package core
{
	import com.hs.apis.redis.events.RedisErrorEvent;
	import com.hs.apis.redis.events.RedisResultEvent;
	import com.hs.apis.redis.Redis;
	import com.hs.apis.redis.RedisResultType;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.Socket;
	import flash.ui.Mouse;
	import units.Ahappy;
	import wins.SimpleWindow;
	
	public class RedisManager
	{
		public var redisPub:Redis;
		public var redisSub:Redis;
		public var publisher:int;
		public var lastevent:*;
		
		public function RedisManager()
		{		
		}
		
		private static var __connecting:Boolean = false;
		private static var redisPub:Redis;
		private static var redisSub:Redis;
		private static var rooms:Array;
		private static var onConnecting:Function;
		public static function listenRooms(rooms:Array, callback:Function = null):void {
			
			if (!Config.connection)
				return;
				
			Log.alert('Socket Connection: ' + Config.connection);
			//trace('Socket Connection: ' + Config.connection);
			
			if (connecting) {
				if (callback != null)
					callback();
				
				return;
			}
			
			Log.alert('Socket Connection: connecting...');
			//trace('Socket Connection: connecting...');
			
			onConnecting = callback;
			RedisManager.rooms = rooms;
			
			redisPub = new Redis(Config.connection, 6379);
			redisPub.addEventListener("connected", connectedPub);
			redisPub.addEventListener(RedisResultEvent.RESULT, resultPub);
			redisPub.addEventListener(RedisErrorEvent.ERROR, errorPub);
			
			redisSub = new Redis(Config.connection, 6379);
			redisSub.addEventListener("connected", connectedSub);
			redisSub.addEventListener(RedisResultEvent.RESULT, resultSub);
			redisSub.addEventListener(RedisErrorEvent.ERROR, errorSub);
			
		}
		
		// Publisher
		private static function connectedPub( event:Event ):void {
			Log.alert(event);
			redisPub.execute( "AUTH" , ["&TFHDkskjhfvfues$%^&fdFGHJGF"] );
		}
		private static function resultPub(event:RedisResultEvent):void {
			for (var i:int = 0; i < event.result.length; i++) {
				var object:Object = event.result[i];
				
				switch(object.type) {
					case RedisResultType.STRING_SIMPLE:
						if (object.result == 'OK') {
							Log.alert('Socket Connection: connected!');
							//trace('Socket Connection: connected!');
						}
						break;
					case RedisResultType.INTEGER: break;
					case RedisResultType.ERROR: break;
					case RedisResultType.STRING_BULK: break;
					case RedisResultType.ARRAY: break;
				}
			}
		}
		private static function errorPub(event:RedisErrorEvent):void {
			Log.alert('Socket Connection: ERROR!');
			//trace('Socket Connection: ERROR!');
		}
		
		// Subscriber
		private static function connectedSub( event:Event ):void {
			Log.alert(event);
			redisSub.execute( "AUTH" , ["&TFHDkskjhfvfues$%^&fdFGHJGF"] );
			redisSub.execute( "SUBSCRIBE" , rooms );
			
			__connecting = true;
			
			if (onConnecting != null) onConnecting();
		}
		private static function resultSub(event:RedisResultEvent):void {
			for (var i:int = 0; i < event.result.length; i++) {
				var object:Object = event.result[i];
				
				switch(object.type) {
					case RedisResultType.STRING_SIMPLE: break;
					case RedisResultType.INTEGER: break;
					case RedisResultType.ERROR: break;
					case RedisResultType.STRING_BULK: break;
					case RedisResultType.ARRAY:
						if (event.result[i].result[0] != 'message') continue;
						
						var data:Object = JSON.parse(Base64.decode(object.result[2]));
						
						if (App.user.id != data['uid'] && data.hasOwnProperty('sid') && App.data.storage[data.sid]['type'] == 'Ahappy') {
							Log.alert(data);
							App.user.redisHandle(data);
						}
						
						break;
				}
				
			}
			
		}
		private static function errorSub(event:RedisErrorEvent):void {
			Log.alert(event);
		}
		
		public static function get connecting():Boolean {
			return __connecting;
		}
		
		public static function publish(room:String, value:String):void {
			if (!connecting) return;
			
			if (rooms.indexOf(room) == -1) {
				redisSub.unsubscribeAll();
				
				rooms.length = 0;
				rooms.push(room);
				
				redisSub.execute( "SUBSCRIBE" , rooms );
			}
			
			redisPub.execute( "PUBLISH" , [ room , Base64.encode(value) ] );
		}
		
		public static function unlistenRooms():void {
			if (!redisPub || !redisSub) return;
			
			redisPub.unsubscribe(rooms);			
		}		
	}
}