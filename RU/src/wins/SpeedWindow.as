package wins {
	
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import ui.BoostTool;
	
	public class SpeedWindow extends Window {
		
		private var progressBar:ProgressBar;
		
		private var finishTime:int;
		private var leftTime:int;
		
		private var isBoost:Boolean;
		
		private var timer:TextField;
		
		public var boostBttn:MoneyButton;
		public var moveBttn:Button;
		
		private var totalTime:int;
		
		private var priceSpeed:int = 0;
		private var priceBttn:int = 0;
		
		public var noBoostJson:Object;
		public var noBoostArray:Array;
		
		public function SpeedWindow(settings:Object = null) {
			settings["width"] = 550;
			settings["height"] = 290;
			settings["fontSize"] = 48;
			settings["hasPaginator"] = false;
			
			if (settings.hasOwnProperty('hasBoost')) {
				settings["hasBoost"] = settings.hasBoost;	
			} else {
				settings["hasBoost"] = true;		
			}
			
			if (settings.hasOwnProperty('picture')) 
			{
				settings["width"] = 770;
				settings["height"] = 600;
				settings["fontSize"] = 38;
				settings['picture'] = settings.picture;
			}
			
			finishTime = settings.finishTime;
			totalTime = settings.totalTime;
			
			super(settings);
			
			priceSpeed = settings.priceSpeed || settings.info.speedup || settings.info.skip;
		}
		
		public function progress():void {
			//leftTime = 0;
			leftTime = finishTime - App.time;
			
			if (leftTime <= 0) {
				leftTime = 0;
				App.self.setOffTimer(progress);
				close();
			}
			
			timer.text = TimeConverter.timeToStr(leftTime);
			var percent:Number = Number(totalTime - leftTime) / totalTime;
			progressBar.progress = percent;
			
			if (App.user.quests.tutorial)
				return;
			
			if (boostBttn && priceBttn != priceSpeed && priceSpeed != 0) {
				priceBttn = priceSpeed;
				boostBttn.count = String(priceSpeed);
			}
		}
		
		override public function drawBackground():void {
			var glowIng:Bitmap = new Bitmap(Window.textures.dailyBonusItemGlow);
			glowIng.scaleX = glowIng.scaleY = 2;
			glowIng.y -= glowIng.height / 2;
			glowIng.x = (settings.width - glowIng.width) / 2;
			glowIng.smoothing = true;
			layer.addChild(glowIng);
			background = backing(settings.width, settings.height, 90, "paperWithBacking");
			layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		public function get canBoost():Boolean {
			var itm:Object = App.data.storage[settings.target.sid];
			return (itm.hasOwnProperty('mboost') && itm.mboost != "" &&!isNaN(itm.mboost))
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xfce97d,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: 2,	
				
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -16;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			//titleLabel.filters = [/*new GlowFilter(0xffffff, 1, 4, 4, 10, 2, false, false),*/ new DropShadowFilter(3.0, 90, 0x713f15, 0.5, 0, 0, 1.0, 3, false, false, false)];
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		private var iconTarget:Bitmap = new Bitmap();
		private var background:Bitmap;
		override public function drawBody():void {
			titleLabel.y += 4;
			
			var btmd:BitmapData;
			
			var itm:Object = App.data.storage[settings.target.sid];
			Load.loading(Config.getIcon(itm.type, itm.preview), onPreviewComplete);
			
			bodyContainer.addChildAt(iconTarget, 0);
			
			var progressBacking:Bitmap = Window.backingShort(433, "backingOne");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = 124;//settings.height - progressBacking.height - 72;
			//progressBacking.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 0, 0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(progressBacking);
			
			drawMirrowObjs('decSeaweed', background.x + settings.width + 56, background.x - 56, background.y + settings.height - 174, true, true);
			
			var star2:Bitmap = new Bitmap(Window.textures.decStarBlue);
			bodyContainer.addChild(star2);
			star2.scaleX = -1;
			star2.y = -56;
			star2.rotation = -20;
			star2.x = star2.width - 18;
			star2.smoothing = true;
			
			var star1:Bitmap = new Bitmap(Window.textures.decStarYellow);
			bodyContainer.addChild(star1);
			star1.x = star2.x + 15;
			star1.y = star2.y + 8;
			star1.rotation = 5;
			star1.smoothing = true;
			
			var someCrab:Bitmap = new Bitmap(Window.textures.clearCrab);
			bodyContainer.addChild(someCrab);
			someCrab.x = 5;
			someCrab.y = settings.height - someCrab.height - 32;
			someCrab.filters = [new DropShadowFilter(6.0, 90, 0, 0.5, 6, 6, 1.0, 3, false, false, false)];
			
			progressBar = new ProgressBar( { win:this, width:progressBacking.width - 0, isTimer:false, scale:.95, typeLine: 'sliderOne'});
			//progress();
			progressBar.x = progressBacking.x - 17;
			progressBar.y = progressBacking.y - 13;
			progressBar.visible = false;
			
			bodyContainer.addChild(progressBar);
			
			progressBar.visible = true;
			
			/*var separator:Bitmap = Window.backingShort(230, 'divider', false);
			separator.alpha = 0.8;
			bodyContainer.addChild(separator);
			separator.x = 30;
			separator.y = 40;
			
			var separator2:Bitmap = Window.backingShort(230, 'divider', false);
			separator2.alpha = 0.8;
			separator2.scaleX = -1;
			bodyContainer.addChild(separator2);
			separator2.x = 460;
			separator2.y = 40;*/
			
			timer = Window.drawText(TimeConverter.timeToStr(127), {
				color:			0xffe44f,
				borderColor:	0x8d6021,
				borderSize:		2,
				fontSize:		48
			});
			
			bodyContainer.addChild(timer);
			timer.y = 50;
			
			timer.height = timer.textHeight;
			timer.width = timer.textWidth + 10;
			timer.x = (settings.width - timer.width) / 2;
			timer.filters = [new DropShadowFilter(4.0, 90, 0x713f15, 0.8, 1.0, 1.0, 1.0, 3, false, false, false), new GlowFilter(0x8d6021, .7, 4, 4, 4)];
			
			var timerBacking:Bitmap = Window.backingShort(timer.width + 100, 'backingGrad', true);
			timerBacking.scaleY = 1.4;
				
			timerBacking.alpha = .7;
			timerBacking.smoothing = true;
			timerBacking.x = timer.x + (timer.width - timerBacking.width) / 2 + 0;
			timerBacking.y = timer.y + (timer.height - timerBacking.height) / 2 + 0;
			bodyContainer.addChild(timerBacking);
			bodyContainer.swapChildren(timer, timerBacking);
			
			progress();
			App.self.setOnTimer(progress);
			progressBar.start();
			
			if (App.user.quests.tutorial) {
				priceSpeed = 0;
			}
			
			boostBttn = new MoneyButton( {
				caption: Locale.__e("flash:1382952380104"),
				countText:String(priceSpeed),
				width:192,
				height:56,
				fontSize:(App.lang == 'de') ? 28 : 32,
				fontCountSize:32,
				radius:26,
				
				/*bgColor:[0xa8f84a, 0x73bb16],
				borderColor:[0xffffff, 0xffffff],
				bevelColor:[0xcefc97, 0x5f9c11],	
				
				fontColor:0xffffff,			
				fontBorderColor:0x2b784f,
				
				fontCountColor:0xffffff,				
				fontCountBorder:0x2b784f,*/
				iconScale:0.8
			});
			
			noBoostJson = JSON.parse(App.data.options.noBoost);
			noBoostArray = noBoostJson.sid;
			
			if (noBoostArray.indexOf(settings.target.sid) != -1) {
				boostBttn.visible = false;
			}else 
			{
				boostBttn.visible = true;
			}
			
			//boostBttn.visible = ((settings.target.sid != '798' ) && (settings.target.sid != '1925') && (settings.target.sid != '1923') && (settings.target.sid != '1858') && (settings.target.sid != '1859') && (settings.target.sid != '1866') && (settings.target.sid != '1775') && (settings.target.sid != '439') && (settings.target.sid != '1617') &&(settings.target.sid != '1606') && (settings.target.sid != '996') && (settings.target.sid != '1291') && (settings.target.sid != '1290') && (settings.target.sid != '1289') && (settings.target.sid != '1288'));
			bodyContainer.addChild(boostBttn);
			boostBttn.x = (settings.width - boostBttn.width)/2;
			boostBttn.y = settings.height - boostBttn.height - 18;
			boostBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			boostBttn.countLabel.width = boostBttn.countLabel.textWidth + 5;
			
			if (settings.hasOwnProperty('moveTo') && User.inExpedition) {
				moveBttn = new Button( {
					caption: Locale.__e("flash:1434377492145"),
					width:192,
					height:56,
					fontSize:32,
					fontCountSize:32,
					radius:26,
					
					/*bgColor:[0xa8f84a, 0x73bb16],
					borderColor:[0xffffff, 0xffffff],
					bevelColor:[0xcefc97, 0x5f9c11],	
					
					fontColor:0xffffff,			
					fontBorderColor:0x2b784f,
					
					fontCountColor:0xffffff,				
					fontCountBorder:0x2b784f,*/
					iconScale:0.8
				});
				moveBttn.x = (settings.width - moveBttn.width)/2;
				moveBttn.y = settings.height - moveBttn.height - 10 + 60;
				bodyContainer.addChild(moveBttn);
				moveBttn.addEventListener(MouseEvent.CLICK, onMoveEvent);
			}
			
			if (!settings.hasBoost) {
				boostBttn.visible = false;
				
			}
			boostBttn.addEventListener(MouseEvent.CLICK, onBoostEvent);
			
			if (canBoost) {
				var bt:BoostTool = new BoostTool(int(settings.target.sid), mBoost)
				bt.x = boostBttn.x + boostBttn.width + 150;
				bt.y = boostBttn.y - 125;
				//bodyContainer.addChild(bt);
			}
		}
		
		protected function onMoveEvent(e:MouseEvent):void 
		{
			moveBttn.state = Button.DISABLED;
			close()
			settings.moveTo();
			
		}
		
		public function onPreviewComplete(data:Bitmap):void {
			iconTarget.bitmapData = data.bitmapData;
			iconTarget.smoothing = true;
			
			Size.size(iconTarget, 150, 150);
			
			iconTarget.x = (settings.width - iconTarget.width) / 2;
			iconTarget.y = (27 - iconTarget.height);
		}
		
		protected function onBoostEvent(e:MouseEvent = null):void {
			if (settings.doBoost)
				settings.doBoost(priceSpeed);
			else
				settings.target.acselereatEvent(priceBttn);
			close();
		}
		
		override public function dispose():void {
			if(progressBar)progressBar.dispose();
			progressBar = null;
			if(boostBttn)boostBttn.removeEventListener(MouseEvent.CLICK, onBoostEvent);
			boostBttn = null;
			App.self.setOffTimer(progress);
			super.dispose();
		}
		
		public function mBoost(onComplete:Function = null):void 
		{
			var mBoost:int;
			if (settings.target.info.hasOwnProperty('mboost') && !isNaN(settings.target.info.mboost)) {
				mBoost = settings.target.info.mboost;
			}else {
				new SimpleWindow({text:'Нельзя ускорить',popup:true}).show();
				return;
			}
			if (App.user.stock.count(mBoost)) {
				var pstParams:Object = {
					ctr:settings.target.info.type,
					act:'mboost',
					uID:App.user.id,
					id:settings.target.id,
					wID:App.user.worldID,
					sID:settings.target.sid
				}
				Post.send(pstParams,mBoostComplete,{completeCallback:onComplete,boostedSid:mBoost});
			}else {
				if(onComplete != null)
					onComplete();
				//ShopWindow.findMaterialSource(mBoost)
				new SimpleWindow({text:Locale.__e('flash:1445780031642'),popup:true}).show();
				return;
			}
		}

		public function mBoostComplete(error:*, data:*, params:*):void {
			if (params.hasOwnProperty('boostedSid') && params.boostedSid) {
				var takeObj:Object = { };
				takeObj[params.boostedSid] = 1;
				App.user.stock.takeAll(takeObj);
			}
			if (params.hasOwnProperty('completeCallback') && params.completeCallback != null) {
				params.completeCallback();
			}
			
			if (error) {
				Errors.show(error, data);
				return;
			}
			finishTime = data.crafted;
			settings.target.began = data.crafted - App.time;
			settings.target.crafted = data.crafted;
			for each(var q:* in settings.target.queue) {
				q.crafted = data.crafted;
			}
		}
	}
}