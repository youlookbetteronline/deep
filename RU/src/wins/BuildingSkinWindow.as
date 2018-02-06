package wins
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import ui.BottomPanel;
	import ui.UserInterface;
	import units.Hero;
	import units.Personage;
	import wins.elements.ShopItem;

	public class BuildingSkinWindow extends Window
	{
		
		public var saveBttn:Button;
		public var backUser:Bitmap;
		public var backLabel:Shape = new Shape();
		public var backBttn:Shape = new Shape();
		private var infoBttn:ImageButton = null;
		public var saveSttings:Object = { };
		
		public var preloader:Preloader = new Preloader();
		public var skins:Object = null;
		
		private var items:Array = [];
		private var backing:Bitmap;
		private var back:Shape = new Shape();
		public var sexBg:LayerX;
		private var tutorialMode:Boolean = false;
			
		public function BuildingSkinWindow(settings:Object = null) 
		{
			if (settings == null)
				settings = new Object();
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = 590;
			settings["height"] = 630;
			settings["fontBorderSize"] = 5;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] = 0x116011;
			settings['shadowColor'] = 0x116011;
			settings['fontSize'] = 42;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 2;
			settings["hasPaginator"] = false;
			settings['exitTexture'] = 'closeBttnMetal';
			
			//settings["title"] = Locale.__e("flash:1484301643090");
			
			initContent(settings);
			super(settings);
		}
		
		public function skinUp(_skin:String):void
		{
			var sendObject:Object = {
				ctr:settings.target.type,
				act:'skin',
				uID:App.user.id,
				id:settings.target.id,
				wID:App.user.worldID,
				sID:settings.target.sid,
				skin:_skin
			}
			
			Post.send(sendObject, onSkinUp);
		}
		
		protected function onSkinUp(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			settings.target.skin = data.skin;
			settings.target.load();
			Window.closeAll();
		}
		
		public function checkOnDressed(_skin:String):Boolean
		{
			if (settings.target.skin && settings.target.skin == _skin)
				return true;
			/*for each(var sid:* in skins)
			{
				if (sid == sID) 
					return true;
			}*/
			
			return false;
		}
		
		public function initContent(_content:Object):void
		{
			skins = new Object();
			var i:int = 0;
			for (var _skin:* in _content.target.info.skins)
			{
				if (App.data.storage[_skin].displayWhenZero == 1 || App.user.stock.count(_skin) > 0)
				{
					skins[i] = {(int(_skin)): String(_content.target.info.skins[_skin])};
					i++;
				}
			}
		}
		
		override public function drawBackground():void 
		{
			//var background:Bitmap  = Window.backing(settings.width, settings.height , 50, 'workerHouseBacking');
			//layer.addChild(background);
			
			var background:Bitmap = Window.backing(settings.width, settings.height ,50, 'capsuleWindowBacking');
			layer.addChild(background);
			
			backing = Window.backing(settings.width - 60, settings.height - 66 ,40, 'paperClear');
			bodyContainer.addChild(backing);
			backing.x = (settings.width - backing.width) / 2;
			backing.y = 0;//(settings.height - backing.height) / 2;
		}
		
		/*protected function drawRibbon():void 
		{
			var ribbonWidth:int = settings.titleWidth + 180;
			if (ribbonWidth < 320)
				ribbonWidth = 320;
			var titleBackingBmap:Bitmap = backingShort(ribbonWidth, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -65;
			//titleBackingBmap.filters = [new GlowFilter(0xf3ff2c, .7, 11, 11, 3)];
			bodyContainer.addChild(titleBackingBmap);
			
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y + 6;
			
			bodyContainer.addChild(titleLabel);
		}*/
		
		private var paginatorUp:Paginator;
		private var paginatorDown:Paginator;
		public function createPaginators():void
		{
			paginator = new Paginator(4, 4, 6, {
				hasArrow:true,
				hasButtons:true
			});
			
			paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);
			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  50,  276, { scaleX:-1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, settings.width - 50, 276, { scaleX:1, scaleY:1 } );
			
			bottomContainer.addChild(paginator);
		}
		
		override public function drawBody():void
		{
			drawRibbon();
			drawInfoBttn();
			drawMirrowObjs('decSeaweed', settings.width + 57, - 57, settings.height - 175, true, true, false, 1, 1, layer);
			
			createPaginators();
			
			titleLabel.y += 8;
			
			exit.x = settings.width - exit.width + 12;
			
			paginator.x = - 7 + backing.x + (backing.width - paginator.width) / 2;
			paginator.y = backing.y + backing.height +3;
			
			drawItems();
		}

		private function drawItems():void
		{
			contentChange()
		}
		
		private function drawInfoBttn():void
		{
			infoBttn = new ImageButton(textures.infoBttnPink);
			bodyContainer.addChild(infoBttn);
			infoBttn.x = settings.width - 47;
			infoBttn.y = 35;
			infoBttn.addEventListener(MouseEvent.CLICK, onInfoEvent);
		}
		
		private function onInfoEvent(e:MouseEvent = null):void
		{
			var hintWindow:WindowInfoWindow = new WindowInfoWindow( {
				popup: true,
				hintsNum:3,
				hintID:7,
				height:540
			});
			hintWindow.show();
		}
		
		override public function contentChange():void
		{
			for (var m:int = 0; m < items.length; m++)
			{
				items[m].dispose();
				bodyContainer.removeChild(items[m]);
			}
			
			//paginator.itemsCount = skins[saveSttings.sex][settings.mode].length;
			paginator.itemsCount = Numbers.countProps(skins);
			paginator.update();
			
			items = [];
			var X:int = backing.x + 54;
			var Y:int = backing.y + 50;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				//var item:SkinItem = new SkinItem(skins[saveSttings.sex][settings.mode][i], this);
				//settings.target.info
				//var item:SkinItem = new SkinItem(skins[saveSttings.sex][settings.mode][i], this);
				var item:SkinItem = new SkinItem(App.data.storage[Numbers.firstProp(skins[i]).key],Numbers.firstProp(skins[i]).val, this);
				bodyContainer.addChild(item);
				item.visible = !tutorialMode;
				item.x = X;
				item.y = Y;
				
				items.push(item);
				X += item.background.width + 20;
				
				if (i % 2 == 1 && i>0)
				{
					X = backing.x + 54;
					Y += item.background.height + 45;
				}
			}
		}
		
		override public function drawExit():void
		{
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		private function onSaveEvent(e:MouseEvent):void
		{
			/*saveSttings.aka = akaField.text;
			
			App.user.aka = saveSttings.aka;
			App.user.sex = saveSttings.sex;
			App.user.head = saveSttings.head;
			App.user.body = saveSttings.sID;
			
			saveSttings.body = saveSttings.sID;
			
			App.user.onProfileUpdate(saveSttings);
			App.user.hero.change(saveSttings);*/
			close();
			
			//Nature.tryChangeMode();
		}
		
		override public function dispose():void 
		{
			super.dispose();
		}

	}
}

import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import units.Anime2;
import wins.Window;

	import buttons.Button;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Cursor;
	import ui.Hints;
	import ui.UserInterface;
	import units.Field;
	import units.Unit;
	import units.Anime2;
	import wins.elements.PriceLabel;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.Window;

	internal class SkinItem extends Sprite {
		
		public var item:*;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var anime:Anime2;
		//public var preloader:Preloader;
		public var title:TextField;
		public var priceBttn:Button;
		public var openBttn:Button;
		public var clothBttn:Button;
		public var window:*;
		private var CY:uint = 70;
		
		public var skin:String;
		public var moneyType:String = "";
		
		private var sprite:LayerX;
		private var preloader:Preloader = new Preloader();
		
		public function SkinItem(item:*,skin:*, window:*) {
			
			this.skin = skin;
			this.item = item;
			this.window = window;
			
			
			background = Window.backing(200, 200, 20, "itemBacking");
			addChild(background);
			
			sprite = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			//anime = new Anime2();
			//sprite.addChild(bitmap);
			//sprite.addChild(anime);
			
			
			sprite.tip = function():Object { 				
				return {
					title:item.title,
					text:item.description
				};
			};
			
			drawTitle();
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height) / 2 - 15;
			
			//if (item.hasOwnProperty('free') && item.free == 1)
			//{
				//App.user.stock.buy(item.sid, 1, onBuyEvent);
			//}
			
			if (App.user.stock.count(item.sID) > 0)
			{
				drawBuyedLabel();
			}else
				drawPriceBttn();
			/*if(App.user.stock.count(item.sID) >0){
				//if (item.hasOwnProperty('unlock') && App.user.level < item.unlock.level && App.user.shop[item.sid] == undefined) {
					//drawOpenBttn();
				//}else{
					drawPriceBttn();
				//}
			}else{
				drawBuyedLabel();
			}*/
			
			if (window.settings.find != null && window.settings.find.indexOf(int(item.sid)) != -1) {
				glowing();
			}
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			
			Load.loading(Config.getSwf('Skin', skin), onPreviewComplete);
		}
		
		public function onPreviewComplete(data:*):void
		{
			
			removeChild(preloader);
			drawAnimation(data);
			//bitmap.bitmapData = data.bitmapData;
			//bitmap.scaleX = bitmap.scaleY = 0.8;
			//bitmap.smoothing = true;
			//bitmap.x = (background.width - bitmap.width)/ 2;
			//bitmap.y = CY - (bitmap.height)/ 2
		}
		
		private function drawAnimation(swf:Object):void 
		{
			anime = new Anime2(swf, { w:background.width - 20, h:background.height - 40 } );
			anime.x = background.width * 0.5 - anime.width * 0.5;
			anime.y = background.height * 0.5 - anime.height * 0.5;
			sprite.addChild(anime);
		}
		
		public function dispose():void {
			
			if(priceBttn != null){
				priceBttn.removeEventListener(MouseEvent.CLICK, onBuyEvent);
			}
			
			if(openBttn != null){
				openBttn.removeEventListener(MouseEvent.CLICK, onOpenEvent);
			}
			
			if(clothBttn != null){
				clothBttn.removeEventListener(MouseEvent.CLICK, onClothEvent);
			}
			
			if (Quests.targetSettings != null) {
				Quests.targetSettings = null;
				if (App.user.quests.currentTarget == null) {
					QuestsRules.getQuestRule(App.user.quests.currentQID, App.user.quests.currentMID);
				}
			}
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
		}
		
		public function drawTitle():void 
		{
			var size:Point = new Point(background.width - 20, 25);
			var pos:Point = new Point(
				10,
				-10
			);
			
			title = Window.drawTextX(String(item.title), size.x, size.y, pos.x, pos.y, this, {
			//title = Window.drawText(String(item.title), {
				color:0xffffff,
				borderColor:0x7f3d0e,
				textAlign:"center",
				autoSize:"center",
				fontSize:20,
				textLeading:-6,
				multiline:true
			});
			title.wordWrap = true;
			title.width = background.width - 20;
			title.y = -10;
			title.x = 10;
			//title.border = true;
			addChild(title);
		}
		
		public function drawBuyedLabel():void {
			
			var labelSettings:Object = {
				text:"",
				fontSize:20,
				autoSize:"left"
			}
			
			var bttnSettings:Object = {
				caption		:"",
				fontSize	:28,
				width		:140,
				height		:45
			};
			
			if (window.checkOnDressed(skin))
			{
				bttnSettings.caption = Locale.__e("Снять");
				bttnSettings.type = 1;
				labelSettings.text = Locale.__e("flash:1382952380162");
				labelSettings.fontSize = 24;
				labelSettings.borderColor = 0x85620d;
				labelSettings.color = 0xf0e6c1;
				
				background.filters = [new GlowFilter(0xFFFF00, .5, 15, 15, 4, 1, true)];
			}
			else
			{
				bttnSettings.type = 0;
				bttnSettings.caption = Locale.__e("flash:1423568900779");
				bttnSettings.borderColor = [0x9f9171, 0x9f9171];
				bttnSettings.fontColor = 0xffffff;
				bttnSettings.fontBorderColor = 0xa9634e;
				bttnSettings.bgColor = [0xfeb268, 0xfe9f53];
				
				labelSettings.text = Locale.__e("flash:1382952380080");
				labelSettings.fontSize = 20;
				
				background.filters = null;
			}
			
			clothBttn = new Button(bttnSettings);
			//clothBttn.color = "fe9f53"
			
			addChild(clothBttn);
			clothBttn.x = background.width/2 - clothBttn.width/2;
			clothBttn.y = background.height - 22;
			
			clothBttn.addEventListener(MouseEvent.CLICK, onClothEvent);
				
			//var label:TextField = Window.drawText(labelSettings.text, labelSettings);
			//addChild(label);
			
			//label.x = (background.width - label.width)/2;
			//label.y = background.height - 54;
			
			if (bttnSettings.type == 1) 
			{
				clothBttn.visible = false
				/*switch(int(item.sid))
				{
					case User.BOY_BODY:
					case User.BOY_HEAD:
					case User.GIRL_BODY:
					case User.GIRL_HEAD:
						clothBttn.visible = false
					break	
				}*/
			}
			
			CY = 90;
		}
		
		private function onClothEvent(e:MouseEvent):void
		{
			//if (e.currentTarget.settings.type == 1)
				//window.clothOff(item.sid);
			//else
				window.skinUp(item.sID);
		}
		
		private var priceLables:Array;
		private var priceSprite:Sprite;
		public function drawPriceBttn():void {
			priceLables = [];
			var icon:Bitmap;
			var price:int = 0;
			var settings:Object = { fontSize:18, autoSize:"left" };
			var bttnSettings:Object = {
				caption		:Locale.__e("flash:1382952379751"),
				fontSize	:28,
				width		:140,
				height		:45
			};
			
			priceSprite = new Sprite();
			var dX:int = 0;
			for (var mt:* in item.price)
			{
				switch(mt)
				{
					case Stock.COINS:
						moneyType = "coins";
						break;
					case Stock.FANT:
						moneyType = "real";
						break;
					default:
						moneyType = "free_item";
				}
			//}
				price = item.price[mt];
				if (price > 0)
				{
					var priceLabel:PriceLabel = new PriceLabel(price, moneyType, .8, {sid:mt});
					priceLabel.x = dX;
					dX += priceLabel.width + 5;
					
					priceLables.push(priceLabel);
					//priceLabel.y = background.height - 23 - priceLabel.height;
					priceSprite.addChild(priceLabel);
				}else{
					bttnSettings["caption"] = Locale.__e("flash:1382952379890");
				}
			}
			addChild(priceSprite);
			priceSprite.x = (background.width - priceSprite.width) / 2;
			priceSprite.y = background.height - 23 - priceSprite.height;
			
			var backShape:Shape = new Shape();
			backShape.graphics.beginFill(0xffffff,.7);
			backShape.graphics.drawRect(0, 0, priceSprite.width, 30);
			backShape.graphics.endFill();
			backShape.filters = [new BlurFilter(20, 0)];
			addChild(backShape);
			
			backShape.x = (background.width - backShape.width) / 2;
			backShape.y = priceSprite.y;
			
			swapChildren(priceSprite, backShape);
			
			if (moneyType == "real")
			{
				bttnSettings["bgColor"] 		= [0x99c9fc, 0x6697f5];
				bttnSettings["borderColor"]		= [0xbad4de, 0x376dda];
				bttnSettings["bevelColor"]		= [0x91c1fa, 0x376dda];
				bttnSettings["fontColor"]	 	= 0xffffff;
				bttnSettings["fontBorderColor"] = 0x395db3;
			}
			priceBttn = new Button(bttnSettings);
			addChild(priceBttn);
			priceBttn.x = (background.width - priceBttn.width) / 2;
			priceBttn.y = background.height - 22;
			
			priceBttn.addEventListener(MouseEvent.CLICK, onBuyAction);
			
			onChangeStock();
		}
		
		private function onChangeStock(e:AppEvent = null):void
		{
			if (moneyType != "" && moneyType == "free_item")
			{
				if (priceLables.length > 0)
				{
					for each(var _plabel:PriceLabel in priceLables)
					{
						_plabel.updatePrice();
					}
				}
				if (priceBttn)
				{
					priceBttn.state = Button.DISABLED;
					if (App.user.stock.checkAll(item.price))
						priceBttn.state = Button.NORMAL;
				}
			}
		}
		
		public function drawOpenBttn():void
		{
			var sprite:Sprite = new Sprite();
			
			var icon:Bitmap;
			var settings:Object = { 
				fontSize:22, 
				autoSize:"left",
				color:0xA3D637,
				borderColor:0x38510D
			};
			
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379890"),
				fontSize:22,
				bgColor: [0xA9DC3C, 0x96C52E],
				borderColor : [0xf8f2bd, 0x836a07],
				fontColor : 0x4E6E16,
				fontBorderColor : 0xDCFA9B,
				width:110,
				height:34,
				shadow:true
			};		
			
			var open:TextField = Window.drawText(Locale.__e("flash:1382952380083"), {
				color:0x4A401F,
				borderSize:0,
				fontSize:16,
				autoSize:"left"
			});
			sprite.addChild(open);
			open.x = 5;
			open.y = 10;
			
			icon = new Bitmap(UserInterface.textures.fantsIcon,"auto",true);
			icon.scaleX = icon.scaleY = 0.7;
				
			icon.x = open.x + open.width + 2;
			icon.y = 6;

			sprite.addChild(icon);
			
			var count:TextField = Window.drawText(String(item.unlock.price),settings);
			sprite.addChild(count);
			count.x = icon.x + icon.width + 2;
			count.y = 8;
			
			var needed:TextField = Window.drawText(Locale.__e("flash:1382952380085",[item.unlock.level]), {
				color:0xbf1a22,
				fontSize:16,
				borderColor:0xfcf5e5,
				textAlign:"center",
				borderSize:6
			});
			
			needed.width = 130;
			needed.height = needed.textHeight;
			sprite.addChild(needed);
			needed.x = 0;
			needed.y = -12;
			
			openBttn = new Button(bttnSettings);
			sprite.addChild(openBttn);
			openBttn.x = 16;
			openBttn.y = 35;
				
			sprite.y = 111;
			addChild(sprite);
					
			openBttn.addEventListener(MouseEvent.CLICK, onOpenEvent);
		}
		
		private function onOpenEvent(e:MouseEvent):void {
			
			openBttn.removeEventListener(MouseEvent.CLICK, onOpenEvent);
			
			if (App.user.stock.take(Stock.FANT, item.unlock.price)) {
				
				Hints.minus(Stock.FANT, item.unlock.price, Window.localToGlobal(e.currentTarget), false, window);
				
				App.user.shop[item.ID] = 1;
				//window.contentChange();
				
				Post.send( {
					ctr:'user',
					act:'open',
					uID:App.user.id,
					sID:item.sid
				}, function(error:*, data:*, params:*):void {
					if (!error) {
						App.user.shop[item.sid] = 1;
						window.contentChange();
					}
				})
			}
		}
		
		private function onBuyAction(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			priceBttn.state = Button.DISABLED;
			//for (var _mat:* in item.price)
			//{
			App.user.stock.buy(item.sID, 1, onBuyEvent);
			//}
		}
		
		private function onBuyEvent(/*MONEY:uint,*/ price:uint):void
		{
			if (priceBttn)
			{
				var point:Point = localToGlobal(new Point(priceBttn.x, priceBttn.y));
				point.x += priceBttn.width / 2;
			}
			//Hints.minus(moneyType,price, point);
			
			//window.addCloth(item.sid);
			window.contentChange();
		}
		
		private function glowing():void {
			if (!App.user.quests.tutorial) {
				customGlowing(background, glowing);
			}
			
			if (priceBttn) {
				if (App.user.quests.tutorial) {
					App.user.quests.currentTarget = priceBttn;
					
					priceBttn.showGlowing();
					priceBttn.showPointing("top", priceBttn.width/2 - 15, 0, priceBttn.parent);
				}else {
					customGlowing(priceBttn);
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
	


	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	internal class PriceLabel extends LayerX
	{
		public var icon:Bitmap;
		public var text:TextField;
		
		private var compare:Boolean = true; 
		private var withDifferent:Boolean = true; 
		private var sid:int = 0;
		private var price:int = 0;
		private var matType:String = '';
		
		public function PriceLabel(count:Number, moneyType:String, iconScale:Number = 0.8, params:Object = null) 
		{
			if (!params) params = { };
			compare = (params.hasOwnProperty('compare')) ? params.compare : true;
			withDifferent = (params.hasOwnProperty('withDifferent')) ? params.withDifferent : true;
			
			if(moneyType == "coins")		icon = new Bitmap(UserInterface.textures.goldenPearl, "auto", true);
			else if (moneyType == "real")	icon = new Bitmap(UserInterface.textures.blueCristal, "auto", true);
			else if (moneyType == "jems")	icon = new Bitmap(UserInterface.textures.gemsIcon, "auto", true);
			else if (moneyType == "ambers")	icon = new Bitmap(UserInterface.textures.ambersIcon, "auto", true);
			else if(moneyType == "energy")	icon = new Bitmap(UserInterface.textures.energyIcon, "auto", true);
			else if(moneyType == "exp")		icon = new Bitmap(UserInterface.textures.expIcon, "auto", true);
			else if(moneyType == "diamond" || moneyType == "tokens")		icon = new Bitmap(UserInterface.textures.diamond, "auto", true);
			else if (moneyType == "icecoins")	icon = new Bitmap(UserInterface.textures.icecoinsIcon, "auto", true);
			else if (moneyType == "shells")	icon = new Bitmap(UserInterface.textures.shellIcon, "auto", true);
			else if (moneyType == "kgold")	icon = new Bitmap(UserInterface.textures.kgoldIcon, "auto", true);
			else if (moneyType == "topcoins")	icon = new Bitmap(UserInterface.textures.topcoinsIcon, "auto", true);
			else if (moneyType == "free_item")	icon = new Bitmap(new BitmapData(30,30,true,0), "auto", true);
			else 								icon = new Bitmap(new BitmapData(1,1,true,0), "auto", true);
			
			matType = moneyType;
			
			addChild(icon);
			Size.size(icon, 30, 30);
			//icon.scaleX = icon.scaleY = iconScale;
			icon.smoothing = true;
			
			icon.x = 0;
			icon.y = 0;
			sid = params.sid;
			
			price = count;
			
			updatePrice();
			
			addChild(text);
			text.height = text.textHeight;
			
			text.x = icon.width + 5;
			text.y = icon.y + (icon.height - text.textHeight) / 2;
			
			if (moneyType == 'free_item' && sid)
			{
				loadIcon(sid);
				tip = function():Object
				{
					var info:Object = App.data.storage[sid];
					return { title:info.title, text:info.description };
				};
			}
		}
		
		public function updatePrice():void
		{
			var _price:String = String(price);
			
			var settings:Object = {
				fontSize:24,
				autoSize:"left",
				color:0xffdc39,
				borderColor:0x6d4b15
			}
			
			var onStock:int;
			switch(matType)
			{
				case"real":
					settings["color"]	 	= 0xfedb38;
					settings["borderColor"] = 0x6c4b15;
					break;
				case"diamond":
					settings["color"]	 	= 0xb0ffff;
					settings["borderColor"] = 0x112f5f;
					break;
				default:
					settings["color"]	 	= 0xffdc39;
					settings["borderColor"] = 0x6d4b15;
			}
			if (matType == 'free_item' && !App.user.stock.check(sid, price))
				settings["color"] = 0xffffff;
			//if (moneyType == "real"){
				//settings["color"]	 	= 0xfedb38;
				//settings["borderColor"] = 0x6c4b15;
			//}else if (moneyType == "diamond") {
				//settings["color"]	 	= 0xb0ffff;
				//settings["borderColor"] = 0x112f5f;
			//}else if (moneyType == 'jems') {
				//onStock = App.user.stock.count(Stock.GEMS);
				//if (compare)
					//_price = Locale.__e('flash:1382952380278', [onStock, price]);
				//
				//if (withDifferent && price > onStock) {
					//settings['color'] = 0xee9177;
					//settings['borderColor'] = 0x8c2a24;
				//}
			//}else if (moneyType == 'ambers') {
				//onStock = App.user.stock.count(Stock.AMBER);
				//if (compare)
					//_price = Locale.__e('flash:1382952380278', [onStock, price]);
				//
				//if (withDifferent && price > onStock) {
					//settings['color'] = 0xee9177;
					//settings['borderColor'] = 0x8c2a24;
				//}
			//}else if (moneyType == 'icecoins') {
				//onStock = App.user.stock.count(Stock.ICECOINS);
				//if (compare)
					//_price = Locale.__e('flash:1382952380278', [onStock, price]);
				//
				//if (withDifferent && price > onStock) {
					//settings['color'] = 0xee9177;
					//settings['borderColor'] = 0x8c2a24;
				//}else {
					//settings['color'] = 0xb0ffff;
					//settings['borderColor'] = 0x112f5f;
				//}
			//}else if (moneyType == 'shells') {
				//onStock = App.user.stock.count(Stock.SHELLS);
				//if (compare)
					//_price = Locale.__e('flash:1382952380278', [onStock, price]);
				//
				//if (withDifferent && price > onStock) {
					//settings['color'] = 0xee9177;
					//settings['borderColor'] = 0x8c2a24;
				//}else {
					//settings['color'] = 0xb0ffff;
					//settings['borderColor'] = 0x112f5f;
				//}
			//}else if (moneyType == 'free_item') {
				//onStock = App.user.stock.count(sid);
				//if (compare)
					//_price = Locale.__e('flash:1382952380278', [onStock, price]);
				//
				//if (withDifferent && price > onStock) {
					//settings['color'] = 0xee9177;
					//settings['borderColor'] = 0x8c2a24;
				//}else {
					//settings['color'] = color;
					//settings['borderColor'] = borderColor;
				//}
			//}
			
			text = Window.drawText(_price, settings);
			
		}
		
		private function get color():uint
		{
			switch(sid) {
				//case Stock.GAVAY_COINS:	return 0xe7e8e3;
			}
			
			return 0xffdc39;
		}
		
		private function get borderColor():uint
		{
			switch(sid) {
				//case Stock.GAVAY_COINS:	return 0x5b5f58;	
			}
			
			return 0x6d4b15;
		}
		
		private function loadIcon(sid:*):void {
			if (!App.data.storage[sid]) return;
			Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), function(data:Bitmap):void {
				icon.bitmapData = data.bitmapData;
				Size.size(icon, 30, 30);
				icon.smoothing = true;
				
				icon.x = 0;
				icon.y = 15 - icon.height/2;
				
				text.x = icon.width + 5;
				text.y = icon.y + (icon.height - text.textHeight) / 2;
				//icon.width = 25;
				//icon.scaleY = icon.scaleX;
			});
		}
		
	}

