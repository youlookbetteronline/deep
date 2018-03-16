package wins.elements 
{
	import core.Load;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.text.TextField;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class BubbleItem extends LayerX 
	{
		private var _settings:Object = {
			width			:110,
			height			:116,
			bgSettings		:{
				texture:	'yellowSquareBacking',
				textureTop:	'yellowWhiteBackingTop',
				textureBot:	'yellowWhiteBackingBot',
				padding:	30
			},
			titleSettings	:{
				color		:0xffffff,
				borderColor	:0x6e411e,
				fontSize	:24,
				borderSize	:3
			},
			counterSettings	:{
				color		:0xffffff,
				borderColor	:0x6e411e,
				fontSize	:28,
				borderSize	:3
			},
			iconSettings	:{
				width		:75,
				height		:75
			}
		}
		
		private var _sid:int;
		private var _count:int;
		private var _info:Object;
		
		private var _background:Bitmap;
		private var _icon:Bitmap;
		private var _title:TextField;
		private var _counter:TextField;
		
		public function BubbleItem(item:Object = null, settings:Object = null) 
		{
			for (var property:* in settings)
			{
				_settings[property] = settings[property];
			}
			_sid = Numbers.firstProp(item).key;
			_count = Numbers.firstProp(item).val;
			_info = App.data.storage[_sid];
			
			drawBackground();
			drawTitle();
			drawCounter();
			drawIcon();
			
			build();
			
			this.tip = function():Object{
				return {
					title	:_info.title,
					text	:_info.description
				}
			}
		}
		
		private function drawBackground():void 
		{
			if (_settings.bgSettings.textureTop && _settings.bgSettings.textureTop != "")
				_background = Window.backing2(_settings.width, _settings.height, _settings.bgSettings.padding, _settings.bgSettings.textureTop, _settings.bgSettings.textureBot);
			else if (_settings.bgSettings.texture && _settings.bgSettings.texture != "")
				_background = Window.backing(_settings.width, _settings.height, _settings.bgSettings.padding, _settings.bgSettings.texture)
				
		}
		
		private function drawIcon():void 
		{
			Load.loading(Config.getIcon(_info.type, _info.preview), onLoad);
		}
		
		private function onLoad(data:Bitmap):void 
		{
			_icon = new Bitmap(data.bitmapData);
			addIcon();
		}
		
		private function addIcon():void 
		{
			if (_icon && _icon.parent)
				_icon.parent.removeChild(_icon);
			Size.size(_icon, _settings.iconSettings.width, _settings.iconSettings.height);
			_icon.smoothing = true;
			_icon.x = (WIDTH - _icon.width) / 2;
			_icon.y = (HEIGHT - _icon.height) / 2;
			addChild(_icon);
			addCounter();
		}
		
		private function drawTitle():void 
		{
			_title = Window.drawText(_info.title, {
				color			:_settings.titleSettings.color,
				borderColor		:_settings.titleSettings.borderColor,
				borderSize		:_settings.titleSettings.borderSize,
				fontSize		:_settings.titleSettings.fontSize,
				width			:WIDTH,
				autoSize		:'center',
				textAlign		:'center',
				multiline		:true,
				wrap			:true
			})
		}
		
		private function drawCounter():void 
		{
			_counter = Window.drawText('x'+String(_count), {
				color			:_settings.counterSettings.color,
				borderColor		:_settings.counterSettings.borderColor,
				borderSize		:_settings.counterSettings.borderSize,
				fontSize		:_settings.counterSettings.fontSize,
				width			:50,
				textAlign		:'center'
			})
			addCounter()
		}
		
		private function addCounter():void 
		{
			if (_counter && _counter.parent)
				_counter.parent.removeChild(_counter);
			_counter.y = HEIGHT / 2 + (HEIGHT / 2 - _counter.textHeight) / 2 ;
			_counter.x = WIDTH / 2 + (WIDTH / 2 - _counter.width) / 2;
			addChild(_counter);
		}
		
		private function build():void 
		{
			addChild(_background);
			if (_settings.titleSettings.hasTitle)
			{
				_title.x = (WIDTH - _title.width) / 2;
				_title.y = -_title.textHeight / 2;
				addChild(_title);
			}
			
			if (_icon)
				addIcon();
			
		}
		
		public function get WIDTH():int{return _settings.width}
		public function get HEIGHT():int{return _settings.height}
	}

}