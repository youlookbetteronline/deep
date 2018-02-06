package wins 
{
	import com.greensock.TweenLite;
	import core.Numbers;
	import effects.Garland;
	import effects.NewParticle;
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import wins.elements.NParticle;

	public class QuestWindow extends Window
	{
		public var missions:Array = [];		
		public var okBttn:Button;		
		public var quest:Object = { };
		public var separator:Bitmap;
		public var isDuration:Boolean = false;
		public var character:Bitmap = new Bitmap();
		public var crab:Bitmap = new Bitmap();
		
		private var titleQuest:TextField;
		private var titleShadow:TextField;
		private var descLabel:TextField;
		private var timerText:TextField;		
		private var arrowLeft:ImageButton;
		private var arrowRight:ImageButton;		
		private var prev:int = 0;
		private var next:int = 0;
		private var background:Bitmap;
		private var _startMissionPosY:int = 140;		
		private var _winContainer:Sprite;
		
		public function QuestWindow(settings:Object = null)
		{
			settings['width'] = 510;
			settings['height'] = 600;
			settings['hasTitle'] = false;
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			settings["background"] = background;
			settings['hasFader'] = true;
			settings['autoClose'] = true;
			settings['qID'] = settings.qID || 2;
			settings['exitTexture'] = 'snowExit';
			settings["hasBubbles"] = true;
			settings["bubblesCount"] = 10;
			settings["bubbleLeftX"] =  - 90;
			
			quest = App.data.quests[settings.qID];
			
			super(settings);
			this.addEventListener(MouseEvent.CLICK, coordsCursor);
			settings.content = App.ui.leftPanel.questsPanel.shownList;
			
			for (var item:* in settings.content) 
			{
				if (settings.qID == settings.content[item].id)
				{
					if (settings.content[item + 1])
						next = settings.content[item + 1].id;
						
					if (settings.content[item - 1])
						prev = settings.content[item - 1].id;
					break;
				}
				//prev = item.id;
			}
			
			/*for each(item in App.ui.leftPanel.questsPanel.shownList)
			{
				if (next == -1)
				{
					next = item.id;
					break;
				}
				if (settings.qID == item.id) {
					next = -1;
				}
			}*/
			
			if (quest.duration > 0) {				
				isDuration = true;
			}
		}
		
		private function coordsCursor(e:*):void
		{
			trace('x: ' + (App.self.stage.mouseX - this.layer.x - 130) + ' y: ' + (App.self.stage.mouseY - this.layer.y - 15) );
		}
		
		override public function drawBackground():void 
		{
			//var background:Bitmap  = backing(settings.width, settings.height , 50, 'workerHouseBacking');
			
		}
		
		private var preloader:Preloader = new Preloader();
		public var bonusBackgroutnd:Bitmap = new Bitmap();
		
		override public function drawBody():void 
		{
			drawMessage();
			var btmp:Bitmap = Window.backingShort(150,'snowButtonLeft')
			okBttn = new ImageButton(btmp.bitmapData)
			/*okBttn = new Button( {
				width:150,
				height:50,
				fontSize:28,
				hasDotes:false,
				caption:Locale.__e("flash:1382952380242")
			});*/
			
			var bttnText:TextField = Window.drawText(Locale.__e("flash:1382952380242"), {
				fontSize:28,
				color:0xffffff,
				borderColor:0x633816,
				textAlign:'center'
			});
			
			

			
			okBttn.addEventListener(MouseEvent.CLICK, close);
			
			bodyContainer.addChild(preloader);
			preloader.x = -preloader.width + 30;
			preloader.y = bgHeight / 2 - preloader.height / 2 + 300;
			/*preloader.x = -138;
			preloader.y = 184;*/
			
			this.x += 130;
			if (fader) fader.x -= 130;
			
			this.y += 15;
			if (fader) fader.y -= 15;
			
			var characterPerv:String = (App.data.personages.hasOwnProperty(quest.character)) ? App.data.personages[quest.character].preview : "octopus";
			
			if (quest.character == 3 || quest.character == 18)
			{
				if (App.user.sex == 'm')
				{
					characterPerv = "boy";
				}else
				{
					characterPerv = "girl";
				}
			}
			
			Load.loading(Config.getQuestIcon('preview', characterPerv), function(data:*):void 
			{
				bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;
				var addY:int;
				
				switch(App.data.personages[quest.character].preview) 
				{
					case 'turtle':
						character.x = -character.width + 70;
						character.y =  character.height / 2 -100;
					break;
					default:
						character.x = -character.width + 60;
						character.y = bgHeight / 2 - character.height / 2;
						break;
				}
				
				bodyContainer.addChildAt(character,1);
				if (okBttn && separator)
				bodyContainer.swapChildren(separator, okBttn);
			});
			bonusBackgroutnd = backingShort(settings.width - 160, "questBackingBonus");
			
			var titleTextCenter:TextField = Window.drawText(Locale.__e('flash:1382952380000'), {
				width		:settings.width,
				fontSize	:30,
				autoSize	:"center",
				color		:0xffffff,
				borderColor	:0x235a82,
				borderSize	:4
			} );
			titleTextCenter.x = (settings.width / 2 - titleTextCenter.width / 2);
			titleTextCenter.y = descLabel.y + descLabel.height - 110;
			
			bodyContainer.addChild(bonusBackgroutnd);
			bonusList = new BonusList(quest.bonus.materials, false, {
				hasTitle:false,
				background:'rewardStripe',
				backingShort:true,
				width: 1909,
				height: 60,
				bgWidth:5000,
				bgX: 0,
				bgY:0,
				titleColor:0x571b00,
				titleBorderColor:0xfffed7,
				bonusTextColor:0xffffff,
				bonusBorderColor:0x235a82				
			} );
			
			if(!bonusList.parent)
				bodyContainer.addChild(bonusList);
				
			bonusBackgroutnd.x = 80;
			bonusBackgroutnd.y = titleTextCenter.y + titleTextCenter.height - 12;
			bonusBackgroutnd.alpha = .8;
			
			bonusList.x = (settings.width - bonusList.width) / 2 - 20;
			bonusList.y = bonusBackgroutnd.y + 10;
			
			
			
			bodyContainer.addChild(titleTextCenter);
			
			contentChange();
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = background.height - okBttn.height + 37;
			
			bttnText.x = okBttn.x + (okBttn.width - bttnText.width) / 2;
			bttnText.y = okBttn.y + (okBttn.height - bttnText.height) / 2 - 6;
			
			
			bodyContainer.addChild(okBttn);
			bodyContainer.addChild(bttnText);
			//drawMirrowObjs('decSeaweed', settings.width + 55, - 55, bgHeight - 177, true, true, false, 1, 1, layer);
			switch(App.data.personages[quest.character].preview) 
			{
				case 'turtle':
					character.x = -character.width + 70;
					character.y =  character.height / 2 -100;
				break;
				default:
					character.x = -character.width + 60;
					character.y = bgHeight / 2 - character.height / 2;
					break;
			}
			//character.y = bgHeight / 2 - character.height / 2;
			
			
			
			arrowLeft = new ImageButton(Window.textures.arrow, {scaleX:-.7,scaleY:.7});
			arrowRight = new ImageButton(Window.textures.arrow, {scaleX:.7, scaleY:.7});
			
			arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, onPrevQuest);
			arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, onNextQuest);
			
			if (prev > 0)
			{
				bodyContainer.addChild(arrowLeft);
				arrowLeft.x = okBttn.x - 30;
				arrowLeft.y = okBttn.y + (okBttn.height - arrowLeft.height) / 2;
			}
			
			if (next > 0)
			{
				bodyContainer.addChild(arrowRight);
				arrowRight.x = okBttn.x + okBttn.width + 30;
				arrowRight.y = okBttn.y + (okBttn.height - arrowRight.height) / 2;
			}
			
			settings.height = okBttn.y + okBttn.height + 16;
			if (isDuration)			
				drawTime();
			
			//exit.scaleX = exit.scaleY = 1.1;
			//exit.smoothing = true;
			//exit.x = background.width + positionsJSON['exit']['x'];
			//exit.y = background.y + positionsJSON['exit']['y'];
			exit.x = background.width - 60;
			//trace("x "+ exit.x)
			exit.y = background.y - 25;
			
			
			drawLamps();
		}
		private var points:Object = {
			'1':{
				'color':0xaedf18,
				'x':20,
				'y':51
			},
			'2':{
				'color':0x4ab5e4,
				'x':58,
				'y':79
			},
			'3':{
				'color':0xff6b57,
				'x':102,
				'y':81
			},
			'4':{
				'color':0xffc72d,
				'x':142,
				'y':74
			},
			'5':{
				'color':0xaedf18,
				'x':185,
				'y':57
			},
			'6':{
				'color':0x4ab5e4,
				'x':217,
				'y':29
			},
			'7':{
				'color':0xff6b57,
				'x':339,
				'y':35
			},
			'8':{
				'color':0x4ab5e4,
				'x':368,
				'y':73
			},
			'9':{
				'color':0xaedf18,
				'x':413,
				'y':80
			},
			'10':{
				'color':0xffc72d,
				'x':450,
				'y':82
			},
			'11':{
				'color':0x52f5ea,
				'x':507,
				'y':60
			}
		}
		
		private function drawLamps():void 
		{
			
			
			setInterval(setLight, 2400);
			
			var leftLamp:Bitmap = new Bitmap(Window.textures.lampsLeft)
			leftLamp.x = -5;
			leftLamp.y = 0;
			
			var lampsShadowLeft:Bitmap = new Bitmap(Window.textures.lampsShadowLeft)
			lampsShadowLeft.x = -14;
			lampsShadowLeft.y = -4;
			
			var rightLamp:Bitmap = new Bitmap(Window.textures.lampsRight)
			rightLamp.x = 315;
			
			var lampsShadowRight:Bitmap = new Bitmap(Window.textures.lampsShadowRight)
			lampsShadowRight.x = 302;
			lampsShadowRight.y = -3;
			
			bodyContainer.addChild(leftLamp);
			bodyContainer.addChild(lampsShadowLeft);
			bodyContainer.addChild(rightLamp);
			bodyContainer.addChild(lampsShadowRight);
			
		}
		
		private function setLight():void 
		{
			var pointArray:Array = Numbers.objectToArray(points);
			var countLamp:int = 4;
			for (var i:int = 0; i < countLamp; i++)
			{
				var index:int = int(Math.random() * pointArray.length);
				var garland:Garland = new Garland(bodyContainer, pointArray[index].x, pointArray[index].y, pointArray[index].color);
				pointArray.splice(index, 1);
			}
		}
		
		
		private var timerContainer:Sprite;
		public function drawTime():void {
			
			if (timerContainer != null)
				bodyContainer.removeChild(timerContainer);
				
			timerContainer = new Sprite();			
			var descriptionLabel:TextField = drawText(Locale.__e('flash:1393581955601'), {
				fontSize:32,
				textAlign:"left",
				color:0xff0000,
				borderColor:0xffffff
			});
			descriptionLabel.x = 0;
			descriptionLabel.y = 0;
			//timerContainer.rotation = -25;
			timerContainer.addChild(descriptionLabel);
			
			var time:int = App.user.quests.data[settings.qID].created + quest.duration * 3600 - App.time;
			var daysToEnd:int = ((Math.floor((time / (60 * 60 * 24))))>1)?(Math.floor((time / (60 * 60 * 24)))):0;

			var timeValue:String = (daysToEnd)?Locale.__e("flash:1411744598574", daysToEnd):TimeConverter.timeToStr(time);
			var timeTextParams:Object = {
				color:0xffdf34,
				letterSpacing:1,
				textAlign:"left",
				fontSize:32,
				borderColor:0x704320
			};
			
			timerText = Window.drawText(timeValue, timeTextParams);
			
			timerText.width = 200;
			timerText.y = descriptionLabel.y + descriptionLabel.textHeight;
			timerText.x = descriptionLabel.x;
			
			timerContainer.addChild(timerText);
			
			bodyContainer.addChild(timerContainer);
			timerContainer.x = -20;
			timerContainer.y = 10;
			
			//separator.y = timerContainer.y + (background.height - separator.height) / 2;
			
			updateDuration();
			App.self.setOnTimer(updateDuration);
		}
		
		private function updateDuration():void {
			App.data.quests
			var time:int = App.user.quests.data[settings.qID].created + quest.duration * 3600 - App.time;
			var daysToEnd:int = ((Math.floor((time / (60 * 60 * 24)))) > 1)?(Math.floor((time / (60 * 60 * 24)))):0;
			var timeValue:String = (daysToEnd)?Locale.__e("flash:1411744598574",daysToEnd):TimeConverter.timeToStr(time);
			timerText.text = timeValue;
			
			if (time <= 0) {
				timerText.visible = false;
				close();
			}
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
			
			var titlePadding:int = 20;
			var descPadding:int = 51;
			var descMarginX:int = 10;
			
			_winContainer = new Sprite();
			titleQuestContainer = new Sprite();
			
			//// Название квеста
			titleQuest = Window.drawText(quest.title, {
				color:0xf6e16b,
				borderColor:0x754217,
				fontSize:37,
				multiline:true,
				textAlign:"center",
				wrap:true,
				width:320			
			});
			titleQuest.wordWrap = true;
			
			var myGlow:GlowFilter = new GlowFilter();
			myGlow.strength = 20;
			myGlow.blurX = 5;
			myGlow.blurY = 5;
			myGlow.color = 0xfdf0d5;
			
			titleQuest.wordWrap = true;
			//titleQuest.border = true;
			titleQuest.width;
			
			var descSize:int = 28;
			
			do{
				descLabel = Window.drawText(quest.description, {
					color:0x624512, 
					border:false,
					fontSize:descSize,
					multiline:true,
					textAlign:"center"
				});
					
				descLabel.wordWrap = true;
				descLabel.width = settings.width - 100;
				descLabel.height = descLabel.textHeight + 44;
				//descLabel.border = true;
				descSize -= 1;	
			}
			while (descLabel.height > 140) 
		
			var curHeight:int;
			if (titleQuest.height < 60) {
				curHeight = titleQuest.height + descLabel.height + titlePadding;
			} else {
				curHeight = titleQuest.height + descLabel.height + titlePadding - 25;
			}
			
			if (curHeight < 170) {
				curHeight = 170;
			}
			
			curHeight += titleQuest.height *0.7;

			var marginSpriteY:int = 65;
			
			//var bg1:Bitmap = Window.backingShort(290, 'dividerLine', false);
			////separator.alpha = 0.47;
			//var bg:Bitmap = Window.backingShort(290,'dividerLine', false);
			////separator2.alpha = 0.47;
			//bg1.x = 75;
			//bg1.y = 13;
			//bg.x = 75;
			//bg.y = 73;
			//bodyContainer.addChild(bg1);
			//bodyContainer.addChild(bg);
			
			//bg = null/* backing2(431, curHeight,60, 'shopBackingTop', 'shopBackingBot');*///Window.backing(431, curHeight, 60, 'paperBacking');
			/*bg.y = _startMissionPosY + marginSpriteY - bg.height;
			bg.x = -90;*/

			titleQuest.height = titleQuest.textHeight + 10; 
			//titleQuest.y = titleQuest.height/2 - 170;
			titleQuest.x =  settings.width/2 - titleQuest.width / 2 - 110;
			descMarginX = 0;
			//descLabel.y = titleQuest.y + titleQuest.height - 7;
			
			titleQuest.y = 100;
			descLabel.y = titleQuest.y + titleQuest.height + 0;
			/*if (titleQuest.height >= 70)
			{
				descLabel.y = titleQuest.y + titleQuest.height - 10;
			}*/
			
			descLabel.x = titleQuest.x + titleQuest.width/2 - descLabel.width/2;
			
			//_winContainer.addChild(bonusBackgroutnd);
			titleQuestContainer.addChild(titleQuest);
			_winContainer.addChild(titleQuestContainer);
			_winContainer.addChild(descLabel);
			titleQuestContainer.filters = [myGlow];
			descLabel.filters = [myGlow];
			bodyContainer.addChild(_winContainer);
			
			_winContainer.x = 110;
			_winContainer.y = -marginSpriteY;
			
			exit.x = settings.width - exit.width * 0.4 + 85;
			exit.y = settings.height - exit.height * 0.4 + 3;
		}
		
		public function progress(mID:int):void {
			contentChange();
			for each(var item:Mission in missions) {
				if (item.mID == mID) {
					item.progress();
				}
			}
		}
		public var bgHeight:int;
		private var bonusList:Sprite;
		override public function contentChange():void {
			
			for each(var item:Mission in missions) {
				bodyContainer.removeChild(item);
				item.dispose();
				item = null;
			}
			missions = [];
			
			
			
			var margin:int = 0;
			if (isDuration) {
				margin = 0;
			}
			
			var blockBttn:Boolean = false;
			var itemNum:int = 0;
			for(var mID:* in quest.missions) {
				
				item = new Mission(settings.qID, mID, this);
				
				bodyContainer.addChild(item);
				item.x = (settings.width - item.background.width) / 2;
				item.y = bonusList.y + 60  + 100 * itemNum + margin + 10;
				
				missions.push(item);
				if (id == mID) 
				{
					item.progress();
				}
				if (App.user.quests.tutorial)
				{
					if (blockBttn && item.helpBttn)
					{
						item.helpBttn.state = Button.DISABLED;
					}
					
					if (!item.finishedM)
						blockBttn = true;
				}
				
				itemNum++;
			}
			
			if (settings.glowHelp) 
			{
				App.user.quests.glowHelp(this);
			}else{
			
				if (App.data.quests[settings.qID].track) 
				{
					App.user.quests.glowHelp(this);
				}
				
				if ((App.user.quests.data[103] && App.user.quests.data[103].finished == 0) || 
				(App.user.quests.data[5] && App.user.quests.data[5].finished == 0) || (settings.qID == 36))
				{
					App.user.quests.glowHelp(this);	
				}
			}
			
			//bgHeight = (6 + item.background.height) * itemNum + 334 + margin;
			bgHeight = bonusBackgroutnd.y + bonusBackgroutnd.height + 60  + (100) * itemNum ;
			layer.numChildren
			if (background)
				layer.removeChild(background)
			if (background2)
				layer.removeChild(background2)
			if (snowBottomLeft)
				layer.removeChild(snowBottomLeft)
			if (snowBottomRight)
				layer.removeChild(snowBottomRight)
			if (snowLeft)
				layer.removeChild(snowLeft);
			if (snowCenter)
				layer.removeChild(snowCenter);
			if (snowRight)
				layer.removeChild(snowRight);
			
			background = Window.backing(settings.width, bgHeight , 50, 'workerHouseBacking');
			
			background2  = Window.backing2(settings.width - 60, bgHeight - 54, 40, 'capsuleWindowBackingPaperUp', 'capsuleWindowBackingPaperDown');
			/*if (missions.length == 3)
			{
				bodyContainer.y = 50;
				exit.y = -45;
				background.y += 50;
			}*/
			background2.x = background.x + (background.width - background2.width) / 2;
			background2.y = background.y + (background.height - background2.height) / 2;
			
			
			
			layer.addChildAt(background2, 0);
			layer.addChildAt(background, 0);
			
			snowLeft = new Bitmap(Window.textures.snowLeft);
			snowLeft.y -= 35;
			layer.addChild(snowLeft);
			
			snowCenter = new Bitmap(Window.textures.snowCenter);
			snowCenter.y -= 34;
			snowCenter.x = 205;
			layer.addChild(snowCenter);
			
			snowRight = new Bitmap(Window.textures.snowRight);
			snowRight.y -= 29;
			snowRight.x = 365;
			layer.addChildAt(snowRight, layer.getChildIndex(background2) + 1);
			
			
			
			snowBottomLeft = new Bitmap(Window.textures.snowBottomCorner);
			snowBottomLeft.y = background.height - 158 + 65;
			snowBottomLeft.x = -112
			layer.addChildAt(snowBottomLeft, 0);
			
			snowBottomRight = new Bitmap(Window.textures.snowBottomCorner);
			snowBottomRight.scaleX = -1;
			snowBottomRight.y = background.height - 160 + 62;
			snowBottomRight.x = 550
			layer.addChildAt(snowBottomRight, 0);
			
			//bodyContainer.swapChildren(character, bodyContainer.getChildAt(0));
			//bodyContainer.addChild(character);
		}
		
		private var titleQuestContainer:Sprite;
		private var snowLeft:Bitmap;
		private var snowCenter:Bitmap;
		private var snowRight:Bitmap;
		private var snowBottomLeft:Bitmap;
		private var snowBottomRight:Bitmap;
		private var background2:Bitmap;
		//private var bg:Bitmap;
		
		override public function dispose():void 
		{
			if (okBttn)
				okBttn.removeEventListener(MouseEvent.CLICK, close);
			
			if (_winContainer && _winContainer.parent)_winContainer.parent.removeChild(_winContainer);
			_winContainer = null;
			
			App.self.setOffTimer(updateDuration);
			
			super.dispose();
		}
		
		override public function drawExit():void 
		{
			
			exit = new ImageButton(textures[this.settings.exitTexture]);
			headerContainer.addChild(exit);
			exit.x = settings.width - 49;
			exit.y = 17 - 20;
			if (!App.user.quests.tutorial)
				exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		override public function show():void 
		{
			super.show();
			if (App.user.worldID == User.LAND_2 && settings.qID == 684 && App.social == 'MM')
			{
				mmQuestCostile();
			}
		}
		
		private function mmQuestCostile():void 
		{
			var unts:Array = Map.findFieldUnits([1095]);
			if (unts.length == 0)
			{
				Post.send( {
					ctr:'quest',
					act:'score',
					uID:App.user.id,
					wID:App.user.worldID,
					score:JSON.stringify({684:{1:{1:1}}})
				},function(error:*, data:*, params:*):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
						App.user.stock.buy(2415, 1, function():void{});
					
				});
			}
		}
	}
}

import buttons.Button;
import buttons.ImageButton;
import buttons.MoneyButton;
import com.greensock.TweenMax;
import com.greensock.plugins.DropShadowFilterPlugin;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.setTimeout;
import ui.Hints;
import ui.QuestPanel;
import ui.UserInterface;
import units.Mfloors;
import units.Plant;
import utils.Locker;
import wins.Window;
import wins.SimpleWindow;
import wins.TravelWindow;

internal class Mission extends Sprite {
	
	public var qID:int;
	public var mID:int;
	public var background:Bitmap;
	public var bitmap:Bitmap = new Bitmap();	
	public var mission:Object = { };
	public var quest:Object = { };	
	public var counterLabel:TextField;
	public var titleLabel:TextField;	
	public var skipBttn:MoneyButton;
	public var helpBttn:Button;
	public var substructBttn:Button;
	public var skipForKeysBttn:ImageButton;
	public var finishedM:Boolean = false;
	
	private var preloader:Preloader = new Preloader();	
	private var window:*;
	private var titleDecor:Bitmap;
	
	public function Mission(qID:int, mID:int, window:*)
	{
		this.qID = qID;
		this.mID = mID;
		
		this.window = window;
		
		background = Window.backingShort(430, 'questTaskBackingNew', true);
		
		var bgHeight:int = background.height;		
		background.y = 7;
		background.alpha = .5;
		addChild(background);
		
		var iconCont:LayerX = new LayerX();
		addChild(iconCont);
		iconCont.addChild(bitmap);
		
		quest = App.data.quests[qID];
		mission = App.data.quests[qID].missions[mID];
		
		var sID:*;
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
			var pattern:RegExp = new RegExp(/[a-zA-Z]/);
			//trace(((String(mission.preview).search(pattern))==-1)?false:true);
			if (sID == 0 || sID == 1 || (mission.preview != "" && (((String(mission.preview).search(pattern)) ==-1)?false:true))) {
				url = Config.getQuestIcon('missions', mission.preview);
			}else {
				var icon:Object
				if (mission.preview != "" && mission.preview != "1") {
					icon = App.data.storage[mission.preview];
				}else{
					icon = App.data.storage[sID];
				}
				
				if (App.data.storage[sID].type == 'Zones')
				{
					url = Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
				}else
					url = Config.getIcon(icon.type, icon.preview);
			}
			var tipTitle:String;
			var tipDesc:String;
			/*if (App.data.storage[sID].type == 'Zones')
			{
				bitmap = new Bitmap(UserInterface.textures.openTerIcon);
				Size.size(bitmap, 80, 80);
				bitmap.smoothing = true;
				bitmap.filters = [new GlowFilter(0xffffff, 0.75, 4, 4, 7)];
				
				iconCont.addChild(bitmap);
				
				iconCont.x = 60 - (iconCont.width) / 2;
				iconCont.y = (bgHeight - iconCont.height) / 2;
				
				tipTitle = Locale.__e('flash:1453282521399');
				tipDesc = Locale.__e('flash:1484134500629');
				
			}else{*/
				loadIcon(url);
				
				tipTitle = App.data.storage[sID].title;
				tipDesc = App.data.storage[sID].description;
			//}
			if (App.data.storage[sID].type == 'Zones')
			{
				iconCont.tip = function():Object {
					return {
						title:Locale.__e('flash:1478095847335')
					};
				}; 
			}else{
				iconCont.tip = function():Object {
					return {
						title:tipTitle,
						text:tipDesc
					};
				}; 
			}
			
			if (App.user.quests.tutorial && App.user.quests.isFirstOpenMission(qID, mID)) 
			{
				if (helpBttn) 
				{
					helpBttn.showGlowing();
					helpBttn.showPointing('bottom', 0, helpBttn.y + helpBttn.height - 10, helpBttn.parent);
				}
			}
		}else{
			if (mission.event == "visit" && mission.target == null)
			{
				url = Config.getQuestIcon('missions', 'friends');
				loadIcon(url);
			}
		}
		
		function loadIcon(url:String):void 
		{
			addChild(preloader);
			preloader.x = 56;
			preloader.y = bgHeight / 2 + 5;
			
			Load.loading(url, function(data:*):void {
				
				removeChild(preloader);
				
				bitmap.bitmapData = data.bitmapData;
				
				Size.size(bitmap, 80, 80);
				
				bitmap.smoothing = true;
				
				iconCont.x = 60 - (iconCont.width) / 2;
				iconCont.y = (bgHeight - bitmap.height) / 2;
				
				bitmap.filters = [new GlowFilter(0xffffff, 0.75, 4, 4, 7)];
			});
		}
		
		var have:int = App.user.quests.data[qID][mID];
		
		var text:String; 
		if(mission.func == 'sum'){
			text = have + '/' + mission.need;
		}else if (mission.func == "subtract") {
			if (have >= mission.need) {
				text = have + '/' + mission.need;
			}else{
				text = App.user.stock.count(sID) + '/' + mission.need;
			}
		}else if (mission.event == "upgrade") {
			var unitsSe:Array = Map.findUnits([sID]);
			for each(var obj:* in unitsSe)
			{
				if (obj.type == 'Walkhero')
				{
					trace("Level = " + obj.model.level);
					trace("ID = " + obj.id);
					have = obj.model.level;
					break;
				}
				if (obj.level && obj.sid == sID){
					trace("Level = " + obj.level);
					trace("ID = " + obj.id);
					have = obj.level;
					break;
				}
			}
			if (have <= mission.need /*|| have == 0*/&& App.user.quests.data[qID][mID] != mission.need) {
				text = have + '/' + mission.need;
			}else{
				text = mission.need + '/' + mission.need;
			}
			//text = have + '/' + mission.need;
		}else if ((mission.event == "grow") && (qID == 548 || qID == 556 || qID == 748 || qID == 950 || qID == 951 || qID == 952)) {
		   var mfloorsUnits:Array = Map.findUnits([sID])
		   var currMfloors:Mfloors;
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
		   if (have <= mission.need && App.user.quests.data[qID][mID] != mission.need) 
		   {
				text = have + '/' + mission.need;
		   }
		}
		else if (mission.event == 'grow' && App.data.storage[mission.target[0]].type == 'Happy' && Map.findUnits(mission.target).length > 0)
		{
			var _hunit:* = Map.findUnits(mission.target)[0];
			have = _hunit.level;
			text = have + '/' + mission.need;
		}
		else if (mission.event == 'grow' && App.data.storage[mission.target[0]].type == 'Friendfloors' && Map.findUnits(mission.target).length > 0)
		{
			var _ffunit:* = Map.findUnits(mission.target)[0];
			have = _ffunit.model.floor;
			text = have + '/' + mission.need;
		}
		else {
			if (have == mission.need) {
				text = '1/'+ mission.need;
			}else {
				text = '0/' + mission.need;
			}
		}
		
		counterLabel = Window.drawText(text, {
			fontSize:32,
			color:0xffffff,
			borderColor:0x6e411e,
			autoSize:"left"
		});
		
		counterLabel.x = 60 - (counterLabel.width) / 2;
		counterLabel.y = 60;
		addChild(counterLabel);
		
		titleLabel = Window.drawText(mission.title, {
			fontSize:24,
			color:0x713f15,
			borderColor:0xffffff,
			multiline:true,
			borderSize:3,
			textAlign:"center",
			textLeading:-3
		});
		titleLabel.wordWrap = true;
		titleLabel.width = 180;
		titleLabel.height = titleLabel.textHeight+10;
		
		titleLabel.x = 110;
		titleLabel.y = (background.height - titleLabel.height) / 2 + 10;
		addChild(titleLabel);

		/*if (mission.func == "subtract") 
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
		}*/
		
		if (mission.func == "subtract")
		{
			if (have >= mission.need) // засчитано
			{
				drawFinished();
			} 
			else 
			{
				if(App.user.stock.count(sID) >= mission.need) // можно снять
				{
					if (App.user.stock.count(sID) > mission.need) 
						counterLabel.text=mission.need + '/' + mission.need;
					else	
						counterLabel.text= App.user.stock.count(sID) + '/' + mission.need;
					drawSubstructButtons();
				}	
				else
				{
					counterLabel.text = App.user.stock.count(sID) + '/' + mission.need;
					drawButtons();// не хватает для снятия
				}
			}
		}
		else
		{
			if (have >= mission.need) 
			{
				drawFinished();
			}
			else
			{
				drawButtons();
			}
		}
		//checkFinish();
	}
	
	
	/*private function checkFinish():void 
	{
		if (mission.controller == "booster" && mission.event == "buy")
		{
			var _targets:Array = Map.findUnits([mission.target[0]]);
			if (_targets.length > 0)
			{
				App.user.quests.finishQuest(qID, mID);
			}
		}
	}*/
	
	private function drawSubstructButtons():void 
	{
		if (mission.noskip != 1)
		{
			if(!window.isDuration && !(App.user.quests.tutorial)){
				skipBttn = new MoneyButton( {
					title: Locale.__e("flash:1424942592614"),
					caption:Locale.__e("flash:1424942592614"),
					countText:String(mission.skip),
					iconScale: .8,
					width:115,
					height:42,
					fontSize:(App.lang == 'de') ? 18 : 22,
					bgColor:[0xbaf76e,0x68af11],
					//borderColor:[0xa0d5f6, 0x53742d],
					fontColor:0xFFFFFF,
					fontCountBorder:0x53742d,
					fontBorderColor:0x53742d,
					bevelColor:[0xd8e7ae,0x4f9500]
				})
				
				addChild(skipBttn);
				skipBttn.x = background.width - skipBttn.width - 8;
				//skipBttn.y = 12;
				skipBttn.countLabel.width = skipBttn.countLabel.textWidth + 5;
				
				skipBttn.addEventListener(MouseEvent.CLICK, onSkipEvent);
			}
		}
		substructBttn = new Button( { 
			caption:Locale.__e('flash:1433939122335'),
			width:115,
			height:38,
			fontSize:22,
			radius:12
		});
		substructBttn.x = background.width - substructBttn.width - 30;
		substructBttn.y = 12;
		if (!skipBttn)
			substructBttn.y = 34;
		substructBttn.name = 'mission';
		if (App.user.quests.tutorial){
			substructBttn.y = 35;
		}
		if(skipBttn)
			skipBttn.y = substructBttn.y + substructBttn.height + 4;
		/*else{
			substructBttn.name = 'mission';
			substructBttn.y = 33;
		}*/
		
		substructBttn.textLabel.x = 8;
		substructBttn.x = background.width - substructBttn.width - 8;
		
		var takenedIconBttn:Bitmap = new Bitmap(Window.textures.takenedItemsIco);
		Size.size(takenedIconBttn, 28, 28);
		//takenedIconBttn.scaleX = takenedIconBttn.scaleY = 0.75;
		takenedIconBttn.smoothing = true;
		takenedIconBttn.x = substructBttn.width - takenedIconBttn.width - 10;
		takenedIconBttn.y = (substructBttn.height - takenedIconBttn.height)/2;
		substructBttn.addChild(takenedIconBttn);
		
		addChild(substructBttn);
		//App.ui.flashGlowing(substructBttn, 0xFFFF00, null, false);
		substructBttn.showGlowing(0xFFFF00);
		substructBttn.addEventListener(MouseEvent.CLICK, onSubstructEvent);
		
		if (window.isDuration)
			substructBttn.y = (background.height - substructBttn.height) / 2 + 6;
			
		/*if (App.user.quests.tutorial) 
		{
			if (window.pointedMission && window.pointedMission != this)
				return;
			
			glowingSubstructBttn();
			substructBttn.showPointing('top', 0, 0, this);
		}else 
		{*/
			glowingSubstructBttn();
		//}
	}
	
	private function glowingSubstructBttn():void 
	{
		customGlowing(substructBttn, glowingSubstructBttn);
	}
	
	private function customGlowing(target:*, callback:Function = null):void 
	{
		TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void 
		{
			TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void 
			{
				if (callback != null) 
				{
					callback();
				}
			}});	
		}});
	}
	
	private function onSubstructEvent(e:MouseEvent):void 
	{
		App.user.quests.subtractEvent(qID, mID, window.progress);
	}	
	
	private function drawFinished():void 
	{
		finishedM = true;
		var underBg:Shape = new Shape();
		underBg.graphics.beginFill(0xceaa7a);
		underBg.graphics.drawCircle(0, 0, 36);
		underBg.graphics.endFill();
		underBg.filters = [new DropShadowFilter(3, 90, 0, .4, 4, 4, 1, 1, true), new DropShadowFilter(3, -90, 0xffffff, .4, 4, 4, 1, 1, true)]
		//var underBg:Bitmap = new Bitmap(Window.textures.instCharBacking, "auto", true);
		addChild(underBg);
		underBg.x = background.width - underBg.width + 10;
		underBg.y = background.height / 2 + 10;
		
		var finished:Bitmap = new Bitmap(Window.textures.checkMark, "auto", true);
		addChild(finished);
		finished.x = background.width - finished.width - 27;
		finished.y = (background.height - finished.height) / 2 + 5;
	}
	
	private function drawButtons():void 
	{
		if (mission.noskip != 1)
			if (!window.isDuration && !(App.user.quests.tutorial)) 
			{
				//App.data.storage
				skipBttn = new MoneyButton( {
					title: Locale.__e("flash:1424942592614"),
					caption:Locale.__e("flash:1424942592614"),
					countText:String(mission.skip),
					iconScale: .7,
					width:115,
					height:42,
					fontCountSize:20,
					fontSize:(App.lang == 'de') ? 18 : 20,
					bgColor:[0xbaf76e,0x68af11],
					//borderColor:[0xa0d5f6, 0x53742d],
					fontColor:0xFFFFFF,
					fontCountBorder:0x53742d,
					fontBorderColor:0x53742d,
					bevelColor:[0xd8e7ae,0x4f9500]
				})
				
				addChild(skipBttn);
				skipBttn.x = background.width - skipBttn.width - 8;
				skipBttn.countLabel.width = skipBttn.countLabel.textWidth + 5;
				
				/*if (skipBttn.textLabel.height < 20) {
					
					skipBttn.textLabel.y -= 7;
				}
				
				if (App.lang == 'de') 
				{
					skipBttn.textLabel.y += 5;
					skipBttn.textLabel.x += 2;
				}	*/
				//skipBttn.textLabel.y -= 6;
				
				skipBttn.addEventListener(MouseEvent.CLICK, onSkipEvent);
				
				drawSkipForKeysButton();
			}	
		
		helpBttn = new Button( {
			caption:Locale.__e('flash:1382952380254'),
			width:115,
			height:40,
			borderColor:[0xb5dbff,0x386cdc],
			fontColor:0xFFFFFF,
			fontBorderColor:0x235a82,
			bevelColor:[0xb8d5f2, 0x4465b6],
			bgColor:[0x81c5f1,0x5a80d0],
			fontSize:22,
			radius:12
		});
		
		addChild(helpBttn);
		helpBttn.x = background.width - helpBttn.width - 8;
		helpBttn.y = 12;
		if (skipBttn)
		{
			if (!window.isDuration) 
			{
				skipBttn.y = 54;
			} else 
			{
				skipBttn.y = helpBttn.height ;
			}
		}else
		{
			helpBttn.y = 34;
		}
		helpBttn.settings['find'] = mission.find;
		helpBttn.name = 'mission';
		
		helpBttn.addEventListener(MouseEvent.CLICK, onHelpEvent);
	}
	
	private function drawSkipForKeysButton():void {
		var buttonTexture:BitmapData = Window.textures.checkBox;
		
		skipForKeysBttn = new ImageButton(buttonTexture, {
			caption:"",
			fontSize:20,
			fontColor:0xcbe6f0,
			fontBorderColor:0x1e6387,
			bgColor:[0x4dc4de, 0x4391b9],
			borderColor:[0xf8f2bd, 0x836a07]
		});
		
		addChild(skipForKeysBttn);
		skipForKeysBttn.x = skipBttn.x + skipBttn.width;
		skipForKeysBttn.y = 8;
		skipForKeysBttn.addEventListener(MouseEvent.CLICK, onSkipForKeysEvent);
		
		skipForKeysBttn.visible = App.user.stock.check(Stock.KEY, 1);
	}
	
	private function onHelpEvent(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		/*if (App.user.quests.tutorial)
		{
			window.close();
			return
		}*/
		/*if (qID == 582 && mID == 1)
		{
			Locker.availableUpdate();
			return;
		}*/
		App.ui.leftPanel.questsPanel.focusedOnQuest(qID, mID, QuestPanel.PROGRESS);
		if (App.data.quests[qID].missions[mID].find == 10)
		{
			/*Locker.availableQuest();
			return;*/
			new SimpleWindow( {
				hasTitle:true,
				label:SimpleWindow.ATTENTION,
				text			:Locale.__e("flash:1482142336166") + '\n' + Locale.__e('flash:1507967972859'),
				//text:Locale.__e("flash:1482142336166"),//Что-то новенькое! Стоит поискать подробности в обновлениях
				popup:true,
				dialog:true,
				confirm:function():void{
					for (var _qID:* in App.data.quests)
					{
					
						if (App.data.quests[_qID].hasOwnProperty('bonus') && App.data.quests[_qID].bonus != null)
						{
							if (App.data.quests[_qID].bonus.hasOwnProperty('materials') && App.data.quests[_qID].bonus.materials != '')
							{
								for (var bID:* in App.data.quests[_qID].bonus.materials)
								{
									if (bID == int(App.data.quests[qID].missions[mID].target[0]))
									{
										utils.Finder.questInUser(_qID, true);
										//new QuestsChaptersWindow({find:[qID], popup:true}).show();
										return;
									}
									
								}
							}

						}
					}
				}
			}).show();
			return;
		}
		if (App.data.quests[qID].missions[mID].find == 15)
		{
			App.ui.bottomPanel.friendsPanel.bttnPrevAll.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			setTimeout(function():void{
				App.ui.bottomPanel.friendsPanel.showPointing("top", -0, 0, App.ui.bottomPanel.friendsPanel.parent, "", null, false);
				App.ui.bottomPanel.friendsPanel.startGlowing();
				setTimeout(function():void {
				App.ui.bottomPanel.friendsPanel.hidePointing();
				App.ui.bottomPanel.friendsPanel.hideGlowing();					
				}, 3500)					
			}, 500)
			
			window.close();
			return
		}
		if (App.user.worldID != 806 && ( qID == 57 || (qID == 144 && mID == 1)))
		{
			new TravelWindow( {
				find:	806,
				popup:	true
			}).show();
			return;
			//new TravelWindow({'find':806}).show();
		}
		if (e.currentTarget.settings.find > 0) {
			
			Window.closeAll();
			App.user.quests.helpEvent(qID, mID);
		}else if (App.user.quests.tutorial) {
			if (qID == 116)
				QuestsRules.quest116_1();
			
			return;
		}else //if (qID == 34 && mID == 1){
		if (App.data.quests[qID].missions[mID].event == 'visit' && App.data.quests[qID].missions[mID].target && App.data.quests[qID].missions[mID].target[0] == 1)
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
		
		}else{
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
				text:App.data.quests[qID].missions[mID].description
			}).show();
		}
	}
	
	public function onSkipEvent(e:MouseEvent):void 
	{
		if (App.user.quests.skipEvent(qID, mID, window.progress, false)) 
		{
			var pnt:Point = Window.localToGlobal(skipBttn)
			var pntThis:Point = new Point(pnt.x - 130, pnt.y - 10);
			Hints.minus(Stock.FANT, mission.skip, pntThis, false, window);
			skipBttn.removeEventListener(MouseEvent.CLICK, onSkipEvent);
		};
	}
	
	private function onSkipForKeysEvent(e:MouseEvent):void {
		if (!App.user.quests.tutorial && App.user.quests.skipEvent(qID, mID, window.progress, true)) 
		{
			// раскомментировать нижние 3 строки, если захочется красоты и спецэффектов
			//var keySkipPoint:Point = Window.localToGlobal(skipForKeysBttn);
			//var keySkipPointThis:Point = new Point(keySkipPoint.x - 100, keySkipPoint.y - 10);
			//Hints.minus(Stock.KEY, 1, keySkipPointThis, false, window);
			skipForKeysBttn.removeEventListener(MouseEvent.CLICK, onSkipForKeysEvent);
		}
	}
	
	public function progress():void {
		App.ui.flashGlowing(bitmap, 0xFFFF00, null, false);
	}
	
	public function dispose():void {
		if(skipBttn != null){
			skipBttn.removeEventListener(MouseEvent.CLICK, onSkipEvent);
		}
		
		if(skipForKeysBttn != null){
			skipForKeysBttn.removeEventListener(MouseEvent.CLICK, onSkipForKeysEvent);
		}
	}
}