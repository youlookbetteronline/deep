package units 
{
	import core.IsoTile;
	import ui.UnitIcon;
	import wins.SimpleWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Portal extends Building 
	{
		private var _portalTarget:*
		public function Portal(object:Object) 
		{
			super(object);			
		}
		
		override public function click():Boolean 
		{
			if (!clickable || id == 0 || (App.user.mode == User.GUEST && touchableInGuest == false)) 
				return false;
			App.tips.hide();
			
			if (level < totalLevels) 
			{
				if (App.user.mode == User.OWNER)
				{
					openConstructWindow();
					return true;
				}
			}
			else if (buildFinished && targetBuildFinished)
			{
				moveToTarget();
				return true;
			}
			else if (buildFinished && !targetBuildFinished)
			{
				new SimpleWindow({
					title		:Locale.__e("flash:1474469531767"),
					label		:SimpleWindow.ATTENTION,
					text		:Locale.__e('flash:1504516002001') + ' ' + App.data.storage[info.moveto].title,
					confirm		:onConfirm
					}).show();
				return true;
			}
			return false
		}
		
		private function onConfirm():void
		{
			App.map.focusedOn(portalTarget, true);
		}
		
		public function get portalTarget():*
		{
			_portalTarget = Map.findUnits([info.moveto])[0]
			return _portalTarget;
		}
		
		private function moveToTarget():void 
		{
			App.user.hero.initMove(coords.x, coords.z, placeHero)
		}
		
		private function placeHero():void 
		{
			var coords:Object = portalTarget.findPlaceNearTarget(portalTarget, 2);
			App.user.hero.placing(portalTarget.coords.x, 0, portalTarget.coords.z);
			App.user.hero.updateCellRow();
			App.map.focusedOn(App.user.hero);
			//var jane:Unit = Unit.add( {gift:false, sid:978, buy:true, x:73, z:90 } );
			App.user.hero.initMove(coords.x, coords.z, function():void{
				App.user.hero.onStop();
				App.user.hero.updateCellRow();
			});
		}
		
		private function get targetBuildFinished():Boolean
		{
			var buildfinished:Boolean = false;
			if (portalTarget.hasOwnProperty('totalLevels') && portalTarget.totalLevels == portalTarget.level)
				buildfinished = true;
			return buildfinished;
		}
		
		override public function showIcon():void 
		{
			super.showIcon();
			if (buildFinished)
			{
				drawIcon(UnitIcon.PORTAL, 1, 1, {
						glow:		true,
						iconScale: .1
					}, 0, coordsCloud.x, coordsCloud.y);
			}
		}
		
		override public function calcDepth():void 
		{
			var left:Object = {x: x - IsoTile.width * rows * .5, y: y + IsoTile.height * rows * .5};
			var right:Object = {x: x + IsoTile.width * cells * .5, y: y + IsoTile.height * cells * .5};
			depth = (left.x + right.x) + (left.y + right.y) * 90;
		}
	}
}