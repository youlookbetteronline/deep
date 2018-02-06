package buttons 
{
	/**
	 * ...
	 * @author Valentine
	 */
	public class PuzzleButton extends MoneyButton 
	{
		public static var INN:uint = 0;
		public static var OUT:uint = 1;
		public static var NONE:uint = 2;
		
		public var left:uint = 2; 
		public var right:uint = 2; 
		public var upper:uint = 2; 
		public var bottom:uint = 2; 
		
		public function PuzzleButton(settings:Object=null) 
		{
			super(settings);
			
		}
		
	}

}