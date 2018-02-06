package wins 
{
	import buttons.Button;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import wins.elements.PuzzleItem;

	
	public class EaselWindow extends Window 
	{
		public var sid:int = 0;
		public var info:Object = { };
		public var picture:Bitmap;
		public var counter:int = 0;
		public var itemsContainer:Sprite = new Sprite();
		public var puzzleContainer:Sprite = new Sprite();
		
		private var progressBar:ProgressBar;
		private var progressBacking:Bitmap;
		private var progressTitle:TextField;
		public static var posArr:Array = [ { x:1, y:1 }, { x:136, y:1 }, { x:272, y:0 }, { x:0, y:93 }, { x:108, y:51 }, { x:216, y:119 } ];
		private var backItems:Array;
		private var items:Vector.<KickItem> = new Vector.<KickItem>;
		private var maska:Shape = new Shape();
		private var back:Shape = new Shape();
		
		public function EaselWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['height'] = settings['height'] || 665;
			settings['width'] = settings['width'] || 695;
			settings['title'] = settings.target.info.title;
			settings['hasPaginator'] = false;
			settings['background'] = 'capsuleWindowBacking';
			settings['exitTexture'] = 'closeBttnMetal';
			
			sid = settings.target.sid;
			info = App.data.storage[sid];
			
			settings['content'] = [];
			
			for (var sID:* in info.kicks)
			{
				var obj:Object = { sID:sID, count:info.kicks[sID].c };
				if (info.kicks[sID].hasOwnProperty('t'))
				{
					obj['t'] = info.kicks[sID].t;
				}
				if (info.kicks[sID].hasOwnProperty('o'))
				{
					obj['o'] = info.kicks[sID].o;
				}
				if (info.kicks[sID].hasOwnProperty('k'))
				{
					obj['k'] = info.kicks[sID].k;
				}
				settings['content'].push(obj);
			}
			
			settings['content'].sortOn('o', Array.NUMERIC);
			
			super(settings);
			
			App.self.setOnTimer(checkParts);
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
		}
		
		private function checkParts():void 
		{
			if (counter == 6) 
			{
				App.self.setOffTimer(checkParts);
				picture.visible = true;
			}
		}
		
		override public function drawBackground():void 
		{
			super.drawBackground();
			var paper:Bitmap = new Bitmap();
			paper = backing(settings.width - 85, settings.height - 85, 46, 'paperGlow');
			paper.x = (settings.width - paper.width) / 2;
			paper.y = (settings.height - paper.height) / 2;
			layer.addChild(paper);
		}
		
		override public function drawBody():void 
		{
			drawPicture();
			drawPuzzles();
			
			exit.y -= 17;
			
			var desc:TextField = drawText(Locale.__e('flash:1460552985115'), {//Рисуй картину...
				width		: 510,
				height		: 80,
				color		: 0x6e411e,
				border		: false,
				
				fontSize	: 28,
				border		: true,
				textAlign	: 'center',
				multiline	: true,
				wrap		: true
			});
			desc.x = (settings.width - desc.width) / 2;
			//desc.border = true;
			
			back.graphics.beginFill(0xffffff, 1);
		    back.graphics.drawRoundRect(0, 0, 486, 285, 25, 25);
			back.filters = [new DropShadowFilter(2, 90, 0x000000, .5, 3, 3, 1, 1)];
		    back.graphics.endFill();
		    back.x = (settings.width - back.width) / 2 ;
			back.y = 60;
		    layer.addChild(back);
			
			desc.y = 310;
			
			bodyContainer.addChild(desc);
			
			drawKicks();
			
			progressBacking = Window.backingShort(430, "backingOne");
			progressBacking.x = back.x + (back.width - progressBacking.width) / 2;
			progressBacking.y = desc.y + desc.height + 2;
			bodyContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar({typeLine:'sliderOne', win:this, width:426, isTimer:false, tY: -6});
			progressBar.x = progressBacking.x - 16;
			progressBar.y = progressBacking.y - 15;
			bodyContainer.addChild(progressBar);
			progressBar.progress = settings.target.kicks / settings.target.kicksNeed;
			progressBar.start();
			
			progressTitle = drawText(progressData, {
				fontSize		:35,
				autoSize		:"left",
				textAlign		:"center",
				color			:0xffffff,
				borderColor		:0x6b340c,
				shadowColor		:0x6b340c,
				shadowSize		:1
			});
			
			progressTitle.x = progressBacking.x + progressBacking.width / 2 - progressTitle.width / 2;
			progressTitle.y = progressBacking.y - 6;
			progressTitle.width = 80;
			bodyContainer.addChild(progressTitle);
			
			var fillText:TextField = drawText(Locale.__e('flash:1460553102138'), {//Уже заполнено:
				color			:0x763a15,
				fontSize		:22,
				borderColor		:0xffffff,
				textAlign		:'center',
				autoSize		:"left"
			});
			
			fillText.x = progressBacking.x + (progressBacking.width - fillText.textWidth) / 2;
			fillText.y = progressBacking.y - 30;
			
			if (settings.target.kicks >= settings.target.kicksMax)
				blockItems(true);
			
		}
		
		public function get progressData():String
		{
			return String(settings.target.kicks) + ' / ' + String(settings.target.kicksNeed);
		}
		
		private function progress():void 
		{
			if (progressBar && info.tower.hasOwnProperty(settings.target.upgrade + 1))
			{
				progressBar.progress = settings.target.kicks / settings.target.kicksNeed;
				if (settings.target.kicks >= settings.target.kicksNeed) 
				{
					settings.target.kicks = settings.target.kicksNeed;
					blockItems(true);
				}
				progressTitle.text = String(settings.target.kicks) + ' / ' + String(settings.target.kicksNeed);
			}
		}
		
		private function drawPicture():void 
		{
			picture = new Bitmap();
			bodyContainer.addChild(maska);
			bodyContainer.addChild(picture);
			picture.visible = false;
			
			Load.loading(Config.getImage('paintings', info.backview, 'jpg'), function (data:*):void {
				picture.bitmapData = data.bitmapData;
				Size.size(picture, 456, 280);
				maska.graphics.beginFill(0xFFFFFF, 1);
				maska.graphics.drawRoundRect(0, 0, picture.width, 260, 25, 25);
				maska.graphics.endFill();
				picture.x = (settings.width - picture.width) / 2;
				picture.y = 32;
				maska.x = picture.x;
				maska.y = picture.y;
				maska.cacheAsBitmap = true;
				picture.mask = maska;
				
			}); 
		}
		
		private function drawPuzzles():void 
		{
			bodyContainer.addChild(puzzleContainer);
			
			for each (var itm:PuzzleItem in backItems)
			{
				if (itm.parent)
					itm.parent.removeChild(itm);
				itm.dispose();
				itm = null;
			}
			
			backItems = [];
			
			for (var i:int = 0; i < 6; i++)
			{
				var item:PuzzleItem = new PuzzleItem({id: i, pos: posArr[i]}, this)
				item.x = posArr[i].x;
				item.y = posArr[i].y;
				backItems.push(item);
				puzzleContainer.addChild(item);
				
				if (i < settings.target.upgrade)
					item.visible = false;
			}
			
			puzzleContainer.x = 115;
			puzzleContainer.y = 30;
			
		}
		
		public function drawKicks():void
		{
			clearKicks();
			var rewards:Array = [];
			for (var s:String in info.kicks) 
			{
				var object:Object = info.kicks[s];
				object['id'] = s;
				rewards.push(object);
			}
			
			rewards.sortOn('o', Array.NUMERIC);
			
			bodyContainer.addChild(itemsContainer);
			itemsContainer.y = 440;
			var X:int = 0;
			var Xs:int = X;
			for (var i:int = 0; i < rewards.length; i++)
			{
				var item:KickItem = new KickItem(rewards[i], this);
				item.x = Xs;
				itemsContainer.addChild(item);
				items.push(item);
				
				Xs += item.bg.width + 5;
			}
			
			itemsContainer.x = (settings.width - itemsContainer.width) / 2;
		}
		
		private function clearKicks():void 
		{
			while (items.length > 0) 
			{
				var item:KickItem = items.shift();
				itemsContainer.removeChild(item);
				item.dispose();
			}
		}
		
		private function onStockChange(e:AppEvent):void 
		{
			drawKicks();
		}
		
		public function blockItems(value:Boolean = true):void
		{
			for (var i:int = 0; i < items.length; i++) {
				if (value) {
					items[i].bttn.state = Button.DISABLED;
				}else {
					items[i].checkButtonsStatus();
				}
			}
		}
		
		public function onUpgradeComplete(bonus:Object = null):void
		{
			if (bonus && Numbers.countProps(bonus) > 0) 
			{
				App.user.stock.addAll(bonus);
			}
			
			kick();
			if (backItems[settings.target.level-1])
				TweenMax.to(backItems[settings.target.level-1], 3, { alpha:0} );
			blockItems(false);
		}
		
		public function kick():void
		{
			progress();
			App.ui.upPanel.update();
			
			if (settings.target.canUpgrade) 
			{
				blockItems(true);
			}else {
				blockItems(false);
			}
		}
		
		override public function dispose():void
		{
			clearKicks();
			App.self.setOffTimer(checkParts);
			super.dispose();
		}
	}
}

import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.BanksWindow;
import wins.ShopWindow;
import wins.Window;

internal class KickItem extends LayerX
{	
	public var window:*;
	public var item:Object;
	public var bg:Bitmap;
	public var bttn:Button;
	public var searchBttn:Button;
	
	private var bitmap:Bitmap;
	private var count:uint;
	private var nodeID:String;
	private var type:uint;
	private var k:uint;
	private var sID:uint;
	private var icon:Bitmap;
	private var sprite:LayerX;
	private var stockCount:TextField;
	
	public function KickItem(obj:Object, window:*) 
	{
		this.sID = obj.id;
		this.count = obj.c;
		this.nodeID = obj.id;
		this.k = obj.k;
		this.item = App.data.storage[sID];
		this.window = window;
		type = obj.t;
		
		bg = Window.backing(110, 110, 20, 'itemBacking');
		addChild(bg);
		bg.y 
		bitmap = new Bitmap();
		addChild(bitmap);
		
		drawTitle();
		drawBttn();
		drawLabel();
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		tip = function():Object {
			return {
				title: item.title,
				text: item.description
			}
		}
	}
	
	private function drawBttn():void
	{
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1382952379978"),
			width:100,
			height:35,
			fontSize:20
		}
		
		/*if (item.real == 0 || type == 1)
		{
			bttnSettings['borderColor'] = [0xaff1f9, 0x005387];
			bttnSettings['bgColor'] = [0x70c6fe, 0x765ad7];
			bttnSettings['fontColor'] = 0x453b5f;
			bttnSettings['fontBorderColor'] = 0xe3eff1;
			
			bttn = new Button(bttnSettings);
		}*/
		
		if (item.real || type == 2) 
		{
			bttnSettings['bgColor'] = [0x70cdf5, 0x5e8fd7];
			bttnSettings['bevelColor'] = [0xd6f0ff, 0x4b6db2];
			bttnSettings['fontColor'] = 0xffffff;
			bttnSettings['fontBorderColor'] = 0x104f7d;
			bttnSettings['fontCountColor'] = 0xffffff;
			bttnSettings['fontCountSize'] = 17;
			bttnSettings['fontCountBorder'] = 0x104f7d;
			bttnSettings['countText']	= item.price[Stock.FANT];
			
			bttn = new MoneyButton(bttnSettings);
		}
		
		if (type == 3) 
		{
			bttn = new Button(bttnSettings);
			
			bttnSettings['caption'] = Locale.__e("flash:1407231372860");
			bttnSettings['bgColor'] = [0xc5e215, 0x81b730];
			bttnSettings['bevelColor'] = [0xdef48a, 0x577c2d];
			bttnSettings['fontColor'] = 0xffffff;
			bttnSettings['fontBorderColor'] = 0x085c10;
			
			searchBttn = new Button(bttnSettings);
		}
		
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height / 2;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		if (searchBttn)
		{
			addChild(searchBttn);
			searchBttn.x = (bg.width - searchBttn.width) / 2;
			searchBttn.y = bg.height - searchBttn.height / 2;
			searchBttn.addEventListener(MouseEvent.CLICK, searchEvent);
		}
		
		checkButtonsStatus();
	}
	
	private function onLoadIcon(data:Bitmap):void
	{
		icon.bitmapData = data.bitmapData;
		icon.scaleX = icon.scaleY = 0.35;
		icon.x = 20;
		icon.y = 4;
		icon.smoothing = true;
	}
	
	public function checkButtonsStatus():void
	{
		if (type == 2) 
		{
			bttn.state = Button.NORMAL;
		}else if (type == 3)
		{
			if (App.user.stock.count(sID) < price) 
			{
				searchBttn.visible = true;
				bttn.visible = false;
				//bttn.state = Button.DISABLED;
			}else {
				searchBttn.visible = false;
				bttn.visible = true;
				//bttn.state = Button.NORMAL;
			}
		}
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED || e.currentTarget.visible == false) return;
		
		if (window.settings.target.kicks > window.settings.target.kicksNeed)
			return;
			
		if (currency == Stock.FANT && App.user.stock.count(Stock.FANT) < price)
		{
			window.close();
			BanksWindow.history = {section:'Reals',page:0};
			new BanksWindow().show();
			return;
		}
		
		if (type == 3 && App.user.stock.count(sID) < 1 && ShopWindow.findMaterialSource(sID))
		{
			window.close();
			return;
		}
		
		window.blockItems();
		window.settings.target.kickAction(sID, onKickEventComplete);
	}
	
	private function onKickEventComplete(bonus:Object = null):void
	{
		App.user.stock.take(currency, price);
		
		var X:Number = App.self.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY;
		Hints.minus(currency, price, new Point(X, Y), false, App.self.tipsContainer);
		
		if (Numbers.countProps(bonus) > 0)
		{
			BonusItem.takeRewards(bonus, new Point(X, Y), 20, true, true);
		}
		
		if (stockCount) stockCount.text = 'x' + App.user.stock.count(sID);
		window.kick();
		
		if (window.settings.target.kicks >= window.settings.target.kicksNeed) 
		{
			window.settings.target.growAction(onUpgradeEvent);
		}
	}	
	
	public function onUpgradeEvent(bonus:Object = null):void 
	{
		window.onUpgradeComplete();
		
		if (bonus)
		{
			flyBonus(bonus);
		}
	}
	
	private function flyBonus(data:Object):void 
	{
		var targetPoint:Point = Window.localToGlobal(bttn);
		targetPoint.y += bttn.height / 2;
		
		for (var _sID:Object in data)
		{
			var sID:uint = Number(_sID);
			for (var _nominal:* in data[sID])
			{
				var nominal:uint = Number(_nominal);
				var count:uint = Number(data[sID][_nominal]);
			}
			
			var item:*;
			
			for (var i:int = 0; i < count; i++)
			{
				item = new BonusItem(sID, nominal);
				App.user.stock.add(sID, nominal);
				
				item.cashMove(targetPoint, App.self.windowContainer)
			}
		}
		SoundsManager.instance.playSFX('reward_1');
	}
	
	private function onLoad(data:Bitmap):void 
	{
		sprite = new LayerX();
		sprite.tip = function():Object {
			return {
				title: item.title,
				text: item.description
			};
		}
		
		bitmap = new Bitmap(data.bitmapData);
		Size.size(bitmap, 60, 60);
		sprite.x = (bg.width - bitmap.width) / 2;
		sprite.y = (bg.height - bitmap.height) / 2;
		sprite.addChild(bitmap);
		addChildAt(sprite, 1);
		bitmap.smoothing = true;
		
		//sprite.addEventListener(MouseEvent.CLICK, searchEvent);
	}
	
	private function searchEvent(e:MouseEvent):void 
	{
		Window.closeAll();
		ShopWindow.findMaterialSource(sID);
	}
	
	public function dispose():void 
	{
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function drawTitle():void
	{
		var title:TextField = Window.drawText(item.title + ' +' + k, {
			color:0xffffff,
			borderColor:0x8b420e,
			textAlign:"center",
			autoSize:"center",
			fontSize:22,
			textLeading:-6,
			multiline:true,
			distShadow:0
		});
		
		title.wordWrap = true;
		title.width = bg.width - 5;
		title.height = title.textHeight;
		title.x = 5;
		title.y = - title.height / 2;
		addChild(title);
	}
	
	public function drawLabel():void 
	{
		var count:int = App.user.stock.count(sID);
		var countText:String = 'x' + String(count);
		
		if (count < 1)
		{
			countText = '';
		}
		
		if (stockCount)
		{
			removeChild(stockCount);
			stockCount = null;
		}
		
		stockCount = Window.drawText(countText, {
			color:0xffffff,
			fontSize:30,
			borderColor:0x7b3e07
		});
		
		stockCount.width = stockCount.textWidth + 10;
		stockCount.x = bg.x + bg.width - stockCount.width;
		stockCount.y = bg.y + bg.height - 55;
		
		if (type == 2)
			return;
		addChild(stockCount);
	}
	
	private function get price():int 
	{
		if (type == 2) 
		{
			for (var s:* in item.price) break;
			return item.price[s];
		}
		
		return 1;
	}
	
	private function get currency():int
	{
		if (type == 2)
		{
			for (var s:* in item.price) break;
			return int(s);
		}
		return sID;
	}
}


