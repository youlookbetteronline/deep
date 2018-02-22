package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.AvaLoad;
	import core.IsoConvert;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import silin.utils.Hint;
	import ui.Cursor;
	import ui.Hints;
	import ui.UnitIcon;
	import ui.UserInterface;
	import utils.InviteHelper;
	import wins.HeroWindow;
	import wins.SimpleWindow;
	import wins.ValentineWindow;
	import wins.Window;
	
	public class Hero extends WorkerUnit
	{
		public static const SOW:String 		= "work";// plant
		public static const HARVEST:String 	= "work";// harvest
		
		public static const PRINCE:String = 'boy';
		public static const PRINCESS:String = 'girl';
		public static var loaded:Boolean = false;
		
		public var owner:*;		
		public var wingsAnimation:Object = { };
		
		public var cloth:Object = {
			'head':0,
			'body':0,
			'sex':'m'
		};
		
		public var photo:String = '';
		public var alien:String = PRINCE;
		public var aka:String = '';
		
		public static var allTargets:Object = {			
			14: [] //Аквалангист
		}
		
		public static function isMain(hero:Hero):Boolean 
		{
			if((hero.sid == 14 && App.user.sex == 'm') || (hero.sid == 15 && App.user.sex == 'f'))
				return true;
			
			return false;	
		}
		
		public static function isInTargets(sid:int):Boolean 
		{
			for (var pers_sid:* in allTargets) 
			{
				if (allTargets[pers_sid].indexOf(sid) != -1) {
					return true;
				}
			}
			
			return false;	
		}
		
		public static function getNeededHero(sid:int,info:Object):Hero {
			
			var persSID:int = 0;
			for (var pers_sid:* in allTargets) {
				if (allTargets[pers_sid].indexOf(sid) != -1) {
					persSID = pers_sid;
				}
			}
			
			if (App.data.storage[sid].kick) 
			{
				return null
			}
			
			
			for each(var pers2:Hero in App.user.personages) 
			{
				return pers2;
			}
			
			return null;
		}
		
		public var currentTarget:* = null;
		public var targets:Array = [];
		public var fireworkTargets:Array = [];
		public function Hero(owner:*, object:Object)
		{
			//owner.sex = 'f';
			var view:String = ''
			
			if (owner.sex == 'f')
			{
				view = 'girl';
			}else {
				view = 'boy';
			}
			
			this.owner = owner;
			
			if(this.owner.hasOwnProperty('photo'))
				photo = this.owner.photo;
			else
				photo = 'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg';

			if (owner.head == null || owner.head == 0)
			{
				if (owner.sex == 'm')
					owner.head = User.BOY_HEAD;
				else
					owner.head = User.GIRL_HEAD;
			}
			
			if (owner.body == null || owner.body == 0)
			{
				if (owner.sex == 'm')
					owner.body = User.BOY_BODY;
				else
					owner.body = User.GIRL_BODY;
			}
			
			cloth.sex = owner.sex;
			cloth.head = owner.head;//12;
			cloth.body = owner.body;//14;
			
			super(object, view);
			
			//velocities = [0.1, 0.1];
			
			moveable = false;
			removable = false;
			transable = false;
			flyeble = true;
			rotateable = false;
			
			if (owner is Owner)
			{
				touchable = false;
				clickable = false;
				if (owner.id != 1)
				{
					createAva(owner);
				}
			}
			
			hasMultipleAnimation = true;
			
			tm = new TargetManager(this);
			framesType = STOP;
			velocities = [0.2];
		}
		
		public var main:Boolean = false;
		private var liveTimer:uint = 0;
		
		override public function beginLive():void
		{
			if (main) return;
			return;
			
			var time:uint = 3000 + int(Math.random() * 3000);
			liveTimer = setTimeout(goHome, time);
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			//return EMPTY;
			for (var i:uint = 0; i < cells; i++)
			{
				for (var j:uint = 0; j < rows; j++)
				{
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					
					if  ((node.b != 0) || (node.p != 0) || node.open == false|| node.object != null) 
					{
						return OCCUPIED;
					}
				}
			}
			return EMPTY;
		}
		
		public function addPreloader():void 
		{	
			if (owner.sex == 'f')
				preloader = new Bitmap(UserInterface.textures.girlLoader);
			else
				preloader = new Bitmap(UserInterface.textures.boyLoader);
			
			preloader.x = -29;
			preloader.y = -71 - 30;			
			
			addChild(preloader);
		}
		override public function goHome(_movePoint:Object = null):void 
		{
			clearTimeout(liveTimer);
			liveTimer = 0;
			
			if (workStatus == BUSY) 
				return;
			
			loopFunctionn = onLoop;
			
			var place:Object;	
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:movePoint.x, z:movePoint.y}}, homeRadius);
			
			framesType = Personage.WALK;
			
			initMove(
				place.x, 
				place.z,
				onGoHomeComplete
			);
		}
		
		override public function stopLive():void
		{
			if (main) return;
			
			if (liveTimer > 0)
			{
				clearTimeout(liveTimer);
				liveTimer = 0;
			}	
		}
		
		private function getClothView(sID:uint):String
		{
			return App.data.storage[sID].preview;
		}
		
		override public function load():void
		{
			if (preloader) 
				addChild(preloader);
			
			Load.loading(Config.getSwf('Clothing', getClothView(cloth.body)), onLoad);
			Load.loading(Config.getSwf('Clothing', getClothView(cloth.head)), onHeadLoad);
			
		}
		
		public function change(clothSettings:Object , callback:Function = null):void
		{
			cloth.body = clothSettings.sID;
			cloth.head = clothSettings.head;
			cloth.sex = clothSettings.sex;
			this.scaleX = this.scaleY = 1;
			
			Load.loading(Config.getSwf('Clothing', getClothView(cloth.body)), 
				function(data:*):void {
					textures = data;
					if (callback != null) callback();
				}
			);
			Load.loading(Config.getSwf('Clothing', getClothView(cloth.head)), 
			function(data:*):void {
					multipleAnime = data.animation.animations;
					if (callback != null) callback();
				}
			);	
		}
		
		private function onHeadLoad(data:*):void
		{
			hasMultipleAnimation = true;
			multipleAnime = data.animation.animations;
			
			if (textures != null)
				removePreloader();
		}
		
		override public function onLoad(data:*):void
		{
			if (App.isSocial('AM')){
				InviteHelper.checkRequests();
			}
			
			textures = data;
			loaded = true;
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_HERO_LOAD));
			getRestAnimations();
			App.ui.resize();
			//velocities[0] = 0.2;
			Load.loading(Config.getSwf("Effects", 'bubble_one'), onLoadBubbles);
			
			checkPet();
			if (!App.user.quests.tutorial && (App.user.mode == User.GUEST))
				App.map.focusedOn(this, false, null, false);
			
			if(multipleAnime != null)
				removePreloader();
				
			addAnimation();
			App.map.allSorting();
			//drawAntiFog();
		}/*
		
		override public function set x(value:Number):void 
		{
			super.x = value;
			circle.x = x;
			
		}
		
		override public function set y(value:Number):void 
		{
			super.y = value;
			circle.y = y;
		}*/
		
		public var circle:Shape = new Shape();
		public function drawAntiFog():void 
		{
			var radius:int = 300; 
			
			circle.graphics.beginFill(0, 1);
			circle.graphics.drawCircle(0, 0, radius);
			circle.graphics.endFill();
			circle.filters = [new BlurFilter(120, 120)];
			App.map.mFog.addChild(circle);
			var point:Object = IsoConvert.isoToScreen(coords.x, coords.z, true);
			circle.cacheAsBitmap = true;
			circle.x = point.x;
			circle.y = point.y;
			circle.cacheAsBitmap = true;
			App.map.mFog.alpha = .8
			circle.blendMode = BlendMode.ERASE;
		}
		
		private var animeBubble:Anime;
		public function onLoadBubbles(data:*):void 
		{
			if (data.animation)
			{
				var framesType:String;
				for (framesType in data.animation.animations) break;
				
				animeBubble = new Anime(data, framesType, data.animation.ax, data.animation.ay - 165);
				animeBubble.scaleX = animeBubble.scaleY = .5;
				animeBubble.addAnimation();
				this.addChild(animeBubble);
				playBubbles();
			}
		}
		
		public function playBubbles():void
		{
			if (App.user.worldID == User.AQUA_HERO_LOCATION)
				return;
				
			if(this.framesType != 'work')
				animeBubble.startAnimationOnce(true);
			
			bubblesTimeout = setTimeout(playBubbles, 6000 + Math.random() * 2000);
		}
		
		public var ava:Sprite;
		
		private var avatarSprite:Sprite = new Sprite();
		private var avatar:Bitmap;
		private var friendID:*;
		
		public function createAva(friend:Object):void 
		{
			if (friend.hasOwnProperty('uid'))
				friendID = friend.uid;
			else
				friendID = friend.id;
				
				
			ava = new Sprite();
			ava.name = 'ava';
			var bg:Bitmap = Window.backing(74, 74, 10, "textSmallBacking");
			ava.addChild(bg);
			
			avatar = new Bitmap(null, "auto", true);
			avatarSprite.addChild(avatar);
			avatarSprite.x = 12;
			avatarSprite.y = 12;
			ava.addChild(avatarSprite);
			
			if (App.user.friends.data[friendID].first_name != null) {
				drawAvatar();
			}else {
				App.self.setOnTimer(checkOnLoad);
			}
			
			var arrow:Sprite = Window.shadowBacking(10, 10, 6);
			ava.addChild(arrow);
			arrow.x = ava.width / 2 - 5;
			arrow.y = bg.x + bg.height - 2;
			
			App.map.mTreasure.addChild(ava);
			ava.x = x - 38;
			ava.y = y - 168;
			
			ava.mouseChildren = false;
		}
		
		private function checkOnLoad():void
		{
			if (App.user.friends.data[friendID].first_name != null) 
			{
				App.self.setOffTimer(checkOnLoad);
				drawAvatar();
			}
		}
		
		override public function uninstall():void
		{
			clearTimeout(petTimer)
			if (bubblesTimeout > 0)
				clearTimeout(bubblesTimeout);
			App.self.setOffTimer(checkOnLoad);
			super.uninstall();
		}
		
		private function drawAvatar():void 
		{
			var friend:Object = App.user.friends.data[friendID];
			var name:TextField = Window.drawText(friend.aka || friend.first_name, {
				fontSize:18,
				color:0x502f06,
				borderColor:0xf8f2e0,
				autoSize:"left"
			});
			
			ava.addChild(name);
			name.x = (ava.width - name.width) / 2;
			name.y = -6;
			
			new AvaLoad(friend.photo, function(data:*):void {
				avatar.bitmapData = data.bitmapData;
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0x000000, 1);
				shape.graphics.drawRoundRect(0, 0, 50, 50, 15, 15);
				shape.graphics.endFill();
				avatarSprite.mask = shape;
				avatarSprite.addChild(shape);
			});
		}
		override public function clearVariables():void 
		{
		}
		
		private var petTimer:uint = 1;
		override public function initMove(cell:int, row:int, _onPathComplete:Function = null):void
		{
			if (Hero.crabBart)
			{
				var place:Object = findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:cell, z:row}}, 4);
				petTimer = setTimeout(function():void
				{
					Hero.crabBart.framesType = Personage.WALK;
					Hero.crabBart.initMove(place.x, place.z, Hero.crabBart.onGoHomeComplete);
				}, 1500);
			}
			
			frame = 0;
			loopFunctionn = onLoop;
			framesType = Personage.WALK;
			
			onPathComplete = _onPathComplete;
			
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
			coords
			path = findPath(App.map._aStarNodes[this.cell][this.row], App.map._aStarNodes[cell][row], App.map._astar);
			
			if (path == null)
			{
				//trace('Не могу туда пройти по-нормальному!');
				if (snails.indexOf(this.sid) != -1){
					this.blocked = true;
				}else{
					noWay(cell, row);
				}
				
				if (path == null)
				{
					this._walk = false;
					pathCounter = 1;
					t = 0;
					App.self.setOffEnterFrame(walk);
					_framesType = 'stop_pause';
					return;
				}
			}
			
			this.blocked = false;
			
			pathCounter = 1;
			t = 0;
			walking();
			
			if (!App.user.quests.tutorial && App.user.pet) {
				var petPos:Point = Pet.getPositionForPet(cell, row);
				App.user.pet.initMove(petPos.x, petPos.y, App.user.pet.onStop);
			}
		}
		
		override public function setRest():void {
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			
			framesType = randomRest;
			if (App.user.quests.tutorial && ((App.user.quests.data.hasOwnProperty("1") && App.user.quests.data[1].finished == 0) || (App.user.quests.data.hasOwnProperty("191") && App.user.quests.data[191].finished == 0)))
			{
				if (owner.sex == 'f')
				{
					framesType = 'idle4';
				}else {
					framesType = randomRest;
				}
			}
			startSound(randomRest);
			if(!App.user.quests.tutorial)
			{
				saySomethingFilter();
			}
			restCount--;
			if (restCount <= 0){
				stopCount = generateStopCount();
				loopFunctionn = stopRest;
			}else
				loopFunctionn = setRest;
		}
		
		/**
		 * Заканчиваем действие и изменяем цель
		 * @param	e
		 */
		override public function finishJob(e:AppEvent = null):void
		{
			if (progressBar != null)
			{
				progressBar.removeEventListener(Event.COMPLETE, finishJob);
				
				if(App.map.mTreasure.contains(progressBar))
					App.map.mTreasure.removeChild(progressBar);
				progressBar = null;
			}
			
			if (tm.currentTarget && tm.currentTarget.target is Resource && App.user.pet)
				App.self.dispatchEvent(new AppEvent(AppEvent.USER_FINISHED_JOB, false, false, {count:1, rid:tm.currentTarget.target.sid}));
			else if (tm.currentTarget && tm.currentTarget.target is Field && tm.currentTarget.event == Personage.GATHER)
				App.self.dispatchEvent(new AppEvent(AppEvent.USER_FINISED_HARVEST));
			
			if (tm.currentTarget != null)
			{
				if (tm.currentTarget.target.hasOwnProperty('isTarget'))
					tm.currentTarget.target.isTarget = false;
				
				tm.onTargetComplete();
			}
			if (tm.currentTarget && tm.currentTarget.target.hasOwnProperty('reserved') && tm.currentTarget.target['reserved'] == 0)
				afterWorkStop();
				
			if (!tm.currentTarget)
			{
				onStop();
				//afterWorkStop();
				//trace('no target');
				return;
			}
			
			if (tm.currentTarget.target is Resource || tm.currentTarget.target is Walkresource)
				return;
			if (!(tm.currentTarget.target is Resource) && App.user.queue.length == 0 && !_walk)
				afterWorkStop();
		}
		
		public function afterWorkStop():void
		{
			onStop();
		}
		
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> 
		{
			shortcutDistance = 40;
			var needSplice:Boolean = checkOnSplice(start, finish);
			
			if (App.user.quests.tutorial && tm.currentTarget != null)
				tm.currentTarget.shortcutCheck = true;
			
			if (!false)
			{
				var path:Vector.<AStarNodeVO> = _astar.search(start, finish);
				if (path == null) 
					return null;
				
				if (tm.currentTarget != null) 
				{
					if (path.length > shortcutDistance) 
					{
						path = path.splice(path.length - 5, 5);
						placing(path[0].position.x, 0, path[0].position.y);
						alpha = 0;
						TweenLite.to(this, 1, { alpha:1 } );
						return path;
					}
				}
				
				if ((path.length > shortcutDistance) || (tm.currentTarget != null && tm.currentTarget.shortcut))
				{
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
		}
		
		public function updateCellRow():void
		{
			this.cell = coords.x;
			this.row = coords.z
		}
		
		/**
		 * Выполняется когда персонаж останавливается без цели
		 */ 
		override public function onStop():void
		{
			stopCount = generateStopCount();
			stopRest();
		}
		
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
		
		/**
		 * Выполняется когда персонаж доходит до цели
		 */ 
		override public function onPathToTargetComplete():void
		{
			startJob();
		}
		
		public static var crabBart:*;
		public function checkPet():void 
		{
			//return;
			if (App.user.mode == User.OWNER)
			{
				var place:Object;
				
				if (App.user.quests.data.hasOwnProperty("233") && App.user.quests.data[233].finished != 0)
				{
					if (Hero.crabBart)
					{
						Hero.crabBart.applyRemove = false;
						Hero.crabBart.removable = true;
						Hero.crabBart.remove();
					}
					else
						return;
				}
				
				if (App.user.quests.data.hasOwnProperty("225"))
				{
					if (Hero.crabBart)
						return
					Hero.crabBart = new Personage( { sid:535, x:coords.x, z:coords.z } );
					place = findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:coords.x, z:coords.z}}, 3);
					Hero.crabBart.initMove(place.x, place.z, Hero.crabBart.setRest);
				}
				
			}
		}
		
		override public function set touch(touch:Boolean):void
		{
			if (Cursor.type == 'stock' && stockable == false) return;
			
			if (!touchable || (App.user.mode == User.GUEST && touchableInGuest == false)) return;
			
			
			_touch = touch;
			
			if (touch) {
				if(state == DEFAULT){
					state = TOCHED;
				}else if (state == HIGHLIGHTED) {
					state = IDENTIFIED;
				}
				
			}else {
				if(state == TOCHED){
					state = DEFAULT;
				}else if (state == IDENTIFIED) {
					state = HIGHLIGHTED;
				}
			}
		}
		
		
		override public function workerFree():void 
		{
		}
		
		override public function generateStopCount():uint 
		{
			return int(Math.random() * 5) + 8;
		}
		
		override public function onLoop():void
		{	
			//super.onLoop();
			/*if(_framesType == HARVEST)
				SoundsManager.instance.playSFX(sounds[sid]['gathering'], this);*/  // не забыть включить
		}
		
		//override public function walk(e:Event = null):* 
		//{
			//switch(alien) {
				//case PRINCE:
					//velocity = 0.18;
					//break;
				//case PRINCESS:
					//velocity = 0.18;
					//break;	
			//}
			/*if (flyeble && path.length > 10 && pathCounter > 2 && pathCounter < path.length - 5){
				startFly();
				velocity = velocities[1];
			}else{	
				finishFly();
				velocity = velocities[0];
			}*/	
			//App.map.mFog.cacheAsBitmap = true;
			//super.walk();
			//circle.x = this.x;
			//circle.y = this.y;
		//}
		
		public function inViewport():Boolean 
		{
			var globalX:int = this.x * App.map.scaleX + App.map.x;
			var globalY:int = this.y * App.map.scaleY + App.map.y;
			
			if (globalX < -10 || globalX > App.self.stage.stageWidth + 10) 	return false;
			if (globalY < -10 || globalY > App.self.stage.stageHeight + 10) return false;
			
			return true;
		}
		
		override public function click():Boolean 
		{
			
			return true;
			
		}
		
		private var bubblesTimeout:uint = 0;
		public static function randomSound(sid:uint, type:String):String {
			if (sounds[sid][type] is Array)
				return sounds[sid][type][int(Math.random() * sounds[sid][type].length)];
			else
				return sounds[sid][type];
		}
		
		public static var sounds:Object = {
			/*5: {//Трик
				gathering:'gathering_sound_3',
				voice:['speak_7','speak_8','speak_9']
			},
			230: {//Леа
				gathering:'gathering_sound_2',
				voice:['speak_4','speak_5','speak_6']
			},
			229: {//Хек
				gathering:'gathering_sound_1',
				voice:['speak_1','speak_2','speak_3']
			}*/
		}
		
		private var lastVoice:uint = 0;
		public function makeVoice():void {
			if (!canVoice()) return;
			SoundsManager.instance.playSFX(randomSound(sid, 'voice'), null, 0, 3);
			lastVoice = App.time;
		}
		
		public function canVoice():Boolean {
			
			return false;
			
			if (lastVoice +10 < App.time)
				return true;
				
			return false;	
		}
		
		
		 /**
		 * Отправляем цель в TargetManager
		 * @param	targetObject имеет target, jobPosition, callback
		 */
		override public function addTarget(targetObject:Object):Boolean
		{
			tm.add(targetObject);
			stopLive();
				
			return true;
		}
		
		public function getJobFramesType(sid:int):String {
			return Personage.WORK;
		}
		
	}
}