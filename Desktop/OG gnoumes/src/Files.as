package  
{
	
	import com.adobe.crypto.MD5;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FileListEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class Files extends EventDispatcher 
	{
		
		public static var lastPath:String = '';
		
		public static function pathFormat(path:String, name:String):File {
			return new File(path + File.separator + name);
		}
		
		public static function openText(file:File, createIfNotExists:Boolean = false):String {
			var output:String = '';
			var fs:FileStream = new FileStream();
			
			if (file.exists) {
				fs.open(file, FileMode.READ);
				output = fs.readUTFBytes(fs.bytesAvailable);
				fs.close();
			}else if (createIfNotExists) {
				fs.open(file, FileMode.WRITE);
				fs.close();
			}
			
			return output;
		}
		public static function open(file:File):ByteArray {
			var output:ByteArray = new ByteArray();
			var fs:FileStream = new FileStream();
			
			if (file.exists) {
				fs.open(file, FileMode.READ);
				fs.readBytes(output);
				fs.close();
				
				fs = null;
				output.position = 0;
			}
			
			
			return output;
		}
		
		/**
		 * 
		 * @param	file	file with filepath
		 * @param	data	bytearray data
		 * @param	rewrite	toggle of rewrite file
		 */
		public static function save(file:File, data:ByteArray, rewrite:Boolean = true):void {
			var fs:FileStream = new FileStream();
			fs.open(file, (rewrite) ? FileMode.WRITE : FileMode.APPEND);
			fs.writeBytes(data, 0, data.length);
			fs.close();
		}
		
		public static function saveText(file:File, data:String = '', rewrite:Boolean = true):void {
			var fs:FileStream = new FileStream();
			fs.open(file, (rewrite) ? FileMode.WRITE : FileMode.APPEND);
			fs.writeUTFBytes(data);
			fs.close();
		}
		
		
		
		
		
		/**
		 * Read folder async
		 */
		public static function readFolderAsync(folder:File, onComplete:Function, onError:Function = null):void {
			
			if (!folder || !folder.exists || !folder.isDirectory){
				onError();
				return;
			}
			
			//var listen:Boolean = folder.hasEventListener(FileListEvent.DIRECTORY_LISTING);
			//if (listen)
				//dispose();
			
			folder.addEventListener(FileListEvent.DIRECTORY_LISTING, complete);
			folder.addEventListener(IOErrorEvent.IO_ERROR, error);
			folder.getDirectoryListingAsync();
			
			function complete(e:FileListEvent):void {
				dispose();
				if (onComplete != null) onComplete(e.files);
			}
			function error(e:IOErrorEvent):void {
				dispose();
				if (onError != null) onError();
			}
			function dispose():void {
				folder.removeEventListener(FileListEvent.DIRECTORY_LISTING, complete);
				folder.removeEventListener(IOErrorEvent.IO_ERROR, error);
				folder = null;
			}
		}
		
		
		
		
		/**
		 * Проверка пути
		 * @param	path	Путь
		 * @param	down	Игнорирование нижних папок
		 * @return
		 */
		public static function validPath(path:String, downcount:int = 0):Boolean {
			var find:Boolean;
			var separator:String;
			
			if (path.indexOf('\\') > -1) separator = '\\';
			if (!separator && path.indexOf('/') > -1) separator = '/';
			if (separator) {
				path = path.replace((separator == '/') ? /\/$/ : /\\$/, '');
				
				var array:Array = path.split(separator);
				if (array.length > downcount) {
					while (--downcount >= 0)
						array.pop();
					
					path = array.join(separator);
					
					var file:File = new File(path);
					if (file.exists) find = true;
					file = null;
				}
				
				array = null;
			}
			
			return find;
		}
		
		
		
		
		
		/**
		 * Помогает выбрать 
		 * @param	onSelect
		 * @param	basicPath
		 * @param	onCancel
		 * @param	title
		 */
		public static function openDirectory(onSelect:Function, basicPath:String = null, onCancel:Function = null, title:String = "Укажите директорию"):void {
			var file:File = new File(basicPath || File.desktopDirectory.nativePath);
			
			try {
				file.browseForDirectory(title);
				file.addEventListener(Event.SELECT, onSelectEvent);
				file.addEventListener(Event.CANCEL, onCancelEvent);
			}catch (error:*) {
				onCancelEvent();
			}
			
			function onSelectEvent(event:Event):void {
				onSelect(event.target as File);
			}
			function onCancelEvent(e:Event = null):void {
				if (onCancel != null)
					onCancel();
			}
		}
		
		
		
		
		private static var downloadList:Object;
		private static var interval:int = 0;
		private static function addTimeout():void {
			if (interval > 0) return;
			interval = setInterval(onTimeout, 100);
		}
		private static function onTimeout():void {
			var count:int = 0;
			
			for (var s:String in downloadList) {
				count++;
				if (downloadList[s].progress != null) {
					//downloadList[s].progress(downloadList[s].bytesLoaded / downloadList[s].bytesTotal);
					
					if (++downloadList[s].speedClock > 10) {
						downloadList[s].speed = downloadList[s].speedInc;
						downloadList[s].speedInc = 0;
					}
					
					var list:Array = [downloadList[s].bytesLoaded / downloadList[s].bytesTotal];
					if (downloadList[s].isSpeed) list.push(downloadList[s].speed);
					
					downloadList[s].progress.apply(null, list);
					
				}
			}
			
			if (count == 0) clearInterval(interval);
		}
		
		public static var downloadBuffer:uint = 1048576; //8388608
		
		public static function downloadFile(url:String, destinationFile:File, params:Object):void {
			
			var currID:String = MD5.hash(url);
			var bytes:ByteArray = new ByteArray();
			var currUrl:String = url;
			var stream:URLStream = new URLStream();
			var fstream:FileStream = new FileStream();
			var complete:Function = params.complete || null;
			var progress:Function = params.progress || null;
			var error:Function = params.error || null;
			var urlRequest:URLRequest = new URLRequest(url);
			urlRequest.requestHeaders = [new URLRequestHeader('Range', 'bytes=64-')];
			
			fstream.open(destinationFile, FileMode.WRITE);
			
			stream.addEventListener(Event.OPEN, onOpen);
			stream.addEventListener(ProgressEvent.PROGRESS, onProgress);
			stream.addEventListener(Event.COMPLETE, onComplete);
			stream.addEventListener(IOErrorEvent.IO_ERROR, onError);
			stream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponse);
			stream.load(new URLRequest(url));
			
			if (!downloadList) downloadList = { };
			if (!params.hasOwnProperty('added')) {
				downloadList[currID] = {
					url:			url,
					file:			destinationFile,
					complete:		complete,
					progress:		progress,
					bytesLoaded:	0,
					bytesTotal:		0,
					isSpeed:		params.isSpeed,
					speed:			0,		// Скорость
					speedInc:		0,		// Инкремент скорости
					speedClock:		0,		// Cчетчик скорости
					cancel:			false,
					waitConnection:	false,
					fragmentable:	false
				};
			}
			
			function onOpen(e:Event):void {
				addTimeout();
			}
			function onProgress(e:ProgressEvent):void {
				//trace(fstream.position, stream.bytesAvailable);
				if (downloadList[currID].cancel == true) {
					stream.close();
					disposeDownload();
				}
				
				downloadList[currID].bytesLoaded = e.bytesLoaded;
				downloadList[currID].bytesTotal = e.bytesTotal;
				downloadList[currID].speedInc += stream.bytesAvailable;
				
				//if (progress != null)
					//progress(e.bytesLoaded / e.bytesTotal);
				
				stream.readBytes(bytes, bytes.length, stream.bytesAvailable);
				
				if (bytes.length >= downloadBuffer)
					writeBytes();
			}
			function onComplete(e:Event):void {
				writeBytes();
				disposeDownload();
				
				/*if (!stream.connected) {
					if (error != null) error(downloadList[currID]);
				}else {
					if (complete != null) complete(downloadList[currID]);
				}*/
				
				if (complete != null) complete(downloadList[currID]);
			}
			function onError(e:IOErrorEvent):void {
				trace(e.toString());
				disposeDownload();
			}
			function onResponse(e:HTTPStatusEvent):void {
				var headers:Array = e.responseHeaders;
				for (var i:int = 0; i < headers.length; i++) {
					trace(headers[i].name + ': ' + headers[i].value);
					if (headers[i].name == 'Accept-Ranges') {
						downloadList[currID].fragmentable = true;
					}
				}
				
				if (e.status == 206)
					trace('Fragment');
			}
			function writeBytes():void {
				trace(downloadList[currID].bytesLoaded);
				fstream.writeBytes(bytes, 0, bytes.length);
				bytes.length = 0;
			}
			
			function disposeDownload():void {
				stream.removeEventListener(Event.OPEN, onOpen);
				stream.removeEventListener(Event.COMPLETE, onComplete);
				stream.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				stream.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				stream.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponse);
				
				stream.close();
				fstream.close();
				
				if (downloadList.hasOwnProperty(currID))
					delete downloadList[currID];
			}
			
		}
		
	}

}