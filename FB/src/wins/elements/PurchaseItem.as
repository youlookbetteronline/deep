package wins.elements
{
	
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import com.greensock.*;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import units.Techno;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class PurchaseItem extends Sprite
	{
		
		public var callback:Function;
		public var background:Bitmap;
		public var title:TextField;
		public var sID:int;
		public var bitmap:Bitmap;
		public var sprite:LayerX;
		public var coinsBttn:MoneyButton;
		public var banksBttn:MoneyButton;
		public var selectBttn:Button;
		public var moneyType:String;
		public var window:*;
		public var _state:uint = 1;
		public var doGlow:Boolean = false;
		public var noShine:Boolean = false;
		public var bgWidth:int = 153;
		public var itemHeight:int = 0;
		public var itemWidth:int = 0;
		public var iconScale:Number = 1;
		
		protected var object:Object;
		protected var price:int;
		
		private var id:uint;
		private var dY:int = -10;
		private var preloader:Preloader = new Preloader();
		private var underIcon:Bitmap;
		private var objIcon:Object;
		private var drawDesc:Boolean = false;
		private var noTitle:Boolean = false;
		private var noDesc:Boolean = false;
		private var shineType:String;
		private var shine:Bitmap;
		private var circle:Shape;
		
		public function PurchaseItem(sID:int, callback:Function, window:*, id:uint, doGlow:Boolean = false, noTitle:Boolean = false, noDesc:Boolean = false, shineType:String = "default", itemHeight:uint = 250, itemWidth:uint = 153, iconScale:Number = 1, noShine:Boolean = false)
		{
			this.id = id;
			this.sID = sID;
			this.callback = callback;
			this.window = window;
			this.doGlow = doGlow;
			this.noTitle = noTitle;
			this.noDesc = noDesc;
			this.shineType = shineType;
			this.itemHeight = itemHeight;
			this.itemWidth = itemWidth;
			this.bgWidth = itemWidth;
			this.iconScale = iconScale;
			background = new Bitmap(new BitmapData(itemWidth, itemHeight));
			
			object = App.data.storage[sID];
			
			var backgroundShape:Shape = new Shape();
			backgroundShape.graphics.beginFill(0xe6b685);
			backgroundShape.graphics.drawCircle(60, 60, 60);
			backgroundShape.graphics.endFill();
			
			shine = new Bitmap(new BitmapData(120, 120, true, 0));
			shine.bitmapData.draw(backgroundShape);
			shine.x = (background.width - shine.width) / 2;
			shine.y = (background.height - shine.height) / 2;
			sprite = new LayerX;
			sprite.addChild(shine);
			addChild(sprite);
			bitmap = new Bitmap(null, "auto", true);
			bitmap.smoothing = true;
			sprite.addChild(bitmap);
			sprite.tip = function():Object
			{
				return {title: object.title, text: object.description};
			}
			
			addChild(preloader);
			preloader.scaleX = preloader.scaleY = 0.67;
			preloader.x = (background.width) / 2;
			preloader.y = (background.height) / 2 - 8;
			
			if (object.hasOwnProperty('price')) price = object.price[Stock.FANT];
			else
			{
				drawDesc = true;
				var needEfir:int = (Stock.efirLimit - App.user.stock.count(Stock.FANTASY));
				if (needEfir > 0) price = Math.ceil(needEfir / 30);
				else price = 0;
					//price = ;
			}
			
			if (!noTitle)
			{
				title = Window.drawText(object.title, {multiline: true, autoSize: "left", textAlign: "center", 
					//textLeading: -10,
					fontSize: 22, color: 0xffffff,//0xfff7fc,
					borderColor: 0x832e14,//0x9b1356
					letterSpacing: 1});
				title.height = title.textHeight;
				title.width = background.width - 40;
				title.wordWrap = true;
				title.y = shine.y - title.textHeight - 14;
				
				title.x = (background.width - title.width) / 2;
				addChild(title);
			}
			
			if (window.settings.listType == "Hut") drawSelectBttn();
			else if (price == 0) 
				drawStockFull();
			else if (object.hasOwnProperty('socialprice') && object.socialprice.hasOwnProperty(App.social))
				drawSocialPriceBttn();
			else drawMoneyBttn();

			
			objIcon = App.data.storage[object.out];
			
			if (!drawDesc && !noDesc)
			{
				if (App.data.storage[sID].view == 'slave')
				{
					objIcon = App.data.storage[App.data.storage[App.user.worldID].techno[0]];
					Load.loading(Config.getIcon(objIcon.type, objIcon.preview), onLoadOut);
				}
				else if (App.data.storage[sID].type == 'Vip')
				{
					drawDescription(object.title);
				}
				else if (App.data.storage[sID].type == 'Firework')
				{
					//
				}
				else
				{
					Load.loading(Config.getIcon(objIcon.type, objIcon.preview), onLoadOut);
				}
			}
			else if (drawDesc)
				drawDescription();
			/*else if (noDesc && !noTitle)
			   title.y = background.y + 5;*/
			
			Load.loading(Config.getIcon(object.type, object.preview), onLoad);
			
			if (App.data.storage[sID].type == 'Luckybag')
			{
				Load.loading(Config.getIcon(object.type, object.preview), onLoadOut);
				drawMoneyBttn();
			}
			
			if (doGlow) glowing();
		}
		
		
		
		protected function glowing():void
		{
			//customGlowing(background, glowing);
			if (coinsBttn)
			{
				customGlowing(coinsBttn, glowing);
			}
			if (banksBttn)
			{
				customGlowing(banksBttn, glowing);
			}
		}
		
		private function customGlowing(target:*, callback:Function = null):void
		{
			TweenMax.to(target, 1, {glowFilter: {color: 0xFFFF00, alpha: 0.8, strength: 7, blurX: 12, blurY: 12}, onComplete: function():void
			{
				TweenMax.to(target, 0.8, {glowFilter: {color: 0xFFFF00, alpha: 0.6, strength: 7, blurX: 6, blurY: 6}, onComplete: function():void
				{
					if (callback != null)
					{
						callback();
					}
				}});
			}});
		}
		
		private function drawStockFull():void
		{
			var itemDesc:TextField = Window.drawText('', {multiline: true, autoSize: "center", textAlign: "center", fontSize: 22, color: Window.getTextColor(object.out).color, borderColor: Window.getTextColor(object.out).borderColor});
			itemDesc.wordWrap = true;
			itemDesc.height = itemDesc.textHeight;
			itemDesc.width = itemDesc.textWidth + 60;
			
			itemDesc.x = (background.width - itemDesc.width) / 2;
			itemDesc.y = background.height - itemDesc.height - 5;
			addChild(itemDesc);
		}
		
		protected function drawDescription(Desc:String = null):void
		{
			var itemDesc:TextField = Window.drawText(Desc || object.description, {multiline: true, color: 0xf9f9fb, borderColor: 0x853016, autoSize: "center", textAlign: "center", fontSize: 22, color: Window.getTextColor(object.out).color, borderColor: Window.getTextColor(object.out).borderColor});
			itemDesc.wordWrap = true;
			itemDesc.height = itemDesc.textHeight;
			itemDesc.width = background.width - 46;
			
			itemDesc.x = (background.width - itemDesc.width) / 2;
			itemDesc.y = shine.y - itemDesc.height - 14;
			addChild(itemDesc);
		}
		
		protected function onLoadOut(data:*):void
		{
			var spEfir:Sprite = new Sprite();
			var iconEfir:Bitmap = new Bitmap(data.bitmapData);
			Size.size(iconEfir, 40, 40);
			iconEfir.filters = [new GlowFilter(0xffffff, 1, 4, 4, 8)];
			iconEfir.smoothing = true;
			var count:uint = object.count || object.capacity;
			
			var textSettings:Object = {
				
				text: '+' + count, multiline: true, color: 0xb5e8fd, borderColor: 0x20698a, autoSize: "left", textAlign: "left", fontSize: 28, color: Window.getTextColor(object.out).color, borderColor: Window.getTextColor(object.out).borderColor}
			
			if (shineType == "gold")
			{
				textSettings['color'] = 0xffda47;
				textSettings['borderColor'] = 0x7b270e;
			}
			
			var efirCount:TextField = Window.drawText(textSettings.text, textSettings);
			
			efirCount.wordWrap = true;
			efirCount.height = efirCount.textHeight;
			efirCount.width = efirCount.textWidth + 10;
			efirCount.x = iconEfir.x + iconEfir.width - 4;
			efirCount.y = iconEfir.y + (iconEfir.height - efirCount.textHeight) / 2;
			
			spEfir.addChild(iconEfir);
			spEfir.addChild(efirCount);
			
			spEfir.x = shine.x + shine.width - 70;
			spEfir.y = shine.y + shine.height - spEfir.height / 2 - 10;
			addChild(spEfir);
		}
		
		public function set state(value:uint):void
		{
			_state = value;
			if (_state)
			{
				if (banksBttn) banksBttn.state = Button.NORMAL;
				if (coinsBttn) coinsBttn.state = Button.NORMAL;
			}
			else
			{
				if (banksBttn) banksBttn.state = Button.DISABLED;
				if (coinsBttn) coinsBttn.state = Button.DISABLED;
			}
		}
		
		public function drawSocialPriceBttn():void 
		{
			if (object.hasOwnProperty('socialprice') && object.socialprice.hasOwnProperty(App.social)) 
			{
				var _count:Number = object.socialprice[App.social];
				
				var socialPriceButton:Button = new Button( {
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
				
				socialPriceButton.x = (itemWidth - socialPriceButton.width) / 2;
				socialPriceButton.y = shine.y + shine.height + 20;
				
				moneyType = 'energy';
			}else {
				if (object.coins > 0)
				{
					coinsBttn = new MoneyButton( {
						countText:String(object.coins),
						width:125,
						height:46,
						caption:Locale.__e("flash:1382952379984"),
						shadow:true,
						fontCountSize:23,
						fontSize:24,
						type:"gold"
					});
					
					coinsBttn.x = (this.width - coinsBttn.width) / 2;
					coinsBttn.y = 160;
					addChild(coinsBttn);
					moneyType = 'coins';
					coinsBttn.addEventListener(MouseEvent.CLICK, onBuyClick)
				}else
				{	
					banksBttn = new MoneyButton( {
						title:Locale.__e('flash:1382952379751') + ':',
						countText:String(object.price[Stock.FANT]),
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
					
					banksBttn.x = (itemWidth - banksBttn.width) / 2;
					banksBttn.y = shine.y + shine.height + 20;
					moneyType = 'banknotes';
					banksBttn.addEventListener(MouseEvent.CLICK, onBuyClick);
					addChild(banksBttn);
				}
			}
		}
		
		private function drawSelectBttn():void
		{
			selectBttn = new Button({width: 125, height: 40, fontSize: 24, bgColor: [0xfdb29f, 0xed7483], borderColor: [0xffffff, 0xffffff], bevelColor: [0xfeb19f, 0xe87383], fontColor: 0xffffff, fontBorderColor: 0x993a40, fontCountColor: 0xFFFFFF, fontCountBorder: 0x354321, fontBorderSize: 3, caption: Locale.__e("flash:1382952380066")});
			
			addChild(selectBttn);
			selectBttn.x = (this.width - selectBttn.width) / 2;
			selectBttn.y = 180;
			
			moneyType = 'coins';
			
			selectBttn.addEventListener(MouseEvent.CLICK, onSelectClick)
		}
		
		protected function drawMoneyBttn():void
		{
			if (object.coins > 0)
			{
				coinsBttn = new MoneyButton({countText: String(object.coins), width: 125, height: 46, caption: Locale.__e("flash:1382952379984"), shadow: true, fontCountSize: 23, fontSize: 24, type: "gold"});
				addChild(coinsBttn);
				coinsBttn.x = (this.width - coinsBttn.width) / 2;
				coinsBttn.y = 160;
				
				moneyType = 'coins';
				
				coinsBttn.addEventListener(MouseEvent.CLICK, onBuyClick)
			}
			else
			{
				banksBttn = new MoneyButton({title: Locale.__e('flash:1382952379751') + ':', countText: String(price), width: 132, height: 44, shadow: true, fontCountSize: 23, fontSize: 22, type: "green", radius: 18, fontBorderColor: 0x375bb0, fontCountBorder: 0x252273, iconScale: 0.65, fontCountSize: 36});
				addChild(banksBttn);
				
				banksBttn.x = (itemWidth - banksBttn.width) / 2;
				banksBttn.y = shine.y + shine.height + 20;
				
				moneyType = 'banknotes';
				
				banksBttn.addEventListener(MouseEvent.CLICK, onBuyClick)
			}
		}
		
		public function dispose():void
		{
			if (coinsBttn != null)
			{
				coinsBttn.removeEventListener(MouseEvent.CLICK, onBuyClick)
			}
			if (banksBttn != null)
			{
				banksBttn.removeEventListener(MouseEvent.CLICK, onBuyClick)
			}
			if (selectBttn != null)
			{
				selectBttn.removeEventListener(MouseEvent.CLICK, onSelectClick)
			}
			if (this.parent != null)
			{
				this.parent.removeChild(this);
			}
		}
		
		public function onSelectClick(e:MouseEvent):void
		{
			if (callback != null) callback(this.sID);
			window.close();
		}
		
		public function onBuyClick(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var sett:Object = null;
			if (User.inExpedition)
			{
				sett = {wID: App.user.worldID}
			}
			
			window.blokItems(false);
			
			if (App.data.storage[sID].view == 'cookie')
			{
				window.blokItems(true);
				App.user.stock.buy(App.data.storage[App.user.worldID].cookie[0], object.capacity, onBuyComplete);
			}
			else
			{
				if (App.data.storage[sID].type == 'Firework' || App.data.storage[sID].type == 'Luckybag'/*||App.data.storage[sID].type == 'Energy'*/)
				{
					App.user.stock.buy(sID, object.count, onBuyComplete, sett)
				}
				else
				{
					App.user.stock.pack(this.sID, onBuyComplete, function():void
					{
						window.blokItems(true);
					}, sett);
				}
			}
			
			window.close();
		}
		
		private function onSocialBuyClick(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var bObject:Object;
			
			if (App.social == 'FB') 
			{
				bObject = {
					id:		 	object.sID,
					type:		'Energy',
					callback: socialCallback
				};
			}else if (App.social == 'GN') 
			{
				bObject = {
					itemId:		object.type+"_" + object.sID,
					price:		int(object.socialprice[App.social]),
					amount:		1,
					itemName:	object.title,
					callback:	socialCallback
				};
			}else if (App.social == 'MX') 
			{
				bObject = {
					money: 		object.type,
					type:		'item',
					item:		object.type+"_"+object.sID,
					votes:		int(object.socialprice[App.social]),
					sid:		object.sID,
					count:		1,
					title:		object.title,
					description:object.description,
					tnidx:		App.user.id + App.time + '-' + object.type + "_" + object.sID,
					callback:	socialCallback
				}
			}else 
			{
				bObject = {
					money: 		'Energy',
					type:		'item',
					item:		'energy'+"_"+object.sID,
					votes:		int(object.socialprice[App.social]),
					sid:		object.sID,
					count:		1,
					title:		Locale.__e('flash:1396521604876'),
					description:Locale.__e('flash:1393581986914'),
					icon:		Config.getIcon(object.type, object.preview),
					tnidx:		App.user.id + App.time + '-' + 'energy' + "_" + object.sID,
					callback:	socialCallback
				}
			}
			ExternalApi.apiBalanceEvent(bObject);
		}
		
		public function socialCallback():void 
		{
			App.user.stock.add(object.out, object.count);
			Window.closeAll();
			new SimpleWindow( {
				hasTitle:true,
				height:300,
				title:Locale.__e("flash:1382952379735"),
				text:Locale.__e("flash:1382952379990")
			}).show();
		}
		
		protected function onBuyComplete(sID:uint, rez:Object = null):void
		{
			window.blokItems(false);
			
			if (callback != null) callback(sID);
			if (window.settings && window.settings.closeAfterBuy) window.close();
			var currentTarget:Button;
			if (banksBttn) currentTarget = banksBttn;
			if (coinsBttn) currentTarget = coinsBttn;
			
			var X:Number = App.self.mouseX - currentTarget.mouseX + currentTarget.width / 2;
			var Y:Number = App.self.mouseY - currentTarget.mouseY;
			
			Hints.plus(this.sID, 1, new Point(X, Y), true, App.self.tipsContainer);
			
			for (var _sid:* in object.price)
				Hints.minus(_sid, object.price[_sid], new Point(X, Y + 20), false, App.self.tipsContainer);
			
			if (sID != Techno.TECHNO)
			{
				flyMaterial();
				window.blokItems(true);
			}
			
			window.removeItems();
			window.createItems();
			window.contentChange();
		}
		
		public function onLoad(data:*):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			Size.size(bitmap, shine.width - 10, shine.height - 10);
			
			bitmap.x = (background.width - bitmap.width) / 2;
			bitmap.y = (background.height - bitmap.height) / 2;
		}
		
		private function flyMaterial():void
		{
			var _sID:uint = sID;
			
			if (App.data.storage[sID].type == 'Energy' && (App.data.storage[sID].view == 'slave3' || App.data.storage[sID].view == 'slave2'))
			{
				return;
			}
			
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Energy' && !App.data.storage[sID].inguest)
			{
				_sID = Stock.FANTASY;
			}
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Energy' && App.data.storage[sID].inguest == 1)
			{
				_sID = Stock.GUESTFANTASY;
			}
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Feed' && !App.data.storage[sID].inguest)
			{
				_sID = App.data.storage[sID].out;
			}
			
			var item:BonusItem = new BonusItem(sID, 0);
			
			var point:Point = Window.localToGlobal(bitmap);
			item.cashMove(point, App.self.windowContainer);
		}
	}
}