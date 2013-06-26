package be.but.scenery 
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Sprite3D;
	import away3d.materials.ColorMaterial;
	import be.but.oculus.OculusSetup;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author fragilem17
	 */
	public class DustCloud extends ObjectContainer3D 
	{
		
		private var _dustParticles:Vector.<Sprite3D>;
		private var _numParticles:int = 100;
		private var _radius:Number = 100;
		private var _ship:Spaceship;
		
		public function DustCloud(ship:Spaceship) 
		{
			_ship = ship;
			_dustParticles = new Vector.<Sprite3D>;
		
			var sprite:Sprite3D;
			for (var i:int = 0; i < _numParticles; i++) 
			{
				sprite = new Sprite3D(new ColorMaterial(0xff0000), 1, 1);
				sprite.position = new Vector3D(getRandomPos(), getRandomPos(), getRandomPos());
				addChild(sprite);
				_dustParticles.push(sprite);
			}
			
			OculusSetup.instance.addEnterFrameHandler(onEnterFrame);
		}
		
		private function onEnterFrame():void 
		{
			for each (var sprite:Sprite3D in _dustParticles) 
			{
				//sprite.position = new Vector3D(getRandomPos(), getRandomPos(), getRandomPos());
			}
		}
		
		
		private function getRandomPos():Number
		{
			return _ship.position + (_radius - ((Math.random() * _radius) * 2));
		}
		
	}

}