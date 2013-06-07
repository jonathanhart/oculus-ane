package be.but.joystick 
{
	import be.but.oculus.OculusSetup;
	import extension.JoyQuery.Joystick;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Fragilem17
	 */
	public class JoystickHelper extends EventDispatcher 
	{
		static public const EVT_BUTTON_DOWN:String = "evtButtonDown";
		
		private static var _instance:JoystickHelper = null;
		private static var _joy:Joystick;
		
		private static var _currentValue:Number;
		
		public static var available:Boolean = false;
		public static var totalAxes:int;
		public static var totalButtons:Number;
	
		public static var axisValues:Vector.<Number> = new Vector.<Number>;
		public static var buttonIsDownStates:Vector.<Boolean> = new Vector.<Boolean>;

		public function JoystickHelper(caller:Function = null)
		{
			if (caller != preventCreation) {
				throw new Error("Creation of JoystickHelper without calling sharedInstance is not valid");
			}else {
				// constructor
				trace("JoyStick Constructed");
				_joy = new Joystick();
				initialise();
				OculusSetup.instance.addEnterFrameHandler(onEnterFrame);
			}
			
		}
		
		private static function preventCreation():void {
		}
	 
		public static function sharedInstance():JoystickHelper {
			if (_instance == null) {
				_instance = new JoystickHelper(preventCreation);
			}
	 
			return _instance;
		}
		
		private function initialise():void 
		{			
			_joy.JoyQuery();
			
			//Check is there are any joysticks connected.
			if(_joy.getTotal() < 1)
			{
				trace("No joystick detected.");
				return;
			}
			
			available = true;
			
			totalAxes = _joy.getTotalAxes(0);
			totalButtons = _joy.getTotalButtons(0);
			
			axisValues.length = totalAxes;
			buttonIsDownStates.length = totalButtons;
		}
		
		private function onEnterFrame():void
		{
			//Update the joystick states.
			_joy.JoyQuery();
			
			var i:int;
			for(i = 0; i < totalAxes; i++)
			{
				axisValues[i] = _joy.getAxis(0, i);
			}
			
			var prevState:Boolean;
			for(i = 0; i < totalButtons; i++)
			{
				prevState = buttonIsDownStates[i];
				//trace("Btn" + i + ": " + _joy.buttonIsDown(0, i));
				buttonIsDownStates[i] = _joy.buttonIsDown(0, i);
				if (prevState != buttonIsDownStates[i]) {
					dispatchEvent(new Event(EVT_BUTTON_DOWN));
				}
			}
			
			/*
			//Loop through all the joysticks, axes, and buttons and output their states to the text field.
			var output:String = "";
			for(var i:int = 0; i < joy.getTotal(); i++)
			{
				var i2:int;
				output += "Joystick " + i + ":\n\t";
				for(i2 = 0; i2 < joy.getTotalAxes(i); i2++)
				{
					output += "Axes" + i2 + ": " + joy.getAxis(i, i2) + "   ";
				}
				output += "\n\t";
				for(i2 = 0; i2 < joy.getTotalButtons(i); i2++)
				{
					output += "Btn" + i2 + ": " + joy.buttonIsDown(i, i2) + "   ";
				}
				output += "\n";					
			}
			newText(output);
			*/
		}
	}

}