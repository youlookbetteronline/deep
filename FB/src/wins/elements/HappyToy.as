package wins.elements 
{
	import buttons.Button;
	import buttons.ImageButton;
	import com.greensock.TweenLite;
	import core.AvaLoad;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import wins.Window;
	
	public class HappyToy extends LayerX 
	{
		
		public static const FREE:uint = 0;
		public static const MOVE:uint = 1;
		public static const BLOCK:uint = 2;
		
		
		public var preloader:Preloader;
		public var bitmap:Bitmap;
		public var closeBttn:ImageButton;
		
		public var mode:uint = 0;
		
		public var id:*;
		public var sID:*;
		public var uID:*;
		public var info:Object;
		public var window:*;
		private var scale:Number = 0.5;
		
		private var avaCont:Sprite;
		
		public function HappyToy(id:*, object:*, window:*) 
		{
			this.id = id;
			this.sID = object.mID;
			this.uID = object['uID'];
			this.window = window;
			info = App.data.storage[this.sID];
			
			x = object.x;
			y = object.y;
			
			
			preloader = new Preloader();
			addChild(preloader);
			
			bitmap = new Bitmap();
			addChild(bitmap);
			Load.loading(Config.getIcon(info.type, info.preview), onLoad);
			
			closeBttn = new ImageButton(Window.textures.closeBttnSmall);
			closeBttn.scaleX = closeBttn.scaleY = 0.65;
			closeBttn.x = -closeBttn.width / 2;
			closeBttn.y = -closeBttn.height / 2 + 50;
			closeBttn.addEventListener(MouseEvent.CLICK, onRemove);
			addChild(closeBttn);
			closeBttn.visible = false;
			
			drawAva();
			
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
		}
		
		private function onOver(e:MouseEvent):void {
			if (mode != FREE) return;
			
			closeBttn.visible = true;
			
			if (timeout == 0) {
				timeout = setTimeout(showAva, 500);
			}
		}
		private function onOut(e:MouseEvent):void {
			closeBttn.visible = false;
			
			hideAva();
		}
		
		private var timeout:int = 0;
		public var ava:Bitmap;
		private function showAva():void {
			timeout = 0;
			
			if (closeBttn.visible && App.user.friends.data.hasOwnProperty(uID)) {
				avaCont.alpha = 0;
				
				if (!ava.bitmapData) {
					new AvaLoad(App.user.friends.data[uID].photo, onAvaLoad);
				}
				
				TweenLite.to(avaCont, 0.3, {alpha:1} );
			}
		}
		private function hideAva():void {
			if (timeout) {
				clearTimeout(timeout);
				timeout = 0;
			}
			
			TweenLite.to(avaCont, 0.3, {alpha:0} );
		}
		private function drawAva():void {
			avaCont = new Sprite();
			avaCont.x = 10;
			avaCont.y = -40;
			addChild(avaCont);
			
			ava = new Bitmap();
			avaCont.addChild(ava);
		}
		private function onAvaLoad(data:Bitmap):void {
			
			ava.bitmapData = data.bitmapData;
			ava.width = ava.height = 50;
			
			var maska:Shape = new Shape();
			maska.graphics.beginFill(0xba944d, 1);
			maska.graphics.drawRoundRect(0, 0, 50, 50, 15, 15);
			maska.graphics.endFill();
			avaCont.addChild(maska);
			
			ava.mask = maska;
			
			//image.x = imageBack.x + (imageBack.width - image.width) / 2;
			//image.y = imageBack.y + (imageBack.height - image.height) / 2;
		}
		
		
		public function onLoad(data:Bitmap):void {
			removeChild(preloader);
			preloader = null;
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.scaleX = bitmap.scaleY = scale;
			bitmap.smoothing = true;
			bitmap.x = -bitmap.width / 2;
			bitmap.y = 0;
			
		}
		
		private function onRemove(e:MouseEvent):void {
			if (closeBttn.mode == Button.NORMAL && App.user.mode == User.OWNER)
				window.onToyRemove(this);
		}
		
		public function dispose():void {
			closeBttn.removeEventListener(MouseEvent.CLICK, onRemove);
			closeBttn.dispose();
			closeBttn = null;
			
			removeEventListener(MouseEvent.ROLL_OVER, onOver);
			removeEventListener(MouseEvent.ROLL_OUT, onOut);
			
			if (parent) parent.removeChild(this);
		}
		
	}

}