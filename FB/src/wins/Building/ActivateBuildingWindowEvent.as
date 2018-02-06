package wins.Building 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ActivateBuildingWindowEvent extends Event 
	{
		public static const CONFIRM_ACTIVATION:String = "activateBuildingWindowEvent.Confirm";
		public static const CANCEL_ACTIVATION:String = "activateBuildingWindowEvent.Cancel";
		
		public function ActivateBuildingWindowEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
		}
	}

}