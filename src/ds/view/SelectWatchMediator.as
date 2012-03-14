package ds.view
{
	import ds.controller.events.SelectDirectoryEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class SelectWatchMediator extends Mediator
	{
		[Inject]
		public var view:SelectWatchView;
		
		public function SelectWatchMediator()
		{
			super();
		}
		
		override public function onRegister():void {
			addContextListener(SelectDirectoryEvent.WATCH_SELECTED, watchSelected, SelectDirectoryEvent);
			addViewListener(SelectDirectoryEvent.WATCH_SELECTED, setWatch, SelectDirectoryEvent);
		}
		
		private function watchSelected(e:SelectDirectoryEvent):void {
			if(view) view.setWatchDirectory(e.path);
		}
		
		private function setWatch(e:SelectDirectoryEvent):void {
			dispatch(e);
		}
	}
}