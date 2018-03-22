package units 
{
	import core.Numbers;
	import wins.MannequinWindow;
	/**
	 * ...
	 * @author 
	 */
	public class Booster extends Building 
	{
		public static var boosters:Vector.<Booster> = new Vector.<Booster>();
		public var boostPercent:Number = 0;
		public function Booster(object:Object) 
		{
			super(object);
			
			boostPercent = Numbers.firstProp(info.target).val;
			
		}
		
		override public function click():Boolean
		{
			hidePointing();
			stopBlink();
			
			/*if (!super.click() || this.id == 0)
			{
				return false;
			}*/		
			
			/*if (App.user.mode == User.GUEST) 
			{
				guestClick();
				return true;
			}*/
			
			if (openConstructWindow()) 
				return true;
				
			if (openInfoWindow())
				return true;
				
			return true;
		}
		
		
		public function openInfoWindow():Boolean 
		{
			if (App.user.mode == User.OWNER && level == totalLevels)
			{
				var hintWindow:MannequinWindow = new MannequinWindow({
					target		:this,
					popup		:true
				});
				hintWindow.show();
				return true
			}
			
			return false;
		}
		
		override public function finishUpgrade():void 
		{
			if (App.user.mode == User.OWNER) 
			{
				isPresent();
				showIcon();
			}
			
			if (level == totalLevels) 
			{
				checkBuildings();
			}
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			if (level == totalLevels)
			{
				checkBuildings();
			}
		}
		override public function showIcon():void 
		{
			if (App.user.mode == User.GUEST) 
				return;
			super.showIcon();
		}
		public function checkBuildings():void
		{
			if (level != totalLevels)
				return;
			if(boosters.indexOf(this) == -1)
				boosters.push(this);
			var bSids:Array = new Array();
			for (var _bSID:* in info.target)
			{
				bSids.push(_bSID);
			}
			var buildings:Array = Map.findUnits(bSids);
			for each(var _building:* in buildings)
			{
				if (_building is Building)
					_building.booster = this;
				if (_building is Craftfloors)
					_building['model'].booster = this;
			}
		}
		
	}
	

}