package chat.gui 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import hlp.TextUtil;
	import wins.Window;
	
	/**
	 * ...
	 * @author none
	 */
	public class ChatMessage extends Sprite 
	{
		private var _message:Object;
		public function ChatMessage(message:Object)  {
			_message = message;
			
			drawBody();
		}
		
		private function drawBody():void {
			drawText();
			drawBack();
		}
		
		private function drawBack():void{
			
		}
		
		private function drawText():void {
			var textSettings:Object = {
				color:			0xf9c659,
				borderColor:	0x000000,
				fontSize:		15,
				fontFamily:		App.MYRIAD_COND,
				multiline:true,
				textAlign:'left',
				width:180,
				wordWrap:true
			}
			
			var isYou:Boolean = (_message.name == App.user.id);
			var name:String = (isYou) ? 'You: ' :  App.user.clan.members[_message.name].aka + ': ';
			var textField:TextField = TextUtil.createTextField(name + _message.text, textSettings);
			TextUtil.colorTextPart(textField, 0xFFFFFF, 0, name.length - 1);
			textField.height = textField.textHeight + 5;
			//if (Math.random() < 0.5) {
			if (isYou) {
				textField.x = 42;
			}
			//textField.border = true;
			addChild(textField);
			
			var back:Bitmap = Window.backing(180, 100, 50, Gui.interfaceTextures.logBacking);
			//back.width = textField.width + 6;
			back.height = textField.height + 6;
			back.x  = textField.x + (textField.width - back.width) / 2;
			back.y  = textField.y + (textField.height - back.height) / 2;
			addChildAt(back,0);
			
		}
	}
}