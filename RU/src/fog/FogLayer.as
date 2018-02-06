package fog 
{
	import astar.AStarNodeVO;
	import com.flashdynamix.motion.layers.VectorLayer;
	import core.IsoConvert;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import units.Plant;
	import units.Unit;
	import wins.VisitWindow;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class FogLayer
	{
		private const districtSize:int = 100;
		private var _transparent:Boolean = false;
		private var reserv:BitmapData;
		private var fogManager:FogManager;
		private var lineContainer:Sprite;
		public function FogLayer(transparent:Boolean = true)
		{
			this.transparent = transparent;
			fogManager = App.map.fogManager;
			reserv = App.map.bitmap.bitmapData.clone();
			unitsList = new Vector.<Unit>;
			unitsListDisplayd = new Vector.<Unit>;
		}
		public function set transparent(value:Boolean):void
		{
			_transparent = value;
		}
		public function get transparent():Boolean
		{
			return _transparent;
		}
		private var _allClouds: Vector.<FogCloud>;
		private function get allClouds():Vector.<FogCloud>
		{
			if (!_allClouds)
				_allClouds = greedy();
			return _allClouds;
		}
		private var _clouds: Vector.<FogCloud>;
		private function get clouds():Vector.<FogCloud>
		{
			if (!_clouds)
			{
				_clouds = new Vector.<FogCloud>;
				for each(var cloud:FogCloud in allClouds)
				{
					if (cloud.inZone(0))
					{
						_clouds.push(cloud);
					}
				}
			}
			return _clouds;
		}
		public function zoneCenter(zoneID:int):Object
		{
			var pos:Object = zonePosition(zoneID);
			var re:Object = {	x:int((pos.topLeftIso.x + pos.botRightIso.x) / 2), z:int((pos.topLeftIso.z + pos.botRightIso.z) / 2) };
			return re;
		}
		
		private function zonePosition(zoneID:int = 0, deepthZ:int = 0):Object
		{
			var nodeArray:Object = App.map._aStarNodes;
			var _topLeftIso:Object = { x:0, z:0 };
			var _topRight:Object = { x:0, y:0 };
			var _topLeft:Object = { x:0, y:0 };
			var _botRightIso:Object = { x:0, z:0 };
			var _botRight:Object = { x:0, y:0 };
			var _botLeft:Object = { x:0, y:0 };
			var minX:uint = Map.cells;
			var minZ:uint = Map.rows;
			var maxX:uint = 0;
			var maxZ:uint = 0;
			var _x:uint = 0;
			var _z:uint = 0;
			
			//_topLeft.x = App.map.bitmap.x;
			//_topLeft.y = App.map.bitmap.y ;

			while ( _x < Map.cells)
			{
				while ( _z < Map.rows) 
				{
					if ( (!zoneID && fogManager.hidenZones.indexOf (nodeArray[_x][_z].z) !=-1) || nodeArray[_x][_z].z == zoneID)
					{
						if (_z < minZ)
							minZ = _z;
						if (_x < minX)
							minX = _x;
						if (_z > maxZ)
							maxZ = _z;
						if (_x > maxX)
							maxX = _x;
					}
					_z++;
				}
				_z = 0;
				_x++;
			}
			if (minX != Map.cells || minZ != Map.rows)
			{
				var obj1:Object = IsoConvert.isoToScreen(minX + deepthZ, minZ + deepthZ, true); // topRight
				var obj2:Object = IsoConvert.isoToScreen(maxX + 1 - deepthZ, maxZ + 1 - deepthZ, true); // botLeft
				var obj3:Object = IsoConvert.isoToScreen(minX + deepthZ, maxZ + 1 - deepthZ, true); // topLeft
				var obj4:Object = IsoConvert.isoToScreen(maxX + 1 - deepthZ, minZ + deepthZ, true); // botRight
				
				_topRight.x += obj2.x;
				_topRight.y += obj2.y;
				_topLeft.x += obj3.x;
				_topLeft.y += obj3.y;
				_botRight.x = obj4.x;
				_botRight.y = obj4.y;
				_botLeft.x = obj1.x; //obj2.x;
				_botLeft.y = obj1.y;
				
				_topLeftIso.x = minX + deepthZ;
				_topLeftIso.z = minZ + deepthZ;
				_botRightIso.x = maxX - deepthZ;
				_botRightIso.z = maxZ - deepthZ;
			}
			return {
				topRight:_topRight,
				topLeft:_topLeft,
				botRight:_botRight,
				botLeft:_botLeft,
				topLeftIso:_topLeftIso,
				botRightIso:_botRightIso
			}
		}
		
		private function checkDepth(numberNodes:int = 5, numberDepth:int = 1):void{
			
			var _x:uint = 0;
			var _z:uint = 0;
			var needX:uint = 0;
			var needZ:uint = 0;
			var node:AStarNodeVO;
			
			for each(var zone:String in App.map.assetZones)
			{
				if (World.zoneIsOpen(uint(zone)))
				{
					var bb:* = zonePosition(int(zone),-numberNodes)
					_x = bb.topLeftIso.x;
					_z = bb.topLeftIso.z;
					needX = bb.botRightIso.x;
					needZ = bb.botRightIso.z;
					
					/*if (numberNodes <= 5)
					{
						zoneDraw(bb, true, 0xffffff);
					}else
					{
						zoneDraw(bb, true, 0xffff);
					}*/
					if (_x >= Map.cells)
						_x = Map.cells - 1;
						
					if (_z >= Map.rows)
						_z = Map.rows - 1;
						
					if (_x < 1)
						_x = 0;
						
					if (_z < 1)
						_z = 0;
						
					if (needX >= Map.cells)
						needX = Map.cells - 1;
						
					if (needZ >= Map.rows)
						needZ = Map.rows - 1;
						
					var counter:int = 0;
					while (_x < needX)
					{
						while (_z < needZ) 
						{
							//if (_x >= Map.cells || _z >= Map.rows)
								//continue;
							
							node = App.map._aStarNodes[_x][_z];
							//if (!node.open)
							/*if (!node.open)
							{*/
							
							//node.fDepth = numberDepth;
							
							if (node.fDepth == 0 || node.fDepth > numberDepth)
							{
								node.fDepth = numberDepth;
								counter++;
							}
								
							/*}
								
							if (node.open)
								node.fDepth = 0;*/
							/*if ( (!zoneID && fogManager.hidenZones.indexOf (nodeArray[_x][_z].z) !=-1) || nodeArray[_x][_z].z == zoneID)
							{
								
							}*/
							_z++;
						}
						_z = bb.topLeftIso.z;
						if (_z >= Map.rows)
							_z = Map.rows - 1;
						
						if (_z < 1)
							_z = 0;
						
						_x++;
					}
				}
			}
			
			
		}
		
		private function collision(fogCloud:FogCloud,list:Vector.<FogCloud> ):Boolean
		{
			if (list.length == 0)
				return false;
			for each (var cloud:FogCloud in list)
			{
				if (fogCloud.collision(cloud))
					return true;
			}
			return false;
		}
		private function greedy():Vector.<FogCloud> // пробуем засунуть попбольше облаков жадным алгоритмом
		{
			var result:Vector.<FogCloud> = new Vector.<FogCloud>;
			var area:Object = zonePosition();
			area.topLeftIso.x = (area.topLeftIso.x > 2)? area.topLeftIso.x - 2: 0;
			area.topLeftIso.z = (area.topLeftIso.z > 2)? area.topLeftIso.z - 2: 0;
			var nodeArray:Object = App.map._aStarNodes;
			var zID:uint  = 0;
			var cloudC:Object = { };
			function cicle(___zone:Boolean):void
			{
				for (var _scale:Number =  2.5; _scale > .5 ; _scale-= 1.5) // Шаг изменения размера тайлика
				{
					var __zone:int = 0;
					for (var _x:uint = area.topLeftIso.x; _x < area.botRightIso.x; _x += 1)// 4
					{
						for (var _z:uint = area.topLeftIso.z; _z < area.botRightIso.z; _z += 1)// 4
						{
							
							var fogCloud:FogCloud = new FogCloud(Math.floor(Math.random()*fogManager.fogsImages.length), _scale);
							//var fogCloud:FogCloud = new FogCloud(0, _scale);
							fogCloud.positionIso = { x:_x, z:_z };
							zID = fogCloud.zID;
							fogCloud.zoneID = zID;
							if ( zID != 0 && fogManager.hidenZones.indexOf (zID) != -1)
							{								
								__zone = (___zone)? zID : 0;	
								if (!collision(fogCloud, result) && fogCloud.inZone(__zone) && fogCloud.inMapPos)
								{
									result.push(fogCloud);		
								}
							}
						}
					}
				}
			}
			cicle(true);
			cicle(false);
			var re:Vector.<FogCloud> =  new Vector.<FogCloud>;
			for (var _index:String in result)
			{
				if ( !collision(result[_index], result) )
				{
					re.push(result[_index]);
				}
			}
			return result;
		}
		private var unitsList:Vector.<Unit>;
		private var unitsListDisplayd:Vector.<Unit>;
		private var wait:int = 1;
		private var startTimer:Boolean = false;
		public function addUnit(target:Unit):void
		{
			unitsList.push(target);
			addUnits();
			if (!startTimer)
			{
				startTimer = true;
				App.self.setOnTimer(timer);
				wait = 1;
			}
		}
		private function timer():void
		{
			wait--;
			if (wait < 0)
			{
				App.self.setOffTimer(timer);
				startTimer = false;
				addUnits();
			}
		}
		// расскоментировать, если необходимо добавлять верхушки юнитов не по одному а пачками сокращая количество вызовов addUnits
		private function addUnits():void
		{
			if (!reserv)
				return;
			for each(var unit:Unit in unitsList)
			{
				if (!unit.open && unit.maskBMD)
				{
					var mtr:Matrix = new Matrix();
					mtr.tx = unit.x + unit.bitmap.x - App.map.bitmap.x;
					mtr.ty = unit.y + unit.bitmap.y - App.map.bitmap.y;
					App.map.bitmap.bitmapData.draw(unit.maskBMD, mtr, null, null, null, true);
					unitsListDisplayd.push(unit);
					unitsList.splice(unitsList.indexOf(unit), 1);
				}
			}
		}
		public function clear():void
		{
			App.map.bitmap.bitmapData = reserv.clone();
			//StarlingLink.self.reAddMapTile();
		}
		
		public function clearAdditionalFog():void
		{
			var arr:Array = Map.findUnits([960]);//uщем туман
			for each(var fogg:* in arr){
				fogg.remove();
			}
		}
		
		public function addFogResources():void
		{	var unit:*;
			var childs:int;
			childs = App.map.mSort.numChildren;
			while (childs--) {
				unit = App.map.mSort.getChildAt(childs);
				if (unit is Plant)
					unit = unit.field;
				
				unit.checkFogDec();
			}
		}
		
		private static var visitWindow:VisitWindow;
		public function hideInFogs():void
		{
			if (!reserv)
				return;
			lineContainer = new Sprite();
			trace('-------->Start	' + new Date().time / 1000);
			var pos:Object = new Object();
			var posD:Object = new Object();
			var posD2:Object = new Object();
			for each(var zone:String in App.map.assetZones)
			{
				if (!World.zoneIsOpen(uint (zone)))
				{
					pos[int(zone)] = zonePosition(int(zone), 0);
					posD[int(zone)] = zonePosition(int(zone), 2);
					posD2[int(zone)] = zonePosition(int(zone), 4);
				}
			}
			
			/*visitWindow = new VisitWindow({title:Locale.__e("flash:1382952379776"), popup: true});
			visitWindow.show();*/
			clearAdditionalFog();
			clear();
			var mtr:Matrix = new Matrix();
			mtr.tx = -App.map.bitmap.x ;
			mtr.ty = -App.map.bitmap.y;
			App.map.bitmap.bitmapData.lock();
			/*for (var xD:int = 0; xD < Map.cells; xD += districtSize )
				for (var zD:int = 0; zD < Map.rows; zD += districtSize )
					sectionDraw( { x:xD, z:zD } );*/
					
			
			for (var zonee:Object in pos)
			{
				zoneDraw(pos[zonee]);
				
				var zoneSid:* = [zonee][0];
				var points:Array = new Array();
				points.push({x:pos[zonee].topLeftIso.x, z:pos[zonee].topLeftIso.z});
				points.push({x:pos[zonee].botRightIso.x, z:pos[zonee].topLeftIso.z});
				points.push({x:pos[zonee].botRightIso.x, z:pos[zonee].botRightIso.z});
				points.push({x:pos[zonee].topLeftIso.x, z:pos[zonee].botRightIso.z});
				//points.push({x:pos[zonee].botLeft.x, y:pos[zonee].botLeft.y});
				//points.push({x:pos[zonee].botRight.x, y:pos[zonee].botRight.y});
				//points.push({x:pos[zonee].topRight.x, y:pos[zonee].topRight.y});
				//points.push({x:pos[zonee].topLeft.x, y:pos[zonee].topLeft.y});
				var pointz:Object = new Object();
				pointz['points'] = points;
				var fader:Zone = new Zone(zoneSid, pointz);
				
				var world:World;
				
				if (App.user.mode == User.OWNER)
					world = App.user.world;
				else	
					world = App.owner.world;
					
				world.faders[zoneSid] = fader;
				
			}
			
			checkDepth(34, 2);
			checkDepth(10, 1);
			
			App.map.bitmap.bitmapData.unlock();
			for each(var unit:Unit in unitsListDisplayd)
			{
				unitsList.push(unit);
			}
			unitsListDisplayd.splice(0,unitsListDisplayd.length);
			addUnits();
			App.map.mLand.addChild(lineContainer);
			if (_clouds)
				_clouds.slice(0, _clouds.length);
			_clouds = null;
			trace('-------->Finish	' + new Date().time / 1000);
			addFogResources();
			/*if (visitWindow != null) 
			{
				visitWindow.close();
				visitWindow = null;
			}*/
		}
		public function dispose():void
		{
			clear();
			reserv.dispose();
			fogManager = null;
			if (unitsList)
			{
				unitsList.splice(0,unitsList.length);
				unitsListDisplayd.splice(0, unitsListDisplayd.length);
			}
			//App.self.setOffTimer(timer);
		}
		
		private function zoneOfZone():Object
		{
			var zonesResult:Object;
			var area:Object = zonePosition();
			area.topLeftIso.x = (area.topLeftIso.x > 2)? area.topLeftIso.x - 2: 0;
			area.topLeftIso.z = (area.topLeftIso.z > 2)? area.topLeftIso.z - 2: 0;
			var nodeArray:Object = App.map._aStarNodes;
			var zID:uint  = 0;
			var cloudC:Object = { };
			function cicle(___zone:Boolean):void
			{
				//for (var _scale:Number =  2.5; _scale > .5 ; _scale-= 1.5) // Шаг изменения размера тайлика
				//{
					var __zone:int = 0;
					for (var _x:uint = area.topLeftIso.x; _x < area.botRightIso.x; _x += 1)// 4
					{
						for (var _z:uint = area.topLeftIso.z; _z < area.botRightIso.z; _z += 1)// 4
						{
							
							/*var fogCloud:FogCloud = new FogCloud(Math.floor(Math.random()*fogManager.fogsImages.length), _scale);
							//var fogCloud:FogCloud = new FogCloud(0, _scale);
							fogCloud.positionIso = { x:_x, z:_z };
							zID = fogCloud.zID;
							fogCloud.zoneID = zID;
							if ( zID != 0 && fogManager.hidenZones.indexOf (zID) != -1)
							{								
								__zone = (___zone)? zID : 0;	
								if (!collision(fogCloud, zonesResult) && fogCloud.inZone(__zone) && fogCloud.inMapPos)
								{
									zonesResult.push(fogCloud);		
								}
							}*/
						}
					}
				//}
			}
			cicle(true);
			cicle(false);
			var re:Vector.<FogCloud> =  new Vector.<FogCloud>;
			/*for (var _index:String in zonesResult)
			{
				if ( !collision(zonesResult[_index], zonesResult) )
				{
					re.push(zonesResult[_index]);
				}
			}*/
			return zonesResult;
		}
		
		private function sectionDraw(point:Object):void
		{
			var mtr:Matrix = new Matrix();
			mtr.tx = -App.map.bitmap.x ;
			mtr.ty = -App.map.bitmap.y;
			var tempSprite:Sprite = new Sprite();
			for each(var cloud:FogCloud in clouds)
			{
				if (cloud.xIso >= point.x && cloud.xIso < point.x + districtSize &&
						cloud.zIso >= point.z && cloud.zIso < point.z + districtSize)
				{
					//cloud.filters = [new BlurFilter(4, 4, BitmapFilterQuality.LOW)];
					//cloud.alpha = .5;
					tempSprite.addChild(cloud);
					/*var i:Boolean = Boolean( 0);
					trace("ramdooom " + i);*/
					if(Math.random()*8 > 7){
						var bubls:Bitmap = new Bitmap(Window.textures.fog_bubbles);
						Size.size(bubls, cloud.radiusC * 2, cloud.radiusC * 2) ;
						bubls.x = cloud.x;
						bubls.y = cloud.y;
						tempSprite.addChild(bubls);
					}
					//lineContainer.graphics.lineStyle(4, 0x00061f, 1);
					//lineContainer.graphics.drawCircle(cloud.x, cloud.y, 2);
					//lineContainer.graphics.lineStyle(2, 0xf4061f, 1);
					//lineContainer.graphics.drawCircle(cloud.centerC.x, cloud.centerC.y, cloud.radiusC);
					//var coords:* = IsoConvert.isoToScreen(cloud.xIso, cloud.zIso,true);
					//lineContainer.graphics.drawCircle(coords.x, coords.y, cloud.radiusC);
				}
			}
			
			App.map.bitmap.bitmapData.draw(tempSprite, mtr, null, null, null, true);
			
			tempSprite.removeChildren();
			tempSprite = null;
		}
		
		private function zoneDraw(point:Object , blur:Boolean = false, color:uint = 0x2a7487):void
		{
			var mtr:Matrix = new Matrix();
			mtr.tx = -App.map.bitmap.x ;
			mtr.ty = -App.map.bitmap.y;
			var tempSprite:Sprite = new Sprite();
			var thisArea:Shape = new Shape();
			//var tileMapa:Bitmap = new Bitmap(Window.textures.firstMapTile);
			//maska.graphics.lineStyle(2,0xAAAAAA);
			//thisArea.graphics.beginFill(uint(Math.random()*0xFFFF)); 
			//thisArea.graphics.beginFill(color); 
			
			var matrix:Matrix = new Matrix();
           // matrix.rotate(Math.PI / 4);
			
			//thisArea.graphics.beginBitmapFill(tileMapa.bitmapData, matrix, true, true);
			thisArea.graphics.beginFill(color); 
			thisArea.graphics.moveTo(point.topLeft.x, point.topLeft.y); 
			thisArea.graphics.lineTo(point.topRight.x, point.topRight.y); 
			thisArea.graphics.lineTo(point.botRight.x, point.botRight.y); 
			thisArea.graphics.lineTo(point.botLeft.x, point.botLeft.y); 
			thisArea.graphics.lineTo(point.topLeft.x, point.topLeft.y); 
			thisArea.graphics.endFill();
			
			//thisArea.bitmapData.copyPixels(bmd, bmd.rect, copyPoint, null, null, true);
			if (blur)
			{
				thisArea.filters = [new BlurFilter(4, 4, 3)];
				thisArea.alpha = .50;
			}else
			{
				thisArea.filters = [new BlurFilter(100, 100, 3)/*, new GlowFilter(0xffffff, 1, 4, 4, 2)*/];
				//thisArea.filters = [new GlowFilter(color, 1, 4, 4, 4)];
				thisArea.alpha = .8;
			}
			//thisArea.graphics.beginFill(0xffffff, 1);
			//thisArea.graphics.drawRect(0, 0, 64, ));
			tempSprite.addChild(thisArea);
			
			//technoIcon.addChild(bitmap);
			//thisArea.cacheAsBitmap;
			/*var bd:BitmapData = new BitmapData( thisArea.width, thisArea.height );
			bd.draw(thisArea);
			
			var bmd1:BitmapData = bd;
			var bitmap1:Bitmap = new Bitmap(bmd1);
			var bmd2:BitmapData = tileMapa.bitmapData;
			var pt:Point = new Point(0, 0);
			var rect:Rectangle = new Rectangle(0, 0, thisArea.width, thisArea.height);
			var threshold:uint =  color;
			bmd2.threshold(bmd1, rect, pt, "<=", threshold);
			
			var bitmap2:Bitmap = new Bitmap(bmd2);
			bitmap2.smoothing = true;
			tempSprite.addChild(bitmap2);*/
			
			//bitmap2.x = 0;
			//bitmap2.y = 0;
			//technoIcon.visible = true;
			//layer.removeChild(preloader);
				
			//maska.alpha = .5;
			//thisArea.x = 0;
			//thisArea.y = 0;
			//thisArea.filters = [new BlurFilter(0, 4, 2)];
			//thisArea.cacheAsBitmap = true;
			/*for each(var cloud:FogCloud in clouds)
			{
				if (cloud.xIso >= point.x && cloud.xIso < point.x + districtSize &&
						cloud.zIso >= point.z && cloud.zIso < point.z + districtSize)
				{
					//cloud.filters = [new BlurFilter(4, 4, BitmapFilterQuality.LOW)];
					//cloud.alpha = .5;
					tempSprite.addChild(cloud);
					if(Math.random()*8 > 7){
						var bubls:Bitmap = new Bitmap(Window.textures.fog_bubbles);
						Size.size(bubls, cloud.radiusC * 2, cloud.radiusC * 2) ;
						bubls.x = cloud.x;
						bubls.y = cloud.y;
						tempSprite.addChild(bubls);
					}
					//lineContainer.graphics.lineStyle(4, 0x00061f, 1);
					//lineContainer.graphics.drawCircle(cloud.x, cloud.y, 2);
					//lineContainer.graphics.lineStyle(2, 0xf4061f, 1);
					//lineContainer.graphics.drawCircle(cloud.centerC.x, cloud.centerC.y, cloud.radiusC);
					//var coords:* = IsoConvert.isoToScreen(cloud.xIso, cloud.zIso,true);
					//lineContainer.graphics.drawCircle(coords.x, coords.y, cloud.radiusC);
				}
			}*/
			
			App.map.bitmap.bitmapData.draw(tempSprite, mtr, null, null, null, true);
			
			tempSprite.removeChildren();
			tempSprite = null;
		}
	}
}