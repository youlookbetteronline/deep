package wins 
{
	/**
	 * ...
	 * @author ...
	 */
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Bridge;
	import units.Techno;
	import wins.elements.BankMenu;
	public class SharkWindow extends Window
	{
		public var item:Object;
		public static const DEFAULT:uint = 0;
		public static const ALL_IN_LINE:uint = 1;
		public var mode:uint = DEFAULT;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var bubbleExit:Bitmap
		public var dx:int;
		public var dy:int;
		protected var upgBttn:Button;
		private var skipBttn:MoneyButton;
		
		public var container:Sprite = new Sprite();
		
		public var resources:Array = [];
		private var prices:Array = [];
		public var partList:Array = [];
		public var partBcList:Array = [];
		
		private var stripeCont:Sprite = new Sprite();
		private var smallWindow:Boolean = false;
		public var textures:Object;
		private var isEnoughMoney:Boolean = false;
		private var level:int;
		protected var itm:Object;
		
		
		private var target:*;
		
		public function SharkWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			settings["width"] = settings.width || 720;
			settings["height"] = settings.height || 590;
			settings["fontSize"] = 44;
			settings["callback"] = settings["callback"] || null;
			settings["hasPaginator"] = false;
			settings['popup'] = true;
			//settings['background'] = "constructBackingBot";
			settings['onUpgrade'] = settings.onUpgrade;
			settings['upgTime'] = settings.upgTime || 0;
			settings['bttnTxt'] = settings.bttnTxt || Locale.__e('flash:1393580216438');
			settings["find"] = settings.find || false;
			settings['exitTexture'] = 'closeBttnMetal';
			settings['bttnCaption'] = settings.bttnCaption || Locale.__e("flash:1487608718012");
			
			settings['notChecks'] = settings.notChecks || false;
			
			mode = settings['mode'] || DEFAULT;
			
			//if (settings.target is Storehouse || settings.target is Mining/* || settings.target is Storehouse || settings.target is Storehouse*/)
				//settings['notChecks'] = true;
			
			if (settings.target.level == 0)
				settings['bttnTxt'] = Locale.__e('flash:1382952379806');
			
			target = settings['target'];
			
			super(settings);
			
			
			
			//var inst:uint = maxInstance();
			//var dataPrice:int = App.data.storage[target.sid].instance.devel[maxInstance()].req[settings.target.level + 1].f;
			
			if (mode != ALL_IN_LINE) {
				var sID:*;
				for (sID in settings.request) {
					switch(sID) {
						case Stock.FANTASY:
							prices.push({sid:sID, count:settings.request[sID]});
							break;
						case Stock.COINS:
							prices.push({sid:sID, count:settings.request[sID]});
							break;
						case Stock.FANT:
							prices.push({sid:sID, count:settings.request[sID]});
							break;
						case App.data.storage[App.user.worldID].techno[0]:
							prices.push({sid:sID, count:settings.request[sID]});
							break;
						default:
							resources.push(sID);
							break
					}
				}
			} else {
				for (sID in settings.request) {
					resources.push(sID);
				}
			}
			
			updateSkipPrice();
			
			if (resources.length == 0) smallWindow = true;
			
			prices.sortOn('sid', Array.NUMERIC);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.addEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);
		}
		
		
		public function findHelp():void 
		{
			if (upgBttn.__hasGlowing) 
			{
				upgBttn.hideGlowing();
			}
			
			if (upgBttn.__hasPointing) 
			{
				upgBttn.hidePointing();	
			}
			
			/*if (App.user.quests.tutorial)
			{
				var showUpgrd:Boolean = true;
				for (var i:int = 0; i < partList.length; i++) {
					if (partList[i].askBttn.visible) 
					{
						partList[i].askBttn.showGlowing();
						partList[i].askBttn.showPointing('bottom', 0, -90, partList[i].askBttn);
						showUpgrd = false;
					}else {
						if (partList[i].askBttn.__hasGlowing)
							partList[i].askBttn.hideGlowing();
							
						if (partList[i].askBttn.__hasPointing)
							partList[i].askBttn.hidePointing();
					}
				}
				if (showUpgrd) 
				{
					upgBttn.showGlowing();
					upgBttn.showPointing('right', 0, 32, upgBttn);
				}
				
			}*/
			
		}
		
		private function onStockChange(e:AppEvent = null):void
		{
			
			if (PostManager.instance.isActive && PostManager.instance.isProgress)
			{
				PostManager.instance.waitPostComplete(onStockChange);
				return;
			}
			
			isEnoughMoney = true;
			
			updateSkipPrice();
			
			if (!lvlSmaller)
			{
				upgBttn.state = Button.NORMAL;
			}
			
			for (var i:int = 0; i < arrBttns.length; i++ )
			{
				var bttn:Button = arrBttns[i];
				if (bttn.order == 1) bttn.removeEventListener(MouseEvent.CLICK, showFantasy);
				else if (bttn.order == 2)bttn.removeEventListener(MouseEvent.CLICK, showBankCoins);
				else if (bttn.order == 3)bttn.removeEventListener(MouseEvent.CLICK, showBankReals);
				else if (bttn.order == 4)bttn.removeEventListener(MouseEvent.CLICK, showTechno);
				bttn.dispose();
				bttn = null;
			}
			arrBttns.splice(0, arrBttns.length);
			
			if (descCont && bodyContainer.contains(descCont) ) {
				bodyContainer.removeChild(descCont);
			}
			
			descCont = null;
			descCont = new Sprite();
			
			for (i = 0; i < partList.length; i++ ) {
				var itm:WorkerItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			if (prices.length > 0)
				drawDescription();
			createResources();
			contentChange();
			findHelp();
		}
		
		private function updateSkipPrice():void 
		{
			skipPrice = 0;
				
			if(skipBttn)
				skipBttn.count = String(skipPrice);	
		}
		
		override public function drawExit():void 
		{
			bubbleExit = new Bitmap(Window.textures.clearBubbleBacking);
			headerContainer.addChild(bubbleExit);
			Size.size(bubbleExit, 82, 82);
			bubbleExit.smoothing = true;
			bubbleExit.x = settings.width - 183;
			bubbleExit.y = 19;
			super.drawExit();
		}
		
		override public function drawBody():void
		{
			exit.x -= 125;
			exit.y += 10;
			drawBackImage();
				
			this.y += 70;
			fader.y -= 70;
			this.x += 60;
			fader.x -= 60;
			
			level = settings.target.level + 1;
	
			drawBackgrounds()
			drawReward();
			
			drawBttn();
			createResources();
			recNeedTxt();
			
			if (prices.length > 0)
				drawDescription();
				
			bodyContainer.addChildAt(container,numChildren - 1);
			container.x = (settings.width - container.width)/2 + 85;
			container.y = 20;
			bttnContainer.y = background.height - 75;
			
			drawTechno();
		}
		
		private var rewardCont:LayerX;
		private function get reward():Object
		{
			return settings.reward;
		}
		
		private function drawReward():void
		{
			if (!reward) return;
			
			if (bonusList)
				bonusList.removeChildren();
			
			var bonusList:CollectionBonusList = new CollectionBonusList(reward,true,{backDafault:false,bgY:10});
			bonusList.x = (settings.width - bonusList.width)/2 - 15;
			bonusList.y = settings.height - bonusList.height - 125;
			bodyContainer.addChild(bonusList);
		}
		
		override public function drawTitle():void 
		{
			
		}
		
		private function onIconComplete(data:*):void 
		{			
			var descContainer:Sprite = new Sprite();
			var stripe:Bitmap = Window.backingShort(380, "rewardStripe");
			descContainer.addChildAt(stripe, 0);
			
			//stripe.x =600;
			//stripe.y = settings.height - 100;
			stripe.scaleY = 0.75
			
			var subTitleOnRibbon:TextField = Window.drawText(Locale.__e("flash:1382952380000"),  {
				fontSize:32,
				color:0xfffddd,
				autoSize:"left",
				borderColor:0x5d3a03
			});
			
			
			descContainer.addChild(subTitleOnRibbon);
			subTitleOnRibbon.x = 230;
			subTitleOnRibbon.y = settings.height - 100;
			
			var perlCoin:Bitmap = new Bitmap;
			perlCoin.bitmapData = (UserInterface.textures.goldenPearl);
			var expCoin:Bitmap = new Bitmap;
			expCoin.bitmapData = (UserInterface.textures.expIcon);
			
			var tabX:Number = subTitleOnRibbon.x +subTitleOnRibbon.textWidth +15;
			var tabY:Number = subTitleOnRibbon.y;
			
			var count:int = (target.devel.rew[level] && target.devel.rew[level][Stock.COINS]) ? target.devel.rew[level][Stock.COINS] : 0
			var countCoins:TextField = Window.drawText(count.toString(),  {
				fontSize:32,
				color:0xFFFFFF,
				autoSize:"left",
				borderColor:0x4d3101
			});
			
			
			
			if (countCoins.text != "") {
				perlCoin.scaleX = perlCoin.scaleY = 0.8;
				perlCoin.smoothing = true;
				perlCoin.x = subTitleOnRibbon.x +subTitleOnRibbon.textWidth +15;
				perlCoin.y =  subTitleOnRibbon.y ;// ( iconTarget.height / 2 - iconTarget.height);
				descContainer.addChild(perlCoin);
				
				countCoins.x = perlCoin.x+countCoins.width;
				countCoins.y = perlCoin.y;
				
				tabX = countCoins.x+countCoins.textWidth ;
				tabY = countCoins.y;
			}
			descContainer.addChild(countCoins);
			
			var exp:int = (target.devel.rew[level] && target.devel.rew[level][Stock.EXP]) ? target.devel.rew[level][Stock.EXP] : 0
			var countExp:TextField = Window.drawText(exp.toString(),  {
				fontSize:32,
				color:0xFFFFFF,
				autoSize:"left",
				borderColor:0x4d3101
			});
			
			if (countExp.text != "") {
				expCoin.scaleX = expCoin.scaleY = 0.8;
				expCoin.smoothing = true;
				expCoin.x = tabX +5;
				expCoin.y =  tabY ;
				descContainer.addChild(expCoin);
			}	
			
			descContainer.addChild(countExp);
			countExp.x = expCoin.x + expCoin.width ;
			countExp.y = expCoin.y;
			bodyContainer.addChild(descContainer)
			descContainer.x = stripeCont.x +stripe.x +(stripe.width - descContainer.width ) / 2
			descContainer.y = stripe.y + 4;
		}
		
		private function drawBackImage():void {	}
		
		private var lvlSmaller:Boolean = false;
		private function drawBttn():void {
			bttnContainer = new Sprite();
			
			var timer:Bitmap = new Bitmap(Window.textures.timerDark, "auto", true);
		
			var timeUpg:int = settings.upgTime;
			var count:String = Locale.__e(TimeConverter.timeToCuts(timeUpg, true, true));
			
			var bttnUpgSettings:Object = {
				caption			:Locale.__e(settings.bttnTxt),
				widthButton		:290,
				height			:55,	
				fontSize		:32,
				radius			:20,
				//countText		:count,
				multiline		:true,
				hasDotes		:false,
				hasText2		:true,
				fontCountSize	:28,
				fontCountColor	:0xffffff,
				fontCountBorder :0x623126,
				textAlign		:"center",	
				bgColor			:[0xf5d058, 0xeeb331],
				bevelColor		:[0xfeee7b, 0xbf7e1a],
				fontBorderColor :0x814f31,
				iconScale		:1,
				iconFilter		:0x814f31
			}
			
			/*if (mode != ALL_IN_LINE) {
				if (count == "") {
					bttnUpgSettings["widthButton"] = 220;
					bttnUpgSettings["caption"] = Locale.__e("flash:1382952379806");
				}
			} else {*/
				bttnUpgSettings["caption"] = Locale.__e('flash:1393580216438');
				
			//}
			
			//if (timeUpg == 0) {
				bttnUpgSettings['widthButton'] = 200;
			//}
			
			upgBttn = new Button({
				caption		:settings.bttnCaption,
				width		:140,
				height		:50,	
				fontSize	:30,
				radius		:26,
				eventPostManager:true
			});
			upgBttn.textLabel.height = 52;
			upgBttn.name = 'construct_bttn';
			upgBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];

			
			if (lvlSmaller) 
			{
				//upgBttn.countLabel.x = upgBttn.coinsIcon.x + (upgBttn.coinsIcon.width - upgBttn.countLabel.width) / 2;
				//upgBttn.topLayer.x += 10;
				upgBttn.state = Button.DISABLED;
			}else{
				if (App.user.quests.tutorial)
				{
					upgBttn.showGlowing();
					upgBttn.showPointing('top', -35, -30);
				}
			}
			
			bttnContainer.addChild(upgBttn);
			upgBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
			
			drawSkpBttn();
			
			bodyContainer.addChild(bttnContainer);
			bttnContainer.x = (settings.width - bttnContainer.width) / 2
			
			if (skipPrice <= 0) {
				upgBttn.visible = true;
				skipBttn.visible = false;
			} else {
				upgBttn.visible = false;
				skipBttn.visible = true;
			}
			
			if (skipBttn.visible) {
				//skipBackground.visible = true;
			}else {
				//skipBackground.visible = false;
			}
		}
		
		override public function contentChange():void 
		{
			
			if (skipPrice <= 0) 
			{
				upgBttn.visible = true;
				skipBttn.visible = false;
			} else 
			{
				upgBttn.visible = false;
				skipBttn.visible = true;
			}

		}
		
		private function drawSkpBttn():void 
		{
			skipBttn = new MoneyButton({
				caption		:Locale.__e("flash:1444918447482"),
				width		:(App.lang == 'jp') || (App.lang == 'fr') ? 200 : 170,
				height		:65,	
				fontSize	:26,
				countText	:90,
				radius		:25
			});
			
			skipBttn.count = String(skipPrice);			
			skipBttn.x = 45;
			skipBttn.y = -20;
			skipBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			upgBttn.x = (bttnContainer.width - upgBttn.width)/2 + 7;
			skipBttn.addEventListener(MouseEvent.CLICK, onSkip);

			bttnContainer.addChild(skipBttn);			
		}
		
		private function onSkip(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			close();
			
			settings.onUpgrade(settings.request, skipPrice);
			
			//var dataPrices:Object = target.devel.obj[settings.target.level + 1]; 
			var dataPrice:int = App.data.storage[target.sid].instance.devel[maxInstance()].req[settings.target.level + 1].f;
			//for (var price:* in dataPrices) {
				App.user.stock.take(3, dataPrice)

			contentChange()
		}
		
		
		public function maxInstance():uint
		{
			var allInstances:Array = Map.findUnits([target.sid]);
			allInstances = allInstances.sortOn("id", Array.NUMERIC);
			
			var instanceNum:int = allInstances.length;
			
			var numInstance:uint = instanceNum;
				
			var iterator:int = 0;
			for (var dd:* in App.data.storage[target.sid].instance.devel)
			{
				iterator++;
			}			
			
			if (numInstance > iterator)
				numInstance = iterator;
				
			return numInstance;
		}
		
		override public function close(e:MouseEvent = null):void 
		{
			super.close();
			settings.find = 0;
		}
		
		override public function drawBackground():void 
		{}
		
		private var iconTarget:Bitmap = new Bitmap();
		public function drawBackgrounds():void 
		{
			background = new Bitmap(Window.textures.sharkWindow);;
			layer.addChild(background);
			
			itm = App.data.storage[settings.target.sid];
		}
		private var iconContainer:LayerX = new LayerX();
		private var technoIn:Bitmap;
		public function drawTechno():void
		{
			technoIn = new Bitmap();
			iconContainer.tip = function():Object {
				return {
					title:App.data.storage[settings.spirit.sid].title,
					text:App.data.storage[settings.spirit.sid].description
				};
			}; 
			Load.loading(Config.getImage('bridge_spirits', App.data.storage[settings.spirit.sid].preview), function(data:Bitmap):void
			{
				technoIn.bitmapData = data.bitmapData;
				technoIn.smoothing = true;
				technoIn.filters = [new DropShadowFilter(7, 105, 0, 0.3, 2.0, 2.0, 1, 3, false, false, false)];
				iconContainer.addChild(technoIn);
				bodyContainer.addChild(iconContainer);
				iconContainer.x = 40;
				iconContainer.y = 70;
			});		
		}
		
		private function onPreviewComplete(data:*):void 
		{
			var animation:Bitmap = new Bitmap;
			var container:Sprite = new Sprite;
			addChild(container);
			
			var Offset:int = 100;
			var _level:uint = (data.sprites.length <= level)?level-1:level;
			iconTarget.bitmapData = data.sprites[_level].bmp;

			iconTarget.x = data.sprites[_level].dx ;
			iconTarget.y = data.sprites[_level].dy;
			
			container.scaleX = container.scaleY = 1
			
			iconTarget.smoothing = true;
			
			container.x = Offset +20;
			container.y =  - container.height;
			container.addChild(iconTarget);
			container.addChild(animation);
			bodyContainer.addChildAt(container, 4);
			bodyContainer.addChild(stripeCont);
			
			if (container.width > 220 ) 
			{
				container.width = 220;
				container.scaleY = container.scaleX;
			}
			
		}
		
		private var descCont:Sprite = new Sprite();
		private var arrBttns:Array = [];
		private var skipPrice:int;
		private var bttnContainer:Sprite;
		private function drawDescription():void 
		{
			var posX:int = 0;
			
			bodyContainer.addChild(descCont);
			
			var contIcon:LayerX = new LayerX();
			
			for (var i:int = 0; i < prices.length; i++ ) {
				var icon:Bitmap;
				var color:int;
				var boderColor:int;
				
				var bttn:Button;
				var bttnSettings:Object = { 
					fontSize:20,
					caption:Locale.__e("flash:1382952379751"),
					height:30,
					width:94,
					radius : 12
				};
				switch(prices[i].sid) {
					case Stock.FANTASY:
						icon = new Bitmap(UserInterface.textures.energyIcon);
						icon.y = 7;
						if (App.user.stock.count(prices[i].sid) < prices[i].count) {
							
							bttnSettings['bgColor'] = [0xa9f84a, 0x73bb16];
							bttnSettings['borderColor'] = [0xffffff, 0xffffff];
							bttnSettings['bevelColor'] = [0xc5fe78, 0x5f9c11];
							bttnSettings['fontColor'] = 0xffffff;				
							bttnSettings['fontBorderColor'] = 0x518410;
							
							bttn = new Button(bttnSettings);
							bttn.addEventListener(MouseEvent.CLICK, showFantasy);
							bttn.order = 1;
						}
						break;
					case Stock.COINS:
						icon = new Bitmap(UserInterface.textures.goldenPearl);
						icon.y = 7;
						if(App.user.stock.count(prices[i].sid) < prices[i].count){
							bttn = new Button( bttnSettings);
							bttn.addEventListener(MouseEvent.CLICK, showBankCoins);
							bttn.order = 2;
						}
						color = 0xfff1cf;
						boderColor = 0x482e16
						break;
					case Stock.FANT:
						icon = new Bitmap(UserInterface.textures.blueCristal);
						icon.y = 7;
						if(App.user.stock.count(prices[i].sid) < prices[i].count){
							bttn = new Button(bttnSettings);
							bttn.addEventListener(MouseEvent.CLICK, showBankReals);
							bttn.order = 3;
						}
						color = 0xfff1cf;
						boderColor = 0x482e16
						break;
					case App.data.storage[App.user.worldID].techno[0]:
						icon = new Bitmap(UserInterface.textures.robotIcon);
						icon.y = 7;
						if((App.user.techno.length - Techno.getBusyTechno()) < prices[i].count){
							bttn = new Button(bttnSettings);
							bttn.addEventListener(MouseEvent.CLICK, showTechno);
							bttn.order = 4;
						}
						color = 0xfff1cf;
						boderColor = 0x482e16;
						
						break;
				}
				if (prices[i].sid == App.data.storage[App.user.worldID].techno[0] && (App.user.techno.length - Techno.getBusyTechno()) < prices[i].count) {
					color = 0xef7563;
					boderColor = 0x623126;
					isEnoughMoney = false;
					upgBttn.state = Button.DISABLED;
					//intervalPluck = setInterval(function():void { if(contIcon && !contIcon.isPluck)contIcon.pluck(30, 25, 25)}, Math.random()* 5000 + 4000);
				}else if (prices[i].sid != App.data.storage[App.user.worldID].techno[0]  && App.user.stock.count(prices[i].sid) < prices[i].count) {
					color = 0xef7563;
					boderColor = 0x623126;

					isEnoughMoney = false;
					upgBttn.state = Button.DISABLED;
					//intervalPluck = setInterval(function():void { if(contIcon && !contIcon.isPluck)contIcon.pluck(30, 25, 25)}, Math.random()* 5000 + 4000);
				}else {
					color = Window.getTextColor(prices[i].sid).color;
					boderColor = Window.getTextColor(prices[i].sid).borderColor;
				}
				
				icon.smoothing = true;
				descCont.addChild(icon);
				icon.x = posX;
				
				var counTxt:TextField = drawText(String(prices[i].count), {
					fontSize:30,
					color:color,
					borderColor:boderColor
				});
			
				counTxt.width = counTxt.textWidth + 5;
				counTxt.height = counTxt.textHeight;
				counTxt.x = icon.x + icon.width + 5;
				counTxt.y = 12;
				
				descCont.addChild(counTxt);
				
				if (bttn) 
				{
					bttn.x = icon.x + (icon.width + counTxt.textWidth + 5 - bttn.width) / 2;
					bttn.y = 52;
					descCont.addChild(bttn);
					arrBttns.push(bttn);
					bttn = null;
				}
				
				posX = counTxt.x + counTxt.width + 30;
			}
			
			bodyContainer.addChild(descCont);
			
			descCont.x = needTxt.x + needTxt.width + 2;
			descCont.y = needTxt.y - 7;
			
		}
		
		private function showTechno(e:MouseEvent):void
		{
			App.ui.upPanel.onRobotEvent();
		}
		
		private function showBankReals(e:MouseEvent):void 
		{
			BankMenu._currBtn = BankMenu.REALS;
			BanksWindow.history = {section:'Reals',page:0};
			new BanksWindow( { popup:true } ).show();

		}
		
		private function showBankCoins(e:MouseEvent):void 
		{
			BankMenu._currBtn = BankMenu.COINS;
			BanksWindow.history = {section:'Coins',page:0};
			new BanksWindow( { popup:true } ).show();
		}
		
		private function showFantasy(e:MouseEvent):void 
		{
			new PurchaseWindow( {
				popup:true,
				closeAfterBuy:false,
				autoClose:false,
				width:716,
				itemsOnPage:4,
				content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Energy'}),
				title:Locale.__e("flash:1382952379756"),
				description:Locale.__e("flash:1382952379757"),
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
		}
		
		private var needTxt:TextField;
		private function recNeedTxt():void
		{
		
			var reqText:String;
			
			reqText = Locale.__e("flash:1382952380003");
			if (target is Bridge)
			{
				if (App.data.storage[target.sid].hasOwnProperty('delete') && App.data.storage[target.sid]['delete'] == 0)
				{
					reqText = Locale.__e("flash:1479733680929");
				}
			}
			
		}
		
		public function createResources():void
		{
			var offsetX:int = 0;
			var offsetY:int = 0;
			var dX:int = 0;
			var count:int = 0;

			
			for (var itm:* in partBcList) {
				if(contains(partBcList[itm]))
				container.removeChild(partBcList[itm]);
			}
			
			for each(var sID:* in resources) {
				
				var inItem:WorkerItem = new WorkerItem({
					sID			:sID,
					need		:settings.request[sID],
					window		:this
				});
			
				inItem.title.multiline = true;
				inItem.title.y -= 5;
				inItem.title.width += 15;
				inItem.checkStatus();
				inItem.buyBttn.y -= 15;
				inItem.buyBttn.height = 40;
				inItem.buyBttn.height = 40;
				inItem.askBttn.y -= 15;
				inItem.askBttn.height = 40;
				inItem.wishBttn.visible = false;
				inItem.searchBttn.visible = false;
				inItem.vs_txt.y = 20;
				inItem.count_txt.y = 20;
				inItem.need_txt.y = 20;
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				partList.push(inItem);
				inItem.y = 65;
				container.addChild(inItem);
				inItem.x = 30 + offsetX;
				
				count++;
				offsetX += 130;
				inItem.background.visible = false;
				
			}
			findHelp();
			inItem.dispatchEvent(new WindowEvent(WindowEvent.ON_CONTENT_UPDATE));
		}
		
		public function onUpdateOutMaterial(e:WindowEvent = null):void 
		{
			
			if (PostManager.instance.isActive && PostManager.instance.isProgress)
			{
				PostManager.instance.waitPostComplete(onUpdateOutMaterial);
				return;
			}
			
			var outState:int = MaterialItem.READY;
			for each(var item:* in partList) {
				if(item.status != MaterialItem.READY){
					outState = item.status;
				}
			}
			
			if (outState == MaterialItem.UNREADY)
			{
				upgBttn.state = Button.DISABLED;
			}
			else if (isEnoughMoney && !lvlSmaller)
			{
				upgBttn.state = Button.NORMAL;
			}
		}
		
		protected function onUpgrade(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			//if(settings.hasState) {
				settings.onUpgrade(settings.request);
			//} else {
				//settings.onUpgrade(target.devel.obj[settings.target.level + 1]);
			//}
			
			close();
		}
		
		override public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);
			
			/*if (App.user.quests.tutorial)
			{
				if (App.user.quests.currentQID == 5)
				{
					QuestsRules.quest5_1();
				}
				
				if (App.user.quests.currentQID == 12)
				{
					if (QuestsRules.crill.level == 0)
						QuestsRules.quest12_2_1();
						
					if (QuestsRules.crill.level == 1)
						QuestsRules.quest12_2_2();
				}
			}*/
			
			if (upgBttn) 
			{
				upgBttn.removeEventListener(MouseEvent.CLICK, onUpgrade);
				upgBttn.dispose();
				upgBttn = null;
			}
			
			for (var i:int = 0; i < arrBttns.length; i++ ) 
			{
				var bttn:Button = arrBttns[i];
				if (bttn.order == 1) bttn.removeEventListener(MouseEvent.CLICK, showFantasy);
				else if (bttn.order == 2)bttn.removeEventListener(MouseEvent.CLICK, showBankCoins);
				else if (bttn.order == 3)bttn.removeEventListener(MouseEvent.CLICK, showBankReals);
				else if (bttn.order == 4)bttn.removeEventListener(MouseEvent.CLICK, showTechno);
				bttn.dispose();
				bttn = null;
			}
			arrBttns.splice(0, arrBttns.length);
			
			
			for (i = 0; i < partList.length; i++ ) 
			{
				var itm:WorkerItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			super.dispose();
		}
		
	}		
}
