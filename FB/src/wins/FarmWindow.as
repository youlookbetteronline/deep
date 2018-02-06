package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import flash.geom.Point;
	import ui.UserInterface;
	import wins.elements.Bar;
	import wins.elements.FarmingItem;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class FarmWindow extends ProductionWindow
	{
		protected var jamBg:Bitmap = null;
		
		public function FarmWindow(settings:Object = null) 
		{
			settings['width'] = 600;
			settings['height'] = 720;
			settings['itemsOnPage'] = 6;
			settings['hasButtons'] = false;
			super(settings);
			dY = 0
		}
		
		override public function drawBody():void {
			
			jamBg = Window.backing(400, 80, 10, "bonusBacking");
			jamBg.x = (settings.width - jamBg.width) / 2;
			jamBg.y = 38;
			bodyContainer.addChild(jamBg);
			
			addBear();
			
			topBg = Window.backing(490, 390, 50, "windowDarkBacking");
			topBg.x = (settings.width - topBg.width) / 2;
			topBg.y = 158;
			bodyContainer.addChild(topBg);
			
			progressBacking = Window.backing(490, 80, 10, "bonusBacking");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = topBg.y + topBg.height + 5;
			bodyContainer.addChild(progressBacking);
			
			subTitle = Window.drawText(Locale.__e("flash:1382952379994"), {
				fontSize:26,
				color:0x502f06,
				autoSize:"left",
				borderColor:0xf0e6c1
			});
			bodyContainer.addChild(subTitle);
	
			subTitle.x = settings.width / 2 - subTitle.width / 2;
			subTitle.y = topBg.y - subTitle.textHeight - 2;
			
			
			createItems();
			paginator.itemsCount = 0;
			for each(var fID:* in settings.target.info.farming) paginator.itemsCount ++;
			paginator.update();
			
			contentChange();
			showProgressBar();
		}
		
		public var bear:Bitmap = new Bitmap();
		public var alertLabel:TextField;
		public var addJamBttn:Button;
		public var bar:Bar;
		
		public function addBear():void {
			var bg:Bitmap = Window.backing(70, 70, 10, "textSmallBacking");
			bodyContainer.addChild(bg);
			bg.x = 110;
			bg.y = 43;
			
			bodyContainer.addChild(bear);
			bear.x = 120;
			bear.y = 53;
			
			
			bear.bitmapData = UserInterface.textures.bearAvatar;
			
			
			alertLabel = Window.drawText(Locale.__e("flash:1382952380101"), {
				fontSize:18,
				color:0x502f06,
				autoSize:"left",
				borderColor:0xf0e6c1
			});
			alertLabel.x = 220;
			alertLabel.y = 48;
			
			addJamBttn = new Button( {
				caption:Locale.__e("flash:1382952380093"),
				width:110,
				padding:5,
				fontSize:22,
				height:28,
				borderColor:			[0xf3a9b3,0x550f16],
				fontColor:				0xe6dace,
				fontBorderColor:		0x550f16,
				bgColor:				[0xbf3245, 0x761925]
			});
			
			addJamBttn.addEventListener(MouseEvent.CLICK, onAddJamEvent);
			
			bodyContainer.addChild(addJamBttn);
			
			addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateSlider);
			
			bar = new Bar(String(settings.target.capacity), settings.target.capacity, 20, "spoonIcon", "jamBar", "jamSlider");
			bar.x = 200;
			bar.y = 78;
			
			bar.icon.x += 18;
			bar.icon.y += -4;
			bar.icon.scaleX = bar.icon.scaleY = 0.5;
			bar.icon.smoothing = true;
		
			bodyContainer.addChild(bar);
			
			bodyContainer.addChild(alertLabel);
			
			toogle();
		}
		
		private function toogle():void {
			if (settings.target.capacity == 0) {
				UserInterface.effect(bear, 0, 0);
				
				alertLabel.text = Locale.__e("flash:1382952380101");
				
				alertLabel.x = 30 + (settings.width - alertLabel.width)/2;
				
				addJamBttn.x = 270;
				addJamBttn.y = 73;
				
				bar.visible = false;
				
			}else {
				alertLabel.text = Locale.__e("flash:1382952380102");
				addJamBttn.caption = Locale.__e("flash:1382952380103");
				//addJamBttn.textLabel.width = addJamBttn.textLabel.textWidth + 4;
				if (alertLabel.textWidth > 300) {
					alertLabel.scaleX = alertLabel.scaleY = 300 / alertLabel.textWidth;
				}
				bear.filters = [];
				//alertLabel.x = 190;
				alertLabel.x = 30 + (settings.width - alertLabel.width)/2;
				
				addJamBttn.x = 340;
				addJamBttn.y = 76;
				
				bar.visible = true;	
			}
		}
		
		private function onUpdateSlider(e:WindowEvent):void {
			bar.have = settings.target.capacity;
			bar.counter = String(settings.target.capacity);
			
			toogle();
		}
		
		public function onAddJamEvent(e:MouseEvent):void {
			
			new JamWindow( { 
				view:'jam',
				onFeedAction:function(jsID:uint):void {
					settings.target.addJam(jsID);
					dispatchEvent(new WindowEvent(WindowEvent.ON_CONTENT_UPDATE));
				},
				popup:true
			}).show();
		}
		
		private var preloader:Preloader = new Preloader();
		override public function startProgress(fID:uint):void
		{
			accelerateBttn = new MoneyButton({
				caption		:Locale.__e('flash:1382952380104'),
				width		:74,
				height		:54,	
				fontSize	:18,
				radius		:15,
				countText	:settings.target.info.skip,
				iconScale	:0.8,
				multiline	:true,
				setWidth:	false
			});
				
			cookingTitle.text = Locale.__e("flash:1382952380105");
				
			bodyContainer.addChild(accelerateBttn);
			
			accelerateBttn.addEventListener(MouseEvent.CLICK, onAccelerateEvent);
			
			/*accelerateBttn.x = settings.width  - accelerateBttn.width + 22;
			accelerateBttn.y = cookingBar.y - 24;
			
			accelerateBttn.textLabel.x = 10;
			accelerateBttn.textLabel.y = 3;
			
			accelerateBttn.countLabel.x = -22;
			accelerateBttn.countLabel.y = 24;
			
			accelerateBttn.coinsIcon.x = 40;
			accelerateBttn.coinsIcon.y = 22;*/
			
			accelerateBttn.x = settings.width - accelerateBttn.settings.width - 68;
			accelerateBttn.y = cookingBar.y - 20;
			
			accelerateBttn.textLabel.x = 10;
			accelerateBttn.textLabel.y = 3;
			
			accelerateBttn.countLabel.x = accelerateBttn.settings.width / 2 - accelerateBttn.countLabel.textWidth;// -12;
			accelerateBttn.countLabel.y = 22;
			
			//accelerateBttn.countLabel.border = true;
			
			accelerateBttn.coinsIcon.x = 40;
			accelerateBttn.coinsIcon.y = 22;
			
			productIcon = new Sprite();
			var bitmap:Bitmap = new Bitmap();
			productIcon.addChild(bitmap);
			bodyContainer.addChild(productIcon);
			productIcon.x = 90;
			productIcon.y = 594;
			
			productIcon.addChild(preloader);
			preloader.scaleX = preloader.scaleY = 0.7;
			//preloader.x = (background.width)/ 2;
			//preloader.y = (background.height) / 2;
			
			Load.loading(
				Config.getIcon("Material", App.data.storage[App.data.farming[fID].out].preview),
				function(data:Bitmap):void{
					bitmap.bitmapData = data.bitmapData;
					bitmap.scaleX = bitmap.scaleY = 0.7;
					bitmap.smoothing = true;
					bitmap.x = -bitmap.width / 2 + 12;
					bitmap.y = -bitmap.height / 2;
					productIcon.removeChild(preloader);
				}
			);
			
			var plantSID:Object = App.data.farming[fID].plant;
			var plantObject:Object = App.data.storage[plantSID];
			
			crafted = settings.target.crafted;
			totalTime = plantObject.levels * plantObject.levelTime;
			progress();
			cookingBar.start();
			
			App.self.setOnTimer(progress);
			busy = true;
		}
		
		override public function onAccelerateEvent(e:MouseEvent):void {
			settings.target.onBoostEvent();
			close();
		}
		
		override public function createItems():void {
			
			var X:int = 76;
			var Xs:int = X;
			var Y:int = topBg.y + 12;
			
			for (var i:int = 0; i < settings.itemsOnPage;  i++)
			{
				var item:FarmingItem = new FarmingItem(this);
				
				bodyContainer.addChild(item);
				items.push(item);
				
				item.x = X;
				item.y = Y;
				
				X += item.background.width + 12;
				if (i == int(settings.itemsOnPage / 2) - 1)
				{
					X = Xs;
					Y += item.background.height + 20;
				}
			}
		}
		
		override public function onCookEvent(fID:uint):void {
			
			super.onCookEvent(fID);
			
			dispatchEvent(new WindowEvent(WindowEvent.ON_CONTENT_UPDATE));
		}
		
		
	}
}
