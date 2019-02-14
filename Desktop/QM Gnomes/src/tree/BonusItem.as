package tree
{
	import com.greensock.easing.Elastic;
	import com.greensock.TweenMax;
	import effects.Effect;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import core.BezieDrop;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import silin.utils.Color;
	import ui.Hints;
	import com.greensock.TweenLite;
	import ui.UserInterface;
	import units.Unit;
	import units.WorkerUnit;
	
	/**
	 * ...
	 * @author 
	 */
	
	public class BonusItem extends Sprite 
	{
		public var bitmap:Bitmap;
		private var sID:uint;
		private var nominal:uint;
		private var count:uint;
		private var bezieDrop:BezieDrop;
		private var layer:*;
		private var scaling:Boolean = true;
		private var destObject:* = null;
		
		private static const PATH_TIME:Number = 1;// 0.8;
		private var preloader:Preloader = new Preloader();
		
		//[Embed(source="blick_bitmap.png", mimeType="image/png")]
		//private var Blick_Bitmap:Class;
		//private var blickBMD:BitmapData = new Blick_Bitmap().bitmapData;
		
		public function BonusItem(sID:uint, nominal:uint, scaling:Boolean = true, destObject:* = null)
		{
			this.sID = sID;
			this.nominal = nominal;
			this.count = count;
			this.scaling = scaling;
			this.destObject = destObject;
			
			bitmap = new Bitmap();
			addChild(bitmap);
			if (sID == Stock.FANTASY) 
			{
				bitmap.bitmapData = UserInterface.textures.energyIcon;
				onImageComplete(bitmap);
			}
			else if (sID == Stock.COINS)
			{
				if (nominal == Treasures.NOMINAL_1)				bitmap.bitmapData = UserInterface.textures.coinsIcon;
				else if (nominal == Treasures.NOMINAL_2)		bitmap.bitmapData = UserInterface.textures.coins3;
				else if (nominal == Treasures.NOMINAL_3)		bitmap.bitmapData = UserInterface.textures.coins5;
				else 											bitmap.bitmapData = UserInterface.textures.coinsIcon;
					
				onImageComplete(bitmap);
			}
			else if (sID == Stock.EXP)
			{
				if (nominal == Treasures.NOMINAL_1)			bitmap.bitmapData = UserInterface.textures.expIcon;
				else if (nominal == Treasures.NOMINAL_2)		bitmap.bitmapData = UserInterface.textures.exp2;
				else if (nominal == Treasures.NOMINAL_3)		bitmap.bitmapData = UserInterface.textures.exp4;
				else                                            bitmap.bitmapData = UserInterface.textures.expIcon;
				
				onImageComplete(bitmap);
			}
			else
			{
				addChild(preloader);
				preloader.scaleX = preloader.scaleY = 0.6;
				
				Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onImageComplete);
			}
			
			setTimeout(cash, 3000 + Math.random()*3000);
		}
		
		private function onMouseOver(e:MouseEvent):void {
			cash();
		}
		
		private var maska:Bitmap;
		public function onImageComplete(data:Bitmap):void
		{
			if(contains(preloader)){
				removeChild(preloader);
			}
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			if (scaling && App.data.storage[sID].mtype != 3 && (bitmap.width >= 70 || App.data.storage[sID].mtype == 4 || bitmap.height >= 70))
				bitmap.scaleX = bitmap.scaleY = 0.6;
				
			if (sID == Stock.FANT)
				bitmap.scaleX = bitmap.scaleY = 0.5;
				
			bitmap.x = -(bitmap.width)/ 2;
			bitmap.y = -(bitmap.height) / 2;
			
			maska = new Bitmap(data.bitmapData);
			addChild(maska);
			maska.x = bitmap.x;
			maska.y = bitmap.y;
			maska.scaleX = bitmap.scaleX;
			maska.scaleY = bitmap.scaleY;
			
			addBlick();
		}
		
		private var blick:Bitmap = new Bitmap();
		private function addBlick():void {
			
			if (maska == null)
				return;
			
			//blick.bitmapData = blickBMD;
			addChild(blick);
			blick.x = bitmap.x;
			blick.y = bitmap.y;
			blick.blendMode = BlendMode.OVERLAY;
			blick.width = maska.width + 10;
			blick.rotation =  - 25 + Math.random() * -10;
			//blick.filters = [new BlurFilter(5,5,2)];
			
			/*blik.graphics.beginFill(0xFFFFFF);
			blik.graphics.drawRect(0, 0, maska.width, 5);
			blik.graphics.endFill();
			blik.x = bitmap.x;
			blik.y = bitmap.y;
			blik.blendMode = BlendMode.OVERLAY;
			blik.rotation = Math.random() * 15;
			//blik.filters = [new BlurFilter(0,10,3)];*/
			
			blick.cacheAsBitmap = true;
			maska.cacheAsBitmap = true;
			blick.mask = maska;
			
			randomTime = 1000 + int(1000 * Math.random());
			setTimeout(startBlick, 1000);
		}
		
		private var timer:uint = 0;
		private var randomTime:int;
		private function startBlick():void {
			if (maska == null)
				return;
			
			blick.y = maska.y -5;
			TweenLite.to(blick, 3, {y:maska.height, onComplete:pauseBlick, ease:Strong.easeOut})
		}
		
		private function pauseBlick():void {
			timer = setTimeout(startBlick, randomTime);
		}
		
		private function stopBlick():void {
			if (timer > 0) {
				clearTimeout(timer);
				timer = 0;
			}
		}
		
		public function move(time:int):void
		{
			setTimeout(doMove, time);
			this.visible = false;
			//var Xf:uint = this.x + int(Math.random() * Treasures.bonusDropArea.w) - Treasures.bonusDropArea.w/2;
			//var Yf:uint = this.y + int(Math.random() * Treasures.bonusDropArea.h);
			//var that:* = this;
			//bezieDrop = new BezieDrop(this.x, this.y, Xf, Yf, this, function():void {
				//addBlick();
				///*var effect:Effect = new Effect('Sparks', that);
				//effect.x = bitmap.x + bitmap.width / 2;
				//effect.y = bitmap.y + bitmap.height / 2;*/
			//});

		}
		
		public var onStartDrop:Function = null;
		public var onCash:Function = null;
		private function doMove():void
		{
			if (onStartDrop != null) onStartDrop();
			this.visible = true;
			
			var Xf:uint = this.x + int(Math.random() * Treasures.bonusDropArea.w) - Treasures.bonusDropArea.w/2;
			var Yf:uint = this.y + int(Math.random() * Treasures.bonusDropArea.h);
			var that:* = this;
			bezieDrop = new BezieDrop(this.x, this.y, Xf, Yf, this, function():void {
				addBlick();
				/*var effect:Effect = new Effect('Sparks', that);
				effect.x = bitmap.x + bitmap.width / 2;
				effect.y = bitmap.y + bitmap.height / 2;*/
			});
		}
		
		import com.greensock.easing.*
		private var cahed:Boolean = false;
		public function cash():void
		{
			stopBlick();
			var that:* = this;
			
			if(bezieDrop != null) bezieDrop.stop();
			bezieDrop = null;
			
			if(App.map.mTreasure.contains(that)){
				App.map.mTreasure.removeChild(that);
			}else{
				return;
			}
			
			var totalCount:uint = nominal;
			if(!App.user.quests.tutorial)
				Hints.plus(sID, totalCount, new Point((that.x*App.map.scaleX + that.width / 2)+App.map.x, that.y*App.map.scaleY+App.map.y));
			
			var place:Point = new Point(x + App.map.x/App.map.scaleX, y + App.map.y/App.map.scaleY);
			place.x *= App.map.scaleX;
			place.y *= App.map.scaleY;
			
			this.layer = App.ui;
			x = place.x;
			y = place.y;
			layer.addChild(this);
			place.y -= 120;
				
			this.scaleX = this.scaleY =  0.2;
			//App.ui.flashGlowing(this);
			startBlick();
			TweenLite.to(this, 0.3, { scaleY:1.2, scaleX:1.2, ease:Back.easeOut});
			TweenLite.to(this, 0.3, { y:place.y, ease:Strong.easeOut, onComplete:function():void {
				cashMove(place, App.ui);
			}});
			
			if (onCash != null)
				onCash();
		}
		
		public function cashMove(place:Point, layer:*):void
		{
			this.layer = layer;
			x = place.x;
			y = place.y;
			var item:* = App.data.storage[sID];
			layer.addChild(this);
			
			if (destObject != null && destObject.sIDs.indexOf(sID) != -1) {
				toDestinationObject();
				return;
			}
			
			switch(sID) {
				//case 206: toMap(sID); break;
				case Stock.COINS:	toCoinsBar(); App.ui.upPanel.update(['coins']); break;
				case Stock.EXP: 	toExpBar(); App.ui.upPanel.update(['exp']); break;
				case Stock.FANT: 	toFantBar(); App.ui.upPanel.update(['fants']); break;
				case Stock.FANTASY:
					toEnergyBar(); 
					App.ui.upPanel.update(['energy']);
					break;
				case Stock.GUESTFANTASY:
					if (App.user.mode == User.OWNER) {
						toStock();
					}else{
						toGuestEnergyBar();
					}
					break;
				//case Stock.JAM:
				//case 55:
				//case 52:
					//toJam(); 
					//App.ui.upPanel.update(['jam']);
					//break;
			default :
					if (App.data.storage[sID].mtype == 4)
						toCollections();
					else
						toStock();
					break;
			}
		}
		
		public function cashMoveSpace(place:Point, layer:*):void
		{
			this.layer = layer;
			x = place.x;
			y = place.y;
			var item:* = App.data.storage[sID];
			layer.addChild(this);
			
			if (destObject)
			{
				var p:Object = { x:destObject.target.x + Math.random()*300, y:destObject.target.y + Math.random()*100};
				TweenLite.to(this, PATH_TIME, { x:p.x, y:p.y, onComplete:function():void {
					remove();
					if (destObject.callback != null)
						destObject.callback();
				}});
			}
		}
		
		public function fromStock(place:Point, moveTo:Point, layer:*):void 
		{
			this.layer = layer;
			x = place.x;
			y = place.y;
			layer.addChild(this);
			
			SoundsManager.instance.playSFX('map_sound_2');
			
			var p:Object = { x:moveTo.x, y:moveTo.y };
			tween(this, p, remove);
		}
		
		private function toDestinationObject():void {
			var p:Object = { x:destObject.target.x + App.map.x, y:destObject.target.y + App.map.y};
			TweenLite.to(this, PATH_TIME, { x:p.x, y:p.y, onComplete:function():void {
				remove();
				if (destObject.callback != null)
					destObject.callback();
			}});
		}
		
		public function tween(target:*, point:Object, onComplete:Function = null, onCompleteParams:Array = null):void{
			var bezierPoints:Array = [];
			
			var bezierPoint:Object = point;
			bezierPoints.push(bezierPoint);
			
			var borders:Object = {a:point, b:{x:target.x, y:target.y}};
			var randomCount:int = 1;
			for (var i:int = 0; i < randomCount; i++) {
				bezierPoint = new Object();
				
				bezierPoint['x'] = int((target.x - point.x - 100) * Math.random()) + point.x + 50;
				bezierPoint['y'] = int((target.y - point.y - 100) * Math.random()) + point.y + 50;
				
				//bezierPoint['x'] = 100 +((App.self.stage.stageWidth - 200) * Math.random());
				//bezierPoint['y'] = 100 +((App.self.stage.stageHeight - 200) * Math.random());
				bezierPoints.unshift(bezierPoint);
			}
			var randomTime:Number = PATH_TIME + PATH_TIME * Math.random();
			
			if (onCompleteParams == null)
				onCompleteParams = [];
			
			TweenMax.to(target, PATH_TIME, {bezierThrough:bezierPoints, orientToBezier:false, onComplete:onComplete, onCompleteParams:onCompleteParams});
		}
		
		private function toCoinsBar():void {
			SoundsManager.instance.playSFX('map_sound_3');
			var bttn:* = App.ui.upPanel.coinsSprite;
			var p:Object = { x:bttn.x + App.ui.upPanel.x + 20 + App.ui.upPanel.leftCont.x, y:bttn.y + App.ui.upPanel.y + 19 + App.ui.upPanel.leftCont.y};
			tween(this, p, remove, [App.ui.upPanel.coinsBar, 0xFFFF00]);
		}
		
		private function toExpBar():void {
			SoundsManager.instance.playSFX('map_sound_4');
			var bttn:* = App.ui.upPanel.expSprite;
			var p:Object = { x:bttn.x + App.ui.upPanel.x + 24 + App.ui.upPanel.rightCont.x, y:bttn.y + App.ui.upPanel.y + 13 + App.ui.upPanel.rightCont.y};
			tween(this, p, remove, [App.ui.upPanel.expIcon, 0xFFFF00]);
		}
		
		private function toJam():void {
			/*var bttn:* = App.ui.upPanel.jamBttn;
			var p:Object = { x:bttn.x + App.ui.upPanel.x + 34, y:bttn.y + App.ui.upPanel.y + 32 };
			tween(this, p, remove, [bttn, 0x7b1012]);*/
		}
		
		private function toFantBar():void {
			SoundsManager.instance.playSFX('map_sound_2');
			var bttn:* = App.ui.upPanel.fantSprite;
			var p:Object = { x:bttn.x + App.ui.upPanel.x + 18 + App.ui.upPanel.leftCont.x, y:bttn.y + App.ui.upPanel.y + 12 + App.ui.upPanel.leftCont.y};
			tween(this, p, remove, []);
		}
		
		private function toEnergyBar():void {
			var bttn:*;
			var p:Object;
			SoundsManager.instance.playSFX('map_sound_2');
			if (App.user.mode == User.GUEST) {
				bttn = App.ui.bottomPanel.bttnMainHome;
				p = { x:bttn.parent.x + bttn.x + bttn.width/2 , y:bttn.parent.y + bttn.y + bttn.height/2 - 4};
			}else {
				bttn = App.ui.upPanel.energySprite;
				p = { x:bttn.x + App.ui.upPanel.x + 24 + App.ui.upPanel.rightCont.x, y:bttn.y + App.ui.upPanel.y + 18 + App.ui.upPanel.rightCont.y};
			}
				
			tween(this, p, remove, [App.ui.upPanel.energyIcon, 0x86e3f2]);
		}
		
		private function toGuestEnergyBar():void {
			SoundsManager.instance.playSFX('map_sound_2');
			var bttn:* = App.ui.leftPanel.guestEnergy.getChildAt(0);
			var p:Object = { x:bttn.x + App.ui.leftPanel.guestEnergy.x + App.ui.leftPanel.x + 36, y:bttn.y + App.ui.leftPanel.guestEnergy.y + App.ui.leftPanel.y + 28 };
			tween(this, p, remove, []);
		}
		
		private function toStock():void {
			var bttn:*;
			var p:Object;
			SoundsManager.instance.playSFX('map_sound_2');
			if (App.user.mode == User.GUEST) {
				bttn = App.ui.bottomPanel.bttnMainHome;
				p = { x:bttn.parent.x + bttn.x + bttn.width/2, y:bttn.parent.y + bttn.y + bttn.height/2 - 4};
			}else {
				bttn = App.ui.bottomPanel.bttnMainStock;
				p = { x:bttn.x + bttn.width/2 + App.ui.bottomPanel.mainPanel.x, y:bttn.y + bttn.height/2 +App.ui.bottomPanel.mainPanel.y };
			}
			
			tween(this, p, remove, [bttn, 0xFFFF00]);
		}
		
		private function toCollections():void 
		{
			var bttn:*;
			var p:Object;
			SoundsManager.instance.playSFX('map_sound_2');
			if (App.user.mode == User.GUEST) {
				bttn = App.ui.bottomPanel.bttnMainHome;
				p = { x:bttn.parent.x + bttn.x + bttn.width/2, y:bttn.parent.y + bttn.y + bttn.height/2 - 4};
			}else {
				bttn = App.ui.bottomPanel.bttns[3];
				p = { x:bttn.parent.x + bttn.x + bttn.width/2, y:bttn.parent.y + bttn.y + bttn.height/2 - 4};
			}
			tween(this, p, remove, [bttn, 0xFFFF00]);
		}
		
		public function remove(target:* = null, color:uint = 0xFFFF00):void 
		{
			if (target) App.ui.glowing(target, color);
			if (this.parent == null) return;
			this.parent.removeChild(this);
			layer = null;
		}
		
		public static function takeRewards(items:Object, target:*, delay:int = 0, addToStock:Boolean = false, updateUI:Boolean = false):void {
			
			var timer:Timer;
			var index:int = 0;
			var bitems:Vector.<BonusItem> = new Vector.<BonusItem>;
			for (var i:String in items) {
				var bitem:BonusItem = new BonusItem(int(i), items[i]);
				bitem.visible = false;
				bitems.push(bitem);
			}
			
			if (bitems.length > 0) {
				if (delay > 0 && bitems.length > 1) {
					timer = new Timer(delay, bitems.length);
					timer.addEventListener(TimerEvent.TIMER, onTimer);
					timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
					timer.start();
				}else {
					for (var j:int = 0; j < bitems.length; j++) showElement(j);
				}
			}
			
			if (addToStock) App.user.stock.addAll(items);
			if (updateUI) App.ui.upPanel.update();
			
			function onTimer(e:TimerEvent):void {
				showElement(timer.currentCount - 1);
			}
			function onTimerComplete(e:TimerEvent):void {
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			}
			function showElement(id:int):void {
				var point:Point;
				if (target is DisplayObject) {
					point = BonusItem.localToGlobal(target, 'center');
				}else if(target is Point) {
					point = target;
				}else {
					return;
				}
				point.x -= bitems[id].width / 2;
				point.y -= bitems[id].height / 2;
				bitems[id].visible = true;
				bitems[id].cashMove(point, App.self.windowContainer);
			}
		}
		
		public static function localToGlobal(target:DisplayObject, type:String = 'center'):Point {
			var point:Point = new Point(target.x, target.y);
			
			if (type == 'center') {
				point.x += target.width / 2;
				point.y += target.height / 2;
			}
			
			while (true) {
				if (target is Stage || target.parent == null) {
					break;
				}else if (target.parent != null) {
					target = target.parent;
					point.x += target.x;
					point.y += target.y;
				}
			}
			
			return point;
		}
	}
}