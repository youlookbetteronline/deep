package models 
{
	import wins.FriendfloorsWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class FriendfloorsModel 
	{
		private var _floor:int;
		private var _totalFloor:int;
		private var _crafted:int;
		private var _lifetime:int;
		private var _friends:Object;
		private var _kicks:int;
		private var _toThrow:Object;
		private var _freeze:Boolean = false;
		private var _mkickCallback:Function;
		private var _fkickCallback:Function;
		private var _fakefkickCallback:Function;
		private var _growCallback :Function;
		private var _window:FriendfloorsWindow;
		
		public static const DECOR:int = 0;
		public static const GOLDEN:int = 1;
		public static const EMERGENT:int = 2;
		public static const REMOVE:int = 3;
		
		public function FriendfloorsModel() 
		{
			
		}
		
		public function get floor():int 
		{
			return _floor;
		}
		
		public function set floor(value:int):void 
		{
			_floor = value;
		}
		
		public function get mkickCallback():Function 
		{
			return _mkickCallback;
		}
		
		public function set mkickCallback(value:Function):void 
		{
			_mkickCallback = value;
		}
		
		public function get fkickCallback():Function 
		{
			return _fkickCallback;
		}
		
		public function set fkickCallback(value:Function):void 
		{
			_fkickCallback = value;
		}
		
		public function get kicks():int 
		{
			return _kicks;
		}
		
		public function set kicks(value:int):void 
		{
			_kicks = value;
		}
		
		public function get totalFloor():int 
		{
			return _totalFloor;
		}
		
		public function set totalFloor(value:int):void 
		{
			_totalFloor = value;
		}
		
		public function get friends():Object 
		{
			return _friends;
		}
		
		public function set friends(value:Object):void 
		{
			_friends = value;
		}
		
		public function get window():FriendfloorsWindow 
		{
			return _window;
		}
		
		public function set window(value:FriendfloorsWindow):void 
		{
			_window = value;
		}
		
		public function get growCallback():Function 
		{
			return _growCallback;
		}
		
		public function set growCallback(value:Function):void 
		{
			_growCallback = value;
		}
		
		public function get freeze():Boolean 
		{
			return _freeze;
		}
		
		public function set freeze(value:Boolean):void 
		{
			_freeze = value;
		}
		
		public function get toThrow():Object 
		{
			return _toThrow;
		}
		
		public function set toThrow(value:Object):void 
		{
			_toThrow = value;
		}
		
		public function get crafted():int 
		{
			return _crafted;
		}
		
		public function set crafted(value:int):void 
		{
			_crafted = value;
		}
		
		public function get lifetime():int 
		{
			return _lifetime;
		}
		
		public function set lifetime(value:int):void 
		{
			_lifetime = value;
		}
		
		public function get fakefkickCallback():Function 
		{
			return _fakefkickCallback;
		}
		
		public function set fakefkickCallback(value:Function):void 
		{
			_fakefkickCallback = value;
		}
		
	}

}