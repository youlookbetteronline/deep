package 
{
	import com.adobe.crypto.MD5;
	import enixan.Compiler;
	import enixan.Size;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import mx.controls.Alert;
	
	public class ServerManager extends EventDispatcher 
	{
		
		public static const UPLOAD:String = 'UPLOAD';
		public static const DOWNLOAD:String = 'DOWNLOAD';
		public static const READDIR:String = 'READDIR';
		
		public static const separator:String = '/';
		
		private var script:String = 'https://dreams.islandsville.com/flmngr.php';
		
		public var browser:ServerBrowser;
		
		public function ServerManager() {
			super();
			
			browser = new ServerBrowser();
			
			
		}
		
		/**
		 * 
		 * @param	action
		 * @param	params
		 * @param	complete
		 * @param	error
		 * @param	progress
		 */
		public function send(action:String, params:Object, complete:Function = null, error:Function = null, progress:Function = null):void {
			switch(action) {
				case READDIR:
				case DOWNLOAD:
				case UPLOAD:
					break;
				default:
					Alert.show('Такого действия не существует', Main.appName);
					return;
			}
			
			var input_bytes:ByteArray;
			var object:Object = {
				act:	action
			}
			
			if (params) {
				for (var s:* in params) {
					if (params[s] is ByteArray) {
						input_bytes = params[s];
					}else{
						object[s] = params[s];
					}
				}
			}
			
			var json:String = JSON.stringify(object);
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(Size.zero(json.length, 4) + json);
			if (input_bytes && input_bytes.length > 0)
				bytes.writeBytes(input_bytes);
			
			trace('SEND', json);
			
			var req:URLRequest = new URLRequest();
			req.url = script;
			req.contentType = 'application/octet-stream';
			req.method = URLRequestMethod.POST;
			req.data = bytes;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = (action == DOWNLOAD) ? URLLoaderDataFormat.BINARY : URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			loader.load(req);
			
			function onComplete(e:Event):void {
				//trace(loader.data);
				
				if (loader.data)
					handleAnswer(object, loader.data);
				
				if (complete != null)
					complete();
				
				dispose();
			}
			function onError(e:IOErrorEvent):void {
				Alert.show(e.toString(), Main.appName);
				
				if (error != null)
					error();
				
				dispose();
			}
			function onProgress(e:ProgressEvent):void {
				if (progress != null)
					progress(loader.bytesLoaded / loader.bytesTotal);
				
				//trace(loader.bytesLoaded / loader.bytesTotal);
			}
			function onHttpStatus(e:HTTPStatusEvent):void { }
			function dispose():void {
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
				loader = null;
			}
		}
		
		
		/**
		 * 
		 */
		private function getName(path:String):String {
			var index:int = path.lastIndexOf(path);
			if (index >= 0)
				return path.substring(index + 1, path.length);
			
			return path;
		}
		
		
		/**
		 * 
		 */
		public function handleAnswer(object:Object, data:*):void {
			
			switch(object.act) {
				case UPLOAD:
					if (!(data is String)) return;
					if (data.indexOf('FAIL') >= 0)
						Alert.show('На сервер ничего не загружено:\n' + data, Main.appName);
					
					break;
				case DOWNLOAD:
					if (!(data is ByteArray)) return;
					readByteArrayData(data, getName(object.path));
					break;
				case READDIR:
					if (!(data is String)) return;
					if (data == 'NO_DIR') return;
					browser.updateFiles(object.path, data.split('\n'), true);
					break;
			}
		}
		private function readByteArrayData(bytes:ByteArray, name:String = null):void {
			
			if (name && name.indexOf(Main.SWF) > 0) {
				var file:File = File.cacheDirectory.resolvePath('temp' + Main.SWF);
				
				Files.save(file, bytes);
				Main.app.loadUrl(file.nativePath);
				
				return;
			}
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, comlete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, error);
			
			var lc:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			lc.allowLoadBytesCodeExecution = true;
			loader.loadBytes(bytes, lc);
			
			function comlete(e:Event):void {
				var data:Object = loader.contentLoaderInfo.content;
				if (data is Bitmap)
					Main.app.stageAdd(new StageInfo(null, Main.app.nextName('Stage'), 0, 0, data.bitmapData));
				
				dispose();
			}
			function error(e:IOErrorEvent = null):void {
				dispose();
			}
			function dispose():void {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, comlete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, error);
				loader = null;
			}
		}
		
		
		/**
		 * Меняет директорию
		 */
		public function changeFolder(path:String, complete:Function = null, updateAnyway:Boolean = false):void {
			
			folderList(path, function(serverBrowserItem:ServerBrowserItem):void {
				ServerManager.path = path;
				if (complete != null)
					complete(serverBrowserItem);
			}, updateAnyway);
		}
		
		
		/**
		 * Возвращает список директорий
		 */
		private var folderListRequests:Dictionary;
		public function folderList(path:String, complete:Function = null, updateAnyway:Boolean = false):void {
			
			path = path.replace(/\/$/, '');
			if (path.length == 0) path = ServerManager.separator;
			
			if (!folderListRequests)
				folderListRequests = new Dictionary();
			
			if (!browser.checkDirectory(path) || updateAnyway) {
				if (!folderListRequests.hasOwnProperty(path)) {
					folderListRequests[path] = complete;
				}else {
					return;
				}
				
				send(READDIR, { path:path }, function():void {
					folderList(path, complete);
				});
				return;
			}
			
			delete folderListRequests[path];
			
			if (complete != null)
				complete(browser.returnFiles(path));
			
		}
		
		
		
		/*public function currentFolder():ServerBrowserItem {
			return browser.returnFiles(path);
		}*/
		
		
		
		/**
		 * Путь
		 */
		public static function get path():String {
			return Main.app.server.browser.currentDirectory;
		}
		public static function set path(value:String):void {
			Main.app.server.browser.currentDirectory = value;
			
			if (!Main.storage.server) Main.storage.server = { };
			Main.storage.server.path = value;
			Main.app.saveStorage(5000);
		}
		
		// Icon path
		public static function get iconPath():String {
			if (Main.storage.server && Main.storage.server.iconPath)
				return Main.storage.server.iconPath;
			
			return null;
		}
		public static function set iconPath(value:String):void {
			if (!Main.storage.server) Main.storage.server = { };
			Main.storage.server.iconPath = value;
			Main.app.saveStorage(5000);
		}
		
		// SWF path
		public static function get swfPath():String {
			if (Main.storage.server && Main.storage.server.swfPath)
				return Main.storage.server.swfPath;
			
			return null;
		}
		public static function set swfPath(value:String):void {
			if (!Main.storage.server) Main.storage.server = { };
			Main.storage.server.swfPath = value;
			Main.app.saveStorage(5000);
		}
		
		
		
		/**
		 * 
		 * @param	list
		 * @param	complete
		 * @param	error
		 */
		public function upload(list:Array, complete:Function = null, error:Function = null):void {
			var data:Object = list.shift();
			
			send(UPLOAD, {
				path:		data.path,
				bytes:		data.bytes
			}, function():void {
				if (list.length) {
					upload(list, complete, error);
				}else if (complete != null) {
					complete();
				}
			}, error);
		}
	}

}

import flash.utils.Dictionary;

internal class ServerBrowser {
	
	public var currentDirectory:String = '/home/dreams/public_html';
	
	public var tree:ServerBrowserItem;
	
	public function ServerBrowser() {
		tree = new ServerBrowserItem('/');
	}
	
	/**
	 * Обновляет список файлов в директории
	 * @param	path	Путь типа /main/submain/destination
	 * @param	list	Список названий файлов в массиве
	 * @return
	 */
	public function updateFiles(path:String, list:Array = null, updated:Boolean = false):ServerBrowserItem {
		if (path.charAt(0) != ServerManager.separator)
			return null;
		
		var pathlist:Array = path.split(ServerManager.separator);
		var currpath:String = '';
		var branch:ServerBrowserItem;
		
		for (var i:int = pathlist.length - 1; i > -1; i--) {
			if (!pathlist[i] || pathlist[i].length == 0)
				pathlist.splice(i, 1);
		}
		
		if (pathlist.length > 0) {
			currentDirectory = path;
			branch = tree;
			for (i = 0; i < pathlist.length; i++) {
				currpath += ServerManager.separator + pathlist[i];
				
				if (!branch.content.hasOwnProperty(pathlist[i])) {
					branch.content[pathlist[i]] = new ServerBrowserItem(pathlist[i], currpath);
				}
				
				branch = branch.content[pathlist[i]];
			}
			
			if (updated && branch)
				branch.updated = true;
			
			var temp:Array;
			for (i = 0; list && i < list.length; i++) {
				temp = list[i].split('\t');
				if (temp.length < 2 || temp[0] == '') continue;
				branch.content[temp[0]] = new ServerBrowserItem(temp[0], currpath, (temp[1] == "1") ? true : false, temp[2], temp[3]);
			}
		}
		
		return branch;
	}
	
	/**
	 * Обновляет список файлов в директории
	 * @param	path	Путь типа /main/submain/destination
	 * @param	lastAvailable	Вернуть последний доступный
	 * @return
	 */
	public function returnFiles(path:String, lastAvailable:Boolean = false):ServerBrowserItem {
		if (path.charAt(0) != ServerManager.separator)
			return null;
		
		var pathlist:Array = path.split(ServerManager.separator);
		var branch:ServerBrowserItem;
		var previewBranch:ServerBrowserItem;
		
		// Очистка пустых папок
		for (var i:int = pathlist.length - 1; i > -1; i--) {
			if (!pathlist[i] || pathlist[i].length == 0)
				pathlist.splice(i, 1);
		}
		
		if (pathlist.length > 0) {
			currentDirectory = path;
			branch = tree;
			
			for (i = 0; i < pathlist.length; i++) {
				if (!branch.content.hasOwnProperty(pathlist[i])) {
					if (lastAvailable && previewBranch)
						return previewBranch;
					
					return null;
				}
				
				previewBranch = branch;
				branch = branch.content[pathlist[i]];
			}
		}
		
		previewBranch = null;
		pathlist = null;
		
		return branch;
	}
	
	public function checkDirectory(path:String = null):Boolean {
		
		if (!path || path.length == 0)
			return false;
		
		var pathlist:Array = path.split(ServerManager.separator);
		var branch:ServerBrowserItem;
		
		if (pathlist.length > 0) {
			branch = tree;
			for (var i:int = 1; i < pathlist.length; i++) {
				if (branch.content.hasOwnProperty(pathlist[i]) && branch.content[pathlist[i]] is ServerBrowserItem &&
					(i < pathlist.length - 1 || branch.content[pathlist[i]].dir == false || branch.content[pathlist[i]].updated)) {
					
					branch = branch.content[pathlist[i]];
					
				}else {
					return false;
				}
			}
		}
		
		return true;
	}
}

internal class ServerBrowserItem {
	
	public var name:String;
	public var updated:Boolean;
	public var content:Dictionary;
	public var dir:Boolean;
	public var time:int;
	public var size:int;
	public var path:String;
	
	public function ServerBrowserItem(name:String, path:String = null, dir:Boolean = true, time:int = 0, size:int = 0, updated:Boolean = false, content:Dictionary = null) {
		
		this.name = name;
		this.updated = updated;
		this.content = content || new Dictionary();
		this.dir = dir;
		this.time = time;
		this.size = size;
		this.path = path;
		
	}
	
}