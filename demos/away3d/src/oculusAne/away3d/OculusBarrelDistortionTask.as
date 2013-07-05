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
		private var _data:Vector.<Number>;
		
		
		private var _lensCenterX:Number;
		private var _lensCenterY:Number;
		
		private var _scaleInX:Number;
		private var _scaleInY:Number;
		
		private var _scaleX:Number;
		private var _scaleY:Number;
		
		private var _hmdWarpParamX:Number;
		private var _hmdWarpParamY:Number;
		private var _hmdWarpParamZ:Number;
		private var _hmdWarpParamW:Number;


		public function OculusBarrelDistortionTask(lensCenterX:Number, lensCenterY:Number, scaleInX:Number, scaleInY:Number, scaleX:Number, scaleY:Number, hmdWarpParamX:Number, hmdWarpParamY:Number, hmdWarpParamZ:Number, hmdWarpParamW:Number)
		{
			super();
			
			_lensCenterX = lensCenterX;
			_lensCenterY = lensCenterY;
			_scaleInX = scaleInX;
			_scaleInY = scaleInY;
			_scaleX = scaleX;
			_scaleY = scaleY;
			_hmdWarpParamX = hmdWarpParamX;
			_hmdWarpParamY = hmdWarpParamY;
			_hmdWarpParamZ = hmdWarpParamZ;
			_hmdWarpParamW = hmdWarpParamW;
			
			_data = Vector.<Number>([0, 0, 0, 0,   0, 0, 0, 0,   0, 0, 0, 0]);	
			updateFragmentConstants();
		}
		
		protected function updateFragmentConstants():void {
			// fc0
			_data[0] = _lensCenterX;		// fc0.x
			_data[1] = _lensCenterY;		// fc0.y
			_data[2] = _scaleInX;			// fc0.z
			_data[3] = _scaleInY;			// fc0.w
			
			// fc1
			_data[4] = _scaleX;				// fc1.x
			_data[5] = _scaleY;				// fc1.y
			_data[6] = 0; 					// not used
			_data[7] = 0; 					// not used
			
			// fc2
			_data[8] = _hmdWarpParamX;		// fc2.x
			_data[9] = _hmdWarpParamY;		// fc2.y
			_data[10] = _hmdWarpParamZ;		// fc2.z
			_data[11] = _hmdWarpParamW;		// fc2.w
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
				
				
				"mul ft0.xy, ft0.xy, fc0.zw 	\n" +
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
				// float2 rvector= ft0.xy * (fc2.x + fc2.y * ft2.x + fc2.z * ft2.x * ft2.x + fc2.w * ft2.x * ft2.x * ft2.x);
				
				
				"mul ft2.y, ft2.x, ft2.x 	\n" +
				// float2 rvector= ft0.xy * (fc2.x + fc2.y * ft2.x + fc2.z * ft2.y + fc2.w * ft2.y * ft2.x);
				
				
				"mul ft2.z, ft2.y, ft2.x 	\n" +
				// float2 rvector= ft0.xy * (fc2.x + fc2.y * ft2.x + fc2.z * ft2.y + fc2.w * ft2.z);
				
				
				"mul ft3.x, fc2.y, ft2.x 	\n" +
				// float2 rvector= ft0.xy * (fc2.x + ft3.x + fc2.z * ft2.y + fc2.w * ft2.z);	
				
				
				"mul ft3.y, fc2.z, ft2.y 	\n" +
				// float2 rvector= ft0.xy * (fc2.x + ft3.x + ft3.y + fc2.w * ft2.z);				
				
				
				"mul ft3.z, fc2.w, ft2.z 	\n" +
				// float2 rvector= ft0.xy * (fc2.x + ft3.x + ft3.y + ft3.z);			
				
				
				"add ft3.w, fc2.x, ft3.x 	\n" +
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
				// float2 tc = fc0.xy + fc1.xy * ft4.zw;
				
				"mul ft5.xy, fc1.xy, ft4.zw 	\n" +
				// float2 tc = fc0.xy + ft5.xy;
				
				"add ft5.xy, fc0.xy, ft5.xy 	\n" +
				// float2 tc = ft5.xy;				
				
				
				// SDK says: return Texture.Sample(Linear, tc);
				"tex ft1, ft5.xy, fs0 <2d,linear,clamp>	\n" +
				
				"mov oc, ft1";
		}
		
		override public function activate(stage3DProxy : Stage3DProxy, camera3D : Camera3D, depthTexture : Texture) : void
		{
			var context:Context3D = stage3DProxy.context3D;
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _data, 3);
		}

		public function get lensCenterX():Number
		{
			return _lensCenterX;
		}

		public function set lensCenterX(value:Number):void
		{
			_lensCenterX = value;
			updateFragmentConstants();
		}

		public function get lensCenterY():Number
		{
			return _lensCenterY;
		}

		public function set lensCenterY(value:Number):void
		{
			_lensCenterY = value;
			updateFragmentConstants();
		}

		public function get scaleInX():Number
		{
			return _scaleInX;
		}

		public function set scaleInX(value:Number):void
		{
			_scaleInX = value;
			updateFragmentConstants();
		}

		public function get scaleInY():Number
		{
			return _scaleInY;
		}

		public function set scaleInY(value:Number):void
		{
			_scaleInY = value;
			updateFragmentConstants();
		}

		public function get scaleX():Number
		{
			return _scaleX;
		}

		public function set scaleX(value:Number):void
		{
			_scaleX = value;
			updateFragmentConstants();
		}

		public function get scaleY():Number
		{
			return _scaleY;
		}

		public function set scaleY(value:Number):void
		{
			_scaleY = value;
			updateFragmentConstants();
		}

		public function get hmdWarpParamX():Number
		{
			return _hmdWarpParamX;
		}

		public function set hmdWarpParamX(value:Number):void
		{
			_hmdWarpParamX = value;
			updateFragmentConstants();
		}

		public function get hmdWarpParamY():Number
		{
			return _hmdWarpParamY;
		}

		public function set hmdWarpParamY(value:Number):void
		{
			_hmdWarpParamY = value;
			updateFragmentConstants();
		}

		public function get hmdWarpParamZ():Number
		{
			return _hmdWarpParamZ;
		}

		public function set hmdWarpParamZ(value:Number):void
		{
			_hmdWarpParamZ = value;
			updateFragmentConstants();
		}

		public function get hmdWarpParamW():Number
		{
			return _hmdWarpParamW;
		}

		public function set hmdWarpParamW(value:Number):void
		{
			_hmdWarpParamW = value;
			updateFragmentConstants();
		}


	}
}

