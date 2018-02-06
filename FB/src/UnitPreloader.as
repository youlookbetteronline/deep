package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	public class UnitPreloader extends Sprite 
	{
		[Embed(source="Question_desk.png")]
		private var Question_desk:Class;
		public var desk:BitmapData = new Question_desk().bitmapData;
		
		public function UnitPreloader() 
		{
			var preloaderPic:Bitmap = new Bitmap(desk);
			addChild(preloaderPic);
		}
		
	}

}