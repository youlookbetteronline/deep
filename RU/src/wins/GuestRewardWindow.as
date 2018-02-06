package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.elements.GuestRewardItem;
	/**
	 * ...
	 * @author ...
	 */
	public class GuestRewardWindow extends Window
	{
		private var guestIcon:Bitmap;
		private var priceBttn:Button;
		private var reward:Object;
		public var background:Bitmap;
		public var count:int;
		public var sid:int;
		
		public function GuestRewardWindow() 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['width'] = 244;
			settings['height'] = 212;
			settings['title'] = String(App.user.currentGuestLimit) +' '+Locale.__e('flash:1423133969401');
			settings['background'] = 'paperBacking';
			settings['hasPaginator'] = false;
			settings['titlePading'] = 70;
			settings['hasExit'] = false;
			settings['popup'] = true;
			settings['forcedClosing'] = true;
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x7a4002;
			settings['fontBorderSize'] = 4;
			
			reward = App.user.currentGuestReward;
			super(settings);
		}
		override public function drawBody():void 
		{
			titleLabel.x = titleLabel.x + 20;
			
			guestIcon  = new Bitmap(UserInterface.textures.guestAction);
			guestIcon.width = 40;
			guestIcon.scaleY = guestIcon.scaleX;
			guestIcon.smoothing = true;
			guestIcon.x = titleLabel.x - guestIcon.width;
			guestIcon.y = titleLabel.y + (titleLabel.height - guestIcon.height) / 2;
			headerContainer.addChild(guestIcon);
			
			drawDesc();
			drawReward();
			drawButton();
		}
		
		override public function drawBackground():void 
		{
			background = backing(settings.width, settings.height , 50, 'workerHouseBacking');
			var background2:Bitmap  = backing(settings.width - 60, settings.height - 54, 40, 'paperClear');
			
			background2.x = background.x + (background.width - background2.width) / 2;
			background2.y = background.y + (background.height - background2.height) / 2;
			layer.addChildAt(background, 0);
			layer.addChildAt(background2, 1);
				
			//background =  backing2(settings.width, settings.height, 45, 'questBackingTop', 'questBackingBot');//Внешняя подложка
			//layer.addChild(background);
		}
		
		private function drawDesc():void 
		{
			var desc:TextField = Window.drawText(Locale.__e('flash:1423136283210'), {
				color:			0xfcd25c,
				borderColor:	0x6f4302,
				fontSize:		26,
				width: 			180
			});
		
			desc.x = (settings.width - desc.textWidth) / 2;
			desc.y = 20;
			bodyContainer.addChild(desc);
		}
		
		private function drawReward():void 
		{

		var item:GuestRewardItem = new GuestRewardItem(reward.sid, reward, this, true,false,false);
		bodyContainer.addChild(item);
		item.x = (settings.width - item.width) / 2;
		item.y = (settings.height - item.height) / 2 - 50;
		item.scaleX = item.scaleY = 1; 
		
			this.sid = item.sid; 
			this.count = item.count;
			
		}
		
		private function drawButton():void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952380242"),
				fontSize:24,
				width:136,
				height:43,
				hasDotes:false
			};
			//flash:1423136283210
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = (settings.height - priceBttn.height) - 15;
			priceBttn.addEventListener(MouseEvent.CLICK, takeReward);
			
		}
		
		private function takeReward(e:MouseEvent = null):void 
		{
			
			var item:BonusItem = new BonusItem(sid, count);
			var point:Point = Window.localToGlobal(e.currentTarget);
			item.cashMove(point, App.self.windowContainer);
			App.user.stock.add(sid, count);
			close();
		}
	}

}