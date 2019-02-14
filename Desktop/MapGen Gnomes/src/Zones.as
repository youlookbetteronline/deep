package 
{
	import core.IsoConvert;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getAliasName;
	
	/**
	 * ...
	 * @author 
	 */
	public class Zones extends Sprite 
	{	
		
		public static var mode:Boolean = false;
		public static var draw:Boolean = false;
		public static var clear:Boolean = false;
		public static var brush:int = 10;
		
		public static var fullTile:BitmapData;
		public static var emptyTile:BitmapData;
		public static var zoneTile1:BitmapData
		public static var zoneTile2:BitmapData
		public static var zoneTile3:BitmapData
		public static var zoneTile4:BitmapData
		public static var zoneTile5:BitmapData
		public static var zoneTile6:BitmapData
		public static var zoneTile7:BitmapData
		public static var zoneTile8:BitmapData
		public static var zoneTile9:BitmapData
		public static var zoneTile10:BitmapData
		public static var zoneTile11:BitmapData
		public static var point:BitmapData
		
		private static const RED:uint = 0xFF0000;
		private static const GREEN:uint = 0x00FF00;
		private static const BLUE:uint = 0x0000FF;
		private static const BLACK:uint = 0x000000;
		private static const WHITE:uint = 0xFFFFFF;
		private static const CYAN:uint = 0x00FFFF;
		private static const MAGENTA:uint = 0xFF00FF;
		private static const YELLOW:uint = 0xFFFF00;
		private static const LIGHT_GREY:uint = 0xCCCCCC;
		private static const MID_GREY:uint = 0x999999;
		private static const DARK_GREY:uint = 0x666666;
		
		public static var currentZoneTile:BitmapData = null
		public static var currentZoneIndex:int = -1;
		
		public function Zones()
		{
			
		}
		
		public static var colors:Array = [0x33FF99,0x9900FF,0x334466,0xAA9900,0xAAFF44,0x115511,0x7FFF00,0xFF1133,0x6666DD,0x0000FF,0x00FFFF,0xFF00FF,0xFFFF00,0x00FF00,0xFF0000,0x006699,0x990000,0x666600,0x339999,0xFF6633,0xF09030];
		
		public static function createTiles():void
		{
			fullTile = drawTile(BLACK, 1);
			emptyTile = drawTile(WHITE, 1);
			zoneTile1 = drawTile(GREEN, 1);
			zoneTile2 = drawTile(BLUE, 1);
			zoneTile3 = drawTile(YELLOW, 1);
			zoneTile4 = drawTile(MAGENTA, 1);
			zoneTile5 = drawTile(CYAN, 1);
			
			zoneTile6 = drawTile(RED, 1);
			zoneTile7 = drawTile(0xdfa056, 1);
			zoneTile8 = drawTile(0x42dfb1, 1);
			zoneTile9 = drawTile(0xf7aba3, 1);
			zoneTile10 = drawTile(0x9876f7, 1);
			zoneTile11 = drawTile(colors[11], 1);
			
			point = drawPoint(GREEN, 1);
			
			currentZoneTile = zoneTile1;
			currentZoneIndex = 1;
		}	
		
		public static function drawTile(color:*, alpha:Number):BitmapData
		{
			var cont:Sprite = new Sprite();
			var _cont:Sprite = new Sprite();
			var shape:Shape = new Shape();
			var bmd:BitmapData;
			shape.graphics.beginFill(color, alpha);
			shape.graphics.drawRect(0, 0, 26, 26);
			shape.graphics.endFill();
			shape.rotation = 45;
			
			cont.addChild(shape)
			cont.height = cont.height / 2;
			_cont.addChild(cont);
			cont.x = cont.width/2;
			bmd = new BitmapData(_cont.width, _cont.height, true, 0);
			bmd.draw(_cont);
			
			return bmd;
		}
		
		private static function drawPoint(color:*, alpha:Number):BitmapData
		{
			var cont:Sprite = new Sprite();
			var _cont:Sprite = new Sprite();
			var shape:Shape = new Shape();
			var bmd:BitmapData;
			shape.graphics.beginFill(color, alpha);
			shape.graphics.drawRect(0, 0, 5,5);
			shape.graphics.endFill();
			
			cont.addChild(shape)
			_cont.addChild(cont);
			
			bmd = new BitmapData(_cont.width, _cont.height, true, 0);
			bmd.draw(_cont);
			
			return bmd;
		}
		
		public static function changeZoneMarker(marker:uint):void
		{
			currentZoneIndex = marker;
			switch(marker)
			{
				case 1:
					currentZoneTile = zoneTile1;
					break;
				case 2:
					currentZoneTile = zoneTile2;
					break
				case 3:
					currentZoneTile = zoneTile3;
					break
				case 4:
					currentZoneTile = zoneTile4;
					break	
				case 5:
					currentZoneTile = zoneTile5;
					break		
				case 6:
					currentZoneTile = zoneTile6;
					break;
				case 7:
					currentZoneTile = zoneTile7;
					break
				case 8:
					currentZoneTile = zoneTile8;
					break
				case 9:
					currentZoneTile = zoneTile9;
					break	
				case 10:
					currentZoneTile = zoneTile10;
					break
				case 11:
					currentZoneTile = zoneTile11;
					break
				default:
					currentZoneTile = drawTile(colors[marker], 1);
			}
		}
		
		public static function onZoneBttnClick(e:Event):void
		{
			mode = !mode;
			if (mode == false)
			{
				Map.self.mIso.visible = false;
				Map.self.setOffEnterFrame(onMouseMove);
			}
			else
			{
				Map.self.createIsoTiles();
				Map.self.setOnEnterFrame(onMouseMove);
			}
		}
		
		public static function changeBrush(event:Event):void
		{
			brush = event.currentTarget.data;
		}
		
		public static function showZones():void
		{
			Map.self.zonesLayer.visible = !Map.self.zonesLayer.visible; 
		}
		
		public static function onMouseMove():void
		{
			/*var point:Object = IsoConvert.screenToIso(Map.self.mouseX, Map.self.mouseY, true);
			var i:int = 0;
			var j:int = 0;
			
			//trace(point.x, point.y);
			if (draw == true) {
				for (i = 0; i < brush; i++)
				{
					for (j = 0; j < brush; j++)
					{
						if (point.x + i >= Map.X || point.z + j >= Map.Z || point.z<0 || point.x<0) continue;
						
						
						if (Map.markersData[point.x + i] == null) return;
						if (Map.markersData[point.x + i][point.z + j] == null) return;
						Map.self.changeGridItem(point.x + i, point.z + j, "1");
					}
				}
			}
			
			if (clear == true)
			{
				for (i = 0; i < brush; i++)
				{
					for (j = 0; j < brush; j++)
					{
						if (point.x + i >= Map.X || point.z + j >= Map.Z || point.z<0 || point.x<0) continue;
						
						if (Map.markersData[point.x + i] == null) return;
						if (Map.markersData[point.x + i][point.z + j] == null) return;
						Map.self.changeGridItem(point.x + i, point.z + j, "0");
					}
				}
			}*/
			
		}
	}
}