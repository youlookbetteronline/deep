package wins.elements 
{
	/**
	 * ...
	 * @author ...
	 */
	public class SearchCollectionPanel extends SearchPanel 
	{
		
		public function SearchCollectionPanel(settings:Object) 
		{
			super(settings);
			
		}
		
		override public function search(query:String = "", isCallBack:Boolean = true):Array 
		{	
			if (query == "") {
				if (settings.stop != null)
					settings.stop();
				return null;	
			}
			
			query = query.toLowerCase();
			
			var result:Array = [];
			var items:Array = settings.win.allContent;
			var L:uint = items.length;
			
			for (var i:int = 0; i < L; i++)
			{
				var item:Object = items[i];
				if(item.title.toLowerCase().search(query)!= -1)
					result.push(item);
			}
			
			result.sortOn('order', Array.NUMERIC);
			
			settings.callback(result);
			trace('SEARCH FUNCTION ' + String(Math.random()*100));
			return null;
		}
		
	}

}