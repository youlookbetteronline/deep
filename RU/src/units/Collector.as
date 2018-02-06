package units
{
	import core.Post;
	import flash.geom.Point;
	import wins.ConstructWindow;
	
	public class Collector extends Building
	{
		public static const FREE:uint 		= 0;
		public static const BUSY:uint 		= 1;
		public static const DAMAGED:uint 	= 2;
		
		public var old:int = 0;
		public var started:uint = 0;
		public var finished:uint = 0;
		public var cID:uint = 0;
		public var mID:uint = 0;
		public var time:uint;		
		public var targets:Vector.<Moneyhouse> = new Vector.<Moneyhouse>;
		public var furrys:Vector.<Techno> = new Vector.<Techno>;
		
		private var data:Object;
		
		public function Collector(object:Object)
		{
			super(object);
			data = object;
			
			touchableInGuest = true;
			
			App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
		}
		
		private function onMapComplete(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);	
			init(data);
		}
		
		public function init(object:Object):void 
		{			
			
			if (object.hasOwnProperty('mID'))
			{
				mID = object.mID;
				cID = object.cID;
				
				if (cID > 0)
					time = info.times[0];
				if (mID > 0)
					time = info.times[1];
			}
			
			if (App.user.mode == User.OWNER)
			{
				initWork(object);
			}
			
			App.ui.glowing(this);
			App.ui.flashGlowing(this);
			
			tip = function():Object {					
				if (hasProduct)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379897")
					};
				}
				
				return {
					title:info.title,
					text:info.description
				};
			}	
		}
		
		private function initWork(object:Object):void 
		{
			for (var key:* in object.worker) 
			{				
				if (key == Techno.TECHNO) 
					continue;
				
				var data:Object = object.worker[key];
				
				if (data.finished == 0)
					continue;
				
				for (var targetSid:* in data.target)
					break;
				
				if (data.hasOwnProperty('reward')) 
				{
					for (var bns:* in data.reward) 
					{
						break;
					}
				}
			}
		}
		
		public function addFurry(furry:Techno):void
		{
			if (furrys.indexOf(furry) == -1)
				furrys.push(furry);
		}
		
		public function furryFinished(id:int):void
		{
			for (var i:int = 0; i < furrys.length; i++) 
			{
				if (id == furrys[i].id)
				{
					furrys[i] = null;
					furrys.splice(i, 1);
					break;
				}
			}
		}
		
		public function storageCollector(furryId:int):void
		{
			Post.send({
				ctr:'collector',
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:sid,
				id:id,
				worker:furryId
			}, onStorageCollectorEvent, {id:furryId});	
		}
		
		private function onStorageCollectorEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			var furry:Techno = getFurry(params.id);
			
			if (data.hasOwnProperty("bonus")){
				Treasures.bonus(Treasures.convert(data.bonus), new Point(furry.x, furry.y));
			}
			
			var fur:Techno = getFurry(params.id);
			
			if(fur.finished <= App.time)
				furryFinished(params.id);
		}
		
		private function getFurry(id:int):Techno
		{
			var fur:Techno;
			for (var i:int = 0; i < furrys.length; i++) 
			{
				if (id == furrys[i].id) {
					fur = furrys[i];
					break;
				}
			}
			return fur;
		}
		
		public function doSync(furryId:int, callback:Function = null):void 
		{
			Post.send({
				ctr:'collector',
				act:'sync',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:sid,
				id:id,
				worker:furryId
			}, onSyncEvent, {callback:callback});		
		}		
		
		private function onSyncEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (params != null && params.hasOwnProperty('callback') && params.callback != null)
				params.callback(data.reward);			
		}
		
		override public function openConstructWindow(openWindowAfterUpgrade:Boolean = true):Boolean 
		{
			if (level <= totalLevels - craftLevels || level == 0)
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						new ConstructWindow( {
							title:			info.title,
							upgTime:		info.devel.req[level + 1].t,
							request:		info.devel.obj[level + 1],
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true
						}).show();
						
						return true;
					}
				}
			}
			return false;
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			if (App.user.mode == User.GUEST)
			{
				App.ui.flashGlowing(this);
			}
			textures = data;
		}
		
		override public function click():Boolean
		{			
			if (App.user.mode == User.GUEST && touchableInGuest == true)
			{
				guestClick();
				return false;
			}
			if (!clickable || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			
			App.tips.hide();
			
			if (!isReadyToWork()) return true;
			
			if (isPresent()) return true;
			
			if (openConstructWindow()) return true;
			
			if (hasProduct)
			{
				App.user.hero.addTarget( {
					target		:this,
					callback	:storageEvent,
					event		:Personage.HARVEST,
					jobPosition	:findJobPosition()
				});
				
				ordered = true;
			}
			return true;
		}
		
		private function searchEvent(mode:uint, sID:uint):void
		{
			started = App.time;
			
			var that:* = this;
			var postObject:Object = {
				ctr:this.type,
				act:'order',
				uID:App.user.id,
				wID:App.user.worldID,
				id:this.id,
				sID:this.sid
			};
			
			Post.send(postObject, function(error:*, data:*, params:*):void {
				if (error) 
				{
					Errors.show(error, data);
					return;
				}
				
				started = data.started;
				App.ui.flashGlowing(this);
				App.self.setOnTimer(work);
				crafting = true;
			});	
		}
		
		override public function storageEvent():void
		{
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fID:fID
			}, onStorageEvent);
		}
		
		override public function onBoostEvent(count:int = 0):void {
			
			if (App.user.stock.take(Stock.FANT, info.skip)) {
				
				started -= time;
				
				var that:* = this;
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (error) 
					{
						Errors.show(error, data);
						return;
					}
					started = data.started;
					App.ui.flashGlowing(that);
				});	
			}
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void 
		{			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			ordered 	= false;
			hasProduct 	= false;
			crafting 	= false;
			started 	= 0;
			
			mID = 0;
			cID = 0;
			
			if (data.hasOwnProperty('bonus'))
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
		}
		
		public function startWork():void
		{
			App.self.setOnTimer(work);
		}
		
		public function work():void
		{
			if (App.time > finished)
			{
				App.self.setOffTimer(work);
			}
		}
		
		public override function onProductionComplete():void
		{			
		}
		
		public override function set crafting(value:Boolean):void
		{
		}
		
		public override function get crafting():Boolean
		{
			return _crafting;
		}
		
		public override function findJobPosition():Object
		{
			var Y:int = -1;
			if (coords.z + Y < 0)
				Y = 0;
			
			return {
				x:int(info.area.w/2),
				y: Y,
				direction:0,
				flip:0
			}		
		}
		
		override public function uninstall():void
		{
			super.uninstall();
		}
		
		override public function checkOnAnimationInit():void
		{
			if (level > totalLevels - craftLevels)
			{
				initAnimation();
				beginAnimation();
			}
		}
		
		override public function setCraftLevels():void
		{
			craftLevels = 1;
		}
		
		override public function beginAnimation():void
		{			
			startAnimation(true);
			
			if (crafting == false) 
				multipleAnime['anim'].bitmap.visible = true;
			else
				multipleAnime['anim'].bitmap.visible = false;
		}
	}
}