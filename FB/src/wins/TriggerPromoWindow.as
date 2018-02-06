package wins 
{
	import core.Load;
	import flash.display.Bitmap;
	import flash.text.TextField;
	
	public class TriggerPromoWindow extends ActionInformerWindow
	{
		public static var showed:Array = [];
		private var rays:Bitmap = new Bitmap();
		public var titleTextLabel:TextField;
		public var description:TextField;
		public var decorID:Number;
		
		public function TriggerPromoWindow(settings:Object) 
		{
			
			settings['width'] = settings.width||350;
			settings['height'] = settings.height||404;
			settings['title'] = settings.title||Locale.__e('flash:1456157218723');
			settings['background'] = 'questBacking';
			settings['hasPaginator'] = false;
			settings['stripX'] = settings.stripX || -68;
			settings['stripY'] = settings.stripY || 135;
			settings['stripW'] = settings.stripW || 130;
			settings['descBgY'] = settings.descBgY || 150;
			super(settings);
		}
		override public function drawBody():void 
		{	
			drawPriceButton();
			drawBottomImages();
			drawDecorations();	
			drawActionDescription();
			//drawActionPic();						
			drawRibbon();
			exit.y -= 20;			
		}
		
		override protected function drawRibbon():void {
		}
		
		public var itemBackingBot:Bitmap;
		private function drawBottomImages():void
		{
			itemBackingBot = new Bitmap();
			Load.loading (Config.getImage('actions', 'DecInfPic1','jpg'), function (data:Bitmap):void
			{
				itemBackingBot.bitmapData = data.bitmapData;
				itemBackingBot.x = settings.width * 0.5 - itemBackingBot.width * 0.5;
				itemBackingBot.y = 150;
				bodyContainer.addChildAt(itemBackingBot, 1);
				for (var goldenID:String in action.items)
					break;
				
				Load.loading (Config.getIcon(App.data.storage[goldenID].type, App.data.storage[goldenID].view), function (data:Bitmap):void
				{
					goldenBM.bitmapData = data.bitmapData;
					goldenBM.x = itemBackingBot.x + itemBackingBot.width * 0.5 - goldenBM.width * 0.5;
					goldenBM.y = itemBackingBot.y + itemBackingBot.height * 0.5 - goldenBM.height * 0.5;
					bodyContainer.addChildAt(goldenBM, 2);
				});
			});
			
		}
		private var materialBm:Bitmap = new Bitmap();
		private var goldenBM:Bitmap = new Bitmap();
		
		override protected function drawDecorations():void 
		{
			for (var id:* in action.items) {
				decorID = id;
			}
			
			//Тайтл декора
			titleTextLabel = Window.drawText(App.data.storage[decorID].title, {
				fontSize			:25,
				textAlign			:"center",
				color				:0xfffeff,
				borderColor			:0x905239,
				border				:true,
				strenghtShadow		:30
			});
			
			titleTextLabel.width = titleTextLabel.textWidth + 10;
			titleTextLabel.x = settings.width / 2 - titleTextLabel.width / 2;	
			titleTextLabel.y = 130;
			bodyContainer.addChild(titleTextLabel);
			
			//Воспользуйся предложением!
			description = Window.drawText(Locale.__e('flash:1393582597477'), {
				fontSize			:25,
				textAlign			:"center",
				color				:0xfffeff,
				borderColor			:0x905239,
				border				:true,
				shadowBorderColor	:0x1743ae,
				strenghtShadow		:30
			});
			
			description.width = description.textWidth + 10;
			description.x = settings.width / 2 - description.width / 2;	
			description.y = priceBttn.y - description.height;
			bodyContainer.addChild(description);			
			
			drawMirrowObjs('storageWoodenDec', 0, settings.width - 0, settings.height - 120 + 15);//bottom
			drawMirrowObjs('storageWoodenDec', 0, settings.width - 0, 40, false, false, false, 1, -1);//up
			drawMirrowObjs('diamondsTop', titleTextLabel.x + 5, titleTextLabel.x + titleTextLabel.width, titleTextLabel.y - 7, true, true);
			
			//Свечение позади БП
			var rays:Bitmap = new Bitmap(Window.textures.sharpShining, "auto", true);
			rays.x = settings.width / 2 - rays.width / 2;	
			rays.y = 15;
			rays.scaleX = rays.scaleY = 1;
			bodyContainer.addChild(rays);
			
			//БП
			Load.loading( Config.getIcon(App.data.storage[action.rel].type, App.data.storage[action.rel].view), function (data:Bitmap):void {
				materialBm.bitmapData = data.bitmapData;
				materialBm.x = settings.width / 2 - materialBm.width / 2;
				materialBm.y = rays.y + 30;
				bodyContainer.addChild(materialBm);
			});
		}
		
		//override protected function drawActionPic():void {
		//}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: Locale.__e('flash:1456497231623'),//Закончились материалы?
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: 33,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,					
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = 15;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		override protected function drawActionDescription():void {
		}
	}

}