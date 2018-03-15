package models 
{
	import core.Numbers;
	import units.Craftfloors;
	/**
	 * ...
	 * @author ...
	 */
	public class CraftfloorsModel 
	{
		private var _target:Craftfloors;
		private var _slots:Array;
		private var _crafts:Array;
		private var _craftList:Array;
		private var _busySlots:Array;
		private var _openSlots:Array;
		private var _floor:int;
		private var _kicks:int;
		private var _totalFloor:int;
		private var _throwCallback:Function;
		private var _craftingCallback:Function;
		private var _growCallback :Function;
		private var _storageCallback :Function;
		private var _unlockCallback :Function;
		private var _boostCallback :Function;
		private var _cancelCallback :Function;
		private var _craftingSlot :int;
		private var _finishedSlots :Array;
		private var _toThrow:Object;
		private var _craftOnPage:int;
		
		public static const FINISH:int = 1;
		public static const INPROGRESS:int = 2;
		public static const INQUEUE:int = 3;
		public static const FREE:int = 4;
		public static const LOCKED:int = 5;
		
		public static const LEFT:int	= 1;
		public static const RIGHT:int 	= 2;
		
		public function CraftfloorsModel(target:Craftfloors) 
		{
			this._target = target;
		}
		
		public function get throwCallback():Function 
		{
			return _throwCallback;
		}
		
		public function set throwCallback(value:Function):void 
		{
			_throwCallback = value;
		}
		
		public function get craftingCallback():Function 
		{
			return _craftingCallback;
		}
		
		public function set craftingCallback(value:Function):void 
		{
			_craftingCallback = value;
		}
		
		public function get growCallback():Function 
		{
			return _growCallback;
		}
		
		public function set growCallback(value:Function):void 
		{
			_growCallback = value;
		}
		
		public function get storageCallback():Function 
		{
			return _storageCallback;
		}
		
		public function set storageCallback(value:Function):void 
		{
			_storageCallback = value;
		}
		
		public function get slotCount():int 
		{
			return Numbers.countProps(_target.info.slots);
		}
		
		public function get totalFloor():int 
		{
			return Numbers.countProps(_target.info.levels);
		}
		
		public function get craftList():Array 
		{
			return _craftList;
		}
		
		public function set craftList(value:Array):void 
		{
			_craftList = value;
		}
		
		public function get floor():int 
		{
			return _floor;
		}
		
		public function set floor(value:int):void 
		{
			_floor = value;
		}
		
		public function get craftingSlot():int 
		{
			return _craftingSlot;
		}
		
		public function set craftingSlot(value:int):void 
		{
			_craftingSlot = value;
		}
		
		public function get finishedSlots():Array 
		{
			return _finishedSlots;
		}
		
		public function set finishedSlots(value:Array):void 
		{
			_finishedSlots = value;
		}
		
		public function get toThrow():Object 
		{
			return _toThrow;
		}
		
		public function set toThrow(value:Object):void 
		{
			_toThrow = value;
		}
		
		public function get kicks():int 
		{
			return _kicks;
		}
		
		public function set kicks(value:int):void 
		{
			_kicks = value;
		}
		
		public function get slots():Array 
		{
			return _slots;
		}
		
		public function set slots(value:Array):void 
		{
			_slots = value;
		}
		
		public function get unlockCallback():Function 
		{
			return _unlockCallback;
		}
		
		public function set unlockCallback(value:Function):void 
		{
			_unlockCallback = value;
		}
		
		public function get boostCallback():Function 
		{
			return _boostCallback;
		}
		
		public function set boostCallback(value:Function):void 
		{
			_boostCallback = value;
		}
		
		public function get busySlots():Array 
		{
			return _busySlots;
		}
		
		public function set busySlots(value:Array):void 
		{
			_busySlots = value;
		}
		
		public function get openSlots():Array 
		{
			return _openSlots;
		}
		
		public function set openSlots(value:Array):void 
		{
			_openSlots = value;
		}
		
		public function get craftOnPage():int 
		{
			return 4;
		}
		
		public function get crafts():Array 
		{
			return _crafts;
		}
		
		public function set crafts(value:Array):void 
		{
			_crafts = value;
		}
		
		public function get cancelCallback():Function 
		{
			return _cancelCallback;
		}
		
		public function set cancelCallback(value:Function):void 
		{
			_cancelCallback = value;
		}
		
	}

}