package chat.models 
{
	import chat.Chat;
	import chat.ChatEvent;
	import com.junkbyte.console.Cc;
	import utils.SocketEventsHandler;
	//import engine.BattleModel;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import hlp.ToolsUtils;
	/**
	 * ...
	 * @author none
	 */
	public class ChatModel 
	{
		protected var messages:Array = [];
		protected var _chat:Chat;
		protected var _settings:Object;
		
		public var start:Boolean = false;
		public var token:Object;
		
		public function ChatModel(token:String, settings:Object) {
			if (settings == null)
				settings = {};
			_settings = settings;
			this.token = token;
			initChat(token);
			setListeners();
		}
		
		public function initChat(token:String):void{
			_chat = new Chat(token, _settings);
		}
		
		public function chatDisconnect():void{
			if (_chat)
				_chat.disconnect();
		}
		
		public function setListeners():void{
			_chat.addEventListener(ChatEvent.NEW_MESSAGE, onNewMessage);
			_chat.addEventListener(ChatEvent.ON_CONNECT, onConnect);
			_chat.addEventListener(ChatEvent.UPDATE_ONLINE, updateOnline);
		}
		
		protected function updateOnline(e:ChatEvent):void {
			if (start) return;
			if (_chat.activeUsers.length == 2){
				start = true;
				//setTimeout(function():void{ //comented me
					//App.self.goToMission(14);
				//}, 1000);
			}
		}
		protected function onConnect(e:ChatEvent):void {
			if(_settings.hasOwnProperty('onParamsConnect'))
				_settings.onParamsConnect(e);
		}
		
		protected function onNewMessage(e:ChatEvent):void {
			var message:Object = _chat.lastMessage;
			var tempUser:String = 'some';
			if (message.body.info && message.body.info.user) 
				tempUser = message.body.info.user;
				
			messages.push({name:tempUser, text:message.body.data.input});
			if (tempUser == App.user.id)
				trace('its me!');
			Cc.log('new message from[' + tempUser + '] text[' + message.body.data.input + ']');	
			trace('new message from[' + tempUser + '] text[' + message.body.data.input + ']');
			//SocketEventsHandler.handleEvent(tempUser, JSON.parse(message.body.data.input));
			onHandleMessage(tempUser, JSON.parse(message.body.data.input));
		}
		
		public function sendMessage(msg:String):void{
			//Cc.log(msg);
			_chat.sendMessage(msg);
		}
		
		public function isOnline(uID:String):Boolean{
			return (_chat.activeUsers.indexOf(uID) != -1);
		}
		
		public function dispose():void{
			if (_chat){
				_chat.removeEventListener(ChatEvent.NEW_MESSAGE, onNewMessage);
				_chat.removeEventListener(ChatEvent.ON_CONNECT, onConnect);
			}
		}
		
		public function get chat():Chat { return _chat; }
		
		private function onHandleMessage(uid:String, obj:Object):void{
			if (uid == App.user.id) 
				return;
			SocketEventsHandler.handleEvent(uid, obj);
			//BattleModel.self.onHandleMessage(uid, obj);
		}
		
	}

}