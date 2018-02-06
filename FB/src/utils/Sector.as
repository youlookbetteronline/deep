package utils 
{
	import astar.AStarNodeVO;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import ui.UserInterface;
	import units.Resource;
	/**
	 * ...
	 * @author 
	 */
	public class Sector extends LayerX 
	{		
		public static var fogs:Object = {};
		public static var BRIDGE_SECTORS:Array = [712, 713, 714, 715, 716, 717];
		public static var BRIDGE_SECTORS2:Array = [743, 742, 746, 741, 740, 739, 738, 702, 701, 737, 700, 664];
		public static var START:int = 1;
		public static var CLEAR:int = 2;
		public static var BUSY:int = 3;
		
		private var settings:Object;
		private var _open:Boolean = false;
		public var defResources:Object = {};
		public var resources:Vector.<Resource>;
		public var neighbors:Vector.<Sector> = new Vector.<Sector>();
		public var coords:Object;
		public var mode:int;
		public var id:int;
		public var fog:Bitmap;
		public var layer:String = Map.LAYER_SORT;
		
		[Embed(source="../f1.png", compression="true", quality="80")]
		public static  var DefFog:Class;
		public static  var defFog:BitmapData = new DefFog().bitmapData;
		
		public function Sector(_settings:Object = null) 
		{
			//layer = Map.LAYER_SORT;
			settings = _settings;
			id = _settings.zone.id;
			resources = _settings.resources;
			coords = _settings.zone;
			checkMode();
			switch(App.user.worldID){
				case User.VILLAGE_MAP:
					if (mode == Sector.START || (settings.sectorZone != 2139 ||settings.sectorZone != 2140))
						open = true;
					break;
				case User.TRAVEL_LOCATION:
					if (mode == Sector.START || this.id == 998|| this.id == 1212)
						open = true;
					break;
				case User.HUNT_MAP:
					if (mode == Sector.START)
						open = true;
					break;
				case User.FARM_LOCATION:
					if (this.id == 791 || this.id == 829)
						open = true;
					break;
			}
			if (App.user.mode == User.PUBLIC)
			{
				if (App.owner.world.data.hasOwnProperty('sectors') && App.owner.world.data.sectors.hasOwnProperty(this.id))
					this.open = true;
				//trace();
			}
			/*if (App.user.worldID == User.TRAVEL_LOCATION)
			{
				if (mode == Sector.START || this.id == 998)
					open = true;
			}*/
			//draw();
			App.map.addUnit(this);
			checkChildren();
			placeOnNodes();
			openNeibors();
			//this.addEventListener(MouseEvent.MOUSE_OVER, overSector);
			//this.addEventListener(MouseEvent.MOUSE_OUT, outSector);
			//this.addEventListener(MouseEvent.CLICK, clickSector);
		}
		
		public function sort(index:*):void
		{
			App.map.mSort.setChildIndex(this, index);
		}
		
		public function set open(val:Boolean):void
		{
			//if(val == true)
				//trace('open sector with id: ' + this.id);
			_open = val;
		}
		
		public function get open():Boolean
		{
			return _open;
		}
		
		public function checkChildren():void
		{
			for each(var _res:* in resources)
			{
				_res.sector = this;
			}
		}
		
		public function clickSector(e:*):void
		{
			trace('\n\ndef = '+ Numbers.countProps(defResources));
			trace('curr = ' + resources.length);
			trace('canOpenNeibors ? - ' + String(canOpenNeibors));
			trace('open ? - ' + String(open));
		}
		/*public function checkCoincidence():void
		{
			var i:int = 0;
			for each(var _res:* in resources)
			{
				if (defResources.hasOwnProperty(_res.id) && defResources[_res.id].sid == _res.sid)
					i++;
			}
			trace('\nCoincidences: ' + i);
		}*/
		
		public function checkSelfOpen():void
		{
			
		}
		
		private var _sectorsToOpen:Array = [];
		public function openNeibors(send:Boolean = false):void
		{
			if (canOpenNeibors)
			{
				_sectorsToOpen = [];
				for each(var _sector:Sector in neighbors)
				{
					if (App.user.mode == User.OWNER && _sector.id == 718 && App.user.worldID == User.TRAVEL_LOCATION)
						openBridgeSectors();
					if (App.user.mode == User.OWNER && (_sector.id == 744 /*|| _sector.id == 708 ||_sector.id == 745 || _sector.id == 709 || _sector.id == 707*/) && App.user.worldID == 3148)
						openBridgeSectors();
					_sector.open = true;
					if (App.user.mode == User.PUBLIC)
					{
						if (App.owner && App.data.storage[App.owner.worldID].maptype == World.PUBLIC)
						{
							//if(App.owner){
							//var _ss:Object = {}
							//_ss[_sector.id] = 1;
							_sectorsToOpen.push(_sector.id);
						}
					}
					
					if(App.user.mode == User.PUBLIC || (App.user.mode == User.OWNER && App.user.worldID != User.FARM_LOCATION))
						_sector.checkFog();
				}
				if (send && App.user.mode == User.PUBLIC && _sectorsToOpen.length > 0)
					SectorsHelper.sendOpened(_sectorsToOpen);
			}
		}
		
		
		
		public function openNeiborsForcibly():void
		{
			for each(var _sector:Sector in neighbors)
			{
				_sector.open = true;
				if((App.user.mode == User.OWNER && App.user.worldID != User.FARM_LOCATION) || App.user.mode == User.PUBLIC)
					_sector.checkFog();
			}
		}
		
		public function openBridgeSectors():void
		{
			for each(var _sector:Sector in App.map.faders)
			{
				if (App.user.worldID == User.TRAVEL_LOCATION)
				{
					if (BRIDGE_SECTORS.indexOf(_sector.id) != -1)
					{
						_sector.open = true;
						_sector.openNeibors();
					}
				}
				if (App.user.worldID == 3148)
				{
					if (BRIDGE_SECTORS2.indexOf(_sector.id) != -1)
					{
						_sector.open = true;
						_sector.openNeibors();
					}
				}
			}
		}
		
		public function fireNeiborsReses():void
		{
			for each(var _sector:Sector in neighbors)
			{
				if (_sector.open)
				{
					for each(var _res:* in _sector.resources)
					{
						_res.glowing();
					}
				}else
				{
					for each(var _res2:* in _sector.resources)
					{
						_res2.glowing(0xbdbdbd);
					}
				}
			}
		}
		
		public function get canOpenNeibors():Boolean
		{
			var i:int = 0;
			for each(var _res:* in resources)
			{
				if (defResources.hasOwnProperty(_res.id) && defResources[_res.id].sid == _res.sid)
					i++;
			}
			
			return Numbers.countProps(defResources) != i;
		}
		
		public function overSector(e:*):void
		{
			this.alpha = 1;
		}
		
		public function outSector(e:*):void
		{
			this.alpha = .5;
		}
		
		public function placeOnNodes():void
		{
			var _zone:Object = coords;
			var node:AStarNodeVO;
			for (var i:int = _zone.x; i < _zone.x + _zone.size; i++)
			{
				if (App.map._aStarNodes.length <= i)
					continue;
				for (var j:int = _zone.z; j < _zone.z + _zone.size; j++)
				{
					if (App.map._aStarNodes[i].length <= j)
						continue;
						
					node = App.map._aStarNodes[i][j];
					node.sector = this;
					
				}
			}
		}
		
		public function checkMode():void
		{
			mode = Sector.CLEAR;
			if (!settings.sectorClear)
				mode = Sector.BUSY;
			if (settings.sectorZone != 0 && App.data.storage[settings.sectorZone].open == 1)
				mode = Sector.START;
			
			switch(mode)
			{
				case 1:
					settings.color = 0x00ff00;
					break;
				case 2:
					settings.color = 0xff0000;
					break;
				default:
					settings.color = 0;
			}
			//settings.color = 0;
			//if (settings.sectorClear)
				//settings.color = 0xff0000;
			//if (/*!settings.sectorClear &&*/ settings.sectorZone != 0 && App.data.storage[settings.sectorZone].open == 1)
				//settings.color = 0x00ff00;
		}
		public function checkFog():void
		{
			//(App.user.worldID != User.TRAVEL_LOCATION)
				//return;
			if (!fog && !open && this.id % 2 == 0)
			{
				if (settings.sectorClear)
					return;
				if (fogs.hasOwnProperty(this.id))
					return;
				var point:Object = IsoConvert.isoToScreen(coords.x + int(coords.size / 2), coords.z + int(coords.size / 2), true);
				fogs[this.id] = 1;
				fog = new Bitmap(defFog);
				UserInterface.colorize(fog, 0x0a668e, .65);
				Size.size(fog, 265, 265);
				if (App.user.worldID != User.TRAVEL_LOCATION)
				{
					fog.scaleY = 1.5;
					//fog.x = point.x - fog.width / 2;
					fog.x = -140;
					fog.y = -160;
				}else{
					fog.x = -140;
					fog.y = -90;
				}
				fog.cacheAsBitmap = true;
				addChild(fog)
				//App.map.depths.push(unit);
				//App.map.sorted.push(unit);
				//App.map.mFog.addChild(fog);
				//App.map.mSort.addChild(fog);
				//App.map.depths.push(this);
				this.cacheAsBitmap = true;
			}else if (fog){
				if (fog.parent)
					fog.parent.removeChild(fog);
				if (fogs.hasOwnProperty(this.id))
					delete fogs[this.id];
				//if (App.map.depths.indexOf(fog != -1))
					//App.map.depths.splice(App.map.depths.indexOf(fog), 1);
				fog = null;
			}
				
		}
		
		public var depth:uint = 0;
		public function calcDepth():void
		{
			var rows:int = 5;
			var cells:int = 5;
			
			var left:Object = {x: x - IsoTile.width * rows * .5, y: y + IsoTile.height * rows * .5};
			var right:Object = {x: x + IsoTile.width * cells * .5, y: y + IsoTile.height * cells * .5};
			depth = (left.x + right.x) + (left.y + right.y) * 100;
		}
		
		public function uninstall():void
		{
			App.map.removeUnit(this);
			
		}
		
		public function draw():void
		{
			//if(App.user.id != "50545195")
				//return;
			var colour:uint = settings.color;
			var _zone:Object = coords;
			var fader:Shape = new Shape();
			var point:Object = IsoConvert.isoToScreen(_zone.x, _zone.z, true);
			fader.graphics.beginFill(colour, 1);
			fader.graphics.moveTo(point.x, point.y);
			
			point = IsoConvert.isoToScreen(_zone.x + _zone.size, _zone.z, true);
			fader.graphics.lineTo(point.x, point.y);
			
			point = IsoConvert.isoToScreen(_zone.x + _zone.size, _zone.z + _zone.size, true);
			fader.graphics.lineTo(point.x, point.y);
			
			point = IsoConvert.isoToScreen(_zone.x, _zone.z + _zone.size, true);
			fader.graphics.lineTo(point.x, point.y);
			
			point = IsoConvert.isoToScreen(_zone.x, _zone.z, true);
			fader.graphics.lineTo(point.x, point.y);
			
			fader.graphics.endFill();
			fader.filters = [new GlowFilter(0xffffff, 1, 2, 2, 8, 1, true)];
			this.alpha = .5;
			addChild(fader);
		}
		
	}

}