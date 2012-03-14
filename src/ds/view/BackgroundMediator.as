package ds.view
{
	import ds.controller.events.AppEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class BackgroundMediator extends Mediator
	{
		[Inject]
		public var view:BackgroundView;
		
		public function BackgroundMediator()
		{
			super();
		}
		
		override public function onRegister():void {
			addViewListener(AppEvent.APP_EXITING, appExiting, AppEvent);
		}
		
		private function appExiting(e:AppEvent):void {
			dispatch(e);
		}
	}
}