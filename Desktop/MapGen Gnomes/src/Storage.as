package  
{
	import flash.net.SharedObject;
	
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
		
	}

}