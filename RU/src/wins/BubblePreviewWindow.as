package wins 
{
	import core.Load;
	import flash.display.Bitmap;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class BubblePreviewWindow extends Window 
	{
		private var _description:TextField;
		private var _image:Bitmap;
		public function BubblePreviewWindow(_settings:Object=null) 
		{
			if (settings == null)
				settings = {};
			for (var property:* in _settings)
			{
				settings[property] = _settings[property];
			}
			settings["background"]			= 'bubbleBlueBacking'
			settings['fontColor'] 			= 0xffe13e;
			settings['fontBorderColor'] 	= 0xbf5e00;
			settings['fontBorderSize']		= 4;
			settings['fontSize'] 			= 46;
			settings['exitTexture'] 		= 'purpleClose';
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			settings["width"]				= 600;
			settings["height"] 				= 400;
			drawDescription();
			settings['height'] += _description.textHeight;
			super(settings);
			
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 80, settings.background);
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			drawImage();
			build();
		}
		
		private function drawImage():void 
		{
			_image = new Bitmap();
			Load.loading(Config.getImageIcon('content', settings.image), function(data:Bitmap):void{
				_image.bitmapData = data.bitmapData;
				_image.y = 35;
				_image.x = (settings.width - _image.width) / 2;
			})
		}
		
		private function drawDescription():void 
		{
			_description = Window.drawText(settings.description, {
				color			:0xfffffe,
				borderColor		:0x2b4a84,
				borderSize		:3,
				fontSize		:26,
				width			:settings.width - 90,
				textAlign		:'center',
				wrap			:true,
				multiline		:true
			})
		}
		
		private function build():void 
		{
			exit.y += 13;
			exit.x -= 15;
			
			titleLabel.y += 40;
			
			_description.x = (settings.width - _description.width) / 2;
			_description.y = settings.height - _description.height - 70;
			
			bodyContainer.addChild(_image);
			bodyContainer.addChild(_description);
		}

		
	}
	
	

}