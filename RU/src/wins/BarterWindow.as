package wins
{
	import buttons.Button;
	import buttons.MoneyButton;
	import buttons.MoneySmallButton;
	import com.greensock.plugins.DropShadowFilterPlugin;
	import core.Load;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	
	public class BarterWindow extends Window
	{
		
		public static var history:int = 0;
		public var items:Vector.<BarterItems> = new Vector.<BarterItems>();
		public var mode:uint;
		public var timeToChange:uint = 0;
		public var ID:uint;
		
		public var openedActions:Array = [];
		public static var barter:Object = {};
		private var nuggetIcon:Bitmap;
		private var ribbon:Bitmap;
		private var nuggetInStock:TextField;
		public var find:Array = [];
		public var currentBarter:Object = {};
		public var bartersForLevel:Array = [];
		public var title:TextField;
		public var bubble:Bitmap;
		
		public function BarterWindow(settings:Object = null):void
		{
			if (settings == null)
			{
				settings = new Object();
			}
			
			settings["title"] = App.data.storage[settings.target.sid].title;
			settings["width"] = 580;
			settings["height"] = 640;
			settings['background'] = 'capsuleWindowBacking';
			settings["hasPaginator"] = false;
			settings['content'] = [];
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			settings['exitTexture'] = 'closeBttnMetal';
			super(settings);
			
			bID = settings.target.bID;
			barter = App.data.barter[bID];
			timeToChange = settings.target.bTime + barter.time + 10;
			
			//if (timeToChange < App.time)
			//{
				//newBarterCreate();
			//}
			
			var countItem:int = 0;
			for each (var numb:*in barter.items)
			{
				countItem++;
				
			}
			var countOuts:int = 0;
			for each (var numb2:* in barter.outs)
			{
				countOuts++;
			}
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
		}
		
		private function changeBarterItem():void
		{
			if (timeToChange < App.time)
			{
				App.self.setOffTimer(changeBarterItem);
				title.text =TimeConverter.timeToStr(0);
				refresh();
				return;
			}
			title.text = TimeConverter.timeToStr(timeToChange - App.time);
		}
		
		private function refresh(buy:Boolean = false):void
		{
			newBarterCreate(buy);
		}
		
		private function newBarterCreate(buy:Boolean = false):void
		{
			this.settings.target.onRefreshAction(buy, refreshContent);
		}
		
		override public function dispose():void
		{
			super.dispose();
			for each (var item:*in items)
				item.dispose();
		}
		
		private var titleBacking:Bitmap;
		
		
		override public function drawTitle():void
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 35,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x4b7915,			
				borderSize 			: 3,					
				shadowColor			: 0x085c10,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center'
			})
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -57;
			
			ribbon = backingShort(400, 'ribbonGrenn',true,1.3);
			ribbon.x = settings.width / 2 -ribbon.width / 2;			
			ribbon.y = titleLabel.y - 7;
		}
		public var block:Boolean = false;
		public function onExchange(bID:int):void
		{
			if (settings.target)
			{
				settings.target.onExchangeAction(bID, refreshContent);
			}
		}
		
		private var shelfBacking:Bitmap;
		private var shelfBacking2:Bitmap;
		private var background:Bitmap;
		private var icon:Bitmap;
		private var bID:int;
		
		private var titleTime:TextField;
		private var skipPrice:uint;
		private var titleOut:TextField;
		private var titleIn:TextField;
		public var skipBttn:MoneyButton;
		private var back1:Bitmap = new Bitmap();
		private var backText:Shape = new Shape();
		override public function drawBody():void
		{
			
			back1 = backing(settings.width - 66, settings.height - 70, 40, 'paperClear');
			bodyContainer.addChild(back1);
			bodyContainer.addChild(ribbon);
			bodyContainer.addChild(titleLabel);
			back1.x = (settings.width - back1.width) / 2;
			back1.y = (settings.height - back1.height) / 2 - 34;
			
			backText.graphics.beginFill(0xffffff);
		    backText.graphics.drawRect(0, 0, settings.width - 140, 395);
			backText.y = 40;
			backText.x = (settings.width - backText.width) / 2;
		    backText.graphics.endFill();
			backText.filters = [new BlurFilter(40, 0, 2)];
			backText.alpha = .4;
		    bodyContainer.addChild(backText);
			
			var dev:Shape = new Shape();
			dev.graphics.beginFill(0xc0804d);
			dev.graphics.drawRect(0, 0, settings.width - 110, 2);
			dev.graphics.endFill();
			
			var dev1:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev1.bitmapData.draw(dev);
			dev1.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			dev1.x = (settings.width - dev1.width) / 2;
			dev1.y = backText.y - dev1.height;
			bodyContainer.addChild(dev1);
			
			var dev2:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev2.bitmapData.draw(dev);
			dev2.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			//var dev2:Bitmap = Window.backingShort(settings.width - 110, "dividerTop", false);
			dev2.x = (settings.width - dev2.width) / 2;
			dev2.y = backText.y + backText.height;
			bodyContainer.addChild(dev2);
			
			var bubble:Bitmap = new Bitmap(Window.textures.bubbleBarter);
			
			bubble.filters = [new DropShadowFilter(6, 135, 0, .4, 10, 10, 1)];
			bubble.x = -77;
			bubble.y = 75;
			bodyContainer.addChild(bubble);
			
			
			var textSettings:Object = {text: Locale.__e("flash:1382952379793"), color: 0xffffff, fontSize: 30, borderColor: 0x7e3e13, textAlign: 'center', multiline: true, wrap: true, width: (App.lang=='jp')?200:130
			
			}
			
			title = Window.drawText(textSettings.text, {
				text: Locale.__e("flash:1382952379793"), 
				color: 0xffdf34, 
				fontSize: 36, 
				borderColor: 0x7e3e13, 
				textAlign: 'center', 
				multiline: true, 
				wrap: true, 
				width: (App.lang=='jp')?200:130
			
			});
			title.height = title.textHeight + 4;
			
			icon = new Bitmap();
			bodyContainer.addChild(icon);
			bodyContainer.addChild(title);
				
			textSettings.fontSize = 26;
			textSettings.width = 180;
			textSettings.color = 0xf0e6c1;
			titleTime = Window.drawText(Locale.__e('flash:1429711659700'), {
				text		: Locale.__e("flash:1382952379793"), 
				color		: 0xffffff, 
				fontSize	: 30, 
				borderColor	: 0x7e3e13, 
				textAlign	: 'center', 
				multiline	: true, 
				wrap		: true, 
				width		: 320
			
			});
			bodyContainer.addChild(titleTime);
			titleTime.x = (settings.width - titleTime.width) / 2;
			titleTime.y = settings.height - 200;
			
			title.y = titleTime.y + titleTime.textHeight;
			title.x = (settings.width - title.width) / 2;
			
			App.self.setOnTimer(changeBarterItem);
			
			var bttnSettings:Object = {caption: Locale.__e("flash:1382952379751"), width: 100, height: 38, fontSize: 24, scale: 0.8, hasDotes: false}
			
			skipPrice = settings.target.info.boostprice;
			
			bttnSettings['countText'] = skipPrice;
			bttnSettings["bgColor"] = [0xa9d4f6, 0x5d8df1];
			bttnSettings["borderColor"] = [0xffffff, 0xffffff];
			bttnSettings["bevelColor"] = [0xa9d4f6, 0x3868cc];
			bttnSettings["fontColor"] = 0xffffff;
			bttnSettings["fontBorderColor"] = 0x3559ad;
			
			skipBttn = new MoneyButton({
				caption		:Locale.__e('flash:1382952380104'),
				countText	:skipPrice,
				width		:130,
				height		:42,
				fontSize	:22,
				radius		:14,
				countText	:0,
				multiline	:true,
				iconScale	:0.7,
				iconDY		:6,
				countDY		:-4
			});
			skipBttn.tip = function():Object
			{
				return {title: Locale.__e("flash:1429716360253")};
			};
			
			skipBttn.coinsIcon.y -= 6;
			skipBttn.addEventListener(MouseEvent.CLICK, onSkipAction);
			skipBttn.y = title.y + title.textHeight + 6;
			skipBttn.x = (settings.width - skipBttn.width) / 2;
			bodyContainer.addChild(skipBttn);
			var persId:int = 13;
			/*if (settings.target.sid == 1722)
				persId = 21;*/
			switch (settings.target.sid){
				case 1722:
					persId = 21;
					break;
				case 2276:
					persId = 34;
					break;
				case 2315:
					persId = 36;
					break;
				default:
					persId = 13;
					break;
			}
			Load.loading(Config.getQuestIcon('preview', App.data.personages[persId].preview), onLoad);
			exit.y = -10; 
			
			
			drawBttns();
			contentChange();
			
		}
		
		private function onLoad(data:*):void
		{
			icon.bitmapData = data.bitmapData;
			Size.size(icon, 270, 270);
			icon.smoothing = true;
			icon.filters = [new DropShadowFilter(8, 135, 0, .6, 6, 6, 1)];
			icon.x = - 20;
			icon.y = (settings.height - icon.height) / 2 - 105;
		
		}
		
		private function drawBttns():void
		{
			var bttnSettings:Object = {caption: Locale.__e("flash:1393580181245"), fontSize: 30, width: 140, height: 46, hasDotes: false};
				
			if (exchangeBttn && exchangeBttn.parent)
			{
				exchangeBttn.parent.removeChild(exchangeBttn);
			}
			
			exchangeBttn = new Button({caption: Locale.__e("flash:1382952380010"), fontSize: 32, width: 180, hasDotes: false, height: 54});
			exchangeBttn.filters = [new DropShadowFilter(6, 90, 0, .8, 4, 4, 2)];
			exchangeBttn.x = (settings.width - exchangeBttn.width) / 2;
			exchangeBttn.y = settings.height - exchangeBttn.height - 27;
			bodyContainer.addChild(exchangeBttn);
			exchangeBttn.addEventListener(MouseEvent.CLICK, onExchangeClick)
			
			
		}
		public function onStockChange(e:* = null):void
		{
			if (exchangeBttn && !block)
			{
				if (App.user.stock.checkAll(barter.items))
				{
					exchangeBttn.state = Button.NORMAL;
					exchangeBttn.mode = Button.NORMAL;
				}
				else
				{
					exchangeBttn.state = Button.DISABLED;
					exchangeBttn.mode = Button.DISABLED;
				}
			}
		}
		public function refreshContent():void
		{
			bID = settings.target.bID;
			barter = App.data.barter[bID];
			timeToChange = settings.target.bTime + barter.time;
			skipBttn.state = Button.NORMAL;
			contentChange();
			App.self.setOnTimer(changeBarterItem);
			block = false;
			onStockChange();
		}
		
		public var exchangeBttn:Button;
		override public function contentChange():void
		{
			var item:BarterItems;
			for each (item in items)
			{
				bodyContainer.removeChild(item);
				item.dispose();
			}
			
			items = new Vector.<BarterItems>();
			var Y:int = 0;
			var itemNum:int = 0;
			var locked:Boolean = true;
			var textSettings:Object = {text: Locale.__e("flash:1382952379793"), color: 0xffffff, fontSize: 30, borderColor: 0x7e3e13,  textAlign: 'center', multiline: true, wrap: true, width: 260}
			
			titleOut = Window.drawText(App.data.storage[settings.target.sid].text2, textSettings);
			item = new BarterItems(barter.items, this, true);
			items.push(item);
			
			bodyContainer.addChild(item);
			bodyContainer.addChild(titleOut);
			item.y += 247;
			item.x += 185;
			titleOut.y = item.y -titleOut.textHeight - 4;
			titleOut.x = back1.width/2 - 45;
			
			titleIn = Window.drawText(App.data.storage[settings.target.sid].text1, textSettings);
			item = new BarterItems(barter.outs, this, false);
			items.push(item);
			bodyContainer.addChild(item);
			bodyContainer.addChild(titleIn);
			item.x += 185;
			item.y = 80;
			titleIn.y = item.y -titleIn.textHeight - 5;
			titleIn.x = back1.width/2 - 40;
			itemNum++;
			onStockChange();
		}
		
		private function resize():void
		{
			var countItem:int = 0;
			for each (var numb:*in barter.items)
			{
				countItem++;
			}
			var countOuts:int = 0;
			for each (var numb2:*in barter.outs)
			{
				countOuts++;
			}
			settings.width = 160 * Math.max(countItem, countOuts) + 150;
		
		}
		
		override public function close(e:MouseEvent = null):void
		{
			
			if (settings.hasAnimations == true)
			{
				startCloseAnimation();
			}
			else
			{
				dispatchEvent(new WindowEvent("onBeforeClose"));
				dispose();
			}
			App.self.setOffTimer(changeBarterItem);
		}
		
		private function onExchangeClick(e:MouseEvent):void
		{
			if (exchangeBttn.mode == Button.DISABLED)
				return;
			
			exchangeBttn.state = Button.DISABLED;
			block = true;
			onExchange(bID);
			
			var id:int = 0;
			
			for each (var _item:BarterItems in items)
			{
				for each (var _item2:BarterItem in _item.items)
				{
					_item2.number = id;					
					_item2.cash2();
					id++;
					
				}				
			}
			
			contentChange();
		}
		
		private function onSkipAction(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			
			if (!App.user.stock.check(Stock.FANT, skipPrice))
				return;
				
			e.currentTarget.mode = Button.DISABLED;
			newBarterCreate(true);
		}
	
	}
}

import buttons.Button;
import buttons.MoneyButton;
import buttons.MoneySmallButton;
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.BarterWindow;
import wins.Window;
import wins.BonusList;

internal class BarterItems extends Sprite
{
	
	public var barter:Object = {};
	public var background:Bitmap;
	
	public var arrow:Bitmap;
	public var window:*;
	public var items:Vector.<BarterItem> = new Vector.<BarterItem>();
	public var bonusList:BonusList;
	public var bID:int;
	public var item:Object;
	private var _modeChange:Boolean = true;
	
	private var sID:int;
	private var count:int;
	static private var IN:Boolean = false;
	static private var OUT:Boolean = true;
	public var mode:Boolean = false;
	
	public function BarterItems(obj:Object, window:*, mode:Boolean = true)
	{
		this.barter = barter;
		this.window = window;
		this.bID = bID;
		this.mode = mode;	
		
		item = obj;
		
		//sID = item.out;
		//count = item.count;
		
		//background = Window.backing(300, 190, 40, 'shopBackingSmall1');
		background = new Bitmap(new BitmapData(300, 190));
		//addChild(background);
		
		//arrow = new Bitmap(Window.textures.arrow);
		createItems();
		//arrow.x = 160;
		//arrow.y = 20;
		//addChild(arrow);
		
		if (window.find.length > 0)
		{
			for (var cellID:*in item.items)
			{
				if (window.find.indexOf(int(cellID)) >= 0)
				{
					window.exchangeBttn.showGlowing();
					window.find.length = 0;
				}
			}
		}
	}
	
	public function set modeChange(value:Boolean):void
	{
		_modeChange = value;
		if (value == true)
		{
			//arrow.alpha = 1;
			window.exchangeBttn.state = Button.NORMAL;
			window.exchangeBttn.mode = Button.NORMAL;
		}
		else
		{
			//arrow.alpha = 0.5;
			window.exchangeBttn.state = Button.DISABLED;
			window.exchangeBttn.mode = Button.DISABLED;
		}
	}
	
	public function dispose():void
	{
		for each (var item:BarterItem in items)
		{
			item.dispose();
		}
	}
	
	public var cont:Sprite;
	
	public function createItems():void
	{
		var i:int = 0;
		for (var itm:*in item)
		{
			var barterItem:BarterItem = new BarterItem({sID: int(itm), count: item[itm]}, this, mode);
			items.push(barterItem);
			barterItem.x = 140 * i + 30;
			barterItem.y = 0;
			i++;
			addChild(barterItem);
				//barterItem.check();
				//barterItem.modeChanges();
			
			/*cont = new Sprite();
			   cont.x = 300;
			   var bg:Bitmap = Window.backing(300, 128, 10, "itemBacking");
			 cont.addChild(bg);*/
		}
		
		if (mode)
		{
			
		}
		else
		{
			
		}
	/*var i:int = 0;
	   for (var itm:* in  item)
	   {
	   var barterItem:BarterItem = new BarterItem({sID: int(itm), count: count}, this, BarterItem.IN);
	   items.push(barterItem);
	   barterItem.x = 140 * i;
	   barterItem.y = 0;
	   i++;
	   addChild(barterItem);
	   barterItem.check();
	   barterItem.modeChanges();
	
	   cont = new Sprite();
	   cont.x = 300;
	   var bg:Bitmap = Window.backing(300, 128, 10, "itemBacking");
	   cont.addChild(bg);
	
	   i = 0;
	   var icnt:int = 0;
	   for (var _sID:*in item.items)
	   {
	   barterItem = new BarterItem({sID: _sID, count: item.items[_sID]}, this, BarterItem.OUT);
	   items.push(barterItem);
	   barterItem.x = 140 * i;
	   barterItem.y = 0;
	   i++;
	   icnt++;
	   cont.addChild(barterItem);
	   barterItem.check();
	   barterItem.modeChanges();
	   }
	   addChild(cont);
	   if (icnt == 1)
	   {
	   barterItem.x += (bg.width - barterItem.width) / 2;
	 }*/
	}

}

internal class BarterItem extends LayerX
{
	
	public static const IN:Boolean = false;
	public static const OUT:Boolean = true;
	
	public var background:Bitmap;
	public var background2:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var material:Object;
	public var sID:int;
	public var buyBttn:MoneyButton;
	public var number:int;
	
	public var countOnStock:TextField;
	public var window:*;
	
	private var mode:Boolean;
	private var preloader:Preloader = new Preloader();
	private var count:int;
	private var colorCount:int;
	private var findBttn:Button;
	
	private static var outsArray:Array = [];	
	
	public function BarterItem(itm:Object, window:*, mode:Boolean = IN)
	{
		//return
		this.sID = itm.sID;
		this.count = itm.count;
		this.window = window;
		this.mode = mode;
		
		for (var i:* in BarterWindow.barter.outs) {
			outsArray.push( {sID: i, count: BarterWindow.barter.outs[i]} );
		}
		
		background = Window.backing(128, 128, 10, "itemBacking");
		//background2 = Window.backing(128, 128, 10, "itemBacking");
		//collectionItemBacking
		/*if (mode == IN)
		{*/
		addChild(background)
		/*}
		else
		{
			addChild(background2);
			background2.alpha = .9;
		}*/
		
		background.filters = [new DropShadowFilter(2, 45, 0, .6, 4, 4, 1)];
		bitmap = new Bitmap(null, "auto", true);
		
		addChild(bitmap);
		
		material = App.data.storage[sID];
		
		title = Window.drawText(material.title, {color: 0x7f4015, border: false , fontSize: 26, multiline: true, textAlign: "center", textLeading:-10, wrap: true, width: background.width - 10});
		
		title.x = background.x + (background.width - title.width) / 2;
		title.y = -1;
		addChild(title);
		
		if (mode == OUT)
			drawButtons();
		
		addChild(preloader);
		preloader.x = (background.width) / 2;
		preloader.y = (background.height) / 2;
		
		Load.loading(Config.getIcon(material.type, material.view), onLoad);
		drawCount();
		
		App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
		
		function shuffle(a:*, b:*):int
		{
			var num:int = Math.round(Math.random() * 2) - 1;
			return num;
		}
		
		tip = function():Object
		{
			return {title: material.title, text: material.description}
		}
		onStockChange();
	}
	
	private var price:int;
	private var neededCount:int;
	
	private function onStockChange(e:* = null):void
	{
		if ( buyBttn && App.user.stock.check(sID, count))
		{
			buyBttn.visible = false;
		}
		drawCount();
	}
	private function drawButtons():void
	{
		if (App.data.storage[sID].mtype == 3 || App.data.storage[sID].mtype == 4 || App.data.storage[sID].mtype == 6 || App.data.storage[sID].mtype == 8)
			return;
		var bttnSettings:Object = {caption: Locale.__e("flash:1382952379751"), width: 100, height: 38, fontSize: 24, scale: 0.8, hasDotes: false}
		
		neededCount = count - App.user.stock.count(sID);
		price = neededCount * App.data.storage[sID].price[Stock.FANT];
		
		//bttnSettings['type'] = 'real';
		//bttnSettings['caption'] = 'Докупить';
		bttnSettings['countText'] = price;
		bttnSettings['caption'] = Locale.__e("flash:1382952379751");
		bttnSettings['fontCountColor'] = 0xffffff;
		bttnSettings["bgColor"] = [0xa9d4f6, 0x5d8df1];
		bttnSettings["borderColor"] = [0xd6f1ff, 0x4b6db2];
		bttnSettings["borderSize"] = 3;
		bttnSettings["bevelColor"] = [0xa9d4f6, 0x3868cc];
		bttnSettings["fontColor"] = 0xffffff;
		bttnSettings["fontBorderColor"] = 0x3559ad;
		bttnSettings["fontCountBorder"] = 0x104f7d;
		//bttnSettings['greenDotes'] = false;
		
		buyBttn = new MoneyButton({
			caption		:Locale.__e('flash:1382952379751'),
			countText	:price,
			width		:121,
			height		:42,
			fontSize	:22,
			radius		:16,
			countText	:0,
			multiline	:true,
			iconScale	:0.7,
			iconDY		:6,
			countDY		:-4
		});
		buyBttn.tip = function():Object
		{
			return {title: Locale.__e("flash:1382952379751") /*,
				 text:Locale.__e("flash:1410432789818")*/};
		};
		buyBttn.coinsIcon.y -= 6;
		buyBttn.addEventListener(MouseEvent.CLICK, onBuyAction);
		buyBttn.y = background.y + background.height - buyBttn.height / 2 + 30;
		buyBttn.x = (background.width - buyBttn.width) / 2;
		addChild(buyBttn);
		//skipPrice = 2 * App.data.storage[347].price[Stock.FANT];
		
	}
	
	private function onFindAction(e:MouseEvent):void
	{
		window.settings.target.work(sID);
		window.close();
	}
	
	private function onBuyAction(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED)
			return;
		
		if (!App.user.stock.check(Stock.FANT, price))
			return;
			
		e.currentTarget.mode = Button.DISABLED;
		
		if (!countOnStock)
			drawCount(true);
		
		App.user.stock.buy(sID, neededCount, function():void
		{
			
			var item:BonusItem = new BonusItem(sID, 1);
			var point:Point = Window.localToGlobal(buyBttn);
			item.cashMove(point, App.self.windowContainer);
			
			Hints.plus(sID, neededCount, point, true, App.self.tipsContainer);
			Hints.minus(Stock.FANT, price, point, false, App.self.tipsContainer);
			
			//window.window.contentChange();
		});
	}
	
	public function cash():void
	{
		if (mode == IN)
			return;
		
		//BarterWindow.barter;
		
		//for (var i:* in BarterWindow.barter.outs) 
		//{
			//var item:BonusItem = new BonusItem(i, BarterWindow.barter.outs[i]);
			//var point:Point = Window.localToGlobal(bitmap);
			//item.cashMove(point, App.self.windowContainer);
			////Hints.plus(i, BarterWindow.barter.outs[i], point, true, App.self.tipsContainer);
		//}
		
		//for (var j:* in BarterWindow.barter.outs) 
		//{
			//Hints.plus(j, BarterWindow.barter.outs[j], point, true, App.self.tipsContainer);
		//}
		
		var item:BonusItem = new BonusItem(sID, count);
		var point:Point = Window.localToGlobal(bitmap);
		item.cashMove(point, App.self.windowContainer);
		Hints.plus(sID, count, point, true, App.self.tipsContainer);
	}
	
	public function cash2():void
	{
		if (mode != IN)
			return;
			
		//var id:int = outsArray[this.number].sID,
		//countQ:int = outsArray[this.number].count;
		
		var item:BonusItem = new BonusItem(sID, count);
		var point:Point = Window.localToGlobal(this);
		item.cashMove(point, App.self.windowContainer);
		Hints.plus(sID, count, point, true, App.self.tipsContainer);
	}
	
	public var searchBttn:MoneyButton
	
	public function modeChanges():void
	{
		if (mode == OUT)
		{
			//не отображать кнопки
			if (buyBttn)
				buyBttn.visible = false;
		}
	}
	
	private function onSearchBttn(e:MouseEvent):void
	{
		window.close();
		if (window.settings.onSearch != null)
			window.settings.onSearch(window.mode, sID);
	}
	
	private function onLoad(data:Bitmap):void
	{
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		bitmap.scaleX = bitmap.scaleY = 0.6;
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2;
	}
	private var counterSprite:LayerX;
	public function drawCount(ignore:Boolean = false):void
	{
		/*if (count == 0 && !ignore)
		 colorCount = 0xff816e;*/
		if (counterSprite && counterSprite.parent)
			counterSprite.parent.removeChild(counterSprite);
		if (countOnStock && countOnStock.parent)
			countOnStock.parent.removeChild(countOnStock);
			
		counterSprite = new LayerX();
		counterSprite.tip = function():Object
		{
			return {title: "", text: Locale.__e("flash:1382952380305")};
		};
		
		var tSett:Object = textSettings[int(mode)];
		if (mode == OUT)
		{
			if (!App.user.stock.check(sID, count))
			{
				tSett.color = 0xff816e;
			}
			else
			{
				tSett.color = 0xffffff;
			}
			countOnStock = Window.drawText(App.user.stock.count(sID)+'/'+ count, tSett);
		}else 
		{
		countOnStock = Window.drawText('x' + count, tSett);	
		}
		counterSprite.x = background.width - counterSprite.width - 30;
		counterSprite.y = 129;
		addChild(counterSprite);
		
		addChild(countOnStock);
		countOnStock.x = counterSprite.x + (counterSprite.width - countOnStock.width) / 2 - 5;
		countOnStock.y = counterSprite.y - 40;
	}
	
	private var textSettings:Object = {1: {color: 0xffffff, borderColor: 0x6e411e, fontSize: 28, autoSize: "left", shadowColor: 0x6e411e, shadowSize: 1}, 0: {color: 0xFFFFFF, borderColor: 0x6e411e, fontSize: 28, autoSize: "left", shadowColor: 0x41332b, shadowSize: 2}}
	//private var skipPrice:uint = 2;
	
	public function check():void
	{
		if (countOnStock)
		{
			'x' + String(count);
		}
		else if (countOnStock)
		{
			countOnStock.text = 'x' + String(count);
		}
	/*if (buyBttn != null)
	   {
	   buyBttn.x = (background.width - buyBttn.width) / 2;
	   buyBttn.y = background.height - buyBttn.height + 17;
	 }*/
	}
	
	private function onWishlistEvent(e:MouseEvent):void
	{
		App.wl.show(sID, e);
	}
	
	public function dispose():void
	{
		//
	}
}