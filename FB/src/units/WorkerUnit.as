package units 
{
	import astar.AStarNodeVO;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import core.Post;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.ProgressBar;
	
	
	public class WorkerUnit extends Personage
	{
		public static const FREE:int = 0;
		public static const BUSY:int = 1;
		public var _wigwam:Boolean = false;
		public var coordsCloud:Object = new Object();
		public var progressBar:ProgressBar;
		public static var busy:uint = 0;
		public var fly:Boolean = false;
		
		public var rel:Object;
		
		public var movePoint:Point = new Point();
		
		public var ended:int = 0;
		public var workEnded:int = 0;
		//public var coordsCloud:Object = new Object();

		public function WorkerUnit(object:Object, view:String = '') {
			
			this.rel = object.rel;
			
			super(object, view);
			
			movePoint.x = object.x;
			movePoint.y = object.z;
			
			tm = new TargetManager(this);
			framesType = Personage.STOP;
			
			if (info.hasOwnProperty('homeradius') && info['homeradius'] != '')
				homeRadius = info.homeradius;
				
			if (info.hasOwnProperty('velocity') && info['velocity'] != '')
				velocities = [info.velocity];
			
		}
		
		override public function click():Boolean
		{
			return true;
		}
		
		public function born(settings:Object = null):void 
		{
			
		}
		
		override public function initMove(cell:int, row:int, _onPathComplete:Function = null):void {
			
			if (this.cell != cell || this.row != row)
			{
				framesType = Personage.WALK;
			}
			//if(coords.x)
			super.initMove(cell, row, _onPathComplete);
		}
		
		public function addTarget(targetObject:Object):Boolean
		{
			tm.add(targetObject);
			return true;
		}
		
		override public function onStop():void
		{
			stopCount = generateStopCount();
			stopRest();
			
		}
		
		/*override public function onStop():void
		{
			framesType = Personage.STOP;
		}*/
		
		override public function onPathToTargetComplete():void
		{
			startJob();
		}
		
		public var _workStatus:uint = FREE;
		public function set workStatus(value:uint):void {
			_workStatus = value;
			App.ui.upPanel.update();
		}
		
		public function get workStatus():uint {
			return _workStatus;
		}
		
		public function isFree():Boolean {
			if(workStatus == FREE)
				return true;
				
			return false;	
		}
		
		/*public function isFreeForWork():Boolean {
			if((workStatus == FREE || (workEnded > 0 && workEnded < App.time)) && (finished == 0 || (finished > 0 && App.time < finished)))
				return true;
			
			return false;	
		}*/
		
		public function isWigwam():Boolean {
			if(_wigwam == true)
				return true;
				
			return false;	
		}
		
		public var homeRadius:int = 5;
		public function goHome(_movePoint:Object = null):void
		{
			clearTimeout(_timer);
			loopFunctionn = onLoop;
			
			if (workStatus == BUSY)
				return;
			
			var place:Object;
			if (_movePoint != null) 
			{
				place = _movePoint;
			}else {
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:this.movePoint.x, z:this.movePoint.y}}, homeRadius);
			}
			
			if (App.user.mode == User.GUEST && App.owner && App.owner.id == '1' && this.sid == 979)
			{
				var johny:Walkgolden = Map.findUnit(717, 1489);
				if (johny)
				{
					var coordPoint:Object = findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:place}, 5);
					johny.framesType = Personage.WALK;
					johny.initMove(coordPoint.x, coordPoint.z, johny.onGoHomeComplete);
				}
				
			}
			
			framesType = Personage.WALK;
			if(place){
				initMove(
					place.x,
					place.z,
					onGoHomeComplete
				);
			}else{
				onGoOnRandomPlace();
			}
		}
		
		public var stopCount:uint = defaultStopCount;
		override public function stopRest():void 
		{
			if (framesType != Personage.STOP)
			{
				framesType = Personage.STOP;
			}
			stopCount--;
			if (stopCount <= 0){
				restCount = generateRestCount();
				loopFunctionn = setRest;
			}else
				loopFunctionn = stopRest;
		}
		
		public var timer:uint = 0;
		override public function onGoHomeComplete():void 
		{
			stopCount = generateStopCount();
			stopRest();
		}
		
		override public function setRest():void 
		{
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			
			framesType = randomRest;
			startSound(randomRest);
			if (Math.random() * 10 > 8 && this.type != 'Animal')
			{
				if (App.user.level > 6)
				{
					if (Math.random() * 10 > 5 && this.type != 'Animal')
						dialogTimeout = setTimeout(saySomething, 3000 + Math.random() * 1000);
				}else{
					dialogTimeout = setTimeout(saySomething, 3000 + Math.random() * 1000);
				}
			}
			
			restCount--;
			if (restCount <= 0){
				stopCount = (1+Math.random() * 2);// generateStopCount();
				loopFunctionn = beforeGoHome;
			}else
				loopFunctionn = setRest;
		}
		public function beforeGoHome():void
		{
			if (framesType != Personage.STOP)
			{
				framesType = Personage.STOP;
			}
			stopCount--;
			if (stopCount <= 0){
				loopFunctionn = goHome;
			}else
				loopFunctionn = beforeGoHome;
		}
		override public function stockAction(params:Object = null):void 
		{
			
			if(App.user.stock.count(sid) > 0)
				App.user.stock.data[sid] -= 1;
			else
				return;
			
			Post.send( {
				ctr:this.type,
				act:'stock',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z
			}, onStockAction);
			
			moveable = false;
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			App.map.moved = null;
			App.ui.glowing(this);
			cell 	= coords.x;
			row 	= coords.z;
			goHome();
		}
		
		
		
		public function goOnRandomPlace():void 
		{
			var place:Object = getRandomPlace();
			initMove(
				place.x, 
				place.z,
				onGoOnRandomPlace
			);
		}
		
		public function getRandomPlace():Object 
		{
			var i:int = 1;
			while (i > 0) {
				i--;
				var place:Object = nextPlace();
				if (App.map._aStarNodes[place.x][place.z].isWall) 
					continue;
				if(info.base == 1){
					if (App.map._aStarNodes[place.x][place.z].w != 1 || App.map._aStarNodes[place.x][place.z].open == false )
					continue;
				}
				
				if(info.base == 0){
					if  ((App.map._aStarNodes[place.x][place.z].b != 0) || App.map._aStarNodes[place.x][place.z].open == false|| App.map._aStarNodes[place.x][place.z].object != null) 
					continue;
				}
				
				break;
			}
			
			return {
				x:place.x,
				z:place.z
			}
			
			function nextPlace():Object {
				var randomX:int = int(Math.random() * Map.cells);
				var randomZ:int = int(Math.random() * Map.rows);
				return {
					x:randomX,
					z:randomZ
				}
			}
		}
		
		private var _timer:uint = 0;
		public function onGoOnRandomPlace():void 
		{
			framesType = STOP;
			if (_timer > 0)
				clearTimeout(_timer);
				
			var time:uint = Math.random() * 5000 + 5000;
			_timer = setTimeout(goOnRandomPlace, time);
		}
		
		override public function clearVariables():void 
		{
			//clearTextures();
			super.clearVariables();
		}
		
		public function clearTextures():void
		{
			if (textures){
				var _bmd:*;
				if(textures.animation.animations){
					for (var _anim1:* in textures.animation.animations)
					{
						for each(var _bmd1:* in textures.animation.animations[_anim1].frames)
						{
							for each(var _anm:* in _bmd1)
							{
								_anm.bmd.dispose();
								_anm.bmd = null;
								_anm = null;
							}
						}
					}
					textures.animation.animations = null;
				}
				if(textures.sprites){
					for (_bmd in textures.sprites){
						textures.sprites[_bmd].bmp.dispose();
						textures.sprites[_bmd].bmp = null;
					}
					textures.sprites = null;
				}
				textures = null;
			}
			//clearVariables();
		}
		
		override public function uninstall():void {
			//App.self.setOffEnterFrame(walk);
			clearTimeout(_timer);
			super.uninstall();
		}
		
		/*private var shortcutDistance:int = 5;// 15;
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> {
			
			var needSplice:Boolean = checkOnSplice(start, finish);
			
			if (App.user.quests.tutorial && tm.currentTarget != null)
				tm.currentTarget.shortcutCheck = true;
				
			if (!needSplice) {
				var path:Vector.<AStarNodeVO> = _astar.search(start, finish);
				if (path == null) 
					return null;
					
				if (tm.currentTarget != null && tm.currentTarget.shortcutCheck) {
					if (path.length > shortcutDistance) {
						path = path.splice(path.length - shortcutDistance, shortcutDistance);
						placing(path[0].position.x, 0, path[0].position.y);
						alpha = 0;
						TweenLite.to(this, 1, { alpha:1 } );
						return path;
					}
				}
					
				if (!inViewport() || (tm.currentTarget != null && tm.currentTarget.shortcut)) {
					path = path.splice(path.length - 5, 5);
					placing(path[0].position.x, 0, path[0].position.y);
					alpha = 0;
					TweenLite.to(this, 1, { alpha:1 } );
				}		
			}else {
				placing(finish.position.x, 0, finish.position.y);
				cell = finish.position.x;
				row = finish.position.y;
				alpha = 0;
				TweenLite.to(this, 1, { alpha:1 } );
				return null;
			}
			
			return path;
		}*/
			/**
		 * Заканчиваем действие и flash:1382952379993меняем цель
		 * @param	e
		 */
		public function finishJob(e:AppEvent = null):void
		{
			if (progressBar != null)
			{
				progressBar.removeEventListener(AppEvent.ON_FINISH, finishJob);
				
				if (App.map.mTreasure.contains(progressBar))
				{
					App.map.mTreasure.removeChild(progressBar);
				}
				progressBar = null;
			}
			
			if (hasEventListener(Event.COMPLETE))	
				removeEventListener(Event.COMPLETE, onFinishFly);
			
			if (hasEventListener(Event.COMPLETE))
				removeEventListener(Event.COMPLETE, onStartFly)
				
			if(tm.length == 0) framesType = Personage.STOP;
			if (tm.currentTarget != null)
			{
				if (App.user.quests.tutorial)
				{
					if (App.user.quests.currentTarget != null && tm.currentTarget.target == App.user.quests.currentTarget)
					{
						App.user.quests.currentTarget = null;
					}
				}
				tm.onTargetComplete();
				
				if(tm.currentTarget.target.hasOwnProperty('reserved') && tm.currentTarget.target.reserved <= 1)
					workerFree();
				if(!tm.currentTarget.target.hasOwnProperty('reserved'))
					workerFree();
				
			}
		}
		
		public function workerFree():void 
		{
			if (tm.currentTarget)
			{
				tm.currentTarget.target.targetWorker = null;
			}
			
		}
		
		private function startFly():void
		{
			if (fly) return;
			fly = true;
			velocity = velocities[1];
			framesType = "_fly";
			TweenLite.to(shadow, 0.3, { alpha:0.4 } );
			addEventListener(Event.COMPLETE, onStartFly)
			SoundsManager.instance.playSFX("flyStart", this);
		}
		
		private function onStartFly(e:Event):void
		{
			removeEventListener(Event.COMPLETE, onStartFly)
			framesType = "fly";
		}
		
		private function onFinishFly(e:Event):void
		{
			removeEventListener(Event.COMPLETE, onFinishFly);
		}
		
		private function finishFly():void
		{
			if (!fly) return;
			fly = false;
			velocity = velocities[0];
			framesType = "fly_";
			TweenLite.to(shadow, 0.3, { alpha:1, ease:Strong.easeIn } );
			addEventListener(Event.COMPLETE, onFinishFly);
			tm.onTargetComplete();
			SoundsManager.instance.playSFX("flyEnd", this);
		}
		
		/**
		 * Выполняем действие
		 */
		
		public function startJob():void
		{
			//if (tm.currentTarget.target is Resource && tm.currentTarget.target.reserved == 0)
				//return;
			if (!tm.currentTarget)
				return;
			var jobTime:Number = tm.currentTarget.target.info.jobtime;
			if (jobTime <= 0) jobTime = 2;
			jobTime = 1.5;
			if (progressBar == null) 
			{
				progressBar = new ProgressBar(jobTime, 110);
			}
			
			if (tm.currentTarget == null)
			{
				onStop();
				return;
			}
			
			if (tm.currentTarget.onStart)	
				tm.currentTarget.onStart();
				
			var ft:String = tm.currentTarget.event;
			loopFunctionn = onLoop;
			framesType = ft;
			
			position = tm.currentTarget.jobPosition;
			
			progressBar.x = x - progressBar.maxWidth / 2; 
			progressBar.y = y - 100;
			
			App.map.mTreasure.addChild(progressBar);
			progressBar.addEventListener(AppEvent.ON_FINISH, finishJob);
			progressBar.start();
		}
		
		
		public var shortcutDistance:int = 5;
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO>
		{
			if (App.user.quests.tutorial && tm.currentTarget != null)
				tm.currentTarget.shortcutCheck = true;
				
			//if (!needSplice) {
			var path:Vector.<AStarNodeVO> = _astar.search(start, finish);
			if (path == null) 
				return null;
			
			if (path.length > shortcutDistance)
			{
				path = path.splice(path.length - shortcutDistance, shortcutDistance);
				placing(path[0].position.x, 0, path[0].position.y);
				alpha = 0;
				TweenLite.to(this, 1, { alpha:1 } );
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
		
		public function checkOnSplice(start:*, finish:*):Boolean 
		{
			
			var zones:Array = [83, 180, 181, 182, 183, 184, 185, 186, 187, 5, 805];
			
			if (zones.indexOf(finish.z) != -1 || zones.indexOf(start.z) != -1) 
			{
				if (start.z != finish.z)
					return true;
			}
			
			return false;
		}
		
		public function initCoordsCloud():void 
		{				
			if (cloudPositions.hasOwnProperty(App.data.storage[sid].view) ) 
			{
				coordsCloud.x = cloudPositions[App.data.storage[sid].view].x;
				coordsCloud.y = cloudPositions[App.data.storage[sid].view].y;
			}else{
				if (App.data.storage[sid].hasOwnProperty('cloudoffset') && 
				(App.data.storage[sid]['cloudoffset'].dx != 0 || App.data.storage[sid]['cloudoffset'].dy != 0))
				{
					coordsCloud.x = App.data.storage[sid]['cloudoffset'].dx;
					coordsCloud.y = App.data.storage[sid]['cloudoffset'].dy;
				}else{
					coordsCloud.x = 0;
					coordsCloud.y = -50;
				}
			}
		}
	}
}
