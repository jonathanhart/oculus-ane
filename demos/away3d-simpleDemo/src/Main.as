package 
{
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.filters.BloomFilter3D;
	import away3d.filters.DepthOfFieldFilter3D;
	import away3d.filters.Filter3DBase;
	import away3d.lights.PointLight;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.WireframeSphere;
	import be.but.joystick.JoystickHelper;
	import be.but.oculus.OculusSetup;
	import be.but.scenery.AsteroidParticles;
	import be.but.scenery.DustParticles;
	import be.but.scenery.Earth;
	import be.but.scenery.SpaceSky;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.ui.GameInput;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Fragilem17
	 */
	public class Main extends Sprite 
	{	
		public static var stage:Stage;
		private var _plane:WireframeSphere;		
		private var _setup:OculusSetup;
		private var _ship:Spaceship;
		private var _lightPicker:StaticLightPicker;
		private var _light:PointLight;
		private var _depthOfFieldFilter:Filter3DBase;
		private var earth:Earth;
		private var earth2:Earth;
		private var asteroids:AsteroidParticles;
		
		
		public function Main():void 
		{
			Main.stage = stage;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
			
			_setup = new OculusSetup();
			//_setup.view.crossEye = true;
			addChild(_setup);
			
			_light = new PointLight();
			_light.x = 10000;
			_light.ambient = 1;
			_light.diffuse = 2;
			
			_lightPicker = new StaticLightPicker([_light]);
		
			
			var sky:SpaceSky = new SpaceSky();
			sky.position = new Vector3D(0, 0, 0);
			_setup.scene.addChild(sky);
			
			earth = new Earth(_lightPicker);
			_setup.scene.addChild(earth);
			earth.position = new Vector3D(0, 0, 0);
			
			earth2 = new Earth(_lightPicker);
			_setup.scene.addChild(earth2);
			earth2.position = new Vector3D(6000, 0, -6000);
			
			
			_ship = new Spaceship(_lightPicker);
			_setup.scene.addChild(_ship);
			_ship.moveBackward(5000);
			
			asteroids = new AsteroidParticles(_lightPicker);
			asteroids.moveBackward(6400);
			_setup.scene.addChild(asteroids);
			
			//JoystickHelper.sharedInstance().addEventListener(JoystickHelper.EVT_BUTTON_DOWN, onButtonDown);
			//_setup.addEnterFrameHandler(onEnterFrame);
		}
		
		private function onEnterFrame():void 
		{
			//_depthOfFieldFilter.focusTarget=asteroids;
		}
		
		private function onButtonDown(e:Event):void 
		{
			//JoystickHelper.buttonIsDownStates[0]
			trace( "JoystickHelper.buttonIsDownStates[0] : " + JoystickHelper.buttonIsDownStates[0] );
		}				
	}
	
}