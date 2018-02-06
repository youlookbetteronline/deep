package ui
{
	import buttons.SimpleButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import units.Field;
	import wins.Window;
	
	public class Cloud extends SimpleButton
	{
		public static const HAND:String 			= "hand";
		public static const SPRING_WATER:String 	= "spring_water";
		public static const TRIBUTE:String 			= "coin";
		public static const PICK:String 			= "pick";
		public static const EFIR:String 			= "efir";
		public static const NEED_REPAIR:String 		= "needRepair";
		public static const AVATAR:String 			= "avatar";
		public static const WATERPITCHER:String 	= "waterPitcher";
		public static const WATER:String 			= "water";
		public static const CRISTAL:String 			= "cristal";
		public static const CONSTRUCTING:String 	= "constructing";
		public static const TECHNO:String 			= "techno";
		public static const GOLDEN:String 			= "golden";
		public static const COOKIE:String 			= "cookie";
		public static const HONEYCOMB:String 		= "honeycomb";
		public static const CRYSTALWATER:String 	= "crystal_water";
		
		public var bg:Bitmap;
		public var bitmap:Bitmap;		
		public var test:Object = { };
		public var params:Object = { };
		
		private var _callBack:Function = null;
		
		public function Cloud(type:String, params:Object = null, isRotate:Boolean = false, callBack:Function = null)
		{			
			this.callBack = callBack;
			
			if (callBack == null && params.target.sid == 176 ) 
			{
				test = callBack;
			}
			
			if(params) 
				this.params = params;
			
			if (params && params.roundBg) 
				bg = new Bitmap(Window.textures.productBacking2);
			else {				
				bg = new Bitmap(Window.textures.productBacking);
				bg.alpha = 0;
			}
			
			bitmap = new Bitmap(Cloud.takeIcon(type, params));			
			bitmap.x = (bg.width - bitmap.width) / 2;
			bitmap.y = 5;
			bitmap.smoothing = true;
			
			if (type == CONSTRUCTING)
			{
				bitmap.scaleX = bitmap.scaleY = 0.9;
				bitmap.x += 4;
				bitmap.y += 5;
				bg.alpha = 1;
			}
			
			if (type == COOKIE)
			{
				bitmap.scaleX = bitmap.scaleY = 0.9;
				bitmap.x += 4;
				bitmap.y += 5;
				bitmap.alpha = .6;
				bg.alpha = .6;
				if (params && params.addGlow) 
					addGlow(Window.textures.iconEff, .7, .8);
			}
			
			if (type == HAND) 
			{
				bitmap.x += 8; 
				bitmap.y -= 12;
				
				if (params && params.addGlow) 
					addGlow(Window.textures.iconEff, .7, .8);
			}
			
			if (isRotate) 
			{
				bitmap.scaleX = -1;
				bitmap.x += bitmap.width;
				if (type == HAND)
				{
					bitmap.x -= 16;
				}
			}
			
			if (type == WATER || type == SPRING_WATER || type == HONEYCOMB|| type == CRYSTALWATER)
			{
				bitmap.x = bg.x + 0;
				bitmap.y = bg.y + 10;
				bitmap.scaleX = bitmap.scaleY = 0.6; 
				addGlow(Window.textures.iconEff, .7, .6);
				if (isRotate)
				{
					bitmap.scaleX = -bitmap.scaleX;
					bitmap.x += bitmap.width;
				}
			}
			
			if (type == GOLDEN) 
			{
				bitmap.x = bg.x + 10;
				addGlow(Window.textures.iconEff, .7, .6);
				bitmap.scaleX = bitmap.scaleY = 0.6;
			}
			
			if (type == TRIBUTE)
			{
				bitmap.y = bg.y + 40;
				addGlow(Window.textures.iconEff, .7, .6);
			}
			
			if (params && params.hasOwnProperty('target'))
			{
				if (params.target.hasProduct) 
				{
					bitmap.y += 10;
				}
			}
			
			addChildAt(bg, 0);
			addChild(bitmap);			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.MOUSE_MOVE, mMove);
		}
		
		public function debug(container:*, color:uint = 0x000000):void 
		{
			container.graphics.lineStyle(2, color, 1, true);
			container.graphics.drawRoundRect(2, 2, container.width, container.height, 10);
			container.graphics.endFill();
		}
		
		private function mMove(e:MouseEvent):void 
		{
			App.map.untouches();
			e.stopImmediatePropagation();
			e.stopPropagation();
		}
		
		private function onClick(e:MouseEvent):void 
		{
			if (App.user.quests.tutorial)
			{
				if (params && params.hasOwnProperty('target') && App.user.quests.currentTarget == params.target)
				{
					params.target.click();
					//App.tutorial.hide();
					params.target.hideGlowing();
				}
				return;
			}
			
			if (this.callBack != null)
				this.callBack();
			e.stopPropagation();
			e.stopImmediatePropagation();
		}
		
		public function addGlow(bmd:BitmapData, layer:int, scale:Number = 1):void
		{
			var btm:Bitmap = new Bitmap(bmd);
			container = new Sprite();
			container.addChild(btm);
			btm.scaleX = btm.scaleY = scale;
			btm.smoothing = true;
			btm.x = -btm.width / 2;
			btm.y = -btm.height / 2;
			
			addChild(container);
			
			container.mouseChildren = false;
			container.mouseEnabled = false;
			
			container.x = bg.x +bg.width / 2;
			container.y = bg.y +bg.height / 2;
			this.startGlowing();
			
			var that:* = this;
			startInterval = setInterval(function():void {
				clearInterval(startInterval);
				interval = setInterval(function():void {
					that.pluck();
				}, 10000);
			}, int(Math.random() * 3000));			
		}
		
		private var container:Sprite = new Sprite();
		
		public function doIconEff():void
		{			
			var _scale:Number = 0.8;
			var _effScale:Number = 0.7;
			addGlow(Window.textures.iconEff, 0, _effScale);			
		}
		
		private var interval:int = 0;
		private var startInterval:int = 0;
		
		private function rotateBtm(e:Event):void 
		{
			container.rotation += 1;
		}
		
		public static function takeIcon(type:String, params:Object = null):BitmapData
		{
			switch(type)
			{
				case "honeycomb":
					return UserInterface.textures.honeycomb;
				case "spring_water":
					return Window.textures.springWater;
				case "crystal_water":
					return UserInterface.textures.crystal_water;
				case "hand":
					return Window.textures.checkMarkBig;
				case "coin":
					return UserInterface.textures.goldenPearl;
				case PICK:
					return UserInterface.textures.handIco;
				case "water":
					return UserInterface.textures.waterIcon;
				case "cristal":
					return Window.textures.gem;	
				case "efir":
					return UserInterface.textures.energyIcon;	
				case "constructing":
					return Window.textures.buildIco;	
				case "avatar":
					return null;
				case "golden":
					return UserInterface.textures.expIco;
				case "cookie":
					return UserInterface.textures[App.data.storage[App.data.storage[App.user.worldID].cookie[0]].view];
				case TECHNO:
					return null;				
					default :
					return UserInterface.textures.goldenPearl;
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			removeEventListener(MouseEvent.CLICK, onClick);
			App.self.setOffEnterFrame(rotateBtm);
			this.hideGlowing();
		}
		
		public function get callBack():Function 
		{
			return _callBack;
		}
		
		public function set callBack(value:Function):void 
		{
			_callBack = value;
		}
	}	
}