package core
{
	
	public class IsoTile 
	{
		
		public static const width:uint = 26;//40;
		public static const height:uint = 20;// 21;
		
		public static const spacing:Number = Number(Math.sqrt(5 * Math.pow(width, 2) / 13.2));
		
		public var x:int = 0;
		public var y:int = 0;
		
		public var center:Object = { x:x, y:y };

		public function IsoTile(x:int = 0, y:int = 0) 
		{
			this.x = x;
			this.y = y;
			
			center.x = x + width * 0.5;
			center.y = y + height * 0.5;
		}
	}
}