package buttons 
{
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import core.Size;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import com.greensock.*
	import wins.Window;
	
	
	public class ContextBttn extends Sprite {
		
		private var backing:Shape;
		public var iconBitmap:Bitmap;
		public var textLabel:TextField;
		private var itemBg:Bitmap;
		
		public var settings:Object = {
			height:		50,
			caption:	''
		};
		
		public var sid:uint;
		
		public function ContextBttn(settings:Object = null) 
		{
			if (settings == null) settings = { };
			for (var s:* in settings)
				this.settings[s] = settings[s];
			
			sid = settings.sid;
			
			draw();
			
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
		}
		
		protected function draw():void {
			
			textLabel = Window.drawText(settings.caption, {
				color:			0xfffff4,
				borderColor:	0x0e4b8b,
				borderSize:		2,
				fontSize:		14,
				autoSize:		'left',
				shadowSize:		1
			});
			textLabel.x = settings.height - 17;
			textLabel.y = (settings.height - textLabel.height) / 2 + 20;
			itemBg = new Bitmap(Window.textures.plantBar);	
			
			itemBg.x = textLabel.x - 40;
			itemBg.y = textLabel.y - 12;
			iconBitmap = new Bitmap();
			if (App.data.storage.hasOwnProperty(sid))
				Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), onLoad);
			
			
			
			
				
			/*var backing:Shape = new Shape();
			backing.graphics.beginFill(0xcb9d6b, 1);
			backing.graphics.drawCircle(settings.height / 2, settings.height / 2, settings.height / 2);
			backing.graphics.endFill();
			
			backing.graphics.beginGradientFill(GradientType.LINEAR, [0x013966, 0x3a76b0], [1, 1], [124, 255]);
			backing.graphics.drawRoundRect(textLabel.x - 20, 9, textLabel.width + 30, settings.height - 18, settings.height - 18, settings.height - 18);
			backing.graphics.endFill();
			backing.filters = [new DropShadowFilter(2, 90, 0x000000, 0.4, 1, 1), new BevelFilter(2, 90, 0xd5b15d, 1, 0x5f4723, 1)];
			
			var backing2:Shape = new Shape();
			backing2.graphics.beginFill(0xcfc5bc, 1);
			backing2.graphics.drawCircle(settings.height / 2, settings.height / 2 - 1, (settings.height - 6) / 2);
			backing2.graphics.endFill();
			backing2.filters = [new DropShadowFilter(1, 90, 0x000000, 0.4, 1, 1), new BevelFilter(2, 90, 0xb6914b, 1, 0xffffff, 0.2, 1, 1)];*/
			
			//addChild(backing);
			//addChild(backing2);
			addChild(itemBg);
			addChild(iconBitmap);
			addChild(textLabel);
			
		}
		
		private function onLoad(data:Bitmap):void {
			iconBitmap.bitmapData = data.bitmapData;
			iconBitmap.smoothing = true;
			Size.size(iconBitmap, settings.height - 15, settings.height - 15);
			iconBitmap.x = itemBg.x + 3;
			iconBitmap.y = itemBg.y;
		}
		
		private function onOver(e:MouseEvent):void {
			Effect.light(this, 0.15);
		}
		private function onOut(e:MouseEvent):void {
			Effect.light(this, 0);
		}
		
		public function dispose():void {
			removeEventListener(MouseEvent.ROLL_OVER, onOver);
			removeEventListener(MouseEvent.ROLL_OUT, onOut);
		}
	}

}