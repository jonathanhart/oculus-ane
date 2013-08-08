package
{	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import oculusANE.OculusANE;
	
	public class TrackerDemo extends Sprite
	{
		private var _ovr:OculusANE = new OculusANE();
		
		public function TrackerDemo()
		{
			if (_ovr.isSupported()) {
				this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
				var obj:Object = _ovr.getHMDInfo();
			} else {
				trace("Oculus Rift not connected or unsupported.");
			}
		}
		
		private function handleEnterFrame(event:Event) : void
		{
			var vec:Vector.<Number> = _ovr.getCameraQuaternion();
			trace("Vec: " + vec[0] + "/" + vec[1] + "/" + vec[2] + "/" + vec[3]);
		}
	}
}