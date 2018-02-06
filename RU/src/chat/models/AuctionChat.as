package chat.models 
{
	import chat.ChatEvent;
	import com.junkbyte.console.Cc;
	import hlp.ToolsUtils;
	import utils.SocketActions;
	/**
	 * ...
	 * @author Andrew Lysenko
	 */
	public class AuctionChat extends ChatModel
	{
		public function AuctionChat(token:String, settings:Object)  {
			settings.timeStamp = 0;
			settings.channel = 'auction_d';
			super(token, settings);
		}
		
		override protected function onConnect(e:ChatEvent):void {
			if (_settings.hasOwnProperty('onConnect') && _settings['onConnect'] is Function)
				_settings.onConnect();
		}
		
		override protected function onNewMessage(e:ChatEvent):void {
			var message:Object = _chat.lastMessage;
			var tempUser:String = 'some';
			var temp:String = ToolsUtils.encrypt(message.body.data.input, SocketActions.not_key, false);
			try {
				var obj:Object = JSON.parse(temp);
				onHandleMessage(obj);
			}catch (e1:VerifyError){
				Cc.error(e1.getStackTrace());
			}catch (e2:SyntaxError){
				Cc.error(e2.getStackTrace());
			}
		}
		
		private function onHandleMessage(obj:Object):void{
			if (obj && obj.event == 'list'){
				if (App.user.auction.windowOpened){
					App.user.auction.updateItems(obj.data);
					App.user.auction.refreshAuctionWindow();
					if (obj.owner != App.user.id){
						if (obj.prevBet.hasOwnProperty(App.user.id)){
							var pBet:Object = obj.prevBet[App.user.id];
							App.user.auction.getRefund(pBet);
							//App.user.stock.addAll(pBet);
						}
					}
				}
			}
		}
	}
}