package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import utils.ActionsHelper;

	public class SaleGoldenWindow extends AddWindow
	{
		private var icon:Bitmap = new Bitmap();
		private var preloader:Preloader = new Preloader();
		private var rays:Bitmap = new Bitmap();
		private var priceBttn:Button;
		private var contIcon:LayerX;
		
		public function SaleGoldenWindow(settings:Object) 
		{
			//settings["title"] = Locale.__e("flash:1396521604876");//Акция!
			settings["width"] = 415;
			settings["height"] = 370;
			settings["hasPaginator"] = false;
			settings["background"] = 'buildingBacking';
			settings['promoPanel'] = true;
			
			action = App.data.actions[settings.pID];
			action['id'] = settings.pID;
			
			super(settings);
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
			contIcon.addChild(rays);
			
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
			/*Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoadIcon);
			contIcon.tip = function():Object { 
				return {
					title:App.data.storage[sID].title,
					text:App.data.storage[sID].description
				};
			};*/
			
			Load.loading(Config.getImage('promo/images', App.data.storage[sID].preview), onLoadIcon);
			bodyContainer.addChild(icon);
			
			drawMirrowObjs('storageWoodenDec', 0, settings.width , settings.height - 110);//down
			drawMirrowObjs('storageWoodenDec', 0, settings.width, 40, false, false, false, 1, -1);//upper
			
			var stripe:Bitmap = Window.backingShort(settings.width + 160, 'bigGoldRibbon');;
			bodyContainer.addChild(stripe);
			stripe.x = (settings.width - stripe.width) / 2;
			stripe.y = settings.height - 150;
			stripe.scaleY = 0.7;
			stripe.smoothing = true;
			
			drawTexts();
			drawBttn();
		}
		
		private function onLoadIcon(data:*):void 
		{
			bodyContainer.removeChild(preloader);
			
			icon.bitmapData = data.bitmapData;
			icon.x = (settings.width - icon.width) / 2;
			icon.y = -60;
			icon.scaleX = icon.scaleY = 1;
		}
		
		/*private var texts:Object = {
			0:{txt:Locale.__e('flash:1406895121425'), bmd:Window.textures.productBacking, scale:0.7, rotation:-18, x:-20, y:0},
			1:{txt:Locale.__e('flash:1406895143591'), bmd:Window.textures.productBacking, scale:1, rotation:14, x:-40, y:60},
			2:{txt:Locale.__e('flash:1406895282697'), bmd:Window.textures.productBacking, scale:0.7, rotation:-17, x:20, y:230},
			3:{txt:Locale.__e('flash:1406895320506'), bmd:Window.textures.productBacking, scale:1, rotation:-13, x:326, y:36},
			4:{txt:Locale.__e('flash:1406895426655'), bmd:Window.textures.productBacking, scale:1, rotation:8, x:330, y:150}
		}*/
		
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
					txtDesc = Window.drawText(Locale.__e("flash:1445527934162"),{//Уникальная декорация всего за:
						fontSize:28,
						color:0xffffff,
						borderColor:0x814f31,
						autoSize:"center"
					}	);
				}
			}			
			
			txtDesc.width = 300;
			txtDesc.x = (settings.width - txtDesc.width) / 2;
			txtDesc.y = 240;
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
			if (App.isJapan())
				bttnSettings.fontSize = 17;
			var priceLable:Object = ActionsHelper.priceLable(action.price[App.social]);
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
				
			bttnSettings['caption'] = Locale.__e(priceLable.text, [priceLable.price]);
			priceBttn = new Button(bttnSettings);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = (settings.height - 70);
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