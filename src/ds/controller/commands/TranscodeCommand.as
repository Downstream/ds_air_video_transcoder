package ds.controller.commands
{
	import ds.controller.TranscoderController;
	import ds.controller.events.TranscodeRequest;
	
	import org.robotlegs.mvcs.Command;
	
	public class TranscodeCommand extends Command
	{
		[Inject]
		public var controller:TranscoderController;
		
		[Inject]
		public var event:TranscodeRequest;
		
		public function TranscodeCommand()
		{
			super();
		}
		
		override public function execute():void {
			if(event.type == TranscodeRequest.TRANSCODE_FILES){
				controller.transcodeFiles(event.filePaths);
			} else if(event.type == TranscodeRequest.CANCEL_TRANSCODE){
				controller.cancelTranscode(event.filePaths);
			}
		}
	}
}