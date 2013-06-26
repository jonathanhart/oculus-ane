package be.but.scenery 
{
	import away3d.animators.data.ParticleProperties;
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleBillboardNode;
	import away3d.animators.nodes.ParticleFollowNode;
	import away3d.animators.nodes.ParticlePositionNode;
	import away3d.animators.nodes.ParticleRotationalVelocityNode;
	import away3d.animators.nodes.ParticleVelocityNode;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.animators.states.ParticleVelocityState;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.HeightMapNormalMethod;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import away3d.tools.utils.Bounds;
	import away3d.utils.Cast;
	import be.but.oculus.OculusSetup;
	import flash.display.BlendMode;
	import flash.display3D.textures.Texture;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author 
	 */
	public class AsteroidParticles extends Mesh
	{
		//particle image
		[Embed(source="/../embeds/asteroid2.jpg")]
		private var AsteroidImg:Class;
		
		[Embed(source="/../embeds/asteroid_normal.jpg")]
		private var AsteroidNormalImg:Class;
		
		private var _radius:Number = 2000;
		private var _particleFollowNode:ParticleFollowNode;
		
		public function AsteroidParticles(lightPicker:StaticLightPicker, particles:int = 10) 
		{
			//setup the particle material
			var material:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(AsteroidImg));
			material.specularMap = Cast.bitmapTexture(AsteroidImg);
			//material.normalMap = Cast.bitmapTexture(AsteroidImg);
			material.lightPicker = lightPicker;
			
			
			//generate the particle geometry
			var plane:Geometry = new SphereGeometry(200);
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			for (var i:int = 0; i < particles; i++)
			{
				geometrySet.push(plane);
			}
			var particleGeometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet);
	
			
			//create the particle animation set
			var animationSet:ParticleAnimationSet = new ParticleAnimationSet();

			//add behaviors to the animationSet
			animationSet.addAnimation(new ParticlePositionNode(ParticlePropertiesMode.LOCAL_STATIC));
			animationSet.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.LOCAL_STATIC));
			animationSet.addAnimation(new ParticleRotationalVelocityNode(ParticlePropertiesMode.LOCAL_STATIC));
			
			//set the initialiser function
			animationSet.initParticleFunc = initParticleParam;
			
			var animator_:ParticleAnimator = new ParticleAnimator(animationSet);
			
			super(particleGeometry, material);
			
			animator = animator_;
			animator_.start();
			bounds.fromSphere(new Vector3D(), 20000);
		}

		/**
		 * Initialiser function for particle properties. It's invoked for every particle.
		 */
		private function initParticleParam(prop:ParticleProperties):void
		{			
			var x:Number = getRandomPosWithinRadius();
			var y:Number = getRandomPosWithinRadius();
			var z:Number = getRandomPosWithinRadius();
			//trace( "z : " + z );
			var pos:Vector3D = new Vector3D(x, y, z);
			var velocityPos:Vector3D = new Vector3D(Math.random()*20, Math.random()*20, Math.random()*20, Math.random()*20);
			var velocityRot:Vector3D = new Vector3D(Math.random()*20, Math.random()*20, Math.random()*20, Math.random()*20);
			
			prop[ParticlePositionNode.POSITION_VECTOR3D] = pos;
			prop[ParticleVelocityNode.VELOCITY_VECTOR3D] = velocityPos;
			prop[ParticleRotationalVelocityNode.ROTATIONALVELOCITY_VECTOR3D] = velocityRot;
		}
		
		private function getRandomPosWithinRadius():Number
		{
			return _radius - ((Math.random() * _radius) * 2);
		}
	}

}