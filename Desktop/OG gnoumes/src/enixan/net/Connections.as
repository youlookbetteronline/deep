package enixan.net 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.net.Socket;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	
	public class Connections extends EventDispatcher
	{
		private static var _connected:Boolean = false;
		private static var _time:int = 0;
		private var relistener:Timer;
		private var relistenTime:int = 10000;
		
		public var networks:Vector.<NetworkInterface>;
		public var usedNetwork:NetworkInterface;
		public var listenHost:String = 'google.com';
		
		public function Connections() 
		{
			networks = new Vector.<NetworkInterface>;
			
			init();
		}
		
		public function init():void {
			if (NetworkInfo.isSupported && !_connected) {
				if (!NetworkInfo.networkInfo.hasEventListener(Event.NETWORK_CHANGE)) {
					NetworkInfo.networkInfo.addEventListener(Event.NETWORK_CHANGE, networkChange);
				}
				
				networkChange(new Event(Event.NETWORK_CHANGE));
			}
		}
		
		public static function get connected():Boolean {
			return _connected;
		}
		private function setConnected(value:Boolean):void {
			if (!_connected && value) {
				_time = getTimer();
			}else {
				_time = 0;
			}
			_connected = value;
		}
		public static function get time():int {
			return (_time > 0) ? Math.floor((getTimer() - _time) / 1000) : _time;
		}
		
		private function networkChange(e:Event):void {
			networks = NetworkInfo.networkInfo.findInterfaces();
			
			checkNetwork();
		}
		private function checkNetwork(e:TimerEvent = null):void {
			if (relistener) {
				relistener.removeEventListener(TimerEvent.TIMER_COMPLETE, checkNetwork);
				relistener.stop();
				relistener = null;
			}
			
			ping(onNetworkChecked, listenHost);
		}
		private function onNetworkChecked(pingTime:int):void {
			if (pingTime > 0) {
				setConnected(true);
				dispatchEvent(new Event(Event.CONNECT));
			}else {
				if (_connected) {
					setConnected(false);
					dispatchEvent(new Event(Event.CLOSE));
				}
				
				if (!relistener) {
					relistener = new Timer(relistenTime, 1);
					relistener.addEventListener(TimerEvent.TIMER_COMPLETE, checkNetwork);
					relistener.start();
				}
			}
		}
		
		private static var ping_repeat:int = 0;
		public static var ping_callback:Function;
		public static function ping(callback:Function = null, host:String = 'google.com', repeat:int = 1):void {
			ping_callback = callback;
			ping_repeat = repeat;
			
			var socket:Socket = new Socket();
			var timer:int = getTimer();
			
			_ping();
			
			function _ping():void {
				socket.addEventListener(Event.CONNECT, connect);
				socket.addEventListener(IOErrorEvent.IO_ERROR, error);
				socket.addEventListener(Event.CLOSE, close);
				socket.connect(host, 80);
			}
			function connect(e:Event):void {
				response(true);
			}
			function error(e:IOErrorEvent):void {
				response(false);
			}
			function close(e:Event):void {
				if (ping_repeat > 0) {
					ping_repeat--;
					setTimeout(_ping, 1000);
				}else {
					ping_callback = null;
				}
			}
			function response(success:Boolean = false):void {
				if (ping_callback != null) {
					if (success) {
						ping_callback(getTimer() - timer);
					}else {
						ping_callback(-1);
					}
				}
				
				socket.close();
				socket.removeEventListener(Event.CONNECT, connect);
				socket.removeEventListener(IOErrorEvent.IO_ERROR, error);
				socket.removeEventListener(Event.CLOSE, close);
				socket = null;
			}
		}
	}

}