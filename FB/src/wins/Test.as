package wins 
{
	/**
	 * ...
	 * @author 
	 */
	public class Test extends Window
	{
		
		public function Test(settings:Object = null) 
		{
			if (settings == null) settings = { };
			
			settings['title'] = "flash:1382952379765";
			settings['width'] = 532;
			settings['height'] = 482;
			
			settings['hasPaginator'] = false;
			settings['hasArrows'] = false;
			settings['hasButtons'] = false;
			settings['itemsOnPage'] = 1;
			
			super(settings);
		}
		
	}

}