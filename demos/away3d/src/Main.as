package 
{	
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.AWDParser;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.net.URLRequest;
	import oculusAne.away3d.OculusScene3D;
	
	/**
	 * Simple demo showcasing the away3d oculus integration
	 * @author Fragilem17
	 */
	[SWF(backgroundColor="#000000", frameRate="120", quality="LOW", width="1280", height="800")]
	public class Main extends Sprite
	{	
		private var _oculusScene3d:OculusScene3D;	
		
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
			
			addChild(new AwayStats(_oculusScene3d.view.leftView));
		}
		
		private function onAssetComplete(event:AssetEvent):void 
		{
			if (event.asset.assetType == AssetType.MESH) {
				var mesh:Mesh = event.asset as Mesh;
				mesh.castsShadows = false;
				_oculusScene3d.addChild(mesh);
			}			
		}
		
		private function onResourceComplete(e:LoaderEvent):void 
		{
			trace( "Main.onResourceComplete > e : " + e );
		}
	}
	
}