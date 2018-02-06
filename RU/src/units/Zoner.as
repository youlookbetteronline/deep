package units 
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Post;
	import core.TimeConverter;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.UnitIcon;
	import ui.UserInterface;
	import wins.OpenZoneWindow;
	import wins.SpeedWindow;
	import wins.Window;
	
	public class Zoner extends Personage 
	{
		
		public static const DEF:String = 'default';
		public static const PREPARE:String = 'prepare';
		public static const HOME_ZONE:int = 113;
		public static const INGRID:int = 2083;
		public static const DEER:int = 1581;
		public static const PROFESSOR:int = 815;
		
		public var walkable:Boolean = false;
		public var sID:uint;
		public var gloweble:Boolean = true;
		
		public var upgrade:int		= 0;
		public var finished:int		= 0;
		public var lock:Boolean;
		
		public var totalLevels:int	= 0;
		public var zoneID:int		= 0;
		public var zoneAsset:*;
		private var relocateTimeout:int = 0;
		private var zonerType:String;
		
		public function Zoner(object:Object, view:String='') 
		{
			level = 0;
			sid = object.sid;
			
			if (object['level']) 
			level = object.level;
			if (object.sid == 280) {
				zonerType = 'bridge';
				object.z -= 1;
				object['layer'] = Map.LAYER_FIELD;
			}
			
			if (info) {
				for each(var rew:* in info.devel.rew) {
					for (var _sid:* in rew) {
						if (App.data.storage[_sid].type == 'Zones')
							zoneID = int(_sid);
					}
				}
			}
			
			if (object.sid == 430) zoneID = HOME_ZONE;
			
			if (info.devel) {
				for each(var obj:* in info.devel.req) {
					totalLevels++;
				}
			}
			
			super(object, view);
			
		
			if (object['upgrade']) 
			upgrade = object.upgrade;
			if (object['crafted']) 
			finished = object.crafted;
			
		//	if (Config.admin)
				moveable = true;
			
			clickable = true;
			touchable = true;
			removable = false;
			sID = object.sid;
			
			if (sid == 815) 
			{
				stockable = true;
			} else 
			{
				stockable = false;
			}		
			
			if (zonerType != 'bridge')
				takeable = false;
			
			velocity = 0.04;
			
			tip = function():Object {
				
				var time:int;
				if (App.user.mode == User.GUEST || sid == 280) {
					return {
						title:	info.title,
						text:	info.description
					}
				}
			
				if (upgrade > App.time) {
					time = upgrade - App.time;
					if (time < 0) time = 0;
					
					return {
						title:	info.title,
						text:	Locale.__e('flash:1402905682294') + ':' + TimeConverter.timeToStr(time),
						timer:	true
					}
				}else if (upgrade > 0 && upgrade <= App.time && level == totalLevels) {
					
					if (sid == Zoner.DEER) 
					{
						return {
							title:	info.title,
							text:   Locale.__e('flash:1403170965448')						
						}
					} else {
						return {
							title:	info.title,
							text:   Locale.__e('flash:1434983742800')+' \n'+ Locale.__e('flash:1403170965448')						
						}
					}					
					
				}else if (finished > 0 && finished > App.time && level == totalLevels) {
					time = finished - App.time;
					if (time < 0) time = 0;
					
					if (sid == Zoner.DEER) 
					{
						return {
							title:	info.title,
							text:   Locale.__e('flash:1382952379839', [TimeConverter.timeToStr(time)]),
							timer:	true
						}
					} else {
						return {
							title:	info.title,
							text:    Locale.__e('flash:1434983742800')+' \n'+ Locale.__e('flash:1382952379839', [TimeConverter.timeToStr(time)]),
							timer:	true
						}
					}					
					
				}else if (finished > 0 && finished <= App.time) {
					
					if (sid == Zoner.DEER) 
					{
						return {
							title:	info.title,
							text:   Locale.__e('flash:1393579618588')					
						}
					} else {
						return {
							title:	info.title,
							text:     Locale.__e('flash:1434983742800')+' \n'+ Locale.__e('flash:1393579618588')
						}
					}					
				}
				
				if (sid == Zoner.DEER) 
				{
					return {
						title:	info.title,
						text:   ""						
					}
				} else {
					return {
						title:	info.title,
						text:	info.description
					}
				}			
			}
			
			if (textures)
			{
				if (textures.hasOwnProperty('animation')) {
					if (textures.animation.animations.hasOwnProperty('walk')) {
						walkable = true;
					}
					
					getRestAnimations();
					addAnimation();
					initAnimation();
				}
			}
			updateLevel();
			showIcon();
			//drawPreview();
		}
		
		
		override public function stockAction(params:Object = null):void
		{
			
			
			if (!App.user.stock.check(sid))
			{
				//TODO показываем окно с ообщением, что на складе уже нет ничего
				return;
			}
			
			App.user.stock.take(sid, 1);
			
			if (sid == 815) 
			{
				Post.send({ctr: this.type, act: 'stock', uID: App.user.id, wID: App.user.worldID, sID: this.sid, x: coords.x, z: coords.z, level:totalLevels}, onStockAction);
			}else 
			{
				Post.send({ctr: this.type, act: 'stock', uID: App.user.id, wID: App.user.worldID, sID: this.sid, x: coords.x, z: coords.z, level:0}, onStockAction);
			}
			
		}
		
		override  protected function onStockAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			//App.map._astar.reload();
			//App.map._astarReserve.reload();
			this.id = data.id;
			if (!(multiple && App.user.stock.check(sid)))
			{
				App.map.moved = null;
			}
			App.ui.glowing(this);
			finished = App.time + info.time;
		}
		
		override public function createShadow():void 
		{				
			if (shadow) {
				removeChild(shadow);
				shadow = null;
			}
			
			if (textures && textures.animation.hasOwnProperty('shadow')) {
				shadow = new Bitmap(UserInterface.textures.shadow);
				addChildAt(shadow, 0);
				shadow.smoothing = true;
				shadow.x = textures.animation.shadow.x - (shadow.width / 2);
				shadow.y = textures.animation.shadow.y - (shadow.height / 2);
				shadow.alpha = textures.animation.shadow.alpha;
				shadow.scaleX = textures.animation.shadow.scaleX;
				shadow.scaleY = textures.animation.shadow.scaleY;
			}			
		}
		
		override public function onLoad(data:*):void {
			textures = data;
			
			if (textures.hasOwnProperty('animation')) {
				if (textures.animation.animations.hasOwnProperty('walk')) {
					walkable = true;
				}
				
				getRestAnimations();
				addAnimation();
				initAnimation();
			}
			
			updateLevel();
			showIcon();
			
			if (level >= totalLevels) 
			{
				createShadow();
			}
			
			
			if (preloader) {
				TweenLite.to(preloader, 0.5, { alpha:0, onComplete:removePreloader } );
			}
		}
		
		override public function set touch(touch:Boolean):void
		{
			super.touch = touch;
		if (App.user.mode == User.GUEST||level < totalLevels)
				return;
			
			stopWalking();
			onGoHomeComplete();
			
			
		}
		
		public var timers:uint = 0;
		
		/*public function stopRest():void {
			framesType = Personage.STOP;
			if (timers > 0)
				clearTimeout(timers);
		}*/
		
		public function initAnimation():void {
			if (!textures.hasOwnProperty('animation')) return;
			
			if (level < totalLevels) {
				if (textures.animation.animations.hasOwnProperty('level' + level)) {
					framesType = 'level' + level;
				}else {
					framesType = STOP;
				}
			}else {
				walkable = true;
				startRest();
			}
		}
		
		override public function click():Boolean {
		//	if (!open /*&& !allParentZonesOpened*/) return false;
			
			if (App.user.mode == User.GUEST) {
				return true;
			}
			
			if (onPrepare()) return true;
			
			if (lock) return false;
			
			if (onBonus()) return true;
			
			if (isUpgrade()) return true;
			
			if (onRewardCrafted()) return true;
			
			if (onRewardComplete()) return true;
			
			return false;
		}
		
		private function get allParentZonesOpened():Boolean {
			var info:Object = App.data.storage[zoneID];
			if (info.hasOwnProperty('require')) {
				for (var zone:* in info.require) {
					if (App.data.storage[zone].type == 'Zones' && App.user.world.zones.indexOf(int(zone)) < 0)
						return false;
				}
			}
			
			return true;
		}
		
		public function updateLevel(checkRotate:Boolean = false):void 
		{
			if (level >= totalLevels && info.time == 0) {
				clickable = false;
				touchable = false;
			}
			
			if (textures == null) return;
			
			var levelData:Object = textures.sprites[this.level];
			
			if (levelData == null) {
				if (level > 0) {
					var lowLevel:int = level;
					while (lowLevel > 0) {
						if (textures.sprites[lowLevel]) {
							levelData = textures.sprites[lowLevel];
							break;
						}
						lowLevel--;
					}
				}
			}
			
			if (levelData == null) {
				if (textures.sprites[0]) {
					levelData = textures.sprites[0];
				}else {
					return;
				}
			}
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			if (this.level != 0 && gloweble) {
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				bitmap.alpha = 0;
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (zonerType == 'bridge') {
				if (level == totalLevels) {
					tip = null;
					touchable = false;
					gloweble = false;
					clickable = false;
					free();
				}
			}
		}
		
		
		// Storage 
		public function storageEvent():void {
			var params:Object = {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}
			
			if (App.user.mode == User.OWNER) {
				lock = true
				if (finished > 0 && finished <= App.time)
					Post.send(params, onStorageEvent);
			}else {
				if (App.user.friends.takeGuestEnergy(App.owner.id)) {
					params['act'] = 'gueststorage';
					params['guest'] = App.user.id;
					params['uID'] = App.owner.id;
					
					Post.send(params, onStorageEvent, {guest:true});
				}
			}
		}
		public function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				if(params && params.hasOwnProperty('guest')){
					App.user.friends.addGuestEnergy(App.owner.id);
				}
				return;
			}
			
			lock = false;
			
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			
			if (params != null) {
				if (params['guest'] != undefined) {
					App.user.friends.giveGuestBonus(App.owner.id);
				}
			}
			
			if (data.hasOwnProperty('started')) finished = data.started;
			
			showIcon();
		}
		
		// Upgrade
		private var upgradeWindow:Window;
		protected function isUpgrade():Boolean {
			if (level < totalLevels) {
				upgradeWindow = new OpenZoneWindow( {
					zoneID:		zoneID,
					require:	info.devel.obj[level + 1],
					title:		info.title,
					description:info.description,//(info.hasOwnProperty('devel') && info.devel.hasOwnProperty('info')) ? info.devel.info[level + 1] : '',
					onUpgrade:	onUpgradeZoneGuide,
					onBoost:	onBoost,
					skipPrice:	info.devel.skip[level + 1],
					level:		level + 1,
					totalLevels:totalLevels,
					sID: sid
				});
				upgradeWindow.show();
				return true;
			}
			
			return false;
		}
		private function onUpgradeZoneGuide():void {
			if (!App.user.stock.takeAll(info.devel.obj[level + 1])) return;
			
			Post.send( {
				ctr:this.type,
				act:'upgrade',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onUpgradeEvent);
		}
		private function onUpgradeEvent(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			upgrade = App.time - 1;
			if (upgradeWindow) {
				upgradeWindow.close();
			}
			onBonus();
			
			//if (data.hasOwnProperty('upgrade')) {
				//upgrade = data.upgrade;
				//if (upgradeWindow) {
					//upgradeWindow.close();
				//}
				//
				//if ((level + 1) == totalLevels) {
					//finished = App.time + info.time;
				//}
				//
			//}
			
			//showIcon();
		}
		
		
		// Boost
		protected function onPrepare():Boolean {
			if (upgrade > 0 && upgrade > App.time && level == totalLevels) {
				new SpeedWindow( {
					title:			info.title,
					target:			this,
					totalTime:		info.devel.req[level + 1].t,
					finishTime:		upgrade,
					doBoost:		onBoost,
					priceSpeed:		info.devel.skip[level + 1]
					
				}).show();
				return true;
			}
			
			return false;
		}
		protected function onRewardCrafted():Boolean {
			if (info.time > 0 && finished > 0 && finished > App.time) {
				new SpeedWindow( {
					title:			info.title,
					target:			this,
					totalTime:		info.time,
					finishTime:		finished,
					doBoost:		onBoost,
					priceSpeed:		info.skip,
					zoneID:         zoneID,
					width:          600,
					height:         320,
					moveTo:			moveTo
					
				}).show();
				return true;
			}
			
			return false;
		}
		private var movingProf:Boolean = false;
		private function moveTo():void 
		{
		/*var unit:Unit = Unit.add( {gift:false, sid:sid, buy:true, wID:1, x:25, z:40 } );
		unit.buyAction({wID:1});
		Unit.sorting(unit);	*/
		
		stockable = true;
		putAction();
		stockable = false;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			if (!(multiple && App.user.stock.check(sid)))
			{
				App.map.moved = null;
			}
			//App.ui.upPanel.update(["coins"]);
			
			this.id = data.id;
			
		}
		
		protected function onRewardComplete():Boolean {
			if (info.time > 0 && finished > 0 && finished <= App.time) {
				storageEvent();
				return true;
			}
			return false;
		}
		
		// Bonus
		public function onBonus():Boolean {
			//click() = false;
			if (upgrade > 0 && upgrade <= App.time) {
				Post.send({
					ctr:this.type,
					act:'reward',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onBonusEvent);
				
				if(level == totalLevels)
					WallPost.makePost(WallPost.NEW_ZONE, { sid:zoneID } );
				
				return true;
			}
			
			return false;
		}
		private function onBonusEvent(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			upgrade = 0;
			level++;
			
			if (level >= totalLevels)
				finished = App.time + info.time;
			
			showIcon();
			updateLevel();
			initAnimation();
			openZone(info.devel.rew[level]);
			
			var reward:Object = { };
			for (var s:* in info.devel.rew[level]) {
				if (App.data.storage[s].type == 'Zones') continue;
				reward[s] = info.devel.rew[level][s];
			}
			Treasures.bonus(Treasures.convert(reward), new Point(this.x, this.y));
		}
		
		
		
		
		
		private function onBoost(price:Object = null):void {
			var action:String = 'boost';
			if (!price) {
				if (level < totalLevels) {
					price = { };
					price[Stock.FANT] = info.devel.skip[level + 1];
					action = 'speedup';
				}else if (level >= totalLevels && finished > App.time) {
					price = { };
					price[Stock.FANT] = info.skip;
					action = 'boost';
				}
			}
			
			if (price && App.user.stock.take(Stock.FANT, uint(price))) {
				Post.send( {
					ctr:	type,
					act:	action,
					sID:	sid,
					id:		id,
					uID:	App.user.id,
					wID:	App.user.worldID
				}, function(error:int, data:Object, params:Object):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (data.hasOwnProperty('crafted')) finished = data.crafted;
					if (data.hasOwnProperty('reward')) 
						Treasures.bonus(data.reward, new Point(this.x, this.y));
					
					if (action == 'speedup') {
						onUpgradeEvent(error, { upgrade:App.time - info.devel.req[level + 1].t }, null);
					}
					
					showIcon();
				} );
			}
		}
		
		
		private function openZone(reward:Object = null):void {
			if (reward && zoneID > 0 && App.data.storage[zoneID].type == 'Zones') {
				if (!App.user.world.hasOwnProperty('zones')) App.user.world.zones = [];
				App.user.world.zones.push(zoneID);
				
				for (var s:* in reward) {
					if (int(s) == zoneID)
						App.user.world.changeNodes(zoneID);
				}
				
				//Делаем push в _6e
				if (App.social == 'FB') {
					ExternalApi.og('investigate','area');
				}
			}
		}
		
		
		// Timer
		private function timer():void {
			relocate();
		}
		
		
		// Relocate
		private function relocate():void {
 			if (!formed || !walkable) return;
			if (_framesType == WALK) return;
			
			goOnRandomPlace(onGoOnRandomPlace);
		}
		private function startRelocate(timeout:int = 5000, random:int = 2000):void {
			if (relocateTimeout > 0) stopRelocate();
			relocateTimeout = setTimeout(relocate, timeout + Math.random() * random);
		}
		private function stopRelocate():void {
			clearTimeout(relocateTimeout);
			relocateTimeout = 0;
		}
		
		
		// Zoner rest
		private function startRest():void {
			if (walkable) {
				
				// Определить привязан ли объект к зоне
				var find:Boolean = false;
				for (var asses:* in App.map.assetZones) {
					if (zoneID > 0 && App.map.assetZones[asses] == zoneID) {
						find = true;
						zoneAsset = asses;
					}
				}
				find = true;
				if (find)
					setRest();
			}
		}
		
		
		public function goOnRandomPlace(callback:Function):void 
		{
			var place:Object = getRandomPlace();
			if (place) {
				framesType = WALK;
				initMove(
					place.x,
					place.z,
					callback
				);
			}
		}
		public function getRandomPlace():Object 
		{
			var i:int = 100;
			while (i > 0) {
				i--;
				var place:Object = nextPlace();
				if ((zoneID)?App.map._aStarNodes[place.x][place.z].z != zoneID:0 || App.map._aStarNodes[place.x][place.z].isWall) 
					continue;
				
				break;
			}
			
			if (i <= 0) return null;
			
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
		public function onGoOnRandomPlace():void {
			setRest();
		}		
		
		override public function onLoop():void {
			if (_framesType.indexOf('rest') >= 0) {
				goOnRandomPlace(onGoOnRandomPlace);
			}
		}
		
		
		private function showIcon():void {
			if (!formed) return;
			
			if (App.user.mode == User.OWNER) {
				if (upgrade > 0 && upgrade <= App.time && level == totalLevels) {
					if (info.sID == INGRID) 
					{
						drawIcon(UnitIcon.REWARD, 26, 1, {
							glow: true,
							iconDX: -40,
							iconDY: 0
						});
					} else 
					{
						drawIcon(UnitIcon.REWARD, 26, 1, {
							glow:		true
						});
					}					
					
				}else if (level >= totalLevels && info.time > 0 && finished > 0 && finished <= App.time) {
					
					if (info.sID == INGRID) 
					{
						drawIcon(UnitIcon.REWARD, 26, 1, {
							glow: true,
							iconDX: -40,
							iconDY: 0
						});
					} else 
					{
						drawIcon(UnitIcon.REWARD, 26, 1, {
							glow:		true
						});
					}						
				}else {
					clearIcon();
				}
			}
		}
		
		
		override public function calcState(node:AStarNodeVO):int {
			return EMPTY;
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case OCCUPIED: this.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; break;
				case EMPTY: this.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; break;
				case TOCHED: this.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; break;
				case HIGHLIGHTED: this.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; break;
				case IDENTIFIED: this.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; break;
				case DEFAULT: this.filters = []; break;
			}
			_state = state;
		}
		
		override public function uninstall():void {
			stopRelocate();
			super.uninstall();
		}
		
		override public function take():void {
			if (!takeable) return;
			
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					node.isWall = (level >= totalLevels) ? false : true;
					node.b = 1;
					node.object = this;
					
					part = App.map._aStarParts[coords.x + i][coords.z + j];
					part.isWall = (level >= totalLevels) ? false : true;
					part.b = 1;
					part.object = this;
				}
			}
		}
		
		override public function free():void {
			if (!takeable) return;
			
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					node.isWall = false;
					node.b = (zonerType == 'bridge') ? 1 : 0;
					node.object = (zonerType == 'bridge') ? this : null;
					
					part = App.map._aStarParts[coords.x + i][coords.z + j];
					part.isWall = false;
					part.b = (zonerType == 'bridge') ? 1 : 0;
					part.object = (zonerType == 'bridge') ? this : null;
				}
			}
		}
	}

}