package oculusANE
{
	public class HmdInfo
	{
		public var hScreenSize:Number;
		public var vScreenSize:Number;
		public var vScreenCenter:Number;
		public var eyeToScreenDistance:Number;
		public var lensSeparationDistance:Number;
		public var interPupillaryDistance:Number;
		public var hResolution:int;
		public var vResolution:int;
		public var distortionK:Vector.<Number>;
		public var chromaAbCorrection:Vector.<Number>;
		
		public function HmdInfo()
		{
			/*
			// defaults for development kit 1
			hScreenSize	= 0.14975999295711517;
			vScreenSize	= 0.09359999746084213;
			vScreenCenter = 0.046799998730421066;	
			eyeToScreenDistance = 0.04100000113248825;
			lensSeparationDistance = 0.06350000202655792;
			interPupillaryDistance = 0.06400000303983688;
			hResolution = 1280;
			vResolution = 800;
			distortionK	= [1, 0.2199999988079071, 0.23999999463558197, 0];
			chromaAbCorrection = [0.9959999918937683, -0.004000000189989805, 1.0140000581741333, 0];	
			*/
		}
	}
}