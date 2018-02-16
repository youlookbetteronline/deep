package units 
{
	import astar.AStarNodeVO;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.Cloud;
	import ui.UnitIcon;
	import wins.ConstructWindow;
	import wins.SharkWindow;
	import wins.SimpleWindow;
	import wins.SpeedWindow;
	
	public class Tribute extends Building
	{
		public static var plumbuses:Array = [1790, 1791, 1793, 1794, 1795];
		
		private var _started:int = 0;
		public var _tribute:Boolean = false;
		private var died:Boolean = false;
		private var launched:int = 0;
		private var capacity:int = 0;
		private var lifetime:int = 0;
		
		private var _hasResetCapacity:Boolean;	// нужен ли ресет по капасити
		private var _hasResetLifetime:Boolean;	// нужен ли ресет по лайфтайму

		public static const CTREE:int = 2988;

		public function get started():int 
		{
			return _started;
		}
		public function set started(value:int):void 
		{
			_started = value;
		}
		
		public function Tribute(object:Object) 
		{
			super(object);
			crafted = object.crafted || 0;
			started = crafted - info.time || 0;
			if(App.data.storage[this.sid].type == 'Tribute')
				totalLevels = Numbers.countProps(App.data.storage[this.sid].instance.devel[1].obj);
			if (object.hasOwnProperty('died'))
				this.died = true;
			if (object.hasOwnProperty('launched'))
				launched = object.launched;
			else
				launched = App.time;
			if (object.hasOwnProperty('lifetime'))
				lifetime = object.lifetime;
			if (object.hasOwnProperty('capacity'))
				capacity = object.capacity;
			if (object.hasOwnProperty('level'))
				level = object.level;
			touchableInGuest = false;
			init();
			//removable = true;
		}
		
		override public function get bmp():Bitmap {
			if (multiBitmap && multiBitmap.bitmapData && multiBitmap.bitmapData.getPixel(multiBitmap.mouseX, multiBitmap.mouseY) != 0)
				return multiBitmap;
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0)
				return bitmap;
				
			return bitmap;
		}
		
		override public function onRemoveFromStage(e:Event):void 
		{
			//App.self.setOffTimer(left);
			App.self.setOffTimer(work);
			super.onRemoveFromStage(e);
		}
		
		public function init():void 
		{
			if (level == totalLevels)
			{
				touchableInGuest = true;
			}
			
			Load.loading(Config.getIcon('Material', App.data.storage[Stock.COINS].view), onOutLoad);
			//Если мы дома
			if (App.user.mode == User.OWNER) 
			{
				if (level === totalLevels) 
				{
					App.self.setOnTimer(work);
				}
			}
			
			tip = tips;
			if (!died)
				showIcon();
		}
		
		/*override public function calcState(node:AStarNodeVO):int 
		{
			return EMPTY;
			return super.calcState(node);
		}*/
		
		override protected function tips():Object
		{
				
			if (level == totalLevels && this.died)
			{
				return {
					title:info.title,
					text:Locale.__e("flash:1501245269125")
				};
			}
			else if (tribute && hasResetCapacity){
				return {
					title:info.title,
					text:Locale.__e("flash:1382952379966")+'\n\n'+Locale.__e("flash:1505828018760") + ' ' + (info.capacity - capacity) + ' ' + Locale.__e('flash:1505828587228')
				};
			}
			else if (tribute && hasResetLifetime && (launched + info.lifetime >= App.time)){
				return {
					title:info.title,
					text:Locale.__e("flash:1382952379966")+'\n'+Locale.__e("flash:1505828018760"),
					timerText: TimeConverter.timeToDays(launched + info.lifetime - App.time),
					timer:true
				};
			}
			else if (tribute && hasResetLifetime && (launched + info.lifetime < App.time)){
				return {
					title:info.title,
					text:Locale.__e("flash:1382952379966")
				};
			}
			if (tribute){
				return {
					title:info.title,
					text:Locale.__e("flash:1382952379966")
				};
			}
			
			if (level == totalLevels)
			{
				if (hasResetCapacity)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1505828018760") + ' ' + (info.capacity - capacity) + ' ' + Locale.__e('flash:1505828587228') + '\n\n' + Locale.__e("flash:1382952379839"),
						timerText: TimeConverter.timeToStr(crafted - App.time),
						timer:true
					};
				}
				
				if (hasResetLifetime && (launched + info.lifetime >= App.time))
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379839"),
						timerText: TimeConverter.timeToStr(crafted - App.time),
						desc: Locale.__e("flash:1505828018760"),
						timerText2: TimeConverter.timeToDays(launched + info.lifetime - App.time),
						timer:true
					};
				}
				else if (hasResetLifetime && (launched + info.lifetime < App.time))
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379839"),
						timerText: TimeConverter.timeToStr(crafted - App.time)
					};
				}

				if (this.died)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1501245269125")
					};
				}
				else if (App.user.mode == User.OWNER)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379839"),
						timerText: TimeConverter.timeToStr(crafted - App.time),
						timer:true
					};
				}
				else
				{
					return {
						title:info.title
					};
				}
			}
			else if (level < totalLevels)
			{
				if (plumbuses.indexOf(sid) != -1)
				{
					return {
						title:info.title,
						text:info.description
					};
				}else{
					return {
						title:info.title,
						text:Locale.__e("flash:1461569023187")
					};
				}
			}
			
			return {
				title:info.title,
				text:Locale.__e("flash:1382952379967")
			};
		}
		
		override public function click():Boolean 
		{	
			if (!clickable || id == 0 || (App.user.mode == User.GUEST && touchableInGuest == false) || died) 
				return false;
				
			App.tips.hide();
			
			if (App.user.useSectors)
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
			
			if (level < totalLevels) 
			{
				var instanceNum:uint = instanceNumber();
				if (App.user.mode == User.OWNER)
				{
					if (plumbuses.indexOf(this.sid) != -1)
					{
						new SharkWindow( {
							title:			info.title,
							bttnCaption:	Locale.__e('flash:1496913298130'),
							upgTime:		info.instance.devel[instanceNum].req[level + 1].l,
							request:		info.instance.devel[instanceNum].obj[level + 1],
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true,
							popup:			false,
							spirit:			this
						}).show();
					}else{
						new ConstructWindow( {
							title:			info.title,
							upgTime:		info.instance.devel[instanceNum].req[level + 1].l,
							request:		info.instance.devel[instanceNum].obj[level + 1],
							reward:			info.instance.devel[instanceNum].rew[level + 1],
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true,
							popup:			false
						}).show();
					}
				}
			}
			else
			{
				if (tribute)
				{
					var price:Object = getPrice();
					
					if (!App.user.stock.checkAll(price))	
						return true;  // было false
					
					// Отправляем персонажа на сбор
					storageEvent();						
					ordered = false;
				}
				else if(App.user.mode == User.OWNER)
				{
					if (!isReadyToWork()) 
						return true;
				}
			}
			
			return true;
		}
		
		override public function isProduct():Boolean
		{
			if (hasProduct)
			{
				var price:Object = getPrice();
						
				if (!App.user.stock.checkAll(price))	
					return true;  // было false
				
				// Отправляем персонажа на сбор
				storageEvent();
				
				/*App.user.addTarget( {
					target:this,
					near:true,
					callback:storageEvent,
					event:Personage.HARVEST,
					jobPosition: findJobPosition(),
					shortcut:true
				});*/
				
				ordered = false;
				
				return true; 
			}
			return false;
		}
		
		override public function isReadyToWork():Boolean
		{
			if (!tribute) 
			{
				new SpeedWindow( {
					title			:info.title,
					priceSpeed		:info.speedup,
					target			:this,
					info			:info,
					finishTime		:started + info.time,
					totalTime		:App.data.storage[sid].time,
					doBoost			:onBoostEvent,
					btmdIconType	:App.data.storage[sid].type,
					btmdIcon		:App.data.storage[sid].preview
				}).show();
				return false;	
			}	
			return true;
		}
		
		private function getPosition():Object 
		{
			var Y:int = -1;
			if (coords.z + Y <= 0)
				Y = 0;
			
			return { x:int(info.area.w / 2), y: Y };
		}
		
		public function get tribute():Boolean 
		{
			if (level >= totalLevels && started + info.time <= App.time)
				return true;
			
			return false;
		}
		
		public function set tribute(value:Boolean):void 
		{
			_tribute = value;
			//var flg:String;
			showIcon();
			/*if (_tribute)
			{
				if (App.user.mode == User.GUEST) 
				{
					flg = Cloud.TRIBUTE;
				}else 
				{
					if (sid == 48)
						flg = Cloud.WATER;
					else if (sid == 890)
						flg = Cloud.SPRING_WATER;
					else if (sid == 1085)
						flg = Cloud.HONEYCOMB;
					else if (sid == 3215)
						flg = Cloud.CRYSTALWATER;
					else
						flg = Cloud.TRIBUTE;
				}
				
				setFlag(flg, click,{target:this});
			}
			else
			{
				flag = false;
			}*/
			
		}
		
		override protected function beginCraft(fID:uint, crafted:uint):void
		{
			this.fID = fID;
			this.crafted = crafted;
			hasProduct = false;
			crafting = true;
			
			App.self.setOnTimer(work);
		}
		
		public function work():void
		{
			if (tribute) {
				App.self.setOffTimer(work);
				if (!died)
				showIcon();
				//App.self.dispatchEvent(new AppEvent(AppEvent.ON_REWARD_READY,false,false,{target:this}));
			}
		}
		
		override public function onBoostEvent(count:int = 0):void {
			
			if (App.user.stock.take(Stock.FANT, info.speedup)) {
				
				started = App.time - info.time;
				showIcon();
				
				var that:Tribute = this;
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) {
						started = data.crafted - info.time;
						App.ui.flashGlowing(that);
					}
					
				});	
			}
		}
		
		//public var guestDone:Boolean = false;
		public override function storageEvent():void
		{
			if (App.user.mode == User.OWNER) 
			{
				var price:Object = { }
				price[Stock.FANTASY] = 0;
					
				if (!App.user.stock.takeAll(price))	
					return;
				//Hints.minus(Stock.FANTASY, 1, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y), true);
				started = App.time;
				crafted = started + info.time;
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					iID:instanceNumber()
				}, onStorageEvent);
			}
			//else 
			//{
				//return;
				/*if (guestDone) 
					return;
			
				if(App.user.addTarget({
					target:this,
					near:true,
					callback:onGuestClick,
					event:Personage.HARVEST,
					jobPosition:getContactPosition(),
					shortcut:true
				})) {
					ordered = true;
					clearIcon();
				}
				else 
				{
					ordered = false;
				}*/
			//}
		}
		
		override public function onGuestClick():void 
		{
			return;
			if (App.user.friends.takeGuestEnergy(App.owner.id)) 
			{
				guestDone = true;
				var that:* = this;
				Post.send( {
					ctr:'user',
					act:'guestkick',
					uID:App.user.id,
					sID:this.sid,
					fID:App.owner.id
				}, function(error:int, data:Object, params:Object):void {
					if (error) {
						Errors.show(error, data);
						return;
					}	
					if (data.hasOwnProperty("bonus")){
						clearIcon();
						Treasures.bonus(data.bonus, new Point(that.x, that.y));
					}
					ordered = false;
					
					if (data.hasOwnProperty('energy')) {												//
						if(App.user.friends.data[App.owner.id].energy != data.energy){					//
							App.user.friends.data[App.owner.id].energy = data.energy;					//
							App.ui.rightPanel.update();													//test
						}																				//
					}																					//
					App.user.friends.giveGuestBonus(App.owner.id);										//
				});
			}
			else 
			{
				showIcon();
				ordered = false;
				////Hints.text(Locale.__e('flash:1382952379907'), Hints.TEXT_RED,  new Point(App.map.scaleX*(x + width / 2) + App.map.x, y*App.map.scaleY + App.map.y));
				App.user.onStopEvent();
				return;					
			}
		}
		
		public function onHelperStorage(_started:uint):void {
			started = _started;
			App.self.setOnTimer(work);
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				if(params && params.hasOwnProperty('guest')){
					App.user.friends.addGuestEnergy(App.owner.id);
				}
				return;
			}
			if (data.hasOwnProperty('died') && data.died == 1)
				this.died = true;
			
			if (hasResetCapacity)
			{
				capacity ++;
				if (data.doReset)
					resetEvent();
			}
			
			if (hasResetLifetime && data.doReset)
				resetEvent();
			ordered = false;
			
			started = App.time;
			crafted = started + info.time;
			App.self.setOnTimer(work);
			
			
			showIcon();
			
			/*if (data.hasOwnProperty('started')) {
				started = data.started;
				crafted = started + info.time;
				App.self.setOnTimer(work);
			}*/
			
			Treasures.bonus(data.treasure, new Point(this.x, this.y));
			
			if (info.sID == 3397)
				SoundsManager.instance.playSFX('country');
			else
				SoundsManager.instance.playSFX('bonus');
			
			if (params != null) {
				if (params['guest'] != undefined) {
					App.user.friends.giveGuestBonus(App.owner.id);
				}
			}
			//App.self.dispatchEvent(new AppEvent(AppEvent.ON_REWARD_TAKE,false,false,{target:this}));
			
		}
		
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			else 
			{
				level = data.level;
				hasUpgraded = false;
				hasBuilded = true;
				upgradedTime = data.upgrade;
				App.self.setOnTimer(upgraded);
				
				addEffect(Building.BUILD);
				showIcon();
				
				if (level == totalLevels || permanentAnimated)
					checkOnAnimationInit();
				if (data.launched)
					launched = data.launched
				
				if (data.bonus)
				{
					Treasures.bonus(Treasures.convert(data.bonus), new Point(this.x, this.y));
				}
				ordered = false;
			}
		}
		
		override public function checkOnAnimationInit():void 
		{
			if (textures && textures['animation'] && ((level == totalLevels /*- craftLevels*/) || permanentAnimated /*|| this.sid == 236*/)) 
			{
				initAnimation();
				//if (crafted) 
				//{
					beginAnimation();
					startAnimation();
				//}
				/*else
				{
					finishAnimation();
				}*/
			}
			
			/*if (sid == 28 && textures && level == 0)
			{
				initAnimation();
				beginAnimation();
				startAnimation();
			}*/
		}
		
		override public function finishUpgrade():void
		{
			super.finishUpgrade();
			if (level >= totalLevels) 
			{
				//started = App.time;
				started = 0;
			}
		}
		
		override public function set material(toogle:Boolean):void {
			if (countLabel == null) return;
			
			if (toogle) {
				countLabel.text = TimeConverter.timeToStr((started + info.time) - App.time);
				countLabel.x = (icon.width - countLabel.width) / 2;
			}
			//popupBalance.visible = toogle;
		}
		
		override public function remove(_callback:Function = null):void {
			App.self.setOffTimer(work);
			super.remove(_callback);
		}
		
		override public function beginAnimation():void {
			if(textures && textures.animation != null && !animated)
				startAnimation();
		}
		
		override public function flip():void 
		{
			super.flip();	
			showIcon();
		}
		
		override public function showIcon():void {
			if (!formed || !open) return;
			
			if (App.user.mode == User.GUEST && touchableInGuest) {
				clearIcon();
			}
			
			if (died)
				clearIcon();
			
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
					coordsCloud.y = -20;
				}
			}
			
			if (App.user.mode == User.OWNER) 
			{
				var instanceNum:uint = instanceNumber();
				var _view:int = Stock.COINS;
				if(info.hasOwnProperty('treasure') && info.treasure!=""){
					for (var i:* in App.data.treasures[info.treasure][info.treasure].item){
						_view = App.data.treasures[info.treasure][info.treasure].item[i];
					}
				}
				
				if (level >= totalLevels && tribute) 
				
				{		
					drawIcon(UnitIcon.REWARD, _view, 1, {
						glow:		true
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1)) 
				{
					if (plumbuses.indexOf(this.sid) != -1){
						drawIcon(UnitIcon.CLEAR, 1275, 0, {
							level: level,
							totalLevels: totalLevels
						}, 0, coordsCloud.x, coordsCloud.y);
					}else{
						drawIcon(UnitIcon.BUILD, null, 0, {
							level: level,
							glow:	true,
							totalLevels: totalLevels
						}, 0, coordsCloud.x, coordsCloud.y);
					}
				}
				else 
				{
					clearIcon();
				}
			}
		}
		
		public function findCloudPosition():void
		{
			if (cloudPositions.hasOwnProperty(info.view))
				setCloudPosition(cloudPositions[info.view].x, cloudPositions[info.view].y);
			
			switch(info.view)
			{
				case 'drinking_fountain':
					setCloudPosition(20, -40);
				break;
				default:
					setCloudPosition(0, -60);
				break;
			}			
		}
		
		// reset with capacity/lifetime
		
		private function get hasResetCapacity():Boolean 
		{
			_hasResetCapacity = false
			if (info.hasOwnProperty('reset') && info.reset == 1 && info.hasOwnProperty('capacity') && info.capacity != '')
			{
				_hasResetCapacity = true;
			}
			return _hasResetCapacity;
		}
		
		private function get hasResetLifetime():Boolean 
		{
			_hasResetLifetime = false
			if (info.hasOwnProperty('reset') && info.reset == 1 && info.hasOwnProperty('lifetime') && info.lifetime != '')
			{
				_hasResetLifetime = true;
			}
			return _hasResetLifetime;
		}
		
		private function resetEvent():void 
		{
			Post.send( {
				ctr	:this.type,
				act	:'reset',
				uID	:App.user.id,
				id	:this.id,
				wID	:App.user.worldID,
				sID	:this.sid
			},onResetEvent);
		}
		
		private function onResetEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			else
			{
				level = data.level
				capacity = data.capacity;
				hasUpgraded = true;
				hasPresent = true;
				load(true);
				clearAnimation();
				showIcon();
				ordered = false;
				checkOnAnimationInit();
				
			}
		}
	}	
}