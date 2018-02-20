package tree 
{
	import flash.display.Bitmap;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class Dialog extends LayerX
	{
		private var qID:int = 0;
		private var text:TextField;
		private var background:Bitmap;
		public function Dialog(qid:int) 
		{
			qID = qid;
			
			text = UI.drawText(App.data.quests[qID].description, {
				fontSize:24,
				color:0xffffff,
				borderColor:0x2D2D2D,
				textAlign:"center",
				width:270,
				wrap:true
			});
			
			text.x = 10;
			text.y = 15;
			addChild(text);
			var currHeight:int = text.textHeight;
			if (currHeight < 60)
				currHeight = 60;
			background = UI.backing(290, currHeight + 44, 44, 'questTaskBackingTop');
			addChildAt(background, 0);
			relocate();
		}
		
		public function relocate():void 
		{
			x = App.self.stage.mouseX + 30;
			y = App.self.stage.mouseY + 0;
			
			if (App.self.stage.stageWidth - App.self.stage.mouseX < background.width)
				x -= background.width;
			
			if (App.self.stage.stageHeight - App.self.stage.mouseY < background.height - 40)
				y -= background.height;
				
			if (y < 0)
				y = 0;
				
			if (y + background.height > App.self.stage.stageHeight)
				y = App.self.stage.stageHeight - background.height;
		}
		
	}

}