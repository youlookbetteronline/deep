package wins.happy 
{
	import wins.happy.HappyToy;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.SimpleButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import units.Happy;
	import wins.AskWindow;
	import wins.SimpleWindow;
	import wins.Window;

	
	public class HappyGuestWindow extends Window 
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
		
		public function HappyGuestWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] || 730;
			settings['height'] = settings['height'] || 610;
			settings['title'] = settings.target.info.title;
			settings['hasPaginator'] = false;
			settings['background'] = 'questBacking';
			
			sid = settings.target.sid;
			info = App.data.storage[sid];
			mode = settings['mode'] || OWNER;
			
			settings['text'] = info['text5'];// Locale.__e('flash:1418822910726')
			if (sid == 1122) settings['text'] = Locale.__e('flash:1423037777907');
			if (sid == 1263) settings['text'] = Locale.__e('flash:1425480719820');
			
			super(settings);
		}
		
		override public function drawBody():void {
			
			exit.x += 0;
			exit.y -= 18;
			
			titleLabel.y -= 10;
			
			var effect:Bitmap = Window.backingShort(400, 'magicFog');
			effect.x = 0;
			effect.y = 0;
			bodyContainer.addChild(effect);
			
			var glow:Bitmap = new Bitmap();
			glow.scaleX = glow.scaleY = 5;
			glow.alpha = 0.5;
			glow.x = effect.x + (effect.width - glow.width) / 2;
			glow.y = effect.y + (effect.height - glow.height) / 2;
			bodyContainer.addChild(glow);
			
			// View
			
			if (mode == OWNER) {
				var descBacking:Shape = new Shape();
				bodyContainer.addChild(descBacking);
				
				var descLebelText:String = info['text3'];
				var descLabelX:int = 380;
				var descLabelWidth:int = 310;
				if (sid == 1122) {
					descLebelText = Locale.__e('flash:1423037757361');
					descLabelX = 410;
					descLabelWidth = 270;
				}
				if (sid == 1263) {
					descLebelText = Locale.__e('flash:1425481811842');
					descLabelX = 410;
					descLabelWidth = 270;
				}
				
				var descLabel:TextField = drawText(descLebelText, {//flash:1418735216505
					textAlign:		'center',
					autoSize:		'center',
					fontSize:		24,
					color:			0xfffcff,
					borderColor:	0x5b3300
				});
				descLabel.width = descLabelWidth;
				descLabel.wordWrap = true;
				descLabel.x = descLabelX;
				descLabel.y = 50;
				bodyContainer.addChild(descLabel);
				
				descBacking.graphics.beginFill(0xd1b665, 1);
				descBacking.graphics.drawRoundRect(0, 0, descLabel.width + 30, descLabel.height + 30 + 40, 60, 60);
				descBacking.graphics.endFill();
				descBacking.x = descLabel.x + (descLabel.width - descBacking.width) / 2;
				descBacking.y = descLabel.y - 15;
				
				if (!App.isSocial('SP')) {
					showBttn = new Button( {
						width:		200,
						height:		58,
						caption:	Locale.__e('flash:1396608121799')
					});
					showBttn.x = descBacking.x + (descBacking.width - showBttn.width) / 2;
					showBttn.y = descBacking.y + descBacking.height - showBttn.height / 2;
					bodyContainer.addChild(showBttn);
					showBttn.addEventListener(MouseEvent.CLICK, onShow);
				}
				
				
				var upCont:Sprite = new Sprite();
				bodyContainer.addChild(upCont);
				
				var avaBack:Bitmap = new Bitmap(Window.textures.referalRoundBacking, 'auto', true);
				avaBack.scaleX = avaBack.scaleY = 0.6;
				avaBack.x = -8;
				avaBack.y = 6;
				upCont.addChild(avaBack);
				
				var avaImage:Bitmap = new Bitmap(UserInterface.textures.friendSlot, 'auto', true);
				upCont.addChild(avaImage);
				upCont.x = 500;
				upCont.y = descBacking.y + descBacking.height + 40;
				
				var text:String = Locale.__e('flash:1382952380289');
				
				inviteBttn = new Button( {
					width:		120,
					height:		64,
					caption:	text,
					multiline:	true,
					textAlign:	'center',
					textLeading:-3,
					fontSize:	23
				});
				inviteBttn.x = upCont.x + (upCont.width - inviteBttn.width) / 2;
				inviteBttn.y = upCont.y + upCont.height + 15;
				bodyContainer.addChild(inviteBttn);
				inviteBttn.addEventListener(MouseEvent.CLICK, onInvite);
				
				clearBttn = new Button( {
					width:		120,
					height:		44,
					caption:	Locale.__e('flash:1418821499681'),
					fontSize:	22,
					bgColor:				[0xf59656,0xef4e31],	//Цвета градиента
					borderColor:			[0xf59656,0xef4e31],	//Цвета градиента
					bevelColor:				[0xfec29e, 0xb32e0d],
					fontColor:				0xfffeff,				//Цвет шрифта
					fontBorderColor:		0x6e3019
				});
				clearBttn.x = inviteBttn.x + (inviteBttn.width - clearBttn.width) / 2;
				clearBttn.y = settings.height - clearBttn.height - 60;
				bodyContainer.addChild(clearBttn);
				clearBttn.addEventListener(MouseEvent.CLICK, onClear);
				
			}else if (mode == GUEST) {
				
				toyBacking = backing(300, 530, 50, 'shopBackingSmall2');
				toyBacking.x = settings.width - toyBacking.width - 35;
				toyBacking.y = 20;
				
				var descGuestLabelText:String = settings.text;
				
				
				var descGuestLabel:TextField = drawText(descGuestLabelText, {
					width:			300,
					textAlign:		'center',
					fontSize:		24,
					color:			0xf8fdff,
					borderColor:	0x4a3b14
				});
				descGuestLabel.x = toyBacking.x + (toyBacking.width - descGuestLabel.width) / 2;;
				descGuestLabel.y = -10;
				
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
			
			if (mode == GUEST) {
				drawToyIcons();
			}
			
			drawToys();
			
			// Help
			
			//helpBttn = new ImageButton(Window.textures.helpButton);
			//helpBttn.x = -2;
			//helpBttn.y = -38;
			//bodyContainer.addChild(helpBttn);
			//helpBttn.addEventListener(MouseEvent.CLICK, onHelp);
		}
		
		private function onShow(e:MouseEvent):void {
			var type:uint = WallPost.HAPPY_SHARE;
			if (sid == 1122) type = WallPost.HAPPY_VALENTINE_SHARE;
			
			WallPost.makePost(type, { sid:sid, uid:App.user.id, bmd:getBitmapData() } );
			showBttn.visible = false;
		}
		
		private function onInvite(e:MouseEvent):void {
			close();
			
			var descText:String = info['text4'];
			if (sid == 1122) descText = Locale.__e("flash:1423037757361");
			if (sid == 1263) descText = Locale.__e("flash:1425481811842");
			
			new AskWindow(AskWindow.MODE_INVITE, {
				target:settings.target,
				title:Locale.__e('flash:1382952380197'), 
				friendException:function(... args):void {
					trace(args);
				},
				inviteTxt:Locale.__e("flash:1395846352679"),
				desc:descText,
				noAllFriends:true,
				bmd:getBitmapData()
			} ).show();
		}
		private function getBitmapData():BitmapData {
			var bmd:BitmapData;
			if (sid == 1122) {
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
			
			settings.target.clearToyAction(null, null, true);
			while (toys.length > 0) {
				onToyRemoveComplete(toys[0]);
			}
			
			if (settings['window'] != null && settings.window is HappyWindow) {
				settings.window.close();
			}
		}
		private function clearReaskWindow():void {
			var text:String = Locale.__e('flash:1418892037902');
			if (sid == 1122) text = Locale.__e('flash:1423037791756');
			
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
		
		
		private function drawTree():void {
			clearTree();
			
			Load.loading(Config.getImage('happy/guest', settings.target.view), onTreeLoad);
		}
		private function onTreeLoad(data:Bitmap):void {
			addTreeState(data.bitmapData);
		}
		private function clearTree():void {
			while (treeContainer.numChildren > 0) {
				var item:* = treeContainer.getChildAt(0);
				treeContainer.removeChild(item);
			}
		}
		private function addTreeState(bmd:BitmapData):void {
			var bitmap:Bitmap = new Bitmap(bmd);
			bitmap.smoothing = true;
			bitmap.x = (500 - bitmap.width) / 2;
			bitmap.y = settings.height - bitmap.height;
			treeContainer.addChild(bitmap);
		}
		
		
		private var items:Vector.<ToyItem> = new Vector.<ToyItem>;
		public function drawToyIcons():void {
			
			clearToyIcons();
			
			var rewards:Array = [];
			for (var s:String in info.outs) {
				rewards.push({sID:s, order:App.data.storage[s].order});
			}
			rewards.sortOn('order', Array.NUMERIC);
			
			for (var i:int = 0; i < rewards.length; i++) {
				var item:ToyItem = new ToyItem(rewards[i].sID, this);
				item.x = toyBacking.x + 16 + (i % 2) * 140;
				item.y = toyBacking.y + 10 + Math.floor(i / 2) * 130;
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
			//BonusItem.takeRewards(bonus, toy, 0, true, true);			//D
		}
		public function onToyRemove(toy:HappyToy):void {
			toy.mode = HappyToy.BLOCK;
			
			settings.target.clearToyAction(toy, onToyRemoveComplete);
		}
		private function onToyRemoveComplete(toy:HappyToy):void {
			toyContainer.removeChild(toy);
			toys.splice(toys.indexOf(toy), 1);
		}
		
		private var hitList:Array;
		private var hitIndex:int;
		private function get isHitTest():Boolean {
			/*hitIndex = 0;
			hitList = treeContainer.getObjectsUnderPoint(new Point(treeContainer.mouseX, treeContainer.mouseY));
			while (hitIndex < hitList.length) {
				if (hitList[hitIndex] is Bitmap) {
					if (hitList[hitIndex].bitmapData.getPixel(treeContainer.mouseX, treeContainer.mouseY) > 0) {
						return true;
					}
				}
				
				hitIndex++;
			}
			
			return false;*/
			
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
		
		///
		private var helpCont:Sprite;
		private function helpStartGlow():void {
			if (!helpCont) {
				helpCont = new Sprite();
				bodyContainer.addChild(helpCont);
			}
			
			var text:TextField = drawText(Locale.__e('flash:1425559829146'), {
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
			
			var back:Shape = new Shape();
			back.graphics.beginFill(0xffffff, 0.3);
			back.graphics.drawRoundRect(0, 0, 260, text.height + 30, 30);
			back.graphics.endFill();
			
			helpCont.addChild(back);
			helpCont.addChild(text);
			helpCont.alpha = 1;
			helpCont.x = 75;
			helpCont.y = (settings.height - helpCont.height) / 2 + 15;
			
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
		///
		override public function dispose():void {
			clearToys();
			clearToyIcons();
			
			if (showBttn) showBttn.removeEventListener(MouseEvent.CLICK, onShow);
			if (clearBttn) clearBttn.removeEventListener(MouseEvent.CLICK, onClear);
			//helpBttn.removeEventListener(MouseEvent.CLICK, onHelp);
			
			super.dispose();
		}
	}

}


import buttons.Button;
import buttons.ImageButton;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
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
		//this.count = obj.c;
		//this.nodeID = obj.id;
		this.item = App.data.storage[sID];
		this.window = window;
		//type = obj.t;
		
		if (currency == Stock.FANT) type = 1;
		
		bg = Window.backing(130, 120, 20, 'itemBacking');
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
		for (var s:* in item.price)
			break;
		
		if (App.user.stock.canTake(item.price))
		{
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
	private function get currency():int {
		for (var s:* in item.price) break;
		return int(s);
	}
}