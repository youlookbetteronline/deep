package wins.elements {

import com.greensock.TweenMax;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;
import wins.SimpleWindow;
public class GuestRewardItem extends Sprite {
	private var window:Window;
	public var id:int;
	public var count:int;
	public var sid:int;
	private var _height:Number;
	private var _width:Number;
	private var canGlowing:Boolean = true;
	private var current:Boolean = false;
	private var background:Bitmap;
	private var guestGlow:Bitmap;
	private var guestIcon:Bitmap;
	private var bitmap:Bitmap = new Bitmap();
	private var mark:Bitmap = new Bitmap();
	
	public var reward:Object = { };
	public function GuestRewardItem(id:int, reward:Object, window:Window, current:Boolean = false,doGlow:Boolean = false, showInfo:Boolean = true) {
		this.window = window;
		this.current = current;
		this.showInfo = showInfo;
		update(id, reward, doGlow);
		
	}
	
	
	public function update(id:int, reward:Object, doGlow:Boolean = false):void
	{
		this.reward = reward;
		this.id = id;
		for (var sid:* in reward.outs){
		this.sid = sid; 
		this.count = reward.outs[sid];
		break
		}
		clearBody();
		drawBody();
		
		if (doGlow) glowing();
	}
	
	private function clearBody():void 
	{
		if (background && background.parent)
			background.parent.removeChild(background);
		background = null;
		
		if (bitmap && bitmap.parent)
			bitmap.parent.removeChild(bitmap);
		bitmap = new Bitmap();
		
		if (guestGlow && guestGlow.parent)
			guestGlow.parent.removeChild(guestGlow);
		guestGlow = null;
		guestGlow = new Bitmap();
		
		if (guestIcon && guestIcon.parent)
			guestIcon.parent.removeChild(guestIcon);
		guestIcon = null;
		guestIcon = new Bitmap();
		
		/*if (takeBttn) {
			takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
			takeBttn.dispose();
		}
		takeBttn = null;
		
		if (rewardCont && rewardCont.parent)
			rewardCont.parent.removeChild(rewardCont);
		rewardCont = null;
		rewardCont = new Sprite();
		
		if (rewardCont && rewardCont.parent)
			rewardCont.parent.removeChild(rewardCont);
		rewardCont = null;
		rewardCont = new Sprite();*/
	}
	
	private function drawBody():void 
	{
		
		drawRewardInfo();
		if (showInfo) 
		{
		drawInfo();
		
		}
		
	}
	private var offset:int = 30;
	private var showInfo:Boolean;
	private function drawRewardInfo():void 
	{
		/*if (reward.count<=App.user.stock.data[Stock.COUNTER_GUESTFANTASY]||current) 
		{
		background 	= new Bitmap(Window.textures.instCharBacking);	
		
		}else 
		{*/
		background 	= new Bitmap(Window.textures.clearBubbleBacking);
		//}
		
		guestGlow  = new Bitmap(Window.textures.glowingBackingNew);
		guestGlow.scaleX = guestGlow.scaleY = 0.6;
		background.y = 40;
		//background = Window.backing2(720, 130, 44, 'storageBackingTop', 'storageBackingBot')
		//background = Window.backing(700, 110, 44, 'shopDarkBacking2'); //бэк верхний
	//	background.alpha = 0.7;
	//	background.scaleY = 1.2;
		background.smoothing = true;
		addChild(background);
		addChild(guestGlow);
		guestGlow.x = background.x -guestGlow.width / 2 + background.width / 2;
		guestGlow.y = background.y -guestGlow.height / 2 + background.height / 2;
		/*if (sid!=Stock.FANTASY) 
		{*/
		Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), onLoadImage);
		
		/*}
		else 
		{
			bitmap   = new Bitmap(UserInterface.textures.energyBolt);
		
				if (bitmap.width>background.width-offset) 
				{
				bitmap.width = 	background.width - offset;
				bitmap.scaleY = bitmap.scaleX;
				
				}
				if (bitmap.height>background.height-offset) 
				{
				bitmap.height = 	background.height -offset;
				bitmap.scaleX = bitmap.scaleY;
				
				}
				bitmap.x =background.x+ (background.width-bitmap.width)/2
				bitmap.y =background.y+ (background.height-bitmap.height)/2
				//bitmap.x = (settings.width - bitmap.width) / 2;
				//bitmap.y = background.y + (background.height - bitmap.height) / 2 - 5;
				bitmap.smoothing = true;
		}*/
		addChild(bitmap);
		for each(var counts:* in reward.outs)
		break
		var count:TextField = Window.drawText('x'+counts, {
				color:			0xffffff,
				borderColor:	0x654317,
				fontSize:		26
			});
		guestIcon.x = background.x + (background.width - guestIcon.width - count.textWidth) / 2;
		count.width = count.textWidth + 10;
		count.x =background.x+ (background.width-count.textWidth)
		count.y = background.y + (background.height - count.height) +6;
		addChild(count);
		
		
	//	bitmap.y = background.y;
		mark = new Bitmap(Window.textures.checkMarkBig);
		
		mark.x =background.x+ (background.width-bitmap.width)/2
		mark.y =background.y+ (background.height-bitmap.height)/2
			
		addChild(mark);
		
		if (reward.count<=App.user.stock.data[Stock.COUNTER_GUESTFANTASY] || current) 
		{
			if (current) 
			{
				guestGlow.alpha = 1;
				mark.alpha = 0;
			}else 
			{
				mark.alpha = 1;
				guestGlow.alpha = 0;
			}
			
			
		}else 
		{
			mark.alpha = 0;
			guestGlow.alpha = 0;
		}
		
	}
	
	private function onLoadImage(data:Object):void
		{
			
				bitmap.bitmapData = data.bitmapData;
				//bitmap.scaleX = bitmap.scaleY = 1.2;
					
				if (bitmap.width>background.width-offset) 
				{
				bitmap.width = 	background.width - offset;
				bitmap.scaleY = bitmap.scaleX;
				
				}
				if (bitmap.height>background.height-offset) 
				{
				bitmap.height = 	background.height - offset;
				bitmap.scaleX = bitmap.scaleY;
				
				}
				bitmap.x =background.x+ (background.width-bitmap.width)/2
				bitmap.y =background.y+ (background.height-bitmap.height)/2
				//bitmap.x = (settings.width - bitmap.width) / 2;
				//bitmap.y = background.y + (background.height - bitmap.height) / 2 - 5;
				bitmap.smoothing = true;
			//	bodyContainer.addChild(bitmap);
		}
	
	private function drawInfo():void 
	{
		guestIcon  = new Bitmap(UserInterface.textures.guestAction);
		addChild(guestIcon);
		guestIcon.scaleX = guestIcon.scaleY = .5;
		var count:TextField = Window.drawText(reward.count, {
				color:			0xffffff,
				borderColor:	0x654317,
				fontSize:		34
			});
		guestIcon.x = background.x + (background.width - guestIcon.width - count.textWidth) / 2;
		count.width = count.textWidth + 10;
		count.x = guestIcon.x+guestIcon.width;
		count.y = guestIcon.y;
		addChild(count);
		
	}
	
	public function glowing():void 
	{
		customGlowing(this, glowing);	
	}
	
	
	private function customGlowing(target:*, callback:Function = null):void {
		TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
				if (callback != null && canGlowing) {
					callback();
				}else if(!canGlowing){
					TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0, strength: 7, blurX:1, blurY:1 } });
				}
			}});	
		}});
	}
	
	private function stopGlowing():void
	{
		canGlowing = false;
		window.settings.find = 0;
	}
	
	public function dispose():void 
	{
		clearBody();
		window = null;
		//mission = null;
		//achive = null;
	}
	
	public override function get height():Number 
	{
		return background.height;
	}
	
	
	
	public override function  get width():Number 
	{
		return background.width;
	}
	
	
	
	
	
}}