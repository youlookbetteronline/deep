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
	public class ExpeditionHintWindow extends Window 
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
		
		public function ExpeditionHintWindow(settings:Object=null)  
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['hintsNum'] = settings.hintsNum;
			settings['hintID'] = settings.hintID;
			settings['title'] = settings.title || Locale.__e('flash:1382952380254')//Помощь;
			settings['width'] = 575;	
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
			
			var IconsArray:Array = new Array();
			var blocksArray:Array;
			switch (settings.hintID) 
			{
				case 1://Подсказка в Столе
					blocksArray = [
						{ text: Locale.__e("flash:1478705076410") },
						{ text: Locale.__e("flash:1478705269503") },
						{ text: Locale.__e("flash:1478705359104") }
					];
					IconsArray = [
						{ type:'Building/', icon:'kitchen' },
						{ type:'Table/', icon:'fish_table' },
						{ type:'Walkgolden/', icon:'blue_orange_fish' }
					];
				break;
				case 2://Подсказка в палатке и складе
					blocksArray = [
						{ text: Locale.__e("flash:1495611160410") },
						{ text: Locale.__e("flash:1495611195839") },
						{ text: Locale.__e("flash:1495611209519") }
					];
					IconsArray = [
						{ type:'Wigwam/', icon:'tent_travel2' },
						{ type:'Building/', icon:'volleyball_court2' },
						{ type:'Resource/', icon:'neptunaria' }
					];
				break;
				case 3://Подсказка в Рыбе-собаке
					blocksArray = [
						{ text: Locale.__e("flash:1496235402242") },
						{ text: Locale.__e("flash:1496235448857") },
						{ text: Locale.__e("flash:1496235529756") }
					];
					IconsArray = [
						{ type:'Pet/', icon:'fishdog' },
						{ type:'Resource/', icon:'resource_250' },
						{ type:'Material/', icon:'gl_5smithers0' }
					];
				case 4://Подсказка в рюкзаке экспедиции
					blocksArray = [
						{ text: Locale.__e("flash:1505914684889") },
						{ text: Locale.__e("flash:1505914734241") },
						{ text: Locale.__e("flash:1505914787968") }
					];
					IconsArray = [
						{ type:'Golden/', icon:'treasure' },
						{ type:'Content/', icon:'Ministock' },
						{ type:'Content/', icon:'stockIcon' }
					];
				break;
				case 5://Ловец течений
					blocksArray = [
						{ text: Locale.__e("flash:1505131604116") },
						{ text: Locale.__e("flash:1505131755291") },
						{ text: Locale.__e("flash:1505131810321") }
					];
					IconsArray = [
						{ type:'Building/', icon:'sinoptic' },
						{ type:'Content/', icon:'net_mat' },
						{ type:'Content/', icon:'keys' }
					];
				break;
				case 6://Аукцион
					blocksArray = [
						{ text: Locale.__e("flash:1506436249162") },
						{ text: Locale.__e("flash:1506436296249") },
						{ text: Locale.__e("flash:1506436323449") }
					];
					IconsArray = [
						//{ type:'Building/', icon:'sinoptic' },
						//{ type:'Content/', icon:'net_mat' },
						//{ type:'Content/', icon:'keys' }
					];
				case 7://Мапы синоптика
					blocksArray = [
						{ text: Locale.__e("flash:1507294072420") },
						{ text: Locale.__e("flash:1507294108490") },
						{ text: Locale.__e("flash:1507294126953") }
					];
					IconsArray = [
						{ type:'Golden/', icon:'treasure' },
						{ type:'Content/', icon:'arrowStock' },
						{ type:'Content/', icon:'stockIcon' }
					];
				break;
			}
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
					width		:295
				});
				
				textOne.x = 100;
				textOne.y = numberHalfY - textOne.height / 2 - 0;
				layer.addChild(textOne);
				
				numberYPosition += 130;
				
			}
			
			if (IconsArray[0])
			{
				Load.loading(Config.getIcon(IconsArray[0].type, IconsArray[0].icon), function(data:Bitmap):void 
				{				
					var bitmapOne:Bitmap = new Bitmap(data.bitmapData);
					Size.size(bitmapOne, 90, 90);
					layer.addChild(bitmapOne);
					bitmapOne.smoothing = true;
					bitmapOne.x = settings.width - bitmapOne.width / 2 - 110;
					bitmapOne.y = 95;
				});
			}
			
			if (IconsArray[1])
			{
				Load.loading(Config.getIcon(IconsArray[1].type, IconsArray[1].icon), function(data:Bitmap):void {
					
					var bitmapTwo:Bitmap = new Bitmap(data.bitmapData);
					Size.size(bitmapTwo, 90, 90);
					layer.addChild(bitmapTwo);
					bitmapTwo.smoothing = true;
					bitmapTwo.x = settings.width - bitmapTwo.width / 2 - 110;
					bitmapTwo.y = 95 + 130;
				});
			}
			
			if (IconsArray[2])
			{
				Load.loading(Config.getIcon(IconsArray[2].type, IconsArray[2].icon), function(data:Bitmap):void 
				{				
					var bitmapThree:Bitmap = new Bitmap(data.bitmapData);
					Size.size(bitmapThree, 90, 90);
					layer.addChild(bitmapThree);
					bitmapThree.smoothing = true;
					bitmapThree.x = settings.width - bitmapThree.width / 2 - 110;
					bitmapThree.y = 95 + 130 + 130;
				});
			}
			
			drawMirrowObjs('decSeaweed', settings.width + 35, - 35, settings.height - 179, true, true, false, 1, 1);
			
			drawBttns();
		}
		
		private function drawBttns():void {
			
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
		}
	}

}