package  
{
	import flash.net.SharedObject;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	public class Storage 
	{
		
		public static function store(name:String, value:*, expire:int = 1):void {
			var so:SharedObject = SharedObject.getLocal('dreams');
			var storage:Object = { };
			if (so.data.hasOwnProperty('storage')) storage = so.data.storage;
			storage[name] = value;
			
			so.data.storage = storage;
			so.flush();
		}
		
		public static function read(name:String, returnDefault:* = ""):* {
			var so:SharedObject = SharedObject.getLocal('dreams');
			if (so.data.hasOwnProperty('storage') && so.data.storage.hasOwnProperty(name)) {
				return so.data.storage[name];
			}else {
				return returnDefault;
			}
		}
		
		public static function sharedRead(key:String, _default:* = null):* {
			var shared:SharedObject = SharedObject.getLocal('df6bvz1');
			var object:* = shared.data[key];
			
			if (object is ByteArray) {
				var bytes:ByteArray = object as ByteArray;
				bytes.uncompress();
				return bytes.readObject();
			}else {
				return _default;
			}
		}
		
	}

}