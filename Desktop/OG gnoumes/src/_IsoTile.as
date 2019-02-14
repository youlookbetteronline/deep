package 
{
	import flash.geom.Point;
	
	public class IsoTile {
		
		public static var WIDTH:Number = 26; /*40;*/
		public static var HEIGHT:Number = 20; /*21;*/
		
		public static function poleToIso(point:Point, scale:Number = 1):Point {
			var result:Point = new Point();
			result.x = Math.floor((2 * point.y + point.x) / (2 * WIDTH * scale / 2));
			result.y = Math.floor((2 * point.y - point.x) / (2 * HEIGHT * scale));
			return(result);
		}
		
		public static function isoToPole(point:Point):Point {
			var result:Point = new Point();
			result.x = (point.x - point.y) * WIDTH / 2;
			result.y = ((point.x + point.y) / 2) * HEIGHT;
			return(result);
		}
		
	}

}