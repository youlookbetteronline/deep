package wins 
{
	import buttons.Button;
	import core.AvaLoad;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import units.Anime2;
	import units.Hippodrome;
	/**
	 * ...
	 * @author 
	 */
	public class HorseCompetitionWindow extends Window 
	{
		private var playBttn:Button;
		private var resultBttn:Button;
		private var progressBackingTop:Bitmap;
		private var progressBackingBot:Bitmap;
		private var progressCont:Sprite;
		private var avatar:Bitmap;
		private var avatarFriend:Bitmap;
		private var sprite:Sprite = new Sprite();
		private var sprite2:Sprite = new Sprite();
		protected var progressSliderTop:ProgressBar;
		protected var progressSliderBot:ProgressBar;
		public function HorseCompetitionWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['background'] = settings.background || "paperWithBacking";
			settings['hasPaginator'] = false;
			settings['faderClickable'] = false;
			settings['faderAsClose'] = false;
			settings['escExit'] = false;
			settings['width'] = 665;
			settings['height'] = 365;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] = 0x116011;
			settings['shadowColor'] = 0x116011;
			settings['fontSize'] = 42;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 2;
			super(settings);
			
		}
		override public function drawBody():void
		{
			exit.x += 5;
			exit.y -= 28;
			drawRibbon();
			titleLabel.y += 11;
			
			drawProgress();
			drawButtons();
			drawPoints();
			drawHorses();
		}
		protected function drawButtons():void 
		{
			playBttn = new Button( {
				width			:165,
				height			:50,
				radius			:19,
				fontSize		:28,
				//multiline		:true,
				textAlign		:'center',
				caption			:Locale.__e("flash:1474465958506"),
				fontBorderColor	:0x7f3d0e,	
				bgColor			:[0xf2ce4f,0xe1a535],
				bevelColor		:[0xf7fe9b, 0xcb6b1e]
				
			});
			layer.addChild(playBttn);
			playBttn.x = (settings.width - playBttn.width) / 2;
			playBttn.y = settings.height - 20 - playBttn.height / 2;
			if(settings.mode == Hippodrome.HOME)
				playBttn.addEventListener(MouseEvent.CLICK, onPlay);
			else
				playBttn.addEventListener(MouseEvent.CLICK, onGuestPlay);
			
			resultBttn = new Button( {
				width			:165,
				height			:50,
				radius			:19,
				fontSize		:28,
				//multiline		:true,
				textAlign		:'center',
				caption			:Locale.__e("flash:1494408737447"),
				fontBorderColor	:0x7f3d0e,	
				bgColor			:[0xf2ce4f,0xe1a535],
				bevelColor		:[0xf7fe9b, 0xcb6b1e]
				
			});
			layer.addChild(resultBttn);
			resultBttn.x = (settings.width - resultBttn.width) / 2;
			resultBttn.y = settings.height - 20 - resultBttn.height / 2 ;
			resultBttn.addEventListener(MouseEvent.CLICK, onResult);
			resultBttn.visible = false;
		}
		
		private var competitionReward:Object;
		private function onResult(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			var winMode:int = Hippodrome.LOSE;
			if (heroPoints > friendPoints)
				winMode = Hippodrome.WIN;
			else if (heroPoints == friendPoints)
				winMode = Hippodrome.DRAW;
			var winSettings:Object = {
				mode			:winMode,
				teritoryMode	:settings.mode,
				reward			:Treasures.convert2(competitionReward),
				popup			:true,
				target			:settings.target
			};
			if (settings.hasOwnProperty('window'))
				winSettings['window'] = settings['window'];
			
			new HippodromeResultWindow(winSettings).show();
			close();
		}
		
		private function onGuestPlay(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
				
			exit.visible = false;
				
			e.currentTarget.visible = false;
			
			Post.send( {
				ctr		:settings.target.type,
				act		:'guestplay',
				uID		:App.user.id,
				fID		:settings.friend.id,
				wID		:App.owner.worldID,
				sID		:settings.target.sid,
				id		:settings.target.id
			},onPlayEvent);
		}
		
		private function onPlay(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
				
			exit.visible = false;
				
			e.currentTarget.visible = false;
			
			Post.send( {
				ctr		:settings.target.type,
				act		:'play',
				uID		:App.user.id,
				wID		:App.user.worldID,
				sID		:settings.target.sid,
				id		:settings.target.id
			},onPlayEvent);
		}
		
		private function onPlayEvent(error:*, data:*, params:*):void
		{
			if (error) {
				if (error == 62 || error == 31)
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1501228132759',[settings.target.info.title]),
						popup:true
					}).show();
				}
				//Errors.show(error, data);
				return;
			}
			
			if (data.hasOwnProperty('notReady') && data['notReady'] == true)
			{
				new SimpleWindow( {
					title:Locale.__e("flash:1474469531767"),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1501228132759',[settings.target.info.title]),
					popup:true
				}).show();
			}
			
			if (data.hasOwnProperty('winner'))
			{
				if (data['winner'] == -1)
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1494929205933'),
						popup:true
					}).show();
					return;
				}
			}
				
			if (data.hasOwnProperty('bonus'))
				competitionReward = data.bonus;
				
			if (data.hasOwnProperty('pLevel'))
				friendPoints = data.pLevel;
				
			if (data.hasOwnProperty('uLevel'))
			{
				heroPoints = data.uLevel;
				heroLevelCount.text = String(heroPoints);
				heroLevelCount.visible = true;
			}
				
			if (data.hasOwnProperty('fLevel'))
				friendPoints = data.fLevel;
				
			if (data.hasOwnProperty('playTimeF'))
				settings.target.players[App.user.id] = data.playTimeF;
				
			if (data.hasOwnProperty('playTime'))
				settings.target.playTime = data.playTime;
				
			if (data.hasOwnProperty('player'))
				new AvaLoad(data.player.photo, onAvaFriendLoad);
			startCompetition();
		}
		
		/*protected function drawRibbon():void 
		{
			var ribbonWidth:int = settings.titleWidth + 180;
			if (ribbonWidth < 320)
				ribbonWidth = 320;
			
			var titleBackingBmap:Bitmap = backingShort(ribbonWidth, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -65;
			bodyContainer.addChild(titleBackingBmap);
			
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y + 6;
			
			bodyContainer.addChild(titleLabel);
		}*/
		
		private var topCounterBg:Shape;
		private var botCounterBg:Shape;
		private var questionText:TextField;
		protected function drawProgress():void
		{
			progressCont = new Sprite();
			
			progressBackingTop = Window.backingShort(385, "horseBacking");
			progressCont.addChild(progressBackingTop);
			
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0xc0804d);
			bg.graphics.drawRoundRect(0, 0, 50, 50, 15, 15);
			bg.graphics.endFill();
			progressCont.addChild(bg);
			
			progressCont.addChild(sprite);
			avatar = new Bitmap();
			sprite.addChild(avatar);
			sprite.x = bg.x;
			sprite.y = bg.y;
			
			new AvaLoad(App.user.photo, onAvaHeroLoad);
			
			progressBackingTop.x = bg.x + bg.width + 10;
			progressBackingTop.y = bg.y + (bg.height - progressBackingTop.height)/2;
			
			progressSliderTop = new ProgressBar({win:this,typeLine:'horseSlider', width:381, scale:1, isTimer:false});
			progressCont.addChild(progressSliderTop);
			progressSliderTop.progress = 1;
			progressSliderTop.x = progressBackingTop.x - 16;
			progressSliderTop.y = progressBackingTop.y - 12;
			
			topCounterBg = new Shape();
			topCounterBg.graphics.beginFill(0xe4a772);
			topCounterBg.graphics.drawRoundRect(0, 0, 50, 52, 22, 22);
			topCounterBg.filters = [new DropShadowFilter(1.0, 90, 0, 0.5, 2.0, 2.0, 1.0, 2, true, false, false), new DropShadowFilter(1.0, 90, 0xffffff, 0.5, 2.0, 2.0, 1.0, 2, false, false, false)];
			topCounterBg.x = progressBackingTop.x + progressBackingTop.width + 20;
			topCounterBg.y = progressBackingTop.y + (progressBackingTop.height - topCounterBg.height) / 2;
			progressCont.addChild(topCounterBg);
			
			var bg2:Shape = new Shape();
			bg2.graphics.beginFill(0xc0804d);
			bg2.graphics.drawRoundRect(0, 0, 50, 50, 15, 15);
			bg2.graphics.endFill();
			progressCont.addChild(bg2);
			
			bg2.x = bg.x;
			bg2.y = bg.y + 125;
			
			questionText = Window.drawText('?', {
				color:0xdfe622,
				border:false,
				textAlign:"center",
				width: bg2.width,
				fontSize:50
			});
			
			progressCont.addChild(sprite2);
			avatarFriend = new Bitmap();
			
			sprite2.addChild(questionText);
			questionText.x = (sprite2.width - questionText.width) / 2;
			questionText.y = (sprite2.height - questionText.height) / 2;
			
			sprite2.addChild(avatarFriend);
			sprite2.x = bg2.x;
			sprite2.y = bg2.y;
			
			if (settings.mode == Hippodrome.GUEST)
				new AvaLoad(settings.friend.photo, onAvaFriendLoad);
			
			progressBackingBot = Window.backingShort(385, "horseBacking");
			
			progressBackingBot.x = bg2.x + bg2.width + 10;
			progressBackingBot.y = bg2.y + (bg2.height - progressBackingBot.height) / 2;
			progressCont.addChild(progressBackingBot);
			
			progressSliderBot = new ProgressBar({win:this,typeLine:'horseSlider', width:381, scale:1, isTimer:false});
			progressCont.addChild(progressSliderBot);
			progressSliderBot.progress = 1;
			progressSliderBot.x = progressBackingBot.x - 16;
			progressSliderBot.y = progressBackingBot.y - 12;
			
			botCounterBg = new Shape();
			botCounterBg.graphics.beginFill(0xe4a772);
			botCounterBg.graphics.drawRoundRect(0, 0, 50, 52, 22, 22);
			botCounterBg.filters = [new DropShadowFilter(1.0, 90, 0, 0.5, 2.0, 2.0, 1.0, 2, true, false, false), new DropShadowFilter(1.0, 90, 0xffffff, 0.5, 2.0, 2.0, 1.0, 2, false, false, false)];
			botCounterBg.x = progressBackingBot.x + progressBackingBot.width + 20;
			botCounterBg.y = progressBackingBot.y + (progressBackingBot.height - botCounterBg.height) / 2;
			progressCont.addChild(botCounterBg);
			
			progressCont.x = (settings.width - progressCont.width) / 2;
			progressCont.y = (settings.height - progressCont.height) / 2 - 25;
			bodyContainer.addChild(progressCont);
		}
		
		private var heroLevelCount:TextField;
		private var friendLevelCount:TextField;
		private var heroPoints:int;
		private var friendPoints:int;
		private function drawPoints():void
		{
			heroPoints = App.user.level + settings.target.floor;
			heroLevelCount = Window.drawText(String(heroPoints),{
				fontSize		:40,
				color			:0xffffff,
				borderColor		:0x713f15,
				width			:topCounterBg.width - 4,
				textAlign		:"center",
				autoSize		:"center"
			});
			heroLevelCount.x = topCounterBg.x + (topCounterBg.width - heroLevelCount.width) / 2;
			heroLevelCount.y = topCounterBg.y + (topCounterBg.height - heroLevelCount.textHeight) / 2;
			progressCont.addChild(heroLevelCount);
			
			if(settings.mode == Hippodrome.GUEST)
				heroLevelCount.visible = false;
			
			friendPoints = 0;
			friendLevelCount = Window.drawText(String(friendPoints),{
				fontSize		:40,
				color			:0xffffff,
				borderColor		:0x713f15,
				width			:botCounterBg.width - 4,
				textAlign		:"center",
				autoSize		:"center"
			});
			friendLevelCount.x = botCounterBg.x + (botCounterBg.width - friendLevelCount.width) / 2;
			friendLevelCount.y = botCounterBg.y + (botCounterBg.height - friendLevelCount.textHeight) / 2;
			progressCont.addChild(friendLevelCount);
			friendLevelCount.visible = false;
		}
		
		private function drawHorses():void
		{
			Load.loading(Config.getSwf('Window', 'big_seahorse'), drawFirstAnimHorses);
		}
		
		private var hors1:Anime2;
		private var hors2:Anime2;
		private function drawFirstAnimHorses(swf:*):void 
		{
			hors1 = new Anime2(swf, { w:50, h:110, type:'Animal' } );
			hors1.x = progressBackingTop.x - hors1.width / 2;
			hors1.y = progressBackingTop.y + (progressSliderTop.height - hors1.height) / 2;
			
			hors2 = new Anime2(swf, { w:50, h:110, type:'Animal' } );
			hors2.x = progressBackingBot.x - hors2.width / 2;
			hors2.y = progressBackingBot.y + (progressBackingBot.height - hors2.height) / 2;
			
			//hors1.filters = [new DropShadowFilter(5, 40, 0, .35, 8, 8, 2)];
			progressCont.addChild(hors1);
			progressCont.addChild(hors2);
		}
		
		
		private function onAvaHeroLoad(data:*):void
		{
			if (data is Bitmap)
			{
				avatar.bitmapData = data.bitmapData;
				//avatar.scaleX = avatar.scaleY = 1.2;
				avatar.smoothing = true;
				//avatar.visible = false;
			}	
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawRoundRect(2, 2, 46, 46, 15, 15);
			shape.graphics.endFill();
			//shape.filters = [new BlurFilter(2, 2)];
			//shape.alpha = .5;
			shape.cacheAsBitmap = true;
			sprite.mask = shape;
			sprite.cacheAsBitmap = true;
			sprite.addChild(shape);
		}
		
		private function onAvaFriendLoad(data:*):void
		{
			if (data is Bitmap)
				avatarFriend.bitmapData = data.bitmapData;
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawRoundRect(2, 2, 46, 46, 15, 15);
			shape.graphics.endFill();
			shape.cacheAsBitmap = true;
			
			sprite2.mask = shape;
			sprite2.cacheAsBitmap = true;
			sprite2.addChild(shape);
		}
		
		private var allTime:int = 12;
		private var startTime:int;
		private function startCompetition():void
		{
			if (heroPoints > friendPoints)
			{
				myTotalTime = allTime;
				//friendTotalTime = allTime - (allTime / (heroPoints - friendPoints));
				friendTotalTime = allTime / (heroPoints / friendPoints);
			}else if (heroPoints < friendPoints){
				friendTotalTime = allTime;
				myTotalTime = allTime / (friendPoints / heroPoints);
			}else{
				friendTotalTime = allTime;
				myTotalTime = allTime;
			}
			startTime = App.time + allTime;
			progressSliderTop.progress = 0;
			progressSliderBot.progress = 0;
			progressSliderTop.start();
			progressSliderBot.start();
			App.self.setOnTimer(progressOfSliderTop);
			//progressSliderTop();
			//progressSliderTop.start();
		}
		
		private var myTotalTime:uint;
		private var friendTotalTime:uint;
		protected function progressOfSliderTop():void
		{
			var leftTime:int = startTime - App.time - Math.abs(myTotalTime - friendTotalTime);
			if (leftTime < 0) 
			{
				App.self.setOffTimer(progressOfSliderTop);
				
				friendLevelCount.text = String(friendPoints);
				friendLevelCount.visible = true;
				friendLevelCount.autoSize = 'center';
				
				resultBttn.visible = true;
				return;
			}
			var topProgress:Number = Math.abs(leftTime - myTotalTime) / Math.max(myTotalTime, friendTotalTime);
			var botProgress:Number = Math.abs(leftTime - friendTotalTime) / Math.max(myTotalTime, friendTotalTime);
			
			progressSliderTop.progress = topProgress;
			progressSliderBot.progress = botProgress;
			
			hors1.x = progressBackingTop.x + progressBackingTop.width * topProgress - hors1.width / 2;
			hors2.x = progressBackingBot.x + progressBackingBot.width * botProgress - hors2.width / 2;
		}
		
	}

}