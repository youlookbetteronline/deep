package enixan 
{
	import enixan.Size;
	import flash.display.Bitmap;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public class BitmapLoader extends Sprite 
	{
		
		private var currWidth:int;
		private var currHeight:int;
		private var scale:Number;
		public var link:String;
		
		private var shape:Shape;
		private var bitmap:Bitmap;
		private var onload:Function;
		
		/**
		 * Загрузка картинки и установка ее в соответствии с размерами
		 * @param	view	Ссылка или sid
		 */
		public function BitmapLoader(view:*, width:int = 0, height:int = 0, scale:Number = 1, onload:Function = null) 
		{
			super();
			
			currWidth = width;
			currHeight = height;
			this.scale = scale;
			this.onload = onload;
			
			if (view is String && view.length > 0)
				link = view;
			
			if (!link) return;
			
			Util.load(link, onLoad);
			
			shape = new Shape();
			shape.graphics.beginFill(0xff0000, 0.0);
			shape.graphics.drawRect(0, 0, currWidth, currHeight);
			shape.graphics.endFill();
			addChild(shape);
			
			if (bitmap || currWidth == 0 || currHeight == 0) return;
			
		}
		
		private function onLoad(data:Bitmap):void {
			if (shape) {
				removeChild(shape);
				shape = null;
			}
			
			bitmap = new Bitmap(data.bitmapData, PixelSnapping.AUTO, true);
			addChild(bitmap);
			
			if (currWidth > 0 && currHeight > 0) {
				Size.size(bitmap, currWidth, currHeight);
				
				if (currWidth > bitmap.width) {
					bitmap.x = currWidth * 0.5 - bitmap.width * 0.5;
				}
				if (currHeight > bitmap.height) {
					bitmap.y = currHeight * 0.5 - bitmap.height * 0.5;
				}
			}
			
			if (onload != null)
				onload();
		}
		
	}

}