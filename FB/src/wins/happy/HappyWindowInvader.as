package wins.happy 
{
	import buttons.IconButton;
	import buttons.ImagesButton;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	import units.AnimeHappy;
	import wins.happy.HappyToy;
	import astar.BinaryHeap;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.SimpleButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import units.Anime;
	import units.Anime2;
	import units.Happy;
	import units.Personage;
	import wins.ProgressBar;
	import wins.SimpleWindow;
	import wins.TopWindow;
	import wins.Window;
	import wins.happy.HappyToy;
	
	public class HappyWindowInvader extends Window
	{
		
		public var timerLabel:TextField;
		public var levelLabel:TextField;
		public var scoreLabel:TextField;
		
		public var image:Bitmap;
		protected var preloader:Preloader;
		public var showBttn:Button;
		public var top100Bttn:IconButton;
		public var upgradeBttn:Button;
		public var helpBttn:Button;
		public var progressBar:ProgressBar;
		
		protected var toyContainer:Sprite;
		protected var treeContainer:Sprite;
		protected var scaleContainer:Sprite;
		protected var kicksContainer:Sprite;
		protected var scorePanel:Sprite;
		protected var kicksBacking:Shape;
		protected var rewardBacking:Bitmap;
		
		
		public var sid:int = 0;
		public var info:Object = { };
		public var background:Bitmap;
		
		private var overstack:Boolean = true;		// Накладывание картинок вида объекта одна на другую
		private var decoratable:Boolean = false;		// Наряжать игрушками?
		
		public var topNumber:int = 50;
		
		public function HappyWindowInvader(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] ||750;
			settings['height'] = settings['height'] || 680;
			settings['title'] = settings.target.info.title;
			settings['hasPaginator'] = false;
			settings['background'] = 'newsBacking';
			
			sid = settings.target.sid;					
			info = App.data.storage[sid]
			if (info.hasOwnProperty('topx'))
			{
				if (info.topx.hasOwnProperty(App.social) )
					topNumber = info.topx[App.social] ;
				else
					topNumber = info.topx;
			}
			else
			{
				topNumber = 50;
			}
			super(settings);
			
			App.self.setOnTimer(timer);
			getRate();
		}
		
		
		override public function drawBackground():void 
		{
			if (!background) {
				background = new Bitmap();
				layer.addChild(background);
			}
			background.bitmapData = backing(settings.width, settings.height, 50, settings.background).bitmapData;
		}
			
		private var preloaderHeader:Preloader;
		override public function drawBody():void 
		{
			titleLabel.y += 50;
		
			//exit.x += 10;
			exit.y += 20;
			
			drawState(); //шапка
			
			drawReward();
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
			
			
			var topBttnText:String = Locale.__e('flash:1418736014580');
				top100Bttn = new IconButton(Window.textures.topHappyBttn,{
						width:		160,
						//height:		90,
						fontColor: 0xffe7d3,
						fontBorderColor:0x81380f,
						caption:	topBttnText
					});
				top100Bttn.textLabel.y += 3;
				top100Bttn.textLabel.x += 3;
				top100Bttn.addEventListener(MouseEvent.CLICK, onTop100);
				top100Bttn.x = background.x +background.width-top100Bttn.width-55;
				top100Bttn.y = background.y + 60;
				bodyContainer.addChild(top100Bttn);
				
			if (settings.target.expire < App.time || settings.target.canUpgrade)	{  	//D  прячем кнопку после окончания работы happy
				top100Bttn.state = Button.DISABLED;
			}
			
		
		}
		
		private var topCont:Sprite;
		private function drawReward():void 
		{
			if (topCont)
				bodyContainer.removeChild(topCont);

			topCont = new Sprite();

			//var topBacking:Shape = new Shape();
			//topBacking.x =58;
			//topBacking.y =/*backingRew.y*/140;
			////bodyContainer.addChild(topBacking);
			//
						//
			//topBacking.graphics.beginFill(0xe2c8a7,1)
			//topBacking.graphics.drawRect(0, 0,background.width - 115,160);
			//topBacking.graphics.endFill();
			
			bodyContainer.addChild(topCont);
			var infoTop:Object = { };
			for (var t:* in App.data.top)
				if (App.data.top[t].target == this.sid)
					infoTop = App.data.top[t];
					
			var k:int = 0;
			for (var j:* in infoTop.league.tbonus[1].t)
				k++;
				var dx:int = (settings.width-200) / k;
					
			var item:InfoWindowItem;		
			for (var i:* in infoTop.league.tbonus[1].t)	{
				item = new InfoWindowItem(infoTop.league.tbonus[1].t[i], i,this);
				item.x = i * dx;
				topCont.addChild(item);

			}
				topCont.y = 160;
				topCont.x = background.x + (background.width - topCont.width) / 2;
					trace();
			
		}
		
		override public function drawSpriteBorders(sprite:Sprite):void {
		   sprite.graphics.beginFill(0xff0000, 0.05);
		   sprite.graphics.lineStyle(2, 0xff0000, 1);
		   sprite.graphics.drawRoundRectComplex(0, 0, sprite.width, sprite.height, 1, 1, 1, 1);
		   sprite.graphics.endFill();
		}
		
		private var topRewerd:Object;
		protected function getReward():int 
		{
			for (var top:* in App.data.top)
			{
				if (App.data.top[top].unit == this.sid)
				{
					topRewerd = App.data.top[top];
				}
			}
			
			var items:Object 
			if (info.tower.hasOwnProperty(settings.target.upgrade + 1)) 
			{					//D
				items = App.data.treasures[info.tower[settings.target.upgrade + 1].t][info.tower[settings.target.upgrade + 1].t].item;
				for each(var s:* in items) 
					return int(s);
			}
			
			if (settings.target.kicksNeed == 0)
			{
				for (var topK:* in App.data.top)
				{
					if (App.data.top[topK].unit == this.sid)
					{
						//if(App.data.top[top].league.tbonus[1].t[2])
						items = App.data.treasures[App.data.top[topK].league.tbonus[1].t[2]][App.data.top[topK].league.tbonus[1].t[2]].item;
						for each(var t:* in items) 
						{
							return int(t);
						}
					}
				}
			}
						
			return 0;
		}
		
		private var rewardCont:LayerX;
		private var reward:Bitmap;
		private var top10Bttn:Button;
				
		private function showInfo(e:MouseEvent = null):void
		{
			//getReward();
			//new InfoWindow({popup:true,title:info.title,st:info.tower,top:topRewerd}).show();
		}
		
		private function onLoadAnimate(swf:*):void {
			rewardCont.removeChild(rewpreloader);
			var anime2:AnimeHappy;
			//if (!sprite) sprite = new LayerX();
			//if (!contains(sprite)) 
			//rewardCont.addChild(sprite);
			var framesType:String;

			if ( swf.sprites.length > 0 ){																	//D
				anime2 = new AnimeHappy(swf,{w:rewardW+20/*rewardBacking.width*/ , h:rewardW+20/*rewardBacking.height*/ });
				//anime2.x = circleRew.x + (circleRew.width - anime2.width) / 2;///* rewardBacking.x + */( rewardW/*rewardBacking.width*/ -  anime2.width ) / 2;
				//anime2.y =circleRew.y + (circleRew.height - anime2.height) / 2; //(backingRew.height/* rewardBacking.height*/ -  anime2.height ) / 2 + 15 ;
			}else {
				anime2 = new AnimeHappy(swf, {animal:true, framesType:Personage.STOP,  w:rewardW+20/*rewardBacking.width*/, h:rewardW+20/*rewardBacking.height*/ } );
				//anime2.x =/* rewardBacking.x + */( rewardW -  anime2.width ) / 2;
				//anime2.y =( backingRew.height -  anime2.height ) / 2 + 15 ;
			}
			
			anime2.x = circleRew.x + (circleRew.width - anime2.width) / 2;///* rewardBacking.x + */( rewardW/*rewardBacking.width*/ -  anime2.width ) / 2;
			anime2.y =circleRew.y + (circleRew.height - anime2.height) / 2+8; //(backingRew.height/* rewardBacking.height*/ -  anime2.height ) / 2 + 15 ;
			
			if (getReward() > 0) {
				var info:Object = App.data.storage[getReward()];
				anime2.tip = function():Object {
					return {
						title:info.title,
						text:info.description
					}
				}
			}
		
			rewardCont.addChild(anime2);
		}
		
		
		private var treeStates:Vector.<Bitmap> = new Vector.<Bitmap>;
				
		private function clearTree():void {
			while (treeContainer.numChildren > 0) {
				var item:* = treeContainer.getChildAt(0);
				treeContainer.removeChild(item);
			}
		}
		
		private function addTreeState(bmd:BitmapData):void {
			var bitmap:Bitmap = new Bitmap(bmd);
			bitmap.smoothing = true;
			bitmap.x = (440 - bitmap.width) / 2;
			bitmap.y = settings.height - bitmap.height;
			treeContainer.addChild(bitmap);
		}
		
		protected function drawTimer():void {
			var timerBacking:Bitmap = new Bitmap(Window.textures.iconGlow/*mapGlow*/, 'auto', true);// Window.backingShort(150, 'seedCounterBacking'); 		 //D
			timerBacking.x = 40;//background.x+(background.width-timerBacking.width)/2;
			timerBacking.y = 40;
			timerBacking.alpha = 0.7;
			bodyContainer.addChild(timerBacking);
			
			var timerDescLabel:TextField = drawText(Locale.__e('flash:1393581955601'), {
				width:			timerBacking.width,
				textAlign:		'center',
				fontSize:		29,
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
				color:			0xffee61,
				borderColor:	0x63371c
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
		
		private var rewardW:int = 120;
		private var rewX:int;
		private var backingRew:Shape;
		private var circleRew:Shape;
		protected var rewardDescLabel:TextField = new TextField();
		protected var rewardTitle:TextField = new TextField();
		private var tLevel:int = 0;
		protected function drawState():void {
			var descBacking:Shape = new Shape();
			descBacking.x =51;
			descBacking.y =42;
			bodyContainer.addChild(descBacking);
			descBacking.graphics.beginFill(0xf1c89a,1)
			descBacking.graphics.drawRect(0, 0,background.width - 103,110);
			descBacking.graphics.endFill();
			
			TextSettings.description.color = 0x622014;
			var descLabel:TextField = drawText(info.description, TextSettings.description);
			descLabel.width = 400;
			descLabel.wordWrap = true;
			descLabel.x = descBacking.x+(descBacking.width-descLabel.width)/2-15;
			descLabel.y = descBacking.y+(descBacking.height-descLabel.height)/2+5;
			bodyContainer.addChild(descLabel);
		}
		
		
		private var backingRew2:Shape;
		protected function drawScore():void {
			if (!scorePanel) 
			{
				scorePanel = new Sprite();
				scorePanel.x = 51;
				scorePanel.y = 335;
				bodyContainer.addChild(scorePanel);
			}
			
			if (scorePanel.numChildren > 0)
			{
				while (scorePanel.numChildren > 0) {
					var item:* = scorePanel.getChildAt(0);
					scorePanel.removeChild(item);
				}
			}
		
			backingRew2 = new Shape();
			//backingRew2.x = background.x+58;
			//backingRew2.y =scorePanel.y+scorePanel.height+15;
			scorePanel.addChild(backingRew2);
			
						
			backingRew2.graphics.beginFill(0xefc99a,1)
			backingRew2.graphics.drawRect(0, 0,background.width - 103,40);
			backingRew2.graphics.endFill();
						
			var scoreDescLabelText:String = Locale.__e('flash:1472117420508');
				
			var scoreDescLabel:TextField = drawText(scoreDescLabelText, {
					width:			150,
					textAlign:		'center',
					fontSize:		28,
					color:			0xf3f3d1,
					borderColor:	0x5a381c
				});
				
			scoreDescLabel.x = (backingRew2.width - scoreDescLabel.width) / 2-30;
			scoreDescLabel.y = (backingRew2.height-scoreDescLabel.height)/2+5;
			scorePanel.addChild(scoreDescLabel);
			
			
			scoreLabel = drawText(String(settings.target.kicks), {
					width:			150,
					textAlign:		'center',
					fontSize:		44,
					color:			0xfbec51,
					borderColor:	0x623619
				});
				
			scoreLabel.x = scoreDescLabel.x +scoreDescLabel.textWidth-30;
			scoreLabel.y = scoreDescLabel.y + (scoreDescLabel.height - scoreLabel.height) / 2;
			scorePanel.addChild(scoreLabel);
		
		}
		
		protected function progress():void {
			
			if (info.tower.hasOwnProperty(settings.target.upgrade + 1) && progressBar ) {								//D
				if (settings.target.upgrade > 0 && settings.target.kicksNeed == 0) {
					progressBar.progress = 1;
					progressBar.timer.text = String(settings.target.kicks);		
				}else{
					progressBar.progress = settings.target.kicks / settings.target.kicksNeed;
					if (settings.target.kicks > settings.target.kicksNeed) {
						settings.target.kicks = settings.target.kicksNeed;
					}
					progressBar.timer.text = String(settings.target.kicks) + ' / ' + String(settings.target.kicksNeed);
				}
			}
			
			
		}
		
		private var toys:Vector.<HappyToy> = new Vector.<HappyToy>;
		public function drawToys():void {
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
		//private var sprite:LayerX;
		private var rewpreloader:Preloader;
		private var rewardBttn:Button;
		public function drawKicks():void {
			clearKicks();
			var rewards:Array = [];
			for (var s:String in info.kicks) {
				var object:Object = info.kicks[s];
				object['id'] = s;
				rewards.push(object);
			}
			rewards.sortOn('o', Array.NUMERIC);
		
			var border:int = 25;

			
			if (!kicksBacking) {			
				kicksBacking = new Shape();
				kicksBacking.x = background.x+52;
				kicksBacking.y =/*backingRew.y*/390;
				bodyContainer.addChild(kicksBacking);
			
						
				kicksBacking.graphics.beginFill(0xefc99a,1)
				kicksBacking.graphics.drawRect(0, 0,background.width - 103,15);
				kicksBacking.graphics.endFill();
			}
			
				var kicksBacking2:Shape = new Shape();
				kicksBacking2.x = kicksBacking.x ;
				kicksBacking2.y =/*backingRew.y*/565;
				bodyContainer.addChild(kicksBacking2);
			
						
				kicksBacking2.graphics.beginFill(0xefc99a,1)
				kicksBacking2.graphics.drawRect(0, 0,background.width - 103,15);
				kicksBacking2.graphics.endFill();
		
			var infoTop:Object = { };
			for (var t:* in App.data.top)
				if (App.data.top[t].target == this.sid)
					infoTop = App.data.top[t];
					
			var k:int = 0;
			for (var j:* in infoTop.league.tbonus[1].t)
				k++;
			var dx:int = (settings.width-200) / k;
											
			for (var i:int = 0; i < rewards.length; i++) {
				var item:KickItem = new KickItem(rewards[i], this);
				item.x = (i+1) * dx-70; //kicksBacking.x + border + 160 * items2.length;
				item.y = kicksBacking.y + 30;
				bodyContainer.addChild(item);
				items2.push(item);
			}		
			
					
			
			
		}
		
		protected function clearKicks():void {
			while (items2.length > 0) {
				var item:KickItem = items2.shift();
				//item.removeEventListener(Event.OPEN, onRewardOpen);
				item.dispose();
			}
		}
		
		//private function onShow(e:MouseEvent):void {
			//new HappyGuestWindow( {
				//popup:		true,
				//mode:		HappyGuestWindow.OWNER,
				//target:		settings.target,
				//window:		this
			//}).show();
		//}
		
		protected function onTop100(e:MouseEvent = null):void {
			
			//if (!Happy.users || Numbers.countProps(Happy.users) == 0) return;
			
			if (rateChecked > 0 && rateChecked + 60 < App.time) {
				rateChecked = 0;
				getRate(onTop100);
				return;
			}
			
			//changeRate();
			
			Post.send( {
				ctr:		'top',
				act:		'users',
				uID:		App.user.id,
				tID:		App.user.topID
			}, function(error:int, data:Object, params:Object):void {
				if (error) 
					return;
				
				//if (data.hasOwnProperty('rate'))
					//Happy.users = data['rate'] || { };
			
				if (data.hasOwnProperty('users'))
					Happy.users = data['users'] || { };

				if (Numbers.countProps(Happy.users) > topNumber) 
				{
					var array:Array = [];
					
					for (var s:* in Happy.users) 
					{
						array.push(Happy.users[s]);
					}
					
					array.sortOn('points', Array.NUMERIC | Array.DESCENDING);
					array = array.splice(0, topNumber);
					
					for (s in Happy.users) 
					{
						if (array.indexOf(Happy.users[s]) < 0)
							delete Happy.users[s];
					}
				}
				
				changeRate();
				
				/*if (settings.target.expire < App.time)
					onUpgradeComplete();*/
					
				if (onUpdateRate != null) {
					onUpdateRate();
					onUpdateRate = null;
				}
				onTop100Show();
			});
			
			
			
		}
		
		private function onTop100Show():void 
		{
			var content:Array = [];
			var k:int = 0;
			for (var s:* in Happy.users) {
				var user:Object = Happy.users[s];
				user['uID'] = s;
				content.push(user);
				k++
			}
			trace("k " + k);
			var top100DescText:String =  Locale.__e('flash:1467807241824');
			getReward();
			new TopWindow( {
				target:			settings.target,
				content:		content,
				description:	top100DescText,
				max:			topNumber,
				info:info,
				top:topRewerd
			}).show();
			
			close();
		}
		
		protected function onUpgrade(e:MouseEvent):void {
			//if (upgradeBttn.mode == Button.DISABLED) return;
			//upgradeBttn.state = Button.DISABLED;
			
			if (canTakeMainReward)
				Happy.users[App.user.id]['take'] = 1;
			
			settings.target.growAction(onUpgradeComplete);
			
		}
		
		

		
		protected function onUpgradeComplete(bonus:Object = null):void {
			//if (bonus && Numbers.countProps(bonus) > 0) {
				//wauEffect();
				//BonusItem.takeRewards(bonus, upgradeBttn, 0, true, true);								//D
			//}
			
			levelLabel.text = Locale.__e('flash:1418735019900', settings.target.upgrade + 1)+"/"+tLevel;
			drawScore();
			//drawTree();
			//updateReward();
			blockItems(false);
		
			
			if (settings.target.upgrade >= Numbers.countProps(settings.target.info.tower) - 1 ) {
				changeRate();
			}
			//upgradeBttn.state = Button.NORMAL;
				//close()
		}
		
		protected function onHelp(e:MouseEvent):void {
			new SimpleWindow( {
				title:		settings.title,
				text:		App.data.storage[sid].text1,
				popup:		true,
				height:		420
			}).show();
		}
		
		public function blockItems(value:Boolean = true):void {
			for (var i:int = 0; i < items2.length; i++) {
				if (value) {
					items2[i].bttn.state = Button.DISABLED;
				}else {
					items2[i].checkButtonsStatus();
				}
			}
		}
		
		public function kick():void {
			progress();
			App.ui.upPanel.update();
			
			if (settings.target.canUpgrade) {
				blockItems(true);
				drawScore();
			}else {
				blockItems(false);
				if (scoreLabel) scoreLabel.text = String(settings.target.kicks);
			}
			
			//if (settings.target.kicksNeed == 0 || info.sID == 2004 || info.sID == 2240 || info.sID == 2388 || info.sid == 2486 || info.sID == 2877 || info.sID == 3225) {
				//changeRate();
			//}
		}
		
		protected function timer():void
		{
			timerLabel.text = TimeConverter.timeToDays((settings.target.expire < App.time) ? 0 : (settings.target.expire - App.time));
			
			
			//if (Events.timeOfComplete < App.time) {
				//close();
				//timerLabel.text="Время вышло"
			//}
		}
		
		override public function dispose():void {
			if (top100Bttn) top100Bttn.removeEventListener(MouseEvent.CLICK, onTop100);
			//if (upgradeBttn) upgradeBttn.removeEventListener(MouseEvent.CLICK, onUpgrade);
			//if (showBttn) showBttn.removeEventListener(MouseEvent.CLICK, onShow);
			//helpBttn.removeEventListener(MouseEvent.CLICK, onHelp);								//D
			App.self.setOffTimer(timer);
			super.dispose();
			//Happy.users = null;
		}
		
		protected function wauEffect(e:MouseEvent =  null):void {
			if (reward.bitmapData != null) {
				var rewardCont:Sprite = new Sprite();
				App.self.contextContainer.addChild(rewardCont);
				
				var glowCont:Sprite = new Sprite();
				glowCont.alpha = 0.6;
				glowCont.scaleX = glowCont.scaleY = 0.5;
				rewardCont.addChild(glowCont);
				
				var glow:Bitmap = new Bitmap(UserInterface.textures.actionGlow);
				glow.x = -glow.width / 2;
				glow.y = -glow.height + 90;
				glowCont.addChild(glow);
				
				var glow2:Bitmap = new Bitmap(UserInterface.textures.actionGlow);
				glow2.scaleY = -1;
				glow2.x = -glow2.width / 2;
				glow2.y = glow.height - 90;
				glowCont.addChild(glow2);
				
				var bitmap:Bitmap = new Bitmap(new BitmapData(reward.width, reward.height, true, 0));
				bitmap.bitmapData = reward.bitmapData;
				bitmap.smoothing = true;
				bitmap.x = -bitmap.width / 2;
				bitmap.y = -bitmap.height / 2;
				rewardCont.addChild(bitmap);
				
				rewardCont.x = layer.x + bodyContainer.x + this.rewardCont.x;
				rewardCont.y = layer.y + bodyContainer.y + this.rewardCont.y;
				
				function rotate():void {
					glowCont.rotation += 1.5;
				}
				
				App.self.setOnEnterFrame(rotate);
				
				//TweenLite.to(rewardCont, 0.5, { x:App.self.stage.stageWidth / 2, y:App.self.stage.stageHeight / 2, scaleX:1.25, scaleY:1.25, ease:Cubic.easeInOut, onComplete:function():void {
					//setTimeout(function():void {
						//App.self.setOffEnterFrame(rotate);
						//glowCont.alpha = 0;
						//var bttn:* = App.ui.bottomPanel.bttnMainStock;
						//var _p:Object = { x:bttn.x + App.ui.bottomPanel.mainPanel.x, y:bttn.y + App.ui.bottomPanel.mainPanel.y};					//D
						//SoundsManager.instance.playSFX('takeResource');
						//TweenLite.to(rewardCont, 0.3, { ease:Cubic.easeOut, scaleX:0.7, scaleY:0.7, x:_p.x, y:_p.y, onComplete:function():void {		//D
							//TweenLite.to(rewardCont, 0.1, { alpha:0, onComplete:function():void {}} );
						//}} );
					//}, 3000)
				//}} );
			}
		}
		
		public function get canTakeMainReward():Boolean {
			if (settings.target.expire < App.time && rateChecked > 0 && (Numbers.countProps(info.tower) - 1 == settings.target.upgrade) && settings.target.kicks >= settings.target.kicksMax && Happy.users.hasOwnProperty(App.user.id) && ( Happy.users[App.user.id].hasOwnProperty('take') || Happy.users[App.user.id]['take'] != 1))
				return true;
			
			return false;
		}
		
		public static var rateChecked:int = 0;
		public var onUpdateRate:Function;
		public function changeRate():void 
		{
			//if (settings.target.kicks < settings.target.kicksMax) return;
			if (Happy.users.hasOwnProperty(App.user.id) && Happy.users[App.user.id].points == settings.target.kicks) 
				return;
			
			if (!Happy.users.hasOwnProperty(App.user.id)) 
			{
				/*if (Numbers.countProps(Happy.users) >= topNumber)   //всех, кто ниже пользователя - удаляет
				{
					for (var id:* in Happy.users) 
					{
						if (Happy.users[id].points < settings.target.kicks) 
						{
							delete Happy.users[id];
						}
					}
				}*/
				
				if (Numbers.countProps(Happy.users) <= topNumber) 
				{
					Happy.users[App.user.id] = 
					{
						aka:			App.user.first_name + " " + App.user.last_name,
						photo:			App.user.photo,
						points:		0
					}
				}
			}
				
			if (Happy.users.hasOwnProperty(App.user.id)) 
			{														
				Happy.users[App.user.id].points = settings.target.kicks;
			}
	
			if (!Happy.users.hasOwnProperty(App.user.id) || Happy.users[App.user.id]['take'] == 1) 
				return;
			
			HappyWindow.rateSended[settings.target.sid] = settings.target.kicks;									//D
			
			//Post.send( {																							//D
				//ctr:		'user',
				//act:		'attraction',
				//uID:		App.user.id,
				//rate:		info.type + '_' + String(sid),
				//max:		topNumber,
				//user:		JSON.stringify({first_name:App.user.first_name, last_name:App.user.last_name, photo:App.user.photo, attraction:settings.target.kicks })
			//}, function(error:int, data:Object, params:Object):void {
				//if (error) return;
				//
				//if (data['users']) settings.target.usersLength = data.users;
			//});
		}
		
		public static var rateSended:Object = {};
		public function getRate(callback:Function = null):void 
		{
			//if (rateChecked > 0) return;
			rateChecked = App.time;
			
			onUpdateRate = callback;
			
			//App.user.topID;
			
			//Post.send( {
				//ctr:		'user',
				//act:		'rate',
				//uID:		App.user.id,
				//max:		topNumber,
				//rate:		info.type + '_' + String(sid)
			//}
			
			//Post.send( {											//D перенест на кнопку топ 100
				//ctr:		'top',
				//act:		'users',
				//uID:		App.user.id,
				//tID:		App.user.topID
			//}, function(error:int, data:Object, params:Object):void {
				//if (error) 
					//return;
				//
				////if (data.hasOwnProperty('rate'))
					////Happy.users = data['rate'] || { };
					//
				//if (data.hasOwnProperty('users'))
					//Happy.users = data['users'] || { };
				//
				//if (Numbers.countProps(Happy.users) > topNumber) 
				//{
					//var array:Array = [];
					//
					//for (var s:* in Happy.users) 
					//{
						//array.push(Happy.users[s]);
					//}
					//
					//array.sortOn('attraction', Array.NUMERIC | Array.DESCENDING);
					//array = array.splice(0, topNumber);
					//
					//for (s in Happy.users) 
					//{
						//if (array.indexOf(Happy.users[s]) < 0)
							//delete Happy.users[s];
					//}
				//}
				//
				//changeRate();
				//
				///*if (settings.target.expire < App.time)
					//onUpgradeComplete();*/
				//
				//if (onUpdateRate != null) {
					//onUpdateRate();
					//onUpdateRate = null;
				//}
			//});
		}
	}
}

import buttons.Button;
import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import units.Anime;
import wins.SimpleWindow;
import wins.Window;
import wins.BanksWindow;


import wins.ShopWindow;
internal class KickItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Shape;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	private var count:uint;
	private var nodeID:String;
	private var type:uint;
	private var WIDTH:int = 135;
	
	
	public function KickItem(obj:Object, window:*) {
		
		this.sID = obj.id;
		this.count = obj.k;			// obj.c;								//D
		this.nodeID = obj.id;
		this.item = App.data.storage[sID];
		this.window = window;
		type = obj.t;
		
		//bg = Window.backing(145, 190, 20, 'itemBacking');
		//addChild(bg);
		bg = new Shape();
		bg.graphics.beginFill(0xefc99a, 1);
		bg.graphics.drawCircle(WIDTH/2,WIDTH/2, WIDTH/2);
		bg.graphics.endFill();
		addChild(bg);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		drawTitle();
		drawBttn();
		drawLabel();
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);			//D
		
		tip = function():Object {												//D
			return {
				title: item.title,
				text: item.description
			}
		}
	}
	
	private function drawBttn():void {
		
		var bttnText:String;
		bttnText = Locale.__e('flash:1407231372860');                                          //D
		
		var bttnSettings:Object = {
			caption:bttnText,
			width:110,
			height:40,
			fontSize:26
		}
		
		if (type == 2) {
			bttnSettings['caption'] = '    ' + String(price);
			bttnSettings['bgColor'] = [0xa8f84a, 0x74bc17];		//Цвета градиента
			bttnSettings['borderColor'] = [0xffffff, 0xffffff];	//Цвета градиента
			bttnSettings['bevelColor'] = [0xc8fa8f, 0x5f9c11];	
			bttnSettings['price'] = price;
			bttnSettings['isMoneyBttn'] = true;
		}
		
		bttn = new Button(bttnSettings);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 25;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		addChild(bttn);
		
		if (type == 2) {
			var icon:Bitmap = new Bitmap(UserInterface.textures.fantsIcon, 'auto', true);
			icon.scaleX = icon.scaleY = 0.75;
			icon.x = 20;
			icon.y = 4;
			bttn.addChild(icon);
		}
		
		
		checkButtonsStatus();
	}
	
	public function checkButtonsStatus():void {
	
		if (window.settings.target.expire < App.time || window.settings.target.canUpgrade) {			//D
			bttn.state = Button.DISABLED;
			return;
		}
		
		if (type == 2) {
				bttn.state = Button.NORMAL;
		}else if (type == 3) {
			if (App.user.stock.count(sID) < price) {
				bttn.state = Button.NORMAL;
			}else {
				var bttnText:String;
				bttnText = Locale.__e('flash:1467807291800');
				bttn.state = Button.NORMAL;
				bttn.caption = bttnText;
			}
		}
		if(stockCount)
			stockCount.text = 'x' + App.user.stock.count(sID);
	}
	
	private function onClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		if (currency == Stock.FANT && App.user.stock.count(Stock.FANT) < price) {
			window.close();
			new BanksWindow().show();
			return;
		}
		if (type == 3 && App.user.stock.count(sID) < price)  {
			if (App.user.worldID == 93)
				
					for (var st:* in App.data.storage)
						if (App.data.storage[st].type == "Invader") {
							var ss:String =	App.data.storage[st].devel.req[1].treasure;
							var trSid:int =	App.data.treasures[ss][ss].item[0];
								if(trSid == this.sID){
									var foundFields:Array = Map.findUnits([st]);
										if (foundFields.length > 0)
											App.map.focusedOn(foundFields[0], true)
										else
											new SimpleWindow( {
									title:Locale.__e("flash:1382952379744"),
									label:SimpleWindow.ERROR,
									text:Locale.__e("flash:1382952379745")
								}).show();
						}}
			window.close();
			return;
		}
		
		
		window.blockItems();
		window.settings.target.kickAction(sID, onKickEventComplete);
		//checkButtonsStatus();
	}
	
	private function onKickEventComplete(bonus:Object = null):void {
		App.user.stock.take(currency, price);
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(currency, price, new Point(X, Y), false, App.self.tipsContainer);
		
		if (Numbers.countProps(bonus) > 0) {
			BonusItem.takeRewards(bonus, bttn, 20, true, true);									//D
		}
		
		stockCount.text = 'x' + App.user.stock.count(sID);
		window.kick();
		
		if (!App.user.stock.check(this.sID, 1))
			var bttnText:String = Locale.__e('flash:1407231372860');
	}	
	
	private function onLoad(data:Bitmap):void {
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = false;
		
		if (bitmap.width > bg.width * 0.8) {
			bitmap.width = bg.width * 0.8;
			bitmap.scaleY = bitmap.scaleX;
		}
		if (bitmap.height > bg.height * 0.8) {
			bitmap.height = bg.height * 0.8;
			bitmap.scaleX = bitmap.scaleY;
		}
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 - 10;
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function drawTitle():void {
		
		var title:TextField = Window.drawText(String(item.title) + ' +'+ count, TextSettings.itemTitle);
		//title.wordWrap = true;
		title.width = bg.width - 10;
		title.height = title.textHeight;
		title.x = 5;
		title.y = -35;
		addChild(title);
	}
	
	private var stockCount:TextField
	public function drawLabel():void 
	{
		stockCount = Window.drawText('x'+App.user.stock.count(sID),TextSettings.itemCount);
		stockCount.x = bg.width - stockCount.width - 20; //(bg.width - stockCount.width) / 2;
		stockCount.y = bg.height - stockCount.height - 14;
		
		if (type == 2)
			return;
			
		addChild(stockCount);
	}
	
	private function get price():int {
		if (type == 2) {												//D
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


internal class InfoWindowItem extends LayerX
{
	private var background:Bitmap;
	private var win:Window;
	
	
	public function InfoWindowItem(image:String,i:int, _win:Window,top:Boolean=false) {
		win = _win;
		drawBacking();
		
		this.tip=function():Object {
				return { title:App.data.storage[sid].title, text:App.data.storage[sid].description };
		}
		
		var sid:int=App.data.treasures[image][image].item[0]
	
		var titlPrms:Object = {
				color			:0xfcd7a2,
				borderColor		:0x6f1f1e,
				multiline		:true,
				wrap			:true,
				textAlign		:'center',
				fontSize		:28,
				border			:true
			}
		var descPrms:Object = {
				color			:0x7b441b,
				borderColor		:0xffffff,
				multiline		:true,
				wrap			:true,
				textAlign		:'center',
				fontSize		:20,
				border			:true
			}
			
		var txt:String;
			switch(i) {
				case 0:	txt = Locale.__e("flash:1470730106988"); break;
				case 1:	txt = Locale.__e("flash:1470730145930");break;
				case 2:	txt = Locale.__e("flash:1470730166282");break;
			}
		var titlLabel:TextField = Window.drawText(txt,titlPrms);
			
			titlLabel.width = background.width-5;
			titlLabel.x =(background.width-titlLabel.width)/2;
			titlLabel.y = 5 ;
			

	
		var descriptionLabel:TextField = Window.drawText(App.data.storage[sid].title,descPrms);
			
			descriptionLabel.width = background.width-5;
			descriptionLabel.x =(background.width-descriptionLabel.width)/2;
			descriptionLabel.y = titlLabel.y + titlLabel.height-4;
		
		
		var bitmap:Bitmap = new Bitmap();
		
		Load.loading (Config.getIcon(App.data.storage[sid].type,App.data.storage[sid].preview), function (data:*):void {
			bitmap.bitmapData = data.bitmapData;
			if (bitmap.width > 130){
				bitmap.width = 130;
				bitmap.scaleY = bitmap.scaleX;
			}
			if (bitmap.height > 130) {
				bitmap.height = 130;
				bitmap.scaleX = bitmap.scaleY;				
			}
			
			
			bitmap.x = (background.width - bitmap.width) / 2;
			
			if(bitmap.height==130)
				bitmap.y = background.height - bitmap.height;
			else {	
				
				bitmap.y = background.height - bitmap.height- (130- bitmap.height)/2;
			}
			addChild(bitmap);
			
		});
		
		addChild (titlLabel);
		addChild (descriptionLabel);	
	}
	
		
	protected function drawBacking():void {
		background = Window.backing(160, 170, 40, "itemBacking");
		addChildAt(background,0);
	}
}


