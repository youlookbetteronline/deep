package  
{
	import core.Post;
	import flash.utils.setTimeout;
	import wins.FiestaWindow;

	/**
	 * ...
	 * @author ...
	 */
	public class Events 
	{
		public static const ST_VALENTINE:String = 'StValentine';
		public static var activeBoxDurationJson:Object;
		//vk - 1426780800
		//fb - 1427976000
		public static var timeOfComplete:int = 0;
		public static var eventItems:Array = [2418, 2545];
		public static var info:Object = { };
		public static var items:Object = { };
		public static var update:String = 'no_update';
		
		public function Events()
		{
			
		}
		
		public static function eventItem(sid:*):Boolean {
			if (eventItems.indexOf(int(sid)) >= 0)
				return true;
			
			return false;
		}
		
		public static function init():void 
		{
			return;
			activeBoxDurationJson = JSON.parse(App.data.options.animatedBoxDuration);
			
			for (var box:* in activeBoxDurationJson[App.SOCIAL]) {
				timeOfComplete = activeBoxDurationJson[App.SOCIAL][box]
			}
			/*if (App.isSocial('DM','VK','MM','OK','FS')) {
				timeOfComplete = 1646133139;
			}else if (App.isSocial('FB','NK')) {
				timeOfComplete = 1646133139;
			}else if (App.isSocial('AI','YB','MX')) {
				timeOfComplete = 1646133139;
			}else if (App.isSocial('HV')) {
				timeOfComplete = 1646133139;
			}else {
				timeOfComplete = 0;
			}*/
		}		
		
		public static function initEvents():void {
		 var eventManager:Object = JSON.parse(App.data.options['EventManager']);
			if (eventManager.timeFinish > App.time && App.user.quests.data[839]) {
				setTimeout(function():void {
					new FiestaWindow().show();
				}, 6000);
			}
		}
		//public static function checkEvents():void {
			//var events:Object = App.data.gameevents;
			//for (var eventID:* in events) {
				//startEvent(eventID);
				//return;
			//}
		//}
		//
		//public static var currentEvent:Object;
		//private static function startEvent(eventID:int):void {
			//currentEvent = App.data.gameevents[eventID];
			//openEventMap(currentEvent.world);
		//}
		//
		//private static function openEventMap(worldID:int):void {
			//
			//if (App.user.worlds.hasOwnProperty(worldID)) return;
			//
			//Post.send({
				//ctr:'world',
				//act:'open',
				//uID:App.user.id,
				//wID:worldID,
				//buy:0
			//},
			//function(error:*, data:*, params:*):void {
				//
				//if (error) {
					//Errors.show(error, data);
					//return;
				//}
				//
				//App.user.worlds[worldID] = worldID;
			//});	
		//}
	}
}