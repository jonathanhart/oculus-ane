package 
{	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import away3d.audio.Sound3D;
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.AWDParser;
	
	import oculusANE.away3d.OculusScene3D;
	
	import uk.co.soulwire.gui.SimpleGUI;
	
	/**
	 * Simple demo showcasing the away3d oculus integration
	 * @author Fragilem17
	 */
	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW", width="1280", height="800")]
	public class Main extends Sprite
	{	
		private var _oculusScene3d:OculusScene3D;	

		private var _gui:SimpleGUI;
		
		private var _forward:Boolean = false;
		private var _backward:Boolean = false;

		private var _container:ObjectContainer3D;
 
		public var overlay1:Loader;
		public var overlay2:Loader;
		
		[Embed(source="nature_distant_river_birds.mp3")]
		private static var NatureSound:Class;
		public static var natureSound:Sound = (Sound)(new NatureSound());		

		private var _natureSound3d:Sound3D;
		
		public function Main():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.BEST;
			
			_oculusScene3d = new OculusScene3D();
			addChild(_oculusScene3d.view);
			
			//setup parser
			AssetLibrary.enableParser(AWDParser);
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			AssetLibrary.load(new URLRequest("level_heavy.awd"));

			
			_oculusScene3d.camera.moveUp(1.8);
			_oculusScene3d.camera.moveForward(5);
			_oculusScene3d.camera.moveLeft(2);			
			
			_natureSound3d = new Sound3D(natureSound, _oculusScene3d.camera, null, 1, 10);
			_natureSound3d.addEventListener(Event.SOUND_COMPLETE, onBGSoundComplete);
				
			//   By default the tracker's target is the oculusScene3D's camera
			//   You can change the tracker's target this way
			//_oculusScene3d.trackerTarget = null;
			
			//   You can attach the camera to another mesh this way
			// virtualHeadOrSomething.addChild(_oculusScene3d.camera);
			
			//addChild(new AwayStats(_oculusScene3d.view.leftView));
			
			_oculusScene3d.addEnterFrameHandler(onEnterFrame);
			
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			setTimeout(initGui, 2000);
		}
		
		protected function onBGSoundComplete(event:Event):void
		{
			_natureSound3d.play();
		}
		
		private function onEnterFrame():void
		{
			// avg walkingSpeed  = 5 Km/h
			var walkingSpeed:Number = 5000 / 60 / 60 / 60; // minute, second, frames
			//walkingSpeed *= 100;

			if(_forward){
				_oculusScene3d.camera.moveForward(walkingSpeed);
			}
			
			if(_backward){
				_oculusScene3d.camera.moveBackward(walkingSpeed);
			}
			
		}
		
		private function onAssetComplete(event:AssetEvent):void 
		{
			//trace("event.asset.assetType: " + event.asset.assetType);
			
			if(event.asset.assetType == AssetType.CAMERA){
				var cam:Camera3D = event.asset as Camera3D;
				_oculusScene3d.camera.transform = cam.transform;
			}
			
			if (event.asset.assetType == AssetType.MESH) {
				var mesh:Mesh = event.asset as Mesh;
				_oculusScene3d.addChild(mesh);	
				
				if(event.asset.name == "log_small_001_nophys_0"){
					trace('adding nature sound to a log');			
					mesh.addChild(_natureSound3d);
					_natureSound3d.play();
				}	
			}
		}
		
		private function onResourceComplete(e:LoaderEvent):void 
		{
			trace( "Main.onResourceComplete > e : " + e );
		}
		
		private function initGui():void 
		{
			if(!_gui){

				/*
				var house:ObjectContainer3D = new ObjectContainer3D();
				house.rotationY = 270;
				house.z = 7;
				house.x = -0.5;
				
				var floor:WireframePlane = new WireframePlane(5,14,5,14);
				floor.rotationZ = 90;
				house.addChild(floor);
				
				
				var ceiling:WireframePlane = new WireframePlane(5,14,5,14, 0xff00ff);
				ceiling.rotationZ = 90;
				ceiling.y = 2.5;
				house.addChild(ceiling);						
				
				var wall:WireframePlane = new WireframePlane(14,2.5,14,3, 0xff0000);
				wall.rotationY = 90;
				wall.y = 2.5/2;
				wall.z = 2.5;
				house.addChild(wall);		
				
				
				var wall2:WireframePlane = new WireframePlane(5,2.5,5,3, 0x00ff00);
				wall2.rotationY = 0;
				wall2.y = 2.5/2;
				wall2.x = 14/2;
				house.addChild(wall2);		
				
				_oculusScene3d.addChild(_container);
				*/
				
				
				overlay1 = new Loader();
				overlay1.load(new URLRequest('overlay1.png'));
				overlay1.alpha = 0.6;
				overlay1.visible = false;
				addChild(overlay1);	
				
				
				overlay2 = new Loader();
				overlay2.load(new URLRequest('overlay2.png'));
				overlay2.alpha = 0.6;
				overlay2.visible = false;
				addChild(overlay2);				

				_gui = new SimpleGUI(this, "Settings", "C");
				
				_gui.addColumn("Barrel Distortion");
				
				var baseClassPath:String;
				
				baseClassPath = "oculusScene3d.view.";
				_gui.addButton("preset 1", {callback:preset1, width:160});
				_gui.addButton("preset 2", {callback:preset2, width:160});
				_gui.addSlider("oculusScene3d.camera.stereoSeperation", 0, 2, {label:'st sep'});
				_gui.addSlider(baseClassPath + "barrelDistortionLensCenterOffsetX", 0, 0.1, {label:'bd lc X'});
				_gui.addSlider(baseClassPath + "lensCenterOffsetX", 0, 0.1, {label:'lc X'});
				_gui.addSlider(baseClassPath + "lensCenterOffsetY", 0, 0.1, {label:'lc Y'});
	 			
				_gui.addToggle("overlay1.visible", {label:'overlay 1 visible'});
				_gui.addToggle("overlay2.visible", {label:'overlay 2 visible'});
				_gui.addSlider(baseClassPath + "scaleIn", 2, 4, {label:'s in '});
				_gui.addSlider(baseClassPath + "scale", 0, 1, {label:'s out'});
				//_gui.addSlider(baseClassPath + "hmdWarpParamX", 0, 1, {label:'hmdWarpParamX'});
				//_gui.addSlider(baseClassPath + "hmdWarpParamY", 0, 1, {label:'hmdWarpParamY'});
				//_gui.addSlider(baseClassPath + "hmdWarpParamZ", 0, 1, {label:'hmdWarpParamZ'});
				//_gui.addSlider(baseClassPath + "hmdWarpParamW", 0, 1, {label:'hmdWarpParamW'});
				
				_gui.addSlider("oculusScene3d.camera.fieldOfView", 90, 150, {label:'fov'});
				
				//_gui.show();
			}
		}
		
		public function preset1():void {
			oculusScene3d.camera.stereoSeperation = 0.06400000303983688;
			oculusScene3d.view.lensCenterOffsetX = 0.07598821439086476;
			oculusScene3d.view.barrelDistortionLensCenterOffsetX = oculusScene3d.view.lensCenterOffsetX / 2;
			oculusScene3d.view.lensCenterOffsetY = 0;
			oculusScene3d.view.scaleIn = 3.12;
			oculusScene3d.view.scale = 0.25;
			oculusScene3d.camera.fieldOfView = 111;
		}
		
		public function preset2():void {
			oculusScene3d.camera.stereoSeperation = 0.06400000303983688;
			oculusScene3d.view.lensCenterOffsetX = 0.045;
			oculusScene3d.view.barrelDistortionLensCenterOffsetX = oculusScene3d.view.lensCenterOffsetX / 2;
			oculusScene3d.view.lensCenterOffsetY = 0;
			oculusScene3d.view.scaleIn = 3.19;
			oculusScene3d.view.scale = 0.31;
			oculusScene3d.camera.fieldOfView = 97.5588441205328;
		}
		
		protected function onKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.F){
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
		
			_forward = (event.keyCode == Keyboard.UP);
			_backward = (event.keyCode == Keyboard.DOWN);
		}	
		
		protected function onKeyUp(event:KeyboardEvent):void
		{
			_forward = false;
			_backward = false;
		}
		

		public function get oculusScene3d():OculusScene3D
		{
			return _oculusScene3d;
		}

	}
	
}