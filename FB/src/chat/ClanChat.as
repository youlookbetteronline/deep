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
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author none
	 */
	public class ClanChat extends EventDispatcher
	{
		private var websocket:WebSocket;
		private var client:String = '';
		private var _token:String = '';
		private var online:Timer;
		private var msgId:uint = 0;
		private var channel:String = 'deep';
		public var messages:Array = [];
		
		private var _settings:Object = {
			maxLength:50,
			onlineTimeout:40000,
			reconnectTimeout:60000
		}
		private var _reconectTimeout:uint;
		
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
					return '31.131.252.76'
					break;
			}
			return '31.131.252.76';
		}
		
		public function ClanChat(token:String, settings:Object = null) {
			_token = token;
			for (var prop:String in settings) _settings[prop] = settings[prop];
			
			channel = App.user.clan.info.id;
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
		
		private function stressTest():void{
			//setInterval(function():void{
				//sendMessage('Сайт рыбатекст поможет дизайнеру, верстальщику, вебмастеру сгенерировать несколько абзацев более менее осмысленного текста рыбы на русском языке, а начинающему оратору отточить навык публичных выступлений в домашних условиях. При создании генератора мы использовали небезызвестный универсальный код речей. Текст генерируется абзацами случайным образом от двух до десяти предложений в абзаце, что позволяет сделать текст более привлекательным и живым для визуально-слухового восприятия.По своей сути рыбатекст является альтернативой традиционному lorem ipsum, который вызывает у некторых клиентов недоумение при попытках прочитать рыбу текст. В отличии от lorem ipsum, текст рыба на русском языке наполнит любой макет непонятным смыслом и придаст неповторимый колорит советских времен.');
			//}, 10);
		}
		
		private function init(e:Event = null):void {
			clearWebSocket();
			websocket = new WebSocket("ws://"+ip+":8000/connection/websocket", "*");
			//websocket.debug = true;
			websocket.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			websocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			websocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			websocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionFail);
			websocket.connect();
		}
		
		private function clearWebSocket():void{
			if (websocket == null) return;
			
			websocket.removeEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			websocket.removeEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			websocket.removeEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			websocket.removeEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionFail);
			websocket = null;
		}
		
		private function handleDisconnect():void{
			if (_reconectTimeout) return;
			_reconectTimeout = setTimeout(tryRecconect, _settings.reconnectTimeout);
		}
		
		private function tryRecconect():void  {
			clearTimeout(_reconectTimeout);
			_reconectTimeout = 0;
			init();
		}
		
		private function get nextMessageId() : int { return ++msgId;}
		
		private function addMessage(msg:Object, index:Boolean = true) : void {
			if(index === true) {
				msg.uid = ''+nextMessageId;
			}
			websocket.sendUTF(JSON.stringify(msg));
		}
		
		private function handleConnectionFail(e:WebSocketErrorEvent):void {
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
						client = message.body.client;
						online.start();
						////////////////// subscribe
						addMessage({
							"method": "subscribe",
							"params": {
								"channel": channel
							}
						});
						addMessage({
							"method": "history",
							"params": {
								"channel": channel
							}
						});
						dispatchEvent(new ChatEvent(ChatEvent.ON_CONNECT));
						break;
					case 'disconnect':
						dispatchEvent(new ChatEvent(ChatEvent.ON_DISCONNECT));
						if ('reason' in message.body) {
							trace('disconnect ERROR[' + message.body.reason + ']');
							Log.alert('disconnect ERROR[' + message.body.reason + ']');
						} else trace('disconnect');
						websocket.close();
						handleDisconnect();
						break;
					case 'subscribe':
						if (message.body.channel == channel &&
							message.body.status == true) {
								trace('subscribe complete');
								
								addMessage( {
									"method": "presence",
									"params": {
										"channel": channel
									}
								});
						} else websocket.close();
						break;
					case 'presence':
						for (var cid:String in message.body.data) {
							trace('client['+cid+'] user['+message.body.data[cid].user+']');
						}
						break;
					case 'join':
						trace('user['+message.body.data.user+'] join channel');
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
		
		private function addHistory(data:Array):void {
			
		}
		
		private function handleWebSocketOpen(e:WebSocketEvent):void {
			addMessage({ 
				'method' : 'connect',
				'params' : {
					'user' : App.user.id,
					'info' : '',
					'timestamp' : ''+App.user.clan.info.created,
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
		
		public function pushMessage(message:Object):void{
			var tempUser:String = 'some';
			if (message.body.info && message.body.info.user) tempUser = message.body.info.user;
			messages.push({name:tempUser, text:message.body.data.input});
			if (messages.length > _settings.maxLength){
				messages.splice(0, messages.length - _settings.maxLength);
			}
			App.self.chatWindow.refresh();
			trace('new message from['+tempUser+'] text['+message.body.data.input+']');
		}
		
		private function handleWebSocketClosed(e:WebSocketEvent):void {
			Log.alert('handleWebSocketClosed');
			Log.alert({title:'handleWebSocketClosed', event:e});
			handleDisconnect();
		}
	}
}