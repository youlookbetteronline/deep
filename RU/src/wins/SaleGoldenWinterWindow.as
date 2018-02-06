package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import utils.ActionsHelper;

	public class SaleGoldenWinterWindow extends AddWindow
	{
		private var icon:Bitmap = new Bitmap();
		private var preloader:Preloader = new Preloader();
		private var rays:Bitmap = new Bitmap();
		private var background:Bitmap = new Bitmap();
		private var priceBttn:Button;
		private var contIcon:LayerX;
		public var itemTitle:TextField;
		
		public function SaleGoldenWinterWindow(settings:Object) 
		{
			settings["title"] = Locale.__e("flash:1396521604876");//Акция!
			settings["width"] = 400;
			settings["height"] = 370;
			settings["hasPaginator"] = false;
			settings["background"] = 'buildingBacking';
			settings['promoPanel'] = true;
			
			action = App.data.actions[settings.pID];
			action['id'] = settings.pID;
			
			super(settings);
		}
		
		override public function drawBackground():void
		{			
			background = backing(settings.width, settings.height, 30, 'buildingBacking');
			layer.addChild(background);
			background.x = 0;
			background.y = -20;
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
					
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
				
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -16;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = -20;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void 
		{
			exit.y -= 25;
			exit.x += 5;			
			
			contIcon = new LayerX();
			
			var rays:Bitmap = new Bitmap(Window.textures.sharpShining, "auto", true);
			rays.x = -30;
			rays.y = -50;
			rays.scaleX = rays.scaleY = 3;
			//contIcon.addChild(rays);
			
			bodyContainer.addChild(contIcon);
			icon = new Bitmap();
			contIcon.addChild(icon);			
			
			bodyContainer.addChild(preloader);
			preloader.x = settings.width / 2;
			preloader.y = 140;
			
			var sID:int = 0;
			for (var s:String in action.items) {
				sID = int(s);
				break;
			}			
			
			var blueBackground:Bitmap = backing(300, 280, 30, 'paperBackingBlue');
			bodyContainer.addChild(blueBackground);
			blueBackground.x = background.x + background.width / 2 - blueBackground.width / 2;
			blueBackground.y = background.y + background.height / 2 - blueBackground.height / 2 - 30;
			
			drawMirrowObjs('winterCornerDecorUp', -35, settings.width + 35, -55, false, false, false, 1, 0.65, null, 0.65);
			drawMirrowObjs('winterTitleDecor', titleLabel.x + 100, titleLabel.x + titleLabel.width - 100, headerContainer.y - 50, true, true, false, 1, 0.85, null, 0.85);
			
			Load.loading(Config.getImage('promo/images', App.data.storage[sID].preview), onLoadIcon);
			bodyContainer.addChild(icon);
			
			var curtain:Shape = new Shape();
			curtain.graphics.beginFill(0xbbd8e6, 0.5);
			curtain.graphics.drawRoundRect(0, 0, 290, 65, 0, 0);
			curtain.graphics.endFill();
			bodyContainer.addChild(curtain);
			curtain.x = 55;
			curtain.y = 205;
			
			drawMirrowObjs('winterCornerDecorDown', -30, settings.width + 30, settings.height - 135, false, false, false, 1, 0.65, null, 0.65);
			
			var stripe:Bitmap = Window.backingShort(settings.width + 160, 'bigGoldRibbon');;
			//bodyContainer.addChild(stripe);
			stripe.x = (settings.width - stripe.width) / 2;
			stripe.y = settings.height - 150;
			stripe.scaleY = 0.7;
			stripe.smoothing = true;
			
			itemTitle = Window.drawText(App.data.storage[sID].title, {
				width		:280,
				fontSize	:25,
				textAlign	:"centre",
				autoSize	:"center",
				color		:0xffffff,
				borderColor	:0x1b59a2,
				multiline	:true,
				wrap		:true
			});
			
			bodyContainer.addChild(itemTitle);
			itemTitle.x = background.x + background.width / 2 - 60;
			itemTitle.y = blueBackground.y + 10;
			
			drawTexts();
			drawBttn();
		}
		
		private function onLoadIcon(data:*):void 
		{
			bodyContainer.removeChild(preloader);
			
			icon.bitmapData = data.bitmapData;
			icon.x = (settings.width - icon.width) / 2;
			icon.y = 30;
			icon.scaleX = icon.scaleY = 1;
		}
		
		private function drawTexts():void 
		{
			for (var i:* in action.items) {
				if (i == '439') 
				{
					var txtDesc:TextField = Window.drawText(Locale.__e("flash:1447688191189"),{//Дает алмазы каждый день! Всего за:
						fontSize:28,
						color:0xffffff,
						borderColor:0x814f31,
						autoSize:"center"
					}	);
				}else {
					txtDesc = Window.drawText(Locale.__e("flash:1449674965301"),{//Описание
						fontSize:20,
						color:0xffffff,
						borderColor:0x156192,
						autoSize:"center",
						multiline:true,
						wrap:true,
						textAlign:"center"
					});
				}
			}			
			
			txtDesc.width = 250;
			txtDesc.x = (settings.width - txtDesc.width) / 2;
			txtDesc.y = 215;
			bodyContainer.addChild(txtDesc);
		}
		
		private function drawOneTxt(txt:String, bg:BitmapData, _scale:Number, _rotation:int, xPos:int, yPos:int):void
		{
			var container:Sprite = new Sprite();
			bodyContainer.addChild(container);
			
			var bgTxt:Bitmap = new Bitmap(bg);
			bgTxt.scaleX = bgTxt.scaleY = _scale;
			bgTxt.smoothing = true;
			container.addChild(bgTxt);
			bgTxt.x = 25;
			var txtDesc:TextField = Window.drawText(txt,{
				fontSize:26,
				color:0xfeffe8,
				borderColor:0x754618,
				autoSize:"center",
				textAlign:'center',
				multiline:true,
				wrap:true,
				width:bg.width + 40
			});
			
			txtDesc.y = (bgTxt.height - txtDesc.textHeight) / 2;
			txtDesc.x = bgTxt.x +(bgTxt.width - txtDesc.width) / 2;
			container.addChild(txtDesc);			
			
			container.rotation = _rotation;
			container.x = xPos;
			container.y = yPos;
		}
		
		private function drawBttn():void 
		{			
			var bttnSettings:Object = {
				fontSize:36,
				width:186,
				height:52 + 10 * int(App.isSocial('MX'))
			};
			var priceLable:Object = ActionsHelper.priceLable(action.price[App.social]);
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
			
			//bttnSettings['caption'] = Payments.price(action.price[App.social]);//Locale.__e(text, [int(action.price[App.self.flashVars.social])]);
			bttnSettings['caption'] = Locale.__e(priceLable.text, [priceLable.price]);
			priceBttn = new Button(bttnSettings);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = (settings.height - 80);
			bodyContainer.addChild(priceBttn);
			
			if (Payments.byFants)
				priceBttn.fant();
			
			/*if(App.isSocial('MX')){
				var mixiLogo:Bitmap = new Bitmap(Window.mixieLogo);
				priceBttn.topLayer.addChild(mixiLogo);
				priceBttn.fitTextInWidth(priceBttn.width - (mixieLogo.width + 10));
				priceBttn.textLabel.width = priceBttn.textLabel.textWidth + 5;
				priceBttn.textLabel.x = (priceBttn.width - (priceBttn.textLabel.width + mixiLogo.width + 5)) / 2 + mixieLogo.width + 5;
				mixiLogo.x = priceBttn.textLabel.x - mixiLogo.width - 5 ;
				mixiLogo.y = (priceBttn.height - mixiLogo.height) / 2;
			}*/
			
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		}
		
		override public function buyEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			//onBuyComplete();
			//descriptionLabel.visible = false;
			//timerText.visible = false;
			switch(App.social) {
				case 'SP':
				case 'HV':
				//case 'AI':
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
							votes:			int(action.price[App.self.flashVars.social]),
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback: 		onBuyComplete
						}
					}
					ExternalApi.apiPromoEvent(object);
					break;
			}
		}
		
		override public function onBuyComplete(e:* = null):void 
		{
			//return;
			priceBttn.state = Button.DISABLED;
			
			if (!User.inExpedition) {
				App.user.stock.addAll(action.items);
			}	
			
			App.user.promo[action.id].buy = 1;
			App.user.buyPromo(action.id);
			App.ui.salesPanel.createPromoPanel();
			
			close();
			
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				title:Locale.__e("flash:1393579648825"),
				text:Locale.__e("flash:1382952379990")
			}).show();
		}
	}
}