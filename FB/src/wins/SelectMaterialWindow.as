package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import wins.elements.StockCounter;
	import wins.PriceFactor;
	/**
	 * ...
	 * @author ...
	 */
	public class SelectMaterialWindow extends Window 
	{
		public var item:Object;
		
		public var bitmap:Bitmap;
		protected var icon:Bitmap;
		public var title:TextField;
		public var priceBttn:Button;/*
		public var placeBttn:Button;
		public var applyBttn:Button;*/
		public var wishBttn:ImageButton;
		public var giftBttn:ImageButton;
		public var sellPrice:TextField;
		public var price:int;
		public var background:Bitmap;
		
		public var plusBttn:Button;
		public var minusBttn:Button;
		
		public var plus10Bttn:Button;
		public var minus10Bttn:Button;
		
		public var countCalc:TextField;
		public var countOnStock:TextField;
		
		protected var _dataProvider:Array;
		protected var _limit:int;
		
		protected var _currentMaterialID:int;
		public function get currentMaterialID():int 
		{
			return _currentMaterialID;
		}
		
		protected var _currentCount:int;
		public function get currentCount():int 
		{
			return _currentCount;
		}
		
		protected var _priceFactors:Vector.<PriceFactor>;
		public function get priceFactors():Vector.<PriceFactor> 
		{
			return _priceFactors;
		}
		public function set priceFactors(value:Vector.<PriceFactor>):void 
		{
			_priceFactors = value;
			updateCountAndPrice();
		}
		
		protected var _applyButtonText:String;
		
		public function SelectMaterialWindow(priceFactors:Vector.<PriceFactor>, limit:int = 0, settings:Object = null):void
		{
			if (settings == null) 
			{
				settings = new Object();
			}
			
			_priceFactors = priceFactors;
			_limit = limit;
			
			settings["title"] = settings["title"] || Locale.__e("flash:1382952379978");
			settings["applyButtonText"] = settings["applyButtonText"] || Locale.__e("flash:1382952379978");
			
			settings["titleDecorate"] = false;
			settings["itemsOnPage"] = 1;
			
			settings["width"] = settings["width"] || 350;
			settings["height"] = settings["height"] || 350;
			settings["popup"] = true;
			settings["fontSize"] = 44;
			settings["fontBorderSize"] = 2;
			settings["callback"] = settings["callback"] || null;
			settings["background"] = 'itemBacking'
			settings["hasPaginator"] = true;
			settings["smallExit"] = true;
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			settings['priceTitle'] = settings['priceTitle'] || Locale.__e("flash:1382952380131");
			
			super(settings);
			
			initContent();
		}
		
		protected function initContent():void
		{
			if (settings.hasOwnProperty("items") && settings.items is Array)
			{
				_dataProvider = settings.items;
			}
			else
			{
				_dataProvider = [];
				for (var key:String in App.user.stock.data)
				{
					_dataProvider.push(int(key));
				}
			}
			
			settings.content = _dataProvider;
			
			_currentMaterialID = _dataProvider[0]
			item = App.data.storage[_currentMaterialID];
		}
			
		protected var preloader:Preloader = new Preloader();
		protected var shape:Shape;
		override public function drawBody():void 
		{
			paginator.itemsCount = _dataProvider.length;
			paginator.visible = false;
			
			titleLabel.y = -8;
			
			shape = new Shape();
			shape.graphics.beginFill(0xe2b8aa, 1);
			shape.graphics.drawCircle(0, 0, 60);
			shape.graphics.endFill();
			bodyContainer.addChild(shape);
			shape.x = settings.width / 2;
			shape.y = settings.height / 2 - 55;
		
			var sprite:LayerX = new LayerX();
			bodyContainer.addChild(sprite);
		
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
		
			sprite.tip = function():Object { 
				return {
					title:item.title,
					text:item.description
				};
			};
		
			drawTitleItem();
			drawBttns();
			
			drawMaterialIcon();
			
			//price = item.cost;
			if (item.cost) {
				price = Math.round(item.cost);
			} else if (item.sale) {
				price = salePrice();
			}
			
			if (item.type == "e") {
				priceBttn.visible = false;
			} else {
				//drawCalculator();
				drawSellPrice();
			}
			
			drawCount();
			contentChange();
		}
		
		protected function drawMaterialIcon():void
		{
			bitmap.visible = false;
			bodyContainer.addChild(preloader);
			
			preloader.x = shape.x + (shape.width - preloader.width) * 0.5;
			preloader.y = shape.y + (shape.height - preloader.height) * 0.5;
			
			Load.loading(Config.getIcon(item.type, item.preview), function(data:Bitmap):void 
			{
				if (bodyContainer.contains(preloader))
				{
					bodyContainer.removeChild(preloader);
				}
				
				bitmap.bitmapData = data.bitmapData;
				bitmap.visible = true;
				bitmap.x = shape.x - bitmap.width / 2;
				bitmap.y = shape.y - bitmap.height / 2;
				bitmap.smoothing = true;
				Size.size(bitmap, 100, 100)
			});
		}
		
		override public function drawArrows():void 
		{
			super.drawArrows();
			paginator.arrowLeft.x += 51;
			paginator.arrowRight.x -= 13;
			paginator.arrowLeft.y -= 24;
			paginator.arrowRight.y -= 24;
		}
		
		override public function contentChange():void 
		{
			//super.contentChange();
			_currentMaterialID = _dataProvider[paginator.page];
			item = App.data.storage[currentMaterialID];
			drawMaterialIcon();
			drawTitleItem();
			drawCount();
			
			dispatchEvent(new Event(Event.CHANGE));
			
			_currentCount = 1;
			
			updateCountAndPrice();
			updateButtons();
		}
		
		public function salePrice():int {
			if (item.sale) 
			{
				for (var s:String in item.sale) 
				{
					switch(int(s)) {
						case Stock.FANT:
							onSaleIconLoad(new Bitmap(UserInterface.textures.fantsIcon, 'auto', true));
							break;
						default:
							Load.loading(Config.getIcon(App.data.storage[s].type, App.data.storage[s].preview), onSaleIconLoad);
					}
					return item.sale[s];
				}
			}
			return 0;
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height , 50, 'workerHouseBacking');
			var background2:Bitmap  = backing2(settings.width - 60, settings.height - 54, 40, 'capsuleWindowBackingPaperUp', 'capsuleWindowBackingPaperDown');
			
			background2.x = background.x + (background.width - background2.width) / 2;
			background2.y = background.y + (background.height - background2.height) / 2;
			layer.addChildAt(background, 0);
			layer.addChildAt(background2, 1);
			
			//var background:Bitmap = backing2(settings.width, settings.height, 50, 'questBackingTop', 'questBackingBot');
			//layer.addChild(background);
		}
		
		public function onSaleIconLoad(data:Bitmap):void {
			if (!icon) {
				icon = new Bitmap(data.bitmapData, 'auto', true);
			}else {
				icon.bitmapData = data.bitmapData;
				icon.smoothing = true;
			}
			drawSellSize();
		}
	
		override public function dispose():void 
		{
			super.dispose();
			
			if (plusBttn != null){
				plusBttn.removeEventListener(MouseEvent.CLICK, onPlusEvent);
				minusBttn.removeEventListener(MouseEvent.CLICK, onMinusEvent);
				plus10Bttn.removeEventListener(MouseEvent.CLICK, onPlus10Event);
				minus10Bttn.removeEventListener(MouseEvent.CLICK, onMinus10Event);
			}
			
			priceBttn.removeEventListener(MouseEvent.CLICK, onApplyEvent);
			
			if (settings.callback != null) {
				settings.callback();
			}
		}
		
		public function drawTitleItem():void 
		{
				
				if (title){
					title.parent.removeChild(title);
				}
				var size:Point = new Point(135, 55);
				var pos:Point = new Point(
					(settings.width - size.x) / 2,
					30 - size.y/2
				);
				title = Window.drawTextX(item.title, size.x, size.y, pos.x, pos.y, this, {
						color:0x7e3918,
						borderColor:0xfdf7e9,
						textAlign:"center",
						autoSize:"center",
						fontSize:26
						/*multiline:true,
						wrap:true*/
				});
				
				bodyContainer.addChild(title);
			
			
			title.y =  30 - title.textHeight/2;
			title.x = (settings.width - title.width) / 2;
		}
		
		protected var counter:StockCounter;
		public function drawCount():void 
		{
			if (!counter)
			{
				counter = new StockCounter();
				counter.x = 98;
				counter.y = 67;
				bodyContainer.addChild(counter);
			}
			
			if (settings.counts)
			{
				var index:int = settings.items.indexOf(currentMaterialID);
				if (index in settings.counts)
				{
					counter.count = settings.counts[index] - 1;
					return;
				}
			}
			
			counter.count = (App.user.stock.data[currentMaterialID] - 1);
		}
		
		
		protected var _sellPriceContainer:Sprite;
		protected var _sellMaterialIcons:Vector.<MaterialIcon>;
		public function drawSellPrice():void 
		{
			if (!_sellPriceContainer)
			{
				_sellPriceContainer = new Sprite();
			}
			
			if (!_sellMaterialIcons)
			{
				_sellMaterialIcons = new Vector.<MaterialIcon>();
			}
			
			var open:TextField = Window.drawText(settings.priceTitle, {
				color:0x643519,
				border:false,
				fontSize:24,
				autoSize:"left"
			});
			
			_sellPriceContainer.addChild(open);
			
			var iconSize:int = 45;
			var startX:int = _sellPriceContainer.width + 5;
			var dX:int = 5;
			
			var currentMaterialIcon:MaterialIcon;
			for each (var priceFactor:PriceFactor in _priceFactors) 
			{
				currentMaterialIcon = new MaterialIcon(priceFactor.materialID, true, price * priceFactor.factor, iconSize);
				currentMaterialIcon.x = startX + (_sellMaterialIcons.length * (iconSize + dX));
				currentMaterialIcon.y = -5;
				
				_sellMaterialIcons.push(currentMaterialIcon);
				_sellPriceContainer.addChild(currentMaterialIcon);
			}
			
			_sellPriceContainer.x = (settings.width - _sellPriceContainer.width) * 0.5;
			_sellPriceContainer.y = 220;
			
			bodyContainer.addChild(_sellPriceContainer);
		}
		
		protected function drawSellSize():void 
		{
			icon.scaleX = icon.scaleY = 0.8;
			icon.smoothing = true;
		}
		
		public var calc:Sprite;
		public function drawCalculator():void 
		{
			calc = new Sprite();
			bodyContainer.addChild(calc);
			
			var countBg:Sprite = new Sprite();
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0xffeed6);
			bg.graphics.drawCircle(0, 0, 18);
			
			var bg2:Shape = new Shape();
			bg.graphics.beginFill(0xdda1a3);
			bg.graphics.drawCircle(0, 0, 16);
				
			countBg.addChild(bg);
			countBg.addChild(bg2);
			
			countBg.filters = [new DropShadowFilter(0, 90, 0, 0.5, 3, 3)];
			calc.addChild(countBg);
			
			//var countBg:Shape = new Shape();
			//countBg.graphics.beginFill(0xd3ad7c);
			//countBg.graphics.drawCircle(0, 0, 18);
			//countBg.graphics.endFill();
			//
			//countBg.x = 0
			//countBg.y = 0;
			//calc.addChild(countBg);
			
			/*countCalc = Window.drawText("1", {
				color:0xfeffff,
				borderColor:0x572c26,
				fontSize:24,
				textAlign:"center"
			});
			
			countCalc.width = countBg.width;
			countCalc.height = countCalc.textHeight;
			calc.addChild(countCalc);
			countCalc.x = - countBg.width / 2;
			countCalc.y = - countBg.height / 2 + 5;*/
			
			/*calc.x = shape.x;
			calc.y = shape.y + shape.height / 2 + 12;*/
			
			var counterButtonSettings:Object = { 
				bgColor			:[0xffe3af, 0xffb468],
				bevelColor		:[0xffeee0, 0xc0804e],
				borderColor		:[0xc3b197, 0xcab89f],
				width			:38,
				height			:26,
				fontSize		:18,
				fontColor		:0xffffff,
				fontBorderColor	:0xa05d36,
				shadow			:true,
				radius			:10,
				shadowColor		:0xa05d36,
				shadowSize		:3
			};
			
			counterButtonSettings["caption"] = "-10";
			minus10Bttn = new Button(counterButtonSettings);
			minus10Bttn.x = calc.x - 90;
			minus10Bttn.y = 180;
			//5bodyContainer.addChild(minus10Bttn);
			
			counterButtonSettings["caption"] = "-";
			counterButtonSettings["width"] = 28;
			minusBttn = new Button(counterButtonSettings);
			minusBttn.x = minus10Bttn.x + minus10Bttn.width + 3;
			minusBttn.y = minus10Bttn.y;
			//bodyContainer.addChild(minusBttn);
			
			counterButtonSettings["caption"] = "+";
			counterButtonSettings["width"] = 28;
			plusBttn = new Button(counterButtonSettings);
			plusBttn.x = minusBttn.x + 70;
			plusBttn.y = minus10Bttn.y;
			//bodyContainer.addChild(plusBttn);
			
			counterButtonSettings["caption"] = "+10";
			counterButtonSettings["width"] = 38;
			plus10Bttn = new Button(counterButtonSettings);
			plus10Bttn.x = plusBttn.x + plusBttn.width + 3;
			plus10Bttn.y = minus10Bttn.y;
			//bodyContainer.addChild(plus10Bttn);
			
			minusBttn.state = Button.DISABLED;
			minus10Bttn.state = Button.DISABLED;
			
			plusBttn.addEventListener(MouseEvent.CLICK, onPlusEvent);
			minusBttn.addEventListener(MouseEvent.CLICK, onMinusEvent);
			plus10Bttn.addEventListener(MouseEvent.CLICK, onPlus10Event);
			minus10Bttn.addEventListener(MouseEvent.CLICK, onMinus10Event);
		}
		
		public function drawBttns():void 
		{
			priceBttn = new Button( {
				caption:settings["applyButtonText"],
				fontSize:30,
				width:150,
				height:45
			});
			bodyContainer.addChild(priceBttn);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = settings.height - priceBttn.height - 33;
			priceBttn.addEventListener(MouseEvent.CLICK, onApplyEvent);
		}
		
		protected function onApplyEvent(e:MouseEvent):void 
		{
			if (priceBttn.mode == Button.DISABLED)
			{
				var buttonBounds:Rectangle = priceBttn.getBounds(stage);
				var hintX:int = buttonBounds.x + (buttonBounds.width * 0.5);
				var hintY:int = buttonBounds.y + (buttonBounds.height * 0.5);
				
				Hints.text(Locale.__e("flash:1382952379927") + "!", Hints.TEXT_RED, new Point(hintX, hintY));
				return;
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function get instock():int
		{
			var result:int; 
			if (settings.counts)
			{
				var index:int = settings.items.indexOf(currentMaterialID);
				if (index in settings.counts)
				{
					result = settings.counts[index];
					return result;
				}
			}
			
			result = App.user.stock.data[_currentMaterialID];
			return result;
		}
		
		protected function updateButtons():void
		{
			//instock = App.user.stock.data[_currentMaterialID];
			
			/*if (_currentCount <= 1)
			{
				minusBttn.state = Button.DISABLED;
				minus10Bttn.state = Button.DISABLED;
			}
			else
			{
				minusBttn.state = Button.NORMAL;
				minus10Bttn.state = Button.NORMAL;
			}
			
			if (_currentCount >= instock || (_limit && _currentCount >= _limit))
			{
				plusBttn.state = Button.DISABLED;
				plus10Bttn.state = Button.DISABLED;
			}
			else
			{
				plusBttn.state = Button.NORMAL;
				plus10Bttn.state = Button.NORMAL;
			}*/
			
			if (instock == 0)
				priceBttn.state = Button.DISABLED;
			else
				priceBttn.state = Button.NORMAL;
		}
		
		protected function updateCountAndPrice():void
		{	
			if (instock == 0)
				_currentCount = 0;
			
			if (_limit > 0 && _currentCount > _limit)
				_currentCount = _limit;
			
			if (_currentCount > instock)
				_currentCount = instock;
			else if (_currentCount <= 0 && instock > 0)
				_currentCount = 1;
				
			countCalc.text = _currentCount.toString();
			
			var currentMaterialIcon:MaterialIcon;
			for (var i:int = 0; i < _sellMaterialIcons.length; i++) 
			{
				currentMaterialIcon = _sellMaterialIcons[i];
				currentMaterialIcon.count = _currentCount * _priceFactors[i].factor;
			}
			
			//sellPrice.text = Math.ceil(_currentCount * price * _priceFactors[0].factor).toString();
			
			counter.count = instock - _currentCount;
		}
		
		////+++++
		protected function onPlusEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) 
				return;
			
			_currentCount += 1;
			
			updateCountAndPrice()
			updateButtons();
			
			updateButtons()
		}
		
		protected function onMinusEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) 
				return;
			
			_currentCount -= 1;
			
			updateCountAndPrice()
			updateButtons();
			
			updateButtons()
		}
		
		protected function onPlus10Event(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) 
				return;
				
			_currentCount += 10;
			
			updateCountAndPrice()
			updateButtons();
			
			updateButtons();
		}
		
		protected function onMinus10Event(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) 
				return;
			
			_currentCount -= 10;
			
			updateCountAndPrice()
			updateButtons();
			
			updateButtons();
		}
		
		
		public function bttnsShowCheck(e:*=null):void
		{
			if (minus10Bttn != null) 
			{
				if (this.mouseY < 180 && this.mouseY > 145 && this.mouseX > 0 && this.mouseX < 180)
				{
					minus10Bttn.visible = true;
					plus10Bttn.visible = true;
				}
				else
				{
					minus10Bttn.visible = false;
					plus10Bttn.visible = false;
				}
			}
		}
	}
}