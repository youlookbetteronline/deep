package wins 
{
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author ...
	 */
	public class TopListWindow extends Window 
	{
		
		public function TopListWindow(settings:Object=null) 
		{
			settings = settingsInit(settings);
			super(settings);
			
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			settings["width"]				= 355;
			settings["height"] 				= 300;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			settings['exitTexture'] 		= 'yellowClose';
			settings['fontColor'] 			= 0x6e411e;
			settings['fontBorderColor'] 	= 0xfdf3cb;
			settings['fontBorderSize']		= 4;
			settings['fontSize'] 			= 28;
			
			return settings;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = Window.backing4(settings.width, settings.height, 0, "backingYellowTL", "backingYellowTR", "backingYellowBL", "backingYellowBR");
			layer.addChild(background);
		}
		
	}

}