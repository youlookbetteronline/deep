package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class BubbleInputWindow extends Window 
	{
		private var _inputField:TextField;
		private var _bttn:Button;
		public function BubbleInputWindow(settings:Object=null) 
		{
			settings = settingsInit(settings);
			super(settings);
			
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			settings["width"]				= 470;
			settings["height"] 				= 275;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			settings['exitTexture'] 		= 'blueClose';
			settings['fontColor'] 			= 0x004762;
			settings['fontBorderColor'] 	= 0xffffff;
			settings['fontBorderSize']		= 4;
			settings['fontSize'] 			= 40;
			
			return settings;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing4(settings.width, settings.height, 126, 'blueBackingSmallTL', 'blueBackingSmallTR', 'blueBackingSmallBL', 'blueBackingSmallBR');
			layer.addChild(background);	
		}
		
		override public function drawBody():void 
		{
			drawInput();
			drawButton();
			build();
		}
		
		private function drawInput():void 
		{
			_inputField = Window.drawText('', 
			{
				fontSize:	32,
				color:		0xffffff,
				borderColor:0x004762,
				autoSize:	"center",
				textAlign:	"center",
				input:		true,
				multiline:	true,
				wrap:		true,
				width:		320,
				height:		120
			});
			if (_inputField.length >= settings.maxLength)
				_inputField.text.slice(0, settings.maxLength);
			_inputField.setSelection(_inputField.length, _inputField.length);
			App.self.stage.focus = _inputField;
			_inputField.addEventListener(Event.CHANGE, onChange);
		}
		
		public function onChange(e:Event):void
		{
			var currentText:String = e.currentTarget.text
			var currentLength:int = currentText.length
			
			if (currentLength > settings.maxLength || e.currentTarget.numLines > 5)
				e.currentTarget.text = currentText.substring(0, currentLength - 1)
			_inputField.wordWrap = true;
		}
		
		private function drawButton():void 
		{
			_bttn = new Button({
				caption:'Отправить',
				fontSize:26,
				width:160,
				hasDotes:false,
				height:55
			})
			_bttn.addEventListener(MouseEvent.CLICK, onConfirm);
		}
		
		private function onConfirm(e:MouseEvent):void 
		{
			settings.confirm(_inputField.text)
		}
		private function build():void 
		{
			exit.x -= 10;
			exit.y += 15;
			
			titleLabel.y += 35;
			
			
			_inputField.x = (settings.width - _inputField.width) / 2;
			_inputField.y = 45;
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - _bttn.height - 10;
			
			bodyContainer.addChild(_inputField);
			bodyContainer.addChild(_bttn);
		}
		
	}

}