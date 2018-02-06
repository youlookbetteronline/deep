package units 
{
	import astar.AStarNodeVO;
	import core.IsoConvert;
	import core.Load;
	import core.MD5;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import units.table.TableEvent;
	import units.table.TableSlot;
	import utils.UnitsHelper;
	import wins.PestWindow;
	import wins.SimpleWindow;
	import wins.TableWindow;
	import wins.Window;
	import wins.WindowEvent;

	public class Table extends AUnit
	{	
		private var _acceptedMaterials:Vector.<int>;
		private var clickableTable:Boolean = true;
		private var _slots:Vector.<TableSlot>;
		private var _tableWindow:TableWindow;
		private var _isFull:Boolean;
		private var slotBonus:Array = [];
		private var _settings:Object;
		private var _currentWorldID:int;
		private var _bitmap:Bitmap;
		private var bonus:Boolean = false;
		private var randCoords:int = 0;
		
		public var _fastestFinish:int;
		public var canShow:Boolean = false;
		public var canClick:Boolean = true;
		public var fishGivesThisShit:int;
		public var fish:int;
		public var level:uint = 1;
		public var totalLevels:uint = 1;
		
		public var unit:TableFish;
		public var pest:Pest;
		public static var locX:*;
		public static var locY:*;
		
		private static var _hasShownHelp:Boolean = false;
		
		public function get acceptedMaterials():Vector.<int> 
		{
			return _acceptedMaterials;
		}
		
		public function get slots():Vector.<TableSlot> 
		{
			return _slots;
		}
		
		public function get tableWindow():TableWindow 
		{
			return _tableWindow;
		}
		
		public function get isFull():Boolean 
		{
			return _isFull;
		}
		
		public function set isFull(value:Boolean):void 
		{
			if (_isFull == value)
			{
				return;
			}
			
			_isFull = value;
			
			if (_isFull)
			{
				drawFullState();
			}
			else
			{
				drawEmptyState();
			}
		}		
		
		static public function get hasShownHelp():Boolean 
		{
			return _hasShownHelp;
		}		
		
		public function Table(object:Object) 
		{	
			if (!_hasShownHelp)
			{
				_hasShownHelp = Boolean(App.user.storageRead("hasShownTableHelp", ""));
			}
			
			layer = Map.LAYER_SORT;
			_settings = object;
			
			super(object);
			
			if (object.hasOwnProperty('finished') && object.finished) 
			{
				if (Numbers.firstProp(object.finished).val != 0 && Numbers.firstProp(object.finished).val < App.time) 
				{
					canShow = true;
				}
			}
			
			if (object.hasOwnProperty('finished') && object.finished) 
			{
				if (Numbers.firstProp(object.finished).val > App.time) 
				{
					slotBonus[0] = false;
				}
			}
			
			if (object.hasOwnProperty('pcount') && object.pcount == 0) 
			{
				addPest(info.pest.sid);
			}
			
			touchableInGuest = false;
			
			load();			
			initAcceptedMaterials();
			initSlots();
			
			App.self.setOnTimer(timerUpdate);
			
			if (App.user.mode == User.OWNER)
			{
				_currentWorldID = App.user.worldID;
			}
			
			locX = this.x;
			locY = this.y;
			
			tip = tips;
			timerUpdate();
		}
		
		private function tips():Object
		{
			if (_fastestFinish > App.time && App.user.mode == User.OWNER)
			{
				return {
					title:info.title,
					text:Locale.__e("flash:1464610391959"),
					timerText: TimeConverter.timeToStr(_fastestFinish - App.time),
					timer:true
				}
			}
			else if (_fastestFinish > 0 && _fastestFinish < App.time && App.user.mode == User.OWNER)
			{
				return {
					title:info.title,
					text:Locale.__e("flash:1464610457921"),
					timer:true
				}
			}
			else 
			{
				return {
					title:info.title,
					text:info.description
				}
			}
		}
		
		public function load():void 
		{	
			if (App.user.mode == User.GUEST)
			{
				var hash:String = MD5.encrypt(Config.getSwf(type, info.view));
				if ((Load.cache[hash] != undefined && Load.cache[hash].status == 3) || !open) {
					Load.loading(Config.getSwf(type, info.view), onLoad);
				}else{
					if(SystemPanel.noload)
						clearBmaps = true;
					Load.loading(Config.getSwf(type, info.view), onLoad);
					//onLoad(UnitsHelper.bTexture);
				}
			}else
				Load.loading(Config.getSwf(type, info.view), onLoad);
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			makeOpen();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			makeOpen();
		}
		
		override public function onLoad(data:*):void 
		{	
			super.onLoad(data);
			if (textures.sprites && textures.sprites[0]["bmp"])
			{
				drawEmptyState();
			}
			
			//if (fromStock || fromShop || (open && formed))
				this.visible = true;
				
			/*if (loader != null) 
			{
				removeChild(loader);
				loader = null;
			}
			
			if (!open && formed) {
				if (bitmap.height > 100) 
					addMask();
					//uninstall();
				this.visible = false;
			}*/
			if(clearBmaps){
				Load.clearCache(Config.getSwf(type, info.view));
				data = null;
			}
		}
		
		private function drawEmptyState():void
		{
			draw(textures.sprites[0]["bmp"], textures.sprites[0]["dx"], textures.sprites[0]["dy"]);
			bitmap.visible = true;
		}
		
		private function drawFullState():void
		{
			if (textures && textures.sprites && textures.sprites[1] && textures.sprites[1]["bmp"])
			{
				draw(textures.sprites[1]["bmp"], textures.sprites[1]["dx"], textures.sprites[1]["dy"]);
				bitmap.visible = true;
			}
		}
		
		override public function click():Boolean 
		{
			if (!canClick) return false;
			
			//bonus = false;
			
			if (!super.click())
				return false;
			
			if (!App.user.mode == User.OWNER)
				return false;
			
			if (!clickableTable)
			{
				new PestWindow({
					text: 		Locale.__e('flash:1478019034297'),
					height:		250,
					buttonText: Locale.__e('flash:1382952380298'),
					hasExit: 	false
					
				}).show();
				return false;
			}
			
			for (var i:int = 0; i < slotBonus.length; i++) 
			{
				if (slotBonus[i] == true && bonus == false)
				{
					bonus = true;
					storageBonus(i + 1);
					return true;
				}
			}	
			
			if (bonus == false)
			{
				openTableWindow();
			}
			return true;
		}
		
		public function openTableWindow():void
		{
			if (_tableWindow != null)
				return;
			
			_tableWindow = new TableWindow( { target:this } );
			_tableWindow.addEventListener(WindowEvent.ON_AFTER_CLOSE, onWindowClose);
			_tableWindow.show();
		}
		
		private function onWindowClose(e:WindowEvent):void 
		{
			_tableWindow.removeEventListener(WindowEvent.ON_AFTER_CLOSE, onWindowClose);
			_tableWindow = null;
		}		
		
		private function initAcceptedMaterials():void
		{
			if (!_acceptedMaterials)
				_acceptedMaterials = new Vector.<int>();
			
			if (info["in"])
			{
				for (var matID:* in info["in"]) 
				{
					_acceptedMaterials.push(matID);
				}
			}
		}		
		
		private function initSlots():void
		{
			if (!_slots)
				_slots = new Vector.<TableSlot>();
			
			var slotsInfo:Object = info.slots;				
			var currentSlot:TableSlot;
			
			for (var key:String in slotsInfo.c)
			{
				currentSlot = new TableSlot(slotsInfo.c[key], slotsInfo.k[key], slotsInfo.p[key], slotsInfo.t[key]);
				
				if (currentSlot.openPrice == 0)
				{
					currentSlot.isOpen = true;
				}
				
				if (_settings.slots && _settings.slots[key])
				{
					currentSlot.isOpen = true;
					for (var materialKey:String in _settings.slots[key])
					{
						currentSlot.currentMaterial = int(materialKey);
						currentSlot.count = _settings.slots[key][materialKey];
						break;
					}
				}
				
				if (_settings.finished && _settings.finished[key])
				{
					currentSlot.finished = _settings.finished[key];					
				}
				
				_slots.push(currentSlot);
			}
		}		
		
		private function timerUpdate():void
		{
			var currentSlot:TableSlot;
			var numSlots:int = _slots.length;			
			var hasFullSlots:Boolean = false;
			
			_fastestFinish = 0;
			
			for (var i:int = 0; i < numSlots; i++) 
			{
				//i = this.id;
				currentSlot = _slots[i];
				
				if (currentSlot.finished > 0 && (_fastestFinish <= 0 || (currentSlot.finished < _fastestFinish)))
				{
					_fastestFinish = currentSlot.finished;
				}
				
				if (currentSlot.finished > 0 && currentSlot.finished > App.time)
				{
					hasFullSlots = true;
				}
				
				if (currentSlot.finished > 0 && currentSlot.finished <= App.time && slotBonus[i] == false)
				{
					slotBonus[i] = true;
					
					dispatchEvent(new TableEvent(TableEvent.BECAME_READY, currentSlot.currentMaterial, currentSlot.count, i + 1));
					fishArrival(currentSlot);
					canClick = false;
					return;
				}else if (!currentSlot.currentMaterial && !currentSlot.count) 
				{
					isFull = false;
					slotBonus[i] = false;
				}else 
				{
					if (currentSlot.finished > 0 && currentSlot.finished <= App.time && currentSlot.currentMaterial && canShow) 
					{
						whatFishGives(currentSlot);	
						slotBonus[i] = true;
						canShow = false;
						
						drawIcon(UnitIcon.REWARD, fishGivesThisShit, 0, null, 0, 40,-50);
						canClick = true;
						dispatchEvent(new TableEvent(TableEvent.BECAME_READY, currentSlot.currentMaterial, currentSlot.count, i + 1));
					}
				}
				
				if (unit && unit.gives)
				{
					clickableTable = true;
					canShow = true;
					unit.gives = false;
				}
				
				if (pest && pest.alive == true)
				{
					clickableTable = false;
				}else{
					clickableTable = true;
				}
			}
			
			isFull = hasFullSlots;
		}
		
		public function fishArrival(currentSlot:TableSlot):void 	
		{			
			whatFishGives(currentSlot);			
			clickableTable = false;
			
			Window.closeAll();
			
			var _loc_2:* = IsoConvert.screenToIso(this.x, this.y, true);
			var place:Object = findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:coords.x, z:coords.z}}, 20);
			
			this.unit = new TableFish( { id:this.id, sid:fish, x:place.x, z:place.z, baseX:_loc_2.x+5, baseZ:_loc_2.z+5 } );
			//unit.goHome();
			clickableTable = false;
		}
		
		public function whatFishGives(slot:TableSlot):void 
		{
			if (slot.currentMaterial == 0) return;
			
			var table:Object = this;
			var innerObhect:Object = App.data.storage[table.sid]["in"];
			
			for (var k:* in innerObhect) 
			{
				if (k == slot.currentMaterial) 
				{
					fish = innerObhect[k];
				}
			}
			
			fishGivesThisShit = App.data.treasures[App.data.storage[fish].treasure][App.data.storage[fish].treasure].item[0];
		}
		
		/*public static function set givs(value:uint):void
		{
			unit.gives = value;
		}
		
		public static function fishDeparture():void 	
		{
			givs = true;
		}*/
		
		public function openSlot(slotID:int):void
		{
			var postObject:Object = { };
			
			postObject["ctr"] = this.type;
			postObject["act"] = "open";
			postObject["sID"] = this.sid;
			postObject["uID"] = App.user.id;
			postObject["id"] = this.id;
			postObject["wID"] = App.user.worldID;
			postObject["slot"] = slotID;
			
			Post.send(postObject, onSlotOpened, {slotID:slotID});
		}
		
		private function onSlotOpened(error:int, data:Object, params:Object):void
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			
			if (params.slotID)
			{
				var currentSlot:TableSlot = _slots[params.slotID - 1];
				
				currentSlot.isOpen = true;
				dispatchEvent(new TableEvent(TableEvent.OPENED_SLOT, 0, 0, params.slotID));
				
				App.user.stock.take(Stock.FANT, currentSlot.openPrice);
			}
		}
		
		public function setMaterialToSlot(mID:int, count:int, slotID:int):void
		{	
			var postObject:Object = { };
			
			postObject["ctr"] = this.type;
			postObject["act"] = "set";
			postObject["sID"] = this.sid;
			postObject["uID"] = App.user.id;
			postObject["id"] = this.id;
			postObject["wID"] = App.user.worldID;
			postObject["mID"] = mID;
			postObject["count"] = count;
			postObject["slot"] = slotID;
			
			Post.send(postObject, onSetMaterialToSlot, {mID:mID, count:count, slotID:slotID});
		}
		
		private function onSetMaterialToSlot(error:int, data:Object, params:Object):void
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			
			if (data.slots)
			{
				for (var key:String in data.slots)
				{
					for (var mKey:String in data.slots[key])
					{
						_slots[int(key) - 1].currentMaterial = int(mKey);
						_slots[int(key) - 1].count = int(data.slots[key][mKey]);
					}
				}
			}
			
			if (data.finished)
			{
				for (var fKey:String in data.finished)
				{
					_slots[int(fKey) - 1].finished = int(data.finished[fKey]);
				}
			}			
			
			if (params && params.mID && params.count && params.slotID)
			{
				dispatchEvent(new TableEvent(TableEvent.SET_ITEMS, params.mID, params.count, params.slotID));
				App.user.stock.take(params.mID, params.count);
			}			
			
			if (data.hasOwnProperty('pcount') && data.pcount == 0) 
			{
				addPest(info.pest.sid)
			}
		}
		
		
		public function addPest(pestSid:int):void
		{
			Window.closeAll();
			
			var _pestSid:int = pestSid;			
			var place:Object = findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:coords.x, z:coords.z}}, 5, true);
			
			pest = new Pest( { id:999999, sid:_pestSid, x:place.x, z:place.z, gift:false, buildingType:info.type, buildingSid:info.sID, buildingID:id } );
			//pest.buyAction();
			App.map.focusedOn(pest, false);
			
			pest.showGlowing(0xf61717);
		}
		
		public function storageBonus(slotID:int):void
		{
			var postObject:Object = { };
			
			postObject["ctr"] = this.type;
			postObject["act"] = "storage";
			postObject["sID"] = this.sid;
			postObject["uID"] = App.user.id;
			postObject["id"] = this.id;
			postObject["wID"] = App.user.worldID;
			postObject["slot"] = slotID;
			
			Post.send(postObject, onBonusStored, {slotID:slotID});
		}
		
		private function onBonusStored(error:int, data:Object, params:Object):void
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			
			var currentSlot:TableSlot;
			
			bonus = false;
			if (params.slotID)
			{
				currentSlot = _slots[params.slotID - 1];
				var event:TableEvent = new TableEvent(TableEvent.TAKEN_REWARD, currentSlot.currentMaterial, currentSlot.count, params.slotID);
				var currentMaterial:Object = App.data.storage[currentSlot.currentMaterial];
				
				if (data.bonus)
				{
					Treasures.bonus(data.bonus, new Point(this.x, this.y));
				}
				
				currentSlot.finished = 0;
				currentSlot.currentMaterial = 0;
				currentSlot.count = 0;				
				dispatchEvent(event);
				
				timerUpdate();				
			}
			clearIcon();
		}
		
		override public function set x(value:Number):void 
		{
			super.x = value;
			updateIconPosition();
		}
		
		override public function set y(value:Number):void 
		{
			super.y = value;
			updateIconPosition();
		}	
		
		private function updateIconPosition():void 
		{
			if (icon)
			{
				icon.x = this.x;
				icon.y = this.y;
			}
		}
		
		override public function calcState(node:AStarNodeVO):int 
		{
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (App.data.storage[sid].base == 1) {
						//trace(node.b, node.open, node.object);
						if ((node.b != 0 || node.open == false || node.object != null) && node.w != 1) {
							return OCCUPIED;
						}
						if (node.w != 1 || node.open == false || node.object != null) {
							return OCCUPIED;
						}
					} else {
						if (node.b != 0 || node.open == false || (node.object != null /*&& (node.object is Stall)*/)) {
							return OCCUPIED;
						}
					}
				}
			}
			return EMPTY;
		}
		
		override public function uninstall():void 
		{
			App.self.setOffTimer(timerUpdate);
			
			if (App.user.mode == User.OWNER)
			{
				var key:String = this.type + "_" + _currentWorldID;
				
				var tableData:Object = { };	
				var tableInfo:Object = { };
				
				tableInfo["sid"] = sid;
				tableInfo["id"] = id;
				
				tableData["info"] = tableInfo;
				
				var tableSlots:Object = { };
				for (var i:int = 0; i < _slots.length; i++) 
				{
					tableSlots[i + 1] = _slots[i].finished;
				}
				
				tableData["slots"] = tableSlots;
				App.user.storageStore(key, tableData, true);
			}			
			super.uninstall();
		}
	}
}