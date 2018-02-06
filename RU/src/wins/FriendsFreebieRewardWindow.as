package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;

	public class FriendsFreebieRewardWindow extends Window
	{
		public var items:Array = new Array();
		private var back:Bitmap;
		private var okBttn:Button;
		public var currentDayItem:FriendRewardItem;
		public var friendsCount:int = 6;
		public var giftStage:int = 3;
		
		public function FriendsFreebieRewardWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 				= 569;
			settings['height'] 				= 325;
			settings['title'] 				= Locale.__e("flash:1427277406259");
			settings['hasPaginator'] 		= false;
			settings['content'] 			= [];
			settings['fontSize'] 			= 48;
			settings['shadowBorderColor']   = 0x342411;
			settings['fontBorderSize'] 		= 4;
			settings['hasExit'] 			= false;
			settings['faderClickable'] 		= false;
			
			var defContent:Array = 
			[ { bonus: { 3:5 }, stage:1,f:5, desc:'' },
			 { bonus: { 4:5 }, stage:2,f:10, desc:'' },
			 { bonus: { 5:10 }, stage:3,f:15, desc:'' },
			 { bonus: { 6:15 }, stage:4,f:20, desc:'' },
			 { bonus: { 10:13 }, stage:5,f:30, desc:'' } ];
			
			for each(var item:Object in defContent)
			{
				settings.content.push(item);
			}
			
			super(settings);
		}
		
		override public function drawTitle():void 
		{
			var bk1:Shape = new Shape();
			bk1.graphics.beginFill(0xe8c38e);
			bk1.graphics.drawRoundRect(0, 0, 490, 115, 50, 50);
			bk1.graphics.endFill();
			bodyContainer.addChild(bk1);
			bk1.x = (settings.width - bk1.width) / 2;
			bk1.y = 30;
			
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
			titleLabel.y = +25;
			bodyContainer.addChild(titleLabel);
			//drawMirrowObjs('diamondsTop', titleLabel.x - 5, titleLabel.x + titleLabel.width + 5, titleLabel.y , true, true);
			//drawMirrowObjs('diamondsTop', settings.width - 30, titleLabel.x + titleLabel.width + 5, titleLabel.y , true, true);
			
			var descLabel:TextField = Window.drawText(Locale.__e("flash:1427277551930"), {
				fontSize	:28,
				color		:0xFFFFFF,
				borderColor	:0x8a4413,
				textAlign	:"center"
			});
			descLabel.width = descLabel.textWidth + 20;
			descLabel.x = titleLabel.x + (titleLabel.width - descLabel.width) / 2;
			descLabel.y = 15 + 35;
			bodyContainer.addChild(descLabel);
		}
		
		override public function drawBackground():void {
			back = Window.backing(settings.width, settings.height, 20, 'buildingBacking');
			layer.addChild(back);
			back.x = (settings.width - back.width) / 2;
			decorateWith('storageWoodenDec');
			titleLabel.y = back.y - titleLabel.height / 2;
		}
		
		override public function drawBody():void {
			Load.loading(Config.getImage('promo/images', 'crystals'), function(data:Bitmap):void {
					var image:Bitmap = new Bitmap(data.bitmapData);
					headerContainer.addChildAt(image, 0);
					image.x = settings.width / 2 - image.width / 2;
					image.y = -80;
			});
			
			drawItems();
			
			var maxFriends:int = 0;
			for (var i:* in settings.content) {
				if (settings.content[i].stage == giftStage) {
					maxFriends = settings.content[i].f;
				}
			}
			var bar:WinBar = new WinBar( { val:friendsCount, max:maxFriends } );
			bodyContainer.addChild(bar);
			bar.x = (settings.width - bar.width) / 2;
			bar.y = 245;
			okBttn = new Button( {
				caption:Locale.__e('flash:1382952380197'),
				fontSize:28,
				width:167,
				height:48
			});
			
			bodyContainer.addChild(okBttn);
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height + 15 - 45;
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
		}
		
		private function onOkBttn(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			e.currentTarget.state = Button.DISABLED
			//take();
		}
		
		private var container:Sprite;
		private function drawItems():void {
			
			var bk2:Bitmap = Window.backing(534, 143, 50, 'buildingDarkBacking');
			bodyContainer.addChild(bk2);
			bk2.x = (settings.width - bk2.width) / 2;
			bk2.y = 87;
			container = new Sprite();
			
			var X:int = 0;
			var Y:int = 10;
			
			for (var i:int = 0; i < 5; i++) {
				var item:FriendRewardItem = new FriendRewardItem(settings.content[i], this);
				container.addChild(item);
				item.x = X;
				item.y = Y;
				
				X += item.bg.width + 12;
			}
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2 + 5;
			container.y = 100;
		}
		
		public function take():void 
		{
/*			Post.send( {
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
				
				App.user.stock.addAll(data.bonus);
				
				for (var _sid:* in data.bonus) {
					var item:BonusItem = new BonusItem(_sid, data.bonus[_sid]);
					var point:Point = Window.localToGlobal(currentDayItem);
					point.y += 80;
					item.cashMove(point, App.self.windowContainer);
				}
				
				setTimeout(close, 300);
			});*/
		}
		
		override public function dispose():void {
			while (container.numChildren > 0) {
				var _item:* = container.getChildAt(0);
				if (_item is FriendRewardItem) _item.dispose();
				container.removeChild(_item);
			}
			okBttn.removeEventListener(MouseEvent.CLICK, onOkBttn);
			
			super.dispose();
		}
	}
}	


import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import ui.UserInterface;
import wins.FriendsRewardWindow;
import wins.Window;
	

internal class FriendRewardItem extends LayerX {
	
	private var item:Object;
	public var bg:Bitmap;
	public var win:FriendsRewardWindow;
	private var title:TextField;
	private var sID:uint;
	private var count:uint;
	private var bitmap:Bitmap;
	private var status:int = 0;
	public var itemDay:int;
	private var check:Bitmap = new Bitmap(Window.textures.checkMark);
	private var layer:LayerX;
	private var intervalPluck:int;
	public var isCurrent:Boolean = false;
	
	public function FriendRewardItem(item:Object, win:FriendsRewardWindow) {
		
		this.win = win;
		this.item = item;
		bg = new Bitmap(Window.textures.instCharBacking);
		bg.scaleX = bg.scaleY = 0.8;
		bg.smoothing = true;
		
		if (item.stage > win.giftStage) {
			status = 2;
		}
		if (item.stage < win.giftStage) {
			status = 0;
		}
		
		if (item.stage == win.giftStage) {
			if (win.friendsCount >= item.f) {
				status = 1
			}
			isCurrent = true;
		}
		
		addChild(bg);
		layer = new LayerX();
		addChild(layer);
		bitmap = new Bitmap();
		if (isCurrent) {
			var gf:GlowEffect = new GlowEffect();
			gf.scaleX = gf.scaleY = 0.6;
			gf.x = bg.width / 2;
			gf.y = bg.height / 2;
			layer.addChild(gf);
			gf.start();
		}
		layer.addChild(bitmap);


		
		if (item == null) return;
		
		for (var _sID:* in item.bonus) break;
			sID = _sID;
		count = item.bonus[_sID];
		
		drawTitle();
		drawCount();		
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), function(data:Bitmap):void {
			bitmap.bitmapData = data.bitmapData;
			var needScale:Number = Math.max(data.width / bg.width, data.height / bg.height);
			if (needScale > 1){
				var scale:Number = 1 / needScale;
				var matrix:Matrix = new Matrix();
				matrix.scale(scale, scale);
				var smallBMD:BitmapData = new BitmapData(data.width * scale, data.height * scale, true, 0x000000);
				smallBMD.draw(data, matrix, null, null, null, true);
				bitmap.bitmapData = smallBMD;
			}
			if(sID == Stock.EXP)
				bitmap.scaleX = bitmap.scaleY = 0.8;
			else
				bitmap.scaleX = bitmap.scaleY = 0.9;
			bitmap.smoothing = true;
			bitmap.x = (bg.width - bitmap.width) / 2;
			bitmap.y = (bg.height - bitmap.height) / 2;
			if (status == 1) startPluck();
			if (sID == Stock.FANT) return;
		});
		drawMark();
		if (status == 2) {
			UserInterface.effect(bg, 0, 0.4);
		}
	}
	
	private function drawMark():void 
	{
		if (status == 0 && !isCurrent){
			UserInterface.effect(bg, 0, 0.8);
			addChild(check);
		}
		check.x = (bg.width - check.width) / 2;
		check.y = (bg.height - check.height) / 2;
	}
	
	private function drawTitle():void
	{
		title = Window.drawText(Locale.__e('flash:1427276489992',[item.f]), {
			color:0xffffff,
			borderColor:0x682f1e,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.y = -15;
		title.x = (bg.width - title.width) / 2;
		addChild(title)
	}
	
	private function drawCount():void
	{
		var countText:TextField = Window.drawText("x" + String(count), {
			color:0xffffff,
			borderColor:0x682f1e,
			textAlign:"left",
			autoSize:"center",
			fontSize:28,
			textLeading:-6,
			multiline:true
		});
		countText.wordWrap = true;
		countText.width = countText.textWidth + 5;
		countText.y = bg.height - countText.height;
		countText.x = (bg.width) / 2;
		addChild(countText)
		
	}
	
	public function startPluck():void {
		intervalPluck = setInterval(randomPluck, Math.random()* 5000 + 2000);
	}
	
	private function randomPluck():void
	{
		layer.pluck(30, layer.width / 2, layer.height / 2 + 50);
	}
	
	public function dispose():void {
		clearInterval(intervalPluck);
		layer.pluckDispose();
	}
}

internal class WinBar extends Sprite {
	
	private var back:Bitmap = new Bitmap(Window.textures.prograssBarBacking);
	private var viewVal:Bitmap = new Bitmap(Window.textures.progressBar);
	private var label:TextField = new TextField();;
	private var currVal:int = 0;
	private var maxVal:int = 100;
	
	public function WinBar(params:Object):void {
		currVal = params.val || 0;
		maxVal = params.max || 100;

		label = Window.drawText(currVal + '/' + maxVal,
			{
				color:0xffffff,
				borderColor:0x644b2b,
				fontSize:32,
				width:back.width,
				textAlign:"center"
			});
		
		addChild(back);
		addChild(viewVal);
		addChild(label);
		viewVal.x = 8;
		viewVal.y = 5;
		setValue(currVal);
	}
	
	public function setValue(val:int = 0):void {
		currVal = Math.min(currVal,maxVal);
		label.text = currVal  + '/' + maxVal;
		var ht:int = back.height;
		var wd:int = int(back.width * (currVal / maxVal));
		
		var shape:Shape = new Shape();
		addChild(shape);
		shape.graphics.beginFill(0xff0000, 1);
		shape.graphics.moveTo(0, 0);
		shape.graphics.lineTo(wd, 0);
		shape.graphics.lineTo(wd, ht);
		shape.graphics.lineTo(0, ht);
		shape.graphics.lineTo(0, 0);
		shape.graphics.endFill();
		
		shape.x = viewVal.x;
		shape.y = viewVal.y;
		viewVal.mask = shape;
	}
}

internal class GlowEffect extends Sprite {
	private var glowBitmap:Bitmap = new Bitmap(Window.textures.glowingBackingNew);
	private var glowCont:Sprite = new Sprite();
	
	public function GlowEffect():void {
		addChild(glowCont);
		glowBitmap.x = -glowBitmap.width / 2;
		glowBitmap.y = -glowBitmap.height / 2;
		glowCont.addChild(glowBitmap);
	}
	
	public function start():void {
		var that:GlowEffect = this;
		
		App.self.setOnEnterFrame(function():void {
			if (that && that.parent) {
				glowCont.rotation++;
			}else {
				App.self.setOffEnterFrame(arguments.callee);
			}
		});
	}
	
}