package wins 
{
	
	
	public class VoicelessShipWindow extends ShipWindow 
	{
		
		
		
		public function VoicelessShipWindow(settings:Object=null) 
		{
			
			
			super(settings);
		}
		
		override public function drawBackground():void {
			//
		}
		override public function show():void {
			//
			super.show();
			bodyContainer.visible = false;
			headerContainer.visible = false;
			headerContainerSplit.visible = false;
			
			layer.visible = false;
			
			settings
			stock.onMaterialItem(settings.e)
		
		}
		
		
	}
}