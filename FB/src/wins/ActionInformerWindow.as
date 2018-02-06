package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class ActionInformerWindow extends Window
	{
		private var icon:Bitmap;
		private var pID:uint;
		protected var action:Object;
		private var premiumItem:Object;
		private var descTextField:TextField;
		private var descTextFieldLow:TextField;
		private var descBg:Sprite;
		private var actionPic:Bitmap;
		private var contIcon:LayerX;
		protected var priceBttn:Button;
		private var price:Number;
		private var maska:Shape = new Shape();
		public var back:Shape = new Shape();
		public var saleCounter:Bitmap = new Bitmap();
		public var saleCounterContaner:Sprite;
		public var background2:Bitmap;
		
		private var preloader:Preloader = new Preloader();
		
		public function ActionInformerWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = { };
			}
			settings['width'] = 450;
			settings['height'] = 400;
			settings['title'] = Locale.__e('flash:1382952379793');
			settings['background'] = 'capsuleWindowBacking';
			settings['hasPaginator'] = false;
			settings['exitTexture'] = 'closeBttnMetal';
			settings['fontColor'] = '0xf3ff2c';
			settings['fontSize'] = 42;
			settings['fontBorderColor'] = 0xb05b15;
			settings['fontBorderSize'] = 2;
			
			pID = settings.pID;
			action = App.data.actions[pID];
			action['id'] = pID;
			
			for (var i:String in action.items) {
				premiumItem = App.data.storage[i];
			}
			
			var descPrms:Object = {
				color			:0x7f3d0e,
				borderColor		:0xffffff,
				width			:320,
				multiline		:true,
				wrap			:true,
				textAlign		:'center',
				fontSize		:26,
				textLeading		: -7
			}
			
			if (action.text1){
				descTextField = Window.drawText(action.text1, descPrms); 
				descPrms['fontSize'] = 22;
				descTextFieldLow = Window.drawText(action.text2, descPrms); 
			} else {
				//var textPart:String = premiumItem.description;
				descTextField = Window.drawText(premiumItem.title, descPrms); 
				descPrms['fontSize'] = 22;
				descTextFieldLow = Window.drawText(premiumItem.description, descPrms);  
			}
			settings['height'] += descTextFieldLow.textHeight;
			
			super(settings)
		}
		
		override public function drawBody():void 
		{	
			drawRibbon();
			titleLabel.y += 10;
			//titleBackingBmap.x -= 10;
			
			drawMirrowObjs('decSeaweed', settings.width + 57, - 57, settings.height - 177, true, true, false, 1, 1, layer);
			
			back.graphics.beginFill(0xf5da65, 1);
		    back.graphics.drawRect(0, 0, settings.width - 90, descTextFieldLow.textHeight + 15);
		    back.graphics.endFill();
		    back.x = (settings.width - back.width) / 2 ;
		    back.filters = [new BlurFilter(20, 0, 2)];
		    bodyContainer.addChild(back);
			
			var star3:Bitmap = new Bitmap(Window.textures.decStarRed);
			star3.x = -15;
			star3.y = -43;
			star3.smoothing = true;
			bodyContainer.addChild(star3);
			drawItem();
			
			var fish2:Bitmap = new Bitmap(Window.textures.decFish2);
			fish2.x = settings.width - 25;
			fish2.y = settings.height - 150;
			layer.addChildAt(fish2,0);
			
			drawActionDescription();
			
			background2 = backing2(370, 230, 45, 'calImgUp', 'calImgBot');
			background2.x = (settings.width - background2.width) / 2;
			background2.y = descTextField.y + descTextField.textHeight + 15;
			
		    back.y = background2.y + background2.height + 10;
			
			bodyContainer.addChild(descTextFieldLow);
			//descTextFieldLow.x = back.x + (back.width - descTextFieldLow.textWidth) / 2;
			descTextFieldLow.x = (settings.width - descTextFieldLow.width) / 2;
			descTextFieldLow.y = back.y + (back.height - descTextFieldLow.height) / 2;
			//descTextFieldLow.border = true;
			
			bodyContainer.addChild(background2);
			
			
			bodyContainer.addChild(preloader);
			preloader.x = settings.width/2;
			preloader.y = 180;
			
			if (action.hasOwnProperty('picture'))
			{
				var pic:Bitmap = new Bitmap();
				bodyContainer.addChild(maska);
				bodyContainer.addChild(pic);
				
				Load.loading( Config.getImage('actions', action.picture, 'jpg'), function(data:*):void {
					pic.bitmapData = data.bitmapData;
					Size.size(pic, background2.width, background2.width);
					pic.smoothing = true;
					maska.graphics.beginFill(0xFFFFFF, 1);
					maska.graphics.drawRoundRect(0, 0, pic.width-4, pic.height-25, 40, 40);
					maska.graphics.endFill();
					
					pic.x = background2.x + 2;
					pic.y = background2.y + (background2.height - pic.height) / 2 + 12;
					maska.x = pic.x;
					maska.y = pic.y;
					
					maska.cacheAsBitmap = true;
					pic.mask = maska;
					if (preloader && preloader.parent)
						preloader.parent.removeChild(preloader);
					//bodyContainer.removeChild(preloader);
					preloader = null;
				});
			}
			
			if(action.rate && action.rate != '')
				drawSaleCounter();
			//drawRibbon();	
			drawPriceButton();			
			//drawActionPic();			
			exit.y -= 25;
			//checkAction();	
		}
		
		private function drawSaleCounter():void 
		{
			var itemForSale:int = action.rate * action.duration;
			var timeForSale:int = action.duration * 3600;
			//var timeStart:int = action.beginTime;
			var passedTime:int = action.time - App.time;
			//var timeLeft:int = timeForSale - passedTime;
			
			var saleItem:int = 0;
			var leftIrem:int = 0;
			
			saleItem = Math.abs((itemForSale * passedTime) / timeForSale);
			leftIrem = itemForSale - saleItem;
			
			saleCounterContaner = new Sprite();
			bodyContainer.addChild(saleCounterContaner);
			saleCounter = Window.backingShort(300, 'ribbonSaleCounter', true, 1);
			saleCounter.scaleX = saleCounter.scaleY = 0.8;
			saleCounterContaner.addChild(saleCounter);
			saleCounterContaner.x = (settings.width - saleCounter.width) / 2;
			saleCounterContaner.y = 227;
			
			var countText1:TextField = Window.drawText(Locale.__e("flash:1435928558888") + ' ' + saleItem, {//App.data.actions[action.id].text1  поменять
				color: 0x6d350d, border: true, textAlign: "center", autoSize: "center", fontSize: 28, borderColor: 0xffffff, borderSize:2, textLeading: -6, multiline: true});
			//countText1.wordWrap = true;
			countText1.width = settings.width - 80;
			countText1.x = (saleCounterContaner.width - countText1.width)/2;
			countText1.y = 0;
			
			var countText2:TextField = Window.drawText(Locale.__e("flash:1393581955601") + ' ' + leftIrem, {//App.data.actions[action.id].text1  поменять
				color: 0x6d350d, border: true, textAlign: "center", autoSize: "center", fontSize: 28, borderColor: 0xffffff, borderSize:2, textLeading: -6, multiline: true});
			//countText2.wordWrap = true;
			countText2.width = settings.width - 80;
			countText2.x = (saleCounterContaner.width - countText2.width)/2;
			countText2.y = countText1.y + countText1.height - 5;
			
			saleCounterContaner.addChild(countText1);
			saleCounterContaner.addChild(countText2);
		}
		private function drawItem():void 
		{		
			contIcon = new LayerX();
			
			//bodyContainer.addChild(contIcon);
			icon = new Bitmap();
			icon.x = 65;
			icon.y = 115;
			contIcon.addChild(icon);
			
			bodyContainer.addChild(preloader);
			preloader.x = settings.width/2;
			preloader.y = icon.y + 70;
			
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
		
		private function onLoadIcon(data:*):void 
		{
			if(preloader)
				preloader.parent.removeChild(preloader);
			
			icon.bitmapData = data.bitmapData;
			icon.x += -icon.width / 2;
			icon.y += -icon.height / 2;			
		}
		
		protected function drawPriceButton():void 
		{			
			var text:String = '';
			price = action.price[App.self.flashVars.social];
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
				case "FS":
					text = '%d ФМ'; 
				break;
				case "HV":
					price = action.price[App.self.flashVars.social];
					price = int(price) / 100;
					text = '%d €';
					break;
				case "NK":
					text = '%d €GB';
					break;
				case "YN":
					text = '%d USD';
					break;
				case "AI":
					text = '%d aコイン';
					break;
				case "YB":
					text = 'flash:1421404546875'; 
					break;
				case "MX":
					text = '%d pt.'
					break;
				case "FB":
						price = action.price[App.self.flashVars.social];
						price = price * App.network.currency.usd_exchange_inverse;
						price = int(price * 100) / 100;
						text = price + ' ' + App.network.currency.user_currency;	
					break;
				default:
					text = '%d';
			}
			
			var bttnSettings:Object = {
				fontSize:28,
				width:186,
				height:52,
				hasDotes:false
			};
			
			if (App.isSocial('YB', 'AI')) 
			{
				bttnSettings.fontSize = 20;
			}
			
			bttnSettings['caption'] = Locale.__e(text, [price])
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = settings.height - priceBttn.height - 18;
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			
			if (Payments.byFants) {
				
				priceBttn.fant();
			}
			
			if(App.isSocial('MX')){
				var mixiLogo:Bitmap = new Bitmap(Window.textures.mixieLogo);
				priceBttn.topLayer.addChild(mixiLogo);
				priceBttn.fitTextInWidth(priceBttn.width - (mixiLogo.width + 10));
				priceBttn.textLabel.width = priceBttn.textLabel.textWidth + 5;
				priceBttn.textLabel.x = (priceBttn.width - (priceBttn.textLabel.width + mixiLogo.width + 5)) / 2 + mixiLogo.width + 5;
				mixiLogo.x = priceBttn.textLabel.x - mixiLogo.width - 5 ;
				mixiLogo.y = (priceBttn.height - mixiLogo.height) / 2;
			}
		}
		
		//protected function drawActionPic():void
		//{			
			//Load.loading(Config.getImage('sales', 'PremActionBackImg'), onPicLoad);
		//}
		
		private function onPicLoad(data:Bitmap):void 
		{
			if (actionPic && actionPic.parent) 
			{
				actionPic.parent.removeChild(actionPic);
			}
			actionPic = new Bitmap();
			bodyContainer.addChild(actionPic);
			bodyContainer.swapChildren(bodyContainer.getChildAt(0), actionPic);
			actionPic.bitmapData = data.bitmapData;
			actionPic.x = (settings.width - actionPic.width) / 2  + 100;
			actionPic.y = 10;
		}
		
		protected function drawActionDescription():void 
		{
			/*descBg.x = (settings.width - descBg.width) / 2;
			descBg.y = 0 ; //270
			descBg.height*/
			
			bodyContainer.addChild(descTextField);
			descTextField.x = titleLabel.x;
			descTextField.y = titleLabel.y + 75;
		}
		
		protected function drawDecorations():void 
		{
			
		}
		
		private var actionCont:LayerX = new LayerX();
		private var actionTitle:TextField;
		private var actionTime:TextField;
		private var remainTitle:TextField;
		private var remainTime:TextField;
		
		private var timeToActionEnd:int = 0;
		private function checkAction():void 
		{
			if (action.time + action.duration * 3600 - App.time > 0) {
				
				//текст "Уже куплено: "
				actionTitle = drawText(Locale.__e("flash:1435928558888"), {
					color:0xffffff,
					borderColor:0x7a4003,
					textAlign:"center",
					autoSize:"center",
					fontSize:30
				});
				actionTitle.y = settings.height/2 - 95;
				actionTitle.x = (settings.width-actionTitle.textWidth)/2 - 30;
				actionCont.addChild(actionTitle);
				
				var timeAction:uint = ((App.time - action.time)/3600) * action.rate ;
				
				actionTime = drawText(String(timeAction), {
					color:0xffffff,
					borderColor:0x7a4003,
					textAlign:"center",
					autoSize:"center",
					fontSize:30
				});
				
				actionTime.width = actionTime.textWidth + 10;
				actionTime.y = actionTitle.y;
				actionTime.x = actionTitle.x + actionTitle.width + 10;
				actionCont.addChild(actionTime);
				
				// текст "Осталось: "
				remainTitle = drawText(Locale.__e("flash:1393581955601"), {
					color:0xffffff,
					borderColor:0x7a4003,
					textAlign:"center",
					autoSize:"center",
					fontSize:30
				});
				remainTitle.y = actionTitle.y + actionTitle.height;
				remainTitle.x = actionTitle.x;
				actionCont.addChild(remainTitle);
				
				var remainItems:uint = (((action.duration * 3600) - (App.time - action.time)) / 3600) * action.rate;
				
				remainTime = drawText(String(remainItems), {
					color:0xffffff,
					borderColor:0x7a4003,
					textAlign:"center",
					autoSize:"center",
					fontSize:30
				});
				
				remainTime.width = actionTime.textWidth + 10;
				remainTime.y = remainTitle.y;
				remainTime.x = remainTitle.x + remainTitle.width + 10;
				actionCont.addChild(remainTime);
				
				bodyContainer.addChild(actionCont);
				actionCont.x = 10;
				actionCont.y = 170;
			}
		}
		
		private function buyEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) 
				return;
			for (var _sid:* in action.items) {
				if (App.data.storage.hasOwnProperty(_sid)){
					if (action.checkstock && action.checkstock == 1 && Stock.isExist(_sid)){
						return;
					}
				}
			}	
			e.currentTarget.state = Button.DISABLED;
			
			switch(App.social) {
				case 'PL':
				//case 'YB':
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
					}
				break;
				case 'SP':
					if(App.user.stock.take(Stock.FANT, action.price[App.social])){
						Post.send({
							ctr:'Promo',
							act:'buy',
							uID:App.user.id,
							pID:action.id,
							ext:App.social
						},function(error:*, data:*, params:*):void {
							if (!error)
								onBuyComplete();
						});
					}else {
						close();
					}
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
							item:			'promo_' + action.id,
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
			var showWindow:Boolean = true;
			
			if (!User.inExpedition)
			{
				App.user.stock.addAll(action.items);				
				var bonus:BonusItem = new BonusItem(premiumItem.sID, 1);
				var point:Point = Window.localToGlobal(premiumItem);
				bonus.cashMove(point, App.self.windowContainer);				
			}
			
			App.user.updateActions();
			App.user.buyPromo(String(pID));
			App.ui.salesPanel.createPromoPanel();
			
			close();
			
			if(showWindow){
				new SimpleWindow( {
					label:SimpleWindow.ATTENTION,
					title:Locale.__e("flash:1382952379735"),
					text:Locale.__e("flash:1382952379990")
				}).show();
			}
		}
	}
}