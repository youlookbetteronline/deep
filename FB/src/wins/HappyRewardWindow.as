package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	public class HappyRewardWindow extends Window 
	{		
		public var top50Backing:Bitmap;
		public var top10Backing:Bitmap;
		public var additionalBacking:Bitmap;
		public var background:Bitmap;
		public var okBttn:Button;
		public var top50TextLabel:TextField;
		public var top10TextLabel:TextField;
		public var additionalTextLabel:TextField;
		public var sid:int = 0;
		public var info:Object = { };
		public var top50Bitmap:Bitmap;
		public var top10Bitmap:Bitmap;
		public var additionalBitmap:Bitmap;
		protected var top50RewardCont:LayerX;
		protected var top10RewardCont:LayerX;
		protected var additionalRewardCont:LayerX;
		
		public function HappyRewardWindow(settings:Object=null)  
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 525;
			settings['height'] = 400;		
			settings['hasTitle'] = true;
			settings['hasButtons'] = true;
			settings['hasPaginator'] = false;
			settings['callback'] = settings.callback || null;			
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;			
			settings['popup'] = true;
			settings['winter'] = settings.winter || false;
			
			sid = settings.happy;
			info = App.data.storage[sid];
			
			if (settings.winter && App.isSocial('DM','VK','OK','FS','MM')) 
			{
				settings['height'] = 550;
			}
			
			super(settings);		
		}
		
		override public function close(e:MouseEvent = null):void {
			super.close();
		}		
		
		override public function drawBackground():void {
			background = backing(settings.width, settings.height, 30, 'bankBacking');
			layer.addChild(background);
			background.y = 10;
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: Locale.__e('flash:1445976778425'),
				color				: settings.fontColor,
				multiline			: settings.multiline,
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,						
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = 0;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = -10;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawExit():void {
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 50;
			exit.y = 10;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		override public function drawBody():void 
		{
			top50Backing = Window.backing(465, 160, 10, 'paperBacking');
			layer.addChild(top50Backing);
			top50Backing.x = background.x + ((background.width - top50Backing.width) / 2);
			top50Backing.y = 50;
			
			top10Backing = Window.backing(465, 160, 10, 'paperBacking');
			layer.addChild(top10Backing);
			top10Backing.x = background.x + ((background.width - top50Backing.width) / 2);
			top10Backing.y = top50Backing.y + top50Backing.height;
			
			additionalBacking = Window.backing(465, 160, 10, 'paperBacking');
			if (settings.winter && App.isSocial('DM','VK','OK','FS','MM')) 
			{
				layer.addChild(additionalBacking);
			}			
			additionalBacking.x = background.x + ((background.width - additionalBacking.width) / 2);
			additionalBacking.y = top10Backing.y + top10Backing.height;
			
			drawMirrowObjs('storageWoodenDec', 0, settings.width, settings.height - 100);//bottom pair
			drawMirrowObjs('storageWoodenDec', 0, settings.width, 50, false, false, false, 1, -1);//upper pair
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 1, settings.width / 2 + settings.titleWidth / 2 + 1, -40, true, true);
			
			drawBttns();
			drawDescription();
			drawItems();
		}
		
		private function drawBttns():void {
			
			okBttn = new Button( {
				width:175,
				height:55,
				fontSize:32,
				caption:Locale.__e("flash:1382952380298")
			});
			layer.addChild(okBttn);
			okBttn.x = background.x + (background.width - okBttn.width) / 2;
			okBttn.y = (background.y + background.height - (okBttn.height / 2)) ;
			okBttn.addEventListener(MouseEvent.CLICK, close);
		}
		
		private function drawDescription():void {
			var top50Text:String = Locale.__e("flash:1447949249541");//Топ игроков получат уникальный подарок:
			var top10Text:String = Locale.__e("flash:1447949289131");//Игроки попавшие в Топ-10 получат дополнительную награду:
			var topText:String = Locale.__e("flash:1447949302587");//Игроки попавшие в получат дополнительную награду:
			
			if (settings.winter) 
			{
				top50Text = Locale.__e("flash:1450358729681");
				top10Text = Locale.__e("flash:1450358815271");
				var additionalText:String = Locale.__e("flash:1450358781079");
			}
			
			top50TextLabel = drawText(top50Text, {// + " " + App.data.storage[top50RewardSid].title, {
				width		:280,
				fontSize	:26,
				textAlign	:"left",
				color		:0x83532d,
				borderColor	:0xffffff,
				multiline	:true,
				wrap		:true
			});
			
			layer.addChild(top50TextLabel);
			top50TextLabel.x = top50Backing.x + 40;
			top50TextLabel.y = top50Backing.y + 40;
			
			top10TextLabel = drawText(top10Text,{// + " " + App.data.storage[top10RewardSid].title, {
				width		:275,
				fontSize	:26,
				textAlign	:"left",
				color		:0x83532d,
				borderColor	:0xffffff,
				multiline	:true,
				wrap		:true
			});
			
			layer.addChild(top10TextLabel);
			top10TextLabel.x = top10Backing.x + 40;
			top10TextLabel.y = top10Backing.y + 40;
			
			additionalTextLabel = drawText(additionalText,{// + " " + App.data.storage[top10RewardSid].title, {
				width		:275,
				fontSize	:26,
				textAlign	:"left",
				color		:0x83532d,
				borderColor	:0xffffff,
				multiline	:true,
				wrap		:true
			});
			
			if (settings.winter && App.isSocial('DM','VK','OK','FS','MM'))
			{
				layer.addChild(additionalTextLabel);	
			}			
			additionalTextLabel.x = top50Backing.x + 40;
			additionalTextLabel.y = additionalBacking.y + 40;
		}
		
		private function drawItems():void {
			
			var top50RewardSid:int = 1448;
			var top10RewardSid:int = 1607;
			var additionalRewardSid:int = 1775;
			
			if (settings.winter) 
			{
				top50RewardSid = 839;
				top10RewardSid = 1771;
			}
			
			top50RewardCont = new LayerX();
			layer.addChild(top50RewardCont);
			top50Bitmap = new Bitmap();
			top50RewardCont.addChild(top50Bitmap);
			
			top10RewardCont = new LayerX();
			layer.addChild(top10RewardCont);
			top10Bitmap = new Bitmap();
			top10RewardCont.addChild(top10Bitmap);
			
			additionalRewardCont = new LayerX();
			if (settings.winter && App.isSocial('DM','VK','OK','FS','MM'))
			{
				layer.addChild(additionalRewardCont);
			}			
			additionalBitmap = new Bitmap();
			if (settings.winter && App.isSocial('DM','VK','OK','FS','MM'))
			{
				additionalRewardCont.addChild(additionalBitmap);
			}			
			
			top50RewardCont.tip = function():Object {
				return { title:App.data.storage[top50RewardSid].title, text:App.data.storage[top50RewardSid].description };
			}
			
			top10RewardCont.tip = function():Object {
				return { title:App.data.storage[top10RewardSid].title, text:App.data.storage[top10RewardSid].description };
			}
			
			if (settings.winter && App.isSocial('DM','VK','OK','FS','MM')) {
				additionalRewardCont.tip = function():Object {
				return { title:App.data.storage[additionalRewardSid].title, text:App.data.storage[additionalRewardSid].description };
				}
			}
			
			Load.loading(
				Config.getIcon(App.data.storage[top50RewardSid].type, App.data.storage[top50RewardSid].preview),
				function(data:Bitmap):void{
					top50Bitmap.bitmapData = data.bitmapData;
					top50Bitmap.smoothing = true;
					if (settings.winter) 
					{
						top50Bitmap.scaleX = top50Bitmap.scaleY = 0.6;
					}
					top50Bitmap.x = top50Backing.x+top50Backing.width-top50Bitmap.width-20;
					top50Bitmap.y = top50Backing.y+top50Backing.height/2-top50Bitmap.height/2;
				}
			);
			
			Load.loading(
				Config.getIcon(App.data.storage[top10RewardSid].type, App.data.storage[top10RewardSid].preview),
				function(data:Bitmap):void{
					top10Bitmap.bitmapData = data.bitmapData;
					top10Bitmap.smoothing = true;
					if (settings.winter) 
					{
						top10Bitmap.scaleX = top10Bitmap.scaleY = 0.7;
					}
					top10Bitmap.x = top10Backing.x+top10Backing.width-top10Bitmap.width-20;
					top10Bitmap.y = top10Backing.y+top10Backing.height/2-top10Bitmap.height/2;
				}
			);
			
			if (settings.winter && App.isSocial('DM','VK','OK','FS','MM')) 
			{
				Load.loading(
					Config.getIcon(App.data.storage[additionalRewardSid].type, App.data.storage[additionalRewardSid].preview),
					function(data:Bitmap):void{
						additionalBitmap.bitmapData = data.bitmapData;
						additionalBitmap.smoothing = true;
						additionalBitmap.x = 350;
						additionalBitmap.y = additionalBacking.y + additionalBacking.height / 2 - additionalBacking.height / 2 + 50;
					}
				);				
			}			
		}
	}
}