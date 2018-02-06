package core 
{
	import api.com.adobe.utils.IntUtil;
	import flash.utils.ByteArray;
	public class Numbers 
	{
		
		public function Numbers() 
		{
			
		}	
		public static var HOUR:int = 3600;
		public static var WEEK:int = 604800;
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
		
		public static function clone(object:*):* {
			var copier:ByteArray = new ByteArray();
			copier.writeObject(object);
			copier.position = 0;
			return	copier.readObject();
		}
		
		public static function moneyFormat2(count:Number):String {
			
			var cnt:int = 0;
			
			if (count > 999999999) {
				cnt = count / 10000000;
				return (cnt / 100).toString() + ' B';
			}else if (count > 999999) {
				cnt = count / 10000;
				return (cnt / 100).toString() + ' M';
			}
			
			return moneyFormat(count);
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
		
		public static function getProp(object:Object, num:int = 0):Object
		{
			var i:int = 0;
			
			for (var itm:* in object)
			{
				if (i == num) 
				{
					return {key:itm,val:object[itm]}
				}
				i++;
			}
			return { };
		}
		
		public static function lastProp(object:Object = null):* 
		{
			return getProp(object, countProps(object) - 1);
		}
		public static function firstProp(object:Object = null):* 
		{
			for (var o:* in object) {
				return { key:o, val:object[o] };
			}
		}
		
		public static function copyObject(inObj:*):* 
		{
			var copier:ByteArray = new ByteArray();
			copier.writeObject(inObj);
			copier.position = 0;
			var outObj:* = copier.readObject();
			return outObj;
		}
		
		public static function objectToArray(obj:*):Array{
			if(!obj) return null;
			if (obj is Array) return obj;

			var result:Array = [];
			for each (var element:* in obj){
				result.push(element);
			}
			return result;
		}

		public static function objectToArraySidCount(obj:*):Array{
			if(!obj) return null;
			if (obj is Array) return obj;

			var val:Object = {};
			var result:Array = [];
			for (var element:* in obj){
				val = {};
				val[element] = obj[element];

				result.push(val);
			}
			return result;
		}
	}
}