package core 
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	//import com.adobe.serialization.json.JSON;

	public class Post 
	{
		private static const BUSY:uint = 1;
		private static const FREE:uint = 0;
		
		private static var queue:Vector.<Object> = new Vector.<Object>();
		private static var sends:Vector.<Object> = new Vector.<Object>();
		
		private static var status:uint = Post.FREE;
		
		private static var loader:URLLoader;
		
		public function Post() 
		{
			
		}
		
		public static function send(action:Object, callback:Function, params:Object = null):void {
			queue.push( { action:action, callback:callback, params:params } );
			
			if (status == FREE) {
				request();
			}
		}
		
		private static function request():void{
			status = BUSY;
			
			var item:Object = queue[0];
			
			var result:String = '';
			for each(var action:Object in item.action) {
				result += action + '';
			}
			
			var pid:Number = new Date().time;
			
			var crc:String = MD5.encrypt('ytf$%$yuGFis*&udh' + result + pid + '');
			var data:String = JSON.stringify(item.action);
			
			trace("POST: "+data);
			
			var requestVars:URLVariables = new URLVariables();
			requestVars.data = data;
			requestVars.crc = crc;
			requestVars.pid = pid;
			
			var req:URLRequest = new URLRequest(Config.getUrl());
			req.method = URLRequestMethod.POST;
			req.data = requestVars;
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			loader.load(req);
		}
		
		private static function onComplete(e:Event):void {
			
			loader.removeEventListener(Event.COMPLETE, onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			
			var item:Object = queue.shift();
			
			trace(e.currentTarget.data);
			
			var response:Object = JSON.parse(e.currentTarget.data);
			
			//Обновляем серверное время и удаляем ненужную переменную
			if (response.data.hasOwnProperty('__time')) {
				App.time = response.data['__time'];
				delete response.data['__time'];
			}
			
			item.callback(response.error, response.data, item.params);
			
			status = FREE;
			if (queue.length > 0) {
				request();
			}
		}
		
		
		private static function OnIOError(event:IOErrorEvent):void {
			loader.removeEventListener(Event.COMPLETE, onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			
			//Ничего не грузиться меняем сервер, отправляем пост повторно
			//TODO как-то обрабатываем ошибку
		}
		
	}

}