package 
{
	import com.flashdynamix.motion.extras.BitmapTiler;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import units.Wall;
	import wins.RoomFader;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	public class Room extends LayerX
	{
		public static var LOWER:int = 0;
		public static var FULL:int = 1;
		public static var mayChecked:Boolean = true;
		public static var checkTime:Number = .4;
		public static var zoneData:Object = { };
		
		public var roomObjects:Object = new Object();
		public var thisZoneID:int;
		public function Room(zoneId:int)
		{
			thisZoneID = zoneId;
			
			if (!World.zoneIsOpen(thisZoneID) && thisZoneID != 0)
			{
			//if(thisZoneID != 0)
				drawFader();
			}
			if (thisZoneID != 0 && thisZoneID != 1304 && thisZoneID != 1307)
			{
				drawFloor();
			}
		}
		
		public function newRoomObject(unit:*):void
		{
			roomObjects[unit.id] = unit;
		}
		
		
		public function steteRoom(state:int):void
		{
			for each(var rUnit:Wall in roomObjects)
			{
				rUnit.wallState = state;
				rUnit.checkWallState();
			}
		}
		
		public function refreshSteteRoom():void
		{
			for each(var rUnit:Wall in roomObjects)
			{
				rUnit.checkWallState();
			}
		}
		public function removeFader():void
		{
			if (fader && fader.parent)
				fader.parent.removeChild(fader);
				
			if (additionalFader && additionalFader.parent)
				additionalFader.parent.removeChild(additionalFader);
		}
		public var fader:RoomFader;
		public var additionalFader:RoomFader;
		public function drawFader():void
		{
			//return;
			//var shapeFader:Shape = new Shape();
			var addit:Boolean = false;
			if (thisZoneID == 1307)
				addit = true;
			fader = new RoomFader(zoneData[thisZoneID].rows, zoneData[thisZoneID].cells, zoneData[thisZoneID], addit, thisZoneID);
			//var height:uint = 0;//140
			if (thisZoneID == 822)
			{
				additionalFader = new RoomFader(zoneData['add1'].rows, zoneData['add1'].cells, zoneData['add1'], true, 822);
				App.map.mSort.addChild(additionalFader);
				App.map.depths.push(additionalFader);
				App.map.sorted.push(additionalFader);
			}
			
			if (thisZoneID == 1303)
			{
				additionalFader = new RoomFader(zoneData['add2'].rows, zoneData['add2'].cells, zoneData['add2'], true, 1303);
				App.map.mSort.addChild(additionalFader);
				App.map.depths.push(additionalFader);
				App.map.sorted.push(additionalFader);
			}
			App.map.mSort.addChild(fader);
			App.map.depths.push(fader);
			App.map.sorted.push(fader);
		}
		
		public static function generateZoneCorners():void 
		{
			zoneData = {
			//Oracle
			'822':{
				'corners':{
					0:{x:39,z:12},
					1:{x:63,z:12},
					2:{x:63,z:30},
					3:{x:39,z:30}
				},
				'cells':63 - 39,
				'rows':30 - 12,
				'floor':'floor3'
			},
			'add1':{
				'corners':{
					0:{x:39,z:11},
					1:{x:63,z:11},
					2:{x:63,z:12},
					3:{x:39,z:12}
				},
				'cells':63 - 39,
				'rows':12 - 11
			},
			'add2':{
				'corners':{
					0:{x:12,z:39},
					1:{x:13,z:39},
					2:{x:13,z:56},
					3:{x:12,z:56}
				},
				'cells':13 - 12,
				'rows':56 - 39
			},
			'1306':{
				'corners':{
					0:{x:48,z:39},
					1:{x:63,z:39},
					2:{x:63,z:56},
					3:{x:48,z:56}
				},
				'cells':63 - 48,
				'rows':56 - 39,
				'floor':'floor1'
			},
			'1305':{
				'corners':{
					0:{x:32,z:39},
					1:{x:47,z:39},
					2:{x:47,z:56},
					3:{x:32,z:56}
				},
				'cells':47 - 32,
				'rows':56 - 39,
				'floor':'floor5'
			},
			'1307':{
				'corners':{
					0:{x:9,z:8},
					1:{x:26,z:8},
					2:{x:26,z:26},
					3:{x:9,z:26}
				},
				'cells':26 - 9,
				'rows':26 - 8,
				'floor':'floor4'
			},
			'1303':{
				'corners':{
					0:{x:13,z:39},
					1:{x:31,z:39},
					2:{x:31,z:56},
					3:{x:13,z:56}
				},
				'cells':31 - 13,
				'rows':56 - 39,
				'floor':'floor2'
			}};
			/*for (var x:int = 0; x < Map.cells; x++)
			{
				for (var z:int = 0; z < Map.rows; z++)
				{
					var zID:* = App.map._aStarNodes[x][z].z;
					
					if(!zoneData.hasOwnProperty(zID))
						zoneData[zID] = { minX:1000, minZ:1000, maxX:0, maxZ:0, objects:[] };
					
					zoneData[zID].minX = Math.min(zoneData[zID].minX, x);
					zoneData[zID].minZ = Math.min(zoneData[zID].minZ, z);
					zoneData[zID].maxX = Math.max(zoneData[zID].maxX, x);
					zoneData[zID].maxZ = Math.max(zoneData[zID].maxZ, z);
				}
			}
			
			var delta:int = 0;
			for (zID in zoneData) 
			{
				zoneData[zID]['corners'] = [];
				zoneData[zID].corners[0] = { x:zoneData[zID].minX - delta, z:zoneData[zID].minZ + 1 };
				zoneData[zID].corners[1] = { x:zoneData[zID].maxX + delta, z:zoneData[zID].minZ + 1 };
				zoneData[zID].corners[2] = { x:zoneData[zID].maxX + delta, z:zoneData[zID].maxZ + delta };
				zoneData[zID].corners[3] = { x:zoneData[zID].minX - delta, z:zoneData[zID].maxZ + delta };
				
				zoneData[zID]['cells'] = zoneData[zID].maxX - zoneData[zID].minX;
				zoneData[zID]['rows'] = zoneData[zID].maxZ - zoneData[zID].minZ;
			}*/
		}
		private var floorElement:LayerX = new LayerX();
		public function drawFloor():void
		{
			Load.loading(Config.getImage('floor', (zoneData[thisZoneID].floor)), onLoadFloor);
		}
		
		
		public function onLoadFloor(data:*):void 
		{
			floorElement = new LayerX();
			
			var point:Object = IsoConvert.isoToScreen(zoneData[thisZoneID].corners[0].x, zoneData[thisZoneID].corners[0].z, true);
			floorElement.graphics.moveTo(point.x, point.y -height);
			floorElement.graphics.beginFill(0xff0000, 1);
			floorElement.graphics.beginBitmapFill(data.bitmapData, null, true, false);
			
			for (var i:int = 1; i < Numbers.countProps(zoneData[thisZoneID].corners); i++) {
				point = IsoConvert.isoToScreen(Numbers.getProp(zoneData[thisZoneID].corners, i).val.x,Numbers.getProp(zoneData[thisZoneID].corners, i).val.z, true);
				floorElement.graphics.lineTo(point.x, point.y - height);
			}
			
			point = IsoConvert.isoToScreen(zoneData[thisZoneID].corners[0].x, zoneData[thisZoneID].corners[0].z, true);
			floorElement.graphics.lineTo(point.x, point.y - height);
			floorElement.graphics.endFill();
			
			App.map.mLand.addChildAt(floorElement,0);
		}
		
		public function dispose():void 
		{
			if (parent)
				parent.removeChild(this);
			removeFader();
		}
	}
}