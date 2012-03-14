package
{
	import ds.TranscoderContext;
	import ds.app.UpdateableApplication;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.Font;
	
	[SWF( width="1000", height="700", backgroundColor="#000000", frameRate="30")] 
	
	public class DsAirVideoTranscoder extends Sprite
	{
		
		[Embed(source="/fonts/Trade Gothic.ttf", fontName="TradeGothic",  mimeType="application/x-font", embedAsCFF="false")]  
		public static var TradeGothic:Class;
		
		[Embed(source="/fonts/Trade Gothic Bold.ttf", fontName="TradeGothicBold",  mimeType="application/x-font", embedAsCFF="false")]  
		public static var TradeGothicBold:Class;
		
		[Embed(source="/fonts/Trade Gothic Light.otf", fontName="TradeGothicLight",  mimeType="application/x-font", embedAsCFF="false")]  
		public static var TradeGothicLight:Class;
		
		public var context:TranscoderContext;
		public function DsAirVideoTranscoder(){
			addEventListener(Event.ADDED_TO_STAGE, ats);
		}
		
		private function ats(e:Event):void {
			
			Font.registerFont(TradeGothic);
			Font.registerFont(TradeGothicBold);
			Font.registerFont(TradeGothicLight);
			
			removeEventListener(Event.ADDED_TO_STAGE, ats);
			NativeApplication.nativeApplication.autoExit = false;
			
			//NativeApplication.nativeApplication.openedWindows[0].visible = true;
			

			
			context = new TranscoderContext(this);
			
		}
	}
}