package wins 
{
	import buttons.Button;
	import chat.ChatEvent;
	import chat.models.ChatModel;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author ...
	 */
	public class ConnectionWindow extends Window 
	{
		private var background:Bitmap;
		private var cancelBttn:Button;
		private var connectText:TextField;
		private var points:String = '';
		private var reTimeout:uint = 1;
		private var bttnTimeout:uint = 2;
		
		public function ConnectionWindow(settings:Object=null) 
		{
			settings['width'] 			= 320;
			settings['height'] 			= 130;
			settings['title'] 			= Locale.__e("flash:1502954302986");
			settings['hasPaginator'] 	= false;
			settings['hasExit'] 		= false;
			settings['hasTitle'] 		= false;
			settings['faderClickable'] 	= false;
			settings['escExit'] 		= false;
			settings['faderAlpha'] 		= 0.6;
			settings['mode'] 			= settings['mode'];
			super(settings);
			
		}
		
		override public function show():void 
		{
			Window.closeAll();
			super.show();
		}
		
		override public function drawBackground():void 
		{
			background = backing(settings.width, settings.height, 30, "banksBackingItem");
			background.alpha = .5;
			layer.addChild(background);	
			
			var preloader:Preloader = new Preloader();
			preloader.x = settings.width / 2;
			preloader.y = preloader.height;
			bodyContainer.addChild(preloader);
			
			connectText = Window.drawText(settings.title, {
				fontSize:34,
				color:0xffdf34,
				autoSize:"left",
				borderColor:0x6e411e
			});
			connectText.x = (settings.width - connectText.width) / 2;
			connectText.y = preloader.y - 20 + preloader.height;
			bodyContainer.addChild(connectText);
			App.self.setOnTimer(timerPoints);
			
			if (Connection.connectionChat){
				Connection.init();
				bttnTimeout = setTimeout(drawBttn, 5000);
				reTimeout = setTimeout(reConnect, 20000);
				App.self.addEventListener(ChatEvent.ON_CONNECT, onConnect);
			}else{
				close();
				Travel.goTo(User.HOME_WORLD);
			}
		}
		
		public function drawBttn():void
		{
			cancelBttn = new Button( {
				caption		:Locale.__e('flash:1502959696485'),
				fontSize	:26,
				width		:160,
				hasDotes	:false,
				height		:47
			});
			cancelBttn.addEventListener(MouseEvent.CLICK, reConnect);
		
			bodyContainer.addChild(cancelBttn);
			cancelBttn.x = (settings.width - cancelBttn.width) / 2;
			cancelBttn.y = settings.height - cancelBttn.height / 2;
		}
		
		public function timerPoints(e:* = null):void
		{
			points += '.';
			if (points.length > 3)
				points = '.';
			connectText.text = settings.title + points;
		}
		
		private function reConnect(e:* = null):void
		{
			close();
			new SimpleWindow( {
				title			:Locale.__e("flash:1474469531767"),
				label			:SimpleWindow.ATTENTION,
				text			:Locale.__e("flash:1502954252425"),
				faderAsClose	:false,
				escExit			:false,
				popup			:true,
				dialog:			true,
				confirm:function():void {
					new ConnectionWindow({}).show();
				},
				cancel:function():void {
					Travel.goTo(User.HOME_WORLD);
				}
			}).show();
		}
		
		private function onConnect(e:*):void
		{
			App.self.removeEventListener(ChatEvent.ON_CONNECT, onConnect);
			//setTimeout(close, 5000);
			close();
			
		}
		
		override public function close(e:MouseEvent = null):void 
		{
			if (cancelBttn)
			{
				cancelBttn.dispose();
				cancelBttn.removeEventListener(MouseEvent.CLICK, reConnect);
			}
			clearTimeout(bttnTimeout);
			clearTimeout(reTimeout);
			App.self.setOffTimer(timerPoints);
			super.close(e);
		}
	}

}