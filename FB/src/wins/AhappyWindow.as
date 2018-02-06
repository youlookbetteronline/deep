package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	import units.Ahappy;
	import wins.FriendRewardWindow;
	import ui.UserInterface;
	import units.Happy;
	import wins.elements.HappyToy;
	import wins.happy.HappyGuestWindow;
	
	
	public class AhappyWindow extends Window 
	{
		
		public var timerLabel:TextField;
		public var levelLabel:TextField;
		public var scoreLabel:TextField;
		public var scoreDescLabel:TextField;
		public var progressBarLabel:TextField;
		public var progressCount:TextField;
		
		public var image:Bitmap;
		protected var preloader:Preloader;
		//public var showBttn:Button;
		public var top100Bttn:Button;
		public var upgradeBttn:Button;
		public var helpBttn:Button;
		public var progressBar:ProgressBar;
		
		protected var toyContainer:Sprite;
		protected var treeContainer:Sprite;
		protected var scaleContainer:Sprite;
		protected var kicksContainer:Sprite;
		protected var scorePanel:Sprite;
		protected var kicksBacking:Shape;
		protected var rewardBacking:Shape;
		protected var scoreBacking:Shape;
		protected var rewardDescLabel:TextField;
		
		// Auction
		public var auctionEnd:int = 0;
		public var auctions:Vector.<AuctionItem> = new Vector.<AuctionItem>;
		public var auctionCont:Sprite;
		public var bonusMode:Boolean = false;
		protected var auctionBonusBttn:Button;
		
		public var sid:int = 0;
		public var info:Object = { };
		public var happy:Ahappy;
		private var overstack:Boolean = true;		// Накладывание картинок вида объекта одна на другую
		private var decoratable:Boolean = true;		// Наряжать игрушками?
		public var croped:Boolean = false;			// Урезаная версия. Без Топ100 и ряда надписей
		public var topNumber:int = 100;
		
		public function AhappyWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] || 830;
			settings['height'] = settings['height'] || 630;
			settings['title'] = settings.target.info.title;
			settings['color'] = 0x6e461e;
			settings['fontSize'] = 46;
			settings['borderSize'] = 2;
			settings['borderColor'] = 0xffffff;
			settings['shadowSize'] = 4;
			settings['shadowColor'] = 0x372e26;
			settings['hasPaginator'] = false;
			//settings['titleAutoSize'] = 'center';
			//settings['background'] = 'questBacking';
			
			settings['shadowSize'] = 4;
			settings['shadowColor'] = 0x611f13;
			settings["fontColor"]       = 0xfdfdfb;
			settings["fontBorderColor"]	= settings.fontBorderColor || 0xc38538;
			
			sid = settings.target.sid;
			info = App.data.storage[sid];
			happy = settings.target;
			topNumber = info.topx || 100;
			
			super(settings);
			
			getRate();
		}
		
		private var backL:Bitmap;
		private var backR:Bitmap;
		private var background:Bitmap;
		override public function drawBackground():void {
			if (!background) {
					background = new Bitmap();
					layer.addChild(background);
				}
			background.bitmapData = backing(settings.width, settings.height, 50, 'capsuleWindowBacking').bitmapData;
			
			backL = backing(560, settings.height - 100, 50, 'shopSpecialBacking');
			backL.x = 50;
			backL.y = 50;
			layer.addChild(backL);
			
			backR = backing(170, settings.height - 100, 50, 'shopSpecialBacking');
			backR.x = backL.x +backL.width;
			backR.y = 50;
			layer.addChild(backR);
		}
			
		override public function drawBody():void {
			titleLabel.y += 20;
			exit.x -= 16;
			exit.y += 15;
			//
			//helpBttn = drawHelp();
			//helpBttn.x = exit.x - helpBttn.width - 6;
			//helpBttn.y = exit.y;
			//helpBttn.addEventListener(MouseEvent.CLICK, onHelp);
			//headerContainer.addChild(helpBttn);
			
			/*bodyContainer.addChild(titleLabel);
			titleLabel.y = -10;*/
			
			var aLabel:TextField = Window.drawText(Locale.__e('flash:1481722258368'), {
				width:		background.width,
				textAlign:	'center',
				color:		0xffd000,
				borderColor:0x5b3409,
				fontSize:	27
				//multiline:	true,
				//wrap:		true
			});
			aLabel.x = backR.x + (backR.width - aLabel.width) / 2;
			aLabel.y = backR.y - 15;
			bodyContainer.addChild(aLabel);
			
			seporator(backL.x+5,320,backL.width-10,130);
			seporator(backL.x+5,backL.y+50,backL.width-10,130);
			seporator(backL.x + 5, 290, backL.width - 10, 10);
			
			seporator(backR.x + 5, backL.y+15, backR.width - 10, 7);
			seporator(backR.x+5,320,backR.width-10,130);
			seporator(backR.x+5,backL.y+50,backR.width-10,130);
			seporator(backR.x + 5, 290, backR.width - 10, 10);
			
			
			// Auction
	
			
			var bitmap:Bitmap = Window.backing(165, 480, 25, 'bonusBacking');
			//auctionCont.addChild(bitmap);
			
			//var actionTitle:String = '';
			//var auctionInfo:Object = Storage.info(happy.info.items[happy.info.items.length - 1]);
			//var auctionTitle:TextField = drawText(auctionInfo.title, {
				//width:		bitmap.width,
				//textAlign:	'center',
				//color:		0xffffff,
				//borderColor:0x3a50b6,
				//fontSize:	20
			//});
			////auctionTitle.x = auctionCont.x + auctionCont.width * 0.5 - auctionTitle.width * 0.5;
			////auctionTitle.y = auctionCont.y - 10;
			//bodyContainer.addChild(auctionTitle);
			
			
			
			drawState();
		
			drawScore();
						
			drawKicks();
			
			drawAuction();
			
			App.self.setOnTimer(timer);
			drawTimer();
			
			auctionBonusBttn = new Button( {
				width:		110,
				height:		42,
				caption:	Locale.__e('flash:1467807368649'),
				onClick:	onAuctionBonus
			});
			auctionBonusBttn.x = auctionCont.x + 84 - auctionBonusBttn.width * 0.5;
			auctionBonusBttn.y = auctionCont.y + auctionCont.height +20;
			bodyContainer.addChild(auctionBonusBttn);

			auctionBonusUpdate();
		}
		
		private function onHelp(e:MouseEvent):void {
			//new HelpWindow( {
				//title:settings.title,
				//content:	[
					//{ sid:5162, text:Locale.__e('flash:1481038167983') 	//D  Создавай необходимые материалы для участия в Забеге ...
					//////{sid:5162, text:Locale.__e('flash:1478683735554') },
					//////{sid:5175, text:Locale.__e('flash:1478683789353') }
				////]
			//}).show();
			trace();
		}
		
		private function auctionBonusUpdate():void {
			var complete:Boolean = false;
			for (var aid:* in App.user.auctions) {
				if (!(App.user.auctions[aid] is String)){
					for (var ai:* in happy.info.items)
						
					if (App.user.auctions[aid].started + happy.auctionTime <= App.time && happy.info.items[ai]==App.user.auctions[aid].aid)	//.indexOf(App.user.auctions[aid].aid) != -1)
						complete = true;
				}
			}
			
			if (complete) {
				auctionBonusBttn.visible = true;
			}else{
				auctionBonusBttn.visible = false;
				bonusMode = false;
			}
		}
		
		private function onClickInfo(e:MouseEvent):void 
		{
			//new HappyInfoWindow({target:this, update:settings.target.update}).show();
			trace();
		}
		
		private function drawDecor():void {
			var topBitmap:Bitmap = new Bitmap();
			var leftBitmap:Bitmap = new Bitmap();
			var rightBitmap:Bitmap = new Bitmap();
			var leftBaloonBitmap:Bitmap = new Bitmap();
			var rightBaloonBitmap:Bitmap = new Bitmap();
			
			// Garlands
			var horizontalBitmapData:BitmapData = new BitmapData(settings.width - 120, 37, true, 0);
			var verticalBitmapData:BitmapData = new BitmapData(37, settings.height - 100, true, 0);
			var fillBitmapData:BitmapData = UserInterface.textures.decorGarland;
			
			var position:int = 0;
			var number:int = 0;
			while (position < horizontalBitmapData.width) {
				horizontalBitmapData.draw(fillBitmapData, new Matrix(1, 0, 0, 1, position, 0));
				number++;
				position = fillBitmapData.width * number;
			}
			
			var angle:Number = -90 * Math.PI / 180;
			position = 0;
			number = 0;
			fillBitmapData = new BitmapData(UserInterface.textures.decorGarland.height, UserInterface.textures.decorGarland.width, true, 0);
			fillBitmapData.draw(UserInterface.textures.decorGarland, new Matrix(Math.cos(angle), -Math.sin(angle), Math.sin(angle), Math.cos(angle), 37));
			while (position < verticalBitmapData.height) {
				verticalBitmapData.draw(fillBitmapData, new Matrix(1, 0, 0, 1, 0, position));
				number++;
				position = fillBitmapData.height * number;
			}
			
			topBitmap.bitmapData = horizontalBitmapData;
			leftBitmap.bitmapData = verticalBitmapData;
			rightBitmap.bitmapData = verticalBitmapData;
			
			// Baloons
			leftBaloonBitmap = new Bitmap(UserInterface.textures.decorColorBaloon);
			leftBaloonBitmap.x = 0;
			leftBaloonBitmap.y = settings.height - 150;
			rightBaloonBitmap = new Bitmap(UserInterface.textures.decorColorBaloon);
			rightBaloonBitmap.scaleX = -1;
			rightBaloonBitmap.x = settings.width - 2;
			rightBaloonBitmap.y = settings.height - 150;
			
			topBitmap.x = 60;
			topBitmap.y = 8;
			leftBitmap.x = 20;
			leftBitmap.y = 40;
			rightBitmap.x = settings.width - rightBitmap.width - 20;
			rightBitmap.y = 40;
			
			bodyContainer.addChild(topBitmap);
			bodyContainer.addChild(leftBitmap);
			bodyContainer.addChild(rightBitmap);
			bodyContainer.addChild(leftBaloonBitmap);
			bodyContainer.addChild(rightBaloonBitmap);
		}
		
		protected function getReward():int 
		{
			//if (info.tower.hasOwnProperty(settings.target.update + 1)) {		//D
			if (info.tower.hasOwnProperty(settings.target.level + 1)) {
				//var items:Object = App.data.treasures[info.tower[settings.target.update + 1].t][info.tower[settings.target.update + 1].t].item; //D
				var items:Object = App.data.treasures[info.tower[settings.target.level + 1].t][info.tower[settings.target.level + 1].t].item; 
				for each(var s:* in items) {
					if (['Wanimal', 'Decor', 'Golden', 'Clothing', 'Box' , 'Walkgolden'].indexOf(App.data.storage[s].type) >= 0) 
						return int(s);
				}
			}
			else
			{
				var tres:String;
				for (var _t:* in App.data.top)
					if (App.data.top[_t].unit == info.rSID)
					{
						for (var _l:* in App.data.top[_t].league.tbonus)
						{
							for(var _tr:* in App.data.top[_t].league.tbonus[_l].t)
								tres = App.data.top[_t].league.tbonus[_l].t[_tr];
						}
						if (tres.length > 0)
							for each( var ins:String in App.data.treasures[tres][tres].item )
								if (['Wanimal', 'Decor', 'Golden', 'Clothing', 'Box' , 'Walkgolden'].indexOf(App.data.storage[ins].type) >= 0) 
									return int(ins);
				//}
						
							//return App.data.treasures[tres][tres]
					}
			}
			
			return 0;// details[sid].defaultReward;
		}
		
		private function onTreeLoad(data:Bitmap):void {
			addTreeState(data.bitmapData);
		}
		
		private function addTreeState(bmd:BitmapData):void {
			var bitmap:Bitmap = new Bitmap(bmd);
			bitmap.smoothing = true;
			bitmap.x = (440 - bitmap.width) / 2;
			bitmap.y = settings.height - bitmap.height;
			treeContainer.addChild(bitmap);
		}
		
		protected function drawTimer():void {			
			var timerBacking:Bitmap = new Bitmap(Window.textures.instCharBackingGuest/*mapGlow*/, 'auto', true);// Window.backingShort(150, 'seedCounterBacking'); 		 //D
			timerBacking.x =backL.x+(backL.width-timerBacking.width)/2;
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
				width:			timerBacking.width + 40,
				textAlign:		'center',
				fontSize:		40,
				color:			0xffd855,
				borderColor:	0x3f1b05
			});
			timerLabel.x = timerBacking.x + (timerBacking.width - timerLabel.width) / 2;
			timerLabel.y = timerBacking.y + 45;
			bodyContainer.addChild(timerLabel);
			
			if (settings.target.expire < App.time) {			//D
				timerBacking.visible = false;
				timerDescLabel.visible = false;
				timerLabel.visible = false;
			}
		}
		
		private var descBacking:Shape;
		protected function drawState():void {
			//if (settings.target.update >= Numbers.countProps(settings.target.info.tower)){		//D
			if (settings.target.level >= Numbers.countProps(settings.target.info.tower)){
				levelLabel = drawText(Locale.__e(''), {
					width:			180,
					textAlign:		'center',
					fontSize:		27,
					color:			0xffffff,
					borderColor:	0x6e3f11
				});
			}else{
				//levelLabel = drawText(Locale.__e('flash:1382952380004', [settings.target.update + 1, Numbers.countProps(settings.target.info.tower)]), {		//D
				levelLabel = drawText(Locale.__e('flash:1481038336247', [settings.target.level + 1, Numbers.countProps(settings.target.info.tower)]), {
					width:			180,
					textAlign:		'center',
					fontSize:		27,
					color:			0xffffff,
					borderColor:	0x6e3f11
				});
			}
			//levelLabel.x = settings.width / 2 - levelLabel.width / 2;
			levelLabel.x = backL.x+backL.width-levelLabel.width-10;
			levelLabel.y = 55;
			bodyContainer.addChild(levelLabel);
			
			// Описание
			//descBacking = backing(395, 110, 50, 'itemBacking');
			//bodyContainer.addChild(descBacking);
		
			var descText:String = info.description;
			
			var descLabel:TextField = drawText(descText, {
				textAlign:		'center',
				width:			380,
				fontSize:		23,
				color:			0x743512,
				borderColor:	0xeee3cd,
				//border:			false,
				multiline:		true,
				wrap:			true
			});
			descLabel.x = backL.x+((backL.width-120)-descLabel.width)/2;
			descLabel.y = backL.y+50+(130 - descLabel.height)/2;
			bodyContainer.addChild(descLabel);
			
			//descBacking.x = descLabel.x + (descLabel.width - descBacking.width) / 2;
			//descBacking.y = descLabel.y + (descLabel.height - descBacking.height) / 2;
			
			// Награда
			rewardBacking = new Shape();
			rewardBacking.graphics.beginFill(0xF6E4D0, 1);
			rewardBacking.graphics.drawCircle( 0,0 , 55);
			rewardBacking.graphics.endFill();
			rewardBacking.x = backL.x + backL.width - 75;
			rewardBacking.y = backL.y+50+(130-_w)/2 +55;
			
			bodyContainer.addChild(rewardBacking);
			
			var rewardGlow:Bitmap = new Bitmap(Window.textures.glowingBackingNew/*mapGlow*/, 'auto', true);// Window.backingShort(150, 'seedCounterBacking'); 		 //D
			rewardGlow.x = rewardBacking.x + ( - rewardGlow.width) / 2;
			rewardGlow.y = rewardBacking.y + ( - rewardGlow.height) / 2;
			rewardGlow.alpha = 0.7;
			bodyContainer.addChild(rewardGlow);
			
			//rewardDescLabel = drawText(Locale.__e('flash:1382952380000'), {
				//textAlign:		'center',
				//fontSize:		34,
				//color:			0x6e461e,
				//borderColor:	0xffffff,
				//width:			rewardBacking.width,
				//distShadow:		0
			//});
			//rewardDescLabel.x =  descBacking.x + ((descBacking.width-120)-rewardDescLabel.width)/2;
			//rewardDescLabel.y = descLabel.y - 60;
			//bodyContainer.addChild(rewardDescLabel);
			
			updateReward();
			
		}
		
		private var rewardCont:LayerX;
		private var reward:Bitmap;
		protected function updateReward():void {
			var sid:int = getReward();
			if (!App.data.storage[sid]) {
				//if (settings.target.update >= Numbers.countProps(settings.target.info.tower)){	//D
				if (settings.target.level >= Numbers.countProps(settings.target.info.tower)){
					//var checkMark:Bitmap = new Bitmap(UserInterface.textures.checknarkBig, 'auto', true);
					//checkMark.smoothing = true;
					//checkMark.x = rewardBacking.x + (rewardBacking.width - checkMark.width) / 2;
					//checkMark.y = rewardBacking.y + (rewardBacking.height - checkMark.height) / 2;
					//bodyContainer.addChild(checkMark);

				}
				return;
			}
			
			if (!rewardCont) {
				rewardCont = new LayerX();
				bodyContainer.addChild(rewardCont);
				
				reward = new Bitmap();
				rewardCont.addChild(reward);
			}
			
			reward.bitmapData = null;
			rewardCont.x = rewardBacking.x-55;
			rewardCont.y = rewardBacking.y-55;
			rewardCont.tip = function():Object {
				return { title:App.data.storage[sid].title, text:App.data.storage[sid].description };
			}
			
			
			var preloader:Preloader = new Preloader();
			preloader.x = rewardBacking.width / 2;
			preloader.y = rewardBacking.height / 2;
			rewardCont.addChild(preloader);
			
			var link:String = Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview);
			
			// Вместо любой из одежды показывается другая картинка (голова выглядит непрезентабельно)
			//if ([3055,3056,3057,3058].indexOf(sid) != -1) {
				//link = Config.getImage('content', 'cloth_preview');
			//}
			Load.loading(link, function(data:Bitmap):void {
				rewardCont.removeChild(preloader);
				preloader = null;
				
				reward.bitmapData = data.bitmapData;
				reward.smoothing = true;
				Size.size(reward, _w, _w);
				//if (reward.width > rewardBacking.width - 20) {
					//reward.width = rewardBacking.width - 20;
					//reward.scaleY = reward.scaleX;
				//}
				//if (reward.height > rewardBacking.height - 20) {
					//reward.height = rewardBacking.height - 20;
					//reward.scaleX = reward.scaleY;
				//}
				var title:TextField = Window.drawText(String(App.data.storage[sid].title), {
				color:0x753e17,
				borderColor:0xf8fdf6,
				textAlign:"center",
				autoSize:"center",
				fontSize:22,
				width:reward.width,
				textLeading: -6,
				wrap:true,
				multiline:true
				});

				//title.height = title.textHeight;
				title.y =-25;
				title.x = (reward.width-title.width)/2;
				rewardCont.addChild(title);
				
				
				rewardCont.x = rewardBacking.x -105+ (rewardBacking.width*2 - reward.width) / 2;
				rewardCont.y = rewardBacking.y -105+ (rewardBacking.height*2 - reward.height) / 2;
			});
			
			
		}
		private var progressBacking:Bitmap;
		protected function drawScore():void {
			if (!scorePanel) {
				scorePanel = new Sprite();
				scorePanel.x = 60;
				scorePanel.y = 220;
				bodyContainer.addChild(scorePanel);
			}
			
			if (scorePanel.numChildren > 0) {
				while (scorePanel.numChildren > 0) {
					var item:* = scorePanel.getChildAt(0);
					scorePanel.removeChild(item);
				}
			}
			
			if (settings.target.canUpgrade) {
				blockItems(true);
				
				/*if (!upgradeBttn) {
					upgradeBttn = new Button( {
						width:		170,
						height:		40,
						caption:	Locale.__e('flash:1382952379806')
					});
					upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
				}
				upgradeBttn.x = settings.width * 0.5 - upgradeBttn.width * 0.5;
				upgradeBttn.y = (croped) ? 410 : 510;
				bodyContainer.addChild(upgradeBttn);*/
				
			}else if (canTakeMainReward) {
				
				blockItems(true);
				
			}
			
			if (!upgradeBttn) {
				upgradeBttn = new Button( {
					width:		170,
					height:		40,
					caption:	Locale.__e('flash:1393579618588')
				});
				upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
			};
			upgradeBttn.x = 240;// settings.width * 0.5 - upgradeBttn.width * 0.5 ;
			upgradeBttn.y = 100;// backL.y + backL.height - upgradeBttn.height - 35;
			bodyContainer.addChild(upgradeBttn);
			upgradeBttn.state = (settings.target.canUpgrade || canTakeMainReward) ? Button.NORMAL : Button.DISABLED;
			
			//var progressBacking:Bitmap = Window.backingShort(410, "progressBarGrey");
			//progressBacking.x = 20;
			//progressBacking.y = 25;
			//scorePanel.addChild(progressBacking);
			//
			//progressBar = new ProgressBar( { win:this, width:progressBacking.width, timeSize:27,scale:.7 } );
			//progressBar.start();
			//progressBar.x = progressBacking.x + (progressBacking.width - progressBar.width) / 2-1;
			//progressBar.y = progressBacking.y - 3
			//scorePanel.addChild(progressBar);
			//progressBar.timer.text = '';
			//progressBacking.width = progressBacking.width - 28;
			//var totalLevels:int = 0;
			//for (var _t * in info.tower)
				//totalLevels++
			//if (settings.target.level < totalLevels)
			//{
				progressBacking = Window.backingShort(410, "progBarBacking");
				progressBacking.x = 80;
				progressBacking.y = 25;
				scorePanel.addChild(progressBacking);
					
				progressBar = new ProgressBar( { win:this, width:progressBacking.width+15, timeSize:27,scale:.7 } );
				progressBar.start();
				progressBar.x = progressBacking.x + (progressBacking.width - progressBar.width) / 2-1;
				progressBar.y = progressBacking.y - 3;
				scorePanel.addChild(progressBar);	
				
				
			
			
			
			//}
			progressBarLabel = drawText(Locale.__e("flash:1472117420508"), {
					width:			150,
					color:			0xfffef8,
					borderColor:	0x7c430e,
					fontSize:		24,
					textAlign:		'left'
				});
			progressBarLabel.x = progressBacking.x + (progressBacking.width - progressBarLabel.width) / 2-50;
			progressBarLabel.y = progressBacking.y + (progressBacking.height - progressBarLabel.height) / 2 + 3;
			scorePanel.addChild(progressBarLabel);
			
			progressCount = drawText('', {
					width:			progressBacking.width,
					color:			0xfdec7a,
					borderColor:	0x7c430e,
					fontSize:		32,
					textAlign:		'left'
				});
			progressCount.x = progressBarLabel.x +progressBarLabel.textWidth+20;
			progressCount.y = progressBarLabel.y + (progressBarLabel.height - progressCount.height)/2;
			scorePanel.addChild(progressCount);
			
			progress();
			
			//if (info.topx > 0 && !top100Bttn) {
				top100Bttn = new Button( {
					width:		140,
					height:		42,
					caption:	Locale.__e('flash:1418736014580')
				});
				top100Bttn.x = 90;// 180;
				top100Bttn.y = backL.y;// 14;
				top100Bttn.addEventListener(MouseEvent.CLICK, onTop100);
			//}
			
			
			if (top100Bttn) 
				bodyContainer.addChild(top100Bttn);
		}
		
		protected function progress():void {
			if (info.tower.hasOwnProperty(settings.target.upgrade + 1) && progressBar ) {								//D
				if (settings.target.upgrade > 0 && settings.target.kicksNeed == 0) {
					progressBarLabel.visible = false;
					progressCount.visible = false;
					progressBar.progress = 1;
					progressBar.timer.text = String(settings.target.kicks);		
				}else{
					progressBarLabel.visible = false;
					progressCount.visible = false;
					progressBar.progress = settings.target.kicks / settings.target.kicksNeed;
					if (settings.target.kicks > settings.target.kicksNeed) {
						settings.target.kicks = settings.target.kicksNeed;
					}
					progressBar.timer.text = Locale.__e("flash:1472117420508") +" "+ String(settings.target.kicks) + ' / ' + String(settings.target.kicksNeed);
				}
			}else{
				progressBacking.visible = false;
				progressBar.visible = false;
				progressCount.visible = true;
				progressCount.visible = true;
				progressCount.text = String(settings.target.kicks);
			}
		}
		
		private var toys:Vector.<HappyToy> = new Vector.<HappyToy>;
		private function drawToys():void {
			if (!decoratable) return;
			
			clearToys();
			
			for (var s:* in settings.target.toys) {
				var toy:HappyToy = new HappyToy(s, settings.target.toys[s], this);
				toyContainer.addChild(toy);
				toys.push(toy);
				toy.mode = HappyToy.BLOCK;
			}
		}
		private function clearToys():void {
			while (toys.length > 0) {
				var toy:HappyToy = toys.shift();
				toy.dispose();
			}
		}
		
		
		private var items2:Vector.<KickItem> = new Vector.<KickItem>;
		private var _w:int = 120;										//D диаметр круга
		public function drawKicks():void {
			
			const ITEM_WIDTH:int = 125;
			const ITEM_HEIGHT:int = 160;
			
			clearKicks();
			
			var rewards:Array = [];
			for (var s:String in info.kicks) {
				var object:Object = info.kicks[s];
				object['id'] = s;
				rewards.push(object);
			}
			rewards.sortOn('o', Array.NUMERIC | Array.DESCENDING);
			rewards.reverse();
						
			for (var i:int = 0; i < rewards.length; i++) {
				var item:KickItem = new KickItem(rewards[i],_w, this);
				item.x = backL.x + 30 + ITEM_WIDTH * items2.length;
				item.y = 325;
				bodyContainer.addChild(item);
				items2.push(item);
			}
			
			//var titleLabel:TextField = drawText((App.isSocial('FB','PL')) ? Locale.__e('flash:1481038494119') + ':' : Locale.__e('flash:1481038546070'), {
				//autoSize:		'center',
				//textAlign:		'center',
				//fontSize:		26,
				//color:			0xfcffff,
				//borderColor:	0x684e29
			//});
			//titleLabel.x = kicksBacking.x + kicksBacking.width / 2 - titleLabel.textWidth / 2;
			//titleLabel.y = kicksBacking.y - 15;
			//bodyContainer.addChild(titleLabel);
		}
		
		protected function clearKicks():void {
			while (items2.length > 0) {
				var item:KickItem = items2.shift();
				item.dispose();
			}
		}
		
		protected function onShow(e:MouseEvent):void {
			new HappyGuestWindow( {
				popup:		true,
				mode:		HappyGuestWindow.OWNER,
				target:		settings.target
			}).show();
		}
		
		private function seporator(_x:int,_y:int,_w:int,_h:int):void
		{
			var sepBacking:Shape = new Shape();
			sepBacking.x = _x;
			sepBacking.y = _y;
			bodyContainer.addChild(sepBacking);
			
						
			sepBacking.graphics.beginFill(0xe2c8a7,1)
			sepBacking.graphics.drawRect(0, 0,_w,_h);
			sepBacking.graphics.endFill();
		}
		
		// Auction
		public function drawAuction(auctionData:Object = null):void {
			
			var i:int = 0;
			var auction:AuctionItem;
			
			auctionClear();
			
			if (auctionCont)
					bodyContainer.removeChild(auctionCont);
					
			auctionCont = new Sprite();
			auctionCont.x = 610;
			auctionCont.y = 50;
			bodyContainer.addChild(auctionCont);
			
			var actionTitle:String = '';
			var auctionInfo:Object = Storage.info(happy.info.items[happy.info.items.length - 1]);
			var auctionTitle:TextField = drawText(auctionInfo.title, {
				//width:		bitmap.width,
				width:		140,
				textAlign:	'center',
				color:		0xffffff,
				borderColor:0x3a50b6,
				fontSize:	20
			});
			auctionTitle.x = auctionCont.x + auctionCont.width * 0.5 - auctionTitle.width * 0.5;
			auctionTitle.y = auctionCont.y - 10;
			bodyContainer.addChild(auctionTitle);
			
			if (bonusMode) {
				
				var list:Array = [];
				for (var aid:* in App.user.auctions) {
					for(var ai:* in happy.info.items)
						if (App.user.auctions[aid].started + happy.auctionTime <= App.time && happy.info.items[ai]==App.user.auctions[aid].aid) //.indexOf(App.user.auctions[aid].aid) != -1) {
							list.push(App.user.auctions[aid]);
						//}
				}
				
				if (list.length == 0) {
					auctionBonusUpdate();
					drawAuction();
					return;
				}
				
				list.sortOn('started', Array.NUMERIC | Array.DESCENDING);
				
				for (i = 0; i < 2; i++) {
					if (list.length <= i) return;
					
					auction = new AuctionItem(list[i].aid, list[i].started + happy.auctionTime, _w, this, list[i]);
					//auction.room = list[i].room;
					auction.x = (backR.width-_w)/2;
					auction.y = 57 + 225 * auctions.length;
					auctionCont.addChild(auction);
					auctions.push(auction);
				}
				
			}else {
				
				var autionsLeft:Number = (App.time - happy.auctionStart) / happy.auctionTime;
				//var autionsLeft:Number = (App.time - happy.auction.started) / happy.auctionTime;
				var auctionCurrent:Number = autionsLeft % Numbers.countProps(happy.info.items);
				auctionEnd = happy.auctionStart + Math.ceil(autionsLeft) * happy.auctionTime;
				//auctionEnd = happy.auction.started + Math.ceil(autionsLeft) * happy.auctionTime;
				
				var auctionObject:Object = happy.auction;
				//auctionEnd=auctionObject.sterted + happy.auctionTime
				for (i = 0; i < 2; i++) {
					var auctionListID:* = getAuctionId(auctionCurrent, i);
					
					auction = new AuctionItem(auctionListID, auctionEnd,_w, this, (i == 0) ? auctionObject : null);
					//auction = new AuctionItem(auctionListID, auctionObject.started+happy.auctionTime,_w, this, (i == 0) ? auctionObject : null);
					auction.x = (backR.width-_w)/2;
					auction.y = 57 + 215 * auctions.length;
					auctionCont.addChild(auction);
					auctions.push(auction);
					
					if (i > 0) {
						auction.next = true;
					}
				}
				
			}
			
			function getAuctionId(current:int, positionInList:int):* {
				return happy.info.items[(current + positionInList) % Numbers.countProps(happy.info.items)];
			}
			
		}
		public function auctionClear():void {
			while (auctions.length) {
				var item:AuctionItem = auctions.shift();
				item.dispose();
			}
			
		}
		
		protected function onAuctionBonus(e:MouseEvent):void {
			bonusMode = !bonusMode;
			
			auctionBonusBttn.caption = (bonusMode) ? Locale.__e('flash:1481038580917') : Locale.__e('flash:1481038617485');
			
			//drawAuction();
			
			if (bonusMode) {
				auctionClear();
				happy.updateAuctionView(drawAuction);
			}else {
				drawAuction();
			}
		}
		
		
		private var expire:int;
		private function onTop100(e:MouseEvent = null):void {
			
			if (e && e.currentTarget.mode == Button.DISABLED)
				return;
			var _top:int = 0;
			for(var _t:* in App.data.top)
				if (App.data.top[_t].target == sid){
					_top = _t;
					expire = App.data.top[_t].expire.e;
					break;
				}
					
			Post.send( {
				ctr:		'top',
				act:		'users',
				uID:		App.user.id,
				tID:		_top// App.user.topID				//D
			}, function(error:int, data:Object, params:Object):void {
				if (error) 
					return;
				
				if (data.hasOwnProperty('users'))
					Ahappy.users = data['users'] || { };

				if (Numbers.countProps(Ahappy.users) > topNumber) 
				{
					var array:Array = [];
					
					for (var s:* in Ahappy.users) 
					{
						array.push(Ahappy.users[s]);
					}
					
					array.sortOn('points', Array.NUMERIC | Array.DESCENDING);
					array = array.splice(0, topNumber);
					
					for (s in Ahappy.users) 
					{
						if (array.indexOf(Ahappy.users[s]) < 0)
							delete Ahappy.users[s];
					}
				}
				
				changeRate();
			
				if (onUpdateRate != null) {
					onUpdateRate();
					onUpdateRate = null;
				}
				onTop100Show();
			});
		}
		
		private var topRewerd:Object;
		private function onTop100Show():void 
		{
			var content:Array = [];
			var k:int = 0;
			for (var s:* in Ahappy.users) {
				var user:Object = Ahappy.users[s];
				user['uID'] = s;
				content.push(user);
				k++
			}
			var top100DescText:String =  Locale.__e('flash:1467807241824');
			getReward();
			new TopWindow( {
				target:			settings.target,
				title:info.title,
				expire:expire, 
				content:		content,
				description:	top100DescText,
				max:			topNumber,
				info:info,
				sid:settings.target.sid,
				top:topRewerd
			}).show();
			
			close();
		}
		
		protected function onUpgrade(e:MouseEvent):void {
			if (upgradeBttn == null || upgradeBttn.mode == Button.DISABLED) return;
			upgradeBttn.mode = Button.DISABLED;
			
			blockItems();
			settings.target.growAction(onUpgradeComplete);
		}
		
		protected function onUpgradeComplete(bonus:Object = null):void {
			if (bonus && Numbers.countProps(bonus) > 0) {
				for (var sid:* in bonus) break;
				for (sid in bonus) {
					if (['Wanimal', 'Golden', 'Box'].indexOf(App.data.storage[sid].type) != -1) break;
				}
				//Effect.wowEffect(sid);
				App.user.stock.addAll(bonus);
				App.ui.upPanel.update();
			}
			
			settings.target.showReward(bonus);
			
			//if (settings.target.update >= Numbers.countProps(settings.target.info.tower)){		//D
			if (settings.target.level >= Numbers.countProps(settings.target.info.tower)){
				levelLabel.text = Locale.__e('');
			}else{
				//levelLabel.text = Locale.__e('flash:1382952380004', [settings.target.update + 1, Numbers.countProps(settings.target.info.tower)]);	//D
				levelLabel.text = Locale.__e('flash:1481038336247', [settings.target.level + 1, Numbers.countProps(settings.target.info.tower)]);
			}
			drawScore();
			close();
			
			if (info.topx > 0)
				changeRate();
			
		}
		
		public function blockItems(value:Boolean = true):void {
			for (var i:int = 0; i < items2.length; i++) {
				Log.alert(items2[i].bttn.name + ' ' + String(items2[i].bttn.mode));
				if (value) {
					items2[i].bttn.state = Button.DISABLED;
				}else {
					items2[i].checkAhappyButtonsStatus();
				}
			}
		}
		
		public function kick():void {
			progress();
			
			if (settings.target.canUpgrade) {
				blockItems(true);
				drawScore();
			}else {
				blockItems(false);
				if (scoreLabel) scoreLabel.text = String(settings.target.kicks);
			}
			
			//if (settings.target.kicksNeed == 0) {
				changeRate();
			//}
		}
		
		protected function timer():void {
			/*if (settings.target.expire < App.time)
				close();*/
			
			timerLabel.text = TimeConverter.timeToStr((settings.target.expire < App.time) ? 0 : (settings.target.expire - App.time));
		}
		
		override public function dispose():void {
			if (top100Bttn) top100Bttn.removeEventListener(MouseEvent.CLICK, onTop100);
			if (upgradeBttn) upgradeBttn.removeEventListener(MouseEvent.CLICK, onUpgrade);
			//showBttn.removeEventListener(MouseEvent.CLICK, onShow);
			App.self.setOffTimer(timer);
			
			super.dispose();
		}
		
		public function get canTakeMainReward():Boolean {
			//if (settings.target.expire < App.time && Happy.rateChecked(sid) > 0 && (Numbers.countProps(info.tower) - 1 == settings.target.update) && settings.target.kicks >= settings.target.kicksMax && Happy.users.hasOwnProperty(App.user.id) && Happy.users[App.user.id]['take'] != 1)	//D
			if (settings.target.expire < App.time && Happy.rateChecked(sid) > 0 && (Numbers.countProps(info.tower) - 1 == settings.target.level) && settings.target.kicks >= settings.target.kicksMax && Happy.users.hasOwnProperty(App.user.id) && Happy.users[App.user.id]['take'] != 1)
				return true;
			
			return false;
		}
		
		protected var onUpdateRate:Function;
		public function changeRate():void {
			//if (settings.target.kicks < settings.target.kicksMax) return;
			if (Happy.users.hasOwnProperty(App.user.id) && Happy.users[App.user.id].attraction == settings.target.kicks) return;
			
			if (!Happy.users.hasOwnProperty(App.user.id))
			{
				if (Numbers.countProps(Happy.users) >= topNumber)
				{
					for (var id:* in Happy.users)
					{
						if (Happy.users[id].attraction < settings.target.kicks)
							delete Happy.users[id];
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
			
			//if (!Happy.users.hasOwnProperty(App.user.id) || Happy.users[App.user.id]['take'] == 1) return;
			
			if (settings.target.kicks == 0) return;
			
			var user:Object = { };
			user['first_name'] = App.user.first_name;
			user['last_name'] = App.user.last_name;
			user['photo'] = App.user.photo;
			user['attraction'] = settings.target.kicks;
			
			Post.send( {
				ctr:		'user',
				act:		'attraction',
				uID:		App.user.id,
				wID:		App.map.id,
				sID:		sid,
				id:			settings.target.id,
				rate:		info.type + '_' + String(sid),
				user:		JSON.stringify(user)
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data['users']) settings.target.usersLength = data.users;
			});
		}
		protected function getRate(callback:Function = null):void {
			if (Happy.rateChecked(sid) > 0) return;
			Happy.rateUpdate(sid, App.time);
			
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
				
				if (App.user.id == '120635122') {
					var user:Object = { };
					user['first_name'] = App.user.first_name;
					user['last_name'] = App.user.last_name;
					user['photo'] = App.user.photo;
					user['attraction'] = 999999999;
					Happy.users[App.user.id] = user;
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
				
				changeRate();
				
				if (settings.target.expire < App.time)
					drawScore();
				
				if (onUpdateRate != null) {
					onUpdateRate();
					onUpdateRate = null;
				}
			});
		}
	}

}



import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Numbers;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.utils.setTimeout;
import ui.Hints;
import ui.UserInterface;
import units.Ahappy;
import wins.Window;
import wins.ShopWindow;
import wins.SimpleWindow;
import wins.ProgressBar;
import wins.AhappyAuctionWindow;
import wins.AhappyRunningWindow;

internal class RewardItem extends Sprite {
	
	public static const WAIT:uint = 0;
	public static const REWARD:uint = 1;
	public static const EMPTY:uint = 2;
	
	public var bitmap:Bitmap;
	public var preloader:Preloader;
	public var takeBttn:Button;
	
	public var sID:int = 0;
	public var info:Object;
	
	public function RewardItem(sid:int, params:Object) {
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
			caption:	Locale.__e('flash:1481037719051'),
			fontSize:	21,
			radius:		10
		});
		takeBttn.x = 0;
		takeBttn.y = 40;
		addChild(takeBttn);
		takeBttn.addEventListener(MouseEvent.CLICK, onTake);
		
	}
	
	
	public function onLoad(data:Bitmap):void {
		removeChild(preloader);
		preloader = null;
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		bitmap.scaleX = bitmap.scaleY = 0.5;
		bitmap.x = -bitmap.width / 2;
		bitmap.y = -bitmap.height / 2;
		
	}
	
	private function onTake(e:MouseEvent):void {
		if (takeBttn.mode == Button.DISABLED) return;
		dispatchEvent(new Event(Event.OPEN));
	}
	
	private var _mode:uint = WAIT;
	public function set mode(value:uint):void {
		_mode = value;
		if (_mode == WAIT) {
			takeBttn.visible = true;
			takeBttn.state = Button.DISABLED;
		}else if (_mode == REWARD) {
			takeBttn.visible = true;
			takeBttn.state = Button.NORMAL;
		}else if (_mode == EMPTY) {
			takeBttn.visible = false;
		}
	}
	public function get mode():uint {
		return _mode;
	}
	
	public function dispose():void {
		takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
		if (parent) parent.removeChild(this);
	}
	
}

internal class KickItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Shape;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	public var buyBttn:MoneyButton;
	private var count:uint;
	private var nodeID:String;
	private var type:uint;
	private var WIDTH:int;
	
	public function KickItem(obj:Object,_w:int, window:*) {
		
		this.sID = obj.id;
		this.count = obj.k;
		this.nodeID = obj.id;
		this.item = App.data.storage[sID];
		this.window = window;
		type = obj.t;
		WIDTH = _w;
		//bg = Window.backing(120, 160, 20, 'itemBacking');
		bg = new Shape();
		bg.graphics.beginFill(0xF6E4D0, 1);
		bg.graphics.drawCircle(WIDTH/2,WIDTH/2, WIDTH/2);
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
			caption:Locale.__e('flash:1481038774311'),
			width:110,
			height:40,
			fontSize:23
		}
		
		if (type == 2) {
			bttnSettings['fontSize'] = 30;
			bttnSettings['caption'] = '     ' + item.price[Stock.FANT];
			bttnSettings['bgColor'] = [0xa5d835, 0x8fbd29];	//Цвета градиента
			bttnSettings['borderColor'] = [0xd0e69e, 0x71811e];	
			bttnSettings['fontColor'] = 0xfffeff;
			bttnSettings['fontBorderColor'] = 0x335206;
			
		}
		
		bttn = new Button(bttnSettings);
		bttn.x = (WIDTH - bttn.width) / 2;
		bttn.y = WIDTH - 5;//bg.height - bttn.height + 12;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		addChild(bttn);
		
		buyBttn = new MoneyButton( {
			width:		100,
			height:		30,
			fontSize	:18,
			radius		:15,
			caption:	Locale.__e('flash:1481038824437'),
			countText:	App.data.storage[sID].price[Stock.FANT],
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
			buyBttn.textLabel.y += 4;
		}
		
		checkAhappyButtonsStatus();
		//тестовая кнопка для ифно окна
		
	}
	
	
	public function checkAhappyButtonsStatus():void {
		if (window.settings.target.expire < App.time || window.settings.target.canUpgrade) {
			bttn.state = Button.DISABLED;
			return;
		}
		
		if (type == 2) {
			if (App.user.stock.count(Stock.FANT) < 1) {
				bttn.state = Button.DISABLED;
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
						bttn.state = Button.DISABLED;
					}
				}
			}else{
				bttn.state = Button.NORMAL;
			}
		}
	}
	
	private function onClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		if (type == 3 && App.user.stock.count(sID) < 1) {
			if (ShopWindow.findMaterialSource(sID)) {
				window.close();
			}else {
				new SimpleWindow( {
					popup:		true,
					title:		item.title,
					text:		item.description
				}).show();
			}
			
			return;
		}
		if (type == 2 && !App.user.stock.check(Stock.FANT, App.data.storage[sID].price[Stock.FANT])) {
			return;
		}
		window.blockItems();
		window.settings.target.kickAction(sID, onKickEventComplete);
		//checkAhappyButtonsStatus();
	}
	
	private function onMoneyClick(e:MouseEvent):void {
		if (buyBttn.mode == Button.DISABLED) return;
		buyBttn.state = Button.DISABLED;
		
		if (App.user.stock.check(Stock.FANT, App.data.storage[sID].price[Stock.FANT])) {
			App.user.stock.buy(sID, 1, function(param:*, params2:*):void {
				stockCountText.text = "x" + App.user.stock.count(sID);
				checkAhappyButtonsStatus();
			}/*, false*/);
		}
	}
	
	private function onKickEventComplete(bonus:Object = null):void 
	{
		if (!App.user.stock.take(priceID, price))
			return;
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(priceID, price, new Point(X, Y), false, App.self.tipsContainer);
		
		
		if (Numbers.countProps(bonus) > 0) {
			App.user.stock.addAll(bonus);
			BonusItem.takeRewards(bonus, bttn, 20);
			App.ui.upPanel.update();
		}
		
		if (type != 2) {
			stockCountText.text = "x" + App.user.stock.count(sID);
		}
		
		window.kick();
		checkAhappyButtonsStatus();
	}	
	
	private function onLoad(data:Bitmap):void {
		bitmap.bitmapData = data.bitmapData;
		
		//
		//if (bitmap.width > bg.width * 0.9) {
			//bitmap.width = bg.width * 0.9;
			//bitmap.scaleY = bitmap.scaleX;
		//}
		//if (bitmap.height > bg.height * 0.9) {
			//bitmap.height = bg.height * 0.9;
			//bitmap.scaleX = bitmap.scaleY;
		//}
		Size.size(bitmap, WIDTH - 10, WIDTH - 10)
		bitmap.smoothing = true;
		
		bitmap.x = (WIDTH - bitmap.width) / 2;
		bitmap.y = (WIDTH - bitmap.height) / 2;
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
		
		if (parent)
			parent.removeChild(this);
	}
	
	public function drawTitle():void {
		
		var title:TextField = Window.drawText(String(item.title) + ' +' + count.toString(), {
			color:0xfffdfa,
			borderColor:0x6e3f11,
			textAlign:"center",
			autoSize:"center",
			fontSize:22,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = WIDTH;
		title.height = title.textHeight;
		title.y = -25;
		title.x = 5;
		addChild(title);
	}
	
	private var stockCountText:TextField
	public function drawLabel():void {
		//var price:PriceLabel;
		if (type != 2) {
			stockCountText = Window.drawText("x" + App.user.stock.count(sID), {
				color:0xf8f1f9,
				borderColor:0x704012,
				textAlign:"center",
				autoSize:"center",
				fontSize:30,
				textLeading:-6,
				multiline:true
			});
			stockCountText.x = WIDTH / 2 + 5;//(bg.width - stockCountText.width) / 2;
			stockCountText.y = WIDTH / 2 + 15;//bg.height - stockCountText.height - 27;
			addChild(stockCountText);
		}
	}
	
	
	private function get price():int {
		if (type == 3)			return 1;
		else 					return item.price[Stock.FANT];
	}
	private function get priceID():int {
		if (type == 3)			return sID;
		else 					return Stock.FANT;
	}
}

internal class AuctionItem extends LayerX {
	
	private var background:Shape;
	private var image:Bitmap;
	private var auctionLabel:TextField;
	private var titleLabel:TextField;
	private var nextLabel:TextField;
	private var countLabel:TextField;
	private var enterBttn:Button;
	private var bonusBttn:Button;
	private var buyBttn:MoneyButton;
	private var preloader:Preloader;
	//private var progressBar:ProgressBar;
	private var progressBarAuct:Sprite;
	private var timerAuction:TextField;
	
	public var window:*;
	
	public var sid:int = 0;
	public var info:Object = null;
	public var require:Object;
	public var auction:Object;
	public var currencyInfo:Object;
	public var currency:*;
	public var currencyCount:int = 0;
	public var endTime:int = 0;
	private var _width:int;
	
	public function AuctionItem(sid:*, endTime:int,w:int, window:*, auction:Object = null) {
		
		this.window = window;
		this.auction = auction;
		this.sid = sid;

		info = Storage.info(sid);
		_width=w
		for (currency in info.currency) break;
		currencyCount = info.currency[currency];
		currencyInfo = Storage.info(currency);
		
		this.endTime = endTime;
		
		var backHeight:int = 200;
		if (endTime < App.time)
			backHeight = 140;
		
		//if (auction && App.user.id == '120635122')
			//delete auction.users['120635122'];
			
		//background = Window.backing(140, backHeight, 50, 'itemBacking');
		background = new Shape();
		background.graphics.beginFill(0xF6E4D0, 1);
		background.graphics.drawCircle(_width/2,_width/2, _width/2);
		background.graphics.endFill();

		addChild(background);
		
		image = new Bitmap();
		addChild(image);
																	//D чтобы войти
		auctionLabel = Window.drawText((endTime > 0 && endTime < App.time) ? Locale.__e('flash:1481037590340') : Locale.__e('flash:1481037534802') + ':', {
			width:		background.width,
			textAlign:	'center',
			color:		0xc5f7ff,
			borderColor:0x024160,
			fontSize:	23,
			multiline:	true,
			wrap:		true
		});
		auctionLabel.y = -35;
		
		//var head:Bitmap = new Bitmap(new BitmapData(background.width, auctionLabel.height + 12));
		//head.bitmapData.copyPixels(background.bitmapData, new Rectangle(0, 0, head.width, head.height), new Point());
		//head.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 196, 0);
		//addChild(head);
		addChild(auctionLabel);
		
		preloader = new Preloader();
		preloader.x = background.width * 0.5;
		preloader.y = background.height * 0.5 + auctionLabel.height * 0.5;
		addChild(preloader);
		
		titleLabel = Window.drawText(currencyInfo.title, {
			width:		background.width,
			textAlign:	'center',
			color:		0x6e461e,
			borderColor:0xffffff,
			fontSize:	21,
			multiline:	true,
			wrap:		true
		});
		titleLabel.y = -15;//auctionLabel.height + 14;
		addChild(titleLabel);
		
		nextLabel = Window.drawText(Locale.__e('flash:1481037669764'), {			//D следующий
			width:		background.width,
			textAlign:	'center',
			color:		0x6e461e,
			borderColor:0xffffff,
			fontSize:	24
		});
		nextLabel.y = _width - 5;
		addChild(nextLabel);
		nextLabel.visible = false;
		
		var bonusName:String = Locale.__e('flash:1481037777706');						//D Пусто
		if (auction && auction.users[App.user.id] && auction.users[App.user.id].count > 0)
			bonusName = Locale.__e('flash:1382952379737');
		
		bonusBttn = new Button( {
			caption:	bonusName,
			width:			110,
			height:			37,
			onClick:	onBonus
		});
		bonusBttn.x = (_width-bonusBttn.width)/2;
		bonusBttn.y =  _width+10;// background.y + background.height - enterBttn.height * 0.5 + 10;
		addChild(bonusBttn);
		bonusBttn.visible = false;
		
		
		
		enterBttn = new Button( {									//D войти
			caption:	Locale.__e('flash:1481037878659'),
			width:		110,
			fontSize:	24,
			textAlign: "center",
			height:		37,
			onClick:	onEnter
		});
		enterBttn.x = (_width-enterBttn.width)/2;
		enterBttn.y = _width+10;
		addChildAt(enterBttn,1);
		enterBttn.textLabel.width = _width;
		enterBttn.visible = false;
		
	
		
		buyBttn = new MoneyButton( {
			width:			enterBttn.width,
			height:			enterBttn.height,
			countText:		currencyInfo.price[Stock.FANT] * currencyCount,
			onClick:		function(e:*):void {
				if (buyBttn.mode == Button.DISABLED) return;
				buyBttn.state = Button.DISABLED;
				
				App.user.stock.buy(currency, currencyCount, function(_price:Object):void {
					var point:Point = BonusItem.localToGlobal(buyBttn);
					Hints.minus(Stock.FANT, _price[Stock.FANT], point, false, window);
					
					update();
				});
			}
		});
		buyBttn.x = (_width-buyBttn.width)/2;
		buyBttn.y =_width+10;// background.y + background.height - buyBttn.height * 0.5 - 5;
		addChild(buyBttn);

		progressBarAuct = new Sprite();
			//win:		window,
			//timeSize: 19,
			//width:		_width + 10
		//});
		progressBarAuct.x = 10;
		progressBarAuct.y = enterBttn.y - 30;
		//progressBar.x = progressBacking.x + (progressBacking.width - progressBar.width) / 2-1;
		//progressBar.y = progressBacking.y - 3;
		//
		timerAuction= Window.drawText('    ',{
				width:			_width-20,
				textAlign:		'center',
				fontSize:		20,
				color:			0xffd855,
				borderColor:	0x3f1b05
			});
			
		progressBarAuct.addChild(timerAuction);
		addChild(progressBarAuct);
		//progressBar.start();

		
		countLabel = Window.drawText('x' + currencyCount.toString(), {
			width:		background.width - 36,
			textAlign:	'right',
			color:		0x6e461e,
			borderColor:0xffffff,
			fontSize:	24
		});
		countLabel.x = background.x + background.width * 0.5 - countLabel.width * 0.5;
		countLabel.y = progressBarAuct.y - countLabel.height + 8;
		addChild(countLabel);
		
		if (endTime >= App.time) {
			App.self.setOnTimer(progress);
			progress();
		}else {
			
			// Если время уже истекло, найти позицию игрока и вывести возможную награду
			var users:Array = [];
			for (var uid:* in auction.users) {
				users.push( {
					uid:	uid,
					time:	auction.users[uid].time,
					count:	auction.users[uid].count
				});
			}
			users.sort(window.happy.userSort);
			
			var rewardID:int = 5;										//D Перепроверить.
			var rewardEqual:int = 0;
			for (var i:int = 3; i > -1; i--) {
				if (!users[i]) continue;
				
				if (users[i].count > rewardEqual) {
					rewardID--;
					rewardEqual = users[i].count;
				}
				
				if (users[i].uid == App.user.id) break;
			}
			
			try {
				require = info.devel[rewardID].items;
				
				for each(var reqCount:* in require) break;
				countLabel.text = 'x' + reqCount.toString();
				countLabel.y = bonusBttn.y - countLabel.height + 8;
			}catch(e:*) {
				countLabel.visible = false;
			}
		}
		
		update();
		
		var link:String;
		if (endTime > 0 && endTime < App.time) {
			// Определение ссылки для материала подарка
			for (var reqID:* in require) break;
			//if (auction && auction.users[App.user.id] && auction.users[App.user.id].count > 0 && reqID)
			if (reqID) {
				link = Config.getIcon('Material', App.data.storage[reqID].preview);
			//else
			//{
				//link = Config.getIcon(App.data.storage[auction.aid].type, App.data.storage[auction.aid].preview);
				//countLabel.visible = false;
			}
		}else {
			// Определение ссылки для материала аукциона
			link = Config.getIcon(currencyInfo.type, currencyInfo.preview);;
		}
		
		if (link) {
			Load.loading(link, function(data:Bitmap):void {
				if (preloader && preloader.parent)
					removeChild(preloader);
				
				image.bitmapData = data.bitmapData;
				image.smoothing = true;
				
				Size.size(image, _width, _width);
				
				image.x = _width * 0.5 - image.width * 0.5;
				image.y = _width * 0.5 - image.height * 0.5;
			});
		}else {
			removeChild(preloader);
		}
		
		tip = function():Object {
			return {
				title:	info.title,
				text:	info.description
			}
		}
	}
	
	private function update():void {
		// Следующий
		if (endTime == 0) {
			progressBarAuct.visible = false;
			countLabel.visible = false;
			enterBttn.visible = false;
			buyBttn.visible = false;
			nextLabel.visible = true;
			
		// Готовые фукционы
		}else if (endTime >= 0 && endTime < App.time) {
			bonusBttn.visible = true;
			progressBarAuct.visible = false;
			//countLabel.visible = false;
			enterBttn.visible = false;
			buyBttn.visible = false;
			nextLabel.visible = false;
			titleLabel.visible = false;
			
		// Аукцион в ожидании
		}else if (!inAuction) {
			enterBttn.caption = Locale.__e('flash:1481037829852');
			
			if (App.user.stock.count(currency) < currencyCount) {
				enterBttn.visible = false;
				buyBttn.visible = true;
			}else {
				enterBttn.visible = true;
				buyBttn.visible = false;
			}
			
		// 
		}else {
			buyBttn.visible = false;
			enterBttn.visible = true;
			enterBttn.caption = Locale.__e('flash:1481037878659');
		}
		
		if (window.happy.expire < App.time) {
			buyBttn.visible = false;
			enterBttn.visible = false;
			progressBarAuct.visible = false;
			countLabel.visible = false;
		}
	}
	
	private function onEnter(e:MouseEvent = null):void {
		if (enterBttn.mode == Button.DISABLED) return;
		
		if (inAuction) {
			openAuctionWindow();
		}else {
			var simpleWindow:SimpleWindow = new SimpleWindow( {
				width:		480,
				height:		440,
				popup:		true,
				dialog:		true,
				title:		info.title,
				text:		Locale.__e('flash:1481037943501', [currencyInfo.title, currencyInfo.title]),
				confirm:	onConfirm
			});
			simpleWindow.show();
			
			simpleWindow.textLabel.y = 105;
			
			
			Load.loading(Config.getImage('content', 'ahappy_' + window.sid.toString() ), function(data:Object):void {
				var image:Bitmap = new Bitmap(data.bitmapData, 'auto', true);
				image.x = -image.width + 90;
				image.y = -30;
				simpleWindow.bodyContainer.addChild(image);
			});
		}
		
		function onConfirm():void {									//D Запуск
			if (!App.user.stock.takeAll(info.currency)) return;
			
			enterBttn.state = Button.DISABLED;
			window.happy.enterAction(function(data:Object = null):void {
				enterBttn.state = Button.NORMAL;
				enterBttn.caption = Locale.__e('flash:1481037878659');
				update();
				openAuctionWindow();
			});
		}
	}
	
	private function openAuctionWindow():void {
		//if (window.happy.info.vtype && window.happy.info.vtype == Ahappy.TURKEY_RUN){
		Window.closeAll();
			new AhappyRunningWindow( {
				popup:		true,
				title:		info.title,
				text:		info.description,
				currency:	info['in'],
				auction:	window.happy.auction,
				target:		window.happy
			}).show();
		//} else {
			//new AhappyAuctionWindow( {
				//popup:		true,
				//title:		info.title,
				//text:		info.description,
				//currency:	info['in'],
				//auction:	window.happy.auction,
				//target:		window.happy
			//}).show();
		//}
	}
	
	private function onBonus(e:MouseEvent):void {
		if (!auction || bonusBttn.mode == Button.DISABLED) return;
		
		bonusBttn.state = Button.DISABLED;
		
		window.happy.bonusAction(auction, function(bonus:Object = null):void {
			if (Numbers.countProps(bonus) > 0) {
				for (var sid:* in bonus) break;
				var point:Point = new Point(window.mouseX, window.mouseY);
				Hints.plus(sid, bonus[sid], point, false, window);
				
				BonusItem.takeRewards(bonus, bonusBttn);
				App.user.stock.addAll(bonus);
				App.ui.upPanel.update();
			}
			
			window.drawAuction();
			window.drawKicks();
		});
	}
	
	private function progress():void {
		if (progressBarAuct) {
			var leftTime:int = endTime - App.time;
			//timerAuction.text = TimeConverter.timeToDays(leftTime);
			if (leftTime < 10 && !inAuction)
				enterBttn.state = Button.DISABLED;
			
			if (leftTime < 0) {
				App.self.setOffTimer(progress);
				progressBarAuct.visible = false;
				countLabel.visible = false;
				enterBttn.visible = false;
				bonusBttn.visible = false;
				
				setTimeout(window.drawAuction, 250);
				
			}else {
				//progressBar.progress = 1 - (leftTime / window.happy.auctionTime);
				//progressBar.time = leftTime;
				timerAuction.text = TimeConverter.timeToDays(leftTime);
				//trace();
			}
		}
	}
	
	public function get inAuction():Boolean {
		//return (window && auction && auction.users.hasOwnProperty(App.user.id) && endTime > App.time);
		return (window && window.happy.auction && endTime > App.time);
	}
	
	public function set next(value:Boolean):void {
		if (value) {
			progressBarAuct.visible = false;
			countLabel.visible = false;
			enterBttn.visible = false;
			buyBttn.visible = false;
			nextLabel.visible = true;
		}
	}
	
	public function dispose():void {
		enterBttn.dispose();
		enterBttn = null;
		
		bonusBttn.dispose();
		bonusBttn = null;
		
		buyBttn.dispose();
		buyBttn = null;
		
		//if (progressBarAuct) {
			//progressBarAuct.dispose();
			//progressBarAuct = null;
		//}
		
		App.self.setOffTimer(progress);
		
		if (parent)
			parent.removeChild(this);
	}
	
}