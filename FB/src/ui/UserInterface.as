package ui
{
	import buttons.Button;
	import com.greensock.TweenMax;
	import core.CookieManager;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.filters.GlowFilter;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class UserInterface extends Sprite
	{
		private var serverDate:Date;
		public static var textures:Object;
		public static var over:Boolean = false;
		
		public var bottomPanel:BottomPanel;
		public var upPanel:UpPanel;
		public var systemPanel:SystemPanel;
		public var rightPanel:RightPanel;
		public var leftPanel:LeftPanel;
		public var salesPanel:SalesPanel;
		//public var homeQuitBttn:Button;
		public var isQuit:Boolean = false;
	
		
		public function UserInterface() {
			/*Load.loading(Config.getInterface('panels'), onLoad, 0, false,
			function(progress:Number):void{
				if(App.self.changeLoader != null) App.self.changeLoader('ui', progress);
			});*/
		}
		
		public function hideAll():void 
		{
			bottomPanel.hide();
			rightPanel.hide();
			salesPanel.hide();
			systemPanel.visible = false;
			leftPanel.visible = false;
			
			upPanel.hide();
			refresh();
		}
		
		public function refresh():void {
			if (App.user.quests.data[123] && App.user.quests.data[123].finished > 0) {
				//upPanel.showMiddle();
				bottomPanel.showMain();
				//App.ui.bottomPanel.show('mainPanel');
			}
			if (App.user.quests.data[5] && App.user.quests.data[5].finished > 0) {
				upPanel.showMiddle();
			}
			if (App.user.quests.data[6] && App.user.quests.data[6].finished > 0) {
				upPanel.showRight();
			}
			if (App.user.quests.data[8] && App.user.quests.data[8].finished > 0) {
				upPanel.showLeft();
			}
			if (App.user.quests.data[140] && App.user.quests.data[140].finished > 0) {
				bottomPanel.showIcons();
			}
		}
		public static var needMove:Boolean = false;
		public function checkExpedition():void {
			if (App.user.mode != User.OWNER) return;
			
			if (User.inExpedition) {
				
			}
			
			//App.ui.bottomPanel.homeQuitBttn.visible = false
			
			//if (App.user.worldID == User.AQUA_HERO_LOCATION && App.user.mode != User.GUEST) 
			//{
				////App.ui.bottomPanel.homeQuitBttn.visible = true;
				//App.ui.upPanel.iconsSprite.visible = false;
			//}else 
			//{
				//App.ui.bottomPanel.homeQuitBttn.visible = false;
				//App.ui.upPanel.iconsSprite.visible = true;
			//}
		}
		
		/*public static function backingShort(width:int, texture:String = "windowBacking", mirrow:Boolean = true):Bitmap {
			var sprite:Sprite = new Sprite();
			
			var left:Bitmap = new Bitmap(textures[texture], "auto", true);
			
			var right:Bitmap = new Bitmap(textures[texture], "auto", true);
			right.scaleX = -1;
			
			var horizontal:BitmapData = new BitmapData(1, left.height, true, 0);
			horizontal.copyPixels(left.bitmapData,new Rectangle(left.width-1, 0, left.width, left.height), new Point());
			
			var fillColor:uint = left.bitmapData.getPixel(left.width - 1, left.height - 1);
			
			right.x = width;
			right.y = 0;
			
			var shp:Shape;
			shp = new Shape();
			shp.graphics.beginBitmapFill(horizontal);
			shp.graphics.drawRect(0, 0, width - left.width * 2, left.height);
			shp.graphics.endFill();
			
			if (width > 0) {
				var hBmd:BitmapData = new BitmapData(width - left.width * 2, left.height, true, 0);
				hBmd.draw(shp);
				var hTopBmp:Bitmap = new Bitmap(hBmd, "auto", true);
				hTopBmp.x = left.width;
				hTopBmp.y = 0;
				sprite.addChild(hTopBmp);
			}else {
				right.x = left.width*2;
			}
			
			sprite.addChild(left);
			if (mirrow)sprite.addChild(right);
			
			
			var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
			bg.draw(sprite);
						
			for (var i:int = 0; i < sprite.numChildren; i++) {
				sprite.removeChildAt(i);
			}
			sprite = null;
			
			return new Bitmap(bg, "auto", true);
		}*/
		public var dateOffset:int = 0;
		
		public function showAll(e:AppEvent = null):void 
		{
			bottomPanel.show();
			rightPanel.show();
			systemPanel.visible = true;
			upPanel.show();
			leftPanel.visible = true;
			App.self.removeEventListener(AppEvent.ON_FINISH_TUTORIAL, showAll);
		}
		
		public function onLoad():void 
		{
			App.user.quests.getOpened();
			Cursor.init();
			bottomPanel = new BottomPanel();
			upPanel = new UpPanel();
			systemPanel = new SystemPanel();
			rightPanel = new RightPanel();
			leftPanel = new LeftPanel();
			salesPanel = new SalesPanel();		
			
			addChild(bottomPanel);
			addChild(upPanel);
			
			serverDate = new Date();
			
			serverDate.setTime((App.midnight + serverDate.timezoneOffset * 60 + 3600 * 12 + dateOffset * 86400) * 1000);
			var month:uint = serverDate.getMonth() + 1;
			var currMonth:uint = month;
			var day:int = serverDate.getDate();
			var year:uint = serverDate.getFullYear();
			var daysOnMonth:int = new Date(year, month, 0).getDate();
			if (App.data.calendar)	
			{
				for (var i:int = 0; i < daysOnMonth; i++) 
				{
					if (App.data.calendar[month] && App.data.calendar[month].hasOwnProperty('items') && App.data.calendar[month].items.hasOwnProperty(i + 1))
						for (var sid:* in App.data.calendar[month].items[i + 1]) break;
							getState(i + 1);
				}
				function getState(index:int):void 
				{
					if (App.user.calendar[year].hasOwnProperty(month)) 
					{
						if(App.user.calendar[year][month].indexOf(index) < 0 && App.user.calendar[year][month].indexOf(year) < 0)
							if (month == currMonth && index == day) 
							{
								App.ui.upPanel.calendarBttn.startGlowing();
							}
					}
				}
			}
			addChild(systemPanel);
			addChild(rightPanel);
			addChild(leftPanel);
			addChild(salesPanel);
			resize();
			
			addEventListener(MouseEvent.MOUSE_DOWN, onDownEvent);
			
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_UI_LOAD));
			
			//resize();
			checkExpedition();
			
			resize();
		}	
		
		private function onDownEvent(e:MouseEvent):void {
			over = true;
		}
		
		public static function dissapear(targetList:Array,callback:Function = null,params:Object = null):void {
			var speed:Number = 1;
			var overedNum:uint = targetList.length;
			if (params && params.hasOwnProperty('speed')) {
				speed = params['speed'];
			}
			var dA:Number = 0.05 * speed;
			var diss:Function = function():void {
					for (var itm:* in targetList) {
						
						if (targetList[itm].alpha < dA) {
							targetList[itm].alpha = 0;
							targetList.splice(itm, 1);
							overedNum--;
						}else {
							targetList[itm].alpha = Math.abs(targetList[itm].alpha - dA);
						}
					}
					if (overedNum == 0) {
						App.self.setOffEnterFrame(diss);
						if (callback!=null) {
							if (params) {
								callback(params);
							}else{
								callback();
							}
						}
					}
				}
			App.self.setOnEnterFrame(diss);
		}
		
		public static function appear(targetList:Array,callback:Function = null,params:Object = null):void {
			var speed:Number = 1;
			var overedNum:uint = targetList.length;
			if (params && params.hasOwnProperty('speed')) {
				speed = params['speed'];
			}
			var dA:Number = 0.05*speed;
			var diss:Function = function():void {
					for (var itm:* in targetList) {
						if (targetList[itm].alpha >= 1) {
							targetList[itm].alpha = 1;
							targetList.splice(itm, 1);
							overedNum--;
						}else {
							targetList[itm].alpha = ( Math.abs( targetList[itm].alpha + dA - 1 ) > dA)?targetList[itm].alpha + dA:1;
						}
					}
					if (overedNum == 0) {
						App.self.setOffEnterFrame(diss);
						if (callback!=null) {
							if (params) {
								callback(params);
							}else{
								callback();
							}
						}
					}
				}
			App.self.setOnEnterFrame(diss);
			
			
			//var diss:Function = function():void {
					//var speed:uint = 1;
					//if (params && params.hasOwnProperty('speed') ){
						//speed = params['speed'];
					//}
					//var dA:Number = 0.05*speed;
					//target.alpha = (Math.abs(target.alpha + dA - 1)>dA)?target.alpha + dA:1;
					//if(target.alpha==1){
						//App.self.setOffEnterFrame(diss);
						//if (callback!=null) {
							//if (params) {
								//callback(params);
							//}
							//else
							//{
								//callback();
							//}
						//}
						//
					//}
				//}
			//App.self.setOnEnterFrame(diss);
		}
		
		
		public function resize():void 
		{
			bottomPanel.resize();
			rightPanel.resize();
			upPanel.resize();
			leftPanel.resize();
			systemPanel.resize();
			salesPanel.resize();
		}
		
		public static function slider(result:Sprite, value:Number, max:Number, bmd:String = "energySlider", useWindowTextures:Boolean = false, wider:uint=0):void {
			while (result.numChildren) {
				result.removeChildAt(0);
			}
			var slider:Bitmap;
			
			if(useWindowTextures)slider = new Bitmap(Window.textures[bmd]);
			else slider = new Bitmap(UserInterface.textures[bmd]);
			if (wider>0) 
			{
			slider.width +=	wider;
			slider.smoothing = true;
			}
			
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0x000000, 1);
			mask.graphics.drawRect(0, 0, slider.width, slider.height);
			mask.graphics.endFill();
			
			result.addChild(mask);			
			result.addChild(slider);
			
			slider.mask = mask;
			
			var percent:Number = value > max ? 1: value / max;
			var currentWidth:Number = slider.width * percent;
			
			mask.x = currentWidth - slider.width;
			mask.x = slider.x <= 0?mask.x:0;
		}
		
		public static function slider2(result:Sprite, value:Number, max:Number, bmd:String = "energySlider"):void 
		{
			while (result.numChildren) 
			{
				result.removeChildAt(0);
			}
			var slider:Bitmap;
			slider = Window.backingShort(max, bmd);
			
			var mask:Shape = new Shape();
			
			result.addChild(mask);			
			result.addChild(slider);
			
			slider.mask = mask;
			
			var percent:Number = value > max ? 1: value / max;
			if (isNaN(percent)) percent  = 0;
			var currentWidth:Number = slider.width * percent;
			
			mask.graphics.beginFill(0x000000, 1);
			mask.graphics.drawRect(0, 0, slider.width * percent, slider.height);
			mask.graphics.endFill();
		}
		
		public function staticGlow(target:*, params:Object = null ):void {
			var color:Number = params.color || 0xFFFF00;
			var size:uint = params.size || 3;
			var strength:uint = params.strength || 3;
			var knock:Boolean = params.knock;
			var filt:GlowFilter = new GlowFilter(color,
								1,
								size,
								size,
								3,
								2,
								false,
								false);
			target.filters = [filt];
		}
		
		public function glowing(target:*, color:uint = 0xFFFF00, callback:Function = null):void { // подсветка добычи
			TweenMax.to(target, 0.3, { glowFilter: { color:color, alpha:0.8, strength: 4, blurX:12, blurY:12 }, onComplete:function():void {
				
				TweenMax.to(target, 0.2, { glowFilter: { color:color, alpha:0, strength: 4, blurX:12, blurY:12 }, onComplete:function():void {
					target.filters = [];
					if (callback != null) {
						callback();
					}
				}});
			}});
		}
		
		public function flashGlowing(target:*, color:uint = 0xFFFF00, callback:Function = null, hasSound:Boolean = true):void 
		{
			TweenMax.to(target, 0.4, { glowFilter: { color:color, alpha:0.8, strength: 7, blurX:30, blurY:30 }, onComplete:function():void {
				TweenMax.to(target, 1, { glowFilter: { color:color, alpha:0, strength: 4, blurX:6, blurY:6 }, onComplete:function():void {
					target.filters = [];
					if (callback != null) {
						callback();
					}
				}});	
			}});
			
			if(hasSound)
				SoundsManager.instance.playSFX('glow');	
		}
		
		import silin.filters.ColorAdjust;	
		
		public static function effect(target:*, brightness:Number = 1, saturation:Number = 1):void {
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(saturation);
			mtrx.brightness(brightness);
			target.filters = [mtrx.filter];
		}
		
		public static function colorize(target:*, rgb:*, amount:*):void {
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.colorize(rgb, amount);
			target.filters = [mtrx.filter];
		}
		
		public function showNews(data:Object, name:String):void 
		{
			var news:NewsItem = new NewsItem(data, name);
				news.show();
		}
		
		public var globalLoader:GlobalLoader;
		public function addGlobalLoader():void {
			if (globalLoader != null)
				globalLoader.dispose();
				
			globalLoader = new GlobalLoader();
			globalLoader.show();
		}
		public function removeGlobalLoader():void {
			if(globalLoader != null)
				globalLoader.dispose();
				
			globalLoader = null;	
		}
	}
}


import flash.display.Sprite;
internal class GlobalLoader extends Sprite
{
	private var preloader:Preloader = new Preloader();
		
		public function GlobalLoader() 
		{
			drawBody();
		}
		
		private function drawBody():void 
		{
			addChild(preloader);
			preloader.scaleX = preloader.scaleY = 0.8;
			preloader.x = 50;
			preloader.y = 80;
			
			
			var txt:TextField = Window.drawText(Locale.__e("flash:1405331495038"), {
				color:0xffffff,
				borderColor:0x1d3b3d,
				fontSize:22,
				textAlign:"left"
			});
			addChild(txt);
			txt.width = txt.textWidth + 10;
			txt.x = preloader.x + preloader.width/2 + 10;
			txt.y = preloader.y - txt.textHeight/2;
			
		}
		
		public function dispose():void
		{
			if (preloader && preloader.parent)
				preloader.parent.removeChild(preloader);
				
			App.self.removeChild(this);	
		}
		
		public function show():void {
			App.self.addChild(this);
			this.x = (App.self.stage.stageWidth - this.width) / 2 - 20;
			this.y = (App.self.stage.stageHeight - this.height) / 2 - 40;
		}
}

import buttons.Button;
import buttons.ImageButton;
import com.greensock.TweenLite;
import core.CookieManager;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.text.TextField;
import wins.ShopWindow;
import wins.Window;

internal class NewsItem extends Sprite
{
	private var bg:Bitmap;
	public var exit:ImageButton
	private var data:Object;
	private var cookieName:String;
	
	public function NewsItem(data:Object, cookieName:String) {
		this.data = data;
		this.cookieName = cookieName;
		
		bg = Window.backing(300, 150, 50, 'windowBacking');
		addChild(bg);
		
		App.ui.addChild(this);
		this.x = App.self.stage.stageWidth - bg.width - 30;
		this.y = -200;
		
		exit = new ImageButton(Window.textures.closeBttn);
		exit.scaleX = exit.scaleY = 0.7;
		addChild(exit);
		exit.x = bg.width - 25;
		exit.y = 0;
		exit.addEventListener(MouseEvent.CLICK, onClose);
		
		drawIcon();
		drawTexts();
		drawBttn();
		
		App.self.setOnTimer(timer);
	}
	
	public function onClose(e:MouseEvent):void {
		if(ExternalInterface.available){
			CookieManager.store(this.cookieName, '1');
		}
		dispose();
	}
	
	public function show():void {
		TweenLite.to(this, 0.5, {y:60})
	}
	
	private var bttn:Button;
	private function drawBttn():void {
		bttn = new Button( {
			caption:Locale.__e('flash:1382952379751'),
			fontSize:22,
			width:94,
			height:30
		})
		addChild(bttn);
		bttn.x = 200 - bttn.width / 2;
		bttn.y = bg.height - bttn.height / 2 - 10;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private var title:TextField;
	private var description:TextField;
	private var timeText:TextField;
	private function drawTexts():void {
		title = Window.drawText(item.title, {
			color:0xFFFFFF,
			borderColor:0x502f06,
			borderSize:4,
			fontSize:26,
			textAlign:"center",
			multiline:true
		});
		title.width = 140;
		title.height = title.textHeight;
		addChild(title);
		
		description = Window.drawText(data.description, {
			color:0xFFFFFF,
			borderColor:0x502f06,
			borderSize:4,
			fontSize:22,
			textAlign:"center",
			multiline:true,
			wrap:true
		});
		description.width = 140;
		description.x = 130;
		description.height = 130;
		addChild(description);
		
		var time:int = (data.time + data.duration * 3600) - App.time;
		timeText = Window.drawText(TimeConverter.timeToStr(time), {
			color:0xf7d64b,
			borderColor:0x502f06,
			borderSize:4,
			fontSize:36,
			textAlign:"center",
			multiline:true,
			wrap:true
		});
		
		timeText.width = 140;
		timeText.x = description.x;
		timeText.y = 70;
		timeText.height = 130;
		addChild(timeText);
	}
	
	private var item:Object;
	private var bitmap:Bitmap;
	private var sID:*;
	private function drawIcon():void {
		bitmap = new Bitmap();
		addChild(bitmap);
		for (sID in data.items) break;
			item = App.data.storage[sID];
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
	}
	
	private function onLoad(data:Bitmap):void
	{
		bitmap.bitmapData = data.bitmapData;
		bitmap.x = 70 - bitmap.width / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
	}
	
	public function onClick(e:MouseEvent = null):void {
		dispose();
		new ShopWindow( { find:[sID] } ).show();
	}
	
	public function dispose(e:MouseEvent = null):void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
		exit.removeEventListener(MouseEvent.CLICK, dispose);
		App.self.setOffTimer(timer);
		App.ui.removeChild(this);
	}
	
	public function timer(e:MouseEvent = null):void {
		var time:int = (data.time + data.duration * 3600) - App.time;
		if (time < 0) {
			dispose();
		}
		timeText.text = TimeConverter.timeToStr(time);
	}
}
