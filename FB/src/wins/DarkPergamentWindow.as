package wins 
{
	import buttons.Button;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class DarkPergamentWindow extends Window
	{
		private var _descLabel:TextField
		private var _bttn:Button
		public function DarkPergamentWindow (settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['hasPaginator'] 		= false;
			settings['background'] 			= 'paperBackingBig';
			settings['fontSize'] 			= 40;	
			settings['fontColor'] 			= 0xffffff;
			settings['height'] 				= 490;
			settings['width'] 				= 520;
			settings['fontBorderColor'] 	= 0x6e411e;
			settings['borderColor'] 		= 0x6e411e;
			settings['shadowBorderColor']	= 0x6e411e;
			super(settings);
		}
		
		override public function drawBody():void 
		{
			drawDescription();
			drawBttn();
			build();
		}
		
		private function drawDescription():void {
			
			var desc:String = settings.opentext;
			
			_descLabel = Window.drawText(desc, {
				fontSize 	:32,
				color  		:0x6e411e,
				border		:false,
				textAlign 	:"center",
				multiline 	:true,
				width   	:settings.width - 120,
				wrap		:true
		    });
		    
		}
		
		private function drawBttn():void 
		{
			var bttnSettings:Object = {
			caption		:Locale.__e('flash:1393579618588'),
			fontColor	:0xffffff,
			width		:160,
			height		:60,
			fontSize	:25
			};
		
			bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
			bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
			bttnSettings['fontBorderColor'] = 0x7f3d0e;
			
			_bttn = new Button(bttnSettings);
			_bttn.addEventListener(MouseEvent.CLICK, onOpenEvent);
		}
		
		private function onOpenEvent(e:MouseEvent):void 
		{
			Window.closeAll()
			App.user.stock.unpackArcane(settings.sID);

		}
		
		private function build():void
		{
			exit.x -= 20;
			titleLabel.y += 38;
			_descLabel.x = (settings.width - _descLabel.width) / 2;
		    _descLabel.y = (settings.height - _descLabel.height) / 2 - 35;
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - 77 - _bttn.height / 2;
			
		    bodyContainer.addChild(_descLabel);
		    bodyContainer.addChild(_bttn);
		}
		
	}

}