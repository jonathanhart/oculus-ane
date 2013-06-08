package be.but.scenery 
{
	import away3d.animators.data.ParticleProperties;
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticlePositionNode;
	import away3d.animators.nodes.ParticleVelocityNode;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import be.but.oculus.OculusSetup;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author 
	 */
	public class DustParticles extends Mesh
	{
		
		public function DustParticles(lightPicker:StaticLightPicker) 
		{
			//create material, mesh and animator
			var material:ColorMaterial = new ColorMaterial(0xff0000);
			material.lightPicker = lightPicker;
			
			//generate the particle geometry
			//var plane:Geometry = new PlaneGeometry(0.2, 0.2, 1, 1, true, true);
			var plane:Geometry = new CubeGeometry(0.5, 0.5, 0.5);
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			for (var i:int = 0; i < 1000; i++)
			{
				geometrySet.push(plane);
			}
			var particleGeometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet);
	
			
			//create the particle animation set
			var animationSet:ParticleAnimationSet = new ParticleAnimationSet(true, true, true);

			//add behaviors to the animationSet
			animationSet.addAnimation(new ParticlePositionNode(ParticlePropertiesMode.LOCAL_STATIC));
			animationSet.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.GLOBAL, new Vector3D(0, 0.1, 0)));

			//set the initialiser function
			animationSet.initParticleFunc = initParticleParam;
			
			var animator_:ParticleAnimator = new ParticleAnimator(animationSet);
			
			super(particleGeometry, material);
			animator = animator_;

			animator_.start();
		}

		/**
		 * Initialiser function for particle properties. It's invoked for every particle.
		 */
		private function initParticleParam(prop:ParticleProperties):void
		{
			//trace( "DustParticles.initParticleParam > prop : " + prop );
			prop.startTime = prop.index * 0.005;
			prop.duration = 10;
			prop.delay = 5;
			//calculate the original position of every particle.
			var percent:Number = prop.index / prop.total;
			var r:Number = percent * 100;
			var x:Number = r*Math.cos(percent * Math.PI * 2 * 20);
			var y:Number = r*Math.cos(percent * Math.PI * 2 * 20);
			var z:Number = r*Math.sin(percent * Math.PI * 2 * 20);
			prop[ParticlePositionNode.POSITION_VECTOR3D] = new Vector3D(x, y, z);
		}
		
	}

}