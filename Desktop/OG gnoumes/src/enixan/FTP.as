package enixan 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author 
	 */
	public class FTP extends EventDispatcher 
	{
		
		public static const USER:String = 'USER';
		public static const PASS:String = 'PASS';
		public static const HELP:String = 'HELP';
		public static const QUIT:String = 'QUIT';
		public static const LIST:String = 'LIST';		// Список файлов и директори
		public static const NLST:String = 'NLST';		// Список файлов и директори
		public static const PASV:String = 'PASV';		// Пассивный режим
		public static const SYST:String = 'SYST';		// Параметры системы
		
		public var ip:String;
		public var port:int;
		private var passive_ip:String;
		private var passive_port:int;
		
		public var username:String = 'empty';
		public var password:String = 'ae21eb1733';
		
		private var commands:String = 'USER PASS HELP QUIT';
		
		public function FTP(ip:String = null, port:int = 22) {
			
			this.ip = ip;
			this.port = port;
			
		}
		
		private var socket:Socket;
		private var dataSocket:Socket;
		public function connect(ip:String = null, port:int = 0):void {
			
			if (ip) this.ip = ip;
			if (port) this.port = port;
			
			socket = new Socket();
			socket.addEventListener(Event.CONNECT, onConnect);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			socket.addEventListener(Event.CLOSE, onClose);
			
			dataSocket = new Socket();
			dataSocket.addEventListener(Event.CONNECT, onConnect);
			dataSocket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
			dataSocket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			dataSocket.addEventListener(Event.CLOSE, onClose);
			
			reconnect();
		}
		
		
		private var __connected:Boolean;
		private var connecting:Boolean;
		public function get connected():Boolean {
			return __connected;
		}
		public function reconnect():void {
			if (socket.connected || connecting) return;
			
			recognized = 0;
			connecting = true;
			socket.connect(ip, port);
		}
		
		
		private function onConnect(e:Event):void {
			//connecting = false;
			
			var sct:Socket = e.target as Socket;
			switch(sct) {
				case socket:
					trace('Socket', e.toString());
					connecting = false;
					break;
				case dataSocket:
					trace('DataSocket', e.toString());
					break;
			}
		}
		private function onData(e:ProgressEvent):void {
			//trace(e.toString());
			
			var sct:Socket = e.target as Socket;
			var data:String = sct.readMultiByte(sct.bytesAvailable, 'iso-8859-1');
			
			for (var i:int = 0; i < listeners.length; i++) {
				listeners[i](data);
			}
			
			switch(sct) {
				case socket:
					trace('Socket', data);
					handleSocket(data);
					break;
				case dataSocket:
					trace('DataSocket', data);
					break;
			}
		}
		private function onError(e:IOErrorEvent):void {
			connecting = false;
			
			trace(e.toString());
		}
		private function onClose(e:Event):void {
			var sct:Socket = e.target as Socket;
			switch(sct) {
				case socket:
					trace('Socket', e.toString());
					break;
				case dataSocket:
					trace('DataSocket', e.toString());
					break;
			}
		}
		
		
		private var recognized:int;
		private var recognizedData:String;
		private var currentDirectory:String;
		private function handleSocket(data:String):void {
			if (recognized) {
				recognizedData += data;
				
				if (data.lastIndexOf('OK') > data.length - 6) {
					recognized = 0;
					data = recognizedData;
				}
				
			}else if (data.search(/The following commands are recognized/) > -1 && data.lastIndexOf('OK') < data.length - 6) {
				recognized = int(data.substring(0, data.indexOf('-')));
				recognizedData = data;
			}
			
			if (recognized) return;
			
			// Логин
			if (data.search(/^220\s/g) == 0) {
				command(USER, username);
			}
			
			// Пароль
			if (data.search(/^331\s/g) > -1) {
				command(PASS, password);
			}
			
			// Поддерживаемые команды
			if (data.search(/^230\s/g) > -1) {
				__connected = true;
				//command(HELP);
				//command(LIST, '\\');
			}
			
			// Время соединения истекло
			if (data.search(/^421\s/g) > -1) {
				__connected = false;
			}
			
			// 
			if (data.search(/214\s/) > -1) {
				commands = data.substring(0, data.search(/214\s/));
				//command('PWD', '\\');
			}
			
			// Текущая директория
			if (data.search(/^257\s/) > -1) {
				currentDirectory = data.substring(4, data.length);
				//command(PASV);
			}
			
			// Пассивный режим
			if (data.search(/^227\s/) > -1) {
				var object:Object = new RegExp(/[0-9\,]+/g).exec(data.substring(4,data.length));
				if (object && object[0]) {
					var array:Array = object[0].split(',');
					passive_ip = array.splice(0, 4).join('.')
					passive_port = (int(array[0]) << 8) + int(array[1]);
					trace(passive_ip, passive_port);
					dataSocket.connect(passive_ip, passive_port);
					/*setTimeout(function():void {
						command(LIST);
					}, 2000);*/
				}
			}
			
			/*if (commandList.length > 0) {
				object = commandList.shift();
				command(object.comm, object.data);
			}*/
		}
		
		private var commandList:Array = [];
		public function command(comm:String, data:String = ''):void {
			
			if (comm != USER && comm != PASS && !connected) {
				commandList.push( { comm:comm, data:data } );
				reconnect();
				return;
			}
			
			switch(comm) {
				default:
					if (commands.indexOf(comm) == -1) return;
					send(comm + ((data.length > 0) ? ' ' + data : data)+ '\n');
			}
		}
		private function send(data:String):void {
			socket.writeUTFBytes(data);
			socket.flush();
		}
		
		
		
		// Shitcode
		private var listeners:Vector.<Function> = new Vector.<Function>;
		public function dataListener(func:Function):void {
			listeners.push(func);
		}
		
	}

}