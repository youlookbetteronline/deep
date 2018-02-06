package  
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import ui.WishListManager;
	import units.Personage;
	import units.Treasure;
	import wins.RewardWindow;
	import wins.Window;
	import wins.WindowEvent;
	
	public class Friends
	{
		public static const ALL:int 	= 1;
		public static const FAV:int		= 2;
		public static var FAVORITES:Array = [];
		public static var inFavorite:Boolean = false;
		private static var _favorites:Object = {};
		
		public var data:Object;
		public var keys:Array = [];
		
		public function Friends(friends:Object, emptyIDs:Array = null)
		{
			data = friends;
			
			parceWishList();
			
			var bear:Object = { };
			
			for each(var item:Object in data) 
			{
				if(item.uid != "1"){
					keys.push( { uid:item.uid, level:item.level } );
				}else {
					item.first_name = Locale.__e('flash:1382952379733');//'Хранитель'
					bear = { uid:item.uid, level:item.level };
				}
				if (App.time <= item.gift) Gifts.takedFreeGift.push(item.uid);
			}
			
			keys.sortOn("level", Array.NUMERIC | Array.DESCENDING);
			
			if (App.isSocial('YB', 'AI', 'MX', 'GN'))  
			{
				var emptyIDs:Array = [];
				for (var fID:String in data) 
				{
					if (App.network.appFriends.indexOf(fID) == -1) {
						if (fID == '1') continue;
						emptyIDs.push(fID);
					}
				}
				
				Log.alert(emptyIDs);
				Log.alert('data');
				Log.alert(data);
				Log.alert('getUsersProfile')
				
				ExternalApi.getUsersProfile(emptyIDs, function(response:Object):void 
				{	
					Log.alert('response');
					Log.alert(response);
					
					for (var fID:String in response) 
					{
						if (data[fID] != undefined) 
						{
							for (var p:String in response[fID])
							{
								data[fID][p] = response[fID][p];
							}
							if (!data[fID].hasOwnProperty('first_name') || [' ', '  ', '   ', '    ', '     ', '      ', '       ', '        '].indexOf(data[fID].first_name) != -1 || data[fID].first_name == '' || data[fID].first_name == 0)
							{
								data[fID].first_name = data[fID].aka;
							}
						}
					}
					
					if (App.ui != null && App.ui.bottomPanel != null) 
					{
						App.ui.bottomPanel.friendsPanel.searchFriends();
					}
				});
			}
		}
		
		private function parceWishList():void 
		{
			var wl:Object;
			for (var uid:String in data) {
				
				//if (data[uid].hasOwnProperty('gift') && data[uid].gift > App.time) {
					//delete data[uid].wl;
					//continue;
				//}
						
				wl = data[uid].wl;
				for (var sid:String in wl) {
					if (wl[sid].hasOwnProperty('f')) {
						if (wl[sid].t <= App.time) {
							delete wl[sid];
							continue;
						}
							
						wl[sid].f = Numbers.objectToArray(wl[sid].f);
						
						if (wl[sid].f.indexOf(App.user.id) == -1)
							delete wl[sid];
						else
							WishListManager.pushRequest(sid, uid);
							
					}else {
						delete wl[sid];
					}
				}
			}
			trace('');
		}
		
		public function showHelpedFriends():void
		{
			var helpersCount:int =  App.data.options['MaxHelpers'] || 10;
			
			for each(var item:Object in data)
			{
				if (helpersCount > 0 && item['helped'] != undefined && item.helped > 0)
				{
					helpersCount--;
					installHelpedFriend(item);
				}
			}
		}
		
		public function showZzzFriends():void 
		{
			return;
			Log.alert('App.user.friends');
			Log.alert(App.user.friends);
		}
		
		public function checkOnLoad():Boolean 
		{
			if (data[keys[keys.length - 1].uid].hasOwnProperty('first_name'))
				return true;
			return false;
		}
		
		public function installHelpedFriend(friend:Object):void
		{
			return;
			var tries:int = 100;
			//Делаем не больше 100 попыток найти свободное место
			while(tries>0){
				var randX:int = 10 + Math.random() * 30;
				var randZ:int = 10 + Math.random() * 30;
				var node:AStarNodeVO = App.map._aStarNodes[randX][randZ];
				
				if (node.b == 0 && node.p == 0)
				{
					new Guest(friend, {sid:Personage.HERO,x:randX,z:randZ});
					return;
				}
				tries--;
			}
		}
		
		public function get count():uint
		{
			var i:int = 0;
			for (var item:* in data) 
			{
				i++;
			}
			return i;
		}
		
		public function uid(uid:String):Object 
		{
			return data[uid];
		}
		
		public var showAttention:Boolean = true;
		public var paidEnergy:Boolean = false;
		
		public function takeGuestEnergy(uid:String):Boolean 
		{
			paidEnergy = false;
			if (energyLimit <= 0) 
			{
				if (App.user.stock.take(Stock.GUESTFANTASY, 1))
				{
					
					paidEnergy = true;
					return true;
				}
				
				return false;
			}
			
			if (data[uid]['energy'] > 0 && data[uid]['energy'] < 6)
			{
				data[uid]['energy']--;
				App.user.stock.add(Stock.COUNTER_GUESTFANTASY, 1);
				if (data[uid]['fill'] == undefined || data[uid]['fill'] == 0)
				{
					data[uid]['fill'] = App.midnight + 24 * 3600;
				}
				App.ui.leftPanel.showGuestEnergy();
				App.ui.upPanel.updateGuestBar();
				return true;
			}else
			{				
				if (App.user.stock.take(Stock.GUESTFANTASY, 1))
				{
					paidEnergy = true;					
					return true;
				}
				
			}
			
			return false;
		}
		
		public function giveGuestBonus(uid:String):void 
		{
			return;
			if (data[uid]['energy'] == 0 && !paidEnergy) 
			{
				App.user.onStopEvent();
				
				Post.send( {
					ctr:'user',
					act:'guest',
					uID:App.user.id,
					fID:uid
				}, onGuestBonusEvent, { uid:uid } );
				
				App.ui.bottomPanel.bttnMainHome.showGlowing();
			}
		}
		
		private function onGuestBonusEvent(error:*, result:*, params:Object):void 
		{			
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			
			if (!error && result) 
			{
				
				if (!result.hasOwnProperty('guestBonus')) 
					return;				
				
				var bonus:Object = {};
				for (var sID:* in result.guestBonus) 
				{
					var item:Object = result.guestBonus[sID];
					for(var count:* in item)
					bonus[sID] = count * item[count];
				}
				
				App.user.stock.addAll(bonus);
				
				new RewardWindow( { bonus:bonus} ).show();
			}
			else
			{
				Errors.show(error, data);
			}
			
		}
		
		private function onAddTargetEvent(e:WindowEvent):void 
		{
			e.target.removeEventListener(WindowEvent.ON_AFTER_CLOSE, onAddTargetEvent);
			var result:Object = e.target.params;
			
			Treasures.bonus(result.guestBonus, new Point(result.unit.x, result.unit.y));
		}
		
		public function addGuestEnergy(uid:String):void 
		{
			if (data[uid]['energy'] > 0 && data[uid]['energy'] < 6) 
			{
				data[uid]['energy']++;
				App.ui.leftPanel.showGuestEnergy();
			}else {
				data[uid]['energy'] = 1;
				App.ui.leftPanel.showGuestEnergy();
			}
		}
		
		public function updateOne(uid:String, field:String, value:*):void 
		{
			if (data[uid]) 
			{
				data[uid][field] = value;
			}
		}
		
		public function get energyLimit():int
		{
			var limit:int = App.data.options['VisitLimit'] || 100;
			
			for each(var item:Object in data)
			{
				limit -= 5 - (item.energy > 0?item.energy:0);
			}
			
			if (limit <= 0)
			{
				for each(item in data) 
				{
					item.energy = 0;
				}
			}
			return limit;
		}
		
		public static function registerFriend(uid:*):void 
		{
			//return; //не забыть убрать
			Log.alert('INVITED FRIENDS');
			Log.alert(uid);
			
			if ((uid is String) || (uid is int)) {
				send(uid);
			} if (App.social == 'FS') {
				if (uid.users && uid.users.length > 0)
					send(uid.users.toString());
			} else if (App.social == 'MM') {
				if ((uid is Array) && uid.length > 0) {
					send(uid.toString());
				} else if (uid.hasOwnProperty('data') && Numbers.countProps(uid.data) > 0) {
					send((Numbers.firstProp(uid.data).val).toString());
				}
			} else if (App.social == 'OK') {
				uid = uid.split(',');
				for (var i:int = 0; i < uid.length; i++) {
					send(uid[i]);
				}
			}
			
			if (App.isSocial('DM', 'VK')) 
			{				
				ExternalApi.apiWallPostEvent(1, new Bitmap(Window.textures.theGame), String(uid), Locale.__e('flash:1382952380111', [Config.appUrl]));
			}
			
			function send(uid:*):void {
				if (App.user.socInvitesFrs.hasOwnProperty(uid))
				{
					Log.alert('Уже такой есть!');
					return;
				}
				Log.alert('GO!');
				Post.send( {
					ctr:'user',
					act:'setinvite',
					uID:App.user.id,
					fID:uid
				},function(error:*, data:*, params:*):void {
					if (error)
					{
						Errors.show(error, data);
						return;
					}
				});
			}
		}
		
		public function get ingameFriendList():Array
		{
			var list:Array = [];
			for (var uid:String in data)
			{
				if (uid == '1') continue;
				list.push(uid);
			}
			return list;
		}
		
		public function hasFriends(id:*):Boolean 
		{
			if (data.hasOwnProperty(id)) return true;
			
			return false;
		}
		
		public function removeFriend(id:*, update:Boolean = true):void 
		{
			if (data.hasOwnProperty(id)) 
			{
				delete data[id];
			}
			if (update) 
			{
				App.ui.bottomPanel.friendsPanel.searchFriends();
				App.ui.bottomPanel.friendsPanel.resize();
			}
		}
		
		public function addFriend(id:*, info:Object, update:Boolean = true):void 
		{
			if (data.hasOwnProperty(id)) return;//не забыть убрать
			data[id] = info;
			
			if (update) 
			{
				App.ui.bottomPanel.friendsPanel.searchFriends();
				App.ui.bottomPanel.friendsPanel.resize();
			}
		}
		
		public static function isOwnerSleeping(uid:String):Boolean 
		{
			if ((((App.user.friends.data[uid].lastvisit + App.data.options['LastVisitDays']) > App.time))) {
				return false;
			} else {
				if (App.user.friends.data[uid].alert /*+ App.data.options['alerttime'])*/ > App.time ) {
					return false;
				}
			}
			return true;
		}
		
		public static function get favorites():Object
		{
			if (Numbers.countProps(_favorites) > 0)
				return _favorites
			for (var fr:* in App.user.friends.data)
			{
				if (App.user.friends.data[fr].hasOwnProperty('favorite') || fr == 1)
				{
					_favorites[fr] = App.user.friends.data[fr];
				}
			}
			return _favorites;
		}
		
		public static function set favorites(value:Object):void
		{
			_favorites = value;
		}
	}
}