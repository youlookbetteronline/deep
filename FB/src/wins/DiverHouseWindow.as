package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author abdurda
	 */
	public class DiverHouseWindow extends Window
	{
		public var picture:Bitmap;
		public var okBttn:Button;
		public var moveBttn:Button;
		public var textLabel:TextField = null;
		
		private var maska:Shape = new Shape();
		private var pictureBG:Shape = new Shape();
		private var titleBackingRibon:Bitmap = new Bitmap();
		public function DiverHouseWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['hasButtons']		= false;
			//settings['title']		= '';
			settings["width"]			= 540;
			settings["height"] 			= 520;		
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;			
			settings["fontSize"]		= 38;	
			settings["hasTitle"]		= true;
			settings["hasExit"]			= true;			
			settings["fontColor"]       = 0xffffff;
			settings['exitTexture'] 	= 'closeBttnMetal';
			settings['background'] 		= 'capsuleWindowBacking';
			//settings['hasBubbles']		= false;
			//settings['bubblesCount']	= 6;
			//settings['bubbleRightX']	= 0;
			//settings['bubbleLeftX']		= 0;
			super(settings);
		}
		
		override public function drawBody():void
		{
			drawBttns();
			drawPicture();
			drawMirrowObjs('decSeaweed', settings.width + 57, - 57, settings.height - 177, true, true, false, 1, 1, layer);
			exit.y -= 25;
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.target.info.title,
				color				: 0xf9fdff,
				multiline			: settings.multiline,			
				fontSize			: 40,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x085c10,			
				borderSize 			: settings.fontBorderSize,	
				shadowColor     	: 0x235b00,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			
			drawRibbon();
			titleLabel.y += 11;
			
		}
		
		private function drawPicture():void 
		{
			picture = new Bitmap();
			
			layer.addChild(pictureBG);
			layer.addChild(maska);
			layer.addChild(picture);
			
			Load.loading(Config.getImage('other_img', 'DiverHousePicture', 'jpg'), function (data:*):void {
				picture.bitmapData = data.bitmapData;
				Size.size(picture, 430, 340, true);
				picture.x = (settings.width - picture.width) / 2;
				picture.y = 30;
				
				maska.graphics.beginFill(0xFFFFFF, 1);
				maska.graphics.drawRoundRect(0, 0, picture.width, picture.height - 30, 25, 25);
				maska.graphics.endFill();
				maska.x = (settings.width - maska.width) / 2;
				maska.y = picture.y + 30;
				picture.mask = maska;
				
				pictureBG.graphics.beginFill(0xFFFFFF, 1);
				pictureBG.graphics.drawRoundRect(0, 0, maska.width + 20, maska.height + 20, 25, 25);
				//pictureBG..filters = [new DropShadowFilter(4, 90, 0x000000, 0.7, 4, 4, 8, 1, true), new DropShadowFilter(1, -90, 0xffffff, .7, 4, 4, 4, 1, true)];
				pictureBG.graphics.endFill();
				pictureBG.x = maska.x - (pictureBG.width - maska.width) / 2;
				pictureBG.y = maska.y - (pictureBG.height - maska.height) / 2;
				
			});
			
			var text:String = Locale.__e('flash:1496994017968'/*,  App.data.storage[settings.target.info.lands[0]].title*/);
			textLabel = Window.drawText(text, {
				color		:0xffffff,
				border		:true,
				borderColor :0x7e3e13,
				fontSize	:30,
				textAlign	:'center',
				multiline	:true,
				textLeading :-8,
				wrap		:true,
				width		:450
			});		
			textLabel.x = (settings.width - textLabel.width) / 2;
			textLabel.y = settings.height - 173;
			bodyContainer.addChild(textLabel);
		}
		
		public function drawBttns():void 
		{
			okBttn = new Button( {
				caption:Locale.__e('flash:1394010224398'),
				bgColor:[0xfed131, 0xf8ab1a],
				fontSize:26,
				width:140,
				hasDotes:false,
				height:47
			});
			okBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);
			bodyContainer.addChild(okBttn);
			okBttn.x = (settings.width - okBttn.width) / 2 - okBttn.width/2 - 10;
			okBttn.y = settings.height - okBttn.height - 65;
			okBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			
			moveBttn = new Button( {
				caption			:Locale.__e('flash:1434377492145'),
				bgColor			:[0xc6e314, 0x80b631],
				bevelColor		:[0xf7fe9a, 0x577c2d],
				fontBorderColor	:0x185b06,
				fontSize		:26,
				width			:140,
				hasDotes		:false,
				height			:47
			});
			moveBttn.addEventListener(MouseEvent.CLICK, onMoveBttn);
			bodyContainer.addChild(moveBttn);
			moveBttn.x = (settings.width - moveBttn.width) / 2 + moveBttn.width / 2 + 10;
			moveBttn.y = okBttn.y;
			moveBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
		}
		
		public function onConfirmBttn(e:MouseEvent):void {
			if (settings.confirm is Function) {
				settings.confirm();
			}
			close();
		}

		public function onMoveBttn(e:MouseEvent):void {
			if (settings.cancel is Function) {
				settings.cancel();
			}
			close();
		}
	
	}

}