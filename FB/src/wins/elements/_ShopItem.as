package wins.elements 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.Hints;
	import ui.UserInterface;
	import ui.WorldPanel;
	import units.Ahappy;
	import units.Building;
	import units.Factory;
	import units.Field;
	import units.Technological;
	import units.Wigwam;
	import units.Techno;
	import units.Unit;
	import units.WorkerUnit;
	import units.Anime2;
	import utils.Finder;
	import wins.CollectionWindow;
	import wins.elements.PriceLabel;
	import wins.ErrorWindow;
	import wins.HeroWindow;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.Window;
	import wins.TravelWindow;
	import flash.geom.ColorTransform;
	import wins.WorldsWindow;

	public class ShopItem extends LayerX {
		
		public var item:*;
		public var window:*;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		
		private var sprite:LayerX;
		private var buttonCont:Sprite;
		
		public var priceBttn:Button;
		public var clothingBttn:Button;
		public var findBttn:Button;
		public var findAhappyBttn:Button;
		public var findButton:Button;
		public var openBttn:MoneyButton;
		private var infoBttn:Button;
		private var priceLabel:PriceLabel;
		private var boughtText:TextField;
		private var comfortLabel:TextField;
		private var smallBitmap:Bitmap = new Bitmap;
		private var comfortIcon:Bitmap = new Bitmap;
		private var comfortBacking:Bitmap = new Bitmap;
		
		public var moneyType:String = "coins";
		public var previewScale:Number = 1;
		public var countOnMap:int = 0;
		public var canBuyOnMap:Array;
		
		private var needTechno:int = 0;
		private var counterLabel:TextField;
		private var isBought:Boolean = false;
		private var preloader:Preloader;
		private var backing:String = '';
		public function ShopItem(item:*, window:*) {
			
			this.item = item;
			this.window = window;
			
			/*if (item.hasOwnProperty('backview') && item.backview != '' && item.type != 'Firework') {
				backing = item.backview;
			} else {
				backing = 'itemBacking';
				
				if (item.type == 'Golden')
					backing = 'itemBackingBlue';
				
				if (item.type == 'Gamble')	
					backing = 'blueItemBacking';
			}
			
			if (item.level > App.user.level && App.user.shop[item.sid] !=1)
				backing = 'shopSpecialBacking1';
			
			if (item.hasOwnProperty('getmethod') && item.getmethod != 0)
				backing = 'itemBacking';*/
			changeBacking();
			background = Window.backing(140, 180, 10, backing);
			addChild(background);
			
			/*sprite = new LayerX();
			sprite.mouseChildren = false;
			sprite.mouseEnabled = false;
			addChild(sprite);*/
			
			if (window.settings.find != null && window.settings.find.indexOf(int(item.sid)) != -1)
			{
				glowing();
			}
			
			sprite = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			sprite.mouseChildren = false;
			sprite.mouseEnabled = false;
			
			preloader = new Preloader();
			preloader.x = background.width * 0.5;
			preloader.y = background.height * 0.5;
			sprite.addChild(preloader);
			var _bitmap:Bitmap = new Bitmap();
			tip = function():Object {
				switch(item.type) {
					case "Plant":
						for (var sid:* in item.outs) {
							if (App.data.storage[sid].mtype != 3) 
							{
								Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview),
								function(data:Bitmap):void
								{
									if (_bitmap)
									{
										_bitmap.bitmapData = data.bitmapData;
										Size.size(_bitmap, 40, 40);
									}
									
								});
							}
						}
						
						return {
							title:item.title,
							text:Locale.__e("flash:1382952380075", [TimeConverter.timeToCuts(item.levelTime * item.levels), App.data.storage[sid].cost]),
							desc:Locale.__e('flash:1402650165308'),
							icon:_bitmap//,
							//iconScale:_bitmap.scaleX
						};
					case "Decor":
						if (item.hasOwnProperty('getmethod') && item.getmethod != 0) {
							if (item.getmethod == 2) {//Можно создать в здании
								return {
									title:item.title,
									text:item.description
								};
							}
						} else {
							return {
								title:item.title,
								text:Locale.__e("flash:1382952380076", String(item.experience))
							};
						}
						
						return {
							title:item.title,
							text:item.description
						}
					break;
					default:
						if (item.hasOwnProperty('devel')) {
							if (item.devel.hasOwnProperty('craft')) {
								if(item.type == 'Building'&&item.market == 7) {
									return {
										title:item.title,
										text:item.description
									}	
								} else if (item.devel.craft.hasOwnProperty(3)) {
									var itemList:Array = new Array();
									for (var itm:String in item.devel.craft[3]) {
										if (App.data.crafting.hasOwnProperty(item.devel.craft[3][itm])&&User.inUpdate(App.data.crafting[item.devel.craft[3][itm]].out)) {
											itemList.push({target:App.data.storage[App.data.crafting[item.devel.craft[3][itm]].out],count:0});
										}
										//itemList.push({target:App.data.storage[App.data.crafting[item.devel.craft[3][itm]].out],count:0});
									}
									//itemList = [];
									return {
										title:item.title,
										text:item.description,
										
										//itemList:(item is Building)?itemList:[],
										itemList:itemList,
										width:200
									};
								}
							}
						}
						
						return {
							title:item.title,
							text:item.description
						}
				}
				
				var description:String = item.description;
				
				return {
					title:		item.title,
					text:		description
				}
			}
			
			buttonCont = new Sprite();
			
			drawTitle();
			addChild(buttonCont);
			drawButton();
			
			if (item.type == 'Plant') 
			{
				/*for (var sid:* in item.outs) 
				{
					if (sid == Stock.COINS) continue;*/
				Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
						/*break;
					
				}*/
			} else {
				if ((/*item.type == 'Decor' ||*/ item.type == 'Golden' || item.type == 'Walkgolden' || item.type == 'Animal'|| item.type == 'Mfloors'))
				{
					Load.loading(Config.getSwf(item.type, item.preview), onAnimComplete);
				} else {
					Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
				}
			}
			
			//load();
		}
		public function get getOpened():Boolean
		{
			return !levelLock;
			/*var ff:* = instance;
			switch(item.type)
			{
				case 'Building':
					if (App.user.level >= instance.level && ((App.user.shop.hasOwnProperty(item.sid))? App.user.shop[item.sid] > countOnMap: true))
						return true;
					break;
				case 'Twigwam':
					if (App.user.level >= instance.level && ((App.user.shop.hasOwnProperty(item.sid))? App.user.shop[item.sid] > countOnMap: true))
						return true;
					break;
				case 'Pharmacy':
					if (App.user.level >= instance.level && ((App.user.shop.hasOwnProperty(item.sid))? App.user.shop[item.sid] > countOnMap: true))
						return true;
				case 'Table':
					if (countOnMap < item.countonmap)
						return true;
					break;
				default:
					if (App.user.level >= item.level && ((App.user.shop.hasOwnProperty(item.sid))? App.user.shop[item.sid] > countOnMap: true))
						return true;
			}
			return false;*/
			
		}
		private function changeBacking():void 
		{
			if (item.hasOwnProperty('backview') && item.backview != '' && item.type != 'Firework'&& Window.textures.hasOwnProperty(item.backview)) 
			{
				backing = item.backview;
			} else 
			{
				backing = 'itemBacking';
				
				if (item.type == 'Golden' || item.type == 'Walkgolden' || item.type == 'Mfloors' || item.type == 'Tribute' || item.type == 'Booster')
					backing = 'shopSpecialBacking';
				
				if (item.type == 'Gamble')	
					backing = 'blueItemBacking';
			}
			
			if (drawLock)
				backing = 'shopSpecialBacking1';
			
			//if (item.hasOwnProperty('getmethod') && item.getmethod != 0)
				//backing = 'itemBacking';
		}
		
		/**
		 * Загрузка
		 */
		private function load():void {
			var link:String = Config.getIcon(item.type, item.preview);
			if (item.type == 'Decor' || item.type == 'Golden' || item.type == 'Walkgolden')
				link = Config.getSwf(item.type, item.preview);
			
			if (item.type == 'Plant') {
				for (var sid:* in item.outs) {
					if (sid == Stock.COINS) continue;
					link = Config.getIcon(App.data.storage[sid].type , App.data.storage[sid].preview);
					break;
				}
			}
			
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
			
			if (sprite.numChildren > 0) return;
			
			preloader = new Preloader();
			preloader.x = background.width * 0.5;
			preloader.y = background.height * 0.5;
			sprite.addChild(preloader);
		}
		
		public function onPreviewComplete(data:Bitmap):void
		{
			if (preloader)
			{
				sprite.removeChild(preloader);
				preloader = null;
			}
			
			var centerY:int = background.height/2;
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.scaleX = bitmap.scaleY = previewScale;	
			
			if (this.item.type != 'Lands')
			{
				if (bitmap.width > background.width - 20)
				{
					bitmap.scaleX = bitmap.scaleY = (background.width - 20)/(bitmap.width);
				}
				
				if (bitmap.height > background.height - 70 ) 
				{
					bitmap.height =  background.height - 70;
					bitmap.scaleX = bitmap.scaleY;
				}
			}
			
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width) / 2;
			
			if (item.type == 'Resource') centerY = 110;
			if (item.type == 'Lands') centerY = 100;
			
			bitmap.y = centerY - bitmap.height / 2 - 10;
			
			if (item.type == 'Material')
			{				
				bitmap.y = (background.height - bitmap.height) / 2;
			}
			
			if (drawLock || alphaSetted)
				bitmap.alpha = .6;		
			
			if (item.type == 'Golden')
			{
				var sid:int;
				var btm:Bitmap = new Bitmap(UserInterface.textures.collectionsIcon);
				btm.scaleX = btm.scaleY = .6;
				App.ui.staticGlow(btm, {color:0xddaa00,size:2});
				btm.x -= 15;
				btm.y = 0;
				var bonus:Object = App.data.treasures[item.shake];
				var tips:Object = {
					title:"",
					text:Locale.__e("flash:1396002489532")  // "Эта декорация дает элементы коллекции и важные материалы"
				}		
				
				for each (var item:* in bonus)
				{
					for (var innerItem:* in item.item)
					{
						sid = item.item[innerItem];
						if (!App.data.storage[sid])
							continue;
						if ((App.data.storage[sid].type != "Collection") &&
							(App.data.storage[sid].mtype != 3)) {
								btm.bitmapData = UserInterface.textures.collectionsIcon;
								tips.text = Locale.__e("flash:1404910191257");  // "Эта декорация дает элементы коллекции и важные материалы"
								break;
						}
					}
				}
				
				var contGolden:LayerX = new LayerX();
				addChild(contGolden);
				contGolden.x = background.width - contGolden.width - 6;
				contGolden.y = background.height - contGolden.height - 32;
				contGolden.tip = function():Object { 
					return {
						title:tips.title,
						text:tips.text
					};
				}
			}
		}
		
		/**
		 * Окончание загрузки
		 * @param	data
		 */
		private function onLoad(data:*):void {
			if (preloader) {
				if (sprite.contains(preloader)) sprite.removeChild(preloader);
				preloader = null;
			}
			
			if (data.hasOwnProperty('animation')) {
				drawAnimation(data);
			}else {
				drawPreview(data);
			}
		}
		
		private function onLoadImage(data:Bitmap):void
		{			
			LoadWalkgolden(data.bitmapData);			
		}
		
		private function LoadWalkgolden(bmd:BitmapData):void 
		{			
			if (preloader)
			{
				sprite.removeChild(preloader);
				preloader = null;
			}
			
			var bitmap:Bitmap = new Bitmap(bmd);
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width) / 2;
			bitmap.y = (background.height - bitmap.height) / 2;
			sprite.addChild(bitmap);
		}
		private var anime:Anime2;
		private function onAnimComplete(swf:*):void 
		{			
			//if (App.data.storage[item.sid].type == "Walkgolden") 
			//{
				//Load.loading(Config.getIcon(App.data.storage[item.sid].type, App.data.storage[item.sid].preview), onLoadImage);		
				//swf = swf.animation.animations.rest
				//return;
				//trace();
			//}
			
			if (preloader)
			{
				sprite.removeChild(preloader);
				preloader = null;
			}
			//if (item.sid == 692) {
				anime = new Anime2(swf, { w:background.width - 40, h:background.height - 40, type:App.data.storage[item.sid].type, framesType:'walk'} );
			//}else{
				//anime = new Anime2(swf, { w:background.width - 40, h:background.height - 40, type:App.data.storage[item.sid].type} );
			//}
			anime.x = (background.width - anime.width) / 2;
			anime.y = (background.height - anime.height) / 2;
			sprite.addChild(anime);
			
			if (drawLock || alphaSetted)
				anime.alpha = .6;
			
			for (var key:* in item.outs) 
			{
				break;
			}
			
			var contGolden:LayerX = new LayerX();
			addChild(contGolden);
			contGolden.x = background.width - contGolden.width - 6;
			contGolden.y = background.height - contGolden.height - 32;
			contGolden.tip = function():Object {
				return {
					title:App.data.storage[key].title,
					text:App.data.storage[key].description
				};
			}		
		}
		
		private function drawAnimation(swf:Object):void 
		{
			var anime:Anime2 = new Anime2(swf, { w:background.width - 20, h:background.height - 40 } );
			anime.x = background.width * 0.5 - anime.width * 0.5;
			anime.y = background.height * 0.5 - anime.height * 0.5;
			sprite.addChild(anime);
		}
		private function drawPreview(bmp:Bitmap):void 
		{
			bitmap = new Bitmap(bmp.bitmapData, PixelSnapping.AUTO, true);
			
			Size.size(bitmap, background.width * 0.8, background.height * 0.8);
				
			bitmap.x = background.width * 0.5 - bitmap.width * 0.5;
			bitmap.y = background.height * 0.5 - bitmap.height * 0.5;
			sprite.addChild(bitmap);
		}
		
		/**
		 * Определения инстанса для данной карты
		 */
		private var __instance:Object;
		private function get instance():Object 
		{
			//return null;
			
			if (__instance)
				return __instance;
			
			if (!item || !item.instance)
				return null;
			
			var index:int = World.getBuildingCount(item.sid);
			var sorter:Array = [];
			var id:*;
			countOnMap = index;
			
			if (item.instance.hasOwnProperty('level')) 
			{
				for (id in item.instance.cost) 
				{
					sorter.push({id:id});
				}
				sorter.sortOn('id', Array.NUMERIC);
				
				if (sorter.length <= index) index = sorter.length - 1;
				if (index < 0) return __instance;
				
				__instance = {
					level:		item.instance.level[sorter[index].id],
					price:		item.instance.cost[sorter[index].id],
					skip:		item.instance.req[sorter[index].id].p,
					instances:	Numbers.countProps(item.instance.req)
				}
			}else if (Numbers.countProps(item.instance) > 0) 
			{
				for (id in item.instance.cost)
				{
					sorter.push({id:id});
				}
				
				sorter.sortOn('id', Array.NUMERIC);
				
				if (sorter.length <= index) index = sorter.length - 1;
				if (index < 0) return __instance;
				/*if (item.instance.cost.length < index)
					index = 1;*/
				__instance = {
					//level:	item.instance[sorter[index].id].req.level,
					level:		item.instance.req[sorter[index].id].level,
					price:		item.instance.cost[sorter[index].id],
					skip:		item.instance.req[sorter[index].id].p,
					instances:	Numbers.countProps(item.instance.req)
				}
			}
			return __instance;
		}
		private var alphaSetted:Boolean = false;
		private var comfortCont:LayerX;
		private function setAlpha():void 
		{
			alphaSetted = true;
			if (bitmap)
				bitmap.alpha = .6;
			if (anime)
				anime.alpha = .6;
			if (title)
				title.alpha = .6;
		}
		private function clear():void 
		{
			while (buttonCont.numChildren) {
				var button:Button = buttonCont.getChildAt(0) as Button;
				buttonCont.removeChild(button);
				button.dispose();
				button = null;
			}
			alphaSetted = false;
			if (boughtText)
				boughtText.visible = false;
			if (bitmap)
				bitmap.alpha = 1;
			if (anime)
				anime.alpha = 1;
			if (title)
				title.alpha = 1;
		}
		private function drawButton():void 
		{
			clear();
			
			if (ShopWindow.shop[100].data.indexOf(item.sid) != -1)
				setNew();
				
			if (item.type == 'Golden' || item.type == 'Gamble' || item.type == 'Walkgolden')
				setStripe();
				
			if (item.type == 'Material' || item.type == 'Collection')// || item.type == 'Gamble' || item.type == 'Walkgolden')
				return;
				
			if (item.hasOwnProperty('getmethod')) {
				switch(item.getmethod) {
					case 1:	drawText(Locale.__e('flash:1427978430162')); return;//Получи выполнив задание
					case 2:	drawText(Locale.__e('flash:1437123640075')); return;//Можно создать в здании
					case 3:	/*drawFindHappyBttn();*/ return;	//Можно получить в акционке
				}
			}
			
			if (window.settings.section == 101)
			{
				switch(item.type){
					case 'Firework':
						return;
						break;
					case 'Mfloors':
					case 'Tribute':
					case 'Building':
					case 'Golden':
					case 'Walkgolden':
					case 'Resource':
						//var array:Array = World.worldsWhereEnabled(item.sid);
						//if (array.indexOf(App.user.worldID) != -1)
						//if (World.canBuyOnThisMap(item.sid) == false)
							//drawFindOnMapButton();
						//else
							//drawFindButton();
						drawFindBttn();	
						return;
						break;
				}
			}
			
			if (!ableOnMap())
				return;
			
			if (window.settings.section == 101 && (App.user.worldID == User.FARM_LOCATION /*|| App.user.worldID == User.SIGNAL_SOURCE*/) && item.type != 'Lands')
			{
				drawFindOnMapButton();
				return;
			}
			
			if (!checkLevel())
				return;
			
			if (!checkQuest())
				return;
			
			if (!checkExpire())
				return;
			
			if (!price)
				return;
			
			if (item.type == 'Energy') 
			{
				/*switch (item.view ) {
					case 'Energy':
					drawCounrOut(item.count,0x04375c,0xffffff);	
					break;
					case 'Cookies':
					drawCounrOut(item.count,0x603a15,0xfdfcce);	
					break;
					default:
				}*/
				if (!item.hasOwnProperty('socialprice') || App.isSocial('SP')) 
				{
					drawPriceBttn();
				}else 
				{
					drawSocialPriceBttn();
				}
				return;
			}
			if (item.type == 'Port' || item.type == 'Barter')
				drawFindOnMapButton();
			else
				drawPriceBttn();
			if (item.hasOwnProperty("tostock"))
				drawComfortLabel();
			
			/*if (App.user.quests.tutorial) 
			{
				App.user.quests.currentTarget = priceBttn;
				
				this.showGlowing();
				
				priceBttn.showGlowing();
				priceBttn.name = 'bttn_shop_item_find';
			}*/
			
		}
		
		private function get sid():int {
			return item.sID;
		}
		
		private function get drawLock():Boolean 
		{
			if (item.type == 'Material')
				return false;
			//var lockThis:Boolean;
			var instances:Array;
			if (item.type == 'Oracle' && item.countonmap)
			{
				instances = Map.findUnits([item.sID]);
				if (instances.length >= item.countonmap)
				{
					return true;
				}
					
			}
			if (item.type == 'Twigwam' || item.type == 'Pharmacy')
			{
				instances = Map.findUnits([item.sID]);
				if (instances.length >= 1)
				{
					return true;
				}
					
			}
			/*if (item.type == 'Tribute')
			{
				instances = Map.findUnits([item.sID]);
				if (instances.length >= 3)
				{
					return true;
				}else 
					return false;
			}*/
			if ((item.type == 'Building' || item.type == 'Hippodrome' )&& item.gcount)
			{
				instances = Map.findUnits([item.sID]);
				if (instances.length >= item.gcount)
				{
					return true;
				}
			}
			//lockThis = levelLock;
			return levelLock;
		}
		/**
		 * Заблокировано ли по уровню
		 */
		private function get levelLock():Boolean {
			//if (item.type == 'Twigwam')
				//return false;
			if (item.type == 'Tribute')
			{
				var instances:Array;
				instances = Map.findUnits([item.sID]);
				if (instances.length >= aveableCount)
				{
					return true;
				}else 
					return false;
			}
			
			if (item.type == 'Fatman')
			{
				var instances1:Array;
				instances1 = Map.findUnits([item.sID]);
				if (instances1.length >= aveableCount)
				{
					return true;
				}else 
					return false;
			}
			
			
			if (item.type == 'Mfloors')
			{
				var floorsInst:Array;
				var floorsOut:Array = [];
				var outSID:int = 0;
				var allCount:int = 0;
				floorsInst = Map.findUnits([item.sID]);
				for each(var itmtreas:* in App.data.treasures[item.treasure][item.treasure].item){
					if (App.data.storage[itmtreas].type == 'Golden' || App.data.storage[itmtreas].type == 'Walkgolden')
						outSID = itmtreas; // floorsOut.push(itmtreas);
				}
				
				floorsOut = Map.findUnits([outSID]);
				allCount = floorsOut.length + floorsInst.length + App.user.stock.count(outSID);
				
				if (item.sID == 1453)
					allCount = 1;
					
				if (allCount >= aveableCount)
					return true;
				
			}
			
			if (item.type == 'Golden')
			{
				var goldenInst:Array = Map.findUnits([item.sID]);
				
				if (goldenInst.length >= aveableCount)
					return true;
			}
			
			if (item.type == 'Gamble')
			{
				var inst:Array;
				inst = Map.findUnits([item.sID]);
				if (inst.length >= aveableCount)
				{
					return true;
				}else 
					return false;
			}
			if (item.type == 'Port' || item.type == 'Barter')
			{
				//var instns:Array;
				//instns = Map.findUnits([item.sID]);
				/*if (instns.length >= 1)
				{
					return true;
				}else */
					return false;
			}
			var openlevel:int = 1;
			//if (item.unlocked)
				openlevel = item.level;
			
			if (instance)
				openlevel = instance.level;
			
			if (App.user.shop[sid] >= countOnMap)
				return false;
				
			if (instance && countOnMap >= instance.instances)
				return true;
			
			//return true;
			return (openlevel > App.user.level);
		}
		
		public function get aveableCount():int
		{
			switch(item.type)
			{
				case 'Golden':
				case 'Mfloors':
				case 'Tribute':
					if (item.sID == 1453)
						return 1;
					else
						return 3;
					break;
				/*case 'Port':
				case 'Barter':
				case 'Gamble':
				case 'Fatman':
				case 'Twigwam':
				case 'Pharmacy':
					return 1;
					break;*/
			}
			return 1;
		}
		/**
		 * Цена покупки объекта
		 */
		public function get price():Object {
			if (instance)
				return instance.price;
			
			if (item.price)
				return item.price;
			
			return null;
		}
		
		/**
		 * 
		 */
		private function checkLevel():Boolean 
		{
			//return true;
			//if (drawLock)
				//return false;
			if (levelLock ) 
			{
			//if (!getOpened) {
				drawTextBought();
				if(item.type != 'Oracle' && item.type != 'Tribute' && item.type != 'Port' || item.type == 'Barter'|| item.type != 'Fatman')
					drawOpenBttn();
				return false;
			}
			
			return true;
		}
		
		/**
		 * Еще не открыт квест
		 * @return
		 */
		private function checkQuest():Boolean {
			if (item.unlocked && item.unlocked.quest > 0 && !App.user.quests.data[item.unlocked.quest])
				return false;
			
			return true;
		}
		
		/**
		 * Истек срок действия
		 * @return
		 */
		private function checkExpire():Boolean {
			if (item.expire) {
				if (item.expire is Number)
					return !(item.expire < App.time);
				
				if (typeof(item.expire) == 'object')
					return !(item.expire[App.social] < App.time);
			}
			
			return true;
		}
		
		/**
		 * доступно на этой карте
		 * @return
		 */
		private function ableOnMap():Boolean 
		{
			//return true;
			
			if (['Material','Collection'].indexOf(item.type) != -1)
				return true;
				
			var instances:Array;
			if (item.type == 'Oracle'&& item.countonmap)
			{
				instances = Map.findUnits([item.sID]);
				if (instances.length >= item.countonmap)
				{
					drawText(Locale.__e('flash:1481298353832')); // Нигде не доступно
					return false;
				}
					
			}
			
			if (item.type == 'Mfloors')
			{
				var floorsInst:Array;
				var floorsOut:Array = [];
				var outSID:int = 0;
				var allCount:int = 0;
				floorsInst = Map.findUnits([item.sID]);
				for each(var itmtreas:* in App.data.treasures[item.treasure][item.treasure].item){
					if (App.data.storage[itmtreas].type == 'Golden' || App.data.storage[itmtreas].type == 'Walkgolden')
						outSID = itmtreas; // floorsOut.push(itmtreas);
				}
				
				floorsOut = Map.findUnits([outSID]);
				allCount = floorsOut.length + floorsInst.length + App.user.stock.count(outSID);
				
				if (item.sID == 1453 && App.user.worldID == User.HOLIDAY_LOCATION)
					allCount = 1;
					
				if (allCount >= aveableCount){
					drawText(Locale.__e('flash:1481298353832')); // Нигде не доступно
					return false;
				}
				
			}
			
			if (item.type == 'Golden')
			{
				var goldenInst:Array = Map.findUnits([item.sID]);
				
				if (goldenInst.length >= aveableCount)
					return false;
			}
			
			if (item.type == 'Tribute')
			{
				instances = Map.findUnits([item.sID]);
				if (instances.length >= aveableCount)
				{
					drawText(Locale.__e('flash:1481298353832')); // Нигде не доступно
					return false;
				}
					
			}
			if (item.type == 'Fatman')
			{
				instances = Map.findUnits([item.sID]);
				if (instances.length >= aveableCount)
				{
					drawText(Locale.__e('flash:1481298353832')); // Нигде не доступно
					return false;
				}
					
			}
			
			if (item.type == 'Booster')
			{
				instances = Map.findUnits([item.sID]);
				if (instances.length >= aveableCount)
				{
					drawText(Locale.__e('flash:1481298353832')); // Нигде не доступно
					return false;
				}
					
			}
			if (item.type == 'Gamble')
			{
				instances = Map.findUnits([item.sID]);
				if (instances.length >= aveableCount)
				{
					drawText(Locale.__e('flash:1481298353832')); // Нигде не доступно
					return false;
				}
					
			}
			if (item.type == 'Twigwam' || item.type == 'Pharmacy')
			{
				instances = Map.findUnits([item.sID]);
				if (instances.length >= aveableCount)
				{
					drawText(Locale.__e('flash:1481298353832')); // Нигде не доступно
					return false;
				}
					
			}
			if ((item.type == 'Building' || item.type == 'Hippodrome' )&& item.gcount)
			{
				instances = Map.findUnits([item.sID]);
				if (instances.length >= item.gcount)
				{
					drawText(Locale.__e('flash:1481298353832')); // Нигде не доступно
					return false;
				}
			}
			/*
			if (World.canBuyOnThisMap(item.sid))
				return true;*/
			
			//canBuyOnMap = World.canBuyOnThisMap(item.sid);
			if (World.canBuyOnThisMap(item.sid) == false)
			{
				drawFindBttn();
				return false;
			}
			else
				return true;
		}
		
		public function drawOpenBttn():void 
		{
			var needCount:int;
			if (item.type == 'Building' || item.type == 'Hippodrome' || item.type == 'Twigwam' || item.type == 'Pharmacy')
				needCount = instance.skip;
			else
				needCount = item.skip;
				
			openBttn = new MoneyButton({
				caption:	Locale.__e("flash:1382952379890"),//Open
				countText:	needCount,
				width:		136,
				height:		43,
				fontSize:	24,
				radius:		20
			});
			buttonCont.addChild(openBttn);
			openBttn.x = (background.width - openBttn.settings.width)/2;
			openBttn.y = background.height - openBttn.height / 2 -6;
			openBttn.addEventListener(MouseEvent.CLICK, onOpenEvent);
		}
		
		private function onOpenEvent(e:MouseEvent):void 
		{
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var needCount:int;
			//if (item.type == 'Building' || item.type == 'Hippodrome' || item.type == 'Twigwam' || item.type == 'Pharmacy')
				//needCount = instance.skip;
			//else
				//needCount = item.skip;
				
			needCount = e.currentTarget.countText;
				
			if (!App.user.stock.take(Stock.FANT, needCount)) return;
			e.currentTarget.state = Button.DISABLED;
			
			Hints.minus(Stock.FANT, needCount, Window.localToGlobal(e.currentTarget), false, window);
			
			Post.send( {
				ctr:'user',
				act:'open',
				uID:App.user.id,
				sID:item.sid,
				wID:App.user.worldID,
				iID:countOnMap
			}, function(error:*, data:*, params:*):void {
				if (error) return;
				
				if (data) {
					for (var s:* in data)
						App.user.shop[s] = data[s];
				}
				//if (data.__take)
					//App.user.stock.takeAll(data.__take);
				drawButton();
				
				changeBacking();
				var newBg:Bitmap = Window.backing(140, 180, 10, backing);
				background.bitmapData = newBg.bitmapData;
			});
		}
		
		private var	findOnMapButton:Button;
		private function drawFindOnMapButton():void 
		{
			var buttonSettings:Object = {
				caption:Locale.__e("flash:1407231372860"),
				fontSize:24,
				width:100,
				height:36,
				hasDotes:false
			};
			findOnMapButton = new Button(buttonSettings);
			buttonCont.addChild(findOnMapButton);
			findOnMapButton.x = background.width/2 - findOnMapButton.width/2;
			findOnMapButton.y = background.height - findOnMapButton.height/2 - 10;
			
			findOnMapButton.addEventListener(MouseEvent.CLICK, onFindOnMap);
			
		}
		private function drawFindButton():void 
		{
			var buttonSettings:Object = {
				caption:Locale.__e("flash:1407231372860"),
				fontSize:24,
				width:136,
				height:43,
				hasDotes:false
			};
			findButton = new Button(buttonSettings);
			buttonCont.addChild(findButton);
			findButton.x = background.width / 2 - findButton.width / 2;
			findButton.y = background.height - findButton.height / 2 + 10;
			
			findButton.addEventListener(MouseEvent.CLICK, onFindLandEvent);
			
		}
		
		private function onFindOnMap(e:MouseEvent):void 
		{
			Window.closeAll();
			if (this.item.sid == 820)
			{
				var arrayHouse:Array = Map.findUnits([820]);
				if (arrayHouse.length > 0)
				{
					App.map.focusedOnCenter(arrayHouse[0], false, function():void 
					{
						arrayHouse[0].showPointing("top", -arrayHouse[0].width/2,- 50);
					});
				}else{
					new WorldsWindow( {
						title: Locale.__e('flash:1415791943192'),
						sID:	this.item.sids,
						only:	[806],
						popup:	true
					}).show();
				}
				return;
			}
			Finder.findOnMap([this.item.sid]);
			//new TravelWindow( { find:this.item.sID } ).show();
		}
		
		private function onFindLandEvent(e:MouseEvent):void 
		{
			Window.closeAll();
			new TravelWindow( { find:this.item.sID } ).show();
		}
		
		private function drawClothingBttn():void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1430304301204"),
				fontSize:24,
				width:136,
				height:43,
				hasDotes:false
			};
			clothingBttn = new Button(bttnSettings);
			addChild(clothingBttn);
			clothingBttn.x = background.width/2 - clothingBttn.width/2;
			clothingBttn.y = background.height - clothingBttn.height + 15;
			
			clothingBttn.addEventListener(MouseEvent.CLICK, onClothingEvent);
		}
		private function onClothingEvent(e:MouseEvent):void 
		{
			window.close()
			new HeroWindow({find:item.sid}).show();
		}
		
		private function drawFindBttn():void 
		{
			setAlpha();
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1407231372860"),
				fontSize:24,
				width:115,
				height:40,
				hasDotes:false
			};
			findBttn = new Button(bttnSettings);
			addChild(findBttn);
			findBttn.x = (background.width - findBttn.width) / 2;
			findBttn.y = background.height - findBttn.height + 15;
			
			findBttn.addEventListener(MouseEvent.CLICK, onFindEvent);
		}
		
		private function onFindEvent(e:MouseEvent):void 
		{
			var onMap:Array = Map.findUnits(([int(item.sid)]));
			if (onMap.length > 0) 
			{
				Window.closeAll();
				App.user.quests.findTarget([onMap[0].sid],false,null,false,onMap[0].sid,false)
			} else {
				if (World.worldsWhereEnabled(item.sid).indexOf(1226) != -1)
				{
					if (!App.user.worlds.hasOwnProperty(1226))
					{
						var onMap1:Array = Map.findUnits(([1063]));
						if (onMap1.length > 0) 
						{
							Window.closeAll();
							new SimpleWindow({
								text: 			Locale.__e('flash:1491471993640'),
								height:			250,
								confirm:function():void {
									App.user.quests.findTarget([onMap1[0].sid],false,null,false,onMap1[0].sid,false)
								}
							}).show();
							
						}else{
							if (!World.canBuyOnThisMap(1063))
							{
								new WorldsWindow( {
									title: Locale.__e('flash:1415791943192'),
									sID:	1063,
									only:	World.worldsWhereEnabled(1063),
									popup:	true
								}).show();
							}
						}
						return;
					}
				}
					
				if (!World.canBuyOnThisMap(item.sid))
				{
					new WorldsWindow( {
						title: Locale.__e('flash:1415791943192'),
						sID:	item.sid,
						only:	World.worldsWhereEnabled(item.sid),
						popup:	true
					}).show();
				}else{
					Window.closeAll();
					
					new ShopWindow({ find:[int(item.sid)] }).show();
				}
				/*new SimpleWindow( {
					text:Locale.__e('flash:1428049630057'),
					label:SimpleWindow.ATTENTION,
					popup:true
				}).show();*/
			}
		}
		
		private function drawClosedLabel():void 
		{
			infoBttn = new Button( {
				caption: Locale.__e("flash:1416404690265"),
				width:96,
				height:34,
				fontSize:24,
				radius:20,
				hasDotes:false,
				bgColor:			[0xf28102,0xca6e04],
				bevelColor:			[0xf89626,0xb05e00]
			});
			
			addChild(infoBttn);
			infoBttn.x = (background.width - infoBttn.settings.width) / 2;
			infoBttn.y = background.height - infoBttn.height +15;
			infoBttn.addEventListener(MouseEvent.CLICK, onInfoClick);
		}
		
		private function onInfoClick(e:MouseEvent):void 
		{
			var worldsWhereEnable:Array = World.canBuyOnMap(item.sID);
			
			new WorldsWindow( {
				title: Locale.__e('flash:1415791943192'),
				sID:	item.sID,
				only:	worldsWhereEnable,
				popup:	true,
				window:	window
			}).show();
		}
		
		private function drawVipUI():void 
		{
			if (App.user.stock.data.hasOwnProperty(item.sid) && App.user.stock.data[item.sid] > App.time) 
			{
				boughtText = Window.drawText('', {
					color:0xfff2dd,
					borderColor:0x7a602f,
					borderSize:4,
					fontSize:24,
					textAlign:'center',
					width:background.width - 20
				});
				boughtText.x = (background.width - boughtText.width) / 2;
				boughtText.y = background.height - boughtText.textHeight - 50;
				addChild(boughtText);
				App.self.setOnTimer(vipTimer);
				vipTimer();
				
				if (!hasEventListener(Event.REMOVED_FROM_STAGE))
					addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
				
			}else 
			{
				if (boughtText) 
				{
					removeChild(boughtText);
					boughtText = null;
				}
				drawPriceBttn();
				App.self.setOffTimer(vipTimer);
			}
		}
		
		private function vipTimer():void 
		{
			var time:int = App.user.stock.data[item.sid] - App.time;
			if (time <= 0) {
				drawVipUI();
			}else{
				boughtText.text = TimeConverter.timeToStr(time);
			}
		}
		
		private function onRemoveFromStage(event:Event):void 
		{
			if (item.type == 'Vip') 
			{
				App.self.setOffTimer(vipTimer);
			}
		}
		
		private function drawText(text:String):void 
		{
			var txt:TextField = Window.drawText(text, {
				color:0xc42f07,
				fontSize:22,
				borderColor:0xfcf5e5,
				textAlign:"center",
				borderSize:3,
				multiline:true,
				wrap:true
			});
			
			txt.width = 150;
			addChild(txt);
			txt.x = (background.width - txt.width) / 2;
			txt.y = background.height - txt.textHeight - 28;
		}
		
		
		public function setStripe():void 
		{
			var newStripe:Bitmap = new Bitmap(Window.textures.goldRibbon);
			newStripe..filters = [new GlowFilter(0xe8eea0, 0.7, 3, 3, 10, 5)];
			newStripe.x = 0;
			newStripe.y = 0;
			addChildAt(newStripe, 1);
		}
		
		
		public function setNew():void 
		{
			var newStripe:Bitmap = new Bitmap(Window.textures.stripNew);
			newStripe.x = 2;
			newStripe.y = 3;
			addChild(newStripe);
		}
		
		public function dispose():void 
		{
			if (priceBttn) {
				priceBttn.removeEventListener(MouseEvent.CLICK, onBuyEvent);
			}
			
			if (openBttn) {
				openBttn.removeEventListener(MouseEvent.CLICK, onOpenEvent);
			}
			
			buttonCont.removeChildren();
		}
		
		public function drawTitle():void 
		{
			/*var size:Point = new Point(80, 30);
			var pos:Point = new Point(
				(background.width - size.x) / 2,
				0
			);*/
			title = Window.drawText(String(item.title), {
				color:0x814f31,
				borderColor:0xfaf9ec,
				textAlign:"center",
				autoSize:"center",
				fontSize:22,				
				textLeading:-6,
				multiline:true,
				wrap:true,
				width:background.width - 20
			});
			title.y = 0;
			title.x = (background.width - title.width) / 2;
			
			if (drawLock)
			{
				title.alpha = .5;
			}
			
			addChild(title)
		}
		
		
		public function drawPriceBttn():void {
			
			if (item.type == 'Collection' || item.type == 'Material')
				return;
			
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379751"),
				fontSize:24,
				width:110,
				height:40,
				hasDotes:false
			};
			
			if (price[Stock.FANT]) {
				bttnSettings["bgColor"] = [0x97c9fe, 0x5e8ef4];
				bttnSettings["borderColor"] = [0xffdad3, 0xc25c62];
				bttnSettings["bevelColor"] = [0xb3dcfc, 0x376dda];
				bttnSettings["fontColor"] = 0xffffff;			
				bttnSettings["fontBorderColor"] = 0x395db3;
				bttnSettings["greenDotes"] = false;
				bttnSettings["diamond"] = true;
				bttnSettings["countText"] = price[Stock.FANT];
			}
			if (price[Stock.BASKET]) {
				bttnSettings["bgColor"] = [0xd36efd, 0x9c32c8];/*[0x82c9f7, 0x5cabdd];*/
				bttnSettings["bevelColor"] = [0xef99fd, 0xe8117ad];/*[0xc2e2f4, 0x3384b2];*/
				bttnSettings["fontBorderColor"] = /*0x993a40*/ 0x6e039b;
				
				//bttnSettings["bgColor"] = [0x97c9fe, 0x5e8ef4];
				//bttnSettings["borderColor"] = [0xffdad3, 0xc25c62];
				//bttnSettings["bevelColor"] = [0xb3dcfc, 0x376dda];
				bttnSettings["fontColor"] = 0xffffff;			
				//bttnSettings["fontBorderColor"] = 0x395db3;
				bttnSettings["greenDotes"] = false;
				bttnSettings["diamond"] = true;
				bttnSettings["countText"] = price[Stock.BASKET];
			}
			
			priceLabel = new PriceLabel(price, true, true);
			priceLabel.x = background.x + background.width * 0.5 - priceLabel.width * 0.5;
			priceLabel.y = background.height - 24 - priceLabel.numChildren * 32;
			addChild(priceLabel);
			
			priceBttn = new Button(bttnSettings);
			priceBttn.x = background.width/2 - priceBttn.width/2;
			priceBttn.y = background.height - priceBttn.height + 15;
			priceBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
			buttonCont.addChild(priceBttn);
			
			// Туториал
			if (App.user.quests.tutorial) 
			{
				//App.user.quests.currentTarget = priceBttn;
				var targets:Array = QuestsRules.getTargtes();
				if (targets.indexOf(int(item.sid)) != -1)
				{
					//QuestsRules.clear();
					//QuestsRules.addTarget(priceBttn);
					priceBttn.name = 'bttn_shop_item_find';
				}
			}
		}
		
		private function drawComfortLabel():void
		{	
			comfortBacking = new Bitmap(Window.textures.comfortBacking);
			comfortBacking.alpha = .8;
			comfortBacking.x = background.x + background.width - comfortBacking.width + 10;
			comfortBacking.y = 20;
			addChild(comfortBacking);
			
			comfortLabel = Window.drawText('+'+ String(Numbers.firstProp(item.tostock).val), {
			color:0x42571c,
			borderColor:0xfaf9ec,
			textAlign:"center",
			autoSize:"center",
			fontSize:20,				
			textLeading:-6,
			multiline:true,
			wrap:true,
			width:40
			});
			
			comfortIcon.x = comfortBacking.x + comfortBacking.width / 2 - comfortIcon.width - 8;
			comfortIcon.y = comfortBacking.y + 3;
			comfortIcon.filters = [new GlowFilter(0xd8ff93, 1, 2, 2, 3, 3)];
			comfortLabel.y = comfortBacking.y + 26;
			comfortLabel.x = comfortBacking.x + (comfortBacking.width - comfortLabel.width) / 2;
			addChild(comfortLabel);
			addChild(comfortIcon);
			Load.loading(Config.getIcon(App.data.storage[Numbers.firstProp(item.tostock).key].type, App.data.storage[Numbers.firstProp(item.tostock).key].preview), function(data:*):void{
				comfortIcon.bitmapData = data.bitmapData;
				Size.size(comfortIcon, 27, 27);
			});	
			
		}

		// Куплено
		private function drawTextBought():void 
		{
			var needLevel:int;
			if (item.type == 'Building' ||item.type == 'Hippodrome' || item.type == 'Pharmacy' || item.type == 'Twigwam')
				needLevel = instance.level;
			else
				needLevel = item.level;
			
			boughtText = Window.drawText(Locale.__e("flash:1382952380085", needLevel), {
				color:0x104f7d,
				border:false,
				fontSize:20,
				textAlign:"center",
				width:120,
				multiline:true,
				wrap:true
			});
			addChild(boughtText);
			boughtText.x = (background.width - boughtText.width) / 2;
			boughtText.y = background.height - boughtText.textHeight - 28;
			boughtText.visible = true;
			
			isBought = true;
		}
		
		
		private function onBuyEvent(e:MouseEvent):void 
		{
			
			if (!isEnoughTechno()) return;
			
			if (price) 
			{
				if (!App.user.stock.checkAll(price)) 
				{
					Hints.text(Locale.__e('flash:1492607773349'), Hints.TEXT_RED, BonusItem.localToGlobal(priceBttn), false, window);
					return;
				}
			}
			
			var unit:Unit;
			App.map.moved = null;
			
			ShopWindow.currentBuyObject = { type:item.type, sid:item.sid };
			
			if (App.map.moved && App.map.moved.info.type == 'Field' ) 
			{
				Cursor.plant = false;
				App.map.moved.previousPlace();
				App.map.moved.move = false;
				App.map.moved.visible = false;
				App.map.moved.uninstall();
			}
			
			if (Cursor.plant)
			{
				Cursor.plant = false;
			}
			
			if (item.type != 'Field' || item.type != 'Plant')
			{
				Cursor.plant == false;
			}
			
			if (App.user.quests.tutorial && item.type == 'Plant')
			{
				QuestsRules.counter++;
				QuestsRules.quest9_1();
			}
			
			switch(item.type) {
				case "Material":
				case 'Vip':
				case 'Firework':
				case "Energy":
					App.user.stock.buy(item.sID, 1, onMoveBuyComplete);
					break;
				case "Boost":
				case "Energy":
					App.user.stock.pack(item.sID);
					break;
				case 'Clothing':
					new HeroWindow({find:item.sid}).show();
					break;
				case "Plant":
					unit = Unit.add( { sid:Field.fieldSkin(), pID:item.sid, planted:0 } );
					unit.move = true;
					App.map.moved = unit;
					
					Cursor.plant = item.sid;
					Field.exists = false;
					
					break;
				default:
					unit = Unit.add( { sid:item.sid, buy:true } );
					unit.move = true;
					unit.fromShop = true;
					unit.isBuyNow = true;
					App.map.moved = unit;
			}
			
			if (item.type != "Material" && item.type != "Firework")
			{
				window.close();
			}else
			{
				var point:Point = localToGlobal(new Point(e.currentTarget.x, e.currentTarget.y));
				point.x += e.currentTarget.width / 2;
				Hints.minus(Numbers.firstProp(item.price).key, Numbers.firstProp(item.price).val, point);
			}
			
		}
		
		private function onMoveBuyComplete(price:Object = null):void
		{
			
			/*var material:uint = Numbers.firstProp(price).key; //item.sID;
			var cost:uint = Numbers.firstProp(price).val;*/
			var material:uint = item.sID;
			var cost:uint = item.count;
			
			var rewardObj:Object = {};
			rewardObj[material] = cost;
			if (item.type == 'Energy' && item.view == 'Feed' && !item.inguest)
			{
				material = item.out;
			}
			
			BonusItem.takeRewards( rewardObj, bitmap);
		}
		
		public var socialPriceButton:Button;
		public var callback:Function;
		public var coinsBttn:MoneyButton;
		public var banksBttn:MoneyButton;
		
		public function drawSocialPriceBttn():void 
		{
			if (item.hasOwnProperty('socialprice') && item.socialprice.hasOwnProperty(App.social)) 
			{
				var _count:Number = item.socialprice[App.social];
				
				socialPriceButton = new Button( {
					caption:Payments.price(_count),
					width			:132,
					height			:44,
					fontSize		:(App.lang == 'jp') ? 15 : 28,
					shadow:true,
					type:"green"
				});
				
				switch(App.SOCIAL)
				{
					case 'AI':
					case 'GN':
						socialPriceButton.caption = Payments.price(_count) + ' ゲソコイン';
						break;
					default:
						socialPriceButton.caption = Payments.price(_count);
						break;
				}
				
				addChild(socialPriceButton);
				socialPriceButton.addEventListener(MouseEvent.CLICK, onSocialBuyClick)
				socialPriceButton.x = background.width / 2 - socialPriceButton.width / 2;
				socialPriceButton.y = background.height - socialPriceButton.height + 15;
				
				moneyType = 'energy';
			}else {
				if (item.coins > 0)
				{
					coinsBttn = new MoneyButton( {
						countText:String(item.coins),
						width:125,
						height:46,
						caption:Locale.__e("flash:1382952379984"),
						shadow:true,
						fontCountSize:23,
						fontSize:24,
						type:"gold"
					});
					
					coinsBttn.x = background.width / 2 - coinsBttn.width / 2;
					coinsBttn.y = background.height - coinsBttn.height + 15;
					addChild(coinsBttn);
					moneyType = 'coins';
					coinsBttn.addEventListener(MouseEvent.CLICK, onBuyEvent)
				}else
				{	
					banksBttn = new MoneyButton( {
						title:Locale.__e('flash:1382952379751') + ':',
						countText:String(item.price[Stock.FANT]),
						width:132,
						height:44,
						shadow:true,
						fontCountSize:23,
						fontSize:22,
						type:"green",
						radius:18,
						fontBorderColor:0x375bb0,
						fontCountBorder:0x252273,
						iconScale:0.65,
						fontCountSize:36
					});
					
					banksBttn.x = background.width / 2 - banksBttn.width / 2;
					banksBttn.y = background.height - banksBttn.height + 15;
					moneyType = 'banknotes';
					banksBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
					addChild(banksBttn);
				}
			}
		}
		
		private function onSocialBuyClick(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var bObject:Object;
			
			if (App.social == 'FB') 
			{
				bObject = {
					id:		 	item.sID,
					type:		'Energy',
					callback: socialCallback
				};
			}else if (App.social == 'GN') 
			{
				bObject = {
					itemId:		item.type+"_" + item.sID,
					price:		int(item.socialprice[App.social]),
					amount:		1,
					itemName:	item.title,
					callback:	socialCallback
				};
			}else if (App.social == 'MX') 
			{
				bObject = {
					money: 		item.type,
					type:		'item',
					item:		item.type+"_"+item.sID,
					votes:		int(item.socialprice[App.social]),
					sid:		item.sID,
					count:		1,
					title:		item.title,
					description:item.description,
					tnidx:		App.user.id + App.time + '-' + item.type + "_" + item.sID,
					callback:	socialCallback
				}
			}else 
			{
				bObject = {
					money: 		'Energy',
					type:		'item',
					item:		'energy'+"_"+item.sID,
					votes:		int(item.socialprice[App.social]),
					sid:		item.sID,
					count:		1,
					title:		Locale.__e('flash:1396521604876'),
					description:Locale.__e('flash:1393581986914'),
					icon:		Config.getIcon(item.type, item.preview),
					tnidx:		App.user.id + App.time + '-' + 'energy' + "_" + item.sID,
					callback:	socialCallback
				}
			}
			ExternalApi.apiBalanceEvent(bObject);
		}
		
		private function drawCounrOut(text:String,brdrColor:uint,fntColor:uint):void 
		{
			var txt:TextField = Window.drawText("x"+text, {
				color:fntColor,
				borderColor:brdrColor,
				fontSize:22,
				textAlign:"left",
				borderSize:5
				
			});
			
			txt.width = 60;
			txt.height = txt.textHeight;
			addChild(smallBitmap);
			addChild(txt);
			txt.x = (background.width - txt.width)+15 ;
			txt.y = background.height - txt.textHeight - 34;
			Load.loading(Config.getIcon(App.data.storage[item.out].type , App.data.storage[item.out].preview), onSmallPreviewComplete);
			
			smallBitmap.x = txt.x - 15;
			smallBitmap.y = txt.y;
		}
		
		public function onSmallPreviewComplete(data:Bitmap):void
		{
			smallBitmap.bitmapData = data.bitmapData;
			smallBitmap.scaleX = smallBitmap.scaleY = 0.3;
		}
		
		public function socialCallback():void 
		{
			App.user.stock.add(item.out, item.count);
			Window.closeAll();
			new SimpleWindow( {
				hasTitle:true,
				height:300,
				title:Locale.__e("flash:1382952379735"),
				text:Locale.__e("flash:1382952379990")
			}).show();
		}
		
		protected function onBuySocialComplete(sID:uint, rez:Object = null):void
		{
			var currentTarget:Button;
			if (socialPriceButton) currentTarget = socialPriceButton;
			var X:Number = App.self.mouseX - currentTarget.mouseX + currentTarget.width / 2;
			var Y:Number = App.self.mouseY - currentTarget.mouseY;
			
			Hints.plus(item.sID, 1, new Point(X,Y), true, App.self.tipsContainer);
		}
		
		/**
		 * Проверка на количество рабочих, которые постоят постройку
		 * @return
		 */
		private function isEnoughTechno():Boolean 
		{
			return true;
			
			if (item.sid == Factory.TECHNO_FACTORY || !item.hasOwnProperty('instance')) return true;
			
			
			var req:Object = item.instance.cost[World.getBuildingCount(item.sid) + 1];
			for (var itm:* in req) {
				if (itm == App.data.storage[App.user.worldID].techno[0]) {
					needTechno = req[itm];
					break;
				}
			}
			
			var bots:Array = Techno.freeTechno();
			if (bots.length < needTechno) {
				var arrFactories:Array = Map.findUnits([Factory.TECHNO_FACTORY]);
				if (arrFactories.length > 0) {
					
					var winSettings:Object = {
						title				:Locale.__e('flash:1396367125010'),
						text				:Locale.__e('flash:1396367066179'),
						buttonText			:Locale.__e('flash:1396367321622'),
						//image				:UserInterface.textures.alert_storage,
						image				:Window.textures.errorOops,
						imageX				: -78,
						imageY				: -76,
						textPaddingY        : -18,
						textPaddingX        : -10,
						hasExit             :true,
						faderAsClose        :true,
						faderClickable      :true,
						closeAfterOk        :true,
						//forcedClosing       :true,
						isPopup             :true,
						bttnPaddingY        :25,
						ok					:function():void {
							new PurchaseWindow( {
								width:560,
								itemsOnPage:3,
								height:320,
								useText:true,
								//shortWindow:true,
								closeAfterBuy:false,
								autoClose:false,								
								popup:true,
								//image:new Bitmap(UserInterface.textures.alert_techno),
								image:new Bitmap(Window.textures.errorOops),
								description:Locale.__e('flash:1422628646880'),
								descWidthMarging:-140,
								content:PurchaseWindow.createContent("Energy", {view:['slave']}),
								title:Locale.__e("flash:1396364739262"),
							//	find:Stock.TECHNO,
								callback:function(sID:int):void {
									var object:* = App.data.storage[sID];
									App.user.stock.add(sID, object);
								}
							}).show();
						}
					};
					new ErrorWindow(winSettings).show();
					
					//new PurchaseWindow( {
						//width:716,
						//itemsOnPage:4,
						//useText:true,
						//shortWindow:true,
						//popup:true,
						//closeAfterBuy:true,
						//image:new Bitmap(UserInterface.textures.alert_techno),
						//description:Locale.__e('flash:1393599816743'),
						//descWidthMarging:-140,
						//content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Техно'}),
						//title:Locale.__e("Техно"),
						//description:Locale.__e("flash:1382952379757"),
						//callback:function(sID:int):void {
							//var object:* = App.data.storage[sID];
							//App.user.stock.add(sID, object);
						//}
					//}).show();
				}else {
					//ShopMenu._currBtn = 1;
					winSettings = {
						title				:Locale.__e('flash:1396364590597'),
						text				:Locale.__e('flash:1396364608277', [App.data.storage[Factory.TECHNO_FACTORY].title]),
						buttonText			:Locale.__e('flash:1393577477211'),
						//image				:UserInterface.textures.alert_storage,
						image				:Window.textures.errorOops,
						imageX				:-78,
						imageY				: -76,
						textPaddingY        : -18,
						textPaddingX        : -10,
						hasw             :true,
						faderAsClose        :true,
						faderClickable      :true,
						closeAfterOk        :true,
						bttnPaddingY        :25,
						ok					:function():void {
							new ShopWindow( { find:[Factory.TECHNO_FACTORY], forcedClosing:true } ).show();
						}
					};
					new ErrorWindow(winSettings).show();
				}
				
				
				return false;
			}
			
			return true;
		}
		
		private function glowing():void {
			//if (!App.user.quests.tutorial) {
				customGlowing(background, glowing);
			//}
			if (App.user.quests.tutorial) 
			{
				this.showPointing("bottom", 0, 200, this);
			}
			if (priceBttn) {
				
					customGlowing(priceBttn);
				//}
			}
		}
		
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xa2ff00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:0xa2ff00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
				}});	
			}});
		}
	}
}	