package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import buttons.MenuButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Storehouse;

	public class EventShopWindow extends Window
	{	
		public var sections:Object = new Object();
		public var icons:Array = new Array();
		public var decor:Array = new Array();
		public var goldenDecor:Array = new Array();
		public var items:Vector.<EventShopItem> = new Vector.<EventShopItem>();
		public static var history:Object = { section:"all", page:0 };
		
		public var bonusList:BonusList;		
		public var makeBiggerBttn:Button;
		public var titleTextLabel:TextField;
		public var youHave:TextField;
		public var willLast:TextField;
		public var buyBttn:Button;
		public var background:Bitmap = new Bitmap();
		public var goWinter:Button;
		public var timeOfExpire:TextField;
		private var rays:Bitmap = new Bitmap();
		public var expireJson:Object;
		public var winterLandBttn:ImageButton;
		public static var showFatman:Boolean = false;
		private var preloader:Preloader = new Preloader();
		
		public function EventShopWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["section"] = settings.section || "all"; 
			settings["page"] = settings.page || 0; 			
			settings["find"] = settings.find || null;			
			settings["title"] = Locale.__e("flash:1448624042373");
			settings["width"] = 615;
			settings["height"] = 525;			
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 5;
			settings["buttonsCount"] = 7;
			settings["background"] = 'storageBackingTop';
			settings['shadowBorderColor'] = 0x1743ae;
			
			var stocks:Array = [];
			stocks = Map.findUnits([Storehouse.SILO]);
			
			if (App.self.getLength(App.user.eventShopData)==0) {
				for (var id:String in App.data.storage) {
					var item:Object = App.data.storage[id];
					if (App.self.getLength(item.currency) && item.currency[Stock.EVENT_COIN]) {
						if (item.type == "Golden") 
						{
							goldenDecor.push(item);
						}else if (item.type == "Decor") 
						{
							decor.push(item);
						}
						
					}
				}
			}
			
			pushItems();
			
			settings["target"] = stocks[0];
			
			createContent();
			
			findTargetPage(settings);
			
			super(settings);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
		}
		
		public function pushItems():void 
		{
			var	eventShopOrder:int = 0;
			while (goldenDecor.length > 0) 
			{
				for (var j:int = 0; j < 3; j++) 
				{
					decor[j].eventShopOrder = eventShopOrder;
					App.user.eventShopData[decor[j].sID] = decor[j];
					eventShopOrder++;
				}
				decor.splice(0, 3);
				
				for (var i:int = 0; i < 2; i++) 
				{
					goldenDecor[i].eventShopOrder = eventShopOrder;
					App.user.eventShopData[goldenDecor[i].sID] = goldenDecor[i];
					eventShopOrder++;
				}
				goldenDecor.splice(0, 2);
				
			}
		}		
		
		override public function dispose():void 
		{
			super.dispose();
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
			
			for each(var item:* in items) {
				item.dispose();
				item = null;
			}
			
			for each(var icon:* in icons) {
				icon.dispose();
				icon = null;
			}
		}
		
		override public function drawBackground():void
		{			
			background = backing(settings.width, settings.height, 30, 'buildingBacking');
			layer.addChild(background);
			background.x = -10;
			background.y = 40;
			
			drawMainTitle();
		}
		
		public function drawMainTitle():void 
		{			
			titleTextLabel = Window.drawText(Locale.__e('flash:1448624042373'), {
				//width				:350,
				fontSize			:45,
				textAlign			:"center",
				color				:0xfffeff,
				borderColor			:0x2a85be,
				border				:true,
				shadowBorderColor	:0x1743ae,
				//multiline			:true,
				//wrap				:true,
				strenghtShadow		:30
			});
			
			titleTextLabel.width = titleTextLabel.textWidth + 10;
			titleTextLabel.x = background.x + background.width / 2 - titleTextLabel.width / 2;
			headerContainer.y = 37;
			layer.addChild(titleTextLabel);
			drawMirrowObjs('winterCornerDecorUp', -65, settings.width + 45, -5);
			drawMirrowObjs('winterTitleDecor', titleTextLabel.x + 5, titleTextLabel.x + titleTextLabel.width, titleTextLabel.y - 7, true, true);	
			titleTextLabel.y = 20;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawTitle():void 
		{
			return;
		}	
		
		override public function drawExit():void 
		{
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 60;
			exit.y = -5;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		override public function close(e:MouseEvent = null):void {		
			if (settings.hasAnimations == true) {
				startCloseAnimation();
			}else {
				dispatchEvent(new WindowEvent("onBeforeClose"));
				dispose();
			}
			
			for (var i:* in sections['all'].items) {
				
				sections['all'].items[i].targetGlowing  = false;
			}
		}
		
		private function findTargetPage(settings:Object):void 
		{					
			
			for (var i:* in sections['all'].items) {
				
				var sid:int = sections['all'].items[i].sid;
				
				if (settings.find >= 0 && settings.find == sections['all'].items[i].sid) {
					
					history.section = 'all';
					history.page = int(int(i) / settings.itemsOnPage);
					
					settings.page = history.page;
					if (settings.find == sections['all'].items[i].sid) {
						sections['all'].items[i].targetGlowing = true;
						return;
					}
					
				}
			}		
		}
		
		private function findRes():void 
		{			
			ShopWindow.findMaterialSource(settings.find[0],this);
		}
		
		public function createContent():void 
		{			
			if (sections["all"] != null) return;
			
			sections = 
			{				
				"all":{items:new Array(),page:0}
			};
			
			var section:String = "all";
			
			for(var ID:* in App.user.eventShopData) {
				var item:Object= App.user.eventShopData[ID];
				if(item == null)continue;				
				if (notShow(ID)) continue;				
				item["sid"] = ID;
				if (User.inUpdate(item.sID)) 
				{
					sections["all"].items.push(item);
				}				
			}
			
			sections["all"].items.sortOn('eventShopOrder', Array.NUMERIC | Array.DESCENDING);
		}	
		
		override public function drawBody():void {
			
			setContentSection(settings.section,settings.page);
			contentChange();
			
			this.y = -40;			
			this.x += 20;			
			fader.y = 40;		
			fader.x -= 20;					
			
			drawMirrowObjs('winterCornerDecorDown', -65, settings.width + 45, settings.height - 120);
			
			if(settings.target){
				if(settings.target.level < settings.target.totalLevels && !settings.target.hasPresent && settings.target.hasBuilded && settings.target.hasUpgraded){
					drawBttns();
				}
			}	
			
			var rays:Bitmap = new Bitmap(Window.textures.sharpShining, "auto", true);
			rays.x = -60;
			rays.y = -20;
			rays.scaleX = rays.scaleY = 1;
			bodyContainer.addChild(rays);
			
			willLast = Window.drawText(Locale.__e('flash:1448801571470'), {//Закончится через
				width				:280,
				fontSize			:20,
				textAlign			:"center",
				color				:0xfbc446,
				borderColor			:0x754602,
				multiline			:true,
				wrap				:true
			});
			
			willLast.x = -110;
			willLast.y = 40;
			bodyContainer.addChild(willLast);
			
			drawTimer();	
			createWinterLandBttn();
		}	
		
		private function createWinterLandBttn():void {
			
			bodyContainer.addChild(preloader);
			preloader.x = 44;
			preloader.y = 222;
			preloader.scaleX = preloader.scaleY = 0.7;
			
			var icon:Bitmap = new Bitmap(new BitmapData(75,75, true, 0), 'auto', true);
			winterLandBttn = new ImagesButton(icon.bitmapData);
			
			winterLandBttn.tip = function():Object { 
				return {
					title:'',
					text:Locale.__e("flash:1449494666683")
				};
			};
			
			winterLandBttn.addEventListener(MouseEvent.CLICK, onGoWinter);
			
			Load.loading(Config.getImageIcon("quests/icons", "land_7"), function(data:Bitmap):void {
				bodyContainer.removeChild(preloader);	
				winterLandBttn.bitmapData = data.bitmapData;				
			});
			
			winterLandBttn.y = 185;
			winterLandBttn.x = 5;	
			winterLandBttn.scaleX = winterLandBttn.scaleY = 0.8;
			bodyContainer.addChild(winterLandBttn);		
			
			goWinter = new Button( {
				width			:75,
				height			:30,
				fontSize		:20,
				caption			:Locale.__e("flash:1394010224398"),//Перейти
				bgColor			:[0x96cafc,0x608cf5],
				borderColor		:[0xb4d9ff,0x376bd9],
				bevelColor		:[0xb4d9ff, 0x376bd9],
				fontColor		:0xfffffd,
				fontBorderColor	:0x355aaa
			});
			
			bodyContainer.addChild(goWinter);			
			goWinter.y = 245;
			goWinter.x = 5;
			goWinter.addEventListener(MouseEvent.CLICK, onGoWinter);
		}
		
		public function onGoWinter(e:MouseEvent = null):void {
			closeAll();
			new ShopWindow( { find:[] } ).show();
		}
		
		public static function findFatman():void 
		{
			new ShopWindow( { find:[] } ).show();
		}
		
		public function drawTimer():void 
		{			
			timeOfExpire = Window.drawText("%m.%d %H:%i", {
				width:			150,
				textAlign:		'center',
				fontSize:		32,
				color:			0xfbc446,
				borderColor:	0x754602
			});
			
			bodyContainer.addChild(timeOfExpire);
			timeOfExpire.x = willLast.x + willLast.width / 2 - timeOfExpire.width / 2;
			timeOfExpire.y = willLast.y + 20;
			
			timer();
			App.self.setOnTimer(timer);
		}
		
		protected function timer():void 
		{		
			var time:uint = 0;
			var currentDate:Date = new Date();
			expireJson = JSON.parse(App.data.options.eventDuration);
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
		}
		
		public function onEnergyEvent(e:MouseEvent = null):void {
			
			if (App.user.quests.tutorial) 
			{
				return;
			}
			
			new PurchaseWindow( {
				width:558,
				itemsOnPage:3,
				content:PurchaseWindow.createContent("Energy", {inguest:0, view:'ivent_money_star'}),
				title:App.data.storage[Stock.EVENT_COIN].title,
				description:Locale.__e("flash:1382952379757"),
				closeAfterBuy:false,
				autoClose:false,
				popup: true,	
				shortWindow:true,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();			
		}
		
		private function updateTime():void
		{
			var time:int = 0;
			if (settings.target.created > 0 && !settings.target.hasBuilded) {
				time = settings.target.created - App.time;
			}else if (settings.target.upgradedTime > 0 && !settings.target.hasUpgraded) {
				time = settings.target.upgradedTime - App.time;
			}
			
			if (time < 0) {
				App.self.setOffTimer(updateTime);
				close();
				return;
			}	
		}
		
		private function drawBttns():void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1393580216438", [settings.target.info.devel.req[settings.target.level + 1].c]), //flash:1396609462757
				fontSize:24,
				width:140,
				height:37,
				radius:15,	
				textAlign:"center",
				hasDotes:false
			};			
		}		
		
		public function setContentSection(section:*, page:int = -1):Boolean 
		{
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
				if (icon.type == section) {
					icon.selected = true;
				}
			}
			if (sections.hasOwnProperty(section)) {
				settings.section = section;
				settings.content = [];
				
				for (var i:int = 0; i < sections[section].items.length; i++)
				{
					var sID:uint = sections[section].items[i].sid;
					settings.content.push(sections[section].items[i]);
				}
				
				paginator.page = page == -1 ? sections[section].page : page;
				paginator.itemsCount = settings.content.length;
				paginator.update();
				
			}else 
			{
				return false;
			}
			
			contentChange();	
			return true
		}	
		
		public function refresh(e:AppEvent = null):void
		{
			sections = { };
			createContent();
			findTargetPage(settings);
			setContentSection(settings.section,settings.page);			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			contentChange();
		}
		
		override public function contentChange():void {
			
			for each(var _item:EventShopItem in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			
			if (bonusList) {
				bodyContainer.removeChild(bonusList);
				bonusList = null;
			}
			
			if (youHave) {
				bodyContainer.removeChild(youHave);
				youHave = null;
			}
			
			if (buyBttn) {
				bodyContainer.removeChild(buyBttn);
				buyBttn = null;
			}
			
			bonusList = new BonusList({1767:App.user.stock.count(Stock.EVENT_COIN)}, true, {
				hasTitle: false,
				extraWidth: true,
				bonusTextColor: 0xefcd36,
				bonusBorderColor:0x592e1e			
			});
			bodyContainer.addChild(bonusList);
			bonusList.x = settings.width - bonusList.width - 30;
			bonusList.y += 200;	
			
			buyBttn = new Button( {
				width			:75,
				height			:30,
				fontSize		:20,
				caption			:Locale.__e("flash:1382952379751"),//Купить
				bgColor			:[0x96cafc,0x608cf5],
				borderColor		:[0xb4d9ff,0x376bd9],
				bevelColor		:[0xb4d9ff, 0x376bd9],
				fontColor		:0xfffffd,
				fontBorderColor	:0x355aaa
			});
			
			bodyContainer.addChild(buyBttn);			
			buyBttn.y = 245;
			buyBttn.addEventListener(MouseEvent.CLICK, onEnergyEvent);		
			
			youHave = Window.drawText(Locale.__e('flash:1448663321439'), {//У вас
				fontSize			:(App.lang == 'jp') ? 15 : 25,
				textAlign			:"left",
				color				:0xfffbff,
				borderColor			:0x894d31
			});
			youHave.width = youHave.textWidth + 5;
			youHave.y = 190;
			
			if (App.user.stock.count(Stock.EVENT_COIN) < 10) 
			{
				buyBttn.x = 518;
				buyBttn.y = 251;
				youHave.x = buyBttn.x + buyBttn.width / 2 - youHave.width / 2;	
				youHave.y = 188;
				
			}else if (App.user.stock.count(Stock.EVENT_COIN) <= 99) 
			{
				buyBttn.x = 513;
				buyBttn.y = 250;
				youHave.x = buyBttn.x + buyBttn.width / 2 - youHave.width / 2;	
				youHave.y = 188;
				
			}else if (App.user.stock.count(Stock.EVENT_COIN) <= 999) 
			{
				buyBttn.x = 506;
				youHave.x = buyBttn.x + buyBttn.width / 2 - youHave.width / 2;	
				
			}else if (App.user.stock.count(Stock.EVENT_COIN) <= 9999) 
			{
				buyBttn.x = 503;
				youHave.x = buyBttn.x + buyBttn.width / 2 - youHave.width / 2;				
			}	
			
			bodyContainer.addChild(youHave);	
			
			items = new Vector.<EventShopItem>();
			var X:int = 95;
			var Xs:int = X;
			var Ys:int = 75;			
			var itemNum:int = 0;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:EventShopItem = new EventShopItem(settings.content[i], this);
				
				bodyContainer.addChild(item);
				
				item.x = Xs;
				if (settings.content[i].type == "Golden") {
					item.x += 50;
				}
				item.y = Ys;
				
				items.push(item);
				Xs += item.bg.width + 20;
				if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					Xs = X;
					Ys += item.bg.height + 30;
				}
				
				itemNum++;
			}			
			sections[settings.section].page = paginator.page;
			settings.page = paginator.pages;			
		}
		
		override public function drawArrows():void 
		{			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 46;
			paginator.arrowLeft.x = 30;
			paginator.arrowLeft.y = y + 100;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 30;
			paginator.arrowRight.y = y + 100;
			
			paginator.x = int((settings.width - paginator.width)/2 - 40);
			paginator.y = int(settings.height - paginator.height + 52);
		}
		
		private function notShow(sID:int):Boolean 
		{
			return false
			switch(sID) {
				case 100000:				
					return true;
				break;
			}			
			return false;
		}
	}
}

	import buttons.Button;
	import buttons.MoneySmallButton;
	import com.greensock.TweenMax;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Cursor;
	import ui.Hints;
	import units.Anime;
	import units.Field;
	import units.Unit;
	import ui.Cursor;
	import ui.Hints;
	import wins.Window;
	import wins.SimpleWindow;
	import wins.PurchaseWindow
	
	internal class EventShopItem extends LayerX {
		
		public var item:Object;
		public var bg:Bitmap;
		private var bitmap:Bitmap;
		private var buyBttn:MoneySmallButton;
		private var buyBttnNow:MoneySmallButton;
		private var _parent:*;
		private var spriteAnime:LayerX;
		private var preloader:Preloader = new Preloader();
		
		public function EventShopItem (item:Object, parent:*) {
			
			this._parent = parent;
			this.item = item;
			
			if (item.type == "Decor") 
			{
				bg = Window.backing(145, 180, 15, 'itemBacking');
			}
			else if (item.type == "Golden") 
			{
				bg = Window.backing(170, 200, 15, 'paperBackingBlue');
			}			
			
			addChild(bg);
			
			if (item.targetGlowing) {
				customGlowing(bg);
			}		
			
			bg.x -= 35;
			bg.y -= 23;
			
			spriteAnime = new LayerX();;
			addChild(spriteAnime);
			
			bitmap = new Bitmap();
			spriteAnime.addChild(bitmap);				
			
			spriteAnime.tip = function():Object { 
				
				return {
					title:item.title,
					text:item.description
				};
			};
			
			drawTitle();
			drawBttn();
			
			addChild(preloader);
			preloader.x = (bg.width)/ 2 - 35;
			preloader.y = (bg.height) / 2 - 20;
			preloader.scaleX = preloader.scaleY = 0.67;
			
			if ((item.type == 'Decor' || item.type == 'Golden' || item.type == 'Walkgolden')) {
				Load.loading(Config.getSwf(item.type, item.preview), onLoadAnimate);	
			} else {		
				Load.loading(Config.getIcon(item.type, item.preview), onLoad);
			}
		}
		
		private function onLoad(data:Bitmap):void {
			if (preloader){
				removeChild(preloader);
				preloader = null;
			}
			
			bitmap.bitmapData = data.bitmapData;
			
			if (bitmap.width > bg.width - 20) {
				bitmap.scaleX = bitmap.scaleY = (bg.width - 20)/(bitmap.width);
			}
			if (bitmap.height > bg.height - 50 ) {
				bitmap.height =  bg.height - 50;
				bitmap.scaleX = bitmap.scaleY;
			}
			
			bitmap.smoothing = true;
			
			bitmap.x = ((bg.width - bitmap.width)/2) - 35;
			bitmap.y = ((bg.height - bitmap.height) / 2) - 23;	
		}
	 
		private function onLoadAnimate(swf:*):void {
			if (preloader){
				removeChild(preloader);
				preloader = null;
			}
			
			var bitmap:Bitmap = new Bitmap(swf.sprites[swf.sprites.length - 1].bmp, 'auto', true);
			bitmap.x = swf.sprites[swf.sprites.length - 1].dx;
			bitmap.y = swf.sprites[swf.sprites.length - 1].dy;
			spriteAnime.addChild(bitmap);			
			
			if(swf.animation){
				var framesType:String;
				for (framesType in swf.animation.animations) break;
				var anime:Anime = new Anime(swf, framesType, swf.animation.ax, swf.animation.ay);
				spriteAnime.addChild(anime);
				anime.startAnimation();
				
				anime.tip = function():Object { 				
					return {
						title:item.title,
						text:item.description
					};
				};
			}			
			
			if (spriteAnime.width > bg.width - 20) {
				spriteAnime.scaleX = spriteAnime.scaleY = (bg.width - 20)/(spriteAnime.width);
			}
			if (spriteAnime.height > bg.height - 40 ) {
				spriteAnime.height =  bg.height - 40;
				spriteAnime.scaleX = spriteAnime.scaleY;
			}
			spriteAnime.x = bg.x + bg.width / 2;
			spriteAnime.y = bg.y + bg.height / 2 + 15;
			
			if (item.preview == 'solar_system') {
				spriteAnime.y += 40;
			}
			if (item.preview == 'stone_sculpture') {
				spriteAnime.y += 40;
			}
			if (item.preview == 'telescope_decor') {
				spriteAnime.y += 20;
			}
			if (item.preview == 'besetka') {
				spriteAnime.y -= 10;
			}
			if (item.preview == 'pool_with_floating_flowers') {
				spriteAnime.y -= 10;
			}
			if (item.preview == 'glade_pinwheells') {
				spriteAnime.y += 10;
			}
			if (item.preview == 'pot_of_food') {
				spriteAnime.y -= 10;
			}
			if (item.preview == 'pink_fountain') {
				spriteAnime.y -= 10;
			}
			if (item.preview == 'frozen_deer') {
				spriteAnime.y += 25;
			}
			if (item.preview == 'frozen_garden') {
				spriteAnime.y -= 20;
				spriteAnime.x -= 15;
			}
			if (item.preview == 'cart_tree') {
				spriteAnime.y -= 20;
			}
			if (item.preview == 'snowman_children') {
				spriteAnime.y -= 30;
			}
			if (item.preview == 'decor_pumpkin3') {
				spriteAnime.y -= 30;
				spriteAnime.x -= 15;
			}
			if (item.preview == 'drum2_3x3') {
				spriteAnime.y -= 15;
			}
			if (item.preview == 'dolphin_totem') {
				spriteAnime.y += 35;
			}
			if (item.preview == 'snow_boat') {
				spriteAnime.y -= 30;
			}
			if (item.preview == 'harvest_buckets') {
				spriteAnime.y -= 5;
			}
			if (item.preview == 'snow_birch') {
				spriteAnime.y += 20;
			}
			if (item.preview == 'frozen_slon') {
				spriteAnime.y += 20;
			}
			if (item.preview == 'frost_wooden_totem') {
				spriteAnime.y += 15;
			}
			if (item.preview == 'frost_flowers') {
				spriteAnime.y += 10;
			}
			if (item.preview == 'sled_with_plaid') {
				spriteAnime.y -= 20;
			}
			if (item.preview == 'snowman') {
				spriteAnime.y += 20;
			}
			if (item.preview == 'snowman_wreath') {
				spriteAnime.y += 20;
			}
			if (item.preview == 'decorated_palm') {
				spriteAnime.y += 25;
			}
			if (item.preview == 'cactus_in_garlands') {
				spriteAnime.y += 20;
			}
			if (item.preview == 'wooden_plate') {
				spriteAnime.y += 25;
			}
			if (item.preview == 'luminous_arch') {
				spriteAnime.y += 10;
				spriteAnime.x += 25;
			}
			if (item.preview == 'crystal_boulders') {
				spriteAnime.y += 30;
			}
			if (item.preview == 'lake_crystal_lilies') {
				spriteAnime.y -= 30;
			}
			if (item.preview == 'cozy_cart') {
				spriteAnime.y -= 5;
				spriteAnime.x -= 10;
			}
			if (item.preview == 'cozy_bench') {
				spriteAnime.y += 5;
				spriteAnime.x -= 20;
			}
			if (item.preview == 'cozy_armchair') {
				spriteAnime.y -= 15;
			}
			if (item.preview == 'new_year_mailbox') {
				spriteAnime.y += 15;
			}
			if (item.preview == 'santa_helper') {
				spriteAnime.y += 10;
			}
			if (item.preview == 'bucket_spruce') {
				spriteAnime.y += 25;
			}
			if (item.preview == 'beautiful_bench') {
				spriteAnime.y -= 10;
				spriteAnime.x -= 15;
			}
			if (item.preview == 'snowballs_basket') {
				spriteAnime.y -= 20;
				spriteAnime.x += 5;
			}
			if (item.preview == 'snow_sphere') {
				spriteAnime.y -= 15;
				spriteAnime.x += 5;
			}
			if (item.preview == 'box_tangerines') {
				spriteAnime.x -= 20;
			}
			if (item.preview == 'snegr_tree') {
				spriteAnime.y += 30;
			}
			if (item.preview == 'ice_road') {
				spriteAnime.y -= 30;
			}
			if (item.preview == 'ice_fence') {
				spriteAnime.y += 5;
				spriteAnime.x -= 30;
			}
			if (item.preview == 'beam_snowy') {
				spriteAnime.y += 10;
			}
			if (item.preview == 'ostrich_hat') {
				spriteAnime.y += 20;
			}
		}
		
		public function drawTitle():void 
		{	
			var title:TextField = new TextField();
			if (item.type == "Decor") 
			{
				title = Window.drawText(String(item.title), {
				color		:0xffffff,
				borderColor	:0x834d33,
				textAlign	:"center",
				fontSize	:22,
				textLeading	:-8,
				multiline	:false,
				wrap		:true,
				width		:bg.width
				});				
			}
			else if (item.type == "Golden") 
			{
				title = Window.drawText(String(item.title), {
				color		:0x2a4da9,
				borderColor	:0xf1f4ed,
				textAlign	:"center",
				fontSize	:22,
				textLeading	:-8,
				multiline	:false,
				wrap		:true,
				width		:bg.width
				});
			}
			
			title.y = -15;
			title.x = ((bg.width - title.width)/2) - 35;
			addChild(title);
		}
		
		public function drawBttn():void {
			
			var isBuyNow:Boolean = false;
			
			var bttnSettings:Object = {
				width			:100,
				height			:38,	
				fontSize		:24,
				scale			:0.8,
				hasDotes    	:false,
				fontCountColor	:0xffffff,
				fontCountBorder	:0x7e4d2c
			}
			
			if (item.currency && item.currency[Stock.EVENT_COIN])
			{
				bttnSettings['type'] = 'eventCoin';
				bttnSettings['countText'] = item.currency[Stock.EVENT_COIN];
			}
			
			buyBttn = new MoneySmallButton(bttnSettings);
			addChild(buyBttn);
			buyBttn.x = ((bg.width - buyBttn.width) / 2) - 35;
			buyBttn.y = bg.height - 47;
			buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
			
			if (item.currency[Stock.EVENT_COIN] > App.user.stock.count(Stock.EVENT_COIN)) 
			{
				buyBttn.state = Button.DISABLED;
			}		
		}	
		
		public function onBuyComplete(type:*, price:uint = 0):void {
			
			var point:Point = new Point(App.self.mouseX - buyBttn.mouseX, App.self.mouseY - buyBttn.mouseY);
			point.x += buyBttn.width / 2;
			Hints.minus(Stock.FANT, item.real, point, false, App.self.tipsContainer);
			buyBttn.state = Button.NORMAL;
			
			flyMaterial();
		}		
		
		private function onBuy(e:MouseEvent):void 
		{
			if (buyBttn.mode == Button.DISABLED) 
			{
				//Hints.text(Locale.__e('flash:1448882625281') + " " + App.data.storage[Stock.EVENT_COIN].title, Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));//Недостаточно:
				
				if (App.user.quests.tutorial) 
				{
					return;
				}
				
				new PurchaseWindow( {
					width:558,
					itemsOnPage:3,
					content:PurchaseWindow.createContent("Energy", {inguest:0, view:'ivent_money_star'}),
					title:App.data.storage[Stock.EVENT_COIN].title,
					description:Locale.__e("flash:1382952379757"),
					closeAfterBuy:false,
					autoClose:false,
					popup: true,	
					shortWindow:true,
					callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
					}
				}).show();	
				
				return;
				
			}
			
			var unit:Unit;
			if (App.map.moved && App.map.moved.info.type == 'Field' ) {
				Cursor.plant = false;
				App.map.moved.previousPlace();
				App.map.moved.move = false;
				App.map.moved.visible = false;
				App.map.moved.uninstall();
			}
			
			if (Cursor.plant) {
				Cursor.plant = false;
			}
			
			App.map.moved = null;
			if (item.type != 'Field' || item.type != 'Plant') {
				Cursor.plant == false;
			}
			
			App.user.stock.buy(item.sid, 1, null, { 'ac':1 } );
			flyMaterial(/*item.sid*/);
			return
			
			switch(item.type)
			{
				case "Material":
				case 'Vip':
				case 'Firework':
				case "Energy":
					if (item.view !='slave') 
					{
					App.user.stock.buy(item.sid, 1,null,{'ac':1});
					flyMaterial(/*item.sid*/);
					break;
					}
				case "Boost":
				case "Energy":
					var sett:Object = null;
					if (App.data.storage[item.sid].out == App.data.storage[App.user.worldID].techno[0]) {
						sett = { 
							ctr:'techno',
							wID:App.user.worldID,
							x:App.map.heroPosition.x,
							z:App.map.heroPosition.z,
							ac:1,
							capacity:App.time + App.data.options['SlaveBoughtTime']
						};
						App.user.stock.pack(item.sid, onBuyComplete, function():void {
						}, sett);
					}else {
						App.user.stock.pack(item.sid,null,null,{'ac':1});
					}
					break;
				default:
					unit = Unit.add( { sid:item.sid, buy:true } );
					unit.move = true;
					unit.isBuyNow = true;
					App.map.moved = unit;
				break;
			}			
		}		
		
		public function dispose():void 
		{
			if(buyBttn)buyBttn.removeEventListener(MouseEvent.CLICK, onBuy);
		}
		
		private function flyMaterial():void
		{
			var item:BonusItem = new BonusItem(item.sid, 0);
			var point:Point = Window.localToGlobal(this);
			item.cashMove(point, App.self.windowContainer);
		}		
		
		private function customGlowing(target:*, callback:Function = null, colorGlow:uint = 0xFFFF00):void 
		{
			TweenMax.to(target, 1, { glowFilter: { color:colorGlow, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:colorGlow, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
				}});	
			}});
		}		
	}
