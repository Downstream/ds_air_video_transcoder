package ds.controller.commands
{
	import ds.controller.TranscoderController;
	import ds.controller.events.SelectDirectoryEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class SelectDirectoryCommand extends Command
	{
		[Inject]
		public var controller:TranscoderController;
		
		[Inject]
		public var event:SelectDirectoryEvent;
		public function SelectDirectoryCommand()
		{
			super();
		}
		
		override public function execute():void {
			if(event.type == SelectDirectoryEvent.OUTPUT_SELECTED){
				controller.setOutputDirectory(event.path);
			} else if(event.type == SelectDirectoryEvent.WATCH_SELECTED){
				controller.setWatchDirectory(event.path);
			}
		}
	}
}