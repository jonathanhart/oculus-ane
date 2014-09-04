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
				var position:Vector.<Vector3D> = _oculus.getOculusPosition();
				trace( "position : " + position );
				var quaternion:Vector.<Number> = _oculus.getCameraQuaternion();
				trace("quaternion: " + quaternion);
			}
		}		
	
	}
}