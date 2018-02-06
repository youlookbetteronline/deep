package  
{
	import chat.ChatEvent;
	import core.Post;
	import flash.display.Sprite;
	import flash.utils.clearTimeout;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import units.Unit;
	import units.Hero;
	import units.Personage;
	import utils.SocketActions;
	import wins.SimpleWindow;
	import wins.Window;

	public class Owner extends Sprite
	{
		
		public var id:String = '0'; 
		public var worldID:int = 1; 
		public var aka:String = ""; 
		public var sex:String = "m"; 
		public var first_name:String; 
		public var last_name:String; 
		public var photo:String; 
		public var level:uint = 1; 
		public var worlds:Object = { }; 
		public var world:World; 
		public var friends:Friends; 
		public var stock:Stock = null;
		public var lastvisit:uint;
		public var createtime:uint;
		public var energy:uint = 0;
		public var restore:int; 
		public var units:Object; 
		public var wishlist:Array = []; 
		public var maps:Object = {}; 
		public var shop:Object = {}; 
		public var money:int = 0; 
		public var pay:int = 0;
		
		public var hero:Hero;
		public var head:uint = 0;
		public var body:uint = 0;
		public var day:uint = 0;
		public var year:uint = 0;
		public var bonus:uint = 0;
		public var _6wbonus:Array = [];
		public var loaded:Boolean = false;
		
		public var ref:String = "";
		
		public function Owner(friend:Object, _worldID:int = 171){
			
			this.id = friend.uid;
			
			first_name 	= friend.first_name;
			last_name 	= friend.last_name;
			sex 		= friend.sex;
			photo		= friend.photo;
			level		= friend.level;
			aka 		= friend.aka;
			
			if (friend.wID == null) {
				worldID = _worldID;
			}
			
			if (id == '1') 
				worldID = 827;
			var _sendObject:Object = {
				'ctr':'user',
				'act':'state',
				'uID':id,
				'wID':worldID,
				'fields':JSON.stringify(['world', 'user'])
			};
			
			if (worldID == User.SOCKET_MAP){
				_sendObject['fields'] = JSON.stringify(['world', 'user', 'stock'])
				if(App.user.id != id)
					_sendObject['visited'] = App.user.id;
				
			}else
				_sendObject['visited'] = App.user.id;
				
			Post.send(_sendObject, onLoad);
		}
		
		public function onLoad(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				//Обрабатываем ошибку
				return;
			}
			
			units = data.units;
			world = new World(data.world);
			
			for (var properties:* in data.user)
			{
				if (properties == 'friends') 
					continue;
			}
			if (body == 0)
			{
				if (sex == 'm')
					body = User.BOY_BODY;
				else
					body = User.GIRL_BODY;
			}
			
			var worlds:Object = {};
			for each(var wID:* in this.worlds) 
			{
				worlds[wID] = wID;
			}
			this.worlds = worlds;
			
			if (App.data.storage[worldID].maptype == World.PUBLIC)
			{
				connectSocket();
				if (App.data.storage[worldID].size == World.MINI)
				{
					if (!data.world.hasOwnProperty('stock')) 
						data.world['stock'] = { };
						
					for (properties in data.stock)
					{
						if (App.data.storage.hasOwnProperty(properties) && App.data.storage[properties].mtype == 3)
							data.world.stock[properties] = data.stock[properties];
					}
					
					App.user.stock = new Stock(data.world.stock);
				}else {
					App.user.stock = new Stock(data.stock);
				}
				if (App.user.data['publicWorlds'] && App.user.data['publicWorlds'].hasOwnProperty(App.owner.worldID))
				{
					App.self.setOnTimer(onLockTime);
				}
				
			}
			
			loaded = true;
			
			if (App.data.storage[worldID].maptype == World.PUBLIC){
				App.self.addEventListener(ChatEvent.ON_CONNECT, onConnect);
			}
			//TODO инициалflash:1382952379993ируем flash:1382952379984висимые объекты
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_OWNER_COMPLETE));
			
		}
		
		public function onLockTime():void 
		{
			if (App.user.data['publicWorlds'][App.owner.worldID] == 0)
				return;
			if (App.user.mode != User.PUBLIC)
			{
				App.self.setOffTimer(onLockTime);
				return;
			}
			var timeLast:int = App.user.data['publicWorlds'][App.owner.worldID] - App.time;
			if (timeLast < 0)
			{
				App.self.setOffTimer(onLockTime);
				new SimpleWindow( {
					title			:Locale.__e("flash:1474469531767"),
					label			:SimpleWindow.ATTENTION,
					text			:Locale.__e("flash:1497517840451"),
					faderAsClose	:false,
					popup			:true,
					onCloseFunction:function():void
					{
						Window.closeAll();
						Travel.goTo(User.HOME_WORLD);
						App.user.data['publicWorlds'][App.owner.worldID] = 0;
					}
				}).show();
				
			}
		}
		
		public function onConnect(e:* = null):void
		{
			App.self.removeEventListener(ChatEvent.ON_CONNECT, onConnect);
			checkConnect();
		}
		
		private var sTimeout:uint = 14;
		public function checkConnect(e:* = null):void
		{
			if (App.user.mode == User.OWNER)
			{
				trace('NOT OWNER!!!!')
				if (Connection.connectionChat)
					Connection.disconnect();
				clearTimeout(sTimeout);
				return;
			}
			
			if (App.data.storage[worldID].maptype != World.PUBLIC)
			{
				clearTimeout(sTimeout);
				return;
			}
			if(Connection.connectionChat){
				SocketActions.checkUsers(Connection.activeUsers);
				sTimeout = setTimeout(checkConnect, 3000);
			}else{
				trace('NO CONNECTION!!!!!!!!!!!!!')
			}
		}
		
		public function connectSocket():void
		{
			Connection.init();
		}
		
		public function addPersonag():void 
		{
			// добавляем персонажа
			hero = new Hero(this, { id:8, sid:Personage.HERO, x:12, z:16, ava:true } );
			App.map.sorted.push(hero);
			
			//Не показываем персонажа бота
			if (this.id == '1') {
				hero.visible = false;
			}
		}
		
		public function showMessage():void {
			if (App.user.quests.data['78'] != null && App.user.quests.data['74'].finished > 0) {
				if (App.user.quests.data['93'] == null || App.user.quests.data['93'].finished == 0) {
					new SimpleWindow( {
						label:SimpleWindow.ATTENTION,
						title:Locale.__e("flash:1382952379699"),
						text:Locale.__e('flash:1382952379742'),
						height:400
					}).show()
				}
			}
		}
		
		public function clearVariables():void {
			var self:* = this;
			var description:XML = describeType(this);
			var variables:XMLList = description..variable;
			for each(var variable:XML in variables) {
				var ss:String = variable.@type;
				if(variable.@type == '*')
				{
					self[variable.@name] = null;
					continue;
				}
				var classType:Class
				try{
					classType = getDefinitionByName(variable.@type) as Class;
				}catch (e:Error){
					self[variable.@name] = null;
					continue;
				}
				switch(classType){
					case Sprite:
						if (self[variable.@name]){
							self[variable.@name].removeChildren();
							self[variable.@name] = null;
						}
						break;
					default:
						self[variable.@name] = null;
				}
			}
		}
	}
}