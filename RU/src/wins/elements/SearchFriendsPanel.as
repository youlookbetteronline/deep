package wins.elements
{
	import buttons.ImageButton;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import ui.UserInterface;
	import wins.GiftWindow;
	import wins.Window;

	/**
	 * ...
	 * @author ...
	 */
	public class SearchFriendsPanel extends SearchPanel 
	{
		
		public function SearchFriendsPanel(settings:Object) {
			
			super(settings);
			
		}
		
		override protected function drawSearch():void {
			
			bttnSearch = new ImageButton(Window.textures.searchFieldEmpty);
			
			bttnSearch.tip = function():Object {
				return {
					title:Locale.__e('flash:1382952380073'),
					text:Locale.__e('flash:1382952380074')
				}
			}
			
			/*var bg:Bitmap = new Bitmap(Window.textures.clearBubbleBacking_0);
			Size.size(bg, 40, 40); 
			bg.x = bttnSearch.x + (bttnSearch.width - bg.width) / 2;
			bg.y = bttnSearch.y + (bttnSearch.height - bg.height) / 2;
			bg.smoothing = true;
			addChild(bg);*/
			
				//bttnSearch.addEventListener(MouseEvent.CLICK, onSearchEvent);
			
			var searchBg:Shape = new Shape();
			//searchBg.graphics.lineStyle(2, 0xd58146, 1, true);
			searchBg.graphics.beginFill(0xffa768,1);
			searchBg.graphics.drawRoundRect(0, 0, 220, 30, 20, 20);
			searchBg.graphics.endFill();
			searchBg.filters = [new DropShadowFilter(1.0, 90, 0, 0.5, 2.0, 2.0, 1.0, 2, true, false, false), new DropShadowFilter(1.0, 90, 0xffffff, 0.5, 2.0, 2.0, 1.0, 2, false, false, false)];
			
			addChild(searchBg);
			searchBg.x = 0;
			searchBg.y = 0;
			
			bttnSearch.x = searchBg.x + 5;
			bttnSearch.y = searchBg.y + (searchBg.height - bttnSearch.height) / 2;
			
			addChild(bttnSearch);
			
			if (!settings.hasIcon)
			{
				bttnSearch.visible = false
			}
			
			bttnBreak = new ImageButton(UserInterface.textures.stopIconNew/*, { scaleX:0.7, scaleY:0.7, shadow:true }*/ );
			addChild(bttnBreak);
			bttnBreak.x = searchBg.x + searchBg.width - bttnBreak.width - 5;
			bttnBreak.y = searchBg.y + (searchBg.height - bttnBreak.height) / 2;
			bttnBreak.addEventListener(MouseEvent.CLICK, onBreakEvent);
			
			searchField = Window.drawText("",{ 
				color:0x6e411e,
				borderColor:0xf8f2e0,
				borderSize:2,
				fontSize:18,
				input:true
			});
			
			searchField.x = bttnSearch.x + bttnSearch.width + 4;
			searchField.y = searchBg.y + 2 + (searchBg.height - searchField.height) / 2;
			searchField.width = 158;
			searchField.height = searchField.textHeight + 2;
			
			addChild(searchField);
			
			searchField.addEventListener(Event.CHANGE, onInputEvent);
			searchField.addEventListener(FocusEvent.FOCUS_IN, onFocusEvent);
			searchField.addEventListener(FocusEvent.FOCUS_OUT, onUnFocusEvent);
		}
		
		override public function search(query:String = "", isCallBack:Boolean = true):Array {
			
			var wlFilter:Boolean = false;
			if (settings.win.hasOwnProperty('wishListFilter')) wlFilter = settings.win.wishListFilter;
			
			var freeFilter:Boolean = false;
			if (settings.win.settings.iconMode == GiftWindow.FREE_GIFTS) freeFilter = true;
			
			var friends:Array = [];
			var friend:Object;
			
			query = query.toLowerCase();
			var fid:String;
			
			// Пустая строка поиска
			if (query == "") {
				
				if (settings.win.settings.itemsMode == GiftWindow.ALLFRIENDS){
					for (fid in App.network.otherFriends) {
						friends.push(App.network.otherFriends[fid]);
					}
					friends.sortOn("uid");
				}else{
					for each(friend in App.user.friends.keys) {
						if (!friend.uid || friend.uid == "1") continue;
						
						if (friend.uid && !useFilters(friend.uid)) continue;
						friends.push(friend);
					}
					friends.sortOn(["level", "uid"]);
				}
			}else {
				
				if (settings.win.settings.itemsMode == GiftWindow.ALLFRIENDS){
					for (fid in App.network.otherFriends) {
						friend = App.network.otherFriends[fid];
						if (
							friend.first_name.toLowerCase().indexOf(query) == 0 ||
							friend.last_name.toLowerCase().indexOf(query) == 0 ||
							friend.uid.toString().toLowerCase().indexOf(query) == 0
						){
							friends.push(friend);
						}
					}
					friends.sortOn("uid");
				}else{
					for each(friend in App.user.friends.data) {
						
						if (!friend.uid || friend.uid == "1" || !useFilters(friend.uid)) continue;
						
						if (
							friend.aka.toLowerCase().indexOf(query) == 0 ||
							(friend.first_name && friend.first_name.toLowerCase().indexOf(query) == 0) ||
							(friend.last_name && friend.last_name.toLowerCase().indexOf(query) == 0) ||
							friend.uid.toString().toLowerCase().indexOf(query) == 0
						){
							friends.push(friend);
						}
					}
					friends.sortOn("level");
				}
			}
			// Передаем новый список друзей
			if(isCallBack)
				settings.callback(friends);
			
			// Проверяем подходит ли под условия фильтра
			function useFilters(_uid:String):Boolean
			{
				if (freeFilter && !Gifts.canTakeFreeGift(_uid)) return false;
				if (wlFilter) {
					var check:Boolean = false;
					for each(var wItem:* in App.user.friends.data[_uid].wl) 
						if (wItem == settings.win.icon.ID) 
							check = true;
					if (!check) 
						return false;
				}
				
				// фильтры пройдены
				return true;
			}
			return friends;
		}
	}
	
}