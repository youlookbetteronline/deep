package 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Log;
	import core.Numbers;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import units.Bathyscaphe;
	import units.Building;
	import units.Decor;
	import units.FogCloud;
	import units.Plant;
	import units.Unit;
	import units.WUnit;
	import wins.Window;
	
	public class Fog extends LayerX 
	{
		private static const FOG_RESOLUTION:Number = 0.75;
		
		[Embed(source="f1.png", compression="true", quality="80")]
		public static  var Fog3:Class;
		public static  var fog3:BitmapData = new Fog3().bitmapData;
		
		public static var zonesTitle:Object = { };
		public static var zoneData:Object = { };
		public static var bitmap:Bitmap 
		public static var clouds:Array = [];
		public static var faders:Object = {};
		public static var offsetY:Boolean = false;
		public static var zones:Object = { };
		public static var fogs:Vector.<Fog> = new Vector.<Fog>();
		public static var tochedZone:int = 0;
		
		private static var openCallback:Function;
		private static var _bounds:Rectangle;
		private static var _matrix:Matrix;
		
		private static var _mapsFogsDict:Dictionary;
		private static var drawedZones:Vector.<int> = new Vector.<int>();
		
		public var sid:int;
		public var index:int;
		public var coords:Object = { };
		public var open:Boolean = false;
		public var faderDrawed:Boolean = false;
		public var container:Sprite;
		public var layer:String;
		public var depth:int = 0;
		public var light:Number = -0.2;
		public var unitCounter:int = 0;
		
		private var _width:int;
		private var _height:int;
		private var points:Array;
		private var closeTween:TweenLite;
		private var callbackTimeout:uint;
		private var _touch:Boolean = false;
		
		/*public function get container():Sprite
		{
			return _container;
		}
		
		public function set container(_val:Sprite):void
		{
			//if(sid == 1026)
				//trace('Zone[' + sid + '].container = ' + _val);
			_container = _val;
		}*/
		
		public function set touch(value:Boolean):void 
		{
			if (App.user.mode == User.GUEST) return;
			
			if (_touch == value) return;
				_touch = value;
			
			if (_touch) 
				UserInterface.effect(this, 0.1, 1);
			else
				this.filters = []; 
		}
		
		public function get touch():Boolean 
		{
			return _touch;
		}
		
		public function Fog(sid:int)
		{
			layer = Map.LAYER_SORT;
			
			this.sid = sid;
			var _data:Object = zoneData[sid];
			Fog.zones[sid] = this;
			
			if(App.user.mode == User.OWNER){
				if (App.user.world && App.user.world.zones.indexOf(sid) != -1)
					open = true;
			}else{
				if (App.owner.world.zones.indexOf(sid) != -1)
					open = true;
			}
			
			coords = { x:_data.corners[0].x, y:0, z:_data.corners[0].z};
			
			points = [];
			for (var i:int = 0; i < _data.corners.length; i++) 
			{
				var coors:Object = IsoConvert.isoToScreen(_data.corners[i].x, _data.corners[i].z, true);
				points.push(coors);
			}
			
			_width = points[1].x - points[3].x;
			_height = points[2].y - points[0].y;
			
			calcDepth();
			
			if (App.data.storage[App.map.id].size == World.NORMAL) 
			{
				tip = function():Object {
					return {
						title:App.data.storage[sid].title,
						text:App.data.storage[sid].description
					};
				};
			}
		}
		
		public function onOpen_enterFrame(e:Event):void 
		{
			App.self.setOffEnterFrame(onOpen_enterFrame);
			
			callbackTimeout = setTimeout(function():void {
				if (openCallback != null) {
					openCallback();
					openCallback = null;
				}
			}, 500);
			TweenLite.to(this, 3, { alpha:0, onComplete:uninstall});
		}
		
		public function calcDepth():void 
		{
			var left:Object = points[3];
			var right:Object = points[1];
			depth = (left.x + right.x) + (left.y + right.y) * 100;
		}
		
		public function sort(index:*):void
		{
			try {
				App.map.mSort.setChildIndex(this, index);
			} catch (e:Error) {
				
			}
		}
		
		public function addUnits(e:AppEvent = null):void 
		{
			if (!zoneData[sid].hasOwnProperty('_units') || zoneData[sid]['_units'].length == 0) 
				return;
			zoneData[sid]._units.sortOn('depth', Array.NUMERIC | Array.DESCENDING);
			zoneData[sid]._units.reverse();
			
			container.visible = false;
			
			for (var i:int = 0; i < zoneData[sid]._units.length; i++)
			{
				var fogUnit:FogUnit = new FogUnit(zoneData[sid]._units[i], this);
				if (container)
					container.addChild(fogUnit);
			}
		}
		
		public function onUnitComplete():void 
		{
			if(!zoneData[sid])
				return;
			unitCounter++;
			
			if (zoneData[sid]._units && unitCounter >= zoneData[sid]._units.length) 
			{
				container.visible = true;
				
				var bounds:Object = snapClip(this);
				
				var bitmap:Bitmap = new Bitmap(bounds.bmd);
				bitmap.scaleX = bitmap.scaleY = 1 / FOG_RESOLUTION;
				bitmap.smoothing = true;
				addChild(bitmap);
				
				bitmap.x = bounds.rect.x;
				bitmap.y = bounds.rect.y + App.map.bitmap.y;
				this.cacheAsBitmap = true;
				bounds = null;
				
				var i:int = container.numChildren;
				while (--i >= 0)
				{
					var _child:* = container.getChildAt(i);
					if(_child.bitmapData){
						_child.bitmapData.dispose();
						_child.bitmapData = null;
					}
					_child = null;
				}
				if (container) 
				{
					container.removeChildren();
					removeChild(container);
					container = null;
				}
				
				zoneData[sid]._units = [];
			}
		}
		
		
		private function drawZone():void 
		{
			container = new Sprite();
			addChild(container);
			container.x = App.map.bitmap.x;
			App.map.addUnit(this);
		}
		
		private function drawRenderedFog():void
		{
			App.map.addUnit(this);
		}
		
		public function uninstall():void
		{
			if(closeTween != null){
				closeTween.complete(true, true);
				closeTween.kill();
				closeTween = null;
			}
			
			clearTimeout(callbackTimeout);
			App.map.removeUnit(this);
		}
		
		public static function generateZoneCorners():void 
		{
			for (var x:int = 0; x < Map.cells - 1; x++)
			{
				for (var z:int = 0; z < Map.rows - 1; z++)
				{
					var zID:* = App.map._aStarNodes[x][z].z;
					
					if(!zoneData.hasOwnProperty(zID))
						zoneData[zID] = { minX:1000, minZ:1000, maxX:0, maxZ:0 };
					
					zoneData[zID].minX = Math.min(zoneData[zID].minX, x);
					zoneData[zID].minZ = Math.min(zoneData[zID].minZ, z);
					zoneData[zID].maxX = Math.max(zoneData[zID].maxX, x);
					zoneData[zID].maxZ = Math.max(zoneData[zID].maxZ, z);
				}
			}
			
			var delta:int = 1;
			for (zID in zoneData) 
			{
				zoneData[zID]['corners'] = [];
				zoneData[zID].corners[0] = { x:zoneData[zID].minX - delta, z:zoneData[zID].minZ - delta };
				zoneData[zID].corners[1] = { x:zoneData[zID].maxX + delta, z:zoneData[zID].minZ - delta };
				zoneData[zID].corners[2] = { x:zoneData[zID].maxX + delta, z:zoneData[zID].maxZ + delta };
				zoneData[zID].corners[3] = { x:zoneData[zID].minX - delta, z:zoneData[zID].maxZ + delta };
				
				zoneData[zID]['cells'] = zoneData[zID].maxX - zoneData[zID].minX;
				zoneData[zID]['rows'] = zoneData[zID].maxZ - zoneData[zID].minZ;
			}
		}
		
		public static function click():Boolean
		{
			if(App.user.world)
				App.user.world.showOpenZoneWindow(tochedZone);
			return true;
		}
		
		public static function checkFog(fsid:int):Boolean 
		{
			for each(var ffog:Fog in fogs)
			{
				if(ffog.sid == fsid){
					if(ffog.faderDrawed == true)
						return true;
					else 
						return false;
				}
			}
			return false;
		}
		public static function addClouds():void 
		{
			var counter:int = 0;
			for (var sx:int = 0; sx < Map.cells + 6; sx += 6) 
			{
				for (var sy:int = 0; sy < Map.rows + 6; sy += 6) 
				{
					var fogObject:Object = 
					{
						id:counter,
						bmd:fog3,
						x:sx - 3 + 6 * Math.random(),
						z:sy - 3 + 6 * Math.random(),
						scale:1
					}
					
					if (App.map._aStarNodes.length > sx && App.map._aStarNodes[sx].length > sy)
					{
						var node:AStarNodeVO = App.map._aStarNodes[sx][sy];
						if (node.z != 0 && node.w != 0 && !node.open && (!node.open && !checkFog(node.z)))
						{
							counter++;
							if (App.user.mode == User.OWNER && App.user.worldID == User.FARM_LOCATION)
								continue;
							var unit:FogCloud = new FogCloud(fogObject);
							unit.zone = node.z;
							Fog.addToZone(unit);
							unit = null;
						}
					}
				}
			}
			
			App.map.sorting();
			
			for each(var fog:Fog in fogs) 
			{
				if(!fog.faderDrawed)
					fog.addUnits();
				
				if(!fog.open)
					fog.faderDrawed = true;
			}
		}
		
		public static function init(assetZones:Object, mapID:int = 0):void {
			if (!_mapsFogsDict)
				_mapsFogsDict = new Dictionary(true);
				
			if (!_mapsFogsDict.hasOwnProperty(mapID))
				_mapsFogsDict[mapID] = new Vector.<Fog>();
			
			fogs = _mapsFogsDict[mapID];
			
			for (var zid:* in zoneData) 
			{
				// Zones that is usually opened after tutorial;
				if (zid == 0 || zid == 828) continue;
				if (Fog.drawedZones.indexOf(zid) != -1) continue;
				if (World.zoneIsOpen(zid))
					continue;
				
				var fog:Fog = new Fog(zid);
				fogs.push(fog);
			}
			
			for each(var _fog:Fog in fogs) 
			{
				if (!World.zoneIsOpen(_fog.sid)){
					Fog.drawedZones[Fog.drawedZones.length] = _fog.sid;
					_fog.drawZone();
				}
			}
			
			addClouds();
			
		}
		
		public static function hideAll():void 
		{
			for each(var fog:Fog in fogs)
				fog.visible = false;
		}
		
		public static function showFogsAfterTutorial():void 
		{
			for each(var fog:Fog in fogs)
				fog.visible = true;
		}
		
		public static function removeFogs():void {
			while(clouds.length > 0){
				clouds[0].uninstall();
				clouds.splice(0, 1);
			}
			clouds = [];
		}
		
		public static function dispose():void 
		{
			untouches();
			Fog.zoneData = { };
			for each(var fog:Fog in fogs) 
			{
				fog.uninstall();
			}
		}
		
		public static function snapClip(clip:*, delta:int = 0):Object 
		{
			_bounds = clip.getBounds(clip);
			_matrix = new Matrix (1, 0, 0, 1, -_bounds.x + delta / 2, -_bounds.y + delta / 2);
			_matrix.scale(FOG_RESOLUTION, FOG_RESOLUTION);
			
			var bmd:BitmapData;
			try { 
				bmd = new BitmapData (int ((_bounds.width+delta) * FOG_RESOLUTION), int ((_bounds.height + delta) * FOG_RESOLUTION), true, 0);
			} catch (e:Error) {
				bmd = new BitmapData(1, 1, true, 0);
			}
			bmd.draw(clip, _matrix);
			
			return {
				bmd:bmd,
				rect:_bounds
			}
		}
		
		public static function touches():Boolean
		{
			if (!fogs)
				return false;
			var node:* = World.nodeDefinion(App.map.mouseX, App.map.mouseY);
			if (node == null) return false;
			
			var zoneID:uint = node.z;
			
			for (var i:int = 0; i < fogs.length; i++) 
			{
				var fog:Fog = fogs[i];
				fog.touch = false;
				
				if (fog.sid == zoneID)
					fog.touch = true;
			}
			
			return false;
		}
		
		public static function addToZone(unit:*):void 
		{
			if (unit is Unit){
				if (Fog.drawedZones.indexOf(unit.zone) != -1) 
					return;
				if (unit is WUnit)
					return;
				if (unit is Bathyscaphe)
					return;
				if (unit.hasOwnProperty('layer') && unit.layer == 'mLand')
					return;
			}
			var zid:int = unit.zone;
			if (!zoneData.hasOwnProperty(zid)) 
				return;
			
			if(!zoneData[zid].hasOwnProperty('_units'))
				zoneData[zid]['_units'] = [];
			
			zoneData[zid]['_units'][zoneData[zid]['_units'].length] = unit;
		}
		
		public static function fogCenter(zID:int):Object 
		{
			var cl:int = int((zoneData[zID].minX + zoneData[zID].maxX) / 2);
			var rw:int = int((zoneData[zID].minZ + zoneData[zID].maxZ) / 2);
			var crds:Object = IsoConvert.isoToScreen(cl, rw, true, false);
			
			return crds;
		}
		
		public static function untouches():void 
		{
			for (var i:int = 0; i < fogs.length; i++)
			{
				fogs[i].touch = false;
			}
		}
			
		public static function openZone(sID:int, callback:Function = null):void {
			for each(var fog:Fog in fogs) 
			{
				if (fog.sid == sID) 
				{
					fog.mouseChildren = false;
					fog.mouseEnabled = false;
					
					openCallback = callback;
					App.self.setOnEnterFrame(fog.onOpen_enterFrame);
				}
			}
		}
	}	
}

import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.BitmapData;
import Fog;
import flash.filters.BlurFilter;
import flash.geom.Matrix;
import ui.UserInterface;
import units.Building;
import units.FogCloud;
import units.Hero;
import units.Plant;
import units.Port;
import units.Unit;
import utils.Sector;

internal class FogUnit extends Bitmap 
{
	private var fog:Fog;
	private var index:int = 0;
	private var offset:int = 0;
	private var color:* = 0x0a668e;
	private var fAmount:Number = .1;
	private var unit:*;
	public function FogUnit(_unit:*, _fog:Fog) 
	{
		unit = _unit;
		index = unit.index;
		fog = _fog;
		
		if (unit.type == 'FogCloud') 
		{
			color = 0x0a668e;
			fAmount = .65;
			draw(unit);
			offset = 20;
		} 
		else 
		{
			if (unit is Plant){
				unit = null;
				return;
			}
			if (unit is Sector){
				unit = null;
				return;
			}
			if (unit is Hero){
				unit = null;
				return;
			}
			if (unit.sid == 3058){
				unit = null;
				fog.onUnitComplete();
				return;
			}
				
			Load.loading(Config.getSwf(unit.info.type, unit.info.view), onLoadUnit);
		}
	}
	
	public function onLoadUnit(data:*):void 
	{
		if(unit.type != 'Bridge'){
			Load.clearCache(Config.getSwf(unit.info.type, unit.info.view));
			data = null;
		}
		draw(unit);
	}
	
	public function draw(unit:*):void 
	{
		if (!unit.bitmap.bitmapData)
		{
			unit = null;
			fog.onUnitComplete();
			return;
		}
		this.bitmapData = unit.bitmap.bitmapData.clone();
		this.x = unit.bitmap.x + unit.x - App.map.bitmap.x - offset;
		this.y = unit.bitmap.y + unit.y - App.map.bitmap.y - offset;
		if (unit.hasOwnProperty('multipleAnime') && Numbers.countProps(unit.multipleAnime) > 0){
			for each(var _anim:* in unit.multipleAnime){
				if(_anim.bitmap.bitmapData)
					this.bitmapData.draw(_anim.bitmap.bitmapData.clone(), new Matrix(1, 0, 0, 1, _anim.bitmap.x -unit.bitmap.x, _anim.bitmap.y - unit.bitmap.y));
			}
		}
		
		if (unit.hasOwnProperty('rotate') && unit.rotate)
		{
			this.scaleX *=-1;
			this.x += this.width;
		}
		
		this.smoothing = true;
		UserInterface.colorize(this, color, fAmount);
		
		if (unit.type == 'FogCloud'){
			var _filters:Array = this.filters;
			UserInterface.effect(this, .9, 1);
			_filters.concat(this.filters)
			_filters.push(new BlurFilter(20, 20, 2));
			this.filters = _filters;
		}else{
			if (App.user.mode == User.GUEST){
				if (unit.type == 'Resource')
					unit.dispose();
				else
					unit.uninstall();
			}
		}
		
		unit = null;
		fog.onUnitComplete();
	}
	
	public function sort():void 
	{
		fog.setChildIndex(this, index);
	}
}