package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import ui.AnimalCloud;
	import ui.UnitIcon;
	import wins.NeedResWindow;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.Window;
	import wins.WindowButtons;
	
	public class Techno extends WorkerUnit
	{
		public static const TECHNO:uint = 8;
		public static const TECHNO_MENATEE:uint = 904;
		public static const TECHNO_FARMER:uint = 1736;
		public static const PHOTOGRAPHER:uint = 2082;
		public static const VOJD:uint = 2277;
		public static const SYNOPTIC:uint = 2414;
		public static const SEAL:uint = 2582;
		
		public static const TECHNO_ANIMATIONS:Array = new Array( 'cut', 'fish', 'mine', 'rest', 'rest1', 'stop_pause', 'walk' );
		
		public static var isMove:Boolean;
		public static var sounds:Object = {
			build:'robot_4',
			work:'robot_1'
		}
		
		public var needID:int;
		public var needFID:int;
		public var needCount:int;
		public var countRes:int;
		public var fColor:uint;
		public var bColor:uint;
		public var finished:uint;
		public var hidden:Boolean;
		public var capacity:int = -1;
		public var targetObject:Object;		
		public var countCap:int = -1;
		public var thisTechnoWigwam:Wigwam;
		
		protected var timerIcon:int = 4;
		
		private var target:*;
		private var workerViewID:int;
		private var intervalMove:int;
		private var sparksInterval:int;
		private var isMoveThis:Boolean;
		private var _hasProduct:Boolean;
		private var _needProduct:Boolean;
		private var jobPosition:Object;
		private var sparksContainer:Sprite;
		private var cloudAnimal:AnimalCloud;
		//public var coordsCloud:Object = new Object();
		
		public function set hasProduct(value:Boolean):void
		{
			_hasProduct = value;
			
			if (_hasProduct) 
			{
				showIcon();
			}else {
				if (cloudAnimal) {
					cloudAnimal.dispose();
					cloudAnimal = null;
				}
			}
		}
		public function set needProduct(value:Boolean):void
		{
			_needProduct = value;
			
			if (_needProduct) 
			{
				showIcon();
			}else {
				clearIcon()
			}
		}
		
		public function get hasProduct():Boolean
		{
			return _hasProduct;
		}
		
		public function get needProduct():Boolean
		{
			return _needProduct;
		}
		/*override public function set touch(touch:Boolean):void
		{
			if (App.user.mode == User.GUEST)
				return;
			
			super.touch = touch;
		}*/
		
		override public function set move(move:Boolean):void 
		{			
			if (busy == BUSY)
				return;
			
			super.move = move;
			
			if (!move && isMoveThis)
				previousPlace();
		}
		
		
		public function Techno(object:Object)
		{
			onPathComplete = function():void { prevCoords = coords; moveAction() };
			super(object);
			
			info['area'] = {w:1, h:1};
			cells = rows = 1;
			velocities = [0.1];		
			if (info.type == 'Techno' || info.type == 'Walkresource')
				removable = false;
			fake = object.fake || false;
			
			if (object.capacity&&(App.user.mode == User.OWNER)) capacity = object.capacity;
			
			if (object.finished) {
				targetObject = { };
				targetObject['sid'] = object.rID;
				targetObject['id'] = object.mID;
				prevCoords = homeCoords(object.rID).coords;
				finished = object.finished;
			}
			
			if (!object.hasOwnProperty('spirit'))
			{
				App.user.techno.push(this);
				if (App.ui.upPanel)
					App.ui.upPanel.update();
			}
			
			defaultStopCount = 2;			
			
			if (capacity >= 0 && (App.user.mode == User.OWNER) && info.type == 'Techno')
			{
				App.self.setOnTimer(addTimerToDeath);
			}			
			
			var tempTime:String;
			if (thisTechnoWigwam)
			{
				tip = function():Object 
				{
					return {
						title:App.data.storage[thisTechnoWigwam.workers[0]].title,
						text:App.data.storage[thisTechnoWigwam.workers[0]].description
					}
				}
			}else{
				tip = function():Object 
				{
					return {
						title:App.data.storage[sid].title,
						text:App.data.storage[sid].description
					}
				}
			}
			
			if (object.fromStock) 
			{
				moveable = true;
			}else{
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onGameComplete);
			}
			moveable = true;
			App.self.addEventListener(AppEvent.ON_MOUSE_UP, onUp);
			
			if (Map.ready) {
				onMapComplete();
			}else{
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			}
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, changeIcon);
		}
		
		override public function take():void
		{
			
			if (!takeable)
				return;
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			var water:AStarNodeVO;
			
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var waters:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			/*if (rotate) {
			   cells = info.area.h;
			   rows = info.area.w;
			 }*/
			for (var i:uint = 0; i < cells; i++)
			{
				for (var j:uint = 0; j < rows; j++)
				{
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					
					nodes.push(node);
					
					/*node.isWall = true;
					node.b = 1;
					node.object = this;*/
					if (layer == Map.LAYER_FIELD || layer == Map.LAYER_LAND)
						node.isWall = false;
					
					if (i > 0 && i < cells - 1 && j > 0 && j < rows - 1)
					{
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						
						part.isWall = true;
						part.b = 1;
						part.object = this;
						if (layer == Map.LAYER_FIELD || layer == Map.LAYER_LAND)
							part.isWall = false;
						
						if (info.base != null && info.base == 1)
						{
							if (App.map._aStarWaterNodes != null)
							{
								water = App.map._aStarWaterNodes[coords.x + i][coords.z + j];
								waters.push(water);
								water.isWall = true;
								water.b = 1;
								water.object = this;
							}
						}
						
					}
					
				}
			}
			
			if (layer == Map.LAYER_SORT)
			{
				App.map._astar.take(nodes);
				App.map._astarReserve.take(parts);
			}
			
			if (info.base != null && info.base == 1)
			{
				if (App.map._astarWater != null)
					App.map._astarWater.take(waters);
			}
		}
		
		override public function onMoveAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);				
				free();
				_move = false;
				placing(prevCoords.x, prevCoords.y, prevCoords.z);
				take();
				state = DEFAULT;
				return;
			}	
			
			this.cell = coords.x;
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			//if (started > 0)
				goHome();
			
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false
		}
		
		public function changeIcon(e:AppEvent):void 
		{
			if (this is Picker || this is Banker)
				return;
			showIcon();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			moveable = true;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			goHome();
			
		}
		
		public function onMapComplete(e:AppEvent = null):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			// Определить привязку к Wigwam
			// Найти шмотку (модификатор)
			// Загрузить ее
			//Тут подменяем вьюшку
			var _info:Object;
			//if (workerViewID > 0 /*&& App.user.mode == User.GUEST*/)
			//{
				//_info = App.data.storage[workerViewID];
				//Load.clearCache(Config.getSwf(_info.type, _info.view));
			//}
			
			workerViewID = sid;
			for (var i:int = 0; i < Wigwam.wigwams.length; i++) 
			{
				var wigwam:Wigwam = Wigwam.wigwams[i];
				if (wigwam.workerSID == sid && wigwam.workerID == id && wigwam.workers.length > 0) {
					
					thisTechnoWigwam = wigwam;
					
					if(wigwam.openHouse == 0)
						needProduct = true;
						
					showIcon();
						
					workerViewID = wigwam.workers[0];
					
					if (wigwam.wigwamIsBusy)
					{
						var technoToHide:Unit = Map.findUnit(wigwam.workerSID, wigwam.workerID);
						if(technoToHide)
							technoToHide.visible = false;
					}
				}
			}
			if (info, type != 'Walkhero')
			{
				_info = App.data.storage[workerViewID];
				Load.loading(Config.getSwf(_info.type, _info.view), onLoad);
			}
			
		}
		
		
		private function addTimerToDeath():void 
		{			
			if (App.user.mode == User.GUEST) 
			{
				return
			}
			
			var countToDelete:Number = capacity - App.time;
			
			if (countToDelete<1)  
			{
				countToDelete =0	
				if (workStatus != WorkerUnit.BUSY) 
				{
					workStatus = WorkerUnit.BUSY;
					visible = false;
					removable = true;
					remove();
					App.data.options.SlaveBoughtTime
					App.self.setOffTimer(addTimerToDeath);
				}
			}
		}
		
		override public function onLoad(data:*):void 
		{
			if (info.sid == 3131)
				trace();
			textures = data;
			getRestAnimations();
			addAnimation();
			createShadow();
			
			if (!open && formed)
				applyFilter();
				
			if (this.sid == Techno.TECHNO_MENATEE)
			{
				if (needProduct) 
				{
					if (!App.user.quests.data.hasOwnProperty("442"))
					{
						if (this.thisTechnoWigwam.workerSID != this.thisTechnoWigwam.workers[0])
							this.thisTechnoWigwam.udress();
					}
				}
			}
			var _info:Object;
			if(workerViewID == 0){
				_info = App.data.storage[sid];
			}else
				_info = App.data.storage[workerViewID];
				
			//if(App.user.mode == User.GUEST){
			//Load.clearCache(Config.getSwf(_info.type, _info.view));
			//data = null;
			//}
		}
		
		override public function beginLive():void
		{		
		}
		
		private function onUp(e:AppEvent):void 
		{
			if (isMoveThis)
			{
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false;
			}
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false;
		}
		
		override public function onDown():void 
		{
			if (workStatus == BUSY) return;
			
			if (App.user.mode == User.OWNER) 
			{
				if (isMoveThis) 
				{
					clearTimeout(intervalMove);
					isMove = false;
					isMoveThis = false
				}else{
					var that:Techno = this;
					intervalMove = setTimeout(function():void {
						isMove = true;
						isMoveThis = true;
						that.move = true;
						App.map.moved = that;
					}, 400);
				}
			}
		}
		
		override public function goHome(_movePoint:Object = null):void
		{
			clearTimeout(timer);
			
			if (move) {
				var time:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, time);
				return;
			}
			
			if (workStatus == BUSY)
				return;
			
			var place:Object;
			if (_movePoint != null) {
				place = _movePoint;
			}else {
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:this.movePoint.x, z:this.movePoint.y}}, homeRadius);
			}
			
			if (targetObject && targetObject.hasOwnProperty('sid') != -1)
			{
				place = findPlaceNearTarget( { info: { area: { w:1, h:1 }},
					coords: {
						x:homeCoords(targetObject.sid).coords.x,
						z:homeCoords(targetObject.sid).coords.z
							}}, homeRadius);
			}
			
			framesType = Personage.WALK;
			
			initMove(
				place.x,
				place.z,
				onGoHomeComplete
			);
			
		}
		
		public function goToAndHide(target:*, radius:int=2):void 
		{
			stopRest();
			this.target = target;
			workStatus = BUSY;
			jobPosition = findPlaceNearTarget(target, radius);
			
			_move = false;
			
			initMove(
				jobPosition.x, 
				jobPosition.z,
				hideThis
			);
		}
		
		override public function onGoHomeComplete():void 
		{
			stopCount = generateStopCount();
			stopRest();
		}
		
		/*override public function setRest():void 
		{
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			
			framesType = randomRest;
			startSound(randomRest);
			if (Math.random() * 10 > 8 && this.type != 'Animal')
				setTimeout(saySomething, 3000 + Math.random() * 1000);
			
			if (restCount <= 0)
				loopFunctionn = goHome;
			else
				loopFunctionn = setRest
			restCount--;
		}*/
		private function hideThis():void 
		{
			hidden = true;
			this.visible = false;
			stopRest();
		}
		
		/*override public function saySomething(bgColor:uint = 0xfffef4, borderColor:uint = 0x47216b, word:String = ''):void
		{
			super.saySomething();
			timerIcon = setTimeout(function():void{
				clearIcon();
				fColor = 0;
				showIcon();
			}, 3000);
		}*/
		
		override public function click():Boolean
		{
			if (App.user.mode == User.GUEST)
				return false;
				
				//saySomething();
			var node:AStarNodeVO = App.map._aStarNodes[coords.x ][coords.z];
			if (!node.open)
				return false;
				
			if (hasProduct) 
			{
				storageEvent();
				return true;
			}
			if (this.thisTechnoWigwam && this.thisTechnoWigwam.workerSID != this.thisTechnoWigwam.workers[0])
				return false;
			
			if (needProduct) 
			{
				trace('Надо ' + App.data.storage[needID].title + ", " + needCount + " штук");
				
				if (App.user.stock.count(needID) >= needCount){
					
					trace("Хватает, есть " + App.user.stock.count(needID) + " штук");
					if (this.thisTechnoWigwam.workerSID != this.thisTechnoWigwam.workers[0])
						return false;
					
					Post.send({
						ctr:this.thisTechnoWigwam.type,
						act:'dress',
						uID:App.user.id,
						fID:needFID,
						tSID:App.data.storage[App.data.crafting[needFID].out].sID,
						wID:App.user.worldID,
						sID:this.thisTechnoWigwam.sid,
						id:this.thisTechnoWigwam.id
					}, function(error:int, data:Object, params:Object):void 
					{
						if (error)
						{
							Errors.show(error, data);
							return;
						}
						thisTechnoWigwam.changeWorker(data.worker);
						showIcon();
						
						//Смотрим перечень айтемов в рецепте, выбрасываем Techno
						
						var payForTechno:Object = {};
						for (var zz:* in App.data.crafting[needFID].items)
						{
							if (App.data.storage[zz].type != "Techno") 
							{
								payForTechno[zz] = App.data.crafting[needFID].items[zz];
							}
						}
						
						App.user.stock.takeAll(payForTechno);
					});	
				}else{
					trace("Не хватает, есть " + App.user.stock.count(needID) + " штук");
					new SimpleWindow({
						text: 			"Вам не хватает: "+App.data.storage[needID].title+" Найти?",
						height:			250,
						dialog:			true,
						confirm:function():void {
							ShopWindow.findMaterialSource(needID, null);
						}
					}).show();
					
				}
				return true;
			}
			
			var that:Techno = this;			
			clearTimeout(intervalMove);
			
			if(isMoveThis){
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false
				return true;
			}
			return true;
		}
		
		private function onGameComplete(e:AppEvent):void
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onGameComplete);
			
			if (finished > 0)
			{
				busy = BUSY;
				prevCoords = homeCoords(targetObject.sID).coords;
				goHome();
				findResourceTarget();
				return;
			}
			
			if (busy == FREE)
			{
				goHome();
			}
		}
		
		override public function born(settings:Object = null):void 
		{
			this.alpha = 0;
			
			if (settings && settings['capacity']&& (App.user.mode == User.OWNER))
				capacity = settings.capacity;
			
			this.cell = coords.x;
			this.row = coords.z;
			
			if (capacity >= 0 && (App.user.mode == User.OWNER))
			{
				addTimerToDeath();
				App.self.setOnTimer(addTimerToDeath);
			}
				
			var that:Techno = this;
			TweenLite.to(this, 1.8, { alpha:1, onComplete:function():void {
				//App.map.focusedOn(that, false);
				that.showGlowing();
				setTimeout(function():void{
					that.hideGlowing();
				},5000);
				
				var index:int = App.user.techno.indexOf(that)
				if (index != -1)
					goHome();
			}});
		}
		
		override public function uninstall():void 
		{
			
			if(target && target.targetWorker)
				target.targetWorker = null;
				
			if (App.user.techno.indexOf(this) != -1)
				App.user.techno.splice(App.user.techno.indexOf(this), 1);
			//thisTechnoWigwam = null;
			//clearTextures();
			clearTimeout(timerIcon);
			tm.owner = null;
			//tm = null;
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, changeIcon);
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onGameComplete);			
			App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onUp);
			App.ui.upPanel.update();
			
			super.uninstall();
			
			//if (clearVars)
				//clearVariables();
		}
		
		
		
		override public function onPathToTargetComplete():void
		{
			workStatus = BUSY;
			startJob();
		}
		
		override public function workerFree():void 
		{
			super.workerFree();
			framesType = STOP;
			workStatus = FREE;
			goHome();			
		}
		
		public function goToJob(target:*, order:int = 0):void 
		{
			stopRest();
			this.target = target;
			workStatus = BUSY;
			jobPosition = target.getTechnoPosition(order);
			
			_move = false;
			
			initMove(
				jobPosition.x, 
				jobPosition.z,
				startWork
			);
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_TECHNO_CHANGE));
		}
		
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> 
		{			
			var needSplice:Boolean = checkOnSplice(start, finish);
			
			if (App.user.quests.tutorial && tm.currentTarget != null)
				tm.currentTarget.shortcutCheck = true;
			
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
				
			return path;
		}
		
		public function fire(minusCapasity:int = 0):void
		{
			stopSound();
			workStatus = FREE;
			disposeSparks();
			tm.stop();
			
			if ((capacity == 0) && (App.user.mode == User.OWNER)) 
			{
				removable = true;
				remove();
			}else {
				goHome();
			}
			
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_TECHNO_CHANGE));
		}
		
		override public function addTarget(targetObject:Object):Boolean
		{
			if (!targetObject.target.info.kick.hasOwnProperty(App.data.storage[App.user.worldID].cookie[0])) 
			{
				return false
			}
			
			if (App.user.stock.count(App.data.storage[App.user.worldID].cookie[0]) >= (targetObject.target.info.kick[App.data.storage[App.user.worldID].cookie[0]]/**(targetObject.target.reserved+1)*/))
			{
				tm.add(targetObject);
				return true;
			} else {
				workerFree();
				targetObject.target.canceled = true;
				//var cookieSid:int = App.data.storage[App.user.worldID].cookie[0];
				var reqObj:Object = new Object();
				reqObj[ App.data.storage[App.user.worldID].cookie[0]] = 1;
				new NeedResWindow( {
					title:Locale.__e("flash:1435241453649"),
					text:Locale.__e('flash:1435241719042'),
					//text2:Locale.__e('flash:1435244772073'),
					height:230,
					neededItems: reqObj,
					button3:true,
					button2:true
				}).show();
				/*new WindowButtons( {
					title:Locale.__e("flash:1435241453649"),
					text:Locale.__e('flash:1435241719042'),
					//text2:Locale.__e('flash:1435244772073'),
					height:230,
					neededItems: reqObj,
					button3:true,
					button2:true
				}).show()*/
				//ShopWindow.findMaterialSource();
				//showPurchWnd();
				return false;
			}
		}
		
		private function startWork():void 
		{			
			if (hasProduct) 
			{
				framesType = 'stop_pause';
				return;
			}
			
			if(target && target.hasOwnProperty('targetWorker'))
				target.targetWorker = this;
			
			framesType = jobPosition.workType;
			
			if (target is Building) 
			{
				framesType = (Math.random() * 2 > 1)?'craft':'craft1';
			}
			
			position = jobPosition;
			
			if (jobPosition.workType == Personage.BUILD)
			{
				startSparks();	
			}
			
			startSound(jobPosition.workType);	
		}
		
		
		
		override public function generateStopCount():uint
		{
			return int(Math.random() * 4) + 1;;
		}
		
		override public function generateRestCount():uint 
		{
			return 1;
		}	
		
		public function inViewport():Boolean 
		{
			var globalX:int = this.x * App.map.scaleX + App.map.x;
			var globalY:int = this.y * App.map.scaleY + App.map.y;
			
			if (globalX < -10 || globalX > App.self.stage.stageWidth + 10) 	return false;
			if (globalY < -10 || globalY > App.self.stage.stageHeight + 10) return false;
			
			return true;
		}
		
		
		
		
		public function startSparks():void 
		{
			if (sparksContainer != null)
				disposeSparks();
			
			sparksContainer = new Sprite();
			addChildAt(sparksContainer, 0);
			generateSpark();
			sparksInterval = setInterval(generateSpark, 1000);
			
			if (framesFlip == 0)
			{
				sparksContainer.x = -50;
				sparksContainer.y = -60;
			}else {
				sparksContainer.scaleX = -1;
				sparksContainer.x = 50;
				sparksContainer.y = -60;
			}
		}
		
		private function generateSpark():void 
		{
			var spark:AnimationItem = new AnimationItem( { type:'Effects', view:'spark', onLoop:function():void {
				spark.dispose();
				if(spark && spark.parent)spark.parent.removeChild(spark);
			}});
			
			var random:int = Math.random();
			
			if (Math.random() > 0.5)
				spark.scaleX = -1;
			
			sparksContainer.addChild(spark);
			spark.x = int(Math.random() * 50) - 25;
			spark.y = int(Math.random() * 50) - 25;
		}
		
			
		
		private function disposeSparks():void 
		{
			if (sparksInterval > 0)
				clearInterval(sparksInterval);
			
			if (sparksContainer) 
			{
				removeChild(sparksContainer);
				sparksContainer = null;
			}
		}
		
		override public function startSound(type:String):void 
		{			
			switch(type)
			{
				case Personage.BUILD:
					break;
				case Personage.WORK:
					break;
				case 'rest':
					break
				case 'rest2':
					break	
			}
		}
		
		public function stopSound():void
		{
			SoundsManager.instance.removeDinamicEffect(target);
		}
		
		public function findResourceTarget():void
		{
			if (target == null) 
			{
				var resource:Resource = Map.findUnit(getByRecource(targetObject.sid), targetObject.id);
				if (resource != null) 
				{
					target = resource;
					target.busy = 1;
					goToJob(target);
					if (resource.hasOwnProperty('targetWorker'))
						resource.targetWorker = this;
				}
			}else {
				target.busy = 1;
				goToJob(target);
			}
			
			App.self.setOnTimer(work);
			work();
		}
		
		private function work():void 
		{
			if (App.time > finished) 
			{
				App.self.setOffTimer(work);				
				var rID:uint;
				hasProduct = true;
				workStatus = 3;
				if (App.user.mode == User.OWNER)
				capacity = countCap;
				if (target != undefined)
				{
					rID = target.info.sID
				}else {
					rID = targetObject.sid;
					target = {info:{sID:rID} };
				}
				
				prevCoords = homeCoords(rID).coords;
				goHome();
			}
		}
		
		public function wigwam(value:Boolean):void 
		{		
			_wigwam = value;
			workStatus = BUSY;
			busy = BUSY;
			this.visible = false;
			uninstall();			
		}	
		
		public function storageEvent():void 
		{			
			var rew:Object = { };
			rew[target.info.sid] = countRes;
			
			if (!App.user.stock.canTake(rew))
				return;
			
			if(target && target.targetWorker)
				target.targetWorker = null;
			
			var that:* = this;
			hasProduct = false;
			fire();
			
			Post.send( {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id
			}, function(error:int, data:Object, params:Object):void{
				if (error) 
				{
					Errors.show(error, data);
					return;
				}
				
				if (target)
				{
					target.busy = 0;
					target = null;
				}
				
				finished = 0;
				busy = 0;
			});
		}
		
		
		public function showIcon():void
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
				
			if (App.user.mode == User.OWNER)
			{
				if (needProduct && (this.thisTechnoWigwam.workerSID == this.thisTechnoWigwam.workers[0])) 
				{
					if (App.user.stock.count(needID) >= needCount){
						if (fColor == 0xb7edff)
							return;
						fColor = 0xb7edff;
						bColor = 0x32398f;
					}else{
						if (fColor == 0xda5a5a)
							return;
						fColor = 0xda5a5a;
						bColor = 0x770f0f;
					}
					/*if (info.sID == DRAGON) 
					{
						drawIcon(UnitIcon.REWARD, 2, 1, {
							glow: true,
							iconDX: -35,
							iconDY: -130
						}, 0, coordsCloud.x, coordsCloud.y);
					}else
					{*/
					var CraftData:Object = this.thisTechnoWigwam.craftData[0];
					needFID = CraftData.fid;
					var itemsCraft:Object = App.data.crafting[CraftData.fid].items;
					
					for (var obj:* in itemsCraft)
					{
						if (App.data.storage[obj].type != 'Techno'){
							needID = obj;
							needCount = itemsCraft[obj];
						}
					}
					
					//var matCount:int 
					drawIcon(UnitIcon.TECHNO, needID, needCount, {
						glow: true,
						iconDX: 0,
						iconDY: 0,
						count: 1,
						textSettings:{
							color		:fColor,
							borderColor	:bColor,
							textAlign	:'center',
							autoSize	:'center',
							fontSize	:24,
							shadowSize	:1.5
						}
						
					}, 0, coordsCloud.x, coordsCloud.y);
					//}
				}else {
					clearIcon();
				}
			}
			//App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_STOCK));
		}
		
		override public function onLoop():void 
		{
			/*if (_framesType == WAIT){
				stopCount--;
				if (stopCount <= 0){
					setRest();
				}	
			}else if (rests.indexOf(_framesType) != -1) {
				restCount --;
				if (restCount <= 0){
					stopCount = generateStopCount();
					framesType = WAIT;
				}
			}else {
				stopCount = defaultStopCount;
			}
			
			if (_framesType == 'opening') 
			{
				workStatus = FREE;
				var rId:uint = targetObject.sid;
				var hPoint:* = homeCoords(rId);
				goHome({
					x:hPoint.coords.x-1, 
					z:hPoint.coords.z-1
				});
				return;
			}
			super.onLoop();*/
		}
		
		override public function remove(_callback:Function = null):void
		{
			if (App.user.mode == User.GUEST)
				return;
				
			var callback:Function = _callback;
			
			if (info && info.hasOwnProperty('ask') && info.ask == true)
			{			
				if (App.data.storage[info.sID].type == 'Building' && Map.findUnits([info.sID]).length <= 1) 
				{				
				}else
				{
					new SimpleWindow({hasTitle:true, title: Locale.__e("flash:1382952379842"), text: Locale.__e("flash:1382952379968", [info.title]), label: SimpleWindow.ATTENTION, dialog: true, isImg: true, confirm: function():void
					{
						onApplyRemove(callback);
					}}).show();	
				}
			}else
			{
				var wigwamOnMap:Array = Map.findUnitsByType(['Wigwam']);
				var doNotRemove:Boolean = false;
				for (var i:int = 0; i < wigwamOnMap.length; i++) 
				{					
					for each (var worker:* in wigwamOnMap[i].workers)
					{
						if (worker == this.id) 
						{
							doNotRemove = true;							
						}
					}					
				}
				
				var landsWithTwoSlaves:Array = [4];
				var landsWithOneSlave:Array = [999];
				
				var conditionOne:Boolean = landsWithTwoSlaves.indexOf(App.user.worldID) > -1 && (this.id == 0 || this.id == 1);
				var conditionTwo:Boolean = landsWithOneSlave.indexOf(App.user.worldID) > -1 && this.id == 0;
				
				if (!doNotRemove) 
				{
					if (!(conditionOne || conditionTwo)) 
					{
						onApplyRemove(callback);
					}					
				}		
			}
		}
		
		public static function homeCoords(rid:uint):Object
		{
			var cells:Object = { };
			if(rid){}
			return { coords:{x:5,z:5}};
		}
		
		public static function getByRecource(sid:uint):uint
		{
			return 0;
		}
		
		public static function nearlestTechno(target:*, bots:Array):Techno
		{
			var resultTechno:Techno;
			var dist:int = 0;
			for each(var bot:Techno in bots)
			{
				var _dist:int = Math.abs(bot.coords.x - target.coords.x) + Math.abs(bot.coords.z - target.coords.z);
				if (dist == 0 || dist > _dist) {
					dist = _dist;
					resultTechno = bot;
				}
			}			
			return resultTechno;
		}
		
		public static function nearestTechnos(target:*, bots:Array, count:uint):Array 
		{
			var resultTechnos:Array = [];
			var dist:int = 0;
			for each(var bot:Techno in bots)
			{
				var _dist:int = Math.abs(bot.coords.x - target.coords.x) + Math.abs(bot.coords.z - target.coords.z);
				{
					resultTechnos.push( { bot:bot, dist:dist } );	
				}
			}
			
			resultTechnos.sortOn('dist', Array.NUMERIC);
			resultTechnos = resultTechnos.splice(0, count);
			return resultTechnos;
		}
		
		public static function showPurchWnd():void {
			new PurchaseWindow( {
				width:530,
				height:620,
				itemsOnPage:6,
				useText:true,
				cookWindow:true,
				shortWindow:true,
				columnsNum:3,
				scaleVal:1,
				noDesc:false,
				closeAfterBuy:false,
				autoClose:false,
				description:Locale.__e('flash:1393599816743'),
				content:PurchaseWindow.createContent("Energy", {view:['slave','Cookies']}),
				title:App.data.storage[150].title,
				popup: true,
				find:0,
				splitWindow:true,
				titleSplit:Locale.__e('flash:1422628903758'),
				descriptionSplit:Locale.__e('flash:1422628646880'),
				itemHeight:220,
				itemWidth:143,
				itemIconScale:0.8,
				offsetY:30
			}).show();			
		}
		
		public static function takeTechno(needTechno:int, target:*):Array 
		{
			var bots:Array = Techno.freeTechno();
			if (bots.length == 0) 
			{
				new PurchaseWindow( {
					width:560,
					height:320,
					itemsOnPage:3,
					useText:true,
					cookWindow:true,
					columnsNum:3,
					scaleVal:1,
					noDesc:true,
					closeAfterBuy:false,
					autoClose:false,
					description:Locale.__e('flash:1422628646880'),
					content:PurchaseWindow.createContent("Energy", {view:['slave']}),
					title:Locale.__e('flash:1422628903758'),
					popup: true,
					callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
					}
					
				}).show();			
			}
			
			var _technos:Array = Techno.nearestTechnos(target, bots, needTechno);
			return _technos;
		}
		public static function getBusyTechno():uint
		{
			var count:int = 0;
			for each( var bot:Techno in App.user.techno)
			{
				if (!bot.isFree()) 
				{						
					count ++;
				}				
			}			
			return count;
		}		
		
		public static function freeTechno():Array 
		{
			var result:Array = [];
			var wigwamArr:Array = Map.findUnitsByType(['Wigwam']);
			for each(var bot:Techno in App.user.techno) 
			{
				for each(var obj:* in wigwamArr){
					if (bot.sid == obj.workers[0] && obj.wigwamIsBusy == 0){
						result.push(bot);
					}
				}
			}
			return result;
		}
		
		public static function freeTechnoBySID(sid:int):Array 
		{
			var result:Array = [];
			var wigwamArr:Array = Map.findUnitsByType(['Wigwam']);
			for each(var obj:* in wigwamArr)
			{
				if (sid == obj.workers[0] && obj.wigwamIsBusy == 0)
				{
					var tech:* = Map.findUnit(obj.workerSID, obj.workerID);
					if(tech.visible)
						result.push(tech);
				}
			}
			return result;
		}
		
		public static function freeTechnoBySIDS(sids:Array):Array 
		{
			var result:Array = [];
			var wigwamArr:Array = Map.findUnitsByType(['Wigwam']);
			for each(var obj:* in wigwamArr)
			{
				if (sids.indexOf(obj.workers[0]) != -1 && obj.wigwamIsBusy == 0)
				{
					var tech:* = Map.findUnit(obj.workerSID, obj.workerID);
					if(tech.visible)
						result.push(tech);
				}
			}
			return result;
		}
		
		public static function technoWigwam():Array 
		{
			var result:Array = [];
			for each(var bot:Techno in App.user.techno) 
			{
				if (bot.isFree())
					result.push(bot);
			}
			
			return result;
		}
		
		public static function stopBusyTechno():void
		{
			for each(var bot:Techno in App.user.techno)
			{				
				bot.tm.dispose();
			}
		}
		
		public static function randomSound(sid:uint, type:String):String 
		{
			if (sounds[sid][type] is Array)
				return sounds[sid][type][int(Math.random() * sounds[sid][type].length)];
			else
				return sounds[sid][type];
		}
		
		public static function findCurrentTechno(itemSids:Array, returnBuilding:* = null, returnCraft:* = null):Boolean
		{
			var wigwamArr:Array = Map.findUnitsByType(['Wigwam']);
			var craft:*;
			for each(var obj:Wigwam in wigwamArr)
			{
				for each(craft in obj.craftData)
				{
					if (obj.workerSID == obj.workers[0] && itemSids.indexOf(craft.sID) != -1)
					{
						Window.closeAll();
						obj.openProfession(craft.sID, true, returnBuilding, returnCraft);
						return true;
					}
				}
			}
			
			for each(var vobj:* in App.data.crafting)
			{
				if (itemSids.indexOf(vobj.out) != -1)
				{
					for (var jobj:* in vobj.items)
					{
						if (App.data.storage[jobj].type == 'Techno')
						{
							var finded:Array = [];
							for (var s:* in App.data.storage)
							{
								if (App.data.storage[s].type == 'Wigwam' && App.data.storage[jobj].type == 'Techno') 
								{
									var hgfh:* = Numbers.firstProp(App.data.storage[s].outs).key
									if (jobj == Numbers.firstProp(App.data.storage[s].outs).key){
										finded.push(s);
										var _worlds:Array = World.canBuyOnMap(finded[0]);
										if(_worlds)
											new ShopWindow( { find:finded } ).show();
										break;
									}
								}	
							}
						}
					}
				}
			}
			return false;
		}
		
	}
}