package oculusAne.away3d
{
	import away3d.cameras.Camera3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.filters.tasks.Filter3DBrightPassTask;
	import away3d.filters.tasks.Filter3DRadialBlurTask;
	import away3d.filters.tasks.Filter3DTaskBase;
	import flash.display3D.Context3D;

	import flash.display3D.Context3DProgramType;

	import flash.display3D.textures.Texture;

	public class OculusBarrelDistortionTask extends Filter3DTaskBase
	{

		public function OculusBarrelDistortionTask()
		{
			super();
		}		
		
		override protected function getVertexCode() : String
		{
			return 	"mov op, va0\n" +
					"mov v0, va1";
		}
		
		override protected function getFragmentCode() : String
		{
			return 	"mov ft0, v0	\n" +
					
					//  centerpoint to the right
					"sub ft0.xy, ft0.xy, fc0.xy 	\n" +
					// scale it
					"mul ft0.xy, ft0.xy, fc0.zz 	\n" +
					
					// pytagoras ft1 = theta
					"mul ft1.x, ft0.x, ft0.x 	\n" +
					"mul ft1.y, ft0.y, ft0.y 	\n" +
					
					// length of vector ft2 = r squared
					"add ft2.x, ft1.x, ft1.y 	\n" +
					
					
					// inner mul hmd.y with r squared
					"mul ft3.x, fc1.y, ft2.x 	\n" +
					
					// add hmd.x with previous result
					"add ft4.x, ft3.x, fc1.x 	\n" +
					
					// double up r squared
					"mul ft6.x, ft2.x, ft2.x 	\n" +
					"mul ft5.x, ft6.x, fc1.z	\n" +

					
					// add 
					"add ft4.x, ft4.x, ft5.x 	\n" +
					
					// double up r squared
					"mul ft6.x, ft6.x, ft2.x 	\n" +
					"mul ft6.x, ft6.x, fc1.w 	\n" +
					
					
					// now add everything 
					"add ft4.x, ft4.x, ft6.x 	\n" +
					
					// and mul with theta ( ft6 = rVector )					
					"mul ft6.xy, ft1.xy, ft4.xx 	\n" +
					
					// add the scale
					"mul ft6.xy, ft6.xy, fc0.ww	\n" + 
					
					// add the screencenter again
					"add ft6.xy, ft6.xy, fc0.xy	\n" + 
					"tex ft1, ft6.xy, fs0 <2d,linear,clamp>	\n" +

					"mov oc, ft1";
		}
		
		override public function activate(stage3DProxy : Stage3DProxy, camera3D : Camera3D, depthTexture : Texture) : void
		{
			var context:Context3D = stage3DProxy.context3D;
			
			// center x, center y, scaleIn, scale,     hmdParam.x, y, z, w
			var data:Vector.<Number> = Vector.<Number>([0.5, 0.5, 2, 1,    1, 0.22, 0.24, 0]);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, data, 2);
		}
	}
}
