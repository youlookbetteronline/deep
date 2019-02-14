package enixan.worker 
{
	import flash.events.Event;
	
	public class WorkerEvent extends Event 
	{
		
		public static const LOCALE:String = 'locale';
		public static const STORAGE_DATA:String = 'storageData';
		public static const LANGUAGE:String = 'language';
		public static const JSON_TO_OBJECT:String = 'jsonToObject';
		public static const BITMAPDATA_TO_PNG:String = 'bitmapDataToPNG';
		
		public function WorkerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
	}

}