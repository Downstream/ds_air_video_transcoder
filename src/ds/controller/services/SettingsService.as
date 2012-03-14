package ds.controller.services
{
	import ds.controller.events.AppEvent;
	import ds.controller.events.SelectDirectoryEvent;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class SettingsService extends EventDispatcher
	{
		private var settingsXML:XML;
		private var preferencesFile:File;
		
		static private const preferencesPath:String = "downstream/video_transcoder/settings.xml";
		public function SettingsService(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function loadSettings():void{
			if(!File.documentsDirectory.resolvePath("downstream/video_transcoder").exists) File.documentsDirectory.resolvePath("downstream/video_transcoder").createDirectory();
			preferencesFile = File.documentsDirectory;
			preferencesFile = preferencesFile.resolvePath(preferencesPath);
			if(preferencesFile.exists){
				var preferencesFilestream:FileStream = new FileStream();
				preferencesFilestream.open(preferencesFile, FileMode.READ);
				settingsXML = XML(preferencesFilestream.readUTFBytes(preferencesFilestream.bytesAvailable));
				preferencesFilestream.close();
				
				if(settingsXML.watch_dir != "NULL"){
					dispatchEvent(new SelectDirectoryEvent(SelectDirectoryEvent.WATCH_SELECTED, settingsXML.watch_dir));
				}
				if(settingsXML.output_dir != "NULL"){
					dispatchEvent(new SelectDirectoryEvent(SelectDirectoryEvent.OUTPUT_SELECTED, settingsXML.output_dir));
				}
				if(settingsXML.start_quiet == "true"){
					dispatchEvent(new AppEvent(AppEvent.START_QUIET));
				}
				
			} else {
				preferencesFile = File.documentsDirectory;
				preferencesFile = preferencesFile.resolvePath(preferencesPath);
				settingsXML = 
					<settings>
						<watch_dir>NULL</watch_dir>
						<output_dir>NULL</output_dir>
						<start_quiet>false</start_quiet>
					</settings>;
				saveXML();
			}
		}
		
		public function setOutputDir(path:String):void {
			if(!settingsXML) return;
			settingsXML.output_dir = path;
			saveXML();
		}
		
		public function setWatchDir(path:String):void {
			if(!settingsXML) return;
			settingsXML.watch_dir = path;
			saveXML();
		}
		
		private function saveXML():void {
			var stream:FileStream = new FileStream();
			stream.open(preferencesFile, FileMode.WRITE);
			stream.writeUTFBytes(settingsXML.toXMLString());
			stream.close();
		}
	}
}