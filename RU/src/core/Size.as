package core 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
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
		
		public static function scaleBD(bitmapData:BitmapData, scaleX:Number = 1, scaleY:Number = 1):BitmapData 
		{
            var width:int = Math.abs(bitmapData.width * scaleX) || 1;
            var height:int = Math.abs(bitmapData.height * scaleY) || 1;
            var transparent:Boolean = bitmapData.transparent;
            var result:BitmapData = new BitmapData(width, height, transparent, 0x0);
            var matrix:Matrix = new Matrix();
            matrix.scale(scaleX, scaleY);
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
		
		public static function rectBorderBitmap(bitmap:Bitmap, width:int = 54, height:int = 54, radius:int = 20, color:uint = 0xffffff, thickness:int = 3):Bitmap
		{
			var _bitmap:Bitmap = new Bitmap();
			var _sprite:Sprite = new Sprite();
			var _mask:Shape = new Shape();
			var shape:Shape = new Shape();
			shape.graphics.beginFill(color);
			shape.graphics.drawRoundRect(0, 0, width, height, radius, radius);
			shape.graphics.endFill();
			
			_sprite.addChild(shape);
			
			Size.size(bitmap, width - thickness * 2, height - thickness * 2);
			bitmap.smoothing = true;
			bitmap.x = (_sprite.width - bitmap.width) / 2;
			bitmap.y = (_sprite.height - bitmap.height) / 2;
			_sprite.addChild(bitmap);
			
			_mask.graphics.beginFill(color);
			_mask.graphics.drawRoundRect(0, 0, bitmap.width, bitmap.height, radius*.8, radius*.8);
			_mask.graphics.endFill();
			_mask.x = (_sprite.width - _mask.width) / 2;
			_mask.y = (_sprite.height - _mask.height) / 2;
			_sprite.addChild(_mask);
			bitmap.mask = _mask;
			
			_bitmap.bitmapData = new BitmapData(width, height, true, 0)
			_bitmap.bitmapData.draw(_sprite, new Matrix(1, 0, 0, 1, 0, 0));
			return _bitmap;
		}

		
	}

}