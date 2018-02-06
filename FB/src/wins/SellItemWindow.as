package wins
{
	import buttons.Button;
	import buttons.ImageButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	
	public class SellItemWindow extends Window
	{
		public var item:Object;
		
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var priceBttn:Button;
		public var placeBttn:Button;
		public var applyBttn:Button;
		public var wishBttn:ImageButton;
		public var giftBttn:ImageButton;
		public var sellPrice:TextField;
		public var price:int;
		
		public var plusBttn:Button;
		public var minusBttn:Button;
		
		public var plus10Bttn:Button;
		public var minus10Bttn:Button;
		
		public var countCalc:TextField;
		public var countOnStock:TextField;
		
		public function SellItemWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			App.data.storage;		
			item = App.data.storage[settings.sID];

			
			settings["title"] = Locale.__e("flash:1382952380277");
			
			settings["width"] = 380;
			settings["height"] = 290;
			settings["popup"] = true;
			settings["fontSize"] = 32;
			settings["callback"] = settings["callback"] || null;
			settings["fontColor"] = 0xfffa74;
			settings["fontBorderColor"] = 0x6e411e;
			settings["fontBorderSize"] = 3;
			
			settings["hasPaginator"] = false;
			
			super(settings);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 90, "paperWithBacking");
			layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		private var preloader:Preloader = new Preloader();
		private var itemBg:Shape;
		private var back:Shape = new Shape();
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: true,
				fontSize			: 28,
				textLeading	 		: settings.textLeading,
				borderColor 		: settings.fontBorderColor,
				borderSize 			: settings.fontBorderSize,
				
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 80,
	//			autoSize			: 'center',
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width)/2;
			titleLabel.y = -38;
			
			bodyContainer.addChild(titleLabel);
		}
		
		
		override public function drawBody():void {
			
			drawMirrowObjs('decSeaweed', settings.width + 57, - 57, settings.height - 175, true, true, false, 1, 1, layer);
			
			back.graphics.beginFill(0xfff4b9, .9);
		    back.graphics.drawRect(0, 0, settings.width - 120, 40);
		    back.graphics.endFill();
		    back.x = (settings.width - back.width) / 2 ;
		    back.y = settings.height - back.height - 107 ;
		    back.filters = [new BlurFilter(40, 0, 2)];
		    bodyContainer.addChild(back);
			titleLabel.y = -34;
			
			background = backing(198, 205, 10, "banksBackingItem"); 
			//bodyContainer.addChild(background);
			background.x = (settings.width - background.width) / 2;
			background.y = (settings.height - background.height) / 3 - 20;;
			
			var titleBackgr:Bitmap = Window.backingShort(150, "titleBgNew");
			titleBackgr.x = (settings.width - titleBackgr.width)/2;
			titleBackgr.y = -7;
			layer.addChild(titleBackgr);
			
			var sprite:LayerX = new LayerX();
			bodyContainer.addChild(sprite);
			
			/*itemBg = new Bitmap(Window.textures.bgOutItem); //подложка item'a
			sprite.addChild(itemBg);
			itemBg.scaleX = itemBg.scaleY = 1.05;
			itemBg.smoothing = true;
			itemBg.x = (settings.width - itemBg.width) / 2;
			itemBg.y = 30;*/
			
			itemBg = new Shape();
			itemBg.graphics.beginFill(0xe59e79, 1);
			itemBg.graphics.drawCircle(0, 0, 53);
			itemBg.graphics.endFill();
			itemBg.x = settings.width / 2;
			itemBg.y = 25 + itemBg.width/2;
			sprite.addChild(itemBg);
		
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
			
			addChild(preloader);
			preloader.x = (settings.width - preloader.width)/ 2;
			preloader.y = (background.height - preloader.height) / 2 - 20 + background.y;
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
			
			price = item.cost;
			//price = Math.round(item.cost - (item.cost * 0.1));
			
			
			
			if (item.type == "e") {
				priceBttn.visible = false;
			}else{
				drawCalculator();
				drawSellPrice();
			}
					
			drawCount();
		
			addEventListener(MouseEvent.MOUSE_OVER, onOverEvent);
			addEventListener(MouseEvent.MOUSE_OUT, onOutEvent);
		}
		
		public function onLoad(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			Size.size(bitmap, itemBg.width - 25, itemBg.width - 25);
			bitmap.smoothing = true;
			bitmap.x = itemBg.x - bitmap.width/2;
			bitmap.y = itemBg.y - bitmap.height/2;
			
		}
		
	
		override public function dispose():void {
			super.dispose();
			
			removeEventListener(MouseEvent.MOUSE_OVER, onOverEvent);
			removeEventListener(MouseEvent.MOUSE_OUT, onOutEvent);
			
			if (plusBttn != null){
				plusBttn.removeEventListener(MouseEvent.CLICK, onPlusEvent);
				minusBttn.removeEventListener(MouseEvent.CLICK, onMinusEvent);
				plus10Bttn.removeEventListener(MouseEvent.CLICK, onPlus10Event);
				minus10Bttn.removeEventListener(MouseEvent.CLICK, onMinus10Event);
			}
			
			priceBttn.removeEventListener(MouseEvent.CLICK, onSellEvent);
			
			if (settings.callback != null) {
				settings.callback();
			}
		}
		
		public function drawTitleItem():void {
			
			/*title = Window.drawText(item.title, {
				color:0x6e411e,
				border: false,
				textAlign:"center",
				autoSize:"center",
				fontSize:30,
				multiline:true
			});
			title.wordWrap = true;
			title.width = background.width - 50;
			title.y = background.y + title.textHeight/2 - 12;
			title.x = (settings.width - title.width) /2;
			bodyContainer.addChild(title);*/
		
			
			var size:Point = new Point(background.width - 50, 35);
			var pos:Point = new Point(itemBg.x - size.x/2, itemBg.y - itemBg.height/2 - 15);
			
			title = Window.drawTextX(item.title, size.x, size.y, pos.x, pos.y, this, {
				color:0x6e411e,
				border: false,
				textAlign:"center",
				autoSize:"center",
				fontSize:30,
				multiline:true
			});
			bodyContainer.addChild(title);
			
		}
		
		public function drawCount():void {
			
			countOnStock = Window.drawText(String(App.user.stock.data[settings.sID] - 1), {
				color:0xffd03a,
				borderColor:0x89562b,
				fontSize:24,
				autoSize:"center"
			});
			
			var circleSprite:Sprite = new Sprite();
			
			var bg:Bitmap = new Bitmap(Window.textures.clearBubbleBacking_0);
			Size.size(bg, 40, 40); 
			bg.x = 280;
			bg.y = 14;
			bg.smoothing = true;
			circleSprite.addChild(bg);
			
			/*//var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0xbc8e41);
			bg.graphics.drawCircle(0, 0, 20);
			
			var bg2:Shape = new Shape();
			bg.graphics.beginFill(0xefd099);
			bg.graphics.drawCircle(0, 0, 17);*/
				
			/*circleSprite.addChild(bg);
			circleSprite.addChild(bg2);
			circleSprite.x = 48;
			circleSprite.y = -20;*/
			/*bg.x = background.width - 25;
			bg2.x = background.width - 25;
			bg.y = background.y + 40;
			bg2.y = background.y + 40;*/
			
			circleSprite.addChild(countOnStock);
			bodyContainer.addChild(circleSprite);
			
			countOnStock.x = bg.x + (bg.width-countOnStock.textWidth)/2 - 2;
			countOnStock.y = bg.y + (bg.height - countOnStock.textHeight) / 2;
			
			
			if (countOnStock.text == "0") {
				plusBttn.state = Button.DISABLED;
				plus10Bttn.state = Button.DISABLED;
			}
		}
		
		public function drawSellPrice():void {
			var freeSpace:uint = 5;
			var icon:Bitmap;
			var settings:Object = {  };
			
			//icon = new Bitmap(Window.textures.money, "auto", true);
			icon = new Bitmap(UserInterface.textures.goldenPearl, "auto", true);
			icon.scaleX = icon.scaleY = 0.7;
			
			icon.x = 150;
			icon.y = 185;

			bodyContainer.addChild(icon);
					
			sellPrice = Window.drawText(String(price), {
				fontSize:22, 
				autoSize:"left",
				color:0xffdc39,
				borderColor:0x794909
			});
			bodyContainer.addChild(sellPrice);
			sellPrice.x = icon.x + icon.width + 5;
			sellPrice.y = icon.y + 2;
			
			var open:TextField = Window.drawText(Locale.__e("flash:1382952380131"), {
				color:0x783a15,
				borderColor:0xffe4ba,
				borderSize:3,
				fontSize:24,
				autoSize:"left"
			});
			bodyContainer.addChild(open);
			var pLabelWd:uint = open.width + freeSpace + icon.width + freeSpace + sellPrice.width;
			open.x = background.x + (background.width-pLabelWd)/2;
			open.y = icon.y + 3;
			
			icon.x = open.x + open.width + freeSpace;
			sellPrice.x = icon.x + icon.width + freeSpace;
			
		}
		
		public function drawCalculator():void {
			
			//var countBg:Shape = new Shape();
			//countBg.graphics.beginFill(0xc29f5f);
			//countBg.graphics.drawCircle(54, -18, 18);
			//var countBg:Bitmap = new Bitmap(UserInterface.textures.itemCounter);
			var countBg:Shape = new Shape();
			countBg.graphics.beginFill(0xfbecaf, 1);
			countBg.graphics.drawRoundRect(0, 0, 51, 33, 10, 10);
			countBg.graphics.endFill();
			countBg.filters = [new DropShadowFilter(1, 90, 0xab9a79, 0.7, 4, 4, 4, 1, true), new DropShadowFilter(1, -90, 0xffffff, .9, 4, 4, 4, 1, true)];	
			countBg.x = (this.settings.width - countBg.width) / 2 ;
			countBg.y = 147;
			bodyContainer.addChild(countBg);
			
			//var countBg:Bitmap = Window.backing(50, 40, 10, "smallBacking");
			//countBg.x = (background.width - countBg.width) / 2 + 5;
			//countBg.y = 164;
			//bodyContainer.addChild(countBg);
			
			countCalc = Window.drawText("1", {
				color:0xffd03a,
				borderColor:0x2e3332,
				fontSize:20,
				textAlign:"center"
			});
			
			bodyContainer.addChild(countCalc);
			countCalc.width = 26;
			countCalc.height = 17;
			countCalc.x = countBg.x + (countBg.width - countCalc.width) / 2;
			countCalc.y = countBg.y + (countBg.height - countCalc.height) / 2 - 3;
			
			var settings:Object = {
				caption			:"+",
				bgColor			:[0xD2C7AB,0xD2C7AB],
				width			:26,
				height			:26,
				borderColor		:[0x474337,0x474337],
				fontSize		:18,
				fontColor		:0xcec080,
				fontBorderColor	:0x6d4b15,
				shadow			:true,
				radius			:10
			};
			
/*			minus10Bttn = new ImageButton(UserInterface.textures.coinsMinusBttn10);
			minus10Bttn.scaleX = 0.9;
			minus10Bttn.y = 135;
			minus10Bttn.x = background.x + 13;
			
			minusBttn = new ImageButton(UserInterface.textures.coinsMinusBttn);
			minusBttn.scaleX = 0.9;
			minusBttn.y = minus10Bttn.y;
			minusBttn.x = minus10Bttn.x + minus10Bttn.width + 3;
			
			plus10Bttn = new ImageButton(UserInterface.textures.coinsPlusBttn10);
			plus10Bttn.scaleX = 0.9;
			plus10Bttn.y = minus10Bttn.y;
			plus10Bttn.x = background.width - 8;
			
			plusBttn = new ImageButton(UserInterface.textures.coinsPlusBttn2);
			plusBttn.scaleX = 0.9;
			plusBttn.y = minus10Bttn.y;
			plusBttn.x = plus10Bttn.x - plusBttn.width - 3;*/
			
			
			plusBttn = new Button( {
				caption:'+',
				width:45,
				height:28,
				borderColor:[0xfaed73,0xcb6b1e],
				fontColor:0xFFFFFF,
				fontBorderColor:0x6e411e,
				bevelColor:[0xfaed73, 0x9f7953],
				bgColor:[0xfed031,0xf8ac1b],
				fontSize:32,
				radius:12
			});
			
			minusBttn = new Button( {
				caption:'-',
				width:45,
				height:28,
				borderColor:[0xfaed73,0xcb6b1e],
				fontColor:0xFFFFFF,
				fontBorderColor:0x6e411e,
				bevelColor:[0xfaed73, 0x9f7953],
				bgColor:[0xfed031,0xf8ac1b],
				fontSize:32,
				radius:12
			});
						
			plusBttn.x = back.x + 163;
			plusBttn.y = back.y + 6;
			bodyContainer.addChild(plusBttn);
			minusBttn.x = back.x + 53;
			minusBttn.y = back.y + 6;
			bodyContainer.addChild(minusBttn);
			
			// Plus10  Minus10
			//settings["caption"] = "+10";
			//settings["fontSize"] = 16;
			//plus10Bttn = new Button(settings);
			
			//plus10Bttn.textLabel.x -= 3;
			//plus10Bttn.textLabel.width += 8;
				
			//settings["caption"] = "-10";
			//minus10Bttn = new Button(settings);
			
			
			plus10Bttn = new Button( {
				caption:'+10',
				width:45,
				height:28,
				borderColor:[0xfaed73,0xcb6b1e],
				fontColor:0xFFFFFF,
				fontBorderColor:0x6e411e,
				bevelColor:[0xfaed73, 0x9f7953],
				bgColor:[0xfed031,0xf8ac1b],
				fontSize:32,
				radius:12
			});
			
			minus10Bttn = new Button( {
				caption:'-10',
				width:45,
				height:28,
				borderColor:[0xfaed73,0xcb6b1e],
				fontColor:0xFFFFFF,
				fontBorderColor:0x6e411e,
				bevelColor:[0xfaed73, 0x9f7953],
				bgColor:[0xfed031,0xf8ac1b],
				fontSize:32,
				radius:12
			});
			
			plus10Bttn.x = back.x + 212;
			plus10Bttn.y = back.y + 6;
			bodyContainer.addChild(plus10Bttn);
			minus10Bttn.x = back.x + 4;
			minus10Bttn.y = back.y + 6;
			bodyContainer.addChild(minus10Bttn);
			
			//plus10Bttn.visible = false;
			//minus10Bttn.visible = false;
			
			minusBttn.state = Button.DISABLED;
			minus10Bttn.state = Button.DISABLED;
			
			plusBttn.addEventListener(MouseEvent.CLICK, onPlusEvent);
			minusBttn.addEventListener(MouseEvent.CLICK, onMinusEvent);
			plus10Bttn.addEventListener(MouseEvent.CLICK, onPlus10Event);
			minus10Bttn.addEventListener(MouseEvent.CLICK, onMinus10Event);
		}
		
		public function drawBttns():void {
			
			//Кнопка "flash:1382952380277"
			priceBttn = new Button( {
				caption:Locale.__e("flash:1382952380277"),
				fontSize:30,
				width:150,
				height:45
			});
			bodyContainer.addChild(priceBttn);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = settings.height - priceBttn.height - 17;
			priceBttn.addEventListener(MouseEvent.CLICK, onSellEvent);
		}
		
		private function onSellEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			priceBttn.state = Button.DISABLED;
			var X:int = this.x + e.currentTarget.x + e.currentTarget.width - 20;
			var Y:int = this.y + e.currentTarget.y - e.currentTarget.height + 80;
			
			var count:int = int(countCalc.text);
			
			App.user.stock.sell(item.sID, count, onSellComplete);
			
			sellPrice.text = String(price);
		}
		
		private function onSellComplete():void
		{
			var icon:Bitmap	= new Bitmap(UserInterface.textures.goldenPearl);
				icon.smoothing = true;
				
			icon.x = App.self.windowContainer.mouseX - priceBttn.mouseX + priceBttn.width/2;
			icon.y = App.self.windowContainer.mouseY - priceBttn.mouseY + priceBttn.height/2;
			App.self.windowContainer.addChild(icon);
			
			TweenLite.to(icon, 0.8, { x:6, y:4, onComplete:function():void {
				App.self.windowContainer.removeChild(icon);
				icon = null;
				//window.animalEnergy.glowing();
			}});
			
			countCalc.text = "1";
			if (App.user.stock.count(item.ID) == 0){
				this.close();
				return;
			};
			countOnStock.text = String(App.user.stock.count(item.ID) - 1);
			priceBttn.state = Button.NORMAL;
		}
			
		private function onOverEvent(e:MouseEvent):void {
			if (minus10Bttn != null) {
				//	minus10Bttn.visible = true;
				//	plus10Bttn.visible = true;
			}
		}
		private function onOutEvent(e:MouseEvent):void {
			if (minus10Bttn != null) {
				//	minus10Bttn.visible = false;
				//	plus10Bttn.visible = false;
			}
		}
		
		private function onPlusEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var count:int = int(countCalc.text) + 1;
			if (count > item.count) {
				count = item.count;
			}
			
			countOnStock.text = int(countOnStock.text) > 0?String(int(countOnStock.text) - 1):"0";
			var instock:int = App.user.stock.data[settings.sID];
			
			countCalc.text = String(count);
			sellPrice.text = String(count * price);
			if (count >= instock) {
				plusBttn.state = Button.DISABLED;
				plus10Bttn.state = Button.DISABLED;
			}
			if(count > 1){
				minusBttn.state = Button.NORMAL;
				minus10Bttn.state = Button.NORMAL;
			}
		}
		
		private function onMinusEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var count:int = int(countCalc.text) - 1;
			if (count < 1) {
				count = 1;
			}
			
			var instock:int = App.user.stock.data[settings.sID];
			countOnStock.text = int(countOnStock.text) < instock?String(int(countOnStock.text) + 1):String(instock);
			
			countCalc.text = String(count);	
			sellPrice.text = String(count * price);
			if (count < 2) {
				minusBttn.state = Button.DISABLED;
				minus10Bttn.state = Button.DISABLED;
			}
			if (count < instock) {
				plusBttn.state = Button.NORMAL;
				plus10Bttn.state = Button.NORMAL;
			}
		}
		
		private function onPlus10Event(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var count:int = int(countCalc.text);
			
			var instock:int = App.user.stock.data[settings.sID] - count;
			var toCounter:int = 0;
			if (instock - 10 >= 0)
				toCounter = 10;
			else
				toCounter = instock;
				
			instock -= toCounter;
			
			countOnStock.text = String(instock);
			
			count += toCounter;
			
			countCalc.text = String(count);
			sellPrice.text = String(count * price);
			
			if (count >= App.user.stock.data[settings.sID]) {
				plusBttn.state = Button.DISABLED;
				plus10Bttn.state = Button.DISABLED;
			}
			if(count > 1){
				minusBttn.state = Button.NORMAL;
				minus10Bttn.state = Button.NORMAL;
			}
		}
		
		private function onMinus10Event(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var count:int = int(countCalc.text) - 10;
			if (count < 1) {
				count = 1;
			}
			
			var instock:int = App.user.stock.data[settings.sID];
			countOnStock.text = int(countOnStock.text) + 10 < instock ? String(int(countOnStock.text) + 10) : String(instock-1);
			
			countCalc.text = String(count);	
			sellPrice.text = String(count * price);
			
			if (count < 2) {
				minusBttn.state = Button.DISABLED;
				minus10Bttn.state = Button.DISABLED;
			}
			if (count < App.user.stock.data[settings.sID]) {
				plusBttn.state = Button.NORMAL;
				plus10Bttn.state = Button.NORMAL;
			}
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