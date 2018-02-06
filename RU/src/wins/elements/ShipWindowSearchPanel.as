package wins.elements 
{
	/**
	 * ...
	 * @author ...
	 */
	public class ShipWindowSearchPanel extends SearchPanel 
	{
		
		public function ShipWindowSearchPanel(settings:Object) 
		{
			super(settings);
			
		}
		
		override public function search(query:String = "", isCallBack:Boolean = true):Array {
			
			if (query == "") {
				if (settings.stop != null)
					settings.stop();
				return null;	
			}
			
			query = query.toLowerCase();
			
			var result:Array = [];
			var items:Array = settings.win.params.content;
			var L:uint = items.length;
			
			for (var i:int = 0; i < L; i++)
			{
				var item:Object = App.data.storage[items[i].sid];
				//if (item.market == 0)
					//continue;
				if (!World.canBuyOnThisMap(item.sid) && item.type != 'Material')
					continue;
				if(item.title.toLowerCase().search(query)!= -1)
				//if (item.title.toLowerCase().indexOf(query) == 0)
					result.push(items[i]);
			}
			
			result.sortOn('order', Array.NUMERIC);
			
			settings.callback(result);
			
			return null;
		}
		
	}

}