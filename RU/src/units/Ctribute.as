package units 
{
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import ui.Cloud;
	import ui.UnitIcon;
	import wins.CtributeChargeWindow;
	import wins.SpeedWindow;

	public class Ctribute extends Tribute 
	{
		public var charged:Boolean = false;
		public var _crafted:uint = 0;
		public var capacity:uint = 0;
		public var remains:int;
		
		public static var UNIVERSITY:int = 3761;
		public static var AUTO_WELL:int = 3747;	
		public static var HELICOPTER:int = 3837;
		public static var MEDICAL_CENTER:int = 4039;
		public static var EAGLE_NEST:int = 3737;
		public static var MAGIC_FORREST:int = 3736;
		
		public function Ctribute(object:Object) 
		{
			crafted = object.crafted || 0;
			created = object.created || 0;
			if (object.hasOwnProperty('capacity'))
				this.capacity = object.capacity
			
			super(object);
			this.remains = info.capacity - capacity
			cloudPositions = {
				'ctribute_test_mat': {
					x: 0,
					y: -70
				},
				'university_nest': {
					x: 200,
					y: -70
				},
				'whale_green': {
					x: -200,
					y:  10
				},
				'whale_cyan': {
					x: -200,
					y:  10
				},
				'whale_lightblue': {
					x: -200,
					y:  10
				},
				'whale_blue': {
					x: -200,
					y:  10
				},
				'press_plastic': {
					x: 20,
					y:  -140
				}		
			}
			
			if (!Config.admin) 
			{
				removable = false;
			}else 
			{
				removable = true;
			}
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			App.self.setOnTimer(checkWork);
			animated = false;
			
			if (level == totalLevels) 
			{
				beginAnimation();
			}
			showIcon();
		}
		
		public function checkWork():void 
		{
			if (App.time >= crafted && crafted != 1 && crafted != 0)
			{
				crafted = 1;
				animated = false;
				beginAnimation();
				work();
			}
		}
		
		override public function click():Boolean 
		{
			
			this.hideGlowing();
			
			if (App.user.mode == User.GUEST)
			{
				guestClick();
				return true;
			}
			
			if (isPresent()) return true;
			if (openConstructWindow()) return true;
			if (!isReadyToWork()) return true;
			if (isProduct()) return true;
			
			if (level == totalLevels) 
			{
				openCtributeChargeWindow();
			}
			
			return true;
		}
		
		override public function get tribute():Boolean 
		{
			var instanceNum:uint = instanceNumber();
			//if (
			if ((level >= totalLevels && started + info.instance.devel[instanceNum].req[totalLevels].tm <= App.time) && hasProduct)
				return true;
			
			return false;
		}
		
		override public function storageEvent():void
		{
			if (App.user.mode == User.OWNER) 
			{	
				var price:Object = { }
				price[Stock.FANTASY] = 0;
					
				if (!App.user.stock.takeAll(price))	
					return;
				//Hints.minus(Stock.FANTASY, 1, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y), true);
				
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					iid:instanceNumber()
				}, onStorageEvent);
			}
			else 
			{
				if (guestDone) 
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
				}
			}
		}
		
		public function openCtributeChargeWindow():void 
		{
			var instanceNum:uint = instanceNumber();
			var outItemItem:Object = App.data.treasures[info.instance.devel[instanceNum].req[totalLevels].tr][info.instance.devel[instanceNum].req[totalLevels].tr].item;
			var outItemCount:Object = App.data.treasures[info.instance.devel[instanceNum].req[totalLevels].tr][info.instance.devel[instanceNum].req[totalLevels].tr].count;
			var key:int;
			var val:int;
			
			for (var i:* in outItemItem)
			{
				key = outItemItem[i]
			}
			
			for (var c:* in outItemCount)
			{
				val = outItemCount[c]
			}
			
			new CtributeChargeWindow( {
				title:			info.title,
				target:			this,
				win:			this,
				type:			info.instance.devel[instanceNum].req[totalLevels].type,
				outItem:		key,
				outCount:		val,
				callback:		onChargeEvent,
				helpMessage:	info.text1,
				inItem:			(info.instance.devel[instanceNum].req[totalLevels].type == CtributeChargeWindow.MATERIAL_TYPE) ? info.instance.devel[instanceNum].req[totalLevels].mat : null
			}).show();
		}
		
		override public function isReadyToWork():Boolean
		{			
			if (crafted > App.time) 
			{
				var instanceNum:uint = instanceNumber();
				
				new SpeedWindow( {
					title:info.title,
					target:this,
					info:info,
					finishTime:crafted,
					totalTime:info.instance.devel[instanceNum].req[level].tm,
					doBoost:onBoostEvent,
					btmdIconType:App.data.storage[sid].type,
					btmdIcon:App.data.storage[sid].preview
				}).show();
				return false;	
				
			}	
			return true;
		}
		
		override public function work():void
		{
			if (App.time >= crafted && crafted != 0)
			{
				//var flg:String;
				
				App.self.setOffTimer(work);
				tribute = true;
				showIcon();
				//flg = Cloud.TRIBUTE;
				
				//setFlag(flg, click);
				onProductionComplete();
			}
		}
		
		override public function showIcon():void {
			if (!formed || !open) return;
			
			
			if (App.user.mode == User.GUEST && touchableInGuest) {
				//if (info.type == 'Golden')
				//{
					//drawIcon(UnitIcon.REWARD, Stock.COINS, 1, {
						//glow:		false
					//});
				//} 
				
				clearIcon();
			}
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
				var key:uint = 2;
				var instanceNum:uint = instanceNumber();
				var need:uint = info.instance.devel[instanceNum].req[totalLevels].mat;
				var _view:int = 0;
				var _dev:int = Numbers.countProps(info.instance.devel)
				for (var _itm:* in App.data.treasures[info.instance.devel[instanceNum].req[totalLevels].tr][info.instance.devel[instanceNum].req[totalLevels].tr].item)
				{
					if (App.data.treasures[info.instance.devel[instanceNum].req[totalLevels].tr][info.instance.devel[instanceNum].req[totalLevels].tr].probability[_itm] == 100)
						key = App.data.treasures[info.instance.devel[instanceNum].req[totalLevels].tr][info.instance.devel[instanceNum].req[totalLevels].tr].item[_itm]
				}
				if (crafted > 0 && crafted > App.time) 
				{
					drawIcon(UnitIcon.PRODUCTION, key, 0, 
					{
						iconScale:	0.7,
						progressBegin:	crafted - info.instance.devel[instanceNum].req[totalLevels].tm,
						progressEnd:	crafted
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else if (level >= totalLevels && tribute) 
				{		
					drawIcon(UnitIcon.REWARD, key, 1, {
						glow:		true
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else if (level >= totalLevels && !tribute)
				{
					drawIcon(UnitIcon.REWARD, need, 1, {
						glow:		true
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
					clearIcon();
				}
			}
		}
		
		override public function onProductionComplete():void
		{
			hasProduct = true;
			crafting = false;
			crafted = 1;
			App.tips.hide();
			showIcon();
		}
		
		override public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			super.onBonusEvent(error, data, params);
			crafted = 0;
			animated = false;
			beginAnimation();
		}
		
		public function onChargeEvent(time:uint):void 
		{
			crafted = time;
			animated = false;
			beginAnimation();
			showIcon();
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			super.onStorageEvent(error, data, params);
			crafted = data.crafted;
			animated = false;
			beginAnimation();
			checkProduction();
			clearIcon();
			showIcon();
			capacity += 1;
			remains -= 1;
			tribute = false;
			hasProduct = false;
			if (data.hasOwnProperty('died'))
				uninstall();
		}
		
		override public function onBoostEvent(count:int = 0):void 
		{
			if (App.user.stock.take(Stock.FANT, count)) 
			{
				//lock = true;
				
				var that:Tribute = this;
				
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
						App.ui.flashGlowing(that);
					}
					//lock = false;
					started = 0;
					hasProduct = true;
					tribute = true;
					animated = false;
					beginAnimation();
					showIcon();
				});	
			}
			
		}
		
		override public function init():void 
		{
			super.init();
			
			tip = function():Object {
				
				//Когда можно собрать продукт
				/*if (tribute){
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379966") + ": " + allTitles//Нажми, чтобы забрать бонус
					};
				}*/
				
				//Когда ожидает зарядки
				if (level == totalLevels && !hasProduct && !hasPresent && crafted == 0)
				{
					if (this.info.hasOwnProperty('capacity') && this.info.capacity != '')
					{
						return {
							title:info.title,
							text:App.data.storage[sid].description + '\n' + Locale.__e('flash:1502725898590', remains) ,
							timer:true
						};
					}
					else
					{
						return {
							title:info.title,
							text:App.data.storage[sid].description,
							timer:true
						};
					}
					
					
				}
				
				//Когда в процессе выдачи
				if (level == totalLevels && !hasProduct && !hasPresent && crafted > 0)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379839"),
						timerText:TimeConverter.timeToCuts(crafted - App.time, true, true),
						timer:true
					};
				}
				
				var descriptionText:String = '';
				
				/*if (multiTributes.indexOf(int(this.sid)) != -1) {
					descriptionText = Locale.__e("flash:1458830094344");//Можно получить с шансом приятные бонусы:
				}else 
				{*/
					descriptionText = App.data.storage[sid].description;//Нажми, чтобы собрать бонус
				//}
				
				return {
					title: info.title,
					text: descriptionText
				};
			}
		}
		
		public function afterStorageUpdate(postData:Object = null):void
		{
			crafted = postData.crafted;
			hasProduct = false;
			tribute = false;
			
			if (crafted != 0 && crafted != 1) 
			{
				tribute = false;
				hasProduct = false;
				App.self.setOnTimer(work);
			}
		}
		
		override public function beginAnimation():void 
		{
			if (textures && textures.animation != null && !animated) 
			{
				initAnimation();
				startAnimation();
			}
		}
		
		override public function initAnimation():void 
		{
			if (level != totalLevels) 
			{
				return;
			}
			
			framesTypes = [];
			if (frameType) 
			{
				frameType == null;
			}
			
			if (textures && textures.hasOwnProperty('animation') && textures.animation.animations.hasOwnProperty('work') && textures.animation.animations.hasOwnProperty('pause'))
			{
				for (var frameType:String in textures.animation.animations)
				{
					if ((crafted == 0 || crafted == 1 || crafted < App.time) && frameType == 'pause') 
					{
						framesTypes.push(frameType);
					}else if (crafted > App.time && frameType == 'work') 
					{
						framesTypes.push(frameType);
					}
				}
				addAnimation()
				animate();
				
			}else if (textures && textures.hasOwnProperty('animation')) 
			{
				for (frameType in textures.animation.animations)
				{
					framesTypes.push(frameType);
				}
				addAnimation()
				animate();
			}
		}
		
		
		
		//Флажок строительства
	/*	override public function setCloudCoords():void
		{
			super.setCloudCoords();
			
			if (cloud && bounds)
			{
				if (sid == UNIVERSITY)
				{
					cloud.x = 50;
					cloud.y = -250;
				}
			}
		}*/
		
		/*override public function findCloudPosition():void
		{
			super.findCloudPosition();
			
			switch(info.view)
			{
				case 'aircraft':
					setCloudPosition(5, -300);
				break;
				default:
					setCloudPosition(0, -60);
				break;
			}
		}*/
	}
}