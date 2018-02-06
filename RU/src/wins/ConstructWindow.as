package wins 
{
	/**
	 * ...
	 * @author ...
	 */
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Numbers;
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
	
	public class ConstructWindow extends Window
	{
		public var item:Object;
		public static const DEFAULT:uint = 0;
		public static const ALL_IN_LINE:uint = 1;
		public var mode:uint = DEFAULT;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var bitmapBack:Bitmap = new Bitmap(null, "auto", true);
		public var dx:int;
		public var dy:int;
		//private var upgBttn:UpgradeButton;
		protected var upgBttn:Button;
		protected var skipBttn:MoneyButton;
		//private var skipBackground:Bitmap;
		
		protected var container:Sprite = new Sprite();
		
		protected var backLine:Bitmap;
		protected var backField:Bitmap;
		
		protected var resources:Array = [];
		protected var prices:Array = [];
		protected var partList:Array = [];
		protected var partBcList:Array = [];
		
		protected var stripeCont:Sprite = new Sprite();
		protected var smallWindow:Boolean = false;
		public var textures:Object;
		protected var bgHeight:int;
		protected var isEnoughMoney:Boolean = false;
		protected var buildingBackImage:Bitmap;
		protected var skipPrices:Array = [];
		protected var level:int;
		protected var totallevels:int;
		protected var itm:Object;
		
		protected var frame:uint = 0;
		protected var frameLength:uint = 0;
		
		protected var chain:Object;
		protected var target:*;
		
		public var ax:int = 0;
		public var ay:int = 0;
		public var multipleAnime:Object = {};
		public var framesType:String = "work";
		
		public var framesTypes:Array = [];
		public var animationBitmap:Object = [];
		
		public function ConstructWindow(settings:Object = null):void
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
			settings['onUpgrade'] = settings.onUpgrade;
			settings['upgTime'] = settings.upgTime || 0;
			settings['bttnTxt'] = settings.bttnTxt || Locale.__e('flash:1393580216438');
			settings["find"] = settings.find || false;
			
			settings['notChecks'] = settings.notChecks || false;
			
			mode = settings['mode'] || DEFAULT;
			
			bgHeight = settings["height"];
			
			if (settings.target.level == 0)
				settings['bttnTxt'] = Locale.__e('flash:1382952379806');
			
			target = settings['target'];
			
			super(settings);
			
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
						/*case Stock.FANT:
							prices.push({sid:sID, count:settings.request[sID]});
							break;*/
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
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: 38,				
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
			titleLabel.y = -16;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		protected function findHelp():void 
		{
			if (upgBttn.__hasGlowing) 
			{
				upgBttn.hideGlowing();
			}
			
			if (upgBttn.__hasPointing) 
			{
				upgBttn.hidePointing();	
			}
			
			if (App.user.quests.tutorial)
			{
				var showUpgrd:Boolean = true;
				for (var i:int = 0; i < partList.length; i++) {
					if (partList[i].askBttn.visible) 
					{
						partList[i].askBttn.showGlowing();
						partList[i].askBttn.showPointing('bottom', -30, -120, partList[i].askBttn);
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
				
			}
			/*if (settings.find) {
				var showUpgrd:Boolean = true;
				for (var i:int = 0; i < partList.length; i++) {
					if (partList[i].askBttn.visible) 
					{
						partList[i].askBttn.showGlowing();
						showUpgrd = false;
					}else {
						if (partList[i].askBttn.__hasGlowing)
						partList[i].askBttn.hideGlowing();
					}
				}
				if (showUpgrd) 
				{
					upgBttn.showGlowing();
					upgBttn.showPointing('bottom', 0, 120, upgBttn);//bttnContainer);
				}
				
			}*/
		}
		
		protected function onStockChange(e:AppEvent = null):void {
			
			if (PostManager.instance.isActive && PostManager.instance.isProgress){
				PostManager.instance.waitPostComplete(onStockChange);
				return;
			}
			
			isEnoughMoney = true;
			
			updateSkipPrice();
			
			if (!lvlSmaller)
			{
				upgBttn.state = Button.NORMAL;
				/*if (App.user.quests.tutorial)
				{
					upgBttn.showGlowing();
					upgBttn.showPointing('up', 0, 120, upgBttn);//bttnContainer);
				}*/
			}
			
			for (var i:int = 0; i < arrBttns.length; i++ ) {
				var bttn:Button = arrBttns[i];
				if (bttn.order == 1) bttn.removeEventListener(MouseEvent.CLICK, showFantasy);
				else if (bttn.order == 2)bttn.removeEventListener(MouseEvent.CLICK, showBankCoins);
				else if (bttn.order == 3)bttn.removeEventListener(MouseEvent.CLICK, showBankReals);
				else if (bttn.order == 4)bttn.removeEventListener(MouseEvent.CLICK, showTechno);
				bttn.dispose();
				bttn = null;
			}
			arrBttns.splice(0, arrBttns.length);
			
			/*if (needTxt && bodyContainer.contains(needTxt) ) {
				bodyContainer.removeChild(needTxt);
			}*/
			
			if (descCont && bodyContainer.contains(descCont) ) {
				bodyContainer.removeChild(descCont);
			}
			
			descCont = null;
			descCont = new Sprite();
			
			for (i = 0; i < partList.length; i++ ) {
				var itm:MaterialItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			if(prices.length > 0)drawDescription();
			//if (!smallWindow) {
				createResources();
			//}
			contentChange();
			findHelp();
		}
		
		protected function updateSkipPrice():void 
		{
			skipPrice = 0;
			//skipPrice = App.data.storage[settings.target.sid].instance.devel[1].req[settings.target.level + 1].f;
			/*var dataPrices:Object = App.data.storage[settings.target.sid].instance.devel[1].obj[settings.target.level + 1];
			for (var price:* in dataPrices) {
				if (!App.user.stock.check(price, dataPrices[price])) {
					var count:int = App.user.stock.count(price);
					var needCount:int = dataPrices[price] - count;
					
					//if (App.data.storage[settings.target.sid].instance.devel[1].req[settings.target.level + 1].f) {}
					if (App.data.storage[price].hasOwnProperty('price')) {
						var leftPrice:int = needCount * App.data.storage[price].price[Stock.FANT];
						skipPrice += leftPrice;
					}
				}
			}*/
			
			if(skipBttn)
				skipBttn.count = String(skipPrice);	
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width  -3;
			exit.y = 4;
		}
		
		override public function drawBody():void {
			
			var titleBackingBmap:Bitmap = backingShort(400, 'shopTitleBacking');
			titleBackingBmap.x = settings.width / 2 - titleBackingBmap.width / 2;
			titleBackingBmap.y = -85;
			bodyContainer.addChild(titleBackingBmap);
			
			drawMirrowObjs('decShell', titleBackingBmap.x + titleBackingBmap.width + 83, titleBackingBmap.x - 83, titleBackingBmap.y + 20, true, true, false, 1, 1, bodyContainer);
			
			drawBackImage();
			resizeBack();
			//darwDecor();
			
			titleLabel.y = -16;
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			
			if (resources.length == 3) {
				titleLabel.x = 70;
			}
			
			if (resources.length == 5) {
				titleLabel.x = 170;
			}
			
			
			this.y += 20;
			fader.y -= 20;
			//smallWindow = true;
			//bgHeight = settings.height; 
			if (smallWindow) {
				bgHeight = 200;
				this.y += 100;
				fader.y -= 100;
			}
			
			/*if (settings.hasState) {
				var underTitle:Bitmap = Window.backingShort(180, "orangeStripPiece");
				underTitle.x = (settings.width - underTitle.width) / 2;
				underTitle.y = 6;
				bodyContainer.addChild(underTitle);
				
				var subTitle:TextField = Window.drawText(Locale.__e("flash:1397573560652") + ": " +  settings.state + "/" + settings.statesTotal, {
					fontSize:24,
					color:0xFFFFFF,
					autoSize:"left",
					borderColor:0xb56a17
				});
				//bodyContainer.addChild(subTitle);
				
				subTitle.x = settings.width / 2 - subTitle.width / 2;
				subTitle.y = underTitle.y + 8;
				
				bgHeight += 30;
				this.y -= 30;
				fader.y += 30;
			};*/
			
			
			//var txt:String = Locale.__e("1382952380004");
			level = settings.target.level + 1;
			totallevels = settings.target.totalLevels /*+ settings.target.craftLevels - 1*/;
			
			var needTxt:TextField = Window.drawText(Locale.__e("flash:1382952380004", [level, totallevels]), {
				fontSize:34,
				color:0xf6f28d,
				borderColor:0x713f15,
				textAlign:"center"
			});
			needTxt.width = needTxt.textWidth + 10;
			
			needTxt.x = (settings.width - needTxt.width) / 2;
			needTxt.y = 22; // 55 // 15
			
			/*if (mode == ALL_IN_LINE){
				needTxt.y = 15;
			}*/
			
			drawBackgrounds()
			drawReward();
			
			/*if (mode == ALL_IN_LINE) { 
				
			} else {
				Load.loading(Config.getIcon(App.data.storage[Stock.COINS].type, App.data.storage[Stock.COINS].preview), onIconComplete); 
			}*/
			
			bodyContainer.addChild(needTxt);	
			drawBttn();
			
			
			
			/*if (!smallWindow) {
				backField = Window.backing(settings.width - 80, 320, 40, "buildingDarkBacking");  // бэкграунд с ингредиентами для улучшения */
				/*if(mode == ALL_IN_LINE){
					backField = Window.backing(settings.width - 80, 280, 40, "buildingDarkBacking");
				}*/
				//bodyContainer.addChildAt(backField, 0);
				/*backField.x = (settings.width - backField.width) / 2;
				
				if (prices.length > 0) {
					backField.y = backLine.y + backLine.height + 10;
					bttnContainer.y = background.height - 75;
					
				} else {
					//background.height = 400;
					backField.y = 80;
					bttnContainer.y = background.height - 75; 
					
					if (settings.hasState)
						backField.y += 40;
				}
				
				if(mode == ALL_IN_LINE){
					backField.y = 30;
				}
				
				
			}	*/	
			if (!smallWindow) {
				//drawBttn();
				
			}
			createResources();
			recNeedTxt();
			
			if (prices.length > 0)
				drawDescription();
				
			bodyContainer.addChildAt(container,numChildren - 1);
			
			bttnContainer.y = background.height - 75; 
			
			//this.y -= 45;
			//fader.y += 45;
			var plankBmap:Bitmap = backingShort(settings.width - 90, 'shopPlank');
			plankBmap.x = 45;
			plankBmap.y = settings.height - plankBmap.height - 90;
			layer.addChild(plankBmap);
			
			windowUpdate();
			
			if (settings.target.info.type == 'University')
				drawUpgradeButton();
		}
		
		protected var rewardCont:LayerX;
		protected function get reward():Object {
			return settings.reward;
		}
		protected function drawReward():void {
			if (!reward) return;
			
			if (bonusList)
				bonusList.removeChildren();
			
			//rewardCont = new LayerX();
			
			/*var subTitleOnRibbon:TextField = Window.drawText(Locale.__e("flash:1382952380000"),  {
				fontSize:32,
				color:0xfffddd,
				autoSize:"left",
				borderColor:0x5d3a03
			});
			subTitleOnRibbon.x = 15;
			subTitleOnRibbon.y = subTitleOnRibbon.height/3;
			rewardCont.addChild(subTitleOnRibbon);*/
			
			/*var rewardList:RewardListB = new RewardListB(reward, false, 0, {
				itemWidth:		40,
				itemHeight:		40,
				itemToItemWidth:40
			}, '');
			rewardList.x = subTitleOnRibbon.x + subTitleOnRibbon.width + 15;
			rewardList.y = subTitleOnRibbon.y;*/
			//rewardCont.addChild(rewardList);
			
			var bonusList:CollectionBonusList = new CollectionBonusList(reward,true,{backDafault:false,bgY:10});
			bonusList.x = (settings.width - bonusList.width)/2 - 15;
			bonusList.y = settings.height - bonusList.height - 125;
			bodyContainer.addChild(bonusList);
			
			/*var stripe:Bitmap = Window.backingShort(rewardCont.width + 90, "rewardStripe");
			stripe.x = - 25;
			rewardCont.addChildAt(stripe, 0);*/
			
			/*rewardCont.x = (settings.width - rewardCont.width)/2 + 100;
			rewardCont.y = settings.height - 180;
			bodyContainer.addChild(rewardCont);*/
		}
		
		protected function onIconComplete(data:*):void 
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
		
		/*private function darwDecor():void {
			drawMirrowObjs('storageWoodenDec', -6, settings.width +6, settings.height - 110);
			drawMirrowObjs('storageWoodenDec', -6, settings.width +6, 34, false, false, false, 1, -1 );
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -45, true, true);
		}*/
		
		protected function drawBackImage():void {
			//
		}
		
		protected function windowUpdate():void {
			if (upgBttn.mode == DISABLED){
				//background.height = bgHeight;
				//backField.height -= 15;
				//bttnContainer.y = bgHeight - 80;
				//storageWoodenDec1.y = storageWoodenDec2.y = bgHeight - 120;
			}else if (backLine != null /*&& backField*/)	{
				/*var hgNew:int = bgHeight - 26;
				background.height = hgNew;
				backField.height = 206;
				bttnContainer.y = hgNew - 80;*/
				//storageWoodenDec1.y = storageWoodenDec2.y = hgNew - 120;
			} 
		}
		
		protected function resizeBack():void {
			/*if (resources.length == 6) 
			{
				settings.width = 940;
				exit.x = -exit.width + settings.width;
			}
			if (resources.length == 5) 
			{
				settings.width = 870;
				exit.x = -exit.width + settings.width;
			}
			if (resources.length == 4) 
			{
				settings.width = 760;
				exit.x = -exit.width + settings.width;
			}*/
			if (resources.length == 3 && buildingBackImage) 
			{
				buildingBackImage.x = settings.width/2 - buildingBackImage.width/2;
			}
		}
		
		protected var lvlSmaller:Boolean = false;
		protected function drawBttn():void {
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
			
			//upgBttn = new UpgradeButton(UpgradeButton.TYPE_ON, bttnUpgSettings);
			upgBttn = new Button({
				caption		:settings['bttnTxt'],//Locale.__e("flash:1382952379806"),
				width		:190,
				height		:55,	
				fontSize	:30,
				radius		:26,
				eventPostManager:true
			});
			upgBttn.textLabel.height = 52;
			upgBttn.name = 'construct_bttn';
			//upgBttn.coinsIcon.x = upgBttn.textLabel.x + upgBttn.textLabel.textWidth + 14;
			//upgBttn.coinsIcon.y -= 2;
			//upgBttn.countLabel.x = upgBttn.coinsIcon.x + upgBttn.coinsIcon.width + 5;
			//upgBttn.countLabel.y += 9;
			//upgBttn.topLayer.x = (upgBttn.settings.width - upgBttn.topLayer.width) / 2 - 10;
			//upgBttn.textLabel.x += 30;
			
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
			
			/*if (skipBttn.visible) 
			{
				//skipBackground.visible = true;
			}else {
				//skipBackground.visible = false;
			}*/
		}
		
		protected function drawSkpBttn():void 
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
			upgBttn.x = (bttnContainer.width - upgBttn.width)/2 + 7;
			upgBttn.y -= 28;
			skipBttn.addEventListener(MouseEvent.CLICK, onSkip);
			
			//skipBackground = Window.backingShort(skipBttn.width + 85, 'donatBttnBacking');			
			//skipBackground.x = 2;
			//skipBackground.y = -29;			
			
			//bttnContainer.addChild(skipBackground);
			bttnContainer.addChild(skipBttn);			
		}
		
		protected function onSkip(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			close();
			
			settings.onUpgrade(settings.request, skipPrice);
			
			//var dataPrices:Object = target.devel.obj[settings.target.level + 1]; 
			var dataPrice:int = App.data.storage[target.sid].instance.devel[maxInstance()].req[settings.target.level + 1].f;
			//for (var price:* in dataPrices) {
				App.user.stock.take(3, dataPrice)
				
			/*var dataPrices:Object = target.devel.obj[settings.target.level + 1]; было
			for (var price:* in dataPrices) {
				App.user.stock.take(price, dataPrices[price])
			}*/
			
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
		{
			
		}
		
		protected var iconTarget:Bitmap = new Bitmap();
		protected function drawBackgrounds():void 
		{
			if (bgHeight < 260)
				bgHeight = 260;
			//background = backing(settings.width, bgHeight, 45, "shopBackingNew"); // основной бэкграунд  
			background = backing2(settings.width, settings.height, 50, 'constructBackingUp', 'constructBackingBot');
			layer.addChild(background);
			
			drawMirrowObjs('decSeaweed', settings.width + 39, - 39, bgHeight - 180, true, true, false, 1, 1);
			
			var star1:Bitmap = new Bitmap(Window.textures.decConstructStar1);
			star1.x = 10;
			star1.y = 14;
			star1.filters = [new DropShadowFilter(2.0, 90, 0, 0.8, 4.0, 4.0, 1.0, 3, false, false, false)];

			layer.addChild(star1);
			
			var star2:Bitmap = new Bitmap(Window.textures.decConstructStar2);
			star2.x = 58;
			star2.y = bgHeight - star2.height - 30;
			star2.filters = [new DropShadowFilter(2.0, 45, 0, 0.8, 4.0, 4.0, 1.0, 3, false, false, false)];

			layer.addChild(star2);
			
			itm = App.data.storage[settings.target.sid];
			
			/*if (prices.length > 0){
				backLine = new Bitmap(Window.textures.plate);
				//bodyContainer.addChild(backLine);
				backLine.x = (settings.width - backLine.width) / 2;
				backLine.y = 20;
			}
			
			if (settings.hasState)
				backLine.y += 30;*/
		}
		
		protected function onPreviewComplete(data:*):void 
		{
			var animation:Bitmap = new Bitmap;
			var container:Sprite = new Sprite;
			addChild(container);
			
			var Offset:int = 100;
			var _level:uint = (data.sprites.length <= level)?level-1:level;
			iconTarget.bitmapData = data.sprites[_level].bmp;
			
			/*if (_level == totallevels && data.hasOwnProperty('animation') ) {
				if(itm.type != 'Port'){
					Load.loading(Config.getSwf(itm.type, itm.view), preview);
					animation = animationBitmap.bitmap;
					animation.smoothing = true;	
				} else {
					Load.loading(Config.getIcon(itm.type, itm.view), onIconComplete);
				}
			}*/
			
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
			
			if (container.width > 220 ) {
				container.width = 220;
				container.scaleY = container.scaleX;
			}
			
		}
		
		protected var descCont:Sprite = new Sprite();
		protected var arrBttns:Array = [];
		protected var numResourses:int;
		protected var storageWoodenDec1:Bitmap;
		protected var storageWoodenDec2:Bitmap;
		protected var skipPrice:int;
		protected var bttnContainer:Sprite;
		
		//private var background:Bitmap;
		
		protected function drawDescription():void 
		{
			var posX:int = 0;
			
			bodyContainer.addChild(descCont);
			
			/*needTxt = drawText(Locale.__e("flash:1383042563368"), {
				fontSize:28,
				color:0xffffff,
				borderColor:0x5b4814
			});
			bodyContainer.addChild(needTxt);
			needTxt.width = needTxt.textWidth + 5;
			needTxt.height = needTxt.textHeight;
			needTxt.y = needTxt.height + 18;
			needTxt.x =  (settings.width - needTxt.width) / 2;*/
			
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
						break;/*
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
						break;*/
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
				
				if (bttn) {
					bttn.x = icon.x + (icon.width + counTxt.textWidth + 5 - bttn.width) / 2;
					bttn.y = 52;
					descCont.addChild(bttn);
					arrBttns.push(bttn);
					bttn = null;
				}
				
				posX = counTxt.x + counTxt.width + 30;
			}
			bodyContainer.addChild(descCont);
			
			//sprite.x = backLine.x + (backLine.width- sprite.width)/2;
			//sprite.y = backLine.y + 10;
			
			descCont.x = /*backLine.x +*/ needTxt.x + needTxt.width + 2;
			descCont.y = /*backLine.y +*/ needTxt.y - 7;
			
		}
		
		protected function showTechno(e:MouseEvent):void
		{
			App.ui.upPanel.onRobotEvent();
		}
		
		protected function showBankReals(e:MouseEvent):void 
		{
			BankMenu._currBtn = BankMenu.REALS;
			BanksWindow.history = {section:'Reals',page:0};
			new BanksWindow( { popup:true } ).show();

		}
		
		protected function showBankCoins(e:MouseEvent):void 
		{
			BankMenu._currBtn = BankMenu.COINS;
			BanksWindow.history = {section:'Coins',page:0};
			new BanksWindow( { popup:true } ).show();
		}
		
		protected function showFantasy(e:MouseEvent):void 
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
		
		protected var needTxt:TextField;
		protected function recNeedTxt():void
		{
			//var txt:String;
			/*if (mode != ALL_IN_LINE){
				if (prices.length > 0) 
					txt = Locale.__e("flash:1393580288027") + ":";
				else */
					//txt = Locale.__e("flash:1382952380003");// + ":";
			/*} else {
				txt = Locale.__e("flash:1433345292234");
			}*/
			var reqText:String;
			
			reqText = Locale.__e("flash:1382952380003");
			if (target is Bridge)
			{
				if (App.data.storage[target.sid].hasOwnProperty('delete') && App.data.storage[target.sid]['delete'] == 0)
				{
					reqText = Locale.__e("flash:1479733680929");
				}
			}
			
			needTxt = drawText(reqText, {
				fontSize:32,
				color:0xffffff,
				borderColor:0x713f15
			});
			bodyContainer.addChild(needTxt);
			needTxt.width = needTxt.textWidth + 5;
			needTxt.height = needTxt.textHeight;
			needTxt.y = needTxt.height + 28;
			needTxt.x = (settings.width - needTxt.width) / 2;
			
			var backgroundneedTxt:Bitmap = Window.backingShort(settings.width - 140, 'questTaskBackingNew', true);
			backgroundneedTxt.x = needTxt.x + (needTxt.width -  backgroundneedTxt.width)/ 2 ;
			backgroundneedTxt.y = needTxt.y /*+ needTxt.height*/ - 3;
			backgroundneedTxt.scaleY = .5;
			backgroundneedTxt.alpha = 1;
			bodyContainer.addChild(backgroundneedTxt);
			bodyContainer.swapChildren(backgroundneedTxt, needTxt);
			
		}
		
		public function createResources():void
		{
			var offsetX:int = 0;
			var offsetY:int = 0;
			var dX:int = 0;
			//partList = [];
			var count:int = 0;
			var bias:int = 0;
			if (!App.user.quests.tutorial) 
				bias = 23;
			
			/*for (var itm:* in partBcList) {
				if(contains(partBcList[itm]))
				container.removeChild(partBcList[itm]);
			}*/
			
			for each(var sID:* in resources) {
				//var background:Bitmap = Window.backing(160, 230, 10, "banksBackingItem");
				//var background:Bitmap = Window.backing(160, 230, 10, "itemBacking");
				//partBcList.push(background);
				//container.addChild(background);
		
				var inItem:MaterialItem = new MaterialItem({
					sID					:sID,
					need				:settings.request[sID],
					window				:this, 
					type				:MaterialItem.IN,
					mode				:MaterialItem.CONSTRUCT,
					background			:'banksBackingItem',
					color				:0x5a291c,
					borderColor			:0xfaf9ec,
					bitmapDY			:0,
					bitmapSize			:90
				});
				
				//if(inItem)
				inItem.title.multiline = true;
				//inItem.title.y -= 30;
				//inItem.title.width += 15;
				inItem.checkStatus();
				//inItem.buyBttn.y += 25;
				//inItem.askBttn.y += 20;
				//inItem.bitmap.y = 5;
				//inItem.bitmap.x = 10;
				//inItem.vs_txt.y += 20;
				//inItem.count_txt.y += 20;
				//inItem.need_txt.y += 20;
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(inItem);
				//background.y = 2;
				//inItem.y = 40;
				
				container.addChild(inItem);
				//background.x = offsetX;
				//inItem.x = 30 + offsetX;
				
				count++;
				
				
				//inItem.background.visible = false;
				inItem.x = offsetX;//background.x + (background.width - inItem.width) / 2 + bias;
				inItem.y = offsetY;//background.y + 45;
				
				offsetX += inItem.background.width - inItem.background.x + 13;// background.width  + 20/* + dX*/;
				/*if (App.data.storage[sID].mtype == 6){
					inItem.x -= 19;
				}*/
				//background.x = inItem.x - (background.width - inItem.width)/2 - 20 ;
				//background.y = inItem.y - 40;
				/*if (App.user.quests.tutorial) 
				{
					background.x += 20;
				}*/
				
				/*if (App.data.storage[sID].mtype == 6){
					background.x += 18;
				}*/
				//inItem.x -= 5;
			}
			container.x = (settings.width - container.width)/2;
			container.y = 120;
			findHelp();
			inItem.dispatchEvent(new WindowEvent(WindowEvent.ON_CONTENT_UPDATE));
		}
		
		public function onUpdateOutMaterial(e:WindowEvent = null):void 
		{
			
			if (PostManager.instance.isActive && PostManager.instance.isProgress){
				PostManager.instance.waitPostComplete(onUpdateOutMaterial);
				return;
			}
			
			var outState:int = MaterialItem.READY;
			for each(var item:* in partList) {
				if(item.status != MaterialItem.READY){
					outState = item.status;
				}
			}
			
			if (outState == MaterialItem.UNREADY) {
				
				upgBttn.state = Button.DISABLED;
			}
			else if (isEnoughMoney && !lvlSmaller) {
				
				upgBttn.state = Button.NORMAL; 
				windowUpdate();
			}
		}
		
		protected function onUpgrade(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			//if(settings.hasState) {
				settings.onUpgrade(settings.request);
			//} else {
				//settings.onUpgrade(target.devel.obj[settings.target.level + 1]);
			//}
			
			close();
		}
		
		private function drawUpgradeButton():void 
		{
			var upgBttn:ImageButton = new ImageButton(Window.textures.upgBttn)
			upgBttn.x = exit.x + (exit.width - upgBttn.width) / 2;
			upgBttn.y = exit.y + exit.height - 20;
			bodyContainer.addChild(upgBttn);
			upgBttn.addEventListener(MouseEvent.CLICK, onUpgBttn)
		}
		
		private function onUpgBttn(e:MouseEvent):void 
		{
			new CraftListWindow({
				popup:		true,
				target:		settings.target,
				content:	Numbers.objectToArray(settings.target.info.instance.devel[1].req[settings.target.level + 1].craft)
			}).show();
		}
		
		override public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);
			
			if (App.user.quests.tutorial)
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
			}
			
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
			
			/*if (needTxt && bodyContainer.contains(needTxt) ) {
				bodyContainer.removeChild(needTxt);
			}*/
			
			for (i = 0; i < partList.length; i++ ) 
			{
				var itm:MaterialItem = partList[i];
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
