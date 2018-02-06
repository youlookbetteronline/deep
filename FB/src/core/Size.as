package core 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Size 
	{
		
		public static function size(target:*, width:Number, height:Number, widthFirst:Boolean = true):void {
			if (!target) return;
			
			if (widthFirst) {
				toWidth();
				toHeight();
			}else {
				toHeight();
				toWidth();
			}
			
			function toWidth():void {
				if (target.width > width) 
				{
					target.width = width;
					target.scaleY = target.scaleX;
				}
			}
			function toHeight():void {
				if (target.height > height) 
				{
					target.height = height;
					target.scaleX = target.scaleY;
				}
			}
		}
		public static function fitImtoTextField(title:TextField):void 
		{
			var brokenWord : Boolean = false;
			var lii : Number = 0;
			var lcc : String;
			for (var ci : int = 0;ci < title.text.length;ci++) {
			var cc : String = title.text.charAt(ci);
			var li : Number = title.getLineIndexOfChar(ci);
			if(li != lii) {
			//	//trace("New Line");
			if(lcc != " " && lcc != "\r" && lcc != "\n") {
			//	//trace(" broken word!");
			brokenWord = true;
			
			var maxTextWidth:int = 145; 
			var maxTextHeight:int = 30; 

			var f:TextFormat = title.getTextFormat();

			//decrease font size until the text fits  
			
			f.size = int(f.size) - 1;
			title.setTextFormat(f);
			fitImtoTextField(title);
			
			
			}
			}
			lii = li;
			lcc = cc;
			//	//trace(cc + " " + li);
			}
		}
		
		public static function scaleBitmapData(bitmapData:BitmapData, scale:Number):BitmapData 
		{
            scale = Math.abs(scale);
            var width:int = (bitmapData.width * scale) || 1;
            var height:int = (bitmapData.height * scale) || 1;
            var transparent:Boolean = bitmapData.transparent;
            var result:BitmapData = new BitmapData(width, height, transparent, 0x0);
            var matrix:Matrix = new Matrix();
            matrix.scale(scale, scale);
            result.draw(bitmapData, matrix, null, null, null, true);
            return result;
        }
		
		public static function flipBitmapData(bitmapData:BitmapData, horisontal:Boolean = true, vertical:Boolean = false):BitmapData
		{
			var scaleX:int = 1;
			var scaleY:int = 1;
			if (horisontal)
				scaleX = -1;
			if (vertical)
				scaleY = -1;
				
			var bmp2:BitmapData = new BitmapData (bitmapData.width, bitmapData.height,true, 0xff);
			var matrix:Matrix = new Matrix ();
			matrix.scale (scaleX, scaleY)
			if(horisontal)
				matrix.tx = bitmapData.width;
			if (vertical)
				matrix.ty = bitmapData.height;
			bmp2.draw (bitmapData, matrix)
			
            return bmp2;
        }

		
	}

}