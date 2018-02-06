package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;

	public class AuctionRewardWindow extends Window 
	{
		private var bttn:Button;
		private var desc:TextField;
		private var object:Object = {};
		private var reward:Object = {};
		
		public function AuctionRewardWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['hasPaginator'] = false;
			settings['background'] = 'paperScroll';
			settings['width'] = 440;
			settings['height'] = 400;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x492103;
			settings['borderColor'] = 0x492103;
			settings['shadowColor'] = 0x492103;
			settings['fontSize'] = 56;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 0;
			settings['hasTitle'] = true;
			settings['hasExit'] = false;
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;			
			settings['popup'] = true;
			settings['title'] = Locale.__e('flash:1393579648825');
			
			//var object_id:int = App.data.lots[settings.id_lot].object;
			object = App.data.storage[settings.objectID];
			
			if (App.user.auction.windowOpened)
				App.user.auction.closeAuctionWindow();
			
			reward['id_auction'] = settings.id_auction;
			reward['id_lot'] = settings.id_lot;
			
			super(settings);
		}
		
		override public function dispose():void
		{
			App.user.auction.getReward(reward);
			take(object.sID);
			super.dispose();
		}
		
		override public function drawBody():void
		{
			drawRibbon();
			drawBttn();
			var image:Bitmap = new Bitmap();
			if (object)
			{
				Load.loading(Config.getIcon(object.type, object.preview), function(data:Bitmap):void{
					image.bitmapData = data.bitmapData;
					Size.size(image, 200, 200);
					image.smoothing = true;
					image.x = (settings.width - image.width) / 2;
					image.y = (settings.height - image.height) / 2;
				});
				bodyContainer.addChild(image);
			}
			
			var title:TextField = Window.drawText(Locale.__e('flash:1506437332340'), 
			{
				fontSize:40,
				color:0xffdf34,
				borderColor:0x451c00,
				textAlign:"center",
				multiline:true,
				wrap:true,
				wordwrap:true
			});
			title.width = 350;
			title.x = (settings.width - title.width) / 2;
			title.y = 70;
			bodyContainer.addChild(title);
			
			//desc = Window.drawText(object.description, 
			//{
				//fontSize:30,
				//color:0xffffff,
				//borderColor:0x451c00,
				//textAlign:"center",
				//multiline:true,
				//wrap:true,
				//wordwrap:true
			//});
			//desc.width = 350;
			//desc.x = (settings.width - desc.width) / 2;
			//desc.y = settings.height - 150;
			//bodyContainer.addChild(desc);
		}
		
		override protected function drawRibbon():void 
		{
			var titleBackingBmap:Bitmap = backingShort(350, 'actionRibbonBg', true);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -35;
			bodyContainer.addChild(titleBackingBmap);
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y + 16;
			
			bodyContainer.addChild(titleLabel);
		}
		
		private function drawBttn():void
		{			
			bttn = new Button( {
				width			:165,
				height			:53,
				radius			:19,
				fontSize		:36,
				textAlign		:'center',
				caption			:Locale.__e('flash:1382952379737'),
				fontBorderColor	:0x762e00,	
				bgColor			:[0xfed131,0xf8ab1a],
				bevelColor		:[0xf7fe9a, 0xf8ab1a]
			});
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = settings.height - bttn.height;
			bodyContainer.addChild(bttn);
			
			bttn.addEventListener(MouseEvent.CLICK, okEvent);	
		}
		
		private function okEvent(e:MouseEvent = null):void{
			//App.user.auction.getReward(reward);
			//take(object.sID);
			close();
		}
		
		private function take(sID:int):void
		{
				var item:BonusItem = new BonusItem(sID, 1);
				var point:Point = Window.localToGlobal(bttn);
				item.cashMove(point, App.self.windowContainer);
		}
	}
}