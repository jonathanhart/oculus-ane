package be.but.oculus 
{
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.LensBase;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.primitives.PlaneGeometry;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.setInterval;
	/**
	 * ...
	 * @author Fragilem17
	 */
	public class OculusCamera extends ObjectContainer3D
	{
		public var leftCamera:Camera3D;
		public var rightCamera:Camera3D;
		private var _stereoSeperation:Number;
		
		public function OculusCamera(fov:Number, horizontalShiftPercentage:Number) 
		{
			var leftLens:OculusLens = new OculusLens(fov, 0.5 + horizontalShiftPercentage, 0.5);
			var rightLens:OculusLens = new OculusLens(fov, 0.5 - horizontalShiftPercentage, 0.5);
			
			leftCamera = new Camera3D(leftLens);
			rightCamera = new Camera3D(rightLens);
			
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
	}

}