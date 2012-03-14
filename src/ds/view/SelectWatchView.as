package ds.view
{
	import ds.controller.events.SelectDirectoryEvent;
	import ds.view.components.LabelledButton;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class SelectWatchView extends Sprite
	{
		private var clearButton:LabelledButton;
		private var setDestinationButton:LabelledButton;
		private var sectionLabel:TextField = new TextField();
		private var sectionDescription:TextField = new TextField();
		private var watchDirectory:TextField = new TextField();
		private var textFormat:TextFormat = new TextFormat("TradeGothicBold", 24, 0xffffff);
		public function SelectWatchView()
		{
			super();
			textFormat.align = TextFormatAlign.LEFT;
			
			sectionLabel.autoSize = TextFieldAutoSize.LEFT;
			sectionLabel.selectable = false;
			sectionLabel.defaultTextFormat = textFormat;
			sectionLabel.embedFonts = true;
			sectionLabel.text = "Watch a folder";
			sectionLabel.setTextFormat(textFormat);
			sectionLabel.alpha = 0.5;
			
			textFormat.size = 12;
			sectionDescription.width = 300;
			sectionDescription.wordWrap = true;
			sectionDescription.multiline = true;
			sectionDescription.selectable = false;
			sectionDescription.defaultTextFormat = textFormat;
			sectionDescription.embedFonts = true;
			sectionDescription.text = "Select a folder to monitor and set the output folder above. When you add videos to that folder, they will automatically be converted and saved in the output directory.";
			sectionDescription.setTextFormat(textFormat);
			sectionDescription.alpha = 0.75;
			sectionDescription.mouseEnabled = false;
			
			watchDirectory.autoSize = TextFieldAutoSize.LEFT;
			watchDirectory.selectable = true;
			watchDirectory.defaultTextFormat = textFormat;
			watchDirectory.embedFonts = true;
			watchDirectory.text = "Watch directory not set.";
			watchDirectory.setTextFormat(textFormat);
			
			addEventListener(Event.ADDED_TO_STAGE, ats, false, 0, true);
		}
		
		private function ats(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, ats);
			
			stage.addEventListener(Event.RESIZE, stageResize, false, 0, true);
			
			clearButton = new LabelledButton("Clear Watch Folder");
			clearButton.addEventListener(MouseEvent.CLICK, clearClick, false, 0, true);
			addChild(clearButton);
			
			setDestinationButton = new LabelledButton("Set Watch Folder");
			setDestinationButton.addEventListener(MouseEvent.CLICK, destClick, false, 0, true);
			addChild(setDestinationButton);
			addChild(sectionDescription);
			addChild(sectionLabel);
			addChild(watchDirectory);
		}
		
		
		private function stageResize(e:Event):void {
			layout();
		}
		
		private function layout():void{
			this.x = 10;
			this.y = 225;
			sectionDescription.y = 30;
			setDestinationButton.y = sectionDescription.y + sectionDescription.textHeight + 10;
			clearButton.y = setDestinationButton.y;
			clearButton.x = setDestinationButton.width + 10;
			watchDirectory.y = clearButton.y + clearButton.height + 10;
		}
		
		private function destClick(e:Event):void {
			var f:File = new File();
			f.addEventListener(Event.SELECT, selectDirectory, false, 0, true);
			f.browseForDirectory("Select destination folder...");
		}
		
		private function selectDirectory(e:Event):void {
			var dir:File = e.target as File;
			dispatchEvent(new SelectDirectoryEvent(SelectDirectoryEvent.WATCH_SELECTED, dir.nativePath));
		}
		
		private function clearClick(e:Event):void {
			dispatchEvent(new SelectDirectoryEvent(SelectDirectoryEvent.WATCH_SELECTED, "NULL"));
		}
		
		public function setWatchDirectory(path:String):void {
			if(!path || path == "NULL"){
				watchDirectory.text = "Watch directory not set.";				
			} else {
				watchDirectory.text = "Watching: " + path;
			}
		}
	}
}