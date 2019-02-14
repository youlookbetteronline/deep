package 
{
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	public class StageInfo extends ViewInfo {
		
		public function StageInfo(file:File, name:String, x:int = 0, y:int = 0, bmd:BitmapData = null) {
			
			super(file, name, x, y);
			
			this.bmd = bmd;
			
			if (bmd) {
			}
			
		}
		
		
		/**
		 * 
		 */
		private var __bmd:BitmapData;
		public function set bmd(value:BitmapData):void {
			__bmd = value;
			if (!__bmd) return;
			sourceWidth = __bmd.width;
			sourceHeight = __bmd.height;	
		}
		public function get bmd():BitmapData {
			return __bmd;
		}
		
		
		
		override public function get bitmapData():BitmapData {
			return bmd || super.bitmapData;
		}
		
		
		
		public function clone():StageInfo {
			var stageInfo:StageInfo = new StageInfo(file, name, x, y, bmd);
			
			// Клонирование объекта
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(extra);
			bytes.position = 0;
			stageInfo.extra = bytes.readObject();
			
			return stageInfo;
		}
		
	}

}