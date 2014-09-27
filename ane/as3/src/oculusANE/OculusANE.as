package oculusANE
{
	import flash.events.EventDispatcher;
	import flash.external.ExtensionContext;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	public class OculusANE extends EventDispatcher
	{
		private var _extContext:ExtensionContext;

		private var _eyePositions:Vector.<Number>;
		private var _eyes:Vector.<Vector3D>;
		
		public static var ovrHmdCap_LowPersistence:uint = 128;
		public static var ovrHmdCap_DynamicPrediction:uint = 512;
	
		public function OculusANE()
		{
			super(null);
			_extContext = ExtensionContext.createExtensionContext("oculusAne", "");

			if ( !_extContext ) {
				throw new Error( "Not supported on this target platform." );
			}else{
				_eyes = new Vector.<Vector3D>();
				_eyes.push(new Vector3D(), new Vector3D());
			}
		}
		
		public function getCameraQuaternion () : Vector.<Number>
		{
			return _extContext.call("getCameraQuaternion") as Vector.<Number>;
		}
		
		public function getOculusResolution() : Point
		{
			var resolution:Vector.<Number> = _extContext.call("getOculusResolution") as Vector.<Number>;
			return new Point(resolution[0], resolution[1]);
		}
		
		public function getOculusPosition() : Vector.<Vector3D>
		{
			_eyePositions = _extContext.call("getCameraPosition") as Vector.<Number>;
			_eyes[0].x = _eyePositions[0];
			_eyes[0].y = _eyePositions[1];
			_eyes[0].z = _eyePositions[2];
			_eyes[1].x = _eyePositions[3];
			_eyes[1].y = _eyePositions[4];
			_eyes[1].z = _eyePositions[5];
			return _eyes;
		}
		
		
		public function getHMDInfo () : Object
		{
			return _extContext.call("getHMDInfo") as Object;
		}
		
		public function beginFrameTiming () : Object
		{
			return _extContext.call("beginFrameTiming") as Object;
		}	
		
		public function endFrameTiming () : Object
		{
			return _extContext.call("endFrameTiming") as Object;
		}			
				
		public function setEnabledCaps (hmdCaps:uint) : Object
		{
			return _extContext.call("setEnabledCaps", hmdCaps) as Object;
		}	
		
		public function getEyePose (eyeNum:uint) : Object
		{ 
			return _extContext.call("getEyePose", eyeNum) as Object;
		}
		
		public function getEyeTimewarpMatrices (eyeNum:uint) : Object
		{ 
			return _extContext.call("getEyeTimewarpMatrices", eyeNum) as Object;
		}	
		
		public function getRenderInfo () : Object
		{
			return _extContext.call("getRenderInfo") as Object;
		}
		
		public function isSupported() : Boolean
		{
			return _extContext.call("isSupported");
		}
		
		public function dispose():void
		{
			_extContext.dispose();
		}
	}
}