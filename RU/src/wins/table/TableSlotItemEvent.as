package wins.table 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TableSlotItemEvent extends Event 
	{
		public static const SET_ITEMS:String = "tableSlotItemEvent.setItems";
		public static const OPEN_SLOT:String = "tableSlotItemEvent.openSlot";
		public static const TAKE_REWARD:String = "tableSlotItemEvent.takeReward";
		
		private var _materialID:int;
		private var _count:int;
		private var _slotID:int;
		
		public function TableSlotItemEvent(type:String, materialID:int, count:int, slotID:int, bubbles:Boolean=false, cancelable:Boolean=false) 
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
			return new TableSlotItemEvent(this.type, this.materialID, this.count, this.slotID, this.bubbles, this.cancelable);
		}
	}
}