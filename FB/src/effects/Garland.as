package effects 
{
	import com.greensock.TweenLite;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	/**
	 * ...
	 * @author ...
	 */
	public class Garland extends LayerX 
	{
		private var _circle:Shape = new Shape();
		public function Garland(container:Sprite, X:int, Y:int, color:uint) 
		{
			super();
			_circle.graphics.beginFill(color, .8);
			_circle.graphics.drawCircle(0, 0, 9);
			_circle.graphics.endFill();
			_circle.filters = [new BlurFilter(10, 10)];
			this.blendMode = BlendMode.LIGHTEN;
			_circle.alpha = 0;
			_circle.x = X;
			_circle.y = Y;
			container.addChild(_circle);
			
			var tween:TweenLite =  TweenLite.to(_circle, 1.2, { alpha:1, scaleX:1.3, scaleY:1.5, onComplete:function():void{
				TweenLite.to(_circle, 1.2, { alpha:0, scaleX:1, scaleY:1, onComplete:function():void{
					if (_circle && _circle.parent)
						_circle.parent.removeChild(_circle);
				} })
			}});
			
		}
		
	}

}