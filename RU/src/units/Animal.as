package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import ui.AnimalCloud;
	import ui.Hints;
	import ui.UnitIcon;
	import ui.UserInterface;
	import wins.NeedResWindow;
	import wins.PurchaseWindow;
	import units.WUnit;
	import wins.SimpleWindow;
	import wins.Window;
	import flash.display.Shape; 
	import wins.WindowButtons;

	public class Animal extends WorkerUnit
	{
		public static var SEAHORSE:int = 1592;
		public var count:int = 0;
		public var _level:int = 0;
		public var cloudAnimal:AnimalCloud;
		private var countRequireItems:int = 0;
		public var time:uint = 0;
		public var sID:uint;
		public var shadowBitmap:Bitmap = new Bitmap();
		public var shady: int = 0;
		private var rabbits:Array = [1441, 1442, 1443, 1444, 1445];
		public static const HUNTER:uint = 1528;
		public var depth_animal:int = 0;
		public var homeCoords:Object = {};
		private var devel:Boolean = false;
		public var fneed:Object
		
		public function Animal(object:Object)
		{
			started = object.started || 0;
			count = object.count || 0;
			time = object.time || App.time;
			sID = object.sid;
			
			if (object.hasOwnProperty('level'))
				_level = object.level;
			if (started > App.time) 
				producting = true;
			super(object);
			if (info.hasOwnProperty('devel') && info.devel != null)
				devel = true;
			if (object.hasOwnProperty('fneed'))
				this.fneed = object.fneed;
			else
			{
				if (devel && object.level)
				{
					/*if (!fneed)
						fneed = {};*/
					this.fneed = info.devel.req[object.level].fneed
				}
				else
				{
					if (Numbers.countProps(info.require) == 1)
						this.fneed = info.require
					else
					{
						var __require:Object = new Object();
						__require[Numbers.firstProp(info.require).key] = Numbers.firstProp(info.require).val
						this.fneed = __require;
					}
				}
				
			}	
			homeCoords = coords;
			info['area'] = { w:1, h:1 };
			cells = rows = 1;
			velocities = [0.05];
			startHungryCloud = 1000;
			
			App.user.animals.push(this);
			App.ui.upPanel.update();			
			
			moveable = true;
			takeable = false;
			//multiple = true;
			
			
			if (started > 0){
				App.self.setOnTimer(work)
			}
				else 
			{
				if (ordered) 
				{
					hungry();
				}				
			}
			
			tip = function():Object {
				var cnt:int = info.count - count;
				if (cnt < 0) cnt = 0;
				if (started != 0){
					if (started > App.time && App.data.storage[sID].immortal == 1){
						return {
							title:info.title,
							text:Locale.__e("flash:1419604104376"),
							timerText: TimeConverter.timeToStr(started - App.time),
							timer:true
						}
					}
					if (started > App.time && App.data.storage[sID].immortal != 1) {
						return {
							title:info.title,
							text:Locale.__e("flash:1403797940774", [String(cnt)] + "\n" + Locale.__e('flash:1419604104376')),
							timerText: TimeConverter.timeToStr(started - App.time),
							timer:true
						}
					}else if (hasProduct) {
						return {
							title:info.title,
							text:Locale.__e('flash:1419931364433')
						}
					}
				}	
				if (info.sID == 1498 && count == 0){
					return{
						title:info.title,
						text:Locale.__e('flash:1492009904170')
					}
				}
				else
				{
					return {
						title:info.title,
						text: (App.data.storage[sID].immortal!=1)?(Locale.__e("flash:1403797940774", [String(cnt)] + "\n" + info.description)):(info.description)
					}
				}
				
			}
			
			for (var out:* in App.data.storage[sid].require) {
				break;
			}
			countRequireItems = App.data.storage[sid].require[out];
			
			if (Map.ready && started > 0)
			{
			}else{
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			}
			if (object.buy)
			{
				showBorders();
			}			
			
			App.self.addEventListener(AppEvent.ON_MOUSE_UP, onUp);
			shortcutDistance = 50;
				
			homeRadius = 10;
			
			//if (this.sid == 1077 || this.sid == 1612 || this.sid == 1613)	
				//homeRadius = 2;
				//
			//if (this.sid == 1498)
				//homeRadius = 5;
				//
			//if (rabbits.indexOf(this.sid) != -1)
				//homeRadius = 100;
				
			
				
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			
			/*var shape1:Shape = new Shape(); // точка под обьектом
			shape1.graphics.beginFill(0xFFff00, 1);
			shape1.graphics.drawCircle(0, 0, 3);
			shape1.graphics.endFill();
			addChild(shape1);*/
		}
		
		override public function load():void 
		{
			if (preloader) 
				addChild(preloader);
			
			Load.loading(Config.getSwf(info.type, info.view), onLoad);
			if (this.info.hasOwnProperty('hungryanim') && this.info.hungryanim != '')
			{
				changeAnimal(hangry);
			}
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			if (info.hasOwnProperty('devel') && info.hungryanim != '')
				changeLevelAnimal();
			changeAnimal(hangry);
			drawShadow();
			
			goHome();
			if (!producting&&!hasProduct&&!fromStock&&fneed)  
			{
				hungry();
			}
			
		}
		
		public function get hangry():Boolean
		{
			if (!producting && !hasProduct && !fromStock)  
				return true;
			return false;
		}
		
		private function changeLevelAnimal():void
		{
			var self:Animal = this;
			if (info.hasOwnProperty('devel') && info.devel != null && _level != 0)
			{
				Load.loading(Config.getSwf(App.data.storage[sid].type, App.data.storage[sid].devel.req[_level].view), function(data:*):void {
					self.textures = data;
				});
			}
			else
			{
				Load.loading(Config.getSwf(App.data.storage[sid].type, App.data.storage[this.sID].view), function(data:*):void {
					self.textures = data;
				});
			}
			
		   if (this.sid == 2077 && _level >= 1)
				homeRadius = 50;
		}
		
		private function changeAnimal(_hungry:Boolean = true):void
		{
			if (info.hasOwnProperty('devel') && info.devel != null && _level != 0)
					changeLevelAnimal();
			if (this.info.hasOwnProperty('hungryanim') && this.info.hungryanim != '')
			{
				var preview:String = App.data.storage[this.sID].view;
				var self:Animal = this;
				if (_hungry)
					preview = App.data.storage[this.sID].hungryanim;
				Load.loading(Config.getSwf(App.data.storage[sid].type, preview), function(data:*):void {
					self.textures = data;
				});
			}
			else
				return;
		}
		
		protected function drawShadow():void
		{
			if (App.data.storage[sid].base == 0)
			{
				//var shadBitmap:BitmapData = textures.animation.animations.walk.frames[0][0].bmd;
				//var invertTransform:ColorTransform = new ColorTransform(0, 0, 0, 1, 0, 0, 0, 1);
				//shadBitmap.colorTransform(shadBitmap.rect, invertTransform);
				shadowBitmap.bitmapData = textures.animation.animations.walk.frames[0][0].bmd;
			}
			var matrix:Array = new Array();
			matrix = matrix.concat([0, 0, 0, 0, 0]); // red
			matrix = matrix.concat([0, 0, 0, 0, 0]); // green
			matrix = matrix.concat([0, 0, 0, 0, 0]); // blue
			matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
			var _filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			shadowBitmap.filters = [new BlurFilter(20, 20, BitmapFilterQuality.LOW), _filter];
			shadowBitmap.x = shadowBitmap.x - (shadowBitmap.width / 2);
			shadowBitmap.y = shadowBitmap.y - (shadowBitmap.height / 2);
			//addChild(shadowBitmap);
			
			if (sID != 0 && App.data.storage[sID].base == 0){
				depth_animal = 20; 
			}else{
				depth_animal = (20) * Math.random() + (this.sid == 454) ? 120 : 170;
			}
			if (sID == 1498)
				depth_animal = 35;
				
			if (sID == 2171 || sID == 2172)
				depth_animal = 20;
			setCloudCoords();
			createShadow();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			App.map.moved = null;
			App.ui.glowing(this);
			
			var point:Object = IsoConvert.screenToIso(App.map.mouseX, App.map.mouseY, true);
			cell 	= point.x;
			row 	= point.z;
			calculateShadow();
			
			hungry();
			goHome();
			setCloudCoords();
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
		
			switch(state) {
				case OCCUPIED: this.bitmap.filters = [new GlowFilter(0xFF0000, 1, 6, 6, 7)]; break;
				case EMPTY: this.bitmap.filters = [new GlowFilter(0x00FF00, 1, 6, 6, 7)]; break;
				case TOCHED:
					this.bitmap.filters = [new GlowFilter(0xFFFF00, 1, 6, 6, 7)];
				break;
				case HIGHLIGHTED: this.bitmap.filters = [new GlowFilter(0x88ffed, 0.6, 6, 6, 7)]; break;
				case IDENTIFIED: this.bitmap.filters = [new GlowFilter(0x88ffed, 1, 8, 8, 10)]; break;
				case DEFAULT: this.bitmap.filters = []; break;
			}
			_state = state;
		}
		
		override public function createShadow():void 
		{
			if (shadow) {
				removeChild(shadow);
				shadow = null;
			}
			
			calculateShadow();
			if (textures) 
			{
				shadow = shadowBitmap;
				addChildAt(shadow, 0);
				shadow.smoothing = true;
				shadow.x = shadowBitmap.x;
				shadow.y = shadowBitmap.y;
				shadow.alpha = 0.3;
				shadow.scaleX = .7;
				shadow.scaleY = .7;
				shady = shadow.y;
			}
		}
		
		override public function addAnimation():void
		{
			super.addAnimation();
			calculateShadow();
		}
		
		public function calculateShadow():void
		{
			if (sID == 0) 
			{
				return;
			}
			
			if (textures)
			{
				ax = textures.animation.ax;
				ay = textures.animation.ay - depth_animal;
			}
		}
		
		
		
		override public function noWay(cell:int, row:int):void
		{
		}
		
		public function getClosestIntersection(cell:int, row:int):Object
		{
			var clNum:int = this.cell;
			var rwNum:int = this.row;
			var temp:Object = { 'cell':clNum, 'row':rwNum };
			while (clNum != cell)
			{
				temp = {'cell':clNum,'row':rwNum}
				var diff:int = (cell - clNum) / Math.abs(cell - clNum);
				clNum += diff;
				rwNum += diff * ( (row - this.row) / (cell - this.cell));
				if (App.map._aStarParts[clNum][rwNum].isWall)
				{
					return temp;
				}
			}
			return temp;
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			//1 w
			//2 b
			//info.base;
			for (var i:uint = 0; i < cells; i++)
			{
				for (var j:uint = 0; j < rows; j++)
				{
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					
					if (info.base == 1)
					{
						if (node.w != 1 || node.open == false /*|| node.object != null*/)
						{
							return OCCUPIED;
						}
					}
					if (info.base == 0)
					{
						if  ((node.b != 0) || node.open == false|| node.object != null) 
						{
							return OCCUPIED;
						}
					}
				}
			}
			return EMPTY;
		}
		
		/*override public function findPlaceNearTarget(target:*, radius:int = 3):Object
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
					
					//Для улиток
					if (info.base == 0)
					{
						if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].b != 0 && App.map._aStarNodes[pX][pZ].w != 1) 
							continue;
					}
					
					//Для водных
					if (info.base == 1)
					{
						if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].w != 1) 
							continue;
					}
					
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].open == false) 
						continue;	
					
					places.push( { x:pX, z:pZ} );
				}
			}
			
			if (places.length == 0) {
				places.push( { x:coords.x, z:coords.z } );
			}
			var random:uint = int(Math.random() * (places.length - 1));
			return places[random];
		}*/
		
		public var cloudScale:Object = {
			/*'small_snail': {x:0.5, y:0.5},
			'snail':{x:0.6,y:0.6},
			'big_snail':{x:0.8, y:0.8},
			'skat':{x:0.9, y:0.9},
			'medusa':{x:0.8,y:0.8},
			'hammerfish':{x:0.8,y:0.8}*/
		}
		
		override public function whenWalking():void
		{
			if (!textures) return;
			
			velocity = velocities[0];
			//homeRadius = 10;
			/*if (this.sid == 1077)
			{
				//homeRadius = 2;
				velocity = 0.01;
			}
			
			if (rabbits.indexOf(this.sid) != -1)
			{
				//homeRadius = 100;
				velocity = 0.3;
			}*/
			
			//switch(App.data.storage[sid].view) 
			//{
				/*case 'skat':
					rebuildShadow( { scale:2, alpha:0.2 } );
					rows = 3;
					cells = 3;
					velocity = 0.03;
					break;*/
				/*case 'lama':
					rebuildShadow( { scale:2, alpha:0.5 } );
					rows = 2;
					cells = 2;
					velocity = 0.035;
					break;
				case 'elephant':
					rebuildShadow( { scale:5, alpha:0.7 } );
					rows = 3;
					cells = 3;
					velocity = 0.05;
					break;
				case 'feneck':
					break;
				case 'ostrich':
					velocity = 0.055;
					break;
				case 'lemur':
					break;
				default:
					velocity = 0.055;
					break;*/
			//}
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
		}
		private var checkNeed:Boolean = false;
		private function onChangeStock(e:AppEvent):void 
		{
			if (fneed)
			{
				if (App.user.stock.checkAll(fneed))
				{
					if (!checkNeed)
					{
						checkNeed = true;
					}else	return;
				}else{
					if (checkNeed)
					{
						checkNeed = false;
					}else	return;
				}
			}
			else
			{
				if (App.user.stock.checkAll(info.require))
				{
					if (!checkNeed)
					{
						checkNeed = true;
					}else	return;
				}else{
					if (checkNeed)
					{
						checkNeed = false;
					}else	return;
				}
			}
			
			if (!hasProduct && cloudAnimal != null && !producting)
			{
				this.cloudAnimal.dispose();
				this.cloudAnimal = null;
				hungry();
			}
		}
		
		private function onUp(e:AppEvent):void 
		{
			if (isMoveThis) 
			{
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false
			}
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false;
		}
		
		override public function set move(move:Boolean):void 
		{
			if (App.user.quests.tutorial || (App.user.mode == User.OWNER && App.user.worldID == User.FARM_LOCATION)) 
			{
				return;
			}
			super.move = move;
			
			if (!move && isMoveThis)
				previousPlace();
		}
		
		override public function previousPlace():void 
		{
			super.previousPlace();
			
			if (contLight) 
			{
				removeChild(contLight);
				contLight = null;
			}
		}
		
		private var contLight:LayerX;
		private function showBorders():void 
		{
			contLight = new LayerX();
			
			var sqSize:int = 30;
			
			var cont:Sprite = new Sprite();
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0x89d93c);
			sp.graphics.drawRoundRect(0, 0, 400, 400, 400, 400);
			sp.rotation = 45;
			sp.alpha = 0.5;
			
			cont.addChild(sp);
			cont.height = 400 * 0.7;
			
			contLight.addChild(cont);			
			contLight.y = -contLight.height / 2;			
			addChildAt(contLight, 0);
		}
		
		private function enableHunger():void 
		{
			
			setTimeout(function():void { hungry(); }, startHungryCloud );
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
			
			if (data.fneed)
				fneed = data.fneed
			this.cell = coords.x 
			this.row = coords.z;			
			this.movePoint = new Point(coords.x,coords.z);
			//hungry();
			this.id = data.id;
			
			//
			hungry();
			goHome();
			setCloudCoords();
		}
		
		override public function update(e:* = null):void 
		{
			super.update(e);
			if (App.data.storage[sid].base == 0)
			{
				if (framesDirection == FACE)
				{
					if (shadow.scaleY < 0)
					{
						//shadow.scaleY = Math.abs(shadow.scaleY);
						shadow.y = shady - (shadow.height / 2);
					}
				}
				if (framesDirection == BACK)
				{
					if (shadow.scaleY > 0)
					{
						//shadow.scaleY = shadow.scaleY * -1;
						shadow.y = shady - (shadow.height / 2);
					}
				}		
				if (framesFlip == RIGHT)
				{
					if (shadow.scaleX > 0)
					{
						shadow.scaleX = shadow.scaleX * -1;
						shadow.x = shadow.x + shadow.width;
					}
				}
				if (framesFlip == LEFT)
				{
					if (shadow.scaleX < 0)
					{
						shadow.scaleX = Math.abs(shadow.scaleX); 
						shadow.x = shadow.x - shadow.width;
					}
				}
			}
		}
		
		override public function free():void 
		{
			showBorders();
			super.free();
		}
		
		override public function onMoveAction(error:int, data:Object, params:Object):void {
			
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
			
			if (error) {
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
			
			if (started > 0)
				goHome();
				
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false;
		}
		override public function take():void {
			
		}
		
		private function onMapComplete(e:AppEvent):void
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			if (started > 0)
				goHome();
		}
		
		public function hungry():void
		{
			if (!cloudAnimal) 
			{
				showIcon('require', feedEvent, AnimalCloud.MODE_NEED, 'animalHungryBackingDark', .38, 4000, .7);
			}
		}
		
		override public function set touch(touch:Boolean):void
		{
			if (App.user.mode == User.GUEST || checkRemove == false )
				return;
			if (!checkRemove) return;
			
			stopWalking();
			onGoHomeComplete();
			
			super.touch = touch;
		}
		override public function setRest():void 
		{
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			
			framesType = randomRest;
			startSound(randomRest);
			saySomethingFilter();
			
			if (restCount <= 0){
				loopFunctionn = goHome;
			}else
				loopFunctionn = setRest
			restCount--;
		}
		
		override public function onGoHomeComplete():void 
		{
			stopCount = generateStopCount();
			stopRest();
		}
		
		override public function stopRest():void 
		{
			if (framesType != Personage.STOP)
			{
				framesType = Personage.STOP;
				if (timer > 0)
					clearTimeout(timer);
			}
			
			if (stopCount <= 0){
				restCount = generateRestCount();
				loopFunctionn = setRest;
			}else
				loopFunctionn = stopRest
			stopCount--;
		}
		
		private var hungryCloseTween:TweenLite;
		private function closeHungryCloud():void 
		{
			if(this.cloudAnimal)hungryCloseTween = TweenLite.to(this.cloudAnimal, 1, { alpha:0, scaleX:0.3, scaleY:0.3, x:(this.cloudAnimal.x + 20), y:(this.cloudAnimal.y + 60), onComplete:realHungCloudClose});
		}
		
		private function realHungCloudClose():void
		{
			if (hungryCloseTween) {
				hungryCloseTween.kill();
				hungryCloseTween = null;
			}
			if (this.cloudAnimal)
			{
				this.cloudAnimal.dispose();
				this.cloudAnimal = null;
			}
		}
		public function disposeShadow():void
		{
			shadowBitmap = new Bitmap();
			
		}
		private var checkRemove:Boolean = true;
		
		public function onFishDeath():void
		{
			TweenLite.to(this, 2, { x:this.x, y:this.y, alpha: 0, onComplete: uninstall});
		}
		
		public function storageUninstall():void 
		{ 
			checkRemove = false;
			stopWalking();
			clearIcon();
			var distanceToDisappear:int = 7;
			if ( this.velocity <= 0.03 )
				distanceToDisappear = 2;
			var place:Object = findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:coords.x, z:coords.z}}, distanceToDisappear);
			initMove(
				place.x,
				place.z
			);
			_dethTimeout = setTimeout(onFishDeath, 3000);
			
			if (this.cloudAnimal)
			{
				this.cloudAnimal.dispose();
				this.cloudAnimal = null;
			}
		}
		
		private var _dethTimeout:uint = 3;
		override public function uninstall():void 
		{
			loopFunctionn = null;
			clearTimeout(timer);
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			realHungCloudClose();
			App.self.setOffEnterFrame(update);
			
			var index:int = App.user.animals.indexOf(this)
			if (index != -1)
				App.user.animals.splice(index, 1);
			clearTimeout(_dethTimeout);
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onUp);
			
			super.uninstall();
		}
		
		private var isMoveThis:Boolean = false;
		public static var isMove:Boolean = false;
		private var intervalMove:int;
		override public function onDown():void 
		{
			if (!checkRemove) return;
			if (App.user.mode == User.OWNER) 
			{
				if (isMove) {
					clearTimeout(intervalMove);
					isMove = false;
					isMoveThis = false;
				}else{
					var that:Animal = this;
					intervalMove = setTimeout(function():void {
						isMove = true;
						isMoveThis = true
						that.move = true;
						App.map.moved = that;
					}, 200);
				}
			}
		}
		
		private var intervalCloud:int = 0;
		private var lock:Boolean = false;
		private var hasProduct:Boolean = false;
		override public function click():Boolean
		{
			clearTimeout(intervalMove);
			
			if (this.id == 0) 
				return false;
				
			if (!checkRemove) return false;
				
			if (App.user.useSectors)
			{
				var node1:AStarNodeVO = App.map._aStarNodes[this.homeCoords.x][this.homeCoords.z];
				
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
			
			if (this.sid == 1077 || this.sid == 1498)
			{
				if (cloudAnimal && !cloudAnimal.visible)
				{
					clearTimeout(intervalCloud);
					cloudAnimal.visible = true;
					intervalCloud = setTimeout(function():void 
					{
						if (cloudAnimal)
						{
							cloudAnimal.visible = false;
						}
					}, 4000);
					return true;
				}
			}
			
			if (lock) return false;
			
			if(isMoveThis){
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false
				return true;
			}
			
			if (App.user.mode == User.GUEST) {
				return true;
			}
			
			if (producting)
			{
				showIcon('outs', storageEvent, AnimalCloud.MODE_CRAFTING, 'productBacking2', 0.8);
				return true;
			}
			
			if (hasProduct)
			{
				lock = true;
				storageEvent();
				
				return true;
			}
			if (this.cloudAnimal)
			{
				feedEvent();
			}else 
				showIcon('require', feedEvent, AnimalCloud.MODE_NEED, 'animalHungryBackingDark', .38, 4000, .7);
			
			return true;
		}
		//public var coordsCloud:Object = new Object();
		private function showIcon(typeItem:String, callBack:Function, mode:int, btmDataName:String = 'animalHungryBackingDark', scaleIcon:Number = 0.6, timeDelay:int = 4000, scaleBttn:Number = 0.8):void 
		{
			if (App.user.mode == User.GUEST)
				return;
				
			if (cloudPositions.hasOwnProperty(App.data.storage[sid].view) ) 
			{
				coordsCloud.x = cloudPositions[this.info.view].x;
				coordsCloud.y = cloudPositions[this.info.view].y - depth_animal;
			}else{
				if (App.data.storage[sid].hasOwnProperty('cloudoffset') && (App.data.storage[sid]['cloudoffset'].dx != 0 || App.data.storage[sid]['cloudoffset'].dy != 0))
				{
					coordsCloud.x = App.data.storage[sid]['cloudoffset'].dx;
					coordsCloud.y = App.data.storage[sid]['cloudoffset'].dy;
				}else{
					coordsCloud.x = 0;
					coordsCloud.y = -50;
				}
			}
				
			if (mode == 3) 
			{
				setCloudCoords();
				drawIcon(UnitIcon.ANIMAL, 2, 1, {
					progressBegin:	started - info.duration,
					progressEnd:	started,
					boostPrice: info.speedup,
					iconDX: 0,
					iconDY: 0
				}, 0, coordsCloud.x, coordsCloud.y);
			}else {
				clearIcon();
				if (this.cloudAnimal) 
				{
					this.cloudAnimal.dispose();
					this.cloudAnimal = null;
				}
				if (fneed)
				{
					if (App.user.stock.checkAll(fneed))
					{
						btmDataName = 'animalHungryBackingLight';
					}
				}
				else
				{
					if (App.user.stock.checkAll(info.require))
					{
						btmDataName = 'animalHungryBackingLight';
					}
				}
				this.cloudAnimal = new AnimalCloud(callBack, this, sid, mode, {scaleIcon:scaleIcon, timeDelay:timeDelay, scaleBttn:scaleBttn, level:_level});
				this.cloudAnimal.create(btmDataName);
				this.cloudAnimal.show();
				
				setCloudCoords();
				if (this.sid == 1077 || this.sid == 1498)
				{
					clearTimeout(intervalCloud);
					intervalCloud = setTimeout(function():void 
					{
						if (cloudAnimal && !hasProduct)
						{
							cloudAnimal.visible = false;
						}
					}, 4000);
				}
				
			}
		}
		
		public function setCloudCoords():void 
		{
			if (cloudAnimal && cloudPositions.hasOwnProperty(this.info.view))
			{
				cloudAnimal.x = cloudPositions[this.info.view].x;
				cloudAnimal.y = cloudPositions[this.info.view].y - depth_animal;
			}	
			else if (cloudAnimal && App.data.storage[sid].hasOwnProperty('cloudoffset') && (App.data.storage[sid]['cloudoffset'].dx != 0 || App.data.storage[sid]['cloudoffset'].dy != 0))
			{
				cloudAnimal.x = App.data.storage[sid]['cloudoffset'].dx;
				cloudAnimal.y = App.data.storage[sid]['cloudoffset'].dy;
			}
			else if (cloudAnimal && cloudScale.hasOwnProperty(this.info.view))
			{
				cloudAnimal.scaleX = cloudScale[this.info.view].x;
				cloudAnimal.scaleY = cloudScale[this.info.view].y;
				
			}
			
			//calculateShadow();
		}
		
		private var producting:Boolean = false;
		
		private var started:uint = 0;
		
		private function feedEvent():void
		{
			if (!checkRemove)
				return;
			lock = true;
			//var reqObj:Object = {};
			var require:Object = App.data.storage[sid].require
			if (fneed)
				require = fneed;
			else if (devel && _level != 0)
				require = App.data.storage[sid].devel.req[_level].fneed
			if (!App.user.stock.takeAll(require))
			{
				for (var req:* in require)
				{
					break;
				}
				if (Numbers.countProps(require) > 1)
				{
					var _require:Object = new Object();
					_require[Numbers.firstProp(require).key] = Numbers.firstProp(require).val
					require = new Object();
					require = _require;
					
				}
				
				var needParams:Object = {
					title:Locale.__e("flash:1435241453649"),
					text:Locale.__e('flash:1478278445176'),
					height:230,
					neededItems: require,
					button3:true,
					button2:true
				};
				//var text:String = Locale.__e('flash:1478278445176');
				if (sid == 2038 || sid == 2035 || sid == 2037)
				{
					needParams['text'] = Locale.__e('flash:1500547942690');
					//needParams['button3'] = false;
				}
				//reqObj = require;
				
				new NeedResWindow(needParams).show()
				lock = false;
				return;
			}
			
			for (var out:* in require)
			{
				break;
			}
			
			var point:Point = new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y - depth_animal);
			Hints.minus(out, App.data.storage[sid].require[out], point);
			
			if (this.cloudAnimal)
			{
				this.cloudAnimal.dispose();
				this.cloudAnimal = null;
			}
			goHome();
			App.ui.flashGlowing(this.bitmap, 0x83c42a);
			
			flyMaterial(out);
			
			producting = true;
			Post.send({
				ctr:this.type,
				act:'feed',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				started = data.started;
				App.self.setOnTimer(work);
				changeAnimal(hangry);
				lock = false;
			});		
		}
		
		override public function goHome(_movePoint:Object = null):void 
		{
			
			if (App.user.useSectors)
			{
				if (Numbers.countProps(this.homeCoords) == 0)
					return;
				var node1:AStarNodeVO = App.map._aStarNodes[this.homeCoords.x][this.homeCoords.z];
				if (!node1.sector)
					return;
				if (!node1.sector.open)
				{
					homeRadius = 3;
				}
			}
			super.goHome(_movePoint);
		}
		
		private function flyMaterial(sid:int):void
		{
			var item:BonusItem = new BonusItem(sid, 0);			
			var point:Point = new Point(10, App.self.stage.stageHeight);
			var moveTo:Point = new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y - depth_animal);
			item.fromStock(point, moveTo, App.self.tipsContainer);
		}
		
		private function work():void 
		{
			if (App.time >= started) {
				App.self.setOffTimer(work);
				hasProduct = true;
				showIcon('outs', storageEvent, AnimalCloud.MODE_DONE, 'productBacking', 0.7);
				if(cloudAnimal)cloudAnimal.doIconEff();
				producting = false;
			}
		}
		
		public function onBoostEvent(count:int = 0):void 
		{
			//hasProduct = true;
			if (!App.user.stock.take(Stock.FANT, count)) return;
				var that:Animal = this;			
				producting = false;
				clearIcon();
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (!error && data) {
						
						App.ui.flashGlowing(that.bitmapContainer);
						
						started = data.started;
					}
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}
		
		private function storageEvent():void {
			
			if (!App.user.stock.canTake(info.outs)) 
				return;
			
			if (this.cloudAnimal)
			{
				this.cloudAnimal.dispose();
				this.cloudAnimal = null;
			}
			
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},onStorageEvent);
		}
		
		private function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			if (data.fneed)
				fneed = data.fneed;
			if (data.level)
				_level = data.level;
			hasProduct = false;
			started = 0;
			var matSID:int = 0;
			//var place:Boolean = false;
			
			if (devel)
			{
				changeLevelAnimal();
			}
			if(data.bonus){
				/*for (var mater:* in data.bonus)
				{
					if (App.data.storage[mater].type == 'Walkgolden' || App.data.storage[mater].type == 'Golden' || App.data.storage[mater].type == 'Animal')
					{
						matSID = mater;
						//place = true;
						//App.user.stock.add(mater, data.bonus[mater]);
						//delete data.bonus[mater];
						break;
					}
				}*/
				Treasures.bonus(data.bonus, new Point(this.x, this.y - depth_animal));
				//hungry();
			}
			if (data.out){
				Treasures.bonus(data.out, new Point(this.x, this.y - depth_animal));
				//hungry();
			}
			
			onGoHomeComplete();
			hungry();
			//click();
			clearTimeout(timer);
			if (App.data.storage[sID].immortal != 1){
				count++;
				if (count >= info.count) 
				{
					/*if (place)
					{
						setTimeout(function():void{
							var rewardUnit:Unit = Unit.add( {fromStock:true, sid:matSID, x:coords.x, z:coords.z } );
							rewardUnit.stockAction();
						}, 500);
					}*/
					storageUninstall();	
				}
				else
					changeAnimal(hangry);
			}
			else
			{
				changeAnimal(hangry);
			}
			
				
			lock = false;
		}
		
		private var startHungryCloud:int;
		/*override public function onLoop():void
		{*/	
			/*super.onLoop();
			if (cloudAnimal || started > 0) return;
			
			if (!cloudAnimal && !producting) {}*/
		//}
		
		private function generateHungryStart():int 
		{
			var rnd:int = 100;
			return rnd;
		}
		
		/*override public function onRemoveFromStage(e:Event):void 
		{
			clearTimeout(timer);
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			realHungCloudClose();
			
			super.onRemoveFromStage(e);
		}*/
		
		override public function checkOnSplice(start:*, finish:*):Boolean 
		{
			return false;
		}		
	}
}