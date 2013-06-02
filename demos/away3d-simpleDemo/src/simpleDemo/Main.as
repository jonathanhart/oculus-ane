package simpleDemo
{
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.SegmentMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.TorusGeometry;
	import away3d.primitives.WireframeCube;
	import away3d.primitives.WireframeSphere;
	import be.but.oculus.OculusCamera;
	import be.but.oculus.OculusView;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.media.Camera;
	
	/**
	 * ...
	 * @author Fragilem17
	 */
	public class Main extends Sprite 
	{	
		private var _view:OculusView;
		private var _scene:Scene3D;
		private var _plane:WireframeSphere;
		private var _camera:OculusCamera;
		
		
        // Away3D4 Camera handling variables (Hover Camera)
        private var move:Boolean = false;
        private var lastPanAngle:Number;
        private var lastTiltAngle:Number;
        private var lastMouseX:Number;
        private var lastMouseY:Number;
		private var cameraController:HoverController;
		
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_scene = new Scene3D();
			
			_camera = new OculusCamera();
			_camera.ipd = 381;
			_scene.addChild(_camera);
			
			_view = new OculusView();
			_view.backgroundColor = 0x000000;
			_view.antiAlias = 0;
			_view.scene = _scene;
			_view.camera = _camera;
			addChild(_view);

			_camera.moveBackward(1200);
			for (var i:int = 0; i < 40; i++) 
			{
				_plane = new WireframeSphere(50, 6, 6, getRandomScenePos(), 0.5);
				_plane.position = new Vector3D(getRandomScenePos(), getRandomScenePos(), getRandomScenePos());
				_scene.addChild(_plane);				
			}
			
			cameraController = new HoverController(_camera, null, 0,90, 300);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			addEventListener(Event.ENTER_FRAME, onEnteredFrame);
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		private function getRandomScenePos():Number 
		{
			return 1000 - (Math.random() * 2000);
		}
		
		private function onResize(e:Event):void 
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}
		
		private function onEnteredFrame(e:Event):void 
		{
			// Handle hover camera
            if (move) {
                cameraController.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
                cameraController.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;
             }

			//_camera.leftCamera.rotationX += 1;
			//_camera.rotationY += 1;
			//_plane.rotationX += 1;
			//_plane.rotationY += 0.6;
			
			//_camera.moveBackward(1);
			//_camera.moveRight(0.1);
			//_camera.moveForward(1);
			
			_view.render();
		}
		
		

        private function mouseDownHandler(e:MouseEvent):void
        {
            lastPanAngle = cameraController.panAngle;
            lastTiltAngle = cameraController.tiltAngle;
            lastMouseX = stage.mouseX;
            lastMouseY = stage.mouseY;
            move = true;
            stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
        }

        private function mouseUpHandler(e:MouseEvent):void
        {
            move = false;
            stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
        }

        private function onStageMouseLeave(e:Event):void
        {
            move = false;
            stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
        }
       
		
	}
	
}