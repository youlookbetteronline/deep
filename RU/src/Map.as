package  
{
	import astar.AStar;
	import astar.AStarNodeVO;
	import atm.Troops;
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Animation;
	import core.Debug;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import effects.BoostEffect;
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.net.FileReference;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setInterval;
	import ui.SunRay;
	import units.FogCloud;
	import ui.UnitIcon;
	import ui.UserInterface;
	import utils.Finder;
	import utils.MapPresets;
	import utils.Saver;
	import utils.Sector;
	import vk.api.serialization.json.JSONEncoder;
	import wins.ExpeditionHintWindow;
	import wins.RoomFader;
	import wins.VisitWindow;
	import wins.Window;
	import effects.Waves;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.SystemPanel;
	import wins.ShopWindow;
	import units.*;
	
	public class Map extends LayerX
	{
		
		public static const LAYER_LAND:String 		= 'mLand';
		public static const LAYER_FIELD:String 		= 'mField';
		public static const LAYER_SORT:String 		= 'mSort';
		public static const LAYER_TREASURE:String 	= 'mTreasure';
		public static const DEBUG:Boolean 	= false;
		
		public const firstDepthLevel:int = 4;
		public const secondDepthLevel:int = 6;
		public const CONFIG_DATA:Object = [
			"overclickable",			//Выделяемый всегда
			"touchableInGuest",			//Не Выделяемый в гостях
			"transable",				//Не Невидимый при выделении верхней части
			"nowater",					//Не Ставится на воду
			"noland",					//Не Ставится на землю
			"multiple",					//Не Выставлять в мульти
			"rotateable",				//Не Вращаемый
			"moveable",					//Не Перемещаемый
			"stockable",				//Не Склад
			"removable",				//Не Удаляемый
			"storageable",				//Не можно с него собрать
			"clickable",				//Не Кликабельный
			"touchable"					//Не Выделяемый
		]
		
		public static var deltaX:int 	= 0;
		public static var deltaY:int 	= 0;
		public static var mapWidth:int 	= 0;
		public static var mapHeight:int	= 0;
		public static var ready:Boolean = false;
		public static var focused:Boolean = false;
		
		public static var X:int = 0;
		public static var Z:int = 0;
		public static var cells:int = 0;
		public static var rows:int = 0;
		public static var resourcesID:Object = {};
		
		private static var contLight:LayerX;
		
		public var params:Array = ['count', 'id', 'sid', 'busy', 'bID', 'floor', 'guests', 'kicks', 'finished', 'created', 'rotate', 'rel', 'worker', 'crafted', 'helpers', 'sleepfinish', 'bTime', 'hasSpirit', 'fID', 'openingZone', 'level', 'started'];
		public var coords:Object = {x: 0, y: 0, z: 0};
		public var publicBoxes:Object = {};
		public var sidRes:int = 0;
		
		public var mEffects:SunRay;
		public var mTreasure:Sprite 	= new Sprite();
		public var mLayer:Sprite 		= new Sprite();
		public var mUnits:Sprite 		= new Sprite();
		public var mLand:Sprite		 	= new Sprite();
		public var mField:Sprite	 	= new Sprite();
		public var mSort:Sprite		 	= new Sprite();
		public var mFog:Sprite		 	= new Sprite();
		public var mIcon:Sprite 		= new Sprite();
		
		public var _aStarNodes:Vector.<Vector.<AStarNodeVO>>;
		public var _aStarWaterNodes:Vector.<Vector.<AStarNodeVO>>;
		public var _aStarParts:Vector.<Vector.<AStarNodeVO>>;
		public var _astar:AStar;
		public var _astarReserve:AStar;
		public var _astarWater:AStar;
		
		public var touched:Vector.<*> = new Vector.<*>();
		public var touchedZone:int = -1;
		public var lastTouched:Vector.<Unit> = new Vector.<Unit>();
		public var rooms:Object = new Object();
		public var transed:Vector.<Unit> = new Vector.<Unit>();
		public var sorted:Array = [];
		public var _depths:Array = [];
		public var _grid:Bitmap;
		public var id:uint;
		public var info:Object = { };
		public var _loadNormalForced:Boolean;
		public var workmen:Object = {0:Personage.BEAR};
		public var heroPosition:Object = { x:85, z:66 };
		public var mainMap:Array = [];
		public var prevMap:Array = [];
		public var defaultFilters:Array = [];
		public var fogCount:int;
		public var valueBlur:int;
		public var sector:Sector;
		public var timer:Timer;
		public var mapContainer:Sprite;
		public var bitmap:Bitmap;
		public var assetZones:Object;
		public var zoneResources:Object;
		public var land_decor:Array = [];
		public var faderBitmap:Bitmap;
		public var itemsToRemove:Array = [];
		public var closedZones:Array = [];
		public var reservBmap:BitmapData;
		public var mapPaddingX:int = -490;
		public var mapPaddingY:int = 70;
		public var displayOnMap:String = 'zones';
		public var defaultJson:Object = {};
		public var sizeMinizone:int = 5;
		public var propsValues:Object = new Object();
		public var faders:Vector.<Sector> = new Vector.<Sector>();
		public var zonesResources:Object = {};
		public var under:Array = [];
		public var animations:Vector.<Anime3>;
		
		private var _worldData:*;
		private var focusCenTween:TweenLite;
		private var watchUnit:Unit;
		private var watchSlow:Number = 2;
		private var unitTarget:*;
		private var focusTween:TweenLite;
		private var additionalCheck:Boolean;
		private var _unitIconOver:Boolean;
		private var mapPadding:int = 250;
		private var replacingDist:int = 0;
		private var iconSortTimeout:int = 0;
		private var globalSorting:int = 0;
		private var tX:int = 0;
		private var tY:int = 0;
		private var _units:Object;
		private var _moved:Unit;
		private var tempData:*;
		private var tutor:Boolean = true;
		
		private var building:Building;
		private var craftfloors:Craftfloors;
		private var university:University;
		private var manufacture:Manufacture;
		private var walkresource:Walkresource;
		private var personage:Personage;
		private var walkhero:Walkhero;
		private var walkgift:Walkgift;
		private var resource:Resource;
		private var decor:Decor;
		private var contest:Contest;
		private var field:Field;
		private var animal:Animal;
		private var houseTechno:Wigwam;
		private var sphere:Twigwam;
		private var tribute:Tribute;
		private var picker:Picker;
		private var booster:Booster;
		private var ctribute:Ctribute;
		private var postman:Postman;
		private var banker:Banker;
		private var treasure:Treasure;
		private var golden:Golden;
		private var tree:Tree;
		private var gamble:Gamble;
		private var ggame:GGame;
		private var beast:Beast;
		private var friendfloors:Friendfloors;
		private var pet:Pet;
		private var barter:Barter;
		private var hippodrome:Hippodrome;
		private var publicbox:Publicbox;
		private var table:Table;
		private var wall:Wall;
		private var bridge:Bridge;
		private var box:Box;
		private var photostand:Photostand;
		private var firework:Firework;
		private var techno:Techno;
		private var character:Character;
		private var happy:Happy;
		private var miniStock:Ministock;
		private var port:Port;
		private var portal:Portal;
		private var tent:Tent;
		private var fogCloud:FogCloud;
		private var bathyscaphe:Bathyscaphe;
		private var oracle:Oracle;
		private var fatman:Fatman;
		private var mfloors:Mfloors;
		private var booker:Booker;
		private var pharmacy:Pharmacy;
		
		public function set unitIconOver(value:Boolean):void{
			_unitIconOver = value;
			if (_unitIconOver) {
				untouches();
			}
		}
		public function set depths(_val:Array):void{
			_depths = _val;
		}
		public function get depths():Array{
			return _depths;
		}
		public function set grid(value:Boolean):void{
			if (value) 
				createGrid();
			else {
				if (_grid.parent){
					_grid.parent.removeChild(_grid);
					_grid = null;
				}
			}
		}
		public function get grid():Boolean{
			if (_grid) 	return true;
			else 		return false;
		}
		public function set scale(value:Number):void{
			App.map.scaleX = value;
			App.map.scaleY = value;
			
			App.map.center();
			additionalCheck = true;
		}
		public function get moved():Unit 
		{
			return _moved;
		}
		
		public function set moved(value:Unit):void 
		{
			_moved = value;
		}
		
		public function Map(id:int, units:Object = null, load:Boolean=true, loadNormalForced:Boolean = false)
		{
			Map.ready = false;
			this._units = units;
			this.id = id;
			this._loadNormalForced = loadNormalForced;
			this.name = 'Map';
			timer = new Timer(10, 0);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, posChecker);
			
			App.self.addChildAt(this, 1);
			
			
			if (load) 
			{
				Load.loading(Config.getDream(takeDreamName()), onLoadTile, 0, false,
				function(progress:Number):void
				{
					if(App.self.changeLoader != null) App.self.changeLoader('map', progress);
				});
			}
			
			fogCount = 1200;
			
			mouseEnabled = false;
			
			if(App.data.storage[id].workmen != null)
				workmen = App.data.storage[id].workmen;
		}	
		
		private function takeDreamName():String
		{
			return App.data.storage[id].view;
		}
		
		public function load():void 
		{
			Load.loading(Config.getDream(takeDreamName()), onLoadTile, 0, false, VisitWindow.mapProgress);
			App.ui.upPanel.resize();
			App.ui.resize();
		}
		
		public function pushBoxes(boxes:Array):void 
		{
			var num:int = 1;
			for each(var _box:* in boxes)
			{
				var newRes:Publicbox = new Publicbox({ id:num, sid:_box['sid'], x:_box['x'], z:_box['z']});
				App.map.sorted.push(newRes);
				newRes.take();
				num++;
			}
		}

		public function pushResources():void 
		{
			MapPresets.generateMapResources(saveMap);
		}
		
		public function inGrid(point:Object):Boolean
		{
			if (point.x >= 0 && point.x < Map.cells)
			{
				if (point.z >= 0 && point.z < Map.rows) return true;
			}
			return false
		}
		
		public function disposeTutor():void {
				
			var unit:*;
			var childs:int = mSort.numChildren;
			
			while (childs--) {
				try
				{
					unit = mSort.getChildAt(childs);
					
					if (unit is Resource && unit.tutorObj) {
						unit.dispose();
					}else{
						if(!(unit is Plant && unit.tutorObj)){
							unit.uninstall();
						}
					}
				
				}catch (e:Error) {
					
				}
			}
			
			childs = mLand.numChildren;
			while (childs--) {
				try
				{
					unit = mLand.getChildAt(childs);
					
					if (unit is Unit&& unit.tutorObj) {
						unit.uninstall();
					}
				}catch (e:Error) {
					
				}	
			}
			
			childs = mField.numChildren;
			while (childs--) {
				try
				{
					unit = mField.getChildAt(childs);
				
					if (unit is Unit&& unit.tutorObj) {
						unit.uninstall();
					}
				}catch (e:Error) {
					
				}	
			}
			
			/*_aStarNodes = null;
			_aStarParts = null;
			_aStarWaterNodes = null;
			_astar = null;
			_astarReserve = null;
			_astarWater = null;*/
			
			//App.user.removePersonages();
			/*App.self.removeChild(this);
			Bear.dispose();
			Lantern.dispose();
			Hut.dispose();
			SoundsManager.instance.dispose();
			Pigeon.dispose();
			Nature.dispose();
			Waves.dispose();*/
			
			
		}
		
		/**
		 * Событие окончания загрузки SWF картыr
		 * @param	data
		 */
		
		private function onLoadTile(data:Object):void 
		{
			//return;
			
			centerPoint = new Shape();
			centerPoint.graphics.beginFill(0xff0000, 0);
			centerPoint.graphics.drawCircle(0, 0, 4);
			centerPoint.graphics.endFill();
			
			closedZones = [];
			sorted = [];
			depths = [];
			/*deltaX 	= 0;
			deltaY 	= 0;
			
			x = -deltaX;
			y = -deltaY;*/
			
			if (data.hasOwnProperty('assetZones')) 
				assetZones = data.assetZones;
			
			if (data.hasOwnProperty('zoneResources'))
			{
				zoneResources = data.zoneResources;
			}
			
			//Назначаем параметры карты
			Map.mapWidth 	= data.mapWidth;
			Map.mapHeight 	= data.mapHeight;
			Map.cells		= data.isoCells;
			Map.rows 		= data.isoRows;
			
			var widthTile:int 	= data.tile.width;
			var heightTile:int 	= data.tile.height;
			
			var mapCells:int 	= Math.ceil(data.mapWidth / widthTile); 
			var mapRows:int 	= Math.ceil(data.mapHeight / heightTile); 
			
			var tileDX:int = 0;
			var tileDY:int = 0;
			
			/*var encoder:JSONEncoder = new JSONEncoder(data.gridData);
			trace('_______________GRID_____________ \n');
			trace(encoder.getString() + '\n');
			
			var encoder2:JSONEncoder = new JSONEncoder(data.assetZones);
			trace('____________assetZones__________ \n');
			trace(encoder2.getString() + '\n');
			
			var fileRef:FileReference = new FileReference(); 
			fileRef.save('GRID\n' + encoder.getString() + '\n assetZones \n' + encoder2.getString(), String(App.user.worldID)+"_zones.txt");*/
			
			//var fileRef2:FileReference = new FileReference(); 
			//fileRef2.save(encoder2.getString(), String(App.user.worldID)+"_assetZones.txt"); 
			
			if (data.hasOwnProperty('tileDX'))
			{
				tileDX = data.tileDX;
				tileDY = data.tileDY;
			}
			
			if (data.hasOwnProperty('type') && data.type == 'image') 
			{
				addTile(0,0);
			}else
			{
				//Дублируем тайлы карты по всему миру
				for (var j:int = 0; j < mapRows; j++ ) 
				{
					for (var i:int = 0; i < mapCells; i++ ) 
					{
						addTile(i, j);
					}
				}
			}
			
			if (data.hasOwnProperty('additionalTiles')) 
			{
				for each(var coords:Object in data.additionalTiles) 
				{
					addTile(coords.i, coords.j);
				}
			}
			
			function addTile(i:int, j:int):void 
			{
				bitmap = new Bitmap(data.tile);
				addChild(bitmap);
				bitmap.x = (i * widthTile) + tileDX;
				bitmap.y = (j * heightTile) + tileDY;
			}
			
			//Создаем сетку 
			tempData = data;
			initWorldElements();
			drawMapAnimation();
			//var pdrag:ProjectionDragger = new ProjectionDragger();
			//pdrag.x = 500;
			//pdrag.y = 500;
			//mEffects.addChild(pdrag);
			//Load.clearCache(data.parent.contentLoaderInfo.url);
			//data = null;
		}
		
		private function drawMapAnimation():void {
			//return;
			if (!animations)
				animations = new Vector.<Anime3>;
			
			clearMapAnimation();
			
			var data:Object = {
				3184: {
					1: {type:'Decor', view:'tentacleblue5', x:3580, y:1040},
					2: {type:'Decor', view:'tentacleblue3', x:3826, y:1060},
					3: {type:'Decor', view:'tentacleblue1', x:3675, y:1210},
					4: {type:'Decor', view:'tentacleblue6', x:3820, y:1340},
					5: {type:'Decor', view:'tentacleblue2', x:3510, y:1570},
					6: {type:'Decor', view:'tentacleblue4', x:3340, y:1790},
					7: {type:'Decor', view:'tentacleblue7', x:3140, y:1860},
					8: {type:'Decor', view:'tentacleblue8', x:3180, y:1620}
					//2: {type:'Anime', view:'waterfall4', x:2650, y:2820}
				}
			}
			
			if (!ready || !(id in data)) return;
			
			for each(var object:Object in data[id]) {
				var anime:Anime3 = new Anime3(Config.getSwf(object.type, object.view));
				anime.x = object.x;
				anime.y = object.y;
				//addChild(anime);
				addChildAt(anime, getChildIndex(bitmap) + 1);
				animations.push(anime);
			}
		}
		
		private function clearMapAnimation():void {
			if (!animations || animations.length == 0) return;
			
			while (animations.length) {
				var anime:Anime3 = animations.shift();
				anime.parent.removeChild(anime);
				anime = null;
			}
		}
		
		public function onUserLoad(e:* = null):void{
			App.self.removeEventListener(AppEvent.ON_WORLD_LOAD, onUserLoad)
			initWorldElements();
		}
		
		public function initWorldElements():void{
			
			Bubbles.init(); 
			initGridNodes(tempData.gridData);
			Fog.generateZoneCorners();
			
			mUnits = new Sprite();
			//mEffects = new SunRay();
			mTreasure = new Sprite();
			
			addChild(mUnits);
			//addChild(mEffects);
			addChild(mTreasure);
			
			mLand = new Sprite();
			mField = new Sprite();
			mSort = new Sprite();
			mFog = new Sprite();
			mIcon = new Sprite();
			
			var fogshape:Shape = new Shape();
			fogshape.graphics.beginFill(0x76a4b9, 1)
			fogshape.graphics.drawRect(0, 0, App.self.width, App.self.height);
			fogshape.graphics.endFill();
			mFog.addChild(fogshape);
			
			mUnits.addChild(mLand);
			mUnits.addChild(mField);
			mUnits.addChild(mSort);
			//mUnits.addChild(mEffects);
			mUnits.addChild(mIcon);
			mFog.cacheAsBitmap = true;
			//mUnits.addChild(mFog);
			
			
			//mEffects.addChild(centerPoint);
			
			if (id == User.AQUA_HERO_LOCATION)
			{
				Room.generateZoneCorners();
				assetZones[Numbers.countProps(assetZones) + 1] = 0;
				for each (var rZone:* in assetZones)
				{
					var room:Room = new Room(rZone);
					rooms[rZone] = room;
				}
				initUnits();
				sorting();
				allSorting();
			}
			else{
				if (App.user.quests.tutorial && App.user.quests.data[189].finished == 0)
				{
					App.self.addEventListener(AppEvent.SHOWN_NEWSPAPER, initUnits);
					App.self.addEventListener(AppEvent.SHOWN_NEWSPAPER, function():void{
						//Fog.generateZoneCorners();
						Fog.init(tempData.assetZones, id);
						//sorting();
					})
				}else{
					initUnits();
					//Fog.generateZoneCorners();
					Fog.init(tempData.assetZones, id);
					//sorting();
					//allSorting();
				}
			}
			
			if (App.user.useSectors && App.user.mode == User.OWNER)
				loadDefault();
			
			if (tempData.hasOwnProperty('heroPosition'))
				heroPosition = tempData.heroPosition;
			
			if (id == 827)
				heroPosition = {x:28, z:22};			
			
			var _bgColor:*;
			if (tempData.hasOwnProperty('bgColor')) {
				_bgColor = tempData.bgColor;
				App.self.stage.color = _bgColor;
			}
			
			Lantern.init();
			SoundsManager.instance.loadSounds();
			
			//if (data.hasOwnProperty('waves'))
				//Waves.add(id, data.waves);
				
			if (tempData.hasOwnProperty('publicBoxes'))
				publicBoxes = tempData.publicBoxes;
			if (App.user.mode == User.PUBLIC && App.data.storage[App.owner.worldID].maptype == World.PUBLIC && App.owner)
			{
				if (App.owner.id == App.user.id)
				{
					if (App.user.data['publicWorlds'] && App.user.data['publicWorlds'].hasOwnProperty(App.owner.worldID))
					{
						if(App.user.data['publicWorlds'][App.owner.worldID] > App.time || (App.user.data['publicWorlds'][App.owner.worldID] == 0 && Numbers.countProps(_units) > 0)){
							defaultJson = App.owner.units;
							checkZonesMinizone();
							initMonster();
						}else{
							App.owner.world.data.expire = App.time + App.data.storage[App.owner.worldID].duration;
							if (tempData.hasOwnProperty('publicBoxes'))
								pushBoxes(tempData.publicBoxes);
							pushResources();
						}
					}else{
						if (tempData.hasOwnProperty('publicBoxes'))
							pushBoxes(tempData.publicBoxes);
						pushResources();
					}
				}else{
					defaultJson = App.owner.units;
					checkZonesMinizone();
					initMonster();
				}
			}
			
			var synopticHelp:int = App.user.storageRead('synoptichelp');
			if (synopticHelp == 0)
			{
				if (User.SYNOPTIC_LANDS.indexOf(App.user.worldID) != -1)
				{
					App.user.storageStore('synoptichelp', App.time);
					new ExpeditionHintWindow( {
						popup: true,
						hintID:7,
						height:540
					}).show();
				}
			}
			
			Map.ready = true;
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_MAP_COMPLETE));
			App.self.setOnEnterFrame(sorting);
			//sorting();
			//allSorting();
			if (!App.user.quests.tutorial)
				tempData = null;
		}
		
		public function initUnits(e:* = null):void 
		{
			App.self.removeEventListener(AppEvent.SHOWN_NEWSPAPER, initUnits);
			//раставляем полученные юниты
			for each(var item:Object in _units) 
			{
				if (item.type == 'Decor' && App.data.storage[item.sid].dtype == 1) 
				{
					land_decor.push(item);
					continue;
				}
				
				if (item.sid == 1078 && item.id == 2 && App.social != 'OK') //Заменялка
				{
					var sendObject:Object = {
						ctr:'Building',
						act:'swap',
						uID:App.user.id,
						id:item.id,
						wID:App.user.worldID,
						sID:item.sid,
						tID:1416
					};
					Post.send(sendObject, onChangeBuilding);
					continue;
				}
				if (!inGrid({x:item.x, z:item.z}) || _aStarNodes[item.x][item.z].z == 0)
					continue;
				if (App.user.mode == User.GUEST)
				{
					var _zCoords:Object = {x:item.x, z:item.z};
					
					if(App.data.storage[item.sid].type == 'Bridge'){
						_zCoords.x = _zCoords.x + App.data.storage[item.sid].area.w - 1;
						_zCoords.z = _zCoords.z + App.data.storage[item.sid].area.h - 1;
					}
					if (!World.zoneIsOpen(_aStarNodes[_zCoords.x][_zCoords.z].z))
					{
						if(Fog.checkFog(_aStarNodes[_zCoords.x][_zCoords.z].z))
							continue;
					}else{
						if (App.data.storage[item.sid].type == 'Techno' || 
							//App.data.storage[item.sid].type == 'Walkgolden'|| 
							App.data.storage[item.sid].type == 'Animal'||
							App.data.storage[item.sid].type == 'Picker'/*||
							App.data.storage[item.sid].type == 'Tree'||
							App.data.storage[item.sid].type == 'Decor'*/)
						{
							continue;
						}
						/*if (App.data.storage[item.sid].type == 'Building' || 
							App.data.storage[item.sid].type == 'Golden' || 
							App.data.storage[item.sid].type == 'Tribute' || 
							App.data.storage[item.sid].type == 'Wigwam' || 
							App.data.storage[item.sid].type == 'Pharmacy' || 
							App.data.storage[item.sid].type == 'Table' || 
							App.data.storage[item.sid].type == 'Port' ||  
							App.data.storage[item.sid].type == 'Twigwam'||  
							App.data.storage[item.sid].type == 'Booster')
						{
							var plate:WaitPlate = WaitPlate.add(item);
							continue;
						}*/
					}
				}
				var unit:Unit = Unit.add(item);
				if (unit.info.config)
				{
					var unitConfig:Array = String(unit.info.config).split('').reverse();
					for (var configID:int = 0; configID < unitConfig.length; configID++ ) 
					{
						if (unitConfig[configID] == "1" && unit.hasOwnProperty(CONFIG_DATA[configID])) 
						{
							unit[CONFIG_DATA[configID]] = false;
						}
					}
				}
				
				if (item.sid == 1107 && item.id == 10 && App.user.worldID == User.AQUA_HERO_LOCATION && App.user.mode == User.OWNER )
				{
					Finder.removeUnits([unit]);
				}
				
				mainMap.push(unit);
			}
			//Fog.hideAll();	
			
			land_decor.sortOn('id');
			var land_decor_lenght:int = land_decor.length;
			for (var i:int = 0; i < land_decor_lenght; i++) 
			{
				Unit.add(land_decor[i]);
			}
			if (App.user.mode == User.GUEST && App.owner.id == '1')
			{
				var wifeSID:int = 977;//;жена обыкновенная
				
				if (App.user.quests.data.hasOwnProperty("34") && App.user.quests.data[34].finished != 0)
				{
					wifeSID = 978;//жена со скалкой
				}
				
				if (App.user.quests.data.hasOwnProperty("41") && App.user.quests.data[41].finished != 0)
				{
					wifeSID = 979;//жена красивая
					var Johny:Walkgolden = new Walkgolden( { sid:717, id:1489, x:22, z:15 } );
				}
				
				var wifeJohny:Walkgolden = new Walkgolden( { sid:wifeSID, id:1488, x:28, z:16 } );
			}
			
			land_decor = null;
			
			if((App.social == 'MM' || App.social == 'OK' )&& App.user.mode == User.OWNER && App.user.worldID == User.LAND_2)
				mmCostile();
				
			onRedrawDispatch();
		}
		
		protected function mmCostile(error:int = 0, data:Object = null, params:Object = null):void 
		{
			var raks:Array = Map.findUnits([1080]);
			if(raks.length <=0){
				var rak:Unit = Unit.add( {sid:1080, buy:true, x:21, z:45 } );
				rak.buyAction();
				rak.take();
			}
			
			var telegas:Array = Map.findUnits([1416]);
			if(telegas.length <=0){
				var telega:Unit = Unit.add( {sid:1416, buy:true, x:25, z:40 } );
				telega.buyAction();
				telega.take();
				telega.open = false;
			}
		}
		
		protected function onChangeBuilding(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			data.data['id'] = data.id;
			var unit:Unit = Unit.add(data.data);
				
			if (unit.info.config)
			{
				var unitConfig:Array = String(unit.info.config).split('').reverse();
				for (var configID:int = 0; configID < unitConfig.length; configID++ ) 
				{
					if (unitConfig[configID] == "1" && unit.hasOwnProperty(CONFIG_DATA[configID])) 
					{
						unit[CONFIG_DATA[configID]] = false;
					}
				}
			}
			
			mainMap.push(unit);
		}
		
		/**
		 * Создание сетки
		 * @param	markersData сетка поверхности
		 * @param	zonesData сетка зон
		 */
		private function initGridNodes(gridData:Array) : void {
			
			var hasWater:Boolean = false;
			_aStarNodes = new Vector.<Vector.<AStarNodeVO>>();
			_aStarParts = new Vector.<Vector.<AStarNodeVO>>();
			//_aStarWaterNodes = new Vector.<Vector.<AStarNodeVO>>();
			var x : uint = 0;
			var z : uint = 0;
			
			while ( x < Map.cells) {
				_aStarNodes[x] = new Vector.<AStarNodeVO>();
				_aStarParts[x] = new Vector.<AStarNodeVO>();
				//_aStarWaterNodes[x] = new Vector.<AStarNodeVO>();
				
				while ( z < Map.rows){
					var node :AStarNodeVO  = new AStarNodeVO();
					var part :AStarNodeVO  = new AStarNodeVO();
					//var water :AStarNodeVO  = new AStarNodeVO();
					
					node.h = 0;
					part.h = 0;
					
					node.f = 0;
					part.f = 0;
					
					node.g = 0;
					part.g = 0;
					
					node.visited = false;
					part.visited = false;
					//water.visited = false;
					
					node.parent = null;
					part.parent = null;
					//water.parent = null;
					
					node.closed = false;
					part.closed = false;
					//water.closed = false;
					
					node.position = new Point(x, z);
					part.position = new Point(x, z);
					//water.position = new Point(x, z);
					
					node.isWall = gridData[x][z].p;
					part.isWall = gridData[x][z].p;
					//water.isWall = !gridData[x][z].w;
					
					if (gridData[x][z].w != null)	hasWater = true;
					
					node.z = assetZones[gridData[x][z].z];// 5;
					
					if (World.zoneIsOpen(node.z)) {
						node.open = true;
					}
					
					node.b = gridData[x][z].b;
					node.p = gridData[x][z].p;
					node.w = gridData[x][z].w;
					
					var point:Object = IsoConvert.isoToScreen(x, z, true);
					var cell:IsoTile = new IsoTile(point.x, point.y);
					
					node.tile = cell;
					part.tile = cell;
					//water.tile = cell;
					
					_aStarNodes[x][z]  = node;
					_aStarParts[x][z]  = part;
					//_aStarWaterNodes[x][z]  = water;
					z++;
				}
				z=0;
				x++;
			}
			
			_astar 			= new AStar(_aStarNodes);
			_astarReserve 	= new AStar(_aStarParts);
			
			_aStarWaterNodes = null;
		}
		
		public function createGrid():void
		{
			var _plane:Sprite = new Sprite();
			addChild(_plane);
			
			var zoneIDs:Object = { };
			for (var x:int = 0; x < Map.cells; x++) {
				for (var z:int = 0; z < Map.rows; z++) {
					var znID:* = _aStarNodes[x][z].z;
					if(!zoneIDs.hasOwnProperty(znID))
						zoneIDs[znID] = { minX:1000, minZ:1000, maxX:0, maxZ:0,objects:[]};
					zoneIDs[znID].minX = Math.min(zoneIDs[znID].minX, x);
					zoneIDs[znID].minZ = Math.min(zoneIDs[znID].minZ, z);
					zoneIDs[znID].maxX = Math.max(zoneIDs[znID].maxX, x);
					zoneIDs[znID].maxZ = Math.max(zoneIDs[znID].maxZ, z);
					
					if(_aStarNodes[x][z].object && zoneIDs[znID].objects.indexOf(_aStarNodes[x][z].object) == -1){
						zoneIDs[znID].objects.push(_aStarNodes[x][z].object);
					}
					if (_aStarNodes[x][z].p == 0) {
						if(displayOnMap == 'object'){
							if (_aStarNodes[x][z].object) {
								_plane.graphics.beginFill(0xff0000, 0.6);
							}else {
								_plane.graphics.beginFill(0x00ff00, 0.6);
							}
						}
						if(displayOnMap == 'zones'){
							_plane.graphics.beginFill(/*0x339900 + */_aStarNodes[x][z].z * 4096, 0.8);
						}
						//_plane.graphics.beginFill(0x339900 , 0.8);
					}else {
						if (!_aStarNodes[x][z].w) {
							_plane.graphics.beginFill(0xaabbff, 0.8);
						}else{
							_plane.graphics.beginFill(0xCC0000, 0.8);
						}
					}
					
					var point:Object = IsoConvert.isoToScreen(x, z, true);
					_plane.graphics.moveTo(point.x, point.y);
					_plane.graphics.lineTo(point.x - 20, point.y + 10);
					_plane.graphics.lineTo(point.x, point.y + 20);
					_plane.graphics.lineTo(point.x + 20, point.y + 10);
					_plane.graphics.endFill();
				}
			}
			
			for (var i:* in zoneIDs)
			{
				var zTxt:TextField = Window.drawText(String(i), { fontSize:60 } );
				var cl:int = int((zoneIDs[i].minX + zoneIDs[i].maxX) / 2);
				var rw:int = int((zoneIDs[i].minZ + zoneIDs[i].maxZ) / 2);
				var crds:Object = IsoConvert.isoToScreen(cl, rw, true, false);
				zTxt.x = crds.x;
				zTxt.y = crds.y;
				_plane.addChild(zTxt);
			}
			
			var bmd:BitmapData = new BitmapData(_plane.width, _plane.height, true, 0);
				bmd.draw(_plane);
				
				removeChild(_plane);
				_plane = null;
				
			_grid = new Bitmap(bmd);
			addChild(_grid);
		}
		
		public function createSectors(step:int = 5):void
		{
			var _plane:Sprite = new Sprite();
			addChild(_plane);
			
			var zoneIDs:Object = { };
			for (var x:int = 0; x < Map.cells; x += step) 
			{
				for (var z:int = 0; z < Map.rows; z += step) 
				{
					var colour:uint = 0xaabbff;
					var _zone:Object = {x:x, z:z, size:step};
					var fader:Shape = new Shape();
					var point:Object = IsoConvert.isoToScreen(_zone.x, _zone.z, true);
					fader.graphics.beginFill(colour, 1);
					fader.graphics.moveTo(point.x, point.y);
					
					point = IsoConvert.isoToScreen(_zone.x + _zone.size, _zone.z, true);
					fader.graphics.lineTo(point.x, point.y);
					
					point = IsoConvert.isoToScreen(_zone.x + _zone.size, _zone.z + _zone.size, true);
					fader.graphics.lineTo(point.x, point.y);
					
					point = IsoConvert.isoToScreen(_zone.x, _zone.z + _zone.size, true);
					fader.graphics.lineTo(point.x, point.y);
					
					point = IsoConvert.isoToScreen(_zone.x, _zone.z, true);
					fader.graphics.lineTo(point.x, point.y);
					
					fader.graphics.endFill();
					fader.filters = [new GlowFilter(0xffffff, 1, 2, 2, 8, 1, true)];
					fader.alpha = .5;
					_plane.addChild(fader);
					
					
					var node:AStarNodeVO = App.map._aStarNodes[_zone.x][_zone.z];
					var numberSector:TextField = Window.drawText(String(node.sector.id),{
						fontSize:18,
						color:0xf2efe7,
						autoSize:"center"
					})
					numberSector.width = numberSector.textWidth + 3;
					numberSector.x = point.x
					numberSector.y = point.y
					
					_plane.addChild(numberSector);
				}
			}
			
			var bmd:BitmapData = new BitmapData(_plane.width, _plane.height, true, 0);
				bmd.draw(_plane);
				
				removeChild(_plane);
				_plane = null;
			_grid = new Bitmap(bmd);
			mTreasure.addChild(_grid);
		}
		
		/**
		 * Перерисовка карты при ее перемещении
		 * @param	dx	смещение по X оси
		 * @param	dy	смещение по Y оси
		 */
		public function redraw(dx:int, dy:int):void 
		{
			Map.focused = false;	
			if (focusTween) {
				focusTween.kill()
				focusTween = null;
			}
			if (focusCenTween) {
				focusCenTween.kill()
				focusCenTween = null;
			}
			
			if (!(x + dx - mapPadding * 2 < 0 && x + dx > stage.stageWidth - mapWidth * scaleX - mapPadding/**.8*/)) 
			{
				dx = 0;
			}
			
			if (!(y + dy - mapPadding * 2 < 0 && y + dy > stage.stageHeight - mapHeight * scaleY - mapPadding*2)) 
			{
				dy = 0;
			}
			
			
			if (dx || dy) 
			{
				tX += dx;
				tY += dy;
			}
			/*if (dx || dy) 
			{
				x += dx;
				y += dy;
				onRedrawDispatch();
				//additionalCheck = false
			}*/
			/*if (additionalCheck || tX != 0 || tY != 0)
			{
				onRedrawDispatch();
				additionalCheck = false
			}*/
			
			//x += tX;
			//tX = 0;
			//y += tY;
			//tY = 0;
			
			replacingDist ++;
			if (replacingDist > 20) 
			{
				replacingDist = 0;
			}
		}
		public var centerPoint:Shape;
		private function posChecker(e:* = null):void
		{
			if (additionalCheck || tX != 0 || tY != 0)
			{
				onRedrawDispatch();
				additionalCheck = false
			}
			
			x += tX;
			tX = 0;
			y += tY;
			tY = 0;
			/*
			if (centerPoint)
			{
				
				centerPoint.x = -App.map.x / scaleX + (App.self.stage.stageWidth / scaleX) / 2;
				centerPoint.y = -App.map.y / scaleY + (App.self.stage.stageHeight / scaleY) /  2;
				centerPoint.z = 0; 
			}*/
		}
		
		
		
		public function onRedrawDispatch():void 
		{
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_MAP_REDRAW));
		}
		
		public function center():void 
		{
			//if (App.user.quests.tutorial && QuestsRules.mapFocus())
				//return;
			//App.self.dispatchEvent(new AppEvent(AppEvent.ON_MAP_REDRAW));
			if (App.user.personages.length > 0)
				focusedOn(App.user.hero, false, null, false);
			else {
				var position:Object = IsoConvert.isoToScreen(App.map.heroPosition.x, App.map.heroPosition.z, true);
				App.map.focusedOn(position, false, null, false);
			}
		}
		
		/*public function set scale(value:Number):void 
		{
			App.map.scaleX = App.map.scaleY = value;
			App.self.resizeStarling();
			//redraw();
		}*/
		
		
		public function align():void 
		{
			if (App.user.worldID == User.AQUA_HERO_LOCATION)
				return;
			
			if (x > mapPaddingX)
				x = mapPaddingX;
				
			if (y > mapPaddingY)	
				y = mapPaddingY;
				
			if (x < stage.stageWidth - mapWidth * scaleX - mapPaddingX) {
				x = stage.stageWidth - mapWidth * scaleX - mapPaddingX;
			}	
			
			if (y < stage.stageHeight - mapHeight * scaleY - mapPaddingY) {
				y = stage.stageHeight - mapHeight * scaleY - mapPaddingY;
			}
		}
		 
		// Icon service
		public function iconSortSetHighest(icon:UnitIcon):void 
		{
			if (!icon || icon.parent != mIcon) return;
			var depth:int = mIcon.getChildIndex(icon);
			if (depth < mIcon.numChildren - 1)
				mIcon.swapChildrenAt(depth, App.map.mIcon.numChildren - 1);
		}
		public function iconSortResort(now:Boolean = false):void 
		{
			if (iconSortTimeout > 0) clearTimeout(iconSortTimeout);
			if (!now) {
				iconSortTimeout = setTimeout(iconSortResort, 10, true);
				return;
			}else {
				iconSortTimeout = 0;
			}
			if (!mIcon)
				return;
			var index:int = 0;
			while (index < mIcon.numChildren - 1) {
				if (mIcon.getChildAt(index).y > mIcon.getChildAt(index + 1).y) {
					mIcon.swapChildrenAt(index, index + 1);
					index = 0;
				}else{
					index ++;
				}
			}
		}
		
		public function addUnit(unit:*):void 
		{
			switch(unit.layer) {
				case LAYER_FIELD:
					mField.addChild(unit); break;
				case LAYER_LAND:
					mLand.addChild(unit); break;
				case LAYER_TREASURE:
					mTreasure.addChild(unit); break;
				case LAYER_SORT:  
					depths.push(unit);
					sorted.push(unit);
					mSort.addChild(unit);
					
					break;
			}
		}
		
		public function removeUnit(unit:*):void 
		{
			if (App.map[unit.layer] == null)
				return;
			switch(unit.layer) {
				case LAYER_FIELD: 		if(mField.contains(unit)) 		mField.removeChild(unit); break;
				case LAYER_LAND:  		if(mLand.contains(unit))		mLand.removeChild(unit); break;
				case LAYER_SORT:  		
					
					var index:int = depths.indexOf(unit);
					if(index>=0)	depths.splice(index, 1);
					
					index = sorted.indexOf(unit);
					if (index >= 0) sorted.splice(index, 1);
					
					if (mSort.contains(unit)) 		
						mSort.removeChild(unit); 
					
					break;
				case LAYER_TREASURE:  	if(mTreasure.contains(unit)) 	mTreasure.removeChild(unit); break;
			}
		}
		
		public function clearZonesMinizone():void
		{
			for each(var _fader:* in faders)
			{
				if(_fader.parent)
					_fader.parent.removeChild(_fader);
			}
			faders = new Vector.<Sector>();
			zonesResources = {};
		}
		
		public function loadDefault():void
		{
			var self:Map = this;
			
			Log.alert('getLandData');
			Log.alert(Config.getLandData(String(this.id)));
			Load.loadText(Config.getLandData(String(this.id)), function(text:String):void 
			{
				self.defaultJson = JSON.parse(text);
				//self.checkDefResources();
				self.checkZonesMinizone();
			}, false);
		}
		
		public function checkZonesMinizone():void
		{
			clearZonesMinizone();
			
			var i:int = 0;
			var j:int = 0;
			var pseId:int;
			for (i = 0; i < Map.cells; i += sizeMinizone)
			{
				for (j = 0; j < Map.rows; j += sizeMinizone)
				{
					pseId = ((i / sizeMinizone) * ((Map.rows) / sizeMinizone)) + (j / sizeMinizone);
					drawMiniZone({x:i, z:j, size:sizeMinizone, id:pseId + 1});
				}
			}
			checkDefResources();
			checkNeighbors();
			setTimeout(function():void{
				checkToOpenNeighbors();
			}, 500);
			
			
			if (App.user.useSectors)
			{
				var node:AStarNodeVO = App.map._aStarNodes[App.map.heroPosition.x][App.map.heroPosition.z];
				node.sector.open = true;
				node.sector.openNeiborsForcibly();
			}
			allSorting();
		}
		
		public function checkToOpenNeighbors():void
		{
			for each(var _sector:Sector in faders)
			{
				_sector.openNeibors();
				if(App.user.worldID != User.FARM_LOCATION)
					_sector.checkFog();
			}
		}
		
		public function checkDefResources():void
		{
			var node:AStarNodeVO;
			for each(var _res:* in defaultJson)
			{
				for (var _val:* in _res)
				{
					propsValues[_val] = 1;
				}
				if (App.data.storage[_res.sid].type != 'Resource')
					continue;
				if (inGrid({x:_res.x, z:_res.z}))
				{
					node = App.map._aStarNodes[_res.x][_res.z];
					
					node.sector.defResources[_res.id] = _res;
				}
			}
		}
		
		public function checkNeighbors():void
		{
			for each(var _sector:Sector in faders)
			{
				// Z - 1 
				if (inGrid({x:_sector.coords.x - 1, z:_sector.coords.z - 1}))
					_sector.neighbors.push(App.map._aStarNodes[_sector.coords.x - 1][_sector.coords.z - 1].sector);
					
				if (inGrid({x:_sector.coords.x + int(_sector.coords.size/2), z:_sector.coords.z - 1}))
					_sector.neighbors.push(App.map._aStarNodes[_sector.coords.x + int(_sector.coords.size/2)][_sector.coords.z - 1].sector);
					
				if (inGrid({x:_sector.coords.x + _sector.coords.size + 1, z:_sector.coords.z - 1}))
					_sector.neighbors.push(App.map._aStarNodes[_sector.coords.x + _sector.coords.size + 1][_sector.coords.z - 1].sector);
					
				// Z + SIZE + 1	
				if (inGrid({x:_sector.coords.x - 1, z:_sector.coords.z + _sector.coords.size + 1}))
					_sector.neighbors.push(App.map._aStarNodes[_sector.coords.x - 1][_sector.coords.z + _sector.coords.size + 1].sector);
					
				if (inGrid({x:_sector.coords.x + int(_sector.coords.size/2), z:_sector.coords.z + _sector.coords.size + 1}))
					_sector.neighbors.push(App.map._aStarNodes[_sector.coords.x + int(_sector.coords.size/2)][_sector.coords.z + _sector.coords.size + 1].sector);
					
				if (inGrid({x:_sector.coords.x + _sector.coords.size + 1, z:_sector.coords.z + _sector.coords.size + 1}))
					_sector.neighbors.push(App.map._aStarNodes[_sector.coords.x + _sector.coords.size + 1][_sector.coords.z + _sector.coords.size + 1].sector);
					
				// Z + SIZE / 2	
				if (inGrid({x:_sector.coords.x - 1, z:_sector.coords.z + int(_sector.coords.size / 2)}))
					_sector.neighbors.push(App.map._aStarNodes[_sector.coords.x - 1][_sector.coords.z + int(_sector.coords.size / 2)].sector);
					
				if (inGrid({x:_sector.coords.x + _sector.coords.size + 1, z:_sector.coords.z + int(_sector.coords.size / 2)}))
					_sector.neighbors.push(App.map._aStarNodes[_sector.coords.x + _sector.coords.size + 1][_sector.coords.z + int(_sector.coords.size / 2)].sector);
					
			}
		}
		
		public function drawMiniZone(_zone:Object):void
		{
			var clear:Boolean = true;
			var node:AStarNodeVO;
			var thisZone:int = 0;
			var sectorResources:Vector.<Resource> = new Vector.<Resource>();
			for (var i:int = _zone.x; i < _zone.x + _zone.size; i++)
			{
				if (App.map._aStarNodes.length <= i)
					continue;
				for (var j:int = _zone.z; j < _zone.z + _zone.size; j++)
				{
					if (App.map._aStarNodes[i].length <= j)
						continue;
						
					node = App.map._aStarNodes[i][j];
					if (node && node.object != null && node.object is Resource)
					{
						if (!zonesResources.hasOwnProperty(node.object['id']))
						{
							zonesResources[node.object['id']] = node.object;
							sectorResources.push(node.object);
							//reses ++;
							if (App.user.worldID == User.TRAVEL_LOCATION && thisZone != 0 && App.data.storage[thisZone].open == 1&& App.user.mode != User.PUBLIC)
								continue;
							if (thisZone != 0 && App.user.mode == User.PUBLIC)
								continue;
							thisZone = node.z;
							clear = false;
						}
					}
				}
			}
			if (!App.map.inGrid({x:_zone.x + int(_zone.size / 2), z:_zone.z + int(_zone.size / 2)}))
				return;
			if (clear)
			{
				if (!App.map.inGrid({x:_zone.x + int(_zone.size / 2), z:_zone.z + int(_zone.size / 2)}))
					return;
				node = App.map._aStarNodes[_zone.x + int(_zone.size/2)][_zone.z + int(_zone.size/2)];
				thisZone = node.z;
			}
			
			sector = new Sector({zone:_zone, resources:sectorResources, sectorZone:thisZone, sectorClear:clear});
			
			var point:Object = IsoConvert.isoToScreen( _zone.x,  _zone.z, true);
			sector.x = point.x;
			sector.y = point.y;
			
			sector.calcDepth();
			
			//mSort.addChild(sector);
			//depths.push(sector);
			faders.push(sector);
		}
		
		public function sorting(e:Event = null):void {
			globalSorting++;
			if (globalSorting % 2 == 0) return;
			
			if (sorted.length > 0) {
				
				depths.sortOn('depth', Array.NUMERIC);
				
				for each(var unit:* in sorted) {
					var index:int = depths.indexOf(unit);
					if(mSort.contains(unit)){
						try {
							//mSort.setChildIndex(unit, index);
							unit.sort(index);
						}catch (e:Error) {
							trace("can't sort " + unit)
						}
					}
				}	
				sorted = [];
				
				if (globalSorting >= 60) {
					var err:Boolean = false;
					for (var i:* in depths) {
						try{
							mSort.setChildIndex(depths[i], int(i));
						}catch (e:Error) {
							err = true;
						}
					}
					if (err) {
						globalSorting = 59;
					}else{
						globalSorting = 0;
					}
				}
			}
			if (globalSorting >= 60) {
				globalSorting = 0;
			}
		}
		
		public function allSorting():void {
			try {
				depths.sortOn('depth', Array.NUMERIC);
				for (var i:* in depths) {
					if(mSort.contains(depths[i])){
						mSort.setChildIndex(depths[i], int(i));
					}
				}
				
				var index:int = 0;
				while (index < mField.numChildren - 1) {
					if (mField.getChildAt(index).y > mField.getChildAt(index + 1).y) {
						mField.swapChildrenAt(index, index + 1);
						index = 0;
					}
					
					index++;
				}
			} catch (e:Error) {
				Log.alert(e.message + ' ' + index + ' ' + mField.numChildren);
			}
		}
		
		public function untouches():void {
			for each(var touch:* in touched) 
			{
				touch.touch = false;
			}
			touched = new Vector.<*>();
			Zone.untouches();
		}
		
		public function touches(e:MouseEvent):void {
			var bmp:Bitmap;
			
			under = getObjectsUnderPoint(new Point(e.stageX, e.stageY));
			Fog.touches();
			
			var length:uint = under.length;
			if (length > 0) {
				for each(var touch:* in touched) {
					bmp = touch.bmp;
					if (!touch.bitmap.bitmapData && touch.animeTouch && touch.animeTouch.bitmapData.getPixel(touch.animeTouch.mouseX, touch.animeTouch.mouseY) == 0)
					{
						touch.touch = false;
						touched.splice(touched.indexOf(touch), 1);
					}
					if (bmp.bitmapData && 
					bmp.bitmapData.getPixel(bmp.mouseX, bmp.mouseY) == 0 || 
					!touch.touchable) {
						touch.touch = false;
						touched.splice(touched.indexOf(touch), 1);
					}
				}
				
				for (var i:int = length-1; i >= 0; i--) {
					if (under[i].parent is BonusItem) {
						if(!BonusItem(under[i].parent).destObject)
							BonusItem(under[i].parent).cash();
					}
					if (under[i].parent is AnimationItem) {
						under[i].parent.touch = true;
						touched.push(under[i].parent);
						break;
					}
					if (!under[i].parent)
						continue;
					var unit:* = null;
					if (under[i].parent is Unit) {
						unit = under[i].parent;
					}
					else if (under[i].parent && under[i].parent.parent is Unit || under[i].parent.parent is WaitPlate)
					{
						unit = under[i].parent.parent;
					}
					else if (under[i].parent && under[i].parent.parent is Monster)
					{
						unit = under[i].parent.parent;
					}
					
					if (App.user.mode == User.OWNER && (App.user.worldID == User.AQUA_HERO_LOCATION))
					{
						if (unit is Wall)
							return;
						if (touchedZone != _aStarNodes[Map.X][Map.Z].z && Room.mayChecked == true)
						{
							Room.mayChecked = false;
							setTimeout(function():void{Room.mayChecked = true; }, Room.checkTime * 1000);
							
							rooms[_aStarNodes[Map.X][Map.Z].z].steteRoom(Room.LOWER);
							
							if (rooms.hasOwnProperty(touchedZone))
							{
								rooms[touchedZone].steteRoom(Room.FULL);
							}
							touchedZone = _aStarNodes[Map.X][Map.Z].z;
						}
					}
					
					if (unit != null){
						
						if (!unit.clickable || !unit.visible) {
							continue;
						}
							
						if (unit.bmp &&
							((unit.bmp.bitmapData && unit.bmp.bitmapData.getPixel(unit.bmp.mouseX, unit.bmp.mouseY) != 0) || 
							(unit.animationBitmap && unit.animationBitmap.bitmapData && unit.animationBitmap.bitmapData.getPixel(unit.animationBitmap.mouseX, unit.animationBitmap.mouseY) != 0))
						) {
							
							var toTouch:Boolean = true;
							if ((unit.cells + unit.rows) * .5 < 4) {
								toTouch = (Map.X+5 >= unit.coords.x && Map.Z+5 >= unit.coords.z || !unit.transable);
							}else {
								toTouch = (Map.X+2 >= unit.coords.x && Map.Z+2 >= unit.coords.z || !unit.transable);
							}
							//Убираем прозрачность
							if (toTouch) {
								
								if (unit.transparent) {
									unit.transparent = false;
								}
								
								//Выделяем объект
								if ((moved == null) && !unit.touch && touched.length == 0) {
									
									if (unit.layer == Map.LAYER_LAND)
									{
										if (Cursor.type == 'default' || Cursor.type == 'locked' || Cursor.type == 'boost') break;
									}
									touched.push(unit);
									unit.touch = true;
									//Выделили самый верхний не прозрачный и выходим
									break;
								}
								
							}else {
								if (!unit.transparent) {
									unit.transparent = true;
									transed.push(unit);
									
									if(unit.touch){
										unit.touch = false;
										touched.splice(touched.indexOf(unit), 1);
									}
								}
							}
						}
						
					}
				}
				
				for each(var trans:Unit in transed) {
					bmp = trans.bmp;
					
					if (bmp.bitmapData && trans.animationBitmap && trans.animationBitmap.bitmapData){
						if (
							(bmp.bitmapData && bmp.bitmapData.getPixel(bmp.mouseX, bmp.mouseY) == 0) &&
							(trans.animationBitmap && trans.animationBitmap.bitmapData && trans.animationBitmap.bitmapData.getPixel(trans.animationBitmap.mouseX, trans.animationBitmap.mouseY) == 0)
						) {
							trans.transparent = false;
							transed.splice(transed.indexOf(trans), 1);
						}
					}else {
						if ((bmp.bitmapData && bmp.bitmapData.getPixel(bmp.mouseX, bmp.mouseY) == 0)) {
							trans.transparent = false;
							transed.splice(transed.indexOf(trans), 1);
						}
					}
				}
			}
		}

		
		public function click():void
		{
			Field.clearBoost();
			
			if ((Cursor.type != "default" || Cursor.plant|| Cursor.accelerator || Cursor.type == "instance") && Cursor.type != "locked") 
			{	
				Cursor.type = 'default';
				Cursor.accelerator = false;
					return;
			}
			
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_MAP_CLICK));
			
			if (App.user.mode == User.OWNER){
				if (!App.user.world.checkZone(null, true)) return;
			}else{
				if (!App.owner.world.checkZone(null, true)) return;
			}
			
			if (App.user.hero && App.user.hero.tm.status != TargetManager.FREE) return;
			var point:Object = IsoConvert.screenToIso(this.mouseX, this.mouseY, true);
			if (App.user.useSectors)
			{
				var node:AStarNodeVO = App.map._aStarNodes[point.x][point.z];
				if (node.sector && node.sector.open == false)
					return;
				if(App.user.personages.length > 0)
					App.user.initPersonagesMove(point.x, point.z);
			}else{
				if(App.user.personages.length > 0)
					App.user.initPersonagesMove(point.x, point.z);
			}
			
			var effect:AnimationItem = new AnimationItem( { type:'Effects', view:'clickEffect', params: { scale:0.4 }, onLoop:function():void {
				App.map.mLand.removeChild(effect);
			}});
			SoundsManager.instance.playSFX('map_sound_1v3');
			if(mLand){
				mLand.addChild(effect);
				effect.x = this.mouseX;
				effect.y = this.mouseY;
			}
		}
		
		public function touch():void
		{
			if (Cursor.type == "instance") {
				Cursor.type = 'default';
				return;
			}
			
			if (touched.length && (touched.length > 0) && !(touched[0] is Unit || touched[0] is Monster || touched[0] is WaitPlate)) return;
			if (touched.length > 0)
			{
				var unit:* = touched[0];
			}else 
			{
				return
			}
			
			if (!(unit is Hero)) App.self.dispatchEvent(new AppEvent(AppEvent.ON_MAP_TOUCH));
			
			var world:World;
			if (App.user.mode == User.OWNER)
				world = App.user.world;
			else	
				world = App.owner.world;
				
			switch(Cursor.type)
			{
				case "move":
					if(App.user.worldID != User.AQUA_HERO_LOCATION)
						if (!world.checkZone(null, true)) return;
						
					if (unit.can()) {
						break;
					}
					unit.fromStock = false;
					unit.move = true;
					if (unit.move) {
						moved = unit;
					}
					break;
					
				case "remove":
					if(App.user.worldID != User.AQUA_HERO_LOCATION)
						if (!world.checkZone(null, true)) return;
						
					if (unit.can()) {
						break;
					}
					touched.splice(0, 1);
					unit.touch = false;
					unit.remove();
					
					break;
					
				case "rotate":
					if(App.user.worldID != User.AQUA_HERO_LOCATION)
						if (!world.checkZone(null, true)) return;
						
					if (unit.can()) {
						break;
					}
					unit.rotate = !unit.rotate;
					break;
				
				case "stock":
					if(Cursor.toStock){
						if(App.user.worldID != User.AQUA_HERO_LOCATION)
							if (!world.checkZone(null, true)) return;
						if (unit.can()) {
							break;
						}
						unit.putAction();
						break;	
					}
					
				default:
					if (!(unit is Field)) {
						Cursor.plant = null;
						ShopWindow.currentBuyObject.type = null;
						ShopWindow.currentBuyObject.currency = null;
					}
					if (!(unit is Lantern) && !(unit is BonusItem) && !(unit is Animal) && !(unit is Walkgolden) && !(unit is SpiritZone) && !(unit is Resource) && !(unit is Bridge)) {
						
						if(App.user.worldID != User.AQUA_HERO_LOCATION)
							if (!world.checkZone(null, true)) return;
					}
					
					unit.click();
					if(!(unit is Animal))
						App.self.dispatchEvent(new AppEvent(AppEvent.ON_STOP_MOVE));
				break;
			}
		}
		
		public function focusedOnPoint(point:Point):void
		{
			var tweenTime:Number = 1.0;
			var target:Object = IsoConvert.isoToScreen(point.x, point.y, true);
			var targetX:Object = -target.x * scaleX + App.self.stage.stageWidth / 2;
			var targetY:Object = -target.y * scaleX + App.self.stage.stageHeight / 2;
			TweenLite.to(this, tweenTime, { x:targetX, y:targetY } );
			
		}
		
		public function focusedOn(unit:*, glowing:Boolean = false, callback:Function = null, tween:Boolean = true, scale:* = null, considerBoder:Boolean = true, tweenTime:Number = 1, focusOnCenter:Boolean = false,follow:Boolean = false):void
		{
			unitTarget = unit;
			if (App.user.quests.tutorial && tweenTime == 1)
				tweenTime = 0.5;
				
			if (scale == null)
				scale = this.scaleX;
			
			var targetX:int = -unit.x * scale + App.self.stage.stageWidth / 2;
			var targetY:int = -unit.y * scale + App.self.stage.stageHeight / 2;
			
			if(considerBoder){
				if (targetX > 0) targetX = 0;
				else if (targetX < stage.stageWidth - mapWidth * scale) 	targetX = stage.stageWidth - mapWidth * scale;
				
				if (targetY > 0) 
					targetY = 0;
				else if  (targetY < stage.stageHeight - mapHeight * scale) 
					targetY = stage.stageHeight - mapHeight * scale;
			}
			
			if (tween == false || (x == targetX && y == targetY)) 
			{
				x = targetX;
				y = targetY;
				
				if (callback != null) callback();
				return;
			}
			
			if(scale == this.scaleX)
				focusTween = TweenLite.to(this, tweenTime, { x:targetX, y:targetY, onComplete:onComplete } );
			else
				focusTween = TweenLite.to(this, tweenTime, { x:targetX, y:targetY, scaleX:scale, scaleY:scale, onComplete:onComplete } );
			
			function onComplete():void {
				if (glowing) App.ui.flashGlowing(unit);
				if(callback != null){
					callback();
				}
				focusTween = null;
				
				if (follow) 
				{
					addEventListener(Event.ENTER_FRAME, followThis);
				}
			}
		}
		
		private function initMonster():void 
		{
			var boxes:Array = findUnits([2335]);
			if (boxes.length > 0 && !Monster.self)
			{
				var params:Object = {
					finish		:{x:boxes[0].coords.x, z:boxes[0].coords.z}, 
					endLife		:App.user.data['publicWorlds'][App.owner.worldID],
					totalTime	:App.data.storage[App.owner.worldID].duration,
					box			:boxes[0]
				}
				Monster.init(params);
			}
		}
		
		private function followThis(e:Event):void 
		{
			focusedOn(unitTarget);
		}
		
		public function stopFocus():void 
		{
			try 
			{
				removeEventListener(Event.ENTER_FRAME, followThis);
			}
			catch (err:Error)
			{
				//trace(err);
			}
		}
		
		public function focusedOnCenter(unit:*, glowing:Boolean = false, callback:Function = null, tween:Boolean = true, scale:* = null, considerBoder:Boolean = true, tweenTime:Number = 1, focusOnCenter:Boolean = false):void
		{
			if (App.user.quests.tutorial)
				tweenTime = 0.5;
			
			if (scale == null)
				scale = this.scaleX;
				
			var posX:int;
			var posY:int;
			
			if (unit.scaleX == 1) 
			{
				posX = unit.x + unit.bitmap.x + unit.bitmap.width / 2;
				posY = unit.y + unit.bitmap.y + unit.bitmap.height / 2;
			}else 
			{
				posX = unit.x + unit.bitmap.width / 2 - (unit.bitmap.width + unit.bitmap.x);
				posY = unit.y + unit.bitmap.y + unit.bitmap.height / 2;
			}
			
			var targetX:int = -posX * scale + App.self.stage.stageWidth / 2;
			var targetY:int = -posY * scale + App.self.stage.stageHeight / 2;
			
			if (considerBoder)
			{
				if (targetX > 0) targetX = 0;
				else if (targetX < stage.stageWidth - mapWidth * scale) 	targetX = stage.stageWidth - mapWidth * scale;
				
				if (targetY > 0) 
					targetY = 0;
				else if  (targetY < stage.stageHeight - mapHeight * scale) 
					targetY = stage.stageHeight - mapHeight * scale;
			}
			
			if (tween == false || (x == targetX && y == targetY)) 
			{
				x = targetX;
				y = targetY;
				if (callback != null) callback();
				return;
			}
			
			SystemPanel.scaleValue = scale;
			SystemPanel.updateScaleMode();
			App.ui.systemPanel.updateScaleBttns();
			
			if(scale == this.scaleX)
				focusCenTween = TweenLite.to(this, tweenTime, { x:targetX, y:targetY, onComplete:onComplete } );
			else
				focusCenTween = TweenLite.to(this, tweenTime, { x:targetX, y:targetY, scaleX:scale, scaleY:scale, onComplete:onComplete } );
			
			function onComplete():void {
				if (glowing) App.ui.flashGlowing(unit);
				if(callback != null){
					callback();
				}
				focusCenTween = null;
			}
		}
		
		public function watchOn(unit:Unit, slow:Number = 2):void 
		{
			if (!watchUnit)
				App.self.setOnEnterFrame(onWatchOn);
			
			watchSlow = slow;		// Коефициент довода камеры ( 1 - жестко привязяна к объекту, 2< - увеличение торможения )
			watchUnit = unit;
		}
		private function onWatchOn(e:Event):void 
		{
			if (!watchUnit) 
			{
				watchOff();
				return;
			}
			
			var targetX:Number = -watchUnit.x * this.scaleX + App.self.stage.stageWidth / 2;
			var targetY:Number = -watchUnit.y * this.scaleX + App.self.stage.stageHeight / 2;
			x = x + (targetX - x) / watchSlow;
			y = y + (targetY - y) / watchSlow;
		}
		public function watchOff():void 
		{
			if (watchUnit) 
			{
				App.self.setOffEnterFrame(onWatchOn);
				watchUnit = null;
			}
		}
		
		public function saveMap():void
		{
			var unitsArray:Array = [];
			var unitObject:Object = {};
			var unit:*;
			var index:int = App.map.mSort.numChildren;
			
			while (--index >= 0) 
			{
				unit = App.map.mSort.getChildAt(index);
				if (!(unit is Unit))
					continue;
				if (unit is Hero)
					continue;
				unitObject = {};
				
				if (!unit.hasOwnProperty('sid'))
					continue;
					
				if (unit.hasOwnProperty('workers'))
				{
					unitObject['workers'] = {(unit['id']): unit['workers'][0]};
				}
				if (unit.hasOwnProperty('coords'))
				{
					unitObject['x'] = unit['coords']['x'];
					unitObject['z'] = unit['coords']['z'];
				}
				
				for each(var _param:* in params)
				{
					if (unit.hasOwnProperty(_param) && unit[_param] != null && unit[_param] != 0)
					{
						if (_param == 'capacity' && unit[_param] == App.data.storage[_param] == unit[_param])
						{
							continue;
						}
						unitObject[_param] = unit[_param];
					}
				}
					
				unitsArray.push(unitObject);
			}
			
			index = App.map.mLand.numChildren;
			while (--index >= 0) 
			{
				unit = App.map.mLand.getChildAt(index);
				if (!(unit is Unit))
					continue;
				if (unit is Hero)
					continue;
				unitObject = {};
				
				if (!unit.hasOwnProperty('sid'))
					continue;
					
				if (unit.hasOwnProperty('workers'))
				{
					unitObject['workers'] = {(unit['id']): unit['workers'][0]};
				}
				if (unit.hasOwnProperty('coords'))
				{
					unitObject['x'] = unit['coords']['x'];
					unitObject['z'] = unit['coords']['z'];
				}
				
				for each(var _param2:* in params)
				{
					if (unit.hasOwnProperty(_param2) && unit[_param2] != null && unit[_param2] != 0)
					{
						unitObject[_param2] = unit[_param2];
					}
				}
				/*unitObject['sid'] = unit['sid'];
				unitObject['id'] = unit['id'];
				unitObject['x'] = unit['coords']['x'];
				unitObject['z'] = unit['coords']['z'];
				unitObject['rotate'] = unit['rotate'];
				if (unit.hasOwnProperty('level'))
					unitObject['level'] = unit['level'];
				if (unit.hasOwnProperty('busy'))
					unitObject['busy'] = unit['busy'];
				if (unit.hasOwnProperty('helpers'))
					unitObject['helpers'] = unit['helpers'];
				if (unit.hasOwnProperty('bID'))
					unitObject['bID'] = unit['bID'];
				if (unit.hasOwnProperty('bTime'))
					unitObject['bTime'] = unit['bTime'];*/
					
				unitsArray.push(unitObject);
			}
			
			//sendMap(JSON.stringify(unitsArray))
			//Saver.uploadFile(JSON.stringify(unitsArray));
			Saver.saveText(JSON.stringify(unitsArray), String(App.user.worldID));
			/*for each(var unit:* in App.map.mSort)
			{
				unitObject = {};
				unitObject['sid'] = unit['sid'];
				unitObject['x'] = unit['coords']['x'];
				unitObject['z'] = unit['coords']['z'];
				unitObject['rotate'] = unit['rotate'];
				unitsArray.push(unitObject)
			}*/
			//unitsArray;
		} 
		
		private function sendMap(data:*):void 
		{
			_worldData = data;
			var sendObject:Object = {
				ctr:'World',
				act:'pcreateunits',
				uID:App.user.id,
				wID:App.user.worldID,
				map:data
			}
			Post.send(sendObject, onSendMap);
		}
		
		private function onSendMap(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			if (!App.user.data.hasOwnProperty('publicWorlds'))
				App.user.data['publicWorlds'] = {};
				
			App.user.data['publicWorlds'][App.owner.worldID] = 0;
			
			defaultJson = JSON.parse(_worldData);
			checkZonesMinizone();
			initMonster();
		}
		private var dTimer:Timer
		private var dispInterval:uint;
		private var uChilds:int;
		private var maxUChilds:int;
		public function disposeSortUnits():void 
		{
			if (mSort)
			{
				uChilds = mSort.numChildren;
				maxUChilds = uChilds;
				dTimer = new Timer(10, 0);
				dTimer.start();
				dTimer.addEventListener(TimerEvent.TIMER, _disposeSortUnits);
			}else{
				disposeUnits();
			}
		}
		public var removed:Boolean;
		private function _disposeSortUnits(e:* = null):void 
		{
			var unit:*;
			//var childs:int;
			//if(mSort){
				//uChilds = mSort.numChildren-1;
				
				//dispInterval = setInterval(function():void 
				//{
			var _counter:int = 50;
			VisitWindow.disposeProgress((maxUChilds - uChilds) / maxUChilds);
			while (uChilds--) {
				if (mSort.numChildren < uChilds)
					continue;
				unit = mSort.getChildAt(uChilds);
				if (unit is Resource) {
					unit.clearVars = true;
					unit.dispose();
				}else
				//if (!(unit is Resource)) 
				{
					if(unit is Unit){
						unit.clearVars = true;
						unit.uninstall();
					}
				}
				
				//uChilds--;
				unit = null;
				if(uChilds <= 0){
					//clearInterval(dispInterval);
					disposeUnits();
				}
				_counter --;
				
				if (_counter == 0)
					return;
			}
				//},.000001);
			//}
		}
		
		public function disposeUnits():void 
		{
			if(dTimer){
				dTimer.stop();
				dTimer.removeEventListener(TimerEvent.TIMER, _disposeSortUnits);
				dTimer = null;
			}
			sorted = [];
			depths = [];
			
			Bubbles.disposeSpots();
			
			var unit:*;
			var childs:int;
			var tempUnit:*;
			App.self.setOffEnterFrame(sorting);
			
			if(mSort){
				childs = mSort.numChildren;
				while (childs--) {
					unit = mSort.getChildAt(childs);
					if (unit is Resource) {
						//unit.clearVars = true;
						unit.dispose();
					}
					if(!(unit is Unit) && !(unit is Fog) && !(unit is RoomFader) && !(unit is Plant)){
						//if(!(unit is Fog) && !(unit is Plant))
						unit.uninstall();
					}
					unit = null;	
				}
			}
			
			if(mLand){
				childs = mLand.numChildren;
				while (childs--) {
					try
					{
						unit = mLand.getChildAt(childs);
						
						if (unit is Unit) {
							unit.uninstall();
						}
						unit = null;
					}catch (e:Error) {
						trace('mLand ' + e);
					}	
				}
				mLand = null;
			}
			if(mField){
				childs = mField.numChildren;
				while (childs--) {
					//try
					//{
						unit = mField.getChildAt(childs);
						
						if (unit is Unit) {
							unit.uninstall();
						}
						unit = null;
					//}catch (e:Error) {
						//trace('mField ' + e);
					//}	
				}
				
				
				mSort = null;
				mField = null;
			}
			Fog.dispose();
			//Fog.removeFogs();
			
			Lantern.dispose();
			Troops.dispose();
			SoundsManager.instance.dispose();
			//Pigeon.dispose();
			Waves.dispose();
			Wigwam.wigwams = new Vector.<Wigwam>();
			clearZonesMinizone();
			
			touched = new Vector.<*>();
			lastTouched = new Vector.<Unit>();
			rooms = new Object();
			transed = new Vector.<Unit>();
			
			/*if (bitmap && bitmap.bitmapData){
				bitmap.bitmapData.dispose();
				bitmap.bitmapData = null;
			}*/
			mUnits = null;
			//mEffects.dispose();
			//mEffects = null;
			mTreasure = null;
			mFog = null;
			mIcon = null;
			
			while (numChildren > 0) {
				removeChildAt(0);
			}
			if(parent)
				parent.removeChild(this);
			disposeOther();
		}
		
		public function disposeOther():void 
		{
			_aStarNodes = null;
			_aStarParts = null;
			_aStarWaterNodes = null;
			_astar = null;
			_astarReserve = null;
			_astarWater = null;
			
			clearVariables();
			
			//Load.clearAllCache();
			System.gc();
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_MAP_REMOVE));
			removed = true;
		}
		
		public function dispose():void {
			Load.clearLoad();
			clearTimeout(iconSortTimeout);
			
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, posChecker);
			timer = null;
			
			for each(var _room:Room in rooms){
				_room.dispose();
			}
			disposeSortUnits();
		}
		
		public function clearVariables():void {
			var self:* = this;
			var description:XML = describeType(this);
			var dscd:XMLList = description.descendants("variable"); 
			var variables:XMLList = description..variable;
			for each(var variable:XML in variables) {
				var ss:String = variable.@type;
				switch(ss){
					case 'Bitmap':
						self[variable.@name] = null;
						continue;
						break;
					case 'Sprite':
						if (self[variable.@name]){
							self[variable.@name].removeChildren();
							self[variable.@name] = null;
						}
						continue;
						break;
				}
				if(ss.search(/units::/) != -1)
				{
					self[variable.@name] = null;
				}
				if(variable.@type == '*')
				{
					self[variable.@name] = null;
				}
			}
			self = null;
		}
		
		public static function glow(width:int, height:int, blur:int = 100):Bitmap 
		{
			var glow:Shape = new Shape();
			glow.graphics.beginFill(0x8de8b6, 1);
			glow.graphics.drawEllipse(0, 0, width, height);
			glow.graphics.endFill();
			
			glow.filters = [new BlurFilter(blur, blur, 3)];
			
			var padding:int = 80;
			var cont:Sprite = new Sprite();
			cont.addChild(glow);
			glow.x = padding;
			glow.y = padding;
			
			var bmd:BitmapData = new BitmapData(glow.width + 2 * padding, glow.height + 2 * padding, true, 0);
			bmd.draw(cont);
			
			cont = null;
			glow = null;
			
			return new Bitmap(bmd);
		}
		
		public static function traceAllResource(_units:*):void
		{
			var res:Object = { };
			var totalCount:uint = 0;
			
			for each(var item:Object in _units) {
				if ( App.data.storage[item.sid].type == "Resource")
				{
					var resource:Object =App.data.storage[item.sid];
					if (!res.hasOwnProperty(resource.title))
					{
						res[resource.title] = {count:0, capacity:0};
					}
					
					res[resource.title].count ++;
					res[resource.title].capacity += item.capacity;
					totalCount ++;
				}
			}
		}
		
		public static function findNearestFreePosition(object:Object, aStarNodes:Vector.<Vector.<AStarNodeVO>> = null, viewedPoints:Vector.<Point> = null):Object 
		{
			var x:int = object.x;
			var y:int = object.z;
			var fX:int = x;
			var fY:int = y;
			var radius:int = 0;
			var sideType:int = 3;
			var emergencyCounter:int = 0;
			if (!aStarNodes)
				var _astarNodes:Vector.<Vector.<AStarNodeVO>>  = App.map._aStarNodes;
			else
				_astarNodes = aStarNodes;
			if (!viewedPoints)
				viewedPoints = new Vector.<Point>;
			function isViewed(_fx:int, _fy:int):Boolean
			{
				for each (var pos:Point in viewedPoints)
				{
					if (pos.x == _fx && _fy == pos.y)
						return true;
				}
				return false;
			}
			while (true) {
				if (emergencyCounter > 1000) break;
				emergencyCounter++;
				
				if (fX >= 0 && fY >= 0 && fX < _astarNodes.length && fY < _astarNodes[fX].length && _astarNodes[fX][fY].open == 1 && _astarNodes[fX][fY].isWall == 0 && !isViewed(fX,fY)) {
					object.x = fX;
					object.z = fY;
					return object;
				}
				if (sideType == 0) {
					fY++;
					if (fY >= y + radius) sideType = 1;
				}else if (sideType == 1) {
					fX--;
					if (fX <= x - radius) sideType = 2;
				}else if (sideType == 2) {
					fY--;
					if (fY <= y - radius) sideType = 3;
				}else if (sideType == 3) {
					fX ++;
					if (fX > x + radius) {
						radius++;
						sideType = 0;
					}
				}
			}
			
			return object;
		}
		
		public static function findUnit(sID:uint, id:uint):*
		{
			var i:int = App.map.mSort.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mSort.getChildAt(i);
				if (unit is Unit && unit.sid == sID  && unit.id == id)
				{
					return unit;
				}
			}
			
			return null;
		}
		
		public static function findUnits(sIDs:Array):Array
		{
			if (!App.map) return new Array();
			var result:Array = [];
			var i:int = App.map.mSort.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mSort.getChildAt(i);
				if (unit is Bitmap || unit is Shape || unit is Sector || unit is Monster)
					continue;
				var index:int = sIDs.indexOf(unit.sid);
				if (index != -1)
				{
					result.push(unit);
				}
			}
			
			return result;
		}
		
		public static function findUnitsByType(types:Array):Array
		{
			var result:Array = [];
			var i:int = App.map.mSort.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mSort.getChildAt(i);
				if (!unit.hasOwnProperty('type')) continue;
				var index:int = types.indexOf(unit.type);
				if (index != -1)
				{
					result.push(unit);
				}
			}
			
			return result;
		}
		
		public static function findUnitsByTypeinLand(types:Array):Array
		{
			var result:Array = [];
			var i:int = App.map.mLand.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mLand.getChildAt(i);
				var index:int = types.indexOf(unit.type);
				if (index != -1)
				{
					result.push(unit);
				}
			}
			
			return result;
		}
		
		public static function findFieldUnits(sIDs:Array):Array
		{
			if (!App.map) return new Array();
			var result:Array = [];
			var i:int = App.map.mField.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mField.getChildAt(i);
				var index:int = sIDs.indexOf(unit.sid);
				if (index != -1)
				{
					result.push(unit);
				}
			}
			
			return result;
		}
	}
}