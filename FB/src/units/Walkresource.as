package units 
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import models.WalkresourceModel;
	import ui.Cursor;
	import ui.Hints;
	import ui.SystemPanel;
	import ui.UserInterface;
	import utils.SocketActions;
	import wins.NeedResWindow;
	import wins.RewardWindow;
	import wins.SimpleWindow;
	import wins	.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class Walkresource extends Techno 
	{
		private var _model:WalkresourceModel;
		private var _hero:Hero;
		private var _popupBalance:Sprite;
		private var _timeID:uint;
		private var _canceled:Boolean = false;
		private var _anim:TweenLite;
		private var _reserved:int = 0;
		private var _countLabel:TextField;
		private var _title:TextField;
		private var _backBubble:Bitmap = new Bitmap();
		private var _iconB:Bitmap;
		private var _dethTimeout:uint = 3;
		public function Walkresource(object:Object) 
		{
			super(object);
			initModel(object);
			tip = function():Object{
				return parseTips();
			}
			App.self.addEventListener(AppEvent.ON_WHEEL_MOVE, onWheel);
			//moveable = false;
			createShadow();
		}
		
		private function initModel(params:Object):void 
		{
			_model = new WalkresourceModel();
			_model.outsList = outsList;
			_model.capacity = params.capacity || info.capacity;
		}
		
		override public function set touch(touch:Boolean):void{
			
			super.touch = touch;
			if (touch){
				if (Cursor.type == 'default'){
					_timeID = setTimeout(function():void{
						balance = true;
						if (!_popupBalance) 
							return;
						_popupBalance.alpha = 0;
						resizePopupBalance();
						_anim = TweenLite.to(_popupBalance, 0.2, {alpha: 1});
					}, 400);
					App.map.lastTouched.push(this);
				}
			}
			else{
				clearTimeout(_timeID);
				if (_anim){
					_anim.complete(true);
					_anim.kill();
					_anim = null;
				}
				balance = false;
			}
		}
		
		override public function set ordered(ordered:Boolean):void{
			_ordered = ordered;
			if (ordered)
				bitmap.alpha = .5;
			else
				bitmap.alpha = 1;
		}
		
		public function set balance(toogle:Boolean):void
		{
			if (move)
				return;
			
			if (toogle)
			{
				if(touchable)
					createPopupBalance();
				if (!_canceled && _popupBalance){
					if (!App.map.mTreasure.contains(_popupBalance))
						App.map.mTreasure.addChild(_popupBalance);
					if (_reserved == 0)
						_countLabel.text = String(_model.capacity);
					else
						_countLabel.text = _reserved + '/' + _model.capacity;
					_countLabel.x = _backBubble.x + (_backBubble.width - _countLabel.width) / 2;
				}
				else{
					redrawCount();
					_canceled = false;
				}
			}
			else{
				if (_popupBalance != null && App.map.mTreasure.contains(_popupBalance))
					App.map.mTreasure.removeChild(_popupBalance);
			}
		}
		
		private function createPopupBalance():void
		{
			if (_popupBalance != null)
				return;
				
			_popupBalance = new Sprite();
			_popupBalance.cacheAsBitmap = true;
			
			_backBubble = new Bitmap(Window.textures.bubble);
			_popupBalance.addChild(_backBubble);
			_backBubble.x = 0;
			_backBubble.y = 0;
			_backBubble.smoothing = true;
			if (!_iconB)
			{
				_iconB = new Bitmap(new BitmapData(50, 50, true, 0x0));
				var _outSid:int = Numbers.getProp(info.outs, Numbers.countProps(info.outs) -1).key;
				Load.loading(Config.getIcon(App.data.storage[_outSid].type, App.data.storage[_outSid].view), onOutLoad);
			}
			_iconB.x = _backBubble.x + (_backBubble.width - _iconB.width) / 2;
			_iconB.y = _backBubble.y + (_backBubble.height - _iconB.height) / 2;
			_popupBalance.addChild(_iconB);
			
			var textSettings:Object = {fontSize: 18, autoSize: "center", color: 0xFFFFFF, borderColor: 0x0a4069, borderSize: 4, distShadow: 0}
			_title = Window.drawText(App.data.storage[_outSid].title, textSettings);
			_title.x = _backBubble.x + (_backBubble.width - _title.width) / 2;
			_title.y = _backBubble.height + 2;
			
			_popupBalance.addChild(_title);
			
			_countLabel = Window.drawText("", textSettings);
			_countLabel.x = _backBubble.x + (_backBubble.width - _countLabel.width) / 2;
			_countLabel.y = _backBubble.y + _backBubble.height - _countLabel.height *5;
			
			_popupBalance.addChild(_countLabel);
			_popupBalance.x = bitmap.x + (bitmap.width - _backBubble.width) / 2 + x;
			_popupBalance.y = bitmap.y - _backBubble.height/2;
		}
		
		public function redrawCount():void
		{
			if (!touchable){
				balance = false;
				return;
			}
			createPopupBalance();
			_reserved = 0;
			moveable = true;
			move = false;
			ordered = false;
			if (!App.map.mTreasure.contains(_popupBalance))
			{
				App.map.mTreasure.addChild(_popupBalance);
			}
			_countLabel.text = String(_model.capacity);
			_countLabel.x = _backBubble.x + (_backBubble.width ) / 2;
		}
		
		private function onWheel(e:AppEvent):void
		{
			if (_popupBalance)
			{
				resizePopupBalance();
			}
		}
		
		private function onOutLoad(data:*):void
		{
			_iconB.bitmapData = data.bitmapData;
			_iconB.smoothing = true;
			Size.size(_iconB, 50, 50);
			_iconB.filters = [new GlowFilter(0xa8e4ed, 1, 4, 4, 8, 1)];
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
			_popupBalance.scaleY = scaleY;
			_popupBalance.scaleX = scaleX;
			
			_popupBalance.x = bitmap.x + (bitmap.width - _backBubble.width * scaleX) / 2 + x;
			_popupBalance.y = bitmap.y + y - _backBubble.height * 1.6 * scaleY + 20;
		}
		
		private function get outsList():Array
		{
			var _tempArray:Array = []
			for (var _out:* in info.outs){
				_tempArray.push(_out);
			}
			return _tempArray;
		}
		
		private function parseTips():Object 
		{
			var _bitmap:Bitmap;
			var _bitmap2:Bitmap;
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
				
				if (App.user.mode == User.GUEST)
				{
					var iScale:Number;
					_bitmap = new Bitmap(UserInterface.textures.guestAction)
					iScale = 0.7;
					materialSid = Numbers.getProp(info.require, 0).key;
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
				gives		:_model.outsList,
				desc		:desc,
				count1		:count1,
				count2		:count2,
				icon		:_bitmap,
				icon2		:_bitmap2/*,
				addDesc		:tresureDesc*/
			};
		}
		
		override public function get glowingColor():*{
			_hero = Hero.getNeededHero(sid, info);
			if (_hero != null ||(App.user.mode == User.GUEST))
				return _glowingColor;
			else
				return 0xFF9900;
		}
		
		override public function click():Boolean 
		{
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
				
			
			if (_reserved >= _model.capacity)
			{
				return true;
			}
			
			if (_reserved == 0)
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
				stopWalking();
				_reserved++;
				balance = true;
			} else {
				ordered = false;
			}
			
			return true;
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
		
		public function onTakeResourceEvent():void
		{
			//stopSwing();
			if (App.user.mode == User.OWNER) 
			{
				if (App.user.stock.takeAll(info.require))
				{
					var postObject:Object = {ctr: this.type, act: 'kick', uID: App.user.id, wID: App.user.worldID, sID: this.sid, id: id}
					for (var obj:* in info.require)
					{
						Hints.minus(obj, info.require[obj], new Point(targetWorker.x * App.map.scaleX + App.map.x, targetWorker.y - targetWorker.height + 50 * App.map.scaleY + App.map.y), true, null, 300);
					}
					Post.send(postObject, onKickEvent);

					if (App.social == 'FB')
					{
						ExternalApi._6epush(["_event", {"event": "achievement", "achievement": "clear"}]);
					}
				}
				else
				{
					App.user.onStopEvent();
					_reserved = 0;
					return;
				}
				
			}
			
			_reserved--;
			if (_reserved < 0)
			{
				_reserved = 0;
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
		
		private function takeResource(count:uint = 1):void
		{
			if (_model.capacity - count >= 0)
				_model.capacity -= count;
			
			if (_model.capacity == 0) 
			{	
				balance = false;
				walkresourceUninstall();
			}
		}
		
		private function walkresourceUninstall():void 
		{
			stopWalking();
			var distanceToDisappear:int = 5;
			if ( this.velocity <= 0.03 )
				distanceToDisappear = 2;
			var place:Object = findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:coords.x, z:coords.z}}, distanceToDisappear);
			initMove(
				place.x,
				place.z
			);
			_dethTimeout = setTimeout(onDeath, 3000);
			
		}
		
		private function onDeath():void 
		{
			clearTimeout(_dethTimeout);
			TweenLite.to(this, 2, { x:this.x, y:this.y, alpha: 0, onComplete: uninstall});
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
		
		public function get model():WalkresourceModel {return _model;}
		public function set model(value:WalkresourceModel):void {_model = value;}
		
		public function get reserved():int 
		{
			return _reserved;
		}
		
		public function set reserved(value:int):void 
		{
			_reserved = value;
		}
		
	}

}