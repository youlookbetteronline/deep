package units
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Load;
	import core.MD5;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.geom.Point;
	import ui.SystemPanel;
	import utils.UnitsHelper;
	import wins.SimpleWindow;
	import wins.TechnoRecipeWindow;
	import wins.TentEquipWindow;
	//import wins.CreateAnimalWindow;
	
	public class Wigwam extends Building
	{
		
		public static var wigwams:Vector.<Wigwam> = new Vector.<Wigwam>;
		
		public var energy:uint = 0;
		public var slaveCount:uint = 1;
		public var animal:uint = 0;
		public var base:uint = 0;
		public var price:Object = 0;
		public var time:uint = 0;
		public var wigwamIsBusy:int = 0;
		public var capacity:int = 0;
		public var finished:uint = 0;
		public var openHouse:uint = 0;
		public var params:Object = null;
		public var technoToDelete:Array = new Array;
		public var workers:Array = new Array;
		public var craftData:Array = [];
		public static var TENTS:Array = [787, 1672, 1675];
		
		public var workerID:int = 0;
		public var workerSID:int = 0;
		
		private var _arrCraft:Array = [];
		private var proffCraft:Array = [];
		private var level1:int;
		
		protected var win:*
		
		public function Wigwam(object:Object)
		{
			layer = Map.LAYER_SORT;
			energy = App.data.storage[object.sid].energy || energy;
			animal = object.animal || animal;
			price = App.data.storage[object.sid].price;
			slaveCount = (App.data.storage[object.sid].outs) ? Numbers.firstProp(App.data.storage[object.sid].outs).val/*[App.data.storage[App.user.worldID].techno[0]]*/ : slaveCount;
			time = App.data.storage[object.sid].time;
			
			super(object);
			
			//Узнаём sid и id хранящегося в домике рабочего			
			if (object.workers && object.workers != null && Numbers.countProps(object.workers) > 0) 
			{
				workerID = Numbers.firstProp(object.workers).key;
				workerSID = Numbers.firstProp(object.workers).val;				
			}
			
			//Не показываем рабочего, если он занят своими делами
			/*if (object.busy) 
			{
				var technoToHide:Unit = Map.findUnit(Numbers.firstProp(object.workers).val, Numbers.firstProp(object.workers).key);
				technoToHide.visible = false;
			}*/
			
			totalLevels = 2;
			finished = object.finished;
			openHouse = App.data.storage[object.sid].b1;
			
			touchableInGuest = false;
			stockable = false;
			
			//Тут подбираем нанятого рабочего после перезагрузки
			if (object.hasOwnProperty('worker'))
			{
				workers.push(object.worker)
			}
			
			//Тут записываем busy
			if (object.hasOwnProperty('busy'))
			{
				wigwamIsBusy = object.busy;	
			}
			
			//Тут записываем capasity
			if (object.hasOwnProperty('capacity'))
			{
				capacity = object.capacity;	
			}
			if (App.user.mode == User.GUEST)
			{
				var hash:String = MD5.encrypt(Config.getSwf(type, info.view));
				if ((Load.cache[hash] != undefined && Load.cache[hash].status == 3) || !open) {
					Load.loading(Config.getSwf(type, info.view), onLoad);
				}else{
					if(SystemPanel.noload)
						clearBmaps = true;
					Load.loading(Config.getSwf(type, info.view), onLoad);
					//onLoad(UnitsHelper.bTexture);
				}
			}else
				Load.loading(Config.getSwf(type, info.view), onLoad);
			addTip();
			
			if (App.map._aStarNodes[coords.x][coords.z].w == 1)
			{
				base = 1;
			}
			
			//scaleX = scaleY = 1;
			
			settings = {
				recipeBttnMarginY:-28,
				target:this,
				titleColor:0x814f31,
				timeColor:0xffffff,
				timeBorderColor:0x764a3e,
				crafting:[],
				timeMarginY:-24,
				timeMarginX: -3, 
				recWin: TechnoRecipeWindow
			};
			
			if (App.data.storage[this.sid].b1 == 0 || this.sid == 2344)
				removable = false;
				
			
			initContent();
		}
		
		private var settings:Object = {};
		private var updtItems:Array = [];
		
		protected function addTip():void
		{
			tip = function():Object
			{
				if (finished != 0)
				{
					if (finished > App.time)
					{
						return {title: info.title, text: Locale.__e('flash:1396606641768', [TimeConverter.timeToStr(finished - App.time)]), timer: true}
					}
					else
					{
						return {title: info.title, text: Locale.__e('flash:1396606659545')}
					}
				}else 
				if (level == totalLevels) 
				{
					return {title: Locale.__e('flash:1425389878666'), text: Locale.__e('flash:1421744346418')}
				}
				
				return {title: info.title, text: info.description}
			}
		}
		
		override public function showIcon():void
		{
			
			//Ничего!
		}
		
		override public function flip():void {
			
			super.flip();
		}
		
		protected function progressToDie():void
		{
			if (finished <= App.time && finished != 0)
			{			
				finished = 0;
				App.self.setOffTimer(progressToDie);
				level++;
				updateLevel();
				
				App.self.setOnTimer(checkTechnoToRemove)
				checkTechnoToRemove();
			}		
		}
		
		public function changeWorker(newWorker:int):void 
		{
			workers = [];
			workers.push(newWorker);
			
			var temporaryUnit:Techno = new Techno( { id:100, sid:newWorker, x:coords.x, z:coords.z} );
			temporaryUnit.fake = true;
			temporaryUnit.visible = false;
			var unitToChange:Techno = Map.findUnit(this.workerSID, this.workerID);
			TweenLite.to(unitToChange, 2, { alpha: 0, onComplete: function():void{
				unitToChange.workStatus = 1;
				unitToChange.busy = 1;
				Load.loading(Config.getSwf(App.data.storage[newWorker].type, App.data.storage[newWorker].view), function(data:*):void {
					unitToChange.textures = temporaryUnit.textures;
					
					temporaryUnit.uninstall();
					temporaryUnit = null;
					unitToChange.showIcon();
					TweenLite.to(unitToChange, 2, { alpha: 1, onComplete: function():void {
						unitToChange.workStatus = 0;
						unitToChange.busy = 0; 
						unitToChange.hidden = false; 
					}});
				});
			
			}});
		}
		
		//Самостоятельно удаление рабочих из домика
		private function checkTechnoToRemove():void
		{
			var count:uint = 0;
			if (technoToDelete.length == slaveCount)
			{
				return
			}else
			{
				for (var j:int = 0; j < workers.length; j++)
				{
					for (var i:int = 0; i < App.user.techno.length; i++)
					{
						
						if (App.user.techno[i].isFree() && workers[j] == App.user.techno[i].id)
						{
							if (technoToDelete.length < slaveCount)
							{
								technoToDelete.push(App.user.techno[i])
								App.user.techno[i].wigwam(true);
							}
							else
							{
								App.self.setOffTimer(checkTechnoToRemove);
								return
							}							
						}
					}
				}				
			}		
		}
		
		override public function onLoad(data:*):void
		{
			super.onLoad(data);
			
			if (finished != 0)
			{
				level = 1;
				
				//App.self.setOnTimer(progressToDie);
				//progressToDie()
			}
			if (clearBmaps)
			{
				Load.clearCache(Config.getSwf(type, info.view));
				data = null;
			}
			//updateLevel();			
		}
		
		override public function onGuestClick():void
		{
			//super.onGuestClick();
			//cloud.dispose();
		}
		
		/*public function create():void
		{			
			Post.send( {
				ctr: 'wigwam', 
				act: 'hire', 
				uID: App.user.id, 
				wID: App.user.worldID, 
				sID: this.sid, 
				id: id,, 
				energy: params.energy, 
				ids: JSON.stringify(params.friends),
				buy: 0
			}, onBuyAction);
			
			App.self.setOnTimer(progressToDie);
			progressToDie()
			level++;
			updateLevel();
		}*/
		
		/*public function boost(params:Object):void
		{			
			Post.send( {
				ctr: 'wigwam', 
				act: 'hire', 
				uID: App.user.id, 
				wID: App.user.worldID,
				sID: this.sid, 
				id: id, 
				energy: params.energy, 
				ids: JSON.stringify(params.friends), 
				buy: 1				
			}, onBuyAction);
			
			App.self.setOnTimer(progressToDie);
			progressToDie()
			level++;
			updateLevel();
		}*/
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (this.hasOwnProperty('capacity'))
			{
				capacity = App.data.storage[this.sid].capacity;	
			}
			
			App.self.setOnTimer(progressToDie);
			progressToDie()
			level++;
			updateLevel();
			
			if (data.hasOwnProperty('finished'))
			{
				finished = data.finished;
			}
			
			if (data.hasOwnProperty('id'))
			{
				this.id = data.id;
			}
			
			if (data.hasOwnProperty('units'))
			{
				for each (var worker:uint in data.units)
				{
					workers.push(worker)
				}
				
				workerID = Numbers.firstProp(data.units).key;
				workerSID = Numbers.firstProp(data.units).val;
			}
			
			addTip();
			
			var hasTechno:Boolean = false;
			var techno:Array = [];
			var reward:Object = info.outs;
			var _reward:Object = {};
			var worker_sid:int = App.data.storage[App.user.worldID].techno[0];
			
			for (var _sid:*in reward)
			{
				if (App.data.storage[_sid].type == 'Techno')
				{
					hasTechno = true;
					worker_sid = _sid;
				}
				else
				{
					_reward[_sid] = reward[_sid];
				}
			}
			
			Treasures.bonus(Treasures.convert(_reward), new Point(this.x, this.y));
			
			removeEffect();
			
			if (hasTechno)
				addChildrens(worker_sid, data.units);
			
			openConstructWindow();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (this.hasOwnProperty('capacity'))
			{
				capacity = App.data.storage[this.sid].capacity;	
			}
			
			App.self.setOnTimer(progressToDie);
			progressToDie()
			level++;
			updateLevel();
			
			if (data.hasOwnProperty('finished'))
			{
				finished = data.finished;
			}
			
			if (data.hasOwnProperty('id'))
			{
				this.id = data.id;
			}
			
			if (data.hasOwnProperty('units'))
			{
				for each (var worker:uint in data.units)
				{
					workers.push(worker)
				}
				
				workerID = Numbers.firstProp(data.units).key;
				workerSID = Numbers.firstProp(data.units).val;
			}
			
			addTip();
			
			var hasTechno:Boolean = false;
			var techno:Array = [];
			var reward:Object = info.outs;
			var _reward:Object = {};
			var worker_sid:int = App.data.storage[App.user.worldID].techno[0];
			
			for (var _sid:*in reward)
			{
				if (App.data.storage[_sid].type == 'Techno')
				{
					hasTechno = true;
					worker_sid = _sid;
				}
				else
				{
					_reward[_sid] = reward[_sid];
				}
			}
			
			Treasures.bonus(Treasures.convert(_reward), new Point(this.x, this.y));
			
			removeEffect();
			
			if (hasTechno)
				addChildrens(worker_sid, data.units);
			
			openConstructWindow();
		}
		
		private function addChildrens(_sid:uint, ids:Object):void
		{
			var rel:Object = {};
			rel[sid] = id;
			
			var unit:Unit;
			
			for (var i:*in ids)
			{
				var position:Object = getNearPosition();
				unit = Unit.add({sid: _sid, id: i, x: position.x, z: position.z, rel: rel});
				(unit as WorkerUnit).born();
			}
		}
		
		public function getNearPosition():Object
		{
			var object:Object = {x: info.area.w + 1, z: info.area.h - 1};
			var tries:int = 50;
			
			while (true)
			{
				var _object:Object = find();
				if (App.map._aStarNodes[_object.x] && App.map._aStarNodes[_object.x][_object.z] && !App.map._aStarNodes[_object.x][_object.z].object && App.map._aStarNodes[_object.x][_object.z].open == true)
				{
					return _object;
				}
				
				tries--;
				if (tries <= 0)
					break;
			}
			
			function find():Object
			{
				var _x:int = coords.x - 5 + int(Math.random() * (info.area.w + 10));
				var _y:int = coords.z - 5 + int(Math.random() * (info.area.h + 10));
				
				return {x: _x, z: _y}
			}
			
			return object;
		}
		
		override public function openConstructWindow(popup:Boolean = false):Boolean
		{
			return false;	
		}
		
		override public function openProductionWindow():void
		{
			
		}
		
		override public function storageEvent():void
		{
			ordered = true;
			
			if (App.user.mode == User.GUEST)
				return;
			
			slaveCount = (App.data.storage[this.sid].outs) ? App.data.storage[this.sid].outs[App.data.storage[App.user.worldID].techno[0]] : slaveCount;
			
			if ((technoToDelete.length == slaveCount && (App.user.mode != User.GUEST)))
			{
				Post.send({ctr: 'wigwam', act: 'reward', uID: App.user.id, id: id, wID: App.user.worldID, sID: this.sid}, onStorageEvent);
			}else 
			{		
				new SimpleWindow( {
					title:Locale.__e("flash:1382952379725"),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e("flash:1425466565512")
				}).show();
			}
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.visible = false;
			ordered = false;
			
			var outs:Object = Treasures.convert(info.outs)
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			uninstall();			
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			/*var state:uint = EMPTY;
			base = 0;
			
			for (var i:uint = 0; i < cells; i++)
			{
				for (var j:uint = 0; j < rows; j++)
				{
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (node.b != 0 || node.open == false)
					{
						state = OCCUPIED;
						
						break;
					}
				}
			}
			
			if (state == EMPTY)
				base = 0;
			
			if (state == OCCUPIED)
			{
				state = EMPTY;
				for (i = 0; i < cells; i++)
				{
					for (j = 0; j < rows; j++)
					{
						if (node.w != 1 || node.object != null || node.open == false)
						{
							state = OCCUPIED;
							break;
						}
					}
				}
				if (state == EMPTY)
					base = 1;
			}			
			return state;*/
			if (App.user.quests.tutorial)
			{
				
				if ((coords.x > 53 && coords.x < 59) && (coords.z > 134 && coords.z < 141))
					return EMPTY;
				else
					return OCCUPIED;
			}
			//return EMPTY;
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
		
		public function addLevel():void
		{
			var levelData:Object = textures.sprites[1];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (textures.hasOwnProperty('animation'))
			{
				addAnimation();
				startAnimation(true);
			}
		}
		
		public function addSlaves():void
		{
			var levelData:Object = textures.sprites[1];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (textures.hasOwnProperty('animation'))
			{
				addAnimation();
				startAnimation(true);
			}
		}
		
		override public function updateLevel(checkRotate:Boolean = false):void
		{
			if (level > totalLevels)
			{
				level = totalLevels;
			}
			if (textures == null)
				return;
			
			var levelData:Object = textures.sprites[level];
			
			if (levelData == null)
				levelData = textures.sprites[0];
			
			if (checkRotate && rotate == true)
			{
				flip();
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			checkOnAnimationInit();
		}
		
		public function initContent():void 
		{
			var dlist:Array = [];
			var lvlRec:int = 0;
			updtItems = Stock.notAvailableItems();
			
			var counter:int = 0;
			
			if (info.dlist)
			{
				for each(var _ditem:* in info.dlist)
				{
					dlist.push(_ditem);
				}
				proffCraft = dlist;//info.dlist;//Залили список крафтов
				
				for (var _id:String in proffCraft)
				{
					var obj:Object = proffCraft[_id];
					
					lvlRec = 0;
					
					var itemsID:int = App.data.crafting[obj].out;
					
					_arrCraft.push( { fid:obj, lvl:2, order:App.data.crafting[obj].order, sID: itemsID} );
					settings.crafting.push(obj);
					counter++;
				}
				
				_arrCraft.sortOn(['lvl', 'order'], Array.NUMERIC);
				
				craftData = _arrCraft;
			}
		}
		
		override public function checkOnAnimationInit():void
		{
			if (!textures || !textures.hasOwnProperty('animation') || Numbers.countProps(textures.animation.animations) == 0)
				return;
			if (level == totalLevels - craftLevels)
			{
				initAnimation();
				beginAnimation();
			}
			if (crafted == 0)
			{
				finishAnimation();
			}
		}
		
		
		public function checkBusy():Boolean
		{
			if (workers[0] && workers[0] != this.workerSID && this.wigwamIsBusy == 0)
				return true;
			return false;
		}
		
		public var recWin:*;
		override public function click():Boolean
		{
			var numberTechno:int = 0;
			if(App.data.storage[this.sid].b1 == 1){
				if (App.user.mode == User.OWNER)
				{
					if (checkBusy()) 
					{
						if(Wigwam.TENTS.indexOf(this.sid) != -1){
							new SimpleWindow({
								text: 			Locale.__e('flash:1495784159078',  App.data.storage[workers[0]].title), 
								height:			250,
								dialog:			true,
								confirm:function():void {
									udress();
								}
							}).show();
						}else{
							new SimpleWindow({
								text: 			Locale.__e('flash:1475076426830',  App.data.storage[workers[0]].title),
								height:			250,
								dialog:			true,
								confirm:function():void {
									if (capacity == 0) 
									{
										applyRemove = false;
										remove();
										new SimpleWindow({
											text: 		Locale.__e('flash:1475076232016',  App.data.storage[workers[0]].title),
											height:		250,
											buttonText: Locale.__e('flash:1382952380298'),
											hasExit: 	false
											
										}).show();
									}else
										udress();
								}
							}).show();
						}
					}else if(workers[0] != this.workerSID)
					{
						if(Wigwam.TENTS.indexOf(this.sid) != -1){
							new SimpleWindow({
								text: 		Locale.__e('flash:1495784548089', [String(App.data.storage[workers[0]].title),String(App.data.storage[App.data.crafting[wigwamIsBusy].out].title)]),
								height:		250
							}).show();
						}else{
							new SimpleWindow({
								text: 		Locale.__e('flash:1475076616493', [String(App.data.storage[workers[0]].title),String(App.data.storage[App.data.crafting[wigwamIsBusy].out].title)]),
								height:		250
							}).show();
						}
					}else 
					{
						var that:Wigwam = this;
						
						if (Wigwam.TENTS.indexOf(this.sid) != -1)
						{
							recWin = new TentEquipWindow( {
								title:info.title,
								fID:craftData[numberTechno].fid,
								busy:false,
								hasDescription:true,
								hasAnimations:false,
								craftData:craftData,
								prodItem:this,
								sID:craftData[numberTechno].sID,
								target:this,
								wID:workerID,
								wSID:workerSID
							});
						}else{
							recWin = new TechnoRecipeWindow( {
								title:info.title,
								fID:craftData[numberTechno].fid,
								busy:false,
								hasDescription:true,
								hasAnimations:false,
								craftData:craftData,
								prodItem:this,
								sID:craftData[numberTechno].sID,
								target:this,
								wID:workerID,
								wSID:workerSID
							});
						}
						recWin.focusAndShow();
						return true;
					}
				}
			}else{
				//Ничего
			}
			return false;
		}
		
		public function udress():void 
		{
			Post.send({
				ctr:this.type,
				act:'undress',
				uID:App.user.id,
				//tSID:App.data.storage[App.data.crafting[settings.fID].out].sID,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}, function(error:int, data:Object, params:Object):void 
			{
				if (data)
				{
					changeWorker(data.worker);
					
					if (info.capacity != 0)
					{
						capacity = data.capacity;
						checkCapacity();
					}
				
				}
			});	
		}
		
		public function checkCapacity():void
		{
			if (info.capacity != 0 && capacity <= 0) 
			{
				var text:String;//flash:1501682780339
				this.applyRemove = false;
				this.remove();
				switch (this.info.sID)
				{
					case 2177:
						text = Locale.__e('flash:1501682780339',  App.data.storage[this.workers[0]].title);
					break;
					default:
						text = Locale.__e('flash:1475076232016',  App.data.storage[this.workers[0]].title);
						break;
					
				}
				
				new SimpleWindow({
					text: 		text, //"Потрачено! " + App.data.storage[obj.sid].title + " был сожжен, " + App.data.storage[obj.workers[0]].title + " сгорел заживо!",
					height:		250,
					buttonText:	Locale.__e('flash:1382952380298'),
					hasExit: 	false
					
				}).show();
			}
		}
		
		public function openProfession( sidTechno:int = 0, focus:Boolean = false, craftItemID:int = 0, craftItemSID:int = 0):Boolean
		{
			var numberTechno:int = 0;
			for each(var obj:* in craftData){
				if (obj.sID == sidTechno)
					numberTechno = obj.order;
			}
			
			if (App.user.mode == User.OWNER)
			{
				if (workers[0] != this.workerSID) 
				{
					new SimpleWindow({
						text: 			"Нового рабочего можно будет нанять только тогда, когда " + App.data.storage[workers[0]].title + " закончит работу!",
						height:			250
					}).show();
					
				}else 
				{
					var that:Wigwam = this;
					if (Wigwam.TENTS.indexOf(this.sid) != -1)
					{
						recWin = new TentEquipWindow( {
							title:info.title,
							fID:craftData[numberTechno].fid,
							busy:false,
							hasDescription:true,
							hasAnimations:false,
							craftData:craftData,
							prodItem:this,
							sID:craftData[numberTechno].sID,
							target:this,
							wID:workerID,
							wSID:workerSID
						});
						recWin.show();
						recWin.onSecond();
					}else{
						recWin = new TechnoRecipeWindow( {
							title:info.title,
							fID:craftData[numberTechno].fid,
							busy:false,
							hasDescription:true,
							hasAnimations:false,
							craftData:craftData,
							prodItem:this,
							sID:craftData[numberTechno].sID,
							target:this,
							wID:workerID,
							wSID:workerSID
						});
						if (craftItemID != 0 && craftItemSID != 0)
						{
							recWin.settings['returnBuildID'] = craftItemID;
							recWin.settings['returnCraft'] = craftItemSID;
						}
						
						/*if (focus)
						{
							recWin.focusAndShow();
						}else
						{*/
						recWin.show();
						//}
					}
					
					
					
					
					return true;
				}
			}
			return false;
		}
		
		override public function install():void 
		{
			App.map.addUnit(this);
			
			if (wigwams.indexOf(this) == -1)
				wigwams.push(this);
		}
		
		override public function uninstall():void
		{
			//var unitToDelete:Unit = Map.findUnit(this.workerSID, this.workerID);
			//if (unitToDelete)
				//unitToDelete.uninstall();
			//if (unitToDelete)
				//unitToDelete = null;
			workers = [];
			if (wigwams.indexOf(this) > -1)
				wigwams.splice(wigwams.indexOf(this), 1);
			super.uninstall();
			
		}
	}
}