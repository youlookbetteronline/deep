package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	/**
	 * ...
	 * @author 
	 */
	public class TechnoEquipWindow extends Window 
	{
		public var container:Sprite = new Sprite();
		
		private var textFilter:GlowFilter;
		private var shadowFilter:BlurFilter;
		protected var partList:Array = [];
		private var scale:Number;
		
		public function TechnoEquipWindow(settings:Object=null) 
		{
			
			settings["width"] = 750;
			settings["height"] = 510;
			settings["hasPaginator"] = false;
			settings["scaleW"] = settings["scaleW"] || App.map.scaleX;
			scale = settings.scaleW;
			settings["hasTitle"] = false;
			settings['exitTexture'] = 'closeBttnMetal';
			
			super(settings);
			
		}
		
		override public function drawBackground():void
		{			
			var background:Bitmap = new Bitmap(Window.textures.workerHouseBack); //backing2(settings.width, settings.height ,50, 'constructBackingUp', 'constructBackingBot');
			layer.addChild(background);
			settings.width = background.width;
			settings.height = background.height;
		}
		
		override public function drawExit():void 
		{
			var bubbleExit:Bitmap = new Bitmap(Window.textures.clearBubbleBacking);
			headerContainer.addChild(bubbleExit);
			Size.size(bubbleExit, 82, 82);
			bubbleExit.smoothing = true;
			bubbleExit.x = settings.width - 262;
			bubbleExit.y = 8;
			
			exit = new ImageButton(textures[this.settings.exitTexture]);
			headerContainer.addChild(exit);
			exit.x = bubbleExit.x + (bubbleExit.width - exit.width) / 2;
			exit.y = bubbleExit.y + (bubbleExit.height - exit.height) / 2;
			
			
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		override public function drawTitle():void 
		{
			settings["title"] = settings.title;
			titleLabel = titleText( {
				title				: settings.title, //заменить
				color				: 0xf9fdff,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x5c9900,			
				borderSize 			: settings.fontBorderSize,					
				shadowBorderColor	: 0x235b00,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = +3;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			//headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		private var downPlankBmap:Bitmap = new Bitmap();
		private var hireBttn:Button;
		private var infoBttn:ImageButton;
		override public function drawBody():void {
			
			
			var titleBackingBmap:Bitmap = backingShort(390, 'ribbonGrenn',true,1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -39;
			titleBackingBmap.filters = [new DropShadowFilter(4.0, 90, 0, 0.5, 4.0, 4.0, 1.0, 3, false, false, false)];
			//bodyContainer.addChild(titleBackingBmap);
			
			downPlankBmap = backingShort(300, 'shopPlankDown');
			downPlankBmap.x = (settings.width - downPlankBmap.width) / 2;
			downPlankBmap.y = settings.height - downPlankBmap.height -26;
			//bodyContainer.addChild(downPlankBmap);
			
			//drawMirrowObjs('decSeaweed', settings.width + 55, - 55, settings.height - 280 - 28, true, true);
			//bodyContainer.swapChildren(downPlankBmap, hireBttn);
			
			hireBttn = new Button( {
				width: 		140,
				height:		45,
				caption:	Locale.__e('flash:1475676146971')
			});
			
			hireBttn.x = downPlankBmap.x + (downPlankBmap.width - hireBttn.width)/2 + 15;
			hireBttn.y = downPlankBmap.y + (downPlankBmap.height - hireBttn.height) + 46;
			hireBttn.addEventListener(MouseEvent.CLICK, onEquip);
			hireBttn.state = Button.DISABLED;
			hireBttn.filters = [new DropShadowFilter(4.0, 90, 0, 0.5, 4.0, 4.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(hireBttn);
			
			infoBttn = new ImageButton(Window.textures.buttonList);
			infoBttn.addEventListener(MouseEvent.CLICK, onInfo);
			infoBttn.x = 50;
			infoBttn.y = exit.y - 1;
			
			var bubble:Bitmap = new Bitmap(Window.textures.clearBubbleBacking);
			bodyContainer.addChild(bubble);
			Size.size(bubble, 82, 82);
			bubble.smoothing = true;
			bubble.x = infoBttn.x + (infoBttn.width - bubble.width) / 2 + 1;
			bubble.y = infoBttn.y + (infoBttn.height - bubble.height) / 2 - 2;
			bodyContainer.addChild(infoBttn);
			
			exit.x = settings.width - exit.width - 8;
			exit.y = 15;
			
			drawTechno();
		}
		
		override public function dispose():void 
		{
			super.dispose();
			infoBttn.removeEventListener(MouseEvent.CLICK, onInfo);
		}
		private var itemsGive:Object = { };
		private function onInfo(e:MouseEvent):void 
		{
			/*var hintWindow:RouletteInfoWindow = new RouletteInfoWindow( {
			popup: true
			});
			hintWindow.show();*/
			var i:int = 0;
			for each(var ii:* in App.data.treasures[settings.target.info.treasure][settings.target.info.treasure].item)
			{
				if (App.data.storage[ii].mtype != 3)
					itemsGive[ii] = App.data.treasures[settings.target.info.treasure][settings.target.info.treasure].count[i];
					
				i++;
			}
			
			var hintWindow:RouletteItemsWindow = new RouletteItemsWindow({
				popup:true,
				title:App.data.storage[settings.target.workerSID].title,
				items:{0: itemsGive}
			});
			hintWindow.show();
			
		}
		
		private var technoIcon:LayerX;
		private var technoIn:Bitmap;
		public function drawTechno():void
		{
			technoIn = new Bitmap();
			technoIcon = new LayerX();
			//container.addChild(technoIcon);
			Load.loading(Config.getImage('wigwam_techno', App.data.storage[settings.wSID].preview), function(data:Bitmap):void
			{
				technoIcon = new LayerX();
				technoIn.bitmapData = data.bitmapData;
				technoIn.smoothing = true;
				Size.size(technoIn, 260, 140);
				technoIcon.addChild(technoIn);
				//technoIn.scaleX = -technoIn.scaleX;
				container.addChild(technoIcon);				
				technoIcon.x = 20;
				technoIcon.y = 120;
				if (App.data.storage[settings.wSID].preview == 'turtle'){
					technoIcon.y = 63;
					technoIcon.x = -5;
					technoIcon.filters = [new DropShadowFilter(5.0, 120, 0, 0.1, 5.0, 5.0, 3.0, 3, false, false, false)];
				}
					
				technoIcon.filters = [new DropShadowFilter(5.0, 120, 0, 0.5, 5.0, 5.0, 3.0, 3, false, false, false)];
				
				drawNeedItem();
			});		
			
			bodyContainer.addChild(container);
			/*container.x = (settings.width - container.width) / 2;
			container.y = (settings.height - container.height) / 2;*/
		}
		
		private var plankBmap:Bitmap;
		public function drawNeedItem():void
		{
			var plus:Bitmap = new Bitmap(Window.textures.plus);
			
			//container.addChild(plus);
			plus.x = technoIcon.x + technoIcon.width + 5;
			plus.y = (technoIcon.height - plus.height ) / 2;
			
			plankBmap = backingShort(240, 'helfBacking'); // надо будет заменить
			plankBmap.x = plus.x + 15;
			plankBmap.y = plus.y + plus.height - 20;
			//container.addChild(plankBmap);
			
			var inItem:WorkerItem = new WorkerItem({
				sID:Numbers.firstProp(settings.materials).key,
				need:Numbers.firstProp(settings.materials).val,
				window:this,
				bitmapDY: +5
			});
			
			inItem.checkStatus();
			inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
			
			inItem.background.visible = false;
			inItem.wishBttn.visible = false;
			inItem.searchBttn.visible = false;
			partList.push(inItem);
			
			container.addChild(inItem);
			
			inItem.x = plankBmap.x + (plankBmap.width - inItem.width) / 2 - 30;
			inItem.y = plankBmap.y + (plankBmap.height - inItem.height) / 2 + 55;
			
			container.x = (settings.width - container.width) / 2;
			container.y = (settings.height - container.height) / 2;
			onUpdateOutMaterial();	
		}
		
		protected function onEquip(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) {
				for (var i:int = 0; i < partList.length; i++ ) {
					partList[i].doPluck();
				}
				//requiresList.doPluck();				
				Hints.text(Locale.__e('flash:1382952379927') + "!", Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));//Нельзя!
				return;
			}
			e.currentTarget.state = Button.DISABLED;
			
			
			this.close();
			Post.send({
				ctr:settings.target.type,
				act:'start',
				uID:App.user.id,
				id:settings.target.id,
				wID:App.user.worldID,
				sID:settings.target.sid
			}, function(error:int, data:Object, params:Object):void 
			{
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				
				if (data.hasOwnProperty('crafted')) {
					settings.target.crafted = data.crafted;
					settings.target.goSearch();
				}else {
					/*ordered = false;
					hasProduct = false;
					queue = [];
					crafted = 0;*/
					//onStorageEvent(error, data, params);
				}
				App.user.stock.takeAll(settings.materials);
			});	
		}
		
		public function onUpdateOutMaterial(e:WindowEvent = null):void {
			var outState:int = WorkerItem.READY;
			for each(var item:* in partList) {
				if(item.status != WorkerItem.READY){
					outState = item.status;
				}
			}
			
			/*if (requiresList && !requiresList.checkOnComplete())
				outState = MaterialItem.UNREADY;*/
			
			if (outState == WorkerItem.UNREADY) 
				hireBttn.state = Button.DISABLED;
			else if (outState != WorkerItem.UNREADY)
				hireBttn.state = Button.NORMAL;
			
		}
		
		public function focusAndShow():void 
		{
			App.map.focusedOnCenter(settings.target, false, function():void 
			{
				//settings.win.settings.target.visible = false;
				show();
			}, true, 1, true, 0.5);
		}
		
		public function unfocus():void 
		{
			if (scale != 1)
			{
				App.map.focusedOnCenter(settings.target, false, null, true, scale, true, 0.3);
			}
				
			//settings.target = null;
			scale = 1;
		}
		
		public override function close(e:MouseEvent = null):void {
			
			//if(settings.target.unFocus){
			unfocus();
			//}
			
			super.close();
		}
		
	}

}