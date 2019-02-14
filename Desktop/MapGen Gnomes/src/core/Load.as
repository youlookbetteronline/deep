package core 
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import flash.events.IOErrorEvent;
	import flash.system.LoaderContext
	import flash.events.Event;
	import flash.display.Loader;
	import flash.display.LoaderInfo

	public class Load 
	{
		
		private static const QUEUESIZE:int = 5;
		private static const WAIT:int = 1;
		private static const LOADING:int = 2;
		private static const LOADED:int = 3;
		
		private static var cache:Dictionary = new Dictionary();
		private static var waitingQueue:Array = new Array();
		private static var loadingQueue:Array = new Array();
		
		public function Load() 
		{
			
		}
		
		public static function loading(url:String, callback:Function):void {
			var hash:String = MD5.encrypt(url);
			if (cache[hash] != undefined && cache[hash].status == LOADED) {
				callback(cache[hash].data);
				return; //TODO может возвращать прелоадер
			}else if(cache[hash] != undefined && cache[hash].status == WAIT){
				cache[hash]['callbacks'].push(callback);
				return; //TODO может возвращать прелоадер
			}else{
				cache[hash] = { data:null, status:WAIT, callbacks:[callback] };
			}
			
			waitingQueue.push( { url:url, status:WAIT } );
			
			loadNextInQueue();
		}
		
		private static function loadNextInQueue():void {
			if (waitingQueue.length == 0) {
				return;
			}
			
			while(waitingQueue.length > 0 && loadingQueue.length < QUEUESIZE){
				var nextToLoad:Object = waitingQueue.shift();
				loadingQueue.push(nextToLoad);
			}
			process();
		}
		
		private static function process():void {
			
			if (loadingQueue.length == 0) {
				loadNextInQueue();
				return;
			}
			

			for each(var target:Object in loadingQueue){
				
				if (target.status == LOADING)
					continue;
				
				target.status = LOADING;
				trace("LOADING: " + target.url);
				
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
				
				function onComplete(e:Event):void {
					
					var data:* = e.target.content
					var hash:String = MD5.encrypt(target.url);
					var item:Object = cache[hash];
					item.data = data;
					item.status = LOADED;
					if (item.callbacks.length > 0) {
						for each(var callback:Function in item.callbacks) {
							callback(data);
						}
						item.callbacks = [];
					}
					
					var index:int = loadingQueue.indexOf(target);
					if(index != -1){
						loadingQueue.splice(index, 1);
					}
					
					loadNextInQueue();
					
				});
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);

				loader.load(new URLRequest(target.url));
			}
		}
		
		private static function onError(e:IOErrorEvent):void {
			trace('Error happend');
		}
		
		
		public static function loadText(url:String, callback:Function):void {
			var loader:URLLoader = new URLLoader();
			trace("LOADING: " + url);
			loader.addEventListener(Event.COMPLETE, function onTextComplete(e:Event):void {
				var data:* = e.target;
				callback(data);
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function onTextError(e:IOErrorEvent):void {
				trace('Error load text');
			});
			loader.load(new URLRequest(url));
		}
		
	}

}