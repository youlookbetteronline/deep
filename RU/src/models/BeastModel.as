package models 
{
	/**
	 * ...
	 * @author ...
	 */
	public class BeastModel 
	{
		private var _crafted:int;
		private var _expire:int;
		private var _maxLengthName:int
		private var _maxTime:int
		private var _toThrow:Object;
		private var _tribute:Boolean = false;
		private var _beastName:String;
		private var _storageCallback:Function;
		private var _throwCallback:Function;
		private var _renameCallback:Function;
		
		public function BeastModel() 
		{
			
		}
		
		public function get crafted():int 
		{
			return _crafted;
		}
		
		public function set crafted(value:int):void 
		{
			_crafted = value;
		}
		
		public function get expire():int 
		{
			return _expire;
		}
		
		public function set expire(value:int):void 
		{
			_expire = value;
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
		
		public function get beastName():String 
		{
			return _beastName;
		}
		
		public function set beastName(value:String):void 
		{
			_beastName = value;
		}
		
		public function get renameCallback():Function 
		{
			return _renameCallback;
		}
		
		public function set renameCallback(value:Function):void 
		{
			_renameCallback = value;
		}
		
		public function get maxLengthName():int 
		{
			return _maxLengthName;
		}
		
		public function set maxLengthName(value:int):void 
		{
			_maxLengthName = value;
		}
		
		public function get maxTime():int 
		{
			return _maxTime;
		}
		
		public function set maxTime(value:int):void 
		{
			_maxTime = value;
		}
		
	}

}