package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	public class AuctionHintWindow extends Window 
	{		
		private var background:Bitmap;
		
		public function AuctionHintWindow(settings:Object=null)  
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['title'] = settings.title || Locale.__e('flash:1382952380254')//Помощь;
			settings['width'] = 500;	
			settings['height'] = settings.height || 515;			
			settings['hasTitle'] = true;
			settings['hasButtons'] = true;
			settings['hasPaginator'] = false;
			settings['callback'] = settings.callback || null;			
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;			
			settings['popup'] = true;
			settings['fontColor'] = 0xffdf61;
			settings['fontBorderColor'] = 0x804c18;
			settings['shadowBorderColor'] = 0x804c18;
			settings['fontBorderSize'] = 3;
			
			super(settings);			
		}
		
		override public function close(e:MouseEvent = null):void
		{
			super.close();
		}		
		
		override public function drawBackground():void
		{
			background = backing(settings.width, settings.height, 30, 'paperScroll');
			layer.addChild(background);
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
			});
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -5;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 0;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawExit():void
		{
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 55;
			exit.y = -10;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		override public function drawBody():void 
		{
			var firstHintBacking:Shape = new Shape();
			firstHintBacking.graphics.beginFill(0xf0c001, .4);
		    firstHintBacking.graphics.drawRect(0, 0, settings.width - 150, 120);
		    firstHintBacking.graphics.endFill();
			firstHintBacking.filters = [new BlurFilter(40, 0, 2)];
			
			firstHintBacking.x = (settings.width - firstHintBacking.width) / 2 + 15;
			firstHintBacking.y = 75;
			layer.addChild(firstHintBacking);
			
			var secondHintBacking:Shape = new Shape();
			secondHintBacking.graphics.beginFill(0xf0c001, .4);
		    secondHintBacking.graphics.drawRect(0, 0, settings.width - 150, 120);
		    secondHintBacking.graphics.endFill();
			secondHintBacking.filters = [new BlurFilter(40, 0, 2)];
			
			secondHintBacking.x = (settings.width - secondHintBacking.width) / 2 + 15;
			secondHintBacking.y = 205;
			layer.addChild(secondHintBacking);
			
			var thirdHintBacking:Shape = new Shape();
			thirdHintBacking.graphics.beginFill(0xf0c001, .4);
		    thirdHintBacking.graphics.drawRect(0, 0, settings.width - 150, 120);
		    thirdHintBacking.graphics.endFill();
			thirdHintBacking.filters = [new BlurFilter(40, 0, 2)];
			
			thirdHintBacking.x = (settings.width - thirdHintBacking.width) / 2 + 15;
			thirdHintBacking.y = 335;
			layer.addChild(thirdHintBacking);
			
			var fish2:Bitmap = new Bitmap(Window.textures.decFish2);
			fish2.x =  - fish2.width/2;
			fish2.y = settings.height - fish2.height*2 - 80;
			layer.addChild(fish2);
			
			var blocksArray:Array;
			blocksArray = [
				{ text: Locale.__e("flash:1506436249162") },
				{ text: Locale.__e("flash:1506436296249") },
				{ text: Locale.__e("flash:1506436323449") }
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
					multiline	:true,
					border		:false,
					wrap		:true,
					width		:settings.width - 150
				});
				
				textOne.x = 100;
				textOne.y = numberHalfY - textOne.height / 2 - 0;
				layer.addChild(textOne);
				
				numberYPosition += 130;
			}
			
			drawMirrowObjs('decSeaweed', settings.width + 35, - 35, settings.height - 179, true, true, false, 1, 1);
			drawBttns();
		}
		
		private function drawBttns():void {
			
			var okBttn:Button = new Button( {
				width:175,
				height:55,
				fontSize:32,
				caption:Locale.__e("flash:1446800999662")//Понятно
			});
			layer.addChild(okBttn);
			okBttn.x = background.x + (background.width - okBttn.width) / 2;
			okBttn.y = (background.y + background.height - (okBttn.height / 2)) - 10;
			okBttn.addEventListener(MouseEvent.CLICK, close);
		}
	}
}