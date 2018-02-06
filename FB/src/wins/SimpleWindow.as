package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import ui.Cursor;

	public class SimpleWindow extends Window
	{
		public static const MATERIAL:int = 1;
		public static const ERROR:int = 6;
		public static const COLLECTION:int = 8;
		public static const ATTENTION:int = 9;
		public static const BUILDING:int = 10;
		public static const TREASURE:int = 11;
		public static const CRYSTALS:int = 12;
		public static const DAYLICS:int = 13;
		
		public var okBttn:Button;
		public var confirmBttn:Button;
		public var cancelBttn:Button;
		
		public var textLabel:TextField = null;
		public var _titleLabel_titleLabel:TextField = null;
		
		private var bitmapLabel:Bitmap = null;
		private var dY:int = 0;
		private var dX:int = 0;
		private var textLabel_dY:int = 0;
		private var titleLabel_dY:int = 0;
		private var textLabelOffsetY:int = 0;
		
		public function SimpleWindow(settings:Object = null)
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
			settings['input']			= settings['input'] || false;
			settings['buttonText']		= settings['buttonText'] || Locale.__e('flash:1382952380298');
			settings['confirmText']		= settings['confirmText'] || Locale.__e('flash:1382952380299');
			settings['cancelText']		= settings['cancelText'] || Locale.__e('flash:1383041104026');		
			settings['confirm']			= settings.confirm || null;
			settings['onCloseFunction']	= settings.onCloseFunction || null;
			settings['cancel']			= settings.cancel || null;
			settings['ok']				= settings.ok || null;			
			settings["width"]			= settings.width || 510;// 380;
			settings["height"] 			= settings.height || 165;// 365;			
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;			
			settings["fontSize"]		= 38;			
			settings["hasPaper"]	 	= true;
			settings["hasTitle"]		= true;
			settings["hasExit"]			= settings.hasExit === true ? true : false;			
			settings["fontColor"]       = 0xffffff;			
			settings["bitmap"]	 		= settings.bitmap || null;
			
			if (!settings.hasOwnProperty("closeAfterOk"))
			{
				settings["closeAfterOk"] = true
			}
			textLabelOffsetY			= settings.textLabelOffsetY || 0;// 365;
			textLabel_dY = 0;
			
			super(settings);
		}
		
		override public function drawExit():void {			
		}
		override public function drawBackground():void {
		}
		
		override public function drawBody():void
		{
			if (settings.isImg) 
			{
				var robotIcom:Bitmap = new Bitmap(Window.textures.errorOops);
				bodyContainer.addChild(robotIcom);
				robotIcom.x = -110;
				robotIcom.y = -90;
			}
			
			if (settings.offsetY) 
			{
				this.y = settings.offsetY;
				fader.y = Math.abs(settings.offsetY);
			}
			if (settings.offsetX) 
			{
				this.x = settings.offsetX;
				fader.x =  Math.abs(settings.offsetX);
			}
			
			var textFontSize:int;
			if (settings.title != null)
			{
				textFontSize = settings.textSize + 6;
			}else
				textFontSize = settings.textSize + 10;
			
			textLabel = Window.drawText(settings.text, {
				color:0x6f3d1a,
				borderColor:0xfff7ee,
				borderSize:4,
				fontSize:textFontSize,
				textAlign:settings.textAlign,
				autoSize:settings.autoSize,
				input:settings.input,
				multiline:true
			});			
			
			textLabel.wordWrap = true;
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			textLabel.width = settings.width - 100;
			textLabel.height = textLabel.textHeight + 4;
			//textLabel.border = true;
			if(settings.input)
				textLabel.mouseEnabled = true;
			
			var y1:int = titleLabel.y + titleLabel.height;
			var y2:int = bottomContainer.y;

			bodyContainer.addChild(textLabel);
			
			var backWidht:int;
			var backHeight:int;
			
			//if (textLabel.textWidth + 70 >= 255) 
			//{
				backWidht = textLabel.textWidth + 70;
			//}else
				//backWidht = 255;
			
			if (backWidht < settings.width)
				backWidht = settings.width;
				
			if (textLabel.textHeight + 80 >= 150) 
			{
				backHeight = textLabel.textHeight + 80;
			}else
				backHeight = 150;
			
			back = backing(backWidht, backHeight, 95, "paperGlow");
			back.x = (settings.width - back.width) / 2;
			back.y = -30;
			bodyContainer.addChildAt(back, 0);
			
			drawMirrowObjs('decSeaweed', back.x + back.width + 59, back.x - 57, backHeight - 200, true, true, false, 1, 1, bodyContainer);
			
			drawBttns();
			textLabel.x = back.x + (back.width - textLabel.width) / 2;
			textLabel.y = back.y + (back.height - textLabel.height) / 2 +textLabelOffsetY;
			
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			
			if (settings.hasExit) 
			{
				headerContainer.addChild(exit);
			}	
			
			exit.x = back.x + back.width - 40;
			exit.y = back.y + 15;
			exit.addEventListener(MouseEvent.CLICK, close);
			
			if (settings.hasOwnProperty('timer'))
			{
				drawTimer();
			}
		}
		
		override public function close(e:MouseEvent = null):void 
		{
			super.close();
			if (settings.onCloseFunction) 
			{
				settings.onCloseFunction();
			}
		}
		
		private var timer:TextField
		private var back:Bitmap;
		private function drawTimer():void 
		{
			textLabel.y -= 20;
			timer = Window.drawText(TimeConverter.timeToStr(settings.timer), {
				color:0xffffff,
				letterSpacing:3,
				textAlign:"center",
				fontSize:35,
				borderColor:0x502f06
			});
			timer.width = settings.width - 60;
			timer.x = 30;
			timer.y = textLabel.y + textLabel.height + 10;
			
			var glowing:Bitmap = new Bitmap(Window.textures.actionGlow);
			glowing.alpha = 0.8;
			
			bodyContainer.addChildAt(glowing,0);
			glowing.x = (settings.width - glowing.width) / 2;
			glowing.y = timer.y + (timer.textHeight - glowing.height) / 2 - 25;
			
			bodyContainer.addChild(timer);
			
			App.self.setOnTimer(update);
		}
		
		private function update():void {
			settings.timer --;
			timer.text = TimeConverter.timeToStr(settings.timer);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title, 
				color				: 0xfdff54,
				multiline			: settings.multiline,			
				fontSize			: 45,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x854815,			
				borderSize 			: 3,					
				shadowColor			: 0x713f15,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center'
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -20;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		public function drawBttns():void 
		{
			if (settings.hasButtons)
			{
				if(settings.dialog == false){
					okBttn = new Button( {
						caption:settings.buttonText,
						fontSize:26,
						width:160,
						hasDotes:false,
						height:47
					});
					okBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);//onOkBttn
				
					bodyContainer.addChild(okBttn);
					okBttn.x = (settings.width- okBttn.width) / 2;
					okBttn.y = back.y + back.height - okBttn.height / 2;
					
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
					
					confirmBttn = new Button(confirmSettings);
					confirmBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);
					
					cancelBttn = new Button(cancelSettings);
					cancelBttn.addEventListener(MouseEvent.CLICK, onCancelBttn);
					
					confirmBttn.x = settings.width / 2 - confirmBttn.width - 4;
					cancelBttn.x = settings.width / 2 +4;
					confirmBttn.y = back.height -60;
					cancelBttn.y = back.height -60;
					bodyContainer.addChild(confirmBttn);
					bodyContainer.addChild(cancelBttn);
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
			if(okBttn != null){
				okBttn.removeEventListener(MouseEvent.CLICK, onOkBttn);
			}
			if(confirmBttn!= null){
				confirmBttn.removeEventListener(MouseEvent.CLICK, onConfirmBttn);
			}
			if(cancelBttn != null){
				cancelBttn.removeEventListener(MouseEvent.CLICK, onCancelBttn);
			}
			
			App.self.setOffTimer(update);
			super.dispose();
		}
	}
}