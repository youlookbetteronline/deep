package chat 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author none
	 */
	public class ChatEvent extends Event 
	{
		public static const SEND_MESSAGE:String = 'send_message';
		public static const NEW_MESSAGE:String = 'new_message';
		public static const CHANGE_UI_HEIGHT:String = 'change_ui_height';
		public static const ON_CONNECT:String = 'ON_CONNECT';
		public static const ON_DISCONNECT:String = 'ON_DISCONNECT';
		public static const UPDATE_ONLINE:String = 'UPDATE_ONLINE';
		public static const UPDATE_CLAN_MEMBER:String = 'UPDATE_CLAN_MEMBER';
		
		public function ChatEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
	}

}