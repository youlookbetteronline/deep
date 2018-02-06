package ui 
{
	import buttons.MoneyButton;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Strong;
	import core.AvaLoad;
	import core.Load;
	import core.Size;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import units.Animal;
	import wins.Window;
	
	public class UnitIcon extends LayerX {
		
		public static const DEFAULT:String = 'default';
		public static const PROGRESS:String = 'progress';
		public static const PRODUCTION:String = 'production';
		public static const REWARD:String = 'reward';
		public static const VALENTINE:String = 'valentine';
		public static const FRIENDS:String = 'friends';
		public static const AVATAR:String = 'avatar';
		public static const ANIMAL:String = 'animal';
		public static const TECHNO:String = 'techno';
		public static const BUILDING_REWARD:String = 'building_reward';
		public static const ORACLE:String = 'oracle';
		public static const MAIL:String = 'mail';
		public static const BUILD:String = 'build';
		public static const CLEAR:String = 'clear';
		public static const BUILDING:String = 'building';
		public static const DIALOG:String = 'dialog';
		public static const DREAM:String = 'dream';
		public static const WALKHERO:String = 'walkhero';
		public static const PORTAL:String = 'portal';
		public static const MATERIAL:String = 'material';
		public static const HUNGRY:String = 'hungry';		
		public static const SMILE_POSITIVE:String = 'smilePositive';
		public static const EMPTY:String = 'empty';
		
		public var backing:Bitmap;
		public var icon:Bitmap;
		public var stopGlowing:Boolean;
		public var block:Boolean;
		public var info:Object;
		public var target:*;
		public var sid:*;
		public var need:int = 0;
		public var count:TextField;
		public var require:Object = { };
		
		private var textLabel:TextField;
		private var glow:Sprite;
		private var container:Sprite;
		private var progressBack:Bitmap;
		private var progressBar:Sprite;
		private var jumpInProgress:Boolean;
		private var boostBttn:MoneyButton;
		private var preloader:Preloader;
		private var _state:String = DEFAULT;
		private var bgIcon:Shape = new Shape();
		private var jumpTimeout:int = 0;
		private var jumpTimes:int = 0;
		private var jumping:int = 0;
		private var hiddenTimeout:int = 0;
		private var tweenFadein:TweenLite;
		private var stockHaveRequire:Boolean;
		
		public var params:Object = {
			minWidth:		30,
			minHeight:		30,
			maxWidth:		140,
			maxHeight:		140,
			horizontalAlign:true,
			verticalAlign:	false,
			backing:		'none',
			hasBacking:		true,
			textLeading:	-3, 		
			
			stocklisten:	false,		// Подписаться на события склада и обновлять счетчик, если известны sid'ы
			hidden:			false,		// Прятаться
			hiddenTimeout:	3000,		// Прятаться по истечении времени
			fadein:			false,
			fadeinTimeout:	500,
			
			clickable:		true,
			onClick:		null,
			multiclick:		false,		// Активирует возможность "кликнуть" на подобные иконти, кликом на одну и наведение мыши на остальные
			
			iconScale:		1,
			iconDX:			0,
			iconDY:			0,
			
			glow:			false,
			glowRotate:		false,
			glowRotateSpeed:0.6,
			
			progressWidth:	100,
			progressHeight:	3,
			progressBegin:	0,
			progressEnd:	0,
			boostPrice:		100,
			progressBacking:'progressBar',
			progressBar:	'progressSlider',
			bttnCaption:	Locale.__e('flash:1382952379751'),
			
			textSettings:	{
				fontSize:	18,
				color:		0xfefefe,
				borderColor:0x754122,
				autoSize:	'left'
			}
		}
		public function set state(value:String):void {
			if (_state == value) return;
			
			_state = value;
		}
		public function get state():String {
			return _state;
		}
		
		public function UnitIcon(type:String, sid:* = null, need:int = 0, target:* = null, params:Object = null) {
			if (params) {
				for (var prop:* in params) {
					this.params[prop] = params[prop];
					
					if (this.hasOwnProperty(prop) && !(params[prop] is Function) && typeof(this[prop]) == typeof(params[prop]) )
						this[prop] = params[prop];
				}
			}
			
			state = type;
			this.target = target;
			
			// Если получили объект, то взять первый элемент как материал
			if (sid && typeof(sid) == 'object') {
				for (var first:* in sid) break;
				require = sid;
				this.need = sid[first];
				this.sid = first;
			} else if (sid is int) {
				require[sid] = need;
				this.sid = sid;
				this.need = need;
			}
			
			if (App.data.storage.hasOwnProperty(this.sid))
				info = App.data.storage[this.sid];
			
			draw();
			initFadeIn();
			initHidden();
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
			
			if (this.params.stocklisten)
				App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			
			var s:Shape = new Shape();
			s.graphics.beginFill(0xFF0000, 1);
			s.graphics.drawCircle(0, 0, 2);
			s.graphics.endFill();
		}
		
		public function draw():void {
			
			container = new Sprite();
			var circle:Shape;
			var maska:Shape;
			addChild(container);
			if (params.clickable) {
				container.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
				container.addEventListener(MouseEvent.MOUSE_UP, onClick, false, 1);
			}			
			if (state == PRODUCTION) {
				progressBack = new Bitmap(UserInterface.textures[params.progressBacking]);
				progressBack.smoothing = true;
				progressBack.x = -progressBack.width / 2;
				progressBack.y = -progressBack.height;
				
				container.addChild(progressBack);
				
				progress();
				
				App.self.setOnTimer(progress);
				
				// Backing
				backing = new Bitmap(Window.textures.bubble);
				backing.width = 70;
				backing.scaleY = backing.scaleX;
				backing.smoothing = true;
				backing.x = -backing.width / 2;
				backing.y = -backing.height - progressBack.height - 4;
				container.addChild(backing);
				
				// Icon
				loadIcon();
				icon.filters = [new GlowFilter(0xc3e0ec, 1, 5, 5, 6)];
				
			} else if (state == PROGRESS || state == BUILDING) {
				progressBack = new Bitmap(UserInterface.textures[params.progressBacking]);
				progressBack.x = -progressBack.width / 2;
				progressBack.y = -progressBack.height;
				container.addChild(progressBack);
				
				progress();
				
				if (Config.admin || (target is Animal && target.isCollectionFinder)) {
					boostBttn = new MoneyButton( {
						width:		progressBack.width + 30,
						height:		44,
						caption:	params.bttnCaption,
						countText:	params.boostPrice,
						onClick:	params.hasOwnProperty('onClick') ?params.onClick : onClick
					});
					boostBttn.x = progressBack.x + (progressBack.width - boostBttn.width) / 2;
					boostBttn.y = progressBack.y - boostBttn.height - 4;
					container.addChild(boostBttn);
				}
				
				App.self.setOnTimer(progress);
				
				removeOnMapClick();
				
			}else if (state == DIALOG) {
				
				var text:TextField = Window.drawText(params['text'], params.textSettings);
				
				if (text.width > 300) {
					text.wordWrap = true;
					text.multiline = true;
					text.width = 300;
					
				}
				
				text.x = -text.textWidth / 2;
				text.y -= text.height + 52;
				text.textColor = 0xeff2f5;
				text.width = text.textWidth;
				if (params.textSettings.hasOwnProperty('input') && params.textSettings.input == true){
					text.setSelection(0, 0);
					text.alwaysShowSelection = true;
				}
				var matrix:Matrix = new Matrix(); 
				matrix.createGradientBox(text.textWidth + 25, text.height + 15, Math.PI / 2);
				var alpha:Number = 0.5;
				bgIcon.graphics.beginGradientFill(
					GradientType.LINEAR,
					[0x46deff, 0x2532dd],
					[alpha, alpha],
					[0, 255],
					matrix
				);
				
				bgIcon.graphics.drawRect(0, 0, text.textWidth + 35, text.height + 15);
				bgIcon.graphics.endFill();
				bgIcon.x = text.x + (text.width - bgIcon.width) / 2;
				bgIcon.y = text.y + (text.height - bgIcon.height) / 2;
				bgIcon.filters = [new BlurFilter(70, 0, 2)];
				
				var triangleHeight:uint = 15; 
				var triangle:Shape = new Shape(); 
				
				triangle.graphics.beginFill(0x2532dd, alpha); 
				triangle.graphics.moveTo(triangleHeight / 2, 0); 
				triangle.graphics.lineTo(triangleHeight, triangleHeight); 
				triangle.graphics.lineTo(0, triangleHeight); 
				triangle.graphics.lineTo(triangleHeight / 2, 0);
				triangle.scaleY = triangle.scaleY * -1;
				triangle.x = bgIcon.x + bgIcon.width / 2 - 30;
				triangle.y = bgIcon.y + bgIcon.height + triangle.height;
				 
				 
				container.addChild(triangle);
				
				container.addChild(bgIcon);
				container.addChild(text);
				
				up();
				
			} else if (state == MAIL) {
				
				backing = new Bitmap(Window.texture('bubble'));
				Size.size(backing, 40, 40);
				backing.smoothing = true;
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				icon = new Bitmap(UserInterface.textures.envelope);
				Size.size(icon, 30, 30);
				icon.smoothing = true;
				icon.x = backing.x + (backing.width - icon.width) / 2;
				icon.y = backing.y + (backing.width - icon.height) / 2;
				container.addChild(icon);
				
			} else if (state == ORACLE) {
				
				backing = new Bitmap(Window.texture('infoBigIcon'));
				backing.width = 70;
				backing.scaleY = backing.scaleX;
				backing.smoothing = true;
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				
				
			}else if (state == BUILDING_REWARD) {
				backing = new Bitmap(Window.texture('bubble'));
				backing.width = 70;
				backing.scaleY = backing.scaleX;
				backing.smoothing = true;
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				loadIcon();
				icon.filters = [new GlowFilter(0xc3e0ec, 1, 5, 5, 6)];
				jump();
				
			} else if (state == TECHNO) {
				backing = new Bitmap(Window.texture('bubble'));
				Size.size(backing, 100, 100)
				backing.smoothing = true;
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				count = Window.drawText(String(need), params.textSettings);
				
				count.x = backing.x + backing.width - count.width;
				count.y = backing.y + backing.height - count.height;
				params.iconScale = .75;
				loadIcon();
				if (icon)
				{
					icon.filters = [new GlowFilter(0xc3e0ec, 1, 5, 5, 6)];
					icon.smoothing = true;
				}
				jump();
				
			}else if (state == ANIMAL) {
				
				progressBack = new Bitmap(UserInterface.textures[params.progressBacking]);
				progressBack.x = -progressBack.width / 2;
				progressBack.y = -progressBack.height;
				container.addChild(progressBack);
				
				progress();
				
				boostBttn = new MoneyButton( {
					width:		progressBack.width + 30,
					height:		44,
					caption:	Locale.__e('flash:1382952380104'),//'Ускорить',
					countText:	params.boostPrice,
					onClick:	onAnimalClick
				});
				boostBttn.x = progressBack.x + (progressBack.width - boostBttn.width) / 2;
				boostBttn.y = progressBack.y - boostBttn.height - 4;
				container.addChild(boostBttn);
				
				App.self.setOnTimer(progress);
				
				removeOnMapClick();
				
			}else if (state == VALENTINE) {
				
				backing = new Bitmap(Window.textures.dailyBonusItemBubble);
				Size.size(backing, 50, 50)
				backing.smoothing = true;
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				icon = new Bitmap(UserInterface.textures.valentineIco);
				container.addChild(icon);
				Size.size(icon, 40, 40)
				icon.smoothing = true;
				icon.x = backing.x + (backing.width - icon.width) / 2;
				icon.y = backing.y + (backing.height - icon.height) / 2 + 2;
				
				jump();
				
			}else if (state == FRIENDS) {
				
				backing = new Bitmap(Window.textures.dailyBonusItemBubble);
				Size.size(backing, 50, 50)
				backing.smoothing = true;
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				icon = new Bitmap(Window.textures.friendIcoSmall);
				container.addChild(icon);
				Size.size(icon, 50, 50)
				icon.smoothing = true;
				icon.x = backing.x + (backing.width - icon.width) / 2;
				icon.y = backing.y + (backing.height - icon.height) / 2;
				
				jump();
					
			}else if (state == REWARD) {
				
				backing = new Bitmap(Window.texture('bubble'));
				Size.size(backing, 45, 45)
				backing.smoothing = true;
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				params.iconScale = .7;
				loadIcon();
				if (icon)
				{
					icon.smoothing = true;
				}
				jump();
				
			} else if (state == CLEAR) {
				circle = new Shape();
				circle.graphics.lineStyle(2,0xAAAAAA);
				circle.graphics.beginGradientFill(GradientType.LINEAR, [0x013966, 0x3a76b0], [1, 1], [124, 255]);
				circle.graphics.drawCircle(0, 0, 32);
				circle.x = 0;
				circle.y = -65;
				container.addChild(circle);
				
				maska = new Shape();
				maska.graphics.beginFill(0xffffff, 1);
				maska.graphics.drawRect(0, 0, 64, (14 + 50 * (params.level / params.totalLevels)));
				container.addChild(maska);
				maska.x = circle.x - circle.width/2;
				maska.y = circle.y + circle.height / 2 - maska.height;
				maska.filters = [new BlurFilter(0, 4, 2)];
				maska.cacheAsBitmap = true;
				circle.cacheAsBitmap = true;
				circle.mask = maska;
				
				backing = new Bitmap(Window.textures.productBacking);
				backing.width = 60;
				backing.scaleY = backing.scaleX=.9;
				backing.smoothing = true;
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				loadIcon();
			} else if (state == BUILD) {
				circle = new Shape();
				circle.graphics.lineStyle(2,0xAAAAAA);
				circle.graphics.beginGradientFill(GradientType.LINEAR, [0x013966, 0x3a76b0], [1, 1], [124, 255]);
				circle.graphics.drawCircle(0, 0, 32);
				circle.x = 0;
				circle.y = -65;
				container.addChild(circle);
				
				maska = new Shape();
				maska.graphics.beginFill(0xffffff, 1);
				maska.graphics.drawRect(0, 0, 64, (14 + 50 * (params.level / params.totalLevels)));
				container.addChild(maska);
				//maska.alpha = .5;
				maska.x = circle.x - circle.width/2;
				maska.y = circle.y + circle.height / 2 - maska.height;
				maska.filters = [new BlurFilter(0, 4, 2)];
				maska.cacheAsBitmap = true;
				circle.cacheAsBitmap = true;
				circle.mask = maska;
				
				backing = new Bitmap(Window.textures.productBacking);
				backing.width = 60;
				backing.scaleY = backing.scaleX=.9;
				backing.smoothing = true;
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				icon = new Bitmap(Window.texture('buildIco'));
				icon.smoothing = true;
				Size.size(icon, 50, 50);
				icon.x = backing.x + (backing.width - icon.width) / 2;
				icon.y = backing.y + (backing.width - icon.height) / 2 - 4;
				container.addChild(icon);
				
			}else if (state == AVATAR) {
				
				backing = new Bitmap(UserInterface.textures.friendIcoBacking);
				backing.smoothing = true;
				container.addChild(backing);
				
				var photo:String = '';
				if (this.params.friend && App.user.friends.data[this.params.friend])
				{
					photo = App.user.friends.data[this.params.friend].photo;
				}
				if (this.params.friend && (this.params.friend == App.user.id))
				{
					photo = App.user.photo;
				}
				if (this.params.photo)
				{
					photo = this.params.photo;
				}
				
				if(photo != '')
					new AvaLoad(photo, loadAvatar);
				
			} else if (state == DREAM) {
				
				backing = new Bitmap(Window.texture('itemBacking'));
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				params.iconScale = 0.55;
				
				loadIcon();
			
			} else if (state == PORTAL) {
				
				backing = new Bitmap(Window.textures.productBacking);
				Size.size(backing, 80, 80)
				backing.smoothing = true;
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				icon = new Bitmap(UserInterface.textures.caveIcon);
				container.addChild(icon);
				Size.size(icon, 50, 50)
				icon.smoothing = true;
				icon.x = backing.x + (backing.width - icon.width) / 2;
				icon.y = backing.y + (backing.height - icon.height) / 2 - 10;
				
				jump();
			} else if (state == MATERIAL) {
				
				backing  = new Bitmap(Window.texture('bubble'));
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				loadIcon();
				
				if (need > 0) {
					stockHaveRequire = true;
					drawText(String(need));
					onChangeStock();
				}
				
			} else if (state == WALKHERO) {
				
				backing = new Bitmap(UserInterface.textures.settingsIcon);
				Size.size(backing, 60, 60)
				backing.smoothing = true;
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				
				jump();
			}else if (state == HUNGRY) {
				backing = new Bitmap(Window.texture('productBacking2'), 'auto', true);
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				params.iconScale = 0.7;
				loadIcon();
			} else if (state == EMPTY) {
				//
			} else {
				backing = new Bitmap(Window.texture('productBacking'), 'auto', true);
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				icon = new Bitmap(Window.texture(state), 'auto', true);
				icon.filters = [new GlowFilter(0xFFFFFF, 1, 5, 5, 1)];
				container.addChild(icon);
				
				icon.x = backing.x + (backing.width - icon.width) / 2 + params.iconDX;
				icon.y = backing.y + (backing.height - icon.height) / 2 + params.iconDY - 5;
				
				jump(100, 1, false);
			}
			
			if (App.self.fps > 15) {
				container.y = -30;
				container.alpha = 0;
				TweenLite.to(container, 0.16, { y:0, alpha:1} );
			}
		}
		
		public function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
				}});	
			}});
		}
		
		public function glowing():void {

			if (App.user.quests.tutorial) 
			{
				
			}
			
			if(!stopGlowing)
				customGlowing(backing, glowing);
			else
			{
				if (backing)
					backing.filters = null;
			}
		}
		
		private function onLoad(data:Bitmap):void {
			if (preloader && container.contains(preloader))
				container.removeChild(preloader);
			if(!icon){
				dispose();
				return;
			}
			icon.bitmapData = data.bitmapData;
			
			var iconWidth:int = backing.width * params.iconScale;
			var iconHeight:int = backing.height * params.iconScale;
			if (iconWidth < params.minWidth) iconWidth = params.minWidth;
			if (iconHeight < params.minHeight) iconHeight = params.minHeight;
			
			if (state == CLEAR)
			{
				Size.size(icon, 48, 48);
				icon.x = backing.x + (backing.width - icon.width) / 2 + params.iconDX;
				icon.y = backing.y + 15;
			}else{
				Size.size(icon, iconWidth, iconHeight);
				icon.x = backing.x + (backing.width - icon.width) / 2 + params.iconDX;
				icon.y = backing.y + (backing.height - icon.height) / 2 + params.iconDY;
			}
			icon.smoothing = true;
			
			if (glow) {
				glow.alpha = 1;
				glow.x = icon.x + icon.width / 2;
				glow.y = icon.y + icon.height / 2;
			}
		}
		
		// Boost
		public function progress():void {
			var progressValue:Number = (App.time - params.progressBegin) / (params.progressEnd - params.progressBegin);
			if (progressValue > 1) progressValue = 1;
			if (progressValue < 0) progressValue = 0;
			
			if (!progressBar) progressBar = new Sprite();
			if (!container.contains(progressBar)) container.addChild(progressBar);
			progressBar.x = progressBack.x + 2;
			progressBar.y = progressBack.y + 2;
			UserInterface.slider(progressBar, progressValue, 1, params.progressBar);
		}
		
		// Glow
		public function drawGlow():void {
			glow = new Sprite();
			glow.alpha = 0;
			container.addChild(glow);
			
			if (backing) {
				glow.x = backing.x + backing.width / 2 + params.iconDX;
				glow.y = backing.y + backing.height / 2 + params.iconDY;
			}
			
			var glowBitmap:Bitmap = new Bitmap(Window.textures.iconEff);
			glowBitmap.scaleX = glowBitmap.scaleY = params.iconScale ;
			glowBitmap.x = -glowBitmap.width / 2;
			glowBitmap.y = -glowBitmap.height / 2;
			glow.addChild(glowBitmap);
			
			App.self.setOnEnterFrame(glowRotate);
		}
		
		private function glowRotate(e:Event = null):void {
			glow.rotation += params.glowRotateSpeed;
		}
		
		// Text
		private function drawText(text:String = '', additionalSettings:Object = null):void {
			//if (params.disableText) return;
			
			if (textLabel && container.contains(textLabel)) {
				container.removeChild(textLabel);
			}
			
			var textSettings:Object = { };
			for (var s:* in params.textSettings)
				textSettings[s] = params.textSettings[s];
			
			if (additionalSettings) {
				for (s in additionalSettings)
					textSettings[s] = additionalSettings[s];
			}
			
			textLabel = Window.drawText('x' + text, textSettings);
			textLabel.x = -textLabel.width / 2 + 15;
			textLabel.y = -textLabel.height - 16;
			container.addChild(textLabel);
		}
		
		// Avatar
		private function loadAvatar(data:*):void
		{
			var sprite:LayerX = new LayerX();
			icon = new Bitmap();
			if (data is Bitmap)
			{
				icon.bitmapData = data.bitmapData;
				icon.scaleX = icon.scaleY = 1.2;
				icon.smoothing = true;
			}
			sprite.addChild(icon)
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawRoundRect(4, 4, 56, 52, 26, 26);
			shape.graphics.endFill();
			shape.filters = [new BlurFilter(2, 2)];
			shape.cacheAsBitmap = true;
			sprite.mask = shape;
			sprite.cacheAsBitmap = true;
			sprite.addChild(shape);
			container.addChild(sprite);
			sprite.x = backing.x + (backing.width - sprite.width) / 2 - 2;
			sprite.y = backing.y + (backing.height - sprite.height) / 2 - 8;
		}
		
		// Icon
		public function loadIcon():void 
		{
			if (!info) return;
			preloader = new Preloader();
			Size.size(preloader, backing.width - 15, backing.height - 15);
			preloader.y = backing.y + (backing.height - preloader.height) / 2 + preloader.height / 2;
			container.addChild(preloader);
			icon = new Bitmap();
			icon.smoothing = true;
			container.addChild(icon);
			
			if (count)
				container.addChild(count);
				
			Load.loading(Config.getIcon(info.type, info.preview), onLoad);
		}
		
		public function onAnimalClick(e:MouseEvent = null):void 
		{
			if (!(target is Animal))
				return;
			target.onBoostEvent(App.data.storage[target.sID].speedup);
			if (e) e.stopImmediatePropagation();
		}
		
		public function onClick(e:MouseEvent = null):void {
			if (App.user.quests.tutorial ) return;
			if (App.map.moved || block) return;
			
			if (target is Animal)
				onAnimalClick(e);
			
			if (__hasGlowing) hideGlowing();
			
			if (params.stocklisten)
				onChangeStock();
			
			if (params.onClick != null) {
				params.onClick();
			}else if (target && target.hasOwnProperty('click') && (target['click'] is Function) && !(target is Animal)) {
				target['click']();
			}
			
			if (App.user.quests.tutorial) return;
			if (e) e.stopImmediatePropagation();
		}
		
		public function onDown(e:MouseEvent):void {}
		
		// Moves and animations
		private function jump(timeout:int = 5000, times:int = 0, randomStart:Boolean = true):void {
			jumpStop();
			
			jumpTimeout = timeout;
			jumpTimes = times;
			jumping = setInterval(goJump, ((randomStart) ? Math.floor(jumpTimeout * Math.random()) : jumpTimeout), randomStart);
		}
		
		private function jumpStop():void {
			if (jumping) clearInterval(jumping);
		}
		
		private function goJump(randomStart:Boolean = false):void {
			if (randomStart) {
				jump(jumpTimeout, jumpTimes, false);
				return;
			}
			
			if (jumpInProgress) return;
			jumpInProgress = true;
			
			TweenLite.to(container, 0.3, { scaleX:1.2, scaleY:0.8, ease:Strong.easeOut, onComplete:function():void {
				TweenLite.to(container, 0.8, { 
					scaleX:1, scaleY:1, ease:Elastic.easeOut, onComplete:function():void {
						if (jumpTimes > 1) {
							jumpTimes--;
						}else if (jumpTimes == 1) {
							jumpStop();
							return;
						}
						
						jumpInProgress = false;
					}
				} );
			}} );
		}
		
		private function up():void {
			container.alpha = 0;
			container.y = 6;
			TweenLite.to(container, 0.25, { y:0, alpha:1 } );
		}
		
		
		private function removeOnMapClick():void {
			App.self.addEventListener(AppEvent.ON_MAP_CLICK, onMapClickEvent);
		}
		private function onMapClickEvent(e:AppEvent = null):void {
			hideBegin();
		}
		
		
		// Fade in
		// Hidden
		private function initHidden():void {
			if (params.hidden && hiddenTimeout == 0) {
				hiddenTimeout = setTimeout(hideBegin, params.hiddenTimeout);
			}
		}
		private var bTween:TweenLite;
		private function hideBegin():void {
			//block = true;
			bTween = TweenLite.to(this, 0.5, { alpha:0, onComplete:function():void {
				if (params.onHide)
					params.onHide();
				dispose();
			}} );
		}
		
		private function initFadeIn():void {
			if (params.fadein && params.fadeinTimeout > 0) {
				alpha = 0;
				tweenFadein = TweenLite.to(this, params.fadeinTimeout / 1000, { alpha:1 } );
			}
		}
		
		// Stock
		private function onChangeStock(e:AppEvent = null):void {
			if (need > 0) {
				if (state == MATERIAL){
					var lastState1:Boolean = stockHaveRequire;
					stockHaveRequire = App.user.stock.checkAll(require);
					
					if (lastState1 != stockHaveRequire) {
						var additionalSettings1:Object = null;
						
						// Если на складе не достаточно материала
						if (!stockHaveRequire) {
							
							backing.bitmapData = Window.texture('bubble');//productBacking2
							
							additionalSettings1 = {
								color:			0xff632c,
								borderColor:	0x591f0b
							}
							
							drawText(String(need), additionalSettings1);
						} else if(stockHaveRequire) {
							backing.bitmapData = Window.texture('bubble');
						}
						
						drawText(String(need), additionalSettings1);
					}
				}else
				{
					var lastState:Boolean = stockHaveRequire;
					stockHaveRequire = App.user.stock.checkAll(require);
					
					if (lastState != stockHaveRequire) {
						var additionalSettings:Object = null;
						
						// Если на складе не достаточно материала
						if (!stockHaveRequire) {
							
							backing.bitmapData = Window.texture('productBacking');//productBacking2
							
							additionalSettings = {
								color:			0xff632c,
								borderColor:	0x591f0b
							}
							
							drawText(String(need), additionalSettings);
						} else if(stockHaveRequire) {
							backing.bitmapData = Window.texture('productBacking');
						}
						
						drawText(String(need), additionalSettings);
					}
				}
			}
		}
		
		protected function onOver(e:MouseEvent):void {
			App.map.unitIconOver = true;
			Effect.light(this, 0.15);
		}
		
		protected function onOut(e:MouseEvent):void {
			App.map.unitIconOver = false;
			Effect.light(this);
		}
		
		private function onRemove(e:Event = null):void {
			dispose();
		}
		
		public function dispose():void {
			if(bTween != null){
				bTween.complete(true, true);
				bTween.kill();
				bTween = null;
			}
			if(App.map)
				App.map.unitIconOver = false;
			
			App.self.setOffEnterFrame(glowRotate);
			
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			removeEventListener(MouseEvent.ROLL_OVER, onOver);
			removeEventListener(MouseEvent.ROLL_OUT, onOut);
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			App.self.removeEventListener(AppEvent.ON_MAP_CLICK, onMapClickEvent);
			container.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			container.removeEventListener(MouseEvent.MOUSE_UP, onClick);
			
			jumpStop();
			App.self.setOffTimer(progress);
			
			if (boostBttn)
				boostBttn.dispose();
			
			if (parent)
				parent.removeChild(this);
			
			if (hiddenTimeout > 0)
				clearTimeout(hiddenTimeout);
			
			if (tweenFadein)
				tweenFadein.kill();
				
			//clearVariables();
		}
		
		public function clearVariables():void {
			var self:* = this;
			var description:XML = describeType(this);
			var variables:XMLList = description..variable;
			for each(var variable:XML in variables) {
				var ss:String = variable.@type;
				if(variable.@type == '*')
				{
					self[variable.@name] = null;
					continue;
				}
				var classType:Class
				try{
					classType = getDefinitionByName(variable.@type) as Class;
				}catch (e:Error){
					self[variable.@name] = null;
					continue;
				}
				switch(classType){
					case Sprite:
						if (self[variable.@name]){
							self[variable.@name].removeChildren();
							self[variable.@name] = null;
						}
						break;
					default:
						self[variable.@name] = null;
				}
			}
		}
	}
}

