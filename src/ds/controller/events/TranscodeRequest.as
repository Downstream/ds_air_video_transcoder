package ds.controller.events
{
	import ds.model.value.FileVO;
	
	import flash.events.Event;
	
	public class TranscodeRequest extends Event
	{
		public static const TRANSCODE_FILES:String = "transcodeFiles";
		public static const CANCEL_TRANSCODE:String = "cancleTranscode";
		
		public var filePaths:Vector.<FileVO>;
		
		public function TranscodeRequest(type:String, files:Vector.<FileVO>)
		{
			filePaths = files;
			super(type);
		}
		
		override public function clone():Event {
			return new TranscodeRequest(type, filePaths);
		}
	}
}