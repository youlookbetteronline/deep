package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import com.greensock.TweenLite;
	import core.Base64;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import core.RedisManager;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	//import ui.BitmapLoader;
	import ui.Hints;
	import units.Ahappy;
	import wins.elements.MaterialBox;
	
	public class AhappyRunningWindow extends Window 
	{
		
		public const buyCount:int = 10;
		
		private var currencyCont:Sprite;
		private var currencyIcon:Bitmap;
		private var currencyLabel:TextField;
		
		private var timerCont:Sprite;
		private var timerIcon:Bitmap;
		private var timerLabel:TextField;
		
		private var auctionCont:Sprite;
		private var inputCont:Sprite;
		private var materialBox:MaterialBox;
		private var sendBttn:Button;
		//private var sendAllBttn:Button;
		private var buyBttn:MoneyButton;
		
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
		
		public function AhappyRunningWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] || 790;
			settings['height'] = settings['height'] || 710;
			settings['title'] = settings['title'] || '';
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['background'] = 'hippoGreenBacking';
			
			settings['shadowSize'] = 4;
			settings['shadowColor'] = 0x611f13;
			settings["fontColor"]       = 0xfdfdfb;
			settings["fontBorderColor"]	= settings.fontBorderColor || 0xc38538;
			
			unit = settings.target;
			auction = settings.auction;
			
			for (var aid:* in App.user.auctions) {
				if (App.user.auctions[aid].room == auction.room)
					auctionID = aid;
			}
			
			for (currency in settings.currency) break;
			currencyCount = settings.currency[currency];	
			currencyInfo = Storage.info(currency);
			finished = auction.started + unit.auctionTime;
			
			auctionInfo = App.data.storage[auction.aid];
			
			// Поиск Энергии с выходным материало currency
			for (var s:* in App.data.storage) {
				if (App.data.storage[s].type != 'Energy') continue;
				if (App.data.storage[s].out == currency) {
					energyPrice = App.data.storage[s].price[Stock.FANT];
					energySID = s;
					break;
				}
			}
			
			super(settings);
			
			if (finished > 0) {
				App.self.setOnTimer(timer);
			}
			
			// Создание и поддеожание соединения; обслуживание иконки
			App.user.initAuction();
			
			if (Ahappy.entered) {
				var interval:int = setInterval(function():void {
					if (!RedisManager.connecting) return;
					
					clearInterval(interval);
					RedisManager.publish(auction.room, JSON.stringify( { sid:settings.target.sid, uid:App.user.id, act:'connect', photo:App.user.photo, aka:App.user.aka, level:App.user.level } ) );
					Ahappy.entered = false;
				}, 1000);
			}
			
			unit.updateAuctionView(function(auction:Object):void {
				this.auction = App.user.auctions[auctionID];
				updateState();
			}, auction.aid, auction.room);
		}
		
		public function timer():void {
			if (!complete) {
				if (App.time > finished) {
					complete = true;
					timerCont.visible = false;
					materialCont.visible = false;
					
					drawComplete();
					
				}else if (timerLabel) {
					timerLabel.text = TimeConverter.timeToStr(finished - App.time);
				
				}
			}
			
			//if (preEndBlock) {
				////if (sendBttn.mode == Button.NORMAL/* || sendAllBttn.mode == Button.NORMAL*/) {
					////sendBttn.state = Button.DISABLED;
					////sendAllBttn.state = Button.DISABLED;
					//timerCont.visible = false;
					//materialCont.visible = false;
					//
				//}
			//}
			
			if (--onlineCounter < 0) {
				onlineCounter = 10;
				RedisManager.publish(auction.room, JSON.stringify( { sid:settings.target.sid, uid:App.user.id, act:'online' } ) );
			}
			
			updateOnline();
		}
		
		override public function titleText(settings:Object):Sprite
		{
				var titleCont:Sprite = new Sprite();
				
				var textLabel:TextField = Window.drawText(settings.title, settings);
				if (this.settings.hasTitle == true && this.settings.titleDecorate == true) {
					drawMirrowObjs('decAhappy', textLabel.x + (textLabel.width - textLabel.textWidth) / 2 - 75, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 + textLabel.textWidth + 75, textLabel.y + (textLabel.height - 70) / 2, false, false, false, 1, 1, titleCont);
				}
				
				titleCont.mouseChildren = false;
				titleCont.mouseEnabled = false;
				titleCont.addChild(textLabel);
				
				return titleCont;
		}

		
		public function get preEndBlock():Boolean {
			return (App.time >= finished - 5);
		}
		
		public function updateState():void {
			if (currencyLabel)
				currencyLabel.text = App.user.stock.count(currency).toString();
			
			drawUsers();
			if(materialBox)
			{	
				materialBox.update();	
			
				if (materialBox.all > 0 && !preEndBlock) {
					sendBttn.state = Button.NORMAL;
					//sendAllBttn.state = Button.NORMAL;
				}
			}
		}
		
		override public function drawBody():void {
			
			exit.x -= 15;
			exit.y += 15;
			
			titleLabel.y += 25;

			drawUsers();
			
			drawTimer();
			
			drawInputs();
		}
		
		// Timer
		private function drawTimer():void {
			timerCont = new Sprite();
			bodyContainer.addChild(timerCont);
			
			var dividerTop:Bitmap = Window.backingShort(300, "dividerGreen", true);
				
				dividerTop.y =25;
				
			var dividerBottom:Bitmap = Window.backingShort(300, "dividerGreen", true);
				dividerBottom.scaleY = -1;
				dividerBottom.y = 80;
				
				
			timerCont.addChild(dividerTop);
			timerCont.addChild(dividerBottom);
			
			var descTimerLabel:TextField = drawText(Locale.__e('flash:1481888472101'), {
				width:			dividerTop.width,
				autoSize:		'center',
				fontSize:		24,
				color:			0x753507,
				border: false
			});
			descTimerLabel.x = (dividerTop.width - descTimerLabel.width) * .5;
			timerCont.addChild(descTimerLabel);
			
			timerLabel = drawText('', {
				width:			dividerTop.width,
				textAlign:		'center',
				fontSize:		44,
				color:			0xfed940,
				borderColor:	0x704c12
			});
			timerLabel.x = (dividerTop.width - timerLabel.width) * .5;
			timerLabel.y = dividerTop.y + (dividerBottom.y- timerLabel.height)/2 - 10;
			timerCont.addChild(timerLabel);
			
	
			timerCont.x = 100;
			timerCont.y = auctionCont.y + auctionCont.height;
		}
		
		// Users
		private var users:Array = [];
		private function drawUsers():void {
			const ITEM_HEIGHT:int = 106;
			
			users.length = 0;
			
			for (var uid:* in auction.users) {
				users.push( {
					uid:	uid,
					count:	auction.users[uid].count,
					time:	auction.users[uid].time,		// Время входя в аукцион
					aka:	auction.users[uid].aka,
					level:	auction.users[uid].level,
					photo:	auction.users[uid].photo
				});
			}
			users.sort(function (a:Object, b:Object):int {
				if (a.time > b.time) {
					return 1;
				}else if (a.time < b.time) {
					return -1;
				}else {
					return 0;
				}
			});
			//users.sort(unit.userSort);
			
			// Проверка на возможность анимационного перемещения
			
			//clearUsers();
			
			if (!auctionList.length){
				if (!complete && checkForMove()) return;
				
				auctionCont = new Sprite();
				bodyContainer.addChildAt(auctionCont,0);
				
				var back:Bitmap = new Bitmap(new BitmapData(520, 427, false));
				back.visible = false;
				auctionCont.addChild(back);
				Load.loading(Config.getImage('content', 'turkey_track'), function(data:*):void {
					back.bitmapData = data.bitmapData;
					back.visible = true;
				});
				back.x = 5;
				back.y = 5;
				
				var rewardID:int = 5;			//D Перевроперить
				var rewardEqual:int = 0;
				var maximum:int = 0;
				
				var users2:* = [];
				for (var item2:* in users){
					users2[item2] = users[item2];
				}
				
				users2.sort(unit.userSort);
				
				var _nk:int = 0;
				for (var i:int = 3; i > -1; i--) {
					if (users[i] && users[i].count > rewardEqual) {
						rewardID--;
						rewardEqual = users[i].count;
					}

					if (users2[i] && users2[i].uid == App.user.id)
						App.ui.leftPanel.createAhappyIcon(i + 1, auction.started + unit.auctionTime);
					
					var item:AhappyAuctionItem = new AhappyAuctionItem(this, getUser(i), getAuctionReward(rewardID), i, maximum);
					item.x = 5;
					item.y = i * (ITEM_HEIGHT-10);
					auctionCont.addChild(item);
					auctionList.unshift(item);
				}
				
				auctionCont.x = 70;
				auctionCont.y = 40;
			} else {
				rewardEqual = 0;
				maximum = 0;
				rewardID = 5;
				
				for (var j:* in users) {
					if(maximum < users[j].count) {
						maximum = users[j].count;
					}
				}
				
				users2 = [];
				for (item2 in users){
					users2[item2] = users[item2];
				}
				
				users2.sort(unit.userSort);
				
				for (i = 3; i > -1; i--) {
					if (users2[i] && users2[i].count > rewardEqual) {
						rewardID--;
						users2[i]['rewardID'] = rewardID;
						rewardEqual = users2[i].count;
					} else if (users2[i] && users2[i].count == rewardEqual) {
						users2[i]['rewardID'] = rewardID;
						rewardEqual = users2[i].count;
					}
				}
				
				for (var auctionItem:* in auctionList) {
					if(users[auctionItem]) {
						auctionList[auctionItem].user = users[auctionItem];
						auctionList[auctionItem].maximum = maximum;
						auctionList[auctionItem].reward = getAuctionReward(users[auctionItem].rewardID);
					}
					auctionList[auctionItem].updateState();
				}
			}
			
			function getUser(i:int):Object {
				return (users.length > i) ? users[i] : null;
			}
			
			function getAuctionReward(index:int):Object {
				//return  (auctionInfo.fair[index]) ? auctionInfo.fair[index].req : { };
				return  (auctionInfo.devel[index]) ?auctionInfo.devel[index].items : { };
			}
			
			function checkForMove():Boolean {
				for (var i:int = 0; i < users.length; i++) {
					for (var j:int = 0; j < auctionList.length; j++) {
						if (auctionList[j].uid == users[i].uid) {
							auctionList[j].order = i;
						}
					}
				}
				
				auctionList.sort(sorter);
				
				return false;
			}
			
			function sorter(a:AhappyAuctionItem, b:AhappyAuctionItem):Number {
				if (a.order > b.order) {
					return 1;
				}else if (a.order < b.order) {
					return -1;
				}else {
					return 0;
				}
			}
		}
		private function clearUsers():void {
			if (auctionCont) {
				auctionCont.removeChildren();
				bodyContainer.removeChild(auctionCont);
				auctionCont = null;
			}
			
			while (auctionList.length) {
				var item:AhappyAuctionItem = auctionList.shift();
				item.dispose();
			}
		}
		
		// Input
		private var buyCont:LayerX;
		private var materialCont:LayerX;
		private var _wR:int = 110;
		private function drawInputs():void {
			materialCont = new LayerX();
			bodyContainer.addChild(materialCont);
			
			
			
			inputCont = new Sprite();
			materialCont.addChild(inputCont);
			
			//var stockBack:Bitmap = backing(235, 165, 10, 'bonusBacking');
			//inputCont.addChild(stockBack);
			drawCircles(_wR / 2, _wR / 2, _wR / 2	, 0xaf8461 , inputCont);
			drawCircles(_wR / 2, _wR / 2, _wR / 2 - 3,0xe7ceaf,inputCont);
			drawCircles(_wR / 2, _wR / 2, _wR / 2 - 4, 0xaf8461 , inputCont);
			drawCircles(_wR / 2, _wR / 2, _wR / 2 - 6,0xe7ceaf,inputCont);
		
						
			buyCont = new LayerX();
			materialCont.addChild(buyCont);
			
			drawCircles(_wR / 2, _wR / 2, _wR / 2	, 0xaf8461 , buyCont);
			drawCircles(_wR / 2, _wR / 2, _wR / 2 - 3,0xe7ceaf,buyCont);
			drawCircles(_wR / 2, _wR / 2, _wR / 2 - 4, 0xaf8461 , buyCont);
			drawCircles(_wR / 2, _wR / 2, _wR / 2 - 6, 0xe7ceaf, buyCont);
			
			//var buyBack:Shape = new Shape();
			//buyBack.graphics.beginFill(0xF6E4D0, 1);
			//buyBack.graphics.drawCircle(155,55, 55);
			//buyBack.graphics.endFill();
			//buyCont.addChild(buyBack);
			
			//var stockLabel:TextField = drawText(Locale.__e('flash:1481099602350'), {
				//width:			235,
				//textAlign:		'center',
				//fontSize:		22,
				//color:			0x6e461e,
				//borderColor:	0xffffff
			//});
			//stockLabel.x = 0;
			//stockLabel.y = -8;
			//inputCont.addChild(stockLabel);
			
			materialBox = new MaterialBox(currency, {width:_wR-30, height:_wR-30,back:false/*,plusButtons:true*/});
			materialBox.x =(_wR-_wR-30)/2;
			materialBox.y = (_wR-_wR-30)/2;
			inputCont.addChild(materialBox);
			
			sendBttn = new Button( {
				caption:		Locale.__e('flash:1382952380137'),
				width:			_wR,
				height:			35,
				fontSize:		20,
				onClick:		onSend
			});
			//sendBttn.x = stockLabel.x + stockLabel.width - sendBttn.width - 15;
			sendBttn.x = (_wR - sendBttn.width)/2;
			sendBttn.y = _wR+5;
			inputCont.addChild(sendBttn);
			
			//sendAllBttn = new Button( {
				//caption:		Locale.__e('flash:1481099829037'),
				//width:			100,
				//height:			35,
				//fontSize:		20,
				//onClick:		onSendAll
			//});
			//sendAllBttn.x = stockLabel.x + stockLabel.width - sendAllBttn.width - 15;
			//sendAllBttn.y = sendBttn.y + sendBttn.height + 5;
			//inputCont.addChild(sendAllBttn);
			
			if (materialBox.all == 0) {
				sendBttn.state = Button.DISABLED;
				//sendAllBttn.state = Button.DISABLED;
			}
			//
			
			// Buy block
			var materialBox2:MaterialBox = new MaterialBox(currency, {
				width:_wR-30,
				height:_wR-30,
				back:false,
				light:		true
			});
			materialBox2.x =(_wR-_wR-30)/2;
			materialBox2.y = (_wR-_wR-30)/2;
			buyCont.addChild(materialBox2);
			
			
			var buyCountLabel:TextField = drawText(buyCount.toString(), {
				width:			50,
				textAlign:		'center',
				fontSize:		23,
				color:			0xfffcfe,
				borderColor:	0x75410f
			});
			buyCountLabel.x = (_wR- buyCountLabel.width) * 0.5;
			buyCountLabel.y = _wR-buyCountLabel.height/2-5;
			buyCont.addChild(buyCountLabel);
			
			buyBttn = new MoneyButton( {
				width:			_wR,
				height:			35,
				countText:		energyPrice.toString(),
				caption: " ",
						//fontSize	:24,
				//countText	:15,
				//multiline	:true,
				//borderColor:
				//radius:20,
				//iconScale:0.67,
				onClick:		onBuy
			});
			buyBttn.x = (_wR - buyBttn.width)/2;
			buyBttn.y = _wR+5
			buyCont.addChild(buyBttn);
			
			
			//
			buyCont.x = _wR + 20;

			materialCont.x = settings.width - materialCont.width-20;
			materialCont.y = auctionCont.y + auctionCont.height;
			
		}
		
		private function drawCircles(x:int, y:int, r:int,color:uint,container:Sprite = null):void 
		{
			var stockBack:Shape = new Shape();
			stockBack.graphics.beginFill(color, 1);
			stockBack.graphics.drawCircle(x,y, r);
			stockBack.graphics.endFill();
			if (container != null) 
					container.addChild(stockBack);
				else 
					bodyContainer.addChild(stockBack)

		}
		
		public function onBuy(e:MouseEvent):void {
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
				
				if (materialBox.all > 0 && App.time <= finished - 5) {
					sendBttn.state = Button.NORMAL;
					//sendAllBttn.state = Button.NORMAL;
				}
				
				buyBttn.state = Button.NORMAL;
				
				if (buyCont && buyCont.__hasGlowing)
					buyCont.hideGlowing();
				
			});
		}
		
		//private var sendMode:int = 0;
		public function onSend(e:MouseEvent):void {
			if (materialBox.all == 0) {
				buyCont.showGlowing();
				return;
			}
			
			if (sendBttn.mode == Button.DISABLED || preEndBlock) return;
			sendBttn.state = Button.DISABLED;
			//sendAllBttn.state = Button.DISABLED;
			
			//sendMode = 1;
			
			unit.pushAction(materialBox.count, onSendComplete);
		}
		
		//public function onSendAll(e:MouseEvent):void {
			//if (materialBox.all == 0) {
				//buyCont.showGlowing();
				//return;
			//}
			//
			//if (sendAllBttn.mode == Button.DISABLED || preEndBlock) return;
			//sendBttn.state = Button.DISABLED;
			//sendAllBttn.state = Button.DISABLED;
			//
			//sendMode = 2;
			//
			//unit.pushAction(materialBox.all, onSendComplete);
		//}
		
		private function onSendComplete(auction:Object):void {
			
			//if (sendMode == 1 || sendMode == 2) {
				var point:Point = BonusItem.localToGlobal(/*(sendMode == 1) ? */sendBttn /*: sendAllBttn*/);
				Hints.minus(currency,/* (sendMode == 1) ?*/ materialBox.count /*: materialBox.all*/, point, false, this);
				//sendMode = 0;
			//}
			
			if (auction == 'stock') {
				new SimpleWindow( {
					popup:		true,
					title:		auctionInfo.title,
					text:		Locale.__e('flash:1481117108074')
				}).show();
			}else {
				this.auction = auction;
				
				RedisManager.publish(auction.room, JSON.stringify( { act:'update', sid:settings.target.sid, uid:App.user.id, count:auction.users[App.user.id].count } ) );
			}
			
			updateState();
		}
		
		private var takeLabel:TextField;
		private var takeBttn:Button;
		private function drawComplete():void {
			//inputCont.removeChildren();
			App.ui.leftPanel.createAhappyIcon();
			close();
			return;
			
			var self:AhappyRunningWindow = this;
			
			takeLabel = drawText(Locale.__e('flash:1481099885260') + '!', {
				width:			settings.width - 120,
				textAlign:		'center',
				fontSize:		28,
				color:			0xebdfb8,
				borderColor:	0x24272d
			});
			addChild(takeLabel);

			takeLabel.x = settings.width - takeLabel.width-20;
			takeLabel.y = auctionCont.y + auctionCont.height;
			
			
			takeBttn = new Button( {
				width:			180,
				height:			46,
				caption:		Locale.__e('flash:1481038617485'),
				onClick:		function(e:MouseEvent = null):void {
					if (takeBttn.mode == Button.DISABLED) return;
					takeBttn.state = Button.DISABLED;
					
					settings.target.bonusAction(App.user.auctions[auctionID], function(bonus:Object = null):void {
						BonusItem.takeRewards(bonus, takeBttn);
						App.user.stock.addAll(bonus);
						App.ui.upPanel.update();
						
						var window:* = Window.isClass(AhappyWindow);
						window.drawAuction();
						window.drawKicks();
						
						self.close();
					});
				}
			});
			takeBttn.x = takeLabel.x + takeLabel.width * 0.5 - takeBttn.width * 0.5;
			takeBttn.y = takeLabel.y + takeLabel.height + 10;
			takeBttn.state = Button.DISABLED;
			addChild(takeBttn);
			
			var preloader:Preloader = new Preloader();
			preloader.x = takeBttn.x - 30;
			preloader.y = takeBttn.y + takeBttn.height * 0.5;
			preloader.scaleX = preloader.scaleY = 0.75
			inputCont.addChild(preloader);
			
			inputCont.x = settings.width * 0.5 - inputCont.width * 0.5;
			inputCont.y = auctionCont.y + auctionCont.height + 20;
			
			unit.updateAuctionView(function(auction:Object):void {
				takeBttn.state = Button.NORMAL;
				inputCont.removeChild(preloader);
				
				self.auction = App.user.auctions[auctionID];
				updateState();
			}, auction.aid, auction.room);
		}
		
		
		public function updater(data:Object = null):void {
			if (!data || (data is int)) return;
			
			Log.alert((App.user.id == data.uid) ? data.uid : 'my');
			
			if (!data.hasOwnProperty('act')) return;
			
			if (Numbers.countProps(auction.users) < 4 && !auction.users[data.uid]) {
				auction.users[data.uid] = {
					count:	0,
					photo:	data.photo,
					uid:	data.uid,
					aka:	data.aka,
					level:	data.level
				}
				unit.auction = auction;
			}
			
			switch(data.act) {
				case 'connect':
					updateState();
					
					break;
				case 'update':
					for (var uid:String in auction.users) {
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
		
		public function get happiSid():int {
			return settings.target.sid;
		}
		
		override public function close(e:MouseEvent = null):void {
			clearUsers();
			if(buyBttn)
				buyBttn.dispose();
			sendBttn.dispose();
			//sendAllBttn.dispose();
			
			App.self.setOffTimer(timer);
			
			RedisManager.publish(auction.room, JSON.stringify( { sid:settings.target.sid, uid:App.user.id, act:'offline' } ) );
			
			super.close(e);
		}
		
		// Online
		public function setOnline(uid:String, online:Boolean = true):void {
			
			// Найти пользователя и обновить его время: если online на текущее, если offline на 0
			for each(var aitem:AhappyAuctionItem in auctionList) {
				if (aitem.uid == uid) {
					aitem.online = (online) ? App.time : 0;
					auction.users[uid].action = aitem.online;
				}
			}
		}
		private function updateOnline():void {
			for each(var aitem:AhappyAuctionItem in auctionList) {
				if (auction.users[aitem.uid] && auction.users[aitem.uid].action < App.time - 20)
					aitem.updateOnlineMarker();
				
			}
		}
	}

}

import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.AvaLoad;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.BevelFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BlurFilter;
import flash.text.TextField;
import ui.UserInterface;
import units.Ahappy;
import units.Anime2;
import units.Anime2v2;
import units.AnimeTape;
import wins.Window;
import wins.ProgressBar;
import wins.RewardListB2;

internal class AhappyAuctionItem extends LayerX {
	
	private var background:Bitmap;
	private var friendsBack:Bitmap;
	private var friendIcon:Bitmap;
	//private var progressBar:ProgressBar;
	
	private var akaLabel:TextField;
	private var rewardLabel:TextField;
	private var waitLabel:TextField;
	private var rewardCont:Sprite;
	private var avatarCont:Sprite;
	private var rewardList:RewardListB2;
	private var onlineMarker:Shape;
	private var turkey:Anime2v2;
	
	public var user:*;
	public var window:*;
	public var auctionID:*;
	public var auctionInfo:Object;
	public var currency:*;
	public var currencyInfo:Object;
	public var order:int = 999;
	public var maximum:int = 999;
	public var reward:Object;
	public var counter:TextField;
	public var itemId:int;
	
	public function AhappyAuctionItem(window:*, user:Object, reward:Object, itemId:int, maximum:int = 0) {
		
		this.user = user;
		this.window = window;
		this.maximum = maximum;
		this.reward = reward;
		this.itemId = itemId;
		currency = window.currency;
		currencyInfo = Storage.info(currency);
		
		friendsBack = new Bitmap(Window.textures.friendSlotNew);
		friendsBack.x = 10;
		friendsBack.y = 80 - friendsBack.height * 0.5;
		addChild(friendsBack);
		Size.size(friendsBack, 80, 80);
		
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
			width:			100,
			textAlign:		'center',
			fontSize:		20,
			color:			0x6e461e,
			borderColor:	0xffffff,
			wrap:			false,
			multiline:		false
		});
		akaLabel.x = friendsBack.x + (friendsBack.width  - akaLabel.width) * .5;
		akaLabel.y = friendsBack.y - akaLabel.textHeight;
		addChild(akaLabel);
		
					
					/*progressBar = new ProgressBar( {
						win:		window,
						width:		akaLabel.width
					});
					progressBar.x = akaLabel.x;
					progressBar.y = akaLabel.y + akaLabel.height - 4;
					addChild(progressBar);
					progressBar.start();*/
					
					/*Load.loading(Config.getSwf(App.data.storage[window.happiSid].type, 'turkey_track'), function(swf:*):void{
						var track:Anime2 = new Anime2(swf);
						track.y = 76 - track.height * .5;
						addChildAt(track, 0);
					});*/
		var _link_line:String = 'line_snow';
			if (itemId % 2 > 0)
				_link_line = 'line_snow_1';			
					
		Load.loading(Config.getIcon(App.data.storage[window.happiSid].type, _link_line), function(bitmap:*):void{
			
				
			var track:units.AnimeTape = new units.AnimeTape(bitmap.bitmapData, {width:530, height: 100});
			track.x = friendsBack.x + friendsBack.width;
			//track.y = 50 - track.height * .5;
			addChildAt(track, 0);
		});
		
					/*Load.loading(Config.getSwf(App.data.storage[window.happiSid].type, 'turkey_'+String(itemId)), function(swf:*):void{
						turkey = new Anime2(swf);
						turkey.x = newPosition;
						turkey.y = 15;
						addChildAt(turkey, 1);
						
						progress();
						
						if (!user)
							turkey.visible = false;
					});*/
		
		Load.loading(Config.getSwf(App.data.storage[window.happiSid].type, 'turkey_'+String(itemId)), function(swf:*):void{		//D олень
			turkey = new Anime2v2(swf);
			turkey.x = newPosition+30;
			turkey.y = 10;
			addChildAt(turkey, 1);
			progress();
			
			//var shape:Shape = new Shape();
			//shape.graphics.beginFill(0x000000, 1);
			//shape.graphics.drawEllipse(turkey.x+9, turkey.y+turkey.height-6,	turkey.width/3, 10);
			//shape.graphics.endFill();
			
			//var blur:BlurFilter = new BlurFilter(); 
			//blur.blurX = 10; 
			//blur.blurY = 10; 
			//blur.quality = BitmapFilterQuality.MEDIUM; 
			//shape.filters = [blur];
			
			//shape.alpha = .7;
			//addChildAt(shape, 1);

			if (!user)
			{
				turkey.visible = false;
				//shape.visible = false;
			}
		});
		
				/*Load.loading(Config.getIcon(App.data.storage[window.happiSid].type, 'turkey_track'), function(data:*):void{
					var block:Bitmap = new Bitmap(data.bitmapData);
					block.x = 77;
					block.y = 118 - block.height;
					addChildAt(block, 2);
				});*/
		
		Load.loading(Config.getIcon(App.data.storage[window.happiSid].type, 'border'), function(bitmap:*):void{
			var track:units.AnimeTape = new units.AnimeTape(bitmap.bitmapData, {width:530, height: 100});
			track.x = 90;
			track.y = 45;
			addChildAt(track, numChildren);
		});
		
		Load.loading(Config.getIcon(App.data.storage[window.happiSid].type, 'turkey_flag'+String(itemId)), function(data:*):void{
			var flag:Bitmap = new Bitmap(data.bitmapData);
			flag.x = 85;
			flag.y = 110 - flag.height;
			addChildAt(flag, 3);
			
			counter = Window.drawText(String(count), {
				width:40,
				textAlign:'center',
				fontSize:28,
				color:0xfbeb50,
				borderColor:0x663821
			});
			counter.x = flag.x + 2;
			counter.y = flag.y + 2;
			addChild(counter);
			
			checkCounter();
		});
		
		waitLabel = Window.drawText(Locale.__e('flash:1481099961935'), {		//D ожидаем соперника
			width:			300,
			textAlign:		'center',
			fontSize:		26,
			color:			0x6e461e,
			borderColor:	0xffffff
		});
		waitLabel.alpha = 0.8;
		waitLabel.x = 240 - akaLabel.width * 0.5;
		waitLabel.y = 70 - waitLabel.height * 0.5 + 4;
		addChild(waitLabel);
		
		rewardLabel = Window.drawText(Locale.__e('flash:1382952380000'), {		//D награда
			autoSize:		'left',
			textAlign:		'left',
			fontSize:		22,
			color:			0x6e461e,
			borderColor:	0xffffff
		});
		rewardLabel.x = 550;
		rewardLabel.y = 10;
		addChild(rewardLabel);
			
		drawReward();
		
		if (count == 0) {
			rewardLabel.alpha = 0.5;
			rewardList.alpha = 0.5;
		}
		
		updateState();
		
	}
	
	
	
	private function checkCounter():void {
		if (!counter) return;
		
		counter.text = String(count);
	}
	
	private function drawReward():void {
		if (rewardList){
			removeChild(rewardList);
			rewardList = null;
		}
		
		rewardList = new RewardListB2(reward, false,0, {
			itemWidth:		50,
			itemHeight:		50
		}, '');
		rewardList.x = rewardLabel.x + rewardLabel.width * 0.5 - rewardList.width * 0.5;
		rewardList.y = rewardLabel.y + rewardLabel.height + 2;
		addChild(rewardList);
	}
	
	private function onLoad(data:Bitmap):void {
		drawAvatar(data.bitmapData); 
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, friendIcon.width, friendIcon.height, 8, 8);
		shape.graphics.endFill();
		avatarCont.mask = shape;
		avatarCont.addChild(shape);
	}
	private function drawAvatar(bitmapData:BitmapData):void {
		friendIcon.bitmapData = bitmapData;
		friendIcon.smoothing = true;
		avatarCont.x = friendsBack.x + friendsBack.width * 0.5 - friendIcon.width * 0.5;
		avatarCont.y = friendsBack.y + friendsBack.height * 0.5 - friendIcon.height * 0.5;
	}
	
	private var max:int = 50;
	private var avatar:AvaLoad;
	public function updateState():void {
		if (user) {
			var avatar:* = avatarCont.getChildAt(0);
			if(!avatar.bitmapData)
				new AvaLoad(user.photo, onLoad);
			
			akaLabel.visible = true;
			rewardLabel.visible = true;
			rewardList.visible = true;
			waitLabel.visible = false;
			onlineMarker.visible = true;
			online = window.auction.users[uid]['action'];
			akaLabel.text = getUserName;
			akaLabel.y = friendsBack.y - akaLabel.textHeight;
			if(turkey)
			{
				turkey.visible = true;
				//shape.visible = true;
			}
			
			drawReward();
			checkCounter();
			
			progress();
		}else {
			//drawAvatar(Window.textures.friendSlotNew);
			
			akaLabel.visible = false;
			rewardLabel.visible = false;
			rewardList.visible = false;
			waitLabel.visible = true;
			onlineMarker.visible = false;
			if(turkey)
			{
				turkey.visible = false;
				//shape.visible = false;
			}
		}
	}
	
	private function progress():void {
		if (!turkey) return;
		
		TweenLite.to(turkey, 5, { x: newPosition});
	}
	
	private function get newPosition():int {
		return 120 + (maximum ? (user && user.count ? (230 * user.count / maximum) : 0) : 0);
	}
	
	public function get getUserName():String {
		if (user)
			return user.aka;
		
		return '';
	}
	public function get uid():String {
		return (user) ? user.uid : null;
	}
	
	public function set count(value:int):void {
		if (user) {
			user.count = value;
		}
	}
	public function get count():int {
		return (user) ? user.count : 0;
	}
 	
	private var __online:int = 0;
	private var __color:uint = 0;
	public function set online(value:int):void {
		__online = value;
		updateOnlineMarker();
	}
	public function get online():int {
		return __online;
	}
	public function updateOnlineMarker():void {
		var color:uint = (__online >= App.time - 20 || uid == App.user.id) ? 0x00FF00 : 0x444444;
		
		if (color == __color) return;
		
		__color = color;
		
		onlineMarker.graphics.clear();
		onlineMarker.graphics.beginFill(__color, 1);
		onlineMarker.graphics.drawCircle(0, 0, 5);
		onlineMarker.graphics.endFill();
	}
	
	public function dispose():void {
		//progressBar.dispose();
		//progressBar = null;
		
		if (parent)
			parent.removeChild(this);
	}
	
}