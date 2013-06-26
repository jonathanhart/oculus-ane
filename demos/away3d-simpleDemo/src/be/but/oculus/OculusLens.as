package be.but.oculus
{
	import away3d.cameras.lenses.LensBase;
	import away3d.core.math.Matrix3DUtils;
	
	import flash.geom.Vector3D;
	
	public class OculusLens extends LensBase
	{
		private var _fieldOfView:Number;
		private var _focalLengthInv:Number;
		private var _yMax:Number;
		private var _xMax:Number;
		private var _left:Number;
		private var _top:Number;
		
		public function OculusLens(fieldOfView:Number = 60, left:Number = 0.5, top:Number = 0.5)
		{
			this.fieldOfView = fieldOfView;
			this.left = left;
			this.top = top;
		}
		
		public override function project(point3d:Vector3D):Vector3D
		{
			//In dev version of Away3D 4.1.0 - LensBase.as
			//TODO this function was affected by commit 21a6cea0fa644d812c418aca665e31ab5fb1f73e, applied reverting override
			
			var v:Vector3D = matrix.transformVector(point3d);
			v.x = v.x / v.w;
			v.y = -v.y / v.w;
			
			//z is unaffected by transform
			//v.z = point3d.z;
			
			return v;
		}
		
		/**
		 * Calculates the position of the given normalized coordinates relative to the camera.
		 * @param mX The x coordinate relative to the View3D. -1 corresponds to the utter left side of the viewport, 1 to the right.
		 * @param mY The y coordinate relative to the View3D. -1 corresponds to the top side of the viewport, 1 to the bottom.
		 * @param mZ The distance from the projection plane.
		 * @return The scene position of the given screen coordinates.
		 */
		public override function unproject(mX:Number, mY:Number, mZ:Number):Vector3D
		{
			//In dev version of Away3D 4.1.0 - LensBase.as
			//TODO this function was affected by commit 21a6cea0fa644d812c418aca665e31ab5fb1f73e, applied reverting override
			
			var v:Vector3D = new Vector3D(mX, -mY, mZ, 1.0);
			
			v = unprojectionMatrix.transformVector(v);
			
			var inv:Number = 1 / v.w;
			
			v.x *= inv;
			v.y *= inv;
			v.z *= inv;
			v.w = 1.0;
			
			return v;
		}
		
		public function get fieldOfView():Number
		{
			return _fieldOfView;
		}
		
		public function get left():Number
		{
			return _left
		}
		;
		
		public function get top():Number
		{
			return _top
		}
		;
		
		public function set fieldOfView(value:Number):void
		{
			if (value == _fieldOfView)
				return;
			_fieldOfView = value;
			
			_focalLengthInv = Math.tan(_fieldOfView * Math.PI / 360);
			invalidateMatrix();
		}
		
		/**
		 *
		 * @param value
		 *
		 */
		public function set left(value:Number):void
		{
			_left = value;
			invalidateMatrix();
		}
		
		/**
		 *
		 * @param value
		 *
		 */
		public function set top(value:Number):void
		{
			_top = value;
			invalidateMatrix();
		}
		
		/**
		 *
		 *
		 */
		override protected function updateMatrix():void
		{
			//trace( "OculusLens.updateMatrix" );
			var yScale:Number = (1.0 / Math.tan((fieldOfView * Math.PI / 360)));
			var xScale:Number = (yScale / _aspectRatio);
			
			var xScaleTotal:Number = 2 * _near / xScale;
			var left:Number = -_left * xScaleTotal;
			var right:Number = (1 - _left) * xScaleTotal;
			
			var yScaleTotal:Number = 2 * _near / yScale;
			var bottom:Number = (_top - 1) * yScaleTotal;
			var top:Number = _top * yScaleTotal;
			
			var raw:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
			
			// assume symmetric frustum
			raw[uint(0)] = 2.0 * _near / (right - left);
			raw[uint(5)] = -2.0 * _near / (bottom - top);
			raw[uint(8)] = -1.0 - 2.0 * left / (right - left);
			raw[uint(9)] = 1.0 + 2.0 * top / (bottom - top);
			raw[uint(5)] = -2.0 * _near / (bottom - top);
			raw[uint(10)] = -_far / (_near - _far);
			raw[uint(11)] = 1;
			raw[uint(1)] = raw[uint(2)] = raw[uint(3)] = raw[uint(4)] = raw[uint(6)] = raw[uint(7)] = raw[uint(12)] = raw[uint(13)] = raw[uint(15)] = 0;
			raw[uint(14)] = (_near * _far) / (_near - _far);
			
			_matrix.copyRawDataFrom(raw);
			
			_yMax = _near * _focalLengthInv;
			_xMax = _yMax * _aspectRatio;
			
			var yMaxFar:Number = _far * _focalLengthInv;
			var xMaxFar:Number = yMaxFar * _aspectRatio;
			
			_frustumCorners[0] = _frustumCorners[9] = -_xMax * _left;
			_frustumCorners[3] = _frustumCorners[6] = _xMax * (1 - _left);
			_frustumCorners[1] = _frustumCorners[4] = -_yMax * _top;
			_frustumCorners[7] = _frustumCorners[10] = _yMax * (1 - _top);
			
			_frustumCorners[12] = _frustumCorners[21] = -xMaxFar * _left;
			_frustumCorners[15] = _frustumCorners[18] = xMaxFar * (1 - _left);
			_frustumCorners[13] = _frustumCorners[16] = -yMaxFar * _top;
			_frustumCorners[19] = _frustumCorners[22] = yMaxFar * (1 - _top);
			
			_frustumCorners[2] = _frustumCorners[5] = _frustumCorners[8] = _frustumCorners[11] = _near;
			_frustumCorners[14] = _frustumCorners[17] = _frustumCorners[20] = _frustumCorners[23] = _far;
			
			_matrixInvalid = false;
		}
	}
}