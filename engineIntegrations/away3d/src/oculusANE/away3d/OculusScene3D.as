package oculusANE.away3d
{	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import away3d.cameras.lenses.LensBase;
	import away3d.containers.Scene3D;
	import away3d.core.base.Object3D;
	import away3d.core.math.Quaternion;
	
	import oculusANE.HmdInfo;
	import oculusANE.OculusANE;
	
	/**
	 * ...
	 * @author Fragilem17
	 */
	public class OculusScene3D extends Scene3D
	{
		public var trackerTarget:Object3D;
		
		private var _view:OculusView;
		private var _camera:OculusCamera;
		
		private var _enterFrameHandlers:Vector.<Function> = new Vector.<Function>;
		private var _tracker:OculusANE;
		private var _nullVector:Vector3D = new Vector3D();
		
		private var _quatVec:Vector.<Number>;
		private var _quat:Quaternion = new Quaternion();
		private var _prevPos:Vector3D;

		public var hmdInfo:HmdInfo;
		public var lensCenterOffset:Number;
		
		public function OculusScene3D() 
		{			
			var zFar:Number = 24000;
			var zNear:Number = 0.1;
			
			_tracker = new OculusANE();
			
			if (_tracker.isSupported()) {
				// get information from HMD
				hmdInfo = _tracker.getHMDInfo();
			}else {
				// set default values from Oculus devkit 1 
				hmdInfo = new HmdInfo();
				hmdInfo.hScreenSize	= 0.14975999295711517;
				hmdInfo.vScreenSize	= 0.09359999746084213;
				hmdInfo.vScreenCenter = 0.046799998730421066;	
				hmdInfo.eyeToScreenDistance = 0.04100000113248825;
				hmdInfo.lensSeparationDistance = 0.06350000202655792;
				hmdInfo.interPupillaryDistance = 0.06400000303983688;
				hmdInfo.hResolution = 1280;
				hmdInfo.vResolution = 800;
				hmdInfo.distortionK	= new Vector.<Number>;
				hmdInfo.distortionK.push(1);
				hmdInfo.distortionK.push(0.2199999988079071);
				hmdInfo.distortionK.push(0.23999999463558197);
				hmdInfo.distortionK.push(0);
				
				hmdInfo.chromaAbCorrection = new Vector.<Number>;
				hmdInfo.chromaAbCorrection.push(0.9959999918937683);
				hmdInfo.chromaAbCorrection.push(-0.004000000189989805);
				hmdInfo.chromaAbCorrection.push(1.0140000581741333);
				hmdInfo.chromaAbCorrection.push(0);
			}
			
			var fieldOfView:Number = (2 * Math.atan(hmdInfo.vScreenSize / (2 * hmdInfo.eyeToScreenDistance))) * 57.2957795;
			trace("fieldOfView calc: " + fieldOfView);
			// TODO: calculate correct value
			fieldOfView = 111;
			trace("fieldOfView man: " + fieldOfView);
			
			//var halfScreenAspectRatio:Number = hmdInfo.hResolution / (2 * hmdInfo.vResolution);
			
			var horizontalShift:Number = (hmdInfo.hScreenSize / 4) - (hmdInfo.lensSeparationDistance / 2); // meters per eye
			lensCenterOffset = horizontalShift / (hmdInfo.hScreenSize / 2); // percentage 0 - 1
			trace("lensCenterOffset calc: " + lensCenterOffset);
			lensCenterOffset = 0.08;
			//lensCenterOffset = 0.048;
			trace("lensCenterOffset man: " + lensCenterOffset);
			
			_camera = new OculusCamera(fieldOfView, lensCenterOffset);
			_camera.stereoSeperation = hmdInfo.interPupillaryDistance; // m
			_camera.position = _nullVector;
			addChild(_camera);
		
			LensBase(_camera.leftCamera.lens).far = zFar;
			LensBase(_camera.rightCamera.lens).far = zFar;			
	
			LensBase(_camera.leftCamera.lens).near = zNear;
			LensBase(_camera.rightCamera.lens).near = zNear;
		
			trackerTarget = _camera;
			
			_view = new OculusView(this, _camera);	
			_view.backgroundColor = 0x000000;
			_view.antiAlias = 2;
			_view.addEventListener(Event.ADDED_TO_STAGE, onViewAddedToStage);			
		}

		
		private function onViewAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onViewAddedToStage);
			_view.setSize(_view.stage.stageWidth, _view.stage.stageHeight);			
			_view.addEventListener(Event.ENTER_FRAME, onEnteredFrame);
			_view.stage.addEventListener(Event.RESIZE, onStageSized);
			_view.stage.nativeWindow.addEventListener(Event.CLOSING, onApplicationClosing);
		}
		
		private function onStageSized(e:Event):void 
		{
			_view.setSize(_view.stage.stageWidth, _view.stage.stageHeight);	
		}
		
		public function addEnterFrameHandler(func:Function):void 
		{
			_enterFrameHandlers.push(func);
		}
		
		private function onApplicationClosing(e:Event):void 
		{
			if (_tracker && _tracker.isSupported()) {
				_tracker.dispose();
				_tracker = null;
			}
		}		
		
		private function onEnteredFrame(e:Event):void 
		{
			for each (var func:Function in _enterFrameHandlers) 
			{
				func.call();
			}
			
			
			if (tracker && trackerTarget) {
				_quatVec = tracker.getCameraQuaternion();
				_quat.x = -_quatVec[0];
				_quat.y = -_quatVec[1];
				_quat.z = _quatVec[2];
				_quat.w = _quatVec[3];
				_prevPos = trackerTarget.position;
				trackerTarget.transform = _quat.toMatrix3D();
				trackerTarget.position = _prevPos;
			}	
			
			_view.render();
		}		
		
		public function get camera():OculusCamera 
		{
			return _camera;
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