package units 
{
	import astar.AStarNodeVO;
	import core.IsoConvert;
	import core.Load;
	import core.MD5;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.system.System;
	import flash.utils.describeType;
	import ui.Cloud;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import utils.UnitsHelper;
	import wins.EaselSpeedWindow;
	import wins.SimpleWindow;
	import wins.SpeedWindow;
	import wins.Window;

	public class Golden extends Tribute
	{
		private var died:Boolean = false;
		public var capacity:int = 0;
		public function Golden(object:Object) 
		{
			crafted = object.crafted || 0;
			//object['started'] = crafted - App.data.storage[object.sid].time;
			crafted = App.time + 0;
			super(object);
			started = object['started'];// = App.time + 0;
			if (object.hasOwnProperty('died'))
				died = Boolean(object.died);
			if (object.capacity)
				capacity = object.capacity;
			crafting = true;
			info.config
			totalLevels = level;
			stockable = true;
			if(this.info && this.info.config){
				var unitConfig:Array = String(this.info.config).split('').reverse();
				for (var configID:int = 0; configID < unitConfig.length; configID++ ) {
					if (unitConfig[configID] == "1" && this.hasOwnProperty(App.map.CONFIG_DATA[configID])) {
						this[App.map.CONFIG_DATA[configID]] = false;
					}
				}
			}
			if (formed && textures && crafted > App.time)
				beginAnimation();
			
			if (App.user.mode == User.GUEST) 
			{
				App.self.setOffTimer(work);
				touchable = true;
				clickable = true;
			}
			mouseEnabled = true;
			mouseChildren = true;
			tip = tips;
			/*if (this.sid == 2951)
				drawAvailableArea();*/
			
		}
		
		private function drawAvailableArea():void 
		{
			var point1:Point = new Point(70, 90);
			var point2:Point = new Point(90, 110);
			_availableZone = new Shape();
			App.map.focusedOnPoint(new Point((point1.x + point2.x) / 2,  (point1.y + point2.y) / 2));
			_availableZone.graphics.beginFill(0x2ef229, .3);//0x21f86d
			
			var isoPoint:Object = IsoConvert.isoToScreen(point1.x, point1.y, true);
			_availableZone.graphics.moveTo(isoPoint.x, isoPoint.y);
			
			isoPoint = IsoConvert.isoToScreen(point1.x, point2.y, true);
			_availableZone.graphics.lineTo(isoPoint.x, isoPoint.y);
			
			isoPoint = IsoConvert.isoToScreen(point2.x, point2.y, true);
			_availableZone.graphics.lineTo(isoPoint.x, isoPoint.y);
			
			isoPoint = IsoConvert.isoToScreen(point2.x, point1.y, true);
			_availableZone.graphics.lineTo(isoPoint.x, isoPoint.y);
			
			isoPoint = IsoConvert.isoToScreen(point1.x, point1.y, true);
			_availableZone.graphics.lineTo(isoPoint.x, isoPoint.y);
			_availableZone.graphics.endFill();
			
			App.map.mField.addChildAt(_availableZone,0);
		}
		
		private function clearAvailableZone():void 
		{
			if (_availableZone)
			{
				_availableZone.parent.removeChild(_availableZone)
				_availableZone = null
			}
		}
		
		override protected function tips():Object
		{
			if (tribute || hasProduct){
				if (info.hasOwnProperty('lifetime') && info.lifetime != 0 && App.time < started + info.lifetime)
				{
					//if (App.time < started + info.lifetime){
						return {
							title:info.title,
							text:Locale.__e("flash:1382952379966")+'\n'+Locale.__e("flash:1491818748419"),
							timerText: TimeConverter.timeToDays(started + info.lifetime - App.time),
							timer:true
						};
					//}
					//else{
						//return {
							//title:info.title,
							//text:Locale.__e("flash:1382952379966")
						//};
					//}
				}
				else{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379966")
					};
					
				}
			}
			
			if (level == totalLevels)
			{
				if (App.user.mode == User.OWNER)
				{
					if (info.hasOwnProperty('lifetime') && info.lifetime != 0)
					{
						if (started + info.lifetime < App.time && died)
						{
							return {
								title:info.title,
								text:Locale.__e("flash:1491817499163")
							};
						}else{
							var leftTime:uint = started + info.lifetime - App.time;
							if (App.time > started + info.lifetime)
								leftTime = crafted - App.time
							return {
								title:info.title,
								text:Locale.__e("flash:1382952379839"),
								timerText: TimeConverter.timeToStr(crafted - App.time),
								desc: Locale.__e("flash:1491818748419"),
								timerText2: TimeConverter.timeToDays(leftTime),
								timer:true
							};
						}
						
					}
					else if (info.capacity != 0 && capacity < info.capacity)
					{
						return {
							title:info.title,
							text: Locale.__e('flash:1491831964108', [info.capacity - capacity])
						};
					}
					else if (died)
					{
						return {
							title:info.title,
							text: Locale.__e("flash:1491817499163")//Декор иссяк
						};
					}
					else{
						return {
							title:info.title,
							text:info.description + '\n\n' + Locale.__e("flash:1382952379839"),
							timerText: TimeConverter.timeToStr(crafted - App.time),
							timer:true
						};
					}
				}
				else
				{
					return {
						title:info.title
					};
				}
				
			}
			
			return {
				title:info.title,
				text:Locale.__e("flash:1382952379967")
			};
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			open = true;
			
			crafted = App.time;
			started = App.time;
			
			for (var itemAdded:* in info.tostock)
			{
				App.user.stock.add(itemAdded, info.tostock[itemAdded]);
			}
			
			beginCraft(0, crafted);
			beginAnimation();
			
			//clearAvailableZone();
		}
		
		override public function flip():void
		{
			super.flip();
			clearIcon();
			showIcon();
		}
		
		override protected function beginCraft(fID:uint, crafted:uint):void
		{
			this.fID = fID;
			this.crafted = crafted;
			hasProduct = false;
			crafting = true;
			
			App.self.setOnTimer(work);
		}
		
		private var wasClick:Boolean = false;
		override public function click():Boolean 
		{
			if (died)
				return false;
				
			if (wasClick) 
				return false;
				
			if (App.user.mode == User.GUEST) 
			{
				return false;
			}
			
			if (App.user.useSectors && sid != 3721)
			{
				var node1:AStarNodeVO = App.map._aStarNodes[this.coords.x][this.coords.z];
				
				if (!node1.sector.open)
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1495607052980') + " " + info.title,
						confirm:function():void
						{
							node1.sector.fireNeiborsReses();
						}
					}).show();
					return false;
				}
			}
			
			if (!isReadyToWork()) 
				return true;
			if (isProduct()) 
				return true;
			
			return true;
		}
		
		
		override public function get tribute():Boolean 
		{
			if (level >= totalLevels && hasProduct && (crafted == 0 || (crafted > 0 && crafted <= App.time)) && !died)
				return true;
			
			return false;
		}
		override public function placing(x:uint, y:uint, z:uint):void
		{
			super.placing(x, y, z);
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			//return EMPTY;
			if (info.market == 17)
			{
				for (var n:uint = 0; n < cells; n++) 
				{
					for (var m:uint = 0; m < rows; m++) 
					{
						node = App.map._aStarNodes[coords.x + n][coords.z + m];
						
						if (info.base == 1)
						{
							if (node.w != 1 || node.open == false)
							{
								//if (node.object != null && (node.object is Wall))
									//return EMPTY;
								//else
									return OCCUPIED;
							}
						}
						if (info.base == 0)
						{
							if  ((node.b != 0) || node.open == false || node.object != null) 
							{
								return OCCUPIED;
							}
						}
					}
				}
				
				return EMPTY;
			}
			
			for (var i:uint = 0; i < cells; i++) 
			{
				for (var j:uint = 0; j < rows; j++) 
				{
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (App.data.storage[sid].base == 1) 
					{
						//trace(node.b, node.open, node.object);
						if ((node.b != 0 || node.open == false || node.object != null) && node.w != 1) 
						{
							return OCCUPIED;
						}
						if (node.w != 1 || node.open == false || node.object != null) 
						{
							return OCCUPIED;
						}
					} else {
						if (node.b != 0 || node.open == false || (node.object != null /*&& (node.object is Stall)*/)) 
						{
							return OCCUPIED;
						}
					}
				}
			}
			if (this.sid == 2951)
			{	
				var point1:Point = new Point(70, 90);
				var point2:Point= new Point(90 - this.info.area.w, 110 - this.info.area.h);
				if ((coords.x > point1.x && coords.z > point1.y) && (coords.x < point2.x && coords.z < point2.y))
					return EMPTY;
				else
					return OCCUPIED;
			}
			return EMPTY;
		}
		
		override public function onProductionComplete():void
		{
			hasProduct = true;
			crafting = false;
			crafted = 0;
			showIcon();
			//App.self.dispatchEvent(new AppEvent(AppEvent.ON_REWARD_READY,false,false,{target:this}));
		}
		public function onDie():void
		{
			hasProduct = false;
			crafting = false;
			crafted = 0;
			clearIcon();
		}
		//public var coordsCloud:Object = new Object();
		override public function showIcon():void {
			if (!formed || !open) return;
			
			if (died) return;
			
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
					coordsCloud.y = -30;
				}
			}
			
			if (App.user.mode == User.GUEST && touchableInGuest) {
				
				clearIcon();
			}
			
			if (App.user.mode == User.OWNER) 
			{
				
				if (level >= totalLevels && tribute) 
				{
					var _view:int = Stock.COINS;
					//App.data.storage[sid].view
					if (info.hasOwnProperty('shake') && info.shake != "")
					{
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
					}		
					drawIcon(UnitIcon.REWARD, _view, 1, {
						glow:		true
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1)) 
				{
					drawIcon(UnitIcon.BUILD, null, 0, null, 0, coordsCloud.x, coordsCloud.y);
				}
				else 
				{
					clearIcon();
				}
			}
		}
		
		
		//
		override public function isProduct():Boolean
		{
			if (hasProduct)
			{
				var price:Object = getPrice();
					
				if (!App.user.stock.checkAll(price))	
					return true;  // было false
				
				// Отправляем персонажа на сбор
				storageEvent();
				ordered = false;				
				return true; 
			}
			return false;
		}
		override public function isReadyToWork():Boolean
		{
			if (crafted > App.time) 
			{
				if (info.speedup == "")
					return false;
				if (info.stopboost)
					return true;
				if (sid == 1133 || sid == 1832)
				{
					var imageName:String = '';
					if (sid == 1133) 
					{
						imageName = 'Painting2';
					}
					
					if (sid == 1832) 
					{
						imageName = 'Painting1';
					}
					
					
					
					new EaselSpeedWindow( {
						title			:info.title,
						target			:this,
						info			:info,
						finishTime		:crafted,
						totalTime		:App.data.storage[sid].time,
						doBoost			:onBoostEvent,
						hasBoost		:true,
						btmdIconType	:App.data.storage[sid].type,
						btmdIcon		:App.data.storage[sid].preview,
						picture			:Config.getImage('paintings', imageName, 'jpg')
					}).show();
					return false;					
				}else {
					new SpeedWindow( {
						title			:info.title,
						priceSpeed		:info.speedup,
						target			:this,
						info			:info,
						finishTime		:crafted,
						totalTime		:info.time,
						doBoost			:onBoostEvent,
						btmdIconType	:info.type,
						btmdIcon		:info.preview
					}).show();
					return false;
				}
			}	
			return true;
		}
		
		public override function storageEvent():void
		{
			if (App.user.mode == User.OWNER) {
				wasClick = true;
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onStorageEvent);
			}
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			wasClick = false;
			if (error)
			{
				Errors.show(error, data);
				if(params && params.hasOwnProperty('guest')){
					App.user.friends.addGuestEnergy(App.owner.id);
				}
				return;
			}
			
			ordered = false;
			
			if (data.hasOwnProperty('started'))
			{
				crafted = data.started;
				//started = crafted - info.time;
				showIcon();
				App.self.setOnTimer(work);
				beginAnimation();
			}
			if (data.hasOwnProperty('died') /*&& data.died == 1*/)
			{
				this.died = Boolean(data.died);
				if(died)
					onDie();
			}
			
			if (info.hasOwnProperty('capacity') && info.capacity > 0)
			{
				capacity++;
			}
			
			if (data.bonus)
			{
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
				SoundsManager.instance.playSFX('bonus');
			}
			
			if (params != null) {
				if (params['guest'] != undefined) {
					App.user.friends.giveGuestBonus(App.owner.id);
				}
			}
			
			hasProduct = false;
			//App.self.dispatchEvent(new AppEvent(AppEvent.ON_REWARD_TAKE,false,false,{target:this}));
		}
		
		override public function work():void 
		{
			if (died)
			{
				App.self.setOffTimer(work);
				onDie();
				return;
			}
			if (App.time >= crafted) 
			{
				App.self.setOffTimer(work);
				onProductionComplete();
			}
		}
		
		override public function onBoostEvent(count:int = 0):void 
		{
			if (App.user.stock.take(Stock.FANT, count)) 
			{
				crafted = App.time;
				//started = crafted - info.time;
				showIcon();
				
				var that:Tribute = this;
				onProductionComplete();
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) 
					{
						crafted = data.crafted;
					}
					App.ui.upPanel.update();
					//stopAnimation();
				});	
			}
		}
		
		override public function build():void 
		{
			hasBuilded = true;
			App.self.setOffTimer(build);
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			open = true;
			this.id = data.id;
			started = App.time;
			if (data.crafted)
				crafted = data.crafted
			else
				crafted = App.time /*+ info.time*/;
			
			hasProduct = false;
			beginCraft(0, crafted);
			
			initAnimation();
			beginAnimation();
		}
		/*
		override public function get bmp():Bitmap 
		{
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0)
				return bitmap;
			if (animationBitmap && animationBitmap.bitmapData && animationBitmap.bitmapData.getPixel(animationBitmap.mouseX, animationBitmap.mouseY) != 0)
				return animationBitmap;
				
			return bitmap;
		}*/
		
		public function isMouseHit():Boolean {
			return hitTestPoint(stage.mouseX, stage.mouseY, true);
		}
		
		override public function set tribute(value:Boolean):void
		{
			_tribute = value;
			
			if (_cloud)_cloud.dispose();
				_cloud = null;
			
			if (_tribute)
			{
				setFlag(Cloud.TRIBUTE, click);
			}else
			{
				if (_cloud)_cloud.dispose();
				_cloud = null;
			}
		}
		
		override public function set state(value:uint):void 
		{
			if (_state == value) 
				return;
			
			var elm:* = this;
			
			if (App.user.mode == User.GUEST)
				elm = this.getChildAt(0);
				
			switch(value) 
			{
				case OCCUPIED: 
					elm.filters = [new GlowFilter(0xFF0000, 1, 6, 6, 7)]; 
					break;
				case EMPTY: 
					elm.filters = [new GlowFilter(0x00FF00, 1, 6, 6, 7)]; 
					break;
				case TOCHED: 
					elm.filters = [new GlowFilter(0xFFFF00, 1, 6, 6, 7)]; 
					break;
				case HIGHLIGHTED: 
					elm.filters = [new GlowFilter(0x88ffed, 0.6, 6, 6, 7)]; 
					break;
				case IDENTIFIED: 
					elm.filters = [new GlowFilter(0x88ffed, 1, 8, 8, 10)]; 
					break;
				case DEFAULT: 
					elm.filters = []; 
					break;
			}
			_state = value;
		}
		
		override public function load(hasReset:Boolean = false):void 
		{
			view = info.view;
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
		
		private var unit:Unit;
		private var _availableZone:Shape;
		public var decorCoords:Object;
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			
			initAnimation();
			beginAnimation();
			if (clearBmaps)
			{
				Load.clearCache(Config.getSwf(type, info.view));
				data = null;
			}
			/*if (App.data.storage[App.user.worldID].fogaroundhero && App.data.storage[App.user.worldID].fogoptions.disablefogunits.indexOf(this.sid) != -1)
				drawAntiFog();*/
		}
		
		/*public var circle:Shape = new Shape();
		public function drawAntiFog():void 
		{
			var radius:int = 200; 
			
			circle.graphics.beginFill(0, 1);
			circle.graphics.drawCircle(0, 0, radius);
			circle.graphics.endFill();
			circle.filters = [new BlurFilter(120, 120)];
			App.map.mFog.addChild(circle);
			var point:Object = IsoConvert.isoToScreen(coords.x, coords.z, true);
			circle.cacheAsBitmap = true;
			circle.x = point.x;
			circle.y = point.y;
			circle.cacheAsBitmap = true;
			App.map.mFog.alpha = .93;
			circle.blendMode = BlendMode.ERASE;
		}*/
		
		public function deleteParent():void 
		{
			this.removable = true;
			this.takeable = false;
			this.onApplyRemove();
			unit.placing(decorCoords.x, 0, decorCoords.z);
			App.map.sorted.push(unit);
			App.map.sorting();
		}
		
		override public function findCloudPosition():void
		{
			switch(info.view) 
			{
				case 'fountain':
					setCloudPosition(20, -40);
					break;
				default:
					setCloudPosition(0, -50);
					break;
			}
		}
		override public function uninstall():void 
		{
			super.uninstall();
				//clearAvailableZone();
		}
	}
}