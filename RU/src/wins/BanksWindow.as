package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MenuButton;
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.UserInterface;
	import wins.elements.BankUsualItem;
	import wins.elements.BankUsualMenu;
	import wins.elements.SetItem;

	public class BanksWindow extends Window
	{
		public static const COINS:String = 'Coins';
		public static const REALS:String = 'Reals';
		public static const SETS:String = 'Sets';
		
		public static var shop:Object;
		public static var history:Object = {section:'Reals',page:0};
		
		public var sections:Array = new Array();
		private var progressBar:ProgressBar;
		private var bubbleBg:Bitmap = new Bitmap();
		private var progressBacking:Bitmap;
		public var news:Object = {items:[],page:0};
		public var icons:Array = new Array();
		private var progressTitle:TextField;
		public var items:Array = [];
		private var preloader:Preloader = new Preloader();
		private var voitIn:Boolean = false;								//<----------КОНТЕЙНЕР PROGRESSBAR----------
		private var textFilter:GlowFilter;
		private var shadowFilter:BlurFilter;
		private var voitUsed:TextField;
		private var voitCont:LayerX;
		private var itemsContainer:Sprite = new Sprite();
		
		private static var _currentBuyObject:Object = { type:null, sid:null };
		
		public function BanksWindow(settings:Object = null)
		
		{		
			_currentBuyObject.type = null;
			_currentBuyObject.sid = null;
			
			if (settings == null) {
				settings = new Object();
			}
			settings["section"] = settings.section || history.section; 
			settings["page"] = settings.page || history.page;
			settings["popup"] = true;
			
			settings["find"] = settings.find || null;
			
			settings["title"] = Locale.__e("flash:1382952379979");
			
			settings["width"] = 640;	
			settings["height"] = 650;
			if (voitIn == false)
				settings["height"] = 620;			
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 6;
			settings["returnCursor"] = false;
			settings['hasButtons'] = false;
			
			settings['exitTexture'] = 'closeBttnMetal';
			
			history.section		= settings.section;
			history.page		= settings.page;
			
			super(settings);
		}
		
		override public function show():void 
		{
			if (App.social == 'SP') {
				ExternalApi.apiBalanceEvent( { money:settings.section } );
				return;
			}
			super.show();
		}
		
		private function checkUpdate(updateID:String):Boolean {
			
			var update:Object = App.data.updates[updateID];
			if (!update.hasOwnProperty('social') || !update.social.hasOwnProperty(App.social)) {
				
				for (var sID:* in App.data.updates[updateID].items) {
					if ((update.ext != null && update.ext.hasOwnProperty(App.social)) && (update.stay != null && update.stay[sID] != null))
					{
						
					}
					else
					{
						App.data.storage[sID].visible = 0;
					}
				}
				
				return false;
			}
			
			return true;
		}
		
		
		override public function drawBackground():void{
			var background:Bitmap = backing(settings.width, settings.height, 50, "capsuleWindowBacking");
			
			layer.addChild(background);
		}
		
		override public function dispose():void {
			
			App.self.setOffTimer(updateTimeAction);
			
			for each(var item:* in items) {
				if (item.parent)
					item.parent.removeChild(item);
				//itemsContainer.removeChild(item);
				item.dispose();
				item = null;
			}
			
			for each(var icon:* in icons) {
				//bodyContainer.removeChild(icon);
				icon.dispose();
				icon = null;
			}
			
			super.dispose();
		}
		
		override public function titleText(settings:Object):Sprite
		{
			if (!settings.hasOwnProperty('width'))
				settings['width'] = 300;
				
			var cont:Sprite = new Sprite();
			var cont2:Sprite = new Sprite();
			var shadow:Sprite = new Sprite();
			
			var fontBorder:int = settings.fontBorderSize;
			settings.fontBorderSize = fontBorder;
			var fontBorderGlow:int = settings.fontBorderGlow;
			settings.fontBorderGlow = fontBorderGlow;
			
			
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			this.settings['titleWidth'] = textLabel.textWidth;
			this.settings['titleHeight'] = textLabel.textHeight;
			textLabel.wordWrap = true;
			textLabel.width = settings.width;
			textLabel.height = textLabel.textHeight + 4;
			
			var borderColor:uint = settings.borderColor
			settings.borderColor = borderColor;//settings.shadowBorderColor;
			settings.color = borderColor;
			
			var textShadow:TextField = Window.drawText(settings.title, settings);
			textShadow.wordWrap = true;
			textShadow.width = settings.width;
			textShadow.height = textLabel.textHeight + 4;
			
			textShadow.cacheAsBitmap = true;
			textLabel.cacheAsBitmap = true;

			var textShadow2:TextField = Window.drawText(settings.title, settings);
			textShadow2.wordWrap = true;
			textShadow2.width = settings.width;
			textShadow2.height = textLabel.textHeight + 4;
			textShadow2.cacheAsBitmap = true;
			
			settings.borderColor = 0x2a5e0b;
			settings.color = 0x2a5e0b;
			var textShadow3:TextField = Window.drawText(settings.title, settings);
			textShadow3.wordWrap = true;
			textShadow3.width = settings.width;
			textShadow3.height = textLabel.textHeight + 4;
			textShadow3.cacheAsBitmap = true;
					
			var textShadow4:TextField = Window.drawText(settings.title, settings);
			textShadow4.wordWrap = true;
			textShadow4.width = settings.width;
			textShadow4.height = textLabel.textHeight + 4;
			textShadow4.cacheAsBitmap = true;
			
			cont2.addChild(shadow);
			shadow.addChild(textShadow3);
			shadow.addChild(textShadow4);
			cont2.addChild(cont);
			
			//cont.addChild(textShadow);
			//cont.addChild(textShadow2);
			
			cont.addChild(textLabel);
			textFilter = new GlowFilter(0x579705, 1, 3,3, 10, 1);
			cont.filters = [textFilter/*, new BlurFilter(1.2,1.2,1)*/];
			
			shadowFilter = new BlurFilter(2,2,1);
			shadow.filters = [shadowFilter/*, new BlurFilter(1.2,1.2,1)*/];
			
			
			textShadow.y = 1;
			textShadow2.y = -2;
			textShadow3.y = 4;
			textShadow3.x = 1;
			textShadow4.y = 4;
			textShadow4.x = -1;
			cont.mouseEnabled = false;
			cont.mouseChildren = false;
			return cont2;
		}
		
		public var clickCont:LayerX;
	//	private var clickCont:LayerX;
		private var lable1:Bitmap;
		private var lable2:Bitmap;
		private var snailBitmap:Bitmap;
		override public function drawBody():void {
			
			this.y -= 10;
			fader.y += 30;
			var titleBackingBmap:Bitmap = backingShort(titleLabel.width + 20, 'ribbonGrenn',true,1.3);
			titleBackingBmap.x = settings.width/2 -titleBackingBmap.width/2;
			titleBackingBmap.y = -67;
			bodyContainer.addChild(titleBackingBmap);
			
			drawMirrowObjs('decSeaweed', settings.width + 55, - 55, settings.height - 150 - 28, true, true);
			
			drawBacking();
			//drawSeparator();
			drawMenu();
			
			voitCont = new LayerX();
			if (voitIn == true)
				bodyContainer.addChild(voitCont);
			
			voitUsed = Window.drawText(Locale.__e('flash:1486049500430'), {
				color:0xffdf34,
				borderColor:0x6e411e,
				fontSize:26,
				multiline:true,
				textAlign:"center",
				wrap:true,
				width:120
				//filters: [new DropShadowFilter(2, 90, 0x604729, 1, 0, 0, 1, 1)]
			});
			voitUsed.x = 60;
			voitUsed.y = titleBackingBmap.y + 80;
			voitCont.addChild(voitUsed);
			
			progressBacking = Window.backingShort(380, "backingBank");
			progressBacking.x = (settings.width - progressBacking.width) / 2 + 55;
			progressBacking.y = titleBackingBmap.y + 90;
			voitCont.addChild(progressBacking);
			
			progressBar = new ProgressBar({typeLine:'sliderBank', win:this, width:376, isTimer:false, tY: -6});
			progressBar.x = progressBacking.x - 18;
			progressBar.y = progressBacking.y - 13;
			voitCont.addChild(progressBar);
			progressBar.progress = 0.5;
			progressBar.start();
			
			progressTitle = drawText('50/100', {
				fontSize:28,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x6e411e,
				shadowColor:0x6b340c,
				shadowSize:1
			});
			
			progressTitle.x = progressBacking.x + progressBacking.width / 2 - progressTitle.width / 2;
			progressTitle.y = progressBacking.y;
			progressTitle.width = 80;
			voitCont.addChild(progressTitle);
			
			
			bubbleBg = new Bitmap(Window.textures.dailyBonusItemBubble);
			bubbleBg.x = progressBacking.x + progressBacking.width - bubbleBg.width/2 - 10;
			bubbleBg.y = progressBacking.y - 30;
			voitCont.addChild(bubbleBg);
			
			
			var date:Date = new Date();
			
			if (App.social == 'OK' && App.data.options.hasOwnProperty('OKEvent')) {
				try {
					var ok_Events:Object = JSON.parse(App.data.options.OKEvent);
				}catch(e:Error) {
					return;
				}
				
				for (var cond:String in ok_Events) {
					var month:int = date.getMonth();
					var day:int = date.getDate();
					var condList:Array = cond.split('.');
					if (condList.length >= 2 && int(condList[0]) == day && int(condList[1]) == month + 1) {
						var lable1:Bitmap = new Bitmap();
						Load.loading(Config.getImage('money', 'OK'), function(data:Bitmap):void {
							lable1.bitmapData = data.bitmapData;
							lable1.x = 100;
							lable1.y = -10;
						});
						
						var lable:Bitmap = new Bitmap();
						
						Load.loading(Config.getImage('money', ok_Events[cond]), function(data:Bitmap):void {
							lable.bitmapData = data.bitmapData;
							lable.smoothing = true;
							
							Numbers.size(lable, 120, 90, false);
							
							lable.x = settings.width - 100 - lable.width / 2;
							lable.y = 15 - lable.height / 2;
						});
						clickCont = new LayerX();
						clickCont.addChild(lable);
						clickCont.addChild(lable1);
						bodyContainer.addChild(clickCont);
						clickCont.addEventListener(MouseEvent.CLICK, onClickContEvent);
						break;
					}
				}
			}
			
			setContentSection(history.section, settings.page);
			//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -40, true, true);
			//drawMirrowObjs('storageWoodenDec', 0, settings.width, settings.height - 120);
			//drawMirrowObjs('storageWoodenDec', 0, settings.width, 40, false, false, false, 1, -1);
		
			contentChange();
			
			exit.x -= 5;
			exit.y -= 25;
			//titleLabel.y -= 4;
			
			
			checkAction();
			
		//	drawCards();
		
			/*if (App.social == 'FB')
			{
				lable1 = new Bitmap();
				Load.loading(Config.getImage('money', 'secure_logos'), function(data:Bitmap):void {
					lable1.bitmapData = data.bitmapData;
					lable1.x = 65;
					lable1.y = settings.height - 120;
				});
				
				lable2 = new Bitmap();
				Load.loading(Config.getImage('money', 'secure_lock'), function(data:Bitmap):void {
					lable2.bitmapData = data.bitmapData;
					lable2.x = settings.width - 65 - lable2.width;
					lable2.y = settings.height - 120;
				});
				
				bodyContainer.addChild(lable1);
				bodyContainer.addChild(lable2);
				
				giftcardBttn = new Button( {
					borderColor:[0xf8f2bd, 0x836a07],
					bgColor:[0xA9DC3C, 0x96C52E],
					fontColor:0x4E6E16,
					fontBorderColor:0xDCFA9B,
					width:		140,
					height:		36,
					fontSize:	24,
					caption:	Locale.__e("flash:1384446450818")
				});
				bodyContainer.addChild(giftcardBttn);
				giftcardBttn.x = settings.width - 80 - giftcardBttn.width;
				giftcardBttn.y = 36;
				giftcardBttn.addEventListener(MouseEvent.CLICK, ExternalApi.onReedem);
				
				changeForFB();
			}*/
			
			/*if (App.social == 'FB' && App.time < dateToFB)  {
				drawTimer();
				App.self.setOnTimer(updateDuration);
			}*/
			snailBitmap = new Bitmap(Window.textures.banksSnail);
			Size.size(snailBitmap, 70, 70);
			snailBitmap.smoothing = true;
			snailBitmap.x = -15;
			snailBitmap.y = settings.height - snailBitmap.height - 36;
			bodyContainer.addChild(snailBitmap);
			
			fader.y -= 25;
		}
		
		private var giftcardBttn:Button;
		private function changeForFB():void {
			if (!isSale()) return;
			//var lable3:Bitmap = new Bitmap();
				//Load.loading(Config.getImage('money', 'fb_sale'), function(data:Bitmap):void {
					//lable3.bitmapData = data.bitmapData;
					//lable3.x = 45;
					//lable3.y = -25;
				//});
			//bodyContainer.addChild(lable3);	
			
			timerText.y = 50-30;
			timerText.x = -35;
			timerText.rotation = 0;
			timerTitle.visible = false;
		}
		
		private function isSale():Boolean {
			var date_from:uint = App.data.money.date_from || App.time;
			if ((App.data.money.date_to > App.time && App.data.money.enabled && App.time && date_from <= App.time) ||
				(App.isSocial('FB') && dateToFB <= App.time && dateToFB > App.time)) {
				return true;
			}
			
			return false;
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xf9fdff,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x5c9900,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: 0x235b00,
				//width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -25;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		/*private var fromDateFB:int = 1423915200;
		private var toDateFB:int = 1624001600;
		private var timerText:TextField;
		private var timerTitle:Sprite;*/
		private var dateToFB:int = 1455523200;
		private var timerTitle:TextField;
		private var timerText:TextField;
		public function drawTimer():void {
			if (App.time < 1455264000 || App.time > dateToFB) 
			{
				return;
			}
			
			/*if (App.social == 'FB' && fromDateFB < App.time && toDateFB > App.time && titleLabel.parent) {
				var _parent:* = titleLabel.parent;
				_parent.removeChild(titleLabel);
				settings.title = Locale.__e('flash:1423736526187');
				drawTitle();
			}
			
			var timerContainer:Sprite = new Sprite();
			timerContainer.mouseEnabled = false;
			bodyContainer.addChild(timerContainer);
			
			var glowing:Bitmap = new Bitmap(Window.textures.actionGlow);
			timerContainer.addChild(glowing);
			glowing.smoothing = true;
			glowing.alpha = .85;
			glowing.scaleX = glowing.scaleY = 0.6;
			//glowing.rotation = -30;
			glowing.x = 5;
			glowing.y = -50;
			
			timerTitle = titleText({
				title:Locale.__e('flash:1382952379793'),
				color:0xffcc00,
				fontSize:53,
				borderColor:0x705535,
				borderSize:8
			});
			
			timerContainer.addChild(timerTitle);
			timerTitle.x = 5;
			timerTitle.y = 15;
			timerTitle.rotation = -30;
			
			var time:int = App.data.money.date_to - App.time;
			
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xf6f1df,
				letterSpacing:0,
				textAlign:"center",
				fontSize:26,
				borderColor:0x817043,
				borderSize:6
			});
			
			timerText.width = 230;
			timerText.y = 90;
			timerText.x = -10;
			//timerText.border = true;
			timerText.rotation = -30
			timerContainer.addChild(timerText);*/
			
			var timerContainer:Sprite = new Sprite();
			timerContainer.mouseEnabled = false;
			timerContainer.x = 205;
			timerContainer.y = -30;
			bodyContainer.addChild(timerContainer);
			
			var glowing:Bitmap = new Bitmap(Window.textures.glowingBackingNew);
			timerContainer.addChild(glowing);
			glowing.smoothing = true;
			glowing.alpha = .5;
			glowing.scaleX = glowing.scaleY = 0.6;
			glowing.x = 100;
			glowing.y = -90;
			
			timerTitle = Window.drawText(Locale.__e('flash:1382952379793'),{
				color:0xffffff,
				fontSize:53,
				borderColor:0x000000,
				borderSize:8
			});
			
			timerContainer.addChild(timerTitle);
			timerTitle.x = 5;
			timerTitle.y = 15;
			timerTitle.rotation = -30;
			
			var time:int = App.data.money.date_to - App.time;
			
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xc6e7f8,
				letterSpacing:0,
				textAlign:"center",
				fontSize:26,
				borderColor:0x3f4081,
				borderSize:2
			});
			
			timerText.width = 230;
			timerText.y = -2;
			timerText.x = 115;
			timerText.rotation = 0;
			timerTitle.visible = false;
			timerContainer.addChild(timerText);
			
			timerContainer.addChild(preloader);
			preloader.x = 235;
			preloader.y = -45;
			preloader.scaleX = preloader.scaleY = 0.7;
			
			var lable3:Bitmap = new Bitmap();
			Load.loading(Config.getImage('money', 'fb_sale'), function(data:Bitmap):void {
				timerContainer.removeChild(preloader);	
				lable3.bitmapData = data.bitmapData;
				lable3.x = 185;
				lable3.y = -75;
			});
			timerContainer.addChild(lable3);		
		}
		
		private function updateDuration():void {
			
			if (App.time < 1455264000 || App.time > dateToFB) 
			{
				return;
			}
			
			var time:int = dateToFB - App.time;
			timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				timerText.visible = false;
				close();
			}
		}
		
		private function drawSeparator():void {
			var paddIng:int = 50;
			var sep:Bitmap = backingShort(settings.width - 2 * paddIng, 'dividerLine');
			sep.alpha = 0.6;
			sep.x = (settings.width - sep.width) / 2;
			sep.y = 40;
			bodyContainer.addChild(sep);
		}
		
		
		private var actionCont:LayerX = new LayerX();
		private var actionTime:TextField;
		private var actionTitle:TextField;
		private var timeToActionEnd:int = 0;
		private function checkAction():void 
		{
			if ((App.data.money && App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1) || App.user.money > App.time) {
				
				if(App.data.money && App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1)
					timeToActionEnd = App.data.money.date_to;
				else if (App.user.money > App.time)
					timeToActionEnd = App.user.money;
				
				/*var btmd:BitmapData = textures.iconEff;
				var invertTransform:ColorTransform = new ColorTransform();
				invertTransform.color = 0xffffff;
				btmd.colorTransform(btmd.rect, invertTransform);*/
				var glowBg:Bitmap = new Bitmap(Window.textures.glowingBackingNew);
				glowBg.scaleX = glowBg.scaleY = 1.3;
				glowBg.smoothing = true;
				actionCont.addChild(glowBg);
			
				actionTitle = drawText(Locale.__e("flash:1382952379793"), {
					color:0xff0000,
					borderColor:0xffffff,
					textAlign:"center",
					autoSize:"center",
					fontSize:38
				});
				actionTitle.y = 30;
				actionTitle.width = actionTitle.textWidth + 10;
				actionCont.addChild(actionTitle);
				
				actionTime = drawText(TimeConverter.timeToStr(timeToActionEnd - App.time), {
					color:0xffd950,
					borderColor:0x402016,
					textAlign:"center",
					autoSize:"center",
					fontSize:40
				});
				actionTime.y = actionTitle.y + actionTitle.textHeight - 4;
				actionTime.x = (glowBg.width - actionTime.width) / 2;
				actionTime.width = actionTime.textWidth + 10;
				actionCont.addChild(actionTime);
				
				actionTitle.x = actionTime.x + (actionTime.width - actionTitle.textWidth) / 2;
				
				App.self.setOnTimer(updateTimeAction);
				
				bodyContainer.addChild(actionCont);
				actionCont.rotation = -25;
				actionCont.x = -120;
				actionCont.y = 30;
			}
		}
		
		private function updateTimeAction():void
		{
			var timeAction:int = timeToActionEnd - App.time;
			if (timeAction < 0) {
				timeAction = 0;
				App.self.setOffTimer(updateTimeAction);
				actionCont.visible = false;
				contentChange();
				return;
			}
			actionTime.text = TimeConverter.timeToStr(timeAction);
		}
		
		private var menu:BankUsualMenu;
		private var giftCardButton:Button;
		private var setsButton:Button;
		public function drawMenu():void 
		{
			menu = new BankUsualMenu(this);
			bodyContainer.addChild(menu);
			menu.y = settings.height - 588;
			menu.x -= 15;
			if (App.social == "FB") 
			{
				//menu.x += 70;
				var gftParams:Object = {
					caption:Locale.__e('flash:1436438494577'),
					bgColor:[0xa8f84a, 0x74bc17],
					borderColor:[0xffffff, 0xffffff],
					bevelColor:[0xc8fa8f, 0x5f9c11],
					fontSize:22,
					fontBorderColor:0x4d7d0e
					//width:102,
					//height:42
				}
				giftCardButton = new Button(gftParams);
				giftCardButton.x = 95;
				giftCardButton.y = 40;
				
				giftCardButton.addEventListener(MouseEvent.CLICK, ExternalApi.onReedem);
				//bodyContainer.addChild(giftCardButton);
			}else {
				//menu.x -= 20;
			}
			
			var setsParams:Object = {
				caption:Locale.__e('flash:1436438494577'),
				bgColor:[0xa8f84a, 0x74bc17],
				borderColor:[0xffffff, 0xffffff],
				bevelColor:[0xc8fa8f, 0x5f9c11],
				fontSize:22,
				fontBorderColor:0x4d7d0e
			}
			setsButton = new Button(setsParams);
			setsButton.x = 95;
			setsButton.y = 40;
			
			setsButton.addEventListener(MouseEvent.CLICK, ExternalApi.onReedem);
			
		}
		
		
		public var cardsLabel:Bitmap = new Bitmap();
		private function drawCards():void {
			if(!cardsLabel.parent){
				Load.loading(Config.getImage('interface', 'cards'), 
									function(data:Bitmap):void {
										cardsLabel.bitmapData = data.bitmapData;
										cardsLabel.x = 60;
										cardsLabel.y = settings.height - 87;
										bodyContainer.addChild(cardsLabel);
										
										App.ui.flashGlowing(cardsLabel);
									} );
			}
			else {
				App.ui.glowing(cardsLabel);
			}
		}
		
		private function onClickContEvent(e:MouseEvent):void {
			/*for (var s:String in App.data.inform) {
				if (App.data.inform[s].enabled && App.data.inform[s].start < App.time && App.data.inform[s].finish > App.time && inSocial(App.data.inform[s].social)) {
					close();
					new InformerWindow({informer:App.data.inform[s]}).show();
					break;
				}
			}
			
			function inSocial(socials:Object):Boolean {
				for (var id:* in socials) {
					if (id == App.social || socials[id] == App.social)
						return true;
				}
				
				return false;
			}*/
		}
		
		public function setContentSection(section:*, page:Number = -1):Boolean
		{
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
				if (icon.type == section) {
					icon.selected = true;
				}
			}
			
			settings.content.splice(0, settings.content.length);
			
			for (var sID:* in App.data.storage) {
				var object:Object = App.data.storage[sID];
				object['sid'] = sID;
				
				if (object.type == section && object.socialprice.hasOwnProperty(App.social))
				{
					settings.content.unshift(object); 
				}
			}
			history.section = section;
			history.page = page;
			
			paginator.itemsCount = settings.content.length;
			paginator.onPageCount = 6;
			if (history.section == 'Sets') {
				paginator.itemsCount = settings.content.length;
				paginator.onPageCount = 4;
			}
			paginator.update();
			
			paginator.update();
			contentChange();
			return true;
		}
		
		public function get currentSale():Object {
			var currSale:Object = new Object();
			for (var decoActId:String in App.data.sales) {
				currSale = App.data.sales[decoActId];
				if ((App.time > currSale.time && App.time < currSale.time + currSale.duration * 3600) && currSale.social.hasOwnProperty(App.social)) {
					break;
				}
			}
			return currSale;
		}
		
		public function set paginatorType(value:String):void {
			var data:Object = {
				Coins: {
					itemsOnPage:6,
					itemsCount:settings.content.length
				},
				Reals: {
					itemsOnPage:6,
					itemsCount:settings.content.length
				},
				Sets: {
					itemsOnPage:4,
					itemsCount:currentSale.items.length
				}
			}
			
			var type:String = 'Coins'
			if (value)
				type = value;
				
				
			settings["itemsOnPage"] = data[type].itemsOnPage;
			paginator.onPageCount = settings.itemsOnPage;
			paginator.itemsCount = data[type].itemsCount;
			
			
			if (history.section == 'Sets') {
				settings.content = [];
				var ln:uint = 0;
				for (var decoItm:String in currentSale.items) {
					settings.content.push(currentSale.items[decoItm])
					ln++;
				}
				paginator.onPageCount = 4;
				paginator.itemsCount = ln;
			}else {
				paginator.onPageCount = 6;
				paginator.onPageCount = settings.itemsOnPage;
				paginator.itemsCount = settings.content.length;
			}
			paginator.update();
		}
		
		public function setContentNews(data:Array):Boolean
		{
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
			}
			
			settings.content = data
			paginator.page = 0;
			
			settings.section = 101;
			paginator.onPageCount = settings.itemsOnPage;
			paginator.itemsCount = settings.content.length;
			paginator.update();
			// 
			contentChange();
			return true;
		}
		
		public function drawBacking():void {
			var backing:Bitmap = Window.backing(600, 490, 15, "shopBackingNew");

			//bodyContainer.addChild(backing);
			backing.x = settings.width/2 - backing.width/2;
			backing.y = 35;
		}
		
		override public function contentChange():void {
			if (history.section == 'Sets') {
				DrawSets();
			}else {
				DrawMoney();
			}
		}
		
		public function removePremiumFlags():void {
			for (var i:int = 0; i < arrLabels.length; i++ ) {
				bodyContainer.removeChild(arrLabels[i]);
				arrLabels[i] = null;
			}
			arrLabels.splice(0, arrLabels.length);
			arrLabels = [];
			
			for (i = 0; i < arrHoles.length; i++ ) {
				bodyContainer.removeChild(arrHoles[i]);
				arrHoles[i] = null;
			}
			arrHoles.splice(0, arrHoles.length);
			arrHoles = [];
		}
		
		public function DrawMoney():void 
		{
			
			for each(var _item:* in items) {
				if(_item && _item.parent){
					bodyContainer.removeChild(_item);
					_item.dispose();
				}
			}
			
			removePremiumFlags();
			
			var profitList:Array = [30, 50, 80, 100, 125];
			if (App.isSocial('YB','GN')) {
				if (history.section == COINS)
					profitList = [25, 87.5, 100, 125];
				else 
					profitList = [25, 50, 81.25, 100, 125];
			}
			profitList.reverse();
			items = [];
			var X:int = 35;
			var Xs:int = X;
			var Ys:int = 80;
			
			//settings.content.sortOn('order', Array.DESCENDING);
			
			var params:Object = {};
			if (App.isSocial('OK') && clickCont)
				params['glow'] = true;
			var padd:uint = 5;
			var itemNum:int = 0;
			
			params.isBestsell = false;
			params.isActionGained = false;
			
			if (timeToActionEnd > App.time)
				params.isBestsell = true;
				
			for (var i:uint = paginator.startCount; i < paginator.finishCount; i++) {
				params['profitValue'] = profitList[i];
				var item:* = new BankUsualItem(settings.content[i], this, params);
				
				bodyContainer.addChildAt(item,0);
				item.x = Xs;
				item.y = Ys + (item.settings.height + padd) * i + padd;
				
				items.push(item);
				itemNum++;
				
				setItemLabel(item);
			var optionItem:int = App.data.options['bankitem'];
			if (item.reward)
				var rewardItem:int = int(item.reward[0]);
			if (settings.glowItem && item.reward && rewardItem == optionItem)
					item.showGlowing();
			}
			
			
			if (settings.section == 101)
				return;
			
			
			settings.page = paginator.page;
		}
		/*override public function contentChange():void {
			if (itemsContainer.parent)
			{
				itemsContainer.parent.removeChild(itemsContainer);
			}
			for each(var _item:* in items) {
				itemsContainer.removeChild(_item);
				_item.dispose();
			}
			
			for (var i:int = 0; i < arrLabels.length; i++ ) {
				bodyContainer.removeChild(arrLabels[i]);
				arrLabels[i] = null;
			}
			arrLabels.splice(0, arrLabels.length);
			arrLabels = [];
			
			for (i = 0; i < arrHoles.length; i++ ) {
				bodyContainer.removeChild(arrHoles[i]);
				arrHoles[i] = null;
			}
			arrHoles.splice(0, arrHoles.length);
			arrHoles = [];
			
			
			items = [];
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 0;
			
			//if (settings.section != 101 && settings.section != 100 && settings.section != 3) 
			settings.content.sortOn('order', Array.NUMERIC);
			
			var params:Object = {};
			var padd:uint = 5;
			var itemNum:int = 0;
			var profitList:Array = [30, 50, 80, 100, 125];
			if (App.isSocial('YB','MX','AI')) 
			{
				if (history.section == REALS) 
				{
					profitList = [5,25,50,66,87]
				}else 
				{
					profitList = [25,25,66,66,66]
				}
				
			}
			profitList.reverse();
			settings.content.reverse();
			for (i = paginator.startCount; i < paginator.finishCount; i++) {
				
				var item:*
				
				params['profitValue'] = 0;
				
				if (App.isSocial('OK') && clickCont)
					params['glow'] = true;
				
				params.isBestsell = (i == 0)?true:false;
				params.isActionGained = false;
				
				if( i < profitList.length )
				params['profitValue'] = profitList[i];
				
				if (i == 0 || i == 2)
				{
					params['backImage'] = 'banksBackingItemBest';
				}
				else
					params['backImage'] = 'banksBackingItem';
				item = new BankUsualItem(settings.content[i], this, params);
				
				itemsContainer.addChild(item);
				item.x = Xs;
				item.y = Ys + (item.settings.height + padd) * i + padd;
				
				items.push(item);
				itemNum++;
				
				setItemLabel(item);
				
				var dX:int = 80;
				
				//bestchoice
				if (i == 0 || i==2){
					item.background.width += dX;
				}
				
				if (i == 0)
					item.bestPrice.visible = true;
					
				if (i == 2)
					item.bestChoice.visible = true;
				

			}

			bodyContainer.addChild(itemsContainer);
			itemsContainer.x = 37;
			itemsContainer.y = menu.y + 50;
			if(snailBitmap)
				bodyContainer.swapChildren(itemsContainer, snailBitmap);
			//itemsContainer.y = 50;
			
			
			if (settings.section == 101)
				return;
			//snailBitmap
			
			settings.page = paginator.page;
		}*/
		
		
		
		public function DrawSets():void 
		{
			
			for each(var _item:* in items) {
				if(_item && _item.parent){
					bodyContainer.removeChild(_item);
					_item.dispose();
				}
			}
			
			removePremiumFlags();
			
			items = [];
			var X:int = 30;
			if (App.isSocial('MX')) X = 80;
			var Xs:int = X;
			var Ys:int = 88;
			
			settings.content.sortOn('order', Array.DESCENDING);
			
			var params:Object = {};
			if (App.isSocial('OK') && clickCont)
				params['glow'] = true;
			var padd:uint = 5;
			var vpadd:uint = 25;
			var itemNum:int = 0;
			var profitList:Array = [30, 50, 80, 100, 125];
			profitList.reverse();
			for (var i:uint = paginator.startCount; i < paginator.finishCount; i++) {
				
				var item:*
				
				params['profitValue'] = 0;
				
				params.isBestsell = (i == 0)?true:false;
				params.isActionGained = false;

				if(i < profitList.length)
				params['profitValue'] = 0;
				settings.content[i]['id'] = i;
				item = new SetItem(settings.content[i], this, params);
				
				bodyContainer.addChildAt(item, 0);
				var mod:int = (i % 2);
				item.x = Xs + (item.settings.width + padd) * (i % 2) + padd+10;
				item.y = Ys + (item.settings.height + vpadd) * (int(i / 2)) + padd;
				
				items.push(item);
				
				itemNum++;
			}
			
			
			if (settings.section == 101)
				return;
			
			settings.page = paginator.page;
			
		}
		
		private var arrLabels:Array = [];
		private var arrHoles:Array = [];
		private function setItemLabel(item:BankUsualItem):void 
		{
			
			
			if (item.isLabel1) {
				switch (App.lang) 
				{
					case 'ru':
					makeLabel(item, UserInterface.textures.labelBD1);	
					break;
					case 'jp':
					makeLabel(item, UserInterface.textures.labelBDJap);		
					break;
					case 'pl':
					makeLabel(item, UserInterface.textures.labelBDPol)		
					break;
					default:
					makeLabel(item, UserInterface.textures.labelBDEng);	
				}
				
			}
			
			if (item.isLabel2) {
				switch (App.lang) 
			{
					case 'ru':
					makeLabel(item, UserInterface.textures.labelUC1);	
					break;
					case 'jp':
					makeLabel(item, UserInterface.textures.labelUCJap);	
					break;
					case 'pl':
					makeLabel(item, UserInterface.textures.labelUCPol)	
					break;
					default:
					makeLabel(item, UserInterface.textures.labelUCEng);
				}
				
			}
			
			
			addLabels();
		}
	
		
		private function addLabels():void 
		{
			for (var i:int = 0; i < arrLabels.length; i++ ) {
				var label:Sprite = arrLabels[i];
				bodyContainer.addChild(label);
			}
		}
		
		private function makeLabel(item:BankUsualItem, btmd:BitmapData):void
		{
			var cont:Sprite = new Sprite();
			//var hole:Bitmap = new Bitmap(UserInterface.textures.hole);
			//hole.x = item.x + item.settings.width - 30;
			//hole.y = item.y + 13;
			//bodyContainer.addChild(hole);
			//arrHoles.push(hole);
			
			var label:Bitmap = new Bitmap(btmd);
			label.smoothing = true;
			cont.addChild(label);
			
			cont.rotation = -50;
			cont.x = item.x + item.settings.width  - 48 + 4;
			cont.y = item.y + 32 + 8;
			
			setTimeout(function():void {
				TweenLite.to(cont, 2, {x:cont.x - 6, y:cont.y - 8, rotation: -30, ease:Elastic.easeOut } );
			}, 200);
			
			arrLabels.push(cont);
		}
		
		override public function drawArrows():void {
			
			/*paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 10;
			paginator.arrowLeft.x = 30;
			paginator.arrowLeft.y = y-5;
			
			paginator.arrowRight.x = settings.width - 30;
			paginator.arrowRight.y = y-5;
			
			paginator.y = settings.height - 44;*/
		}
		
		override public function close(e:MouseEvent=null):void {
				
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_CLOSE_BANK));
			App.self.setOffTimer(updateTimeAction);
			
			super.close(e);
		}
		
		static public function set currentBuyObject(value:Object):void
		{
			_currentBuyObject = value;
		}
		
		static public function get currentBuyObject():Object
		{
			return _currentBuyObject;
		}
		
	}
}