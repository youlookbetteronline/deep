package wins 
{
	import core.Load;
	import core.Log;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author 
	 */
	public class WindowJSON extends Window 
	{
		
		private var loadedData:Boolean 		= false;
		public var positionsJSON:Object 	= false;
		public function WindowJSON(settings:Object=null) 
		{
			super(settings);
		}
		
		public function showAfter():void 
		{
			super.show();
		}
		
		override public function show():void 
		{
			if (!loadedData)
			{
				loadJSONData();
				return;
			}
		}
		
		private function loadJSONData():void 
		{
			var ss:String = getQualifiedClassName(this);
			var seach:int = ss.search('::');
			ss = ss.slice(seach+2, ss.length);
				
			Log.alert('loadWindowJson');
			Load.loadText(Config.getWindowData(ss), function(text:String):void 
			{
				positionsJSON = JSON.parse(text);
				positionsJSON = positionsJSON[0];
				loadedData = true;
				showAfter();
			}, false);
		}
	}

}