package effects
{
	import core.IsoConvert;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import silin.filters.ColorAdjust;
	
	/**
	 * ...
	 * @author 
	 */
	public class Effect extends Sprite
	{
		
		public function Effect(type:String, layer:Sprite)
		{
			//
		}
		
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