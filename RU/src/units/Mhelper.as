package units 
{
	import core.Post;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import ui.Cursor;
	import ui.Hints;
	import ui.UnitIcon;
	import wins.MhelperWindow;
	import wins.SimpleWindow;

	public class Mhelper extends Building
	{
		public static const READY:int = 1;
		public static const UNREADY:int = 2;
		public static const UNBOOST:int = 3;
		public static const BOOST:int = 4;		
		public static const MHELPER_FIRST:int = 2372;		
		public static const MHELPER_UNDINE:int = 2664;
		public static const MHELPER_TRIBUTE:int = 2764;
		
		public static var letsFindUndinesInsde:int = 0;
		
		public var stacks:uint = 0;
		public var noBoostJson:Object;
		public var noBoostArray:Array;
		
		public function Mhelper(object:Object) 
		{
			super(object);
			object.slots = object.slots || 0;
			stacks = object.slots;
			this.info['moveable'] = 0;
			stockable = false;	
			touchableInGuest = false;
			
			if (object.units)
			{
				for (var index:String  in object.units)
				{
					var item:Object = object.units[index];
					item['info'] = App.data.storage[item.sid];
					targets[index] = item;
					
					//Костыль
					if (object.sid == MHELPER_UNDINE) 
					{
						letsFindUndinesInsde++;
					}
				}
			}
			
			if (App.user.mode == User.GUEST) 
			{				
				flag = false;
			}
			
			tip = function():Object {
				return {
					title:		info.title,
					text: info.description
				};
			}
		}
		
		override public function showIcon():void
		{			
			if (App.user.mode == User.OWNER)
			{
				drawIcon(UnitIcon.REWARD, 26, 1, {
					glow: true,
					iconDX: -35,
					iconDY: -80
				});				
			}
		}
		
		override public function onLoad(data:*):void
		{
			super.onLoad(data);
			initAnimation();
			startAnimation();
		}
		
		public function get targetsLength():int
		{
			var re:int = 0;
			for (var i:String in targets)
				re++;
			return re;
		}
		
		private function onMapComplete(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
		}
		
		public var targets:Array = [];
		
		public function get posibleTargets ():Array
		{	
			//Костыль
			var arr: Array = [];
			if (sid == MHELPER_FIRST) 
			{
				arr = Map.findUnitsByType(["Walkgolden", "Golden"]);
			}else if (sid == MHELPER_TRIBUTE) 
			{
				arr = Map.findUnitsByType(["Tribute"]);
			}else if(sid == MHELPER_UNDINE)
			{
				arr = Map.findUnitsByType(["Golden"]);
			}
			
			var result:Array = [];
			
			for each (var key:Object in arr)
				if ((!App.data.storage[key.sid].hasOwnProperty('capacity') || App.data.storage[key.sid].capacity == 0) ) 
				{//Костыль
					/*if (info.sID == MHELPER_FIRST) 
					{
						if (key.sid != Golden.UNDINE && key.sid != Golden.PORT_SHOP) 
						{
							result.push (key.sid);
						}
					}else if (info.sID == MHELPER_UNDINE) 
					{
						if (key.sid == Golden.UNDINE && key.sid != Golden.PORT_SHOP) 
						{
							result.push (key.sid);
						}						
					}else if (info.sID == MHELPER_TRIBUTE) 
					{
						result.push (key.sid);						
					}*/
				}
			return result;
		}
		
		public function getTime (item:Object):int
		{
			return item.crafted - App.time;
		}
		
		public function cheackState(object:Object):Object 
		{
			noBoostJson = JSON.parse(App.data.options.noBoost);
			noBoostArray = noBoostJson.sid;
			
			var re:Object = { };
			
			if (getTime(object) < 10)
			{
				re['isReady'] = READY;
			}else
			{
				re['isReady'] = UNREADY;
			}
			
			if (object.info.block || object.info.type == "Changeable" || noBoostArray.indexOf(object.info.sID) != -1)//Не ускорять
			{
				re['isBoost'] = UNBOOST;
			}else
			{
				re['isBoost'] = BOOST;
			}
			return re;
		}

		public function getPriceItems (object:Object = null):int
		{
			if ( object )
			{
				return object.priceSpeed || object.info.speedup || object.info.skip;
			}
			
			var re:int = 0;
			
			for each(var item:Object in targets)
			{
				var check:Object = cheackState(item);
				if (check.isBoost == BOOST && check.isReady == UNREADY)
					re += item.priceSpeed || item.info.speedup || item.info.skip;
			}
			return re;
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST)
				return false;
			new MhelperWindow( { target:this } ).show();
			return true;
		}
		
		public function findBoost():Object
		{
			var re:Object = {};
			for each (var item:Object in targets)
			{
				var check:Object = cheackState(item);
				if (check.isBoost == BOOST && check.isReady == UNREADY)
					re [targets.indexOf (item)] =  item.sid;
			}
			return re;
		}
		
		public function findCollect():Object
		{
			var re:Object = { };
			for each (var item:Object in targets)
			{
				var check:Object = cheackState(item);
				if (check.isReady == READY)
					re [targets.indexOf (item)] =  item.sid;
			}
			return re;
		}
		
		public static var chooseTargets:Array = [];
		public static var clickCounter:int = 0;
		
		public function startAttch():void
		{
			chooseTargets = [];
		}
		
		public function onCancel():void
		{
			App.ui.upPanel.hideHelp();
			App.ui.upPanel.hideCancel();
			Cursor.type = 'default';
			unselectTargets();
			itsMhelperForTributes = false;
			itsMhelperForUndines = false;
			itsRegularMhelper = false;
			waitWorker = null
		}
		
		public function unselectTargets():void
		{
			var _posibleTargets:Array = Map.findUnits(posibleTargets);
			for each(var res:* in _posibleTargets)
			{
				if (res.state == res.HIGHLIGHTED) 
				{
					res.state = res.DEFAULT;
					
				}
				res.helperLock = false;
			}
			lockTargets();
		}
		
		public function unselectPossibleTargets(e:MouseEvent = null):void
		{			
			if (App.self.moveCounter > 3)
				return;
			
			if (itsMhelperForTributes)
				return;
			if (itsMhelperForUndines)
				return;
			if (itsRegularMhelper)
				return;
			
			App.self.removeEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			App.ui.upPanel.hideHelp();
			App.ui.upPanel.hideCancel();
			Cursor.type = 'default';
			unselectTargets();		
			itsMhelperForTributes = false;
			itsMhelperForUndines = false;
			itsRegularMhelper = false;
			waitWorker = null;
		}
		
		private function lockTargets():void
		{
			return;
		}
		
		public function onConfirm():void
		{
			attachAction();
			App.ui.upPanel.hideHelp();
			App.ui.upPanel.hideCancel();
			Cursor.type = 'default';
			unselectTargets();
			itsMhelperForTributes = false;
			itsMhelperForUndines = false;
			itsRegularMhelper = false;
			waitWorker = null
		}
		
		public static var waitWorker:Mhelper;
		
		public static function addTarget(target:*):void 
		{			
			if ((itsMhelperForTributes || itsMhelperForUndines || itsRegularMhelper) &&  chooseTargets.length + waitWorker.targetsLength < waitWorker.stacks && chooseTargets.indexOf(target) == -1)
			{
				chooseTargets.push(target);
			}
			
			if (chooseTargets.length + waitWorker.targetsLength >= waitWorker.stacks) 
			{
				App.ui.upPanel.hideCancel();
				Cursor.type = 'default';
				itsMhelperForTributes = false;
				itsMhelperForUndines = false;
				itsRegularMhelper = false;
				
				if (waitWorker) 
				{
					var targets:Object = [];
					
					for each (var unit:* in chooseTargets)
					{
						var object:Object = { };
						object[unit.sid] = unit.id;
						targets.push(object);
						
					}
					
					waitWorker.attachAction();
				}
			}else {
				App.ui.upPanel.showHelp(Locale.__e('flash:1456159293680') + ' ' + (chooseTargets.length + waitWorker.targetsLength) + "/" +  waitWorker.stacks, 0);//Выбрано
			}
		}
		
		public function attachAction():void 
		{
			if (!chooseTargets || chooseTargets.length < 1)
				return;
			
			var _target:Array = [];
			
			for each ( var item:Object in  chooseTargets)
			{				
				_target.push( { sID:item.sid, ID:item.id } );
			}
			
			var that:Mhelper = this;
			
			Post.send({
				ctr:this.type,
				act:'attach',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				units:JSON.stringify(_target)
			}, function(error:*, data:*, params:*):void {
				for each (var item:Object in chooseTargets)
				{
					that.targets[that.targets.length] = { sid:item.sid, id:item.id, info: App.data.storage[item.sid], crafted: item.crafted , started: item.started }; // извращуга
					item.uninstall();
					/*if (item.sid == Golden.UNDINE) 
					{
						letsFindUndinesInsde++;
					}*/
				}
				chooseTargets = [];
			});
		}
		
		public function startDetach(item:Object, win:MhelperWindow = null):void
		{
			waitWorker = this;
			detachIID = targets.indexOf(item);
			item['id'] = 0;
			item['fromMhelper'] = true;
			item.info['moveable'] = false;
			var unit:Unit = add(item);
			unit.move = true;
			App.map.moved = unit;			
		}
		
		public function stopDetach():void
		{
			waitWorker = null;
			detachIID = -1;
		}
		
		public var detachIID:int = -1;
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			stacks = info.start;
		}
		
		public static function detachAction(item:Object):void
		{
			if (waitWorker.detachIID < 0) return;
			
			item.fromMhelper = false;
			
			Post.send({
				ctr:waitWorker.type,
				act:'detach',
				uID:App.user.id,
				id:waitWorker.id,
				wID:App.user.worldID,
				sID:waitWorker.sid,
				iID:waitWorker.detachIID,
				x:item.coords.x,
				z:item.coords.z
				}, function(error:*, data:*, params:*):void {
				
				if (!error && data) 
				{
					var tempArr:Array = new Array();
					for (var index:String in waitWorker.targets)
					{
						if ( int (index) != waitWorker.detachIID )
							tempArr[index] = waitWorker.targets[index];
					}
					
					waitWorker.targets.length = 0;
					waitWorker.targets = tempArr;
					item.beginCraft(0, item.crafted);
					waitWorker.detachIID = -1;
					item.moveable = true;
					waitWorker = null;
					
					if (item.info.type == 'Walkgolden' && item.contLight) {
						item.removeChild(item.contLight);
						item.contLight = null;
					}
					if (item.info.type == 'Golden')
					{
						item.initAnimation();
						item.beginAnimation();
					}
					
					/*if (item.info.sID == Golden.UNDINE) 
					{
						letsFindUndinesInsde--;
					}*/
					
					if (data.hasOwnProperty('id'))
						item.id = data.id;
				}
				
			});
		}
		
		public function speedAction(win:MhelperWindow, item:Object = null):void 
		{
			var queryString:String = '';
			
			if (!item)
				queryString = JSON.stringify(findBoost());
			else
				queryString = JSON.stringify({(targets.indexOf (item)):  item.sid});
			
			if ( App.user.stock.take(Stock.FANT,getPriceItems(item)) )
			{
				Post.send({
					ctr:this.type,
					act:'speedin',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					units:queryString
				}, function(error:*, data:*, params:*):void {
					var point:Point = new Point (App.self.stage.mouseX, App.self.stage.mouseY);
					Hints.minus(Stock.FANT,getPriceItems(item), point,true,win);
					if (!error && data) 
					{
						for (var index:String in data.crafted)
						{
							if (targets[index].info.type == 'Golden')
								targets[index].started = App.time - targets[index].info.time;
							else
								targets[index].started = targets[index].crafted;
							targets[index].crafted = data.crafted[index];
						}
					}
					win.contentChange();
					win.blockAll(false);
				});
			}
		}
		
		public static var itsRegularMhelper:Boolean = false;
		public static var itsMhelperForUndines:Boolean = false;
		public static var itsMhelperForTributes:Boolean = false;
		
		public function collectAction(win:MhelperWindow, item:Object = null):void 
		{
			var queryString:String = '';
			var fin:Object = findCollect();
			if (!item)
				queryString = JSON.stringify(fin);
			else
				queryString = JSON.stringify({(targets.indexOf (item)):  item.sid});
			
			var that:Object = this;
			
			Post.send({
				ctr:this.type,
				act:'collectin',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				units:queryString
			}, function(error:*, data:*, params:*):void {				
				if (!error && data) 
				{
					var point:Point = new Point (App.self.stage.mouseX, App.self.stage.mouseY);
					var tempBonus:Object = { };
					
					for (var _sid:String in data.bonus)
					{
						for (var _instance:String in data.bonus[_sid])
						{
							tempBonus[_sid] = int( data.bonus[_sid][_instance]) * int (_instance);
						}
					}
					
					Hints.plusAll(tempBonus, point, win);
					
					for each (var index:String in data.units)
					{
						that.targets[index].started = App.time; 
						that.targets[index].crafted = App.time + App.data.storage[that.targets[index].sid].time;
					}
					
					Treasures.bonus(data.bonus, new Point(that.x, that.y),null,true,null,null);
					SoundsManager.instance.playSFX('bonus');					
				}
				win.contentChange();
				win.blockAll(false);
			});
		}
		
		public function extendAction (win:MhelperWindow):void 
		{
			for (var ins:Object in info.extra)
				break;
			if ( targetsLength < info.stacks && App.user.stock.take (int(ins), info.extra[ins]))
			{
				var that:Mhelper = this;
				var point:Point = new Point (App.self.stage.mouseX, App.self.stage.mouseY);
				Hints.minus(int(ins), int(info.extra[ins]), point, true, win);
				Post.send({
					ctr:this.type,
					act:'extend',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) 
					{
						that.stacks++;
					}
					win.contentChange();
					win.blockAll(false);
				});
			}
		}
		
		override public function putAction():void
		{
			if (targetsLength > 0 )
			{
				new SimpleWindow( {
					hasTitle:true,
					title:info.title,
					text:Locale.__e("flash:1457260686688"),//Предупреждение при удалении если в объекте есть декор
					label:SimpleWindow.ATTENTION,
					dialog:true,
					isImg:true,
					height:250,
					confirm:function():void {
						click();
					}
				}).show();
				return;
			}
			
			if (!stockable)
			{
				return;
			}
			
			uninstall();
			App.user.stock.add(sid, 1);
			
			Post.send({ctr: this.type, act: 'put', uID: App.user.id, wID: App.user.worldID, sID: this.sid, id: this.id}, function(error:int, data:Object, params:Object):void
			{});
		}
		
		override public function remove(_callback:Function = null):void 
		{
			var callback:Function = _callback;
			
			if (!removable) return;
			
			if (targetsLength > 0 )
			{
				new SimpleWindow( {
					hasTitle:true,
					title:info.title,
					text:Locale.__e("flash:1457260686688"),//Предупреждение при удалении если в объекте есть декор
					label:SimpleWindow.ATTENTION,
					dialog:true,
					isImg:true,
					height:250,
					confirm:function():void {
						click();
					}
				}).show();
				return;
			}	
			
			if (info && info.hasOwnProperty('ask') && info.ask == true)
			{
				new SimpleWindow( {
					hasTitle:true,
					title:Locale.__e("flash:1382952379842"),//Удалить?
					text:Locale.__e("flash:1382952379968", [info.title]),//Вы действительно хотите удалить?
					label:SimpleWindow.ATTENTION,
					dialog:true,
					isImg:true,
					confirm:function():void {
						onApplyRemove(callback);
					}
				}).show();
			}
			else
			{
				onApplyRemove(callback)
			}
		}
		
		override public function setFlag(value:*, callBack:Function = null, settings:Object = null):void
		{
			return;
		}
	}	
}