package oculusAne.away3d 
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

		public var oculusBarrelDistortionFilterLeft:OculusBarrelDistortionFilter3D;
		public var oculusBarrelDistortionFilterRight:OculusBarrelDistortionFilter3D;
		
		public function OculusView(scene:OculusScene3D, camera:OculusCamera) 
		{
			_scene = scene;
			_camera = camera;

			leftView = new View3D(_scene, _camera.leftCamera);
			addChild(leftView);
			
			rightView = new View3D(_scene, _camera.rightCamera);
			addChild(rightView);
			
			//setTimeout(checkForContext, 2000);
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
			
			//oculusBarrelDistortionFilterLeft =  new OculusBarrelDistortionFilter3D(0.5+_camera.horizontalShiftPercentage, 0.5, 2, 0.46, dk[0], dk[1], dk[2], dk[3]);
			oculusBarrelDistortionFilterLeft =  new OculusBarrelDistortionFilter3D(0.5+_camera.horizontalShiftPercentage, 0.5, 3, 0.22, dk[0], dk[1], dk[2], dk[3]);
			leftView.filters3d = [oculusBarrelDistortionFilterLeft];
			
			//oculusBarrelDistortionFilterRight = new OculusBarrelDistortionFilter3D(0.5-_camera.horizontalShiftPercentage, 0.5, 2, 0.46, dk[0], dk[1], dk[2], dk[3]);
			oculusBarrelDistortionFilterRight = new OculusBarrelDistortionFilter3D(0.5-_camera.horizontalShiftPercentage, 0.5, 3, 0.22, dk[0], dk[1], dk[2], dk[3]);
			rightView.filters3d = [oculusBarrelDistortionFilterRight];
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
	}

}