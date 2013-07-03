package oculusANE
{
	import flash.events.EventDispatcher;
	import flash.external.ExtensionContext;
	
	public class OculusANE extends EventDispatcher
	{
		private var _extContext:ExtensionContext;
		
		public function OculusANE()
		{
			super(null);
			_extContext = ExtensionContext.createExtensionContext("oculusAne", "");

			if ( !_extContext ) {
				throw new Error( "Not supported on this target platform." );
			}
		}
		
		public function getCameraQuaternion () : Vector.<Number>
		{
			return _extContext.call("getCameraQuaternion") as Vector.<Number>;
		}
		
		public function getHMDInfo() : HmdInfo
		{
			var info:Object = _extContext.call("getHMDInfo") as Object;
			var hmdInfo:HmdInfo = new HmdInfo();
			
			for (var property:String in info) {
				if (hmdInfo.hasOwnProperty(property)){
					hmdInfo[property] = info[property];
				}
			}

			return hmdInfo;
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