package away3d.stereo.methods
{
	import flash.display3D.Context3DProgramType;
	
	import away3d.core.managers.RTTBufferManager;
	import away3d.core.managers.Stage3DProxy;
	
	public class OculusStereoRenderMethod extends StereoRenderMethodBase
	{
		private var _shaderData : Vector.<Number>;
		
		public function OculusStereoRenderMethod()
		{
			super();
			
			_shaderData = new <Number>[1,1,1,1];
		}
		
		
		override public function activate(stage3DProxy:Stage3DProxy):void
		{
			if (_textureSizeInvalid) {
				var minV : Number;
				var rttManager : RTTBufferManager;
				
				rttManager = RTTBufferManager.getInstance(stage3DProxy);
				_textureSizeInvalid = false;
				
				_shaderData[0] = 0.5;
				_shaderData[1] = 2;
			}
			
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _shaderData);
		}
		
		
		override public function deactivate(stage3DProxy:Stage3DProxy):void
		{
			stage3DProxy.setTextureAt(2, null);
		}
		
		
		override public function getFragmentCode():String
		{
			return	"slt ft0, v1.xxxx, fc0.xxxx\n" +  // 1 if fc0.x is less than .5
					"sge ft1, v1.xxxx, fc0.xxxx\n" + // 1 if fc.x >= .5
					"mov ft3, v1\n"+
					"frc ft3, ft3\n"+ 
					"tex ft4, ft3, fs0 <2d,linear,nomip>\n"+
					"tex ft5, ft3, fs1 <2d,linear,nomip>\n"+
					"mul ft4, ft4, ft0\n"+
					"mul ft5, ft5, ft1\n"+
					"add ft6, ft4, ft5\n"+
					"mov oc, ft6";
		}
	}
}

