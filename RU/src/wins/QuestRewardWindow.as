package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import strings.Strings;
	import ui.TipsPanel;
	import units.Animal;
	import units.Hero;
	import units.Techno;
	import units.Unit;

	public class QuestRewardWindow extends Window
	{
		public static const QUESTS:String = "quests";
		public static const DAYLICS:String = "daylics";
		
		public var questType:String = QUESTS;
		public var materials:Object = { };
		public var title:String = "";		
		public var okBttn:Button;		
		public var quest:Object = { };
		public var bonusList:CollectionBonusList;
		
		private var titleQuest:TextField;		
		private var descLabel:TextField;/*
		private var bonusList:RewardList;*/
		private var levelRew:Boolean = false;		
		private var _startMissionPosY:int = 174;		
		private var _winContainer:Sprite;		
		private var checkBox:CheckboxButton
		
		public function QuestRewardWindow(settings:Object = null) 
		{
			settings['width'] = 500;
			settings['height'] = 360;			
			settings['hasTitle'] = false;
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			settings['callback'] = settings.callback || null;			
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;			
			settings['popup'] = true;
			levelRew = settings.levelRew || false;
			settings['qID'] = settings.qID || 2;
			//settings['openSound'] = 'sound_6';
			quest = settings.quest?settings.quest:App.data.quests[settings.qID];
			
			//super(settings);
			
			if (settings.hasOwnProperty('type')) 
			{
				questType = settings.type;
			}
			
			if (settings.levelRew) 
			{
			}
			else{
				if(questType == DAYLICS) {
					quest = App.data.daylics[settings.qID];
					materials = quest.bonus;
					if (settings.qID == 1 || settings.qID == 2) {
						title = Locale.__e('flash:1478007800211', [String(settings.qID)]); // 'Задание 1/2 успешно пройдено!';
					}else{
						title = Locale.__e("flash:1478006864518");
					}				
				}else {			
					//quest = App.data.quests[settings.qID];
					quest = App.data.quests[settings.qID];
					materials = quest.bonus.materials;
					
					if (App.data.quests[settings.qID].type == 5)
						title = quest.title;
					else
						title = Locale.__e("flash:1424346258637", quest.title);
				}
			}
			
			super(settings);
			
			SoundsManager.instance.playSFX('sound_6');
			TipsPanel.hide();
		}
		private var photographer:*
		
		override public function show():void 
		{
			if (App.user.quests.tutorial)
				QuestsRules.clear();
			
			
			bonusList = new CollectionBonusList((quest.bonus.hasOwnProperty('materials'))?quest.bonus.materials:quest.bonus, true);
			if(settings.width < bonusList.width + 140)
				settings.width = bonusList.width + 140;
			super.show();
			//
			if ([2, 5, 7, 19, 135, 4, 12, 132, 59].indexOf(int(settings.qID)) >= 0) {
				visible = false;
				close();
			}
			
			if (settings.qID == 561){
				var place:Object = App.user.hero.findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:App.user.hero.coords.x, z:App.user.hero.coords.z}}, 10);
				photographer = Unit.add({sid:Techno.PHOTOGRAPHER, x:place.x, z:place.z});
				photographer.buyAction();
				photographer.take();
			}
			
			if (settings.qID == 559)
			{
				var unitToDelete:* = Map.findUnits([Techno.PHOTOGRAPHER])[0];
				unitToDelete.removable = true;
				unitToDelete.onApplyRemove();
				
			}
		}
		
		override public function close(e:MouseEvent = null):void 
		{
			if (settings.qID == 454)
			{
				var farmer:* = Unit.add({sid:Techno.TECHNO_FARMER, x:51, z:18});
				farmer.buyAction();
				farmer.take();
			}
			
			super.close();
		}
		
		private var background:Bitmap;
		
		override public function drawBackground():void 
		{
		}
		
		private var preloader:Preloader = new Preloader();
		private var stripe:Bitmap;
		private var upperPart:Bitmap;
		private var descLabelBacking:Bitmap;
		
		override public function drawBody():void 
		{
			var fishesBackingPart:Bitmap = new Bitmap(Window.textures.questRewardFishes);
			fishesBackingPart.x = -170;
			fishesBackingPart.y = -10;
			layer.addChildAt(fishesBackingPart, 0);
			
			background = backing2(settings.width, settings.height, 80, 'levelUpBackingUp', 'levelUpBackingBot');
			//background  = backing2(settings.width, settings.height , 50, 'itemBackingPaperBigDrec', 'itemBackingPaperBig');
			layer.addChildAt(background, 1);
			background.x = - background.width/4 + 25;
			background.y = 110;
			
			upperPart = new Bitmap(Window.textures.questRewardWooden);
			upperPart.x = background.x + (background.width - upperPart.width) / 2;
			upperPart.y = background.y - upperPart.height + 10;
			upperPart.smoothing = true;
			bodyContainer.addChild(upperPart);
			
			drawMirrowObjs('decSeaweed', background.x + settings.width + 57, background.x - 57, background.y + settings.height - 172, true, true, false, 1, 1, layer);
			
			var upperPartText:TextField = Window.drawText(Locale.__e("flash:1382952380249"), {
				color:0xffe348, 
				borderColor:0xa35514,
				fontSize:42,
				textAlign:"center"
			});
			
			bodyContainer.addChild(upperPartText);
			upperPartText.width = upperPartText.textWidth + 20;
			upperPartText.x = upperPart.x + (upperPart.width - upperPartText.width) / 2;
			upperPartText.y = upperPart.y + (upperPart.height - upperPartText.height) / 2 + 30;
			//upperPartText.filters = [new GlowFilter(0xffffff, .7, 4, 4, 6)]; 
			
			var paperBack:Bitmap = backing(background.width - 100, background.height - 108, 40, 'paperClear');
			layer.addChild(paperBack);
			paperBack.x = background.x + (background.width - paperBack.width) / 2;
			paperBack.y = background.y + 50;
			
			var star1:Bitmap = new Bitmap(Window.textures.decStarYellow);
			bodyContainer.addChild(star1);
			star1.x = upperPart.x + 20;
			star1.y = upperPart.y + 100;
			
			var star2:Bitmap = new Bitmap(Window.textures.decStarBlue);
			bodyContainer.addChild(star2);
			star2.x = upperPart.x + upperPart.width - 100; 
			star2.y = upperPart.y + 88;
			
			var levelCrab:Bitmap = new Bitmap(Window.textures.levelUpCrab);
			layer.addChild(levelCrab);
			levelCrab.x = background.x + 35;
			levelCrab.y =  background.y + settings.height - levelCrab.height;
			
			exit.visible = false;
			
			this.x += 120;
			fader.x -= 120;
			this.y -= 40;
			fader.y += 40;
			
			bodyContainer.addChild(preloader);
			preloader.x = upperPart.x + (settings.width - preloader.width) / 2 + 11;
			preloader.y = upperPart. y + 49;
			
			drawMessage();			
			
			okBttn = new Button( {
				borderColor:			[0xfeee7b,0xb27a1a],
				fontColor:				0xffffff,
				fontBorderColor:		0x814f31,
				bgColor:				[0xf5d159, 0xedb130],
				width:162,
				height:50,
				fontSize:32,
				hasDotes:false,
				caption:Locale.__e("flash:1393582068437")
			});
			
			bodyContainer.addChild(okBttn);
			okBttn.name = 'QuestRewardWindow_okBttn';
			okBttn.addEventListener(MouseEvent.CLICK, onTakeEvent);			
			
			/*var character:Bitmap = new Bitmap();
			
			var characterPerv:String = (App.data.personages.hasOwnProperty(quest.character)) ? quest.character : "1";
			
			if(quest.character == 3){
				if(App.user.sex == 'm'){
					characterPerv = "boy";
				}else{
					characterPerv = "girl";
				}
			}
			
			Load.loading(Config.getImage('questIcons', characterPerv), function(data:*):void {
				bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;
				
				switch(App.data.personages[quest.character].preview) {
					
					default:
						character.x = (settings.width - character.width)/2;
						character.y = -character.height / 2;
						break;
				}
			});*/
			
			contentChange();
			
			okBttn.x = background.x + (settings.width - okBttn.width) / 2;
			okBttn.y = background.y + settings.height - okBttn.height/2;
			okBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			
			checkBox = new CheckboxButton({
				//width			:(App.lang=='en')?90:145,
				multiline		:false,
				wordWrap		:false,
				fontSize		:22,
				fontSizeUnceked	:22
			});
			
			if (!levelRew && !(App.user.quests.tutorial)) 
			{	
				if (!App.isSocial('SP') && !App.isJapan()) 
				{
					bodyContainer.addChild(checkBox);
				}				
				checkBox.x = okBttn.x + (okBttn.width - 170) / 2;
				checkBox.y = paperBack.y + paperBack.height - checkBox.height - 25;	
			}	
			
			var titlePadding:int = -10;
			
			var descMarginX:int = 10;
			
			_winContainer = new Sprite();
			
			titleQuest = Window.drawText(Locale.__e('flash:1382952380249'), {
				color:0x68350a,
				borderColor:0xfef2dc,
				borderSize:4,
				fontSize:36,
				multiline:true,
				textAlign:"center"
			});
			titleQuest.wordWrap = true;
			titleQuest.width = 420;
			titleQuest.height = titleQuest.textHeight + 10; 
			
			//var descText:String = "";
			/*if (App.data.quests[settings.qID].type == 5){
				descText = quest.title 
			}else{
				descText = Locale.__e('flash:1424346258637',quest.title)
			}
			if(questType == DAYLICS) {
				descText = Locale.__e('flash:1424346258637', [String(settings.qID)])
			}*/
			
			
			var descSize:int = 28;
			if (!levelRew) 
			{
				do{					
					descLabel = Window.drawText(title, {//quest.description.replace(/\r/g,""), {
						fontSize:descSize,
						color:0x713f15,
						borderColor:0xffffff,
						multiline:true,
						borderSize:3,
						autoSize: "center",
						textAlign:"center",
						textLeading:-3
					});
						
					descLabel.wordWrap = true;
					descLabel.width = 380;
					descLabel.height = descLabel.textHeight + 10;
					//descLabel.border = true;
					
					descSize -= 1;	
				}
				while (descLabel.height > 90) 
				
				/*if (questType == DAYLICS) 
				{
					descLabel.visible = false;	
				}
				*/
				var curHeight:int = titleQuest.height + descLabel.height + titlePadding*2;
				if (curHeight > 240) curHeight = 240;
				if (curHeight < 200) curHeight = 200;
				
				var marginSpriteY:int = 65;
				
				titleQuest.y = upperPart.y + (upperPart.height - titleQuest.height)/2  + 110;
				titleQuest.x = upperPart.x + (upperPart.width - titleQuest.width)/2;
				if(descLabel.numLines == 2)
					descLabel.y = upperPart.y + upperPart.height + (descLabel.textHeight / 2) + 30;
				else
					descLabel.y = upperPart.y + upperPart.height + (descLabel.textHeight / 2) + 66;
				
				descLabel.x = background.x + (background.width - descLabel.width) / 2;
				bodyContainer.addChild(descLabel);
				
				var descLabelBacking:Bitmap = Window.backingShort(descLabel.textWidth + 60, 'backingGrad', true);
				descLabelBacking.scaleY = 1;
				if(descLabel.numLines == 2)
					descLabelBacking.scaleY = 1.5;
					
				descLabelBacking.alpha = .7;
				descLabelBacking.smoothing = true;
				descLabelBacking.x = descLabel.x + (descLabel.width - descLabelBacking.width) / 2 + 0;
				descLabelBacking.y = descLabel.y + (descLabel.textHeight - descLabelBacking.height) / 2 + 0;
				bodyContainer.addChild(descLabelBacking);
				bodyContainer.swapChildren(descLabel, descLabelBacking);
			}
			bodyContainer.addChild(_winContainer);
			
			_winContainer.x = (settings.width - _winContainer.width) / 2 + 74;
			_winContainer.y = _startMissionPosY - _winContainer.height;
			
			addIcon();			
		}
		
		private function onTakeEvent(e:MouseEvent):void 
		{
			if (checkBox.checked == CheckboxButton.CHECKED&&!levelRew) onTellEvent(e);
			bonusList.take();
			if ((settings.qID == 234 || settings.qID == 225) && App.user.hero)
				App.user.hero.checkPet();
			
			if (App.user.quests.tutorial && settings.qID == 5)
			{
				QuestsRules.clear();
				//Window.hasType
				//Window.closeAll();
			}
			//if (App.user.quests.tutorial && settings.qID == 9)
			//{
				//App.user.quests.stopTrack();
				//App.user.quests.tutorial = false;
				//QuestsRules.quest59();
				//Window.closeAll();
			//}
			close();
		}
		
		private function onTellEvent(e:MouseEvent):void 
		{
			//Пост на стену
			if (questType !=DAYLICS || !App.user.quests.tutorial) 
			{
				WallPost.makePost(WallPost.QUEST, {quest:quest, qID:settings.qID});
			}
			
			bonusList.take();
			close();
		}		
		
		private function drawMessage():void
		{			
		}
		
		private function addIcon():void
		{
			var persIcon:Bitmap = new Bitmap();
			var spriteMask:Bitmap = new Bitmap();
			
			var characterPerv:String = (App.data.personages.hasOwnProperty(quest.character)) ? String(quest.character) : "1";
			
			if(quest.character == 3 || quest.character == 18){
				if(App.user.sex == 'm'){
					characterPerv = "boy";
				}else{
					characterPerv = "girl";
				}
			}
			
			Load.loading(Config.getImage('questIcons', characterPerv), function(data:*):void {
				bodyContainer.removeChild(preloader);
				persIcon.bitmapData = data.bitmapData;
				
				var addY:int;
				
				switch(App.data.personages[quest.character].preview)
				{
					/*case 'firstPers':
						persIcon.x = upperPart.x + (upperPart.width - persIcon.width)/2 + 15;
						persIcon.y = upperPart.y - 170;
					break;*/
					case 'turtle':
						persIcon.x = upperPart.x + (upperPart.width - persIcon.width) / 2
						persIcon.y = upperPart.y + upperPart.height - persIcon.height - 68;
					break;
					default:
						persIcon.x = upperPart.x + (upperPart.width - persIcon.width) / 2
						persIcon.y = upperPart.y + upperPart.height - persIcon.height - 68;
					break;
				}
				
				/*var square:Shape = new Shape(); 
				square.graphics.lineStyle(1, 0x000000); 
				square.graphics.beginFill(0x000000); 
				square.graphics.drawRect(-300, -300, App.self.stage.stageWidth, 400); 
				square.graphics.endFill(); 
				layer.addChild(square);
				layer.addChild(square);*/
				
				bodyContainer.addChild(persIcon);
			})			
		}		
		
		override public function contentChange():void 
		{
			
			bonusList = new CollectionBonusList((quest.bonus.hasOwnProperty('materials'))?quest.bonus.materials:quest.bonus, true/*, {settings.width: - 50, Locale.__e("flash:1382952380000"), 0.4}*/);
			bodyContainer.addChild(bonusList);
			bonusList.x = background.x + (settings.width - bonusList.width) / 2 - 10;
			bonusList.y = 250;
			if (App.user.quests.tutorial) 
			{
				bonusList.y = 280;
			}
		}	
		
		override public function dispose():void 
		{
			okBttn.removeEventListener(MouseEvent.CLICK, close);			
			super.dispose();
		}		
	}
}
