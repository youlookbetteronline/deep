package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Techno;
	import units.Unit;
	import units.WorkerUnit;
	import 	flash.geom.ColorTransform;

	public class RoomSetWindow extends AddWindow
	{
		private var items:Array = new Array();
		//public var action:Object;
		private var container:Sprite;
		private var priceBttn:Button;
		private var timerText:TextField;
		private var itemDesc:TextField;
		private var rewardText1:TextField;
		private var rewardText2:TextField;
		private var descriptionLabel:TextField;
		private var background:Bitmap;
		private var fishDual:Bitmap;
		private var back1:Bitmap;
		private var backgroundDesc:Shape = new Shape();
		private var clockIcon:Bitmap;
		private var picture:Bitmap = new Bitmap();
		private var blueStripe:Bitmap;
		private var backTextUp:Shape = new Shape();
		private var backTextDown:Shape = new Shape();
		private var backPicture:Shape = new Shape();
		private var maska:Shape = new Shape();
		private var pID:uint;
		private var rewardCont:Sprite;
		protected var actions:Object;
		public var chairIcon:Bitmap;
		
		
		public function RoomSetWindow(settings:Object = null)
		{
			pID = settings.pID;
			actions = App.data.actions[pID];
			
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 650;
			settings['height'] = 560;
						
			settings['title'] = Locale.__e("flash:1382952379793");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] = 0x116011;
			settings['shadowBorderColor'] = 0x116011;
			settings['fontSize'] = 32;
			settings['hasExit'] = true;
			//settings['background'] = 'capsuleWindowBackin';
			
			super(settings);
			App.user.promos;
			
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: 42,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,
				borderSize 			: 3,
				shadowSize 			: 1,
				shadowColor			: settings.fontBorderColor,
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -20;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		private var textFilter:GlowFilter;
		private var shadowFilter:BlurFilter;
		
		
		override public function drawBackground():void {}
		
		public function changePromo(pID:String):void {
			
			App.self.setOffTimer(updateDuration);
			
			settings.content = initContent(action.items);
			settings.bonus = initContent(action.bonus);
			
			var numItems:int = settings.content.length + (settings.bonus.length - 1);
			
			var background:Bitmap = backing(settings.width, settings.height, 50, 'capsuleWindowBacking');
			layer.addChild(background);

/*			exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 50;
			exit.y -= 0;
			exit.x -= 0;
			*/
			this.y -= 30;
			fader.y += 30;
			
			/*var backing:Bitmap = Window.backing(settings.width - 50, 230, 43, 'buildingDarkBacking');
			bodyContainer.addChild(backing);
			backing.x = (settings.width - backing.width) / 2;
			backing.y = -12;*/
			//backing.alpha = 0.5;
			/*
			var image:Bitmap = new Bitmap(Window.textures.premiumDecor);
			image.y =  settings.height - image.height - 3 + 18 - 50;
			image.x -= -4;
			image.smoothing = true;
			image.scaleX = image.scaleY = 1;
			bodyContainer.addChild(image);
			var image2:Bitmap = new Bitmap(Window.textures.premiumDecor);
			image2.x = settings.width + 2 - 4;
			image2.y =  settings.height - image2.height / 2 + 2 + 18 - 104;
			image2.smoothing = true;
			image2.scaleX = -1;
			image2.scaleY = 1
			bodyContainer.addChild(image2);*/
			
			var text:String = Locale.__e("flash:1465388251257");
			_descriptionLabel = drawText(text, {
				fontSize:30,
				autoSize:"left",
				textAlign:"center",
				color:0xff002e,
				borderColor:0xffffff
			});
				
			var ribbon:Bitmap = backingShort(340, 'ribbonGrenn');
			ribbon.y = -65;
			ribbon.x = (settings.width - ribbon.width) / 2;
			bodyContainer.addChild(ribbon);
			
			
			/*var backgroundDesc:Bitmap = Window.backingShort(settings.width - 100, 'dailyBonusBackingDesc', true);
			backgroundDesc.x = (settings.width - backgroundDesc.width) / 2;
			backgroundDesc.y = 12;
			backgroundDesc.alpha = .6;
			bodyContainer.addChild(backgroundDesc);*/
			
			//_descriptionLabel.y = 3;
			
			
			//_descriptionLabel1.x = _descriptionLabel.x;
			//_descriptionLabel1.y = _descriptionLabel.y +2;
			
			//bodyContainer.addChild(_descriptionLabel1);
			bodyContainer.addChild(_descriptionLabel);

			container = new Sprite();
			bodyContainer.addChild(container);
			/*container.x = 55;
			container.y = 200;*/
			
			
			settings['L'] = settings.content.length + settings.bonus.length;
			if (settings['L'] < 2) settings['L'] = 2;
			
			//settings.width = 130 * settings['L'] + 130;
			
			//if(background != null)
				//layer.removeChild(background);
				//
			//background = backing(settings.width, settings.height, 50, "windowActionBacking");
			//layer.addChildAt(background,0);
			
			drawImage();	
			contentChange();
			drawPrice();
			drawTime();
			updateDuration();
			App.self.setOnTimer(updateDuration);
			
			if(fader != null)
				onRefreshPosition();
			
			_descriptionLabel.x = settings.width / 2 - _descriptionLabel.width / 2;
			_descriptionLabel.y = settings.height - 138;
			
			var X:int = 10;
			for each(var bttn:PromoIcon in bttns) {
				
				if (bttn.pID == pID) 
				{
					bttn.clickable = false;
					bttn.scaleX = bttn.scaleY = 1.2;
					bttn.filters = [];
					bttn.bttn.startRotate(0, 10000, 1);
					bttn.x = X;
					bttn.y = -6;
					X += 84;
				}
				else
				{
					bttn.clickable = true;
					UserInterface.effect(bttn, 0, 0.6);
					bttn.scaleX = bttn.scaleY = 1;
					bttn.y = 0;
					bttn.bttn.stopRotate();
					bttn.x = X;
					X += 70;
				}
			}
			
			if (menuSprite != null){
				menuSprite.x = settings.width / 2 - (promoCount * 70) / 2 - 20;
			}
			
			drawMirrowObjs('decSeaweed', settings.width + 56, - 56, settings.height - 176, true, true, false, 1, 1, layer);
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var sID:* in data)
				result.push({sID:sID, count:data[sID], order:action.iorder[sID]});
			
			result.sortOn('order');
			return result;
		}
		
		private var axeX:int
		private var _descriptionLabel:TextField;
		private var _descriptionLabel1:TextField;
		
		override public function drawBody():void 
		{
			back1 = backing(settings.width - 70, settings.height - 70, 40, 'paperClear');
			bodyContainer.addChild(back1);
			back1.x = (settings.width - back1.width) / 2;
			back1.y = (settings.height - back1.height) / 2 - 42;
			exit.y -= 20;
			
			drawBackDividerTwo();
			
			backPicture.graphics.lineStyle(1, 0x6d6d6d, 0.7);
			backPicture.graphics.beginFill(0xf5ead5);
		    backPicture.graphics.drawRoundRect(0, 0, 295, 295, 20, 20);
			backPicture.y = 97;
			backPicture.x = 60;
		    backPicture.graphics.endFill();
			backPicture.filters = [new DropShadowFilter(3, 90, 0x8f8f8f, 0.6, 2, 2, 1, 1)];
		    bodyContainer.addChild(backPicture);
			bodyContainer.addChild(picture);
			bodyContainer.addChild(maska);
			Load.loading(Config.getImage('actions/backgrounds', actions.picture, 'jpg'), function(data:*):void{
				picture.bitmapData = data.bitmapData;
				Size.size(picture, backPicture.width - 18, backPicture.height - 18);
				picture.smoothing = true;
				picture.x = backPicture.x + (backPicture.width - picture.width) / 2;
				picture.y = backPicture.y + (backPicture.height - picture.height) / 2;
				maska.graphics.beginFill(0xFFFFFF, 1);
				maska.graphics.drawRoundRect(0, 0, picture.width, picture.height, 20, 20);
				maska.graphics.endFill();
				maska.x = picture.x;
				maska.y = picture.y;
				maska.cacheAsBitmap = true;
				picture.mask = maska;
			});
			
			blueStripe = new Bitmap(Window.textures.blueStripe);
			blueStripe.x = backPicture.x + 35;
			blueStripe.y = backPicture.y + backPicture.height - blueStripe.height - 3;
			blueStripe.filters = [new DropShadowFilter(3, 90, 0x8f8f8f, 0.6, 4, 4, 2, 2)];
			bodyContainer.addChild(blueStripe);
			
			rewardCont = new Sprite();
			rewardText1 = drawText(Locale.__e('flash:1490712871188'), {
				fontSize	:30,
				autoSize	:"left",
				textAlign	:"center",
				color		:0xffffff,
				borderColor	:0x005d74,
				borderSize	:3
			});
			rewardText1.x = 0;
			rewardText1.y = 0;
			rewardCont.addChild(rewardText1);
			
			chairIcon = new Bitmap(UserInterface.textures.chair_green);
			chairIcon.x = rewardText1.x + rewardText1.textWidth + 10;
			chairIcon.y = 0;
			chairIcon.filters = [new GlowFilter(0xffffff, 1, 3, 3, 5, 5)];
			Size.size(chairIcon, 30, 30);
			rewardCont.addChild(chairIcon);
			
			var reward:int;
			for (var itm:* in action.items){
				if (App.data.storage[itm].hasOwnProperty('tostock') && Numbers.firstProp(App.data.storage[itm].tostock).val > 0)
				{		
					reward += Numbers.firstProp(App.data.storage[itm].tostock).val;
				}
			}
			if (action.bonus.hasOwnProperty(Stock.CHAIR))
				reward = action.bonus[Stock.CHAIR];
			rewardText2 = drawText(String(reward), {
				fontSize	:30,
				autoSize	:"left",
				textAlign	:"center",
				color		:0xf3ff3a,
				borderColor	:0x7e3e13,
				borderSize	:3
			});
			
			rewardText2.x = chairIcon.x + chairIcon.width + 5;
			rewardText2.y = 0;
			rewardCont.addChild(rewardText2);
			rewardCont.x = blueStripe.x + 40;
			rewardCont.y = blueStripe.y + 12;			
			bodyContainer.addChild(rewardCont);
			
			fishDual = new Bitmap(Window.textures.fishDual);
			fishDual.x = settings.width - fishDual.width + 40;
			fishDual.y = settings.height - fishDual.height - 30;
			bodyContainer.addChild(fishDual);
			
			changePromo(action.id);
			
			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
				
			_descriptionLabel.x = settings.width / 2 - _descriptionLabel.width / 2;

		}
		
		override protected function onRefreshPosition(e:Event = null):void
		{ 		
			var stageWidth:int = App.self.stage.stageWidth;
			var stageHeight:int = App.self.stage.stageHeight;
			
			layer.x = (stageWidth - settings.width) / 2;
			layer.y = (stageHeight - settings.height) / 2;
			
			fader.width = stageWidth;
			fader.height = stageHeight;
		}
		
		private var promoCount:int = 0;
		private var menuSprite:Sprite
		private var bttns:Array = [];
		/*private function drawMenu():void {
			//return
			menuSprite = new Sprite();
			var X:int = 10;
						
			if (App.data.promo == null) return;
			
			for (var pID:* in App.user.promo) {
				
				var promo:Object = App.data.promo[pID];	
				
				if (App.user.promo[pID].status)	continue;
				if (App.time > App.user.promo[pID].started + promo.duration * 3600||promo.buy==1)	continue
					
				promoCount++;
				var bttn:PromoIcon = new PromoIcon(pID, this);
				menuSprite.addChild(bttn);
				bttns.push(bttn);
				bttn.y = 0;
				bttn.x = X;
				
				if (App.user.promo[pID].hasOwnProperty('new')) 
				{
					if(App.time < App.user.promo[pID]['new'] + 2*3600)
						bttn._new = true;
					
					if(App.time < App.user.promo[pID]['new'] + 5*60)
						bttn.showGlowing();
				}
				X += 70;
			}
			
			bodyContainer.addChild(menuSprite);
			menuSprite.y = settings.height - 70;
			var bg:Bitmap = Window.backing((promoCount * 70) + 40, 70, 10, 'smallBacking');
			menuSprite.addChildAt(bg, 0);
			
			menuSprite.x = (settings.width - menuSprite.width) / 2 - 10;
		}*/
		
		private var glowing:Bitmap;
		private var stars:Bitmap;
		private function drawImage():void {
			if(action.image != null && action.image != " " && action.image != ""){
				Load.loading(Config.getImage('promo/images', action.image), function(data:Bitmap):void {
					
					var image:Bitmap = new Bitmap(data.bitmapData);
					bodyContainer.addChildAt(image, 0);
					image.x = 20;
					image.y = 185;
					
				});
			}else{
				axeX = settings.width / 2;
			}

		}
		
		override public function onBuyComplete(data:* = null):void {
			super.onBuyComplete(data);
			
			for each(var item:ActionItem in items) {
				var bonus:BonusItem = new BonusItem(item.sID, item.count);
				var point:Point = Window.localToGlobal(item);
				bonus.cashMove(point, App.self.windowContainer);
			}
		}
		
		public override function contentChange():void 
		{
			
			for each(var _item:ActionItem in items)
			{
				container.removeChild(_item);
				_item = null;
			}
			
			items = [];
			var Xs:int = 0;
			var Ys:int = -20;
			var X:int = 0;
			
			var itemNum:int = 0;
			//for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			
			itemDesc = drawText(Locale.__e('flash:1473090871653'), {
				fontSize	:28,
				autoSize	:"left",
				textAlign	:"center",
				color		:0x7e3e13,
				border		:false
			});
			itemDesc.x = 25;
			itemDesc.y = -60;
			container.addChild(itemDesc);
			
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var item:ActionItem = new ActionItem(settings.content[i], this);
				item.x = Xs;
				item.y = Ys;
				Xs += item.background.width + 12;
				container.addChild(item);
				if (itemNum == 1 || itemNum == 3 || itemNum == 5){
					Xs = X;
					Ys += item.background.height + 10;
				}				
				items.push(item);
				
				itemNum++;
			}
			
			/*for (i = 0; i < settings.bonus.length; i++)
			{
				item = new ActionItem(settings.bonus[i], this, true);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width;
			}*/
			
			container.y = (settings.height - container.height) / 2;
			container.x = settings.width - container.width - 100;
		}
		
		private var timerContainer:Sprite;
		public function drawTime():void {
			
			if (timerContainer != null)
				bodyContainer.removeChild(timerContainer);
				
			timerContainer = new Sprite()
			
			var colorTransform:ColorTransform = new ColorTransform(0.5, 0.5, 0.5);

			descriptionLabel = drawText(Locale.__e('flash:1382952379794'), {
				fontSize:30,
				textAlign:"left",
				color:0xffdf34,
				borderColor:0x7e3e13,
				width:250
			});
			descriptionLabel.x = 0;
			descriptionLabel.y = 0;
			timerContainer.addChild(descriptionLabel);
			
			clockIcon = new Bitmap(Window.textures.clockIcon)
			clockIcon.x = descriptionLabel.x + descriptionLabel.textWidth + 10;
			clockIcon.y = descriptionLabel.y - 4;
			timerContainer.addChild(clockIcon);
			var time:int = action.duration * 60 * 60 - (App.time - App.user.promo[action.id].started);
			//timerText = Window.drawText(TimeConverter.timeToCuts(time, true, true), {
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xff002e,
				letterSpacing:0,
				textAlign:"left",
				fontSize:34,//30,
				borderColor:0xffffff
			});
			timerText.width = 200;
			timerText.y = clockIcon.y + 5;
			timerText.x = descriptionLabel.x + descriptionLabel.textWidth + 55;
			
			timerContainer.addChild(timerText);
			timerContainer.y = 32;
			timerContainer.x = (settings.width - timerContainer.width) / 2 + 20;
			bodyContainer.addChild(timerContainer);
			
		}
		
		private function drawBackDividerTwo():void
		{
			backTextUp.graphics.beginFill(0xfce4c8);
		    backTextUp.graphics.drawRect(0, 0, settings.width - 140, 55);
			backTextUp.y = 22;
			backTextUp.x = (settings.width - backTextUp.width) / 2;
		    backTextUp.graphics.endFill();
			backTextUp.filters = [new BlurFilter(40, 0, 2)];
		    bodyContainer.addChild(backTextUp);
			
			var dev:Shape = new Shape();
			dev.graphics.beginFill(0xc0804d);
			dev.graphics.drawRect(0, 0, settings.width - 110, 2);
			dev.graphics.endFill();
			
			var dev1:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev1.bitmapData.draw(dev);
			dev1.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			dev1.x = (settings.width - dev1.width) / 2;
			dev1.y = backTextUp.y + backTextUp.height;
			bodyContainer.addChild(dev1);
			
			var dev2:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev2.bitmapData.draw(dev);
			dev2.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			dev2.x = (settings.width - dev2.width) / 2;
			dev2.y = dev1.y + 330;
			bodyContainer.addChild(dev2);
			
			backTextDown.graphics.beginFill(0xfce4c8);
		    backTextDown.graphics.drawRect(0, 0, settings.width - 140, 55);
			backTextDown.y = dev2.y + dev2.height;
			backTextDown.x = (settings.width - backTextDown.width) / 2;
		    backTextDown.graphics.endFill();
			backTextDown.filters = [new BlurFilter(40, 0, 2)];
		    bodyContainer.addChild(backTextDown);
		}
		
		/*private function drawBackDividerTwo():void{
			backTextUp.graphics.beginFill(0xfce4c8);
		    backTextUp.graphics.drawRect(0, 0, settings.width - 140, 55);
			backTextUp.y = 22;
			backTextUp.x = (settings.width - backTextUp.width) / 2;
		    backTextUp.graphics.endFill();
			backTextUp.filters = [new BlurFilter(40, 0, 2)];
		    bodyContainer.addChild(backTextUp);
			
			//var dev1:Bitmap = Window.backingShort(settings.width - 110, "dividerTop", false);
			//dev1.x = (settings.width - dev1.width) / 2;
			//dev1.y = backTextUp.y + backTextUp.height;
			//bodyContainer.addChild(dev1);
			
			//var dev2:Bitmap = Window.backingShort(settings.width - 110, "dividerTop", false);
			//dev2.x = (settings.width - dev2.width) / 2;
			//dev2.y = dev1.y + 330;
			//bodyContainer.addChild(dev2);
			
			backTextDown.graphics.beginFill(0xfce4c8);
		    backTextDown.graphics.drawRect(0, 0, settings.width - 140, 55);
			//backTextDown.y = dev2.y + dev2.height;
			backTextDown.x = (settings.width - backTextDown.width) / 2;
		    backTextDown.graphics.endFill();
			backTextDown.filters = [new BlurFilter(40, 0, 2)];
		    bodyContainer.addChild(backTextDown);
		}*/
		
		private var cont:Sprite;
		public function drawPrice():void {
			
			var bttnSettings:Object = {
				fontSize:32,
				width:186,
				height:52 + 10*int(App.isSocial('MX'))
				//hasDotes:true
			};
			price = action.price[App.self.flashVars.social];
			var text:String = '%d';
			switch(App.self.flashVars.social) {
				
				case "VK":
				case "DM":
						text = 'flash:1382952379972';
					break;
				case "OK":
						text = '%d ОК';
					//	bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
					//	bttnSettings['fontColor'] = 0x3f2a1a;
					//	bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;	
				case "MM":
						text = '[%d мэйлик|%d мэйлика|%d мэйликов]';
					//	bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
					//	bttnSettings['fontColor'] = 0x3f2a1a;
					//	bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;
				case "HV":
					price = int(price) / 100;
					text = '%d €';
				break;	
				case "PL":
				case "AI":
					text = '%d aコイン';
					bttnSettings.fontSize = 20;
					break;
				case "YB":
					text = 'flash:1421404546875'; 
					bttnSettings.fontSize = 20;
					break;
				case "MX":
					text = '%d pt.'
					break;
				case "FS":
					text = '%d ФМ'; 
				break;
				case "NK":
					text = '%d €GB'; 
				break;
				case "YN":
					text = String(price) + ' USD'; 
					break;
				case "FB":
						var price:Number = action.price[App.self.flashVars.social];
						price = price * App.network.currency.usd_exchange_inverse;
						price = int(price * 100) / 100;
						text = price + ' ' + App.network.currency.user_currency;	
						
						/*bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						bttnSettings['fontColor'] = 0x3f2a1a;
						bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];*/
					break;
			}
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
				
			bttnSettings['caption'] = Locale.__e(text,[price])
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			
			priceBttn.x = settings.width/2 - priceBttn.width / 2;
			priceBttn.y = settings.height - priceBttn.height / 2 - 60;//135;
			
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			
				if (Payments.byFants)
				priceBttn.fant();
				
			if (cont != null)
				bodyContainer.removeChild(cont);
				
			cont = new Sprite();
			
			bodyContainer.addChild(cont);
			cont.x = priceBttn.x + priceBttn.width / 2 - cont.width / 2;
			cont.y = priceBttn.y - 30;
			
			if(App.isSocial('MX')){
				var mixiLogo:Bitmap =   new Bitmap(Window.textures.mixieLogo);
				priceBttn.topLayer.addChild(mixiLogo);
				priceBttn.fitTextInWidth(priceBttn.width - (mixiLogo.width + 10));
				priceBttn.textLabel.width = priceBttn.textLabel.textWidth + 5;
				priceBttn.textLabel.x = (priceBttn.width - (priceBttn.textLabel.width + mixiLogo.width + 5)) / 2 + mixiLogo.width + 5;
				mixiLogo.x = priceBttn.textLabel.x - mixiLogo.width - 5 ;
				mixiLogo.y = (priceBttn.height - mixiLogo.height) / 2;
			}
		}
		
		private function updateDuration():void {
			var time:int = action.duration * 3600 - (App.time - App.data.actions[action.id].begin_time);
			timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				descriptionLabel.visible = false;
				timerText.visible = false;
			}
		}
		
		public override function dispose():void
		{
			for each(var _item:ActionItem in items)
			{
				_item = null;
			}
			
			App.self.setOffTimer(updateDuration);
			super.dispose();
		}
	}
}

import buttons.ImagesButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

internal class PromoIcon extends LayerX
{
	private var data:Object;
	public var pID:String;
	public var bttn:ImagesButton;
	private var win:*;
	public var clickable:Boolean = true;
	
	public function PromoIcon(pID:String, win:*)
	{
		this.pID = pID;
		this.win = win;
		//var backBitmap:Bitmap = Window.backing(120, 70, 8, 'textSmallBacking');
		
		data = App.data.promo[pID];
		for (var sID:* in data.items) break;
		var url:String = Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
		
		bttn = new ImagesButton(new BitmapData(100,100,true,0));
		//addChild(bttn);
		
		Load.loading(Config.getImage('promo/icons', data.preview), function(data:*):void {
			bttn.bitmapData = data.bitmapData;
		});
		
		Load.loading(url, function(data:Bitmap):void 
		{
			bttn.icon = data.bitmapData;
			bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = 0.5;
			bttn.iconBmp.smoothing = true;
			//bttn.iconBmp.filters = iconSettings.filter;
			bttn.iconBmp.x = 40 - bttn.iconBmp.width / 2;//(bttn.bitmap.width - bttn.iconBmp.width)/2;
			bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2;
		});
		
		bttn.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private var title:TextField;
	public function set _new(value:Boolean):void 
	{
		var textSettings:Object = {
			text:Locale.__e("flash:1382952379743"),
			color:0xf0e6c1,
			fontSize:19,
			borderColor:0x773c18,
			scale:0.5,
			textAlign:'center',
			multiline:true
		}
		
		var title:TextField = Window.drawText(textSettings.text, textSettings);
		title.wordWrap = true;
		title.width = 60;
		title.height = title.textHeight + 4;
		
		if (value == true){
			bttn.addChild(title);
			title.x = (bttn.bitmap.width - title.width)/2 - 2;
			title.y = (bttn.bitmap.height - title.height) / 2 + 14;
		}else{
			
		}
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onClick(e:MouseEvent):void {
		if (clickable == false) return;
		win.changePromo(pID);
	}
}

import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;

internal class ActionItem extends Sprite {
		
		public var count:uint;
		public var sID:uint;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var window:*;
		
		private var preloader:Preloader = new Preloader();
		
		private var bonus:Boolean = false;
		
		private var sprite:LayerX;
		
		public function ActionItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			
			this.window = window;
			this.bonus = bonus;
			
			background = Window.backing(80, 80, 10, 'levelUpItemBacking');
			if (bonus)
			{
				background = new Bitmap(Window.textures.presentBacking);
				background.y = 0;
			}
			
		
			
			//addChild(background);
			
			
			
			sprite = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			
			//drawTitle();
			
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height) / 2 - 15;
			
			var type:String = App.data.storage[sID].type;
			var preview:String = App.data.storage[sID].preview;
			
			switch(sID) {
				case Stock.COINS:
					type = "Coins";
					preview = getPreview(Stock.COINS, type);
				break;
				case Stock.FANT:
					type = "Reals";
					preview = getPreview(Stock.FANT);
				break;
				case Stock.FANTASY:
					type = "Energy";
					preview = "energy1"
				break;
			}
			Load.loading(Config.getIcon(type, preview), onPreviewComplete);
		}
		
		private function getPreview(sid:int, type:String = "Reals"):String
		{
			var preview:String;// = App.data.storage[sID].preview;
			
			var arr:Array = [];
			arr = getIconsItems(type);
			arr.sortOn("order", Array.NUMERIC);
			
			if (arr.length == 0) return preview;
			preview = arr[arr.length-1].preview;
			for (var j:int = arr.length-1; j >= 0; j-- ) {
				if (count >= arr[j].price[sid]) {
					preview = arr[j].preview;
				}
				if (type == "Reals" && arr[j]) {
					
				}
				if (type == "Reals") {
					preview = "crystal_03";
				}else if (type == "Coins") {
					preview = "gold_02";
				}
				
			}
			return preview;
		}
		
		private function getIconsItems(type:String):Array
		{
			var arr:Array = [];
			
			for (var sID:* in App.data.storage) {
				var object:Object = App.data.storage[sID];
				object['sid'] = sID;
				
				if (object.type == type)
				{
					arr.push(object); 
				}
			}
			
			return arr;
		}

		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			//bitmap.scaleX = bitmap.scaleY = 0.8;
			/*if (bitmap.height > 124) {
				bitmap.scaleX = bitmap.scaleY = 124 / bitmap.height;
			}*/
			Size.size(bitmap, 80, 80);
		
			bitmap.smoothing = true;
			bitmap.x = background.x + (background.width - bitmap.width) / 2;
			bitmap.y = background.y + (background.height - bitmap.height) / 2;
			bitmap.filters = [new DropShadowFilter(4, 45, 0x8f8f8f, 0.5, 5, 5, 2, 2)];
			drawCount();
			var description:String = App.data.storage[sID].description;
			if (sID == App.data.storage[App.user.worldID].techno[0]) {
				description = Locale.__e('flash:1396445082768');
			}
			
			sprite.tip = function():Object {
				return {
					title:App.data.storage[sID].title,
					text:description
				};
			}
			/*
			if (bonus)
			{
				var backGlow:Bitmap = new Bitmap(Window.textures.dailyBonusItemGlow);
				backGlow.scaleX = backGlow.scaleY = 1.2;
				backGlow.smoothing = true;
				Size.size(bitmap, 90, 90);
				bitmap.x += 14;
				bitmap.y += 10;
				backGlow.x = bitmap.x + (bitmap.width - backGlow.width) / 2;
				backGlow.y = bitmap.y + (bitmap.height - backGlow.height) / 2;
				sprite.addChild(backGlow);
				sprite.swapChildren(backGlow, bitmap);
				//bitmap.filters = [new GlowFilter(0xffffff, 1, 40, 40)];
			}*/
		}
		/*
		public function drawTitle():void {
			title = Window.drawText(String(App.data.storage[sID].title), {
				color:0x773c18,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:24,
				textLeading:-6,
				multiline:true
			});
			title.wordWrap = true;
			title.width = background.width - 20;
			title.y = 10;
			title.x = 10;
			addChild(title);
		}*/
		
		public function drawCount():void {
			var countText:TextField = Window.drawText('x' + String(count), {
				color		:0xffffff,
				borderColor	:0x7e3e13,
				textAlign	:"center",
				autoSize	:"center",
				fontSize	:28,
				textLeading	:-6,
				multiline	:true,
				width		:40
			});
			countText.wordWrap = true;
			//countText.width = background.width - 10;
			countText.y = background.y + background.height - countText.height;
			countText.x = background.x + background.width - countText.width;
			sprite.addChild(countText);
				/*if (sID == Stock.FANTASY) 
			{
				var smallIco:Bitmap = new Bitmap(UserInterface.textures.energyIconSmall);
				Size.size(smallIco, 35, 35);
				smallIco.filters = [new GlowFilter(0xffffff, 1, 6, 6)];
				smallIco.smoothing = true;
				countText.text = '+' + String(count);
				addChild(smallIco)
				smallIco.x = (background.width -countText.textWidth  - smallIco.width) / 2;
				countText.y = background.height - 50;
				smallIco.y = countText.y ;
				countText.x = smallIco.x + smallIco.width / 2 - 5;
			}*/
		
		}
}
