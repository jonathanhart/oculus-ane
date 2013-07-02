package oculusAne.away3d 
{
	import away3d.filters.Filter3DBase;
	
	/**
	 * ...
	 * @author 
	 */
	public class OculusBarrelDistortionFilter3D extends Filter3DBase
	{
		private var _task:OculusBarrelDistortionTask;
		
		public function OculusBarrelDistortionFilter3D() 
		{
			super();
			_task = new OculusBarrelDistortionTask();
			addTask(_task);
		}
	}

}
