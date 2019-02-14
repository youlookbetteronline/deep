package {
	import com.adobe.images.BitString;
	import com.greensock.TweenMax;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.*
	import flash.external.ExternalInterface;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.SecurityDomain;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;	
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.display.*;
	import flash.geom.*
	import flash.utils.setTimeout;
	
	[SWF ( width="1600", height="700", backgroundColor="#031021", allowsFullScreen = true) ]
	//[SWF ( width="900", height="700", backgroundColor="#031021", allowsFullScreen = true) ]
	
	public class  MainPreloader extends Sprite
	{
		[Embed(source="fonts/BRUSH-N.TTF",  fontName = "font", unicodeRange ='U+0020-U+0040', mimeType = "application/x-font-truetype", fontWeight="normal", fontStyle="normal", advancedAntiAliasing="true", embedAsCFF="false")]
		private static var font:Class;	
		
		[Embed(source="../bin/star.png")]
		public var StarCl:Class;
		public var star:BitmapData = new StarCl().bitmapData;
		
		[Embed(source="glass.png")]
		public var Glass:Class; 
		public var glass:BitmapData = new Glass().bitmapData;
		
		[Embed(source="roll.png")]
		public var Roll:Class; 
		public var roll:BitmapData = new Roll().bitmapData;
		
		[Embed(source="rollBubbles.png")]
		public var RollBubbles:Class; 
		public var rollBubbles:BitmapData = new RollBubbles().bitmapData;
		
		[Embed(source="rollBacking.png")]
		public var RollBacking:Class; 
		public var rollBacking:BitmapData = new RollBacking().bitmapData;
		
		[Embed(source="cloudLeft.png")]
		public var CloudLeft:Class; 
		public var cloudLeft:BitmapData = new CloudLeft().bitmapData;
		
		[Embed(source="cloudRight.png")]
		public var CloudRight:Class; 
		public var cloudRight:BitmapData = new CloudRight().bitmapData;
		
		[Embed(source="CenterCloudLeft.png")]
		public var CenterCloudLeft:Class; 
		public var centerCloudLeft:BitmapData = new CenterCloudLeft().bitmapData;
		
		[Embed(source="CenterCloudRight.png")]
		public var CenterCloudRight:Class; 
		public var centerCloudRight:BitmapData = new CenterCloudRight().bitmapData;
		
		[Embed(source="MainLogoFB.png")]
		public var MainLogo:Class; 
		public var mainLogo:BitmapData = new MainLogo().bitmapData;
		
		[Embed(source="Eye.png")]
		public var Eye:Class; 
		public var eye:BitmapData = new Eye().bitmapData;
		
		[Embed(source="EyeBack.png")]
		public var EyeBack:Class; 
		public var eyeBack:BitmapData = new EyeBack().bitmapData;
		
		[Embed(source="EyeClose.png")]
		public var EyeClose:Class; 
		public var eyeClose:BitmapData = new EyeClose().bitmapData;
		
		[Embed(source="logoNet.png")]
		public var LogoNet:Class; 
		public var logoNet:BitmapData = new LogoNet().bitmapData;
		
		[Embed(source="logo.png")]
		public var Logo:Class; 
		public var logo:BitmapData = new Logo().bitmapData;
	
		[Embed(source="start_screen_2.jpg")]
		public var Screen:Class; 
		public var screen:BitmapData = new Screen().bitmapData;
		
		Security.allowDomain("*");
        Security.allowInsecureDomain("*");
		
		public static var progressModel1:Object = {
			"game"	:[0, 0.5],
			"wins"	:[0.5, 0.85],
			//"ui"	:[0.7, 0.85],
			"map"	:[0.85, 1]
		}
		
		public static var PROGRESS:Object = progressModel1;
		
		public var bg:Bitmap;
		public var bar:Bitmap;
		public var barB:Bitmap;
		public var barBack:Bitmap;
		public var mEye:Bitmap;
		public var mainLogoDeep:Bitmap;
		public var mainLogoNet:Bitmap;
		public var keys:Keyboard;
		public var maskaGlow:Sprite;
		public var maska:Sprite;
		public var maskaB:Shape;
		//public var glower:Bitmap;
		public var glasser:Bitmap;
		public var countProgress:TextField;
		public var textHelp:TextField;
		public var viewImage:Sprite;
		public var cloudsSprite:Sprite;
		public var viewImageNew:Sprite;
		public var barSprite:Sprite = new Sprite();
		public var eyeSprite:Sprite = new Sprite();
		
		private var loopBias:int;
		private var loopTimeout:int;
		private var pTimer:Timer;
		private var lCloud:Bitmap;
		private var rCloud:Bitmap;
		private var bTween:TweenMax;
		private var lTween:TweenLite;
		private var rTween:TweenLite;
		private var parallaxBmaps:Vector.<*> = new Vector.<*>();
		private var parallaxObjects:Vector.<Object> = new Vector.<Object>();
		private var parallaxCoords:Vector.<Object> = new Vector.<Object>();
		
		public function MainPreloader()
		{
			Font.registerFont(font);
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler, false, 0, true);
		}
		
		
		private function addedToStageHandler(e:Event=null):void
		{	
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
    		stage.addEventListener(MouseEvent.MOUSE_MOVE, cloudsParallax)
			
			stage.scaleMode 	= StageScaleMode.NO_SCALE;
			stage.align 		= StageAlign.TOP_LEFT;
			
			mainLogoDeep = new Bitmap(mainLogo);
			mainLogoNet = new Bitmap(logoNet);
			barBack = new Bitmap(rollBacking);
			bg = new Bitmap(screen);
			bar = new Bitmap(roll);
			barB = new Bitmap(new BitmapData(rollBubbles.width * 2, rollBubbles.height, true, 0));
			barB.bitmapData.draw(rollBubbles);
			barB.bitmapData.draw(rollBubbles, new Matrix(1, 0, 0, 1, rollBubbles.width));
			//fish = new Bitmap(glow);
			addChild(bg);
			bg.x = (stage.stageWidth - bg.width) / 2;
			bg.y = (stage.stageHeight - bg.height) / 2;
			
			mainLogoDeep.x = (stage.stageWidth - mainLogoDeep.width) / 2;
			mainLogoDeep.y = stage.stageHeight - mainLogoDeep.height - 240;
			
			mainLogoNet.x = mainLogoDeep.x + 460;
			mainLogoNet.y = mainLogoDeep.y + 30;
			
			addParalaxClouds();
			
			if (stage.stageWidth < bg.width)
				drawSides();
				
			addChild(barBack);
			addTweenClouds();
			
			addChild(mainLogoDeep);
			
			drawEye();
			
			addChild(mainLogoNet);
			addChild(bar);
			addChild(barB);
			
			barBack.x = (stage.stageWidth - barBack.width) / 2;
			barBack.y = stage.stageHeight - barBack.height - 30;
			
			bar.x = barBack.x + (barBack.width - bar.width) / 2;
			bar.y = barBack.y + (barBack.height - bar.height) / 2;
			bar.cacheAsBitmap = true;
			
			barB.x = bar.x;
			barB.y = bar.y;
			barB.cacheAsBitmap = true;
			
			maska = new Sprite();
			maska.graphics.beginFill(0,1);
			maska.graphics.drawRect(0, 0, 1, bar.height+1);
			maska.graphics.endFill();
			maska.cacheAsBitmap = true;
			addChild(maska);
			
			maska.x = bar.x - 8;
			maska.y = bar.y;
			bar.mask = maska;
			
			maskaB = new Shape();
			maskaB.graphics.beginFill(0x000000);
			maskaB.graphics.drawRect(0, 0, 1, bar.height+1);
			maskaB.graphics.endFill();
			maskaB.x = barB.x + 8;
			maskaB.y = barB.y;
			maskaB.cacheAsBitmap = true;
			addChild(maskaB);
			barB.mask = maskaB;
			
			stage.addEventListener(Event.ENTER_FRAME, moveBubbles);
			/*glower = new Bitmap(glow);
			addChild(glower);
			glower.x = maska.x - 5;
			glower.y = maska.y - 2 + (maska.height - glower.height) / 2;
			
			glower.visible = false;
			
			maskaGlow = new Sprite();
			maskaGlow.graphics.beginFill(0x000000);
			maskaGlow.graphics.drawRoundRect(bar.x, bar.y, bar.width, bar.height, 30, 30);
			maskaGlow.graphics.endFill();
			maskaGlow.filters = [new BlurFilter(4, 4)];
			maskaGlow.cacheAsBitmap = true;
			glower.cacheAsBitmap = true;
			glower.mask = maskaGlow;
			
			addChild(maskaGlow);*/
			
			glasser = new Bitmap(glass);
			addChild(glasser);
			glasser.x = barBack.x + (barBack.width - glasser.width) / 2;
			glasser.y = barBack.y - 2 + (barBack.height - glasser.height) / 2;
			
			var format:TextFormat = new TextFormat();
			format.font = "font";
			format.size = 28;
			format.color = 0xfff9cb;
			format.align = TextFormatAlign.CENTER;
			
			countProgress = new TextField();
			countProgress.embedFonts = true;
			countProgress.defaultTextFormat = format;
			countProgress.setTextFormat(format);
			countProgress.textColor = 0xffffff;
			var filter:GlowFilter = new GlowFilter(0x366a0d, 1, 3, 3, 6, 1);
			var shadowFilter:DropShadowFilter = new DropShadowFilter(2, 90, 0x366a0d, 1, 1, 1, 1, 1); 
			countProgress.filters = [filter, shadowFilter];
			
			addChild(countProgress);
			countProgress.text = "";
			countProgress.width = 300;
			countProgress.x = barBack.x + (barBack.width - countProgress.width)/2;
			countProgress.y = barBack.y + 1;
			countProgress.mouseEnabled = false;
			
			//timerHandler();
			//progress('game', 1)//0.02);
			//libsProgress('wins', 1);
			//libsProgress('map', 1);
			//addStars();
			
			var _logo:Bitmap = new Bitmap(logo);
			addChild(_logo);
			_logo.x = stage.stage.stageWidth -_logo.width - 13;
			_logo.y = stage.stage.stageHeight -_logo.height - 13;
		}
		
		private function moveBubbles(e:*):void
		{
			barB.x --;
			if(barB.x < bar.x - barB.width / 2)
				barB.x = bar.x;
		}
		private function drawEye():void
		{
			var _eyeCoords:Object = {x:mainLogoDeep.x + 310, y:mainLogoDeep.y + 80};
			var coords:Object = {};
			
			var matrix:Matrix = new Matrix(); 
			matrix.createGradientBox(27, 30, Math.PI / 2);
			var alpha:Number = 0.9;
			var bgEye:Bitmap = new Bitmap(eyeBack);
			
			bgEye.x = _eyeCoords.x + 2;
			bgEye.y = _eyeCoords.y;
			addChild(bgEye);
				
			var aEye:Shape = new Shape();
			aEye.graphics.beginFill(0, 1);
			aEye.graphics.drawRoundRect(0, 0, 5, 12, 8);
			aEye.graphics.endFill();
			aEye.filters = [new BlurFilter(2, 2, 1)];
			aEye.rotation = 15;
			aEye.x = _eyeCoords.x + 9;
			aEye.y = _eyeCoords.y + 5;
			addChild(aEye);
			
			parallaxBmaps.push(aEye);
			var _eTween:TweenLite;
			parallaxObjects.push({x:aEye.x, y:aEye.y, width:aEye.width, bias:10, tween:_eTween});
			coords = {x:aEye.x, y:aEye.y};
			parallaxCoords.push(coords);
			
			var eyeBlick:Shape = new Shape();
			eyeBlick.graphics.beginFill(0xffffff, 1);
			eyeBlick.graphics.drawEllipse(0, 0, 6, 4);
			eyeBlick.graphics.endFill();
			eyeBlick.filters = [new BlurFilter(4, 4, 1)];
			eyeBlick.x = _eyeCoords.x + 12;
			eyeBlick.y = _eyeCoords.y + 7;
			addChild(eyeBlick);
			
			parallaxBmaps.push(eyeBlick);
			var _beTween:TweenLite;
			parallaxObjects.push({x:eyeBlick.x, y:eyeBlick.y, width:eyeBlick.width, bias:6, tween:_beTween});
			coords = {x:eyeBlick.x, y:eyeBlick.y};
			parallaxCoords.push(coords);
			
			mEye = new Bitmap(eye);
			mEye.x = _eyeCoords.x + 2;
			mEye.y = _eyeCoords.y + 0;
			addChild(mEye);
			cloudsParallax();
			updatePositions();
			
		}
		
		private function loopEye():void{
			mEye.bitmapData = eyeClose;
			clearTimeout(loopTimeout);
			loopTimeout = setTimeout(function():void{
				mEye.bitmapData = eye;
			},300)
		}
		
		private function addTweenClouds():void
		{
			lCloud = new Bitmap(centerCloudLeft);
			lCloud.x = mainLogoDeep.x - 30;
			lCloud.y = mainLogoDeep.y - 20;
			addChild(lCloud);
			setTimeout(alphaLeft, 500);
			
			rCloud = new Bitmap(centerCloudLeft);
			rCloud.x = mainLogoDeep.x + 200;
			rCloud.y = mainLogoDeep.y + 75;
			addChild(rCloud);
			alphaRight();
		}
		
		private function alphaLeft():void
		{
			if(lTween){
				lTween.kill();
				lTween = null;
			}
			var _alpha:Number = .7;
			if (lCloud.alpha > .3)
				_alpha = .3;
			lTween = TweenLite.to(lCloud, 2, {alpha:_alpha, onComplete:alphaLeft});
		}
		
		private function alphaRight():void{
			if(rTween){
				rTween.kill();
				rTween = null;
			}
			var _alpha:Number = 1;
			if (rCloud.alpha > .5)
				_alpha = .5;
			rTween = TweenLite.to(rCloud, 2, {alpha:_alpha, onComplete:alphaRight});
		}
		private function addParalaxClouds():void
		{
			var cloudsMask:Shape = new Shape();
			cloudsMask.graphics.beginFill(0xffffff);
			cloudsMask.graphics.drawRect(bg.x + 30, bg.y, bg.width - 60, bg.height);
			cloudsMask.graphics.endFill();
			cloudsMask.filters = [new BlurFilter(60, 0, 1)];
			cloudsMask.cacheAsBitmap = true;
			
			cloudsSprite = new Sprite();
			addChild(cloudsSprite);
			addChild(cloudsMask);
			cloudsSprite.cacheAsBitmap = true;
			cloudsSprite.mask = cloudsMask;
			
			pTimer = new Timer(10, 0);
			pTimer.start();
			pTimer.addEventListener(TimerEvent.TIMER, updatePositions);
				
			var coords:Object = {};
			var _leftCloud:Bitmap = new Bitmap(cloudLeft);
			_leftCloud.x = bg.x-30;
			_leftCloud.y = stage.stageHeight - _leftCloud.height - 30;
			cloudsSprite.addChild(_leftCloud);
			parallaxBmaps.push(_leftCloud);
			var _lTween:TweenLite;
			parallaxObjects.push({x:_leftCloud.x, y:_leftCloud.y, width:_leftCloud.width, bias:40, tween:_lTween});
			coords = {x:_leftCloud.x, y:_leftCloud.y};
			parallaxCoords.push(coords);
			
			var _rightCloud:Bitmap = new Bitmap(cloudRight);
			_rightCloud.x = bg.x + bg.width - _rightCloud.width + 30;
			_rightCloud.y = stage.stageHeight - _rightCloud.height - 35;
			cloudsSprite.addChild(_rightCloud);
			parallaxBmaps.push(_rightCloud);
			var _rTween:TweenLite;
			parallaxObjects.push({x:_rightCloud.x, y:_rightCloud.y, width:_rightCloud.width, bias:40, tween:_rTween});
			coords = {x:_rightCloud.x, y:_rightCloud.y};
			parallaxCoords.push(coords);
			cloudsParallax();
		}
		
		private function updatePositions(e:* = null):void
		{
			for (var i:* in parallaxBmaps) 
			{
				if (parallaxObjects[i].tween)
				{
					parallaxObjects[i].tween.kill();
					parallaxObjects[i].tween = null;
				}
				if (Math.abs(parallaxBmaps[i].x - parallaxObjects[i].x) > .5 || Math.abs(parallaxBmaps[i].y - parallaxObjects[i].y) > .5)
				{
					var _bias:int = int(Math.abs(parallaxBmaps[i].x - parallaxObjects[i].x) + Math.abs(parallaxBmaps[i].y - parallaxObjects[i].y));
					var _time:Number = (_bias + 1) / 20;
					if(i == 2){
						loopBias += Math.abs(parallaxObjects[i].x - parallaxBmaps[i].x) + Math.abs(parallaxObjects[i].y - parallaxBmaps[i].y);
						trace(loopBias);
						if (loopBias > 250){
							loopBias = 0;
							loopEye();
						}
					}
					parallaxObjects[i].tween = new TweenLite(parallaxBmaps[i], _time, {x:(parallaxObjects[i].x), y:(parallaxObjects[i].y)});
				}
			}
		}
		
		private function cloudsParallax(e:* = null):void
		{
			if (parallaxObjects.length == 0)
				return;
			var bias:Number = 40;
			for (var i:* in parallaxObjects) 
			{
				if (parallaxObjects[i].x + parallaxObjects[i].width/2 < stage.stageWidth/2){
					parallaxObjects[i].x = int((parallaxCoords[i].x) - (parallaxObjects[i].bias / 2 + parallaxObjects[i].bias * (mouseX / stage.stageWidth)*-1));
				}else{
					parallaxObjects[i].x = int((parallaxCoords[i].x) + (parallaxObjects[i].bias / 2 + parallaxObjects[i].bias * (mouseX / stage.stageWidth)));
				}
				parallaxObjects[i].y = int((parallaxCoords[i].y) + (parallaxObjects[i].bias / 4 + (parallaxObjects[i].bias/2) * (mouseY / stage.stageHeight)));
			}
		}
		
		private function drawSides():void {
			var leftShape:Shape = new Shape();
			leftShape.graphics.beginFill(0x031021, 1);
			leftShape.graphics.drawRect( -50, 0, 80, stage.stageHeight);
			leftShape.graphics.endFill();
			leftShape.filters = [new BlurFilter(60, 0)];
			addChild(leftShape);
			
			var rightShape:Shape = new Shape();
			rightShape.graphics.beginFill(0x031021, 1);
			rightShape.graphics.drawRect( stage.stageWidth - 30, 0, 80, stage.stageHeight);
			rightShape.graphics.endFill();
			rightShape.filters = [new BlurFilter(60, 0)];
			addChild(rightShape);
		}
		
		public function progress(type:String, _progress:Number = 1):void
		{
			var _width:int = int((PROGRESS[type][1] * bar.width) * _progress);
			maska.width = _width + 16;
			maska.filters = [new BlurFilter(8, 0)];
			maska.cacheAsBitmap  = true;
			
			maskaB.width = _width - 6;
			maskaB.filters = [new BlurFilter(10, 0)];
			maskaB.cacheAsBitmap  = true;
			
			var nn:Number = int((PROGRESS[type][1] - PROGRESS[type][0]) * 100) / 100;
			var vv:Number = nn * _progress;
			
			var _value:int = int((PROGRESS[type][0] + vv) * 100);
			if (countProgress.text != '50%' && _value == 50)
				loopEye();
			countProgress.text = String(_value) + "%";
		}
		
		public function libsProgress(type:String, _progress:Number):void
		{
			var value:Number = (PROGRESS[type][1] - PROGRESS[type][0]) * _progress;
			value = value + PROGRESS[type][0];
			
			var _width:int = int(value * bar.width);
			maska.width = _width + 16;
			maska.filters = [new BlurFilter(8, 0)];
			maska.cacheAsBitmap  = true;
			
			maskaB.width = _width - 6;
			maskaB.filters = [new BlurFilter(10, 0)];
			maskaB.cacheAsBitmap  = true;
			
			var nn:Number = int((PROGRESS[type][1] - PROGRESS[type][0]) * 100) / 100;
			var vv:Number = nn * _progress;
			var _value:int = int((PROGRESS[type][0] + vv) * 100);
			if (countProgress.text != '85%' && _value == 85)
				loopEye();
			countProgress.text = String(_value) + "%";
		}
		
		public function dispose():void
		{
			stage.removeEventListener(Event.ENTER_FRAME, moveBubbles);
			if(bTween){
				bTween.kill();
				bTween = null;
			}
			if(lTween){
				lTween.kill();
				lTween = null;
			}
			if(rTween){
				rTween.kill();
				rTween = null;
			}
			if(pTimer){
				pTimer.stop();
				pTimer.removeEventListener(TimerEvent.TIMER, updatePositions);
				pTimer = null;
			}
    		stage.removeEventListener(MouseEvent.MOUSE_MOVE, cloudsParallax);
			for (var i:* in parallaxBmaps) 
			{
				if (parallaxObjects[i].tween)
				{
					parallaxObjects[i].tween.kill();
					parallaxObjects[i].tween = null;
				}
			}
			//glow.dispose();
			roll.dispose();
			screen.dispose();
			keys = null;
			
			clearTimeout(loopTimeout);
		}
	}
}
