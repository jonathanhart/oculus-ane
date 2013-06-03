package be.but.oculus 
{
	import away3d.containers.Scene3D;
	import away3d.controllers.FirstPersonController;
	import away3d.controllers.HoverController;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Fragilem17
	 */
	public class OculusSetup extends Sprite 
	{
		public static var instance:OculusSetup;
		
		private var _view:OculusView;
		private var _scene:Scene3D;
		private var _camera:OculusCamera;
		
		private var _enterFrameHandlers:Vector.<Function> = new Vector.<Function>;
		
		public function OculusSetup() 
		{
			instance = this;
			_scene = new Scene3D();
			
			_camera = new OculusCamera();
			_camera.ipd = 0.054; // m
			_scene.addChild(_camera);
			
			_view = new OculusView(_scene, _camera);
			_view.backgroundColor = 0x000000;
			_view.antiAlias = 1;
			addChild(_view);			
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			stage.addEventListener(Event.ENTER_FRAME, onEnteredFrame);
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		public function addEnterFrameHandler(func:Function):void 
		{
			_enterFrameHandlers.push(func);
		}
		

		private function onEnteredFrame(e:Event):void 
		{
			for each (var func:Function in _enterFrameHandlers) 
			{
				func.call();
			}
			_view.render();
		}
		
		private function onResize(e:Event):void 
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}
		
		
		public function get camera():OculusCamera 
		{
			return _camera;
		}
		
		public function get scene():Scene3D 
		{
			return _scene;
		}
		
		public function get view():OculusView 
		{
			return _view;
		}
		
	}

}