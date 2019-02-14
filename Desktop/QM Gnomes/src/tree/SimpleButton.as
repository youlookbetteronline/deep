package tree 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author ...
	 */
	
	public class SimpleButton extends LayerX
	{
		private var bitmap:Bitmap;
		public var settings:Object;
		public function SimpleButton(bitmapData:BitmapData, _settings:Object = null) 
		{
			this._bitmapData = bitmapData;
			if (_settings == null) {
				_settings = new Object();
			}
			settings = _settings
			settings["widthButton"] = settings.widthButton || bitmapData.width;
			settings["heightButton"] = settings.heightButton || bitmapData.height;
			
			settings["scaleX"] = settings.scaleX == undefined?1:settings.scaleX;
			settings["scaleY"] = settings.scaleY == undefined?1:settings.scaleY;
			
			mouseChildren = false;
			drawBottomLayer();
		}
		public var _bitmapData:BitmapData;
		public function set bitmapData(bmd:BitmapData):void
		{
			_bitmapData = bmd;
			bitmap.bitmapData = _bitmapData;
			bitmap.smoothing = true;
			bitmap.x =  0;
			bitmap.y = 0;
		}
		protected function drawBottomLayer():void {
			bitmap = new Bitmap(_bitmapData,"auto",true)
			bitmap.x = 0;
			bitmap.y = 0;
						
			bitmap.scaleX = settings.scaleX;
			if(settings.scaleX < 0){
				bitmap.x += -bitmap.width * settings.scaleX;
			}
		
			bitmap.scaleY = settings.scaleY;
			if(settings.scaleY < 0){
				bitmap.y += -bitmap.height * settings.scaleY;
			}
			addChild(bitmap);
		}	
	}

}