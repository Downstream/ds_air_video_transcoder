package ds.view
{
	import ds.controller.events.TranscodeProgressEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class ProgressMediator extends Mediator
	{
		[Inject]
		public var view:ProgressView;
		public function ProgressMediator()
		{
			super();
		}
		
		override public function onRegister():void {
			addContextListener(TranscodeProgressEvent.TRANSCODE_START, transcodeStart, TranscodeProgressEvent);
			addContextListener(TranscodeProgressEvent.TRANSCODE_PROGRESS, transcodeProgress, TranscodeProgressEvent);			
			addContextListener(TranscodeProgressEvent.TRANSCODE_COMPLETE, transcodeComplete, TranscodeProgressEvent);
			addContextListener(TranscodeProgressEvent.TRANSCODE_ERROR, transcodeError, TranscodeProgressEvent);
		}
		
		override public function onRemove():void {
			if(view) view.destroy();
			removeContextListener(TranscodeProgressEvent.TRANSCODE_START, transcodeStart, TranscodeProgressEvent);
			removeContextListener(TranscodeProgressEvent.TRANSCODE_PROGRESS, transcodeProgress, TranscodeProgressEvent);			
			removeContextListener(TranscodeProgressEvent.TRANSCODE_COMPLETE, transcodeComplete, TranscodeProgressEvent);
			removeContextListener(TranscodeProgressEvent.TRANSCODE_ERROR, transcodeError, TranscodeProgressEvent);

		}
		
		private function transcodeStart(e:TranscodeProgressEvent):void {
			if(view) view.transcodeStart(e.targetFile);
		}
		
		private function transcodeProgress(e:TranscodeProgressEvent):void {			
			if(view) view.transcodeProgress(e.progressPercent);
		}
		
		private function transcodeComplete(e:TranscodeProgressEvent):void {
			if(view) view.transcodeComplete(e.targetFile);
		}
		
		private function transcodeError(e:TranscodeProgressEvent):void {
			if(view) view.transcodeError(e.targetFile);
			
		}
	}
}