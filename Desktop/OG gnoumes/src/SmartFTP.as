/*
 * @author McGrave
 * @author Visionlore
 * @email visionlore@gmail.com
 * @version 1.0;
 * This solution works in "passive mode" (oposite of "active mode") for transfered data
 */
package  {
	import flash.events.ProgressEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.events.IOErrorEvent;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	public class SmartFTP {
		public static const LOGIN_SUCCESS:String = 'loginSuccess';
		public static const DOWNLOAD_SUCCESS:String = 'downloadSuccess';
		public static const UPLOAD_SUCCESS:String = 'uploadSuccess';
		public static const CONNECTION_CLOSED:String = 'connectionClosed';
		public static const CONNECTION_TIMEOUT:String = 'connectionTimeout';
		public static const LOGIN_FAILD:String = 'loginFaild';
		public static const DIRECTORY_FAILD:String = 'directoryFaild';
		public static const UPLOAD_STREAM_SUCCESS:String = 'uploadStreamSuccess';
		public static const STREAM_CLOSED:String = 'streamClosed';
		public static const ERROR:String = 'error';
		public static const DIR_LIST_RECEIVED:String = 'dirListReceived';
		//
		private var _host:String;
		private var _username:String;
		private var _password:String;
		private var _port:int;
		private var _path:String;
		private var _task:String;
		private var _message:Vector.<String>;
		private var _error:Vector.<String>;
		private var _taskList:Vector.<Object>;
		private var _busy:Boolean;
		private var busyChecker:Boolean;
		//
		public var listener:Function;
		//
		private var cmdSocket:Socket;
		private var dataSocket:Socket;
		private var fileStream:FileStream;
		private var streamBuffer:int;
		private var closeStreamTimer:Timer;
		private var uploadAndCloseTimer:Timer;
		private var busyTimeout:Timer;
		private var byteArray:ByteArray;
		
		public function SmartFTP(host:String = null, username:String = null, password:String = null, port:int = 21):void {
			_host = host;
			_username = username;
			_password = password;
			_port = port;
			_task = null;
			_message = new Vector.<String>();
			_error = new Vector.<String>();
			_taskList = new Vector.<Object>();
			//
			closeStreamTimer = new Timer(20, 0);
			closeStreamTimer.addEventListener(TimerEvent.TIMER, closeStreamCheck);
			uploadAndCloseTimer = new Timer(333, 0);
			uploadAndCloseTimer.addEventListener(TimerEvent.TIMER, uploadAndCloseCheck);
			busyTimeout = new Timer(3000, 0);
			busyTimeout.addEventListener(TimerEvent.TIMER, busyCheck);
			//
			fileStream = new FileStream();
			cmdSocket = new Socket();
			cmdSocket.addEventListener(ProgressEvent.SOCKET_DATA, onReceivedSCmd);
			cmdSocket.addEventListener(Event.CONNECT, onConnectSCmd);
			cmdSocket.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
			cmdSocket.addEventListener(Event.CLOSE, onCloseSCmd);
			dataSocket = new Socket();
			dataSocket.addEventListener(ProgressEvent.SOCKET_DATA, onReceivedSData);
			dataSocket.addEventListener(Event.CONNECT, onConnectSData);
			dataSocket.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
			dataSocket.addEventListener(Event.CLOSE, onCloseSData);
			if (host && username && password) {
				_busy = true;
				cmdSocket.connect(host, port);
			}
		}
		
		//--------------SOCKET CMD
		//Handle codes received from server
		//List of codes: http://en.wikipedia.org/wiki/List_of_FTP_server_return_codes
		private function onReceivedSCmd(e:ProgressEvent):void {
			var code:String = cmdSocket.readUTFBytes(cmdSocket.bytesAvailable);
			addMsg('Received: ' + code);
			if (code.indexOf('220 ') > -1) { //Send user name
				cmdSocket.writeUTFBytes('USER ' + _username + '\n');
				cmdSocket.flush();
			}
			if (code.indexOf('331 ') > -1) { //Username accepted now send _password
				cmdSocket.writeUTFBytes('PASS ' + _password + '\n');
				cmdSocket.flush();
			}
			if (code.indexOf('230') > -1) { //Passwor accepted
				_busy = false;
				addMsg('LOGIN SUCCESSFUL - CONNECTION OPEN');
				_listener({target: this, code: 230, type: 'loginSuccess', task: _task, msg: code});
				busyTimeout.start();
			}
			if (code.indexOf('421') > -1) { //Transfer timeout
				_busy = false;
				busyChecker = false;
				addMsg('TRANSFER TIMEOUT - CONTROL CONNECTION CLOSED');
				_listener({target: this, code: 421, type: 'connectionTimeout', task: _task, msg: code});
			}
			if (code.indexOf('530') > -1) { //Login faild
				closeData();
				addError('LOGIN FAILED - CONNECTION CLOSED');
				_listener({target: this, code: 530, type: 'loginFaild', task: _task, msg: code});
				_listener({target: this, code: 530, type: 'streamClosed', task: _task, msg: code});
			}
			if (code.indexOf('550') > -1) { //Wrong directory
				closeData();
				addError('WRONG DIRECTORY');
				_listener({target: this, code: 550, type: 'directoryFaild', task: _task, msg: code});
				_listener({target: this, code: 550, type: 'streamClosed', task: _task, msg: code});
			}
			var index:int = code.indexOf('227');
			if (index > -1) { //Entering passive mode
				//Passive mode message example: 227 Entering Passive Mode (288,120,88,233,161,214)
				//And interpretation: IP is 288.120.88.233, and PORT is 161*256+214 = 41430
				var st:int = code.indexOf('(', index);
				var en:int = code.indexOf(')', index);
				var str:String = code.substring(st + 1, en);
				var ar:Array = str.split(',');
				var p1:int = int(ar.pop());
				var p2:int = int(ar.pop());
				_host = ar.join('.');
				_port = (p2 * 256) + (p1 * 1);
				_busy = true;
				dataSocket.connect(_host, _port);
			}
			if (code.indexOf('226 ') > -1) { //Requested file action successful (download/upload/abort)
				//Forece disconnect socket cmd after action if you want
				//cmdSocket.writeUTFBytes("QUIT \n");
				//cmdSocket.flush();
				if (_task == 'download') {
					addMsg('DOWNLOAD COMPLETE');
					_listener({target: this, code: 226, type: 'downloadSuccess', task: _task, msg: code});
				}
				if (_task == 'upload') {
					addMsg('UPLOAD COMPLETE');
					_listener({target: this, code: 226, type: 'uploadSuccess', task: _task, msg: code});
				}
				closeStreamTimer.start(); //Close stream if data socket connection is closed
			}
			if (code.indexOf('221 ') > -1) { //Service closing control connection
				_busy = false;
				addMsg('CONTROL CONNECTION CLOSED');
				_listener({target: this, code: 221, type: 'connectionClosed', task: _task, msg: code});
			}
			if (code.indexOf('150 ') > -1) { //Ready for data connection after we send 'PASV' command
				if (_task == 'upload') {
					_busy = true;
					uploadAndCloseTimer.start();
				} else if (_task == 'download') {
					_busy = true;
				} else {
					_busy = false;
				}
			}
		}
		
		private function onConnectSCmd(e:Event):void {
			addMsg('CONNECTED TO FTP');
		}
		
		private function onCloseSCmd(e:Event):void {
			addMsg('COMMAND CHANELL CLOSED');
		}
		
		//Used by Socket Cmd
		
		private function closeStreamCheck(e:TimerEvent):void { //Keep connection until data is written (connection is open)
			if (!dataSocket.connected) {
				fileStream.close()
				closeStreamTimer.stop();
				_busy = false;
				addMsg('UPLOAD STREAM SUCCESS');
				var code:String = dataSocket.readUTFBytes(dataSocket.bytesAvailable);
				_listener({target: this, code: null, type: 'uploadStreamSuccess', task: _task, msg: code});
				_listener({target: this, code: null, type: 'streamClosed', task: _task, msg: code});
			}
		}
		
		private function uploadAndCloseCheck(e:TimerEvent):void {
			if (fileStream.bytesAvailable <= 0) {
				uploadAndCloseTimer.stop();
				dataSocket.close();
			} else { //if something gets wrong and after first try there is still data available
				if (fileStream.bytesAvailable < streamBuffer) { //avoid problems - make sure there is always lower buffer on
					streamBuffer = fileStream.bytesAvailable;
				}
				byteArray = new ByteArray();
				//Non async stream
				fileStream.readBytes(byteArray, 0, streamBuffer); //load fileStream data to byteArray
				dataSocket.writeBytes(byteArray, 0, byteArray.bytesAvailable); //save byteArray via data socket
				dataSocket.flush();
			}
		}
		
		//--------------SOCKET DATA
		
		private function onReceivedSData(e:ProgressEvent):void {
			var code:String;
			if (_task == 'dirList') {
				code = dataSocket.readUTFBytes(dataSocket.bytesAvailable);
				addMsg('Received: ' + code);
				_listener({target: this, code: null, type: 'dirListReceived', task: _task, msg: code});
			} else if (_task == 'download') {
				byteArray = new ByteArray();
				dataSocket.readBytes(byteArray, 0, dataSocket.bytesAvailable); //load dataSocket data to byteArray
				fileStream.writeBytes(byteArray, 0, byteArray.bytesAvailable); //save byteArray via file stream
			}
		}
		
		private function onConnectSData(e:Event):void {
			_busy = true;
			addMsg('Connected to DATA port');
			if (_task == 'dirList') {
				//example path: /public_html
				cmdSocket.writeUTFBytes("NLST " + _path + "\n");
			} else if (_task == 'download') {
				//example path: /public_html/oldBanner.jpg
				cmdSocket.writeUTFBytes("RETR " + _path + "\n");
			} else if (_task == 'upload') {
				//example path: /public_html/newBanner.jpg
				cmdSocket.writeUTFBytes("STOR " + _path + "\n");
			}
			cmdSocket.flush();
		}
		
		private function onCloseSData(e:Event):void {
			addMsg('DATA CHANELL CLOSED');
		}
		
		//For both sockets
		
		private function onSocketError(e:IOErrorEvent):void {
			close();
			addMsg(e.errorID + ':' + e.text);
			_busy = false;
			var code:String = dataSocket.readUTFBytes(dataSocket.bytesAvailable);
			_listener({target: this, code: null, type: 'error', task: _task, msg: code});
			_listener({target: this, code: e.errorID, type: 'streamClosed', task: _task, msg: code});
		}
		
		//--------------TRIGGERS
		
		public function upload(localPath:String, ftpPath:String = ''):void {
			if (connected && _busy == false) {
				var file:File = new File(localPath);
				if (file.exists && ftpPath.length) {
					_busy = true;
					_task = 'upload';
					_path = ftpPath;
					fileStream.open(file, FileMode.READ);
					cmdSocket.writeUTFBytes('TYPE I\n'); //set data as binary
					cmdSocket.writeUTFBytes('PASV \n'); //use passive mode
					cmdSocket.flush();
				} else {
					addError("Incorrect URL path");
				}
			} else {
				addError("Can't upload with closed or busy connection");
			}
		}
		
		public function uploadTask(localPath:String, ftpPath:String = ''):void {
			_taskList.push({task: 'upload', localPath: localPath, ftpPath: ftpPath});
		}
		
		public function download(localPath:String, ftpPath:String):void {
			if (connected && _busy == false) {
				var file:File = new File(localPath);
				if (ftpPath.length) {
					_busy = true;
					_task = 'download';
					_path = ftpPath;
					fileStream.open(file, FileMode.WRITE);
					cmdSocket.writeUTFBytes('TYPE I\n');
					cmdSocket.writeUTFBytes('PASV \n');
					cmdSocket.flush();
				} else {
					addError("Incorrect URL path");
				}
			} else {
				addError("Can't download with closed or busy connection");
			}
		}
		
		public function downloadTask(localPath:String, ftpPath:String):void {
			_taskList.push({task: 'download', localPath: localPath, ftpPath: ftpPath});
		}
		
		public function dirListMsg(ftpPath:String):void {
			if (connected && _busy == false) {
				_busy = true;
				_task = 'dirList';
				_path = ftpPath;
				cmdSocket.writeUTFBytes('PASV \n');
				cmdSocket.flush();
			} else {
				addError("Can't get directory list with closed or busy connection");
			}
		}
		
		public function dirListMsgTask(ftpPath:String):void {
			_taskList.push({task: 'dirList', ftpPath: ftpPath});
		}
		
		public function open(host:String = null, username:String = null, password:String = null, port:int = 21):void {
			close();
			_host = host;
			_username = username;
			_password = password;
			_port = port;
			_message.length = 0;
			if (host && username && password) {
				_busy = true;
				cmdSocket.connect(host, port);
			} else {
				addError("Not enough data to open FTP [host, username, password]");
			}
		}
		
		public function close():void {
			uploadAndCloseTimer.stop();
			closeStreamTimer.stop();
			busyTimeout.stop();
			if (cmdSocket.connected) {
				cmdSocket.close();
			}
			fileStream.close();
			if (dataSocket.connected) {
				dataSocket.close();
			}
			busyChecker = false;
			_busy = false;
		}
		
		public function closeStream():void {
			fileStream.close();
		}
		
		public function closeTask():void {
			_taskList.push({task: 'close'});
		}
		
		public function closeData(closeDataTasks:Boolean = true):void {
			uploadAndCloseTimer.stop();
			closeStreamTimer.stop();
			fileStream.close();
			if (dataSocket.connected) {
				dataSocket.close();
			}
			if (closeDataTasks) {
				for (var i:int = 0; i < _taskList.length; i += 1) {
					if (_taskList[i].task == 'upload' || _taskList[i].task == 'download' || _taskList[i].task == 'dirList') {
						_taskList.splice(i, 1);
						if (i > 0) {
							i -= 1;
						}
					}
				}
			}
			_busy = false;
		}
		
		//--------------MANAGE
		
		private function busyCheck(e:TimerEvent):void {
			if (_busy && busyChecker && dataSocket.connected == false) {
				_busy = false;
				var code:String = dataSocket.readUTFBytes(dataSocket.bytesAvailable);
				_listener({target: this, code: null, type: 'busyCheckDrop', task: _task, msg: code});
			}
			busyChecker = _busy;
			if (!cmdSocket.connected) {
				close();
			}
		}
		
		private function _listener(obj:Object):void {
			trace('BUSY: ' + _busy);
			if (!_busy && _taskList.length > 0) {
				var o:Object = _taskList.shift();
				if (o.task == 'upload') {
					upload(o.localPath, o.ftpPath);
				} else if (o.task == 'download') {
					download(o.localPath, o.ftpPath);
				} else if (o.task == 'dirList') {
					dirListMsg(o.ftpPath);
				} else if (o.task == 'close') {
					_taskList.length = 0;
					close();
				}
			}
			if (listener is Function) {
				listener(obj);
			}
		}
		
		private function addMsg(s:String):void {
			trace('MESSAGE: ' + s);
			if (s.indexOf('\n') > -1) {
				_message.unshift(s);
			} else {
				_message.unshift(s + '\n');
			}
		}
		
		private function addError(s:String):void {
			trace('ERROR: ' + s);
			if (s.indexOf('\n') > -1) {
				_error.unshift(s);
			} else {
				_error.unshift(s + '\n');
			}
		}
		
		public function clearMessage():void {
			_message.length = 0;
		}
		
		public function get message():String {
			return _message.join('');
		}
		
		public function get messageVec():Vector.<String> {
			var v:Vector.<String> = _message.concat();
			return v;
		}
		
		public function clearError():void {
			_error.length = 0;
		}
		
		public function get error():String {
			return _error.join('');
		}
		
		public function get errorVec():Vector.<String> {
			var v:Vector.<String> = _error.concat();
			return v;
		}
		
		public function get taskList():Vector.<Object> {
			return _taskList;
		}
		
		public function get fileData():ByteArray {
			return byteArray;
		}
		
		public function get connected():Boolean {
			return cmdSocket.connected;
		}
		
		public function get connectedData():Boolean {
			return dataSocket.connected;
		}
		
		public function get busy():Boolean {
			return _busy;
		}
		
		public function get host():String {
			return _host;
		}
		
		public function get username():String {
			return _username;
		}
		
		public function get password():String {
			return _password;
		}
		
		public function get port():int {
			return _port;
		}
		
		public function get path():String {
			return _path;
		}
		
		public function get task():String {
			return _task;
		}
	}
}