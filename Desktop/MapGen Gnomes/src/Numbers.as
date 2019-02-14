package  
{
	import flash.geom.Point;
	public class Numbers 
	{
		
		public function Numbers() 
		{
			
		}	
	
		public static function moneyFormat(count:int):String {
			var r:RegExp = /\d\d\d$/g;
			var s:String = count.toString();
			var a:Array = new Array();
			var res:String ='';

			while (s.length > 3){
				a.push(' '+s.match(r));
				s = s.replace(r,'');
			}

			for (var i:int = a.length; i > 0; i--) {
				res = res+a[i-1];
			}

			res = s + res;
			return res;
		}
		
		public static function pushInVector(array:Vector.<*>, index:int, element:Object):Vector.<Object> {
			//var temp:Vector.<*> = new Vector.<*>();
			//temp.concat(temp, array);
			//var temp2:Vector.<*> = new Vector.<*>();
			//temp2.concat(temp2, array);
			
			//var someArrayR:Vector.<Object> = array.slice(-index);
			//var someArrayL:Vector.<Object> = array.slice(index);
			//someArrayL.unshift(element);
			var result:Vector.<Object> = new Vector.<Object>();
			var j:int = 0;
			for (var i:int = 0; i < array.length+1; i++){
				if(i == index){
					result[i] = element;
					i++;
					j++;
				}
				result[i] = array[i - j];
			}
			//result = someArrayR.concat(someArrayL);

			//trace(someArrayR);     // a,b,c,d,e,f
			//trace(someArrayR); // e,f
			return result;
		}
		
		public static function pushIn(array:Array, index:int, element:*):Array {
			var temp:Array = new Array();
			temp.concat(array);
			var temp2:Array = new Array();
			temp2.concat(array);
			
			var someArrayL:Array = temp.slice(-index);
			var someArrayR:Array = temp2.slice(index);
			someArrayL.push(element);
			var result:Array = result.concat(someArrayL, someArrayR);

			trace(someArrayR);     // a,b,c,d,e,f
			trace(someArrayR); // e,f
			return result;
		}
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
				if (target.width > width) {
					target.width = width;
					target.scaleY = target.scaleX;
				}
			}
			function toHeight():void {
				if (target.height > height) {
					target.height = height;
					target.scaleX = target.scaleY;
				}
			}
		}
		
		public static function countProps(object:Object = null):int {
			var nums:int = 0;
			
			if (object)
				for (var s:String in object) nums++;
			
			return nums;
		}
		
		public static function inObject(object:Object = null, value:* = null):Boolean {
			if (object && value) {
				for (var s:String in object) {
					if (s == String(value) || object[s] == value)
						return true;
				}
			}
			
			return false;
		}
		
		public static function getProp(object:Object, num:int = 0):Object {
			var i:int = 0;
			for (var itm:* in object) {
				if (i == num) {
					return {key:itm,val:object[itm]}
				}
				i++;
			}
			return { };
		}
		
		public static function firstProp(object:Object):Object {
			for (var itm:* in object) {
				return { key:itm, val:object[itm] }
				break;
			}
			return null;
		}
	}

}