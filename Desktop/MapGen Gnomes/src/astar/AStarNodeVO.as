package astar
{
	import core.IsoTile;
	import flash.geom.Point;
	import units.Unit;
	
	public class AStarNodeVO
	{
		
		public var
			h : uint,
			f : uint,
			g : uint,
			cost : uint,
			visited : Boolean,
			closed : Boolean,
			isWall : Boolean,
			position : Point,
			parent : AStarNodeVO,
			next : AStarNodeVO,
			neighbors : Vector.<AStarNodeVO>,
			zone : uint,
			marker : String,
			object : Unit,
			tile : IsoTile;
		
		public function AStarNodeVO(cost:uint = 1)
		{
			this.cost = cost;
		}
	}
}