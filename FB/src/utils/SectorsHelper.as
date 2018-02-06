package utils 
{
	import core.Post;
	/**
	 * ...
	 * @author ...
	 */
	public class SectorsHelper 
	{
		
		public function SectorsHelper() 
		{
			
		}
		
		public static function sendOpened(_sIds:Array):void
		{
			if (!App.owner)
				return;
			var sendObject:Object = {
				ctr:'World',
				act:'opensectors',
				uID:App.owner.id,
				wID:App.owner.worldID,
				sectors:JSON.stringify(_sIds)
			}
			Post.send(sendObject, onSendOpened);
		}
		
		private static function onSendOpened(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
		}
		
	}

}