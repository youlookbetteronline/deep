package wins.elements 
{
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author ...
	 */
	public class BlickBitmap extends LayerX
	{
		
		[Embed(source="/blick_bitmap.png", mimeType="image/png")]
		private var Blick_Bitmap:Class;
		private var blickBMD:BitmapData = new Blick_Bitmap().bitmapData;
		
		private var preloader:Preloader = new Preloader();
		public var bitmap:Bitmap;
		private var callback:Function;
		public function BlickBitmap() 
		{
			
			//addBlick();
			bitmap = new Bitmap();
			addChild(bitmap);
			
			//addChild(preloader);
			//preloader.x = (background.width)/ 2;
			//preloader.y = (background.height)/ 2 - 15;
			
			//var round:Sprite = new Sprite();
			//addChild(round);
			//round.graphics.beginFill(0xFFFFFF, 1);
			//round.graphics.drawCircle(0, 0, 2);
			//round.graphics.endFill();
		}
		
		public function load(item:Object, callback:Function):void {
			this.callback = callback;
			Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
		}
		
		private var blick:Bitmap = new Bitmap();
		private var maska:Bitmap = new Bitmap();
		public function addBlick():void {
			
			if (maska == null)
				return;
			
			blick.bitmapData = blickBMD;
			addChild(blick);
			blick.x = bitmap.x;
			blick.y = bitmap.y;
			blick.blendMode = BlendMode.OVERLAY;
			blick.width = maska.width + 10;
			blick.rotation =  - 25 + Math.random() * -10;
			
			
			blick.cacheAsBitmap = true;
			maska.cacheAsBitmap = true;
			blick.mask = maska;
			
			randomTime = 1000 + int(1000 * Math.random());
			var firstRandomTime:int = 100 + int(1000 * Math.random());
			setTimeout(startBlick, firstRandomTime);
		}
		
		private var timer:uint = 0;
		private var randomTime:int;
		private function startBlick():void {
			blick.y = maska.y -5;
			TweenLite.to(blick, 3, {y:maska.height, onComplete:pauseBlick, ease:Strong.easeOut})
		}
		
		private function pauseBlick():void {
			timer = setTimeout(startBlick, randomTime);
		}
		
		private function stopBlick():void {
			if (timer > 0) {
				clearTimeout(timer);
				timer = 0;
			}
		}
		
		public function onPreviewComplete(data:Bitmap):void
		{
			if(preloader && preloader.parent)
			removeChild(preloader);
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			
			bitmap.x = - bitmap.width / 2;
			bitmap.y = - bitmap.height / 2;
			
			maska = new Bitmap(data.bitmapData);
			addChild(maska);
			maska.x = bitmap.x;
			maska.y = bitmap.y;
			addBlick();
			
			if (callback != null)
				callback();
		}
		
	}

}