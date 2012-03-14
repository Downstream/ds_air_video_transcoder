package ds.view
{
	import ds.controller.events.AppEvent;
	import ds.view.components.LabelledButton;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class BackgroundView extends Sprite
	{
		private var exitButton:LabelledButton;
		private var titleField:TextField = new TextField();
		private var subTitleField:TextField = new TextField();
		private var textFormat:TextFormat = new TextFormat("TradeGothicBold", 36, 0xffffff);
		private var middleLine:Sprite = new Sprite();
		private var sectionDescription:TextField = new TextField();
		public function BackgroundView()
		{
			textFormat.align = TextFormatAlign.LEFT;
			
			titleField.autoSize = TextFieldAutoSize.LEFT;
			titleField.selectable = false;
			titleField.defaultTextFormat = textFormat;
			titleField.embedFonts = true;
			titleField.text = "downstream";
			titleField.setTextFormat(textFormat);
			titleField.alpha = 0.15;
			titleField.x = 10;
			
			textFormat.font = "TradeGothicLight";
			textFormat.size = 30;
			
			subTitleField.autoSize = TextFieldAutoSize.LEFT;
			subTitleField.selectable = false;
			subTitleField.defaultTextFormat = textFormat;
			subTitleField.embedFonts = true;
			subTitleField.text = " | video converter";
			subTitleField.setTextFormat(textFormat);
			subTitleField.alpha = 0.15;
			subTitleField.x = titleField.textWidth + 10;
			subTitleField.y = 6;
			
			textFormat.font = "TradeGothicBold";
			textFormat.align = TextFormatAlign.RIGHT;
			textFormat.size = 12;
			sectionDescription.width = 300;
			sectionDescription.height = 300;
			sectionDescription.wordWrap = true;
			sectionDescription.multiline = true;
			sectionDescription.selectable = false;
			sectionDescription.defaultTextFormat = textFormat;
			sectionDescription.embedFonts = true;
			sectionDescription.text = "Close this window for converting to continue in the background. Click exit to cancel all converting";
			sectionDescription.setTextFormat(textFormat);
			sectionDescription.alpha = 0.75;
			sectionDescription.mouseEnabled = false;
			exitButton = new LabelledButton("Exit");
			exitButton.addEventListener(MouseEvent.CLICK, exitClick, false, 0, true);
			
			addChild(exitButton);
			addChild(titleField);
			addChild(subTitleField);
			addChild(middleLine);
			addChild(sectionDescription);
			
			addEventListener(Event.ADDED_TO_STAGE, ats, false, 0, true);
		}
		
		private function ats(e:Event):void {			
			stage.addEventListener(Event.RESIZE, stageResize, false, 0, true);
			layout();
		}
		
		private function stageResize(e:Event):void {
			layout();
		}
		
		private function layout():void {
			this.graphics.clear();
			this.graphics.beginFill(0x333333, 1.0);
			this.graphics.drawRect(0,0,stage.stageWidth, stage.stageHeight);
			this.graphics.endFill();
			exitButton.x = stage.stageWidth - exitButton.width - 10;
			exitButton.y = stage.stageHeight - exitButton.height - 10;
			sectionDescription.x = exitButton.x - 15 - sectionDescription.textWidth - exitButton.width;
			sectionDescription.y = exitButton.y + 5;
			
			middleLine.graphics.clear();
			middleLine.graphics.lineStyle(0.5, 0xffffff, 0.7);
			middleLine.graphics.moveTo(stage.stageWidth/2, 40);
			middleLine.graphics.lineTo(stage.stageWidth/2, stage.stageHeight - 40);
		}
		
		private function exitClick(e:Event):void {
			dispatchEvent(new AppEvent(AppEvent.APP_EXITING));
		}
	}
}