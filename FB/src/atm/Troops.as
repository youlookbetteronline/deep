package atm 
{
	import api.ExternalApi;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Load;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.Hints;
	import ui.UserInterface;
	import units.Anime;
	public class Troops extends LayerX
	{
		
		private var animeTroop:Anime;
		private var troopsSprite:LayerX = new LayerX();
		public static const LANTERN:uint = 585;
		public static const LANTERN_BLUE:uint = 586;
		public static const LANTERN_RED:uint = 587;
		public static const WBALOON:uint = 637;
		public static const OWL:uint = 1702;
		
		public static const DIR_RIGHT:Boolean = false;
		public static const DIR_LEFT:Boolean = true;
		
		public static var direction:Boolean = DIR_LEFT;
		
		public static var troopz:Array = [];
		public static var delay:uint = 50;
		public static var initTime:uint = 0;
		public static var troopsArray:Array = ['medusa', 'clown_troop', 'treska_troop', 'doctor_troop'];
		
		public var shadow:Bitmap;
		private var dX:Number = 0;
		private var dY:Number = 0;
		private var amplitude:Number = 40;
		private var altitude:uint = 300;
		private var currentTroop:int = 0;
		
		private var viewportX:int;
		private var viewportY:int;
		
		private var start:Object;
		private var finish:Object;
		private var vittes:Number;
		private var t:Number = 0;
		private var live:Boolean = false;
		public var position:Object = null
		
		public function Troops(object:Object) 
		{
			//this.position = object.position;
			//this.id = object.id || 0;
			Troops.troopz.push(this);
			//var ii:String = troopsArray[int(Math.random() * troopsArray.length)];
			//layer = Map.LAYER_TREASURE;
			currentTroop = int(Math.random() * troopsArray.length);
			Load.loading(Config.getSwf("Atmosphere", troopsArray[currentTroop]), onLoad);
			
			//Load.loading(Config.getSwf(info.type, info.preview), onLoad);
			//Load.loading(Config.getSwf('Tools', 'lantern'), onLoad);
			//trace(App.data);
			//this.addEventListener(MouseEvent.MOUSE_OVER, oMove);
			//this.addEventListener(MouseEvent.MOUSE_MOVE, mMove);
			//this.addEventListener(MouseEvent.MOUSE_OUT, uMove);
		}
		
		public static function dispose():void
		{
			/*App.self.setOffTimer(timer);
			for each(var troop:Troops in Troops.troopz) {
				troop.uninstall();
				
			}
			Troops.troopz = [];*/
			
		}
		
		public static function init():void 
		{
			/*if (App.user.quests.tutorial) 
			{
				App.self.addEventListener(AppEvent.ON_FINISH_TUTORIAL, start);
				return;
			}*/
			
			start();
		}
		
		private static function start(e:* = null):void 
		{
			//initTime = App.time;
			App.self.setOnTimer(timer);
			//if(Troops.troopz.length < 1)
				//addTroops();
		}
		
		public static function timer():void 
		{
			if (App.user.worldID == User.AQUA_HERO_LOCATION)
				return;
			if (initTime + delay <= App.time)
			{
				initTime = App.time;
				addTroops();
				addTroops();
				//delay = int(Math.random() * 15) + 8;
				delay = 60;
			}
		}
		
		private static function addTroops():void
		{
			var sid:uint = 0;
			var worldID:uint = App.user.worldID;
			var info:Object = App.data.storage[worldID];
			
			/*if (!info) return;
			
			if (info.lantern) {
				if (info.lantern is Number) {
					sid = info.lantern;
				}else {
					var list:Array = [];
					for (var s:* in info.lantern) {
						list.push(s);
					}
					sid = list[int(list.length * Math.random())];
				}
				
				info = App.data.storage[sid];
				if (!info) return;*/
				
				new Troops( { sid:sid } );
			//}
			
		}
		
		private function uMove(e:MouseEvent):void 
		{
			//App.map.untouches()
		}
		
		private function mMove(e:MouseEvent):void 
		{
			//App.map.untouches()
			//this.touch = true;
		}
		
		private function oMove(e:MouseEvent):void 
		{
			App.user.quests.startTrack()
			App.user.quests.currentTarget = this;
			
			setTimeout(function():void {
				App.user.quests.stopTrack()	
			},200)
			//App.map.untouches()
			//this.touch = true;
		//	e.stopImmediatePropagation();
			
		}
			
		/*override public function get bmp():Bitmap 
		{
			return animationBitmap;
		}*/
		public var troopsParams:Object = {
			'medusa':{
				scale1		:.3,
				scale2		:.1,
				distance	:350
			},
			'clown_troop':{
				scale1		:.8,
				scale2		:.1,
				distance	:150
			},
			'treska_troop':{
				scale1		:.4,
				scale2		:.1,
				distance	:150
			},
			'doctor_troop':{
				scale1		:.7,
				scale2		:.1,
				distance	:150
			}
		};
		
		private var troopsVector:Vector.<Anime> = new Vector.<Anime>();
		private var count:int = 7;
		public function onLoad(data:*):void 
		{
			if (data.animation)
			{
				var framesType:String;
				for (framesType in data.animation.animations) break;
				
				for (var i:int = 0; i < count; i++)
				{
					animeTroop = new Anime(data, framesType, data.animation.ax, data.animation.ay);
					troopsVector.push(animeTroop);
				}
				
				for each(var trup:Anime in troopsVector)
				{
					trup.scaleX = trup.scaleY = troopsParams[troopsArray[currentTroop]].scale1 + Math.random() * troopsParams[troopsArray[currentTroop]].scale2;
					trup.addAnimation();
					trup.startAnimation(true);
					trup.x = Math.random() * troopsParams[troopsArray[currentTroop]].distance;
					trup.y = Math.random() * troopsParams[troopsArray[currentTroop]].distance;
					
					troopsSprite.addChild(trup);
					/*if (!trup.hitTestObject(titleBackingBmap) && !star1.hitTestObject(exit) && star1.hitTestObject(roofBmap))
					{
						bodyContainer.addChild(star1);
						
						break;
					}*/
				}
				//troopsSprite.addChild(animeTroop);
				App.map.mTreasure.addChild(troopsSprite);
				troopsSprite.alpha = 0;
				TweenLite.to(troopsSprite, 2, {alpha: 1, onComplete: function():void
				{
					
				}});
				
				troopsSprite.tip = function():Object {
					return {
						title:Locale.__e("flash:1382952379937"),
						text:Locale.__e("flash:1382952379937")
					};
				};
				startFly();
				//Size.size(animeTroop, 90, 90);
			}
		}
		
		private function startFly():void
		{
			live = true;
			//ay -= altitude;
			/*shadow = new Bitmap(UserInterface.textures.shadow);
			addChildAt(shadow, 0);
			shadow.x = - shadow.width / 2;
			shadow.y = - 4;
			shadow.alpha = 0.5;*/
			
			amplitude += int(Math.random() * 40 - 20);
			
			direction = (Math.random() > 0.5)?DIR_LEFT:DIR_RIGHT;
			
			var isoStX:int;
			var isoStY:int;
			var isoFnX:int;
			var isoFnY:int;
			
			if (direction) {
				isoStX = int(Math.random() * (Map.rows - 10) + 5);
				isoStY = -10;
				isoFnX = isoStX;
				isoFnY = Map.rows + 10;
			}else {
				flip();
				isoStX = -10;
				isoStY = int(Math.random() * (Map.cells - 10) + 5);
				isoFnX = Map.cells + 10;
				isoFnY = isoStY;
			}

			if(position == null) {
				start = IsoConvert.isoToScreen(isoStX, isoStY, true);
				finish = IsoConvert.isoToScreen(isoFnX, isoFnY, true);
			
				_altitude = altitude;
			}else {
				start = position;
				finish = IsoConvert.isoToScreen(isoFnX, isoFnY, true);
				_altitude = 0;
			}
			/*if(start.y < finish.y){
				troopsSprite.scaleY = troopsSprite.scaleY *-1;
			}*/
			if(start.x < finish.x){
				troopsSprite.scaleX = troopsSprite.scaleX *-1;
			}
			
			var maxNum:Number = 0.0008;
			var minNum:Number = 0.0005;
			
			vittes = Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum;

			
			App.self.setOnEnterFrame(flying);
			this.visible = true;
		}
		
		public function flip():void
		{
			scaleX = -scaleX;
			x -= width * scaleX;
		}
		
		private var _altitude:int = 0;
		private var dAlt:uint = 2;
		private function flying(e:Event = null):void
		{
			t += vittes * (32 / App.self.fps);
			
			if (t >= 1 && live)
			{
				live = false;
				TweenLite.to(this, 0.5, { alpha:0, onComplete:uninstall } );
			}
			
			var nextX:Number = int(start.x + (finish.x - start.x) * t);
			var nextY:Number = int(start.y + (finish.y - start.y) * t);
			
			//var place:Object = IsoConvert.isoToScreen(nextX, nextY, false);
				
			troopsSprite.x = nextX;// place.x;
			troopsSprite.y = nextY;// place.y;
			
			if (nextX < 0 || nextY < 0)
				dispose();
			
			if (_altitude < altitude)
				_altitude += dAlt;
			
			//ay = (amplitude * Math.sin(0.01 * x)) - _altitude;
		}
		
		public function click():Boolean 
		{
			//if (!clickable) return false;
			//if (! App.user.stock.check(Stock.FANTASY, 1)) return false;
			
			//haloEffect(null, this.parent);
			
			/*Post.send( {
				ctr:'Gift',
				act:'light',
				uID:App.user.id,
				sID:sid
				}, onLightAction);
			
			clickable = false;
			touchable = false;
			ordered = true;*/
			
			return true;
		}
		
		/*private function removeFromStock():void 
		{
			if (sid != LANTERN)
			{
				if(App.user.stock.count(sid) > 0)
					App.user.stock.sell(sid, 1);
			}
		}*/
		
		/*private function onLightAction(error:int, data:Object, params:Object = null):void
		{
			if (error)
			{
				if (error == 23 || error == 19)
				{
					uninstall();
					return;
				}
				
				Errors.show(error, data);
				return;
			}
			
			if (App.social == 'FB') {
				ExternalApi._6epush([ "_event", { "event":"gain", "item":"lantern_bonus" } ]);
			}
			
			Hints.minus(Stock.FANTASY, 1, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y + ay*App.map.scaleY), true);
			
			if (data.hasOwnProperty("bonus")) {
				Treasures.bonus(data.bonus, new Point(this.x, this.y + ay));
				SoundsManager.instance.playSFX('bonus');
			}
			uninstall();
			
			if (data.hasOwnProperty(Stock.FANTASY)) {
				App.user.stock.setFantasy(data[Stock.FANTASY]);
			}
		}*/
		
		public function uninstall():void
		{
			TweenLite.to(troopsSprite, 2, {alpha: 0, onComplete: function():void
			{
				//unitToMove.visible = false;
				var index:int = troopz.indexOf(this);
				troopz.splice(index, 1);
				if(troopsSprite.parent)
					troopsSprite.parent.removeChild(troopsSprite);
			}});
			//this.removeEventListener(MouseEvent.MOUSE_OVER, oMove);
			//this.removeEventListener(MouseEvent.MOUSE_MOVE, mMove);
			//this.removeEventListener(MouseEvent.MOUSE_OUT, uMove);
			//App.self.setOffEnterFrame(flying);
			//App.map.removeUnit(this);
		}
		
		/*public function addAnimation():void
		{
			super.addAnimation();
			for each(var multipleObject:Object in multipleAnime) {
				animationBitmap = multipleObject.bitmap;
				return;
			}
		}*/
		
		/*override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case TOCHED: animationBitmap.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; break;
				case DEFAULT: animationBitmap.filters = []; break;
			}
			_state = state;
		}*/
	}
}