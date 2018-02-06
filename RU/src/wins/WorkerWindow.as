package wins 
{
	import buttons.Button;
	import buttons.IconButton;
	import buttons.MixedButton2;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import units.Animal;
	import units.Cowboy;
	import units.Factory;
	import units.Gardener;
	import units.Goldentechno;
	import units.Moneyhouse;
	import units.Resource;
	import units.Techno;
	/**
	 * ...
	 * @author ...
	 */
	public class WorkerWindow extends Window
	{
		private var robotIcon:Bitmap;
		private var robotCounter:TextField;
		private var textSettings:Object;
		private var bitmap:Bitmap;
		private var background2:Bitmap;
		private var separator:Bitmap;
		private var separator2:Bitmap;
		private var collectBttn:MixedButton2;
		
		public var plusBttn:Button;
		public var minusBttn:Button;
		public var minusBttn10:Button;
		public var plusBttn10:Button;
		
		public static const FURRY:int = 1;
		public static const RESOURCE:int = 2;
		public static const COLLECTOR:int = 3;
		public static const COWBOW:int = 4;
		public static const GOLDEN_FURRY:int = 5;
		public static const FURRY_FREE:int = 6;
		public static const FURRY_GARDENER:int = 7;
		
		public var mode:int = FURRY;
		public var free:Boolean = false;
		public var otherResRewarw:Array = new Array(601,602,604)
		public var neededResourse:int = -1;
		public var icon:LayerX;
		public function WorkerWindow(settings:Object = null) 
		{
			
			if (settings == null) 
			{
				settings = new Object();
			}
			
			settings["width"] = 366;
			settings["height"] = 366;
			settings["title"] = settings.info.title;
			
			settings["fontSize"] = 150;
			settings["hasPaginator"] = false;
			mode = settings["mode"] || FURRY;
			free = settings["free"] || false;
			
			for (var pr_sid:* in settings.target.info.require) 
			{
				neededResourse = pr_sid;
			}
			
			super(settings);
		}
		
		override public function drawBackground():void 
		{
			if(mode == FURRY || mode == COLLECTOR || mode == COWBOW || mode == FURRY_FREE || mode == FURRY_GARDENER)
			{
				background = backing(settings.width, settings.height + 45, 20, "alertBacking");
				if (mode != FURRY_FREE) 
				{
					separator = Window.backingShort(160, 'divider', false);
					separator2 = Window.backingShort(160, 'divider', false);
					separator.alpha = separator2.alpha =  0.7;
					separator.x = 40;
					separator.y = separator2.y = 260;
					separator2.x = 325;
					separator2.scaleX = -1;
					bodyContainer.addChild(separator);
					bodyContainer.addChild(separator2);	
				}
			}
			
			if(mode == RESOURCE || mode == GOLDEN_FURRY )
			{
				background = backing(settings.width, settings.height, 20, "alertBacking");
				background.x += 50;
			}
			
			layer.addChildAt(background,0);
		}
		
		override public function drawTitle():void{			
		}
			
		private function drawTitleLabel():void 
		{
			var titleContainer:Sprite = new Sprite();
			var textFilter:GlowFilter = new GlowFilter(0x885827, 1, 4,4, 8, 1);
			var titleText:String;
			if (settings.info.sID == 164) {
				titleText = settings.title;
			}else {
				titleText = settings.info.title;
			}
			var title:TextField = Window.drawText(titleText, {
					color		:0xfeffff,
					borderColor	:0xb88556,
					fontSize	:38,
					multiline	:true,
					wrap		:true,
					textAlign	:"center"
				});
				
				if(mode == FURRY || mode == COLLECTOR || mode == COWBOW || mode == FURRY_FREE || mode == FURRY_GARDENER)
				{
					title.y = -35;
					title.width = 250;
					title.x = (settings.width - title.width) / 2 - 2;
				}
				
				if(mode == RESOURCE || mode == GOLDEN_FURRY)
				{
					title.y = -5;
					title.x += 50;
					title.width = 450;
					title.x = (settings.width - title.width) / 2 + 50;
					
				}
				title.height = title.textHeight;

			titleContainer.addChild(title);
			titleContainer.filters = [textFilter ];
			bodyContainer.addChild(titleContainer);
		}
		
		override public function drawBody():void 
		{
			
			if(mode == FURRY || mode == COLLECTOR || mode == COWBOW || mode == FURRY_FREE || mode == FURRY_GARDENER)
			{
				background2 = Window.backing(205, 188, 30, "storageDarkBackingSlim");	
				background2.x = (settings.width/2 - background2.width / 2);
				background2.y = (settings.height/2 - background2.height / 2) - 20;
				layer.addChild(background2);
				drawMirrowObjs('diamonds', 24, settings.width - 24, 58, false, false, false,1,-1 );
				drawMirrowObjs('storageWoodenDec', 5, settings.width - 5, settings.height - 65);
				if (mode != FURRY_FREE) 
				{
					shopBusyFurry();
				}
				
				drawItems();
				
				
				drawTitleLabel();
				
				if (mode == COLLECTOR)
					drawHelpButton();
				drawButtons();
				return;
			}
			
			if(mode == RESOURCE || mode == GOLDEN_FURRY)
			{	
				var countContainer:Sprite = new Sprite();
				var capacityContainer:Sprite = new Sprite();
				background2 = Window.backing(175, 170, 30, "storageDarkBackingSlim");
				background2.x = (settings.width/2 - background2.width / 2) + 50;
				background2.y = (settings.height/2 - background2.height / 2) - 30;
				layer.addChild(background2);
				
				//var diamond1:Bitmap = new Bitmap(Window.textures.diamonds);
				//var diamond2:Bitmap = new Bitmap(Window.textures.diamonds);
				//var woodenDec1:Bitmap = new Bitmap(Window.textures.storageWoodenDec);
				//var woodenDec2:Bitmap = new Bitmap(Window.textures.storageWoodenDec);
				
				//diamond1.y = diamond2.y = 85;
				//diamond1.scaleY = diamond2.scaleY = -1;
				//diamond2.scaleX = -1;
				//diamond1.x = 74;
				//diamond2.x = settings.width - 24 + 50;
				
				//woodenDec1.y = woodenDec2.y = settings.height - 85;
				//woodenDec1.x = 55;
				//woodenDec2.scaleX = -1;
				//woodenDec2.x = settings.width - 5 + 50;
				
				//layer.addChild(diamond1);
				//layer.addChild(diamond2);
				//layer.addChild(woodenDec1);
				//layer.addChild(woodenDec2);
				
				//var workerFurry:Bitmap = new Bitmap(Window.textures.errorWork);
				//
				//
				//if (mode == GOLDEN_FURRY) 
				//{
					//Load.loading(Config.getIcon('Furkies', 'master'), function(data:Bitmap):void {
						//var workerFurryTwo:Bitmap = new Bitmap();;
						//workerFurry.bitmapData = data.bitmapData;
						//workerFurry.x =  workerFurry.width * 2  +15;
						//workerFurry.y =  45;
					//});
					//
					//Load.loading(Config.getIcon('Furkies', 'twoMasters'), function(data:Bitmap):void {
						//var workerFurryTwo:Bitmap = new Bitmap();
						//workerFurryTwo.bitmapData = data.bitmapData;
						//workerFurryTwo.x = -workerFurryTwo.width/2;
						//layer.addChild(workerFurryTwo);
					//});	
				//}else 
				//{
						//workerFurry.x = - workerFurry.width/3;
				//
				//
				//
				//}
				//
				//layer.addChild(workerFurry);
				
			
				
				drawItems();
				var bg:Shape = new Shape();
				bg.graphics.beginFill(0xbc8e41);
				bg.graphics.drawCircle(0, 0, 18);
				
				var bg2:Shape = new Shape();
				bg2.graphics.beginFill(0xefd099);
				bg2.graphics.drawCircle(0, 0, 15);
				
				var bg3:Shape = new Shape();
				bg3.graphics.beginFill(0xbc8e41);
				bg3.graphics.drawCircle(0, 0, 19);
				
				var bg4:Shape = new Shape();
				bg4.graphics.beginFill(0xefd099);
				bg4.graphics.drawCircle(0, 0, 16);
					
				countContainer.addChild(bg);
				countContainer.addChild(bg2);
				
				capacityContainer.addChild(bg3);
				capacityContainer.addChild(bg4);
				
				itemCount = settings.capacity;
				capacity = 1;
				countCalc = Window.drawText(String(capacity) , {
					color		:0xfeffff,
					borderColor	:0x572c26,
					fontSize	:24,
					textAlign	:"center"
				});
				countCalc.x = -1;
				countCalc.y = -3;
				
				itemCapacityTf = Window.drawText(String(itemCount - capacity) , {
					color		:0xfeffff,
					borderColor	:0x572c26,
					fontSize	:22,
					textAlign	:"center"
				});
				itemCapacityTf.x = -50;
				itemCapacityTf.y = -12;
				
				priceCount = capacity * settings.target.info.require[neededResourse];
				priceCalc = Window.drawText(String(priceCount) , {
					color		:0xffdb65,
					borderColor	:0x775002,
					fontSize	:34,
					textAlign	:"center"
				});
				priceCalc.x = 15
				priceCalc.y = 65
				
				
				var counterButtonSettings:Object = { 
					bgColor			:[0xffe3af, 0xffb468],
					bevelColor		:[0xffeee0, 0xc0804e],
					borderColor		:[0xc3b197, 0xcab89f],
					width			:28,
					height			:26,
					fontSize		:18,
					fontColor		:0xffffff,
					fontBorderColor	:0xa05d36,
					shadow			:true,
					radius			:10,
					shadowColor		:0xa05d36,
					shadowSize		:3
				};
				
				counterButtonSettings["caption"] = "-";
				minusBttn = new Button(counterButtonSettings);
				minusBttn.x = 0;
				bg.x = minusBttn.x + minusBttn.width + 20;
				bg.y = 10;
				bg2.x = bg.x;
				bg2.y = bg.y;
				
				counterButtonSettings["caption"] = "+";
				plusBttn = new Button(counterButtonSettings);
				plusBttn.x = bg.x + 20;
				
				counterButtonSettings["caption"] = "-10";
				counterButtonSettings["width"] = "38";
				minusBttn10 = new Button(counterButtonSettings);
				minusBttn10.x = 100 + 50;
				minusBttn10.y = 194;
				
				counterButtonSettings["caption"] = "+10";
				plusBttn10 = new Button(counterButtonSettings);
				plusBttn10.x = 236 + 50;
				plusBttn10.y = 194;
				
				//var iconBack:Bitmap = new Bitmap(Window.textures.hutNektarBack);
				//iconBack.x = (settings.width - iconBack.width) / 2 + 50;
				//iconBack.y = (settings.width - iconBack.width) / 2 + 130;
				//layer.addChild(iconBack);
				
				icon = new MaterialIcon(App.user.pet.sid, false, 0, 60);
				
				//Load.loading(Config.getIcon(App.data.storage[neededResourse].type, App.data.storage[neededResourse].preview), onIconComplete);
				
				//icon.scaleX = icon.scaleY = 0.9;
				//icon.smoothing = true;
				icon.x = ((settings.width - 70)  * 0.5) + 70;
				icon.y = ((settings.width - 70) * 0.5) + 133;
				layer.addChild(icon);
				
				if (mode == GOLDEN_FURRY)
				{
					//iconBack.visible = false;
					//icon.visible = false;
				}
				
				minusBttn.state = Button.DISABLED;
				minusBttn10.state = Button.DISABLED;
				plusBttn.addEventListener(MouseEvent.CLICK, onPlusEvent);
				plusBttn10.addEventListener(MouseEvent.CLICK, onPlus10Event);
				minusBttn.addEventListener(MouseEvent.CLICK, onMinusEvent);
				minusBttn10.addEventListener(MouseEvent.CLICK, onMinus10Event);
				
				countContainer.addChild(plusBttn);
				countContainer.addChild(minusBttn);
				layer.addChild(plusBttn10);
				layer.addChild(minusBttn10);
				countContainer.addChild(countCalc);
				countContainer.addChild(priceCalc);
				
				if (free) 
				{
					priceCalc.visible = false
				}
				
				capacityContainer.addChild(itemCapacityTf);
				
				layer.addChild(countContainer);
				layer.addChild(capacityContainer);
				
				countContainer.x = (background2.width + countContainer.width) / 2 - 10 + 50;
				countContainer.y = background2.y + (background2.height + countContainer.height) / 2 - 20;
				
				capacityContainer.x = background2.x + background2.width;
				capacityContainer.y = background2.y + 10;
				
				
				drawTitleLabel();
				drawButtons();
				refreshBttns();
				return;
			}
		}
		
		//private function onIconComplete(data:Bitmap):void 
		//{
			//icon.bitmapData = data.bitmapData;
			//icon.smoothing = true;
			//icon.width = 40;
			//
			//icon.scaleY = icon.scaleX ;				
		//}
		
		private function drawHelpButton():void
		{
			var icon:Bitmap = new Bitmap(UserInterface.textures.energyIcon);	
			bttnHelp = new IconButton(Window.textures.helpButton, {caption:''});
			bttnHelp.x = 80;
			bttnHelp.y = 40;
			bodyContainer.addChild(bttnHelp);
			
			bttnHelp.addEventListener(MouseEvent.CLICK, onHelp);
		}
		
		private function onHelp(e:MouseEvent):void 
		{
			new ConciergeHelpWindow({title:Locale.__e('flash:1410429947661')}).show();
		}
		
		private function onMinus10Event(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (capacity - 10 <= 0)
			{
				capacity = 1;
			}else
				capacity -= 10;
			
			plusBttn.state = Button.NORMAL;
			plusBttn10.state = Button.NORMAL;
				
			priceCount = int(capacity * settings.target.info.require[neededResourse]);
			priceCalc.text = String(priceCount);
			countCalc.text = String(capacity);
			itemCapacityTf.text = String(itemCount - capacity);
			timeNeed = capacity * settings.target.info.time;  
			collectBttn.count = TimeConverter.timeToCuts(timeNeed, true, true);
			collectBttn.topLayer.x = (collectBttn.bottomLayer.width - collectBttn.topLayer.width) / 2 - 30;
			
			refreshBttns();
		}
		
		private function onPlus10Event(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (capacity + 10 >= itemCount)
			{
				capacity = itemCount;
			}else
				capacity += 10;
			
			minusBttn.state = Button.NORMAL;
			minusBttn10.state = Button.NORMAL;
			
			priceCount = int(capacity * settings.target.info.require[neededResourse]);
			priceCalc.text = String(priceCount);
			countCalc.text = String(capacity);
			itemCapacityTf.text = String(itemCount - capacity);
			timeNeed = capacity * settings.target.info.time;  
			collectBttn.count = TimeConverter.timeToCuts(timeNeed, true, true);
			collectBttn.topLayer.x = (collectBttn.bottomLayer.width - collectBttn.topLayer.width) / 2 - 30;
			
			
			refreshBttns();
		}
		
		
		public var capacity:int = 0;
		private function onMinusEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			capacity --;
			
			priceCount = int(capacity * settings.target.info.require[neededResourse]);
			priceCalc.text = String(priceCount);
			countCalc.text = String(capacity);
			itemCapacityTf.text = String(itemCount - capacity);
			timeNeed = capacity * settings.target.info.time;  
			collectBttn.count = TimeConverter.timeToCuts(timeNeed, true, true);
			collectBttn.topLayer.x = (collectBttn.bottomLayer.width - collectBttn.topLayer.width) / 2 - 30;
			
			refreshBttns();
		}
		
		private function onPlusEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			capacity ++
			
			priceCount = int(capacity * settings.target.info.require[neededResourse]);
			
			priceCalc.text = String(priceCount);
			countCalc.text = String(capacity);	
			itemCapacityTf.text = String(itemCount - capacity);
			timeNeed = capacity * settings.target.info.time;  
			collectBttn.count = TimeConverter.timeToCuts(timeNeed, true, true);
			collectBttn.topLayer.x = (collectBttn.bottomLayer.width - collectBttn.topLayer.width) / 2 - 30;
			
			refreshBttns();
		}
		
		public function refreshBttns():void 
		{
			plusBttn.state = Button.NORMAL
			plusBttn10.state = Button.NORMAL;
			minusBttn.state = Button.NORMAL
			minusBttn10.state = Button.NORMAL;
			
			if (capacity >= itemCount) {
				plusBttn.state = Button.DISABLED;
				plusBttn10.state = Button.DISABLED;
			}
			
			if (capacity <= 1) {
				minusBttn.state = Button.DISABLED;
				minusBttn10.state = Button.DISABLED;
			}
		}
		
		public function drawItems():void
		{	
			bitmap = new Bitmap();
			if (mode == COWBOW) {
				bitmap.bitmapData = settings.target.bitmap.bitmapData;
				bitmap.smoothing = true;
				bitmap.scaleX = bitmap.scaleY = 1;
				bitmap.x = (settings.width - bitmap.width) / 2;
				bitmap.y = 130 - bitmap.height / 2;
				bodyContainer.addChild(bitmap);
			}
			if (mode == FURRY || mode == COLLECTOR || mode == FURRY_FREE || mode == FURRY_GARDENER)
			{	
				bitmap.bitmapData = settings.target.bitmap.bitmapData;
				bitmap.smoothing = true;
				if (settings.info.sID == 164) 
				{
					bitmap.scaleX = bitmap.scaleY = 1.2;
				}else {
					bitmap.scaleX = bitmap.scaleY = 0.7;
				}
				bitmap.x = (settings.width - bitmap.width) / 2;
				bitmap.y = 130 - bitmap.height / 2;
				bodyContainer.addChild(bitmap);
			}
			
			
			if (mode == RESOURCE || mode == GOLDEN_FURRY)
			{
				//bitmap.bitmapData = settings.target.icon.bitmapData;
				//bitmap.smoothing = true;
				//
				//if (bitmap.height > 140)
					//bitmap.scaleX = bitmap.scaleY = 0.8;
				//
				//bitmap.x = background2.x + (background2.width - bitmap.width) / 2;
				//bitmap.y = background2.y + (background2.height - bitmap.height) / 2 - 10;
				//
				//layer.addChild(bitmap);
			}
		}
		
		private function drawButtons():void 
		{
			if (collectBttn != null)
			{
				bodyContainer.removeChild(collectBttn);
			}
			var timer:Bitmap = new Bitmap(Window.textures.itemBacking, "auto", true);
			
			var bttnTxt:String = Locale.__e("flash:1403870467181");
			
			if (mode == COLLECTOR || mode == COWBOW || mode == FURRY_GARDENER)
				bttnTxt = "";
			
			collectBttnObj = {
				title			:Locale.__e("flash:1403870467181"),
				width			:240,
				height			:53,	
				fontSize		:26,
				radius			:20,
				countText		:TimeConverter.timeToCuts(timeNeed, true, true),
				multiline		:true,
				hasDotes		:false,
				hasText2		:true,
				fontCountSize	:26,
				fontCountColor	:0xffffff,
				fontCountBorder :0x814f31,
				textAlign		: "left",	
				bgColor			:[0xf5d058, 0xeeb331],
				bevelColor		:[0xfeee7b, 0xbf7e1a],
				fontBorderColor :0x814f31,
				iconScale		:1,
				iconFilter		:0x814f31
			};
			
			var bttnX:int;
			var bttnY:int;

			if (mode == FURRY || mode == COLLECTOR || mode == COWBOW || mode == FURRY_FREE || mode == FURRY_GARDENER)
			{	
				if (mode == COLLECTOR || mode == COWBOW || mode == FURRY_GARDENER)
					collectBttnObj['title'] = settings.bttnText;
				bttnX = 63;
				bttnY = 300;
			}
			if (mode == RESOURCE || mode == GOLDEN_FURRY)
			{	
				collectBttnObj.title = Locale.__e('flash:1403882956073');
				timeNeed = capacity * settings.target.info.time;  
				collectBttnObj.countText = TimeConverter.timeToCuts(timeNeed, true, true);
				bttnX = 113;
				bttnY = 283;
			}
			
			collectBttn = new MixedButton2(timer, collectBttnObj);
			collectBttn.textLabel.x = (collectBttn.settings.width - collectBttn.textLabel.width) / 2;
			
			if (mode == RESOURCE || mode == GOLDEN_FURRY)
			{	
				if (collectBttn.countLabel.textWidth <= 50)
				{
					collectBttn.textLabel.x = 35;
				} else collectBttn.textLabel.x = 10;
				
				collectBttn.textLabel.x = 25;
				collectBttn.coinsIcon.x = collectBttn.textLabel.x + collectBttn.textLabel.textWidth + 10;
				collectBttn.countLabel.x = collectBttn.coinsIcon.x + collectBttn.coinsIcon.width + 3;
				collectBttn.countLabel.y = collectBttn.textLabel.y + 1;
				collectBttn.countLabel.textWidth;
			}
			
			collectBttn.addEventListener(MouseEvent.CLICK, onCollect);
			collectBttn.x = bttnX;
			collectBttn.y = bttnY;
			
			bodyContainer.addChild(collectBttn);
		}
		
		private function showAnyTargets(possibleSIDs:Array = null):void {
			if (!possibleSIDs) possibleSIDs = [];
			
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:* in possibleTargets)
			{
				if (res.hasProduct || res.producting) continue;
				res.state = res.HIGHLIGHTED;
				res.canAddWorker = true;
			}
		}
		
		private function showMoneyTargets():void
		{
			var possibleSIDs:Array = [];
			for (var id:* in App.data.storage) {
				if (App.data.storage[id].type == "Moneyhouse") {
					possibleSIDs.push(id);
				}
			}
			var hutTargets:Object = { };
			for each(var sID:* in hutTargets)	possibleSIDs.push(sID);
			
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:Moneyhouse in possibleTargets)
			{
				if (res.busy == 1 || res.hasProduct || res.colector) continue;
				res.state = res.HIGHLIGHTED;
				res.canCollector = true;
				//Moneyhouse.waitForTarget = true;
			}
		}
		
		private function showAnimalTargets():void 
		{
			var possibleSIDs:Array = [];
			for (var id:* in App.data.storage) {
				if (App.data.storage[id].type == "Animal") {
					possibleSIDs.push(id);
				}
			}
			var hutTargets:Object = { };
			for each(var sID:* in hutTargets)	possibleSIDs.push(sID);
			
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:Animal in possibleTargets)
			{
				if (res.cowboy) continue;
				res.state = res.HIGHLIGHTED;
				res.canAddCowboy = true;
			}
		}
		
		private function showResTargets(techno:Goldentechno = null):void
		{
			var possibleSIDs:Array = [];
			if (techno != null) 
			{
				for (var itm:* in techno.info.targets) 
				{
					
					possibleSIDs[itm] = techno.info.targets[itm];
				}
			}
			else
			{
				for (var id:* in App.data.storage) 
				{
					if (App.data.storage[id].type == "Resource") 
					{
						possibleSIDs.push(id);
					}
				}
				var hutTargets:Object = { };
				for each(var sID:* in hutTargets)	possibleSIDs.push(sID);
			}
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:Resource in possibleTargets)
			{
				if (res.busy == 1 || res.isTarget) continue;
				res.state = res.HIGHLIGHTED;
			}
			/*setTimeout(function():void {
				App.self.addEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			}, 100);*/
		}
		
		private function unselectPossibleTargets(e:MouseEvent):void
		{
			if (App.self.moveCounter > 3)
				return;
			
			if (mode == FURRY_GARDENER) {
				if (Gardener.waitForTarget) {
					return;
				}
			}
			
			App.self.removeEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			
			if (mode == COLLECTOR) {
				Moneyhouse.waitForTarget = false;
			}else if (mode == COWBOW) { 
				Animal.waitForTarget = false;
			}else if (mode == FURRY) {
				Factory.waitForTarget = false;
			}else if (mode == FURRY_GARDENER) {
				Gardener.waitForTarget = false;
			}
			
			for each(var res:* in possibleTargets)
			{
				res.state = res.DEFAULT;
				if (res.hasOwnProperty('canAddCowboy')) {
					res.canAddCowboy = false;
				}
				if(res.hasOwnProperty('canCollector'))	{
					res.canCollector = false;
				}
				if (res.hasOwnProperty('canAddWorker')) {
					res.canAddWorker = false;
				}
			}
		}
		
		private function onCollect(e:MouseEvent):void 
		{
			//close();
			//var workers:Array
			//if (mode == GOLDEN_FURRY) 
			//{
				 //workers = Goldentechno.freeTechno(settings.target.sid);
			//}
			//else 
			//{
				 //workers = Techno.freeTechno();
			//}
			//
			//if (mode != COWBOW &&mode != FURRY_FREE && (workers == null || workers.length == 0)){
				//App.ui.upPanel.onWorkersEvent();
				//return;
			//}
			//
			//if (mode != COLLECTOR && mode != COWBOW && mode != GOLDEN_FURRY && mode != FURRY && mode != FURRY_FREE && mode != FURRY_GARDENER) 
			//{
				//if (!App.user.stock.take(neededResourse, priceCount))
				//return;
			//}
			
			
			//if (mode == FURRY) {
				//showResTargets();
				//showTargets();
			//}else if (mode == COLLECTOR) { 
				//showMoneyTargets();
				//showTargets();
			//}else if (mode == COWBOW) { 
				//showAnimalTargets();
				//showTargets();
			//}else if (mode == GOLDEN_FURRY) {
				//var workerGold:Goldentechno = workers[0];
				////showResTargets(workerGold);
				//workerGold.autoEvent(settings.target, capacity);
			//}else if (mode == FURRY_FREE) {
				//showResTargets(settings.target);
				//showTargets();
			//}else if (mode == FURRY_GARDENER) {
				//if (settings.target.workStatus == 1) // BUSY
				//{
					//settings.target.unbindAction();
				//}else{
					//showAnyTargets(settings.possibleTargets);
					//showTargets();
				//}
			//}else{
				//var worker:Techno = workers[0];
				//worker.autoEvent(settings.target, capacity);
			//}
			
			App.user.pet.autoEvent(settings.target, capacity);
			close();
		}
		
		
		private var possibleTargets:Array = [];
		private var itemCount:int;
		private var countCalc:TextField;
		private var priceCalc:TextField;
		private var priceCount:int;
		private var timeNeed:int;
		private var collectBttnObj:Object;
		private var itemCapacityTf:TextField;
		private var bttnHelp:IconButton;
		
		private function showTargets():void
		{
			var txt:String;
			var widthBg:int = 250;
			
			if (mode == FURRY_GARDENER) {
				Gardener.waitWorker = settings.target;
				Gardener.chooseTargets = [];
				Gardener.clickCounter = 0;
				Gardener.waitForTarget = true;
				//App.ui.upPanel.showCancel(settings.target.onCancel);
				txt = Locale.__e('flash:1416306272834');
			}else if (mode == COLLECTOR) {
				Moneyhouse.waitForTarget = true;
				Moneyhouse.collector = settings.target;
				txt = Locale.__e('flash:1409127749657');
				widthBg = 350;
			}else if (mode == COWBOW) {
				Animal.waitForTarget = true;
				Cowboy.cowboy = settings.target;
				//Moneyhouse.collector = settings.target;
				txt = Locale.__e('flash:1409568558009');
			}else if (mode == FURRY || mode == FURRY_FREE) {
				Factory.waitForTarget = true;
				txt = Locale.__e("flash:1403870467181");
			}
			//App.ui.upPanel.showHelp(Locale.__e(txt), widthBg);
			
			setTimeout(function():void {
				App.self.addEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			}, 100);
		}
		
		private function shopBusyFurry():void
		{
			textSettings = {
				color:0xFFFFFF,
				borderColor:0x4b2e1a,
				fontSize:32,
				textAlign:"center"
			};
			
			var icon:BitmapData;
			var countTxt:String;
			
			if (mode == COWBOW) {
				countTxt = Cowboy.getBusyCowboys() + "/" + App.user.cowboys.length;
				icon = Window.textures.shepherdIco;
			}else {
				countTxt = Techno.getBusyTechno() + "/" + App.user.techno.length
				icon = UserInterface.textures.iconWorker;
			}
			
			robotIcon = new Bitmap(icon);
			robotIcon.x = settings.width/2 - 50;
			robotIcon.y = settings.height/2 + 85;
			if (mode == COWBOW) {
				robotIcon.scaleX = robotIcon.scaleY = 0.85;
				robotIcon.smoothing = true;
				robotIcon.x -= 5;
			}
			robotCounter = Window.drawText("-/-", textSettings);
			robotCounter.text 	=  countTxt;
			
			layer.addChild(robotIcon);
			layer.addChild(robotCounter);
			
			robotCounter.x = robotIcon.x + robotIcon.width - 20;
			robotCounter.y = robotIcon.y + 7;
		}
		
		override public function drawExit():void 
		{
			super.drawExit();
			
			exit.x = settings.width - exit.width;
			exit.y = 0;

			if (mode == RESOURCE || mode == GOLDEN_FURRY)
			{	
				exit.x += 50;
			}
		}
		
		
		//public function clearWindow():void
		//{
			//collectBttn.removeEventListener(MouseEvent.CLICK, onCollect);
			//layer.removeChild(background2);
			//layer.removeChild(robotIcon);
			//layer.removeChild(robotCounter);
			//bodyContainer.removeChild(separator);
			//bodyContainer.removeChild(separator2);
			//bodyContainer.removeChild(bitmap);
			//bodyContainer.removeChild(collectBttn);
		//}
		
		
		override public function dispose():void
		{
			if (bttnHelp)
			{
				bttnHelp.removeEventListener(MouseEvent.CLICK, onHelp);
				bttnHelp.dispose();
				bttnHelp = null;
			}
			super.dispose();
		}
	}

}