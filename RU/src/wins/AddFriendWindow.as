package wins 
{
	/**
	 * ...
	 * @author ...
	 */
	public class AddFriendWindow extends Window 
	{
		
		public function AddFriendWindow(settings:Object=null) 
		{
			super(settings);
			
			settings["width"]				= 500;
			settings["height"] 				= 305;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= true;
			settings["hasArrows"]			= false;
			settings['exitTexture'] 		= 'closeBttnMetal';
			settings['background']	 		= 'capsuleWindowBacking';
			settings['fontColor'] 			= 0xffffff;
			settings['fontBorderColor'] 	= 0x116011;
			settings['borderColor'] 		= 0x116011;
			settings['shadowBorderColor']	= 0x116011;
			settings['fontSize'] 			= 52;
			settings['title'] 				= Locale.__e('flash:1435241453649');
		}
		
	}

}