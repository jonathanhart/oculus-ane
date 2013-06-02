package be.but.oculus 
{
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.LensBase;
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.primitives.PlaneGeometry;
	import flash.events.Event;
	import flash.utils.setInterval;
	/**
	 * ...
	 * @author Fragilem17
	 */
	public class OculusCamera extends Mesh
	{
		public var leftCamera:Camera3D;
		public var rightCamera:Camera3D;
		private var _ipd:Number;
		
		public function OculusCamera(lens:LensBase=null) 
		{
			super(new PlaneGeometry());
			leftCamera = new Camera3D(lens);
			rightCamera = new Camera3D(lens);
			
			addChild(leftCamera);
			addChild(rightCamera);
			
			//setInterval(onEnterFrame, 15);
		}
		
		private function onEnterFrame(e:Event = null):void 
		{
			leftCamera.position = position;
			rightCamera.position = position;
			
			leftCamera.rotationX = rotationX;
			rightCamera.rotationX = rotationX;
			
			leftCamera.rotationZ = rotationZ;
			rightCamera.rotationZ = rotationZ;
			trace( "rightCamera.rotationX : " + rightCamera.rotationX );
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