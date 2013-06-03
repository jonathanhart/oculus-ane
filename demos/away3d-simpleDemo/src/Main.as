package 
{
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.lights.PointLight;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.WireframeSphere;
	import be.but.oculus.OculusSetup;
	import be.but.scenery.Earth;
	import be.but.scenery.SpaceSky;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Fragilem17
	 */
	public class Main extends Sprite 
	{	
		public static var stage:Stage;
		private var _plane:WireframeSphere;		
		private var _setup:OculusSetup;
		private var ship:Spaceship;
		private var _lightPicker:StaticLightPicker;
		private var _light:PointLight;
		
		
		public function Main():void 
		{
			Main.stage = stage;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
			
			_setup = new OculusSetup();
			addChild(_setup);
			
			// 3 earths
			PerspectiveLens(_setup.camera.leftCamera.lens).far = (6371 * 2);
			PerspectiveLens(_setup.camera.rightCamera.lens).far = (6371 * 2);
					
			// 50 cm
			PerspectiveLens(_setup.camera.leftCamera.lens).near = 0.5;
			PerspectiveLens(_setup.camera.rightCamera.lens).near = 0.5;
			
			_light = new PointLight();
			_light.x = 10000;
			_light.ambient = 1;
			_light.diffuse = 2;
			
			_lightPicker = new StaticLightPicker([_light]);
		
			
			var sky:SpaceSky = new SpaceSky();
			_setup.scene.addChild(sky);
			
			var earth:Earth = new Earth(_lightPicker);
			_setup.scene.addChild(earth);
			earth.position = new Vector3D(0, 0, 0);
			
			var earth2:Earth = new Earth(_lightPicker);
			_setup.scene.addChild(earth2);
			earth2.position = new Vector3D(6000, 0, -6000);
			
			ship = new Spaceship();
			ship.addChild(_setup.camera);
			_setup.camera.moveBackward(2);
			_setup.scene.addChild(ship);
			
			ship.moveBackward(6371);
			ship.rotationY = 20;
			
			//_scene.addEnterFrameHandler(onEnterFrame);
		}
		
		private function onEnterFrame():void 
		{
			//ship.moveForward(1);
		}
				
	}
	
}