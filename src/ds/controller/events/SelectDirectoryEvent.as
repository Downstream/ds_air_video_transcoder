package ds.controller.events
{
	import flash.events.Event;
	
	public class SelectDirectoryEvent extends Event
	{
		public static const OUTPUT_SELECTED:String = "outputSelected";
		public static const WATCH_SELECTED:String = "watchSelected";
		
		public var path:String;
		public function SelectDirectoryEvent(type:String, outputPath:String)
		{
			path = outputPath;
			super(type);
		}
		
		override public function clone():Event {
			return new SelectDirectoryEvent(type, path);
		}
	}
}