package be.but.oculus 
{
	import away3d.cameras.Camera3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.render.RendererBase;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.events.Event;
	/**
	 * ...
	 * @author 
	 */
	public class OculusView extends Sprite
	{
		public var leftView:View3D;
		public var rightView:View3D;
		
		private var _backgroundColor:Number;
		private var _antiAlias:Number;
		private var _scene:Scene3D;
		private var _camera:OculusCamera;
		private var _width:Number;
		private var _height:Number;
		
		public function OculusView(scene:Scene3D=null, camera:OculusCamera=null, renderer:RendererBase=null, forceSoftware:Boolean=false) 
		{
			if (scene) {
				_scene = scene;
			}
			if (camera) {
				_camera = camera;
			}else {
				_camera = new OculusCamera();
			}
			
			leftView = new View3D(scene, _camera.leftCamera, renderer, forceSoftware);
			rightView = new View3D(scene, _camera.rightCamera, renderer, forceSoftware);
			
			addChild(leftView);
			addChild(rightView);
		}
		
		private function positionViews():void 
		{
			leftView.width = rightView.width = (_width / 2);
			leftView.height = rightView.height = _height;
			rightView.x = leftView.width; // normal
			//leftView.x = leftView.width; // crosseye
			
			trace( "crosseye: " + (leftView.x != 0));
		}
		
		public function render():void 
		{
			leftView.render();
			rightView.render();
		}
		
		override public function get width():Number 
		{
			return _width;
		}
		
		override public function set width(value:Number):void 
		{
			_width = value;
			positionViews();
		}
		
		override public function get height():Number 
		{
			return _height;
		}
		
		override public function set height(value:Number):void 
		{
			_height = value;
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
		
	}

}