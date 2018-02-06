package wins 
{
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author 
	 */
	public class BuildingWindow extends Window
	{
		
		public function BuildingWindow(settings:Object) 
		{
			super(settings);
			scale = App.map.scaleX;
			target = settings.target;
		}
		
		private var target:*
		private var scale:Number;
		public function focusAndShow():void 
		{
			
			var _targetX:int = target.x + App.map.x - App.self.stage.stageWidth/2;
			var _targetY:int = target.y + App.map.y - App.self.stage.stageHeight/2;
			
			if (Math.abs(_targetX) < 200 && Math.abs(_targetY) < 200){
				App.map.focusedOnCenter(target, false, function():void 
				{
					show();
				}, false);
				return;
			}
			
			App.map.focusedOnCenter(target, false, function():void 
			{
				show();
			}, true,1, true, 0.5, true);
		}
		
		public override function close(e:MouseEvent = null):void {
			unfocus();
			super.close();
		}
		
		public function unfocus():void 
		{
			if(scale != 1)
				App.map.focusedOnCenter(target, false, null, true, scale, true, 0.3,true);
				
			target = null;
			scale = 1;
		}
	}
}