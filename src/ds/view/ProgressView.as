package ds.view
{
	import com.greensock.TweenLite;
	
	import ds.model.value.FileVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class ProgressView extends Sprite
	{
		private var sectionLabel:TextField = new TextField();
		private var fileName:TextField = new TextField();
		private var percentLabel:TextField = new TextField();
		private var progressBar:Sprite = new Sprite();
		private var progressHolder:Sprite = new Sprite();
		private var textFormat:TextFormat = new TextFormat("TradeGothicBold", 16, 0xffffff);
		public var curPercent:Number = 0.0;
		private var animateTime:Number = 0.2;
		public function ProgressView()
		{
			textFormat.align = TextFormatAlign.LEFT;
			
			sectionLabel.autoSize = TextFieldAutoSize.LEFT;
			sectionLabel.selectable = false;
			sectionLabel.defaultTextFormat = textFormat;
			sectionLabel.embedFonts = true;
			sectionLabel.text = "Transcode progress";
			sectionLabel.setTextFormat(textFormat);
			sectionLabel.alpha = 0.5;
			
			textFormat.font = "TradeGothic";
			textFormat.size = 12;
			
			fileName.autoSize = TextFieldAutoSize.LEFT;
			fileName.selectable = false;
			fileName.defaultTextFormat = textFormat;
			fileName.embedFonts = true;
			fileName.text = "Select files to start";
			fileName.setTextFormat(textFormat);
			fileName.y = 24;
			
			percentLabel.autoSize = TextFieldAutoSize.LEFT;
			percentLabel.selectable = false;
			percentLabel.defaultTextFormat = textFormat;
			percentLabel.embedFonts = true;
			percentLabel.text = "Waiting";
			percentLabel.setTextFormat(textFormat);
			percentLabel.y = 75;
			
			addChild(sectionLabel);
			addChild(fileName);
			addChild(progressHolder);
			addChild(progressBar);
			addChild(percentLabel);
			
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
			this.x = 10;
			this.y = stage.stageHeight - 125;
			
			progressHolder.graphics.clear();
			progressHolder.graphics.beginFill(0x000000, 0.7);
			progressHolder.graphics.drawRoundRect(0, 50, stage.stageWidth/2 - 20, 20, 5);
			progressHolder.graphics.endFill();
			
			drawProgressBar();
		}
		
		private function drawProgressBar():void {
			if(progressBar && stage){
				progressBar.graphics.clear()
				progressBar.graphics.beginFill(0xffffff, 0.7);
				progressBar.graphics.drawRoundRect(0,50, curPercent * (stage.stageWidth/2 - 20), 20, 5);
				progressBar.graphics.endFill();
			}
		}
		
		public function transcodeStart(curFile:FileVO):void {
			fileName.text = curFile.fileName;
			percentLabel.text = "Starting transcode...";
			TweenLite.to(this, animateTime, {curPercent:0.0, onUpdate:drawProgressBar});
		}
		
		public function transcodeProgress(percent:Number):void {
			percentLabel.text = String(Math.floor(percent * 100)) + "% Complete";
			TweenLite.to(this, animateTime, {curPercent:percent, onUpdate:drawProgressBar});
		}
		
		public function transcodeComplete(curFile:FileVO):void {
			fileName.appendText(" Transcode complete. Select files to transcode");
			percentLabel.text = "Waiting."
			TweenLite.to(this, animateTime, {curPercent:1.0, onUpdate:drawProgressBar});
		}
		
		public function transcodeError(curFile:FileVO):void {
			fileName.text = "Transcode error with " + curFile.fileName + " Check files and try again.";
			percentLabel.text = "Waiting."
			TweenLite.to(this, animateTime, {curPercent:0.0, onUpdate:drawProgressBar});	
		}
		
		public function destroy():void {
			
		}
	}
}