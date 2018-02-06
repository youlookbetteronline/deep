package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	public class HappyTopBonusWindow extends Window 
	{		
		public var top50Backing:Bitmap;
		public var top10Backing:Bitmap;
		public var background:Bitmap;
		public var okBttn:Button;
		public var top50TextLabel:TextField;
		public var top10TextLabel:TextField;
		public var sid:int = 0;
		public var info:Object = { };
		public var top50Bitmap:Bitmap;
		public var top10Bitmap:Bitmap;
		
		protected var top50RewardCont:LayerX;
		protected var top10RewardCont:LayerX;
		
		public function HappyTopBonusWindow(settings:Object=null)  
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 550;
			settings['height'] = 415;			
			settings['hasTitle'] = true;
			settings['hasButtons'] = true;
			settings['hasPaginator'] = false;
			settings['callback'] = settings.callback || null;			
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;			
			settings['popup'] = true;
			
			sid = settings.target.sid;
			info = App.data.storage[sid];
			
			super(settings);			
		}
		
		override public function close(e:MouseEvent = null):void {
			super.close();
		}		
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height , 50, 'questBackingTop', 'questBackingBot');
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
			top50Backing = Window.backing(440, 140, 10, 'banksBackingItem');
			layer.addChild(top50Backing);
			top50Backing.x = background.x + ((background.width - top50Backing.width) / 2);
			top50Backing.y = 80;
			
			top10Backing = Window.backing(440, 140, 10, 'banksBackingItem');
			layer.addChild(top10Backing);
			top10Backing.x = background.x + ((background.width - top50Backing.width) / 2);
			top10Backing.y = top50Backing.y + top50Backing.height + 10;
			
			/*drawMirrowObjs('storageWoodenDec', 0, settings.width, settings.height - 100);//bottom pair
			drawMirrowObjs('storageWoodenDec', 0, settings.width, 50, false, false, false, 1, -1);//upper pair
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 1, settings.width / 2 + settings.titleWidth / 2 + 1, -40, true, true);*/
			
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
			okBttn.y = (background.y + background.height - (okBttn.height / 2)) - 20;
			okBttn.addEventListener(MouseEvent.CLICK, close);
		}
		
		private function drawDescription():void {
			var top50Text:String = Locale.__e("flash:1445980186484");//Топ игроков получат уникальный подарок:
			var top10Text:String = Locale.__e("flash:1445980263382");//Игроки попавшие в Топ-10 получат дополнительную награду:
			
			var top50RewardSid:int = getTop50Reward();
			var top10RewardSid:int = getTop10Reward();
			
			top50TextLabel = drawText(top50Text + " " + App.data.storage[top50RewardSid].title, {
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
			top50TextLabel.y = top50Backing.y + (top50Backing.height - top50TextLabel.height) / 2;
			
			top10TextLabel = drawText(top10Text + " " + App.data.storage[top10RewardSid].title, {
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
			top10TextLabel.y = top10Backing.y + (top10Backing.height - top10TextLabel.height) / 2;
		}
		
		private function drawItems():void {
			
			var top50RewardSid:int = getTop50Reward();
			var top10RewardSid:int = getTop10Reward();
			
			top50RewardCont = new LayerX();
			layer.addChild(top50RewardCont);
			top50Bitmap = new Bitmap();
			top50RewardCont.addChild(top50Bitmap);
			
			top10RewardCont = new LayerX();
			layer.addChild(top10RewardCont);
			top10Bitmap = new Bitmap();
			top10RewardCont.addChild(top10Bitmap);
			
			top50RewardCont.tip = function():Object {
				return { title:App.data.storage[top50RewardSid].title, text:App.data.storage[top50RewardSid].description };
			}
			
			top10RewardCont.tip = function():Object {
				return { title:App.data.storage[top10RewardSid].title, text:App.data.storage[top10RewardSid].description };
			}
			
			Load.loading(
				Config.getIcon(App.data.storage[top50RewardSid].type, App.data.storage[top50RewardSid].preview),
				function(data:Bitmap):void{
					top50Bitmap.bitmapData = data.bitmapData;
					Size.size(top50Bitmap, 80, 80);
					//top50Bitmap.scaleX = top50Bitmap.scaleY = 0.7;
					top50Bitmap.smoothing = true;
					top50Bitmap.x = top50Backing.x + top50Backing.width - (top50Bitmap.width) / 2 - 80;
					top50Bitmap.y = top50Backing.y + (top50Backing.height - top50Bitmap.height)/2;
					/*if (App.data.storage[top50RewardSid].sID == 1859) 
					{
						top50Bitmap.y -= 25;	
					}
					if (App.data.storage[top50RewardSid].sID == 1866) 
					{
						top50Bitmap.y -= 20;
						top50Bitmap.x -= 20	
					}*/
				}
			);
			
			Load.loading(
				Config.getIcon(App.data.storage[top10RewardSid].type, App.data.storage[top10RewardSid].preview),
				function(data:Bitmap):void{
					top10Bitmap.bitmapData = data.bitmapData;
					Size.size(top10Bitmap, 80, 80);
					//top10Bitmap.scaleX = top10Bitmap.scaleY = 0.7;
					top10Bitmap.smoothing = true;
					top10Bitmap.x = top10Backing.x + top10Backing.width - (top10Bitmap.width) / 2 - 80;
					top10Bitmap.y = top10Backing.y + (top10Backing.height - top10Bitmap.height)/2;
					/*if (App.data.storage[top10RewardSid].sID == 1858) 
					{
						top10Bitmap.y += 10;	
						top10Bitmap.x -= 5;	
					}*/
				}
			);
		}
		
		protected function getTop50Reward():int 
		{
			var top50Sid:int = 0;
			if (settings.target.info.hasOwnProperty('bbonus')) 
			{
				top50Sid = Numbers.firstProp(settings.target.info.bbonus).key;
			}
			/*if (info.tower.hasOwnProperty(settings.target.upgrade + 1)) {
				var length:Number = 1;
				for (var i:* in info.tower) 
				{
					length = i;
				}
				var items:Object = App.data.treasures[info.tower[length].t][info.tower[length].t].item;
				for each(var s:* in items) return int(s);
			}*/
			
			return top50Sid;
		}
		
		protected function getTop10Reward():int 
		{
			var top10Sid:int = 0;
			if (settings.target.info.hasOwnProperty('abonus')) 
			{
				top10Sid = Numbers.firstProp(settings.target.info.abonus).key;
			}
			/*for (var i:* in settings.target.info.abonus) 
			{
				top10Sid = i;				
			}*/
			
			return top10Sid;
		}
	}

}