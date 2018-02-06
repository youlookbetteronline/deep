package wins
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	import wins.elements.SearchCollectionPanel;

	public class CollectionWindow extends Window
	{
		public static const COLLECTIONS:int = 0;
		public static const SELECT_COLLECTION:int = 1;
		public static const SELECT_ELEMENT:int = 2;
		public var plankBmap:Bitmap = new Bitmap();
		
		public static var history:int = 0;
		public var items:Vector.<CollectionItems> = new Vector.<CollectionItems>();
		public var mode:uint;
		private var separator2:Sprite;
		private var _searchPanel:SearchCollectionPanel
		private var _allContent:Array = [];
		//public var exchangeBttn:Button
		
		public function CollectionWindow(settings:Object = null):void
		{
			if (settings == null) 
			{
				settings = new Object();
			}
			
			mode = settings.mode || COLLECTIONS;
			
			settings["title"] = Locale.__e("flash:1382952379800");
			settings["width"] = 810;
			settings["height"] = 614/*594*/;// 636;
			settings['background'] = 'shopBackingNew';
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 2;
			settings["page"] = history;
			settings['content'] = [];
			
			super(settings);
		}
		
		override public function createPaginator():void
		{
			super.createPaginator();
			updateContent();
			findTargetPage(settings);
			contentChange();
		}
		
		private function findTargetPage(settings:Object):void 
		{
				for (var i:* in settings.content) 
				{
					
					var ssid:int = settings.content[i].sID;
					if (settings.find != null && settings.find.indexOf(ssid) != -1) {
						
							paginator.page = int(int(i) / settings.itemsOnPage) ;
							
							paginator.startCount =  int(int(i) / settings.itemsOnPage);
							
							if((int(i)+settings.itemsOnPage) < settings.content.length)
								paginator.finishCount =  int(i) + settings.itemsOnPage;
							else
								paginator.finishCount = settings.content.length;
							
							settings.page = paginator.page;
							history = settings.page;
						return;
					}
				}
		}
		
		override public function dispose():void 
		{
			
			super.dispose();
			
			for each(var item:* in items)	item.dispose();
		}
		
		public function updateContent():void 
		{
			settings['content'] = [];
			for (var sID:* in App.data.storage) {
				var item:Object = App.data.storage[sID];
				item['sID'] = sID;
				if (item.sID == 2596)
					trace();
				if (App.data.storage[sID].visible == 0 || (App.data.updatelist[App.social].hasOwnProperty(User.getUpdate(sID)) 
				&& App.data.updates[User.getUpdate(sID)].temporary == 1 && ((App.data.updatelist[App.social][(User.getUpdate(sID))] 
				+ App.data.updates[User.getUpdate(sID)].duration * 3600) < App.time)))
					continue;
				
				if (item.type == 'Collection' && item.visible) {
					settings.content.push(item);
					
					var full:Boolean = true;
					for each(var mID:int in item.materials) {
						if (App.user.stock.count(mID) == 0) {
							full = false;
							break;
						}
					}
					if (full && item.order > 0) {
						item.order *= -1;
					}else if (!full && item.order < 0) {
						item.order *= -1;
					}
				}
			}
			settings.content.sortOn('order', Array.NUMERIC);
			allContent = settings.content;
			paginator.itemsCount = settings.content.length;
			paginator.update();
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			var arrTop:uint = 215;
			paginator.arrowLeft.y = paginator.arrowRight.y = arrTop;
			paginator.arrowLeft.x += 50;
			paginator.arrowRight.x += 15;
			
			//paginator.y += 52;
			paginator.x = int((settings.width - paginator.width)/2 - 5);
			paginator.y = int(settings.height - paginator.height +3);
		}
		
		public function createSeparator(top:uint=0):Sprite{
				var bw:int = settings.width*0.8;
				
				var sepTop:int = top;
				var sepItemWidth:int = -60;
				var sepWidth:int = 340;
				var separator:Bitmap = Window.backingShort(sepWidth, 'dividerLight', false);
				var separator2:Bitmap = Window.backingShort(sepWidth, 'dividerLight', false);
				separator.y = separator2.y = sepTop;
				separator.x = 55;
				separator2.scaleX = -1;
				separator2.x = separator.x + separator.width * 2;
				var sep:Sprite = new Sprite()
				sep.addChild(separator);
				sep.addChild(separator2);
				sep.alpha = 0.5;
				return sep;
		}
		
		override public function drawBody():void {
			
			//bodyContainer.addChild(createSeparator(220));
			//separator2 = createSeparator(470);
			//bodyContainer.addChild(separator2);
			paginator.page = settings.page;
			paginator.update();
			titleLabel.y -= 10;
			
			var roofBmap:Bitmap = backingShort(settings.width + 40, 'shopRoof');
			roofBmap.x = -20;
			roofBmap.y = -120;
			bodyContainer.addChild(roofBmap);
			
			var bmd1:BitmapData = new BitmapData(100, roofBmap.height, true);
			//var bmd2:BitmapData = new BitmapData(80, 40, false, 0x0000CC44);

			var rect:Rectangle = new Rectangle(0, 0, 100, roofBmap.height);
			var pt:Point = new Point(0, 0);
			bmd1.copyPixels(roofBmap.bitmapData, new Rectangle(roofBmap.width/2 - 145, 0, 100, roofBmap.height), new Point());

			var copyRoof:Bitmap =  new Bitmap(bmd1);
			/*var bm1:Bitmap = new Bitmap(bmd1);
			this.addChild(bm1);
			var copyRoof1:Bitmap = new Bitmap(copyRoof.bitmapData);*/
			copyRoof.x = roofBmap.x + roofBmap.width / 2 - 50;
			copyRoof.y = roofBmap.y;
			
			bodyContainer.addChild(copyRoof);
			
			var titleBackingBmap:Bitmap = backingShort(270, 'shopTitleBacking');
			
			//roofBmap.scaleX = roofBmap.scaleY = 1.05;
			titleBackingBmap.x = settings.width/2 -titleBackingBmap.width/2;
			titleBackingBmap.y = -100;
			bodyContainer.addChild(titleBackingBmap);
			
			plankBmap = backingShort(settings.width - 90, 'shopPlank');
			
			//roofBmap.scaleX = roofBmap.scaleY = 1.05;
			plankBmap.x = 45;
			plankBmap.y = 295;
			layer.addChild(plankBmap);
			
			var downPlankBmap:Bitmap = backingShort(300, 'shopPlankDown');
			downPlankBmap.x = settings.width/2 -downPlankBmap.width/2;
			downPlankBmap.y = settings.height - 55;
			layer.addChild(downPlankBmap);
			
			/*exit.x -= 23;
			exit.y += 39;
			titleLabel.y += 5;
			*/
			contentChange();
			drawBttns();
			
			this.y += 5;
			fader.y -= 5;
			
			/*drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -30, true, true);
			drawMirrowObjs('storageWoodenDec', -3, settings.width+3, settings.height - 110);
			drawMirrowObjs('storageWoodenDec', -11, settings.width + 11, +40,false,false,false,1,-1);*/
			exit.y += 5;
			exit.x -= 15;
			//drawSearchPanel();
		}
		
		private function onStopFinding():void
		{
			updateContent();
			contentChange();
		}
		
		private function drawSearchPanel():void 
		{
			_searchPanel = new SearchCollectionPanel({
				win:this, 
				callback:showFinded,
				stop:onStopFinding,
				hasIcon:false,
				caption:Locale.__e('flash:1439895194037')
			});
			bodyContainer.addChild(_searchPanel);
			_searchPanel.y = settings.height - 105;
			_searchPanel.x = settings.width - 250;
		}
		
		private function showFinded(content:Array):void
		{
			settings.content = content;
			paginator.itemsCount = content.length;
			paginator.update();
			
			contentChange();
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: 42,				
				textLeading	 		: settings.textLeading,
				borderColor 		: 0x451c00,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: 0x451c00,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
				//border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -9;
			headerContainer.addChild(titleLabel);
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.mouseEnabled = false;
		}
		
		private function drawBttns():void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1393580181245"),
				fontSize:30,
				width:140,
				height:46,
				hasDotes:false
			};
		}
		
		private var findBoolean:Boolean = false;
		
		override public function contentChange():void 
		{
			var item:CollectionItems;
			for each(item in items) {
				bodyContainer.removeChild(item);
				item.dispose();
			}
			
			items = new Vector.<CollectionItems>();
			
			updateContent();
			
			//if (!findBoolean)
			//{
				//findBoolean	= true;			
				//
			//}
			
			var itemNum:int = 0;
			//separator2.visible = (paginator.finishCount-paginator.startCount == 1)?false:true;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				item = new CollectionItems(settings.content[i], this);
				
				bodyContainer.addChild(item);
				item.x = 6 + (settings.width - item.width) / 2;
				item.y = 9 + (item.height + 4) * itemNum;
				items.push(item);
				itemNum++;
				for (var sID:String in settings.find) 
				
				
				if (item.sID == settings.find[sID]) 
				{
					item.startGlowing();
					setTimeout(item.hideGlowing, 5000);
				}
			}
			
			var marginSep:int = 40;
			
			//var separator:Bitmap = Window.backingShort(item.width - marginSep * 2, 'divider');
			//separator.alpha = 0.8;
			//bodyContainer.addChild(separator);
			//separator.x = item.x + marginSep;
			//separator.y = 260;
			
			settings.page = paginator.page;
			history = settings.page;
		}
		
		public static function completed():uint
		{
			var counter:int = 0;
			
			for (var sID:String in App.data.storage) {
				var item:Object = App.data.storage[sID];
				if (item.visible == 0) continue;
				
				if (item.type == 'Collection') {
					var min:int = -1;
					for each(var mID:int in item.materials) {
						if (min == -1) {
							min = App.user.stock.count(mID);
						}else{
							min = Math.min(min, App.user.stock.count(mID));
						}
						if(min == 0){
							break;
						}
					}
					if(min != -1){
						counter += min;
					}
				}
			}
				
			return counter;
		}
		
		public function get allContent():Array 
		{
			return _allContent;
		}
		
		public function set allContent(value:Array):void 
		{
			_allContent = value;
		}
		
	}

}


import api.ExternalApi;
import buttons.Button;
import buttons.ImageButton;
import buttons.MoneyButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.ShopWindow;
import wins.Window;
import wins.CollectionBonusList;
import wins.CollectionWindow;

internal class CollectionItems extends LayerX {
	
	public var collection:Object;
	public var background:Bitmap;
	public var title:TextField;
	public var collectionCount:TextField = new TextField();
	public var exchangeBttn:Button;
	public var arrow:Bitmap;
	public var bank:Bitmap;
	public var window:*;
	public var items:Vector.<CollectionItem> = new Vector.<CollectionItem>();
	public var bonusList:CollectionBonusList;
	public var separator:Sprite;
	public var sID:String;
	public var minCount:int = 100000000;
	public var currentCount:int;
	public var minusButton:ImageButton = new ImageButton(Window.textures.addBttnBlueGrey);
	public var plusButton:ImageButton = new ImageButton(Window.textures.addBttnGreen);;
	
	private var _modeChange:Boolean = true;
	
	private var bSet:Object = {
			caption:"",
			fontSize:22,
			width:126,
			height:34,
			borderColor:[0xaff1f9, 0x005387],
			bgColor:[0x70c6fe, 0x765ad7],
			fontColor:0x453b5f,
			fontBorderColor:0xe3eff1
		}

	public function CollectionItems(collection:Object, window:*) {
		
		this.collection = collection;
		this.window = window;
		this.sID = collection.sID;
		background = Window.backing2(810, 220, 40, 'giftBeckingCollection', 'giftBeckingCollectio');
		//addChild(background);
		//separator = createSeparator(background.height + 16);
		//addChild(separator);
		
		title = Window.drawText(collection.title, {
			color:0xffffff,
			borderColor:0x451c00,
			fontSize:30,
			borderSize:3,
			autoSize:'left'
		});
		
		title.x = (background.width - title.width) / 2 - 70;
		title.y = 2;
		addChild(title);
		
		minusButton.addEventListener(MouseEvent.CLICK, onMinusBttn);
		plusButton.addEventListener(MouseEvent.CLICK, onPlusBttn);
		
		bank = new Bitmap(Window.textures.decBank);
		addChild(bank);
		
		createItems();
		
		currentCount = minCount;
		
		createBonus();
		
		drawCollectionCount();
		drawCountButtons();

		arrow = new Bitmap(Window.textures.checkMark);
		arrow.scaleX = arrow.scaleX = 0.8;
		arrow.smoothing = true;
		arrow.x = -15; arrow.y = 60;
		addChild(arrow);
		
		if (App.user.stock.checkCollection(collection.sID)) {
			modeChange = true;
		} else {
			modeChange = false;
		}
		
		if (window.mode == CollectionWindow.SELECT_COLLECTION || window.mode == CollectionWindow.SELECT_ELEMENT) {
			bonusList.visible = false;
			exchangeBttn.visible = false;
			collectionCount.visible = false;
			if(plusButton){
				plusButton.visible = false;
				minusButton.visible = false;
			}
		}
	}
	
	private var searchBttn:Button;
	private function set modeChange(value:Boolean):void
	{
		_modeChange = value;
		if (value == true) {
			exchangeBttn.visible = true;
			collectionCount.visible = true;
			arrow.visible = true;
			if(plusButton){
				plusButton.visible = true;
				minusButton.visible = true;
			}
		} else {
			exchangeBttn.visible = false;
			collectionCount.visible = false;
			arrow.visible = false;
			if(plusButton){
				plusButton.visible = false;
				minusButton.visible = false;
			}
		}
		
		if (window.mode == CollectionWindow.SELECT_COLLECTION) {
			exchangeBttn.visible = false;
			collectionCount.visible = false;
			bonusList.visible = false;
			if(plusButton){
				plusButton.visible = false;
				minusButton.visible = false;
			}
			
			searchBttn = new Button({
				width:178,
				height:44,
				fontSize:25,
				caption:Locale.__e("flash:1382952380011")
			});
			addChild(searchBttn);
			searchBttn.x = (background.width - searchBttn.width) / 2;
			searchBttn.y = 195;
			searchBttn.addEventListener(MouseEvent.CLICK, onSearchBttn);
		}
	}
	
	private function onSearchBttn(e:MouseEvent):void 
	{
		window.close();
		if (window.settings.onSearch != null) 
			window.settings.onSearch(window.mode, collection.sID);
	}

	public function dispose():void 
	{
		exchangeBttn.removeEventListener(MouseEvent.CLICK, onExchangeEvent);
		
		for each(var item:CollectionItem in items) {
			item.dispose();
		}
	}
	
	public var rewObject:Object = new Object();
	public function createBonus():void 
	{
		if (bonusList && bonusList.parent)
			bonusList.parent.removeChild(bonusList);
			
		rewObject = new Object();
		var counter:int = currentCount;
		if (counter < 1)
			counter = 1;
		for (var rewItm:* in collection.reward)
		{
			rewObject[rewItm] = collection.reward[rewItm] * counter;
		}
		bonusList = new CollectionBonusList(rewObject);
		addChild(bonusList);
		
		bonusList.x = (background.width - bonusList.width) / 2 - 70;
		bonusList.y = title.y + 170;
		
		bank.x = bonusList.x - bank.width - 50;
		bank.y = bonusList.y + 8;
		
		minusButton.x = bank.x - 47;
		minusButton.y = bank.y + 10;
		
		plusButton.x = bank.x + bank.width + 0;
		plusButton.y = bank.y + 10;
		
		collectionCount.x = bank.x + bank.width / 2 - collectionCount.width / 2 - 3;
		collectionCount.y = bank.y + bank.height / 2 - collectionCount.height / 2 + 7;
	}
	
	public function createItems():void 
	{
		var i:Number = 0;		
		for each(var sID:uint in collection.materials) 
		{
			var item:CollectionItem = new CollectionItem(sID, window);
			items.push(item);
			item.y = title.y + title.height - 6;
			item.x = 3 + item.width * i;
			i+=1.02;
			addChild(item);
			if(!App.user.stock.data[item.sID]){
				minCount = 0;
			}
			if (App.user.stock.data[item.sID] < minCount)
				minCount = App.user.stock.data[item.sID];
			item.check();
			item.modeChanges();
			
		}
	}
	
	public function drawCountButtons():void
	{
		if (minusButton && minusButton.parent)
			minusButton.parent.removeChild(minusButton);
			
		if (plusButton && plusButton.parent)
			plusButton.parent.removeChild(plusButton);
		addChild(minusButton);
		minusButton.x = bank.x - 47;
		minusButton.y = bank.y + 10;
		addChild(plusButton);
		plusButton.x = bank.x + bank.width + 0;
		plusButton.y = bank.y + 10;
	}
	
	public function drawCollectionCount():void
	{
		if(collectionCount.parent)
			collectionCount.parent.removeChild(collectionCount);
		
		collectionCount = Window.drawText("" + currentCount, {
			color:0xffffff,
			borderColor:0x7e3e14,
			fontSize:30,
			borderSize:4,
			autoSize:'center'
		});
		
		collectionCount.x = bank.x + bank.width / 2 - collectionCount.width / 2 - 3;
		collectionCount.y = bank.y + bank.height / 2 - collectionCount.height / 2 + 7;
		addChild(collectionCount);
		
		if(exchangeBttn)
			removeChild(exchangeBttn);
			
		exchangeBttn = new Button( {
			caption:Locale.__e("flash:1382952380010") + " x" + currentCount,
			fontSize:25,
			width:140,
			hasDotes:false,
			height:40,
			borderColor:[0xf8f2bd, 0x836a07],
			bgColor:[0xfdd349, 0xf6ac25]
		});
		exchangeBttn.x = background.width - exchangeBttn.width*2 - 10;
		exchangeBttn.y = background.height - exchangeBttn.height / 2 - 0;
		
		addChild(exchangeBttn);
		
		createBonus();
		
		exchangeBttn.addEventListener(MouseEvent.CLICK, onExchangeEvent);
	}
	
	private function onMinusBttn(e:MouseEvent):void 
	{
		if (collectionCount.visible == false)
			return;
			
		if(currentCount > 1)
			currentCount--;
			
		drawCollectionCount();
	}
	
	private function onPlusBttn(e:MouseEvent):void 
	{
		if (collectionCount.visible == false)
			return;
		
		if(currentCount < minCount)
			currentCount++;
			
		drawCollectionCount();
	}
	
	private function onExchangeEvent(e:MouseEvent):void 
	{
		exchangeBttn.visible = false;
		collectionCount.visible = false;
		
		if (plusButton)
		{
			plusButton.visible = false;
			minusButton.visible = false;
		}
		bonusList.take(currentCount);
		
		App.user.stock.exchange(collection.sID, onExchangeResponse, currentCount);
	}
	
	private function onExchangeResponse():void 
	{
		exchangeBttn.state = Button.NORMAL;
		
		for each(var item:CollectionItem in items) 
		{
			item.check();
		}
		
		if (App.user.stock.checkCollection(collection.sID)) 
		{
			modeChange = true;
		}else {
			modeChange = false;
		}
		
		App.ui.rightPanel.update();
		
		App.ui.bottomPanel.updateCollCounter();
		
		window.contentChange();
	}
}

import wins.GiftWindow;

internal class CollectionItem extends LayerX {
	
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var material:Object;
	public var sID:int;
	public var giftBttn:ImageButton;
	public var wishlistBttn:ImageButton;
	public var countOnStock:TextField;
	public var window:*;
	
	private var preloader:Preloader = new Preloader();
		
	public function CollectionItem(sID:int, window:*) 
	{
		this.sID = sID;
		this.window = window;
		
		background = Window.backing(130, 130, 10, "itemBacking");
		addChild(background);
		
		bitmap = new Bitmap(null, "auto", true);
		addChild(bitmap);
		
		material = App.data.storage[sID];
		
		title = Window.drawText(material.title, {
			color:0x814f31,
			borderColor:0xfaf9ec,
			fontSize:17,
			multiline:true,
			textAlign:"center",
			wrap:true,
			width:background.width - 20
		});
		
		title.x = 10;
		title.y = 10;
		addChild(title);
		
		giftBttn = new ImageButton(Window.textures.giftBttn, { scaleX:1, scaleY:1 } );
		giftBttn.tip = function():Object { 
			return {
				title:Locale.__e("flash:1382952380012")
			};
		};
		
		wishlistBttn = new ImageButton(Window.textures.wishlistBttn);
		wishlistBttn.tip = function():Object { 
			return {
				title:Locale.__e("flash:1382952380013")
			};
		};
		
		if (App.social != 'FB')
		{
			addChild(giftBttn);
			addChild(wishlistBttn);
		}
		
		wishlistBttn.addEventListener(MouseEvent.CLICK, onWishlistEvent);
		giftBttn.addEventListener(MouseEvent.CLICK, onGiftBttnEvent);
		
		
		addChild(preloader);
		preloader.x = (background.width) / 2;
		preloader.y = (background.height) / 2;
		
		Load.loading(Config.getIcon('Material', material.view), onLoad);
		
		drawCount();

		function shuffle(a:*, b:*):int 
		{
			var num : int = Math.round(Math.random()*2)-1;
			return num;
		}
	
		var cID:int = material['collection'];
		var places:Array = [];
		if (App.data.collectionIndex[cID] != undefined) {
			for each(var id:* in App.data.collectionIndex[cID]){
				places.push(id);
			}
			places = places.sort(shuffle);
		}
		
		tip = function():Object 
		{
			return {
				title:material['title'],
				text:App.data.storage[material.collection].description
			}
		}
	}
	
	public var searchBttn:MoneyButton
	public function modeChanges():void
	{
		if (window.mode == CollectionWindow.SELECT_COLLECTION) {
			wishlistBttn.x = (background.width - wishlistBttn.width) / 2;
			giftBttn.visible = false;
		}
		
		if (window.mode == CollectionWindow.SELECT_ELEMENT)
		{
			wishlistBttn.x = (background.width - wishlistBttn.width) / 2;
			giftBttn.visible = false;
			
			searchBttn = new MoneyButton( {
					caption		:Locale.__e('flash:1382952380015'),
					width		:121,
					height		:37,	
					fontSize	:18,
					countText	:material.price[Stock.FANT],
					multiline	:true
			});
			addChild(searchBttn);
			searchBttn.x = (background.width - searchBttn.width) / 2;
			searchBttn.y = background.height + 10;
			
			searchBttn.addEventListener(MouseEvent.CLICK, onSearchBttn)
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
		Size.size(bitmap, 70, 70);
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2;
		
	}
	
	public function drawCount():void
	{
		var count:int = App.user.stock.count(sID);
		if (count == 0) return;
		
		var counterSprite:LayerX = new LayerX();
		counterSprite.tip = function():Object { 
			return {
				title:Locale.__e("flash:1382952380305")
			};
		};
		
		var countOnStock:TextField = Window.drawText('x' + count || "", {
			color:0xffffff,
			borderColor:0x7e3e14,  
			fontSize:26,
			autoSize:"left"
		});
		
		var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
		
		addChild(counterSprite);
		counterSprite.x = background.width - counterSprite.width - 33;
		counterSprite.y = 122;
		
		addChild(countOnStock);
		countOnStock.x = background.x + background.width - countOnStock.width - 5;
		countOnStock.y = counterSprite.y - 46;
	}
	
	public function check():void
	{
		wishlistBttn.y = background.height - wishlistBttn.height + 13;
		
		var count:uint = App.user.stock.count(sID);
		if (count == 0) {  
			bitmap.alpha = 0.4;
			giftBttn.visible = false;
			wishlistBttn.x = (background.width - wishlistBttn.width) / 2;
			
			if(countOnStock)
				countOnStock.text = "0";
		}else {
			bitmap.alpha = 1;
			giftBttn.visible = true;
			wishlistBttn.x = (background.width - (giftBttn.width + wishlistBttn.width)) / 2;
			giftBttn.y = wishlistBttn.y - 2;
			
			giftBttn.x = wishlistBttn.x + wishlistBttn.width + 5;
			
			if(countOnStock)
				countOnStock.text = String(count);
		}
	}
	
	private function onWishlistEvent(e:MouseEvent):void
	{
		App.wl.show(sID, e);
	}
	
	private function onGiftBttnEvent(e:MouseEvent):void
	{
		window.close();
		new GiftWindow( {
			iconMode:GiftWindow.COLLECTIONS,
			itemsMode:GiftWindow.FRIENDS,
			sID:sID
		}).show();
	}
	
	public function dispose():void 
	{
		wishlistBttn.removeEventListener(MouseEvent.CLICK, onWishlistEvent);
		giftBttn.removeEventListener(MouseEvent.CLICK, onGiftBttnEvent);
		if(searchBttn) searchBttn.removeEventListener(MouseEvent.CLICK, onSearchBttn);
	}
}