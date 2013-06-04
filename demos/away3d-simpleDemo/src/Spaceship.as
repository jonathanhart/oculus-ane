package  
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.math.Quaternion;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.Parsers;
	import away3d.primitives.WireframeCube;
	import be.but.joystick.JoystickHelper;
	import be.but.oculus.OculusSetup;
	import com.numeda.OculusANE.OculusANE;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Fragilem17
	 */
	public class Spaceship extends ObjectContainer3D 
	{
		private var ship:ObjectContainer3D;
		private var _speed:Number = 0;
		
		private var _yawSpeed:Number = 0;
		private var _rollSpeed:Number = 0;
		private var _pitchSpeed:Number = 0;
		
		private var _speedIncrement:Number = 0.1;
		private var _oculusTracker:OculusANE;
		
		public function Spaceship() 
		{
			ship = new WireframeCube(1, 1, 3, 0xffffff, 1);
			ship.position = new Vector3D();
			addChild(ship);
			
			//_oculusTracker = new OculusANE();
			
			OculusSetup.instance.addEnterFrameHandler(onEnterFrame);
			Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Main.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function onEnterFrame():void
		{			
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
			if (_oculusTracker && _oculusTracker.isSupported()) {
				var quatVec:Vector.<Number> = _oculusTracker.getCameraQuaternion();
				var quat:Quaternion = new Quaternion(-quatVec[0], -quatVec[1], quatVec[2], quatVec[3]); 
				OculusSetup.instance.camera.transform = quat.toMatrix3D();
			}

			moveForward(_speed);
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			trace( "e.charCode : " + e.keyCode );
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