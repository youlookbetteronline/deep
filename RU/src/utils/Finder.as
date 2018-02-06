package utils 
{
	import astar.AStarNodeVO;
	import buttons.ImageButton;
	import core.Numbers;
	import flash.utils.setTimeout;
	import ui.UnitIcon;
	import units.Lantern;
	import wins.QuestsChaptersWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class Finder 
	{
		
		public function Finder() 
		{
			
		}
		
		public static function findOnMap(unitz:Array):void
		{
			//var units:Array = Map.findUnits(unitz);
			//var target:* = units[0];
			App.user.quests.findTarget(unitz, false, null, false);
		}
		
		/*public static function walkNodes(from:Object, to:Object, targets:Array):void
		{
			var _node:AStarNodeVO;
			for (var i:int = from.x; i <= to.x; i++)
			{
				for (var j:int = from.z; j <= to.z; j++)
				{
					_node = App.map._aStarNodes[i][j];
					if (_node.object)
					{
						
						if (targets)
						{
							
						}
					}
				}
			}
		}*/
		
		public static function questInUser(qID:int, inChapter:Boolean = false):void
		{
			var tempQuest:int = qID;
			while (tempQuest != 0)
			{
				if (App.user.quests.data.hasOwnProperty(tempQuest))
					break;
				tempQuest = App.data.quests[tempQuest].parent;
				
			}
			
			if (tempQuest != 0)
			{
				if (App.data.quests[tempQuest].type == 1)
					tempQuest = App.data.quests[tempQuest].parent
				if (inChapter && !App.user.quests.data.hasOwnProperty(tempQuest))
					new QuestsChaptersWindow({find:[tempQuest], popup:true}).show();
				else
				{
					if (App.data.quests[tempQuest] && App.data.quests[tempQuest].hasOwnProperty('dream')&& App.data.quests[tempQuest].dream != null && App.data.quests[tempQuest].dream.indexOf(App.user.worldID) == -1)
					{
						Locker.notFindQuest(tempQuest);
						return;
					}
					App.ui.leftPanel.questsPanel.focusedOnQuest(tempQuest, 0);
					Window.closeAll();
				}
			}
		}
		
		public static function nearestUnit(unit:*, targets:Array = null):*
		{
			if (!App.map._aStarNodes)
				return null;
			var nearestUnit:*;
			if (targets && targets.length > 0)
			{
				nearestUnit = targets[0];
				var subtract:int;
				for each(var _unit:* in targets)
				{
					if (!subtract || ((Math.abs(_unit.coords.x - unit.coords.x) + Math.abs(_unit.coords.z - unit.coords.z)) < subtract))
					{
						if (!App.map._aStarNodes || !App.map._aStarNodes[_unit.coords.x][_unit.coords.z].open)
							continue;
						subtract = Math.abs(_unit.coords.x - unit.coords.x) + Math.abs(_unit.coords.z - unit.coords.z);
						nearestUnit = _unit;
					}
				}
				return nearestUnit;
			}
			//nearestUnit = targets[0];
			
			var _node:AStarNodeVO;	 
			var m:int = 0;
			var bias:Number = 0;
			var direction:String = 'up';
			
			var currentPos:Object = {x:int(unit.coords.x), z:int(unit.coords.z)};
			var tempPos:Object = currentPos;
			
			while (true)
			{
				m++;
				switch(direction)
				{
					case 'up':
						//walkNodes(currentPos,currentPos['z'] - 1 + bias)
						currentPos['z'] -= 1 + bias;
						bias += .5;
						direction = 'right'
						break;
					case 'right':
						//walkNodes(currentPos,currentPos['x'] + 1 + bias)
						currentPos['x'] += 1 + bias;
						bias += .5;
						direction = 'down'
						break;
					case 'down':
						//walkNodes(currentPos,currentPos['z'] + 1 + bias)
						currentPos['z'] += 1 + bias;
						bias += .5;
						direction = 'left'
						break;
					case 'left':
						//walkNodes(currentPos,currentPos['x'] - 1 + bias)
						currentPos['x'] -= 1 + bias;
						bias += .5;
						direction = 'up'
						break;
				}
				var positions:Object = {
					min:{
						x:Math.min(tempPos.x,currentPos.x),
						z:Math.min(tempPos.z,currentPos.z)
					},
					max:{
						x:Math.max(tempPos.x,currentPos.x),
						z:Math.max(tempPos.z,currentPos.z)
					}
				}
				for (var i:int = positions.min.x; i <= positions.max.x; i++)
				{
					for (var j:int = positions.min.z; j <= positions.max.z; j++)
					{
						if (!App.map.inGrid({x:i, z:j}))
							continue;
						//trace('check: x: ' + i + ', z: ' + j);
						_node = App.map._aStarNodes[i][j];
						if (_node.object)
						{
							if (targets)
							{
								//var _unt:Object = {unit:_node.object};
								if (targets.indexOf(_node.object) != -1 && _node.object['open'])
								{
									//trace('find: '+_node.object.info.title +" after i = "+m)
									return _node.object;
								}
							}else{
								
								//trace('find: '+_node.object.info.title +" after i = "+m)
								return _node.object;
							}
						}
					}
				}
				//walkNodes(tempPos, currentPos, targets);
				tempPos = {x:int(currentPos.x),z:int(currentPos.z)};
				//
				if (m > 200)
					break;
				//trace('x: '+(int(currentPos['x']) - unit.coords.x)+' z: '+ (int(currentPos['z']) - unit.coords.z))
				//for (i; i < j; i++)
				//{
					//if(App.map.inGrid(App.user.hero.coords.x+i,App.user.hero.coords.z+j))
						//_node = App.map._aStarNodes[App.user.hero.coords.x + i][App.user.hero.coords.z + j];
				//}
			}
			
			/*var nearestPos:uint = 999999999999999999;
			for each(var tarObj:* in unitz)
			{
				var xx:uint = Math.abs(tarObj.unit.x - App.user.hero.x);
				var yy:uint = Math.abs(tarObj.unit.y - App.user.hero.y);
				if (xx + yy  < nearestPos)
				{
					if (tarObj.unit is ImageButton)
						continue;
					if (tarObj.unit is UnitIcon)
						continue;
					if (!tarObj.unit.open)
						continue;
					nearestPos = xx + yy;
					nearestUnit = tarObj;
					//unclossedRes = true;
				}
			}*/
			return nearestUnit;
			
		}
		
		public static function onLanternSpawn(e:* = null):void
		{
			App.self.removeEventListener(AppEvent.ON_LANTERN_SPAWN, Finder.onLanternSpawn);
			Finder.focusOnLantern();
		}
		
		public static function focusOnLantern():void
		{
			if (Lantern.lanterns.length > 0)
			{
				var _lamp:Lantern = Lantern.lanterns[0];
				App.map.focusedOn(_lamp, false, function():void 
				{
					_lamp.startBlink();
					setTimeout(function():void {
						_lamp.stopBlink();
					}, 2000);
				});
			}else
				App.self.addEventListener(AppEvent.ON_LANTERN_SPAWN, Finder.onLanternSpawn);
		}
		
		public static function removeUnits(_units:Array):void
		{
			for each(var _unit:* in _units)
			{
				_unit.removable = true;
				_unit.onApplyRemove();
			}
		}
	}

}