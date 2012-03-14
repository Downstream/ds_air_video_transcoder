package ds.view
{
	import ds.controller.events.SelectDirectoryEvent;
	import ds.controller.events.TranscodeRequest;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class SelectFilesMediator extends Mediator
	{
		[Inject]
		public var view:SelectFilesView;
		
		public function SelectFilesMediator()
		{
			super();
		}
		
		override public function onRegister():void {
			addViewListener(TranscodeRequest.TRANSCODE_FILES, transcodeSingle, TranscodeRequest);
			addViewListener(SelectDirectoryEvent.OUTPUT_SELECTED, outputSelected, SelectDirectoryEvent);
		}
		
		private function transcodeSingle(e:TranscodeRequest):void {
			dispatch(e);
		}
		
		private function outputSelected(e:SelectDirectoryEvent):void {
			dispatch(e);
		}
	}
}