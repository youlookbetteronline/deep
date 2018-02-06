package units {
	
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import ui.AnimalCloud;
	import ui.CloudsMenu;
	import ui.Cursor;
	import ui.IconsMenu;
	import utils.SocketEventsHandler;
	import wins.Window;
	
	public class Firework extends Decor
	{		
		public var cloudItem:CloudsMenu;
		
		public static var _boom:Boolean = false;
		
		public static const NITRO:uint = 1935;
		public static const FIREWORK5:uint = 2858;
		
		public function get isboom():Boolean{
			return _boom;
		}
		
		public function set isboom(_val:Boolean):void{
			_boom = _val;
		}
		
		public function Firework(object:Object) 
		{
			layer = Map.LAYER_SORT;
			if (App.data.storage[object.sid].dtype == 1)
				layer = Map.LAYER_LAND;
			
			super(object);
			
			touchableInGuest = false;
			multiple = false;
			stockable = true;
			
			Load.loading(Config.getSwf(info.type, 'explode'), onLoadExplode);
		}
		
		public var explodeTextures:Object = null;
		
		private function onLoadExplode(data:*):void
		{
			explodeTextures = data;
		}
		
		private function showIcon(typeItem:String, callBack:Function, mode:int, btmDataName:String = 'instCharBackingGuest', params:Object = null):void 
		{
			if (App.user.mode == User.GUEST) return;
			
			if (!params) params = { };
			
			hideIcon();
			
			cloudItem = new CloudsMenu(callBack, this, sid);
			cloudItem.create(btmDataName);
			cloudItem.show();
			cloudItem.x = 0;
			cloudItem.y = - 100;
		}
		
		private function hideIcon():void
		{
			if (cloudItem)
			{
				cloudItem.dispose();
				cloudItem = null;
			}
		}
		
		override public function set touch(touch:Boolean):void
		{
			if (!touchable) 
				return;
			
			if (!touchable || (App.user.mode == User.GUEST && touchableInGuest == false)) return;
			
			_touch = touch;
			
			if (touch) 
			{
				if (state == DEFAULT)
				{
					state = TOCHED;
				} else if (state == HIGHLIGHTED)
				{
					state = IDENTIFIED;
				}				
			} else {
				if (state == TOCHED)
				{
					state = DEFAULT;
				} else if (state == IDENTIFIED)
				{
					state = HIGHLIGHTED;
				}
			}
			
			if (Cursor.type != 'default') 
			{				
				hideIcon();
				hideTargets();				
			} 
		}
		
		private function hideAllStuff(event:MouseEvent):void
		{
			hideIcon();
			hideTargets();
		}
		
		private var iconMenu:IconsMenu;
		override public function click():Boolean
		{
			if (!super.click() || this.id == 0) return false;
			if (App.user.mode == User.PUBLIC)
			{
				if (ownerID){
					if (ownerID != App.user.id && SocketEventsHandler.personages.hasOwnProperty(ownerID))
						return false;
				}else{
					hideIcon();
					showTargets();
					trace('have no owner')
					return false;
				}
			}
			
			if (_boom == true)
			{
				return true;
			}
			if (cloudItem)
			{
				initBoom();
				return true;
			}	
			
			var icons:Array = [];
			var dY:int = 0;
			
			showIcon('require', initBoom, AnimalCloud.MODE_NEED);
			showTargets();
			
			return true;
		}
		
		private function expects(sid:int):Boolean 
		{			
			return false;
		}
		
		public function limits(resSID:int):Boolean 
		{
			if (App.data.storage[resSID].hasOwnProperty('require') && (/*Numbers.firstProp(App.data.storage[resSID].require).key != Stock.FANTASY*/canBoom.indexOf(Numbers.firstProp(App.data.storage[resSID].require).key) == -1 || Numbers.countProps(App.data.storage[resSID].require) > 1))
				return true;
			if (!App.data.storage[resSID].hasOwnProperty('require'))
				return true;
			/*if (sid == 1935)
			{
				// Взрывать только для 1935
				if ([1984, 1985, 1986].indexOf(resSID) == -1)
					return true;
			}else if (sid == 2858) 
			{
				// Взрывать только для 2858
				if ([2874, 2875, 2876].indexOf(resSID) == -1)
					return true;
			}else {
				// Не взрывать эти ресурсы обычными динамитами
				if ([1984, 1985, 1986, 2874, 2875, 2876].indexOf(resSID) != -1)
					return true;
			}*/
			return false;
		}
		
		private function get canBoom():Array
		{
			var canBoomMaterials:Array = [];
			for (var i:int = 0; i < info.impact.length;  i++)
			{
				canBoomMaterials.push(info.impact[i])
			}
			return canBoomMaterials;
		}
		
		public var damageTargets:Array = [];
		public var targets:Array = [];
		public var tempUnits:Array = []
		private function showTargets(params:Object = null):void
		{
			hideTargets();
			var startX:int = coords.x - info.count;
			var startZ:int = coords.z - info.count;
			var finishX:int = coords.x + info.count;
			var finishZ:int = coords.z + info.count;
			
			if (startX < 0) startX = 0;
			if (startZ < 0) startZ = 0;
			
			if (finishX > Map.cells) finishX = Map.cells;
			if (finishZ > Map.rows) finishZ = Map.rows;
			
			var index:int = App.map.mSort.numChildren;
			var unit:*;
			var _x:int = 0;
			var _z:int = 0;
			var radius:int = 10;
			
			while (index > 0) 
			{
				index--;
				unit = App.map.mSort.getChildAt(index);
				
				if (!(unit is Resource) || !unit.hasOwnProperty('coords') || !unit.open || unit.reserved || limits(unit.sid)) continue;
				
				if (radius > Math.sqrt((unit.coords.x - coords.x) * (unit.coords.x - coords.x) + (unit.coords.z - coords.z) * (unit.coords.z - coords.z))) 
				{
					targets.push(unit);
				}
			}
			
			for (var s:* in targets) 
			{
				if (targets[s].busy == true) 
				{
					targets.splice(int(s), 1);
					continue;
				}
				targets[s].state = HIGHLIGHTED;
			}
			if (App.user.mode == User.PUBLIC)
			{
				if (App.user.hero.fireworkTargets.indexOf(this) == -1)
					App.user.hero.fireworkTargets.push(this);
					
				tempUnits = [];
				for each(var target:* in targets) 
				{
					//var target:Resource = damageTargets[i];
					//if (target.damage == 0) continue;
					var array:Array = [target.sid, target.id];
					target.busy = 1;
					target.clickable = false;
					tempUnits.push(array);
				}
				ownerID = App.user.id;
				
				var _objParams:Object = {
					units	:JSON.stringify(tempUnits),
					sID		:this.sid,
					iD		:this.id
				};
				
				Connection.sendMessage({
					u_event	:'firework_reserve', 
					aka		:App.user.aka, 
					params	:_objParams
				});
			}
		}
		
		private function hideTargets():void 
		{
			for each(var target:Resource in targets) 
			{
				target.state = DEFAULT;
			}
			targets = [];
			tempUnits = [];
			if (App.user.mode == User.PUBLIC){
				if (ownerID){
					if (ownerID == App.user.id && App.user.hero.fireworkTargets.indexOf(this) != -1)
						App.user.hero.fireworkTargets.splice(App.user.hero.fireworkTargets.indexOf(this), 1);
				}
			}
		}
		
		private function generateDamage():void 
		{
			var target:Resource;
			var damageLeft:int = info.capacity;
			var destroyed:Array = [];
			
			while (damageLeft > 0)
			{
				if (damageTargets.length <= destroyed.length) break;
				
				for (var i:int = 0; i < damageTargets.length; i++)
				{
					target = damageTargets[i];
					if (destroyed.indexOf(target) != -1) continue;
					if (target.capacity - target.damage > 0)
					{
						target.damage ++;
						damageLeft --;
						if (damageLeft <= 0) break;
					} else {
						destroyed.push(target);
					}
				}
			}
		}
		
		public function initBoom(params:Object = null):void 
		{
			hideIcon();
			
			_boom = true;
			
			clickable = false;
			touchable = false;
			moveable = false;
			removable = false;
			rotateable = false;
			stockable = false;
			
			damageTargets = [];
			damageTargets = damageTargets.concat(targets);
			
			for each(var target:Resource in targets) 
			{
				target.busy = 1;
				target.clickable = false;
			}
			
			startCountdown();
		}
		
		private function showExplodes():void
		{
			var counter:int = 0;
			var X:int = App.map.x;
			var Y:int = App.map.y;
			
			doExplode();
			var count:int = 0;
			var interval:int = setInterval(doExplode, 300);
			
			function doExplode():void 
			{
				if (counter >= damageTargets.length) 
				{
					clearInterval(interval);
					hideTargets();
					_boom = false;
					return;
				}
				
				var target:Resource = damageTargets[counter];
				
				if (target.damage != 0) 
				{
					setTimeout(target.showDamage, 200);	
				}
				
				var explode:Explode = new Explode(explodeTextures);
				explode.scaleX = explode.scaleY = 0.75;
				explode.filters = [new GlowFilter(0xffFF00, 1, 15, 15, 4, 3)];
				explode.x = target.x;
				explode.y = target.y - 100;
				counter ++;	
			}
		}
		
		private function boom(params:Object = null):void
		{
			generateDamage();
			var _tempunits:Array = [];
			var _units:Array = [];
			
			for (var i:int = 0; i < damageTargets.length; i++) 
			{
				var target:Resource = damageTargets[i];
				if(App.user.mode == User.PUBLIC){
					_tempunits.push([target.sid, target.id, target.damage]);
				}
				if (target.damage == 0) continue;
				var array:Array = [target.sid, target.id, target.damage];
				_units.push(array);
			}
			
			showExplodes();
			
			var that:*= this;
			var _postObject:Object = {
				ctr:this.type,
				act:'boom',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				units:JSON.stringify(_units)
			};
			if (App.user.mode == User.PUBLIC)
			{
				if (!App.owner)
					return;
				_postObject['uID'] = App.owner.id;
			}
			
			Post.send(_postObject, function(error:*, data:*, params:*):void {
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				if (App.user.mode == User.PUBLIC)
				{
					var _objParams:Object = {
						units	:JSON.stringify(_tempunits),
						bonus	:data.bonus,
						sID		:that.sid,
						iD		:that.id
					};
					
					Connection.sendMessage({
						u_event	:'firework_boom', 
						aka		:App.user.aka, 
						params	:_objParams
					});
					
					if (ownerID){
						if (ownerID == App.user.id && App.user.hero.fireworkTargets.indexOf(this) != -1)
							App.user.hero.fireworkTargets.splice(App.user.hero.fireworkTargets.indexOf(this), 1);
					}
				}
				
				App.ui.flashGlowing(that.bitmap);
				TweenLite.to(that, 1, { alpha:0, onComplete:uninstall } );
				Treasures.bonus(data.bonus, new Point(that.x, that.y));
			});	
		}
		
		private var countDown:TextField;
		private var counter:int = 4;
		private var cont:Sprite;
		
		private function startCountdown():void 
		{
			cont = new Sprite();
			countDown = Window.drawText(String(counter), {
				color:0xffdc39,
				borderColor:0x6d4b15,
				textAlign:"center",
				fontSize:30,
				width:30
			});
			
			cont.addChild(countDown);
			countDown.x = -countDown.width / 2;
			countDown.y = -countDown.textHeight - 20;
			
			cont.x = 0;
			cont.y = -20;
			addChild(cont);
			
			doCountDown();
			interval = setInterval(doCountDown, 1000);
		}
		
		private var interval:int = 0;
		
		private function doCountDown():void
		{
			if (counter <= 1) 
			{
				clearInterval(interval);
				removeChild(cont);
				boom();
				return;
			}
			
			cont.scaleX = cont.scaleY = 1;
			TweenLite.to(cont, 1, { scaleX:2, scaleY:2 } );			
			counter--;
			countDown.text = String(counter);
		}
	}
}