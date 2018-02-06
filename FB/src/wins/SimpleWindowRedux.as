package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import ui.Cursor;

	public class SimpleWindowRedux extends Window
	{
		public static const MATERIAL:int = 1;
		public static const ERROR:int = 6;
		public static const COLLECTION:int = 8;
		public static const ATTENTION:int = 9;
		public static const BUILDING:int = 10;
		public static const TREASURE:int = 11;
		public static const CRYSTALS:int = 12;
		public static const DAYLICS:int = 13;
		
		public var OkBttn:Button;
		public var ConfirmBttn:Button;
		public var CancelBttn:Button;		
		public var textLabel:TextField = null;
		
		private var bitmapLabel:Bitmap = null;
		private var innerBackground:Bitmap;
		
		public function SimpleWindowRedux(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['hasTitle']		= settings.hasTitle || false;
			settings['title'] 			= settings.title;
			settings["label"] 			= settings.label || null;
			settings['text'] 			= settings.text || '';
			settings['textAlign'] 		= settings.textAlign || 'center';
			settings['autoSize'] 		= settings.autoSize || 'center';
			settings['textSize'] 		= settings.textSize || 24;
			settings['padding'] 		= settings.padding || 20;			
			settings['hasButtons']		= settings['hasButtons'] == null ? true : settings['hasButtons'];
			settings['dialog']			= settings['dialog'] || false;
			settings['buttonText']		= settings['buttonText'] || Locale.__e('flash:1382952380298');
			settings['confirmText']		= settings['confirmText'] || Locale.__e('flash:1382952380299');
			settings['cancelText']		= settings['cancelText'] || Locale.__e('flash:1383041104026');		
			settings['confirm']			= settings.confirm || null;
			settings['onCloseFunction']	= settings.onCloseFunction || null;
			settings['cancel']			= settings.cancel || null;
			settings['ok']				= settings.ok || null;			
			settings["width"]			= settings.width || 480;
			settings["height"] 			= settings.height || 440;			
			settings["hasImage"] 		= settings.hasImage || false;			
			settings["imageID"] 		= settings.imageID || null;			
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;			
			settings["fontSize"]		= 38;			
			settings["hasPaper"]	 	= true;
			settings["hasExit"]			= settings.hasExit === false ? false : true;			
			settings["fontColor"]       = 0xffffff;			
			settings["bitmap"]	 		= settings.bitmap || null;
			settings["background"] 		= 'buildingBacking';
			
			if (!settings.hasOwnProperty("closeAfterOk"))
			{
				settings["closeAfterOk"] = true
			}
			
			super(settings);
		}
		
		override public function drawBody():void
		{	
			//внутренняя подложка
			innerBackground = Window.backing(settings.width - 60, settings.height - 70, 40, 'paperBacking');
			layer.addChild(innerBackground);
			innerBackground.x = (settings.width - settings.width) + settings.width / 2 - innerBackground.width / 2;
			innerBackground.y = (settings.height - settings.height) + settings.height / 2 - innerBackground.height / 2;
			
			if (settings.hasTitle) 
			{
				drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, titleLabel.y, true, true);
			}			
			drawMirrowObjs('storageWoodenDec', -10, settings.width, settings.height - 70);
			drawMirrowObjs('storageWoodenDec', -10, settings.width, 80, false, false, false, 1, -1);
			
			/*var exit:ImageButton = new ImageButton(textures.closeBttn);
			addChildAt(exit, 5);
			exit.x = settings.width - 60;
			exit.y = -5;
			exit.addEventListener(MouseEvent.CLICK, close);*/
			
			drawBttns();			
			
			//Основной текст
			textLabel = Window.drawText(settings.text, {
				color			:0xffffff,
				borderColor		:0x7a471c,
				width			:320,
				multiline		:true,
				wrap			:true,
				textAlign		:'center',
				fontSize		:26
			});	
			textLabel.x = innerBackground.x + innerBackground.width / 2 - textLabel.width / 2;
			textLabel.y = innerBackground.y + innerBackground.height / 2 - textLabel.height / 2;
			layer.addChild(textLabel);
			
			if (settings.hasImage) 
			{
				if (settings.imageID && settings.imageID == 1) 
				{
					Load.loading(Config.getImage('actions', 'girl_and_butterfly'), onPicLoad);
				}				
			}
		}
		
		private function onPicLoad(data:Bitmap):void 
		{			
			addPicState(data.bitmapData);			
		}
		
		private function addPicState(bmd:BitmapData):void 
		{
			var bitmap:Bitmap = new Bitmap(bmd);
			bitmap.smoothing = true;
			bitmap.x = settings.width - bitmap.width - bitmap.width + bitmap.width / 2 - 100;
			bitmap.y -= 30;
			if (settings.imageID == 1) 
			{
				bitmap.scaleX = bitmap.scaleY = 1;
				bitmap.x -= 100;
				bitmap.y += 10;
			}
			layer.addChild(bitmap);	
		}		
		
		override public function drawExit():void 
		{
			
		}	
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: true,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 80,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			} )
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = settings.height - settings.height - titleLabel.height / 2 + 10; 
			bodyContainer.addChild(titleLabel);
		}
		
		public function drawBttns():void 
		{
			if (settings.hasButtons)
			{
				if(settings.dialog == false){
					OkBttn = new Button( {
						caption:settings.buttonText,
						fontSize:26,
						width:160,
						hasDotes:false,
						height:47
					});
					OkBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);//onOkBttn
				
					bodyContainer.addChild(OkBttn);
					OkBttn.x = settings.width / 2 - OkBttn.width / 2;
					OkBttn.y = settings.height - OkBttn.height / 2 - 5;
					
				}else{
					
					var confirmSettings:Object = {
						caption:settings.confirmText,
						width:140,
						hasDotes:false,
						height:40
					}
					
					var cancelSettings:Object = {
						caption:settings.cancelText,
						width:140,
						hasDotes:false,
						height:40
					}
					
					if (settings.hasOwnProperty('confirmSettings'))
						confirmSettings = settings.confirmSettings;
						
					if (settings.hasOwnProperty('cancelSettings'))
						cancelSettings = settings.cancelSettings;
					
					ConfirmBttn = new Button(confirmSettings);
					ConfirmBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);
					
					CancelBttn = new Button(cancelSettings);
					CancelBttn.addEventListener(MouseEvent.CLICK, onCancelBttn);
					
					ConfirmBttn.x = settings.width / 2 - ConfirmBttn.width/* + 4*/-4;
					CancelBttn.x = settings.width / 2/* - 4*/-4;
					ConfirmBttn.y = settings.height - ConfirmBttn.height / 2 - 5;
					CancelBttn.y = settings.height - CancelBttn.height / 2 - 5;
					bodyContainer.addChild(ConfirmBttn);
					bodyContainer.addChild(CancelBttn);
				}
			}
			
			bottomContainer.y = settings.height - bottomContainer.height - 36;
			bottomContainer.x = 0;
		}
		
		public function onOkBttn(e:MouseEvent):void {
			if (settings.ok is Function) {
				settings.ok();
			}
			if(settings.closeAfterOk)
				close();
		}
		
		public function onConfirmBttn(e:MouseEvent):void {
			if (settings.confirm is Function) {
				settings.confirm();
			}
			close();
		}

		public function onCancelBttn(e:MouseEvent):void {
			if (settings.cancel is Function) {
				settings.cancel();
			}
			close();
		}
		
		override public function dispose():void {
			if(OkBttn != null){
				OkBttn.removeEventListener(MouseEvent.CLICK, onOkBttn);
			}
			if(ConfirmBttn!= null){
				ConfirmBttn.removeEventListener(MouseEvent.CLICK, onConfirmBttn);
			}
			if(CancelBttn != null){
				CancelBttn.removeEventListener(MouseEvent.CLICK, onCancelBttn);
			}
			
			//App.self.setOffTimer(update);
			super.dispose();
		}
	}
}