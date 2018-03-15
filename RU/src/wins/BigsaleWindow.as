package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;

	public class BigsaleWindow extends Window
	{
		private var items:Array = new Array();
		public var action:Object;
		private var container:Sprite;
		private var priceBttn:Button;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		private var descriptionLucky:TextField;
		private var openBagBttn:Button;
		private var background:Bitmap;
		private var background2:Bitmap;
		public var backDesc:Shape = new Shape();
		//public var closeBttn:Button;	
		
		public static function startAction(sID:int, sale:Object):void {
			Load.loading(Config.getQuestIcon('preview', App.data.personages[sale.image].preview), function(data:*):void { 
				if (App.user.quests.chapters.indexOf(2) != -1) {
					new BigsaleWindow( { sID:sID } ).show();
				}
			});
		}
		
		public function BigsaleWindow(settings:Object = null)
		{
			
			if (settings == null) {
				settings = new Object();
			}
			
			action = App.data.bigsale[settings['sID']];
			action.id = settings['sID'];
			
			settings['width'] = 570;
			settings['height'] = 490;
			settings['title'] = action.title;
			settings['hasTitle'] = false;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasExit'] = true;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] = 0x116011;
			settings['shadowBorderColor'] = 0x116011;
			settings['fontSize'] = 32;
			settings['itemsOnPage'] = 3;
			settings['exitTexture'] = 'closeBttnMetal';
			
			settings.content = initContent(action.items);
						
			super(settings);
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var id:* in data)
				result.push({id:id, sID:data[id].sID, count:data[id].c, order:data[id].o, price_new:data[id].pn, price_old:data[id].po});
			
			result.sortOn('order', Array.NUMERIC);
			return result;
		}
		
		/*protected function drawRibbon():void 
		{
			var titleBackingBmap:Bitmap = backingShort(settings.titleWidth + 180, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -30;
			//titleBackingBmap.filters = [new GlowFilter(0xf3ff2c, .7, 11, 11, 3)];
			bodyContainer.addChild(titleBackingBmap);
			
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y + 7;
			
			bodyContainer.addChild(titleLabel);
		}*/
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: 40,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,
				borderSize 			: 3,
				shadowSize 			: 2,
				shadowColor			: settings.fontBorderColor,
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			drawRibbon();
			titleLabel.y += 43;
			titleBackingBmap.y += 32;
			
		}
		
		private var axeX:int
		override public function drawBody():void {	
			
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
			
			var fish1:Bitmap = new Bitmap(Window.textures.decFish1);
			fish1.smoothing = true;
			fish1.x = settings.width - 60;
			fish1.y = settings.height - 200;
			bodyContainer.addChild(fish1);
			
			drawMirrowObjs('decSeaweed', settings.width + 57, - 57, settings.height - 150 - 28, true, true, false, 1, 1, layer);
			drawTitle();
			container = new Sprite();
			
			backDesc.graphics.beginFill(0xfdedd7, 1);
			backDesc.graphics.drawRect(0, 0, settings.width - 140, 225);
			backDesc.graphics.endFill();
			backDesc.x = (settings.width - backDesc.width) / 2;;
			backDesc.y = settings.height - backDesc.height - 100;
			backDesc.filters = [new BlurFilter(30, 0, 2)];
			bodyContainer.addChild(backDesc); 
			/*
			var dev1:Bitmap = Window.backingShort(settings.width - 110, "dividerTop", false);
			dev1.x = (settings.width - dev1.width) / 2;
			dev1.y = backDesc.y - dev1.height;
			bodyContainer.addChild(dev1);
			
			var dev2:Bitmap = Window.backingShort(settings.width - 110, "dividerTop", false);
			dev2.x = (settings.width - dev2.width) / 2;
			dev2.y = backDesc.y + backDesc.height;
			bodyContainer.addChild(dev2);
			*/
			bodyContainer.addChild(container);
			container.x = 65;
			container.y = 210;
			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
	
			contentChange();
			drawMessage();
			App.self.setOnTimer(updateDuration);
			
			exit.parent.removeChild(exit);
			bodyContainer.addChild(exit);
			exit.x += 5;
			exit.y -= 32;
			
			descriptionLucky = Window.drawText(Locale.__e('flash:1450886877237'), {
				width		:300,
				fontSize	:22,
				textAlign	:"center",
				autoSize	:"center",
				color		:0xffffff,
				borderColor	:0x844e28,
				multiline	:true,
				wrap		:true
			});

			descriptionLucky.x = settings.width / 2 + backgroundContainer.x - descriptionLucky.width / 2 + 130;
			descriptionLucky.y = 68;
			
			openBagBttn = new Button( {
				width:200,
				height:55,
				fontSize:32,
				caption:Locale.__e("flash:1450889118031")
			});
	
			openBagBttn.x = settings.width - openBagBttn.width - 90;
			openBagBttn.y = 150;
			openBagBttn.addEventListener(MouseEvent.CLICK, onOpenBag);
		}

		private function onOpenBag (e:Event = null):void 
		{
			new LuckybagContentWindow({ 
				popup: true,
				targetSID: 1937				
			}).show();
		}	
		
		override public function close(e:MouseEvent=null):void {
			super.close();
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = settings.height / 2 - paginator.arrowLeft.height + 30;
			paginator.arrowLeft.x = 55;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width + 10;
			paginator.arrowRight.y = y;
		}
		
		public override function contentChange():void 
		{
			for each(var _item:BigsaleItem in items)
			{
				container.removeChild(_item);
				_item = null;
			}
			
			items = [];
			
			var Xs:int = -26;
			var Ys:int = 10;
			var X:int = 0;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:BigsaleItem = new BigsaleItem(settings.content[i], this);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width + 8;
				
				itemNum++;
			}
		}
		
		override public function drawBackground():void {
			background = backing(settings.width, settings.height, 50, "capsuleWindowBacking");
			layer.addChild(background);	
			background2 = Window.backing(settings.width - 66, settings.height - 66, 40, 'paperClear');//фоны самих квестов
			background2.x = (background.width - background2.width) / 2;
			background2.y = (background.height - background2.height) / 2;
			layer.addChild(background2);
		}
	
		private function drawMessage():void {
			
			var sprite:Sprite = new Sprite();
			var title:TextField;
			var titleShadow:TextField;		
			drawTime();
			bodyContainer.addChild(timeConteiner);
			timeConteiner.x = 0;
			timeConteiner.y = 0;
			bodyContainer.addChild(sprite);	
			
			
		}
		
		private var timeConteiner:Sprite
		private var descBG:Shape = new Shape();
		public function drawTime():void {
			timeConteiner = new Sprite();
			
			descBG.graphics.beginFill(0xfded74, 1);
			descBG.graphics.drawRect(0, 0, settings.width - 220, 65);
			descBG.graphics.endFill();
			descBG.x = (settings.width - descBG.width) / 2;;
			descBG.y = 75;
			descBG.filters = [new BlurFilter(30, 0, 2)];
			timeConteiner.addChild(descBG);	

			descriptionLabel = drawText(Locale.__e('flash:1382952379969'), {
				fontSize: 30,
				textAlign:"center",
				color:0xffffff,
				borderColor:0x6e411e
			});
			descriptionLabel.width = 260;
			descriptionLabel.x = descBG.x + (descBG.width - descriptionLabel.width) / 2;	
			descriptionLabel.y = descBG.y + (descBG.height - descriptionLabel.height) / 2 - 11;	
			
			var time:int = action.duration * 60 * 60 - (App.time - action.time);
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xf8d74c,
				letterSpacing:3,
				textAlign:"center",
				fontSize:30,
				borderColor:0x502f06
			});
			timerText.width = 230;
			timerText.y = descriptionLabel.y + descriptionLabel.height / 2 + 10;
			timerText.x = descBG.x + (descBG.width - timerText.width) / 2				
			
			timeConteiner.addChild(descriptionLabel);
			timeConteiner.addChild(timerText);	
		
		
		}
		
		private function updateDuration():void {
			var time:int = action.duration * 60 * 60 - (App.time - action.time);
			timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) 
			{
				App.self.setOffTimer(updateDuration);
				//App.ui.leftPanel.createPromoPanel();
				App.ui.salesPanel.createPromoPanel();
				close();
			}
		}
		
		public override function dispose():void
		{
			for each(var _item:BigsaleItem in items)
			{
				_item = null;
			}
			
			App.self.setOffTimer(updateDuration);
			super.dispose();
		}
	}
}

import api.ExternalApi;
import buttons.Button;
import core.Load;
import core.Post;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.geom.Point;
import flash.text.TextField;
import ui.Cursor;
import ui.UserInterface;
import units.Field;
import units.*;
import utils.ActionsHelper;
import wins.elements.PriceLabel;
import wins.Window;
import wins.SimpleWindow;

internal class BigsaleItem extends LayerX {
		
		public var count:uint;
		public var sID:uint;
		public var background:Shape = new Shape();
		public var bitmap:Bitmap;
		public var title:TextField;
		public var window:*;
		public var item:Object;
		public var price_new:Number;
		public var price_old:Number;
		public var priceLabel1:TextField;
		public var priceLabel2:TextField;
		public var diamond:Bitmap;
		public var diamond2:Bitmap;
		private var preloader:Preloader = new Preloader();
		private var efirTitle:TextField = new TextField();
		private var efirCount:TextField = new TextField();
		private var presentIcon:Bitmap = new Bitmap();
		private var tipsID:uint;
		private var sprite:LayerX = new LayerX();
		
		public function BigsaleItem(item:Object, window:*) {
			
			sID = item.sID;
			count = item.count;
			price_new = item.price_new;
			price_old = item.price_old;
			this.item = item;
			this.window = window;

			background.graphics.beginFill(0xf9d2ac);
			background.graphics.drawCircle(0, 0, 70);
			background.graphics.endFill();
			background.x += 100;
			background.y += 33;
			sprite.addChild(background);			
			addChild(sprite);

			bitmap = new Bitmap();
			sprite.addChild(bitmap);		
			drawBttn();
			drawCount();
			addChild(preloader);
			preloader.x = background.width/2;
			preloader.y = (background.height) / 2 - 35;
			
			/*switch (sID) 
			{
				case Stock.FANT:
					switch (item.order) 
					{
					case 1:
					tipsID = 190;	
					break;
					case 2:
					tipsID = 192;		
					break;
					case 3:
					tipsID = 194;
					break;
					}
				break;
				case Stock.COINS:
					switch (item.order) 
					{
					case 1:
					tipsID = 185;		
					break;
					case 2:
					tipsID = 186;		
					break;
					case 3:
					tipsID = 187;
					break;
					}
				break;
				case Stock.COOKIE:
					switch (item.order) 
					{
					case 1:
				//	sID = 185;		
					break;
					case 2:
				//	sID = 186;		
					break;
					case 3:
					//sID = 187;
					break;
					}
				break;
				case Stock.FANTASY:
					switch (item.order) 
					{
					case 1:
					tipsID = 195;		
					break;
					case 2:
					tipsID = 196;		
					break;
					case 3:
					tipsID = 197;
					break;
					}
				break;
				case Stock.GUESTFANTASY:
					switch (item.order) 
					{
					case 1:
					tipsID = 403;		
					break;
					case 2:
					tipsID = 402;		
					break;
					case 3:
					tipsID = 401;
					break;
					}
				break;
			default:
				switch (item.order) 
					{
					case 1:
					tipsID = sID;		
					break;
					case 2:
					tipsID = sID;		
					break;
					case 3:
					tipsID = sID;
					break;
					}
			}*/
			
			//Load.loading(Config.getIcon(App.data.storage[tipsID].type, App.data.storage[tipsID].preview), onPreviewComplete);
			//if (sID != 150){
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
			//} else {
				//Load.loading(Config.getIcon('Energy', 'cookie3'), onPreviewComplete);
			//}			
			
			if(App.data.storage[sID].type == 'Golden'){
				var label:Bitmap = new Bitmap(Window.textures.goldLabel);
			//	addChild(label);
				label.smoothing = true;
				label.x = -11;
				label.y = 20;
			}
			
			sprite.tip = _tip;				
		}
		
		private function _tip():Object {
			return {
					title:App.data.storage[sID].title,
					text:App.data.storage[sID].description
				}
		}
		
		public var countLabel:TextField;
		public var titleItem:TextField;
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.scaleX = bitmap.scaleY = 2;
			bitmap.smoothing = true;
			Size.size(bitmap, 70, 70);
			bitmap.x = background.x - background.width/2 + (background.width - bitmap.width)/ 2;
			bitmap.y = background.y - background.height/2 + (background.height - bitmap.height)/ 2;

			titleItem = Window.drawText(String(App.data.storage[item.sID].title), {
				color		:0xffffff,
				autoSize	:'left',
				borderColor	:0x6e411e,
				fontSize	:28,
				width		:150
			});
			sprite.addChild(titleItem);
			titleItem.x = background.x - titleItem.textWidth / 2;
			titleItem.y = background.y - background.height / 2 - titleItem.textHeight / 2;
			
			countLabel = Window.drawText('+'+String(count), {
				color:0xffda47,
				autoSize:'left',
				borderColor:0x6e411e,
				fontSize:30
			});
			countLabel.border = false;
			countLabel.wordWrap = true;
			
			countLabel.y = background.y + background.height / 2 - countLabel.textHeight / 2 - 8;
			countLabel.x = background.x - countLabel.textWidth / 2;
			if (sID != 1936 && sID != 1937 && sID != 1938) 
			{
				addChild(countLabel);	
			}	
			
			
			
			//count
		/*	efirCount = Window.drawText(('x' + App.data.storage[sID].count), {
				multiline:true,
				color:0xffffff,
				borderColor:0x7f4a28,
				autoSize:"left",
				textAlign:"left",
				fontSize:36
			});
			
			if (sID == 1936 || sID == 1937 || sID == 1938) 
			{
				addChild(efirCount);
			}
			
			efirCount.x = (background.width - efirCount.width) / 2 + 55;
			efirCount.y = 160;
			*/
			//иконка подарочка
			/*presentIcon = new Bitmap(UserInterface.textures.crab);	
			if (sID == 1936 || sID == 1937 || sID == 1938) 
			{
				addChild(presentIcon);
			}*/
			
			presentIcon.x = efirCount.x - 45;
			presentIcon.y = efirCount.y;
		}
		
		public var priceBttn:Button
		public function drawBttn():void {
			
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379751"),
				fontSize:26,
				fontBorderColor: 0x6e411e,
				width:130,
				height:44
			};
			
			priceBttn = new Button(bttnSettings);
			addChild(priceBttn);
			priceBttn.x = background.x - priceBttn.width / 2;
			priceBttn.y = background.height + 40;
			priceBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);			
		}
		
		private function onBuyEvent(e:MouseEvent):void{
			if (e.currentTarget.mode == Button.DISABLED) return;				
				
			var object:Object;
			switch(App.social) {
				case 'SP':
					if(App.user.stock.take(Stock.FANT, price_new)){
						Post.send({
							ctr:'Stock',
							act:'bigsale',
							uID:App.user.id,
							sID:window.action.id,
							pos:item.id
						},function(error:*, data:*, params:*):void {
							if (!error)
								onBuyComplete();
						});
					}else {
						window.close();
					}
				break;
				case 'PL':
					if (item.sID != Stock.FANT && item.sID != Stock.COINS)
					{
					if(App.user.stock.take(Stock.FANT, price_new)){
						Post.send({
							ctr:'Stock',
							act:'bigsale',
							uID:App.user.id,
							sID:window.action.id,
							pos:item.id
						},function(error:*, data:*, params:*):void {
							if(!error){
								App.user.stock.add(item.sID,count, true);
								onBuyComplete();
							}
						});
					}else {
						window.close();
					}
					return;
					}
				case 'FB':
					object = {
						id:		 		window.action.id+'#'+item.id,
						type:			'bigsale',
						callback:		onBuyComplete
					};
					break;
				default:
					object = {
						count:			count,
						money:			'bigsale',
						type:			'item',
						item:			'bigsale_'+window.action.id+'_'+item.id,
						votes:			price_new,
						title: 			Locale.__e('flash:1382952379996'),
						description: 	Locale.__e('flash:1382952379997'),
						callback: 		onBuyComplete
					}
					break;
			}
			ExternalApi.apiBalanceEvent(object);
		}
		
		private function onBuyComplete(e:* = null):void 
		{
			priceBttn.state = Button.DISABLED;
			if(sID != Stock.FANT){
				App.user.stock.add(sID, count, true);
			}
			
			
			var bonus:BonusItem = new BonusItem(sID, count);
			var point:Point = Window.localToGlobal(this);
			bonus.cashMove(point, App.self.windowContainer);
			
			window.close();
			
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				title:Locale.__e("flash:1382952379735"),
				text:Locale.__e("flash:1382952379990")
			}).show();
		}
		
		
		
		
		public function drawCount():void {
			var text:String;
			var textSettings:Object = { };
			
			var settings:Object = {
				fontSize:22,
				autoSize:"left",
				color:0xffffff,
				borderColor:0x6e401f
			}
			
			var delta:int = 0;
			switch(App.social) {
				case "PL":
				case "YB":
				case "MX":
				//case "AI":
					delta = 32;
					break;
				default: 
					delta = 0;
					break;
			}
			
			var priceLabel2:TextField = Window.drawText(Locale.__e(ActionsHelper.priceLable(price_new).text, ActionsHelper.priceLable(price_new).price), settings);
			
			var totalLabel:TextField = Window.drawText(Locale.__e('flash:1382952379998'), {
				fontSize:22,
				textAlign:"left",
				color:0xf0e6c1,
				borderColor:0x502f06
			});
			totalLabel.width = totalLabel.textWidth + 5;
			totalLabel.x = (background.width - totalLabel.width - priceLabel2.width - delta) / 2;
			totalLabel.y = 144;
			//addChild(totalLabel);
			totalLabel.height = totalLabel.textHeight;
			
			
			priceLabel2.x = totalLabel.x + totalLabel.width + 2;			
			priceLabel2.y = 144;
			
		//	addChild(priceLabel2);
			priceBttn.caption = Locale.__e(ActionsHelper.priceLable(price_new).text, ActionsHelper.priceLable(price_new).price);
			
			priceBttn.fitTextInWidth(priceBttn.width - 40);
			
			if(App.isSocial('MX')){
				var mixiLogo:Bitmap =  new Bitmap(Window.textures.mixieLogo);
				priceBttn.topLayer.addChild(mixiLogo);
				mixiLogo.y = (priceBttn.height - mixiLogo.height) / 2;
				mixiLogo.x = ((priceBttn.width - (mixiLogo.width + 5 + priceBttn.textLabel.textWidth)) / 2) - 5;
				priceBttn.textLabel.x = mixiLogo.x + mixiLogo.width;
			}	
			
			if (App.isSocial('MM')) {
				priceBttn.textLabel.x += 20;
			}
			
			if (App.isSocial('AI')) {
				priceBttn.textLabel.x += 15;
			}
			
			if (App.isSocial('SP')) 
			{				
				diamond = new Bitmap();
				priceBttn.topLayer.addChild(diamond);
				Load.loading(
					Config.getIcon(App.data.storage[27].type, App.data.storage[27].preview),
					function(data:Bitmap):void{
						diamond.bitmapData = data.bitmapData;
						diamond.scaleX = diamond.scaleY = 0.45;
						diamond.smoothing = true;
						diamond.x = ((priceBttn.width - (diamond.width + 5 + priceBttn.textLabel.textWidth)) / 2) - 5;
						diamond.y = (priceBttn.height - diamond.height) / 2;
						priceBttn.textLabel.x = diamond.x + diamond.width;
					}
				);
			}

			var priceLabel1:TextField = Window.drawText(Locale.__e(ActionsHelper.priceLable(price_old).text, ActionsHelper.priceLable(price_old).price), {
				fontSize	:26,
				autoSize	:'left',
				textAlign	:"center",
				color		:0x7e3e13,
				border		:false
			});

			priceLabel1.x = background.x - priceLabel1.textWidth / 2;
			priceLabel1.y = background.y + background.height/2 + 15;
			sprite.addChild(priceLabel1);
			
			var redLine:Bitmap = new Bitmap(Window.textures.redLines);
			redLine.scaleX = redLine.scaleY = 2;
			Size.size(redLine, priceLabel1.textWidth + 5, priceLabel1.height + 20);
			redLine.smoothing = true;
			redLine.x = priceLabel1.x + 5;
			redLine.y = priceLabel1.y + priceLabel1.textHeight - redLine.height + 5;
			sprite.addChild(redLine);
			
			
			priceLabel1.alpha = 0.9;
			
			if(App.isSocial('MX')){
				var mixiLogo1:Bitmap =  new Bitmap(Window.textures.mixieLogo);
				addChild(mixiLogo1);
				priceLabel1.x += 15;
				mixiLogo1.y = 165;
				mixiLogo1.x += 30;
				mixiLogo1.scaleX = mixiLogo1.scaleX / 2;
				mixiLogo1.scaleY = mixiLogo1.scaleY / 2;
			}
			
			if (App.isSocial('SP')) 
			{				
				diamond2 = new Bitmap();
				addChild(diamond2);
				Load.loading(
					Config.getIcon(App.data.storage[27].type, App.data.storage[27].preview),
					function(data:Bitmap):void{
						diamond2.bitmapData = data.bitmapData;
						diamond2.scaleX = diamond2.scaleY = 0.3;
						diamond2.smoothing = true;
						diamond2.x += 60;
						diamond2.y = 165;
						priceLabel1.x += 15;
					}
				);
			}
		}
}
