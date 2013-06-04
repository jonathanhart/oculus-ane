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
		private var _ipd:Number;
		
		public function OculusCamera(lens:LensBase=null) 
		{
			leftCamera = new Camera3D(lens);
			rightCamera = new Camera3D(lens);
			
			addChild(leftCamera);
			addChild(rightCamera);

			leftCamera.position = new Vector3D();
			rightCamera.position = new Vector3D();
		}
				
		public function get ipd():Number 
		{
			return _ipd;
		}
		
		public function set ipd(value:Number):void 
		{
			_ipd = value;
			leftCamera.x = -(_ipd / 2);
			rightCamera.x = (_ipd / 2);
		}		
	}

}