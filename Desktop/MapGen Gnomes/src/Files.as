package  
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
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
		
		/**
		 * 
		 * @param	file	file with filepath
		 * @param	data	bytearray data
		 * @param	rewrite	toggle of rewrite file
		 */
		public static function save(file:File, data:ByteArray, rewrite:Boolean = true):void {
			var fs:FileStream = new FileStream();
			fs.open(file, (rewrite) ? FileMode.APPEND : FileMode.WRITE);
			fs.writeBytes(data, 0, data.length);
			fs.close();
		}
		
		public static function saveText(file:File, data:String = '', rewrite:Boolean = true):void {
			var fs:FileStream = new FileStream();
			fs.open(file, (rewrite) ? FileMode.APPEND : FileMode.WRITE);
			fs.writeUTFBytes(data);
			fs.close();
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
				if (downloadList[s].progress != null)
					downloadList[s].progress(downloadList[s]);
			}
			
			if (count == 0) clearInterval(interval);
		}
		
		public static var downloadBuffer:int = 1048576; //8388608
		
		public static function downloadFile(url:String, destinationFile:File, params:Object):void {
			
			var currID:String = MD5.encrypt(url);
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