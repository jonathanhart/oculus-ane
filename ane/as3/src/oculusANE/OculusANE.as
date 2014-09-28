package oculusANE
{
	import flash.events.EventDispatcher;
	import flash.external.ExtensionContext;
	
	public class OculusANE extends EventDispatcher
	{
		private var _extContext:ExtensionContext;

		public static var ovrHmdCap_LowPersistence:uint = 128;
		public static var ovrHmdCap_DynamicPrediction:uint = 512;
	
		public function OculusANE()
		{
			super(null);
			_extContext = ExtensionContext.createExtensionContext("oculusAne", "");

			if ( !_extContext ) {
				throw new Error( "Not supported on this target platform." );
			}
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