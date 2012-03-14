package ds.controller.services
{
	import ds.app.QueryEvent;
	import ds.app.SQLQuery;
	import ds.controller.events.TranscodeRequest;
	import ds.model.value.FileVO;
	
	import flash.data.SQLMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	
	public class CacheService extends EventDispatcher
	{
		private var initSql:SQLQuery;
		private var cacheSql:SQLQuery;
		private var writeQuery:SQLQuery;
		private var cachedFiles:Vector.<FileVO> = new Vector.<FileVO>;
		private var watchDirectory:String = "NULL";
		
		private var checkTimer:Timer;
		
		private var sqlPath:String = "downstream/video_transcoder/file_cache.sqlite";
		
		private var invalidExtensions:Vector.<String> = new Vector.<String>;
		
		public function CacheService()
		{
			invalidExtensions.push("db","sqlite","pdf","doc");
			super();
			
			createDb();
			
			var f:File = new File();
			initSql = new SQLQuery( File.documentsDirectory.resolvePath(sqlPath).nativePath, false);
			initSql.addEventListener(QueryEvent.LOAD_ERROR, sqError, false, 0, true);
			initSql.addEventListener(QueryEvent.LOAD_COMPLETE, startUpWatchDir, false, 0, true);
			initSql.addEventListener(IOErrorEvent.IO_ERROR, sqError, false, 0, true);
			initSql.setOpenMode(SQLMode.UPDATE);
			
			cacheSql = new SQLQuery( File.documentsDirectory.resolvePath(sqlPath).nativePath, false);
			cacheSql.addEventListener(QueryEvent.LOAD_ERROR, sqError, false, 0, true);
			cacheSql.addEventListener(QueryEvent.LOAD_COMPLETE, cacheLoaded, false, 0, true);
			cacheSql.addEventListener(IOErrorEvent.IO_ERROR, sqError, false, 0, true);
			cacheSql.setOpenMode(SQLMode.UPDATE);
			
			writeQuery = new SQLQuery( File.documentsDirectory.resolvePath(sqlPath).nativePath, false);
			writeQuery.addEventListener(QueryEvent.LOAD_ERROR, sqError, false, 0, true);
			writeQuery.addEventListener(IOErrorEvent.IO_ERROR, sqError, false, 0, true);
			writeQuery.setOpenMode(SQLMode.UPDATE);
			//writeQuery.setSynchronous(false);
			
			initSql.getAllFromTable("WatchDir");
		}
		
		private function createDb():void {
			var createSql:SQLQuery = new SQLQuery( File.documentsDirectory.resolvePath(sqlPath).nativePath, false, SQLMode.CREATE);
			createSql.addEventListener(QueryEvent.LOAD_ERROR, sqError, false, 0, true);
			createSql.addEventListener(IOErrorEvent.IO_ERROR, sqError, false, 0, true);
			createSql.query( "CREATE TABLE IF NOT EXISTS WatchDir (WatchID INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , WatchPath TEXT)");
			createSql.query( "CREATE TABLE IF NOT EXISTS Files (FileID INTEGER PRIMARY KEY  NOT NULL ,FilePath TEXT,FileModified TEXT,FileName TEXT,Complete BOOL)");
			createSql.removeEventListener(QueryEvent.LOAD_ERROR, sqError);
			createSql.removeEventListener(IOErrorEvent.IO_ERROR, sqError);
		}
		
		public function setWatchDirectory(path:String):void {
			if(checkTimer){
				checkTimer.stop();
				checkTimer.removeEventListener(TimerEvent.TIMER, checkTimerHandler);
				checkTimer = null;
			}
			// if we're switching or clearing the path, clear the cache
			// if the path is the same as the old path, keep the cache and check the directory
			if(!path) path = "NULL";
			if(path == "NULL" || watchDirectory != path){
				cachedFiles.splice(0,cachedFiles.length);
				cachedFiles = null;
				cachedFiles = new Vector.<FileVO>;
				cacheSql.query("DELETE FROM Files");	
				cacheSql.query("DELETE FROM WatchDir");
				cacheSql.query("INSERT INTO WatchDir (WatchPath) VALUES ('" + path + "')");
			}
			watchDirectory = path;
			if(watchDirectory != "NULL"){
				scanDirectory(watchDirectory);
				checkTimer = new Timer(2000);
				checkTimer.addEventListener(TimerEvent.TIMER, checkTimerHandler, false, 0, true);
				checkTimer.reset();
				checkTimer.start();
			}
		}
		
		private function sqError(e:Event):void {
			trace(e);
		}
		
		// this sets the watch directory that the sql is pointed at
		// when startup finishes, the xml watch dir is checked against this one
		// if there's not a match, the cache is cleared.
		private function startUpWatchDir(e:QueryEvent):void {
			if(e.data && e.data.length > 0){
				watchDirectory = e.data[0].WatchPath;
			}
			cacheSql.getAllFromTable("Files", null);
		}
		
		private function cacheLoaded(e:QueryEvent):void {
			if(!e.data || e.data.length < 1) return;
			cachedFiles.splice(0, cachedFiles.length);
			cachedFiles = null;
			cachedFiles = new Vector.<FileVO>;
			for(var i:int = 0; i < e.data.length; i++){
				var fvo:FileVO = new FileVO(e.data[i].FileName, e.data[i].FilePath);
				fvo.fileModDate = e.data[i].FileModified;
				fvo.transcodeComplete = e.data[i].Complete;
				cachedFiles.push(fvo);
			}
		}
		
		private function scanDirectory(path:String):void {
			var file:File = new File(path);
			if(!file.exists || !file.isDirectory) return;
			var files:Array = file.getDirectoryListing();
			for(var i:int = 0; i < files.length; i++){
				var fi:File = files[i] as File;
				if(fi.isDirectory){
					scanDirectory(fi.nativePath);
				} else {
					if(checkAgainstCache(fi.nativePath, fi.modificationDate)) continue;
					addFile(fi);
				}
			}
		}
		
		// YYYY-MM-DD hh:mm:ss
		// or YYYY-M-D h:m:s
		// this function does not add leading zeros
		private function dateToString(date:Date):String {
			var retStr:String = date.getFullYear() + "-" + date.getUTCMonth() + "-" + date.getDate() + " " 
				+ date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
			return retStr;
		}
		
		// returns true if this file has already been converted
		private function checkAgainstCache(path:String, modDate:Date):Boolean {
			for each(var fvo:FileVO in cachedFiles){
				if(fvo.filePath == path && dateToString(modDate) == fvo.fileModDate){
					return true;
				}	
			}
			return false;
		}
		
		// adds a file to the cache and dispatches an event to transcode it
		private function addFile(file:File):void {
			if(!validateExtension(file.extension)) return;
			writeQuery.query("INSERT INTO Files (FilePath, FileModified, FileName, Complete) VALUES ('" + file.nativePath + "','" + dateToString(file.modificationDate) + "','" + file.name + "', 0)");
			var fv:Vector.<FileVO> = new Vector.<FileVO>;
			var fvo:FileVO = new FileVO(file.name, file.nativePath);
			fvo.fileModDate = dateToString(file.modificationDate);
			fv.push( fvo );
			cachedFiles.push(fvo);
			dispatchEvent(new TranscodeRequest(TranscodeRequest.TRANSCODE_FILES, fv));
		}
		
		private function validateExtension(extension:String):Boolean {
			for each(var s:String in invalidExtensions){
				if(s == extension) return false;
			}
			return true;
		}
		
		public function transcodeComplete(path:String):void {
			writeQuery.query("UPDATE Files SET Complete = 1 WHERE FilePath = '" + path + "'");
		}
		
		public function transcodeError(path:String):void {
			writeQuery.query("DELETE FROM Files WHERE FilePath = '" + path + "'");
		}
		
		private function checkTimerHandler(e:TimerEvent):void {
			scanDirectory(watchDirectory);
		}
	}
}