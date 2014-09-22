package flare.loaders
{
	import flare.core.Pivot3D;
	import flare.core.Texture3D;
	import flare.materials.filters.LightMapFilter;
	import flare.materials.filters.TextureMapFilter;
	import flare.materials.Shader3D;
	import flare.system.ILibraryExternalItem;
	import flare.core.Surface3D;
	import flash.events.IOErrorEvent;
	import flash.filters.DisplacementMapFilterMode;
	import flash.net.URLLoader;
	import flare.system.Library3D;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flare.basic.Scene3D;
	import flash.events.Event;
	import flare.core.Mesh3D;
	import flare.flsl.FLSLFilter;
	import flare.modifiers.Modifier;
	import flare.core.Camera3D;
	import flare.core.Light3D;
	import flare.core.Frame3D;

	public class OculusModelLoader extends Pivot3D implements ILibraryExternalItem
	{
		private var _xmlPath:String;
		private var _assetPath:String;
		private var _loaded:Boolean = false;
		private var _urlLoader:URLLoader;
		private var _layerIndex:int = 0;
		
		public var collisionModels:Vector.<Pivot3D> = new Vector.<Pivot3D>;
		public static var requestTexture : Function;
		private var _oTextures:Object;


		public function OculusModelLoader(request:*, parent:Pivot3D = null, sceneContext:Scene3D = null, texturesFolder:String = null, flipNormals:Boolean = false, cullFace:String = "back") 
		{
			_xmlPath = request;
			var assetPathArray:Array = _xmlPath.split('/');
			assetPathArray.pop();
			_assetPath = assetPathArray.join('/');
			
			trace( "OculusModelLoader.OculusModelLoader > request : " + request + ", parent : " + parent + ", sceneContext : " + sceneContext + ", texturesFolder : " + texturesFolder + ", flipNormals : " + flipNormals + ", cullFace : " + cullFace );					
		}

		public function load() : void 
		{
			trace( "OculusModelLoader.load" );
			_urlLoader = new URLLoader(new URLRequest(_xmlPath));
			_urlLoader.addEventListener(Event.COMPLETE, onModelXMLLoaded);
		}
		
		private function onModelXMLLoaded(e:Event):void 
		{
			_urlLoader.removeEventListener(Event.COMPLETE, onModelXMLLoaded);
			var modelXml:XML = new XML(_urlLoader.data);
			var models:XMLList = modelXml.models.model;
			var textures:XMLList = modelXml.textures.texture;
			_oTextures = new Object();
			trace( "models.length() : " + models.length() );
			
			var usedTexturesList:XMLList = modelXml.models..texture;
			var usedTextureIndices:Object = new Object();
			for each (var textureXml:XML in usedTexturesList) 
			{
				if (String(textureXml.@index) != "-1") {					
					usedTextureIndices[textureXml.@index] = textureXml.@index;
				}
			}
			
			
			// find and create all unique textures
			var texturePath:String;
			var texture:Texture3D;
			for each (var item:int in usedTextureIndices) 
			{
				textureXml = textures[item];
				texturePath = _assetPath + "/" + textureXml.@fileName;
				if (String(textureXml.@alpha) == "1") {
					if (texturePath.indexOf('.atf') == -1) {
						texture = scene.addTextureFromFile(texturePath, false);
					}else {
						texture = scene.addTextureFromFile(texturePath, false, Texture3D.FORMAT_COMPRESSED_ALPHA);
					}
				}else {
					texture = scene.addTextureFromFile(texturePath, false, Texture3D.FORMAT_COMPRESSED);
				}
				
				texture.name = textureXml.@fileName;
				_oTextures[item] = texture;
			}
				
			
			
			// find and create all unique shaders (diffuse and lightmap combinations)
			var uniqueTextureCombinations:Object = new Object();
			for each (var model:XML in models) 
			{
				var diffuseTextureIndex:int =  parseInt(model.material.(@name == "diffuse").texture.@index);	
				var lightMapTextureIndex:int =  parseInt(model.material.(@name == "lightmap").texture.@index);
				
				uniqueTextureCombinations[diffuseTextureIndex + "_" + lightMapTextureIndex] = {diffuseIndex: diffuseTextureIndex, lightMapIndex: lightMapTextureIndex};
			}
			
			var shader:Shader3D;
			var allShaders:Object = new Object();
			for each (var textureCombi:Object in uniqueTextureCombinations) 
			{
				shader = new Shader3D(String(textureCombi.diffuseIndex + "_" + textureCombi.lightMapIndex));
				
				if (textureCombi.diffuseIndex != -1) {
					texture = _oTextures[textureCombi.diffuseIndex];
					if (texture.format != Texture3D.FORMAT_COMPRESSED) {
						shader.transparent = true;
					}
					shader.filters.push( new TextureMapFilter(texture) );
				}
				
				if (textureCombi.lightMapIndex != -1) {
					texture = _oTextures[textureCombi.lightMapIndex];
					shader.filters.push( new LightMapFilter(texture) );						
				}else {
					shader.enableLights = false;
				}
				
				shader.build();
				
				allShaders[String(textureCombi.diffuseIndex + "_" + textureCombi.lightMapIndex)] = shader;
			}
			
			
			for each (model in models) 
			{
				var mesh:Mesh3D = new Mesh3D(String(model.@name));
				mesh.surfaces[0] = new Surface3D("my surface");
				mesh.surfaces[0].addVertexData( Surface3D.POSITION, 3 );
				mesh.surfaces[0].addVertexData( Surface3D.NORMAL, 3 );
				mesh.surfaces[0].addVertexData( Surface3D.UV0, 2 );
				mesh.surfaces[0].addVertexData( Surface3D.UV1, 2 );
		
				
				var verticesArray:Array = String(model.vertices).split(" ");
				//trace( "verticesArray : " + verticesArray.length );
				var normalsArray:Array = String(model.normals).split(" ");
				//trace( "normalsArray : " + normalsArray.length );
				var uv0Array:Array = String(model.material[0].texture).split(" ");
				//trace( "uv0Array : " + uv0Array.length );
				var uv1Array:Array = String(model.material[1].texture).split(" ");
				//trace( "uv1Array : " + uv1Array.length );			
				var indexArray:Array = String(model.indices).split(" ");
				//trace( "indexArray : " + indexArray.length );
				
				//var vertexVector:Vector.<Number> = new Vector.<Number>;
				var index:int = 0;
				var uvIndex:int = 0;
				var v0:Number, v1:Number, v2:Number;
				var n0:Number, n1:Number, n2:Number;
				var uv0_0:Number, uv0_1:Number;
				var uv1_0:Number, uv1_1:Number;
				
				var vertexVector:Vector.<Number> = new Vector.<Number>();
				while (index < verticesArray.length) {
					v0 = parseFloat(verticesArray[index]);
					n0 = parseFloat(normalsArray[index]);
					uv0_0 = parseFloat(uv0Array[uvIndex]);
					uv1_0 = parseFloat(uv1Array[uvIndex]);
					
					v1 = parseFloat(verticesArray[index+1]);
					n1 = parseFloat(normalsArray[index+1]);
					uv0_1 = parseFloat(uv0Array[uvIndex+1]);
					uv1_1 = parseFloat(uv1Array[uvIndex+1]);
					
					v2 = parseFloat(verticesArray[index+2]);
					n2 = parseFloat(normalsArray[index + 2]);
					
					//vertexVector.push(v0, v1, v2, n0, n1, n2, uv0, uv1);
					mesh.surfaces[0].vertexVector.push(v0, v1, v2, n0, n1, n2, uv0_0, uv0_1, uv1_0, uv1_1);
					
					index += 3;
					uvIndex += 2;
				}
				index = 0;
				while (index < indexArray.length) {
					mesh.surfaces[0].indexVector.push(indexArray[index++]);
				}
				
				mesh.layer = -1;
				
				if (model.@isCollisionModel == "1") {
					mesh.visible = false;
					collisionModels.push(mesh);
				}
					
				diffuseTextureIndex =  parseInt(model.material.(@name == "diffuse").texture.@index);
				lightMapTextureIndex =  parseInt(model.material.(@name == "lightmap").texture.@index);
				
				mesh.surfaces[0].material = allShaders[String(diffuseTextureIndex + "_" + lightMapTextureIndex)];
				if (mesh.surfaces[0].material.transparent) {
					mesh.layer = _layerIndex++;
				}
				
				//shader.twoSided = true;
				//mesh.scaleX = -1;
				
				scene.addChild(mesh);
			}
			
			_loaded = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}		
		
		private function onTextureNotFound(e:IOErrorEvent):void 
		{
			trace( "OculusModelLoader.onTextureNotFound > e : " + e.text );
			
		}
		
		public function get bytesLoaded():uint 
		{
			return 0;
		}

		public function get bytesTotal() : uint 
		{
			return 0;
		}

		public function get loaded():Boolean 
		{
			trace( "get loaded");
			return _loaded;
		}

		public function close():void 
		{
			trace( "OculusModelLoader.close" );
			
		}

		public static function extract(weightTable:Vector.<Array>, surface:Surface3D, indices:Vector.<uint>):void 
		{
			trace( "OculusModelLoader.extract > weightTable : " + weightTable + ", surface : " + surface + ", indices : " + indices );	
		}
	}
}
