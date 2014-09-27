package  
{
	import flare.basic.*;
	import flare.core.*;
	import flare.flsl.*;
	import flare.materials.*;
	import flare.materials.filters.*;
	import flare.physics.test.AxisInfo;
	import flare.primitives.*;
	import flare.system.*;
	import flare.utils.Matrix3DUtils;
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import oculusANE.OculusANE;
	//import oculusANE.*;
	
	/**
	 * @author Ariel Nehmad
	 */
	public class OculusScene3D extends Scene3D 
	{
		[Embed(source = "fxaa.flsl.compiled", mimeType = "application/octet-stream")]
		private var FXAA:Class;
		
		[Embed(source = "dk2.flsl.compiled", mimeType = "application/octet-stream")]
		private var Disortion:Class;
		
		[Embed(source = "oculus.json", mimeType = "application/octet-stream")]
		private var oculusJson:Class;
		
		private var _texture:Texture3D;
		private var _distortionTexture:Texture3D;
		private var _ocCam:Camera3D;
		private var _ocShader:FLSLMaterial;
		private var _fxaaShader:FLSLMaterial;
		
		private var _stage:Stage;
		
		// one for each eye
		private var _ocMeshes:Vector.<Mesh3D> = new Vector.<Mesh3D>();
		private var _scissorRectangles:Vector.<Rectangle> = new Vector.<Rectangle>();
		private var _projections:Vector.<Matrix3D> = new Vector.<Matrix3D>();
		
		private var _ipd:Number;
		
		private var _preferredTextureSize:Rectangle = new Rectangle();
		
		private var _vFov:Number;
		private var _hmdInfo:Object;
		private var _useTimewarp:Boolean = true;
		private var _useFXAA:Boolean = true;
		private var _lowPersistence:Boolean = true;
		private var _isSupported:Boolean = false;
		private var _bRender:Boolean = true;
		private var _textureScale:Number = 1;
		private var _textureSize:Rectangle;
		private var _createTextureTimeout:int;
		private var _rotationMatrix:Matrix3D = new Matrix3D();
		
		public var _oculusANE:OculusANE;
		public var headRotationTarget:Pivot3D;
		public var headPositionTarget:Pivot3D;
		
		public function OculusScene3D( container:DisplayObjectContainer ) 
		{
			super( container );
			
			_stage = container.stage;
			
			
			super.camera = new Camera3D( "ocCamera" );
			super.camera.setPosition( 0, 0, 0 );
			
			initOculusScene();
		}
		
		private function initOculusScene():void 
		{
			//trace(JSON.stringify(info));
			
			_oculusANE = new OculusANE();
			
			
			_isSupported = _oculusANE.isSupported();
			if (!_isSupported) {
				return;
			}
			
			_hmdInfo = _oculusANE.getHMDInfo();
			lowPersistence = _lowPersistence;

			// TODO : workout nice oculus fake
			//_hmdInfo = JSON.parse(new oculusJson())
			//_isSupported = true,
			
			_vFov = _hmdInfo.eyeInfos[eyeNum].vFov;
			trace( "vFov sdk : " + _vFov * (180 / Math.PI) );
			trace( "hFov sdk : " + _hmdInfo.eyeInfos[eyeNum].hFov * (180 / Math.PI) );
			
			// this feels better
			_vFov = 2.22;
			IPD = parseFloat(_hmdInfo.IPD);
			
			_preferredTextureSize.width = _hmdInfo.renderTargetSize.w;
			_preferredTextureSize.height = _hmdInfo.renderTargetSize.h;
			
			_ocCam = new Camera3D( "oculusCam" );
			
			_ocShader = new FLSLMaterial( "ocShader", new Disortion() );
			_ocShader.params.EyeRotationStart.value = new Matrix3D;
			_ocShader.params.EyeRotationEnd.value = new Matrix3D;
			_ocShader.params.EyeToSourceUVScale.value[0] = _hmdInfo.eyeInfos[0].UVScaleOffset.eyeToSourceUVScale.x;
			_ocShader.params.EyeToSourceUVScale.value[1] = _hmdInfo.eyeInfos[0].UVScaleOffset.eyeToSourceUVScale.y;
			_ocShader.params.EyeToSourceUVOffset.value[0] = _hmdInfo.eyeInfos[0].UVScaleOffset.eyeToSourceUVOffset.x;
			_ocShader.params.EyeToSourceUVOffset.value[1] = _hmdInfo.eyeInfos[0].UVScaleOffset.eyeToSourceUVOffset.y;
			
			_fxaaShader = new FLSLMaterial( "fxaa", new FXAA() );
			
			// for each eye make a mesh
			var eyeMesh:Mesh3D;
			for ( var eyeNum:int = 0; eyeNum < 2; eyeNum++ ) {
				eyeMesh = new Mesh3D( 'eye' + eyeNum );
				eyeMesh.surfaces[0] = new Surface3D("Oculus");			
				eyeMesh.surfaces[0].addVertexData( Surface3D.POSITION, 2 ); // position x, y
				eyeMesh.surfaces[0].addVertexData( Surface3D.UV2, 2 ); // texR u, v
				eyeMesh.surfaces[0].addVertexData( Surface3D.UV1, 2 ); // texG u, v
				eyeMesh.surfaces[0].addVertexData( Surface3D.UV0, 2 ); // texB u, v
				eyeMesh.surfaces[0].addVertexData( Surface3D.COLOR0, 2 ); // timewarpLerpFactor / vignette 
				
				for each (var item:Object in _hmdInfo.eyeInfos[eyeNum].vertexData) 
					eyeMesh.surfaces[0].vertexVector.push( 
						item.posX, 
						item.posY, 
						item.texB.x, 
						item.texB.y, 
						item.texG.x, 
						item.texG.y, 
						item.texR.x, 
						item.texR.y, 
						item.colA / 256, 
						item.colRGB / 256);
				
				for ( var i:int = 0; i < _hmdInfo.eyeInfos[eyeNum].indexCount; i++ ) {
					var index:int = parseInt(_hmdInfo.eyeInfos[eyeNum].indexData[i]);
					eyeMesh.surfaces[0].indexVector.push(index);
				}
				
				_ocMeshes.push( eyeMesh );
			}
			
			createTexture(false);
		}
		
		private function createTexture(useTimeout:Boolean = true):void 
		{
			// make sure to compile with -swf-version 22 or above.
			_textureSize = new Rectangle(0, 0, Math.round(_preferredTextureSize.width * _textureScale), Math.round(_preferredTextureSize.height * _textureScale));
			
			for ( var eyeNum:int = 0; eyeNum < 2; eyeNum++ ) {
				_scissorRectangles[eyeNum] = new Rectangle( Math.round(eyeNum * (_textureSize.width * 0.5)), 0, Math.round(_textureSize.width * 0.5), _textureSize.height );
				
				// the Oculus SDK provides the projections, but they are weird and seem wrong.
				//var rawProjectionData:Vector.<Number> = _hmdInfo.eyeInfos[eyeNum].projection;
				//trace( "rawProjectionData1 : " + rawProjectionData.toString() );
				//rawProjectionData[0] = rawProjectionData[0]/2;
				//_projections[eyeNum] = new Matrix3D(rawProjectionData);
				
				// because of the wrong projections we're building one ourselves
				_projections[eyeNum] = createProjection(eyeNum, _scissorRectangles[eyeNum]);
			}
			
			clearTimeout(_createTextureTimeout);
			_createTextureTimeout = setTimeout(function ():void { 
					_texture = new Texture3D(_textureSize);
					_texture.mipMode = Texture3D.MIP_NONE;
					_texture.upload( scene );
					_ocShader.params.texture.value = _texture;	
					
					_distortionTexture = new Texture3D(_textureSize);
					_distortionTexture.mipMode = Texture3D.MIP_NONE;
					_distortionTexture.upload( scene );					
				}, (useTimeout?500:0));
		}
		
		private function createProjection(eyeNum:int, scissorRect:Rectangle):Matrix3D
		{
			//var viewCenter:Number = _hmd.hScreenSize * 0.25;
			//var eyeProjectionShift:Number = viewCenter - _hmd.lensSeparationDistance * 0.5;
			//projectionCenterOffset = 2 * eyeProjectionShift / _hmd.hScreenSize;
			// DK1
			var viewCenter:Number = 0.14975999295711517 * 0.25;
			var eyeProjectionShift:Number = viewCenter - (0.07350000202655792 * 0.5);
			var projectionCenterOffset:Number = 2 * eyeProjectionShift / 0.14975999295711517;
			
			// DK2
			viewCenter = 0.126186692 * 0.25;
			eyeProjectionShift = viewCenter - (0.064 * 0.5);
			projectionCenterOffset = 2 * eyeProjectionShift / 0.126186692;
			trace( "projectionCenterOffset1 : " + projectionCenterOffset );
			
			if (eyeNum == 0) {
				projectionCenterOffset *= -1;
			}
			
			// testing from sdk
			//projectionCenterOffset = _hmdInfo.eyeInfos[eyeNum].viewAdjust[0];
			//trace( "projectionCenterOffset2 : " + projectionCenterOffset );
			
			//projectionCenterOffset = 0;
			//_vFov = _hmdInfo.eyeInfos[eyeNum].vFov;
			//trace( "_vFov : " + _vFov );
			//trace( "vFov : " + _vFov * (180 / Math.PI) );
			
			return ocProjection( scissorRect, 0.01, 10000, projectionCenterOffset );	
		}
		
		private function ocProjection( view:Rectangle, near:Number, far:Number, offset:Number):Matrix3D
		{  	
			var w:Number = _textureSize.width;
			var h:Number = _textureSize.height;
			var aspect:Number = view.width / view.height;
			var y:Number = 2 / _vFov * aspect;
			trace( "vFov : " + _vFov * (180 / Math.PI) );
			trace( "y : " + y );
			var x:Number = y / aspect;
			trace( "x : " + x );
			
			var rawData:Vector.<Number> = new Vector.<Number>( 16, true );
			rawData[10] = far / (near - far);
			rawData[11] = -1;
			rawData[14] = (far * near) / (near - far);
			rawData[0] = x / ( w / view.width );
			rawData[5] = y / ( h / view.height );
			rawData[8] = (1 - ( view.width / w ) - view.x / w * 2 + offset);
			rawData[9] = (-1 + ( view.height / h ) + view.y / h * 2);
			_hmdInfo
			var proj:Matrix3D = new Matrix3D( rawData );
			proj.prependScale( 1, 1, -1 );
			//proj.prependRotation( 180, new Vector3D(0,0,1) );
			return proj;
		}
				
		override public function render(camera:Camera3D = null, clearDepth:Boolean = false, target:Texture3D = null):void 
		{
			if (_isSupported) {
				
				var info:Object;
				var eyeNum:int;
				
				//info = _oculusANE.getRenderInfo();

				if (_bRender) {
					
					super.context.setRenderToTexture( _texture.texture, true, 0 );
					super.context.clear();

					for ( eyeNum = 0; eyeNum < 2; eyeNum++ ) {

						info = _oculusANE.getEyePose(eyeNum);
						//_oculusANE.beginFrameTiming();
						
						//trace( "info.eyeInfos[eyeNum].position : " + info.eyeInfos[eyeNum].position );
						if (headPositionTarget) {
							headPositionTarget.x = info.position[0];
							headPositionTarget.y = info.position[1];
							headPositionTarget.z = -info.position[2];						
						}
						
						if (headRotationTarget) {
							var vec:Vector.<Number> = info.orientation as Vector.<Number>;
							quatToTransform( -vec[0], -vec[1], vec[2], vec[3], headRotationTarget );						
						}
							
						
						_ocCam.projection = _projections[eyeNum];
						// position the camera
						_ocCam.copyTransformFrom( scene.camera, false );
						_ocCam.translateX( (eyeNum*(IPD))-(IPD/2));
						super.context.setScissorRectangle( _scissorRectangles[eyeNum] );
						super.render( _ocCam );
					}
					
				}
				
				if (_useFXAA) {
					super.context.setRenderToTexture( _distortionTexture.texture, true, 0 );					
				}else {
					super.context.setRenderToBackBuffer();
				}
				
				super.context.clear();
				super.context.setScissorRectangle( null );
	
				
				for ( eyeNum = 0; eyeNum < 2; eyeNum++ ) {				
					
					_ocShader.params.EyeToSourceUVScale.value[0] = _hmdInfo.eyeInfos[eyeNum].UVScaleOffset.eyeToSourceUVScale.x;
					_ocShader.params.EyeToSourceUVScale.value[1] = _hmdInfo.eyeInfos[eyeNum].UVScaleOffset.eyeToSourceUVScale.y;
					_ocShader.params.EyeToSourceUVOffset.value[0] = _hmdInfo.eyeInfos[eyeNum].UVScaleOffset.eyeToSourceUVOffset.x;
					_ocShader.params.EyeToSourceUVOffset.value[1] = _hmdInfo.eyeInfos[eyeNum].UVScaleOffset.eyeToSourceUVOffset.y;
					
					// timewarp stuff is doing weird.. disabled for the moment
					if (_useTimewarp) {
						info = _oculusANE.getEyeTimewarpMatrices(eyeNum);
						
						//trace( "info.eyeRotationStart : " + info.eyeRotationStart );
						
						//info.eyeRotationStart[0] = -info.eyeRotationStart[0];
						_rotationMatrix.rawData = info.eyeRotationStart;
						_rotationMatrix.invert();
						_ocShader.params.EyeRotationStart.value.rawData = _rotationMatrix.rawData;
						
						//info.eyeRotationEnd[0] = -info.eyeRotationEnd[0];
						_rotationMatrix.rawData = info.eyeRotationEnd;
						_rotationMatrix.invert();
						_ocShader.params.EyeRotationEnd.value.rawData = _rotationMatrix.rawData;
					}
					
					_ocMeshes[eyeNum].draw( false, _ocShader );	
				}
				
				//_oculusANE.endFrameTiming();
				
				if (_useFXAA) {
					super.context.setRenderToBackBuffer();
					_fxaaShader.setTechnique( "fxaa" );
					_fxaaShader.params.resolution.value[0] = scene.viewPort.width;
					_fxaaShader.params.resolution.value[1] = scene.viewPort.height;
					_fxaaShader.params.targetBuffer.value = _distortionTexture;
					_fxaaShader.drawQuad();					
				}
				
			}else {
				super.render(camera, clearDepth, target);
			}
		}
		
		public function applyHeadRotationTo(target:Pivot3D):void {
			if ( _isSupported ) {
				var vec:Vector.<Number> = _oculusANE.getCameraQuaternion();
				quatToTransform( -vec[0], -vec[1], vec[2], vec[3], target );				
			}
		}
		
		public function applyHeadPositionTo(head:Pivot3D):void 
		{
			if ( _isSupported ) {
				var vec:Vector.<Vector3D> = _oculusANE.getOculusPosition();
				//trace( "vec : " + vec );
				head.x = vec[0].x;
				head.y = vec[0].y;
				head.z = -vec[0].z;
			}
		}
		
		protected function quatToTransform( x:Number, y:Number, z:Number, w:Number, target:Pivot3D ):void
		{
			var rawData:Vector.<Number> = new Vector.<Number>( 16, true );
			var xy2:Number = 2.0 * x * y, xz2:Number = 2.0 * x * z, xw2:Number = 2.0 * x * w;
			var yz2:Number = 2.0 * y * z, yw2:Number = 2.0 * y * w, zw2:Number = 2.0 * z * w;
			var xx:Number = x * x, yy:Number = y * y, zz:Number = z * z, ww:Number = w * w;
			rawData[0] = xx - yy - zz + ww;
			rawData[4] = xy2 - zw2;
			rawData[8] = xz2 + yw2;
			rawData[12] = target.x;
			rawData[1] = xy2 + zw2;
			rawData[5] = -xx + yy - zz + ww;
			rawData[9] = yz2 - xw2;
			rawData[13] = target.y;
			rawData[2] = xz2 - yw2;
			rawData[6] = yz2 + xw2;
			rawData[10] = -xx - yy + zz + ww;
			rawData[14] = target.z;
			rawData[3] = 0.0;
			rawData[7] = 0.0;
			rawData[11] = 0;
			rawData[15] = 1;
			target.transform.copyRawDataFrom(rawData);
			target.updateTransforms(true);
		}
		
		public function get bRender():Boolean 
		{
			return _bRender;
		}
		
		public function set bRender(value:Boolean):void 
		{
			_bRender = value;
		}
		
		public function get hmdInfo():Object 
		{
			return _hmdInfo;
		}
		
		public function set hmdInfo(value:Object):void 
		{
			_hmdInfo = value;
		}
		
		public function get preferredTextureSize():Rectangle 
		{
			return _preferredTextureSize;
		}
		
		public function get textureScale():Number 
		{
			return _textureScale;
		}
		
		public function set textureScale(value:Number):void 
		{
			_textureScale = value;
			createTexture();
		}
		
		public function get lowPersistence():Boolean 
		{
			return _lowPersistence;
		}
		
		public function set lowPersistence(value:Boolean):void 
		{
			_lowPersistence = value;
			if (_isSupported) {
				if (_lowPersistence) {
					_oculusANE.setEnabledCaps(OculusANE.ovrHmdCap_LowPersistence + OculusANE.ovrHmdCap_DynamicPrediction);					
				}else {
					_oculusANE.setEnabledCaps(OculusANE.ovrHmdCap_DynamicPrediction);
				}
			}
		}
		
		public function get useTimewarp():Boolean 
		{
			return _useTimewarp;
		}
		
		public function set useTimewarp(value:Boolean):void 
		{
			_useTimewarp = value;
		}
		
		public function get vFov():Number 
		{
			return _vFov;
		}
		
		public function set vFov(value:Number):void 
		{
			_vFov = value;
			_projections[0] = createProjection(0, _scissorRectangles[0]);
			_projections[1] = createProjection(1, _scissorRectangles[1]);
		}
		
		public function get IPD():Number 
		{
			return _ipd;
		}
		
		public function set IPD(value:Number):void 
		{
			_ipd = value;
		}
		
		public function get useFXAA():Boolean 
		{
			return _useFXAA;
		}
		
		public function set useFXAA(value:Boolean):void 
		{
			_useFXAA = value;
		}
	}
}