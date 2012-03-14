package ds.controller.events
{
	import ds.model.value.FileVO;
	
	import flash.events.Event;
	
	public class TranscodeProgressEvent extends Event
	{
		public static const TRANSCODE_START:String = "transcodeStart";
		public static const TRANSCODE_PROGRESS:String = "progress";
		public static const TRANSCODE_COMPLETE:String = "transcodeComplete";
		public static const TRANSCODE_ERROR:String = "transcodeError";
		
		public var progressPercent:Number;
		public var targetFile:FileVO;
		
		public function TranscodeProgressEvent(type:String, file:FileVO, progress:Number = 0.0)
		{
			progressPercent = progress;
			targetFile = file;
			super(type);
		}
		
		override public function clone():Event {
			return new TranscodeProgressEvent(type, targetFile, progressPercent);
		}
	}
}