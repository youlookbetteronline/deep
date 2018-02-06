package units
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.IsoTile;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	
	public class WUnit extends Unit 
	{
		public static const FACE:int = 0;
		public static const BACK:int = 1;
		public static const LEFT:int = 0;
		public static const RIGHT:int = 1;
		
		public var _walk:Boolean = false;
		public var start:Object = { x:0, y:0 };
		public var finish:Object = { x:0, y:0 };
		public var t:Number = 0;
		public var velocities:Array = [0.18];
		public var velocity:Number = velocities[0];		
		public var frame:uint = 0;		
		public var _framesType:String = 'walk';
		public var framesDirection:int = FACE;
		public var _position:Object = null;
		public var sign:int = 1;		
		public var path:Vector.<AStarNodeVO>;
		public var pathCounter:int = 0;		
		public var cell:int = 0;
		public var row:int = 0;		
		public var tm:TargetManager;
		public var onPathComplete:Function = null;		
		public var hasMultipleAnimation:Boolean = false;
		public var multiBitmap:Bitmap;
		public var multipleAnime:Object = null;
		public var flyeble:Boolean = false;	
		public var blocked:Boolean = false;	
		public var shadow:Bitmap;
		public var shadowContainer:Sprite;
		//public static const DRAGON:uint = 3363;
		public static var snails:Array = [793, 794, 795];
		
		private var _framesFlip:int = LEFT;
		private var frameLength:uint = 0;
		private var chain:Object;
		public var ax:int = 0;
		public var ay:int = 0;
		
		public function WUnit(object:Object) 
		{
			//Hut.huts
			cell 	= object.x;
			row 	= object.z;
			super(object);
			//walk = walkFunction;
			//update = updateFunction;
			//addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);			
		}
		
		/*public function onRemoveFromStage(e:Event):void 
		{
			if (animated) 
			{
				stopAnimation();
				stopWalking();
			}
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}*/
		
		/**
		 * Вызывается по окончанию загрузки анимации
		*/
		
		public function addAnimation():void
		{
			multiBitmap = new Bitmap();
			addChild(multiBitmap);
			
			ax = textures.animation.ax;
			ay = textures.animation.ay; // позиция битмапки персонажа 
			
			if (!animated)
			{
				startAnimation();
			}
		}
		
		/**
		 * вкл/выкл анимации
		*/
		
		public function startAnimation():void 
		{
			animated = true;
			//addEventListener(Event.ENTER_FRAME,update)
			App.self.setOnEnterFrame(this.update);
		}
		
		public function stopAnimation():void
		{
			animated = false;
			//removeEventListener(Event.ENTER_FRAME,update)
			App.self.setOffEnterFrame(this.update);
		}
			
		/**
		 * Вычисляем маршрут
		 * @param	cell
		 * @param	row
		*/
		
		private var walkTimeout:uint = 0;
		public function initMove(cell:int, row:int, _onPathComplete:Function = null):void
		{
			//Не пересчитываем маршрут, если идем в ту же клетку
			onPathComplete = _onPathComplete;
			loopFunctionn = onLoop;
			if (_walk)
			{
				if (path[path.length - 1].position.x == cell && path[path.length - 1].position.y == row)
				{
					return;
				}
			}
			
			if (!(cell in App.map._aStarNodes))
			{
				return;
			}
			
			if (!(row in App.map._aStarNodes[cell])) 
			{
				return;
			}
			
			if (App.map._aStarParts[cell][row].isWall ) 
			{
				var findNewPlace:Boolean = false;
				var count:int = 1;
				
				while (!findNewPlace)
				{
					for (var _cell:int = cell - count; _cell < count; _cell++)
					{
						for (var _row:int = row - count; _row < count; _row++)
						{
							if (_row < 0 || _cell < 0 || count > 10)
							{
								if (!findNewPlace)
								{
									walking();
									return;
								}
							}
							
							if (App.map._aStarParts[_cell][_row].isWall == false) 
							{
								cell = _cell;
								row = _row;
								findNewPlace = true;
								break;
							}
						}
					}
					count ++;
				}
				
				if (!findNewPlace)
				{
					walking();
					return;
				}			
			}
			
			path = findPath(App.map._aStarNodes[this.cell][this.row], App.map._aStarNodes[cell][row], App.map._astar);
			
			if (path == null)
			{
				//trace('Не могу туда пройти по-нормальному!');
				if (snails.indexOf(this.sid) != -1){
					this.blocked = true;
					/*walkTimeout = setTimeout(function():void{ 
						//this.dispatchEvent(new Event(Event.COMPLETE));
						//frame = 0;
						//onLoop();
					}, 1500 + Math.random() * 1000);*/
					//trace("Жду хода");
					//return;
				}else{
					noWay(cell, row);
				}
				
				if (path == null)
				{
					this._walk = false;
					pathCounter = 1;
					t = 0;
					App.self.setOffEnterFrame(walk);
					//trace('Не могу туда пройти!');
					_framesType = 'stop_pause';
					return;
				}
			}
			
			this.blocked = false;
			
			pathCounter = 1;
			t = 0;
			walking();
		}		
		
		public function noWay(cell:int, row:int):void 
		{
			path = findPath(App.map._aStarParts[this.cell][this.row], App.map._aStarParts[cell][row], App.map._astarReserve);
		}
		
		public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> 
		{
			var path:Vector.<AStarNodeVO> = _astar.search(start, finish);
			return path;
		}
		
		/**
		 * Задаем путь из клетки в клетку
		*/
		
		public function walking():void
		{
			if (path && pathCounter < path.length) 
			{
				start.x = this.x;
				start.y = this.y;
				
				//this.alpha = 1;
				var node:AStarNodeVO = path[pathCounter];
				
				finish = {x:node.tile.x, y:node.tile.y};
				if (this._walk == false)
				{
					this._walk = true;
					App.self.setOnEnterFrame(walk);
				}
			}else {
				// Заканчиваем путь
				/*if (this.visible == false)
				{
					TweenLite.to(this, 2, {alpha: 1, onComplete: function():void{this.visible = true;}});
				}*/
				path = null;
				pathCounter = 1;
				this._walk = false;
				t = 0;
				App.self.setOffEnterFrame(walk);
				if (onPathComplete != null)
					onPathComplete();
			}
		}		
		
		public function whenWalking():void
		{			
		}
		
		/**
		 * Обновляем координаты юнита
		 * @return возвращаем юнит если его нужно сортировать
		*/
		//public var walk:Function;
		public function walk(e:* = null):void
		{
			var k:Number = 0;
			
			
			if (start.x == finish.x) 
			{
				k = IsoTile.spacing / Math.abs(start.y - finish.y);
			}else if (start.y == finish.y)
			{
				k = IsoTile.spacing / Math.abs(start.x - finish.x);
			}else {
				var d:Number = Math.sqrt(Math.pow((start.x - finish.x), 2) + Math.pow((start.y - finish.y), 2));
				k = IsoTile.spacing / d;
			}
			velocity = velocities[0];
			//velocity = 0.18;
			
			whenWalking();
			t += velocity * k * (32 / (App.self.fps || 32));
			
			if (t >= 1)
			{
				if (!path) 
				{
					return;
				}
				
				var node:AStarNodeVO = path[pathCounter];
				this.cell = node.position.x;
				this.row = node.position.y;
				
				coords = { x:node.position.x, y:0, z:node.position.y };
				
				calcDepth();
				
				App.map.sorted.push(this);
				
				t = 0;
				x = finish.x;
				y = finish.y;
				
				pathCounter++;
				walking();
			}else
			{
				x = int((start.x + (finish.x - start.x) * t));
				y = int((start.y + (finish.y - start.y) * t));
				
			}
		}
		
		public function set framesType(value:String):void
		{
			if (sid == 8 && value == 'wait')
				value = 'stop_pause'
			if (_framesType != value)
			{
				frame = 0;
				_framesType = value;
			}
			position = null;
		}	
		public function get framesType():String
		{
			return _framesType;
		}	
		
		public function get framesFlip():int 
		{
			return _framesFlip;
		}
		
		public function set framesFlip(value:int):void 
		{
			_framesFlip = value;
		}
		
		public function set position(value:*):void
		{
			if (sid == 14) 
			{
				if (_framesType == 'harvest' || _framesType == 'gather') 
				{
					_framesType = 'work'
				}
			}
			
			if (App.data.storage[this.sid].type == 'Techno' && _framesType == 'work')
				_framesType = 'rest';
			
			_position = value;
			if (_position)
			{
				framesFlip = _position.flip;
				framesDirection = _position.direction;
				
				if (framesFlip != RIGHT)
				{
					frame = 0;
					bitmap.scaleX = 1;
					sign = 1;
				}
				
				if (framesFlip != LEFT)
				{
					frame = 0;
					bitmap.scaleX = -1;
					sign = -1;
				}
				
				if (textures)
				{	
					var cadr:uint = textures.animation.animations[_framesType].chain[frame];	
					if (textures.animation.animations[_framesType].frames[framesDirection] == undefined)
					{
						framesDirection = 0;
					}
					var frameObject:Object 	= textures.animation.animations[_framesType].frames[framesDirection][cadr];
					bitmap.x = frameObject.ox * sign;	
				}
			}
		}
		
		/**
		 * Обновляет изображение юнита
		*/
		//public var update:Function;
		public function update(e:* = null):void
		{
			if (sid == 535)
				trace();
			if (_walk)
			{
				if (start.y < finish.y)
				{ 
					if (framesDirection != FACE) //frame = 0;
					framesDirection = FACE; 
				}else {
					if (framesDirection != BACK) //frame = 0;
					framesDirection = BACK;
				}
				
				if (start.x < finish.x)
				{ 
					if (framesFlip != RIGHT)
					{
						//frame = 0;
						if (bitmap.scaleX > 0)
						{
							bitmap.scaleX = -1;
							sign = -1;
						}
					}
					framesFlip = RIGHT; 
				}else {
					if (framesFlip != LEFT)
					{
						//frame = 0;
						if (bitmap.scaleX < 0)
						{
							bitmap.scaleX = 1;
							sign = 1;
						}
					}
					framesFlip = LEFT;
				}				
			}else {
				if (!_position)	framesDirection = FACE;
			}
			
			var anim:Object = textures.animation.animations;
			//if (!anim)
				//return;
			if (anim.wait && _framesType == "stop_pause" && this.type == 'Techno') 
			{
				_framesType = "stop_pause";//было "wait"
			}
			
			if (anim.stop_pause && _framesType == "stop_pause" && this.type == 'Techno') 
			{
				_framesType = "stop_pause";
			}
			
			if (anim.rest && _framesType == "rest1" && this.type == 'Techno') 
			{
				_framesType = "rest";
			}this
			var cadr:uint 	= anim[_framesType].chain[frame];
			
			if (anim[_framesType].frames[framesDirection] == undefined) 
			{
				framesDirection = 0;
			}
			
			if (cadr > anim[_framesType].frames[framesDirection].length - 1)
				cadr = anim[_framesType].frames[framesDirection].length - 1;
			var frameObject:Object 	= anim[_framesType].frames[framesDirection][cadr];
			if (hasMultipleAnimation) multipleAnimation(cadr);
			
			bitmap.bitmapData = frameObject.bmd;
			bitmap.x = frameObject.ox * sign;
			bitmap.y = frameObject.oy - 0 + ay;
			bitmap.smoothing = true;
			if (shadow){
				if (App.data.storage[sid].base == 1){
					if(sid != 717){
						shadow.bitmapData = bitmap.bitmapData;
						shadow.scaleX = bitmap.scaleX*.8;
						shadow.scaleY = bitmap.scaleY*.8;
						//shadow.y = frameObject.oy*.8 - shadow.height/2;
						//if (framesFlip == RIGHT)
						//{
							shadow.x = frameObject.ox*.8 * sign;
							shadow.y = frameObject.oy*.8;
						//}
						//if (framesFlip == LEFT)
						//{
							//shadow.x = frameObject.ox*.8 * sign;
						//}
						
						//shadow.x = frameObject.ox*.8;
						//shadow.y = frameObject.oy * .8;
					}
				}/*else{
					shadow.scaleX = bitmap.scaleX;
					shadow.scaleY = bitmap.scaleY;
				}*/
			}
			frame++;
			if (frame >= anim[_framesType].chain.length) 
			{
				this.dispatchEvent(new Event(Event.COMPLETE));
				frame = 0;
				loopFunctionn();
			}
			
			if (icon) iconSetPosition();			
		}	
		
		public var loopFunctionn:Function = onLoop;
		private function multipleAnimation(cadr:int):void
		{
			if (multipleAnime == null)
			{
				multiBitmap.bitmapData = null;
				return;
			}
			this
			var frameObject:Object 	= multipleAnime[_framesType].frames[framesDirection][cadr];
			if (frameObject == null) return;
			multiBitmap.scaleX = bitmap.scaleX;
			multiBitmap.bitmapData = frameObject.bmd;
			multiBitmap.smoothing = true;
			multiBitmap.x = frameObject.ox * sign;
			
			multiBitmap.y = frameObject.oy + ay;
		}
		
		public function stopWalking():void
		{
			if (this._walk == true)
			{
				this._walk = false;
				framesDirection = 0;
				frame = 0;
				
			}
			
			path = null;			
			App.self.setOffEnterFrame(walk);
		}
		
		public var onLoopParams:Object;
		
		public function onLoop():void 
		{
			if (onLoopParams != null)
			{
				initMove(onLoopParams.cell, onLoopParams.row, onLoopParams.onPathComplete);
				onLoopParams = null;
			}
		}
		
		override public function uninstall():void 
		{
			stopAnimation();
			stopWalking();
			//this.update = null;
			//this.walk = null;
			super.uninstall();
			//loopFunctionn = null;
		}
	}
}