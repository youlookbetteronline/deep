package core{
	
	import com.greensock.*; 
	import com.greensock.easing.*;
	
	public class BezieDrop
	{
		
		public function BezieDrop()
		{
			
		}
		
		public static function drop(Xs:int, Ys:int, Xf:int, Yf:int, obj:*):void
		{
			var Xb:int =  Xs + (Xf - Xs) / 2
			var Yb:int =  Ys - (Yf - Ys) / 2
			
			obj.x = Xs
			obj.y = Ys
			TweenMax.to(obj, 0.5, {bezierThrough:[{x:Xs, y:Ys}, {x:Xb, y:Yb}, {x:Xf, y:Yf}], ease:Strong.easeOut});
		}
	}
}