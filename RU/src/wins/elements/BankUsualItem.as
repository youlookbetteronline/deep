package wins.elements 
{
	import api.ExternalApi;
	import buttons.Button;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Field;
	import units.Techno;
	import utils.ActionsHelper;
	import wins.BanksWindow;
	import wins.HeroWindow;
	import wins.SimpleWindow;
	import wins.Window;

	public class BankUsualItem extends LayerX {
		
		public var item:*;
		public var background:Bitmap;
		public var bgMask:Shape = new Shape();
		public var bitmap:Bitmap;
		public var title:TextField;
		public var bgImage:String;
		public var bestChoice:Bitmap;
		public var bestPrice:Bitmap;
		public var rewBtm:Bitmap = new Bitmap();
		public var buyBttn:Button;
		
		public var window:*;
		
		public var moneyType:String = "coins";
		public var previewScale:Number = 1;
		private var rew:Bitmap;
		private var rewardContainer:LayerX = new LayerX();
		
		private var needTechno:int = 0;
		
		public var isLabel1:Boolean = false;  // just for test
		public var isLabel2:Boolean = false;   // just for test
		
		private var preloader:Preloader = new Preloader();
		
		
		public var buyObject:Object;
		
		public var settings:Object = {
			height:73,
			width:566,
			icons:false,
			sale:false,
			profit:0,
			isBestsell:false,
			isActionGained:false
		}
		
		public var reward:Array;
		
		
		
		public function BankUsualItem(item:*, window:*, _settings:Object = null) {
			
			this.item = item;
			this.window = window;
			if (item.hasOwnProperty('reward') && item.reward!={}) {
				reward = [];
				//var itnm:uint
				for (var it:String in item.reward){
					reward[0] = it;
					break;
				}
			}
			settings.profit = _settings.profitValue | 0;
			bgImage = _settings['backImage'];
			settings.isBestsell = true/*(_settings.isBestsell)?true:false*/;
			settings.isActionGained = (_settings.isActionGained)?true:false;
			var ind:int  = 0;
			switch(item.type) {
				case 'Reals':
					ind = Stock.FANT;
				break;
				case 'Coins':
					ind = Stock.COINS;
				break;
			}
			var _votes:int = item.socialprice[App.social];
			if (item.dmaterials)
			{
				if (App.user.stock.count(Numbers.firstProp(item.dmaterials).key) > 0)
				{
					if (!(item.extra && item.extra > 0 && App.data.money && (App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1) || App.user.money > App.time)) 
						_votes = item.socialprice[App.social] * (100 - Numbers.firstProp(item.dmaterials).val) * .01;
				}
			}
			buyObject = {
				type: item.type,
				count:	item.price[ind] || 0, 
				votes:	/*item.socialprice[App.social]*/ _votes || 0, 
				extra:  item.extra,
				id:		item.sid,
				title: Locale.__e(item.title),
				description: Locale.__e(item.description),
				icon: Config.getIcon(item.type, item.preview)
			};
			
			if (_settings) {
				for (var s:String in _settings) {
					this.settings[s] = _settings[s];
				}
			}
			
			if (this.settings['glow']) {
				if (item.hasOwnProperty('socialprice') && item.socialprice.hasOwnProperty(App.social) && int(item.socialprice[App.social]) >= 50) {
					startGlowing();
				}
			}
			
			/*if (_settings == null) {
				this.settings = new Object();
				
				this.settings = {
					height:216,
					width:186,
					icons:true,
					sale:false
				}
			}else {
				this.settings = _settings;
			}*/
			bgImage = 'banksBackingItem';
			background = Window.backing(settings.width, settings.height, 30, bgImage);
			addChildAt(background, 0);
			
			var clt:ColorTransform = new ColorTransform(1.0, 1.0, 0.7);
			//background.transform.colorTransform = clt;
			addChildAt(background, 0);
			if (reward)
			{
				drawTopReward();
				
				bgMask.graphics.beginFill(0xFFFFFF, 1);
				bgMask.graphics.drawRect(0, 0, background.width + 10, background.height);
				bgMask.graphics.endFill();
				bgMask.x = background.x + 10;
				bgMask.y = background.y;
				background.cacheAsBitmap = true;
				bgMask.cacheAsBitmap = true;
				background.mask = bgMask;
				addChildAt(bgMask, 1);	
				
			}
			//drawFlag();
				
			if (item['new'] == 1) {
				var newStripe:Bitmap = new Bitmap(Window.textures.bankBonusRibbonBacking);
				newStripe.x = 2;
				newStripe.y = 3;
				addChild(newStripe);
			}
			
			var sprite:LayerX = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			sprite.tip = function():Object { 
				
				if (item.type == "Plant")
				{
					return {
						title:item.title,
						text:Locale.__e("flash:1382952380075", [TimeConverter.timeToCuts(item.levelTime * item.levels), item.experience, App.data.storage[item.out].cost])
					};
				}
				else if (item.type == "Decor")
				{
					return {
						title:item.title,
						text:Locale.__e("flash:1382952380076", item.experience)
					};
				}
				else
				{
					return {
						title:item.title,
						text:item.description
					};
				}
			};
			
			//drawTitle();
			
			//addChild(preloader);
			//preloader.x = (background.width)/ 2;
			//preloader.y = (background.height)/ 2 - 15;
			
			var short:Boolean = false;
			
			//Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
			
			drawBttn();
			
			drawCount();
			
			checkLabels();
			
			
			bestChoice = new Bitmap(Window.textures[(App.lang != 'ru')?'bestChoiceEN' :'bestChoice']);
			bestChoice.x = background.x + background.width - bestChoice.width + 80;
			bestChoice.y = buyBttn.y - bestChoice.height/2 + 13;
			addChild(bestChoice);
			bestChoice.visible = false;
			
			bestPrice = new Bitmap(Window.textures[(App.lang != 'ru')?'bestPriceEN' :'bestPrice']);
			bestPrice.x = background.x + background.width - bestPrice.width + 90;
			bestPrice.y = buyBttn.y - bestPrice.height/2 + 17;
			addChild(bestPrice);
			bestPrice.visible = false;
		}
		
		private function drawTopReward():void{
			
			rew = new Bitmap(Window.textures.bankRibbon);
			rewardContainer.addChild(rew);
			rew.smoothing = true;
			//Size.size(rew, 148, 104);
			var glow:Bitmap = new Bitmap(Window.textures.glowingBackingNew);
			glow.y = rew.y + (rew.height - glow.height) / 2;
			glow.x = 22;
			//glow.filters = [new BlurFilter(10, 10, 1)];
			rewardContainer.addChild(glow);
			var rID:int = Numbers.firstProp(item.reward).key;
			Load.loading(Config.getIcon(App.data.storage[rID].type, App.data.storage[rID].preview), function(data:*):void{
				rewBtm.bitmapData = data.bitmapData;
				Size.size(rewBtm, 70, 70);
				rewBtm.smoothing = true;
				rewBtm.x = glow.x + (glow.width - rewBtm.width) / 2;
				rewBtm.y = glow.y + (glow.height - rewBtm.height) / 2;
			});
			
			
			var rewText:TextField = Window.drawText(Locale.__e('flash:1493383312549'),{
					fontSize:24,
					textAlign:"center",
					color:0xff0000,
					borderColor:0xffffff,
					textLeading: 8,
					multiline:true,
					width:90
			});
			rewText.x = glow.x + (glow.width - rewText.width) / 2;
			rewText.y = glow.y + glow.height - 30;
			rewardContainer.addChild(rewBtm);
			rewardContainer.addChild(rewText);
			addChild(rewardContainer);
			rewardContainer.x = -125;
			rewardContainer.y = -31;
			//item.reward
			
			rewardContainer.tip = function():Object 
				{ 
					return {
						title:App.data.storage[rID].title,
						text:App.data.storage[rID].description
					};
				};
		}
		
		public var flagCont:LayerX = new LayerX();
		public static var currView:String = 'unicorn';
		public static var presIco:Object = new Object();
		public function drawFlag():void {
			if (settings.isBestsell) {
				
				var flagLabel:Bitmap = new Bitmap(Window.textures.bankBonusRibbonBacking);
				flagCont.addChild(flagLabel);
				addChild(flagCont);
				var presentIco:Bitmap = new Bitmap();
				presentIco.x = flagLabel.x - flagLabel.width + 80;
				var prcSetts:Object = {
						fontSize: 20,
						border:true,
						color:0xfffeff,
						borderColor:0x8c1639,
						textAlign:'center'
					};
				var prsntLabel:TextField = Window.drawText(Locale.__e('flash:1419330538250'), prcSetts);
				//prsntLabel.border = true;
				
				var object:Object = App.data.storage[reward[0]];
				if (!object) return;
				
				var preCurrView:String = object.view;
				if(!presIco.hasOwnProperty(preCurrView)) {
					Load.loading(Config.getImage('interface', preCurrView),
						function(data:Bitmap):void {
							presentIco.bitmapData = data.bitmapData;
							presIco[preCurrView] = new Bitmap();
							presIco[preCurrView].bitmapData = data.bitmapData;
							flagCont.addChild(presentIco);
							flagCont.addChild(prsntLabel);
								if (preCurrView == 'undina') 
							{
								presentIco.scaleX = presentIco.scaleY = .8;
							}
							prsntLabel.y = flagLabel.y + flagLabel.height - prsntLabel.height ;
							prsntLabel.x = presentIco.x - (prsntLabel.width - presentIco.width) / 2 -5;
							presentIco.y = flagLabel.y + (flagLabel.height - presentIco.height) -15;
							
							App.ui.flashGlowing(flagCont);
						});
				}else {
					presentIco.bitmapData = presIco[preCurrView].bitmapData;
					flagCont.addChild(presentIco);
					flagCont.addChild(prsntLabel);
					prsntLabel.x = presentIco.x - (prsntLabel.width - presentIco.width) / 2;
					prsntLabel.y = flagLabel.y + flagLabel.height - prsntLabel.height ;
					presentIco.y = flagLabel.y - (presentIco.height - flagLabel.height ) -15;
					//prsntLabel.y = flagLabel.y + flagLabel.height - prsntLabel.height - 10;
				}
				
				prsntLabel.y = flagLabel.y + flagLabel.height - prsntLabel.height ;
				prsntLabel.x = presentIco.x - (prsntLabel.width - presentIco.width) / 2 -5;
				presentIco.y = flagLabel.y + (flagLabel.height - presentIco.height) -15;
				
				prsntLabel.x -= 15;
				presentIco.x -= 15;
				currView = preCurrView;
				var item:Object = App.data.storage[reward[0]];
				flagCont.tip = function():Object {
					return{
					title:item.title,
					text:item.description
					}
				}
				flagLabel.x = background.x - flagLabel.width * 0.9;
				//swapChildren(flagCont, background);
			}	
		}
		
		public var premiumCont:Sprite = new Sprite();
		private function drawPremium():void {

			if (settings.isActionGained) {

				counterLabel.x = icon.x + icon.width + 5;
				counterLabel.y = (background.height - counterLabel.height) / 2 -4;
				
				priceLabel.x = 300 - 12 * int(App.isSocial('MX', 'YB'));
				
				buyBttn.x = background.x + background.width - buyBttn.width - 15;
				var bcount:uint = bonusVal;
				var redLine:Bitmap = new Bitmap(Window.textures.redLines);
				redLine.scaleX = redLine.scaleY = 2;
				Size.size(redLine, counterLabel.textWidth + 15, counterLabel.height + 20);
				redLine.smoothing = true;
				redLine.x = counterLabel.x;
				redLine.y = counterLabel.y + counterLabel.textHeight - redLine.height - 4;
				addChild(redLine);
				
				var prmsCountLbl:Object = {
					color:(item.type!='Reals')?0xf9c83b:0x9dfcff,  
					borderColor:(item.type!='Reals')?0x7b4004:0x335c7b,
					width:120,
					border:true,
					multilnine:true,
					wrap:true,
					textAlign:"left",
					autoSize:"center",
					fontSize:40
				}
				var bonusValue:TextField = Window.drawText(String(bcount + Numbers.firstProp(item.price).val), prmsCountLbl);
				bonusValue.x = counterLabel.x + counterLabel.textWidth + 15;
				bonusValue.y = background.y + 3 +(background.height - bonusValue.textHeight) / 2;
				
				premiumCont.addChild(bonusValue);
				addChild(premiumCont);
				
			}
		}
		
		public function get bonusVal():uint {
			return item.extra;
		}
		
		public var profitLabel:TextField = new TextField();
		
		private function checkLabels():void
		{
			if (settings.profit && settings.profit!= 0) {
				var prfVal:uint = settings.profit;
				var prms:Object = {
					color:0xd62d4e,
					border:false,
					textAlign:"center",
					autoSize:"center",
					fontSize:24
				}
				
				profitLabel = Window.drawText( Locale.__e('flash:1419254677876') + " " + prfVal + "%", prms );
				if(App.social == 'FB'){
					profitLabel = Window.drawText( prfVal + "% " + Locale.__e('flash:1419254677876'), prms );
				}else {
					profitLabel = Window.drawText( Locale.__e('flash:1419254677876') + " " + prfVal + "%", prms );
				}
				profitLabel.x = background.x + 180;
				profitLabel.y = background.y + (background.height - profitLabel.height) / 2 + 4;
				addChild(profitLabel);
			}
			
			var type:String;
			var price:Number = item.socialprice[App.social];
			
			if(settings.isActionGained)
				profitLabel.visible = false;
			if (item.type == "Reals")
				type = 'reals';
			else if (item.type == "Coins")
				type = 'coins';
				
			if (item.offertype) {
				if (item.offertype == 1) {
					isLabel1 = true;
				}else if (item.offertype == 2) {
					isLabel2 = true;
				}
			}
		}
		private var priceLabel:TextField
		public function drawBttn():void
		{
			var text:String;
			var price:Number = item.socialprice[App.social];
			var priceLable:Object = ActionsHelper.priceLable(price)
			var priceVal:String = Locale.__e(priceLable.text, [priceLable.price]);
			var bttnSettings:Object = {
				caption:Locale.__e('flash:1382952379751'),
				fontSize:24,
				width:100,
				height:40,
				hasDotes:false
			};
			
			switch(item.type) {
				case BanksWindow.COINS:
					bttnSettings["bgColor"] = [0xc8e414, 0x80b631];
					bttnSettings["borderColor"] = [0xeafed1, 0x577c2d];	
					bttnSettings["bevelColor"] = [0xdef58a, 0xa17759];
					bttnSettings["fontColor"] = 0xffffff;			
					bttnSettings["fontBorderColor"] = 0x34560d;
				break;
				case BanksWindow.REALS:
					bttnSettings["bgColor"] = [0x97c8ff, 0x5d8ef4];
					bttnSettings["borderColor"] = [0xffffff, 0xffffff];	
					bttnSettings["bevelColor"] = [0xb6dcff, 0x376ce0];
					bttnSettings["fontColor"] = 0xffffff;			
					bttnSettings["fontBorderColor"] = 0x3259b4;
					bttnSettings["greenDotes"] = false;					
				break;
				case BanksWindow.SETS:
					
				break;
			}
			
			var pvalPars:Object = {
					color:0x793900,
					border:false,
					textAlign:"left",
					autoSize:"center",
					fontSize:28
				};
			
			priceLabel = Window.drawText(priceVal, pvalPars)
			
			addChild(priceLabel);
		//	priceLabel.x = 305;
			priceLabel.x = 300 - 12 * int(App.isSocial('MX', 'YB'));
			priceLabel.y = background.y + (background.height - priceLabel.height) / 2 + 3;
			
			if (App.isSocial('MX')) {
				var mxLogo:Bitmap =  new Bitmap(Window.textures.mixieLogo);
				addChild(mxLogo);
				mxLogo.y = priceLabel.y - (mxLogo.height - priceLabel.height)/2;
				mxLogo.x = priceLabel.x;
				priceLabel.x = mxLogo.x + mxLogo.width + 5;
			}
			
			buyBttn = new Button(bttnSettings);
			addChild(buyBttn);
			buyBttn.x = background.x + background.width - buyBttn.width - 15;
			buyBttn.y = (background.height - buyBttn.height)/2;
			
			buyBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		}
		
		private var dY:int = -22;
		public function onPreviewComplete(data:Bitmap):void
		{
			if(preloader && preloader.parent){
				removeChild(preloader);
			}
			var centerY:int = 90;
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.scaleX = bitmap.scaleY = previewScale;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width) / 2;
			if (item.type == 'Resource') centerY = 110;
			bitmap.y = centerY - bitmap.height / 2 + 6;
			
			//bitmap.filters = [new GlowFilter(0x93b0e0, 1, 40, 40)]
		}
		
		public function dispose():void {
			if(buyBttn != null){
				buyBttn.removeEventListener(MouseEvent.CLICK, buyEvent);
			}
			
			if (Quests.targetSettings != null) {
				Quests.targetSettings = null;
				if (App.user.quests.currentTarget == null) {
					QuestsRules.getQuestRule(App.user.quests.currentQID, App.user.quests.currentMID);
				}
			}
		}
		
		public function drawTitle():void {
			title = Window.drawText(String(item.title), {
				color:(item.type!='Reals')?0xffffff:0xcde8ff,  
				borderColor:(item.type!='Reals')?0x7b4004:0x242578,
				textAlign:"center",
				autoSize:"center",
				fontSize:24,
				textLeading:-6,
				multiline:true,
				wrap:true,
				width:background.width - 40
			});
			title.y = 5;
			title.x = (background.width - title.width)/2;
			addChild(title)
		}
		
		//var isExtra:Boolean = true;
		private var counterLabel:TextField;
		private var icon:Bitmap;
		private function drawCount():void
		{	
			var ind:int;
			
			var sighnTxt:String = "x ";
			switch(item.type) {
				case 'Reals':
					ind = Stock.FANT;
					icon = new Bitmap(UserInterface.textures.blueCristal);
				break;
				case 'Coins':
					ind = Stock.COINS;
					icon = new Bitmap(UserInterface.textures.goldenPearl);
				break;
			}
			
			//if (!settings.icons) {
				//sighnTxt = "x";
				//icon = null;
			//}
			
			var isExtra:Boolean = false;
			if (buyObject.extra && buyObject.extra > 0 &&App.data.money&& (App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1) || App.user.money > App.time) {
				
				/*var contCount:Sprite = new Sprite();
				var extraTxt:TextField = Window.drawText("+" + String(buyObject.extra), {
					fontSize:34,
					color:0x6ce8de,
					borderColor:0x0e4067,
					autoSize:"left"
				});
				//contCount.addChild(counterLabel);
				counterLabel.x = 0;
				counterLabel.y = -counterLabel.textHeight / 2;
				extraTxt.x = counterLabel.textWidth + 5;
				extraTxt.y = counterLabel.y + counterLabel.textHeight/2;
				//contCount.addChild(extraTxt);
				//addChild(contCount);
				if (settings.sale) {
					contCount.x = (settings.width - contCount.width) / 2;
					contCount.y = 164;
				}else {
					contCount.x = (settings.width - contCount.width) / 2;//background.width - contCount.width - 26;
					contCount.y = 142;
				}*/
				
				isExtra = true;
				settings.isActionGained = true;
				
			}
			
			counterLabel = Window.drawText(sighnTxt + String(item.price[ind])/*(item.price[ind] + ((App.data.money[App.social].enabled && App.data.money[App.social].date_to > App.time)?buyObject.extra:0))*/, {
				fontSize:(settings.isActionGained == true)?30:36,
				color:(item.type == 'Reals')?0x9dfcff:0xffdf34,
				borderColor:(item.type != 'Reals')?0x7b4004:0x335c7b,
				autoSize:"left"
			});
			counterLabel.x = background.x + 75;
			counterLabel.y = (background.height - counterLabel.height) / 2 + 4;
			
			//if (settings.sale) {
				//counterLabel.y = 164;
			//}
		
			addChild(counterLabel);
			
			
			icon.x = 10;
			icon.y = (settings.height - icon.height) / 2 - 3;
			icon.scaleX = icon.scaleY = 1.2;
			icon.smoothing = true;
			icon.filters = [new GlowFilter(0xffffff, 1, 6, 6, 6)]
			
			counterLabel.x = icon.x + icon.width + 5;
			counterLabel.y = (background.height - counterLabel.height) / 2 + 4;
			addChild(icon);
			
			/*if ((App.data.money.enabled && App.data.money.date_to > App.time)) {
				
			}*/
			//settings.isActionGained = true;
			if(settings.isActionGained)
				drawPremium();
			else if (checkDmaterials)
				drawDiscount();
		}
		
		private function get checkDmaterials():Boolean 
		{
			if (item.dmaterials)
				return true;
			else
				return false;
		}
		
		private function drawDiscount():void 
		{
			var dID:int = Numbers.firstProp(item.dmaterials).key;
			var percent:int = Numbers.firstProp(item.dmaterials).val;
			var backDiscount:Bitmap = new Bitmap(Window.textures.starBacking);
			var iconDiscount:Bitmap;
			var discountContainer:LayerX = new LayerX();
			
			var price:Number = Math.round(item.socialprice[App.social] * (100 - percent) * .01);
			var priceLable:Object = ActionsHelper.priceLable(price)
			var priceVal:String = Locale.__e(priceLable.text, [priceLable.price]);
			
			Size.size(backDiscount, 60, 60);
			backDiscount.smoothing = true;
			backDiscount.filters = [new GlowFilter(0xffffff, 1, 4, 4, 10, 1)];
			
			background.width += 65;
			
			discountContainer.addChild(backDiscount);
			
			Load.loading(Config.getIcon(App.data.storage[dID].type, App.data.storage[dID].preview), function(data:Bitmap):void{
				iconDiscount = new Bitmap(data.bitmapData);
				Size.size(iconDiscount, 35, 35);
				iconDiscount.smoothing = true;
				iconDiscount.filters = [new GlowFilter(0xffffff, 1, 3, 3, 10, 1)];
				
				iconDiscount.x = backDiscount.x + (backDiscount.width - iconDiscount.width) / 2;
				iconDiscount.y = backDiscount.y + (backDiscount.height - iconDiscount.height) / 2;
				discountContainer.addChild(iconDiscount);
			});
			
			discountContainer.x = background.x + background.width - discountContainer.width - 10;
			discountContainer.y = background.y + (background.height - discountContainer.height) / 2;
			addChild(discountContainer);
			
			discountContainer.tip = function():Object{
				return {
					title:	App.data.storage[dID].title,
					text:	App.data.storage[dID].description
				}
			}
			if (App.user.stock.count(dID) < 1)
				return;
				
			priceLabel.y -= 15;
			var redLine:Bitmap = new Bitmap(Window.textures.redLines);
			redLine.scaleX = redLine.scaleY = 2;
			Size.size(redLine, priceLabel.textWidth + 10, priceLabel.height + 15);
			redLine.smoothing = true;
			redLine.x = priceLabel.x;
			redLine.y = priceLabel.y + priceLabel.textHeight - redLine.height;
			addChild(redLine);
			
			var newPriceLabel:TextField = Window.drawText(priceVal, {
				color:0x793900,
				border:false,
				textAlign:"left",
				autoSize:"center",
				fontSize:28
			});
			
			newPriceLabel.x = priceLabel.x + (priceLabel.width - newPriceLabel.width) / 2;
			newPriceLabel.y = priceLabel.y + 30;
			addChild(newPriceLabel);
		}
		
		private function buyEvent(e:MouseEvent):void
		{
			if (App.social == 'AM') {
				var _itype:String = item.type;
				_itype = _itype.toLowerCase();
				Post.send({
					ctr		:'Orders',
					act		:'createOrder',
					uID		:App.user.id,
					type	:_itype, 
					pos		:item.sid
				}, function(error:*, data:*, params:*):void {
					navigateToURL(new URLRequest(data.transactionUrl),"_parent");
				});
				return;
			}
			var object:Object;
			if (App.social == 'FB') {
				object = {
					id:		 	buyObject.id,
					type:		buyObject.type,
					callback: function():void {
						bonusAnim();
					}
				};
				
			}else {
				//object = {
					//money: buyObject.type,
					//type:	'item',
					//item:	buyObject.type+"_"+buyObject.id,
					//votes:	buyObject.votes,
					//count: 	buyObject.count + ((App.data.money.enabled && App.data.money.date_to > App.time)?buyObject.extra:0),
					//title:	buyObject.title,
					//callback: function():void {
						//bonusAnim();
					//}
				//}
				
				object = {
					money: 		buyObject.type,
					type:		'item',
					item:		buyObject.type+"_"+buyObject.id,
					votes:		buyObject.votes,
					sid:		buyObject.id,
					count:		buyObject.count + ((App.data.money.enabled && App.data.money.date_to > App.time)?buyObject.extra:0),
					title:		buyObject.title,
					description:	buyObject.description,
					icon:		buyObject.icon,
					tnidx:		App.user.id + App.time + '-' + buyObject.type + "_" + buyObject.id,
					callback:	function():void {
						bonusAnim();
					}
				}
			}
			
			Log.alert(object);
			var that:BankUsualItem = this;
			var bonusAnim:Function = function():void {
				var idItem:int;
				if (buyObject.type == 'Coins')
					idItem = Stock.COINS;
				else
					idItem = Stock.FANT;
				
				var point:Point = Window.localToGlobal(buyBttn);
				if (settings.isBestsell) {
					point.x -= 121;
				}
				var item:BonusItem = new BonusItem(idItem, 1);
				item.cashMove(point, App.self.windowContainer);
				
				if (reward) {
					var _point:Point = new Point(flagCont.x, flagCont.y);
					var itm:BonusItem = new BonusItem(reward[0], 1);
					itm.cashMove(_point, App.self.windowContainer);
					App.user.stock.add(reward[0], 1);
				}
				
				if (that.item.dmaterials)
				{
					if (App.user.stock.count(Numbers.firstProp(that.item.dmaterials).key) > 0)
					{
						App.user.stock.take(Numbers.firstProp(that.item.dmaterials).key, 1);
						App.ui.upPanel.update(['discount']);
						window.close();
					}
				}
			}
			ExternalApi.apiBalanceEvent(object);
		}
		
	}
}	