package utils 
{
	import core.Numbers;
	import core.Post;
	import wins.BonusLackWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class BonusHelper 
	{
		
		public function BonusHelper() 
		{
			
		}
		
		public static function checkLack():void
		{
			if (!App.user.data.user.lacksDays)
				return;
			var lackDay:int = 0;
			var lacks:Array = [];
			for (var _day:* in App.data.lacks)
			{
				lacks.push(_day)
			}
			lacks.sort(Array.NUMERIC).reverse();
			for each(var d:* in lacks)
			{
				if (App.user.data.user.lacksDays > d)
				{
					lackDay = d;
					break;
				}
			}
			if (App.data.lacks.hasOwnProperty(lackDay))
				new BonusLackWindow({popup:true, bonus: App.data.lacks[lackDay].items}).show();

		}
		public static function getLack(lackCallback:Function):void
		{
			Post.send({
				ctr:	'bonus',
				act:	'lacks',
				uID:	App.user.id,
				wID:	App.user.worldID
			}, onGetLack, {
				lackCallback: lackCallback
			})
		}
		
		private static function onGetLack(error:int, data:Object, params:Object):void 
		{
			if (error)
				return;
			if (data.bonus)
				params.lackCallback(data.bonus);
		}
	}

}