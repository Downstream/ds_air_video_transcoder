package ds.view
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	
	import ds.controller.events.TranscodeRequest;
	import ds.model.value.FileVO;
	import ds.view.components.QueueItem;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class QueueView extends Sprite
	{
		private var sectionLabel:TextField = new TextField();
		private var outputDir:TextField = new TextField();
		private var textFormat:TextFormat = new TextFormat("TradeGothicBold", 16, 0xffffff);
		private var queueItems:Vector.<QueueItem> = new Vector.<QueueItem>;
		
		static private const itemSpacing:Number = 25;
		static private const itemTopPadding:Number = 50;
		
		private var itemsHolder:Sprite = new Sprite();
		private var itemsMask:Sprite = new Sprite();
		public function QueueView()
		{
			super();
			
			sectionLabel.autoSize = TextFieldAutoSize.LEFT;
			sectionLabel.selectable = false;
			sectionLabel.defaultTextFormat = textFormat;
			sectionLabel.embedFonts = true;
			sectionLabel.text = "Conversion queue";
			sectionLabel.setTextFormat(textFormat);
			sectionLabel.alpha = 0.5;
			
			textFormat.size = 12;
			outputDir.autoSize = TextFieldAutoSize.LEFT;
			outputDir.selectable = true;
			outputDir.defaultTextFormat = textFormat;
			outputDir.embedFonts = true;
			outputDir.text = "No output directory. Set one to begin transcoding.";
			outputDir.setTextFormat(textFormat);
			
			addChild(sectionLabel);
			addChild(outputDir);
			addChild(itemsHolder);
			itemsHolder.addChild(itemsMask);
			itemsHolder.mask = itemsMask;
			
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
			this.x = stage.stageWidth/2 + 10;
			this.y = 40;
			outputDir.y = 25;
			itemsMask.width = stage.stageWidth/2;
			itemsMask.height = stage.stageHeight - 100;
			itemsMask.graphics.clear();
			itemsMask.graphics.beginFill(0x000000, 0.5);
			itemsMask.graphics.drawRect(0, 0, stage.stageWidth/2, stage.stageHeight/2);
			itemsMask.graphics.endFill();
			layoutItems();
		}
		
		public function outputSelected(path:String):void {
			outputDir.text = "Ouput folder: " + path;
		}
		
		public function addFiles(files:Vector.<FileVO>):void {
			for each(var f:FileVO in files){
				var dupe:Boolean = false;
				for each( var qq:QueueItem in queueItems){
					if( f.filePath == qq.filePath){
						dupe = true;
						break;
					}
				}
				if(dupe) continue;
				var qi:QueueItem = new QueueItem(f.fileName, f.filePath);
				qi.addEventListener(Event.CLEAR, itemClear, false, 0, true);
				itemsHolder.addChild(qi);
				queueItems.push(qi);
			}
			layoutItems();
		}
		
		public function startTranscode(file:FileVO):void {
			for each(var qi:QueueItem in queueItems){
				if(qi.filePath == file.filePath){
					qi.setStatus("Converting...");
					return;
				}
			}
		}
		
		public function transcodeComplete(file:FileVO):void {
			for each(var qi:QueueItem in queueItems){
				if(qi.filePath == file.filePath){
					qi.setStatus("Complete");
					return;
				}
			}
		}
		
		public function transcodeError(file:FileVO):void {
			for each(var qi:QueueItem in queueItems){
				if(qi.filePath == file.filePath){
					qi.setStatus("Error");
					return;
				}
			}
		}
		
		private function itemClear(e:Event):void {
			var qi:QueueItem = e.target as QueueItem;
			if(qi){
				removeItemByPath(qi.filePath);
			} else {
				trace("couldn't convert");
			}
		}
		
		public function removeItemByPath(filePath:String):void {
			var fvs:Vector.<FileVO> = new Vector.<FileVO>;
			for each(var qi:QueueItem in queueItems){
				if(qi.filePath == filePath){
					TweenLite.to(qi, 0.25, {alpha:0, onComplete:killItem, onCompleteParams:[qi]});
					qi.removeEventListener(Event.CLEAR, itemClear);
					queueItems.splice(queueItems.indexOf(qi), 1);
					fvs.push( new FileVO(qi.fileName, qi.filePath));
					layoutItems();
				}
			}	
			
			dispatchEvent(new TranscodeRequest(TranscodeRequest.CANCEL_TRANSCODE, fvs));
		}
		
		private function killItem(dO:QueueItem):void {
			if(dO && dO.parent){
				dO.destroy();
				dO.parent.removeChild(dO);
				dO = null;
			}
		}
		
		private function layoutItems():void {
			var posY:int = itemTopPadding;
			for each( var qi:QueueItem in queueItems){
				TweenLite.to(qi, 0.25, {y:posY, ease:Quad.easeInOut});
				posY += itemSpacing;
			}
		}
	}
}