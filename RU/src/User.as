package  
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import auction.Auction;
	import auction.Updater;
	import com.adobe.images.BitString;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import core.Animation;
	import core.BezieDrop;
	import core.IsoConvert;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import core.RedisManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.ChatField;
	import ui.Cursor;
	import ui.UserInterface;
	import units.Ahappy;
	import units.AnimationItem;
	import units.Bathyscaphe;
	import units.Pet;
	import units.Walkresource;
	import utils.ActionsHelper;
	import utils.ObjectsContent;
	import utils.SocketEventsHandler;
	import wins.SimpleWindow;
	import units.Character;
	import units.Field;
	import units.Resource;
	import units.Techno;
	import units.Tree;
	import units.Unit;
	import units.Hero;
	import units.Personage;
	import units.WorkerUnit;
	import units.WUnit;
	import wins.AhappyAuctionWindow;
	import wins.BankSaleWindow;
	import wins.BonusVisitingWindow;
	import wins.CalendarWindow;
	import wins.DayliBonusWindow;
	import wins.DialogWindow;
	import wins.JamWindow;
	import wins.PurchaseWindow;
	import wins.ReferalRewardWindow;
	import wins.RouletteWindow;
	import wins.SaleBoosterWindow;
	import wins.ShopWindow;
	import wins.TriggerPromoWindow;
	import wins.Window;

	public class User extends EventDispatcher {
		//MODE
		public static const GUEST:int 	= 1;
		public static const OWNER:int	= 2;
		public static const PUBLIC:int	= 3;
		//LANDS
		public static const AQUA_HERO_LOCATION:int 	= 1388;
		public static const SHARK_LOCATION:int 		= 1226;
		public static const DUNGEON_LOCATION:int 	= 1402;
		public static const HOLIDAY_LOCATION:int 	= 1446;
		public static const TRAVEL_LOCATION:int 	= 1627;
		public static const FARM_LOCATION:uint 		= 1733;
		public static const SIGNAL_SOURCE:uint 		= 1851;
		public static const SOCKET_MAP:uint 		= 1852;
		public static const NEPTUNE_MAP:uint 		= 1881;
		public static const HUNT_MAP:uint 			= 2001;
		public static const VILLAGE_MAP:uint 		= 2133;
		public static const SCIENCE_MAP:uint 		= 2336;
		public static const SYNOPTIK_MAP:uint 		= 2404;
		public static const SWEET_MAP:uint 			= 2646;
		public static const HALLOWEEN_MAP:uint 		= 2633;
		public static const FISHLOCK_MAP:uint 		= 2698;
		public static const OMUT:uint 				= 2740;
		public static const MAP_2975:uint 			= 2975;
		public static const MAP_3069:uint 			= 3069;
		public static const LAND_1:uint 			= 4;
		public static const LAND_2:uint 			= 806;
		public static const LAND_4:uint 			= 1226;
		public static const HOME_WORLD:uint 		= 4;
		public static const JANE_WORLD:uint 		= 827;
		
		//SYNOPTIC LANDS
		public static const WEST_MAP:int 			= 2481;
		public static const SOUTH_MAP:int 			= 2480;
		public static const EAST_MAP:int 			= 2479;
		public static const NORTH_MAP:int 			= 2478;
		public static const SYNOPTIC_LANDS:Array 	= [2481,2480,2479,2478];
		
		//HERO
		public static const GIRL:uint 				= 15;
		public static const GIRL_BODY:uint 			= 11;
		public static const GIRL_HEAD:uint 			= 719;
		
		public static const BOY:uint 				= 14;
		public static const BOY_BODY:uint 			= 10;
		public static const BOY_HEAD:uint 			= 718;
		
		public static var sectorsLocations:Array 	= [1627, 1733, 2001, 2633, 2698, 2740, 2975, 3148];
		public static var checkBoxState:int = 1;
		
		public var buyActions:Object = {};
		
		public static var openExpJson:Object;
		
		public var auction:Auction;
		public var openedRadarMaps:Array = [];
		public var radarMaps:Object = {};
		public var id:String = '0'; 
		public var worldID:int = 1; 
		public var aka:String = ""; 
		public var sex:String = "m"; 
		public var email:String = ""; 
		public var first_name:String; 
		public var last_name:String; 
		public var photo:String; 
		public var year:int; 
		public var city:String;
		public var country:String;
		public var level:uint = 1; 
		public var tempLocation:Boolean = false; 
		public var worldTime:uint = 0; 
		public var world:World;
		private var _worlds:Object = {};
		private var _actionsUpdater:Updater;
		public var maps:Array = [];
		public var friends:Friends;
		public var quests:Quests;
		public var stock:Stock = null;
		public var units:Object;
		public var shop:Object = { };
		public var lastvisit:uint = 0;
		public var createtime:uint = 0;
		public var energy:uint = 0;
		public var freebie:Object = null;
		public var presents:Object = {};
		public var restore:int;
		public var promos:Array = [];
		public var promo:Object = { };
		public var boostPromos:Array = [];
		public var boostCompleteTime:int = 0;
		public var boostBlock:Boolean = false;
		public var oncePromos:Array = [];
		public var onceOfferShow:uint = 0;
		public var premiumPromos:Array = []; 
		public var money:int = 0; 
		public var pay:int = 0;
		public var countTechInInst:int = 0;
		public var blinks:Object = { };
		public var ministock:Object = { level:1 };
        private var timer:int = 0;
		public var plusMinus:uint = 0;
		public var currentGuestReward:Object;
		public var currentGuestLimit:uint = 0;
		public var wishlist:Array = [];
		public var gifts:Array = [];
		public var requests:Array = [];
		public var head:uint = 0;
		public var body:uint = 0;
		public var day:uint = 0;
		public var bonus:uint = 0;
		public var _6wbonus:Object = {};
		public var trialpay:Object = {};
		private var blinkContainer:Sprite;
		public var personages:Array = [];
		public var characters:Array = [];
		public var techno:Array = [];
		public var technoInInstance:Array = [];
		public var animals:Array = [];
		public var mode:int = OWNER;
		public var fmode:int = Friends.ALL;
		public var trades:Object;
		private var _settings:String = '';
		public var settings:Object = {ui:"111", f:"0"};
		public var gift:Object = null;
		public var ach:Object = {};
		public var hidden:int = 0;
		public var mbonus:Object = { };
		public var calendar:Object = { };
		public var daylics:Object = { };
		public var auctions:Object = { };//Ahappy
		public var bonusOnline:BonusOnline; // бонус за пребывание в игре
		public var reconnectCounter:int = 0; // бонус за пребывание в игре
		
		public var rooms:Object = {};
		public var wl:Object;
		
		public var diffvisit:int = 0;
		
		public var confirmDiamond:Boolean = false;
		
		public var charactersData:Array = [];
		public var daylicShopData:Object = {};
		public var apothecaryData:Object = {};
		public var fatmanData:Object = {};
		public var luckyBagData:Object = {};
		public var eventShopData:Object = {};
		private var circle:Shape;
        private var square:Shape;
		private var preloader:Preloader;
        private var One:Number = 0;
        private var Scale:Number = 8;
		private var PlusScale:Boolean = true;
		public var requestsInvite:Object = { }
		public var allreadyInvite:Object = { }
		public var socInvitesFrs:Object = { }
		
		public var boosterTimer:int = 180 + Math.floor(120 * Math.random());
		public var boosterTimeouts:int = 900;
		public var boosterLimit:int = 4;
		
		public var topID:int = 0;
		public var top:Object = { };
		
		public var instance:Object = { };		//D gbuilding
		public var instanceWorlds:Object = {};	//D
		private var _bathyscaphe:Bathyscaphe;

		public var ref:String = ""; 
		public var keepers:Object = {
			79:0,
			80:0,
			81:0
		}
		
		public function User(id:String){
			this.id = id;
			
			first_name 	= App.network.profile.first_name || 'Gamer';
			last_name 	= App.network.profile.last_name || '';
			sex 		= App.network.profile.sex;
			photo		= App.network.profile.photo;
			year		= App.network.profile.year || 0;
			city		= App.network.profile.city || '';
			country		= App.network.profile.country || '';
			email		= App.network.profile.email || '';
			
			if (id == '91831684')
				sex = 'f';
				
				
			if (id == '1')
				worldID = 228;
				
			if (id == '29060311' || id == '83730403' || id == '89824749'|| id == '473082136')
		    {
				App.network.appFriends = ['437526134','376089319','29060311', '83730403', '159185922', '1401191194', '98160788', '145579072', '216968557', '19046676', '96391814', '111222333', '50545195', '413309776'];
				
			}
			//	sex = 'm';
			//}
			
			Log.alert('STATE User');
			if (!App.network.appFriends)
				App.network.appFriends = [];
			var send:Object = {
				'ctr':'user',
				'act':'state',
				'city':city,
				'country':country,
				'uID':id,
				'year':year,
				'sex':sex,
				'social':(App.social != 'DM') ? App.social : 'VK',
				'email':email//,
				//,
				//'aka':first_name + ' ' + last_name,
				//'photo':photo
				//'friends':JSON.stringify(App.network.appFriends), //((User.cheater) ? '[]' : JSON.stringify(App.network.appFriends)), 
			};
			/*if (App.isSocial('AM'))
			{
				send['friends'] = JSON.stringify(App.network.friends);
			}*/
			if (Capabilities.playerType != 'StandAlone')
			{
				send['photo'] = photo;
				send['aka'] = first_name + ' ' + last_name;
				send['friends'] = JSON.stringify(App.network.appFriends);
			}else{
				send['fnochange'] = '1';
				send['friends'] = JSON.stringify([]);
			}
			
			
			if (App.blink.length > 0)
				send.blink = App.blink;
			
			Post.send(send, onLoadData);
		}
		
		public var data:Object;
		
		private function onUILoad(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_UI_LOAD, onUILoad);
			
			// Boosts
			activeBooster();
		}
		
		public static function findWorldId(userID:String):int {
			if (userID == "1")
				return JANE_WORLD;
				
			return HOME_WORLD;
		}
		
		private var _pet:Pet;
		public function get pet():Pet 
		{
			return _pet;
		}
		
		public function set pet(value:Pet):void 
		{
			_pet = value;
		}
		
		
		public static function get inExpedition():Boolean {
			
			/*openExpJson = null;// SON.parse(App.data.options.expeditionChange);
			if (App.SERVER == 'DM' && openExpJson)
			{
				return false;
			}*/			
			
			if (App.data.storage[App.user.worldID].size == World.MINI) return true;
			return false;
		}
		
		// Auction connection
		/*public function initAuction():void {
			var auction:Object;
			var place:int = 0;
			var endTime:int = 0;
			
			for each(var auctObject:Object in auctions) {
				for each(var ahappySID:* in Ahappy.ahappys) {
					var ahappy:Object = App.data.storage[ahappySID];
					if (!ahappy.items.indexOf(auctObject.aid) == -1) continue;
					
					if (auctObject.started + ahappy.duration > App.time) {
						endTime = auctObject.started + ahappy.duration;
						auction = auctObject;
					}
					break;
				}
			}
			
			if (!auction)
				return;
			
			// Расчет позиции игрока относительно остальных
			var users:Array = [];
			for (var uid:* in auction.users) {
				users.push( {
					uid:	uid,
					count:	auction.users[uid].count
				});
			}
			users.sortOn('count', Array.NUMERIC | Array.DESCENDING);
			for (var i:int = 0; i < users.length; i++) {
				if (users[i].uid == id)
					place = i + 1;
			}
			
			App.ui.leftPanel.createAhappyIcon(place, endTime);
			App.self.addEventListener(AppEvent.ON_LEVEL_UP, App.ui.leftPanel.createAhappyIcon);
			
			RedisManager.listenRooms([auction.room])
		}
		
		public function redisHandle(data:Object):void {
			
			// необходимые поля act, sid, uid
			if (!data || (data is int) || !data.hasOwnProperty('act') || !data.hasOwnProperty('sid') || !data.hasOwnProperty('uid')) return;
			
			var auction:Object;
			
			for (var auID:* in auctions) {
				var ahappy:Object = App.data.storage[data.sid];
				if (auctions[auID].started + ahappy.duration > App.time) {
					auction = auctions[auID];
				}
			}
			
			var window:* = Window.isClass(AhappyAuctionWindow);
			
			if (!auction) return;
			
			// Обновление данных по happy
			if (data.act == 'connect' || data.act == 'update') {
				if (Numbers.countProps(auction.users) < 4 && !auction.users[data.uid]) {
					auction.users[data.uid] = {
						count:	0,
						photo:	data.photo,
						uid:	data.uid,
						aka:	data.aka,
						level:	data.level,
						action:	App.time
					}
				}
			}
			
			// Обновление активности пользователя
			if (data.act == 'connect' || data.act == 'update' || data.act == 'online') {
				if (auction.users[data.uid])
					auction.users[data.uid]['action'] = App.time;
			}else if (data.act == 'offline') {
				if (auction.users[data.uid])
					auction.users[data.uid]['action'] = 0;
			}
			
			switch(data.act) {
				case 'online':
					if (window)
						window.setOnline(data.uid);
					
					break;
				case 'offline':
					if (window)
						window.setOnline(data.uid, false);
					
					break;
				case 'connect':
					if (Ahappy.ahappy)
						Ahappy.ahappy.auction = auction;
					
					if (window) {
						window.auction = auction;
						window.updateState();
					}
					
					break;
				case 'update':
					for (var uid:String in auction.users) {
						if (App.user.id == uid || uid != data.uid) continue;
						
						auction.users[uid].count = data.count;
						break;
					}
					
					if (Ahappy.ahappy)
						Ahappy.ahappy.auction = auction;
					
					if (window) {
						window.auction = auction;
						window.updateState();
					}
					
					break;
			}
			
			initAuction();
		}*/
		
		private function onLoadData(error:int, data:Object, params:Object):void {
			if (error) return;

			this.data = data;
			if(App.user.data.user.modefriends)
				fmode = App.user.data.user.modefriends;
			if (App.social == 'FS' && this.data.user.sex == 'w')
				this.data.user.sex = 'f';
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_USERDATA_COMPLETE));
			
			
			
			if (App.isSocial('AM'))
			{
				if (ExternalInterface.available)
				{
					ExternalInterface.addCallback("updateApplicants", function(content:Array):void {
						for each(var usr:* in content){
							allreadyInvite[usr.to.id] = usr.to;
						}
					});
					ExternalInterface.call("getApplicants");
					
					ExternalInterface.addCallback("updateRequests", function(_content:Array):void {
						for each(var frnd:* in _content){
							requestsInvite[frnd.from.id] = frnd.from;
						}
					});
					ExternalInterface.call("getRequests");
				}
			}
		}
		
		public function checkRadarMaps():void
		{
			//return;
			for (var _sid:* in App.data.storage)
			{
				if (App.data.storage[_sid].type == 'Lands' && App.data.storage[_sid].maptype == 1)
				{
					if (App.data.storage[_sid].hasOwnProperty('expire') && App.data.storage[_sid].expire.hasOwnProperty(App.social)&& App.data.storage[_sid].expire[App.social] > App.time)
					{
						if (!App.user.worlds.hasOwnProperty(_sid) && Numbers.countProps(App.user.data.tempWorlds) == 0)
						{
							App.user.worlds[_sid] = _sid;
							onpenRadarMap(int(_sid));
						}
					}
				}
			}
		}
		
		private function onpenRadarMap(location:int):void
		{
			//if (Numbers.countProps(App.user.radarMaps)>0)
			//{
				//var index:int = (Math.random() * Numbers.countProps(App.user.radarMaps));
				//location = Numbers.getProp(App.user.radarMaps, index).key;
				//var variant:int = location.val.vars[int(Math.random() * location.val.vars.length)];
				//location = 1851;
			if (App.user.data.hasOwnProperty('tempWorlds') && Numbers.countProps(App.user.data['tempWorlds']) > 0)
			{
				for each(var _coords:* in App.user.data['tempWorlds'])
				{
					for (var _pos:* in ObjectsContent.RADAR_POSITIONS)
					{
						if (_coords['x'] == ObjectsContent.RADAR_POSITIONS[_pos]['x'] && _coords['y'] == ObjectsContent.RADAR_POSITIONS[_pos]['y'])
							ObjectsContent.RADAR_POSITIONS.splice(_pos, 1);
					}
				}
			}
			
			var index:int = Math.random() * ObjectsContent.RADAR_POSITIONS.length;
			var radarPosition:Object = ObjectsContent.RADAR_POSITIONS[index];
			
			var send:Object = {
				'ctr':'user',
				'act':'generateWorld',
				'uID':App.user.id, 
				'wID':location,
				'x':radarPosition.x,
				'y':radarPosition.y
			};
			
			Post.send(send, onRadarData);
			//}
		}
		
		private function onRadarData(error:int, data:Object, params:Object):void
		{
			if (error) return;
			if (data.hasOwnProperty('wID'))
			{
				App.user.openedRadarMaps.push(int(data['wID']));
				App.user.worlds[int(data['wID'])] = int(data['wID']);
			}
			if (data.hasOwnProperty('x'))
			{
				App.user.data['tempWorlds'][int(data['wID'])] = {x:0, y:0};
				App.user.data['tempWorlds'][int(data['wID'])]['x'] = data['x'];
			}
			if (data.hasOwnProperty('y'))
			{
				App.user.data['tempWorlds'][int(data['wID'])]['y'] = data['y'];
			}
		}
		
		public var arrHeroesInRoom:Array = [];
		public function onLoad(error:int, data:Object, params:Object):void {
			
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			Log.alert("DEEP: User.onLoad");
			
			bonusOnline = new BonusOnline(data.user);
			
			ach = data.ach || { };
			
			if (!ach) ach = { };
			for (var ac:* in App.data.ach) {
				if (!ach[ac]) {
					ach[ac] = { };
				}
			}
			
			if (data.user && data.user.invite) {
				socInvitesFrs = data.user.invite;
			}
			
			data.friends[1].photo = Config.getImageIcon('avatars','ChiefAvatar'); 
			App.ref = data.user['ref'] || "";
			
			for (var properties:* in data.user)
			{
				if (properties == 'friends') 
					continue;
				
				if (properties == 'wID') {
					worldID = data.user[properties];
					continue;
				}	
				
				if (properties == 'settings') {
					try{
						_settings = data.user[properties];
						settings = JSON.parse(_settings);
					}catch (e:*) {}
					if (!settings['ui']) settings['ui'] = '111';
					if (!settings['f']) settings['f'] = '0';
					continue;
				}
				
				if(this.hasOwnProperty(properties))
					this[properties] = data.user[properties];
			}
			
			this.worlds = {};
			// Worlds
			checkWorlds(data);
			// Units
			units = data.units;
			
			
			// На МИНИ локации другой склад. Переносим в него системные материалы и создаем из ресурсов мира
			if (App.data.storage[worldID].size == World.MINI) {
				if (!data.world.hasOwnProperty('stock')) data.world['stock'] = { };
				for (properties in data.stock) {
					if (App.data.storage.hasOwnProperty(properties) && App.data.storage[properties].mtype == 3)
						data.world.stock[properties] = data.stock[properties];
				}
				stock = new Stock(data.world.stock);
				//stock = new Stock(data.stock);
			}else{
				stock = new Stock(data.stock);
			}
			
			//if (data.user.profile) 
			//{
				//App.user.body = data.user.profile[1];// settings.body;
			//}else {
				//if (sex == 'f') App.user.body = User.GIRL_BODY;
				//else 			App.user.body = User.BOY_BODY;
			//}
			
			/*if (data.user.profile) {
				for (var val:* in data.user.profile) {
					for (var k:int = 0; k < aliens.length; k++ ) {
						if (val == aliens[k].sid)
							aliens[k].type = getClothView(data.user.profile[val]);
						
					}
				}
			}*/
			
			if (App.network['friends'] != undefined) {
				for (var _i:* in App.network.friends) {
					
					var fID:String = '';
					if (App.network.friends[_i] is Object && App.network.friends[_i].hasOwnProperty('uid')) {
						fID = App.network.friends[_i].uid;
					}else{
						fID = App.network.friends[_i];
					}
					
					if (data.friends[fID] != undefined) {
						for (var key:* in App.network.friends[_i]) {
							data.friends[fID][key] = App.network.friends[_i][key];
						}
					}
				}
			}
			
			
			if (!ExternalInterface.available) {
				var networkDefoult:Object = { };
				networkDefoult['1'] = {
					"uid"           : 1,//friend["uid"],
					"first_name"    : 'User',//friend["first_name"],
					"last_name"     : 'Real_user',
					"photo"	        : '',
					"url"  			: "http://vk.com/id" + 1,
					"sex"           : 'm'//friend["sex"] == 2 ? "m" : "f"
				}
				
				for (var _j:* in data.friends) {
					var fID2:int = data.friends[_j].uid;
					if (data.friends[fID2] != undefined) {
						for (var key2:* in networkDefoult[1]) {
							if (!data.friends[fID2].hasOwnProperty(key2)) {
								if (key2 == 'photo')
									data.friends[fID2][key2] = Config.getImage('avatars', 'av_1'/* + int(Math.random() * 2 + 1)*/);
								else
									data.friends[fID2][key2] = networkDefoult[1][key2];
							}
						}
					}
				}
			}
			
			friends = new Friends(data.friends);
			
			promo 		= data.promo;
			freebie     = data.freebie;
			presents	= data.presents;
			trades		= data.trades;
			
			for (var item:* in App.data.storage) {
				if (App.data.storage[item].type == 'Maps' /*&& User.inUpdate(item)*/)//временно
					maps.push(App.data.storage[item]);
			}
			
			for each(var sID:String in data.user.wl) {
				wishlist.push(sID);
			}
			
			if (data.hasOwnProperty('keepers'))
				keepers		= data.keepers;
			
			
			Console.addLoadProgress("User: 2");
			for (var gID:String in data.gifts) {
				if (gID == 'limit') continue;
				Gifts.addGift(gID, data.gifts[gID]);
			}
			
			gifts.sortOn("time");
			gifts.reverse();
			
			world = new World(data.world);
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_WORLD_LOAD));
			quests = new Quests(data.quests);
			
			initTutorial();
			
			if (App.data.options.hasOwnProperty('SaySomething')) 
			{
				try {
					User.phrases = JSON.parse(App.data.options['SaySomething']);
					for (var _param:* in User.phrases)
					{
						switch(_param){
							case 'Default':
								for each(var phrase1:* in User.phrases['Default'])
								{
									var _word1:String = Locale.__e(phrase1);
									if (phrase1 && _word1.search('flash') != -1)
									{
										User.phrases['Default'].splice(User.phrases['Default'].indexOf(phrase1), 1);
										trace('deleted ->' + _word1);
									}
								}
								break;
							case 'sids':
								for (var _sid:* in User.phrases['sids'])
								{
									for (var i:int = 0; i < User.phrases['sids'][_sid].length;i++ )
									{
										var _word2:String = Locale.__e(User.phrases['sids'][_sid][i]);
										if (User.phrases['sids'][_sid][i] && _word2.search('flash') != -1)
										{
											User.phrases['sids'][_sid].splice(User.phrases['sids'][_sid].indexOf(User.phrases['sids'][_sid][i]), 1);
											trace('deleted ->' + _word2);
											i--;
										}
									}
								}
								break;
							case 'Walkgolden':
								for each(var phrase3:* in User.phrases['Walkgolden'])
								{
									var _word3:String = Locale.__e(phrase3);
									if (phrase3 && _word3.search('flash') != -1)
									{
										User.phrases['Walkgolden'].splice(User.phrases['Walkgolden'].indexOf(phrase3), 1);
										trace('deleted ->' + _word3);
									}
								}
								break;
						}
					}
					//User.phrases = (App.lang=='en')?(JSON.parse(App.data.options['SaySomethingFB'])):(JSON.parse(App.data.options['SaySomething']));
				}catch (e:*) {
					return;
				}
			}
			
			
			checkTempLocation();
			
			checkRadarMaps();
			
			if (!App.isJapan())
			{
				connectSocket();
				
				App.user.auction = new Auction();
				App.user.auction.init();
			}
			//акции
			if (!App.isJapan())
			{
				if (level > 10)
					ActionsHelper.createUserActions(true);
			}
			
			App.self.checkGroup();
			//акции old
			//updateActions();
			
			// Roulette
			//RouletteWindow.parse(data.user);
			
			//TODO инициализируем зависимые объекты
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_USER_COMPLETE));
			App.self.setOnTimer(totalTimer);
			
			CalendarWindow.format();
			
		}
		
		public function get useSectors():Boolean 
		{
			if (App.user.mode == User.OWNER && !App.self.fakeMode && 
			   (User.sectorsLocations.indexOf(App.user.worldID) != -1 || 
			   (App.user.openedRadarMaps.indexOf(App.user.worldID) != -1)))
				return true;
			if (App.user.mode == User.PUBLIC)
				return true;
			return false;
		}
		public function checkWorlds(_data:*):void 
		{
			for each(var wID:* in _data.user.worlds) 
			{
				this.worlds[int(wID)] = int(wID);
				if (App.data.storage[int(wID)].maptype == 1 && App.user.openedRadarMaps.indexOf(int(wID)) == -1)
				{
					openedRadarMaps.push(int(wID));
				}
			}
		}
		public static var phrases:Object;
		public function initTutorial():void 
		{
			return;
			if (id == '1')
				storageStore('tutorial', { c:1, s:0 } );
				
			
			
			var tutorial:Object = storageRead('tutorial', { c:0, s:1 } );
			
			if (typeof(tutorial) == 'number') {
				tutorial = { c:0, s:1 };
				storageStore('tutorial', tutorial);
			}
			
			/*if (!tutorial.c && !quests.data.hasOwnProperty(5)) {
				App.tutorial = new Tutorial();
				App.tutorial.show(tutorial.s);
			}else {
				Tutorial.mainTutorialComplete = true;
			}*/
		}
		
		public function addInstance(sid:int):void
		{
			
			if (instance.hasOwnProperty(sid))
				instance[sid] = instance[sid] + 1;
			else
				instance[sid] = 1;
		}
		
		public function dellInstance(sid:int):void
		{
			if (instance.hasOwnProperty(sid))
				instance[sid] = instance[sid] - 1;

		}
		
		private function getClothView(sID:uint):String
		{
			return App.data.storage[sID].preview;
		}
		
		//акции
		public function checkOpenNew():void 
		{
			App.ui.resize();
			if (App.data.actions)
			{
				for each(var actn:* in App.data.actions)
				{
					if(actn.unlock && actn.unlock.level == App.user.level){
						for each(var prIcon:* in App.ui.salesPanel.promoIcons)
						{
							prIcon.onClick();
							return;
							//App.ui.salesPanel.promoIcons;
							
						}
					}
				}
			}
		}
		
		public var promoFirstParse:Boolean = true;
		public function updateActions():void 
		{
			ActionsHelper.updateActions();
		}
		
		public function buyPromo(pID:String):void {
			if (App.data.actions[pID]['more'] == 1) return;  
			
			var actionsArch:Object = storageRead('actions', {});
			if (!actionsArch.hasOwnProperty(pID)){
				 actionsArch[pID] = {};
			}
			actionsArch[pID]['buy'] = 1;
			
			if (promo[pID]) {
				promo[pID]['buy'] = 1;
				promos.splice(promos.indexOf(promo[pID]), 1);
			} else {
				for (var i:int = 0; i < premiumPromos.length; i++) {
					if (premiumPromos[i].pID == pID) {
						premiumPromos[i]['buy'] = 1;
						premiumPromos.splice(premiumPromos.indexOf(premiumPromos[pID]), 1);
					}
				}
			}
			
			storageStore('actions', actionsArch, true);
		}
		
		public function unprimeAction(pID:String):void {
			var actionsArch:Object = storageRead('actions', {});
			if (actionsArch.hasOwnProperty(pID)) 
				actionsArch[pID]['prime'] = 0;
			promo[pID]['prime'] = 0;
			
			storageStore('actions', actionsArch);
		}
		
		public var aliens:Array;
		
		public function addPersonag():void
		{
			personages = [];
			var position:Object = App.map.heroPosition;
			var heroSid:int = 0;
			if (sex == "m")
			{
				heroSid = BOY;
			}else{
				heroSid = GIRL;
			}
			var hero:Hero = new Hero(this, { id:1, sid:heroSid, x:position.x, z:position.z/*, alien:aliens[i].type, aka:aliens[i].aka */} );
			hero.beginLive();
			
			personages.push(hero);
		}
		
		
		public function get hero():Hero {
			for each(var hero:Hero in App.user.personages) {
				if (hero.main)
					return hero;
			}
			return App.user.personages[0];
		}
		
		public function get worlds():Object 
		{
			return _worlds;
		}
		
		public function set worlds(value:Object):void 
		{
			_worlds = value;
		}
		
		public function getHeroByType(type:String):Hero
		{
			for each(var hero:Hero in App.user.personages) {
				if (hero.info.preview == type)
					return hero;
			}
			return App.user.personages[0];
		}
		
		public function returnHero(sid:uint, position:Object):void {
			if (sid ==0) 
			{
				sid = 177
			}
			if (App.data.storage[sid].type == "Character") {
				for (var i:int = 0; i < charactersData.length; i++) {
					if (sid == charactersData[i].sid) {
						var _character:Character = new Character({id:1, sid:charactersData[i].sid, x:position.x, z:position.z, type:charactersData[i].type});
						_character.cell = position.x;
						_character.row = position.z;
						_character.calcDepth();
						
						var index:int = arrHeroesInRoom.indexOf(sid);
						if (index != -1) arrHeroesInRoom.splice(index, 1);
						break;
					}
				}	
			}else {
				for (i = 0; i < aliens.length; i++) {
					if (sid == aliens[i].sid) {
						var _hero:Hero = new Hero(this, { id:Personage.HERO, sid:aliens[i].sid, x:position.x, z:position.z, alien:aliens[i].type, aka:aliens[i].aka } ); 
						personages.push(_hero);
						_hero.cell = position.x;
						_hero.row = position.z;
						_hero.calcDepth();
						
						index = arrHeroesInRoom.indexOf(sid);
						if (index != -1) arrHeroesInRoom.splice(index, 1);
						break;
					}
				}	
			}
				
			App.ui.upPanel.update();
		}
		
		
		public static function inUpdate(sid:*):Boolean {
			if (App.user.id == '83730403')
				return true;
			var fsid:String = String(sid);
			var find:Boolean = false;
			
			for (var update:String in App.data.updatelist[App.social]) {
				if ((App.data.updates[update].social.hasOwnProperty(App.social) && App.data.updates[update].items && App.data.updates[update].items.hasOwnProperty(fsid)) || (App.data.updates[update].ext && App.data.updates[update].ext.hasOwnProperty(App.social) && App.data.updates[update].stay && App.data.updates[update].stay.hasOwnProperty(fsid))) {
					find = true;
					break;
				}
			}
			
			return find;
		}
		
		public static function getUpdate(sid:int):String
		{
			var needUpdate:String = ""
			for (var upd:* in App.data.updates)
			{
				for (var itm:* in App.data.updates[upd].items)
				{
					if (sid == itm){
						
						needUpdate = upd;
						return needUpdate
					}
				}
			}
			return needUpdate;
		}
		
		public static function get isOwner():Boolean
		{
			if (App.user.mode == User.PUBLIC && App.owner.id == App.user.id)
				return true;
			else
				return false;
			
		}
		
		
		private var multiply:Object = { 227:2 };
		private var whimsyTerms:Object = { 43:{skip:1}, 42:{skip:1}, 41:{skip:1}, 73:{skip:1} }; //Нектар Опыт Монеты
		private var numOfShow:int = 3;
		public var triggerOpen:int = 0;
		public function showBooster(type:* = null):void {
			
			if (App.isJapan()) return;
			
			var boostCanSell:Array = [];
			var skipBoost:Boolean;
		
			
			var delay:int = 0;
			for each(var s_:* in whimsyTerms) {
				if (int(s_.skip)>0) 
				{
				delay = 1;	
				}
			}
			if (!delay) 
			{
			boosterTimer = boosterTimeouts*10;	
			}
			/*
			if (level > 4 && numOfShow > 0 && boostCanSell.indexOf(int(type)) >= 0 && !Window.hasType(SaleBoosterWindow)) {
				new SaleBoosterWindow( { popup:true, pID:String(type)} ).show();
				numOfShow --;
			}*/
				for (var i:int = 0; i < boostPromos.length; i++) {
				skipBoost = false;
				for (var s:String in boostPromos[i].items) {
					/*for (var s2:String in App.data.storage[s].outs) {*/
						if (stock.data.hasOwnProperty(s) && stock.data[s] > App.time) {
							skipBoost = true;
						}
					//}
				//}
				if (!skipBoost) {
					if (multiply.hasOwnProperty(boostPromos[i].pID)) {
						for (var j:int = 1; j < multiply[boostPromos[i].pID]; j++)
						if (whimsyTerms[int(boostPromos[i].pID)].skip>0) 
						{
							boostCanSell.push(int(boostPromos[i].pID));
							//whimsyTerms[int(boostPromos[i].pID)].skip--;
						}
							
					}
					if (whimsyTerms[int(boostPromos[i].pID)].skip>0) 
						{
							boostCanSell.push(int(boostPromos[i].pID));
						//	whimsyTerms[int(boostPromos[i].pID)].skip--;
						}
				}	
				}
			}
			
			
			var index:int = 0;
			/*for (var s:String in whimsyTerms) {
				if (App.user.stock.count(int(s)) < App.time)
					boostCanSell.push(int(s));
			}*/
			if (boostCanSell.length > 0)
			
				index = boostCanSell[Math.floor(Math.random() * boostCanSell.length)];
				
				
			
			//trace( boostCanSell.indexOf(index));
			//trace(!Window.hasType(SaleBoosterWindow));
			if (SaleBoosterWindow.boosterWindowIsNotBusy && Cursor.plant && level > 4 && boostCanSell.indexOf(index) >= 0 && !Window.hasType(SaleBoosterWindow)) {
				new SaleBoosterWindow( { popup:true, pID:String(index) } ).show();
				whimsyTerms[index].skip--;
				boosterTimer = boosterTimeouts;
				boosterLimit --;
				SaleBoosterWindow.boosterWindowIsNotBusy = false;
			}
		}
		
		
		public function activeBooster():void {
			return;
			boostCompleteTime = 0;
			for (var id:String in stock.data) {
				//App.data.storage[id].type
				if (App.data.storage[id].type == 'Vip' && stock.data[id] > App.time) {
					var percent:Number = 0;
					var boosted:int = 0;
					for (var s:String in App.data.storage[id].outs) {
						boosted = int(s);
						boosted = int(s);
						percent = App.data.storage[id].outs[s];
						break;
					}
					switch(boosted) {
						case Stock.EXP: App.ui.upPanel.expBoost.show(percent);
						/*setTimeout(function () : void
						{
							unactiveBooster()
						}, (stock.data[id]+1-App.time)*1000);*/
						break;
						case Stock.COINS: App.ui.upPanel.coinsBoost.show(percent); 
						/*setTimeout(function () : void
						{
							unactiveBooster()
						}, (stock.data[id]+1-App.time)*1000);*/
						break;
						
					case Stock.FANTASY: 
						/*if (App.data.storage[id].sID == Stock.MORE_ENERGY) 
						{
							App.ui.upPanel.energyBoost.show(Locale.__e('flash:1427979479987'),true);//-1
							Stock.energyRestoreSettings = App.data.options['EnergyRestoreTime'] - App.data.options['EnergyRestoreTime'] * App.data.storage[Stock.MORE_ENERGY].outs[Stock.FANTASY] / 100;
							if (Stock.energyRestoreSettings < 5) Stock.energyRestoreSettings = 5;
							stock.diffTime = Stock.energyRestoreSettings;
						}
						if (App.data.storage[id].sID == Stock.ENERGY_BOOM) 
						{
							App.ui.upPanel.energyBoost.show(Locale.__e('flash:1449141376637'),true);//-2.25
							Stock.energyRestoreSettings = App.data.options['EnergyRestoreTime'] - App.data.options['EnergyRestoreTime'] * App.data.storage[Stock.ENERGY_BOOM].outs[Stock.FANTASY] / 100;
							if (Stock.energyRestoreSettings < 5) Stock.energyRestoreSettings = 5;
							stock.diffTime = Stock.energyRestoreSettings;
						}*/
						
						/*setTimeout(function () : void
						{
							unactiveBooster()
						}, (stock.data[id]+1-App.time)*1000);*/
						break;
					}
					if (boostCompleteTime == 0 || boostCompleteTime > stock.data[id])
						boostCompleteTime = stock.data[id];
				}
			}
		}
		
		public function unactiveBooster():void {
			for (var id:String in stock.data) {
				if (App.data.storage[id].type == 'Vip' && stock.data[id] <= App.time) {
					for (var s:String in App.data.storage[id].outs) break;
					switch(int(s)) {
						case Stock.EXP: App.ui.upPanel.expBoost.hide(); break;
						case Stock.COINS: App.ui.upPanel.coinsBoost.hide(); break;
						case Stock.LIGHT: App.ui.bottomPanel.lightBoost.hide(); break;
						case Stock.FANTASY: App.ui.upPanel.energyBoost.hide(); 
						Stock.energyRestoreSettings = App.data.options['EnergyRestoreTime'];
						break;
					}
				}
			}
		}
		
		public function removePersonage(sid:uint):void 
		{
			for (var i:int = 0; i < personages.length; i++ ) {
				var _hero:Hero = personages[i];
				if (_hero.sid == sid) {
					arrHeroesInRoom.push(sid);
					_hero.stopAnimation();
					_hero.uninstall();
					_hero = null;
					personages.splice(i, 1);
					i--;
				}
			}
			for ( i = 0; i < characters.length; i++ ) {
				var _character:Character = characters[i];
				if (_character.sid == sid) {
					if(arrHeroesInRoom.indexOf(sid) == -1)
						arrHeroesInRoom.push(sid);
						
					_character.stopAnimation();
					_character.uninstall();
					_character = null;
					characters.splice(i, 1);
					i--;
				}
			}
			App.ui.upPanel.update();
		}
		
		public function onStopEvent(e:MouseEvent = null):void {
			if (hero == null) return;
			if (ChatField.self)
				ChatField.self.dispose();
			for (var i:int = 0; i < personages.length; i++ ) {
				var pers:Hero = personages[i];
				if(pers._walk){
					pers.stopWalking();
				}
				pers.tm.dispose();
				pers.finishJob();
				if (pers.path) {
					pers.path.splice(0, pers.path.length);
				}
			}
			
			for each(var target:* in App.user.queue)
			{
				if (target.target.ordered)
				{
					target.target.ordered = false;
					target.target.worker = null;
					if (!target.target.formed)
					{
						target.target.uninstall();
					}
				}
				if (target.target.hasOwnProperty('reserved') && target.target.reserved > 0) {
					target.target.reserved = 0;
				}
			}
			
			Field.clearBoost();
			for (i = Field.planting.length - 1; i > -1; i--) {
				Field.planting[i].removePlant();
				Field.planting.splice(i, 1);
			}
			var fields:Array = Field.findFields();
			for (i = 0; i < fields.length; i++) {
				if (!fields[i].formed) {
					fields[i].uninstall();
				}
			}
			
			App.user.queue = [];
			Cursor.type = 'default';
			Cursor.plant = false;
			if (ShopWindow.currentBuyObject.type) {
				ShopWindow.currentBuyObject.type = null;
			}
			if (ShopWindow.currentBuyObject.currency) {
				ShopWindow.currentBuyObject.currency = null;
			}
			
			
		}

		
		public function goHome():void 
		{
			//worldID = User.HOME_WORLD;
			Log.alert('STATE goHome');
			Post.send( {
				'ctr':'user',
				'act':'state',
				'uID':id,
				'wID':worldID,
				'fields':JSON.stringify(['world'])
			}, onWorldLoad /*function onLoad(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					//Обрабатываем ошибку
					return;
				}
				
				for (var properties:* in data.user)
				{
					if (properties == 'friends') 
					continue;
					this[properties] = data.user[properties];
				}
				
				units = data.units;
				world = new World(data.world);
				
				this.worlds = {};
				for each(var wID:* in data.user.worlds) 
				{
					this.worlds[int(wID)] = int(wID);
				}
				
				
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_USER_COMPLETE));
			}*/);
		}
		public function loadDump(tID:String):void {
			Post.send( {
				'ctr':'dump',
				'act':'make',
				'uID':id,
				'tID':tID
			},  function onLoad(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					//Обрабатываем ошибку
					return;
				}
				ExternalApi.reset()
			});
		}
		
		public function onProfileUpdate(data:Object):void 
		{
			var postData:Object = {
				'ctr':'user',
				'act':'profile',
				'uID':id,
				'pID':1
			}
			
			for (var key:* in data) {
				postData[key] = data[key];
			}
			
			Post.send(postData,  function onLoad(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					//Обрабатываем ошибку
					return;
				}
			});
			
			/*var postData:Object = {
				ctr:	'user',
				act:	'profile',
				uID:	id,
				pID:	0,
				sID:	data.body
			}
			
			var dataBody:uint = data.body;
			Post.send(postData,  function onLoad(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				body = dataBody;
				//if (colotherEnterBonus > 0)
					//App.ui.flashGlowing(App.ui.upPanel.energyPanel);
			});*/
		}
		
		public function dreamEvent(wID:int):void 
		{
			App.self.setOffTimer(onLockTime);
			Log.alert('STATE dreamEvent');
			Connection.disconnect();
			SocketEventsHandler.personages = new Object();
			SocketEventsHandler.objects = {'resources':{}};
			worldID = wID;
			Post.send( {
				'ctr':'user',
				'act':'state',
				'uID':id,
				'wID':wID,
				'fields':JSON.stringify(['world','stock'])
			}, onWorldLoad);
		}
		
		public function onWorldLoad(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				//Обрабатываем ошибку
				return;
			}
			
			if (App.data.storage[worldID].size == World.MINI)
			{
				if (!data.world.hasOwnProperty('stock')) 
					data.world['stock'] = { };
				for (properties in data.stock)
				{
					if (App.data.storage.hasOwnProperty(properties) && App.data.storage[properties].mtype == 3)
						data.world.stock[properties] = data.stock[properties];
				}
				//App.self.setOffTimer(App.user.stock.checkEnergy);
				stock = new Stock(data.world.stock);
			}else {
				//App.self.setOffTimer(App.user.stock.checkEnergy);
				stock = new Stock(data.stock);
			}
			
			units = data.units;
			
			for each (var unt:* in units)
			{
				
				if (App.data.storage[unt.sid].type == 'Bridge')
					trace();
			}
			world = new World(data.world);
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_WORLD_LOAD));
			for (var properties:* in data.user)
			{
				if (properties == 'friends') 
					continue;
				
				if (properties == 'wID') {
					worldID = data.user[properties];
					continue;
				}	
				
				if (properties == 'settings') {
					try{
						_settings = data.user[properties];
						settings = JSON.parse(_settings);
					}catch (e:*) {}
					if (!settings['ui']) settings['ui'] = '111';
					if (!settings['f']) settings['f'] = '0';
					continue;
				}
				
				if(this.hasOwnProperty(properties))
					this[properties] = data.user[properties];
			}
			/*for (var properties:* in data.user)
			{
				if(this.hasOwnProperty(properties))
					this[properties] = data.user[properties];
			}*/
			
			// Worlds
			this.worlds = {};
			this.reconnectCounter = 0;
			checkWorlds(data);
			
			/*for each(var wID:* in data.user.worlds) 
			{
				this.worlds[int(wID)] = int(wID);
				if (App.data.storage[int(wID)].maptype == 1 && !openedRadarMap)
				{
					openedRadarMap = int(wID);
				}
			}
			*/
			checkTempLocation();
			
			checkRadarMaps();
			
			connectSocket();
				
			
			//Акции
			if (!App.isJapan())
			{
				if (level > 10)
					ActionsHelper.createUserActions(true);
			}
			CalendarWindow.format();
			/*var worlds:Object = {};
			for each(var wID:* in this.worlds) {
				worlds[int(wID)] = int(wID);
			}
			this.worlds = worlds;*/
			
			//Забрать награду если победил в аукционе
			//if (/*worldID == User.HOME_WORLD && */App.user.auction) {
				//проверить и если есть получпить
				//App.user.auction.checkReward();
			//}
			if(App.user.auction)
				App.user.auction.init();//дернуть лист чтобы получить возврать если вашу ставку перебили
			
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_USER_COMPLETE));
		}
		
		public function connectSocket():void
		{
			//return;
			if (App.user.worldID == User.SOCKET_MAP)
			{
				Connection.init({
					onParamsConnect:function(e:*):void{
						var _owner:Object = {
							sex:App.user.sex,
							head:App.user.head,
							body:App.user.body,
							photo:App.user.photo,
							id:App.user.id
						}
						var users:Array = Connection.activeUsers;
						Connection.subscribe();
						Connection.sendMessage({u_event:'hero_load', aka:App.user.aka, params:{uID:App.user.id, owner:_owner, coords:{x:App.user.hero.coords.x, z:App.user.hero.coords.z}}});
					}
				});
				
				//Connection.sendMessage({u_event:'hero_load', params:{uID:App.user.id, owner:_owner, coords:{x:this.coords.x, z:this.coords.z}}});
			}
		}
		
		public function checkTempLocation():void
		{
			tempLocation = false;
			if (worldID)
			{
				if (App.data.storage[worldID].hasOwnProperty('expire') && App.data.storage[worldID].expire.hasOwnProperty(App.social))
				{
					tempLocation = true;
					worldTime = App.data.storage[worldID].expire[App.social];
					App.self.setOnTimer(onLockTime);
				}
				
				if (App.data.storage[worldID].hasOwnProperty('available') && App.data.storage[worldID].available != '')
				{
					App.self.setOnTimer(onLockTime);
				}	
			}
		}
		
		
		public function onLockTime():void 
		{
			var timeLast:int = worldTime - App.time;
			var serverDate:Date = new Date();
			serverDate.setTime((App.midnight + serverDate.timezoneOffset * 60 + 3600 * 12) * 1000);
			var currDay:int = serverDate.getDate()
			if (onSynopticMap)
			{
				if (App.user.data.hasOwnProperty('tempWorlds') && App.user.data.tempWorlds.hasOwnProperty(App.user.worldID))
					timeLast = App.user.data.tempWorlds[App.user.worldID] - App.time;
				else
					timeLast = App.midnight + (App.data.storage[App.user.worldID].available[currDay].hend * 60 * 60) - App.time
				
			}
			
			
				
			if (timeLast < 0)
			{
				App.self.setOffTimer(onLockTime);
				new SimpleWindow( {
					title			:Locale.__e("flash:1474469531767"),
					label			:SimpleWindow.ATTENTION,
					text			:Locale.__e("flash:1497517840451"),
					faderAsClose	:false,
					popup			:true,
					onCloseFunction:function():void
					{
						Window.closeAll();
						Travel.goTo(User.HOME_WORLD);
					}
				}).show();
				
			}
		}
		
		private var _tempCoords:Object = {x:0, z:0};
		public function initPersonagesMove(X:int, Z:int):void 
		{
			var positions:Array = findNewPositions(X, Z, personages.length);
			var counter:int = 0;
			for each(var _hero:Hero in personages) {
				if (App.map._aStarNodes[positions[counter].x][positions[counter].z].p == 0 && App.map._aStarNodes[positions[counter].x][positions[counter].z].object == null){
					if (_hero.tm.status == TargetManager.FREE && positions[counter] != null)
					{
						_hero.initMove(positions[counter].x, positions[counter].z, _hero.onStop);
						
						if (App.owner && App.owner.worldID == User.SOCKET_MAP && (_hero.coords.x != X || _hero.coords.z != Z) && (_tempCoords.x != X || _tempCoords.z != Z))
						{
							Connection.sendMessage({u_event:'hero_move', aka:App.user.aka, params:{uID:id, coords:{x:X, z:Z}}});
							_tempCoords = {x:X, z:Z}
						}
					}
				}
					
				counter++;
			}
		}
		
		public function get onSynopticMap():Boolean
		{
			if ([User.SOUTH_MAP, User.WEST_MAP, User.NORTH_MAP, User.EAST_MAP].indexOf(App.user.worldID) != -1)
				return true
			else
				return false;
		}
		
		public function get bathyscaphe():Bathyscaphe 
		{
			return _bathyscaphe;
		}
		
		public function set bathyscaphe(value:Bathyscaphe):void 
		{
			_bathyscaphe = value;
		}
		
		public var queue:Array = [];
		
		public function nearlestFreeHero(target:*):Hero {
			var resultHero:Hero;
			var dist:int = 0;
			for each(var _hero:Hero in personages){
				if (_hero.tm.status != TargetManager.FREE)	continue;
				
				var _dist:int = Math.abs(_hero.coords.x - target.coords.x) + Math.abs(_hero.coords.z - target.coords.z);
				if (dist == 0 || dist > _dist) {
					dist = _dist;
					resultHero = _hero;
				}
			}
			return resultHero;
		}
		
		private function freeHero():Hero 
		{
			for each(var _hero:Hero in personages)
			{
				if (_hero.tm.status == TargetManager.FREE)
					return _hero;
			}
			return null;
		}
		
		
		public function addTarget(targetObject:Object):Boolean
		{
			var target:* = targetObject.target;
			var near:Boolean = targetObject.near || false;
			
			if (target is Tree) 
			{
				_hero = Hero.getNeededHero(target.sid, target.info);
				
			}
			
			// ищем свободного, если нет отдаем первому
			var _hero:Hero;
			if (near)
				_hero = nearlestFreeHero(target);
			else	
				_hero = freeHero();
				
			if (_hero == null && targetObject.isPriority) {
				for each(_hero in personages) {
					_hero.addTarget(targetObject);
					return true;
				}
			}
			
			if (target is Resource || target is Walkresource)
			{
				_hero = Hero.getNeededHero(target.sid, target.info);
			
				if (_hero)
				{
					// если уже обрабатывается кем-то, то отдаем ему же в очередь
					if (target.targetWorker  is Hero) { 
						targetObject['event'] = _hero.getJobFramesType(target.sid);
						target.targetWorker.addTarget(targetObject); 
						return true; 
					} else { 
						if (target.targetWorker is Techno)
						{
							return false;
						}
					}
					targetObject['event'] = _hero.getJobFramesType(target.sid);
					
					target.targetWorker = _hero;
				
				}else if (App.user.mode == User.OWNER) {
						
					// если уже обрабатывается кем-то, то отдаем ему же в очередь
					if (target.targetWorker is Techno) {
						targetObject['event'] = target.getWorkType(target.sid);
						target.targetWorker.addTarget(targetObject); 
						target.targetWorker.workStatus = WorkerUnit.BUSY;
						return true; 
					}
					var workers:Array =  Techno.freeTechnoBySIDS(App.data.storage[App.user.worldID].techno);
					
					if (workers == null || workers.length == 0){
						if (!Techno.findCurrentTechno(App.data.storage[App.user.worldID].techno))
						{
							new SimpleWindow({
								title:Locale.__e("flash:1474469531767"),
								label:SimpleWindow.ATTENTION,
								text:Locale.__e("flash:1501679546415")
							}).show();
						}
						
						return false;
					}
					
					if (workers == null || workers.length == 0)
					{
						
						var technos:Array = Techno.freeTechno();
						for each(var _technoo:Techno in technos)
						{
							if (App.data.storage[App.user.worldID].techno.indexOf(_technoo.thisTechnoWigwam.craftData[0].sID) != -1)
							{
								Techno.findCurrentTechno(_technoo.thisTechnoWigwam.craftData[0].sID);
								break;
							}
						}
						return false;
					}
					
				var worker:Techno = workers[0];
				worker.workStatus = WorkerUnit.BUSY;
				targetObject['event'] = target.getWorkType(target.sid);
				if (worker.addTarget(targetObject)) 
				{
					target.targetWorker = worker;
				}
				
				return true;
			}else 
			{
				return false
			}	
			
			}else{
			  
			if (near)
				_hero = nearlestFreeHero(target);
			else	
				_hero = freeHero();
					
			if(_hero)
				targetObject['event'] = (targetObject.event)?targetObject.event:_hero.getJobFramesType(target.sid);
			}	
				
			if (_hero == null && targetObject.isPriority) {
				for each(_hero in personages) {
					
					
					_hero.addTarget(targetObject);
					return true;
				}
			}
			
			if (_hero == null) {
				if (targetObject.isPriority)
					queue.unshift(targetObject);
				else{ 
				
				queue.push(targetObject);}
			}else{
				_hero.addTarget(targetObject);
			}	
		
			return true;
		}
		
		public function takeBonus():void {
			if (quests.tutorial) return;
		}
		
		private var radius:int = 7;
		private function findNewPositions(x:int, z:int, length:int = 2):Array {
			
			var positions:Array = [];
			var sX:int = x - radius;
			var sZ:int = z - radius;
			
			var fX:int = x + radius;
			var fZ:int = z + radius;
			
			for (var i:int = sX; i < fX; i++) {
				for (var j:int = sZ; j < fZ; j++) {
					if (App.map.inGrid( { x:i, z:j } )) {
						var node:AStarNodeVO = App.map._aStarNodes[i][j];
						if (!node.isWall /*&& node.p == 0*/) {
							positions.push( { x:i, z:j } );
						}
					}
				}
			}
			
			var result:Array = [
				{x:x, z:z}
			];
			
			for (var n:int = 0; n < length; n++) {
				result.push(takePosition(Math.random() * positions.length));
			}
			
			function takePosition(id:int):Object 
			{
				var position:Object = positions[id];
				positions.splice(id, 1);
				if (position == null) {
					position = {x:x, z:z };
				}
				return position;
			}
			
			//if(result[])
			
			return result;
		}
		public function takeTaskForTarget(_target:*):Array
		{
			var result:Array = [];
			for (var i:int = 0; i < queue.length; i++)	{
				if (queue[i].target == _target){ 
					result.push(queue[i]);
					queue.splice(i, 1);
					i--;
				}
			}
			
			return result;
		}
		
		public function storageRead(name:String, defaultReturn:* = ''):* {
			if (!settings[name]) return defaultReturn;
			
			try {
				var _value:Object = settings[name];
				return _value;
			}catch (e:*) {
				var _string:* = settings[name];
				return _string;
			}
		}
		
		public function storageStore(name:String, value:*, immediately:Boolean = false, added:Object = null):void {
			settings[name] = value;
			if (immediately) {
				settingsWait = settingsSaveEvery;
				settingsSave(added);
			}else {
				settingsWait = 0;
			}
		}
		public function settingsSave(added:Object = null):void {
			var presettings:String = JSON.stringify(settings);
			var compress:Boolean = true;
			
			if (_settings == presettings) return;
			_settings = presettings;
			
			var params:Object = {
				'uID':		id,
				'ctr':		'user',
				'act':		'settings',
				'settings':	presettings
			}
			if(added) {
				for (var s:String in added) {
					params[s] = added[s];
				}
			}
			
			Post.send(params, function(error:uint, data:Object, sett:Object):void {
				//
			}, {});
		}
		
		/*public function settingsSave():void {
			var presettings:String = JSON.stringify(settings);
			var compress:Boolean = true;
			
			if (_settings == presettings) return;
			_settings = presettings;
			
			//trace(presettings);
			
			Post.send( {
				'uID':		id,
				'ctr':		'user',
				'act':		'settings',
				'settings':	presettings
			}, function(error:uint, data:Object, sett:Object):void {
				////trace(data);
			}, {});
		}*/
		
		private var skipTimes:int = 3;
		private const settingsSaveEvery:uint = 3;
		private var settingsWait:uint = 0;
		public function totalTimer():void 
		{
			// Daylics
			if (skipTimes > 0) 
			{
				skipTimes--;
				return;
			}
			quests.checkDaylics();
			
			// Booster
			if (boostCompleteTime > 0 && boostCompleteTime < App.time) unactiveBooster();
			if (boosterTimer < 1) 
			{
				if (boosterLimit > 0)
					showBooster();
			}
			boosterTimer--;
			
			if (onceOfferShow > 0) onceOfferShow--;
			
			if (App.time > App.nextMidnight) 
			{
				App.nextMidnight += 86400;
				App.midnight += 86400;
				
				try { Window.isClass(CalendarWindow).close() }catch(e:*){};
				try { Window.isClass(DayliBonusWindow).close() }catch(e:*){};
				App.user.quests.dayliInit = false;
				delete App.user.daylics.quests;
				App.user.quests.getDaylics(true);
			}
			
			// settings
			if (settingsWait == settingsSaveEvery) 
			{
				settingsSave();
			}
			settingsWait++;
		}
		
		public function onTrigger(type:String, sid:int = 0):void 
		{			
			if ( type == "FG" && stock.countFG == 0 )
				startTriggerAction(3089);
		}
		
		private function startTriggerAction(actionID:*):void {
			var action:Object = App.data.actions[actionID];
			
			if (!action) return;
			
			triggerOpen = int(action.pID);
			updateActions();
			App.ui.salesPanel.createPromoPanel();
		}
		
		public var checkDaysleft_Complete:Boolean = false;
		// Пероид отсутствия в игре
		public function checkDaysleft():void {
			
			if (checkDaysleft_Complete) return;
				checkDaysleft_Complete = true;
				
			if (!App.data.options.hasOwnProperty('LackBonus') || App.user.quests.tutorial) return;
			var luckBonus:Object = JSON.parse(App.data.options.LackBonus);
			//diffvisit = App.time - 86400 * 15;
			var daysLeft:int = 0;
			
			if (diffvisit <= 0) return;
			var maxDay:int = 0;
			for (var s:String in luckBonus) {
				var dayleftBonus:Object = luckBonus[s];
				if (diffvisit <= App.time - int(s) * 86400) {// && daysLeft * 86400 < App.time - diffvisit) {
					if (maxDay < int(s)) {
						maxDay = int(s)
						daysLeft = int(s);
					}
				}
			}
			return;
			
			if (daysLeft > 0 && luckBonus.hasOwnProperty(daysLeft)) {
				new BonusVisitingWindow( {
					width:800,
					dayleft:daysLeft,
					bonus:luckBonus[daysLeft],
					onTake:function():void {
						if (App.social == 'SP')
							return;
						
						if (daysLeft >= 14) {
							Post.send( {
								ctr:		'user',
								act:		'money',
								uID:		App.user.id,
								enable:		1
							}, function(error:int, data:Object, params:Object):void {
								if (error) {
									Errors.show(error, data);
									return;
								}
								App.user.money = App.time + (App.data.money.duration || 24) * 3600;
								
								if (!App.isSocial('SP','YN'))
									//new BankSaleWindow().show();
								
								App.ui.salesPanel.addBankSaleIcon();
							});	
						}
					}
				}).show();
			}
		}
		
	}
}

