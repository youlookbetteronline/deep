package units 
{
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.RedisManager;
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	import wins.AhappyAuctionWindow;
	import wins.AhappyWindow;
	//import wins.AhappyAuctionWindow;
	import wins.AhappyRunningWindow;
	//import wins.AhappyWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class Ahappy extends Happy 
	{
		public static var entered:Boolean = false;
		public static var ahappys:Array = [];
		public static var ahappy:Ahappy;
		
		//Константы для vtype
		public static const TURKEY_RUN:int = 1;
		public static const AUCTION:int = 0;
		
		public var auction:Object;
		public var auctionID:*;
		
		public static var users:Object = {};
			
		public function Ahappy(object:Object) 
		{
			super(object);
			
			initAuctions();

			if (expire > App.time)
				App.self.setOnTimer(timer);
			
			Ahappy.ahappy = this;
			
			if (expire > App.time)
				removable = false;
			
		}
		
		public function initAuctions():void {
			
			for (var aid:* in App.user.auctions) {
				var auction:Object = App.user.auctions[aid];
				if (Numbers.countProps(auction) == 0) continue;
				// Если в комнате нет этого пользователя (серверный баг) просто очищаем ее
				if (!auction.users[App.user.id]) {
					delete App.user.auctions[aid];
					continue;
				}
				
				//if (auction.started + auctionTime > App.time) {
					//this.auction = auction;
					//
					//break;
				//}
				if (auction.started + auctionTime > App.time) {
					this.auction = auction;
					auctionID = aid;
					
					break;
				}
			}
		}
		
		override public function openProductionWindow():void {
			new AhappyWindow( {
				target:		this
			}).show();
		}
		
		public function get auctionStart():int {
			return expire - info.lifetime;
		}
		public function get auctionTime():int {
			return info.duration;
		}
		public function get auctionReady():Boolean {
			for each(var auction:Object in App.user.auctions) {
				if (auction.started + auctionTime <= App.time)
					return true;
			}
			
			return false;
		}
		public function get auctionHasUnready():Boolean {
			for each(var auction:Object in App.user.auctions) {
				if (auction.started + auctionTime > App.time)
					return true;
			}
			//
			return false;
		}
		
		override public function click():Boolean {
			
			if (App.user.mode == User.GUEST) {
				return true;
			}
			
			openProductionWindow();
			
			return true;
		}
		
		private function timer():void {
			if (!auctionHasUnready && auction) {
				RedisManager.unlistenRooms();
				//Window.closeAll(AhappyWindow, AhappyAuctionWindow/*, AhappyRunningWindow*/);
				
				updateFullData = true;
				auction = null;
			}
		}
		
		override public function uninstall():void 
		{			
			App.self.setOffTimer(timer);
			Ahappy.ahappy = null;
			super.uninstall();
		}
		
		public function userSort(a:Object, b:Object):int {
			if (a.count > b.count) {
				return -1;
			}else if (a.count < b.count) {
				return 1;
			}else {
				if (a.time > b.time) {
					return 1;
				}else if (a.time < b.time) {
					return -1;
				}else {
					return 0;
				}
			}
		}
		
		override public function load():void 
		{
			if (textures) 
			{
				stopAnimation();
				textures = null;
			}
			
			var view:String = info.view;
			if (info.hasOwnProperty('start') && level == 0) 
			{
				level = info.start;
			} 
			if (info.hasOwnProperty('tower')) 
			{
				var viewLevel:int = level;
				while (true) 
				{
					if (info.tower.hasOwnProperty(viewLevel) && info.tower[viewLevel].hasOwnProperty('v') && String(info.tower[viewLevel].v).length > 0) 
					{
						if (info.tower[viewLevel].v == '0') 
						{
							if (viewLevel > 0) 
							{
								viewLevel --;
							}
							else 
							{
								break;
							}
						} 
						else 
						{
							view = info.tower[viewLevel].v;
							break;
						}
					}
					else if (viewLevel == 0) 
					{
						view = info.preview;
						break;
					}
					else 
					{
						break;
					}
				}
			}
			
			Load.loading(Config.getSwf(type, view), onLoad);
		}
		
		
		//private var usedStage:int = 0;
		override public function drawIcon(type:String, material:*, need:int = 0, params:Object = null, directSid:int = 0, posX:int = 0, posY:int = 0):void 
		{
		/*override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{*/
            if (textures == null)
                return;
			
			var numInstance:uint = instanceNumber();
			
			var levelData:Object;
			
			//if (this.level && 
				//info.hasOwnProperty("instance") && 
				//info.instance.hasOwnProperty("devel") && 
				//info.instance.devel.hasOwnProperty(numInstance) && 
				//info.instance.devel[numInstance].hasOwnProperty("req") &&
				//info.instance.devel[numInstance].req.hasOwnProperty(this.level) &&
				//info.instance.devel[numInstance].req[this.level].hasOwnProperty("s") &&
				//textures.sprites[info.instance.devel[numInstance].req[this.level].s])
			//{
				//usedStage = info.instance.devel[numInstance].req[this.level].s;
			//}
			//else if (textures.sprites[this.level]) 
			//{
				//usedStage = this.level;
			//}
			
			
			levelData = textures.sprites[usedStage];
			
			/*if (checkRotate && rotate == true) {
				flip();
			}*/
			
			if (this.level != 0 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				App.ui.flashGlowing(this, 0xFFF000);
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			if (level >= totalLevels) 
				addGround();
			
			checkOnAnimationInit();
		}
		
		
		
		override public function checkOnAnimationInit():void 
		{
			//totalLevels = 0;
			//for (var _lvl:* in info.tower)
				//totalLevels++;
				//
			//if (textures && textures['animation'] && ((level >= totalLevels - craftLevels) /*|| this.sid == 236*/)) 
			//{
				initAnimation();
				beginAnimation();
				startAnimation();
			//}
		}
		
		// Enter action
		public function enterAction(callback:Function = null):void {
			
			updateFullData = true;
			
			Post.send( {
				ctr:	'Auction',
				act:	'enter',
				uID:	App.user.id,
				sID:	sid,
				id:		id,
				wID:	App.map.id
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.hasOwnProperty('auction')) {
					auction = data.auction;
					
					var key:int = 0;
					while (true) {
						if (App.user.auctions[key])
							key++;
						else
							break;
					}
					
					App.user.auctions[key] = auction;
					
					Ahappy.entered = true;
				}
				
				if (callback != null)
					callback(auction);
				
			});
		}
		
		private var updateFullData:Boolean = true;
		public function updateAuctionView(callback:Function = null, auctionID:int = 0, roomID:String = ''):void {
			
								// Если (roomID == '') и разрешено полное обновление данных в App.user.auctions то обновляем,
								// иноче просто вызываем callback
								
								/*if (roomID == '' && !updateFullData) {
									callback(auction);
									return;
								}*/
			
			Post.send( {
				ctr:	'Auction',
				act:	'view',
				uID:	App.user.id,
				aid:	auctionID,
				room:	roomID
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				for (var id:Object in data) {
					for (var aid:* in App.user.auctions) {
						if (App.user.auctions[aid].room == data[id].room) {
							App.user.auctions[aid] = data[id];
							
							if (auction && auction.room == data[id].room)
								auction = data[id];
							
							break;
						}
					}
				}
				
				if (callback != null)
					callback(auction);
				
				if (roomID == '') 
					updateFullData = false;
			});
		}
		
		// Push action
		public function pushAction(count:int = 1, callback:Function = null):void {
			
			if (!auction) return;
			
			var require:Object = { }; ;
			for (var s:* in App.data.storage[auction.aid]['in'])
				require[s] = App.data.storage[auction.aid]['in'][s] * count;
			
			if (!App.user.stock.takeAll(require)) {
				if (callback != null)
					callback('stock');
				
				return;
			}
			
			Post.send( {
				ctr:	'Auction',
				act:	'push',
				uID:	App.user.id,
				sID:	sid,
				id:		id,
				wID:	App.map.id,
				aid:	auction.aid,
				room:	auction.room,
				count:	count
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				auction.users[App.user.id].count = data.total;
				
				updateUserAuction();
				
				if (callback != null)
					callback(auction);
				
			});
		}
		
		// Push action
		public function bonusAction(auction:Object, callback:Function = null):void {
			
			Post.send( {
				ctr:	'Auction',
				act:	'bonus',
				uID:	App.user.id,
				wID:	App.map.id,
				sID:	sid,
				id:		id,
				aid:	auction.aid,
				room:	auction.room
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				for (var auctionID:Object in App.user.auctions) {
					if (App.user.auctions[auctionID] == auction)
						delete App.user.auctions[auctionID];
				}
				
				if (callback != null)
					callback(data.bonus);
				
			});
		}
		
		
		override public function growAction(callback:Function = null):void 
		{
			growCallback = callback;
			
			Post.send( {
				ctr:	type,
				act:	'grow',
				uID:	App.user.id,
				wID:	App.user.worldID,
				id:		id,
				sID:	sid
			}, function(error:int, data:Object, params:Object):void {
				if (error) 
				{		
					if (type == 'Ahappy') 
					{
						new SimpleWindow({
							title:	"System",
							text: 	"Время ещё не пришло!",
							height: 250,
							popup:	true
						}).show();
					}
					return;
				}
				
				if (data.hasOwnProperty('level')) level = data.level;
				 load();
				checkLevel();
				updateLevel();
				
				if (growCallback != null) {
					growCallback(Treasures.treasureToObject(data.bonus));
					growCallback = null;
				}
			});
		}
		
				
		private function checkLevel():void {
			if (level > totalLevels) {
				upgrade = level - totalLevels;
			}
		}
		
		// Обновляет данные аукциона в User
		public function updateUserAuction():void {
			if (!auction || auction.started + auctionTime < App.time) return;
			
			for (var aid:* in App.user.auctions) {
				if (App.user.auctions[aid].room == auction.room) {
					App.user.auctions[aid] = this.auction;
				}
			}

		}
		
	}

}