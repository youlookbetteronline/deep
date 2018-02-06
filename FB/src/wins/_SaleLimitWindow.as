package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;

	public class SaleLimitWindow extends AddWindow
	{
		private var items:Array = new Array();
		//public var action:Object;
		private var container:Sprite;
		private var actionImages:Object;
		private var priceBttn:Button;
		private var timerText:TextField;
		private var pID:uint;
		public var maska:Shape = new Shape();
		private var descriptionLabel:TextField;
		private var backgroundItem:Bitmap = new Bitmap();
		protected var actions:Object;
		
		public function SaleLimitWindow(settings:Object = null)
		{
			
			pID = settings.pID;
			actions = App.data.actions[pID];
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 430;
			settings['height'] = 480;
						
			settings['title'] = Locale.__e("flash:1382952379793");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['exitTexture'] = 'closeBttnMetal';
			settings['fontColor'] = '0xffffff';
			settings['fontSize'] = 44;
			settings['fontBorderColor'] = 0x4b7915;
			settings['shadowColor'] = 0x085c10;
			settings['fontBorderSize'] = 3;
	
			super(settings);
		}
		
		override public function drawPromoPanel():void {
			
		}
		
		override public function drawBackground():void 
		{
			//var background:Bitmap = backing2(settings.width, settings.height, 45, 'questsSmallBackingTopPiece', 'questsSmallBackingBottomPiece');
			var background:Bitmap = backing(settings.width, settings.height, 45, "capsuleWindowBacking"/*, "questsSmallBackingBottomPiece"*/);
			layer.addChild(background);
		}
		
		private var background:Bitmap
		public function changePromo(pID:String):void {
			
			App.self.setOffTimer(updateDuration);
			
			action = App.data.actions[pID];
			
			settings.content = initContent(action.items);  // поменять как на серваке будет готово
			
			settings['L'] = settings.content.length;
			if (settings['L'] < 2) settings['L'] = 2;
			
			drawImage();	
			contentChange();
			drawPrice();
			drawTime();
			
			App.self.setOnTimer(updateDuration);
			
			if(fader != null)
				onRefreshPosition();
				
			titleLabel.x = (settings.width - titleLabel.width) / 2;	
			//_descriptionLabel.x = settings.width/2 - _descriptionLabel.width/2;
			exit.y -= 10;
			
			if (menuSprite != null){
				menuSprite.x = settings.width / 2 - (promoCount * 70) / 2 - 20;
			}
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var sID:* in data)
				result.push({sID:sID, count:data[sID], order:action.iorder[sID],pID:settings.pID});
			
			result.sortOn('order');
			return result;
		}
		
		private var axeX:int
		private var _descriptionLabel:TextField;
		override public function drawBody():void 
		{
			drawRibbon();
			titleLabel.y += 10;
			/*var ribbon:Bitmap = backingShort(300, 'ribbonGrenn');
			ribbon.x = settings.width / 2 -ribbon.width / 2;			
			ribbon.y = -68;*/
			
			var glowIcon:Bitmap = new Bitmap(Window.textures.dailyBonusItemGlow);
			glowIcon.scaleX = glowIcon.scaleY = 2.5;
			glowIcon.smoothing = true;
			glowIcon.x = (settings.width - glowIcon.width) / 2;
			glowIcon.y = -130;
			bodyContainer.addChild(glowIcon);
			
			backgroundItem = new Bitmap(Window.textures.actionItemBg);
			backgroundItem.x = (settings.width - backgroundItem.width)/2;
			backgroundItem.y = 24;
			bodyContainer.addChild(backgroundItem);
			
			Load.loading( Config.getImage('actions/backgrounds', actions.picture, 'jpg'), onBgComplete);
			bodyContainer.addChild(picture);
			bodyContainer.addChild(maska);
			
			//bodyContainer.addChild(ribbon);
			
			/*var text:String = Locale.__e("flash:1393581986914");
			_descriptionLabel = drawText(text, {
				fontSize:26,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x175d8e
			});*/
			
			//_descriptionLabel.border = true;
			/*_descriptionLabel.y = 3;
			
			bodyContainer.addChild(_descriptionLabel);*/
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2;
			container.y = 60;

			//drawMenu();
			changePromo(settings['pID']);
			
			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
				
			/*_descriptionLabel.x = settings.width / 2 - _descriptionLabel.width / 2;*/
			
			drawDescription();
			
		}
		
		private function drawDescription():void 
		{
			
			
			var descText:String = App.data.actions[action.id].text1;
			if (descText == '')
				descText = App.data.storage[Numbers.firstProp(App.data.actions[action.id].items).key].description;
			var desc:TextField = Window.drawText(descText, {//App.data.actions[action.id].text1  поменять
				color:0x6d350d,
				border: false,
				textAlign:"center",
				autoSize:"center",
				fontSize:26,
				textLeading:-6,
				multiline:true
			});
			desc.wordWrap = true;
			desc.width = settings.width - 80;
			
			
			back.graphics.beginFill(0xf6db65, .9);
			back.graphics.drawRect(0, 0, settings.width - 120, desc.textHeight + 10);
			back.graphics.endFill();
			back.x = (settings.width - back.width)/2;
			back.y = settings.height - 160;
			back.filters = [new BlurFilter(40, 0, 2)];
			
			desc.y = back.y + (back.height - desc.textHeight) / 2;
			desc.x = (settings.width - desc.width) / 2;
			
			bodyContainer.addChild(back);
			bodyContainer.addChild(desc);	
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
		private function drawMenu():void {
			
			menuSprite = new Sprite();
			var X:int = 10;
						
			if (App.data.promo == null) return;
			
			/*for (var pID:* in App.user.promo) {
				
				var promo:Object = App.data.promo[pID];	
				
				if (App.user.promo[pID].status)	continue;
				if (App.time > App.user.promo[pID].started + promo.duration * 3600)	continue
					
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
			}*/
			
			bodyContainer.addChild(menuSprite);
			menuSprite.y = settings.height - 70;
			var bg:Bitmap = Window.backing((promoCount * 70) + 40, 70, 10, 'smallBacking');
			menuSprite.addChildAt(bg, 0);
			
			menuSprite.x = (settings.width - menuSprite.width) / 2 - 10;
		}
		
		private var glowing:Bitmap;
		private var stars:Bitmap;
		private var stars2:Bitmap;
		private var stars3:Bitmap;
		private var stars4:Bitmap;
		private var stars5:Bitmap;
		private var stars6:Bitmap;
		private function drawImage():void {
			if(action.image != null && action.image != " " && action.image != ""){
				Load.loading(Config.getImage('promo/images', action.image), function(data:Bitmap):void {
					
					var image:Bitmap = new Bitmap(data.bitmapData);
					bodyContainer.addChildAt(image, 0);
					image.x = 20;
					image.y = 185;
					if (action.image == 'bigPanda') {
						image.x = -200;
						image.y = -20;
						//this.x += 100;
					}
				});
			}else{
				axeX = settings.width / 2;
			}
			
			/*if (glowing == null)
			{
				glowing = new Bitmap(Window.textures.glow2);
				bodyContainer.addChildAt(glowing, 0);
			}
			
			if (stars == null) {
				stars = new Bitmap(Window.textures.decorStars);
				bodyContainer.addChildAt(stars, 1);
			}
			if (stars2 == null) {
				stars2 = new Bitmap(Window.textures.decorStars);
				bodyContainer.addChildAt(stars2, 2);
			}
			if (stars3 == null) {
				stars3 = new Bitmap(Window.textures.decorStars);
				bodyContainer.addChildAt(stars3, 3);
				stars3.scaleX = -1;
			}
			if (stars4 == null) {
				stars4 = new Bitmap(Window.textures.decorStars);
				bodyContainer.addChildAt(stars4, 4);
				stars4.scaleX = -1;
			}
			
			if (stars5 == null) {
				stars5 = new Bitmap(Window.textures.decorStars);
				bodyContainer.addChildAt(stars5, 5);
			}
			if (stars6 == null) {
				stars6 = new Bitmap(Window.textures.decorStars);
				bodyContainer.addChildAt(stars6, 6);
				stars6.scaleX = -1;
			}*/
			
			/*stars.x = 0;
			stars.y = 20;
			stars2.x = 0;
			stars2.y = stars.y + stars.height - 30;
			
			stars3.x = stars.x + stars.width + 120;
			stars3.y = 20;
			stars4.x = stars2.x + stars2.width + 120;
			stars4.y = stars3.y + stars3.height - 30;
			
			stars5.x = 0;
			stars5.y = stars2.y + stars2.height - 30;
			stars6.x = stars5.x + stars5.width + 120;
			stars6.y = stars5.y;
			
			glowing.alpha = 0.85;
			glowing.scaleX = glowing.scaleY = 0.5;
			glowing.smoothing = true;
			glowing.x = (settings.width - glowing.width) / 2;
			glowing.y = 50;
			glowing.smoothing = true;
			
			
			glowing.width = (settings.width - 100);
			glowing.x = 50;
			axeX = settings.width / 2;*/
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
			var Ys:int = 0;
			var X:int = 0;
			
			var itemNum:int = 0;
			//for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var item:ActionItem = new ActionItem(settings.content[i], this);
				
				container.addChild(item);
				//item.x = Xs;
				//item.y = Ys;
								//
				items.push(item);
				//Xs += item.background.width;
			}
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, movePictureParallax);
			
			container.y = 32;
			container.x = (settings.width - item.background.width) / 2;
		}
		
		private var timerContainer:Sprite;
		public function drawTime():void {
			
			if (timerContainer != null)
				bodyContainer.removeChild(timerContainer);
				
			timerContainer = new Sprite()
			
			/*var background:Bitmap = Window.backingShort(200, "timeBg");
			timerContainer.addChild(background);
			background.x =  - background.width/2;
			background.y = settings.height - background.height - 80;*/
			
			descriptionLabel = drawText(Locale.__e('flash:1393581955601'), {
				fontSize:30,
				textAlign:"right",
				color:0xffffff,
				borderColor:0x7f3d0e
			});
			descriptionLabel.width = descriptionLabel.textWidth + 10;
			//descriptionLabel.border = true;
			timerContainer.addChild(descriptionLabel);
			
			var time:int = action.duration * 60 * 60 - (App.time - App.data.actions[action.id].time);
			
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xffffff,
				letterSpacing:3,
				textAlign:"left",
				fontSize:28,//30,
				borderColor:0x7f3d0e
			});
			timerText.width = timerText.textWidth + 10;
			timerText.y = descriptionLabel.y + 2;
			timerText.x = descriptionLabel.x + descriptionLabel.width + 3;
			//timerText.border = true;
			
			timerContainer.addChild(timerText);
			
			bodyContainer.addChild(timerContainer);
			timerContainer.x = (settings.width - timerContainer.width )/ 2;
			timerContainer.y = settings.height - 200;
		}
		
		private var cont:Sprite;
		private var back:Shape = new Shape();
		public function drawPrice():void {
			
			var bttnSettings:Object = {
				fontSize:36,
				width:(App.isSocial('OK', 'MM'))?208:180,
				height:52,
				hasDotes:false,
				textAlign:'center'
			};
			
			var text:String;
			switch(App.self.flashVars.social) {
				
				case "VK":
				case "DM":
						text = 'flash:1382952379972';
					break;
				case "OK":
						text = 'Купить за %d ОК';
					break;	
				case "MM":
						text = '[%d мэйлик|%d мэйлика|%d мэйликов]';
					break;
				case "PL":
				case "YB":
						text = 'flash:1421404546875'; 
						bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						bttnSettings['fontColor'] = 0x3f2a1a;
						bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;
				case "FS":
					text = '%d ФМ'; 
				break;
				case "NK":
					text = '%d €GB'; 
				break;	
			case "FB":
					var price:Number = action.price[App.self.flashVars.social];
					price = price * App.network.currency.usd_exchange_inverse;
					price = int(price * 100) / 100;
					text = price + ' ' + App.network.currency.user_currency;
					break;
			}
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
				
			bttnSettings['caption'] = Locale.__e(text, [action.price[App.self.flashVars.social]])
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = settings.height - priceBttn.height / 2 - 40;//135;
			
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			
			if (cont != null)
				bodyContainer.removeChild(cont);
				
			cont = new Sprite();
			
			bodyContainer.addChild(cont);
			cont.x = priceBttn.x + priceBttn.width / 2 - cont.width / 2;
			cont.y = priceBttn.y - 30;
		}
		
		public static var picCoords:Object = new Object(/*{x:10, y:10}*/);
		public var picture:Bitmap = new Bitmap();
		private function onBgComplete(data:Bitmap):void{
			picture.bitmapData = data.bitmapData;
			Size.size(picture, settings.width - 20, settings.height - 20);
			picture.smoothing = true;
			maska.graphics.beginFill(0xFFFFFF, 1);
			maska.graphics.drawCircle(0, 0, 88);
			maska.graphics.endFill();
			Size.size(picture, 400, 400);
			picture.x = backgroundItem.x + (backgroundItem.width - picture.width) / 2;
			picture.y = backgroundItem.y + (backgroundItem.height - picture.height) / 2;
			picCoords['x'] = picture.x;
			picCoords['y'] = picture.y;
			maska.x = backgroundItem.x + backgroundItem.width / 2;
			maska.y = backgroundItem.y + backgroundItem.height / 2 - 5;
			
			
			
			maska.cacheAsBitmap = true;
			picture.mask = maska;
			
			pictureParallax();
		}
		
		/*private function buyEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			//descriptionLabel.visible = false;
			//timerText.visible = false;
			switch(App.social) {
				case 'PL':
					//if(!App.user.stock.check(Stock.FANT, action.price[App.social])){
						//close();
						
						//break;
					//}
				case 'YB':
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
					}
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
							votes:			action.price[App.self.flashVars.social],
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback: 		onBuyComplete
						}
					}
					ExternalApi.apiPromoEvent(object);
					break;
			}
		}
		
		private function onBuyComplete(e:* = null):void 
		{
			priceBttn.state = Button.DISABLED;
			App.user.stock.addAll(action.items);
			App.user.stock.addAll(action.bonus);
			
			for each(var item:ActionItem in items) {
				var bonus:BonusItem = new BonusItem(item.sID, item.count);
				var point:Point = Window.localToGlobal(item);
					bonus.cashMove(point, App.self.windowContainer);
			}
			
			App.user.promo[action.id].buy = 1;
			App.user.buyPromo(action.id);
			App.ui.salesPanel.createPromoPanel();
			
			close();
			
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				title:Locale.__e("flash:1382952379735"),
				text:Locale.__e("flash:1382952379990")
			}).show();
		}*/
		
		private function updateDuration():void {
			var time:int = action.duration * 60 * 60 - (App.time - App.data.actions[action.id].time);
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
				this.removeEventListener(MouseEvent.MOUSE_MOVE, movePictureParallax);
			}
			
			App.self.setOffTimer(updateDuration);
			super.dispose();
		}
		
		private function movePictureParallax(e:MouseEvent):void
		{
			pictureParallax();
		}

		private var bias:Number = 50;
		private function pictureParallax():void
		{
			picture.x = picCoords.x - bias / 2 + bias * (mouseX / stage.stageWidth) + picture.width / 8;
			picture.y = picCoords.y - bias / 2 + bias * (mouseY / stage.stageHeight);
			if (items.length > 0 && items[0].anime)
			{
				items[0].anime.x = items[0].animeCoords.x - (bias / 8) + (bias / 4) * (mouseX / stage.stageWidth);
				items[0].anime.y = items[0].animeCoords.y - (bias / 8) + (bias / 4) * (mouseY / stage.stageHeight);
			}
		}
	}
}

import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextField;
import units.Anime2Golden;
import wins.Window;

internal class ActionItem extends LayerX {
		
		public var count:uint;
		public var sID:uint;
		
		public var background:Bitmap;
		public var bitmap:Bitmap;
		
		public var title:TextField;
		public var window:*;
		
		private var sprite:LayerX;
		private var preloader:Preloader = new Preloader();
		
		private var bonus:Boolean = false;
		
		public function ActionItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			
			/*actions = App.data.actions[pID];*/
			this.window = window;
			this.bonus = bonus;
			
			background = new Bitmap(Window.textures.actionItemBg);
			//background.x = ( - background.width) / 2;
			//addChild(background);

			sprite = new LayerX();
			addChild(sprite);
			tip = function():Object {
				return {
					title:		App.data.storage[sID].title,
					text:		App.data.storage[sID].description
				};
			};
			/*bitmap = new Bitmap();
			sprite.addChild(bitmap);*/

			drawTitle();
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 15;
			
			//Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
			Load.loading(Config.getSwf(App.data.storage[sID].type, App.data.storage[sID].preview), onAnimComplete);
			
		}
		public var animeCoords:Object;
		public var anime:Anime2Golden;
		private function onAnimComplete(swf:*):void 
		{			
	
			if (preloader)
			{
				removeChild(preloader);
				preloader = null;
			}			
			anime = new Anime2Golden(swf, { w:background.width - 100, h:background.height - 50, type:App.data.storage[sID].type} );	
			sprite.addChild(anime);
			//Size.size(sprite, 130, 130);
			anime.x = (background.width - sprite.width) / 2;
			anime.y = (background.height - sprite.height) / 2;
			animeCoords = {x:anime.x, y:anime.y};
		}
		
		private function addBonusLabel():void 
		{
			removeChild(background);
			background = null;
			background = Window.backing(150, 190, 55, 'shopSpecialBacking');
			addChild(background);
			
			var bonusIcon:Bitmap = new Bitmap(Window.textures.redBow);
			bonusIcon.y = -20;
			bonusIcon.x = -20;
			addChild(bonusIcon);
			
		}
		
		public function drawTitle():void {
			
			title = Window.drawText(String(App.data.storage[sID].title), {
				color:0xffffff,
				borderColor:0x7f3d0e,
				textAlign:"center",
				autoSize:"center",
				fontSize:30,
				textLeading:-6,
				multiline:true
			});
			title.wordWrap = false;
			title.width = background.width - 20;
			
			var ribbWidth:int = title.textWidth + 100;
			if (ribbWidth < 200)
				ribbWidth = 200;
			var yellowRibbon:Bitmap = Window.backingShort(ribbWidth, 'actionRibbonBg');
			yellowRibbon.scaleY = .5;
			yellowRibbon.x = (background.width - yellowRibbon.width) / 2;			
			yellowRibbon.y = background.y + background.height - 35;
			addChild(yellowRibbon);
			title.y = yellowRibbon.y + 3;
			title.x = yellowRibbon.x + (yellowRibbon.width - title.width) / 2;
			addChild(title);
		}
		
}
