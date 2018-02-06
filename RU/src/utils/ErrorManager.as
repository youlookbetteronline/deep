package utils 
{
	import core.Post;
	import flash.display.Sprite;
	import flash.events.UncaughtErrorEvent;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ErrorManager extends Sprite
	{
		public static function onUncaughtError($event:UncaughtErrorEvent):void
		{
			$event.preventDefault();
			var message:String;
			var id:int = ($event.errorID) ? $event.errorID : $event.error.errorID
			if ($event.error["message"])
			{
				message = $event.error["message"];
			}
			else if ($event.error["text"])
			{
				message = $event.error["text"];
			}
			else
			{
				message = $event.error["toString"]();
			}
			message += $event.error.getStackTrace();
			sendErrorToServer(id, message);
		}
		
		public static function sendErrorToServer($errorId:*, $errorMessage:String, $name:String = ""):void
		{
			var errorText:String = ($name) ? ($errorMessage + " place: " + $name): $errorMessage;
			Post.send({ctr: 'user', act: 'error', uID: App.user.id, id: $errorId, error: errorText}, errorCallback);
		}
		
		public static function errorCallback($error:int = 0, $data:Object = null, $params:Object = null):void
		{
			if ($error)
			{
				return;
			}
		}
	}

}