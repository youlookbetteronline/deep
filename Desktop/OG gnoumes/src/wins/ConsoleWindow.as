package wins 
{
	import enixan.Util;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class ConsoleWindow extends Window 
	{
		private var titleLabel:TextField;
		private var commLabel:TextField;
		
		public function ConsoleWindow(params:Object = null) 
		{
			if (!params) params = { };
			params.width = 600;
			params.height = 600;
			
			super(params);
			
			//Main.app.appStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			//Main.app.ftp.dataListener(onDataChange);
		}
		
		private const FTP:String = 'FTP: ';
		private function onKeyUp(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.ENTER) {
				var stgring:String = commLabel.text.replace(/[\r\n]+/g, '');
				var array:Array = stgring.split(' ');
				if (array.length > 0)
					Main.app.ftp.command(array.shift(), array.join(' '));
				
				commLabel.text = '';
			}
		}
		private function onDataChange(data:String = null):void {
			if (!data) return;
			titleLabel.appendText(data);
			titleLabel.scrollV = titleLabel.maxScrollV;
		}
		
		override public function draw():void {
			
			super.draw();
			
			titleLabel = Util.drawText( {
				width:		560,
				height:		520,
				multiline:	true,
				wordWrap:	true,
				size:		12,
				color:		0x111111,
				border:			true,
				borderColor:	0x888888,
				background:		true,
				backgroundColor:0x666666
			});
			titleLabel.x = params.width * 0.5 - titleLabel.width * 0.5;
			titleLabel.y = 20;
			container.addChild(titleLabel);
			
			commLabel = Util.drawText( {
				width:		560,
				height:		21,
				size:		12,
				color:		0x111111,
				border:			true,
				borderColor:	0x888888,
				background:		true,
				backgroundColor:0x666666,
				type:			'input'
			});
			commLabel.x = params.width * 0.5 - commLabel.width * 0.5;
			commLabel.y = 554;
			container.addChild(commLabel);
		}
		
		override public function close(e:MouseEvent = null):void {
			Main.app.appStage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			super.close(e);
		}
		
	}

}