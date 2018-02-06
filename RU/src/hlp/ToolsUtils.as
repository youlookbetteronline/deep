package hlp {
	import core.Base64;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Andrey S
	 */
	public class ToolsUtils 
	{
		public function ToolsUtils() 
		{
			
		}
		
		public static function objectToArray(obj:*):Array{
			if (obj is Array) return obj;
			
			var result:Array = [];
			for each (var element:* in obj){
				result.push(element);
			}
			return result;
		}
		
		public static function objectLength(myObject:Object):int {
			var cnt:int = 0;
			for (var s:String in myObject) cnt++;
			return cnt;
		}
		
		public static function changeTwo(val1:*, val2:*):void {
			if (typeof(val1) != typeof(val2)) return;
			var temp:* = val1;
			val1 = val2;
			val2 = temp;
		}
		//
		//public static function createMask(w:int, h:int):Shape {
		   //var mask:Shape = new Shape();
		   //mask.graphics.beginFill(0x0, 0.5);
		   //mask.graphics.drawRect(0, 0, w, h);
		   //mask.graphics.endFill();
		   //
		   //return mask;
		//}
		
		public static function round(num:Number, decimals:int):Number{
			var m:int = Math.pow(10, decimals);
			return Math.round(num * m) / m;
		}
		
		public static function flipBitmapData(original:BitmapData, axis:String = "x"):BitmapData{
			 var flipped:BitmapData = new BitmapData(original.width, original.height, true, 0);
			 var matrix:Matrix
			 if(axis == "x"){
				  matrix = new Matrix( -1, 0, 0, 1, original.width, 0);
			 } else {
				  matrix = new Matrix( 1, 0, 0, -1, 0, original.height);
			 }
			 flipped.draw(original, matrix, null, null, null, true);
			 return flipped;
		}
		
		public static function objectToString(object:Object):String {
			var result:String = '';
			for (var prop:String in object) {
				result += prop + ': ' + object[prop] + '\n';
			}
			return Locale.__e(result);
		}
		
		public static function indexOfObject(object:Object, element:*):int {
			for (var index:String in object) {
				if (object[index] == element) return int(index);
			}
			
			return -1;
		}
		
		public static function randRange(minNum:Number, maxNum:Number):Number {
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
		
		public static function toRadians(degrees:Number):Number {
			return degrees * Math.PI / 180;
		}
		
		public static function clone( source:Object ):* { 
			var myBA:ByteArray = new ByteArray(); 
			myBA.writeObject( source ); 
			myBA.position = 0; 
			return( myBA.readObject() ); 
		}
		
		public static function removeFromParent(target:Object, dispose:Boolean = false):void {
			if (target && target is Array) {
				for each (var item:Object in target) {
					if (item && item is DisplayObject && item.parent) {
						item.parent.removeChild(item);
						if (/*dispose && */item.hasOwnProperty('dispose')) {
							item.dispose();
						}
					}
				}
			}else if (target && target is DisplayObject && target.parent) {
				target.parent.removeChild(target);
				if (/*dispose && */target.hasOwnProperty('dispose')) {
					target.dispose();
				}
			}
		}
		
		public static function createMask(w:int, h:int, a:Number = .5, ellipse:Number = 0):Sprite {
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0x0, a);
			mask.graphics.drawRoundRect(0, 0, w, h, ellipse, ellipse);
			mask.graphics.endFill();
			
			return mask;
		}
		
		public static function fillContainer(container:Sprite, color:uint = 0xff0000):void {
			container.graphics.beginFill(color, 0.5);
			container.graphics.drawRect(0, 0, container.width, container.height);
			container.graphics.endFill();
		}
		
		public static function realHitTest(object:DisplayObject, point:Point):Boolean {
			/* If we're already dealing with a BitmapData object then we just use the hitTest
			 * method of that BitmapData.
			 */
			if(object is BitmapData) {
				return (object as BitmapData).hitTest(new Point(0,0), 0, object.globalToLocal(point));
			}
			else {
				
				/* First we check if the hitTestPoint method returns false. If it does, that
				 * means that we definitely do not have a hit, so we return false. But if this
				 * returns true, we still don't know 100% that we have a hit because it might
				 * be a transparent part of the image. 
				 */
				if(!object.hitTestPoint(point.x, point.y, true)) {
					return false;
				}
				else {
					/* So now we make a new BitmapData object and draw the pixels of our object
					 * in there. Then we use the hitTest method of that BitmapData object to
					 * really find out of we have a hit or not.
					 */
					var bmapData:BitmapData = new BitmapData(object.width, object.height, true, 0x00000000);
					bmapData.draw(object, new Matrix());
					
					var returnVal:Boolean = bmapData.hitTest(new Point(0,0), 0, object.globalToLocal(point));
					
					bmapData.dispose();
					
					return returnVal;
				}
			}
		}
		
		public static function isPixelTransparent(objectOnStage:DisplayObject, globalPoint:Point):Boolean {
			var local:Point = objectOnStage.globalToLocal(globalPoint);
			var matrix:Matrix = new Matrix();
			matrix.translate(-local.x, -local.y); 
			var data:BitmapData = new BitmapData(1, 1, true, 0x00000000);
			data.draw(objectOnStage, matrix);
			var a:uint = data.getPixel32(0, 0);
			return 0x00000000 == a;
		}
		
		public static function encrypt(text:String, key:String, encode:Boolean = true):String{
			var _text:ByteArray;
			
			if (encode == false) {
				_text = Base64.decode(text);
				_text.position = 0;
				text = '';
				for (var k:int = 0; k < _text.length; k++ ) {
					var byte:int = _text.readByte();
					text += String.fromCharCode(byte);
				}
			}
			var klen:int = key.length;
			var tlen:int = text.length;
			var outText:String = '';        
			for (var i:int = 0; i < tlen; i++) {
				outText += String.fromCharCode(text.charCodeAt(i) ^ (key.charCodeAt(i - Math.floor(i / klen) * klen)));
			}
			var out:ByteArray = new ByteArray();
			out.writeUTFBytes(outText);
			return encode ? Base64.encode(out) : outText;
		}
	
	}

}