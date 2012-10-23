package ds.view
{
	import ds.controller.events.SelectDirectoryEvent;
	import ds.controller.events.TranscodeRequest;
	import ds.model.value.FileVO;
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
	
	public class SelectFilesView extends Sprite
	{
		private var selectFilesButton:LabelledButton;
		private var setDestinationButton:LabelledButton;
		private var sectionLabel:TextField = new TextField();
		private var sectionDescription:TextField = new TextField();
		private var textFormat:TextFormat = new TextFormat("TradeGothicBold", 24, 0xffffff);
		public function SelectFilesView()
		{
			super();
			textFormat.align = TextFormatAlign.LEFT;
			
			sectionLabel.autoSize = TextFieldAutoSize.LEFT;
			sectionLabel.selectable = false;
			sectionLabel.defaultTextFormat = textFormat;
			sectionLabel.embedFonts = true;
			sectionLabel.text = "Convert videos now";
			sectionLabel.setTextFormat(textFormat);
			sectionLabel.alpha = 0.5;
			
			
			textFormat.size = 12;
			sectionDescription.width = 300;
			sectionDescription.wordWrap = true;
			sectionDescription.multiline = true;
			sectionDescription.selectable = false;
			sectionDescription.defaultTextFormat = textFormat;
			sectionDescription.embedFonts = true;
			sectionDescription.text = "Choose one or more video files. If an output directory is set, converting will begin immediately.";
			sectionDescription.setTextFormat(textFormat);
			sectionDescription.alpha = 0.75;
			sectionDescription.mouseEnabled = false;
			
			selectFilesButton = new LabelledButton("Select Videos");
			selectFilesButton.addEventListener(MouseEvent.CLICK, buttonClick, false, 0, true);
			addChild(selectFilesButton);
			
			setDestinationButton = new LabelledButton("Set Output Folder");
			setDestinationButton.addEventListener(MouseEvent.CLICK, destClick, false, 0, true);
			addChild(setDestinationButton);
			addChild(sectionDescription);
			addChild(sectionLabel);
			
			addEventListener(Event.ADDED_TO_STAGE, ats, false, 0, true);
		}
		
		private function ats(e:Event):void {
			stage.addEventListener(Event.RESIZE, stageResize, false, 0, true);
			layout();
		}
		
		
		private function stageResize(e:Event):void {
			layout();
		}
		
		private function layout():void{
			this.x = 10;
			this.y = 75;
			sectionDescription.y = 30;
			selectFilesButton.y = sectionDescription.y + sectionDescription.textHeight + 10;
			setDestinationButton.y = selectFilesButton.y;
			setDestinationButton.x = selectFilesButton.width + 10;
		}
		
		private function destClick(e:Event):void {
			var f:File = new File();
			f.addEventListener(Event.SELECT, selectDirectory, false, 0, true);
			f.browseForDirectory("Select destination folder...");
		}
		
		private function selectDirectory(e:Event):void {
			var dir:File = e.target as File;
			dispatchEvent(new SelectDirectoryEvent(SelectDirectoryEvent.OUTPUT_SELECTED, dir.nativePath));
		}
		
		private function buttonClick(e:Event):void {
			var f:File = new File();
			f.addEventListener(FileListEvent.SELECT_MULTIPLE, selectMultiple, false, 0, true);
			f.browseForOpenMultiple("Select video files...");
		}
		
		private function selectMultiple(e:FileListEvent):void {
/*			var f:File = e.files[0];
			var dest:File = File.documentsDirectory.resolvePath("downstream/encoded_videos/test.wmv");
			trace(dest.exists);
			f.moveTo(dest, true);*/
			var filePaths:Vector.<FileVO> = new Vector.<FileVO>;
			for( var i:int = 0; i < e.files.length; i++){
				var f:File = e.files[i] as File;
				var fvo:FileVO = new FileVO(f.name, f.nativePath, f.extension);
				filePaths.push(fvo);
			}
			dispatchEvent(new TranscodeRequest(TranscodeRequest.TRANSCODE_FILES, filePaths));
		}
	}
}