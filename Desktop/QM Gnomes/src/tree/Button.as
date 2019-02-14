package tree 
{
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import tree.filter.ColorAdjust;
	
	public class Button extends LayerX
	{
		
		public static const DISABLED:int 	= 0;
		public static const NORMAL:int 		= 1;
		public static const ACTIVE:int 		= 2;
		
		//Визуальные свойства
		public var settings:Object			= {
			
			// Подложка
			width:					150,					//Ширина
			height:					42,						//Высота
			radius:					20,						//Радиус скругления
			bgColor:				[0xf5cf57,0xeeb431],	//Цвета градиента
			borderColor:			[0xbcbaa6,0xbcbaa6],	//Цвета градиента
			bevelColor:				[0xfeee7b,0xbf7e1a],	
			fontColor:				0xffffff,				//Цвет шрифта
			fontBorderColor:		0x814f31,				//Цвет обводки шрифта		
			// Текст
			fontSize:				30,						//Размер шрифта
			
			textLeading:			-8,						//Вертикальное расстояние между словами	
			
			fontBorderSize:			3,						//Размер обводки шрифта
			fontBorderGlow:			2,						//Размер размытия шрифта
			caption:				Locale.__e("flash:1382952379714"),			//Текст кнопки
			//fontFamily:				"BrushType-SemiBold",	//Шрифт
			fontFamily:				"font",	//Шрифт
			textAlign:				"center",				//Расположение текста
			multiline:				false,					//Многострочный текст
			
			shadow:					true,					//Тень
			worldWrap:				false,					//Тень
			filters:				null,					//Дополнительные фильтры
			hasDotes:				false,
			greenDotes:				false,
			grayDotes:				false,
			isMoneyBttn:			false,
			price:					0,
			active: {
				bgColor:				[0xad9765,0xd1be88],	//Цвета градиента
				borderColor:			[0x8b7a51,0x8b7a51],	//Цвета градиента
				bevelColor:				[0x8b7a51,0xded4bf],	
				fontColor:				0xffffff,				//Цвет шрифта
				fontBorderColor:		0x7a683c				//Цвет обводки шрифта		
			},
			
			sound:'sound_1v2'
		}
		//Состояние кнопки
		public var mode:int					= NORMAL;				//Состояние кнопки: true - активное, false - пассивное
		
		//События
		public var onMouseDown:Function		= null;							//Нажатие кнопки мыши
		public var onMouseUp:Function		= null;							//Отпускание кнопки мыши
		public var onClick:Function			= null;							//Клик
		
		//Приватные свойства
		public var bottomLayer:Sprite 		= new Sprite;		//Нижний слой (кнопка)
		public var topLayer:Sprite			= new Sprite;		//Слой с текстом
		
		public var textLabel:TextField;
		public var style:TextFormat;
		public var textFilter:GlowFilter;
		
		public var __tween:* = null;
		
		public var order:int = 0;
		
		public var bttnY:Number;
			
		/**
		 * Конструктор
		 * @param	settings	пользовательские настройки кнопки
		 */
		public function Button(settings:Object = null)
		{
			//Переназначаем дефолтные настройки на пользовательские
			for (var property:* in settings) {
				this.settings[property] = settings[property];
				if (property == 'onClick') {
					this[property] = settings[property];
				}
			}
			draw();
			this.cacheAsBitmap = true;
			this.buttonMode = true
			
			if (settings == null) {
				settings = { };
			}
			
			if (settings['tip'] && settings.tip is Object) {
				tip = function():Object { return settings.tip };
			}
			
			name = settings['name'] || name;
			onMouseDown = settings.onMouseDown;
			
			mouseChildren = false;
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
			if (onClick != null) {
				removeEventListener(MouseEvent.CLICK, onClick);
			}
			
			onMouseUp = null;
			onMouseDown = null;		
			
			//if (this.hasEventListener(MouseEvent.CLICK)) {
				//onClick = null;
			//}
			
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
		}
		
		public function set state(mode:int):void {
			
			this.mode = mode;
			
			switch(mode) {
				case Button.DISABLED:  disable(); break;
				case Button.NORMAL:  enable(); break;
				case Button.ACTIVE:  active(); break;
			}
		}

		private function draw():void {
			drawBottomLayer();
			drawTopLayer();
			setEvents();
			
			this.state = mode;
		}
		
		private function redrawBottomLayer():void
		{
			removeChild(bottomLayer);
			bottomLayer = new Sprite();
			drawBottomLayer();
			
			if (style == null) return;
			
			if (mode == Button.ACTIVE) {
				
				style.color = 0xf0e6c1;
				textFilter = new GlowFilter(0x7b5909, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
				//textLabel.filters = [textFilter];	
			}else{
				
				style.color = settings.fontColor; 
				textFilter = new GlowFilter(settings.fontBorderColor, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
				//textLabel.filters = [textFilter];	
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
				bg.graphics.lineStyle(0x000000, 0, 0, true);	
				bg.graphics.beginGradientFill(gradType, bgColors, alphas, ratios, matrix);
				bg.graphics.drawRoundRect(2, 2, settings.width-4, settings.height-4, settings.radius, settings.radius);
				bg.graphics.endFill();
				bg.filters = [new BevelFilter(2, 90, settings.bevelColor[0], 1, settings.bevelColor[1], 1, 0, 0, 1, 1)];
			
			var shadow:Sprite = new Sprite();
				shadow.graphics.lineStyle(0x000000, 0, 0, true);
				shadow.graphics.beginFill(0x000000, 0.2);
				shadow.graphics.drawRoundRect(0, 0, settings.width, settings.height, settings.radius+6);
				shadow.graphics.endFill();
				
			if (!settings.shadow)	
			{
				shadow.height -= 5;
				shadow.y +=4;
			}
			
			bottomLayer.addChild(shadow);
			bottomLayer.addChild(bg);
			
			addChildAt(bottomLayer, 0);
			
			if(style){
				style.color = settings.fontColor; 
				textLabel.setTextFormat(style);
			}
			
			if (textLabel) {
				textFilter = new GlowFilter(settings.fontBorderColor, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
				var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,settings.fontBorderColor,0.9,2,2,2,1);
				textLabel.filters = [textFilter, shadowFilter];
				//textLabel = 200;
			}
			
			if (settings.hasDotes) {
				if (settings.greenDotes) {
					var dot1:Bitmap = new Bitmap(Textures.textures['dotGreen']);
					var dot2:Bitmap = new Bitmap(Textures.textures['dotGree']);
				}else if (settings.grayDotes) {
					dot1 = new Bitmap(Textures.textures['dotGray']);
					dot2 = new Bitmap(Textures.textures['dotGray']);
				}else {
					dot1 = new Bitmap(Textures.textures['dotYellow']);
					dot2 = new Bitmap(Textures.textures['dotYellow']);
				}
				
				dot1.smoothing = true;
				dot2.smoothing = true;
				bottomLayer.addChild(dot1);
				bottomLayer.addChild(dot2);
				
				bottomLayer.x += 10;
				dot1.x = -10;
				dot2.x = bg.width + 5;
				dot1.y = dot2.y = (bottomLayer.height - dot1.height) / 2;
				//drawDotes();
			}
		}	
		
		//public function drawDotes():void {
			//
				//var dot1:Bitmap = new Bitmap(Window.textures.dot);
				//var dot2:Bitmap = new Bitmap(Window.textures.dot);
				//dot1.smoothing = true;
				//dot2.smoothing = true;
				//bottomLayer.addChild(dot1);
				//bottomLayer.addChild(dot2);
				//
				//bottomLayer.x += 10;
				//dot1.x = -10;
				//dot2.x = bottomLayer.width + 5;
				//dot1.y = dot2.y = (bottomLayer.height - dot1.height) / 2;
		//}
		
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
				bg.filters = [new BevelFilter(2, 90, settings.active.bevelColor[0], 1, settings.active.bevelColor[1], 1, 0, 0, 1, 1)];
			
			var shadow:Sprite = new Sprite();
				shadow.graphics.lineStyle(0x000000, 0, 0, true);
				shadow.graphics.beginFill(0x000000, 0.2);
				shadow.graphics.drawRoundRect(0, 0, settings.width, settings.height, settings.radius+6);
				shadow.graphics.endFill();
				
			bottomLayer.addChild(shadow);
			bottomLayer.addChild(bg);
			
			addChildAt(bottomLayer, 0);
			
			if (!settings.shadow)	
			{
				shadow.height -= 5;
				shadow.y +=4;
			}
			
			if(style){
				style.color = settings.active.fontColor; 
				textLabel.setTextFormat(style);
			}
			if(textLabel){
				textFilter = new GlowFilter(settings.active.fontBorderColor, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
				var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,settings.active.fontBorderColor,0.9,2,2,2,1);
				textLabel.filters = [textFilter, shadowFilter];
			}
			if (settings.hasDotes) {
				bottomLayer.x = 10;
			}
		}	
		
		public var descent:uint = 15;
		protected function drawTopLayer():void {
			
			
			textLabel = new TextField();
			
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			
			textLabel.antiAliasType = AntiAliasType.ADVANCED;
			textLabel.multiline = settings.multiline;
			textLabel.embedFonts = true;
			textLabel.sharpness = 100;
			textLabel.thickness = 50;
			//textLabel.border = true;

			textLabel.text = settings.caption;
			
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
			

			
			//textLabel.width = textLabel.textWidth + 8;
			textLabel.width = settings.width;
			textLabel.height = textLabel.textHeight + 4;//settings.height;
			//textLabel.border = true;
			textLabel.y = (settings.height - textLabel.textHeight) / 2 - 2;
			//textLabel.x = (settings.width - textLabel.width) / 2;
			textLabel.x = 0;
			bttnY = textLabel.y;
			topLayer.addChild(textLabel);
			
			if(textLabel.text.length > 0){
				fitTextInWidth(settings.width);
			}
			
			
			addChild(topLayer);
			if (settings.hasDotes)
				topLayer.x = 10;
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
						//textLabel.x = (settings.width - textLabel.width) / 2;
						textLabel.x = 0;
					}
				}
			}else {
				if (textLabel.textWidth + 8 > maxWidth && settings.multiline) {
					textLabel.wordWrap = true;
					textLabel.multiline = true;
				}
			}
		}
		
		public function set caption(text:String):void {
			textLabel.text = text;
			textLabel.setTextFormat(style);
			textLabel.x = (settings.width - textLabel.width) / 2;
			textLabel.y = (settings.height - textLabel.textHeight) / 2;
		}
			
		public function get caption():String {
			return textLabel.text;
		}
					
		public function disable():void {
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
		
		//protected function onBeforeClick(e:MouseEvent):void 
		//{
			//
		//}
		
		private var reask:Boolean = false;

		protected function onBeforeClick(e:MouseEvent):void {

			
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
		
		private var fantImage:Bitmap;
		public function fant(params:Object = null):void {
			fantImage = new Bitmap(Textures.textures['fantsIcon'], 'auto', true);
			fantImage.scaleX = fantImage.scaleY = 0.9;
			fantImage.x = (settings.width - (fantImage.width + textLabel.textWidth + 8)) / 2 - 4;
			fantImage.y = settings.height * 0.5 - fantImage.height * 0.5;
			textLabel.autoSize = 'left';
			textLabel.x = fantImage.x + fantImage.width + 8;
			
			if (fantImage && !topLayer.contains(fantImage))
				topLayer.addChild(fantImage);
		}
	}
}