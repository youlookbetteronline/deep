package effects
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import silin.filters.ColorAdjust;
	
	/**
	 * ...
	 * @author 
	 */
	public class Effect extends Sprite {
		
		public static function light(target:*, brightness:Number = 0, saturation:Number = 1):void {
			if(target is DisplayObject) {
				var mtrx:ColorAdjust = new ColorAdjust();
				mtrx.saturation(saturation);
				mtrx.brightness(brightness);
				target.filters = [mtrx.filter];
			}
		}
		
	}
}