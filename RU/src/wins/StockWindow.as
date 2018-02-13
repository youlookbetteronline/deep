package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import units.Port;
	import units.Tent;
	import wins.elements.SearchMaterialPanel;

	public class StockWindow extends Window
	{
		public static var showUpgBttn:Boolean = true;
		public static const MINISTOCK:int = 4;
		public static const ARCHIVE:int = 1;
		public static const DESERT_WAREHOUSE:int = 2;
		public static const PAGODA:int = 3;
		public static const DEFAULT:int = 0;
		
		public static var mode:int = DEFAULT;
		public var sections:Object = new Object();
		public var plankBmap:Bitmap = new Bitmap();
		public var icons:Array = new Array();
		public var items:Vector.<StockItem> = new Vector.<StockItem>();
		public static var accelUnits:Array;
		public static var accelMaterial:int;
		private var showMessage:Boolean = true;
		
		public static var history:Object = { section:"all", page:0 };
		
		public var makeBiggerBttn:Button;
		
		public var infoBttn:ImageButton;
		private var preloader:Preloader = new Preloader();
		
		//public var capasitySprite:LayerX = new LayerX();
		//private var capasitySlider:Sprite = new Sprite();
		//private var capasityCounter:TextField;
		//public var capasityBar:Bitmap;
		
		public function StockWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["section"] = settings.section || "all"; 
			settings["page"] = settings.page || 0; 
			
			settings["find"] = settings.find || null;
			
			settings["title"] = User.inExpedition?Locale.__e('flash:1505901950203'):Locale.__e("flash:1382952379767");
			settings["width"] = 690;
			settings["height"] = 560;
			
			settings["hasPaginator"] = true;
			settings["paginatorSettings"] = {buttonsCount: 3};
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 6;/*
			settings["buttonsCount"] = 7;*/
			settings["background"] = 'storageBackingBot';
			settings["fontBorderColor"] = 0x70401d;
			//settings["hasBubbles"] = true;
			//settings["shadowBorderColor"] = 0x70401d;
			mode = settings.mode || DEFAULT;
			//settings["hasPaginator"] = false;
			//settings["footerImage"] = 'stock';
			
			
			settings["target"] = [];
			
			createContent();
			
			findTargetPage(settings);
			
			super(settings);
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
		}
		
		override public function titleText(settings:Object):Sprite
		{
			
			if (!settings.hasOwnProperty('width'))
				settings['width'] = 300;
			
			var cont:Sprite = new Sprite();
			
			settings.shadowSize = settings.shadowSize || 3;
			settings.shadowColor = settings.shadowColor || 0x111111;
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			this.settings['titleWidth'] = textLabel.textWidth;
			this.settings['titleHeight'] = textLabel.textHeight;
			textLabel.wordWrap = true;
			textLabel.width = settings.width;
			textLabel.height = textLabel.textHeight + 4;
			
			var filters:Array = []; 
			
			if (settings.borderSize > 0) 
			{
				filters.push(new GlowFilter(settings.borderColor || 0x7e3e14, 1, settings.borderSize, settings.borderSize, 16, 1));
			}
			
			if (settings.shadowSize > 0) 
			{
				filters.push(new DropShadowFilter(settings.shadowSize, 90, 0x4d3300, 1, 0, 0));
			}
			
			textLabel.filters = filters;
			
			cont.addChild(textLabel);
			cont.mouseEnabled = false;
			cont.mouseChildren = false;
			return cont;
		}
		
		override public function dispose():void {
			super.dispose();
			
			if(boostBttn)boostBttn.removeEventListener(MouseEvent.CLICK, onBoostEvent);
			boostBttn = null;
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
			
			//if (capasitySprite.parent) capasitySprite.parent.removeChild(capasitySprite);
			//if (capasitySlider.parent) capasitySlider.parent.removeChild(capasitySlider);
			//capasitySprite = null;
			//capasitySlider = null;
			//capasityCounter = null;
			//capasityBar = null;
			
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
			var background:Bitmap = backing(settings.width, settings.height, 50, settings.background);
			layer.addChild(background);
			background.x = -10;
			background.y = 40;
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: 40,				
				textLeading	 		: settings.textLeading,
				borderColor 		: 0x7e3e13,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: 0x70401d,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
				//border				: true
			})
			
			
			titleLabel.x = (settings.width - titleLabel.width) * .5 - 6;
			titleLabel.y = 16;
			headerContainer.addChild(titleLabel);
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.mouseEnabled = false;
		}
		
		/*override public function drawExit():void {
				var exit:ImageButton = new ImageButton(textures.closeBttn);
				headerContainer.addChild(exit);
				exit.x = settings.width - 70;
				exit.y = -5;
				exit.addEventListener(MouseEvent.CLICK, close);
			}*/
		
		public static function inShop(sid:uint = 0):Boolean 
		{
			var shop:Object = App.data.storage[App.user.worldID]['shop'];
					if (shop) {
						for (var type:* in shop) {
							if (shop[type].hasOwnProperty(sid)) {
								if (shop[type][sid] == 1)
									return true
							}
						}
					}
					return false
		}
	
		private function findTargetPage(settings:Object):void {			
			
			//for (var section:* in sections) {
			var j:int = Numbers.countProps(sections);
			var collectionArray:Array = [];
			while (j--){
				var section:* = Numbers.getProp(sections, j).key;
				//if (App.user.quests.currentQID == 158) 
					//section = 'others';
				for (var i:* in sections[section].items) {
					
					var sid:int = sections[section].items[i].sid;
					if (App.data.storage[sid].type == 'Collection')
						collectionArray.push(sid);
					if (settings.find != null && settings.find.indexOf(sid) != -1 && section !='all') 
					{
						//paginator.page = i / paginator.onPageCount;
						//paginator.update();
						history.section = section;
						history.page = (int(i) - collectionArray.length) / settings.itemsOnPage;
						
						settings.section = history.section;
						settings.page = history.page;
						return;
					}
				}
			}
			//close();
			
			if (settings.hasOwnProperty('find') && settings.find != null && settings.findEvent != 'load' && settings.findEvent != 'unload')
			{
				if (showMessage) 
				{
					new SimpleWindow( {
						label		:SimpleWindow.ATTENTION,
						text		:Locale.__e('flash:1425555522565', [App.data.storage[settings.find[0]].title]),
						title		:Locale.__e('flash:1382952379725'),
						popup		:true,
						confirm		:findRes,
						buttonText	:Locale.__e('flash:1407231372860')
					}).show();
					showMessage = false;
				}			
			}			
		}
		
		private function findRes():void 
		{
			Window.closeAll();
			ShopWindow.findMaterialSource(settings.find[0],this);
		}
		
		public function createContent():void {
			
			if (sections["all"] != null) return;
			
			sections = {
				
				"others":{items:new Array(),page:0},
				"all":{items:new Array(),page:0},
				"harvest":{items:new Array(),page:0},
				"jam": { items:new Array(), page:0 },
				"materials":{items:new Array(),page:0},
				"decors":{items:new Array(),page:0},
				"harvest":{items:new Array(),page:0},
			//	"collections":{items:new Array(),page:0},
				"workers":{items:new Array(),page:0}
			};
			
			var section:String = "all";
			for (var ID:* in App.user.stock.data) {
				if (ID == 3396)
					trace()
				var count:int = App.user.stock.data[ID];
				var item:Object = App.data.storage[ID];

				if(item == null)	continue;
				if (count < 1) 		continue;
				
				
				if (notShow(ID)) continue;
				//Пропускаем деньги
				//if ('gct'.indexOf(item.type) != -1) continue;

				switch(item.type){
					case 'Material':
						if (item.mtype == 0) {
							section = "materials";
						}/*else if (item.mtype == 1) {
							section = "harvest";
						}*/else if (item.mtype == 3) {
							if( mode != StockWindow.MINISTOCK) {
								continue
							 }else {
								 //Пропускаем системные
								continue; 
							 }
						
						}
						else if (item.mtype == 4 && User.inExpedition)
						{
							continue
						}
						else if (item.mtype == 4 && mode != StockWindow.MINISTOCK) {
							//Пропускаем коллекции
							section = 'collections';
							continue;
						}else{
							section = "others";
						}
						if (Stock.isHarvest(item.sID)) {
							section = "harvest";
						}
						break;
					case 'Decor':
					case 'Golden':
					case 'Walkgolden':
					case 'Walkhero':
					case 'Picker':
					case 'Tribute':
					case 'Mfloors':
						section = "decors";
						break;
					/*case 'Energy':
						section = 'others';
						break;*/
					case 'Jam':
					case 'Clothing':
					case 'Lamp':
					case 'Guide':
					case 'Vip':
							continue;
						break;
					default:
						section = "others";
						break;	
				}
				
				/*if (item.sID == 150 || item.sID == 920 || item.sID == 1690)//Пропускаем печенье (не паки)
				{
					continue;
				}*/
				
				item["sid"] = ID;
				sections[section].items.push(item);
				sections["all"].items.push(item);
			}
			
			if (mode != DEFAULT) {
				if (mode != MINISTOCK) {
					sections["all"].items = artifacts[mode];
				}else {
					sections["all"].items = sections["all"].items.concat(artifacts[PAGODA]);
					sections["all"].items = sections["all"].items.concat(artifacts[DESERT_WAREHOUSE]);
					sections["all"].items = sections["all"].items.concat(artifacts[ARCHIVE]);
				}
			}
			//for each(var _section:* in sections) {
				//_section.items.sortOn("order", Array.NUMERIC);
			//}
		}
		
		private var artifacts:Object = { 1:[], 2:[], 3:[] };
		
		private var separator:Bitmap;
		private var separator2:Bitmap;
		private var seachPanel:SearchMaterialPanel;
		override public function drawBody():void {
			//drawBacking();
			exit.x -= 25;
			exit.y += 40;
			/*drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, 2, true, true);
		if (mode == MINISTOCK) {
				drawMirrowObjs('tentDecor', -10, settings.width - 10, 0);
				drawMirrowObjs('tentDecor', -10, settings.width - 10, settings.height , false, false, false, 1, -1);
			}else {
				drawMirrowObjs('storageWoodenDec', -10, settings.width - 10, settings.height - 70);
				drawMirrowObjs('storageWoodenDec', -10, settings.width - 10, 80, false, false, false, 1, -1);
			}
			*/
			
			drawMenu();
			
			var roofBmap:Bitmap = backingShort(717, 'storageRoof');
			
			//roofBmap.scaleX = roofBmap.scaleY = 1.05;
			roofBmap.x = -23;
			roofBmap.y = -75;
			bodyContainer.addChild(roofBmap);
			setContentSection(settings.section,settings.page);
			contentChange();
			
			seachPanel = new SearchMaterialPanel( {
				win:this, 
				callback:showFinded,
				stop:onStopFinding,
				hasIcon:false,
				caption:Locale.__e('flash:1382952380300')
			});
			bodyContainer.addChild(seachPanel);
			seachPanel.y = paginator.y + 13;
			seachPanel.x = -5;
			
			this.y -= 25;
			fader.y += 25;
			
			var titleBackingBmap:Bitmap = backingShort(270, 'shopTitleBacking');
			
			//roofBmap.scaleX = roofBmap.scaleY = 1.05;
			titleBackingBmap.scaleX = titleBackingBmap.scaleY = 0.8;
			titleBackingBmap.x = roofBmap.x + roofBmap.width / 2 - titleBackingBmap.width / 2;
			titleBackingBmap.y = -53;
			bodyContainer.addChild(titleBackingBmap);
						
			plankBmap = backingShort(settings.width - 92, 'shopPlank');
			
			//roofBmap.scaleX = roofBmap.scaleY = 1.05;
			plankBmap.x = 36;
			plankBmap.y = 325;
			layer.addChild(plankBmap);
			
			var downPlankBmap:Bitmap = backingShort(300, 'shopPlankDown');
			downPlankBmap.x = settings.width / 2 -downPlankBmap.width / 2;
			downPlankBmap.y = settings.height - 10;
			layer.addChild(downPlankBmap);
			
			/*separator = Window.backingShort(160, 'separator3');
			separator.alpha = 0.5;
			separator.x = settings.backX;
			separator.y = 84;*/
			
			/*separator2 = Window.backingShort(160, 'separator3');
			separator2.alpha = 0.5;
			separator2.x = settings.backX + settings.backWidth - separator2.width;
			separator2.y = 84;*/
			
			/*bodyContainer.addChild(separator);
			bodyContainer.addChild(separator2);*/
			
			/*if(settings.target){
				if(settings.target.level < settings.target.totalLevels && showUpgBttn && !settings.target.hasPresent && settings.target.hasBuilded && settings.target.hasUpgraded){
					drawBttns();
				}
				//if(settings.target.level <= settings.target.totalLevels && showUpgBttn && !settings.target.hasPresent && settings.target.hasBuilded && settings.target.hasUpgraded){
					//addSlider();
				//}
				else if(settings.target.upgradedTime > 0 && !settings.target.hasUpgraded){
					drawUpgradeInfo();
				}else {
					drawBigSaparator();
				}
			}else {
				drawBigSaparator();
			}*/
			
			drawMinistockBttn();
			
			if (settings.findEvent == 'load' || settings.findEvent == 'unload') 
			{
				
				new ShipWindow( {
					target:	(settings.hasOwnProperty('stockTarget'))?settings.stockTarget:null,
					find:settings.find,
					findEvent:settings.findEvent,
					forcedClosing:true,
					mode:mode
				}).show();
				close();
				return;
			}
			
			//DECORATIONS
			
			var snail:Bitmap = new Bitmap(Window.textures.decSnail);
			//titleBackingBmap
			snail.scaleX = snail.scaleY = 0.9;
			snail.x = titleBackingBmap.x - 4;
			snail.y = titleBackingBmap.y - 31;
			bodyContainer.addChild(snail);
			
			var decStorageL:Bitmap = new Bitmap(Window.textures.decStorageLeft);
			decStorageL.x = -decStorageL.width/2 + 45;
			decStorageL.y = paginator.y - decStorageL.height + 20;
			bodyContainer.addChild(decStorageL);
			
			var decStorageR:Bitmap = new Bitmap(Window.textures.decStorageRight);
			decStorageR.x = settings.width - decStorageR.width;
			decStorageR.y = paginator.y - decStorageL.height + 32;
			bodyContainer.addChild(decStorageR);
			
			var star1:Bitmap = new Bitmap(Window.textures.decStarBlue);
			
			while (true)
			{
				star1.x = ((roofBmap.width /2))* Math.random() + (roofBmap.width /2 - star1.width*2);
				star1.y = (100 - star1.height*2)* Math.random() + roofBmap.y + star1.height;
				if (!star1.hitTestObject(titleBackingBmap) && !star1.hitTestObject(exit) && star1.hitTestObject(roofBmap))
				{
					bodyContainer.addChild(star1);
					
					break;
				}
			}
			
			var star2:Bitmap = new Bitmap(Window.textures.decStarYellow);
			
			while (true)
			{
				star2.x = ((roofBmap.width /2))* Math.random() + (roofBmap.width /2 - star2.width*3);
				star2.y = (100 - star2.height*2)* Math.random() + roofBmap.y + star2.height;
				if (!star2.hitTestObject(titleBackingBmap) && !star2.hitTestObject(star1) && !star2.hitTestObject(exit) && star2.hitTestObject(roofBmap))
				{
					bodyContainer.addChild(star2);
					break;
				}
			}
			
			//addSlider();
			//if(User.inExpedition)
				//createInfoIcon(); // пока скрыто
		}
		
		private function createInfoIcon():void {
			
			var infoIcon:Bitmap = new Bitmap(new BitmapData(75,75, true, 0), 'auto', true);
			infoBttn = new ImagesButton(infoIcon.bitmapData);
			
			infoBttn.tip = function():Object { 
				return {
					title:Locale.__e("flash:1382952380254"),
					text:''
				};
			};
			
			infoBttn.addEventListener(MouseEvent.CLICK, onInfo);
			
			bodyContainer.addChild(preloader);
			preloader.x = infoBttn.x + 130;
			preloader.y =  infoBttn.y + 30;
			preloader.scaleX = preloader.scaleY = 0.5;
			
			Load.loading(Config.getImageIcon("quests/icons", "helpBttn"), function(data:Bitmap):void {
				bodyContainer.removeChild(preloader);	
				infoBttn.bitmapData = data.bitmapData;				
				infoBttn.initHotspot();
			});
			
			infoBttn.x = 90;
			//if (App.isSocial('DM', 'VK', 'OK', 'MM', 'FS')) 
			//{
			bodyContainer.addChild(infoBttn);
			//}			
		}
		
		private function onInfo (e:Event = null):void 
		{
			var hintWindow:ExpeditionHintWindow = new ExpeditionHintWindow( {
				popup: true,
				hintsNum:3,
				hintID:4,
				height:540
			});
			hintWindow.show();
		}
		
		private function drawMinistockBttn():void 
		{
			if (!App.data.updatelist[App.social].hasOwnProperty('u59b168cb9a191'))//Рисуем рюкзак только когда на сети уже есть обновление "Ловец течений"
				return	
			var stockBttn:ImageButton = new ImageButton(UserInterface.textures.backpackBttnIco);
			stockBttn.tip = function():Object
			{
				return {
					title:	App.data.storage[Port.shipID].title,
					text:	App.data.storage[Port.shipID].description
				}
			}
			stockBttn.addEventListener(MouseEvent.CLICK, onStockBttn);
			//var bg:Bitmap = new Bitmap(UserInterface.textures.mainBttnBacking);
			//bodyContainer.addChild(bg); // пока скрыто
			bodyContainer.addChild(stockBttn);
			stockBttn.x = stockBttn.height / 2 -25;
			stockBttn.y = stockBttn.width / 2 -25;
			//bg.x = stockBttn.x-(bg.width-stockBttn.width)/2;
			//bg.y = stockBttn.y-(bg.height-stockBttn.height)/2;
		}
		
		private function onStockBttn(e:MouseEvent):void 
		{
			close();
			new ShipWindow( {
				target:	(settings.hasOwnProperty('stockTarget'))?settings.stockTarget:null,
				mode:mode
			}).show();
		}
		
		public function onStockShipTransferWindowBttn(e:MouseEvent):void 
		{
			//close();
			var win:* = new VoicelessShipWindow( {
				e:e,
				target:	(settings.hasOwnProperty('stockTarget'))?settings.stockTarget:null,
				popup:true,
				mode:mode
			});
			win.show();
		}
		
		private var priceSpeed:int = 0;
		//private var priceBttn:int = 0;
		private var totalTime:int = 0;
		private var finishTime:int = 0;
		private var boostBttn:MoneyButton;
		private var upgTxt:TextField;
		private function drawUpgradeInfo():void 
		{
			if(separator)
				bodyContainer.removeChild(separator);
			if(separator2)
				bodyContainer.removeChild(separator2);
			separator = null;
			separator2 = null;
			
			var time:int = 0;
			if (settings.target.created > 0 && !settings.target.hasBuilded) {
				time = settings.target.created - App.time;
				
				var curLevel:int = settings.target.level + 1;
				if (curLevel >= settings.target.totalLevels) curLevel = settings.target.totalLevels;
				finishTime = settings.target.created;
				totalTime = App.data.storage[settings.target.sid].devel.req[1].t;
			}else if (settings.target.upgradedTime > 0 && !settings.target.hasUpgraded) {
				time = settings.target.upgradedTime - App.time;
				
				finishTime = settings.target.upgradedTime;
				totalTime = App.data.storage[settings.target.sid].devel.req[settings.target.level+1].t;
			}
			
			var textSettings:Object = {
				color:0xffffff,
				borderColor:0x644b2b,
				fontSize:32,
				
				textAlign:"left"
			};
			
			upgTxt = Window.drawText(Locale.__e('flash:1402905682294') + " " + TimeConverter.timeToStr(time), textSettings); 
			upgTxt.width = upgTxt.textWidth + 10;
			upgTxt.height = upgTxt.textHeight;
			
			bodyContainer.addChild(upgTxt);
			upgTxt.x = 70;
			upgTxt.y = 44;
			
			
			priceSpeed = Math.ceil((finishTime - App.time) / App.data.options['SpeedUpPrice']);
			
			boostBttn = new MoneyButton({
					caption		:Locale.__e('flash:1382952380104'),
					width		:102,
					height		:63,	
					fontSize	:24,
					countText	:15,
					multiline	:true,
					radius:20,
					iconScale:0.67,
					fontBorderColor:0x4d7d0e,
					fontCountBorder:0x4d7d0e,
					notChangePos:true
			});
			boostBttn.x = upgTxt.x + upgTxt.width + 10;
			boostBttn.y = 32;
			bodyContainer.addChild(boostBttn);
			
			boostBttn.textLabel.y -= 12;
			boostBttn.textLabel.x = 0;
			
			boostBttn.coinsIcon.y += 12;
			boostBttn.coinsIcon.x = 2;
			
			boostBttn.countLabel.y += 12;
			boostBttn.countLabel.x = boostBttn.coinsIcon.x + boostBttn.coinsIcon.width + 6;
			
			var txtWidth:int = boostBttn.textLabel.width;
			if ((boostBttn.coinsIcon.width + 6 + boostBttn.countLabel.width) > txtWidth) {
				txtWidth = boostBttn.coinsIcon.width + 6 + boostBttn.countLabel.width;
				boostBttn.textLabel.x = (txtWidth - boostBttn.textLabel.width) / 2;
			}
			boostBttn.topLayer.x = (boostBttn.settings.width - txtWidth)/2;
			
			boostBttn.addEventListener(MouseEvent.CLICK, onBoostEvent);
			
			updateTime();
			App.self.setOnTimer(updateTime);
		}
		
		private function onBoostEvent(e:MouseEvent = null):void
		{
			//if (settings.doBoost)
				//settings.doBoost(priceBttn);
			//else
				//settings.target.acselereatEvent(priceBttn);
			//close();
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
			
			upgTxt.text = Locale.__e('flash:1402905682294') + " " + TimeConverter.timeToStr(time);
			
			
			priceSpeed = Math.ceil((finishTime - App.time) / App.data.options['SpeedUpPrice']);
			
			//if (boostBttn && priceBttn != priceSpeed && priceSpeed != 0) {
				//priceBttn = priceSpeed;
				//boostBttn.count = String(priceSpeed);
			//}
			
		}
		
		private function drawBigSaparator():void
		{
			/*bodyContainer.removeChild(separator);
			bodyContainer.removeChild(separator2);
			separator = null;
			separator2 = null;*/
			
			/*separator = Window.backingShort(580, 'separator3');
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			separator.x = settings.backX;
			separator.y = 84;*/
		}
		
		/*private function addSlider():void
		{
			capasityBar = new Bitmap(Window.textures.prograssBarBacking);			
			capasityBar.x;
			capasityBar.y = 22;
			Window.slider(capasitySlider, 60, 60, "progressBar");
			
			bodyContainer.addChild(capasitySprite);
			
			
			var textSettings:Object = {
				color:0xffffff,
				borderColor:0x644b2b,
				fontSize:32,
				
				textAlign:"center"
			};
			
			capasityCounter = Window.drawText(Stock.value +'/'+ Stock.limit, textSettings); 
			capasityCounter.width = 120;
			capasityCounter.height = capasityCounter.textHeight;
			
			capasitySprite.mouseChildren = false;
			capasitySprite.addChild(capasityBar);
			capasitySprite.addChild(capasitySlider);
			capasitySprite.addChild(capasityCounter);
			
			capasitySlider.x = capasityBar.x + 10; 
			capasitySlider.y = capasityBar.y + 6;
			
			
			if (settings.target.level < settings.target.totalLevels)
			{
				capasitySprite.x = settings.width / 2 - capasityBar.width / 2 - 85; 
				capasitySprite.y = 17;
			}else
			{
				capasitySprite.x = settings.width / 2 - capasityBar.width / 2; 
				capasitySprite.y = 17;
			};
			
			
			capasityCounter.x = capasityBar.width / 2 - capasityCounter.width / 2; 
			capasityCounter.y = capasityBar.y - capasityBar.height/2 + capasityCounter.textHeight / 2 + 8;
			
			updateCapasity(Stock.value, Stock.limit);
		}
		
		public function updateCapasity(currValue:int, maxValue:int):void
		{
			if (capasitySlider) {
				
				if (currValue < 0)
					currValue = 0;
				
				Window.slider(capasitySlider, currValue, maxValue, "progressBar");
				
				if(capasityCounter){
					capasityCounter.text = currValue +'/' + maxValue;
					capasityCounter.x = capasityBar.width / 2 - capasityCounter.width / 2;
				}
			}
		}*/
		
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
			
			makeBiggerBttn = new Button(bttnSettings);
			bodyContainer.addChild(makeBiggerBttn);
			makeBiggerBttn.tip = function():Object { 
				return {
					title:"",
					text:Locale.__e("flash:1393580216438", [settings.target.info.devel.req[settings.target.level + 1].c]) //flash:1396609462757
				};
			};
		
			makeBiggerBttn.x = settings.width * 0.5 - makeBiggerBttn.width * 0.5 + 210;
			makeBiggerBttn.y = 43;
			
			makeBiggerBttn.addEventListener(MouseEvent.CLICK, onMakeBiggerEvent);
		}
		
		private function onMakeBiggerEvent(e:MouseEvent):void 
		{
			new ConstructWindow( {
				title:settings.target.info.title,
				upgTime:settings.upgTime,
				request:settings.target.info.devel.obj[settings.target.level + 1],
				target:settings.target,
				win:this,
				onUpgrade:onUpgradeAction,
				hasDescription:true
			}).show();
		}
		
		private function onUpgradeAction(obj:Object = null, count:int = 0):void 
		{
			settings.target.upgradeEvent(settings.target.info.devel.obj[settings.target.level + 1], count);
			showUpgBttn = false;
			//App.ui.bottomPanel.bttnMainStock.buttonMode = false;
			//TweenLite.to(App.ui.bottomPanel.bttnMainStock, 1, {alpha:0});
			close();
		}
		
		private function showFinded(content:Array):void
		{
			settings.content = content;
			paginator.itemsCount = content.length;
			paginator.update();
			
			contentChange();
		}
		
		private function onStopFinding():void
		{
			setContentSection(history.section,history.page);
		}
		
		public function drawBacking():void {
			
			var backing:Bitmap = Window.backing(580, 390, 40, 'storageInnerBacking');
			bodyContainer.addChild(backing);
			backing.x = (settings.width - backing.width) / 2 - 10;
			backing.y = 98;
			
			settings['backX'] = backing.x;
			settings['backWidth'] = backing.width;
		}
		
		public function drawMenu():void {
			if (mode == StockWindow.MINISTOCK) 
			{
			return	
			}
			var menuSettings:Object = {
				"all":		{order:1, 	title:" "+Locale.__e("flash:1382952380301")},
				"harvest":	{order:2, 	title:" "+Locale.__e("flash:1382952380302")},
				"materials":{order:4, 	title:Locale.__e("flash:1382952380303")},
				"others":	{order:6, 	title:Locale.__e("flash:1382952380304")},
				"decors":	{order:5, 	title:Locale.__e("flash:1489400472396")}
			}
			
			for (var item:* in sections) {
				if (menuSettings[item] == undefined) continue;
				var settings:Object = menuSettings[item];
				settings['type'] = item;
				settings['onMouseDown'] = onMenuBttnSelect;
				
				/*if (settings.order == 1) 
				{
					settings["bgColor"] = [0xf0b738, 0xeaa125];
					settings["bevelColor"] = [0x96572d, 0x9a5b31];
					settings["fontBorderColor"] = 0x814f31;
					settings['active'] = {
						bgColor:				[0xeaa125,0xf0b738],
						bevelColor:				[0x8f5128, 0x93562a],	
						fontBorderColor:		0x814f31				//Цвет обводки шрифта		
					}
				}*/
				
				icons.push(new MenuButton(settings));
			}
			icons.sortOn("order");
			
			var sprite:Sprite = new Sprite();
			var offset:int = 0;
			for (var i:int = 0; i < icons.length; i++)
			{
				icons[i].x = offset;
				//icons[i].y = 30;
				offset += icons[i].settings.width + 6;
				sprite.addChild(icons[i]);
			}
			bodyContainer.addChild(sprite);
			sprite.x = (this.settings.width - sprite.width) / 2;
			sprite.y = 58;
			
		}
		
		private function onMenuBttnSelect(e:MouseEvent):void
		{
			if (App.user.quests.tutorial) 
			{
				return
			}
			e.currentTarget.selected = true;
			setContentSection(e.currentTarget.type);
		}
		
		public function setContentSection(section:*,page:int = -1):Boolean {
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
					if (World.worldsWhereEnabled(sID).length == 0 && App.data.storage[sID].type != 'Material')
						continue;
					//if (!World.canBuyOnThisMap(sID) && App.data.storage[sID].type != 'Material')
						//continue;
					if (App.user.stock.count(sID) > 0)
						settings.content.push(sections[section].items[i]);
				}
				
				paginator.page = page == -1 ? sections[section].page : page;
				paginator.itemsCount = settings.content.length;
				paginator.update();
				
			}else {
				return false;
			}
			
			contentChange();	
			//if(seachPanel) seachPanel.text = "";
			return true
		}
		
		
		
		public function refresh(e:AppEvent = null):void
		{
			//setContentSection(settings.section,settings.page);
			
			for (var i:int = 0; i < settings.content.length; i++)
			{
				if (App.user.stock.count(settings.content[i].sid) == 0)
				{
					settings.content.splice(i, 1);
				}
			}
			sections = { };
			createContent();
			
			//findTargetPage(settings);
			//setContentSection(settings.section,settings.page);			
			
			if (paginator) {
				paginator.itemsCount = settings.content.length;
				paginator.update();
				contentChange();
			}		
			
			//updateCapasity(Stock.value, Stock.limit);
		}
		public var snail2:Bitmap = new Bitmap(Window.textures.decSnailUP);
			
		override public function contentChange():void {
		
			for each(var _item:StockItem in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			
			items = new Vector.<StockItem>();
			//var X:int = 74;
			var X:int = 71;
			var Xs:int = X;
			var Ys:int = 107;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:StockItem = new StockItem(settings.content[i], this);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
				App.data.storage	
				items.push(item);
				Xs += item.background.width+15;
				if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					Xs = X;
					Ys += item.background.height+46;
				}
				itemNum++;
				snail2.x = item.x + item.width - 12;
				snail2.y = item.y /*- 25*/;
				
			}
			if (snail2.parent)
			{
				snail2.parent.removeChild(snail2);
			}

			if(itemNum > 0)
				bodyContainer.addChild(snail2);

			sections[settings.section].page = paginator.page;
			settings.page = paginator.page;
		}
		
		override public function drawArrows():void 
		{
			if(paginator.pages > 1){
				paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
				paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
				
				var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 46;
				paginator.arrowLeft.x = 34;
				paginator.arrowLeft.y = y + 15;
				
				paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 12;
				paginator.arrowRight.y = y + 15;
				
				//paginator.y += 87;
				paginator.x = int((settings.width - paginator.width)/2 - 5);
				paginator.y = int(settings.height - paginator.height + 60) - 8;
			}else{
				paginator.y = int(settings.height - paginator.height + 60);
			}
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
import buttons.ImageButton;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.Load;
import core.Numbers;
import core.Post;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.setTimeout;
import ui.Cursor;
import ui.UserInterface;
import ui.WishList;
import units.Field;
import units.Golden;
import units.Techno;
import units.Unit;
import utils.Effects;
import wins.StockWindow;
import wins.Window;
import wins.SellItemWindow;
import silin.filters.ColorAdjust;

/*internal class StockMenuItem extends Sprite {
	
	public var textLabel:TextField;
	public var icon:Bitmap;
	public var type:String;
	public var order:int = 0;
	public var title:String = "";
	public var selected:Boolean = false;
	public var window:*;
	
	public function StockMenuItem(type:String, window:*) {
		
		this.type = type;
		this.window = window;
		
		switch(type) {
			case "all"			: order = 1; title = Locale.__e("flash:1382952380301"); break;
			case "harvest"		: order = 2; title = Locale.__e("flash:1382952380302"); break;
			case "jam"			: order = 3; title = Locale.__e("flash:1382952380201"); break;
			case "materials"	: order = 4; title = Locale.__e("flash:1382952380303"); break;
			case "others"		: order = 6; title = Locale.__e("flash:1382952380304"); break;
			case "decors"		: order = 6; title = Locale.__e("flash:1489400472396"); break;
		}

		icon.y = - icon.height + 6;
		
		addChild(icon);
				
		textLabel = Window.drawText(title,{
			fontSize:18,
			color:0xf2efe7,
			borderColor:0x464645,
			autoSize:"center"
		});


		addChild(textLabel);
		textLabel.x = (icon.width - textLabel.width) / 2 + 200;

		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
		
	
	private function onClick(e:MouseEvent):void 
	{
		if (App.user.quests.tutorial)
			return
		this.active = true;
		window.setContentSection(type);
	}
	
	private function onOver(e:MouseEvent):void
	{
		if (!selected)
		{
			effect(0.1);
		}
	}
	
	private function onOut(e:MouseEvent):void 
	{
		if (!selected)
		{
			icon.filters = [];
		}
	}
	
	public function dispose():void 
	{
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	public function set active(selected:Boolean):void 
	{
		var format:TextFormat = new TextFormat();
		
		this.selected = selected;
		if (selected) 
		{
			glow();
			format.size = 18;
			textLabel.setTextFormat(format);
		}else 
		{
			icon.filters = [];
			textLabel.setTextFormat(textLabel.defaultTextFormat);
		}
	}
	
	public function glow():void
	{
		var myGlow:GlowFilter = new GlowFilter();
		myGlow.inner = false;
		//myGlow.color = 0xebdb81;
		myGlow.color = 0xf1d75d;
		myGlow.blurX = 10;
		myGlow.blurY = 10;
		myGlow.strength = 10
		icon.filters = [myGlow];
	}
	
	private function effect(count:int):void 
	{
		var mtrx:ColorAdjust;
		mtrx = new ColorAdjust();
		mtrx.brightness(count);
		icon.filters = [mtrx.filter];
	}
}*/

import wins.GiftWindow;
import wins.RewardWindow
import wins.SimpleWindow;
import wins.StockDeleteWindow;
import wins.ShipTransferWindow;
import wins.DarkPergamentWindow;
import wins.WorldsWindow;
import wins.TravelWindow;
import utils.Finder;
import flash.display.Sprite;

internal class StockItem extends Sprite {
	
	public var item:*;
	public var background:Bitmap;
	public var bitmap:Bitmap;
	//public var preloader:Preloader;
	public var title:TextField;
	//public var priceBttn:Button;
	public var placeBttn:Button;
	public var findBttn:Button;
	public var applyBttn:Button;
	public var closeBttn:ImageButton;
	public var wishlistBttn:ImageButton;
	public var giftBttn:ImageButton;
	public var window:*;
	public var sellPrice:TextField;
	public var price:int;
	
	public var plusBttn:Button;
	public var minusBttn:Button;
	
	public var plus10Bttn:Button;
	public var minus10Bttn:Button;
	public var backpackBttn:ImageButton;
	
	public var countCalc:TextField;
	public var sprite:LayerX;
	public var sellSprite:Sprite = new Sprite();
	private var preloader:Preloader = new Preloader();
//	private var limitMinistock;
//	private var countMinistock;
	private var block:Boolean;
	
	
	public function StockItem(item:*, window:*):void {
		
		this.item = item;
		this.window = window;
		
		background = Window.backing(166, 166, 10, "itemBacking");
		background.y -= 6;
		addChild(background);
		
		
		sprite = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		bitmap.scaleX = bitmap.scaleY = 0.8;
		sprite.addChild(bitmap);
		
		sprite.tip = function():Object { 
			return {
				title:item.title,
				text:item.description
			};
		};
		
		drawTitle();
		
		addChild(preloader);
		preloader.x = background.width / 2;
		preloader.y = background.height / 2;
		preloader.scaleX = preloader.scaleY = 0.67;
		
		drawBttns();
		
		
		Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
		
		price = item.cost;
		
		placeBttn.visible = false;
		
		applyBttn.visible = false;
		wishlistBttn.visible = false;
		
		if (WishList.canAddWishList(item.sID)) 
		{
			wishlistBttn.visible = true;
		}
		
		giftBttn.visible = true;
		
		if (StockWindow.mode == StockWindow.MINISTOCK) 
		{
			giftBttn.visible = false;
			closeBttn.visible = false;
			//wishlistBttn.x -= 50;
		}	
		//if (item.type == "e") {
			//priceBttn.visible = false;
		//}else{	
			drawSellPrice();
		//}
		
		//wishBttn.visible = true;
		
		if (item.type == "Jam"){
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			//priceBttn.visible = false;
			placeBttn.visible = true;
			closeBttn.y = 10;
		}
		
		if (['Walkhero', 'Happy','Photostand','GGame','Banker','Picker','Beast','Thappy','Building','Hippodrome','Booster','Barter','Plant','Changeable','Farm','Gardener', 'Mfield', 'Fatman','Helper', 'Tribute','Decor'/*'Golden'*/,'Animal','Ganimal','Resource','Table','Collector','Bridge','Firework', 'Techno', 'Box', 'Moneyhouse', 'Field', 'Floors','Resource','Tree','Gamble','Port','Tent','Walkgolden','Zoner','Oracle', 'Changeable', 'Mfloors', 'Boss', 'Booker', 'Technological', 'Ahappy', 'Mhelper', 'Table', 'Pharmacy', 'Ctribute'].indexOf(item.type) != -1){
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			//priceBttn.visible = false;
			placeBttn.visible = true;
			closeBttn.y = 0;
			closeBttn.x = background.width - closeBttn.width ;
			closeBttn.visible = false;
			sellSprite.visible = false;
		}
		
		if (item.type == "Golden") 
		{
			if (!User.inExpedition)
			{
				giftBttn.visible = false;
				wishlistBttn.visible = false;
				placeBttn.visible = true;
				closeBttn.y = 0;
				closeBttn.x = background.width - closeBttn.width ;
				closeBttn.visible = false;
				sellSprite.visible = false;
			}
		}		
		
		if (item.type == 'Accelerator') 
		{
			giftBttn.visible = false;
			placeBttn.visible = false;
			sellSprite.visible = false;
			applyBttn.visible = true;
			closeBttn.visible = false;
			
			applyBttn.x = (background.width - applyBttn.width) * 0.5;
		}
		
		if (item.type == 'Luckybag') {
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			placeBttn.visible = false;
			sellSprite.visible = false;
			applyBttn.visible = true;
			closeBttn.visible = false;
			
			applyBttn.x = (background.width - applyBttn.width) * 0.5;
		}
		
		if ((item.hasOwnProperty('mtype') && (item.mtype == 5 || item.mtype == 8))) 
		{
			giftBttn.visible = false;
			wishlistBttn.visible = false;
		}
		
		if (item.hasOwnProperty('mtype') && item.mtype == 8)
		{
			sellSprite.visible = false;
			closeBttn.visible = false;
		}
		
		if (item.type == 'Boss') 
		{
			giftBttn.visible = false;
			wishlistBttn.visible = true;
			applyBttn.visible = false;
			placeBttn.visible = false;
		}
		
		if (item.type == 'Wigwam') 
		{
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			applyBttn.visible = false;
			placeBttn.visible = true;
			closeBttn.visible = false;
		}
		if (item.type == 'Arcane') 
		{
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			applyBttn.visible = true;
			placeBttn.visible = false;
			closeBttn.visible = false;
		}
		if (item.type == 'Twigwam') 
		{
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			applyBttn.visible = false;
			placeBttn.visible = true;
			closeBttn.visible = false;
		}
		
		if (item.type == 'Energy')
		{
			if (User.inExpedition && (item.view == 'Cookies' || item.view == 'Cookies2' || item.view == 'Cookies3')) 
			{
				giftBttn.visible = false;
				wishlistBttn.visible = false;
				applyBttn.visible = false;
				applyBttn.x = (background.width - applyBttn.width) / 2;
				closeBttn.visible = false;
				closeBttn.x += 8;
			}else {
				giftBttn.visible = false;
				wishlistBttn.visible = false;
				applyBttn.visible = true;
				applyBttn.x = (background.width - applyBttn.width) / 2;
				closeBttn.visible = false;
				closeBttn.x += 8;
			}	
			
			if (item.view == 'Cookies' || item.view == 'Cookies2' || item.view == 'Cookies3')
			{
				var cookieSid:Number = 0
				for (var i:* in App.data.storage[App.user.worldID].cookie)
				{
					cookieSid = App.data.storage[App.user.worldID].cookie[i];
				}
				
				if (item.out != cookieSid) 
				{
					giftBttn.visible = false;
					wishlistBttn.visible = false;
					applyBttn.visible = false;
					applyBttn.x = (background.width - applyBttn.width) / 2;
					closeBttn.visible = false;
					closeBttn.x += 8;
				}
			}
		}
		if ((!World.canBuyOnThisMap(item.sid) || 
		App.user.worldID == User.NEPTUNE_MAP || 
		(App.user.worldID == User.SWEET_MAP && item.type == 14) || 
		(App.user.worldID == 3333 && (item.type == 'Golden' || item.type == 'Walkgolden'))) && 
		item.type != 'Energy' && 
		item.type != 'Material')
			drawFindBttn();
		
		drawCount();
		
		if (window.settings.find != null && window.settings.find.indexOf(int(item.sid)) != -1)
		{
			glowing();
		}
		
		if (item.type == 'Material')
		{
			drawBackpackBttn();
		}
		if (int(item.sid) == 373)
			this.addEventListener(MouseEvent.CLICK, onSimple);
	}
	
	private var clickCounter:int = 0;		
	private function onSimple(e:MouseEvent = null):void 
	{
		if (clickCounter > 10 + Math.random() * 10)
		{
			Effects.confeti(sprite, 150, {interval:1, x:90, y:160});
			clickCounter = 0;
		}
		clickCounter++;
	}
		
	
	private function drawBackpackBttn():void 
	{
		backpackBttn = new ImageButton(Window.textures.wishlistBttn);
		backpackBttn.tip = function():Object { 
			return {
				title:Locale.__e("flash:1436540673995")
			};
		};
		backpackBttn.y -= 5;
		backpackBttn.x = 130;
		backpackBttn.addEventListener(MouseEvent.CLICK, onBackPackBttnEvent);
	//	addChild(backpackBttn);
	}
	
	private function onBackPackBttnEvent(e:MouseEvent):void 
	{
		
			window.onStockShipTransferWindowBttn(e);
		
	}
	
	public function onExchange(type:*, sid:int, count:int):void {
			var items:Object = { };
			items[sid] = count;
			
			
		}
	
		
	public function dispose():void {
		this.removeEventListener(MouseEvent.CLICK, onSimple);
		//removeEventListener(MouseEvent.MOUSE_OVER, onOverEvent);
		//removeEventListener(MouseEvent.MOUSE_OUT, onOutEvent);
		
		//if (plusBttn != null){
			//plusBttn.removeEventListener(MouseEvent.CLICK, onPlusEvent);
			//minusBttn.removeEventListener(MouseEvent.CLICK, onMinusEvent);
			//plus10Bttn.removeEventListener(MouseEvent.CLICK, onPlus10Event);
			//minus10Bttn.removeEventListener(MouseEvent.CLICK, onMinus10Event);
			
		//}
		
		//Connection.MAIN_CONTAINER.removeEnterFrameCallback(bttnsShowCheck)
		
		//priceBttn.removeEventListener(MouseEvent.CLICK, onSellEvent);
		closeBttn.removeEventListener(MouseEvent.CLICK, onSellEvent);
		//if(tweenClose)tweenClose.kill();
		//tweenClose = null;
		if (backpackBttn) 
		{
		backpackBttn.removeEventListener(MouseEvent.CLICK, onBackPackBttnEvent);
		}
		
		wishlistBttn.removeEventListener(MouseEvent.CLICK, onWishlistEvent);
		giftBttn.removeEventListener(MouseEvent.CLICK, onGiftBttnEvent);
		placeBttn.removeEventListener(MouseEvent.CLICK, onPlaceEvent);
		applyBttn.removeEventListener(MouseEvent.CLICK, onApplyEvent);
	}
	
	public function drawTitle():void {
		var size:Point = new Point(background.width - 25, 50);
		var pos:Point = new Point(
			(background.width - size.x)/2,
			 - 10
			 );
		var text:String = "";
		
		title = Window.drawTextX(item.title, size.x, size.y, pos.x, pos.y, this, {
			color:0xffefef,
			borderColor:0x6a4400,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			multiline:true
		});
		title.wordWrap = true;
		addChild(title)
	}
	
	
	public function drawCount():void {
		/*var counterSprite:LayerX = new LayerX();
		counterSprite.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380305")
			};
		};*/
		
		var countOnStock:TextField = Window.drawText('x' + App.user.stock.data[item.sid] || "", {
			color:0xefcfad9,
			borderColor:0x443632,  
			fontSize:24,
			autoSize:"left"
		});
		
		var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
		//var bg:Bitmap = Window.backing(width, 40, 10, "smallBacking");
		
		//counterSprite.addChild(bg);
		/*addChild(counterSprite);
		counterSprite.x = background.width - counterSprite.width - 33;
		counterSprite.y = 122;*/
		
		addChild(countOnStock);
		countOnStock.x = background.width - countOnStock.width - 14;
		countOnStock.y = background.height - countOnStock.height - 30;
	}
	
	
	public function drawSellPrice():void 
	{
		if (item.type == 'Building')
			return;
		
		var label:TextField = Window.drawText(Locale.__e("flash:1382952380306"), {
			color:0x4A401F,
			borderSize:0,
			fontSize:18,
			autoSize:"left"
		});
		//sellSprite.addChild(label);
		
		var icon:Bitmap;
		
		icon = new Bitmap(UserInterface.textures.goldenPearl, "auto", true);
		icon.scaleX = icon.scaleY = 0.6;
		//icon.x = label.width;
		icon.x = -5;
		icon.y = 4;

		sellSprite.addChild(icon);
				
		sellPrice = Window.drawText(String(price), {
			fontSize:22,
			autoSize:"left",
			color:0xffdc39,
			borderColor:0x6d4b15
		});
		sellSprite.addChild(sellPrice);
		sellPrice.x = icon.x + icon.width;
		sellPrice.y = 5;
				
		addChild(sellSprite);
		if (price <=0) 
		{
			sellSprite.visible = false;
		}
		sellSprite.x = background.width /12;
		sellSprite.y = background.height /5;;
	}
	
	public function drawFindBttn():void 
	{
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1407231372860"),
			width:100,
			height:37,
			fontSize:22,
			hasDotes:false
		};
		findBttn = new Button(bttnSettings);
		addChild(findBttn);
		findBttn.x = (background.width - findBttn.width) / 2;
		findBttn.y = background.height - findBttn.height / 2 - 6;
		
		giftBttn.visible = false;
		placeBttn.visible = false;
		sellSprite.visible = false;
		applyBttn.visible = false;
		closeBttn.visible = false;
		wishlistBttn.visible = false;
		
		findBttn.addEventListener(MouseEvent.CLICK, onFindEvent);
	}
	
	
	private function onFindEvent(e:MouseEvent):void 
	{
		//if (!World.canBuyOnThisMap(item.sid))
		//{
		var _wrlds:Array = World.worldsWhereEnabled(item.sid);
		
		if (_wrlds.indexOf(User.NEPTUNE_MAP) != -1)
			_wrlds.splice(_wrlds.indexOf(User.NEPTUNE_MAP), 1);
			
		if (_wrlds.indexOf(User.SWEET_MAP) != -1 && item.shop == 14)
			_wrlds.splice(_wrlds.indexOf(User.SWEET_MAP), 1);
			
		if (_wrlds.indexOf(3333) != -1 && App.user.worldID == 3333 && (item.type == 'Golden' || item.type == 'Walkgolden'))
			_wrlds.splice(_wrlds.indexOf(3333), 1);
			
		if (_wrlds.indexOf(1388) != -1 && !App.user.worlds.hasOwnProperty(1388))
			Finder.findOnMap([Numbers.firstProp(App.data.storage[1388].items[0]).key]);
		else
			new WorldsWindow( {
				title: Locale.__e('flash:1415791943192'),
				sID:	null,
				only:	_wrlds,
				popup:	true
			}).show();
		//}
	}
	public function drawBttns():void 
	{
		
		placeBttn = new Button( {
			caption:Locale.__e('flash:1382952380210'),
			width:100,
			height:37,
			fontSize:22,
			hasDotes:false
		});
		addChild(placeBttn);
		
		placeBttn.x = (background.width - placeBttn.width) / 2;
		placeBttn.y = background.height - placeBttn.height / 2 - 6;
		
		placeBttn.addEventListener(MouseEvent.CLICK, onPlaceEvent);
		
		
		applyBttn = new Button( {
			caption:Locale.__e('flash:1423568900779'),
			width:100,
			hasDotes:false,
			height:37,
			fontSize:22
		});
		
		addChild(applyBttn);
		
		applyBttn.x = (background.width - applyBttn.width)/2;
		applyBttn.y = background.height - applyBttn.height / 2 - 8;
		
		applyBttn.addEventListener(MouseEvent.CLICK, onApplyEvent);
		
		// хотелки
		//var bg:Bitmap = Window.backing2(256, 69+6, 15, "cursorsPanelBg2", "cursorsPanelBg3");
			//childs.addChild(bg);
			
		wishlistBttn = new ImageButton(Window.textures.wishlistBttn);
		wishlistBttn.tip = function():Object 
		{
			return {
				title:Locale.__e("flash:1382952380013")
			};
		};
		//addChild(wishlistBttn);
		//wishlistBttn.x = (background.width - wishlistBttn.width) / 2;
		//wishlistBttn.y = background.height - wishlistBttn.height/2;
		wishlistBttn.addEventListener(MouseEvent.CLICK, onWishlistEvent);
		
		var btnnCont:Sprite = new Sprite();
		if (item.mtype != 6)	
		{
			btnnCont.addChild(wishlistBttn);
		}
		
		giftBttn = new ImageButton(UserInterface.textures.giftsIcon, { scaleX:0.65, scaleY:0.65 } );
		giftBttn.tip = function():Object { 
			return {
				title:Locale.__e("flash:1382952380012")
			};
		};
		giftBttn.y -= 5;
		giftBttn.x = giftBttn.x + giftBttn.width - 30;
		/*giftBttn.y -= 7;
		giftBttn.x -= 22;*/
		giftBttn.addEventListener(MouseEvent.CLICK, onGiftBttnEvent);
		if (item.mtype != 6)
		{
		btnnCont.addChild(giftBttn);
		}
		wishlistBttn.y -= 4;
		wishlistBttn.x -= 25;
		
		/*wishlistBttn.y -= 5;
		wishlistBttn.x = giftBttn.x + giftBttn.width + 5;*/
		
		addChild(btnnCont);
		btnnCont.x = (background.width - btnnCont.width) / 2 ;
		btnnCont.y = background.height - btnnCont.height / 2;
		
		closeBttn = new ImageButton(Window.textures.sellBttn/*storageSell*/);
		if (item.mtype != 6)
		{
			addChild(closeBttn);
		}
		closeBttn.tip = function():Object { 
			return {
				title:Locale.__e("flash:1382952380277")
			};
		};
		closeBttn.scaleX = closeBttn.scaleY = 0.95;
		
		closeBttn.x = btnnCont.x + btnnCont.width -20;
		closeBttn.y = btnnCont.y - 5;
		
		closeBttn.addEventListener(MouseEvent.CLICK, onSellEvent);
	}
	
	private function onGiftBttnEvent(e:MouseEvent):void 
	{
		new GiftWindow( {
			iconMode:GiftWindow.MATERIALS,
			itemsMode:GiftWindow.FRIENDS,
			sID:item.sid
		}).show();
		window.close();
	}
	
	private function onWishlistEvent(e:MouseEvent):void {
		App.wl.show(item.sid, e);
	}
	
	//private var tweenClose:TweenLite;
	//private function onCloseEvent(e:MouseEvent):void 
	//{
		//if(tweenClose)tweenClose.kill();
		//tweenClose = null;
		//var that:StockItem = this;
		//new StockDeleteWindow( {
			//title:Locale.__e("flash:1382952379842"),
			//text:Locale.__e("flash:1382952379968", [item.title]),
			//isImg:true,
			//dialog:true,
			//popup:true,
			//sid:item.sid,
			//confirm:function(count:int):void {
				//App.user.stock.remove(item.sid, count);
				//if(!App.user.stock.data[item.sid])
					//tweenClose = TweenMax.to(that, 0.3, { scaleX:0.2, scaleY:0.2, x:/*(that.x + that.width*0.2) + */window.settings.width / 2, y:App.self.stage.stageHeight, alpha:0, onComplete:function():void { window.refresh(); }} ); //window.refresh();
				//else
					//window.refresh();
					//
				//App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_STOCK));
			//}
		//}).show();
		//App.user.stock.remove(item.sid);
		//window.refresh();
	//}
		public function onInfoClick(e:MouseEvent):void  
		{
			var worldsWhereEnable:Array = [];
			for each (var s:* in ui.WorldPanel.allWorlds) {
				if (App.data.storage[s].hasOwnProperty('shop')) {
					for (var shopNode:String in App.data.storage[s].shop) {
						if (App.data.storage[s].shop[shopNode].hasOwnProperty(item.sID) && App.data.storage[s].shop[shopNode][item.sID] == 1) {
							var all:Array = TravelWindow.getAllIncluded();
							if(all.indexOf(int(s))!=-1)
								worldsWhereEnable.push(s);
						}
					}
				}
			}
				/*Travel.findMaterial = {
											find:[item.sID]
										}*/
			//window.settings.sID = null;																	
			new WorldsWindow( {
				title: Locale.__e('flash:1415791943192'),
				sID:	null,
				only:	worldsWhereEnable,
				popup:	true,
				window:	window
			}).show();
		}
	
	private function onPlaceEvent(e:MouseEvent):void 
	{
		/*if (canPlace(item)) //проверка на возможность ставить в этой локе
		{
			onInfoClick(e);
			return;
		}*/
		
		var settings:Object = { sid:item.sid, fromStock:true };
		
		/*if ((App.user.worldID == User.AQUA_HERO_LOCATION) && item.sID == 823)
		{
			new SimpleWindow( {
				hasTitle:true,
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
				title:Locale.__e('flash:1428052352624'),
				popup:true
			}).show();
			return;
		}*/
		
		/*if(item.type == 'Techno'){
			if (item.sid == App.data.storage[App.user.worldID].techno[0]) 
			{
			settings['capacity'] = App.time + App.data.options['SlaveBoughtTime']
			}else 
			{
			new SimpleWindow( {
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
					title:"",
					popup:true
				}).show();
				return;	
			}
		}*/
		
		if (item.sid == 815) 
		{
			settings['level'] = 2;	
		}
		
		var unit:Unit = Unit.add(settings);
		unit.move = true;
		App.map.moved = unit;
		window.close();
		if (App.user.quests.data[158] && App.user.quests.data[158].finished == 0) 
		{
			//App.user.quests.currentTarget = App.map.moved;
			//App.user.quests.stopTrack();
			//Map.createLight( { x:10,z:10,_x:28, _z:73 },App.data.storage[item.sid].preview);
			App.user.quests.currentTarget = null;
			QuestsRules.getQuestRule(158,1);
		}
	}
	
	private function canPlace(item:*):Boolean
	{
		var isCan:Boolean = true;
		switch(item.type) {
			case 'Animal':
			case 'Ganimal':
			case 'Golden':
			case 'Techno':
			case 'Building':
			case 'Hippodrome':
			case 'Barter':
			case 'Pharmacy':
			case 'Ctribute':
			case 'Mining':
			case 'Storehouse':
			case 'Factory':	
			case 'Moneyhouse':	
			case 'Trade':	
			case 'Field':
			case 'Firework':
			case 'Changeable':
			case 'Tribute':
			case 'Decor':
			case 'Tower':
			case 'Box':
			case 'Zoner':
			case 'Technological':
			case 'Floors':
			case 'Resource':
			case 'Happy':
			case 'Thappy':
			case 'Oracle':
			case 'Mhelper':
			case 'Mfield':
			case 'Gamble':
			case 'Fatman':				
			case 'Walkgolden':				
			case 'Booker':				
			case 'Ahappy':			
			case 'Table':			
				isCan = false;
			break;
		}
		
		if (!isCan)
			isCan = !StockWindow.inShop(item.sID)
		
		//if (Config.admin)
			//return false;
		
		return isCan;
	}	
	
	private function onApplyEvent(e:MouseEvent):void {
		
		//Ускорение производства
		
		if (item.type == 'Accelerator') {
			window.close();
			var sIDs:Array = [];
			
			for (var key:String in App.data.storage) {
				for (var type:String in item.targets) {
					if (item.targets[type] === App.data.storage[key].type) {
						sIDs.push(int(App.data.storage[key].sID));  
					}
				}
			}
			
			StockWindow.accelUnits = Map.findUnits(sIDs);
			
			for each (var target:* in StockWindow.accelUnits) 
			{
				if ((target.crafted > 0 && target.crafted > App.time) || (target is Golden && Golden(target).crafting))
				{
					target.showGlowing();
					
					Cursor.material = item.sid;	
					Cursor.accelerator = true;
					StockWindow.accelMaterial = int(item.sID);
				}
			}			
			return;
		}
		
		if (item.type == 'Luckybag') 
		{		
			window.close();
			App.user.stock.unpackLuckyBag(item.sID, onLuckybag, function():void {
				window.blokItems(true);
			});
			return
		}
		
		if (item.type == 'Arcane') 
		{		
			if (item.needletter)
			{
				new DarkPergamentWindow({
					sID: 		item.sID,
					opentext: 	item.opentext[int(Math.random() * item.opentext.length)],
					title:	item.titletext,
					popup:		true
				}).show();
				return
			}
			else
			{
				Window.closeAll()
				App.user.stock.unpackArcane(item.sID);
				return;
			}
			
		}
		
		if (item.type == 'Energy' || item.type == 'Vip') 
		{
			if (item.view == 'slave')
			{
				var sett:Object = null;
				sett = { 
					ctr:'techno',
					wID:App.user.worldID,
					x:App.map.heroPosition.x,
					z:App.map.heroPosition.z,
					capacity:App.time + App.data.options['SlaveBoughtTime']
				};
			
				//window.close();
				//App.user.stock.charge(item.sID);
				App.user.stock.packFree(item.sID, onBuyComplete, function():void {
					window.blokItems(true);
				}, sett);
				return
			}		
			else 
			{
				App.user.stock.charge(item.sID);				
			}			
			
			if (item.type == 'Vip'||App.data.storage[item.out].type) {
				applyBttn.state = Button.DISABLED;
			} else if (item.view == 'Cookies') 
			{
				flyMaterial(Stock.COOKIE);
				window.refresh();
				App.ui.upPanel.update();
				return;
			}else{
				flyMaterial(Stock.FANTASY);
				window.refresh();
				App.ui.upPanel.update();
				return;
			}
			
		}
		
		if (item.mtype != null && item.mtype == 5){
			Field.boost = item.ID;
			Cursor.type = 'water';
		}	
		//window.close();
	}
	
	private function onLuckybag(bonusArray:Object = null):void
	{				
		var targetPoint:Point = new Point(0, 0);
		BonusItem.takeRewards(bonusArray, targetPoint, 0, true, true);		
	}

	
	private function onBuyComplete(sID:uint, rez:Object = null):void
	{		
		if (window.settings.closeAfterBuy)	window.close();
		/*if (App.data.storage[App.user.worldID].techno[0] == sID) {
			addChildrens(sID, rez.ids);
		}*/		
	}
	
	//private function addChildrens(_sid:uint, ids:Object):void 
	//{
		/*var rel:Object = { };
		rel[Factory.TECHNO_FACTORY] = _sid;
		var position:Object = App.map.heroPosition;
		for (var i:* in ids){
			var unit:Unit = Unit.add( { sid:_sid, id:ids[i], x:position.x, z:position.z, rel:rel } );
				(unit as Techno).born({capacity:App.time + App.data.options['SlaveBoughtTime']});
		}*/
	//}
		
	private function onSellEvent(e:MouseEvent):void {
		window.settings.find = null;
		new SellItemWindow( { 
			sID:item.sID, 
			callback:function():void {
				window.refresh();
			}
		}).show();
	}
	
	
	/*
	private function onWishEvent(e:MouseEvent):void
	{
		App.wl.show(item.ID, e);
	}
	
	private function onGiftEvent(e:MouseEvent):void
	{
		new GiftWindow( {
			iconMode:GiftWindow.MATERIALS,
			itemsMode:GiftWindow.FRIENDS,
			sID:item.ID
		}).show();
	}*/
	
	public function onPreviewComplete(data:Bitmap):void
	{
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		if (bitmap.width > background.width-20) {
				bitmap.scaleX = bitmap.scaleY = (background.width - 20)/(bitmap.width);
			}
			if (bitmap.height > background.height - 20 ) {
				bitmap.height =  background.height - 20;
				bitmap.scaleX = bitmap.scaleY;// = (background.height - 70) / (bitmap.height);
			}
		bitmap.smoothing = true;
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2 + 5;
	}
	
	private function glowing():void {
		if (window.settings.hasOwnProperty('findEvent') && (window.settings.findEvent =='gift')) {
			customGlowing(background, glowing);
			customGlowing(giftBttn, null, 0xff9900);	
		} else if (window.settings.hasOwnProperty('findEvent') && (window.settings.findEvent == 'send')) {
			customGlowing(background, glowing);
			customGlowing(giftBttn, null, 0xff9900);	
		} else {
			customGlowing(background, glowing);
			customGlowing(closeBttn, null, 0xff9900);	
		}
		
	}
	
	private function customGlowing(target:*, callback:Function = null,colorGlow:uint = 0xFFFF00):void {
		TweenMax.to(target, 1, { glowFilter: { color:colorGlow, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.8, { glowFilter: { color:colorGlow, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
				if (callback != null) {
					callback();
				}
			}});	
		}});
	}	
	
	private function flyMaterial(sID:uint):void
	{
		var item:BonusItem = new BonusItem(sID, 0);
		
		var point:Point = Window.localToGlobal(bitmap);
		item.cashMove(point, App.self.windowContainer);
	}
}