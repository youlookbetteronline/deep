package ui 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class ChatField extends LayerX 
	{
		public static var self:ChatField;
		private var settings:Object = {
			width:250,
			height:100
		};
		public function ChatField(_settings:Object = null) 
		{
			if (_settings)
			{
				for (var _param:* in _settings)
					settings[_param] = _settings[_param]
			}
			drawBacking();
			drawField();
			App.self.stage.addEventListener(Event.RESIZE, onResize);
			App.self.stage.addEventListener(KeyboardEvent.KEY_DOWN, onPostMessage);
		}
		
		public static function show(setts:Object = null):void
		{
			if (ChatField.self)
				ChatField.self.dispose();
			else{
				ChatField.self = new ChatField(setts);
				App.self.windowContainer.addChild(ChatField.self);
				ChatField.self.onResize();
			}
		}
		
		public function onPostMessage(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				if (ChatField.self.text.text.length < 3)
				{
					ChatField.self.dispose();
					return;
				}
				if (ChatField.self.text.text.length > 140)
				{
					ChatField.self.text.text = ChatField.self.text.text.slice(0, 140);
					ChatField.self.text.text.concat(ChatField.self.text.text, "...");
				}
				Connection.sendMessage({u_event:'hero_say', aka:App.user.aka, text:ChatField.self.text.text});
				App.user.hero.clearIcon();
				App.user.hero.saySomething(0xfffef4, 0x123b65, ChatField.self.text.text);
				ChatField.self.dispose();
			}
		}
		public function dispose():void
		{
			if (ChatField.self && ChatField.self.parent)
				ChatField.self.parent.removeChild(ChatField.self)
			ChatField.self = null;
			App.self.stage.removeEventListener(Event.RESIZE, onResize);
			App.self.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onPostMessage);
		}
		
		public function onResize(e:* = null):void
		{
			ChatField.self.x = App.self.stage.stageWidth - ChatField.self.width - 210;
			ChatField.self.y = App.self.stage.stageHeight - ChatField.self.height - 70;
		}
		
		public var text:TextField;
		private function drawField():void
		{
			var textSettings:Object =	{
				color:			0xfffef4,
				borderColor:	0x123b65,
				input:			true,
				wrap:			true,
				multiline:		true,
				textAlign:		'left',
				fontSize:		20,
				shadowSize:		1.5
			};
			var _text:String = '';
			if (settings.hasOwnProperty('text'))
				_text = settings['text'];
			text = Window.drawText(_text, textSettings);
			
			text.setSelection(_text.length, _text.length);
			text.width = settings.width - 20;
			text.height = settings.height - 20;
			text.x = bgIcon.x + 10;
			text.y = bgIcon.y + 10;
			App.self.stage.focus = text;
			addChild(text);
			
		}
		private var bgIcon:Shape;
		private var bgBitmap:Bitmap;
		private function drawBacking():void
		{
			bgBitmap = new Bitmap(new BitmapData(settings.width + 5, settings.height + 24, true, 0x0));
			
			var matrix:Matrix = new Matrix(); 
			matrix.createGradientBox(settings.width, settings.height, Math.PI / 2);
			bgIcon = new Shape();
			bgIcon.graphics.beginFill(0x15256d, 1);
			bgIcon.graphics.drawRoundRect(0, 0, settings.width, settings.height, 25, 25);
			bgIcon.graphics.endFill();
			bgBitmap.bitmapData.draw(bgIcon);
			
			var triangle:Shape = new Shape(); 
			triangle.graphics.beginFill(0x15256d, 1);
			triangle.graphics.moveTo(18, -12);
			triangle.graphics.curveTo(24, 18, 18, 18);
			triangle.graphics.curveTo(14, 20, -3, 0);
			triangle.graphics.endFill();
			bgBitmap.bitmapData.draw(triangle, new Matrix(1, 0, 0, 1, bgIcon.x + bgIcon.width - triangle.width + 6, bgIcon.y + bgIcon.height));
			
			bgBitmap.alpha = .7;
			addChild(bgBitmap);
		}
		
	}

}