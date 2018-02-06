package units
{
	import core.Post;
	import wins.NewsWindow;
	import wins.UpdateWindow;
	import wins.ValentinePreviewWindow;
	
	public class Pigeon
	{
		public function Pigeon() 
		{
			
		}
		
		public static function checkNews():void
		{
			var news:Array = [];
			var updatelist:Array = [];
			var first:Boolean = false;
			var update:Object;
			
			if(App.data.updatelist.hasOwnProperty(App.social)) {
				for (var s:String in App.data.updatelist[App.social]) {
					if (!App.data.updates[s].social.hasOwnProperty(App.social)) continue;
					updatelist.push( {
						nid: s,
						update: App.data.updates[s],
						order: App.data.updatelist[App.social][s]
					});
				}
				updatelist.sortOn('order', Array.NUMERIC);
				updatelist.reverse();
			}
			update = updatelist[0].update;
			update['nid'] = updatelist[0].nid;
			if (update == null) return;
			
			var count:int = 0;
			var _cookie:String = App.user.storageRead('upd', '');
			var cookie:Array = _cookie.split("_");
			
			if (cookie.length == 0 || cookie[0] != update.nid) {
				
			} else {
				count = int(cookie[1]) + 1;
			}
			if (cookie.length > 2) 
			{
				App.user.storageStore('upd', update.nid + "_" + count + "_" + 1);
				Post.addToArchive('upd ' + update.nid + "_" + count + "_" + 1);
			} else 
			{
				App.user.storageStore('upd', update.nid + "_" + count);
				Post.addToArchive('upd ' + update.nid + "_" + count);
			}
			/*if (activeAuctions.length > 0)
				new ValentinePreviewWindow({updt:update}).show();
			else
			{*/
				if (count <= 5 && !User.inExpedition) {
					if (update.nid != 'u59ef37ab9d08a')
						new UpdateWindow({news:update}).show();
						//new NewsWindow({news:update}).show();

				//Load.loading(Config.getImageIcon('updates/images', update.preview), function(data:Bitmap):void {
					//new ValentinePreviewWindow({blockButton:true, updt:update}).show();
				//});
				}
			//}
		}
		
		public static function get activeAuctions():Array
		{
			var _activeAuctions:Array = [];
			for each (var auction:Object in App.data.auctions) 
			{
				if (auction.enabled && auction.expire.s < App.time && auction.expire.e > App.time) {
					_activeAuctions.push(auction);
				}
			}
			return _activeAuctions
		}
	}
}