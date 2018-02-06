package ui
{
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.QuestPanel;
	import wins.Window;

	public class QuestIcon extends LayerX
	{
		public static const HEIGHT:int = 70;
		public static var visibleQuest:Object = { };
		
		public var needClose:Boolean = true;
		public var questData:Object;
		public var qID:int;
		public var iconItemId:int = 0;
		public var bg:Bitmap;
		public var backing:Bitmap;
		private var backingDecor:Bitmap;
		public var icon:Bitmap = new Bitmap();
		public var timerLabel:TextField;
		public var newIcon:Bitmap;
		
		private var _parent: QuestPanel;
		protected var preloader:Preloader;
		public var item:Object;
		
		protected var backBmap:Bitmap = new Bitmap();
		protected var countTxt:TextField = new TextField();
		protected var iconNew:Bitmap = new Bitmap();
		protected var iconTimer:Bitmap = new Bitmap();
		
		public function QuestIcon(item:Object, _QuestPanel:QuestPanel = null, newQuest:Boolean = false) {
			
			this.item = item;
			this.qID = item.id;
			questData = App.data.quests[qID];
			//newQuestIc = newQuest;
			drawIcon();
			
			if (_QuestPanel )
			{
				this._parent = _QuestPanel;
			}
			
			tip = function():Object {
				var text:String = questData.description;
				
				if (questData.missions) {
					text = '';
					var count:int = 1;
					for (var mid:* in questData.missions) {
						if (text.length > 0) text += '\n';
						
						var have:int = (App.user.quests.data.hasOwnProperty(qID)) ? App.user.quests.data[qID][mid] : 0;
						var txt:String;
						if (questData.missions[mid].event == "upgrade")
						{
							var unitsSe:Array = Map.findUnits(questData.missions[mid].target);
							for each(var obj:* in unitsSe)
							{
								if (obj.type == 'Walkhero')
								{
									trace("Level = " + obj.model.level);
									trace("ID = " + obj.id);
									have = obj.model.level;
									break;
								}
								else
								{
								//if (obj.level && obj.sid == sID){
								trace("Level = " + obj.level);
								trace("ID = " + obj.id);
								txt = obj.level + '/' + questData.missions[mid].need;
								//break;
								//}
								}
							}
							if (obj == undefined)
							{
								txt = '0/' + questData.missions[mid].need;
							}
							
							/*if (have == questData.missions[mid].need) {
								txt = '1/1';
							}else {
								txt = '0/' + questData.missions[mid].need;//'0/1';
							}*/
							text += ' - ' + questData.missions[mid].title + ' ' + txt;
						} else if (questData.missions[mid].func != 'sum') 
						{
							if (have == questData.missions[mid].need) {
								txt = '1/1';
							}else {
								txt = '0/' + questData.missions[mid].need;//'0/1';
							}
							text += ' - ' + questData.missions[mid].title + ' ' + txt;
						} else {
							text += ' - ' + questData.missions[mid].title + ' ' + String(App.user.quests.data[qID][mid] || 0) + '/' + String(questData.missions[mid].need);
						}
						count++;
					}
				}
				
				return {
					title:		questData.title,
					text:		text
				}
			};
			
			initAddon();
		}
		
		
		public function drawIcon():void 
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xFF0000, 0.0);
			shape.graphics.drawRect(0, 0, HEIGHT, HEIGHT);
			shape.graphics.endFill();
			addChild(shape);
			
			preloader = new Preloader();
			preloader.scaleX = preloader.scaleY = 1;
			preloader.x = 36;
			preloader.y = 40;
			addChild(preloader);
			
			backing = new Bitmap();
			addChild(backing);
			
			bg = new Bitmap();
			addChild(bg);
			
			var character:String = (App.data.personages.hasOwnProperty(questData.character)) ? App.data.personages[questData.character].preview : "octopus";
			var backPrev:String = (questData.backview > 0) ? questData.backview : '1';
			
			if(questData.character == 3){
				if(App.user.sex == 'm'){
					character = "boy";
				}else{
					character = "girl";
				}
			}
			Load.loading(Config.getImageIcon('quests/backings', backPrev), function(data:Bitmap):void 
			{
				backing.bitmapData = data.bitmapData;
				if (backPrev == '9')
				{
					backing.y = -3;
					backing.x = -6;
				}
				if (backPrev == '10')
				{
					Load.loading(Config.getImageIcon('quests/decor', backPrev+'decor'), function(data:Bitmap):void 
					{
						backingDecor = new Bitmap(data.bitmapData);
						//backingDecor.bitmapData = data.bitmapData
						addChild(backingDecor)
					});
				}
			});
			Load.loading(Config.getImageIcon('quests/icons', character), function(data:Bitmap):void 
			{
				removeChild(preloader);
				preloader = null;
				
				bg.bitmapData = data.bitmapData;
				bg.smoothing = true;
				bg.y = -12;
				resize();
				
				if (txtTime) {
					txtTime.x = (bg.width - txtTime.width) / 2;
					txtTime.y = bg.height - txtTime.height + 10;
				}
				
				if (timerLabel) {
					timerLabel.x = (bg.width - timerLabel.width) / 2;
					timerLabel.y = bg.height - timerLabel.height + 7;
				}
				
				
				
				iconNew = new Bitmap(UserInterface.textures.newQuestIco);
				Size.size(iconNew, 35, 35);
				iconNew.smoothing = true;
				iconNew.x = bg.x /*+ bg.height - iconNew.height*/ - iconNew.width / 4;
				iconNew.y = bg.y /*+ bg.width - iconNew.width*/;
				addChild(iconNew);
				for (var miss:* in App.user.quests.data[qID]){
					if (miss != "finished" && miss != "created"){
						//trace("Not new")
						iconNew.visible = false;
					}else{
						//if (qID == 21)
							//App.user.quests.openWindow(qID, true);
					}/*else{
						trace("Newww!!!")
					}*/
				}	
				
				iconTimer = new Bitmap(UserInterface.textures.timerQuest);
				iconTimer.x = bg.x -2;
				iconTimer.y = bg.y + 55;
				if (App.data.quests.hasOwnProperty(qID) && App.data.quests[qID].update && App.data.updates[App.data.quests[qID].update].hasOwnProperty('temporary') && App.data.updates[App.data.quests[qID].update]['temporary'] > 0)
					addChild(iconTimer);
				
			});
			
			// App.data.quests[qID];
			// App.user.quests.data[qID][missionNum]
			//if (newQuestIc)
			//{
				/*iconNew = new Bitmap(UserInterface.textures.attantion);
				iconNew.x = bg.x + (bg.height - iconNew.height) / 2;
				iconNew.y = bg.y + (bg.width - iconNew.width) / 2;
				addChild(iconNew);*/
				//iconNew.visible = false;
			//}
			
			
			
			/*icon = new Bitmap();
			addChild(icon);*/
			/*
			var mid:*
			for (var ind:* in questData.missions) {
				if (!mid) for each(mid in questData.missions[ind].target) break;
				if (!mid) for each(mid in questData.missions[ind].map) break;
			}
			
			if (qID == 28) mid = 6;
			if (qID == 341) mid = 852;
			if (questData.hasOwnProperty('backview') && questData.backview != '' && questData.backview != null && questData.backview != 'null') {
				Load.loading(Config.getImage('questIcons', questData.backview), function(data:Bitmap):void {
					icon.bitmapData = data.bitmapData;
					icon.smoothing = true;
					
					Size.size(icon, 50, 50);
					icon.filters = [new GlowFilter(0xccebf3, 1, 5, 5, 6)];
					
					resize();
				});
			} else {
				
			}*/
			
			
			//countTxt.x = backBmap.x;
			//countTxt.y = backBmap.y;
						
			
			//icon.x = backBmap.x + (icon.width - backBmap.width)/2
			
			addEventListener(MouseEvent.CLICK, onQuestOpen);
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
			
			newIcon = new Bitmap(Window.textures.star);
			newIcon.x = 46;
			newIcon.y = 5 - newIcon.height / 2;
			newIcon.visible = false;
			addChild(newIcon);
			
			if (!visibleQuest.hasOwnProperty(questData.ID)) {
				visibleQuest[questData.ID] = {visible:true};
			}
			
			var update:String = questData.update;
			if (App.data.updatelist.hasOwnProperty(App.social)) {
				if (App.data.updatelist[App.social][update] + Numbers.WEEK >= App.time && visibleQuest[questData.ID].visible) { 
					if (App.user.quests.data.hasOwnProperty(questData.ID) && App.user.quests.data[questData.ID].hasOwnProperty('viewed') && App.user.quests.data[questData.ID].viewed < App.time) {
						newIcon.visible = false;
					} else {
						newIcon.visible = true;
					}
				}
			}
			
			if (questData.duration > 0) {
				drawTime();
			}
			
			if (!App.user.quests.tutorial && item.fresh && isNewItem()) {
				glowIcon(1);
			}
				
			if (questData.hasOwnProperty('glow') && questData.glow == 1) {
				showGlowing();
			}
			
			if (Config.admin) {
				var guestIdLabel:TextField = Window.drawText(qID.toString() + '\n' + ((questData.update && App.data.updates[questData.update]) ? App.data.updates[questData.update].title : ''), {
					textAlign:	'center',
					width:		70,
					fontSize:	18,
					color:		0xffffff,
					borderColor:0x111111,
					multiline:	true,
					wrap:		true
				});
				guestIdLabel.y = 50;
				addChild(guestIdLabel);
			}
		}
		
		protected function isNewItem():Boolean
		{
			//for each (var item:* in QuestPanel.newQuests)
			for (var item:* in QuestPanel.newQuests)
			{
				if (item/*.id*/ == qID && (App.time - QuestPanel.newQuests[item]) < 10) return true;
			}
			return false;
		}
		
		public function resize():void {
			/*if (bg && bg.bitmapData)
				Size.size(bg, HEIGHT, HEIGHT);*/
			
			if (icon && icon.bitmapData) {
				if (bg && bg.bitmapData) {
					icon.x = 55 + (backBmap.width - icon.width) / 2 + 6;//bg.x + bg.width - icon.width + 6;
					icon.y = backBmap.y + (backBmap.height - icon.height) / 2;//bg.y + bg.height - icon.height;
					countTxt.x = icon.x + icon.width/2;
					countTxt.y = icon.y + icon.height/2 + 0;
					
					if (newIcon) {
						newIcon.x = 46;
						newIcon.y = 5 - newIcon.height / 2;
					}
				}else {
					icon.x = (HEIGHT - icon.width) / 2;
					icon.y = (HEIGHT - icon.height) / 2;
					countTxt.x = icon.x + icon.width + 10;
					countTxt.y = icon.y + icon.height - 5;
				}
			}
		}
		
		protected var txtTime:TextField;
		protected function drawTime():void 
		{
			if (!App.user.quests.data.hasOwnProperty(qID)) return;
			var textSettings:Object = {
				text:Locale.__e("flash:1382952379793"),
				color:0xffffff,
				fontSize:19,
				borderColor:0x073839,
				scale:0.5,
				textAlign:'center'
			}
			
			var time:int = App.user.quests.data[qID].created + questData.duration * 3600 - App.time; 
			if (App.data.quests[qID].update == addon.update && App.user.quests.data[qID].created + questData.duration * 3600 > Events.timeOfComplete && Events.timeOfComplete != 0) {
				time = Events.timeOfComplete - App.time;
			}
			txtTime = Window.drawText(TimeConverter.timeToStr(time), textSettings);
			updateDuration();
			addChild(txtTime);			
			
			txtTime.width = 95;
			txtTime.x = (bg.width - txtTime.width) / 2;
			txtTime.y = 55;// bg.height - txtTime.height + 10;
			
			App.self.setOnTimer(updateDuration);
		}
		
		private var timeID:uint;
		private var materialIcon:Bitmap;
		
		//public function glowIcon(text:String, timout:uint = 15000, isTimeOut:Boolean = true, type:uint = QuestPanel.NEW):void {
		public function glowIcon(missionNum:uint, timout:uint = 10000, isTimeOut:Boolean = true, type:uint = 2):void 
		{
			//icon = new Bitmap();
			
			//if (App.user.quests.tutorial)
				//QuestsRules.getQuestRule(qID, missionNum);
			//if (qID == 9)
				//App.user.quests.openWindow(9);
				
			clearTimeout(timeID);
			
			if (icon && icon.parent)
			{
				icon.parent.removeChild(icon);
				icon.bitmapData = null;
			}
				
			if (backBmap.parent)
			{
				backBmap.parent.removeChild(backBmap);
				countTxt.parent.removeChild(countTxt);
			}
			
			/*var text:String = Locale.__e('flash:1382952379743');
			if (type == QuestPanel.PROGRESS)
			text = Locale.__e('flash:1382952379797');*/
			
			backBmap = Window.separator2(134, 'backQuestIcon1', 'backQuestIcon2');
			backBmap.x = 55;
			backBmap.y = 0;
			backBmap.scaleX = backBmap.scaleY = .8;
			
			if (questData.missions[missionNum].target != null)
			{
				var mid:uint = questData.missions[missionNum].target[0];
				
			}else{
				trace("New Quest!!");
			}
			
			var text:String = String(App.user.quests.data[qID][missionNum] || 0) + '/' + String(questData.missions[missionNum].need);
			
			if (questData.missions[missionNum].event == 'upgrade')
			{
				var unitsSe:Array = Map.findUnits(questData.missions[missionNum].target);
				var have:String; 
				for each(var obj:* in unitsSe)
				{
						if (obj.type == 'Walkhero')
						{
							trace("Level = " + obj.model.level);
							trace("ID = " + obj.id);
							have = obj.model.level + 1;
							break;
						}
						else
							have = obj.level + 1;
				}
				if (have == null)
					have = '0';
				else
					have = String(int(have) - 1);
				text = have + '/' + String(questData.missions[missionNum].need);
			}
			else if ((questData.missions[missionNum].event == "grow") && (qID == 548 || qID == 556 || qID == 748 || qID == 950 || qID == 951 || qID == 952)) 
			{
				var mfloorsUnits:Array = Map.findUnits([questData.missions[missionNum].target[0]])
				var currMfloors:*;
				for (var i:int = 0; i < mfloorsUnits.length; i++)
				{
					if (qID == 548 && mfloorsUnits[i].id == 2)
					{
						currMfloors = mfloorsUnits[i];
						have = currMfloors.floor
					}
					else if (qID == 556 && mfloorsUnits[i].id == 1)
					{
						currMfloors = mfloorsUnits[i];
						have = currMfloors.floor
					}
					else 
					{
						currMfloors = mfloorsUnits[i];
						have = currMfloors.floor
					}
				}
				if ((have <= questData.missions[missionNum].need) && (App.user.quests.data[qID][missionNum] != questData.missions[missionNum].need)) 
				{
					text = have + '/' + String(questData.missions[missionNum].need);
				}
			}
			else if (questData.missions[missionNum].event == 'grow' && App.data.storage[questData.missions[missionNum].target[0]].type == 'Happy' && Map.findUnits(questData.missions[missionNum].target).length > 0)
			{
				var _hunit:* = Map.findUnits(questData.missions[missionNum].target)[0];
				have = _hunit.level;
				text = have + '/' + questData.missions[missionNum].need;
			}
			else if (questData.missions[missionNum].event == 'grow' && App.data.storage[questData.missions[missionNum].target[0]].type == 'Friendfloors' && Map.findUnits(questData.missions[missionNum].target).length > 0)
			{
				var _ffunit:* = Map.findUnits(questData.missions[missionNum].target)[0];
				have = _ffunit.model.floor;
				text = have + '/' + questData.missions[missionNum].need;
			}
			
			countTxt = Window.drawText(text, {
				color:0x713c1b,
				borderColor:0xffffff,
				textAlign:"left",
				autoSize:"left",
				fontSize:22
			});
			if (mid == 1)
				mid = 979;
			if (App.data.storage.hasOwnProperty(mid) && App.data.storage[mid].preview != '') 
			{
				Load.loading(Config.getIcon(App.data.storage[mid].type, App.data.storage[mid].preview), function(data:Bitmap):void {
					icon.bitmapData = data.bitmapData;
					icon.smoothing = true;
					
					Size.size(icon, 50, 50);
					icon.filters = [new GlowFilter(0xccebf3, 1, 5, 5, 6)];
					
					resize();
					
					icon.visible = true;
					
				});
				
			}
			if (mid == 0 && questData.missions[missionNum].target == null && questData.missions[missionNum].event == 'visit')
			{
				Load.loading(Config.getQuestIcon('missions', 'friends'), function(data:Bitmap):void {
					icon.bitmapData = data.bitmapData;
					icon.smoothing = true;
					
					Size.size(icon, 50, 50);
					icon.filters = [new GlowFilter(0xccebf3, 1, 5, 5, 6)];
					
					resize();
					
					icon.visible = true;
					
				});
			}
			
			addChild(backBmap);
			addChild(icon);
			addChild(countTxt);
			showGlowingOnce();
			//showGlowing();
			/*showPointing('right', -x, -y, this, text, { //показывает
				fontSize:		26,
				color:			0xffd84c,
				borderColor:	0x743d29,
				shadowSize:		2
			});*/
			
			if(isTimeOut){
				timeID = setTimeout(clear, timout);
			}
			
			//SoundsManager.instance.playSFX('sound_5');
		}
		
		public function clear():void {
			App.self.setOffTimer(updateDuration);
			
			//App.ui.leftPanel.questsPanel.change();
			clearTimeout(timeID);
			hideGlowing();
			hidePointing();
			//icon.visible = false;
			if (icon && icon.parent){
				icon.parent.removeChild(icon);
				}
			if(backBmap && backBmap.parent){
				removeChild(backBmap);
				removeChild(countTxt);
				icon.visible = false;
			}
			
		}
		
		public function onQuestOpen(e:MouseEvent = null):void {
			if (App.user.quests.tutorial) return;
			
			hideGlowing();
			hidePointing();
			
			if (newIcon && newIcon.visible == true) {
				newIcon.visible = false;
				visibleQuest[questData.ID].visible = false;
			}
			
			if (needClose) Window.closeAll();
			else needClose = true;
			
			if (App.data.quests[qID].bonus)
				App.user.quests.openWindow(qID);
		}
		public function onOver(e:MouseEvent):void {
			Effect.light(this, 0.15);
		}
		public function onOut(e:MouseEvent):void {
			Effect.light(this, 0);
		}
		
		public static function sendQuestClick(qID:int):void {
			Post.send( {
				ctr:'quest',
				act:'view',
				qID:qID,
				uID:App.user.id
			}, function(error:int, data:Object, params:Object):void {
				
			});
		}
		
		private function updateDuration():void {
			if (!App.user.quests.data[qID].hasOwnProperty('created')) {
				App.self.setOffTimer(updateDuration);
				return;
			}
			var time:int = App.user.quests.data[qID].created + questData.duration * 3600 - App.time;
			if (App.data.quests[qID].update == addon.update && App.user.quests.data[qID].created + questData.duration * 3600 > addonFinish && addonFinish != 0 && addonFinish > App.time) {
				time = addonFinish - App.time;
			}
			var daysToEnd:int = ((Math.floor((time / (60 * 60 * 24))))>1)?(Math.floor((time / (60 * 60 * 24)))):0;
			
			var timeValue:String = (daysToEnd)?Locale.__e("flash:1411744598574",daysToEnd):TimeConverter.timeToStr(time);
			
			txtTime.text = timeValue;
			
			if (time <= 0) {
				App.self.setOffTimer(updateDuration);
				App.ui.leftPanel.questsPanel.change();
			}
		}
		
		// Addon (Дополнение со временем)
		private var addonFinish:int = 0;
		private var addon:Object = {
			update:	'u566af0ca81b69',
			sid:	1302
		}
		/*private var addon2:Object = {
			update:	'562de476e0f54',
			sid:	1004
		}*/
		private function initAddon():void {
			var active:Boolean = false;
			for (var update:String in App.data.updatelist[App.social]) {
				if (addon.update == update && questData.update == addon.update && App.data.updates[addon.update].social.hasOwnProperty(App.social)) {
					active = true;
					break;
				}
			}
			
			if (active == false) return;
			
			/*var info:Object;
			if (addon.sid == 0) {
				if (App.data.top.hasOwnProperty(App.user.topID)) {
					info = App.data.top[App.user.topID];
					if (info.expire.hasOwnProperty('expire'))
						addonFinish = info.expire.e;
				} else return;
			}else {
				info = App.data.storage[addon.sid];
				if (info.type == 'Fatman') {
					addonFinish = Events.timeOfComplete;
				}
				else {
					if (info.expire[App.social]) {
						addonFinish = info.expire[App.social];
					}
				}
			}*/
			
			if (addonFinish > App.time && questData.duration <= 0) {
				drawTimer();
				updateAddon();
				App.self.setOnTimer(updateAddon);
			}
		}
		
		private function updateAddon():void {
			var time:int = addonFinish - App.time;
			timerLabel.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				App.self.setOffTimer(updateAddon);
				//App.ui.leftPanel.questsPanel.change(0,0);
			}
		}
		
		
		private function drawTimer():void {
			if (timerLabel) return;
			
			timerLabel = Window.drawText('', {
				color:			0xfeffbb,
				borderColor:	0x6f3203,
				fontSize:		17,
				width:			80,
				textAlign:		'center'
			});
			timerLabel.x = -9;
			timerLabel.y = 57;
			addChild(timerLabel);
			
		}
		public function dispose():void {
			removeEventListener(MouseEvent.CLICK, onQuestOpen);
			removeEventListener(MouseEvent.ROLL_OVER, onOver);
			removeEventListener(MouseEvent.ROLL_OUT, onOut);
			clear();
			if (parent) parent.removeChild(this);
		}
	}
}	