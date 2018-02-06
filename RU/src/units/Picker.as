package units 
{
	import ui.UnitIcon;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Picker extends Techno 
	{
		private var types:Array = new Array();
		private var unitsClick:Array;
		public function Picker(object:Object) 
		{
			super(object);
			this.types = this.info.types;
			removable = true;
			/*App.self.addEventListener(AppEvent.ON_REWARD_READY, redrawIcon);
			App.self.addEventListener(AppEvent.ON_REWARD_TAKE, redrawIcon);*/	
			showIcon();
		}
		
		private function get initCount():Array 
		{
			var unitsOnMap:Array = [];
			unitsClick = new Array();
			for each (var onmap:* in App.data.storage)
			{
				if (onmap.sID == Walkgolden.JOHNY)
					continue;
				if (types.indexOf(onmap.type) != -1 && Map.findUnits([onmap.sID]).length > 0)
					unitsOnMap.push(onmap.sID)
			}
			
			for each (var untrew:* in unitsOnMap)
			{
				var _units:Array = Map.findUnits([untrew]);
				for each (var _unt:* in _units)
					if ((_unt.hasOwnProperty('hasProduct') && _unt.hasProduct) || (_unt.hasOwnProperty('tribute') && _unt.tribute))
						unitsClick.push(_unt)
			}
			return unitsClick;
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST) 
				return false;
			clearIcon();
			if (initCount.length > 0)
			{
				for (var i:int = 0; i < initCount.length; i++)
				{
					initCount[i].click();
					initCount.splice(i, 1);
				}
				return true;
			}
			else
			{
				new SimpleWindow( {
					title:Locale.__e("flash:1474469531767"),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1501601080822'),
					confirm:function():void {
							new ShopWindow({find:[1222, 1526]}).show();
						}
				}).show();
			}
			return true;	
		}
		
		private function redrawIcon(e:*):void 
		{
			for each(var tp:* in types)
			{
				if (e.params.target.type == tp)
					showIcon();
					break;
			}
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			showIcon();
		}
		
		override public function showIcon():void 
		{
			if (App.user.mode == User.GUEST) 
				return;
			if (App.data.storage[sid].hasOwnProperty('cloudoffset') &&  (App.data.storage[sid]['cloudoffset'].dx != 0 || App.data.storage[sid]['cloudoffset'].dy != 0))
			{
				coordsCloud.x = App.data.storage[sid]['cloudoffset'].dx;
				coordsCloud.y = App.data.storage[sid]['cloudoffset'].dy;
			}else{
				coordsCloud.x = 0;
				coordsCloud.y = -50;
			}
				
			//if (initCount.length > 0) 
			//{
				drawIcon(UnitIcon.REWARD, 2192, 1, {
					glow:		true
				}, 0, coordsCloud.x, coordsCloud.y);
			//}
		}
	}

}