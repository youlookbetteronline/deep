package wins 
{
	import buttons.Button;
	import core.Post;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	//import FriendRewardItem;
	/**
	 * ...
	 * @author ...
	 */
	public class FriendRewardWindow extends Window
	{
		private var background:Bitmap;
		private var guestIcon:Bitmap;
		private var priceBttn:Button;
		private var reward:Object;
		public var count:int;
		public var sid:int;
		
		public function FriendRewardWindow(settings:*=null,ID:*=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['width'] = 244;
			settings['height'] = 212;
			settings['title'] = Locale.__e('flash:1382952380000');
			settings['background'] = 'workerHouseBacking';
			settings['hasPaginator'] = false;
			settings['titlePading'] = 70;
			settings['hasExit'] = false;
			settings['popup'] = true;
			settings['forcedClosing'] = true;
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			settings['ID'] = ID || '';
			//reward = settings;/*||App.user.currentGuestReward*/;
			super(settings);
		}
		
		override public function drawBackground():void 
		{
			background = backing(settings.width, settings.height , 50, 'workerHouseBacking');
			var background2:Bitmap  = backing2(settings.width - 60, settings.height - 54, 40, 'capsuleWindowBackingPaperUp', 'capsuleWindowBackingPaperDown');

			background2.x = background.x + (background.width - background2.width) / 2;
			background2.y = background.y + (background.height - background2.height) / 2;
			layer.addChildAt(background, 0);
			//layer.addChildAt(background2, 1);
		}
		
		override public function drawBody():void 
		{
			//var background2:Bitmap  = backing2(settings.width - 70, settings.height - 64, 30, 'capsuleWindowBackingPaperUp', 'capsuleWindowBackingPaperDown');
			var background2:Bitmap  = Window.backing(settings.width - 70, settings.height - 64, 30, 'paperClear');
				
			background2.x = (settings.width - background2.width) / 2;
			background2.y = (settings.height - background2.height) / 2 - 28;
			bodyContainer.addChildAt(background2, 0);
			
			//titleLabel.x = titleLabel.x + 20;
			
			/*guestIcon  = new Bitmap(UserInterface.textures.guestAction);
			guestIcon.width = 40;
			guestIcon.scaleY = guestIcon.scaleX;
			guestIcon.smoothing = true;
			guestIcon.x = titleLabel.x - guestIcon.width;
			guestIcon.y = titleLabel.y+5;
			headerContainer.addChild(guestIcon);*/
			
			//drawDesc();
			drawReward();
			drawButton();
		}
		
		private function drawDesc():void 
		{
			var desc:TextField = Window.drawText(Locale.__e('flash:1423136283210'), {
				color:			0xfcd25c,
				borderColor:	0x6f4302,
				fontSize:		26,
				width: 			180
			});
		
		desc.x = (settings.width - desc.textWidth) / 2;
		desc.y = 0;
		bodyContainer.addChild(desc);
		}
		
		private function drawReward():void 
		{

		var item:FriendRewardItem = new FriendRewardItem(settings,this);
		bodyContainer.addChild(item);
		item.x = (settings.width - item.width) / 2;
		item.y = (settings.height - item.height) / 2 -15;
		item.scaleX = item.scaleY = 1; 
		
			this.sid = item.sID; 
			this.count = item.count;
			
		}
		
		private function drawButton():void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379737"),
				fontSize:24,
				width:136,
				height:43,
				hasDotes:false
			};
			//flash:1423136283210
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = (settings.height - priceBttn.height) - 15;
			priceBttn.addEventListener(MouseEvent.CLICK, take);
			
		}
		
		/*private function takeReward(e:MouseEvent = null):void 
		{
			
			var item:BonusItem = new BonusItem(sid, count);
			var point:Point = Window.localToGlobal(e.currentTarget);
			item.cashMove(point, App.self.windowContainer);
			App.user.stock.add(sid, count);
			close();
		}*/
			public function take(target:* = null):void {
			priceBttn.mode = Button.DISABLED;
			var sendObject:Object = {
				ctr:'freebie',
				act:'take',
				uID:App.user.id,
				fID:/*(App.user.freebie.status+1)//*/settings.ID
			}
			
			Post.send( sendObject, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				App.user.stock.addAll(data.bonus);
				BonusItem.takeRewards(data.bonus, (target != null) ? target : this);
				App.user.freebie.status++;
				
				if (App.user.freebie.status < FreebieWindow.freebieMaxValue) {
					//drawState();
					close();
				}else {
					close();
					App.ui.rightPanel.hideFreebie();
				}
			});
			
		}
	}

}
import core.Load;
import core.Size;
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
import wins.FriendRewardWindow;
import wins.Window;
	

internal class FriendRewardItem extends LayerX {
	
	private var item:Object;
	public var bg:Bitmap;
	public var win:FriendRewardWindow;
	private var title:TextField;
	public var sID:uint;
	public var count:uint;
	private var bitmap:Bitmap;
	private var status:int = 0;
	public var itemDay:int;
	private var check:Bitmap = new Bitmap(Window.textures.checkMark);
	private var layer:LayerX;
	private var intervalPluck:int;
	public var isCurrent:Boolean = false;
	
	public function FriendRewardItem(item:Object, win:FriendRewardWindow,numb:int = 0) {
		
		this.win = win;
		this.item = item;
		bg = new Bitmap(Window.textures.clearBubbleBacking);
		bg.scaleX = bg.scaleY = 1;
		bg.smoothing = true;
		
		if (numb > App.user.freebie.status) {
			status = 2;
		}
		if (numb < App.user.freebie.status) {
			status = 0;
		}
		
		if (numb == App.user.freebie.status) {
		//	if (win.friendsCount >= item.f) {
				status = 1
		//	}
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
			/*if(sID == Stock.EXP)
				//bitmap.scaleX = bitmap.scaleY = 0.8;
				Size.size(bitmap, 80, 80);
				
			else*/
			Size.size(bitmap, 70, 70);
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
			//addChild(check);
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
			textLeading:-6
		//	multiline:true
		});
	//	countText.wordWrap = true;
		countText.width = countText.textWidth + 15;
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