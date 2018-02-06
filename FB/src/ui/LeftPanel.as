package ui 
{
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.greensock.easing.Back;
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import core.CookieManager;
	import core.Load;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import units.Oracle;
	import wins.DaylicsShopWindow;
	import wins.DaylicWindow;
	import wins.DreamsWindow;
	import wins.QuestsChaptersWindow;
	import wins.SalesWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class LeftPanel extends Sprite
	{
		
		public var glowedIcons:Object = { };
		public var guestEnergy:Sprite = new Sprite();
		public var questsPanel:QuestPanel;
		//public var promoPanel:Sprite = new Sprite();
		public var promoList:UIList;
		public var questIcons:Array = [];
		public var promoIcons:Array = [];
		public var newPromo:Object = {};		
		//public var lastVisible:Array = [];
		
		public var bttnMainDreams:ImagesButton;
		public static var iconHeight:uint = 80;
		
		public function LeftPanel():void
		{
			/*promoList = new UIList( {
				type:		UIList.HORIZONTAL,
				backAlpha:	0.0,
				startIndent:12,
				finishIndent:12,
				indent:		8
			});
			promoList.x = -15;
			promoList.y = 50;
			addChild(promoList);*/
			
			/*for each(var character:* in App.data.personages) 
			{
				Load.loading(Config.getQuestIcon('icons', character.preview), function(data:*):void { } );
			}*/
			
			var material:Object = App.data.storage[Stock.COINS];
			Load.loading(Config.getIcon(material.type, material.preview), function(data:*):void { } );
			addChild(guestEnergy);
			
			createQuestPanel();
			
			/*var mailbox:* = Map.findUnits([901]);
			if (mailbox != null && mailbox.paid == 1)
			{
			//if(!App.isSocial('MX')) {
				createDaylicsIcon();
			}*/
			
			//createChaptersIcon();
			
			App.self.stage.addEventListener(Event.FULLSCREEN, onFullscreen);
		}
		
		//Daylics
		public var bttnDaylics:ImageButton;
		public var bttnChapters:ImageButton;
		public var dayliLabel:TextField;
		
		public function createDaylicsIcon():void {
			disposeDaylicsIcon();
			
			var icon:Bitmap = new Bitmap(Window.textures.daylicIcon, 'auto', true);
			bttnDaylics = new ImagesButton(icon.bitmapData);
			
			bttnDaylics.tip = function():Object {
				var time:int = App.nextMidnight - App.time;
				var text:String = '';
				if (time > 0) {
					if (Quests.daylicsComplete) {
						text = Locale.__e("flash:1392987701468");
					}else{
						text = Locale.__e("flash:1392987639226");
					}
				}
				
				return {
					title:Locale.__e("flash:1392987414713"),
					text:Locale.__e(text),
					timerText: TimeConverter.timeToStr(time),
					timer:true
				};
			}
			
			bttnDaylics.x = 8;
			bttnDaylics.y = 60;
			bttnDaylics.addEventListener(MouseEvent.CLICK, onDaylics);
			
			/*Load.loading(Config.getImageIcon("quests/icons", "totem"), function(data:Bitmap):void {
				bttnDaylics.bitmapData = data.bitmapData;
				
				bttnDaylics.initHotspot();
			});*/
			
			/*var attantion:Bitmap = new Bitmap(Window.textures.daylicIcon, 'auto', true);
			//Size.size(attantion, 50, 50); 
			attantion.x = 0;
			attantion.y = 0;
			var attCont:Sprite = new Sprite();
			attCont.addChild(attantion);
			attCont.x = 0;
			attCont.y = 60;
			attCont.name = "attantion";*/
			
			//bttnDaylics.addChild(attCont);
			bttnDaylics.visible = false;
			App.self.addEventListener(AppEvent.ON_LEVEL_UP, App.user.quests.getDaylics);
			
			addChild(bttnDaylics);
			resize();
		}
		
		/*private function createChaptersIcon():void {
			//return;
			disposeChaptersIcon();
			
			var icon:Bitmap = new Bitmap(new BitmapData(75,75, true, 0), 'auto', true);
			bttnChapters = new ImagesButton(icon.bitmapData);
			
			bttnChapters.tip = function():Object { 
				return {
					title:Locale.__e("flash:1446805841616"),
					text:''
				};
			};
			
			//bttnChapters.x = 8;
			//bttnChapters.y = 8;
			bttnChapters.addEventListener(MouseEvent.CLICK, onChapters);
			
			Load.loading(Config.getImageIcon("quests/icons", "chapters"), function(data:Bitmap):void {
				bttnChapters.bitmapData = data.bitmapData;
				
				bttnChapters.initHotspot();
			});
			
			//bttnChapters.visible = false;
			App.self.addEventListener(AppEvent.ON_LEVEL_UP, App.user.quests.getDaylics);
			
			addChild(bttnChapters);
			//bttnChapters.visible = false;
			
			resize();
		}*/
		
		private function disposeDaylicsIcon():void {
			if (bttnDaylics) {
				bttnDaylics.removeEventListener(MouseEvent.CLICK, onDaylics);
				removeChild(bttnDaylics);
				bttnDaylics = null;
			}
		}
		
		private function disposeChaptersIcon():void {
			if (bttnChapters) {
				bttnChapters.removeEventListener(MouseEvent.CLICK, onChapters);
				removeChild(bttnChapters);
				bttnChapters = null;
			}
		}
		
		private function onDaylics(e:MouseEvent = null):void {
			stopDaylicsGlow();
			
			if (Quests.daylicsComplete) {
				/*var daylicWindow:DaylicsShopWindow = new DaylicsShopWindow( {
					popup: true
				}
				);
				daylicWindow.y += 40;
				daylicWindow.show();
				daylicWindow.fader.y -= 40;*/
				new SimpleWindow({
					text: 		Locale.__e('flash:1478015325654'),
					height:		250,
					buttonText: Locale.__e('flash:1382952380298'),
					hasExit: 	false
					
				}).show();
				return;
			}
			new DaylicWindow({}).show();
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
		
		public function attantionMove():void {
			if (!bttnDaylics) return;
			var target:DisplayObject = bttnDaylics.getChildByName("attantion");
			TweenLite.to(target, 0.6, { rotation:6, ease:Elastic.easeIn, onComplete:function():void {
				TweenLite.to(target, 0.25, { rotation:-6, ease:Back.easeInOut, onComplete:function():void {
					TweenLite.to(target, 0.6, { rotation:0, ease:Elastic.easeOut} )
					}
				})
			}});
		}
		public function startDaylicsGlow(pointing:Boolean = false):void {
			if(bttnDaylics){ //cвечение дейлика
				if ( bttnDaylics.__hasGlowing) return;
				//if (pointing) bttnDaylics.showPointing('left', bttnDaylics.width + 30, bttnDaylics.height / 2, bttnDaylics, '', null, true);
				bttnDaylics.showGlowing(0xFFFF00);
			}
		}
		public function stopDaylicsGlow():void {
			bttnDaylics.hidePointing();
			bttnDaylics.hideGlowing();
		}
		public function dayliState(value:Boolean):void {
			if (!App.user.quests.dayliInit) return;
			if (bttnDaylics) 
			{
				bttnDaylics.visible = value;	
			}
			
			resize();
		}
		
		public function createQuestPanel():void {
			
			//return;
			if (questsPanel != null) {
				removeChild(questsPanel);
				questsPanel = null; 
			}
			questsPanel = new QuestPanel(this);
			addChild(questsPanel);
		}
		
		public function initPromo():void {
			//createPromoPanel();
			//promoTime();
			App.user.quests.checkPromo();
		}
		
		private function createDreamsBttn():void
		{
			bttnMainDreams = new ImagesButton(UserInterface.textures.mainBttnBacking, UserInterface.textures.mainBttnCollections, { ix:3 } );
			bttnMainDreams.tip = function():Object {
				return {
					title:Locale.__e("flash:1382952379791"),
					text:Locale.__e("flash:1382952379792")
				};
			}
			
			bttnMainDreams.addEventListener(MouseEvent.CLICK, onBttnMainDreams);
			bttnMainDreams.y = App.self.stage.stageHeight - bttnMainDreams.height - 120;
			bttnMainDreams.x = 10;
			
			addChild(bttnMainDreams);
		}
		
		private function onBttnMainDreams(e:MouseEvent):void
		{
			new DreamsWindow().show();
		}
		
		private function onFullscreen(e:Event):void {
			//setTimeout(createQuestPanel, 60);
			if(App.user.mode == User.GUEST){
				setTimeout(update, 60);
			}
		}
		
		public var iconDealSpot:*;
		public function createDealSpot(swf:*):void {
			iconDealSpot = swf;
			//promoPanel.addChild(iconDealSpot);
			iconDealSpot.x = 120;
			iconDealSpot.y = 0;
		}
		
		public function checkOnGlow(type:String, bttn:ImagesButton, pID:*):void 
		{
			if (ExternalInterface.available) 
			{
				var pID:String = String(pID);
				var cookieName:String = pID + "_" + App.user.id;
				var value:String = CookieManager.read(cookieName);
				
				
				if (value != '1') {
					Post.addToArchive('startGlow: '+ pID);
					startGlow(bttn);
					CookieManager.store(cookieName, '1');
				}
			}
		}
		
		private function startGlow(bttn:ImagesButton):void {
			bttn.showGlowing();
			bttn.showPointing("left", 0, 50, App.ui.leftPanel, Locale.__e("flash:1382952379795"), {
				color:0xf3c769,
				borderColor:0x322204,
				autoSize:"left",
				fontSize:24
			}, false);
		}
		
		public function clearIconsGlow():void {
			for (var i:int = 0; i < promoIcons.length; i++){
				promoIcons[i].hideGlowing();
				promoIcons[i].hidePointing();
			}	
			
			questsPanel.clearIconsGlow();
		}
		
		public function showGuestEnergy():void {
			if (App.owner == null) {
				return;
			}
			
			clearIconsGlow();
			questsPanel.visible = false;
			//App.ui.bottomPanel.homeQuitBttn.visible = false;
			//promoPanel.visible = false;
			dayliState(false);
			var childs:int = guestEnergy.numChildren;
			
			var friend:Object = App.user.friends.uid(App.owner.id);
			
			if (childs > 0 && childs > friend.energy) {
				var icon:*;
				if (App.user.stock.count(Stock.GUESTFANTASY) && friend.energy > 0) {
					icon = guestEnergy.getChildAt(0);
				}else if (App.user.stock.count(Stock.GUESTFANTASY)) {
					icon = guestEnergy.getChildAt(0);
				}else{
					icon = guestEnergy.getChildAt(0);
				}
				
				App.ui.glowing(icon, 0x86e3f2, function():void{ 
					update();
				});
				
			}else {
				update();
			}
			
			
		}
		
		public function update():void 
		{
			var friend:Object = App.user.friends.uid(App.owner.id);
			
			while (guestEnergy.numChildren) {
				guestEnergy.removeChildAt(0);
			}
			var material:Object = App.data.storage[Stock.GUESTFANTASY];
			var contEn:LayerX;
			var limit:int = App.user.friends.energyLimit;
			if (limit > 0) {
				
				var min:int = Math.min(limit, friend.energy);
				if  (min)
				{
					contEn = new LayerX();
					var bitmap:Bitmap = new Bitmap(UserInterface.textures.guestAction);
					bitmap.scaleX = bitmap.scaleY = 1;
					bitmap.smoothing = true;
					bitmap.x = 6;
					bitmap.y = (App.self.stage.stageHeight - bitmap.height) / 2 + (bitmap.height ) -70;
					contEn.addChild(bitmap);
					App.ui.staticGlow(contEn, { color:0xffffff, size:3, strength:3 } );
					guestEnergy.addChild(contEn);
					
					var counter2:TextField = Window.drawText('x' + min, {
							fontSize:22,
							autoSize:"left",
							color:0x38342c,
							borderColor:0xecddb9
						});
						
						
						contEn.addChild(counter2);
						
						counter2.x = bitmap.x + bitmap.width - 30;
						counter2.y = bitmap.y + bitmap.height - counter2.height;
						
					contEn.tip = function():Object { 
						return {
							title:Locale.__e('flash:1404378818609'),
							text:Locale.__e("flash:1404378842760")
						};
					};
				}
				if  (App.user.stock.count(Stock.GUESTFANTASY))
				{
						contEn = new LayerX();
						var bitmap2:Bitmap = new Bitmap(UserInterface.textures.guestActionGold);
						bitmap2.scaleX = bitmap2.scaleY = 1;
						bitmap2.smoothing = true;
						bitmap2.x = 6;
						bitmap2.y = (App.self.stage.stageHeight + bitmap2.height)/2 - bitmap2.height  -80;
						
						var counter:TextField = Window.drawText('x' + App.user.stock.count(Stock.GUESTFANTASY), {
							fontSize:22,
							autoSize:"left",
							color:0x38342c,
							borderColor:0xecddb9
						});
						
						contEn.addChild(bitmap2);
						contEn.addChild(counter);
						App.ui.staticGlow(contEn, { color:0xffffff, size:3, strength:3 } );
						guestEnergy.addChild(contEn);
						counter.x = bitmap2.x + bitmap2.width - 30;
						counter.y = bitmap2.y + bitmap2.height - counter.height;
						
						contEn.tip = function():Object { 
							return {
								title:Locale.__e('flash:1404378818609'),
								text:Locale.__e("flash:1404378842760")
							};
						};
						
					
				}
				
			}else{
				if(App.user.stock.count(Stock.GUESTFANTASY)){
					Load.loading(Config.getIcon(material.type, material.preview), function(data:*):void { 
						var bitmap:Bitmap = data;
						bitmap.scaleX = bitmap.scaleY = 1;
						bitmap.smoothing = true;
						
						bitmap.x = 2;
						bitmap.y = (App.self.stage.stageHeight - bitmap.height)/2;
						guestEnergy.addChild(bitmap);
						
						var counter:TextField = Window.drawText('x' + App.user.stock.count(Stock.GUESTFANTASY), {
							fontSize:22,
							autoSize:"left",
							color:0x38342c,
							borderColor:0xecddb9
						});
						
						guestEnergy.addChild(counter);
						counter.x = bitmap.x + bitmap.width - 30;
						counter.y = bitmap.y + bitmap.height - counter.height;
					});
				}
			}
			
		}
		
		public function hideGuestEnergy():void {
			while (guestEnergy.numChildren) {
				guestEnergy.removeChildAt(0);
			}
			
			dayliState(true);
			questsPanel.visible = true;
		}
		
		public function resize():void 
		{
			if (bttnChapters) 
			{
				bttnChapters.x = 90;
				bttnChapters.y = 60;
			}
			
			if (questsPanel) 
			{
				questsPanel.resize(isBankAdd /*|| promoList.containsElements*/ );
			//if (promoList.height <= 0)
				questsPanel.y = -150;
			/*else{
				questsPanel.y = -50;
				if (bttnDaylics)
					bttnDaylics.y = 160
			}*/
			}	
			if (bttnDaylics && App.user.quests.dayliInit)
				questsPanel.y += 85;
		}
		
		// Левые промоакции
		public var isBankAdd:Boolean = false;
		public function addLeftPromo(child:*):void {
			promoList.addChild(child);
			resize();
		}
		/*public function clearLeftPromo():void 
		 * {
			promoList.dispose();
		}*/
		private function getBigSaleIcon(bttn:ImagesButton, sale:Object, pID:String = ''):ImagesButton {
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(75,75, true, 0), "auto", true);
			bttn = new ImagesButton(bitmap.bitmapData, null, { pID:pID } );
			
			var material:uint = sale.items[0].sID
			var url_icon:String = Config.getIcon(App.data.storage[material].type, App.data.storage[material].preview);
			var url_bg:String = Config.getImage('sales/bg', 'glow');
			
			var textSettings:Object = {
				text:"",
				color:0xf0e6c1,
				fontSize:19,
				borderColor:0x634807,
				scale:0.55,
				textAlign:'center'
			}
			
			var iconSettings:Object = {
				scale:0.55,
				filter:[new GlowFilter(0xf8da0f, 1, 4, 4, 8, 1)]
			}
			
			var text:TextField = Window.drawText(textSettings.text, textSettings);
			text.width = 95;
			text.x = -10;
			text.y = 45;
			
			Load.loading(url_bg, function(data:*):void {
				bttn.bitmapData = data.bitmapData;
				
				Load.loading(url_icon, function(data:*):void {
					bttn.icon = data.bitmapData;
					bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = iconSettings.scale;
					bttn.iconBmp.smoothing = true;
					bttn.iconBmp.filters = iconSettings.filter;
					bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width)/2 - 5;
					bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height)/2 - 6;
					
					bttn.addChild(text);
					bttn.initHotspot();
				});
			});
			
			App.self.setOnTimer(update);
			
			function update():void {
				var time:int = sale.duration * 3600 - (App.time - sale.time);
				text.text = TimeConverter.timeToStr(time);
				if (time < 0) {
					App.self.setOffTimer(update);
					//createPromoPanel();
				}
			}
			
			bttn.tip = function():Object {
				return {
					title:Locale.__e(sale.title)
				}
			};	
			
			return bttn;
		}
		
		public static var ahappyIcon:LayerX;
		public static var ahappyStandbyIcon:LayerX;
		private var text:TextField;
		
		public function createAhappyIcon(id:int = 0, endTime:int = 0):void 
		{			
			return;
			
			if (User.inExpedition || App.user.worldID == User.AQUA_HERO_LOCATION || App.user.mode != User.OWNER || App.user.level < 5) 
			{
				if (ahappyStandbyIcon && ahappyStandbyIcon.parent == this) 
				{
					removeChild(ahappyStandbyIcon);
					ahappyStandbyIcon = null;
				}
				if (ahappyIcon && ahappyIcon.parent == this) 
				{
					removeChild(ahappyIcon);
					ahappyIcon = null;
				}
				return;
			}
			
			var str:String;
			var bitmap:Bitmap;
			
			switch(id) 
			{
				case 1:	str = 'placeIco' + id;
				case 2:	str = 'placeIco' + id;
				case 3:	str = 'placeIco' + id;
				case 4:	str = 'placeIco' + id;
			}
			
			if (ahappyStandbyIcon && ahappyStandbyIcon.parent == this) {
				ahappyStandbyIcon.removeChildren();
				ahappyStandbyIcon.removeEventListener(MouseEvent.CLICK, onClickIco);
				removeChild(ahappyStandbyIcon);
				ahappyStandbyIcon = null;
			}
			
			
			if (ahappyIcon && ahappyIcon.parent == this) 
			{
				ahappyIcon.removeChildren();
				ahappyIcon.removeEventListener(MouseEvent.CLICK, onClickIco);
				ahappyIcon.removeEventListener(TimerEvent.TIMER, onAhappyTimer);
				removeChild(ahappyIcon);
				ahappyIcon = null;
			}
			
			if (!str || endTime < App.time) 
			{				
				if (App.data.storage[2144].expire[App.SOCIAL] > App.time) 
				{
					Load.loading(Config.getImage('events', 'ahappyCustom'), function(data:Bitmap):void {
						ahappyStandbyIcon = new LayerX();
						bitmap = new Bitmap(data.bitmapData);
						ahappyStandbyIcon.addChild(bitmap);
						ahappyStandbyIcon.x = 215;
						ahappyStandbyIcon.y = 10;
						if (App.ui.upPanel.ribbonSaleSprite.visible) 
						{
							ahappyStandbyIcon.y = App.ui.bottomPanel.friendsPanel.y - 60;
						}
						if (App.isSocial('VK','OK','FS','MM')) 
						{
							addChild(ahappyStandbyIcon);
						}						
						ahappyStandbyIcon.visible = true;
						ahappyStandbyIcon.addEventListener(MouseEvent.CLICK, onClickIco);
						ahappyStandbyIcon.showGlowing();
						ahappyStandbyIcon.tip = function():Object 
						{		
							return {
								text:Locale.__e('flash:1456301846886')
							};
						}					
					});	
				}else 
				{
					return;
				}		
			}
			
			ahappyIcon = new LayerX();
			ahappyIcon.name = endTime.toString();
			ahappyIcon.x = 215;
			ahappyIcon.y = 0;
			if (App.ui.upPanel.ribbonSaleSprite.visible) 
			{
				ahappyIcon.y = App.ui.bottomPanel.friendsPanel.y - 85;
			}
			addChild(ahappyIcon);
			
			ahappyIcon.addEventListener(MouseEvent.CLICK, onClickIco);
			ahappyIcon.addEventListener(TimerEvent.TIMER, onAhappyTimer);
			
			Load.loading(Config.getImage('events', str), function(data:Bitmap):void 
			{
				if (!ahappyIcon) return;
				
				ahappyIcon.removeChildren();
				
				bitmap = new Bitmap(data.bitmapData);
				ahappyIcon.addChild(bitmap);
				
				text = Window.drawText(TimeConverter.timeToStr(endTime - App.time), {
					fontSize:19,
					color:0xffffff,
					borderColor:0x7d4310,
					autoSize:"center",
					shadowColor:0x7d4310,
					shadowSize:1
				});
				text.x = (bitmap.width - text.width) / 2;
				text.y = bitmap.height - 10;
				ahappyIcon.addChild(text);
				
				App.self.setOnTimer(timer);
			});
		}
		
		public function timer():void 
		{
			if (ahappyIcon && int(ahappyIcon.name) >= App.time) {
				var time:int = int(ahappyIcon.name) - App.time;
				if (time > 0) {
					text.text = TimeConverter.timeToStr(time);
				} else {
					text.text = '';
					if (ahappyIcon) 
					{
						ahappyIcon.removeChildren();
						ahappyIcon.removeEventListener(MouseEvent.CLICK, onClickIco);
						ahappyIcon.removeEventListener(TimerEvent.TIMER, onAhappyTimer);
						removeChild(ahappyIcon);
						ahappyIcon = null;
						createAhappyIcon();
					}
				}
			}
		}
		
		private function onAhappyTimer(e:TimerEvent):void
		{
			if (!ahappyIcon || int(ahappyIcon.name) < App.time)
				createAhappyIcon();
		}
		
		private function onClickIco(e:MouseEvent):void 
		{			
			/*if (Map.findUnits([2144]).length == 0) 
			{
				new ShopWindow( { find:[2144] } ).show();
			}else 
			{
				var units:Array = Map.findUnits([2144]);
				if (units.length > 0) App.map.focusedOn(units[0], true);			
			}*/
		}
	}
}

