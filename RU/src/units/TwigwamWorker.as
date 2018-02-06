package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Post;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.UnitIcon;

	public class TwigwamWorker extends Walkgolden 
	{
		private var goToX:int;
		private var goToZ:int;
		private var uniqueID:int;
		private var tableTimeout:uint = 0;
		public var gives:Boolean = false;
		public var technoIsFree:Boolean = false;
		public var goesBeyond:Boolean = false;
		public var targetObject:Object = null;
		
		public function TwigwamWorker(object:Object) 
		{			
			goToX = object.baseX;
			goToZ = object.baseZ;
			uniqueID = object.uniqueID;
			technoIsFree = object.free || false;
			targetObject = object.target;
			super(object);
			tip = function():Object 
			{
				return {
					title:info.title,
					text: info.description
				};
			}	
		}
		
		override public function click():Boolean 
		{
			var node:AStarNodeVO = App.map._aStarNodes[coords.x ][coords.z];
			if (!node.open)
				return false;
				
			if (targetObject.hasProduct) 
			{
				targetObject.gatherProduct();
				clearIcon();
				return true;
			}	
			return false;
		}
		
		
		/*public function goBeyond():void 
		{
			initMove(
				Map.rows - 1,
				Map.cells - 1,
				function():void
				{
					uninstall(); 
				}
			);
		}*/
		
		private var unitIconRes:int;
		override public function showIcon():void
		{
			if (unitIcons.hasOwnProperty(App.data.storage[sid].view) ) 
			{
				unitIconRes = unitIcons[App.data.storage[sid].view].icon;
			}else{
				unitIconRes = 2;
			}
			
			clearIcon();
			
			if (cloudPositions.hasOwnProperty(App.data.storage[sid].view) ) 
			{
				coordsCloud.x = cloudPositions[App.data.storage[sid].view].x;
				coordsCloud.y = cloudPositions[App.data.storage[sid].view].y;
			}else{
				coordsCloud.x = 0;
				coordsCloud.y = -50;
			}
			
			if (App.user.mode == User.OWNER)
			{
				if (targetObject.hasProduct) 
				{
					drawIcon(UnitIcon.REWARD, unitIconRes, 1, {
						glow: true/*,
						iconDX: 0,
						iconDY: -20*/
					}, 0, coordsCloud.x, coordsCloud.y);
				}else {
					clearIcon();
				}
			}
		}
		
		override public function set move(move:Boolean):void 
		{
			//ничего не делаем
		}
		
		public function lightUnit(settings:Object = null, time:int = 2000):void 
		{
			if(settings && settings.focus)
				this.alpha = 1;
			else
				this.alpha = 0;
			var that:TwigwamWorker = this;
			TweenLite.to(this, time/1000, { alpha:1, onComplete:function():void {
				if(settings && settings.focus){
					App.map.focusedOn(that, false);
				}
				that.showGlowing();
				setTimeout(function():void{
					that.hideGlowing();
				}, 6000);
			}});
		}
		
		override public function goHome(_movePoint:Object = null):void
		{
			if (goesBeyond)
				return;
				
			if(!this.bitmap.visible)
				this.bitmap.visible = true;
				
			homeRadius = 5;
			
			clearTimeout(timer);
			
			if (workStatus == BUSY)
				return;
			
			loopFunctionn = onLoop;
			
			var place:Object;
			if (_movePoint != null) {
				place = _movePoint;
			}else {
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:this.movePoint.x, z:this.movePoint.y}}, homeRadius);
			}
			
			framesType = Personage.WALK;
			
			initMove(
				place.x,
				place.z,
				onGoHomeComplete
			);
		}
		
		public static function homeCoords(rid:uint):Object
		{
			var cells:Object = { };
			return { coords:{x:5,z:5}};
		}
		
		override public function onLoop():void 
		{
			
		}
		public function goBeyond():void
		{
			trace("go");
			goesBeyond = true;
			homeRadius = Map.cells;
			loopFunctionn = onLoop;
			
			var place:Object = findPlaceNearTarget({info:{area:{w:this.targetObject.cells, h:this.targetObject.rows}}, coords:{x:this.targetObject.coords.x, z:this.targetObject.coords.z}}, 20);
			initMove(
				place.x,
				place.z,
				onExitComplete
			);
		}
		
		public function goFromBeyond():void
		{
			trace("placed");
			alpha = 0;
			TweenLite.to(this, 2, {alpha: 1});
			goesBeyond = true;
			var place:Object = findNewPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:goToX, z:goToZ}}, 3);
			initMove(
				place.x,
				place.z,
				function():void{
					trace("finished");
					goesBeyond = false;
					this.movePoint.x = place.x;
					this.movePoint.y = place.z;
					goHome();
				}
			);
			
		}
		
		override public function walking():void
		{
			if (!App.map)
				return;
			if (path && pathCounter < path.length) 
			{				
				start.x = this.x;
				start.y = this.y;
				
				var node:AStarNodeVO = path[pathCounter];
				
				finish = {x:node.tile.x, y:node.tile.y};
				if (this._walk == false)
				{
					this._walk = true;
					App.self.setOnEnterFrame(walk);
				}
			}else {
				// Заканчиваем путь
				path = null;
				pathCounter = 1;
				this._walk = false;
				t = 0;
				App.self.setOffEnterFrame(walk);
				if (onPathComplete != null)
				onPathComplete();
			}
		}
		
		public function onExitComplete():void
		{
			TweenLite.to(this, 2, { x:this.x, y:this.y, alpha: 0, onComplete: uninstall/*function():void{
				this.visible = false;
			}*/});
			//TweenLite.to(this, 6, { alpha: 0, onComplete: } );
		}
		
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> 
		{
			var needSplice:Boolean = checkOnSplice(start, finish);
			
			if (App.user.quests.tutorial && tm.currentTarget != null)
				tm.currentTarget.shortcutCheck = true;
			
			/*if (!needSplice)
			{*/
				var path:Vector.<AStarNodeVO> = _astar.search(start, finish);
				if (path == null) 
					return null;
				
				if (workStatus == BUSY && path.length > shortcutDistance)
				{
					path = path.splice(path.length - shortcutDistance, shortcutDistance);
					placing(path[0].position.x, 0, path[0].position.y);
					alpha = 0;
					TweenLite.to(this, 1, { alpha:1 } );
					return path;
				}else {
					return path;
				}				
			/*}else {
				placing(finish.position.x, 0, finish.position.y);
				cell = finish.position.x;
				row = finish.position.y;
				alpha = 0;
				TweenLite.to(this, 1, { alpha:1 } );
				return null;
			}*/
			return path;
		}
		
		
		public function findNewPlaceNearTarget(target:*, radius:int = 3, lookOnWater:Boolean = false):Object
		{
			var places:Array = [];
			
			var targetX:int = target.coords.x;
			var targetZ:int = target.coords.z;
			
			var startX:int = targetX - radius;
			var startZ:int = targetZ - radius;
			
			if (startX <= 0) startX = 1;
			if (startZ <= 0) startZ = 1;
			
			var finishX:int = targetX + radius + target.info.area.w;
			var finishZ:int = targetZ + radius + target.info.area.h;
			
			if (finishX >= Map.cells) finishX = Map.cells - 1;
			if (finishZ >= Map.rows) finishZ = Map.rows - 1;
			
			for (var pX:int = startX; pX < finishX; pX++)
			{
				for (var pZ:int = startZ; pZ < finishZ; pZ++)
				{
					if ((coords.x <= pX && pX <= targetX +target.info.area.w) &&
					(coords.z <= pZ && pZ <= targetZ +target.info.area.h)){
						continue;
					}
					
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].isWall) 
						continue;
						
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].open == false) 
						continue;	
					
					places.push( { x:pX, z:pZ} );
				}
			}
			
			if (places.length == 0)
			{
				places.push( { x:coords.x, z:coords.z } );
			}
			
			var random:uint = int(Math.random() * (places.length - 1));
			return places[random];
		}
		
		public var unitIcons:Object = {
			'crab':{
				icon:214
			},
			'turtle':{
				icon:122
			}
		}
		
	}
}