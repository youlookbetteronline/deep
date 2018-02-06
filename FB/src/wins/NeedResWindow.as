package wins 
{
	
	import buttons.Button;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.PurchaseWindow;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class NeedResWindow extends Window 
	{
		
		public var button1:Button;
		public var button2:Button;
		public var button3:Button;
		
		public var textLabel:TextField = null;
		public var textLabel2:TextField = null;
		
		public var neededItem:Bitmap = new Bitmap;
		
		private var requireItems:Object = null;
		
		private var requireText:String = new String;
		
		public var background:Bitmap;
		
		public var bitmap:Bitmap = new Bitmap;
		
		private var bitmapLabel:Bitmap = null;
		//private var back:Bitmap;
		
		private var dY:int = 0;
		private var dX:int = 0;
		private var textLabel_dY:int = 0;
		private var titleLabel_dY:int = 0;
		private var textLabelOffsetY:int = 0;
		
		public function NeedResWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;
			settings['title'] 			= settings.title;
			settings['text'] 			= settings.text;
			settings['text2'] 			= settings.text2 || false;
			settings['textAlign'] 		= settings.textAlign || 'center';
			settings['autoSize'] 		= settings.autoSize || 'center';
			settings['textSize'] 		= settings.textSize || 24;
			settings['padding'] 		= settings.padding || 20;
			settings["width"]			= settings.width || 530;
			settings["height"] 			= 300;
			settings["fontSize"]		= 38;
			settings["fontColor"]       = 0xffffff;
			settings["bitmap"]	 		= settings.bitmap || null;
			settings['button1'] 		= settings.button1 || false;
			settings['button2'] 		= settings.button2 || false;
			settings['button3'] 		= settings.button3 || false;
			settings['neededItems']     = settings.neededItems || 645;  // если ничего не надо - всегда надо динамит
			settings['exitTexture']		= 'closeBttnMetal';
			
			textLabelOffsetY			= settings.textLabelOffsetY || 0;
			textLabel_dY = 0;
			
			super(settings);
		}
		private var icon:Bitmap;
		private var backingBack:Bitmap;
		override public function drawBody():void {

			if (settings.offsetY) {
				this.y = settings.offsetY;
				fader.y = Math.abs(settings.offsetY);
			}
			
			if (settings.offsetX) {
				this.x = settings.offsetX;
				fader.x =  Math.abs(settings.offsetX);
			}
			
			var textFontSize:int;
			if (settings.title != null) {
				textFontSize = settings.textSize;
			} else
				textFontSize = settings.textSize + 8;
				
			requireItems = settings.neededItems;
			
			var ribbon:Bitmap = backingShort((titleLabel.width + 100 < 380) ? titleLabel.width + 100 : 380, 'ribbonGrenn');
			ribbon.y = -40;
			ribbon.x = (settings.width - ribbon.width) / 2;
			layer.addChild(ribbon);
			
			var itemsBacking:Bitmap = Window.backingShort(settings.width - 80, 'backingGrad', true);
			itemsBacking.scaleY = 2.6;
			itemsBacking.alpha = .8;
			itemsBacking.smoothing = true;
			itemsBacking.x = (settings.width - itemsBacking.width) / 2;
			itemsBacking.y = (settings.height - itemsBacking.height) / 2;
			layer.addChild(itemsBacking);
			
			var backgroundShape:Shape = new Shape();
			backgroundShape.graphics.beginFill(0xe59e79);
			backgroundShape.graphics.drawCircle(68, 68, 68);
			backgroundShape.graphics.endFill();
			
			backingBack = new Bitmap(new BitmapData(136, 136, true, 0));
			backingBack.bitmapData.draw(backgroundShape);
			//backingBack = new Bitmap(Window.textures.bgOutItem);
			//backingBack.scaleX = backingBack.scaleY = 1.35;
			//backingBack.smoothing = true;
			backingBack.x = itemsBacking.x + 20;
			backingBack.y = itemsBacking.y + (itemsBacking.height - backingBack.height) / 2;
			layer.addChild(backingBack);
			drawItem();
			
			if (requireItems)
			{
				for (var t:* in requireItems) 
				{
					requireText += App.data.storage[t].title + ' ';
				}
				textLabel = Window.drawText(settings.text + ' ' + requireText, 
				{
					color: 0xFFFFFF,
					borderColor:0x6f3d1a,
					borderSize:4,
					fontSize:textFontSize,
					textAlign:settings.textAlign,
					autoSize:settings.autoSize,
					multiline:true
				});
			}  else 
			{
				textLabel = Window.drawText(settings.text, 
				{
					color: 0xFFFFFF,
					borderColor:0x6f3d1a,
					borderSize:4,
					fontSize:textFontSize,
					textAlign:settings.textAlign,
					autoSize:settings.autoSize,
					multiline:true
				});
			}
			

			textLabel.wordWrap = true;
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			textLabel.width = 270;
			textLabel.height = textLabel.textHeight + 4;
			//textLabel.border = true;
			var y1:int = titleLabel.y + titleLabel.height;
			var y2:int = bottomContainer.y;
			
			bodyContainer.addChild(textLabel);
			//textLabel.border = true;
			textLabel.x = itemsBacking.x + 164;
			textLabel.y = itemsBacking.y + (itemsBacking.height - textLabel.textHeight) / 2 - 36;
			
			exit.x -= 9;
			exit.y = 0;
			
			if (settings.text2) {
				textLabel2 = Window.drawText(settings.text2, {
					color:0xFFFFFF,
					borderColor:0x6f3d1a,
					borderSize:4,
					fontSize:textFontSize,
					textAlign:settings.textAlign,
					autoSize:settings.autoSize,
					multiline:true
				});
					
				textLabel2.wordWrap = true;
				textLabel2.mouseEnabled = false;
				textLabel2.mouseWheelEnabled = false;
				textLabel2.width = settings.width - 50;
				textLabel2.height = textLabel.textHeight + 4;
				
				textLabel.x = 25;
				textLabel.y = 30;
				
				//bodyContainer.addChild(textLabel2);
				
				textLabel2.x = textLabel.x;
				textLabel2.y = textLabel.y + textLabel.height + 20 ;
				
			}
			
			checkPacks();
			
			drawBttns();
			
			if (settings.title != null) {
				//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, settings.titleHeight / 2 + titleLabel.y + 2, true, true, true);
				//drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, settings.height - 105);
				//drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, 45,false,false,false,1,-1);
			}
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap =  backing(settings.width, settings.height, 50, 'capsuleWindowBacking');
			layer.addChild(background);	
			
			var bgPaper:Bitmap = backing(settings.width - 68, settings.height - 68, 40, 'paperClear');
			bgPaper.x = background.x + (background.width - bgPaper.width) / 2;
			bgPaper.y = background.y + (background.height - bgPaper.height) / 2;
			layer.addChild(bgPaper);
			
			drawMirrowObjs('decSeaweed', settings.width + 56, - 56, settings.height - 174, true, true, false, 1, 1, layer);
			//background = backing2(settings.width, settings.height, 50, 'questBackingTop', 'questBackingBot');
		}
		public var preloader:Preloader = new Preloader();
		public function drawItem():void 
		{
			layer.addChild(preloader);
			//preloader.scaleX = preloader.scaleY = 0.6;
			preloader.x = backingBack.x + (backingBack.width / 2);
			preloader.y = backingBack.y + (backingBack.height / 2);
			
			var sIDD:int;
			sIDD = Numbers.firstProp(requireItems).key;
			icon = new Bitmap();
			layer.addChild(icon)
			Load.loading(Config.getIcon( App.data.storage[sIDD].type,  App.data.storage[sIDD].preview),
			function(data:Bitmap):void
			{
				if (icon)
				{
					layer.removeChild(preloader);
					icon.bitmapData = data.bitmapData;
					Size.size(icon, backingBack.width - 10, backingBack.height - 10);
					icon.x = backingBack.x + (backingBack.width - icon.width) / 2;
					icon.y = backingBack.y + (backingBack.height - icon.height) / 2;
				}
			});
		}
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x4c871c,			
				borderSize 			: 3,					
				shadowColor			: 0x085c10,
				//width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = - 62; 
			bodyContainer.addChild(titleLabel);
		}
		
		public function drawBttns():void
		{
			var buttonsSprite:Sprite = new Sprite();
			
			if (settings.button1)
			{	
				button1 = new Button({
					caption:Locale.__e('flash:1382952379751'),
					fontSize:26,
					width:120,
					hasDotes:false,
					height:47
				});
				
				button1.addEventListener(MouseEvent.CLICK, buttonAction1);
				
				//button1.x = 0;
				buttonsSprite.addChild(button1);
				//button1.y = 0;
				//button1.x = settings.width / 2 - button1.width - 10;
				//button1.y = textLabel.y + textLabel.height + 40 ;
			}
			if (settings.button2)
			{
				button2 = new Button( {
						caption			:Locale.__e('flash:1407231372860'),
						fontSize		:26,
						width			:120,
						hasDotes		:false,
						height			:47,
						bgColor			:[0xc8e414,0x80b631],	//Цвета градиента
						borderColor		:[0xeafed1,0x577c2d],	//Цвета градиента
						bevelColor		:[0xdef58a, 0x577c2d],
						fontColor		:0xffffff,				//Цвет шрифта
						fontBorderColor	:0x085c10
				});
				
				button2.addEventListener(MouseEvent.CLICK, buttonAction2);
				
				button2.x = buttonsSprite.width + ((buttonsSprite.width == 0) ? 0 : 12);
				buttonsSprite.addChild(button2);
				//button2.y = settings.height - button2.height *2 + 26;
			}
			if (settings.button3 && packsParams['content'].length > 0)
			{
				button3 = new Button( {
						caption			:Locale.__e('flash:1382952379751'),
						fontSize		:26,
						width			:120,
						hasDotes		:false,
						height			:47,
						bgColor			:[0x71d0f7,0x5984cb],	//Цвета градиента
						borderColor		:[0xd6f0ff,0x405ea4],	//Цвета градиента
						bevelColor		:[0xd6f0ff,0x405ea4],
						fontColor		:0xffffff,				//Цвет шрифта
						fontBorderColor	:0x104f7d
				});
				
				button3.addEventListener(MouseEvent.CLICK, buttonAction3);
				
				button3.x = buttonsSprite.width + ((buttonsSprite.width == 0) ? 0 : 12);
				buttonsSprite.addChild(button3);
				//button3.y = settings.height - button3.height *2 + 26;//textLabel.y + textLabel.height  + button3.height / 2 ;
				/*if(textLabel2){
					button3.y += textLabel2.height;
				}*/
			}
			//if (settings.button2 && settings.button3){
				//button2.x = (settings.width - button2.width - button3.width) / 2
				//button3.x = button2.x + button2.width + 5;
			//}
			bodyContainer.addChild(buttonsSprite);
			buttonsSprite.x = (settings.width - buttonsSprite.width) / 2;
			buttonsSprite.y = settings.height - 45 - buttonsSprite.height / 2;
			
			//bottomContainer.y = settings.height - bottomContainer.height - 36;
			//bottomContainer.x = 0;
		}
		
		public function buttonAction1(e:MouseEvent):void {
			close();
			new PurchaseWindow( {
				width:550,
				itemsOnPage:3,
				//content:PurchaseWindow.createContent("Firework"),
				content:PurchaseWindow.createContent("Firework", {backview:['dinamite_1']}),
				title:App.data.storage[645].title,
				popup:true,
				description:Locale.__e("flash:1382952379757"),
				closeAfterBuy:false,
				autoClose:false
			}).show();
		}
		public var targets:Array = [];
		public function buttonAction2(e:MouseEvent):void{
			close();
			var sID:int = 0;
			for (var t:* in settings.neededItems){
				sID = t; // получили айдишник того, чего не хватает для добычи ресурса
			}
			ShopWindow.findMaterialSource(sID);
			
		}
		
		//private function glowing():void {
			//customGlowing(background, glowing);
			//customGlowing(placeBttn, null, 0xff9900);	
		//}
		//
		//private function customGlowing(target:*, callback:Function = null,colorGlow:uint = 0xFFFF00):void {
			//TweenMax.to(target, 1, { glowFilter: { color:colorGlow, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				//TweenMax.to(target, 0.8, { glowFilter: { color:colorGlow, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					//if (callback != null) {
						//callback();
					//}
				//}});	
			//}});
		//}
		private var packsParams:Object = new Object();
		private function checkPacks():void
		{
			if (settings.button3)
			{
				var niID:int;
				var niView:String;
				for (var t:* in settings.neededItems)
				{
					niID = t; // получили айдишник того, чего не хватает для добычи ресурса
				}
				
				for each (var niResource:* in App.data.storage) 
				{
					if (niResource.type == 'Energy')
					{
						if (niResource.out == niID) 
						{
							niView = niResource.view;
						}
					} 
				}
				
				var itemsOnPage: int;
				if(niView == "Feed"){
					itemsOnPage = 2;
				}else{
					itemsOnPage = 3;
				}
				
				packsParams['niID'] = niID;
				packsParams['niView'] = niView;
				packsParams['itemsOnPage'] = itemsOnPage;
				packsParams['content'] = PurchaseWindow.createContent("Energy", {view:niView}, niID);
			}
		}
		
		public function buttonAction3(event:MouseEvent):void 
		{
			close();
			
			new PurchaseWindow({
				width			:(packsParams['niView'] == "Feed") ? 420 : 600,
				itemsOnPage		:packsParams['itemsOnPage'],
				content			:packsParams['content'],
				title			:App.data.storage[packsParams['niID']].title,
				popup			:true,
				description		:Locale.__e("flash:1382952379757"),
				closeAfterBuy	:false,
				autoClose		:false
			}).show();
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}

}