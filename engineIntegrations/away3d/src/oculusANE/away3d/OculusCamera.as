package oculusANE.away3d 
{
	import flash.geom.Vector3D;
	
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	
	/**
	 * ...
	 * @author Fragilem17
	 */
	public class OculusCamera extends ObjectContainer3D
	{
		public var leftCamera:Camera3D;
		public var rightCamera:Camera3D;
		private var _lensCenterOffset:Number;
		
		private var _stereoSeperation:Number;

		private var _leftLens:OculusLens;
		private var _rightLens:OculusLens;

		
		public function OculusCamera(fieldOfView:Number, lensCenterOffset:Number) 
		{
			_lensCenterOffset = lensCenterOffset;
			_leftLens = new OculusLens(fieldOfView, 0.5 + _lensCenterOffset, 0.5);
			_rightLens = new OculusLens(fieldOfView, 0.5 - _lensCenterOffset, 0.5);
			
			leftCamera = new Camera3D(_leftLens);
			rightCamera = new Camera3D(_rightLens);
			
			addChild(leftCamera);
			addChild(rightCamera);

			leftCamera.position = new Vector3D();
			rightCamera.position = new Vector3D();
		}
				
		public function get stereoSeperation():Number 
		{
			return _stereoSeperation;
		}
		
		public function set stereoSeperation(value:Number):void 
		{
			_stereoSeperation = value;
			trace("stereoSeperation: " + _stereoSeperation);
			leftCamera.x = -(_stereoSeperation / 2);
			rightCamera.x = (_stereoSeperation / 2);
		}		

		public function get fieldOfView():Number
		{
			return _leftLens.fieldOfView;
		}

		public function set fieldOfView(value:Number):void
		{
			_leftLens.fieldOfView = value;
			_rightLens.fieldOfView = value;
		}

		public function get lensCenterOffset():Number
		{
			return _lensCenterOffset;
		}

		public function set lensCenterOffset(value:Number):void
		{
			_lensCenterOffset = value;
			_leftLens.left = 0.5 + _lensCenterOffset;
			_rightLens.left = 0.5 - _lensCenterOffset;
		}


	}

}