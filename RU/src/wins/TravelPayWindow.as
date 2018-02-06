package wins {
	
	import buttons.Button;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class TravelPayWindow extends Window {
		
		public var travelBttn:Button;
		public var container:Sprite;
		public var worldID:int = User.HOME_WORLD;
		private var descLabel:TextField;
		
		public function TravelPayWindow(settings:Object=null) {
			if (!settings) settings = { };
			settings['width'] = 460;
			settings['height'] = 430;
			settings['hasPaginator'] = false;
			settings['popup'] = true;
			worldID = settings['worldID'] || User.HOME_WORLD;
			settings['title'] = App.data.storage[worldID].title || Locale.__e('flash:1418286565591');
			settings['fontColor'] = 0xffffff;
			settings['fontSize'] = 42;
			settings['borderColor'] = 0x085c10;
			settings['shadowColor'] = 0x085c10;
			settings['fontBorderColor'] = 0x085c10;
			settings['fontBorderSize'] = 2;
			settings['shadowSize'] = 2;
			settings['shadowColor'] = 0x085c10;
			settings['exitTexture'] = 'closeBttnMetal';
			settings['content'] = settings['content'] || {};

			super(settings);
		}
		
		override public function drawTitle():void
		{
			super.drawTitle();
			var textLabel:* = titleLabel.getChildAt(0);
			settings.titleWidth = textLabel.textWidth - 55;
			drawRibbon();
			titleLabel.y += 33;
			titleBackingBmap.y += 20;
		}
		
		override public function drawExit():void
		{
			super.drawExit();
			exit.x -= 2;
			exit.y -= 14;
		}
		
		override public function drawBackground():void
		{
			drawMirrowObjs('decSeaweedWithBubbles', settings.width + 56, -56, settings.height - 267, true, true, false, 1, 1, layer);
			super.drawBackground();
			var back:Bitmap = Window.backing(settings.width - 60, settings.height - 60, 30, 'itemBackingPaper');
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2;
			layer.addChild(back);
		}
		
		override public function drawBody():void {
			exit.x -= 4;
			exit.y -= 6;
			
			descLabel = drawText(Locale.__e('flash:1418285724686'), {
				fontSize:28,
				color:0xffffff,
				borderColor:0x623518,
				autoSize:"center",
				textAlign:'center',
				multiline:true
			});
			descLabel.wordWrap = true;
			descLabel.width = (settings.width - 40 > 100) ? (settings.width - 150) : 100;
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 42;
			bodyContainer.addChild(descLabel);
			
			travelBttn = new Button( {
				width:		180,
				height:		55,
				caption:	Locale.__e('flash:1382952380219')
			});
			travelBttn.x  = (settings.width - travelBttn.width) / 2;
			travelBttn.y = settings.height - 74;
			bodyContainer.addChild(travelBttn);
			travelBttn.addEventListener(MouseEvent.CLICK, onTravel);
			onUpdateOutMaterial();
			
			container = new Sprite();
			bodyContainer.addChild(container);
			
			contentChange();
		}
		
		override public function contentChange():void {
			for (var s:* in settings.content) {
				var inItem:WorkerItem = new WorkerItem({
					sID:int(s),
					need:settings.content[s],
					window:this,
					type:MaterialItem.IN
				});
				
				inItem.y = -40;
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				var background:Bitmap = Window.backing(142, 164, 10, "banksBackingItem");
				inItem.background.bitmapData = background.bitmapData;
				inItem.title.x = (inItem.background.width - inItem.title.width) / 2;
				inItem.title.y = 5;
				inItem.buyBttn.x += 22;
				inItem.buyBttn.y += 30;
				inItem.askBttn.x += 20;
				inItem.askBttn.y += 30;
				inItem.sprTip.x = (inItem.background.width - inItem.bitmap.width) / 2;
				inItem.sprTip.y = (inItem.background.height - inItem.bitmap.height) / 2;
				inItem.vs_txt.y += 20;
				inItem.count_txt.y += 20;
				inItem.need_txt.y += 20;
				inItem.vs_txt.x += 50;
				inItem.count_txt.x += 50;
				inItem.need_txt.x += 50;
				inItem.searchBttn.visible = false;
				inItem.wishBttn.visible = false;
				inItem.buyBttn.visible = false;
				inItem.x = container.numChildren * ((inItem.background)?inItem.background.width + 12:100 - 30);
				container.addChild(inItem);
			}
			
			container.x = (settings.width - container.width) / 2 + 10;
			container.y = descLabel.y + descLabel.height + 47;
		}
		
		public function onUpdateOutMaterial(e:WindowEvent = null):void {
			if (App.user.stock.checkAll(settings.content)) {
				travelBttn.visible = true;
			} else {
				travelBttn.visible = false;
			}
		}
		
		public function onTravel(e:MouseEvent):void {
			if (App.user.stock.checkAll(settings.content)) {
				App.user.stock.takeAll(settings.content);
				
				Travel.goTo(worldID);
				
				if (settings['window']) settings.window.close();
				close();
			}
		}
		
		override public function dispose():void {
			travelBttn.removeEventListener(MouseEvent.CLICK, onTravel);
			travelBttn.dispose();
			
			super.dispose();
		}
	}
}