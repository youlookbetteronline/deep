package astar
{
	import core.IsoTile;
	import flash.geom.Point;
	import units.Unit;
	import utils.Sector;
	
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
			object : LayerX,
			sector : Sector,
			tile : IsoTile,
			open:Boolean = false,
			fDepth : int,
			z : int,
			b : int,
			p : int,
			w : int;
		
		public function AStarNodeVO(cost:uint = 1)
		{
			this.cost = cost;
		}
	}
}