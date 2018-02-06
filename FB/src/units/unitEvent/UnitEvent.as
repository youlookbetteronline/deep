package units.unitEvent 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class UnitEvent extends Event 
	{
		public static const UNIT_UPGRADE:String = "unitEvent.Upgrade";
		public static const TREE_WATERED:String = "unitEvent.TreeWatered";
		public static const UNIT_START_MOVE:String = "unitEvent.UnitStartMove";
		public static const UNIT_ANIMATION_LOOP:String = "unitEvent.AnimationLoop";
		
		public static const UNIT_SHOP_ACTION:String = "unitEvent.ShopAction";
		public static const UNIT_STOCK_ACTION:String = "unitEvent.StockAction";
		
		public static const UNIT_UNINSTALL:String = "unitEvent.Uninstall";
		
		public static const UNIT_BOOST:String = "unitEvent.Boost";
		
		public static const UNIT_REWARD_TAKEN:String = "unitEvent.RewardTaken";
		
		public function UnitEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
		}
	}
}