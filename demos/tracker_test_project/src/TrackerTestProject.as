package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import oculusANE.OculusANE;
	
	public class TrackerTestProject extends Sprite
	{

		private var _oculus:OculusANE;
		
		public function TrackerTestProject()
		{
			_oculus = new OculusANE();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		protected function onEnterFrame(event:Event):void
		{
			if ( _oculus.isSupported() ) {
				
				// do this for each eye
				var eyePose:Object = _oculus.getEyePose(0);
				trace("pos x:" + eyePose.position[0] + " y: " + eyePose.position[1] + " z: " + eyePose.position[2]);
				
				var vec:Vector.<Number> = eyePose.orientation as Vector.<Number>;
				trace("rotation vector: " + vec);
				
			}
		}		
	
	}
}