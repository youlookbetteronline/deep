package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	public class WindowInfoWindow extends Window 
	{		
		public var firstHintBacking:Bitmap;
		public var secondHintBacking:Bitmap;
		public var thirdHintBacking:Bitmap;
		public var background:Bitmap;
		public var okBttn:Button;
		public var sid:int = 0;
		public var info:Object = { };
		public var firstHintText:TextField;
		public var secondHintText:TextField;
		public var thirdHintText:TextField;
		public var firstHintBitmap:Bitmap;
		public var secondHintBitmap:Bitmap;
		public var thirdHintBitmap:Bitmap;
		
		protected var top50RewardCont:LayerX;
		protected var top10RewardCont:LayerX;
		
		private var preloaderOne:Preloader = new Preloader();
		private var preloaderTwo:Preloader = new Preloader();
		private var preloaderThree:Preloader = new Preloader();
		private var preloader:Preloader = new Preloader();
		
		
		public function WindowInfoWindow(settings:Object=null)  
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['hintsNum'] = settings.hintsNum;
			settings['hintID'] = settings.hintID;
			settings['title'] = settings.title || Locale.__e('flash:1382952380254')//Помощь;
			settings['width'] = 455;	
			settings['height'] = 250;			
			settings['hasTitle'] = true;
			settings['hasButtons'] = true;
			settings['hasPaginator'] = false;
			settings['callback'] = settings.callback || null;			
			settings['faderAsClose'] = true;
			settings['faderClickable'] = false;			
			settings['popup'] = true;
			settings['fontColor'] = 0xffdf61;
			settings['fontBorderColor'] = 0x804c18;
			settings['shadowBorderColor'] = 0x804c18;
			settings['fontBorderSize'] = 3;
			
			info = App.data.storage[sid];
			
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
			/*titleLabel = titleText( {
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
			headerContainer.mouseEnabled = false;*/
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
			var IconsArray:Array = new Array();
			var blocksArray:Array;
			switch (settings.hintID) 
			{
				case 1://Подсказка в Столе
					blocksArray = [
						{ text: Locale.__e("flash:1382952379976"), dx:0 }
					];
					IconsArray = [
						{ icon:'octopusWife', dy:0, dx:0 }
					];
				break;
				case 2://Подсказка в палатке и складе
					blocksArray = [
						{ text: Locale.__e("flash:1481196597483"), dx:0 }
					];
					IconsArray = [
						{ icon:'sickCancer', dy:0, dx:0 }
					];
				break;
				case 3://Подсказка в палатке и складе
					blocksArray = [
						{ text: Locale.__e("flash:1482244036284"), dx:20 }
					];
					IconsArray = [
						{ icon:'fatSnale', dy:10, dx:0 }
					];
				break;
				case 4://Подсказка в палатке и складе
					blocksArray = [
						{ text: Locale.__e("flash:1483009006529"), dx:20 }
					];
					IconsArray = [
						{ icon:'octupusFriends', dy:10, dx:0 }
					];
				break;
				case 5://Подсказка в палатке и складе
					blocksArray = [
						{ text: Locale.__e("flash:1484585380293"), dx:-20 }
					];
					IconsArray = [
						{ icon:'girlClothes', dy:-2, dx:0 }
					];
				break;
				case 6://Подсказка в палатке и складе
					blocksArray = [
						{ text: Locale.__e("flash:1487169539319"), dx:15 }
					];
					IconsArray = [
						{ icon:'octopusFlower', dy:-20, dx:0 }
					];
				break;
				case 7://Подсказка в капсуле
					blocksArray = [
						{ text: Locale.__e("flash:1493364380114"), dx:6 }
					];
					IconsArray = [
						{ icon:'paintImage', dy:0, dx:-40 }
					];
				break;
			}
			var numberYPosition:Number = 110;
			
			for (var blockIndex:* = 0; blockIndex < blocksArray.length; blockIndex++) {
				
				var indexText:String = '' + (blockIndex + 1);				
				
				/*var numberText:TextField = drawText(indexText, {
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
				
				var numberHalfY:* = numberText.y + numberText.height / 2;*/
				
				var textOne:TextField = drawText(blocksArray[blockIndex].text, {
					fontSize	:26,
					textAlign	:"center",
					color		:0x803d08,
					borderColor	:0xfef6ed,
					multiline	:true,
					border		:true,
					wrap		:true,
					width		:210
					
				});
				textOne.x = 205 + blocksArray[0].dx;
				textOne.y = (background.height - textOne.textHeight) / 2;
				layer.addChild(textOne);

			}
			//preloader.x = 110;
			//preloader.y = 120;
			/*layer.addChild(preloader);*/
			var bitmapOne:Bitmap;
			bitmapOne = new Bitmap(Window.textures[IconsArray[0].icon]);
			bitmapOne.x = 40 + IconsArray[0].dx;
			bitmapOne.y = IconsArray[0].dy;
			bodyContainer.addChild(bitmapOne);
			
			/*Load.loading(Config.getImage(IconsArray[0].type, IconsArray[0].icon), function(data:Bitmap):void 
			{				
				layer.removeChild(preloader);
				var bitmapOne:Bitmap = new Bitmap(data.bitmapData);
				//Size.size(bitmapOne, 90, 90);
				layer.addChild(bitmapOne);
				bitmapOne.smoothing = true;
				bitmapOne.x = 30;
				bitmapOne.y = 20;
			});*/

			//drawBttns();
		}
		
		/*private function drawBttns():void {
			
			okBttn = new Button( {
				width:175,
				height:55,
				fontSize:32,
				caption:Locale.__e("flash:1446800999662")//Понятно
			});
			layer.addChild(okBttn);
			okBttn.x = background.x + (background.width - okBttn.width) / 2;
			okBttn.y = (background.y + background.height - (okBttn.height / 2)) - 10;
			okBttn.addEventListener(MouseEvent.CLICK, close);
		}*/
	}

}