package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.TimeConverter;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	
	public class FiestaWinterWindow extends Window
	{
		private var background:Bitmap;
		private var textInfo:TextField;
		private var back:Bitmap;
		private var textDay:TextField ;
		private var eventManager:Object = JSON.parse(App.data.options['EventManager']);
		private var ico:BitmapData;
		private var bttnArr:Array = new Array;	
		private var shop:Object;
		public var titleTextLabel:TextField;
		public var questsManagerBttn:Button;
		public var shopBttn:Button;
		public var rewardBttn:Button;
		public var winterShopBttn:Button;
		public var timeOfExpire:TextField;
		public var textLost:TextField;
		public var expireJson:Object;
		
		public function FiestaWinterWindow(settings:Object = null):void
		{		
			if (settings == null) {
				settings = new Object();
			}
			settings["section"] = settings.section || "all"; 
			settings["page"] = settings.page || 0; 
			settings["find"] = settings.find || null;
			settings["title"] = Locale.__e(eventManager.title);
			settings["width"] = 535;
			settings["height"] = 400;
			settings["hasPaginator"] = false;
			settings["hasArrows"] = false;
			settings["itemsOnPage"] = 0;
			settings["buttonsCount"] = 0;
			settings["background"] = 'buildingBacking';
				
			super(settings);
		}	
		
		override public function drawTitle():void 
		{
			return;
		}	
		
		public function drawMainTitle():void 
		{			
			titleTextLabel = Window.drawText(Locale.__e('flash:1447939675929'), {
				width				:350,
				fontSize			:42,
				textAlign			:"center",
				color				:0xfffeff,
				borderColor			:0x2a85be,
				border				:true,
				shadowBorderColor	:0x1743ae,
				multiline			:true,
				wrap				:true,
				strenghtShadow		:30
			});
			
			titleTextLabel.x = background.x + background.width / 2 - titleTextLabel.width / 2;
			headerContainer.y = 0;
			headerContainer.addChild(titleTextLabel);	
			titleTextLabel.y = -75;
			headerContainer.mouseEnabled = false;
		}

		override public function drawBackground():void
		{			
			background = backing(settings.width, settings.height, 50, settings.background);
			bodyContainer.addChild(background);
			background.x = -10;
			background.y = -90;
		}
		
		override public function drawBody():void 
		{
			back = backing(430, 195, 0, 'paperBackingBlue');
			back.x = background.x + background.width / 2 - back.width / 2;
			back.y = background.y + 60;
			bodyContainer.addChild(back);
			
			var back2:Bitmap = backing(140, 55, 0, 'collectionMiniBackingBlue');
			back2.x = back.x + back.width / 2  -back2.width / 2;
			back2.y = back.y + 25;
			bodyContainer.addChild(back2);
			
			textLost = Window.drawText(Locale.__e(eventManager.textLeft),{	//Осталось
				color:0xFFFFFF,
				fontSize:46,
				borderColor:0x0f4c8f,
				borderSize:4,
				width:70,
				textAlign:"center"
			});
			
			textLost.x = back.x + back.width / 2 - textLost.width / 2;
			textLost.y = back.y + 5;
			bodyContainer.addChild(textLost);
			
			textDay= Window.drawText("00:00:00", {//Дни
				color:0xfcd731,
				fontSize:50,
				borderColor:0x563317,
				borderSize:3,
				width:300,
				height:200,
				textAlign:"center"
			});
			textDay.x = back.x + back.width / 2 - textDay.width / 2;
			textDay.y = textLost.y + 40;
			//bodyContainer.addChild(textDay);
			
			drawMirrowObjs('winterCornerDecorUp', -40, settings.width + 20, -90, false, false, false, 1, 0.65, null, 0.7);			
			
			textInfo = Window.drawText(Locale.__e(eventManager.textDesc), {	
				fontSize:25,
				color:0x1c6da2,
				borderColor:0xd6f7ff,
				borderSize:1,
				multiline:true,
				wrap:true,
				width:400,
				textAlign:"center"
			});
			textInfo.height = textInfo.textHeight+8;
			textInfo.x = back.x + back.width / 2 - textInfo.width / 2;
			textInfo.y = back.y + 85;
			bodyContainer.addChild(textInfo);	
			
			Load.loading(Config.getImage('events/winter', App.data.storage[Stock.CHRISTMAS_TREE].view), onTreeLoad);
			Load.loading(Config.getImage('events/winter', 'presents'), onPresentsLoad);
			
			drawBtt();		
			
			App.self.setOnTimer(update);
			update();
			drawMainTitle();
			drawTimer();
			
			drawMirrowObjs('winterTitleDecor', settings.width / 2 - titleTextLabel.width / 2 + 60, settings.width / 2 + titleTextLabel.width / 2 - 70, -105, true, true, false, 1, 0.8, null, 0.8);
		}
		
		public var time:uint = 0;
		public function drawTimer():void 
		{			
			//var time:uint = 0;
			var currentDate:Date = new Date();
			expireJson = JSON.parse(App.data.options.fiestaWinterDuration);
			for (var i:* in expireJson) {
				if (i == App.SOCIAL) 
				{
					time = expireJson[i].time;
				}
			}
			
			//timeOfExpire.text = TimeConverter.timeToDays((time < App.time) ? 0 : (time - App.time));
			//timeOfExpire.text = TimeConverter.timeToCuts(time - App.time, true, true);
			
			timeOfExpire = Window.drawText(TimeConverter.timeToDays(time - App.time), {
				color:0xfcd731,
				fontSize:43,
				borderColor:0x563317,
				borderSize:5,
				width:300,
				height:200,
				textAlign:"center"
			});
			
			//if (App.isSocial('DM','VK','FS','MM','OK'))
			//{
				bodyContainer.addChild(timeOfExpire);
				timeOfExpire.x = back.x + back.width / 2 - timeOfExpire.width / 2;
				timeOfExpire.y = textLost.y + 25;
			//}	
			
			updateTimer();
			App.self.setOnTimer(updateTimer);
		}
		
		public function updateTimer():void 
		{
			timeOfExpire.text = TimeConverter.timeToDays((time < App.time) ? 0 : (time - App.time));
		}
		
		private function onTreeLoad(data:Bitmap):void
		{		
			addTreeState(data.bitmapData);
		}
		
		private function onPresentsLoad(data:Bitmap):void
		{		
			addPresentState(data.bitmapData);
		}
		
		protected function addTreeState(bmd:BitmapData):void 
		{
			var bitmap:Bitmap = new Bitmap(bmd);
			bitmap.smoothing = true;
			bitmap.x = settings.width - 100;
			bitmap.y -= 50;
			bitmap.scaleX = bitmap.scaleY = 1;
			bodyContainer.addChild(bitmap);	
		}
		
		protected function addPresentState(bmd:BitmapData):void 
		{
			var bitmap:Bitmap = new Bitmap(bmd);
			bitmap.smoothing = true;
			bitmap.x = - 100;
			bitmap.y = settings.height - bitmap.height - 55;
			bitmap.scaleX = bitmap.scaleY = 1;
			bodyContainer.addChild(bitmap);	
		}	
		
		private function update():void 
		{
			if (eventManager.timeFinish > App.time) {//eventManager.timeFinish[App.social] 
				textDay.text = TimeConverter.timeToDays(eventManager.timeFinish - App.time);
			}///else this.close();
		}
		
		private function drawBtt():void 
		{
			//for (var i:int = 0; i < eventManager.bttn.length;i++ ){			
				//var bttn:Button=new Button( {
					//caption:Locale.__e(eventManager.bttn[i].title),	//к первому заданию
					//fontSize:30,
					//width:180,
					//fontColor:				0xFFFFFF,				//Цвет шрифта
					//fontBorderColor:		0x814f31,				//Цвет обводки шрифта	
					//height:50
				//});
				//bttn.x = eventManager.bttn[i].dx;
				//bttn.y = eventManager.bttn[i].dy-60;
				//bodyContainer.addChild(bttn);
				//bttn.addEventListener(MouseEvent.CLICK, onMouseClick);
				//bttnArr.push(bttn);
			//}			
			
			questsManagerBttn = new Button( {
				width:180,
				height:50,
				fontSize:30,
				bgColor			:[0x96cafc,0x608cf5],
				borderColor		:[0xb4d9ff,0x376bd9],
				bevelColor		:[0xb4d9ff, 0x376bd9],
				fontColor		:0xfffffd,
				fontBorderColor	:0x355aaa,
				caption:Locale.__e("flash:1446805841616")
			});
			
			bodyContainer.addChild(questsManagerBttn);
			questsManagerBttn.x = back.width - questsManagerBttn.width + 20;
			questsManagerBttn.y = back.height + questsManagerBttn.height - 70;
			questsManagerBttn.addEventListener(MouseEvent.CLICK, onGoToQuestsManager);
			
			shopBttn = new Button( {
				width:180,
				height:50,
				fontSize:30,
				bgColor			:[0x96cafc,0x608cf5],
				borderColor		:[0xb4d9ff,0x376bd9],
				bevelColor		:[0xb4d9ff, 0x376bd9],
				fontColor		:0xfffffd,
				fontBorderColor	:0x355aaa,
				caption:Locale.__e("flash:1382952379765")
			});
			
			bodyContainer.addChild(shopBttn);
			shopBttn.x = back.x + 20;
			shopBttn.y = questsManagerBttn.y;
			shopBttn.addEventListener(MouseEvent.CLICK, onGoToShop);
			
			winterShopBttn = new Button( {
				width:180,
				height:50,
				fontSize:26,
				bgColor			:[0x96cafc,0x608cf5],
				borderColor		:[0xb4d9ff,0x376bd9],
				bevelColor		:[0xb4d9ff, 0x376bd9],
				fontColor		:0xfffffd,
				fontBorderColor	:0x355aaa,
				textAlign:"center",
				caption:Locale.__e("flash:1448624042373")
			});
			
			bodyContainer.addChild(winterShopBttn);
			winterShopBttn.x = shopBttn.x;
			winterShopBttn.y = shopBttn.y + 60;
			winterShopBttn.addEventListener(MouseEvent.CLICK, onGoToWinterShop);
			
			rewardBttn = new Button( {
				width:180,
				height:50,
				fontSize:30,
				bgColor			:[0x96cafc,0x608cf5],
				borderColor		:[0xb4d9ff,0x376bd9],
				bevelColor		:[0xb4d9ff, 0x376bd9],
				fontColor		:0xfffffd,
				fontBorderColor	:0x355aaa,
				caption:Locale.__e("flash:1447939811359")
			});
			
			bodyContainer.addChild(rewardBttn);
			rewardBttn.x = questsManagerBttn.x;
			rewardBttn.y = questsManagerBttn.y + 60;
			rewardBttn.addEventListener(MouseEvent.CLICK, onShowReward);
		}
		
		private function onGoToQuestsManager(e:Event = null):void 
		{
			new QuestsChaptersWindow({popup:true, find:[22, 23, 24]}).show();
		}
		
		private function onGoToWinterShop(e:Event = null):void 
		{
			new EventShopWindow({popup:true}).show();
		}
		
		private function onShowReward(e:Event = null):void 
		{
			var sid:int = 7;
			var rewardWindow:HappyRewardWindow = new HappyRewardWindow( {
				popup: true,
				happy:sid,
				winter:true
			}
			);
			rewardWindow.y -= 70;
			rewardWindow.x -= 10;
			rewardWindow.show();
			rewardWindow.fader.y += 70;
			rewardWindow.fader.x += 10;
		}
		
		private function onGoToShop(e:Event = null):void 
		{
			shopIt();
			var window:ShopWindow;
			if (App.user.quests.tutorial)
			return;
			window = new ShopWindow({popup:true});
			window.show();
			window.setContentNews(shop.data);
		}	
		
		private function onMouseClick(e:MouseEvent):void 
		{
			var max:int = 0;
			var mas:Array = new Array();
			for (var i:* in  App.data.updates) {
				for (var j:*in App.data.updates[i].social) {
					if(App.data.updates[i].social[j]==App.SOCIAL)
						if(App.data.updates[i].order>max && App.data.updates[i].quests>0){	
							max = App.data.updates[i].order;
							mas[0] =	i;
					}
				}
			}
			
			var qID:int = App.data.updates[mas[0]].quests
			var quest:Object = App.data.quests[qID];
			var chapterID:int = quest.chapter;
			var masQuests:Array = new Array();

			switch(e.target.caption){	
			case("К заданиям"):
				
				new QuestsChaptersWindow({find:[20],popup:true}).show();
				break;
			
			case("Награда"): 
				var sid:int = Stock.CHRISTMAS_TREE;
				new HappyRewardWindow({happy:sid,popup:true}).show();
				break;
			
			case("Магазин"): 
				shopIt();
				var window:ShopWindow;
				if (App.user.quests.tutorial)
				return;
				window = new ShopWindow({popup:true});
				window.show();
				window.setContentNews(shop.data);
				break;
			
			default: break;
			
			}
		}
		
		private function shopIt():void 
		{	
			if (shop == null) {
				shop = new Object();
			shop = {
				data:[],	
				page:0
			};
			
			for (var updateID:* in App.data.updates) {	
				if(	updateID == "u565f517fb4553"){
					if (!App.data.updates[updateID].social || !App.data.updates[updateID].social.hasOwnProperty(App.social)) 
						continue;
			var updateObject:Object = {
					id:updateID,
					data:[]
				}
					var updatesItems:Array = [];
					var items:Object = App.data.updates[updateID].items;
					
					for (var _sid:* in items)
					{
						if (!App.data.storage.hasOwnProperty(_sid))
							continue					
						if (App.data.storage[_sid].visible == 0 /*&& !Config.admin*/) continue;
						if (App.data.storage[_sid].type == 'Collection') continue;
						if (App.data.storage[_sid].type == 'Lands') continue;
						updatesItems.push( { sid:_sid, order:items[_sid] } );
					}	
					updatesItems.sortOn('order', Array.NUMERIC);
					for (var i:int = 0; i < updatesItems.length; i++) {
						updateObject.data.push(App.data.storage[updatesItems[i].sid]);
					}
					shop.data=updateObject.data;	
				}
			}
			}	
		}
		
		override public function drawExit():void 
		{
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 60;
			exit.y = -70;
			exit.addEventListener(MouseEvent.CLICK, close);
		}	
		
		override public function dispose():void {
			App.self.setOffTimer(update);
			super.dispose();
		}
	}
}
