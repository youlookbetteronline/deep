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
	import units.Golden;
	import utils.ActionsHelper;

	public class SaleGoldenWindowExtended extends AddWindow
	{
		private var icon:Bitmap = new Bitmap();
		private var preloader:Preloader = new Preloader();		
		private var priceBttn:Button;		
		private var contIcon:LayerX;		
		private var rays:Bitmap = new Bitmap();
		private var miraContainer:LayerX;
		
		public function SaleGoldenWindowExtended(settings:Object) 
		{
			settings["title"] = Locale.__e("flash:1396521604876");
			settings["width"] = 415;
			settings["height"] = 435;
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
			
			miraContainer = new LayerX();
			bodyContainer.addChild(miraContainer);
			
			Load.loading(Config.getImage('promo/images', App.data.storage[sID].preview), onLoadIcon);
			miraContainer.addChild(icon);	
			
			miraContainer.tip = function():Object {
				return { title:App.data.storage[1488].title, text:App.data.storage[1488].description };
			}
			
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
			icon.y = 0;
		}
		
		private var texts:Object = {
			0:{txt:Locale.__e('flash:1446041937860'), bmd:Window.textures.sharpShining, scale:0.7, rotation:-18, x:-10, y:10},//лево верх
			1:{txt:Locale.__e('flash:1446041985035'), bmd:Window.textures.sharpShining, scale:1, rotation:14, x:-30, y:90},//лево низ
			2:{txt:Locale.__e('flash:1446042019147'), bmd:Window.textures.sharpShining, scale:1, rotation:-13, x:230, y:10},//право верх
			3:{txt:Locale.__e('flash:1445589898759'), bmd:Window.textures.sharpShining, scale:1, rotation:8, x:250, y:150}//право низ
		}
		
		private function drawTexts():void 
		{
			for each(var data:* in texts) {
				drawOneTxt(data.txt, data.bmd, data.scale, data.rotation, data.x, data.y);
			}
			
			var txtDesc:TextField = Window.drawText(Locale.__e("flash:1445527934162"),{
				fontSize:28,
				color:0xffffff,
				borderColor:0x814f31,
				autoSize:"center"
			});
			txtDesc.width = 300;
			txtDesc.x = (settings.width - txtDesc.width) / 2;
			txtDesc.y = 300;
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
				height:52 + 10*int(App.isSocial('MX'))
			};
			
			var price:Number= action.price[App.social];
			if (App.isJapan())
				bttnSettings.fontSize = 17;
			var priceLable:Object = ActionsHelper.priceLable(price);
			
			if (priceBttn != null) 
			{
				bodyContainer.removeChild(priceBttn);
			}				
			
			bttnSettings['caption'] = Locale.__e(priceLable.text, [priceLable.price]);
			priceBttn = new Button(bttnSettings);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = (settings.height - 70) - 10*int(App.isSocial('MX'));
			bodyContainer.addChild(priceBttn);
			
			if (Payments.byFants)
				priceBttn.fant();
			
			if(App.isSocial('MX')){
				var mixiLogo:Bitmap = new Bitmap(Window.textures.mixieLogo);
				priceBttn.topLayer.addChild(mixiLogo);
				priceBttn.fitTextInWidth(priceBttn.width - (mixiLogo.width + 10));
				priceBttn.textLabel.width = priceBttn.textLabel.textWidth + 5;
				priceBttn.textLabel.x = (priceBttn.width - (priceBttn.textLabel.width + mixiLogo.width + 5)) / 2 + mixiLogo.width + 5;
				mixiLogo.x = priceBttn.textLabel.x - mixiLogo.width - 5 ;
				mixiLogo.y = (priceBttn.height - mixiLogo.height) / 2;
			}
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		}
		
		override public function buyEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			switch(App.social) 
			{
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
				case 'PL':
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