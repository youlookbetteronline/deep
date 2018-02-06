package units
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Load;
	import core.MD5;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import effects.explosion.ParticleManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.EventsManager;
	import ui.Hints;
	import ui.SystemPanel;
	import ui.UserInterface;
	import utils.Sector;
	import utils.SocketActions;
	import utils.SocketEventsHandler;
	import wins.JamWindow;
	import wins.NeedResWindow;
	import wins.PurchaseWindow;
	import wins.RewardWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.WindowButtons;
	import wins.Window;
	import wins.WindowEvent;
	
	public class Resource extends Unit
	{
		public static var debris:Array = [474, 475, 476];
		
		public var _hero:Hero;
		public var _bitmap:Bitmap;
		public var _bitmap2:Bitmap;
		public var capacity:uint;
		public var sector:Sector;
		public var reserved:int = 0;
		public var visited:uint = 0;
		public var countLabel:TextField;
		public var title:TextField;
		public var iconB:Bitmap;
		public var popupBalance:Sprite;
		public var glowed:Boolean = false;
		public var canceled:Boolean = false;
		public var damage:int = 0;
		public var framesType:String = "work";
		public var framesTypes:Array = [];
		public var multipleAnime:Object = { };
		public var ax:int = 0;
		public var ay:int = 0;
		
		public var chestes:Array = [1072, 1073];
		public var cickOwner:String = '';
		public var isTarget:Boolean = false;
		public var backBubble:Bitmap = new Bitmap();
		private var tempBmap:Bitmap;
		private var scew:Number = .15;
		private var cnter:int = 0;
		private var back:Boolean = false;
		private var firstDraw: Boolean;
		private var containerY:int = 20;private var timeID:*;
		private var anim:TweenLite;
		private var glowInterval:int;
		
		override public function set touch(touch:Boolean):void{
			if ((!moveable && Cursor.type == 'move') || (!removable && Cursor.type == 'remove') || (!rotateable && Cursor.type == 'rotate')){
				return;
			}
			super.touch = touch;
			if (touch){
				if (Cursor.type == 'default'){
					timeID = setTimeout(function():void{
						balance = true;
						if (!popupBalance) 
							return;
						popupBalance.alpha = 0;
						resizePopupBalance();
						anim = TweenLite.to(popupBalance, 0.2, {alpha: 1});
					}, 400);
					App.map.lastTouched.push(this);
				}
			}
			else{
				clearTimeout(timeID);
				if (anim){
					anim.complete(true);
					anim.kill();
					anim = null;
				}
				balance = false;
			}
		}
		public function set balance(toogle:Boolean):void
		{
			if (move)
				return;
			
			if (toogle)
			{
				if(touchable)
					createPopupBalance();
				if (!canceled&&popupBalance){
					if (!App.map.mTreasure.contains(popupBalance))
						App.map.mTreasure.addChild(popupBalance);
					if (reserved == 0)
						countLabel.text = String(capacity);
					else
						countLabel.text = reserved + '/' + capacity;
					countLabel.x = backBubble.x + (backBubble.width - countLabel.width) / 2;
				}
				else{
					redrawCount();
					canceled = false;
				}
			}
			else{
				if (popupBalance != null && App.map.mTreasure.contains(popupBalance))
					App.map.mTreasure.removeChild(popupBalance);
			}
		}
		override public function get bmp():Bitmap{
			return bitmap;
		}
		override public function get visible():Boolean{
			return super.visible;
		}
		override public function get info():Object{
			return super.info;
		}
		override public function set info(value:Object):void{
			super.info = value;
		}
		private function get resDesc():Array{
			var queue:Array = [];
			for (var _out:* in info.outs){
				queue.push(_out);
			}
			return queue;
		}
		override public function get glowingColor():*{
			_hero = Hero.getNeededHero(sid, info);
			if (_hero != null ||(App.user.mode == User.GUEST))
				return _glowingColor;
			else
				return 0xFF9900;
		}
		override public function set ordered(ordered:Boolean):void{
			_ordered = ordered;
			if (ordered)
				bitmap.alpha = .5;
			else
				bitmap.alpha = 1;
		}
		public function getWorkType(sid:int = -1):String{
			return Personage.WORK;
		}
		
		public function Resource(object:Object)
		{
			layer = Map.LAYER_SORT;
			super(object);
			App.data.storage
			if (info.outs)
			{
				for (var _sid:*in info.outs)
				{
					info['out'] = _sid;
					break;
				}
			}
			else
			{
				info['out'] = Stock.COINS;
			}
			
			if (object.hasOwnProperty('capacity'))
			{
				capacity = object.capacity;
				if (capacity <= 0 && App.user.mode == User.OWNER)
				{
					info['ask'] = false;
					remove();
					return;
				}
			}
			else
			{
				capacity = info.capacity;
			}
			
			moveable = false;
			multiple = true;
			rotateable = false;
			removable = false;
			
			if (Config.admin) 
			{
				moveable = true;
				rotateable = true;
				removable = true;
			}
			
			if (!formed)
				moveable = true;
				
				if (!Hero.isInTargets(sid))
				{	
					if (App.user.mode == User.GUEST)
					{
						touchable = false;
					}
				}
			tip = function():Object
			{
				_bitmap = new Bitmap();	
				_bitmap2 = new Bitmap();
				var materialSid:uint = 0;
				var count1:String = '0';	
				var count2:String = '0';	
				
				if (_hero != null || info.kick != null)
				{
					if (App.user.mode == User.OWNER || App.user.mode == User.PUBLIC)
					{
						var countter:int = 0;
						for (var sID:* in info.require)
						{
							if (App.data.storage.hasOwnProperty(sID) && App.data.storage[sID].mtype != 3) {
								Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview),
								function(data:Bitmap):void
								{
									if (_bitmap2)
									{
										_bitmap2.bitmapData = data.bitmapData;
										Size.size(_bitmap2, 40, 40);
									}
								});
							}
							Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), 
							function(data:Bitmap):void
							{
								if (_bitmap)
								{
									_bitmap.bitmapData = data.bitmapData;
									Size.size(_bitmap, 40, 40);
								}									
							});
							countter++;
						}
						
						if (info.kick != null){
							sID = Numbers.firstProp(info.kick).key;
							if (App.data.storage.hasOwnProperty(sID) && App.data.storage[sID].mtype != 3) {
								Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview),
								function(data:Bitmap):void
								{
									if (_bitmap)
									{
										_bitmap.bitmapData = data.bitmapData;
										Size.size(_bitmap, 40, 40);
									}
								});
							}
							count1 = Numbers.firstProp(info.kick).val;
							materialSid = Numbers.firstProp(info.kick).key;
							_bitmap2 = null;
						}else{
							if (countter == 1){
								_bitmap2 = null;
								count1 = Numbers.getProp(info.require, 0).val;
								materialSid = Numbers.getProp(info.require, 0).key;
							}else{
								count1 = Numbers.getProp(info.require, 0).val;
								count2 = Numbers.getProp(info.require, 1).val;
								materialSid =Numbers.getProp(info.require, 1).key;
							}
						}
					}
					
					if (App.user.mode == User.GUEST)
					{
						var iScale:Number;
						_bitmap = new Bitmap(UserInterface.textures.guestAction)
						iScale = 0.7;
						materialSid = Numbers.getProp(info.require, 0).key;
					}
				}
				
				if (App.data.storage[sid].ftreasure) 
				{
					var tresureDesc:String = '';
					for each (var tres:* in App.data.treasures[App.data.storage[sid].ftreasure])
					{
						for each( var itemDesc:* in tres.item)
						{
							if (App.data.storage[itemDesc].mtype !=3)
								tresureDesc +=App.data.storage[itemDesc].title + ' '
						}
					}
					if (tresureDesc !='') 
					{
						tresureDesc = Locale.__e('flash:1430985750052') + '\n' + tresureDesc;
					}
					if (!App.isSocial('VK','DM','OK','FS','MM')) 
					{
						tresureDesc = '';
					}
				}
				var desc:String = Locale.__e('flash:1409654204888');
				
				if (Config.admin) 
				{
					desc = ("sid = " + this.sid + ", id = " + this.id);
				}
				
				if (materialSid == 0)
					return{title:''};
				
				if (App.data.storage[materialSid].mtype != 3)
				{
					count1 = count1 +' / ' + String(App.user.stock.count(sID));
				}
				
				return {
					title		:info.title,
					gives		:resDesc,
					desc		:desc,
					count1		:count1,
					count2		:count2,
					icon		:_bitmap,
					icon2		:_bitmap2,
					addDesc		:tresureDesc
				};
			};			
			
			if(App.user.mode == User.GUEST){
				var hash:String = MD5.encrypt(Config.getSwf(type, info.view));
				if ((Load.cache[hash] != undefined && Load.cache[hash].status == 3) || !open) {
					Load.loading(Config.getSwf(type, info.view), onLoad);
				}else{
					if(SystemPanel.noload)
						clearBmaps = true;
					Load.loading(Config.getSwf(type, info.view), onLoad);
					//onLoad(UnitsHelper.cTexture);
					//onLoad(UnitsHelper.bTexture);
				}
			}else
				Load.loading(Config.getSwf(type, info.view), onLoad);
			App.self.addEventListener(AppEvent.ON_WHEEL_MOVE, onWheel);
			
			if (App.user.id=='5325659') 
			{
				moveable = true;
				multiple = true;
				rotateable = true;
				removable = true;	
				touchable = true;
			}
			
			if (App.user.id =='5325659'|| App.user.id =='12276904'|| App.user.id =='5151331'|| App.user.id =='44715129' || App.user.id =='6823974'|| App.user.id =='1234567'|| App.user.id =='68239741'|| App.user.id =='codename' || (App.user.stock.data.hasOwnProperty(Stock.LIGHT_RESOURCE)&&App.user.stock.data[Stock.LIGHT_RESOURCE]>App.time)||/*App.user.id =='44715129'||*/App.user.id =='74377189'/*||App.user.id =='282708972'*/) 
			{
				for (var resId:* in App.map.zoneResources) {
					if (id == resId) 
					{					
						this.showPointing();
						this.showGlowing();
					}
				}	
			}			
		}
		
		
		private function addAnimation():void
		{
			ax = textures.animation.ax;
			ay = textures.animation.ay- 20;
			
			clearAnimation();
			
			var arrSorted:Array = [];
			for each(var nm:String in framesTypes) 
			{
				arrSorted.push(nm); 
			}
			arrSorted.sort();
			
			for (var i:int = 0; i < arrSorted.length; i++ ) {
				var name:String = arrSorted[i];
				multipleAnime[name] = { bitmap:new Bitmap(), cadr: -1 };
				bitmapContainer.addChild(multipleAnime[name].bitmap);
				
				if (textures.animation.animations[name]['unvisible'] != undefined && textures.animation.animations[name]['unvisible'] == true) {
					multipleAnime[name].bitmap.visible = false;
				}
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name]['frame'] = 0;
				multipleAnime[name]['bid'] = i;
			}
			
			firstDraw = false;
		}
		
		public function stopAnimation():void
		{
			App.self.setOffEnterFrame(animate);
			animated = false;
		}
		
		public function clearAnimation():void {
			stopAnimation();
			if (!SystemPanel.animate) return;
			for (var _name:String in multipleAnime) {
				var btm:Bitmap = multipleAnime[_name].bitmap;
				if (btm && btm.parent)
					btm.parent.removeChild(btm);
			}
		}
		
		private function startAnimation(random:Boolean = false):void
		{
			
			if (animated) return;
				
			for each(var name:String in framesTypes) 
			{
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name].bitmap.visible = true;
				multipleAnime[name]['frame'] = 0;
				if (random) {
					multipleAnime[name]['frame'] = int(Math.random() * multipleAnime[name].length);
				}
			}
			
			App.self.setOnEnterFrame(animate);
			animated = true;
		}
		
		override public function animate(e:Event = null):void
		{
			if (!SystemPanel.animate && firstDraw) return;
			
			firstDraw = true;
			for each(var name:String in framesTypes) {
				var frame:* 			= multipleAnime[name].frame;
				if (!textures || !textures.animation || !textures.animation.animations)
					continue
				var cadr:uint 			= textures.animation.animations[name].chain[frame];
				if (multipleAnime[name].cadr != cadr) {
					multipleAnime[name].cadr = cadr;
					var frameObject:Object 	= textures.animation.animations[name].frames[cadr];
					
					multipleAnime[name].bitmap.bitmapData = frameObject.bmd;
					//multipleAnime[name].bitmap.smoothing = true;
					multipleAnime[name].bitmap.x = frameObject.ox + ax;
					multipleAnime[name].bitmap.y = frameObject.oy + ay;
					//animeTouch = multipleAnime[name].bitmap;
				}
				multipleAnime[name].frame++;
				if (multipleAnime[name].frame >= multipleAnime[name].length)
				{
					multipleAnime[name].frame = 0;
				}
			}
		}
		
		private function onWheel(e:AppEvent):void
		{
			if (popupBalance)
			{
				resizePopupBalance();
			}
		}
		
		public function initAnimation():void 
		{
			framesTypes = [];
			
			var frameType:String = new String(); if (textures && textures.hasOwnProperty('animation')) {
				
				for (frameType in textures.animation.animations) {
					framesTypes.push(frameType);
				}
				addAnimation();
				startAnimation(true);
			}
		}
		
		public function onLoad(data:*):void 
		{
			if (App.user.mode == User.OWNER && App.user.worldID == User.LAND_2 && this.sid == 259 && this.id == 147)
			{
				onApplyRemove();
			}
			
			textures = data;
			var levelData:Object = textures.sprites[0];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			framesType = info.view;
			if (textures && textures.hasOwnProperty('animation')) 
				initAnimation();
			
			if (!open && formed) {
				applyFilter();
			}
			bitmapContainer.cacheAsBitmap = true;
			
			if(clearBmaps){
				Load.clearCache(Config.getSwf(type, info.view));
				data = null;
			}
		}
		
		override public function moveAction():void
		{
			if (Cursor.prevType == "rotate")
				Cursor.type = Cursor.prevType;
			if (this.fake && this.fake == true)
			{
				trace ("you are FAKE!");
				onMoveAction(0,{},{});
			}else{
				Post.send( { 
					ctr: this.type, 
					act: 'move', 
					uID: App.user.id, 
					wID: App.user.worldID, 
					sID: this.sid, 
					id: id, 
					x: coords.x, 
					z: coords.z, 
					rotate: int(rotate) 
				}, onMoveAction);
			}
		}
		
		override public function draw(bitmapData:BitmapData, dx:int, dy:int):void
		{
			bitmap.bitmapData = bitmapData;
			bitmap.scaleX = 0.999;
			
			this.dx = dx;
			this.dy = dy;
			bitmap.x = dx;
			bitmap.y = dy - containerY;
			bitmapContainer.y = containerY;
			
			if (rotate)
			{
				scaleX = -scaleX;
			}
		}
		
		
		public function redrawCount():void
		{
			if (!touchable){
				balance = false;
				return;
			}
			createPopupBalance();
			reserved = 0;
			moveable = true;
			move = false;
			ordered = false;
			if (!App.map.mTreasure.contains(popupBalance))
			{
				App.map.mTreasure.addChild(popupBalance);
			}
			countLabel.text = String(capacity);
			countLabel.x = backBubble.x + (backBubble.width ) / 2;
		}
		
		
		
		private function onOutLoad(data:*):void
		{
			iconB.bitmapData = data.bitmapData;
			iconB.smoothing = true;
			Size.size(iconB, 50, 50);
			iconB.filters = [new GlowFilter(0xa8e4ed, 1, 4, 4, 8, 1)];
		}
		
		private function createPopupBalance():void
		{
			if (popupBalance != null)
				return;
				
			popupBalance = new Sprite();
			popupBalance.cacheAsBitmap = true;
			
			backBubble = new Bitmap(Window.textures.bubble);
			popupBalance.addChild(backBubble);
			backBubble.x = 0;
			backBubble.y = 0;
			backBubble.smoothing = true;
			if (!iconB)
			{
				iconB = new Bitmap(new BitmapData(50, 50, true, 0x0));
				var _outSid:int = Numbers.getProp(info.outs, Numbers.countProps(info.outs) -1).key;
				Load.loading(Config.getIcon(App.data.storage[_outSid].type, App.data.storage[_outSid].view), onOutLoad);
			}
			iconB.x = backBubble.x + (backBubble.width - iconB.width) / 2;
			iconB.y = backBubble.y + (backBubble.height - iconB.height) / 2;
			popupBalance.addChild(iconB);
			
			var textSettings:Object = {fontSize: 18, autoSize: "center", color: 0xFFFFFF, borderColor: 0x0a4069, borderSize: 4, distShadow: 0}
			title = Window.drawText(info.title, textSettings);
			title.x = backBubble.x + (backBubble.width - title.width) / 2;
			title.y = backBubble.height + 2;
			
			popupBalance.addChild(title);
			
			countLabel = Window.drawText("", textSettings);
			countLabel.x = backBubble.x + (backBubble.width - countLabel.width) / 2;
			countLabel.y = backBubble.y + backBubble.height - countLabel.height *5;
			
			popupBalance.addChild(countLabel);
			popupBalance.x = bitmap.x + (bitmap.width - backBubble.width) / 2 + x;
			popupBalance.y = bitmap.y - backBubble.height/2;
		}
		
		private function resizePopupBalance():void
		{
			var scale:Number = 1;
			switch (SystemPanel.scaleMode)
			{
				case 0: 
					scale = 1;
					break;
				case 1: 
					scale = 1.3;
					break;
				case 2: 
					scale = 1.6;
					break;
				case 3: 
					scale = 2.1;
					break;
			}
			
			var scaleX:Number = scale;
			var scaleY:Number = scale;
			
			//if(rotate) scaleX = -scaleX;
			
			popupBalance.scaleY = scaleY;
			popupBalance.scaleX = scaleX;
			
			popupBalance.x = bitmap.x + (bitmap.width - backBubble.width * scaleX) / 2 + x;
			popupBalance.y = /*bitmap.height + */bitmap.y + y - backBubble.height * 1.6 * scaleY + 20;
		}
		
		
		
		override public function getContactPosition():Object
		{
			var result:Object = new Object();
			var node:AStarNodeVO;
			var point:Object;
			var deffX:int;
			var deffZ:int;
			for (var i:int = info.area.w - 1; i >= 0; i--)
			{
				point = {x:coords.x + i, z:coords.z - 1};
				if (App.map.inGrid(point))
				{
					node = App.map._aStarNodes[point.x][point.z];
					if (node.b != 1)
					{
						deffX = Math.abs(point.x - App.user.hero.coords.x);
						deffZ = Math.abs(point.z - App.user.hero.coords.z);
						
						if (result.hasOwnProperty('deffX'))
						{
							if ((deffX + deffZ)  < result['deffX'])
							{
								result = {
									x:point.x,
									y:point.z,
									direction:0,
									deffX:deffX + deffZ,
									flip:0
								};
							}
						}else{
							result = {
								x:point.x,
								y:point.z,
								direction:0, 
								deffX:deffX + deffZ,
								flip:0
							};
						}
					}
				}
			}
			
			for (var j:int = info.area.h-1; j >= 0; j--)
			{
				point = {x:coords.x - 1, z:coords.z + j};
				if (App.map.inGrid(point))
				{
					node = App.map._aStarNodes[point.x][point.z];
					if (node.b != 1)
					{
						deffX = Math.abs(point.x - App.user.hero.coords.x);
						deffZ = Math.abs(point.z - App.user.hero.coords.z);
						
						if (result.hasOwnProperty('deffX'))
						{
							if ((deffX + deffZ) < result['deffX'])
							{
								result = {
									x:point.x,
									y:point.z,
									direction:0,
									deffX:deffX + deffZ,
									flip:1
								};
							}
						}else{
							result = {
								x:point.x,
								y:point.z,
								direction:0, 
								deffX:deffX + deffZ,
								flip:1
							};
						}
						//trace('x: ' + point.x +' z:' + point.z +  ' are open');
						//return {x: -1, y: j, direction: 0, flip: 1}
					}
				}
			}
			
			if (result.hasOwnProperty('deffX'))
			{
				result['x'] = result['x'] - coords.x;
				result['y'] = result['y'] - coords.z;
				
				return result;
			}
			
			var y:int = -1;
			if (this.coords.z + y < 0)
				y = 0;
			
			return {x: int(info.area.w), y: y, direction: 0, flip: 0}
		}
		
		public function getTechnoPosition(order:int = 1):Object
		{
			var z:int = -1;
			if (this.coords.z + z < 0)
				z = 0;
			
			return {x: coords.x + info.area.w, z: coords.z + z, direction: 0, flip: 0, workType: getWorkType(this.sid)}
		}
		
		
		
		private function onAfterClose(e:WindowEvent):void
		{
			e.currentTarget.removeEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
			Cursor.type = Cursor.prevType;
		}
		private function canTake():Boolean
		{
			if (info.level > App.user.level)
			{
				new SimpleWindow({title: Locale.__e('flash:1396606807965', [info.level]), text: Locale.__e('flash:1396606823071'), label: SimpleWindow.ERROR}).show();
				
				return false;
			}
			return true;
		}
		
		override public function click():Boolean
		{
			if (App.user.mode == User.PUBLIC && !SocketActions.checkUserResource(this))
				return false;
			if (SocketActions.lockAction)
			{
				SocketActions.lockStartMap();
				return false;
			}
			for (var check:* in info.kick)
				break;
				
			if (!App.self.fakeMode && App.user.useSectors)
			{
				var nodes:Array = [];
				var openedFromSector:Boolean = false;
				if (this.info.area.w > 6 && this.info.area.h > 6)
				{
					nodes.push(App.map._aStarNodes[this.coords.x][this.coords.z + int(info.area.h / 2)]);
					nodes.push(App.map._aStarNodes[this.coords.x + int(info.area.w / 2)][this.coords.z]);
					nodes.push(App.map._aStarNodes[this.coords.x + info.area.w-1][this.coords.z + int(info.area.h / 2)]);
					nodes.push(App.map._aStarNodes[this.coords.x + int(info.area.w / 2)][this.coords.z + info.area.h - 1]);
				}
				else{
					nodes.push(App.map._aStarNodes[this.coords.x][this.coords.z]);
				}
				for each(var _node:* in nodes)
				{
					if (_node.sector.open == true)
					{
						openedFromSector = true;
						break;
					}
				}
				
				if (!openedFromSector)
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1495607052980') + " " + info.title,
						confirm:function():void
						{
							for each(var _node:* in nodes)
							{
								_node.sector.fireNeiborsReses();
							}
						}
					}).show();
					return false;
				}
			}
			
			if (check && (_hero == null) && (check != App.data.storage[App.user.worldID].cookie[0]))
			{
				return false;
			}
			
			if (User.inExpedition && _hero == null)
			{
				if (!canHeroKick()) {
					new NeedResWindow( {
						title:Locale.__e('flash:1435225350048'),
						text:Locale.__e('flash:1435226475773'),
						height:185,
						button1:true,
						button2:true
					}).show();
					
					return false;
					
				} else {
					new NeedResWindow( {
						title:Locale.__e("flash:1435241453649"),
						text:Locale.__e('flash:1435241719042'),
						text2:Locale.__e('flash:1435244772073'),
						height:230,
						neededItems: info.require,
						button3:true
					}).show()
					
					return false;
				}
			}
			
			if ( _hero == null && check != App.data.storage[App.user.worldID].cookie[0]) 
			{
				if (!canHeroKick()) 
				{
					return false;
				} else {
					new NeedResWindow( {
						title:Locale.__e("flash:1435241453649"),
						text:Locale.__e('flash:1435241719042'),
						text2:Locale.__e('flash:1435244772073'),
						height:230,
						neededItems: info.require,
						button3:true
					}).show()
					
					return false;
				}
			}
			
			if(info.require){
				var counter:int = 0;
				var checked: int = 0;
				var checkNeed:int = Numbers.countProps(info.require);
				var reqObj:Object = {};
				
				for each(var num:* in info.require)
				{
					var key:int = Numbers.getProp(info.require, counter).key;
					var val:int = Numbers.getProp(info.require, counter).val;
					if (App.user.stock.check(key, val))
					{
						checked++;
					}else{
						reqObj[key] = val;
					}
					counter++;
					if (counter == checkNeed)
					{
						if (checked != checkNeed)
						{
							if(App.data.storage[key].mtype != 3)
							new NeedResWindow({
								title:Locale.__e("flash:1435241453649"),
								text:Locale.__e('flash:1435241719042'),
								height:230,
								neededItems: reqObj,
								button3:true,
								button2:true
							}).show()
							return false;
						}
					}
					
				}
			}
			
			if (!super.click())
				return false;
			
			if (!canTake() || !App.user.stock.canTake(info.outs))
				return true;
				
			
			if (reserved >= capacity)
			{
				return true;
			}
			
			if (reserved == 0)
			{
				ordered = true;
			}
			
			if (App.user.addTarget({target: this, near: true, callback: onTakeResourceEvent, event: Personage.WORK, jobPosition: getContactPosition(), shortcutCheck: true, onStart: function(_target:* = null):void
			{ordered = false;}}))
			{
				if (App.user.mode == User.PUBLIC)
				{
					SocketActions.checkResource(this);
				}
				reserved++;
				balance = true;
			} else {
				ordered = false;
			}
			
			return true;
		}
		
		private function canHeroKick():Boolean 
		{
			for (var i:* in Hero.allTargets) {
				for (var j:int = 0; j < Hero.allTargets[i].length; j++) 
				{
					if (Hero.allTargets[i][j] == sid) {
						return true;
					}
				}	
			}
			return false;
		}
		
		public function takeResource(count:uint = 1):void
		{
			if (capacity - count >= 0)
				capacity -= count;
			
			if (capacity == 0) 
			{
				if (App.user.mode == User.OWNER && !User.inExpedition && App.user.worldID != User.AQUA_HERO_LOCATION && App.user.worldID != User.TRAVEL_LOCATION && App.user.worldID != User.HUNT_MAP)
				{
					if (info.capacity >= 20 || chestes.indexOf(sid) != -1)
					{
						var box:Unit;
						if (chestes.indexOf(sid) != -1)
						{
							box = Unit.add( {sid:info.out, x:coords.x, z:coords.z } );
						}else
						{
							var randIndx:int;
							if (info.capacity >= 30)
								randIndx = 0
							else
								randIndx = 1;
							box = Unit.add( {sid:chestes[randIndx], x:coords.x, z:coords.z } );
						}
						box.buyAction();
						box.take();
					}
				}
				
				balance = false;
				cickOwner = App.user.id;
				dispose();
				App.user.world.removeResource(this);
			}
		}
		
		public function onTakeResourceEvent():void
		{
			//stopSwing();
			if (App.user.mode == User.OWNER) 
			{
				
				if ((targetWorker is Techno)) 
				{
					
					if (App.user.stock.takeAll(info.kick))
					{
						var postObjectT:Object = {ctr: 'techno', act: 'auto', uID: App.user.id, wID: App.user.worldID, sID: targetWorker.sid, id: targetWorker.id, tsID: sid, tID: id}
						
						for (var obj1:* in info.kick)
						{
							Hints.minus(obj1, info.kick[obj1], new Point(targetWorker.x * App.map.scaleX + App.map.x, targetWorker.y - targetWorker.height + 50 * App.map.scaleY + App.map.y), true, null, 10,{personage:targetWorker});
						}
						
						Post.send(postObjectT, onKickEvent);
						
						if (App.social == 'FB')
						{
							ExternalApi._6epush(["_event", {"event": "achievement", "achievement": "clear"}]);
						}
					} else {
						targetWorker['workerFree'].call(null);;
						targetWorker['tm']['dispose'].call(null);;
						targetWorker = null;
						reserved = 0;
						
						var reqObj:Object = new Object();
						reqObj[App.data.storage[App.user.worldID].cookie[0]] = 1;
						new NeedResWindow( {
							title		:Locale.__e("flash:1435241453649"),
							text		:Locale.__e('flash:1435241719042'),
							height		:230,
							neededItems	: reqObj,
							button3		:true,
							button2		:true
						}).show();
						return;
					}
				} else 
				{
					if (App.user.stock.takeAll(info.require))
					{
						var postObject:Object = {ctr: this.type, act: 'kick', uID: App.user.id, wID: App.user.worldID, sID: this.sid, id: id}
						for (var obj:* in info.require)
						{
							Hints.minus(obj, info.require[obj], new Point(targetWorker.x * App.map.scaleX + App.map.x, targetWorker.y - targetWorker.height + 50 * App.map.scaleY + App.map.y), true, null, 300);
						}
						if (this.fake && this.fake == true)
						{
							trace ("you are FAKE!");
							onKickEvent(0,{},{});
						}else{
							Post.send(postObject, onKickEvent);
						}
						if (App.social == 'FB')
						{
							ExternalApi._6epush(["_event", {"event": "achievement", "achievement": "clear"}]);
						}
					}
					else
					{
						App.user.onStopEvent();
						reserved = 0;
						return;
					}
				}
			}
			
			if (App.user.mode == User.GUEST) 
			{
				if (App.user.friends.takeGuestEnergy(App.owner.id))
				{
					Post.send({ctr: 'user', act: 'guestkick', uID: App.user.id, sID: this.sid, fID: App.owner.id}, onKickEvent, {guest: true});
				}
				else
				{
					Hints.text(Locale.__e('flash:1382952379907'), Hints.TEXT_RED, new Point(App.map.scaleX * (x + width / 2) + App.map.x, y * App.map.scaleY + App.map.y));
					App.user.onStopEvent();
					reserved = 0;
					return;
				}
			}
			
			if (App.user.mode == User.PUBLIC) 
			{
				if (App.user.stock.takeAll(info.require))
				{
					var publicPostObject:Object = {
						ctr: this.type,
						act: 'pguestkick',
						uID: App.owner.id,
						guest: App.user.id,
						wID: App.owner.worldID,
						sID: this.sid,
						id: id
					}
					for (var object:* in info.require)
					{
						Hints.minus(object, info.require[object], new Point(targetWorker.x * App.map.scaleX + App.map.x, targetWorker.y - targetWorker.height + 50 * App.map.scaleY + App.map.y), true, null, 300);
					}
					
					Post.send(publicPostObject, onKickEvent);
					if (App.social == 'FB')
					{
						ExternalApi._6epush(["_event", {"event": "achievement", "achievement": "clear"}]);
					}
				}
				else
				{
					App.user.hero.afterWorkStop();
					Connection.sendMessage({u_event:'resources_free'});
					SocketActions.clearUserResources(App.user.id);
					App.user.onStopEvent();
					reserved = 0;
					return;
				}
			}
			
			reserved--;
			if (reserved < 0)
			{
				reserved = 0;
			}
			takeResource();
		}
		
		
		private function onKickEvent(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				if (params != null && params.hasOwnProperty('guest'))
				{
					App.user.friends.addGuestEnergy(App.owner.id);
				}
				return;
			}
			
			if (App.user.mode == User.PUBLIC)
			{
				var _objParams:Object = {
					iD:this.id, 
					sID:this.sid, 
					capacity:this.capacity
				}
				if (data.hasOwnProperty("bonus"))
				{
					_objParams['bonus'] = data.bonus;
				}
				Connection.sendMessage({
					u_event	:'resource_kick', 
					aka		:App.user.aka, 
					params	:_objParams
				});
				if (reserved < 1)
				{
					Connection.sendMessage({
						u_event	:'resource_free',
						params	:{iD:this.id, sID:this.sid}
					});
					SocketActions.resourceFree(App.user.id, this.id, this.sid);
				}
			}
			
			var that:* = this;
			
			if (touch)
				balance = true;
				
			if (data.hasOwnProperty("outs"))
			{
				Treasures.bonus(data.outs, new Point(that.x, that.y));
			}
			if (data.hasOwnProperty("bonus"))
			{
				Treasures.bonus(data.bonus, new Point(that.x, that.y));
			}
			
			if (data.hasOwnProperty('guestBonus')) 
			{
				if (App.self.getLength( data.guestBonus) == 0) 
				{
					return;
				}
				var bonus:Object = {};
				for (var sID:* in data.guestBonus) 
				{
					var item:Object = data.guestBonus[sID];
					for(var count:* in item)
					bonus[sID] = count * item[count];
				}
				App.user.stock.addAll(bonus);
				
				new RewardWindow( { bonus:bonus } ).show();
			}
			
			if (data.hasOwnProperty('id'))
		    {
				var type:String = 'units.' + App.data.storage[info.emergent].type;
				var classType:Class = getDefinitionByName(type) as Class;
				var unit:Unit = new classType({ id:data.id, sid:info.emergent, x:coords.x, z:coords.z});
				unit.take();
		    }
			
			if (data.hasOwnProperty("energy") && data.energy > 0)
			{
				App.user.friends.updateOne(App.owner.id, "energy", data.energy);
			}
			
			if (App.user.mode == User.GUEST)
				App.user.friends.giveGuestBonus(App.owner.id);
			
			ordered = false;
		}
		
		override public function can():Boolean
		{
			return reserved > 0
		}
		
		public function glowing(_color:uint = 0xFFFF00):void
		{
			glowed = true;
			var that:Resource = this;
			TweenMax.to(this, 0.8, {glowFilter: {color: _color, alpha: 1, strength: 6, blurX: 15, blurY: 15}, onComplete: function():void
			{
				TweenMax.to(that, 0.8, {glowFilter: {color: _color, alpha: 0, strength: 4, blurX: 6, blurY: 6}, onComplete: function():void
				{
					that.filters = [];
					glowed = false;
				}});
			}});
		}
		
		public function dispose():void
		{
			clearTimeout(glowInterval);
			App.self.removeEventListener(AppEvent.ON_WHEEL_MOVE, onWheel);
			uninstall();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			if (!Config.admin)
				moveable = false;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			this.alpha = 1;
			if (returnClickable)
				clickable = true;
			
			this.id = data.id;
			if (!Config.admin)
				moveable = false;
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			if (App.self.fakeMode)
				return EMPTY;
			//if (this.sid == 263)
				//return EMPTY;
			//return EMPTY;
			/*if (info.base != null && info.base == 1)
			{
				for (var i:uint = 0; i < cells; i++)
				{
					for (var j:uint = 0; j < rows; j++)
					{
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						if (node.w != 1 || node.open == false || node.object != null)
						{
							return OCCUPIED;
						}
					}
				}
				return EMPTY;
			}
			else
			{
				return super.calcState(node);
			}*/
			
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (App.data.storage[sid].base == 1) {
						//trace(node.b, node.open, node.object);
						if ((node.b != 0 || node.open == false || node.object != null) && node.w != 1) {
							return OCCUPIED;
						}
						if (node.w != 1 || node.open == false || node.object != null) {
							return OCCUPIED;
						}
					} else {
						if (node.b != 0 || node.open == false || (node.object != null /*&& (node.object is Stall)*/)) {
							return OCCUPIED;
						}
					}
				}
			}
			return EMPTY;
		}
		
		public function showDamage(uID:String = null):void
		{
			//Hints.minus(info.out, damage, new Point(), false, this);
			var bonus:Object = {};
			bonus[info.out] = {"1": damage};
			if (uID && uID != App.user.id){
				if(SocketEventsHandler.personages.hasOwnProperty(uID)){
					Treasures.bonus(bonus, new Point(this.x, this.y), {target:SocketEventsHandler.personages[uID]});
				}
				state = DEFAULT;
			}else{
				Treasures.bonus(bonus, new Point(this.x, this.y));
			}
			
			takeResource(damage);
			
			damage = 0;
			busy = 0;
			clickable = true;
		}
		
		public function clearTextures():void
		{
			if (textures){
				var _bmd:*;
				if (textures.animation && textures.animation.animations)
				{
					for (var _anim1:* in textures.animation.animations)
					{
						for each(var _bmd1:* in textures.animation.animations[_anim1].frames){
							_bmd1.bmd.dispose();
							_bmd1.bmd = null;
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
			for each(var _anime:* in multipleAnime)
			{
				if (_anime.bitmapData)
				{
					_anime.bitmapData.dispose();
					_anime.bitmapData = null;
				}
			}
		}
		
		override public function uninstall():void 
		{
			iconB = null;
			if(clearBmaps){
				clearTextures();
			}
			//clearTextures();
			//var description:XML = describeType(this);
			//System.disposeXML(description);
			/*if(bitmap && bitmap.bitmapData){
				bitmap.bitmapData.dispose();
				bitmap.bitmapData = null;
				bitmap = null;
			}
			bitmapContainer = null;*/
			if (sector)
			{
				var _send:Boolean = false;
				if (cickOwner != '' && cickOwner == App.user.id)
					_send = true;
				sector.resources.splice(sector.resources.indexOf(this), 1);
				sector.openNeibors(_send);
			}
			//App.self.removeEventListener(AppEvent.ON_MAP_REDRAW, checkDrawMode);
			super.uninstall();
		}
		
		public function setCapacity(count:int):void
		{
			capacity = count;
			if (capacity <= 0) 
			{
				dispose();
			}
		}
	
	}
}