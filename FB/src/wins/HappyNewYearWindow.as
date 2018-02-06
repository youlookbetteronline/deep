package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.elements.HappyToy;
	/**
	 * ...
	 * @author ...
	 */
	public class HappyNewYearWindow extends Window 
	{
		public static const OWNER:uint = 0;
		public static const GUEST:uint = 1;
		
		public var toyBacking:Bitmap;
		
		public var helpBttn:ImageButton;
		public var showBttn:Button;
		public var inviteBttn:Button;
		public var clearBttn:Button;
		
		private var treeContainer:Sprite;
		private var toyContainer:Sprite;
		
		public var mode:uint = OWNER;
		
		public var sid:int = 0;
		public var info:Object = {};
		private var trees:Array = [];
		public var bg:Bitmap;
		
		public function HappyNewYearWindow (settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = 666;
			settings['height'] = 445;
			settings['title'] = settings.target.info.title;
			settings['hasPaginator'] = false;
			settings['background'] = 'buildingBacking';
			
			sid = settings.target.sid;
			info = App.data.storage[sid];
			mode = settings['mode'] || OWNER;
			
			if (mode != OWNER) 
			{
				settings['width'] = 685;
				settings['height'] = 620;
			}
			
			settings['text'] = Locale.__e('flash:1418822910726')
			
			super(settings);
		}
		
		override public function drawBody():void {
			
			exit.x += 0;
			exit.y -= 18;
			
			titleLabel.y -= 10;			
			
			if (mode != OWNER)
			{
				drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 + 10, settings.width / 2 + settings.titleWidth / 2 + 10, titleLabel.y + 6, true, true);
			}else 
			{
				drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 + 60, settings.width / 2 + settings.titleWidth / 2 + 60, titleLabel.y + 6, true, true);
			}
			//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 + 60, settings.width / 2 + settings.titleWidth / 2 + 60, titleLabel.y + 6, true, true);
			drawMirrowObjs('storageWoodenDec', 0, settings.width - 0, 38, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', 0, settings.width - 0, settings.height - 78, false, false, true, 1, 1);
			
			var effect:Sprite = new Sprite();
			effect.graphics.beginFill(0xedca94);
			effect.graphics.drawRoundRect(0,0,(settings.width - 100), 100,40);
			effect.graphics.endFill();
			
			effect.alpha = .8;
			effect.x = (settings.width - effect.width)/2 ;
			effect.y = 0;
			
			var glow:Bitmap = new Bitmap();
			glow.scaleX = glow.scaleY = 5;
			glow.alpha = 0.5;
			glow.x = effect.x + (effect.width - glow.width) / 2;
			glow.y = effect.y + (effect.height - glow.height) / 2;
			bodyContainer.addChild(glow);
			
			if (mode == OWNER) {
				bg = Window.backing(280, 195, 20, 'itemBacking');
				bodyContainer.addChild(bg);//Подложка описания
				
				var descLebelText:String = Locale.__e('flash:1449656416748');
				var descLabelX:int = 380;
				var descLabelWidth:int = 310;
				
				var descLabel:TextField = drawText(descLebelText, {//flash:1418735216505
					textAlign:		'center',
					autoSize:		'center',
					fontSize:		24,
					color:			0xffffff,
					borderColor:	0x935a3c
				});
				
				//descBacking.graphics.beginFill(0xedca94, .8);
				//descBacking.graphics.drawRoundRect(0, 0, descLabelWidth , 100, 60, 60);
				//descBacking.graphics.endFill();
				bg.x =  (settings.width - bg.width) / 2 + 155;
				bg.y = 40;
				
				descLabel.width = descLabelWidth -20;//Описание
				descLabel.wordWrap = true;
				descLabel.x = bg.x + bg.width / 2 - descLabel.width / 2;
				descLabel.y = bg.y + bg.height / 2 - descLabel.height / 2;
				bodyContainer.addChild(descLabel);
				
				showBttn = new Button( {
					width:		200,
					height:		58,
					caption:	Locale.__e('flash:1396608121799')//Рассказать друзьям
				});
				
				showBttn.x = 60;
				showBttn.y = bg.y + bg.height - showBttn.height / 2 + 40;
				//bodyContainer.addChild(showBttn);
				showBttn.addEventListener(MouseEvent.CLICK, onShow);			
				
				var upCont:Sprite = new Sprite();
				bodyContainer.addChild(upCont);
				
				var avaBack:Bitmap = new Bitmap(Window.textures.friendsBttn, 'auto', true);
				avaBack.scaleX = avaBack.scaleY = 0.6;
				avaBack.x = -8;
				avaBack.y = 6;
				
				var avaImage:Bitmap = new Bitmap(Window.textures.friendsBttn, 'auto', true);
				//upCont.addChild(avaImage);
				upCont.x = showBttn.x + showBttn.width + 40;
				upCont.y = bg.y + bg.height ;
				
				var text:String = Locale.__e('flash:1407159672690');//Пригласить
				
				inviteBttn = new Button( {
					width:				165,
					height:				45,
					caption:			text,
					multiline:			true,
					textAlign:			'center',
					textLeading: 		-3,
					bgColor:			[0xfacf42,0xf5b329],
					borderColor:		[0xfbe969,0xca710b],
					bevelColor:			[0xfbe969,0xca710b],
					fontColor:			0xffffff,
					fontBorderColor:	0x8a533e,
					fontSize:			25
				});
				
				inviteBttn.x = bg.x + bg.width / 2 - inviteBttn.width / 2;
				inviteBttn.y = bg.y + bg.height + 40;
				
				if (!App.isSocial('SP')) 
				{
					bodyContainer.addChild(inviteBttn);
				}				
				
				inviteBttn.addEventListener(MouseEvent.CLICK, onInvite);
				
				clearBttn = new Button( {
					width:				105,
					height:				40,
					caption:			Locale.__e('flash:1418821499681'),
					fontSize:			23,
					bgColor:			[0xffa701,0xfb7d29],
					borderColor:		[0xfde56b,0xca4f09],
					bevelColor:			[0xfde56b,0xca4f09],
					fontColor:			0xffffff,
					fontBorderColor:	0x88513d
				});
				clearBttn.x = bg.x + bg.width / 2 - clearBttn.width / 2;
				clearBttn.y = inviteBttn.y + inviteBttn.height + 25;
				bodyContainer.addChild(clearBttn);
				clearBttn.addEventListener(MouseEvent.CLICK, onClear);						
				
			}else if (mode == GUEST) {
				
				toyBacking = backing(280, 525, 20, 'buildingDarkBacking');
				toyBacking.x = settings.width - toyBacking.width - 50;
				toyBacking.y = 30;
				
				var descGuestLabelText:String = settings.text;				
				
				var descGuestLabel:TextField = drawText(descGuestLabelText, {
					width:			280,
					textAlign:		'center',
					fontSize:		24,
					color:			0xffffff,
					borderColor:	0x874b2f,
					multiline:		true
				});
				descGuestLabel.x = toyBacking.x + (toyBacking.width - descGuestLabel.width) / 2;
				descGuestLabel.y = 0;
				
				bodyContainer.addChild(descGuestLabel);
				bodyContainer.addChild(toyBacking);				
			}
			
			// Tree
			
			treeContainer = new Sprite();
			treeContainer.x = -40;
			treeContainer.y = -60;
			bodyContainer.addChild(treeContainer);
			
			toyContainer = new Sprite();
			toyContainer.x = treeContainer.x;
			toyContainer.y = treeContainer.y;
			bodyContainer.addChild(toyContainer);
			
			drawTree();
			
			if (mode != OWNER) {
				drawToyIcons();
			}
			
			if (mode == OWNER) {				
				toyContainer.x -= 30;
				toyContainer.y -= 80;
			}
			
			drawToys();
			
			helpBttn = new ImageButton(Window.textures.friendsBttn);
			helpBttn.x = -2;
			helpBttn.addEventListener(MouseEvent.CLICK, onHelp);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
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
			
			titleLabel.x = (settings.width - titleLabel.width) * .5 + 60;
			if (mode != OWNER) 
			{
				titleLabel.x = (settings.width - titleLabel.width) * .5 + 10;	
			}
			titleLabel.y = -40;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			bodyContainer.addChild(titleLabel);
		}
		
		private function onShow(e:MouseEvent):void {
			var type:uint = WallPost.HAPPY_SHARE;
			WallPost.makePost(type, { sid:sid, uid:App.user.id, bmd:getBitmapData() } );
		}
		
		private function onInvite(e:MouseEvent):void {
			close();
			
			var descText:String = Locale.__e("flash:1418821860999");
			
			new AskWindow(AskWindow.MODE_INVITE, {
				target:settings.target,
				title:Locale.__e('flash:1382952380197'), 
				friendException:function(... args):void {
					//trace(args);
				},
				inviteTxt:Locale.__e("flash:1395846352679"),
				desc:descText,
				noAllFriends:true,
				bmd:getBitmapData()
			} ).show();
		}
		
		private function getBitmapData():BitmapData 
		{
			var bmd:BitmapData;
			if (sid == 520) {
				bmd = settings.target.textures.sprites[settings.target.level].bmp;
			}else {
				bmd = new BitmapData(treeContainer.width, treeContainer.height, true, 0);
				bmd.draw(treeContainer);
				bmd.draw(toyContainer);
			}
			
			return bmd;
		}
		
		private var clearReask:Boolean = false;
		private function onClear(e:MouseEvent = null):void {
			if (!clearReask) {
				clearReaskWindow();
				return;
			}
			clearReask = false;
			
			//settings.target.clearToyAction(null, null, true);
			settings.target.clearToyAction(null, onAllToysRemove, true);
			while (toys.length > 0) {
				onToyRemoveComplete(toys[0]);
			}
			
			if (settings['window'] != null && settings.window is HappyWindow) {
				settings.window.close();
			}
			
			if (App.user.mode == User.GUEST) {
				toy.mode = HappyToy.BLOCK;
			}
			
			if (toys.length == 0 && clearBttn) 
			{
				clearBttn.state = DISABLED;
				clearBttn.removeEventListener(MouseEvent.CLICK, onClear);
			}	
		}
		
		private function onAllToysRemove(bonus:Object = null):void 
		{
			var x:int = toyContainer.x + toyContainer.width / 2;
			var y:int = toyContainer.y + toyContainer.height / 2;
			var targetPoint:Point = new Point(x, y);
			BonusItem.takeRewards(bonus, clearBttn, 0, true, true);			
		}
		
		private function clearReaskWindow():void {
			var text:String = Locale.__e('flash:1418892037902');
			if (sid == 520) text = Locale.__e('flash:1423037791756');
			
			new SimpleWindow( {
				title:		settings.title,
				text:		text,
				dialog:		true,
				popup:		true,
				confirm:	function():void {
					clearReask = true;
					onClear();
				}
			}).show();
		}
		
		
		private var treeStates:Vector.<Bitmap> = new Vector.<Bitmap>;
		private function drawTree():void {
			clearTree();
			Load.loading(Config.getImage('happy/guest', info.view), onTreeLoad);			
		}
		private function onTreeLoad(data:Bitmap):void {
			
			addTreeState(data.bitmapData);
			
		}
		
		private function clearTree():void 
		{
			while (treeContainer.numChildren > 0) {
				var item:* = treeContainer.getChildAt(0);
				treeContainer.removeChild(item);
			}
		}
		
		protected function addTreeState(bmd:BitmapData):void 
		{
			var bitmap:Bitmap = new Bitmap(bmd);
			bitmap.smoothing = true;
			bitmap.x = (settings.width - bitmap.width) / 52 - 60;
			bitmap.y -= 50;
			treeContainer.addChild(bitmap);	
			
			if (mode != OWNER)
			{
				bitmap.y = 30;
				bitmap.x += 30;
			}
		}		
		
		private var items:Vector.<ToyItem> = new Vector.<ToyItem>;
		public function drawToyIcons():void {
			
			clearToyIcons();
			
			var rewards:Array = [];
			for (var s:String in info.outs) {
				rewards.push({sID:s, order:App.data.storage[s].order, price:App.data.storage[s].price});
			}
			rewards.sortOn('order', Array.NUMERIC);
			
			for (var i:int = 0; i < rewards.length; i++) {
				var item:ToyItem = new ToyItem(rewards[i].sID, this);
				if (i < 4) {
					item.x = toyBacking.x + 25;
					item.y = toyBacking.y + 15 + i * 125;
				} else {
					item.x = toyBacking.x + 145;
					item.y = toyBacking.y + 15 + (i - 4) * 125;
				}
				
				bodyContainer.addChild(item);
				items.push(item);
			}
		}
		
		private function clearToyIcons():void {
			while (items.length > 0) {
				var item:ToyItem = items.shift();
				item.dispose();
			}
		}
		
		private function onHelp(e:MouseEvent):void {
			new SimpleWindow( {
				title:		settings.title,
				text:		App.data.storage[sid].description,
				popup:		true
			}).show();
		}
		
		public function blockItems(value:Boolean = true):void {
			for (var i:int = 0; i < items.length; i++) {
				if (value) {
					items[i].bttn.state = Button.DISABLED;
				}else {
					items[i].checkButtonsStatus();
				}
			}
		}
		
		private var toys:Vector.<HappyToy> = new Vector.<HappyToy>;
		private function drawToys():void {
			clearToys();
			for (var s:* in settings.target.toys) {
				var toy:HappyToy = new HappyToy(s, settings.target.toys[s], this);
				toyContainer.addChild(toy);
				toys.push(toy);				
				
				if (App.user.mode == User.GUEST) {
					toy.mode = HappyToy.BLOCK;
				}
			}
			
			if (toys.length == 0 && clearBttn) 
			{
				clearBttn.state = DISABLED;
				clearBttn.removeEventListener(MouseEvent.CLICK, onClear);
			}	
		}
		private function clearToys():void {
			while (toys.length > 0) {
				var toy:HappyToy = toys.shift();
				toy.dispose();
			}
		}
		
		private var onAddCallback:Function;
		private var toy:HappyToy;
		public function startAddToy(sID:*, callback:Function = null):void {
			onAddCallback = callback;
			blockItems();
			addToy(sID, HappyToy.MOVE);
			helpStartGlow();
			
			App.self.addEventListener(MouseEvent.MOUSE_DOWN, onGlobalClick, false, 1000);
			App.self.addEventListener(MouseEvent.MOUSE_MOVE, onGlobalMove, false, 1000);
		}
		private function onGlobalClick(e:MouseEvent):void {
			App.self.removeEventListener(MouseEvent.MOUSE_DOWN, onGlobalClick);
			App.self.removeEventListener(MouseEvent.MOUSE_MOVE, onGlobalMove);
			
			if (!checkDecorate()) {
				blockItems(false);
				if (text && back) 
				{
					helpCont.removeChild(back);
					helpCont.removeChild(text);					
				}
			}
		}
		private function onGlobalMove(e:MouseEvent):void {
			if (toy) {
				toy.x = toyContainer.mouseX;
				toy.y = toyContainer.mouseY;
				
				if (isHitTest) {
					helpStopGlow();
					toy.filters = [new GlowFilter(0x00FF00)];
				}else {
					toy.filters = [new GlowFilter(0xFF0000)];
				}
			}
		}
		public function addToy(sID:*, mode:uint = 0):void {
			var happyToy:HappyToy = new HappyToy(0, {
				mID:	sID,
				x:		toyContainer.mouseX,
				y:		toyContainer.mouseY,
				uID:	App.user.id
			}, this);
			happyToy.mode = mode;
			toyContainer.addChild(happyToy);
			toy = happyToy;
		}
		
		private function checkDecorate():Boolean {
			toy.filters = null;
			if (isHitTest) {
				toys.push(toy);
				toy.mode = HappyToy.BLOCK;
				settings.target.saveToyAction(toy, onToySave);
			}else {
				toy.dispose();
			}
			
			toy = null;
			
			return isHitTest;
		}
		private function onToySave(toy:HappyToy, bonus:Object = null):void {
			toy.mode = (App.user.mode == User.GUEST) ? HappyToy.BLOCK : HappyToy.FREE;
			
			if (onAddCallback != null) {
				onAddCallback();
				onAddCallback = null;
			}
			
			blockItems(false);
			BonusItem.takeRewards(bonus, toy, 0, true, true);
		}
		public function onToyRemove(toy:HappyToy):void {
			toy.mode = HappyToy.BLOCK;
			
			settings.target.clearToyAction(toy, onToyRemoveComplete);
		}
		private function onToyRemoveComplete(toy:HappyToy, bonus:Object = null):void {
			toyContainer.removeChild(toy);
			toys.splice(toys.indexOf(toy), 1);
			BonusItem.takeRewards(bonus, toy, 0, true, true);
		}
		
		private var hitList:Array;
		private var hitIndex:int;
		private function get isHitTest():Boolean 
		{
			hitIndex = 0;
			while (hitIndex < treeContainer.numChildren) {
				var bitmap:* = treeContainer.getChildAt(hitIndex);
				if (bitmap is Bitmap) {
					if (bitmap.bitmapData.getPixel(treeContainer.mouseX - bitmap.x, treeContainer.mouseY - bitmap.y) > 0) {
						return true;
					}
				}
				
				hitIndex++;
			}			
			return false;
		}
		
		private var helpCont:Sprite;
		
		public var text:TextField = new TextField();
		public var back:Shape = new Shape();
		private function helpStartGlow():void {			
			if (!helpCont) {
				helpCont = new Sprite();
				bodyContainer.addChild(helpCont);
			}
			
			text = drawText(Locale.__e('flash:1425559829146'), {
				width:		220,
				fontSize:	26,
				color:		0xfafffb,
				borderColor:0x49360c,
				autoSize:	'center',
				textAlign:	'center',
				wrap:		true,
				multiline:	true
			});
			text.x = 20;
			text.y = 12;
			
			back.graphics.beginFill(0xffffff, 0.3);
			back.graphics.drawRoundRect(0, 0, 260, text.height + 30, 30);
			back.graphics.endFill();
			
			helpCont.addChild(back);
			helpCont.addChild(text);
			helpCont.alpha = 1;
			helpCont.x = (settings.width - helpCont.width)/2;
			helpCont.y = 100;
			
			helpGlowTick();
		}
		
		private function helpGlowTick():void {
			if (!helpCont) return;
			TweenLite.to(helpCont, 0.75, { alpha:1, onComplete:function():void {
				if (!helpCont) return;
				TweenLite.to(helpCont, 0.75, { alpha:0.5, onComplete:helpGlowTick });
			}});
		}
		
		private function helpStopGlow():void {
			if (helpCont && bodyContainer.contains(helpCont)) {
				bodyContainer.removeChild(helpCont);
				helpCont = null;
			}
		}
		
		override public function dispose():void {
			clearToys();
			clearToyIcons();
			
			if (showBttn) showBttn.removeEventListener(MouseEvent.CLICK, onShow);
			if (clearBttn) clearBttn.removeEventListener(MouseEvent.CLICK, onClear);
			helpBttn.removeEventListener(MouseEvent.CLICK, onHelp);
			
			super.dispose();
		}
	}
}

import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import ui.Hints;
import ui.UserInterface;
import wins.Window;

internal class ToyItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	private var count:uint;
	private var nodeID:String;
	private var type:uint = 0;
	
	public function ToyItem(sID:*, window:*) {
		
		this.sID = sID;
		this.item = App.data.storage[sID];
		this.window = window;
		
		if (currency == Stock.FANT) type = 1;
		
		bg = Window.backing(110, 110, 7, 'itemBacking');
		addChild(bg);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		drawBttn();
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		tip = function():Object {
			return {
				title: item.title,
				text: item.description
			}
		}
	}
	
	private function drawBttn():void {
		
		var bttnSettings:Object = {
			caption:'    ' + String(price),
			width:110,
			height:40,
			fontSize:26
		}
		
		if (type == 1) {
			bttnSettings['bgColor'] = [0xa8f84a, 0x74bc17];	//Цвета градиента
			bttnSettings['borderColor'] = [0xffffff, 0xffffff];	//Цвета градиента
			bttnSettings['bevelColor'] = [0xc8fa8f, 0x5f9c11];
			bttnSettings['fontColor'] = 0xcaf993;
			bttnSettings['fontBorderColor'] = 0x3c6809;
			
		}
		
		bttn = new Button(bttnSettings);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 12;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		addChild(bttn);
		
		var icon:Bitmap
		if (type == 1) {
			icon = new Bitmap(UserInterface.textures.fantsIcon, 'auto', true);
		}else {
			icon = new Bitmap(UserInterface.textures.coinsIcon, 'auto', true);
		}
		icon.scaleX = icon.scaleY = 0.75;
		icon.x = 20;
		icon.y = 2;
		bttn.addChild(icon);		
		checkButtonsStatus();
	}
	
	public function checkButtonsStatus():void {
		for (var s:* in item.price) break;
		
		if (App.user.stock.canTake(item.price)) {
			if (int(s) != Stock.FANT && !window.settings.target.canDecorate()) {
				bttn.state = Button.DISABLED;
			}else {
				bttn.state = Button.NORMAL;
			}
		}else {
			bttn.state = Button.DISABLED;
		}
	}
	
	private function onClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		window.startAddToy(sID, onAddComplete);
	}
	
	private function onAddComplete():void {
		App.user.stock.take(currency, price);
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(currency, price, new Point(X, Y), false, App.self.tipsContainer);
		
		if (currency != Stock.FANT) window.settings.target.addGuest(App.user.id);
	}	
	
	private function onLoad(data:Bitmap):void {
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = false;
		
		if (bitmap.width > bg.width * 0.9) {
			bitmap.width = bg.width * 0.9;
			bitmap.scaleY = bitmap.scaleX;
		}
		if (bitmap.height > bg.height * 0.9) {
			bitmap.height = bg.height * 0.9;
			bitmap.scaleX = bitmap.scaleY;
		}
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 - 10;
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
		if (parent) parent.removeChild(this);
	}
	
	
	private function get price():int {
		for (var s:* in item.price) break;
		return item.price[s];
	}
	public function get currency():int {
		for (var s:* in item.price) break;
		return int(s);	
	}
}