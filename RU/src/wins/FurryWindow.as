package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MixedButton2;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import units.Factory;
	import units.GardenerSlave;
	import units.Techno;
	
	public class FurryWindow extends Window
	{
		private var background:Bitmap;
		private var robotIcon:Bitmap;
		private var robotCounter:TextField;
		private var timeLeft:TextField;
		private var textSettings:Object;
		private var bitmap:Bitmap;
		private var background2:Bitmap;
		private var collectBttn:MixedButton2;
		
		public var plusBttn:ImageButton;
		public var minusBttn:ImageButton;
		public var minusBttn10:ImageButton;
		public var plusBttn10:ImageButton;
		public var neededResourse:int = -1;		
		public var mode:int = FURRY
		
		public static const FURRY:int = 1;
		public static const RESOURCE:int = 2;
		public static const COLLECTOR:int = 3;
		public static const COWBOW:int = 4;
		public static const GOLDEN_FURRY:int = 5;
		public static const FURRY_FREE:int = 6;
		public static const FURRY_GARDENER:int = 7;	
		
		public function FurryWindow(settings:Object = null) 
		{
			if (settings == null)
			{
				settings = new Object();
			}
			
			settings["width"] = 400;
			settings["height"] = 400;
			settings["title"] = settings.info.title;
			settings["fontSize"] = 150;
			settings["hasPaginator"] = false;
			mode = settings["mode"] || FURRY;
			settings["iconBuilding"] = settings.iconBuilding;
			
			for (var pr_sid:* in settings.target.info.require) {
				neededResourse = pr_sid;
			}
			
			super(settings);
		}
		
		override public function drawBackground():void 
		{
			background = backing(settings.width, settings.height, 20, "questBackingTop");	
			layer.addChildAt(background, 0);			
		}
		
		override public function drawTitle():void
		{			
		}
		
		private function drawTitleLabel():void 
		{
			var titleContainer:Sprite = new Sprite();
			var textFilter:GlowFilter = new GlowFilter(0x885827, 1, 4,4, 8, 1);			
			var title:TextField = Window.drawText(settings.info.title, {
				color		:0xfeffff,
				borderColor	:0xb88556,
				fontSize	:38,
				multiline	:true,
				wrap		:true,
				textAlign	:"center",
				textLeading : -12
				
			});				
			
			title.y = -45;
			title.width = 250;
			title.x = (settings.width - title.width) / 2 - 2;
			
			titleContainer.addChild(title);
			titleContainer.filters = [textFilter ];
			bodyContainer.addChild(titleContainer);
		}
		
		override public function drawBody():void 
		{
			background2 = Window.backing2(205, 188, 20, "itemBackingPaperBigDrec", "itemBackingPaperBig", 0, -1);
			
			background2.x = (settings.width/2 - background2.width / 2);
			background2.y = (settings.height/2 - background2.height / 2);
			layer.addChild(background2);
			drawItems();
			showTimer();				
			drawTitleLabel();
		}
		
		private function showTimer():void 
		{
			textSettings = {
				color:0xFFFFFF,
				borderColor:0x4b2e1a,
				fontSize:32,
				textAlign:"center",
				multiline:true,
				width: 200
			};
			
			timeLeft = Window.drawText(Locale.__e("flash:1382952379794",TimeConverter.timeToStr(settings.finished - App.time)), textSettings);
			
			layer.addChild(timeLeft);		
			timeLeft.x = settings.width/2 - timeLeft.textWidth/2;
			timeLeft.y = background2.y+ background2.height + 20;			
			App.self.setOnTimer(showTimeLeft)			
		}
		
		private function showTimeLeft():void 
		{
			timeLeft.text 	=  Locale.__e("flash:1382952379794", TimeConverter.timeToStr(settings.finished - App.time));
			if (settings.finished - App.time<=0) 
			{
				close();
			}
		}
		
		public function drawItems():void
		{	
			bitmap = new Bitmap();
			
			bitmap.bitmapData = settings.target.bitmap.bitmapData;
			bitmap.smoothing = true;
			
			switch (settings.info.sID)
			{				
				case App.data.storage[App.user.worldID].techno[0]:
					bitmap.scaleX = bitmap.scaleY = 1;
					break;
				default:
					bitmap.scaleX = bitmap.scaleY = 0.7;
			}
			
			bitmap.x = (settings.width - bitmap.width) / 2;
			bitmap.y = 170 - bitmap.height / 2;
			bodyContainer.addChild(bitmap);
		}
		
		override public function drawExit():void 
		{
			super.drawExit();
			
			exit.x = settings.width - exit.width+10;
			exit.y = -15;
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}