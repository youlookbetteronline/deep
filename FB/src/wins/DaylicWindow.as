package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;

	public class DaylicWindow extends Window
	{		
		
		public var separator:Bitmap;
		public var missions:Array = [];
		
		public var okBttn:Button;
		//public var daylicShopBttn:Button;
		
		public var quest:Object = { };
		private var headBG:Sprite;
		private var titleQuest:TextField;
		private var titleShadow:TextField;
		private var descLabel:TextField;
		private var presLabel:TextField;
		private var timerLabel:TextField;
		
		private var arrowLeft:ImageButton;
		private var arrowRight:ImageButton;
		private var presentBacking:Bitmap;
		private var topBacking:Bitmap;
		private var helpBttn:Button;
		
		private var progressView:Sprite = new Sprite();
		private var presentView:Sprite;
		
		private var prev:int = 0;
		private var next:int = 0;
		
		public function DaylicWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = { };
			}
			
			settings['width'] = 490; // 444;
			settings['height'] = 680;
			
			settings['hasTitle'] = false;
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			settings['exitTexture'] = 'closeBttnMetal';
			
			//if (Quests.currentDID != 0 && App.data.daylics.hasOwnProperty(Quests.currentDID))
			
			settings['qID'] = Quests.currentDID;
			quest = Quests.daylics[Quests.currentDID];
			super(settings);
			
			if (App.isSocial('YB', 'AI')) {
				pretime = 'のこり: ';
			}
		}
		
		private var pretime:String = '';
		public function timerControll():void {
			timerLabel.text = pretime + TimeConverter.timeToStr(App.nextMidnight - App.time);
		}
		
		override public function drawBackground():void {
			
		}
		
		override public function create():void {
			super.create();
			//layer.swapChildren(bodyContainer, headerContainer);
		}
		
		private var preloader:Preloader = new Preloader();
				
		override public function drawBody():void {
			
			//helpBttn = drawHelp();
			//helpBttn.x = exit.x - 40;
			//helpBttn.y = exit.y;
			//helpBttn.addEventListener(MouseEvent.CLICK, onHelp);
			//headerContainer.addChild(helpBttn);
			
			//bodyContainer.y += 40;
			/*presentBacking = backingShort(398, "yellowRibbon");
			presentBacking.x = 45;
			presentBacking.y = 46;
			bodyContainer.addChild(presentBacking);*/
			/*if (quest == null)
			{
				Post.send( {
					ctr:'user',
					act:'refreshdaylics',
					uID:App.user.id
				}, function(error:int, data:Object, params:Object):void {
					App.user.daylics = data.result;
					App.user.quests.daylicsInit();
					if (App.user.quests.dayliPressent is uint && App.user.quests.dayliPressent == 0) {
						App.user.quests.dayliPressent = 1;
						App.ui.leftPanel.startDaylicsGlow(true);
					
					}
					drawMessage();
					//if(dayliInit && openWindow) {
						//new DaylicWindow().show();
					//}
				});
				setTimeout(drawBody, 1000);
				return;
			}
			else*/
				drawMessage();
			
			exit.x -= 13
			//this['exit'].x += 40;
			exit.y -= 12;
			
			okBttn = new Button( {
				width:138,
				height:42,
				fontSize:28,
				caption:Locale.__e("flash:1382952380298")
			});
			okBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(okBttn);
			
			okBttn.addEventListener(MouseEvent.CLICK, close);
			
			/*daylicShopBttn = new Button( {
				width:128,
				height:60,
				fontSize:28,
				textAlign:"center",
				caption:Locale.__e("flash:1442309571643")
			});
			
			daylicShopBttn.addEventListener(MouseEvent.CLICK, openDaylicShop);*/
			
			var character:Bitmap = new Bitmap();
			
			bodyContainer.addChild(preloader);
			preloader.x = -80;
			preloader.y = 290;
			
			var characterPerv:String = (App.data.personages.hasOwnProperty(quest.character)) ? App.data.personages[quest.character].preview : "octopus";
			
			if(quest.character == 3){
				if(App.user.sex == 'm'){
					characterPerv = "boy";
				}else{
					characterPerv = "girl";
				}
			}
			
			//Load.loading(Config.getQuestIcon('preview', characterPerv), function(data:*):void 
			
			Load.loading(Config.getQuestIcon('preview', characterPerv), function(data:*):void { 
				bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;
				character.x = (-(character.width / 4) * 3) - 40;
				character.y = 20;
				
				bodyContainer.addChild(character);
				//bodyContainer.addChild(daylicShopBttn);
			});
			
			infoUpdate(true);
			
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = 210 + 102 * missions.length + 84;
			
			arrowLeft = new ImageButton(Window.textures.arrow, {scaleX:-0.7,scaleY:0.7});
			arrowRight = new ImageButton(Window.textures.arrow, {scaleX:0.7,scaleY:0.7});
			
			arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, onPrevQuest);
			arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, onNextQuest);
			
			if(prev > 0){
				bodyContainer.addChild(arrowLeft);
				arrowLeft.x = okBttn.x - arrowLeft.width - 40;
				arrowLeft.y = okBttn.y + 2;
			}
			
			if(next > 0){
				bodyContainer.addChild(arrowRight);
				arrowRight.x = okBttn.x + okBttn.width + 54;
				arrowRight.y = okBttn.y + 2;
			}
			
			settings.height = okBttn.y + okBttn.height - 14;
			var background:Bitmap = backing(settings.width, settings.height, 50, "capsuleWindowBacking");//фон
			bodyContainer.addChildAt(background, 0);
			
			
			drawMirrowObjs('decSeaweed', settings.width + 56, - 56, settings.height - 169, true, true, false, 1, 1, bodyContainer);
			
			App.self.setOnTimer(timerControll);
			
		}
		
		private function openDaylicShop(e:Event = null):void 
		{
			close();
			var daylicWindow:DaylicsShopWindow = new DaylicsShopWindow( {
				popup: true
			}
			);
			daylicWindow.y += 40;
			daylicWindow.show();
			daylicWindow.fader.y -= 40;
		}
		
		private function onPrevQuest(e:MouseEvent):void {
			close();
			App.user.quests.openWindow(prev);
		}
		
		private function onNextQuest(e:MouseEvent):void {
			close();
			App.user.quests.openWindow(next);
		}
		
		private function drawMessage():void {
			
			if (descLabel) {
				//headBG.removeChild(titleQuest);
				headBG.removeChild(descLabel);
				headBG.removeChild(timerLabel);
				bodyContainer.removeChild(presLabel);
				bodyContainer.removeChild(headBG);
			}
			
			headBG = new Sprite();
			
			/*titleQuest = Window.drawText(Locale.__e('flash:1392987414713'), {
				color:0xFFFFFF,
				borderColor:0xc67710,
				fontSize:41,
				multiline:true,
				textAlign:"center",
				wrap:true,
				width:320,
				filters: [new DropShadowFilter(2, 90, 0x604729, 1, 0, 0, 1, 1)]
			});
			titleQuest.wordWrap = true;
			titleQuest.width = 320;
			titleQuest.height = titleQuest.textHeight + 10;*/
			
			descLabel = Window.drawText(quest.description.replace(/\r/g,""), {
				color:0x045260,
				borderColor:0xffecc8,/*
				border:false,*/
				fontSize:24,
				width:420,
				autoSize:'center',
				multiline:true,
				textAlign:"center"
			});
			//descLabel.wordWrap = true;
			descLabel.width = settings.width - 100;
			descLabel.height = descLabel.textHeight + 10;
			
			timerLabel = Window.drawText('', {
				color:0xfceb5d,
				borderColor:0x6d350d,
				fontSize:32,
				textAlign:"center",
				width:320,
				filters: [new DropShadowFilter(2, 90, 0x604729, 1, 0, 0, 1, 1)]
			});
			timerControll();
			timerLabel.width = 280;
			timerLabel.height = timerLabel.textHeight + 10;
			timerLabel.cacheAsBitmap = true;
			
			presLabel = Window.drawText(Locale.__e("flash:1392118243755"), {
				color:0xffdf61,
				borderColor:0x883218,
				fontSize:24,
				textAlign:"center",
				textLeading:1
			});
			presLabel.width = presLabel.textWidth + 10;
			presLabel.height = presLabel.textHeight + 4;
			presLabel.x = (settings.width - presLabel.width) / 2;
			presLabel.y = 210 + missions.length * 102;
			bodyContainer.addChild(presLabel);
			
			/*topBacking = Window.backing2(settings.width - 30 * 2, 200, 40, 'itemBackingPaperBigDrec', 'itemBackingPaperBig');//верхний бумажный квадрат
			headBG.addChild(topBacking);
			topBacking.y += 40;*/
			
			/*separator = Window.backingShort(375, 'divider');
			separator.alpha = 0.8;
			headBG.addChild(separator);
			separator.x = 29;
			separator.y = 135;*/
			
			/*headBG.addChild(titleQuest);
			titleQuest.y = 28;
			titleQuest.x = (headBG.width - titleQuest.width) / 2;*/
			
			headBG.addChild(descLabel);
			descLabel.x = (headBG.width - descLabel.width) / 2;
			descLabel.y = 28;
			
			headBG.addChild(timerLabel);
			timerLabel.x = (headBG.width - timerLabel.width) / 2;
			timerLabel.y = descLabel.y + descLabel.height +5;
			
			var backgroundTimer:Bitmap = Window.backingShort(140, 'bubbleTimerBack');// Window.backing(200, 65, 20, "buildinSmallDarkgBacking");
			//Size.size(backgroundTimer, 140, 40);
			//backgroundTimer.scaleX = backgroundTimer.scaleY = .85;
			backgroundTimer.smoothing = true;
			headBG.addChild(backgroundTimer);
			headBG.swapChildren(backgroundTimer, timerLabel);
			backgroundTimer.x = timerLabel.x + (timerLabel.width - backgroundTimer.width) / 2;
			backgroundTimer.y = timerLabel.y + (timerLabel.textHeight - backgroundTimer.height) / 2;
			
			headBG.x = (settings.width - headBG.width) / 2;
			headBG.y = 0;
			
			bodyContainer.addChild(headBG);
		}
		
		public function infoUpdate(allUpdate:Boolean = false):void {
			if (Quests.currentDID == 0) return;
			
			for (var i:int = 0; i < missions.length; i++) {
				var child:Mission = missions[i] as Mission;
				if (Quests.currentDID == child.qID) {
					child.update();
				}else {
					allUpdate = true;
					settings['qID'] = Quests.currentDID;
					quest = Quests.daylics[Quests.currentDID];
				}
			}
			
			if (allUpdate) {
				//titleQuest.text = Quests.daylics[Quests.currentDID].title;
				descLabel.text = quest.description.replace(/\r/g, "");
				
				contentChange();
				drawMessage();
				drawStage();
				drawBonus();
			}
		}
		
		public var stageList:Array = [];
		public function drawStage():void {
			clearStageList();
			
			const indent:int = 6;
			var complete:Boolean = false;
			var arrow:Bitmap;
			
			var pos:int = 0;
			for (var i:int = 0; i < Quests.daylicsList.length; i++) {
				if (Quests.daylicsList[i].finished == 0 && !arrow) {
					arrow = new Bitmap(Window.textures.arrowUp, 'auto', true);
					arrow.rotation = 180;
					Size.size(arrow, 25, 25);
					arrow.x = pos + 34;
					arrow.y = 70 - 114;
					progressView.addChild(arrow);
				}
				var currStage:LayerX = new LayerX();
				var stageLabel:Bitmap;
				var countLabel:TextField;
				var stageText:TextField;
				if (Quests.daylicsList[i].finished > 0) {
					stageLabel = new Bitmap(Window.textures.clearBubbleBacking_0, 'auto', true);
					Size.size(stageLabel, 34, 34);
					var mark:Bitmap = new Bitmap(Window.textures.checkmarkBig);
					Size.size(mark, 34, 34);
					mark.smoothing = true;
					stageLabel.y = - 48;
					mark.x = pos + 8;
					mark.y = stageLabel.y + (stageLabel.height - mark.height) / 2 - 3;
				}else {
					stageLabel = new Bitmap(Window.textures.clearBubbleBacking_0, 'auto', true);
					Size.size(stageLabel, 34, 34); 
					countLabel = Window.drawText(String(i+1), {
						color:0x02eeff,
						borderColor:0x904917,
						fontSize:25,
						textAlign:"center"
					});
					countLabel.width = countLabel.textWidth + 4;
					countLabel.height = countLabel.textHeight + 4;
					countLabel.x = Math.floor((stageLabel.width - countLabel.width)/2);
					countLabel.y = -45;
					//stageLabel.y = -48;
					
					stageText = Window.drawText(Locale.__e('flash:1395675420972'), {
						fontSize:		18,
						color:			0x774222,
						borderColor:	0xfffcca,
						autoSize:		'center'
					});
					stageText.x = Math.floor((stageLabel.width - stageText.width)/2);
					//stageText.y = stageText.height + 7;
					stageText.y = - 15;
					stageLabel.y = - 48;
				}
				currStage.x = pos + indent;
				currStage.y = -currStage.height;
				currStage.addChild(stageLabel);
				pos += currStage.width + indent + 10;
				
				if (i < Quests.daylicsList.length - 1) {
					var line:Bitmap = new Bitmap(Window.textures.clearBubbleBacking_0, 'auto', true);
					Size.size(line, 16, 16);
					line.smoothing = true;
					line.x = pos;
					line.y = - 38;
					progressView.addChild(line);
					pos += line.width + indent;
				}
				
				if (countLabel) {
					currStage.addChild(countLabel);
					currStage.addChild(stageText);
				}
				if (mark)
					progressView.addChild(mark);
				
				progressView.addChild(currStage);
				if (arrow)
					progressView.swapChildren(arrow, currStage);
				stageList.push(currStage);
			}
			
			progressView.x = Math.floor((settings.width - progressView.width) / 2);
			progressView.y = 175;
			
			var backgroundProgress:Shape = new Shape();
			backgroundProgress.graphics.beginFill(0xf0c001, .6);
		    backgroundProgress.graphics.drawRect(0, 0, settings.width - 130, 40);
		    backgroundProgress.graphics.endFill();
			backgroundProgress.filters = [new BlurFilter(40, 0, 2)];
			
			backgroundProgress.x = (settings.width - backgroundProgress.width) / 2;
			backgroundProgress.y = progressView.y - 51;
			
			bodyContainer.addChild(backgroundProgress);
			
			bodyContainer.addChild(progressView);
		}
		public function clearStageList():void {
			while (progressView.numChildren > 0) {
				progressView.removeChildAt(0);
			}
			stageList = [];
		}
		
		public function drawBonus():void {
			if (presentView) {
				while (presentView.numChildren > 0) {
					presentView.removeChildAt(0);
				}
			}
			presentView = new Sprite();
			bonusList = new CollectionBonusList(Quests.daylics[Quests.currentDID].bonus, false, {borderSize: 4, iconBacking: false, hasTitle: false, glow:0});
			//bonusList.itemsSprite.y += 5;
			bonusList.x = (settings.width - bonusList.width) / 2 - 10;
			bonusList.y = 220 + 102 * missions.length;;
			var bonusListBacking:Bitmap = Window.backingShort(settings.width - 80, 'backingGrad', true);
			bonusListBacking.scaleY = 1;
			bonusListBacking.alpha = .7;
			bonusListBacking.smoothing = true;
			bonusListBacking.x = (settings.width - bonusListBacking.width) / 2 ;
			bonusListBacking.y = bonusList.y + (bonusList.height - bonusListBacking.height) / 2 + 17;
			if(bonusList.parent) bonusList.parent.removeChild(bonusList);
			if(bonusListBacking.parent) bonusListBacking.parent.removeChild(bonusListBacking);
			bodyContainer.addChild(bonusListBacking);
			bodyContainer.addChild(bonusList);
			//bodyContainer.swapChildren(bonusListBacking, bonusList);
			
			/*bonusList = new BonusList(Quests.daylics[Quests.currentDID].bonus, false, { 
					hasTitle:false,
					background:'questRewardBacking',
					//backingShort:true,
					width: 200,
					height: 60,
					bgWidth:60,
					bgX: -3,
					bgY:5,
					titleColor:0x571b00,
					titleBorderColor:0xfffed7,
					bonusTextColor:0x3a1e08,
					bonusBorderColor:0xffffd9
					
				} );
			bodyContainer.addChild(bonusList);
			bonusList.x = (settings.width - bonusList.width) / 2 - 10;
			bonusList.y = presentBacking.y;*/
		}
		
		public function progress(mID:int):void {
			contentChange();
			for each(var item:Mission in missions) {
				if (item.mID == mID) {
					item.progress();
				}
			}
		}
		
		private var bonusList:CollectionBonusList;
		override public function contentChange():void {
			
			for each(var item:Mission in missions) {
				bodyContainer.removeChild(item);
				item.dispose();
				item = null;
			}
			missions = [];
			
			var itemNum:int = 0;
			for(var mID:* in quest.missions) {
				
				item = new Mission(settings.qID, mID, this);
				
				bodyContainer.addChild(item);
				item.x = (settings.width - item.background.width) / 2;
				item.y = (220 + 110 * itemNum) - 35;
				
				missions.push(item);
				
				if (id == mID) {
					item.progress();
				}
				
				itemNum++;
			}
			
			
			
			/*daylicShopBttn.x = -195;
			daylicShopBttn.y = 460;*/
		}
		
		public function showTake(dID:uint):void {
			for(var i:String in App.data.daylics[dID].bonus) {
				var item:BonusItem = new BonusItem(uint(i), App.data.daylics[dID].bonus[i]);
				item.cashMove(new Point(presentBacking.x + presentBacking.width / 2, presentBacking.y + presentBacking.height / 2), App.self.windowContainer);
			}
		}
		
		override public function dispose():void 
		{
			if(okBttn)
				okBttn.removeEventListener(MouseEvent.CLICK, close);
				
			App.self.setOffTimer(timerControll);
			
			super.dispose();
		}
		
		override public function drawFader():void {
			super.drawFader();
			
			this.x += 150;
			fader.x -= 150;
		}
		
	}

}
import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.setTimeout;
import wins.Window;
import wins.SimpleWindow;
import units.Field;


internal class Mission extends Sprite {
	
	public var qID:int;
	public var mID:int;
	
	public var background:Bitmap;
	public var bitmap:Bitmap = new Bitmap();
	
	public var mission:Object = { };
	public var quest:Object = { };
	public var have:int = 0;
	public var text:String = '';
	
	public var counterLabel:TextField;
	public var titleLabel:TextField;
	public var presLabel:TextField;
	
	public var helpBttn:Button;
	public var rewards:Sprite;
	
	private var preloader:Preloader = new Preloader();
	
	private var window:*;
	private var sID:*;
	public function Mission(qID:int, mID:int, window:*) {
		
		this.qID = qID;
		this.mID = mID;
		
		this.window = window;
		
		background = Window.backing(430, 110, 40, 'paperClear');//фоны самих квестов
		addChild(background);
		
		
		
		quest = Quests.daylics[qID];
		mission = Quests.daylics[qID].missions[mID];
		
		
		if(mission.target is Object){
			for each(sID in mission.target) {
				break;
			}
		}else if (mission.map is Object) {
			for each(sID in mission.map) {
				break;
			}
		}
		
		if(sID!= null && App.data.storage[sID] != undefined){
			
			var url:String;
			
			if (sID == 0 || sID == 1) {
				url = Config.getQuestIcon('missions', mission.preview);
			}else {
				var icon:Object = App.data.storage[sID];
				url = Config.getIcon(icon.type, icon.preview);
			}
			
			var bubbleBg:Bitmap = new Bitmap(Window.textures.dailyBonusItemBubble);
			bubbleBg.y = (background.height - bubbleBg.height) / 2;
			bubbleBg.x = 15;
			addChild(bubbleBg);
			var tipContainer:LayerX;
			tipContainer = new LayerX;
			addChild(tipContainer);
			tipContainer.addChild(bitmap);
			
			addChild(preloader);
			Size.size(preloader, bubbleBg.width, bubbleBg.height); 
			preloader.x = bubbleBg.x + bubbleBg.width / 2;
			preloader.y = bubbleBg.y + bubbleBg.height / 2;
			
			Load.loading(url, function(data:*):void {
				
				removeChild(preloader);
				
				bitmap.bitmapData = data.bitmapData;
				/*if (bitmap.height > 100) {
					bitmap.scaleX = bitmap.scaleY = 100 / bitmap.height;
				}*/
				Size.size(bitmap, bubbleBg.width - 20, bubbleBg.height - 20);
				bitmap.smoothing = true;				
				bitmap.x = bubbleBg.x + (bubbleBg.width - bitmap.width) / 2;
				bitmap.y = bubbleBg.y + (bubbleBg.height - bitmap.height) / 2;
				
			});
			tipContainer.tip = function():Object 
			{
			return {
				title:mission.title/*App.data.storage[sID].title*/,
				text:mission.description/*App.data.storage[sID].description*/
			}
			}
		}
		
		update();
		
		counterLabel = Window.drawText(text, {
			fontSize:28,
			color:0xffffff,
			borderColor:0x7f2d14,
			autoSize:"left"
		});
		
		counterLabel.x = bubbleBg.x + (bubbleBg.width - counterLabel.width) / 2;
		counterLabel.y = bubbleBg.y + bubbleBg.height - counterLabel.textHeight;
		addChild(counterLabel);
		
		titleLabel = Window.drawText(mission.title, {
			fontSize:24,
			color:0xffffff,
			borderColor:0x853016,
			multiline:true,
			borderSize:3,
			textAlign:"center",
			textLeading:-3
		});
		titleLabel.wordWrap = true;
		titleLabel.width = 170;
		titleLabel.height = titleLabel.textHeight + 10;
		//titleLabel.border = true;
		
		titleLabel.x = 110;
		titleLabel.y = (background.height - titleLabel.height) / 2;
		addChild(titleLabel);
		
		if (mission.func == "subtract") 
		{
			if (have >= mission.need) {// засчитано
				drawFinished();
			}else {
				if(App.user.stock.count(sID) >= mission.need)// можно снять
					drawSubstructButtons();
				else
					drawButtons();// не хватает для снятия
			}
		}else {
			if (have >= mission.need) {
				drawFinished();
			}else{
				drawButtons();
			}
		}
		
		if(mission.hasOwnProperty('bonus') && mission.need > have) {
			var nums:int = 0;
			rewards = new Sprite(); App.data.daylics;
			for (var s:String in mission.bonus) {
				var item:PresentItem = new PresentItem(s, String(mission.bonus[s]), {bitmapSize:32});
				item.x = (50 * nums) - 45;
				item.y += 15;
				rewards.addChild(item);
				nums++;
			}
			rewards.x = background.width - 50 * nums - 20;
			rewards.y = 20;
			addChild(rewards);
		}
	}
	
	public function update():void {
		have = quest.progress[mID];
		if (have > mission.need) have = mission.need;
		
			
		
		if(mission.func == 'sum'){
			text = have + '/' + mission.need;
		}else if (mission.func == "subtract") {
			if (have >= mission.need) {
				text = have + '/' + mission.need;
			}else{
				text = App.user.stock.count(sID) + '/' + mission.need;
			}
		}else {
			if (have == mission.need) {
				text = '1/1';
			}else {
				text = '0/1';
			}
		}
		if(counterLabel)
			counterLabel.text = text;
		
		if (have >= mission.need && rewards) {
			take(App.data.daylics[qID].missions[mID].bonus);
			removeChild(rewards);
			rewards = null;
			if (presLabel) 
			{
				presLabel.visible = false;
			}
			if (helpBttn) 
			{
				helpBttn.visible = false;
			}
			if (substructBttn) 
			{
				substructBttn.visible = false;
			}
			
			drawFinished();
		}
	}
	private function take(items:Object):void {
		for(var i:String in items) {
			var item:BonusItem = new BonusItem(uint(i), items[i]);
			var point:Point = Window.localToGlobal(rewards);
			item.cashMove(point, App.self.windowContainer);
		}
	}
	
		private var substructBttn:Button;
	
	private function drawSubstructButtons():void {
		
	/*	if(!window.isDuration){
			skipBttn = new MoneyButton( {
				caption: Locale.__e("flash:1382952380253"),
				countText:String(mission.skip),
				width:115,
				height:38,
				borderColor:[0xcefc97, 0x5f9c11],
				fontColor:0xFFFFFF,
				fontBorderColor:0x4d7d0e,
				bevelColor:[0xcefc97,0x5f9c11]
			})
			
			addChild(skipBttn);
			skipBttn.x = background.width - skipBttn.width - 30;
			skipBttn.y = 20;
			skipBttn.countLabel.width = skipBttn.countLabel.textWidth + 5;
			
			skipBttn.addEventListener(MouseEvent.CLICK, onSkipEvent);
		}*/
		
		substructBttn = new Button( { 
			//caption:Locale.__e('flash:1433939122335'),
			caption:Locale.__e('flash:1443188488951'),
			width:115,
			height:38,
			fontSize:22,
			radius:12
		});
		substructBttn.x = background.width - substructBttn.width - 30;
		substructBttn.y = 62;
		substructBttn.textLabel.x += 1;
		
		var takenedIconBttn:Bitmap = new Bitmap(Window.textures.takenedItemsIco);
		takenedIconBttn.scaleX = takenedIconBttn.scaleY = 0.75;
		takenedIconBttn.smoothing = true;
		takenedIconBttn.x = substructBttn.textLabel.x + substructBttn.textLabel.width ;
		takenedIconBttn.y = -3;
		//substructBttn.addChild(takenedIconBttn);
		
		addChild(substructBttn);
		substructBttn.showGlowing();
		substructBttn.addEventListener(MouseEvent.CLICK, onSubstructEvent);
		
		//if (window.isDuration)
		//	substructBttn.y = (background.height - substructBttn.height) / 2 + 6;
	}
	
	private function onSubstructEvent(e:MouseEvent):void {
		App.user.quests.subtractEvent(qID, mID, window.progress,'daylics');
	}
	
	private function drawFinished():void {
		var bg:Shape = new Shape();
		bg.graphics.beginFill(0xceaa7a);
		bg.graphics.drawCircle(0, 0, 36);
		bg.graphics.endFill();
		bg.filters = [new DropShadowFilter(3, 90, 0, .4, 4, 4, 1, 1, true), new DropShadowFilter(3, -90, 0xffffff, .4, 4, 4, 1, 1, true)]
		
		//var bg:Bitmap = new Bitmap(Window.textures.questCheckmarkSlot);
		var mark:Bitmap = new Bitmap(Window.textures.checkMark);
	 
		bg.x = 315 + 36;
		mark.x = 325;
		bg.y += 23 + 36;
		mark.y += 23;
		
		addChild(bg);
		addChild(mark);
	}
	
	private function drawButtons():void {
		presLabel = Window.drawText(Locale.__e("flash:1382952380000"), {
			fontSize:22,
			color:0xffdf61,
			borderColor:0x7b270e,
			multiline:false,
			textLeading:-2
		});
		presLabel.width = 156;
		presLabel.height = presLabel.textHeight+4;
		presLabel.x = background.width - 115;
		presLabel.y = 9;
		addChild(presLabel);
		
		helpBttn = new Button( { 
			caption:Locale.__e('flash:1382952380254'),
			width:100,
			height:35,
			bgColor:[0xbaf76e,0x68af11],
			borderColor:[0xa0d5f6, 0x3384b2],
			fontColor:0xFFFFFF,
			fontBorderColor:0x435060,
			bevelColor:[0xd8e7ae,0x4f9500],
			fontSize:22,
			radius:18
		});
		
		addChild(helpBttn);
		helpBttn.x = background.width - helpBttn.width - 35;
		helpBttn.y = 60;
		helpBttn.settings['find'] = mission.find;
		
		helpBttn.addEventListener(MouseEvent.CLICK, onHelpEvent);
		
	}
	
	private function onHelpEvent(e:MouseEvent):void
	{
		if (e.currentTarget.settings.find > 0) {
			
			Window.closeAll();
			App.user.quests.helpEvent(qID, mID, false, 1);
		}else //if (qID == 34 && mID == 1){
		if ((qID == 34 && mID == 1) || (qID == 116 && mID == 1))
		{
			App.ui.bottomPanel.friendsPanel.bttnPrevAll.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			setTimeout(function():void{
				App.ui.bottomPanel.friendsPanel.friendsItems[0].showPointing("top", -0, 0, App.ui.bottomPanel.friendsPanel.friendsItems[0], "", null, false);
				App.ui.bottomPanel.friendsPanel.friendsItems[0].startGlowing();
				setTimeout(function():void {
				App.ui.bottomPanel.friendsPanel.friendsItems[0].hidePointing();
				App.ui.bottomPanel.friendsPanel.friendsItems[0].hideGlowing();					
				}, 3500)					
			}, 500)
			
			window.close();
			return
		
		}else {
			/*if (qID == 126 && mID == 1)
			{
				App.ui.bottomPanel.friendsPanel.bttnPrevAll.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				setTimeout(function():void{
					App.ui.bottomPanel.friendsPanel.friendsItems[0].showPointing("top", -50, 0, App.ui.bottomPanel.friendsPanel.friendsItems[0], "", null, false);
					App.ui.bottomPanel.friendsPanel.friendsItems[0].startGlowing();
					setTimeout(function():void {
					App.ui.bottomPanel.friendsPanel.friendsItems[0].hidePointing();
					App.ui.bottomPanel.friendsPanel.friendsItems[0].hideGlowing();					
					}, 3500)					
				}, 500)
				
				window.close();
				return
			}*/
			
			new SimpleWindow( {
				popup:true,
				height:320,
				width:480,
				title:Locale.__e('flash:1382952380254'),
				text:App.data.daylics[qID].missions[mID].description
			}).show();
		}
	}
	
	public function progress():void {
		App.ui.flashGlowing(bitmap, 0xFFFF00, null, false);
	}
	
	public function dispose():void {
		if(helpBttn)
			helpBttn.removeEventListener(MouseEvent.CLICK, onHelpEvent);
	}
}

internal class PresentItem extends LayerX {
	
	public var count:TextField;
	
	function PresentItem(sid:String, text:String, sett:Object) {
		var preload:Preloader = new Preloader();
		preload.x = sett.bitmapSize / 2;
		preload.y = sett.bitmapSize / 2;
		preload.width = sett.bitmapSize;
		preload.height = sett.bitmapSize;
		addChild(preload);
		
		tip = function():Object {
			return {
				title:		App.data.storage[sid].title,
				text:		App.data.storage[sid].description
			}
		}
		count = Window.drawText('x' + text, {
			fontSize:		sett.fontSize || 25,
			color: 			sett.color || 0xffdf61,
			borderColor:	sett.borderColor || 0x7b270e,
			borderSize:		sett.borderSize || 3,
			multiline:		false,
			textLeading:	-2
		});
		
		count.width = count.textWidth + 4;
		count.height = count.textHeight + 2;
		
		
		Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), function(data:*):void {
			removeChild(preload);
			var bitmap:Bitmap = new Bitmap(data.bitmapData, 'auto', true);
			Size.size(bitmap, 25, 25);
			bitmap.smoothing = true;
			bitmap.x = 2;
			bitmap.y = -1;
			
			count.x = bitmap.x + bitmap.width + 2;
			count.y = bitmap.y +(bitmap.height - count .textHeight) / 2;
			//bitmap.width = sett.bitmapSize;
			//bitmap.scaleY = bitmap.scaleX;
			/*bitmap.scaleY = 0.36;
			bitmap.scaleX = 0.36;*/
			addChild(bitmap);
		});
		
		
		addChild(count);
	}
}