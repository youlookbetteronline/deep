
package units
{
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.setTimeout;
	import wins.ConstructWindow;
	import wins.StockWindow;
	import wins.StoreHouseWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Storehouse extends Building
	{
		public var _capacity:uint;
		public var totalCapacity:uint;
		private var _created:int;
		public static const STOREHOUSE_1:uint = 161;
		public static const SILO:uint = 139;
		public static var storehouses:Array = [];
		
		public static function addStorehouse(_unit:Storehouse):void{
			if (storehouses.indexOf(_unit) != -1) 
				return;
			
			storehouses.push(_unit);
			refreshLimits();
		}
		
		public static function refreshLimits():void {
			var newEfirLimit:int = 0;	
			var newStockLimit:int = 0;	
			for each(var _storehouse:Storehouse in storehouses) {
				switch(_storehouse.sid) {
				case STOREHOUSE_1:
					newEfirLimit += _storehouse.totalCapacity;	
					break;
				case SILO:
					newStockLimit += _storehouse.totalCapacity;	
					break;	
				}	
			}
			efirDistribution();				
			
			Stock.efirLimit = newEfirLimit;
			//Stock.limit = newStockLimit;
		}
		
		public static function upgrade(_unit:Storehouse):void {
			
			//if (_unit.sid == SILO) {
				//Stock.limit = _unit.totalCapacity;
				//return;
			//}
			
			if (storehouses.indexOf(_unit) == -1) 
				addStorehouse(_unit);
			else	
				refreshLimits();	
		}
		
		public static function removeStorehouse(_unit:Storehouse):void {
			var index:int = storehouses.indexOf(_unit);
			if (index == -1) return;
			
			storehouses.splice(index, 1);	
			refreshLimits();
		}
		
		public static function efirDistribution():void {
			var totalEfir:int = App.user.stock.count(Stock.FANTASY);
			for (var i:int = 0; i < storehouses.length; i++) {
				if(storehouses[i].sid == STOREHOUSE_1){
					var storeCapacity:int = storehouses[i].totalCapacity;
					
					var takedEfir:int = storeCapacity;
					if (takedEfir > totalEfir)
						takedEfir = totalEfir;
						
					totalEfir -= takedEfir;
					storehouses[i].capacity = takedEfir;
				}
			}
		}
		
		public function Storehouse(object:Object)
		{
			capacityBitmap = new Bitmap();
			super(object);
			if(sid == SILO)		removable = false;
			
			bitmapContainer.addChild(capacityBitmap);
			
			if(level > 0)
				totalCapacity = info.devel.req[level].c;
			else
				totalCapacity = info.devel.req[1].c;
				
			if (formed && level > 0)
				addStorehouse(this);
				
				
			tip = function():Object 
			{
				if (created > 0 && !hasBuilded) {
					return {
						title:info.title,
						text:Locale.__e('flash:1395412587100') +  '\n' + TimeConverter.timeToStr(created-App.time),
						timer:true
					}
				}else if (upgradedTime > 0 && !hasUpgraded) {
					
					return {
						title:info.title,
						text:Locale.__e('flash:1395412562823') +  '\n' + TimeConverter.timeToStr(upgradedTime-App.time),
						timer:true
					}
				}
				
				if (sid == SILO) {
					return {
						title:info.title
						//text:Stock.value+"/"+Stock.limit
					};
				}
				return {
					title:info.title,
					text:capacity+"/"+totalCapacity
				};
			}
		}
		
		
		public function set capacity(value:uint):void {
			_capacity = value;
			setCapacity(_capacity);
		}
		public function get capacity():uint {
			return _capacity;
		}
		
		override public function openConstructWindow(popup:Boolean = false):Boolean 
		{
			if (sid == SILO)
				return false
			else if(super.openConstructWindow()) return true;
			
			return false;
		}
		
		private var capacityBitmap:Bitmap;
		private function setCapacity(volume:Number = 0):void {
			
			if (textures == null || level == 0) 
				return;
		
			var ratio:Number = (volume / totalCapacity);	
			if (ratio > 1) ratio = 1;
			var _currentLevel:Number = ratio * (capacityLevels.length-1);
			var currentLevel:int = Math.floor(_currentLevel);
			
			var spriteID:int = capacityLevels[currentLevel];
			
			if(spriteID == 0){
				capacityBitmap.bitmapData = new BitmapData(1, 1, true, 0);
				return;
			}	
			
			var data:Object = textures.sprites[spriteID];
			capacityBitmap.bitmapData = data.bmp;
			capacityBitmap.x = data.dx;
			capacityBitmap.y = data.dy;
		}
		
		override public function updateLevel(checkRotate:Boolean = false):void 
		{
			if (textures == null) return;
			if (level <= 1) {
				updateGraphics();
			}else {
				totalCapacity = info.devel.req[level].c;
				//refreshLimits();
				Load.loading(Config.getSwf(type, info.devel.req[level].v), onGraphicsLoad);
			}
		}
		
		private function onGraphicsLoad(data:*):void{
			textures = data;
			updateGraphics();
		}
			
		private var capacityLevels:Array = [];
		private function updateGraphics():void
		{
			capacityLevels = [null];
			var firstCapLevel:int = 2;// 0-галлограмма 1-здание
			if (level > 1)
				firstCapLevel = 1;// 0-здание
			
			for (var i:int = firstCapLevel; i < textures.sprites.length; i++) {
				capacityLevels.push(i)
			}
				
			var levelData:Object;
			if (level == 1) {
				if(textures.sprites[1] == null)
					levelData = textures.sprites[0];
				else
					levelData = textures.sprites[1];
			}else {
				levelData = textures.sprites[0];
			}
			
			if (this.level == 1 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				App.ui.flashGlowing(this, 0x6fefff);
				
				TweenLite.to(bitmap, 2, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			//onGraphicsUpdated();
		}
		
		/*private function onEfirChanged(e:AppEvent = null):void 
		{
			var buildingsCount:int = World.getBuildingCount(sid);
			var efirCount:int = App.user.stock.count(Stock.FANTASY);
			
			capacity = int(efirCount/buildingsCount);
			setCapacity(capacity);
		}*/		
		
		private var counter:int = 0;
		private function onGraphicsUpdated():void
		{
			if (level > 0 ) {
				initAnimation();
				beginAnimation();
			}
			if (_created >= _capacity || hasPresent || !hasUpgraded) {
				finishAnimation();
			}
			
			setCapacity(capacity);
			//onEfirChanged();
		}
		
		override public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			super.onBonusEvent(error, data, params);
			totalCapacity = info.devel.req[level].c;
			Storehouse.upgrade(this);
			if (sid == SILO) {
				StockWindow.showUpgBttn = true;
				//App.ui.bottomPanel.bttnMainStock.buttonMode = true;
				//TweenLite.to(App.ui.bottomPanel.bttnMainStock, 1, { alpha:1 } );
			}
		}
		
		override public function uninstall():void {
			removeStorehouse(this);
			super.uninstall();
		}
		
		override public function openProductionWindow():void {
			if(sid == SILO)
				new StockWindow( /*{
					target:this
				}*/).show();
			else {
				new StoreHouseWindow({
					title:info.title,
					target:this,
					capasity:_capacity,
					totalCapacity:totalCapacity,
					onUpgradeEvent:upgradeEvent
				}).show();
			}
		}
		
		override public function setCraftLevels():void
		{
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('req')) {
				for each(var obj:* in info.devel.req) {
					if(obj.s > 0)
						craftLevels++;
				}
			}
		}
	}
}