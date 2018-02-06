package 
{
	import com.adobe.air.crypto.EncryptionKeyGenerator;
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
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import ui.Hints;
	import com.greensock.TweenLite;
	import ui.UserInterface;
	import units.FakeHero;
	import units.Unit;
	import wins.CollectionMsgWindow;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	
	public class BonusItem extends Sprite 
	{		
		[Embed(source="blick_bitmap.png", mimeType="image/png")]
		private var Blick_Bitmap:Class;
		private var blickBMD:BitmapData = new Blick_Bitmap().bitmapData;
		private var bmapsDict:Dictionary;
		
		private static const PATH_TIME:Number = 1;// 0.8;
		//public var owner:Object;
		public var bitmap:Bitmap;
		private var sID:uint;
		private var nominal:uint;
		private var count:uint;
		private var bezieDrop:BezieDrop;
		private var layer:*;
		private var scaling:Boolean = true;
		private var _stween:TweenLite;
		private var _ltween:TweenLite;
		private var _tween:TweenMax;
		
		public var destObject:* = null;
		
		private var preloader:Preloader = new Preloader();
		
		public function BonusItem(sID:uint, nominal:uint, scaling:Boolean = true, destObject:* = null)
		{
			this.sID = sID;
			this.nominal = nominal;
			this.count = count;
			this.scaling = scaling;
			this.destObject = destObject;
			bitmap = new Bitmap();
			addChild(bitmap);
			
			if (!bmapsDict)
				bmapsDict = new Dictionary(true);
				
			if (sID == Stock.COINS)
			{
				if (nominal == Treasures.NOMINAL_1)				bitmap.bitmapData = UserInterface.textures.goldenPearl;
				else if (nominal == Treasures.NOMINAL_2)		bitmap.bitmapData = UserInterface.textures.goldenPearl;//bitmap.bitmapData = UserInterface.textures.coins3;
				else if (nominal == Treasures.NOMINAL_3)		bitmap.bitmapData = UserInterface.textures.goldenPearl;
				else 											bitmap.bitmapData = UserInterface.textures.goldenPearl;
					
				onImageComplete(bitmap);
			}
			else if (sID == Stock.EXP)
			{
				if (nominal == Treasures.NOMINAL_1)				bitmap.bitmapData = UserInterface.textures.expIco;
				else if (nominal == Treasures.NOMINAL_2)		bitmap.bitmapData = UserInterface.textures.exp2;
				else if (nominal == Treasures.NOMINAL_3)		bitmap.bitmapData = UserInterface.textures.exp4;
				else                                            bitmap.bitmapData = UserInterface.textures.expIco;
				
				onImageComplete(bitmap);
			}
			else
			{
				if (bmapsDict.hasOwnProperty(sID)){
					onImageComplete(bmapsDict[sID]);
				}else{
					addChild(preloader);
					preloader.scaleX = preloader.scaleY = 0.6;
					
					Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onImageComplete);
				}
			}
			if (this.destObject)
				cashTimeout = setTimeout(cash, 1000 + Math.random()*1000);
			else
				cashTimeout = setTimeout(cash, 3000 + Math.random()*3000);
		}
		
	
		private var cashTimeout:int;
		private var maska:Bitmap;
		public function onImageComplete(data:Bitmap):void
		{
			if (!bitmap)
				return;
			bitmap.bitmapData = data.bitmapData;
			if(contains(preloader)){
				removeChild(preloader);
				bmapsDict[sID] = bitmap;
			}
			
			bitmap.smoothing = true;
			
			if (scaling && App.data.storage[sID].mtype != 3 && (bitmap.width >= 70 || App.data.storage[sID].mtype == 4 || bitmap.height >= 70))
				bitmap.scaleX = bitmap.scaleY = 0.6;
				
			if (sID == Stock.FANT)
				bitmap.scaleX = bitmap.scaleY = 0.5;
			
			if (sID == Stock.FANTASY)
				bitmap.scaleX = bitmap.scaleY = 0.5;
			bitmap.x = -(bitmap.width)/ 2;
			bitmap.y = -(bitmap.height) / 2;
			
			
			maska = new Bitmap(bitmap.bitmapData);
			addChild(maska);
			maska.x = bitmap.x;
			maska.y = bitmap.y;
			maska.scaleX = bitmap.scaleX;
			maska.scaleY = bitmap.scaleY;
			
			addBlick();
		}
		
		private var blick:Bitmap = new Bitmap();
		private function addBlick():void {
			//blick ;
			if (maska == null)
				return;
			
			blick.bitmapData = blickBMD;
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
			
			randomTime = 400 + int(600 * Math.random());
			sTimer = setTimeout(startBlick, 1000);
		}
		
		private var sTimer:uint = 0;
		private var bTimer:uint = 0;
		private var randomTime:int;
		private function startBlick():void {
			if (maska){
				clearTimeout(sTimer);
				clearTimeout(bTimer);
				blick.y = maska.y - blick.height;
				_ltween = TweenLite.to(blick, 3, {y:maska.height, onComplete:pauseBlick, ease:Strong.easeOut});
			}
		}
		
		private function pauseBlick():void {
			clearTimeout(bTimer);
			bTimer = setTimeout(startBlick, randomTime);
		}
		
		private function stopBlick():void {
			clearTimeout(sTimer);
			clearTimeout(bTimer);
			//if (bTimer > 0) {
				//clearTimeout(bTimer);
				//bTimer = 0;
			//}
		}
		
		public function move(time:int):void {
			setTimeout(doMove, time);
			this.visible = false;
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
			clearTimeout(cashTimeout);
			stopBlick();
			var that:* = this;
			
			if(bezieDrop != null) bezieDrop.stop();
			bezieDrop = null;
			
			if(App.map && App.map.mTreasure.contains(that)){
				App.map.mTreasure.removeChild(that);
			}else{
				remove();
				return;
			}
			
			var totalCount:uint = nominal;
			if(!App.user.quests.tutorial)
				Hints.plus(sID, (totalCount > 0) ? totalCount : 1, new Point((that.x*App.map.scaleX + that.width / 2)+App.map.x, that.y*App.map.scaleY+App.map.y));
			
			var place:Point = new Point(x + App.map.x/App.map.scaleX, y + App.map.y/App.map.scaleY);
			place.x *= App.map.scaleX;
			place.y *= App.map.scaleY;
			
			this.layer = App.ui;
			x = place.x;
			y = place.y;
			layer.addChild(this);
			place.y -= 120;
			
			this.scaleX = this.scaleY =  0.2;
			
			_stween = TweenLite.to(this, 0.3, { scaleY:1.1, scaleX:1.1, ease:Back.easeOut});
			_ltween = TweenLite.to(this, 0.3, {  y:place.y, ease:Strong.easeOut, onComplete:function():void {
				cashMove(place, layer);
			}});
			
			if (onCash != null)
				onCash();
		}
		
		public function cashMove(place:Point, layer:*):void
		{
			clearTimeout(cashTimeout);
			stopBlick();
			this.layer = layer;
			this.scaleX = this.scaleY =  1.1;
			x = place.x;
			y = place.y;
			layer.addChild(this);
			
			if (destObject != null /*&& destObject.sIDs.indexOf(sID) != -1*/) {
				toDestinationObject();
				return;
			}
			/*if(owner){
				toOwner();
				return;
			}*/
			
			switch(sID) {
				case Stock.COINS:	toCoinsBar(); App.ui.upPanel.update(['coins']); break;
				case Stock.MOXIE: 	toMoxieBar(); App.ui.upPanel.update(['moxie']); break;
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
				default :
					if (App.data.storage[sID].mtype == 4)
						toCollections();
					else
						toStock();
					break;
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
			if (destObject.target is FakeHero){
				if (!destObject.target.icon)
				{
					remove();
					return;
				}
				p = { x:(destObject.target.icon.x + destObject.target.icon.width / 2 + App.map.x) * App.map.scaleX, y:(destObject.target.icon.y + destObject.target.icon.height / 2 + App.map.y) * App.map.scaleY};
				//p = { x:destObject.target.x + App.map.x, y:destObject.target.y + App.map.y};
				tween(this, p, remove,  [destObject.target.icon, 0xFFFF00]);
			}
			else
				_tween = TweenMax.to(this, PATH_TIME, { x:p.x, y:p.y, onComplete:remove});
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
			
			_tween = TweenMax.to(target, PATH_TIME, {bezierThrough:bezierPoints, orientToBezier:false, onComplete:onComplete, onCompleteParams:onCompleteParams});
		}
		
		private function toCoinsBar():void 
		{
			SoundsManager.instance.playSFX('coin');
			var bttn:* = App.ui.upPanel.coinsSprite;
			var p:Object = { x:bttn.x + App.ui.upPanel.x + 19 + App.ui.upPanel.leftCont.x, y:bttn.y + App.ui.upPanel.y + 19 + App.ui.upPanel.leftCont.y};
			tween(this, p, remove, [App.ui.upPanel.coinsBar, 0xFFFF00]);
		}
		
		private function toMoxieBar():void 
		{
			SoundsManager.instance.playSFX('coin');
			var bttn:* = App.ui.upPanel.moxieSprite;
			var p:Object = { x:bttn.x + App.ui.upPanel.x + 19 + App.ui.upPanel.leftCont.x, y:bttn.y + App.ui.upPanel.y + 19 + App.ui.upPanel.leftCont.y};
			tween(this, p, remove, [App.ui.upPanel.moxieBar, 0xFFFF00]);
		}
		
		private function toExpBar():void 
		{
			SoundsManager.instance.playSFX('experience3');
			var bttn:* = App.ui.upPanel.expSprite;
			var p:Object = { x:bttn.x + App.ui.upPanel.x - 46  + App.ui.upPanel.rightCont.x - 24, y:bttn.y + App.ui.upPanel.y + 23 + App.ui.upPanel.rightCont.y};
			tween(this, p, remove, [App.ui.upPanel.expBar, 0xFFFF00]);
		}
		
		private function toJam():void {
			/*var bttn:* = App.ui.upPanel.jamBttn;
			var p:Object = { x:bttn.x + App.ui.upPanel.x + 34, y:bttn.y + App.ui.upPanel.y + 32 };
			tween(this, p, remove, [bttn, 0x7b1012]);*/
		}
		
		private function toFantBar():void {
			SoundsManager.instance.playSFX('map_sound_2');
			var bttn:* = App.ui.upPanel.fantSprite;
			var p:Object = { x:bttn.x + App.ui.upPanel.x + 2 + App.ui.upPanel.leftCont.x, y:bttn.y + App.ui.upPanel.y + 20 + App.ui.upPanel.leftCont.y};
			tween(this, p, remove,  [App.ui.upPanel.fantsBar, 0xFFFF00]);
		}
		
		private function toEnergyBar():void {
			var bttn:*;
			var p:Object;
			SoundsManager.instance.playSFX('map_sound_2');
			if (App.user.mode == User.GUEST) 
			{
				bttn = App.ui.bottomPanel.bttnMainHome;
				p = { x:bttn.parent.x + bttn.x + bttn.width/2 , y:bttn.parent.y + bttn.y + bttn.height/2 - 4};
			}else 
			{
				bttn = App.ui.upPanel.energySprite;
				p = { x:bttn.x + App.ui.upPanel.x + App.ui.upPanel.rightCont.x - 28, y:bttn.y + App.ui.upPanel.y + App.ui.upPanel.rightCont.y + 18};
			}
			tween(this, p, remove, [App.ui.upPanel.energyBar, 0xFFFF00]);
		}
		
		private function toGuestEnergyBar():void {
			SoundsManager.instance.playSFX('map_sound_2');
			var bttn:* = App.ui.leftPanel.guestEnergy.getChildAt(0);
			var p:Object = { x:bttn.x + App.ui.leftPanel.guestEnergy.x + App.ui.leftPanel.x + 36, y:bttn.y + App.ui.leftPanel.guestEnergy.y + App.ui.leftPanel.y + 28 };
			tween(this, p, remove, []);
		}
		
		/*private function toOwner():void {
			var bttn:*;
			var p:Object;
			
			var pnt:Point = Window.localToGlobal(owner['personage']);
			p = {x:pnt.x, y:pnt.y};	
			
			tween(this, p, remove, [bttn, 0xFFFF00]);
		}*/
		
		private function toStock():void {
			var bttn:*;
			var p:Object;
			SoundsManager.instance.playSFX('takeMaterial');
			if (App.user.mode == User.GUEST) {
				bttn = App.ui.bottomPanel.bttnMainHome;
				p = { x:bttn.parent.x + bttn.x + bttn.width/2, y:bttn.parent.y + bttn.y + bttn.height/2 - 4};
			} /*else if (User.inExpedition) {
				p = { x:App.self.stage.stageWidth - 40, y:App.self.stage.stageHeight - 45 };			
			}*/ else {
				bttn = App.ui.bottomPanel.bttnMainStock;
				p = { x:bttn.x + bttn.width/2 + App.ui.bottomPanel.mainPanel.x, y:bttn.y + bttn.height/2 +App.ui.bottomPanel.mainPanel.y };
				//p = { x:App.self.stage.stageWidth - 40, y:App.self.stage.stageHeight - 120 };
			}	
			
			tween(this, p, remove, [bttn, 0xFFFF00]);
		}
		
		private function toCollections():void 
		{
			var bttn:*;
			var p:Object;
			SoundsManager.instance.playSFX('glow');
			
			if (CollectionMsgWindow.self)
				CollectionMsgWindow.self.dispose();
			
			var collect:CollectionMsgWindow  = new CollectionMsgWindow({sid:this.sID});
			collect.show();
			for each(var itm:* in collect.items)
			{
				if (itm.sID == this.sID)
					break;
			}
			/*if (App.user.mode == User.GUEST) 
			{
				bttn = App.ui.bottomPanel.bttnMainHome;
				p = { x:bttn.parent.x + bttn.x + bttn.width/2, y:bttn.parent.y + bttn.y + bttn.height/2 - 4};
			}else {*/
			if (!itm)
			{
				remove();
				return;
			}
			bttn = itm;
			p = { x:bttn.parent.parent.x + bttn.parent.parent.parent.x + bttn.x + bttn.width / 2, y:bttn.parent.parent.y + bttn.parent.parent.parent.y + bttn.y + bttn.height / 2 - 4};
			//}
			tween(this, p, remove, [bttn, 0xFFFF00]);
		}
		
		public function remove(target:* = null, color:uint = 0xFFFF00):void 
		{
			clearTimeout(cashTimeout);
			clearTimeout(sTimer);
			clearTimeout(bTimer);
			if (target) 
				App.ui.glowing(target, color);
			if (this.parent)
			this.parent.removeChild(this);
			layer = null;
			if (_stween){
				_stween.complete(true, true);
				_stween.kill();
				_stween = null;
			}
			if (_ltween){
				_ltween.complete(true, true);
				_ltween.kill();
				_ltween = null;
			}
			if (_tween){
				_tween.complete(true, true);
				_tween.kill();
				_tween = null;
			}
			bitmap = null;
			maska = null;
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
		
		/*private function toMap(sid:uint):void 
		{
			remove();
			var unit:Unit = Unit.add( { sid:sid, id:1, x:39, z:46 } );
			unit.buyAction();
		}*/
	}
}