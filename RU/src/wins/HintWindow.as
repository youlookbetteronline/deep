package wins 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author ...
	 */
	public class HintWindow extends Window 
	{
		private var _hint:Hint
		private var _hintContainer:Sprite = new Sprite();
		public function HintWindow(settings:Object=null) 
		{
			settings = settingsInit(settings);
			super(settings);
			
		}
		
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			settings["width"]				= 510;
			settings["height"] 				= 110 + settings.icons.length * 118;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			settings['exitTexture'] 		= 'yellowClose';
			settings['fontColor'] 			= 0x6e411e;
			settings['fontBorderColor'] 	= 0xfdf3cb;
			settings['fontBorderSize']		= 3;
			settings['fontSize'] 			= 46;
			settings['title'] 				= Locale.__e('flash:1382952380254');
			
			return settings;
		}
		
		
		private function get parseContent():Array 
		{
			var result:Array = [];
			for (var it:* in settings.icons)
			{
				var obj:Object = {}
				obj.description = settings.descriptions[it]
				obj.icon = settings.icons[it]
				result[it] = obj
			}
			return result;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = Window.backing4(settings.width, settings.height, 0, "yellowBackingTL", "yellowBackingTR", "yellowBackingBL", "yellowBackingBR");
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			settings.content = parseContent
			var Y:int = 0;
			for (var i:int = 0; i < settings.content.length; i ++ )
			{
				_hint = new Hint({
					item:	settings.content[i]
				})
				_hint.y = Y;
				_hintContainer.addChild(_hint);
				Y += 115;
			}
			build()
		}
		
		private function build():void 
		{
			exit.x -= 10;
			exit.y += 10;
			titleLabel.y += 40;
			
			_hintContainer.x = (settings.width - _hintContainer.width) / 2;
			_hintContainer.y = 45
			bodyContainer.addChild(_hintContainer);
		}
		
		override public function close(e:MouseEvent = null):void 
		{
			super.close(e);
			if (settings.callback)
				settings.callback();
		}
	}

}
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class Hint extends Sprite
{
	private var _item:Object
	private var _background:Bitmap;
	private var _icon:Bitmap;
	private var _desc:TextField;
	public function Hint(settings:Object)
	{
		this._item = settings.item
		drawBackground()
		drawIcon()
		drawDescription()
		build();
	}
	
	private function drawBackground():void 
	{
		_background = Window.backing2(110, 110, 39, 'yellowBackingT', 'yellowBackingB')
	}
	
	private function drawIcon():void 
	{
		Load.loading(Config.getIcon('Content', _item.icon), onLoad)
	}
	
	private function onLoad(data:Bitmap):void 
	{
		_icon = new Bitmap(data.bitmapData);
		Size.size(_icon, 95, 95);
		_icon.smoothing = true;
		_icon.x = _background.x + (_background.width - _icon.width) / 2;
		_icon.y = _background.y + (_background.height - _icon.height) / 2;
		addChild(_icon);
	}
	
	private function drawDescription():void 
	{
		_desc = Window.drawText(_item.description, {
			width		:320,
			textAlign	:'center',
			fontSize	:24,
			color		:0xffffff,
			borderColor	:0x6e411e,
			borderSize	:3,
			multiline	:true,
			wrap		:true
		})		
	}
	
	private function build():void 
	{
		_desc.x = _background.width + 10;
		_desc.y = _background.y + (_background.height - _desc.height) / 2;
		
		addChild(_background);
		addChild(_desc);
		
		if (_icon)
		{
			_icon.x = _background.x + (_background.width - _icon.width) / 2;
			_icon.y = _background.y + (_background.height - _icon.height) / 2;
			addChild(_icon);
		}
	}
}