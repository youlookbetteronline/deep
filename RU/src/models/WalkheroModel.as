package models 
{
	/**
	 * ...
	 * @author ...
	 */
	public class WalkheroModel 
	{
		private var _level:int;
		private var _freeze:Boolean;
		private var _upgradeParams:Object;
		private var _totalLevel:int;
		private var _crafted:int;
		private var _expired:int;
		private var _upgradeCallback:Function;
		private var _storageCallback:Function;
		public function WalkheroModel() 
		{
			
		}
		
		public function get level():int 
		{
			return _level;
		}
		
		public function set level(value:int):void 
		{
			_level = value;
		}
		
		public function get totalLevel():int 
		{
			return _totalLevel;
		}
		
		public function set totalLevel(value:int):void 
		{
			_totalLevel = value;
		}
		
		public function get upgradeParams():Object 
		{
			return _upgradeParams;
		}
		
		public function set upgradeParams(value:Object):void 
		{
			_upgradeParams = value;
		}
		
		public function get upgradeCallback():Function 
		{
			return _upgradeCallback;
		}
		
		public function set upgradeCallback(value:Function):void 
		{
			_upgradeCallback = value;
		}
		
		public function get storageCallback():Function 
		{
			return _storageCallback;
		}
		
		public function set storageCallback(value:Function):void 
		{
			_storageCallback = value;
		}
		
		public function get crafted():int 
		{
			return _crafted;
		}
		
		public function set crafted(value:int):void 
		{
			_crafted = value;
		}
		
		public function get expired():int 
		{
			return _expired;
		}
		
		public function set expired(value:int):void 
		{
			_expired = value;
		}
		
		public function get freeze():Boolean 
		{
			return _freeze;
		}
		
		public function set freeze(value:Boolean):void 
		{
			_freeze = value;
		}
		
	}

}