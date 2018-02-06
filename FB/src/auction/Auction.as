package auction 
{
	import chat.models.AuctionChat;
	import core.Load;
	import core.Post;
	import wins.AuctionRewardWindow;
	import wins.AuctionWindow;
	//import empire.battle.Battle;
	//import empire.farm.Farm;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Andrew Lysenko
	 */
	public class Auction extends EventDispatcher {
		private var _activeItems:Vector.<AuctionItemVO>;
		private var _closedItems:Vector.<AuctionItemVO>;
		
		private var _updater:Updater;
		private var _lastData:String = '';
		
		private var _initialized:Boolean = false;
		private var _chat:AuctionChat;
		private var _auctionWindow:AuctionWindow;
		private var _auctionWindowOpening:Boolean;
		private var _auctionID:String;
		
		public function Auction()  {
			_closedItems = new Vector.<AuctionItemVO>(); 
			_updater = new Updater(init);
			
			//_updater.start();
		}
		
		public function init(callback:Function = null):void{
			//return;
			//if (Battle.self) return;
			initActiveAuction();
			if (_auctionID == null) return;
			
			Post.send({
				ctr:'auction',
				act:'list',
				id_auction:_auctionID,
				uID:App.user.id
			}, function(e:int, data:Object, params:Object):void{
				if (e) return;
				if (data.sbonus) App.user.stock.addAll(data.sbonus);
				updateItems(data);
				_initialized = true;
				_updater.lastUpdateTime = App.time;
				if (callback != null) callback();
			});
		}
		
		public function refreshAuctionWindow():void
		{
			if (_auctionWindow != null)
					_auctionWindow.refresh();
		}
		
		public function initChat(id:int, token:String):void{
			_chat = new AuctionChat(token, {});
		}
		
		public function chatDisconnect():void{
			if (_chat)
			{
				_auctionWindow = null;
				_chat.dispose();
				_chat.chatDisconnect();
			}
		}
		
		public function makeBet(itemVO:AuctionItemVO, count:int = 0, finishCallback:Function = null):void{
			if (!App.user.stock.takeAll(itemVO.betObject)) return;
			Post.send({
				ctr:'auction',
				act:'bet',
				id_lot:itemVO.id,
				id_auction:_auctionID,
				bet:count || itemVO.bet,
				uID:App.user.id
			}, function(e:int, data:Object, params:Object):void{
				if (e) return;
				if (data.error){
					App.user.stock.addAll(itemVO.betObject);
					init();
					return;
				}
				if (data.sbonus) App.user.stock.addAll(data.sbonus);
				//if (data.refund) App.user.stock.addAll(data.refund);
				if (finishCallback != null) finishCallback();
				//init();
			});
		}
		
		public function updateItems(data:Object):void{
			var tempData:String = JSON.stringify(data);
			if (tempData == _lastData) return;
			_lastData = tempData;
			
			_activeItems = new Vector.<AuctionItemVO>();
			_closedItems = new Vector.<AuctionItemVO>();
			var itemVO:AuctionItemVO;
			var item:Object;
			for each (item in data.active){
				itemVO = new AuctionItemVO(item);
				_activeItems.push(new AuctionItemVO(item));
			}
			_activeItems.sort(compare);
			for each (item in data.closed){
				itemVO = new AuctionItemVO(item);
				_closedItems.push(new AuctionItemVO(item));
			}
			_closedItems.sort(compare);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function openAuctionWindow():void{
			if (_auctionWindow != null) return;
			_auctionWindowOpening = true;
			_auctionWindow = new AuctionWindow({onClose:onAuctionClose});
			if (App.time - _updater.lastUpdateTime < 10){
				onOpenWindow();
			}
			else {
				init(onOpenWindow);
			}
		}
		
		public function showAuctionWindow():void{
			if (_auctionWindow == null) return;
			_auctionWindow.show();
		}
		
		public function closeAuctionWindow():void{
			_auctionWindow.close();
			//_auctionWindow.dispose();
			_auctionWindow = null;
		}
		
		public function getRefund(prevBet:Object):void{
			for (var item:* in prevBet)
			{
				if (item == App.user.id)
					App.user.stock.addAll(prevBet[App.user.id]);
			}
		}
		
		public function checkReward():void
		{
			return;
			Post.send({
				ctr: 'Auction',
				act: 'myvictories',
				uID: App.user.id
			}, function(e:int, data:Object, params:Object):void {
				if (e){
					//обрабатываем ошибку
					return;
				}
				for each (var victory:Object in data.victories) 
				{
					new AuctionRewardWindow(victory).show();
				}
			});
		}
		
		public function getReward(reward:Object):void
		{
			Post.send({
				ctr: 'Auction',
				act: 'reward',
				id_auction: reward.id_auction,
				id_lot: reward.id_lot,
				uID: App.user.id
			}, function(e:int, data:Object, params:Object):void {
				if (e){
					//обрабатываем ошибку
					return;
				}
				App.user.stock.addAll(data.reward);
			});
		}
		
		private function compare(item1:AuctionItemVO, item2:AuctionItemVO):Number {
			return (item1.info.expire.end < item2.info.expire.end) ? -1 : 1;
		}
		
		private function initActiveAuction():void{
			var _auction:Object;
			for (var id:String in App.data.auctions){
				_auction = App.data.auctions[id];
				if (App.time > _auction.expire.s && App.time < _auction.expire.e){
					_auctionID = id;
					return;
				}
			}
			_auctionID = null;
		}
		
		private function onWinningAuctionLot(e:int, data:Object, params:Object):void 
		{
			if (e) return;
		}
		
		private function onOpenWindow():void {
			if (_auctionWindow == null) return;
			//if (!Farm.self) return;
			_auctionWindow.show();
		}
		
		private function onAuctionClose():void {
			_auctionWindow = null;
		}
		
		public function get activeItems():Vector.<AuctionItemVO>  { return _activeItems; }
		public function get closedItems():Vector.<AuctionItemVO>  { return _closedItems; }
		
		public function get updater():Updater  { return _updater; }
		public function get windowOpened():Boolean {return (_auctionWindow != null)}
		
		public function get auctionID():String { return _auctionID;}
		
		public function get auctionWindowOpening():Boolean {return _auctionWindowOpening;}
		public function set auctionWindowOpening(value:Boolean):void {_auctionWindowOpening = value;}
	}
}