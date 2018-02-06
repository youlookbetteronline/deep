package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import units.Happy;
	import wins.elements.HappyToy;
	
	public class HappyWindow extends Window
	{	
		protected var preloader:Preloader;
		protected var toyContainer:Sprite;
		protected var treeContainer:Sprite;
		protected var scaleContainer:Sprite;
		protected var kicksContainer:Sprite;
		protected var scorePanel:Sprite;
		protected var kicksBacking:Bitmap;
		protected var rewardBacking:Bitmap;	
		protected var overstack:Boolean = true;			// Накладывание картинок вида объекта одна на другую
		protected var decoratable:Boolean = true;		// Наряжать игрушками?
		
		public var timerLabel:TextField;
		public var levelLabel:TextField;
		public var scoreLabel:TextField;
		public var scoreDescLabel:TextField;
		public var progressBarLabel:TextField;		
		public var image:Bitmap;		
		public var showBttn:Button;
		public var top100Bttn:Button;
		public var topRewardButton:Button;
		public var upgradeBttn:Button;
		public var helpBttn:Button;
		public var progressBar:ProgressBar;
		public var sid:int = 0;
		public var info:Object = { };
		public var croped:Boolean = false;				// Урезаная версия. Без Топ100 и ряда надписей
		public var topNumber:int = 100;
		
		public static var itemToGlowID:int;	
		public static var noGrowButtonPlease:Boolean = false;
		
		public function HappyWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = /*settings['width'] ||*/ 820;
			settings['height'] = /*settings['height'] ||*/ 590;
			settings['title'] = settings.target.info.title;
			settings['hasPaginator'] = false;
			settings['background'] = 'buildingBacking';
			
			itemToGlowID = settings.target && settings.target.kickToGlow ? settings.target.kickToGlow : null;
			
			sid = settings.target.sid;
			info = App.data.storage[sid];
			topNumber = info['topx'] || 25;			
			
			/*if (croped) 
			{
				settings['height'] = 500;
			}*/
			
			super(settings);			
			App.self.setOnTimer(timer);			
			getRate();
		}
		
		override public function drawBackground():void 
		{
			if (settings.background!=null) 
			{
				var background:Bitmap = backing2(settings.width, settings.height, 50, 'constructBackingUp', 'constructBackingBot');
				layer.addChild(background);	
			}
		}
		
		override public function drawBody():void 
		{			
			this.y += 20;
			fader.y -= 20;
			/*image = new Bitmap();
			bodyContainer.addChild(image);*/
			
			/*preloader = new Preloader();
			preloader.x = settings.width / 2;
			preloader.y = settings.y;
			bodyContainer.addChild(preloader);*/
			
			drawMirrowObjs('decSeaweed', settings.width + 38, - 38, settings.height - 210, true, true, false, 1, 1, layer);
			var titleBackingBmap:Bitmap = backingShort(380, 'shopTitleBacking');
			
			titleBackingBmap.x = (settings.width - titleBackingBmap.width)/ 2;
			titleBackingBmap.y = -88;
			bodyContainer.addChild(titleBackingBmap);
			
			var downPlankBmap:Bitmap = backingShort(300, 'shopPlankDown');
			downPlankBmap.x = settings.width / 2 -downPlankBmap.width / 2;
			downPlankBmap.y = settings.height - downPlankBmap.height + 10;
			layer.addChild(downPlankBmap);
			
			/*if (sid == Stock.HAPPY_EASTER) 
			{
				Load.loading(Config.getImage('happy/guest', info.view),  function(data:Bitmap):void {
					bodyContainer.removeChild(preloader);
					preloader = null;
					
					image.bitmapData = data.bitmapData;
					image.smoothing = true;
					image.scaleX = image.scaleY = .6;
					image.x = settings.width / 2 - image.width / 2;
					image.y = -image.height / 2 - 20;
					
				});					
			}else if (sid == Stock.HAPPY_ASTRO) 
			{
				Load.loading(Config.getIcon(info.type, info.preview), function(data:Bitmap):void {
				bodyContainer.removeChild(preloader);
				preloader = null;
				
				image.bitmapData = data.bitmapData;
				image.smoothing = true;
				image.x = (settings.width / 2 - image.width / 2) - 10;
				image.y = -165;
				});	
			}else if (sid == Stock.CHRISTMAS_TREE) 
			{
				Load.loading(Config.getIcon(info.type, info.preview), function(data:Bitmap):void {
				bodyContainer.removeChild(preloader);
				preloader = null;
				
				image.bitmapData = data.bitmapData;
				image.smoothing = true;
				image.x = (settings.width / 2 - image.width / 2) - 10;
				image.y = -180;
				});	
			}else if (sid == Stock.HAPPY_BALLOON_2) 
			{
				Load.loading(Config.getIcon(info.type, info.preview), function(data:Bitmap):void {
				bodyContainer.removeChild(preloader);
				preloader = null;
				image.scaleX = image.scaleY = 0.4;
				image.bitmapData = data.bitmapData;
				image.smoothing = true;
				image.x = (settings.width / 2 - image.width / 2) - 10;
				image.y = -100;
				});	
			}else if (sid == Stock.TROPICAL_TREASURY) 
			{
				Load.loading(Config.getIcon(info.type, info.preview), function(data:Bitmap):void {
				bodyContainer.removeChild(preloader);
				preloader = null;
				image.scaleX = image.scaleY = 0.4;
				image.bitmapData = data.bitmapData;
				image.smoothing = true;
				image.x = settings.width / 2 - image.width / 2;
				image.y = -image.height / 2 - 20;
				});	
			}else {*/
				/*Load.loading(Config.getIcon(info.type, info.preview), function(data:Bitmap):void {
				bodyContainer.removeChild(preloader);
				preloader = null;
				image.bitmapData = data.bitmapData;
				image.smoothing = true;
				image.x = settings.width / 2 - image.width / 2;
				image.y = -image.height / 2 - 20;
				});	*/		
			//}
			
			exit.x -= 20;
			exit.y -= 0;
			
			drawState();			
			drawKicks();			
			drawScore();
			
			treeContainer = new Sprite();
			treeContainer.x = -40;
			treeContainer.y = -110;
			bodyContainer.addChild(treeContainer);
			
			toyContainer = new Sprite();
			toyContainer.x = treeContainer.x;
			toyContainer.y = treeContainer.y;
			bodyContainer.addChild(toyContainer);
			
			drawTimer();
			
			helpBttn = new ImageButton(Window.textures.showMeBttn);
			helpBttn.x = exit.x - exit.width +20;
			helpBttn.y -= 20;
			
			//if (sid != Stock.CHRISTMAS_TREE && sid != Stock.HAPPY_EASTER_2 && sid != Stock.HAPPY_BALLOON_2) 
			//{
			bodyContainer.addChild(helpBttn);
			//}	
			
			helpBttn.addEventListener(MouseEvent.CLICK, onHelp);
			
			var lookLabelText:String = Locale.__e('flash:1425474885987');//Посмотри, что тебе дарят друзья!
			
			var lookLabel:TextField = drawText(lookLabelText, {
				autoSize:		'center',
				textAlign:		'center',
				fontSize:		26,
				color:			0x814f31,
				borderColor:	0xffffff,
				distShadow:		0,
				multiline:		true,
				wrap:			true,
				width:			300
			});
			
			lookLabel.x = 135;
			
			if (sid == Stock.CHRISTMAS_TREE) 
			{
				lookLabel.x = 220;	
			}
			
			lookLabel.y = settings.height - 96;
			
			/*if (App.lang != 'ru' && App.lang != 'en' && App.lang != 'it') 
			{
				lookLabel.y -= 10;	
			}	*/	
			
			bodyContainer.addChild(lookLabel);
			
			showBttn = new Button( {
				width:		130,
				height:		42,
				textAlign:	'center',
				caption:	Locale.__e('flash:1382952380228'),
				fontColor:	0xffffff,
				fontBorderColor:	0x814f31,
				fontSize:	24
			});
			
			showBttn.x = lookLabel.x + lookLabel.width + 15;
			showBttn.y = settings.height - 100;
			bodyContainer.addChild(showBttn);
			showBttn.addEventListener(MouseEvent.CLICK, onShow);
			
			/*if (sid == Stock.HAPPY_BALLOON || sid == Stock.HAPPY_CHO || sid == Stock.HAPPY_ASTRO || sid == Stock.HAPPY_EASTER_2 || sid == Stock.HAPPY_BALLOON_2|| sid == Stock.TROPICAL_TREASURY) 
			{ */
				bodyContainer.removeChild(showBttn);
				bodyContainer.removeChild(lookLabel);
			//}
		}
		
		override public function drawSpriteBorders(sprite:Sprite):void
		{
		   sprite.graphics.beginFill(0xff0000, 0.05);
		   sprite.graphics.lineStyle(2, 0xff0000, 1);
		   sprite.graphics.drawRoundRectComplex(0, 0, sprite.width, sprite.height, 1, 1, 1, 1);
		   sprite.graphics.endFill();
		}
		
		protected function getReward():int
		{	
			/*if (info.sID == Stock.TROPICAL_TREASURY && settings.target.upgrade >= 4) 
			{
				return 0;
			}*/
			
			if (info.tower.hasOwnProperty(settings.target.upgrade + 1))
			{
				var items:Object = App.data.treasures[info.tower[settings.target.upgrade + 1].t][info.tower[settings.target.upgrade + 1].t].item;
				for each(var s:* in items) return int(s);
			}
			
			return 0;
		}
		
		protected var rewardCont:LayerX;
		protected var reward:Bitmap;
		
		protected function updateReward():void 
		{			
			var sid:int = getReward();
			
			if (!rewardCont) 
			{
				rewardCont = new LayerX();
				bodyContainer.addChild(rewardCont);
				
				reward = new Bitmap();
				rewardCont.addChild(reward);
			}
			
			if (!App.data.storage.hasOwnProperty(sid))
			{
				reward.bitmapData = null;
				return;
			}
			
			rewardCont.x = rewardBacking.x;
			rewardCont.y = rewardBacking.y;
			
			rewardCont.tip = function():Object 
			{
				return { title:App.data.storage[sid].title, text:App.data.storage[sid].description };
			}
			
			var preloader:Preloader = new Preloader();
			preloader.x = rewardBacking.width / 2;
			preloader.y = rewardBacking.height / 2;
			rewardCont.addChild(preloader);
			
			Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), function(data:Bitmap):void {
				rewardCont.removeChild(preloader);
				preloader = null;				
				reward.bitmapData = data.bitmapData;
				
				/*if (reward.width > rewardBacking.width - 20) 
				{
					reward.width = rewardBacking.width - 20;
					reward.scaleY = reward.scaleX;
				}
				
				if (reward.height > rewardBacking.height - 20)
				{
					reward.height = rewardBacking.height - 20;
					reward.scaleX = reward.scaleY;
				}*/
				Size.size(reward, rewardBacking.width - 30, rewardBacking.width - 30);
				
				rewardCont.x = rewardBacking.x + (rewardBacking.width - reward.width) / 2;
				rewardCont.y = rewardBacking.y + (rewardBacking.height - reward.height) / 2;
			});
			
			bodyContainer.swapChildren(rewardCont, rewardDescLabel);
		}
		
		protected var treeStates:Vector.<Bitmap> = new Vector.<Bitmap>;
		
		protected function drawTree():void
		{
			return;			
			clearTree();
		}
		
		protected function clearTree():void
		{
			while (treeContainer.numChildren > 0) 
			{
				var item:* = treeContainer.getChildAt(0);
				treeContainer.removeChild(item);
			}
		}
		
		protected function addTreeState(bmd:BitmapData):void 
		{
			var bitmap:Bitmap = new Bitmap(bmd);
			bitmap.smoothing = true;
			bitmap.x = (440 - bitmap.width) / 2;
			bitmap.y = settings.height - bitmap.height;
			treeContainer.addChild(bitmap);
		}
		
		protected function drawTimer():void 
		{
			var timerBacking:Bitmap = new Bitmap(Window.textures.glowingBackingNew, 'auto', true);
			timerBacking.x = -10;
			timerBacking.y = -60;
			timerBacking.alpha = 0.7;
			timerBacking.width = 150;
			timerBacking.scaleY = timerBacking.scaleX;
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
			
			timerLabel.x = timerBacking.x + (timerBacking.width - timerLabel.width) / 2;
			timerLabel.y = timerBacking.y + 45;
			bodyContainer.addChild(timerLabel);
			
			if (settings.target.expire < App.time)
			{
				timerBacking.visible = false;
				timerDescLabel.visible = false;
				timerLabel.visible = false;
			}
		}
		
		protected var rewardDescLabel:TextField = new TextField();
		
		protected function drawState():void 
		{
			var descBacking:Bitmap = backing(445, 115, 48, 'itemBacking');
			bodyContainer.addChild(descBacking);
			
			var descLabelText:String = Locale.__e('flash:1418735216505'); 
			//if (sid == 1051) descLabelText = Locale.__e('flash:1438602749808');
			//if (sid == Stock.HAPPY_ASTRO) descLabelText = Locale.__e('flash:1445431779410');
			//if (sid == Stock.HAPPY_EASTER) descLabelText = Locale.__e('flash:1423037805795');
			//if (sid == Stock.HAPPY_BALLOON) descLabelText = Locale.__e('flash:1433414501147');
			//if (sid == Stock.CHRISTMAS_TREE) descLabelText = Locale.__e('flash:1449585583366');
			//if (sid == Stock.TROPICAL_TREASURY) descLabelText = Locale.__e('flash:1470840894549');
			
			var descLabel:TextField = drawText(descLabelText, {
				textAlign:		'center',
				autoSize:		'center',
				fontSize:		24,
				color:			0xfffcff,
				borderColor:	0x6b401a,
				distShadow:		0
			});
			descLabel.width = 420;
			descLabel.wordWrap = true;
			descLabel.x = 110;
			descLabel.y = 40;
			bodyContainer.addChild(descLabel);
			
			descBacking.x = descLabel.x + (descLabel.width - descBacking.width) / 2 ;
			descBacking.y = descLabel.y + (descLabel.height - descBacking.height) / 2;
			
			var stateBacking:Bitmap = Window.backingShort(200, "yellowRibbon");
			stateBacking.x = descLabel.x + (descLabel.width - stateBacking.width) / 2;
			stateBacking.y = descLabel.y - stateBacking.height - 15;
			//bodyContainer.addChild(stateBacking);
			
			levelLabel = drawText(Locale.__e('flash:1418735019900', settings.target.upgrade + 1), {
				width:			stateBacking.width,
				textAlign:		'center',
				fontSize:		24,
				color:			0xfffcff,
				borderColor:	0x5b3300
			});
			levelLabel.x = stateBacking.x + (stateBacking.width - levelLabel.width) / 2;
			levelLabel.y = stateBacking.y + (stateBacking.height - levelLabel.height) / 2;
			//bodyContainer.addChild(levelLabel);
			
			rewardBacking = backing(170, 180, 48, 'banksBackingItem');
			rewardBacking.x = descBacking.x + descBacking.width + 15;
			rewardBacking.y = descBacking.y;
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
			rewardDescLabel.y = rewardBacking.y;
			bodyContainer.addChild(rewardDescLabel);
			
			updateReward();
		}
		
		protected function drawScore():void 
		{
			if (!scorePanel) 
			{
				scorePanel = new Sprite();
				scorePanel.x = 100;
				scorePanel.y = 135;
				bodyContainer.addChild(scorePanel);
			}
			
			if (scorePanel.numChildren > 0)
			{
				while (scorePanel.numChildren > 0) 
				{
					var item:* = scorePanel.getChildAt(0);
					scorePanel.removeChild(item);
				}
			}
			
			if (settings.target.canUpgrade && settings.target.expire > App.time) 
			{				
				blockItems(true);
				
				if (!upgradeBttn) 
				{
					upgradeBttn = new Button( {
						width:		200,
						height:		55,
						caption:	Locale.__e('flash:1393579618588')//Забрать награду
					});
					upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
				}
				upgradeBttn.x = 220 - upgradeBttn.width / 2;
				upgradeBttn.y = 0;
				scorePanel.addChild(upgradeBttn);
				
			}else if (settings.target.upgrade < Numbers.countProps(info.tower) - 1 && settings.target.expire > App.time)
			{
				var progressBacking:Bitmap = Window.backingShort(440, "prograssBarBacking3");
				progressBacking.x = 0;
				progressBacking.y = 10;
				scorePanel.addChild(progressBacking);
				
				progressBar = new ProgressBar( { win:this, width:progressBacking.width - 6, timeSize:27,scale:.7, timerY:4 } );
				progressBar.start();
				progressBar.x = progressBacking.x + (progressBacking.width - progressBar.width) / 2-6;
				progressBar.y = progressBacking.y - 6;
				
				scorePanel.addChild(progressBar);
				progress();
			} else if (canTakeMainReward) 
			{
				blockItems(true);
				
				if (!upgradeBttn) 
				{
					upgradeBttn = new Button( {
						width:		200,
						height:		55,
						caption:	Locale.__e('flash:1463052544639')//Награда за ТОП
					});					
					
					upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
				}
				
				upgradeBttn.x = 220 - upgradeBttn.width / 2;
				upgradeBttn.y = 0;
				scorePanel.addChild(upgradeBttn);				
			} else {
				var scoreBacking:Bitmap = backing(180, 65, 25, 'timeBg');
				scoreBacking.x = 40;
				scoreBacking.y = 20;
				scorePanel.addChild(scoreBacking);
				
				var scoreDescLabelText:String = Locale.__e('flash:1418736101766');
				//if (sid == 1122) scoreDescLabelText = Locale.__e('flash:1423037842261');
				
				var scoreDescLabel:TextField = drawText(scoreDescLabelText, {
					width:			scoreBacking.width,
					textAlign:		'center',
					fontSize:		26,
					color:			0xfffcff,
					borderColor:	0x5b3300
				});
				
				scoreDescLabel.x = scoreBacking.x + (scoreBacking.width - scoreDescLabel.width) / 2;
				scoreDescLabel.y = scoreBacking.y - 10;
				scorePanel.addChild(scoreDescLabel);
				
				scoreLabel = drawText(String(settings.target.kicks), {
					width:			scoreBacking.width,
					textAlign:		'center',
					fontSize:		44,
					color:			0xfed955,
					borderColor:	0x3d1509
				});
				
				scoreLabel.x = scoreDescLabel.x + (scoreDescLabel.width - scoreLabel.width) / 2;
				scoreLabel.y = scoreBacking.y + 12;
				scorePanel.addChild(scoreLabel);
				
				var topBttnText:String = Locale.__e('flash:1418736014580');
				/*if (sid == Stock.HAPPY_EASTER) topBttnText = Locale.__e('flash:1423037857595');
				
				if (sid == Stock.HAPPY_BALLOON) 
				{ 
					topBttnText = (App.isSocial("AI","MX"))?Locale.__e('flash:1441285454882'):Locale.__e('flash:1433256369513'); 
				}
				
				if (sid == Stock.HAPPY_CHO) 
				{ 
					topBttnText =(App.isSocial("HV"))?Locale.__e('flash:1441285454882'): Locale.__e('flash:1433256369513');
				}*/
				
				if (!top100Bttn) 
				{
					top100Bttn = new Button( {
						width:		160,
						height:		58,
						caption:	topBttnText
					});
					top100Bttn.addEventListener(MouseEvent.CLICK, onTop100);
					top100Bttn.x = scoreBacking.x + scoreBacking.width + 40;
					top100Bttn.y = scoreBacking.y + 4;
				}				
				
				//if (sid == 1263 || sid == 3431 ) topBttnText = 'Top-50';
			}
			
			/*if ((sid == Stock.HAPPY_CHO) && !App.isSocial("HV") && !top100Bttn)
			{
				top100Bttn = new Button( {
					width:		140,
					height:		42,
					caption:	Locale.__e('flash:1433256369513')
				});
				
				top100Bttn.x = 50;
				top100Bttn.y = -150;
				top100Bttn.addEventListener(MouseEvent.CLICK, onTop100);
			}*/
			
			/*if (sid == Stock.HAPPY_ASTRO || sid == Stock.HAPPY_EASTER_2 || sid == Stock.HAPPY_BALLOON_2) 
			{
				top100Bttn = new Button( {
					width:		140,
					height:		42,
					caption:	Locale.__e('flash:1418896186635')
				});
				
				top100Bttn.x = 50;
				top100Bttn.y = 345;
				top100Bttn.addEventListener(MouseEvent.CLICK, onTop100);
				
				topRewardButton = new Button( {
					width:		140,
					height:		42,
					caption:	Locale.__e('flash:1382952380228')
				});
				
				topRewardButton.addEventListener(MouseEvent.CLICK, onBonusDescription);
				topRewardButton.x = 420;
				topRewardButton.y = 345;
				scorePanel.addChild(topRewardButton);
			}*/
			
			//if (sid == Stock.CHRISTMAS_TREE || sid == Stock.TROPICAL_TREASURY) 
			//{
				top100Bttn = new Button( {
					width:		140,
					height:		42,
					caption:	Locale.__e('flash:1418896186635'),
					fontSize:	25
				});
				
				top100Bttn.x = (settings.width - top100Bttn.width)/2;
				top100Bttn.y = settings.height - top100Bttn.height - 48;
				top100Bttn.addEventListener(MouseEvent.CLICK, onTop100);
				
				topRewardButton = new Button( {
						width:		130,
						height:		35,
						caption:	Locale.__e('flash:1449656535819')
					});
				topRewardButton.addEventListener(MouseEvent.CLICK, onBonusDescription);
				topRewardButton.x = 478;
				topRewardButton.y = 45;
				scorePanel.addChild(topRewardButton);				
			//}	
			
			if (top100Bttn) bodyContainer.addChild(top100Bttn);
		}
		
		protected function progress():void 
		{
			if (progressBar && info.tower.hasOwnProperty(settings.target.upgrade + 1)) {
				progressBar.progress = settings.target.kicks / settings.target.kicksNeed;
				if (settings.target.kicks > settings.target.kicksNeed) {
					settings.target.kicks = settings.target.kicksNeed;
				}
				progressBar.timer.text = String(settings.target.kicks) + ' / ' + String(settings.target.kicksNeed);
			}
		}
		
		protected var toys:Vector.<HappyToy> = new Vector.<HappyToy>;
		
		public function drawToys():void 
		{
			if (!decoratable) return;
			
			clearToys();
			
			for (var s:* in settings.target.toys) {
				var toy:HappyToy = new HappyToy(s, settings.target.toys[s], this);
				toyContainer.addChild(toy);
				toys.push(toy);
				toy.mode = HappyToy.BLOCK;
			}
		}
		
		protected function clearToys():void
		{
			while (toys.length > 0) {
				var toy:HappyToy = toys.shift();
				toy.dispose();
			}
		}
		
		private var items2:Vector.<KickItem> = new Vector.<KickItem>;
		
		public function drawKicks():void 
		{
			clearKicks();
			var rewards:Array = [];
			for (var s:String in info.kicks) {
				var object:Object = info.kicks[s];
				object['id'] = s;
				rewards.push(object);
			}
			
			rewards.sortOn('o', Array.NUMERIC);
			
			if (!kicksBacking)
			{
				kicksBacking = backing(rewards.length * 150 + 75, 240, 50, 'buildingDarkBacking');
				kicksBacking.x = (settings.width - kicksBacking.width)/2;
				kicksBacking.y = 235;
				kicksBacking.visible = false; //может временно
				bodyContainer.addChild(kicksBacking);
			}
			
			for (var i:int = 0; i < rewards.length; i++) 
			{
				var item:KickItem = new KickItem(rewards[i], this);
				item.x = kicksBacking.x + 25 + 160 * items2.length;
				item.y = kicksBacking.y + 25;
				bodyContainer.addChild(item);
				items2.push(item);
			}
			
			var decorationLabelText:String = Locale.__e('flash:1418742079569');
			
			if (sid == Stock.HAPPY_BALLOON) 
			{
				decorationLabelText = Locale.__e('flash:1433418906597');
			}
			
			var titleLabel:TextField = drawText(decorationLabelText, {
				autoSize:		'center',
				textAlign:		'center',
				fontSize:		32,
				color:			0xfafeff,
				borderColor:	0x703b1b
			});
			
			titleLabel.x = kicksBacking.x + kicksBacking.width / 2 - titleLabel.textWidth / 2;
			titleLabel.y = kicksBacking.y - 15;
			bodyContainer.addChild(titleLabel);
		}
		
		protected function clearKicks():void 
		{
			while (items2.length > 0) 
			{
				var item:KickItem = items2.shift();
				item.dispose();
			}
		}
		
		protected function onShow(e:MouseEvent):void 
		{
			if (sid == Stock.CHRISTMAS_TREE) 
			{
				new HappyNewYearWindow( {
					popup:		true,
					mode:		HappyGuestWindow.OWNER,
					target:		settings.target,
					window:		this
				}).show();
			}else 
			{
				new HappyGuestWindow( {
					popup:		true,
					mode:		HappyGuestWindow.OWNER,
					target:		settings.target,
					window:		this
				}).show();
			}		
		}
		
		protected function onTop100(e:MouseEvent = null):void 
		{			
			if (!Happy.users || Numbers.countProps(Happy.users) == 0) return;
			
			if (rateChecked > 0 && rateChecked + 60 < App.time) 
			{
				rateChecked = 0;
				getRate(onTop100);
				return;
			}
			
			changeRate();
			
			var content:Array = [];
			
			for (var s:* in Happy.users) 
			{
				var user:Object = Happy.users[s];
				user['uID'] = s;
				content.push(user);
			}
			
			var top100DescText:String = Locale.__e('flash:1419520338982');
			
			if (sid == Stock.HAPPY_EASTER) 
			{
				top100DescText = Locale.__e('flash:1423068400354');
			}
			
			if (sid == Stock.HAPPY_BALLOON) 
			{
				
				top100DescText =(App.isSocial("AI","MX"))?Locale.__e('flash:1441285483537'): Locale.__e('flash:1433501899180');
			}
			
			if (sid == Stock.HAPPY_CHO) 
			{
				top100DescText =(App.isSocial("HV"))?Locale.__e('flash:1441285483537'): Locale.__e('flash:1438602841597');
			}
			
			if (sid == Stock.HAPPY_ASTRO) 
			{
				top100DescText = null;
			}
			var list:Object = {
				
				'0':{
					'attraction':'235',
					'firstname':'Oleg',
					'height': 75,
					'last_name': 'Kinash',
					'num': '25',
					'photo': 'http://cs316618.userapi.com/u174971289/e_29f86101.jpg',
					'uID' : 29060311,
					'width': 625				
				},
				'1':{
					'attraction':'236',
					'firstname':'Oleg',
					'height': 75,
					'last_name': 'Kinash',
					'num': '25',
					'photo': 'http://cs316618.userapi.com/u174971289/e_29f86101.jpg',
					'uID' : 29060311,
					'width': 625				
				}/*,
				'2':{
					'attraction':235,
					'firstname':'Oleg',
					'height': 75,
					'last_name': 'Kinash',
					'num': '25',
					'photo': 'http://cs316618.userapi.com/u174971289/e_29f86101.jpg',
					'uID' : 29060311,
					'width': 625				
				},
				'3':{
					'attraction':235,
					'firstname':'Oleg',
					'height': 75,
					'last_name': 'Kinash',
					'num': '25',
					'photo': 'http://cs316618.userapi.com/u174971289/e_29f86101.jpg',
					'uID' : 29060311,
					'width': 625				
				}*/			
			};
			new TopWindow( {
				target:			settings.target,
				content:		content,
				description:	top100DescText,
				max:			topNumber
			}).show();
			
			close();
		}
		
		protected function onBonusDescription(e:MouseEvent = null):void
		{			
			new HappyTopBonusWindow( {
				target:			settings.target
			}).show();
			
			close();
		}
		
		protected function onUpgrade(e:MouseEvent):void 
		{
			if (canTakeMainReward) 
			{
				var simpleWindow:SimpleWindow = new SimpleWindow( {
					width:		460,
					height:		300,
					popup:		true,
					dialog:		true,
					title:		info.title,
					hasTitle:	true,
					text:		Locale.__e('flash:1463056174893'),
					confirm:	function onUpgrade2():void {
						if (upgradeBttn.mode == Button.DISABLED)
							return;
						
						if (canTakeMainReward)
							Happy.users[App.user.id]['take'] = 1;
						
						upgradeBttn.mode = Button.DISABLED;
						settings.target.topBonusAction(onUpgradeComplete);
					}
				});
				simpleWindow.show();
				return;
			}
			
			if (e && e.currentTarget.mode == Button.DISABLED)
				return;
			
			if (canTakeMainReward)
				Happy.users[App.user.id]['take'] = 1;
			
			e.currentTarget.state = Button.DISABLED;
			settings.target.growAction(onUpgradeComplete);			
		}		
		
		protected function onUpgradeComplete(bonus:Object = null):void 
		{
			if (bonus && Numbers.countProps(bonus) > 0) 
			{
				wauEffect();
				BonusItem.takeRewards(bonus, upgradeBttn, 0, true, true);
			}
			
			levelLabel.text = Locale.__e('flash:1418735019900', settings.target.upgrade + 1);
			drawScore();
			drawTree();
			updateReward();
			blockItems(false);
			close();
			changeRate();
		}
		
		protected function onHelp(e:MouseEvent):void 
		{
			var txt:String = (App.isSocial("MX", "AI") && sid == Stock.HAPPY_BALLOON)?Locale.__e('flash:1441285411843'):App.data.storage[sid].text1;
			txt = (App.isSocial("HV") && sid == Stock.HAPPY_CHO)?Locale.__e('flash:1441285411843'):App.data.storage[sid].text1;
			
			new SimpleWindow( {
				title:		settings.title,
				hasTitle:	true,
				text:		txt,
				popup:		true,
				height:		420
			}).show();
		}
		
		public function blockItems(value:Boolean = true):void 
		{
			for (var i:int = 0; i < items2.length; i++)
			{
				if (value)
				{
					items2[i].bttn.state = Button.DISABLED;
				}else {
					items2[i].checkButtonsStatus();
				}
			}
		}
		
		public function kick():void
		{
			progress();
			App.ui.upPanel.update();
			
			if (settings.target.canUpgrade) 
			{
				blockItems(true);
				drawScore();
			}else {
				blockItems(false);
				if (scoreLabel) scoreLabel.text = String(settings.target.kicks);
			}
			
			changeRate();
		}
		
		protected function timer():void
		{
			if (timerLabel) 
			{
				timerLabel.text = TimeConverter.timeToDays((settings.target.expire < App.time) ? 0 : (settings.target.expire - App.time));				
			}
		}
		
		override public function dispose():void 
		{
			if (top100Bttn) top100Bttn.removeEventListener(MouseEvent.CLICK, onTop100);
			if (upgradeBttn) upgradeBttn.removeEventListener(MouseEvent.CLICK, onUpgrade);
			
			if (showBttn) 
			{
				showBttn.removeEventListener(MouseEvent.CLICK, onShow);	
			}
			
			if (helpBttn) 
			{
				helpBttn.removeEventListener(MouseEvent.CLICK, onHelp);	
			}
			
			App.self.setOffTimer(timer);
			super.dispose();
		}
		
		protected function wauEffect():void
		{
			if (noGrowButtonPlease) 
			{
				return;
			}
			
			if (reward.bitmapData != null) 
			{
				var rewardCont:Sprite = new Sprite();
				App.self.contextContainer.addChild(rewardCont);
				
				var glowCont:Sprite = new Sprite();
				glowCont.alpha = 0.6;
				glowCont.scaleX = glowCont.scaleY = 0.5;
				rewardCont.addChild(glowCont);
				
				var glow:Bitmap = new Bitmap(Window.textures.actionGlow);
				glow.x = -glow.width / 2;
				glow.y = -glow.height + 90;
				glowCont.addChild(glow);
				
				var glow2:Bitmap = new Bitmap(Window.textures.actionGlow);
				glow2.scaleY = -1;
				glow2.x = -glow2.width / 2;
				glow2.y = glow.height - 90;
				glowCont.addChild(glow2);
				
				var bitmap:Bitmap = new Bitmap(new BitmapData(reward.width, reward.height, true, 0));
				bitmap.bitmapData = reward.bitmapData;
				Size.size(bitmap, 60, 60);
				bitmap.smoothing = true;
				bitmap.x = -bitmap.width / 2;
				bitmap.y = -bitmap.height / 2;
				rewardCont.addChild(bitmap);
				
				rewardCont.x = layer.x + bodyContainer.x + this.rewardCont.x;
				rewardCont.y = layer.y + bodyContainer.y + this.rewardCont.y;
				
				function rotate():void 
				{
					glowCont.rotation += 1.5;
				}
				
				App.self.setOnEnterFrame(rotate);
				
				TweenLite.to(rewardCont, 0.5, { x:App.self.stage.stageWidth / 2, y:App.self.stage.stageHeight / 2, scaleX:1.25, scaleY:1.25, ease:Cubic.easeInOut, onComplete:function():void {
					setTimeout(function():void {
						App.self.setOffEnterFrame(rotate);
						glowCont.alpha = 0;
						var bttn:* = App.ui.bottomPanel.bttnMainStock;
						var _p:Object = { x:bttn.x + App.ui.bottomPanel.mainPanel.x, y:bttn.y + App.ui.bottomPanel.mainPanel.y};
						SoundsManager.instance.playSFX('takeResource');
						TweenLite.to(rewardCont, 0.3, { ease:Cubic.easeOut, scaleX:0.7, scaleY:0.7, x:_p.x, y:_p.y, onComplete:function():void {
							TweenLite.to(rewardCont, 0.1, { alpha:0, onComplete:function():void {}} );
						}} );
					}, 3000)
				}} );
			}
		}
		
		//Выдача наград за ТОП-50 и ТОП-10
		public function get canTakeMainReward():Boolean 
		{
			if (noGrowButtonPlease)//Не показывать при повторном открытии окна в то же сессии, когда забрал награду за топ
			{
				return false;
			}
			
			if (settings.target.hasOwnProperty('topRewardTaken') && settings.target.topRewardTaken == 1)//Не показывать юзерам, которые уже забрали награду за топ
			{
				return false;
			}
			
			if (settings.target.expire < App.time && rateChecked > 0) 
			{
				
				if (settings.target.kicks > 0)// Не показывать юзерам без киков вообще
				{
					return true;
				}
				
				/*if (settings.target.upgrade != Numbers.countProps(info.tower)) Условие Не показывать на какой-то стадии. Добавить если нужно.
				{
				}*/
				
				/*if (Numbers.countProps(info.tower) - 1 == settings.target.upgrade) Условие если достроил до последней стадии. Добавить если нужно.
				{
				}*/	
				
				/*if (settings.target.kicks >= settings.target.kicksMax) Условие если набрал нужное кол-во киков. Добавить если нужно.
				{
				}*/
			}
			
			return false;
		}
		
		public static var rateChecked:int = 0;
		public static var rateSended:Object = { };
		
		protected var onUpdateRate:Function;
		
		public function changeRate():void 
		{
			if (Happy.users.hasOwnProperty(App.user.id) && Happy.users[App.user.id].attraction == settings.target.kicks) return;
			
			if (!Happy.users.hasOwnProperty(App.user.id)) 
			{
				if (Numbers.countProps(Happy.users) >= topNumber)
				{
					for (var id:* in Happy.users)
					{
						if (Happy.users[id].attraction < settings.target.kicks)
						{
							delete Happy.users[id];
						}
					}
				}
				
				if (Numbers.countProps(Happy.users) < topNumber) 
				{
					Happy.users[App.user.id] = {
						first_name:		App.user.first_name,
						last_name:		App.user.last_name,
						photo:			App.user.photo,
						attraction:		0
					}
				}
			}
			
			if (Happy.users.hasOwnProperty(App.user.id)) 
			{
				Happy.users[App.user.id].attraction = settings.target.kicks;
			}
			
			if (settings.target.kicks == 0) return;
			
			var user:Object = { };
			user['first_name'] = App.user.first_name;
			user['last_name'] = App.user.last_name;
			user['photo'] = App.user.photo;
			user['attraction'] = settings.target.kicks;
			
			HappyWindow.rateSended[settings.target.sid] = settings.target.kicks;
			
			Post.send( {
				ctr:		'user',
				act:		'attraction',
				uID:		App.user.id,
				rate:		info.type + '_' + String(sid),
				user:		JSON.stringify(user)
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data['users']) settings.target.usersLength = data.users;
			});
		}
		
		protected function getRate(callback:Function = null):void 
		{
			if (rateChecked > 0) return;
			rateChecked = App.time;			
			onUpdateRate = callback;
			
			Post.send( {
				ctr:		'user',
				act:		'rate',
				uID:		App.user.id,
				rate:		info.type + '_' + String(sid)
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.hasOwnProperty('rate'))
					Happy.users = data['rate'] || { };
				
				if (Numbers.countProps(Happy.users) > topNumber)
				{
					var array:Array = [];
					for (var s:* in Happy.users) 
					{
						array.push(Happy.users[s]);
					}
					
					array.sortOn('attraction', Array.NUMERIC | Array.DESCENDING);
					array = array.splice(0, topNumber);
					
					for (s in Happy.users)
					{
						if (array.indexOf(Happy.users[s]) < 0)
							delete Happy.users[s];
					}
				}
				
				changeRate();
				
				if (onUpdateRate != null) 
				{
					onUpdateRate();
					onUpdateRate = null;
				}
			});
		}
		
		override public function close(e:MouseEvent = null):void 
		{
			if (settings.target && settings.target.kickToGlow) 
			{
				settings.target.kickToGlow = 0;			
				itemToGlowID = 0;
			}			
			super.close();			
		}
	}
}

import buttons.Button;
import com.greensock.TweenMax;
import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.BanksWindow;
import wins.HappyWindow;
import wins.ShopWindow;
import wins.Window;

internal class RewardItem extends Sprite {
	
	public static const WAIT:uint = 0;
	public static const REWARD:uint = 1;
	public static const EMPTY:uint = 2;
	
	public var bitmap:Bitmap;
	public var preloader:Preloader;
	public var takeBttn:Button;	
	public var sID:int = 0;
	public var info:Object;
	
	public function RewardItem(sid:int, params:Object) 
	{
		sID = sid;
		info = App.data.storage[sID];		
		preloader = new Preloader();
		addChild(preloader);		
		bitmap = new Bitmap();
		addChild(bitmap);
		Load.loading(Config.getIcon(info.type, info.preview), onLoad);
		
		takeBttn = new Button( {
			width:		100,
			height:		28,
			caption:	Locale.__e('flash:1382952379737'),
			fontSize:	21,
			radius:		10
		});
		
		takeBttn.x = 0;
		takeBttn.y = 40;
		addChild(takeBttn);
		takeBttn.addEventListener(MouseEvent.CLICK, onTake);		
	}
	
	
	public function onLoad(data:Bitmap):void
	{
		removeChild(preloader);
		preloader = null;		
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		Size.size(bitmap, 60, 60);
		//bitmap.scaleX = bitmap.scaleY = 0.5;
		bitmap.x = -bitmap.width / 2;
		bitmap.y = -bitmap.height / 2;		
	}
	
	protected function onTake(e:MouseEvent):void 
	{
		if (takeBttn.mode == Button.DISABLED) return;
		dispatchEvent(new Event(Event.OPEN));
	}
	
	protected var _mode:uint = WAIT;
	
	public function set mode(value:uint):void
	{
		_mode = value;
		if (_mode == WAIT) 
		{
			takeBttn.visible = true;
			takeBttn.state = Button.DISABLED;
		}else if (_mode == REWARD)
		{
			takeBttn.visible = true;
			takeBttn.state = Button.NORMAL;
		}else if (_mode == EMPTY)
		{
			takeBttn.visible = false;
		}
	}
	
	public function get mode():uint
	{
		return _mode;
	}
	
	public function dispose():void 
	{
		takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
		if (parent) parent.removeChild(this);
	}	
}

internal class KickItem extends LayerX
{	
	public var window:*;
	public var item:Object;
	public var bg:Bitmap;
	public var bttn:Button;
	
	protected var bitmap:Bitmap;
	protected var sID:uint;
	protected var count:uint;
	protected var nodeID:String;
	protected var type:uint;
	protected var removeGlow:Boolean = false;
	
	public function KickItem(obj:Object, window:*) 
	{	
		this.sID = obj.id;
		this.count = obj.c;
		this.nodeID = obj.id;
		this.item = App.data.storage[sID];
		this.window = window;
		type = obj.t;
		
		bg = Window.backing(145, 190, 20, 'itemBacking');
		addChild(bg);
		
		if (HappyWindow.itemToGlowID > 0 && HappyWindow.itemToGlowID == sID) 
		{
			customGlowing(bg);
		}		
		
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
	
	protected var icon:Bitmap;
	
	protected function drawBttn():void 
	{		
		var bttnText:String = Locale.__e('flash:1418826830156');
		if (window.sid == 1122) bttnText = Locale.__e('flash:1423037868310');
		
		var bttnSettings:Object = {
			caption:bttnText,
			width:110,
			height:40,
			fontSize:26
		}
		
		if (type == 2) 
		{
			bttnSettings['caption'] = '    ' + String(price);
			bttnSettings['bgColor'] = [0x99cbfe, 0x5c87ef];		//Цвета градиента
			bttnSettings['borderColor'] = [0xffffff, 0xffffff];	//Цвета градиента
			bttnSettings['bevelColor'] = [0xb5dbff, 0x386cdc];	
			bttnSettings['type'] = 'happy';		
			bttnSettings['countText'] = String(price);		
		}
		
		bttn = new Button(bttnSettings);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 12;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		addChild(bttn);
		
		if (type == 2) 
		{			
			icon = new Bitmap();
			Load.loading(Config.getIcon('Material', 'diamond'), onLoadIcon);			
			bttn.addChild(icon);
		}		
		
		checkButtonsStatus();
	}
	
	public function onLoadIcon(data:Bitmap):void
	{
		icon.bitmapData = data.bitmapData;		
		//icon.scaleX = icon.scaleY = 0.35;
		Size.size(icon, 30, 30);
		icon.smoothing = true;
		icon.x = 20;
		icon.y = 5;
		
	}	
	
	public function checkButtonsStatus():void
	{
		if (window.settings.target.expire < App.time || window.settings.target.canUpgrade)
		{
			bttn.state = Button.DISABLED;
			return;
		}
		
		if (type == 2) 
		{
			bttn.state = Button.NORMAL;
		}else if (type == 3) 
		{
			if (App.user.stock.count(sID) < price) 
			{
				bttn.state = Button.DISABLED;
			}else {
				bttn.state = Button.NORMAL;
			}
		}
	}
	
	protected function onClick(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (currency == Stock.FANT && App.user.stock.count(Stock.FANT) < price)
		{
			window.close();
			new BanksWindow().show();
			return;
		}
		
		if (type == 3 && App.user.stock.count(sID) < 1 && ShopWindow.findMaterialSource(sID)) 
		{
			window.close();
			return;
		}
		
		window.blockItems();
		window.settings.target.kickAction(sID, onKickEventComplete);
	}
	
	protected function onKickEventComplete(bonus:Object = null):void
	{
		App.user.stock.take(currency, price);		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(currency, price, new Point(X, Y), false, App.self.tipsContainer);
		
		if (Numbers.countProps(bonus) > 0)
		{
			BonusItem.takeRewards(bonus, bttn, 20, true, true);
		}
		
		stockCount.text = 'x' + App.user.stock.count(sID);
		window.kick();
	}	
	
	protected function onLoad(data:Bitmap):void 
	{
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = false;
		
		/*if (bitmap.width > bg.width * 0.9)
		{
			bitmap.width = bg.width * 0.9;
			bitmap.scaleY = bitmap.scaleX;
		}
		
		if (bitmap.height > bg.height * 0.9) 
		{
			bitmap.height = bg.height * 0.9;
			bitmap.scaleX = bitmap.scaleY;
		}*/
		
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 - 10;
	}
	
	public function dispose():void 
	{
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function drawTitle():void 
	{		
		var title:TextField = Window.drawText(String(item.title) + '\n+' + count.toString(), {
			color:0x7f3f14,
			borderColor:0xffffff,
			textAlign:"center",
			autoSize:"center",
			fontSize:36,
			textLeading:-6,
			multiline:true,
			distShadow:0
		});
		
		title.wordWrap = true;
		title.width = 90;
		title.height = title.textHeight;
		title.x = 5;
		title.y = 15;
		//addChild(title);
	}
	
	protected var stockCount:TextField
	
	public function drawLabel():void 
	{
		stockCount = Window.drawText('x'+App.user.stock.count(sID), {
			color:0x6d4b15,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:30,
			textLeading:-6,
			multiline:true
		});
		
		stockCount.x = (bg.width - stockCount.width) / 2;
		stockCount.y = bg.height - stockCount.height - 24;
		
		if (type == 2)
			return;
		
		addChild(stockCount);
	}
	
	protected function get price():int 
	{
		if (type == 2) 
		{
			for (var s:* in item.price) break;
			return item.price[s];
		}
		
		return 1;
	}
	
	protected function get currency():int
	{
		if (type == 2) 
		{
			for (var s:* in item.price) break;
			return int(s);
		}
		
		return sID;
	}
	
	private function customGlowing(target:*, callback:Function = null, colorGlow:uint = 0xFFFF00):void 
	{
		TweenMax.to(target, 1, { glowFilter: { color:colorGlow, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.8, { glowFilter: { color:colorGlow, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
				if (callback != null) {
					callback();
				}
			}});	
		}});
	}
	
	private function hideCustomGlowing(target:*, callback:Function = null, colorGlow:uint = 0xFFFF00):void 
	{
		TweenMax.to(target, 1, { glowFilter: { color:colorGlow, alpha:0.8, strength: 0, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.8, { glowFilter: { color:colorGlow, alpha:0.6, strength: 0, blurX:6, blurY:6 }, onComplete:function():void {
				if (callback != null) {
					callback();
				}
			}});	
		}});
	}
}