package wins 
{
	import core.Load;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class MaterialIcon extends LayerX 
	{
		private var _sid:int;
		private var _useCount:Boolean;
		private var _fishTip:Boolean;
		private var _count:int;
		private var _size:int;
		private var _customIcon:BitmapData;		
		private var _iconContainer:LayerX;
		private var _textCount:TextField;
		private var _iconBitmap:Bitmap;
		private var _countSize:int;		
		private var _fishSid:int;		
		private var _preloader:Preloader;
		
		public var _bitmap:Bitmap;
		
		public function get sid():int 
		{
			return _sid;
		}
		
		public function set sid(value:int):void 
		{
			_sid = value;
			loadIcon();
		}		
		
		public function get useCount():Boolean 
		{
			return _useCount;
		}
		
		public function set useCount(value:Boolean):void 
		{
			_useCount = value;
			drawCount();
		}
		
		public function get count():int 
		{
			return _count;
		}
		
		public function set count(value:int):void 
		{
			_count = value;
			drawCount();
		}		
		
		public function get size():int 
		{
			return _size;
		}
		
		public function set size(value:int):void 
		{
			_size = value;
			updateSize();
		}
		
		public function get iconBitmap():Bitmap 
		{
			return _iconBitmap;
		}
		
		public function set iconBitmap(value:Bitmap):void 
		{
			onIconLoaded(value);
		}		
		
		public function MaterialIcon(sid:int, useCount:Boolean = false, count:int = 1, size:int = 50, countSize:int = 20, customIcon:BitmapData = null, fishTip:Boolean = false, fishSid:int = 0) 
		{
			super();
			
			_sid = sid;
			_count = count;
			_size = size;
			_useCount = useCount;
			_countSize = countSize;
			_customIcon = customIcon;
			_fishTip = fishTip;
			_fishSid = fishSid;
			
			draw();
			//showTip();
			
			/*tip = function():Object
			{
				var info:Object = App.data.storage[sid];
				return { title:info.title, text:info.description };
			};*/
		}
		
		private function draw():void
		{
			_iconContainer = new LayerX();
			addChild(_iconContainer);
			_preloader = new Preloader();
			_preloader.x = size * 0.5;
			_preloader.y = size * 0.5;
			_iconContainer.addChild(_preloader);
			loadIcon();
		}
		
		private function loadIcon():void
		{
			if (_iconContainer.numChildren > 0)
			{
				_iconContainer.removeChildren();
			}
			
			_iconContainer.scaleX = _iconContainer.scaleY = 1;
			
			var info:Object = App.data.storage[sid];
			
			if (info && !_customIcon)
			{
				Load.loading(Config.getIcon(info.type, info.preview), onIconLoaded);
			}else if (_customIcon)
			{
				if (!_iconBitmap)
					_iconBitmap = new Bitmap(_customIcon);
				else
					_iconBitmap.bitmapData = _customIcon;
					
				_iconContainer.addChild(_iconBitmap);
				updateSize();
				drawCount();
			}
		}
		
		private function onIconLoaded(data:Bitmap):void
		{
			var info:Object = App.data.storage[sid];
			
			if (!_iconBitmap)
				_iconBitmap = new Bitmap(data.bitmapData);
			else
				_iconBitmap.bitmapData = data.bitmapData;
				
			_iconContainer.addChild(_iconBitmap);
			updateSize();
			drawCount();
			
			/*_iconContainer.tip = function():Object { 
				return {
					title:info.title,
					text:info.description
				};
			};*/
			
			if (_fishTip) 
			{
				_iconContainer.tip = function():Object
				{
					
					
					_bitmap = new Bitmap();	
					var count1:uint = 0;
					
					if (_fishTip) 
					{
						Load.loading(Config.getIcon(App.data.storage[_fishSid].type, App.data.storage[_fishSid].preview),
						function(data:Bitmap):void
						{
							if (_bitmap)
							{
								_bitmap.bitmapData = data.bitmapData;
								Size.size(_bitmap, 40, 40);
							}
						});	
					}else 
					{
						Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview),
						function(data:Bitmap):void
						{
							if (_bitmap)
							{
								_bitmap.bitmapData = data.bitmapData;
								Size.size(_bitmap, 40, 40);
							}
						});	
					}
					
					return {
						title: info.title,
						desc: Locale.__e('flash:1473802659364') + " ",
						count1: "",
						icon: _bitmap,
						iconScale: _bitmap.scaleX,
						addDesc:""
					};
				}
			}
		}
		
		private function updateSize():void
		{
			Numbers.size(_iconContainer, size, size);
			_iconBitmap.smoothing = true;
			drawCount();
		}
		
		private function drawCount():void
		{
			if (!_textCount)
			{
				_textCount = Window.drawText("x" + count.toString(), {
					fontSize:_countSize,
					size:_countSize,
					width:_countSize * (count.toString().length + 1),
					textAlign:"left",
					color:0xFFFEFF,
					borderColor:0x5E5D5B
				});
				
				_textCount.width = _textCount.textWidth + 5;
				_textCount.x = size - _textCount.width * 1.5;
				_textCount.y = size - _textCount.textHeight;
				this.addChild(_textCount);
			}
			else
			{
				_textCount.text = "x" + count.toString();
				_textCount.width = _textCount.textWidth + 5;
			}
			
			_textCount.visible = useCount;
		}
		
		/*private function showTip():Object
		{
			var info:Object = App.data.storage[sid];
			return { title:info.title, text:info.description };
		}*/
	}
}