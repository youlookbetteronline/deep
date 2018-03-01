package {
	
	import flash.events.KeyboardEvent
	import flash.events.Event;
	import flash.ui.Mouse
	import flash.ui.MouseCursor
	
	public class Keyboard {
		
		private var _main:* 
		
		public function Keyboard(main:*)
		{
			_main = main
		}
		
		public function displayKey(e:KeyboardEvent):void
		{
			trace(Number(e.keyCode.toString()))
			switch(Number(e.keyCode.toString()))
			{
				case 49://"1"
				if (e.ctrlKey == true)
				{
					if (_main.informer.visible == false)
					{
						_main.showInformer()
					}
					else
					{
						_main.hideInformer()
					}
				}	
				break
			}	
			
		}
	}
	
}