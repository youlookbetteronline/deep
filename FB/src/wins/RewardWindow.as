package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	
	public class RewardWindow extends Window
	{
		public var items:Array = new Array();
		public var bitmap:Bitmap;
		public var image:BitmapData;
		public var okBttn:Button;
		
		
		public function RewardWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}		
			settings["bonus"] = settings.bonus || [];
			
			settings['width'] = 500;
			settings['height'] = 350;
			
			settings['title'] = Locale.__e("flash:1404394075014");
			settings['hasPaginator'] = false;

			super(settings);
			
			
		}
		
		public var rewardSprite:Sprite;
		override public function drawBody():void {
			var background:Bitmap = Window.backing(525, 353, 30, "questBacking");
			layer.addChild(background);
			
			var bg:Bitmap = Window.backing(471, 207, 20, 'paperBacking');
			bodyContainer.addChild(bg);
			bg.x = background.x + (background.width - bg.width)/2;
			bg.y = 100;
			
			
			var titleContainer:Sprite = new Sprite();
			var title:TextField = Window.drawText(Locale.__e("flash:1404394075014"), {
				color				:0xffffff,
				borderColor			:0xb98659,
				borderSize			:4,
				fontSize			:42,
				autoSize			:"center"
			});
			titleContainer.addChild(title);
			bodyContainer.addChild(titleContainer);
			var titleGlow:GlowFilter = new GlowFilter(0x855729, 1, 6, 6, 6, 1, false, false);
			titleContainer.filters = [titleGlow];
			title.x = background.x + (background.width - title.width) / 2;
			title.y = background.y-40;
			
			
			
			rewardSprite = new Sprite();
			var itemNum:int = 0
			for (var sID:* in settings.bonus){
				var item:RewardItem = new RewardItem(sID, settings.bonus[sID]);
				item.x = itemNum * (item.width + 30) ;
				itemNum++;
				rewardSprite.addChild(item);
			}
			rewardSprite.x = bg.x + (bg.width - rewardSprite.width) / 2;
			rewardSprite.y = 136;
			bodyContainer.addChild(rewardSprite);
			
			var lable:TextField = drawText(Locale.__e("flash:1382952380261"),{
				color				:0xffffff,
				borderColor			:0x855729,
				multiline			: true,
				fontSize			: 28,
				autoSize			: "center"
			});
						
			bodyContainer.addChild(lable);
			lable.x = background.x + (background.width - lable.textWidth) / 2 - 3;
			lable.y = background.y + (background.height/2 - lable.height)/2 - 10;
			
			okBttn = new Button( {
				caption:Locale.__e('flash:1404394519330'),
				fontSize:28,
				width:170,
				height:50
			});
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
		
			bottomContainer.addChild(okBttn);
			okBttn.x = background.x + (background.width - okBttn.width) / 2;
			okBttn.y = background.height - okBttn.height + 10;
			

			
			var giftLabel:Bitmap = new Bitmap(Window.textures.chestTukan, "auto", true);
			layer.addChildAt(giftLabel, 1);
			giftLabel.x = background.x + (background.width - giftLabel.width) / 2 -10;
			giftLabel.y = -giftLabel.height + 120;
			
			var shining:Bitmap = new Bitmap(Window.textures.sharpShining, "auto", true);
			layer.addChildAt(shining, 1);
			shining.x = giftLabel.x - 80;
			shining.y = giftLabel.y;
			shining.width = giftLabel.width + 160;
			shining.height = giftLabel.height;
			//drawMirrowObjs('diamondsTop', title.x +4, title.x + title.width -4, title.y , true, true);
			//drawMirrowObjs('storageWoodenDec', background.x + 5, background.x + background.width, background.y + 45, false, false, false, 1, -1);
			//drawMirrowObjs('storageWoodenDec', background.x + 5, background.x + background.width, background.y + background.height - 102);
			
		}
		
		override public function drawBackground():void {
			this.y += 80;
			this.fader.y -= 80;
		}
		override public function drawTitle():void {
		}

		override public function drawExit():void {
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 20;
			exit.y = -5;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		public function take():void{
			var childs:int = rewardSprite.numChildren;
			
			while(childs--) {
				var reward:RewardItem = rewardSprite.getChildAt(childs) as RewardItem;
				
				var item:BonusItem = new BonusItem(reward.sID, reward.count);
			
				var point:Point = Window.localToGlobal(reward);
				item.cashMove(point, App.self.windowContainer);
			}
		}
		
		private function onOkBttn(e:MouseEvent):void {
			take();
			close();
		}
		
		override public function dispose():void
		{	
			super.dispose();
		}
		
	}
}


