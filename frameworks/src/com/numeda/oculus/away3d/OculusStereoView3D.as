package com.numeda.oculus.away3d
{
	import away3d.cameras.Camera3D;
	import away3d.containers.Scene3D;
	import away3d.core.render.RendererBase;
	import away3d.stereo.StereoView3D;
	import away3d.stereo.methods.StereoRenderMethodBase;
	
	public class OculusStereoView3D extends StereoView3D
	{
		public function OculusStereoView3D(scene:Scene3D=null, camera:Camera3D=null, renderer:RendererBase=null, stereoRenderMethod:StereoRenderMethodBase=null)
		{
			super(scene, camera, renderer, stereoRenderMethod);
		}
		
		public override function set width(val:Number) : void
		{
			super.width = val;
			_viewScissorRect.width /= 2;
		}		
	}
}