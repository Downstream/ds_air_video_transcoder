package ds.view.components
{
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class LabelledButton extends Sprite
	{
		private var label:String;
		private var buttonUp:Sprite;
		private var buttonDown:Sprite;
		private var labelUp:TextField = new TextField();
		private var labelDown:TextField = new TextField();
		private var padX:Number = 20;
		private var padY:Number = 40;
		private var textYOffset:Number = 7;
		public function LabelledButton(theLabel:String, xPad:Number = 20, yPad:Number = 40, textY:Number = 8)
		{
			padX = xPad;
			padY = yPad;
			textYOffset = textY;
			label = theLabel;
			super();
			
			var tf:TextFormat = new TextFormat("TradeGothicBold", 16, 0x333333);
			tf.align = TextFormatAlign.CENTER;
			
			var getWidth:TextField = new TextField();
			getWidth.autoSize = TextFieldAutoSize.LEFT;
			getWidth.defaultTextFormat = tf;
			getWidth.embedFonts = true;
			getWidth.text = label;
			getWidth.setTextFormat(tf);
			
			var buttonWidth:Number = getWidth.textWidth + padX;
			
			buttonUp = new Sprite();
			buttonUp.graphics.clear();
			buttonUp.graphics.beginFill(0xffffff, 0.7);
			buttonUp.graphics.drawRoundRect(0, 0, buttonWidth, padY, 10);
			buttonUp.graphics.endFill();
			
			buttonDown = new Sprite();
			buttonDown.graphics.clear();
			buttonDown.graphics.beginFill(0x666666, 0.7);
			buttonDown.graphics.drawRoundRect(0, 0, buttonWidth, padY, 10);
			buttonDown.graphics.endFill();
			
			labelUp.width = buttonWidth;
			labelUp.height = padY;
			labelUp.selectable = false;
			labelUp.defaultTextFormat = tf;
			labelUp.embedFonts = true;
			labelUp.text = label;
			labelUp.setTextFormat(tf);
			labelUp.y = textYOffset;
			
			labelDown.width = buttonWidth;
			labelDown.height = padY;
			labelDown.selectable = false;
			labelDown.defaultTextFormat = tf;
			labelDown.embedFonts = true;
			labelDown.text = label;
			labelDown.setTextFormat(tf);
			labelDown.textColor = 0xffffff;
			labelDown.y = textYOffset;
			
			addChild(buttonUp);
			addChild(buttonDown);
			addChild(labelUp);
			addChild(labelDown);
			
			setButtonState(false);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
			buttonMode = true;
			mouseEnabled = true;
			mouseChildren = false;
		}
		
		private function setButtonState(down:Boolean):void {
			var animateTime:Number = 0.25;
			if(down){
				TweenLite.to(buttonDown, animateTime, {alpha:1.0});
				TweenLite.to(buttonUp, animateTime, {alpha:0.0});
				TweenLite.to(labelDown, animateTime, {alpha:1.0});
				TweenLite.to(labelUp, animateTime, {alpha:0.0});
			} else {
				TweenLite.to(buttonDown, animateTime, {alpha:0.0});
				TweenLite.to(buttonUp, animateTime, {alpha:1.0});
				TweenLite.to(labelDown, animateTime, {alpha:0.0});
				TweenLite.to(labelUp, animateTime, {alpha:1.0});
			}
		}
		
		private function mouseDown(e:Event):void {
			setButtonState(true);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOver, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_OUT, mouseOut, false, 0, true);
		}
		
		private function mouseOut(e:Event):void {
			setButtonState(false);
		}
		
		private function mouseOver(e:Event):void {
			setButtonState(true)
		}
		
		private function mouseUp(e:Event):void {
			setButtonState(false);
			removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		public function destroy():void {
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			
			if(buttonDown){
				buttonDown.parent.removeChild(buttonDown);
				buttonDown = null
			}
			if(buttonUp){
				buttonUp.parent.removeChild(buttonUp);
				buttonUp = null
			}
			if(labelUp){
				labelUp.parent.removeChild(labelUp);
				labelUp = null
			}
			if(labelDown){
				labelDown.parent.removeChild(labelDown);
				labelDown = null
			}
		}
	}
}