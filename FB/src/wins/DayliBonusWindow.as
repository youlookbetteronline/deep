package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;

	public class DayliBonusWindow extends Window
	{
		public var items:Array = new Array();
		private var back:Bitmap;
		private var okBttn:Button;
		public var currentDayItem:DayliItem
		private var textFilter:GlowFilter;
		private var shadowFilter:BlurFilter;
		private var sprite:LayerX;
		
		public function DayliBonusWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 				= 740;
			settings['height'] 				= 520;
			settings['title'] 				= Locale.__e("flash:1382952380042");
			settings['hasPaginator'] 		= false;
			settings['content'] 			= [];
			settings['fontSize'] 			= 48;
			settings['shadowBorderColor']   = 0x342411;
			settings['fontBorderSize'] 		= 4;
			settings['hasExit'] 			= false;
			settings['faderClickable'] 		= false;
			settings['hasBubbles'] 			= true;
			settings["bubblesCount"] = 20;
			
			for each(var item:Object in App.data.daylibonus)
			{
				settings.content.push(item);
			}
			
			super(settings);
		}
		/*
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: true,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -35;
			bodyContainer.addChild(titleLabel);
			//drawMirrowObjs('diamondsTop', titleLabel.x - 5, titleLabel.x + titleLabel.width + 5, titleLabel.y - 20, true, true);
			
			var descLabel:TextField = Window.drawText(Locale.__e("flash:1397115227646"), {
				fontSize	:28,
				color		:0xFFFFFF,
				borderColor	:0x5f2980,
				textAlign	:"center"
			});
			descLabel.width = descLabel.textWidth + 20;
			descLabel.x = titleLabel.x + (titleLabel.width - descLabel.width) / 2;
			descLabel.y = -5;
			bodyContainer.addChild(descLabel);
		}*/
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xf9fdff,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x116011,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: 0x235b00,
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
		
		private var backBack:Bitmap;
		override public function drawBackground():void {
			back = backing(settings.width, settings.height, 50, 'dailyBonusBackingUp');
			layer.addChild(back);
			back.x = (settings.width - back.width) / 2;
			back.y = 0;
			back.filters = [new DropShadowFilter(6.0, 90, 0xa16a28, 1, 2.0, 2.0, 1.8, 3, false, false, false)];
			
			backBack = backing(670, 350, 50, 'dailyBonusBackingBack');
			layer.addChild(backBack);
			backBack.x = (settings.width - backBack.width) / 2;
			backBack.y = back.y + 130;
			backBack.filters = [new DropShadowFilter(4.0, 90, 0xffebc2, 1, 2.0, 2.0, 1.8, 3, false, false, false)];
			
			drawTenlacles();
			//drawBubbles();
			
			var backgroundTitle:Shape = new Shape();
			backgroundTitle.graphics.beginFill(0xf0c001, .6);
		    backgroundTitle.graphics.drawRect(0, 0, settings.width - 100, 50);
		    backgroundTitle.graphics.endFill();
			backgroundTitle.filters = [new BlurFilter(40, 0, 2)];
			
			//var backgroundTitle:Bitmap = Window.backingShort(settings.width - 80, 'dailyBonusBackingDesc', true);
			backgroundTitle.x =  (settings.width -  backgroundTitle.width)/ 2 ;
			backgroundTitle.y =  back.y + 25;
			bodyContainer.addChild(backgroundTitle);
			
			var descLabel:TextField = Window.drawText(Locale.__e("flash:1397115227646"), {
				fontSize	:32,
				color		:0xFFFFFF,
				borderColor	:0x7f3d0e,
				textAlign	:"center"
			});
			descLabel.width = descLabel.textWidth + 20;
			descLabel.x = titleLabel.x + (titleLabel.width - descLabel.width) / 2;
			descLabel.y = backgroundTitle.y + (backgroundTitle.height - descLabel.height) / 2 + 4;
			bodyContainer.addChild(descLabel);
			
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			layer.addChild(exit);
			exit.x = back.x + back.width - 46;
			exit.y = back.y - 14;
			exit.addEventListener(MouseEvent.CLICK, close);			
		}
		
		override public function titleText(settings:Object):Sprite
		{
			if (!settings.hasOwnProperty('width'))
				settings['width'] = 300;
				
			var cont:Sprite = new Sprite();
			var cont2:Sprite = new Sprite();
			var shadow:Sprite = new Sprite();
			
			var fontBorder:int = settings.fontBorderSize;
			settings.fontBorderSize = fontBorder;
			var fontBorderGlow:int = settings.fontBorderGlow;
			settings.fontBorderGlow = fontBorderGlow;
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			this.settings['titleWidth'] = textLabel.textWidth;
			this.settings['titleHeight'] = textLabel.textHeight;
			textLabel.wordWrap = true;
			textLabel.width = settings.width;
			textLabel.height = textLabel.textHeight + 4;
			
			var borderColor:uint = settings.borderColor
			settings.borderColor = borderColor;//settings.shadowBorderColor;
			settings.color = borderColor;
			
			var textShadow:TextField = Window.drawText(settings.title, settings);
			textShadow.wordWrap = true;
			textShadow.width = settings.width;
			textShadow.height = textLabel.textHeight + 4;
			
			textShadow.cacheAsBitmap = true;
			textLabel.cacheAsBitmap = true;

			var textShadow2:TextField = Window.drawText(settings.title, settings);
			textShadow2.wordWrap = true;
			textShadow2.width = settings.width;
			textShadow2.height = textLabel.textHeight + 4;
			textShadow2.cacheAsBitmap = true;
			
			settings.borderColor = 0x2a5e0b;
			settings.color = 0x2a5e0b;
			var textShadow3:TextField = Window.drawText(settings.title, settings);
			textShadow3.wordWrap = true;
			textShadow3.width = settings.width;
			textShadow3.height = textLabel.textHeight + 4;
			textShadow3.cacheAsBitmap = true;
					
			var textShadow4:TextField = Window.drawText(settings.title, settings);
			textShadow4.wordWrap = true;
			textShadow4.width = settings.width;
			textShadow4.height = textLabel.textHeight + 4;
			textShadow4.cacheAsBitmap = true;
			
			cont2.addChild(shadow);
			shadow.addChild(textShadow3);
			shadow.addChild(textShadow4);
			cont2.addChild(cont);
			
			//cont.addChild(textShadow);
			//cont.addChild(textShadow2);
			
			cont.addChild(textLabel);
			textFilter = new GlowFilter(0x579705, 1, 3,3, 10, 1);
			cont.filters = [textFilter/*, new BlurFilter(1.2,1.2,1)*/];
			
			shadowFilter = new BlurFilter(2,2,1);
			shadow.filters = [shadowFilter/*, new BlurFilter(1.2,1.2,1)*/];
			
			
			textShadow.y = 1;
			textShadow2.y = -2;
			textShadow3.y = 4;
			textShadow3.x = 1;
			textShadow4.y = 4;
			textShadow4.x = -1;
			cont.mouseEnabled = false;
			cont.mouseChildren = false;
			return cont2;
		}
		
		override public function drawBody():void {
			
			var titleBackingBmap:Bitmap = backingShort(520, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = settings.width/2 -titleBackingBmap.width/2;
			titleBackingBmap.y = -90;
			titleBackingBmap.scaleY = 1.2;
			titleBackingBmap.smoothing = true;
			bodyContainer.addChild(titleBackingBmap);
			
			titleLabel.y = titleBackingBmap.y + 14 + (titleBackingBmap.height - titleLabel.height)/2;
			
			/*Load.loading(Config.getImage('promo/images', 'crystals'), function(data:Bitmap):void {
					var image:Bitmap = new Bitmap(data.bitmapData);
					//headerContainer.addChildAt(image, 0);
					image.x = settings.width / 2 - image.width / 2;
					image.y = -80;
			});*/
			/*sprite = new LayerX();
			addChild(sprite);*/
			
			drawItems();
			
			okBttn = new Button( {
				caption:Locale.__e('flash:1382952379737'),
				fontSize:32,
				radius:15,	
				width:200,
				height:60
			});
			
			bodyContainer.addChild(okBttn);
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - okBttn.height ;
			okBttn.filters = [new DropShadowFilter(4.0, 90, 0, .6, 2.0, 2.0, 1, 3, false, false, false)];
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
		}
		
		public function drawTenlacles():void {
			
			var tentacle1:Bitmap = new Bitmap(Window.textures.tentacle1);
			tentacle1.x = - 70;
			tentacle1.y = -tentacle1.height/2 + 20;
			layer.addChild(tentacle1);
			
			var tentacle2:Bitmap = new Bitmap(Window.textures.tentacle2);
			tentacle2.x = back.width - tentacle2.width/2 + 8;
			tentacle2.y = 130;
			layer.addChild(tentacle2);
			
			var tentacle3:Bitmap = new Bitmap(Window.textures.tentacle3);
			tentacle3.x = - tentacle2.width/2 - 14;
			tentacle3.y = 295;
			layer.addChild(tentacle3);
			
			var tentacle4:Bitmap = new Bitmap(Window.textures.tentacle4);
			tentacle4.x = - tentacle2.width/2 - 14;
			tentacle4.y = 70;
			layer.addChild(tentacle4);
			
			var tentacle5:Bitmap = new Bitmap(Window.textures.tentacle5);
			tentacle5.x = back.width - tentacle2.width/2 + 10;
			tentacle5.y = 315;
			layer.addChild(tentacle5);
			
			var tentacle6:Bitmap = new Bitmap(Window.textures.tentacle6);
			tentacle6.x = 50;
			tentacle6.y = back.height - 37;
			layer.addChild(tentacle6);
			
			var tentacle7:Bitmap = new Bitmap(Window.textures.tentacle7);
			tentacle7.x = back.width - tentacle7.width - 24;
			tentacle7.y = back.height - 106;
			bodyContainer.addChild(tentacle7);
			
			var tentacle8:Bitmap = new Bitmap(Window.textures.tentacle8);
			tentacle8.x = back.width - tentacle8.width + 62;
			tentacle8.y = -tentacle1.height/2 + 44;
			layer.addChild(tentacle8);
			
		}
		
		private function onOkBttn(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			e.currentTarget.state = Button.DISABLED
			take();
		}
		
		private function drawItems():void {
			
			var container:Sprite = new Sprite();
			
			var X:int = 0;
			var Y:int = 36;
			
			for (var i:int = 0; i < 5; i++) {
				var item:DayliItem = new DayliItem(settings.content[i], this);
				
				//if (item.itemDay == App.user.day){
				container.addChild(item);
				/*}else
					container.addChildAt(item,0);*/
				item.x = X;
				item.y = Y;
				
				X += item.bg.width + 8;
			}
			
			layer.addChild(container);
			//container.x = (settings.width - container.width) / 2;
			container.x = (settings.width - 632) / 2;
			container.y = 110;
			
		}
		
		public function take():void 
		{
			Post.send( {
				ctr:'user',
				act:'day',
				uID:App.user.id
			}, function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (App.social == 'FB') {						
					ExternalApi.og('claim', 'daily_bonus');
				}
				
				if (!User.inExpedition) 
				{
					App.user.stock.addAll(data.bonus);
				}
				
				
				for (var _sid:* in data.bonus) 
				{
					var item:BonusItem = new BonusItem(_sid, data.bonus[_sid]);
					var point:Point = Window.localToGlobal(currentDayItem);
					point.y += 80;
					item.cashMove(point, App.self.windowContainer);
				}
				
				setTimeout(close, 1500);
			});
		}
	}
}	


import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import ui.UserInterface;
import wins.DayliBonusWindow;
import wins.Window;
	

internal class DayliItem extends Sprite {
	
	private var item:Object;
	public var bg:Bitmap;
	public var bgBitmap:Bitmap;
	public var win:DayliBonusWindow;
	private var title:TextField;
	private var countText:TextField;
	private var sID:uint;
	private var count:uint;
	private var bitmap:Bitmap = new Bitmap();
	private var status:int = 0;
	public var itemDay:int;
	private var check:Bitmap = new Bitmap(Window.textures.checkmarkBig);
	public var preloader:Preloader = new Preloader();
	public function DayliItem(item:Object, win:DayliBonusWindow) {
		
		this.win = win;
		this.item = item;
		itemDay = item.day;
		
		var sprite:LayerX = new LayerX();
		
		sprite.tip = function():Object { 
			return {
				title:App.data.storage[Numbers.firstProp(item.bonus).key].title,
				text:App.data.storage[Numbers.firstProp(item.bonus).key].description
			};
		};
		
		if (item.day == App.user.day) {
			status = 1;
			win.currentDayItem = this;
		}else if (item.day > App.user.day + 1)
			status = 0;
		else if (item.day == App.user.day + 1)
			status = 2;
		else if (item.day < App.user.day)
			status = -1;
			
		if (status == 1) {
			bg = Window.backing(120, 320, 40, 'dailyBonusTodayBack');
		}else if(status == 2)
		{
			bg = Window.backing(120, 320, 40, 'dailyBonusTomorrowBack');
		}else
		{
			bg = Window.backing(120, 320, 40, 'dailyBonusSimpleBack');
		}
		
		bg.filters = [new GlowFilter(0x974401, 1, 4, 4, 10, 1)];
		addChild(bg);
		if (item == null) return;
		
		for (var _sID:* in item.bonus) break;
		sID = _sID;
		count = item.bonus[_sID];
		
		
		drawCount();
		drawDay();
		
		if (status == 1 || status == 2) {
			bgBitmap = new Bitmap(Window.textures.dailyBonusItemGlow);
		}else
		{
			bgBitmap = new Bitmap(Window.textures.dailyBonusItemBubble);
		}
		
		addChild(bgBitmap);
		bgBitmap.visible = false;
		addChild(sprite);
		sprite.addChild(bitmap);
		//addChild(bitmap);
		
		addChild(preloader);
		preloader.x = (bg.width) / 2;
		preloader.y = (bg.height) / 2 + 35;
			
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), function(data:Bitmap):void {
			removeChild(preloader);
			bitmap.bitmapData = data.bitmapData;
			
			if (status == 1 || status == 2) {
				Size.size(bitmap, 85, 85);
			}else
			{
				Size.size(bitmap, 75, 75);
			}
				
			bitmap.smoothing = true;
			
			bitmap.x = (bg.width - bitmap.width) / 2;
			bitmap.y = (bg.height - bitmap.height) / 2 + 35;
			
			bgBitmap.x = bitmap.x + (bitmap.width - bgBitmap.width) / 2;
			bgBitmap.y = bitmap.y + (bitmap.height - bgBitmap.height) / 2;
			
			bgBitmap.visible = true;
			
			if (sID == Stock.FANT) return;
			if (status == 0 || status == 2){
				UserInterface.effect(bitmap, 0, 0.8);
			}
		});
		drawTitle();
		
		drawMark();
	}
	
	private function drawMark():void 
	{
		if (status == -1)
		{
			addChild(check);
		}
		check.x = (bg.width - check.width) / 2;
		check.y = 68;
		check.filters = [new GlowFilter(0xe8fd5a, .8, 6, 6, 8, 1)];
	}
	
	private function drawTitle():void
	{
		var textSettings:Object = {
			color:0x773c18,
			borderColor:0xfaf9eb,
			textAlign:"center",
			autoSize:"center",
			width:bg.width - 12,
			fontSize:24,
			textLeading:-6,
			multiline:true
		};
		
		if(status == 1){
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x085c10;
		}
			
		if(status == 2){
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x0453a4;
		}	
		if(status == 0){
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x7f3d0e;
		}
		
		title = Window.drawText(App.data.storage[sID].title, textSettings);
		
		title.wordWrap = true;
		title.y = bg.height - 80;
		title.x = 5;
		addChild(title);
	}
	
	private function drawDay():void
	{
		var textSettings:Object = {
			color:0xFFFFFF,
			borderColor:0x7f3d0e,
			fontSize:34,
			textAlign:"center",
			autoSize:"center",
			textLeading:-6,
			multiline:true
		}
		
		var text:String = Locale.__e('flash:1382952380043', [item.day]);
		
		if(status == 1){
			text = Locale.__e("flash:1382952380044");
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x085c10;
		}
			
		if(status == 2){
			text = Locale.__e("flash:1383041362368");
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x0453a4;
		}	
		if(status == 0){
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x7f3d0e;
		}
		
		var title:TextField = Window.drawText(text, textSettings);
		title.wordWrap = true;
		title.width = bg.width;
		title.y = 25;
		title.x = 0;
		addChild(title)
	}
	
	private function drawCount():void
	{
		var textSettings:Object = {
			color:0xffffff,
			borderColor:0x682f1e,
			textAlign:"center",
			autoSize:"center",
			fontSize:32,
			textLeading:-6,
			multiline:true
		};
		var text:String = "x "+ String(count);
		
		if(status == 1){
			textSettings['color'] = 0xf6ff00;
			textSettings['borderColor'] = 0x306100;
		}
			
		if(status == 2){
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x0453a4;
		}	
		if(status == 0){
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x7f3d0e;
		}
		
		var countText:TextField = Window.drawText(text, textSettings);
		countText.wordWrap = true;
		countText.width = bg.width;
		countText.y = bg.height - countText.height - 18;
		countText.x = 0;
		addChild(countText)
		
	}
}

