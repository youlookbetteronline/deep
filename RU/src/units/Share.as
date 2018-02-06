package units
{
	import api.ExternalApi;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import strings.Strings;
	import ui.Hints;
	import wins.BuildingConstructWindow;
	import wins.ProductionWindow;
	import wins.RepairWindow;
	import wins.ShareGuestWindow;
	import wins.ShareWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class Share extends Building
	{
		public var guests:Object;
		public var kicks:uint;
		public var burst:int = 0;
		
		public function Share(object:Object)
		{		
			guests = object.guests || { };
			kicks = object.kicks || 0;
			super(object);
		}
		
		override public function onLoad(data:*):void
		{
			super.onLoad(data);
			//setCloudPosition(0, -40);
				
			if (level == totalLevels)
				touchableInGuest = true;
				
			if (kicks >= info.count){
				level ++;
				updateLevel();
				//flag = false;
				
				if (App.user.mode == User.OWNER){
					//flag = "hand"; 
				}else
					touchableInGuest = false;
			}else{
				if (App.user.mode == User.GUEST) {
					//flag = "hand"; 
				}
			}
		}
		
		override public function onAfterBuy(e:AppEvent):void
		{
			removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			
			App.user.stock.add(Stock.EXP, App.data.storage[sid].experience);
			
			if (App.data.storage[sid].hasOwnProperty('experience'))
			{
				Hints.plus(Stock.EXP, App.data.storage[sid].experience, new Point(this.x + App.map.x, this.y + App.map.y), true);
			}			
			
			App.ui.flashGlowing(this);
		}
		
		override public function click():Boolean {
			if (!clickable) return false;
				
			if (level < totalLevels) {
				if(App.user.mode == User.OWNER){
					new BuildingConstructWindow({
						title:info.title,
						level:Number(level),
						totalLevels:Number(totalLevels),
						devels:info.devel[level+1],
						bonus:info.bonus,
						target:this,
						upgradeCallback:upgradeEvent
					}).show();
				}
			}
			else
			{
				if(App.user.mode == User.OWNER){
					new ShareWindow( {
						target:this,
						storageEvent:storageAction
					} ).show();
				}else {	
					if (kicks >= info.count)
					{
						// Больше стучать нельзя
					}
					else
					{
						new ShareGuestWindow({
							target:this,
							kickEvent:kickEvent
						}).show();
					}
				}
			}
			
			return true;
		}
		
		public function kickEvent(mID:uint, callback:Function, type:int = 1, _sendObject:Object = null):void {
			
			var item:Object = App.data.storage[mID];
			switch(type) {
				case 1:
					if (!App.user.friends.takeGuestEnergy(App.owner.id)) 
						return;
					break;
				case 2:
					if (!App.user.stock.take(Stock.FANT, item.price[Stock.FANT])) 
						return;
					break;
				case 3:
					if (!App.user.stock.take(mID, 1))
						return;
					break;
			}
			
			var self:Share = this;
			var sendObject:Object = {
				ctr:info.type,
				act:'kick',
				uID:App.owner.id,
				wID:App.owner.worldID,
				sID:this.sid,
				id:this.id,
				guest:App.user.id,
				mID:mID
			}
			
			if (_sendObject != null)
				for (var _item:* in _sendObject)
					sendObject[_item] = _sendObject[_item];
		
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void 
			{
				if (error) {
					
					if (error == 31) {
						uninstall();
						new SimpleWindow( {
							label:SimpleWindow.ATTENTION,
							text:Locale.__e(info.text1),
							forcedClosing:true
						}).show();
						if(type == 1){
							App.user.friends.addGuestEnergy(App.owner.id);
						}
						
						return;
					}
					
					Errors.show(error, data);
					return;
				}
				
				callback();
								
				if (data.hasOwnProperty("energy") && data.energy > 0)
					App.user.friends.updateOne(App.owner.id, "energy", data.energy);
					
				if (data.hasOwnProperty('bonus'))
					Treasures.bonus(data.bonus, new Point(self.x, self.y));
					
				self = null;
				
				if (type == 1)
				{
					App.user.friends.giveGuestBonus(App.owner.id);
					guests[App.user.id] = App.time;	
				}
				
				kicks += info.kicks[mID].c;				
				if (data.hasOwnProperty('kicks'))
					kicks = data.kicks;
				
				refresh();
			});
		}
		
		public function mKickEvent(mID:uint, callback:Function, type:int = 1, _sendObject:Object = null):void {
			
			var item:Object = App.data.storage[mID];
			switch(type) {
				case 1:
					if (!App.user.friends.takeGuestEnergy(App.owner.id)) 
						return;
					break;
				case 2:
					if (!App.user.stock.take(Stock.FANT, item.price[Stock.FANT])) 
						return;
					break;
				case 3:
					if (!App.user.stock.take(mID, 1))
						return;
					break;
			}
			
			var self:Share = this;
			var sendObject:Object = {
				ctr:info.type,
				act:'mkick',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				//guest:App.user.id,
				mID:mID
			}
			
			if (_sendObject != null)
				for (var _item:* in _sendObject)
					sendObject[_item] = _sendObject[_item];
		
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void 
			{
				if (error) {
					
					if (error == 31) {
						uninstall();
						new SimpleWindow( {
							label:SimpleWindow.ATTENTION,
							text:Locale.__e(info.text1),
							forcedClosing:true
						}).show();
						if(type == 1){
							App.user.friends.addGuestEnergy(App.owner.id);
						}
						
						return;
					}
					
					Errors.show(error, data);
					return;
				}
				
				callback();
								
				if (data.hasOwnProperty("energy") && data.energy > 0)
					App.user.friends.updateOne(App.owner.id, "energy", data.energy);
					
				if (data.hasOwnProperty('bonus'))
					Treasures.bonus(data.bonus, new Point(self.x, self.y));
					
				self = null;
				
				if (type == 1)
				{
					App.user.friends.giveGuestBonus(App.owner.id);
					guests[App.user.id] = App.time;	
				}
				
				kicks += info.mkicks[mID].c;
				
				
				if (data.hasOwnProperty('kicks'))
					kicks = data.kicks;
				
				refresh();
			});
		}
		
		public function refresh():void {
			if (kicks >= info.count) {
				//flag = false;
				level = totalLevels +1;
				updateLevel();
				touchableInGuest = false;
			}
		}
		
		public function storageAction(boost:uint, callback:Function):void {
			
			if (boost != 0) {
				if (!App.user.stock.take(Stock.FANT, boost))
					return;
			}
			else
			{
				if (!App.user.stock.take(Stock.FANTASY, 1))
					return;
			}
			
			var self:Share = this;
			var sendObject:Object = {
				ctr:'share',
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}
			
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				callback(Stock.FANT, boost);
				
				if (data.hasOwnProperty(Stock.FANT))
					App.user.stock.data[Stock.FANT] = data[Stock.FANT];
				
				if (data.hasOwnProperty('bonus'))
					Treasures.packageBonus(data.bonus, new Point(self.x, self.y));
				
				uninstall();
				self = null;
				
			});
		}
		
		public function sendInvite(fID:String):void
		{
			//Пост на стену
			//var message:String = Locale.__e("flash:1382952379950", [Config.appUrl]);
			//var message:String = Strings.__e('Share_sendInvite', [Config.appUrl]);
			var message:String = Locale.__e(info.text8) +" "+ Config.appUrl;
			var bitmap:Bitmap = null
			
			if(info.view == 'egg'){
				bitmap = new Bitmap(Window.textures.easterBear);
			}	
			else	
			{
				var cont:Sprite = new Sprite();
				var _bitmap:Bitmap = new Bitmap(textures.sprites[3].bmp);
				cont.addChild(_bitmap);
				_bitmap.smoothing = true;
				_bitmap.scaleX = _bitmap.scaleY = 0.7;
				var bmd:BitmapData = new BitmapData(cont.width, cont.height, true, 0);
				bmd.draw(cont);
				bitmap = new Bitmap(bmd);
				bitmap = new Bitmap(Gifts.generateGiftPost(bitmap, -15));
			}
			
			if (bitmap != null) {
				ExternalApi.apiWallPostEvent(ExternalApi.OTHER, bitmap, String(fID), message, sid);
			}
			//End Пост на стену
		}
		
		public function sendKickPost(fID:String, bmp:Bitmap):void
		{
			//Пост на стену
			//var message:String = Locale.__e("flash:1382952380041 ударил по Пасхальному яйцу в твоем сне. %s", [Config.appUrl]);
			//var message:String = Strings.__e('Share_sendKickPost', [Config.appUrl]);
			var message:String = Locale.__e(info.text9) + " " + Config.appUrl;
			var bitmap:Bitmap = new Bitmap(Gifts.generateGiftPost(bmp));
			
			if (bitmap != null) {
				ExternalApi.apiWallPostEvent(ExternalApi.OTHER, bitmap, String(fID), message, sid);
			}
			//End Пост на стену
		}
	}
}
