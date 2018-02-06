package units 
{
	import com.greensock.TweenLite;
	import core.Post;
	import flash.geom.Point;
	import flash.utils.setTimeout;

	public class TableFish extends Walkgolden 
	{ 
		private var goToX:int;
		private var goToZ:int;
		private var uniqueID:int;
		private var tableTimeout:uint = 0;
		public var gives:Boolean = false;
		//public static const WMOLE:uint = 2799;
		
		public function TableFish(object:Object) 
		{			
			goToX = object.baseX;
			goToZ = object.baseZ;
			uniqueID = object.uniqueID;
			
			super(object);		
			
			tip = function():Object 
			{	
				return {
					title:info.title
				};
			}
			
		}
		
		override public function click():Boolean 
		{	
			//ничего не делаем
			return false;
		}
		
		override public function showIcon():void
		{			
			//ничего не делаем
		}
		
		override public function set move(move:Boolean):void 
		{
			//ничего не делаем
		}
		
		
		override public function goHome(_movePoint:Object = null):void
		{
			//framesType = Personage.WALK;
			
			initMove(
				goToX,
				goToZ,
				onGoHomeComplete
			);
		}
		
		override public function onGoHomeComplete():void
		{
			tableTimeout = setTimeout(goToExit, 2000 + Math.random() * 2000);
			gives = true;
		}
		
		public function goToExit():void
		{
			var place:Object = findNewPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:coords.x, z:coords.z}}, 20);
			initMove(
				place.x,
				place.z,
				onExitComplete
			);
		}
		
		public function onExitComplete():void
		{
			TweenLite.to(this, 2, { x:this.x, y:this.y, alpha: 0, onComplete: uninstall});
		}
		
		
		public function findNewPlaceNearTarget(target:*, radius:int = 3, lookOnWater:Boolean = false):Object
		{
			var places:Array = [];
			
			var targetX:int = target.coords.x;
			var targetZ:int = target.coords.z;
			
			var startX:int = targetX - radius;
			var startZ:int = targetZ - radius;
			
			if (startX <= 0) startX = 1;
			if (startZ <= 0) startZ = 1;
			
			var finishX:int = targetX + radius + target.info.area.w;
			var finishZ:int = targetZ + radius + target.info.area.h;
			
			if (finishX >= Map.cells) finishX = Map.cells - 1;
			if (finishZ >= Map.rows) finishZ = Map.rows - 1;
			
			for (var pX:int = startX; pX < finishX; pX++)
			{
				for (var pZ:int = startZ; pZ < finishZ; pZ++)
				{
					if ((coords.x <= pX && pX <= targetX +target.info.area.w) &&
					(coords.z <= pZ && pZ <= targetZ +target.info.area.h)){
						continue;
					}
					
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].isWall) 
						continue;
						
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].open == false) 
						continue;	
					
					places.push( { x:pX, z:pZ} );
				}
			}
			
			if (places.length == 0)
			{
				places.push( { x:coords.x, z:coords.z } );
			}
			
			var random:uint = int(Math.random() * (places.length - 1));
			return places[random];
		}
		
		
		
	}
}