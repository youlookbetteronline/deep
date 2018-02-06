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
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.display.GradientType; 
	import flash.geom.Matrix; 
	/**
	 * ...
	 * @author ...
	 */
	public class PremiumActionWindow extends Window
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
		public var background2:Bitmap;
		public var titleBackingBmap2:Bitmap;
		private var preloader:Preloader = new Preloader();
		
		public function PremiumActionWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = { };
			}
			pID = settings.pID;
			action = App.data.actions[pID];
			for (var i:String in action.items) {
				premiumItem = App.data.storage[i];
			}
			settings['width'] = 440;
			settings['height'] = 380;
			settings['title'] = premiumItem.title;
			settings['hasTitle'] = false;
			settings['background'] = 'ironBacking';
			settings['hasPaginator'] = false;
			settings['exitTexture'] = 'closeBttnMetal';
			settings['fontColor'] = '0xffffff';
			settings['fontSize'] = 42;
			settings['fontBorderColor'] = 0xb05b15;
			settings['fontBorderSize'] = 2;
			
			
			
			action['id'] = pID;
			
			
			
			var descPrms:Object = {
				color			:0xffffff,
				borderColor		:0xa23900,
				width			:320,
				multiline		:true,
				wrap			:true,
				textAlign		:'center',
				fontSize		:52,
				textLeading		: -7,
				fontBorderSize	:2
			}
			
			/*color:0xffffff,
				borderColor:0x004551,
				textAlign:"center",
				autoSize:"center",
				fontSize:26*/
			
			if (action.text1){
				descTextField = Window.drawText(action.text1, descPrms); 
				descPrms['fontSize'] = 52;
				descTextFieldLow = Window.drawText(action.text2, descPrms); 
			} else {
				//var textPart:String = premiumItem.description;
				descTextField = Window.drawText(premiumItem.title, descPrms); 
				descPrms['fontSize'] = 26;
				descPrms['borderColor'] = 0x004551;
				descTextFieldLow = Window.drawText(premiumItem.description, descPrms);  
			}
			settings['height'] += descTextFieldLow.textHeight + 40;
			
			super(settings)
		}
		
		private var white:Shape;
		override public function drawBody():void 
		{	
		
			
			var gradientBoxMatrix:Matrix = new Matrix(); 
			gradientBoxMatrix.createGradientBox(400, 110, Math.PI / 2, 0, -50);
			
		
			
			
			titleBackingBmap2 = backingShort(530, 'actionRibbonBg', true, 1);
			titleBackingBmap2.x = -45;
			titleBackingBmap2.y = 270;
			titleBackingBmap2.filters = [new DropShadowFilter(4.0, 90, 0, 0.5, 4.0, 4.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(titleBackingBmap2);
			
			white = new Shape();
			white.graphics.beginGradientFill(GradientType.LINEAR, [0xa8d3da,0x05749a], [1, 1], [0,255],gradientBoxMatrix);
			white.graphics.drawRect(0, 0, 400, (settings.height -(titleBackingBmap2.y + titleBackingBmap2.height) + 15));
			white.x = (settings.width - white.width) / 2;
			white.y = settings.height - white.height - 5;
			white.graphics.endFill(); 
			layer.addChildAt(white,0);
			//titleLabel.y += 100;
			
			
			drawMirrowObjs('decSeaweed', settings.width + 57, - 57, settings.height - 177, true, true, false, 1, 1, layer);
			
			/*back.graphics.beginFill(0xf5da65, 1);
		    back.graphics.drawRect(0, 0, settings.width - 90, descTextFieldLow.textHeight + 15);
		    back.graphics.endFill();
		    back.x = (settings.width - back.width) / 2 ;
		    back.filters = [new BlurFilter(20, 0, 2)];
		    bodyContainer.addChild(back);*/ 
			
			var star3:Bitmap = new Bitmap(Window.textures.decStarRed);
			star3.x = titleBackingBmap2.x + titleBackingBmap2.width - 110;
			star3.y = titleBackingBmap2.y;
			star3.smoothing = true;
			bodyContainer.addChild(star3);
			drawItem();
			
			/*var fish2:Bitmap = new Bitmap(Window.textures.decFish2);
			fish2.x = settings.width - 25;
			fish2.y = settings.height - 150;
			layer.addChildAt(fish2,0);*/
			
			drawActionDescription();
			
			/*background2 = backing2(370, 230, 45, 'calImgUp', 'calImgBot');
			background2.x = (settings.width - background2.width) / 2;
			background2.y = descTextField.y + descTextField.textHeight + 15;
			
			
		    back.y = background2.y + background2.height + 10;*/
			
			bodyContainer.addChild(descTextFieldLow);
			descTextFieldLow.x = (settings.width - descTextFieldLow.width) / 2;
			descTextFieldLow.y = white.y + (white.height - descTextFieldLow.textHeight) / 2 - 10;
			//settings['height'] += descTextFieldLow.textHeight;
			
			//descTextFieldLow.border = true;
			
			//bodyContainer.addChild(background2);
			
			
			bodyContainer.addChild(preloader);
			preloader.x = settings.width/2;
			preloader.y = 180;
			
			if (action.hasOwnProperty('picture'))
			{
				var pic:Bitmap = new Bitmap();
				layer.addChildAt(maska,0);
				layer.addChildAt(pic,0);
				Load.loading( Config.getImage('actions/backgrounds', action.picture, 'png'), function(data:*):void {
					pic.bitmapData = data.bitmapData;
					Size.size(pic, 769, 402);
					pic.smoothing = true;
					maska.graphics.beginFill(0xFFFFFF, 1);
					maska.graphics.drawRoundRect(0, 0, settings.width - 10, settings.height - 10, 50, 50);
					maska.graphics.endFill();
					maska.x = 5;
					maska.y = 10;
					pic.x = maska.x - (pic.width - maska.width)/2;
					pic.y = maska.y + 10;
					
					maska.cacheAsBitmap = true;
					pic.mask = maska;
					if (preloader && preloader.parent)
						preloader.parent.removeChild(preloader);
					//bodyContainer.removeChild(preloader);
					preloader = null;
				});		
			}
			
			
			//drawRibbon();	
			drawPriceButton();			
			drawActionPic();			
			exit.y -= 25;
			//checkAction();	
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
				width:200,
				height:65,
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
			priceBttn.y = settings.height - priceBttn.height + 20;
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
		
		protected function drawActionPic():void
		{			
			Load.loading(Config.getImage('sales/image', 'prem_energy_fish'), onPicLoad);
		}
		
		private function onPicLoad(data:Bitmap):void 
		{
			if (actionPic && actionPic.parent) 
			{
				actionPic.parent.removeChild(actionPic);
			}
			actionPic = new Bitmap();
			bodyContainer.addChild(actionPic);
			//bodyContainer.swapChildren(bodyContainer.getChildAt(0), actionPic);
			actionPic.bitmapData = data.bitmapData;
			actionPic.x = titleBackingBmap2.x + (titleBackingBmap2.width - actionPic.width) / 2;
			actionPic.y = -80;
		}
		
		protected function drawActionDescription():void 
		{
			/*descBg.x = (settings.width - descBg.width) / 2;
			descBg.y = 0 ; //270
			descBg.height*/
			
			bodyContainer.addChild(descTextField);
			descTextField.x = titleBackingBmap2.x + (titleBackingBmap2.width - descTextField.width) / 2;
			descTextField.y = titleBackingBmap2.y + (titleBackingBmap2.height - descTextField.height) / 2;
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
			if (e.currentTarget.mode == Button.DISABLED) return;
			
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