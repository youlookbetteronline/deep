package units.table 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TableEvent extends Event 
	{
		public static const SET_ITEMS:String = "tableEvent.setItems";
		public static const OPENED_SLOT:String = "tableEvent.openedSlot";
		public static const TAKEN_REWARD:String = "tableEvent.takenReward";
		public static const BECAME_READY:String = "tableEvent.becameReady";
		
		private var _materialID:int;
		private var _count:int;
		private var _slotID:int;
		
		
		public function TableEvent(type:String, materialID:int, count:int, slotID:int, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			
			_materialID = materialID;
			_count = count;
			_slotID = slotID;
		}
		
		public function get materialID():int 
		{
			return _materialID;
		}
		
		public function get count():int 
		{
			return _count;
		}
		
		public function get slotID():int 
		{
			return _slotID;
		}
		
		override public function clone():Event 
		{
			return new TableEvent(this.type, this.materialID, this.count, this.slotID, this.bubbles, this.cancelable);
		}
	}
}