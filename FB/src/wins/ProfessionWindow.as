package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MixedButton;
	import buttons.MoneyButton;
	import buttons.UpgradeButton;
	import com.greensock.easing.Back;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	import core.Post;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import ui.BoostTool;
	import wins.elements.ProductionQueue;
	TweenPlugin.activate([TransformAroundPointPlugin]);
	import core.Load;
	import flash.geom.Point;
	import ui.Hints;
	import wins.elements.ProductionItem;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class ProfessionWindow extends BuildingWindow
	{
		public static var find:*;
		
		protected var topBg:Bitmap = null;
		protected var bottomBg:Bitmap = null;
		protected var subTitle:TextField = null;
		public var items:Array = new Array();
		protected var partList:Array = new Array();
		protected var outItem:MaterialItem = null;
		protected var currentItem:ProductionItem = null;
		private var shine:Bitmap;
		protected var cookBttn:Button = null;
		protected var cookingTitle:TextField = null;
		protected var cookingBar:ProgressBar;
		protected var productIcon:Sprite;
		public var itemContainer:Sprite = new Sprite();
		public var crafted:uint;
		public var totalTime:uint;
		public var progressBacking:Bitmap;
		public var craftData:Array = [];
		private var proffCraft:Array = [27, 28, 29, 30];
		public var busy:Boolean = false;
		public var dY:int = 30;
		private static var itemsInQueue:int = 5;
		
		protected var accelerateBttn:MoneyButton = null;
		protected var upgradeBttn:UpgradeButton = null;
		protected var boostBttn:MoneyButton = null;
		protected var neddLvlBttn:UpgradeButton = null;
		
		public static var history:int = 0;
		private var _arrCraft:Array = [];
		
		private var priceSpeed:int = 0;
		private var priceBttn:int = 0;
		private var isStart:Boolean = true;
		
		private var endLevelCont:Sprite = new Sprite();
		private var bttn:ImageButton;
		
		private var canUpgrade:Boolean = false;
		
		private var level:int;
		
		public var rotationRightAngle:Number = 28;
		public var rotationLeftAngle:Number = -28;
		public var rotationAngle:Number = -28;
		public function ProfessionWindow(settings:Object = null)
		{
			settings['width'] = settings.width || 620;
			settings['height'] = settings.height || 616;
			settings['hasArrows'] = true;
			settings['itemsOnPage'] = 6;
			settings['faderAlpha'] = 0.6;
			settings['page'] = history;
			settings['hasButtons'] = false;
			settings['hasAnimations'] = false;
			settings['hasTitle'] = false;
			
			canUpgrade = settings.canUpgrade || false;

		
			settings.crafting = [];
			
			/*if (Quests.help && index > 0) {
				settings.page = int(index / settings.itemsOnPage);
			}*/
			
			//crafted = settings.target.crafted;
			//totalTime = App.data.crafting[fID].time;
			
			initContent(settings);
			super(settings);
		}
		
		private function findTarget():void {
			if (!settings.find) return;
			
			for (var i:int = 0; i < _arrCraft.length; i++ ) {
				if (App.data.crafting[_arrCraft[i].fid].out == settings.find) {
					if (i >= settings.itemsOnPage) {
						var count:int = Math.ceil((i - 5) / 2);
						for (var k:int = 0; k < count; k++ ) {
							makeScrolling(1);
						}
						arrowLeftBttn.mouseEnabled = true;
						arrowLeftBttn.alpha = 1;
						settings.find = 0;
					}
					break;
				}
			}
		}
		
		private var updtItems:Array = [];
		public function initContent(settings:Object):void {
			var lvlRec:int = 0;
			updtItems = Stock.notAvailableItems();
			
			//if (settings.target.info.hasOwnProperty('devel') ) {
				for (var _id:String in proffCraft) {
					var obj:Object = proffCraft[_id];
					lvlRec = 0/*int(_id) - *//*(settings.target.totalLevels - settings.target.craftLevels)*/;
					
					var counter:int = 0;
					/*for each(var fID:* in obj) {
						
						if (!App.data.crafting[fID] || updtItems.indexOf(App.data.crafting[fID].out) != -1) {
							continue;
						}
						_arrCraft.push( { fid:fID, lvl:lvlRec, order:counter } );
						settings.crafting.push(fID);
						counter++;
					}*/
					//for each(var fID:* in obj) {
						
						/*if (!App.data.crafting[fID] || updtItems.indexOf(App.data.crafting[fID].out) != -1) {
							continue;
						}*/
						_arrCraft.push( { fid:obj, lvl:2, order:counter } );
						settings.crafting.push(obj);
						counter++;
					//}
				}
			//}
			
			_arrCraft.sortOn(['lvl', 'order'], Array.NUMERIC);
			
			//level1 = settings.target.level /*- (settings.target.totalLevels -  settings.target.craftLevels)*/;
			craftData = _arrCraft;
		}
		
		
		override public function drawBackground():void { }
		
		override public function drawExit():void {
			super.drawExit();
		}
		
		private var counter:int;
		override public function drawBody():void {
			
			topBg = Window.backing(570, 440, 40, "shopBackingSmall");
			topBg.x = (settings.width - topBg.width) / 2;
			topBg.y = 40;
			
			var iconCont:LayerX = new LayerX();
			
			var b:BitmapData = Zone.snapClip(settings.target.bitmapContainer);
			var iconBuilding:Bitmap = new Bitmap(b);
			
			//var iconBuilding:Bitmap = new Bitmap(settings.target.bitmap.bitmapData);
			iconBuilding.smoothing = true;
			
			if (settings.target.scaleX == -1) {
				iconBuilding.scaleX = -1;
				iconBuilding.x += iconBuilding.width;
			}
			
			shine = new Bitmap(Window.textures.productionReadyBacking);
			shine.scaleX = shine.scaleY = 3;
			bodyContainer.addChild(shine);
			shine.x = (settings.width - shine.width) / 2;
			shine.y = (settings.height - shine.height) / 2;
			iconCont.addChild(iconBuilding);
			bodyContainer.addChild(iconCont);
			
			//iconCont.x = (settings.width - iconCont.width) / 2;
			//iconCont.y = (settings.height - iconCont.height) / 2;
			
			iconCont.x = shine.x + (shine.width - iconCont.width)/2;
			iconCont.y = shine.y + (shine.height - iconCont.height)/2;;
			iconCont.pluck(60, iconCont.x + iconCont.width/2, iconCont.y + iconCont.height/* / 2 + 300*/);
	
			levelTxt = Window.drawText(Locale.__e("flash:1409651648482", [level]), {
				fontSize:30,
				color:0xffffff,
				textAlign:"center",
				borderColor:0x603508
			});
			levelTxt.x = (settings.width - levelTxt.width) / 2 + 3;
			levelTxt.y = 440;
			
			titleTxt = Window.drawText(settings.title, {
				fontSize:30,
				color:0xffffff,
				textAlign:"center",
				borderColor:0x603508,
				width:200
			});
			bodyContainer.addChild(titleTxt);
			titleTxt.x = (settings.width - titleTxt.width) / 2 + 3;
			titleTxt.y = 160;
			
			var mymask:Sprite = new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(1075,400);
			mymask.graphics.lineStyle();
			mymask.graphics.beginGradientFill(GradientType.RADIAL,[0xFFFFFF,0xFFFFFF],[1,0],[235,255],matrix);
			mymask.graphics.drawRect(0,0,1075,400);
			mymask.graphics.endFill();
			bodyContainer.addChild(mymask);
			
			mymask.x = (settings.width - mymask.width) / 2;
			mymask.y = (settings.height - mymask.height) / 2 - 120;
		
			
			bodyContainer.addChild(itemContainer);
			itemContainer.mask = mymask;
			
			itemContainer.cacheAsBitmap = true;
			mymask.cacheAsBitmap = true;
			
			setTimeout(createItems, 400);
			
			paginator.itemsCount = 0;
			
			
			craftData = _arrCraft;
			
			paginator.itemsCount = _arrCraft.length; 
			paginator.page = settings.page;
			paginator.update();
			paginator.y -= 82;
			
			
			
			var isBttn:Boolean = false;
			/*for each(var _sid:* in settings.target.info.devel[1].craft) {
				if (updtItems.indexOf(App.data.crafting[_sid].out) == -1) { //проверка соответствия уровня здания уровню крафта
					//isBttn = true;
					break;
				}
			}*/
			/*if (settings.target.level < App.data.storage[settings.target.sid].devel)
				isBttn = true;*/
			
			if (isBttn)
				drawButton();
			
			if (settings.target.level >= settings.target.totalLevels || !isBttn) {
				drawForMaxLevel();
			}
			
			for (var i:* in settings.target.queue) {
				counter++;
			}	
			
			if (settings.target.crafting || counter > 0)
			{
				//drawQueue(true);
			}		
			
			showProgressBar();
			
		}
		
		/*public function drawQueue($value:Boolean):void
		{  
			if (productionQueue != null){
				bodyContainer.removeChild(productionQueue);
				productionQueue = null;
				
			}
			var items:Object = settings.target.queue;
			
			productionQueue = new ProductionQueue(items, settings, this);
			bodyContainer.addChild(productionQueue);
			productionQueue.visible = $value;
			productionQueue.x = (settings.width - productionQueue.width/2) / 2 - 85;
			productionQueue.y = (settings.height*2 - productionQueue.height) / 2 - 80;
		}*/
		
		
		private var queueInfoText:TextField;
		public function addInfoBlock():void 
		{
			if (queueInfoText != null) return; 
			
			queueInfoText = Window.drawText(Locale.__e("flash:1406104440861"), {
				fontSize:34,
				color:0xe74113,
				borderColor:0xffffff,
				textAlign:"center"
			});
				queueInfoText.alpha = 0;
				//queueInfoText.height = queueInfoText.textHeight + 10;
				bodyContainer.addChild(queueInfoText);
				queueInfoText.width = cookingTitle.textWidth + 20;
				queueInfoText.height = cookingTitle.textHeight;
				queueInfoText.x = progressBacking.x + (progressBacking.width - cookingTitle.width) / 2;
				queueInfoText.y = progressBacking.y - 80;
				
			
			addText();	
		}
		
		private function addText():void 
		{
			if (queueInfoText != null) {
				TweenLite.to(queueInfoText, 0.2, {alpha:1, ease:Linear.easeNone});
				
			setTimeout(function():void {
					removeText();
				}, 1500);
				glowEnabled();
			}
			
			
			
		}
		
		private function removeText():void 
		{
			
			if (queueInfoText != null) {
				TweenLite.to(queueInfoText, 1, {alpha:0, ease:Linear.easeNone});
				
			setTimeout(function():void {
					bodyContainer.removeChild(queueInfoText);
					queueInfoText = null;
				}, 1000);
				hideEnabledGlow();
			}
			
			
		}
		
		private function drawForMaxLevel():void
		{			
			var doingNothing:TextField = Window.drawText(Locale.__e("flash:1393581854554"), {
				fontSize:30,
				color:0xffffff,
				borderColor:0x5c3500,
				textAlign:"center"
			});
			//endLevelCont.addChild(doingNothing);
			
			doingNothing.width = 330;
			doingNothing.height = doingNothing.textHeight;
			doingNothing.x = (settings.width - doingNothing.width) / 2;
			doingNothing.y = settings.height - doingNothing.textHeight - 115;
			
			bodyContainer.addChild(endLevelCont);
		}
		
		private function drawButton():void 
		{
			upgradeBttn = new UpgradeButton(UpgradeButton.TYPE_ON,{
				caption: Locale.__e("flash:1396963489306"),
				width:236,
				height:55,
				icon:Window.textures.upgradeArrow,
				fontBorderColor:0x002932,
				countText:"",
				fontSize:28,
				iconScale:0.95,
				radius:30,
				textAlign:'left',
				autoSize:'left',
				widthButton:230
			});
			upgradeBttn.textLabel.x += 18;
			upgradeBttn.coinsIcon.x += 18;
			
			
			bodyContainer.addChild(upgradeBttn);
			
			upgradeBttn.x = (settings.width - upgradeBttn.width)/2 + 4;
			upgradeBttn.y = topBg.y + topBg.height - 10;
			
			upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgradeEvent);
			
			if (settings.target.helpTarget == settings.target.sid){
				upgradeBttn.showGlowing();
				//upgradeBttn.showPointing("bottom", 0, 0, upgradeBttn.parent);
			}
		}
		
		private function drawNeddLvlBttn():void 
		{
			neddLvlBttn = new UpgradeButton(UpgradeButton.TYPE_OFF,{
				caption: Locale.__e("flash:1393579961766"),
				width:236,
				height:55,
				icon:Window.textures.star,
				countText:String(settings.target.info.devel.req[settings.target.level + 1].l),
				fontSize:24,
				iconScale:0.95,
				radius:20,
				bgColor:[0xe4e4e4, 0x9f9f9f],
				bevelColor:[0xfdfdfd, 0x777777],
				fontColor:0xffffff,
				fontBorderColor:0x575757,
				fontCountColor:0xffffff,
				fontCountBorder:0x575757,
				fontCountSize:24,
				fontBorderCountSize:4
			})
			
			bodyContainer.addChild(neddLvlBttn);
			neddLvlBttn.x = (settings.width - neddLvlBttn.width)/2;
			neddLvlBttn.y = settings.height - neddLvlBttn.height - 64;
		}
		
		private function onUpgradeEvent(e:MouseEvent):void 
		{
			new ConstructWindow( {
				title:settings.target.info.title,
				upgTime:settings.upgTime,
				request:settings.target.info.instance.devel[1].obj[settings.target.level + 1],
				target:settings.target,
				win:this,
				onUpgrade:onUpgradeAction,
				hasDescription:true
			}).show();
		}
		
		private function onUpgradeAction(obj:Object = null, $fast:int = 0):void
		{
			if ($fast > 0)
			{
				settings.target.upgradeEvent(settings.request, $fast);
			}else
				settings.target.upgradeEvent(settings.target.info.devel.obj[settings.target.level + 1]);
			close();
		}
		
		private function progressVisible(value:Boolean):void
		{
			progressBacking.visible = value;
			if(cookingTitle != null)
				cookingTitle.visible = value;
			cookingBar.visible = value;
		}
		
		public var bitmapIcon:Bitmap = null;
		public var sprTip:LayerX = new LayerX();
		private var preloader:Preloader = new Preloader();
		
		public function showProgressBar():void
		{
			progressBacking = Window.backingShort(340, "prograssBarBacking3");
			progressBacking.x = (settings.width - progressBacking.width) / 2 - 5;
			progressBacking.y = topBg.y + topBg.height - 55;
			bodyContainer.addChild(progressBacking);
			
			//Создаем пустой прогресс бар
			if (settings.target.fID > 0) {
				cookingTitle = Window.drawText(Locale.__e("flash:1409663511254", [App.data.storage[App.data.crafting[settings.target.fID].out].title]), {
				fontSize:28,
				color:0xfbf4e4,
				borderColor:0x5c3400,
				textAlign:"center"
				});
			bodyContainer.addChild(cookingTitle);
			cookingTitle.width = cookingTitle.textWidth + 20;
			cookingTitle.height = cookingTitle.textHeight;
			cookingTitle.x = progressBacking.x + (progressBacking.width - cookingTitle.width) / 2;
			cookingTitle.y = progressBacking.y - 35;
			}
			
			
			var barWidth:int = 320;
			cookingBar = new ProgressBar({win:this, width:barWidth, scale:0.7,timerX:12,timerY:2});
			bodyContainer.addChild(cookingBar);
			cookingBar.x = (settings.width - barWidth)/2 - 2 - 22;
			cookingBar.y = progressBacking.y + (progressBacking.height - cookingBar.height) / 2 - 7;
			
			if (settings.target.crafted > App.time) {
				startProgress(settings.target.fID);
				levelTxt.visible = false;
			}
			else {
				progressVisible(false);
				
			}
			
		}
		override public function drawFader():void {
			if (fader==null && settings.hasFader) {
				fader = new Sprite();
					
				fader.graphics.beginFill(settings.faderColor);
				fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
				fader.graphics.endFill();
				
				addChildAt(fader, 0);
					
				fader.alpha = 0;
				
				var finishX:Number = (App.self.stage.stageWidth - settings.width) / 2;
				var finishY:Number = (App.self.stage.stageHeight - settings.height) / 2;
					
				TweenLite.to(fader, settings.faderTime, { alpha:settings.faderAlpha } );
			}
		}
		override public function show():void
		{
			super.show();
			//App.map.focusedOn(settings.target, false, function():void 
			//{
				//settings.target.pluck(10, settings.target.x, settings.target.y - settings.target.bitmap.x);
			//}, true, 1, true, 0.5);
		}
		public function onPreviewComplete(obj:Object):void
		{
			if(bodyContainer.contains(preloader)){
				bodyContainer.removeChild(preloader);
			}
			bitmapIcon.bitmapData = obj.bitmapData;
			bitmapIcon.smoothing = true;
			if(bitmapIcon.height > 50)
				bitmapIcon.scaleX = bitmapIcon.scaleY = 0.8;
			sprTip.x = 40;
			sprTip.y = topBg.y + topBg.height + 4;
		}
		
		
		public function updateNumItems():void
		{
			//numItems.text = 'x' + String(settings.target.craftRow.length);
		}
		
		private var numItems:TextField;
		public function startProgress(fID:uint):void
		{
			totalTime = App.data.crafting[fID].time;
			if (isStart) crafted = settings.target.crafted;
			else crafted = App.time + totalTime;
			
			endLevelCont.visible = false;
			if(upgradeBttn)upgradeBttn.visible = false;
			
			boostBttn = new MoneyButton({
					caption		:Locale.__e('flash:1382952380104'),
					width		:102,
					height		:63,	
					fontSize	:24,
					countText	:15,
					multiline	:true,
					radius:20,
					iconScale:0.67,
					fontBorderColor:0x3559ad,
					fontCountBorder:0x3559ad,
					notChangePos:true
			});
			boostBttn.x = settings.width - boostBttn.width - 10;
			boostBttn.y = topBg.y + topBg.height - 65;
			boostBttn.textLabel.y -= 12;
			boostBttn.textLabel.x = 0;
			boostBttn.coinsIcon.y += 12;
			boostBttn.coinsIcon.x = 12;
			boostBttn.countLabel.y += 12;
			boostBttn.countLabel.x = boostBttn.coinsIcon.x + boostBttn.coinsIcon.width + 12;
			
			var txtWidth:int = boostBttn.textLabel.width;
			if ((boostBttn.coinsIcon.width + 6 + boostBttn.countLabel.width) > txtWidth) {
				txtWidth = boostBttn.coinsIcon.width + 6 + boostBttn.countLabel.width;
				boostBttn.textLabel.x = (txtWidth - boostBttn.textLabel.width) / 2;
			}
			
			
			
			boostBttn.topLayer.x = (boostBttn.settings.width - txtWidth)/2;
			
			priceSpeed = Math.ceil((crafted - App.time) / App.data.options['SpeedUpPrice']);
			boostBttn.count = String(priceSpeed);
			
			boostBttn.addEventListener(MouseEvent.CLICK, onAccelerateEvent);
			bodyContainer.addChild(boostBttn);
			
			productIcon = new Sprite();
			var bitmap:Bitmap = new Bitmap();
			productIcon.addChild(bitmap);
			bodyContainer.addChild(productIcon);
			productIcon.x = 74;
			productIcon.y = 500;
			
			if (App.data.quests.hasOwnProperty(App.user.quests.currentQID) && App.data.quests[App.user.quests.currentQID].missions!= null&&App.data.quests[App.user.quests.currentQID].missions.hasOwnProperty(App.user.quests.currentMID) && App.data.quests[App.user.quests.currentQID].missions[App.user.quests.currentMID].event == 'boost' && settings.find) {
				//boostBttn.count = '0';
				boostBttn.showGlowing();
				boostBttn.showPointing('top',0,-10,bodyContainer);
				//boostBttn.visible = false;
				setTimeout(boostBttn.hidePointing,3000)
			}
			
			Load.loading(
				Config.getIcon(App.data.storage[App.data.crafting[fID].out].type, App.data.storage[App.data.crafting[fID].out].preview),
				function(data:Bitmap):void{
					bitmap.bitmapData = data.bitmapData;
					bitmap.scaleX = bitmap.scaleY = 1;
					bitmap.smoothing = true;
					bitmap.x = -bitmap.width / 2 + 10;
					bitmap.y = -110;
				}
			);
			
			progress();
			cookingBar.start();
			
			if (canBoost) {
				var bt:BoostTool = new BoostTool(int(settings.target.sid), mBoost)
				bt.x = boostBttn.x + 110;
				bt.y = boostBttn.y + - bt.height*0.3;
				//bodyContainer.addChild(bt);
			}
			
			App.self.setOnTimer(progress);
			busy = true;
			
			
			if(neddLvlBttn) neddLvlBttn.visible = false;
		}
		
		public function onAccelerateEvent(e:MouseEvent):void {
			settings.target.onBoostEvent(priceBttn);
			
				Hints.minus(Stock.FANT, priceBttn, Window.localToGlobal(boostBttn), false, this);
			
			close();
		}
		
		
		public function drawClosedWindow():void
		{
			var winSettings:Object = {
						text				:Locale.__e('flash:1409659785281'),
						buttonText			:Locale.__e('flash:1382952380298'),
						image				:Window.textures.errorOops,
						imageX				: -78,
						imageY				: -76,
						textPaddingY        : -18,
						textPaddingX        : -10,
						hasExit             :true,
						faderAsClose        :true,
						faderClickable      :true,
						closeAfterOk        :true,
						isPopup             :true,
						bttnPaddingY        :25
					};
			
			new ErrorWindow(winSettings).show();
		}
		
		public function glowEnabled():void {
			for (var i:int = 0; i < items.length; i++) {
				items[i].startGlowing();
			} 
		}
		
		public function hideEnabledGlow():void
		{
			for (var i:int = 0; i < items.length; i++) 
			{
				items[i].hideGlowing();
			}
		}
		
		private var itemWidth:int = 170;
		private var itemHeight:int = 206;
		private var indItem:int = 0;
		public function createItems():void 
		{
			if (!_arrCraft)
				return;
		
			var angle:int;
			var time:Number = 0.4;
			if (!(_arrCraft.length <= settings.itemsOnPage))
				showPaginator();
			for (var i:int = 0; i < settings.itemsOnPage;  i++)
			{
				var item:ProductionItem = new ProductionItem(this, { height:itemHeight, width:itemWidth, crafting:_arrCraft[i], craftData:_arrCraft, level:level } );
				
				indItem++;
				
				var inner:Sprite = new Sprite();
				var cont:Sprite = new Sprite();
				
				inner.addChild(item);
				item.x = - item.width / 2;
				item.y = - item.height / 2;
				
				inner.rotation = -setPosScrollItems(i + 1);
				
				inner.x = 230;
				cont.addChild(inner);
				
				cont.rotation = 180;
				
				itemContainer.addChild(cont);
				items.push(item);
				
				//isScrolling = true;
				
				if (i == settings.itemsOnPage-1)
					setTimeout(function():void{isScrolling = false}, time);
				
				var indRot:int = i;
				TweenLite.to(cont, time, { rotation:setPosScrollItems(i + 1), alpha:1, ease:Back.easeOut } );
				
				time += 0.05;
				
				angle = 90 - settings.crafting.length * 15;
				if (settings.crafting.length <= 5) 
					inner.rotation -= angle;
			}
			
			itemContainer.x = settings.width / 2;
			itemContainer.y = settings.height / 2;
			
			angle = 90 - settings.crafting.length * 15;
			if (settings.crafting.length <= 5) 
				TweenLite.to(itemContainer, time, { rotation:angle, alpha:1, ease:Back.easeOut } );			
			
			if (indItem >= _arrCraft.length){
				
				//arrowRigthBttn.state = Button.DISABLED;
				arrowRigthBttn.mouseEnabled = false;
				arrowRigthBttn.alpha = 0.5;
			}
			
			contentChange();
			findTarget();
		}
		
		private function hidePaginator():void {
			arrowLeftBttn.visible = false;
			arrowRigthBttn.visible = false;
		}
		
		private function showPaginator():void {
			arrowLeftBttn.visible = true;
			arrowRigthBttn.visible = true;
		}
		
		private var arrowLeftBttn:ImageButton;
		private var arrowRigthBttn:ImageButton;
		override public function drawArrows():void
		{
			
			arrowLeftBttn = new ImageButton(Window.textures.menuArrow, {scaleX:1,scaleY:1});
			arrowRigthBttn = new ImageButton(Window.textures.menuArrow2, { scaleX:1, scaleY:1 } );
			hidePaginator();
			bodyContainer.addChild(arrowLeftBttn);
			bodyContainer.addChild(arrowRigthBttn);
			
			arrowLeftBttn.x = 15;
			arrowLeftBttn.y = 320;
			arrowLeftBttn.rotation = 0;
			
			arrowRigthBttn.x = 520;
			arrowRigthBttn.y = 320;
			//arrowRigthBttn.rotation = 10;
			
			arrowLeftBttn.addEventListener(MouseEvent.CLICK, onLeftArrowClick);
			arrowRigthBttn.addEventListener(MouseEvent.CLICK, onRightArrowClick);
			
			//arrowLeftBttn.state = Button.DISABLED;
			arrowLeftBttn.mouseEnabled = false;
			arrowLeftBttn.alpha = 0.2;
			
			if (_arrCraft.length <= 6) 
			{
				arrowRigthBttn.mouseEnabled = false;
				arrowRigthBttn.alpha = 0.2;
			}
			else 
			{
				arrowRigthBttn.mouseEnabled = true;
				arrowRigthBttn.alpha = 1;
			}
		}
		
		private var isScrolling:Boolean = false;
		private var countScrollItems:int = 2;
		private var scrollingTime:Number = 0.2;
		private var scrollingAngle:int = 30;
		
		private var arrRemove:Array = [];
		
		private function addScrollItems(type:int):int
		{
			var countItems:int = 0;
			var removeInd:int = 0;
			var newInd:int;
			
			if (indItem < 0)
				indItem = 0;
			else if (indItem >= _arrCraft.length)
				indItem = _arrCraft.length;
			
			switch(type) {
				case 1:
					newInd = indItem;
					removeInd = 0;
				break;
				case 2:
					newInd = indItem - settings.itemsOnPage - 1;
					removeInd = items.length - 1;
				break;
			}
			
			var stopAdd:Boolean = false;
			
			arrRemove = [];
			
			for (var i:int = 0; i < countScrollItems; i++ ) {
				
				if (stopAdd || !_arrCraft[newInd])
					break;
				
				countItems++;
					
				var inner:Sprite = new Sprite();
				var cont:Sprite = new Sprite();
				
				var item:ProductionItem = new ProductionItem(this, { height:itemHeight, width:itemWidth, crafting:_arrCraft[newInd], craftData:_arrCraft, level:level } );
				
				item.canRotate = false;
				inner.addChild(item);
				item.x = - item.width / 2;
				item.y = - item.height / 2;
				
				var koef:int = -1;
				if (type == 1)
					koef = 1;
				inner.rotation = -setPosScrollItems(newInd + 1) - itemContainer.rotation + scrollingAngle * countScrollItems * koef;
				
				inner.x = 230;
				cont.addChild(inner);
				
			
				itemContainer.addChild(cont);
				
				cont.rotation = setPosScrollItems(newInd + 1);
				
				var isHelp:Boolean = false;
				
				if (settings.find == App.data.crafting[_arrCraft[newInd].fid].out) 
					isHelp = true;
				
				item.change(_arrCraft[newInd].fid, _arrCraft[newInd].lvl, isHelp);
				item.visible = true;
				
				arrRemove.push(items[removeInd]);
				items.splice(removeInd,1);
				
				switch(type) {
					case 1:
						indItem ++;
						if (indItem >= _arrCraft.length) {
							stopAdd = true;
							arrowRigthBttn.mouseEnabled = false;
							arrowRigthBttn.alpha = 0.2;
							inner.rotation = -setPosScrollItems(newInd + 1) - itemContainer.rotation + scrollingAngle * countItems * koef;
						}
						newInd++;
						items.push(item);
					break;
					case 2:
						indItem --;
						if (indItem - settings.itemsOnPage - 1 < 0) {
							stopAdd = true;
							arrowLeftBttn.mouseEnabled = false;
							arrowLeftBttn.alpha = 0.2;
							inner.rotation = -setPosScrollItems(newInd + 1) - itemContainer.rotation + scrollingAngle * countItems * koef;
						}
						newInd--;
						items.unshift(item);
					break;
				}
			}
			
			return countItems;
		}
		
		private function setPosScrollItems(ind:int):Number
		{
			var countItems:int = int(settings.itemsOnPage) * 2;
			var angle:Number = ind * 360 / countItems + 165;//152//165;
			
			if (angle > 360)
				angle = angle - 360;
			
			return angle;
		}
		
		private function onRightArrowClick(e:MouseEvent):void 
		{		
			if (isScrolling || indItem >= _arrCraft.length || arrowRigthBttn.mode == Button.DISABLED)
				return;
			//arrowLeftBttn.state = Button.NORMAL;
			arrowLeftBttn.mouseEnabled = true;
			arrowLeftBttn.alpha = 1;
			makeScrolling(1);
		}
		
		private function onLeftArrowClick(e:MouseEvent):void 
		{
			if (isScrolling || (indItem - settings.itemsOnPage - 1) < 0 || arrowLeftBttn.mode == Button.DISABLED)
				return;
				
			//arrowRigthBttn.state = Button.NORMAL;	
			arrowRigthBttn.mouseEnabled = true;
			arrowRigthBttn.alpha = 1;
			makeScrolling(2);
		}
		
		private function makeScrolling(type:int):void {
			if (tween) {
				onTweenComplete();
				itemContainer.rotation = targetRotation;
			}
			
			var koef:int = 1;
			if (type == 1)
				koef = -1;
			
			//isScrolling = true;
			
			var itemsToScroll:int = addScrollItems(type);
			
			var angle:int = scrollingAngle * itemsToScroll * koef;
			rotationAngle = itemContainer.rotation + angle;
			
			var item:ProductionItem = null;
			
			for (var i:int = 0; i < items.length; i++ ) {
				item = items[i];
				
				if (item.canRotate) {
					var _angle:int = convertAngle(item.parent.rotation - angle);
					item.rotateAngle = _angle;
					item.rotateTween = TweenLite.to(item.parent, scrollingTime * itemsToScroll, { rotation:_angle } );
				} else {
					item.canRotate = true;
				}
			}
			item = null;
			
			for (i = 0; i < arrRemove.length; i++ ) {
				item = arrRemove[i];
				
				if(item)
					item.parent.rotation = convertAngle(item.parent.rotation - angle);
			}
			
			targetRotation = rotationAngle;
			tween = TweenLite.to(itemContainer, scrollingTime * itemsToScroll, { rotation:rotationAngle, onComplete:onTweenComplete } );;
		}
		
		private function onTweenComplete():void {
			if(tween)
				tween.kill();
			tween = null;
			isScrolling = false;
			for (var i:int = 0; i < arrRemove.length; i++ ) {
				if(arrRemove[i]) {
					arrRemove[i].parent.removeChild(arrRemove[i]);
					arrRemove[i].dispose();
				}
			}
			
			for (i = 0; i < items.length; i++) {
				items[i].removeAngleTween();
			}
			arrRemove = [];
		}
		
		private var tween:TweenLite; 
		private var targetRotation:Number;
		private var levelTxt:TextField;
		private var titleTxt:TextField;
		
		private function convertAngle(value:int):int
		{
			var angle:int = value;
			
			if (angle > 360)
				angle = angle - 360;
			else if (angle < 0)
				angle = angle + 360;
				
			return angle;
		}
		
		override public function contentChange():void {
			
			for (var i:int = 0; i < items.length; i++)
			{
				items[i].visible = false;
			}
			
			var itemNum:int = 0
			
			for (i = paginator.startCount; i < paginator.finishCount; i++)
			{
				var isHelp:Boolean = false;
				if (settings.find == App.data.crafting[_arrCraft[i].fid].out  ) 
					isHelp = true;
				if ((App.data.crafting[_arrCraft[i].fid].out == App.data.storage[App.user.worldID].cookie[0])) 
				{
					if ((App.user.stock.count(App.data.storage[App.user.worldID].cookie[0])<=uint(App.data.options.CookiesAlarmLimit))) 
					{
						isHelp = true;
					}
				}
				items[itemNum].change(_arrCraft[i].fid, _arrCraft[i].lvl, isHelp);
				items[itemNum].visible = true;
				itemNum++;
			}
			
			settings.page = paginator.page;
			history = settings.page;
		}
		
		public function onCookEvent(fID:uint):void {
			isStart = false;
			var queueCounter:int;
			//if (App.user.quests.tutorial)
			
			for (var item:* in settings.target.queue) {
				queueCounter++;
				if (queueCounter >= 1)
					productionQueue.update();
			}
			//if (queueCounter < 1)
				//close();
			
			if (!settings.target.crafting) {
				settings.onCraftAction(fID);
				close();
				return;
				/*startProgress(fID);
				//contentChange();
				levelTxt.visible = false;
				App.ui.flashGlowing(progressBacking, 0xFFFF00, null, false);
				SoundsManager.instance.playSFX('production');	
				progressVisible(true);
				if (upgradeBttn) upgradeBttn.visible = false;*/
			}else {
				settings.onCraftAction(fID);
				updateNumItems();
			}
			settings.target.fID;
			addElemetnToQueue(settings.target.fID);
		}
		
		private var count:int;
		public var productionQueue:ProductionQueue;
		private function addElemetnToQueue(_fID:int):void 
		{
			var fid:int = _fID;
			count++;
			//drawQueue(true);
		}
		
		protected function progress():void
		{
			var leftTime:int = crafted - App.time;
			if (leftTime < 0) 
			{
				cookingBar.time = 0;
				cookingBar.progress = 1;
				App.self.setOffTimer(progress);
				close();
				return;
			}	
			cookingBar.progress = (totalTime - leftTime) / totalTime;
			cookingBar.time		= leftTime;
			if (settings.sid ==243 &&App.user.quests.currentQID ==128) 
			{
				
			}
			priceSpeed = Math.ceil((crafted - App.time) / App.data.options['SpeedUpPrice']);
			if (boostBttn && priceBttn != priceSpeed && priceSpeed != 0) {
				priceBttn = priceSpeed;
				boostBttn.count = String(priceSpeed);
			}
			if (App.data.quests.hasOwnProperty(App.user.quests.currentQID) && 
			App.data.quests[App.user.quests.currentQID].missions != null&&
			App.data.quests[App.user.quests.currentQID].missions.hasOwnProperty(App.user.quests.currentMID) && 
			App.data.quests[App.user.quests.currentQID].missions[App.user.quests.currentMID].event == 'boost' &&
			settings.find) {
				boostBttn.count = '0';
				//boostBttn.showGlowing();
			}
			if (App.data.quests.hasOwnProperty(App.user.quests.currentQID) && settings.target.sid == 243 && App.user.quests.currentQID == 128) {
				boostBttn.count = '0';
				//boostBttn.showGlowing();
				
			}
			dispatchEvent(new WindowEvent("onProgress"));
		}
		
		override public function dispose():void {
			
			settings.target.visible = true;
			
			if (_arrCraft) {
				_arrCraft.splice(0, _arrCraft.length);
			}
			_arrCraft = null;
			if (shine) 
			{
		//	bodyContainer.removeChild(shine);	
			}
			
			for (var i:int = 0; i < items.length; i++ ) {
				items[i].dispose();
			}
			
			if(arrowLeftBttn){
				arrowLeftBttn.removeEventListener(MouseEvent.CLICK, onLeftArrowClick);
				arrowLeftBttn.dispose();
				arrowLeftBttn = null;
			}
			if(arrowRigthBttn){
				arrowRigthBttn.removeEventListener(MouseEvent.CLICK, onRightArrowClick);
				arrowRigthBttn.dispose();
				arrowRigthBttn = null;
			}
			
			App.self.setOffTimer(progress);
			super.dispose();
		}
		
		public function glowQuest():void {
			var qID:* = App.user.quests.currentQID;
			var mID:* = App.user.quests.currentMID;
			var targets:* = App.data.quests[qID].missions[mID].target;
			
			for each(var sID:* in targets) {
				for each(var item:ProductionItem in items) {
					if (item.sID == sID) {
						item.select();
					}
				}
			}
		}
		
		
		// Create Items NG
		private var productionItems:Vector.<ProductionItem> = new Vector.<ProductionItem>;
		private var values:Object = { rotate:-4, targetRotate:-4 }		// Доля угла
		private const ANGLE:int = 25;
		private const RADIUS:int = 300;
		private var moveTween:TweenLite;
		public function createItemsNG():void {
			itemContainer.x = settings.width / 2;
			itemContainer.y = 400;
			
			itemContainer.graphics.beginFill(0xff0000);
			itemContainer.graphics.drawCircle(0, 0, 5);
			itemContainer.graphics.endFill();
			
			for (var i:int = 0; i < _arrCraft.length; i++) {
				var item:ProductionItem = new ProductionItem(this, {
					height:			itemHeight,
					width:			itemWidth,
					crafting:		_arrCraft[i],
					craftData:		_arrCraft,
					level:			level
				});
				item.change(_arrCraft[i].fid, _arrCraft[i].lvl, false);
				itemContainer.addChild(item);
				productionItems.push(item);
				
				item.visible = false;
			}
			
			firstShow();
		}
		public function firstShow():void {
			productionMoveTo();
		}
		public function productionMoveTo(value:int = 0):void {
			if (values.rotate == value) return;
			
			if (moveTween) moveTween.kill();
			moveTween = TweenLite.to( values, 0.5, { rotate:value, onUpdate:onUpdate, onComplete:onComplete } );
			
			values.targetRotate = value;
			
			function onUpdate():void {
				for (var i:int = 0; i < productionItems.length; i++) {
					//if (i > values.rotate + 4 && i < values.rotate + 8
					//trace(values.rotate);
				}
			}
			function onComplete():void {
				moveTween = null;
			}
		}
		
		public function get canBoost():Boolean 
		{
			return (settings.target.info.hasOwnProperty('mboost') && settings.target.info.mboost != "" && settings.target.info.mboost>0 &&!isNaN(settings.target.info.mboost))
		}
		
		public function mBoost(onComplete:Function = null):void 
		{
			var mBoost:int;
			if (settings.target.info.hasOwnProperty('mboost') && settings.target.info.mboost != "" && !isNaN(settings.target.info.mboost)) {
				mBoost = settings.target.info.mboost;
			}else {
				new SimpleWindow({text:'Нельзя ускорить',popup:true}).show();
				return;
			}
			if (App.user.stock.count(mBoost)) {
				var pstParams:Object = {
					ctr:settings.target.info.type,
					act:'mboost',
					uID:App.user.id,
					id:settings.target.id,
					wID:App.user.worldID,
					sID:settings.target.sid
				}
				Post.send(pstParams,mBoostComplete,{completeCallback:onComplete,boostedSid:mBoost});
			}else {
				if(onComplete != null)
					onComplete();
				//ShopWindow.findMaterialSource(mBoost)
				new SimpleWindow({text:Locale.__e('flash:1445780031642'),popup:true}).show();
				return;
			}			
		}
		
		public function mBoostComplete(error:*, data:*, params:*):void
		{
			if (params.hasOwnProperty('boostedSid') && params.boostedSid) {
				var takeObj:Object = { };
				takeObj[params.boostedSid] = 1;
				App.user.stock.takeAll(takeObj);
			}
			if (params.hasOwnProperty('completeCallback') && params.completeCallback != null) {
				params.completeCallback();
			}
				
			if (error) {
				Errors.show(error, data);
				return;
			}
			crafted = data.crafted;
			settings.target.began = data.crafted - App.time;
			for each(var q:* in settings.target.queue) {
				q.crafted = data.crafted;
			}
		}
	}
}
