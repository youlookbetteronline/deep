package ui 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Sine;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.AvaLoad;
	import core.Load;
	import core.Log;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import effects.BoostEffect;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import units.Animal;
	import units.Personage;
	import units.Techno;
	import units.Unit;
	import utils.Finder;
	import utils.TopHelper;
	import wins.BankSaleWindow;
	import wins.BanksWindow;
	import wins.BonusBankWindow;
	import wins.BonusOnlineWindow;
	import wins.CalendarWindow;
	import wins.CollectionBonusList;
	import wins.CollectionWindow;
	import wins.FriendsSocketWindow;
	import wins.InviteSocketWindow;
	import wins.LevelUpWindow;
	import wins.TopListWindow;
	import wins.TopWindow;
	import wins.TravelWindow;
	import wins.elements.BankMenu;
	import wins.GuestRewardsWindow;
	import wins.GuestRewardWindow;
	import wins.PersonageInfoWindow;
	import wins.ShopWindow;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import silin.utils.Color;
	//import units.Bear;
	import wins.JamWindow;
	import wins.PurchaseWindow;
	import wins.Window;	
	import ui.BottomPanel;

	public class UpPanel extends Sprite
	{
		public var avatarPanel:Sprite;
		public var guestWakeUpPanel:Sprite;
		public var guestButton:Button;
		public var inviteBttn:ImageButton;
		public var chairPlusBttn:ImageButton;
		public var basketPlusBttn:ImageButton;
		public var moxiePlusBttn:ImageButton;
		public var coinsPlusBttn:ImageButton;
		public var fantsPlusBttn:ImageButton;
		public var energyPlusBttn:ImageButton;
		public var robotPlusBttn:ImageButton;
		public var guestPlusBttn:ImageButton;
		public var zzzWakeBttn:ImageButton;
		public var calendarBttn:ImageButton;
		public var auctionBttn:ImageButton;
		public var bonusOnlineBttn:ImageButton;
		//public var rouletteBttn:ImageButton;
		//public var winterInformerBttn:ImageButton;		
		public var coinsBar:Bitmap;
		public var fantsBar:Bitmap;
		//public var robotBar:ImageButton;
		public var chairBar:Bitmap;
		public var timerBar:Bitmap;
		public var moxieBar:Bitmap;
		public var basketBar:Bitmap;
		public var energyBar:Bitmap;
		public var expBar:Bitmap;
		public var expIcon:Bitmap;
		public var guestBar:Bitmap;
		public var guestIcon:Bitmap;
		public var chairIcon:Bitmap;
		//public static var winterShopBttn:ImageButton;
		public var timerSprite:LayerX = new LayerX();
		public var chairSprite:LayerX = new LayerX();
		public var basketSprite:LayerX = new LayerX();
		public var moxieSprite:LayerX = new LayerX();
		public var discountSprite:LayerX = new LayerX();
		public var topSprite:LayerX = new LayerX();
		public var coinsSprite:LayerX = new LayerX();
		public var fantSprite:LayerX = new LayerX();
		public var robotSprite:LayerX = new LayerX();
		//public var cookiesContainer:LayerX = new LayerX();
		public var energySprite:LayerX = new LayerX();
		public var expSprite:LayerX = new LayerX();
		public var guestSprite:LayerX = new LayerX();
		public var iconsSprite:LayerX = new LayerX();
		public var ribbonSaleSprite:LayerX = new LayerX();	
		private var rewardContainer:LayerX = new LayerX();
		public var coinsIcon:Bitmap;
		public var moxieIcon:Bitmap;
		public var discountIcon:Bitmap;
		public var basketIcon:Bitmap;
		public var fantsIcon:Bitmap;
		private var timeToEnd:int = 0;
		public var favoriteButton:ImageButton;
		public var robotIcon:Bitmap;
		public var robotIcon2:Bitmap;
		public var robotIcon3:Bitmap;
		private var rewBttn:ImageButton;
		public var energyIcon:Bitmap;
		
		public var bubblesLeft:Bitmap;
		public var bubblesRight:Bitmap;
		
		/*public var cookiesIcon:Bitmap;
		public var cookiesIcon2:Bitmap;
		public var cookiesIcon3:Bitmap;*/
		
		//public var bearPanel:BearsPanel;
		
		private var bg:Bitmap;
		private var chairCounter:TextField;
		private var discountText:TextField;
		private var coinsCounter:TextField;
		private var fantsCounter:TextField;
		private var basketCounter:TextField;
		private var moxieCounter:TextField;
		private var dicountCounter:TextField;
		private var ribbonSaleText:TextField;
		private var timeSaleText:TextField;
		private var mapTimer:TextField;
		//private var robotCounter:TextField;
		//private var cookiesCounter:TextField;
		private var energyCounter:TextField;
		private var expCounter:TextField;
		private var levelCounter:TextField;
		private var guestActionCounter:TextField;
		public static var timeOfExpire:TextField;
		
		private const enerySliderWidth:int = 81;
		private const expSliderWidth:int = 148;
		
		private var energySlider:Sprite = new Sprite();
		private var expSlider:Sprite = new Sprite();
		
		public var leftCont:Sprite = new Sprite();
		public var rightCont:Sprite = new Sprite();
		
		private var help:LayerX;
		private var guestGlowContainer:LayerX = new LayerX;
		private var timer:Timer = new Timer(2000, 1);
		
		private var glowBg:Bitmap;
		private var optionItem:int = App.data.options['bankitem'];
		
		public var tresureIcons:Array = [];
		public var expireJson:Object;
		
		public var coinsBoost:BoostEffect;
		public var expBoost:BoostEffect;
		public var energyBoost:BoostEffect;
		
		public var confirmBttn:Button;
		
		public function hide():void {
			leftCont.visible = false;
			iconsSprite.visible = false;
			rightCont.visible = false;
			this.y = -200;
		}
		
		public function show2(tween:Boolean = true):void {
			if (tween) {
				TweenLite.to(this, 0.5, { y:0 } );
			}
		}
		
		public function UpPanel() 
		{
			bubblesLeft	= new Bitmap(UserInterface.textures.bubbles);//бульбашки
			bubblesRight	= new Bitmap(UserInterface.textures.bubbles2);//бульбашки
			
			coinsIcon	= new Bitmap(UserInterface.textures.goldenPearl);//иконка монет
			fantsIcon	= new Bitmap(UserInterface.textures.blueCristal);//иконка алмазов
			/*robotIcon	= new Bitmap(UserInterface.textures.robotIcon);
			robotIcon2	= new Bitmap(UserInterface.textures.robotIcon2);
			robotIcon3	= new Bitmap(UserInterface.textures.robotIcon3);*/
			energyIcon	= new Bitmap(UserInterface.textures.energyIcon);
			/*cookiesIcon	= new Bitmap(UserInterface.textures.cookie);
			cookiesIcon2	= new Bitmap(UserInterface.textures.cookie2);
			cookiesIcon3	= new Bitmap(UserInterface.textures.cookie3);*/
			
			//bearPanel 	= new BearsPanel();
			
			ribbonInterBankSale	= new Bitmap(UserInterface.textures.interBankSale);
			
			coinsBar	= new Bitmap(UserInterface.textures.moneyPanel);//бар монет
			chairBar	= new Bitmap(UserInterface.textures.moneyPanel);//бар монет
			basketBar	= new Bitmap(UserInterface.textures.moneyPanel);//бар монет
			moxieBar	= new Bitmap(UserInterface.textures.moneyPanel);//бар бодрости
			timerBar	= new Bitmap(UserInterface.textures.moneyPanel);
			fantsBar 	= new Bitmap(UserInterface.textures.moneyPanel);//бар алмазов
			//robotBar 	= new ImageButton(UserInterface.textures.workerPanel);
			energyBar 	= new Bitmap(UserInterface.textures.expPanel);//бар энергии
			expBar 		= new Bitmap(UserInterface.textures.expPanel);//бар опыта
			expIcon 	= new Bitmap(UserInterface.textures.expIcon);//иконка опыта
			chairIcon 	= new Bitmap(UserInterface.textures.chair_green);//иконка кресла
			basketIcon 	= new Bitmap(UserInterface.textures.basketIcon);//иконка кресла
			guestBar 	= new Bitmap(Window.textures.instCharBackingGuest);
			guestGlow 	= new Bitmap(Window.textures.glowingBackingNew);
			guestIcon 	= new Bitmap(UserInterface.textures.guestAction);
			moxieIcon 	= new Bitmap(new BitmapData(50, 50, true, 0x0));//иконка бодрости
			loadMoxieIcon();
			
			chairPlusBttn 	= new ImageButton(UserInterface.textures.coinsPlusBttn);//Плюс около кресла
			coinsPlusBttn 	= new ImageButton(UserInterface.textures.coinsPlusBttn);//Плюс около монет
			basketPlusBttn 	= new ImageButton(UserInterface.textures.coinsPlusBttn);//Плюс около монет
			moxiePlusBttn 	= new ImageButton(UserInterface.textures.fantsPlusBttn);//Плюс около бодрости
			coinsPlusBttn.name = "coins";
			fantsPlusBttn 	= new ImageButton(UserInterface.textures.fantsPlusBttn);
			fantsPlusBttn.name = "fants";
			
			energyPlusBttn 	= new ImageButton(UserInterface.textures.coinsPlusBttn);
			zzzWakeBttn 	= new ImageButton(UserInterface.textures.energyPlusBttn);
			
			robotPlusBttn 	= new ImageButton(UserInterface.textures.coinsPlusBttn);
			guestPlusBttn   = new ImageButton(UserInterface.textures.energyIcon);//Иконка энергии
			
			
			var serverDate:Date = new Date();
			serverDate.setTime((App.midnight + serverDate.timezoneOffset * 60 + 3600 * 12 + dateOffset * 86400) * 1000);
			var dayText:TextField = Window.drawText(String(serverDate.getDate()), {
				color:0x43343a,
				border:false,
				borderColor:0x7b4003,
				textAlign:"center",
				width: UserInterface.textures.calendarIcoNew.width,
				fontSize:24
			});
			
			var bd:BitmapData = new BitmapData(UserInterface.textures.calendarIcoNew.width, UserInterface.textures.calendarIcoNew.height, true, 0x0);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -1, 13);
			bd.draw(UserInterface.textures.calendarIcoNew);
			bd.draw(dayText, matrix);
			
			calendarBttn	= new ImageButton(bd);
			auctionBttn		= new ImageButton(UserInterface.textures.auctionIcon);
			
			//winterInformerBttn	= new ImageButton(UserInterface.textures.winterEventInformerIcon);
			
			//rouletteBttn   = new ImageButton(UserInterface.textures.winterEventInformerIcon);
			//rouletteBttn.addEventListener(MouseEvent.CLICK, onRouletteEvent);
			/*rouletteBttn.showGlowing();
			rouletteBttn.tip = function():Object {
				return {
					title:App.data.roulette[1].name,
					text:"А сюда нужна локаль"
				}
			}*/
			
			coinsBoost = new BoostEffect(-3, 6);
			expBoost = new BoostEffect(-22, 10);
			energyBoost = new BoostEffect(-8, 8,true);
			
			chairPlusBttn.tip =  function():Object { return { title:Locale.__e("flash:1489583354332") }; }
			basketPlusBttn.tip =  function():Object { return { title:Locale.__e("flash:1491904363422") }; }
			coinsPlusBttn.tip =  function():Object { return { title:Locale.__e("flash:1382952379813") }; }
			fantsPlusBttn.tip =  function():Object { return { title:Locale.__e("flash:1382952379814") }; }
			energyPlusBttn.tip =  function():Object { return { title:Locale.__e("flash:1382952379817") }; }
			robotPlusBttn.tip =  function():Object { return { title:Locale.__e("flash:1396336797272") }; }
			moxiePlusBttn.tip =  function():Object { return { title:Locale.__e("flash:1495726123584",[App.data.storage[App.data.storage[App.user.worldID].cookie[0]].title]) }; }
			
			coinsPlusBttn.addEventListener(MouseEvent.CLICK, onCoinsEvent);
			chairPlusBttn.addEventListener(MouseEvent.CLICK, onChairEvent);
			basketPlusBttn.addEventListener(MouseEvent.CLICK, onBasketEvent);
			moxiePlusBttn.addEventListener(MouseEvent.CLICK, onMoxieEvent);
			fantsPlusBttn.addEventListener(MouseEvent.CLICK, onRealEvent);
			energyPlusBttn.addEventListener(MouseEvent.CLICK, onEnergyEvent);
			//robotPlusBttn.addEventListener(MouseEvent.CLICK, onRobotEvent);
			guestPlusBttn.addEventListener(MouseEvent.CLICK, onGuestEvent);
			zzzWakeBttn.addEventListener(MouseEvent.CLICK, onWakeEvent);
			calendarBttn.addEventListener(MouseEvent.CLICK, onCalendarEvent);
			auctionBttn.addEventListener(MouseEvent.CLICK, onAuctionEvent);
			//winterInformerBttn.addEventListener(MouseEvent.CLICK, onWinterInformer);
			
			var textSettings:Object;
			
			//Кресло
			textSettings = {
				color:0xffffff,
				borderColor:0x0c4065,
				borderSize:2,
				fontSize:22,
				textAlign:"center"
			};
			
			chairCounter = Window.drawText(Numbers.moneyFormat(App.user.stock.count(Stock.CHAIR)), textSettings);
			chairCounter.width = 100;
			chairCounter.height = chairCounter.textHeight;
			
			basketCounter = Window.drawText(Numbers.moneyFormat(App.user.stock.count(Stock.BASKET)), textSettings);
			basketCounter.width = 100;
			basketCounter.height = basketCounter.textHeight;
			
			moxieCounter = Window.drawText(Numbers.moneyFormat(App.user.stock.count(App.data.storage[App.user.worldID].cookie[0])), textSettings);
			moxieCounter.width = 100;
			moxieCounter.height = moxieCounter.textHeight;
			
			//Монеты
			textSettings = {
				color:0xffffff,
				borderColor:0x0c4065,
				borderSize:2,
				fontSize:22,
				textAlign:"center"
			};
			
			coinsCounter = Window.drawText(Numbers.moneyFormat(App.user.stock.count(Stock.COINS)), textSettings);
			coinsCounter.width = 100;
			coinsCounter.height = coinsCounter.textHeight;
			
			textSettings = {
				color:0xffffff,
				borderColor:0x0c4065,
				fontSize:22,
				textAlign:"left"
			};
			
			App.user.currentGuestLimit = 0;
			guestActionCounter = Window.drawText(String(0)+'/'+String(App.user.currentGuestLimit), textSettings);
			guestActionCounter.width = 100;
			guestActionCounter.height = guestActionCounter.textHeight;		
			
			//Алмазы
			textSettings = {
				color:0xffffff,
				borderColor:0x0c4065,
				borderSize:2,
				fontSize:22,
				textAlign:"center"
			};
			
			fantsCounter = Window.drawText(Numbers.moneyFormat(App.user.stock.count(Stock.FANT)), textSettings);
			fantsCounter.width = 80;
			fantsCounter.height = fantsCounter.textHeight;

			/*textSettings = {
				color:0xfefdcf,
				borderColor:0x5e3613,
				fontSize:22,
				textAlign:"center"
			};
			
			robotCounter = Window.drawText("-/-", textSettings);
			robotCounter.width = 60;
			robotCounter.height = robotCounter.textHeight;
			var cookieAmount:String = '1';
			cookiesCounter = Window.drawText(cookieAmount, textSettings);
			cookiesCounter.width = 60;
			cookiesCounter.height = cookiesCounter.textHeight;*/
			
			//Энергия
			textSettings = {
				color:0xffffff,
				borderColor:0x0c4065,
				borderSize:2,
				fontSize:22,
				textAlign:"center"
			};
			
			energyCounter = Window.drawText(String(App.user.stock.count(Stock.FANTASY)), textSettings);
			energyCounter.width = 82;
			energyCounter.height = energyCounter.textHeight;
			
			//Опыт
			textSettings = {
				color			:0xffffff,
				borderColor		:0x0c4065,
				borderSize		:2,
				fontSize		:22,
				textAlign		:"center"
			};
			
			
			
			expCounter = Window.drawText(String(App.user.stock.count(Stock.EXP)), textSettings);
			expCounter.width = 148;
			expCounter.height = expCounter.textHeight;
			
			//Уровень
			textSettings = {
				fontSize		:22,
				textAlign		:"center",
				color			:0xf59208,
				width 			:110,
				borderSize		:0,
				shadowSize		:0.00001,
				sharpness		:0,
				fontBorder		:0,
				fontBorderGlow	:0,
				textShadow		:0
			};
			
			textSettings.border = true;
			textSettings.fontSize = 26;
			levelCounter = Window.drawText(String(App.user.level), textSettings);
			levelCounter.width = 32;
			levelCounter.height = levelCounter.textHeight;
			levelCounter.filters = [new DropShadowFilter(2.0, 45, 0, 0.5, 2.0, 2.0, 1.0, 3, true, false, false)];
			
			textSettings = {
				color			:0xffffff,
				borderColor		:0x0f0600,
				borderSize		:2,
				fontSize		:22,
				textAlign		:"center"
			};
			
			updateExperience();
			updateEnergy();
			//updateCookies();
			
			Size.size(moxieIcon, 40, 40);
			moxieIcon.smoothing = true;
			leftCont.addChild(moxieSprite);
			moxieSprite.addChild(moxieBar);
			moxieSprite.addChild(moxieCounter);
			moxieSprite.addChild(moxieIcon);
			moxieSprite.addChild(moxiePlusBttn);
			if (App.user.worldID == User.HALLOWEEN_MAP || App.user.worldID == User.SWEET_MAP)
				moxiePlusBttn.visible = false;
			else
				moxiePlusBttn.visible = true;
			moxieIcon.x = -moxieIcon.width / 2;
			moxieCounter.y = 5;
			moxiePlusBttn.x = 75;
			moxiePlusBttn.y = 0;
			
			moxieSprite.tip = function():Object {
				
				//var text:String = Locale.__e('flash:1489583448096');
				return {
					title:App.data.storage[App.data.storage[App.user.worldID].cookie[0]].title,
					text:App.data.storage[App.data.storage[App.user.worldID].cookie[0]].description
				}
			}
			
			Size.size(chairIcon, 42, 42);
			chairIcon.smoothing = true;
			leftCont.addChild(chairSprite);
			chairSprite.addChild(chairBar);
			chairSprite.addChild(chairCounter);
			chairSprite.addChild(chairIcon);
			chairSprite.addChild(chairPlusBttn);
			chairIcon.x = -chairIcon.width / 2;
			chairCounter.y = 5;
			chairPlusBttn.x = 75;
			chairPlusBttn.y = 0;
			
			chairSprite.tip = function():Object {
				return {
					title:App.data.storage[Stock.CHAIR].title,
					text:App.data.storage[Stock.CHAIR].description,
					timer:false
				}
			}
			
			Size.size(basketIcon, 52, 52);
			basketIcon.smoothing = true;
			//UserInterface.colorize(basketBar, 0xb6e340, .8);
			//basketBar.filters = [new GlowFilter(0xfff000, 0.5, 4, 4, 4, 1, true)];
			//basketSprite.filters = [new GlowFilter(0xfff000, 0.5, 5, 5, 2, 1, false)];
			basketIcon.filters = [new GlowFilter(0xffd03e, 0.8, 6, 6, 6, 2)];
			leftCont.addChild(basketSprite);
			basketSprite.addChild(basketBar);
			basketSprite.addChild(basketCounter);
			basketSprite.addChild(basketIcon);
			basketSprite.addChild(basketPlusBttn);
			basketIcon.x = -basketIcon.width / 2;
			basketIcon.y = 0;
			basketCounter.y = 5;
			basketPlusBttn.x = 75;
			basketPlusBttn.y = 0;
			
			basketSprite.tip = function():Object {
				
				var text:String = Locale.__e('flash:1491904231903');
				var timer:Boolean = false;
				return {
					title:App.data.storage[Stock.BASKET].title,
					text:text,
					timer:timer
				}
			}
			
			leftCont.addChild(ribbonSaleSprite);
			leftCont.addChild(coinsSprite);
			ribbonSaleSprite.visible = false;
			coinsSprite.mouseChildren = false;
			coinsSprite.addChild(coinsBar);
			coinsSprite.addChild(coinsIcon);
			coinsSprite.addChild(coinsBoost);
			coinsSprite.addChild(coinsCounter);
			coinsSprite.addChild(bubblesLeft);
			expSprite.addChild(bubblesRight);
			
			resize();
			
			coinsSprite.tip = function():Object {
				
				var text:String = Locale.__e('flash:1382952379825');
				var timer:Boolean = false;
				if (App.user.stock.data['463'] > App.time) {
					var percent:int = App.data.storage['463'].outs[Stock.COINS];
					text = Locale.__e('flash:1413277595939', [String(percent), TimeConverter.timeToStr(App.user.stock.data['463'] - App.time)]) + '\n' + text;
					timer = true;
				}
				
				return {
					title:Locale.__e('flash:1382969956057'),
					text:text,
					timer:timer
				}
			}
			coinsSprite.name = 'coins';
			coinsSprite.addEventListener(MouseEvent.CLICK, onCoinsEvent);
			
			leftCont.addChild(fantSprite);
			if (App.social == 'FB' && optionItem > 0)
				drawTopReward();
				
			if (App.user.openedRadarMaps.length > 0)
			{
				radarExpireTime = App.data.storage[App.user.openedRadarMaps[0]].expire[App.social];
				drawRadarIcon();
			}
				
			fantSprite.mouseChildren = false;
			fantSprite.addChild(fantsBar);
			fantSprite.addChild(fantsIcon);
			fantSprite.addChild(fantsCounter);
			fantSprite.tip = function():Object {
				return {
					title:Locale.__e('flash:1382952379826'),
					text:Locale.__e('flash:1382952379827')
				}
			}
			fantSprite.name = 'fants';
			fantSprite.addEventListener(MouseEvent.CLICK, onRealEvent);
				
			textSettings = {
				color:0xffffff,
				borderColor:0x0c4065,
				borderSize:2,
				fontSize:22,
				textAlign:"center"
			};
			
			mapTimer = Window.drawText('00:00:00', textSettings);
			mapTimer.width = timerBar.width;
			mapTimer.height = mapTimer.textHeight;
			mapTimer.y = (timerBar.height - mapTimer.height) / 2;
			
			timerSprite.mouseChildren = false;
			timerSprite.addChild(timerBar);
			timerSprite.addChild(mapTimer);
			timerSprite.tip = function():Object {
				return {
					title:Locale.__e('flash:1503303346504')
				}
			}
			leftCont.addChild(timerSprite);
			App.self.setOnTimer(mapTimerUpdate);
			
			//cookiesContainer.addChild(cookiesCounter);
			/*robotSprite.visible = false;//ВРЕМЕННО
			robotSprite.mouseChildren = false;
			robotSprite.addChild(robotBar);
			robotSprite.addChild(robotIcon);
			robotSprite.addChild(robotIcon2);
			robotSprite.addChild(robotIcon3);
			robotSprite.addChild(cookiesIcon);
			robotSprite.addChild(cookiesIcon2);
			robotSprite.addChild(cookiesIcon3);
			robotSprite.addChild(cookiesContainer);
			robotSprite.addChild(robotCounter);*/
			//robotSprite.addChild(cookiesCounter);
			
			/*robotSprite.tip = function():Object {
				return {
					title:Locale.__e('flash:1382952379828'),
					text:Locale.__e('flash:1382952379829')
				}
			}
			robotSprite.addEventListener(MouseEvent.CLICK, onRobotEvent);*/
			
			addChild(iconsSprite);
			iconsSprite.addChild(robotSprite);
			
			
			leftCont.addChild(coinsPlusBttn);
			leftCont.addChild(fantsPlusBttn);
			
			//iconsSprite.addChild(robotPlusBttn);
			//robotPlusBttn.visible = false;//ВРЕМЕННО
			//var timeAction:int = timeToEnd - App.time;
			//if (timeAction > 0)
			//{
				addBankSaleIcon();
			//}
			energySprite.tip = function():Object {
				var boostText:String = '';
				/*if (App.user.stock.data[Stock.MORE_ENERGY]&&App.user.stock.data[Stock.MORE_ENERGY]> App.time) {
					boostText = '\n' + '\n' + App.data.storage[Stock.MORE_ENERGY].title + '\n' + Locale.__e('flash:1396275298418', [TimeConverter.timeToStr(App.user.stock.data[Stock.MORE_ENERGY] - App.time)]);
				}
				if (App.user.stock.data[Stock.ENERGY_BOOM]&&App.user.stock.data[Stock.ENERGY_BOOM]> App.time) {
					boostText = '\n' + '\n' + App.data.storage[Stock.ENERGY_BOOM].title + '\n' + Locale.__e('flash:1396275298418', [TimeConverter.timeToStr(App.user.stock.data[Stock.ENERGY_BOOM] - App.time)]);
				}*/
				
				if (App.user.stock.count(Stock.FANTASY) < App.user.stock.maxEnergyOnLevel) {
					var time:int =  (Stock.energyRestoreSettings - Stock.diffTime/*(App.time - App.user.energy)*/);
					
					if (time <= 0) 
					{
						time = 0;
						//App.user.stock.diffTime--;
						//App.user.stock.checkEnergy();
					}
					
					return {
						title:Locale.__e('flash:1382952379830', [App.user.stock.count(Stock.FANTASY), App.user.stock.maxEnergyOnLevel]),
						text:Locale.__e('flash:1382952379831'),
						timerText: TimeConverter.timeToCuts(time, true, true),
						timer:true
					}
				}else{
					return {
						title:Locale.__e('flash:1382952379830',[App.user.stock.count(Stock.FANTASY), App.user.stock.maxEnergyOnLevel]),
						text:Locale.__e('flash:1382952379832'),
						timerText: boostText,
						timer:true
					}
				}
			};
			
			energySprite.addChild(energyBar);
			energySlider.mouseEnabled = false;
			energySprite.addChild(energySlider);
			energySprite.addChild(energyIcon);
			energySprite.addChild(energyBoost);
			energySprite.addChild(energyCounter);
			
			energyBoost.tip = function():Object {
				var boostText:String = '';
				if (App.user.stock.data[Stock.MORE_ENERGY]&&App.user.stock.data[Stock.MORE_ENERGY]> App.time) {
					boostText = '\n' + '\n' + App.data.storage[Stock.MORE_ENERGY].title + '\n' + Locale.__e('flash:1396275298418', [TimeConverter.timeToStr(App.user.stock.data[Stock.MORE_ENERGY] - App.time)]);
				}
				if (App.user.stock.data[Stock.ENERGY_BOOM]&&App.user.stock.data[Stock.ENERGY_BOOM]> App.time) {
					boostText = '\n' + '\n' + App.data.storage[Stock.ENERGY_BOOM].title + '\n' + Locale.__e('flash:1396275298418', [TimeConverter.timeToStr(App.user.stock.data[Stock.ENERGY_BOOM] - App.time)]);
				}
				
				if (App.user.stock.count(Stock.FANTASY) < App.user.stock.maxEnergyOnLevel) {
					var time:int =  (Stock.energyRestoreSettings - Stock.diffTime/*(App.time - App.user.energy)*/);
					
					if (time < 0) time = 0;
					
					return {
						title:Locale.__e('flash:1382952379830', [App.user.stock.count(Stock.FANTASY), App.user.stock.maxEnergyOnLevel]),
						text:Locale.__e('flash:1382952379831'),
						timerText:TimeConverter.timeToCuts(time, true, true),
						timer:true
					}
				}else{
					return {
						title:Locale.__e('flash:1382952379830',[App.user.stock.count(Stock.FANTASY), App.user.stock.maxEnergyOnLevel]),
						text:Locale.__e('flash:1382952379832'),
						timerText: boostText,
						timer:true
					}
				}
			};
			
			//energySprite.addEventListener(MouseEvent.CLICK, onEnergyEvent);
			guestPlusBttn.tip = function():Object {
				return {
					title:Locale.__e('flash:1424362259010')
					
				}
			};
			
			calendarBttn.tip = function():Object {
				return {
					title:Locale.__e('flash:1393413668177'),
					text:Locale.__e('flash:1393413718831')
				}
			}
			
			auctionBttn.tip = function():Object {
				return {
					title:Locale.__e('Аукцион')
					//text:Locale.__e('Купи')
				}
			}
			
			/*winterInformerBttn.tip = function():Object {
				return {
					title:Locale.__e('flash:1450436894233'),
					text:Locale.__e('flash:1450436973207')
				}
			}*/
			
			//Временно не скрыто
			//if (Config.admin)
			if (!App.isSocial('SP'))
				drawDiscount();
			drawTopContainer();
			addChild(calendarBttn);
			if (App.isSocial('FS'))
				addChild(auctionBttn);
				
			//if (App.isSocial('FS'))
			
			//calendarBttn.visible = false;
			
			/*rouletteBttn.x = calendarBttn.x - 80;
			rouletteBttn.y = calendarBttn.y - 5;
			if (Config.admin) addChild(rouletteBttn);*/
			
			/*if (App.isSocial('DM','VK','OK','MM','FS')) 
			{
				addChild(winterInformerBttn);
				winterInformerBttn.showGlowing();
			}*/
			
			// BonusOnline
			addBonusOnline();
			
			calendarBttn.x = App.self.stage.stageWidth - calendarBttn.width - 20;
			calendarBttn.y = expIcon.height ;
			auctionBttn.x = calendarBttn.x - auctionBttn.width - 5;
			auctionBttn.y = calendarBttn.y + (calendarBttn.height - auctionBttn.height) / 2;
			
			discountSprite.x = calendarBttn.x - discountSprite.width + 110;
			discountSprite.y = calendarBttn.y + (calendarBttn.height - discountSprite.height) / 2 + 5;
			
			topSprite.x = calendarBttn.x - topSprite.width - 20;
			topSprite.y = calendarBttn.y + (calendarBttn.height - topSprite.height) / 2 + 7;
			//winterInformerBttn.x = calendarBttn.x - 80;
			//winterInformerBttn.y = calendarBttn.y - 5;
			expSprite.mouseChildren = false;
			
			expSprite.tip = function():Object {
				
				var diffExp:int = App.data.levels[App.user.level + 1].experience || 0;
				diffExp -= App.user.stock.count(Stock.EXP);
				diffExp = diffExp > 0?diffExp:0;
				
				var text:String = Locale.__e('flash:1382952379834', [diffExp, App.user.level + 1]);
				var timer:Boolean = false;
				if (App.user.stock.data['464'] > App.time) {
					var percent:int = App.data.storage['464'].outs[Stock.EXP];
					text = Locale.__e('flash:1413277595939', [String(percent), TimeConverter.timeToStr(App.user.stock.data['464'] - App.time)]) + '\n' + text;
					timer = true;
				}
				
				return {
					title:Locale.__e('flash:1382952379833'),
					text:text,
					timer:timer
				}
			};
			
			rightCont.addChild(expSprite);
			expSprite.addEventListener(MouseEvent.CLICK, onKeyLevelShow);
			rightCont.addChild(energySprite);
			energySprite.addChild(energyPlusBttn);
			expSprite.addChild(expBar);
			expSprite.addChild(expSlider);
			expSprite.addChild(expCounter);
			expSprite.addChild(expIcon);
			expSprite.addChild(levelCounter);
			guestSprite.addChild(guestBar);			
			guestSprite.addChild(guestGlowContainer);
			guestSprite.addChild(guestPlusBttn);
			guestSprite.addChild(guestActionCounter);
			guestSprite.addChild(guestIcon);
			leftCont.addChild(guestSprite);			
			expSprite.addChild(expBoost);
			addChild(leftCont);
			addChild(rightCont);
			
			//Спрайт кресла
			chairSprite.x = (App.self.stage.stageWidth - chairSprite.width) / 2 - 20;
			chairSprite.y = 14;
			
			//Спрайт корзинки
			basketSprite.x = (App.self.stage.stageWidth - basketSprite.width) / 2 - 20;/*(App.self.stage.stageWidth - basketSprite.width) / 2 - 198*/;
			basketSprite.y = 14;
			
			//Спрайт бодрости
			moxieSprite.x = (App.self.stage.stageWidth - moxieSprite.width) / 2 - 20;/*(App.self.stage.stageWidth - basketSprite.width) / 2 - 198*/;
			moxieSprite.y = 14;
			
			//Спрайт монет
			coinsSprite.x = 20;
			coinsSprite.y = 14;
			
			coinsBar.x = 20;
			coinsBar.y = 0;
			
			//Текст
			coinsCounter.x = coinsBar.x -1;
			coinsCounter.y = coinsBar.y + 6;
			
			//Монетка
			coinsIcon.x = coinsBar.x - 20;
			coinsIcon.y = coinsBar.y - 1;
			
			//Бульбашки
			bubblesLeft.x = -12;
			bubblesLeft.y = -10;
			
			//Бульбашки 2
			bubblesRight.x = 80;
			bubblesRight.y = 0;
			
			//Плюс
			coinsPlusBttn.x = 119;
			coinsPlusBttn.y = 14;	
			
			//Спрайт алмазов
			fantSprite.x = 185;
			fantSprite.y = 15;	
			
			//Бесплатка банка
			rewardContainer.x = 285;
			rewardContainer.y = 0;
			
			fantsBar.x = 0;
			fantsBar.y = 0;
			
			//Алмаз
			fantsIcon.x = fantsBar.x - 20;
			fantsIcon.y = fantsBar.y - 3;
			
			//Текст
			fantsCounter.x = fantsBar.x + 10;
			fantsCounter.y = fantsBar.y + 6;
			
			//Плюс
			fantsPlusBttn.x = fantsBar.x + 260;
			fantsPlusBttn.y = fantsBar.y + 14;
			
			ribbonInterBankSale.x = 175;
			ribbonInterBankSale.y = 25;			
			
			/*robotBar.y = -19;
			
			robotIcon.x = robotBar.x;
			robotIcon.y = robotBar.y + 7;
			robotIcon2.x = robotIcon.x;
			robotIcon2.y = robotIcon.y;
			robotIcon3.x = robotIcon.x - 10;
			robotIcon3.y = robotIcon.y - 10;*/
			
			/*cookiesIcon.x = robotBar.x + robotBar.width - cookiesIcon.width;
			cookiesIcon.y = robotBar.y + 7;
			cookiesIcon2.x = cookiesIcon.x;
			cookiesIcon2.y = cookiesIcon.y;
			cookiesIcon3.x = cookiesIcon.x;
			cookiesIcon3.y = cookiesIcon.y;*/
			
			/*robotCounter.x = robotBar.x + (robotBar.width - robotCounter.width) / 2 - 64;
			robotCounter.y = robotBar.y + 17;*/
			
			/*cookiesCounter.x = robotBar.x + (robotBar.width - cookiesCounter.width) / 2 + 64;
			cookiesCounter.y = robotBar.y + 17;*/
			
			//Спрайт энергии
			energySprite.x = -170;
			energySprite.y = 16;
			
			//Бар энергии
			energyBar.x = 0;
			energyBar.y = 0;
			
			//Иконка энергии
			energyIcon.x = energyBar.x - 48;
			energyIcon.y = energyBar.y - 5;
			
			//Прогресс бар энергии
			energySlider.x = energyBar.x;
			energySlider.y = energyBar.y;
			
			//Текст энергии
			energyCounter.x = energyBar.x + 25;
			energyCounter.y = 4;
			
			//Кнопка докупки энергии
			energyPlusBttn.x = energyBar.x + 105;
			energyPlusBttn.y = energyBar.y - 3;
			
			//guestGlowContainer.addChild(guestGlow);
			guestGlow.scaleX = guestGlow.scaleY = 0.7;
			guestGlow.x = -guestGlow.width/2;
			guestGlow.y = -guestGlow.height/2;
			guestGlowContainer.x += 46;
			guestGlowContainer.y += 46;
			//guestGlowContainer.x = guestBar.x + (guestBar.width - guestGlowContainer.width) / 2;
			//guestGlowContainer.y = guestBar.y + (guestBar.height - guestGlowContainer.height) / 2;
			guestIcon.scaleX = guestIcon.scaleY = 0.45;
			guestIcon.x = 0;
			guestIcon.smoothing = true;
			
			guestActionCounter.x = guestIcon.x+guestIcon.width+0;
			guestActionCounter.y = guestBar.height - 0;
			guestIcon.y = guestActionCounter.y + (guestActionCounter.height - guestIcon.height) / 2;
			
			guestPlusBttn.x = 25;
			guestPlusBttn.y = 10;
			guestPlusBttn.scaleX = guestPlusBttn.scaleY = 0.8;
			guestPlusBttn.visible = false;
			robotSprite.y = 60;
			robotSprite.x = -30;
			
			//Спрайт опыта
			expSprite.y = 5;
			expSprite.x += 80;
			
			guestSprite.x = 10;
			guestSprite.y += 100;
			
			//Бар опыта
			expBar.x = -45;
			expBar.y = 10;
			
			//Таймер времени карты
			timerSprite.y = 15;
			
			//Иконка опыта
			expIcon.x = -95;
			expIcon.y = 5;
			
			//Текст опыта
			expCounter.x = (expBar.x + 70 - (expCounter.width)/2);
			expCounter.y = 13;
			
			//Прогресс бар опыта
			expSlider.x = expBar.x;
			expSlider.y = expBar.y;
			
			levelCounter.x = expIcon.x + 6;
			levelCounter.y = expIcon.y + 9;
			//levelCounter.visible = true;//ВРЕМЕННО? Ага!
			
			robotPlusBttn.x = robotSprite.x + 116;
			robotPlusBttn.y = robotSprite.y - 7;
			addEventListener(Event.ENTER_FRAME, rotate);
			guestSprite.visible = false;
			
			/*robotIcon2.visible = false;
			robotIcon3.visible = false;
			cookiesIcon.visible = false;
			cookiesIcon2.visible = false;
			cookiesIcon3.visible = false;*/
			//drawInvitetoMap();
			//createWinterShop();
		}
		
		private function drawDiscount():void 
		{
			var sID:int = App.data.options.bonusBankItem;
			var discountBack:Shape = new Shape();
			discountBack.graphics.beginFill(0xffffff, 1);
			discountBack.graphics.drawRect(0, 0, 80, 42);
			discountBack.graphics.endFill();
			discountSprite.addChild(discountBack);
			
			var maska:Shape = new Shape();
			maska.graphics.beginFill(0x000000, .9);
			maska.graphics.drawRect(0, 0, 120, 42);
			maska.graphics.endFill();
			maska.cacheAsBitmap = true;
			discountBack.cacheAsBitmap = true;
			maska.filters = [new BlurFilter(20, 0, 20)];
			maska.x = discountBack.x - 70;
			discountSprite.addChild(maska);
			discountBack.mask = maska;
			
			var discountIcon:Bitmap;
			var backDiscount:Bitmap = new Bitmap(Window.textures.starBacking);
			Size.size(backDiscount, 50, 50);
			backDiscount.smoothing = true;
			backDiscount.filters = [new GlowFilter(0xffffff, 1, 4, 4, 10, 1)];
			backDiscount.x = -15;
			discountSprite.addChild(backDiscount);
			
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), function(data:Bitmap):void{
				discountIcon = new Bitmap(data.bitmapData);
				Size.size(discountIcon, 28, 28);
				discountIcon.smoothing = true;
				discountIcon.filters = [new GlowFilter(0xffffff, 1, 2, 2, 10, 1)];
				discountIcon.x = backDiscount.x + (backDiscount.width - discountIcon.width) / 2;
				discountIcon.y = backDiscount.y + (backDiscount.height - discountIcon.height) / 2;
				discountSprite.addChild(discountIcon);
			})
			
			discountText = Window.drawText(String(App.user.stock.count(sID)), {
				color:		0xffe610,
				borderColor:0x603024,
				textAlign:	"left",
				fontSize:	30
			})
			discountText.x = backDiscount.x + backDiscount.width + 6;
			discountText.y = backDiscount.y + (backDiscount.height - discountText.height) / 2 + 1;
			discountSprite.addChild(discountText);
			addChild(discountSprite);
			
			discountSprite.addEventListener(MouseEvent.CLICK, onDiscountClick)
			discountSprite.tip = function():Object{
				return {
					title:	App.data.storage[sID].title,
					text:	App.data.storage[sID].description
				}
			}
		}
		
		private function drawTopContainer():void 
		{
			var topBacking:Bitmap = new Bitmap(UserInterface.textures.topBacking);
			Size.size(topBacking, 55, 55);
			topBacking.smoothing = true;
			topSprite.addChild(topBacking);
			
			topSprite.addEventListener(MouseEvent.CLICK, onTopClick)
			//addChild(topSprite);
		}
		
		private function onTopClick(e:MouseEvent):void 
		{
			new TopListWindow({
				
			}).show();
		}
		
		private function onDiscountClick(e:MouseEvent):void 
		{
			new BonusBankWindow({
				description: Locale.__e('flash:1513337390170', App.data.storage[App.data.options.bonusBankItem].title)
			}).show();
		}
		
		private var panelMat:int = 0;
		private function loadMoxieIcon():void
		{
		
			if (panelMat != App.data.storage[App.user.worldID].cookie[0])
			{
				//var self:* = this;
				panelMat = App.data.storage[App.user.worldID].cookie[0];
				Load.loading(Config.getIcon(App.data.storage[panelMat].type, App.data.storage[panelMat].preview),function(data:*):void{
					moxieIcon.bitmapData = data.bitmapData;
					Size.size(moxieIcon, 40, 40);
					moxieIcon.smoothing = true;
					moxieIcon.x = -moxieIcon.width / 2;
					resize();
				});
			}
		}
		
		public var radarTimerText:TextField;
		public var radarExpireTime:uint;
		public var radarSprite:Sprite;
		private function drawRadarIcon():void
		{
			if (radarExpireTime < App.time)
				return;
			radarSprite = new Sprite();
			var bmapData:BitmapData = new BitmapData(UserInterface.textures.radarBacking.width, 80, true, 0x0);
			
			var radarBacking:Bitmap = new Bitmap(bmapData);
			radarBacking.bitmapData.draw(UserInterface.textures.radarBacking, new Matrix(1, 0, 0, 1, 0, bmapData.height - UserInterface.textures.radarBacking.height));
			var blackCircle:Shape = new Shape();
			blackCircle.graphics.beginFill(0, .4);
			blackCircle.graphics.drawCircle(0, 0, 10);
			blackCircle.graphics.endFill();
			var matrix:Matrix = new Matrix(1, 0, 0, 1, bmapData.width / 2, 110 + bmapData.height - radarBacking.height / 2);
            matrix.scale(1, .4);
			
			radarBacking.bitmapData.draw(blackCircle, matrix);
			Load.loading(Config.getIcon('Lands', 'radar'), function(data:*):void{
				//var _bmap:Bitmap = new Bitmap(data.bitmapData)
				//Size.size(_bmap, 30, 45);
				//_bmap.cacheAsBitmap = true;
				var newBdata:BitmapData = Size.scaleBitmapData(data.bitmapData, .7);
				radarBacking.bitmapData.draw(newBdata, new Matrix(1, 0, 0, 1, (bmapData.width - newBdata.width) / 2, bmapData.height  - newBdata.height - 20));
			});
			var radarBttn:ImageButton = new ImageButton(radarBacking.bitmapData);
			radarBttn.addEventListener(MouseEvent.CLICK, onRadarEvent);
			radarSprite.addChild(radarBttn);
			
			var timerBg:Bitmap = Window.backingHorizontal(40, 'travelBg');
			timerBg.x = (radarBttn.width - timerBg.width) / 2;
			timerBg.y = 6 + radarBttn.height - timerBg.width / 2;
			radarSprite.addChild(timerBg);
			
			//var finalTime:uint = App.data.storage[App.user.openedRadarMaps[0]].expire[App.social];
			
			radarTimerText =  Window.drawText(TimeConverter.timeToDays( App.data.storage[App.user.openedRadarMaps[0]].expire[App.social] - App.time), {
			  color:0xfeee9a,
			  borderColor:0x552c00,
			  textAlign:"center",
			  fontSize:14,
			  width:timerBg.width - 4
			});
			
			radarTimerText.y = timerBg.y + 3;
			radarTimerText.x = timerBg.x + 2;
			radarSprite.addChild(radarTimerText);
				
			App.self.setOnTimer(radarTimerUpdate);
			//timerCont.addChild(timerText);
			//timerCont.y = 14;
			//addChild(timerCont);
		
			//radarSprite.addChild(radarBacking);
			radarSprite.x = 100;
			radarSprite.y = 60;
			addChild(radarSprite);
		}
		
		private function onRadarEvent(e:* = null):void
		{
			new TravelWindow({find:App.user.openedRadarMaps[0], popup: true}).show();
		}
		
		private function radarTimerUpdate():void
		{
			var time:int = radarExpireTime - App.time;
			if (time <= 0)
			{
				if(radarSprite && radarSprite.parent)
					radarSprite.parent.removeChild(radarSprite);
				App.self.setOffTimer(radarTimerUpdate);
			}
			radarTimerText.text = TimeConverter.timeToDays(time);
		}
		
		private function mapTimerUpdate():void
		{
			if (!App.owner || !App.owner.world || !App.owner.loaded || App.user.mode != User.PUBLIC)
				return;
			if (App.user.data['publicWorlds'] && App.user.data['publicWorlds'].hasOwnProperty(App.owner.worldID))
			{
				if (App.user.data['publicWorlds'][App.owner.worldID] == 0)
				{
					time = App.data.storage[App.owner.worldID].duration;
					mapTimer.text = TimeConverter.timeToDays(time);
					return;
				}
			}else{
				App.user.data['publicWorlds'][App.owner.worldID] = 0;
				return;
			}
			
			var time:int = App.user.data['publicWorlds'][App.owner.worldID]/*App.owner.world.data.expire*/ - App.time;
			if (time <= 0)
			{
				if(timerSprite)
					timerSprite.visible = false;
				//App.self.setOffTimer(mapTimerUpdate);
			}
			mapTimer.text = TimeConverter.timeToDays(time);
		}
		
		private function drawTopReward():void
		{
			var glow:Bitmap = new Bitmap(Window.textures.glowingBackingNew);
			glow.y = 0;
			glow.x = 0;
			Size.size(glow, 70, 70);
			//glow.filters = [new BlurFilter(10, 10, 1)];
			rewardContainer.addChild(glow);
			Load.loading(Config.getIcon(App.data.storage[optionItem].type, App.data.storage[optionItem].preview), function(data:*):void{
				//rewBtm.bitmapData = data.bitmapData;
				var rewBttn:ImageButton = new ImageButton(data.bitmapData);
				Size.size(rewBttn, 40, 40);
				rewBttn.x = (glow.width - rewBttn.width) / 2 + 2;
				rewBttn.y = (glow.height - rewBttn.height) / 2;
				rewardContainer.addChild(rewBttn);
				rewBttn.addEventListener(MouseEvent.CLICK, rewBttnEvent);
			});
			
			
			/*Load.loading(Config.getIcon(App.data.storage[83].type, App.data.storage[83].preview), function(data:*):void{
				rewBtm.bitmapData = data.bitmapData;
				Size.size(rewBtm, 70, 70);
				rewBtm.smoothing = true;
				rewBtm.x = glow.x + (glow.width - rewBtm.width) / 2;
				rewBtm.y = glow.y + (glow.height - rewBtm.height) / 2;
			});*/
			
			
			var rewText:TextField = Window.drawText(Locale.__e('flash:1493383312549'),{
				fontSize:16,
				textAlign:"center",
				color:0xff0000,
				borderColor:0xffffff,
				textLeading: 8,
				multiline:true,
				width:90
			});
			rewText.x = glow.x + (glow.width - rewText.width) / 2;
			rewText.y = glow.y + glow.height - 15;
			
			rewardContainer.addChild(rewText);
			
			leftCont.addChild(rewardContainer);
			
			//item.reward
			
			rewardContainer.tip = function():Object 
				{ 
					return {
						title:App.data.storage[83].title,
						text:App.data.storage[83].description
					};
				};
		}
		
		public function rewBttnEvent(e:MouseEvent = null):void
		{
			new BanksWindow({
				glowItem:true
			}).show();
		}
		/*private function createWinterShop():void {
			disposeWinterShop();
			
			var icon:Bitmap = new Bitmap(new BitmapData(75,75, true, 0), 'auto', true);
			winterShopBttn = new ImagesButton(icon.bitmapData);
			
			winterShopBttn.tip = function():Object { 
				return {
					title:Locale.__e("flash:1448624042373"),
					text:Locale.__e("flash:1449486229836")
				};
			};			
			
			if (ribbonSaleSprite.visible) 
			{
				winterShopBttn.y = App.self.stage.x + 105;
				winterShopBttn.x = coinsSprite.x + 170;
				timeOfExpire.x = winterShopBttn.x - 40;
				timeOfExpire.y = winterShopBttn.y + 55;
			} else {
				winterShopBttn.y = coinsSprite.y - 10;
				winterShopBttn.x = coinsSprite.x + 200;
			}
			
			winterShopBttn.addEventListener(MouseEvent.CLICK, onWinterShop);
			
			Load.loading(Config.getImageIcon("quests/icons", "winterEventShop"), function(data:Bitmap):void {
				winterShopBttn.bitmapData = data.bitmapData;
				
				winterShopBttn.initHotspot();
			});
			
			if (App.isSocial('DM','VK','FS','MM','OK','YB','MX','AI','HV','FB','NK','YN','SP'))
			{
				leftCont.addChild(winterShopBttn);
				winterShopBttn.showGlowing();
			}
			
			winterShopBttn.visible = false;
			
			if (!App.user.quests.tutorial) 
			{
				winterShopBttn.visible = true;
			}
		
			drawTimer();
		}*/
		
		/*public function drawTimer():void 
		{			
			timeOfExpire = Window.drawText("%m.%d %H:%i", {
				width:			150,
				textAlign:		'center',
				fontSize:		20,
				color:			0xffffff,
				borderColor:	0x292971
			});
			
			if (App.isSocial('DM','VK','FS','MM','OK','YB','MX','AI','HV','FB','NK','YN','SP'))
			{
				leftCont.addChild(timeOfExpire);
			}			
			timeOfExpire.x = winterShopBttn.x - 40;
			timeOfExpire.y = winterShopBttn.y + 55;
			
			winterTimer();
			App.self.setOnTimer(winterTimer);
		}*/
		
		/*private function winterTimer():void 
		{		
			var time:uint = 0;
			var currentDate:Date = new Date();
			expireJson = [];
			for (var i:* in expireJson) {
				if (i == App.SOCIAL) 
				{
					time = expireJson[i].time;
				}
			}
			
			if (timeOfExpire) 
			{
				timeOfExpire.text = TimeConverter.timeToDays((time < App.time) ? 0 : (time - App.time));
				
			}		
		}*/
		
		/*private function disposeWinterShop():void {
			if (winterShopBttn) {
				winterShopBttn.removeEventListener(MouseEvent.CLICK, onWinterShop);
				leftCont.removeChild(winterShopBttn);
				winterShopBttn = null;
			}
		}
		
		private function onWinterShop(e:MouseEvent = null):void {
			winterShopBttn.hideGlowing();
			var eventShop:EventShopWindow = new EventShopWindow( {
				popup: true
			}
			);				
			eventShop.show();			
			return;
			new EventShopWindow({}).show();
		}*/
		
		public function addBonusOnline():void
		{
			if (App.user.mode == User.OWNER && !App.user.quests.tutorial && bonusOnlineBttn && App.user.worldID != User.HOLIDAY_LOCATION && App.user.worldID != User.TRAVEL_LOCATION)
				bonusOnlineBttn.visible = true;
			
			if (!bonusOnlineBttn && App.user.bonusOnline.showIcon && !App.user.quests.tutorial && App.user.mode == User.OWNER && App.user.worldID != User.AQUA_HERO_LOCATION) 
			{
				bonusOnlineBttn = new ImageButton(UserInterface.textures.bonusIco);
				bonusOnlineBttn.addEventListener(MouseEvent.CLICK, onBonusOnlineEvent);
				bonusOnlineBttn.x = (App.self.stage.stageWidth - bonusOnlineBttn.width)/2 - 20;
				bonusOnlineBttn.y = 0;
				bonusOnlineBttn.tip = function():Object {
					return {
						title:	Locale.__e('flash:1447939811359'),
						text:	Locale.__e('flash:1470747600500')
					}
				}
				if (App.user.mode == User.OWNER)
					addChild(bonusOnlineBttn);
					
				if (App.user.mode == User.GUEST)
					removeChild(bonusOnlineBttn);
				
				var bonusOnlineLabel:TextField = Window.drawText('0:00:00', {
					color			:0xffffff,
					borderColor		:0x66221a,
					width			:70,
					fontSize		:(App.isJapan()) ? 18 : 20,
					textAlign		:'center'
				});
				
				bonusOnlineLabel.y = 45;
				bonusOnlineLabel.x = 12;
				bonusOnlineBttn.addChild(bonusOnlineLabel);
				
				var itemPreview:int = 0;
				var bitmap:Bitmap = new Bitmap(UserInterface.textures.energyIconSmall);
				var bonusOnlineRevardLabel:TextField;
				var bonusOnlineUpdate:Function = function():void {
					if (App.user.mode == User.GUEST || App.user.quests.tutorial || App.user.worldID == User.HOLIDAY_LOCATION || (moxieSprite && moxieSprite.visible == true)){
						bonusOnlineBttn.visible = false;
						return;
					}
					else{
						bonusOnlineBttn.visible = true;
					}
					
					if (bonusOnlineBttn)
					{
						bonusOnlineBttn.visible = App.user.bonusOnline.showIcon;
						if (!App.user.bonusOnline.showIcon)
						{
							bonusOnlineBttn.hideGlowing();
							//bonusOnlineBttn.hidePointing();
							App.self.setOffTimer(bonusOnlineUpdate);
						}
					}
					var time:int = App.user.bonusOnline.nextTimePoint /*- App.user.bonusOnline.visitTime*/;
					//if (time > 14400) time = 14400;
					bonusOnlineLabel.text = TimeConverter.timeToStr(time);
					if (App.user.bonusOnline.canTakeReward && !App.user.quests.tutorial)
					{
						//if (!bonusOnlineBttn.__hasPointing)
							//bonusOnlineBttn.showPointing('bottom', 0, 100, bonusOnlineBttn.parent);
						if (!bonusOnlineBttn.__hasGlowing)
							bonusOnlineBttn.showGlowing();
						bonusOnlineLabel.visible = false;
						if (itemPreview == 0)
						{
							var sID:int = Numbers.firstProp(App.user.bonusOnline.info.devel.obj[4]).key;
							var count:int = Numbers.firstProp(App.user.bonusOnline.info.devel.obj[4]).val;
							itemPreview = sID;
							
							bonusOnlineRevardLabel = Window.drawText('+ ' + count, {
								color:			0xffffff,
								borderColor:	0x66221a,
								width:			70,
								fontSize:		20,
								textAlign:		'left'
							});
							bonusOnlineRevardLabel.y = 45;
							bonusOnlineRevardLabel.x = 20;
							bonusOnlineBttn.addChild(bonusOnlineRevardLabel);
							
							Size.size(bitmap, 23, 23);
							bitmap.smoothing = true;
							bitmap.y = 45;
							bitmap.x = bonusOnlineRevardLabel.x + bonusOnlineRevardLabel.textWidth + 2;
							bonusOnlineBttn.addChild(bitmap);
						}
						
						if (bitmap && bonusOnlineRevardLabel)
						{
							bitmap.visible = true;
							bonusOnlineRevardLabel.visible = true;
						}
					}
					else
					{
						if (bitmap && bonusOnlineRevardLabel)
						{
							bitmap.visible = false;
							bonusOnlineRevardLabel.visible = false;
						}
						itemPreview = 0;
						bonusOnlineLabel.visible = true;
						bonusOnlineBttn.hideGlowing();
						//bonusOnlineBttn.hidePointing();
					}
				}
				App.self.setOnTimer(bonusOnlineUpdate);
			}
		}
		
		public function addBankSaleIcon():void
		{
			if (ribbonSaleText && ribbonSaleText.parent)
				ribbonSaleText.parent.removeChild(ribbonSaleText);
			if (timeSaleText && timeSaleText.parent)
				timeSaleText.parent.removeChild(timeSaleText);
				
			var textSettings:Object = {
				color			:0xf9ff47,
				borderColor		:0x5b3d0e,
				borderSize		:3,
				fontSize		:26,
				textAlign		:"center"
			};	
			if(App.data.money && App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1)
					timeToEnd = App.data.money.date_to;
			else if (App.user.money > App.time)
					timeToEnd = App.user.money;
					
			ribbonSaleText = Window.drawText(Locale.__e('flash:1396521604876'), textSettings);		
			timeSaleText = Window.drawText(TimeConverter.timeToStr(timeToEnd - App.time), {
					color:0xffd950,
					borderColor:0x402016,
					textAlign:"center",
					autoSize:"center",
					fontSize:16
				});
			ribbonSaleSprite.addChild(ribbonInterBankSale);
			ribbonSaleSprite.addChild(ribbonSaleText);
			ribbonSaleSprite.addChild(timeSaleText);
			ribbonSaleSprite.addEventListener(MouseEvent.CLICK, onRealEvent);
			App.self.setOnTimer(updateTimeAction);
			
			
			resize();
			
		}
		public function updateTimeAction():void
		{
			var timeAction:int = timeToEnd - App.time;
			if (timeAction < 0)
			{
				timeAction = 0;
				App.self.setOffTimer(updateTimeAction);
				resize();
				//actionCont.visible = false;
				//contentChange();
				return;
			}
			timeSaleText.text = TimeConverter.timeToStr(timeAction);
		}
		
		public var dateOffset:int = 0;
		
		/*private function onRouletteEvent(e:MouseEvent):void 
		 * {
			if (!App.user.quests.tutorial)  {
				new RouletteWindow().show();
			}
		}*/
		
		private function onCalendarEvent(e:MouseEvent):void 
		{
			if (!App.user.quests.tutorial) 
			{
				var serverDate:Date = new Date();
				
				serverDate.setTime((App.midnight + serverDate.timezoneOffset * 60 + 3600 * 12 + dateOffset * 86400) * 1000);
				var month:uint = serverDate.getMonth()+1;
				var year:uint = serverDate.getFullYear();
				
				if (App.user.calendar[year].hasOwnProperty(month)) 
				{				
					new CalendarWindow().show();				
				}				
			}			
		}
		
		private function onAuctionEvent(e:MouseEvent):void 
		{
			App.user.auction.openAuctionWindow();			
		}
		
		private function onBonusOnlineEvent(e:MouseEvent):void
		{
			if (!App.user.quests.tutorial) 
			{
				new BonusOnlineWindow().show();
			}
		}
		
		/*private function onWinterInformer(e:MouseEvent):void 
		{
			new FiestaWinterWindow().show();
			winterInformerBttn.hideGlowing();
		}*/
		
		public function hideExpedition(hide:Boolean = true):void {
			robotSprite.visible = hide;
			robotPlusBttn.visible = hide;
			energyPlusBttn.visible = hide;
			//winterShopBttn.visible = hide;	
			//timeOfExpire.visible = hide;
		}
		
		private function onGuestEvent(e:MouseEvent):void 
		{
			App.ui.upPanel.guestSprite.hidePointing();
			App.ui.upPanel.guestSprite.hideGlowing();	
			new GuestRewardsWindow().show();
			return;
		}
		
		private function onWakeEvent(e:MouseEvent):void 
		{
			
		}
		
		private function rotate(e:Event):void {
			guestGlowContainer.rotation += 1;	
		}
		
		public var rel:Array = new Array();
		
		public function updateGuestBar():void 
		{
			
			rel = [];
			var numb:int = 0;
			var currentNumb:int = 0;
			for each (var material:* in App.data.storage) {
				
				if (material.type == 'Guests') {
					if (App.self.getLength(material.outs) > 1)
					{
						delete(material.outs[Stock.COUNTER_GUESTFANTASY])
					}
					rel[numb] = material;
					numb++;
				}
			}
			
			rel.sortOn('count', Array.NUMERIC);
			
			for (var j:int = 0; j < rel.length; j++ ) 
			{
				if (rel[j].count<=App.user.stock.data[Stock.COUNTER_GUESTFANTASY]) 
				{
					currentNumb = j + 1;
					
				}
			}
			
			if (currentNumb==rel.length||App.user.currentGuestLimit!=rel[currentNumb].count) 
			{
				
				if (App.user.currentGuestLimit > 0)
				{
					if (rel[currentNumb-1].count==App.user.stock.data[Stock.COUNTER_GUESTFANTASY]) 
					{
						new GuestRewardWindow().show();		
						new GuestRewardsWindow().show();
						if (currentNumb==rel.length) 
						{
							App.user.stock.add(Stock.COUNTER_GUESTFANTASY, 1);	
						}
					}				
				}
				
				if (currentNumb>rel.length-1) 
				{
					currentNumb = rel.length - 1;
				}
				
				for (var sid2:* in rel[currentNumb].outs){
					break
				}
				Load.loading(Config.getIcon(App.data.storage[sid2].type, App.data.storage[sid2].preview), onLoadImage);				
				
				App.user.currentGuestLimit = rel[currentNumb].count;
				App.user.currentGuestReward = rel[currentNumb];
			
			}
			if (App.user.stock.data[Stock.COUNTER_GUESTFANTASY]<=rel[rel.length-1].count) 
			{
				guestActionCounter.text = String((App.user.stock.data.hasOwnProperty(Stock.COUNTER_GUESTFANTASY))?(App.user.stock.data[Stock.COUNTER_GUESTFANTASY]):0) + '/' + String(App.user.currentGuestLimit);
				if (App.user.stock.data[Stock.COUNTER_GUESTFANTASY] == rel[rel.length - 1].count) {
					guestGlowContainer.visible = false;
					guestPlusBttn.tip = function():Object {
						return {
							title:Locale.__e('flash:1425398780779')
						}
					};	
				}				
			}else 
			{
				guestActionCounter.text = String(rel[rel.length-1].count) + '/' + String(App.user.currentGuestLimit);
				if (App.user.stock.data[Stock.COUNTER_GUESTFANTASY] >= rel[rel.length - 1].count) {
					guestGlowContainer.visible = false;
					guestPlusBttn.tip = function():Object {
						return {
							title:Locale.__e('flash:1425398780779')
						}
					};	
				}
			}
			if (!App.user.stock.data.hasOwnProperty(Stock.COUNTER_GUESTFANTASY)) 
			{
				guestActionCounter.text = String('0'+'/'+rel[0].count)	;
			}
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_GUEST_FANTASY));			
		}
		
		private var confirmCallback:Function;
		//public var confirmBttn:Button;
		public function showConfirm(callback:Function = null, hideOnClick:Boolean = true):void {
			confirmCallback = callback;
			this.hideOnClick = hideOnClick;
			
			if (confirmBttn) return;
			
			confirmBttn = new Button( {
				width: 		160,
				height:		44,
				caption:	Locale.__e('flash:1382952379978')
			});
			
			confirmBttn.x = (App.self.stage.stageWidth - confirmBttn.width) / 2;
			if ( cancelBttn )
			{
				cancelBttn.x += cancelBttn.width /2 + 10;
				confirmBttn.x -= confirmBttn.width/2 - 10;
			}
			confirmBttn.y = 176;
			confirmBttn.addEventListener(MouseEvent.CLICK, onConfirm);
			addChild(confirmBttn);
		}
		private function onConfirm(e:MouseEvent):void {
			if (confirmCallback != null) confirmCallback();
			if (hideOnClick) hideCancel();
		}
		
		private var cancelCallback:Function;
		private var hideOnClick:Boolean = true;
		public var cancelBttn:Button;
		public function showCancel(callback:Function = null, hideOnClick:Boolean = true):void {
			cancelCallback = callback;
			this.hideOnClick = hideOnClick;
			
			if (cancelBttn) return;
			
			cancelBttn = new Button( {
				width: 		160,
				height:		44,
				caption:	Locale.__e('flash:1396963190624')
			});
			cancelBttn.x = (App.self.stage.stageWidth - cancelBttn.width) / 2;
			cancelBttn.y = 176;
			cancelBttn.addEventListener(MouseEvent.CLICK, onCancel);
			addChild(cancelBttn);
		}
		
		public function hideCancel():void {
			if (cancelBttn) {
				if (contains(cancelBttn)) removeChild(cancelBttn);
				cancelBttn.removeEventListener(MouseEvent.CLICK, onCancel);
				cancelBttn.dispose();
				cancelBttn = null;
			}
			if (confirmBttn)
			{
				if (contains(confirmBttn)) removeChild(confirmBttn);
				confirmBttn.removeEventListener(MouseEvent.CLICK, onConfirm);
				confirmBttn.dispose();
				confirmBttn = null;
			}
		}
		
		private function onCancel(e:MouseEvent):void {
			if (cancelCallback != null) cancelCallback();
			if (hideOnClick) hideCancel();
		}
		
		private function onLoadImage(data:Object):void
		{
			guestPlusBttn.visible = true;
			var offset:int = 30;
			guestPlusBttn.bitmapData = data.bitmapData;
				Size.size(guestPlusBttn, guestBar.width - 25, guestBar.width - 25);
				guestPlusBttn.x = guestBar.x + (guestBar.width - guestPlusBttn.width) / 2;
				guestPlusBttn.y = guestBar.y + (guestBar.height - guestPlusBttn.height) / 2;
				guestPlusBttn.visible = true;
		}
		
		public function onRealEvent(e:MouseEvent):void
		{
			if (App.user.quests.tutorial)
				return;
			
			BankMenu._currBtn = BankMenu.REALS;
			BanksWindow.history = {section:'Reals',page:0};
			onBankEevent(e);
		}
		
		public function onChairEvent(e:MouseEvent = null):void 
		{
			new ShopWindow(Quests.targetSettings).show();
		}
		public function onCoinsEvent(e:MouseEvent = null):void 
		{
			if (App.user.quests.tutorial)
				return;
			
			BankMenu._currBtn = BankMenu.COINS;
			BanksWindow.history = {section:'Coins',page:0};
			onBankEevent(e);
		}
		
		private function updateTimer():void {
			var time:int = timeToActionEnd - App.time;
			if (time <= 0) {
				App.self.setOffTimer(updateTimer);
				moneyLabelCont.visible = false;
				timeToActionEnd = 0;
				return;
			}
			timerText.text = TimeConverter.timeToStr(time);
		}
		
		/*private function onBearBarOver(e:MouseEvent):void{
			bearPanel.show();
		}*/
		
		/*private function onBearBarOut(e:MouseEvent):void {
			bearPanel.hide();
		}*/
		
		public var btmp:Bitmap;
		public var avatar:Bitmap;
		public var avatarBacking:Bitmap;
		public var avatarSprite:Sprite;
		public function showAvatar():void {
			
			hideAvatar();
			
			if (App.isSocial("SP")) 
			{
				if (App.owner.id == "1") 
				{
					var nameLabel:TextField = Window.drawText(Locale.__e("flash:1396867993836", [(App.owner.aka/*App.owner.first_name*/)]), App.self.userNameSettings( { 
						fontSize:20,
						autoSize:"left",
						color:0xffffff,
						borderColor:0x874c26,
						textAlign:"center",
						multiline:true
					}));
				}else 
				{
					nameLabel = Window.drawText(Locale.__e("flash:1396867993836", [(App.owner.aka)]), App.self.userNameSettings( { 
						fontSize:20,
						autoSize:"left",
						color:0xffffff,
						borderColor:0x874c26,
						textAlign:"center",
						multiline:true
					}));
				}				
			}else 
			{
				if (App.owner.id == '1')
				{
					App.owner.aka = Locale.__e('flash:1382952379733');
				}
				
				nameLabel = Window.drawText(Locale.__e("flash:1396867993836", [(App.owner.aka || App.owner.first_name)]), App.self.userNameSettings( { 
					fontSize:20,
					autoSize:"left",
					color:0xffffff,
					borderColor:0x874c26,
					textAlign:"center",
					multiline:true
				}));
			}		
			
			nameLabel.wordWrap = true;
			nameLabel.width = 100;
			//nameLabel.border = true;
			
			avatarPanel = new Sprite();	//Window.shadowBacking(nameLabel.width+70, 50, 20);
			
			btmp = new Bitmap(Window.textures.frGuestPanel)
			avatarPanel.addChild(btmp);
			btmp.x = 0;
			btmp.y = 0;
			
			avatarSprite = new Sprite();
			
			avatar = new Bitmap(null, "auto", true);
			
			Log.alert(App.owner);
			//Load.loading();
			
			avatarBacking = new Bitmap(UserInterface.textures.friendsBacking);
			avatarBacking.x = btmp.x + btmp.width - avatarBacking.width - 40;
			avatarBacking.y = btmp.y + 5 + (btmp.height - avatarBacking.height) / 2;
			
			avatarPanel.addChild(avatarBacking);
			avatarSprite.addChild(avatar);
			avatarPanel.addChild(avatarSprite);
			
			new AvaLoad(App.owner.photo, onAvatarLoad);
			
			//avatar.y += 20;
			//avatar.x += 30;
			//avatarSprite.addChild(avatar);
			//avatarPanel.addChild(avatarSprite);
			//avatarSprite.x = btmp.x + btmp.width - avatarSprite.width;
			//avatarSprite.y = btmp.y + (btmp.height - avatarSprite.height) / 2;		
			
			/*if(avatarPanel != null){
				guestWakeUpPanel.x = avatarPanel.x + (avatarPanel.width - guestWakeUpPanel.width)/2;
				guestWakeUpPanel.y = avatarPanel.y + avatarPanel.height;
			} else {
				guestWakeUpPanel.x = (App.self.stage.stageWidth - guestWakeUpPanel.width)/2;
				guestWakeUpPanel.y = avatarPanel.y + avatarPanel.height;
			}*/
			
			/*if (avatarPanel != null){
				avatarPanel.x = (App.self.stage.stageWidth - avatarPanel.width) / 2;
			} else {
				avatarPanel.x = (App.self.stage.stageWidth - avatarPanel.width) / 2;
			}*/		
			
			addChild(avatarPanel);
			avatarPanel.addChild(nameLabel);
			
			nameLabel.x = btmp.x + 33;
			nameLabel.y = btmp.y + 38;
			
			avatarSprite.filters = [new GlowFilter(0xf7f2de, 1, 6, 6, 4, 1)];
			
			addArrows();
			avatarPanel.x = (App.self.stage.stageWidth - avatarPanel.width) / 2 + 30;
		}
		
		public function drawFavoritePanel():void 
		{
			Friends.inFavorite = false;
			//return;
			if (App.user.friends.data[App.owner.id].hasOwnProperty('favorite'))
				Friends.inFavorite = true
			hideFavoriteButton();
			var bdata:BitmapData = Friends.inFavorite?UserInterface.textures.removeFav:UserInterface.textures.addFav;
			favoriteButton = new ImageButton(bdata)
			
			favoriteButton.addEventListener(MouseEvent.CLICK, onFavorite)
			
			favoriteButton.y = avatarPanel.y + 10;
			favoriteButton.x = avatarPanel.x + avatarPanel.width - 90;
			addChild(favoriteButton);
			
			var tipText:String
			
			favoriteButton.tip = function():Object{
				return{
					title:	Friends.inFavorite?Locale.__e('flash:1510657070386'):Locale.__e('flash:1510657095921')
				}	
			}
		}
		
		private function onFavorite(e:MouseEvent):void 
		{
			if (!Friends.inFavorite)
			{
				Post.send({
					ctr		:'friends',
					act		:'addtofavorites',
					uID		:App.user.id,
					fID		:App.owner.id
					}, onAddEvent);
				
			}
			else
			{
				Post.send({
					ctr		:'friends',
					act		:'removefromfavorites',
					uID		:App.user.id,
					fID		:App.owner.id
					}, onRemoveEvent);
				
			}
		}
		
		private function onAddEvent(error:int, data:Object, params:Object):void
		{
			redrawFavIcon(Friends.inFavorite)
			Friends.inFavorite = true;
			Friends.favorites[data.fID] = App.user.friends.data[data.fID];
			if (App.user.fmode == Friends.FAV)
				App.ui.bottomPanel.friendsPanel.searchFriends("", Friends.favorites)
		}
		
		private function onRemoveEvent(error:int, data:Object, params:Object):void
		{
			var tempFr:Object = {};
			for (var fr:* in Friends.favorites)
			{
				if (fr != data.fID)
					tempFr[fr] = Friends.favorites[fr]
			}
			if (Numbers.countProps(tempFr) == 0)
				Friends.favorites = new Object();
			else
				Friends.favorites = tempFr
			redrawFavIcon(Friends.inFavorite)
			Friends.inFavorite = false;
			if (App.user.fmode == Friends.FAV)
				App.ui.bottomPanel.friendsPanel.searchFriends("", Friends.favorites)
		}
		
		private function redrawFavIcon(inFav:Boolean):void 
		{
			favoriteButton.parent.removeChild(favoriteButton)
			var bdata:BitmapData = inFav?UserInterface.textures.addFav:UserInterface.textures.removeFav;
			favoriteButton.bitmapData = bdata;
			addChild(favoriteButton);
		}
		
		public function hideFavoriteButton():void 
		{
			//return;
			if (favoriteButton != null && contains(favoriteButton))
			{
				removeChild(favoriteButton);
				favoriteButton = null;
			}
		}
		
		public var arrowLeft:ImageButton 		= null;
		public var arrowRight:ImageButton 		= null;
		public var scale:Number =.6;
		public var guestGlow:Bitmap;
		public var ribbonInterBankSale:Bitmap;
		private var currentFriend: uint = 0;
		//public var friendsItems:Vector.<FriendItem> = new Vector.<FriendItem>();
		private function addArrows():void 
		{	
		/*	var length:int = App.ui.bottomPanel.friendsPanel.friends.length ;
			var item:FriendItem;
			
			var X:int = 45;
			var Y:int = 20;
			
			for (var i:int = start; i < length; i++) {
				item = new FriendItem(App.ui.bottomPanel.friendsPanel,friends[i]);
				friendsItems.push(item);
				/*item.x = X;
				item.y = Y;
				friendsCont.addChild(item);
				item.px = item.x;
				X += 68;*/
				//item.addEventListener(MouseEvent.CLICK, onVisitEvent);
		//	}*/
			
			for	(var fId:* in App.ui.bottomPanel.friendsPanel.friends)
			{
				if (App.ui.bottomPanel.friendsPanel.friends[fId].uid == App.owner.id)
				currentFriend = fId;
			}
			
			arrowLeft = new ImageButton(Window.textures.shopButton);
			arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, arrowLeftDown)
			
			avatarPanel.addChild(arrowLeft);
			arrowLeft.scaleX = -1*scale;
			arrowLeft.scaleY = scale;
			arrowLeft.x = avatarSprite.x + 30;
			arrowLeft.y = avatarSprite.y + 51;
			
			arrowRight = new ImageButton(Window.textures.shopButton);
			arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, arrowRightDown);
			arrowLeft.tip = function():Object {
				return {
					title:App.ui.bottomPanel.friendsPanel.friends[(currentFriend - 1 < 0)?App.ui.bottomPanel.friendsPanel.friends.length - 1:currentFriend - 1].aka,
					text:Locale.__e('flash:1382952379780')
					//title:Locale.__e('flash:1382952379780')
				};
			};
				
			//App.user
			avatarPanel.addChild(arrowRight);
			arrowRight.scaleX = 1 * scale;
			arrowRight.scaleY = scale;
			arrowRight.x = btmp.x + btmp.width - 25;
			arrowRight.y = avatarSprite.y + 50;
			
			arrowRight.tip = function():Object {
				return {
					title:App.ui.bottomPanel.friendsPanel.friends[(currentFriend + 1)>=App.ui.bottomPanel.friendsPanel.friends.length?0:currentFriend + 1].aka,
					text:Locale.__e('flash:1382952379780')
					//title:Locale.__e('flash:1382952379780')
					//App.user.friends
				};
			};
		}
		
		private function deleteArrows():void{ // created 250615
			avatarPanel.removeChild(arrowLeft);
			avatarPanel.removeChild(arrowRight);
		}
		
		private function arrowRightDown(e:MouseEvent):void 
		{
			var i:int = (currentFriend + 1) >= App.ui.bottomPanel.friendsPanel.friends.length ?0 :currentFriend + 1;
			App.ui.bottomPanel.friendsPanel.tempFriend = new FriendItem(App.ui.bottomPanel.friendsPanel, App.ui.bottomPanel.friendsPanel.friends[i]);
			App.ui.bottomPanel.friendsPanel.tempFriend.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			//App.ui.bottomPanel.friendsPanel.allFriendsItems[(currentFriend + 1)>=App.ui.bottomPanel.friendsPanel.allFriendsItems.length?0:currentFriend + 1].dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		private function arrowLeftDown(e:MouseEvent):void 
		{
			var i:int = (currentFriend - 1 < 0) ?App.ui.bottomPanel.friendsPanel.friends.length - 1 :currentFriend - 1;
			App.ui.bottomPanel.friendsPanel.tempFriend = new FriendItem(App.ui.bottomPanel.friendsPanel, App.ui.bottomPanel.friendsPanel.friends[i]);
			App.ui.bottomPanel.friendsPanel.tempFriend.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			
			//App.ui.bottomPanel.friendsPanel.allFriendsItems[(currentFriend - 1 < 0)?App.ui.bottomPanel.friendsPanel.allFriendsItems.length - 1:currentFriend - 1].dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		public function hideAvatar():void {
			if(avatarPanel != null && contains(avatarPanel)){
				removeChild(avatarPanel);
				avatarPanel = null;
				avatar = null;
				avatarSprite = null;
			}
		}
		
		public function drawInvitetoMap():void 
		{
			inviteBttn = new ImageButton(UserInterface.textures.friendsAddBacking);
			addChild(inviteBttn);
			Size.size(inviteBttn, 45, 45);
			//mainPanelFriend.addChild(bttnChat);
			inviteBttn.tip = function():Object {
				if (App.user.mode == User.PUBLIC && App.user.id == App.owner.id){
					return {
						title:Locale.__e('flash:1382952379781'),
						text:Locale.__e('flash:1503066220921')
					};
				}else{
					return {
						title:Locale.__e('flash:1503066274427')//,
						//text:Locale.__e("Нажми, чтобы посмотре друга!")
					};
				}
				
			}
			inviteBttn.addEventListener(MouseEvent.CLICK, onInviteEevent);
			resize();
		}
		

		public function drawGuestWakeUpPanel():void 
		{
			hideWakeUpPanel();
			if (!App.isSocial('DM', 'VK', 'FB', 'NK'))
				return;
				
			if (App.owner.id == '1')
				return;
				
			if (!Friends.isOwnerSleeping(App.owner.id) || App.owner.level < 10) return;
			
			var guestButtonSettings:Object = {
				caption		:Locale.__e('flash:1432729045568'),
				textAlign	:'center',
				fontSize	:22,
				width		:136,
				height		:48,
				hasDotes	:false
			};
			
			guestWakeUpPanel = new Sprite();
			//bg = BottomPanel.drawPanelBg(App.self.stage.stageWidth - 260, 'friendsPanel');  
			
			var extra:ExtraItem = new ExtraItem( Treasures.convertToObject(getExtraItems(App.owner.level))/*{ 7:3, 1:40, 2:15 }*/, this);
			guestWakeUpPanel.addChild(extra);
			extra.y = 10;
			
			guestButton = new Button(guestButtonSettings);  
			guestButton.addEventListener(MouseEvent.CLICK, guestAction);
			
			guestButton.x = (extra.bg.width - guestButton.width) / 2;
			guestButton.y = extra.bg.height - 32;
			
			
			extra.addChild(guestButton);
			if (App.owner && App.owner.level >= 10)
				addChild(guestWakeUpPanel);
			
			if(avatarPanel != null){
				//guestWakeUpPanel.x = avatarPanel.x + (avatarPanel.width - guestWakeUpPanel.width)/2;  // закомментировано 250615
				guestWakeUpPanel.x = (App.self.stage.stageWidth - guestWakeUpPanel.width)/2 + 27;
				guestWakeUpPanel.y = avatarPanel.y + avatarPanel.height - 30;
			} else {
				guestWakeUpPanel.x = (App.self.stage.stageWidth - guestWakeUpPanel.width)/2;
				guestWakeUpPanel.y = avatarPanel.y + avatarPanel.height;
			}
			
			//var bonusList:CollectionBonusList = new CollectionBonusList( { 7:100, 1:50, 2:50 } );
			//
			//guestWakeUpPanel.addChild(bonusList);
			//bonusList.x = 0;// (bg.width - bonusList.width) / 2;
			//bonusList.y = 50;
		}
		
		private function getExtraItems(level:int):String
		{
			var treas:String = "";
			for each(var bonus:* in App.data.wakeupbonus)
			{
				if (level >= bonus.levelFrom && level <= bonus.levelTo)
				{
					treas = bonus.bonus;
					break;
				}
			}
			return treas;
		}
		
		public function hideInvitePanel():void 
		{
			return;
			if (inviteBttn && inviteBttn.parent)
			{
				inviteBttn.parent.removeChild(inviteBttn);
				inviteBttn.removeEventListener(MouseEvent.CLICK, onInviteEevent);
			}
		}
		
		public function hideWakeUpPanel():void 
		{
			if (guestWakeUpPanel != null && contains(guestWakeUpPanel))
			{
				removeChild(guestWakeUpPanel);
				guestWakeUpPanel = null;
			}
		}
		
		
		
		private function guestAction(event:MouseEvent):void 
		{
			if (guestButton.mode == Button.DISABLED) 
				return;
				
			//guestButton.state = Button.DISABLED;  // need to make button like disable
			//App.self.sendPostWake();
			Notify.wakeUp(App.owner.id);
		}
		
		private function onAvatarLoad(data:*):void {
			if(data is Bitmap){
				avatar.bitmapData = data.bitmapData;
				avatar.height = avatar.width = avatarBacking.width - 6;
				avatar.smoothing = true;
			}	
			//avatar.scaleX = avatar.scaleY = 0.7;
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawRoundRect(0, 0, avatarBacking.width - 6, avatarBacking.width - 6, 30, 30);
			shape.graphics.endFill();
			avatarSprite.mask = shape;
			
			avatarSprite.x = avatarBacking.x + 3;//btmp.x + btmp.width - avatarSprite.width;
			avatarSprite.y = avatarBacking.y + 4;//btmp.y + (btmp.height - avatarSprite.height) / 2;
			
			shape.x = avatarSprite.x;
			shape.y = avatarSprite.y;
			
			avatarPanel.addChild(shape);
			
			var star1:Bitmap = new Bitmap(UserInterface.textures.expIcon);
			star1.scaleX = star1.scaleY = 0.6;
			star1.smoothing = true;
			star1.x = shape.x + shape.width - star1.width / 2 - 6;
			star1.y = shape.y + shape.height - star1.height / 2 - 3;
			avatarPanel.addChild(star1);			
			
			var lvlTxt:TextField =  Window.drawText(String(App.owner.level), {
					color:0xffffff,
					fontSize:16,
					borderColor:0x814f31,
					autoSize:"center",
					textAlign:"center"
				}
			);
			
			lvlTxt.width = 90;
			lvlTxt.x = star1.x +(star1.width - lvlTxt.width) / 2;
			lvlTxt.y = star1.y +(star1.height - lvlTxt.textHeight) / 2;
			//lvlTxt.filters = [new DropShadowFilter(2.0, 45, 0, 0.8, 2.0, 2.0, 1.0, 3, true, false, false)];
			avatarPanel.addChild(lvlTxt);
		}
		
		public function resize():void 
		{			
			if (tweenLeft) {
				tweenLeft.kill();
				tweenLeft = null;
			}
			if (tweenMiddle) {
				tweenMiddle.kill();
				tweenMiddle = null;
			}
			if (tweenRight) {
				tweenRight.kill();
				tweenRight = null;
			}
			
			if (bonusOnlineBttn) 
			{
				bonusOnlineBttn.x = (App.self.stage.stageWidth - bonusOnlineBttn.width) / 2 - 20;
				bonusOnlineBttn.y = 0;
			}
			if (chairSprite) 
			{
				if (App.user.worldID == User.AQUA_HERO_LOCATION && App.user.mode == User.OWNER)
				{
					chairSprite.visible = true;
					chairSprite.x = (App.self.stage.stageWidth - chairSprite.width) / 2 - 20;
				}else	
					chairSprite.visible = false;
			}
			
			if (timerSprite) 
			{
				if (App.user.mode == User.PUBLIC)
				{
					if (App.owner.world.data.expire - App.time <= 0)
						timerSprite.visible = false;
					else{
						timerSprite.visible = true;
						timerSprite.x = (App.self.stage.stageWidth - timerSprite.width) / 2 - 50;
					}
				}else	
					timerSprite.visible = false;
			}
			
			if (moxieSprite) 
			{
				loadMoxieIcon();
				if (App.data.storage[App.user.worldID].cookie && App.data.storage[App.user.worldID].cookie[0] != 519 && App.user.mode == User.OWNER)
				{
					moxieSprite.visible = true;
					moxieSprite.y = 14;
					moxieSprite.x = (App.self.stage.stageWidth - moxieSprite.width) / 2 - 20;
				}else	
					moxieSprite.visible = false;
			}
			
			if (basketSprite) 
			{
				if (App.user.worldID == User.HOLIDAY_LOCATION && App.user.mode == User.OWNER)
				{
					basketSprite.visible = true;
					basketSprite.x = (App.self.stage.stageWidth - basketSprite.width) / 2 - 20;
				}else	
					basketSprite.visible = false;
			}
			
			if (rewardContainer) 
			{
				if (App.user.worldID == User.HOLIDAY_LOCATION || App.user.worldID == User.AQUA_HERO_LOCATION)
					rewardContainer.visible = false;
				else	
					rewardContainer.visible = true;
			}
			
			if (avatarPanel != null)
			{
				avatarPanel.x = (App.self.stage.stageWidth - avatarPanel.width) / 2 + 50;
				
				//if (App.self.stage.displayState == StageDisplayState.NORMAL) {
				//}
			}
			
			if (favoriteButton)
			{
				favoriteButton.x = avatarPanel.x + avatarPanel.width - 90;
				favoriteButton.y = avatarPanel.y + 10;
			}
			
			if (guestWakeUpPanel != null) 
			{	
				if(avatarPanel != null){
					guestWakeUpPanel.x = avatarPanel.x + (avatarPanel.width - guestWakeUpPanel.width)/2 - 6;
				} else {
					guestWakeUpPanel.x = (App.self.stage.stageWidth - guestWakeUpPanel.width)/2;
				}
			}
			
			iconsSprite.x = App.self.stage.stageWidth / 2 -iconsSprite.width/2;
			iconsSprite.y = 9;
			
			if (help != null) help.x = (App.self.stage.stageWidth - help.width) / 2;			
			
			rightCont.x = App.self.stage.stageWidth - 180;
			rightCont.y = 0;
			leftCont.y = 0;
			
			calendarManage();
			
			if (inviteBttn)
			{
				inviteBttn.x = App.self.stage.stageWidth - inviteBttn.width - 80;
				inviteBttn.y = expIcon.height + 10;
			}
			
			calendarBttn.x = App.self.stage.stageWidth - calendarBttn.width - 20;
			calendarBttn.y = expIcon.height + 10;
			
			auctionBttn.x = calendarBttn.x - auctionBttn.width - 5;
			auctionBttn.y = calendarBttn.y + (calendarBttn.height - auctionBttn.height) / 2;
			
			discountSprite.x = calendarBttn.x - discountSprite.width + 110;
			discountSprite.y = calendarBttn.y + (calendarBttn.height - discountSprite.height) / 2 + 5;
			
			topSprite.x = calendarBttn.x - topSprite.width - 20;
			topSprite.y = calendarBttn.y + (calendarBttn.height - topSprite.height) / 2 + 7;
			
			if (confirmBttn) 
			{
				confirmBttn.x = (App.self.stage.stageWidth - confirmBttn.width) / 2;
				confirmBttn.y = 176;
				cancelBttn.x = (App.self.stage.stageWidth - cancelBttn.width) / 2;
				cancelBttn.y = 176;
				if ( cancelBttn )
				{
					cancelBttn.x += cancelBttn.width / 2 + 10;
					confirmBttn.x -= confirmBttn.width/ 2 - 10;
				}				
			}
			if (ribbonSaleText)
			{
				ribbonSaleText.x = ribbonInterBankSale.x + 8;
				ribbonSaleText.y = ribbonInterBankSale.y + (ribbonInterBankSale.height - ribbonSaleText.textHeight) / 2 + 7;
				
				timeSaleText.x = ribbonSaleText.x + 25;
				timeSaleText.y = ribbonSaleText.y + 29;
			}
		}	
		
		private function onInviteEevent(e:MouseEvent):void 
		{
			if (App.user.mode == User.PUBLIC && App.user.id == App.owner.id)//{
				new InviteSocketWindow( { } ).show();
				//if(App.user.id == App.owner.id)
			//}
			else
				new FriendsSocketWindow( { } ).show();
			//Notify.wakeUp(App.owner.id);
		}
		
		private function onBankEevent(e:MouseEvent):void {
			if (App.user.quests.tutorial) {
				return;
			}
			switch(App.social) {
				case "PL": 
					if (e.target.name == 'coins') {
						ExternalApi.apiBalanceEvent('coins');
					}else if (e.target.name == 'fants') {
						ExternalApi.apiBalanceEvent('reals');
					}
					break;
				default:
					//new BankSaleWindow().show();
					new BanksWindow().show();
				break;
			}
			
		}
		
		public function onEnergyEvent(e:MouseEvent = null):void {
			
			if (App.user.quests.tutorial)
				return;
			
			new PurchaseWindow( {
				width:600,
				itemsOnPage:3,
				content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Energy'}, Stock.FANTASY),
				title:Locale.__e("flash:1382952379756"),
				description:Locale.__e("flash:1382952379757"),
				popup: true,
				closeAfterBuy:false,
				autoClose:false,			
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
			
		}
		
		public function onMoxieEvent(e:MouseEvent = null):void {
			
			if (App.user.quests.tutorial)
				return;
			if (App.data.storage[App.user.worldID].cookie[0] == 1954)
			{
				var _units:Array = Map.findUnits([1918, 1916, 1915, 1914, 1913, 1912, 1902, 1901, 1887]);
				var _unit:* = _units[int(Math.random() * _units.length)];// Finder.nearestUnit(App.user.hero, units);
				
				App.map.focusedOnCenter(_unit, false, function():void 
				{
					if (_unit is Animal)
					{
						_unit.stopWalking();
						_unit.showPointing("top", _unit.dx - _unit.width / 2, _unit.dy - _unit.depth_animal);
					}else
					{
						_unit.showPointing("top",  _unit.dx - _unit.width / 2, _unit.dy);
					}
					setTimeout(function():void {
						_unit.hidePointing();
					}, 2000);
				});
			}
			else if (App.data.storage[App.user.worldID].cookie[0] == 3240)
			{
				var _wunits:Array = Map.findUnits([3131]);
				if (_wunits.length > 0)
				{
					var _wunit:Unit
					for each(var unt:* in _wunits)
					{
						if (World.zoneIsOpen(App.map._aStarNodes[unt.coords.x][unt.coords.z].z))
						{
							_wunit = unt;
							break;
						}
					}
					if (!_wunit)
						_wunit = _wunits[int(Math.random() * _wunits.length)];
					
					App.map.focusedOnCenter(_wunit, false, function():void 
					{
						_wunit.showPointing("top",  _wunit.dx - _wunit.width / 2, _wunit.dy);
						
						setTimeout(function():void {
							_wunit.hidePointing();
						}, 2000);
					});
				}
				else
				{
					var _ship:* = Map.findUnits([3238])[0];
					App.map.focusedOnCenter(_ship, false, function():void 
					{
						_wunit.showPointing("top",  _ship.dx - _ship.width / 2, _ship.dy);
						
						setTimeout(function():void {
							_ship.hidePointing();
						}, 2000);
					});
				}
				
			}
			else if (App.data.storage[App.user.worldID].cookie[0] == 3036)
			{
				var __nyunits:Array = [3040, 3041, 2911]
				var _nyunits:Array = Map.findUnits(__nyunits);
				if (_nyunits.length > 0)
				{
					var _nyunit:* = _nyunits[int(Math.random() * _nyunits.length)];
				
					App.map.focusedOnCenter(_nyunit, false, function():void 
					{
						_nyunit.showPointing("top",  _nyunit.dx - _nyunit.width / 2, _nyunit.dy);
						
						setTimeout(function():void {
							_nyunit.hidePointing();
						}, 2000);
					});
				}
				else
				{
					new ShopWindow({
						find:	__nyunits
					}).show();
				}
				
			}
			else if (App.data.storage[App.user.worldID].cookie[0] == 3348)
			{
				var __postunits:Array = [3317]
				var _postunits:Array = Map.findUnits(__postunits);
				if (_postunits.length > 0)
				{
					var _postunit:* = _postunits[int(Math.random() * _postunits.length)];
				
					App.map.focusedOnCenter(_postunit, false, function():void 
					{
						_postunit.showPointing("top",  _postunit.dx , _postunit.dy);
						
						setTimeout(function():void {
							_postunit.hidePointing();
						}, 2000);
					});
				}
				else
				{
					new ShopWindow({
						find:	__postunits
					}).show();
				}
				
			}
			else if (App.data.storage[App.user.worldID].cookie[0] == 3269)
			{
				new CollectionWindow({find:	[3273]}).show();
				
			}
			else{
				new PurchaseWindow( {
					width			:600,
					itemsOnPage		:3,
					content			:PurchaseWindow.createContent("Energy", {inguest:0, view:'bodrost1'}, App.data.storage[App.user.worldID].cookie[0]),
					title			:App.data.storage[App.data.storage[App.user.worldID].cookie[0]].title,
					description		:Locale.__e("flash:1382952379757"),
					popup			:true,
					closeAfterBuy	:false,
					autoClose		:false,			
					callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
					}
				}).show();
				//TopHelper.showTopWindow(1489);
			}
				
			
		}
		
		public function onBasketEvent(e:MouseEvent = null):void {
			
			if (App.user.quests.tutorial)
				return;
			
			new PurchaseWindow( {
				width:600,
				itemsOnPage:3,
				content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Basket'}, Stock.BASKET),
				title:Locale.__e("flash:1492613621735"),
				description:Locale.__e("flash:1382952379757"),
				popup: true,
				closeAfterBuy:false,
				autoClose:false,			
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
			//TopHelper.showTopWindow(1489);
			
		}
		
		public function onRobotEvent(e:MouseEvent = null,toFind:int=-1):void {
			
			if (App.user.quests.tutorial) return;
			var bttn:ImageButton = e.target as ImageButton;
			
			if (!bttn||bttn.mode == Button.DISABLED) return;
			bttn.state = Button.DISABLED;
			
			var _settings:Object;
			if (Quests.targetSettings != null)
				_settings = Quests.targetSettings;
			else
				_settings = { };			
			
			new PurchaseWindow( {
				width:530,
				height:635,
				itemsOnPage:6,
				useText:true,
				cookWindow:true,
				shortWindow:true,
				columnsNum:3,
				scaleVal:1,
				noDesc:false,
				closeAfterBuy:false,
				autoClose:false,
				description:Locale.__e('flash:1393599816743'),
				content:PurchaseWindow.createContent("Energy", {view:['slave','Cookies']}),
				title:Locale.__e('flash:1422628903758'),
				popup: true,
				technoCookieWindow: true,
				find:toFind,
				splitWindow:true,
				titleSplit:App.data.storage[App.data.storage[App.user.worldID].cookie[0]].title,
				descriptionSplit:Locale.__e('flash:1422628646880'),
				itemHeight:220,
				itemWidth:143,
				itemIconScale:0.8,
				offsetY:30
			}).show();
			bttn.state = Button.NORMAL;
		}
		
		public function showCookie():void 
		{
			onRobotEvent();
		}
		
		public function onKeyLevelShow(e:MouseEvent):void
		{
			if (App.lang != 'ru') {
				return;
			}
			
			//Открытие окна следующего уровня. Пока у нас тут нет.
			//if (Config.admin) 
			//{
				//new LevelUpWindow({nextKeyLevel:true}).show();
			//}			
		}
		
		public function show(toogle:Boolean = true):void 
		{		
			energyBar.visible = toogle;
			//expSprite.visible = toogle;
			energyIcon.visible = toogle;
			energySlider.visible = toogle;
			energyCounter.visible = toogle;
			energyPlusBttn.visible = toogle;
			//robotPlusBttn.visible = toogle;
			iconsSprite.visible = toogle;
			guestSprite.visible = toogle;
			energySprite.visible = toogle;
			//winterShopBttn.visible = toogle;
			//timeOfExpire.visible = toogle;
		}
		
		/*private var canTween:Boolean = true;
		private var isTween:Boolean = false;
		private var timeOff:int;
		private var hideTween:TweenMax;
		public function updateCapasity(_value:int):void 
		{
			if (isTween) return;
			if (!canTween) {
				clearInterval(timeOff);
				
				removeHideTween();
				
				capasityValues(Stock.value, Stock.limit);
				
				timeOff = setInterval(function():void { 
					clearInterval(timeOff);
					
					hideTween = TweenMax.to(capasitySprite, 0.5, { alpha:0, onComplete:function():void {
							capasitySprite.visible = false; canTween = true;
					}});
					}, 2000);
				return;
			}
			
			removeHideTween();
			
			canTween = false;
			isTween = true;
			var value:int = _value;
			var limit:int = Stock.limit;
			
			capasitySprite.visible = true;
			capasitySprite.alpha = 0;
			
			capasityValues(value, limit);
			
			TweenLite.to(capasitySprite, 1, { alpha:1, onComplete:function():void {
				isTween = false;
				capasityValues(Stock.value, limit);
				
				timeOff = setInterval(function():void { 
					clearInterval(timeOff);
					hideTween = TweenMax.to(capasitySprite, 0.5, { alpha:0, onComplete:function():void {
							capasitySprite.visible = false; canTween = true;
					}});
				}, 2000);
			}});
		}
		
		private function capasityValues(value:int, limit:int):void
		{
			capasityCounter.text = value +'/' + limit;
			UserInterface.slider(capasitySlider, value, limit, "progressBar", true);
		}
		
		private function removeHideTween():void
		{
			if (hideTween) {
				hideTween.complete(true);
				hideTween.killVars(capasitySprite);
				hideTween = null;
				capasitySprite.visible = true; capasitySprite.alpha = 1;
			}
		}*/
		
		public function updateExperience():void {
			var maxExp:int;
			var minExp:int;
			
			if (App.data.levels[App.user.level+1]){
				maxExp = App.data.levels[App.user.level + 1].experience;
			}else {
				maxExp = App.data.levels[App.user.level].experience;
			}
			minExp = App.data.levels[App.user.level].experience;
			var exp:int = App.user.stock.count(Stock.EXP) - minExp;
			if (exp > maxExp) {
				exp = maxExp;
			}
			UserInterface.slider(expSlider, exp, maxExp-minExp, "expSlider");
		}
		
		public function updateEnergy():void {
			var maxEnergy:int = App.user.stock.maxEnergyOnLevel;
			var energy:int = App.user.stock.count(Stock.FANTASY);
			UserInterface.slider(energySlider, energy, maxEnergy, "energySlider");
		}
		
		private var _arrCounts:Array = [App.user.stock.count(Stock.COINS), App.user.stock.count(Stock.FANT), App.user.personages.length,  
										App.user.stock.count(Stock.EXP), App.user.level];//App.user.stock.count(Stock.FANTASY)
		public function update(fields:Array = null):void {
			
			if (fields != null) {
				for each(var field:String in fields) {
					switch (field) 
					{
						case 'moxie': 
							moxieCounter.text = Numbers.moneyFormat2(App.user.stock.count(App.data.storage[App.user.worldID].cookie[0]));
							break;
						case 'chair': 
							chairCounter.text = Numbers.moneyFormat2(App.user.stock.count(Stock.CHAIR));
							break;
						case 'basket': 
							basketCounter.text = Numbers.moneyFormat2(App.user.stock.count(Stock.BASKET));
							break;
						case 'coins': 
							coinsCounter.text = Numbers.moneyFormat2(App.user.stock.count(Stock.COINS));
							break;
						case 'fants':
							fantsCounter.text 	= Numbers.moneyFormat(App.user.stock.count(Stock.FANT));
							break;
						case 'discount':
							discountText.text 	= Numbers.moneyFormat(App.user.stock.count(App.data.options.bonusBankItem));
							break;
						/*case 'cookie':							
							cookiesCounter.text 	= String(App.user.stock.count(App.data.storage[App.user.worldID].cookie[0]))
							updateCookies();
							break;*/
						case 'energy': 
							energyCounter.text 	= String(App.user.stock.count(Stock.FANTASY));
							updateEnergy();
							break;
						case 'exp':
							expCounter.text 	= String(App.user.stock.count(Stock.EXP));
							updateExperience();
							break;
					}
				}
			}else {
				var twTime:Number = 1.6;
				
				TweenLite.to(_arrCounts, twTime, {endArray: [App.user.stock.count(Stock.COINS), App.user.stock.count(Stock.FANT), App.user.personages.length, 
							App.user.stock.count(Stock.EXP), App.user.level], ease:Sine.easeOut, onUpdate: output } );//App.user.stock.count(Stock.FANTASY), 
				
				chairCounter.text 	= Numbers.moneyFormat2(App.user.stock.count(Stock.CHAIR));
				basketCounter.text 	= Numbers.moneyFormat2(App.user.stock.count(Stock.BASKET));
				coinsCounter.text 	= Numbers.moneyFormat2(App.user.stock.count(Stock.COINS));
				fantsCounter.text 	= Numbers.moneyFormat(App.user.stock.count(Stock.FANT));
				moxieCounter.text 	= String(App.user.stock.count(App.data.storage[App.user.worldID].cookie[0]));
				energyCounter.text 	= String(App.user.stock.count(Stock.FANTASY));
				expCounter.text 	= String(App.user.stock.count(Stock.EXP));
				levelCounter.text 	= String(App.user.level);
				App.user.personages.length,
				//robotCounter.text 	=  Techno.getBusyTechno() +"/"+(Techno.freeTechno().length + Techno.getBusyTechno());
				
				updateExperience();
				updateEnergy();
				//updateCookies();
			}		
			
			//robotIcon.visible = false;	
			//robotIcon2.visible = false;
			//robotIcon3.visible = false;
			//cookiesIcon.visible = false;
			//cookiesIcon2.visible = false;
			//cookiesIcon3.visible = false;
			
			/*switch(App.user.worldID) {
				default:
					robotIcon.visible = true;		
					cookiesIcon.visible = true;
					break;
			}*/
			
			calendarManage();
		}
		
		private function calendarManage():void 
		{
			if (App.user.quests.tutorial)
			{
				calendarBttn.visible = false;
				auctionBttn.visible = false;
				discountSprite.visible = false;
				topSprite.visible = false;
				return;
			}
				
			if(!App.data.calendar || App.user.mode == User.GUEST)
				calendarBttn.visible = false;
			else
				calendarBttn.visible = true;//ВРЕМЕННО
				
			if (App.user.mode == User.GUEST)
			{
				auctionBttn.visible = false;
				discountSprite.visible = false;
				topSprite.visible = false;
			}
			else
			{
				discountSprite.visible = true;
				topSprite.visible = true;
				//auctionBttn.visible = true;//ВРЕМЕННО
				for each (var auction:Object in App.data.auctions) 
				{
					if (auction.enabled && auction.expire.s < App.time && auction.expire.e > App.time) {
						auctionBttn.visible = true;
						return;
					} else {
						auctionBttn.visible = false;
					}
				}
			}
		}
		
		private var cookieAmount:String ;
		private function updateCookies():void 
		{
			if (cookieAmount&&(int(cookieAmount)<=App.data.options.CookiesAlarmLimit)&&(App.data.storage[App.user.worldID].cookie[0]>App.data.options.CookiesAlarmLimit)) 
			{
				finded = []
				for (var s:* in App.data.storage) {
					if (App.data.storage[s].hasOwnProperty('devel')) {
						var crafting:* = App.data.storage[s].devel.craft;
						for each(var cftItm:* in crafting) {
								for each(var cft:* in cftItm) {
								if (App.data.crafting.hasOwnProperty(cft)&&App.data.crafting[cft].out == int(App.data.storage[App.user.worldID].cookie[0])) {
								finded.push(s);
								
								}
							}
						}
					}
				}	
				if (finded) {
					var onMap:Array = Map.findUnits(finded);
					for (var i:int = 0; i < onMap.length; i++) 
					{
						
						onMap[i].hideGlowing();	
						
						
					}
				}
			}	
		}
		
		private function output():void 
		{
			//if (App.user.stock.count(Stock.COINS) < _arrCounts[0]) {
			//doScaleAnim(coinsIcon);
			//coinsCounter.text 	= Numbers.moneyFormat(int(_arrCounts[0]));
			//}
			//if (App.user.stock.count(Stock.FANT) < _arrCounts[1]) {
			//doScaleAnim(fantsIcon);
			
			fantsCounter.text 	= Numbers.moneyFormat(int(_arrCounts[1]));
			////trace("_arrCounts[1]-= " + _arrCounts[1] + "   fantsCounter.text-= " + fantsCounter.text + "   App.user.stock.count(Stock.FANT)-= " + App.user.stock.count(Stock.FANT) );
			//}
			//if (App.user.personages.length < _arrCounts[2]) {
			//doScaleAnim(bearIcon);
			
			//bearCounter.text 	= String(int(_arrCounts[2])) + "/3";
			//}
			//if (App.user.stock.count(Stock.FANTASY) < _arrCounts[3]) {
			//doScaleAnim(energyIcon);
			
			//energyCounter.text 	= String(int(_arrCounts[3]));
			//}
			//if (App.user.stock.count(Stock.EXP) < _arrCounts[4]) {
			//doScaleAnim(expIcon);
			//
			//expCounter.text 	= String(int(_arrCounts[3]));
			//}
			//if (App.user.level < _arrCounts[5]) {
			
			levelCounter.text 	= String(int(_arrCounts[4]));
			//}
			//if (0 < 0) {
			
			//	robotCounter.text 	= String(int(_arrCounts[5])) + "/3";
			//}
		}
		
		private function doScaleAnim(btm:Bitmap):void
		{
			var container:MovieClip = new MovieClip();
			container.x = btm.x; container.y = btm.y;
			container.addChild(btm);
			btm.x = 0, btm.y = 0;
			addChild(container);
			TweenLite.to(container, 0.8, { scaleX:1.4, scaleY:1.4, ease:Elastic.easeOut, onComplete:function():void {
				TweenLite.to(container, 0.8, { scaleX:1, scaleY:1, ease:Elastic.easeOut } );
			}});
		}
		
		/*public function showHelp(message:String):void
		{
			//var paddingX:int = 25;
			//var paddingY:int = 17;
			var text:TextField = Window.drawText(message,
			{
				color:0xfbf6d6,
				borderColor:0x5c4126,
				fontSize:38
			});
			
			text.height 	= text.textHeight;
			text.width 		= text.textWidth + 5;
			//text.x = paddingX;
			//text.y = paddingY;
						
			help = new LayerX();
			var backing:Bitmap = Window.backing(250, 60, 10, "searchPanelBackingPiece");
			help.addChild(backing);
			backing.alpha = 0.9;
			
			text.x = (backing.width - text.width) / 2;
			text.y = (backing.height - text.height) / 2;
			
			help.addChild(text);
			addChild(help);
			
			help.x = (App.self.stage.stageWidth - help.width) / 2;
			help.y = 110;
			help.alpha = 0;
			
			TweenLite.to(help, 0.7, { alpha:1, onComplete:function():void { help.startGlowing(); }} );
		
		}
		*/
		
		public function showHelp(message:String, width:int = 250):void
		{
			if (help != null && contains(help)) {
				help.hideGlowing();
				removeChild(help);
			}
			help = null;
			
			var text:TextField = Window.drawText(message,
			{
				color:0xfbf6d6,
				borderColor:0x5c4126,
				fontSize:38
			});
			
			text.height 	= text.textHeight;
			text.width 		= text.textWidth + 5;
			//text.x = paddingX;
			//text.y = paddingY;
			
			if (width == 0) {
				if (text.width > 250) {
					width = text.width + 40;
				}else {
					width = 250;
				}
			}
			
			help = new LayerX();
			var backing:Bitmap = Window.backing(width, 60, 10, "searchPanelBackingPiece");
			backing.x += 10;
			help.addChild(backing);
			backing.alpha = 0.9;
			
			text.x = (backing.width - text.width) / 2;
			text.y = (backing.height - text.height) / 2;
			
			help.addChild(text);
			addChild(help);
			
			help.x = (App.self.stage.stageWidth - help.width) / 2;
			help.y = 110;
			help.alpha = 0;
			if (help) {
				TweenLite.to(help, 0.7, { alpha:1, onComplete:function():void { if(help) help.startGlowing(); }} );
			}
			
			/*timer.addEventListener(TimerEvent.TIMER, hideHelp);
			timer.start();*/
		}
		
		public function hideHelp(e:TimerEvent = null):void
		{
			timer.reset();
			timer.removeEventListener(TimerEvent.TIMER, hideHelp);
			
			if (help != null)	
			{
				TweenLite.to(help, 1, { alpha:0, onComplete:function():void
				{
					if (help != null && contains(help)) 
					{
						help.hideGlowing();
						removeChild(help);
					}
					help = null;
				}});
			}
		}
		
		private var moneyLabelCont:LayerX = new LayerX();
		private var timerText:TextField;
		
		private var timeToActionEnd:int = 0;
		public function showMoneyLabels():void 
		{
			
			moneyLabelCont.mouseEnabled = false;
			
			var bgLabel:Bitmap = new Bitmap(Window.textures.boost);
			bgLabel.scaleX = bgLabel.scaleY = 0.67;
			bgLabel.smoothing = true;
			
			var labelTitle:TextField = Window.drawText(Locale.__e("flash:1396521604876"), {
				color:0xffc936,
				borderColor:0x773918,
				textAlign:"center",
				autoSize:"center",
				borderSize:3,
				fontSize:19
			});
			labelTitle.width = labelTitle.textWidth + 10;			
			
			if(App.data.money && App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1)
				timeToActionEnd = App.data.money.date_to;
			else if (App.user.money > App.time)
				timeToActionEnd = App.user.money;
			
			timerText = Window.drawText(TimeConverter.timeToStr(timeToActionEnd), {
				letterSpacing:0,
				textAlign:"center",
				fontSize:17,
				color:0xffea90,
				borderColor:0x7b3a1e,
				borderSize:3
			});
			timerText.width = 80;
			
			labelTitle.y = 7;
			bgLabel.x = (timerText.width - bgLabel.width) / 2;
			labelTitle.x = bgLabel.x + (bgLabel.width - labelTitle.width) / 2;
			timerText.y = labelTitle.y + labelTitle.textHeight - 2;
			
			moneyLabelCont.addChild(bgLabel);
			moneyLabelCont.addChild(labelTitle);
			moneyLabelCont.addChild(timerText);
			
			addChild(moneyLabelCont);
			moneyLabelCont.rotation = -18;
			moneyLabelCont.x = 132;
			moneyLabelCont.y = 50;
			
			App.self.setOnTimer(updateTimer);
		}
		
		private var tweenLeft:TweenLite;
		public function showLeft(value:Boolean = true):void
		{
			if (value && !leftCont.visible && !tweenLeft) {
				leftCont.visible = true;
				leftCont.y = -leftCont.height - 20;
				tweenLeft = TweenLite.to(leftCont, 0.6, { y:0, onComplete:function():void { tweenLeft = null; }} );
			}else if (!value && leftCont.visible && !tweenLeft) {
				leftCont.y = 0;
				tweenLeft = TweenLite.to(leftCont, 0.6, { y: -leftCont.height-20, onComplete:function():void { tweenLeft = null, leftCont.visible = false;}} );
			}
		}
		
		private var tweenMiddle:TweenLite;
		public function showMiddle(value:Boolean = true):void
		{
			if (value && !iconsSprite.visible && !tweenMiddle) {
				iconsSprite.visible = true;
				iconsSprite.y = -iconsSprite.height - 9;
				tweenMiddle = TweenLite.to(iconsSprite, 0.6, { y:9, onComplete:function():void { tweenMiddle = null; }} );
			}else if (!value && iconsSprite.visible && !tweenMiddle) {
				iconsSprite.y = 9;
				tweenMiddle = TweenLite.to(iconsSprite, 0.6, { y: -iconsSprite.height-9, onComplete:function():void { tweenMiddle = null, iconsSprite.visible = false;}} );
			}
			
			//if (iconsSprite.visible) 
			//return;
			//
			//this.y = 0;	
			//
			//iconsSprite.visible = true;
			//iconsSprite.y = -iconsSprite.height -9;
			//
			//tweenMiddle = TweenLite.to(iconsSprite, 0.6, {y:9, onComplete:function():void{tweenMiddle = null}});
		}
		
		private var isRightTween:Boolean = false;
		private var tweenRight:TweenLite;
		private var guestShowed:Boolean = false;
		private var finded:Array;
		
		public function showRight(value:Boolean = true):void
		{
			if (value && !rightCont.visible && !tweenRight) {
				rightCont.visible = true;
				rightCont.y = -rightCont.height - 20;
				tweenRight = TweenLite.to(rightCont, 0.6, {y:0, onComplete:function():void{tweenRight = null}});
			}else if(!value && rightCont.visible && !tweenRight){
				rightCont.y = 0;
				tweenRight = TweenLite.to(rightCont, 0.6, {y:-rightCont.height, onComplete:function():void{tweenRight = null, rightCont.visible = false;}});
			}
		}
	}
}

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.ExtraBonusList;
import wins.Window;


internal class ExtraItem extends Sprite
{
	public var extra:Object;
	public var bg:Bitmap;
	private var title:TextField;
	private var extraReward:ExtraBonusList;
	
	public function ExtraItem(extra:Object, window:*) 
	{
		this.extra = extra;
		drawReward();
		
		bg = Window.backing((extraReward.width < 150) ? 200 : extraReward.width + 50, 130, 50, "tipUp");
		addChild(bg);
		swapChildren(bg, extraReward);
		extraReward.x = bg.x + (bg.width - extraReward.width) / 2 - 10;
		drawTitle();
		
	}
	
	private function drawTitle():void 
	{
		title = Window.drawText(Locale.__e("flash:1492081222859"), {
			fontSize	:18,
			color		:0xffffff,
			borderColor	:0x673a1f,
			textAlign   :'center',
			borderSize 	:2,
			multiline   :true,
			wrap        :true
		});
		//title.border = true;
		title.width = bg.width - 50;
		title.x = bg.x + (bg.width - title.width) / 2;
		title.y = bg.y + 14;
		extraReward.y = title.y + title.textHeight - 12;
		addChild(title);
	}
	
	private function drawReward():void 
	{
		//var reward:RewardList = new RewardList(extra, false, 0, '', 1, 44, 16, 40, "x", 0.6, -3, 7);
		extraReward = new ExtraBonusList(extra, false);
		
		addChild(extraReward);
		extraReward.x = 15;
		
		
		/*var icon:Bitmap = new Bitmap(Window.textures.viralAborigine);
		addChild(icon);
		icon.x = 140;
		icon.y = -58;*/
	}
}

/*
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.GlowFilter;
import units.Bear;
import flash.utils.Timer;
import units.Personage;

internal class BearsPanel extends Sprite
{
	private var showed:Boolean = false;
	private var items:Array = [];
	private var container:Sprite;
	private var overed:Boolean = false;
	private var overTimer:Timer = new Timer(250, 1);
	
	public function BearsPanel()
	{
		overTimer.addEventListener(TimerEvent.TIMER, dispose)
	}
	
	public function show():void
	{
		dispose();
		
		items = [];
		container = new Sprite();
		
		var X:int = 0;
		var Y:int = 0;
		Bear.bears.sortOn('id');
		for (var i:int = 1; i <= Bear.bears.length; i++)
		{
			var item:BearItem = new BearItem(Bear.bears[i-1]);
			
			item.addEventListener(MouseEvent.MOUSE_OVER, over);
			item.addEventListener(MouseEvent.MOUSE_OUT, out);
			
			container.addChild(item);
			item.x = X;
			item.y = Y;
			
			X += item.bg.width + 2;
			
			if (i%5 == 0)
			{
				Y += item.bg.height;
				X = 0;
			}
		}
		
		container.x = - container.width / 2;
		addChild(container);
		
		showed = true;
	}
	
	private function over(e:MouseEvent):void
	{
		overed = true;
	}
	private function out(e:MouseEvent):void
	{
		overed = false;
	}
	
	private function dispose(e:TimerEvent = null):void
	{
		overTimer.reset();
		if (overed)
		{
			overTimer.start();
			return;
		}	
		
		for each(var _item:BearItem in items)
		{
			_item.dispose();
			_item.removeEventListener(MouseEvent.MOUSE_OVER, over);
			_item.removeEventListener(MouseEvent.MOUSE_OUT, out);
			removeChild(_item);
			_item = null;
		}
		
		if (container != null)
		{
			removeChild(container);
			container = null;
		}
		
		showed = false;
	}
	
	public function hide():void
	{
		overTimer.reset();
		overTimer.start();
	}
}

import units.Bear;
import ui.UserInterface;
import buttons.ImagesButton;

internal class BearItem extends Sprite
{
	public var bg:ImagesButton;
	private var bear:Bear;
	private var bitmap:Bitmap;
	private var statusBitmap:Bitmap;
	
	public function BearItem(bear:Bear)
	{
		this.bear = bear;
		var bearBmd:BitmapData = new BitmapData(UserInterface.textures.mainBttnBacking.width, UserInterface.textures.mainBttnBacking.height, true, 0);
		
		bg = new ImagesButton(UserInterface.textures.mainBttnBacking, bearBmd);
		bg.addEventListener(MouseEvent.CLICK, onClick);
		
		Load.loading(Config.getImage('interface', bear.info.view), function(data:Bitmap):void {
			bg.icon = data.bitmapData;
		});
			
		bitmap = new Bitmap();
		statusBitmap = new Bitmap();
		
		if (bear.resource != null && bear.status == Bear.HIRED)
		{
			Load.loading(Config.getIcon("Material", App.data.storage[bear.resource.info.out].preview), onLoad);
		}
		
		statusBitmap.bitmapData = bearBmd;
		statusBitmap.scaleX = statusBitmap.scaleY = 0.8;
		statusBitmap.smoothing = true;
		
		addChild(bg);
		addChild(bitmap);
		addChild(statusBitmap);
		
		statusBitmap.y = 45 - statusBitmap.height/2;
	}
	
	private function onLoad(data:Bitmap):void
	{
		bitmap.bitmapData = data.bitmapData;
		var scale:Number = 26 / data.width;
		bitmap.scaleX = bitmap.scaleY = scale;
		bitmap.smoothing = true;
		bitmap.x = bg.width - bitmap.width - 4;
		bitmap.y = bg.height - bitmap.height -4;
		bitmap.filters = [new GlowFilter(0xe8dfcd,1, 4,4,7)];
	}
	
	private function onClick(e:MouseEvent):void
	{
		App.map.focusedOn(bear, true);
	}
	
	public function dispose():void
	{
		bg.removeEventListener(MouseEvent.CLICK, onClick);
		bear = null;
	}
}*/