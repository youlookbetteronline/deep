package units 
{
	import api.ExternalApi;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.Hints;
	import ui.UserInterface;
	import wins.NeedResWindow;
	public class Lantern extends AUnit
	{
		public static const LANTERN:uint = 585;
		public static const LANTERN_BLUE:uint = 586;
		public static const LANTERN_RED:uint = 587;
		public static const WBALOON:uint = 637;
		public static const OWL:uint = 1702;
		public static const DIR_RIGHT:Boolean = false;
		public static const DIR_LEFT:Boolean = true;
		
		public static var direction:Boolean = DIR_LEFT;
		public static var lanterns:Array = [];
		public static var delay:uint = 50;
		public static var initTime:uint = 0;
		
		public var position:Object;
		public var shadow:Bitmap;
		
		private var dX:Number = 0;
		private var dY:Number = 0;
		private var amplitude:Number = 40;
		private var altitude:uint = 300;
		private var viewportX:int;
		private var viewportY:int;
		private var start:Object;
		private var finish:Object;
		private var vittes:Number;
		private var t:Number = 0;
		private var live:Boolean;
		private var _altitude:int = 0;
		private var dAlt:uint = 2;
		private var _mTween:TweenLite;
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case TOCHED: animationBitmap.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; break;
				case DEFAULT: animationBitmap.filters = []; break;
			}
			_state = state;
		}
		override public function get bmp():Bitmap {
			return animationBitmap;
		}
		public function Lantern(object:Object) 
		{
			object.hasLoader = false;
			this.position = object.position;
			this.id = object.id || 0;
			Lantern.lanterns.push(this);
			
			layer = Map.LAYER_TREASURE;
			
			super(object);
			
			touchable	= true;
			clickable	= true;
			transable 	= false;
			moveable 	= false;
			removable 	= false;
			rotateable  = false;
			
			
			Load.loading(Config.getSwf(info.type, info.preview), onLoad);
			
			tip = function():Object {
				var _bitmap:Bitmap = new Bitmap();
				Load.loading(Config.getIcon(App.data.storage[Numbers.firstProp(info.require).key].type, App.data.storage[Numbers.firstProp(info.require).key].preview), 
				function(data:Bitmap):void
				{
					if (_bitmap)
					{
						_bitmap.bitmapData = data.bitmapData;
						Size.size(_bitmap, 40, 40);
					}
				});
				
				var count:String = String(Numbers.firstProp(info.require).val);
				var desc:String = Locale.__e('flash:1409654204888');
				
				if (App.data.storage[Numbers.firstProp(info.require).key].mtype != 3)
				{
					count = count + ' / ' + String(App.user.stock.count(Numbers.firstProp(info.require).key));
				}
				
				return {
					title		:info.title,
					desc		:desc,
					count1		:count,
					icon		:_bitmap
				};
			};
			this.addEventListener(MouseEvent.MOUSE_OVER, oMove);
		}
		
		private function oMove(e:MouseEvent):void 
		{
			App.user.quests.startTrack()
			App.user.quests.currentTarget = this;
			
			setTimeout(function():void {
				App.user.quests.stopTrack()	
			},200)
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			
			textures = data;
			
			viewportX = Map.mapWidth - (Map.mapWidth + App.map.x);
			viewportY = Map.mapHeight - (Map.mapHeight + App.map.y);
			
			if(position == null) {
				x = viewportX + Math.random() * App.self.stage.stageWidth;
				y = viewportY + Math.random() * App.self.stage.stageHeight;
			} else {
				x = position.x;
				y = position.y;
			}
			
			initAnimation();
			startAnimation();
			startFly();
		}
		
		private function startFly():void
		{
			live = true;
			ay -= altitude;
			
			shadow = new Bitmap(UserInterface.textures.shadow);
			addChildAt(shadow, 0);
			shadow.x = - shadow.width / 2;
			shadow.y = - 4;
			shadow.alpha = 0.5;
			
			amplitude 	+= int(Math.random() * 40 - 20);
			
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
				start = IsoConvert.isoToScreen(isoStX,isoStY, true);
				finish = IsoConvert.isoToScreen(isoFnX,isoFnY, true);
			
				_altitude = altitude;
			}else {
				start = position;
				finish = IsoConvert.isoToScreen(isoFnX,isoFnY, true);
				_altitude = 0;
			}
			
			var maxNum:Number = 0.0008;
			var minNum:Number = 0.0005;
			
			vittes = Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum;
			
			x = start.x;
			y = start.y;
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_LANTERN_SPAWN));
			if (!(this.info.hasOwnProperty('moving') && this.info.moving == 0))
				App.self.setOnEnterFrame(flying);
			this.visible = true;
		}
		
		private function flying(e:Event = null):void
		{
			checkDrawMode();
			t += vittes * (32 / App.self.fps);
			
			if (t >= 1 && live)
			{
				live = false;
				_mTween = TweenLite.to(this, 0.5, { alpha:0, onComplete:uninstall } );
			}
			
			var nextX:Number = int(start.x + (finish.x - start.x) * t);
			var nextY:Number = int(start.y + (finish.y - start.y) * t);
				
			x = nextX;
			y = nextY;
			
			if (_altitude < altitude)
				_altitude += dAlt;
		}
		
		private function removeFromStock():void {
			if (sid != LANTERN)
			{
				if(App.user.stock.count(sid) > 0)
					App.user.stock.sell(sid, 1);
			}
		}
		
		private function onLightAction(error:int, data:Object, params:Object = null):void
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
			
			Hints.minus(Numbers.firstProp(info.require).key, Numbers.firstProp(info.require).val, new Point(), true, null, 0, {personage:this});
			
			if (data.hasOwnProperty("bonus")) {
				Treasures.bonus(data.bonus, new Point(this.x, this.y + ay));
				SoundsManager.instance.playSFX('bonus');
			}
			uninstall();
		}
		
		public override function click():Boolean
		{
			if (!clickable) return false;
			if (!App.user.stock.checkAll(info.require))
			{
				if (App.data.storage[Numbers.firstProp(info.require).key].mtype != 3)
				{
					new NeedResWindow({
						title:Locale.__e("flash:1435241453649"),  
						text:(sid == 2628) ?Locale.__e('flash:1507892186068') : Locale.__e('flash:1500541592120'),  
						height:230,
						neededItems: info.require,
						button3:true,
						button2:true
					}).show();
				}
				return false;
			}
			App.user.stock.takeAll(info.require);
			
			Post.send( {
				ctr:'Gift',
				act:'light',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:sid
				}, onLightAction);
			
			clickable = false;
			touchable = false;
			ordered = true;
			
			return true;
		}
		
		override public function remove(callback:Function = null):void {
			
		}
		
		public override function uninstall():void
		{
			if (_mTween){
				_mTween.complete(true, true);
				_mTween.kill();
				_mTween = null;
			}
			
			var index:int = lanterns.indexOf(this);
			lanterns.splice(index, 1);
			this.removeEventListener(MouseEvent.MOUSE_OVER, oMove);
			App.self.setOffEnterFrame(flying);
			super.uninstall();
		}
		
		override public function addAnimation():void
		{
			super.addAnimation();
			for each(var multipleObject:Object in multipleAnime) {
				animationBitmap = multipleObject.bitmap;
				return;
			}
		}
		
		public static function dispose():void
		{
			App.self.setOffTimer(timer);
			for each(var lantern:Lantern in Lantern.lanterns) {
				lantern.uninstall();
				lantern = null;
			}
			Lantern.lanterns = [];
		}
		
		public static function init():void
		{
			if (App.user.mode == User.PUBLIC)
				return;
			if (App.user.quests.tutorial) {
				App.self.addEventListener(AppEvent.ON_FINISH_TUTORIAL, start);
				return;
			}
			Lantern.start();
		}
		
		public static function timer():void {
			if (initTime + delay <= App.time) {
				initTime = App.time;
				addLantern();
				delay = 60;
				if (App.user.worldID == User.NEPTUNE_MAP)
					delay = 40;
				if (App.user.worldID == User.HUNT_MAP)
					delay = 20;
			}
		}
		
		private static function start(e:* = null):void {
			initTime = App.time;
			App.self.setOnTimer(timer);
			if(Lantern.lanterns.length < 1)
				addLantern();
		}
		
		private static function addLantern():void
		{
			var sid:uint = 0;
			var worldID:uint = App.user.worldID;
			if(App.user.mode != User.OWNER && App.owner){
				worldID = App.owner.worldID;
			}
			var info:Object = App.data.storage[worldID];
			
			if (!info) return;
			
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
				
				if ((App.user.worldID == User.HUNT_MAP || App.user.worldID == User.VILLAGE_MAP) && App.user.mode == User.OWNER)
				{
					var sids:Array = [2083, 2084, 2085, 2086, 2087];
					sid = sids[int(Math.random() * sids.length)];
				}
				info = App.data.storage[sid];
				if (!info) return;
				new Lantern( { sid:sid } );
			}
			
		}
		
	}
}