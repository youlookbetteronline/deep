package units 
{
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author 
	 */
	public class Guide extends WorkerUnit
	{
		public function Guide(object:Object)
		{
			/*var randomPlace:Object = getRandomPlace();
			object.x = randomPlace.x;
			object.z = randomPlace.z;*/
			
			super(object);
			removable = false;
			info['area'] = { w:1, h:1 };
			velocities = [0.05];
		}
		
		
		override public function click():Boolean
		{
			/*framesType = 'fly';
			goOnRandomPlace();
			*/
			return true;
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			initMove(
				coords.x + 5, 
				coords.z + 5,
				onGoOnRandomPlace
			);
		}
		
		override public function goOnRandomPlace():void 
		{
			var place:Object = findPlaceNearTarget(this, 5);
			initMove(
				place.x, 
				place.z,
				onGoOnRandomPlace
				//onGoHomeComplete
			);
		}
		
		override public function onGoHomeComplete():void {
			stopRest();	
			var time:uint = Math.random() * 8000 + 8000;
			timer = setTimeout(goHome, time);
		}
	}
}