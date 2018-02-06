package 
{
	import api.ExternalApi;
	import core.Numbers;
	import flash.events.MouseEvent;
	import flash.utils.describeType;
	import ui.Cursor;
	import ui.SystemPanel;
	import ui.TipsPanel;
	import units.Hero;
	import units.Lantern;
	import utils.Finder;
	import wins.OpenWorldWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.TravelWindow;
	import wins.VisitWindow;
	import wins.Window;
	import wins.WindowEvent;
	
	public class Travel 
	{
		private static var visitWindow:VisitWindow;
		private static var startTime:uint;
		private static var finishTime:uint;
		private static var worldID:int;
		
		public static var openShop:Object;
		public static var findMaterial:Object;
		public static var callbackFunction:Function = null;
		public static var ownerWorldID:int;
		public static var currentFriend:Object = null;
		public static var friend:Object;
		public static var trustFriendOpenWorld:int;
		public static const START_LOCATION:int = 4;
		
		public function Travel()
		{			
		}
		
		public static function goHome(e:MouseEvent = null):void
		{			
			App.user.onStopEvent();
			App.ui.bottomPanel.bttnMainHome.hideGlowing();
			App.ui.upPanel.hideFavoriteButton();
			//App.ui.bottomPanel.worldPanel.hide();
			App.ui.bottomPanel.showOwnerPanel();
			App.ui.leftPanel.hideGuestEnergy();
			
			clearWorlds();
			visitWindow = new VisitWindow( {
				title:Locale.__e('flash:1432132991867',[App.data.storage[User.HOME_WORLD].title])
			});
			visitWindow.addEventListener(WindowEvent.ON_AFTER_OPEN, loadHome);
			visitWindow.show();
		}
		
		private static function clearWorlds():void 
		{
			if (App.owner) 
			{
				App.owner.world.dispose();
				App.owner.world = null;
				App.owner.clearVariables();
				App.owner = null;
			}
			
			if (App.user.world) 
			{
				App.user.world.dispose();
				App.user.world = null;
			}
			
			if (App.map)
			{
				App.map.dispose();
				//App.map = null;
			}
		}
		
		private static function loadHome(e:WindowEvent):void
		{		
			visitWindow.removeEventListener(WindowEvent.ON_AFTER_OPEN, loadHome);
			
			App.self.addEventListener(AppEvent.ON_USER_COMPLETE, onHomeComplete);
			
			if (trustFriendOpenWorld > 0)
			{
				App.user.dreamEvent(trustFriendOpenWorld);
			}else{
				App.user.dreamEvent(User.HOME_WORLD);
			}
			trustFriendOpenWorld = 0;
		}
		
		private static function onHomeComplete(e:AppEvent):void
		{			
			App.self.removeEventListener(AppEvent.ON_USER_COMPLETE, onHomeComplete);
			
			App.user.mode = User.OWNER;
			if (App.map.removed)
			{
				App.map = null;
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
				if (App.owner)
					App.map = new Map(App.owner.worldID, App.owner.units, false);
				else
					App.map = new Map(App.user.worldID, App.user.units, false);
				App.map.load();
			}else
				App.self.addEventListener(AppEvent.ON_MAP_REMOVE, onMapRemove);
		}
		
		private static function onMapRemove(e:AppEvent):void
		{
			App.self.removeEventListener(AppEvent.ON_MAP_REMOVE, onMapRemove);
			App.map = null;
			App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			if (App.owner)
				App.map = new Map(App.owner.worldID, App.owner.units, false);
			else
				App.map = new Map(App.user.worldID, App.user.units, false);
			App.map.load();
		}
		
		private static function onMapComplete(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			App.user.addPersonag();
			
			App.map.scaleX = App.map.scaleY = SystemPanel.scaleValue;
			App.map.center();
			
			if (visitWindow != null) 
			{
				visitWindow.close();
				visitWindow = null;
			}
			
			if (openShop != null) 
			{
				new ShopWindow( { find:openShop.find } ).show();
				openShop = null;
			}
			
			/*if (onMapFind != null) 
			{
				var onMap:Array = Map.findUnits([onMapFind.find]);
				App.map.focusedOn(onMap[0], false, function():void{
					onMap[0].click();
				})
				openShop = null;
			}*/
		}
		
		public static function onVisitEvent(visitWorld:int):void 
		{
			//Window.closeAll();
			Connection.disconnect();
			
			Cursor.type = 'default';
			
			if (Quests.lockButtons)
			{
				Quests.lockButtons = false;
				return;
			}
			
			if (!friend)
				return;
				
			TipsPanel.hide();
			
			//if (App.owner != null && friend.uid == App.owner.id && App.owner.worldID == visitWorld) return;
			
			ownerWorldID = visitWorld;
			App.user.onStopEvent();
			currentFriend = friend;
			friend['visited'] = App.time;
			var params:Object = {};
			if (App.data.storage[ownerWorldID].maptype == World.PUBLIC)
			{
				App.ui.bottomPanel.showPublicPanel();
				//title:Locale.__e('flash:1432132991867',[App.data.storage[User.HOME_WORLD].title])
				params['title'] = Locale.__e('flash:1432132991867',[App.data.storage[ownerWorldID].title])
			}
			else
				App.ui.bottomPanel.showGuestPanel();
			visitWindow = new VisitWindow(params);
			visitWindow.addEventListener(WindowEvent.ON_AFTER_OPEN, loadOwner);
			visitWindow.show();
			
			//Делаем push в _6e
			if (App.social == 'FB') 
			{
				ExternalApi.og('visit','friend');
			}			
		}
		
		private static function loadOwner(e:WindowEvent):void 
		{			
			visitWindow.removeEventListener(WindowEvent.ON_AFTER_OPEN, loadOwner);
			App.self.addEventListener(AppEvent.ON_OWNER_COMPLETE, onOwnerComplete);
			
			clearWorlds();
			App.owner = new Owner(friend, ownerWorldID);
			if (App.data.storage[App.owner.worldID].maptype == World.PUBLIC)
			{
				App.user.worldID = ownerWorldID;
			}else{
				App.ui.leftPanel.showGuestEnergy();
				App.ui.upPanel.showAvatar();
				App.ui.upPanel.drawGuestWakeUpPanel();
				App.ui.upPanel.drawFavoritePanel();
			} 
			App.ui.bottomPanel.resize();			
			friend = null;
		}
		
		private static function onOwnerComplete(e:AppEvent):void 
		{ 
			App.self.removeEventListener(AppEvent.ON_OWNER_COMPLETE, onOwnerComplete);
			
			if (App.data.storage[App.owner.worldID].maptype == World.PUBLIC)
				App.user.mode = User.PUBLIC;
			else
				App.user.mode = User.GUEST;
			if (App.map.removed)
			{
				App.map = null;
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
				if (App.owner)
					App.map = new Map(App.owner.worldID, App.owner.units, false);
				else
					App.map = new Map(App.user.worldID, App.user.units, false);
				App.map.load();
			}else
				App.self.addEventListener(AppEvent.ON_MAP_REMOVE, onMapRemove);
			
			//App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);			
			//App.map = new Map(App.owner.worldID, App.owner.units, false);
			//App.map.load();			
		}
		
		
		public static function goTo(_worldID:uint):void
		{
			if (!App.user.worlds.hasOwnProperty(_worldID))
			{
				Window.closeAll();
				new TravelWindow({
					find: _worldID
				}).show();
				/*if (App.data.storage[_worldID].hasOwnProperty('require') && Numbers.countProps(App.data.storage[_worldID].require) > 0)
				{
					new OpenWorldWindow( {
						popup:		true,
						worldID:	_worldID,
						content:	App.data.storage[_worldID].require
					}).show();
				}*/
				
				return;
			}	
			//clearObjects();
			if (App.data.storage[_worldID].hasOwnProperty('reqquest') &&
			App.data.storage[_worldID]['reqquest'] != "" &&
			!App.user.quests.data.hasOwnProperty(App.data.storage[_worldID]['reqquest']))
			{
				var needComplete:int = App.data.quests[App.data.storage[_worldID]['reqquest']].parent
				new SimpleWindow( {
					title			:Locale.__e("flash:1474469531767"),
					label			:SimpleWindow.ATTENTION,
					text			:Locale.__e("flash:1497521725898",[App.data.quests[needComplete].title]) + '\n' + Locale.__e('flash:1507967972859'),
					faderAsClose	:false,
					popup			:true,
					dialog			:true,
					confirm			:function():void{
						utils.Finder.questInUser(needComplete, true);
					}
				}).show();
				
				return;
			}
			App.ui.bottomPanel.showOwnerPanel();
			Window.closeAll();
			worldID = _worldID;
			App.user.onStopEvent();
			if (App.data.storage[worldID].size == World.MINI)
				App.ui.bottomPanel.redrawStockBttn();
			if (User.inExpedition)
				App.ui.bottomPanel.drawDefaultStockBttn();
			visitWindow = new VisitWindow( {
				title:Locale.__e('flash:1432132991867',[App.data.storage[worldID].title]),
				mode: worldID
			});
			
			visitWindow.addEventListener(WindowEvent.ON_AFTER_OPEN, _onLoadUser);
			visitWindow.show();	
		}
		
		public static function get synopticMaps():Array
		{
			var lands:Array = [];
			for (var lnd:* in App.data.storage) 
			{
				if (App.data.storage[lnd].type == 'Lands' && App.data.storage[lnd].hasOwnProperty('available'))
				{
					if (!TravelWindow.availableByTime(lnd))
						lands.push(lnd);
				}
			}
			return lands;
		}
		
		private static function _onLoadUser(e:WindowEvent):void
		{
			visitWindow.removeEventListener(WindowEvent.ON_AFTER_OPEN, _onLoadUser);
			ShopWindow.shop = null;
			App.self.addEventListener(AppEvent.ON_USER_COMPLETE, _onUserComplete);
			clearWorlds();
			//App.user.world.dispose();
			//App.user.world = null;
			App.user.dreamEvent(worldID);
		}
		
		private static function _onUserComplete(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_USER_COMPLETE, _onUserComplete);
			App.user.mode = User.OWNER;
			if (App.map.removed)
			{
				App.map = null;
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
				if (App.owner)
					App.map = new Map(App.owner.worldID, App.owner.units, false);
				else
					App.map = new Map(App.user.worldID, App.user.units, false);
				App.map.load();
			}else
				App.self.addEventListener(AppEvent.ON_MAP_REMOVE, _onMapRemove);
			
		}
		
		private static function _onMapRemove(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_REMOVE, _onMapRemove);
			
			App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, _onMapComplete);	
			
			App.map = new Map(App.user.worldID, App.user.units, false);
			App.map.load();
		}
		
		private static function _onMapComplete(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, _onMapComplete);		
			
			if (visitWindow != null)
			{
				visitWindow.close();
				visitWindow = null;
			}
			
			App.ui.checkExpedition();
			App.user.addPersonag();
			App.map.scaleX = App.map.scaleY = SystemPanel.scaleValue;
			App.map.center();
			if(App.user.hero){
				App.map.focusedOn(App.user.hero, false, null, false);
			}
			
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_GAME_COMPLETE));
			
			//Lantern.init();
			SoundsManager.instance.loadSounds();
			
			if (openShop != null) 
			{
				if (App.data.storage[openShop.find[0]].type != 'Material' && App.data.storage[openShop.find[0]].type != 'Collection')
				{
					Finder.findOnMap([openShop.find[0]])
				}
				else
					ShopWindow.findMaterialSource(openShop.find[0]);				
				openShop = null;
			}
			
			if (findMaterial != null && findMaterial.hasOwnProperty('find') && findMaterial.find && findMaterial.find.indexOf(0) == -1) 
			{
				ShopWindow.findMaterialSource(findMaterial.find);
				findMaterial = null;
			}
			
			if (callbackFunction != null) 
			{
				callbackFunction();
				callbackFunction = null;
			}			
		}
	}
}