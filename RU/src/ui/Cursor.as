package ui 
{
	
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.text.TextField;
    import flash.ui.Mouse;
    import flash.ui.MouseCursorData;
    import flash.geom.Point;
    import flash.display.BitmapData;
	import units.Unit;
	import wins.StockWindow;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	public class Cursor 
	{
		private static var _type:String = "default";
		
		private static var cursorBitmapData:BitmapData;
		private static var cursorData:MouseCursorData;
		private static var cursorVector:Vector.<BitmapData> = new Vector.<BitmapData>();
		
		private static var types:Array = [ ];
		private static var icon:Bitmap = new Bitmap();
		
		public static var prevType:String = "default";
		public static var toStock:Boolean = false;
		
		private static var _accelerator:Boolean = false;
		
		private static var iconLabel:TextField;
		public static var moveMouseMargin:Point = new Point();
		
		//private static var effect:MovieClip = new clickEffect();
		
		public static function init():void
		{
			_type = prevType;//"default";
			
			var smallDefault:BitmapData = new BitmapData(22, 22, true, 0);
			smallDefault.draw(UserInterface.textures.cursorDefault, new Matrix(0.66, 0, 0, 0.66));
			
			types = [ 
					{type:"default", 		bmd:UserInterface.textures.cursorDefault},
					{type:"reset", 			bmd:UserInterface.textures.cursorDefault},
					{type:"move", 			bmd:UserInterface.textures.cursorMove},
					{type:"remove", 		bmd:UserInterface.textures.cursorRemove},
					{type:"locked", 		bmd:UserInterface.textures.cursorLocked},
					{type:"stock", 			bmd:UserInterface.textures.cursorStock },
					{type:"rotate", 		bmd:UserInterface.textures.cursorRotate},
					//{type:"woodCollect", 	bmd:UserInterface.textures.cursorWoodCollect},
					//{type:"buildingIn", 	bmd:UserInterface.textures.cursorBuildingIn},
					//{type:"stoneCollect", 	bmd:UserInterface.textures.cursorStoneCollect},
					{type:"take", 			bmd:UserInterface.textures.cursorTake},
					{type:"harvest", 		bmd:UserInterface.textures.cursorTake},
					{type:"water", 			bmd:UserInterface.textures.cursorFertilizer },
					//{type:"accelerator", 	bmd:UserInterface.textures.cursorAccelerator },
					{type:"boost", 			bmd:UserInterface.textures.cursorFertilizer }
				];
			
			for (var i:String in types)
			{
				cursorVector[0] = types[i].bmd;
				
				cursorData = new MouseCursorData();
				cursorData.hotSpot = new Point(1, 1);
				cursorData.data = cursorVector;
             
				Mouse.registerCursor(types[i].type, cursorData);
			}
			
			Mouse.cursor = _type;
		}
		
		public static function get type():String
		{
			return _type
		}
		
		public static function set image(value:*):void
		{
			if (icon.bitmapData) 
			{
				App.self.setOffEnterFrame(move);
				App.self.contextContainer.removeChild(icon);
				icon.bitmapData = null;
				icon.filters = null;
			}
						
			if (value) 
			{
				/*if (value == Cursor.AXE || value == Cursor.PICK || value == Cursor.BACKET) 
				{
					moveMouseMargin = new Point(10, 10);
				}else{*/
					moveMouseMargin = new Point();
				//}
				
				icon.bitmapData = UserInterface.textures[value];
				icon.x = App.self.mouseX + moveMouseMargin.x;
				icon.y = App.self.mouseY + moveMouseMargin.y;
				icon.scaleX = icon.scaleY = 1;
				icon.smoothing = true;
				
				App.self.contextContainer.addChild(icon);
				App.self.setOnEnterFrame(move);
			}
		}
		
		public static function get image():* 
		{
			return icon.bitmapData == null ? null : icon;
		}
		
		public static function set type(type:String):void
		{
			try {
				if(type == "locked" && _type != "locked")
					prevType = _type;
				else if(prevType == "locked")	
					prevType = "default";
				
				if (type != "locked" && prevType!="remove")
					prevType = type;	
					
				_type = type;
				Mouse.cursor = _type;
			}catch (e:Error) {
				
			}
		}
		
		public static function set material(value:*):void
		{
			/*if (icon.bitmapData) 
			{
				App.self.setOffEnterFrame(move);
				App.self.contextContainer.removeChild(icon);
				icon.bitmapData = null;
				icon.filters = null;
			}*/
			
			if (value)
			{
				moveMouseMargin = new Point();
				
				Load.loading(Config.getIcon("Material", App.data.storage[value].preview),
					function(data:Bitmap):void 
					{
						var iconN:Bitmap = new Bitmap(data.bitmapData);
						iconN = new Bitmap(Window.textures.chestCheckMark);
						Size.size(iconN, 30, 30);
						iconN.smoothing = true;
						
						cursorVector[0] = iconN.bitmapData;
				
						cursorData = new MouseCursorData();
						cursorData.hotSpot = new Point(1, 1);
						cursorData.data = cursorVector;
					 
						Mouse.registerCursor("material", cursorData);
						Mouse.cursor = 'material';
					}
				);
				
				//App.self.contextContainer.addChild(icon);
				//App.self.setOnEnterFrame(move);
				//
				//if (iconLabel && App.self.contextContainer.contains(iconLabel))
					//App.self.contextContainer.removeChild(iconLabel);
				//
				//iconLabel = Window.drawText('', {
					//fontSize:		20,
					//autoSize:		'left',
					//color:			0xfefefe,
					//borderColor:	0x754122
				//});
				//App.self.contextContainer.addChild(iconLabel);
			}
		}
		
		public static function get material():* 
		{
			return icon.bitmapData == null ? null : icon;
		}
		
		public static function set plant(value:*):void
		{
			if (icon.bitmapData) 
			{
				App.self.setOffEnterFrame(move);
				App.self.contextContainer.removeChild(icon);
				icon.bitmapData = null;
			}
			
			if (value)
			{
				//icon = new Bitmap();
				/*for (var sd:* in App.data.storage[value].outs) {
						if ((sd == Stock.COINS&&App.self.getLength(App.data.storage[value].outs)>1)) 
						{
						}else 
						{
						break;	
						}
						
					}
					
				Load.loading(Config.getIcon("Material", App.data.storage[sd].preview),
					
					function(data:Bitmap):void
					{
						icon.bitmapData = data.bitmapData;
						icon.scaleX = icon.scaleY = 0.5;
						icon.smoothing = true;
					}
				);
					
				App.self.contextContainer.addChild(icon);
				App.self.setOnEnterFrame(move);*/
				
				var info:Object = App.data.storage[value];
				if (info.hasOwnProperty('outs') && App.self.getLength(info.outs) > 1) 
				{
					for (var sd:* in info.outs) 
					{
						if (sd != Stock.COINS) 
						{
							info = App.data.storage[sd];
							break;	
						}
					}
				}
				
				Load.loading(Config.getIcon(info.type, info.preview), function(data:Bitmap):void 
				{
					icon.bitmapData = data.bitmapData;
					icon.scaleX = icon.scaleY = 0.5;
					icon.smoothing = true;
				});
				
				App.self.contextContainer.addChild(icon);
				App.self.setOnEnterFrame(move);
			}
		}
		
		public static function get plant():* 
		{
			return icon.bitmapData == null ? null : icon;
		}
		
		private static var _loading:Boolean = false;
		private static var preloader:Preloader = new Preloader();
		public static function set loading(loading:Boolean):void 
		{
			if (_loading == loading) return;
			
			if (loading) 
			{
				preloader.scaleX = preloader.scaleY = 0.7;
				App.self.contextContainer.addChild(preloader);
				App.self.setOnEnterFrame(moveLoader);
			}else
			{
				App.self.setOffEnterFrame(moveLoader);
				App.self.contextContainer.removeChild(preloader);
			}
			_loading = loading;
		}
		
		public static function get loading():Boolean 
		{
			return _loading;
		}
		
		static public function get accelerator():Boolean 
		{
			return _accelerator;
		}
		
		static public function set accelerator(value:Boolean):void 
		{
			_accelerator = value;
			
			if (!_accelerator && StockWindow.accelUnits)
			{
				for each (var unit:Unit in StockWindow.accelUnits) 
				{
					unit.hideGlowing();
				}
				StockWindow.accelUnits = [];
			}
		}
		
		private static function moveLoader(e:Event = null):void 
		{
			preloader.x = App.self.mouseX;
			preloader.y = App.self.mouseY;
		}
		
		private static function move(e:Event = null):void
		{
			icon.x = App.self.mouseX;
			icon.y = App.self.mouseY;
		}
		
		public static function click():void
		{
			//new Click();
		}
	}
}
/*import flash.events.Event;

internal class Click extends clickEffect
{
	public function Click()
	{
		App.self.addChild(this);
		this.x = App.self.mouseX;
		this.y = App.self.mouseY;
		
		addEventListener(Event.ENTER_FRAME, check);
	}
	
	private function check(e:Event):void
	{
		if (this.currentFrame == this.totalFrames) {
			removeEventListener(Event.ENTER_FRAME, check);
			remove();
		}
	}
	
	private function remove():void
	{
		App.self.removeChild(this);
	}
}*/
  