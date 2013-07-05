package 
{	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.net.URLRequest;
	
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.AWDParser;
	
	import oculusAne.away3d.OculusScene3D;
	
	import uk.co.soulwire.gui.SimpleGUI;
	
	/**
	 * Simple demo showcasing the away3d oculus integration
	 * @author Fragilem17
	 */
	[SWF(backgroundColor="#000000", frameRate="120", quality="LOW", width="1280", height="800")]
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
			
			_oculusScene3d.camera.moveUp(10);
			_oculusScene3d.camera.moveForward(24);
			_oculusScene3d.camera.moveRight(5);
			_oculusScene3d.camera.yaw(180);
			
			
			//   By default the tracker's target is the oculusScene3D's camera
			//   You can change the tracker's target this way
			// _oculusScene3d.trackerTarget = virtualHeadOrSomething;
			
			//   You can attach the camera to another mesh this way
			// virtualHeadOrSomething.addChild(_oculusScene3d.camera);
			
			//addChild(new AwayStats(_oculusScene3d.view.leftView));
		}
		
		private function onAssetComplete(event:AssetEvent):void 
		{
			if (event.asset.assetType == AssetType.MESH) {
				var mesh:Mesh = event.asset as Mesh;
				mesh.castsShadows = false;
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
				
				baseClassPath = "oculusScene3d.view.oculusBarrelDistortionFilterLeft.";
				_gui.addSlider(baseClassPath + "lensCenterX", 0, 1, {label:'lensCenterX'});
				_gui.addSlider(baseClassPath + "lensCenterY", 0, 1, {label:'lensCenterY'});
	 
				_gui.addSlider(baseClassPath + "scaleInX", 1, 3, {label:'scaleInX'});
				_gui.addSlider(baseClassPath + "scaleX", 0.3, 0.5, {label:'scaleX'});
				_gui.addSlider(baseClassPath + "hmdWarpParamX", 0, 1, {label:'hmdWarpParamX'});
				_gui.addSlider(baseClassPath + "hmdWarpParamY", 0, 1, {label:'hmdWarpParamY'});
				_gui.addSlider(baseClassPath + "hmdWarpParamZ", 0, 1, {label:'hmdWarpParamZ'});
				_gui.addSlider(baseClassPath + "hmdWarpParamW", 0, 1, {label:'hmdWarpParamW'});
				
				_gui.addColumn("Right");
				
				baseClassPath = "oculusScene3d.view.oculusBarrelDistortionFilterRight.";
				_gui.addSlider(baseClassPath + "lensCenterX", 0, 1, {label:'lensCenterX'});
				_gui.addSlider(baseClassPath + "lensCenterY", 0, 1, {label:'lensCenterY'});
		
				_gui.addSlider(baseClassPath + "scaleInX", 1, 3, {label:'scaleInX'});
				_gui.addSlider(baseClassPath + "scaleX", 0.3, 0.5, {label:'scaleX'});
				_gui.addSlider(baseClassPath + "hmdWarpParamX", 0, 1, {label:'hmdWarpParamX'});
				_gui.addSlider(baseClassPath + "hmdWarpParamY", 0, 1, {label:'hmdWarpParamY'});
				_gui.addSlider(baseClassPath + "hmdWarpParamZ", 0, 1, {label:'hmdWarpParamZ'});
				_gui.addSlider(baseClassPath + "hmdWarpParamW", 0, 1, {label:'hmdWarpParamW'});
				
				_gui.show();				
			}
		}
		
		

		public function get oculusScene3d():OculusScene3D
		{
			return _oculusScene3d;
		}

	}
	
}