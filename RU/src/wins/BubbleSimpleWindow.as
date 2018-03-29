package wins 
{
	import buttons.Button;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class BubbleSimpleWindow extends Window 
	{
		private var _label:TextField;
		private var _leftBttn:Button;
		private var _rightBttn:Button;
		private var _confirmBttn:Button;
		private var _timeToFinish:int = 0;
		public function BubbleSimpleWindow(_settings:Object=null) 
		{
			if (settings == null)
				settings = {};
			for (var property:* in _settings)
			{
				settings[property] = _settings[property];
			}
			settings["background"]			= 'bubbleBlueBacking'
			settings['fontColor'] 			= 0xfff94e;
			settings['fontBorderColor'] 	= 0x2b4a84;
			settings['fontBorderSize']		= 4;
			settings['fontSize'] 			= 48;
			settings['exitTexture'] 		= 'purpleClose';
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			settings["width"]				= 480;
			drawDescription();
			settings["height"] 				= 130 + _label.textHeight;
			settings["leftBttnText"] 		= settings.leftBttnText || Locale.__e('flash:1382952380299');
			settings["rightBttnText"] 		= settings.rightBttnText || Locale.__e('flash:1383041104026');
			settings["confirmBttnText"] 	= settings.confirmBttnText || Locale.__e('flash:1382952380242');
			settings["dialog"]				= settings.dialog || false;
			settings["timer"]				= settings["timer"] || {
				enabled	: false,
				text	: '',
				finish	: 0
			}
			super(settings);
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 80, settings.background);
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			build();
			if (settings.dialog)
				drawDialogButtons()
			else
				drawConfirmButton()
		}
		
		private function drawDescription():void 
		{
			if (settings.timer && settings.timer.enabled)
			{
				_timeToFinish = settings.timer.finish - App.time;
				_label = Window.drawText(settings.timer.text + '\n' + TimeConverter.timeToDays(_timeToFinish), {
					color			:0xffffff,
					borderColor		:0x2b4a84,
					borderSize		:4,
					fontSize		:32,
					width			:settings.width - 100,
					textAlign		:'center',
					wrap			:true,
					multiline		:true
				})
				App.self.setOnTimer(rewriteDescription)
			}
			else
			{
				_label = Window.drawText(settings.label, {
					color			:0xffffff,
					borderColor		:0x2b4a84,
					borderSize		:4,
					fontSize		:32,
					width			:settings.width - 100,
					textAlign		:'center',
					wrap			:true,
					multiline		:true
				})
			}
			
		}
		
		private function rewriteDescription():void 
		{
			_timeToFinish = settings.timer.finish - App.time;
			_label.text = settings.timer.text + '\n' + TimeConverter.timeToDays(_timeToFinish)
			if (_timeToFinish <= 0)
			{
				Window.closeAll();
				App.self.setOffTimer(rewriteDescription);
			}
		}
		
		private function drawDialogButtons():void 
		{
			
			_leftBttn = new Button({
				caption			:settings.leftBttnText,
				fontColor		:0xffffff,
				width			:170,
				height			:51,
				fontSize		:32,
				bgColor			:[0xbcec63, 0x68bc21],
				bevelColor		:[0xe0ffad, 0x4e8b2c],
				fontBorderColor	:0x085c10
			});
			
			_rightBttn = new Button({
				caption			:settings.rightBttnText,
				fontColor		:0xffffff,
				width			:170,
				height			:51,
				fontSize		:32,
				bgColor			:[0xfed131, 0xf8ab1a],
				bevelColor		:[0xf7fe9a, 0xcb6b1e],
				fontBorderColor	:0x6e411e
			});
			
			_leftBttn.y = settings.height - _leftBttn.height - 20;
			_leftBttn.x = settings.width / 2 - _leftBttn.width - 15;
			
			_rightBttn.y = settings.height - _rightBttn.height - 20;
			_rightBttn.x = settings.width / 2 + 15;
			
			bodyContainer.addChild(_leftBttn);
			bodyContainer.addChild(_rightBttn);
			
			_leftBttn.addEventListener(MouseEvent.CLICK, onLeftClick)
			_rightBttn.addEventListener(MouseEvent.CLICK, onRightEvent)
		}
		
		private function onLeftClick(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			e.currentTarget.state = Button.DISABLED;
			if (settings.leftBttnEvent)
				settings.leftBttnEvent()
			else
				close();
		}
		
		private function onRightEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			e.currentTarget.state = Button.DISABLED;
			if (settings.rightBttnEvent)
				settings.rightBttnEvent()
			else
				close();
				
			
		}
		
		private function drawConfirmButton():void 
		{
			
			_confirmBttn = new Button({
				caption			:settings.confirmBttnText,
				fontColor		:0xffffff,
				width			:170,
				height			:51,
				fontSize		:32,
				bgColor			:[0xfed131, 0xf8ab1a],
				bevelColor		:[0xf7fe9a, 0xcb6b1e],
				fontBorderColor	:0x6e411e
			});
			
			_confirmBttn.y = settings.height - _confirmBttn.height - 20;
			_confirmBttn.x = (settings.width - _confirmBttn.width) / 2;
			
			bodyContainer.addChild(_confirmBttn);
			
			_confirmBttn.addEventListener(MouseEvent.CLICK, onConfirmEvent)
		}
		
		private function onConfirmEvent(e:MouseEvent):void 
		{
			if (settings.confirmBttnEvent)
				settings.confirmBttnEvent();
			else
				close();
		}
		
		private function build():void 
		{
			if (exit)
			{
				exit.y += 13;
				exit.x -= 15;
			}
			
			
			_label.x = (settings.width - _label.width) / 2;
			_label.y = 30
			
			bodyContainer.addChild(_label);
		}
		
	}

}