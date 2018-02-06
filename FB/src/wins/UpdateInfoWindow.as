package wins 
{
	import buttons.Button;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import ui.Cursor;

	public class UpdateInfoWindow extends Window
	{
		public static const MATERIAL:int = 1;
		public static const ERROR:int = 6;
		public static const COLLECTION:int = 8;
		public static const ATTENTION:int = 9;
		public static const BUILDING:int = 10;
		public static const TREASURE:int = 11;
		public static const CRYSTALS:int = 12;
		
		public var OkBttn:Button;
		public var ConfirmBttn:Button;
		public var CancelBttn:Button;
		
		public var updateListContainer:Sprite = new Sprite();
		//public var headerImage:Sprite = new Sprite();
		
		public var textLabel:TextField = null;
		public var _titleLabel_titleLabel:TextField = null;
		
		private var bitmapLabel:Bitmap = null;
		private var dY:int = 0;
		private var dX:int = 0;
		private var textLabel_dY:int = 0;
		private var titleLabel_dY:int = 0;
		
		public function UpdateInfoWindow(settings:Object = null)
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
			settings['cancel']			= settings.cancel || null;
			settings['ok']				= settings.ok || null;
			
			settings["width"]			= settings.width || 470;// 380;
			settings["height"] 			= settings.height || 465;// 365;
			
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;
			
			settings["fontSize"]		= 38;
			
			settings["hasPaper"]	 	= true;
			settings["hasTitle"]		= true;
			settings["hasExit"]			= settings.hasExit || false;
			
			settings["fontColor"]       = 0xffffff//0xf5cf57;
			
			settings["hasExit"]         = true;
			
			settings["bitmap"]	 		= settings.bitmap || null;
			if (!settings.hasOwnProperty("closeAfterOk"))
			{
				settings["closeAfterOk"] = true
			}
			
			textLabel_dY = 0;
			
			super(settings);
		}
		override public function drawExit():void {
				super.drawExit();
				exit.x = settings.width - exit.width / 2;
				exit.y = -6;
		}
		public function drawBcDecor():void {
			drawMirrowObjs('decorTopLiana', -5, settings.width+5, -25);
			drawMirrowObjs('decorBotHameleo', -5, settings.width+5, settings.height - 147);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 45, "buildingBacking");
			var headerImage:Bitmap = new Bitmap();
			Load.loading(Config.getImage('informers', 'updateHeader'),
				function(data:*):void {
						headerImage.bitmapData = data.bitmapData;
					} );
			bodyContainer.addChild(background);
			bodyContainer.getChildIndex(background);
			bodyContainer.swapChildren(background, bodyContainer.getChildAt(0));
			drawBcDecor();
			bodyContainer.addChild(headerImage);
			headerImage.y = -182;
			bodyContainer.addChild(updateListContainer);
			drawTitle();
			

			background.y -= 20;
		}
		
		public function drawUpdateList():void {
			var back:Bitmap = backing2(/*backWidth*/textLabel.textWidth + 50, settings.height, 45, "questsSmallBackingTopPiece", 'questsSmallBackingBottomPiece');				
			
			back = backing(438, 366, 25, "dialogueLightBacking");
			back.x = 19;
			back.y = 67;
			
			updateListContainer.addChildAt(back, 0);
			
			textLabel.x = back.x + (back.width - textLabel.width) / 2;
			textLabel.y = back.y + (back.height - textLabel.height) / 2 - 5;
			
			var _textSettings:Object = {
				width:341,
				height:296,
				color:0x663719,
				fontSize:30,
				border:false,
				scale:1,
				textAlign:'left',
				multiline:true
			}
			
			var updateText:TextField = Window.drawText(settings.text, _textSettings);
			updateText.x = 67;
			updateText.y = 114;
			updateListContainer.addChild(updateText);
		}
		
		override public function drawBody():void {
			this.y += 63;
			fader.y -= 63;
			var textFontSize:int;
			if (settings.title != null)
			{
				textFontSize = settings.textSize;
			}else
				textFontSize = settings.textSize + 8;
			textLabel = Window.drawText(settings.text, {
				color:0x6f3d1a,
				borderColor:0xfff7ee,
				borderSize:4,
				fontSize:textFontSize,
				textAlign:settings.textAlign,
				autoSize:settings.autoSize,
				multiline:true
			});

			textLabel.wordWrap = true;
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			textLabel.width = settings.width - 100;
			textLabel.height = textLabel.textHeight + 4;
			
			var y1:int = titleLabel.y + titleLabel.height;
			var y2:int = bottomContainer.y;
			
			bodyContainer.addChild(textLabel);
			
			drawUpdateList();
			
			drawBttns();
			
			if (settings.title != null) {
				drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, settings.titleHeight/2 + titleLabel.y + 2, true, true, true);
			}
			
			if (settings.hasOwnProperty('timer')) {
				drawTimer();
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
				color				: settings.fontColor,
				multiline			: true,			
				fontSize			: 36,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0xc76e10,
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 80,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) /2;
			titleLabel.y = 55; 
			bodyContainer.addChildAt(titleLabel, bodyContainer.numChildren);
			var lastChld:* = titleLabel.getChildAt(titleLabel.numChildren - 1);
			
			var tw:uint = lastChld['textWidth'];
			var th:uint = lastChld['textHeight'];
			titleLabel.y += 10 - th / 2;
			drawMirrowObjs('diamondsTop', (settings.width - tw) / 2 - 5, (settings.width + tw)/ 2 + 5, titleLabel.y+th/4, true, true);
		}
		
		public function drawBttns():void 
		{
			
			OkBttn = new Button( {
				caption:settings.buttonText,
				fontSize:30,
				width:178,
				hasDotes:false,
				height:55
			});
			OkBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);//onOkBttn
		
			updateListContainer.addChild(OkBttn);
			OkBttn.x = settings.width / 2 - OkBttn.width / 2;
			OkBttn.y = settings.height - OkBttn.height;
		}
		
		public function bringToFront(childMc:*):void {
			if (!childMc.parent)
				return;
			
			var parentMc:* = childMc.parent;
			var highest:* = parentMc.getChildAt(parentMc.numChildren-1);
			parentMc.swapChildren(childMc, highest);
		}
		
		public function bringToBack(childMc:*):void {
			if (!childMc.parent)
				return;
			
			var parentMc:* = childMc.parent;
			var lowest:* = parentMc.getChildAt(0);
			parentMc.swapChildren(childMc, lowest);
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
			
			App.self.setOffTimer(update);
			super.dispose();
		}
	}
}