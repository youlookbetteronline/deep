package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.Hints;
	/**
	 * ...
	 * @author LtCodename
	 */
	public class Rabbit extends Walkgolden
	{		
		public static var initTime:uint = 0;
		public static var delay:uint = 10;
		public static var rabbitCount:uint = 0;
		public static var lanterns:Array = [];
		public static var canGo:Boolean = false;
		private static var dots:Array = [];
		//private var currentDot:uint = 0;
		
		//private var hasProduct:Boolean = false;
		
		//public var ax:int = 0;
		//public var ay:int = 0;
		
		public static function init():void
		{
			
			if (App.user.quests.tutorial) {
				App.self.addEventListener(AppEvent.ON_FINISH_TUTORIAL, start);
				return;
			}
			start();
		}
		
		override public function set framesType(value:String):void {
			super.framesType = value;
		}
		
		override public function onLoop():void
		{	
		}
		
		private static function start(e:* = null):void {
			initTime = App.time;
			App.self.setOnTimer(timer);
			addLantern();
			App.data;
		}
		
		public static function timer():void
		{
			if (initTime + delay <= App.time)
			{
				initTime = App.time;
				addLantern();
				delay = int(Math.random() * 5) + 5;
			}
		}
		
		private static function addLantern():void
		{
			var sid:uint = 0;
			var worldID:uint = App.user.worldID;
			
			if (App.user.mode == User.GUEST)
				worldID = App.owner.worldID;
			
			if (!App.data.storage[sid]) return;
			
			dots = [
				//1
				{ x:71, z:32 },
				{ x:79, z:14 },
				{ x:98, z:46 },
				{ x:90, z:25 },
				{ x:109, z:26 },
				//2
				{ x:108, z:68 },
				{ x:125, z:19 },
				{ x:139, z:75 },
				{ x:138, z:43 },
				{ x:145, z:22 },
				//3
				{ x:39, z:48 },
				{ x:58, z:43 },
				{ x:70, z:86 },
				{ x:93, z:87 },
				{ x:62, z:65 },
				//4
				{ x:10, z:69 },
				{ x:33, z:74 },
				{ x:20, z:101 },
				{ x:44, z:92 },
				{ x:27, z:85 }			 
			];
			
			var currentDot:int = int(Math.random() * dots.length);
			var x:int = dots[currentDot].x;
			var z:int = dots[currentDot].z;
			
			if (rabbitCount <= 2) {
				var node:AStarNodeVO = App.map._aStarNodes[x][z];
				if (!App.map._aStarNodes[x][z].isWall && App.map._aStarNodes[x][z].open) {
					new Rabbit( { sid:sid, x:x, z:z} );
					rabbitCount++;
				}
			}				
		}
		
		public function Rabbit(object:Object) 
		{			
			//object['x'] = 60;
			//object['x'] = int(Math.random() * 10) + 65;
			//object['z'] = 30;

			this.position = object.position;
			this.id = object.id || 0;
			Rabbit.lanterns.push(this);
			
			layer = Map.LAYER_TREASURE;
			super(object);
			
			touchable = true;
			clickable = true;
			moveable = false;
			removable = false;
			rotateable = false;
			
			info.moveable = 1;
			velocities = [0.01];
			info.area = { w:1, h:1 };
			Load.loading(Config.getSwf(info.type, info.preview), onLoad);
			tip = function():Object { 
				return {
					title:App.data.storage[sid].title,
					text:Locale.__e("flash:1382952379937")
				};
			};
			this.addEventListener(MouseEvent.MOUSE_OVER, oMove);
			this.addEventListener(MouseEvent.MOUSE_MOVE, mMove);
			this.addEventListener(MouseEvent.MOUSE_OUT, uMove);
			//this.showPointing("top", - this.width/2 , this.height/2)
			
			App.self.addEventListener(AppEvent.ON_MOUSE_UP, onUp);
			shortcutDistance = 50;
			homeRadius = 20;
			
			if (object.buy || object.fromStock) {
			}
			
			beginCraft(0, crafted);
			
			if (canGo) 
			{
				goHome();
			}
			
			if (Map.ready)
				goHome();
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
		}
		
		private function uMove(e:MouseEvent):void 
		{
		}
		
		private function mMove(e:MouseEvent):void 
		{
		}
		
		private function oMove(e:MouseEvent):void 
		{
			App.user.quests.startTrack()
			App.user.quests.currentTarget = this;
			
			setTimeout(function():void {
				App.user.quests.stopTrack()	
					
				},200)			
		}
		
		override public function onDown():void 
		{
			if (App.user.mode == User.OWNER) {
				if (isMove) {
					clearTimeout(intervalMove);
					isMove = false;
					isMoveThis = false;
				}else{
					var that:Walkgolden = this;
					intervalMove = setTimeout(function():void {
						isMove = true;
						isMoveThis = true
						that.move = true;
						App.map.moved = that;
					}, 200);
				}
			}
		}
		
		private var isMoveThis:Boolean = false;
		public static var isMove:Boolean = false;
		private var intervalMove:int;
		private function onUp(e:AppEvent):void 
		{
			if (isMoveThis) {
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false
			}
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false;
		}
		
		private function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			if (formed) {
				goHome();
			}
		}
		
		override public function onGoHomeComplete():void {
			stopRest();
			var time:uint = Math.random() * 5000 + 5000;
			timer = setTimeout(goHome, time);
		}
		
		override public function set lock (item:Boolean):void {
			_lock = item;
			
			if (item)
				removable = false;
			else
				removable = true;
				
		}
		
		override public function get lock():Boolean {
			return _lock;
		}
		
		override public function onMoveAction(error:int, data:Object, params:Object):void {
			return;
		}
		
		override public function click():Boolean 
		{
			haloEffect(null, this.parent);
			
			Post.send( {
				ctr:'Gift',
				act:'light',
				uID:App.user.id,
				sID:sid
			}, onLightAction);
			
			clickable = false;
			touchable = false;
			ordered = true;
			
			return true;
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
			
			Hints.minus(Stock.FANTASY, 1, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y + ay*App.map.scaleY), true);
			
			if (data.hasOwnProperty("bonus")) {
				Treasures.bonus(data.bonus, new Point(this.x, this.y + ay));
				SoundsManager.instance.playSFX('bonus');
			}
			uninstall();
			rabbitCount--;			
			
			if (data.hasOwnProperty(Stock.FANTASY)) {
				App.user.stock.setFantasy(data[Stock.FANTASY]);
			}
		}
		
		public override function uninstall():void
		{
			var index:int = lanterns.indexOf(this);
			lanterns.splice(index, 1);
			this.removeEventListener(MouseEvent.MOUSE_OVER, oMove);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, mMove);
			this.removeEventListener(MouseEvent.MOUSE_OUT, uMove);
			App.map.removeUnit(this);
		}			
		
		//public var contLight:LayerX;
		
		private function showBorders():void 
		{
			contLight = new LayerX();			
			var sqSize:int = 30;			
			var cont:Sprite = new Sprite();
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0x89d93c);
			sp.graphics.drawRoundRect(0, 0,400,400,400,400);
			sp.rotation = 45;
			sp.alpha = 0.5;
			cont.addChild(sp);
			cont.height = 400 * 0.7;			
			contLight.addChild(cont);			
			contLight.y = -contLight.height / 2;			
			addChildAt(contLight, 0);
		}
		
		override public function previousPlace():void {
			super.previousPlace();
			
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
		}
		
		override public function free():void {
			super.free();
		}	
		
		override public function onLoad(data:*):void 
		{
			textures = data;
			getRestAnimations();
			addAnimation();
			createShadow();
			
			if (preloader) {
				TweenLite.to(preloader, 0.5, { alpha:0, onComplete:removePreloader } );
			}
		}
		
		override public function set move(move:Boolean):void {
			super.move = move;
			
			if (move){
				stopWalking();
				framesType = STOP;
			}	
			
			if (!move && isMoveThis) {				
				previousPlace();
			}
		}
		
		override public function set touch(touch:Boolean):void
		{
			if (App.user.mode == User.GUEST) {				
				return;
			}
			
			super.touch = touch;
		}		
	}
}