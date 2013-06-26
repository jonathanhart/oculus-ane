package be.but.oculus
{
	import away3d.cameras.Camera3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.filters.tasks.Filter3DBrightPassTask;
	import away3d.filters.tasks.Filter3DTaskBase;

	import flash.display3D.Context3DProgramType;

	import flash.display3D.textures.Texture;

	public class OculusBarrelDistortionTask extends Filter3DTaskBase
	{

		public function OculusBarrelDistortionTask()
		{
			super();
		}

		override protected function getFragmentCode() : String
		{
			// PURE VOODO MAGIC BELOW THAT DOES SOME BRIGHTNESS STUFF COPIED FROM THE Filter3DBrightPassTask
			return 	"tex ft0, v0, fs0 <2d,linear,clamp>	\n" +
					"dp3 ft1.x, ft0.xyz, ft0.xyz	\n" +
					"sqt ft1.x, ft1.x				\n" +
					"sub ft1.y, ft1.x, fc0.x		\n" +
					"mul ft1.y, ft1.y, fc0.y		\n" +
					"sat ft1.y, ft1.y				\n" +
					"mul ft0.xyz, ft0.xyz, ft1.y	\n" +
					"mov oc, ft0					\n";
					
			// converted GLSL shader for the rift with 
			// http://www.cmodule.org/glsl2agal/
			// but code is erroring.. no idea where to start looking
			
			/*return	"sub ft1.xy, v2.xyyy, v0.xyyy	\n" +
					"mul ft3.xy, ft1.xyyy, fc5.xyyy	\n" +
					"mul ft1.y, ft3.y, ft3.y	\n" +
					"mul ft1.x, ft3.x, ft3.x	\n" +
					"add ft4.z, ft1.x, ft1.y	\n" +
					"mul ft2.z, fc6.w, ft4.z	\n" +
					"mul ft2.y, ft2.z, ft4.z	\n" +
					"mul ft2.x, ft2.y, ft4.z	\n" +
					"mul ft0.w, fc6.z, ft4.z	\n" +
					"mul ft0.z, ft0.w, ft4.z	\n" +
					"mul ft0.y, fc6.y, ft4.z	\n" +
					"add ft0.x, fc6.x, ft0.y	\n" +
					"add ft1.w, ft0.x, ft0.z	\n" +
					"add ft1.z, ft1.w, ft2.x	\n" +
					"mul ft4.xy, ft3.xyyy, ft1.z	\n" +
					"mul ft3.xy, fc7.xyyy, ft4.xyyy	\n" +
					"add ft4.xy, v0.xyyy, ft3.xyyy	\n" +
					"mov ft3.xy, ft4.xyyy	\n" +
					"sub ft3.y, fc3.x, ft4.y	\n" +
					"sub ft4.xy, v1.xyyy, fc4.xyyy	\n" +
					"add ft0.xy, v1.xyyy, fc4.xyyy	\n" +
					"min ft1.xy, ft3.xyyy, ft0.xyyy	\n" +
					"max ft0.xy, ft1.xyyy, ft4.xyyy	\n" +
					"seq ft1.xy, ft0.xyyy, ft3.xyyy	\n" +
					"add ft0.x, ft1.x, ft1.y	\n" +
					"sub ft1.x, fc3.x, ft0.x	\n" +
					"sub ft2.w, fc3.x, ft1.x	\n" +
					"mul oc, oc, ft2.w	\n" +
					"sub ft0.x, fc3.x, ft1.x	\n" +
					"sub ft1.x, fc3.x, ft0.x	\n" +
					"mul oc, oc, ft1.x	\n" +
					"tex ft1, ft3.xyyy, fs0 <linear mipdisable repeat 2d>	\n" +
					"mul ft3, ft1, ft0.x	\n" +
					"add oc, oc, ft3	\n";*/
		}

		override public function activate(stage3DProxy : Stage3DProxy, camera3D : Camera3D, depthTexture : Texture) : void
		{
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([0.01, 1 / (1-0.01), 0, 0]), 1);
		}
	}
}
