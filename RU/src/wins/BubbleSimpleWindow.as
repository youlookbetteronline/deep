package wins 
{
	import flash.display.Bitmap;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class BubbleSimpleWindow extends Window 
	{
		private var _label:TextField
		public function BubbleSimpleWindow(_settings:Object=null) 
		{
			if (settings == null)
				settings = {};
			for (var property:* in _settings)
			{
				settings[property] = _settings[property];
			}
			settings["background"]			= 'bubbleBlueBacking'
			settings['fontColor'] 			= 0xfff94e;
			settings['fontBorderColor'] 	= 0x2b4a84;
			settings['fontBorderSize']		= 4;
			settings['fontSize'] 			= 48;
			settings['exitTexture'] 		= 'purpleClose';
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			settings["width"]				= 480;
			drawDescription();
			settings["height"] 				= 140 + _label.textHeight;
			super(settings);
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 80, settings.background);
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			build();
		}
		
		private function drawDescription():void 
		{
			_label = Window.drawText(settings.label, {
				color			:0xffffff,
				borderColor		:0x2b4a84,
				borderSize		:4,
				fontSize		:32,
				width			:settings.width - 100,
				textAlign		:'center',
				wrap			:true,
				multiline		:true
			})
		}
		
		private function build():void 
		{
			titleLabel.y += 45;
			
			exit.y += 13;
			exit.x -= 15;
			
			_label.x = (settings.width - _label.width) / 2;
			_label.y = 50
			
			bodyContainer.addChild(_label);
		}
		
	}

}