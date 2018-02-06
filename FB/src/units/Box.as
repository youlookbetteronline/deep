package units 
{
	import core.Load;
	import core.Numbers;
	import core.Post;
	import effects.explosion.ParticleManager;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.Hints;
	import wins.EventWindow;
	import wins.LevelLockWindow;
	import wins.ShopWindow;
	
	public class Box extends AUnit {
	
		public static var activeBoxJson:Object;

		public function Box(object:Object)
		{
			layer = Map.LAYER_SORT;
			if (object.hasOwnProperty('gift'))
				gift = object.gift;
				
			super(object);
			layer = Map.LAYER_SORT;
			
			clickable 			= true;
			touchableInGuest 	= false;
			removable = false;
			
			Load.loading(Config.getSwf(info.type, info.view), onLoad);
			
			tip = function():Object { 
				return {
					title:info.title,
					text:info.description
				};
			};
		}
		
		override public function buyAction(setts:*=null):void 
		{
			SoundsManager.instance.playSFX('build');
			//TODO снимаем деньги за покупку
			var money:uint = Stock.COINS;
			var count:int = info.coins;
			if (info.real > 0) {
				money = Stock.FANT;
				count = info.real;
			}
			
			var postObject:Object = {
				ctr:this.type,
				act:'buy',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z
			}
			
			if (gift) {
				postObject['gift'] = 1;
			}
			
			if (App.user.stock.take(money, count))
			{
				//Hints.buy(this);
				Post.send(postObject, onBuyAction);
				dispatchEvent(new AppEvent(AppEvent.AFTER_BUY));
			}else{
				ShopWindow.currentBuyObject.type = null;
				ShopWindow.currentBuyObject.currency = null;
				uninstall();
			}
		}
		
		override public function onLoad(data:*):void {
			textures = data;
			initAnimation();
			startAnimation();
			if (loader!=null) 
			{
				removeChild(loader);
			}
			
			loader = null;
			
			var levelData:Object = textures.sprites[0];			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (!open && formed) 
			{
				applyFilter();
			}
			
		}
		
		public function get levelLock():Boolean
		{
			var levellock:Boolean = false
			if (this.info.level != '' && App.user.level < this.info.level)
				levellock = true;
			return levellock
		}
		
		override public function click():Boolean 
		{
			
			if (levelLock)
			{
				new LevelLockWindow({
					level	:this.info.level,
					search	:this.info.sID
				}).show();
				return false;
			}
			if (!super.click()) return false;
			if (!clickable || id == 0) return false;
			//if (!App.user.quests.data.hasOwnProperty('111')) return false;
			App.tips.hide();
			if (App.user.mode == User.OWNER)
			{
				var price:Object = { };
				price[Stock.FANTASY] = 1;
					
				if (!App.user.stock.checkAll(price))	return false;
				
				showKeyWindow();
			}
			return true;
		}
		
		protected function showKeyWindow():void {
			if(info.hasOwnProperty('in')){
				if (Numbers.firstProp(info['in']).val == '')
				{
					onOpen();
					return;
				}
			}
			var data:Object = new Object();
			data[Numbers.firstProp(info['in']).key] = Numbers.firstProp(info['in']).val;
			
			new EventWindow({
				target:this,
				req:data,
			    description:App.data.storage[sid].text1||Locale.__e('flash:1382952379888'),
				bttnCaption:App.data.storage[sid].text2||Locale.__e('flash:1427966073897'),
				onWater:onOpen
			}).show();
		}
		
		protected var gift:Boolean = false;
		private function onOpen():void 
		{
			if (Numbers.firstProp(info['in']).val != '') 
			{
				App.user.stock.take(Numbers.firstProp(info['in']).key, Numbers.firstProp(info['in']).val);
				/*if (!Numbers.firstProp(info['in']).key, Numbers.firstProp(info['in']).val) {
					App.user.onStopEvent();
					showKeyWindow();
					return;	
				}*/
			}else {
				gift = true;
			}
			
			ordered = true;
			storageEvent();
		}
		
		override public function set ordered(ordered:Boolean):void 
		{
			super.ordered = ordered;
			alpha = 1;
			var levelData:Object;
			
			if (ordered)
			{
				if (textures.sprites.length > 1) 
				{
					levelData = textures.sprites[1];
				}else 
				{
					levelData = textures.sprites[0];
				}
				App.ui.flashGlowing(this);
			}else {
				levelData = textures.sprites[0];
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
		}
		
		public function storageEvent():void
		{
			if (App.user.mode == User.OWNER) 
			{
				var price:Object = { }
				//price[Stock.FANTASY] = 1;
				//price[info['in']] = 1;
				price = Numbers.firstProp(info['in']).val;
				
				if(price){
					if (!App.user.stock.takeAll(price))	return;
					Hints.minus(Numbers.firstProp(info['in']).key, Numbers.firstProp(info['in']).val, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
				}
				
				var postObject:Object = {
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}
				
				Post.send(postObject, onStorageEvent);
			}
		}
		
		public function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (data.bonus != null)
				Treasures.packageBonus(data.bonus, new Point(this.x, this.y));
				
			setTimeout(uninstall, 2000);	
		}
		
		private function getPosition():Object
		{
			var Y:int = -1;
			if (coords.z + Y <= 0)
				Y = 0;
			
			return { x:1, y: Y };
		}
		
		override public function get bmp():Bitmap {
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0)
				return bitmap;
			if (animeTouch && animeTouch.bitmapData && animeTouch.bitmapData.getPixel(animeTouch.mouseX, animeTouch.mouseY) != 0)
				return animeTouch;
				
			return bitmap;
		}
		
		private static var eventBoxComplete:Boolean = false;
		public static function generateEventBox():void 
		{
			if (!App.isSocial("DM","VK","OK","MM","FS")) return;
			if (App.map.id != User.HOME_WORLD) return;
			if (eventBoxComplete) return;
			
			activeBoxJson = JSON.parse(App.data.options.animatedBox);
			
			//Сид бокса
			
			for (var box:* in activeBoxJson[App.SOCIAL]) {
				var sid:int = activeBoxJson[App.SOCIAL][box]
			}
			
			var tries:int = 1000;
			var cell:int = 0;
			var row:int = 0;
			
			var list:Array = Map.findUnits([sid]);
			
			if (list.length > 0) 
			{
				
				return;
			}
			while (tries > 0 || eventBoxComplete) {
				cell = int(Math.random() * Map.cells);
				row = int(Math.random() * Map.rows);
				Post.addToArchive("cell " + cell);
				Post.addToArchive("row " + row);
				
				if (App.map._aStarNodes[cell][row].open && !App.map._aStarNodes[cell][row].object && App.map._aStarNodes[cell][row].b == 0) {
					var unit:Unit = Unit.add( {gift:false, sid:sid, buy:true, x:cell, z:row } );
					unit.buyAction();
					eventBoxComplete = true;
					
					break;
				}
				
				tries--;
			}
			
		}
	}
}