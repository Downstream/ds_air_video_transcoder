package ds.controller.events
{
	import flash.events.Event;
	
	public class AppEvent extends Event
	{
		public static const STARTUP_COMPLETE:String = "startupComplete";
		public static const APP_EXITING:String = "appExiting";
		public static const START_QUIET:String = "startQuiet";
		public function AppEvent(type:String)
		{
			super(type);
		}
		
		override public function clone():Event {
			return new AppEvent(type);
		}
	}
}