package  
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.Parsers;
	import away3d.primitives.WireframeCube;
	import be.but.oculus.OculusSetup;
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
		private var _speedIncrement:Number = 0.5;
		
		public function Spaceship() 
		{
			ship = new WireframeCube(1, 1, 3, 0xffffff, 1);
			ship.position = new Vector3D();
			addChild(ship);
			
			OculusSetup.instance.addEnterFrameHandler(onEnterFrame);
			Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onEnterFrame():void 
		{
			moveForward(_speed);
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			trace( "e.charCode : " + e.keyCode );
			if (e.keyCode == 37) {
				// left
				rotationY -= 0.5;
			}			
			if (e.keyCode == 38) {
				// forward
				_speed += _speedIncrement;
				
			}
			if (e.keyCode == 39) {
				// right
				rotationY += 0.5;
				
			}
			if (e.keyCode == 40) {
				// backward
				_speed -= _speedIncrement;
			}
		}		
	}
}