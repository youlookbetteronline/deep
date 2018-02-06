package units 
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Load;
	import core.Numbers;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.SystemPanel;
	import utils.Locker;
	import wins.BuildingConstructWindow;
	import wins.ConstructWindow;
	import wins.SharkWindow;
	import wins.SimpleWindow;
	import wins.WindowEvent;
	
	public class Bridge extends Building
	{
		public static var bridges:Object;
		public var line:String;
		public var openingZone:uint = 0;
		public var hasSpirit:Boolean = false;
		public var zID:uint;
		
		public function Bridge(object:Object)
		{
			if (object.id)
				line = getLine(this, object.x, object.z);
				
			layer = Map.LAYER_SORT;
			/*if (object.sid == 776)// || object.sid == 851
				layer = Map.LAYER_LAND;*/
				
			if (object.hasOwnProperty('hasSpirit'))
			{
				this.hasSpirit = object.hasSpirit;
				//this.unitParams['hasSpirit'] = true;
			}
				
			if (object.hasOwnProperty('openingZone'))
				this.openingZone = object.openingZone;
				
			super(object);
			touchableInGuest = false;
			//popupBalance.visible = false;
			if (Config.admin)
			{
				if (formed)	
					moveable = true;
				multiple = false;
				rotateable = true;
				removable = true;
			}
			else{
				if (formed)	
					moveable = false;
				multiple = false;
				rotateable = false;
				removable = false;
				stockable = false;
			}
			
			if (hasSpirit)
			{
				touchable = false;
				visible = false;
				free();
			}
			
			
			////trace('{x:' + coords.x + ', z:' + coords.z + ', id:'+object.id+', view:'+info.view+' }');
			
			/*if (formed)
			{
				if(info.side == 1 || info.side == 2 || info.view == 'pier')
					App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			}*/
			
			if (hasSpirit && !unit)
				drawSpririt({
					x:coords.x,
					z:coords.z
				});
		}
		
		override public function set visible(value:Boolean):void 
		{
			if (hasSpirit)
				super.visible = false;
			else
				super.visible = value;
		}
		
		private function getLine(bridge:Bridge, _x:int, _z:int):String 
		{
			for (var lineName:String in bridges) 
			{
				for each(var object:Object in bridges[lineName]) 
				{
					if (object.x == _x && object.z == _z) 
					{
						return lineName;
					}
				}
			}
			return null;
		}
		override public function showIcon():void 
		{
			if (hasSpirit)
				return;
			super.showIcon();
		}
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			super.onUpgradeEvent(error, data, params);
			// ѕровер¤ем при flash:1382952379984вершении строительства
			if (level == totalLevels)
			{
				//level++;
				//free();
				take();
				//level--;
				if (this.sid == 1657)
				{
					var travelRailing:Unit = Unit.add( {gift:false, sid:1699, buy:true, x:79, z:112 } );
					travelRailing.buyAction();
					travelRailing.take();
				}
				if (this.sid == 2403)
				{
					var travelRailing2:Unit = Unit.add( {gift:false, sid:2413, buy:true, x:55, z:22} );
					travelRailing2.buyAction();
					travelRailing2.take();
				}
				if (this.sid == 3145)
				{
					var travelRailing3:Unit = Unit.add( {gift:false, sid:3146, buy:true, x:101, z:88} );
					travelRailing3.buyAction();
					travelRailing3.take();
				}
				if (this.sid == 808)
				{
					var railing:Unit = Unit.add( {gift:false, sid:929, buy:true, x:87, z:27 } );
					railing.buyAction();
					railing.take();
					
					var far_1:Unit = Unit.add( {gift:false, sid:927, buy:true, x:83, z:50 } );
					far_1.buyAction();
					far_1.take();
					
					var far_2:Unit = Unit.add( {gift:false, sid:928, buy:true, x:82, z:19 } );
					far_2.buyAction();
					far_2.take();
					
					var close_1:Unit = Unit.add( {gift:false, sid:925, buy:true, x:88, z:50 } );
					close_1.buyAction();
					close_1.take();
					
					var close_2:Unit = Unit.add( {gift:false, sid:926, buy:true, x:87, z:20 } );
					close_2.buyAction();
					close_2.take();
				}
				/*if (check()) {
					for each(var bridge:Object in bridges[line]){
						var _bridge:* = App.map._aStarNodes[bridge.x][bridge.z].object;
						if(_bridge is Bridge && _bridge.info.side == 0)
							App.ui.flashGlowing(_bridge);
					}	
				}*/
				if (openingZone != 0 && App.data.storage[openingZone].type == 'Zones')
				{
					App.user.world.openZone(openingZone);
				}
				else{
					if (App.data.storage[this.sid].require && App.data.storage[Numbers.firstProp(info.require).val].type == 'Zones')
					{
						App.user.world.openZone(Numbers.firstProp(info.require).val);
					}
				}
				if (App.data.storage[this.sid].hasOwnProperty('delete') && App.data.storage[this.sid]['delete'] == 0)
				{
					//if (App.data.storage[this.sid]['delete'] == 0)
						this.removable = true;
						this.applyRemove = false;
						this.remove();
						this.removedd = true;
						
				}else{
					if(Map.ready)
						drawLastLevel();
					else
						App.self.addEventListener(AppEvent.ON_MAP_COMPLETE,drawLastLevel)
				}
			}	
		}
		private var removedd:Boolean = false;
		override public function remove(_callback:Function = null):void 
		{
				super.remove(_callback);
		}
		
		override public function updateLevel(checkRotate:Boolean = false):void 
		{
			super.updateLevel(checkRotate)
			
			if (!formed) return;
			if (level != totalLevels) return;
			
			if (info.side == 1 || info.side == 2) 
			{
				var _x:int = 0;
				var _z:int = 0;
				if(rotate)
				{
					_x = coords.x + info.area.h;
					_z = coords.z ;
				}
				else
				{
					_x = coords.x;
					_z = coords.z + info.area.h;
				}
				
				
				var front:Bridge = new Bridge( {
					sid:info.front,
					x:_x,
					z:_z,
					rotate:this.rotate
				});
				
				front.clickable = false;
				front.touchable = false;
			}
			
			clickable = false;
			touchable = false;
		}
		
		public function onMapComplete(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			check();
		}
		
		private function check():Boolean 
		{
			if (info.view != 'pier')
			{
				// ѕровер¤ем собрана ли лини¤
				if (!isLineComplete(line, 'light')) 
					return false;
					
				// выстраеваем тайлики	
				//buildBridgeTiles();
				
			}else 
			{
				if(!isPierComplete())
					return false;
			}
			
			// освобождаем путь
			
			//unlock(bridges[line]);
			return true;
		}
		
		public function isPierComplete():Boolean 
		{
			var complete:Boolean = true;
			for (var i:int = 0; i < bridges['line1'].length; i++) 
			{
				var place:Object = bridges['line1'][i];
				if (App.map._aStarNodes[place.x][place.z].object is Bridge) {
					
				}else {
					complete = false;
				}
			}
			return complete;
		}
		
		public function isLineComplete(line:String, type:String = 'light'):Boolean 
		{
			var complete:Boolean = false;
			if (type != 'light')
				return complete;
			
			var _bridges:Array = Map.findUnitsByType(['Bridge']);
			var lineBridges:Array = [];
			
			for each(var _bridge:Bridge in _bridges) {
				if (_bridge.line == line)
					lineBridges.push(_bridge);
			}
			
			_bridge = null;
			
			complete = true;
			for each(_bridge in lineBridges) {
				if (_bridge.info.side == 1 || _bridge.info.side == 2) {
					if (_bridge.level != _bridge.totalLevels)
						complete = false;
				}
			}
			
			return complete;
			
			for each(var place:Object in bridges[line]) 
			{
				var object:* = App.map._aStarNodes[place.x][place.z].object;
				if (object != null && object is Bridge) {
					
				}
				else
				{
					return false;
				}
			}
			
			unlock(bridges[line]);
			return true;
		}
		
		public function buildBridgeTiles():void 
		{
			var _tile:int = 631;
			if (info.front == 850 || info.front == 848)
				_tile = 851;
			
			for (var i:int = 1; i < bridges[line].length - 1; i++) {
				var _x:int = bridges[line][i].x;
				var _z:int = bridges[line][i].z;
				var _rotate:int = bridges[line][i].rotate;
				//if (App.map._aStarNodes[_x][_z].object == null) {
					var tile:Bridge = new Bridge( {
						sid:_tile,
						rotate:_rotate,
						x:_x,
						z:_z,
						hasSpirit:false
					});
					tile.clickable = false;
					tile.touchable = false;
					tile.take();
				/*}
				else
				{
					return;
				}*/
			}
			///bridges[line] = [bridges[line][0], bridges[line][bridges[line].length - 1]];
		}
		
		override public function onAfterBuy(e:AppEvent):void
		{
			super.onAfterBuy(e);
			
			// назначаем к какой линии принадлежит мост
			for (var i:int = 0; i < possiblePlaces.length; i++) {
				var place:Object = possiblePlaces[i].place;
				if (place.x == coords.x && place.z == coords.z) {
					line = possiblePlaces[i].line;
				}
			}
			//if(line != null)
				//Bridge.checkLine(line);
			hideSpirits();
		}
		
		public function drawLastLevel():void 
		{
			if (sid != 808)
				return;
			if (App.self.hasEventListener(AppEvent.ON_MAP_COMPLETE))
			{
				App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, drawLastLevel);
			}
			App.map.bitmap.bitmapData.draw(this, new Matrix(1, 0, 0, 1, this.x -App.map.bitmap.x, this.y-App.map.bitmap.y));
			uninstall();
		}
		
		public function hideSpirits():void {
			possiblePlaces = [];
			for each(var spirit:SpiritZone in spirits)
				spirit.uninstall();
				//App.map.mLand.removeChild(spirit);
				
			spirits = [];
		}
		
		public var possiblePlaces:Array = [];
		public var spirits:Array = [];
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			if (this.level == this.totalLevels)
			{
				
				if (App.data.storage[this.sid].hasOwnProperty('delete') && App.data.storage[this.sid]['delete'] == 0 && !removedd)
				{
					if (App.data.storage[this.sid].require && App.data.storage[info.require[0]].type == 'Zones')
					{
						App.user.world.openZone(App.data.storage[this.sid].require[0]);
					}
					//if (App.data.storage[this.sid]['delete'] == 0)
					this.removable = true;
					this.applyRemove = false;
					this.remove();
				}else{
					drawLastLevel();
				}
				/*setTimeout(function():void{
					if (App.data.storage[this.sid].require)
					{
						App.user.world.openZone(App.data.storage[this.sid].require[0]);
					}
					if (App.data.storage[this.sid].hasOwnProperty('delete') && App.data.storage[this.sid]['delete'] == 0)
					{
						//if (App.data.storage[this.sid]['delete'] == 0)
							this.removable = true;
							this.applyRemove = false;
							this.remove();
					}
				}, 4000);*/
			}
				
			/*if (info.view == 'pier') {
				defindLevel();
			}*/
		}
		
		public var unit:SpiritZone;
		private function drawSpririt(nextPlace:Object):void 
		{
			//return;
			//var _loc_2:* = IsoConvert.screenToIso(this.x, this.y, true);
			//var place:Object = {x:coords.x, z:coords.z};
			var sSID:int = 1234;//стандартная акула
			if (this.sid == 1717)
				sSID = 1713;//москиты
			if (this.sid == 1719 || this.sid == 2036)
				sSID = 1309;//акула
			if (this.sid == 1721)
				sSID = 1714;//пирака 1
			if (this.sid == 1720)
				sSID = 1708;//пирака 2
			unit = new SpiritZone( { id:this.id, sid:sSID, x:this.coords.x, z:this.coords.z, target:this } );
			//setTimeout(function():void 
			//{
			unit.goHome();
			//}, 5000);
			//App.map.mLand.addChild(unit);
			//this.unit.take();
			//var levelData:Object = textures.sprites[this.level];
			//var place:Object = IsoConvert.isoToScreen(nextPlace.x, nextPlace.z, true);
			//var spirit:Spirit = new Spirit(levelData.bmp);
			//spirit.x = place.x + levelData.dx;
			//spirit.y = place.y + levelData.dy;
			
			//App.map.mLand.addChildAt(spirit, 0);
			//spirit.showGlowing();
			spirits.push(unit);
			
			//if (id == 0)
				//App.map.focusedOn(unit);
		}	
		
		public function defindLevel():void 
		{
			var place:Object
			if (formed) {
				place = {
					x:coords.x,
					z:coords.z
				}
			}
			else
			{
				possiblePlaces = Bridge.findPlaceBridges(info.view);
				if (possiblePlaces.length == 0)
					return;
					
				place = possiblePlaces[0].place;	
			}
			
			for (var j:int = 0; j<bridges['line1'].length; j++) {
				if (place.x == bridges['line1'][j].x) {
					if (place.z == bridges['line1'][j].z) {
						if (j == 0)
							level = 0;
						else if (j == bridges['line1'].length - 1)	
							level = 2;
						else
							level = 1;
					}
				}
			}
			updateLevel();
			
			//if (hasSpirit && !formed)
				//drawSpririt(place);
		}
		
		/*override public function calcDepth():void {
			
			var left:Object;
			var right:Object;
			
			if (info.side == 1 || info.side == 2) {
				left = { x:x - IsoTile.width * 1 * .5, y:y + IsoTile.height * 1 * .5 };
				right = { x:x + IsoTile.width * 1 * .5, y:y + IsoTile.height * 1 * .5 };
				depth = (left.x + right.x) + (left.y + right.y) * 100;
				return;
			}
			
			if (info.side == 0) 
			{
				left = { x:x, y:y + 50};
				right = { x:x, y:y + 50};
				depth = (left.x + right.x) + (left.y + right.y) * 100;
				return;
			}
			
			super.calcDepth();
		}*/
		
		override public function uninstall():void 
		{
			hideSpirits();
			super.uninstall();
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			return EMPTY;
			/*if (info.view == 'pier') 
			{
				var check:Boolean = false;
				for each(var place:Object in possiblePlaces) {
					if (place.place.x == coords.x && place.place.z == coords.z) {
						
						check = true;
					}
				}
				if (!check) return OCCUPIED;
			}*/
			
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (node.open == false || node.object != null) {//node.w != 1 || 
						return OCCUPIED;
					}
				}
			}
			
			return EMPTY;
		}
		public var fromSpirit:Boolean = false;
		override public function click():Boolean
		{
			if (hasSpirit && !fromSpirit)
				return false;
			
			if (!clickable || id == 0 || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			
			
			if (needQuest != 0)
			{
				if (!App.user.quests.data.hasOwnProperty(needQuest))
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1481879219779"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1481878959561', App.data.quests[needQuest].title)
					}).show();
					return false;
				}
			}
			
			if (this.sid == 1657)
			{
				var node:AStarNodeVO = App.map._aStarNodes[77][136];
				if (!node.sector.open)
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1495607052980') + " " + info.title
					}).show();
					return false;
				}
			}
			
			if (this.sid == 3145)
			{
				var node2:AStarNodeVO = App.map._aStarNodes[102][119];
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
				if (!node2.sector.open)
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1495607052980') + " " + info.title,
						confirm: function():void
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
			
			if (App.user.useSectors)//Москиты и акула
			{
				var node1:AStarNodeVO = null;
				if (App.user.worldID == User.TRAVEL_LOCATION)
				{
					switch(this.id)
					{
						case 1:
							node1 = App.map._aStarNodes[77][136];
							break;
						case 3:
							node1 = App.map._aStarNodes[43][107];
							break;
						case 4:
							node1 = App.map._aStarNodes[148][141];
							break;
						case 5:
							node1 = App.map._aStarNodes[110][55];
							break;
						case 6:
							node1 = App.map._aStarNodes[121][130];
							break;
						case 7:
							node1 = App.map._aStarNodes[145][80];
							break;
						case 8:
							node1 = App.map._aStarNodes[86][75];
							break;
						case 9:
							node1 = App.map._aStarNodes[180][136];
							break;
						case 10:
							node1 = App.map._aStarNodes[35][75];
							break;
						case 11:
							node1 = App.map._aStarNodes[81][16];
							break;
					}
				}
				
				if (App.user.worldID == User.HUNT_MAP)
				{
					switch(this.id)
					{
						case 1:
							node1 = App.map._aStarNodes[75][50];
							break;
					}
				}
				if (App.user.worldID == User.FARM_LOCATION)
				{
					switch(this.id)
					{
						case 4:
							node1 = App.map._aStarNodes[26][31];//+
							break;
						case 5:
							node1 = App.map._aStarNodes[67][87];//+
							break;
						case 8:
							node1 = App.map._aStarNodes[46][136];//+
							break;
						case 9:
							node1 = App.map._aStarNodes[87][42];//+
							break;
						case 10:
							node1 = App.map._aStarNodes[46][51];//+
							break;
						case 11:
							node1 = App.map._aStarNodes[53][113];//+
							break;
						case 12:
							node1 = App.map._aStarNodes[67][151];//+
							break;
					}
				}
					
				if (node1 && !node1.sector.open)
				{
					new SimpleWindow( {
						title	:Locale.__e("flash:1474469531767"),
						label	:SimpleWindow.ATTENTION,
						text	:Locale.__e('flash:1495607052980') + " " + info.title,
						confirm:function():void
						{
							node1.sector.fireNeiborsReses();
						}
					}).show();
					return false;
				}
			}
			/*if (!Config.admin && this.sid == 1095)
			{
				new SimpleWindow( {
				title:Locale.__e("flash:1474469531767"),
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1481899130563')
				}).show();
				return false;
			}*/
			
			if (hasSpirit)
				fromSpirit = false;
			
			App.tips.hide();
			
			if (level < totalLevels) 
			{
				if (App.user.mode == User.OWNER)
				{
					openConstructWindow();
					/*var inst:int = instanceNumber();
					// ќткрываем окно постройки
					new BuildingConstructWindow({
						title:info.title,
						level:Number(level),
						totalLevels:Number(totalLevels),
						devels:info.instance.devel[level+1],
						bonus:info.bonus,
						target:this,
						upgradeCallback:upgradeEvent
					}).show();*/
				}
			}
			else
			{
				App.map.click();
				return false;
			}
			
			return true;
		}
		
		override public function openConstructWindow(openWindowAfterUpgrade:Boolean = true):Boolean 
		{
			if (App.data.storage[sid].hasOwnProperty('require') && App.data.storage[sid].require[0] && !User.inUpdate(App.data.storage[sid].require[0]))
			{
				Locker.availableUpdate();
				return false;
			}
			if (_constructWindow != null)
				return true;
			
			if (level < totalLevels)
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						var instanceNum:uint = instanceNumber();
						if (hasSpirit)
						{
							if (!User.inUpdate(openingZone))
							{
								Locker.availableUpdate();
								return false;
							}
							
							_constructWindow = new SharkWindow( { // Bременно заменен истанс
								title:			info.title,
								upgTime:		info.instance.devel[instanceNum].req[level + 1].l,
								request:		info.instance.devel[instanceNum].obj[level + 1],
								target:			this,
								win:			this,
								onUpgrade:		upgradeEvent,
								hasDescription:	true,
								popup:			false,
								spirit:			unit
							});
							
						}else{
							_constructWindow = new ConstructWindow( { // Bременно заменен истанс
								title:			info.title,
								upgTime:		info.instance.devel[instanceNum].req[level + 1].l,
								request:		info.instance.devel[instanceNum].obj[level + 1],
								reward:			info.instance.devel[instanceNum].rew[level + 1],
								target:			this,
								win:			this,
								onUpgrade:		upgradeEvent,
								hasDescription:	true,
								popup:			false
							});
						}
						
						_constructWindow.addEventListener(WindowEvent.ON_AFTER_CLOSE, onConstructWindowClose);
						_constructWindow.show();
						_openWindowAfterUpgrade = openWindowAfterUpgrade;
						
						return true;
					}
				}
			}
			return false;
		}
		
		override public function set touch(touch:Boolean):void 
		{
			if (hasSpirit)
				return;
			if ((!moveable && Cursor.type == 'move') ||
				(!removable && Cursor.type == 'remove') ||
				(!rotateable && Cursor.type == 'rotate'))// ||
				//(!touchableCursor.type == 'default')
			{
				//if (info.view != 'pier')
					return;
			}
			
			super.touch = touch;
		}
		
		override public function take():void 
		{
			
			//super.take();
			//	return;
			//unlock(App.map.info.bridges['line1']);
			
			//return;
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			var water:AStarNodeVO;
			
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var waters:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var i:int = 0
			var j:int = 0
			if (level < totalLevels)
			{
			for (i = 0; i < cells; i++) {//+2
				for (j = 0; j < rows; j++) {//+2
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					nodes.push(node);
					//node.p = 1;
					//node.isWall = true;
					node.object = this;
					
					part = App.map._aStarParts[coords.x + i][coords.z + j];
					parts.push(part);
					//part.isWall = false;
					part.object = this;
					
					/*if (info.view == 'pier') {
						water = App.map._aStarWaterNodes[coords.x + i][coords.z + j];
						//part.isWall = true;
						water.object = this;
						water.isWall = true;
						waters.push(water);
					}*/
				}
			}
			}else{
				//this.rows = 1;
				//this.cells = 1;
				for (i = 0; i < cells; i++) {//+2
					for (j = 0; j < rows; j++) {//+2
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						nodes.push(node);
						//node.p = 0;
						//node.isWall = false;
						//node.object = this;*/
						node.object = null;
						
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						//part.isWall = false;
						//part.object = this;
						part.object = null;
						
						/*if (info.view == 'pier') {
							water = App.map._aStarWaterNodes[coords.x + i][coords.z + j];
							//part.isWall = true;
							water.object = this;
							water.isWall = true;
							waters.push(water);
						}*/
					}
				}
			}
			
			if (info.view == 'pier') {
				App.map._astarWater.take(waters);
			}
		}
		
		override public function calcDepth():void
		{
			var left:Object = {x: x - IsoTile.width * 1 * .5, y: y + IsoTile.height * 1 * .5};
			var right:Object = {x: x + IsoTile.width * 1 * .5, y: y + IsoTile.height * 1 * .5};
			depth = (left.x + right.x) + (left.y + right.y) * 100;
		}
		
		public static function findPlaceBridges(view:String = "light"):Array 
		{
			if (bridges == null) return [];
			var _bridges:Array = [];
			
			if (view == 'pier')
				_bridges = Map.findUnitsByTypeinLand(['Bridge']);
			else
				_bridges = Map.findUnitsByType(['Bridge']);
			
			var result:Array = [];
			for (var lineName:String in bridges) 
			{
				var mapBridges:Array = bridges[lineName];
				for (var i:int = 0; i < mapBridges.length; i++) {
					var bridge:Bridge = findBridgeOnThisPlace(mapBridges[i]);
					if (bridge == null) {
						result.push( { place:mapBridges[i], line:lineName } );
						break;
					}
				}
			}
			return result;
			
			function findBridgeOnThisPlace(place:Object):Bridge
			{
				for (var i:int = 0; i < _bridges.length; i++) 
				{
					var bridge:Bridge = _bridges[i];
					if (bridge.coords.x == place.x && bridge.coords.z == place.z) 
					{
						return bridge;
					}
				}
				
				return null;
			}
		}
		
		public static function init(bridges:Object):void {
			
			Bridge.bridges = bridges;
			// блокируем лини переходов
			lockLines(bridges);
		}
		
		public static function lockLines(bridges:Object):void {
			for (var lineName:String in bridges) {
				lock(bridges[lineName]);
			}
		}
		
		private static function lock(bridges:Array):void {
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			for (var i:uint = 0; i < bridges.length; i++) {
				var bridge:Object = bridges[i];
				for (var _i:uint = 0; _i < 3; _i++) {
					for (var _j:uint = 0; _j < 3; _j++) {
						node = App.map._aStarNodes[bridge.x + _i][bridge.z + _j];
						node.isWall = true;
						nodes.push(node);
						
						part = App.map._aStarParts[bridge.x + _i][bridge.z + _j];
						part.isWall = true;
						parts.push(part);
					}
				}
			}	
			
			App.map._astar.take(nodes);
			App.map._astarReserve.take(parts);
		}
		
		private static function unlock(bridges:Array):void {
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			for (var i:uint = 0; i < bridges.length; i++) {
				var bridge:Object = bridges[i];
				for (var _i:uint = 0; _i < 3; _i++) {
					for (var _j:uint = 0; _j < 3; _j++) {
						node = App.map._aStarNodes[bridge.x + _i][bridge.z + _j];
						node.isWall = false;
						nodes.push(node);
						
						part = App.map._aStarParts[bridge.x + _i][bridge.z + _j];
						part.isWall = false;
						parts.push(part);
					}
				}
			}	
			
			App.map._astar.free(nodes);
			App.map._astarReserve.free(parts);
		}
		
		public static function showMessage():void 
		{
			if (!App.map.info.hasOwnProperty('bridges')) return;
			
			new SimpleWindow( {
				title:Locale.__e('flash:1382952379891'),
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1382952379892')
			}).show();
			
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			App.map.moved = null;
			this.id = data.id;
			
			// назначаем к какой линии принадлежит мост
			for (var i:int = 0; i < possiblePlaces.length; i++) {
				var place:Object = possiblePlaces[i].place;
				if (place.x == coords.x && place.z == coords.z) {
					line = possiblePlaces[i].line;
				}
			}
			//if(line != null)
				//Bridge.checkLine(line);
			hideSpirits();
			clickable = false;
			touchable = false;
			state = DEFAULT;
			check();
			App.ui.flashGlowing(this);
		}
	}	
}
import flash.display.Bitmap;
import flash.display.BitmapData;

internal class Spirit extends LayerX
{
	private var bitmap:Bitmap = new Bitmap();
	public function Spirit(bmd:BitmapData) 
	{
		bitmap.bitmapData = bmd;
		bitmap.alpha = 0.5;
		addChild(bitmap);
	}
}


