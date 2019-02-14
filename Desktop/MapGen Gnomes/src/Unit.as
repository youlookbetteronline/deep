package 
{
	import core.IsoConvert;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.filesystem.*
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author 
	 */
	public class Unit extends Sprite 
	{
		public const OCCUPIED:uint 		= 1;
		public const EMPTY:uint 		= 2;
		public const TOCHED:uint 		= 3;
		public const DEFAULT:uint 		= 4;
		
		public var bitmap:Bitmap = new Bitmap();
		public var _touch:Boolean = false;
		public var touchable:Boolean 	= true;
		protected var _state:uint 		= DEFAULT;
		private var _move:Boolean 		= false;
		public var coords:Object = { x:0, y:0, z:0 };
		private var dx:int = 0;
		private var dy:int = 0;
		public var depth:uint = 0;
		public var label:String = "non";
		public var url:String = "non";
		
		public function set index(value:uint):void
		{
			depth = value;
		}
		
		public function Unit(settings:Object)
		{
			label = settings.label;
			addChild(bitmap);
			Map.units.push(this);
			url = "http://dreams.islandsville.com/resources/dreams/" + settings.img;
			Load.loading(url, onLoad);
		}
		
		public function getIsoCoords():Object
		{
			var coords:Object = IsoConvert.screenToIso(this.x, this.y, false);
			return coords;
		}
		
		private function onLoad(data:Bitmap):void
		{
			bitmap.bitmapData = data.bitmapData;
			this.x = Map.main.width/2 - Map.self.x - bitmap.width/2;
			this.y = Map.main.height/2 - Map.self.y - bitmap.height/2;
		}
		
		public function get bmp():Bitmap {
			return bitmap;
		}
		
		public function set touch(touch:Boolean):void {
			if (!touchable) return;
			
			_touch = touch;
			
			if (touch) {
				if(state == DEFAULT){
					state = TOCHED;
				}
			}else {
				if(state == TOCHED){
					state = DEFAULT;
				}
			}
		}
		
		protected function get state():uint {
			return _state;
		}
		
		public function get touch():Boolean {
			return _touch;
		}
		
		protected function set state(state:uint):void {
			if (_state == state) return;
			switch(state) {
				case OCCUPIED: bitmap.filters = [new GlowFilter(0xFF0000,1, 4,4,5)]; break;
				case EMPTY: bitmap.filters = [new GlowFilter(0x00FF00,1, 4,4,5)]; break;
				case TOCHED: bitmap.filters = [new GlowFilter(0xFFFF00,1, 4,4,5)]; break;
				case DEFAULT: bitmap.filters = []; break;
			}
			_state = state;
		}
		
		public function placing(x:uint, y:uint, z:uint):void
		{
			//coords = { x:x, y:0, z:z };
			//trace(x, y, z);
			//var point:Object = IsoConvert.isoToScreen(x,z);
			this.x = Map.self.mouseX - dx;
			this.y = Map.self.mouseY - dy;
			
			//calcDepth();
		}
		
		private function moving():void {
			placing(Map.X, 0, Map.Z);
			//if (coords.x != Map.X || coords.z != Map.Z) {
				
				/*if (layer == Map.LAYER_SORT)
				{
					App.map.depths[index] = depth;
					App.map.sorted.push(this);
				}*/	
			//}
		}
		
		public function scale(value:Number):void
		{
			bitmap.width	= bitmap.bitmapData.width * value;
			bitmap.height 	= bitmap.bitmapData.height * value;
		}
	}
}