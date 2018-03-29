package core 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import com.junkbyte.console.Cc;
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	import models.BankerModel;
	import wins.AchivementsWindow;
	import wins.SimpleWindow;
	import wins.WindowEvent;
	//import com.adobe.serialization.json.JSON;

	public class Post extends EventDispatcher
	{
		private static const BUSY:uint = 1;
		private static const FREE:uint = 0;
		
		private static var queue:Vector.<Object> = new Vector.<Object>();
		private static var sends:Vector.<Object> = new Vector.<Object>();
		
		private static var status:uint = Post.FREE;
		
		private static var loader:URLLoader;
		public static var archive:Array = [];
		public static var time1:uint = 0;
		public static var time2:uint = 0;
		
		// Синgелтон.
		private static var _instance:Post;
		public static function get instance():Post
		{
			if (_instance == null)
			{
				_instance = new Post();
			}
			return _instance;
		}
		
		public function Post() 
		{
			
		}
		public static const STATISTIC_INVITE:String = 'invite';
		public static const STATISTIC_WALLPOST:String = 'wallpost';
		
		public static var EVENT_POST_START:String 	= "eventPostStart";
		public static var EVENT_POST_END:String 	= "eventPostEnd";
		
		public static function send(action:Object, callback:Function, params:Object = null):void 
		{
			if (Capabilities.playerType == 'StandAlone')
			{
				action['social'] = App.social;
			}
			action['ref'] = App.ref || "";
			queue.push( { action:action, callback:callback, params:params } );
			
			if (App.ui && App.ui.bottomPanel)
				App.ui.bottomPanel.addPostPreloader();
			
			if (status == FREE) 
			{
				request();
			}
			
			
		}
		
		/**
		 * Сообщаем всем, кто нас слушает - что клиент отправил запрос на сервер.
		 */
		public function dispatchPostStart():void
		{
			dispatchEvent(new Event(Post.EVENT_POST_START));
		}
		
		/**
		 * Сообщаем всем, кто нас слушает - что клиент получил ответ от сервера.
		 */
		public function dispatchPostEnd():void
		{
			dispatchEvent(new Event(Post.EVENT_POST_END));
		}
		
		private static function request():void 
		{
			
			/*if (App.user && App.user.quests && App.user.quests.tutorial)
				App.user.quests.lockFuckAll();*/
			
			status = BUSY;
			
			var item:Object = queue[0];
			
			var result:String = '';

			if (App.user && App.user.pay > 0) item.action['p'] = 1;
			for each(var action:* in item.action) 
			{
				result += action + '';
			}
			
			var pid:Number = new Date().time;
			var crc:String = MD5.encrypt('ytf$%$yuGFis*&udh' + result + pid + '');
			var data:String = JSON.stringify(item.action);
			
			time1 = getTimer();
			trace("POST: " + data);
			addToArchive('\n'+data+'  '+time1);
					
			
			var requestVars:URLVariables = new URLVariables();
			requestVars.data = data;
			requestVars.crc = crc;
			requestVars.pid = pid;
			if (Post.h) 
				requestVars.h = Post.h;
			
			var req:URLRequest = new URLRequest(Config.getUrl());
			req.method = URLRequestMethod.POST;
			req.data = requestVars;
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, OnHttpStatus);
			loader.load(req);
			
			Post.instance.dispatchPostStart();
		}
		
		public static var h:String = '';
		public static var _stock:Object = {};
		private static function onComplete(e:Event):void 
		{
			Post.instance.dispatchPostEnd();
			trace()
			/*if (App.user && App.user.quests && App.user.quests.tutorial)
				App.user.quests.unlockFuckAll();
			*/	
			URLLoader(e.target).removeEventListener(Event.COMPLETE, onComplete);
			URLLoader(e.target).removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			URLLoader(e.target).removeEventListener(HTTPStatusEvent.HTTP_STATUS, OnHttpStatus);
			
			var item:Object = queue.shift();
			var string:String = e.currentTarget.data;
			time2 = getTimer();
			
			trace(e.currentTarget.data);
			addToArchive(e.currentTarget.data.replace(/\n/, '') + ' d:'+(time2 - time1)+'  '+time2);
			//Cc.log(String((time2 - time1) / 1000) + 'sec  ' + string);
			
			try
			{
				var response:Object = JSON.parse(e.currentTarget.data);
			}catch (e:Error) 
			{
				status = FREE;
				return;
			}
			
			//Обновляем серверное время и удаляем ненужную переменную
			var progress:*;
			var dayliProgress:*;
			if (response.data != null) 
			{
				if (response.data.hasOwnProperty('__loyalty'))
					BankerModel.loyalty = response.data.__loyalty;
				else if (response.data && response.data.hasOwnProperty('user') && response.data.user.hasOwnProperty('loyalty'))
					BankerModel.loyalty = response.data.user.loyalty;	
				
				if (response.data.hasOwnProperty('topParams'))
					App.self.dispatchEvent(new TopEvent(TopEvent.ON_FINISH_TRY, false, false, response.data.topParams));
					
				if (response.data.hasOwnProperty('h')) 
				{
					Post.h = response.data.h;
					delete response.data['h'];	
				}
			
				if (response.data.hasOwnProperty('__time')) 
				{
					App.time = response.data['__time'];
					delete response.data['__time'];	
				}
			
				
				if (response.data.hasOwnProperty('__took')) 
				{
					delete response.data['__took'];	
				}
				if (response.data.hasOwnProperty('__stock')) 
				{
					_stock = response.data.__stock;
					delete response.data['__stock'];	
				}
				if (response.data.hasOwnProperty('__queststate')) 
				{
					progress = new Object();
					//progress = response.data['__queststate'];
					for (var qID:* in response.data['__queststate']) 
					{
						if (App.data.quests.hasOwnProperty(qID)) 
						{
							progress[qID] = response.data['__queststate'][qID];
						}
					}
					delete response.data['__queststate'];	
				}
				
				//achivements
				if (response.data.hasOwnProperty('__achstate')) 
				{
					//progress = new Object();
					
					for (var ach:* in response.data.__achstate) 
					{
						if (!App.user.ach[ach]) 
						{
							App.user.ach[ach] = response.data.__achstate[ach];
							continue;
						}
						
						for (var mis:* in response.data.__achstate[ach]) 
						{
							App.user.ach[ach][mis] = response.data.__achstate[ach][mis];
						}
						
						AchivementsWindow.checkAchProgress(ach);
					}
					
			
					
					
					/*for (var qID:* in response.data['__achstate']) {
						if (App.data.quests.hasOwnProperty(qID)) {
							progress[qID] = response.data['__achstate'][qID];
						}
					}*/
					delete response.data['__achstate'];	
				}
				if (response.data.hasOwnProperty('__daylics')) 
				{
					dayliProgress = { };
					for (var dID:* in response.data['__daylics']) 
					{
						if (App.data.daylics.hasOwnProperty(dID)) 
						{
							for (var miss:* in response.data['__daylics'][dID])
							{
								App.user.daylics.quests[dID][miss] = response.data['__daylics'][dID][miss];
							}
							dayliProgress[dID] = response.data['__daylics'][dID];
							
						}
					}
					delete response.data['__daylics'];
				}	
			}
				//Устанавливаем время полночи
				if (response.data && response.data.hasOwnProperty('midnight')) 
				{
					if (response.data['midnight'] != undefined) 
					{
						App.midnight = response.data.midnight;
						App.nextMidnight = App.midnight + 24*3600;
						delete response.data['midnight'];	
					}
				}
			

			item.callback(response.error, response.data, item.params);
			
			if(App.ui && App.ui.bottomPanel)App.ui.bottomPanel.removePostPreloader();
			
			if (progress) 
			{
				App.user.quests.progress(progress);
			}
			if (dayliProgress) 
			{
				App.user.quests.dayliProgress(dayliProgress);
			}
			
			status = FREE;
			if (queue.length > 0) 
			{
				request();
			}
		}
		
		/*public static function statisticPost(type:String):void 
		{
			Post.send({
				ctr:'User',
				act:'stat',
				uID:App.user.id,
				type:type
			}, function(error:int, data:Object, params:Object):void 
			{
				if (error) 
				{
					Errors.show(error, data);
					return;
				}	
			});
		}*/
		
		public static function clear():void
		{
			queue = new Vector.<Object>;
		}
		
		private static function OnIOError(event:IOErrorEvent):void 
		{
			URLLoader(event.target).removeEventListener(Event.COMPLETE, onComplete);
			URLLoader(event.target).removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			
			trace(event.target.data);
			
			//Показываем ошибку, только если у нас уже не осталось flash:1382952379984пасных IP адресов
			if (Config._mainIP.length == 0) 
			{
				new SimpleWindow( 
				{
					title:Locale.__e('flash:1382952379725'),
					text:Locale.__e('flash:1382952379726'),
					label:SimpleWindow.ERROR
				});
			}
		}
		
		private static function OnHttpStatus(event:HTTPStatusEvent):void {
			
			switch(event.status) 
			{
				case 301:
				case 302:
				case 303:
				case 304:
				case 305:
				case 307:
				case 200: break;
				default: 
				
					URLLoader(event.target).removeEventListener(Event.COMPLETE, onComplete);
					URLLoader(event.target).removeEventListener(HTTPStatusEvent.HTTP_STATUS, OnHttpStatus);
					
					if (Config.changeIP()) 
					{
						status = FREE;
						if (queue.length > 0) 
						{
							request();
						}
						return;
					}
					
					//var item:Object = queue.shift();
					//item.callback(1000, null, item.params);
					
					//Errors.show(1000, {code:event.status } );
					break;
			}
		}
		
		
		public static function addToArchive(data:String, checkOnLength:Boolean = true):void
		{
			if (data.length > 430 && checkOnLength)
			{
				data = "\ntoo long\n";
			}
			
			if (archive.length > 80)
				archive.shift();
			
			var _data:String = data;
			archive.push(_data);
			Cc.log(_data);
		}
	}

}