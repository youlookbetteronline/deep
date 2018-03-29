package wins {
	
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.elements.SimpleItem;
	import wins.elements.UnlockItem;
	
	public class OpenWorldWindow extends Window {
		
		public var worldID:int;
		public var openBttn:Button;
		public var buyBttn:MoneyButton;
		public var container:Sprite;
		
		public function OpenWorldWindow(settings:Object):void {
			if (settings == null) settings = {};
			
			worldID = settings.worldID || 0;
			
			settings["width"] = 60;
			settings["height"] = 290;
			for (var req:* in settings.content)
			{
				if (App.user.stock.count(req) < settings.content[req])
				{
					settings["height"] = 370;
					break;
				}
			}
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
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onUpdateOutMaterial);
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, onUpdateOutMaterial);
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
		}
		
		override public function contentChange():void {
			var offsetX:int = 0;
			for (var s:* in settings.content) {
				var background:Bitmap = Window.backing(160, settings.height - 135, 10, "banksBackingItem");
				container.addChild(background);
				
				var inItem:SimpleItem = new SimpleItem(int(s), {
					item:{width:110, height:110},
					count:{need:settings.content[s], align:'center', dy: 20},
					bttns:{dy: 20},
					bg:{hasBg: false},
					window:this
				});
				background.x = offsetX;
				inItem.x = background.x + (background.width - inItem.WIDTH) / 2;
				inItem.y = 20;
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				offsetX += background.width + 15;
				container.addChild(inItem);
			}
			container.x = (settings.width - container.width) / 2;
			container.y = 45;
			if(inItem)
				inItem.dispatchEvent(new WindowEvent(WindowEvent.ON_CONTENT_UPDATE));
		}
		
		public function onUpdateOutMaterial(e:* = null):void {
			buyBttn.visible = false;
			/*if (App.user.stock.checkAll(settings.content)) {
				openBttn.state = Button.NORMAL;
			} else {
				openBttn.state = Button.DISABLED;
			}*/
			openBttn.state = Button.NORMAL;
			for (var sid:* in settings.content)
			{
				if (App.user.stock.count(sid) < settings.content[sid])
				{
					openBttn.state = Button.DISABLED;
					return;
				}
			}
		}
		
		private function onOpen(e:MouseEvent):void {
			if (openBttn.mode == Button.DISABLED) {
				return
			}
			World.openMap(worldID, onOpenComplete, 1);
		}
		
		private function onOpenComplete():void {
			if (App.user.worlds.hasOwnProperty(worldID)) {
				Window.closeAll();	
				Travel.goTo(worldID);
			}
		}
	}		
}