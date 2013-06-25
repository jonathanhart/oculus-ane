package com.numeda.OculusANE
{
	import flash.events.EventDispatcher;
	import flash.external.ExtensionContext;
	
	public class OculusANE extends EventDispatcher
	{
		private var _extContext:ExtensionContext;
		
		public function OculusANE()
		{
			super(null);
			_extContext = ExtensionContext.createExtensionContext("com.numeda.OculusANE", "");

			if ( !_extContext ) {
				throw new Error( "Not supported on this target platform." );
			}
		}
		
		public function getCameraQuaternion () : Vector.<Number>
		{
			return _extContext.call("getCameraQuaternion") as Vector.<Number>;
		}
		
		public function getHMDInfo() : Object
		{
			var info:Object = _extContext.call("getHMDInfo") as Object;
			return info;
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