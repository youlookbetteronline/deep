package auction 
{
	import hlp.ToolsUtils;
	/**
	 * ...
	 * @author Andrew Lysenko
	 */
	public class AuctionItemInfo 
	{
		private var _backview		:String;
		private var _objectSid		:int;
		private var _object			:Object;
		private var _price_percent	:Number;
		private var _price_sid		:int;
		private var _price_start	:int;
		//private var _sid			:int;
		private var _expire			:ExpireVO;
		private var _bonus			:Object;
		private var _bet_bonus		:Object;
		private var _enabled		:String;
		//private var _storageInfo	:Object;
		
		public function AuctionItemInfo(info:Object)  {
			_backview		 = info.image;
			_enabled		 = info.enabled;
			_objectSid		 = info.object;			
			_object			 = App.data.storage[_objectSid];			
			_price_percent	 = info.price_percent;	
			_price_sid		 = info.price_sid;		
			_price_start	 = info.price_start;	
			//_sid			 = info.sid;
			_bonus			 = info.bonus;
			_bet_bonus			 = info.bet_bonus || "";
			//_storageInfo 	 = App.data.storage[_sid];
			_expire = new ExpireVO(info.expire);
		}
		
		public function get backview():String 
		{
			return _backview;
		}
		
		public function get enabled():String 
		{
			return _enabled;
		}
		
		public function get description():String{
			return _object.description;
		}
		
		public function get object():Object 
		{
			return _object;
		}
		
		public function get price_percent():Number 
		{
			return _price_percent;
		}
		
		public function get price_sid():int 
		{
			return _price_sid;
		}
		
		public function get price_start():int 
		{
			return _price_start;
		}
		
		//public function get sid():int 
		//{
			//return _sid;
		//}
		
		public function get expire():ExpireVO 
		{
			return _expire;
		}
		
		public function get objectSid():int 
		{
			return _objectSid;
		}
		
		public function get bonus():Object 
		{
			return _bonus;
		}
		
		public function get bet_bonus():Object 
		{
			return _bet_bonus;
		}
		
	}

}