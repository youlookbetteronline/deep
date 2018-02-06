package chat.models 
{
	import chat.Chat;
	import chat.ChatEvent;
	import flash.events.Event;
	/**
	 * ...
	 * @author none
	 */
	public class ClanChat extends ChatModel
	{
		public var messages:Array = [];
		private var _messagesSettings:Object = {
			maxLength:50
		}
		public function ClanChat(token:String, settings:Object) {
			super(token, settings);
		}
		
		override protected function onConnect(e:ChatEvent):void {
			App.self.createChatWindow();
		}
		
		override protected function onNewMessage(e:ChatEvent):void {
			var message:Object = _chat.lastMessage;
			var tempUser:String = 'some';
			if (message.body.info && message.body.info.user) tempUser = message.body.info.user;
			messages.push({name:tempUser, text:message.body.data.input});
			if (messages.length > _messagesSettings.maxLength){
				messages.splice(0, messages.length - _messagesSettings.maxLength);
			}
			App.self.chatWindow.refresh();
			trace('new message from['+tempUser+'] text['+message.body.data.input+']');
		}
	}

}