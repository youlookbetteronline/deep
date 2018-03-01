package units 
{
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.UnitIcon;
	import wins.ConstructWindow;
	//import wins.ElfWindow;
	import wins.Window;
	import wins.YetiWindow;
	
	public class Fatman extends Building 
	{
		
		public const EATING_TIME:uint = 0;
		
		public var float:WaterFloat;
		
		public var inited:Boolean = false;
		private var lastLevel:int = 0;
		public var timeTo:int = 0;
		public var timeCurr:int = 0;
		public var totalTime:int = 0;
		public var eatingTime:int = 0;
		public var _mode:String;
		public var itemsObject:Object = new Object();
		
		public var food:Object;
		public var serverTime:int = 0;
		
		public function Fatman(object:Object)
		{
			crafted = object['fintime'] || 0;
			super(object);
			
			if (!Config.admin) removable = false;
			
			lastLevel = level;
			totalTime = info.time;
			food = object['food'] || null;
			serverTime = object.time;
			crafting = true;
			removable = true;
			itemsObject = object.items || null;
			createContent();
			
			if (formed)
			{
				checkState();
			}
			if (crafted > 0 && crafted > App.time)
				App.self.setOnTimer(timer);
			tip = tips;
		}
		
		public function checkState():void {	
			if (level >= totalLevels) 
			{
				if(!food || !food.sID) {
					updateData();
				}else {
					init();
				}
			}
		}
		public var contentArr:Array = new Array();
		public function createContent():void 
		{
			if (level >= totalLevels) 
			{
				contentArr = new Array();
				/*for each(var itm:* in info.barters)
				{
					info
					for (var needItm:* in itemsObject)
					{
						if (itemsObject[needItm] == itm.bart.sid)
						{
							itm['key'] = needItm;
							contentArr.push(itm);
							break;
						}
					}
				}*/
				for (var needItm:* in itemsObject)
				{
					
					if (itemsObject[needItm] == info.barters[needItm].bart.sid)
					{
						info.barters[needItm]['key'] = needItm;
						contentArr.push(info.barters[needItm]);
						
					}
				}
			}
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			checkState();
			createContent();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			checkState();
			createContent();
		}
		
		public function updateData():void {
			
			/*Post.send( {
				id:		id,
				uID:	App.user.id,
				sID:	sid,
				wID:	App.user.worldID,
				act:	'start',
				ctr:	'Fatman'
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.food) {
					parseData(data);*/
					init();
				/*}
			}, {});*/
		}
		/*public function parseData(data:Object = null):void 
		{
			if (!data) data = {food:food};
			
			food = data.food;
			//serverTime = data.food.time;
		}*/
		
		/*override public function upgraded():void {
			
			updateProgress(upgradedTime - info.devel.req[level+1].t, upgradedTime);
			if (isUpgrade()){
				App.self.setOffTimer(upgraded);
				
				if (App.user.mode == User.OWNER) {
					//showIcon();
				}
				
				if (!hasUpgraded) {
					//instance = 1;
					created = App.time + info.devel.req[1].t;
					App.self.setOnTimer(build);
					addProgressBar();
					addEffect(Building.BUILD);
					checkTechnoNeed();
				} else {
					hasUpgraded = true;
					hasPresent = true;
					
					this.level++;
					finishUpgrade();
					updateLevel();
					fireTechno(1);
					removeProgress();
					checkState();
				}
			}
		}*/
		
		override public function click():Boolean {
			
			if (App.user.mode == User.GUEST) return true;
			
			if (!buildFinished) {
				openConstructWindow();
			} else {
				
				if (crafted != 0 && crafted > App.time)
				{
					mode = YetiWindow.GONE;
					//return true;
				}else{
					if (crafted == 0)
						mode = YetiWindow.WAIT;
					else{
						//showIcon();
						storageEvent();
						return true;
					}
				}
					new YetiWindow( {
						title:			info.title,
						info:			info.description,
						target:			this,
						totalTime:		info.time,
						state:			mode,
						content:		contentArr,
						food:			info.foods //(mode == YetiWindow.WAIT) ? food : null
					}).show();
				//}
			}
			
			if (Events.timeOfComplete < App.time && sid == 2680) return true;
			
			//if (mode && mode != YetiWindow.EAT && level >= totalLevels) {
				
				// Эльф
				/*if (sid == 2333 || sid == 2680) {
					new ElfWindow({
						target:		this
					}).show();
				}else{
					new YetiWindow( {
						title:			info.title,
						info:			info.description,
						target:			this,
						totalTime:		info.time * 3600,
						state:			mode,
						food:			(mode == YetiWindow.WAIT) ? food : null
					}).show();
				}*/
			//}else if (level < totalLevels) {
			//	super.click();
			//}
			
			return true;
		}
		override public function showIcon():void 
		{
			
			if (needQuest != 0 && !App.user.quests.data.hasOwnProperty(needQuest) && App.user.mode == User.OWNER)
				return;
			
			if (!formed || !open) 
				return;
				
			if (cloudPositions.hasOwnProperty(App.data.storage[sid].view) ) 
			{
				coordsCloud.x = cloudPositions[App.data.storage[sid].view].x;
				coordsCloud.y = cloudPositions[App.data.storage[sid].view].y;
			}else{
				if (App.data.storage[sid].hasOwnProperty('cloudoffset') && (App.data.storage[sid]['cloudoffset'].dx != 0 || App.data.storage[sid]['cloudoffset'].dy != 0))
				{
					coordsCloud.x = App.data.storage[sid]['cloudoffset'].dx;
					coordsCloud.y = App.data.storage[sid]['cloudoffset'].dy;
				}else{
					coordsCloud.x = 0;
					coordsCloud.y = -20;
				}
			}
			
			if (App.user.mode == User.OWNER) 
			{
				var matID:int = 459;
				if(this.sid != 1135)
				{
					//var _mid:int;
					var _treasure:* = App.data.treasures[Numbers.firstProp(info.barters).val.bonus][Numbers.firstProp(info.barters).val.bonus];
					for (var _mID:* in _treasure.item)
					{
						if (App.data.storage[_treasure.item[_mID]].type == 'Material' &&
						App.data.storage[_treasure.item[_mID]].mtype != 3 && 
						_treasure.probability[_mID])
						{
							matID = _treasure.item[_mID];
							break;
						}
					}
					/*Load.loading(Config.getIcon(App.data.storage[_mid].type, App.data.storage[_mid].preview), function(data:Bitmap):void {
						boxReward.bitmapData = data.bitmapData;
						boxReward.smoothing = true;
						boxReward.x = (settings.width - boxReward.width) / 2;
						boxReward.y = back.y + (back.height - boxReward.height) / 2;
					});*/
				}
				if (crafted > 0 && crafted <= App.time /*&& hasProduct && formula*/) {
					drawIcon(UnitIcon.BUILDING_REWARD, matID, 1, {
						glow:		true,
						iconScale: .64
					}, 0, coordsCloud.x, coordsCloud.y - 85);
				}
				else if (crafted > 0 && crafted >= App.time && formula) 
				{
					drawIcon(UnitIcon.PRODUCTION, formula.out, 1, {
						progressBegin:	crafted - formula.time,
						progressEnd:	crafted,
						iconScale: .64
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else if (hasPresent) 
				{
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		true,
						iconScale: .64
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else if (hasBuilded && upgradedTime > 0 && upgradedTime > App.time && level < totalLevels) 
				{
					drawIcon(UnitIcon.BUILDING, null, 0, {
						level: level,
						totalLevels: totalLevels,
						clickable:		false,
						boostPrice:		info.instance.devel[1].req[level + 1].f,
						progressBegin:	upgradedTime - info.instance.devel[1].req[level + 1].l,
						progressEnd:	upgradedTime,
						onBoost:		function():void {
							accelerateEvent(info.devel.skip[level + 1]);
						}
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1)) 
				{
					drawIcon(UnitIcon.BUILD, null, 0, {
						level: level,
						totalLevels: totalLevels
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else 
				{
					//removeGlow();
					clearIcon();
				}
			}
			else if (App.user.mode == User.GUEST) 
			{
				if (level >= totalLevels && this.type != 'Bridge')
				{
					drawIcon(UnitIcon.REWARD, Stock.COINS, 1, {
						glow:		false,
						iconScale: .64
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else
					clearIcon();
			}
			checkGlowing();
		}
		
		override public function openConstructWindow(popup:Boolean = false):Boolean 
		{	
			//super.openConstructWindow(popup);			
			//return true;
			
			if (level < totalLevels - craftLevels /*|| level == 0*/)
			{
				if (App.user.mode == User.OWNER)
				{
					/*if (hasUpgraded)
					{*/	
						//level++;
						new ConstructWindow( {
							title:			info.title,
							request:		info.instance.devel[1].obj[level + 1], 
							upgTime:		info.instance.devel[1].req[level + 1].t,
							reward:			info.instance.devel[1].rew[level + 1],
							target:			this,
							popup:			popup,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true,
							find:helpTarget
						}).show();
						//level--;
						helpTarget = 0;
						return true;
					//}
				}
			}
			return false;
		}
		private var timeoutFloat:uint = 1;
		private var emergeDown:Boolean = false;
		public function timer():void 
		{
			/*if (eatingTime > 0) {
				eatingTime--;
				if (eatingTime <= 0) init();
			}*/
			
			timeCurr = crafted - App.time;
			if (timeCurr < 0) 
			{
				timeCurr = 0;
				emergeDown = true;
				init();
				if (float)
				{
					timeoutFloat = setTimeout(function():void{showIcon();}, WaterFloat.floatTimeout*1000)
				}else
					showIcon();
				App.self.setOffTimer(timer);
			}
		}
		
		override public function updateLevel(checkRotatable:Boolean = true):void 
		{
			super.updateLevel(checkRotatable);
			if (level >= totalLevels) {
				initAnimation();
				beginAnimation();
			}
		}
		
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void  {
			super.onUpgradeEvent(error, data, params);
			level = data.level;
			if (level >= totalLevels) 
			{
				//serverTime = App.time;
				itemsObject = data.items;
				createContent();
				init();
				//setTimeout(updateData, 500);
			}
		}
		
		override public function storageEvent():void
		{
			hasProduct = false;
			
			var sendObject:Object = {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}
			
			Post.send(sendObject, onStorageEvent);
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				/*Errors.show(error, data);*/
				return;
			}
			if (data.hasOwnProperty('bonus')) 
			{
				var that:* = this;
				Treasures.bonus(data.bonus, new Point(that.x, that.y));
			}
			
			itemsObject = data.items;
			createContent();
			clearIcon();
			
			ordered = false;
			hasProduct = false;
			//queue = [];
			crafted = 0;
			//init();
		}
		
		public function init(setMode:String = null):void 
		{
			/*if (!yeti && !inited) {
				App.self.setOnTimer(timer);
				createYeti();
			}*/
			
			/*if (setMode == YetiWindow.EAT) 
			{
				mode = YetiWindow.GONE;
			//	mode = YetiWindow.EAT;
			//	eatingTime = EATING_TIME;
				return;
			}*/
			
			
			if (buildFinished)
			{
				if (crafted != 0 && crafted > App.time)
				{
					mode = YetiWindow.GONE;
					if (float)
						float.emerge()
				}else{
					if (crafted == 0 || crafted <= App.time)
					{
						mode = YetiWindow.WAIT;
						inited = true;
						createFloat(emergeDown);
						return;
					}
				}
			}
			/*var window:* = Window.isClass(YetiWindow);
			if (window && window.target.id == id) window.close();
			
			var attitude:Number = (App.time - serverTime) / totalTime;
			if (attitude == Infinity) attitude = 0;
			
			if (attitude >= 2) {
				attitude = attitude % 2;
				serverTime += (App.time - serverTime) - (App.time - serverTime) % (totalTime * 2);
				if (App.user.mode == User.GUEST) {
					//trace(food);
				}else if (attitude < 1 && (!food.time || (food.time && food.time < App.time - totalTime * 2))) updateData();
			}
			if (attitude < 1) {
				mode = YetiWindow.WAIT;
			}else if (attitude < 2) {
				mode = YetiWindow.GONE;
			}
			
			if (serverTime == 0) serverTime = App.time;
			timeTo = App.time + totalTime - (App.time - serverTime) % totalTime;
			
			inited = true;*/
		}
		
		private function createFloat(emrDown:Boolean = false):void 
		{
			if (sid != 1135)
			{
				return;
			}
			//this.unit = new TableFish( { id:this.id, sid:fish,  baseX:_loc_2.x+5, baseZ:_loc_2.z+5 } );
			if (this.sid != 1135)
				return;
			float = new WaterFloat( {
				id		:0,
				sid		:WaterFloat.FLOAT,
				target	:this,
				x		:coords.x, 
				z		:coords.z
			});
			if (emrDown)
			{
				float.emergeDown();
			}
			//addChild(float);
		}
		public function set mode(value:String):void {
			_mode = value;
			setYetiAnimation();
		}
		public function get mode():String {
			return _mode;
		}
		public function setYetiAnimation():void {
			if (textures) {
				if (mode == YetiWindow.GONE/* || Building.ALWAYS_ANIMATED*/) {
					startAnimation();
				}else {
					if(Building.ALWAYS_ANIMATED.indexOf(this.sid) == -1)
						stopAnimation();
				}
				//draw(levelData.bmp, levelData.dx, levelData.dy);
			}
		}
		override public function onMoveAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				
				free();
				_move = false;
				placing(prevCoords.x, prevCoords.y, prevCoords.z);
				take();
				state = DEFAULT;
				
				//TODO мен¤ем координаты на старые
				return;
			}
		
			App.map._astar.reload();
			App.map._astarReserve.reload();
			if (float)
			{
				float.x = this.x;
				float.y = this.y;
			}
		}
		
		override public function uninstall():void 
		{
			App.self.setOffTimer(timer);
			
			//yeti.dispose();
			
			super.uninstall();
		}
		
		//public function flight(item:Sprite, )
	}

}