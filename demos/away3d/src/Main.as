package 
{	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display3D.textures.Texture;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.AWDParser;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.WireframeCube;
	
	import oculusAne.away3d.OculusLens;
	import oculusAne.away3d.OculusScene3D;
	
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
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
			
			_oculusScene3d = new OculusScene3D();
			addChild(_oculusScene3d.view);
			
			//setup parser
			AssetLibrary.enableParser(AWDParser);
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			AssetLibrary.load(new URLRequest("level_light.awd"));
			
			_oculusScene3d.camera.moveUp(20);
			_oculusScene3d.camera.moveBackward(10);
			_oculusScene3d.camera.moveRight(20);
			//_oculusScene3d.camera.yaw(180);
			//_oculusScene3d.camera.position = new Vector3D(0,0,0,0);
			
			
			//var cub:WireframeCube = new WireframeCube(400,400,400);
			//_oculusScene3d.addChild(cub);
			
			//   By default the tracker's target is the oculusScene3D's camera
			//   You can change the tracker's target this way
			//_oculusScene3d.trackerTarget = null;
			
			//   You can attach the camera to another mesh this way
			// virtualHeadOrSomething.addChild(_oculusScene3d.camera);
			
			addChild(new AwayStats(_oculusScene3d.view.leftView));
			
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function onAssetComplete(event:AssetEvent):void 
		{
			if (event.asset.assetType == AssetType.MESH) {
				var mesh:Mesh = event.asset as Mesh;
				//mesh.castsShadows = false;
				
				/*var material:TextureMaterial = mesh.material as TextureMaterial;
				if(material){
					trace("mesh has mat");
					//material.lightPicker = null;
				}*/
				
				_oculusScene3d.addChild(mesh);

				// starting gui after the first asset is added, the stage context is ready by then
				initGui();
			}
		}
		
		private function onResourceComplete(e:LoaderEvent):void 
		{
			trace( "Main.onResourceComplete > e : " + e );
		}
		
		private function initGui():void 
		{
			if(!_gui){
				_gui = new SimpleGUI(this, "Barrel Distortion", "C");
				
				_gui.addColumn("Left");
				
				var baseClassPath:String;
				
				baseClassPath = "oculusScene3d.view.";
				_gui.addSlider(baseClassPath + "lensCenterX", 0, 1, {label:'lensCenterX'});
				_gui.addSlider(baseClassPath + "lensCenterY", 0, 1, {label:'lensCenterY'});
	 
				_gui.addSlider(baseClassPath + "scaleIn", 0, 4, {label:'scaleInX'});
				_gui.addSlider(baseClassPath + "scale", 0, 1, {label:'scaleX'});
				_gui.addSlider(baseClassPath + "hmdWarpParamX", 0, 1, {label:'hmdWarpParamX'});
				_gui.addSlider(baseClassPath + "hmdWarpParamY", 0, 1, {label:'hmdWarpParamY'});
				_gui.addSlider(baseClassPath + "hmdWarpParamZ", 0, 1, {label:'hmdWarpParamZ'});
				_gui.addSlider(baseClassPath + "hmdWarpParamW", 0, 1, {label:'hmdWarpParamW'});
				
				_gui.addSlider("oculusScene3d.camera.fieldOfView", 90, 150, {label:'fieldOfView'});
				
				_gui.show();
				
				
				//var loader:Loader = new Loader();
				//loader.load(new URLRequest('overlay.png'));
				//addChild(loader);
			}
		}
		
		protected function onKeyUp(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.F){
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
		}		
		

		public function get oculusScene3d():OculusScene3D
		{
			return _oculusScene3d;
		}

	}
	
}