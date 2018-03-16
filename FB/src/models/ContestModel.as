package models 
{
	
	/**
	 * ...
	 * @author ...
	 */
	public class ContestModel
	{
		private var _crafted:int;
		private var _floor:int;
		private var _kicks:int;
		private var _toThrow:Object;
		private var _tribute:Boolean = false;
		private var _storageCallback:Function;
		private var _throwCallback:Function;
		private var _upgradeCallback:Function;
		private var _totalFloor:int;
		
		public function ContestModel() 
		{
			super();
			
		}
		
		public function get crafted():int 
		{
			return _crafted;
		}
		
		public function set crafted(value:int):void 
		{
			_crafted = value;
		}
		
		public function get storageCallback():Function 
		{
			return _storageCallback;
		}
		
		public function set storageCallback(value:Function):void 
		{
			_storageCallback = value;
		}
		
		public function get throwCallback():Function 
		{
			return _throwCallback;
		}
		
		public function set throwCallback(value:Function):void 
		{
			_throwCallback = value;
		}
		
		public function get toThrow():Object 
		{
			return _toThrow;
		}
		
		public function set toThrow(value:Object):void 
		{
			_toThrow = value;
		}
		
		public function get tribute():Boolean 
		{
			return _tribute;
		}
		
		public function set tribute(value:Boolean):void 
		{
			_tribute = value;
		}
		
		public function get floor():int 
		{
			return _floor;
		}
		
		public function set floor(value:int):void 
		{
			_floor = value;
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
		
		public function get upgradeCallback():Function 
		{
			return _upgradeCallback;
		}
		
		public function set upgradeCallback(value:Function):void 
		{
			_upgradeCallback = value;
		}
		
	}

}