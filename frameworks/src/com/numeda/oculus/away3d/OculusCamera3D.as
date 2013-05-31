package com.numeda.oculus.away3d
{
	import away3d.cameras.lenses.LensBase;
	import away3d.stereo.StereoCamera3D;
	
	public class OculusCamera3D extends StereoCamera3D
	{
		public function OculusCamera3D(lens:LensBase=null)
		{
			super(lens);
			this.stereoFocus = Infinity;
			this.stereoOffset = -381;
		} 
	}
}