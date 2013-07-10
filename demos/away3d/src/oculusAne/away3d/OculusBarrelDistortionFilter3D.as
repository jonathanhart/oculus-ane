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
		
		public function OculusBarrelDistortionFilter3D(lensCenterX:Number = 0.5, lensCenterY:Number = 0.5, scaleInX:Number = 2, scaleX:Number = 0.5, hmdWarpParamX:Number = 1, hmdWarpParamY:Number = 0.22, hmdWarpParamZ:Number = 0.24, hmdWarpParamW:Number = 0) 
		{
			super();
			_task = new OculusBarrelDistortionTask(lensCenterX, lensCenterY, scaleInX, scaleX, hmdWarpParamX, hmdWarpParamY, hmdWarpParamZ, hmdWarpParamW);
			addTask(_task);
		}
		
		
		public function get lensCenterX():Number
		{
			return _task.lensCenterX;
		}
		
		public function set lensCenterX(value:Number):void
		{
			_task.lensCenterX = value;
		}
		
		public function get lensCenterY():Number
		{
			return _task.lensCenterY;
		}
		
		public function set lensCenterY(value:Number):void
		{
			_task.lensCenterY = value;			
		}
		
		public function get scaleIn():Number
		{
			return _task.scaleIn;
		}
		
		public function set scaleIn(value:Number):void
		{
			_task.scaleIn = value;			
		}
		
		public function get scale():Number
		{
			return _task.scale;
		}
		
		public function set scale(value:Number):void
		{
			_task.scale = value;			
		}
		
		public function get hmdWarpParamX():Number
		{
			return _task.hmdWarpParamX;
		}
		
		public function set hmdWarpParamX(value:Number):void
		{
			_task.hmdWarpParamX = value;			
		}
		
		public function get hmdWarpParamY():Number
		{
			return _task.hmdWarpParamY;
		}
		
		public function set hmdWarpParamY(value:Number):void
		{
			_task.hmdWarpParamY = value;			
		}
		
		public function get hmdWarpParamZ():Number
		{
			return _task.hmdWarpParamZ;
		}
		
		public function set hmdWarpParamZ(value:Number):void
		{
			_task.hmdWarpParamZ = value;			
		}
		
		public function get hmdWarpParamW():Number
		{
			return _task.hmdWarpParamW;
		}
		
		public function set hmdWarpParamW(value:Number):void
		{
			_task.hmdWarpParamW = value;
		}		
	}

}
