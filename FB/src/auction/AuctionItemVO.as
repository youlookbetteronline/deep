package auction 
{
	/**
	 * ...
	 * @author Andrew Lysenko
	 */
	public class AuctionItemVO  {
		private var _bet:int;
		private var _data:Object;
		private var _id:String;
		private var _info:AuctionItemInfo; 
		public function AuctionItemVO(item:Object)  {
			_bet = item.bet || 0;
			_data = item.data || {bet:0, winner:''};
			_id = item.id_lot;
			_info = new AuctionItemInfo(item.info);
		}
		
		public function get bet():int 
		{
			return (_data.bet) ? Math.ceil(_data.bet * info.price_percent) : info.price_start;
		}
		
		public function get currentBet():int{
			return _data.bet;
		}
		
		public function get betObject():Object{
			var result:Object = {};
			result[info.price_sid] = bet;
			return result;
		}
		
		public function get data():Object 
		{
			return _data;
		}
		
		public function get id():String 
		{
			return _id;
		}
		
		public function get info():AuctionItemInfo 
		{
			return _info;
		}
	}
}