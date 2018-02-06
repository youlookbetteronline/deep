package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Happy;
	import units.Thappy;
	
	public class ThappyWindow extends HappyWindow
	{
		private var teamFlag:Bitmap;
		private var info2:Object;
		
		protected var bonusBttn:Button;
		protected var teamOneValueLabel:TextField;
		protected var teamTwoValueLabel:TextField;
		
		public function ThappyWindow(settings:Object=null) 
		{
			settings['height'] = 620;
			//croped  = true;
			super(settings);
			
			info2 = settings;
			
		}
		
		protected var teamID:int;
		
		override public function drawBody():void {
			drawMirrowObjs('storageWoodenDec', -5, settings.width+5, 40,false,false,false,1,-1);
			drawMirrowObjs('storageWoodenDec', -5, settings.width +5, settings.height - 115);
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -45, true, true);
			
			image = new Bitmap();
			//bodyContainer.addChild(image);
			teamID = settings.target.team;
			var preloader:Preloader = new Preloader();
			preloader.x = settings.width / 2;
			preloader.y = settings.y;
			bodyContainer.addChild(preloader);
			
			Load.loading(Config.getIcon(info.type, info.preview), function(data:Bitmap):void {
				bodyContainer.removeChild(preloader);
				preloader = null;
				
				image.bitmapData = settings.target.bitmap.bitmapData;
				image.smoothing = true;
				image.x = settings.width / 2 - image.width / 2;
				image.y = -image.height / 2 - 20;
			});
			
			exit.x += 0;
			exit.y -= 18;
			
			drawState();
			
			drawKicks();
			
			drawTimer();
			
			helpBttn = new ImageButton(Window.textures.showMeBttn);
			helpBttn.x = exit.x - exit.width +25;;
			helpBttn.y = 180;
			bodyContainer.addChild(helpBttn);
			helpBttn.addEventListener(MouseEvent.CLICK, onHelp);
			
			App.self.setOnTimer(timer);
			
			drawScore();
			
			updateReward();
		}
		
		override protected function drawTimer():void {
			
			/*var timerDescLabel:TextField = drawText(Locale.__e('flash:1393581955601'), {
				width:			150,
				textAlign:		'center',
				fontSize:		23,
				color:			0xfffcff,
				borderColor:	0x5b3300
			});
			timerDescLabel.x = 0;
			timerDescLabel.y = 0;
			bodyContainer.addChild(timerDescLabel);*/
			
			timerLabel = drawText('00:00:00', {
				width:			150,
				textAlign:		'center',
				fontSize:		32,
				color:			0xffd855,
				borderColor:	0x3f1b05
			});
			timerLabel.x = -15;
			timerLabel.y = -15;
			bodyContainer.addChild(timerLabel);
			
			//if (settings.target.expire < App.time) {
				//timerDescLabel.visible = false;
				//timerLabel.visible = false;
			//}
			
			timer();
		}
		override protected function drawState():void {
			
			var descBacking:Bitmap = backing(445, 120, 50, 'itemBacking');
			bodyContainer.addChild(descBacking);
			
			teamFlag = new Bitmap();
			bodyContainer.addChild(teamFlag);
			
			var _name:String ;
			if ( teamID == Thappy.RED)
				_name = "FlagRed";
			else
				_name = "FlagBlue";
			
			var descLabelText:String = info.description;
			
			var descLabel:TextField = drawText(descLabelText, {
				textAlign:		'center',
				autoSize:		'center',
				fontSize:		24,
				color:			0xfffcff,
				borderColor:	0x6b401a,
				distShadow:		0,
				wrap:			true,
				multiline:		true
			});
			
			bodyContainer.addChild(descLabel);
			
			descLabel.width = 400;
			Load.loading(Config.getImage("content", _name), function(data:Bitmap):void {
				teamFlag.bitmapData = data.bitmapData;
				//teamFlag.height = 115 ;
				//teamFlag.scaleX = teamFlag.scaleY;
				teamFlag.x = 20;
				teamFlag.y = -20;
				teamFlag.smoothing = true;
			});
			
			descLabel.x = 260 - descLabel.width * 0.5;
			descLabel.y = 100 - descLabel.height * 0.5;
			descBacking.x = descLabel.x + descLabel.width * 0.5 - descBacking.width * 0.5;
			descBacking.y = descLabel.y + descLabel.height * 0.5 - descBacking.height * 0.5 ;
			
			
			var stateBacking:Bitmap = Window.backingShort(200, "itemBacking");
			stateBacking.x = descLabel.x + (descLabel.width - stateBacking.width) / 2 ;
			stateBacking.y = descLabel.y - stateBacking.height - 15;
			
			var levelValue:int = settings.target.upgrade + 1;
			var levelText:String = Locale.__e('flash:1382952380004', [levelValue, settings.target.levels]);
			if (levelValue > settings.target.levels) {
				levelValue = settings.target.levels;
				levelText = '';
			}
			
			levelLabel = drawText(levelText, {
				width:			140,
				textAlign:		'center',
				fontSize:		52,
				color:			0x814f31,
				borderColor:	0xffffff
			});
			levelLabel.x = 200;
			levelLabel.y = 25;
			bodyContainer.addChild(levelLabel);
			
			
			rewardBacking = backing(180, 200, 50, 'itemBackingGold');
			rewardBacking.x = descBacking.x + descBacking.width +15;
			rewardBacking.y = descBacking.y -20;
			bodyContainer.addChild(rewardBacking);
			
			rewardDescLabel = drawText(Locale.__e('flash:1382952380000'), {
				textAlign:		'center',
				fontSize:		30,
				color:			0x814f31,
				borderColor:	0xffffff,
				width:			rewardBacking.width,
				distShadow:		0
			});
			rewardDescLabel.x = rewardBacking.x + (rewardBacking.width - rewardDescLabel.width) / 2;
			rewardDescLabel.y = rewardBacking.y - 10;
			bodyContainer.addChild(rewardDescLabel);
			
		}
		override protected function getReward():int {
			
			var s:*;
			if (info.points.hasOwnProperty(settings.target.upgrade)&&info.points[settings.target.upgrade].b) {
				var items:Object = App.data.treasures[info.points[settings.target.upgrade].b]['team' + teamID].item;
				for each(s in items) {
					if (['Golden','Box','Mfield'].indexOf(App.data.storage[s].type) >= 0) 
						return int(s);
				}
			}
			
			return 0;
		}
		
		override protected function drawScore():void {
			
			if (!scorePanel) {
				scorePanel = new Sprite();
				scorePanel.x = 0;
				scorePanel.y = 0;
				bodyContainer.addChild(scorePanel);
			}
			
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
			
			/*if (settings.target.canUpgrade && settings.target.expire > App.time) {
				
				scoreDescLabel = drawText(Locale.__e('flash:1441105403617') + ':', {
					width:			150,
					textAlign:		'right',
					fontSize:		30,
					color:			0x5f472b,
					borderColor:	0xf9eece
				});
				
				scoreLabel = drawText(String(settings.target.kicks), {
					width:			150,
					textAlign:		'left',
					fontSize:		42,
					color:			0xf1d613,
					borderColor:	0x753c00
				});
				
				scoreDescLabel.x = 180;
				scoreDescLabel.y = 205;
				scoreLabel.x = scoreDescLabel.x + scoreDescLabel.width + 10;
				scoreLabel.y = scoreDescLabel.y - 5;
				scorePanel.addChild(scoreDescLabel);
				scorePanel.addChild(scoreLabel);
				
				blockItems(true);
				upgradeBttn.state = Button.NORMAL;
				
			} else */if (settings.target.upgrade < Numbers.countProps(info.points) - 1 && settings.target.canUpgrade == false && settings.target.expire > App.time) {
				
				var progressBacking:Bitmap = Window.backingShort(440, "prograssBarBacking3"); // Window.backingShort(440, "prograssBarBacking3");
				progressBacking.x = 40;
				progressBacking.y = 175;
				scorePanel.addChild(progressBacking);
				
				progressBar = new ProgressBar( { win:this, width:progressBacking.width - 6, timeSize:27,scale:.7 } );
				progressBar.start();
				progressBar.x = progressBacking.x + (progressBacking.width - progressBar.width) / 2 -6;
				progressBar.y = progressBacking.y -6;
				scorePanel.addChild(progressBar);
				progressBar.timer.text = '';
				
				progressBarLabel = drawText('', {
					width:			progressBacking.width,
					color:			0x6d461f,
					borderColor:	0xfbfff8,
					borderSize:		3,
					fontSize:		31,
					textAlign:		'center'
				});
				progressBarLabel.x = progressBacking.x + (progressBacking.width - progressBarLabel.width) / 2;
				progressBarLabel.y = progressBacking.y + (progressBacking.height - progressBarLabel.height) / 2 + 3;
				scorePanel.addChild(progressBarLabel);
				progress();
				
			} else {
				
				scoreDescLabel = drawText(Locale.__e('flash:1441105403617') + ':', {
					width:			150,
					textAlign:		'right',
					fontSize:		30,
					color:			0x5f472b,
					borderColor:	0xf9eece
				});
				
				scoreLabel = drawText(String(settings.target.kicks), {
					width:			150,
					textAlign:		'left',
					fontSize:		42,
					color:			0xf1d613,
					borderColor:	0x753c00
				});
				
				scoreDescLabel.x = 170;
				scoreDescLabel.y = 180;
				scoreLabel.x = scoreDescLabel.x + scoreDescLabel.width + 10 - 0;
				scoreLabel.y = scoreDescLabel.y - 5;
				scorePanel.addChild(scoreDescLabel);
				scorePanel.addChild(scoreLabel);
				
				upgradeBttn.state = Button.DISABLED;
				upgradeBttn.visible = false;
			}
			
			if (settings.target.canUpgrade && settings.target.expire > App.time) {
				blockItems(true);
				upgradeBttn.state = Button.NORMAL;
				upgradeBttn.visible = true;
			}
			
			// 
			if (canTakeMainReward) {
				upgradeBttn.state = Button.NORMAL;
				upgradeBttn.visible = true;
			} 
			
			
			
			// Teams rate
			var teamRateContainer:Sprite = new Sprite();
			scorePanel.addChild(teamRateContainer);
			
			var teamOneDescLabel:TextField = drawText(settings.target.info.teams.team[1].name + ':', {
				width:			110,
				textAlign:		'right',
				fontSize:		28,
				color:			0xfffcff,
				borderColor:	0x5b3300
			});
			teamOneDescLabel.x = -60;
			teamOneDescLabel.y = 30;
			teamRateContainer.addChild(teamOneDescLabel);
			
			teamOneValueLabel = drawText(String(settings.target.rate[1] || 0), {
				width:			110,
				//autoSize:		'left',
				textAlign:		'left',
				fontSize:		40,
				color:			0xfdf98b,
				borderColor:	0x6e2306
			});
			teamOneValueLabel.width += 10;
			teamOneValueLabel.x = teamOneDescLabel.x + teamOneDescLabel.width + 10;
			teamOneValueLabel.y = 24;
			teamRateContainer.addChild(teamOneValueLabel);
			
			
			var teamTwoDescLabel:TextField = drawText(settings.target.info.teams.team[2].name + ':', {
				width:			90,
				textAlign:		'right',
				fontSize:		28,
				color:			0xfffcff,
				borderColor:	0x5b3300
			});
			teamTwoDescLabel.x = teamOneValueLabel.x + teamOneValueLabel.width + 20;
			teamTwoDescLabel.y = 30;
			teamRateContainer.addChild(teamTwoDescLabel);
			
			teamTwoValueLabel = drawText(String(settings.target.rate[2] || 0), {
				width:			110,
				//autoSize:		'left',
				textAlign:		'left',
				fontSize:		40,
				color:			0xd7ff9e,
				borderColor:	0x1a2f72
			});
			teamTwoValueLabel.width += 10;
			teamTwoValueLabel.x = teamTwoDescLabel.x + teamTwoDescLabel.width + 10;
			teamTwoValueLabel.y = 24;
			teamRateContainer.addChild(teamTwoValueLabel);
			
			teamRateContainer.x = 340 - teamRateContainer.width * 0.5;
			teamRateContainer.y = settings.height - teamRateContainer.height - 75;
			
			
			
			/*var topDesc:TextField = drawText(Locale.__e('flash:1441094769416'), {
				width:			510,
				textAlign:		'center',
				fontSize:		26,
				color:			0x5b4425,
				borderColor:	0xf2ebce
			});
			topDesc.x = 80;
			topDesc.y = settings.height - topDesc.height - 88;
			bodyContainer.addChild(topDesc);*/
			
			if (settings.target.expire < App.time && settings.target.taked == 0) {
				bonusBttn = new Button( {
					width:		120,
					height:		40,
					caption:	Locale.__e('flash:1382952379737')
				});
				bonusBttn.x = 50;
				bonusBttn.y = scoreLabel.y + scoreLabel.height * 0.5 - bonusBttn.height * 0.5 - 10;
				bonusBttn.addEventListener(MouseEvent.CLICK, onBonusTake);
				bonusBttn.showGlowing();
				scorePanel.addChild(bonusBttn);
			}
			
			var topBttnText:String = Locale.__e('flash:1418896186635');
			if (!top100Bttn) {
				top100Bttn = new Button( {
					width:		130,
					height:		42,
					caption:	topBttnText
				});
				top100Bttn.addEventListener(MouseEvent.CLICK, onTop100);
			}
			top100Bttn.x = settings.width - top100Bttn.width - 50;
			top100Bttn.y = settings.height - top100Bttn.height - 70;
			bodyContainer.addChild(top100Bttn);
		}
		
		protected function onBonusTake(e:MouseEvent):void {
			new TeamResultWindow( {
				target:		settings.target,
				team:		teamID,
				popup:		true,
				bonus:		getTeamBonus(),
				win:		isWin()
			}).show();
			
			function getTeamBonus():Object {
				if (isWin()) {
					return info.abonus || { };
				}
				
				return info.bbonus || { };
			}
			
			function isWin():Boolean {
				if (settings.target.rate[teamID] > settings.target.rate[teamID % 2 + 1])
					return true;
				
				return false;
			}
		}
		
		override protected function onTop100(e:MouseEvent = null):void {
			
			if (e && e.currentTarget.mode == Button.DISABLED)
				return;
			
			if (!Happy.users || Numbers.countProps(Happy.users) == 0) return;
			
			if (rateChecked > 0 && rateChecked + 60 < App.time) {
				rateChecked = 0;
				getRate(onTop100);
				return;
			}
			
			var content:Array = [];
			for (var s:* in Happy.users) {
				var user:Object = Happy.users[s];
				user['uID'] = s;
				content.push(user);
			}
			
			new TopWindow( {
				target:		settings.target,
				content:	content,
				max:		info['topx'] || 100,
				popup:		true
			}).show();
			
			close();
		}
		
		override protected function progress():void {
			//if (progressBar && info.teams.levels[teamID].с.hasOwnProperty(settings.target.update )) {
			if (progressBar){
				progressBar.progress = settings.target.kicks / settings.target.kicksNeed;
				progressBarLabel.text = String(settings.target.kicks) + ' / ' + String(settings.target.kicksNeed);
			}
		}
		 override protected function onUpgradeComplete(bonus:Object = null):void {
			if (bonus && Numbers.countProps(bonus) > 0) {
				var sid:* = 0;
				for (sid in bonus) {
					if (['Golden', 'Box','Mfield'].indexOf(App.data.storage[sid].type) != -1) break;
				}
				Effect.wowEffect(sid);
				App.user.stock.addAll(bonus);
				App.ui.upPanel.update();
			}
			
			levelLabel.text = Locale.__e('flash:1418735019900', settings.target.upgrade + 1);
			drawScore();
			updateReward();
			blockItems(false);
			close();
			
			if (settings.target.upgrade >= Numbers.countProps(info.points[settings.target.upgrade].c)) {
				changeRate();
			}
		}
		override public function get canTakeMainReward():Boolean {
			if (settings.target.expire < App.time && rateChecked > 0 && Numbers.countProps(info.points) - 1 == settings.target.upgrade && settings.target.kicksMax == 0 && Happy.users.hasOwnProperty(App.user.id) && Happy.users[App.user.id]['take'] != 1)
				return true;
			
			return false;
		}
		
		/*override protected function timer():void {
			timerLabel.text = TimeConverter.timeToDays((settings.target.expire < App.time) ? 0 : (settings.target.expire - App.time));
			
		}*/
		
		
		private var items2:Vector.<KickItem> = new Vector.<KickItem>;
		override public function drawKicks():void {
			/*clearKicks();
			var rewards:Array = [];
			for (var s:String in info.kicks) {
				var object:Object = info.kicks[s];
				object['id'] = s;
				rewards.push(object);
			}
			rewards.sortOn('c', Array.NUMERIC);
			
			if (!kicksBacking) {
				kicksBacking = backing(rewards.length * 150 + 60, 240, 50, 'windowDarkBacking');
				kicksBacking.x = settings.width - kicksBacking.width - 50;
				kicksBacking.y = 270;
				bodyContainer.addChild(kicksBacking);
			}
			
			for (var i:int = 0; i < rewards.length; i++) {
				var item:KickItem = new KickItem(rewards[i], this);
				item.x = kicksBacking.x + 45 + 160 * itemsKick.length;
				item.y = kicksBacking.y + 25;
				bodyContainer.addChild(item);
				itemsKick.push(item);
			}
			
			var decorationLabelText:String = Locale.__e('flash:1426694723184');
			var titleLabel:TextField = drawText(decorationLabelText, {
				autoSize:		'center',
				textAlign:		'center',
				fontSize:		32,
				color:			0xfafeff,
				borderColor:	0x703b1b
			});
			titleLabel.x = kicksBacking.x + kicksBacking.width / 2 - titleLabel.textWidth / 2;
			titleLabel.y = kicksBacking.y - 15;
			bodyContainer.addChild(titleLabel);*/
			
			
			clearKicks();
			
			var rewards:Array = [];
			for (var s:String in info.kicks) {
				var object:Object = info.kicks[s];
				object['id'] = s;
				rewards.push(object);
			}
			rewards.sortOn('k', Array.NUMERIC | Array.DESCENDING);
			rewards.reverse();
			
			if (!kicksBacking) {
				kicksBacking = backing(rewards.length * 150 + 40, 260, 50, 'buildingDarkBacking');
				kicksBacking.x = settings.width - kicksBacking.width - 40;
				kicksBacking.y = (croped) ? 150 : 245;
				bodyContainer.addChild(kicksBacking);
			}
			
			for (var i:int = 0; i < rewards.length; i++) {
				var item:KickItem = new KickItem(rewards[i], this);
				item.x = kicksBacking.x + 20 + 150 * items2.length;
				item.y = kicksBacking.y + 30;
				bodyContainer.addChild(item);
				items2.push(item);
			}
			
			var titleLabel:TextField = drawText(Locale.__e('flash:1426694723184'), {
				autoSize:		'center',
				textAlign:		'center',
				fontSize:		27,
				color:			0xfcffff,
				borderColor:	0x684e29
			});
			titleLabel.x = kicksBacking.x + kicksBacking.width / 2 - titleLabel.textWidth / 2;
			titleLabel.y = kicksBacking.y - 15;
			bodyContainer.addChild(titleLabel);
		}
		
		override public function changeRate():void {
			if ( scoreLabel != null )
				scoreLabel.text = String(settings.target.kicks);
		}
		
		override protected function getRate(callback:Function = null):void {
			//if (rateChecked > 0) return;
			rateChecked = App.time;
			
			onUpdateRate = callback;
			
			Post.send( {
				ctr:		'user',
				act:		'rate',
				field:		'all', // users
				uID:		App.user.id,
				rate:		info.type + '_' + String(sid)
			}, function(error:int, data:Object, params:Object):void {
				
				if (error) return;
				
				if (data.hasOwnProperty('rate') && data.rate) {
					if (data.rate.hasOwnProperty('users') && data.rate.users)
						Happy.users = data.rate['users'] || { };
					
					if (data.rate.hasOwnProperty('teams')) {
						settings.target.rate = {
							1:data.rate.teams[1] || 0,
							2:data.rate.teams[2] || 0
						}
					}
					
					if (teamOneValueLabel) {
						teamOneValueLabel.text = String(settings.target.rate[1]);
						teamTwoValueLabel.text = String(settings.target.rate[2]);
					}
				}
				
				if (Numbers.countProps(Happy.users) > topNumber) {
					var array:Array = [];
					for (var s:* in Happy.users) {
						array.push(Happy.users[s]);
					}
					array.sortOn('attraction', Array.NUMERIC | Array.DESCENDING);
					array = array.splice(0, topNumber);
					for (s in Happy.users) {
						if (array.indexOf(Happy.users[s]) < 0)
							delete Happy.users[s];
					}
				}
				
				if (canTakeMainReward == true && upgradeBttn.mode == Button.DISABLED) {
					drawScore();
				}
				
				/*if (!data.rate) data.rate = { };
				
				settings.target.rate = {
					1:data.rate[1] || 0,
					2:data.rate[2] || 0
				};
				if (settings.target.update == 3){ 
					settings.target.kicks = settings.target.rate[teamID];
					changeRate();
				}*/
				
				/*if (settings.target.expire < App.time)
					onUpgradeComplete();*/
				
				//if (onUpdateRate != null) {
					//onUpdateRate();
					//onUpdateRate = null;
				//}
			});
		}
		
		public function updateRates(rateValue:int = 0):void {
			if (settings.target.team == Thappy.RED) {
				teamOneValueLabel.text = String(int(teamOneValueLabel.text) + rateValue);
			}
			if (settings.target.team == Thappy.BLUE) {
				teamTwoValueLabel.text = String(int(teamTwoValueLabel.text) + rateValue);
			}
		}
		
		override public function blockItems(value:Boolean = true):void {
			for (var i:int = 0; i < items2.length; i++) {
				if (value) {
					items2[i].bttn.state = Button.DISABLED;
				}else {
					items2[i].checkButtonsStatus();
				}
			}
		}
	}

}


import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.Window;
import wins.ThappyWindow;
import wins.ShopWindow;

internal class KickItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	public var buyBttn:MoneyButton;
	private var count:uint;
	private var nodeID:String;
	private var type:uint;
	
	public function KickItem(obj:Object, window:*) {
		
		this.sID = obj.id;
		this.count = obj.k;
		this.nodeID = obj.id;
		this.item = App.data.storage[sID];
		this.window = window;
		type = obj.t;
		
		bg = Window.backing(150, 190, 20, 'itemBacking');
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
			caption:Locale.__e('flash:1382952379978'),
			width:110,
			height:32,
			fontSize:23
		}
		
		if (type == 2) {
			bttnSettings['caption'] = '    ' + String(price);
			
			bttnSettings['bgColor'] = [0x99cbfe, 0x5c87ef];	//Цвета градиента
			bttnSettings['borderColor'] = [0xcefc97, 0x5f9c11];	//Цвета градиента
			bttnSettings['bevelColor'] = [0xb5dbff, 0x386cdc];	
		}
		
		
		bttn = new Button(bttnSettings);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 12;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		addChild(bttn);
		
		buyBttn = new MoneyButton( {
			width:		100,
			height:		40,
			fontSize	:18,
			radius		:15,
			caption:	Locale.__e('flash:1382952380221'),
			countText:	price,
			iconScale:	0.75
			
		});
		buyBttn.x = bttn.x + 5;
		buyBttn.y = bttn.y + bttn.height - 2;
		buyBttn.addEventListener(MouseEvent.CLICK, onMoneyClick);
		buyBttn.visible = false;
		addChild(buyBttn);
		
		if (type == 2) {
			var icon:Bitmap = new Bitmap(UserInterface.textures.fantsIcon, 'auto', true);
			icon.scaleX = icon.scaleY = 0.8;
			icon.x = 25;
			icon.y = 2;
			bttn.addChild(icon);
		}
		
		checkButtonsStatus();
	}
	
	public function checkButtonsStatus():void {
		if (window.settings.target.expire < App.time || window.settings.target.canUpgrade) {
			bttn.state = Button.DISABLED;
			return;
		}
		
		if (type == 2) {
			if (App.user.stock.count(Stock.FANT) < 1) {
				bttn.state = Button.NORMAL;
			}else {
				bttn.state = Button.NORMAL;
			}
		}else if (type == 3) {
			if (window.croped) {
				buyBttn.visible = true;
				buyBttn.state = Button.NORMAL;
				if (App.user.stock.count(sID) < 1) {
					bttn.state = Button.DISABLED;
				}else {
					if (window.settings.target.kicksNeed > 0) {
						bttn.state = Button.NORMAL;
					}else {
						//bttn.state = Button.DISABLED;
						bttn.state = Button.NORMAL;
					}
				}
			}else{
				if (App.user.stock.count(sID) < 1) {
					bttn.state = Button.DISABLED;
				}else {
					if (window.settings.target.kicksNeed > 0) {
						bttn.state = Button.NORMAL;
					}else {
					//	bttn.state = Button.DISABLED;
					bttn.state = Button.NORMAL;
					}
				}
			}
		}
	}
	
	private function onClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		if (type == 3 && App.user.stock.count(sID) < 1 && ShopWindow.findMaterialSource(sID))  {
			window.close();
			return;
		}
		if (!App.user.stock.take(priceID, price/*App.data.storage[sID].price[Stock.FANT]*/))
			return;
			
		window.blockItems();
		window.settings.target.kickAction(sID, onKickEventComplete);
		//checkButtonsStatus();
	}
	
	private function onMoneyClick(e:MouseEvent):void {
		if (buyBttn.mode == Button.DISABLED) return;
		buyBttn.state = Button.DISABLED;
		
		if (App.user.stock.check(Stock.FANT, App.data.storage[sID].real)) {
			App.user.stock.buy(sID, 1, function(param:*, params2:*):void {
				stockCountText.text = "x" + App.user.stock.count(sID);
				checkButtonsStatus();
			}, false);
		}
	}
	
	private function onKickEventComplete(bonus:Object = null):void 
	{
		
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(priceID, price/*App.data.storage[sID].price[Stock.FANT]*/, new Point(X, Y), false, App.self.tipsContainer);
		
		
		if (Numbers.countProps(bonus) > 0) {
			App.user.stock.addAll(bonus);
			BonusItem.takeRewards(bonus, bttn, 20);
			App.ui.upPanel.update();
		}
		
		if (type != 2) {
			stockCountText.text = "x" + App.user.stock.count(sID);
		}
		
		
		window.updateRates(count);
		window.kick();
		checkButtonsStatus();
	}	
	
	private function onLoad(data:Bitmap):void {
		bitmap.bitmapData = data.bitmapData;
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 - 10;
		
		if (bitmap.width > bg.width * 0.9) {
			bitmap.width = bg.width * 0.9;
			bitmap.scaleY = bitmap.scaleX;
		}
		if (bitmap.height > bg.height * 0.9) {
			bitmap.height = bg.height * 0.9;
			bitmap.scaleX = bitmap.scaleY;
		}
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function drawTitle():void {
		
		var title:TextField = Window.drawText(String(item.title) + '\n+' + count.toString(), {
			color:0x6e461e,
			borderColor:0xffffff,
			textAlign:"center",
			autoSize:"center",
			fontSize:22,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = bg.width - 10;
		title.height = title.textHeight;
		title.y = 10;
		title.x = 5;
		addChild(title);
	}
	
	private var stockCountText:TextField;
	public function drawLabel():void {
		//var price:PriceLabel;
		if (type != 2) {
			stockCountText = Window.drawText("x" + App.user.stock.count(sID), {
				color:0x6e461e,
				borderColor:0xffffff,
				textAlign:"center",
				autoSize:"center",
				fontSize:30,
				textLeading:-6,
				multiline:true
			});
			stockCountText.x = (bg.width - stockCountText.width) / 2;
			stockCountText.y = bg.height - stockCountText.height - 27;
			addChild(stockCountText);
		}
	}
	
	
	private function get price():int {
		if (type == 3)			return 1;
		else 					return App.data.storage[sID].price[Stock.FANT];
	}
	private function get priceID():int {
		if (type == 3)			return sID;
		else 					return Stock.FANT;
	}
}