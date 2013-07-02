package oculusAne.away3d 
{
	import away3d.cameras.Camera3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.render.DefaultRenderer;
	import away3d.core.render.RendererBase;
	import away3d.events.Stage3DEvent;
	import away3d.filters.BloomFilter3D;
	import away3d.filters.BlurFilter3D;
	import away3d.filters.RadialBlurFilter3D;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author 
	 */
	public class OculusView extends Sprite
	{
		public var leftView:View3D;
		public var rightView:View3D;
		private var _crossEye:Boolean = false;
		
		private var _backgroundColor:Number;
		private var _antiAlias:Number;
		private var _scene:Scene3D;
		private var _camera:OculusCamera;
		private var _width:Number;
		private var _height:Number;
		
		public function OculusView(scene:Scene3D, camera:OculusCamera) 
		{
			_scene = scene;
			_camera = camera;

			leftView = new View3D(_scene, _camera.leftCamera);
			addChild(leftView);
			
			rightView = new View3D(_scene, _camera.rightCamera);
			addChild(rightView);
			
			//checkForContext();
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
			rightView.filters3d = [new OculusBarrelDistortionFilter3D()];
			leftView.filters3d = [new OculusBarrelDistortionFilter3D()];
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
		
		public function get scene():Scene3D 
		{
			return _scene;
		}
		
		public function set scene(value:Scene3D):void 
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