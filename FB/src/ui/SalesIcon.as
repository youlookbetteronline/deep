package ui 
{
	import api.com.adobe.utils.IntUtil;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import effects.Effect;
	import effects.NewParticle;
	import effects.ParticleEffect;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import units.Anime2;
	import units.Anime2Golden;
	import utils.ActionsHelper;
	import wins.ActionInformerWindow;
	import wins.PremiumActionWindow;
	import wins.RoomSetWindow;
	import wins.SaleGoldenWindow;
	import wins.SaleGoldenWindowExtended;
	import wins.SaleGoldenWinterWindow;
	import wins.SaleVipWinterWindow;
	import wins.TemporaryActionWindow;
	import wins.TriggerPromoWindow;
	import wins.BanksWindow;
	import wins.BigsaleWindow;
	import wins.PromoWindow;
	import wins.SaleDecorWindow;
	import wins.SaleLimitWindow;
	import wins.SalesWindow;
	import wins.Window;
	
	public class SalesIcon extends LayerX 
	{
		public static var firstTimeoutInit:Boolean = false;
		
		private var anime:Anime2Golden;
		private var animeGolden:Anime2;
		private var backCont:Sprite;
		private var title:TextField;
		private var titleBankIcon:TextField;
		
		protected var iconPreloader:Preloader = new Preloader();
		protected var preloader:Preloader = new Preloader();
		protected var sID:int;
		protected var iconCont:LayerX;
		
		public var backing:Bitmap;
		public var image:Bitmap;
		public var pID:*;
		public var promo:Object;
		public var params:Object = {
			width:			60,
			height:			80,
			backingMarginX:	0,
			backingMarginY:	0,
			backingScale:	0.8,
			filter:			null,
			
			rotate:			true,
			rotateTimeout:	5000,
			rotateTime:		0.5,
			rotateIndex:	0,
			
			backAlpha:	0.0
		}
		
		public function SalesIcon(promo:Object, params:Object = null) 
		{
			pID = promo.pID;
			this.promo = promo;
			getSid();
			
			if (params)
			{
				for (var s:* in params)
					this.params[s] = params[s];
			}
			
			draw();
			
			if (this.params.rotate)
			{
				startRotate();
			}
			
			App.ui.systemPanel.addEventListener(AppEvent.ON_UI_ANIMATION, onAnimation);
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
		}
		
		override public function get width():Number {
			if (params.hasOwnProperty('width') && params.width > 0) return params.width;
			return super.width;
		}
		override public function get height():Number {
			if (params.hasOwnProperty('height') && params.height > 0) return params.height;
			return super.height;
		}
		
		public function draw():void 
		{
			addChild(preloader);
			preloader.x = width / 2;
			preloader.y = height / 2;
			
			if (params.backAlpha > 0) 
			{
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0xFF0000, params.backAlpha);
				shape.graphics.drawRect(0, 0, params.width, params.height);
				shape.graphics.endFill();
				addChild(shape);
			}
			
			if (promo.bg == null)
				promo.bg = 'DeepSaleBacking3';
			
			backCont = new Sprite();
			iconCont = new LayerX();
			addChild(backCont);
			image = new Bitmap();
			backing = new Bitmap();
			
			Load.loading(Config.getImageIcon('sales/bg', promo.preview), onBackingLoad);
			
			var glowBacking:Bitmap = new Bitmap(Window.textures.glowSale);
			Size.size(glowBacking, 120, 120);
			glowBacking.smoothing = true;
			
			glowBacking.x = params.backingMarginX - glowBacking.width / 2;
			glowBacking.y = params.backingMarginY - glowBacking.height / 2;
			
			backCont.x = width / 2;
			backCont.y = height / 2 + glowBacking.height * 0.05; // изза того что звезда, как пятиугольник, имеет смещенный центр
			backCont.addChild(glowBacking);
		}
		private var firefly:Bitmap
		protected function onBackingLoad(data:Bitmap):void
		{
			removeChild(preloader);
			backing.bitmapData = data.bitmapData;
			backing.x = (params.backingMarginX - backing.width / 2) + width / 2 + 3;
			backing.y = (params.backingMarginY - backing.height / 2) + height / 2 + backing.height * 0.05;
			Size.size(backing, 80, 80);
			backing.smoothing = true;
			
			var firefly:Bitmap = new Bitmap(Window.textures.fireflies);
			Size.size(firefly, 110, 110)
			firefly.x = backing.x - 20;
			firefly.y = backing.y - 10;
			firefly.smoothing = true;
			//drawParticles();
			addChild(backing);
			//addChild(firefly);
			addChild(iconCont);
			addChild(particleSprite);
			drawTitle();
			onAnimation();
		}
		
		private function onAnimation(e:AppEvent = null):void {
			if (SystemPanel.animate) {
				clearParticles();
				drawParticles();
			}else{
				clearParticles();
				var firefly:Bitmap = new Bitmap(Window.textures.fireflies);
				Size.size(firefly, 110, 110)
				firefly.x = backing.x - 20;
				firefly.y = backing.y - 10;
				firefly.smoothing = true;
				particleSprite.addChild(firefly);
			}
		}
		
		public var particleSprite:Sprite = new Sprite();
		public function clearParticles():void
		{
			while (particleSprite && particleSprite.numChildren > 0)
			{
				var _child:* = particleSprite.getChildAt(0);
				try {
					_child.dispose();
				}catch (e:Error) {
					if (_child.parent)
						_child.parent.removeChild(_child);
				}
				
			}
		}
		
		public function drawParticles():void
		{
			var count:int = 20;
			for (var i:int = 0; i < count; i++)
			{
				var particle:NewParticle = new NewParticle({color:0xffffff, radius:1, time:1});
				particle.x = backing.x - 6 + (Math.random() * 80 + 3);
				particle.y = backing.y - 6 + (Math.random() * 80 + 3);
				particleSprite.addChild(particle);
			}
		}
		
		protected function drawTips():void
		{
			iconCont.tip = function():Object {
				var text:String = '';
				var timer:Boolean = true;
				var time:int = 0;
				
				if (promo.type == 6) {
					time = promo.time + promo.live - App.time;
				}else if (promo.type == 0) {
					time = promo.duration * 3600 - (App.time - promo.begin_time);
				}else{
					time = promo.duration * 3600 - (App.time - promo.time);
				}
				
				if (pID == "32") {
					text = Locale.__e('flash:1409671213710');
					timer = false;
				}else if (time > 0 && time < 3600 * 60) {
					text = Locale.__e('flash:1382952379794');
				}else{
					text = Locale.__e('flash:1418655116398');
					timer = false;
				}
				if (timer){
					
					return {
						title:Locale.__e(promo.title),
						text:text,
						timerText:TimeConverter.timeToCuts(time, true, true),
						timer:true
					}
				}else{
					return {
						title:Locale.__e(promo.title),
						text:text,
						timer:timer
					}
				}
			}
		}
		protected function drawTitle():void
		{
			var textSettings:Object;
			textSettings = {
			color:0xffffff,
			borderColor:0x663000,
			borderSize:2,
			fontSize:16,
			textAlign:"center"};
			
			switch(promo.bg){
				case 'DeepSaleBacking1':
					textSettings.borderColor = 0x663000;
					break;
					
				case 'DeepSaleBacking2':
					textSettings.borderColor = 0x8c0e8e;
					break;
					
				case 'DeepSaleBacking3':
					textSettings.borderColor = 0x06535a;
					break;
					
				case 'DeepSaleBacking4':
					textSettings.borderColor = 0x06535a;
					break;
					
				case 'DeepSaleBacking5':
					textSettings.borderColor = 0x5f392e;
					break;
					
				case 'DeepSaleBacking6':
					textSettings.borderColor = 0x3b5510;
					break;
					
				default:
					textSettings.borderColor = 0x663000;
					break;
			}
			
			title = Window.drawText(Locale.__e("flash:1382952379793"), textSettings);
			
			if (promo.bg == 'TemporaryActionWindow') 
			{
				updateCounterBooker();
				App.self.setOnTimer(updateCounterBooker);
			}
			
			if (promo['sale'] == 'bankSale' || promo['sale'] == 'promo'|| promo['sale'] == 'bigSale')
			{
				var startTime:int = (promo.hasOwnProperty('begin_time')) ? promo.begin_time : promo.time
				var bigSaleTime:int = promo.duration * 3600 - (App.time - startTime);
				if (bigSaleTime > 0)
					App.self.setOnTimer(updateTimers);
			}
			
			title.wordWrap = true;
			title.width = params.width;
			title.y = params.height - title.height;
			
			if (promo.ribbon && Window.textures.hasOwnProperty(promo.ribbon))
			{
				var titleRibbon:Bitmap = Window.backingHorizontal(95, promo.ribbon,Size.scaleBitmapData(Window.textures[promo.ribbon],.8));
				titleRibbon.x = title.x - (titleRibbon.width - title.width) / 2;
				titleRibbon.y = title.y - 3;
				addChild(titleRibbon);
			}
			
			if (promo.leftImage && promo.leftImage != '')
			{
				var leftImage:Bitmap = new Bitmap;
				Load.loading(Config.getImage('actions/leftImage', promo.leftImage),function(data:*):void{
					leftImage.bitmapData = data.bitmapData;
					Size.size(leftImage, 55, 55);
					leftImage.smoothing = true;
					leftImage.x = backing.x - 15;
					leftImage.y = backing.y - 10;
					addChild(leftImage);
				})
			}
			addChild(title);
			drawPromoIcon();
		}
		
		protected function drawPromoIcon():void
		{
			iconCont.addChild(iconPreloader);
			iconPreloader.x = params.width / 2;	
			iconPreloader.y = params.height / 2;
			if (sID == 2499)
			{
				Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview),onCostileLoad);
			}
			else if (sID == 1254)
				Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview),onCostileLoad);
			else if (App.data.storage[sID].type == 'Walkgolden')
				Load.loading(getUrl(), onAnimationLoad);
			else if (App.data.storage[sID].type == 'Golden')
				Load.loading(getUrl(), onAnimationGoldenLoad);
			else if (promo['sale'] == 'bigSale' && promo.hasOwnProperty('icon') && promo['icon'] != '')
				Load.loading(Config.getSwf('Bigsale', promo['icon']), onBigsaleLoad);
			else
				Load.loading(getUrl(), onIconLoad);
		}
		
		private function onCostileLoad(data:*):void 
		{
			iconCont.removeChild(iconPreloader);
			var icon:Bitmap = new Bitmap(data.bitmapData);
			Size.size(icon, 70, 70)
			iconCont.addChild(icon);
			iconCont.x = (params.width  - iconCont.width) / 2;
			iconCont.y = (params.height - iconCont.height) / 2;
			
		}
		
		private function onIconLoad(data:Bitmap):void
		{
			iconCont.removeChild(iconPreloader);
			
			image.bitmapData = data.bitmapData;
			image.smoothing = true;
			
			iconCont.addChild(image);
			
			if (backing && backing.width > 0)
			{
				Size.size(image, backing.width - 20, backing.height - 20);
			}
			
			image.filters = params.filter;
			iconCont.x = (params.width  - iconCont.width) / 2;
			iconCont.y = (params.height - iconCont.height) / 2;
			drawTips();
		}
		
		private function onAnimationLoad(swf:*):void 
		{
			iconCont.removeChild(iconPreloader);
			anime = new Anime2Golden(swf, { w:backing.width-4, h:backing.height, type:'Walkgolden' } );
			
			iconCont.addChild(anime);
			iconCont.x = (params.width  - iconCont.width) / 2;
			iconCont.y = (params.height - iconCont.height) / 2;
			drawTips();
		}
		
		private function onAnimationGoldenLoad(swf:*):void 
		{
			iconCont.removeChild(iconPreloader);
			animeGolden = new Anime2(swf, { w:backing.width-4, h:backing.height, type:'Golden'} );
			
			iconCont.addChild(animeGolden);
			iconCont.x = (params.width  - iconCont.width) / 2;
			iconCont.y = (params.height - iconCont.height) / 2;
			drawTips();
		}
		
		private function onBigsaleLoad(swf:*):void 
		{
			iconCont.removeChild(iconPreloader);
			animeGolden = new Anime2(swf, { 
				w	:backing.width - 25, 
				h	:backing.height - 25
			});
			
			iconCont.addChild(animeGolden);
			iconCont.x = (params.width  - iconCont.width) / 2;
			iconCont.y = (params.height - iconCont.height) / 2;
			drawTips();
		}
		
		private function updateCounterBooker():void
		{
			var action:Object = App.data.actions[pID];
			var bookerTime:int = action.begin_time + action.duration * 3600 - App.time;
			title.text = TimeConverter.timeToStr(bookerTime);
			
			if (bookerTime <= 0) {
				title.visible = false;
				App.self.setOffTimer(updateCounterBooker);
			}
		}
		
		private function updateTimers():void 
		{
			var timeToEnd:int = 0;
			var bigSaleTime:int;
			if (promo['sale'] == 'bankSale') {
				if(App.data.money && App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1)
					timeToEnd = App.data.money.date_to;
				else if (App.user.money > App.time)
					timeToEnd = App.user.money;
				else
					this.visible = false;
				
				var time:int = timeToEnd - App.time;
				title.text = TimeConverter.timeToStr(time);
				title.visible = true;
			}else if (promo['sale'] == 'promo') {
				if (promo.hasOwnProperty('additional'))
					bigSaleTime = promo.duration * 3600 - (App.time - promo.time);
				else
					bigSaleTime = promo.duration * 3600 - (App.time - promo.begin_time);
				title.visible = true;
				title.text = TimeConverter.timeToStr(bigSaleTime);
				if (bigSaleTime <= 0)
				{
					dispose();
					App.self.setOffTimer(updateTimers);
					App.ui.salesPanel.resize();
				}
			}else if (promo['sale'] == 'bigSale') {
				bigSaleTime = promo.duration * 3600 - (App.time - promo.time);
				title.visible = true;
				title.text = TimeConverter.timeToStr(bigSaleTime);
				if (bigSaleTime <= 0)
				{
					dispose();
					App.self.setOffTimer(updateTimers);
					App.ui.salesPanel.resize();
				}
			}else {
				this.visible = false;
			}
			
		}
		
		protected function getSid():void
		{
			if (promo.hasOwnProperty('iorder'))
			{
				var _items:Array = [];
				for (var _sID:* in promo.items)
				{
					_items.push( { sID:_sID, order:promo.iorder[_sID] } );
				}
				_items.sortOn('order');
				sID = _items[0].sID;
			}else {
				sID = promo.items[0].sID;
			}
		}
		
		protected function getUrl():String
		{
			var url:String = Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
			switch(sID) 
			{
				case Stock.COINS:
					url = Config.getIcon("Coins", "gold_02");
				break;
				case Stock.FANT:
					url = Config.getIcon("Reals", "crystal_03");
				break;
				case Stock.COOKIE:
					url = Config.getIcon("Energy", "cookie3");
				break;
			}
			
			if (App.data.storage[sID].type == 'Walkgolden')
			{
				url = Config.getSwf(App.data.storage[sID].type, App.data.storage[sID].preview);
			}
			if (App.data.storage[sID].type == 'Golden')
			{
				url = Config.getSwf(App.data.storage[sID].type, App.data.storage[sID].preview);
			}
				
			
			return url;
		}
		
		private var timeout:int = 0;
		private var interval:int = 0;
		private var tween:TweenLite = null;
		public function startRotate(checkRotateIndex:Boolean = true):void
		{
			if (checkRotateIndex && params.rotateIndex > 0)
			{
				timeout = setTimeout(function():void {
					startRotate(false);
					timeout = 0;
				}, params.rotateIndex * params.rotateTime * 1000 / 1.5);
				return;
			}
			
			interval = setInterval(rotate, params.rotateTimeout);
		}
		
		public function rotate():void 
		{
			tween = TweenLite.to(backCont, params.rotateTime, { rotation:backCont.rotation + 360 / 5, onComplete:function():void {
				tween = null;
			}} );
		}
		
		private function onOver(e:MouseEvent):void
		{
			Effect.light(iconCont, 0.1);
		}
		
		private function onOut(e:MouseEvent):void
		{
			Effect.light(iconCont);
		}
		
		public function onClick(e:MouseEvent = null):void 
		{
			Window.closeAll();
			ActionsHelper.openAction(pID, promo);
		}
		
		public function dispose():void
		{
			App.ui.systemPanel.removeEventListener(AppEvent.ON_UI_ANIMATION, onAnimation);
			removeEventListener(MouseEvent.CLICK, onClick);
			removeEventListener(MouseEvent.ROLL_OVER, onOver);
			removeEventListener(MouseEvent.ROLL_OUT, onOut);
			
			if (tween)
			{
				tween.kill();
				tween = null;
			}
			
			if (interval > 0)
			{
				clearInterval(interval);
				interval = 0;
			}
			
			if (timeout > 0)
			{
				clearInterval(timeout);
				timeout = 0;
			}
			
			//clearParticles();
			
			if (parent) parent.removeChild(this);
			
			App.self.setOffTimer(updateTimers);
			
		}
	}

}