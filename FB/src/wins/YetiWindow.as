package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import units.Fatman;
	
	public class YetiWindow extends Window 
	{
		
		public static const WAIT:String = 'wait';
		public static const GONE:String = 'gone';
		public static const EAT:String = 'eat';
		private const LEFT_INDENT:int = 120;
		
		
		public var infoLabel:TextField;
		public var requiredLabel:TextField;
		public var timeDescLabel:TextField;
		public var timeLabel:TextField;
		public var rewardLabel:TextField;
		public var feedBttn:Button;
		public var image:Bitmap;
		public var boostBttn:MoneyButton;
		public var progressBar:ProgressBar;
		public var rewards:Sprite;
		public var items:Sprite;
		public var target:Fatman;
		
		public var mode:String;
		public var totalTime:int = 0;
		public var food:Object;
		public var canFeed:Boolean = false;
		public var progressBacking:Bitmap;
		
		public function YetiWindow(settings:Object = null) 
		{
			if (!settings) settings = { };
			settings['title'] = settings.title || Locale.__e('flash:1399545882426');	// 'Йети';
			settings['info'] = settings.info || Locale.__e('flash:1399545783168');		// Покорми Йети и он даст тебе алмазы.
			settings['width'] = settings.width || 440;
			settings['height'] = 500;
			settings['hasTitle'] = true
			settings["hasPaginator"] = true;
			settings["hasButtons"] = false;
			settings["itemsOnPage"] = 1;
			settings["buttonsCount"] = 3;
			settings["paginatorSettings"] = {buttonPrev:'arrow'};
			settings["hasArrows"] = true;
			target = settings['target'];

			super(settings);
			totalTime = settings.totalTime;
			mode = settings['state'];
			food = settings['food'];
			
			if (App.self.getLength(App.user.fatmanData) == 0) 
			{
				for (var id:String in settings.food)
				{
					var item:Object = App.data.storage[settings.food[id]];
					App.user.fatmanData[id] = (item);
				}
			}
		}
		
		private var boxReward:Bitmap;
		override public function drawBody():void 
		{
			drawMirrowObjs('decSeaweed', settings.width + 56, - 56, settings.height - 175, true, true, false, 1, 1, layer);
			
			var fish2:Bitmap = new Bitmap(Window.textures.decFish2);
			fish2.x = -27;
			fish2.y = 25;
			bodyContainer.addChild(fish2);
		
			var ribbon:Bitmap = backingShort(340, 'ribbonGrenn',true,1.3);
			ribbon.x = settings.width / 2 -ribbon.width / 2;			
			ribbon.y = -74;
			bodyContainer.addChild(ribbon);
			
			exit.x = settings.width - 45;
			exit.y = -15;
			
			back.graphics.beginFill(0xfee084, .9);
			back.graphics.drawRect(0, 0, 230, 140);
			back.graphics.endFill();
			back.x = (settings.width - back.width)/2;
			back.y = settings.height / 2 - back.height - 5;
			back.filters = [new BlurFilter(20, 0, 2)];
			bodyContainer.addChild(back);
			
			back2.graphics.beginFill(0xfef3ba, .9);
			back2.graphics.drawRect(0, 0, 320, 120);
			back2.graphics.endFill();
			back2.x = (settings.width - back2.width)/2;
			back2.y = settings.height / 2 + 40;
			back2.filters = [new BlurFilter(30, 0, 2)];
			bodyContainer.addChild(back2);
			
			boxReward = new Bitmap();
			switch(target.sid)
			{
				case 1135://буй
				case 2957://буй
				case 3067://горка
					boxReward = new Bitmap(Window.textures.boxTreasure);
					boxReward.x = (settings.width - boxReward.width)/2;
					boxReward.y = back.y;
					break;
				default://Остальные
					var _mid:int;
					var _treasure:* = App.data.treasures[Numbers.firstProp(target.info.barters).val.bonus][Numbers.firstProp(target.info.barters).val.bonus];
					for (var _mID:* in _treasure.item)
					{
						if (App.data.storage[_treasure.item[_mID]].type == 'Material' &&
						App.data.storage[_treasure.item[_mID]].mtype != 3 && 
						_treasure.probability[_mID])
						{
							_mid = _treasure.item[_mID];
							break;
						}
					}
					Load.loading(Config.getIcon(App.data.storage[_mid].type, App.data.storage[_mid].preview), function(data:Bitmap):void {
						boxReward.bitmapData = data.bitmapData;
						boxReward.smoothing = true;
						boxReward.x = (settings.width - boxReward.width) / 2;
						boxReward.y = back.y + (back.height - boxReward.height) / 2;
					})
			}
			
			bodyContainer.addChild(boxReward);
			
			infoLabel = Window.drawText(settings.info, {//текст из админки
				fontSize:		28,
				width:			settings.width - 160,
				color:			0x7f3d0e,
				border:			false,
				textAlign:		"center",
				multiline:		true,
				wrap:			true
			});
			infoLabel.x = (settings.width - infoLabel.width) / 2;
			infoLabel.y = 18;
			bodyContainer.addChild(infoLabel);
			
			if (mode == YetiWindow.WAIT) 
			{
				requiredLabel = Window.drawText(Locale.__e('flash:1402650129068'), {//текст из админки
					fontSize:		30,
					width:			settings.width - 160,
					color:			0x6e411e,
					borderColor:	0xffffff,
					borderSize:		2,
					textAlign:		"center",
					multiline:		true,
					wrap:			true
				});
				requiredLabel.x = (settings.width - requiredLabel.width) / 2;
				requiredLabel.y = settings.height / 2;
				bodyContainer.addChild(requiredLabel);
				
				
				
				timeDescLabel = Window.drawText(Locale.__e('flash:1386855956497'), {
					fontSize:		21,
					width:			200,
					color:			0x604729,
					borderColor:	0xf0e6c1,
					borderSize:		4,
					textAlign:		"center"
				});
				timeDescLabel.x = (settings.width - timeDescLabel.width) / 2;
				timeDescLabel.y = 60;
				//bodyContainer.addChild(timeDescLabel);
				
				timeLabel = Window.drawText(TimeConverter.timeToStr(timer), {
					fontSize:		32,
					width:			200,
					color:			0x604729,
					borderColor:	0xf7f2de,
					borderSize:		6,
					textAlign:		"center",
					multiline:		true,
					filters:		[new DropShadowFilter(2, 90, 0x604729, 1, 0, 0, 1, 1)]
				});
				timeLabel.x = (settings.width - timeLabel.width) / 2;
				timeLabel.y = 78;
				//bodyContainer.addChild(timeLabel);
				
				rewardLabel = Window.drawText(Locale.__e('flash:1382952380000'), {//награда
					fontSize:	26,
					width:		120,
					color:		0xfefefe,
					borderColor:0x624707,
					textAlign:"center"
				});
				rewardLabel.x = ((settings.width - rewardLabel.width) / 2) + 5;
				rewardLabel.y = 290;
				//bodyContainer.addChild(rewardLabel);
				
				var feedText:String = Locale.__e('flash:1382952380137');
				if (settings.target.sid == 2876) feedText = Locale.__e('flash:1382952380137');
				if (settings.target.sid == 3183) feedText = Locale.__e('flash:1382952380137');
				feedBttn = new Button( {
					width:		175,
					height:		50,
					caption:	feedText
				});
				feedBttn.x = (settings.width - feedBttn.width) / 2;
				feedBttn.y = settings.height - 65;
				bodyContainer.addChild(feedBttn);
				feedBttn.addEventListener(MouseEvent.CLICK, onInit);
				
				
				//Load.loading(Config.getImage('promo/images',target.info.view), function(data:Bitmap):void {
					//image.bitmapData = data.bitmapData;
					//image.smoothing = true;
					//image.x = -240;
					//image.y = 35;
				//})
				contentChange();
				//drawItems();
				//drawReward();
				
				//this.x += LEFT_INDENT;
			}else if (mode == YetiWindow.GONE) {
				
				/*var backing3:Bitmap = Window.backing(270, 220, 38, 'itemBacking');
				backing3.x = Math.floor((settings.width - backing3.width) / 2);
				backing3.y = 10;
				bodyContainer.addChild(backing3);*/
				
				//image = new Bitmap(new BitmapData(1, 1, true, 0), 'auto', true);
				//bodyContainer.addChild(image);
				
				/*infoLabel = Window.drawText(settings.title, {
					fontSize:	32,
					width:		settings.width,
					color:		0x604729,
					borderColor:0xf6f0c1,
					borderSize:	4,
					textAlign:	"center",
					filters:	[new DropShadowFilter(2, 90, 0x604729, 1, 0, 0, 1, 1)]
					
				});
				infoLabel.x = (settings.width - infoLabel.width) / 2;
				infoLabel.y = -30;
				bodyContainer.addChild(infoLabel);*/
				
				timeDescLabel = Window.drawText(Locale.__e('flash:1393581955601'), {
					fontSize:	30,
					width:		200,
					color:		0x6e411e,
					border:		false,
					textAlign:	"center"
				});
				timeDescLabel.x = (settings.width - timeDescLabel.width) / 2;
				timeDescLabel.y = 290;
				bodyContainer.addChild(timeDescLabel);
				
				progressBacking = Window.backingShort(275, "backingOne");
				progressBacking.x = (settings.width - 290) / 2 + 9;
				progressBacking.y = 330;
				bodyContainer.addChild(progressBacking);
				progressBar = new ProgressBar( { win:this, width:271, timerX:-10} );
				progressBar.x = progressBacking.x - 15;
				progressBar.y = progressBacking.y - 12;
				bodyContainer.addChild(progressBar);
				progressBar.start();
				update();
				
				boostBttn = new MoneyButton( {
					width:			(App.lang=='de')?230:190,
					height:			60,
					countText:		App.data.storage[target.sid].skip,		// Fants
					caption:		Locale.__e('flash:1382952380021'),
					fontSize:		32,
					fontCountSize:	32,
					radius:			28
				});
				boostBttn.x = (settings.width - boostBttn.width) / 2;
				boostBttn.y = 410;
				bodyContainer.addChild(boostBttn);
				boostBttn.addEventListener(MouseEvent.CLICK, onBoost);
				
				/*Load.loading(Config.getImage('promo/images',target.info.view), function(data:Bitmap):void {
					image.bitmapData = data.bitmapData;
					image.scaleX = image.scaleY = 0.5;
					image.smoothing = true;
					image.x = backing3.x + Math.floor((backing3.width - image.width) / 2);
					image.y = backing3.y + Math.floor((backing3.height - image.height) / 2);
				})*/
			}
			
			if (totalTime == 0) {
				timeDescLabel.visible = false;
				timeLabel.visible = false;
				infoLabel.y = (75 - infoLabel.height * 0.5) - 40;
			}
			
			App.self.setOnTimer(update);
		}
		override public function drawBackground():void 
		{
				background = backing(settings.width, settings.height , 50, 'workerHouseBacking');
				var background2:Bitmap  = backing(settings.width - 70, settings.height - 64, 40, 'paperClear');
				
				background2.x = background.x + (background.width - background2.width) / 2;
				background2.y = background.y + (background.height - background2.height) / 2;
				layer.addChildAt(background, 0);
				layer.addChildAt(background2, 1);
		}
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 38,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x4b7915,			
				borderSize 			: 3,					
				shadowColor			: 0x085c10,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center'
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -26;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		public function onInit(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			feedBttn.state = Button.DISABLED;
			
			Post.send( {
				id:		target.id,
				uID:	App.user.id,
				sID:	target.sid,
				wID:	App.user.worldID,
				bID:	currMaterial.key,
				act:	'init',
				ctr:	'Fatman'
			}, function(error:int, data:Object, params:Object):void {
				feedBttn.state = Button.NORMAL;
				if (error) return;
				
				App.user.stock.takeAll(data.__take);
				target.crafted = data.time;
				
				App.self.setOnTimer(target.timer);
				target.init();
				/*var rewards:Object = { };
				for (var s:String in App.data.storage[food.sID].reward) {
					rewards[s] = App.data.storage[food.sID].reward[s] + food.margin;
				}
				App.user.stock.addAll(rewards);
				
				take(rewards, feedBttn);
				
				if (totalTime <= 0) {
					target.updateData();
				}else{
					target.serverTime = App.time - totalTime;
					target.init(YetiWindow.EAT);
				}*/
				
				close();
			});
		}

		public function onFeed(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			feedBttn.state = Button.DISABLED;
			
			Post.send( {
				id:		target.id,
				uID:	App.user.id,
				sID:	target.sid,
				wID:	App.user.worldID,
				iID:	currMaterial.sid,
				act:	'storage',
				ctr:	'Fatman'
			}, function(error:int, data:Object, params:Object):void {
				feedBttn.state = Button.NORMAL;
				if (error) return;
				
				App.user.stock.takeAll(food.need);
				
				var rewards:Object = { };
				for (var s:String in App.data.storage[food.sID].reward) {
					rewards[s] = App.data.storage[food.sID].reward[s] + food.margin;
				}
				App.user.stock.addAll(rewards);
				
				take(rewards, feedBttn);
				
				if (totalTime <= 0) {
					target.updateData();
				}else{
					target.serverTime = App.time - totalTime;
					target.init(YetiWindow.EAT);
				}
				
				close();
			});
		}
		public function onBoost(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			boostBttn.state = Button.DISABLED;
			
			var that:* = this;
			
			Post.send( {
				id:		target.id,
				uID:	App.user.id,
				sID:	target.sid,
				wID:	App.user.worldID,
				act:	'boost',
				ctr:	'Fatman'
			}, function(error:int, data:Object, params:Object):void {
				boostBttn.state = Button.NORMAL;
				if (error) return;
				
				//Hints.minus(Stock.FANT, App.data.storage[target.sid].skip, Window.localToGlobal(boostBttn), false, that);
				
				App.user.stock.take(Stock.FANT, App.data.storage[target.sid].skip);
				target.crafted = App.time;
				close();
				//target.parseData(data);
				//target.init();
			});
		}
		
		private function take(items:Object, target:*):void {
			for(var i:String in items) {
				var item:BonusItem = new BonusItem(uint(i), items[i]);
				var point:Point = Window.localToGlobal(target);
				item.cashMove(point, App.self.windowContainer);
			}
		}
		public function get timer():int {
			var time:int = target.crafted - App.time;
			if (time < 0) time = 0;
			return time;
		}
		public function update():void {
			if (mode == YetiWindow.WAIT) {
				timeLabel.text = TimeConverter.timeToStr(timer);
			}else if (mode == YetiWindow.GONE) {
				progressBar.time = timer;
				progressBar.progress = (totalTime - timer) / totalTime;
			}
		}
		
		
		/*public function drawItems():void {
			if (items) {
				while (items.numChildren > 0) {
					var item:YetiItem = items.getChildAt(0) as YetiItem;
					item.dispose();
					items.removeChild(item);
				}
			}
			items = new Sprite();
			
			//var requires:Object = App.data.storage[food.sID].require;
			var requires:Object = food;
			
			var index:int = 0;
			canFeed = true;
			for (var s:String in requires) {
				var require:YetiItem = new YetiItem( {
					window:	this,
					sid:	s,
					need:	requires[s],
					width:	120
				});
				
				require.x = 130 * index;
				items.addChild(require);
				index++;
				
				if (require.info.diff > 0) canFeed = false;
			}
			
			items.x = (settings.width - index * 130) / 2 + 10;
			items.y = 120;
			bodyContainer.addChild(items);
			
			feedBttn.visible = canFeed;
		}*/
		private var currMaterial:Object;
		private var background:Bitmap;
		private var back:Shape = new Shape();
		private var back2:Shape = new Shape();
		override public function contentChange():void 
		{
			if (items) 
			{
				while (items.numChildren > 0) 
				{
					var item:YetiItem = items.getChildAt(0) as YetiItem;
					item.dispose();
					items.removeChild(item);
				}
			}
			items = new Sprite();
			
			//var requires:Object = App.data.storage[food.sID].require;
			var requires:Object = settings.content;
			
			var index:int = 0;
			canFeed = true;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
			//for (var s:String in requires){
				/*index = i;
				if (index < 0)
					index = 0;*/
				currMaterial = new Object();
				currMaterial = Numbers.getProp(requires, i).val;
				var require:YetiItem = new YetiItem( {
					window:	this,
					sid:	currMaterial.bart.sid,
					need:	currMaterial.bart.count,
					width:	120
				});
				
				require.x = 130 /** index*/;
				items.addChild(require);
				//index++;
				
				if (require.info.diff > 0) canFeed = false;
			}
			
			items.x = 30;
			items.y = back2.y + 40;
			bodyContainer.addChild(items);
			
			feedBttn.visible = canFeed;
			
			//sections[settings.section].page = paginator.page;
			//settings.page = paginator.page;			
		}
		
		override public function drawArrows():void 
		{
			if (mode == YetiWindow.WAIT) 
			{
				paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -.7, scaleY:.7 } );
				paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:.7, scaleY:.7 } );
				
				var y:Number = (settings.height - paginator.arrowLeft.height) / 2;
				paginator.arrowLeft.x = -paginator.arrowLeft.width / 2 + 86;
				paginator.arrowLeft.y = 325;
				
				paginator.arrowRight.x = settings.width - paginator.arrowRight.width / 2 - 26;
				paginator.arrowRight.y = 325;
			}
		}
		
		private function drawReward():void {
			if (rewards) {
				while (rewards.numChildren > 0) {
					rewards.removeChildAt(0);
				}
			}
			rewards = new Sprite();
			
			var index:int = 0;
			for (var s:String in App.data.storage[food.sID].reward) {
				var info:Object = App.data.storage[s];
				
				var reward:PresentItem = new PresentItem(Config.getIcon(info.type, info.view), App.data.storage[food.sID].reward[s] + food.margin, {
					bitmapSize:	46,
					textX:		56,
					textY:		4,
					fontSize:	40,
					borderSize:	5,
					color:		0xfefefe,
					borderColor:0x40322a,
					info: 		info
				} );//сколько монет
				
				
				
				reward.x = (90 * index) + 10;
				reward.y += 10;
				rewards.addChild(reward);
				index++;
			}
			
			rewards.x = (settings.width - rewards.numChildren * 90) / 2;
			rewards.y = 322;
			bodyContainer.addChild(rewards);
		}
		
		override public function dispose():void {
			if (feedBttn && feedBttn.hasEventListener(MouseEvent.CLICK)) feedBttn.removeEventListener(MouseEvent.CLICK, onInit);
			App.self.setOffTimer(update);
			
			super.dispose();
		}
		
		public static function bonus(sid:*, from:DisplayObject, to:DisplayObject, container:DisplayObject, sett:Object = null):void {
			if (!sett) sett = { };
			sett = sett['position'] || 'center'; // center,begin
			
			
		}
	}

}



import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.geom.Point;
import ui.Hints;
import wins.Window;
import wins.ShopWindow;
import flash.display.Bitmap;
import flash.text.TextField;

internal class YetiItem extends LayerX
{
	public var titleLabel:TextField;
	public var attitudeLabel:TextField;
	public var buyBttn:MoneyButton;
	public var bitmap:Bitmap;
	private var searchBttn:Button;
	
	public var info:Object;
	
	public function YetiItem(info:Object) { // sid, need
		
		tip = function():Object {
			return {
				title:		App.data.storage[info.sid].title,
				text:		App.data.storage[info.sid].description
			}
		}
		
		this.info = info;
		
		bitmap = new Bitmap(new BitmapData(1, 1, true, 0));
		addChild(bitmap);
		
		titleLabel = Window.drawText(Locale.__e(App.data.storage[info.sid].title), {//название материала
			fontSize:	22,
			width:		info.width,
			color:		0xf2eee0,
			borderColor:0x804f30,
			borderSize:	4,
			textAlign:	"center",
			wrap:		true,
			multiline:	true
		});
		titleLabel.x = (info.width - titleLabel.width) / 2;
		titleLabel.y = -45;
		addChild(titleLabel);
		
		attitudeLabel = Window.drawText(setAttitude(), {//сколько материала
			fontSize:	35,
			width:		info.width,
			color:		(info.have < info.need) ? 0xfe806d : 0xffffff,
			borderColor:0x41332a,
			borderSize:	4,
			textAlign:	"center"
		});
		//attitudeLabel.color = (info.have < info.need) ? 0xfe806d : 0xace53e;
		attitudeLabel.x = (info.width - attitudeLabel.width) / 2;
		//attitudeLabel.y = (info.have < info.need) ? 95 : 118;
		attitudeLabel.y = 45;
		addChild(attitudeLabel);
		
		searchBttn = new Button({
					caption			:Locale.__e("flash:1407231372860"),
					fontSize		:15,
					radius      	:10,
					fontColor		:0xffffff,
					fontBorderColor	:0x435060,
					bgColor			:[0xbaf76e,0x68af11],
					borderColor		:[0xa0d5f6, 0x3384b2],
					bevelColor		:[0xd8e7ae, 0x4f9500],
					width			:94,
					height			:30,
					fontSize		:15
				});
				
		searchBttn.x = 15;
		searchBttn.y = 85;
		
		searchBttn.addEventListener(MouseEvent.CLICK, onSearchEvent);
		addChild(searchBttn);
		searchBttn.visible = (info.have < info.need) ? true : false;
		
		searchBttn.tip = function():Object {
			return {
				title:"",
				text:Locale.__e("flash:1407231372860")
			};
		}
		
		buyBttn = new MoneyButton( {
			width:			110,
			height:			38,
			countText:		App.data.storage[info.sid].price[Stock.FANT] * info.diff
		});
		buyBttn.x = 5;
		buyBttn.y = 116;
		buyBttn.countLabel.x -= 5;
		addChild(buyBttn);
		buyBttn.visible = (info.have < info.need) ? true : false;
		buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
		
		Load.loading(Config.getIcon(App.data.storage[info.sid].type, App.data.storage[info.sid].view), function(data:Bitmap):void {
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			bitmap.width = info.width - 20;
			bitmap.scaleY = bitmap.scaleX = 0.9;
			bitmap.x = (120 - bitmap.width) / 2;
			bitmap.y = (20 + (120 - bitmap.height) / 2) - 57;
		});
	}
	
	public function onSearchEvent(e:MouseEvent):void {
		ShopWindow.findMaterialSource(info.sid);
		info.window.close();		
	}
	public function onBuy(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		e.currentTarget.state = Button.DISABLED;
		
		App.user.stock.buy(info.sid, info.diff, onBuyEvent);
	}
	private function onBuyEvent(price:int):void {
		buyBttn.mode = Button.NORMAL;
		
		//Hints.minus(Stock.FANT, App.data.storage[info.sid].real * info.diff, Window.localToGlobal(buyBttn), false, info.window);
		
		var items:Object = { };
		items[info.sid] = info.diff;
		take(items);
		attitudeLabel.text = setAttitude();
		buyBttn.visible = (info.have < info.need) ? true : false;
		info.window.contentChange();
	}
	
	private function take(items:Object):void {
		for(var i:String in items) {
			var item:BonusItem = new BonusItem(uint(i), items[i]);
			var point:Point = Window.localToGlobal(buyBttn);
			item.cashMove(point, App.self.windowContainer);
		}
	}
	
	private function setAttitude():String {
		info['have'] = App.user.stock.count(info.sid);
		info['diff'] = (info.need > info.have) ? (info.need - info.have) : 0;
		return Locale.__e('flash:1442930152251', [info.have, info.need]);
	}
	
	public function dispose():void {
		while (this.numChildren > 0) this.removeChildAt(0);
		buyBttn.removeEventListener(MouseEvent.CLICK, onBuy);
		searchBttn.removeEventListener(MouseEvent.CLICK, onSearchEvent);
	}
}



internal class PresentItem extends LayerX {
	
	public var count:TextField;
	public var info:Object;
	

	function PresentItem(url:String, text:String, sett:Object) {
		info = sett.info;
		var preload:Preloader = new Preloader();
		preload.x = sett.bitmapSize / 2;
		preload.y = sett.bitmapSize / 2;
		preload.width = sett.bitmapSize;
		preload.height = sett.bitmapSize;
		addChild(preload);
		
		tip = function():Object {
			return { title:info.title, text:info.description };
		}
		
		Load.loading(url, function(data:*):void {
			removeChild(preload);
			var bitmap:Bitmap = new Bitmap(data.bitmapData, 'auto', true);
			bitmap.x = 2;
			bitmap.y = 0;
			bitmap.width = sett.bitmapSize;
			bitmap.scaleY = bitmap.scaleX;
			addChild(bitmap);
		});
		
		count = Window.drawText(text, {
			fontSize:		sett.fontSize || 18,
			color:			sett.color || 0xffe04f,
			borderColor:	sett.borderColor || 0xa56a09,
			borderSize:		sett.borderSize || 2,
			multiline:		false,
			letterSpacing:	1
		});
		count.x = sett.textX || 36;
		count.y = sett.textY || 4;
		count.width = count.textWidth + 4;
		count.height = count.textHeight + 2;
		addChild(count);
	}
}