package wins 
{
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author ...
	 */
	public class BubbleWindow extends Window 
	{
		
		public function BubbleWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = {};
			}
			settings["width"]				= 490;
			settings["height"] 				= 480;
			settings['exitTexture'] 		= 'blueClose';
			settings['fontColor'] 			= 0x004762;
			settings['fontBorderColor'] 	= 0xffffff;
			settings['fontBorderSize']		= 4;
			settings['fontSize'] 			= 40;
			settings["paginatorSettings"] 	= {
				buttonsCount	:3, 
				itemsOnPage		:3,
				buttonPrev		:"bubbleArrow"
				
			};
			super(settings);
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing4(settings.width, settings.height, 160, 'blueBackingTL', 'blueBackingTR', 'blueBackingBL', 'blueBackingBR');
			layer.addChild(background);	
		}
		
		
	}

}