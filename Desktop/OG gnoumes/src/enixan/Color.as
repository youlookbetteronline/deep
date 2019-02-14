package enixan 
{
	/**
	 * ...
	 * @author 
	 */
	public class Color 
	{
		
		public static function light(color:uint, div:int):uint {
			
			var a:int = (( color >> 24 ) & 0xFF);
			var r:int = (( color >> 16 ) & 0xFF);
			var g:int = (( color >> 8 ) & 0xFF);
			var b:int = (color & 0xFF);
			
			r += div;
			g += div;
			b += div;
			
			if (r < 0) r = 0;
			if (g < 0) g = 0;
			if (b < 0) b = 0;
			if (r > 0xFF) r = 0xFF;
			if (g > 0xFF) g = 0xFF;
			if (b > 0xFF) b = 0xFF;
			
			return ( a << 24 ) | ( r << 16 ) | ( g << 8 ) | b;
		}
		
	}

}