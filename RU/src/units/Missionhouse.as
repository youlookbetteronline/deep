package units 
{
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import wins.InstancePassingWindow;
	import wins.InstanceWindow;
	/**
	 * ...
	 * @author 
	 */
	public class Missionhouse extends Building
	{
		public static var windowOpened:Boolean = false;
		
		public var roomInfo:Object = { };
		
		public var arrHeroesSids:Object = {};
		
		public var focusPositions:Object;
		
		public var timeToEnd:int;
		
		public function checkRoom():uint {
			
			var roomID:uint = info.rooms[0];
			
			for each(var rID:* in info.rooms) 
			{
				var room:Object = App.data.storage[rID];
				if (room.level <= App.user.level){
					if (App.data.storage[roomID].level < room.level) {
						roomID = rID;
					}
				}
			}
			
			if (!App.user.rooms.hasOwnProperty(roomID)) {
				App.user.rooms['roomID'] = { };
			}
			roomInfo = App.data.storage[roomID];
			roomInfo['id'] = roomID;
			return roomID;
			
			
		}
		
		override public function remove(_callback:Function = null):void
		{
			
			var callback:Function = _callback;
			
			
			//	onApplyRemove(callback)
			
		}
		
		public function Missionhouse(object:Object)
		{
			object['level'] = 1;
			super(object);
			removable = true;
			/*remove();
			return*/
			var roomID:uint = checkRoom();
			
			
			roomInfo['id'] = roomID; // ID комнаты
			roomInfo.require;		 // Понадобятся
			roomInfo.outs;			 // Что выпадает
			roomInfo.count;			 // Количество персонажей
			
			
			if (formed) {
				moveable = true;
			}
			if (info.view == 'waterfall')	
				transable = false;
				
			removable = false;
			rotateable = false;
			//moveable = false;
			moveable = true;
			transable = false;
			/// Delete down
			moveable = true;
			rotateable = true;
			removable = true;
			// to here
			if (App.user.mode == User.OWNER) {
				timeToEnd = roomInfo.time - App.data.storage[roomID].term * getNumFriends();
							
				for (var key:* in App.user.rooms) {
					if (roomID == key && App.user.rooms[key].time > 0) {
						crafting = true; 
						startTime = App.user.rooms[key].time;
						//App.self.setOnTimer(work);
						startWork(startTime);
						
						for (var _sid:* in App.user.rooms[key].pers) {
							
						arrHeroesSids[_sid] = (App.user.rooms[key].pers[_sid]);
						App.user.countTechInInst++;
						}
						
					//	addCloud();
						//App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, checkCloud);	
						break;
					}
				}
				
				tip = function():Object 
				{
					if (startTime > 0 && (startTime + timeToEnd) > App.time) {
						return {
							title:info.title,
							text:Locale.__e('' + TimeConverter.timeToStr((startTime + timeToEnd)-App.time)),
							timer:true
						}
					}
					return {
						title:info.title,
						text:info.description
					};
				}
				
				if (sid == 320) {
					if(SoundsManager.complete)
						addAmbience();
					else
						App.self.addEventListener(AppEvent.ON_SOUND_LOAD, addAmbience);
				}
				
				focusPositions = {
					'oracle':{
						x:this.x + 20,
						y:this.y + 50
					},
					'portal':{
						x:this.x + 20,
						y:this.y + 50
					},
					'waterfall':{
						x:this.x + 20,
						y:this.y + 50
					},
					'ice_rock':{
						x:this.x + 20,
						y:this.y + 50
					},
					'tower':{
						x:this.x + 20,
						y:this.y + 50
					},
					'ship':{
						x:this.x - 140,
						y:this.y + 100
					},
					'wrecked_ship':{
						x:this.x - 140,
						y:this.y + 100
					}
				}
				
				Post.send({
					ctr:'missionhouse',
					act:'lookin',
					uID:App.user.id,
					rID:roomInfo.id
				}, function(error:int, data:Object, params:Object):void
				{
					if (error) {
						Errors.show(error, data);
						return;
					}
					//addCloud(arrHeroesSids);
					friendsData = data.friends;
					var count:int = 0;
					for (var fr:* in friendsData) {
						count++;
					}
					
					if (App.user.rooms[roomInfo.id]) {
						App.user.rooms[roomInfo.id]['count'] = count;
					}
					else {
						App.user.rooms[roomInfo.id] = {};
						App.user.rooms[roomInfo.id]['count'] = count;
					}
					
					timeToEnd = roomInfo.time - App.data.storage[roomInfo.id].term * getNumFriends();
					
					//App.ui.upPanel.setTimeToPersIcons(startTime, timeToEnd, sid);
					updatePersIcons();
					
				});
			}
			
			if (App.user.mode == User.GUEST) {
				//showIcon();
			}
		}
		
		
		
		public function getNumFriends():int 
		{
			var numFriends:int = 0;
			
			for (var key:* in friendsData) {
				numFriends++;
			}
			
			if (numFriends > roomInfo.limit) numFriends = roomInfo.limit;
			
			return numFriends;
		}
		
		private function addAmbience(e:AppEvent = null):void {
			App.self.removeEventListener(AppEvent.ON_SOUND_LOAD, addAmbience)
		//	SoundsManager.instance.addDinamicEffect('ambience_2', this);
		}
		
		public var windowOpened:Boolean = false;
		override public function click():Boolean
		{
			//clickable = false;
			if (App.user.mode == User.GUEST) {
				//guestClick();
				
				return true;
			}
			
			if (hasProduct) {
				clickable = false;
				storageEvent();
				return true;
			}
			
			if (focusPositions.hasOwnProperty(info.view)) {
				App.map.focusedOn({x:focusPositions[info.view].x, y:focusPositions[info.view].y}, false, null, true, 1.1, false);
			}else {
				App.map.focusedOn({x:this.x - 55, y:this.y + 100}, false, null, true, 1.1, false);
			}
			
			if (canSendLookin && !windowOpened) {
				clickable = false;
				canSendLookin = false;
				//windowOpened = true;
				checkRoom();
				Post.send({
					ctr:'missionhouse',
					act:'lookin',
					uID:App.user.id,
					rID:roomInfo.id
				}, onLookinEvent);
			}else if (!windowOpened) {
				//windowOpened = true;
				checkRoom();
			
			if (startTime + timeToEnd - App.time > 0)
			{
				clickable = false;
				new InstancePassingWindow( {
				roomInfo:roomInfo,
				target:this,
				friendsData:friendsData,
				onClose:onCloseWindow
				}).show();
			}else {
				clickable = false;
				new InstanceWindow( {
				roomInfo:roomInfo,
				target:this,
				friendsData:friendsData,
				onClose:onCloseWindow
				}).show();
				
			}
				
			  	hideObjects();
			/*	initAnimation();
				startAnimation();
			*/
			}
			
			//windowOpened = true;
			return true;
			
		}
		
		override public function storageEvent():void
		{	
			
			App.user.rooms[roomInfo.id].pers = { };
			App.user.rooms[roomInfo.id].drop = 0;
			App.user.rooms[roomInfo.id].count = 0;
			App.user.rooms[roomInfo.id].time = 0;
			App.user.rooms[roomInfo.id].times = 0;
			
			startTime = 0;
			
			updatePersIcons(false);
			
			for (var i:* in arrHeroesSids)  {
				var position:Object = findHeroPos(i);
				App.user.returnHero(arrHeroesSids[i], position);
			}
			
			
			App.ui.upPanel.updatePersIcons();
			//App.ui.bottomPanel.removeTresure(sid);
			
			haloEffect();
			
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				rID:roomInfo.id
			}, onStorageEvent);			
		}
		
		private function updatePersIcons(isBusy:Boolean = true):void 
		{
			for (var i:* in arrHeroesSids)  {
				App.user.removePersonage(arrHeroesSids[i]);
				
				for (var j:int = 0; j < App.ui.upPanel.personageIcons.length; j++ ) {
					if (arrHeroesSids[i] == App.ui.upPanel.personageIcons[j].sid/* && !App.ui.upPanel.personageIcons[j].isBusy*/) {
						App.ui.upPanel.personageIcons[j].update();
						App.ui.upPanel.personageIcons[j].isBusy = isBusy;
						App.ui.upPanel.personageIcons[j].updateTime(startTime, timeToEnd);
						if (isBusy) {
							App.ui.upPanel.personageIcons[j].startWork();
						}
					}
				}
			}
		}
		
		private function findHeroPos(id:int):Object {
			switch(id){
				case 0:
						return {
							x:coords.x + int(info.area.w/2),
							z:coords.z + info.area.h + 4
						}
					break;
				case 1:
						return {
							x:coords.x + int(info.area.w/2),
							z:coords.z + info.area.h + 4
						}
					break;
				case 2:
						return {
							x:coords.x + int(info.area.w/2),
							z:coords.z + info.area.h + 4
						}
					break;	
				default:
					return {
							x:coords.x + int(info.area.w/2),
							z:coords.z + info.area.h + 4
						}
			}
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			ordered = false;
			crafting = false;
			
			fID = 0;
			crafted = 0;
			
			var bonus:Object = data.bonus;
			var that:* = this;
			var tx:int = that.x;
			var ty:int = that.y;
			
			Treasures.bonus(Treasures.convert(bonus), new Point(tx, ty));
			
			for (var _id:* in arrHeroesSids) {
				for (var i:int = 0; i < App.user.techno.length; i++) 
				{
					if (App.user.techno[i].id == _id) 
					{
					App.user.techno[i].workStatus = WorkerUnit.FREE 
					App.user.techno[i].visible = true;
					}
					
				}
			}
			
			arrHeroesSids = { };
			clickable = true;
		}
		
		
		
		public function takeReward():void
		{
			
		}
		
		public function updateTime(time:int):void
		{
			startTime = time;
			/*if (cloudItems) {
				cloudItems.updateTime(startTime, startTime + timeToEnd);
			}*/
		}
		
		public var startTime:int;
		public function startWork(time:int):void
		{
			crafting = true;
			startTime = time;
			App.self.setOnTimer(work);
			startAnimation();
		}
		
		private function work():void 
		{
			var time:int = startTime + timeToEnd - App.time;
			
			if (time <= 0) {
				stopWork();
			}
		}
		
		private function stopWork():void 
		{
			stopAnimation();
			App.self.setOffTimer(work);
			onProductionComplete();
			
			clickable = true;
		}
		
		
			
		public function onStart(arrHeroSids:Array, callBack:Function):void
		{
			
			arrHeroesSids = App.self.toObject(arrHeroSids);
			
			var arrPers:Array = [];
			var arrPersObj:String = new String();
			for (var pers:* in arrHeroesSids) {
				arrPersObj = '';
				//settings['hasPaginator'] = true;
				arrPersObj = pers+":"+arrHeroesSids[pers];
				arrPers.push(arrPersObj);
			}
	
			Post.send({
				ctr:'missionhouse',
				act:'enter',
				sID:sid,
				wID:App.user.worldID,
				uID:App.user.id,
				rID:roomInfo.id,
				id:id,
				pers:JSON.stringify(arrPers)
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					
					
					return;
				}
				
				App.user.rooms = data.rooms;
				
				startTime = data.rooms[roomInfo.id].time;
				
				//App.ui.upPanel.setTimeToPersIcons(startTime, timeToEnd, sid);
				updatePersIcons();
				
				startWork(startTime);
				callBack(startTime);
				
				//App.user.countTechInInst += arrHeroesSids.length;
				
				App.ui.upPanel.setTimeToPersIcons(startTime, timeToEnd, sid);
			});
		}
		
		public var friendsData:Object = { };
		private var intervalLookin:int;
		private var canSendLookin:Boolean = true;
		private function onLookinEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			friendsData = data.friends;
			var count:int = 0;
			for (var fr:* in friendsData) {
				count++;
			}
			
			if (App.user.rooms[roomInfo.id]) {
				App.user.rooms[roomInfo.id]['count'] = count;
			}
			else {
				App.user.rooms[roomInfo.id] = {};
				App.user.rooms[roomInfo.id]['count'] = count;
			}
			clearInterval(intervalLookin);
			intervalLookin = setInterval(function():void { canSendLookin = true; }, 300000);
			if (startTime + timeToEnd - App.time > 0)
			{
				new InstancePassingWindow( {
				roomInfo:roomInfo,
				target:this,
				friendsData:friendsData,
				onClose:onCloseWindow
				}).show();
			}else {
				new InstanceWindow( {
				roomInfo:roomInfo,
				target:this,
				friendsData:friendsData,
				onClose:onCloseWindow
				}).show();
			}
			
			
			hideObjects();
			/*initAnimation();
			startAnimation();*/
			
			//addCloud(arrHeroesSids);
			timeToEnd = roomInfo.time - App.data.storage[roomInfo.id].term * getNumFriends();
			
			updatePersIcons();
			//App.ui.upPanel.setTimeToPersIcons(startTime, timeToEnd, sid);
			clickable = true;
		}
		
		public function onCloseWindow(isWork:Boolean):void {
			/*stopAnimation();
			clearAnimation();*/
			//setTimeout(showObjects, 300);
			showObjects();
			/*if(!isWork)
				returnHeroes();*/
		}
		
		private var objects:Array = [];
		public function hideObjects(radius:int = 15):void
		{
			var places:Array = [];
			
			var targetX:int = coords.x;
			var targetZ:int = coords.z;
			
			var startX:int = targetX - radius;
			var startZ:int = targetZ - radius;
			
			if (startX <= 0) startX = 1;
			if (startZ <= 0) startZ = 1;
			
			var finishX:int = targetX + radius + info.area.w;
			var finishZ:int = targetZ + radius + info.area.h;
			
			if (finishX >= Map.cells) finishX = Map.cells - 1;
			if (finishZ >= Map.rows) finishZ = Map.rows - 1;
			
			for (var pX:int = startX; pX < finishX; pX++)
			{
				for (var pZ:int = startZ; pZ < finishZ; pZ++)
				{
					if ((coords.x <= pX && pX <= targetX + info.area.w) &&
					(coords.z <= pZ && pZ <= targetZ + info.area.h)){
						continue;
					}
					
				//	if (App.map._aStarNodes[pX][pZ].object) {
					//	var object:* = App.map._aStarNodes[pX][pZ].object;
					//	object.alpha = 0.5;
					//	object.touchable = false;
					//	object.clickable = false;
					//	objects.push(object);
				//	}
				}
			}
		}
		
		public function showObjects():void {
			for (var i:int = 0; i < objects.length; i++) {
				objects[i].alpha = 1;
				objects[i].touchable = true;
				objects[i].clickable = true;
			}
			objects = [];
		}
		
		override public function checkProduction():void {
			completed = [];
			crafting = false;
			
			if (startTime > 0 && startTime <= App.time) {
				initAnimation();
			}
		}
		
		override public function set touch(touch:Boolean):void
		{
			if (App.user.mode == User.GUEST)
				return;
				
			super.touch = touch;
		}
		
		override public function load(hasReset:Boolean = false):void {
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
		}
		
		override public function checkOnAnimationInit():void {
			initAnimation();
			if(crafting)
				startAnimation();
		}
		
		override public function onRemoveFromStage(e:Event):void {
			clearInterval(intervalLookin);
			App.self.removeEventListener(AppEvent.ON_SOUND_LOAD, addAmbience)
			super.onRemoveFromStage(e);
		}
		
	}
}