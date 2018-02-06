package ui 
{
	import api.ExternalApi;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import effects.BoostEffect;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import units.Field;
	import units.Unit;
	import utils.SocketActions;
	import wins.AchivementsWindow;
	import wins.CollectionWindow;
	import wins.ExpeditionHintWindow;
	import wins.FreeGiftsWindow;
	import wins.InvitesWindow;
	import wins.PurchaseWindow;
	import wins.QuestsChaptersWindow;
	import wins.ShipWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.TresureWindow;
	import wins.Window;
	import wins.elements.PostPreloader;
	import wins.elements.TresureIcon;
	
	public class BottomPanel extends Sprite
	{
		public var bttnPrev:ImageButton;
		public var bttnPrevSix:ImageButton;
		public var bttnPrevAll:ImageButton;
		public var bttnNext:ImageButton;
		public var bttnNextSix:ImageButton;
		public var bttnNextAll:ImageButton;
		public var bttnMainShop:ImagesButton;
		public var bttnMainStock:ImagesButton;
		public var bttnMainMap:ImagesButton;
		public var bttnChat:ImageButton;
		public var bttnMainHome:ImageButton;
		public var bttnStop:ImagesButton;
		public var bttnStopFriends:ImagesButton;
		public var bttnCursors:ImagesButton;
		public var openArrow:Bitmap = new Bitmap();
		public var cursorsPanel:LayerX;
		public var mainPanel:Sprite;
		public var guestMainPanel:Sprite;
		public var mainPanelFriend:Sprite;
		public var mainPanelExp:Sprite;
		public var iconsPanel:Sprite = new Sprite();		
		public var counterMapPanel:Bitmap;
		public var counterBlue:Bitmap;
		public var counterYellow:Bitmap;
		public var mapCounter:TextField;
		private var mapCounterCont:Sprite
		public var counterAchivePanel:Bitmap;
		public var achiveCounter:TextField;
		private var achiveCounterCont:Sprite;
		
		public var lightBoost:BoostEffect;
		public var counterCollPanel:Bitmap;
		public var seaweedDecoration:Bitmap;
		public var collCounter:TextField;
		private var collCounterCont:Sprite;
		
		public var tresureIcons:Array = [];
		public var bttnMainGifts:ImagesButton;
		public var bttnCursor:ImagesButton;
		public var bttnCursorExp:ImagesButton;
		public var counterPanel:Bitmap;
		public var counterRequestPanel:Bitmap;
		public var giftCounter:TextField;
		public var requestCounter:TextField;
		private var giftCounterCont:Sprite;
		private var requestCounterCont:Sprite;
		public var bttns:Array = [];
		public var infoBttn:ImageButton;
		public var countRequest:int;
		//Подложки под кнопки
		private var bgIconsData:Object = {
		};
		
		//Иконки  по панелям
		
		//Нижняя-левая панелька
		public var iconsBottom:Array = [
			{name:'gift', 			icon:UserInterface.textures.giftsIcon, 			pos:{x:24.7, y:-33, ix:-5, iy:3,  					title:Locale.__e('flash:1382952379798'), 	description:Locale.__e('flash:1382952379799')}, 	click:onMainGifts},
			{name:'map', 			icon:UserInterface.textures.mapIcon, 			pos:{scaleBg:0.77, x:32.5, y:-103,ix:-6, iy:-3, 	title:Locale.__e('flash:1396961967928'), 	description:Locale.__e('flash:1396343775152')}, 	click:onMapClick},
			{name:'prix', 			icon:UserInterface.textures.prixIcon, 			pos:{scaleBg:0.77, x:174.4, y:-14.4, ix:-2, iy:4, 	title:Locale.__e('flash:1396961879671'), 	description:Locale.__e('flash:1396343692368')}, 	click:onPrixClick},
			{name:'collections',	icon:UserInterface.textures.collectionsIcon, 	pos:{scaleBg:0.77, x:107.4, y:-14.4,ix:-6, iy:4, 	title:Locale.__e('flash:1382952379800'), 	description:Locale.__e('flash:1396343809444')}, 	click:onCollectionsClick}
			
			];
		//Нижняя-правая панелька
		
		public var iconsMain:Array = [
			{name:'stock', 	icon:User.inExpedition?UserInterface.textures.ministock:UserInterface.textures.stockIcon, 		pos:{scaleBg:0.76, x:122, y:-81.5, ix:-0.5, iy:-4, 	title:User.inExpedition?Locale.__e('flash:1505901950203'):Locale.__e('flash:1382952380181'), 	description:Locale.__e('flash:1396343542646')}, 	click:onStockEvent},
			{name:'cursor', icon:UserInterface.textures.iconCursorMain, pos:{scaleBg:0.77, x:46, y:6.3,ix:8, iy:7, 			title:Locale.__e('flash:1382952379760'), 	description:Locale.__e('flash:1382952379761')}, 	click:onCursorsEvent,arrow:{x:30,y:5}},
			{name:'shop', 	icon:UserInterface.textures.shopIcon, 		pos:{scaleBg:1.0,x:114.5, y:-12,ix:-12, iy:-1, 		title:Locale.__e('flash:1382952379765'), 	description:Locale.__e('flash:1382952379766')}, 	click:onShopEvent},
			{name:'stop', 	icon:UserInterface.textures.stopBttnIco, 	pos:{scaleBg:0.487, x:-1, y:26, ix:3, iy:3, 		title:Locale.__e('flash:1396963190624'), 	description:Locale.__e('flash:1382952379763')}, 	click:onStopEvent}
		];
		//Нижняя-правая панелька в гостях		
		public var iconsMainFriend:Array = [
			{name:'stopFriend', icon:UserInterface.textures.stopBttnGuestIco, pos:{scaleBg:0.0001, x:68, y:30, ix:8, iy:8, title:Locale.__e('flash:1396963190624'), description:Locale.__e('flash:1382952379763')}, click:onStopEvent}
		];
		
		//Нижняя-правая панелька в экспедиции		
		public var iconsMainExp:Array = [
			{name:'cursorExp', icon:UserInterface.textures.iconCursorMove, pos: { scaleBg:0.8, x:58, y: -46, ix:10, iy:10, title:Locale.__e('flash:1382952379775'), description:Locale.__e('flash:1382952379775') }, click:onMoveCursor }
		];
		
		/*public function removeTresure(sid:int):void
		{
			var trIcon:TresureIcon;
			for (var i:int = 0; i < tresureIcons.length; i++ ) {
				trIcon = tresureIcons[i];
				if(sid == trIcon.sid){
					trIcon.dispose();
					trIcon = null;
					tresureIcons.splice(i, 1);
					resizeTresureIcons();
					break;
				}
			}
		}*/
		public var bttnChapters:ImageButton;
		private function createChaptersIcon():void {
			//return;
			//disposeChaptersIcon();
			
			var icon:Bitmap = new Bitmap(new BitmapData(75,75, true, 0), 'auto', true);
			bttnChapters = new ImagesButton(icon.bitmapData);
			
			bttnChapters.tip = function():Object { 
				return {
					title:Locale.__e("flash:1446805841616"),
					text:''
				};
			};
			
			bttnChapters.x = 100;
			bttnChapters.y = -90;
			bttnChapters.addEventListener(MouseEvent.CLICK, onChapters);
			
			Load.loading(Config.getImageIcon("quests/icons", "chapters"), function(data:Bitmap):void {
				bttnChapters.bitmapData = data.bitmapData;
				
				bttnChapters.initHotspot();
			});
			
			//bttnChapters.visible = false;
			//App.self.addEventListener(AppEvent.ON_LEVEL_UP, App.user.quests.getDaylics);
			
			iconsPanel.addChild(bttnChapters);
			//bttnChapters.visible = false;
			
			//resize();
		}
		
		private function onChapters(e:MouseEvent = null):void {
			
			//return
			var chaptersWindow:QuestsChaptersWindow = new QuestsChaptersWindow( {
				popup: true
			}
			);
			
			chaptersWindow.show();
			return;
			
			new QuestsChaptersWindow({}).show();
		}
		
		public function resizeTresureIcons():void
		{
			var posX:int = 0;// App.ui.bottomPanel.iconsPanel.x + App.ui.bottomPanel.iconsPanel.width;
			for (var i:int = 0; i < tresureIcons.length; i++ ) {
				
				tresureIcons[i].x = posX;
				tresureIcons[i].y = 0;// App.self.stage.stageHeight - tresureIcons[i].bg.height - 2;
				
				posX += tresureIcons[i].bg.width + 14;
				
			}
		}
		
		private var tresureCont:Sprite = new Sprite();
		public function addTresure(sid:int, roomSid:int):void
		{
			if (App.user.quests.tutorial) 
				tresureCont.visible = false;
			if (!canAddTresureIcon(sid)) return;
			
			var tresureIcon:TresureIcon = new TresureIcon(sid, roomSid);
			tresureIcons.push(tresureIcon);
			tresureCont.addChild(tresureIcon);
			resizeTresureIcons();
			
			tresureCont.x = App.ui.bottomPanel.iconsPanel.x + App.ui.bottomPanel.iconsPanel.width;
			tresureCont.y = App.self.stage.stageHeight - 82;
			
			if(!App.user.quests.isTutorial){
				var winSettings:Object = {
					title				:App.data.storage[roomSid].title,
					text				:Locale.__e('flash:1402926875000'),
					instanceId          :sid,
					closeAfterOk        :true
				};
				if(App.user.worldID == App.data.storage[tresureIcon.sid].land && App.user.mode == User.OWNER && !TresureWindow.isOpen)
					new TresureWindow(winSettings).show();
			}
		}
		
		private function canAddTresureIcon(sid:int):Boolean 
		{
			for (var i:int; i < tresureIcons.length; i++ ) {
				if (tresureIcons[i].sid == sid) {
					return false;
				}
			}
			return true;
		}
		
		
		private var dY:int = 0;
		public function resize():void 
		{
			if (tweenIcons) {
				tweenIcons.kill();
				tweenIcons = null;
			}
			if (tweenMain) {
				tweenMain.kill();
				tweenMain = null;
			}
			
			if (isShowMain) {
				mainPanel.y = App.self.stage.stageHeight - 71;
			}else {
				mainPanel.y = App.self.stage.stageHeight - 72 + dY;
			}
			mainPanel.x = App.self.stage.stageWidth - 196;
			
			
			if (User.inExpedition)
			{
				mainPanelFriend.x = 0;
				mainPanelFriend.y = App.self.stage.stageHeight - 108 + dY;
			}
			else
			{
				mainPanelFriend.x = App.self.stage.stageWidth - 250;
				mainPanelFriend.y = App.self.stage.stageHeight - 108 + dY;
			}
			
			mainPanelExp.x = App.self.stage.stageWidth - 195;
			mainPanelExp.y = App.self.stage.stageHeight - 108 + dY + 35;
			
			if (iconsPanel)
			{
				iconsPanel.x = -4;
				iconsPanel.y = App.self.stage.stageHeight - 52 +dY;
			}
			
			if (friendsPanel) 
			{
				friendsPanel.resize(mainPanelFriend.visible);
				if (mainPanelFriend.visible) 
				{
					friendsPanel.x = -100;
				}else 
				{
					friendsPanel.x = 120;
				}
				friendsPanel.y = App.self.stage.stageHeight - 94 + dY;
			}
			
			tresureCont.x = App.ui.bottomPanel.iconsPanel.x + App.ui.bottomPanel.iconsPanel.width;
			tresureCont.y = App.self.stage.stageHeight - 82;
			
			//homeQuitBttn.scaleX = homeQuitBttn.scaleY = 0.9;
			//homeQuitBttn.textLabel.height = 52;
			//homeQuitBttn.x = App.ui.bottomPanel.friendsPanel.x + App.ui.bottomPanel.friendsPanel.width/2
			//homeQuitBttn.y = App.ui.bottomPanel.friendsPanel.y - 40;
			//homeQuitBttn.addEventListener(MouseEvent.CLICK, onQuit);
			//worldPanel.y = friendsPanel.y - worldPanel.height + 20;
			//worldPanel.x = friendsPanel.x + friendsPanel.width - worldPanel.width + 60;			
			//worldPanel.resize();
			createInfoIcon()
			//createWorldPanel();
		}
		
		public function hide(tween:Boolean = false):void {
			dY = 100;
			mainPanel.visible = false;
			friendsPanel.visible = false;
			iconsPanel.visible = false;
			
			resize();
		}
		
		public function show(only:String = ''):void {
			dY = 0;
			mainPanel.visible = true;
			TweenLite.to(mainPanel, 0.5, { y:App.self.stage.stageHeight - 85 + dY } );
			if (only == 'mainPanel') return;
			
			var finY:int;
			if (iconsPanel) {
				if (!friendsPanel.opened) 	finY = App.self.stage.stageHeight - 52 + dY;
				else						finY = App.self.stage.stageHeight + 20 + dY;
			}
			TweenLite.to(iconsPanel, 0.5, { y:finY } );
			
			if (friendsPanel) {
				if(friendsPanel.opened) 	finY = App.self.stage.stageHeight - 72 + dY;
				else						finY = App.self.stage.stageHeight + 20 + dY;
			}
			
			TweenLite.to(friendsPanel, 0.5, { y:finY } );
			friendsPanel.visible = true;
			iconsPanel.visible = true;
		}
		
		public function drawMainPanel():void {
			
			var _bmp:Bitmap = new Bitmap(UserInterface.textures.bottom_right_back);
			mainPanel = new Sprite();
			_bmp.x = -94; //-98 було
			_bmp.y = -98;
			//_bmp.alpha = 0.6;
			mainPanel.addChild(_bmp);
			mainPanel.x = App.self.stage.stageWidth + 220;
			mainPanel.y = App.self.stage.stageHeight + 85;
			addChild(mainPanel);
			
			
			//addChild(worldPanel);
			
			/*homeQuitBttn = new Button( {
					width:		140,
					height:		52,
					caption:	Locale.__e("flash:1444656653841"),
					fontSize:	38,
					multiline:  true,
					bgColor:	[0xfac986,0xf2ad51],
					borderColor:[0xffeede,0xbcbaa6],
					fontBorderColor: 0x9e5b30,
					bevelColor:	[0xfeebc3,0xbd6e35]
			});
			addChild(homeQuitBttn);
			
			homeQuitBttn.visible = false*/
			
			drawIconsToPanel(iconsMain, mainPanel);
			
			drawChatIcon();
			if (Invites.externalPermission) {
				//inviteMargin = 90;
				
				if (!inviteBttn) {
					inviteBttn = drawInviteBttn();
					inviteBttn.y = -50;
					inviteBttn.x = -30;
					mainPanel.addChild(inviteBttn);
					updateInviteCounter();
					App.invites.addEventListener(Event.CHANGE, updateInviteCounter);
				}
			}						
		}
		
		/*private function onQuit(e:MouseEvent):void {
			Travel.goTo(806);
			homeQuitBttn.visible = false;
		}*/
		
		public var dinamiteSprite:Sprite;
		public function drawSellDinamiteBttn():void 
		{
			var dinamiteBttn:ImageButton = new ImageButton(UserInterface.textures.dinamite);
			dinamiteSprite = new Sprite();
			dinamiteBttn.addEventListener(MouseEvent.CLICK, onDinamiteBttn);
			var bg:Bitmap = new Bitmap(UserInterface.textures.mainBttnBacking);
			bg.scaleX = bg.scaleY = .7;
			bg.smoothing = true;
			dinamiteSprite.addChild(bg);
			dinamiteSprite.addChild(dinamiteBttn);
			mainPanel.addChild(dinamiteSprite);
			dinamiteBttn.x = dinamiteBttn.height/2 -60;
			dinamiteBttn.y = dinamiteBttn.width / 2 +24;
			bg.x = dinamiteBttn.x-(bg.width-dinamiteBttn.width)/2;
			bg.y = dinamiteBttn.y - (bg.height - dinamiteBttn.height) / 2;
			
			dinamiteSprite.visible = false;
			
		}
		
		public var knifeSprite:Sprite;
		public function drawSellKnifeBttn():void 
		{
			var knifeBttn:ImageButton = new ImageButton(UserInterface.textures.knife);
			knifeSprite = new Sprite();
			knifeBttn.addEventListener(MouseEvent.CLICK, onKnifeBttnBttn);
			var bg:Bitmap = new Bitmap(UserInterface.textures.mainBttnBacking);
			bg.scaleX = bg.scaleY = .7;
			bg.smoothing = true;
			knifeSprite.addChild(bg);
			knifeSprite.addChild(knifeBttn);
			mainPanel.addChild(knifeSprite);
			knifeBttn.x = knifeBttn.height/2 -120;
			knifeBttn.y = knifeBttn.width / 2 +24;
			bg.x = knifeBttn.x-(bg.width-knifeBttn.width)/2;
			bg.y = knifeBttn.y - (bg.height - knifeBttn.height) / 2;
			
			knifeSprite.visible = false;
			
		}
		
		public var lightSprite:Sprite;
		public function drawSellLightBttn():void 
		{
			var lightBttn:ImageButton = new ImageButton(UserInterface.textures.lightSphere);
			lightSprite = new Sprite();
			lightBttn.addEventListener(MouseEvent.CLICK, onLightBttnBttn);
			
			var bg:Bitmap = new Bitmap(UserInterface.textures.mainBttnBacking);
			bg.scaleX = bg.scaleY = .7;
			bg.smoothing = true;
			lightSprite.addChild(bg);
			lightSprite.addChild(lightBttn);
			//mainPanel.addChild(lightSprite);
			lightBttn.x = lightBttn.height/2 -164;
			lightBttn.y = lightBttn.width / 2 - 7 ;
			bg.x = lightBttn.x-(bg.width-lightBttn.width)/2;
			bg.y = lightBttn.y - (bg.height - lightBttn.height) / 2;
			
			if (App.user.stock.data[Stock.LIGHT_RESOURCE]>App.time) 
			{
				lightSprite.addChild(lightBoost);
				lightBoost.x  = lightBttn.x;
				lightBoost.y  = lightBttn.y;
				lightBoost.show(Locale.__e('flash:1441631836410'));
				lightSprite.visible = false;
			}
			//lightSprite.visible = false;
			
		}
		
		private function onLightBttnBttn(e:MouseEvent):void 
		{
			new PurchaseWindow( {
				width:210,
				itemsOnPage:1,
				closeAfterBuy:false,
				autoClose:false,
				content:PurchaseWindow.createContent("Vip", {view:['light_sphere']}),
				title:App.data.storage[Stock.LIGHT_RESOURCE].title,
				popup:true,
				description:Locale.__e("flash:1382952379757")
			}).show();
		}
		
		public var minePickSprite:Sprite;
		public function drawSellMinePickBttn():void {
			var minePickBttn:ImageButton = new ImageButton(UserInterface.textures.minePick);  // pick icon
			minePickSprite = new Sprite();
			minePickBttn.addEventListener(MouseEvent.CLICK, onMinePickBttn);
			var bg:Bitmap = new Bitmap(UserInterface.textures.mainBttnBacking);
			bg.scaleX = bg.scaleY = .7;
			bg.smoothing = true;
			minePickSprite.addChild(bg);
			minePickSprite.addChild(minePickBttn);
			mainPanelFriend.addChild(minePickSprite);
			minePickBttn.x = minePickBttn.height/2 - 120;
			minePickBttn.y = minePickBttn.width / 2 + 24;
			bg.x = minePickBttn.x - (bg.width - minePickBttn.width)/2;
			bg.y = minePickBttn.y - (bg.height - minePickBttn.height) / 2;
			
			minePickSprite.visible = false;
		}
		
		private function onKnifeBttnBttn(e:MouseEvent):void 
		{
			new PurchaseWindow( {
					width:550,
					itemsOnPage:3,
					closeAfterBuy:false,
					autoClose:false,
					content:PurchaseWindow.createContent("Energy", {view:['knife']}),
					title:App.data.storage[709].title,
					popup:true,
					description:Locale.__e("flash:1382952379757")
				}).show();
		}
		
		private function onDinamiteBttn(e:MouseEvent):void 
		{
			new PurchaseWindow( {
					width:550,
					itemsOnPage:3,
					//content:PurchaseWindow.createContent("Firework"),
					content:PurchaseWindow.createContent("Firework", {backview:['dinamite_1']}),
					title:App.data.storage[645].title,
					popup:true,
					closeAfterBuy:false,
					autoClose:false,
					description:Locale.__e("flash:1382952379757")
				}).show();
		}
		
		private function onMinePickBttn(e:MouseEvent):void 
		{
			new PurchaseWindow( {
					width:550,
					itemsOnPage:3,
					content:PurchaseWindow.createContent("Energy", {view:['picker']}),
					title:App.data.storage[271].title,
					popup:true,
					closeAfterBuy:false,
					autoClose:false,
					description:Locale.__e("flash:1382952379757")
				}).show();
		}
		
		public var tentStockSprite:Sprite;
		public function drawTentStock():void 
		{
			var tentButtonExp:ImageButton = new ImageButton(UserInterface.textures.smile);
			tentStockSprite = new Sprite();
			var bg:Bitmap = new Bitmap(UserInterface.textures.interRoundBttn);
			var bg2:Bitmap = new Bitmap(UserInterface.textures.mainBttnBacking);
			bg.scaleX = bg.scaleY = 1;
			bg2.scaleX = bg.scaleY = 1;
			bg.smoothing = true;
			bg2.smoothing = true;
			tentStockSprite.addChild(bg2);
			tentStockSprite.addChild(bg);
			tentStockSprite.addChild(tentButtonExp);
			
			tentButtonExp.addEventListener(MouseEvent.CLICK, onStockEvent);
			mainPanel.addChild(tentStockSprite);
			tentButtonExp.x = tentButtonExp.height/2 + 90;
			tentButtonExp.y = tentButtonExp.width / 2 - 32;
			bg2.x = tentButtonExp.x - (bg2.width - tentButtonExp.width)/2;
			bg2.y = tentButtonExp.y - (bg2.height - tentButtonExp.height) / 2;
			bg.x = tentButtonExp.x - (bg.width - tentButtonExp.width)/2;
			bg.y = tentButtonExp.y - (bg.height - tentButtonExp.height) / 2;
			
			tentStockSprite.visible = false;
		}
		
		
		
		public var inviteBttn:ImageButton;
		private var counterBack:Bitmap;
		private var counterLabel:TextField;
		private function drawInviteBttn():ImageButton {
			var imageBttn:ImageButton = new ImageButton(Window.textures.viralAborigine);
			imageBttn.addEventListener(MouseEvent.CLICK, onInvite);
			
			var titleLabel:TextField = Window.drawText(Locale.__e('flash:1415782880933'), {
				fontSize:		16,
				color:			0xfcefc3,
				borderColor:	0x80480f,
				autoSize:		'center'
			});
			titleLabel.x = (imageBttn.width - titleLabel.width) / 2 ;
			titleLabel.y = 62;
			imageBttn.addChild(titleLabel);
			
			counterBack = new Bitmap(UserInterface.textures.simpleCounterGreen, 'auto', true);
			counterBack.x = 75;
			counterBack.y = 45;
			counterBack.name = 'counterBack';
			counterBack.visible = false;
			imageBttn.addChild(counterBack);
			
			counterLabel = Window.drawText('', {
				fontSize:		18,
				color:			0xfdfcc6,
				borderColor:	0xad1818,
				textAlign:		'center',
				width:			40
			});
			counterLabel.x = counterBack.x + (counterBack.width - counterLabel.width) / 2;
			counterLabel.y = counterBack.y + (counterBack.height - counterLabel.height) / 2 + 2;
			counterLabel.name = 'counter';
			counterLabel.visible = false;
			imageBttn.addChild(counterLabel);
			return imageBttn;
		}
		public function updateInviteCounter(e:Event = null):void {
			if (!App.invites || !App.invites.inited) return;
			
			var count:int = /*Numbers.countProps(App.invites.invited); +*/ Numbers.countProps(App.invites.requested);
			if (count > 0) {
				counterLabel.text = String(count);
				counterLabel.visible = true;
				counterBack.visible = true;
			}else {
				counterLabel.visible = false;
				counterBack.visible = false;
			}
		}
		private function onInvite(e:MouseEvent):void {
			if (App.user.mode == User.OWNER&&!App.user.quests.tutorial)
				new InvitesWindow().show();
		}
		
		private function drawMainPanelFriend():void {
			mainPanelFriend = new Sprite();
			mainPanelFriend.x = App.self.stage.stageWidth;
			mainPanelFriend.y = App.self.stage.stageHeight;
			
			var bitmapa:Bitmap = new Bitmap(UserInterface.textures.bottom_right_back_guest);
			addChild(mainPanelFriend);
			//mainPanel = new Sprite();
			bitmapa.x = -37; //-98 було
			bitmapa.y = -27;
			//_bmp.alpha = 0.6;
			mainPanelFriend.addChild(bitmapa);
			/*mainPanel.x = App.self.stage.stageWidth + 220;
			mainPanel.y = App.self.stage.stageHeight + 85;
			addChild(mainPanel);*/
			
			drawSellDinamiteBttn();
			//if (App.user.worldID != 1001){
			//if (User.inUpdate(Stock.PENKNIFE)) 
			//{
				//drawSellKnifeBttn();
			//}
			lightBoost = new BoostEffect(-3, 6);
			/*if (User.inUpdate(Stock.LIGHT_RESOURCE)) 
			{*/
				//drawSellLightBttn();
			/*}*/
				
			//} else {
			/*if (User.inUpdate(Stock.MINEPICK)) 
			{
				drawSellMinePickBttn();
			}*/
				
			//}
			//if (User.inExpedition)
				//drawTentStock();
			mainPanelExp = new Sprite();
			mainPanelExp.x = App.self.stage.stageWidth;
			mainPanelExp.y = App.self.stage.stageHeight;
			addChild(mainPanelExp);
			mainPanelExp.visible = false;
			mainPanelFriend.visible = false;
			
			
			bttnMainHome = new ImageButton(UserInterface.textures.guest_home_button);
			var homeText:TextField = Window.drawText(Locale.__e('flash:1382952379764'), {
				fontSize:18,
				color:0xffffff,
				borderColor:0x884a25,
				autoSize:"center",
				textAlign:"center",
				multiline:true
			});
			
			mainPanelFriend.addChild(bttnMainHome);
			mainPanelFriend.addChild(homeText);
			bttnMainHome.x = bitmapa.x + bitmapa.width - bttnMainHome.width - 24;
			bttnMainHome.y = 16;
			homeText.x = bttnMainHome.x + (bttnMainHome.width - homeText.width) /2;
			homeText.y = bttnMainHome.y + bttnMainHome.height - homeText.height / 2;
			//bttnMainHome.name = 'bttn_home';
			bttnMainHome.addEventListener(MouseEvent.CLICK, function():void {
				bttnMainHome.hidePointing();
				bttnMainHome.hideGlowing();
				/*if (App.user.ministock.hasOwnProperty('items') && App.user.ministock.items ) {
					for (var req:* in App.user.ministock.items) {
						if (App.user.ministock.items[req])
							break;
					}
				}*/
				//trace(App.self.getLength(App.user.ministock.items));
				if (((App.user.ministock.hasOwnProperty('items'))?(ShipWindow.countMinistock == ShipWindow.limitMinistock):0) || !User.inExpedition) {
					Travel.goHome();
				}else {
					if(User.inExpedition){
						new SimpleWindow( {
							title:Locale.__e('flash:1422866083955'),
							text:Locale.__e('flash:1422866167804'),
							label:SimpleWindow.ATTENTION,
							textSize:(App.isSocial("AI","YB","MX"))?16:24,
							dialog:true,
							isImg:true,
							confirm:function():void {
								Travel.goHome();
							}
						}).show();
					}
				}
				
			});
			
			bttnMainHome.tip = function():Object {
				return {
					title:Locale.__e("flash:1382952379764"),
					text:Locale.__e("flash:1382952379769")
				};
			}
			
			//homeText.border = true;
			/*= new UpgradeButton(UpgradeButton.TYPE_ON,{
				caption: Locale.__e("flash:1382952379764"),
				width:236,
				height:55,
				fontBorderColor:0x6f2700,
				countText:"",
				fontSize:(App.isSocial('YB','MX','AI'))?32:42,
				iconScale:0.95,
				radius:30,
				textAlign:'left',
				autoSize:'left',
				widthButton:195
			});*/
			//bttnMainHome.textLabel.x = (bttnMainHome.width - bttnMainHome.textLabel.width)/2;
			
			
			if (!User.inExpedition)
			{
				drawIconsToPanel(iconsMainFriend, mainPanelFriend);
			}
			
			
			drawIconsToPanel(iconsMainExp, mainPanelExp);
			
		}
		
		
		private function drawBgIcons():void 
		{
			for (var key:* in bgIconsData) 
			{
				//if (User.inExpedition)
					//if (key == "stopFriend" || key == "shop" || key == "cursor" || key == "stock" || key == "gift")
						
				drawBgIcon(key, bgIconsData[key]);
				
				if (User.inExpedition)
					if (key == "stopFriend" || key == "shop" || key == "cursor" || key == "stock" || key == "gift")
						(objectBgIcon[key] as Bitmap).visible = false;
			}
		}
		
		public var objectBgIcon:Object = new Object(); 
		
		private function drawBgIcon(key:String, data:Object):void 
		{
			var bg:Bitmap = new Bitmap(UserInterface.textures[data.bg]);
			
			bg.scaleX = bg.scaleY = data.scale;
			bg.smoothing = true;
			
			bg.x = data.x;
			bg.y = data.y;
			
			if (data.main){
				mainPanel.addChildAt(bg,1);
			}		
			if (data.mainFriend){
				mainPanelFriend.addChildAt(bg,1);
			}
			if (data.icons){
				iconsPanel.addChildAt(bg,1);
			}
			if (data.mainExp){
				mainPanelExp.addChildAt(bg,0);
			}
			
			objectBgIcon[key] = bg;
		}
		
		private function onMainGifts(e:MouseEvent):void
		{
			//if (App.user.quests.tutorial)
				//return;
			
			if (App.user.gifts.length == 0)
				new FreeGiftsWindow().show();
			else		
				new FreeGiftsWindow( {
					mode:FreeGiftsWindow.TAKE
				}).show();
		}
		
		public static function drawPanelBg(_width:int, textureName:String = 'panelCorner'):Bitmap {
			var bg:Sprite = new Sprite();
			var texture:BitmapData = Window.texture(textureName);// UserInterface.textures[textureName];
			var leftSide:Bitmap = new Bitmap(texture);
			var rightSide:Bitmap = new Bitmap(texture);
			var midSideBMD:BitmapData = new BitmapData(1, rightSide.height, true, 0);
			midSideBMD.copyPixels(texture, new Rectangle(leftSide.width - 1, 0, 1, leftSide.height), new Point());
			var midSide:Bitmap = new Bitmap(midSideBMD);
			var midleWidth:int = _width - leftSide.width * 2;
			
			bg.addChild(leftSide);
			bg.addChild(rightSide);
			bg.addChild(midSide);
			leftSide.x = 0;
			midSide.x = leftSide.x + leftSide.width;
			rightSide.scaleX = -1;
			rightSide.x = midleWidth + leftSide.width + rightSide.width;
			midSide.width = midleWidth;
			
			var resultBMD:BitmapData = new BitmapData(bg.width, bg.height, true, 0);  // картинка понадобится для бекграунда
			resultBMD.draw(bg);  // рисуем бекграунд - подложку под айтемы друзей
			
			return new Bitmap(resultBMD);
		}
		
		public function drawChatIcon():void 
		{
			bttnChat = new ImageButton(UserInterface.textures.chatIcon);
			mainPanel.addChild(bttnChat);
			//mainPanelFriend.addChild(bttnChat);
			bttnChat.tip = function():Object {
				return {
					title:Locale.__e("flash:1503904484912"),
					text:Locale.__e("flash:1503904516190")
				};
			}
			bttnChat.addEventListener(MouseEvent.CLICK, onChatClick);
			bttnChat.x = -22;
			bttnChat.y = 10;
			bttnChat.visible = false;
		}
		
		public function drawIconsPanel():void 
		{
			addChild(iconsPanel);
			
			drawIconsToPanel(iconsBottom, iconsPanel);
			//var bg:Bitmap = new Bitmap(UserInterface.textures.compass);
			var bg:Bitmap = new Bitmap(UserInterface.textures.bottom_left_back);
			bg.x = -5;
			bg.y = -117;
			//bg.alpha = 0.6;
			iconsPanel.addChildAt(bg, 0);
		}
	
		public var iconsObject:Object = new Object();
		
		public function redrawStockBttn():void
		{
			mainPanel.removeChild(bttnMainStock);
			
			bttnMainStock = new ImagesButton(UserInterface.textures.interRoundBttn, UserInterface.textures.ministock, iconsMain[0].pos);
			bttnMainStock.iconBmp.x -= 5;
			bttnMainStock.iconBmp.y -= 5;
			addButtons(bttnMainStock, iconsMain[0], mainPanel);
			title = Window.drawText(Locale.__e('flash:1505901950203'), {
					fontSize	:16,
					color		:0xfcf6e4,
					borderColor	:0x814f31,
					multiline	:true,
					textAlign	:"center",
					//width		:bttnObject.icon.width + 10,
					autoSize	:"center"
				});
			title.x = iconsMain[0].pos.ix + (bttnMainStock.width - title.width) / 2 - 10;
			title.y = (bttnMainStock.height ) - 30;
			bttnMainStock.addChild(title);
			
			bttnMainStock.tip = function():Object {
				return {
					title:Locale.__e('flash:1505901950203'),
					text:Locale.__e('flash:1505901987794')
				}
			}
		}
		
		public function drawDefaultStockBttn():void 
		{
			mainPanel.removeChild(bttnMainStock);
			
			bttnMainStock = new ImagesButton(UserInterface.textures.interRoundBttn, iconsMain[0].icon, iconsMain[0].pos);
			addButtons(bttnMainStock, iconsMain[0], mainPanel);
			title = Window.drawText(iconsMain[0].pos.title, {
					fontSize	:16,
					color		:0xfcf6e4,
					borderColor	:0x814f31,
					multiline	:true,
					textAlign	:"center",
					//width		:bttnObject.icon.width + 10,
					autoSize	:"center"
				});
			title.x = iconsMain[0].pos.ix + (bttnMainStock.width - title.width) / 2;
			title.y = (bttnMainStock.height ) - 18;
			bttnMainStock.addChild(title);
			
			bttnMainStock.tip = function():Object {
				return {
					title:iconsMain[0].pos.title,
					text:iconsMain[0].pos.description
					
				}
			}
		}
		public function drawIconsToPanel(iconsArray:Array, panel:Sprite):void 
		{
			bttns.splice(0, bttns.length);
			for (var i:int = 0; i < iconsArray.length; i++) 
			{
				
				var bttnObject:Object = iconsArray[i];
				
				var back:BitmapData = UserInterface.textures.interRoundBttn;//Подложка под основными кнопками интерфейса
				var backBack:BitmapData = UserInterface.textures.interRoundBttn;
				title = Window.drawText(iconsArray[i].pos.title, {
					fontSize	:16,
					color		:0xfcf6e4,
					borderColor	:0x814f31,
					multiline	:true,
					textAlign	:"center",
					//width		:bttnObject.icon.width + 10,
					autoSize	:"center"
				});
				/*var dX:int = 0;
				switch(App.social){
					case 'FB'	: dX = -5; break;
				}*/
				switch (iconsArray[i].name) 
				{
					case 'shop':
						bttnMainShop = new ImagesButton(back, bttnObject.icon, bttnObject.pos);	
						addButtons(bttnMainShop, bttnObject, panel);
						
						title.x = bttnObject.pos.ix + (bttnMainShop.width - title.textWidth) / 2;
						title.y = (bttnMainShop.height ) - 18;
						//title.border = true;
						bttnMainShop.addChild(title);
						iconsObject[iconsArray[i].name] = bttnMainShop;
						break;
					case 'stock':
						bttnMainStock = new ImagesButton(back, bttnObject.icon, bttnObject.pos);	
						addButtons(bttnMainStock, bttnObject, panel);
						
						title.x = bttnObject.pos.ix + (bttnMainStock.width - title.width) / 2;
						title.y = (bttnMainStock.height ) - 18;
						//title.border = true;
						bttnMainStock.addChild(title);
						iconsObject[iconsArray[i].name] = bttnMainStock;
						break;
					case 'gift':
						bttnMainGifts = new ImagesButton(back, bttnObject.icon, bttnObject.pos);	
						addButtons(bttnMainGifts, bttnObject, panel);
						
						title.x = bttnObject.pos.ix + (bttnMainGifts.width - title.width) / 2;
						title.y = (bttnMainGifts.height ) - 18;
						//title.border = true;
						bttnMainGifts.addChild(title);
						iconsObject[iconsArray[i].name] = bttnMainGifts;
						break;
					case 'stop':
						bttnStop = new ImagesButton(back, bttnObject.icon, bttnObject.pos);	
						addButtons(bttnStop, bttnObject, panel);
						iconsObject[iconsArray[i].name] = bttnStop;
						break;
					case 'cursor':
						bttnCursor = new ImagesButton(back, bttnObject.icon, bttnObject.pos);	
						addButtons(bttnCursor, bttnObject, panel);
						iconsObject[iconsArray[i].name] = bttnCursor;
						break;
					case 'stopFriend':
						bttnStopFriends = new ImagesButton(back, bttnObject.icon, bttnObject.pos);	
						addButtons(bttnStopFriends, bttnObject, panel);
						iconsObject[iconsArray[i].name] = bttnStopFriends;
						break;
					case 'cursorExp':
						bttnCursorExp = new ImagesButton(back, bttnObject.icon, bttnObject.pos);	
						addButtons(bttnCursorExp, bttnObject, panel);
						iconsObject[iconsArray[i].name] = bttnCursorExp;
						break;
					case 'map':
						bttnMainMap = new ImagesButton(back, bttnObject.icon, bttnObject.pos);
						addButtons(bttnMainMap, bttnObject, panel);
						
						title.x = bttnObject.pos.ix + (bttnMainMap.width - title.width) / 2;
						//title.border = true;
						title.y = bttnMainMap.height - 18;
						bttnMainMap.addChild(title);
						
						iconsObject[iconsArray[i].name] = bttnMainMap;
						break;
					
					default:
						var bttn:ImagesButton = new ImagesButton(back, bttnObject.icon, bttnObject.pos);
						addButtons(bttn, bttnObject, panel);
						
						title.x = bttnObject.pos.ix + (bttn.width - title.width) / 2;
						title.y = bttn.height -18;
						//title.border = true;
						bttn.addChild(title);
						
						iconsObject[iconsArray[i].name] = bttn;
						break
				}
				//var bttn:ImagesButton = new ImagesButton(back, bttnObject.icon, bttnObject.pos);	
				/*if (User.inExpedition)
					if (iconsArray[i].name == "shop"  || iconsArray[i].name == "cursor" || iconsArray[i].name == "stock")
					{
						(iconsObject[iconsArray[i].name] as ImagesButton).visible = false;
					}*/
			}
		
		}
		
		private function addButtons(bttn:ImagesButton,bttnObject:Object,panel:Sprite):void 
		{
			bttn.addEventListener(MouseEvent.CLICK, bttnObject.click);
			bttnObject['bttn'] = bttn;
			panel.addChild(bttn);

			bttn.x = bttnObject.pos.x;
			bttn.y = bttnObject.pos.y;
			bttns.push(bttn);
		
			if (bttnObject.arrow is Object)
			{
			//	bttn.addChildAt(openArrow,1);
	
				//openArrow.x = 30;
				//openArrow.y = 5;
				////trace('blueArrow')
				makeCursorsPanel(bttn)
			}
			
			addTip(bttn);
			
			function addTip(bttn:*):void{
				bttn.tip = function():Object {
					return {
						title:bttn.settings.title,
						text:bttn.settings.description
						
					}
				}
			
			}
		}
		
		private function onFriendsClick(e:MouseEvent):void 
		{
			if (App.user.quests.tutorial)
				return;
				
			showFriendsPanel();
			
			for (var s:String in App.data.updatelist[App.social]) 
			{
				var update:Object = 
				{
					nid: s,
					update: App.data.updates[s],
					order: App.data.updatelist[App.social][s]
				}
				break;
			}
		}
		
		private function onChatClick(e:MouseEvent):void 
		{
			if(ChatField.self)
				ChatField.self.dispose();
			else
				ChatField.show();
		}
		
		private function onPrixClick(e:MouseEvent):void 
		{
			new AchivementsWindow().show();
			App.ui.bottomPanel.bttns[3].hidePointing();
		}
		
		private function onMapClick(e:MouseEvent):void 
		{
			Cursor.accelerator = false;
			App.ui.rightPanel.onMapClick(e);
		}
		
		private function onCollectionsClick(e:MouseEvent):void 
		{
			if (User.inExpedition && !Config.admin)
				return;
			new CollectionWindow().show();
		}
		
		public var friendsPanel:FriendsPanel;
		public function showFriendsPanel():void 
		{
			//removeFriendsInt();
			friendsPanel.resize(mainPanelFriend.visible);
			friendsPanel.opened = true;
			if (App.user.fmode == Friends.FAV)
				friendsPanel.searchFriends("", Friends.favorites)	
			else
				friendsPanel.searchFriends("")
			friendsPanel.y = App.self.stage.stageHeight + 20;
			friendsPanel.visible = true;
			friendsPanel.x = 120;
			//TweenLite.to(iconsPanel, 0.5, { y:App.self.stage.stageHeight + 40 } );
			TweenLite.to(iconsPanel, 0.5, { y:App.self.stage.stageHeight - 52 } );
			
			TweenLite.to(friendsPanel, 0.5, { y:App.self.stage.stageHeight - 94 } );
			
			tresureCont.visible = false;
		}
		
		public function hideFriendsPanel():void 
		{
			//removeFriendsInt();
			
			friendsPanel.opened = false;
			TweenLite.to(iconsPanel, 0.5, { y:App.self.stage.stageHeight - 52 } );
			TweenLite.to(friendsPanel, 0.5, { y:App.self.stage.stageHeight + 45 } );
			
			tresureCont.visible = true;
		}
		
		public var hideFriendsInt:int;
		
		public function BottomPanel()
		{
			counterMapPanel = new Bitmap(UserInterface.textures.simpleCounterRed);
			counterBlue = new Bitmap(UserInterface.textures.simpleCounterBlue);
			counterYellow = new Bitmap(UserInterface.textures.simpleCounterYellow);
			counterAchivePanel = new Bitmap(UserInterface.textures.simpleCounterRed);
			counterCollPanel = new Bitmap(UserInterface.textures.simpleCounterRed);
				
			friendsPanel = new FriendsPanel(this);
			addChild(friendsPanel);
				
			friendsPanel.visible = false;
			
			drawMainPanel();
			drawMainPanelFriend();
			drawIconsPanel();
			drawBgIcons();
			addChild(friendsPanel);
			
			//addChild(worldPanel);
			//worldPanel.x = App.self.stage.stageWidth;
			//worldPanel.y = App.self.stage.stageHeight;			
			
			addChild(tresureCont);
			
			var textSettings:Object = {
				color:0xf0e9db,
				borderColor:0x8c3116,
				fontSize:16,
				textAlign:"center"
			};
			
			var textBlueSettings:Object = {
				color:0xf0e9db,
				borderColor:0x005ab4,
				fontSize:16,
				textAlign:"center"
			};
			
			var textYellowSettings:Object = {
				color:0xf0e9db,
				borderColor:0x7e3e13,
				fontSize:16,
				textAlign:"center"
			};
			
			
			counterMapPanel.x = -12;
			counterMapPanel.y = -10;
			
			//trade count
			mapCounter = Window.drawText(String(25), textSettings);
			mapCounter.width = 60;
			mapCounter.height = mapCounter.textHeight;
			mapCounter.x = (counterMapPanel.x - counterMapPanel.width / 2) - 1;
			mapCounter.y = (counterMapPanel.y + counterMapPanel.height/2 - mapCounter.height / 2) - 1;
			
			mapCounterCont = new Sprite();
			mapCounterCont.addChild(counterMapPanel);
			mapCounterCont.addChild(mapCounter);
			mapCounterCont.x = bttns[1].x + 50;
			mapCounterCont.y = bttns[1].y - 1;
			mapCounterCont.mouseChildren = mapCounterCont.mouseEnabled = false;
			
			//achive count
			achiveCounter = Window.drawText(String(25), textSettings);
			achiveCounter.width = 60;
			achiveCounter.height = achiveCounter.textHeight;
			achiveCounter.x = counterAchivePanel.width / 2 - 30;
			achiveCounter.y = counterAchivePanel.height / 2 - achiveCounter.height / 2 - 1;
			
			achiveCounterCont = new Sprite();
			achiveCounterCont.addChild(counterAchivePanel);
			achiveCounterCont.addChild(achiveCounter);
			achiveCounterCont.x = bttns[2].x + 40;
			achiveCounterCont.y = bttns[2].y - 12;
			achiveCounterCont.mouseChildren = achiveCounterCont.mouseEnabled = false;
			
			//collection count
			collCounter = Window.drawText(String(25), textSettings);
			collCounter.width = 60;
			collCounter.height = collCounter.textHeight;
			collCounter.x = counterCollPanel.width / 2 - 30;
			collCounter.y = counterCollPanel.height / 2 - collCounter.height / 2 - 1;
			
			collCounterCont = new Sprite();
			collCounterCont.addChild(counterCollPanel);
			collCounterCont.addChild(collCounter);
			collCounterCont.x = bttns[3].x + 40;
			collCounterCont.y = bttns[3].y - 12;
			collCounterCont.mouseChildren = collCounterCont.mouseEnabled = false;
			
			iconsPanel.addChild(mapCounterCont);
			iconsPanel.addChild(achiveCounterCont);
			iconsPanel.addChild(collCounterCont);
			
			mapCounterCont.visible = false;
			
			counterPanel = new Bitmap(UserInterface.textures.simpleCounterBlue);
			counterRequestPanel = new Bitmap(UserInterface.textures.simpleCounterYellow);
			
			counterPanel.y -= 25;
			counterPanel.x -= 17;
			
			counterRequestPanel.y -= 25;
			counterRequestPanel.x -= 90;
			
			giftCounter = Window.drawText(String(25), textBlueSettings);
			giftCounter.width = 60;
			giftCounter.height = giftCounter.textHeight;
			giftCounter.x = counterPanel.x+counterPanel.width / 2 - 31;
			giftCounter.y = counterPanel.y + counterPanel.height / 2 - giftCounter.height / 2 - 1;
			countRequest = WishListManager.totalFriendsRequests;	//ЗАМЕНИТЬ
			requestCounter = Window.drawText(String(countRequest), textYellowSettings);
			requestCounter.width = 60;
			requestCounter.height = giftCounter.textHeight;
			requestCounter.x = counterRequestPanel.x+ counterRequestPanel.width / 2 - 31;
			requestCounter.y = counterRequestPanel.y+ counterRequestPanel.height / 2 - requestCounter.height / 2 - 1;
			
			giftCounterCont = new Sprite();
			requestCounterCont = new Sprite();
			giftCounterCont.addChild(counterPanel);
			giftCounterCont.addChild(giftCounter);
			requestCounterCont.addChild(counterRequestPanel);
			requestCounterCont.addChild(requestCounter);
			giftCounterCont.x = bttns[1].x + 65;
			giftCounterCont.y = bttns[1].y + 95;
			requestCounterCont.x = bttns[1].x + 65;
			requestCounterCont.y = bttns[1].y + 95;
			iconsPanel.addChild(giftCounterCont);
			
			if(App.isSocial('FB', 'FBD'))
				iconsPanel.addChild(requestCounterCont);
				
			giftCounterCont.addEventListener(MouseEvent.CLICK, onMainGifts);
			
			giftCounter.text = String(App.user.gifts.length);
			if (App.user.gifts.length == 0) 
				giftCounterCont.visible = false;	
			else 							
				giftCounterCont.visible = true;	
			
			if (countRequest <= 0) 
				requestCounterCont.visible = false;	
			else 							
				requestCounterCont.visible = true;	
			
				
			updateMapCounter();
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, updateMapCounter);
			
			updateAchiveCounter();
			
			showFriendsPanel();
			
			createChaptersIcon();
		}
		
		public function updateGiftCount():void
		{
			giftCounter.text = String(App.user.gifts.length);
			if (App.user.gifts.length == 0) 
				giftCounterCont.visible = false;	
			else 							
				giftCounterCont.visible = true;	
			
			if (countRequest <= 0) 
				requestCounterCont.visible = false;	
			else 							
				requestCounterCont.visible = true;	
		}
		
		public function updateGiftCounter():void
		{
			giftCounter.text = String(App.user.gifts.length);
			if (App.user.gifts.length == 0) 
				giftCounterCont.visible = false;	
			else 							
				giftCounterCont.visible = true;	
		}
		
		private var arrCollections:Array = [];
		public function updateCollCounter():void 
		{
			var counter:int = 0;
			
			if (arrCollections.length == 0) {
				for (var ind:* in App.data.storage) {
					
					var item:Object = App.data.storage[ind];
					item['sID'] = ind;
					if (item.type == 'Collection' && item.visible) {
						
						if (App.data.storage[ind].visible == 0 || (App.data.updatelist[App.social].hasOwnProperty(User.getUpdate(ind)) 
						&& App.data.updates[User.getUpdate(ind)].temporary == 1 && ((App.data.updatelist[App.social][(User.getUpdate(ind))] 
						+ App.data.updates[User.getUpdate(ind)].duration) < App.time)))
							continue;
						
						if (App.user.stock.checkCollection(ind) ) {
							counter++;
						}
						arrCollections.push(ind);
					}
				}
			}else {
				for (var i:int = 0; i < arrCollections.length; i++ ) {
					if (App.user.stock.checkCollection(arrCollections[i])) {
						counter++;
					}
				}
			}
			
			if (counter > 0) {
				collCounter.text = String(counter);
				collCounterCont.visible = true;
			}
			else collCounterCont.visible = false;
		}
		
		public function updateAchiveCounter():void
		{
			var counter:int = 0;
			
			for (var ind:* in  App.data.ach) {
				for (var mis:* in  App.data.ach[ind].missions) {
					
					if (ind == 29) {
						//trace('1');
					}
					
					
					if (App.user.ach[ind][mis] < 1000000000 && App.data.ach[ind].missions[mis].need <= App.user.ach[ind][mis]) {
						counter++;
					}
				}
			}
			
			if (counter > 0) {
				achiveCounter.text = String(counter);
				achiveCounterCont.visible = true;
			}
			else achiveCounterCont.visible = false;
		}
		
		public function updateMapCounter(e:AppEvent = null):void 
		{
			updateCollCounter();
			updateGiftCounter();
			
			/*var arrTrades:Array = Map.findUnits([Trade.TRADE_ID]);
			if (arrTrades.length == 0 || arrTrades[0].level < arrTrades[0].totalLevels) {
				mapCounterCont.visible = false;
				return;
			}
			
			var counter:int = 0;
			for each(var item:* in arrTrades[0].trades) {
				if (App.user.stock.checkAll(item.items) && item.time <= App.time) 
				counter++;
			}
			
			if (counter > 0 && arrTrades.length > 0) {
				mapCounter.text = String(counter);
				mapCounterCont.visible = true;
			}
			else mapCounterCont.visible = false;*/
		}
		
		
		public function onManageFriends(e:MouseEvent):void {
			if(App.invites.inited){
				new InvitesWindow().show();
			}
		}
			
		private var progressLight:Sprite;
		private var textLable:Sprite;
		
		public var moveCursor:ImagesButton;
		public var removeCursor:ImagesButton;
		public var stockCursor:ImagesButton;
		public var rotateCursor:ImagesButton;
		public function makeCursorsPanel(bttnCursors:ImagesButton):void {
			
				
			moveCursor = new ImagesButton(Window.textures.cursorsPanelItemBg);
			moveCursor.icon = UserInterface.textures.iconCursorMove;
			moveCursor.alpha = 0.85;
			
			removeCursor = new ImagesButton(Window.textures.cursorsPanelItemBg);
			removeCursor.icon = UserInterface.textures.iconCursorRemove;
			removeCursor.alpha = 0.85;
			
			stockCursor = new ImagesButton(Window.textures.cursorsPanelItemBg);
			stockCursor.icon = UserInterface.textures.iconCursorStock;
			stockCursor.alpha = 0.85;
			
			rotateCursor = new ImagesButton(Window.textures.cursorsPanelItemBg);
			rotateCursor.icon = UserInterface.textures.iconCursorRotate;
			rotateCursor.alpha = 0.85;
			
			var bg:Bitmap = Window.backing2(74, 260, 15, "cursorsPanelBg2", "cursorsPanelBg3");

			bg.y = -32;
			bg.alpha = 0.5;
			cursorsPanel = new LayerX();
			
			
			
			cursorsPanel.addChild(bg);
			
			mainPanel.addChild(cursorsPanel);
			cursorsPanel.x = bttnCursors.x - 10;
			cursorsPanel.y = bttnCursors.y - cursorsPanel.height + 28;
			
			cursorsPanel.addChild(stockCursor);
			stockCursor.x = 7;
			stockCursor.y = -26;
			stockCursor.tip =  function():Object { return { title:Locale.__e("flash:1382952379772") }; }
			
			cursorsPanel.addChild(rotateCursor);
			rotateCursor.x = 7;
			rotateCursor.y = 37;
			rotateCursor.tip =  function():Object {return {title:Locale.__e("flash:1382952379773")};}
				
			cursorsPanel.addChild(removeCursor);
			removeCursor.x = 7;
			removeCursor.y = 113 - 13;
			removeCursor.tip =  function():Object {return {title:Locale.__e("flash:1382952379774")};}
			
			cursorsPanel.addChild(moveCursor);
			moveCursor.x = 7;
			moveCursor.y = 180 - 17;
			moveCursor.tip =  function():Object { return { title:Locale.__e("flash:1382952379775") }; }
			
			stockCursor.addEventListener(MouseEvent.CLICK, onStockCursor);
			rotateCursor.addEventListener(MouseEvent.CLICK, onRotateCursor);
			removeCursor.addEventListener(MouseEvent.CLICK, onRemoveCursor);
			moveCursor.addEventListener(MouseEvent.CLICK, onMoveCursor);
			
			cursorsPanel.visible = false;
		}
		
		private function onStopEvent(e:MouseEvent):void {
			App.user.onStopEvent(e);
			clearCursor();
			if (App.map.moved != null)
				onCursorsEvent(e);
			Cursor.accelerator = false;
		}
		
		
		private function onCursorsEvent(e:MouseEvent):void {
			if (App.user.quests.tutorial)
			{
				QuestsRules.quest9_2_1();
			}
			if (User.inExpedition && !Config.admin)
				return;
			clearCursor();
				
			var exit:Boolean = false;
			
			if (App.map.moved != null) {
				App.map.moved.previousPlace();
				Cursor.type = "default";
				//Cursor.init();
				cursorsPanel.visible = false;
				exit = true;
				//return;
			}
			
			if (Cursor.plant) 
			{
				Cursor.plant = false;
				exit = true;
			}
			
			if (ShopWindow.currentBuyObject.type != null) {
				ShopWindow.currentBuyObject.type = null;
				ShopWindow.currentBuyObject.currency = null;
				Cursor.type = "default";
				//Cursor.init();
				cursorsPanel.visible = false;
				exit = true;
				//return;	
			}
			
			if (exit) {
				return;
			}
				
			if (Cursor.type != "default") {
				Cursor.type = "default";
				Cursor.toStock = false;
			}else{
				if (cursorsPanel.visible == false && App.user.mode == User.OWNER) {
					cursorsPanel.alpha = 0;
					cursorsPanel.visible = true;
					TweenLite.to(cursorsPanel, 0.2, { alpha:1 } );
					
					App.self.addEventListener(AppEvent.ON_MOUSE_UP, onCursorsPanelHide);
				}else {
					cursorsPanel.visible = false;
				}
			}
		}
		
		public function clearCursor():void {
			if(Unit.lastUnit){
				var fake:* = Map.findUnit(Unit.lastUnit.sid, 0);
				if (fake != null)
					fake.uninstall();
			}
			
			for (var i:int = 0; i < Unit.unitsMove.length; i++) 
			{
				if (Unit.unitsMove[i].move) 
				{
					Unit.unitsMove[i].visible = false;	
				}
			}
			if (Field.boost)
			{
				if (Cursor.type != "default") 
				{
					Cursor.type = "default";
					Cursor.toStock = false;
				}
				Field.boost = 0;
			}
			
			/*var unit:*;
			
			var childs:int = App.map.mLand.numChildren;
			
			while (childs--) {
				try
				{
					unit = App.map.mLand.getChildAt(childs);
					
					if (unit is Resource) {
						unit.dispose();
					}else{
						if(!(unit is Plant)){
							unit.uninstall();
						}
					}
				
				}catch (e:Error) {
					
				}
			}*/
			/*if (App.map.moved) {
				App.map.moved.move = false;
				App.map.moved = null;
				Cursor.type = "default";
			}*/
		}
		
		private function onCursorsPanelHide(e:AppEvent):void {
			cursorsPanel.visible = false;
		}
		
		private function onStockCursor(e:MouseEvent):void {
			Cursor.type = "stock";
			Cursor.toStock = true;
			cursorsPanel.visible = false;
		}
		
		private function onRotateCursor(e:MouseEvent):void {
			Cursor.type = "rotate";
			cursorsPanel.visible = false;
		}
		
		private function onRemoveCursor(e:MouseEvent):void {
			Cursor.type = "remove";
			cursorsPanel.visible = false;
		}
		
		private function onMoveCursor(e:MouseEvent):void {	
			Cursor.type = "move";
			if(!User.inExpedition)
				cursorsPanel.visible = false;
		}
		
		public function showExpeditionPanel():void 
		{
			mainPanelFriend.visible = true;
			bttnMainHome.hideGlowing();
			mainPanel.visible =	true;
			mainPanelExp.visible = false;
			iconsPanel.visible = false;
			//friendsPanel.exit.visible = false;
			
			if(inviteBttn != null)inviteBttn.visible = false;
			
			if(!User.inExpedition)
				cursorsPanel.visible = false;
			
			openArrow.visible = false;
			
			dinamiteSprite.x = tentStockSprite.x + 30;
			dinamiteSprite.y = -30;
			if (knifeSprite) 
			{
			knifeSprite.x = tentStockSprite.x +25;
			knifeSprite.y = -30; 	
			}
			
			
			//mapBttn.visible = true;
			
			//bttnStopFriends.visible = false;
			
			for (var kei:String in iconsObject) 
			{
				if (kei == "shop"  || kei == "cursor" || kei == "stock"  || kei == "stopFriend")
					(iconsObject[kei] as ImagesButton).visible = false;
			}
			for (var key:String in  objectBgIcon) 
			{
				if (key == "stopFriend" || key == "shop" || key == "cursor" || key == "stock" || key == "gift")
					(objectBgIcon[key] as Bitmap).visible = false;
			}
			
			mainPanelFriend.x = 0;
			mainPanelFriend.y = App.self.stage.stageHeight - 108 + dY;
			
		}
		
		private function drawTravelBttn():void 
		{
			var back:BitmapData = UserInterface.textures.interRoundBttn;
			var backBack:BitmapData = UserInterface.textures.interRoundBttn;
			mapBttn = new ImagesButton(back, UserInterface.textures.mapIcon);
			mapBttn.x = 0;
			mapBttn.y = 0;
			var bg:Bitmap = new Bitmap(UserInterface.textures.mainBttnBacking);
			mapBttn.addChildAt(bg, 0);
			bg.x = - 10;
			bg.y = - 10;
			mapBttn.x = bttnMainHome.x - mapBttn.width + 45;
			mapBttn.y += 28;
			
			mapBttn.addEventListener(MouseEvent.CLICK, onMapClick);
			mainPanelFriend.addChild(mapBttn);
			
		}
		
		public function showGuestPanel():void 
		{
			bttnChat.visible = false;
			mainPanelFriend.visible = true;
			mainPanel.visible = false;
			mainPanelExp.visible = false;
			iconsPanel.visible = false;
			//friendsPanel.exit.visible = false;
			
			openArrow.visible = false;
			
			bttnMainHome.hideGlowing();
			mainPanelFriend.x = App.self.stage.stageWidth - 250;
			//mapBttn.visible = false;
			
			App.ui.systemPanel.y = 63;
			tresureCont.visible = false;
			friendsPanel.resize(mainPanelFriend.visible);
		
			App.ui.upPanel.show(false);
			//App.ui.leftPanel.promoList.visible = false;
			//App.ui.rightPanel.mode = User.GUEST;
			App.ui.rightPanel.visible = false;
			showFriendsPanel2();
			App.ui.salesPanel.visible = false;
			dinamiteSprite.visible = false;
			//mainPanelExp.visible = true;
			
			for (var key:* in bgIconsData) 
			{
				if (key == "stopFriend")
					(objectBgIcon[key] as Bitmap).visible = false;
			}
			
		}
		public function showPublicPanel():void 
		{
			bttnStop.visible = false;
			bttnChat.visible = true;
			
			mainPanelFriend.visible = false;
			mainPanel.visible = true;
			iconsPanel.visible = true;
			openArrow.visible = true;
			mainPanelExp.visible = false;
			
			App.ui.upPanel.hideExpedition(true);
			App.ui.upPanel.hideAvatar();
			//App.ui.upPanel.hideInvitePanel();
			App.ui.upPanel.hideWakeUpPanel();
			App.ui.systemPanel.y = 113;
			App.ui.upPanel.show(true);
			App.ui.upPanel.guestSprite.visible = false;
			
			bttnMainHome.hideGlowing();
			//mainPanelFriend.x = App.self.stage.stageWidth - 250;
			
			App.ui.systemPanel.y = 63;
			tresureCont.visible = false;
			//friendsPanel.resize(mainPanelFriend.visible);
		
			//App.ui.upPanel.show(true);
			App.ui.rightPanel.visible = false;
			//showFriendsPanel2();
			App.ui.salesPanel.visible = false;
			dinamiteSprite.visible = false;
			
			for (var key:* in bgIconsData) 
			{
				if (key == "stopFriend")
					(objectBgIcon[key] as Bitmap).visible = false;
			}
			
		}
		
		private function showFriendsPanel2():void 
		{
			friendsPanel.opened = true;
			if (App.user.fmode == Friends.ALL)
				friendsPanel.searchFriends();
			else
				friendsPanel.searchFriends("", Friends.favorites);
			friendsPanel.y = App.self.stage.stageHeight + 20;
			friendsPanel.visible = true;
			friendsPanel.x = -100;
			friendsPanel.showFriends();
			TweenLite.to(friendsPanel, 0.5, { y:App.self.stage.stageHeight - 94 } );
			tresureCont.visible = false;
			App.ui.upPanel.guestSprite.visible = true;
			App.ui.upPanel.updateGuestBar();
		}
		
		
		public function showOwnerPanel():void {
		
			//friendsPanel.exit.visible = true;
			bttnStop.visible = true;
			bttnChat.visible = false;
			mainPanelExp.visible = false;
			mainPanelFriend.visible = false;
			App.ui.leftPanel.visible = true;
			mainPanel.visible = true;
			iconsPanel.visible = true;
			openArrow.visible = true;
			App.ui.upPanel.hideExpedition(true);
			App.ui.upPanel.hideAvatar();
			//App.ui.upPanel.hideInvitePanel();
			App.ui.upPanel.hideWakeUpPanel();
			App.ui.systemPanel.y = 113;
			App.ui.upPanel.show(true);
			App.ui.salesPanel.visible = true;
			//App.ui.rightPanel.mode = User.OWNER;
			App.ui.rightPanel.visible = true;
			hideWorlds();
			showFriendsPanel()
			App.ui.upPanel.guestSprite.visible = false;
			//App.ui.leftPanel.promoList.visible = true;
			App.user.currentGuestLimit = 0;
			dinamiteSprite.visible = false;
			//if (App.user.worldID == 1001) {
				//if (knifeSprite) knifeSprite.visible = false;
				//if (minePickSprite) minePickSprite.visible = false;
				//if (lightSprite) lightSprite.visible = false;
			//} else {
				//minePickSprite.visible = false;
			//}
			//tentStockSprite.visible = false;
			//TipsPanel.show();
			
			for (var kei:String in iconsObject) 
			{
				(iconsObject[kei] as ImagesButton).visible = true;
			}
			for (var key:String in  objectBgIcon) 
			{
				(objectBgIcon[key] as Bitmap).visible = true;
			}
		}
		
		public var worldsPanel:WorldsPanel
		public function hideWorlds():void 
		{
			if (worldsPanel != null){
				removeChild(worldsPanel);
			}
			worldsPanel = null;
		}
		
		public function showWorlds():void 
		{
			hideWorlds();
			worldsPanel = new WorldsPanel();
			addChild(worldsPanel);
			worldsPanel.y = -35;
			worldsPanel.x = 760;
		}
		
		public function onInviteEvent(e:MouseEvent):void {
			
			ExternalApi.apiInviteEvent();
		}
		
		private function onShopEvent(e:MouseEvent):void {
			if (Cursor.loading == true) 
			{
				return
			}
			
			if (User.inExpedition && !Config.admin)
				return;
			e.currentTarget.hidePointing();
			e.currentTarget.hideGlowing();
			
			clearCursor();
			
			if (App.map.moved) 
			{
				if (App.map.moved != null) 
				{					
					App.map.moved.previousPlace();					
				}
			}
			
			new ShopWindow(Quests.targetSettings).show();
		}
		
		private function onStockEvent(e:MouseEvent):void 
		{
			if (SocketActions.lockAction)
			{
				SocketActions.lockStartMap()
				return;
			}
			else
			{
				new StockWindow( {
					mode:(User.inExpedition?StockWindow.MINISTOCK:StockWindow.DEFAULT)
				}).show();
			}
		}
		
		private var isShowMain:Boolean = false;
		private var tweenMain:TweenLite;
		public function showMain(value:Boolean = true):void
		{
			if (value && !mainPanel.visible && !tweenMain) {
				isShowMain = true;
				mainPanel.visible = true;
				mainPanel.y = App.self.stage.stageHeight + 60;
				tweenMain = TweenLite.to(mainPanel, 0.6, { y:App.self.stage.stageHeight - 71, onComplete:function():void { tweenMain = null; }} );
			}else if (!value && iconsPanel.visible && !tweenMain) {
				isShowMain = false;
				mainPanel.y = App.self.stage.stageHeight - 71;
				tweenMain = TweenLite.to(mainPanel, 0.6, { y:App.self.stage.stageHeight +60, onComplete:function():void { tweenMain = null, mainPanel.visible = false;}} );
			}
		}
		
		private var tweenIcons:TweenLite;
		public function showIcons(value:Boolean = true):void
		{
			if (value && !iconsPanel.visible && !tweenIcons) {
				iconsPanel.visible = true;
				iconsPanel.y = App.self.stage.stageHeight - 52 + 100;
				tweenIcons = TweenLite.to(iconsPanel, 0.6, { y:App.self.stage.stageHeight - 52, onComplete:function():void { tweenIcons = null; }} );
			}else if (!value && iconsPanel.visible && !tweenIcons) {
				iconsPanel.y = App.self.stage.stageHeight - 52;
				tweenIcons = TweenLite.to(iconsPanel, 0.6, { y:App.self.stage.stageHeight - 52 + 100, onComplete:function():void { tweenIcons = null, iconsPanel.visible = false;}} );
			}
		}
		
		private var timeToPostShow:int = 500;
		private var postInterval:int;
		private var postPreloader:PostPreloader;
		private var title:TextField = null;
		public var mapBttn:ImagesButton;
		public var mapBttnSprite:Sprite;
		public function addPostPreloader():void
		{
			clearInterval(postInterval);
			postInterval = setInterval(function():void{
			removePostPreloader();
			postPreloader = new PostPreloader();
			App.self.addChild(postPreloader);
			postPreloader.x = 0;
			postPreloader.y = App.self.stage.stageHeight - postPreloader.height + 8;
			}, timeToPostShow);
			
			if (App.user.quests.tutorial) 
			{
				App.user.quests.addSquareToBlock(0.8);
			}
		}
		
		public function removePostPreloader(obj:* = null):void
		{
			clearInterval(postInterval);
			if (postPreloader && postPreloader.parent)
				postPreloader.parent.removeChild(postPreloader);
				
			postPreloader = null;
			
			if (App.user.quests.tutorial) 
			{
				App.user.quests.removeSquareToBlock();
			}
		}
		
		public function hidePanels():void
		{
			////trace("прячем панельки");
			//hideoutFriendsPanel();
			//hideUpPanel();
			
		}
		
		public function showStopBttn(value:Boolean = true):void 
		{
			//bttnStopFriends.visible = value;
		}
		
		private function hideUpPanel():void 
		{
			//trace("прячем верхнюю панель");
		}
		
		private function hideoutFriendsPanel():void
		{
			//trace("прячем панель друзей");
			//friendsPanel.opened = false;
			TweenLite.to(iconsPanel, 0.5, { y:App.self.stage.stageHeight - 52 } );
			TweenLite.to(friendsPanel, 0.5, { y:App.self.stage.stageHeight + 45 } );
			//
			//tresureCont.visible = true;
			//friendsPanel.alpha = 0;
			//iconsPanel.alpha = 0;
		}
		
		private function createInfoIcon():void {
			
			return;
			var infoIcon:Bitmap = new Bitmap(new BitmapData(75,75, true, 0), 'auto', true);
			infoBttn = new ImagesButton(infoIcon.bitmapData);
			
			infoBttn.tip = function():Object { 
				return {
					title: (App.user.worldID == 800) ? Locale.__e('flash:1446828926936') : Locale.__e("flash:1382952380254"),
					text:''
				};
			};
			
			infoBttn.addEventListener(MouseEvent.CLICK, onInfo);
			
			Load.loading(Config.getImageIcon("quests/icons", "helpBttn"), function(data:Bitmap):void {
				infoBttn.bitmapData = data.bitmapData;				
				infoBttn.initHotspot();
			});
			
			infoBttn.x = 240;
			infoBttn.y = 30;
			if ((App.isSocial('DM', 'VK', 'OK', 'MM', 'FS'))) 
			{
				mainPanelFriend.addChild(infoBttn);
			}			
			infoBttn.visible = false;		
		}
		
		private function onInfo (e:Event = null):void 
		{
			var hintWindow:ExpeditionHintWindow = new ExpeditionHintWindow( {
				popup: true,
				hintsNum:(App.user.worldID == 800) ? 2 : 3,
				hintID:(App.user.worldID == 800) ? 4 : 3,
				height:(App.user.worldID == 800) ? 415 : 575
			}
			);
			hintWindow.show();
		}
	}
}

	


import flash.display.Sprite;
import flash.events.MouseEvent;
import wins.SimpleWindow;
import wins.elements.MapIcon;
internal class WorldsPanel extends Sprite
{
		private var _wIDs:Array = [171,696,442,668,834];
		private var worlds:Array = [];
		public function WorldsPanel():void {
			if (App.owner.id == '1') return;
			var userWorlds:Object = App.user.worlds;
			var ownerWorlds:Object = App.owner.worlds;
			
			for each(var wID:* in ownerWorlds) {
				if (wID == App.owner.worldID) continue;
				if (_wIDs.indexOf(wID) == -1) continue;
				
				worlds.push(wID);
			}
			
			var X:int = 0;
			var Y:int = 0;
			
			for (var i:int = 0; i < worlds.length; i++) {
				var icon:MapIcon = new MapIcon(worlds[i], this);
				icon.x = X;
				icon.y = Y;
				icon.scaleX = icon.scaleY = 0.7;
				if (worlds[i] == 668)
					icon.y -= 5;
					
				X -= 57;
				addChild(icon);
				icon.addEventListener(MouseEvent.CLICK, onClickIcon);
				if (!App.user.worlds.hasOwnProperty(worlds[i]))
					icon.open = false;
				//if (userWorlds[worlds[i]] == null)
				//icon.alpha = 0.5;
			}
		}
		
		public function onClickIcon(e:MouseEvent):void
		{
			if (!e.currentTarget.open)
			{
				new SimpleWindow({
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1396608344836'),
						popup:true
					}).show();
				return;
			}
			
			//Travel.visitOwnerWorld(e.currentTarget.worldID);
		}
		
		
}
