package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Hints;
	import units.Building;
	import units.Techno;
	import units.Unit;
	import wins.elements.OutItem;
	public class RecipeWindow extends Window
	{
		public static var rememberCraft:Object = {};
		public static var rememberProduction:Object = {};
		
		public var item:Object;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var outItem:OutItem;
		public var arrowLeft:ImageButton;
		public var arrowRight:ImageButton;
		public var stopGlowing:Boolean = false;
		public var requiresList:RequiresList;
		public var technoIcon:LayerX;
		public var hireTechBttn:Button;
		public var hasTechno:Boolean = false;
		public var count:int = 0;
		public var prev:int = 0;
		public var next:int = 0;
		public var needRecs:Boolean = false;
		public var technoBacking:Bitmap = new Bitmap();
		public var technoBackingUp:Bitmap = new Bitmap();
		public var backgroundTitle:Bitmap = new Bitmap();
		public var container:Sprite = new Sprite();
		public var countContainer:Sprite = new Sprite();
		public var items:Vector.<MaterialItem> = new Vector.<MaterialItem>;
		
		protected var _backLine:Bitmap;
		protected var _background:Bitmap;
		protected var _equality:Bitmap;
		protected var partList:Array = [];
		protected var padding:int = 20;
		protected var formula:Object;
		protected var backgroundWidth:int;
		protected var _minWidth:int = 360;
		
		private var sID:uint;
		private var itemSid:*;
		private var itemQtty:*;
		private var wigwamSID:*;
		private var wigwamID:*;
		private var buyBttn:MoneyButton;
		private var preloader:Preloader = new Preloader();
		
		public function RecipeWindow(settings:Object = null):void
		{
			if (settings == null) 
			{
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = settings.width || 670;
			settings["height"] = settings.height || 300;
			settings["popup"] = true;
			settings["fontSize"] = settings.fontSize || 38;
			settings["fontColor"] = settings.fontColor || 0xfffa74
			settings["fontBorderColor"] = settings.fontBorderColor || 0x70401d
			settings["faderAlpha"] = 0.000000001;
			settings["callback"] = settings["callback"] || null;
			settings["dontCheckTechno"] = settings["dontCheckTechno"] || false;
			settings["hasPaginator"] = false;
			
			formula = App.data.crafting[settings.fID];
			
			sID = formula.out;
			
			if (settings.win != undefined) {
				var crafting:Object = {};
				for (var itm:* in settings.win.craftData) 
				{
					if (settings.win.craftData[itm].lvl <= App.user.level) 
					{
						crafting[itm] = settings.win.craftData[itm].fid;
					}
				}
				for each(var item:* in crafting) 
				{
					if (settings.fID == item) 
					{
						break;
					}
					prev = item;
				}
				
				for each(item in crafting) 
				{
					if (next == -1) 
					{
						next = item;
						break;
					}
					if (settings.fID == item) 
					{
						next = -1;
					}
				}
				//trace();
			}
			
			var requiresCount:int = 0;
			var requires:Object = { };
			var materialsCount:int = 0;
			var materials:Object = { };
			//if (settings.target.info.type !settings.hasOwnProperty('materials'))
			//{
				
				for (var sID:* in formula.items) {
					
				if(App.data.storage[sID].type == 'Techno'){
					requiresCount ++;
					requires[sID] = formula.items[sID];
				}else{
					materialsCount ++;
					materials[sID] = formula.items[sID];
				}
					
					
				}
				if (settings.building && App.data.crafting[settings.fID].hasOwnProperty('rcount') && App.data.crafting[settings.fID].rcount != "")
				{
					materials = settings.building.craftNeed[settings.fID];
				}
				if (settings.hasOwnProperty('fromBuild') && settings.fromBuild == true)
				{
					materialsCount = 3;
				}else{
				
					settings['requires'] = requires;
					settings['materials'] = materials;
				}
			//}
			
			if (materialsCount == 0)
			{
				settings['materials'][Stock.FANTASY] = requires[Stock.FANTASY];
				delete settings['requires'][Stock.FANTASY];
			}
			
			super(settings);	
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.addEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);
		}
		
		/*override public function titleText(settings:Object):Sprite
		{
			
			if (!settings.hasOwnProperty('width'))
				settings['width'] = 300;
			
			var cont:Sprite = new Sprite();
			
			settings.shadowSize = settings.shadowSize || 3;
			settings.shadowColor = settings.shadowColor || 0x111111;
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			this.settings['titleWidth'] = textLabel.textWidth;
			this.settings['titleHeight'] = textLabel.textHeight;
			textLabel.wordWrap = true;
			textLabel.width = settings.width;
			textLabel.height = textLabel.textHeight + 4;
			
			var filters:Array = []; 
			
			if (settings.borderSize > 0) 
			{
				filters.push(new GlowFilter(settings.borderColor || 0x7e3e14, 1, settings.borderSize, settings.borderSize, 16, 1));
			}
			
			if (settings.shadowSize > 0) 
			{
				filters.push(new DropShadowFilter(settings.shadowSize, 90, 0x4d3300, 1, 0, 0));
			}
			
			textLabel.filters = filters;
			
			cont.addChild(textLabel);
			cont.mouseEnabled = false;
			cont.mouseChildren = false;
			return cont;
		}*/
		
		override public function show():void 
		{
			super.show();
			findHelp();
		}
		
		public function findHelp():void 
		{
			if (outItem.recipeBttn.__hasGlowing) 
			{
				outItem.recipeBttn.hideGlowing();
			}
			if (outItem.recipeBttn.__hasPointing) 
			{
				outItem.recipeBttn.hidePointing();	
			}
			
			
			if (settings.isHelp||Quests.help) {
				var showUpgrd:Boolean = true;
				for (var i:int = 0; i < partList.length; i++) 
				{
					if (partList[i].askBttn && partList[i].askBttn.visible) 
					{
						partList[i].askBttn.showGlowing();
						showUpgrd = false;
					}else 
					{
						if (partList[i].askBttn && partList[i].askBttn.__hasGlowing)
						partList[i].askBttn.hideGlowing();
					}
				}
				if (showUpgrd && !(outItem.recipeBttn.mode == Button.DISABLED) )
				{
					outItem.recipeBttn.showGlowing();
					outItem.recipeBttn.showPointing('bottom', 0, 60, outItem,'',null,false,true);	
				}
				
			}
		}
		
		protected function onStockChange(e:AppEvent):void 
		{
			if (requiresList && requiresList.parent) {
				requiresList.parent.removeChild(requiresList);
				requiresList.dispose();
				requiresList = null;
			}
			
			for (var i:int = 0; i < partList.length; i++ )
			{
				var itm:MaterialItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			if (_equality && _equality.parent)
			{
				_equality.parent.removeChild(_equality);
				_equality = null;
			}
			
			if (outItem && outItem.parent)
			{
				outItem.parent.removeChild(outItem);
				outItem = null;
			}
			
			for (i = 0; i < container.numChildren; i++ )
			{
				container.removeChildAt(0);
				i--;
			}
			
			if (container && container.parent) 
			{
				container.parent.removeChild(container);
			}
			
			createItems(settings['materials']);
			
			/*if (outItem)
			{
				outItem.x = padding + backgroundWidth + 6;
				outItem.y = 70;
			}*/
			
			//container.x = padding + (backgroundWidth - container.width) / 2;
			//_equality.x = padding + backgroundWidth - _equality.width / 2 - 17;
			//_equality.y = 103;
			
			findHelp();
		}
		
		override public function drawBackground():void
		{
		}
		
		override public function drawExit():void
		{
			super.drawExit();
			
			exit.x = settings.width - exit.width + 18;
			exit.y = -18;
		}
		
		/*override public function drawTitle():void 
		{	
			settings["fontBorderSize"] = 2;
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x70401d,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 500,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: false
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -10;
			bottomContainer.addChild(titleLabel);			
		}*/
		
		
		
		override public function drawBody():void 
		{			
			if (settings.hasDescription) settings.height += 40;
			titleLabel.y = 55;
			
			var ln:uint = 0;
			
			var reqLength:* = Numbers.countProps(settings['requires']);
			
			if (reqLength > 0)
			{
				needRecs = true;
			}else{
				needRecs = false;
			}
			
			for (var cn:* in settings['materials'])
			{
				ln++;
			}
			
			if (settings['materials'].hasOwnProperty(28) || !settings['materials'] && ln < 2)
			{
				createItems(settings['requires']);
				needRecs = false;
			}else {
				createItems(settings['materials']);
			}
			
			backgroundWidth = /*container.width;*/ partList.length * 145 /*(partList[0].background.width + 45 + 24)*/ + 160;
			
			if (needRecs)
			{
				backgroundWidth += 150;
			}
			
			if (backgroundWidth < _minWidth)
				backgroundWidth = _minWidth;
			
			var backgroundShape:Shape = new Shape();
			backgroundShape.graphics.beginFill(0xe6b685);
			backgroundShape.graphics.drawCircle(50, 50, 50);
			backgroundShape.graphics.endFill();
			
			_background = new Bitmap(new BitmapData(100, 100, true, 0));
			_background.bitmapData.draw(backgroundShape);
			
			//_background = new Bitmap(Window.textures.bgItem);
			_background.x = padding;
			_background.y = 6;
			
			//_backLine = Window.backing(_background.width - 36, 48, 10, "recipte_line");
			//_backLine.x = _background.x + 18;
			//_backLine.y = _background.y + 12;
			
			settings.width = padding * 3 + backgroundWidth /*+ 5 + partList[0].background.width + 20 + padding*/;
			
			
			var background:Bitmap = backing(settings.width, settings.height , 50, 'workerHouseBacking');
			
			container.x = padding * 3;
			if (needRecs)
			{
				container.x += 150;
			}
			
			var background2:Bitmap  = backing2(settings.width - 60, settings.height - 54, 40, 'capsuleWindowBackingPaperUp', 'capsuleWindowBackingPaperDown');
			background2.x = background.x + (background.width - background2.width) / 2;
			background2.y = background.y + (background.height - background2.height) / 2;
			
			layer.addChildAt(background, 0);
			layer.addChild(background2);
			
			technoBackingUp = new Bitmap(Window.textures.technoBack);
			technoBackingUp.x = 26;
			technoBackingUp.y = (settings.height - technoBackingUp.height) / 2;
			
			technoBacking = new Bitmap(Window.textures.technoBackBack);
			technoBacking.x = technoBackingUp.x + (technoBackingUp.width - technoBacking.width)/2;
			technoBacking.y = technoBackingUp.y + (technoBackingUp.height - technoBacking.height) / 2;
			
			if (needRecs)
			{
				
				layer.addChild(technoBackingUp);
				layer.addChild(technoBacking);
			}
			
			backgroundTitle = Window.backingShort(190, 'titleBgNew', true);
			backgroundTitle.x = (settings.width - backgroundTitle.width) / 2;
			backgroundTitle.y = 56 - 65;
			//backgroundTitle.scaleY = .45;
			//backgroundTitle.alpha = .7;
			
			layer.addChild(backgroundTitle);
			
			drawMirrowObjs('decSeaweed', settings.width + 55, - 55, 162, true, true);
			
			exit.x = settings.width - exit.width + 12;
			titleLabel.x = settings.width / 2 - titleLabel.width / 2;
			titleLabel.y -= 62;
			bodyContainer.addChild(countContainer);
			(needRecs)?drawRequirements(settings['requires']):null;
			
			container.y = 65;
			_background.y = 27;
			//_backLine.y = _background.y + 12;
			
			onUpdateOutMaterial();
			outItem.addGlow();
			
			arrowLeft = new ImageButton(Window.textures.arrow, {scaleX:-0.7,scaleY:0.7});
			arrowRight = new ImageButton(Window.textures.arrow, {scaleX:0.7,scaleY:0.7});
			
			arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, onPrev);
			arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, onNext);
			
			if (prev > 0)
			{
				bodyContainer.addChild(arrowLeft);
				arrowLeft.x = backgroundTitle.x - 20;
				arrowLeft.y = backgroundTitle.y - 31 + (backgroundTitle.height - arrowLeft.height) / 2;
			}
			
			if (next > 0)
			{
				bodyContainer.addChild(arrowRight);
				arrowRight.x = backgroundTitle.x + backgroundTitle.width + 20;
				arrowRight.y = backgroundTitle.y - 31 + (backgroundTitle.height - arrowRight.height) / 2;
			}
			
			if (formula.hasOwnProperty('capacity') && formula.capacity > 0)
				drawLimits();
		}
		
		private function drawLimits():void 
		{
			var _back:Bitmap = Window.backing(210, 150, 50, 'tipWindowUp');
			_back.x = (settings.width - _back.width) / 2;
			_back.y = settings.height - 40;
			bodyContainer.addChild(_back);
			
			var _title:TextField = Window.drawText(Locale.__e('flash:1474469531767'), {
				color:		0xfff368,
				borderColor:0x7f3d0e,
				fontSize:	34
			})
			_title.width = _title.textWidth + 10;
			_title.x = _back.x + (_back.width - _title.textWidth) / 2;
			_title.y = _back.y;
			bodyContainer.addChild(_title);
			
			var _desc:TextField = Window.drawText(Locale.__e('flash:1509534778831'),{
				color:		0xffffff,
				borderColor:0x7f3d0e,
				fontSize:	20,
				multiline:	true,
				wrap:		true,
				textAlign:	'center'
			});
			
			_desc.width = _back.width - 20;
			_desc.x = _back.x + (_back.width - _desc.width) / 2;
			_desc.y = _title.y + _title.textHeight + 5;
			bodyContainer.addChild(_desc);
			
			var _leftCount:int = formula.capacity;
			if (settings.building && settings.building.hasOwnProperty('craftsLimit') && settings.building.craftsLimit.hasOwnProperty(formula.ID))
				_leftCount = settings.building.craftsLimit[formula.ID];
			
			var _left:TextField = Window.drawText(Locale.__e('flash:1393581955601')+ ' ' + String(_leftCount), {
				color:		0xfff368,
				borderColor:0x7f3d0e,
				fontSize:	32
			});
			_left.width = _back.width - 20;
			_left.x = _back.x + (_back.width - _left.textWidth) / 2;
			_left.y = _desc.y + _desc.textHeight + 10;
			bodyContainer.addChild(_left);
			
		}
		
		public function onPrev(e:MouseEvent):void 
		{
			settings.prodItem.recWin = new RecipeWindow( {
				title:Locale.__e("flash:1382952380065"),
				fID:prev,
				onCook:settings.win.onCookEvent,
				busy:settings.win.busy,
				win:settings.win,
				hasDescription:true,
				hasAnimations:false,
				prodItem:settings.prodItem
			});;
			settings.prodItem.recWin.show();
			silentClose();
		}
		
		public function onNext(e:MouseEvent):void 
		{
			settings.prodItem.recWin = new RecipeWindow( {
				title:Locale.__e("flash:1382952380065"),
				fID:next,
				onCook:settings.win.onCookEvent,
				busy:settings.win.busy,
				win:settings.win,
				hasDescription:true,
				hasAnimations:false,
				prodItem:settings.prodItem
			});
			settings.prodItem.recWin.show();
			silentClose();
		}
		
		
		protected function drawRequirements(requirements:Object):void 
		{
			layer.addChild(preloader);
			//Size.size(preloader, 80, 80); 
			preloader.x = technoBacking.x + technoBacking.width / 2;
			preloader.y = technoBacking.y + technoBacking.height / 2;
			//var count:int = 0;
			itemSid = Numbers.firstProp(requirements).key;
			itemQtty = Numbers.firstProp(requirements).val;			
			hasTechno = true;
			Load.loading(Config.getImage('techno', App.data.storage[itemSid].preview), function(data:Bitmap):void
			{
				var bitmapDataScale:BitmapData = new BitmapData(data.bitmapData.width * 0.75,data.bitmapData.height * 0.75,true,0x00000000);
				technoIcon = new LayerX();
				bitmap = new Bitmap(data.bitmapData);
				bitmap.smoothing = true;
				
				
				bitmapDataScale.draw(bitmap, new Matrix (0.75, 0, 0, 0.75));
				
				
				bitmap.bitmapData = bitmapDataScale;
				technoIcon.addChild(bitmap);
				
				var bmd1:BitmapData = technoBacking.bitmapData;
				var bitmap1:Bitmap = new Bitmap(bmd1);
				var bmd2:BitmapData = bitmap.bitmapData;
				var pt:Point = new Point(technoIcon.width - bitmap1.width - 16, 195);
				var rect:Rectangle = new Rectangle(0, bitmap1.height/1.8, bitmap1.width, bitmap1.height+ 100);
				var threshold:uint =  0xFF000000;
				bmd2.threshold(bmd1, rect, pt, "<=", threshold);
				
				var bitmap2:Bitmap = new Bitmap(bmd2);
				bitmap2.smoothing = true;
				layer.addChild(bitmap2);
				
				bitmap2.x = technoBacking.x + technoBacking.width - bitmap2.width  + 16;
				bitmap2.y = technoBacking.y + technoBacking.height - bitmap2.height - 6;
				technoIcon.visible = true;
				layer.removeChild(preloader);
			});	
			
			hireTechBttn = new Button( {
				width			:123,
				fontSize		:26,
				radius			:19,
				caption			:Locale.__e("flash:1396367321622"),
				fontSize		:26,
				height			:44,
				bgColor			:[0xf2ce4f,0xe1a535],//Цвета градиента
				fontBorderColor	:0x6e411e,	
				bevelColor		:[0xf7fe9b, 0xcb6b1e]
				
			});
			
			hireTechBttn.x = technoBackingUp.x + (technoBackingUp.width - hireTechBttn.width) / 2;
			hireTechBttn.y = technoBackingUp.y + technoBackingUp.height + 3;
			layer.addChild(hireTechBttn);
			hireTechBttn.addEventListener(MouseEvent.CLICK, onHireTech)
			hireTechBttn.state = Button.NORMAL;
			hireTechBttn.visible = true;
			
			var technoArr:Array = Map.findUnitsByType(['Techno']);
			
			for each(var _techno:* in technoArr)
			{
				if (itemSid == _techno.sid && !_techno.fake)
				{
					count++;
				}
			}
			
			var wigwamArr:Array = Map.findUnitsByType(['Wigwam']);
			
			for each(var obj:* in wigwamArr)
			{
				if (itemSid == obj.workers[0] && obj.wigwamIsBusy == 0)
				{
					count++;
				}
			}
			
			if (count >= itemQtty)
				hireTechBttn.visible = false;
				//hireTechBttn.state = Button.DISABLED;
			
			var count_txt:TextField = Window.drawText(String(count),{
				fontSize		:26,
				color			:0xffffff,
				borderColor		:0x713f15,
				autoSize		:"left"
			});
			
			var vs_txt:TextField= Window.drawText("/"+" ",{
				fontSize		:24,
				color			:0xffffff,
				borderColor		:0x713f15,
				autoSize		:"left"
			});
			
			var need_txt:TextField = Window.drawText(String(itemQtty),{
				fontSize		:26,
				color			:0xffffff,
				borderColor		:0x713f15,
				autoSize		:"left"
			});			
			
			count_txt.x = 0;
			vs_txt.x = count_txt.width;
			vs_txt.y -= 2;
			need_txt.x = vs_txt.x + vs_txt.width - 3;
			countContainer.addChild(count_txt);
			countContainer.addChild(vs_txt);
			countContainer.addChild(need_txt);
			countContainer.x = technoBackingUp.x + (technoBackingUp.width - countContainer.width) / 2 + 5;
			countContainer.y = technoBackingUp.y + (technoBackingUp.height - countContainer.height) / 2 + 45 - 10;			
		}
		
		
		protected function onHireTech(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) {
				for (var i:int = 0; i < partList.length; i++ ) {
					partList[i].doPluck();
				}
				//requiresList.doPluck();				
				Hints.text(/*Locale.__e('flash:1382952379927')*/ "Рабочий уже есть"+ "!", Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));//Нельзя!
				return;
			}
			e.currentTarget.state = Button.DISABLED;
			closeAll();
			
			//count = 0;
			//var itemSid:* = Numbers.firstProp(requirements).key;
			
			Techno.findCurrentTechno([itemSid], settings.win.settings.target.id, outItem.sID);
			rememberCraft = this.settings;
			rememberProduction = this.settings.prodItem.win.settings;
		}		
		
		protected function createItems(materials:Object):void
		{
			var offsetX:int = 0;
			var offsetY:int = 0;
			/*var dX:int = 0;
			if (needRecs == true)
			{
				dX = 70;
			}*/
			
			//var pluses:Array = [];		
			var count:int = 0;
			
			for(var _sID:* in materials) 
			{
				var inItem:MaterialItem = new MaterialItem({
					sID			:_sID,
					need		:materials[_sID],
					window		:this, 
					type		:MaterialItem.IN,
					bitmapDY	: +5,
					disableAll	:disableAll
				});
				
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(inItem);
				
				container.addChild(inItem);
				inItem.x = offsetX;
				inItem.y = offsetY;
				count++;
				if (count < Numbers.countProps(materials)) 
				{
					var plus:Bitmap = new Bitmap(Window.textures.plus);
					container.addChild(plus);
					//pluses.push(plus)
					plus.scaleX = plus.scaleY = .8;
					plus.smoothing = true;
					plus.x = inItem.x - inItem.background.x + inItem.background.width + 5;
					plus.y = inItem.y + (inItem.background.height - plus.height) / 2;
				}
				
				offsetX += inItem.background.width - inItem.background.x + 45;
			}
			
			//var firstPlus:Bitmap = pluses.shift();
			//container.removeChild(firstPlus);
			
			_equality = new Bitmap(Window.textures.equals, 'auto', true);
			container.addChild(_equality);
			_equality.scaleX = _equality.scaleY = .8;
			//_equality.smoothing = true;
			_equality.x = inItem.x - inItem.background.x + inItem.background.width + 5;
			_equality.y = inItem.y + (inItem.background.height  - _equality.height) / 2;
			
			
			outItem = new OutItem(onCook, {formula:formula, recipeBttnName:"dd", target:settings.win.settings.target,sID:settings.sID});
			outItem.change(formula);
			outItem.x = _equality.x + _equality.width + 4;
			outItem.y = inItem.y /*+ (inItem.background.height  - outItem.height) / 2*/;
			container.addChild(outItem);
			
			//outItem.x = offsetX;
			
			
			bodyContainer.addChild(container);
			//backgroundWidth = partList.length * (partList[0].background.width + 70) ;
			//container.x = 20;// (backgroundWidth - container.width) / 2;
			//container.y = 20;
			
			onUpdateOutMaterial();
		}
		
		protected function disableAll(value:Boolean = true):void 
		{
			for (var i:int = 0; i < partList.length; i++ )
			{
				partList[i].disableBtt(value);
			}
		}
		
		public function onUpdateOutMaterial(e:WindowEvent = null):void {
			
			if (PostManager.instance.isActive && PostManager.instance.isProgress){
				PostManager.instance.waitPostComplete(onUpdateOutMaterial);
				return;
			}
			
			var outState:int = MaterialItem.READY;
			for each(var item:* in partList) {
				if(item.status != MaterialItem.READY){
					outState = item.status;
				}
			}
			if(count < 1 && hasTechno){
				outState = MaterialItem.UNREADY;
				//customGlowing(hireTechBttn);
			}
			
			if (requiresList && !requiresList.checkOnComplete())
				outState = MaterialItem.UNREADY;
			
			if (outState == MaterialItem.UNREADY) 
				outItem.recipeBttn.state = Button.DISABLED;
			else if (outState != MaterialItem.UNREADY)
			{
				outItem.recipeBttn.state = Button.NORMAL;
				stopGlowing = true;
			}
			
			var openedSlots:int;
			openedSlots = settings.win.settings.target.openedSlots;
			if (settings.win.settings.target.queue.length >= openedSlots+1)
				outItem.recipeBttn.state = Button.DISABLED;
		}
		
		protected function onCook(e:MouseEvent):void
		{
			// TODO Обьяснять причину 
			if (settings.busy /*&& (settings.fID != settings.win.settings.target.fID)*/){
				App.ui.flashGlowing(settings.win.progressBacking, 0xFFFF00);
				Hints.text(Locale.__e("flash:1426782737630"), Hints.TEXT_RED, new Point(mouseX, mouseY), false, App.self.tipsContainer);
				return;
			}
			if (formula.out == Stock.JAM && App.user.stock.count(Stock.JAM) >= App.data.levels[App.user.level].jam) {
				Hints.text(Locale.__e("flash:1382952380256"), Hints.TEXT_RED, new Point(mouseX, mouseY), false, App.self.tipsContainer);
			}
			
			if (e.currentTarget.mode == Button.DISABLED) {
				for (var i:int = 0; i < partList.length; i++ ) {
					partList[i].doPluck();
				}
				//requiresList.doPluck();				
				Hints.text(Locale.__e('flash:1382952379927') + "!", Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));//Нельзя!
				return;
			}
			e.currentTarget.state = Button.DISABLED;
			
			outItem.removeGlow();
			
			settings.onCook(settings.fID);
			
			/*if (formula.time == 0)
			{
				this.close();
				
				if ( PostManager.instance.isActive ){
						PostManager.instance.waitPostComplete( showRecipeWindow );
					}
			}
			else{*/
				/*if (formula.time)
				{*/
					close();
				/*} else
				{
					if ( PostManager.instance.isActive ){
						PostManager.instance.waitPostComplete( change );
					}
					else{
						change();
					}
				}*/
			//}
			
			
			
			
			//close();
		}
		
		private function showRecipeWindow():void
		{
			settings.prodItem.recWin = new RecipeWindow( {
				title:Locale.__e("flash:1382952380065"),
				fID:settings.fID,
				onCook:settings.win.onCookEvent,
				busy:settings.win.busy,
				win:settings.win,
				hasDescription:true,
				hasAnimations:false,
				prodItem:settings.prodItem,
				faderAlpha:0.5
			}).show();// .show();
			//settings.prodItem.recWin.show();
		}
		
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
					if (stopGlowing) {
						target.filters = null;
					}
				}});	
			}});
		}
		
		public function change():void
		{
			outItem.flyMaterial();
			clear();
			bodyContainer.removeChild(outItem);
			contentChange();
		}
		
		override public function contentChange():void
		{		
			onUpdateOutMaterial();
		}
		
		private function clear():void 
		{
			while (partList.length)
			{
				var item:MaterialItem = partList.shift();
				item.dispose();
				if (item.parent) item.parent.removeChild(item);
			}
		}
		
		override public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);
			
			for (var i:int = 0; i < partList.length; i++ ) {
				var itm:MaterialItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			super.dispose();
		}
		
		
	}		
}
