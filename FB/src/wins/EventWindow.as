package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.elements.OutItem;
	
	public class EventWindow extends Window
	{
		public var item:Object;
		
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		
		private var buyBttn:MoneyButton;
		private var back:Shape = new Shape();
		
		private var sID:uint;
		private var need:uint;
		private var container:Sprite;
		
		private var partList:Array = [];
		private var padding:int = 10;
		public var outItem:OutItem;
		public var eventBttn:Button;
		
		public function EventWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = 400;
			settings["height"] = 340;
			settings["popup"] = true;
			settings["fontSize"] = 30;
			settings["callback"] = settings["callback"] || null;
			settings["hasPaginator"] = false;
			settings["bttnCaption"] = settings.bttnCaption || Locale.__e("flash:1382952380090");
			
			for (var _sid:* in settings["req"]) {
				sID = _sid;
				need = settings["req"][sID];
			}
			
			settings["title"] = settings.target.info.title;
			
			super(settings);	
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 38,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x4c871c,			
				borderSize 			: 3,					
				shadowColor			: 0x085c10,
				//width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
		
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = - 62; 
			bodyContainer.addChild(titleLabel);
			
		}	
		
		override public function drawBackground():void {
			var background:Bitmap =  backing(settings.width + 50, settings.height, 50, 'capsuleWindowBacking');
			layer.addChild(background);	
			
			var bgPaper:Bitmap = backing(settings.width - 18, settings.height - 68, 40, 'paperClear');
			bgPaper.x = background.x + (background.width - bgPaper.width) / 2;
			bgPaper.y = background.y + (background.height - bgPaper.height) / 2;
			layer.addChild(bgPaper);
			
			drawMirrowObjs('decSeaweed', settings.width + 106, - 56, settings.height - 174, true, true, false, 1, 1, layer);
		}
		
		
		
		override public function drawBody():void {
			
			if (settings.hasDescription) settings.height += titleLabel.height+titleLabel.y;

			headerContainer.y += 28;
			drawDescription();
			
			createItems();
			
			/*var background:Bitmap = backing(settings.width, settings.height, 30, "bankBacking");
			layer.addChild(background);*/
			
			//drawMirrowObjs('storageWoodenDec', 0, settings.width, settings.height - 110);
			//drawMirrowObjs('storageWoodenDec', 0, settings.width, 50, false, false, false, 1, -1);
				//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2, settings.width / 2 + settings.titleWidth / 2, titleLabel.y , true, true);
				
			var ribbon:Bitmap = backingShort(titleLabel.width + 20, 'ribbonGrenn');
			ribbon.y = -40;
			ribbon.x = (settings.width - ribbon.width) / 2 + 25;
			layer.addChild(ribbon);
		
			
			titleLabel.x = (settings.width - titleLabel.width) * .5 + 25;
			
			container.x = padding;
			container.y = 6;
			
			eventBttn = new Button({
				caption		:Locale.__e('flash:1382952379890'),
				width		:140,
				height		:45,
				fontSize	:26
			});
			
			bodyContainer.addChild(eventBttn);
			eventBttn.x = (settings.width - eventBttn.width) / 2 + 28;
			eventBttn.y = settings.height - eventBttn.height - 23; 
			
			if (App.user.stock.data[sID] >= need)
				eventBttn.state = Button.NORMAL;
			else
				eventBttn.state = Button.DISABLED;
			
			eventBttn.addEventListener(MouseEvent.CLICK, onClick);
			exit.x = settings.width - 5;
			exit.y -= exit.height/2 + 13;
			
		}
		
		private function onClick(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) 
				return;
			e.currentTarget.state = Button.DISABLED;
			settings.onWater();
			close();
		}
		
		private function drawDescription():void 
		{
			
			var text1:TextField = drawText(Locale.__e(settings.description), {
				color: 0xFFFFFF,
				borderColor:0x6f3d1a,
				borderSize:4,
				fontSize:24,
				textAlign:settings.textAlign,
				autoSize:settings.autoSize,
				multiline:true
			});
			
			text1.width = settings.width - 40;
			bodyContainer.addChildAt(text1, 1);
			text1.x = (settings.width - text1.width) / 2 + 110;
			text1.y = 20;
			back.graphics.beginFill(0xfff4b9, .9);
		    back.graphics.drawRect(0, 0, 260, 30);
		    back.graphics.endFill();
			//back.height = 30;
		    back.x = text1.x - 40;
		    back.y = text1.y;
		    back.filters = [new BlurFilter(20, 0, 2)];
		    bodyContainer.addChildAt(back, 0);
		}
		
		private function createItems():void
		{
			container = new Sprite();
			
			var inItem:MaterialItem = new MaterialItem({
				sID:sID,
				need:need,
				window:this, 
				type:MaterialItem.IN,
				bitmapDY:-10
			});
				
			inItem.checkStatus();
			inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
			inItem.bitmap.y += 7;
			inItem.x = (settings.width - inItem.background.width) / 2 + 20;
			inItem.y = 80;
			
			container.addChild(inItem);
			bodyContainer.addChild(container);
		}
		
		public function onUpdateOutMaterial(e:WindowEvent):void 
		{
			if (App.user.stock.data[sID] >= need)
				eventBttn.state = Button.NORMAL;
			else
				eventBttn.state = Button.DISABLED;
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}		
}
