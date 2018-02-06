package units 
{
	import com.greensock.TweenLite;
	import core.IsoTile;
	/**
	 * ...
	 * @author 
	 */
	public class WaterFloat extends Decor 
	{
		public static var FLOAT:int = 1157;
		public static var floatTimeout:int = 12;
		public var onBase:Boolean = true;
		public function WaterFloat(object:Object) 
		{
			super(object);
			
		}
		override public function calcDepth():void
		{
			var left:Object = {x: x - IsoTile.width * rows * .5, y: y + IsoTile.height * rows * .5};
			var right:Object = {x: x + IsoTile.width * cells * .5, y: y + IsoTile.height * cells * .5};
			depth = (left.x + right.x) + (left.y + right.y) * 150;
		}
		
		public function emerge():void
		{
			onBase = false;
			this.bitmap.smoothing = true;
			TweenLite.to(this, floatTimeout, { x:this.x, y:this.y - 500, scaleX: 2, scaleY: 2, alpha: 0, onComplete: uninstall});
		}
		public function emergeDown():void
		{
			this.y -= 500;
			this.scaleX = this.scaleY = 2;
			this.alpha = 0;
			this.bitmap.smoothing = true;
			TweenLite.to(this, floatTimeout, { x:this.x, y:this.y + 500, scaleX: 1, scaleY: 1, alpha: 1});
		}
		
	}

}