package ds
{
	import ds.app.UpdateableApplication;
	import ds.controller.TranscoderController;
	import ds.controller.commands.AppCommand;
	import ds.controller.commands.SelectDirectoryCommand;
	import ds.controller.commands.TranscodeCommand;
	import ds.controller.events.AppEvent;
	import ds.controller.events.SelectDirectoryEvent;
	import ds.controller.events.TranscodeRequest;
	import ds.view.BackgroundMediator;
	import ds.view.BackgroundView;
	import ds.view.ProgressMediator;
	import ds.view.ProgressView;
	import ds.view.QueueMediator;
	import ds.view.QueueView;
	import ds.view.SelectFilesMediator;
	import ds.view.SelectFilesView;
	import ds.view.SelectWatchMediator;
	import ds.view.SelectWatchView;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.DisplayObjectContainer;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.InvokeEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.system.Capabilities;
	
	import mx.core.Window;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.mvcs.Context;
	
	public class TranscoderContext extends Context
	{
		private var progressView:ProgressView;
		private var backgroundView:BackgroundView;
		private var selectSingleView:SelectFilesView;
		private var selectWatchView:SelectWatchView;
		private var queueView:QueueView;
		
		private var quietStart:Boolean = false;
		
		private var appWindow:NativeWindow;
		public function TranscoderContext(contextView:DisplayObjectContainer=null, autoStartup:Boolean=true)
		{
			super(contextView, autoStartup);
		}
		
		override public function startup():void
		{
			commandMap.mapEvent(AppEvent.STARTUP_COMPLETE, AppCommand, AppEvent);
			commandMap.mapEvent(AppEvent.APP_EXITING, AppCommand, AppEvent);
			commandMap.mapEvent(TranscodeRequest.TRANSCODE_FILES, TranscodeCommand, TranscodeRequest);
			commandMap.mapEvent(TranscodeRequest.CANCEL_TRANSCODE, TranscodeCommand, TranscodeRequest);
			commandMap.mapEvent(SelectDirectoryEvent.OUTPUT_SELECTED, SelectDirectoryCommand, SelectDirectoryEvent);
			commandMap.mapEvent(SelectDirectoryEvent.WATCH_SELECTED, SelectDirectoryCommand, SelectDirectoryEvent);
			
			injector.mapSingleton(TranscoderController);
			
			mediatorMap.mapView(BackgroundView, BackgroundMediator);
			mediatorMap.mapView(ProgressView, ProgressMediator);
			mediatorMap.mapView(SelectFilesView, SelectFilesMediator);
			mediatorMap.mapView(SelectWatchView, SelectWatchMediator);
			mediatorMap.mapView(QueueView, QueueMediator);
			
			var nw:NativeWindow = NativeApplication.nativeApplication.openedWindows[0];
			nw.close();
			
			newWindow(true);
			super.startup();

			addEventListener(AppEvent.START_QUIET, startQuiet, false, 0, true);
			dispatchEvent(new AppEvent(AppEvent.STARTUP_COMPLETE));
			
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, appInvoke);
			
			if(quietStart){
				appWindow.close();
			} else {
				appWindow.visible = true;
			}
		}
		
		private function startQuiet(e:Event):void {
			quietStart = true;
		}
		
		private function newWindow(initial:Boolean = false):void {
			var initOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
			initOptions.maximizable = true;
			initOptions.minimizable = true;
			initOptions.resizable = true;
			initOptions.systemChrome = NativeWindowSystemChrome.STANDARD;
			initOptions.type = NativeWindowType.NORMAL;
			
			var newWin:NativeWindow = new NativeWindow(initOptions);
			newWin.visible = false;
			newWin.stage.align = StageAlign.TOP_LEFT;
			newWin.stage.scaleMode = StageScaleMode.NO_SCALE;
			newWin.width = 1000;
			newWin.height = 600;
			newWin.minSize = new Point(700, 600);
			newWin.addEventListener(Event.CLOSING, windowClosing, false, 0, true);
			newWin.stage.addChild(contextView);
			
			if(!backgroundView) backgroundView = new BackgroundView();
			contextView.addChild(backgroundView);
			if(!progressView) progressView = new ProgressView();
			contextView.addChild(progressView);
			if(!selectWatchView) selectWatchView = new SelectWatchView();
			contextView.addChild(selectWatchView);
			if(!selectSingleView) selectSingleView = new SelectFilesView();
			contextView.addChild(selectSingleView);
			if(!queueView) queueView = new QueueView();
			contextView.addChild(queueView);
			
			if(!initial){
				newWin.visible = true;
				newWin.activate();
			}
			appWindow = newWin;
		}
		
		private function windowClosing(e:Event):void {
			// remove views here
			if(appWindow) appWindow.removeEventListener(Event.CLOSING, windowClosing);
			appWindow = null;
		}
		
		private function appInvoke(e:InvokeEvent):void {
			if(quietStart){
				quietStart = false;
				return;
			}
			if(!appWindow) newWindow();
		}
	}
}