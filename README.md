oculus-ane
==========

Oculus ANE (Adobe Native Extension)

Mac OSX only for now. Windows support coming soon (especially if someone wants to help out with it)

--- 

AWAY3D Support (alpha): 

Just added support for Away3D. Some caveats:

	1) Not optimized
	2) No lens correction yet
	3) No peripheral occlusion yet

To connect the Oculus via the ANE, add it in the Project Properties (remember to also check it off in the ActionScript Build Packaging section!)

Connect to the Oculus in AS3:

	var oculus:OculusANE = new OculusANE();

Tell Away3D to render in Oculus mode:

	_scene = new Scene3D();
	
	_camera = new OculusCamera3D();
	_camera.z = 0;
	
	_view = new OculusStereoView3D();
	_view.scene = _scene;
	_view.camera = _camera;
	_view.stereoRenderMethod = new OculusStereoRenderMethod();
	
	addChild(_view);

For every frame of your render loop, have this code:

	private function enterFrame(event:Event) : void {
		
		var quatVec:Vector.<Number> = _oculus.getCameraQuaternion();
		var quat:Quaternion = new Quaternion(-quatVec[0], -quatVec[1], quatVec[2], quatVec[3]); 
		_camera.transform = quat.toMatrix3D(_core.transform);
		_view.render();
	}

