package ds.controller
{
	import ds.controller.events.AppEvent;
	import ds.controller.events.SelectDirectoryEvent;
	import ds.controller.events.TranscodeProgressEvent;
	import ds.controller.events.TranscodeRequest;
	import ds.controller.services.CacheService;
	import ds.controller.services.SettingsService;
	import ds.controller.services.TranscoderService;
	import ds.model.value.FileVO;
	
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	
	import org.robotlegs.mvcs.Actor;
	
	public class TranscoderController extends Actor
	{
		private var transcodeService:TranscoderService;
		private var settingsService:SettingsService;
		private var cacheService:CacheService;
		public function TranscoderController()
		{
			super();
			transcodeService = new TranscoderService();
			transcodeService.addEventListener(TranscodeProgressEvent.TRANSCODE_ERROR, transcodeProgress);
			transcodeService.addEventListener(TranscodeProgressEvent.TRANSCODE_PROGRESS, transcodeProgress);
			transcodeService.addEventListener(TranscodeProgressEvent.TRANSCODE_START, transcodeProgress);
			transcodeService.addEventListener(TranscodeProgressEvent.TRANSCODE_COMPLETE, transcodeProgress);
			
			settingsService = new SettingsService();
			settingsService.addEventListener(SelectDirectoryEvent.WATCH_SELECTED, selectDirEvent);
			settingsService.addEventListener(SelectDirectoryEvent.OUTPUT_SELECTED, selectDirEvent);
			settingsService.addEventListener(AppEvent.START_QUIET, quietStart);
			
			cacheService = new CacheService();
			cacheService.addEventListener(TranscodeRequest.TRANSCODE_FILES, transcodeRequestHandler);
		}
		
		public function transcodeFiles(files:Vector.<FileVO>):void{
			for each(var fvo:FileVO in files){
				transcodeService.transcode(fvo);
			}
		}
		
		public function cancelTranscode(files:Vector.<FileVO>):void {
			for each(var fvo:FileVO in files){
				transcodeService.cancelTranscode(fvo);
			}
		}
		
		public function appStartup(e:AppEvent):void {
			settingsService.loadSettings();
		}
		
		public function exitApp(e:AppEvent):void {
			transcodeService.appExit();
			NativeApplication.nativeApplication.exit(0);
		}
		
		public function transcodeProgress(e:TranscodeProgressEvent):void {
			dispatch(e);
			if(e.type == TranscodeProgressEvent.TRANSCODE_COMPLETE){
				cacheService.transcodeComplete(e.targetFile.filePath);
			} else if(e.type == TranscodeProgressEvent.TRANSCODE_ERROR){
				cacheService.transcodeError(e.targetFile.filePath);
			}
		}
		
		private function selectDirEvent(e:SelectDirectoryEvent):void {
			dispatch(e);
		}
		
		private function quietStart(e:AppEvent):void {
			dispatch(e);
		}
		
		public function setOutputDirectory(dir:String):void {
			settingsService.setOutputDir(dir);
			transcodeService.setDestinationPath(dir);
		}
		
		public function setWatchDirectory(dir:String):void {
			settingsService.setWatchDir(dir);
			cacheService.setWatchDirectory(dir);
		}
		
		private function transcodeRequestHandler(e:TranscodeRequest):void {
			dispatch(e);
		}
	}
}