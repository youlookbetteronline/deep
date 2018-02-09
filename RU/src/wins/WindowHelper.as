package wins 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author ...
	 */
	public class WindowHelper
	{
		
		public function WindowHelper() 
		{
			super();
			
		}
		
		public static function drawPopup(width:int, height:int, radius:int = 30, color:uint = 0xffffff, glowColor:uint = 0x3c6374, alpha:Number = .8, tw:int = 30, th:int = 15):Bitmap 
		{	
			var bg:Sprite = new Sprite();
			var back:Shape = new Shape();
			
			back.graphics.beginFill(0xffffff, alpha);
			back.graphics.drawRoundRect(0, 0, width, height, 30);
			back.graphics.endFill();
			var triangle:Shape = new Shape(); 
			
			var background:Bitmap = new Bitmap(new BitmapData(back.width, back.height + th, true, 0));
			triangle.graphics.beginFill(color, 1);
			triangle.graphics.moveTo(0, 0); 
			triangle.graphics.lineTo(tw, 0); 
			triangle.graphics.lineTo(tw / 2, th); 
			triangle.graphics.lineTo(0, 0);
			background.bitmapData.draw(back);
			background.bitmapData.draw(triangle, new Matrix(1, 0, 0, 1, back.width / 2 - triangle.width / 2, back.height));
			
			
			background.filters = [new GlowFilter(glowColor, 1, 2, 2, 2, 1, true)];
			
			bg.addChild(background);
			bg.alpha = alpha
			var resBitmap:Bitmap = new Bitmap(new BitmapData(bg.width, bg.height, true, 0))
			resBitmap.bitmapData.draw(bg)
			return background;
		}
		
	}

}