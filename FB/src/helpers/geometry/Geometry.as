/**
 * Created by Andrew on 15.05.2017.
 */
package helpers.geometry
{
	import flash.geom.Point;

	public class Geometry
	{
	/**
	 * проверка пересечения линий (a;b) и (c;d)
	 */
		public static function isIntersecting(a:Point , b:Point , c:Point , d:Point ):Boolean
		{
			var denominator:Number = ((b.x - a.x) * (d.y - c.y)) - ((b.y - a.y) * (d.x - c.x));
			var numerator1:Number = ((a.y - c.y) * (d.x - c.x)) - ((a.x - c.x) * (d.y - c.y));
			var numerator2:Number = ((a.y - c.y) * (b.x - a.x)) - ((a.x - c.x) * (b.y - a.y));

			// Detect coincident lines (has a problem, read below)
			if (denominator == 0) return numerator1 == 0 && numerator2 == 0;

			var r:Number = numerator1 / denominator;
			var s:Number = numerator2 / denominator;

			return (r >= 0 && r <= 1) && (s >= 0 && s <= 1);
		}

		/**
		 * получить случайную точку на линии (p1;p2)
		 */
		public static function getRandomPosBetween(p1:Point, p2:Point):Point {
			return Point.interpolate(p1, p2, Math.random());
		}
	}
}
