package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author das
	 */
	public class InputMoneyWindow extends Window
	{
		public var inputField:TextField;
		public function InputMoneyWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['hasPaginator'] = false;
			settings['background'] = 'paperScroll';
			settings['width'] = 400;
			settings['height'] = 200;
			settings['fontColor'] = 0xffdf34;
			settings['fontBorderColor'] = 0x492103;
			settings['borderColor'] = 0x451c00;
			settings['shadowColor'] = 0x492103;
			settings['fontSize'] = 56;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 0;
			super(settings);
			this.addEventListener(KeyboardEvent.KEY_DOWN, onInputEvent);
		}
		
		override public function drawBody():void 
		{
			titleLabel.y += 16;
			exit.y -= 20;
			inputField = Window.drawText('', 
			{
				fontSize:	32,
				color:		0xffffff,
				borderColor:0x492103,
				textAlign:	"center",
				input:		true,
				multiline:	true,
				wrap:		true,
				width:		250,
				height:		100
			});
			inputField.x = (settings.width - inputField.width) / 2;
			inputField.y = 40;
			if (inputField.length >= settings.maxLength)
				inputField.text.slice(0, settings.maxLength);
			bodyContainer.addChild(inputField);
			
			inputField.setSelection(inputField.length, inputField.length);
			App.self.stage.focus = inputField;
			
			var okBttn:Button = new Button( {
				caption:settings.buttonText,
				fontSize:26,
				width:160,
				hasDotes:false,
				height:55
			});
			okBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);//onOkBttn

			bodyContainer.addChild(okBttn);
			okBttn.x = settings.width / 2 - okBttn.width / 2;
			okBttn.y = settings.height - okBttn.height - 30;
		}
		
		public function onConfirmBttn(e:MouseEvent):void {
			if (inputField.text.length < 1)
			{
				close();
				return;
			}
			if (inputField.text.length > settings.maxLength)
			{
				inputField.text = inputField.text.slice(0, settings.maxLength);
				inputField.text.concat(inputField.text, "...");
			}
				
			if (settings.confirm is Function) {
				settings.confirm();
			}
			close();
		}
		
		private function onInputEvent(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				if (inputField.text.length < 1)
				{
					close();
					return;
				}
				if (inputField.text.length > settings.maxLength)
				{
					inputField.text = inputField.text.slice(0, settings.maxLength);
					inputField.text.concat(inputField.text, "...");
				}
				if (settings.confirm is Function) {
					settings.confirm();
				}
				close();
			}
		}
		
	}

}