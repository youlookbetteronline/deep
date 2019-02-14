package silin 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	/**
	 * ...
	 * @author 111
	 */
	public class FaderPoint extends Sprite 
	{
		public var zoneId:int;
		public var pointId:int;
		public function FaderPoint(_zoneId:int, _pointId:int) 
		{
			zoneId = _zoneId;
			pointId = _pointId;
			draw();
			x = Main.main.map.faders[zoneId].points[pointId].x;
			y = Main.main.map.faders[zoneId].points[pointId].y;
			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
		private var point:Shape;
		private function draw():void{
			point = new Shape();
			point.graphics.beginFill(0xff0000, 1);
			point.graphics.drawCircle(0, 0, 2.5);
			point.graphics.endFill();
			addChild(point);
			point.filters = [new GlowFilter(0xffffff, 1, 4, 4, 4)];
		}
		
		public function onOver(event:MouseEvent):void {
			point.graphics.clear();
			point.graphics.beginFill(0xfff000, 1);
			point.graphics.drawCircle(0, 0, 2.5);
			point.graphics.endFill();
			Main.main.map.touchedPoint = this;
		}
		public function onOut(event:MouseEvent):void {
			point.graphics.clear();
			point.graphics.beginFill(0xff0000, 1);
			point.graphics.drawCircle(0, 0, 2.5);
			point.graphics.endFill();
			Main.main.map.touchedPoint = null;
		}
		
		public function updateFader():void{
			Main.main.map.faders[zoneId].points[pointId].x = this.x;
			Main.main.map.faders[zoneId].points[pointId].y = this.y;
		}
		
		public function dispose():void{
			removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onOut);
			if (parent)
				parent.removeChild(this);
		}
	}

}