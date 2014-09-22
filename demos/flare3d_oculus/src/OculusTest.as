package  
{
	import flare.basic.*;
	import flare.core.*;
	import flare.flsl.*;
	import flare.loaders.ZF3DLoader;
	import flare.materials.Shader3D;
	import flare.primitives.*;
	import flare.system.*;
	import flare.utils.Matrix3DUtils;
	import flare.utils.Pivot3DUtils;
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import oculusANE.*;
	import uk.co.soulwire.gui.SimpleGUI;
	
	[SWF(width = 1280, height = 800, frameRate = 75)]
	
	/**
	 * Oculus ANE, project page : https://github.com/jonathanhart/oculus-ane
	 */
	public class OculusTest extends Sprite 
	{
		public var scene:OculusScene3D;
		
		private var _gui:SimpleGUI;
		private var _playerModel:Pivot3D;
		private var _head:Pivot3D;
		private var _engineLeft:Pivot3D;
		private var _engineRight:Pivot3D;
		private var _eyes:Pivot3D;
		
		
		public function OculusTest() 
		{	
			scene = new OculusScene3D( this );
			
			scene.autoResize = true;
			scene.allowImportSettings = true;
			scene.frameRate = 75;
			scene.skipFrames = true;
			
			_gui = new SimpleGUI(this, "Settings", "C");
			_gui.addColumn("Settings");
			//_gui.addSlider("scene.IPD", -2, 2, {label:'IPD'});
			_gui.addSlider("scene.textureScale", 0.5, 1.5, {label:'input texture size factor'});
			_gui.addToggle("scene.lowPersistence", {label:'lowPersistence'});
			_gui.addToggle("scene.useTimewarp", {label:"useTimewarp, 'G' to pause rendering"});
			_gui.show();
			
			//scene.addChildFromFile("tuscany_stripped_inverse.zf3d");
			scene.addChildFromFile("tuscany_physics2.zf3d");

			scene.addEventListener( Scene3D.COMPLETE_EVENT, completeEvent );
			
			var stats:Stats = new Stats();
			addChild(stats);
			
			scene.pause();
		}
		
		private function completeEvent(e:Event = null):void 
		{
			trace( "OculusTest.completeEvent > e : " + e );
			scene.addEventListener( Scene3D.UPDATE_EVENT, updateEvent );
			
			// the culling system may be affected by the custom projection.
			// we need to disable it for now, but this needs to be fixed.
			//var meshes:Vector.<Pivot3D> = scene.getChildrenByClass( Mesh3D );
			//for each ( var m:Mesh3D in meshes ) {
				//m.bounds = null;
			//}
			
			_playerModel = scene.getChildByName("player");
			_playerModel.collider.constrainLocalRotation(0, 0, 0);
			_playerModel.collider.isRigidBody = true;
			_playerModel.collider.friction = 1;
			
			//scene.camera.setPosition(5, 3, 1);
			//scene.camera.lookAt(_playerModel.x, _playerModel.y, _playerModel.z);
			scene.camera.setPosition(0, 0, 0);
			scene.camera.setRotation(0, 0, 0);
			
			_eyes = scene.getChildByName("eyes");
			_head = scene.getChildByName("head");
			
			_eyes.addChild(scene.camera);
			
			// the magic happens here
			scene.headRotationTarget = _eyes;
			scene.headPositionTarget = _eyes;
			
			// once the scene has been loaded, resume the render.
			scene.resume();
		}
		
		private function updateEvent(e:Event):void 
		{		
			if ( Input3D.keyHit( Input3D.F ) ) {
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
			
			if ( Input3D.keyDown( Input3D.UP ) ) _playerModel.translateZ( 0.05 );
			if ( Input3D.keyDown( Input3D.DOWN ) ) _playerModel.translateZ( -0.05 );
			if ( Input3D.keyDown( Input3D.LEFT ) ) _playerModel.rotateY( -1 );
			if ( Input3D.keyDown( Input3D.RIGHT ) ) _playerModel.rotateY( 1 );

			if ( Input3D.keyDown( Input3D.SPACE ) ) {
				_playerModel.collider.applyLocalImpulse( 0, 2, 0 );
			}
			
			if ( Input3D.keyHit( Input3D.G ) ) {
				scene.bRender = !scene.bRender;
			}
			
			if ( Input3D.keyDown( Input3D.R ) ) {
				_playerModel.setRotation( 0, 0, 0 );
				_playerModel.setPosition( 0, 10, 0 );
				_playerModel.collider.resetVelocities();
			}
			
			scene.physics.step( 3, 1 / 30 );
		}
				
	}
}