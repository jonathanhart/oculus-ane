package be.but.oculus
{
	import away3d.cameras.lenses.LensBase;
	import away3d.containers.Scene3D;
	import away3d.controllers.FirstPersonController;
	import away3d.controllers.HoverController;
	import away3d.filters.BloomFilter3D;
	import away3d.filters.MotionBlurFilter3D;
	import away3d.filters.RadialBlurFilter3D;
	import com.numeda.OculusANE.OculusANE;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.utils.setTimeout;
	import uk.co.soulwire.gui.SimpleGUI;
	
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
		private var gui:SimpleGUI;
		private var _tracker:OculusANE;
		
		public function OculusSetup() 
		{
			instance = this;
			
			var zFar:Number = 12000;
			var zNear:Number = 0.5;
			
			_tracker = new OculusANE();
			var infoObj:Object = new Object();
			//if (_oculusAne.isSupported()) {
				//infoObj = _oculusAne.getHMDInfo();
			//}else {
				infoObj.hScreenSize = 0.14976;
				infoObj.vScreenSize = 0.09356;
				infoObj.vScreenCenter = 0.0468;
				infoObj.eyeToScreenDistance = 0.041;
				infoObj.lensSeparationDistance = 0.0635;
				infoObj.interPupillaryDistance = 0.054;
				infoObj.hResolution = 1280;
				infoObj.vResolution = 800;
				infoObj.kDistortion = [1, 0.22, 0.24, 0];
				infoObj.chromAbCorrection = [0.996, -0.004, 1.014, 0];
			//}
			
			var fov:Number = (2 * Math.atan(infoObj.vScreenSize / (2 * infoObj.eyeToScreenDistance))) * 57.2957795;
			var halfScreenAspectRatio:Number = infoObj.hResolution / (2 * infoObj.vResolution);
			
			var horizontalShift:Number = (infoObj.hScreenSize / 4) - (infoObj.lensSeparationDistance / 2); // meters per eye
			var horizontalShiftPercentage:Number = horizontalShift / (infoObj.hScreenSize / 2);
			
			/*
			var projectionVector:Vector.<Number> = new Vector.<Number>;
			projectionVector.push(1 / (halfScreenAspectRatio * Math.tan(fov/2)));
			projectionVector.push(0);
			projectionVector.push(0);
			projectionVector.push(0);
			
			projectionVector.push(0);
			projectionVector.push(1 / (Math.tan(fov/2)));
			projectionVector.push(0);
			projectionVector.push(0);
			
			projectionVector.push(0);
			projectionVector.push(0);
			projectionVector.push(zFar / (zNear - zFar));
			projectionVector.push((zFar * zNear) / (zNear - zFar));
			
			projectionVector.push(0);
			projectionVector.push(0);
			projectionVector.push(-1);
			projectionVector.push(0);
			
			var projectionCenterMatrix:Matrix3D = new Matrix3D(projectionVector);
			trace( "projectionCenterMatrix : " + projectionCenterMatrix );
			*/

			_scene = new Scene3D();
			
			_camera = new OculusCamera(fov, horizontalShiftPercentage);
			_camera.stereoSeperation = 0.054; // m
			_scene.addChild(_camera);
		
			LensBase(_camera.leftCamera.lens).far = zFar;
			LensBase(_camera.rightCamera.lens).far = zFar;			
	
			LensBase(_camera.leftCamera.lens).near = zNear;
			LensBase(_camera.rightCamera.lens).near = zNear;
			
			_view = new OculusView(_scene, _camera);		
			_view.backgroundColor = 0x000000;
			_view.antiAlias = 2;
			addChild(_view);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		
		private function onAddedToStage(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(Event.ENTER_FRAME, onEnteredFrame);
			stage.addEventListener(Event.RESIZE, onResize);

			initGUI();
		}
		

		/**
		 * Initialise the GUI
		 */
		private function initGUI():void
		{
			gui = new SimpleGUI(this);
			gui.addColumn("Settings");
			gui.addSlider("camera.stereoSeperation", 0, 0.07, { label:"stereoSeperation", tick:0.001 } );
			gui.addToggle("view.crossEye");
			gui.show();
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
		
		private function onResize(e:Event = null):void 
		{
			_view.setSize(stage.stageWidth, stage.stageHeight);
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
		
		public function get tracker():OculusANE 
		{
			return _tracker;
		}
		
	}

}