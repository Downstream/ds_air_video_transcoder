package ds.view.components
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class QueueItem extends Sprite
	{
		private var fileLabel:TextField = new TextField();
		private var _filePath:String;
		private var transcodeStatus:TextField = new TextField();
		private var clearBtn:LabelledButton;
		
		private var textFormat:TextFormat = new TextFormat("TradeGothicBold", 12, 0xffffff);
		
		public function QueueItem(fileName:String, path:String)
		{
			super();
			_filePath = path;			
			
			textFormat.align = TextFormatAlign.LEFT;
			
			fileLabel.selectable = false;
			fileLabel.defaultTextFormat = textFormat;
			fileLabel.embedFonts = true;
			fileLabel.text = fileName;
			fileLabel.setTextFormat(textFormat);
			
			transcodeStatus.selectable = false;
			transcodeStatus.defaultTextFormat = textFormat;
			transcodeStatus.embedFonts = true;
			transcodeStatus.text = "Waiting";
			transcodeStatus.setTextFormat(textFormat);
			transcodeStatus.alpha = 0.5;
			
			clearBtn = new LabelledButton("x", 8, 16, -5);
			clearBtn.addEventListener(MouseEvent.CLICK, clearClick, false, 0, true);
			
			addEventListener(Event.ADDED_TO_STAGE, ats, false, 0, true);
		}
		
		private function ats(e:Event):void {			
			addChild(fileLabel);
			addChild(transcodeStatus);
			addChild(clearBtn);
			layout();
			stage.addEventListener(Event.RESIZE, stageResize, false, 0, true);
		}
		
		private function stageResize(e:Event):void {
			layout();
		}
		
		private function layout():void {
			fileLabel.width = stage.stageWidth / 3;
			fileLabel.x = 25;
			transcodeStatus.width = stage.stageWidth / 6;
			transcodeStatus.x = stage.stageWidth / 3 + 35;
			clearBtn.x = 5;
			clearBtn.y = 1;
		}
		
		public function setStatus(status:String):void{
			transcodeStatus.text = status;
		}
		
		public function get filePath():String {
			return _filePath;
		}
		
		public function get fileName():String {
			return fileLabel.text;
		}
		
		private function clearClick(e:Event):void {
			dispatchEvent(new Event(Event.CLEAR));
		}
		
		public function destroy():void {
			stage.removeEventListener(Event.RESIZE, stageResize);
			fileLabel.parent.removeChild(fileLabel);
			fileLabel = null;
			transcodeStatus.parent.removeChild(transcodeStatus);
			transcodeStatus = null;
			if(clearBtn){
				clearBtn.destroy();
				clearBtn.parent.removeChild(clearBtn);
				clearBtn = null;
			}
			
		}
	}
}