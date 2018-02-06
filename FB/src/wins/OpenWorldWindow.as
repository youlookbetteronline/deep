package wins {
	
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.elements.UnlockItem;
	
	public class OpenWorldWindow extends Window {
		private var inItem:MaterialItem;
		
		public var worldID:int;
		public var openBttn:Button;
		public var buyBttn:MoneyButton;
		public var container:Sprite;
		
		public function OpenWorldWindow(settings:Object):void {
			if (settings == null) settings = {};
			
			worldID = settings.worldID || 0;
			
			settings["width"] = 60;
			settings["height"] = 370;
			settings["background"] = 'capsuleWindowBacking';
			settings["popup"] = true;
			settings["callback"] = settings["callback"] || null;
			settings["hasPaginator"] = false;
			
			settings["description"] = Locale.__e("flash:1382952380232");
			settings["fontSize"] = 36;
			settings["fontBorderColor"] = 0x104d0a;
			settings["fontBorderSize"] = 2;
			settings["title"] = App.data.storage[worldID].title;
			settings['width'] += 140 * Numbers.countProps(settings.content) + 90;
			settings['exitTexture'] = 'closeBttnMetal';
			
			super(settings);
		}
		
		override public function drawBackground():void {
			if (settings.background!=null) 
			{
			var background:Bitmap = backing(settings.width, settings.height, 40, settings.background);
			layer.addChild(background);	
			}
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				shadowSize 			: 0,	
				shadowBorderColor	: 0x5c9900,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -36;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			
			var titleBackingBmap:Bitmap = backingShort((titleLabel.width <= 310)? 360 : titleLabel.width + 50, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = titleLabel.x + (titleLabel.width - titleBackingBmap.width) / 2;
			titleBackingBmap.y = titleLabel.y + (titleLabel.height - titleBackingBmap.height) / 2 + 15;
			headerContainer.addChild(titleBackingBmap);
			headerContainer.swapChildren(titleBackingBmap, titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void {
			
			/*var background2:Bitmap = Window.backing(settings.width - 90, 245, 10, "paperClear");
			bodyContainer.addChildAt(background2, 0);
			background2.x = (settings.width - background2.width) / 2;
			background2.y = 15;*/
			
			openBttn = new Button( {
				width:		180,
				height:		52,
				caption:	Locale.__e('flash:1382952379890')
			});
			openBttn.x  = (settings.width - openBttn.width) / 2;
			openBttn.y = settings.height - openBttn.height / 2 - 50;
			bodyContainer.addChild(openBttn);
			openBttn.addEventListener(MouseEvent.CLICK, onOpen);
			
			buyBttn = new MoneyButton( {
				width:		180,
				height:		52,
				caption:	Locale.__e('flash:1382952379890'),
				countText:	App.data.storage[worldID].price
			});
			buyBttn.x  = (settings.width - buyBttn.width) / 2;
			buyBttn.y = settings.height - 90;
			bodyContainer.addChild(buyBttn);
			openBttn.addEventListener(MouseEvent.CLICK, onBuy);
			onUpdateOutMaterial();
			
			container = new Sprite();
			bodyContainer.addChild(container);
			
			var subTitle:TextField = Window.drawText(Locale.__e("flash:1435916018685") , {
				fontSize:24,
				color:0xFFFFFF,
				autoSize:"center",
				borderColor:0x703e14,
				width: settings.width - 40,
				multiline: true,
				wrap: true,
				textAlign: 'center'
				
			});
			bodyContainer.addChild(subTitle);
			subTitle.x = (settings.width  - subTitle.width) / 2;
			subTitle.y = -7;
			
			contentChange();
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onUpdateOutMaterial)
		}
		
		override public function contentChange():void {
			for (var s:* in settings.content) {
				var background:Bitmap = Window.backing(160, 230, 10, "banksBackingItem");
				//var background:Bitmap = Window.backing(160, 230, 10, "itemBacking");
				//partBcList.push(background);
				container.addChild(background);
				
				inItem = new MaterialItem({
					sID:int(s),
					need:settings.content[s],
					window:this, 
					type:MaterialItem.IN,
					color:0x5a291c,
					borderColor:0xfaf9ec,
					bitmapDY: -10,
					bgItemY:38,
					bgItemX:20
				}, null);
				
				
				inItem.background.visible = false;
				inItem.x = container.numChildren * (inItem.background.width - 10) - 58;
				inItem.y = 30; 
				inItem.checkStatus();
				inItem.background.visible = false;
				background.x = inItem.x - (background.width - inItem.width) / 2 - 17 ;
				if(App.data.storage[inItem.sID].mtype == 6)
					background.x = inItem.x - (background.width - inItem.width) / 2;
				background.y = inItem.y - 40;
				
				container.addChild(inItem);
			}
			
			container.x = (settings.width - container.width) / 2;
			container.y = 65;
		}
		
		public function onUpdateOutMaterial(e:* = null):void {
			//openBttn.visible = true;
			buyBttn.visible = false;
			if (App.user.stock.checkAll(settings.content)) {
				openBttn.state = Button.NORMAL;
				//buyBttn.visible = false;	
			} else {
				openBttn.state = Button.DISABLED;
				//buyBttn.visible = true;
			}
		}
		
		private function onOpen(e:MouseEvent):void {
			if (openBttn.mode == Button.DISABLED) {
				return
			}
			World.openMap(worldID, onOpenComplete, 1);
		}
		
		private function onBuy(e:MouseEvent):void {
			//World.openMap(worldID, onOpenComplete, 1);
		}
		
		private function onOpenComplete():void {
			if (App.user.worlds.hasOwnProperty(worldID)) {
				Window.closeAll();	
				Travel.goTo(worldID);
			}
			//close();
		}
		
		override public function dispose():void 
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onUpdateOutMaterial)
			super.dispose();
		}
	}		
}