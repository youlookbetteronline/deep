package wins.happy 
{
	import buttons.IconButton;
	import buttons.ImagesButton;
	import core.Size;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
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
	
	public class HappyWindow extends Window
	{
		
		public var timerLabel:TextField;
		public var levelLabel:TextField;
		public var scoreLabel:TextField;
		private var backText:Shape = new Shape();
		public var image:Bitmap;
		public var background:Bitmap;
		protected var preloader:Preloader;
		public var showBttn:Button;
		public var top100Bttn:IconButton;
		public var bttnTr:Button;
		public var upgradeBttn:Button;
		public var helpBttn:Button;
		public var progressBar:ProgressBar;
		private var textFilter:GlowFilter;
		private var shadowFilter:BlurFilter;
		protected var toyContainer:Sprite;
		protected var treeContainer:Sprite;
		protected var scaleContainer:Sprite;
		protected var kicksContainer:Sprite;
		protected var scorePanel:Sprite;
		protected var progBarCont:Sprite;		
		protected var kicksBacking:Bitmap;
		protected var rewardBacking:Bitmap;
		protected var rewardBitmap:Bitmap;
		private var timerCont:LayerX;
		
		public static var rates:Object = { };			//D thappy
				
		public var sid:int = 0;
		public var info:Object = { };
		
		private var overstack:Boolean = true;		// Накладывание картинок вида объекта одна на другую
		private var decoratable:Boolean = false;		// Наряжать игрушками?
		
		//private var trees:Array;
		//public var topNumber:int = 100;
		public var topNumber:int = 50;
		
		public function HappyWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] ||800;
			settings['height'] = 525;
			settings['title'] = settings.target.info.title;
			settings['hasPaginator'] = false;
			settings['background'] = 'capsuleWindowBacking';
			
			settings['shadowSize'] = 4;
			settings['shadowColor'] = 0x611f13;
			settings["fontColor"]       = 0xfdfdfb;
			settings["fontBorderColor"]	= settings.fontBorderColor || 0xc38538;
			
			sid = settings.target.sid;					
			info = App.data.storage[sid]
			if (info.hasOwnProperty('topx') && info.htype!=1)
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
			
			if(info.htype!=1)
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
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xf9fdff,
				multiline			: settings.multiline,			
				fontSize			: 46,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x176b125c9900,			
				borderSize 			: 2,		
				shadowBorderColor	: 0x235b00,
				//width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -25;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		override public function titleText(settings:Object):Sprite
		{
			if (!settings.hasOwnProperty('width'))
				settings['width'] = 300;
				
			var cont:Sprite = new Sprite();
			var cont2:Sprite = new Sprite();
			var shadow:Sprite = new Sprite();
			
			var fontBorder:int = settings.fontBorderSize;
			settings.fontBorderSize = fontBorder;
			var fontBorderGlow:int = settings.fontBorderGlow;
			settings.fontBorderGlow = fontBorderGlow;
			
			
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			this.settings['titleWidth'] = textLabel.textWidth;
			this.settings['titleHeight'] = textLabel.textHeight;
			textLabel.wordWrap = true;
			textLabel.width = settings.width;
			textLabel.height = textLabel.textHeight + 4;
			
			var borderColor:uint = settings.borderColor
			settings.borderColor = borderColor;//settings.shadowBorderColor;
			settings.color = borderColor;
			
			var textShadow:TextField = Window.drawText(settings.title, settings);
			textShadow.wordWrap = true;
			textShadow.width = settings.width;
			textShadow.height = textLabel.textHeight + 4;
			
			textShadow.cacheAsBitmap = true;
			textLabel.cacheAsBitmap = true;

			var textShadow2:TextField = Window.drawText(settings.title, settings);
			textShadow2.wordWrap = true;
			textShadow2.width = settings.width;
			textShadow2.height = textLabel.textHeight + 4;
			textShadow2.cacheAsBitmap = true;
			
			settings.borderColor = 0x2a5e0b;
			settings.color = 0x2a5e0b;
			var textShadow3:TextField = Window.drawText(settings.title, settings);
			textShadow3.wordWrap = true;
			textShadow3.width = settings.width;
			textShadow3.height = textLabel.textHeight + 4;
			textShadow3.cacheAsBitmap = true;
					
			var textShadow4:TextField = Window.drawText(settings.title, settings);
			textShadow4.wordWrap = true;
			textShadow4.width = settings.width;
			textShadow4.height = textLabel.textHeight + 4;
			textShadow4.cacheAsBitmap = true;
			
			cont2.addChild(shadow);
			shadow.addChild(textShadow3);
			shadow.addChild(textShadow4);
			cont2.addChild(cont);
			
			//cont.addChild(textShadow);
			//cont.addChild(textShadow2);
			
			cont.addChild(textLabel);
			textFilter = new GlowFilter(0x579705, 1, 3,3, 10, 1);
			cont.filters = [textFilter/*, new BlurFilter(1.2,1.2,1)*/];
			
			shadowFilter = new BlurFilter(2,2,1);
			shadow.filters = [shadowFilter/*, new BlurFilter(1.2,1.2,1)*/];
			
			
			textShadow.y = 1;
			textShadow2.y = -2;
			textShadow3.y = 4;
			textShadow3.x = 1;
			textShadow4.y = 4;
			textShadow4.x = -1;
			cont.mouseEnabled = false;
			cont.mouseChildren = false;
			return cont2;
		}
			
		private var preloaderHeader:Preloader;
		override public function drawBody():void 
		{
		var titleBackingBmap:Bitmap = backingShort(titleLabel.width + 110, 'ribbonGrenn',true,1.3);
		titleBackingBmap.x = settings.width/2 -titleBackingBmap.width/2;
		titleBackingBmap.y = -70;
		bodyContainer.addChild(titleBackingBmap);
			
			exit.x -= 5;
			exit.y = -15;
			drawState(); //шапка
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
			
			backText.graphics.beginFill(0xf1cfbd);
		    backText.graphics.drawRect(0, 0, 480, 135);
			backText.y += 51;
			backText.x += 63;
		    backText.graphics.endFill();
			backText.filters = [new BlurFilter(40, 0, 2)];
		    bodyContainer.addChildAt(backText, 0);
			
			var description:TextField = drawText(Locale.__e('flash:1418735216505'), {
				width:			410,
				textAlign:		'center',
				fontSize:		26,
				multiline:		true,
				wrap:			true,
				color:			0x7f4015,
				border:			false
			});
			description.x = (settings.width - description.width) / 2 - 100;
			description.y = 57;
			bodyContainer.addChild(description);
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1396961879671"),
				width:160,
				height:50,
				fontSize:32
			}
			bttnSettings['bgColor'] = [0xc8e414, 0x80b631];
			bttnSettings['borderColor'] = [0xeafed1, 0x577c2d];
			bttnSettings['bevelColor'] = [0xdef58a, 0x577c2d];
			bttnSettings['fontColor'] = 0xffffff;
			bttnSettings['fontBorderColor'] = 0x526f00;
			if(info.htype!=1)
				drawTimer();
			var _top:int = 0;
			for(var _t:* in App.data.top)
				if (App.data.top[_t].target == sid){
					_top = _t;
					break;
				}
			if (_top > 0)
			{	
				var topBttnText:String = Locale.__e('flash:1473845055751', [App.data.top[_top].limit]);
				var bttntop:Bitmap = Window.backingShort(200, 'bttnTop');
					top100Bttn = new IconButton(bttntop.bitmapData,{
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
			}
			else{
				var bttnTrIcon:Bitmap = Window.backingShort(200, 'shopSpecialBacking1');
					bttnTr = new Button(bttnSettings);
					bttnTr.textLabel.y += 3;
					bttnTr.textLabel.x += 3;
					bttnTr.addEventListener(MouseEvent.CLICK, onTress);
					bttnTr.x = (settings.width - bttnTr.width) / 2;
					bttnTr.y = settings.height - 85;
					bodyContainer.addChild(bttnTr);
			}
		}
		
		private function onTress(e:MouseEvent):void 
		{
			//new HappyTopWindow({sid:info.rSID}).show();
			new HappyTopWindow({sid:1168}).show();
		}
		
		/*override public function drawSpriteBorders(sprite:Sprite):void {
		   sprite.graphics.beginFill(0xff0000, 0.05);
		   sprite.graphics.lineStyle(2, 0xff0000, 1);
		   sprite.graphics.drawRoundRectComplex(0, 0, sprite.width, sprite.height, 1, 1, 1, 1);
		   sprite.graphics.endFill();
		}*/
		
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
						//if(App.data.top[top].league.tbonus[1].t[2]){			
						var _tress:String;															//D +
						for (var _tb:* in App.data.top[topK].league.tbonus)						
							for (var _tr:* in App.data.top[topK].league.tbonus[_tb].t)
								_tress=App.data.top[topK].league.tbonus[_tb].t[_tr]
							
						//items = App.data.treasures[App.data.top[topK].league.tbonus[1].t[2]][App.data.top[topK].league.tbonus[1].t[2]].item;  //D -
						items = App.data.treasures[_tress][_tress].item;
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
		//private var top10Bttn:Button;
		//qrwpreloader
		protected function updateReward():void {
			var sid:int = getReward();
			if (rewardCont)
			{
				bodyContainer.removeChild(rewardCont);
				rewardCont = null;
			}
			if (sid == 0 && info.htype==1)
			{
				levelLabel.x = background.x + (background.width - levelLabel.width) / 2;
				descLabel.width = background.width - 180;
				descLabel.x= background.x + (background.width - descLabel.width) / 2;
				descLabel.y= backingRew.y+(backingRew.height-descLabel.height)/2;
				circleRew.visible = false;
				upgradeBttn.visible = false;
				rewGlow.visible = false;
				if (rewardTitle)
					rewardTitle.visible = false;
				return;
			}
			rewardTitle.text = App.data.storage[sid].title;
			rewardCont = new LayerX();
			bodyContainer.addChild(rewardCont);
			
			reward = new Bitmap();
			rewardCont.addChild(reward);
			
			if (!App.data.storage.hasOwnProperty(sid)) {
				reward.bitmapData = null;
				return;
			}
			
			rewardCont.x = backingRew.x+backingRew.width-rewardW-20//rewardBacking.x;
			rewardCont.y = backingRew.y + 5;//rewardBacking.y;
			
			
			rewardCont.tip = function():Object {
				return { title:App.data.storage[sid].title, text:App.data.storage[sid].description };
			}
			
			rewpreloader = new Preloader();
			rewpreloader.x = rewardCont.x;// rewardBacking.width / 2;
			rewpreloader.y = rewardCont.y;// rewardBacking.height / 2;
			rewardCont.addChild(rewpreloader);
			var typeObject:String = App.data.storage[sid].type;

			Load.loading(Config.getSwf(typeObject, App.data.storage[sid].preview), onLoadAnimate);	
		}
		
		private function showInfo(e:MouseEvent = null):void
		{
			getReward();
			new InfoWindow({popup:true,title:info.title,st:info.tower,top:topRewerd}).show();
		}
		
		private function onLoadAnimate(swf:*):void {
			rewardCont.removeChild(rewpreloader);
			var anime2:AnimeHappy;
			//if (!sprite) sprite = new LayerX();
			//if (!contains(sprite)) 
			//rewardCont.addChild(sprite);
			var framesType:String;
			
			//Size.size(anime2, 30, 30);
			if ( swf.sprites.length > 0 ){																	//D
				anime2 = new AnimeHappy(swf,{w:rewardW-10/*rewardBacking.width*/ , h:rewardW-10/*rewardBacking.height*/ });
			}else {
				anime2 = new AnimeHappy(swf, {animal:true, framesType:Personage.STOP,  w:rewardW-10/*rewardBacking.width*/, h:rewardW-10/*rewardBacking.height*/ } );
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
			timerCont = new LayerX();
			bodyContainer.addChild(timerCont);
			var timerDescLabel:TextField = drawText(Locale.__e('flash:1486476576457'), {
				width:			150,
				textAlign:		'center',
				fontSize:		30,
				color:			0xffffff,
				borderColor:	0x7e3e13
			});
			timerDescLabel.x = (settings.width - timerDescLabel.width) / 2 - 100;
			timerDescLabel.y = 10;
			timerCont.addChild(timerDescLabel);
			
			timerLabel = drawText('00:00:00', {
				width:			100,
				textAlign:		'center',
				fontSize:		30,
				color:			0xffdf34,
				borderColor:	0x7e3e13
			});
			timerLabel.x = timerDescLabel.x + timerDescLabel.textWidth + 10;
			timerLabel.y = timerDescLabel.y;
			timerCont.addChild(timerLabel);
			
			if (settings.target.expire < App.time) {			//D
				//timerBacking.visible = false;
				timerDescLabel.visible = false;
				timerLabel.visible = false;
			}
		}
		
		public var rewardW:int = 120;
		//private var rewardH:int = 190;
		public var rewX:int;
		public var backingRew:Shape;
		public var circleRew:Shape;
		public var rewGlow:Bitmap;
		public var descLabel:TextField;
		protected var rewardDescLabel:TextField = new TextField();
		protected var rewardTitle:TextField = new TextField();
		private var tLevel:int = 0;
		protected function drawState():void {
			//var descBacking:Bitmap = backing(445, 150, 50, 'itemBacking');
			//bodyContainer.addChild(descBacking);
			
			backingRew = new Shape();
			backingRew.x = background.x+58;
			backingRew.y =background.y+100;
			//bodyContainer.addChild(backingRew);
			
						
			backingRew.graphics.beginFill(0xe2c8a7,1)
			backingRew.graphics.drawRect(0, 0,background.width - 115,rewardW+10);
			backingRew.graphics.endFill();
			

			//var descLabelText:String =info['text2'];									//D Раскоментить
			descLabel = drawText(info.description, TextSettings.description);
			descLabel.width = 420;
			descLabel.wordWrap = true;
			descLabel.x = 90;
			descLabel.y = backingRew.y+(backingRew.height-descLabel.height)/2;
			bodyContainer.addChild(descLabel);

			for (var tl:* in info.tower)
				tLevel++;
			var userLvl:int = settings.target.upgrade;
			
			if (userLvl > tLevel)
				userLvl = tLevel;
				
			levelLabel = drawText(Locale.__e('flash:1418735019900', userLvl) + "/" + tLevel, TextSettings.steps);	//D Этап
			levelLabel.x = background.x +background.width - levelLabel.width-85;
			levelLabel.y = background.y + 50;
			bodyContainer.addChild(levelLabel);

			rewX = backingRew.x + backingRew.width - rewardW / 2 - 20;
			
			circleRew = new Shape();
			circleRew.graphics.beginFill(0xF6E4D0, 1);
			circleRew.graphics.drawCircle(rewX,backingRew.y+5+rewardW/2 , rewardW/2);
			circleRew.graphics.endFill();

			//bodyContainer.addChild(circleRew);
			preloader = new Preloader();
			addChild(preloader);

			rewGlow = new Bitmap(Window.textures.glowingBackingNew, 'auto', true);
			rewGlow.width = rewGlow.height = rewardW + 30;
			rewGlow.x =(rewX-circleRew.width/2) +(circleRew.width-rewGlow.width)/2;
			rewGlow.y =backingRew.y-10;
			//rewGlow.alpha = 0.7;
			bodyContainer.addChild(rewGlow);
			var sid:int = getReward();
			rewardBitmap = new Bitmap();
			bodyContainer.addChild(rewardBitmap);
			Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), onRewardLoad);
			
			TextSettings.rewardTitle['width'] =backingRew.width;
			rewardTitle = drawText('', TextSettings.rewardTitle);
			
			rewardTitle.x = (rewX-circleRew.width/2) +(circleRew.width-rewardTitle.width)/2;
			rewardTitle.y = backingRew.y-10;
			//rewardDescLabel.y = levelLabel.y + 30;//rewardBacking.y;
			bodyContainer.addChild(rewardTitle);
			
			
			//if (!upgradeBttn) {
			upgradeBttn = new Button( {
				width:		100,
				height:		40,
				fontSize: 21,
				caption:	Locale.__e('flash:1382952379737')		//D flash:1393579618588
			});
			upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
				//}
			upgradeBttn.x = (rewX-circleRew.width/2) +(circleRew.width-upgradeBttn.width)/2;; //250 - upgradeBttn.width / 2;
			upgradeBttn.y = settings.height - 100;
				//scorePanel.addChild(upgradeBttn);
			bodyContainer.addChild(upgradeBttn);

			updateReward();
		}
		
		public function onRewardLoad(data:Bitmap):void {
			removeChild(preloader);
			preloader = null;
			rewardBitmap.bitmapData = data.bitmapData;
			rewardBitmap.smoothing = true;
			rewardBitmap.scaleX = rewardBitmap.scaleY = 0.5;
			rewardBitmap.x = rewGlow.x + (rewGlow.width - rewardBitmap.width) / 2;
			rewardBitmap.y = rewGlow.y + (rewGlow.height - rewardBitmap.height) / 2;
			
		}
	
		
		public function get progressData():String {													//D
			return String(settings.target.kicks) + ' / ' + String(settings.target.kicksNeed);
		}
		
		protected var progressTitle:TextField;		//D
		private var backingRew2:Shape;
		protected function drawScore():void {
			if (!scorePanel) 
			{
				scorePanel = new Sprite();
				scorePanel.x = 50;
				scorePanel.y = 140;
				bodyContainer.addChildAt(scorePanel, 0);
			}
			
			if (scorePanel.numChildren > 0)
			{
				while (scorePanel.numChildren > 0) {
					var item:* = scorePanel.getChildAt(0);
					//scorePanel.removeChild(item);
				}
			}
		
						
			var scoreDescLabelText:String = Locale.__e('flash:1418736101766');
				
			var scoreDescLabel:TextField = drawText(scoreDescLabelText, {
					width:			150,
					textAlign:		'center',
					fontSize:		28,
					color:			0x7f4015,
					borderColor:	0xfffefe
				});
				
			scoreDescLabel.x = backingRew.x + (backingRew.width - scoreDescLabel.width) / 2-150;
			scoreDescLabel.y = -2;
			scorePanel.addChild(scoreDescLabel);
			
			var bgBubble:Bitmap = new Bitmap(Window.textures.clearBubbleBacking_0);
			Size.size(bgBubble, 50, 50); 
			bgBubble.x = scoreDescLabel.x + scoreDescLabel.textWidth + 42;
			bgBubble.y = scoreDescLabel.y + (scoreDescLabel.height - bgBubble.height) / 2;
			bgBubble.smoothing = true;
			scorePanel.addChild(bgBubble);
			
			scoreLabel = drawText(String(settings.target.kicks), {
					width:			150,
					textAlign:		'center',
					fontSize:		28,
					color:			0xffdf34,
					borderColor:	0x7e3e13
				});
				
			scoreLabel.x = bgBubble.x + (bgBubble.width - scoreLabel.width) / 2;
			scoreLabel.y = scoreDescLabel.y + (scoreDescLabel.height - scoreLabel.height) / 2 + 5;
			scorePanel.addChild(scoreLabel);
			
			scoreDescLabel.visible = false;
			scoreLabel.visible = false;
			bgBubble.visible = false;
			
			
			backingRew2 = new Shape();
			backingRew2.x = background.x+58;
			backingRew2.y =scorePanel.y+scorePanel.height+15;
			//bodyContainer.addChild(backingRew2);
			
			/*			
			backingRew2.graphics.beginFill(0xe2c8a7,1)
			backingRew2.graphics.drawRect(0, 0,background.width - 115,10);
			backingRew2.graphics.endFill();*/
		
			
			if (settings.target.canUpgrade && (settings.target.expire > App.time || info.htype==1)) 			//D  вернуть таймер
			{				

				scoreDescLabel.visible = true;	
				bgBubble.visible = true;	
				scoreLabel.visible = true;	
				upgradeBttn.state = Button.NORMAL;
				
			}else if (settings.target.upgrade < Numbers.countProps(info.tower) /*- 1*/ && (settings.target.expire > App.time || info.htype==1))
			{
				scoreDescLabel.visible = false;	
				bgBubble.visible = false;	
				scoreLabel.visible = false;	
				upgradeBttn.state = Button.DISABLED;
				
				/*var progressBacking:Bitmap = Window.backingShort(410, "progBarBacking");
				progressBacking.x = settings.width - 260;
				progressBacking.y = 270;
				progressBacking.rotation = 270;
				scorePanel.addChild(progressBacking);
				
				progressBar = new ProgressBar( { win:this, width:progressBacking.width+15, timeSize:27,scale:.7 } );
				progressBar.start();
				progressBar.x = progressBacking.x + (progressBacking.width - progressBar.width) / 2-1;
				progressBar.y = progressBacking.y + 10;
				progressBar.rotation = 270;
				
				scorePanel.addChild(progressBar);*/
				progBarCont = new Sprite;
				scorePanel.addChild(progBarCont);
				progBarCont.rotation = 90;
				//progBarCont.scaleY = progBarCont.scaleY *-1;
				//progBarCont.scaleX = progBarCont.scaleX *-1;
				progBarCont.x = settings.width - 155;
				progBarCont.y = -320;

				var progressBacking:Bitmap = Window.backingShort(380, "happyPanel");
				progressBacking.x = settings.width/2 - progressBacking.width/2;
				progressBacking.y = 0;
				progBarCont.addChild(progressBacking);
				
				progressBar = new ProgressBar({typeLine:'happySlider', win:this, width:376, timeSize:27, tY: -6});
				progressBar.start();
				progressBar.x = progressBacking.x + (progressBacking.width - progressBar.width) / 2 + progressBacking.width + 16;
				progressBar.y = progressBacking.y - 11;
				progressBar.scaleX = progressBar.scaleX *-1;
				progressBar.timer.scaleY = progressBar.timer.scaleY *-1;
				progressBar.timer.rotation = -90;
				progressBar.timer.x += 180;
				progressBar.timer.y += 175;
				progBarCont.addChild(progressBar);
				
				//progressBar.progress = 0.5;
				
				progress();
			} else if (canTakeMainReward) 
			{				
				blockItems(true);
				
				if (!upgradeBttn) 
				{
					upgradeBttn = new Button( {
						width:		200,
						height:		55,
						caption:	Locale.__e('flash:1393579618588')
					});
					upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
				}
				
				upgradeBttn.x = 220 - upgradeBttn.width / 2;
				upgradeBttn.y = 0;
				scorePanel.addChild(upgradeBttn);				
			} else {
				scoreDescLabel.visible = true;	
				scoreLabel.visible = true;	
				bgBubble.visible = true;	
				upgradeBttn.state = Button.DISABLED;
			}
		}
		
		public function progress():void {
			
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
				progressBar.timer.textColor = 0xffdf34;
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
		private var sprite:LayerX;
		private var rewpreloader:Preloader;
		public var rewardBttn:Button;
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

			var _w:int;
				if (settings.width > 750)
						_w = 145;
					else
						_w = 120;
			
			if (!kicksBacking) {			
				kicksBacking = backing2(510,210, 36, 'happyBgTop', 'happyBgBottom');
				kicksBacking.x = 50;
				kicksBacking.y = 200;
				bodyContainer.addChild(kicksBacking);
			}
			
			var itemDescription:TextField = drawText(Locale.__e('flash:1418742079569'), {
				width:			410,
				textAlign:		'center',
				fontSize:		30,
				multiline:		true,
				wrap:			true,
				color:			0xffffff,
				borderColor:	0x7f3d0e
			});
			itemDescription.x = kicksBacking.x + (kicksBacking.width - itemDescription.width) / 2;
			itemDescription.y = kicksBacking.y - 15;
			bodyContainer.addChild(itemDescription);

			for (var i:int = 0; i < rewards.length; i++) {
				var item:KickItem = new KickItem(rewards[i],_w, this);
				item.x = kicksBacking.x + border + (_w+15) * items2.length;
				item.y = kicksBacking.y + 47;
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

		private var expire:int;
		public function onTop100(e:MouseEvent = null):void {
			
			//if (!Happy.users || Numbers.countProps(Happy.users) == 0) return;
			
			if (rateChecked > 0 && rateChecked + 60 < App.time) {
				rateChecked = 0;
				getRate(onTop100);
				return;
			}
			
			//changeRate();
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
			if (upgradeBttn.mode == Button.DISABLED) return;
			//upgradeBttn.state = Button.DISABLED;
			
			if (canTakeMainReward)
				Happy.users[App.user.id]['take'] = 1;
			
			settings.target.growAction(onUpgradeComplete);
			
		}
		
		

		
		public function onUpgradeComplete(bonus:Object = null):void {

			var _l:int = settings.target.upgrade;
			if (_l> tLevel)
				_l=tLevel
			levelLabel.text = Locale.__e('flash:1418735019900', _l)+"/"+tLevel;
			drawScore();
			//drawTree();
			updateReward();
			blockItems(false);
		
			
			if (settings.target.upgrade >= Numbers.countProps(settings.target.info.tower) - 1 ) {
				changeRate();
			}
			//upgradeBttn.state = Button.NORMAL;
				//close()
		}
		
		public function onHelp(e:MouseEvent):void {
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
		
		public function timer():void
		{
			timerLabel.text = TimeConverter.timeToDays((settings.target.expire < App.time) ? 0 : (settings.target.expire - App.time));

		}
		
		override public function dispose():void {
			if (top100Bttn) top100Bttn.removeEventListener(MouseEvent.CLICK, onTop100);
			if (upgradeBttn) upgradeBttn.removeEventListener(MouseEvent.CLICK, onUpgrade);
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
				
			}
		}
		
		public function get canTakeMainReward():Boolean {
			if ((settings.target.expire < App.time || info.htype==1) && rateChecked > 0 && (Numbers.countProps(info.tower) - 1 == settings.target.upgrade) && settings.target.kicks >= settings.target.kicksMax && Happy.users.hasOwnProperty(App.user.id) && ( Happy.users[App.user.id].hasOwnProperty('take') || Happy.users[App.user.id]['take'] != 1))
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

		}
		
		public static var rateSended:Object = {};
		public function getRate(callback:Function = null):void 
		{
			//if (rateChecked > 0) return;
			rateChecked = App.time;
			
			onUpdateRate = callback;

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
import wins.Window;
import wins.BanksWindow;

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
			caption:	Locale.__e('flash:1382952379737'),
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
	private var sprite:LayerX;
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

import wins.ShopWindow;
internal class KickItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	private var count:uint;
	private var nodeID:String;
	private var type:uint;
	private var WIDTH:int;
	
	
	public function KickItem(obj:Object,_w:int, window:*) {
		WIDTH = _w;
		this.sID = obj.id;
		this.count = obj.k;			// obj.c;								//D
		this.nodeID = obj.id;
		this.item = App.data.storage[sID];
		this.window = window;
		type = obj.t;
		
		//bg = Window.backing(145, 190, 20, 'itemBacking');
		//addChild(bg);
		bg = new Bitmap(Window.textures.bubbleBackingBig);
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
		bttnText = Locale.__e('flash:1418826830156');                                          //D
		
		var bttnSettings:Object = {
			caption:bttnText,
			width:125,
			height:40,
			fontSize:22
		}
		
		if (type == 2) {
			bttnSettings['caption'] = Locale.__e('flash:1418826830156');
			bttnSettings['bgColor'] = [0x66b9f0, 0x567ace];
			bttnSettings['borderColor'] = [0xcce8fa, 0x4465b6];
			bttnSettings['bevelColor'] = [0xf8d8b5, 0x4465b6];
			bttnSettings['fontColor'] = 0xffffff;
			bttnSettings['fontBorderColor'] = 0x2b4a84;
			bttnSettings['fontCountColor'] = 0xffffff;
			bttnSettings['fontCountSize'] = 22;
			bttnSettings['fontCountBorder'] = 0x2b4a84;
			bttnSettings['price'] = price;
			bttnSettings['countText']	= item.price[Stock.FANT];
			bttnSettings['isMoneyBttn'] = true;
		}
		
		bttn = new Button(bttnSettings);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 25;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		addChild(bttn);
		//bttn.textLabel.y += 3;
		
		if (type == 2) {
			var icon:Bitmap = new Bitmap(UserInterface.textures.blueCristal, 'auto', true);
			icon.scaleX = icon.scaleY = 0.7;
			icon.x = 90;
			icon.y = 4;
			bttn.addChild(icon);
		}
		
		checkButtonsStatus();
	}
	
	public function checkButtonsStatus():void {
	
		if (window.info.htype!=1 && (window.settings.target.expire < App.time || window.settings.target.canUpgrade)) {			//D
			bttn.state = Button.DISABLED;
			return;
		}
		if (window.info.htype==1 && (window.settings.target.level >= window.settings.target.totalLevels)) {			//D
			bttn.state = Button.DISABLED;
			return;
		}
		
		if (type == 2) {
			/*if (App.user.stock.count(Stock.FANT) < price) {
				bttn.state = Button.DISABLED;
			}else {*/
				bttn.state = Button.NORMAL;
			//}
		}else if (type == 3) {
			if (App.user.stock.count(sID) < price) {
				//bttn.caption = Locale.__e('Вложить');									//D
				bttn.state = Button.NORMAL;
				
				//bttn.state = Button.DISABLED;
			}else {
				var bttnText:String;

				bttnText = Locale.__e('flash:1418826830156');
				bttn.state = Button.NORMAL;
				bttn.caption = bttnText;
			}
		}
		if(stockCount)
			stockCount.text = 'x' + App.user.stock.count(sID);
	}
	
	private function onClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) 
			return;
		
		if (currency == Stock.FANT && App.user.stock.count(Stock.FANT) < price) 
		{
			window.close();
			new BanksWindow({section:BanksWindow.REALS}).show();
			return;
		}
		
		if (type == 3 && App.user.stock.count(sID) < price && ShopWindow.findMaterialSource(sID))  
		{
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
		
		var title:TextField = Window.drawText(String(item.title) +'\n' + '+' + count, {
			color:0x7f3e14,
			borderColor:0xffffff,
			textAlign:"center",
			autoSize:"center",
			fontSize:26,
			textLeading:-6,
			multiline:true,
			distShadow:0
		});
		//title.wordWrap = true;
		title.width = bg.width - 10;
		title.height = title.textHeight;
		title.x = bg.x + (bg.width - title.width) / 2;
		title.y = -22;
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
internal class InfoWindow extends Window
{
	protected var descriptionLabel:TextField;
	public var descText:String;

	//override public var background:Bitmap = Window.backing2(490, 110, 44, 'storageMainBackingTop', 'stockBackingBot');
	public function InfoWindow(settings:Object = null)
	{
		if (settings == null) 
		{
			settings = new Object();
		}
		settings['background'] 		= 'alertBacking';
		settings['width'] 			= 800;
		settings['height'] 			= 620;
		settings['title'] 			= settings.title;
		settings['hasPaginator'] 	= false;
		settings['hasExit'] 		= true;
		settings['hasTitle'] 		= true;
		settings['faderClickable'] 	= true;
		settings['faderAlpha'] 		= 0.6;
		
		super(settings);
	}
	
	//override public function drawBackground():void {
		//var background:Bitmap = new Bitmap(Window.textures.gotoDream);
		//layer.addChild(background);
	//}
	
	private var itemCont:Sprite;
	private var topCont:Sprite;
	override public function drawBody():void {
		//drawDecorations();
		itemCont = new Sprite();
		topCont = new Sprite();
		
		
		var bttn:Button = new Button( {  
			width:194, 
			height:53, 
			caption:Locale.__e('flash:1382952380298') 
			} );
		bttn.x = (settings.width - bttn.width) / 2;
		bttn.y = settings.height - bttn.height - 50;
		bttn.addEventListener(MouseEvent.CLICK, close);
		
		exit.y = -25;
		exit.x = 8;
		
		
		var item:InfoWindowItem;
		for (var st:* in settings.st){
			item = new InfoWindowItem(settings.st[st].t, st,this);
			item.x = 130 * (st-1);
			itemCont.addChild(item);
		}
		
		var itemTop:InfoWindowItem;
		for (var top:* in settings.top.league.tbonus[1].t) {
			st++;	
			itemTop = new InfoWindowItem(settings.top.league.tbonus[1].t[top], settings.top.league.tbonus[1].e[top],this,true);
			itemTop.x = 135 * top;
			topCont.addChild(itemTop);
		}
		itemCont.x = (settings.width - itemCont.width) / 2;
		itemCont.y = 80;
		
		topCont.x = (settings.width - topCont.width) / 2;
		topCont.y = itemCont.y + itemCont.height + 10;

		bodyContainer.addChild(bttn);

		var descPrms:Object = {
			color			:0x7a471c,
			borderColor		:0xffffff,
			//width			:settings.width-100,
			multiline		:true,
			wrap			:true,
			textAlign		:'center',
			fontSize		:35
		}
		
		descriptionLabel = Window.drawText(Locale.__e('flash:1467792355007'), descPrms);
		descriptionLabel.width = settings.width - 100;
		descriptionLabel.x = (settings.width-descriptionLabel.width)/2;
		descriptionLabel.y = bodyContainer.y + 30;
		bodyContainer.addChild(descriptionLabel);
		
		
		
		bodyContainer.addChild(itemCont);
		bodyContainer.addChild(topCont);
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
				color			:0xffffff,
				borderColor		:0x7b441b,
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
		background = Window.backing(135, 210, 40, "itemBacking");
		addChildAt(background,0);
	}
}