package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Anime2;
	import units.Hippodrome;
	import utils.TopHelper;
	/**
	 * ...
	 * @author 
	 */
	public class HippodromeMainWindow extends Window 
	{
		
		public var upgrHorseBttn:Button;
		public var playBttn:Button;
		public var topBttn:Button;
		
		public function HippodromeMainWindow(settings:Object=null) 
		{
			settings['background'] = settings.background || "paperWithBacking";
			settings['hasPaginator'] = false;
			settings['escExit'] = false;
			settings['width'] = 670;
			settings['height'] = 510;
			
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] = 0x116011;
			settings['shadowColor'] = 0x116011;
			settings['fontSize'] = 42;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 2;
			
			super(settings);
		}
		private var backImage:Bitmap;
		override public function drawBody():void 
		{
			exit.x += 3;
			exit.y -= 26;
			drawRibbon();
			titleLabel.y += 10;
			
			backImage = new Bitmap(Window.textures.hippodromImage);
			backImage.x = 60;
			backImage.y = 30;
			bodyContainer.addChild(backImage);
			Load.loading(Config.getSwf('Window', 'seahorse'), drawAnimation);
			
			drawBackDivider();
			drawDividerItems();
			drawLevels();
			drawButtons();
		}
		
		private function drawAnimation(swf:*):void 
		{
			var anime:Anime2 = new Anime2(swf, { w:backImage.width - 20, h:backImage.height - 40, framesType:'walk', type:'Animal' } );
			anime.scaleX = anime.scaleX * -1;
			anime.x = backImage.x + (backImage.width - anime.width) / 2;
			anime.y = backImage.y + (backImage.height - anime.height) / 2;
			anime.filters = [new DropShadowFilter(5, 40, 0, .35, 8, 8, 2)];
			bodyContainer.addChild(anime);
		}
		
		private var bttnSprite:Sprite = new Sprite();
		protected function drawButtons():void 
		{
			upgrHorseBttn = new Button( {
				width			:165,
				height			:50,
				radius			:19,
				fontSize		:28,
				//multiline		:true,
				textAlign		:'center',
				caption			:Locale.__e("flash:1494333803790"),
				fontBorderColor	:0x7f3d0e,	
				bgColor			:[0xf2ce4f,0xe1a535],
				bevelColor		:[0xf7fe9b, 0xcb6b1e]
				
			});
			bttnSprite.addChild(upgrHorseBttn);
			upgrHorseBttn.addEventListener(MouseEvent.CLICK, onOpenUpgWindow);
			
			playBttn = new Button( {
				width			:165,
				height			:50,
				radius			:19,
				fontSize		:28,
				textAlign		:'center',
				caption			:Locale.__e("flash:1494333772959"),
				fontColor		:0xf5ff57,	
				fontBorderColor	:0x6e039b,	
				bgColor			:[0xd46ffe, 0x9c32c8],
				bevelColor		:[0xfeb2fc, 0x8117ad]
				
			});
			playBttn.x = upgrHorseBttn.x + upgrHorseBttn.width + 10;
			bttnSprite.addChild(playBttn);
			playBttn.addEventListener(MouseEvent.CLICK, onCompetitionWindow)
			
			topBttn = new Button( {
				width			:165,
				height			:50,
				radius			:19,
				fontSize		:28,
				textAlign		:'center',
				caption			:Locale.__e("flash:1418896186635"),
				fontBorderColor	:0x3f7522,	
				bgColor			:[0xbcec63, 0x63ba1d],
				bevelColor		:[0xf6ffbc, 0x4e8b2c]
				
			});
			topBttn.x = playBttn.x + playBttn.width + 10;
			bttnSprite.addChild(topBttn);
			topBttn.addEventListener(MouseEvent.CLICK, onTopWindow)
			bodyContainer.addChild(bttnSprite);
			bttnSprite.x = (settings.width - bttnSprite.width) / 2;
			bttnSprite.y = settings.height - bttnSprite.height - 100;
		}
		
		private var winsSprite:Sprite = new Sprite();
		public var winsTextCount:TextField;
		private function drawDividerItems():void
		{
			var winsText:TextField = Window.drawText(Locale.__e('flash:1494335289134'),{
				fontSize		:42,
				color			:0x7e3e13,
				border			:false,
				textAlign		:"left"
			});
			winsText.width = winsText.textWidth + 10;
			winsText.x = 50;
			winsSprite.addChild(winsText);
			
			var istanceTop:int = TopHelper.getTopInstance(TopHelper.getTopID(settings.target.sid));
			
			var winCountt:int = 0;
			if (Numbers.countProps(App.user.data.user.top[TopHelper.getTopID(settings.target.sid)]) > 0)
			{
				if (App.user.data.user.top[TopHelper.getTopID(settings.target.sid)][istanceTop])
				{
					winCountt = App.user.data.user.top[TopHelper.getTopID(settings.target.sid)][istanceTop]['count'];
				}
					
			}
				
			winsTextCount = Window.drawText(String(winCountt),{
				fontSize		:56,
				color			:0xffffff,
				borderColor		:0x713f15,
				textAlign		:"left"
			});
			winsTextCount.x = winsText.x + winsText.textWidth + 5;
			winsTextCount.y = winsText.y + 5 + (winsText.height - winsTextCount.height) / 2;
			winsSprite.addChild(winsTextCount);
			
			var winsBmap:Bitmap = new Bitmap();
			winsSprite.addChild(winsBmap);
			Load.loading(Config.getIcon(App.data.storage[1599].type, App.data.storage[1599].preview),function(data:Bitmap):void{
				winsBmap.bitmapData = data.bitmapData;
				Size.size(winsBmap, 54, 54);
				winsBmap.smoothing = true;
				winsBmap.x = winsText.x - 27 - winsBmap.width / 2;
				winsBmap.y = winsText.y + (winsText.textHeight - winsBmap.height) / 2;
			});
			bodyContainer.addChild(winsSprite);
			winsSprite.x = backText.x + 25 + (backText.width - winsSprite.width) / 2;
			winsSprite.y = backText.y + 17;
			
			/*var competText:TextField = Window.drawText(Locale.__e('flash:1494335754392'),{
				fontSize		:30,
				color			:0x7e3e13,
				border			:false,
				textAlign		:"left"
			});
			competText.width = competText.textWidth + 10;
			competText.x = backText.x + 100;
			competText.y = winsText.y + winsText.height + 5;
			bodyContainer.addChild(competText);
			
			var competTextCount:TextField = Window.drawText(settings.target.games,{
				fontSize		:40,
				color			:0xffffff,
				borderColor		:0x713f15,
				textAlign		:"left"
			});
			competTextCount.x = competText.x + competText.textWidth + 5;
			competTextCount.y = competText.y + (competText.textHeight - competTextCount.textHeight) / 2;
			bodyContainer.addChild(competTextCount);
			
			var competBmap:Bitmap = new Bitmap();
			bodyContainer.addChild(competBmap);
			Load.loading(Config.getIcon(App.data.storage[1598].type, App.data.storage[1598].preview),function(data:Bitmap):void{
				competBmap.bitmapData = data.bitmapData;
				Size.size(competBmap, 40, 40);
				competBmap.smoothing = true;
				competBmap.x = competText.x - 25 - competBmap.width / 2;
				competBmap.y = competText.y + (competText.textHeight - competBmap.height) / 2;
			});*/
			
			//getWins(winsTextCount);
		}
		
		/*private function getWins(textFild:TextField):void
		{
			App.user.data
			Post.send( {
				ctr		:'top',
				act		:'position',
				uID		:App.user.id,
				tID		:TopHelper.getTopID(settings.target.sid)
			}, function(error:*, data:*, params:*):void
			{
				textFild.text = '1';
			});
		}*/
		
		private var backText:Shape = new Shape();
		private function drawBackDivider():void
		{
			backText.graphics.beginFill(0xffffff);
		    backText.graphics.drawRect(0, 0, settings.width - 140, 80);
			backText.y = 260;
			backText.x = (settings.width - backText.width) / 2;
		    backText.graphics.endFill();
			backText.filters = [new BlurFilter(40, 0, 2)];
			backText.alpha = .4;
		    bodyContainer.addChildAt(backText, 0);
			
			var dev:Shape = new Shape();
			dev.graphics.beginFill(0xc0804d);
			dev.graphics.drawRect(0, 0, settings.width - 110, 2);
			dev.graphics.endFill();
			
			var dev1:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev1.bitmapData.draw(dev);
			dev1.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			dev1.x = (settings.width - dev1.width) / 2;
			dev1.y = backText.y - dev1.height;
			bodyContainer.addChild(dev1);
			
			var dev2:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev2.bitmapData.draw(dev);
			dev2.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			dev2.x = (settings.width - dev2.width) / 2;
			dev2.y = backText.y + backText.height;
			bodyContainer.addChild(dev2);
		}
		
		private var levelsSprite:Sprite = new Sprite();
		protected function drawLevels():void 
		{
			var horseBmap:Bitmap = new Bitmap();
			levelsSprite.addChild(horseBmap);
			
			var horseLevelBg:Shape = new Shape();
			horseLevelBg.graphics.beginFill(0xe4a772);
			horseLevelBg.graphics.drawRoundRect(0, 0, 65, 50, 24, 24);
			horseLevelBg.filters = [new DropShadowFilter(1.0, 90, 0, 0.5, 2.0, 2.0, 1.0, 2, true, false, false), new DropShadowFilter(1.0, 90, 0xffffff, 0.5, 2.0, 2.0, 1.0, 2, false, false, false)];
			levelsSprite.addChild(horseLevelBg);
			
			var horseLevelTitle:TextField = Window.drawText(Locale.__e('flash:1494333667290'),{
				fontSize		:30,
				color			:0x7dfdff,
				borderColor		:0x713f15,
				width			:85,
				multiline		:true,
				wrap			:true,
				textAlign		:"center"
			});
			horseLevelTitle.x = horseLevelBg.x + (horseLevelBg.width - horseLevelTitle.width) / 2;
			horseLevelTitle.y = horseLevelBg.y - horseLevelTitle.height;
			levelsSprite.addChild(horseLevelTitle);
			
			Load.loading(Config.getImage('horses', 'horse'),function(data:Bitmap):void{
				horseBmap.bitmapData = data.bitmapData;
				Size.size(horseBmap, 70, 80);
				horseBmap.smoothing = true;
				horseBmap.x = horseLevelTitle.x - horseBmap.width - 5;
				horseBmap.y = horseLevelTitle.y + (horseLevelTitle.textHeight - horseBmap.height) / 2;
			});
			
			var horseLevelCount:TextField = Window.drawText(String(settings.target.floor),{
				fontSize		:40,
				color			:0xffffff,
				borderColor		:0x713f15,
				width			:horseLevelBg.width,
				textAlign		:"center"
			});
			horseLevelCount.x = horseLevelBg.x + (horseLevelBg.width - horseLevelCount.width) / 2;
			horseLevelCount.y = horseLevelBg.y + (horseLevelBg.height - horseLevelCount.textHeight) / 2;
			levelsSprite.addChild(horseLevelCount);
			
			var plus:Bitmap = new Bitmap(Window.textures.plus);
			levelsSprite.addChild(plus);
			plus.x = horseLevelBg.x + horseLevelBg.width + 27;
			plus.y = horseLevelBg.y + (horseLevelBg.height - plus.height) / 2;
			
			var expBmap:Bitmap = new Bitmap(UserInterface.textures.expIco);
			levelsSprite.addChild(expBmap);
			
			var heroLevelBg:Shape = new Shape();
			heroLevelBg.graphics.beginFill(0xe4a772);
			heroLevelBg.graphics.drawRoundRect(0, 0, 65, 50, 24, 24);
			heroLevelBg.filters = [new DropShadowFilter(1.0, 90, 0, 0.5, 2.0, 2.0, 1.0, 2, true, false, false), new DropShadowFilter(1.0, 90, 0xffffff, 0.5, 2.0, 2.0, 1.0, 2, false, false, false)];
			levelsSprite.addChild(heroLevelBg);
			heroLevelBg.x = 160;
			
			var heroLevelTitle:TextField = Window.drawText(Locale.__e('flash:1494333710548'), {
				fontSize		:30,
				color			:0x7dfdff,
				borderColor		:0x713f15,
				width			:85,
				multiline		:true,
				wrap			:true,
				textAlign		:"center"
			});
			heroLevelTitle.x = heroLevelBg.x + (heroLevelBg.width - heroLevelTitle.width) / 2;
			heroLevelTitle.y = heroLevelBg.y - heroLevelTitle.height;
			levelsSprite.addChild(heroLevelTitle);
			
			
			expBmap.x = heroLevelTitle.x - expBmap.width - 5;
			expBmap.y = heroLevelTitle.y + (heroLevelTitle.textHeight - expBmap.height) / 2;
			
			var heroLevelCount:TextField = Window.drawText(String(App.user.level),{
				fontSize		:40,
				color			:0xffffff,
				borderColor		:0x713f15,
				width			:heroLevelBg.width,
				textAlign		:"center"
			});
			heroLevelCount.x = heroLevelBg.x + (heroLevelBg.width - heroLevelCount.width) / 2;
			heroLevelCount.y = heroLevelBg.y + (heroLevelBg.height - heroLevelCount.textHeight) / 2;
			levelsSprite.addChild(heroLevelCount);
			
			
			var allCount:TextField = Window.drawText(String(App.user.level + settings.target.floor),{
				fontSize		:60,
				color			:0xf5ff57,
				borderColor		:0x713f15,
				width			:100,
				textAlign		:"center"
			});
			allCount.x = plus.x + (plus.width - allCount.width) / 2;
			allCount.y = plus.y + plus.height + 15;
			levelsSprite.addChild(allCount);
			
			bodyContainer.addChild(levelsSprite);
			levelsSprite.x = settings.width / 2 + 25;
			levelsSprite.y = 105;
		}
		
		/*protected function drawRibbon():void 
		{
			var titleBackingBmap:Bitmap = backingShort(settings.titleWidth + 180, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -65;
			bodyContainer.addChild(titleBackingBmap);
			
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y + 4;
			
			bodyContainer.addChild(titleLabel);
		}*/
		
		private function onTopWindow(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			TopHelper.showTopWindow(settings.target.sid);
		}
		
		private function onCompetitionWindow(e:MouseEvent):void{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			if (settings.target.playTime == 0 || settings.target.playTime <= App.time)
			{
				new HorseCompetitionWindow( {
					title:		Locale.__e('flash:1494340775437'),
					target:		settings.target,
					mode:		Hippodrome.HOME,
					window:		this,
					popup:		true
				}).show();
			}else{
				new SpeedWindow( {
					title			:settings.target.info.title,
					priceSpeed		:settings.target.info.skip,
					target			:settings.target,
					info			:settings.target.info,
					finishTime		:settings.target.playTime,
					totalTime		:settings.target.info.time,
					doBoost			:settings.target.onBoostEvent,
					btmdIconType	:settings.target.info.type,
					btmdIcon		:settings.target.info.preview,
					popup			:true
				}).show();
			}
		}
		
		private function onOpenUpgWindow(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
				
			Window.closeAll();
			settings.target.onOpenUpgWindow();
		}
		
	}

}