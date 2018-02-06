package chat.gui 
{
	import bttns.SimpleButton;
	import chat.ChatEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import hlp.TextUtil;
	import hlp.ToolsUtils;
	import wins.MassiveWindow;
	import wins.Window;
	
	public class UserInput extends Sprite {
		
		[Embed(source="..//..//..//INTERFACE//inputBacking2.png")]
		public  var InputBacking:Class;
		public  var inputBacking:BitmapData = new InputBacking().bitmapData;
		
		[Embed(source="..//..//..//INTERFACE//mirrowInput.png")]
		public  var MirrowInput:Class;
		public  var mirrowInput:BitmapData = new MirrowInput().bitmapData;
		
		[Embed(source="..//..//..//INTERFACE//sendButton.png")]
		public  var SendButton:Class;
		public  var sendButton:BitmapData = new SendButton().bitmapData;
		
		private var _editText:TextField;
		private var _textBacking:Bitmap;
		private var _mirrowLayer:Sprite;
		private const MAX_CHARS:int = 150;
		private var _enterButton:SimpleButton;
		
		public function UserInput() 
		{
			super();
			drawBody();
		}
		
		public function get text():String{ return _editText.text };
		public function set text(value:String):void {
			_editText.text = value; 
			if (Math.abs(_editText.textHeight - _editText.height) < 1) return;
			_editText.y -= _editText.textHeight - _editText.height + 5;
			_editText.height = _editText.textHeight + 5; 
			
		};
		private function drawBody():void{
			drawInput();
			drawButton();
			drawBack();
		}
		
		public function drawBack():void{
			ToolsUtils.removeFromParent(_textBacking);
			ToolsUtils.removeFromParent(_mirrowLayer);
			_mirrowLayer = new Sprite();
			_textBacking = Window.backing(220, _editText.height + 10, 50,inputBacking);
			_textBacking.smoothing = true;
			
			_textBacking.y = _editText.y - 5;
			_enterButton.y =_editText.y + _editText.height - 30;
			
			dispatchEvent(new ChatEvent(ChatEvent.CHANGE_UI_HEIGHT));
			MassiveWindow.drawMirrowObj(mirrowInput, _textBacking.width + 12, _mirrowLayer, _textBacking.width / 2, _textBacking.height - 26);
			var tempLayer:Sprite = new Sprite();
			MassiveWindow.drawMirrowObj(mirrowInput, _textBacking.width + 12, tempLayer, _textBacking.width / 2, 0);
			tempLayer.scaleY = -1;
			tempLayer.y = 26;
			_mirrowLayer.addChild(tempLayer);
			_mirrowLayer.y = _textBacking.y;
			addChildAt(_mirrowLayer, 0);
			addChildAt(_textBacking, 0);
		}
		
		private function drawInput():void{
			_editText = TextUtil.createInputText('', {
				//color:			0xf9c659,
				color:			0xFFFFFF,
				borderColor:	0x000000,
				fontSize:		14,
				borderSize 			: 2,					//Размер обводки шрифта
				fontBorderGlow 		: 2,					//Размер размытия шрифта
				fontFamily:		App.MYRIAD_REG,
				type: TextFieldType.INPUT,
				multiline:true,
				textAlign:'left',
				wordWrap:true
			});
			_editText.width = 190;
			_editText.height = _editText.textHeight + 5;
			_editText.y = 5;
			_editText.x = 10;
			addChild(_editText);
		}
		
		public function setListeners():void{
			App.self.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_editText.addEventListener(Event.CHANGE, onTextChange)
		}
		
		private function onTextChange(e:Event):void {
			if (_editText.text == '\r') _editText.text = '';
			
			if (_editText.text.length > MAX_CHARS){
				_editText.text = _editText.text.slice(0, MAX_CHARS);
			}
			if (Math.abs(_editText.textHeight - _editText.height) < 6) return;
			_editText.y -= _editText.textHeight - _editText.height + 5;
			_editText.height = _editText.textHeight + 5;
			drawBack();
		}
		
		public function clearListeners():void{
			App.self.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_editText.removeEventListener(Event.CHANGE, onTextChange)
		}
		
		public function dispose():void{
			clearListeners();
			if (_enterButton){
				_enterButton.dispose();
				_enterButton = null;
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.ENTER){
				dispatchEvent(new ChatEvent(ChatEvent.SEND_MESSAGE));
				return;
			}
			//if (_editText.text.length > MAX_CHARS){
				//_editText.text = _editText.text.slice(0, MAX_CHARS);
			//}
			//if (Math.abs(_editText.textHeight - _editText.height) < 6) return;
			//_editText.y -= _editText.textHeight - _editText.height + 5;
			//_editText.height = _editText.textHeight + 5;
			//drawBack();
		}
		
		private function drawButton():void{
			_enterButton = new SimpleButton({bmd:sendButton});
			_enterButton.onClick = function(e:*):void {dispatchEvent(new ChatEvent(ChatEvent.SEND_MESSAGE))};
			_enterButton.x = 198;
			addChild(_enterButton);
		}
	}
}