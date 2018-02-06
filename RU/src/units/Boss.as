package units 
{
	import com.greensock.TweenAlign;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.Hints;
	import wins.CharactersWindow;
	import wins.PurchaseWindow;
	
	public class Boss extends AUnit
	{		
		public static const KILLER_TURKEY:int = 1675,
							SATAN_HELPER:int = 1934,
							LOVE_PAPERPLANE:int = 2150
		
		public static var bosses:Array = [],
					      delay:uint = 50,
						  initTime:uint = 0;
						  static private var bossHaloColor:int;
						  private var require:int;
		
		public var shadow:Bitmap,
				   position:Object = null,
				   direction:String = 'left';	
		
		private var dX:Number = 0,
					dY:Number = 0,
					amplitude:Number = 40,
					altitude:uint = 400,
					viewportX:int,
					viewportY:int,
					start:Object,
					finish:Object,
					firstPos:Object,
					secondPos:Object,
					thirdPos:Object,
					fourthPos:Object,
					vittes:Number,
					t:Number = 0,
					live:Boolean = false,
					mouseOverBoss:Boolean = false,
					clickCounter:int = 0;
					
		public function Boss(object:Object) 
		{
			this.position = object.position;
			this.id = object.id || 0;
			Boss.bosses.push(this);
			
			layer = Map.LAYER_TREASURE;
			
			if (User.inExpedition) 
			{
				this.visible = true;
			}
			
			require = object.require || 0;
			
			super(object);
			
			if (this.sid == Boss.KILLER_TURKEY) 
			{
				currentPath = poss;
				path_L = 17;
			} else if (this.sid == Boss.SATAN_HELPER) 
			{
				currentPath = poss2;
				path_L = 17;
			} else if (this.sid == Boss.LOVE_PAPERPLANE) 
			{
				currentPath = poss3;
				path_L = 24;
			}			
			
			touchable	= true;
			clickable	= true;
			transable 	= false;
			moveable 	= false;
			removable 	= false;
			rotateable  = true;
			takeable	= false;
			
			Load.loading(Config.getSwf(info.type, info.preview), onLoad);
			setMoveParams();
			
			/*if (this.sid == Boss.KILLER_TURKEY) {
				
				count  = Math.round (Math.random() * path_L);
				var bosses:Object = Map.findUnits([Boss.KILLER_TURKEY]);
				for (var i:int = 0; i < bosses.length; i++ ) {
					if (bosses[i].count == count) {
						count  = Math.round (Math.random() * path_L);
						i = 0;
					}	
				}				
				startFly(count);
			}else if (this.sid == Boss.SATAN_HELPER) 
			{
				count  = Math.round (Math.random() * path_L);
				bosses = Map.findUnits([Boss.SATAN_HELPER]);
				for (i = 0; i < bosses.length; i++ ) {
					if (bosses[i].count == count) {
						count  = Math.round (Math.random() * path_L);
						i = 0;
					}	
				}	
				startFly(count);
			}else if (this.sid == Boss.LOVE_PAPERPLANE) 
			{
				count  = Math.round (Math.random() * path_L);
				bosses = Map.findUnits([Boss.LOVE_PAPERPLANE]);
				for (i = 0; i < bosses.length; i++ ) {
					if (bosses[i].count == count) {
						count  = Math.round (Math.random() * path_L);
						i = 0;
					}	
				}	
				startFly(count);
			} else {
				startFly();
			}*/
			
			count = 1 + Math.round (Math.random() * path_L);
			startFly(count);
			
			tip = function():Object { 
				return {
					title:App.data.storage[sid].title,
					text:App.data.storage[sid].description
				};
			};
		}
		
		public static function init():void
		{
			if (App.user.quests.tutorial) {
				App.self.addEventListener(AppEvent.ON_FINISH_TUTORIAL, start);
				return;
			}
				
			start();
		}
		
		private function showIcon(typeItem:String, callBack:Function, mode:int, btmDataName:String = 'productBacking2', scaleIcon:Number = 0.6):void 
		{
			/*if (App.user.mode == User.GUEST)
				return;
			
			if (cloudAnimal) {
				cloudAnimal.dispose();
				cloudAnimal = null;
			}
			
			cloudAnimal = new AnimalCloud(callBack, this, sid, mode);
			cloudAnimal.create(btmDataName);
			
			
			if (this.direction == 'right') 
			{
				cloudAnimal.scaleX = -1;
			}
			if (this.direction == 'left') 
			{
				cloudAnimal.scaleX = scaleX;
			}
			
			cloudAnimal.show();
			cloudAnimal.x = 0;
			cloudAnimal.y = -50;
			
			if (this.sid == Boss.SATAN_HELPER) 
			{
				cloudAnimal.x = 0;
				cloudAnimal.y = -485;
			}
			
			if (this.sid == Boss.LOVE_PAPERPLANE) 
			{
				cloudAnimal.x = 0;
				cloudAnimal.y = -485;
			}
			
			cloudAnimal.pluck(30);
			
			App.self.setOnTimer(hideIcon);
			startTime = App.time;*/
		}
		
		private static function start(e:* = null):void {
			initTime = App.time;
			addBoss();
		}
		
		public static function timer():void {
			if (initTime + delay <= App.time) {
				delay = int(Math.random() * 5) + 5;
			}
		}
		
		public static function addBoss(_lottery:* = null):void
		{			
			var sid:uint;
			var worldID:uint = App.user.worldID;
			if (App.user.mode == User.GUEST)
			{
				
				worldID = App.owner.worldID;
			}
			
			var lottery:int
			if (_lottery != null) {
				lottery = _lottery;
			}else {
				lottery = Math.round(Math.random() * 3);	
			}
			
			var txt:String;
			if (lottery == 0) {
				txt = Locale.__e('flash:1409299164759');
				sid = KILLER_TURKEY;
			}
			if (lottery == 1) {
				txt = Locale.__e('flash:1409299395052');
				sid = SATAN_HELPER;
			}
			if (lottery == 2) {
				txt = Locale.__e('flash:1411568890341');
				sid = LOVE_PAPERPLANE;
			}
			
			bossHaloColor = 0x000000;
			
			if (sid == KILLER_TURKEY)
				bossHaloColor = 0xFFFF00;
			if (sid == SATAN_HELPER)
				bossHaloColor = 0xFFFF00;	
			if (sid == LOVE_PAPERPLANE)
				bossHaloColor = 0xFFFF00;	
			
			var require:int;
			for (var id:* in App.data.storage[sid].require) {
				require = id;
			}
			
			var boss:Boss = new Boss( { sid:sid, require:require } );
			boss.visible = true;;
		}
		
		override public function get bmp():Bitmap {
			return animationBitmap;
		}
		
		public function setMoveParams():void {
			viewportX = Map.mapWidth - (Map.mapWidth + App.map.x);
			viewportY = Map.mapHeight - (Map.mapHeight + App.map.y);
			
			if(position == null) {
				x = viewportX + Math.random() * App.self.stage.stageWidth;
				y = viewportY + Math.random() * App.self.stage.stageHeight;
			} else {
				x = position.x;
				y = position.y;
			}
		}
		
		override public function onLoad(data:*):void {
			
			super.onLoad(data);
			
			textures = data;
			this.alpha = 0;
			
			TweenLite.to(this, 1, { alpha:1} );	
			
			initAnimation();
			startAnimation();
		}
		
		private var poss:Object = {
			1: {
				x:1518,
				y:795
			},
			2: {
				x:2826,
				y:887
			},
			3: {
				x:1814,
				y:1485
			},
			4: {
				x:1577,
				y:2149
			},
			5: {
				x:2816,
				y:2126
			},
			6: {
				x:3624,
				y:1265
			},
			7: {
				x:3049,
				y:289
			},
			8: {
				x:4004,
				y:583
			},
			9: {
				x:4226,
				y:928
			},
			10: {
				x:4516,
				y:1632
			},
			11: {
				x:3700,
				y:1591
			},
			12: {
				x:3416,
				y:2200
			},
			13: {
				x:4375,
				y:2206
			},
			14: {
				x:2916,
				y:2332
			},
			15: {
				x:2040,
				y:2477
			},
			16: {
				x:1159,
				y:1863
			},
			17: {
				x:1612,
				y:1108
			}
		}
		
		private var poss2:Object = {
			1: {
				x:2285,
				y:571
			},
			2: {
				x:2851,
				y:924
			},
			3: {
				x:3328,
				y:1295
			},
			4: {
				x:2102,
				y:2042
			},
			5: {
				x:3144,
				y:1565
			},
			6: {
				x:3957,
				y:875
			},
			7: {
				x:3224,
				y:385
			},
			8: {
				x:4234,
				y:363
			},
			9: {
				x:4936,
				y:749
			},
			10: {
				x:4930,
				y:1289
			},
			11: {
				x:3610,
				y:1091
			},
			12: {
				x:3563,
				y:1720
			},
			13: {
				x:4569,
				y:2140
			},
			14: {
				x:3153,
				y:1869
			},
			15: {
				x:3171,
				y:2530
			},
			16: {
				x:2020,
				y:1628
			},
			17: {
				x:2320,
				y:873
			}
		}
		
		private var poss3:Object = {
			1: {
				x:3030, 
				y:924
			},
			2: {
				x:3802, 
				y:1428
			},
			3: {
				x:3728, 
				y:2402
			},
			4: {
				x:2700, 
				y:2881
			},
			5: {
				x:3877, 
				y:3314
			},
			6: {
				x:4314, 
				y:2553
			},
			7: {
				x:4332, 
				y:1065
			},
			8: {
				x:5434, 
				y:1020
			},
			9: {
				x:6359, 
				y:1565
			},
			10: {
				x:6291, 
				y:2298
			},
			11: {
				x:5042, 
				y:1446
			},
			12: {
				x:4434, 
				y:2751
			},
			13: {
				x:5659, 
				y:3193
			},
			14: {
				x:3871, 
				y:3532
			},
			15: {
				x:2436, 
				y:3281
			},
			16: {
				x:2312, 
				y:2355
			},
			17: {//last
				x:2851, 
				y:1208
			},
			18: {
				x:3489,  
				y:1700
			},
			19: {
				x:4989,  
				y:1565
			},
			20: {
				x:5334,  
				y:2687
			},
			21: {
				x:3955, 
				y:2093
			},
			22: {
				x:4508,  
				y:802
			},
			23: {
				x:2396,  
				y:1291
			},
			24: {
				x:2161,  
				y:3512
			},
			25: {
				x:3402,  
				y:765
			}
		}
		
		private var currentPath:Object;
		private function startFly(pos:int = 1):void
		{
			live = true;
			ay -= altitude;
			
			amplitude += int(Math.random() * 40 - 20);
			
			//var p1:Object = IsoConvert.isoToScreen(int((Map.rows - 10) + 5), -10, true);
			//var p2:Object = IsoConvert.isoToScreen(int((Map.rows - 10) + 5), Map.cells + 10, true);
			//positions = [p1,p2,p1,p2];
			
			//if(position == null) {
				
			/*	start = currentPath[pos];
				if (pos == path_L) {//17
					finish = currentPath[1];
				}else {
					finish = currentPath[pos+1];
				}
				
				if (finish.x > start.x && this.direction == 'left') {
					this.direction = 'right';
					flip();
				} else if (finish.x < start.x && this.direction == 'right') {
					this.direction = 'left';
					flip();
				}*/
				
				start = currentPath[pos];
				if (pos >= path_L) {//16
					finish = currentPath[1];
				} else {
					finish = currentPath[pos+1];
				}
				
				if (finish.x > start.x && this.direction == 'left') {
					this.direction = 'right';
					flip();
				} else if (finish.x < start.x && this.direction == 'right') {
					this.direction = 'left';
					flip();
				}
				
				
				_altitude = altitude;
			
			vittes = 0.0015;
			
			App.self.setOnEnterFrame(flying);
		}
		
		private var path_L:int = 17		
		private var _altitude:int = 0;
		private var dAlt:uint = 2;
		private var startTime:int;
		private var counter:int;
		private var positions:Array;
		private var count:int = 1;
		private var _fps:uint = 31;
		
		private function flying(e:Event = null):void
		{			
			t += vittes * (32 / (_fps));
			
			if (t >= 1 && live)
			{
				_fps = (App.self.fps)?App.self.fps:31;
				t = 0;
				count++;
				if (count > path_L) {
					count = 1;
				}
				App.self.setOffEnterFrame(flying);
				startFly(count);
			}
			
			if ( !start ) {
				startFly();
				return;
			}
			
			var nextX:Number = int(start.x + (finish.x - start.x) * t);
			var nextY:Number = int(start.y + (finish.y - start.y) * t);
			
			
			x = nextX;
			y = nextY;
			
			if (_altitude < altitude)
				_altitude += dAlt;
			
			if (die) {
				_altitude = 0;
				amplitude = 0;
			}
			
			ay = (amplitude * Math.sin(0.01 * x)) - _altitude;
		}
		
		override public function remove(callback:Function = null):void {
			
		}
		
		private function onCloudClick(e:* = null):void {
			click();
		}
		
		public function get weapoon():int {
			return int(require);
		}
		
		public override function click():Boolean {
			if (!clickable) return false;
			clickCounter++;
			
			if (clickCounter == 1) {
				var clickTime:int = App.time;
				//showIcon('require', onCloudClick, AnimalCloud.MODE_NEED, 'productBacking2'/*, 0.7*/);
				clickCounter = 1;
				return true;
			}
			App.self.setOnTimer(crearClicks);
			function crearClicks():void {
				var duration:int = 1;
				var time:int = duration - (App.time - clickTime);
				if (time < 0) {
					App.self.setOffTimer(crearClicks);
					clickCounter = 0;
				}
			}
			
			if (!App.user.stock.check(require, 1) && clickCounter == 2) {
				clickCounter = 0;
				
				new PurchaseWindow( {
					width:560,
					closeAfterBuy:false,
					autoClose:false,
					itemsOnPage:3,
					find:[weapoon],
					content:PurchaseWindow.createContent("Energy", { out:weapoon }),
					find:require,
					title:App.data.storage[weapoon].title,
					description:Locale.__e("flash:1382952379757"),
					callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
					}
				}).show()
			}
			
			if (clickCounter == 2 && App.user.stock.take(require, 1)) {
				haloEffect(bossHaloColor, this.parent);
				killAnyWay();
			}
			return true;
		}
		
		public function killAnyWay(callback:Function = null):void {
			var cb:Function = onLightAction;
			if (callback != null)
				cb = callback;
			Post.send( {
				ctr:'boss',
				act:'kill',
				wID:App.user.worldID,
				uID:App.user.id,
				sID:sid
			}, cb);
		}
		
		public function storageEvent(count:int = 1):void {
			
		}	
		
		private function onGremDieAction(error:int, data:Object, params:Object = null):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			Hints.minus(require, 1, new Point(0,0), true);
			if (data.hasOwnProperty("bonus")) {
				Treasures.bonus(data.bonus, new Point(this.x, this.y - 500/* + ay*/));
				SoundsManager.instance.playSFX('bonus');
			}
			uninstall();
			
			if (data.hasOwnProperty(Stock.FANTASY)) {
				App.user.stock.setFantasy(data[Stock.FANTASY]);
			}
		}
		
		private function onLightAction(error:int, data:Object, params:Object = null):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			Hints.minus(require, 1, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y + App.map.scaleY), true);
			
			if (data.hasOwnProperty("bonus")) {
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
				SoundsManager.instance.playSFX('bonus');
			}
			
			uninstall();
			
			if (data.hasOwnProperty(Stock.FANTASY)) {
				App.user.stock.setFantasy(data[Stock.FANTASY]);
			}
		}
		
		public override function uninstall():void
		{
			var index:int = bosses.indexOf(this);
			bosses.splice(index, 1);
			
			App.self.setOffEnterFrame(flying);
			App.map.removeUnit(this);
			/*setTimeout(function():void {
				if (App.user.worldID == User.EXP_7) 
				{
					addBoss(1);
				}
				if (App.user.worldID == User.EXP_8) 
				{
					addBoss(2);
				}
				if (App.user.worldID == User.EXP_6) 
				{
					addBoss(0);
				}
			}, 10000 + Math.random()*10000);	*/	
		}
		
		private var die:Boolean = false;
		override public function addAnimation():void
		{
			super.addAnimation();
			
			for each(var multipleObject:Object in multipleAnime) {
				animationBitmap = multipleObject.bitmap;
				return;
			}
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case TOCHED: animationBitmap.filters = [new GlowFilter(0xFFFF00, 1, 6, 6, 7)];
					App.self.setOffEnterFrame(flying);
				break;
				case DEFAULT: animationBitmap.filters = []; 
				mouseOverBoss = false;
				App.self.setOnEnterFrame(flying);
				break;
			}
			_state = state;
		}	
		
		public static function dispose():void
		{
			App.self.setOffTimer(timer);
			for each(var boss:Boss in Boss.bosses) {
				boss.uninstall();
			}
			Boss.bosses = [];
		}
	}
}