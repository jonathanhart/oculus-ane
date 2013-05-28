package
{
	import com.numeda.OculusANE.OculusANE;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class TrackerDemo extends Sprite
	{
		private var _ovr:OculusANE = new OculusANE();
		
		public function TrackerDemo()
		{
			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		private function handleEnterFrame(event:Event) : void
		{
			var vec:Vector.<Number> = _ovr.getCameraQuaternion();
			trace("Vec: " + vec[0] + "/" + vec[1] + "/" + vec[2] + "/" + vec[3]);
		}
	}
}