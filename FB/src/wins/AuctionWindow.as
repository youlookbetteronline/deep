package wins
{
	import buttons.MenuButton;
	import chat.Chat;
	import chat.ChatEvent;
	import chat.models.ChatModel;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketEvent;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	public class AuctionWindow extends Window
	{
		private var _auction:Object = {};
		private var _icons:Array = new Array();
		private var _backIcon:Shape = new Shape();
		private var _items:Vector.<TabItem> = new Vector.<TabItem>();
		private var _lastChangeTab:String;
		private var _testConnect:*;
		
		public function AuctionWindow(settings:Object = null):void
		{
			if (settings == null)
			{
				settings = new Object();
			}
			
			settings["page"] = settings.page || 0;
			settings["title"] = Locale.__e('flash:1503046891653');
			settings["width"] = 660;
			settings["height"] = 670;
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 2;
			settings["buttonsCount"] = 8;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] = 0x116011;
			settings['shadowBorderColor'] = 0x116011;
			_auction = App.user.auction;
			connect();
			super(settings);
		}
		
		override public function dispose():void
		{
			super.dispose();
			App.user.auction.chatDisconnect();
			clearTimeout(_testConnect);
		}
		
		public function connect():void
		{
			var that:* = this;
			Post.send({
				ctr: 'user',
				act: 'aconnect',
				uID: App.user.id,
				wID: App.user.worldID
			}, function(e:int, data:Object, params:Object):void {
				if (e){
					that.close();
					return;
				}
				
				if (data.auction){
					App.user.auction.initChat(data.auction.id, data.auction.token);
				}
			});
		}
		
		override public function drawBackground():void
		{
			var background:Bitmap = backing(settings.width, settings.height, 50, 'workerHouseBacking');
			
			_backIcon.graphics.beginFill(0xfad7b5, 1);
			_backIcon.graphics.lineStyle(1, 0xaf5824);
			_backIcon.graphics.drawRoundRect(0, 0, 580, 524, 20, 20);
			_backIcon.y = 107;
			_backIcon.x = (settings.width - _backIcon.width) / 2 + 1;
			_backIcon.graphics.endFill();
			layer.addChild(background);
			layer.addChild(_backIcon);
		}
		
		override public function drawExit():void
		{
			super.drawExit();
			exit.x = settings.width - exit.width + 47;
			exit.y = -8;
		}
		
		override public function drawTitle():void
		{
			titleLabel = titleText({title: settings.title, color: settings.fontColor, multiline: settings.multiline, fontSize: 42, textLeading: settings.textLeading, borderColor: settings.fontBorderColor, borderSize: 3, shadowSize: 1, shadowColor: settings.fontBorderColor, shadowBorderColor: settings.shadowBorderColor || settings.fontColor, width: settings.width - settings.titlePading, textAlign: 'center', sharpness: 50, thickness: 50, border: true})
			
			drawRibbon();
			titleLabel.y += 15;
			titleBackingBmap.y += 5;
		}
		
		override public function drawBody():void
		{
			//App.user.auction.getReward();
			exit.x -= 30;
			drawTabs();
			contentChange();
		}
		
		override public function drawArrows():void
		{
			paginator.drawArrow(bottomContainer, Paginator.LEFT, 0, 0, {scaleX: -1, scaleY: 1});
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, {scaleX: 1, scaleY: 1});
			
			var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 45;
			paginator.arrowLeft.x = paginator.arrowRight.width - 30;
			paginator.arrowLeft.y = y - 54;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 31;
			paginator.arrowRight.y = y - 54;
			
			paginator.x = int((settings.width - paginator.width) / 2 - 20);
			paginator.y = int(settings.height - paginator.height - 39);
			//paginator.filters = [new DropShadowFilter(1,-90,0xd56d2f,1,1,1,2,1,false)];
		}
		
		override public function contentChange():void
		{
			for each (var _item:TabItem in _items)
			{
				bodyContainer.removeChild(_item);
				_item = null;
			}
			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			
			_items = new Vector.<TabItem>();
			var Ys:int = 98;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:TabItem = new TabItem(settings.content[i], this);
				
				if (settings.content[i].info.expire.end < App.time)
				{
					item._makeBetBttn.visible = false;
					item.timer = false;
				}
						
				bodyContainer.addChild(item);
				_items.push(item);
				item.x = (settings.width - item.background.width) / 2;
				item.y = Ys - 5;
				Ys += 232;
			}
			App.user.auction.auctionWindowOpening = false;
		}
		
		public function refresh():void
		{
			App.user.auction.init(onRefresh);
		}
		
		private function createContent(tab:String):void
		{
			settings.content = [];
			if (_auction.hasOwnProperty(tab))
			{
				for each (var contentItem:* in _auction[tab])
				{
					if(contentItem.info.enabled == "1")
						settings.content.push(contentItem);
				}
			}
		}
		
		private function drawTabs():void
		{
			
			var menuSettings:Object = {
				"activeItems": {order: 4, title: Locale.__e("flash:1503587578521")},//Действующие
				"closedItems": {order: 6, title: Locale.__e("flash:1503587635913")}//Завершенные
			}
			
			var menuItems:Object = {
				"activeItems":{selected:true},
				"closedItems":{}
			}
			
			for (var item:String in menuItems)
			{
				if (menuSettings[item] == undefined) continue;
				var settings:Object = menuSettings[item];
				settings['type'] = item;
				settings['onMouseDown'] = onMenuBttnSelect;
				
				if (settings)
				{
					settings["bgColor"] = [0xce934f, 0xce934f];
					settings["height"] = 65;
					settings["radius"] = 15;
					settings["width"] = (item == 'activeItems') ? 157 : 152;
					settings["bevelColor"] = [0xf8c07d, 0xce934f];
					settings["captionOffsetY"] = -5;
					settings["fontSize"] = 30;
					settings["fontBorderColor"] = 0x7f3d0e;
					settings['active'] = {bgColor: [0xfad7b5, 0xfad7b5], borderColor: [0xb96f2d/*0x7f3d0e*/], height: 50, bevelColor: [0xffffff, 0xfad7b5], fontBorderColor: 0x7f3d0e}
				}
				
				var icon:MenuButton = new MenuButton(settings);
				if (menuItems[item].hasOwnProperty('selected') && menuItems[item].selected == true)
				{
					icon.selected = true;
					_lastChangeTab = item;
					createContent(item);
				}
				_icons.push(icon);
			}
			_icons.sortOn("order");
			
			var sprite:Sprite = new Sprite();
			
			var offset:int = 0;
			for (var i:int = 0; i < _icons.length; i++)
			{
				_icons[i].x = offset;
				
				offset += _icons[i].settings.width + 12;
				sprite.addChild(_icons[i]);
			}
			layer.addChild(sprite);
			layer.swapChildren(sprite, _backIcon);
			sprite.filters = [new GlowFilter(0x7f3d0e, 1, 2, 2, 2, 1, true)];
			sprite.x = 52;
			sprite.y = 60;
		}
		
		private function onRefresh():void
		{			
			_auction = App.user.auction;
			createContent(_lastChangeTab);
			contentChange();
		}
		
		private function onMenuBttnSelect(e:MouseEvent):void
		{
			for each(var icon:MenuButton in _icons)
				icon.selected = false;
			e.currentTarget.selected = true;
			_lastChangeTab = e.currentTarget.type;
			refresh();
		}
	}
}

import buttons.Button;
import buttons.MoneyButton;
import com.greensock.TweenMax;
import core.Load;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;

internal class TabItem extends LayerX
{
	public var background:Shape = new Shape();
	public var _makeBetBttn:MoneyButton;
	
	private static var _STARTPOS:int = 33;
	private var item:*;
	private var _window:*;
	private var _timer:Boolean = true;
	private var _timerField:TextField;
	
	public function TabItem(item:*, window:*):void
	{
		this.item = item;
		this._window = window;
		
		background.graphics.beginFill(0xf0e9e0, .7);
		background.graphics.drawRect(0, 0, 490, 210);
		background.y = 2;
		background.x = 0;
		background.graphics.endFill();
		background.filters = [new BlurFilter(20, 0, 4)];
		addChild(background);
		
		var separator:Bitmap = Window.backingShort(490, "dividerLine");
		separator.x = 0;
		separator.y = 2;
		addChild(separator);
		
		var tabTextLabel:TextField = Window.drawText(item.info.object.title, {width: 280, fontSize: 28, textAlign: "center", color: 0xffdf34, borderColor: 0x7f3d0e, multiline: true, wrap: true});
		tabTextLabel.x = (background.x + (background.width / 2)) - 140;
		tabTextLabel.y = -13;
		addChild(tabTextLabel);
		
		var lotPreview:Bitmap = new Bitmap();
		addChild(lotPreview);
		Load.loading(Config.getImage('auction', item.info.backview, 'jpg'), function(data:Bitmap):void
		{
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0xfff7e5, 1);
			bg.graphics.drawRoundRect(0, 0, 170, 130, 25, 25);
			bg.graphics.endFill();
			bg.filters = [new DropShadowFilter(2, 90, 0xab9f8f, 0.8, 1.0, 4.0, 2.0, 5, false, false, false)];
			bg.x = background.x - 7;
			bg.y = background.y - 2;
			addChild(bg);
			
			lotPreview.bitmapData = data.bitmapData;
			Size.size(lotPreview, 161, 128);
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawRoundRect(0, 0, 161, 124, 25, 25);
			shape.graphics.endFill();
			shape.x = background.x;
			shape.y = background.y;
			lotPreview.mask = shape;
			lotPreview.x = shape.x - 4;
			lotPreview.y = shape.y + 2;
			lotPreview.cacheAsBitmap = true;
			shape.cacheAsBitmap = true;
			
			addChild(lotPreview);
			addChild(shape);
			addChild(tabTextLabel);
		});
		
		var textDescriptionLot:String = item.info.description;
		var descriptionLot:TextField = Window.drawText(item.info.description, {
			fontSize: 22, textAlign: "center", textLeading: -3, color: 0x7e3e13, border: false, multiline: true, wrap: true, width: 325});
		
		var _textCont:LayerX = new LayerX();
		_textCont.cacheAsBitmap = true;
		_textCont.addChild(descriptionLot);
		_textCont.x = 175;
		_textCont.y = 27;
		addChild(_textCont)

		var _currentLeaderLabel:TextField = Window.drawText(Locale.__e('flash:1503590643028'), {width: 150, fontSize: 28, textAlign: "center", color: 0xffffff, borderSize:4, borderColor: 0x7f3d0e, multiline: true, wrap: false});
		_currentLeaderLabel.x = 0;
		_currentLeaderLabel.y = 110 + _currentLeaderLabel.textHeight;
		addChild(_currentLeaderLabel);
		
		var textCurentLeader:String = "";
		if (item.data.winner.hasOwnProperty('aka'))
			textCurentLeader = item.data.winner.aka;
			
		var _currentLeader:TextField = Window.drawText(textCurentLeader, {width: 150, fontSize: 22, textAlign: "center", color: 0x7e3e13, borderSize:0,/* borderColor: 0x5b3c06,*/ multiline: true, wrap: false});
		_currentLeader.width = _currentLeader.textWidth + 5;
		_currentLeader.x = _currentLeaderLabel.x + _currentLeaderLabel.width;
		_currentLeader.y = 118 + _currentLeaderLabel.textHeight;
		addChild(_currentLeader);
		var currentBetLabel:TextField = Window.drawText(Locale.__e('flash:1503590729780'), {width: 150, fontSize: 28, textAlign: "center", color: 0xffffff, borderSize:4, borderColor: 0x7f3d0e, multiline: true, wrap: false});
		currentBetLabel.x = 0;
		currentBetLabel.y = 122 + currentBetLabel.textHeight*2;
		addChild(currentBetLabel);
		
		//var coinsIcon:Bitmap = new Bitmap(UserInterface.textures.blueCristal, "auto", true);
		var coinsIcon:Bitmap;
		if (item.info.price_sid == 2)
			coinsIcon = new Bitmap(UserInterface.textures.goldenPearl, "auto", true);
		else
			coinsIcon = new Bitmap(UserInterface.textures.blueCristal, "auto", true);
		
		coinsIcon.x = currentBetLabel.x + currentBetLabel.width;
		coinsIcon.y = 123 + currentBetLabel.textHeight * 2;
		Size.size(coinsIcon,30,30);
		addChild(coinsIcon);
		var currentBet:TextField = Window.drawText(item.currentBet, {fontSize: 20, textAlign: "center", color: 0x7e3e13, borderSize:0,/* borderColor: 0x5b3c06,*/autoSize:'left', multiline: true, wrap: false});
		currentBet.x = coinsIcon.x + coinsIcon.width + 3;
		currentBet.y = 126 + currentBetLabel.textHeight*2;
		addChild(currentBet);
		
		drawTimer();
		drawBttns();
		
		var separator2:Bitmap = Window.backingShort(490, "dividerLine");
		separator2.x = 0;
		separator2.y = 210;
		addChild(separator2);
	}
	
	public function progress():void {
		//var auctionStart:int = item.info.expire.start;
		//var leftTime:int = App.time - auctionStart;
		//_timerField.text = TimeConverter.timeToStr(leftTime);
		
		var auctionEnd:int = item.info.expire.end;
		var leftTime:int = auctionEnd - App.time;
		if (leftTime < 0) 
		{
			leftTime = 0;
			if (_makeBetBttn)	_makeBetBttn.visible = false;
			if(_timerField) _timerField.visible = false;
		}
		_timerField.text = TimeConverter.timeToStr(leftTime);
	}

	private function drawBttns():void
	{		
		_makeBetBttn = new MoneyButton( {
			width			:150,
			height			:39,
			countText		:item.bet,
			caption			:'Поставить',
			fontSize		:24,
			boostsec		:1,
			mID				:item.info.price_sid,
			iconDY			:2,
			bevelColor		:[0x176dfd, 0x3194a7],
			bgColor			:[0xd56aff, 0x29cdff]
		});
		
		_makeBetBttn.x = background.x + background.width - _makeBetBttn.width - 18;
		_makeBetBttn.y = background.y + (background.height / 2) - (_makeBetBttn.height / 2) + 75;
		_makeBetBttn.addEventListener(MouseEvent.CLICK, onMakeBet);
		_makeBetBttn.countLabel.x -= 4;
		_makeBetBttn.countLabel.y -= 1;
		addChild(_makeBetBttn);
	}
	
	private function drawTimer():void
	{
		if (_timerField && _timerField.parent)
			_timerField.parent.removeChild(_timerField);
			
		if (_timer == true)
		{
			_timerField = Window.drawText(TimeConverter.timeToStr(127), {
					color:			0xffdf34,
					borderColor:	0x7e3e13,
					borderSize:		2,
					fontSize:		26
				});
				
			addChild(_timerField);
			_timerField.height = _timerField.textHeight;
			_timerField.width = _timerField.textWidth + 10;
			_timerField.x = background.x + background.width - _timerField.width - 45;
			_timerField.y = 136;
			//timer.filters = [new DropShadowFilter(4.0, 90, 0x713f15, 0.8, 1.0, 1.0, 1.0, 3, false, false, false), new GlowFilter(0x8d6021, .7, 4, 4, 4)];
			progress();
			App.self.setOnTimer(progress);
		}
	}
	
	private function onMakeBet(e:Event = null):void
	{
		App.user.auction.makeBet(item, item.bet, function():void {
			//_window.refresh();
		});
	}
	
	public function set timer(value:Boolean):void 
	{
		_timer = value;
		drawTimer();
	}
}