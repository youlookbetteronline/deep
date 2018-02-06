package buttons 
{
	import com.greensock.easing.Strong;
	import core.Load;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.setInterval;
	import silin.filters.ColorAdjust;	
	import com.greensock.*;
	import ui.SystemPanel;
	import ui.UserInterface;
	import wins.AchivementMsgWindow;
	import wins.CharactersWindow;
	import wins.ErrorWindow;
	import wins.LevelUpWindow;
	import wins.PaymentConfirmWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class Button extends LayerX
	{
		
		public static const DISABLED:int 	= 0;
		public static const NORMAL:int 		= 1;
		public static const ACTIVE:int 		= 2;
		
		//Визуальные свойства
		public var settings:Object			= {
			
			// Подложка
			width					:150,					//Ширина
			height					:42,						//Высота
			radius					:20,						//Радиус скругления
			bgColor					:[0xfed131, 0xf8ab1a],
			bevelColor				:[0xf7fe9a, 0xcb6b1e],
			borderColor				:[0xfff37d, 0xc57e0c],	//Цвета градиента
			// Текст
			fontColor				:0xffffff,				//Цвет шрифта
			fontBorderColor 		:0x6e411e,
			fontSize				:30,						//Размер шрифта
			textLeading				:-8,						//Вертикальное расстояние между словами	
			
			fontBorderSize:			3,						//Размер обводки шрифта
			fontBorderGlow:			2,						//Размер размытия шрифта
			caption:				Locale.__e("flash:1382952379714"),			//Текст кнопки
			captionOffsetY:			0,
			//fontFamily:				"BrushType-SemiBold",	//Шрифт
			fontFamily:				"font",	//Шрифт
			textAlign:				"left",				//Расположение текста
			multiline:				false,					//Многострочный текст
			
			shadow:					true,					//Тень
			worldWrap:				false,					//Тень
			filters:				null,					//Дополнительные фильтры
			hasDotes:				false,
			greenDotes:				false,
			grayDotes:				false,
			view:					'empty',
			
			active: {
				bgColor:				[0xad9765,0xd1be88],	//Цвета градиента
				borderColor:			[0x8b7a51,0x8b7a51],	//Цвета градиента
				bevelColor:				[0x8b7a51,0xded4bf],	
				fontColor:				0xffffff,				//Цвет шрифта
				fontBorderColor:		0x7a683c				//Цвет обводки шрифта		
			},
			
			eventPostManager:		false,						// Кнопка по умолчанию не слушает PostManager. То есть не реагирует на запрос/ответ от сервера. 
			
			sound:'sound_1v2'
		}
		//Состояние кнопки
		public var mode:int					= NORMAL;				//Состояние кнопки: true - активное, false - пассивное
		
		//События
		public var onMouseDown:Function		= null;							//Нажатие кнопки мыши
		public var onMouseUp:Function		= null;							//Отпускание кнопки мыши
		public var onClick:Function			= null;							//Клик
		public var bottomLayer:Sprite 		= new Sprite;		//Нижний слой (кнопка)
		public var topLayer:Sprite			= new Sprite;		//Слой с текстом
		public var textLabel:TextField;
		public var style:TextFormat;
		public var textFilter:GlowFilter;
		public var __tween:* = null;
		public var order:int = 0;
		public var bttnY:Number;
		public var descent:uint = 15;
		
		private var _oldState:int			= 1;				// предыдущее состояние кнопки.
		private var reask:Boolean;
		private var fantImage:Bitmap;
		
		/**
		 * Какое предыдущее состояние кнопки было?
		 */
		public function get oldState():int{
			return _oldState;
		}
		public function set caption(text:String):void{
			textLabel.text = text;
			textLabel.setTextFormat(style);
			textLabel.width = textLabel.textWidth + 8;
			textLabel.x = (settings.width - textLabel.width) / 2;
			textLabel.y = (settings.height - textLabel.textHeight) / 2;
		}
		public function get caption():String{
			return textLabel.text;
		}
		public function set state(mode:int):void{
			_oldState = this.mode;
			this.mode = mode;
			switch(mode) {
				case Button.DISABLED:  disable(); break;
				case Button.NORMAL:  	enable(); break;
				case Button.ACTIVE:  	active(); break;
			}
		}
		
		/**
		 * Конструктор
		 * @param	settings	пользовательские настройки кнопки
		 */
		public function Button(settings:Object = null)
		{
			//Переназначаем дефолтные настройки на пользовательские
			for (var property:* in settings) {
				this.settings[property] = settings[property];
			}
			draw();
			this.cacheAsBitmap = true;
			this.buttonMode = true
			
			if (settings == null) {
				settings = { };
			}
			
			name = settings['name'] || name;
			onMouseDown = settings.onMouseDown;
			
			mouseChildren = false;
			
			// Если параметр eventPostManager истина - то добавить кнопку в PostManager
			if ( settings.hasOwnProperty('eventPostManager') && settings.eventPostManager ){
				PostManager.instance.add(this);
			}
		}
		
		private function draw():void {
			drawBottomLayer();
			drawTopLayer();
			setEvents();
			this.state = mode;
		}
		
		/**
		 * Удаление слушателей событий
		 */
		public function dispose():void {
			
			removeEventListener(MouseEvent.MOUSE_OVER, MouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT, MouseOut);
			removeEventListener(MouseEvent.MOUSE_DOWN, MouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, MouseUp);
			
			removeEventListener(MouseEvent.CLICK, onBeforeClick);
			
			onMouseUp = null;
			onMouseDown = null;
			
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
		}
		
		
		
		protected function redrawBottomLayer():void
		{
			removeChild(bottomLayer);
			bottomLayer = new Sprite();
			drawBottomLayer();
			
			if (style == null) return;
			
			if (mode == Button.ACTIVE) {
				
				style.color = 0xf0e6c1;
				textFilter = new GlowFilter(0x7b5909, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
			}else{
				
				style.color = settings.fontColor; 
				textFilter = new GlowFilter(settings.fontBorderColor, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
			}
			
			textLabel.setTextFormat(style);
		}

		protected function drawBottomLayer():void
		{
			var gradType:String = GradientType.LINEAR;
			var alphas:Array = [1, 1];
			var ratios:Array = [0, 255];
			
			var matrix:Matrix = new Matrix();
			var boxWidth:Number = settings.width;
			var boxHeight:Number = settings.height;
			var boxRotation:Number = Math.PI/2;
			var tx:Number = 25;
			var ty:Number = 0;

			matrix.createGradientBox(boxWidth, boxHeight, boxRotation, tx, ty);
			
			var borderColors:Array = [];
				borderColors = borderColors.concat(settings.borderColor);
				
			var bgColors:Array = [];
				bgColors = bgColors.concat(settings.bgColor);	
					
			var bg:Sprite = new Sprite();
			with(bg.graphics){
				lineStyle(0x000000, 0, 0, true);	
				beginGradientFill(gradType, bgColors, alphas, ratios, matrix);
				drawRoundRect(2, 2, settings.width-4, settings.height-4, settings.radius, settings.radius);
				endFill();
			}
			bg.filters = [new DropShadowFilter(1, 90, settings.bevelColor[0], 1, 4, 4, 4, 1, true), new DropShadowFilter(1, -90, settings.bevelColor[1], .8, 4, 4, 4, 1, true), new DropShadowFilter(1, 90, 0, .3, 4, 4, 4, 1)];
			bottomLayer.addChild(bg);
			
			addChildAt(bottomLayer, 0);
			
			if (style)
			{
				style.color = settings.fontColor; 
				textLabel.setTextFormat(style);
			}
			
			if (textLabel)
			{
				textFilter = new GlowFilter(settings.fontBorderColor, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
				var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,settings.fontBorderColor,0.9,2,2,2,1);
				textLabel.filters = [textFilter, shadowFilter];
			}
		}
		
		protected function drawDownBottomLayer():void
		{
			var gradType:String = GradientType.LINEAR;
			var alphas:Array = [1, 1];
			var ratios:Array = [0, 255];
			
			var matrix:Matrix = new Matrix();
			var boxWidth:Number = settings.width;
			var boxHeight:Number = settings.height;
			var boxRotation:Number = Math.PI/2;
			var tx:Number = 25;
			var ty:Number = 0;

			matrix.createGradientBox(boxWidth, boxHeight, boxRotation, tx, ty);
			
			var borderColors:Array = [];
				borderColors = borderColors.concat(settings.active.borderColor);
				
			var bgColors:Array = [];
				bgColors = bgColors.concat(settings.active.bgColor);	
				
			var bg:Sprite = new Sprite();
				bg.graphics.lineStyle(0x000000, 0, 0, true);	
				bg.graphics.beginGradientFill(gradType, bgColors, alphas, ratios, matrix);
				bg.graphics.drawRoundRect(2, 2, settings.width-4, settings.height-4, settings.radius, settings.radius);
				bg.graphics.endFill();
				bg.filters = [new DropShadowFilter(1, 90, settings.active.bevelColor[0], .8, 4, 4, 4, 1, true), new DropShadowFilter(1, -90, settings.active.bevelColor[1], 1, 4, 4, 4, 1, true), new DropShadowFilter(1, 90, 0, .3, 4, 4, 4, 1)];
				//bg.filters = [new BevelFilter(2, 90, settings.active.bevelColor[0], 1, settings.active.bevelColor[1], 1, 0, 0, 1, 1)];
			
			//var shadow:Sprite = new Sprite();
				//shadow.graphics.lineStyle(0x000000, 0, 0, true);
				//shadow.graphics.beginFill(0x000000, 0.2);
				//shadow.graphics.drawRoundRect(0, 0, settings.width, settings.height, settings.radius+6);
				//shadow.graphics.endFill();
				//
			//bottomLayer.addChild(shadow);
			bottomLayer.addChild(bg);
			
			addChildAt(bottomLayer, 0);
			
			//if (!settings.shadow)	
			//{
				//shadow.height -= 5;
				//shadow.y +=4;
			//}
			
			if(style){
				style.color = settings.active.fontColor; 
				textLabel.setTextFormat(style);
			}
			if(textLabel){
				textFilter = new GlowFilter(settings.active.fontBorderColor, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
				var shadowFilter:DropShadowFilter = new DropShadowFilter(1, 90, settings.active.fontBorderColor, 0.9, 2, 2, 2, 1);
				textLabel.filters = [textFilter, shadowFilter];
			}
			//if (settings.hasDotes) {
				//bottomLayer.x = 10;
			//}
		}	
		
		public function fitTextInWidth(maxWidth:uint):void {
			if (!settings.multiline) {
				textLabel.wordWrap = false;
				textLabel.multiline = false;
				if (settings.width > 0) {
					textLabel.width = maxWidth;
					if(textLabel.textWidth+descent > maxWidth) {
						while (textLabel.textWidth + descent > maxWidth/* || textLabel.textWidth < 10*/) {
							settings.fontSize -= 1;
							style.size = settings.fontSize;
							style.align = 'center';
							textLabel.setTextFormat(style);
						}
						textLabel.y = (settings.height - textLabel.textHeight ) / 2 - 2;
						//textLabel.width = textLabel.textWidth + 3;
						textLabel.width = maxWidth;
						textLabel.x = (settings.width - textLabel.width) / 2;
						//textLabel.x = 0;
					}
				}
			}else {
				if (textLabel.textWidth + 8 > maxWidth && settings.multiline) {
					textLabel.wordWrap = true;
					textLabel.multiline = true;
				}
			}
		}
		
		protected function drawTopLayer():void {
			
			textLabel = new TextField();
			
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			
			textLabel.antiAliasType = AntiAliasType.ADVANCED;
			textLabel.multiline = settings.multiline;
			textLabel.embedFonts = true;
			textLabel.sharpness = 100;
			textLabel.thickness = 50;
			//textLabel.border = true;  // закомментировано

			textLabel.text = settings.caption;
			
			if (App.isSocial('NK','HV')&&(App.lang == 'pl'||App.lang == 'nl')/*App.isSocial('NK','HV')*/ /*&& (App.lang == 'pl'||App.lang == 'nl')*/ /*&& App.reserveFont && !App.defaultFont.hasGlyphs(text)*/ && textLabel.text.search(/[\^\s0-9a-zA-Z€€aąbcćdeęfghijкklłmnńoóprsśtuwyxzźżAĄBCĆDEĘFGHIJКKLŁMNOÓPRSŚTUWYXZŹŻ\…\.,_\/\-\|\{\}\[\]\+\)\(\*\&\?\>\<\:\;\%\$\#\@\!\"\']/) != -1) {
				settings.fontFamily = App.reserveFont.fontName;
				settings.fontSize *= 0.75;
			}
			
			/*if (App.isSocial('NK','HV')  && textLabel.text.search(/[€ąćęflłńóśźż€ĄĆĘŁÓŚŹŻ']/) != -1) {
				settings.fontFamily = App.reserveFont.fontName;
				settings.fontSize *= 0.75;
			}*/
			
			if (textLabel.text.indexOf('€GB') >= 0) {
				settings.fontFamily = App.reserveFont.fontName;
				settings.fontSize *= 0.75;
			}
			if (textLabel.text.indexOf('€' ) >= 0) {
				settings.fontFamily = App.reserveFont.fontName;
				settings.fontSize *= 0.75;
			}
			style = new TextFormat(); 
			style.color = settings.fontColor; 
			if(settings.multiline){
				style.leading = settings.textLeading; 
			}
			style.size = settings.fontSize;
			style.font = settings.fontFamily;
			switch(settings.textAlign) {
				case "left": style.align = TextFormatAlign.LEFT; break;
				case "center": style.align = TextFormatAlign.CENTER; break;
				case "rigth": style.align = TextFormatAlign.RIGHT; break;
			}			
			textLabel.setTextFormat(style);
			
			
			textFilter = new GlowFilter(settings.fontBorderColor, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
			var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,settings.fontBorderColor,0.9,2,2,2,1);
			textLabel.filters = [textFilter, shadowFilter];	
			
			if (textLabel.textWidth + 8 > settings.width ) {
				textLabel.wordWrap = true;
				textLabel.multiline = true;
			}
			var fontSize:int = settings.fontSize;
			while (textLabel.textHeight>settings.height) 
			{
				fontSize--;
				style.size = fontSize;
				textLabel.setTextFormat(style);
			}
			//textLabel.width = textLabel.textWidth + 8;
			textLabel.width = textLabel.textWidth + 8;
			textLabel.height = textLabel.textHeight + 4;//settings.height;
			textLabel.y = (settings.height - textLabel.textHeight) / 2 - 2 + settings.captionOffsetY;
			textLabel.x = (settings.width - textLabel.width) / 2;
			bttnY = textLabel.y;
			//textLabel.border = true;
			topLayer.addChild(textLabel);
			
			/*if(textLabel.text.length > 0){
				fitTextInWidth(settings.width);
			}*/
			
			addChild(topLayer);
			if (settings.hasDotes)
				topLayer.x = 10;
		}
		
					
		public function disable():void 
		{
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(0);
			this.filters = [mtrx.filter];
			this.mouseChildren = false;
		}
		
		public function enable():void {
			this.filters = [];
			//this.mouseChildren = true;
			redrawBottomLayer();
			//effect(0,1);
		}
		
		public function active():void {
			//effect(0.2, 1.5);
			//redrawBottomLayer();
			
			removeChild(bottomLayer);
			bottomLayer = new Sprite();
			drawDownBottomLayer();
			//effect(0,0.5);
		}
		
		private function setEvents():void {
			addEventListener(MouseEvent.MOUSE_OVER, MouseOver, false, 100);
			addEventListener(MouseEvent.MOUSE_OUT, MouseOut);
			addEventListener(MouseEvent.MOUSE_DOWN, MouseDown);
			addEventListener(MouseEvent.MOUSE_UP, MouseUp);
			
			//Назначаем события
			if (onClick != null) {
				//trace('onClick in Button')
				this.addEventListener(MouseEvent.CLICK, onClick);
			}
			
			this.addEventListener(MouseEvent.CLICK, onBeforeClick, false, 500);
		}
		
		public function setEvent(event:*, callback:Function):void {
			this.addEventListener(event, callback);
		}
		
		protected function MouseOver(e:MouseEvent):void {
			if(mode == Button.NORMAL){
				effect(0.1);
			}
			//new Effect("Particles", this, {});
		}
		
		protected function MouseOut(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				effect(0, 1);
				removeChild(bottomLayer);
				bottomLayer = new Sprite();
				drawBottomLayer();
			}
		}
		
		protected function MouseDown(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				
				SoundsManager.instance.playSFX(settings.sound);
				removeChild(bottomLayer);
				bottomLayer = new Sprite();
				drawDownBottomLayer();
				effect(0,0.6);
				if(onMouseDown != null){
					onMouseDown(e);
				}					
			}
		}
		
		protected function MouseUp(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				//effect(0.1);
				removeChild(bottomLayer);
				bottomLayer = new Sprite();
				drawBottomLayer();
				if(onMouseUp != null){
					onMouseUp(e);
				}
			}
		}	
		
		public function effect(count:Number, saturation:Number = 1):void {
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(saturation);
			mtrx.brightness(count);
			bottomLayer.filters = [mtrx.filter];
		}
		
	
		private function onBeforeClick(e:MouseEvent):void 
		{
			if (QuestsRules.cantPress(this))
				e.stopImmediatePropagation();
				if (!priceCount)
				reask = true;
			if (!App.user.quests.tutorial && App.isJapan())
			{
				if (!reask && this.settings.type != "seaStone" && this.settings.type != "eventCoin" && ((this is MoneySmallButton) || (this is MoneyButton) || (this is Button && (this.settings.hasOwnProperty('diamond')))))  {
					reaskWindow();
					e.stopImmediatePropagation();
				}else {
					reask = false;
				}
			}
		}
		private function get priceCount():int
		{
			var count:int = 0;
			if (this is MoneySmallButton) {
				count = (this as MoneySmallButton).settings.countText;
			}else if (this is MoneyButton) {
				count = int((this as MoneyButton).countLabel.text);
			} else if (this is Button) {
				count = (this as Button).settings.countText;
			}
			return count;
		}
		
		private function reaskWindow():void {
		
			var that:* = this;
			new PaymentConfirmWindow({
				mID:this.settings.mID,
				title:Locale.__e('flash:1448372607635'),//Оплата
				text:Locale.__e('flash:1448458936727'),
				popup:true,
				count:[String(priceCount)],
				confirm:function():void {
					reask = true;
					that.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				}
			}).show();
		}
		public function initHotspot():void {
			//setInterval(makeHotspot, 2000);
		}
		
		private function makeHotspot():void 
		{
			var hotspot:Shape = new Shape();
			hotspot.graphics.beginFill(0xFFFF00, 1);
			hotspot.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFF00, 0xFFFFFF], [0, 1,0], [0,100]);
			hotspot.graphics.drawRect(0, 0, 20, this.height);
			hotspot.graphics.endFill();
			addChild(hotspot);
			hotspot.blendMode = BlendMode.SCREEN;
			hotspot.x = 0;//-this.width / 2;
			hotspot.y = 0;
			
			TweenLite.to(hotspot, 1.5, { x:this.width, ease:Strong.easeIn, onComplete:function():void {
				removeChild(hotspot);
			}});
		}
		
		public function fant(params:Object = null):void {
			fantImage = new Bitmap();
			Load.loading(Config.getIcon('Material','diamond'), function (data:Bitmap):void 
			{
				fantImage.bitmapData = data.bitmapData;
				fantImage.scaleX = fantImage.scaleY = 0.5;
				fantImage.smoothing = true;
				fantImage.x = (settings.width - (fantImage.width + textLabel.textWidth + 8)) / 2 - 4;
				fantImage.y = settings.height * 0.5 - fantImage.height * 0.5;
				textLabel.autoSize = 'left';
				textLabel.x = fantImage.x + fantImage.width + 8;
			
				if (fantImage && !topLayer.contains(fantImage))
				topLayer.addChild(fantImage);
			});
			
		}
	}
}