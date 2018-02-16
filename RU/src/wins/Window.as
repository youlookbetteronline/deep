package wins 
{
	import buttons.ImageButton;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import com.greensock.*
	import com.greensock.easing.*
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.text.TextFormatAlign;
	import flash.filters.GlowFilter;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	import core.Load;
	import ui.Cursor;
	import ui.UserInterface;
	import units.Unit;
	
	
	public class Window extends LayerX
	{
		public static const DISABLED:int = 0;
		public static const ENABLED:int = 1;
		
		public static var fontScale:Number =1;
		
		public static var textures:Object;
		private var showAfterLoad:Boolean = false; 
		private var textFilter:GlowFilter;
		private var shadowFilter:BlurFilter;
		
		//Вуальные свойства flash:1382952379993
		public var id:String						= '';					//Идентификатор окна
		public var opened:Boolean 					= false;
		public var settings:Object					= {
			content				: new Array(),
			type				: 'normal',				//Тип окна
			title				: '',			//Заголовок окна
			titleScaleX			: 1,
			titleScaleY			: 1,
			multiline			: false,				//Многострочный текст
			fontSize			: 48,					//Размер шрифта
			fontColor	 		: 0xfbfbf1,				//Цвет шрифта	
			textLeading	 		: -3,					//Вертикальное расстояние между словами	
			fontBorderColor 	: 0x7e3e14,				//Цвет обводки шрифта	
			fontBorderSize 		: 2,					//Размер обводки шрифта
			fontBorderGlow 		: 2,					//Размер размытия шрифта
			//fontFamily		: 'BrushType-SemiBold',		//Шрифт
			fontFamily			: 'font',		//Шрифт
			titlePading			: 140,
			
			background			: "capsuleWindowBacking",	
			hasPaper			: false,
			hasTitle			: true,
			hasRibbon			: true,
			ribbon				: 'ribbonGrenn',
			
			autoClose			: false,				//Авто flash:1382952379984крытие окна при открытие другого
			forcedClosing		: false,				//Принудительное flash:1382952379984крытие окна 
			strong				: false,				//Принудительно не может быть flash:1382952379984крыто
			popup				: false,				//Всплывающее окно
			escExit				: true,					//Закрытие окна по Esc
			
			hasPaginator		: true,					//Окно с пагинацией
			hasButtons			: true,					//Окно со стрелками влево, вправо
			paginatorSettings 	: {},					//Настройки пагинатора
			
			hasArrows			: true,					//Окно со стрелками влево, вправо
			itemsOnPage			: 6,					//Кол-во итемов на странице
			buttonsCount		: 3,					//Кол-во кнопок в пейжинаторе
			hasFader			: true,					//Окно с подкладкой			
			faderClickable		: true,					//Окно с подкладкой			
			faderAlpha			: 0.5,					//Прозрачность фейдера
			hasAnimations		: true,					//Окно с анимацией при открытии и flash:1382952379984крытии
			hasExit				: true,					//Показывать кнопку flash:1382952379984крытия окна
			hasBubbles			: false,				//Пузырьки вкл/выкл
			bubblesSpeed		: 1,					//Скорость пузыря
			bubblesCount		: 6,					//Количество пузырьков
			bubbleRightX		: 0,					//Смещение правых пузырьков
			bubbleLeftX			: 0,					//Смещение левых пузырьков
		
			animationShowSpeed	: 0.3,					//Скорость анимации появления окна
			animationHideSpeed	: 0.1,					//Скорость анимации flash:1382952379984крытия окна
		
			faderAsClose		: true,					//Клик по подкладке flash:1382952379984крывает окно
			autoClose			: false,				//При открытии другого окна это flash:1382952379984крывается автоматически
			delay				: 200,					//Задержка при открытии окна в милисекундах
		
			currentPage			: 1,					//Текущая страница
		
			width				: 500,					//Ширина контейнера с окном
			height				: 500,					//Длина контейнера с окном	
			
			paperHeight			: 0,
			paperWidth			: 0,
						
			debug				: false,					//В Debug режиме отображаются рамки контейнера
			
			returnCursor		: true,
			hasDescription		: false,
			faderColor			: 0x000000,
			faderTime			: 0.3,
			
			openSound 			:'sound_3',
			closeSound 			:'sound_4',
			
			exitTexture 		:'closeBttn',
			
			offsetY				:0,
			offsetX				:0,
			point				:null
			
			//exitType			: Window.EXIT_DEFAULT
		};
		
		public static var DEBUG:Boolean = false;// вкл/выкл дебаг режим для текста.
		
		//Части окна
		public var exit:ImageButton					= null;
		private var titleContainer:Sprite			= null;
		public var backgroundContainer:Sprite		= new Sprite();
		public var headerContainer:Sprite			= new Sprite();
		public var headerContainerSplit:Sprite		= new Sprite();
		public var contentContainer:Sprite			= new Sprite();
		
		public var bodyContainer:Sprite				= new Sprite();
		public var bottomContainer:Sprite			= new Sprite();
		

		public var paginator:Paginator				= null;					//Объект Пагинатор
		public var layer:Sprite 					= new Sprite();			//Объект Фейдер
		public var fader:Sprite 					= null;			 		//Объект Фейдер
		
		public var content:*;													//Контент окна 
		
		protected var titleBar:Bitmap;
		protected var titleLabel:Sprite;
		protected var style:TextFormat;
		public var _bitmap:Bitmap = null;
		
		public var params:Object;
		
		public function Window(settings:Object = null) 
		{
			//Переназначаем дефолтные настройки на пользовательские
			//App.user.data.tempWorlds
			for (var property:* in settings) 
			{
				this.settings[property] = settings[property];
			}
			
			if (!this.settings['point'])
				this.settings['point'] = new Point(0, 0);
				
			trace(this);
			Log.alert('opened '+this);
			
			App.self.setOnEnterFrame(bubblesFly);
			
		}
		
		private function onLoad(data:*):void 
		{
			textures = data;
			
			if (showAfterLoad) 
			{
				showAfterLoad = false;
				show();
			}
		}
		
		public static function hasType(type:Class):Boolean 
		{
			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) 
			{
				var window:* = App.self.windowContainer.getChildAt(i);
				if (window is type)
					return true;
			}
			
			return false;
		}
			
		public static function centerOn(sub:*, on:*):void 
		{
			sub.x = on.x + (on.width - sub.width) / 2;
			sub.y = on.y + (on.height - sub.height) / 2;
		}
		
		public static function get isOpen():* 
		{
			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) 
			{
				var window:* = App.self.windowContainer.getChildAt(i)
				if (window is Window && window.opened == true)
					return window;
			}
			
			return false;
		}
		public static function isClass(clss:Class):* 
		{
			var window:* = null;
			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) 
			{
				window = App.self.windowContainer.getChildAt(i);
				if (window is clss && window.opened == true) 
				{
					return window as clss;
				}
			}
			return null;
		}
		public static function localToGlobal(object:*):Point
		{
			//var X:int = object.x + object.parent.x + object.parent.win.layer.x + object.width/2;
			//var Y:int = object.y + object.parent.y + object.parent.win.layer.y;
			var X:int = App.self.mouseX - object.mouseX + object.width/2;
			var Y:int = App.self.mouseY - object.mouseY;
			return new Point(X, Y);
		}
		
		public static function createdWindowType(type:*, content:*):Boolean 
		{
			
			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) 
			{
				var window:* = App.self.windowContainer.getChildAt(i)
				if (window is Window) 
				{
					////trace(getQualifiedClassName(window))
						if (window.settings[type] != null && window.settings[type] == content)
						{
							return true
						}
				}
			}
			return false
		}
		
		public static function texture(texture:String):BitmapData 
		{
			if (Window.textures.hasOwnProperty(texture)) 
			{
				return Window.textures[texture];
			}else if (UserInterface.textures.hasOwnProperty(texture)) 
			{
				return UserInterface.textures[texture];
			}
			return new BitmapData(1, 1, true, 0);
			}
			
		public function show():void 
		{
			if (App.map != null) 
			{
				for each(var trans:Unit in App.map.transed) 
				{
					var bmp:Bitmap = trans.bmp;
					
					trans.transparent = false;
					App.map.transed.splice(App.map.transed.indexOf(trans), 1);
				}
			}
			
			if(App.map != null){
				App.map.untouches();
				
				if (App.map.moved != null) 
				{
					App.map.moved.previousPlace();
				}
			}
			
			App.tips.hide();
			
			//if (Cursor.type != "default") {
			Cursor.prevType = Cursor.type;
				Cursor.type = "default";
			//}
			Cursor.plant = false;
			
			if (App.ui != null)
			{
				App.ui.bottomPanel.cursorsPanel.visible = false;
			}
			//trace(Cursor.prevType);
			if (textures == null) 
			{
				showAfterLoad = true;
				return;
			}
			
			
			//try{
			var hasQueue:Boolean = false;
			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++)
			{
				var backWindow:* = App.self.windowContainer.getChildAt(i);

				if (backWindow is Window && (settings.forcedClosing == true || backWindow.settings.autoClose == true)) 
				{
					if (backWindow is LevelUpWindow) 
					{
						hasQueue = true;
						return;
					}else if (backWindow is OracleWindow) 
					{ 
						hasQueue = true;
						return;
					}else if (backWindow.settings.strong) 
					{
						hasQueue = true;
						//return;
					}else if ((backWindow is AchivementMsgWindow))
					{
						backWindow.close();
						//hasQueue = true;
					}else if (settings.popup) 
					{ 
						backWindow.close();
					}else 
					{
						//backWindow.close();
						hasQueue = true;
					}
				}else if (backWindow is Window && !(backWindow is AchivementMsgWindow)  &&  settings.popup == false) 
				{
					hasQueue = true;
				}
			}
			
			App.self.windowContainer.addChild(this);
			layer.visible = false;
			addChild(layer);
			if (hasQueue == true) 
			{
				return;
			}
			create();
			SoundsManager.instance.playSFX(settings.openSound);
			
		}
		
		/**
		 * Добавляем окно на сцену
		 * @param	e	Event
		 */
		private function onAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			this.visible = false;
			create();
		}
	
		public function drawFader():void 
		{
			if (fader == null && settings.hasFader) 
			{
				fader = new Sprite();
					
				fader.graphics.beginFill(settings.faderColor);
				fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
				fader.graphics.endFill();
				
				addChildAt(fader, 0);
				
				fader.alpha = 0;
				
				var finishX:Number = (App.self.stage.stageWidth - settings.width) / 2;
				var finishY:Number = (App.self.stage.stageHeight - settings.height) / 2;
				
				TweenLite.to(fader, settings.faderTime, { alpha:settings.faderAlpha } );
			}
		}
		
		protected function onFaderClick(e:MouseEvent):void {
			
			if (App.user.quests.track && App.user.quests.currentTarget != null) {
				return;
			}
			
			if(fader.hasEventListener(MouseEvent.CLICK)){
				fader.removeEventListener(MouseEvent.CLICK, onFaderClick);
			}
			if (!settings.faderAsClose)
				return;
			
			if(settings.faderClickable == true){
				close();
			}
		}
		
		/**
		 * Отрисовываем окно, при необходимости запускаем анимацию появления окна
		 */
		
		protected var clearQuestsTargets:Boolean = false;
		public function create():void 
		{
			
			opened = true;
				
			if (Quests.help) 
			{
				clearQuestsTargets = true;
			}
		
			dispatchEvent(new WindowEvent( "onBeforeOpen"));
			
			dispatchEvent(new WindowEvent( "onContentRequest"));
			
			drawFader();
			drawHeader();
			drawBottom();
			drawBackground();
			drawBody();
			
			if (settings.hasBubbles)
			{
				drawBubbles();
				this.addEventListener(MouseEvent.MOUSE_MOVE, moveBubbleParallax)
			}			
			
			layer.addChild(bodyContainer);
			layer.addChild(contentContainer);
			layer.addChild(headerContainer);
			layer.addChild(headerContainerSplit);
			
			//headerContainer.y = - (headerContainer.height - 18*settings.titleScaleY) / 2;
			
			
			if (settings.hasTitle)
			{
				bodyContainer.y = headerContainer.height / 2;
			}
			
			
			layer.addChild(bottomContainer);
			
			if (settings.debug) 
			{
				debug(headerContainer, 0x00FF00);
				debug(bottomContainer, 0xCCCCCC);
				debug(bodyContainer, 0xFF0000);
				debug(headerContainerSplit, 0xFFCC00);
				
			}
			
			if (settings.hasPaginator && settings.hasArrows)
			{
				drawArrows();
			}
			//drawFader();
			
			this.stage.addEventListener(Event.RESIZE, onRefreshPosition);
			
			if (settings.hasAnimations == true) 
			{/*
				if (settings.delay)
				{
					setTimeout(startOpenAnimation, settings.delay);
				}else 
				{
					startOpenAnimation();
				}*/
				startWithoutAnimation();
			}else 
			{
				this.visible = true;
				layer.x = (App.self.stage.stageWidth - settings.width) / 2 + settings.point.x;
				layer.y = (App.self.stage.stageHeight - settings.height) / 2 + settings.point.y;
				//layer.x = App.self.stage.stageWidth / 2 - settings.width / 2
				//layer.y = App.self.stage.stageHeight / 2 - settings.height / 2
				layer.visible = true;
				
				fader.addEventListener(MouseEvent.CLICK, onFaderClick);
					
				dispatchEvent(new WindowEvent("onAfterOpen"));
			}
			
			if (settings.debug) 
			{
				debug(this,0x0000FF);
			}
		
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		
		protected function onKeyDown(e:KeyboardEvent):void 
		{
			if (Number(e.keyCode.toString()) == 27 && settings.escExit == true) 
			{
				
				if (App.user.quests.currentTarget != null) 
				{
					return;
				}
				
				close();
			}
		}
		
		public function dispose():void 
		{
			if(cTween != null){
				cTween.complete(true, true);
				cTween.kill();
				cTween = null;
			}
			if (fader != null && fader.hasEventListener(MouseEvent.CLICK)) 
			{
				fader.removeEventListener(MouseEvent.CLICK, onFaderClick);
				fader = null;
			}
			
			if (this.stage != null)
			{
				this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				this.stage.removeEventListener(Event.RESIZE, onRefreshPosition);
			}
			if (settings){
				if (settings.hasExit && exit)
				{
					exit.removeEventListener(MouseEvent.CLICK, close);
				}
				
				if (settings.hasPaginator && paginator != null) 
				{
					paginator.dispose();
				}
			
				if (settings.hasBubbles)
				{
					this.removeEventListener(MouseEvent.MOUSE_MOVE, moveBubbleParallax)
				}
			}
			if (this.parent != null) 
			{
				this.parent.removeChild(this);
			}else 
			{
				if (App.self.windowContainer.contains(this))
				{
					App.self.windowContainer.removeChild(this);
				}
			}
			App.self.setOffEnterFrame(bubblesFly);

			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) 
			{
				var backWindow:* = App.self.windowContainer.getChildAt(i);

				if (backWindow is Window && !(backWindow is AchivementMsgWindow) && backWindow.opened == false) 
				{
					backWindow.create();
					break;
				}else if(backWindow is Window)
				{
					break;
				}
			}
			
			if (settings && settings.returnCursor && Cursor.type != "stock" && Cursor.type != "water")
			{
				Cursor.type = Cursor.prevType;
			}
			
			dispatchEvent(new WindowEvent("onAfterClose"));		
			if (clearQuestsTargets) 
			{
				Quests.help = false;
			}
			clearVariables();
		}
		
		public function close(e:MouseEvent = null):void {
			if (settings && settings.hasAnimations == true) 
			{
				startCloseAnimation();
			}else 
			{
				dispatchEvent(new WindowEvent("onBeforeClose"));
				dispose();
			}
		}
		
		public function clearVariables():void {
			return;
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
		
		public function contentChange():void 
		{
			
			
		}
		public static function drawCircleSegment(graphics:Graphics, center:Point, start:Number, end:Number, r:Number, h_ratio:Number = 1, v_ratio:Number = 1, new_drawing:Boolean = true):void
		{
			var x:Number = center.x;
			var y:Number = center.y;
			// first point of the circle segment
			if (new_drawing)
			{
				graphics.moveTo(x + Math.cos(start) * r * h_ratio, y + Math.sin(start) * r * v_ratio);
			}
			
			// draw the circle in segments
			var segments:uint = 8;
			
			var theta:Number = (end - start) / segments;
			var angle:Number = start; // start drawing at angle ...
			
			var ctrlRadius:Number = r / Math.cos(theta / 2); // this gets the radius of the control point
			for (var i:int = 0; i < segments; i++)
			{
				// increment the angle
				angle += theta;
				var angleMid:Number = angle - (theta / 2);
				// calculate our control point
				var cx:Number = x + Math.cos(angleMid) * (ctrlRadius * h_ratio);
				var cy:Number = y + Math.sin(angleMid) * (ctrlRadius * v_ratio);
				// calculate our end point
				var px:Number = x + Math.cos(angle) * r * h_ratio;
				var py:Number = y + Math.sin(angle) * r * v_ratio;
				// draw the circle segment
				graphics.curveTo(cx, cy, px, py);
			}
		}
		public function drawFooterImage(type:String):* 
		{
			
			/*var bg:Bitmap;
			switch(type) {
				case "stock"	: bg = new Bitmap(new StockFooter(),"auto",true); break;
				case "shop"		: bg = new Bitmap(new ShopFooter(),"auto",true); break;
				case "voodoo"	: bg = new Bitmap(new VoodooFooter(),"auto",true); break;
			}
			if(bg != null) {
				bg.scaleX = settings.width / bg.width;
				bg.scaleY = bg.scaleX;
				bg.x = 0;
				bg.y = settings.height - bg.height - headerContainer.height/2;
				return bg;
			}*/
			return false;
		}
		
		public function drawBackground():void 
		{
			if (settings.background!=null) 
			{
				var background:Bitmap = backing(settings.width, settings.height, 50, settings.background);
				layer.addChild(background);	
			}
			if (settings.hasPaper == true) 
			{
				var paper:Bitmap = Window.backing(settings.width - 76, settings.height - 76, 40, 'paperClear');
				paper.x = (background.width - paper.width) / 2;
				paper.y = (background.height - paper.height) / 2;
				layer.addChild(paper);
			}
		}
		
		public function decorateWith(decorItemName:String, margin:int = 0):void 
		{
			var bd:BitmapData = Window.textures[decorItemName];
			var yOffset:int = 10;
			drawMirrowObjs(decorItemName, margin, settings.width - margin , settings.height - bd.height - margin + yOffset);
			drawMirrowObjs(decorItemName, margin, settings.width - margin , bd.height + margin + yOffset, false, false, false, 1, -1);
		}
		
		public function decorateTitleWith(decorItemName:String):void 
		{
			var bd:BitmapData = Window.textures[decorItemName];
			var yOffset:int = 10;
			drawMirrowObjs(decorItemName,  (settings.width - settings.titleWidth) / 2 + 5, (settings.width + settings.titleWidth) / 2 - 5, bodyContainer.y - headerContainer.y + titleLabel.y + (titleLabel.height - 3*bd.height) / 2, true, true);
		}
		
		public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowSize			: settings.shadowSize,
				shadowColor			: settings.shadowColor,
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
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		private var bubblesContainer:Sprite = new Sprite();
		private var bubblesCoords:Object = new Object;
		private var bubblesVector:Vector.<Bitmap> = new Vector.<Bitmap>();
		
		public function drawBubbles():void 
		{
			bodyContainer.addChild(bubblesContainer);
			var bubble:Bitmap;
			//bubblesContainer.x = fader.x;
			//bubblesContainer.y = fader.y;
			
			var bubblesArray:Array = ['dailyBonusBubble1', 'dailyBonusBubble2', 'dailyBonusBubble1', 'dailyBonusBubble2', 'dailyBonusBubble3', 'dailyBonusBubble4', 'dailyBonusBubble5', 'dailyBonusBubble4', 'dailyBonusBubble5', 'dailyBonusBubble6'];
				
			for (var i:int = 0; i < Window.isOpen.settings.bubblesCount; i++) 
			{
				//var table:Object = this;//ТУТ
				var numm:int = Math.random() * bubblesArray.length;
				bubble = new Bitmap(Window.textures[bubblesArray[numm]]);
				if (i < Window.isOpen.settings.bubblesCount / 2){
					bubble.x = settings.bubbleLeftX + 20 - Math.random()*150;
				}else{
					bubble.x = settings.bubbleRightX +  settings.width - 20 + Math.random()*150;
				}
				bubble.y = Math.random()*settings.height;
				bubblesVector.push(bubble);
				bubblesContainer.addChild(bubblesVector[i]);
				bubblesVector[i].smoothing = true;
				bubblesVector[i].alpha = .7 + Math.random() * .3;
				
				bubblesCoords[i] = {x:bubble.x, y:bubble.y, speed:settings.bubblesSpeed / (bubble.width / 10) + Math.random() * .2};
			}
			
			bubbleParallax();
		}
		
		private function bubblesFly(e:* = null):void
		{
			if (!Window.isOpen)
				return;
			if (Window.isOpen.settings.hasBubbles == false)
				return;
			if (Numbers.countProps(bubblesCoords) <= 0 || bubblesVector.length < Window.isOpen.settings.bubblesCount)
				return;
			if (stage){	
				var heightDifference:Number = settings.height - stage.stageHeight;
				for (var i:int = 0; i < Window.isOpen.settings.bubblesCount; i++) 
				{	
					bubblesCoords[i].y -= bubblesCoords[i].speed;
					bubblesVector[i].y = bubblesCoords[i].y;
					if (bubblesVector[i].y + bubblesVector[i].height < heightDifference)
					{
						bubblesCoords[i].y = stage.stageHeight;//bubblesVector[i].y = stage.stageHeight;
						if (i < Window.isOpen.settings.bubblesCount / 2){
							bubblesCoords[i].x = settings.bubbleLeftX + 20 - Math.random()*150;
						}else{
							bubblesCoords[i].x = settings.bubbleRightX + settings.width - 20 + Math.random()*150;
						}
						bubbleParallax();
					}
				}
			}
			
		}
		
		private function moveBubbleParallax(e:MouseEvent):void
		{
			bubbleParallax();
		}
		
		private function bubbleParallax():void
		{
			if (!Window.isOpen)
				return;
			if (bubblesVector.length < Window.isOpen.settings.bubblesCount)
				return;
			var bias:Number;
			for (var i:int = 0; i < Window.isOpen.settings.bubblesCount; i++) 
			{
				bias = 1 / (bubblesVector[i].width * .002);
				if (i < Window.isOpen.settings.bubblesCount / 2){
					bubblesVector[i].x = (bubblesCoords[i].x) - bias / 2 + bias * (mouseX / stage.stageWidth);
				}else{
					bubblesVector[i].x = (bubblesCoords[i].x) - bias / 2 + bias * (mouseX / stage.stageWidth);
				}
				bubblesVector[i].scaleX = bubblesVector[i].scaleY = 0.7 + 0.3 * mouseY / stage.stageHeight;

				bubblesVector[i].x += (1 - bubblesVector[i].scaleX) * bubblesVector[i].width;
			}
		}
		
		protected var titleBackingBmap:Bitmap;
		protected function drawRibbon():void 
		{
			if (!settings.hasRibbon)
				return
			if (titleBackingBmap && titleBackingBmap.parent)
				titleBackingBmap.parent.removeChild(titleBackingBmap);
			if (titleLabel && titleLabel.parent)
				titleLabel.parent.removeChild(titleLabel);
			
			var ribWidth:int = settings.titleWidth + 180;
			if (ribWidth < 320)
				ribWidth = 320;
			titleBackingBmap = backingShort(ribWidth, settings.ribbon, true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -65;
			//titleBackingBmap.filters = [new GlowFilter(0xf3ff2c, .7, 11, 11, 3)];
			bodyContainer.addChild(titleBackingBmap);
			
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y - 4;
			
			bodyContainer.addChild(titleLabel);
		}
		
		public function drawExit():void 
		{
			exit = new ImageButton(textures[this.settings.exitTexture]);
			headerContainer.addChild(exit);
			exit.x = settings.width - 49;
			exit.y = 17;
			
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		public function drawHeader():void {
			if(settings.hasTitle){
				drawTitle();		
			}
			if (settings.hasExit == true) {
				drawExit();
			}
		}
		
		public function drawBody():void {
			

		}
		
		public static function slider(result:Sprite, value:Number, max:Number, bmd:String = "energySlider", useBacking:Boolean = false, backingWidth:int = 0):void {
			while (result.numChildren) {
				result.removeChildAt(0);
			}
			var slider:Bitmap;
			if (!useBacking) {
				slider = new Bitmap(textures[bmd]);
			}else {
				slider = Window.backingShort(backingWidth, bmd);
			}
			
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0x000000, 1);
			mask.graphics.drawRect(0, 0, slider.width, slider.height);
			mask.graphics.endFill();
			
			result.addChild(mask);			
			result.addChild(slider);
			
			slider.mask = mask;
			
			var percent:Number = value > max ? 1: value / max;
			var currentWidth:Number = slider.width * percent;
			
			mask.x = currentWidth - slider.width;
			mask.x = slider.x <= 0?mask.x:0;
		}
		
		public function drawMirrowObjs(texture:String, xPos:int, xPos2:int, yPos:int, selfPaddingLeft:Boolean = false, selfPaddingRight:Boolean = false, selfPaddingTop:Boolean = false, _alpha:Number = 1, scaleY:Number = 1 , container:Sprite = null, scaleX:Number = 1):void
		{
			//var btmLeft:Bitmap = new Bitmap(new BitmapData(1, 1, true, 0)/*textures[texture]*/);
			var a:BitmapData;
			var btmLeft:Bitmap;
			var btmRight:Bitmap;
			a = textures[texture];
			btmLeft = new Bitmap(textures[texture]);
			
			btmLeft.scaleY = scaleY;
			btmLeft.scaleX = scaleX;
			if (selfPaddingLeft) {
				btmLeft.x = xPos - btmLeft.width; 
			}else {
				btmLeft.x = xPos; 
			}
			if (selfPaddingTop) {
				btmLeft.y = yPos - btmLeft.height/2;
			}else {
				btmLeft.y = yPos;
			}
			
			//var btmRight:Bitmap = new Bitmap(new BitmapData(1,1,true,0)/*textures[texture]*/);
			btmRight = new Bitmap(textures[texture]);

			btmRight.scaleX = -scaleX;
			btmRight.scaleY = scaleY;
			
			if (selfPaddingRight) {
				btmRight.x = xPos2 + btmRight.width;
			}else{
				btmRight.x = xPos2;
			}
			if (selfPaddingTop) {
				btmRight.y = yPos - btmRight.height/2;
			}else {
				btmRight.y = yPos;
			}
			
			//if (texture == 'decSeaweed')
			//{
				if (container != null) {
					container.addChild(btmLeft);
					container.addChild(btmRight);
				}else {
					layer.addChildAt(btmLeft, 0);
					layer.addChildAt(btmRight, 0);
				}
				return;
			//}
			if (texture == 'decShell')
			{
				btmLeft.filters = [new DropShadowFilter(2.0, 90, 0, 0.8, 4.0, 4.0, 1.0, 3, false, false, false)];
				btmRight.filters = [new DropShadowFilter(2.0, 90, 0, 0.8, 4.0, 4.0, 1.0, 3, false, false, false)];
			}
			
			if (container != null) {
					container.addChild(btmLeft);
					container.addChild(btmRight);
				}else {
					bodyContainer.addChild(btmLeft);
					bodyContainer.addChild(btmRight);
				}
				
			btmLeft.alpha = _alpha;
			btmRight.alpha = _alpha;
		
		}
		
		public function drawHelp():ImageButton {
				var bttn:ImageButton = new ImageButton(Window.textures.bttn);
				var questionMark:TextField = Window.drawText('?', {
					fontSize:		36,
					border:			false,
					//borderColor:	0x776741,
					color:			0xFFFFFF,
					autoSize:		'center',
					filters:		[new DropShadowFilter(1,90,0x776741,1,0,0,1,1)]
				});
				
				questionMark.x = (bttn.width - questionMark.width) / 2 - 1;
				questionMark.y = (bttn.height - questionMark.height) / 2 + 3;
				bttn.addChild(questionMark);
				
				return bttn;
			}
		
		
		public function drawBottom():void {
			
			if(settings.hasPaginator == true){
				createPaginator();
			}
		}
		
		public function createPaginator():void {
			
			if (paginator) {
				if (paginator.hasEventListener(WindowEvent.ON_PAGE_CHANGE)) {
					paginator.removeEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);
				}
				if (paginator.parent){
					paginator.parent.removeChild(paginator);
					paginator = null;
				}
			}
			
			settings.paginatorSettings["hasArrow"] = settings.paginatorSettings.hasArrow || settings.hasArrow;
			settings.paginatorSettings["hasButtons"] = settings.paginatorSettings.hasButtons || settings.hasButtons;
			
			paginator = new Paginator(settings.content.length, settings.itemsOnPage, settings.buttonsCount, settings.paginatorSettings);
			paginator.x = int((settings.width - paginator.width) / 2);
			paginator.y = int(settings.height - paginator.height - 46);
			
			paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);
						
			bottomContainer.addChild(paginator);

		}
		
		public function drawArrows():void {
			
			//createPaginator();
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 26;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 26;
			paginator.arrowRight.y = y;
			
		}
		
		public function onPageChange(e:WindowEvent):void {
			//drawArrows();
			contentChange();
		}
		
		public function startWithoutAnimation():void 
		{			
			layer.x = (App.self.stage.stageWidth - settings.width) / 2 + settings.point.x;
			layer.y = (App.self.stage.stageHeight - settings.height) / 2 + settings.point.y;
			
			if(settings.hasTitle)
				layer.y += headerContainer.height / 4 + settings.point.y;
			
			layer.visible = true;
			layer.cacheAsBitmap = true;
			
			if (fader)
				fader.addEventListener(MouseEvent.CLICK, onFaderClick);
			dispatchEvent(new WindowEvent("onAfterOpen"));
		}
		public function startOpenAnimation():void 
		{
			var finishX:int = (App.self.stage.stageWidth - settings.width) / 2 + settings.point.x;
			var finishY:int = (App.self.stage.stageHeight - settings.height) / 2 + settings.point.y;
			
			if(settings.hasTitle)
				finishY += headerContainer.height / 4 + settings.point.y;
			
			layer.x = (App.self.stage.stageWidth - settings.width * .3) / 2;
			layer.y = (App.self.stage.stageHeight - settings.height * .3) / 2;
			
			layer.scaleX = layer.scaleY = 0.3;
			layer.visible = true;
			layer.cacheAsBitmap = true;
			
			TweenLite.to(layer, settings.animationShowSpeed, { x:finishX, y:finishY, scaleX:1, scaleY:1, ease:Strong.easeOut, onComplete:finishOpenAnimation } );
			//openAnimationTween = TweenLite.to(layer, settings.animationShowSpeed, { x:finishX, y:finishY, scaleX:1, scaleY:1, ease:Strong.easeOut, onComplete:finishOpenAnimation } );
		}
		
		public function finishOpenAnimation():void {
			if(fader)fader.addEventListener(MouseEvent.CLICK, onFaderClick);
			dispatchEvent(new WindowEvent("onAfterOpen"));
		}
		private var cTween:TweenLite;
		public function startCloseAnimation():void 
		{
			if (fader != null)
			{
				fader.visible = false;
			}
			cTween = TweenLite.to(layer, settings.animationHideSpeed, { alpha:0, onComplete:finishCloseAnimation } );
		}
		
		public function finishCloseAnimation():void 
		{
			dispose();
		}		
		
		public function debug(container:*, color:uint = 0x000000):void 
		{
			container.graphics.lineStyle(2, color, 1, true);
			container.graphics.drawRoundRect(2, 2, container.width, container.height, 10);
			container.graphics.endFill();
		}
		
		protected function onRefreshPosition(e:Event = null):void
		{ 		
			var stageWidth:int = App.self.stage.stageWidth;
			var stageHeight:int = App.self.stage.stageHeight;
			
			layer.x = (stageWidth - settings.width) / 2 + settings.point.x;
			layer.y = (stageHeight - settings.height) / 2 + settings.point.y;
			
			if (settings.hasTitle)
			{
				layer.y += headerContainer.height / 4 + settings.point.y;
				//layer.y += headerContainer.height;
			}
			
			if (fader)
			{
				fader.width = stageWidth;
				fader.height = stageHeight;
			}
		}
		
		public static function drawText(text:String, settings:Object = null):TextField {
			
			var defaults:Object = {
				color				: 0xdfdbcf,
				multiline			: false,				//Многострочный текст
				fontSize			: 19,					//Размер шрифта
				textLeading	 		: -3,					//Вертикальное расстояние между словами	
				borderColor 		: 0x000000,//0x5d5d5d,				//Цвет обводки шрифта	
				borderSize 			: 4,					//Размер обводки шрифта
				fontBorderGlow 		: 2,					//Размер размытия шрифта
				//fontFamily		: 'BrushType-SemiBold',		//Шрифт					
				fontFamily			: 'font',		//Шрифт					
				autoSize			: 'none',
				textAlign			: 'left',
				filters				: [],
				sharpness 			: 100,
				thickness			: 50,
				border				: true,
				letterSpacing		: 0,
				input				: false,
				width				: 0,
				wrap				: false,
				angleShadow			:	90,
				strenghtFilter		:	2,
				strenghtShadow		:	8,
				distShadow			:	1
			}
			
			if (settings == null) {
				settings = defaults;
			}else {
				for (var property:* in settings) {
					defaults[property] = settings[property];
				}
				settings = defaults;
			}
			
			if(App.lang == 'jp')
				settings.fontSize = int(settings.fontSize * 0.75);
			
			if (!text) text = '';
			
			var textLabel:TextField = new TextField();
			
			if(settings.input){
				textLabel.type = TextFieldType.INPUT;
				//textLabel.selectable = false;
				//textLabel.tabEnabled = true;
			}else{
				textLabel.mouseEnabled = false;
				textLabel.mouseWheelEnabled = false;
			}
			textLabel.antiAliasType = AntiAliasType.ADVANCED;
			textLabel.multiline = settings.multiline;
			
			switch(settings.autoSize){
				case "left": textLabel.autoSize = TextFieldAutoSize.LEFT; break;
				case "center": textLabel.autoSize = TextFieldAutoSize.CENTER; break;
				case "right": textLabel.autoSize = TextFieldAutoSize.RIGHT; break;
			}
			
			textLabel.embedFonts = true;
			textLabel.sharpness = settings.sharpness;
			textLabel.thickness = settings.thickness;
			//textLabel.border = true;
			
			var style:TextFormat = new TextFormat(); 
			style.color = settings.color; 
			style.letterSpacing = settings.letterSpacing;
			if(settings.multiline){
				style.leading = settings.textLeading; 
			}
			
			if (App.isSocial('VK','NK','HV') && text.search( /[€]/ ) != -1) {
					settings.fontFamily = App.reserveFont.fontName;
					settings.fontSize *= 0.75;
				}	
			if (text.indexOf('€GB') >= 0) {
				settings.fontFamily = App.reserveFont.fontName;
				settings.fontSize *= 0.75;
			}	
			if (textLabel.text.indexOf('€' ) >= 0) {
				settings.fontFamily = App.reserveFont.fontName;
				settings.fontSize *= 0.75;
			}
			style.size = settings.fontSize*fontScale*App._fontScale;
			style.font = settings.fontFamily;
			style.bold = settings.bold || false;
			switch(settings.textAlign) {
				case 'left': style.align = TextFormatAlign.LEFT; break;
				case 'center': style.align = TextFormatAlign.CENTER; break;
				case 'right': style.align = TextFormatAlign.RIGHT; break;
			}
			
			textLabel.defaultTextFormat = style;
			if (text == null) text = "";
			textLabel.text = text;
			
			textLabel.wordWrap = settings.wrap;
			
			var metrics:*;
			if (settings.width > 0) { 
				textLabel.width = settings.width;
				metrics = textLabel.getLineMetrics(0);
				if(text.length > 3 && textLabel.textWidth+metrics.descent > settings.width) {
					while (textLabel.textWidth + metrics.descent > settings.width) {
						settings.fontSize -= 1;
						style.size = settings.fontSize;
						textLabel.setTextFormat(style);
						metrics = textLabel.getLineMetrics(0);
						//textLabel.defaultTextFormat = style;
					}
				}
			}
			textLabel.defaultTextFormat = style;
			
			var filter:GlowFilter;
			var shadowFilter:DropShadowFilter
			if(settings.borderSize>0 && settings.border){
				filter = new GlowFilter(settings.borderColor, 1, settings.borderSize, settings.borderSize, settings.strenghtFilter, 1); //(settings.borderColor, 1, settings.borderSize, settings.borderSize, 6, 1);
				shadowFilter = new DropShadowFilter(settings.distShadow, settings.angleShadow, settings.borderColor, 1, 1, 1, settings.strenghtShadow, 1);  //(1,90,settings.borderColor,0.9,2,2,2,1);
				textLabel.filters = [filter, shadowFilter];
			}			
			
			textLabel.cacheAsBitmap = true;
			
			if (settings.autoSize == 'none') {
				metrics = textLabel.getLineMetrics(0);
				textLabel.height = (textLabel.textHeight || metrics.height) + metrics.descent;
			}
			return textLabel;
		}
		
		/**
		 * Текст 2
		 * Текст автоматически подсраивается под заданые размеры @width и @height
		 * Если Window.DEBUG == true - то будут отрисовываться граници текста.
		 * 
		 * Обязательные параметры:
		 * @width - ширина текста
		 * @height - высота текста
		 * @x - позиция
		 * @y - позиция
		 * @parent - обькт, в который добавится текст
		 * @settings - параметры текста
		 * @alignForHeight - по умолчанию == "center", позиционирует текст по высоте. Если нужно, что бы текст был вверху, то передаем "up"
		 * 
		 * @textAlign - выравнивание текста по центру, применяется по умолчанию. 
		 * ВАЖНО!!! autoSize передавать НЕ нужно. Этот параметр ломает механику.
		 */
		public static function drawTextX(text:String, width:Number, height:Number, x:Number, y:Number, parent:Sprite, settings:Object, alignForHeight:String = "center"):TextField 
		{				
			var defaults:Object = 
			{
				align:"center",
				textAlign:"center",
				wrap:true,
				multiline:true
			};
			
			for (var property:* in settings) {
				defaults[property] = settings[property];
			}
			
			settings = defaults;
			
			settings.width = width;
			settings.height = height;
			
			const startW:Number = width;
			const startH:Number = height;
			
			
			
			var textLabel:TextField = new TextField();
			
			// уменьшает текст по высоте, что бы он не вышел за рамки максимальной заданой высоты.
			settings = checkingHeight(text, settings);
			
			// уменьшает текст по ширине, что бы он не вышел за рамки максимальной заданой ширины.
			settings = checkingWidth(text, settings);
			
			settings.height = startH;
			
			textLabel = Window.drawText(text, settings);
			
			var offsetY:Number = ( startH - textLabel.textHeight ) / 2;
			
			if (alignForHeight != "center"){
				offsetY = 0;	// Не центрировать текст по высоте в центре. Текст отобразится вверху выделеного места.
			}
			
			textLabel.x = x;
			textLabel.y = y + offsetY;
			parent.addChild(textLabel);
			
			
			if (Config.admin && Window.DEBUG){							
				var shape:Shape = new Shape();
				shape.graphics.lineStyle(1,0xff0000,1);
				shape.graphics.drawRect(textLabel.x, textLabel.y - offsetY, startW, startH);
				shape.graphics.endFill();
				textLabel.parent.addChild(shape);
			}
			
			
			return textLabel;
		}
		
		/**
		 * Уменьшает текст по высоте, что бы он не вышел за рамки максимальной заданой высоты.
		 * @text - текст.
		 * @prms - параметры текста.
		 * Обязательно нужно передать: height, fontSize
		 */
		private static function checkingHeight(text:String, prms:Object):Object
		{
			var textLabel:TextField = new TextField();
			var reSize:Boolean = false; 
			
			do
			{
				if (reSize){
					prms.fontSize -= 1;						// уменьшаем размер шрифта, пока текст не влезит по высоте
				}
				
				textLabel = Window.drawText(text, prms);
				textLabel.wordWrap = true;
				reSize = true;
			}
			while (textLabel.textHeight > prms.height)
			
			prms.height = textLabel.textHeight;
			
			return prms;
		}
			
		/**
		 * Берет самое длинное слово в предложении, и проверяет, слово не длинее ширины текста.
		 * @text - текст.
		 * @prms - параметры текста.
		 * Обязательно нужно передать: width, fontSize
		 */
		private static function checkingWidth(text:String, prms:Object):Object 
		{
			if (App.isSocial('YB', 'MX', 'AI'))	// отключено для этих сетей, ибо слова у них слишком длинные
				return prms;
			
			const NEED_WIDTH:Number = prms.width;	// ширина, за которую не должен вылезти текст
			
			var words:Array;
			var longest:String = '';
			var i:String;
			
			words = text.split(' ');
			words = words.sortOn(['length'], Array.DESCENDING);
			
			longest = '';
			
			// Находим самое длинное слово.
			for (i in words)
			{
				if(words[i].length > longest.length)
					longest = words[i];
			}
							
			if (App.isSocial('YB', 'MX', 'AI')) 
			{
				splitSimbol('、');
				splitSimbol('。');
			}
			
			/**
			 * Разрезает текст в месте, указаным сиволом @simbol
			 * Результатом является самое длинное слово в тексте, которое хранится в @longest
			 */
			function splitSimbol(simbol:String):void
			{
				words = longest.split(simbol);
				words = words.sortOn(['length'], Array.DESCENDING);
				
				longest = '';
				
				// Находим самое длинное слово.
				for (i in words)
				{
					if(words[i].length > longest.length)
						longest = words[i];
				}
			}
			
			
			var textFontSize:int  = prms.fontSize;
			
			prms.width = 1000;	//сбрасываем ширину.
			
			var textLabel:TextField;
			var reSize:Boolean = false; 
			
			do{
				if (reSize){
					prms.fontSize -= 1;
				}
				
				textLabel = Window.drawText(longest, prms);
				reSize = true;
			}
			while (textLabel.textWidth + 10 > NEED_WIDTH)	// + погрешность
			
			prms.width = NEED_WIDTH;
			return prms;
		}
		
		public static function backing(width:int, height:int, padding:int = 50, texture:String = "windowBacking"):Bitmap 
		{
			var sprite:Sprite = new Sprite();
			var cWidth:int = 0;
			var cHeight:int = 0;
			
			if (textures[texture].width * 2 > width) 
			{
				cWidth = Math.floor(width / 2) - 1;
			}else 
			{
				cWidth = textures[texture].width;
			}
			if (textures[texture].height * 2 > height) 
			{
				cHeight = Math.floor(height / 2) - 1;
			}else 
			{
				cHeight = textures[texture].height;
			}
			
			var backingBMD:BitmapData = new BitmapData(cWidth, cHeight, true, 0x00000000);
			backingBMD.copyPixels(textures[texture], new Rectangle(0, 0, cWidth, cHeight), new Point());
			
			var topLeft:Bitmap = new Bitmap(backingBMD, "auto", true);
			
			var topRight:Bitmap = new Bitmap(backingBMD, "auto", true);
			topRight.scaleX = -1;
			
			var bottomLeft:Bitmap = new Bitmap(backingBMD, "auto", true);
			bottomLeft.scaleY = -1;
			
			var bottomRight:Bitmap = new Bitmap(backingBMD, "auto", true);
			bottomRight.scaleX = bottomRight.scaleY = -1;
			
			if (topLeft.height * 2 > height) 
			{
				cHeight = Math.floor(height / 2);
			}else 
			{
				cHeight = topLeft.height;
			}
			
			var horizontal:BitmapData = new BitmapData(1, cHeight, true, 0);
			horizontal.copyPixels(topLeft.bitmapData,new Rectangle(cWidth-1, 0, cWidth, cHeight), new Point());
			
			var vertical:BitmapData = new BitmapData(topLeft.width, 1, true, 0);
			vertical.copyPixels(topLeft.bitmapData,new Rectangle(0, cHeight-1, cWidth, cHeight), new Point());
			
			var fillColor:uint = topLeft.bitmapData.getPixel32(cWidth - 1, cHeight - 1);
			//var pixelValue:uint = topLeft.bitmapData.getPixel32(cWidth - 1, cHeight - 1);
			var alphaValue:Number = (fillColor >> 24 & 0xFF) / 255;
			
			topRight.x = width;
			topRight.y = 0;
			
			bottomLeft.x = 0;
			bottomLeft.y = height;
			
			bottomRight.y = height;
			bottomRight.x = width;
			
			var shp:Shape;
			shp = new Shape();
			shp.graphics.beginBitmapFill(horizontal);
			shp.graphics.drawRect(0, 0, width - topLeft.width * 2, cHeight);
			shp.graphics.endFill();
			
			var hBmd:BitmapData = new BitmapData(width - topLeft.width * 2, cHeight, true, 0);
			hBmd.draw(shp);
			
			var hTopBmp:Bitmap = new Bitmap(hBmd, "auto", true);
			var hBottomBmp:Bitmap = new Bitmap(hBmd, "auto", true);
			hBottomBmp.scaleY = -1;
			
			hTopBmp.x = topLeft.width;
			hTopBmp.y = 0;
			hBottomBmp.x = topLeft.width;
			hBottomBmp.y = height;
			
			shp = new Shape();
			shp.graphics.beginBitmapFill(vertical);
			shp.graphics.drawRect(0, 0, topLeft.width, height - cHeight * 2);
			shp.graphics.endFill();

			var vBmd:BitmapData = new BitmapData(topLeft.width, (height - cHeight * 2 == 0) ? 1 : (height - cHeight * 2), true, 0);
			vBmd.draw(shp);
			
			var vLeftBmp:Bitmap = new Bitmap(vBmd, "auto", true);
			var vRightBmp:Bitmap = new Bitmap(vBmd, "auto", true);
			vRightBmp.scaleX = -1;
			
			vLeftBmp.x = 0;
			vLeftBmp.y = cHeight;
			
			vRightBmp.x = width;
			vRightBmp.y = cHeight;
			
			var solid:Sprite = new Sprite();
			solid.graphics.beginFill(fillColor,alphaValue); // вот здесь чё-то не то
			solid.graphics.drawRect(padding, padding, width-padding*2, height-padding*2);
			solid.graphics.endFill();
			
			sprite.addChildAt(solid,0);
			
			sprite.addChild(topLeft);
			sprite.addChild(topRight);
			sprite.addChild(bottomLeft);
			sprite.addChild(bottomRight);
			sprite.addChild(hTopBmp);
			sprite.addChild(hBottomBmp);
			sprite.addChild(vLeftBmp);
			sprite.addChild(vRightBmp);
			
			solid = null;
			
			var bg:BitmapData = new BitmapData(sprite.width, sprite.height, true, 0x00000000);
			bg.draw(sprite);
						
			for (var i:int = 0; i < sprite.numChildren; i++) 
			{
				sprite.removeChildAt(i);
			}
			sprite = null;
			
			return new Bitmap(bg, "auto", true);
		}
		
		public static function backingHorizontal(width:int, texture:String = "windowBacking", bdata:BitmapData = null):Bitmap
		{
			var bTexture:BitmapData = (texture != "") ? ((textures.hasOwnProperty(texture)) ? textures[texture] : UserInterface.textures[texture]) :null;
			if (bdata)
				bTexture = bdata;
				
			var bData:BitmapData = new BitmapData(width, bTexture.height, true, 0);
			
			var matrix:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
			bData.draw(bTexture, matrix);
			
			matrix = new Matrix(1, 0, 0, 1, width - bTexture.width, 0);
			bData.draw(Size.flipBitmapData(bTexture), matrix);
			
			var horizontal:BitmapData = new BitmapData(1, bTexture.height, true, 0);
			horizontal.copyPixels(bTexture, new Rectangle(bTexture.width - 1, 0, 1, bTexture.height), new Point());
			
			var shp:Shape = new Shape();
			shp.graphics.beginBitmapFill(horizontal);
			shp.graphics.drawRect(0, 0,width - bTexture.width*2, bTexture.height);
			shp.graphics.endFill();
			
			matrix = new Matrix(1, 0, 0, 1, bTexture.width, 0);
			bData.draw(shp, matrix);
			
			return new Bitmap(bData, "auto", true);
		}
		
		public static function backing4(width:int, height:int, hz:int = 0, _texture:String = "collectionRewardBacking", _texture2:String = null, _texture3:String = null, _texture4:String = null):Bitmap
		{
			var bData:BitmapData = new BitmapData(width, height, true, 0xff);
			var texture1:BitmapData = (textures.hasOwnProperty(_texture)) ? textures[_texture] : UserInterface.textures[_texture];
			var texture2:BitmapData = Size.flipBitmapData((textures.hasOwnProperty(_texture)) ? textures[_texture] : UserInterface.textures[_texture])
			var texture3:BitmapData = Size.flipBitmapData((textures.hasOwnProperty(_texture)) ? textures[_texture] : UserInterface.textures[_texture], false, true);
			var texture4:BitmapData = Size.flipBitmapData((textures.hasOwnProperty(_texture)) ? textures[_texture] : UserInterface.textures[_texture], true, true);
			
			if (_texture2 != null && (_texture3 == null || _texture4 == null))
			{
				texture3 = (textures.hasOwnProperty(_texture2)) ? textures[_texture2] : UserInterface.textures[_texture2];
				texture4 = Size.flipBitmapData((textures.hasOwnProperty(_texture2)) ? textures[_texture2] : UserInterface.textures[_texture2], true);
			}
			if (_texture2 != null && _texture3 != null && _texture4 != null)
			{
				texture2 = (textures.hasOwnProperty(_texture2)) ? textures[_texture2] : UserInterface.textures[_texture2];
				texture3 = (textures.hasOwnProperty(_texture3)) ? textures[_texture3] : UserInterface.textures[_texture3];
				texture4 = (textures.hasOwnProperty(_texture4)) ? textures[_texture4] : UserInterface.textures[_texture4];
			}
			
			var matrix:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
			bData.draw(texture1, matrix);
			
			matrix = new Matrix(1, 0, 0, 1, width - texture2.width, 0);
			bData.draw(texture2, matrix);
			
			matrix = new Matrix(1, 0, 0, 1, 0, height - texture3.height);
			bData.draw(texture3, matrix);
			
			matrix = new Matrix(1, 0, 0, 1, width - texture4.width, height - texture4.height);
			bData.draw(texture4, matrix);
			
			var horizontal:BitmapData = new BitmapData(1, texture1.height, true, 0);
			horizontal.copyPixels(texture1, new Rectangle(texture1.width - 1, 0, 1, texture1.height), new Point(), null, null, true);
			
			var horizontal2:BitmapData = new BitmapData(1, texture3.height, true, 0);
			horizontal2.copyPixels(texture3,new Rectangle(texture3.width-1, 0, 1, texture3.height), new Point(), null, null, true);
			
			var shp:Shape = new Shape();
			shp.graphics.beginBitmapFill(horizontal);
			shp.graphics.drawRect(0, 0, width - texture1.width - texture2.width, texture1.height);
			shp.graphics.endFill();
			
			var shp2:Shape = new Shape();
			shp2.graphics.beginBitmapFill(horizontal2);
			shp2.graphics.drawRect(0, 0, width - texture3.width - texture4.width, texture3.height);
			shp2.graphics.endFill();
			
			matrix = new Matrix(1, 0, 0, 1, texture1.width);
			bData.draw(shp, matrix);
			
			matrix = new Matrix(1, 0, 0, 1, texture3.width,height - texture3.height);
			bData.draw(shp2, matrix);
			
			var vertical:BitmapData = new BitmapData(texture1.width, 1, true, 0);
			vertical.copyPixels(texture1, new Rectangle(0, texture1.height - 1, texture1.width, 1), new Point(), null, null, true);
			
			var vertical2:BitmapData = new BitmapData(texture2.width, 1, true, 0);
			vertical2.copyPixels(texture2,new Rectangle(0, texture2.height - 1, texture2.width, 1), new Point(), null, null, true);
			
			var shp3:Shape = new Shape();
			shp3.graphics.beginBitmapFill(vertical);
			shp3.graphics.drawRect(0, 0,texture1.width, height - texture1.height - texture3.height);
			shp3.graphics.endFill();
			
			var shp4:Shape = new Shape();
			shp4.graphics.beginBitmapFill(vertical2);
			shp4.graphics.drawRect(0, 0, texture2.width, height - texture2.height - texture4.height);
			shp4.graphics.endFill();
			
			matrix = new Matrix(1, 0, 0, 1, 0, texture1.height);
			bData.draw(shp3, matrix);
			
			matrix = new Matrix(1, 0, 0, 1, width - texture2.width, texture2.height);
			bData.draw(shp4, matrix);
			var colour:uint = bData.getPixel32(texture1.width - 1, texture1.height - 1);
			
			bData.fillRect(new Rectangle(texture1.width, texture1.height, width - texture1.width - texture2.width, height - texture1.height - texture3.height), colour);
			
			return new Bitmap(bData, "auto", true);
		}
		
		public static function backingShort(width:int, _texture:String = "windowBacking", mirrow:Boolean = true, scaleXpart:int = 1):Bitmap {
			var sprite:Sprite = new Sprite();
			
				var left:Bitmap;
				var right:Bitmap;
			if (Window.textures.hasOwnProperty(_texture)) {
				left = new Bitmap(Window.textures[_texture]);
				right =  new Bitmap(Window.textures[_texture]);
			}else if(UserInterface.textures.hasOwnProperty(_texture)) {
				left =  new Bitmap(UserInterface.textures[_texture]);
				right =  new Bitmap(UserInterface.textures[_texture]);
			}else {
				left =  new Bitmap(Window.texture('titleDecRose'));
				right =  new Bitmap(Window.texture('titleDecRose'));
				left.visible = false;
				right.visible = false;
			}
			
			right.scaleX = -1;
			
			var horizontal:BitmapData = new BitmapData(1, left.height, true, 0);
			horizontal.copyPixels(left.bitmapData,new Rectangle(left.width-1, 0, left.width, left.height), new Point());
			
			var fillColor:uint = left.bitmapData.getPixel(left.width - 1, left.height - 1);
			
			right.x = width;
			right.y = 0;
			
			var shp:Shape;
			shp = new Shape();
			shp.graphics.beginBitmapFill(horizontal);
			shp.graphics.drawRect(0, 0, width - left.width * 2, left.height);
			shp.graphics.endFill();
			
			if (width > 0) {
				var hBmdWidth:uint = Math.abs(width - left.width * 2);
				hBmdWidth = (hBmdWidth == 0) ? 1 : hBmdWidth;
				var hBmd:BitmapData = new BitmapData(hBmdWidth, left.height, true, 0);
				hBmd.draw(shp);
				var hTopBmp:Bitmap = new Bitmap(hBmd, "auto", true);
				hTopBmp.x = left.width;
				hTopBmp.y = 0;
				sprite.addChild(hTopBmp);
			}else {
				right.x = left.width*2;
			}
				
			
			
			sprite.addChild(left);
			if (mirrow)sprite.addChild(right);
			
			
			var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
			bg.draw(sprite);
			
			for (var i:int = 0; i < sprite.numChildren; i++) {
				sprite.removeChildAt(i);
			}
			sprite = null;
			
			return new Bitmap(bg, "auto", true);
		}
		/*public static function backingShort(width:int, texture:String = "windowBacking", mirrow:Boolean = true, scaleXpart:int = 1):Bitmap 
		{
			var sprite:Sprite = new Sprite();
			
			var left:Bitmap = new Bitmap(textures[texture], "auto", true);
			
			var right:Bitmap = new Bitmap(textures[texture], "auto", true);
			right.scaleX = -1;
			left.scaleX *= scaleXpart; 
			right.scaleX *= scaleXpart;
			var horizontal:BitmapData = new BitmapData(1, left.height, true, 0);
			horizontal.copyPixels(left.bitmapData,new Rectangle(left.width-1, 0, left.width, left.height), new Point());
			
			var fillColor:uint = left.bitmapData.getPixel(left.width - 1, left.height - 1);
			
			right.x = width;
			right.y = 0;
			
			var shp:Shape;
			shp = new Shape();
			shp.graphics.beginBitmapFill(horizontal);
			shp.graphics.drawRect(0, 0, width - left.width * 2, left.height);
			shp.graphics.endFill();
			
			if (width > 0) 
			{
				var hBmd:BitmapData = new BitmapData(Math.abs(width - left.width * 2), left.height, true, 0);
				hBmd.draw(shp);
				var hTopBmp:Bitmap = new Bitmap(hBmd, "auto", true);
				hTopBmp.x = left.width;
				hTopBmp.y = 0;
				sprite.addChild(hTopBmp);
			}else 
			{
				right.x = left.width*2;
			}
				
			
			
			sprite.addChild(left);
			if (mirrow)sprite.addChild(right);
			
			
			var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
			bg.draw(sprite);
						
			for (var i:int = 0; i < sprite.numChildren; i++) 
			{
				sprite.removeChildAt(i);
			}
			sprite = null;
			
			return new Bitmap(bg, "auto", true);
		}*/
		
		public static function amazingBackingShort(width:int, texture:String = "windowBacking", mirrow:Boolean = true,scaleXpart:int = 1):Bitmap {
			var sprite:Sprite = new Sprite();
			
			var left:Bitmap = new Bitmap(textures[texture], "auto", true);
			
			var right:Bitmap = new Bitmap(textures[texture], "auto", true);
			left.scaleX = -1;
			left.scaleX *= scaleXpart; 
			right.scaleX *= scaleXpart;
			var horizontal:BitmapData = new BitmapData(1, left.height, true, 0);
			horizontal.copyPixels(left.bitmapData,new Rectangle(left.x, 0, left.width, left.height), new Point());
			
			var fillColor:uint = left.bitmapData.getPixel(left.width - 1, left.height - 1);
			left.x += left.width;
			right.x = width - right.width;
			right.y = 0;
			
			var shp:Shape;
			shp = new Shape();
			shp.graphics.beginBitmapFill(horizontal);
			shp.graphics.drawRect(0, 0, width - left.width * 2, left.height);
			shp.graphics.endFill();
			
			if (width > 0) {
				var hBmd:BitmapData = new BitmapData(Math.abs(width - left.width * 2), left.height, true, 0);
				hBmd.draw(shp);
				var hTopBmp:Bitmap = new Bitmap(hBmd, "auto", true);
				hTopBmp.x = left.width;
				hTopBmp.y = 0;
				sprite.addChild(hTopBmp);
			}else {
				right.x = left.width*2;
			}
				
			
			
			sprite.addChild(left);
			if (mirrow)sprite.addChild(right);
			
			
			var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
			bg.draw(sprite);
						
			for (var i:int = 0; i < sprite.numChildren; i++) {
				sprite.removeChildAt(i);
			}
			sprite = null;
			
			return new Bitmap(bg, "auto", true);
		}
		
		public static function backingShort2(width:int, height:int, texture:String = "windowBacking", isBottonPiece:Boolean = false):Bitmap {
			var sprite:Sprite = new Sprite();
			
			var left:Bitmap = new Bitmap(textures[texture], "auto", true);
			
			var right:Bitmap = new Bitmap(textures[texture], "auto", true);
			right.scaleX = -1;
			
			
			var piece:BitmapData = new BitmapData(1, left.height, true, 0);
			piece.copyPixels(left.bitmapData,new Rectangle(1, 0, left.width, left.height), new Point());
			
			//var fillColor:uint = left.bitmapData.getPixel(1, left.height - 1);
			
			var shp:Shape;
			shp = new Shape();
			shp.graphics.beginBitmapFill(piece);
			shp.graphics.drawRect(0, 0,(width - left.width * 2)/2, left.height);
			shp.graphics.endFill();
			
			var pieceBmd:BitmapData = new BitmapData((width - left.width * 2)/2, left.height, true, 0);
			pieceBmd.draw(shp);
			
			var leftBmp:Bitmap = new Bitmap(pieceBmd, "auto", true);
			var rightBmp:Bitmap = new Bitmap(pieceBmd, "auto", true);
			
			if (isBottonPiece) {
				var bottomPiece:BitmapData = new BitmapData(1, 1, true, 0);
				bottomPiece.copyPixels(left.bitmapData, new Rectangle(1, left.height-1, width, height -left.height), new Point());
				
				var shp2:Shape;
				shp2 = new Shape();
				shp2.graphics.beginBitmapFill(bottomPiece);
				shp2.graphics.drawRect(0, 0,width, height -left.height);
				shp2.graphics.endFill();
				
				var bottomPieceBmd:BitmapData = new BitmapData(width, height - left.height, true, 0);
				bottomPieceBmd.draw(shp2);
				
				var bottomBmp:Bitmap = new Bitmap(bottomPieceBmd, "auto", true);
				sprite.addChild(bottomBmp);
				bottomBmp.y = leftBmp.y + leftBmp.height;
			}
			
			
			leftBmp.x = 0;
			leftBmp.y = 0;
			
			left.x = leftBmp.width;
			left.y = 0;
			
			right.x = left.x + left.width*2;
			right.y = 0;
			
			rightBmp.x = right.x;
			rightBmp.y = 0;
			
			sprite.addChild(left);
			sprite.addChild(right);
			sprite.addChild(leftBmp);
			sprite.addChild(rightBmp);
			
			var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
			bg.draw(sprite);
						
			for (var i:int = 0; i < sprite.numChildren; i++) {
				sprite.removeChildAt(i);
			}
			sprite = null;
			
			return new Bitmap(bg, "auto", true);
		}
		
		public static function backing2(width:int, height:int, padding:int = 50, texture:String = "windowBacking", texture2:String = "windowBacking", koefBetweenTextures:int = 0, coef:int = 0):Bitmap
		{
			var bData:BitmapData = new BitmapData(width, height, true, 0xff);
			
			var matrix:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
			bData.draw(textures[texture], matrix);
			
			matrix = new Matrix(1, 0, 0, 1, width - textures[texture].width, 0);
			bData.draw(Size.flipBitmapData(textures[texture]), matrix);
			
			matrix = new Matrix(1, 0, 0, 1, width - textures[texture].width, 0);
			bData.draw(Size.flipBitmapData(textures[texture]), matrix);
			
			matrix = new Matrix(1, 0, 0, 1, 0, height - textures[texture2].height);
			bData.draw(textures[texture2], matrix);
			
			matrix = new Matrix(1, 0, 0, 1, width - textures[texture2].width, height - textures[texture2].height);
			bData.draw(Size.flipBitmapData(textures[texture2], true), matrix);
			
			var horizontal:BitmapData = new BitmapData(1, textures[texture].height, true, 0);
			horizontal.copyPixels(textures[texture], new Rectangle(textures[texture].width - 1, 0, 1, textures[texture].height), new Point());
			
			var horizontal2:BitmapData = new BitmapData(1, textures[texture2].height, true, 0);
			horizontal2.copyPixels(textures[texture2],new Rectangle(textures[texture2].width-1, 0, 1, textures[texture2].height), new Point());
			
			var shp:Shape = new Shape();
			shp.graphics.beginBitmapFill(horizontal);
			shp.graphics.drawRect(0, 0, width - textures[texture].width * 2, textures[texture].height);
			shp.graphics.endFill();
			
			var shp2:Shape = new Shape();
			shp2.graphics.beginBitmapFill(horizontal2);
			shp2.graphics.drawRect(0, 0, width - textures[texture2].width * 2, textures[texture2].height);
			shp2.graphics.endFill();
			
			matrix = new Matrix(1, 0, 0, 1, textures[texture2].width);
			bData.draw(shp, matrix);
			
			matrix = new Matrix(1, 0, 0, 1, textures[texture2].width,height - textures[texture2].height);
			bData.draw(shp2, matrix);
			
			var vertical:BitmapData = new BitmapData(textures[texture].width, 1, true, 0);
			vertical.copyPixels(textures[texture], new Rectangle(0, textures[texture].height - 1, textures[texture].width, 1), new Point());
			
			var vertical2:BitmapData = new BitmapData(textures[texture].width, 1, true, 0);
			vertical2.copyPixels(textures[texture],new Rectangle(0, textures[texture].height - 1, textures[texture].width, 1), new Point());
			
			var shp3:Shape = new Shape();
			shp3.graphics.beginBitmapFill(vertical);
			shp3.graphics.drawRect(0, 0,textures[texture].width, height - textures[texture].height - textures[texture2].height);
			shp3.graphics.endFill();
			
			var shp4:Shape = new Shape();
			shp4.graphics.beginBitmapFill(Size.flipBitmapData(vertical2));
			shp4.graphics.drawRect(0, 0, textures[texture].width, height - textures[texture].height - textures[texture2].height);
			shp4.graphics.endFill();
			
			matrix = new Matrix(1, 0, 0, 1, textures[texture].width);
			bData.draw(shp, matrix);
			
			matrix = new Matrix(1, 0, 0, 1, textures[texture2].width, height - textures[texture2].height);
			bData.draw(shp2, matrix);
			
			matrix = new Matrix(1, 0, 0, 1, 0, textures[texture].height);
			bData.draw(shp3, matrix);
			
			matrix = new Matrix(1, 0, 0, 1, width - textures[texture].width, textures[texture].height);
			bData.draw(shp4, matrix);
			var colour:uint = bData.getPixel32(textures[texture].width - 1, textures[texture].height - 1);
			
			bData.fillRect(new Rectangle(textures[texture].width, textures[texture].height, width - textures[texture].width - textures[texture2].width, height - textures[texture].height - textures[texture2].height), colour);
			
			return new Bitmap(bData, "auto", true);
		}
			
		public static function backing2Old(width:int, height:int, padding:int = 50, texture:String = "windowBacking", texture2:String = "windowBacking", koefBetweenTextures:int = 0, spaceY:int = 0):Bitmap {
			var sprite:Sprite = new Sprite();
			
			var isHeightSmoller:Boolean = false;
			
			var topLeft:Bitmap = new Bitmap(textures[texture], "auto", true);
			var topRight:Bitmap = new Bitmap(textures[texture], "auto", true);
			var bottomLeft:Bitmap = new Bitmap(textures[texture2], "auto", true);
			var bottomRight:Bitmap = new Bitmap(textures[texture2], "auto", true);
			
			var sameHeigth:Boolean = false;
			var sameWidth:Boolean = false;
			
			if (height <= topLeft.height + bottomLeft.height) {
				sameHeigth = true;
			}
			else if (width <= topLeft.width + bottomLeft.width) {
				sameWidth = true;
			}
			
			if(!sameWidth){
				var horizontal:BitmapData = new BitmapData(1, bottomLeft.height, true, 0);
				horizontal.copyPixels(topLeft.bitmapData, new Rectangle(topLeft.width - 1, 0, topLeft.width, topLeft.height), new Point(),null,null,true);
				
				var horizontal2:BitmapData = new BitmapData(1, bottomLeft.height, true, 0);
				horizontal2.copyPixels(bottomLeft.bitmapData,new Rectangle(bottomLeft.width-1, 0, bottomLeft.width, bottomLeft.height), new Point(),null,null,true);
			
				var shp:Shape;
				shp = new Shape();
				shp.graphics.beginBitmapFill(horizontal);
				shp.graphics.drawRect(0, 0, width - topLeft.width * 2, topLeft.height);
				shp.graphics.endFill();
				
				var shp2:Shape;
				shp2 = new Shape();
				shp2.graphics.beginBitmapFill(horizontal2);
				shp2.graphics.drawRect(0, 0, width - bottomLeft.width * 2 + koefBetweenTextures*4, bottomLeft.height);
				shp2.graphics.endFill();
				
				if (width - topLeft.width * 2 <= 0)
					width = topLeft.width * 2 + 1;
						
				var hBmd:BitmapData = new BitmapData(width - topLeft.width * 2, topLeft.height, true, 0);
				hBmd.draw(shp);
				
				if (width - bottomLeft.width * 2 <= 0)
					width = bottomLeft.width * 2 + 1;
				
				var hBmd2:BitmapData = new BitmapData(width - bottomLeft.width * 2  + koefBetweenTextures*4, bottomLeft.height, true, 0);
				hBmd2.draw(shp2);
				
				var hTopBmp:Bitmap = new Bitmap(hBmd, "auto", true);
				var hBottomBmp:Bitmap = new Bitmap(hBmd2, "auto", true);
			}
				
			if (height < topLeft.height + bottomLeft.height) {
				isHeightSmoller = true;
				var heightDiff:Number = (topLeft.height + bottomLeft.height) - height + 6;
				
				topLeft.height = topLeft.height - heightDiff / 2;
				topRight.height = topRight.height - heightDiff / 2;
				bottomLeft.height = bottomLeft.height - heightDiff / 2;
				bottomRight.height = bottomRight.height - heightDiff / 2;
				
				hTopBmp.height = hTopBmp.height - heightDiff / 2;
				hBottomBmp.height = hBottomBmp.height - heightDiff / 2;
			}
			
			if(!sameWidth){
				hTopBmp.x = topLeft.width;
				hTopBmp.y = 0;
				hBottomBmp.x = bottomLeft.width - koefBetweenTextures*2;
				hBottomBmp.y = height - hBottomBmp.height + spaceY;
			}
			
			topRight.scaleX = -1;
			bottomRight.scaleX = -1;
			
			if(!sameHeigth){
				var vertical:BitmapData = new BitmapData(topLeft.width, 1, true, 0);
				vertical.copyPixels(topLeft.bitmapData,new Rectangle(0, topLeft.height-1, topLeft.width, topLeft.height), new Point());
			
				var fillColor:uint = topLeft.bitmapData.getPixel(topLeft.width - 1, topLeft.height - 1);
			}
			
			topLeft.x = 0;
			topLeft.y = 0;
			
			topRight.x = width;
			topRight.y = 0;
			
			bottomLeft.x = - koefBetweenTextures;
			if (isHeightSmoller) {
				bottomLeft.y = topLeft.height + spaceY;
				if(!sameWidth)hBottomBmp.y = bottomLeft.y + bottomLeft.height - hBottomBmp.height;
			}else {bottomLeft.y = height - bottomLeft.height + spaceY;}
			
			if (isHeightSmoller) 
				bottomRight.y = topRight.height + spaceY;
			else 
				bottomRight.y = height - bottomRight.height + spaceY;
			
			bottomRight.x = width + koefBetweenTextures;
			
			if(!sameHeigth){
				shp = new Shape();
				shp.graphics.beginBitmapFill(vertical);
				shp.graphics.drawRect(0, 0, topLeft.width, height - topLeft.height * 2);
				shp.graphics.endFill();

				var vBmd:BitmapData = new BitmapData(topLeft.width, height - topLeft.height * 2, true, 0);
				vBmd.draw(shp);
				
				var vLeftBmp:Bitmap = new Bitmap(vBmd, "auto", true);
				var vRightBmp:Bitmap = new Bitmap(vBmd, "auto", true);
				vRightBmp.scaleX = -1;
				
				vLeftBmp.x = 0;
				vLeftBmp.y = topLeft.height;
				
				vRightBmp.x = width;
				vRightBmp.y = topLeft.height;
			}
			
			if(!sameHeigth && !sameWidth){
				var solid:Sprite = new Sprite();
				solid.graphics.beginFill(fillColor);
				solid.graphics.drawRect(padding, padding, width-padding*2, height-padding*2);
				solid.graphics.endFill();
			}
			
			sprite.addChild(topLeft);
			sprite.addChild(topRight);
			sprite.addChild(bottomLeft);
			sprite.addChild(bottomRight);
			
			if (!sameHeigth && !sameWidth) sprite.addChildAt(solid, 0);
			if(!sameWidth){
				sprite.addChild(hTopBmp);
				sprite.addChild(hBottomBmp);
			}
			if(!sameHeigth){
				sprite.addChild(vLeftBmp);
				sprite.addChild(vRightBmp);
			}
			
			solid = null;
			
			var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
			bg.draw(sprite);
						
			for (var i:int = 0; i < sprite.numChildren; i++) {
				sprite.removeChildAt(i);
			}
			sprite = null;
			
			return new Bitmap(bg, "auto", true);
		}

		public static function separator(width:int, xPos:int = 0, yPos:int = 0, alphaVal:Number = 1, texture:String = "separatorPiece", texture2:String = "separatorPiece2"):Bitmap
		{
			var sprite:Sprite = new Sprite();
			
			var left:Bitmap = new Bitmap(textures[texture], "auto", true);
			
			var right:Bitmap = new Bitmap(textures[texture], "auto", true);
			right.scaleX = -1;
			right.x = width;
			
			var piece2Width:Number = width - left.width - right.width;
			
			var centerPiece:Shape = new Shape();
			centerPiece.graphics.beginBitmapFill(Window.textures.separatorPiece2);
			centerPiece.graphics.drawRect(0, 0, piece2Width, Window.textures.separatorPiece2.height);
			centerPiece.graphics.endFill();
			centerPiece.x = left.width;
			
			sprite.addChild(left);
			sprite.addChild(right);
			sprite.addChild(centerPiece);
			
			var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
			bg.draw(sprite);
			
						
			for (var i:int = 0; i < sprite.numChildren; i++) {
				sprite.removeChildAt(i);
			}
			sprite = null;
			
			var sep:Bitmap = new Bitmap(bg, "auto", true);
			sep.alpha = alphaVal;
			sep.x = xPos; sep.y = yPos;
			
			return sep;
		}

		public static function separator2(width:int, texture:String = "separatorPiece", texture2:String = "separatorPiece2"):Bitmap
		{
			var sprite:Sprite = new Sprite();
			
			var left:Bitmap = new Bitmap(textures[texture], "auto", true);
			
			var right:Bitmap = new Bitmap(textures[texture2], "auto", true);
			//right.scaleX = -1;
			//right.x = width;
			
			var horizontal:BitmapData = new BitmapData(1, left.height, true, 0);
			horizontal.copyPixels(left.bitmapData,new Rectangle(left.width-1, 0, left.width, left.height), new Point());
			
			var fillColor:uint = left.bitmapData.getPixel(left.width - 1, left.height - 1);
			
			right.x = width - right.width;
			right.y = 0 + (left.height - right.height);
			
			var shp:Shape;
			shp = new Shape();
			shp.graphics.beginBitmapFill(horizontal);
			shp.graphics.drawRect(0, 0, width - left.width - right.width, left.height);
			shp.graphics.endFill();
			
			if (width > 0) {
				var hBmd:BitmapData = new BitmapData(Math.abs(width - left.width - right.width), left.height, true, 0);
				hBmd.draw(shp);
				var hTopBmp:Bitmap = new Bitmap(hBmd, "auto", true);
				hTopBmp.x = left.width;
				hTopBmp.y = 0;
				sprite.addChild(hTopBmp);
			}else {
				right.x = left.width*2;
			}
				
			
			
			sprite.addChild(left);
			/*if (mirrow)*/sprite.addChild(right);
			
			
			var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
			bg.draw(sprite);
						
			for (var i:int = 0; i < sprite.numChildren; i++) {
				sprite.removeChildAt(i);
			}
			sprite = null;
			
			return new Bitmap(bg, "auto", true);
		}
		
		
		public static function shadowBacking(width:int, height:int, radius:int=7):Sprite {
			
			var sprite:Sprite = new Sprite();
			
			var shadow:Shape = new Shape();
			shadow.graphics.beginFill(0x5A31B0, .2);
			shadow.graphics.drawRoundRect(2, 4, width, height, radius, radius);
			shadow.graphics.endFill();
			
			var middle:Shape = new Shape();
			middle.graphics.beginFill(0x442585, 1);
			middle.graphics.drawRoundRect(0, 0, width, height, radius, radius);
			middle.graphics.endFill();
			
			var face:Shape = new Shape();
			face.graphics.beginFill(0x4A40CE, 1); 
			face.graphics.drawRoundRect(2, 2, width-4, height-4, radius, radius);
			face.graphics.endFill();
			
			sprite.addChild(shadow);
			sprite.addChild(middle);
			sprite.addChild(face);
			
			return sprite;
		}
		
		public static function getBacking(width:int = 100, height:int = 100, x:int = 0, y:int = 0, radius:int = 33, settings:Object = null):Sprite {
			
			var defaultsColors:Object = {
				bgColor				:0x98988e,
				bevelColorHight		:0x939689,
				bevelColorDown		:0xc4caab,
				glowColor			:0x2c312a,
				borderWidth			:2,
				bevel				:true
			}
			
			if (settings == null) {
				settings = defaultsColors;
			}else {
				for (var property:* in settings) {
					defaultsColors[property] = settings[property];
				}
				settings = defaultsColors;
			}
			
			var backing:Sprite = new Sprite();
			
			var backing1:Sprite= new Sprite();
			
			if(settings.bevel == true){
				backing1.graphics.beginFill(settings.bgColor);
				backing1.graphics.drawRoundRect(0, 0, width, height, radius,radius);
				backing1.graphics.endFill();
				var filter1:BevelFilter = new BevelFilter(1, 90, settings.bevelColorHight, 1, settings.bevelColorDown, 1, 1.6, 1.6, 15, 15, "outter", false);
				backing1.filters = [filter1];
			}
			
			var backing2:Sprite= new Sprite();
			
			backing2.graphics.beginFill(settings.bgColor);
			backing2.graphics.drawRoundRect(0, 0, width, height, radius, radius);
			backing2.graphics.endFill();
			
			var filter2:GlowFilter = new GlowFilter(settings.glowColor, 1, settings.borderWidth, settings.borderWidth, 10, BitmapFilterQuality.HIGH, false);
			
			backing2.filters = [filter2];
						
			backing.addChild(backing1);
			backing.addChild(backing2);
			
			backing.x = x;
			backing.y = y;
			
			backing.cacheAsBitmap = true;
			
			return backing;
		}
		
		public function drawSpriteBorders(sprite:Sprite):void {
			sprite.graphics.beginFill(0xff0000, 0.05);
			sprite.graphics.lineStyle(2, 0xff0000, 1);
			sprite.graphics.drawRoundRectComplex(0, 0, sprite.width, sprite.height, 1, 1, 1, 1)
			sprite.graphics.endFill();
		}
		
		public function titleText(settings:Object):Sprite
		{
			if (!settings.hasOwnProperty('width'))
				settings['width'] = 300;
			
			var cont:Sprite = new Sprite();
			
			if (settings.hasOwnProperty('shadowSize'))
				settings.shadowSize = settings.shadowSize;
			else
				settings.shadowSize = 3;
				
			settings.shadowColor = settings.shadowColor || 0x4d3300;
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			this.settings['titleWidth'] = textLabel.textWidth;
			this.settings['titleHeight'] = textLabel.textHeight;
			textLabel.wordWrap = true;
			textLabel.width = settings.width;
			textLabel.height = textLabel.textHeight + 4;
			
			var filters:Array = []; 
			
			if (settings.borderSize > 0) 
			{
				filters.push(new GlowFilter(settings.borderColor || 0x7e3e14, 1, settings.borderSize, settings.borderSize, 16, 2));
			}
			
			if (settings.shadowSize > 0) 
			{
				filters.push(new DropShadowFilter(settings.shadowSize, 90, settings.shadowColor, 1, 0, 0, 1, 2));
			}
			
			textLabel.filters = filters;
			
			cont.addChild(textLabel);
			cont.mouseEnabled = false;
			cont.mouseChildren = false;
			return cont;
		}
		
		public var titleLabelImage:Bitmap;
		
		public function drawLabel(bmd:BitmapData, scale:Number = 1):void
		{
			titleLabelImage = new Bitmap(bmd);
			bodyContainer.addChild(titleLabelImage);
			if (titleLabelImage.height > 260 && scale == 1) 
				scale = 260 / titleLabelImage.height;
			
			titleLabelImage.scaleX = titleLabelImage.scaleY = scale;
			titleLabelImage.smoothing = true;
			
			titleLabelImage.x = (settings.width - titleLabelImage.width)/2;
			titleLabelImage.y = -titleLabelImage.height / 2;
		}
		
		public static function getTextColor(sid:int):Object
		{
			var data:Object = [];
			data['color'] = 0xffffff;
			data['borderColor'] = 0x000000;
			
			switch(sid) {
				case Stock.FANTASY:
				case Stock.GUESTFANTASY:
					data['color'] = 0xffdb65;
					data['borderColor'] = 0x775002;
				break;
				case Stock.COINS:
					data['color'] = 0xffdb65;
					data['borderColor'] = 0x775002;
				break;
				case Stock.FANT:
					data['color'] = 0xffdb65;
					data['borderColor'] = 0x775002;
				break;
				case App.data.storage[App.user.worldID].techno[0]:
					data['color'] = 0xfff1cf;
					data['borderColor'] = 0x482e16;
				break;
			}
			return data;
		}
		
		
		public static function addMirrowObjs(layer:Sprite, texture:String, xPos:int, xPos2:int, yPos:int, selfPaddingLeft:Boolean = false, selfPaddingRight:Boolean = false, selfPaddingTop:Boolean = false, _alpha:Number = 1, scaleY:Number = 1 ):void
		{
			var btmLeft:Bitmap = new Bitmap(textures[texture]);
			btmLeft.scaleY = scaleY;
			btmLeft.smoothing = true;
			
			if (selfPaddingLeft) {
				btmLeft.x = xPos - btmLeft.width; 
			}else {
				btmLeft.x = xPos; 
			}
			if (selfPaddingTop) {
				btmLeft.y = yPos - btmLeft.height/2;
			}else {
				btmLeft.y = yPos;
			}
			
			var btmRight:Bitmap = new Bitmap(textures[texture]);
			btmRight.smoothing = true;
			btmRight.scaleX = -1;
			btmRight.scaleY = scaleY;
			
			if (selfPaddingRight) {
				btmRight.x = xPos2 + btmRight.width;
			}else{
				btmRight.x = xPos2;
			}
			if (selfPaddingTop) {
				btmRight.y = yPos - btmRight.height/2;
			}else {
				btmRight.y = yPos;
			}
			btmLeft.alpha = _alpha;
			btmRight.alpha = _alpha;
			layer.addChild(btmLeft);
			layer.addChild(btmRight);
		}
		
		public static function closeAll():void {
			for (var i:int = App.self.windowContainer.numChildren - 1; i > -1; i--) {
				var window:* = App.self.windowContainer.getChildAt(i);
				if (window is Window) window.close();
			}
		}
		
		public static function clearBorders(sprite:Sprite):void { sprite.graphics.clear();}
		public static function showBorders(sprite:*, color:uint = 0xFFFFFF):void
		{
			clearBorders(sprite);
			var bounds:Rectangle = sprite.getBounds(sprite);
			
			sprite.graphics.beginFill(color, 0.5);
			sprite.graphics.drawRect(bounds.topLeft.x, bounds.topLeft.y, bounds.width, bounds.height);
			sprite.graphics.endFill();
			
			//sprite.graphics.beginFill(color, 0.5);
			//sprite.graphics.drawRect(0, 0, sprite.width, sprite.height);
			//sprite.graphics.endFill();
			
			
			sprite.graphics.beginFill(0xFF0000, 0.5);
			sprite.graphics.drawCircle(0,0,5);
			sprite.graphics.endFill();
		}
		
		public function silentClose(e:MouseEvent = null):void {
			
			if (settings.hasAnimations == true) {
				startCloseAnimation();
			}else {
				dispatchEvent(new WindowEvent("onBeforeClose"));
				dispose();
			}
		}
		
		public function disposeChilds(list:*):void 
		{
			if (!list)
				return;
			for each(var item:DisplayObject in list){
				if (item && item.parent)
					item.parent.removeChild(item);
				item = null;
			}
			list = new (getDefinitionByName(getQualifiedClassName(list)) as Class)
			trace();
			//list =  new classType();
			
		}
	}
}