package units 
{
	import com.adobe.images.PNGEncoder;
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import utils.Saver;
	import wins.ConstructWindow;
	import wins.EaselWindow;
	import wins.Window;
	import wins.WindowEvent;
	import wins.elements.PuzzleItem;
	import wins.happy.HappyGuestWindow;
	import wins.happy.HappyToy;
	import wins.happy.HappyWindow;
	import wins.happy.HappyWindowInvader;
	
	//
	//Denis
	//htype = 1 (обычная) = не учитывает параметр expire и top.   
	//Вечный хеппи.
	//
	
	public class Happy extends Building 
	{
		public var kicks:int = 0;
		public var guests:Object = { };
		public var upgrade:int = 0;
		public var toys:Object = { };
		public var expire:int = 0;
		public var topNumber:int = 0;
		public static var users:Object = {};
		public var usersLength:int = 0;
		
		public function Happy(object:Object) 
		{
			/*if (!App.data.storage[object.sid]['devel']) {
				App.data.storage[object.sid]['devel'] = { };
				App.data.storage[object.sid]['devel']['req'] = { };
			}*/
			//object.level = 4;
			
			if (object['kicks'])
				kicks = object.kicks;

			if (object['guests'])
				guests = object.guests;

			if (object['materials'])
				toys = object.materials;
			
			super(object);
					
			if (info.hasOwnProperty('expire') && info.expire.hasOwnProperty(App.social))
			{
				var _expire:int = info.expire[App.social];//TimeConverter.strToTime(
				if (_expire > 0) {
					expire = _expire;
				}else {
					expire = info.time;
				}
			}
			else
			{
				expire = info.time;
			}
			
			if (info.hasOwnProperty('tower')) 
			{
				totalLevels = Numbers.countProps(info.tower);
			}

			removable = false;
			if (expire < App.time && info.htype!=1)
				removable = true;
				
			if (info.rSID == 1152)
			{
				removable = false;
				stockable = false;
				moveable = false;
				rotateable = false;
			}
			//if (expire < App.time )
				//stockable = true;

			if (info.hasOwnProperty('topx'))
			{
				if (info.topx.hasOwnProperty(App.social) )
					topNumber = info.topx[App.social] ;
				else
					topNumber = info.topx;
			}
			if (!topNumber)
			{
				topNumber = 50;
			}
			checkLevel();
			touchableInGuest = false;
		}
		
		override public function load(hasReset:Boolean = false):void 
		{
			if (textures) 
			{
				stopAnimation();
				textures = null;
			}
			
			var _view:String = info.view;
			//_view = info.view;
			if (info.hasOwnProperty('start') && level == 0) {
				level = info.start;
			}
			
			/*if (info.hasOwnProperty('tower') && info.tower.hasOwnProperty(this.level+1)) 
			{
				var viewLevel:int = this.level + 1;
				while (true) 
				{
					if (info.tower[viewLevel].hasOwnProperty('v') && String(info.tower[viewLevel].v).length > 0) 
					{
						if (info.tower[viewLevel].v == '0') 
						{
							if (viewLevel > 0) 
							{
								viewLevel --;
							}
							else 
							{
								break;
							}
						} 
						else 
						{
							_view = info.tower[viewLevel].v;
							break;
						}
					}
					else if (viewLevel > 0) 
					{
						viewLevel --;
					}
					else 
					{
						break;
					}
				}
			}else{
				if (info.hasOwnProperty('tower') && info.tower.hasOwnProperty(this.level) && this.level >= Numbers.countProps(info.tower)) 
				{
					_view = info.tower[this.level].v;
				}
			}*/
			
			/*if (info.hasOwnProperty('start') && level == 0) 
			{
				level = info.start;
			} 
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('req')) 
			{
				var viewLevel:int = level;
				while (true) 
				{
					if (info.devel.req.hasOwnProperty(viewLevel) && info.devel.req[viewLevel].hasOwnProperty('v') && String(info.devel.req[viewLevel].v).length > 0) 
					{
						if (info.devel.req[viewLevel].v == '0') 
						{
							if (viewLevel > 0) 
							{
								viewLevel --;
							}
							else 
							{
								break;
							}
						} 
						else 
						{
							_view = info.devel.req[viewLevel].v;
							break;
						}
					}
					else if (viewLevel > 0) 
					{
						viewLevel --;
					}
					else 
					{
						break;
					}
				}
			}*/
			
			Load.loading(Config.getSwf(type, _view), onLoad);
			//loadParts();
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			redrawParts();
		}
		
		public function redrawParts():void
		{
			loadParts();
			updateLevel();
		}
		
		private var loadedParts:Boolean = false;
		private var parts:Array;
		private var partsSprite:LayerX;
		private var partsBitmap:Bitmap;
		private function loadParts():void
		{
			loadedParts = false;
			//parts = new Array();
			partsSprite = new LayerX();
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0, 0);
			shape.graphics.drawRect(0, 0, 1, 1);
			shape.graphics.endFill();
			partsSprite.addChild(shape);
			
			_counter = 0;
			for (var i:int = 0; i < EaselWindow.posArr.length; i++)
			{
				//trace("level: " + level);
				if (i < level)
					continue;
				var item:PuzzleItem = new PuzzleItem({id: i, pos: EaselWindow.posArr[i]}, this);
				item.x =  EaselWindow.posArr[i].x;
				item.y =  EaselWindow.posArr[i].y;
				partsSprite.addChild(item);
			}
			//App.self.addChild(partsSprite);
			/*for (var i:int = 0; i < EaselWindow.posArr.length; i++)
			{
				Load.loading(Config.getImage('paintings/parts', 'PaintPiece' + (i + 1)), function(data:Bitmap):void {
					parts.push(data);
					if (parts.length == EaselWindow.posArr.length)
					{
						loadedParts = true;
						updateLevel();
					}
				});
			}*/
		
		}
		private var _counter:int = 0;
		public function set counter(_count:int):void
		{
			_counter = _count;
			if (_count == EaselWindow.posArr.length - level)
			{
				loadedParts = true;
				updateLevel();
			}
		}
		public function get counter():int
		{
			return _counter;
		}
		
		override public function draw(bitmapData:BitmapData, dx:int, dy:int):void
		{
			bitmap.bitmapData = bitmapData;
			if (info.backview && partsSprite && (loadedParts || level == totalLevels))
			{
				Load.loading(Config.getImage('paintings', info.backview, 'jpg'), function (data:Bitmap):void {
					var tempBitmap:Bitmap = new Bitmap(Size.scaleBitmapData(data.bitmapData, .095), "auto", true);
					partsBitmap = new Bitmap(new BitmapData(partsSprite.width, partsSprite.height, true, 0x0),"auto",true);
					
					partsBitmap.bitmapData.draw(partsSprite);
					
					var scewY:Number = -.75;
					var scewX:Number = .32;
					var matrix:Matrix = new Matrix(1, scewY, scewX, 1, 7.4, 8 +tempBitmap.height * Math.abs(scewY * 1.7));
					bitmap.bitmapData.draw(tempBitmap, matrix);
					bitmap.bitmapData.draw(Size.scaleBitmapData(partsBitmap.bitmapData, .142), matrix);
					
					//Saver.savePNG(bitmap.bitmapData, info.preview);
					
					this.dx = dx;
					this.dy = dy;
					bitmap.x = dx;
					bitmap.y = dy;
				});
			}
			
			this.dx = dx;
			this.dy = dy;
			bitmap.x = dx;
			bitmap.y = dy;
			
			if (rotate /*&& scaleX > 0*/)
			{
				scaleX = Math.abs(scaleX) * -1;
			}
		}
			
		override public function click():Boolean
		{
			//return false;
			if (!isReadyToWork()) return true;
					
			if(App.user.mode == User.OWNER)
			{
				if (isPresent()) return true;
				
				//if (level < totalLevels) {			//D Для строящихся Хеппи
					//openConstructWindow();
					//return true;
				//}
				
				openProductionWindow();
			}
			else
			{
				return false;


				if ( expire < App.time && info.htype!=1)
					return false;

				new HappyGuestWindow( {
					target:		this,
					mode:		HappyGuestWindow.GUEST
				}).show();
			}
			
			return true;
		}
		
		//protected var _openWindowAfterUpgrade:Boolean = true;
		override public function openConstructWindow(openWindowAfterUpgrade:Boolean = true):Boolean 
		{
			if (_constructWindow != null)
				return true;
			
			if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1))
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						//var instanceNum:uint = instanceNumber();
						
						_constructWindow = new ConstructWindow( {
							title:			info.title,
							//upgTime:		info.devel.req[level + 1].t,
							request:		info.devel.obj[level + 1],
							//reward:			info.devel.rew[level + 1],
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true,
							popup:			false
						});
						_constructWindow.addEventListener(WindowEvent.ON_AFTER_CLOSE, onConstructWindowClose);
						_constructWindow.show();
						_openWindowAfterUpgrade = openWindowAfterUpgrade;
						
						return true;
					}
				}
			}
			return false;
		}
		
		/*public function drawIcon(type:String, material:*, need:int = 0, params:Object = null, directSid:int = 0, posX:int = 0, posY:int = 0):void 
		{
		override public function drawIcon(type:String, material:*, need:int = 0, params:Object = null):void
		{
			super.drawIcon(type,material,need,params);
		}*/


		override public function showIcon():void
		{
			//super.showIcon();
		}


		//override public function onLoad(data:*):void 	//No
		//{
			//super.onLoad(data);
			//if ( App.user.mode == User.OWNER )
			//{
				//Post.send( {
					//ctr:		'user',
					//act:		'attraction',
					//uID:		App.user.id,
					//rate:		info.type + '_' + String(sid),
					//max:		topNumber,
					//user:		JSON.stringify({first_name:App.user.first_name, last_name:App.user.last_name, photo:App.user.photo, attraction:kicks })
				//}, function(error:int, data:Object, params:Object):void {
					//if (error) return;
					//
				//});
			//}
		//}
		
		override public function openProductionWindow():void 
		{					//D
			//if(info.window=="HappyWindow")
			if (info.htype == 1)
			{
				new EaselWindow( {
					target:		this,
					kickEvent:  kickAction
				}).show();
				return;
			}else{
				new HappyWindow( {
					target:		this
					//height:	(sid == 2486 || sid == 2877 || sid == 3225)?690:660
				}).show();
			}
			/*else if (info.window == "HappyWindowInvader")
				new HappyWindowInvader( {
					target:		this
					//height:	(sid == 2486 || sid == 2877 || sid == 3225)?690:660
				}).show();*/
		}
		
		public function get hview():String {
			var _view:String;
			for (var s:* in info.tower) {
				if (!_view) _view = info.tower[s]['v'];
				if (upgrade > int(s) && info.tower[s]['v']) _view = info.tower[s]['v'];
				if (upgrade == int(s))
					return info.tower[s]['v'];
			}
			
			return _view;
		}
		
		//D Aheppy
		private static var rates:Object = { };							
		public static function rateUpdate(sid:int, time:int = 0):void {
			rates[sid] = time;
		}
		public static function rateChecked(sid:int):int {
			return rates[sid] || 0;
		}
		
		public function get canUpgrade():Boolean {
			if (kicksNeed > 0 && kicks >= kicksNeed) return true;
			
			return false;
		}
		//D Aheppy
		
		public function get kicksNeed():int {
			var _kicks:int = 0;
			checkLevel();
			if (info.tower.hasOwnProperty(upgrade + 1)) 
			{
				_kicks = info.tower[upgrade + 1].c;
			}
			return _kicks;
		}
		
		public function get kicksMax():int {
			var max:int = 0;
			for (var s:* in info.tower) {
				if (info.tower[s].c > max)
					max = info.tower[s].c;
			}
			return max;
		}
		
		private function checkLevel():void {
			//totalLevels = 0;
			//for (var _lvl:* in info.tower)
				//totalLevels++;
			//if (level > totalLevels) {
				//upgrade = level - totalLevels;
				upgrade = level;
			//}
		}
		
		public function canDecorate():Boolean {
			if (guests.hasOwnProperty(App.user.id) && guests[App.user.id] > App.midnight) {
				return false;
			}
			
			return true;
		}
		public function addGuest(uID:*):void {
			guests[uID] = App.time;
		}
		
		// Actions
		
		/*
		 * kick - добавление материала для роста елки (сам у себя дома)
		- params: uID, sID, wID, id, mID - сид материала со стуков
		- out: bonus, kicks
		*/
		
		public var kickCallback:Function;
		public function kickAction(mID:*, callback:Function = null):void {
			kickCallback = callback;
			
			Post.send( {
				ctr:	type,
				act:	'kick',
				uID:	App.user.id,
				wID:	App.user.worldID,
				id:		id,
				sID:	sid,
				mID:	mID
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.hasOwnProperty('kicks')) kicks = data.kicks;
				
				if (kickCallback != null) {
					/*var bonus:Object;
					if (data.hasOwnProperty('bonus')) {
						bonus = Treasures.convert(data.bonus);
					}*/
					kickCallback(Treasures.treasureToObject(data.bonus));
					kickCallback = null;
				}
			});
		}
		
		public function showReward(bonus:Object):void {
			Treasures.bonus(bonus, new Point(x, y), null, false);
		}
		/*
		 * grow - получение награды и переход на след. уровень.
		- params: uID, sID, wID, id
		- out: level, bonus
		*/
		
		public var growCallback:Function;
		public function growAction(callback:Function = null):void {

			growCallback = callback;
			var that:Happy = this;
			
			Post.send( {
				ctr:	type,
				act:	'grow',
				uID:	App.user.id,
				wID:	App.user.worldID,
				id:		id,
				sID:	sid
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.hasOwnProperty('level')) 
					level = data.level;
				
				checkLevel();
				redrawParts();
				updateLevel();
				takeBonus(Treasures.treasureToObject(data.bonus));
				App.user.stock.addAll(Treasures.treasureToObject(data.bonus));
				
				if (info.htype == 1 && data.hasOwnProperty('id'))
				{
				//if (data.hasOwnProperty('id'))
				//{
				Treasures.bonus(data.bonus, new Point(that.x, that.y));					
				Window.closeAll();
				this.removable = true;
				this.applyRemove = false;
				that.remove();
					
				}else {
					if (growCallback != null) {
						growCallback(Treasures.treasureToObject(data.bonus));
						growCallback = null;
					}
				}
				
				if (level == totalLevels)
				{
					Window.closeAll();
					that.uninstall();
				}
			});
		}
		
		private var takeCount:int = 0;
		private var rewardW:Bitmap;
		private function takeBonus(items:Object, e:MouseEvent = null):void 
		{
			for (var i:String in items) 
			{ 
				Load.loading(Config.getIcon(App.data.storage[i].type, App.data.storage[i].preview), function(data:Bitmap):void {
					closeEarly();
					rewardW = new Bitmap;
					rewardW.bitmapData = data.bitmapData;
					takeCount = items[i];
					wauEffect(e);
				});
			}
		}
		
		
		//private var usedStage:int = 0;
		//override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		//{
            //if (textures == null)
                //return;
			//
			//var numInstance:uint = instanceNumber();
			//
			//var levelData:Object;
			//
			//if (this.level && 
				//info.hasOwnProperty("instance") && 
				//info.instance.hasOwnProperty("devel") && 
				//info.instance.devel.hasOwnProperty(numInstance) && 
				//info.instance.devel[numInstance].hasOwnProperty("req") &&
				//info.instance.devel[numInstance].req.hasOwnProperty(this.level) &&
				//info.instance.devel[numInstance].req[this.level].hasOwnProperty("s") &&
				//textures.sprites[info.instance.devel[numInstance].req[this.level].s])
			//{
				//usedStage = info.instance.devel[numInstance].req[this.level].s;
			//}
			//else if (textures.sprites[this.level]) 
			//{
				//usedStage = this.level;
			//}
			//
			//levelData = textures.sprites[usedStage];
			//
			//if (checkRotate && rotate == true) {
				//flip();
			//}
			//
			//if (this.level != 0 && gloweble)
			//{
				//var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				//backBitmap.x = bitmap.x;
				//backBitmap.y = bitmap.y;
				//addChildAt(backBitmap, 0);
				//
				//bitmap.alpha = 0;
				//
				//App.ui.flashGlowing(this, 0xFFF000);
				//
				//TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					//removeChild(backBitmap);
					//backBitmap = null;
				//}});
				//
				//gloweble = false;
			//}
			//
			//draw(levelData.bmp, levelData.dx, levelData.dy);
			//if (level >= totalLevels) 
				//addGround();
			//
			//checkOnAnimationInit();
		//}
		override public function checkOnAnimationInit():void 
		{
			totalLevels = 0;
			for (var _lvl:* in info.tower)
				totalLevels++;
				
			if (textures && textures['animation'] && ((level >= totalLevels - craftLevels) /*|| this.sid == 236*/)) 
			{
				initAnimation();
				beginAnimation();
				startAnimation();
			}
		}
		
		public var rewardCont:Sprite;
		private function wauEffect(e:MouseEvent =  null):void
		{
			if (rewardW.bitmapData != null) 
			{
				rewardCont = new Sprite();
				App.self.windowContainer.addChild(rewardCont);
				
				var glowCont:Sprite = new Sprite();
				glowCont.alpha = 0.6;
				glowCont.scaleX = glowCont.scaleY = 0.5;
				rewardCont.addChild(glowCont);
				
				var glow:Bitmap = new Bitmap(Window.textures.dailyBonusItemGlow);
				glow.scaleX = glow.scaleY = 2.4;
				glow.smoothing = true;
				glow.x = -glow.width / 2;
				glow.y = -glow.height / 2;
				glowCont.addChild(glow);
				
				var bitmap:Bitmap = new Bitmap(new BitmapData(rewardW.width, rewardW.height, true, 0));
				bitmap.bitmapData = rewardW.bitmapData;
				bitmap.smoothing = true;
				bitmap.x = -bitmap.width / 2 - 8;
				bitmap.y = -bitmap.height / 2 + 5;
				rewardCont.addChild(bitmap);
				
				if (e) {
					rewardCont.x = e.target.parent.x + e.target.parent.width / 2;
					rewardCont.y = e.target.parent.y + e.target.parent.height / 2;
				} else {
					rewardCont.x = rewardCont.y = 0;
				}
				
				function rotate():void {
					glowCont.rotation += 1.5;
				}
				
				App.self.setOnEnterFrame(rotate);
				rewardCont.addEventListener(MouseEvent.CLICK, closeEarly);
				//TweenLite.from(rewardCont, 0.5, { x:, y:bttnOpen.mouseY} );
				
				TweenLite.to(rewardCont, 0.5, { x:App.self.stage.stageWidth / 2, y:App.self.stage.stageHeight / 2, scaleX:1.25, scaleY:1.25, ease:Cubic.easeInOut, onComplete:function():void {
					setTimeout(function():void {
						App.self.setOffEnterFrame(rotate);
						glowCont.alpha = 0;
						var bttn:* = App.ui.bottomPanel.bttnMainStock;
						var _p:Object = { x:bttn.x + App.ui.bottomPanel.mainPanel.x, y:bttn.y + App.ui.bottomPanel.mainPanel.y};
						SoundsManager.instance.playSFX('takeResource');
						TweenLite.to(rewardCont, 0.3, { ease:Cubic.easeOut, scaleX:0.7, scaleY:0.7, x:_p.x, y:_p.y, onComplete:function():void {
							TweenLite.to(rewardCont, 0.1, { alpha:0, onComplete:function():void {
								if(rewardCont.parent)
									rewardCont.parent.removeChild(rewardCont);
								rewardCont.removeEventListener(MouseEvent.CLICK, closeEarly);}} );
						}} );
					}, 3000)
				}} );
			}
		}
		public function closeEarly(e:MouseEvent = null):void
		{
			if (rewardCont)
			{	if (rewardCont && rewardCont.parent)
					rewardCont.parent.removeChild(rewardCont);
				rewardCont.removeEventListener(MouseEvent.CLICK, closeEarly);
			}
			//else
				//return;
		}
		/*
		2) decorate - добавление украшеня в гостях
		- params: uID, sID, wID, id, mID - сид материала из info['outs'], x,y - координаты на елке
		- out: bonus
		*/
		
		private var saveToyCallback:Function;
		public function saveToyAction(toy:HappyToy, callback:Function = null):void {
			saveToyCallback = callback;
			
			Post.send( {
				ctr:	type,
				act:	'decorate',
				uID:	App.owner.id,
				guest:	App.user.id,
				wID:	App.owner.worldID,
				id:		id,
				sID:	sid,
				mID:	toy.sID,
				x:		toy.x,
				y:		toy.y
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				toys[nextToyID] = {
					mID:	toy.sID,
					x:		toy.x,
					y:		toy.y,
					uID:	App.user.id
				}
				
				if (saveToyCallback != null) {
					saveToyCallback(toy, Treasures.treasureToObject(data.bonus));
					saveToyCallback = null;
				}
			});
		}
		private function get nextToyID():int {
			var last:int = 0;
			for (var s:* in toys) {
				if (!isNaN(int(s)) && int(s) >= last) {
					last++;
				}
			}
			return last;
		}
		
		
		/*
		clear - удаление украшения со своей елки
		- params: uID, sID, wID, id, mID - сид материала из info['outs'], x,y - координаты на елке
		- out: пусто
		*/
		
		//override public function setFlag(value:*, callBack:Function = null, settings:Object = null):void {		//D
		override public function setFlag(value:*, callBack:Function = null, settings:Object = null):void {
			//super.setFlag(value, callBack, settings);
		}
		
		
		//override protected function onStockAction(error:int, data:Object, params:Object):void {
			//super.onStockAction(error, data, params);
			//for(var fm:* in App.data.storage[sid].tower)
				//{
					//level++;
				//}
			//totalLevels = level;
			//updateLevel();
		//}
		
		private var clearToyCallback:Function;
		public function clearToyAction(toy:HappyToy = null, callback:Function = null, all:Boolean = false):void {
			clearToyCallback = callback;
			
			var values:Object = {
				ctr:	type,
				act:	'clear',
				uID:	App.user.id,
				wID:	App.user.worldID,
				id:		id,
				sID:	sid
			};
			
			if (all) {
				values['all'] = 1;
			}else {
				values['mID'] = toy.sID;
				values['x'] = toy.x;
				values['y'] = toy.y;
			}
			
			Post.send(values, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (all) {
					toys = { };
				}else if( toys.hasOwnProperty(toy.id)) {
					delete toys[toy.id];
				}
				
				if (clearToyCallback != null) {
					clearToyCallback(toy);
					clearToyCallback = null;
				}
			});
		}
		
	}

}