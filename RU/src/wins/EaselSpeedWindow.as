package wins {
	
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	public class EaselSpeedWindow extends SpeedWindow {
		
		private var progressBar:ProgressBar;
		private var finishTime:int;
		private var leftTime:int;
		private var isBoost:Boolean;
		private var timer:TextField;
		private var totalTime:int;
		private var priceSpeed:int = 0;
		private var priceBttn:int = 0;
		private var iconTarget:Bitmap = new Bitmap();
		private var background:Bitmap;
		private var maska:Shape = new Shape();
		private var imageSprite:LayerX = new LayerX();
		
		public function EaselSpeedWindow(settings:Object = null)
		{
			
			if (settings.hasOwnProperty('hasBoost')) 
			{
				settings["hasBoost"] = settings.hasBoost;
			} else {
				settings["hasBoost"] = true;
			}
			settings['exitTexture'] = 'closeBttnMetal';

			
			finishTime = settings.finishTime;
			totalTime = settings.totalTime;
			
			super(settings);
			
			settings["hasPaginator"] = false;
			settings['picture'] = settings.picture;
			
			priceSpeed = settings.priceSpeed || settings.info.speedup || settings.info.skip;
		}
		
		override public function progress():void 
		{
			leftTime = finishTime - App.time;
			
			if (leftTime <= 0) 
			{
				leftTime = 0;
				App.self.setOffTimer(progress);
				close();
			}
			
			timer.text = TimeConverter.timeToStr(leftTime);
			var percent:Number = (totalTime - leftTime) / totalTime;
			progressBar.progress = percent;
			
			if (App.user.quests.tutorial)
				return;
			
			if (boostBttn && priceBttn != priceSpeed && priceSpeed != 0) 
			{
				priceBttn = priceSpeed;
				boostBttn.count = String(priceSpeed);
			}
		}
		
		private	var background2:Bitmap;
		override public function drawBackground():void 
		{
			background = backing(settings.width, settings.height, 50, 'capsuleWindowBacking');
			layer.addChild(background);
			
			background2 = backing2(670, 400 , 45, 'calImgUp', 'calImgBot');
			background2.x = (settings.width - background2.width) / 2;
			background2.y = 10;
			bodyContainer.addChild(background2);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: true,
				wordWrap			: true,
				fontSize			: 45,
				textLeading	 		: settings.textLeading,
				borderColor 		: settings.fontBorderColor,
				borderSize 			: settings.fontBorderSize,
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: 350,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: false
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void
		{
			titleLabel.y = -14;
			
			var btmd:BitmapData;
			
			//var itm:Object = App.data.storage[settings.target.sid];
			//Load.loading(Config.getIcon(itm.type, itm.preview), onPreviewComplete);
			
			//bodyContainer.addChildAt(iconTarget, 0);
			
			var progressBacking:Bitmap = Window.backingShort(433, "backingOne");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = 485;//settings.height - progressBacking.height - 72;
			//progressBacking.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 0, 0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(progressBacking);
			
			drawMirrowObjs('decSeaweed', background.x + settings.width + 56, background.x - 56, background.y + settings.height - 206, true, true);
			
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
			
			timer = Window.drawText(TimeConverter.timeToStr(127), {
				color:			0xffe44f,
				borderColor:	0x8d6021,
				borderSize:		2,
				fontSize:		48
			});
			
			bodyContainer.addChild(timer);
			timer.y = 420;
			
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
			
			var image:Bitmap = new Bitmap();
			imageSprite.addChild(image);
			imageSprite.addChild(maska);
			bodyContainer.addChild(imageSprite);
			
			imageSprite.x = background2.x - 2;
			imageSprite.y = background2.y;
			
			imageSprite.tip = function():Object {
				return {
					title:settings.info.title,
					text:settings.info.description
				}
			}
			
			Load.loading(settings.picture, function(data:*):void {
				image.bitmapData = data.bitmapData;
				
				maska.graphics.beginFill(0xFFFFFF, 1);
				maska.graphics.drawRoundRect(0, 0, image.width - 9, image.height - 6, 40, 40);
				maska.graphics.endFill();
				
				image.mask = maska;
			
				//image.x = background2.x + (background2.width - image.width) / 2;
				//image.y = background2.y + (background2.height - image.height) / 2 - 1;
				maska.x = image.x + (image.width - maska.width) / 2;
				maska.y = image.y + (image.height - maska.height) / 2;
				
				//image.alpha = .3;
				//timer.y = image.y + image.height + 20;
				//progressBacking.y = timer.y + timer.height + 3;
				//progressBar.y = progressBacking.y - 7;
				
				//boostBttn.y -= 50;
			});
		}
		
		override public function onPreviewComplete(data:Bitmap):void 
		{
			
		}
	}
}