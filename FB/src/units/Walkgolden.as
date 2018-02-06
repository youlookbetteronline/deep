package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Load;
	import core.MD5;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.utils.clearTimeout;
	import flash.utils.describeType;
	import flash.utils.setTimeout;
	import ui.Hints;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import ui.UserInterface;
	import ui.CloudsMenu;
	import utils.UnitsHelper;
	import wins.SpeedWindow;
	import wins.ValentineWindow;
	
	public class Walkgolden extends WorkerUnit
	{
		public static const JOHNY:uint = 717;
		public static const HORSE:uint = 1140;
		public static const OUKOON:uint = 2161;
		
		public static var isMove:Boolean = false;
		
		public var crafted:uint = 0;
		public var started:int = 0;
		public var crafting:Boolean;
		public var fID:int = 0;
		public var shady:int = 0;
		public var _cloud:CloudsMenu;
		public var _showCloud:Boolean;
		public var capacity:int = 0;
		public var walkable:Boolean;
		public var hasProduct:Boolean;
		public var shadowScale:Number = .75;
		public var smartShadow:Bitmap = new Bitmap();
		//public var coordsCloud:Object = new Object();
		
		protected var _helperLock:Boolean;
		protected var _lock:Boolean;
		protected var wasClick:Boolean;
		
		private var _tribute:Boolean;
		private var isMoveThis:Boolean;
		private var timerSay:int = 1;
		private var intervalMove:int;
		private var homeTimeout:uint;
		private var iconTimeout:uint;
		
		private function get timeOver():Boolean{
			if (info.hasOwnProperty('lifetime') && info.lifetime != 0 && started + info.lifetime < App.time  )
				return true;
			else
				return false;
		}
		public function set lock (item:Boolean):void
		{
			_lock = item;
			if (_cloud && _lock){
				_cloud.dispose();
				_cloud = null;
			}
			
			if (item)
				removable = false;
			else
				removable = true;
				
		}
		public function get lock():Boolean 
		{
			return _lock;
		}		
		public function set helperLock (item:Boolean):void
		{
			_helperLock = item;
			
			if (_cloud && _helperLock)
			{
				_cloud.dispose();
				_cloud = null;
			}
			
			if (item)
				removable = false;
			else
				removable = true;
				
		}
		public function get helperLock():Boolean{
			return _helperLock;
		}
		override public function set move(move:Boolean):void{
			super.move = move;
			
			if (move)
			{
				stopWalking();
				framesType = STOP;
			}	
			
			if (!move && isMoveThis)
				previousPlace();
		}
		
		override public function set touch(touch:Boolean):void{
			if (App.user.mode == User.GUEST)
				return;
			
			super.touch = touch;
		}
		
		public function get tribute():Boolean{
			return _tribute
		}
		public function set tribute(value:Boolean):void{
			_tribute = value;
			
			if (_cloud)_cloud.dispose();
				_cloud = null;
			
			if (_tribute && hasProduct)
			{
				cloudResource(true, Stock.COINS, isProduct);				
			}else
			{
				if (_cloud)_cloud.dispose();
				_cloud = null;
			}
		}
		
		public function Walkgolden(object:Object) 
		{
			level = 0;
			crafted = object.crafted || 0;
			
			crafting = true;
			
			if (object.capacity)
				capacity = object.capacity;
			
			if (object.started)
				started = object.started;
			
			if (!object.hasOwnProperty('started'))
				started = App.time;
			
			if (object.hasOwnProperty('level'))
				level = object.level;

			super(object);
			multiple = true;
			moveable = true;
			stockable = true;
			
			tip = function():Object 
			{				
				var subText:String = Locale.__e('flash:1491831964108', [info.capacity - capacity]);//Осталось сборов награды : %d
				
				if (!info.capacity || info.capacity == 0)
					subText = '';
				if (lock){
					return {
						title:info.title,
						text:Locale.__e("flash:1394010372134") //Занят
					};
				}
				var timerTime:int = crafted - App.time;
				
				if (sid == JOHNY)
				{
					return {
						title:info.title,
						text:info.description
					};
				}
				
				if (sid == 1140)
				{
					return {
						title:info.title,
						text:info.description
					};
				}
				
				if (timeOver)
				{
					return {
						title:info.title
					};
					
				}
				
				if (info.hasOwnProperty('lifetime') && info.lifetime != 0 && App.time < started + info.lifetime && _tribute)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379966")+'\n'+Locale.__e("flash:1491818748419"),//Нажми, чтобы забрать бонус //Иссякнет через:
						timerText: TimeConverter.timeToDays(started + info.lifetime - App.time),
						timer:true
					};
				}
				
				if (info.hasOwnProperty('lifetime') && info.lifetime != 0 && App.time < started + info.lifetime)
				{
					return {
						title:info.title,
						text: info.description + '\n' + '\n' + Locale.__e("flash:1382952379839") + '\n' + subText,//До выдачи бонуса осталось: 
						timerText: TimeConverter.timeToStr(timerTime),
						timerText2: Locale.__e("flash:1491818748419") + ' ' + TimeConverter.timeToDays(started + info.lifetime - App.time),
						timer:true
					};
				}
				
				if (info.capacity != 0 && capacity >= info.capacity)
				{
					return {
						title:info.title,
						text: Locale.__e("flash:1491817499163")//Декор иссяк
					};
				}
				
				if (_tribute || timerTime <= 0)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379966") + '\n' + subText//Нажми, чтобы забрать бонус
					};
				}
				
				
				return {
					title:info.title,
					text: info.description + '\n' + '\n' + Locale.__e("flash:1382952379839") + '\n' + subText,//До выдачи бонуса осталось: 
					timerText: TimeConverter.timeToStr(timerTime),
					timer:true
				};
			}
			
			shortcutDistance = 50;
			homeRadius = 20;
			
			beginCraft(0, crafted);
			
			if (formed && Map.ready)
			{
				if (snails.indexOf(this.sid) != -1)
				{
					homeTimeout = setTimeout(goHome, 10000);
				}else
				{
					goHome();
				}
			}
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
				
			if (object.sid == JOHNY) 
			{
				stockable = false;
				removable = false;
			}
		}
		
		override public function generateStopCount():uint
		{
			return int(Math.random() * 2) + 1;;
		}
		
		override public function generateRestCount():uint 
		{
			return 1;
		}
		
		override public function load():void
		{
			if (preloader) 
				addChild(preloader);
			if (this.sid == JOHNY)
			{
				info.view = 'johny'
			}
			if(App.user.mode == User.GUEST){
				var hash:String = MD5.encrypt(Config.getSwf(info.type, info.view));
				if ((Load.cache[hash] != undefined && Load.cache[hash].status == 3) || !open) {
					Load.loading(Config.getSwf(info.type, info.view), onLoad);
				}else{
					if(SystemPanel.noload)
						clearBmaps = true;
					Load.loading(Config.getSwf(info.type, info.view), onLoad);
					//onLoad(UnitsHelper.walkTexture);
				}
			}else
				Load.loading(Config.getSwf(info.type, info.view), onLoad);
		}
		
		override public function onLoad(data:*):void 
		{
			if (this.sid == JOHNY && this.id > 4 && App.user.mode == User.OWNER) 
			{
				this.applyRemove = false;
				removable = true;
				remove();
			}
			super.onLoad(data);
			textures = data;
			getRestAnimations();
			addAnimation();
			createShadow();
			
			if (preloader)
			{
				TweenLite.to(preloader, 0.5, { alpha:0, onComplete:removePreloader });
			}
			if (clearBmaps)
			{
				Load.clearCache(Config.getSwf(info.type, info.view));
				data = null;
			}
		}
		
		override public function setRest():void 
		{
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			
			framesType = randomRest;
			startSound(randomRest);
			saySomethingFilter();
			
			if (sid == OUKOON)
				restCount = 1;
			else
				restCount--;
				
			if (restCount <= 0){
				stopCount = (1 + Math.random() * 2);
				loopFunctionn = beforeGoHome;
			}else
				loopFunctionn = setRest;
		}
		
		override public function beforeGoHome():void
		{
			if (sid == OUKOON){
				if (framesType != Personage.EMERGE)
				{
					framesType = Personage.EMERGE;
				}
			}else{
				if (framesType != Personage.STOP)
				{
					framesType = Personage.STOP;
				}
			}
			
			stopCount--;
			if (stopCount <= 0){
				loopFunctionn = goHome;
			}else
				loopFunctionn = beforeGoHome;
		}
		
		override public function saySomething(bgColor:uint = 0xfffef4, borderColor:uint = 0x47216b, word:String = ''):void
		{
			clearTimeout(dialogTimeout);
			if (App.user.quests.tutorial)
				return;
			super.saySomething(bgColor, borderColor, word);
			timerSay = setTimeout(this.showIcon, 2500);
		}
		
		override public function onDown():void 
		{
		}
		
		
		private function onMapComplete(e:AppEvent):void
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			if (formed)
			{
				homeTimeout = setTimeout(goHome, 3000);
			}
		}
		
		override public function goHome(_movePoint:Object = null):void
		{
			if (!this.open)
				return;
			
			if (App.user.quests.tutorial)
				return;
				
			if (App.user.mode == User.GUEST && App.owner && App.owner.id == '1' && this.sid == JOHNY)
				return;
			
			if (info.moveable == 1)	super.goHome(_movePoint);
			
		}
		override public function onGoHomeComplete():void 
		{
			stopCount = generateStopCount();
			if (sid == OUKOON)
				stopCount = 1;
			stopRest();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}		
			
			this.cell = coords.x
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			this.id = data.id;	
			started = App.time;
			
			open = true;
			crafted = App.time;
			created = App.time;
			hasProduct = true;
			crafting = false;
			showIcon();			
			beginCraft(0, created);			
			tribute = false;
			hasProduct = false;
			goHome();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{			
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			if (data.started)
				started = created = data.started
			else
				started = created = App.time;
			
			this.cell = coords.x; 
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			open = true;
			if (data.crafted)
				crafted = data.crafted
			else 
				crafted = App.time
			if (data.crafted > App.time)
				hasProduct = false;
			if (data.crafted > App.time)
				crafting = true;
			showIcon();			
			beginCraft(0, crafted);			
			moveable = true;
			touchable = true;
			tribute = false;			
			goHome();
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
				return;
			}	
			
			this.cell = coords.x;
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			goHome();
			
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false
		}
		
		override public function take():void
		{
			if (!takeable)
				return;
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			var water:AStarNodeVO;
			
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var waters:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			for (var i:uint = 0; i < cells; i++)
			{
				for (var j:uint = 0; j < rows; j++)
				{
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					
					nodes.push(node);
					if (layer == Map.LAYER_FIELD || layer == Map.LAYER_LAND)
						node.isWall = false;
					
					if (i > 0 && i < cells - 1 && j > 0 && j < rows - 1)
					{
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						
						part.isWall = true;
						part.b = 1;
						part.object = this;
						if (layer == Map.LAYER_FIELD || layer == Map.LAYER_LAND)
							part.isWall = false;
						
						if (info.base != null && info.base == 1)
						{
							if (App.map._aStarWaterNodes != null)
							{
								water = App.map._aStarWaterNodes[coords.x + i][coords.z + j];
								waters.push(water);
								water.isWall = true;
								water.b = 1;
								water.object = this;
							}
						}
					}
				}
			}
			
			if (layer == Map.LAYER_SORT)
			{
				App.map._astar.take(nodes);
				App.map._astarReserve.take(parts);
			}
			
			if (info.base != null && info.base == 1)
			{
				if (App.map._astarWater != null)
					App.map._astarWater.take(waters);
			}
		}
		
		
		override public function click():Boolean 
		{
		
			clearTimeout(intervalMove);
			var node:AStarNodeVO = App.map._aStarNodes[coords.x ][coords.z];
			if (!node.open || timeOver)
				return false;
				
			if (App.data.storage[sid].time == 999)
				return false;
			if (sid == OUKOON)
			{
				frame = textures.animation.animations[_framesType].chain.length-1;
				stopCount = 1;
				loopFunctionn = beforeGoHome;
			}
			if (lock)
				return false;
				
			if (info.hasOwnProperty('capacity') && info.capacity != 0 && capacity >= info.capacity)
				return false;
				
			if (isMoveThis)
			{
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false
				return true;
			}
			
			if (App.user.mode == User.GUEST)
			{
				return true;
			}
			if (!tribute)
				return false;
			if (isProduct()) return true;
			
			return true;
		}
		
		override public function createShadow():void
		{
			if (shadow) 
			{
				removeChild(shadow);
				shadow = null;
			}
			
			if (textures){
				textures.animation.shadow = {
					x:0,
					y:10,
					alpha:0.59,
					scaleX:1,
					scaleY:1
				};
			}
			if (sid == 1513)
			{
				textures.animation.shadow.scaleX = 3;
				textures.animation.shadow.scaleY = 3;
				textures.animation.shadow.x = -20;
				textures.animation.shadow.y = -3;
			}
			
			shadow = new Bitmap(UserInterface.textures.shadow);
			addChildAt(shadow, 0);
			shadow.smoothing = true;
			shadow.x = textures.animation.shadow.x - (shadow.width / 2);
			shadow.y = textures.animation.shadow.y - (shadow.height / 2);
			shadow.alpha = 0.3;
			shadow.scaleX = textures.animation.shadow.scaleX * .7;
			shadow.scaleY = textures.animation.shadow.scaleY * .7;
			
			if (App.data.storage[sid].base == 1 && sid != JOHNY)
			{
				//fly = true;
				//var shadBitmap:BitmapData = textures.animation.animations.walk.frames[0][0].bmd.clone();
				//var invertTransform:ColorTransform = new ColorTransform(0, 0, 0, 1, 0, 0, 0, 1);
				//shadBitmap.colorTransform(shadBitmap.rect, invertTransform);
				
				var matrix:Array = new Array();
				matrix = matrix.concat([0, 0, 0, 0, 0]); // red
				matrix = matrix.concat([0, 0, 0, 0, 0]); // green
				matrix = matrix.concat([0, 0, 0, 0, 0]); // blue
				matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
				var _filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
				
				//shadow.bitmapData = shadBitmap;
				shadow.filters = [new BlurFilter(20, 20, BitmapFilterQuality.LOW), _filter];
				shadow.scaleX = shadow.scaleY = shadowScale;
				shadow.x = shadow.x - (shadow.width / 2);
				shadow.y = shadow.y - (shadow.height / 2);
				shady = shadow.y;
				
				if (textures)
				{
					ax = textures.animation.ax;
					ay = textures.animation.ay - 100;// позиция битмапки персонажа над тенью
				}
			}
		}
		
		public function isReadyToWork():Boolean
		{
			if (crafted > App.time)
			{
				new SpeedWindow( {
					title:info.title,
					target:this,
					priceSpeed:info.speedup,
					info:info,
					finishTime:crafted,
					totalTime:App.data.storage[sid].time,
					doBoost:onBoostEvent,
					btmdIconType:App.data.storage[sid].type,
					btmdIcon:App.data.storage[sid].preview
				}).show();
				return false;				
			}
			return true;
		}
		
		public function onBoostEvent(count:int = 0):void
		{			
			if (App.user.stock.take(Stock.FANT, count))
			{				
				started = App.time - info.time;
				crafted = App.time - info.time;
				
				var that:Walkgolden = this;
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) {
						started = data.started;
						App.ui.flashGlowing(that);
					}					
				});
			}
		}
		
		public function beginCraft(fID:uint, crafted:uint):void
		{
			this.fID = fID;
			this.crafted = crafted;
			hasProduct = false;
			crafting = true;			
			App.self.setOffTimer(work);
			App.self.setOnTimer(work);
		}
		
		public function work():void
		{
			if (App.time >= crafted)
			{
				App.self.setOffTimer(work);
				tribute = true;
				onProductionComplete();
			}
		}
		
		public function onProductionComplete():void
		{
			hasProduct = true;
			crafting = false;
			crafted = 0;
			showIcon();
		}
		
		override public function initCoordsCloud():void 
		{				
			if (cloudPositions.hasOwnProperty(App.data.storage[sid].view) ) 
			{
				coordsCloud.x = cloudPositions[App.data.storage[sid].view].x;
				coordsCloud.y = cloudPositions[App.data.storage[sid].view].y;
			}else{
				if (App.data.storage[sid].hasOwnProperty('cloudoffset') && 
				(App.data.storage[sid]['cloudoffset'].dx != 0 || App.data.storage[sid]['cloudoffset'].dy != 0))
				{
					coordsCloud.x = App.data.storage[sid]['cloudoffset'].dx;
					coordsCloud.y = App.data.storage[sid]['cloudoffset'].dy;
				}else{
					coordsCloud.x = 0;
					coordsCloud.y = -50;
				}
			}
		}
		
		public function showIcon():void
		{
			initCoordsCloud();
			
			if ((info.hasOwnProperty('capacity') && info.capacity != 0 && capacity >= info.capacity) || timeOver)
			{
				clearIcon();
				return;
			}
			
			if (App.data.storage[sid].time == 999 && this.sid != JOHNY)
				return;
				
			if (App.user.mode == User.OWNER)
			{
				if (hasProduct) 
				{
					if (this.sid == JOHNY && App.user.mode == User.OWNER) 
					{
						return;
						drawIcon(UnitIcon.VALENTINE, 1, 1, {
							glow: true,
							iconDX: 0,
							iconDY: 0
						}, 0, coordsCloud.x, coordsCloud.y);
						return;
					}
					
					var _view:int = Stock.COINS;
					if(info.hasOwnProperty('shake') && info.shake!="")
						for (var shake:* in App.data.treasures[info.shake][info.shake].item)
							if (Treasures.onlySystemMaterials(info.shake))
							{
								if (App.data.treasures[info.shake][info.shake].probability[shake] == 100)
									_view = App.data.treasures[info.shake][info.shake].item[shake]
							}
							else if (App.data.storage[App.data.treasures[info.shake][info.shake].item[shake]].mtype != 3 &&
								App.data.treasures[info.shake][info.shake].probability[shake] == 100){	
									_view = App.data.treasures[info.shake][info.shake].item[shake];
									break;
							}		
							
					drawIcon(UnitIcon.REWARD, _view, 1, {
						glow:		true
					}, 0, coordsCloud.x, coordsCloud.y);
				}else {
					clearIcon();
				}
			}
		}
		
		public function getPrice():Object
		{
			var price:Object = { }
			price[Stock.FANTASY] = 0;
			return price;
		}
		
		public function isProduct(value:int = 0):Boolean
		{
			if (hasProduct)
			{
				var price:Object = getPrice();
				
				if (!App.user.stock.checkAll(price))	return true;
				
				storageEvent();				
				ordered = false;				
				return true; 
			}
			return false;
		}
		
		public function storageEvent(value:int = 0):void
		{
			if (App.user.mode == User.OWNER) {
				var act:String = 'storage';
				
				if (App.isSocial('AI', 'YB', 'MX'))
				{
					act = 'storage2'
				}
				
				Post.send({
					ctr:this.type,
					act:act,
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onStorageEvent);
			}
			
			tribute = false;
		}
		
		public function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			ordered = false;
			crafted = App.time + App.data.storage[sid].time;
			
			if (data.hasOwnProperty('started'))
			{
				App.self.setOnTimer(work);
			}
			
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			
			tribute = false;
			hasProduct = false;
			
			clearIcon();
			
			if (info.hasOwnProperty('capacity') && info.capacity > 0)
			{
				capacity++;
			}
		}
		
		public function cloudResource(flag:Boolean, sid:int, callBack:Function, btm:String = 'productBacking2', scaleIcon:*=null, isStartProgress:Boolean = false, start:int = 0, end:int = 0, offIcon:Boolean = false):void
		{
			if (_cloud)
				_cloud.dispose();
			
			_cloud = null;
			
			if (lock)
				return;
			if (App.user.mode == User.GUEST)
				return;
			
			if (flag)
			{
				_showCloud = true;
				_cloud = new CloudsMenu(callBack, this, sid, {offIcon:offIcon, scaleIcon:scaleIcon } );// , tint:isTint } );
				_cloud.create(btm, false);	
				_cloud.show();
				
				setCloudCoords();
				
				if (rotate) 
				{
					_cloud.scaleX = -_cloud.scaleX;
					setCloudCoords();
				}
			}
			
			if(isStartProgress)_cloud.setProgress(start, end);
		}
		
		public function setCloudCoords():void      
		{
			if (cloudPositions.hasOwnProperty(info.view))
			{
				_cloud.y = cloudPositions[info.view].y;
				if (rotate) _cloud.x = cloudPositions[info.view].x + 70;
				else _cloud.x = cloudPositions[info.view].x;
			}
		}
		
		override public function update(e:* = null):void 
		{
			super.update(e);
			/*if (framesDirection == FACE)
			{
				if (shadow.scaleY < 0)
				{
					//shadow.scaleY = Math.abs(shadow.scaleY);
					shadow.y = shady - (shadow.height / 2);
				}
			}
			if (framesDirection == BACK)
			{
				if (shadow.scaleY > 0)
				{
					//shadow.scaleY = shadow.scaleY * -1;
					shadow.y = shady - (shadow.height / 2);
				}
			}		
			if (framesFlip == RIGHT)
			{
				if (shadow.scaleX > 0)
				{
					shadow.scaleX = shadow.scaleX * -1;
					shadow.x = shadow.x + shadow.width;
				}
			}
			if (framesFlip == LEFT)
			{
				if (shadow.scaleX < 0)
				{
					shadow.scaleX = Math.abs(shadow.scaleX); 
					shadow.x = shadow.x - shadow.width;
				}
			}*/
		}
		
		override public function previousPlace():void
		{
			super.previousPlace();
		}
		
		override public function free():void 
		{
			super.free();
		}
		
		override public function uninstall():void 
		{
			loopFunctionn = null;
			clearTimeout(homeTimeout);
			clearTimeout(dialogTimeout);
			clearTimeout(timerSay);
			App.self.setOffEnterFrame(update);
			App.self.setOffTimer(work);
			tm.owner = null;
			clearIcon();
			icon = null;
			super.uninstall();
		}
	}
}