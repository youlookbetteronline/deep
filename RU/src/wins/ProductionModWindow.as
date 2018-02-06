package wins 
{
	
	public class ProductionModWindow extends BuildingWindow 
	{
		
		public static var history:int = 0;
		
		public function ProductionModWindow(settings:Object) 
		{
			
			if (!settings) settings = { };
			
			settings['title'] = settings['title'] || Locale.__e('');
			settings['width'] = settings.width || 620;
			settings['height'] = settings.height || 616;
			settings['hasArrows'] = true;
			settings['itemsOnPage'] = 6;
			settings['faderAlpha'] = 0.6;
			settings['page'] = history;
			settings['hasButtons'] = false;
			settings['hasAnimations'] = false;
			settings['hasTitle'] = false;
			
			super(settings);
			
		}
		
		override public function drawBody():void {
			
			
			
		}
		
	}

}