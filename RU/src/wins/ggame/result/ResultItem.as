/**
 * Created by Andrew on 16.05.2017.
 */
package wins.ggame.result {
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import core.Numbers;
	import core.Size;

	import flash.display.Bitmap;
	import flash.text.TextField;

	import wins.Window;

	public class ResultItem extends LayerX
	{
		private const ITEM_WIDTH:int = 50;
		private const ITEM_HEIGHT:int = 50;

		private var _info:Object;
		private var _preloader:Preloader;
		private var _icon:Bitmap;
		private var _countText:TextField;
		private var _sid:int;
		private var _count:int;
		private var _bg:Bitmap;

		private var _borderColor:uint = 0x754122;
		private var _textColor:uint = 0xfefefe;

		private var _labelSettings:Object = {
			color		:0x773c18,
			borderColor	:0xffffff,
			fontSize	:35,
			multiline	:true,
			textAlign	:"left",
			wrap		:true,
			background	:false,
			width		:50
		}
		public function ResultItem(sid:int, count:int, params:Object = null)
		{
			_sid = sid;
			_count = count;
			_info = App.data.storage[sid];

			_borderColor = params.borderColor || 0x754122;
			_textColor = params.textColor || 0xfefefe;

			super();
			drawBg();
			drawIcon();
			drawCountText();
			drawTip();
		}
		private function drawCountText():void {
			_labelSettings.color        = _textColor;
			_labelSettings.borderColor  = _borderColor;

			_countText = Window.drawText('x' + _count.toString(), _labelSettings);
			
				addChild(_countText);
			_countText.x = _bg.width - _countText.width + 5;
			_countText.y = _bg.height - _countText.height;
		}
		private function drawBg():void 
		{
			_bg = new Bitmap(Window.backing(100, 100, 5, 'itemBacking').bitmapData);
			addChild(_bg);
		}
		private function drawTip():void {
			tip = function():Object {
				return {
					title:          _info.title,
					description:    _info.description
				};
			};
		}

		private function drawIcon():void {
			
			if (!_preloader) {
				_preloader = new Preloader();
				Size.size(_preloader, ITEM_WIDTH, ITEM_HEIGHT);
				_preloader.x = _preloader.width;
				_preloader.y = _preloader.height;
				addChild(_preloader);
			}

			if(_info.type == 'Material')
			{
				Load.loading(Config.getIcon(_info.type, _info.preview), onLoad);
			}
		}

		private function onLoad(data:Bitmap):void {
			if (!_icon)
			{
				_icon = new Bitmap();
				addChildAt(_icon,1);
			}
			
			if (_preloader && contains(_preloader)) {
				removeChild(_preloader);
				_preloader = null;
			}
			_icon.bitmapData = data.bitmapData;
			Size.size(_icon, ITEM_WIDTH, ITEM_HEIGHT, true);
			_icon.x = (_bg.width - _icon.width) / 2;
			_icon.y = (_bg.height - _icon.height) / 2;
		}

		public function dispose():void
		{
			if (_preloader && contains(_preloader)) {
				removeChild(_preloader);
				_preloader = null;
			}

			if(_icon && contains(_icon))
			{
				removeChild(_icon);
				_icon = null;
			}
		}
	}
}
