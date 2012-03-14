package ds.controller.commands
{
	import ds.controller.TranscoderController;
	import ds.controller.events.AppEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class AppCommand extends Command
	{
		[Inject]
		public var controller:TranscoderController;
		
		[Inject]
		public var event:AppEvent;
		
		public function AppCommand()
		{
		}
		
		override public function execute():void {
			if(event.type == AppEvent.APP_EXITING){
				controller.exitApp(event);
			} else if(event.type == AppEvent.STARTUP_COMPLETE){
				controller.appStartup(event);
			}
		}
	}
}