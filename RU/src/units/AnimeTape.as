package units 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author ...
	 */
	/*Load.loading(Config.getIcon(App.data.storage[window.happiSid].type, 'border'), function(bitmap:*):void{
		var track:AnimeTape = new AnimeTape(bitmap.bitmapData, {width:360, height: 70});
		track.x = 150;
		track.y = 76 - track.height * .5;
		addChildAt(track, 0);
	});*/
	
	public class AnimeTape extends Sprite {
		public var settings:Object = {
			mask:{
				width:100,
				height:50
			},
			bitmapData:null
		}
		private var sprite:Sprite = new Sprite();
		private var bitmap:Bitmap;
		private var shape:Shape;
		private var bitmaps:Array = [];

		public function AnimeTape(bitmapData:BitmapData, mask:Object = null):void {
			settings.mask = mask;
			settings.bitmapData = bitmapData;

			addChild(sprite);
			
			var count:int = getBitmapCount(bitmapData.width)
			for (var i:int = 0; i < count; i++) {
				drawTrack(bitmapData);
			}
			
			drawMask();
			startAnimation();
		}
		
		//Расчет длины
		private function getBitmapCount(itemWidth:int):int {
			if ( itemWidth < settings.mask.width)
				return ((settings.mask.width * 2) / itemWidth);
				
			return 2;
		}
		
		//Отрисовка картинок
		private function drawTrack(bitmapData:BitmapData):void {
			var bitmap:Bitmap = new Bitmap(bitmapData);
			sprite.addChild(bitmap);
			bitmaps.push(bitmap);
			
			var pastBitmap:int = bitmaps.indexOf(bitmap) - 1;
			if(bitmaps[pastBitmap])
				bitmap.x = bitmaps[pastBitmap].x + bitmaps[pastBitmap].width;
		}
		
		//Отрисовка маски
		private function drawMask():void {
			shape = new Shape();
			shape.graphics.beginFill(0x000000, 0);
			shape.graphics.drawRect(0, 0, settings.mask.width, settings.mask.height);
			shape.graphics.endFill();
			sprite.mask = shape;
			addChild(shape);
			sprite.y = shape.y + (shape.height - sprite.height) * .5;
		}
		
		//Начало анимации
		private var tween:TweenLite;
		public function startAnimation():void {
			var item:* = bitmaps[0];
			
			sprite.x = 0;
			var to:int = item.x + item.width;
			tween = TweenLite.to(sprite, 
				speed(item.x, to), 
				{
					x : -to,
					ease:Linear.easeNone,
					onComplete:function():void {
						tween.kill();
						startAnimation();
					}
				}
			);
			
			function speed(from:int, to:int):Number {
				var long:Number = Math.sqrt(((to - from) * (to - from)));
				var time:Number = 100;
				var speed:Number = long / time;
				return speed;
			}
		}
		
		//Остановка анимации
		public function stopAnimation():void {
			if (tween)
				tween.kill();
		}
		
		public function dispose():void {
			stopAnimation();
			
			while (numChildren > 0) {
				var child:* = getChildAt(numChildren - 1);
				
				if (child.hasOwnProperty('dispose'))
					child.dispose();
				
				removeChild(child);
				child = null;
			}
		}
	}
}