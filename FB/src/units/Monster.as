package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Load;
	import core.Post;
	import effects.ParticlesStars;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import ui.UnitIcon;
	import utils.Effects;
	import wins.SimpleWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Monster extends LayerX 
	{
		public static const WALK:String 		= "walk";
		public static const WALK_BACK:String 	= "walk_back";	
		public static const WORK:String 		= "work";
		public static const WORK_BACK:String 	= "work_back";	
		
		public static var self:Monster;	
		
		public const HIGHLIGHTED:uint = 6;
		public const TOCHED:uint = 3;
		public const DEFAULT:uint = 4;
		public const IDENTIFIED:uint = 5;
		
		private const STREAM_SLUCK:Number = 2;
		
		public var mode:String;
		public var framesType:String;
		public var animation:Anime;
		public var start:Object = {};
		public var finish:Object = {};
		public var depth:uint = 0;
		public var cells:int = 5;
		public var rows:int = 5;
		public var bounds:Object;		
		public var textures:Object;
		public var icon:UnitIcon;
		public var info:Object = {};
		public var iconPosition:Object = { x:0, y:0 };
		public var defBox:Object = {};
		public var clickable:Boolean = true;
		public var touchable:Boolean = true;
		public var transparent:Boolean = false;
		public var transable:Boolean = false;
		public var layer:String = Map.LAYER_SORT;
		public var animationBitmap:Bitmap;
		public var settings:Object = {
			preview	:'crab_monster',
			start	:{x:20, z:24},
			box		:null
		};
		
		protected var isStreaming:Boolean = false;
		protected var _touch:Boolean = false;
		protected var _state:uint = DEFAULT;
		
		private var crushTexture:BitmapData;
		private var tween:TweenLite;
		private var nextX:Number;
		private var nextY:Number;
		private var lastIconX:Number = 0;
		private var lastIconY:Number = 0;
		private var _altitude:int = 0;
		private var totalTime:uint = 0;
		private var finishTime:uint = 0;
		private var dAlt:uint = 2;
		private var t:Number = 0;
		private var live:Boolean = false;
		
		public function set touch(touch:Boolean):void
		{
			_touch = touch;
			
			if (touch)
			{
				if (state == DEFAULT)
				{
					state = TOCHED;
				}
				else if (state == HIGHLIGHTED)
				{
					state = IDENTIFIED;
				}
				
			}
			else
			{
				if (state == TOCHED)
				{
					state = DEFAULT;
				}
				else if (state == IDENTIFIED)
				{
					state = HIGHLIGHTED;
				}
			}
		}
		
		public function get touch():Boolean
		{
			return _touch;
		}
		
		public function set state(state:uint):void
		{
			if (_state == state)
				return;
			
			switch (state)
			{
				case TOCHED: 
					this.filters = [new GlowFilter(glowingColor, 1, 6, 6, 7)];
					break;
				case HIGHLIGHTED: 
					this.filters = [new GlowFilter(0x88ffed, 0.6, 6, 6, 7)];
					break;
				case IDENTIFIED: 
					this.filters = [new GlowFilter(0x88ffed, 1, 8, 8, 10)];
					break;
				case DEFAULT:
					this.filters = [];
					break;
			}
			_state = state;
		}
		
		public function get state():uint
		{
			return _state;
		}
		
		public function get bmp():Bitmap
		{
			if (!animation)
				return new Bitmap(new BitmapData(10, 10, true, 0x0));
				
			return animation.bitmap;
		}
		public function get coords():Object
		{
			var _point:Object = IsoConvert.screenToIso(this.x, this.y, true);
			return _point;
		}
		
		public static function init(_settings:Object = null):void{
			Monster.self = new Monster(_settings);
			Monster.self.calcDepth();
			App.map.mSort.addChild(Monster.self);
			App.map.depths.push(Monster.self);
		}
		
		public function Monster(_settings:Object = null) 
		{
			for (var property:* in _settings) 
			{
				settings[property] = _settings[property];
			}
			info['title'] = Locale.__e('flash:1503473546104');
			info['description'] = Locale.__e('flash:1503473576206');
			
			tip = function():Object {
				return {
					title:info.title,
					text:info.description
				};
			};
			//if(settings.box){
			for each(var _box:* in App.map.publicBoxes){
				if (_box.sid == Publicbox.MAIN_BOX)
					defBox = _box;
			}
			//}
			
			
			checkState();
			Load.loading(Config.getSwf('Monster', settings.preview), onLoad);
			Load.loading(Config.getIcon('Material', 'gl_branch0'), onLoadTexture);
			App.self.setOnEnterFrame(checkWorkFrame);
		}
		
		public function onLoad(data:*):void {
			textures = data;
			if (data.animation)
			{
				checkState();
				checkMotionState();
				
				animation = new Anime(data, framesType, data.animation.ax, data.animation.ay);
				
				addChild(animation);
				animation.addAnimation();
				animation.startAnimation();
				startWalk();
				
			}
			showIcon();
		}
		
		public function sort(index:*):void
		{
			try {
				App.map.mSort.setChildIndex(this, index);
			} catch (e:Error) {
				
			}
		}
		
		public function calcDepth():void
		{
			var left:Object = {x: x - IsoTile.width * rows * .5, y: y + IsoTile.height * rows * .5};
			var right:Object = {x: x + IsoTile.width * cells * .5, y: y + IsoTile.height * cells * .5};
			depth = (left.x + right.x) + (left.y + right.y) * 102;
		}
		
		public function startWalk():void
		{
			if (settings.endLife == 0)
				return;
			checkState();
			
			if (animation && animation.framesType != mode)
				animation.framesType = mode;
				
			calcDepth();
			App.map.sorted.push(this);
			
			walking();
			App.self.setOnEnterFrame(walking);
			
			x = nextX;
			y = nextY;
			
			checkMotionState();
		}
		
		public function changeFrameType():void{
			var self:Monster = this;
			if(animation){
				animation.callback = function():void{
					if(self.framesType){
						self.animation.framesType = self.framesType;
						self.animation.callback = null;
					}
				}
			}
		}
		
		public function checkWorkFrame(e:* = null):void
		{
			if (!animation)
				return;
			if (animation.framesType != WORK && animation.framesType != WORK_BACK)
				return;
			if (mode == WALK){ //рубает вперед
				if (animation.frame == 15 || animation.frame == 48)
				{
					if (App.map.mSort.getChildIndex(this) != -1)
						crush(new Point(this.x, this.y + 100) ,App.map.mSort.getChildIndex(this));
				}
			}else{ //рубает назад
				if (animation.frame == 15 || animation.frame == 48)
				{
					if (App.map.mSort.getChildIndex(this) != -1)
						crush(new Point(this.x, this.y - 100) ,App.map.mSort.getChildIndex(this) - 10);
				}
					
			}
		}
		
		public function checkMotionState():void
		{
			var self:Monster = this;
			var diff:int = Math.abs(this.x - nextX) + Math.abs(this.y - nextY);
			//trace('diff: ' + diff);
			if (diff >= 20){
				if(animation){
					animation.callback = function():void{
						if (self.mode == Monster.WALK)
							self.framesType = Monster.WALK;
						else
							self.framesType = Monster.WALK_BACK;
						
						self.animation.callback = self.walk;
					}
				}else{
					if (self.mode == Monster.WALK)
						self.framesType = Monster.WALK;
					else
						self.framesType = Monster.WALK_BACK;
				}
			}else{
				if (animation){
					//crush();
					animation.callback = function():void{
						if (self.mode == Monster.WALK)
							self.framesType = Monster.WORK;
						else
							self.framesType = Monster.WORK_BACK;
						
						self.animation.callback = self.work;
						self.animation.framesType = self.framesType;
					}
				}else{
					if (self.mode == Monster.WALK)
						self.framesType = Monster.WORK;
					else
						self.framesType = Monster.WORK_BACK;
				}
			}
		}
		
		public function walk():void
		{
			//trace('walk');
			animation.framesType = framesType;
			animation.callback = null;
			var time:Number = (animation.animation.animation.animations[framesType].chain.length - 1) / 32/*App.self.fps*/;
			tween = TweenLite.to(this, time, { x:nextX, y:nextY, onComplete:checkMotionState } );
		}
		
		public function onLoadTexture(data:Bitmap):void {
			crushTexture = data.bitmapData;
		}
		
		public function crush(point:Point, index:int):void
		{
			if (!crushTexture)
				return;
			if (index < 0)
				index = 0;
			var bmap:Bitmap = new Bitmap(crushTexture);
			Effects.randomTween(crushTexture, App.map.mSort, point, 15, index);
		}
		
		public function work():void
		{
			//trace('crush');
			animation.callback = null;
			var time:Number = (animation.animation.animation.animations[framesType].chain.length-1) / 32/*App.self.fps*/;
			tween = TweenLite.to(this, time, {onComplete:checkMotionState } );
		}
		
		private function walking(e:Event = null):void
		{
			t = 1 - ((finishTime - App.time) / totalTime);
			
			if (t >= 1)
			{
				checkState();
			}
			
			nextX = int(start.x + (finish.x - start.x) * t);
			nextY = int(start.y + (finish.y - start.y) * t);
			calcDepth();
			if(App.map.sorted.indexOf(this) == -1){
				App.map.sorted.push(this);
			}
		}
		
		public function click():Boolean
		{
			if (!animation)
			{
				return false;
			}
			
			if (settings.box && (settings.box.coords.x != defBox.x || settings.box.coords.z != defBox.z))
				return false;
				
			if (settings.box && mode == Monster.WALK)
				return false;
			
			if (App.user.useSectors)
			{
				var node1:AStarNodeVO = App.map._aStarNodes[this.coords.x][this.coords.z];
				
				if (!node1.sector.open)
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1495607052980') + " " + info.title,
						confirm:function():void
						{
							node1.sector.fireNeiborsReses();
						}
					}).show();
					return false;
				}
			}
			if (settings.box)
			{
				var boxes:Array = Map.findUnits([settings.box.sid])
				if (boxes.length == 0)
					return false;
				settings.box.free();
				var postObject:Object = {
					ctr: settings.box.type, 
					act: 'move', 
					uID: App.owner.id, 
					wID: App.owner.worldID, 
					sID: settings.box.sid, 
					id: settings.box.id, 
					x: this.coords.x, 
					z: this.coords.z, 
					rotate: int(true)
				};
				settings.box.coords.x = this.coords.x;
				settings.box.coords.z = this.coords.z;
				settings.box.rotate = true;
				Post.send(postObject, settings.box.onMoveAction);
				clearIcon();
			}
			App.tips.hide();
			
			return true;
		}
		
		public function checkBoxState():void
		{
			if (settings.box && mode == Monster.WALK_BACK)
			{
				if (settings.box.coords.x == defBox.x && settings.box.coords.z == defBox.z && settings.box.visible)
				{
					settings.box.visible = false;
					settings.box.clearIcon();
				}
			}
		}
		
		public function checkState():void
		{
			if (settings.endLife == 0)
				return;
			if (settings.endLife - settings.totalTime / 2 >= App.time)
			{
				mode = Monster.WALK;
				totalTime = settings.totalTime/2;
				finishTime = settings.endLife - settings.totalTime/2;
				
				start = IsoConvert.isoToScreen(settings.start.x, settings.start.z, true);
				//finish = IsoConvert.isoToScreen(settings.finish.x, settings.finish.z, true);
				finish = IsoConvert.isoToScreen(defBox.x, defBox.z, true);
				
			}else{
				mode = Monster.WALK_BACK;
				checkBoxState();
				totalTime = settings.totalTime/2;
				finishTime = settings.endLife;
				
				start = IsoConvert.isoToScreen(defBox.x, defBox.z, true);
				//start = IsoConvert.isoToScreen(settings.finish.x, settings.finish.z, true);
				finish = IsoConvert.isoToScreen(settings.start.x, settings.start.z, true);
			}
			if(settings.endLife < App.time){
				App.self.setOffEnterFrame(walking);
				clearIcon();
				TweenLite.to(this, 1, { alpha:0, onComplete:uninstall } );
				return;
			}
			showIcon();
		}
		
		public function drawIcon(type:String, material:*, need:int = 0, params:Object = null, directSid:int = 0, posX:int = 0, posY:int = 0):void 
		{
			if (icon) clearIcon();
			if (!parent) return;
			
			icon = new UnitIcon(type, material, need, this, params);
			iconPosition = { x:posX, y:posY };
			icon.y = this.y + iconPosition.y;
			icon.x = this.x + iconPosition.x;
			
			
			if (!App.map.mIcon.contains(icon))
				App.map.mIcon.addChild(icon);
			
			iconSetPosition(0, 0, true);
			App.map.iconSortResort();
		}
		
		public function clearIcon():void 
		{
			if (icon) {
				icon.dispose();
				icon = null;
				
				this.hideGlowing();
			}
		}
		
		public function iconSetPosition(x:int = 0, y:int = 0, stream:Boolean = false):void 
		{
			if (isStreaming) return;
			if (!icon) return;
			if (!bounds && textures) 
				countBounds();
			if (bounds) {
				if (!stream) {
					iconIndentCount();
					icon.x = this.x + ((x == 0) ? iconPosition.x : x);
					icon.y = this.y + ((y == 0) ? iconPosition.y : y);
				}else {
					isStreaming = true;
					App.self.setOnEnterFrame(streaming);
				}
			}
		}
		
		public function showIcon():void {
			clearIcon();
			if (mode == Monster.WALK)
				return;
			if (!settings.box)
				return;
			if (settings.box && (settings.box.coords.x != defBox.x || settings.box.coords.z != defBox.z))
				return;
			var boxes:Array = Map.findUnits([settings.box.sid])
			if (boxes.length == 0)
				return;
			drawIcon(UnitIcon.BUILDING_REWARD, Publicbox.MAIN_BOX, 1, {
				iconScale: 1
			}, 0, 0, -200);
		}
		
		public function iconIndentCount():void {
			if (!bounds) return;
			
			iconPosition.x += bounds.x + bounds.w / 2;
			iconPosition.y += bounds.y + 15;
			
		}
		
		public function countBounds(animation:String = '', stage:int = -1):void {
			bounds = Anime.bounds(textures, { stage:stage, animation:animation, walking: false } );
		}
		
		private function streaming(e:Event = null):void 
		{
			if (!icon)
				return;
			lastIconX = icon.x;
			lastIconY = icon.y;
			icon.x = icon.x + (this.x - icon.x + iconPosition.x) / STREAM_SLUCK;
			icon.y = icon.y + (this.y - icon.y + iconPosition.y) / STREAM_SLUCK;
		}
		public function uninstall():void{
			clearIcon();
			App.self.setOffEnterFrame(checkWorkFrame);
			if (tween)
			{
				tween.complete(true);
				tween.kill();
				tween = null;
			}
			if (this.parent)
			{
				this.parent.removeChild(this);
				Monster.self = null;
			}
		}
		
	}

}