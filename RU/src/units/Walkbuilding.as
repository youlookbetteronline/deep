package units 
{
	/**
	 * ...
	 * @author ...
	 */
	public class Walkbuilding extends WorkerUnit 
	{
		public var coordsCloud:Object = new Object();
		
		private var _totalLevel:int = 0;
		
		public function Walkbuilding(object:Object) 
		{
			super(object, view);
			
			if (object.level)
				level = object.level;
		}
		
		override public function click():Boolean 
		{
			return super.click();
		}
		
		public function showIcon():void
		{
			if (cloudPositions.hasOwnProperty(App.data.storage[sid].view) ) 
			{
				coordsCloud.x = cloudPositions[App.data.storage[sid].view].x;
				coordsCloud.y = cloudPositions[App.data.storage[sid].view].y;
			}else{
				if (App.data.storage[sid].hasOwnProperty('cloudoffset') && 
				(App.data.storage[sid]['cloudoffset'].dx != 0 || App.data.storage[sid]['cloudoffset'].dy != 0))
				{
					coordsCloud.x = App.data.storage[sid]['cloudoffset'].dx;
					coordsCloud.y = App.data.storage[sid]['cloudoffset'].dy;
				}else{
					coordsCloud.x = 0;
					coordsCloud.y = -50;
				}
			}
				
			if (App.user.mode == User.OWNER)
			{
				if (level < totalLevels) 
				{
					drawIcon(UnitIcon.BUILD, null, 0, {
						level: level,
						totalLevels: totalLevels
					}, 0, coordsCloud.x, coordsCloud.y);
				}
			}
		}
		
		public function get totalLevel():int
		{
			return _totalLevel;
		}
		
		public function set totalLevel(value:int):void
		{
			_totalLevel = value;
		}
		
	}

}