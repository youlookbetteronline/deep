package 
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import core.IsoConvert;
	import core.Numbers;
	import core.Post;
	import core.WallPost;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import units.Booster;
	import units.Bubbles;
	import units.Field;
	import units.Plant;
	import units.Resource;
	import units.Unit;
	import utils.Locker;
	import wins.InformWindow;
	import wins.OpenZoneWindow;
	import wins.RoomFader;
	import wins.SimpleWindow;
	import wins.Window;
	import wins.elements.ShopMenu;
	
	/**
	 * ...
	 * @author 
	 */
	public class World 
	{
		public static const NORMAL:uint = 0;
		public static const MINI:uint = 1;
		public static const PUBLIC:uint = 2;
		
		public static var worlds:Array = [];
		public static var maps:Array = [];
		public static var minimaps:Object = { };
		public static var allZones:Array = [];
		public static var buildingStorage:Object;
		
		public var data:Object;
		public var zones:Array = [];
		public var faders:Object = new Object();
		public var zoneUnits:Object = { };
		public var checkClicks:Number = 0;
		private var bonusCoords:Point;
		private var fakes:Object = { }
		
		
		public function World(data:Object)
		{
			zones = new Array();
			
			this.data = data;
			for each(var zone:* in data.zones) 
			{
				zones.push(zone);
			}
			buildingStorage = null;
			buildingStorage = {};
		}
		
		public function showOpenZoneWindow(zoneID:uint):void
		{
			if (!User.inUpdate(zoneID))
			{
				Locker.availableUpdate();
				return;
			}
			var data:Object = App.data.storage[zoneID];
			
			var zones:Array = App.user.world.zones;
			var check:int = 0;
			var needZones:Array = [];
			for (var sID:* in data.require)
			{
				if (App.data.storage[sID].type == "Zones")	
				{	
					needZones.push(sID);
					if (App.user.world.zones.indexOf(sID) != -1)
						check++;
				}
			}
			
			if (check == 0 && needZones.length > 0)
			{
				if (App.user.worldID == User.AQUA_HERO_LOCATION){
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e("flash:1488901793144")
					}).show();
					return;
				}
				else{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e("flash:1382952380332")
					}).show();
					return;
				}
			}
			
			if (data.level > App.user.level) {
				new SimpleWindow( {
					title:Locale.__e('flash:1396606807965', [data.level]),
					text:Locale.__e('flash:1405002933543'),
					label:SimpleWindow.ERROR
				}).show();
				
				return;
			}
			//if (App.social == 'VK' || App.social == 'FS'|| App.social == 'MM')
			//{
			if (App.user.worldID == User.HOLIDAY_LOCATION && (zoneID == 1000))
			{
				
			}
			if (App.user.worldID == User.LAND_2 && (zoneID == 1000))
			{
				if (!Config.admin)
				//if (true)
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1481899130563')
					}).show();
					return;
				}
			}
			//}else{
				/*if (App.user.worldID == User.LAND_2 && zoneID != 949 && zoneID != 950 && zoneID != 951) 
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1481899130563')
					}).show();
					return;
				}
			}*/
			
			/*if (zoneID == 1305 && !Config.admin)
			{
				new SimpleWindow( {
				title:Locale.__e("flash:1474469531767"),
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1481899130563')
				}).show();
				return;
			}*/
			
			/*if (zoneID == 1447 && !Config.admin)
			{
				new SimpleWindow( {
				title:Locale.__e("flash:1474469531767"),
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1481899130563')
				}).show();
				return;
			}*/
			
			
			
			new OpenZoneWindow({
				sID:zoneID,
				require:data.price,
				unlock:data.unlock,
				openZone:openZone
			}).show();
		}
		
		
		public function checkUnitZone(unit:*, zone:int):Boolean 
		{
			for (var i:int = unit.coords.x; i < unit.coords.x + (unit.hasOwnProperty('cells'))?unit.cells:0; i++ )
			{
				for (var j:int = unit.coords.z; j < unit.coords.z + unit.rows; j++ ) 
				{
					var node:AStarNodeVO = App.map._aStarNodes[i][j];
					if (node.z != zone && !node.open)
						return false;
				}
			}
			
			return true;
		}
		
		public function checkZone(target:Unit = null, openWindow:Boolean = false):Boolean
		{
			var node:AStarNodeVO;
			if (target == null)
				node = World.nodeDefinion(App.map.mouseX, App.map.mouseY);
			else
				node = App.map._aStarNodes[target.coords.x][target.coords.z];
			
			if (node == null || node.z == 0)	return false;
			
			if (!node.open)
				checkClicks ++;
				
			var data:Object = App.data.storage[node.z];
			
			if (App.user.mode == User.GUEST)
			{
				if(node.open)
					return true;
				else 
					return false;
			}
			if (!node.open)
			{
				if (Config.admin && App.self.openZone)
				{
					App.user.world.openZone(node.z);
					setTimeout(function():void{Window.closeAll(); }, 200);
					return false;
				}
				if (data.require){
					var typesArr:Array = new Array();
					for (var objId:* in data.require)
					{
						typesArr.push(App.data.storage[objId].type);
					}
					
					if (typesArr.indexOf('Zones') != -1 || typesArr.indexOf('Bridge') != -1)
					{
						var check:int = 0;
						var needZones:Array = [];
						for (var sID:* in data.require)
						{
							if (App.data.storage[sID].type == "Zones")	
							{
								needZones.push(sID);
								if (App.user.world.zones.indexOf(sID) != -1)
									check++;
							}
						}
						
						if (check == 0 && needZones.length > 0)
						{
							if (App.user.worldID == User.AQUA_HERO_LOCATION){
								new SimpleWindow( {
									title:Locale.__e("flash:1474469531767"),
									label:SimpleWindow.ATTENTION,
									text:Locale.__e("flash:1488901793144")
								}).show();
								return false;
							}
							else{
								new SimpleWindow( {
									title:Locale.__e("flash:1474469531767"),
									label:SimpleWindow.ATTENTION,
									text:Locale.__e("flash:1382952380332")
								}).show();
								return false;
							}
						}
						else
						{
							for (var obj:* in data.require)
							{
								if (App.data.storage[obj].type != "Bridge")
									continue;
								
								var bridges:Array = Map.findUnits([obj]);
								var bridge:* = bridges[0];
								if (!bridge && App.data.storage[obj]['delete'] == 1)
								{
									App.user.world.openZone(node.z);
									return false;
								}
								
								if (bridge && bridge.level == bridge.totalLevels)
								{
									if (App.data.storage[obj]['delete'] == 1)
									{
										App.user.world.openZone(node.z);
										return false;
									}
								}else
								{
									if (bridge.hasSpirit)
									{
										new SimpleWindow( {
											hasTitle:	true,
											title:		Locale.__e("flash:1474469531767"),
											text:		Locale.__e('flash:1487331255788',  App.data.storage[bridge.unit.sid].title)
										} ).show();
									}else{
										new SimpleWindow( {
											hasTitle:	true,
											title:		Locale.__e("flash:1474469531767"),
											text:		(App.data.storage[bridge.sid]['delete'] == 0) ? Locale.__e('flash:1477306523171',  App.data.storage[bridge.sid].title) : Locale.__e('flash:1476870793186',  App.data.storage[bridge.sid].title) 
										} ).show();
									}
									return false;
								}
							}
						}
					}
				}
				if (openWindow && App.user.mode == User.OWNER){
					showOpenZoneWindow(node.z);
				}
				
				return false;
			}
			return true;
		}
		
		
		
		public function openZone(sID:uint, buy:Boolean = false):void
		{
			var require:Object;
			if (buy)
			{
				var price:int = App.data.storage[sID].price;
				if (!App.user.stock.takeAll(price)) return;
			}
			else
			{
				var zone:Object = App.data.storage[sID];
				if (zone.devel) {
					for (var _level:* in zone.devel.req) {
					var obj:Object = zone.devel.req[_level];
					if(	App.user.level >= obj.lfrom &&
						App.user.level <= obj.lto )
						{
							require = zone.devel.obj[_level];
							break
						}
					}	
				}
				
				for (var sid:* in require)
				{
					if (App.data.storage[sid].type != "Material") {
						delete require[sid];
					}
				}
				if (!App.user.stock.takeAll(require))	return;
			}
			
			Post.send({
				ctr:'world',
				act:'zone',
				uID:App.user.id,
				wID:App.user.worldID,
				zID:sID,
				buy:int(buy)
			}, onOpenZone, {sID:sID, require:require});
		}
		
		public function onOpenExpeditionZone(error:*, data:*, params:*):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			var _center:Object = { x:App.user.personages[0].x, z:App.user.personages[0].z };
			
			var zoneCenter:Object  =  {}
			
			zoneCenter['target'] = IsoConvert.isoToScreen(_center.x, _center.z, true);
			zoneCenter['callback'] = function():void {
				onOpenComplete(params.sID);	
			}
			
			changeNodes(params.sID);
			zones.push(params.sID);
			Fog.openZone(params.sID);
			var bonus:Object = { };
			bonus = Treasures.convert(bonus);
			Treasures.bonus(bonus, new Point(params.target.x, params.target.y), zoneCenter);
		}
		
		private function onOpenComplete(sID:uint):void
		{
		
			changeNodes(sID);
			zones.push(sID);
			if (!App.user.quests.tutorial)
			{
				new InformWindow( {
					title:Locale.__e("flash:1393579648825"),
					label:InformWindow.ZONE,
					text:Locale.__e("flash:1382952380334"),
					confirm:function():void 
					{
						openZonePost(sID);
					}
				}).show();
			}
		}
		
		public function onOpenZone(error:*, data:*, params:*):void
		{
			var sID:int = params.sID;
			var require:Object = params.require;
			
			if (error) {
				Errors.show(error, data);
				for (var _sID:* in require)
				{
					App.user.stock.add(_sID, require[_sID]);
				}
				return;
			}
			
			bonusCoords = new Point(App.map.mouseX, App.map.mouseY);
			
			if (App.data.storage[params.sID].hasOwnProperty("price"))
			{
				App.user.stock.takeAll(App.data.storage[params.sID].price);
			}
			
			if (data.hasOwnProperty("bonus")) Treasures.bonus(data.bonus, bonusCoords);
			if (data.hasOwnProperty("reward")) Treasures.bonus(data.reward, bonusCoords);
			
			onOpenComplete(sID);
			bonusCoords = null;
			
			removeFakes(sID);
			
			//Делаем push в _6e
			if (App.social == 'FB') {
				ExternalApi.og('investigate','area');
			}
			if (App.user.worldID == User.AQUA_HERO_LOCATION)
			{
				RoomFader.removeFader(sID);
				for each(var _room:* in App.map.rooms)
				{
					_room.refreshSteteRoom();
				}
			
			}else
				Fog.openZone(sID);
		}
		
		
		public function removeResource(res:Resource):void 
		{
			if (App.map.zoneResources == null)
				return;
				
			if (!App.map.zoneResources.hasOwnProperty(res.id))
				return;
			
			var zoneID:int = App.map.zoneResources[res.id];
			var zone_SID:int = App.map.assetZones[zoneID];
			
			if (App.user.world.zones.indexOf(zone_SID) != -1)
				return;
			
			Post.send({
				ctr:'world',
				act:'zone',
				uID:App.user.id,
				wID:App.user.worldID,
				zID:zone_SID,
				buy:0
			}, onOpenExpeditionZone, {sID:zone_SID, target:res});
		}
		
		
		private function removeFakes(sID:int):void 
		{
			var fakeObject:Object = fakes[sID];
			if (fakeObject == null)
				return;
			var fake:* = Map.findUnit(fakeObject.sid, fakeObject.id);
			if (fake != null)
				fake.onApplyRemove();
		}
		
		
		
		public function dispose():void
		{
			Booster.boosters = new Vector.<Booster>(); 
			//Fog.dispose();
			Bubbles.disposeSpots();
			zoneUnits = { };
			faders = null;
			zones = [];
			data = null;
			clearVariables();
		}
		
		
		private function onWorldLoad(e:* = null):void
		{
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_USER_COMPLETE));
		}
		
		public function changeNodes(sID:uint):void
		{
			var x : uint = 0;
			var z : uint = 0;
			
			while ( x < Map.cells) {
				z = 0;
				while ( z < Map.rows){
					if (App.map._aStarNodes[x][z].z == sID)
					{
						App.map._aStarNodes[x][z].open = true;
						if (App.map._aStarNodes[x][z].object != null){
							App.map._aStarNodes[x][z].object['makeOpen'].call(null);
						}
					}	
					z++;	
				}
				x++;
			}
			
			var obNum:int = 0
			for (obNum = 0; obNum < App.map.mSort.numChildren - 1; obNum++ ) {
				var _unit:* = App.map.mSort.getChildAt(obNum);
				if (_unit is Fog || _unit is RoomFader)
					continue;
					
				if (_unit is Plant)
					_unit = _unit.field;
					
				if(_unit is Unit)
					_unit.applyFilter();
				
			}
			
			for (obNum = 0; obNum < App.map.mField.numChildren - 1; obNum++ ) {
				var _funit:* = App.map.mField.getChildAt(obNum);
				if (!(_funit is Field))
					continue;
					
				if(_funit is Unit)
					_funit.applyFilter();
			}
		}
		
		
		public function emergOpenZone(zone_SID:int):void
		{
			Post.send({
				ctr:'world',
				act:'zone',
				uID:App.user.id,
				wID:App.user.worldID,
				zID:zone_SID,
				buy:0
			}, function(error:*, data:*, params:*):void {
				changeNodes(zone_SID);
				zones.push(zone_SID);
				Fog.openZone(zone_SID);
			});
		}
		
		public function openZonePost(sID:uint):void
		{
			WallPost.makePost(WallPost.NEW_ZONE, {sid:sID});
		}
		
		public function openWorld(wID:uint, buy:Boolean = false, callback:Function = null):void
		{
			var worldID:uint = wID;
			var require:Object;
			if (buy)
			{
				var price:int = App.data.storage[wID].unlock.price;
				if (!App.user.stock.take(Stock.FANT, price)) return;
			}
			else
			{
				require = App.data.storage[wID].require;
				for (var sid:* in require)
				{
					if (App.data.storage[sid].type != "Material") {
						delete require[sid];
					}
				}
				if (!App.user.stock.takeAll(require))	return;
			}
			
			Post.send({
				ctr:'world',
				act:'open',
				uID:App.user.id,
				wID:worldID,
				buy:int(buy)
			},
			function(error:*, data:*, params:*):void {
				
				if (error) {
					Errors.show(error, data);
					for (var _sID:* in require)
						App.user.stock.add(_sID, require[_sID]);
					return;
				}
				
				App.user.worlds[worldID] = worldID;
				if (callback != null) callback(worldID);
			});	
		}
		
		public function clearVariables():void {
			var self:* = this;
			var description:XML = describeType(this);
			var variables:XMLList = description..variable;
			for each(var variable:XML in variables) {
				var ss:String = variable.@type;
				if(variable.@type == '*')
				{
					self[variable.@name] = null;
					continue;
				}
				var classType:Class
				try{
					classType = getDefinitionByName(variable.@type) as Class;
				}catch (e:Error){
					self[variable.@name] = null;
					continue;
				}
				switch(classType){
					case Sprite:
						if (self[variable.@name]){
							self[variable.@name].removeChildren();
							self[variable.@name] = null;
						}
						break;
					default:
						self[variable.@name] = null;
				}
			}
		}
		public static function initMaps():void {
			maps = [];
			minimaps = { };
			for (var id:String in App.data.storage) {
				var item:Object = App.data.storage[id];
				
				if (item.type == 'Lands' && item.visible) {
					maps.push({sid:id, order:item.order});
				}
				
				if (item.type == 'Port') {
					if (item['devel'] && item.devel['open']) {
						for (var lvl:* in item.devel.open) {
							for (var wid:* in item.devel.open[lvl]) {
								minimaps[wid] = int(lvl);
							}
						}
					}
				}
				
				if (item.type == 'Zones' || item["sID"] == 83 || item["sID"] == 732 || item["sID"] == 801) {
					if(!allZones[item.land])
						allZones[item.land] = new Array();
					if(allZones[item.land].indexOf(item.sID) == -1)
						allZones[item.land].push(item.sID);
				}
			}
			
			maps.sortOn('order');
		}
		
		public static function checkZoneOpen(zoneID:uint):Boolean
		{
			var data:Object = App.data.storage[zoneID];
			
			var zones:Array = App.user.world.zones;
			var check:int = 0;
			var needZones:Array = [];
			for (var sID:* in data.require)
			{
				if (App.data.storage[sID].type == "Zones")	
				{	
					needZones.push(sID);
					if (App.user.world.zones.indexOf(sID) != -1)
						check++;
				}
			}
			
			if (check == 0 && needZones.length > 0)
			{
				return false;
			}
			
			if (data.level > App.user.level) {
				
				return false;
			}
			
			return true;
		}
		
		public static function nodeDefinion(X:Number, Y:Number):AStarNodeVO
		{
			if (!App.map._aStarNodes)
				return null;
			var place:Object = IsoConvert.screenToIso(X, Y, true);
			
			if (place.x<0 || place.x>Map.X) return null;
			if (place.z<0 || place.z>Map.Z) return null;
			
			return App.map._aStarNodes[place.x][place.z];
		}
		
		public static function openMap(worldID:int, callback:Function = null, buy:uint = 0):void {
			
			if (App.user.worlds.hasOwnProperty(worldID)) return;
			var _worldID:int = worldID;
			Post.send({
				ctr:'world',
				act:'open',
				uID:App.user.id,
				wID:worldID,
				buy:buy
			}, function(error:*, data:*, params:*):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (data['open'] == 1) {
					if (buy == 0 && App.data.storage[_worldID].hasOwnProperty('require'))
						App.user.stock.takeAll(App.data.storage[_worldID].require);
					
					App.user.worlds[_worldID] = _worldID;
				}
				if (callback != null) callback();
			});	
		}
		
		public static function isOpen(worldID:uint):Boolean {
			if (App.user.worlds.hasOwnProperty(worldID))
				return true;
			
			return false;
		}
		
		public static function isAvailable(sID:*):Boolean 
		{
			App.data.storage[sID];
			App.user.worlds;			
			return true;
		}
		
		public static function zoneIsOpen(sID:uint):Boolean
		{	
			var world:World;
			if (App.user.mode == User.OWNER){
				world = App.user.world;
			}
			else	
				world = App.owner.world;
				
			if (!world || world.zones.indexOf(sID) == -1) 
				return false;
				
			return true;
		}
		
		public static function tagUnit(unit:Unit):void
		{
			if (!App.data.storage.hasOwnProperty(unit.sid)) return;
			var type:String = unit.type;
			switch(type) {
				case 'Building':
				case 'Mining':
				case 'Storehouse':
				case 'Factory':
				case 'Field':
				case 'Moneyhouse':
				case 'Trade':
				case 'Fplant':
				case 'Buffer':
				case 'Collector':
				case 'Tradesman':
				case 'Barter':
				case 'Stall':
				case 'Thimbles':
					addBuilding(unit.sid);
					break;
					
			}
		}
		
		public static function addBuilding(sid:int):void
		{
			if (buildingStorage[sid]) {
				buildingStorage[sid] += 1;
				return;
			}
			
			buildingStorage[sid] = 1;
		}
		
		public static function removeBuilding(unit:Unit):void 
		{
			if (buildingStorage[unit.sid]) 
			{
				var index:int = buildingStorage[unit.sid];
				if (index != -1) 
				{
					buildingStorage[unit.sid] = index -1;
				}
			}
		}
		
		public static function getBuildingCount(sid:int):int {
			var countB:int = Map.findUnits([sid]).length;
			return countB;
		}
		
		public static function canBuilding(sid:int):Boolean 
		{
			var placeAnyway:Boolean = false;
			var builded:int = getBuildingCount(sid);
			var canBuild:int = 0;
			
			if (!App.data.storage[sid].hasOwnProperty('instance'))
				placeAnyway = true;
			
			try 
			{
				canBuild = Numbers.countProps(App.data.storage[sid].instance.cost);
				
				// Если просто здание можно строить всегда
				if (['Tribute', 'Building', 'Pharmacy'].indexOf(App.data.storage[sid].type) != -1)
				{
					canBuild = builded + 1;
				}
			}
			catch (e:*) {}
			
			return (placeAnyway || (canBuild > 0 && builded < canBuild)) ? true : false;
		}
		
		public static function canBuyOnThisMap(sid:*, exceptionSections:Array = null):Boolean {
			var info:Object = App.data.storage[App.map.id];
			
			if (info) {
				for (var section:* in info.shop) {
					if (exceptionSections && exceptionSections.indexOf(section) >= 0) continue;
					if (info.shop[section].hasOwnProperty(sid) && info.shop[section][sid] == 1) return true;
				}
			}
			
			return false;
		}
		public static function worldsWhereEnabled(sid:*):Array 
		{
			var worldsWhereEnable:Array = [];
			for (var i:* in App.user.maps) 
			{
				for (var mapa:* in App.user.maps[i].ilands)
				{
					if (World.canBuyOnThatMap(sid, mapa))
					{
						if ((App.data.storage[mapa].hasOwnProperty('expire') && App.data.storage[mapa].expire[App.social] > App.time) || !App.data.storage[mapa].hasOwnProperty('expire'))
						{
							worldsWhereEnable.push(mapa);
						}
					}
				}
			}
			
			for each(var ii:* in App.user.openedRadarMaps) 
			{
				
				if (World.canBuyOnThatMap(sid, ii))
					worldsWhereEnable.push(ii);
			}
			
			return worldsWhereEnable;
		}
		
		public static function worldsWhereEnabledTry(sid:*):Array 
		{
			var worldsWhereEnable:Array = [];
			for (var i:* in App.user.maps) 
			{
				for (var mapa:* in App.user.maps[i].ilands)
				{
					var itemIsAweable:Array = ShopMenu.getMapShop(mapa);
					if (World.canBuyOnThatMap(sid, mapa) && itemIsAweable.indexOf(App.data.storage[sid].market) != -1)
					{
						if ((App.data.storage[mapa].hasOwnProperty('expire') && App.data.storage[mapa].expire[App.social] > App.time) || !App.data.storage[mapa].hasOwnProperty('expire'))
						{
							worldsWhereEnable.push(mapa);
						}
					}
				}
			}
			
			for each(var ii:* in App.user.openedRadarMaps) 
			{
				
				if (World.canBuyOnThatMap(sid, ii))
					worldsWhereEnable.push(ii);
			}
			
			return worldsWhereEnable;
		}
		
		public static function canBuyOnThatMap(sid:*, mapId:int = 4, exceptionSections:Array = null):Boolean {
			var info:Object = App.data.storage[mapId];
			
			if (info) 
			{
				for (var section:* in info.shop) 
				{
					if (exceptionSections && exceptionSections.indexOf(section) >= 0) continue;
					if (info.shop[section].hasOwnProperty(sid) && info.shop[section][sid] == 1) 
						return true;
				}
			}
			
			return false;
		}
		
		public static function canBuyOnMap(sid:*, exceptionSections:Array = null):Array {
			var worlds:Array;
			
			if (!exceptionSections) exceptionSections = [];
			if (exceptionSections.indexOf(0) == -1)
				exceptionSections.push(0);
			
			for each(var worldID:* in World.worlds) {
				var info:Object = App.data.storage[worldID];
				if (info) {
					for (var section:* in info.shop) {
						if (exceptionSections.indexOf(section) >= 0) continue;
						if (info.shop[section][sid] == 1) {
							if (!worlds) worlds = [];
							worlds.push(worldID);
						}
					}
				}
			}
			
			return worlds;
		}
		
	}
}