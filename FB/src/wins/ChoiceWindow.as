package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class ChoiceWindow extends Window 
	{
		
		public function ChoiceWindow(settings:Object=null) 
		{
			var lengthDesc:int = settings.descriptionText.length
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x085c10;
			settings['borderColor'] = 0x085c10;
			settings['shadowColor'] = 0x085c10;
			settings['fontSize'] = 48;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 2;
			settings['hasPaginator'] 	= false
			settings['bgBottom'] 		= settings.bgBottom || 'workerHouseBacking';
			settings['bgTop'] 			= settings.bgTop || 'itemBacking';
			settings['height'] 			= settings.height + lengthDesc / 35 * 40;
			settings['width'] 			= settings.width || 400;
			settings['mainText'] 		= settings.mainText || '';
			settings['descriptionText'] = settings.descriptionText || '';
			settings['rightBttnText']   = settings.rightBttnText || '';
			settings['leftBttnText'] 	= settings.leftBttnText || '';
			super(settings);
			
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 50, settings.bgBottom);
			layer.addChild(background);	
			var background2:Bitmap = backing(settings.width - 70, settings.height - 70, 30, settings.bgTop);
			background2.x = background.x + (background.width - background2.width) / 2;
			background2.y = background.y + (background.height - background2.height) / 2;
			layer.addChild(background2);	
		}
		
		override public function drawBody():void 
		{
			exit.y -= 20;
			drawRibbon();
			titleLabel.y += 15;
			titleBackingBmap.y += 5;
			
			var mainText:TextField = Window.drawText(settings.mainText, {
				color		:0xffffff,
				borderColor	:0x6e411e,
				fontSize	:30,
				width		:settings.width - 80,
				wrap		:true,
				textAlign	:"center"
			})
			mainText.x = (settings.width - mainText.width) / 2;
			mainText.y = 35;
			bodyContainer.addChild(mainText);
			
			var descriptionText:TextField = Window.drawText(settings.descriptionText, {
				color		:0x6e411e,
				border		:false,
				fontSize	:30,
				width		:settings.width - 80,
				wrap		:true,
				textAlign	:"center"
			})
			
			descriptionText.x = (settings.width - mainText.width) / 2;
			descriptionText.y = mainText.y + mainText.textHeight + 15;
			bodyContainer.addChild(descriptionText);
			drawButtons();
		}
		
		private function drawButtons():void 
		{
			var leftBttn:Button = new Button({
				caption			:settings.leftBttnText,
				width			:175, 
				height			:57, 
				fontSize		:30, 
				hasDotes		:false,
				bgColor			:[0xfed031,0xf8ac1b],
				bevelColor		:[0xfed131, 0xf8ab1a],
				fontColor		:0xffffff,
				fontBorderColor	:0x6e411e
			});
			leftBttn.x = settings.width / 2 - leftBttn.width - 10;
			leftBttn.y = settings.height - leftBttn.height - 25;
			bodyContainer.addChild(leftBttn);
			
			var rightBttn:Button = new Button({
				caption			:settings.rightBttnText,
				width			:175, 
				height			:57, 
				fontSize		:30, 
				hasDotes		:false,
				bgColor			:[0xbcec63,0x63ba1d],
				bevelColor		:[0xdefea7, 0x4e8b2c],
				fontColor		:0xffffff,
				fontBorderColor	:0x085c10
			});
			rightBttn.x = settings.width / 2 + 10;
			rightBttn.y = settings.height - rightBttn.height - 25;
			bodyContainer.addChild(rightBttn);
			
			leftBttn.addEventListener(MouseEvent.CLICK, onLeftBttnEvent);
			rightBttn.addEventListener(MouseEvent.CLICK, onRightBttnEvent);
		}
		
		private function onLeftBttnEvent(e:*):void 
		{
			settings.leftEvent()
			close()
		}
		
		private function onRightBttnEvent(e:*):void 
		{
			settings.rightEvent()
			close();
		}
		
	}

}