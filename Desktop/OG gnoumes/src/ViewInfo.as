package 
{
	import flash.display.BitmapData;
	import flash.filesystem.File;
	
	public class ViewInfo extends Object {
		
		public var extra:Object;
		public var file:File;
		public var name:String;
		public var x:int;
		public var y:int;
		public var sourceWidth:int;		// Исходный размер
		public var sourceHeight:int;	// Исходный размер
		
		public function ViewInfo(file:File, name:String, x:int = 0, y:int = 0) {
			
			this.file = file;
			this.name = name;
			this.x = x;
			this.y = y;
			extra = { };
		}
		
		public function get bitmapData():BitmapData {
			return null;
		}
		
	}

}