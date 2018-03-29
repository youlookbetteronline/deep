package 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TopEvent extends Event 
	{
		public static const ON_FINISH_TRY:String 		= "onFinishTry";
		public var params:Object;
		
		public function TopEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, params:Object = null) 
		{
			super(type, bubbles, cancelable);
			this.params = params;
		}
		
		
	}

}