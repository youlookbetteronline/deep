package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.RedisManager;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import ui.Hints;
	import units.Ahappy;
	import wins.elements.MaterialBox;
	
	public class AhappyAuctionWindow extends Window 
	{
		public const buyCount:int = 10;
		
		private var currencyCont:Sprite;
		private var currencyIcon:Bitmap;
		private var currencyLabel:TextField;
		private var timerCont:Sprite;
		private var timerIcon:Bitmap;
		private var back:Bitmap = new Bitmap();
		private var timerLabel:TextField;
		private var auctionCont:Sprite;
		private var inputCont:Sprite;
		private var materialBox:MaterialBox;
		private var sendBttn:Button;
		private var sendAllBttn:Button;
		private var buyBttn:MoneyButton;
		private var users:Array = [];
		private var buyCont:LayerX;
		private var sendMode:int = 0;
		private var takeLabel:TextField;
		private var takeBttn:Button;
		
		public var complete:Boolean = false; // Аукцион завершен
		public var auctionList:Vector.<AhappyAuctionItem> = new Vector.<AhappyAuctionItem>;
		public var finished:int = 0;
		public var currency:*;
		public var currencyCount:int = 0;
		public var energyPrice:int = 0;
		public var energySID:int = 0;
		public var currencyInfo:Object;
		public var onlineCounter:int = 0;
		public var auctionID:*;
		public var auction:Object;
		public var auctionInfo:Object;
		public var unit:*;
		public var descTimerLabel:TextField;
		public var buyCountBack:Shape = new Shape();
		
		public function AhappyAuctionWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] || 625;
			settings['height'] = settings['height'] || 645;
			settings['title'] = settings['title'] || '';
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			
			unit = settings.target;
			auction = settings.auction;
		   
			for (var aid:* in App.user.auctions) 
			{
				if (App.user.auctions[aid].room == auction.room) 
				{
					auctionID = aid;
				}
			}
			
			for (currency in settings.currency) break;
			currencyCount = settings.currency[currency];
			currencyInfo = Storage.info(currency);
			finished = auction.started + unit.auctionTime;
			
			auctionInfo = App.data.storage[auction.aid];
			
			// Поиск Энергии с выходным материало currency
			for (var s:* in App.data.storage) 
			{
				if (App.data.storage[s].type != 'Energy') continue;
				if (App.data.storage[s].out == currency)
				{
					for (var pr:* in App.data.storage[s].price) 
					{
						energyPrice = App.data.storage[s].price[pr];
						break;
					}
					energySID = s;
					break;
				}
			}
			
			super(settings);
			
			if (finished > 0)
			{
				App.self.setOnTimer(timer);
			}
			
			// Создание и поддеожание соединения; обслуживание иконки
			App.user.initAuction();
			
			if (Ahappy.entered) 
			{
				var interval:int = setInterval(function():void {
					if (!RedisManager.connecting) return;
					clearInterval(interval);
					RedisManager.publish(auction.room, JSON.stringify( { sid:settings.target.sid, uid:App.user.id, act:'connect', photo:App.user.photo, aka:App.user.aka, level:App.user.level } ) );
					Ahappy.entered = false;
				}, 1000);
			}
			
			unit.updateAuctionView(function(auction:Object):void {
				this.auction = auction;
				updateState();
			}, auction.aid, auction.room);
		}
		
		public function timer():void 
		{
			if (!complete)
			{
				if (App.time > finished)
				{
					complete = true;
					drawComplete();
				}else if (timerLabel)
				{
					timerLabel.text = TimeConverter.timeToStr(finished - App.time);
				}
			}
			
			if (preEndBlock) 
			{
				if (sendBttn.mode == Button.NORMAL || sendAllBttn.mode == Button.NORMAL)
				{
					sendBttn.state = Button.DISABLED;
					sendAllBttn.state = Button.DISABLED;
				}
			}
			
			if (--onlineCounter < 0) 
			{
				onlineCounter = 10;
				RedisManager.publish(auction.room, JSON.stringify( { sid:settings.target.sid, uid:App.user.id, act:'online' } ) );
			}
			
			updateOnline();
		}
		
		public function get preEndBlock():Boolean
		{
			return (App.time >= finished - 5);
		}		
		
		public function updateState():void 
		{
			if (currencyLabel)
				currencyLabel.text = App.user.stock.count(currency).toString();
			
			drawUsers();
			materialBox.update();
			
			if (materialBox.all > 0 && !preEndBlock)
			{
				sendBttn.state = Button.NORMAL;
				sendAllBttn.state = Button.NORMAL;
			}
		}
		
		override public function drawBody():void 
		{
			exit.y -= 20;
			titleLabel.y -= 10;
			
			drawMirrowObjs('storageWoodenDec', -10, settings.width, settings.height - 110);
			drawMirrowObjs('storageWoodenDec', -10, settings.width, 35, false, false, false, 1, -1);
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, titleLabel.y - 35, true, true);
			
			drawCurrency();
			drawTimer();
			drawUsers();
			drawInputs();
		}
		
		// Currency
		private function drawCurrency():void 
		{
			currencyCont = new Sprite();
			currencyCont.x = 60;
			currencyCont.y = 0;
			bodyContainer.addChild(currencyCont);
			
			var back:Bitmap = Window.backingShort(110, "workerHouseCounter", true);
			back.x -= 20;
			back.y -= 20;
			currencyCont.addChild(back);
			
			currencyIcon = new Bitmap();
			currencyCont.addChild(currencyIcon);
			
			currencyLabel = drawText(App.user.stock.count(currency).toString(), {
				width:			80,
				textAlign:		'left',
				fontSize:		32,
				borderSize:		4,
				borderColor:	0x8f532f,
				color:			0xffffff
			});
			currencyLabel.x = 35;
			currencyLabel.y = back.y + back.height * 0.5 - currencyLabel.height * 0.5 + 7;
			currencyCont.addChild(currencyLabel);
			if (!currencyInfo) return;
			
			Load.loading(Config.getIcon(currencyInfo.type, currencyInfo.preview), function(data:Bitmap):void {
				currencyIcon.bitmapData = data.bitmapData;
				currencyIcon.smoothing = true;
				
				Size.size(currencyIcon, 40, 40);
				
				currencyIcon.x = -10;
				currencyIcon.y = back.y + back.height * 0.5 - currencyIcon.height * 0.5;
			});
		}
		
		private function drawTimer():void 
		{
			timerCont = new Sprite();
			bodyContainer.addChild(timerCont);
			
			descTimerLabel = drawText(Locale.__e('flash:1481099538003') + ": ", {//Осталось времени
				autoSize:		'left',
				fontSize:		24,
				color:			0xfffcdf,
				borderColor:	0x793b26
			});
			
			descTimerLabel.x = -60;
			descTimerLabel.y = -5;
			timerCont.addChild(descTimerLabel);
			
			timerLabel = drawText('', {
				width:			150,
				textAlign:		'left',
				fontSize:		32,
				color:			0xfed940,
				borderColor:	0x704c12,
				filters:		[new DropShadowFilter(4, 90, 0x000000, 0.5, 0, 0)]
			});
			
			timerLabel.x = descTimerLabel.x + descTimerLabel.width + 5;
			timerLabel.y = descTimerLabel.y - 5;
			timerCont.addChild(timerLabel);
			
			timerCont.x = 250;
			timerCont.y = 0;
		}
		
		private function drawUsers():void 
		{
			const ITEM_HEIGHT:int = 100;
			users.length = 0;
			for (var uid:* in auction.users) 
			{
				users.push( {
					uid:	uid,
					count:	auction.users[uid].count,
					time:	auction.users[uid].time,//Время входя в аукцион
					aka:	auction.users[uid].aka,
					level:	auction.users[uid].level,
					photo:	auction.users[uid].photo
				});
			}
			users.sort(unit.userSort);
			
			// Проверка на возможность анимационного перемещения
			if (!complete && checkForMove()) return;
			
			clearUsers();
			
			auctionCont = new Sprite();
			bodyContainer.addChild(auctionCont);
			
			var back:Bitmap = backing(570, 420, 50, 'buildingDarkBacking');//Внутренняя за друьями
			back.x -= 20;
			back.y -= 45;
			auctionCont.addChild(back);
			
			var rewardID:int = 4;		//D
			var rewardEqual:int = 0;
			var maximum:int = 0;
			
			if (users[0])
				maximum = users[0].count;
			
			for (var i:int = 3; i > -1; i--) 
			{
				if (users[i] && users[i].count > rewardEqual)
				{
					rewardID--;
					rewardEqual = users[i].count;
				}
				
				var item:AhappyAuctionItem = new AhappyAuctionItem(this, getUser(i), getAuctionReward(rewardID), maximum);
				item.x = -3;
				item.y = -35 + i * ITEM_HEIGHT;
				auctionCont.addChild(item);
				auctionList.unshift(item);
			}
			
			auctionCont.x = 50;
			auctionCont.y = 80;
			
			function getUser(i:int):Object
			{
				return (users.length > i) ? users[i] : null;
			}
			
			function getAuctionReward(index:int):Object 
			{
				return  (auctionInfo.devel[index].items) ?auctionInfo.devel[index].items : { };
			}
			
			function checkForMove():Boolean 
			{
				for (var i:int = 0; i < users.length; i++)
				{
					for (var j:int = 0; j < auctionList.length; j++)
					{
						if (auctionList[j].uid == users[i].uid) 
						{
							auctionList[j].order = i;
						}
					}
				}
				
				auctionList.sort(sorter);
				
				// Определение неправильной сортировки
				var tweens:Array = [];
				
				for (i = 0; i < auctionList.length - 1; i++)
				{
					// Если расположение не верно
					if (auctionList[i].y > auctionList[i + 1].y) 
					{
						// Переместить все поля пользователей в нужные координаты
						for (i = 0; i < auctionList.length; i++) 
						{
							if (auctionList[i].y != 10 + i * ITEM_HEIGHT) 
							{
								var position:int = 10 + i * ITEM_HEIGHT;
								tweens.push(TweenLite.to(auctionList[i], 0.5, { y:position, onComplete:function():void {
									// Удалить твины и перерисовать блок пользователей
									while (tweens.length)
									{
										var tween:TweenLite = tweens.shift() as TweenLite;
										tween.kill();
									}
									drawUsers();
								}} ));
							}
						}
						return true;
					}
				}
				return false;
			}
			
			function sorter(a:AhappyAuctionItem, b:AhappyAuctionItem):Number {
				if (a.order > b.order) 
				{
					return 1;
				}else if (a.order < b.order)
				{
					return -1;
				}else {
					return 0;
				}
			}
		}
		
		private function clearUsers():void
		{
			if (auctionCont) 
			{
				auctionCont.removeChildren();
				bodyContainer.removeChild(auctionCont);
				auctionCont = null;
			}
			
			while (auctionList.length) 
			{
				var item:AhappyAuctionItem = auctionList.shift();
				item.dispose();
			}
		}
		
		private function drawInputs():void 
		{
			inputCont = new Sprite();
			bodyContainer.addChild(inputCont);
			
			var stockBack:Bitmap = backing(270, 130, 55, 'buildingDarkBacking');//Слева внизу
			inputCont.addChild(stockBack);
			
			buyCont = new LayerX();
			inputCont.addChild(buyCont);
			
			var buyBack:Bitmap = backing(270, 130, 50, 'buildingDarkBacking');//Справа внизу
			buyBack.x = stockBack.x + stockBack.width + 10;
			buyCont.addChild(buyBack);
			
			var stockLabel:TextField = drawText(Locale.__e('flash:1481099602350')  + ':', {//Отправить со склада
				width:			stockBack.width,
				textAlign:		'center',
				fontSize:		25,
				color:			0xfff7e5,
				borderColor:	0x7e5831
			});
			
			stockLabel.x = stockBack.x;
			stockLabel.y = -8;
			inputCont.addChild(stockLabel);
			
			materialBox = new MaterialBox(currency, {
				backing:	'itemBackingGold'
			});
			
			materialBox.x = 20;
			materialBox.y = 20;
			inputCont.addChild(materialBox);
			
			sendBttn = new Button( {
				caption:		Locale.__e('flash:1382952380137'),//Оправить
				width:			120,
				height:			34,
				fontSize:		28
			});
			
			sendBttn.addEventListener(MouseEvent.CLICK, onSend);
			sendBttn.x = stockLabel.x + stockLabel.width - sendBttn.width - 25;
			sendBttn.y = 30;
			inputCont.addChild(sendBttn);
			
			sendAllBttn = new Button( {
				caption:		Locale.__e('flash:1481099829037'),//Оправить всё
				width:			120,
				height:			34,
				fontSize:		28
			});
			
			sendAllBttn.addEventListener(MouseEvent.CLICK, onSendAll);
			sendAllBttn.x = stockLabel.x + stockLabel.width - sendAllBttn.width - 25;
			sendAllBttn.y = sendBttn.y + sendBttn.height + 5;
			inputCont.addChild(sendAllBttn);
			
			if (materialBox.all == 0) 
			{
				sendBttn.state = Button.DISABLED;
				sendAllBttn.state = Button.DISABLED;
			}
			
			var materialBox2:MaterialBox = new MaterialBox(currency, {//Покупка
				backing:	'itemBackingGold',
				light:		true
			});
			
			materialBox2.x = buyBack.x + 20;
			materialBox2.y = 17;
			inputCont.addChild(materialBox2);
			
			buyCountBack.graphics.lineStyle(1, 0xb88a3f);
			buyCountBack.graphics.beginFill(0xd9bf82);
			buyCountBack.graphics.drawCircle(materialBox2.x + 88, materialBox2.y + 12, 16);
			inputCont.addChild(buyCountBack);
			
			var buyCountLabel:TextField = drawText(buyCount.toString(), {
				width:			50,
				textAlign:		'center',
				fontSize:		25,
				color:			0xeFFFFFF,
				borderColor:	0x875435
			});
			
			buyCountLabel.x = buyCountBack.x + 363;
			buyCountLabel.y = buyCountBack.y + 15;
			inputCont.addChild(buyCountLabel);
			
			buyBttn = new MoneyButton( {
				width:			130,
				height:			42,
				countText:		energyPrice.toString() 
			});
			
			buyBttn.addEventListener(MouseEvent.CLICK, onBuy)
			buyBttn.x = buyBack.x + buyBack.width - buyBttn.width - 18;
			buyBttn.y = (buyBack.y + buyBack.height * 0.5 - buyBttn.height * 0.5) - 5;
			inputCont.addChild(buyBttn);
			
			inputCont.x = settings.width * 0.5 - inputCont.width * 0.5;
			inputCont.y = auctionCont.y + auctionCont.height + 10 - 55;
		}
		
		public function onBuy(e:MouseEvent):void 
		{
			if (buyBttn.mode == Button.DISABLED) return;
			buyBttn.state = Button.DISABLED;
			
			var that:* = this;
			
			App.user.stock.pack(energySID, function():void {
				if (complete) return;
				
				var point:Point = BonusItem.localToGlobal(buyBttn);
				Hints.minus(Stock.FANT, energyPrice, point, false, that);
				
				App.ui.upPanel.update();
				
				if (currencyLabel) currencyLabel.text = App.user.stock.count(currency).toString();
				materialBox.update();
				
				if (materialBox.all > 0 && App.time <= finished - 5)
				{
					sendBttn.state = Button.NORMAL;
					sendAllBttn.state = Button.NORMAL;
				}
				
				buyBttn.state = Button.NORMAL;
				
				if (buyCont && buyCont.__hasGlowing)
					buyCont.hideGlowing();
			});
		}
		
		public function onSend(e:MouseEvent):void
		{
			if (materialBox.all == 0) 
			{
				buyCont.showGlowing();
				return;
			}
			
			if (sendBttn.mode == Button.DISABLED || preEndBlock) return;
			sendBttn.state = Button.DISABLED;
			sendAllBttn.state = Button.DISABLED;
			
			sendMode = 1;
			
			unit.pushAction(materialBox.count, onSendComplete);
		}
		
		public function onSendAll(e:MouseEvent):void 
		{
			if (materialBox.all == 0) 
			{
				buyCont.showGlowing();
				return;
			}
			
			if (sendAllBttn.mode == Button.DISABLED || preEndBlock) return;
			sendBttn.state = Button.DISABLED;
			sendAllBttn.state = Button.DISABLED;
			
			sendMode = 2;
			
			var allQuantity:Number = materialBox.all;
			unit.pushAction(materialBox.all, function(auction:Object):void {onSendComplete(auction, allQuantity)});
		}
		
		private function onSendComplete(auction:Object, allCount:Number = 1):void 
		{
			if (sendMode == 1 || sendMode == 2) 
			{
				var point:Point = BonusItem.localToGlobal((sendMode == 1) ? sendBttn : sendAllBttn);
				Hints.minus(currency, allCount, point, false, this);
				sendMode = 0;
			}
			
			if (auction == 'stock') 
			{
				new SimpleWindow( {
					popup:		true,
					title:		auctionInfo.title,
					height:		250,
					text:		'Не хватает материала!'//Не хватает материала
				}).show();
			}else {
				this.auction = auction;
				RedisManager.publish(auction.room, JSON.stringify( { act:'update', sid:settings.target.sid, uid:App.user.id, count:auction.users[App.user.id].count } ) );
			}
			
			updateState();
		}
		
		private function drawComplete():void
		{
			inputCont.removeChildren();
			
			var self:AhappyAuctionWindow = this;
			
			unit.updateAuctionView(function(auction:Object):void {
				auction = App.user.auctions[auctionID];
				updateState();
				
				takeLabel = drawText(Locale.__e('flash:1481099885260') + '!', {//Аукцион закончен
					width:			settings.width - 120,
					textAlign:		'center',
					fontSize:		28,
					color:			0xffffff,
					borderColor:	0x875430
				});
				
				inputCont.addChild(takeLabel);
				
				takeBttn = new Button( {
					width:			180,
					height:			46,
					color:			0xebdfb8,
					borderColor:	0x24272d,
					caption:		Locale.__e('flash:1393579618588')//Забрать награду
				});
				
				takeBttn.addEventListener(MouseEvent.CLICK, function():void {
					if (takeBttn.mode == Button.DISABLED) return;
					takeBttn.state = Button.NORMAL;
					
					settings.target.bonusAction(auction, function(bonus:Object = null):void {
						BonusItem.takeRewards(bonus, takeBttn);
						App.user.stock.addAll(bonus);
						App.ui.upPanel.update();
						
						var window:* = Window.isClass(AhappyWindow);
						window.drawAuction();
						window.drawKicks();
						
						self.close();
					});
				});
				
				takeBttn.x = takeLabel.x + takeLabel.width * 0.5 - takeBttn.width * 0.5;
				takeBttn.y = takeLabel.y + takeLabel.height + 10;
				inputCont.addChild(takeBttn);
				
				if (auction.users[App.user.id].count > 0) 
				{
					descTimerLabel.visible = false;
					timerLabel.visible = false;
				}
				
				inputCont.x = settings.width * 0.5 - inputCont.width * 0.5;
				inputCont.y = auctionCont.y + auctionCont.height + 20;
				
			}, auction.aid, auction.room);
		}
		
		public function updater(data:Object = null):void
		{
			if (!data || (data is int)) return;
			
			Log.alert((App.user.id == data.uid) ? data.uid : 'my');
			
			if (!data.hasOwnProperty('act')) return;
			
			if (Numbers.countProps(auction.users) < 4 && !auction.users[data.uid])
			{
				auction.users[data.uid] = {
					count:	0,
					photo:	data.photo,
					uid:	data.uid,
					aka:	data.aka,
					level:	data.level
				}
				unit.auction = auction;
			}
			
			switch(data.act) 
			{
				case 'connect':
					updateState();
					break;
				case 'update':
					for (var uid:String in auction.users) 
					{
						if (uid != data.uid) continue;
						auction.users[uid].count = data.count;
						unit.auction = auction;
						updateState();
						break;
					}
					updateState();
					break;
			}
		}
		
		public function get happiSid():int 
		{
			return settings.target.sid;
		}
		
		override public function close(e:MouseEvent = null):void
		{
			clearUsers();
			buyBttn.dispose();
			sendBttn.dispose();
			sendAllBttn.dispose();
			App.self.setOffTimer(timer);
			RedisManager.publish(auction.room, JSON.stringify( { sid:settings.target.sid, uid:App.user.id, act:'offline' } ) );
			super.close(e);
		}
		
		public function setOnline(uid:String, online:Boolean = true):void
		{
			// Найти пользователя и обновить его время: если online на текущее, если offline на 0
			for each(var aitem:AhappyAuctionItem in auctionList) 
			{
				if (aitem.uid == uid) 
				{
					aitem.online = (online) ? App.time : 0;
					auction.users[uid].action = aitem.online;
				}
			}
		}
		
		private function updateOnline():void
		{
			for each(var aitem:AhappyAuctionItem in auctionList) 
			{
				if (auction.users[aitem.uid] && auction.users[aitem.uid].action < App.time - 20)
					aitem.updateOnlineMarker();
			}
		}
	}

}

import core.AvaLoad;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.BevelFilter;
import flash.text.TextField;
import ui.UserInterface;
import wins.ProgressBar;
import wins.RewardListB;
import wins.Window;

internal class AhappyAuctionItem extends LayerX 
{	
	private var background:Bitmap;
	private var friendsBack:Bitmap;
	private var friendIcon:Bitmap;
	private var progressBar:ProgressBar;
	private var progressBacking:Bitmap;	
	private var akaLabel:TextField;
	private var rewardLabel:TextField;
	private var waitLabel:TextField;
	private var rewardCont:Sprite;
	private var avatarCont:Sprite;
	private var rewardList:RewardListB;
	private var onlineMarker:Shape;
	private var max:int = 50;
	private var __online:int = 0;
	private var __color:uint = 0;
	
	public var user:*;
	public var window:*;
	public var auctionID:*;
	public var auctionInfo:Object;
	public var currency:*;
	public var currencyInfo:Object;
	public var order:int = 999;
	public var maximum:int = 999;
	
	public function AhappyAuctionItem(window:*, user:Object, reward:Object, maximum:int = 0)
	{
		this.user = user;
		this.window = window;
		this.maximum = maximum;
		currency = window.currency;
		currencyInfo = Storage.info(currency);
		
		background = Window.backing(540, 100, 20, (user && user.uid == App.user.id) ? 'itemBacking' : 'itemBacking');//Друзья и ты
		addChild(background);
		
		friendsBack = new Bitmap(Window.textures.friendSlotNew);
		friendsBack.x = background.x + 15;
		friendsBack.y = background.y + background.height * 0.5 - friendsBack.height * 0.5;
		addChild(friendsBack);
		
		avatarCont = new Sprite();
		addChild(avatarCont);
		
		friendIcon = new Bitmap();
		avatarCont.addChild(friendIcon);
		
		onlineMarker = new Shape();
		onlineMarker.x = friendsBack.x + friendsBack.width - 12;
		onlineMarker.y = friendsBack.y + friendsBack.height - 13;
		onlineMarker.filters = [new BevelFilter(1, 90, 0xFFFFFF, 0.5, 0x000000, 0.3, 4, 4, 1, 1)];
		addChild(onlineMarker);
		
		akaLabel = Window.drawText(getUserName, {
			width:			300,
			textAlign:		'center',
			fontSize:		27,
			color:			0xffffff,
			borderColor:	0x6e461e
		});
		
		akaLabel.x = friendsBack.x + friendsBack.width + 16;
		akaLabel.y = 20;
		addChild(akaLabel);
		
		progressBacking = Window.backingShort(akaLabel.width + 110, "prograssBarBacking3");//прогресс бар
		progressBacking.x = akaLabel.x;
		progressBacking.y = akaLabel.y + akaLabel.height - 15;
		progressBacking.height = 45;
		progressBacking.scaleX = progressBacking.scaleY = 0.75;
		addChild(progressBacking);
		
		progressBar = new ProgressBar( {
			win:		window,
			width:		akaLabel.width + 190
		});
		
		progressBar.x = akaLabel.x - 11;
		progressBar.y = akaLabel.y + akaLabel.height - 25;
		progressBar.bar.scaleX = progressBar.bar.scaleY = 0.6; 
		progressBar.timer.x -= 90;
		progressBar.timer.y -= 5;
		addChild(progressBar);
		progressBar.start();
		
		waitLabel = Window.drawText(Locale.__e('flash:1481099961935'), {//Ожидание соперника
			width:			300,
			textAlign:		'center',
			fontSize:		26,
			color:			0x6e461e,
			border:			false
		});
		
		waitLabel.alpha = 0.8;
		waitLabel.x = background.x + background.width * 0.5 - akaLabel.width * 0.5;
		waitLabel.y = background.y + background.height * 0.5 - waitLabel.height * 0.5 + 4;
		addChild(waitLabel);
		
		rewardLabel = Window.drawText(Locale.__e('flash:1467807368649'), {//Награда
			autoSize:		'left',
			textAlign:		'left',
			fontSize:		22,
			color:			0x6f5034,
			borderColor:	0xffffff
		});
		
		rewardLabel.x = 440;
		rewardLabel.y = 10;
		addChild(rewardLabel);
		
		rewardList = new RewardListB(reward, false, 0/*, {
			itemWidth:		35,
			itemHeight:		35
		}, ''*/);
		rewardList.x = (rewardLabel.x + rewardLabel.width * 0.5 - rewardList.width * 0.5) + 15;
		rewardList.y = rewardLabel.y + rewardLabel.height - 32;
		rewardList.scaleX = rewardList.scaleY -= 0.2;
		addChild(rewardList);
		
		if (count == 0)
		{
			rewardLabel.alpha = 0.5;
			rewardList.alpha = 0.5;
		}
		
		updateState();
	}
	
	private function onLoad(data:Bitmap):void
	{
		drawAvatar(data.bitmapData); 
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, friendIcon.width, friendIcon.height, 8, 8);
		shape.graphics.endFill();
		avatarCont.mask = shape;
		avatarCont.addChild(shape);
	}
	
	private function drawAvatar(bitmapData:BitmapData):void
	{
		friendIcon.bitmapData = bitmapData;
		friendIcon.smoothing = true;
		avatarCont.x = friendsBack.x + friendsBack.width * 0.5 - friendIcon.width * 0.5;
		avatarCont.y = friendsBack.y + friendsBack.height * 0.5 - friendIcon.height * 0.5;
	}
	
	public function updateState():void 
	{
		if (user) 
		{
			new AvaLoad(user.photo, onLoad);
			akaLabel.visible = true;
			rewardLabel.visible = true;
			rewardList.visible = true;
			waitLabel.visible = false;
			progressBar.visible = true;
			progressBacking.visible = true;
			onlineMarker.visible = true;
			online = this.window.auction.users[uid]['action'];
			
			progressBar.progress = user.count / maximum;
			progressBar.timer.text = String(user.count);
		}else {
			drawAvatar(Window.textures.friendSlotNew);
			progressBar.visible = false;
			progressBacking.visible = false;
			akaLabel.visible = false;
			rewardLabel.visible = false;
			rewardList.visible = false;
			waitLabel.visible = true;
			onlineMarker.visible = false;
		}
	}
	
	public function get getUserName():String
	{
		if (user)
			return user.aka;
		
		return '';
	}
	
	public function get uid():String 
	{
		return (user) ? user.uid : null;
	}
	
	public function set count(value:int):void
	{
		if (user)
		{
			user.count = value;
		}
	}
	
	public function get count():int
	{
		return (user) ? user.count : 0;
	}
 	
	public function set online(value:int):void 
	{
		__online = value;
		updateOnlineMarker();
	}
	
	public function get online():int 
	{
		return __online;
	}
	
	public function updateOnlineMarker():void 
	{
		var color:uint = (__online >= App.time - 20 || uid == App.user.id) ? 0x00FF00 : 0x444444;
		
		if (color == __color) return;
		
		__color = color;
		
		onlineMarker.graphics.clear();
		onlineMarker.graphics.beginFill(__color, 1);
		onlineMarker.graphics.drawCircle(0, 0, 5);
		onlineMarker.graphics.endFill();
	}
	
	public function dispose():void
	{
		progressBar.dispose();
		progressBar = null;
		
		if (parent)
			parent.removeChild(this);
	}	
}