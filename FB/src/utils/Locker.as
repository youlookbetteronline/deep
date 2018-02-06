package utils 
{
	import flash.display.Sprite;
	import wins.SimpleWindow;
	import wins.Window;
	import wins.WorldsWindow;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Locker 
	{
		
		public function Locker() 
		{
			
		}
		
		public static function availableUpdate(closewins:Boolean = true):void
		{
			if (App.self.windowContainer.numChildren > 0 && closewins)
				Window.closeAll();
			new SimpleWindow( {
				title:Locale.__e("flash:1474469531767"),
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1481899130563'),
				popup:true
			}).show();
			return;
		}
		public static function notFindQuest(qID:int, closewins:Boolean = true):void
		{
			if (App.self.windowContainer.numChildren > 0 && closewins)
				Window.closeAll();
			var _wID:int = App.user.worldID;
			if (App.data.quests[qID].dream && App.data.quests[qID].dream[0])
				_wID = App.data.quests[qID].dream;
			new SimpleWindow( {
				title:Locale.__e("flash:1474469531767"),
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1510067633699'),
				popup:true,
				confirm:function():void{
					new WorldsWindow( {
						title: Locale.__e('flash:1415791943192'),
						sID:	null,
						only:	[_wID],
						popup:	true
					}).show();
				}
			}).show();
			return;
		}
		
		public static function availableWith(sid:int, closewins:Boolean = true):void
		{
			if (App.self.windowContainer.numChildren > 0 && closewins)
				Window.closeAll();
			new SimpleWindow( {
				title:Locale.__e("flash:1474469531767"),
				label:SimpleWindow.ATTENTION,
				text:Locale.__e("flash:1508417999810", App.data.storage[sid].title),
				popup:true
			}).show();
			return;
		}
		
		public static function blockClick(closewins:Boolean = true):void
		{
			if (App.self.windowContainer.numChildren > 0 && closewins)
				Window.closeAll();
			new SimpleWindow( {
				title:Locale.__e("flash:1474469531767"),
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1505465080358'),
				popup:true
			}).show();
			return;
		}
		
		public static function notEnoughSlot(closewins:Boolean = true):void
		{
			if (App.self.windowContainer.numChildren > 0 && closewins)
				Window.closeAll();
			new SimpleWindow( {
				title:Locale.__e("flash:1474469531767"),
				label:SimpleWindow.ATTENTION,
				text:Locale.__e("flash:1506334450394"),
				popup:true
			}).show();
			return;
		}
		
		public static function availableQuest(closewins:Boolean = true):void
		{
			if (App.self.windowContainer.numChildren > 0 && closewins)
				Window.closeAll();
			new SimpleWindow( {
				title:Locale.__e("flash:1474469531767"),
				label:SimpleWindow.ATTENTION,
				text:Locale.__e("flash:1482142336166"),
				popup:true
			}).show();
			return;
		}
		
	}

}