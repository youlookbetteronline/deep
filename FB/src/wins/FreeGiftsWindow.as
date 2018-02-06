package wins 
{
	import buttons.Button;
	import buttons.CheckboxButton;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import flash.display.Bitmap;
	import flash.display.CapsStyle;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import flash.filters.GlowFilter;
	import flash.ui.Mouse;
	import ui.UserInterface;
	import ui.WishListManager;
	
	public class FreeGiftsWindow extends Window
	{
		public static const FREE:uint = 1;
		public static const TAKE:uint = 2;
		public static const ASK:uint = 3;
		
		public var paginatorDown:Paginator
		
		public var bitmap:Bitmap;
		public var container:Sprite;		
		public var ListFree:Array = new Array;
		public var ListTake:Array = new Array;		
		public var listItems:Array = new Array;
		public var takeItems:Array = new Array;		
		public var items:Array = new Array;		
		public var freeGiftsBttn:MenuButton;								
		public var takeGiftsBttn:MenuButton;
		public var askGiftsBttn:MenuButton;
		public var takeAllBttn:Button;		
		public var limitLabel:Sprite = new Sprite();
		public var countLimitLabel:TextField = null;
		public var capasitySprite:LayerX = new LayerX();
		public var capasityBar:Bitmap;	
		public var requestsCont:Sprite = new Sprite();
		public var descCont:Sprite = new Sprite();
		private var mode:uint = FREE;		
		private var capasitySlider:Sprite = new Sprite();
		private var capasityCounter:TextField;	
		private var requestsLabel:TextField;	
		private var requestsCounter:TextField;	
		private var descLabel:TextField;	
		private var descCounter:TextField;	
		private var backText:Shape = new Shape();	
		
		/**
		 * Конструктор
		 * @param	settings	настройки
		 */ 
		
		public function FreeGiftsWindow(settings:Object = null) 
		{
			if (settings == null)
			{
				settings = new Object();
			}
			
			settings["title"]			= Locale.__e("flash:1382952380112");			
			settings["width"]			= 686;
			settings["height"] 			= 618;			
			settings["fontSize"] 		= 38;
			settings["fontColor"] 		= 0xffffff;
			settings["multiline"] 		= true;
			settings["textLeading"] 	= -6;			
			settings["hasPaginator"] 	= false;
			settings["autoClose"] 		= false;
			settings["background"] 		= 'buildingBacking';
			settings["startMode"] =  settings.mode || FREE;
			settings["paginatorSettings"] = {buttonsCount: 3};
			mode = settings.mode || FREE
			showedAlready = false;
			super(settings);
		}
		
		override public function dispose():void {
			
			super.dispose();
			
			for each(var item:* in items)	item.dispose();
			for each(item in listItems)	item.dispose();
			for each(item in takeItems)	item.dispose();
			for each(item in ListFree)	item.dispose();
			for each(item in ListTake)	item.dispose();
			
			if(items)items.splice(0, items.length);
			if(listItems)listItems.splice(0, listItems.length);
			if(takeItems)takeItems.splice(0, takeItems.length);
			if(ListFree)ListFree.splice(0, ListFree.length);
			if(ListTake)ListTake.splice(0, ListTake.length);
			items = null;
			listItems = null;
			takeItems = null;
			ListFree = null;
			ListTake = null;
			
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
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -6;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBackground():void {
			if (settings.background!=null) 
			{ //QuestBackingTop QuestBackingBot
			var background:Bitmap = backing2(settings.width, settings.height, 50, 'constructBackingUp', 'constructBackingBot');//= backing(settings.width, settings.height, 50, settings.background);
			layer.addChild(background);	
			}
		}
		
		override public function drawBody():void {
			exit.y -= 5;
			exit.x -= 18;
			
			drawBackgroundElement();
			drawMirrowObjs('decSeaweed', settings.width + 38, - 38, settings.height - 180, true, true, false, 1, 1);
			var titleBackingBmap:Bitmap = backingShort(380, 'shopTitleBacking');
			
			titleBackingBmap.x = (settings.width - titleBackingBmap.width)/ 2;
			titleBackingBmap.y = -77;
			bodyContainer.addChild(titleBackingBmap);
			
			var star1:Bitmap = new Bitmap(Window.textures.decStarBlue);
			star1.x = titleBackingBmap.x + titleBackingBmap.width + star1.width/2 - 15;
			star1.y = -star1.height / 2;
			star1.smoothing = true;
			
			var star2:Bitmap = new Bitmap(Window.textures.decStarYellow);
			star2.x = titleBackingBmap.x - star2.width - 14;
			star2.y = -star2.height / 2;
			star2.smoothing = true;
			
			var star3:Bitmap = new Bitmap(Window.textures.decStarRed);
			star3.x = 7;
			star3.y = -star2.height / 2 - 8;
			star3.smoothing = true;
			
			bodyContainer.addChild(star1);
			bodyContainer.addChild(star2);
			bodyContainer.addChild(star3);
			
			var downPlankBmap:Bitmap = backingShort(300, 'shopPlankDown');
			downPlankBmap.x = settings.width / 2 -downPlankBmap.width / 2;
			downPlankBmap.y = settings.height - downPlankBmap.height + 10;
			layer.addChild(downPlankBmap);
			
			createBttns();
			//createTakeBttns()
			
			settings.content = {
				free:createFreeContent(),
				take:App.user.gifts
			};
				
			createPaginators();
			changeRazdel(mode);
			
			//drawDecorations();
			
			addSlider();
			descCont.x = (settings.width - descCont.width) / 2;
		}
		
		public function drawDescription():void{
			descCont = new Sprite();
			var descText:String;
			switch (settings.mode){
				case FREE: descText = Locale.__e('flash:1493108079781'); break;
				case ASK: descText = Locale.__e('flash:1493023425774'); break;
			}
			backText.graphics.beginFill(0xffffff);
		    backText.graphics.drawRect(0, 0, settings.width - 200, 44);
			backText.y = 72;
			backText.x = (settings.width - backText.width) / 2;
		    backText.graphics.endFill();
			backText.filters = [new BlurFilter(40, 0, 2)];
			backText.alpha = .4;
		    bodyContainer.addChild(backText);
			
			descLabel = Window.drawText(descText, {
				color:0xffffff,
				borderColor:0x6e411e,
				fontSize:32,
				textAlign:"left"//,
				//width: 280
			});
			
			descLabel.width = descLabel.textWidth + 10;
			descLabel.y = backText.y + (backText.height - descLabel.textHeight) / 2;
			descCont.addChild(descLabel);
			
			descCounter = Window.drawText(String(" " + WishListManager.count + "/" + WishListManager.MAX_COUNT), {
				color:0xffdf34,
				borderColor:0x6e411e,
				fontSize:32,
				textAlign:"left"
			});
			descCounter.width = descCounter.textWidth + 8;
		
			descLabel.x = 0;
			descCounter.x = descLabel.x + descLabel.textWidth + 6;
			descCounter.y = descLabel.y;
			if (settings.mode == ASK)
				descCont.addChild(descCounter)
			
			descCont.x = (settings.width - descCont.width) / 2;
			bodyContainer.addChild(descCont);
	
		}
		
		override public function close(e:MouseEvent = null):void {
			if (App.wl.lastSID!=0) 
			{
				App.wl.dispose();
			}
			
			if (settings.hasAnimations == true) {
				startCloseAnimation();
			}else {
				dispatchEvent(new WindowEvent("onBeforeClose"));
				dispose();
			}
		}
		
		/*private function drawDecorations():void {
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -40, true, true);
			drawMirrowObjs('storageWoodenDec', 0, settings.width + 2, settings.height - 118);
			drawMirrowObjs('storageWoodenDec', 1, settings.width + 3, 45, false, false, false, 1, -1);
		}*/
		
		private function addSlider():void
		{
			capasityBar = new Bitmap(Window.textures.prograssBarBacking);
			
			Window.slider(capasitySlider, 60, 50, "progressBar");
			
			bodyContainer.addChild(capasitySprite);
			
			
			var textSettings:Object = {
				color:0xffffff,
				borderColor:0x7b4003,
				fontSize:30,
				borderSize:4,
				textAlign:"center"
			};
			
			//textSettings.fontSize = 24;
			capasityCounter = Window.drawText("", textSettings); 
			capasityCounter.width = 120;
			
			capasitySprite.mouseChildren = false;
			capasitySprite.addChild(capasityBar);
			capasitySprite.addChild(capasitySlider);
			capasitySprite.addChild(capasityCounter);
			//capasitySprite.y -= 50;
			//capasitySlider.x = (capasityBar.width - capasitySlider.width)/2; capasitySlider.y = (capasityBar.height - capasitySlider.height)/2;
			
			capasitySprite.scaleX = capasitySprite.scaleY = 1;
			
			var txtTaked:TextField = Window.drawText(Locale.__e('flash:1393580533220'), {
					color		:0xffffff,
					borderColor	:0x6e411e,
					fontSize	:25,
					textAlign	:"center",
					autoSize	:"center",
					//multiline	:true,
					//wrap		:true
					width		:130
				}
			);
			//txtTaked.border = true;
			txtTaked.width = 110;
			capasitySprite.addChild(txtTaked);
			
			
			capasityBar.x = 35;
			capasityBar.y  = 32;
			capasitySlider.x = capasityBar.x + 1; //слайдер, бар
			capasitySlider.y = 33;
			txtTaked.x = capasityBar.x - txtTaked.width - 5;
			txtTaked.y = 31;
			
			capasitySprite.x = settings.width / 2 - capasityBar.width / 2; 
			capasitySprite.y = 60;
			
			capasityCounter.x = capasityBar.x + (capasityBar.width - capasityCounter.width) / 2; 
			capasityCounter.y = capasityBar.height / 2 - capasityCounter.textHeight / 2 - 10;
			
			updateCapasity();
		}
		
		public function updateCapasity():void {
			App.ui.bottomPanel.updateGiftCount();
			if (!capasityCounter) return;
			//App.user
			var maxValue:int = (App.data.options['GiftsLimit']+((App.user.stock.check(Stock.GIFT_EXTENDER))?App.user.stock.data[Stock.GIFT_EXTENDER]:0));
		//	maxValue += +(App.user.stock.check(Stock.GIFT_EXTENDER))?App.user.stock.data[Stock.GIFT_EXTENDER]:0;;
			var currValue:int = App.user.gifts.length;
			
			//trace(App.user.stock.check(Stock.GIFT_EXTENDER));
			//trace((App.user.stock.check(Stock.GIFT_EXTENDER))?App.user.stock.data[Stock.GIFT_EXTENDER]:0);
			
			Window.slider(capasitySlider, currValue,maxValue, "progressBar");
			capasityCounter.text = String(currValue) +'/' +  String(maxValue);
			capasityCounter.height = capasityCounter.textHeight;
			capasityCounter.y = capasityBar.height / 2 - capasityCounter.textHeight / 2 + 32;
			capasityCounter.x = capasityBar.x + capasityBar.width / 2 - capasityCounter.width / 2; 
		}
		
		private function createFreeContent():Array
		{
			var spisok:Array = []
			for (var sID:* in App.data.storage)
			{
				if (App.data.storage[sID].type == 'Material' && App.data.storage[sID].free == 1)
				{
					if (App.data.storage[sID].visible == 0 || (App.data.updatelist[App.social].hasOwnProperty(User.getUpdate(sID)) 
					&& App.data.updates[User.getUpdate(sID)].temporary == 1 && ((App.data.updatelist[App.social][(User.getUpdate(sID))] 
					+ App.data.updates[User.getUpdate(sID)].duration * 3600) < App.time)))
						continue;
					
					spisok.push(sID);
				}
			}
			
			return spisok;
		}
		
		private var giftsCounter:TextField;
		private var requestCounter:TextField;
		private function createBttns():void
		{
			var menuCont:Sprite = new Sprite();
			freeGiftsBttn = new MenuButton( {
				title:				Locale.__e("flash:1382952380137"),
				giftMode:				FREE,
				fontSize:				21,
				height:					45,
				width:					125,
				multiline:				true,
				bgColor: 			[0xfed131, 0xf8ab1a],
				bevelColor: 		[0xf7fe9a, 0xcb6b1e],
				fontColor: 			0xffffff,
				fontBorderColor:	0x7f3d0e,
				active:{
					bgColor:				[0xfed131, 0xf8ab1a],
					fontSize: 				36,
					bevelColor:				[0xcb6b1e, 0xf7fe9a],
					fontColor:				0xffffff,
					fontBorderColor:		0x7f3d0e			//Цвет обводки шрифта		
				}
			});
				
			menuCont.addChild(freeGiftsBttn);
			freeGiftsBttn.textLabel.y -= 3;
			freeGiftsBttn.addEventListener(MouseEvent.CLICK, bttnClick);
			//freeGiftsBttn.x = 0;
			freeGiftsBttn.y = -10;
			
			/*if (WishListManager.totalFriendsRequests > 0)
			{
				var textYellowSettings:Object = {
					color:0xf0e9db,
					borderColor:0x7e3e13,
					fontSize:14,
					textAlign:"center"
				};
				
				var counterRequestPanel:Bitmap = new Bitmap(UserInterface.textures.simpleCounterYellow);
				counterRequestPanel.x = freeGiftsBttn.width - counterRequestPanel.width / 2;
				counterRequestPanel.y = -3;
				//countRequest = WishListManager.totalFriendsRequests;
				
				requestCounter = Window.drawText(String(WishListManager.totalFriendsRequests), textYellowSettings);
				requestCounter.width = 30;
				requestCounter.height = requestCounter.textHeight;
				requestCounter.x = counterRequestPanel.x + (counterRequestPanel.width - requestCounter.width)/ 2;
				requestCounter.y = counterRequestPanel.y + (counterRequestPanel.height  - requestCounter.height) / 2 - 2;
				freeGiftsBttn.addChild(counterRequestPanel)
				freeGiftsBttn.addChild(requestCounter)
			}*/
			
			takeGiftsBttn = new MenuButton( {
				title:				Locale.__e("flash:1382952379786"),
				giftMode:				TAKE,
				fontSize:				21,
				height:					45,
				width:					125,
				multiline:				true,
				bgColor: 				[0x65b8ef, 0x567bce],
				bevelColor: 			[0xcce8fa, 0x4465b6],
				fontColor: 				0xffffff,
				fontBorderColor: 		0x2b4a84,
				active:{
					bgColor:				[0x65b8ef,0x567bce],
					bevelColor:				[0x4465b6, 0xcce8fa],
					fontColor:				0xffffff,
					fontBorderColor:		0x2b4a84			//Цвет обводки шрифта		
				}
			} );
			
			menuCont.addChild(takeGiftsBttn);								
			takeGiftsBttn.addEventListener(MouseEvent.CLICK, bttnClick);
			takeGiftsBttn.x = freeGiftsBttn.x + freeGiftsBttn.bottomLayer.width + 15;
			takeGiftsBttn.y = -10;
			takeGiftsBttn.textLabel.y -= 3;
			
			/*if (App.user.gifts.length > 0)
			{
				var textBlueSettings:Object = {
					color:0xf0e9db,
					borderColor:0x005ab4,
					fontSize:14,
					textAlign:"center"
				};
				
				var counterPanel:Bitmap = new Bitmap(UserInterface.textures.simpleCounterBlue);
				counterPanel.x = takeGiftsBttn.width - counterPanel.width / 2;
				counterPanel.y = -3;
				
				giftsCounter = Window.drawText(String(App.user.gifts.length), textBlueSettings);
				giftsCounter.width = 30;
				giftsCounter.height = giftsCounter.textHeight;
				giftsCounter.x = counterPanel.x + (counterPanel.width - giftsCounter.width)/ 2;
				giftsCounter.y = counterPanel.y + (counterPanel.height  - giftsCounter.height) / 2 - 2;
				takeGiftsBttn.addChild(counterPanel)
				takeGiftsBttn.addChild(giftsCounter)
			}*/
			//var counterPanel:Bitmap = new Bitmap(UserInterface.textures.simpleCounterBlue);
			drawCounters();
			askGiftsBttn = new MenuButton( {
				title:				Locale.__e("flash:1382952379975"),
				giftMode:				ASK,
				fontSize:				21,
				height:					45,
				width:					125,
				multiline:				true,
				bgColor: [0xcbec6e, 0x85b937],
				bevelColor: [0xf8ffbe, 0x648a38],
				fontColor: 0xffffff,
				fontBorderColor: 0x53742d,
				active:{
					bgColor:				[0xcbec6e,0x85b937],
					bevelColor:				[0x648a38, 0xf8ffbe],
					fontColor:				0xffffff,
					fontBorderColor:		0x53742d			//Цвет обводки шрифта		
				}
			});
										
			askGiftsBttn.addEventListener(MouseEvent.CLICK, bttnClick);
			askGiftsBttn.x = takeGiftsBttn.x + takeGiftsBttn.bottomLayer.width + 15;
			askGiftsBttn.y = -10;
			askGiftsBttn.textLabel.y -= 3;
			if (App.isSocial('FB', 'FBD'))									
				menuCont.addChild(askGiftsBttn);	
			
			takeAllBttn = new Button( {
				caption:				Locale.__e("flash:1382952380115"),
				fontSize:				21,
				height:					34,
				width:					110
			});
								
			//bodyContainer.addChild(takeAllBttn);								
			takeAllBttn.addEventListener(MouseEvent.CLICK, onTakeAllBttn);
			takeAllBttn.x = settings.width - takeAllBttn.width - 35;
			takeAllBttn.y = 56;	
			
			menuCont.y = 33;
			menuCont.x = (settings.width - menuCont.width) / 2;
			bodyContainer.addChild(menuCont);
			//giftsImproveButton = new Button(
			//{
				//caption : Locale.__e("flash:1393580216438"),
				//fontSize: 21,
				//height:	42,
				//width: 110,
				//color: 0xcaebfc,
				//bgColor : [0x97c9fe, 0x5e8ef4],
				//borderColor : [0xffdad3, 0xc25c62],
				//bevelColor : [0xb3dcfc, 0x376dda],
				//fontColor : 0xffffff,
				//multiline: true
			//}
			//);
			//giftsImproveButton.addEventListener(MouseEvent.CLICK, giftsImprove);
			//giftsImproveButton.x = settings.width/2 + giftsImproveButton.width + 60;
			//giftsImproveButton.y = giftsImproveButton.height + 8;
			//bodyContainer.addChild(giftsImproveButton);
		}
		private var counterRequestPanel:Bitmap;
		private var counterPanel:Bitmap;
		private function drawCounters():void
		{
			if (counterPanel && counterPanel.parent)
				counterPanel.parent.removeChild(counterPanel);
			if (counterRequestPanel && counterRequestPanel.parent)
				counterRequestPanel.parent.removeChild(counterRequestPanel);
				
			if (giftsCounter && giftsCounter.parent)
				giftsCounter.parent.removeChild(giftsCounter);
			if (requestCounter && requestCounter.parent)
				requestCounter.parent.removeChild(requestCounter);
				
			if (freeGiftsBttn && WishListManager.totalFriendsRequests > 0)
			{
				var textYellowSettings:Object = {
					color:0xf0e9db,
					borderColor:0x7e3e13,
					fontSize:14,
					textAlign:"center"
				};
				
				counterRequestPanel = new Bitmap(UserInterface.textures.simpleCounterYellow);
				counterRequestPanel.x = freeGiftsBttn.width - counterRequestPanel.width / 2;
				counterRequestPanel.y = -3;
				//countRequest = WishListManager.totalFriendsRequests;
				
				requestCounter = Window.drawText(String(WishListManager.totalFriendsRequests), textYellowSettings);
				requestCounter.width = 30;
				requestCounter.height = requestCounter.textHeight;
				requestCounter.x = counterRequestPanel.x + (counterRequestPanel.width - requestCounter.width)/ 2;
				requestCounter.y = counterRequestPanel.y + (counterRequestPanel.height  - requestCounter.height) / 2 - 2;
				freeGiftsBttn.addChild(counterRequestPanel)
				freeGiftsBttn.addChild(requestCounter)
			}
			if (takeGiftsBttn && App.user.gifts.length > 0)
			{
				var textBlueSettings:Object = {
					color:0xf0e9db,
					borderColor:0x005ab4,
					fontSize:14,
					textAlign:"center"
				};
				
				counterPanel = new Bitmap(UserInterface.textures.simpleCounterBlue);
				counterPanel.x = takeGiftsBttn.width - counterPanel.width / 2;
				counterPanel.y = -3;
				
				giftsCounter = Window.drawText(String(App.user.gifts.length), textBlueSettings);
				giftsCounter.width = 30;
				giftsCounter.height = giftsCounter.textHeight;
				giftsCounter.x = counterPanel.x + (counterPanel.width - giftsCounter.width)/ 2;
				giftsCounter.y = counterPanel.y + (counterPanel.height  - giftsCounter.height) / 2 - 2;
				takeGiftsBttn.addChild(counterPanel)
				takeGiftsBttn.addChild(giftsCounter)
			}
		}
		private function giftsImprove(e:MouseEvent):void
		{
			
		}
		
		private function onTakeAllBttn(e:MouseEvent):void
		{
			Gifts.grab(refreshRazdel);
		}
		
		private function bttnClick(e:MouseEvent):void
		{
			changeRazdel(e.currentTarget.settings.giftMode);
		}
			
		public function changeRazdel(mode:uint):void
		{
			settings.mode = mode;
			paginator.hide();
			
			paginator.visible = false;
			var index:int = 0;
			switch(mode)
			{
				case FREE:
					
					takeGiftsBttn.state = Button.NORMAL;
					askGiftsBttn.state = Button.NORMAL;
					freeGiftsBttn.state = Button.ACTIVE;
					drawBackgroundElement(mode);
					paginator.onPageCount = 6;
					paginator.show(settings.content.free.length);
					paginator.visible = true;
					
					if (mode == FREE && settings['find'] != undefined) {
						index = settings.content.free.indexOf(settings.find[0]);
						if(index != -1){
							paginator.page = index / paginator.onPageCount;
							paginator.update();
						}
					}
					capasitySprite.visible = false;
					
					takeAllBttn.visible = false;
					//giftsImproveButton.visible = false;
				break;
				
				case ASK:
					
					takeGiftsBttn.state = Button.NORMAL;
					askGiftsBttn.state = Button.ACTIVE;
					freeGiftsBttn.state = Button.NORMAL;
					drawBackgroundElement(mode);
					paginator.onPageCount = 6;
					paginator.show(settings.content.free.length);
					paginator.visible = true;
					
					if (mode == ASK && settings['find'] != undefined) {
						index = settings.content.free.indexOf(settings.find[0]);
						if(index != -1){
							paginator.page = index / paginator.onPageCount;
							paginator.update();
						}
					}
					capasitySprite.visible = false;
					
					takeAllBttn.visible = false;
					//giftsImproveButton.visible = false;
				break;
				
				case TAKE:
					takeGiftsBttn.state = Button.ACTIVE;
					freeGiftsBttn.state = Button.NORMAL;
					askGiftsBttn.state = Button.NORMAL;
					drawBackgroundElement(mode);
					for (var i:int = 0; i < settings.content.take.length; i++) {
						var uid:String = settings.content.take[i].from
						if (!App.user.friends.data.hasOwnProperty(uid))
						{
							settings.content.take.splice(i, 1);
						}
					}
					
					paginator.onPageCount = 3;
					paginator.show(settings.content.take.length);
					paginator.visible = true;
					
					if (mode == TAKE && settings['find'] != undefined) {
						index = settings.content.take.indexOf(settings.find[0]);
						if(index != -1){
							paginator.page = index / paginator.onPageCount;
							paginator.update();
						}
					}
					
					if (App.user.gifts.length == 0) takeAllBttn.state = Button.DISABLED;
					takeAllBttn.visible = true;
					
					capasitySprite.visible = true;
					//giftsImproveButton.visible = true;
				break;
			}
			
			contentChange();
		}
		
		private var itemsCount:int = 0;
		private var itemsOnPage:int = 0;
		private function onChangeFree():void
		{
			drawDescription();
			//drawAvailableRequests();	
			itemsCount = 0;
			itemsOnPage = 6;
			var Xs:int = 90;
			var Ys:int = 120; // bgDecor
			var X:int = Xs;
			
			for each(var _item:* in items)
			{
				_item.dispose();
				bodyContainer.removeChild(_item);
				_item = null;
			}
			items = [];
			
			var itemNumb:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:FreeGiftItem = new FreeGiftItem(settings.content.free[i], settings.mode, this);
				bodyContainer.addChild(item);
				item.x = int(Xs);
				item.y = int(Ys);
				itemsCount++;
				items.push(item);
				Xs += item.bg.width + 10;
				
				if (itemNumb == 2){
					Xs = X;
					Ys += item.bg.height + 10;
				}
				//if (WishListManager.count == 0)
					//UserInterface.colorize(item, 0x676767, 0.5);
				
				itemNumb++;
			}
			
			if (settings.mode == FreeGiftsWindow.ASK) {
				if(WishListManager.count >= WishListManager.MAX_COUNT) {
					for each(_item in items) {
						if (_item._time < App.time) {
							_item.giftBttn.state = Button.DISABLED;
						}
					}
				}
			}
			
		}
		
		
		private function drawAvailableRequests():void{
			
			var totalRequests:int = 3;

			requestsLabel = Window.drawText(Locale.__e('flash:1493023425774'), {
				width			:100,
				fontSize		:24,
				autoSize		:"center",
				color			:0x7dfdff,
				borderColor		:0x7d3400
			} );
			requestsLabel.x = 0;
			requestsLabel.y = 0;
			requestsCont.addChild(requestsLabel);
			
			requestsCounter = Window.drawText(WishListManager.count + "/" + WishListManager.MAX_COUNT, {
				color:			0xf5ff57,
				borderColor:	0x7d3400,
				width:			100,
				fontSize:		20,
				textAlign:		'left'
			});
			requestsCounter.x = requestsLabel.x + requestsLabel.width + 5;
			requestsCounter.y = 0;
			requestsCont.addChild(requestsCounter);
			requestsCont.x = (settings.width - requestsCont.width) / 2;
			
			//if (requestsCont && requestsCont.parent)
				//bodyContainer.parent.removeChild(requestsCont);
				
			bodyContainer.addChild(requestsCont);
			requestsCont.visible = false;
			if (settings.mode == ASK)
				requestsCont.visible = true;
			
		}

		//private var itemWidth:int = 170;
		//private var itemHeight:int = 206;
		
		private function onChangeTake():void
		{
			var Xs:int = 75;
			var Ys:int = 90 + 38;// bgDecor
			var X:int = Xs;
			itemsCount = 0;
			itemsOnPage = 3;
			
			for each(var _item:* in items)
			{
				_item.dispose();
				bodyContainer.removeChild(_item);
				_item = null;
			}
			items = [];
			
			var itemNumb:int = 0;
			for (var i:int = paginator.startCount; i <  paginator.finishCount; i++)
			{
				var item:TakeItem = new TakeItem({
					window:this,
					data:settings.content.take[i] 
					//width:itemWidth,
					//height:itemHeight
				});
				
				bodyContainer.addChild(item);
				item.x = int(Xs);
				item.y = int(Ys);
				itemsCount++;
				items.push(item);
				Ys += item.bg.height + 10;
				
				itemNumb++;
			}
			
			if (settings.find != null&& settings.startMode == TAKE&&!showedAlready) 
			{
				var showEmptyMessage:Boolean = true;
				for (var j:int = 0; j < items.length; j++) 
				{
					if (items[j].glow) {
						showEmptyMessage = false;
					}
				}
				if (showEmptyMessage ) 
				{
					showedAlready = true;
					new SimpleWindow( {
					popup:true,
					title:Locale.__e('flash:1382952379725'),
					text:Locale.__e('flash:1425035536904')
				}).show();
				}
			}
			updateCapasity();
		}
		
		public override function contentChange():void 
		{
			drawCounters();
			if (requestsCont && requestsCont.parent)
				requestsCont.parent.removeChild(requestsCont);
			
			if (descCont && descCont.parent)
				descCont.parent.removeChild(descCont);
				
			if (backText && backText.parent)
				backText.parent.removeChild(backText);
			
				
			switch (settings.mode){
				case FREE:onChangeFree(); break;
				case TAKE:onChangeTake(); break;
				case ASK:onChangeFree(); break;
			}
			/*if (settings.mode == FREE)	onChangeFree();
			else onChangeTake();*/
			
			//createPaginators();
		}
		
		public function createPaginators():void {
			paginator = new Paginator(itemsCount, itemsOnPage, 3, {
				hasArrow:true,
				hasButtons:true
			});
		
			paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);
			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  55, settings.height/2 - 20, { scaleX:-1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, settings.width - 55, settings.height/2 - 20, { scaleX:1, scaleY:1 } );
			bottomContainer.y += 20;
			
			bottomContainer.addChildAt(paginator,0)
			paginator.x = int((settings.width - paginator.width)/2) - 10;
			paginator.y = int(settings.height - paginator.height - 12);
		}
		
		/*public function refreshRazdel()
		{
			countLimitLabel.text = NumberConverter.convert(Profile.maxCostGifts - Profile.costGifts);
			
			takeItems = createTakeItems();
			paginatorDown.itemsCount = takeItems.length;
			paginatorDown.update();
			onDownChange();
			
			if (takeItems.length == 0)
			{
				takeAllBttn.state = Button.DISABLED
			}
		}*/
		
		//private var bgDecor:Bitmap;
		private var showedAlready:Boolean;
		private function drawBackgroundElement(mode:uint = 0):void
		{
			/*if(bgDecor && bgDecor.parent){
				bodyContainer.removeChild(bgDecor);
				bgDecor = null;
			}*/
			
			var bgTop:uint = 95;
			var bgHt:uint = 460;
			
			if (mode && mode == FREE) {
				bgTop = 93;
				bgHt = 450;
			}
			
			/*bgDecor = Window.backing(561, bgHt, 40, "shopBackingMain");
			bodyContainer.addChild(bgDecor);
			bgDecor.x = (settings.width - bgDecor.width)/2;
			bgDecor.y = bgTop;
			if(bodyContainer.numChildren>1){
				var chOb:* = bodyContainer.getChildAt(0);
				if (chOb != bgDecor) {
					bodyContainer.swapChildren(bgDecor, chOb);
				}
			}*/
			//bgDecor.alpha = 0.7;
		}
		
		public function refreshRazdel():void{
			drawCounters();
			if (settings.mode == FREE) return;
			
			settings.content.take = App.user.gifts;
			paginator.itemsCount = settings.content.take.length;
			paginator.update();
			onChangeTake();
			
			if (settings.content.take.length == 0)
			{
				takeAllBttn.state = Button.DISABLED;
			}
		}	
		
		public function blockItems(block:Boolean = false):void
		{
			if (settings.mode == FREE) return;
			
			var item:TakeItem;
			if (!block) {
				for each(item in items)
					item.takeBttn.state = Button.NORMAL;
			}else{
				for each(item in items)
					item.takeBttn.state = Button.DISABLED;
			}
		}
	}	
}


import buttons.Button;
import buttons.ImageButton;
import com.greensock.TweenMax;
import core.AvaLoad;
import core.Load;
import core.Log;
import core.Post;
import core.Size;
import core.TimeConverter;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.filters.BlurFilter;
import flash.geom.Point;
import ui.WishListManager;
import wins.FreeGiftsWindow;
import wins.GiftWindow;
import wins.AskWindow;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.Window;
import wins.RequestWindow;

//	храним ячейки
internal class FreeGiftItem extends Sprite
{
	public var sID:uint;
	public var _mode:uint;
	private var info:Object;
	private var bitmap:Bitmap;
	public var bg:Bitmap;
	private var leftLabelTitle:TextField;
	private var leftLabelTimer:TextField;
	public var giftBttn:Button;
	public var wishBttn:ImageButton;
	public var win:FreeGiftsWindow;
	private var preloader:Preloader = new Preloader();
	
	public function FreeGiftItem(sID:uint, _mode:int, window:FreeGiftsWindow)
	{
		win = window;
		info = App.data.storage[sID];
		this.sID = sID;
		this._mode = _mode;
		bg = Window.backing(162, 190, 10, "itemBacking");
		addChild(bg);
		
		addChild(preloader);
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height) / 2 - 15;
		
		drawBitmap();

		drawTitle();
		if (_mode == FreeGiftsWindow.FREE)
			drawCountRequest();
			
		drawBttn();
		
		if (window.settings.find != null && window.settings.find.indexOf(int(sID)) != -1 && (window.settings.startMode == FreeGiftsWindow.FREE || window.settings.startMode == FreeGiftsWindow.ASK)) 
		{
			glowing();
		}
		
		
	}
	
	public var _time:int = 0;
	
	private function drawBttn():void
	{
		var text:String;
		if (_mode == FreeGiftsWindow.FREE)
			text = Locale.__e("flash:1382952380118");
		if (_mode == FreeGiftsWindow.ASK)
			text = Locale.__e("flash:1382952379975");
		/*switch (_mode){
			FREE: text = Locale.__e("flash:1382952380118"); break;
		}*/
		giftBttn = new Button({
			caption		:text,
			width		:116,
			height		:36,
			fontSize	:24,
			onMouseDown :onGiftBttn,
			hasDotes:false
		});
		
		addChild(giftBttn);
		giftBttn.x = (bg.width - giftBttn.width) / 2;
		giftBttn.y = bg.height - giftBttn.height* 1.3;
		
		
		wishBttn = new ImageButton(Window.textures.wishlistBttn);
		if(!App.isSocial('FB', 'FBD'))
			addChild(wishBttn);
		wishBttn.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380013")
			};
		};
		
		wishBttn.x = 0;
		wishBttn.y = 40;
		wishBttn.addEventListener(MouseEvent.CLICK, onWishEvent);
	}
	
	private function onWishEvent(e:MouseEvent):void
	{
		//trace(bttnWishListGlow + " click_____wish");
		wishBttn.hidePointing();
		/*if (wishBttn.) 
		{
			
		}*/
		App.wl.show(sID, e, bttnWishListGlow);
		bttnWishListGlow = false;
	}
	
	private function onGiftBttn(e:MouseEvent):void
	{
		
		if (_mode == FreeGiftsWindow.FREE) {
			win.close();	
			new GiftWindow( {
				sID:		this.sID,
				iconMode:	GiftWindow.FREE_GIFTS,
				itemsMode:	GiftWindow.FRIENDS
			}).show();
		} if (_mode == FreeGiftsWindow.ASK) {
				
			Gifts.openRequestWindow(sID, askEvent);
		}
	}
	
	private function askEvent():void
	{
		win.changeRazdel(FreeGiftsWindow.ASK);
	}
	
	private function drawBitmap():void
	{
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		Load.loading(Config.getIcon(info.type, info.preview), onPreviewComplete);
		
		sprite.tip = function():Object { 
			return {
				title:info.title,
				text:info.description
			};
		};
		
		if (_mode == FreeGiftsWindow.ASK) {
			_time = WishListManager.getTime(sID);
			if(_time > App.time)
				drawTimer();
		}
	}
		
	public function onPreviewComplete(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.x = (bg.width - bitmap.width) / 2;
		//if (_mode == FreeGiftsWindow.ASK)
			//bitmap.y = (bg.height - bitmap.height) / 2 - 25;
		//else
			bitmap.y = (bg.height - bitmap.height) / 2 - 10;
	}
	
	public function dispose():void
	{
		if (giftBttn) giftBttn.dispose();
	}
	
	private function drawCountRequest():void
	{
		var count:int = WishListManager.getRequestCount(String(sID));
		if (count > 0)
		{
			var backing:Bitmap = new Bitmap(Window.textures.comfortBacking);
			Size.size(backing, 40, 40);
			backing.alpha = .8;
			backing.smoothing = true;
			backing.x = 4;
			backing.y = 25;
			addChild(backing);
			
			var countRequest:TextField = Window.drawText(String(count), {
				color:0xffffff,
				//border:false,
				borderColor:0x7d4e32,
				textAlign:"center",
				//autoSize:"center",
				fontSize:24,
				multiline:true,
				wrap:true
				//width:bg.width - 50
			});
			//countRequest.border = true;
			countRequest.y = backing.y + (backing.height - countRequest.height) / 2;
			countRequest.x = backing.x + (backing.width - countRequest.width) / 2;
			addChild(countRequest);
		}
	}
	
	private function drawTitle():void
	{
		var title:TextField = Window.drawText(info.title, {
			color:0x7d4e32,
			border:false,
			borderColor:0xffffff,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			multiline:true,
			wrap:true,
			width:bg.width - 50
		});
			
		//title.wordWrap = true;
		//title.width = bg.width - 50;
		title.y = bg.y;
		title.x = (bg.width - title.width)/2;
		addChild(title);
	}
	
	private function reDrawTimer():void
	{
		var left:int = _time - App.time;
		if (left < 0) {
			App.self.setOffTimer(reDrawTimer);
			delete App.user.wishlist[sID];
			win.changeRazdel(FreeGiftsWindow.ASK);
		}
		leftLabelTimer.text = TimeConverter.timeToStr(left);
	}
	private function drawTimer():void
	{
		var timerCont:Sprite = new Sprite();
		
		var timerBack:Shape = new Shape();
		timerBack.graphics.beginFill(0xffffff, .7);
		timerBack.graphics.drawRect(0, 0, bg.width - 30, 30);
		timerBack.graphics.endFill();
		timerBack.filters = [new BlurFilter(30, 0)];
		addChild(timerBack);
		timerBack.x = bg.x + (bg.width - timerBack.width) / 2;
		timerBack.y = bg.y + bg.height - timerBack.height - 45;
		
		leftLabelTitle = Window.drawText(Locale.__e('flash:1393581955601'), {
			width			:100,
			fontSize		:18,
			autoSize		:"center",
			color			:0x7dfdff,
			borderColor		:0x7d3400
		} );
		timerCont.addChild(leftLabelTitle);		//	добавляем надпись
		leftLabelTitle.x = 0;
		leftLabelTitle.y = 0;
		
		
		leftLabelTimer = Window.drawText('',{
			color:			0xf5ff57,
			borderColor:	0x7d3400,
			width:			100,
			fontSize:		20,
			textAlign:		'left'
		});
		leftLabelTimer.x = leftLabelTitle.x + leftLabelTitle.width + 5;
		leftLabelTimer.y = 0;
		leftLabelTimer.width = 80;
		//leftLabelTimer.border = true;
		App.self.setOnTimer(reDrawTimer);
		timerCont.addChild(leftLabelTimer);	
		timerCont.x = bg.x + (bg.width - timerCont.width) / 2 + 10;
		timerCont.y = bg.height - 70;
		//trace(bg.x);
		addChild(timerCont);	//	добавляем спарйте на окно
		reDrawTimer();
	}
	
	public var bttnWishListGlow:Boolean = false;
	
	public var bttnWishListPoint:Boolean = false;
		
	private function glowing(mode:int = 1):void 
	{
		//customGlowing(bg, glowing);
		if (win.settings.startMode == FreeGiftsWindow.ASK)
		{
			if (giftBttn) 
			{
				customGlowing(giftBttn,glowing);
			}
		}else{
			if (win.settings['icon'] != undefined && win.settings.icon == 'wishlist') 
			{
				customGlowing(wishBttn, glowing);
				if (!bttnWishListPoint) 
				{
					wishBttn.showPointing("top",0,0,wishBttn.parent);
					bttnWishListPoint = true;
				}
				
				bttnWishListGlow = true;
				//	App.wl.show(sID, e,true);
				
			//	wishBttn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}else{
				if (giftBttn) {
					customGlowing(giftBttn,glowing);
				}
			}
		}
	
	
	}
	
	private function customGlowing(target:*, callback:Function = null):void {
		TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
				if (callback != null) {
					callback();
				}
			}});	
		}});
	}
}


import wins.Window;
import wins.FreeGiftsWindow;
import wins.StockWindow;
			
internal class TakeItem extends Sprite
{ 
	public var bg:Bitmap;	
	public var data:Object;
	public var win:FreeGiftsWindow;
	
	private var imageCont:Sprite;
	private var bitmap:Bitmap;
	private var title:TextField;
	private var userTitle:TextField;
	private var counter:TextField;
	
	private var regiftBttn:Button;
	public var takeBttn:Button;
	public var closeBttn:ImageButton;
	public var glow:Boolean;
	
	private var avatar:Bitmap
	private var avaCont:Sprite
	
	private var message:Sprite
	private var cutText:String;
	private var fullText:String;
	private var messText:TextField;
	private var messBg:Bitmap;
	
	private var preloader:Preloader = new Preloader();
	private var avaPreloader:Preloader = new Preloader();
	
	public function TakeItem(settings:Object){
		  
		this.data = settings.data;
		this.win = settings.window;
		bg = Window.backing(530, 115, 20, "itemBacking");
		addChild(bg);
		
		imageCont = new Sprite();
		
		//var contBg:Bitmap = Window.backing(110, 110, 10, "bonusBacking");
		var backgroundShape:Shape = new Shape();
		backgroundShape.graphics.beginFill(0xe59e79);
		backgroundShape.graphics.drawCircle(50, 50, 50);
		backgroundShape.graphics.endFill();
		
		var contBg:Bitmap = new Bitmap(new BitmapData(100, 100, true, 0));
		contBg.bitmapData.draw(backgroundShape);
		//searchBg.graphics.lineStyle(2, 0x47424e, 1, true);
		/*contBg.graphics.beginFill(0xd7cda2, 1);
		contBg.graphics.drawRoundRect(0, 0, 130, 110, 30, 30);
		contBg.graphics.endFill();*/
		contBg.y += 1;
		
		bitmap = new Bitmap();
		
		imageCont.addChild(contBg);
		imageCont.addChild(bitmap);
		
		addChild(imageCont);
		imageCont.x = (bg.width - imageCont.width) / 2 - 10;
		imageCont.y = (bg.height - imageCont.height) / 2;
		
		drawTitle();
		drawCount();
		drawBttns();
		
		avaCont = new Sprite();
		avatar = new Bitmap();
		
		avaCont.addChild(avatar);
		addChild(avaCont);
		avaCont.x = 60;
		avaCont.y = 36;
		
		avaPreloader.x = 90;
		avaPreloader.y = 70;
		Log.alert('data.from '+data.from);
		Log.alert('App.user.friends.data[data.from].first_name '+App.user.friends.data[data.from].first_name);
		Log.alert('App.user.friends.data[data.from].photo '+App.user.friends.data[data.from].photo);
		if (App.user.friends.data.hasOwnProperty(data.from)&&App.user.friends.data[data.from].hasOwnProperty('first_name')&&App.user.friends.data[data.from].first_name&&App.user.friends.data[data.from].hasOwnProperty('photo')&&App.user.friends.data[data.from].photo){
			drawAvatar();
		}else {
			addChild(avaPreloader);
			App.self.setOnTimer(checkOnLoad);
		}
		
		if (data.msg.length > 1)	drawMessage();
		
		addChild(preloader);
		preloader.x = imageCont.x + contBg.width / 2;
		preloader.y = imageCont.y + contBg.height / 2;
		glow = false;
		Load.loading(Config.getIcon(App.data.storage[data.sID].type, App.data.storage[data.sID].preview), onLoad);
		if (settings.window.settings.find != null && settings.window.settings.find.indexOf(int(data.sID)) != -1 &&settings.window.settings.startMode == FreeGiftsWindow.TAKE) {
			glowing();
		}
	}
	
	private function glowing():void 
	{
			glow = true;
			if (takeBttn) {
				customGlowing(takeBttn,glowing);
			}
		
	}
	
	private function checkOnLoad():void 
	{
		//if (App.user.friends.data[data.from].hasOwnProperty('first_name'))
		if (App.user.friends.data[data.from].hasOwnProperty('aka')) //Временно?
		{
			App.self.setOffTimer(checkOnLoad);
			removeChild(avaPreloader);
			drawAvatar();
		}
	}
	
	private function onLoad(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 0.6;
		bitmap.x = 100 / 2 - bitmap.width / 2;
		bitmap.y = 120 / 2 - bitmap.height / 2;
		bitmap.smoothing = true;
	}
	
	private function drawAvatar():void
	{
		var sender:Object = App.user.friends.data[data.from];
		
		new AvaLoad(App.user.friends.data[data.from].photo, onAvaLoad); 
		//App.user.friends.data[data.from].photo = Config.getImageIcon('avatars','ChiefAvatar'); 
		//new AvaLoad(Config.getImageIcon('avatars','ChiefAvatar'), onAvaLoad); // временно
		
		
		//userTitle = Window.drawText(sender.first_name.substr(0, 15), App.self.userNameSettings({
		if (sender.uid == '1')
		{
			sender.aka = Locale.__e('flash:1382952379733');
		}
		var params:Array = sender.aka.split(" ");
		userTitle = Window.drawText(params[0], App.self.userNameSettings({
		//var akkName:String = "Какой-то друг";
		//userTitle = Window.drawText(akkName.substr(0, 15), App.self.userNameSettings({ //временно?
									color:0xffffff,
									borderColor:0x6e411e,
									fontSize:22
								}));
		addChild(userTitle);
		userTitle.height = userTitle.textHeight;
		userTitle.width = userTitle.textWidth + 4;
		userTitle.x = 90 - userTitle.width / 2;
		userTitle.y = 8;
	}
	
	private function onAvaLoad(data:Bitmap):void
	{
		avatar.bitmapData = data.bitmapData;
		avatar.smoothing = true;
				
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, 50, 50, 12, 12);
		shape.graphics.endFill();
		avaCont.mask = shape;
		avaCont.addChild(shape);
		
		var scale:Number = 1.3;
		
		avaCont.width *= scale;
		avaCont.height *= scale;
		
		if (avaPreloader.parent)
		{
			avaPreloader.parent.removeChild(avaPreloader);
		}
		//removeChild(avaPreloader);
	}
	
	private function drawBttns():void
	{
		regiftBttn = new Button({
			caption:				Locale.__e("flash:1382972712784"),
			multiline:				true,
			fontSize:				22,
			height:					50,
			width:					120,
			textAlign:				"center",
			//borderColor:			[0x9f9171,0x9f9171],
			//fontColor:				0x4c4404,
			fontBorderColor:		0x28648f,
			bgColor:				[0x71d0f7, 0x5984cb],
			bevelColor:				[0xd6f0ff,0x405ea4],
			mouseDown:				onRegiftClick,
			hasDotes:false
		});
			
		//addChild(regiftBttn);	
		//regiftBttn.x = bg.width - regiftBttn.width - 40;
		//regiftBttn.y = 10;
		//regiftBttn.addEventListener(MouseEvent.CLICK, onRegiftClick);
			
		takeBttn = new Button( {
			caption:Locale.__e("flash:1382952379786"),
			fontSize:22,
			height:40,
			width:120,
			textAlign:"center",
			onMouseDown:onTake,
			hasDotes:false
		});
			
		addChild(takeBttn);	
		takeBttn.x = bg.width - takeBttn.width - 40;
		//takeBttn.y = regiftBttn.y + regiftBttn.height + 5;
		takeBttn.y = (bg.height - regiftBttn.height)/2 + 5;
		
		if (data.type == Gifts.SPECIAL /*|| data.from == "1"*/){ //временно
			regiftBttn.visible = false;
			takeBttn.y = bg.height / 2 - takeBttn.height / 2;
		}
		
		closeBttn = new ImageButton(Window.textures.closeBttnSmall, {
				onMouseDown:onClose
			});
		addChild(closeBttn);
		closeBttn.x = bg.width - 30;
		closeBttn.y = bg.y - 0;
		closeBttn.addEventListener(MouseEvent.CLICK, onClose);
	}
	
	private function onClose(e:MouseEvent):void 
	{
		Gifts.remove(data.gID, function():void 
		{
			win.refreshRazdel();
		});
		win.updateCapasity();
	}
	
	private function onRegiftClick(e:MouseEvent):void
	{
		win.close();
		
			//new StockWindow( /*{
				//target:stocks[0]
			//}*/).show();
			
		new GiftWindow( {
			//sID:		this.sID,
			iconMode:	GiftWindow.FREE_GIFTS,
			itemsMode:	GiftWindow.FRIENDS,
			find:data.from
		}).show();
	}
	
	private function drawTitle():void
	{
		title = Window.drawText(App.data.storage[data.sID].title, {
			color:0xffffff,
			borderColor:0x764a3e,
			textAlign:"center",
			autoSize:"center",
			fontSize:20,
			multiline:true,
			border: 2,
			textLeading: -8
		});
		
		title.wordWrap = true;
		title.width = imageCont.width;
		imageCont.addChild(title);
		title.y = 2;
	}
	
	private function drawCount():void
	{
		counter = Window.drawText("x"+String(data.count), {
			color:0xffffff,
			borderColor:0x764a3e,
			fontSize:28
		});
		
		imageCont.addChild(counter);
		counter.x = imageCont.width - counter.textWidth - 14;//70;
		counter.y = 66;
	}
	
	public function dispose():void
	{
		App.self.setOffTimer(checkOnLoad);
	}
	
	private function showCutMessage(e:MouseEvent = null):void
	{
		if (messBg != null && message.contains(messBg)) 		message.removeChild(messBg);
		if (messText != null && message.contains(messText)) 	message.removeChild(messText);
		
		messBg = Window.backing(192, 60, 30, "banksBackingItem");
		message.addChild(messBg);
		
		messText = Window.drawText(cutText,
		{
			autoSize:"left",
			fontSize:17,
			border:false,
			color:0x6d4b15,
			multiline:true
		});
		messText.wordWrap = true;
		messText.width = 172;
		messText.height = 10;
		
		message.addChild(messText);
		messText.x = 10;
		messText.y = 10;
	}
	
	private function showFullMessage(e:MouseEvent = null):void
	{
		if (fullText == null || fullText == "") return;
		
		if (messBg != null && message.contains(messBg)) 		message.removeChild(messBg);
		if (messText != null && message.contains(messText)) 	message.removeChild(messText);
		
		messBg = Window.backing(352, 60, 30, "banksBackingItem");
		message.addChild(messBg);
		
		messText = Window.drawText(fullText,
						{
							autoSize:"left",
							fontSize:17,
							border:false,
							color:0x6d4b15,
							multiline:true
						});
		messText.wordWrap = true;
		messText.width = 332;
		messText.height = 10;
		
		message.addChild(messText);
		messText.x = 14;
		messText.y = 10;
	}
	
	public function drawMessage():void
	{
		return;
		message = new Sprite();
		message.addEventListener(MouseEvent.MOUSE_OVER, showFullMessage);
		message.addEventListener(MouseEvent.MOUSE_OUT, showCutMessage);
		message.buttonMode = true;
		message.mouseChildren = false;
		
		addChild(message);
		message.x = 0;
		message.y = 80;
		
		var text:String = data.msg;//"Привет, вот тебе подарочек от меня. Жду в ответ что-нибудь flash:1382952379993 моего списка желаний";
		if (text.length > 55)
		{
			fullText = text;
			cutText = "";
			var wordsArray:Array = text.split(" ");
			
			for (var i:int = 0; i < wordsArray.length; i++)
			{
				var Length:int = cutText.length + wordsArray[i].length;
				if (Length > 55)
				{
					cutText += "...";
					break;
				}
				else
				{
					cutText += " " + wordsArray[i];
				}
			}
		}
		else
		{
			cutText = text; 
			fullText = null;
		}
		
		showCutMessage();
	}
	
		
	private function onTake(e:MouseEvent):void
	{
		var rew:Object = { };
		rew[data.sID] = int(data.count);
		var targetPoint:Point = Window.localToGlobal(e.currentTarget);
		Gifts.take(data.gID, function(block:Boolean, data:Object = null):void 
		{
			if (block == true) {
				win.refreshRazdel();
				win.blockItems(block);
			}
			else
			{
				win.blockItems(block);
			}
			
			for (var sID:* in data) {
				if (sID == Stock.FANT || sID == Stock.COINS || sID == Stock.FANTASY) {
					var item:*;
					item = new BonusItem(sID, data[sID]);
					item.cashMove(targetPoint, App.self.windowContainer)
				}
			}
		});
		win.updateCapasity();
	}
	
	private function customGlowing(target:*, callback:Function = null):void {
		TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
				if (callback != null) {
					callback();
				}
			}});	
		}});
	}
}	