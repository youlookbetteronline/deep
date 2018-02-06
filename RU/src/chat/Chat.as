package chat 
{
	import com.junkbyte.console.Cc;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import core.Log;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.system.Security;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import utils.SocketActions;
	import utils.SocketEventsHandler;
	
	/**
	 * ...
	 * @author none
	 */
	public class Chat extends EventDispatcher
	{
		private var websocket:WebSocket;
		private var client:String = '';
		private var _token:String = '';
		private var online:Timer;
		private var msgId:uint = 0;
		private var channel:String = 'deep';
		private var _lastMessage:Object = {};
		private var _activeUsers:Array = [];
		
		public function get lastMessage():Object {return _lastMessage};
		
		private var _settings:Object = {
			onlineTimeout:40000,
			reconnectTimeout:60000,
			channel:'deep'
		}
		public var _reconectTimeout:uint;
		
		private const IPs:Object = {
			'FB':'138.201.51.144'
		}
		
		public function get ip():String{
			switch (App.social){
				//case 'FB':
					//return 'e-fb1.islandsville.com';
					//break;
				default:
					//return 'e-fb1.islandsville.com'
					//return '31.131.252.76' // d-ok3
					
					//return '88.99.244.36':31731
					return '136.243.154.35' //vk1
					break;
			}
			return '136.243.154.35';
		}
		
		public function Chat(token:String, settings:Object) {
			Security.loadPolicyFile("xmlsocket://" + ip + ":843");
			
			_token = token;
			for (var prop:String in settings) _settings[prop] = settings[prop];
			
			channel = _settings.channel;
			if (App.user.mode == User.PUBLIC && channel != 'auction')
			{
				channel = App.user.id + '_' + User.SOCKET_MAP;
				if (App.owner)
					channel = App.owner.id + '_' + User.SOCKET_MAP;
			}
			
			init();
			online = new Timer(_settings.onlineTimeout);
			online.addEventListener(TimerEvent.TIMER, onTimeOnline);
		}
		private function onTimeOnline(e:TimerEvent):void {
			if (websocket.connected) {
				addMessage({ 
					'method': 'ping',
					'params': {}
				});
			}
		}
		
		private function init(e:Event = null):void {
			clearWebSocket();
			websocket = new WebSocket("ws://" + ip + ":8000/connection/websocket", "*");
			//websocket.addEventListener(ChatEvent.ON_DISCONNECT, onDisconnect);
			websocket.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			websocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			websocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			websocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionFail);
			websocket.connect();
		}
		
		private function clearWebSocket():void{
			if (websocket == null) return;
			
			//websocket.removeEventListener(ChatEvent.ON_DISCONNECT, onDisconnect);
			websocket.removeEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			websocket.removeEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			websocket.removeEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			websocket.removeEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionFail);
			websocket = null;
		}
		
		private function onDisconnect(e:* = null):void
		{
			Connection.sendMessage({u_event:'hero_leave', aka:App.user.aka});
		}
		
		private function handleDisconnect():void{
			if (_reconectTimeout){
				trace('has no reconectTimeout')
				return;
			}
			App.self.dispatchEvent(new AppEvent(AppEvent.SOCKET_DISCONNECT));
				
			//_reconectTimeout = setTimeout(tryRecconect, _settings.reconnectTimeout);
		}
		
		private function tryRecconect():void  {
			clearTimeout(_reconectTimeout);
			_reconectTimeout = 0;
			init();
		}
		
		private function get nextMessageId() : int { return ++msgId;}
		public function get activeUsers():Array  { return _activeUsers; }
		
		public function addMessage(msg:Object, index:Boolean = true) : void {
			if(index === true) {
				msg.uid = ''+nextMessageId;
			}
			websocket.sendUTF(JSON.stringify(msg));
		}
		
		private function handleConnectionFail(e:WebSocketErrorEvent):void 
		{
			Cc.error({title:'handleConnectionFail', event:e});
			Log.alert({title:'handleConnectionFail', event:e});
			handleDisconnect();
		}
		
		private function handleWebSocketMessage(e:WebSocketEvent):void {
			var messages:Array = [];
			var response:Object = JSON.parse(e.message.utf8Data);
			if ('method' in response) {
				messages.push(response);
			} else messages = response as Array;
			
			for (var i:int = 0; i < messages.length; i++ ) {
				var message:Object = messages[i];
				
				switch(message.method) {
					case 'connect':
						trace('connect [' + JSON.stringify(message.body) + ']');
						Cc.log('connect [' + JSON.stringify(message.body) + ']');
						client = message.body.client;
						online.start();
						////////////////// subscribe
						addMessage({
							"method": "subscribe",
							"params": {
								"channel": channel
							}
						});
						dispatchEvent(new ChatEvent(ChatEvent.ON_CONNECT));
						App.self.dispatchEvent(new ChatEvent(ChatEvent.ON_CONNECT));
						break;
					case 'disconnect':
						dispatchEvent(new ChatEvent(ChatEvent.ON_DISCONNECT));
						App.self.dispatchEvent(new ChatEvent(ChatEvent.ON_DISCONNECT));
						if ('reason' in message.body) {
							trace('disconnect ERROR[' + message.body.reason + ']');
							Cc.log('disconnect ERROR[' + message.body.reason + ']');
						} else trace('disconnect');
						websocket.close();
						handleDisconnect();
						break;
					case 'ping':
						break;
					case 'subscribe':
						if (message.body.channel == channel /*&&
							message.body.status == true*/) {
								trace('subscribe complete');
								Cc.log('subscribe complete');
								addMessage( {
									"method": "presence",
									"params": {
										"channel": channel
									}
								});
						} else 
							websocket.close();
						break;
					case 'presence':
						Cc.log('presence complete');
						trace('presence complete');    
						renewActiveUsers(message.body.data);
						break;
					case 'join':
						updateActiveUsers(message.body.data.user);
						break;		
					case 'leave':
						updateActiveUsers(message.body.data.user, false);
						break;
					case 'message':
						pushMessage(message);
						break;
					case 'history':
						addHistory(message.body.data);
						break;
					default:
						trace(JSON.stringify(message));
						break;
				}			
			}
		}
		
		private function addHistory(data:Array):void {}//TODO 
		private function handleWebSocketOpen(e:WebSocketEvent):void {
			addMessage({ 
				'method' : 'connect',
				'params' : {
					'user' : /*App.social + '' + */App.user.id,
					'info' : '',
					'timestamp' : ''+App.time,
					'token' : _token
				}
			}, false);
		}
		
		public function sendMessage(msg:String):void{
			addMessage( {
				"method": "publish",
				"params": {
					"channel": channel,
					"data": {
						"input": msg
					}
				}
			});
		}
		
		public function subscribe():void{
			addMessage( {
				"method": "subscribe",
				"params": {
					"channel": channel,
					"status": true
				}
			});
		}
		
		public function disconnect():void{
			onDisconnect();
			addMessage( {
				"method": "disconnect",
				"params": {
					"reason": 'leave'
				}
			});
		}
		
		private function renewActiveUsers(users:Object):void{
			_activeUsers = [];
			for (var cid:String in users) _activeUsers.push(users[cid].user); 
			
			_activeUsers.sort(Array.DESCENDING);
			Cc.log('renewActiveUsers ' + _activeUsers);
			SocketActions.renewUsers(_activeUsers);
			dispatchEvent(new ChatEvent(ChatEvent.UPDATE_ONLINE));
		}
		
		private function updateActiveUsers(user:String, add:Boolean = true):void{
			var index:int = _activeUsers.indexOf(user);
			if (add && index == -1) _activeUsers.push(user);
			else if (!add && index != -1) _activeUsers.splice(index, 1);
			
			_activeUsers.sort(Array.DESCENDING);
			Cc.log('updateActiveUsers '+_activeUsers);
			dispatchEvent(new ChatEvent(ChatEvent.UPDATE_ONLINE));
		}
		
		public function pushMessage(message:Object):void{
			_lastMessage = message;
			dispatchEvent(new ChatEvent(ChatEvent.NEW_MESSAGE));
		}
		
		private function handleWebSocketClosed(e:WebSocketEvent):void {
			Cc.log('handleWebSocketClosed');
			Log.alert({title:'handleWebSocketClosed', event:e});
			handleDisconnect();
		}
	}
}