package  
{
	import flare.basic.*;
	import flare.core.*;
	import flare.flsl.*;
	import flare.materials.*;
	import flare.materials.filters.*;
	import flare.primitives.*;
	import flare.system.*;
	import flash.display.*;
	import flash.geom.*;
	import oculusANE.OculusANE;
	//import oculusANE.*;
	
	/**
	 * @author Ariel Nehmad
	 */
	public class OculusScene3D extends Scene3D 
	{
		[Embed(source = "dk2.flsl.compiled", mimeType = "application/octet-stream")]
		private var Disortion:Class;
		
		[Embed(source = "oculus.json", mimeType = "application/octet-stream")]
		private var oculusJson:Class;
		
		private var _texture:Texture3D;
		private var _ocCam:Camera3D;
		private var _ocShader:FLSLMaterial;
		
		private var _stage:Stage;
		private var _ocMeshes:Vector.<Mesh3D> = new Vector.<Mesh3D>();		
		
		private var _stereoQuad:Quad = new Quad("quad", 0, 0, 1280 / 4, 720/4 );
		
		private var _leftRect:Rectangle;
		private var _rightRect:Rectangle;
		//private var _screenRect:Rectangle;
		private var _leftProj:Matrix3D;
		private var _rightProj:Matrix3D;
		//private var _projectionCenterOffset:Number;
		//private var _yfov:Number;
		//private var _scaleX:Number;
		//private var _scaleIn:Number;
		//private var _aspect:Number;
		//private var _factor:Number;
		
		private var _halfIPD:Number;
		private var _hResTexture:Number;
		private var _vResTexture:Number;
		private var _hmdInfo:Object;
		//private var _createTextureTimeout:int;
		
		//public var oculus:Object;
		public var oculus:OculusANE;
		
		public function OculusScene3D( container:DisplayObjectContainer ) 
		{
			super( container );
			
			_stage = container.stage;
			
			oculus = new OculusANE();
			//oculus = new Object();
			//oculus.isSupported = function():Boolean { return false };
			
			super.camera = new Camera3D( "ocCamera" );
			super.camera.setPosition( 0, 0, 0 );
			

			//if (oculus.isSupported()) {
				_hmdInfo = oculus.getHMDInfo();
			//}else {
				//info = JSON.parse(new oculusJson());
			//}
			
			
			//trace(JSON.stringify(info));

			_halfIPD = parseFloat(_hmdInfo.IPD) / 2;
			_hResTexture = _hmdInfo.renderTargetSize.w;
			_vResTexture = _hmdInfo.renderTargetSize.h;
			
			//_hResTexture /= 2;
			//_vResTexture /= 2;
			
			_ocCam = new Camera3D( "oculusCam" );
			_ocCam.fieldOfView = 90;
			_ocCam.near = 0.01;
			_ocCam.far = 10000;
			
			//_ocCam.updateProjectionMatrix();
			trace( "_ocCam : " + _ocCam.projection.rawData );
			
			// make sure to compile with -swf-version 22 or above.
			_texture = new Texture3D(new Rectangle(0, 0, _hResTexture, _vResTexture));
			_texture.mipMode = Texture3D.MIP_NONE;
			_texture.upload( scene );
			
			_ocShader = new FLSLMaterial( "ocShader", new Disortion() );
			_ocShader.params.EyeRotationStart.value = new Matrix3D;
			_ocShader.params.EyeRotationEnd.value = new Matrix3D;
			_ocShader.params.EyeToSourceUVScale.value[0] = _hmdInfo.eyeInfos[0].UVScaleOffset.eyeToSourceUVScale.x;
			_ocShader.params.EyeToSourceUVScale.value[1] = _hmdInfo.eyeInfos[0].UVScaleOffset.eyeToSourceUVScale.y;
			_ocShader.params.EyeToSourceUVOffset.value[0] = _hmdInfo.eyeInfos[0].UVScaleOffset.eyeToSourceUVOffset.x;
			_ocShader.params.EyeToSourceUVOffset.value[1] = _hmdInfo.eyeInfos[0].UVScaleOffset.eyeToSourceUVOffset.y;
			_ocShader.params.texture.value = _texture;
			
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
				
				
				var rawData:Vector.<Number> = _hmdInfo.eyeInfos[eyeNum].projection;
				rawData[10] = -rawData[10];
				rawData[11] = rawData[11] * -100;
				
				if (eyeNum == 0) {
					_leftRect = new Rectangle( 0, 0, _hResTexture * 0.5, _vResTexture );
					_leftProj = new Matrix3D( rawData );
					//trace( "_leftProj : " + _leftProj.rawData );
					//_leftProj.appendTranslation( -_halfIPD, 0, 0);
					//_leftProj.appendScale(0.5, 1, 1);
					//_leftProj.prependScale( 1, 1, -1 );
					
				}else {
					_rightRect = new Rectangle( _hResTexture * 0.5, 0, _hResTexture * 0.5, _vResTexture );
					_rightProj = new Matrix3D( rawData );
					//_rightProj.appendTranslation(_halfIPD, 0, 0);
					//_rightProj.appendScale(0.5, 1, 1);
					//_rightProj.prependScale( 1, 1, -1 );
				}
				
				_ocMeshes.push( eyeMesh );

				
				var _stereoMat:Material3D = new Shader3D("stero", [new TextureMapFilter(_texture)], false);
				_stereoQuad.material = _stereoMat;
				_stereoQuad.x = 200;
				
			}

			updateProjection();
		}
		
		private function updateProjection():void 
		{
			var viewCenter:Number = 0.14975999295711517 * 0.25;
			var eyeProjectionShift:Number = viewCenter - 0.07350000202655792 * 0.5;
			var projectionCenterOffset:Number = 2 * eyeProjectionShift / 0.14975999295711517;
			
			_leftRect = new Rectangle( 0, 0, _hResTexture * 0.5, _vResTexture );
			_leftProj = ocProjection( _leftRect, 0.01, 10000, -projectionCenterOffset );
			
			_rightRect = new Rectangle( _hResTexture * 0.5, 0, _hResTexture * 0.5, _vResTexture );
			_rightProj = ocProjection( _rightRect, 0.01, 10000, projectionCenterOffset );	
		}
		
		private function ocProjection( view:Rectangle, near:Number, far:Number, offset:Number ):Matrix3D
		{  	
			var halfScreenDistance:Number = 1 * 0.09359999746084213 * 0.5;
			var yfov:Number = (2.0 * Math.atan( halfScreenDistance / 0.04100000113248825)) * (180 / Math.PI) * 1;
			yfov = 3;
			trace( "yfov : " + yfov );
			
			var w:Number = _hResTexture;
			var h:Number = _vResTexture;
			var aspect:Number = view.width / view.height;
			var y:Number = 2 / yfov * aspect;
			var x:Number = y / aspect;
			
			var rawData:Vector.<Number> = new Vector.<Number>( 16, true );
			rawData[10] = far / (near - far);
			rawData[11] = -1;
			rawData[14] = (far * near) / (near - far);
			rawData[0] = x / ( w / view.width );
			rawData[5] = y / ( h / view.height );
			rawData[8] = 1 - ( view.width / w ) - view.x / w * 2 + offset;
			rawData[9] = -1 + ( view.height / h ) + view.y / h * 2;
			
			var proj:Matrix3D = new Matrix3D( rawData );
				proj.prependScale( 1, 1, -1 );
			return proj;
		}
				
		override public function render(camera:Camera3D = null, clearDepth:Boolean = false, target:Texture3D = null):void 
		{
			super.context.setRenderToTexture( _texture.texture, true, 0 );
			super.context.clear();
			
			//var info:Object = oculus.getRenderInfo();
			//info.eyeInfos[0].projection
			// render left eye.
			_ocCam.projection = _leftProj;
			_ocCam.copyTransformFrom( scene.camera, false );
			_ocCam.translateX( -_halfIPD);
			super.context.setScissorRectangle( _leftRect );
			super.render( _ocCam );
			
			// render right eye.
			_ocCam.projection = _rightProj;
			_ocCam.copyTransformFrom( scene.camera, false );
			_ocCam.translateX(_halfIPD);
			super.context.setScissorRectangle( _rightRect );
			super.render( _ocCam );
			
			super.context.setRenderToBackBuffer();
			//super.context.clear( 0.1, 0.2, 0.3, 1 );
			super.context.clear();
			super.context.setScissorRectangle( null );
			
			_ocShader.params.EyeToSourceUVScale.value[0] = _hmdInfo.eyeInfos[0].UVScaleOffset.eyeToSourceUVScale.x;
			_ocShader.params.EyeToSourceUVScale.value[1] = _hmdInfo.eyeInfos[0].UVScaleOffset.eyeToSourceUVScale.y;
			_ocShader.params.EyeToSourceUVOffset.value[0] = _hmdInfo.eyeInfos[0].UVScaleOffset.eyeToSourceUVOffset.x;
			_ocShader.params.EyeToSourceUVOffset.value[1] = _hmdInfo.eyeInfos[0].UVScaleOffset.eyeToSourceUVOffset.y;
			_ocMeshes[0].draw( false, _ocShader );		
			
			_ocShader.params.EyeToSourceUVScale.value[0] = _hmdInfo.eyeInfos[1].UVScaleOffset.eyeToSourceUVScale.x;
			_ocShader.params.EyeToSourceUVScale.value[1] = _hmdInfo.eyeInfos[1].UVScaleOffset.eyeToSourceUVScale.y;
			_ocShader.params.EyeToSourceUVOffset.value[0] = _hmdInfo.eyeInfos[1].UVScaleOffset.eyeToSourceUVOffset.x;
			_ocShader.params.EyeToSourceUVOffset.value[1] = _hmdInfo.eyeInfos[1].UVScaleOffset.eyeToSourceUVOffset.y;
			_ocMeshes[1].draw( false, _ocShader );
			
			//_stereoQuad.draw(true);
		}
		
		public function applyHeadRotationTo(target:Pivot3D):void {
			if ( oculus.isSupported() ) {
				var vec:Vector.<Number> = oculus.getCameraQuaternion();
				quatToTransform( -vec[0], -vec[1], vec[2], vec[3], target );				
			}
		}
		
		public function applyHeadPositionTo(head:Pivot3D):void 
		{
			if ( oculus.isSupported() ) {
				var vec:Vector.<Vector3D> = oculus.getOculusPosition();
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
		
		//public function get projectionCenterOffset():Number 
		//{
			//return _projectionCenterOffset;
		//}
		//
		//public function set projectionCenterOffset(value:Number):void 
		//{
			//_projectionCenterOffset = value;
			//trace( "projectionCenterOffset : " + _projectionCenterOffset );
		//}
		//
		//public function get IPD():Number 
		//{
			//return _halfIPD * 2;
		//}
		//
		//public function set IPD(value:Number):void 
		//{
			//_halfIPD = value / 2;
			//trace( "IPD : " + value + " m.");
		//}
		
		//public function get factor():Number 
		//{
			//return _factor;
		//}
		//
		//private var _hResInputTexture:int = 1920;
		//private var _vResInputTexture:int = 1080;
//
		//public function set inputTextureSize(value:int):void {
			//_hResInputTexture = value;
			//_vResInputTexture = value * (800 / 1280);
			//factor = _factor;
		//}
		//public function get inputTextureSize():int {
			//return _hResInputTexture;
		//}
		//
			//
		//
		//public function set factor(value:Number):void 
		//{
			//_factor = value;
			//trace( "factor : " + _factor );
			//
			//// the below is correct but as adobe air does not allow for antiAliasing when rendering to texture we want the input texture to be even bigger
			////_hResTexture = Math.round(hmd.hResolution * factor);
			////_vResTexture = Math.round(hmd.vResolution * factor);
			//
			//// TEMP use the lines above when render to texture antiAliasing becomes available
			//_hResTexture = Math.round(_hResInputTexture * factor);
			//_vResTexture = Math.round(_vResInputTexture * factor);
			//
			//var halfScreenDistance:Number = 1 * _hmd.vScreenSize * 0.5;
			//yfov = (2.0 * Math.atan( halfScreenDistance / _hmd.eyeToScreenDistance)) * (180 / Math.PI) * factor;
			//
			//scaleIn = 1;
			//scale = (1 / factor) / 2;
			//
			//if (_createTextureTimeout) {
				//clearTimeout(_createTextureTimeout);
			//}
			//
			//_createTextureTimeout = setTimeout(function():void {
				//_texture = new Texture3D(new Rectangle(0, 0, _hResTexture, _vResTexture));
				//trace( "_vResTexture : " + _vResTexture );
				//trace( "_hResTexture : " + _hResTexture );
				////_texture.mipMode = Texture3D.MIP_NONE;
				//_texture.upload( scene );
				//_ocShader.params.texture.value = _texture;
				//
				//_ocMesh.surfaces[0].material['filters'].push(new TextureMapFilter(_texture));
				//
				//}, 200);
//
		//}
		//
		//public function get yfov():Number 
		//{
			//return _yfov;
		//}
		//
		//public function set yfov(value:Number):void 
		//{
			//_yfov = value / (180 / Math.PI);
			//trace( "yfov : " + value );
			//updateProjection();
		//}
		//
//
		//public function get scale():Number 
		//{
			//return _scaleX;
		//}
		//
		//public function set scale(value:Number):void 
		//{
			//_scaleX = value;
			//trace( "scale : " + _scaleX );
//
			////_ocShader.params.Scale.value[0] = _scaleX / 2;
			////_ocShader.params.Scale.value[1] = (_scaleX) * _aspect;
		//}
		//
		//public function get scaleIn():Number 
		//{
			//return _scaleIn;
		//}
		//
		//public function set scaleIn(value:Number):void 
		//{
			//_scaleIn = value;
			//trace( "scaleIn : " + scaleIn );
			//
			////_ocShader.params.ScaleIn.value[0] = _scaleIn;
			////_ocShader.params.ScaleIn.value[1] = _scaleIn / _aspect;
		//}
		
	}
}