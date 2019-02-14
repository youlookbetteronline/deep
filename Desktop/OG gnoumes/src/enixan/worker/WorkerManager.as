package enixan.worker 
{
	import com.adobe.crypto.MD5;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.system.MessageChannel;
	import flash.system.System;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.getTimer;
	
	[Event('type=core.WorkerEvent')]
	
	public class WorkerManager extends EventDispatcher 
	{
		
		public static var queued:Boolean = true;		// Поочередно отправлять данные
		
		public static var workerManager:WorkerManager;
		public static function getInstance():WorkerManager {
			if (!workerManager) {
				workerManager = new WorkerManager();
			}
			
			return workerManager;
		}
		
		
		[Embed(source="../../../worker/bin/worker.swf", mimeType="application/octet-stream")]
		private var WorkerClass:Class;
		
		public var mainChannel:MessageChannel;
		public var workerChannel:MessageChannel;
		public var worker:Worker;
		
		private var started:Boolean;
		
		private static var waitList:Object;
		
		public function WorkerManager() {
			
			super();
			
			waitList = { };
			
			init();
		}
		
		protected function init():void {
			if (!Worker.current.isPrimordial) return;
			
			worker = WorkerDomain.current.createWorker(new WorkerClass());
			workerChannel = Worker.current.createMessageChannel(worker);
			mainChannel = worker.createMessageChannel(Worker.current);
			
			worker.setSharedProperty('toWorker', workerChannel);
			worker.setSharedProperty('toMain', mainChannel);
			
			mainChannel.addEventListener(Event.CHANNEL_MESSAGE, onChannelMessage);
			worker.addEventListener(Event.WORKER_STATE, function(e:*):void {
				trace(e.toString());
			});
			
			worker.start();
		}
		
		
		/**
		 * Перезапуск
		 */
		public function restart():void {
			if (!worker || worker.state != WorkerState.RUNNING) return;
			
			mainChannel.removeEventListener(Event.CHANNEL_MESSAGE, onChannelMessage);
			mainChannel.close();
			workerChannel.close();
			
			worker.terminate();
			worker = null;
			
			worker = WorkerDomain.current.createWorker(new WorkerClass());
			
			workerChannel = Worker.current.createMessageChannel(worker);
			mainChannel = worker.createMessageChannel(Worker.current);
			mainChannel.addEventListener(Event.CHANNEL_MESSAGE, onChannelMessage);
			
			worker.setSharedProperty('toWorker', workerChannel);
			worker.setSharedProperty('toMain', mainChannel);
			worker.start();
		}
		
		private function onChannelMessage(e:Event):void {
			
			trace('[Main] Worker recieve data.', System.totalMemory);
			
			// Если возможно обработать запрос по ключу
			var object:Object = mainChannel.receive();
			
			if (!object) return;
			
			if (waitList.hasOwnProperty(object.key)) {
				if (waitList[object.key]['callback'] != null) {
					var callback:Function = waitList[object.key].callback;
					callback(object.data);
				}
				
				waitList[object.key] = null;
				delete waitList[object.key];
			}
			
			if (queued) {
				sended = false;
				restart();
				send();
			}
			
		}
		
		
		/**
		 * Перезапуск и продолжение работы
		 */
		public static var restartTimeout:uint = 0;
		public static function restartAndWork():void {
			
			var count:int = 0;
			for each (var object:Object in waitList) {
				if (object.sended) continue;
				count ++;
			}
			
			if (count > 0) return;
			
			var workerManager:WorkerManager = WorkerManager.getInstance();
			if (workerManager) {
				workerManager.restart();
			}
			
			restartTimeout = getTimer() + 10000;
			send();
		}
		
		
		
		
		private static var sended:Boolean;
		public static function work(event:String, data:* = null, callback:Function = null):void {
			if (!WorkerManager.workerManager)
				WorkerManager.getInstance();
			
			
			var key:String = MD5.hash(Math.random().toString());
			
			var object:Object = {
				event:event,
				key:key,
				data:data,
				callback:callback
			};
			
			waitList[key] = object;
			
			send();
		}
		private static function send():void {
			
			/*if (System.totalMemory > 1000000000 && getTimer() > restartTimeout) {
				restartAndWork();
				return;
			}*/
			
			for each(var object:Object in waitList) {
				if (sended || !object || object.sended) continue;
				
				trace('[Main] Send work.');
				
				sended = true;
				object.sended = true;
				WorkerManager.workerManager.workerChannel.send(object);
				object.data = null;
			}
		}
		
		
		
	}

}