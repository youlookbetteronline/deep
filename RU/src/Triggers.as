package
{
	import core.Post;
	
	
	public class Triggers {
		public static var data:Object = {};
		
		public static const LOAD_GAME:int = 188;
		public static const LOAD_INTRO:int = 189;
		public static const SHOW_NP:int = 190;
		public static const SHOW_HERO:int = 191;
		
		public static function send(qID:uint):void 
		{
			if (App.user.quests.data[qID] && App.user.quests.data[qID].finished) return;
			Post.send( {
				ctr:'quest',
				act:'read',
				qID:qID,
				uID:App.user.id
			}, function(e:int, data:Object, param:Object):void {
				if (e) {
					return;
				}
				if (!App.user.quests.data.hasOwnProperty(qID)) {
					App.user.quests.data[qID] = { };
				}
				App.user.quests.data[qID].finished = App.time;
				//App.user.quests.getOpened();
				App.user.quests.openChilds(qID);
			});
		}
	}
}