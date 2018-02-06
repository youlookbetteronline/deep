package wins.elements 
{

	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneySmallButton;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Factory;
	import units.Techno;
	import units.Unit;
	import wins.SimpleWindow;
	import wins.Window;
	import core.Load;
	import com.greensock.*;

	public class LuckybagPurchaseItem extends PurchaseItem
	{ 		
		private var id:uint;
		private var dY:int = -10;
		private var underIcon:Bitmap;
		private var objIcon:Object;
		private var drawDesc:Boolean = false;
		private var noTitle:Boolean = false;
		private var noDesc:Boolean = false;
		private var shineType:String;
		private var shine:Bitmap;
		private var circle:Shape;
		private var coinsBttnNew:MoneySmallButton;
		private var efirTitle:TextField = new TextField();
		private var presentIcon:Bitmap = new Bitmap();
		private var priceBttnJapan:Button;
		
		public function LuckybagPurchaseItem(sID:int, callback:Function, window:*, id:uint, doGlow:Boolean = false, noTitle:Boolean = false, noDesc:Boolean = false, shineType:String = "default",itemHeight:uint =250,itemWidth:uint = 153, iconScale:Number = 1)
		{	
			this.background = Window.backing(itemWidth, itemHeight, 15, 'itemBacking');
			super(sID, callback, window, id, doGlow, noTitle, noDesc, shineType, itemHeight, itemWidth, iconScale, true);
		}
		
		private function customGlowing(target:*, callback:Function = null):void 
		{
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
				}});	
			}});
		}
		
		override protected function drawDescription(Desc:String = null):void 
		{
			return;
		}
		
		override protected function onLoadOut(data:*):void 
		{
			var spEfir:Sprite = new Sprite();
			var iconEfir:Bitmap = new Bitmap(data.bitmapData);
			iconEfir.scaleX = iconEfir.scaleY ;
			iconEfir.smoothing = true;
			var count:uint = object.count || object.capacity;
			
			var textSettings:Object = {
				
				text:'x' + count,
				multiline:true,
				color:0xffffff,
				borderColor:0x7f4a28,
				autoSize:"left",
				textAlign:"left",
				fontSize:36
			}
			
			var efirCount:TextField = Window.drawText(textSettings.text, textSettings);			
			
			if (iconEfir.width > 40) 
			{
				iconEfir.width = 40;
				iconEfir.scaleY = iconEfir.scaleX;
			}
			efirCount.wordWrap = true;
			efirCount.height = efirCount.textHeight;
			efirCount.width = efirCount.textWidth + 10;
			efirCount.x = iconEfir.x + iconEfir.width + 10;
			
			//spEfir.addChild(iconEfir);			
			spEfir.addChild(efirCount);
			
			spEfir.x = (background.width - spEfir.width) / 2;
			spEfir.y = 160;
			addChild(spEfir);
			
			efirTitle = Window.drawText((object.title), {
				width: 165,
				fontSize:28,
				color:0xffffff,
				borderColor:0x753c1e,
				autoSize:"center",
				multiline:true,
				wrap:true,
				textAlign:"center"
			});
			
			addChild(efirTitle);
			efirTitle.x = this.background.x + this.background.width / 2 - efirTitle.width / 2;
			efirTitle.y = 5;
			
			//sprite.y += 15;	
			
			presentIcon = new Bitmap(UserInterface.textures.giftLuckyBag);	
			addChild(presentIcon);
			presentIcon.x = spEfir.x + 8;
			presentIcon.y = spEfir.y;
		}		
		
		override protected function drawMoneyBttn():void
		{
			//Вытаскиваем цену
			if (App.data.storage[sID].type == 'Luckybag') {
				for (var i:* in object.socialprice) {
					if (i == App.SOCIAL) 
					{
						price = App.data.storage[sID].socialprice[i];				
					}
				}
			}	
			
			//Настройки кнопки покупки под каждую японскую сеть и дефолтная
			var text:String = new String();
			
			if (App.isSocial('AI')) 			
			{				
				text = ' aコイン';
				priceBttnJapan = new Button({
					fontSize:20,
					width:125,
					height:45,
					caption:'' + String(price) + text
				});	
				
			}else if (App.isSocial('YB')) 
			{
				text = ' モバコイン';
				priceBttnJapan = new Button({
					fontSize:20,
					width:150,
					height:45,
					caption:'' + String(price) + text
				});	
				
			}else if (App.isSocial('MX'))
			{
				text = ' pt.';
				priceBttnJapan = new Button({
					fontSize:20,
					width:150,
					height:45,
					caption:'' + String(price) + text
				});	
				
				var mixiLogo:Bitmap = new Bitmap(Window.textures.mixieLogo);
				mixiLogo.scaleX = mixiLogo.scaleY = 0.7;
				priceBttnJapan.topLayer.addChild(mixiLogo);
				priceBttnJapan.fitTextInWidth(priceBttnJapan.width - (mixiLogo.width + 10));
				priceBttnJapan.textLabel.width = priceBttnJapan.textLabel.textWidth + 5;
				priceBttnJapan.textLabel.x = (priceBttnJapan.width - (priceBttnJapan.textLabel.width + mixiLogo.width + 5)) / 2 + mixiLogo.width + 5;
				mixiLogo.x = priceBttnJapan.textLabel.x - mixiLogo.width - 5 ;
				mixiLogo.y = (priceBttnJapan.height - mixiLogo.height) / 2;
			}else if (App.isSocial('VK','DM')){				
				text = 'голосов';
				priceBttnJapan = new Button({
					fontSize:28,
					width:125,
					height:45,
					caption:'' + String(price) + ' ' + text
				});	
			}
			
			addChild(priceBttnJapan);			
			priceBttnJapan.x = this.background.x + this.background.width / 2 - priceBttnJapan.width / 2;
			priceBttnJapan.y = 195;	
			priceBttnJapan.addEventListener(MouseEvent.CLICK, buyLuckyEvent);
		}
		
		public function buyLuckyEvent(e:MouseEvent):void
		{			
			if (e.currentTarget.mode == Button.DISABLED) return;
			priceBttnJapan = e.currentTarget as Button;			
			
			var object:Object;			
			
			object = {
				count:			1,
				money:			'promo',
				type:			'item',
				item:			'luckybag_' + sID,
				votes:			price,
				title: 			Locale.__e('flash:1382952379793'),//Акция
				description: 	Locale.__e('flash:1382952380239'),//Уникальное предложение
				callback: 		onBuyLuckyComplete
			}
			
			priceBttnJapan.mode = Button.DISABLED;
			ExternalApi.apiPromoEvent(object);			
		}
		
		public function onBuyLuckyComplete(e:* = null):void 
		{
			priceBttnJapan.state = Button.DISABLED;
			
			window.close();
			
			App.user.stock.add(sID, 1);
			
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				title:Locale.__e('flash:1393579648825'),
				text:Locale.__e('flash:1382952379990')
			}).show();

		}
		
		override protected function onBuyComplete(sID:uint, rez:Object = null):void
		{
			window.blokItems(false);
			
			if (callback != null) callback(sID);
			if (window.settings.closeAfterBuy)	window.close();
			
			if (Techno.TECHNO == sID || Techno.NORD_TECHNO == sID || Techno.STORM_TECHNO == sID) {
				addChildrens(sID, rez.ids);
			}else{
				var currentTarget:Button;
				if (coinsBttnNew) currentTarget = coinsBttnNew;
				
				var X:Number = App.self.mouseX - currentTarget.mouseX + currentTarget.width / 2;
				var Y:Number = App.self.mouseY - currentTarget.mouseY;				
				Hints.plus(this.sID, 1, new Point(X, Y), true, App.self.tipsContainer);	
				
				if (App.data.storage[sID].type == 'Luckybag') 
				{
					for (var i:* in object.socialprice) {
						if (i == App.SOCIAL) 
						{
							price = App.data.storage[sID].socialprice[i];				
						}
						Hints.minus(Stock.FANT, price, new Point(X, Y), false, App.self.tipsContainer);					
					}
				}
				
				/*for (var _sid:* in object.price) 
				{					
					Hints.minus(_sid, object.price[_sid], new Point(X, Y), false, App.self.tipsContainer);
				}*/
			}
			
			flyMaterial();
			window.blokItems(true);
			
			window.removeItems();
			window.createItems();
			window.contentChange();
		}
		
		private function addChildrens(_sid:uint, ids:Object):void 
		{
			var rel:Object = { };
			rel[Factory.TECHNO_FACTORY] = _sid;
			var position:Object = App.map.heroPosition;
			for (var i:* in ids){
				var unit:Unit = Unit.add( { sid:_sid, id:ids[i], x:position.x, z:position.z, rel:rel } );
					(unit as Techno).born({capacity:App.time + App.data.options['SlaveBoughtTime']});
			}
		}
		
		private function flyMaterial():void
		{
			var _sID:uint = sID;
			
			if (App.data.storage[sID].type == 'Energy' && (App.data.storage[sID].view == 'slave3' || App.data.storage[sID].view == 'slave2')) 
			{
				return;
			}
			
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Energy' && !App.data.storage[sID].inguest){
				_sID = Stock.FANTASY;
			}
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Energy' && App.data.storage[sID].inguest == 1){
				_sID = Stock.GUESTFANTASY;
			}
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Feed' && !App.data.storage[sID].inguest){
				_sID = App.data.storage[sID].out;
			}
			
			var item:BonusItem = new BonusItem(sID, 0);			
			var point:Point = Window.localToGlobal(bitmap);
			item.cashMove(point, App.self.windowContainer);
		}
	}
}	