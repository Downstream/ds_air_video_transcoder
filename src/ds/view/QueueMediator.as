package ds.view
{
	import ds.controller.events.SelectDirectoryEvent;
	import ds.controller.events.TranscodeProgressEvent;
	import ds.controller.events.TranscodeRequest;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class QueueMediator extends Mediator
	{
		[Inject]
		public var view:QueueView;
		public function QueueMediator()
		{
			super();
		}
		
		override public function onRegister():void {
			addContextListener(TranscodeRequest.TRANSCODE_FILES, transcodeFiles, TranscodeRequest);
			addContextListener(TranscodeProgressEvent.TRANSCODE_START, transcodeStart, TranscodeProgressEvent);
			addContextListener(TranscodeProgressEvent.TRANSCODE_COMPLETE, transcodeComplete, TranscodeProgressEvent);
			addContextListener(TranscodeProgressEvent.TRANSCODE_ERROR, transcodeError, TranscodeProgressEvent);
			addContextListener(SelectDirectoryEvent.OUTPUT_SELECTED, outputSelected, SelectDirectoryEvent);
			
			addViewListener(TranscodeRequest.CANCEL_TRANSCODE, cancelTranscode, TranscodeRequest);
		}
		
		override public function onRemove():void {
			
		}
		
		private function outputSelected(e:SelectDirectoryEvent):void {
			if(view) view.outputSelected(e.path);
		}
		
		private function transcodeFiles(e:TranscodeRequest):void {
			if(view) view.addFiles(e.filePaths);
		}
		private function transcodeStart(e:TranscodeProgressEvent):void {
			if(view) view.startTranscode(e.targetFile);
		}
		private function transcodeComplete(e:TranscodeProgressEvent):void {
			if(view) view.transcodeComplete(e.targetFile);
		}
		private function transcodeError(e:TranscodeProgressEvent):void {
			if(view) view.transcodeError(e.targetFile);	
		}
		
		private function cancelTranscode(e:TranscodeRequest):void {
			dispatch(e);
		}
	}
}