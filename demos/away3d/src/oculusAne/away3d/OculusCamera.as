package oculusAne.away3d 
{
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.setInterval;
	
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.LensBase;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.primitives.PlaneGeometry;
	/**
	 * ...
	 * @author Fragilem17
	 */
	public class OculusCamera extends ObjectContainer3D
	{
		public var leftCamera:Camera3D;
		public var rightCamera:Camera3D;
		public var horizontalShiftPercentage:Number;
		
		private var _stereoSeperation:Number;

		private var _leftLens:OculusLens;
		private var _rightLens:OculusLens;

		
		public function OculusCamera(fieldOfView:Number, horizontalShiftPercentage:Number) 
		{
			this.horizontalShiftPercentage = horizontalShiftPercentage;
			_leftLens = new OculusLens(fieldOfView, 0.5 + horizontalShiftPercentage, 0.5);
			_rightLens = new OculusLens(fieldOfView, 0.5 - horizontalShiftPercentage, 0.5);
			
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

	}

}