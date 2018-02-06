package chat.models 
{
	import chat.Chat;
	import chat.ChatEvent;
	import com.junkbyte.console.Cc;
	import empire.clans.Clan;
	import empire.clans.clanWar.ClanWarConstants;
	import empire.clans.clanWar.controllers.ClanWarController;
	import empire.clans.clanWar.controllers.ClickController;
	import hlp.ToolsUtils;
	import wins.Window;
	/**
	 * ...
	 * @author none
	 */
	public class WarChat extends ChatModel {
		
		public static const UPDATE_POINT	:int = 0;
		public static const END_WAR			:int = 1;
		public static const UPDATE_MEMBER	:int = 2;
		
		private var _token:String;
		public function WarChat(token:String, settings:Object) {
			_token = token;
			super(token, settings);
		}
		
		override protected function onNewMessage(e:ChatEvent):void {
			var message:Object = _chat.lastMessage;
			var tempUser:String = 'some';
			var temp:String = ToolsUtils.encrypt(message.body.data.input, ClanWarConstants.not_key, false);
			try {
				var obj:Object = JSON.parse(temp);
				onHandleMessage(obj);
			}catch (e1:VerifyError){
				Cc.error(e1.getStackTrace());
			}catch (e2:SyntaxError){
				Cc.error(e2.getStackTrace());
			}
		}
		
		override public function sendMessage(msg:String):void{
			//trace(msg);
			var msgNew:String = ToolsUtils.encrypt(msg, ClanWarConstants.not_key, true)
			super.sendMessage(msgNew);
			//var temp:String = ToolsUtils.encrypt(msgNew, ClanWarConstants.not_key, false);
			//trace(temp);
			//trace('-----------------------');
		}
		
		override protected function onConnect(e:ChatEvent):void {
			//trace('Connected')
		}
		
		private function onHandleMessage(obj:Object):void{
			switch (obj.type){
				case UPDATE_POINT:
					var tempLines:Object = App.user.clan.wars.info[obj.clan].lines;
					var tempLine:Object = tempLines[obj.point.line][obj.point.point];
					tempLine = obj.point;
					tempLines[obj.point.line][obj.point.point] = tempLine;
					if (ClanWarController.map != null) ClanWarController.map.renewField();
					break;
				case END_WAR:
					ClickController.endWar(obj);
					break;
				case UPDATE_MEMBER:
					if (!App.user.clan.members.hasOwnProperty(obj.uid)) return;
					App.user.clan.members[obj.uid].status = obj.status;
					App.self.dispatchEvent(new ChatEvent(ChatEvent.UPDATE_CLAN_MEMBER));
					break;
			}
		}
	}
}