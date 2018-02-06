package core 
{
	import flash.external.ExternalInterface;
	public class Log 
	{
		
		public function Log() 
		{
			
		}
		
		public static function alert(data:*):void {
			
			//return;
			Post.addToArchive(JSON.stringify(data), false);
			if (ExternalInterface.available)
			{
				ExternalInterface.call("console.log", data);
			}
			
		}
		
	}

}