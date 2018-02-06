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
		public function BubbleSimpleWindow(settings:Object=null) 
		{
			settings = settingsInit(settings);
			super(settings);
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			
			settings["width"]				= 480;
			settings["height"] 				= 200;
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
			
			return settings;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 80, settings.background);
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			drawDescription();
			build();
		}
		
		private function drawDescription():void 
		{
			//_label
		}
		
		private function build():void 
		{
			titleLabel.y += 35;
			
			exit.y += 13;
			exit.x -= 15;
		}
		
	}

}