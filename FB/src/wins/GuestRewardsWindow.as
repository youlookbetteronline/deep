package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	public class GuestRewardsWindow extends Window
	{
		public var rel:Array = new Array;
		public var background:Bitmap;
		public var backgroundTitle:Bitmap;
		
		private var guestRewards:Array;
		private var priceBttn:Button;
		private var back:Shape = new Shape();
		
		
		public function GuestRewardsWindow(settings:Object = null) 
		{
			if (settings == null) 
			{
				settings = new Object();
			}
			
			settings['width'] = 735;
			settings['height'] = 345;
			settings['title'] = Locale.__e('flash:1424171922968');
			settings['background'] = 'workerHouseBacking';
			settings['hasPaginator'] = false;			
			
			super(settings);
			rel = [];
			var numb:int = 0;
			
			for each (var material:* in App.data.storage) 
			{
				if (material.type == 'Guests')
				{					
					rel[numb] = material;
					numb++;
				}
			}
			
			rel.sortOn('count', Array.NUMERIC);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_GUEST_FANTASY, reDraw);
		}
		
		override public function drawExit():void 
		{
			super.drawExit();
			exit.x = settings.width - 50;
			exit.y = -15;
		}
		
		override public function drawBackground():void 
		{
				background = backing(settings.width, settings.height , 50, 'workerHouseBacking');
				var background2:Bitmap  = backing2(settings.width - 60, settings.height - 54, 40, 'capsuleWindowBackingPaperUp', 'capsuleWindowBackingPaperDown');
				
				background2.x = background.x + (background.width - background2.width) / 2;
				background2.y = background.y + (background.height - background2.height) / 2;
				layer.addChildAt(background, 0);
				layer.addChildAt(background2, 1);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 35,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x4b7915,			
				borderSize 			: 3,					
				shadowColor			: 0x085c10,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center'
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -22;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void 
		{
			guestRewards = [];
			
			var ribbon:Bitmap = backingShort(390, 'ribbonGrenn',true,1.3);
			ribbon.x = settings.width / 2 -ribbon.width / 2;			
			ribbon.y = -70;
			bodyContainer.addChild(ribbon);
			
			/*backgroundTitle = Window.backingShort(510, 'dailyBonusBackingDesc', true);
			backgroundTitle.x =  background.x + background.width / 2 - backgroundTitle.width / 2;
			backgroundTitle.height = 30;
			backgroundTitle.y = 25;
			backgroundTitle.alpha = .2;
			bodyContainer.addChild(backgroundTitle);*/
			
			back.graphics.beginFill(0xfff4b9, .9);
		    back.graphics.drawRect(0, 0, 480, 30);
		    back.graphics.endFill();
		    back.x = background.x + background.width / 2 - back.width / 2;
		    back.y = 25;
		    back.filters = [new BlurFilter(40, 0, 2)];
		    bodyContainer.addChild(back);
			
			
			drawDesc();
			contentChange();
			drawButton();
		}
		
		private function reDraw(e:AppEvent = null):void 
		{
			if(background)
				contentChange();
			else{
				setTimeout(reDraw, 1000);
			}
		}
		
		private function drawButton():void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952380242"),//Хорошо!
				fontSize:26,
				width:170,
				height:45,
				hasDotes:false
			};
			
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = (settings.height - priceBttn.height) - 35;
			priceBttn.addEventListener(MouseEvent.CLICK, close);
		}
		
		private function drawDesc():void 
		{		
			var title:TextField = Window.drawText(Locale.__e('flash:1423055726862'), {
				color:0xffffff,
				borderColor:0x7b4003,
				textAlign:"center",
				autoSize:"center",
				fontSize:22,
				width: back.width - 10,
				multiline: true,
				wrap: true
			});
			
			bodyContainer.addChild(title);
			title.x = back.x + back.width / 2 - title.width / 2;
			title.y = back.y + back.height / 2 - title.height / 2;	
		}
		
		override public function contentChange():void 
		{	
			for each(var item:GuestRewardItem in guestRewards)
			{
				if(item.parent)item.parent.removeChild(item);
				item.dispose();
				item = null;
			}
			
			guestRewards = [];
			if (progressBacking)
			bodyContainer.removeChild(progressBacking);
			progressBacking = null;
			
			if (progressBar)
			bodyContainer.removeChild(progressBar);
			progressBar = null;
			
			if (count)
			bodyContainer.removeChild(count);
			count = null;		
			
			var posX:int = 70;
			var currentNumb:int = 0;
			var posStartX:int = -12;
			var current:Boolean = false;
			
			for (var j:int = 0; j < rel.length; j++ ) 
			{
				if (rel[j].count<=App.user.stock.data[Stock.COUNTER_GUESTFANTASY]) 
				{
					currentNumb = j + 1;
					if (currentNumb>rel.length-1) 
					{
						currentNumb = rel.length - 1;
					}
				}
			}
			
			for (var i:int = 0; i < rel.length; i++ ) 
			{				
				if (currentNumb == i &&(rel[i].count>App.user.stock.data[Stock.COUNTER_GUESTFANTASY])) 
				{
					current = true
				}else 
				{
					current = false
				}
				
				item =  new GuestRewardItem(rel[i].sid, rel[i], this, current);
				
				bodyContainer.addChild(item);
				item.x = posStartX+ posX + 20;
				item.y = 60;
				posX += item.width + 15;
				
				guestRewards.push(item);			
			}
			
			var progressBacking:Bitmap = Window.backingShort(299, "progBarBacking");
			progressBacking.x = background.x + background.width / 2 - progressBacking.width / 2;
			progressBacking.y = background.height - 120;			
			bodyContainer.addChild(progressBacking);
			progressBacking.smoothing = true;
			
			var progressBar:ProgressBar = new ProgressBar( { win:this, width:298, isTimer:false,scale:.7});
			progressBar.x = progressBacking.x - 17;
			progressBar.y = progressBacking.y - 17;
			bodyContainer.addChild(progressBar);
			progressBar.start();
			
			progressBar.scaleX = 1;//Заполняшка
			progressBar.scaleY = 1.35;
			
			progressBar.progress = getProgress(rel[currentNumb].count);
			
			var count:TextField = Window.drawText(getProgressTxt(rel[currentNumb].count), {
				color:			0xffffff,
				borderColor:	0x18419e,
				fontSize:		30
			});
			
			count.width = count.textWidth + 10;
			count.x = ( progressBacking.width - count.textWidth) / 2 + progressBacking.x;
			count.y = progressBacking.y - 2;
			bodyContainer.addChild(count);
		}
		
		private function getProgressTxt(need:int):String 
		{
			var needItems:int = need;
			var haveItems:int;
			
			haveItems = App.user.stock.data[Stock.COUNTER_GUESTFANTASY];
			
			if (haveItems > needItems) haveItems = needItems;
			
			var rez:String = String(haveItems) + "/" + String(needItems)
			return rez;
		}
		
		private function getProgress(need:int):Number 
		{
			var needItems:int = need;
			var haveItems:int;
			
			haveItems = App.user.stock.data[Stock.COUNTER_GUESTFANTASY];
			
			if (haveItems > needItems) haveItems = needItems;
			
			var rez:Number =  haveItems / needItems;
			if (rez > 1) rez = 1;
			
			return rez;
		}
		
		override public function dispose():void 
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_GUEST_FANTASY, reDraw);
			super.dispose();
		}
	}
}

import com.greensock.TweenMax;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.text.TextField;
import ui.UserInterface;
import wins.GuestRewardsWindow;
import wins.Window;
import wins.SimpleWindow;

internal class GuestRewardItem extends LayerX
{	
	public var id:int;
	public var count:int;
	public var sid:int;
	
	private var _height:Number;
	private var _width:Number;
	private var canGlowing:Boolean = true;
	private var current:Boolean = false;
	private var background:Bitmap;
	private var guestIcon:Bitmap;
	private var bitmap:Bitmap = new Bitmap();
	private var mark:Bitmap = new Bitmap();
	private var window:GuestRewardsWindow;
	private var offset:int = 30;
	private var title:String;
	private	var text:String;
	public var preloader:Preloader = new Preloader();
	
	
	public var reward:Object = { };
	
	public function GuestRewardItem(id:int, reward:Object, window:GuestRewardsWindow, current:Boolean = false, doGlow:Boolean = false)
	{
		this.window = window;
		this.current = current;
		update(id, reward, doGlow);
	}	
	
	public function update(id:int, reward:Object, doGlow:Boolean = false):void
	{
		this.reward = reward;
		this.id = id;
		
		for (var sid:* in reward.outs)
		{
			if (sid==Stock.COUNTER_GUESTFANTASY) 
			{
				continue
			}
			
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
		
		if (guestIcon && guestIcon.parent)
			guestIcon.parent.removeChild(guestIcon);
		guestIcon = null;
		guestIcon = new Bitmap();	
	}
	
	private function drawBody():void 
	{		
		drawRewardInfo();
		drawInfo();	
	}	
	
	private function drawRewardInfo():void 
	{
		background 	= new Bitmap(Window.textures.clearBubbleBacking);
		
		background.y = 40;		
		background.smoothing = true;
		addChild(background);		
		addChild(preloader);
		preloader.x = (background.width)/ 2;
		preloader.y = (background.height) / 2 + 40;
		Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), onLoadImage);	
		addChild(bitmap);
		
		for each(var counts:* in reward.outs)
		break
		var count:TextField = Window.drawText('x'+ counts, {
			color:			0xffffff,
			borderColor:	0x654317,
			fontSize:		30
		});
		
		guestIcon.x = background.x + (background.width - guestIcon.width - count.textWidth) / 2;
		count.width = count.textWidth + 10;
		count.x = background.x + background.width / 2 - count.width / 2;
		count.y = background.y + (background.height - count.height) + 30;
		addChild(count);
		
		mark = new Bitmap(Window.textures.checkmarkBig);		
		mark.x =background.x+ (background.width-mark.width)/2
		mark.y =background.y+ (background.height-mark.height)/2
		addChild(mark);
		
		if (reward.count<=App.user.stock.data[Stock.COUNTER_GUESTFANTASY] || current) 
		{
			if (current) 
			{
				mark.alpha = 0;
				title=Locale.__e('flash:1424362259010');
				text = Locale.__e('flash:1424362185796', [String(reward.count),String(count.text),String(App.data.storage[sid].title)]);
			}else 
			{
				mark.alpha = 1;
				title = Locale.__e('flash:1424362519721');
				text = Locale.__e('flash:1484130958324', [String(count.text) +' ' + String(App.data.storage[sid].title)]);
			}			
		}else 
		{
			mark.alpha = 0;
			title=Locale.__e('flash:1424362259010');
			text = Locale.__e('flash:1424362185796', [String(reward.count),String(count.text),String(App.data.storage[sid].title)]);
		}
		title = reward.title;
		
		tip = function():Object {
			return {
				title:title,
				text:text
			}
		}
	}
	
	private function onLoadImage(data:Object):void
	{		
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		
		/*if (bitmap.width>background.width-offset) 
		{
			bitmap.width = 	background.width - offset;
			bitmap.scaleY = bitmap.scaleX;				
		}*/
		Size.size(bitmap, 80, 80);
		
		bitmap.x = background.x + (background.width - bitmap.width) / 2;
		bitmap.y = background.y + (background.height - bitmap.height) / 2;
		bitmap.smoothing = true;
	}
	
	private function drawInfo():void 
	{
		guestIcon  = new Bitmap(UserInterface.textures.guestAction);
		addChild(guestIcon);
		guestIcon.scaleX = guestIcon.scaleY = .5;
		guestIcon.smoothing = true;
		
		var count:TextField = Window.drawText(reward.count, {
			color:			0xffffff,
			borderColor:	0x654317,
			fontSize:		34
		});
		
		guestIcon.x = background.x + (background.width - guestIcon.width - count.textWidth) / 2;
		guestIcon.y = 10
		count.width = count.textWidth + 10;
		count.x = guestIcon.x+guestIcon.width;
		count.y = guestIcon.y;
		addChild(count);		
	}
	
	public function glowing():void 
	{
		customGlowing(this, glowing);	
	}	
	
	private function customGlowing(target:*, callback:Function = null):void 
	{
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
	}
	
	public override function get height():Number 
	{
		return background.height;
	}
	
	public override function  get width():Number 
	{
		return background.width;
	}	
}