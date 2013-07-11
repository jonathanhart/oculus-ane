oculus-ane
==========

Oculus ANE (Adobe Native Extension)

Alpha support for both Mac OSX and Windows.

Support for Away3D. Some caveats:

	1) Not optimized
	2) Basic lens correction (works only at the rift's native resolution of 1280x800)
	3) No Chromatic aberration implemented yet (colors shift at the edges)

--- 

To connect the Oculus via the ANE, add it in the Project Properties (remember to also check it off in the ActionScript Build Packaging section!)

Connect to the Oculus in AS3:

	var _oculus:OculusANE = new OculusANE();


For every frame of your render loop, have this code:

	private function enterFrame(event:Event) : void {
		
		var quatVec:Vector.<Number> = _oculus.getCameraQuaternion();
		var quat:Quaternion = new Quaternion(-quatVec[0], -quatVec[1], quatVec[2], quatVec[3]); 
		_camera.transform = quat.toMatrix3D(_core.transform);
		_view.render();
	}

When your application is closing make sure to call the dispose method to avoid a crash by using this code:

	_oculus.dispose();