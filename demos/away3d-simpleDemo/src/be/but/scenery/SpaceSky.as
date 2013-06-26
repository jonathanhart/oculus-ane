package be.but.scenery 
{
	import away3d.cameras.lenses.FreeMatrixLens;
	import away3d.cameras.lenses.LensBase;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.SkyBoxMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.utils.WireframeMapGenerator;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.SkyBox;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapCubeTexture;
	import away3d.utils.Cast;
	import be.but.oculus.OculusSetup;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author 
	 */
	public class SpaceSky extends Mesh 
	{
		/*
		//skybox textures
		[Embed(source="/../embeds/sky/space_posX.jpg")]
		private var PosX:Class;
		[Embed(source="/../embeds/sky/space_negX.jpg")]
		private var NegX:Class;
		[Embed(source="/../embeds/sky/space_posY.jpg")]
		private var PosY:Class;
		[Embed(source="/../embeds/sky/space_negY.jpg")]
		private var NegY:Class;
		[Embed(source="/../embeds/sky/space_posZ.jpg")]
		private var PosZ:Class;
		[Embed(source="/../embeds/sky/space_negZ.jpg")]
		private var NegZ:Class;
		*/
		
		[Embed(source="/../embeds/sky/starfield.png")]
    	public static var Stars:Class;
		
		private var cubeTexture:BitmapCubeTexture;
		
		public function SpaceSky() 
		{
			//var cube:SphereGeometry = new SphereGeometry(LensBase(OculusSetup.instance.camera.leftCamera.lens).far, 30, 30);
			var cube:CubeGeometry = new CubeGeometry(LensBase(OculusSetup.instance.camera.leftCamera.lens).far, LensBase(OculusSetup.instance.camera.leftCamera.lens).far, LensBase(OculusSetup.instance.camera.leftCamera.lens).far, 1, 1, 1, true);
			//setup the cube texture
						
			//var cubeTexture:BitmapCubeTexture = new BitmapCubeTexture(Cast.bitmapData(PosX), Cast.bitmapData(NegX), Cast.bitmapData(PosY), Cast.bitmapData(NegY), Cast.bitmapData(PosZ), Cast.bitmapData(NegZ));
			
			//var cubeMaterial:SkyBoxMaterial = new SkyBoxMaterial(cubeTexture);
			var cubeMaterial:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(Stars));
			
			super(cube, cubeMaterial);
			scaleX = -1;
			
			OculusSetup.instance.addEnterFrameHandler(onEnterFrame);
		}		
		
		private function onEnterFrame():void 
		{
			position = OculusSetup.instance.camera.scenePosition;			
		}
	}

}