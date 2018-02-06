package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	public class SaleBoosterWindow extends Window
	{
		private var icon:Bitmap;
		private var preloader:Preloader = new Preloader();
		
		private var priceBttn:Button;
		private var titleField:TextField;
		private var descLabel:TextField;
		private var contIcon:LayerX;
		public var action:Object;
		public static var boosterWindowIsNotBusy:Boolean = true;
		
		private var texts:Object = {
			43: { 0: 'flash:1413192251710', 1: 'flash:1413192625775' },	// Энергия
			42: { 0: 'flash:1413192273749', 1: 'flash:1412866371989' },	// Опыт
			41: { 0: 'flash:1413192287727', 1: 'flash:1413192639034' },		// Монеты
			73: { 0: 'flash:1427789416558', 1: 'flash:1427789431447' }		// Макс Энергия
		}
		
		public function SaleBoosterWindow(settings:Object) 
		{
			settings["title"] = Locale.__e("flash:1396521604876");
			settings["width"] = 450;
			settings["height"] = 400;
			settings["hasPaginator"] = false;
			settings["background"] = 'questBacking';
			//action = {};
			action = (App.data.actions[settings.pID])?App.data.actions[settings.pID]:{};
			action['id'] = settings.pID;
			
			super(settings);
		}
		private var effect:Bitmap;
		override public function drawBody():void 
		{
			exit.y -= 20;
			exit.x += 10;
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -44, true, true);
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, 44, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, settings.height - 68, false, false, true, 1, 1);
			contIcon = new LayerX();
			effect = new Bitmap();
			bodyContainer.addChild(effect);
			
			Load.loading(Config.getImage('sales', 'ActionBackImg'), onLoadBack);
			var checkBack:Bitmap = new Bitmap(Window.textures.instCharBacking, 'auto', true);
			checkBack.x = (settings.width - checkBack.width) / 2;
			checkBack.y = 100;
			checkBack.visible = false;
			bodyContainer.addChild(checkBack);
			bodyContainer.addChild(contIcon);
			icon = new Bitmap();
			icon.x = checkBack.x + checkBack.width / 2;
			icon.y = checkBack.y + checkBack.height / 2;
			contIcon.addChild(icon);
			
			bodyContainer.addChild(preloader);
			preloader.x = checkBack.x + checkBack.width / 2;
			preloader.y = checkBack.y + checkBack.height / 2;
			
			var stripe:Bitmap = Window.backingShort(settings.width + 60, 'purpleRibbon');
			bodyContainer.addChild(stripe);
			stripe.x = (settings.width - stripe.width) / 2;
			stripe.y = 5;
			
			titleField = drawText(Locale.__e(texts[action.id]['0']), {
				fontSize:		28,
				color:			0xfdfdfd,
				borderColor:	0x6b3186,
				textAlign:		'center',
				width:			settings.width - 40
			});
			titleField.x = stripe.x + (stripe.width - titleField.width) / 2;
			titleField.y = stripe.y + (stripe.height - titleField.height) / 2 ;
			bodyContainer.addChild(titleField);
			
			
			var rrect:Sprite = new Sprite();
			 rrect.graphics.beginFill(0xedca94);
			 rrect.graphics.drawRoundRect(0,0,settings.width-60, 100,40);
			 rrect.graphics.endFill();
			 bodyContainer.addChild(rrect);
			rrect.alpha = .8;
			rrect.x = (settings.width - rrect.width) / 2;
			rrect.y = 240;
			
			descLabel = drawText(Locale.__e(texts[action.id]['1']), {
				fontSize:		26,
				color:			0xfdfdfd,
				borderColor:	0x794515,
				textAlign:		'center',
				width:			settings.width - 60,
				multiline:		true,
				wrap:			true
			});
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y =rrect.y + (rrect.height - descLabel.textHeight)/2;
			
			
			
			bodyContainer.addChild(descLabel);
			
				
			drawBttn();
			
			var sID:int = 0;
			for (var s:String in action.items) {
				sID = int(s);
				break;
			}
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoadIcon);
			contIcon.tip = function():Object { 
				return {
					title:App.data.storage[sID].title,
					text:App.data.storage[sID].description
				};
			};
		}
		
		private function onLoadBack(data:*):void 
		{
			//bodyContainer.removeChild(preloader2);
		effect.bitmapData = data.bitmapData;	
		effect.x = (settings.width - effect.width) / 2;
		effect.y = 50;	
		}
		
		private function onLoadIcon(data:*):void 
		{
			bodyContainer.removeChild(preloader);
			
			icon.bitmapData = data.bitmapData;
			icon.x += -icon.width / 2;
			icon.y += -icon.height / 2;
			
		}
		
		private function get offerTitle():String {
			var value:String = '';
			
			if (action.hasOwnProperty('items')) {
				for (var s:String in action.items) {
					if (App.data.storage[s].type == 'Vip')
						value = App.data.storage[s].title;
				}
			}
			
			return value;
		}
		
		private function drawBttn():void 
		{
			var bttnSettings:Object = {
				fontSize:36,
				width:186,
				height:52 + 10 * int(App.isSocial('MX'))
				//hasDotes:true
			};
			
			var text:String;
			switch(App.self.flashVars.social) {
				
				case "VK":
				case "DM":
					text = 'flash:1382952379972';
					break;
				case "OK":
					text = '%d ОК';
					break;	
				case "MM":
					text = '[%d мэйлик|%d мэйлика|%d мэйликов]';
					break;
				case "NK":
					text = '%d €GB'; 
				break;	
				case "PL":				
				case "AI":
					text = '%d';
					break;
				case "YB":
					text = 'flash:1421404546875'; 
					bttnSettings.fontSize = 20;
				case "MX":
					text = '%d pt.'
					break;
				case "FS":
					text = '%d ФМ'; 
				break;
				case "FB":
						var price:Number = action.price[App.self.flashVars.social];
						price = price * App.network.currency.usd_exchange_inverse;
						price = int(price * 100) / 100;
						text = price + ' ' + App.network.currency.user_currency;
					break;
			}
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
			
			var priceVal:String = '';
			priceVal = action.price[App.self.flashVars.social];
				
			bttnSettings['caption'] = Locale.__e(text, [int(priceVal)]);
			priceBttn = new Button(bttnSettings);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = (settings.height - 60);
			bodyContainer.addChild(priceBttn);
			priceBttn.state = Button.DISABLED;
			//priceBttn.visible = false;
			setTimeout(function():void { priceBttn.state = Button.NORMAL; }, 2000);
			if(App.isSocial('MX')){
				var mixiLogo:Bitmap =   new Bitmap(Window.textures.mixieLogo);
				priceBttn.topLayer.addChild(mixiLogo);
				priceBttn.fitTextInWidth(priceBttn.width - (mixiLogo.width + 10));
				priceBttn.textLabel.width = priceBttn.textLabel.textWidth + 5;
				priceBttn.textLabel.x = (priceBttn.width - (priceBttn.textLabel.width + mixiLogo.width + 5)) / 2 + mixiLogo.width + 5;
				mixiLogo.x = priceBttn.textLabel.x - mixiLogo.width - 5 ;
				mixiLogo.y = (priceBttn.height - mixiLogo.height) / 2;
			}
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		}
		
		private function redrawWindowHeight(_height:Number):void {
			settings.height = _height;
			drawBackground();
		}
		
		private function buyEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			//onBuyComplete();
			switch(App.social) {
				case 'PL':
					//if(!App.user.stock.check(Stock.FANT, action.price[App.social])){
						//close();
						
						//break;
					//}
				/*case 'YB':
					if(App.user.stock.take(Stock.FANT, action.price[App.social])){
						Post.send({
							ctr:'Promo',
							act:'buy',
							uID:App.user.id,
							pID:action.id,
							ext:App.social
						},function(error:*, data:*, params:*):void {
							onBuyComplete();
						});
					}else {
						close();
					}*/
					break;
				default:
					var object:Object;
					if (App.social == 'FB') {
						ExternalApi.apiNormalScreenEvent();
						object = {
							id:		 		action.id,
							type:			'promo',
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback:		onBuyComplete
						};
					}else{
						object = {
							count:			1,
							money:			'promo',
							type:			'item',
							item:			'promo_'+action.id,
							votes:			action.price[App.self.flashVars.social],
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback: 		onBuyComplete
						}
					}
					ExternalApi.apiPromoEvent(object);
					break;
			}
		}
		
		private function onBuyComplete(e:* = null):void 
		{
			priceBttn.state = Button.DISABLED;
			
			// Преобразовать количество бустеров во время и запускаем их
			App.user.stock.addAll(action.items);
			App.user.activeBooster();
			App.user.boosterLimit = 0;
			
			close();
		}
		
		override public function close(e:MouseEvent = null):void {
			//App.user.boosterLimit = 0;
			boosterWindowIsNotBusy = true;
			super.close(e);
		}
	}

}