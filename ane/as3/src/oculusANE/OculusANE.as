package oculusANE
{
	import flash.events.EventDispatcher;
	import flash.external.ExtensionContext;
	import flash.geom.Point;
	
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
		
		public function getOculusResolution() : Point
		{
			var resolution:Vector.<Number> = _extContext.call("getOculusResolution") as Vector.<Number>;
			return new Point(resolution[0], resolution[1]);
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