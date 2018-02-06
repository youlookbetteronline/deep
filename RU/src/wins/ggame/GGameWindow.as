/**
 * Created by Andrew on 10.05.2017.
 */
package wins.ggame
{
	import buttons.ImageButton;
	import core.Size;
	import flash.filters.GlowFilter;
	import ui.UserInterface;
	import wins.ExpeditionHintWindow;
	import wins.SimpleItemsWindow;
	import wins.WindowInfoWindow;

	import core.Load;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import helpers.geometry.Geometry;

	import ui.BitmapLoader;

	import wins.InfoWindow;

	import wins.PurchaseWindow;
	import wins.SimpleWindow;
	import wins.Window;
	import wins.WindowEvent;
	import wins.ggame.result.ResultModel;
	import wins.ggame.result.ResultWindow;

	public class GGameWindow extends Window
	{
		private const BORDER_OFFSET:int = 150;

		private var _uiLayer:Sprite;
		private var _itemsLayer:Sprite;
		private var _stickiLayer:Sprite;
		private var _startPanel:StartPanel;
		private var _timePanel:TimePanel;
		private var _stickObject:StickObject;
		private var _model:GGameModel;
		private var _resultModel:ResultModel;
		private var _panel1:CurrencyCounter;
		private var _panel3:Counter;
		private var _panel4:Counter;

		private var _itemsPull:Vector.<FallingObject>;

		private var _stickLimitMin:Point;
		private var _stickLimitMax:Point;

		private var _spawnLimitMin:Point;
		private var _spawnLimitMax:Point;

		private var _moveLimitMin:Point;
		private var _moveLimitMax:Point;

		private var _fallingTime:Number = 7;

		private var _itemsList:Vector.<FallingObject>;
		private var _delayStep:uint = 1500;

		private var _loadedContent:int = 0;

		private var _helpBttn:ImageButton;

		public function GGameWindow()
		{
			_model = GGameModel.instance;
			_resultModel = ResultModel.instance;

			settings = settingsInit(settings);
			super(settings);

			_itemsPull = new Vector.<FallingObject>();
			_itemsList = new Vector.<FallingObject>();

			initLimits();
			//firstTimeHelp();
		}

		/**
		 * предварительная загрузка всех иконок, что бы не плыли крутящиеся колеса
		 */
		private function loadAllIcons():void {
			addEventListener(GGameEvent.ON_ICON_LOADED, onIconLoad);
			_loadedContent = 0;
			for(var i:int = 0; i < _model.uniqItems.length; i++)
			{
				loadIcon(_model.uniqItems[i].sid);
			}
		}

		/**
		 * при загрузке иконки, записываем что она загрузилась и проверяем все ли из списка загружены
		 */
		private function onIconLoad(event:Event):void {
			_loadedContent++;

			if(_loadedContent == _model.uniqItems.length)
			{
				removeEventListener(GGameEvent.ON_ICON_LOADED, onIconLoad);

				_timePanel.start(App.time + _model.raundTime);
				createItems();
			}
		}

		private function loadIcon(sid:int):void {
			Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].view), function(data:Bitmap):void {
				dispatchEvent(new GGameEvent(GGameEvent.ON_ICON_LOADED));
			});
		}

		/**
		 * инициализация лимитов спавна объектов и движения сачка
		 */
		private function initLimits():void {
			_stickLimitMin = new Point(this.x + BORDER_OFFSET, this.y + settings.height - 40);
			_stickLimitMax = new Point(this.x + settings.width - BORDER_OFFSET, this.y + settings.height - 80);

			_spawnLimitMin = new Point(this.x + BORDER_OFFSET + 100, this.y - BORDER_OFFSET);
			_spawnLimitMax = new Point(this.x + settings.width - BORDER_OFFSET - 100, this.y - BORDER_OFFSET);

			_moveLimitMin = new Point(this.x + BORDER_OFFSET, this.y + settings.height);
			_moveLimitMax = new Point(this.x + settings.width - BORDER_OFFSET, this.y + settings.height);
		}

		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}

			settings["width"]			= settings.width 	|| 862;
			settings["height"] 			= settings.height 	|| 660;
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;
			settings["background"]		= settings.background || "capsuleWindowBacking";
			settings["faderClickable"]  = false;
			settings["escExit"]         = false;
			settings['exitTexture'] 	= 'closeBttnMetal';
			settings['fontColor'] 		= 0xffffff;
			settings['fontBorderColor'] = 0x085c10;
			settings['borderColor']		= 0x085c10;
			settings['shadowColor'] 	= 0x085c10;
			settings["hasBubbles"] 		= true;
			settings["bubblesCount"] 	= 14;
			settings["bubbleRightX"] 	= -190;
			settings["bubbleLeftX"] 	= 130;
			settings["bubblesSpeed"] 	= 5;

			settings["title"] = _model.title;

			return settings;
		}
		
		public function get panel3():Counter
		{
			return _panel3
		}

		private function initListeners():void {
			App.self.setOnEnterFrame(update);
			stage.addEventListener(GGameEvent.ON_GAME_START, onGameStart);
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.addEventListener('onBeforeClose', onPurchasClose);
			App.self.addEventListener(WindowEvent.ON_BEFORE_OPEN, onPurchasOpen);
		}

		/**
		 * при открытии доп окна, паузим игру
		 */
		private function onPurchasOpen(event:Event):void {
			if(App.self.windowContainer.numChildren == 1)
				return;

			if(_panel1.visible)
				return;

			for each (var object:FallingObject in _itemsList)
			{
				object.pause();
			}

			_model.paused = true;
			_stickObject.paused = true;
			_timePanel.paused = true;
		}

		/**
		 * при закрытии доп окон, возобнавляем игру
		 */
		private function onPurchasClose(event:Event):void {
			if(App.self.windowContainer.numChildren > 2)
				return;

			if(_panel1.visible)
				return;

			for each (var object:FallingObject in _itemsList)
			{
				object.unpause();
			}

			_model.paused = false;
			_stickObject.paused = false;
			_timePanel.paused = false;
		}

		/**
		 * при нажатии старта, меняем состояние view окна
		 */
		private function onGameStart(event:GGameEvent):void {
			event.stopImmediatePropagation();
			event.stopPropagation();

			_model.groupOfMaterialsCount = 0;
			_model.catched = {};
			loadAllIcons();

			_panel1.visible = false;
			_startPanel.enabled(false);

			_stickObject.started = true;
		}

		private function createItems():void {
			var delay:uint = 0;

			for(var i:int = 0; i < _model.maxOnScreen; i++)
			{
				getItem(_model.itemsOrder.pop(), Geometry.getRandomPosBetween(_spawnLimitMin, _spawnLimitMax), delay);

				delay += _delayStep;
			}
		}

		/**
		 * возвращает доступным нам итем, если есть те что отработали свое, берет его и пересоздает, или если нету свободных создает нового
		 */
		private function getItem(sid:int, point:Point, delay:uint = 0):FallingObject {
			var fallingObject:FallingObject;

			if(_itemsPull.length == 0)
			{
				fallingObject = new FallingObject(sid);

				fallingObject.x = point.x;
				fallingObject.y = point.y;

				_itemsList.push(fallingObject);
				_itemsLayer.addChild(fallingObject);
				fallingObject.addEventListener(GGameEvent.ITEM_MOVE_COMPLETE, onItemMoveComplete);
				fallingObject.addEventListener(GGameEvent.ITEM_CATCHED, onItemCatch);
			}
			else
			{
				fallingObject = _itemsPull.pop();

				fallingObject.stopHide();
				fallingObject.x = point.x;
				fallingObject.y = point.y;

				fallingObject.recreate(sid);
			}
			if (_model.firstGame)
			{
				var colorGlowing:* = 0xcd0000;
				for each(var itm:* in _model.uniqItems)
				{
					if (itm.sid == fallingObject.sid && itm.count)
					{
						colorGlowing = 0xfff000;
						break;
					}
				}
				fallingObject.filters = [new GlowFilter(colorGlowing, 3, 3, 3, 8, 3, true)];
				
			}
			var endPos:Point = Geometry.getRandomPosBetween(_moveLimitMin, _moveLimitMax);

			var color:uint = Math.random() * 0xFFFFFF;

			var s1:Shape = new Shape();

			s1.graphics.beginFill(color);
			s1.graphics.drawCircle(0,0, 10);
			s1.graphics.endFill();

			s1.x = endPos.x;
			s1.y = endPos.y;

			_itemsLayer.addChild(s1);

			fallingObject.initMove(endPos, _fallingTime, delay);

			return fallingObject;
		}
		
		/**
		 * когда поймали предмет
		 */
		private function onItemCatch(event:GGameEvent):void {
			if(_itemsPull.indexOf(event.target) >= 0)
				return;
			var colorGlowing:* = 0xcd0000;
			for each(var itm:* in _model.uniqItems)
			{
				if (itm.sid == event.target.sid && itm.count)
				{
					colorGlowing = 0xfff000;
					break;
				}
			}
			_stickObject.showGlowingOnce(colorGlowing, 1);
			trace();
			onItemMoveComplete(event);
			onStockChange(null);
		}

		/**
		 * предмет закончил свое движение
		 */
		private function onItemMoveComplete(event:GGameEvent):Boolean {
			if(event)
			{
				event.stopPropagation();
				event.stopImmediatePropagation();
			}

			if(_itemsPull.indexOf(event.target) == -1)
				_itemsPull.push(event.target as FallingObject);
			else
				return false;

			getItem(_model.itemsOrder.pop(), Geometry.getRandomPosBetween(_spawnLimitMin, _spawnLimitMax));

			return true;
		}

		override public function drawBody():void
		{
			exit.y -= 20;
			drawBg();
			createLayers();

			createPanels();
			createStickObject();
			drawPanels();
			drawRibbon();
			titleLabel.y += 15;
			titleBackingBmap.y += 5;
			
			drawInfoBttn();
			drawHelpBttn();
		}

/*
		private function firstTimeHelp():void
		{
			App.user.storageRead('HelpCount', null);

			var help:Object = App.user.storageRead('HelpCount', null);
			if (!help) help = { };

			if (help.hasOwnProperty('ggame_3983'))
			{

			}
			else
			{
				help ['ggame_3983'] = 1;

				App.user.storageStore('HelpCount', help, true);
				onHelpEvent(null);
			}
		}*/


		private function drawPanels():void {
			_panel1 = new CurrencyCounter(_model.startPriceSID);
			_panel3 = new Counter(_model.catchPriceSID, _model.canCatch - _model.catchedCount, {searchEnabled:false});
			_panel4 = new Counter(-1, _model.groupOfMaterialsCount, {buy:false, type:'Content', view:'river_gold', scale:1});

			_panel1.x = _panel3.x = _panel4.x = _itemsLayer.mask.x + 75;
			_panel3.y = _itemsLayer.mask.y + 25;
			_panel1.y =  _panel3.y + _panel3.height + 1;
			
			_panel4.y = _panel3.y + _panel3.height + 1;

			_uiLayer.addChild(_panel1);
			_uiLayer.addChild(_panel3);
			//_uiLayer.addChild(_panel4);
		}

		private function createStickObject():void {
			_stickObject = new StickObject('content','ggame_net',_stickLimitMin, _stickLimitMax);

			_stickiLayer.addChild(_stickObject);
		}

		private function createPanels():void {
			createStartPanel();
			createTimePanel();
		}

		private function createTimePanel():void {
			_timePanel = new TimePanel();

			_timePanel.x = 360;
			_timePanel.y = 70;

			_timePanel.addEventListener(GGameEvent.TIMER_COMPLETE, onTimerComplete);
			_uiLayer.addChild(_timePanel);
		}

		/**
		 * время закончилось
		 */
		private function onTimerComplete(event:GGameEvent):void {
			var item:FallingObject;

			while (_itemsList.length > 0)
			{
				item = _itemsList.pop();
				_itemsLayer.removeChild(item);
				item.dispose();
			}

			_itemsPull = new Vector.<FallingObject>();

			_stickObject.started = false;
			_startPanel.enabled(true);

			_panel1.visible = true;
			_model.saveGameStartCallback(showResultWindow);
			
		}

		private function showResultWindow():void {
			//Window.closeAll();
			new ResultWindow({ggamewin:this}).show();
		}

		private function createStartPanel():void {
			_startPanel = new StartPanel();

			_startPanel.x = settings.width / 2;
			_startPanel.y = settings.height / 2 + 240;
			_startPanel.addEventListener(GGameEvent.ON_START_CLICK, onStartClick);
			_uiLayer.addChild(_startPanel);
		}

		private function onStartClick(event:GGameEvent):void {
			event.stopPropagation();
			
			event.stopImmediatePropagation();
			if(App.user.stock.checkAll(_model.startPrice/*, true*/))
			{
				_model.gameStartCallback();
				_startPanel.enabled(false);
			}
			else
			{
				var content:Array = PurchaseWindow.createContent('Energy', { inguest:0, view:App.data.storage[_model.startPriceSID].view}, _model.startPriceSID  );
				if(content.length > 0 || true)
				{
					new PurchaseWindow( {
						popup:		true,
						width:		600,
						itemsOnPage:content.length,
						content:	content,
						title:		App.data.storage[_model.startPriceSID].title,
						description:Locale.__e('flash:1472652747853')
					}).show();
				}

				_startPanel.enabled(true);
			}
		}

		private function drawBg():void {
			var bg:BitmapLoader = new BitmapLoader(Config.getImage('content', 'ggame_river', 'jpg'), 0, 0, 1, function ():void {
				if(_itemsLayer.mask)
					bodyContainer.removeChild(_itemsLayer.mask);

				if(_stickiLayer.mask)
					bodyContainer.removeChild(_stickiLayer.mask);

				_itemsLayer.mask = getMask(new Rectangle(bg.x, bg.y - 60, bg.width, bg.height + 60));
				_stickiLayer.mask = getMask(new Rectangle(bg.x, bg.y, bg.width, bg.height));
			});
			bg.x = settings.width / 2 - 787 / 2;
			bg.y = settings.height / 2 - 622 / 2 - 11;
			bodyContainer.addChild(bg);
			
			var maskBg:Shape = new Shape();
			maskBg.graphics.beginFill(0x000000, 1);
			maskBg.graphics.drawRoundRect(0, 0, settings.width - 77, settings.height - 85, 40, 40);
			maskBg.graphics.endFill();
			maskBg.x = settings.width / 2 - 787 / 2;
			maskBg.y = settings.height / 2 - 622 / 2 - 11;
			bg.mask = maskBg;
			bodyContainer.addChild(maskBg);
		}

		private function createLayers():void {
			_uiLayer = new Sprite();
			_itemsLayer = new Sprite();
			_stickiLayer = new Sprite();

			bodyContainer.addChild(_itemsLayer);
			bodyContainer.addChild(_uiLayer);
			bodyContainer.addChild(_stickiLayer);

			if(!_itemsLayer.mask)
				_itemsLayer.mask = getMask(new Rectangle(37, 1, 622, 787));

			if(!_stickiLayer.mask)
				_stickiLayer.mask = getMask(new Rectangle(37, 1, 622, 787));
		}

		private function getMask(rect:Rectangle):DisplayObject {
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0xFFFFFF00);
			mask.graphics.drawRect(rect.x,rect.y + 61, rect.width, rect.height - 61);
			mask.graphics.endFill();

			bodyContainer.addChild(mask );
			return mask ;
		}


		override public function dispose():void {
			if(_startPanel)
			{
				_startPanel.removeEventListener(GGameEvent.ON_START_CLICK, onStartClick);
				_startPanel.dispose();
			}

			if(_timePanel)
			{
				_timePanel.removeEventListener(GGameEvent.TIMER_COMPLETE, onTimerComplete);
				_timePanel.dispose();
			}

			App.self.setOffEnterFrame(update);
			stage.removeEventListener(GGameEvent.ON_GAME_START, onGameStart);
			
			if (_stickObject)
			{
				_stickObject.dispose();
			}

			for each (var object:FallingObject in _itemsList)
			{
				object.removeEventListener(GGameEvent.ITEM_MOVE_COMPLETE, onItemMoveComplete);
				object.removeEventListener(GGameEvent.ITEM_CATCHED, onItemCatch);
				object.dispose();
			}

			if(_panel1)
			{
				_panel1.dispose();
				_panel3.dispose();
				_panel4.dispose();
			}

			removeEventListener(GGameEvent.ON_ICON_LOADED, onIconLoad);
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);

			super.dispose();
		}

		override public function show():void {
			super.show();

			initListeners();
		}

		public function onStockChange(e:AppEvent):void {
			if (!_panel1) return;

			_panel1.update();
			_panel3.update(_model.canCatch - _model.catchedCount);
			_panel4.update(_model.groupOfMaterialsCount);

			_startPanel.update();
		}

		/**
		 * проверка пересечения линии, объектов с линией сачка
		 */
		public function update(e:Event):void {
			for each(var fallingObject:FallingObject in _itemsList)
			{
				if(checkCollision(fallingObject))
				{
					if(canCatch())
					{
						if(!fallingObject.catched)
						{
							catchObject(fallingObject);
							fallingObject.mesh();
						}
					}
					else
					{
						if(!_model.paused)
							_panel3.onPlus(null);
					}
				}
			}
		}

		private function catchObject(fallingObject:FallingObject):void {
			if(_model.catched[fallingObject.sid])
				_model.catched[fallingObject.sid] += 1;
			else
				_model.catched[fallingObject.sid] = 1;


			for each (var itemVO:ItemVO in _model.uniqItems)
			{
				if(itemVO.sid == fallingObject.sid)
				{
					if(itemVO.count)
					{
						_model.groupOfMaterialsCount++;
					}
				}
			}
		}

		private function canCatch():Boolean {
			return _model.canCatch > _model.catchedCount;
		}

		private function checkCollision(fallingObject:FallingObject):Boolean {
			if(!fallingObject || !fallingObject.previousPosition || !fallingObject.currentPosition)
				return false;
			if(fallingObject.sid == 2443){
				trace(fallingObject.sid + ' collision = ' + Geometry.isIntersecting(fallingObject.previousPosition, fallingObject.currentPosition, _stickObject.left, _stickObject.right));
				trace('prevPosition: (x:' + fallingObject.previousPosition.x + ' y:' + fallingObject.previousPosition.y + ')');
				trace('currPosition: (x:' + fallingObject.currentPosition.x + ' y:' + fallingObject.currentPosition.y + ')');
			}
			
			return Geometry.isIntersecting(fallingObject.previousPosition, fallingObject.currentPosition, _stickObject.left, _stickObject.right);
		}

		override public function drawExit():void {
			super.drawExit();

			exit.removeEventListener(MouseEvent.CLICK, close);
			exit.addEventListener(MouseEvent.CLICK, closeConfirm);
		}

		private function closeConfirm(event:MouseEvent):void {
			if(_panel1.visible)
			{
				close();
				return;
			}

			new SimpleWindow( {
				cancelText:		Locale.__e('flash:1382952380008'),
				title:			Locale.__e('flash:1474469531767'),
				text:			Locale.__e('flash:1505124517846'),
				confirmText:	Locale.__e('flash:1448460114881'),
				dialog:			true,
				popup:			true,
				confirm:		function():void {
					close();
				},
				cancel:			function():void {},
				needCancelAfterClose:	true
			}).show();
		}
		
		private function drawInfoBttn():void 
		{
			var infoBttn:ImageButton = new ImageButton(textures.askBttnMetal);
			bodyContainer.addChild(infoBttn);
			infoBttn.x = settings.width - 47;
			infoBttn.y = 40;
			infoBttn.addEventListener(MouseEvent.CLICK, infoEvent);
		}
		
		private function infoEvent(e:MouseEvent = null):void
		{
			var hintWindow:ExpeditionHintWindow = new ExpeditionHintWindow( {
				popup: true,
				hintID:5,
				height:540
			});
			hintWindow.show();	
			
		}
		
		private function drawHelpBttn():void 
		{
			_helpBttn = new ImageButton(textures.infoBttnMetal);
			Size.size(_helpBttn, 60, 60);
			bodyContainer.addChild(_helpBttn);
			_helpBttn.x = settings.width - 47;
			_helpBttn.y = 110;
			_helpBttn.addEventListener(MouseEvent.CLICK, helpEvent);
		}
		
		private function helpEvent(e:MouseEvent = null):void 
		{
			new SimpleItemsWindow({
				content	:_model.garbage,
				popup	:true
			}).show()
		}
	}
}
