package auction 
{
	import chat.models.AuctionChat;
	import core.Numbers;
	import core.Post;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import wins.AuctionRewardWindow;
	import wins.AuctionWindow;

	public class Auction extends EventDispatcher {
		private var _activeAuctionId:String;
		private var _activeItems:Vector.<AuctionItemVO>;
		private var _closedItems:Vector.<AuctionItemVO>;
		
		private var _updater:Updater;
		private var _lastData:String = '';
		
		private var _initialized:Boolean = false;
		private var _chat:AuctionChat;
		private var _auctionWindow:AuctionWindow;
		private var _auctionWindowOpening:Boolean;
		private var _auctionID:String;
		private var _connecting:Boolean = true;
		private var _token:String = '';
		private var _prevRefund:String;
		
		public function Auction()  {
			_closedItems = new Vector.<AuctionItemVO>(); 
			_updater = new Updater(init);
			
			//App.self.addEventListener(AppEvent.SOCKET_DISCONNECT, handleDisconnect);
		}
		
		public function chatConnect():void
		{
			//var that:* = this;
			Post.send({
				ctr: 'user',
				act: 'aconnect',
				uID: App.user.id,
				wID: App.user.worldID
			}, function(e:int, data:Object, params:Object):void {
				if (e){
					//that.close();
					if(_auctionWindow)
						_auctionWindow.close();
					return;
				}
				
				if (data.auction){
					initChat(data.auction.id, data.auction.token);
				}
			});
		}
		
		//public function handleDisconnect(e:* = null):void{
			////if (_auctionWindow){
				////reinitChat();
			////}
			//new AuctionConnectionWindow({}).show();
		//}
		
		public function init(callback:Function = null):void{
			//return;
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
				if (data.refund && Numbers.countProps(data.refund) > 0)
					getRefund(data.refund);
					//App.user.stock.addAll(data.refund);
				updateItems(data);
				_initialized = true;
				_updater.lastUpdateTime = App.time;
				if (callback != null) callback();
			});
		}
		
		public function refreshAuctionWindow():void
		{
			if (_auctionWindow != null)
				_auctionWindow.refresh(_activeItems, _closedItems);
		}
		
		//public function reinitChat():void{
			//if (_auctionWindow && !_connecting){
				//if (_chat && _token.length > 0){
					//var _token:String = _token;
					//_chat.dispose();
					//_chat = new AuctionChat(_token, {onConnect:onConnect});
					////showAuctionWindow();
				//}else{
					//_auctionWindow.connect();
				//}
			//}
		//}
		
		public function initChat(id:int, token:String):void{
			_chat = new AuctionChat(token, {onConnect:onConnect});
			_token = token;
		}
		
		public function onConnect():void{
			_connecting = false;
		}
		
		public function chatDisconnect():void{
			if (_chat)
			{
				_auctionWindow = null;
				_chat.dispose();
				_chat.chatDisconnect();
				_chat = null;
			}
		}
		
		public function makeBet(itemVO:AuctionItemVO, count:int = 0, finishCallback:Function = null):void{
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
					//App.user.stock.addAll(itemVO.betObject);
					init();
					return;
				}
				
				if (data.sbonus) App.user.stock.addAll(data.sbonus);
				if (data.refund && Numbers.countProps(data.refund) > 0)
					App.user.stock.addAll(data.refund);
				if (data.price){
					App.user.stock.takeAll(data.price);
				}
				if (finishCallback != null) finishCallback(data);
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
			if (_auctionWindow != null) 
				return;
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
			if (!_auctionWindow)
				return;
			_auctionWindow.close();
			_auctionWindow = null;
		}
		
		public function getRefund(refund:Object):void
		{
			var currentRefund:String = JSON.stringify(refund);
			if (currentRefund == _prevRefund) return;
			_prevRefund = currentRefund;
			App.user.stock.addAll(refund);
		}
		
		public function checkReward():void
		{
			if (_auctionID == null) return;
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
					for each (var activeLot:Object in _activeItems)
					{
						if (activeLot.id == victory.id_lot)
						{
							victory['objectID'] = activeLot.info.objectSid;
							new AuctionRewardWindow(victory).show();
							return;
						}
					}
					for each (var closedLlot:Object in _closedItems)
					{
						if (closedLlot.id == victory.id_lot)
						{
							victory['objectID'] = closedLlot.info.objectSid;
							new AuctionRewardWindow(victory).show();
							return;
						}
					}
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
				//new StockWindow({ "find":{"sid":Numbers.firstProp(data.reward).key}});
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
				if (_auction.enabled && App.time > _auction.expire.s && App.time < _auction.expire.e){
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
		public function get auctionWindow():AuctionWindow { return _auctionWindow; }
		public function set auctionWindow(value:AuctionWindow):void { _auctionWindow = value; }
		public function get chat():AuctionChat { return _chat; }
		public function set chat(value:AuctionChat):void { _chat = value; }
	}
}