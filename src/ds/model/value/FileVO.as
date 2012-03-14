package ds.model.value
{
	public class FileVO
	{
		public var filePath:String;
		public var fileName:String;
		public var fileModDate:String;
		
		public var vidWidth:int;
		public var vidHeight:int;
		public var vidDuration:Number;
		public var vidFrames:int;
		
		public var transcodeComplete:Boolean = false;
		
		public function FileVO(theName:String, path:String)
		{
			fileName = theName;
			filePath = path;
		}
	}
}