/*

Based on the Globe example in Away3d

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

This code is distributed under the MIT License

Copyright (c) The Away Foundation http://www.theawayfoundation.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

package be.but.scenery 
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterData;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.BasicDiffuseMethod;
	import away3d.materials.methods.BasicSpecularMethod;
	import away3d.materials.methods.CompositeDiffuseMethod;
	import away3d.materials.methods.CompositeSpecularMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.MethodVO;
	import away3d.materials.methods.PhongSpecularMethod;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	import be.but.oculus.OculusSetup;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.geom.ColorTransform;
	import flash.geom.Point;

	
	public class Earth extends ObjectContainer3D
	{
		//night map for globe
		[Embed(source="/../embeds/globe/land_lights_16384.jpg")]
    	public static var EarthNight:Class;
		
		//diffuse map for globe
		[Embed(source="/../embeds/globe/land_ocean_ice_2048_match.jpg")]
		public static var EarthDiffuse:Class;
		
		//normal map for globe
		[Embed(source="/../embeds/globe/EarthNormal.png")]
		public static var EarthNormals:Class;
		
		//specular map for globe
		[Embed(source="/../embeds/globe/earth_specular_2048.jpg")]
		public static var EarthSpecular:Class;
		
		//diffuse map for globe
		[Embed(source="/../embeds/globe/cloud_combined_2048.jpg")]
		public static var SkyDiffuse:Class;

		//material objects
		private static var groundMaterial:TextureMaterial;
		private static var cloudMaterial:TextureMaterial;
		private static var atmosphereMaterial:ColorMaterial;
		private static var atmosphereDiffuseMethod:*;
		private static var atmosphereSpecularMethod:*;
		
		private var ground:Mesh;
		private var clouds:Mesh;
		private var atmosphere:Mesh;
		private var lightPicker:StaticLightPicker;
		
		public function Earth(lightPicker:StaticLightPicker) 
		{
			this.lightPicker = lightPicker;
			if (!groundMaterial) {
				initMaterials();				
			}
			initObjects();
			
			OculusSetup.instance.addEnterFrameHandler(onEnterFrame);
		}
		
		private function onEnterFrame():void 
		{
			rotationX -= 0.003
			clouds.rotationY += 0.006;
			clouds.rotationX += 0.002;
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			//adjust specular map
			var specBitmap:BitmapData = Cast.bitmapData(EarthSpecular); 
			specBitmap.colorTransform(specBitmap.rect, new ColorTransform(1, 1, 1, 1, 64, 64, 64));
			
			var specular:FresnelSpecularMethod = new FresnelSpecularMethod(true, new PhongSpecularMethod());
			specular.fresnelPower = 1;
			specular.normalReflectance = 0.1;

			groundMaterial = new TextureMaterial(Cast.bitmapTexture(EarthDiffuse));
			groundMaterial.specularMethod = specular;
			groundMaterial.specularMap = new BitmapTexture(specBitmap);
			groundMaterial.normalMap = Cast.bitmapTexture(EarthNormals);
			groundMaterial.ambientTexture = Cast.bitmapTexture(EarthNight);
			groundMaterial.lightPicker = lightPicker;
			groundMaterial.gloss = 5;
			groundMaterial.specular = 1;
			groundMaterial.ambientColor = 0xFFFFFF;
			groundMaterial.ambient = 1;
			
			var skyBitmap:BitmapData = new BitmapData(2048, 1024, true, 0xFFFFFFFF);
			skyBitmap.copyChannel(Cast.bitmapData(SkyDiffuse), skyBitmap.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			
			cloudMaterial = new TextureMaterial(new BitmapTexture(skyBitmap));
			cloudMaterial.alphaBlending = true;
			cloudMaterial.lightPicker = lightPicker;
			cloudMaterial.specular = 0;
			cloudMaterial.ambientColor = 0x1b2048;
			cloudMaterial.ambient = 1;
			
			//atmosphereDiffuseMethod =  new CompositeDiffuseMethod(modulateDiffuseMethod);
			//atmosphereSpecularMethod =  new CompositeSpecularMethod(modulateSpecularMethod, new PhongSpecularMethod());
			
			atmosphereMaterial = new ColorMaterial(0x1671cc);
			//atmosphereMaterial.diffuseMethod = atmosphereDiffuseMethod;
			//atmosphereMaterial.specularMethod = atmosphereSpecularMethod;
			atmosphereMaterial.blendMode = flash.display.BlendMode.ADD;
			atmosphereMaterial.lightPicker = lightPicker;
			atmosphereMaterial.specular = 0.5;
			atmosphereMaterial.gloss = 5;
			atmosphereMaterial.ambientColor = 0x0;
			atmosphereMaterial.ambient = 1;
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			var earthDiameter:Number = 6371/2;
			ground = new Mesh(new SphereGeometry(earthDiameter, 60, 60), groundMaterial);			
			clouds = new Mesh(new SphereGeometry(earthDiameter+(earthDiameter/90), 60, 60), cloudMaterial);
			atmosphere = new Mesh(new SphereGeometry(earthDiameter+(earthDiameter/20), 60, 60), atmosphereMaterial);
			atmosphere.scaleX = -1;
			
			addChild(ground);
			addChild(clouds);
			addChild(atmosphere);
		}
		

		private function modulateDiffuseMethod(vo : MethodVO, t:ShaderRegisterElement, regCache:ShaderRegisterCache, sharedRegisters:ShaderRegisterData):String
		{
			vo=vo;
			regCache=regCache;
			sharedRegisters=sharedRegisters; 
			var viewDirFragmentReg:ShaderRegisterElement = atmosphereDiffuseMethod.sharedRegisters.viewDirFragment;
			var normalFragmentReg:ShaderRegisterElement = atmosphereDiffuseMethod.sharedRegisters.normalFragment;
			
			var code:String = "dp3 " + t + ".w, " + viewDirFragmentReg + ".xyz, " + normalFragmentReg + ".xyz\n" + 
							"mul " + t + ".w, " + t + ".w, " + t + ".w\n";
			
			return code;
		}
		
		private function modulateSpecularMethod(vo : MethodVO, t:ShaderRegisterElement, regCache:ShaderRegisterCache, sharedRegisters:ShaderRegisterData):String
		{
			vo=vo;
			regCache=regCache;
			sharedRegisters=sharedRegisters; 

			var viewDirFragmentReg:ShaderRegisterElement = atmosphereDiffuseMethod.sharedRegisters.viewDirFragment;
			var normalFragmentReg:ShaderRegisterElement = atmosphereDiffuseMethod.sharedRegisters.normalFragment;
			var temp:ShaderRegisterElement = regCache.getFreeFragmentSingleTemp();
			regCache.addFragmentTempUsages(temp, 1);
			
			var code:String = "dp3 " + temp + ", " + viewDirFragmentReg + ".xyz, " + normalFragmentReg + ".xyz\n" + 
							"neg" + temp + ", " + temp + "\n" +
							"mul " + t + ".w, " + t + ".w, " + temp + "\n";
				
				regCache.removeFragmentTempUsage(temp);
			
			return code;
		}
	}

}