package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class RouletteInfoWindow extends Window 
	{		
		public var frontBacking:Bitmap;		
		public var okBttn:Button;	
		
		private var separator1:Bitmap;	
		private var separator2:Bitmap;	
		private var separator3:Bitmap;	
		private var separator4:Bitmap;	
		
		private var blocksArray:Array = [];	
		
		public function RouletteInfoWindow(settings:Object=null)  
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['title'] = settings.title || Locale.__e('flash:1382952380254')//Помощь;
			settings['width'] = 515;	
			settings['height'] = settings.height || 536;			
			settings['hasTitle'] = true;
			settings['hasButtons'] = true;
			settings['hasPaginator'] = false;
			settings['callback'] = settings.callback || null;			
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;			
			settings['popup'] = true;
			settings['background'] = 'paperScroll';
			settings['fontColor'] = 0xffdf61;
			settings['fontBorderColor'] = 0x804c18;
			settings['shadowBorderColor'] = 0x804c18;
			settings['fontBorderSize'] = 3;
			
			super(settings);			
		}
		
		override public function close(e:MouseEvent = null):void {
			super.close();
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: Locale.__e('flash:1382952380254'),//Помощь
				color				: settings.fontColor,
				multiline			: settings.multiline,
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,
				shadowColor			: settings.shadowBorderColor,
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true,
				shadowSize			: 2
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -5;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 0;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawExit():void {
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 58;
			exit.y = -10;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		override public function drawBody():void 
		{
			//frontBacking = Window.backing(470, 560, 10, 'paperBacking');
			//layer.addChild(frontBacking);
			//frontBacking.x = settings.width / 2 - frontBacking.width / 2;
			//frontBacking.y = settings.height / 2 - frontBacking.height / 2;;			
			
			/*drawMirrowObjs('storageWoodenDec', 0, settings.width, settings.height - 105);//bottom pair
			drawMirrowObjs('storageWoodenDec', 0, settings.width, 45, false, false, false, 1, -1);//upper pair
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 1, settings.width / 2 + settings.titleWidth / 2 + 1, -45, true, true);*/
			
			//сепараторы
			var backgroundText1:Bitmap = Window.backingShort(settings.width - 90, 'dailyBonusBackingDesc', true);
			backgroundText1.x = (settings.width - backgroundText1.width) / 2 + 15;
			backgroundText1.y = 75;
			backgroundText1.height = 120;
			backgroundText1.alpha = .4;
			layer.addChild(backgroundText1);
			
			var backgroundText2:Bitmap = Window.backingShort(settings.width - 90, 'dailyBonusBackingDesc', true);
			backgroundText2.x = (settings.width - backgroundText2.width) / 2 + 15;
			backgroundText2.y = 205;
			backgroundText2.height = 120;
			backgroundText2.alpha = .4;
			layer.addChild(backgroundText2);
			
			var backgroundText3:Bitmap = Window.backingShort(settings.width - 90, 'dailyBonusBackingDesc', true);
			backgroundText3.x = (settings.width - backgroundText3.width) / 2 + 15;
			backgroundText3.y = 335;
			backgroundText3.height = 120;
			backgroundText3.alpha = .4;
			layer.addChild(backgroundText3);
			
			var fish2:Bitmap = new Bitmap(Window.textures.decFish2);
			fish2.x =  - fish2.width/2;
			fish2.y = settings.height - fish2.height*2 - 80;
			layer.addChild(fish2);
			
			//var backgroundText4:Bitmap = Window.backingShort(settings.width - 60, 'dailyBonusBackingDesc', true);
			//backgroundText4.x = (settings.width - backgroundText4.width) / 2;
			//backgroundText4.y = 375;
			//backgroundText4.height = 80;
			//backgroundText4.alpha = .4;
			//layer.addChild(backgroundText4);
			//
			//var backgroundText5:Bitmap = Window.backingShort(settings.width - 60, 'dailyBonusBackingDesc', true);
			//backgroundText5.x = (settings.width - backgroundText5.width) / 2;
			//backgroundText5.y = 475;
			//backgroundText5.height = 80;
			//backgroundText5.alpha = .4;
			//layer.addChild(backgroundText5);
			
			/*separator1 = Window.backingShort(416, 'divider');
			separator1.alpha = 0.4;
			layer.addChild(separator1);
			separator1.x = (settings.width - separator1.width) / 2;
			separator1.y = 110;
			
			separator2 = Window.backingShort(416, 'divider');
			separator2.alpha = 0.4;
			layer.addChild(separator2);
			separator2.x = separator1.x;
			separator2.y = 215;
			
			separator3 = Window.backingShort(416, 'divider');
			separator3.alpha = 0.4;
			layer.addChild(separator3);
			separator3.x = separator1.x;
			separator3.y = 320;
			
			separator4 = Window.backingShort(416, 'divider');
			separator4.alpha = 0.4;
			layer.addChild(separator4);
			separator4.x = separator1.x;
			separator4.y = 425;*/
			
			//Блоки	
			
			var blocksArray:Array = [
				{ text: Locale.__e("flash:1478771256888") },
				{ text: Locale.__e("flash:1478771526576") },
				{ text: Locale.__e("flash:1478771604119") }
			];
			
			var numberYPosition:Number = 110;
			
			for (var blockIndex:* = 0; blockIndex < blocksArray.length; blockIndex++) {
				
				var indexText:String = '' + (blockIndex + 1);				
				
				var numberText:TextField = drawText(indexText, {
					fontSize	:40,
					textAlign	:"center",
					color		:0xffdf61,
					borderColor	:0x6d350d,
					multiline	:true,
					wrap		:true,
					shadow		:true,
					shadowColor	:0x6d350d,
					shadowSize	:4
				});
				
				numberText.x = 15;
				numberText.y = numberYPosition;
				
				var bubbleBmap:Bitmap = new Bitmap(Window.textures.clearBubbleBacking_0);
				bubbleBmap.x = numberText.x + (numberText.width - bubbleBmap.width) / 2;
				bubbleBmap.y = numberText.y + (numberText.textHeight - bubbleBmap.height) / 2;
				layer.addChild(bubbleBmap);
				
				layer.addChild(numberText);
				
				var numberHalfY:* = numberText.y + numberText.height / 2;
				
				var textOne:TextField = drawText(blocksArray[blockIndex].text, {
					fontSize	:28,
					textAlign	:"left",
					color		:0x70431f,
					//borderColor	:0xfffff1,
					multiline	:true,
					border		:false,
					wrap		:true,
					width		:285
				});
				
				textOne.x = 100;
				textOne.y = numberHalfY - textOne.height / 2 - 0;
				layer.addChild(textOne);
				
				numberYPosition += 130;
				
			}
			
			Load.loading(Config.getImage('hints/', 'HelpRoulettePic1'), function(data:Bitmap):void 
			{				
				var bitmapOne:Bitmap = new Bitmap(data.bitmapData);
				layer.addChild(bitmapOne);
				bitmapOne.x = settings.width - bitmapOne.width;
				bitmapOne.y = 45;
			});
			
			Load.loading(Config.getImage('hints/', 'HelpRoulettePic2'), function(data:Bitmap):void {
				
				var bitmapTwo:Bitmap = new Bitmap(data.bitmapData);
				layer.addChild(bitmapTwo);
				bitmapTwo.x = settings.width - bitmapTwo.width;
				bitmapTwo.y = 45 + 105;
			});
			
			Load.loading(Config.getImage('hints/', 'HelpRoulettePic3'), function(data:Bitmap):void 
			{				
				var bitmapThree:Bitmap = new Bitmap(data.bitmapData);
				layer.addChild(bitmapThree);
				bitmapThree.x = settings.width - bitmapThree.width - 10;
				bitmapThree.y = 45 + 105 + 105;
			});
			/*
			Load.loading(Config.getImage('hints/', 'HelpRoulettePic4'), function(data:Bitmap):void 
			{				
				var bitmapFour:Bitmap = new Bitmap(data.bitmapData);
				layer.addChild(bitmapFour);
				bitmapFour.x = settings.width - bitmapFour.width + 5;
				bitmapFour.y = 45 + 105 + 105 + 105;
			});
			
			Load.loading(Config.getImage('hints/', 'HelpRoulettePic5'), function(data:Bitmap):void 
			{				
				var bitmapFive:Bitmap = new Bitmap(data.bitmapData);
				layer.addChild(bitmapFive);
				bitmapFive.x = settings.width - bitmapFive.width - 10;
				bitmapFive.y = 45 + 105 + 105 + 105 + 105;
			});*/
			
			drawMirrowObjs('decSeaweed', settings.width + 35, - 35, settings.height - 179, true, true, false, 1, 1);
			
			drawBttns();
		}
		
		private function drawBttns():void 
		{			
			okBttn = new Button( {
				width:165,
				height:55,
				fontSize:32,
				caption:Locale.__e("flash:1446800999662")//Понятно
			});
			layer.addChild(okBttn);
			okBttn.x = settings.width / 2 - okBttn.width / 2;
			okBttn.y = settings.height - 35;
			okBttn.addEventListener(MouseEvent.CLICK, close);
		}
	}

}