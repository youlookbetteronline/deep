package units 
{
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.Hints;
	import ui.UnitIcon;
	import wins.ShopWindow;
	import wins.WindowButtons;
	
	public class Pest extends Box 
	{
		public var alive:Boolean = true;
		public var bSID:int;
		public var bID:int;
		public var bType:String;
		
		public function Pest(object:Object) 
		{
			super(object);	
			
			bSID = object.buildingSid;
			bID = object.buildingID;
			bType = object.buildingType;
			
			tip = function():Object
			{
				var _bitmap:Bitmap = new Bitmap();
				var count1:uint = 0;	
				var count2:uint = 0;	
				var countter:int = 0;
				var sID:int = Numbers.firstProp(info['in']).key;
				
				if (App.data.storage.hasOwnProperty(sID) && App.data.storage[sID].mtype != 3)
				{
					Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview),
					function(data:Bitmap):void
					{
						if (_bitmap)
						{
							_bitmap.bitmapData = data.bitmapData;
							Size.size(_bitmap, 40, 40);
						}
						
					});
				}
				
				count1 = Numbers.firstProp(info['in']).val;
				
				return {
					title: info.title,
					text: info.description, 
					desc: Locale.__e('flash:1409654204888'),
					count1: "x"+count1,
					icon: _bitmap,
					iconScale: _bitmap.scaleX
				};
			};
			
			//saySomething();
		}
		
		public function saySomething():void
		{			
			var wordsArray:Array = ["0ooOo0"];			
			var randint:Number = int(Math.random() * wordsArray.length);			
			var word:String = wordsArray[randint];
			
			this.drawIcon(UnitIcon.DIALOG, 0, 0, {
				fadein:			true,
				hidden:			true,
				hiddenTimeout:	3 * 1000,
				text:			"" + word,
				iconDY:			-10,
				textSettings:	{
					color:			0xfffef4,
					borderColor:	0x11243e,
					textAlign:		'center',
					autoSize:		'center',
					fontSize:		24,
					shadowSize:		1.5
				}
			});
			
			dialogTimeout = setTimeout(saySomething, 3000 + Math.random()*2000);
		}
		
		private var dialogTimeout:uint = 0;
		public var price:Object = { };
		public var weaponSID:int;				
		public var weaponCount:int;
		
		override public function click():Boolean 
		{
			if (!clickable || id == 0) return false;
			
			App.tips.hide();
			
			if (App.user.mode == User.OWNER)
			{			
				price = info['in'];				
				weaponSID = Numbers.firstProp(price).key;				
				weaponCount = Numbers.firstProp(price).val;	
				
				if (!App.user.stock.checkAll(price))
				{
					ShopWindow.findMaterialSource(weaponSID);
					return false;
				}
				
				ordered = true;
				storageEvent();
			}
			
			return true;			
		}
		
		override public function storageEvent():void
		{
			if (App.user.mode == User.OWNER) 
			{				
				if (!App.user.stock.takeAll(price))	return;
				Hints.minus(weaponSID, weaponCount, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y), true);
				
				//var type:String = String(bType);
				
				var postObject:Object = {
					ctr:bType,
					act:'pest',
					uID:App.user.id,
					id:bID,
					wID:App.user.worldID,
					sID:bSID
				}
				
				Post.send(postObject, onStorageEvent);
			}
		}		
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (data.bonus != null)
				Treasures.packageBonus(data.bonus, new Point(this.x, this.y));
			
			uninstall();
			alive = false;
		}		
	}
}