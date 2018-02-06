package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Hints;
	import ui.UserInterface;

	public class GambleWindow extends Window
	{
		public var playBttn:Button;
		public var playFreeBttn:Button;
		public var items:Array = [];
		public var wheelImg:Bitmap;
		public var wishBttn:Button;
		private var textFilter:GlowFilter;
		private var shadowFilter:BlurFilter;
		public var reqMaterial:int;
		private var ticket:Bitmap;
		private var center:Bitmap;
		private var crab:Bitmap;
		
		public function GambleWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 520;
			settings['height'] = 490;
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			settings['fontSize'] = 54;
			settings['title'] = settings.target.info.title;			
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			var j:int = 0;
			var obj:Object = new Object;
			var obj2:Object = new Object;
			reqMaterial = App.data.storage[this];			
			settings.content =  settings.target.info.items;
			super(settings);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 44,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x085c10,			
				borderSize 			: 2,	
				
				shadowBorderColor	: 0x235b00,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = -121;
			
			
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
			textFilter = new GlowFilter(0x427514, 1, 1,1, 1, 1);
			cont.filters = [textFilter/*, new BlurFilter(1.2,1.2,1)*/];
			
			shadowFilter = new BlurFilter(1,1,1);
			shadow.filters = [shadowFilter/*, new BlurFilter(1.2,1.2,1)*/];
			
			
			textShadow.y = 1;
			textShadow2.y = -1;
			textShadow3.y = 1;
			textShadow3.x = 1;
			textShadow4.y = 1;
			textShadow4.x = -1;
			cont.mouseEnabled = false;
			cont.mouseChildren = false;
			return cont2;
		}
		
		public var dX:uint = 160
		override public function drawBody():void 
		{			
			this.y += 65;
			fader.y -= 65;
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			
			var titleBackingBmap:Bitmap = backingShort(320, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -125;
			
			if (exit != null)
			{
				exit.x = (background.x + background.width - exit.width * (3 / 4)) - 5;
				exit.y -= exit.height * (3 / 4) - 20;
			}
			
			drawBttns();
			
			wheelBG = new Bitmap(Window.textures.wheelBG);
			wheelBG.x = (settings.width - wheelBG.width) / 2;
			wheelBG.y = -140;
			
			drawWheel();
			
			if (!settings.target.tribute) {
				playBttn.visible = true;
				drawTime();
			}else
			{
				playBttn.visible = false;
			}
			
			bodyContainer.addChild(wheelBG);
			bodyContainer.addChild(titleBackingBmap);
			bodyContainer.addChild(titleLabel);		
			bodyContainer.addChild(wheel);
			
			center = new Bitmap(Window.textures.rouletteCenter);
			center.x = wheelBG.x + (wheelBG.width - center.width) / 2 - 5;
			center.y = wheelBG.y + (wheelBG.height - center.height) / 2 + 40;
			bodyContainer.addChild(center);

			var text:String = Locale.__e("flash:1487002125180");
			backDesc.graphics.beginFill(0xfcd586, 1);
			backDesc.graphics.drawRect(0, 0, settings.width - 90, 75);
			backDesc.graphics.endFill();
			backDesc.x = (settings.width - backDesc.width) / 2 ;
			backDesc.y = wheelBG.y + wheelBG.height - 5;
			backDesc.filters = [new BlurFilter(30, 0, 2)];
			bodyContainer.addChild(backDesc); 
			
			crab = new Bitmap(Window.textures.crabPearl);
			crab.x = 40;
			crab.y = settings.height - crab.height - 45;
			bodyContainer.addChild(crab);

			descriptionLabel = drawText(text, {
				fontSize:26,
				autoSize:"center",
				textAlign:"center",
				color:0x70431f,
				width:350,
				wrap:true,
				multiline:true,
				border:false
			});		
			descriptionLabel.width = settings.width - 75;
			descriptionLabel.x = background.x + (background.width - descriptionLabel.width) / 2 - 40;
			descriptionLabel.y = backDesc.y + 10;
			bodyContainer.addChild(descriptionLabel);
			
			
			/*var descriptionCount:TextField = drawText("5", {
				fontSize:36,
				autoSize:"center",
				textAlign:"center",
				color:0xffffff,
				borderColor: 0x7c3f15,
				width:350,
				wrap:true,
				multiline:true
			});

			descriptionCount.x = descriptionLabel.x + descriptionLabel.textWidth - 20;
			descriptionCount.y = descriptionLabel.y + 5;
			bodyContainer.addChild(descriptionCount);
			bodyContainer.addChild(descriptionLabel);
			
			ticket = new Bitmap(Window.textures.ticketLotto);
			Size.size(ticket, 50, 50);
			ticket.x = backDesc.x + backDesc.width / 2 + 100;
			ticket.y = backDesc.y + 11;
			ticket.filters = [new GlowFilter(0xffffff, 0.8, 10, 10, 2)]*/
			var ticketLayer:LayerX = new LayerX();
			ticketLayer.tip = function():Object 
			{ 
				return {
					title:App.data.storage[Numbers.firstProp(settings.target.info.materialskip).key].title,
					text:App.data.storage[Numbers.firstProp(settings.target.info.materialskip).key].description
				};
			};
			ticket = new Bitmap();
			Load.loading(Config.getIcon(App.data.storage[Numbers.firstProp(settings.target.info.materialskip).key].type, App.data.storage[Numbers.firstProp(settings.target.info.materialskip).key].preview), onLoadTicket);
			ticketLayer.addChild(ticket);
			bodyContainer.addChild(ticketLayer);
			
			drawTickets();
			
			if (App.isSocial('YB','MX','AI')) 
			{
				var descriptionLabelJP:TextField = drawText(Locale.__e("flash:1435052650729"), {
					fontSize:18,
					autoSize:"center",
					textAlign:"center",
					color:0x713e13,
					borderColor:0xffffff,
					width:settings.width - 75,
					wrap:true,
					multiline:true
				});
				descriptionLabelJP.y = settings.width/2 + settings.y + 40+ 60;
				descriptionLabelJP.x =  background.x + (background.width - descriptionLabel.width) / 2;
				bodyContainer.addChild(descriptionLabelJP);	
			}			
			drawArrow();
		}
		
		private var timeConteiner:Sprite;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		private function onLoadTicket(data:Bitmap):void 
		{
			ticket.bitmapData = data.bitmapData;
			Size.size(ticket, 90, 90);
			ticket.smoothing = true;
			ticket.x = backDesc.x + backDesc.width / 2 + 55;
			ticket.y = backDesc.y + (backDesc.height - ticket.height) / 2;
			drawWishListBttn();
			
			drawTickets();
			
		}
		public function drawWishListBttn():void 
		{
			wishBttn = new Button( {
				width			:60,
				fontSize		:26,
				radius			:25,
				caption			:'+',
				fontSize		:26,
				height			:40,
				bgColor			:[0xf2ce4f,0xe1a535],//Цвета градиента
				fontBorderColor	:0x6e411e,	
				bevelColor		:[0xf7fe9b, 0xcb6b1e]
				
			});
			
			bodyContainer.addChild(wishBttn);
			wishBttn.x = ticket.x + ticket.width + 5;
			wishBttn.y = ticket.y + (ticket.height - wishBttn.height) / 2;
			
			wishBttn.tip = function():Object 
			{ 
				return {
					title:Locale.__e("flash:1382952380013")
				};
			};
			wishBttn.addEventListener(MouseEvent.CLICK, wishesEvent);
		}
		
		private var descriptionCount:TextField;
		public function drawTickets():void 
		{
			if (descriptionCount && descriptionCount.parent)
				descriptionCount.parent.removeChild(descriptionCount);
				
			var countTickets:String = String(App.user.stock.count(Numbers.firstProp(settings.target.info.materialskip).key)) + '/' + String(Numbers.firstProp(settings.target.info.materialskip).val);
			descriptionCount = drawText(countTickets, {
				fontSize:32,
				autoSize:"center",
				textAlign:"left",
				color:0xffffff,
				borderColor: 0x7c3f15,
				wrap:true,
				multiline:true
			});
			//descriptionCount.border = true;
			descriptionCount.x = ticket.x + ticket.width - descriptionCount.textWidth;
			descriptionCount.y = ticket.y + ticket.height - descriptionLabel.height + 20;
			bodyContainer.addChild(descriptionCount);
			
		}
		public function drawTime():void {
			
			timeConteiner = new Sprite();
			
			descriptionLabel = drawText(Locale.__e('flash:1382952380127'), {
				fontSize:26,
				textAlign:"center",
				color:0xfff9fa,
				borderColor:0x4c3604
			});
			
			descriptionLabel.width = 230;
			descriptionLabel.x = (descriptionLabel.width - 230)/2;
			descriptionLabel.y = 25;
			timeConteiner.addChild(descriptionLabel);
			
			var time:int = App.nextMidnight - App.time;
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xffdb4b,
				letterSpacing:3,
				textAlign:"center",
				fontSize:32,
				borderColor:0x492318
			});
			timerText.width = 230;
			timerText.y = 53;
			timerText.x = 0;
			timeConteiner.addChild(timerText);
			
			timeConteiner.x = background.x + (background.width - timeConteiner.width)/2;
			timeConteiner.y = settings.width/2 + settings.y + 5;
			//bodyContainer.addChild(timeConteiner);
			
			App.self.setOnTimer(updateDuration);
		}
		
		private function updateDuration():void 
		{
			var time:int = App.nextMidnight - App.time;
				timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				descriptionLabel.visible = false;
				timerText.visible = false;
				playBttn.visible = false;
			}
		}
		
		public var background:Bitmap;
		public var back:Bitmap;
		override public function drawBackground():void 
		{
			if (settings.background != null)
			{
				background = backing(settings.width, settings.height, 30, 'paperScroll');
				layer.addChild(background);	
			}
		}
		
		private function drawBttns():void 
		{			
			playBttn = new Button({
				caption		:Locale.__e("flash:1382952380129"),
				width		:160,
				height		:46,	
				fontSize	:30
			});
			bodyContainer.addChild(playBttn);
			
			if (App.user.stock.count(Numbers.firstProp(settings.target.info.materialskip).key) < Numbers.firstProp(settings.target.info.materialskip).val) 
			{
				playBttn.state = Button.DISABLED;
			}
			
			playBttn.x = background.x + (background.width - playBttn.width) / 2;
			playBttn.y = settings.height - playBttn.height - 32;
			playBttn.addEventListener(MouseEvent.CLICK, onPlayClick);
			playBttn.state = Button.DISABLED;	
		}
		
		public var wheel:Sprite = new Sprite();
		
		private function drawWheel():void 
		{
			wheelImg = new Bitmap(Window.textures.wheel_new);
			wheelImg.smoothing = true;
			wheelImg.x = -wheelImg.width / 2;
			wheelImg.y = -wheelImg.height / 2;
			
			wheel.addChild(wheelImg);
			wheel.rotation += (360 / 8) / 2;
			wheel.x = (settings.width - wheel.width) / 2 + 176;
			wheel.y = wheelBG.y + wheel.height / 2 + 82;
			
			/*var shape1:Shape = new Shape(); // точка под обьектом
			shape1.graphics.beginFill(0xFFff00, 1);
			shape1.graphics.drawCircle(0, 0, 3);
			shape1.graphics.endFill();
			//shape1.x =(settings.width - wheel.width) / 2 + 160;
			//shape1.y = wheelBG.y + wheel.height / 2 + 92;
			wheel.addChild(shape1);*/
			
			drawItems();

			playBttn.state = Button.NORMAL;	
			
			if (App.user.stock.count(Numbers.firstProp(settings.target.info.materialskip).key) < Numbers.firstProp(settings.target.info.materialskip).val) 
			{
				playBttn.state = Button.DISABLED;
			}
		}
		
		public var arrow:Bitmap
		
		private function drawArrow():void 
		{
			arrow = new Bitmap(Window.textures.rouletteArrow);
			bodyContainer.addChild(arrow);
			arrow.x += 223;
			arrow.y -= 80;
		}
		
		private function drawItems():void {
			
			var num:uint = 0;
			for (var id:* in settings.content) {
				var item:WheelItem = new WheelItem(settings.content[id], this);
				items.push(item);
				
				wheel.addChild(item);
				var angle:Number = num * 360 / 8 + 30;
				item.angle 		= angle;
				item.rotation 	= angle;
				num ++;
			}
		}
		
		private function onPlayFreeClick(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			
			exit.visible = false;
			e.currentTarget.state = Button.DISABLED;
			settings.onPlay(0, onPlayComplete);
		}
		private var showwer:Boolean = true;
		private function onPlayClick(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED){
				Hints.text(Locale.__e('flash:1488794346991'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
				return;
			}
				
			showwer = false;
			exit.visible = false;	
			e.currentTarget.state = Button.DISABLED;
			var X:Number = App.self.mouseX - e.currentTarget.mouseX + e.currentTarget.width / 2;
			var Y:Number = App.self.mouseY - e.currentTarget.mouseY;			
			
			Hints.minus(Numbers.firstProp(settings.target.info.materialskip).key, Numbers.firstProp(settings.target.info.materialskip).val, new Point(X, Y), false, App.self.tipsContainer);
			
			settings.onPlay(1, onPlayComplete);	
			
			if (!App.user.stock.check(Numbers.firstProp(settings.target.info.materialskip).key, Numbers.firstProp(settings.target.info.materialskip).val))
			{
				exit.visible = true;
				return;
			}		
		}
		
		public function onPlayComplete(bonus:Object):void {
			var count:uint;
			for (var sID:* in bonus) {
				count = bonus[sID];
			}
			
			for each(var item:* in items) {
				if (item.sID == sID && item.count == count) {
					setWheelStopPoint(item);
				}
			}
		}
		
		private var winItem:WheelItem;
		private var wheelBG:Bitmap;
		private var backDesc:Shape = new Shape();
		private function setWheelStopPoint(item:WheelItem):void {
			
			trace(App.data.storage[item.sID].title);
			trace(item.count);
			trace(item.angle);
			winItem = item;
			
			var needRot:Number = 0 - item.angle + int(Math.random() * 14) - 97;
			var circles:int = int(Math.random() * 5) + 3;
			var time:Number = 8;
			
			setTimeout(takeReward, (time - 1) * 1000);
			TweenLite.to(wheel, time, { rotation:needRot + circles * 360 , ease:Strong.easeOut} );
		}
		
		private function takeReward():void {
			winItem.take();
			exit.visible = true;
		}
		
		public function onWheelStop():void
		{
			
			if (App.user.stock.count(Numbers.firstProp(settings.target.info.materialskip).key) < Numbers.firstProp(settings.target.info.materialskip).val) 
			{
				playBttn.state = Button.DISABLED;
			}else {
				playBttn.state = Button.NORMAL;
			}
			//playBttn.visible = true;
			showwer = true;
		}
		
		public override function dispose():void
		{
			if (playBttn) 
				playBttn.removeEventListener(MouseEvent.CLICK, onPlayClick);
			if (wishBttn)
				wishBttn.removeEventListener(MouseEvent.CLICK, wishesEvent);
			App.self.setOffTimer(updateDuration);
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			
			super.dispose();
		}
		protected function onStockChange(e:AppEvent):void 
		{
			drawTickets();
			
			if (App.user.stock.count(Numbers.firstProp(settings.target.info.materialskip).key) < Numbers.firstProp(settings.target.info.materialskip).val || showwer == false) 
				playBttn.state = Button.DISABLED;
			else	
				playBttn.state = Button.NORMAL;
		}
		
		public function wishesEvent(e:MouseEvent):void
		{
			new NeedResWindow( {
				title			:Locale.__e("flash:1435241453649"),
				text			:Locale.__e('flash:1487168353550'),
				height			:230,
				neededItems		:settings.target.info.materialskip,
				button3			:true,
				button2			:true,
				popup			:true
			}).show()
			//App.wl.show(Numbers.firstProp(settings.target.info.materialskip).key, e);
		}
	}
}

import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import wins.Window;

internal class WheelItem extends LayerX
{
	private var text:TextField;
	private var icon:Bitmap;
	public var sID:uint;
	public var count:uint;
	public var angle:Number;
	public var bitmap:Bitmap;
	public var window:*;
	
	public function WheelItem(data:Object, window:*) {
		
		this.window = window;
		for (var sID:* in data) {
			var count:uint = data[sID];
		}
		
		this.sID = sID;
		
		var material:Object = App.data.storage[sID];
		this.count = count;

		var cont:Sprite = new Sprite();
		text = Window.drawText(Numbers.moneyFormat(count), {
			color:0xffffff,
			borderColor:0x37286b,
			fontSize:22,
			textAlign:"center"
		});
		text.width = 80;
		text.height = text.textHeight;
		text.x = 127;
		text.y = -50
		text.rotation = 90;
		addChild(text);
		
		var bmd:BitmapData = new BitmapData(text.width, text.height, true, 0);
		bmd.draw(cont);
		
		bitmap = new Bitmap(bmd);
		addChild(bitmap);
		bitmap.x = 46;
		bitmap.y = -bitmap.height / 2;
		bitmap.smoothing = true;
		
		
		tip = function():Object { 
			return {
				title:App.data.storage[sID].title
			};
		};
		
		Load.loading(Config.getIcon(material.type, material.preview), onLoad);
	}
	
	public function take():void {
		
		var that:* = this;
		App.ui.flashGlowing(this, 0xFFFF00, function():void {
			var item:BonusItem = new BonusItem(that.sID, that.count);
			var point:Point = new Point();
			
			point.x = window.width/2 - 25;
			point.y = window.height/2 - 150;
			
			App.user.stock.add(sID, count);
			
			item.cashMove(point, App.self.windowContainer);
			
			that.window.onWheelStop();
		});
	}
	
	private function onLoad(data:Bitmap):void 
	{
		icon = new Bitmap(data.bitmapData);
		var scaleInd:int = 35;
		if (icon.height>scaleInd) 
		{
			icon.height = scaleInd;	
			icon.scaleX = icon.scaleY;
		}
		if (icon.width>scaleInd) 
		{
			icon.width = scaleInd;	
			icon.scaleY = icon.scaleX;
		}
		icon.smoothing = true;
		addChild(icon);
		icon.x = bitmap.x + bitmap.width - 50 - icon.width/2 + 90;
		icon.y = -icon.height / 2 - 10;
		icon.rotation = 90;
	}
}