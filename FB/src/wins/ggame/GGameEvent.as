/**
 * Created by Andrew on 10.05.2017.
 */
package wins.ggame {
	import flash.events.Event;

	public class GGameEvent extends Event
	{
		public static const ON_START_CLICK:String 		        = "ggame::startClick";
		public static const ON_GAME_START:String 		        = "ggame::gameStart";
		public static const TIMER_COMPLETE:String 		        = "ggame::timerComplete";
		public static const ITEM_MOVE_COMPLETE:String 		    = "ggame::itemMoveComplete";
		public static const ITEM_CATCHED:String 		        = "ggame::itemCatched";
		public static const ON_ICON_LOADED:String 		        = "ggame::iconLoaded";

		public var data:Object;

		public function GGameEvent(eventType:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object = null):void
		{
			super(eventType, bubbles, cancelable);

			this.data = data;
		}
	}
}
