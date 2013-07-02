package oculusAne.away3d
{
	import away3d.cameras.lenses.LensBase;
	import away3d.containers.Scene3D;
	import away3d.core.base.Object3D;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.math.Quaternion;
	import away3d.events.Stage3DEvent;
	import com.numeda.OculusANE.OculusANE;
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
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
		
		public function OculusScene3D() 
		{			
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
			
			_camera = new OculusCamera(fov, horizontalShiftPercentage);
			_camera.stereoSeperation = 0.054; // m
			_camera.position = _nullVector;
			addChild(_camera);
		
			LensBase(_camera.leftCamera.lens).far = zFar;
			LensBase(_camera.rightCamera.lens).far = zFar;			
	
			LensBase(_camera.leftCamera.lens).near = zNear;
			LensBase(_camera.rightCamera.lens).near = zNear;
		
			trackerTarget = _camera;
			
			_view = new OculusView(this, _camera);		
			_view.backgroundColor = 0x000000;
			_view.antiAlias = 4;
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
			
			if (tracker && tracker.isSupported() && trackerTarget) {
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