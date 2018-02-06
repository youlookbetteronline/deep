package atm 
{
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Load;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import units.Anime;
	public class Troops extends LayerX
	{
		
		public static const DIR_RIGHT:Boolean = false;
		public static const DIR_LEFT:Boolean = true;
		public static var direction:Boolean = DIR_LEFT;
		public static var troopz:Array = [];
		public static var delay:uint = 50;
		public static var initTime:uint = 0;
		public static var troopsArray:Array = ['medusa', 'clown_troop', 'treska_troop', 'doctor_troop', 'white_strange_lamp', 'green_strange_lamp'];
		
		public var position:Object;
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
			},
			'white_strange_lamp':{
				scale1		:.7,
				scale2		:.1,
				distance	:250
			},
			'green_strange_lamp':{
				scale1		:.7,
				scale2		:.1,
				distance	:250
			}
		};
		
		private var troopsVector:Vector.<Anime>;
		private var dX:Number = 0;
		private var dY:Number = 0;
		private var currentTroop:int;
		private var count:int = 7;
		private var altitude:uint = 300;
		private var start:Object;
		private var finish:Object;
		private var vittes:Number;
		private var amplitude:Number = 40;
		private var t:Number = 0;
		private var live:Boolean;
		private var troopsSprite:LayerX;
		private var _altitude:int = 0;
		private var dAlt:uint = 2;
		private var _placeTween:TweenLite;
		private var _endTween:TweenLite;
		private var _removeTween:TweenLite;
		
		public function Troops(object:Object) 
		{
			Troops.troopz.push(this);
			currentTroop = int(Math.random() * troopsArray.length);
			Load.loading(Config.getSwf("Atmosphere", troopsArray[currentTroop]), onLoad);
		}
		
		public function onLoad(data:*):void 
		{
			if (data.animation)
			{
				troopsSprite = new LayerX();
				troopsVector = new Vector.<Anime>()
				var framesType:String;
				for (framesType in data.animation.animations) break;
				
				var animeTroop:Anime ;
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
					troopsSprite.addChild(trup);
					trup.x = Math.random() * troopsParams[troopsArray[currentTroop]].distance;
					trup.y = Math.random() * troopsParams[troopsArray[currentTroop]].distance;
					
				}
				App.map.mTreasure.addChild(troopsSprite);
				troopsSprite.alpha = 0;
				_placeTween = TweenLite.to(troopsSprite, 2, {alpha: 1});
				troopsSprite.tip = function():Object {
					return {
						title:Locale.__e("flash:1382952379937"),
						text:Locale.__e("flash:1382952379937")
					};
				};
				startFly();
			}
		}
		
		private function oMove(e:MouseEvent):void 
		{
			App.user.quests.startTrack()
			App.user.quests.currentTarget = this;
			
			setTimeout(function():void {
				App.user.quests.stopTrack()	
			},200)
			
		}
		
		private function startFly():void
		{
			live = true;
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
			if(start.x < finish.x){
				troopsSprite.scaleX = troopsSprite.scaleX *-1;
			}
			
			var maxNum:Number = 0.0008;
			var minNum:Number = 0.0005;
			
			vittes = Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum;
			
			App.self.setOnEnterFrame(flying);
			this.visible = true;
		}
		private function flying(e:Event = null):void
		{
			t += vittes * (32 / App.self.fps);
			
			if (t >= 1 && live)
			{
				live = false;
				_endTween = TweenLite.to(this, 0.5, { alpha:0, onComplete:uninstall } );
			}
			
			var nextX:Number = int(start.x + (finish.x - start.x) * t);
			var nextY:Number = int(start.y + (finish.y - start.y) * t);
			
			troopsSprite.x = nextX;
			troopsSprite.y = nextY;
			if (_altitude < altitude)
				_altitude += dAlt;
		}
		
		public function flip():void
		{
			scaleX = -scaleX;
			x -= width * scaleX;
		}
		
		public function uninstall():void
		{
			if (_endTween){
				_endTween.complete(true, true);
				_endTween.kill();
				_endTween = null;
			}
			if (_placeTween){
				_placeTween.complete(true, true);
				_placeTween.kill();
				_placeTween = null;
			}
			_removeTween = TweenLite.to(troopsSprite, 2, {alpha: 0, onComplete: function():void
			{
				var index:int = troopz.indexOf(this);
				troopz.splice(index, 1);
				if(troopsSprite && troopsSprite.parent)
					troopsSprite.parent.removeChild(troopsSprite);
			}});
		}
		
		public static function dispose():void
		{
			App.self.setOffTimer(timer);
			for each(var lantern:Troops in Troops.troopz) {
				lantern.uninstall();
				
			}
			Troops.troopz = [];
		}
		
		public static function init():void 
		{
			start();
		}
		
		private static function start(e:* = null):void 
		{
			App.self.setOnTimer(timer);
		}
		
		public static function timer():void 
		{
			if (App.user.worldID == User.AQUA_HERO_LOCATION)
				return;
			if (initTime + delay <= App.time)
			{
				initTime = App.time;
				addTroops();
				delay = 60;
			}
		}
		
		private static function addTroops():void
		{
			var sid:uint = 0;
			var worldID:uint = App.user.worldID;
			var info:Object = App.data.storage[worldID];
			new Troops( { sid:sid } );
		}
	}
}