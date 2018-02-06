package wins.happy 
{
	import buttons.Button;
	import buttons.IconButton;
	import buttons.ImageButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Happy;
	import units.Thappy;
	import wins.ProgressBar;
	import wins.TopWindow;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class ThappyWindow extends HappyWindow
	{
		private var thappy:Thappy;
		//private var info2:Object;
		//private var preloader:Preloader;					//D
		//private var helpBttn:ImageButton;					//D
		public function ThappyWindow(settings:Object=null) 
		{
			settings['width'] = 700;
			settings['height'] = 640;
			thappy = settings.target;
			super(settings);
			//info2 = settings;
			
		}
		protected var teamID:int;
		
		override public function drawBody():void {
			titleLabel.y += 10;
			teamID = settings.target.team;
			
			drawSeparator(58,290, 10);
			
			drawState();			
			drawKicks();			
			drawTimer();
			drawScore();			
			drawTeamScore();
			
			var topBttnText:String = Locale.__e('flash:1418736014580');
			top100Bttn = new IconButton(Window.textures.topHappyBttn,{
						width:		160,
						//height:		90,
						caption:	topBttnText
					});
			top100Bttn.textLabel.y += 3;
			top100Bttn.textLabel.x += 3;
			top100Bttn.addEventListener(MouseEvent.CLICK, onTop100);
			top100Bttn.x = background.x + 80;
			top100Bttn.y = background.y + 32;
			bodyContainer.addChild(top100Bttn);
				
			if (settings.target.expire < App.time /*|| settings.target.canUpgrade*/)	{  	//D  прячем кнопку после окончания работы happy
				top100Bttn.state = Button.DISABLED;
			}
		
		}
		
		override protected function drawState():void {
			//var descBacking:Bitmap = backing(445, 150, 50, 'itemBacking');
			//bodyContainer.addChild(descBacking);
			
			backingRew = new Shape();
			backingRew.x = background.x+58;
			backingRew.y =background.y+100;
			bodyContainer.addChild(backingRew);
			
						
			backingRew.graphics.beginFill(0xe2c8a7,1)
			backingRew.graphics.drawRect(0, 0,background.width - 115,rewardW+10);
			backingRew.graphics.endFill();
			

			//var descLabelText:String =info['text2'];									//D Раскоментить
			var descLabel:TextField = drawText(info.description, TextSettings.description);
			descLabel.width = 420;
			descLabel.wordWrap = true;
			descLabel.x = 90;
			descLabel.y = backingRew.y+(backingRew.height-descLabel.height)/2;
			bodyContainer.addChild(descLabel);

			var lv:int;
			if (settings.target.upgrade + 1 <= settings.target.totalTowerLevels)
					lv = settings.target.upgrade;
				else	
					lv=settings.target.totalTowerLevels
			levelLabel = drawText(Locale.__e('flash:1418735019900', lv) + "/" + settings.target.totalTowerLevels, TextSettings.steps);	//D Этап
			levelLabel.x = background.x +background.width - levelLabel.width-100;
			levelLabel.y = background.y + 50;
			bodyContainer.addChild(levelLabel);
			
			rewX = backingRew.x + backingRew.width - rewardW / 2 - 20;
			
			circleRew = new Shape();
			circleRew.graphics.beginFill(0xF6E4D0, 1);
			circleRew.graphics.drawCircle(rewX,backingRew.y+5+rewardW/2 , rewardW/2);
			circleRew.graphics.endFill();

			bodyContainer.addChild(circleRew);
			
			
			var rewGlow:Bitmap = new Bitmap(Window.textures.glowRound, 'auto', true);
			rewGlow.width = rewGlow.height = rewardW + 30;
			rewGlow.x =(rewX-circleRew.width/2) +(circleRew.width-rewGlow.width)/2;
			rewGlow.y =backingRew.y-10;
			//rewGlow.alpha = 0.7;
			bodyContainer.addChild(rewGlow);
			
			
			 TextSettings.rewardTitle['width'] =backingRew.width;
			rewardTitle = drawText('', TextSettings.rewardTitle);
			
			rewardTitle.x = (rewX-circleRew.width/2) +(circleRew.width-rewardTitle.width)/2;
			rewardTitle.y = backingRew.y-15;
			//rewardDescLabel.y = levelLabel.y + 30;//rewardBacking.y;
			bodyContainer.addChild(rewardTitle);

			
			if (!upgradeBttn) {
			upgradeBttn = new Button( {
				width:		100,
				height:		40,
				fontSize: 21,
				caption:	Locale.__e('flash:1382952379737')		//D flash:1393579618588
			});
			upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
				}
			upgradeBttn.x = (rewX-circleRew.width/2) +(circleRew.width-upgradeBttn.width)/2;; //250 - upgradeBttn.width / 2;
			upgradeBttn.y = backingRew.y+backingRew.height-10;
				//scorePanel.addChild(upgradeBttn);
			bodyContainer.addChild(upgradeBttn);
			upgradeBttn.state = Button.DISABLED;
			
			//var rewardDescLabel:TextField = drawText(Locale.__e('flash:1382952380000'), {
			//rewardDescLabel = drawText(Locale.__e('flash:1382952380000'), {
				//textAlign:		'center',
				//fontSize:		30,
				//color:			0x814f31,
				//borderColor:	0xffffff,
				////width:			rewardBacking.width,
				//distShadow:		0
			//});
			//rewardDescLabel.x = background.x + background.width - rewardDescLabel.width - 60;//rewardBacking.x + (rewardBacking.width - rewardDescLabel.width) / 2;
			//rewardDescLabel.y = levelLabel.y + 30;//rewardBacking.y;
			//bodyContainer.addChild(rewardDescLabel);
			
			updateReward();
		}
		
		override protected function drawTimer():void {
			var timerBacking:Bitmap = new Bitmap(Window.textures.glow, 'auto', true);// Window.backingShort(150, 'seedCounterBacking');
			timerBacking.width = 150;
			timerBacking.scaleY = timerBacking.scaleX;
			timerBacking.scaleY = 0.3;
			timerBacking.x = (settings.width - timerBacking.width) / 2;
			timerBacking.y = 10;
			timerBacking.alpha = 0.7;
			bodyContainer.addChild(timerBacking);
			
			var timerDescLabel:TextField = drawText(Locale.__e('flash:1393581955601'), {
				width:			timerBacking.width,
				textAlign:		'center',
				fontSize:		26,
				color:			0xfffcff,
				borderColor:	0x5b3300
			});
			timerDescLabel.x = timerBacking.x + (timerBacking.width - timerDescLabel.width) / 2;
			timerDescLabel.y = timerBacking.y + 20;
			bodyContainer.addChild(timerDescLabel);
			
			timerLabel = drawText('00:00:00', {
				width:			timerBacking.width + 50,
				textAlign:		'center',
				fontSize:		40,
				color:			0xffd855,
				borderColor:	0x3f1b05
			});
			timerLabel.x = (settings.width - timerLabel.width) / 2;
			timerLabel.y =timerBacking.y+45;
			bodyContainer.addChild(timerLabel);
			
			if (settings.target.expire < App.time) {
				timerBacking.visible = false;
				timerDescLabel.visible = false;
				timerLabel.visible = false;
			}
		}
		//override protected function drawState():void {					//D
			//var descLabelText:String = info['text2'];			
			//var descLabel:TextField = drawText(descLabelText, {
				//textAlign:		'center',
				//autoSize:		'center',
				//fontSize:		24,
				//color:			0xfffcff,
				//borderColor:	0x6b401a,
				//distShadow:		0
			//});
			//
			//descLabel.wordWrap = true;
			//
			//bodyContainer.addChild(descLabel);
			//
			//descLabel.width = 420  - 130;
			//
			//descLabel.x = 120;
			//descLabel.y = 100;		
			//
			////circleRew = new Shape();
			////circleRew.graphics.beginFill(0xF6E4D0, 1);
			////circleRew.graphics.drawCircle(rewX,backingRew.y+5+rewardW/2 , rewardW/2);
			////circleRew.graphics.endFill();
////
			////bodyContainer.addChild(circleRew);
			//
			//
			//var rewGlow:Bitmap = new Bitmap(Window.textures.glowRound, 'auto', true);
			//rewGlow.width = rewGlow.height = rewardW + 30;
			//rewGlow.x =(rewX-circleRew.width/2) +(circleRew.width-rewGlow.width)/2;
			//rewGlow.y =backingRew.y-10;
			////rewGlow.alpha = 0.7;
			//bodyContainer.addChild(rewGlow);
			//
			//
			//rewardBacking = backing(140, 175, 10, 'itemBacking');
			//rewardBacking.x = settings.width - rewardBacking.width - 75;
			//rewardBacking.y = 50;
			//bodyContainer.addChild(rewardBacking);
			//
			//rewardDescLabel = drawText(Locale.__e('flash:1382952380000'), {
				//textAlign:		'center',
				//fontSize:		30,
				//color:			0x814f31,
				//borderColor:	0xffffff,
				//width:			rewardBacking.width,
				//distShadow:		0
			//});
			//rewardDescLabel.x = rewardBacking.x + (rewardBacking.width - rewardDescLabel.width) / 2;
			//rewardDescLabel.y = rewardBacking.y;
			//bodyContainer.addChild(rewardDescLabel);
			//
			//levelLabel = drawText(Locale.__e('flash:1471880481039',String(settings.target.upgrade + 1)), {
				//width:			150,
				//textAlign:		'center',
				//fontSize:		24,
				//color:			0xfffcff,
				//borderColor:	0x5b3300
			//});
			//levelLabel.x = rewardDescLabel.x + (rewardDescLabel.width - levelLabel.width) / 2;
			//levelLabel.y = 20;
			//bodyContainer.addChild(levelLabel);
		//}
		override protected function getReward():int {
			if (info.teams[teamID].levels.t[settings.target.upgrade]) {
				var trName:String = info.teams[teamID].levels.t[settings.target.upgrade];
				var treasure:Object = App.data.treasures[trName][trName];
				for each(var s:* in treasure.item) 
					return int(s);
			} 
			
			for (s in info.teams[teamID].bonus) 
				return int(s);
			
			var tbName:String=App.data.top[this.thappy.topID].league.tbonus[1].t[2];  //D в качестве награды отображаем топ 100 из рейтинга 
			
			var treasure2:Object = App.data.treasures[tbName][tbName];
				for each(var sb:* in treasure2.item) 
				return int(sb);
			return 0;
			}
		
		override protected function drawScore():void {
			if (!scorePanel) {
				scorePanel = new Sprite();
				scorePanel.x = 70;
				scorePanel.y = 170;
				bodyContainer.addChild(scorePanel);
			}
			//var topBttnText:String = Locale.__e('flash:1471880384319');
			//if (!top100Bttn) {
				//top100Bttn = new IconButton( {									//D
					////width:		160,
					////height:		42,
					////caption:	topBttnText
					//
					//width:		160,
						////height:		90,
						//caption:	topBttnText
				//});
				//top100Bttn = new IconButton(Window.textures.topHappyBttn,{
						//width:		160,
						////height:		90,
						//caption:	topBttnText
					//});
				//top100Bttn.x = (settings.width - top100Bttn.width) / 2 - 50;
				//top100Bttn.y = 325;
				//top100Bttn.addEventListener(MouseEvent.CLICK, onTopEvent);
			//}
			
			//top100Bttn.visible = false;
			if (!upgradeBttn) {
					upgradeBttn = new Button( {
						width:		110,
						height:		32,
						fontSize:	24,
						caption:	Locale.__e('flash:1382952379737')
					});
					upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
					upgradeBttn.state = Button.DISABLED;
					upgradeBttn.x = rewardBacking.x + rewardBacking.width / 2 - upgradeBttn.width / 2;
					upgradeBttn.y = rewardBacking.y + rewardBacking.height  - upgradeBttn.height / 2 - 5;
					bodyContainer.addChild(upgradeBttn);
			}
			
			if (scorePanel.numChildren > 0) {
				while (scorePanel.numChildren > 0) {
					var item:* = scorePanel.getChildAt(0);
					scorePanel.removeChild(item);
				}
			}
			
			if (settings.target.canUpgrade && settings.target.expire > App.time) {
				
				blockItems(true);
				upgradeBttn.state = Button.NORMAL;
				
			} else if (settings.target.upgrade < Numbers.countProps(info.teams[teamID].levels.t) && settings.target.expire > App.time) {
				var progressBacking:Bitmap = Window.backingShort(330, "progBarBacking");
				progressBacking.x = 50;
				progressBacking.y = 75;
				scorePanel.addChild(progressBacking);
				
				progressBar = new ProgressBar( { win:this, width:progressBacking.width + 16, isTimer:false} );
				progressBar.x = progressBacking.x - 8;
				progressBar.y = progressBacking.y - 4;
				scorePanel.addChild(progressBar);
				progressBar.progress = settings.target.kicks / settings.target.kicksNeed;
				progressBar.start();
				
				progressTitle = drawText(progressData, {
					fontSize:32,
					autoSize:"left",
					textAlign:"center",
					color:0xffffff,
					borderColor:0x6b340c,
					shadowColor:0x6b340c,
					shadowSize:1
				});
				progressTitle.x = progressBacking.x + progressBacking.width / 2 - progressTitle.width / 2;
				progressTitle.y = progressBacking.y - 2;
				progressTitle.width = 80;
				scorePanel.addChild(progressTitle);
				
				progress();
				if (top100Bttn) {
					top100Bttn.visible = true;				
					scorePanel.addChild(top100Bttn);
				}
				
			} else if (canTakeMainReward) {
				upgradeBttn.state = Button.NORMAL;
			} else {
				upgradeBttn.state = Button.DISABLED;
				var scoreDescLabelText:String = Locale.__e('flash:1472117420508');
				
				var scoreDescLabel:TextField = drawText(scoreDescLabelText, {
					width:			120,
					textAlign:		'center',
					fontSize:		32,
					color:			0xfffcff,
					borderColor:	0x5b3300
				});
				scoreDescLabel.x = 50;
				scoreDescLabel.y = 75;
				scorePanel.addChild(scoreDescLabel);
				scoreLabel = drawText(String(settings.target.rate[teamID]), {
					width:			120,
					textAlign:		'center',
					fontSize:		44,
					color:			0xf5ce4f,
					borderColor:	0x71371f
				});
				scoreLabel.x = scoreDescLabel.x + scoreDescLabel.width;
				scoreLabel.y = scoreDescLabel.y + scoreDescLabel.height/2 - scoreLabel.height/2 + 5;
				scorePanel.addChild(scoreLabel);
				if (top100Bttn) {
					top100Bttn.visible = true;
					scorePanel.addChild(top100Bttn);
				}
				changeRate();
			}
			
			if (getReward() == 0) {
				upgradeBttn.visible = false;
				rewardBacking.visible = false;
				rewardDescLabel.visible = false;
				levelLabel.visible = false;
			}
			
		}
		
		public var oneTeamScore:TextField;
		public var secTeamScore:TextField;
		public function drawTeamScore():void {
			var teamScoreBg:Shape = new Shape();
			teamScoreBg.x = background.x+58;
			teamScoreBg.y =490;
			bodyContainer.addChild(teamScoreBg);
			
						
			teamScoreBg.graphics.beginFill(0xe2c8a7,1)
			teamScoreBg.graphics.drawRect(0, 0,background.width - 115,45);
			teamScoreBg.graphics.endFill();
			
			if (!oneTeamScore) {
				oneTeamScore = Window.drawText(App.data.storage[thappy.sid].teams[1].info.title + ": " + thappy.rate[1], {
					color:		0xd3ff78,
					borderColor:0x0f4d0c,
					fontSize:	26
				});
				oneTeamScore.width = oneTeamScore.textWidth + 10;
				oneTeamScore.x = 70;
				oneTeamScore.y = teamScoreBg.y + 5;
				bodyContainer.addChild(oneTeamScore);
			} else {
				oneTeamScore.text = App.data.storage[thappy.sid].teams[1].info.title + ": " + thappy.rate[1];
			}
			
			if (!secTeamScore) {
				secTeamScore = Window.drawText(App.data.storage[thappy.sid].teams[2].info.title + ": " + thappy.rate[2], {
					color:		0x77ffff,
					borderColor:0x0a3f75,
					fontSize:	28
				});
				secTeamScore.width = secTeamScore.textWidth + 10;
				secTeamScore.x = 450;
				secTeamScore.y = oneTeamScore.y;
				bodyContainer.addChild(secTeamScore);
			} else {
				secTeamScore.text = App.data.storage[thappy.sid].teams[2].info.title + ": " + thappy.rate[2];
			}
			
			var topBttnText:String = Locale.__e('flash:1471880384319');

			var rezultBttn:IconButton = new IconButton(Window.textures.topHappyBttn,{
						width:		180,
						//height:		90,
						caption:	topBttnText
					});
			rezultBttn.x = teamScoreBg.x+(teamScoreBg.width - rezultBttn.width) / 2;
			rezultBttn.y = teamScoreBg.y + (teamScoreBg.height - rezultBttn.height) / 2;
			rezultBttn.addEventListener(MouseEvent.CLICK, onTopEvent);
			bodyContainer.addChild(rezultBttn);
			
		}

		
		//override public function openConstructWindow(openWindowAfterUpgrade:Boolean = true):Boolean 
		//{
			//if (_constructWindow != null)
				//return true;
			//
			//if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1))
			//{
				//if (App.user.mode == User.OWNER)
				//{
					////if (hasUpgraded)
					////{
						////var instanceNum:uint = instanceNumber();
						//
						//_constructWindow = new ConstructWindow( {
							//title:			info.title,
							////upgTime:		info.devel.req[level + 1].t,
							//request:		info.devel.obj[level + 1],
							////reward:			info.devel.rew[level + 1],
							//target:			this,
							//win:			this,
							//onUpgrade:		upgradeEvent,
							//hasDescription:	true,
							//popup:			false
						//});
						//_constructWindow.addEventListener(WindowEvent.ON_AFTER_CLOSE, onConstructWindowClose);
						//_constructWindow.show();
						//_openWindowAfterUpgrade = openWindowAfterUpgrade;
						//
						//return true;
					////}
				//}
			//}
			//return false;
		//}
		
		//override public function onTop100(e:MouseEvent = null):void {
			//if (thappy.rateChecked == 0) {
				//thappy.rateChecked = App.time;
				//getRate(onTop100);
				//return;
			//}
			//
			//thappy.rateChecked = 0;
			////changeRate();
			//
			//var content:Array = [];
			//for (var s:* in Happy.users) {
				//var user:Object = Happy.users[s];
				//user['uID'] = s;
				//content.push(user);
			//}
			//
			////if (settings.target.topID >= 8 && settings.target.topID != 9 && settings.target.topID != 11 && settings.target.topID != 13) {
				//////new TopLeaguesWindow( {
					//////title:			settings.title,
					//////description:	App.data.top[topID].description,
					//////points:			HappyWindow.rate,
					//////max:			topx,
					//////target:			settings.target,
					//////content:		HappyWindow.rates,
					//////material:		null,
					//////popup:			true,
					//////topID:			settings.target.topID,
					//////onInfo:			function():void {
						//////
					//////}
				//////}).show();
			////} else {
				//new TopWindow( {
					//title:			settings.title,
					//description: App.data.top[settings.target.topID].description,
					////points:			HappyWindow.rate,
					////max:			topx,
					//target:			settings.target,
					//content:		HappyWindow.rates,
					//material:		null,
					//popup:			true
					////onInfo:			function():void {
						////new InfoWindow( {
							////popup:true,
							////qID:'top' + topID
						////}).show();
					////}
				//}).show();
			////}			
		//}
		
		override public function progress():void {
			if (progressBar){
				progressBar.progress = settings.target.kicks / settings.target.kicksNeed;
				/*if (settings.target.kicks > settings.target.kicksNeed) {
					settings.target.kicks = settings.target.kicksNeed;
				}*/
				progressTitle.text = String(settings.target.kicks) + ' / ' + String(settings.target.kicksNeed);
			}
			
			//D обновляем общие результаты
			if (oneTeamScore)
			{																		
				if (this.teamID == 1)
					oneTeamScore.text = App.data.storage[thappy.sid].teams[1].info.title + ": " + thappy.rate[1];
				if (this.teamID == 2)
					secTeamScore.text = App.data.storage[thappy.sid].teams[2].info.title + ": " + thappy.rate[2];	
			}
		}
		
		
		override public function onUpgradeComplete(bonus:Object = null):void {			//D
			if (bonus && Numbers.countProps(bonus) > 0) {
				wauEffect();
				//App.user.stock.addAll(bonus);
			}
			
			levelLabel.text = Locale.__e('flash:1471880481039', settings.target.upgrade + 1);
			drawScore();
			updateReward();
			blockItems(false);
			close();
			
			var totalLevel:int = 0;
			for (var ttl:* in settings.target.info.teams[teamID].levels.v)
				totalLevel++;
			
			if (settings.target.upgrade >=settings.target.info.teams[teamID].levels.v ) { //D
				changeRate();
			}
		}
		override public function get canTakeMainReward():Boolean {
			return false;
		}
		
		override public function timer():void {					//D
			if(timerLabel)
				timerLabel.text = TimeConverter.timeToDays((settings.target.expire < App.time) ? 0 : (settings.target.expire - App.time));
		}
		
		
		public function drawSeparator(_x:int, _y:int, _h:int = 10):void {
			var separator:Shape = new Shape();
			separator.x = _x;
			separator.y =_y;
			bodyContainer.addChild(separator);
	
			separator.graphics.beginFill(0xe2c8a7,1)
			separator.graphics.drawRect(0, 0,background.width - 115,_h);
			separator.graphics.endFill();
		}
		

		override public function changeRate():void {
			if ( scoreLabel != null )
				scoreLabel.text = String(settings.target.kicks);// String(thappy.rate[thappy.team]);
		}
		
		public function onTopEvent(e:MouseEvent = null):void {
			thappy.getCommandRate(showIslandCWindow);
			if(oneTeamScore){																					//D обновляем общие результаты
					if (this.teamID == 1)
						oneTeamScore.text = App.data.storage[thappy.sid].teams[1].info.title + ": " + thappy.rate[1];
					if (this.teamID == 2)
						secTeamScore.text = App.data.storage[thappy.sid].teams[2].info.title + ": " + thappy.rate[2];	
				}
			function showIslandCWindow():void
			{
				
				var win:Object = new IslandChallengeWindow ({
						callback:null,
						target:settings.target,
						popup:true,
						title:Locale.__e ("flash:1471964388929"),
						mode:IslandChallengeWindow.CHALLENGE
					});
				win.show();
			}			
		}

		override public function getRate(callback:Function = null):void {
			
			function onGetRate():void
			{
				changeRate();
				if (callback != null)
					callback();
			}
			thappy.getRate(onGetRate);
		}
		
		
		override public function dispose():void 
		{
			super.dispose();
			thappy = null;
		}
	}

}


import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.Window;
import wins.ShopWindow;
import wins.BanksWindow;
import flash.geom.Point;


internal class KickItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Sprite;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	public var bttnFind:Button;
	private var count:uint;
	private var nodeID:String;
	private var type:uint;
	private var k:uint;
	
	public function KickItem(obj:Object, window:*) {
		this.sID = obj.id;
		this.count = obj.c;
		this.nodeID = obj.id;
		this.k = obj.k;
		this.item = App.data.storage[sID];
		this.window = window;
		type = obj.t;
		
		bg = new Sprite();
		bg.graphics.beginFill(0xF6E4D0,1);
		bg.graphics.drawCircle(60, 100, 60);
		bg.graphics.endFill();
		addChild(bg);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		drawTitle();
		drawBttn();
		drawLabel();
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		tip = function():Object {
			return {
				title: item.title,
				text: item.description
			}
		}
	}
	
	private function drawBttn():void {
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1382952379978"),
			width:115,
			height:40,
			fontSize:22
		}
		
		if(item.real == 0 || type == 1){
			bttnSettings['borderColor'] = [0xaff1f9, 0x005387];
			bttnSettings['bgColor'] = [0x70c6fe, 0x765ad7];
			bttnSettings['fontColor'] = 0x453b5f;
			bttnSettings['fontBorderColor'] = 0xe3eff1;
			
			bttn = new Button(bttnSettings);
		}
		
		if (item.real || type == 2) {
			
			bttnSettings['bgColor'] = [0xa8f749, 0x74bc17];
			bttnSettings['borderColor'] = [0x5b7385, 0x5b7385];
			bttnSettings['bevelColor'] = [0xcefc97, 0x5f9c11];
			bttnSettings['fontColor'] = 0xffffff;			
			bttnSettings['fontBorderColor'] = 0x4d7d0e;
			bttnSettings['fontCountColor'] = 0xc7f78e;
			bttnSettings['fontCountBorder'] = 0x40680b;		
			bttnSettings['countText']	= item.price[Stock.FANT];
			
			bttn = new MoneyButton(bttnSettings);
		}
		
		if (type == 3) {
			bttn = new Button(bttnSettings);
		}
		
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height + 30;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		bttnFind = new Button({
			caption			:Locale.__e("flash:1405687705056"),
			fontColor:		0xffffff,
			fontBorderColor:0x475465,
			borderColor:	[0xfff17f, 0xbf8122],
			bgColor:		[0x75c5f6,0x62b0e1],
			bevelColor:		[0xc6edfe,0x2470ac],
			width			:115,
			height			:40,
			fontSize		:22
		});
		addChild(bttnFind);
		bttnFind.x = (bg.width - bttnFind.width) / 2;
		bttnFind.y = bg.height + 30;
		bttnFind.addEventListener(MouseEvent.CLICK, onFind);
		bttnFind.visible = false;
		
		checkButtonsStatus();
	}
	
	public function checkButtonsStatus():void {
		if (window.settings.target.expire < App.time || window.settings.target.canUpgrade) {
			bttn.state = Button.DISABLED;
			return;
		}
		
		if (type == 2) {
			bttn.state = Button.NORMAL;
			bttn.visible = true;
			bttnFind.visible = false;
		}else if (type == 3) {
			if (App.user.stock.count(sID) < price) {
				bttn.state = Button.DISABLED;
				bttn.visible = false;
				bttnFind.visible = true;
			}else {
				bttn.state = Button.NORMAL;
				bttn.visible = true;
				bttnFind.visible = false;
			}1436188159724
		}
	}
	
	private function onClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		e.currentTarget.state = Button.DISABLED;
		
		if (currency == Stock.FANT && App.user.stock.count(Stock.FANT) < price) {
			window.close();
			new BanksWindow().show();
			return;
		}
		if (type == 3 && App.user.stock.count(sID) < 1 && ShopWindow.findMaterialSource(sID))  {
			window.close();
			return;
		}
		
		window.blockItems();
		window.settings.target.kickAction(sID, onKickEventComplete);
	}
	
	private function onKickEventComplete(bonus:Object = null):void {
		App.user.stock.take(currency, price);
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(currency, price, new Point(X, Y), false, App.self.tipsContainer);
		
		//if (Numbers.countProps(bonus) > 0) {
			//BonusItem.takeRewards(bonus, bttn, 20);
		//}
		if (bonus){
			flyBonus(bonus);
		}

		stockCount.text = 'x' + App.user.stock.count(sID);
		
		window.kick();
	}	
	
	private function flyBonus(data:Object):void {
		var targetPoint:Point = Window.localToGlobal(bttn);
		targetPoint.y += bttn.height / 2;
		for (var _sID:Object in data)
		{
			var sID:uint = Number(_sID);
			for (var _nominal:* in data[sID])
			{
				var nominal:uint = Number(_nominal);
				var count:uint = Number(data[sID][_nominal]);
			}
			
			var item:*;
			
			for (var i:int = 0; i < count; i++)
			{
				item = new BonusItem(sID, nominal);
				App.user.stock.add(sID, nominal);	
				item.cashMove(targetPoint, App.self.windowContainer)
			}			
		}
		SoundsManager.instance.playSFX('reward_1');
	}
	
	private function onFind(e:MouseEvent):void {
		ShopWindow.findMaterialSource(sID);
		window.close();
	}
	
	private var sprite:LayerX;
	private function onLoad(data:Bitmap):void {
		sprite = new LayerX();
		sprite.tip = function():Object {
			return {
				title: item.title,
				text: item.description
			};
		}
		
		bitmap = new Bitmap(data.bitmapData);
		Size.size(bitmap, 120, 120);
		sprite.x = (bg.width - bitmap.width) / 2;
		sprite.y = (bg.height - bitmap.height) / 2 + 35;
		sprite.addChild(bitmap);
		addChildAt(sprite, 1);
		bitmap.smoothing = true;
		
		sprite.addEventListener(MouseEvent.CLICK, searchEvent);
	}
	
	private function searchEvent(e:MouseEvent):void {
		ShopWindow.findMaterialSource(sID);
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function drawTitle():void {
		var title:TextField = Window.drawText(item.title + ' +' + k, TextSettings.itemTitle);
		//{
			//color:0x814f31,
			//borderColor:0xffffff,
			//textAlign:"center",
			//autoSize:"center",
			//fontSize:22,
			//textLeading:-6,
			//multiline:true,
			//distShadow:0
		//});
		title.wordWrap = true;
		title.width = bg.width - 10;
		title.height = title.textHeight;
		title.x = 5;
		title.y = 15;
		addChild(title);
	}
	
	private var stockCount:TextField
	public function drawLabel():void 
	{
		var count:int = App.user.stock.count(sID);
		var countText:String = 'x' + String(count);
		if (count < 1) {
			countText = '';
		}
		if (stockCount) {
			removeChild(stockCount);
			stockCount = null;
		}
		stockCount = Window.drawText(countText, {
			color:0xffffff,
			fontSize:30,
			borderColor:0x7b3e07
		});
		stockCount.width = stockCount.textWidth + 10;
		stockCount.x = bg.x + bg.width - stockCount.width;
		stockCount.y = bg.y + bg.height - 10;
		
		if (type == 2)
			return;
		addChild(stockCount);
	}
	
	private function get price():int {
		if (type == 2) {
			for (var s:* in item.price) break;
			return item.price[s];
		}
		
		return 1;
	}
	private function get currency():int {
		if (type == 2) {
			for (var s:* in item.price) break;
			return int(s);
		}
		
		return sID;
	}
}