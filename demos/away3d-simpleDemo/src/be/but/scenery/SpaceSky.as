package be.but.scenery 
{
	import away3d.primitives.SkyBox;
	import away3d.textures.BitmapCubeTexture;
	import away3d.utils.Cast;
	import be.but.oculus.OculusSetup;
	
	/**
	 * ...
	 * @author 
	 */
	public class SpaceSky extends SkyBox 
	{
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
		
		private var cubeTexture:BitmapCubeTexture;
		
		public function SpaceSky() 
		{
			//setup the cube texture
			var cubeTexture:BitmapCubeTexture = new BitmapCubeTexture(Cast.bitmapData(PosX), Cast.bitmapData(NegX), Cast.bitmapData(PosY), Cast.bitmapData(NegY), Cast.bitmapData(PosZ), Cast.bitmapData(NegZ));
			super(cubeTexture);
			
			// generate clouds maybe?
			OculusSetup.instance.addEnterFrameHandler(onEnterFrame);
		}
		
		private function onEnterFrame():void 
		{
			
		}
		
	}

}