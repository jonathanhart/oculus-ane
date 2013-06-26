package be.but.scenery 
{
	import away3d.animators.data.ParticleProperties;
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleBillboardNode;
	import away3d.animators.nodes.ParticleFollowNode;
	import away3d.animators.nodes.ParticlePositionNode;
	import away3d.animators.nodes.ParticleVelocityNode;
	import away3d.animators.nodes.VertexClipNode;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.animators.states.ParticleVelocityState;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.WireframeCube;
	import away3d.primitives.WireframeSphere;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import away3d.utils.Cast;
	import be.but.oculus.OculusSetup;
	import flash.display.BlendMode;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author 
	 */
	public class DustParticlesLocal extends Mesh
	{
		//particle image
		[Embed(source="/../embeds/dust.png")]
		private var ParticleImg:Class;

		private var _radius:Number = 100;
		private var _cube:WireframeCube;
		private var _particleVelocity:Vector3D = new Vector3D();
		
		public function DustParticlesLocal(lightPicker:StaticLightPicker = null) 
		{
			//create material, mesh and animator
			//setup the particle material
			var material:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(ParticleImg));
			material.blendMode = BlendMode.ADD;
			
			if (lightPicker) {
				material.lightPicker = lightPicker;
			}
			
			//generate the particle geometry
			var plane:Geometry = new PlaneGeometry(1, 1, 1, 1, false, false);
			//var plane:Geometry = new CubeGeometry(1, 1, 1);
	
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			for (var i:int = 0; i < 500; i++)
			{
				geometrySet.push(plane);
			}
			var particleGeometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet);
			
			//create the particle animation set
			var animationSet:ParticleAnimationSet = new ParticleAnimationSet(true, true, true);
			
			//add behaviors to the animationSet
			animationSet.addAnimation(new ParticleBillboardNode());
			animationSet.addAnimation(new ParticlePositionNode(ParticlePropertiesMode.LOCAL_STATIC));
			animationSet.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.GLOBAL, _particleVelocity));
			
			//set the initialiser function
			animationSet.initParticleFunc = initParticleParam;
			
			var animator_:ParticleAnimator = new ParticleAnimator(animationSet);
			animator_.playbackSpeed = 1000 / Main.stage.frameRate;
			
			
			super(particleGeometry, material);
			
			//_cube = new WireframeCube(_radius * 2, _radius * 2, _radius * 2);
			//addChild(_cube);
			
			animator = animator_;
			animator_.start();
			
			bounds.fromExtremes(-50000, -50000, -50000, 50000, 50000, 50000);
		}

		/**
		 * Initialiser function for particle properties. It's invoked for every particle.
		 */
		private function initParticleParam(prop:ParticleProperties):void
		{
			//trace( "DustParticles.initParticleParam > prop : " + prop );
			prop.duration = prop.total;
			prop.startTime = prop.index * (prop.duration / prop.total);
			prop.delay = 0;
			trace( "prop.duration : " + prop.duration );
			trace( "prop.startTime : " + prop.startTime );
		
			var x:Number = getRandomPosWithinRadius();
			var y:Number = getRandomPosWithinRadius();
			var z:Number = getRandomPosWithinRadius();
			//trace( "z : " + z );
			var pos:Vector3D = new Vector3D(x, y, z);
			prop[ParticlePositionNode.POSITION_VECTOR3D] = pos;
			//prop[ParticleVelocityNode.VELOCITY_VECTOR3D] = _particleVelocity;
		}
		
		private function getRandomPosWithinRadius():Number
		{
			return _radius - ((Math.random() * _radius) * 2);
		}
		
		public function get particleVelocity():Vector3D 
		{
			return _particleVelocity;
		}
	}

}