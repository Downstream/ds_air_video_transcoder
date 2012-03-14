package ds.controller.services
{
	import ds.controller.events.TranscodeProgressEvent;
	import ds.model.value.FileVO;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	public class TranscoderService extends EventDispatcher
	{
		private var processTranscode:NativeProcess;
		private var processInfo:NativeProcess;
		private var destinationPath:String;
		private var destinationPathSet:Boolean = false;
		private var requestQueue:Vector.<FileVO> = new Vector.<FileVO>;
		private var curFile:FileVO;
		private var processing:Boolean = false;
		public function TranscoderService()
		{
			processInfo = new NativeProcess();
			processInfo.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onInfoOutput);
			processInfo.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onInfoError);
			processInfo.addEventListener(NativeProcessExitEvent.EXIT, onInfoExit);
			processInfo.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
			processInfo.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError);
			
			processTranscode = new NativeProcess();
			processTranscode.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			processTranscode.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData);
			processTranscode.addEventListener(NativeProcessExitEvent.EXIT, onExit);
			processTranscode.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
			processTranscode.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError);
			
			var fileDest:File = File.documentsDirectory.resolvePath("downstream/encoded_videos");
			fileDest.createDirectory();
			destinationPath = fileDest.nativePath;
			super();
		}
		
		public function setDestinationPath(destPath:String):void {
			destinationPath = destPath;
			if(destPath && destPath != "NULL"){
				destinationPathSet = true;
				checkQueue();
			}
		}
		
		public function transcode(target:FileVO):void {
			if(curFile && target.filePath == curFile.filePath){
				return;
			}
			for each(var fvo:FileVO in requestQueue){
				if(fvo.filePath == target.filePath){
					return;
				}
			}
			requestQueue.push(target);
			checkQueue();
		}
		
		public function cancelTranscode(target:FileVO):void {
			for each(var fvo:FileVO in requestQueue){
				if(target.filePath == fvo.filePath){
					requestQueue.splice(requestQueue.indexOf(fvo), 1);
				}
			}
			if(target.filePath == curFile.filePath){
				if(processInfo.running) processInfo.exit(true);
				if(processTranscode.running) processTranscode.exit(true);
				dispatchEvent(new TranscodeProgressEvent(TranscodeProgressEvent.TRANSCODE_ERROR, curFile, 1.0));
				checkQueue();
			}
		}
		
		private function checkQueue():void{
			if(destinationPathSet && !processing && requestQueue.length > 0){
				curFile = requestQueue[0];
				requestQueue.shift();
				getCurFileInfo();
			}
		}
		
		private function getCurFileInfo():void {
			var ffmpeg:File = File.applicationDirectory.resolvePath("assets/ffprobe.exe");
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = ffmpeg;			
			// ffprobe -show_streams -pretty -sexagesimal -pretty -print_format compact -i \"" + path  + "\" 2>&1"; 
			var processArgs:Vector.<String> = new Vector.<String>;
			processArgs.push("-show_streams");
			processArgs.push("-pretty");
			processArgs.push("-sexagesimal");
			processArgs.push("-pretty");
			processArgs.push("-print_format");
			processArgs.push("compact");
			//processArgs.push("-count_frames");
			processArgs.push("-i");
			processArgs.push(curFile.filePath);
			nativeProcessStartupInfo.arguments = processArgs;
			
			processInfo.start(nativeProcessStartupInfo);
			processing = true;
		}
		
		private function onInfoOutput(event:ProgressEvent):void {
			var retStr:String = processInfo.standardOutput.readUTFBytes(processInfo.standardOutput.bytesAvailable);
			var vidSection:int = retStr.indexOf("codec_type=video");
			if(vidSection < 0) vidSection = 0;
			var width:int = int(parseVariable("width=", "|", retStr, vidSection));
			var height:int = int(parseVariable("height=", "|", retStr, vidSection));
			var frames:int = int(parseVariable("nb_frames=", "|", retStr, vidSection));
			var duration:String = parseVariable("duration=", "|", retStr, vidSection);
			var hours:Number = int(duration.substr(0,1));
			var minutes:Number = int(duration.substr(2,2));
			var seconds:Number = Number(duration.substr(5));
			var dur:Number = (hours * 60 * 60) + (minutes * 60) + seconds;
			if(int(frames) < 1){
				var rate:String = parseVariable("r_frame_rate=","|", retStr, vidSection);
				var rateNum:Number = Number(rate);
				if(!rateNum || rateNum < 0){
					var rateUp:Number = Number(rate.substr(0, rate.indexOf("/")));
					var rateDown:Number = Number(rate.substr(rate.indexOf("/") + 1));
					rateNum = rateUp / rateDown;
				}
				frames = (dur * rateNum);

			}
			curFile.vidDuration = dur;
			curFile.vidFrames = frames;
			curFile.vidHeight = height;
			curFile.vidWidth = width;
		}
		
		private function parseVariable(varName:String,breakChar:String, stringToParse:String, startSearchAt:int = 0):String{
			var pos:int = stringToParse.indexOf(varName, startSearchAt);
			if(pos > -1){
				var output:String = stringToParse.substr(pos+varName.length);
				pos = output.indexOf(breakChar);
				if(pos > -1){
					output = output.substr(0, pos);
					return output;
				}
			}
			return "";
		}
		
		private function onInfoError(event:ProgressEvent):void {
			//dispatchEvent(new TranscodeProgressEvent(TranscodeProgressEvent.PROGRESS, 0.0, curFile.fileName));
			//trace("ERROR -", processInfo.standardError.readUTFBytes(processInfo.standardError.bytesAvailable)); 
		}
		
		private function onInfoExit(event:NativeProcessExitEvent):void {
			transcodeCurFile();
		}
		
		private function transcodeCurFile():void{				
			var ffmpeg:File = File.applicationDirectory.resolvePath("assets/ffmpeg.exe");
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = ffmpeg;			
			
			var processArgs:Vector.<String> = new Vector.<String>;
			processArgs.push("-y");
			processArgs.push("-i");
			processArgs.push(curFile.filePath);
			processArgs.push("-acodec");
			processArgs.push("libvo_aacenc");
			processArgs.push("-ar");
			processArgs.push("44100");
			processArgs.push("-ab");
			processArgs.push("160k");
			processArgs.push("-coder");
			processArgs.push("ac");				
			processArgs.push("-vcodec");
			processArgs.push("libx264");		
			processArgs.push("-g");		
			processArgs.push("12");		
			processArgs.push("-level");		
			processArgs.push("5.1");
			processArgs.push(destinationPath + "\\" + curFile.fileName + ".mp4");
			nativeProcessStartupInfo.arguments = processArgs;
			
			processTranscode.start(nativeProcessStartupInfo);
			processing = true;
			dispatchEvent(new TranscodeProgressEvent(TranscodeProgressEvent.TRANSCODE_START, curFile, 0.0));
		}
		
		private function onOutputData(event:ProgressEvent):void {
			//trace("Got: ", processTranscode.standardOutput.readUTFBytes(processTranscode.standardOutput.bytesAvailable)); 
		}
		
		// FFprobe sends output to the error stream by default
		private function onErrorData(event:ProgressEvent):void {
			if(!processTranscode || !processTranscode.running) return;
			var retStr:String = processTranscode.standardError.readUTFBytes(processTranscode.standardError.bytesAvailable);			
			var curFrame:int = int(parseVariable("frame=", " fps=", retStr));
			var curPercent:Number = curFrame / curFile.vidFrames;
			if(curPercent > 1.0) curPercent = 1.0;			
			if(curPercent > 0.0) dispatchEvent(new TranscodeProgressEvent(TranscodeProgressEvent.TRANSCODE_PROGRESS, curFile, curPercent));
		}
		
		private function onExit(event:NativeProcessExitEvent):void {
			if(event.exitCode == 0){
				dispatchEvent(new TranscodeProgressEvent(TranscodeProgressEvent.TRANSCODE_COMPLETE, curFile, 1.0));
			} else {
				dispatchEvent(new TranscodeProgressEvent(TranscodeProgressEvent.TRANSCODE_ERROR, curFile, 1.0));
			}
			processing = false;
			checkQueue();
		}
		
		private function onIOError(event:IOErrorEvent):void {
			trace(event.toString());
		}
		
		public function appExit():void {
			if(processInfo && processInfo.running){
				processInfo.exit(true);
			}
			if(processTranscode && processTranscode.running){
				processTranscode.exit(true);
			}
		}
	}
}