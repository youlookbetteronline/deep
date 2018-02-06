package wins 
{
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class HorseUpgradeWindow extends SharkWindow 
	{
		private var iconContainer:LayerX = new LayerX();
		private var technoIn:Bitmap;
		private var bubbleCounter:Bitmap;
		private var counterContainer:Sprite;
		public function HorseUpgradeWindow(settings:Object=null) 
		{	
			if (settings == null) {
				settings = new Object();
			}
			settings['bttnCaption'] = Locale.__e("flash:1396963489306");
			super(settings);
			
		}
		
		override public function drawTechno():void
		{
			technoIn = new Bitmap();
			/*iconContainer.tip = function():Object {
				return {
					title:App.data.storage[settings.spirit.sid].title,
					text:App.data.storage[settings.spirit.sid].description
				};
			}; */
			Load.loading(Config.getImage('horses', 'horse'), function(data:Bitmap):void
			{
				technoIn.bitmapData = data.bitmapData;
				technoIn.smoothing = true;
				technoIn.filters = [new DropShadowFilter(7, 105, 0, 0.3, 2.0, 2.0, 1, 3, false, false, false)];
				iconContainer.addChild(technoIn);
				bodyContainer.addChild(iconContainer);
				iconContainer.x = 150;
				iconContainer.y = -45;
			});		
		}

		
		override public function drawExit():void 
		{
			super.drawExit();	
			bubbleExit.x = settings.width - 137;
			bubbleExit.y = -40;
			exit.x = settings.width - 4;
			exit.y = bubbleExit.y + (exit.height - bubbleExit.height) / 2 + 4;
		}
		
		
		override public function drawBackgrounds():void 
		{
			background = new Bitmap(Window.textures.hippodromBacking);
			layer.addChild(background);
			itm = App.data.storage[settings.target.sid];
		}
		
		override public function drawBody():void
		{
			super.drawBody();
			this.x -= 40;
			fader.x += 40;
			upgBttn.y -= 10;
			counterContainer = new Sprite();
			bubbleCounter = new Bitmap(Window.textures.clearBubbleBacking);
			counterContainer.addChild(bubbleCounter);
			Size.size(bubbleCounter, 82, 82);
			bubbleCounter.smoothing = true;
			bubbleCounter.x = 0;
			bubbleCounter.y = 0;
			var floor:int = settings.target.floor;
			var counterText:TextField = Window.drawText(String(floor),  {
				fontSize:50,
				color:0xffdf34,
				borderSize:3,
				textAlign:"center",
				borderColor:0x7e3e13
			});
			counterText.x = bubbleCounter.x + (bubbleCounter.width - counterText.width) / 2;
			counterText.y = bubbleCounter.y + (bubbleCounter.height - counterText.textHeight) / 2;
			counterContainer.addChild(counterText);
			counterContainer.x = 60;
			counterContainer.y = -30;
			bodyContainer.addChild(counterContainer);
		}
		
		override protected function onUpgrade(e:MouseEvent):void 
		{
			super.onUpgrade(e);
		}
		
		override public function createResources():void
		{
			var offsetX:int = 0;
			var offsetY:int = 0;
			var dX:int = 0;
			var count:int = 0;

			
			for (var itm:* in partBcList) {
				if(contains(partBcList[itm]))
				container.removeChild(partBcList[itm]);
			}
			
			for each(var sID:* in resources) {
				
				var inItem:WorkerItem = new WorkerItem({
					sID			:sID,
					need		:settings.request[sID],
					window		:this
				});
			
				/*inItem.title.multiline = true;
				inItem.title.y -= 5;
				inItem.title.width = 100;*/
				inItem.checkStatus();
				inItem.buyBttn.y -= 15;
				inItem.buyBttn.height = 40;
				inItem.askBttn.y -= 15;
				inItem.askBttn.height = 40;
				inItem.wishBttn.visible = false;
				inItem.searchBttn.visible = false;
				inItem.vs_txt.y = 20;
				inItem.count_txt.y = 20;
				inItem.need_txt.y = 20;
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				partList.push(inItem);
				inItem.y = 30;
				container.addChild(inItem);
				inItem.x = 30 + offsetX;
				
				count++;
				//
				offsetX += 135;
				inItem.background.visible = false;
				
			}
			findHelp();
			if(inItem)
				inItem.dispatchEvent(new WindowEvent(WindowEvent.ON_CONTENT_UPDATE));
		}
		
		
	}

}