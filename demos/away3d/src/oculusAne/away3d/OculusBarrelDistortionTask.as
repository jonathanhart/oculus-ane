package oculusAne.away3d
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	
	import away3d.cameras.Camera3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.filters.tasks.Filter3DTaskBase;
	
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
				
				// SDK says: 
				//  float2 theta = (in01 - LensCenter) * ScaleIn; // Scales to [-1, 1]
				// replace above with constants
				// float2 theta = (ft0.xy - fc0.xy) * fc0.z;
				
				"sub ft0.xy, ft0.xy, fc0.xy 	\n" +
				// float2 theta = (ft0.xy) * fc0.z;
				
				"mul ft0.xy, ft0.xy, fc0.zz 	\n" +
				// float2 theta = ft0.xy;
				// ft0.xy = theta
				
				
				// SDK says:
				//  float rSq = theta.x * theta.x + theta.y * theta.y;
				// replace above with constants
				//  float rSq = ft0.x * ft0.x + ft0.y * ft0.y;
				
				"mul ft1.x, ft0.x, ft0.x 	\n" +
				//  float rSq = ft1.x + ft0.y * ft0.y;
				
				"mul ft1.y, ft0.y, ft0.y 	\n" +
				//  float rSq = ft1.x + ft1.y;
				
				"add ft2.x, ft1.x, ft1.y 	\n" +
				// float rSq = ft1.x + ft1.y
				// ft2.x = rSq
				
				
				
				// SDK says:
				// float2 rvector= theta * (HmdWarpParam.x + HmdWarpParam.y * rSq +	HmdWarpParam.z * rSq * rSq + HmdWarpParam.w * rSq * rSq * rSq);
				// replace above with constants
				// float2 rvector= ft0.xy * (fc1.x + fc1.y * ft2.x + fc1.z * ft2.x * ft2.x + fc1.w * ft2.x * ft2.x * ft2.x);
				
				
				"mul ft2.y, ft2.x, ft2.x 	\n" +
				// float2 rvector= ft0.xy * (fc1.x + fc1.y * ft2.x + fc1.z * ft2.y + fc1.w * ft2.y * ft2.x);
				
				
				"mul ft2.z, ft2.y, ft2.x 	\n" +
				// float2 rvector= ft0.xy * (fc1.x + fc1.y * ft2.x + fc1.z * ft2.y + fc1.w * ft2.z);
				
				
				"mul ft3.x, fc1.y, ft2.x 	\n" +
				// float2 rvector= ft0.xy * (fc1.x + ft3.x + fc1.z * ft2.y + fc1.w * ft2.z);	
				
				
				"mul ft3.y, fc1.z, ft2.y 	\n" +
				// float2 rvector= ft0.xy * (fc1.x + ft3.x + ft3.y + fc1.w * ft2.z);				
				
				
				"mul ft3.z, fc1.w, ft2.z 	\n" +
				// float2 rvector= ft0.xy * (fc1.x + ft3.x + ft3.y + ft3.z);			
				
				
				"add ft3.w, fc1.x, ft3.x 	\n" +
				// float2 rvector= ft0.xy * (ft3.w + ft3.y + ft3.z);
				
				
				"add ft4.x, ft3.w, ft3.y 	\n" +
				// float2 rvector= ft0.xy * (ft4.x + ft3.z);
				
				
				"add ft4.y, ft4.x, ft3.z 	\n" +
				// float2 rvector= ft0.xy * (ft4.y);
				
				
				"mul ft4.zw, ft0.xy, ft4.yy 	\n" +
				// float2 rvector= ft4.zw;
				// ft4.zw = rvector
				
				
				// SDK says:
				// float2 tc = LensCenter + Scale * rvector;
				// replace above with constants
				// float2 tc = fc0.xy + fc0.w * ft4.zw;
				
				"mul ft5.xy, fc0.ww, ft4.zw 	\n" +
				// float2 tc = fc0.xy + ft5.xy;
				
				"add ft5.xy, fc0.xy, ft5.xy 	\n" +
				// float2 tc = ft6.xy;				
				
				// SDK says: return Texture.Sample(Linear, tc);
				"tex ft1, ft5.xy, fs0 <2d,linear,clamp>	\n" +
				//"tex ft1, ft0.xy, fs0 <2d,linear,clamp>	\n" +
				
				"mov oc, ft1";
		}
		
		override public function activate(stage3DProxy : Stage3DProxy, camera3D : Camera3D, depthTexture : Texture) : void
		{
			var context:Context3D = stage3DProxy.context3D;
			
			/*
			// damn texture map is 1024 instead of 640
			var centerX:Number = (640/2) / 1024; // 0.3125
			var centerY:Number = (800/2) / 1024;
			
			// total left side of texture needs to be -1, total right 1
			// code above needs to mul. the centerX with scale in orde to achieve this 
			var scaleX:Number = (1 / (centerX*2)) * 2;
			var scaleY:Number = (1 / (centerY*2)) * 2;
			*/
			
			// hmd params should come from the hms, not just hardcoded like now
			
			// center x, center y, ScaleIn, scale,     hmdParam.x, y, z, w
			var data:Vector.<Number> = Vector.<Number>([0.5, 0.5, 2, 1,    1, 0.22, 0.24, 0]);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, data, 2);
		}
	}
}

