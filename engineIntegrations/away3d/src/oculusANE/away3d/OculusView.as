package oculusANE.away3d 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import away3d.containers.View3D;
	
	/**
	 * ...
	 * @author Fragilem17
	 */
	public class OculusView extends Sprite
	{
		public var leftView:View3D;
		public var rightView:View3D;
		private var _crossEye:Boolean = false;
		
		private var _backgroundColor:Number;
		private var _antiAlias:Number;
		private var _scene:OculusScene3D;
		private var _camera:OculusCamera;
		private var _width:Number;
		private var _height:Number;

		private var _oculusBarrelDistortionFilterLeft:OculusBarrelDistortionFilter3D;
		private var _oculusBarrelDistortionFilterRight:OculusBarrelDistortionFilter3D;

		private var _lensCenterOffsetX:Number = 0;
		private var _lensCenterOffsetY:Number = 0;
		
		public function OculusView(scene:OculusScene3D, camera:OculusCamera) 
		{
			_scene = scene;
			_camera = camera;
			_lensCenterOffsetX = _camera.lensCenterOffset;

			leftView = new View3D(_scene, _camera.leftCamera);
			addChild(leftView);
			
			rightView = new View3D(_scene, _camera.rightCamera);
			addChild(rightView);
			
			checkForContext();
		}
		
		private function checkForContext():void 
		{
			if (leftView.stage3DProxy && leftView.stage3DProxy.context3D) {
				onContextCreated();
			}else {
				setTimeout(checkForContext, 16);
			}
		}
		
		private function onContextCreated():void 
		{
			var dk:Vector.<Number> = scene.hmdInfo.distortionK;
			
			_oculusBarrelDistortionFilterLeft =  new OculusBarrelDistortionFilter3D(0.5 + (_lensCenterOffsetX/2), 0.5, 3.12, 0.25, dk[0], dk[1], dk[2], dk[3]);
			//_oculusBarrelDistortionFilterLeft =  new OculusBarrelDistortionFilter3D(0.545, 0.5, 3.26, 0.175, dk[0], dk[1], dk[2], dk[3]);
			//_oculusBarrelDistortionFilterLeft =  new OculusBarrelDistortionFilter3D(0.545, 0.5, 2, 0.5, dk[0], dk[1], dk[2], dk[3]);
			leftView.filters3d = [_oculusBarrelDistortionFilterLeft];
			
			_oculusBarrelDistortionFilterRight = new OculusBarrelDistortionFilter3D(0.5 - (_lensCenterOffsetX/2), 0.5, 3.12, 0.25, dk[0], dk[1], dk[2], dk[3]);
			//_oculusBarrelDistortionFilterRight = new OculusBarrelDistortionFilter3D(0.455, 0.5, 3.26, 0.175, dk[0], dk[1], dk[2], dk[3]);
			//_oculusBarrelDistortionFilterRight = new OculusBarrelDistortionFilter3D(0.455, 0.5, 2, 0.5, dk[0], dk[1], dk[2], dk[3]);
			rightView.filters3d = [_oculusBarrelDistortionFilterRight];
		}
		
		
		private function positionViews():void 
		{
			trace( "OculusView.positionViews: " + _width );
			if (leftView && rightView) {
				
				leftView.width = rightView.width = (_width / 2);
				leftView.height = rightView.height = _height;
				
				if (_crossEye) {
					rightView.x = 0;
					leftView.x = rightView.x + rightView.width; // crosseye		
				}else {
					leftView.x = 0;
					rightView.x = leftView.x + leftView.width;
				}
			}
		}
		
		public function render(e:Event = null):void 
		{
			if (leftView && rightView) {
				leftView.render();
				rightView.render();				
			}
		}
		
		public function setSize(width:Number, height:Number):void {
			_width = width;
			_height = height;
			positionViews();
		}
		
		public function get backgroundColor():Number 
		{
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:Number):void 
		{
			_backgroundColor = value;
			leftView.backgroundColor = rightView.backgroundColor = _backgroundColor;
		}
		
		public function get antiAlias():Number 
		{
			return _antiAlias;
		}
		
		public function set antiAlias(value:Number):void 
		{
			_antiAlias = value;
			leftView.antiAlias = rightView.antiAlias = _antiAlias;
		}
		
		public function get scene():OculusScene3D 
		{
			return _scene;
		}
		
		public function set scene(value:OculusScene3D):void 
		{
			_scene = value;
			leftView.scene = rightView.scene = _scene;
		}
		
		public function get camera():OculusCamera 
		{
			return _camera;
		}
		
		public function set camera(value:OculusCamera):void 
		{
			_camera = value;
			leftView.camera = _camera.leftCamera;
			rightView.camera = _camera.rightCamera;
		}
		
		public function get crossEye():Boolean 
		{
			return _crossEye;
		}
		
		public function set crossEye(value:Boolean):void 
		{
			_crossEye = value;
			positionViews();
		}
		
		
		
		
		public function get lensCenterOffsetX():Number
		{
			return _lensCenterOffsetX;
		}
		
		public function set lensCenterOffsetX(value:Number):void
		{
			_lensCenterOffsetX = value;
			//_oculusBarrelDistortionFilterLeft.lensCenterX = 0.5 + (_lensCenterOffsetX);
			//_oculusBarrelDistortionFilterRight.lensCenterX = 0.5 - (_lensCenterOffsetX);
			_camera.lensCenterOffset = _lensCenterOffsetX;
			trace("_lensCenterOffsetX: " + _lensCenterOffsetX);
		}
		
		
		public function get barrelDistortionLensCenterOffsetX():Number
		{
			return _oculusBarrelDistortionFilterLeft.lensCenterX - 0.5;
		}
		
		public function set barrelDistortionLensCenterOffsetX(value:Number):void
		{
			_oculusBarrelDistortionFilterLeft.lensCenterX = 0.5 + (value);
			_oculusBarrelDistortionFilterRight.lensCenterX = 0.5 - (value);
			trace("barrelDistortionLensCenterOffsetX: " + value);
		}		
		
		
		
		public function get lensCenterOffsetY():Number
		{
			return _lensCenterOffsetY;
		}
		
		public function set lensCenterOffsetY(value:Number):void
		{
			_lensCenterOffsetY = value;
			_oculusBarrelDistortionFilterLeft.lensCenterY = 0.5 + _lensCenterOffsetY;
			_oculusBarrelDistortionFilterRight.lensCenterY = 0.5 + _lensCenterOffsetY;		
		}
		
		public function get scaleIn():Number
		{
			return _oculusBarrelDistortionFilterLeft.scaleIn;
		}
		
		public function set scaleIn(value:Number):void
		{
			_oculusBarrelDistortionFilterLeft.scaleIn = value;	
			_oculusBarrelDistortionFilterRight.scaleIn = value;		
			trace("scaleIn: " + value);
		}
		
		public function get scale():Number
		{
			return _oculusBarrelDistortionFilterLeft.scale;
		}
		
		public function set scale(value:Number):void
		{
			_oculusBarrelDistortionFilterLeft.scale = value;
			_oculusBarrelDistortionFilterRight.scale = value;	
			trace("scale: " + value);
		}
		
		public function get hmdWarpParamX():Number
		{
			return _oculusBarrelDistortionFilterLeft.hmdWarpParamX;
		}
		
		public function set hmdWarpParamX(value:Number):void
		{
			_oculusBarrelDistortionFilterLeft.hmdWarpParamX = value;
			_oculusBarrelDistortionFilterRight.hmdWarpParamX = value;			
		}
		
		public function get hmdWarpParamY():Number
		{
			return _oculusBarrelDistortionFilterLeft.hmdWarpParamY;
		}
		
		public function set hmdWarpParamY(value:Number):void
		{
			_oculusBarrelDistortionFilterLeft.hmdWarpParamY = value;
			_oculusBarrelDistortionFilterRight.hmdWarpParamY = value;			
		}
		
		public function get hmdWarpParamZ():Number
		{
			return _oculusBarrelDistortionFilterLeft.hmdWarpParamZ;
		}
		
		public function set hmdWarpParamZ(value:Number):void
		{
			_oculusBarrelDistortionFilterLeft.hmdWarpParamZ = value;
			_oculusBarrelDistortionFilterRight.hmdWarpParamZ = value;			
		}
		
		public function get hmdWarpParamW():Number
		{
			return _oculusBarrelDistortionFilterLeft.hmdWarpParamW;
		}
		
		public function set hmdWarpParamW(value:Number):void
		{
			_oculusBarrelDistortionFilterLeft.hmdWarpParamW = value;
			_oculusBarrelDistortionFilterRight.hmdWarpParamW = value;
		}			
	}

}