package units {
	
	import astar.AStarNodeVO;
	import buttons.Button;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.utils.clearTimeout;
	//import camera.MapMask;
	import com.greensock.TweenLite;
	import core.Post;
	import core.TimeConverter;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	import ui.UnitIcon;
	import wins.JamWindow;
	import wins.QuestsChaptersWindow;
	import wins.petWindow.PetFeedWindow;
	import wins.SimpleWindow;
	
	public class Pet extends WorkerUnit 
	{
		public static const DOG:int = 1731;
		public static const RADIUS_POSITION:int = 5;
		
		private static const WAIT:String = 'stop_pause';
		
		private static const ANIMATION_HAPPY:String = "happy";
		private static const ANIMATION_SAD:String = "sad";
		private static const ANIMATION_EAT:String = "eat";
		
		private static var _petFoods:Array;
		
		public static function get petFoods():Array 
		{
			return _petFoods;
		}
		
		public function get finished():int 
		{
			return _finished;
		}
		public function set finished(value:int):void 
		{
			_finished = value;
		}
		
		private var bonusTimeout:uint = 2;
		private var specialCount:int;
		private var _finished:int;
		private var depth_animal:int;
		//private var shady:int;
		private var hideTimeout:uint = 1;
		private var shadowBitmap:Bitmap;
		//private var coordsCloud:Object = new Object();
		
		private var _bountiesLeft:uint;
		private var _settings:Object;
		
		private var _lastFood:Object;
		private var _animateFeeding:Boolean;
		private var _onFeedComplete:Function;
		private var _foodID:int;
		private var _foodsForPet:Array;
		
		private var _bonusCount:int = 0;
		private var _materialID:int = 0;
		private var _resourceID:int = 0;
		
		public function Pet(object:Object = null) 
		{
			object['x'] = App.map.heroPosition.x + 2;
			object['z'] = App.map.heroPosition.z + 2;
			super(object);
			_settings = object;
			stockable = false;
			_bonusCount = int(_settings.count);
			_materialID = int(_settings.mID);
			_resourceID = int(_settings.rID);
			
			init();
			tips();
		}
		
		private function init():void
		{
			cells = 0;
			rows = 0;
			App.map._aStarNodes[coords.x][coords.z].object = null;
			
			velocities = [0.15, 0.75];
			velocity = 0.15;
			_bountiesLeft = _settings.feed;
			flyeble = true;
			
			//var _position:Object = Map.findNearestFreePosition({x:App.user.hero.coords.x + 4, z:App.user.hero.coords.z + 3});
			//placing(_position.x,0,_position.z);
			//moveable = (_settings.fromShop || _settings.fromStock);
			//removable = false;
			//touchableInGuest = false;
			//framesType = WAIT;
			
			if (!_settings.fromStock && !_settings.fromShop)
			{
				initWithHero();
			}
			
			initPetfoods();
			makeOpen();
			checkVisible();
		}
		public function checkVisible():void
		{
			//var questsVerify:Boolean = (App.user.mode == User.GUEST || !QuestsRulesVerify.instance.checkVerify(String(sid), "visible"));
			//var mapVerify:Boolean = MapMask.instance.isMapMask;
			visible = isActive;
		}
		private function get isActive ():Boolean
		{
			//var questsVerify:Boolean = (!QuestsRulesVerify.instance.checkVerify(String(sid), "visible"));
			//var mapVerify:Boolean = MapMask.instance.isMapMask;
			return !(/*questsVerify || mapVerify ||*/ App.user.mode == User.GUEST);
		}
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			initWithHero();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			initWithHero();
		}
		
		private function initWithHero():void
		{
			if (App.user.hero == null)
			{
				App.self.addEventListener(AppEvent.ON_GAME_COMPLETE, onGameComplete);
				return;
			}
			
			//if (!App.user.quests.tutorial && App.user.hero && App.user.mode == User.OWNER) 
			//{
			assignPetToUser();
			//}
		}
		
		private function initPetfoods():void
		{
			_petFoods = [];
			var currentItem:Object;
			for (var key:String in App.data.storage)
			{
				currentItem = App.data.storage[key];
				if (currentItem.type == "Petfood")
				{
					if (currentItem.pets.indexOf(sid) >= 0)
					{
						_petFoods.push(int(key));
					}
				}
			}
			
			for (var key1:int = 0; key1 < _petFoods.length; key1++ )
			{
				for (var key2:int = 0; key2 < _petFoods.length; key2++ )
				{
					if ( App.data.storage[_petFoods[key1]].order < App.data.storage[_petFoods[key2]].order)
					{
						var templ:int = _petFoods[key1];
						_petFoods[key1] = _petFoods[key2];
						_petFoods[key2] = templ;
					}
				}
			}
		}
		
		private function onPetReleased(e:AppEvent):void 
		{
			//App.self.removeEventListener(AppEvent.PET_RELEASED, onPetReleased);
			//assignPetToUser();
		}
		
		private function assignPetToUser():void
		{
			this.visible = true;
			App.user.pet = this;
			//placing(App.user.hero.cell + 2, 0, App.user.hero.row + 2);
			updateStatusIcon();
			
			App.self.addEventListener(AppEvent.USER_FINISHED_JOB, onUserFinishedJob);
			App.self.addEventListener(AppEvent.USER_FINISED_HARVEST, onUserFinisedHarvest);
		}
		
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> 
		{
			shortcutDistance = 20;
			return super.findPath(start, finish, _astar);
		}
		
		override public function initMove(cell:int, row:int, _onPathComplete:Function = null):void 
		{
			if (finished > App.time)
				return;
			
			super.initMove(cell, row, _onPathComplete);
		}
		
		private function onUserFinisedHarvest(e:AppEvent):void 
		{
			storageFromField();
		}
		
		
		private function onUserFinishedJob(e:AppEvent):void 
		{
			storageFromPetEvent(e.params.count,e.params.rid);
		}
		
		protected function onGameComplete(e:AppEvent):void 
		{
			//super.onGameComplete(e);
			
			App.self.removeEventListener(AppEvent.ON_GAME_COMPLETE, onGameComplete);
			initWithHero();
		}
		
		override public function get name():String 
		{
			return "Pet";
		}
		
		override public function set name(value:String):void
		{
			super.name = value;
		}
		
		override public function take():void {}
		override public function free():void {}
		
		public function findCollection():void
		{
			//if (_bountiesLeft <= 0)
				//return;
			//framesType = 'dig';
			//framesDirection = WUnit.BACK;
			//_position = true;
			//setTimeout(SoundsManager.instance.playSFX, 0, 'bark');
			//setTimeout(SoundsManager.instance.playSFX, 600, 'bark');
			//setTimeout(SoundsManager.instance.playSFX, 4100, 'bark');
			//setTimeout(SoundsManager.instance.playSFX, 4700, 'bark');
			//setTimeout(function():void {
				//framesType = Personage.STOP;
			//},5000);
		}
		
		override public function stockAction(params:Object = null):void 
		{
			super.stockAction(params);
			moveable = false;
			
			if (App.user.pet)
				App.user.pet.putAction();
			
			App.user.pet = this;
		}
		
		override public function buyAction(setts:*=null):void
		{
			super.buyAction(setts);
			moveable = false;
			
			if (App.user.pet)
				App.user.pet.putAction();
			
			App.user.pet = this;
		}
		
		override public function walking():void 
		{
			if (path && pathCounter < path.length) 
			{
				if (_framesType != "walk")
				{
					framesType = "walk";
				}
			}
			else 
			{
				framesType = "stop_pause";
			}
			
			super.walking();	
			
			//updateStatusIcon();
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			drawShadow();
		}
		
		
		protected function drawShadow():void
		{
			shadowBitmap = new Bitmap();
			var shadBitmap:BitmapData = textures.animation.animations.walk.frames[0][0].bmd.clone();
			var invertTransform:ColorTransform = new ColorTransform(0, 0, 0, 1, 0, 0, 0, 1);
			shadBitmap.colorTransform(shadBitmap.rect, invertTransform);
			shadowBitmap.bitmapData = shadBitmap;
			shadowBitmap.filters = [new BlurFilter(15, 15, 1)];
			shadowBitmap.x = shadowBitmap.x - (shadowBitmap.width / 2);
			shadowBitmap.y = shadowBitmap.y - (shadowBitmap.height / 2);
			
			depth_animal = 70;
			//createShadow();
		}
		
		override public function beforeGoHome():void
		{
			if (framesType != Personage.STOP)
			{
				framesType = Personage.STOP;
			}
			stopCount--;
			if (stopCount <= 0){
				loopFunctionn = goArround;
			}else
				loopFunctionn = beforeGoHome;
		}
		
		override public function addAnimation():void
		{
			super.addAnimation();
			calculateShadow();
		}
		
		public function calculateShadow():void
		{
			
			if (textures)
			{
				ax = textures.animation.ax;
				ay = textures.animation.ay - depth_animal;
			}
		}
		
		override public function createShadow():void 
		{
			drawShadow();
			if (shadow)
			{
				removeChild(shadow);
				shadow = null;
			}
			
			calculateShadow();
			if (textures /*&& textures.animation.hasOwnProperty('shadow')*/) 
			{
				shadow = shadowBitmap;
				addChildAt(shadow, 0);
				shadow.smoothing = true;
				shadow.x = shadowBitmap.x;
				shadow.y = shadowBitmap.y;
				shadow.alpha = 0.3/*textures.animation.shadow.alpha*/;
				shadow.scaleX = /*textures.animation.shadow.scaleX **/ .7;
				shadow.scaleY = /*textures.animation.shadow.scaleY **/ .7;
				shady = shadow.y;
			}
		}
		
		public function setSpecialAnim():void 
		{
			specialCount--;
			if (specialCount <= 0){
				stopCount = (1 + Math.random() * 1);
				loopFunctionn = beforeGoHome;
			}else
				loopFunctionn = setSpecialAnim;
		}
		
		override public function setRest():void 
		{
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			
			framesType = randomRest;
			startSound(randomRest);
			
			restCount--;
			if (restCount <= 0){
				stopCount = (1+Math.random() * 1);// generateStopCount();
				loopFunctionn = beforeGoHome;
			}else
				loopFunctionn = setRest;
		}
		
		public function goArround(_movePoint:Object = null):void 
		{
			var place:Object = findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:cell, z:row}}, 4);
			framesType = Personage.WALK;
			initMove(place.x, place.z, onStop);
		}
		
		override public function goHome(_movePoint:Object = null):void 
		{
			//super.goHome(_movePoint);
		}
		
		override public function set framesType(value:String):void 
		{			
			super.framesType = value;
		}
		override public function click():Boolean 
		{
			if (ordered)
				return false;
			if (!touchableInGuest && App.user.mode == User.GUEST)
				return false;
				
			var foodOnStock:Boolean = false;
			if (bountiesLeft == 0)
			{
				var foods:Array = foodsForPet();
				
				for (var i:int = 0; i < foods.length; i++) 
				{
					if (App.user.stock.count(foods[i].sID) > 0)
					{						
						feed(foods[i].sID);
						ordered = true;
						foodOnStock = true;
						break;
						//return true;
					}
				}
				if (!foodOnStock)
					openFeedWindow();
			}
			else
			{
				openFeedWindow();
			}
				
			return true;
		}
		
		private function onIconClick(e:MouseEvent):void 
		{
			if (ordered)
				return;
			
			icon.removeEventListener(MouseEvent.CLICK, onIconClick);
			//click();
		}
		
		private function onMapClick(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_CLICK, onMapClick);
			hideHungryIcon();
		}
		
		public function openFeedWindow(flag:Boolean = false):void
		{
			var windowSettings:Object = { 
				onFeedAction	:feed,
				petID			:this.sid,
				buyBttnCaption	:"Buy",
				glowFeedItems	:flag
			};
			
			if (App.user.pet)
			{
				new PetFeedWindow(this, windowSettings).show();
				//new JamWindow(windowSettings).show();
			}
		}
		
		public function foodsForPet():Array
		{
			if (!_foodsForPet)
			{
				_foodsForPet = [];
			
				for each (var foodItem:Object in App.data.storage) 
				{
					if (foodItem.pets && foodItem.pets.indexOf(sid) >= 0)
					{
						_foodsForPet.push(foodItem);
					}
				}
				_foodsForPet.sortOn("count", Array.NUMERIC);
			}
			
			return _foodsForPet;
		}
		
		override public function uninstall():void 
		{
			App.user.pet = null;
			App.self.removeEventListener(AppEvent.USER_FINISHED_JOB, onUserFinishedJob);
			App.self.removeEventListener(AppEvent.USER_FINISED_HARVEST, onUserFinisedHarvest);
			if (icon)
				icon.removeEventListener(MouseEvent.CLICK, onIconClick);
			App.self.removeEventListener(AppEvent.ON_MAP_CLICK, onMapClick);
			App.self.removeEventListener(AppEvent.ON_GAME_COMPLETE, onGameComplete);
			clearTimeout(hideTimeout);
			clearTimeout(bonusTimeout);
			super.uninstall();
		}
		
		
		public function feed(foodID:int, animate:Boolean = true, onComplete:Function = null):void
		{
			//if (!App.user.stock.take(foodID,1))
				//return;
			var foodItem:Object = App.data.storage[foodID];
			_lastFood = foodItem;
			
			_animateFeeding = animate;
			_onFeedComplete = onComplete;
						
			var objectToSend:Object = {
				ctr:this.type,
				act:"feed",
				uID:App.user.id,
				sID:sid,
				id:id,
				wID:App.user.worldID,
				fID:foodID
			};
			Post.send(objectToSend, feedCallback);
			
			ordered = true;
		}
		
		private function feedCallback(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (_lastFood.count)
				_bountiesLeft += _lastFood.count;
			
			App.user.stock.take(_lastFood.ID, 1);
			framesType = ANIMATION_EAT;
			specialCount = 1;
			setSpecialAnim();
			
			updateStatusIcon();
			
			if (_animateFeeding)
				showFeedReaction();
			
			ordered = false;
			
			if (_onFeedComplete != null && _onFeedComplete is Function)
			{
				_onFeedComplete.call();
			}
		}
		
		public function storageFromField(fieldSID:int = 0):void
		{
			//if (!QuestsRulesVerify.instance.checkVerify(String(sid), "storage"))
			if (!isActive)
				return;
			if (_bountiesLeft > 0)
			{
				var objectToSend:Object = {
					ctr:this.type,
					act:"storage", 
					uID:App.user.id,
					sID:sid,
					id:id,
					wID:App.user.worldID
				};
				
				if (fieldSID)
					objectToSend.tID = fieldSID;
				else
					return;
				
				Post.send(objectToSend, onStoragefromFieldEvent);
			}
			else
			{
				framesType = ANIMATION_SAD;
				specialCount = 1;
				setSpecialAnim();
				updateStatusIcon();
			}
		}
		
		private function onStoragefromFieldEvent(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (data.bonus)
			{				
				dropBonus(data.bonus);
			}
			updateStatusIcon();
		}
		
		public function storageFromPetEvent(count:int,rid:int):void 
		{
			if (!isActive)
				return;
				
			if (App.user.mode == User.GUEST || !App.user.stock.check(Numbers.firstProp(App.data.storage[rid].require).key, Numbers.firstProp(App.data.storage[rid].require).val))
				return;
			if (_bountiesLeft < count)
				count = _bountiesLeft; 
			if (_bountiesLeft >= 1)
			{
				var objectToSend:Object = {
					ctr		:this.type,
					act		:"storage", 
					uID		:App.user.id,
					sID		:sid,
					id		:id,
					count	:count,
					wID		:App.user.worldID,
					rID		:rid
				};
				_bountiesLeft -= count;
				if (_bountiesLeft < 0)
					_bountiesLeft = 0;
				Post.send(objectToSend, onStorageEvent);
			}
			else
			{
				framesType = ANIMATION_SAD;
				specialCount = 1;
				setSpecialAnim();
				
				updateStatusIcon();
			}
		}
		
		public function onStorageEvent(error:int, data:Object, params:Object):void 
		{			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (data.bonus)
			{
				
				for (var ins:String in data.bonus)
				{
					if (App.data.storage[ins].type == 'Material' && App.data.storage[ins].collection)
					{
						findCollection();
						break;
					}
				}
				if (App.user.quests.tutorial) 
				{
					bonusTimeout = setTimeout(function():void {
						dropBonus(data.bonus);
					}, 1500);
				}
				else
				{
					dropBonus(data.bonus);
				}
			}
			
			framesType = ANIMATION_HAPPY;
			specialCount = 1;
			setSpecialAnim();
			
			updateStatusIcon();
		}
		
		private function dropBonus(bonusObj:Object):void
		{
			Treasures.bonus(bonusObj, new Point(this.x, this.y));
		}
		
		
		private function showFeedReaction():void
		{			
			var foodItem:BonusItem = new BonusItem(getFoodID(), 1, true, { target:{x:this.x - App.map.x, y:this.y - App.map.y}, sIDs:[getFoodID()] } );
			
			var stockButton:Button = App.ui.bottomPanel.bttnMainStock;
			var rect:Rectangle = stockButton.getBounds(App.map.mIcon);
			
			var startPoint:Point = new Point();
			
			startPoint.x = rect.x + (rect.width * 0.5);
			startPoint.y = rect.y + (rect.height * 0.5);
			
			foodItem.cashMove(startPoint, App.map.mIcon);
		}
		
		private function showHungryIcon(autohide:Boolean = true):void
		{
			if (!icon)
				return;
				
			TweenLite.to(icon, 0.3, { alpha:1 } );
			
			if (autohide)
				hideTimeout = setTimeout(hideHungryIcon, 2900);
				
			icon.mouseEnabled = true;
			icon.mouseChildren = true;
		}
		
		private function hideHungryIcon():void
		{
			if (!icon)
				return;
				
			TweenLite.to(icon, 0.3, { alpha:0, onComplete:onIconHidden } );
		}
		
		private function onIconHidden():void
		{
			if (!icon)
				return;
				
			icon.mouseEnabled = false;
			icon.mouseChildren = false;
		}
		
		private function updateStatusIcon():void
		{
			if (cloudPositions.hasOwnProperty(App.data.storage[sid].view) ) 
			{
				coordsCloud.x = cloudPositions[App.data.storage[sid].view].x;
				coordsCloud.y = cloudPositions[App.data.storage[sid].view].y;
			}else{
				coordsCloud.x = 0;
				coordsCloud.y = -50;
			}
			
			if (finished < App.time && _bonusCount > 0)
			{
				var mID:int = App.data.storage[_resourceID].out;
				drawIcon(UnitIcon.REWARD, mID);
			}
			else if (_bountiesLeft == 0 && !icon)
			{				
				var haveInStock:int;
				var foodSIDs:Array = foodsForPet()
				
				for (var i:int = 0; i < foodSIDs.length; i++) 
				{
					haveInStock += App.user.stock.count(foodSIDs[i].ID);
				}
				
				drawIcon(UnitIcon.HUNGRY, getFoodID(), haveInStock, { iconScale:0.6, iconDY: -5 }, 0, coordsCloud.x, coordsCloud.y );
				hideTimeout = setTimeout(hideHungryIcon, 2000);
			}
			else if (_bountiesLeft == 0 && icon)
			{
				showHungryIcon();
			}
			else if(_bountiesLeft > 0)
			{
				clearIcon();
			}
			
			getFoodID();
		}
		
		
		private function getFoodID():int
		{
			if (!_foodID)
			{
				switch(sid)
				{
					case 1731:
						_foodID = 1750;
						break;
				}
			}
			return _foodID;
		}
		
		public function get bountiesLeft():uint 
		{
			return _bountiesLeft;
		}
		
		public function tips():void 
		{
			tip = function():Object 
			{
				var result:Object = {
					title: info.title,
					text: info.description
					
				}
				return result;
			};
		}
		
		
		override public function set visible(value:Boolean):void 
		{
			super.visible = value;
			if (icon)
				icon.visible = value;
		}
		
		override public function set state(value:uint):void 
		{
			if (state == value)
				return;
			
			super.state = value;
			
			if (bountiesLeft > 0)
				return;
			
			updateStatusIcon();
			
			if (state == TOCHED && icon)
			{
				showHungryIcon(false);
				icon.mouseEnabled = true;
				icon.mouseChildren = true;
				icon.addEventListener(MouseEvent.CLICK, onIconClick);
				App.self.addEventListener(AppEvent.ON_MAP_CLICK, onMapClick);
			}
		}
		
		
		override public function putAction():void 
		{
			if (_bountiesLeft > 0)
			{
				var msgWindow:SimpleWindow = new SimpleWindow({text:Locale.__e("flash:1447167158326")});
				msgWindow.show();
				return;
			}
			
			var bonusItem:BonusItem = new BonusItem(sid, 1, false);
			bonusItem.x = this.x;
			bonusItem.y = this.y;
			App.map.mTreasure.addChild(bonusItem);
			bonusItem.cash();
			
			super.putAction();
		}
		
		public static function getPositionForPet(initX:int, initZ:int):Point {
			var resultPoint:Point;
			var initNode:AStarNodeVO = App.map._aStarNodes[initX][initZ];
			var node:AStarNodeVO;
			
			var openPositions:Vector.<Point> = new Vector.<Point>();
			
			for (var posX:int = initX - Pet.RADIUS_POSITION; posX <= initX + Pet.RADIUS_POSITION; posX += 1) {
				for (var posZ:int = initZ - Pet.RADIUS_POSITION; posZ <= initZ + Pet.RADIUS_POSITION; posZ += 1) {
					if (posX == initX && posZ == initZ) {
						continue;
					}
					
					var newX:int = posX;
					var newZ:int = posZ;
					
					if (newX < 0) newX = 0;
					if (newZ < 0) newZ = 0;
					if (newX > Map.cells - 1) newX = Map.cells - 1;
					if (newZ > Map.rows - 1) newZ = Map.rows - 1;
					
					node = App.map._aStarNodes[newX][newZ];
					if (initNode.open && !initNode.isWall && node.open && !node.isWall) {
						openPositions.push(new Point(newX, newZ));
					}
				}
			}
			
			if (openPositions.length > 0) {
				resultPoint = openPositions[int(Math.random() * openPositions.length)];
			}
			
			if (!resultPoint) {
				resultPoint = new Point(App.user.pet.coords.x, App.user.pet.coords.z);
			}
			return resultPoint;
		}
	}
}