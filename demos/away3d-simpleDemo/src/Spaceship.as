package  
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.math.Quaternion;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.WireframeCube;
	import away3d.primitives.WireframePlane;
	import away3d.primitives.WireframeSphere;
	import be.but.joystick.JoystickHelper;
	import be.but.oculus.OculusSetup;
	import be.but.scenery.DustParticles;
	import com.numeda.OculusANE.OculusANE;
	import flash.display.StageDisplayState;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Fragilem17
	 */
	public class Spaceship extends ObjectContainer3D 
	{
		private var cockpit:ObjectContainer3D;
		private var head:WireframeCube;
		
		private var _speed:Number = 0;
		
		private var _yawSpeed:Number = 0;
		private var _rollSpeed:Number = 0;
		private var _pitchSpeed:Number = 0;
		
		private var _speedIncrement:Number = 0.1;
		private var _dust:DustParticles;
		private var _dustEmitter:ObjectContainer3D;
		
		public function Spaceship(lightPicker:StaticLightPicker) 
		{
			cockpit = new WireframeCube(1, 1.5, 3, 0xffffff, 1);
			//cockpit.position = new Vector3D();
			//cockpit.moveForward(2);
			addChild(cockpit);
			
			
			head = new WireframeCube(0.14, 0.20, 0.18);
			addChild(head);
			
			head.addChild(OculusSetup.instance.camera);
			OculusSetup.instance.camera.moveForward(head.depth/2);
			OculusSetup.instance.camera.moveUp(head.height/2);
			
			
			//_dustEmitter = new WireframeSphere(10, 10, 10, 0x999999, 0.1);
			_dustEmitter = new ObjectContainer3D();
			OculusSetup.instance.scene.addChild(_dustEmitter);
			

			_dust = new DustParticles(lightPicker);
			OculusSetup.instance.scene.addChild(_dust);
			_dust.follow(_dustEmitter);			
			
			OculusSetup.instance.addEnterFrameHandler(onEnterFrame);
			Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Main.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			Main.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{
			if (Main.stage.mouseLock) {				
				//trace( "e.localX : " + e.movementX );
				OculusSetup.instance.camera.yaw(e.movementX);
				OculusSetup.instance.camera.pitch(e.movementY);
				//OculusSetup.instance.camera.roll(0);
				OculusSetup.instance.camera.rotationZ = 0;
			}
		}
		
		private function onEnterFrame():void
		{			
			_dustEmitter.transform = transform;
			_dustEmitter.moveForward(_speed * 100);
			
			if (JoystickHelper.available) {
				//trace(JoystickHelper.axisValues[0]);
				_speed = -JoystickHelper.axisValues[2];
				yaw(JoystickHelper.axisValues[0]);
				pitch(JoystickHelper.axisValues[1]);
				roll(-JoystickHelper.axisValues[3]);
			}
			
			yaw(_yawSpeed);
			pitch(_pitchSpeed);
			roll(_rollSpeed);
			
			
			// the camera is attached to this ship
			// thus moving along the path and rotation of the ship
			// the oculus should rotate the camera in its own space, thus looking arround inside the ship
			if (OculusSetup.instance.tracker) {
				if (OculusSetup.instance.tracker.isSupported()) {
					var quatVec:Vector.<Number> = OculusSetup.instance.tracker.getCameraQuaternion();
					var quat:Quaternion = new Quaternion(-quatVec[0], -quatVec[1], quatVec[2], quatVec[3]); 
					head.transform = quat.toMatrix3D();					
				}
			}
			
			moveForward(_speed);
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			//trace( "e.charCode : " + e.keyCode );
			if (e.keyCode == 39) {
				// right
				_yawSpeed = 0.5;
			}
			
			if (e.keyCode == 37) {
				// left
				_yawSpeed = -0.5;
			}
			
			if (e.keyCode == 38) {
				// up
				_pitchSpeed = 0.5;
			}
			
			if (e.keyCode == 40) {
				// down
				_pitchSpeed = -0.5;
			}
			
			if (e.keyCode == 189) {
				// +
				_speed += _speedIncrement;
			}

			if (e.keyCode == 219) {
				// -
				_speed -= _speedIncrement;
			}
			
			if (e.keyCode == 70) {
				// f
				Main.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				Main.stage.mouseLock = true;
			}
		}	
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
			if (e.keyCode == 39) {
				// right
				_yawSpeed = 0;
			}
			
			if (e.keyCode == 37) {
				// left
				_yawSpeed = 0;
			}
			
			if (e.keyCode == 38) {
				// up
				_pitchSpeed = 0;
			}
			
			if (e.keyCode == 40) {
				// down
				_pitchSpeed = 0;
			}
		}
	}
}