package enixan 
{
	
	public class Size 
	{
		
		public static function size(target:*, width:Number, height:Number, widthFirst:Boolean = true):void {
			if (!target) return;
			
			if (widthFirst) {
				toWidth();
				toHeight();
			}else {
				toHeight();
				toWidth();
			}
			
			function toWidth():void {
				if (target.width > width) {
					target.width = width;
					target.scaleY = target.scaleX;
				}
			}
			function toHeight():void {
				if (target.height > height) {
					target.height = height;
					target.scaleX = target.scaleY;
				}
			}
		}
		
		
		public static function zero(value:*, size:int = 2, symbol:String = '0'):String {
			var rtrn:String = String(value);
			while (rtrn.length < size) {
				rtrn = symbol + rtrn;
			}
			return rtrn;
		}
		
	}

}