package wins 
{
	import core.IsoConvert;
	import core.IsoTile;
	import core.Numbers;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	/**
	 * ...
	 * @author 
	 */
	public class RoomFader extends LayerX 
	{
		
		public var cells:uint = 0;
		public var rows:uint = 0;
		public var depth:uint = 0;
		public var sid:int = 0;
		public var data:Object;
		public var additional:Boolean;
		public function RoomFader(_cells:uint, _rows:uint, _data:Object, _additional:Boolean = false, _zone:int = 0) 
		{
			cells = _cells;
			rows = _rows;
			data = _data;
			additional = _additional;
			
			super();
			
			if (additional && _zone!= 0)
			{
				drawAdditional(_zone);
			}else
				draw();
				
			calcDepth();
		}
		
		public function draw():void
		{
			var fader:Shape = new Shape();
			var point:Object = IsoConvert.isoToScreen(data.corners[0].x, data.corners[0].z, true);
			fader.graphics.moveTo(point.x, point.y -height);
			fader.graphics.beginFill(0x000000, 1);
			
			for (var i:int = 1; i < Numbers.countProps(data.corners); i++) {
				point = IsoConvert.isoToScreen(Numbers.getProp(data.corners, i).val.x,Numbers.getProp(data.corners, i).val.z, true);
				fader.graphics.lineTo(point.x, point.y - height);
			}
			
			point = IsoConvert.isoToScreen(data.corners[0].x, data.corners[0].z, true);
			fader.graphics.lineTo(point.x, point.y - height);
			fader.graphics.endFill();
			fader.filters = [new BlurFilter(10, 10)];
			fader.alpha = 0.5;
			addChild(fader);
		}
		
		public function drawAdditional(zone:int = 0):void
		{
			var fader:Shape = new Shape();
			var point:Object;
			if (zone == 822)
			{
				point = IsoConvert.isoToScreen(data.corners[0].x, data.corners[0].z, true);
				point.y -= 16;
				fader.graphics.moveTo(point.x, point.y);
				fader.graphics.beginFill(0x000000, 1);
				
				point = IsoConvert.isoToScreen(data.corners[0].x, data.corners[0].z, true);
				point.y -= 143;
				point.x += 4;
				fader.graphics.lineTo(point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[1].x, data.corners[1].z, true);
				point.y -= 170;
				point.x -= 38;
				fader.graphics.lineTo(point.x, point.y);
				
				/*point = IsoConvert.isoToScreen(data.corners[1].x, data.corners[1].z, true);
				point.y -= 124;
				point.x -= 10;
				fader.graphics.lineTo(point.x, point.y);*/
				
				point = IsoConvert.isoToScreen(data.corners[1].x, data.corners[1].z, true);
				point.y -= 124;
				point.x -= 6;
				fader.graphics.curveTo(point.x - 8, point.y - 25, point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[1].x, data.corners[1].z, true);
				point.x -= 6;
				point.y += 20;
				fader.graphics.lineTo(point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[2].x, data.corners[2].z, true);
				fader.graphics.lineTo(point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[3].x, data.corners[3].z, true);
				fader.graphics.lineTo(point.x, point.y);
				
				//point = IsoConvert.isoToScreen(data.corners[0].x, data.corners[0].z, true);
				//point.y -= 16;
				//fader.graphics.lineTo(point.x, point.y);
				fader.graphics.endFill();
			}
			
			if (zone == 1303)
			{
				point = IsoConvert.isoToScreen(data.corners[3].x, data.corners[3].z, true);
				point.x += 26;
				fader.graphics.moveTo(point.x, point.y);
				fader.graphics.beginFill(0x000000, 1);
				
				point = IsoConvert.isoToScreen(data.corners[3].x, data.corners[3].z, true);
				point.y -= 110;
				point.x += 23;
				fader.graphics.lineTo(point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[3].x, data.corners[3].z, true);
				point.y -= 175;
				point.x += 48;
				//fader.graphics.lineTo(point.x, point.y);
				fader.graphics.curveTo(point.x - 27, point.y + 27, point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[1].x, data.corners[1].z, true);
				point.y -= 158;
				point.x -= 20;
				fader.graphics.lineTo(point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[1].x, data.corners[1].z, true);
				point.x -= 20;
				point.y -= 24;
				fader.graphics.lineTo(point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[1].x, data.corners[1].z, true);
				point.x -= 3;
				point.y -= 1;
				fader.graphics.lineTo(point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[2].x, data.corners[2].z, true);
				fader.graphics.lineTo(point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[3].x, data.corners[3].z, true);
				point.x += 30;
				fader.graphics.lineTo(point.x, point.y);
				fader.graphics.endFill();
			}
			
			if (zone == 1307)
			{
				point = IsoConvert.isoToScreen(data.corners[1].x, data.corners[1].z, true);
				point.y -= 80;
				point.y += 10;
				point.x += 33;
				fader.graphics.moveTo(point.x, point.y);
				fader.graphics.beginFill(0x000000, 1);
				
				point = IsoConvert.isoToScreen(data.corners[1].x, data.corners[1].z, true);
				point.y += 10;
				point.x += 32;
				fader.graphics.lineTo(point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[2].x, data.corners[2].z, true);
				point.y -= 13;
				point.x += 70;
				fader.graphics.lineTo(point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[2].x, data.corners[2].z, true);
				point.y -= 6;
				point.x -= 30;
				fader.graphics.curveTo(point.x + 45, point.y + 9, point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[3].x, data.corners[3].z, true);
				point.y += 4;
				point.x -= 30;
				fader.graphics.lineTo(point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[3].x, data.corners[3].z, true);
				point.y -= 80;
				point.y += 0;
				point.x -= 32;
				fader.graphics.lineTo(point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[0].x, data.corners[0].z, true);
				point.y -= 80;
				point.y += 22;
				point.x -= 60;
				fader.graphics.lineTo(point.x, point.y);
				
				point = IsoConvert.isoToScreen(data.corners[0].x, data.corners[0].z, true);
				point.y -= 80;
				point.y += 20;
				point.x += 40;
				fader.graphics.curveTo(point.x - 50, point.y - 16, point.x, point.y);
				
				fader.graphics.endFill();
			}
			fader.filters = [new BlurFilter(10, 10)];
			fader.alpha = 0.5;
			
			addChild(fader);
		}
		
		public function calcDepth():void
		{
			var left:Object = {x: x - IsoTile.width * rows * .5, y: y + IsoTile.height * rows * .5};
			var right:Object = {x: x + IsoTile.width * cells * .5, y: y + IsoTile.height * cells * .5};
			depth = (left.x + right.x) + (left.y + right.y) * 100;
		}
		
		public static function removeFader(zID:int):void
		{
			if (App.map.rooms[zID])
			{
				App.map.rooms[zID].removeFader();
				//delete App.map.rooms[zID];
			}
			
		}
		
	}

}