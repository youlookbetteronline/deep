package models 
{
	/**
	 * ...
	 * @author das
	 */
	public class BankerModel 
	{
		private var _storageTime:uint;
		public static var loyalty:Object;
		private var _tribute:Boolean = false;
		private var _storageCallback:Function;

		public function BankerModel() 
		{
			
		}
		
		public function get storageTime():uint 
		{
			return _storageTime;
		}
		
		public function set storageTime(value:uint):void 
		{
			_storageTime = value;
		}
		
		public function get tribute():Boolean 
		{
			return _tribute;
		}
		
		public function set tribute(value:Boolean):void 
		{
			_tribute = value;
		}
		
		/*public static function get loyalty():Object 
		{
			return _loyalty;
		}
		
		public static function set loyalty(value:Object):void 
		{
			_loyalty = value;
		}*/
		
		public function get storageCallback():Function 
		{
			return _storageCallback;
		}
		
		public function set storageCallback(value:Function):void 
		{
			_storageCallback = value;
		}
		
	}

}