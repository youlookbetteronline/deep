package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.elements.SearchMaterialPanel;

	public class ApothecaryWindow extends Window
	{
		public static var showUpgBttn:Boolean = true;
		public static const MINISTOCK:int = 4;
		public static const ARCHIVE:int = 1;
		public static const DESERT_WAREHOUSE:int = 2;
		public static const PAGODA:int = 3;
		public static const DEFAULT:int = 0;
		
		public static var mode:int = DEFAULT;
		public static var history:Object = { section:"all", page:0 };
		
		public var sections:Object = new Object();
		public var fishOrders:Object = new Object();
		public var icons:Array = new Array();
		public var items:Vector.<ApothecaryItem> = new Vector.<ApothecaryItem>();		
		public var bonusList:BonusList;
		public var plusBttn:ImageButton;		
		public var makeBiggerBttn:Button;
		public var targetSID:int;
		public var targetID:int;
		public var infoBttn:ImageButton = null;
		
		public function ApothecaryWindow(settings:Object = null):void
		{
			if (settings == null) 
			{
				settings = new Object();
			}
			
			settings["section"] = settings.section || "all";
			settings["page"] = settings.page || 0;
			settings["find"] = settings.find || null;
			settings["title"] = settings.target.info.title || Locale.__e('storage:707:title');
			settings["width"] = 800;
			settings["height"] = 620;
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 4;
			settings["buttonsCount"] = 7;
			settings["background"] = 'storageBackingTop';
			mode = settings.mode || DEFAULT;			
			
			if (App.self.getLength(App.user.apothecaryData) == 0) 
			{
				for (var id:String in settings.items)
				{
					var item:Object = App.data.storage[settings.items[id]];
					App.user.apothecaryData[id] = (item);
				}
			}
			
			fishOrders = settings.orders;
			targetSID = settings.target.sid;
			targetID = settings.target.id
			
			createContent();			
			findTargetPage(settings);			
			super(settings);
			
			
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
			
			for each(var item:* in items) 
			{
				item.dispose();
				item = null;
			}
			
			for each(var icon:* in icons)
			{
				icon.dispose();
				icon = null;
			}
		}
		
		override public function drawBackground():void
		{
			if (settings.background != null)
			{
				var background:Bitmap = backing2(settings.width, settings.height, 50, 'constructBackingUp', 'constructBackingBot');
				layer.addChild(background);	
			}
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,
				fontSize			: 46,
				textLeading	 		: settings.textLeading,
				borderColor 		: 0x673104,
				borderSize 			: 3,
				shadowSize			: 4,
				shadowColor			: 0x691F16,
				hasShadow			: true,				
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			});
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -15;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 0;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawExit():void
		{
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 60;
			exit.y = -5;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		private function drawInfoBttn():void 
		{
			infoBttn = new ImageButton(textures.infoBttnPink);
			bodyContainer.addChild(infoBttn);
			infoBttn.x = settings.width - 58;
			infoBttn.y = 40;
			infoBttn.addEventListener(MouseEvent.CLICK, info);
		}
		
		private function info(e:MouseEvent = null):void
		{
			var hintWindow:WindowInfoWindow = new WindowInfoWindow( {
				popup: true,
				hintsNum:3,
				hintID:2,
				height:540
			});
			hintWindow.show();	
			
		}
		
		private function findTargetPage(settings:Object):void
		{			
			for (var section:* in sections) 
			{
				if (App.user.quests.currentQID == 158) 
				section = 'others';
				for (var i:* in sections[section].items)
				{
					
					var sid:int = sections[section].items[i].sid;
					if (settings.find != null && settings.find.indexOf(sid) != -1) {
						
						history.section = section;
						history.page = int(int(i) / settings.itemsOnPage);
						
						settings.section = history.section;
						settings.page = history.page;
						return;
					}
				}
			}
			
			if (settings.hasOwnProperty('find')&&settings.find !=null) 
			{
				new SimpleWindow( {
					hasTitle:true,
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1425555522565', [App.data.storage[settings.find[0]].title]),
					title:Locale.__e('flash:1382952379725'),
					popup:true,
					height:300,
					confirm:findRes,
					buttonText:Locale.__e('flash:1407231372860')
				}).show();
			}			
		}
		
		private function findRes():void 
		{
			ShopWindow.findMaterialSource(settings.find[0],this);
		}
		
		public function createContent():void
		{
			if (sections["all"] != null) return;
			
			sections = {
				
				"others":{items:new Array(),page:0},
				"all":{items:new Array(),page:0},
				"harvest":{items:new Array(),page:0},
				"jam": { items:new Array(), page:0 },
				"materials":{items:new Array(),page:0},
				"workers":{items:new Array(),page:0}
			};
			
			var section:String = "all";
			
			for (var ID:* in App.data.storage[targetSID].items)
			//App.data.storage[items]
			{
				var item:Object= App.data.storage[App.data.storage[targetSID].items[ID]];
				if(item == null) continue;
				//Пропускаем деньги				
				switch(item.type)
				{
					case 'Material':				
						if (item.mtype == 0)
						{
							section = "materials";
						}
					break;
					default:
						section = "others";
					break;	
				}
				
				item["sid"] = ID;
				sections[section].items.push(item);
				sections["all"].items.sortOn('market', Array.NUMERIC);
				sections["all"].items.push(item);
				
			}
		}
		
		override public function drawBody():void 
		{
			drawInfoBttn();
			
			drawMirrowObjs('decSeaweed', settings.width + 55, - 55, settings.height - 212, true, true, false, 1, 1, bodyContainer);
			
			var titleBackingBmap:Bitmap = backingShort(320, 'shopTitleBacking');
			titleBackingBmap.x = settings.width/2 -titleBackingBmap.width/2;
			titleBackingBmap.y = -76;
			bodyContainer.addChild(titleBackingBmap);
			
			var plankBmap:Bitmap = backingShort(settings.width - 90, 'shopPlank');
			plankBmap.x = 45;
			plankBmap.y = 320;
			layer.addChild(plankBmap);
			
			var downPlankBmap:Bitmap = backingShort(300, 'shopPlankDown');
			downPlankBmap.x = settings.width/2 -downPlankBmap.width/2;
			downPlankBmap.y = settings.height - 50;
			layer.addChild(downPlankBmap);
			
			drawAcceptedMaterials();			
			setContentSection(settings.section, settings.page);
			sort();
			contentChange();
		}
		
		public function setContentSection(section:*, page:int = -1):Boolean
		{
			for each(var icon:MenuButton in icons) 
			{
				icon.selected = false;
				if (icon.type == section) {
					icon.selected = true;
				}
			}
			
			if (sections.hasOwnProperty(section)) 
			{
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
				
			}else {
				return false;
			}
			sort();
			contentChange();
			return true
		}	
		public function sort():void
		{
			var ordersArray:Array = [];
			for (var f:* in fishOrders) 
			{
				ordersArray.push(fishOrders[f]);
			}
			
			for each(var itm:* in settings.content)
			{
				if (ordersArray.indexOf(itm.sID) >= 0)
				{
					itm.market = 2;
					var count:int = App.user.stock.count(itm.sID);
			
					if (count > 0)
						itm.market = 3;
				}else
					itm.market = 1;
			}
			settings.content.sortOn('market', Array.NUMERIC | Array.DESCENDING);
		}
		
		public function refresh(e:AppEvent = null):void
		{
			sections = { };
			createContent();
			findTargetPage(settings);
			setContentSection(settings.section,settings.page);			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			sort();
			contentChange();
		}
		
		override public function contentChange():void 
		{
			for each(var _item:ApothecaryItem in items) 
			{
				bodyContainer.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			
			drawAcceptedMaterials();
			
			items = new Vector.<ApothecaryItem>();
			var X:int = 108;
			var Xs:int = X;
			var Ys:int = 355;
			
			var itemNum:int = 0;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:ApothecaryItem = new ApothecaryItem(settings.content[i], this);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;					
				items.push(item);
				Xs += item.bg.width + 5;
				
				itemNum++;
			}
			
			sections[settings.section].page = paginator.page;
			settings.page = paginator.page;			
		}
		
		public function updateOrders(slot:int, msid:int):void
		{			
			settings.orders[slot] = msid;
			drawAcceptedMaterials();
		}
		
		private var materialsContainer:Sprite = new Sprite();
		private var _materialsBG:Shape;
		private var _houseBG:Bitmap = new Bitmap();
		private var _housePrice:Bitmap = new Bitmap();
		private function drawAcceptedMaterials():void
		{			
			var bonusListObj:Object = new Object;
			
			for (var iw:* in settings.orders)
			{
				var smth:int = settings.orders[iw];
				bonusListObj[smth] = 1;
			}			
			
			materialsContainer.removeChildren();
			
			if (_acceptedMaterialsSprite && _acceptedMaterialsSprite.parent)
			{
				_acceptedMaterialsSprite.parent.removeChild(_acceptedMaterialsSprite);
			}
			
			var _acceptedMaterialsSprite:Sprite = new Sprite();
			
			if (_materialsBG && _materialsBG.parent)
			{
				_materialsBG.parent.removeChild(_materialsBG);
				_houseBG.parent.removeChild(_houseBG);
			}
			_houseBG = new Bitmap(Window.textures.apothecaryHouse);
			_houseBG.x = 50;
			_houseBG.y = 0;
			
			_housePrice = new Bitmap(UserInterface.textures.goldenPearl);
			Size.size(_housePrice, 30, 30);
			_housePrice.smoothing = true;
			_housePrice.x = _houseBG.x + 55;
			_housePrice.y = _houseBG.y + 13;
			
			var price_txt:TextField = Window.drawText('300', {
				fontSize		:26,
				color			:0xffffff,
				borderColor		:0x713f15,
				autoSize:"center"
			});
			price_txt.x = _housePrice.x + 30;
			price_txt.y = _housePrice.y + 3;
			price_txt.rotation = -7;
			
			_materialsBG = new Shape();
			_materialsBG.graphics.beginFill(0xf0c001, .5);
		    _materialsBG.graphics.drawRect(0, 0, settings.width - 380, 90);
		    _materialsBG.graphics.endFill();
			_materialsBG.filters = [new BlurFilter(40, 0, 2)];
			
			//_materialsBG = Window.backingShort(settings.width - 360, 'dailyBonusBackingDesc', true);
			//_materialsBG.scaleY = 1.7;
			//_materialsBG.smoothing = true;
			//_materialsBG.alpha = .5;
			_materialsBG.x = _houseBG.x + _houseBG.width;
			_materialsBG.y = _houseBG.y + _houseBG.height - _materialsBG.height - 20;
			
			_acceptedMaterialsSprite.addChild(_houseBG);
			_acceptedMaterialsSprite.addChild(_housePrice);
			_acceptedMaterialsSprite.addChild(_materialsBG);
			_acceptedMaterialsSprite.addChild(price_txt);
			
			var _acceptedMaterialItems:Vector.<ApothecaryIcon> = new Vector.<ApothecaryIcon>();			
			
			var currentItem:ApothecaryIcon;
			var dX:int = 10;
			var iconSize:int = 100;
			var currentCharterIcon:ApothecaryIcon;
			var itemInfo:Object;
			var materialSid:int;
			
			for (var i:int = 0; i < Numbers.countProps(bonusListObj); i++) 
			{
				materialSid = Numbers.getProp(bonusListObj, i).key;
				currentItem = new ApothecaryIcon(Numbers.getProp(bonusListObj, i).key, false, 0, iconSize, 20, null, true, materialSid);
				currentItem.x = i * (iconSize + dX);
				currentItem.y = _materialsBG.y + _materialsBG.height ;
				materialsContainer.addChild(currentItem);
				
			}
			
			if(!_acceptedMaterialsSprite.contains(materialsContainer)) {
				materialsContainer.x = (_acceptedMaterialsSprite.width - ((iconSize * materialsContainer.numChildren) + (dX * (materialsContainer.numChildren - 1)))) * 0.5 + 150;
				materialsContainer.y = (_acceptedMaterialsSprite.height - iconSize) * 0.5 - 96;
				_acceptedMaterialsSprite.addChild(materialsContainer);
				
				_acceptedMaterialsSprite.x = 15;
				_acceptedMaterialsSprite.y = 85;
				bodyContainer.addChild(_acceptedMaterialsSprite);
			}
		}
		
		override public function drawArrows():void 
		{			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 146;
			paginator.arrowLeft.x = paginator.arrowLeft.width - 10;
			paginator.arrowLeft.y = y + 5;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 10;
			paginator.arrowRight.y = y + 5;
			
			paginator.x = int((settings.width - paginator.width)/2 - 10);
			paginator.y = int(settings.height - paginator.height + 10);
		}
	}
}

import buttons.Button;
import buttons.MoneySmallButton;
import core.Load;
import core.Numbers;
import core.Post;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.setTimeout;
import ui.Cursor;
import ui.Hints;
import units.Anime;
import units.Field;
import units.Unit;
import wins.ShopWindow;
import wins.Window;
	
	internal class ApothecaryItem extends Sprite
	{		
		public var item:Object;
		public var bg:Bitmap;
		private var bitmap:Bitmap;
		private var buyBttn:Button;
		private var buyBttnNow:MoneySmallButton;
		private var _parent:*;
		private var sprite:LayerX;
		private var preloader:Preloader = new Preloader();
		
		public function ApothecaryItem (item:Object, parent:*) {
			
			this._parent = parent;
			this.item = item;
			
			bg = Window.backing(160, 180, 15, 'itemBacking');
			addChild(bg);
			
			bg.x -= 35;
			bg.y -= 23;
			
			sprite = new LayerX();
			addChild(sprite);				
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			sprite.tip = function():Object { 
				
				return {
					title:item.title,
					text:item.description
				};				
			};
			
			drawTitle();
			drawBttn();
			drawCount();
			
			addChild(preloader);
			//preloader.scaleX = preloader.scaleY = 0.67;
			preloader.x = bg.x + bg.width / 2;
			preloader.y = bg.y + bg.height / 2;
			
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		}
		
		private function onLoad(data:Bitmap):void 
		{
			if (preloader)
			{
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
		
		public function drawTitle():void 
		{
			var title:TextField = Window.drawText(String(item.title), {
				color:0x814f31,
				borderColor:0xfcf6e4,
				textAlign:"center",
				fontSize:22,
				textLeading:-10,
				multiline:false,
				wrap:true,
				width:bg.width - 20
			});
			
			title.y = -15;
			title.x = ((bg.width - title.width)/2) - 35;
			addChild(title);
		}
		
		public function drawBttn():void
		{
			if (buyBttn) 
			{
				removeChild(buyBttn);
			}
			
			var bttnSettings:Object = {
				caption     :Locale.__e("flash:1382952380277"),
				width		:100,
				height		:38,	
				fontSize	:24,
				scale		:0.8,
				hasDotes    :false
			}
			
			/*if (item.price && item.price[Stock.FANT])
			{
				bttnSettings['countText'] = item.price[Stock.FANT];
			}*/
			
			buyBttn = new Button(bttnSettings);
			addChild(buyBttn);
			buyBttn.x = (bg.width - buyBttn.width) / 2;
			buyBttn.y = bg.height - 24;
			buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
			
			var ordersArray:Array = [];
			for (var f:* in _parent.fishOrders) 
			{
				ordersArray.push(_parent.fishOrders[f]);
			}
			
			if (ordersArray.indexOf(item.sID) >= 0) 
			{
				buyBttn.state = Button.NORMAL;
				item.isInOrders = true;
			}else 
			{
				buyBttn.state = Button.DISABLED;
				//buyBttn.caption = 'Найти';
				item.isInOrders = false;
			}
			
			var count:int = App.user.stock.count(item.sID);
			
			if (count == 0) 
			{
				//buyBttn.state = Button.DISABLED;
				buyBttn.caption = 'Найти';
			}else 
			{
				if (item.isInOrders) 
				{
					buyBttn.state = Button.NORMAL;
				}				
			}
			
			buyBttn.x -= 35;
			buyBttn.y -= 23;			
		}
		
		public function drawCount():void
		{
			if (count_txt) 
			{
				removeChild(count_txt);
			}
			
			var count:int = App.user.stock.count(item.sID);
			var need:int = 1;
			
			var count_txt:TextField = Window.drawText(String(count) + "/" + String(need),{
				fontSize		:26,
				color			:0xffffff,
				borderColor		:0x713f15,
				autoSize:"center"
			});
			addChild(count_txt);
			count_txt.y = bg.y + bg.height - 65;
			count_txt.x = bg.x + (bg.width) / 2 - 20;			
		}
		
		public function onBuyComplete():void 
		{			
			var point:Point = new Point(App.self.mouseX - buyBttn.mouseX, App.self.mouseY - buyBttn.mouseY);
			point.x += buyBttn.width / 2;
			Hints.minus(item.sID, 1, point, false, App.self.tipsContainer);
			App.user.stock.take(item.sID, 1);
			drawBttn();			
		}		
		
		private function onBuy(e:MouseEvent):void 
		{
			if (buyBttn.mode == Button.DISABLED && !item.isInOrders) 
			{
				Hints.text(Locale.__e('flash:1474363204520'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));//Рыбкам не нужно это лекарство!
				return;
			}
			
			var count:int = App.user.stock.count(item.sID);
			if (count == 0) 
			{
				//Hints.text(Locale.__e('flash:1474363409152'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));//Нет на складе!					
				//setTimeout(findCraft, 1500);
				findCraft();
				return;
			}
			
			//Узнаём id слота
			var slotID:int = 0;
			for (var slot:* in _parent.fishOrders)
			{
				if (item.sID == _parent.fishOrders[slot]) 
				{
					slotID = slot;
				}
			}
			
			Post.send({
				ctr:'Pharmacy',
				act:'sell',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:_parent.targetSID,
				id:_parent.targetID,
				iID:slotID
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				onBuyComplete();				
				_parent.updateOrders(data.iID, data.mID);
				_parent.refresh();
				drawCount();
				
				var ssid:int = 0;
				var scount:int = 0;
				for (var h:* in data.bonus) 
				{
					ssid = h;
					for (var d:* in data.bonus[h])
					{
						scount = data.bonus[h][d] + Numbers.getProp(data.bonus[h], 1).key;
						break;
					}
					App.user.stock.add(ssid, scount);
					flyMaterial(ssid, scount);
				}
				
			});			
		}
		
		public function findCraft():void 
		{
			Window.closeAll();
			ShopWindow.findMaterialSource(item.sID);
		}
		
		public function dispose():void 
		{
			if(buyBttn)buyBttn.removeEventListener(MouseEvent.CLICK, onBuy);
		}
		
		private function flyMaterial(sid:int, count:int):void
		{
			var item:BonusItem = new BonusItem(sid, count);
			
			var point:Point = Window.localToGlobal(this);
			item.cashMove(point, App.self.windowContainer);
		}
	}
