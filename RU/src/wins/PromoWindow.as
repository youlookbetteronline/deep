package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Techno;
	import units.Unit;
	import units.WorkerUnit;
	import 	flash.geom.ColorTransform;
	import utils.ActionsHelper;
	import wins.elements.DiscountAction;

	public class PromoWindow extends AddWindow
	{
		private var items:Array = new Array();
		//public var action:Object;
		private var container:Sprite;
		private var priceBttn:Button;
		private var materialBttn:MoneyButton;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		private var background:Bitmap;
		private var backgroundDesc:Shape = new Shape();
		
		
		public function PromoWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 728;
			settings['height'] = 450;
						
			settings['title'] = Locale.__e("flash:1382952379793");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['exitTexture'] = 'closeBttnMetal';
			settings['fontColor'] = '0xf3ff2c';
			settings['fontSize'] = 42;
			settings['fontBorderColor'] = 0xb05b15;
			settings['fontBorderSize'] = 2;
			settings['wName'] = 'PromoWindow';
			
			super(settings);
		}
		
		
		override public function drawExit():void {}
		override public function drawBackground():void {}
		
		override public function show():void 
		{
			super.show();
			if (settings.additional && settings.action.viewed == 0)
			{
				ActionsHelper.viewUserAction(settings.action.id);
				settings.action.viewed = 1;
			}
		}
		
		public function changePromo(pID:String):void {
			
			App.self.setOffTimer(updateDuration);
			
			settings.content = initContent(action.items);
			settings.bonus = initContent(action.bonus);
			
			var numItems:int = settings.content.length + (settings.bonus.length - 1);
			
			if (numItems < 4) {
				
				settings.width = numItems * 200 + 300;
				if (settings.content.length == 3) settings.width = numItems * 200 + 180;
			}
			if (numItems == 4) settings.width = 780;
			var fish1:Bitmap = new Bitmap(Window.textures.decFish1);
			fish1.smoothing = true;
			fish1.x -= fish1.width;
			fish1.y = settings.height - fish1.height - 30;
			//layer.addChild(fish1);
			
			var fish2:Bitmap = new Bitmap(Window.textures.decFish2);
			fish2.scaleX = fish2.scaleY = 1.2;
			fish2.smoothing = true;
			fish2.x = settings.width - fish2.width/2;
			fish2.y = settings.height - fish2.height*2 - 80;
			layer.addChild(fish2);
			
			var background:Bitmap = backing(settings.width, settings.height, 50, 'capsuleWindowBacking');
			layer.addChild(background);
			
			var star1:Bitmap = new Bitmap(Window.textures.decStarRed);
			star1.x = - 5;
			star1.y = -9;
			star1.smoothing = true;
			//layer.addChild(star1);
			
			exit = new ImageButton(textures[this.settings.exitTexture]);
			headerContainer.addChild(exit);
			exit.x = settings.width - 50;
			exit.y -= 0;
			exit.x -= 0;
			
			this.y -= 30;
			fader.y += 30;
			exit.addEventListener(MouseEvent.CLICK, close);
			
			var text:String = Locale.__e("flash:1382952380239");
			_descriptionLabel = drawText(text, {
				fontSize:30,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x7b270e
			});
			
			drawRibbon();
			titleBackingBmap.y -= 9;
			
			backgroundDesc.graphics.beginFill(0xf5da65, 1);
		    backgroundDesc.graphics.drawRect(0, 0, settings.width - 100, 38);
		    backgroundDesc.graphics.endFill();
		    backgroundDesc.x = (settings.width - backgroundDesc.width) / 2;
		    backgroundDesc.y = 20;
		    backgroundDesc.filters = [new BlurFilter(20, 0, 2)];
		    bodyContainer.addChild(backgroundDesc);
			
			_descriptionLabel.y = backgroundDesc.y + (backgroundDesc.height - _descriptionLabel.textHeight) / 2 - 1;
			bodyContainer.addChild(_descriptionLabel);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 120;
			
			
			settings['L'] = settings.content.length + settings.bonus.length;
			if (settings['L'] < 2) settings['L'] = 2;
			
			drawImage();	
			contentChange();
			if(action.price)
				drawPrice();
			if (action.mprice)
				drawMaterialPrice();
			drawTime();
			updateDuration();
			App.self.setOnTimer(updateDuration);
			
			if(fader != null)
				onRefreshPosition();
				
			_descriptionLabel.x = settings.width / 2 - _descriptionLabel.width / 2;
			exit.y -= 10;
			
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
			
			drawMirrowObjs('decSeaweed', settings.width + 56, - 56, settings.height - 221, true, true, false, 1, 1, bodyContainer);
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
			var octopusBack:Bitmap = new Bitmap(Window.textures.levelUpBackingOctopusFish);
			layer.addChildAt(octopusBack, 0);
			octopusBack.x = - 50;
			octopusBack.y = -octopusBack.height / 2 - 21;
			
			var tentacle1:Bitmap = new Bitmap(Window.textures.tentacle3);
			bodyContainer.addChild(tentacle1);
			tentacle1.x = -42;
			tentacle1.y = -15;
			
			var tentacle2:Bitmap = new Bitmap(Window.textures.tentacle4);
			bodyContainer.addChild(tentacle2);
			tentacle2.x = -41;
			tentacle2.y = 110;
			
			changePromo(action.id);
			
			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
				
			_descriptionLabel.x = settings.width / 2 - _descriptionLabel.width / 2;
			
			if (!settings.hasOwnProperty('additional') && App.data.actions[settings.pID].profit != '' && int(App.data.actions[settings.pID].profit) > 0) 
			{
				var profLabel:DiscountAction = new DiscountAction( { profit: int(App.data.actions[settings.pID].profit) } );
				profLabel.x = 110;
				profLabel.y = 320;
				if (settings.width <= 600){
					profLabel.x = 10;
					profLabel.y = 340;
				}
				profLabel.rotation = -30;
				bodyContainer.addChild(profLabel);
			}
			
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
			//return
			menuSprite = new Sprite();
			var X:int = 10;
						
			if (App.data.promo == null) return;
			
			for (var pID:* in App.user.promo)
			{
				var promo:Object;
				if (promo.hasOwnProperty('additional'))
					promo = App.user.promo[pID];
				else
					promo = App.data.promo[pID];	
				
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
		}
		
		private var glowing:Bitmap;
		private var stars:Bitmap;
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
			
		}
		
		override public function onBuyComplete(data:* = null):void {
			super.onBuyComplete(data);
			
			for each(var item:ActionItem in items) 
			{
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
			var Ys:int = -50;
			var X:int = 0;
			
			var itemNum:int = 0;
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var item:ActionItem = new ActionItem(settings.content[i], this);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width + 12;
			}
			
			var plus:Bitmap = new Bitmap(Window.textures.pluss);
			plus.x = Xs + 5;
			plus.y = 35;
			plus.filters = [new GlowFilter(0xffffff, 1, 5, 5, 3, 1)];
			Xs += 20;
			
			for (i = 0; i < settings.bonus.length; i++)
			{
				item = new ActionItem(settings.bonus[i], this, true);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width;
			}
			container.addChild(plus);
			
			container.y -= 4;
			container.x = (settings.width - 150 * (settings.content.length + settings.bonus.length)) / 2 - 50;
		}
		
		private var timerContainer:Sprite;
		public function drawTime():void {
			
			if (timerContainer != null)
				bodyContainer.removeChild(timerContainer);
				
			timerContainer = new Sprite()
			
			var background:Bitmap = Window.backingShort(200, 'bubbleTimerBack');// Window.backing(200, 65, 20, "buildinSmallDarkgBacking");
			timerContainer.addChild(background);
			background.x =  - background.width/2;
			
			
			var colorTransform:ColorTransform = new ColorTransform(0.5, 0.5, 0.5);
			
			
			descriptionLabel = drawText(Locale.__e('flash:1393581955601'), {
				fontSize:30,
				textAlign:"left",
				color:0xffffff,
				borderColor:0x5a2910
			});
			descriptionLabel.x =  background.x + (background.width - descriptionLabel.textWidth) / 2;
			descriptionLabel.y = background.y - descriptionLabel.textHeight - 5;
			timerContainer.addChild(descriptionLabel);
			
			var time:int;
			
			if (action.hasOwnProperty('additional'))
				time = action.duration * 60 * 60 - (App.time - action.time);
			else
				time = action.duration * 60 * 60 - (App.time - App.user.promo[action.id].started);
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xf8d74c,
				letterSpacing:3,
				textAlign:"center",
				fontSize:34,//30,
				borderColor:0x502f06
			});
			timerText.width = 200;
			timerText.y = background.y + (background.height - timerText.textHeight) / 2;
			timerText.x = background.x;
			
			timerContainer.addChild(timerText);
			timerContainer.y = settings.height - timerContainer.height - 39;
			bodyContainer.addChild(timerContainer);
			timerContainer.x = settings.width/2;
		}
		
		private var cont:Sprite;
		public function drawPrice():void {
			
			var bttnSettings:Object = {
				fontSize:32,
				width:186,
				height:52 + 10*int(App.isSocial('MX'))
				//hasDotes:true
			};
			if (App.isJapan())
				bttnSettings.fontSize = 20;
			var price:Number = action.price[App.social];
			var priceLable:Object = ActionsHelper.priceLable(price);
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
				
			bttnSettings['caption'] = Locale.__e(priceLable.text,[priceLable.price])
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			
			priceBttn.x = settings.width/2 - priceBttn.width / 2;
			priceBttn.y = settings.height - priceBttn.height / 2 - 50;//135;
			
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
		
		public function drawMaterialPrice():void 
		{
			var bttnSettings:Object = {
				caption			:Locale.__e("flash:1382952379751"),
				countText		:String(Numbers.firstProp(action.mprice[App.social]).val),
				iconScale		:.7,
				fontCountSize	:32,
				fontSize		:30,
				width			:186,
				height			:52
			};
			
			if (materialBttn != null)
				bodyContainer.removeChild(materialBttn);
			materialBttn = new MoneyButton(bttnSettings)
			bodyContainer.addChild(materialBttn);
			
			materialBttn.x = (settings.width - materialBttn.width) / 2;
			materialBttn.y = settings.height - materialBttn.height / 2 - 50;
			
			materialBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		}
		
		private function onTechnoComplete(sID:uint, rez:Object = null):void 
		{
			if (App.data.storage[App.user.worldID].techno[0] == sID) {
				addChildrens(sID, rez.ids);
			}
		}
		
		private function addChildrens(_sid:uint, ids:Object):void 
		{
			var position:Object = App.map.heroPosition;
			for (var i:* in ids){
				var unit:Unit = Unit.add( { sid:_sid, id:ids[i], x:position.x, z:position.z} );
					(unit as WorkerUnit).born({capacity:1});
			}
		}
		
		private function updateDuration():void
		{
			var time:int;
			if (action.hasOwnProperty('additional'))
				time = action.duration * 60 * 60 - (App.time - action.time);
			else
				time = action.duration * 3600 - (App.time - App.data.actions[action.id].begin_time);
				
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
			
			background = Window.backing(150, 190, 10, 'levelUpItemBacking');
			if (bonus)
			{
				background = new Bitmap(Window.textures.presentBacking);
				background.y = 0;
			}
			
		
			
			addChild(background);
			
			
			
			sprite = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			
			drawTitle();
			drawCount();
			
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
			Size.size(bitmap, 124, 124);
		
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width)/ 2;
			bitmap.y = (background.height - bitmap.height) / 2;
			
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
			}
		}
		
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
		}
		
		public function drawCount():void {
			var countText:TextField = Window.drawText('x' + String(count), {
				color:0xffda47,
				borderColor:0x7b270e,
				textAlign:"center",
				autoSize:"center",
				fontSize:32,
				textLeading:-6,
				multiline:true
			});
			countText.wordWrap = true;
			//countText.width = background.width - 10;
			countText.y = background.height - 40;
			countText.x = background.x + (background.width - countText.width) / 2;
			addChild(countText);
				if (sID == Stock.FANTASY) 
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
			}
		
		}
}
