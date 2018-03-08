package units 
{
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.Cloud;
	import ui.UnitIcon;
	import ui.UserInterface;
	import utils.Finder;
	
	public class Personage extends WUnit
	{
		public static const E:int = 0;
		
		public var level:uint = 0;
		
		public var _flag:* = false;
		public var prevFlag:* = false;
		public var preloader:Bitmap = null;
		public var cloud:Cloud;
		
		
		public static const BEAR:uint 			= 177;
		public static const BEAVER:uint 		= 622;
		public static const PANDA:uint 			= 1069;
		public static const BOOSTER:uint 		= 431;
		public static const HERO:uint			= 8;
		public static const CONDUCTOR:uint		= 457;
		public static const TECHNO:uint			= 8;
		public static const TECHNO_GREEK:uint	= 927;
		public static const TECHNO_NORD:uint	= 1681;
		
		public static const SOW:String 		= "water";
		public static const CUT:String 		= "cut";
		public static const FISH:String		= "fish";
		public static const MINE:String		= "mine";
		public static const REST:String 	= "rest";
		public static const WALK:String 	= "walk";
		public static const HARVEST:String 	= "work";//harvest
		public static const GATHER:String 	= "work";//gather
		public static const STOP:String 	= "stop_pause";
		public static const EMERGE:String 	= "action";
		public static const WORK:String 	= "work";
		public static const BUILD:String 	= "build";
		public static const WAIT:String 	= "stop_pause";//wait
		private var bufferWord:int = -1;
		
		
		private var loaderCoords:Object = {
			'man': { x: -15, y: -100 },
			'woman': { x: -15, y: -100 }
		}
		
		public function Personage(object:Object, view:String = '')
		{
			if (object.layer)
				layer = object.layer;
			else
				layer = Map.LAYER_SORT
			
			super(object);
			
			rotateable = false;
			transable = false;
			moveable = false;
			flyeble = true;
			
			if (view !== '') {
				info.view = view;
			}
			
			
			/*if(UserInterface.textures.hasOwnProperty(info.view)){
				preloader = new Bitmap(UserInterface.textures[info.view])
				preloader.x = loaderCoords[info.view].x;
				preloader.y = loaderCoords[info.view].y;
			}*/
			if (info.type != 'Walkhero' && info.type != 'Contest')
				load();
		}
		
		public function load():void
		{
			if (preloader) addChild(preloader);
			Load.loading(Config.getSwf(info.type, info.view), onLoad);
		}
		
		/*public function onLoad(data:*):void 
		{
			textures = data;
			
			
			if (preloader) {
				TweenLite.to(preloader, 0.5, { alpha:0, onComplete:removePreloader } );
			}
		}
		*/
		public function onLoad(data:*):void 
		{
			textures = data;
			getRestAnimations();
			addAnimation();
			createShadow();
			
			if (!open && formed) 
				applyFilter();
			
			//Load.clearCache(Config.getSwf(info.type, info.view));
			//data = null;
		}
		
		public function removePreloader():void
		{
			if (preloader) 
				removeChild(preloader);
			preloader = null;
		}
		
		public function onPathToTargetComplete():void
		{
			
		}
		
		public function testHireAniamtion(worker:Personage, animationType:String = 'stop_pause'):String {
			if (worker.textures && worker.textures.animation.animations.hasOwnProperty(animationType)) {
				return animationType;
			}else {
				return Personage.STOP;
			}
		}
		protected var dialogTimeout:uint;
		protected var rests:Array = [];
		//private var rests:Array = [];
		public function getRestAnimations():void {
			for (var animType:String in textures.animation.animations)
				if (animType.indexOf('rest') != -1 || animType.indexOf('idle') != -1)
					rests.push(animType);
		}
		
		public function onStop():void
		{
			
		}
		
		public function get flag():* 
		{
			return _flag;
		}
		
		public function set flag(value:*):void
		{			
			if (cloud != null)
			{
				removeChild(cloud);
				cloud = null;
			}
			
			_flag = value;
			
			if (_flag)
			{
				if (sid == Personage.TECHNO)
				{
					cloud = new Cloud(_flag, { view:'jam' } );
					cloud.y = -140;
				}else{
					cloud = new Cloud(_flag, { view:'fish' } );
					cloud.y = -75;
				}	
				
				addChild(cloud);
				cloud.x = - cloud.width / 2;
			}
		}
		
		public var defaultStopCount:uint = 5;
		private var stopCount:uint = defaultStopCount;
		public var restCount:uint = 0;
		
		override public function click():Boolean
		{
			super.click();
			if (info.preview && Quests.questsPerses.hasOwnProperty(info.preview)){
				if (App.data.personages.hasOwnProperty(Quests.questsPerses[info.preview]))
				{
					for each(var quest:* in App.user.quests.opened){
						if (quest.character == Quests.questsPerses[info.preview])
						{
							App.user.quests.openWindow(quest.id);
							return true;
						}
					}
				}
			}
			return true;
		}
		
		override public function onLoop():void
		{	
		}
		
		public function onGoHomeComplete():void 
		{
			stopCount = generateStopCount();
			stopRest();
		}
		
		/*	oneFilter	=	первая фильтрация 1-10 что сообщение не вылетит
		 *	twoFilter	=	вторая фильтрация 1-10 что сообщение не вылетит относительно первого фильтра
		 * */
		public function saySomethingFilter(oneFilter:int = 8, twoFilter:int = 8):void 
		{
			if (Math.random() * 10 > oneFilter && this.type != 'Animal')
			{
				if (App.user.level > 6)
				{
					if (Math.random() * 10 > twoFilter && this.type != 'Animal')
					{
						dialogTimeout = setTimeout(saySomething, 3000 + Math.random() * 1000);
						
						//trace("Уровень персонажа " + App.user.level);
						//trace("сработал диалог");
					}
				}
				else{
					dialogTimeout = setTimeout(saySomething, 3000 + Math.random() * 1000);
					//trace("Уровень персонажа " + App.user.level);
					//trace("сработал диалог - 2");
				}
			}
		}
		
		public function setRest():void 
		{
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			
			framesType = randomRest;
			startSound(randomRest);
			saySomethingFilter();
			/*if (Math.random() * 10 > 8 && this.type != 'Animal')
			{
				if (App.user.level > 6)
				{
					if (Math.random() * 10 > 5 && this.type != 'Animal')
						dialogTimeout = setTimeout(saySomething, 3000 + Math.random() * 1000);
				}else{
					dialogTimeout = setTimeout(saySomething, 3000 + Math.random() * 1000);
				}
			}*/
			
			restCount--;
			if (restCount <= 0){
				stopCount = generateStopCount();
				loopFunctionn = stopRest;
			}else
				loopFunctionn = setRest;
				
			/*if (App.user.quests.tutorial) {
				framesType = STOP;
				return;
			}
			
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			restCount = generateRestCount();
			framesType = randomRest;
			startSound(randomRest);
			
			if (Math.random() * 10 > 7 && this.type != 'Animal')
				dialogTimeout = setTimeout(saySomething, 2000 + Math.random() * 1000);*/
		}
		
		public function stopRest():void 
		{
			if (framesType != Personage.STOP)
			{
				framesType = Personage.STOP;
			}
			stopCount--;
			if (stopCount <= 0){
				restCount = generateRestCount();
				loopFunctionn = setRest;
			}else
				loopFunctionn = stopRest;
		}
		
		/*public function nearestUnit():*{
			return Finder.nearestUnit(this);
			
			var nearestUnit:*;
			var nearestPos:uint = 999999999999999999;
			var childs:int;
			var unit:*;
			childs = App.map.mSort.numChildren;
			while (childs--) {
				unit = App.map.mSort.getChildAt(childs);
				//var xx:uint = Math.abs(unit.x - App.user.hero.x);
				//var yy:uint = Math.abs(unit.y - App.user.hero.y);
				var xx:uint = Math.abs(unit.x - this.x);
				var yy:uint = Math.abs(unit.y - this.y);
				if( xx + yy  < nearestPos && unit!= this){
					nearestPos = xx + yy;
					nearestUnit = unit;
				}
			}
			return nearestUnit;
		}*/
		

		
		//public var coordsCloud:Object = new Object();
		
		public var timeDialog:Number;
		public var onHideFunction:Function = null;
		public function saySomething(bgColor:uint = 0xfffef4, borderColor:uint = 0x123b65, word:String = ''):void
		{
			clearTimeout(dialogTimeout);
			if (this.sid == 535) //синий краб
				return;
			if (!this.visible)
				return;
			var titleUnit:String;
			
			var nUnit:* = Finder.nearestUnit(this);
			if (nUnit && nUnit != null && nUnit is Unit && nUnit.sid && App.data.storage[nUnit.sid])
			{
				titleUnit = App.data.storage[nUnit.sid].title;
			}else{
				if(word == '')
					return;
			}
				
			var wordsArray:Array = new Array();
			if (!User.phrases)
				return;
			if (User.phrases.sids.hasOwnProperty(this.sid))
				wordsArray = User.phrases.sids[this.sid];
			else{
				if (User.phrases.hasOwnProperty(this.type))
					wordsArray = User.phrases[this.type];
				else
					wordsArray = User.phrases.Default;
			}
			
			if (word != '')
				wordsArray = new Array(word);
				
			var randint:Number = int(Math.random() * wordsArray.length);
			if (randint == bufferWord && word == '')
				return;
			var dy:int = 0;
			var word:String = Locale.__e(wordsArray[randint], titleUnit);
			bufferWord = randint;
			var wLength:int = word.length;
			if (wLength > 30){
				timeDialog = wLength / 9 * 1000;
			}
			else{
				timeDialog = wLength / 7 * 1000;
			}
			if (timeDialog < 3000)
				timeDialog = 3000;
			if (App.data.storage[sid].hasOwnProperty('cloudoffset') && (App.data.storage[sid]['cloudoffset'].dx != 0 || App.data.storage[sid]['cloudoffset'].dy != 0))
			{
				//dx.x = App.data.storage[sid]['cloudoffset'].dx;
				dy = App.data.storage[sid]['cloudoffset'].dy;
			}
			else if (cloudPositions.hasOwnProperty(App.data.storage[sid].view)) 
			{
				dy = cloudPositions[App.data.storage[sid].view].y;
			}
			//trace(randint);
			drawIcon(UnitIcon.DIALOG, 0, 0, {
				fadein:			true,
				hidden:			true,
				hiddenTimeout:	timeDialog,
				text:			"" + word,
				iconDY:			-10,
				onHide:			onHideFunction,
				textSettings:	{
					color:			bgColor,
					borderColor:	borderColor,
					textAlign:		'center',
					autoSize:		'center',
					fontSize:		20,
					shadowSize:		1.5
				}
			}, 0, 0, 20 + dy);
		}
		
		public var cloudPositions:Object = {
			//Pet
			'fishdog':{
				x:0,
				y:-120
			},
			//Walkgolden
			'crab':{
				x:0,
				y:-30
			},
			'snail':{
				x:0,
				y:-30
			},
			'small_snail':{
				x:0,
				y:-20
			},
			'big_snail':{
				x:0,
				y:-60
			},
			'walken_warrior':{
				x:0,
				y:-130
			},
			'walken_rider':{
				x:0,
				y:-130
			},
			'small_snail': {
				x:0, 
				y:-30
			},
			'snail':{
				x: -3,
				y:-50
			},
			'big_snail':{
				x:0,
				y:-70
			},
			'fish_clown':{
				x:0,
				y:-130
		    },
		    'green_fish':{
				x:0,
				y:-190
		    },
		    'octopus_johny':{
				x:0,
				y:-100
		    },
		    'johny':{
				x:0,
				y:-100
		    },
		    'needle_fish':{
				x:0,
				y:-120
		    },
			'yellow_little_fish':{
				x:0,
				y:-145
			},
			'blue_orange_fish':{
				x:0,
				y:-150
			},
			'fish_prick':{
				x:0,
				y:-150
			},
			//Animal
			'skat':{
				x:0,
				y:-50
			},
			'hammerfish':{
				x: -15,
				y:-50
			},
			'cowfish':{
				x: -5,
				y:-70
			},
			'manatee':{
				x:0,
				y:-55
			},
			'dolphin':{
				x: -10,
				y:-70
			},
			'medusa':{
				x:0,
				y:-70
			},
			'north_whale':{
				x:0,
				y:-70
			},'seahorse':{
				x:0,
				y:-90
			},'fish_dandruff':{
				x:0,
				y:-80
			},'rabbit_green':{
				x:0,
				y:-50
			},'rabbit_yellow':{
				x:0,
				y:-50
			},'rabbit_blue':{
				x:0,
				y:-50
			},'rabbit_red':{
				x:0,
				y:-50
			},'rabbit_pink':{
				x:0,
				y:-50
			},'skat_blue':{
				x:0,
				y:-50
			},'lohness_small':{
				x:0,
				y:-50
			},'octopus_animal':{
				x:20,
				y:-80
			},'geckofrog':{
				x:0,
				y:-80
			},'redStingray':{
				x:0,
				y:-145
			},'purpleStingray':{
				x:0,
				y:-150
			},
			//Techno
			'manatee_painter':{
				x:0,
				y:-90
			},
			'manatee_drummer':{
				x:0,
				y:-90
			},
			'snail_animal':{
				x:0,
				y:-40
			},
			'little_octopuses_one':{
				x:0,
				y:-40
			},
			'little_octopuses_two':{
				x:0,
				y:-40
			},
			'little_octopuses_three':{
				x:0,
				y:-40
			},
			'octopus_hunter':{
				x:0,
				y:-80
			},
			'octopus_miner':{
				x:0,
				y:-80
			},
			'octopus_cook':{
				x:0,
				y:-80
			},
			//Hero
			'girl':{
				x:0,
				y:-90
			},
			'boy':{
				x:0,
				y:-90
			},
			//Walkgolden
			'wife_simply':{
				x:0,
				y:-90
			},
			'wife_angry':{
				x:0,
				y:-90
			},
			'wife_good':{
				x:0,
				y:-90
			},
			'turtle':{
				x:0,
				y:-70
			},
			'octopus':{
				x:0,
				y:-90
			},
			'squid':{
				x:0,
				y:-110
			},
			'gold_fish':{
				x:0,
				y:-140
			},
			'octopus_cupid':{
				x:0,
				y:-80
			},
			'fromice_fish':{
				x:0,
				y:-135
			},
			'fishbird_walkgolden':{
				x:0,
				y:-135
			},'lohness':{
				x:0,
				y:-40
			},'squid_with_tray_walk':{
				x:-5,
				y:-75
			},'shark':{
				x:-5,
				y:-165
			},
			//Walkgift
			'valentine':{
				x:-25,
				y:-165
			}
		};
		
		public function startSound(type:String):void 
		{
		}
		
		public function generateStopCount():uint 
		{
			return int(Math.random() * 5) + 3;
		}
		
		public function generateRestCount():uint 
		{
			return 1;// int(Math.random() * )
		}
		
		public function createShadow():void 
		{
			if (shadow && shadow.parent) {
				shadow.parent.removeChild(shadow);
				shadow = null;
			}
			if (textures && textures.animation.hasOwnProperty('shadow')) {
				shadow = new Bitmap(UserInterface.textures.shadow);
				addChildAt(shadow, 0);
				shadow.smoothing = true;
				if (textures.animation.shadow.alpha && textures.animation.shadow.scaleX && textures.animation.shadow.scaleY && textures.animation.shadow.x && textures.animation.shadow.y)
				{
					shadow.x = textures.animation.shadow.x - (shadow.width / 2);
					shadow.y = textures.animation.shadow.y - (shadow.height / 2);
					shadow.alpha = textures.animation.shadow.alpha;
					shadow.scaleX = textures.animation.shadow.scaleX;
					shadow.scaleY = textures.animation.shadow.scaleY;
				}
				else
				{
					shadow.x = 0;
					shadow.y = 10;
					shadow.alpha = 0.59;
					shadow.scaleX = 1;
					shadow.scaleY = 1;
				}
				
			}
		}
		
		public function rebuildShadow(params:Object = null):void 
		{
			var defParams:Object = {
				scale:1,
				alpha:1
			}
			if(params)
				for (var st:* in params) 
				{
					defParams[st] = params[st];
				}
			if (textures && textures.animation.hasOwnProperty('shadow')) 
			{
				shadow.x = textures.animation.shadow.x - (shadow.width / 2);
				shadow.y = textures.animation.shadow.y - (shadow.height / 2);
				shadow.alpha = defParams.alpha;
				shadow.scaleX = shadow.scaleY = defParams.scale;
			}
		}
		
		override public function get bmp():Bitmap 
		{
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0)
				return bitmap;
			if (multiBitmap && multiBitmap.bitmapData && multiBitmap.bitmapData.getPixel(multiBitmap.mouseX, multiBitmap.mouseY) != 0)
				return multiBitmap;
				
			return bitmap;
		}
		
		override public function set state(state:uint):void 
		{
			if (_state == state) return;
			
			/*switch(state) {
				case OCCUPIED: bitmap.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; break;
				case EMPTY: bitmap.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; break;
				case TOCHED: bitmap.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; break;
				case HIGHLIGHTED: bitmap.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; break;
				case IDENTIFIED: bitmap.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; break;
				case DEFAULT: bitmap.filters = []; break;
			}*/
			/*switch(state) {
				case OCCUPIED: this.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; this.bitmap.filters = []; break;
				case EMPTY: this.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; this.bitmap.filters = []; break;
				case TOCHED: this.bitmap.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; this.filters = []; break;
				case HIGHLIGHTED: this.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; this.bitmap.filters = []; break;
				case IDENTIFIED: this.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; this.bitmap.filters = []; break;
				case DEFAULT: this.filters = []; this.bitmap.filters = []; break;
			}*/
			switch(state) {
				case OCCUPIED: this.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; this.bitmap.filters = []; break;
				case EMPTY: this.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; this.bitmap.filters = []; break;
				case TOCHED: this.bitmap.filters = [new GlowFilter(glowingColor, 1, 6, 6, 7)]; this.filters = []; break;
				case HIGHLIGHTED: this.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; this.bitmap.filters = []; break;
				case IDENTIFIED: this.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; this.bitmap.filters = []; break;
				case DEFAULT: this.filters = []; this.bitmap.filters = []; break;
			}
			/*if (state == TOCHED && this is Hero)
			{
				this.bitmap.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)];
			}*/
			_state = state;
		}
		
		override public function uninstall():void 
		{
			if (tm != null) {
				tm.dispose();
			}
			clearTimeout(dialogTimeout);
			super.uninstall();
			//stopWalking();
		}
		
		public function beginLive():void {
			
		}
		public function stopLive():void {
			
		}
		public function rotateTo(target:*):void 
		{
			var side:int = WUnit.LEFT;
			if (this.x < target.x)
				side = WUnit.RIGHT;
			
			if (side == WUnit.RIGHT) {
				framesFlip = side;
				sign = -1;
				bitmap.scaleX = -1;
			}else{
				framesFlip = side;
				sign = 1;
				bitmap.scaleX = 1;
			}
			
			if (textures) 
				update();
			//bitmap.x = (frameObject.ox + ax) * sign;
		}
		
		
		
	}

}