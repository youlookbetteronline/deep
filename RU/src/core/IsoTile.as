package core
{
	import flash.display.BitmapData;
	public class IsoTile 
	{
		
		[Embed(source = "tile.png")]
		private static var Tile:Class;
		public static const _tile:BitmapData = new Tile().bitmapData;	
		
		public static const width:uint = _tile.width;
		public static const height:uint = 20;//_tile.height;
		
		public static const spacing:Number = int(Math.sqrt(5 * Math.pow(_tile.width, 2) / 16));
		
		public var isoX:int = 0;
		public var isoY:int = 0;
		public var isoZ:int = 0;
		
		public var x:int = 0;
		public var y:int = 0;
		
		public var center:Object = { x:x, y:y };

		public function IsoTile(x:int = 0, y:int = 0) 
		{
			this.x = x;
		
			this.y = y;
			
			center.x = x + _tile.width * 0.5;
			center.y = y + _tile.height * 0.5;
		}
	}
}