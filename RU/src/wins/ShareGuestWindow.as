package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;

	public class ShareGuestWindow extends Window
	{
		private var items:Array = new Array();
		public var info:Object;
		public var back:Bitmap;
		
		public function ShareGuestWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			info = settings.target.info;			
			
			settings['itemsNum'] = settings.itemsNum;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] = 0x116011;
			settings['shadowBorderColor'] = 0x116011;
			settings['fontSize'] = 32;
			settings['fontBorderSize'] = 4;	
			/*settings['fontColor'] = 0xffcc00;
			settings['fontSize'] = 36;
			settings['fontBorderColor'] = 0x705535;
			settings['shadowBorderColor'] = 0x342411;
			settings['fontBorderSize'] = 4;*/
			settings['description'] = getTextFormInfo('text6');
			settings['width'] = (settings.itemsNum == 2) ? 460 : 713;
			settings['height'] = 405;
			settings['title'] = info.title;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 10;
			
			settings['content'] = [];
			for (var sID:* in info.kicks) {
				var obj:Object = { sID:sID, count:info.kicks[sID].c };
				if (info.kicks[sID].hasOwnProperty('t')) {
					obj['t'] = info.kicks[sID].t;
				}
				settings['content'].push(obj);
			}
			
			settings['content'].sortOn('sID', Array.NUMERIC);
			super(settings);
		}
		
		private function drawStageInfo():void{
			
			var textSettings:Object = 
			{
				title		:getTextFormInfo('text5') + Locale.__e("flash:1382952380278", [1, info.count]),
				fontSize	:36,
				color		:0xffffff,
				borderColor	:0x77461d
				//autoSize	:"left"
				//textAlign	:'center',
			}
			
			var titleText:Sprite = titleText(textSettings);
			titleText.x = (settings.width - titleText.width) / 2;
			titleText.y = 350;
			bodyContainer.addChild(titleText);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 50, "paperScroll");
			layer.addChild(background);
			background.y = 45;
		}
		
		/*protected function drawRibbon():void 
		{
			var widthRibbon:int = settings.titleWidth + 120;
			if (widthRibbon < 320)
				widthRibbon = 320;
			var titleBackingBmap:Bitmap = backingShort(widthRibbon, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -5;
			titleBackingBmap.filters = [new DropShadowFilter(2, 90, 0, .4, 4, 4, 2)];
			//titleBackingBmap.filters = [new GlowFilter(0xf3ff2c, .7, 11, 11, 3)];
			bodyContainer.addChild(titleBackingBmap);
			
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y - 33;
			
			bodyContainer.addChild(titleLabel);
		}*/
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,		
				fontSize			: 34,				
				textLeading	 		: -3,				
				borderColor 		: settings.fontBorderColor,
				borderSize 			: 3,
				shadowSize 			: 1,
				shadowColor			: settings.fontBorderColor,
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: 220,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true,
				multiline			: true,
				wrap				: true
			})
			

		}
		
		override public function drawBody():void {
			
			drawMirrowObjs('decSeaweed', settings.width + 35, - 35, settings.height - 140, true, true, false, 1, 1);
			//drawLabel(settings.target.textures.sprites[3].bmp);
			drawRibbon();
			titleBackingBmap.y += 50;
			titleLabel.y += 65;
			//titleLabelImage.y += 20;
			/*exit.x += 30;
			exit.x -= 5;*/
			
			drawItems();
			//drawStageInfo();
			
			var descriptionLabel:TextField = new TextField();
		
			descriptionLabel = drawText(Locale.__e(settings.description), {
				fontSize	:26,
				autoSize	:"left",
				textAlign	:"center",
				color		:0x7f4015,
				border		:false,
				textLeading	:-9
			});
			descriptionLabel.wordWrap = true;
			descriptionLabel.width = 340;
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 75;
			bodyContainer.addChild(descriptionLabel);
			
			//decorateTitleWith('diamondsTop');
			//decorateWith('storageWoodenDec', 20);
			//drawBttns();

		}
		
		private function drawItems():void {
			
			var container:Sprite = new Sprite();
			
			var X:int = 0;
			var Y:int = 0;
			
			settings.content.sortOn('t', Array.NUMERIC);
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var _item:ShareGuestItem = new ShareGuestItem(settings.content[i], this);
				container.addChild(_item);
				_item.x = X;
				_item.y = Y;
				items.push(_item);
				
				X += _item.bg.width + 5;
			}
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2;
			container.y = 175;
		}
		
		public function blockItems(value:Boolean):void {
			for each(var _item:ShareGuestItem in items) {
				if(value)
					_item.bttn.state = Button.DISABLED;
				else
					_item.bttn.state = Button.NORMAL;
			}
		}
		
		public function getTextFormInfo(value:String):String {
			var text:String = info[value];
			text = text.replace(/\r/, "");
			return Locale.__e(text);
		}
		
		private function drawBttns():void {
			/*
			kickBttn = new Button({
				caption		:Locale.__e("flash:1382952380279"),
				width		:190,
				height		:38,	
				fontSize	:26
			});
			
			buyAllBttn = new MoneyButton({
				caption		:Locale.__e("flash:1382952380280"),
				width		:190,
				height		:42,	
				fontSize	:26,
				countText	:20
			});
			buyAllBttn.x = (settings.width - buyAllBttn.width) / 2;
			buyAllBttn.y = 400;
			
			kickBttn.x = (settings.width - kickBttn.width) / 2;
			kickBttn.y = 400;
			
			bodyContainer.addChild(kickBttn);
			bodyContainer.addChild(buyAllBttn);
			
			kickBttn.addEventListener(MouseEvent.CLICK, kickEvent);
			buyAllBttn.addEventListener(MouseEvent.CLICK, buyAllEvent);
			
			kickBttn.visible = false;*/
		}
		
		override public function drawExit():void {
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 45;
			exit.y = 35;
			exit.addEventListener(MouseEvent.CLICK, close);
		}		
	}
}

import buttons.Button;
import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.elements.PriceLabel;
import wins.Window;

internal class ShareGuestItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	private var kicks:uint;
	private var type:uint;
	private var kicksNum:uint;
	
	public function ShareGuestItem(obj:Object, window:*) {
		
		this.type = obj.t;
		this.sID = obj.sID;
		this.kicks = window.info.kicks[sID].c;
		this.item = App.data.storage[sID];
		this.kicksNum = window.info.kicks[sID].k;
		this.window = window;
		
		bg = Window.backing(150, 190, 20, 'itemBacking');
		addChild(bg);
		bg.filters = [new DropShadowFilter(2, 45, 0, .4, 4, 4, 2)];
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		drawTitle();
		drawLabel();
		drawkicksNum();
		
		tip = function():Object 
		{
			return {
				title: Locale.__e(item.title),
				text: Locale.__e(item.description)
			}
		}
	}
	
	private var count_txt:TextField; 
	private var count:int; 

	private function drawCount():void
	{
		count = App.user.stock.count(sID);
		count_txt = Window.drawText(Locale.__e('flash:1382952380305')+" "+String(count),{
			fontSize		:24,
			color			:0xffdc39,
			borderColor		:0x6d4b15,
			autoSize:"left"
		});
		
		addChild(count_txt);
	}
	
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption:window.getTextFormInfo('text7'),
			width:120,
			height:38,
			fontSize:23
		}
		
		if(item.real == 0 || type == 1){
			bttnSettings['borderColor'] = [0xaff1f9, 0x005387];
			bttnSettings['bgColor'] = [0x70c6fe, 0x765ad7];
			bttnSettings['fontColor'] = 0x453b5f;
			//bttnSettings['fontBorderColor'] = 0xe3eff1;
		}
		
		bttn = new Button(bttnSettings);
		
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 20;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		if (item.real == 0 && App.user.friends.data[App.owner.id]['energy'] <= 0&&App.user.stock.data[Stock.GUESTFANTASY] <= 0){
			bttn.state = Button.DISABLED;
		}
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		switch(type) {
			case 2:
				if (!App.user.stock.check(Stock.FANT, item.real)) 
					return;
			break;
			case 3:
				if (!App.user.stock.check(sID, 1)) 
					return;
			break;
		}
		/*
		var boost:int = 0;
		if(item.real > 0)
			boost = 1;*/
		
		window.blockItems(true);
		window.settings.kickEvent(sID, onKickEventComplete, type);
	}
	
	private function onKickEventComplete():void {//sID:uint, price:uint
		
		var sID:uint;
		var price:uint;
		if (type == 1) {
			window.close();
			return;
		}
		else if (type == 2)
		{
			sID = Stock.FANT;
			price = item.price[Stock.FANT];
		}
		else if (type == 3)
		{
			//sID = this.sID;
			sID = Stock.GUESTFANTASY;
			price = 1;
		}
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
		window.close();
	}	
	
	private function onLoad(data:Bitmap):void {
		bitmap.bitmapData = data.bitmapData;		
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 - 10;
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	private var title:TextField; 
	
	
	public function drawTitle():void {
		title = Window.drawText(String(item.title), {
			color:0x6d4b15,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:20,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = bg.width - 10;
		title.height = title.textHeight;
		title.y = 10;
		title.x = 5;
		addChild(title);		
	}
	
	private var kicksNumLable:TextField; 
	private var kicksNumAmount:int; 
	
	private function drawkicksNum():void
	{
		kicksNumAmount = kicksNum;
		kicksNumLable = Window.drawText("+"+String(kicksNumAmount),{
			fontSize		:22,
			color			:0x814f31,
			borderColor		:0xffffff,
			autoSize		:"left"
		});		
		addChildAt(kicksNumLable, 3);
		kicksNumLable.y = title.y + title.height - 2;
		kicksNumLable.x = (title.x + (title.width / 2)) - 15;
	}
	
	public function drawLabel():void {
		
		var bttnSettings:Object = {
			caption:window.getTextFormInfo('text7'),
			width:120,
			height:38,
			fontSize:23
		}
		
		var price:PriceLabel;
		var text:String = '';
		var hasButton:Boolean = true;
		if (type == 2) { // за кристалы
			bttnSettings["bgColor"] = [0x97c9fe, 0x5e8ef4];
			bttnSettings["borderColor"] = [0xffdad3, 0xc25c62];
			bttnSettings["bevelColor"] = [0xb3dcfc, 0x376dda];
			bttnSettings["fontColor"] = 0xffffff;			
			bttnSettings["fontBorderColor"] = 0x395db3;
			bttnSettings["greenDotes"] = false;
			bttnSettings["diamond"] = "diamond";
			if (item.price && !bttnSettings["countText"]) 
			{
				bttnSettings["countText"] = item.price[27];
			}
			price = new PriceLabel(item.price);
			addChild(price);
			price.x = (bg.width - price.width) / 2;
			price.y = 135;
		}
		else if (type == 3) { // со склада
			var part1:String = Locale.__e('flash:1382952380305');
			part1 = part1.replace('.','');
			text = part1 + ": "+String(App.user.stock.count(sID));
		}
		else if (type == 1) { // за фантазию
			var guests:Object = window.settings.target.guests;
			
			if (guests.hasOwnProperty(App.user.id) && guests[App.user.id] > 0 && guests[App.user.id] > App.midnight)
			{
				text = Locale.__e("flash:1382952380288");//Один раз в день
				hasButton = false;
			}
			else if (Numbers.countProps(window.settings.target.info.kicks) == 0)
			{	
				text = Locale.__e("flash:1383041104026"); //Нет
				hasButton = false;
			}
			else
			{
				var prOb:Object = new Object();
				prOb[Stock.GUESTFANTASY] = 1;
				price = new PriceLabel(prOb);
				addChild(price);
				price.x = (bg.width - price.width) / 2;
				price.y = 135;
			}
		}
		
		var label:TextField;
		if(text != '')
		{
			label = Window.drawText(text, {
				color:0x6d4b15,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:20,
				textLeading:-6,
				multiline:true
			});
			
			label.wordWrap = true;
			label.width = bg.width - 10;
			label.height = label.textHeight;
			label.y = 140;
			label.x = 5;
			addChild(label);
		}
		
		bttn = new Button(bttnSettings);
		if (!hasButton)
			return;
			
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 20;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		if(type == 1 && App.user.friends.data[App.owner.id]['energy'] <= 0&&App.user.stock.data[Stock.GUESTFANTASY] <= 0){
			bttn.state = Button.DISABLED;
		}else if(type == 3) {
			if (App.user.stock.count(sID) <= 0) {
				bttn.state = Button.DISABLED;
			}
		}
	}
}