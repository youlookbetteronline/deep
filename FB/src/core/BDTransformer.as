package core 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import ui.UserInterface;
	
	public class BDTransformer 
	{
		public static const HORISONTAL:uint = 0;
		public static const VERTICAL:uint = 1;
		public static const BOTH:uint = 2;
		
		public function BDTransformer() {
			
		}
		
		public static function flipBitmapData(bd:BitmapData,direction:uint = HORISONTAL):BitmapData {
			var bigBm:BitmapData = bd;
			var horizDir:int = int([HORISONTAL, BOTH].indexOf(direction) != -1) * ( -1);
			var vertDir:int = int([VERTICAL, BOTH].indexOf(direction) != -1) * ( -1);
/*			var matrix:Matrix = new Matrix( horizDir, vertDir, int(direction == VERTICAL), int(direction == HORISONTAL),
											bigBm.width * int(direction == HORISONTAL), bigBm.height * int(direction == VERTICAL))*/
			var matrix:Matrix = new Matrix( horizDir, vertDir, 0, 1, bigBm.width, 0);
			var smallBMD:BitmapData = new BitmapData(bigBm.width, bigBm.height, true, 0x000000);
			smallBMD.draw(bigBm,  matrix,  null, null, null, true);
			bd = smallBMD;
			return smallBMD;
		}
		
		public static function scaleBitmapData(bd:BitmapData,scaleX:Number = 1, scaleY:Number = 1):BitmapData {
			var matrix:Matrix = new Matrix();
			matrix.scale(scaleX, scaleY);
			var smallBMD:BitmapData = new BitmapData(bd.width * scaleX, bd.height * scaleX, true, 0x000000);
			smallBMD.draw(bd, matrix, null, null, null, true);
			bd = smallBMD;
			return smallBMD;
		}
		
		public static function getFrame(bd:BitmapData,x:int,y:int,w:int,h:int):BitmapData {
			var smallBMD:BitmapData = new BitmapData(w, h, true, 0x000000);
			var matrix:Matrix = new Matrix
			matrix.translate( -x, -y);
			smallBMD.draw(bd, null, null, null, new Rectangle(x, y, w, h));
			bd = smallBMD;
			return smallBMD;
		}
		
		public static function fitIn(bd:BitmapData, w:int, h:int):BitmapData {
			var scaleVal:Number = 1;
			if (bd.width / w > bd.height / h) {
				scaleVal = w / bd.width;
			}else {
				scaleVal = h / bd.height;
			}
			
			var matrix:Matrix = new Matrix();
			matrix.scale(scaleVal, scaleVal);
			var smallBMD:BitmapData = new BitmapData(bd.width * scaleVal, bd.height * scaleVal, true, 0x000000);
			smallBMD.draw(bd, matrix, null, null, null, true);
			//bd = smallBMD;
			return smallBMD;
		}
		
		public static function copyBD(_bd:BitmapData):BitmapData {
			return _bd.clone();
		}
		
		public static function recolour(bData:BitmapData,color:int,amount:Number):BitmapData {
			var _bData:BitmapData = bData.clone();
			var bm:Bitmap = new Bitmap(_bData);
			UserInterface.colorize(bm, color, amount);
			var resBM:BitmapData = new BitmapData(bData.width, bData.height, true, 0xffffff);
			resBM.draw(bm);
			bm.bitmapData.dispose();
			bm = null;
			return resBM;
		}
		
	}
}