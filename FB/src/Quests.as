package
{
	import api.ExternalApi;
	import core.Numbers;
	import core.Post;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import org.flintparticles.twoD.renderers.PixelRenderer;
	import ui.QuestIcon;
	import ui.QuestPanel;
	import ui.SystemPanel;
	import units.Animal;
	import units.Barter;
	import units.Bridge;
	import units.Building;
	import units.Craftfloors;
	import units.Decor;
	import units.Field;
	import units.Lantern;
	import units.Pet;
	import units.Pigeon;
	import units.Plant;
	import units.Port;
	import units.Resource;
	import units.Techno;
	import units.Tribute;
	import units.Twigwam;
	import units.Unit;
	import units.Walkgolden;
	import units.Wigwam;
	import utils.Finder;
	import utils.Sector;
	import wins.ChapterWindow;
	import wins.CharactersWindow;
	import wins.CollectionWindow;
	import wins.DaylicWindow;
	import wins.DialogWindow;
	import wins.FreeGiftsWindow;
	import wins.GoalWindow;
	import wins.Paginator;
	import wins.QuestRewardWindow;
	import wins.QuestWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.TimerMapsWindow;
	import wins.TravelWindow;
	import wins.Window;
	import wins.WindowEvent;
	import wins.WorldsWindow;
	//import units.Hut;
	//import wins.InviteSocialFriends;
	
	public class Quests 
	{	
		public var data:Object = { };
		
		public var opened:Array = []; 

		//public var tutorial:Boolean = false;
		public var needIntro:Boolean = false;
		//private var startTutorial:Boolean = false;
		
		public static var targetSettings:Object;
		
		public static var initQuestRule:Boolean = false;
		public var chapters:Array = [];
		public var exclude:Object = { };
		
		
		public static var questMission:int = 0;
		
		public var _dayliInit:Boolean = false;
		public var dayliPressent:uint;
		public var dayliInitable:Boolean = false;
		public var dayliTimerActive:Boolean = false;
		public var dayliLowestLevel:uint = 900;
		public static var daylicsComplete:Boolean = false;
		public static var daylics:Object = {};
		public static var daylicsList:Array = [];
		public static var currentDID:int = 0;
		public static var currentDMID:int = 0;
		public var mapLoaded:Boolean = false;
		
		public function Quests(quests:Object) 
		{
			
			data = quests;
			
			for (var questID:* in App.data.quests) 
			{
				if (!App.data.quests[questID].hasOwnProperty('ID'))
				delete App.data.quests[questID];
			}
			
			App.self.addEventListener(AppEvent.ON_UI_LOAD, init);
		}
		
		public function init(e:AppEvent):void 
		{
			
			if(App.user.mode == User.GUEST)
				return;
			
			for each(var item:Object in App.data.updates) 
			{
				if (item['quests'] != undefined) 
				{					
					var qID:* = item['quests'];
					var has:Boolean = false;
					
					if (item['social'].hasOwnProperty(App.social))
						has = true;
					
					if (!has)
						exclude[qID] = qID;
				}
			}
			
			// Записываем главы, которые нам встречались
			for (id in data) 
			{
				if (App.data.quests[id] == null) 
				{
					delete data[id];
					continue;
				}
				inNewChapter(App.data.quests[id].chapter)
			}
			
			for (var id:* in App.data.quests) 
			{
				if (exclude[id] != undefined) 
				{
					var parentID:int = App.data.quests[id].parent;
					var updateID:String = App.data.quests[id].update || null;
					//delete App.data.quests[id];
					deletedQuests.push(id);
					deleteAllChildrens(id, parentID, updateID);
					
				}
				openChilds(id);
			}
			
			removeDeletedQuests();
			getOpened();
			pushPersonages();
			// Daylics
			if(App.data.hasOwnProperty('daylics'))
				getDaylics();
		}
		
		public function scoreQuest(qID:int, mID:int, id:int):void 
		{
			var scored:Object = { };
			if (data[qID].finished == 0)
			{
				scored[qID] = { };
				scored[qID][mID] = { };
				scored[qID][mID][id] = 1;
			}
			
			Post.send( {
				ctr:'quest',
				act:'score',
				uID:App.user.id,
				wID:App.user.worldID,
				score:JSON.stringify(scored)
			},function(error:*, data:*, params:*):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}
		
		// Daylics
		public function set dayliInit(value:Boolean):void 
		{
			_dayliInit = value;
			App.ui.leftPanel.dayliState(value);
		}
		
		public function get dayliInit():Boolean 
		{
			return _dayliInit;
		}
		
		public static var questsPerses:Object = new Object();
		public function pushPersonages():void 
		{
			for (var quesst:* in App.data.personages)
			{
				questsPerses[App.data.personages[quesst].preview] = quesst
			}
		}
		
		public function daylicsInitable():void {
			const numMissions:int = 1;
			var numQuests:uint = 0;
			
			if (App.user.daylics.hasOwnProperty('quests') && Numbers.countProps(App.user.daylics.quests) > 0) {
				for each (var value:* in App.user.daylics.quests) {
					numQuests++;
				}
				if (numQuests > 0) {
					dayliPressent = 1;
					dayliInitable = false;
					daylicsInit();
					return;
				}
			}
			dayliPressent = 0;
			
			for each(var daylic:Object in App.data.daylics) {
				if (!daylic.hasOwnProperty('missions')) continue;
				var totalAvailMissions:uint = 0;
				for (var s:String in daylic.missions) {
					if (dayliLowestLevel > daylic.missions[s].levelStart) dayliLowestLevel = daylic.missions[s].levelStart;
					if (App.user.level >= daylic.missions[s].levelStart && App.user.level <= daylic.missions[s].levelFinish) {
						totalAvailMissions++;
					}
				}
				
				if (totalAvailMissions >= numMissions) {
					numQuests++;
				}
			}
			
			if (numQuests >= 3) {
				dayliInitable = true;
			}
		}
		
		public function isFinish(qID:int):Boolean 
		{
			if (qID in data && data[qID]['finished'] > 0)
				return true;
			
			return false;
		}
		
		/*public function subtractEvent(qID:int, mID:int, callback:Function, type:String = 'quest'):Boolean {
			
			if (type == 'quest') 
			{
			if (data[qID] == undefined || data[qID].finished != 0) {
				return false;
			}
				
			}else if (App.user.daylics.quests[qID]== undefined) {
				return false;
			
			}
			
			var mission:Object = App.data[type][qID].missions[mID];
			
			if (App.user.stock.take(mission.target[0], mission.need)) {
				
				Post.send( {
					ctr:'quest',
					act:(type =='quest')?'subtract':'dsubtract',
					uID:App.user.id,
					qID:qID,
					mID:mID
				}, function(error:*, result:*, params:*):void {
					
					if (error) {
						
					}else if (result&&App.self.getLength(result)) {
						data[qID][mID] = mission.need;
						callback(mID);
					}
					
				});
				
				return true;
			}
			
			return false;
		}*/
		
		public function subtractEvent(qID:int, mID:int, callback:Function, type:String = 'quest'):Boolean {
			
			if (data[qID] == undefined || data[qID].finished != 0) 
			{
				return false;
			}
			
			var mission:Object = App.data.quests[qID].missions[mID];
			if (App.user.stock.take(mission.target[0], mission.need)) {
				
				Post.send( {
					ctr:'quest',
					act:'subtract',
					uID:App.user.id,
					qID:qID,
					mID:mID
				}, function(error:*, result:*, params:*):void {
					
					if (error) 
					{
						Errors.show(error, data);
					}
					else if (result) 
					{
						data[qID][mID] = mission.need;
						callback(mID);
					}
				});
				return true;
			}
			return false;
		}
		
		private function clone(object:Object):Object {
			var copier:ByteArray = new ByteArray();
			copier.writeObject(object);
			copier.position = 0;
			return	copier.readObject();
		}
		public function daylicsInit():void {
			
			daylics = {};
			daylicsList = [];
			daylicsComplete = false;
			for (var did:String in App.user.daylics.quests) {
				var info:Object = App.user.daylics.quests[did];
				var daylic:Object = clone(App.data.daylics[did]);
				daylic['progress'] = App.user.daylics.quests[did];
				daylic['finished'] = 0;
				daylic['dID'] = did;
				
				if (!daylics.hasOwnProperty(did)) {
					daylics[did] = daylic;
					daylicsList.push(daylic);
				}
				
				daylicsComplete = true;
				for (var mid:String in daylic.missions) {
					if (daylic.progress is Number) {
						daylic.finished = App.time;
						continue;
					}else {
						if (!info.hasOwnProperty(mid)) { // || App.user.level < daylic.missions[mid].levelStart || App.user.level >= daylic.missions[mid].levelFinish
							delete daylic.missions[mid];
						}else {
							daylicsComplete = false;
						}
					}
					
					if (daylic.missions[mid] && daylic.missions[mid].need > daylic.progress[mid]) {
						if(currentDID == 0)
							currentDID = int(did);
					}
				}
			}
			daylicsList.sortOn('order', Array.NUMERIC);
			if (daylicsList.length > 0) {
				dayliInit = true;
			}
		}
		public function dayliProgress(state:Object):void {
			var finishedQuest:int = 0;
			for (var dID:String in state) {
				var missions:* = state[dID];
				
				if (missions is String && missions == "finished") {
					daylics[dID].finished = App.time;
					finishedQuest = int(dID);
					
					currentDID = 0;
					for (var i:int = 0; i < daylicsList.length; i ++) {
						if (daylicsList[i].finished == 0) {
							currentDID = daylicsList[i].dID;
							currentDMID = 0;
							break;
						}
					}
					
					for(var mid:String in daylics[dID].progress) {
						if (daylics[dID].progress[mid] < App.data.daylics[dID].missions[mid].need) {
							// Зачислить бонус по незачисленным миссиям
							App.user.stock.addAll(daylics[dID].missions[mid].bonus);
						}
					}
				}else{
					for (var mID:String in missions) {
						if (daylics[dID].progress is Number) continue;
						
						daylics[dID].progress[mID] = missions[mID];
						if (daylics[dID].progress[mID] >= App.data.daylics[dID].missions[mID].need) {
							App.ui.leftPanel.startDaylicsGlow();
							// Зачислить бонус
							App.user.stock.addAll(daylics[dID].missions[mID].bonus);
							App.ui.upPanel.update();
						}					
					}
				}				
			}			
			
			if (daylics[dID].finished > 0) {
				daylics[dID].progress = App.time;
				App.user.stock.addAll(daylics[dID].bonus);
			}
			
			// Проверить или не закончились на сегодня дейлики
			daylicsComplete = true
			for (var did:String in daylics) {
				if (daylics[did].finished == 0) daylicsComplete = false;
			}
			
			var window:* = Window.isClass(DaylicWindow);
			if (window) {
				if (daylicsComplete) {
					window.close();
				}else {
					window.infoUpdate();
				}
				
				if (daylics[dID].finished > 0) {
					window.showTake(dID);
				}
			}
			if (finishedQuest > 0)
				new QuestRewardWindow({qID:finishedQuest, type:QuestRewardWindow.DAYLICS, popup:true}).show();
		}
		public function getDaylics(openWindow:Boolean = false):void 
		{
			if (dayliInit) return;
			daylicsInitable();
			if (tutorial || !dayliInitable) return;
			Post.send( {
				ctr:'user',
				act:'refreshdaylics',
				uID:App.user.id
			}, function(error:int, data:Object, params:Object):void {
				App.user.daylics = data.result;
				daylicsInit();
				if (dayliPressent is uint && dayliPressent == 0) {
					dayliPressent = 1;
					App.ui.leftPanel.startDaylicsGlow(true);
					if (App.user.level >= dayliLowestLevel) {
						new SimpleWindow( {
							title:		Locale.__e("flash:1392987414713"),
							text:		Locale.__e("flash:1392987515564"),
							label:		SimpleWindow.DAYLICS
						}).show();
					}else{
						new SimpleWindow( {
							title:		Locale.__e("flash:1392987414713"),
							text:		Locale.__e("flash:1392987515564"),
							label:		SimpleWindow.DAYLICS
						}).show();
					}
				}
				if(dayliInit && openWindow) {
					new DaylicWindow().show();
				}
			});
		}
		private var toAttMove:int = 0;
		public function checkDaylics():void {
			if (App.time > App.nextMidnight) {
				var window:* = Window.isClass(DaylicWindow);
				if (window) window.close();
				getDaylics();
				//App.nextMidnight = App.time + 86400;
			}
			toAttMove--;
			if (toAttMove <= 0) {
				toAttMove = 2 + 4 * Math.random();
				//App.ui.leftPanel.attantionMove();
			}
		}
		
		private function removeDeletedQuests():void {
			for each(var id:* in deletedQuests) {
				if (App.data.quests[id] != null)
					delete App.data.quests[id];
			}
			deletedQuests = [];
		}
		
		private var deletedQuests:Array = [];
		private function deleteAllChildrens(qID:int, parentID:int, updateID:String):void
		{
			if (updateID == null) return;
			
			var quest:Object;
			// Выбираем квесты этого обновления
			for (var id:* in App.data.quests)
			{
				quest = App.data.quests[id];
				if (quest.hasOwnProperty('update') && quest.update == updateID)
				{
					deletedQuests.push(id);
					//delete App.data.quests[id];
				}
			}
			/*
			// Определяем наследников этих квестов
			var childrens:Array = [];
			for (var _id:* in App.data.quests)
			{
				if (data.hasOwnProperty(_id)) // если уже открыт
					continue;
					
				quest = App.data.quests[_id];
				if (deletedQuests.indexOf(quest.parent) != -1) {
					quest.parent = parentID;
					childrens.push(_id);

				}
			}
			
			if(childrens.length > 0)
				openQuest(childrens);*/
		}
		
		public function checkPromo(isLevelUp:Boolean = false):void		
		{			
			App.user.updateActions();
			if (App.ui) {
				setTimeout(function():void {
					//trace('Запуск панели с акциями отменен!');
					return;
					App.ui.salesPanel.createPromoPanel(isLevelUp);
					App.ui.salesPanel.resize();
				}, 10000);
			}
		//	}
			//App.user.updateActions();
		}
		
		public function checkFreebie():void
		{
			
			App.ui.rightPanel.addFreebie();	
			//return;
			//var many:Boolean = false;
			//var fast:Boolean = false;
			
			//if (App.user.freebie.status == 1) {
			//
				//if (InviteSocialFriends.canShow()) {
					//App.ui.rightPanel.addFreebie(true);	
				//}
				//return;
			//}
			
			//if(App.user.freebie == null /*|| App.user.freebie.status == 1 */|| App.ui.rightPanel.freebieBttn != null){
				//fast = false;
			//}else{
				//if(App.user.freebie.ID != 0){
					//var neededQuest:int = App.data.freebie[App.user.freebie.ID].unlock.quest;
					//if (App.user.quests.data.hasOwnProperty(neededQuest) && App.user.quests.data[neededQuest].finished > 0)
					//{
						//fast = true;
					//}
				//}
			//}
			
			//if(fast)
				//App.ui.rightPanel.addFreebie();	
				
			//if (App.social == 'VK' && App.network.leads.length > 0 && App.network.leads[0] > 0) {
				//many = true;
			//}
			//if (App.social == 'FB'){// && ExternalApi.visibleTrialpay) {
				//many = true;
			//}
			//fast = true;
			//many = false
			//if (App.ui && (fast || many)) {
				//App.ui.rightPanel.addFreebie();	
			//}
		}
		
		public function isOpen(qID:int):Boolean
		{
			for each(var quest:Object in opened)
			{
				if (qID == quest.id && App.data.quests[qID].type != 1)
				{
					return true;
				}
			}
			return false;
		}
		
		public function openPromo(pID:String):void {
			Post.send( {
				ctr:'promo',
				act:'open',
				uID:App.user.id,
				pID:pID
			}, function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}
		
		public function get isTutorial():Boolean
		{
			if (tutorial) {
				return true;
			}
			return false;
		}
		
		public function get lock():Boolean 
		{
			return _lock;
		}
		
		public function set lock(value:Boolean):void 
		{
			_lock = value;
		}
		
		static public function get help():Boolean 
		{
			return _help;
		}
		
		static public function set help(value:Boolean):void 
		{
			_help = value;
		}
		
		
		
		public function getOpened():void {
			opened = [];
			currentQID = 0;
			var messages:Array = [];
			
			for (var id:* in App.data.quests) {
				
				if (id == 1009)
					trace(1);
				
				if (data[id] != undefined && data[id].finished == 0) {
					
					if(currentQID == 0){
						currentQID = id;
						/*for each(var miss:* in App.data.quests[id].missions) {
							if (!data[id][miss.ID]) {// == undefined
								currentMID = miss.ID;
								break;
							}
						}*/
					}
						
					if (App.data.quests[id].tutorial) //включить туториал
						tutorial = true;
					
					var questObject:Object = App.data.quests[id];
					
					if (questObject.hasOwnProperty('update') && questObject['update'] != "") 
					{
						var updateID:String = questObject.update;
						
						if (App.data.updates.hasOwnProperty(updateID))
						{
							if (App.data.updates[updateID].social.hasOwnProperty(App.social))
							{
								if (App.data.updates[updateID].temporary == 1 && App.data.updates[updateID].duration > 0)
								{
									//trace("updTime: " + (App.data.updatelist[App.social][updateID] + App.data.updates[updateID].duration * 3600));
									//trace("appTime: " + (App.time));
									if (App.data.updatelist[App.social].hasOwnProperty(updateID) && ((App.data.updatelist[App.social][updateID] + App.data.updates[updateID].duration * 3600) < App.time))
									{
										//trace('need to delete: ' + id);
										//Post.send( {
											//ctr:'quest',
											//act:'remove',
											//uID:App.user.id,
											//qID:id
										//},function(error:*, data:*, params:*):void {trace('removed')});
										continue;
									}
								}
							}else
								continue;
						}
							
							
						if (App.data.updates.hasOwnProperty(updateID) && !App.data.updates[updateID].social.hasOwnProperty(App.social))
							continue;
					}
					
					opened.push({
						id				:id, 
						character		:App.data.quests[id].character, 
						order			:App.data.quests[id].order,
						fresh			:data[id]['fresh'] || false,
						type			:App.data.quests[id].type,
						showed			:(App.data.quests[id].showed || false),
						mission			:data[id][currentMID]
					});
					if (data[id]['fresh'] != undefined)
					{
						delete data[id]['fresh'];
					}
				}
			}
			
			//Tutorial.tutorialQuests();
			
			if (App.map == null) {
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);	
			}else{
				scoreOpened();
			}
		}
		
		public function getFirstOpenMission(qID:int):int {
			var quest:Object = App.data.quests[qID];
			var missions:Array = [];
			for (var mid:* in quest.missions) {
				missions.push(mid);
			}
			missions.sort();
			for (var i:int = 0; i < missions.length; i++) {
				if (data[qID] && (!data[qID][missions[i]] || int(data[qID][missions[i]]) < quest.missions[missions[i]].need))
					return missions[i];
			}
			
			return 0;
		}
		
		public function isFirstOpenMission(qID:int, mID:int):Boolean {
			return (getFirstOpenMission(qID) == mID);
		}
		
		private function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);	
			scoreOpened();
		}
		
		public function countOfUnits(sid:*):int {
			var childs:int = App.map.mSort.numChildren;
			var unit:Unit;
			var count:uint = 0;
			while (childs--) {
				unit = App.map.mSort.getChildAt(childs) as Unit;
				
				if (unit&&unit.sid == sid) {
					count++;
				}
			}
			return count;
		}
		
		public function scoreOpened():void {
			if (App.user.mode == User.GUEST) {
				return;
			}
			
			var scored:Object = { };
			var custom_score:Object = { };
			var send:Boolean = false;
			var exit:Boolean = false;
			var capsulCrafts:Array = App.data.storage[500].devel[1].craft

			for each(var quest:* in opened) 
			{
				var missions:Object = App.data.quests[quest.id].missions;
				for (var mID:* in missions)
				{
					//Проверка, если цель квеста крафт из капсулы и материал крафта уже был на складе защитать мисию
					if ( missions[mID].event == 'add') 
					{
						for each(var target_SID:* in missions[mID].target)
						{
							for (var i:int = 0; i <capsulCrafts.length ; i++) 
							{
								if (target_SID == App.data.crafting[capsulCrafts[i]].out && Stock.isExist(App.data.crafting[capsulCrafts[i]].out))
								{
									if (scored[quest.id] == undefined)
									{
										scored[quest.id] = { };
									}
									scored[quest.id][mID] = { };
									scored[quest.id][mID][target_SID] = 1;
									//exit = true;
									send = true;
								}
							}
						}
					}
					if (missions[mID]['score'] != undefined && missions[mID].score)
					{	
						if (missions[mID].event == 'zone') 
						{
							for each(var target_sID:* in missions[mID].target)
							{
								if (App.user.world.zones.indexOf(target_sID) != -1)
								{
									if (scored[quest.id] == undefined)
									{
										scored[quest.id] = { };
									}
									scored[quest.id][mID] = { };
									scored[quest.id][mID][target_sID] = 1;
									
									exit = true;
									send = true;
									scored[quest.id][mID][sID] = count;
								}
							}
						}
						
						if (exit) break;
						//if (exit) continue;
						
						var childs:int; 
						var unit:Unit; 
						var _data:Array = [];
						
						
						childs = App.map.mSort.numChildren;
						while (childs--) {
							unit = App.map.mSort.getChildAt(childs) as Unit;
							if(unit != null)
								_data.push(unit)
						}
						
						childs = App.map.mLand.numChildren;
						while (childs--) {
							unit = App.map.mLand.getChildAt(childs) as Unit;
							if(unit != null)
								_data.push(unit)
						}
						
						childs = _data.length;
						exit = false;
						while (childs--) {
							
							//var unit:Unit = App.map.mSort.getChildAt(childs) as Unit;
							unit = _data[childs];
							
							//if (unit == null) continue;
							
							if (App.map._aStarNodes[unit.coords.x][unit.coords.z].open == false) {
								continue;
							}
							
							for each(var sID:* in missions[mID].target){
						
								var need:int = missions[mID].need;
								var func:String = missions[mID].func;
								
								if (data[quest.id][mID] >= need) 
									continue;
								
								if (unit.sid == sID)
								{
									var obj:Object = App.data.storage[sID];
									switch(missions[mID].event) {
										case 'buy': 
											if (['Building','Walkhero','Friendfloors','Craftfloors','Booster','Portal','Hippodrome','Bathyscaphe','University','Manufacture','Twigwam','Port', 'Pharmacy', 'Thappy', 'Field', 'Factory', 'Mining', 'Moneyhouse','Fatman', 'Golden', 'Storehouse', 'Fplant', 'Tradeshop','Hut','Tribute','Floors','Oracle', 'Mfloors', 'Happy', 'Barter', 'Ahappy', 'Table', 'Gamble'].indexOf(unit.type) != -1) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												scored[quest.id][mID] = { };
												scored[quest.id][mID][sID] = unit.id;
												//exit = true;
												send = true;
											}
											break;
										case 'instance':
											if (['Building','Booster','Hippodrome','Twigwam','Barter','Port', 'Pharmacy', 'Thappy', 'Field', 'Factory', 'Mining', 'Moneyhouse','Fatman', 'Golden', 'Storehouse','Oracle','Table'].indexOf(unit.type) != -1) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												var count:int = countOfUnits(sID);
												
												scored[quest.id][mID] = { };
												scored[quest.id][mID][sID] = count
												//exit = true;
												send = true;
											}
											break;
										case 'finished':
											if (['Building','Booster','Hippodrome','Bathyscaphe','University','Manufacture','Twigwam','Port', 'Pharmacy', 'Barter', 'Thappy', 'Field', 'Factory', 'Mining', 'Moneyhouse','Fatman', 'Golden', 'Storehouse','Tribute','Floors','Oracle', 'Mfloors', 'Table'].indexOf(unit.type) != -1) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												
												if(unit.hasOwnProperty('level') && unit.hasOwnProperty('totalLevels') && unit['level'] == unit['totalLevels']){
													count = countOfUnits(sID);
												
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = count
													exit = true;
													send = true;
												}
											}
											break;
										case 'grow':
											if (['Floors', 'Mfloors'].indexOf(unit.type) != -1) {
												if (unit['floor'] >= missions[mID].need) {
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = unit.id;
													exit = true;
													send = true;
												}
											}else if (['Ahappy'].indexOf(unit.type) != -1) 
											{
												if (unit['level'] >= missions[mID].need || unit['expire'] < App.time) {
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = unit.id;
													exit = true;
													send = true;
												}
												
											}else if (['Friendfloors', 'Craftfloors'].indexOf(unit.type) != -1) 
											{
												if (unit['model']['floor'] >= missions[mID].need) {
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = unit.id;
													//exit = true;
													send = true;
												}
												
											}
											break;
										case 'upgrade':
										case 'reward':
											if (['Building','Animal','Booster','Bathyscaphe','University','Portal','Manufacture','Hippodrome','Twigwam', 'Bridge', 'Pharmacy', 'Ctribute', 'Fair', 'Technological', 'Minigame', 'Port','Thappy', 'Field', 'Factory', 'Mining', 'Moneyhouse', 'Fatman','Golden', 'Storehouse','Tradeshop','Hut','Tribute','Floors','Zoner','Oracle','Mfloors', 'Happy', 'Ahappy', 'Barter', 'Tradeship'].indexOf(unit.type) != -1) {
												if (unit['level'] >= missions[mID].need) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												scored[quest.id][mID] = { };
												scored[quest.id][mID][sID] = unit.id;
												send = true;
												}
											}
											break;
										case 'mkick':
											if (['Friendfloors'].indexOf(unit.type) != -1) {
												if (unit['model'].kicks >= missions[mID].need) 
												{
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = unit.id;
													send = true;
												}
											}
											break;
										case 'fkick':
											if (['Friendfloors'].indexOf(unit.type) != -1) {
												if (Numbers.countProps(unit['model'].friends) >= missions[mID].need) 
												{
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = unit.id;
													send = true;
												}
											}
											break;
										case 'feed':
											if (['Animal'].indexOf(unit.type) != -1) {
												if (quest.id == 815 || quest.id == 816)
												{
													if (unit['_level'] > 0)
													{
														if(custom_score[quest.id] == undefined){
															custom_score[quest.id] = { };
														}
														custom_score[quest.id][mID] = unit['_level'];
														send = true;
															
													}
												}
											}
											break;
										case 'throw':
											if (['Bathyscaphe'].indexOf(unit.type) != -1) {
												if (App.user.bathyscaphe.currentThrow > 0)
												{
													if(custom_score[quest.id] == undefined){
														custom_score[quest.id] = { };
													}
													custom_score[quest.id][mID] = App.user.bathyscaphe.currentThrow;
													send = true;
														
												}
											}
											break;
										case 'remove':
											if (['Resource'].indexOf(unit.type) != -1) {
												if (quest.id == 814)
												{
													var needUnits:Array = Map.findUnits([2758, 2759, 2760])
													trace();
														if(custom_score[quest.id] == undefined){
															custom_score[quest.id] = { };
														}
														custom_score[quest.id][mID] = need - (needUnits.length-1);
														send = true;
														
												}
											}
											break;
										case 'create':
											if (['Animal'].indexOf(unit.type) != -1) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												scored[quest.id][mID] = { };
												scored[quest.id][mID][sID] = unit.id;
												exit = true;
												send = true;
											}
											break;
										case 'stock':
											if (['Building','Thappy', 'Tribute', 'Walkgolden', 'Ahappy'].indexOf(unit.type) != -1) {
												
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = unit.id;
													
													exit = true;
													send = true;
												
											}
											break;	
									}
								}
								if (exit) break;
							}
							if (exit) break;
						}		
					}
				}	
			}
			if (send) {
				var sendObj:Object = {
					ctr:'quest',
					act:'score',
					uID:App.user.id,
					wID:App.user.worldID,
					score:JSON.stringify(scored)
				}
				if (custom_score)
					sendObj['custom_score'] = JSON.stringify(custom_score);
				Post.send( sendObj ,function(error:*, data:*, params:*):void {
					
					
				});
			}
		}
		
		public function finishQuests(qIDs:Array):void
		{
			Post.send({
				ctr:'quest',
				act:'finish',
				uID:App.user.id,
				finished:JSON.stringify(qIDs)
			},function(error:*, data:*, params:*):void {
				
			});
		}	
		
		public function finishQuest(qID:int, mID:int):void
		{
			var obj:Object = { };
			obj[qID] = [mID];
			Post.send({
				ctr:'quest',
				act:'finish',
				uID:App.user.id,
				finished:JSON.stringify(obj)
			},function(error:*, data:*, params:*):void {
				
			});
		}	
		
		public function openQuest(childrens:Array):void 
		{
			var qIDs:Array = [];
			for (var i:int = 0; i < childrens.length; i++)
			{
				var qID:int = childrens[i];
				if (data[qID] == undefined)
				{
					qIDs.push(qID);
					data[qID] = { };
					data[qID]['finished'] = 0;
					data[qID]['fresh'] = true;
				}
			}
			
			if(qIDs.length > 0){
				Post.send( {
					ctr:'quest',
					act:'open',
					uID:App.user.id,
					qIDs:JSON.stringify(qIDs)
				},function(error:*, data:*, params:*):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
				});
			}	
		}
		
		private var shoewdFr:Boolean = false;
		private var alreadyShowed:Object = { };
		public var skipMessages:Array = [];
		public static var openDialogs:Object = {};
		public function openMessages():void
		{
			//return;
			for (var id:* in opened) {
				
				var qID:int = opened[id].id;
				var questInfo:Object = App.data.quests[qID];
				
				if (opened[id].type == 1)
				{
					var reg:RegExp = new RegExp(/[0-9]+:\s/);
					
					if (reg.test(questInfo.description))
					{
						if (App.user.quests.tutorial)
							Window.closeAll();
						if (openDialogs.hasOwnProperty(qID))
							continue;
						Quests.openDialogs[qID] = 1;
						new DialogWindow( {
							dialog	:questInfo.description,
							qID		:opened[id].id,
							mID		:1,
							//popup	:true,
							callback:function():void {
								readEvent(qID, function():void { });
							}
						}).show();
							//readEvent(qID, function():void { });
					}else {
						if (!tutorial)
							new CharactersWindow( { qID:opened[id].id, mID:1 } ).show();
					}					
				}
			}
			if (opened.length < 1)
				return;
			switch (opened[id].type) 
			{
				case 2:
				case 3:
				case 4:
					new GoalWindow( { quest:App.data.quests[opened[id].id] } ).show();
				break;
				default:
				break
			}
			
			/*if (opened[id].type > 1) 
			{				
				new GoalWindow( { quest:App.data.quests[opened[id].id] } ).show();
			}*/
		}
		
		public function isNew(qID:int):Boolean
		{
			for each(var quest:Object in opened)
			{
				if (qID == quest.id && quest.fresh && App.data.quests[qID].type != 1) 
				{
					return true;
				}
			}
			return false;
		}
		
		public function openChilds(parentID:int = 0):void
		{
			var parentQuest:Object = data[parentID] || { };
			for (var qID:* in App.data.quests) {
				var quest:Object = App.data.quests[qID];
				if(((parentQuest['finished'] != undefined && parentQuest['finished'] > 0) || parentID == 0) && quest.parent == parentID){
					if(data[qID] == undefined){
						data[qID] = { };
						data[qID]['finished'] = 0;
						data[qID]['fresh'] = true;
						if(quest.hasOwnProperty('duration'))
							data[qID]['created'] = App.time;
						
						checkPromo();
						checkFreebie();
						
						if(data[qID] == 839) {
							Events.initEvents();
						}
						
					}
				}
			}
		}
		
	
	
		private function inNewChapter(id:uint):Boolean
		{
			if (chapters.indexOf(id) == -1)
			{
				chapters.push(id);
				return true;
			}
			return false;
		}
		
		private function changeChapter(id:uint):void
		{
			new ChapterWindow( {
				chapter:id
			}).show();
			
			Pigeon.checkNews();
			
			setTimeout(function():void {
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_FINISH_TUTORIAL));
			},1000)
		}
		
		public function openWindow(qID:int, glowHelp:Boolean = false):void {
			getOpened();	
			
			if (App.data.quests[qID].bonus) {
				var questData:Object = App.data.quests[qID];
				var update:String = questData.update;
				if (App.data.updatelist[App.social][update] + Numbers.WEEK >= App.time) { 
					if (App.user.quests.data.hasOwnProperty(questData.ID) && App.user.quests.data[questData.ID].hasOwnProperty('viewed') && App.user.quests.data[questData.ID].viewed < App.time) {
						
					} else {
						QuestIcon.sendQuestClick(qID);
					}
				}
				//new QuestWindow( { qID:qID, popup:true } ).show();
			}
			
			setTimeout(function():void {
			/*if (!User.inExpedition) 
			{*/
				new QuestWindow( { 
					qID			:qID,
					popup		:true,
					glowHelp	:glowHelp
				}).show();				
				alreadyShowed[qID] = App.time;	
			//}
			}, 100);		
		}
		
		private var timeGlowID:uint = 0;
		private var timeID:uint = 0;
		
		public function progress(state:Object):void 
		{
			for (var qID:* in state)
			{
				if (!data.hasOwnProperty(qID))
					continue;
				var missions:Object = state[qID];
				
				for (var mID:* in missions)
				{
					
					data[qID][mID] = missions[mID];
					
					if (data[qID][mID] >= App.data.quests[qID].missions[mID].need) 
					{
						/*//TODO показываем прогресс напротив иконки квеста
						if (App.data.quests[qID].tutorial) {
							continueTutorial();
						}else {
							App.ui.leftPanel.questsPanel.focusedOnQuest(qID, QuestPanel.PROGRESS)
						}*/
					}else if (App.data.quests[qID].tutorial && App.data.quests[qID].track && qID != 9)
					{
						helpEvent(qID, mID);
					}
				}
				
				var finished:Boolean = true;
				
				for (mID in App.data.quests[qID].missions)
				{
					if (data[qID][mID] == undefined || App.data.quests[qID].missions[mID].need > data[qID][mID]) 
					{
						finished = false;
						break;
					}
				}
				
				if (finished == true) 
				{
					data[qID].finished = App.time;
					
					if (App.social == 'FB')
					{
						ExternalApi.og('complete','quest');
					}
					
					//if (!tutorial) {
					//if (!Window.hasType(QuestRewardWindow))
					//{
						new QuestRewardWindow( {
							qID:qID,
							//forcedClosing:true,
							strong:true,
							callback:onTakeEvent
						}).show();
					//}
					//}
					
					App.user.stock.addAll(App.data.quests[qID].bonus.materials);
					
					openChilds(qID);
					getOpened();
					App.ui.leftPanel.questsPanel.refresh();
					openMessages();	
					clearTimeout(timeGlowID);
					clearTimeout(timeID);
					
					if (qID !=112) 
					{
						currentTarget = null;
					}
					//continueTutorial();
				}
				
				continueTutorial();
				
				for (var ind:* in missions) {
					questMission = ind;
					break;
				}
				
				//TODO показываем прогресс напротив иконки квеста
				if (App.data.quests[qID].tutorial) {
					//continueTutorial();
				}else {
					if(App.ui) App.ui.leftPanel.questsPanel.focusedOnQuest(qID, questMission, QuestPanel.PROGRESS)
				}
			}
		}
		
		public function onTakeEvent(bonus:Object):void
		{
			//App.user.stock.addAll(bonus);
		}
		
		public function silentRead(qID:int):void {
			Post.send( {
				ctr:'quest',
				act:'read',
				uID:App.user.id,
				qID:qID
			}, function(error:*, result:*, params:*):void {});
			App.user.quests.readEvent(qID, function():void {
				trace("each");
			});
		}
		
		public function readEvent(qID:int, callback:Function):void 
		{
			Post.send( 
			{
				ctr:'quest',
				act:'read',
				uID:App.user.id,
				qID:qID
			}, function(error:*, result:*, params:*):void 
			{
				if (result) 
				{
					delete Quests.openDialogs[data[qID]];
					callback();
					data[qID]['finished'] = App.time;
					
					openChilds(qID);
					getOpened();
					
					App.ui.leftPanel.questsPanel.refresh();
					
					currentTarget = null;
					//continueTutorial();
					
					openMessages();
					
					if (tutorial)
						continueTutorial();
				}
			});
		}
		
		/**
		 * обработка кнопок для пропуска миссий в квестах
		 * @param	qID - квест
		 * @param	mID - миссия
		 * @param	callback
		 * @param	isForKeys - можно пройти за ключик или не за ключик
		 * @return
		 */
		public function skipEvent(qID:int, mID:int, callback:Function = null, isForKeys:Boolean = false):Boolean {
			
			if (data[qID] == undefined || data[qID].finished != 0) {
				//TODO может быть нужно показывать окно о несоответсвии, если квест не открыт
				return false;
			}
			
			var mission:Object = App.data.quests[qID].missions[mID];
			
			var objectToSend:Object = {};
			var isEnoughResorces:Boolean;
			
			if (isForKeys) {
				isEnoughResorces = App.user.stock.take(Stock.KEY, 1);
				objectToSend.m = "1";
			} else {
				isEnoughResorces = App.user.stock.take(Stock.FANT, mission.skip);
			}
			
			if (isEnoughResorces) {				
				objectToSend.ctr = "quest";
				objectToSend.act = "skip";
				objectToSend.uID = App.user.id;
				objectToSend.qID = qID;
				objectToSend.mID = mID;
				
				Post.send( objectToSend, 
					function(error:*, result:*, params:*):void {
						if (error) {
							Errors.show(error, data);
							
							if (objectToSend.m){
								App.user.stock.add(Stock.KEY, 1);
							} else {
								App.user.stock.add(Stock.FANT, mission.skip);
							}
							
							return;
						}
					data[qID][mID] = mission.need;	
					callback(mID);
				} );
				
				return true;
			}
			return false;	
		}
		
		public var win:*;
		
		private static var _help:Boolean = false;
		public static var daylicsHelp:Boolean = false;
		public function helpEvent(qID:int, mID:int, light:Boolean = false, dID:int = 0):void {
			//currentQID = qID;
			//currentMID = mID;
			
			var event:*;
			var targets:Array = [];
			var mapTargets:Object;
			var searchByType:Boolean = false;
			var filter:Object;
			var all:Boolean = false;
			var questType:String = 'quests';
			
			if (dID == 1) {
				questType = 'daylics';
				daylicsHelp = true;
				currentDMID = mID;
			}else {
				help = true;
				currentQID = qID;
				currentMID = mID;
			}
			
			event = App.data[questType][qID].missions[mID].find;
			if (App.data[questType][qID].missions[mID]['map']) {
				mapTargets = App.data[questType][qID].missions[mID].map;
			}else{
				mapTargets = App.data[questType][qID].missions[mID].target;
			}
			for each(var target:* in mapTargets) {
				targets.push(target);
			}
			searchByType = Boolean(App.data[questType][qID].missions[mID].ontype) || false;
			filter = App.data[questType][qID].missions[mID].filter;
			all = Boolean(App.data[questType][qID].missions[mID].all || 0);
			
		switch(event) 
		{
				case 0: break; //нигде
				case 1:
					for each(var _find:* in App.data[questType][qID].missions[mID]./*map*/target) 
					{
						break;
					}
					if (qID == 9 && mID == 2)
						_find = App.data[questType][qID].missions[mID].map[0];
					
					if (!findTarget(targets, searchByType, filter, all, _find, light, App.data[questType][qID].missions[mID].event))
					{
						if (User.inExpedition) 
						{
							new SimpleWindow( {
								popup:true,
								height:320,
								width:480,
								title:Locale.__e('flash:1382952380254'),
								text:App.data[questType][qID].missions[mID].description
							}).show();
							return
						}
						var shW2:ShopWindow;
						if (App.data.storage[int(target)].type == 'Material')
						{
							var resId:uint = 0;
							for each(var ssId:* in App.data.storage)
							{
								if (ssId.type == 'Resource' && ssId.outs)
								{
									var counter:int = 0;
									for each(var num:* in ssId.outs)
									{
										resId = Numbers.getProp(ssId.outs, counter).key;
										
										if (resId == target)
										{
											shW2 = new ShopWindow( { find:[int(ssId.sID)] } );
											shW2.show();
											break;
										}
										counter++;
									}
								}
							}
							
						}
						//shW2 = new ShopWindow( { find:[int(target)] } );
						/*var exceptions:Array = [407, 1939, 1940, 1941, 1942, 1943, 1948, 1950, 1960, 1949, 1977, 1989, 1990, 1740, 1749, 1934, 427, 203, 2064, 2151];
						if (exceptions.indexOf(App.data.storage[target].sID) != -1) 
						{
							ShopWindow.history.section = 100;
						}*/
						if (App.data.storage[int(target)].type == 'Resource')
						{
							if (onClosedZone)
								return;
							new SimpleWindow( {
								title:Locale.__e("flash:1474469531767"),
								label:SimpleWindow.ATTENTION,
								text:Locale.__e('flash:1481876277712', App.data.storage[int(target)].title)
							}).show();
							return;
						}
						/*if (App.data.storage[int(target)].type == 'Building')
						{
							new ShopWindow( { find:[int(target)] } ).show();
						}*/
						if (ShopWindow.history.section != 100) {
							//shW2.show();
						}else {
							if (App.data[questType][qID].missions[mID].description!='') 
							{
								if(App.data.storage[int(target)].type != 'Walkgolden')
								{
									new SimpleWindow( {
										popup:true,
										height:320,
										width:480,
										title:Locale.__e('flash:1382952380254'),
										text:App.data[questType][qID].missions[mID].description
									}).show();
								}
							}else{
								new SimpleWindow( {
									title:Locale.__e("flash:1382952379744"),
									label:SimpleWindow.ERROR,
									text:Locale.__e("flash:1382952379745"),
									ok:function():void {
										
										if (App.user.level <= 2) {
											ExternalApi.sendmail( {
												title:'flash:1382952379745',
												text:App.self.flashVars['social'] + "  " + App.user.id
											});
										}
									}
								}).show();	
							}
						}						
					}else 
					{
						if (App.data[questType][qID].missions[mID].event == 'move') //перемещение
						{
							App.ui.bottomPanel.bttnCursor.showGlowing();
							App.ui.bottomPanel.bttnCursor.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
							App.ui.bottomPanel.moveCursor.showGlowing();
							setTimeout(function():void {
								//App.ui.bottomPanel.bttnCursors.hidePointing();
								App.ui.bottomPanel.bttnCursor.hideGlowing();
								App.ui.bottomPanel.moveCursor.hideGlowing()
							}, 5000);
						}
						if (App.data[questType][qID].missions[mID].event == 'remove' && (qID != 426) && !App.data.quests[qID].tutorial && App.data.storage[int(target)].type != 'Resource') //удаление
						{
							App.ui.bottomPanel.bttnCursor.showGlowing();
							App.ui.bottomPanel.bttnCursor.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
							App.ui.bottomPanel.removeCursor.showGlowing();
							setTimeout(function():void {
								//App.ui.bottomPanel.bttnCursors.hidePointing();
								App.ui.bottomPanel.bttnCursor.hideGlowing();
								App.ui.bottomPanel.removeCursor.hideGlowing()
							}, 5000);
						}
						if (App.data[questType][qID].missions[mID].event == 'put') //на склад
						{
							App.ui.bottomPanel.bttnCursor.showGlowing();
							App.ui.bottomPanel.bttnCursor.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
							App.ui.bottomPanel.stockCursor.showGlowing();
							setTimeout(function():void {
								//App.ui.bottomPanel.bttnCursors.hidePointing();
								App.ui.bottomPanel.bttnCursor.hideGlowing();
								App.ui.bottomPanel.stockCursor.hideGlowing()
							}, 5000);
						}
					}					
					break; //На карте
				case 2: 
					
					if (App.data.quests[qID].tutorial) 
					{
						currentTarget = App.ui.bottomPanel.bttnMainShop;
						//currentTarget.startBlink();
						//currentTarget.showPointing("top", 0, 0, currentTarget.parent, '', null);
						
						QuestsRules.addTarget(currentTarget);
						QuestsRules.addTarget(targets[0]);
						
						currentTarget.addEventListener(MouseEvent.CLICK, onTargetClick, false, 3000);
					}else
					{
						var unts:Array = Map.findUnits(targets);
						if (World.worldsWhereEnabled(targets[0]).indexOf(App.user.worldID) == -1)
						{
							new WorldsWindow( {
								title: Locale.__e('flash:1415791943192'),
								sID:	targets[0],
								only:	World.worldsWhereEnabled(targets[0]),
								popup:	true
							}).show();
							break;
						}
						
						win = new ShopWindow( { find:targets } );
						win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
						win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
						win.show();
					}
					break; //В магазине
				case 3:
					var sIDD:int = App.data[questType][qID].missions[mID].target[0];
					if (App.user.stock.count(sIDD) > 0 && App.user.stock.count(sIDD) >= App.data[questType][qID].missions[mID].need)
					{
						win = new StockWindow({ find:targets, findEvent:App.data[questType][qID].missions[mID].event });
						win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
						win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
						win.show();
					}else
					{	
						new SimpleWindow({
						text:    Locale.__e('flash:1482139038489',  App.data.storage[sIDD].title), 
						//App.data.storage[workers[0]].title + " уже обучен профессии! Стереть ему память?",
						height:   250,
						dialog:   true,
						confirm:function():void {
							ShopWindow.findMaterialSource(sIDD);
						}
						}).show();					
					}
					
					break; //На складе
				case 4:
					win = new CollectionWindow( { find:targets } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					break; //flash:1382952379772е
				case 5:
					if (App.ui.bottomPanel.friendsPanel.opened) 
					{
						App.ui.bottomPanel.hideFriendsPanel();
						__dy = -65;
					}
					currentTarget = App.ui.bottomPanel.iconsBottom[0].bttn;
					currentTarget.showGlowing();
					currentTarget.addEventListener(MouseEvent.CLICK, onFriendsIconClick, false, 3000);
					//setTimeout(startTrack, 200);
					break; //flash:1382952379772е
				case 6:
					win = new FreeGiftsWindow( { find:targets } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					break; //В бесплатных подарках
				case 7:
					win = new FreeGiftsWindow( { find:targets, mode:FreeGiftsWindow.TAKE } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					break; //В принятых подарках
				case 8:
					if(App.social == 'FB'){
						win = new FreeGiftsWindow( { find:targets, icon:'wishlist', mode:FreeGiftsWindow.ASK} );
						win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
						win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
						win.show();
					}else{
						win = new FreeGiftsWindow( { find:targets, icon:'wishlist' } );
						win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
						win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
						win.show();
					}
					break; //В бесплатных подарках
				case 9:
					if (User.inExpedition) 
					{
						App.ui.bottomPanel.bttnMainHome.showGlowing();
						App.ui.bottomPanel.bttnMainHome.showPointing("top", 0, 30, App.ui.bottomPanel.bttnMainHome.parent);
						
						setTimeout(function():void 
						{
							App.ui.bottomPanel.bttnMainHome.hidePointing();
							App.ui.bottomPanel.bttnMainHome.hideGlowing();
						}, 3000);
						
						return;
					}
					var __dy:int = 0;
					//if (qID == 81) {
					/*if (App.ui.bottomPanel.friendsPanel.opened) {
						App.ui.bottomPanel.hideFriendsPanel();
						__dy = -65;
					}
					currentTarget = App.ui.bottomPanel.iconsBottom[1].bttn;
					currentTarget.showGlowing();
					Tutorial.watchOn(currentTarget, 'top', false, { dy: __dy } );
					currentTarget.addEventListener(MouseEvent.CLICK, onOpenMaps, false, 3000);*/
					win = new TravelWindow( { find:targets } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					break;// В картах
			}
		}
		
		private function onTargetClick(e:MouseEvent):void 
		{
			if (currentTarget == null) return;
			currentTarget.removeEventListener(MouseEvent.CLICK, onTargetClick);
			currentTarget.hidePointing();
			currentTarget.hideGlowing();
		}
		
		private function onFriendsIconClick(e:MouseEvent):void 
		{
			onTargetClick(e);
			if (currentTarget == null) return;
			
			currentTarget = App.ui.bottomPanel.friendsPanel.friendsItems[0];
			currentTarget.showGlowing();
		}
		
		
		private function onOpenMaps(e:MouseEvent):void 
		{
			onTargetClick(e);
		}
		
		
		private function filteredTarget(unit:Unit, filter:Object):Boolean 
		{
			for (var field:String in filter) {
				var properties:Array = field.split(".");
				var value:* = filter[field];
				
				var target:* = unit;
				for each(var property:* in properties) 
				{
					if (!target.hasOwnProperty(property)) 
						return false;
					
					target = target[property];
				}
				
				if (target != value)
					return false;	
			}
			
			return true;
		}
		
		public var targets:Array = [];
		public var currentTarget:*;
		public var unclossedRes:Boolean = false;
		public var lockWhileMove:Boolean = false;
		public var onClosedZone:Boolean = false;
		public function findTarget(sIDs:Array, searchByType:Boolean, filter:Object = null, all:Boolean = false, find:int = 0 , light:Boolean = false, eventType:String = '', exception:Boolean = false):Boolean 
		{
			var sPoint:Object = { x:App.user.hero.cell, z:App.user.hero.row };
			var sID:int;
			var ssID:int;
			var childs:int;
			var childsPlant:int;
			var unit:*;
			var depth:int;
			
			//Поиск зон на карте. Если такой зоны нет на текущей карте - сообщение
			if (find != 0 && App.data.storage[find].type == 'Lands') 
			{
				if (sIDs.length > 0 && (find == 1388))
				{
					new TravelWindow( { find:820, popup:true } ).show();
					return true;
				}
				
				if (App.data.storage[find].hasOwnProperty('available') && App.data.storage[find].available != '' && !TravelWindow.availableByTime(find))
				{	
					new TimerMapsWindow({}).show();
					return true;
				}
				else{
					new TravelWindow( { find:find, popup:true } ).show();
					return true;
				}
			}
			//Поиск зон на карте. Если такой зоны нет на текущей карте - сообщение
			if (find != 0 && App.data.storage[find].type == 'Zones') 
			{
				var findedZ:Boolean = false;
				for each(var sIDD:* in sIDs)
				{
					find = sIDD;
					if (App.user.mode == User.OWNER)
					{	
						var worldsWhereEnable1:Array = [];
						for (var i1:* in App.user.maps) 
						{
							for (var mapa1:* in App.user.maps[i1].ilands)
							{
								if (World.canBuyOnThatMap(find, mapa1))
									worldsWhereEnable1.push(mapa1);
							}
						}
						
						if (!World.canBuyOnThisMap(find))
						{
							new WorldsWindow( {
								title: Locale.__e('flash:1415791943192'),
								sID:	null,
								only:	worldsWhereEnable1,
								popup:	true
							}).show();
							return true;
						}
						
						var fogCoords:* = Fog.fogCenter(find); //
						var obj1:Object = {x:fogCoords.x + 0, y:fogCoords.y + 0};
						App.map.focusedOn(obj1);
						QuestsRules.addTarget(Fog.zones[find]);
						if (App.user.worldID == User.AQUA_HERO_LOCATION){
							App.map.rooms[find].fader.startBlink();
							setTimeout(function():void 
							{
								App.map.rooms[find].fader.stopBlink();
							}, 5000);
						}
						else{
							Fog.zones[find].startBlink();
							//Fog.faders[find].startBlink();
							setTimeout(function():void 
							{
								if(Fog.zones)
									Fog.zones[find].stopBlink();
							}, 5000);
						}
						return true;
					}
					
				}
				
				if(!findedZ)
				{
					new SimpleWindow( {
						popup:true,
						height:320,
						width:480,
						title:Locale.__e('flash:1382952380254'),
						text:Locale.__e('flash:1453282521399') + " " + App.data.storage[find].title + " " + Locale.__e('flash:1453282576126') + " " + App.data.storage[App.data.storage[find].land].title
					}).show();
					return true;
				}
			}
			
			if (searchByType == true && sIDs.length > 0) 
			{
				sID = sIDs.shift();
				ssID = sID;
				var type:String = App.data.storage[sID].type;
				
				childs = App.map.mSort.numChildren;
				while (childs--) 
				{
					unit = App.map.mSort.getChildAt(childs);
					
					if (App.map._aStarNodes[unit.coords.x][unit.coords.z].open == false) 
					{
						continue;
					}
					
					if (unit.type == type)
					{
						if (unit is Plant) unit = unit.parent;
						if (unit is Wigwam || unit is Twigwam) 
						{ 
							if (eventType == 'hire' && unit.level >= unit.totalLevels - 1) 
							{
								continue;
							}	
						}
						if (eventType == 'upgrade' && unit.level && (unit.level == (unit.totalLevels - unit.craftLevels))) 
						{
							continue;
						}
						if (filter != null) 
						{
							if (!filteredTarget(unit, filter)) 
							{
								continue;
							}
						}
						targets.push(unit);
					}
				}
			}else{
				while (sIDs.length > 0)
				{
					sID = sIDs.shift();
					ssID = sID;
					childs = App.map.mSort.numChildren;
					if (App.data.storage[sID].type == "Lamp")
					{
						for each (unit in Lantern.lanterns )
							if (unit.sid == sID)
								targets.push(unit);
					}else
					{
						while (childs--) 
						{
							unit = App.map.mSort.getChildAt(childs);
							
							if (sID == 0)
								continue;
								
							if (unit is PixelRenderer || unit is Fog || unit is Sector || !unit.hasOwnProperty('coords') || !unit.coords)
							{
								continue;
							}
							if (App.map._aStarNodes[unit.coords.x][unit.coords.z].open == false && !exception && !(unit is Bridge) && !(unit is Plant) && !(unit is Tribute) && !(unit is Barter) && !(unit is Animal) && !(unit is Decor) && !(unit is Building) && !(unit is Resource && !App.user.quests.tutorial)) 
							{
								if (unit.sid == sID && sID != 1141)
								{
									// закрытые ресы
									onClosedZone = true;
									continue;
								}
							}
							
							if (unit is Unit && unit.sid == sID) 
							{
								if (unit is Wigwam || unit is Twigwam) 
								{
									if (eventType == 'hire' && unit.level >= (unit.totalLevels - 1))
										continue;
								}
								/*if (unit is Animal && eventType == 'ready') 
								{
									continue;
								}*/
								if (eventType == 'upgrade' && unit.hasOwnProperty('totalLevels') && (unit.level == unit.totalLevels)) 
								{
									continue;
								}
								
								if (!(unit is Animal) && eventType == 'ready' && unit.hasOwnProperty('totalLevels') && unit.totalLevels && (unit.level < unit.totalLevels)) 
								{
									continue;
								}
								if (unit is Plant)
									unit = unit.parent;
								/*if (unit is Twigwam)
									unit = unit.parent;*/
								
								if (filter != null) {
									if (!filteredTarget(unit, filter)) 
									{
										continue;
									}
								}
								
								depth = Math.abs(sPoint.x - unit.coords.x) + Math.abs(sPoint.z - unit.coords.z);
								if(unit.sid == 988 && sID == 988 && sIDs.length == 0)
									targets.push(unit);
									
								if(unit.sid != 988)
									targets.push(unit);
							}
						}
					}
					
					childsPlant = App.map.mField.numChildren;
					while (childsPlant--) {
						unit = App.map.mField.getChildAt(childsPlant);
						
						if (App.map._aStarNodes[unit.coords.x][unit.coords.z].open == false)
						{
							if (unit.sid == sID)
							{
								onClosedZone = true;
								continue;
							}
						}
						
						if(unit.sid == sID){
							if (unit is Plant) unit = unit.parent;
						
							if (filter != null) {
								if (!filteredTarget(unit, filter)) {
									continue;
								}
							}
							
							//depth = Math.abs(sPoint.x - unit.coords.x) + Math.abs(sPoint.z - unit.coords.z);
							targets.push(unit);
						}
						
						if (unit.plant && unit.plant.sid == sID)
						{
							if (filter != null) {
								if (!filteredTarget(unit, filter)) {
									continue;
								}
							}
							targets.push(unit);
						}
					}
				}
				
				if (targets.length == 0 /*&& App.data.storage[sID].sID == 1778*/) 
				{
					if (sID == 1592)//конек costile 
					{
						findTarget([1141],false);
						return true;
					}
					
					if (onClosedZone && (App.data.storage[sID].type == 'Resource' || App.data.storage[sID].type == 'Material'))
					{
						new SimpleWindow( {
							title:Locale.__e("flash:1474469531767"),
							label:SimpleWindow.ATTENTION,
							text:Locale.__e('flash:1481876277712', App.data.storage[ssID].title)
						}).show();
						return false;
					}else{
						if (eventType == 'put') 
						{
							new StockWindow( { find:[ssID] } ).show();
							return false;
						}
						
						if (!World.canBuyOnThisMap(sID)){
							Travel.findMaterial = {
								find:[find]
							}
							
							new WorldsWindow( {
								title: Locale.__e('flash:1415791943192'),
								sID:	sID,
								only:	World.worldsWhereEnabled(sID),
								popup:	true
							}).show();
							return true;
						}
						if (ssID != 679 && App.data.storage[sID].type != 'Resource' && App.data.storage[sID].type != 'Lamp')
						{
							new ShopWindow( { find:[ssID] } ).show();
						
						}
					}
				}
			}
			
			if (targets && targets.length > 0) 
			{
				if (App.user.quests.tutorial)
				{
					var finded:Boolean = false;
					var ii:* = QuestsRules.getTargtes();
					if (ii)
					{
						for each(var tar:* in ii)
						{
							if (tar && tar.hasOwnProperty('sid') && tar.sid == sID)
							{
								targets = new Array();
								targets.push(tar);
								finded = true;
							}else{
								if (tar != null)
								{
									targets = new Array();
									targets.push(tar);
									finded = true;
								}
							}
						}
					}
					if (!finded)
					{
						var hhh:* = Numbers.firstProp(targets).val;
						//var ddd:* = Numbers.firstProp(hhh).val;
						QuestsRules.addTarget(hhh);
					}
				}
				
			}
			
			if (targets.length > 0) 
			{
				targets.sortOn('depth', Array.NUMERIC);
				var target:Object = Finder.nearestUnit(App.user.hero, targets);
				lock = true;
				lockWhileMove = true;
				var tween:Boolean = true;
				var focusTarget:* = target;
				if (all == true) 
				{
					var need:int = App.data.quests[currentQID].missions[currentMID].need;
					if (need <= 0)
						need = 1;
					var have:int = data[currentQID][currentMID];
					need = need - have;
					for each(var item:* in targets) 
					{
						if (need <= 0)
							break;
						
						if (item.type != "Animal"){
							focusTarget.showPointing("top", item.dx, item.dy);//0 - dx
							
						}
							
						focusTarget.startBlink();
						if (!App.user.quests.tutorial)
							hideTargetGlowing(target);
						doFocus(focusTarget);
						need--;
					}
				}else 
				{
					
					doFocus(focusTarget);
					
				}
				
				function doFocus(thisTarget:*):void 
				{
					if (target is Port)
					{
						Window.closeAll();
					}
					App.map.focusedOnCenter(thisTarget, false, function():void 
					{
						currentTarget = target;
						
						var doClick:Boolean = false;
						if ((thisTarget is Building || thisTarget is Craftfloors) && !(thisTarget is Tribute) && !(thisTarget is Barter)) 
						{
							if(eventType != "move")
								doClick = true;
						}
						
						if (thisTarget is Field || thisTarget is Port /*|| thisTarget is Building*/) 
						{
							doClick = false;
						}
						if (tutorial && currentQID == 19 || currentQID == 5 || (currentQID == 135 && currentMID == 1))
						{
							doClick = false;
						}
						
						if (doClick && thisTarget.open && thisTarget.type != 'Resource'){
							if (thisTarget.hasOwnProperty('hasProduct') && thisTarget.hasProduct && !tutorial)
								thisTarget.click();
							
							thisTarget.helpTarget = find;
							if (thisTarget.type != 'Portal')
								thisTarget.click();
							
						}else
						{
							target.startBlink();
							if (!tutorial || !track) 
							{
								var _timer:uint = 3000;
								if (target is Lantern)
								{
									target.showPointing("none", target.dx - 100, -350);
									//_timer = 1000;
								}else if (target is Port)
								{
									target.showPointing("top", target.dx + 35, target.dy + 50);
								}else if (target is Animal)
								{
									target.stopWalking();
									target.showPointing("top", target.dx - target.width/2, target.dy - target.depth_animal);
								}else if (target is Pet)
								{
									target.showPointing("top", target.dx - target.width/2, target.dy - 75);
								}else if (target is Techno)
								{
									target.stopWalking();
									target.onGoHomeComplete();
									target.showPointing("top", target.dx - target.width/2, target.dy - 60);
								}else if (target is Walkgolden)
								{
									target.showPointing("top", target.dx - target.width/2, target.dy);
								}else
								{
									var ddx:int = 0
									target.showPointing("top", target.dx + ddx, target.dy);
								}
								
								if (tutorial) 
								{
									App.user.quests.startTrack();
									currentTarget = thisTarget;
								}
								
								setTimeout(function():void {
									target.hidePointing();
									target.stopBlink();
									target.hideGlowing();
								}, _timer);
							}else 
							{
								App.user.quests.unlockFuckAll();
							}
						}
						
						lock = false;
						lockWhileMove = false;
					}, tween,SystemPanel.scaleValue);
				}
				
				targets = [];	
				return true;
			}
			return false;
		}		
		
		private function hideTargetGlowing(item:*):void 
		{
			setTimeout(function():void {
				item.hidePointing();
				item.hideGlowing();
			}, 3000);
		}
		
		public var track:Boolean = false;
		private var _lock:Boolean = false;
		public function startTrack():void 
		{	
			if (track == false) 
			{
				//trace('startTrack');
				track = true;
				App.self.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent, false, 1000);
				App.self.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent, false, 1000);
				App.self.stage.addEventListener(MouseEvent.CLICK, onMouseEvent, false, 1000);
				//App.self.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 1000);
				App.self.stage.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDouble, false, 1000);
			}
		}
		
		public function stopTrack():void 
		{		
			//trace('stopTrack');
			track = false;
			App.self.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
			App.self.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
			App.self.stage.removeEventListener(MouseEvent.CLICK, onMouseEvent);
			//App.self.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			App.self.stage.removeEventListener(MouseEvent.DOUBLE_CLICK, onMouseDouble);
		}
		
		private function onMouseDouble(e:MouseEvent):void 
		{
			e.stopImmediatePropagation();
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{
			App.self.moveCounter  = 0;
		}
		
		public static var lockButtons:Boolean;
		private function onMouseEvent(e:MouseEvent):void 
		{
			
			if (e.type == MouseEvent.MOUSE_DOWN) 
			{
				App.self.moveCounter = 0;
				App.slackTime = 0;
				
				App.self.cursorOut = false;
				App.self.deltaX = e.stageX;
				App.self.deltaY = e.stageY;
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_MOUSE_DOWN));
			}
			if (e.type == MouseEvent.MOUSE_UP) 
			{
				QuestsRules.underMouse = App.self.getObjectsUnderPoint(new Point(App.self.mouseX, App.self.mouseY));
				
				if(!App.self.mapMoving || App.map.moved)
					QuestsRules.cantPress(e.target);
				
				App.self.mapMoving = false;
			}
			
			if (App.map.moved)
				return;
			
			e.stopImmediatePropagation();
			e.stopPropagation();
		}
		
		public static var _lockFuckAll:Boolean = false;
		public function unlockFuckAll():void 
		{
			removeSquareToBlock()
			_lockFuckAll = false;
			lockButtons = false;
		}
		
		public function removeSquareToBlock():void 
		{
		if (square) 
			{
				if (square.parent) 
			{
				App.self.faderContainer.removeChild(square); 
			}
				
			}	
		}
		
		private var square:Shape; 
		public function lockFuckAll():void 
		{
			
			addSquareToBlock();		
					
			_lockFuckAll = true;
			lockButtons = true;
			
		}
		
		public function addSquareToBlock(_alpha:uint = 0.01):void 
		{
			if ((square) ) 
			{
				App.self.faderContainer.addChild(square); 
				square.alpha = 0.01;
			}
			else
			{
				square = new Shape();
				square.graphics.lineStyle(1, 0xffffff); 
				square.graphics.beginFill(0xffffff); 
				square.graphics.drawRect(0, 0, App.self.stage.width,App.self.stage.width); 
				square.graphics.endFill(); 
				App.self.faderContainer.addChild(square); 
				square.alpha = 0.01;//_alpha;
			}
		}
		
		private var proceed:Boolean = false;
		private var timer:int = 0;
		public var currentQID:int = 0;
		public var currentMID:int = 0;
		private var _miniTutGrow:int = 0;
		public function continueTutorial():void 
		{
			/*if (currentQID == 0 || !App.data.quests[currentQID].tutorial) {
				return;
			}else {
				tutorial = true;
			}
			
			if(App.data.quests[currentQID].track)
				startTrack();
			
			getOpened();
			
			if(opened.length > 0 && App.ui.leftPanel.questsPanel){
				for each(var questIcon:QuestIcon in App.ui.leftPanel.questsPanel.icons) {
					//
				}
			}*/
			
			for (var i:int = 0; i < opened.length; i++) 
			{
				var quest:Object = App.data.quests[opened[i].id];
				
				if (quest.tutorial) 
				{
					currentQID = opened[i].id;
					currentMID = getFirstOpenMission(currentQID);
					QuestsRules.getQuestRule(currentQID, currentMID);
					return;
				}
				if (quest.ID == 21)
					QuestsRules.quest162();
			}
		}
		
		private function nextQuest(Ind:uint = 0):void 
		{
			
		}
		
		public function glowHelp(window:QuestWindow):void 
		{
			for each(var mission:* in window.missions) 
			{
				if (mission.helpBttn != null) 
				{
					currentQID = mission.qID;
					currentMID = mission.mID;
					
					mission.helpBttn.showGlowing();
					mission.helpBttn.showPointing("top", 0, 30, mission.helpBttn.parent);
					currentTarget = mission.helpBttn;
					
					break;
				}
				if (mission.substructBttn != null) 
				{
					currentQID = mission.qID;
					currentMID = mission.mID;
					
					mission.substructBttn.showGlowing();
					mission.substructBttn.showPointing("top", 0, 30, mission.substructBttn.parent);
					currentTarget = mission.substructBttn;
					
					break;
				}
			}
		}
		
		public function glowTutorialBttn(window:*, bttn:*, light:Boolean = false):void
		{//, qID:int, mID:int):void {
		/*	currentQID = qID;
			currentMID = mID;*/
			if (!light) 
			{
				bttn.showPointing("right", 0, 0, bttn.parent);
				bttn.showGlowing();
			}
			
			currentTarget = bttn;
			lockButtons = false;
			//App.cursorShleif.start(currentTarget);
		}
		
		private function onAfterOpen(e:WindowEvent):void 
		{
			//if (currentTarget == null) {
				//QuestsRules.getQuestRule(currentQID, currentMID);
			//}
		}
		
		private function onAfterClose(e:WindowEvent):void 
		{
			if (currentTarget == null && App.user.quests.tutorial) 
			{
				QuestsRules.getQuestRule(currentQID, currentMID);
			}
		}
		
		/**
		 * Включен туториал или нет
		 */
		private var __tutorial:Boolean = false;
		public function set tutorial(value:Boolean):void 
		{
			if (__tutorial == value) return;
			
			__tutorial = value;
			
			if (__tutorial) 
			{
				Paginator.block = 1;
				startTrack();
			}else 
			{
				Paginator.block = 0;
				stopTrack();
			}
		}
		public function get tutorial():Boolean 
		{
			return __tutorial;
		}	
	}

}