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
	import ui.ChatField;
	import ui.Cursor;
	import ui.UnitIcon;
	import ui.UserInterface;
	import wins.HeroWindow;
	import wins.SimpleWindow;
	import wins.ValentineWindow;
	import wins.Window;
	
	public class FakeHero extends WorkerUnit
	{
		public var owner:*;
		public var cloth:Object = {
			'head':0,
			'body':0,
			'sex':'m'
		};
		
		public var aka:String = '';
		public var photo:String = '';
		public var currentTarget:* = null;
		public var targets:Array = [];
		public var fireworkTargets:Array = [];
		public function FakeHero(owner:*, object:Object)
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
			if(object.hasOwnProperty('aka'))
				aka = object.aka;
				
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
			type = 'FakeHero';
			
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
		
		override public function saySomething(bgColor:uint = 0xfffef4, borderColor:uint = 0x123b65, word:String = ''):void 
		{
			super.saySomething(bgColor, borderColor, word);
		}
		
		override public function goHome(_movePoint:Object = null):void 
		{
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
		
		public function showAva():void
		{
			drawIcon(UnitIcon.AVATAR, 1, 1, {
				glow: true,
				iconDX: 0,
				iconDY: 0,
				photo: this.photo
			}, 0, -32, -180);
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
			onHideFunction = showAva;
			textures = data;
			addAnimation();
			getRestAnimations();
			//velocities[0] = 0.2;
			Load.loading(Config.getSwf("Effects", 'bubble_one'), onLoadBubbles);
			
			//if (!App.user.quests.tutorial && (App.user.mode == User.GUEST))
				//App.map.focusedOn(this, false, null, false);
			showAva();
			if(multipleAnime != null)
				removePreloader();
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
		
		override public function initMove(cell:int, row:int, _onPathComplete:Function = null):void
		{
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
			
			path = findPath(App.map._aStarNodes[this.cell][this.row], App.map._aStarNodes[cell][row], App.map._astar);
			
			if (path == null)
			{
				//trace('Не могу туда пройти по-нормальному!');
				//if (snails.indexOf(this.sid) != -1){
					//this.blocked = true;
				//}else{
					noWay(cell, row);
				//}
				
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
		}
		
		override public function setRest():void 
		{
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			
			framesType = randomRest;
			startSound(randomRest);
			
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
				trace('no target');
				return;
			}
				
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
		
		/**
		 * Выполняется когда персонаж останавливается без цели
		 */ 
		override public function onStop():void
		{
			if (_walk)
				return;
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
		}
		
		override public function click():Boolean 
		{
			ChatField.show({text:(aka + ', ')});
			return true;
			
		}
		
		private var bubblesTimeout:uint = 0;		
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
		
		public function getJobFramesType(sid:int):String 
		{
			return Personage.WORK;
		}
		
	}
}