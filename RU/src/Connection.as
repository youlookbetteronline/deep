package 
{
	import chat.Chat;
	import chat.ChatEvent;
	import chat.models.ChatModel;
	import com.junkbyte.console.Cc;
	import core.Numbers;
	import core.Post;
	import wins.SimpleWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class Connection 
	{
		
		public function Connection() 
		{
			
		}
		
		public static var MAX_USERS:int = 5;
		private static var _chat:ChatModel;
		public static var _dafaultSettings:Object = {
			onParamsConnect:function(e:*):void{
				trace(e);
				var _owner:Object = {
					sex:App.user.sex,
					head:App.user.head,
					body:App.user.body,
					photo:App.user.photo,
					id:App.user.id
				}
				var users:Array = Connection.activeUsers;
				trace('users: ' + users.length);
				Connection.subscribe();
				Connection.sendMessage({u_event:'hero_load', aka:App.user.aka, params:{uID:App.user.id, owner:_owner, coords:{x:App.user.hero.coords.x, z:App.user.hero.coords.z}}});
			}
		};
		public static function init(settings:Object = null):void {
			//Cc.visible = true;
			if(_chat){
				_chat.chat.disconnect();
				_chat.dispose();
				_chat = null;
			}
			if (!settings)
				settings = Connection._dafaultSettings;
			Post.send({
				ctr: 'user',
				act: 'connect',
				uID: App.user.id,
				wID: App.user.worldID
			}, function(e:int, data:Object, params:Object):void {
				if (data.hasOwnProperty('presence') && Numbers.countProps(data.presence[0][0].body.data) >= Connection.MAX_USERS)
				{
					new SimpleWindow( {
						title			:Locale.__e("flash:1474469531767"),
						label			:SimpleWindow.ATTENTION,
						text			:Locale.__e("flash:1503913855490"),
						faderAsClose	:false,
						popup			:true,
						onCloseFunction:function():void
						{
							Window.closeAll();
							Travel.goTo(User.HOME_WORLD);
							App.owner = null;
							//App.user.data['publicWorlds'][App.owner.worldID] = 0;
						}
					}).show();
					return;
				}
					
				_chat = new ChatModel(data.token, settings);
			});
		}
		
		public static function sendMessage(obj:Object):void {
			if (!_chat) return;
			var msg:String = JSON.stringify(obj);
			_chat.sendMessage(msg);
		}
		
		public static function disconnect():void 
		{
			if (!_chat) return;
			_chat.chat.disconnect();
			_chat.dispose();
			_chat = null;
		}
		
		public static function get connectionChat():ChatModel 
		{
			return _chat;
		}
		
		public static function subscribe():void 
		{
			if (!_chat) return;
			_chat.chat.subscribe();
		}
		
		
		public static function get activeUsers():Array
		{
			//return [App.user.id, App.user.id];
			return _chat.chat.activeUsers;
		}
	}

}