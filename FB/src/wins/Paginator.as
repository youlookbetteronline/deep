package wins 
{
	import flash.display.Sprite;
	import buttons.PageButton;
	import buttons.ImageButton;
	import buttons.Button;
	import flash.events.MouseEvent;

	public class Paginator extends Sprite
	{	
		public static var block:int 			= 0;
		public static const LEFT:int			= 1;
		public static const RIGHT:int			= 2;
		public static const LEFT_DIAGONAL:int	= 3;
		public static const RIGHT_DIAGONAL:int	= 4;
		
		public var page:int 					= 0;
		public var pages:int 					= 0;
		public var buttonsCount:int 			= 10;
		public var onPageCount:int 				= 6;
		public var itemsCount:int 				= 0;		
		public var hasPoints:Boolean 			= true;
		public var hasArrows:Boolean 			= true;
		public var hasButtons:Boolean 			= true;
		public var separatorWidth:int 			= 12;		
		public var start:int 					= 0;
		public var finish:int 					= 0;
		public var startCount:int 				= 0;
		public var finishCount:int 				= 0;		
		public var _buttons:Vector.<PageButton> = new Vector.<PageButton>();		
		public var pointsLeft:ImageButton 		= null;
		public var pointsRight:ImageButton 		= null;		
		public var arrowLeft:ImageButton 		= null;
		public var arrowRight:ImageButton 		= null;
		public var goldenButtons:Array			= [];
		public var buttonPrev:String			= ''
		
		public function Paginator(itemsCount:int = 0, onPageCount:int = 6, buttonsCount:int = 9, settings:Object = null)
		{
			//if(itemsCount !=0 || 10)
			this.itemsCount 	= itemsCount;
			this.buttonsCount 	= buttonsCount;
			this.onPageCount 	= onPageCount;
			
			
			//Если передан объект null, инициализируем его
			if (settings == null) 
			{
				settings = new Object();
			}
			
			//Инициализируем настройки
			this.page 			= settings["page"] || 0;
			this.hasPoints		= settings.hasPoints == undefined?true:settings.hasPoints;
			this.hasArrows		= settings.hasArrows == undefined?true:settings.hasArrows;
			this.hasButtons		= settings.hasButtons == undefined?true:settings.hasButtons;
			this.separatorWidth = settings["separatorWidth"] || this.separatorWidth;
			this.buttonPrev 	= settings["buttonPrev"] || 'shopButton';
			
			//Получаем кол-во страниц
			pages = Math.ceil(itemsCount / onPageCount);
			
			//Создаем кнопки из трех точек для перехода в начало или конец списка страниц
			if (hasPoints == true)
			{
				createPoints(0, 5, Paginator.LEFT);
				createPoints(pointsLeft.width+separatorWidth - 4 +(PageButton.WIDTH+separatorWidth)*buttonsCount, 5, Paginator.RIGHT);
			}
			
			//Визуализируем пагинатор
			update();
		}
		
		/**
		 * Очищаем объект
		 */
		
		public function dispose():void
		{
			if (pointsLeft != null && pointsLeft.hasEventListener(MouseEvent.MOUSE_DOWN))
			{
				pointsLeft.removeEventListener(MouseEvent.MOUSE_DOWN, pointsLeftDown)
			}
			if (pointsRight != null && pointsRight.hasEventListener(MouseEvent.MOUSE_DOWN))
			{
				pointsRight.removeEventListener(MouseEvent.MOUSE_DOWN, pointsRightDown)
			}
			removeButtons();
		}
		
		/**
		 * Удаляем кнопки страниц, а также привяflash:1382952379984нные к ним события
		 */
		
		public function removeButtons():void 
		{
			for (var i:int = 0; i < buttonsCount; i++)
			{
				if (_buttons.hasOwnProperty(i))
				{
					_buttons[i].removeEventListener(MouseEvent.CLICK, select);
					removeChild(_buttons[i]);
				}
			}
			_buttons = new Vector.<PageButton>();
		}
		
		/**
		 * //Визуализируем пагинатор
		 */
		public function update():void 
		{
			//Получаем кол-во страниц
			pages = Math.ceil(itemsCount / onPageCount);
			
			//На всякий случай насильно ограничиваем номера страниц в соотвествии с реальными данными
			if (page >= pages) 
			{
				page = pages-1;
			}
			if (page < 0) 
			{
				page = 0;
			}			
			
			if (hasButtons == true)
			{
				var X:int = pointsLeft.width + separatorWidth - 4;
				//Удаляем кнопки, чтобы нарисовать новые
				removeButtons();
				
				/*if (pages > 1) {
					var count:int = pages >= buttonsCount?buttonsCount:pages;
					for (var i:int = 0; i < count; i++)
					{
						var pageButton:PageButton = new PageButton({width:28} );
						addChild(pageButton);
						
						pageButton.addEventListener(MouseEvent.CLICK, select);
						pageButton.x = int(X + (((PageButton.WIDTH + separatorWidth)*buttonsCount) - PageButton.WIDTH - separatorWidth)/2 - (PageButton.WIDTH - 10 + separatorWidth)*((count-1)/2-i));
						pageButton.y = -14;
						pageButton.scaleX = 1.1;
						pageButton.textLabel.width = 35;
						_buttons.push(pageButton)
					}
				}else {
					pageButton = new PageButton({width:28});
					pageButton.caption = String(1);
					pageButton.state = Button.ACTIVE;
					pageButton.x = int(X + (((PageButton.WIDTH + separatorWidth)*buttonsCount) - PageButton.WIDTH - separatorWidth)/2);
					pageButton.y = -14;
					pageButton.scaleX = 1.1;
					addChild(pageButton);
					
					_buttons.push(pageButton);
				}*/
				
				if (pages > 1)
				{
					var count:int = pages >= buttonsCount?buttonsCount:pages;
					for (var i:int = 0; i < count; i++)
					{
						var pageButton:PageButton;
						if (goldenButtons.indexOf(i) != -1)
							pageButton = new PageButton( { 
								width:28,
								bevelColor:[0x4a94bf, 0x235985],
								bgColor:[0xb8e8f9, 0x68a7c5],
								borderColor:[0x000000, 0x000000],
								fontBorderColor:0x965e23,
								active: {
									bgColor:				[0xd89008,0xd89008],
									borderColor:			[0x000000,0x000000],	//Цвета градиента
									bevelColor:				[0xa86121,0xffff7b],	
									fontColor:				0xfffcff,				//Цвет шрифта
									fontBorderColor:		0x965e23				//Цвет обводки шрифта		
								}
							} );
						else 
						pageButton = new PageButton( { width:28 } );
						addChild(pageButton);
						
						pageButton.addEventListener(MouseEvent.CLICK, select);
						pageButton.x = int(X + (((PageButton.WIDTH + separatorWidth)*buttonsCount) - PageButton.WIDTH - separatorWidth)/2 - (PageButton.WIDTH - 10 + separatorWidth)*((count-1)/2-i));
						pageButton.y = -14;
						pageButton.scaleX = 1.1;
						pageButton.textLabel.width = 35;
						_buttons.push(pageButton)
					}
				}else {
					pageButton = new PageButton({width:28});
					pageButton.caption = String(1);
					pageButton.state = Button.ACTIVE;
					pageButton.x = int(X + (((PageButton.WIDTH + separatorWidth)*buttonsCount) - PageButton.WIDTH - separatorWidth)/2);
					pageButton.y = -14;
					pageButton.scaleX = 1.1;
					addChild(pageButton);
					
					_buttons.push(pageButton);
				}
			}
			
			if (pages > 0)
			{				
				if (page == 0) 
				{
					if (arrowLeft != null) arrowLeft.visible = false;
				}else {
					if (arrowLeft != null) arrowLeft.visible = true;
				}				
				
				if (page == pages - 1)
				{
					if (arrowRight != null) arrowRight.visible = false;
				}else {
					if (arrowRight != null) arrowRight.visible = true;
				}
			}else
			{
				if (arrowRight != null) arrowRight.visible = false;
				if (arrowLeft != null) arrowLeft.visible = false;
			}
			/*if (pages > 0)
			{				
				if (page == 0) 
				{
					if (arrowLeft != null) arrowLeft.mode = Button.DISABLED;
				}else {
					if (arrowLeft != null) arrowLeft.mode = Button.NORMAL;
				}				
				
				if (page == pages - 1)
				{
					if (arrowRight != null) arrowRight.mode = Button.DISABLED;
				}else {
					if (arrowRight != null) arrowRight.mode = Button.NORMAL;
				}
			}else
			{
				if (arrowRight != null) arrowRight.visible = false;
				if (arrowLeft != null) arrowLeft.visible = false;
			}*/
			
			sort();
		}

		public function sort():void
		{
			if (pages < buttonsCount)
			{
				start = 0;
				finish = pages - 1;
			}else {
				if (page < buttonsCount - 1)
				{
					start = 0;
					finish = pages-1;
				}else if (page > pages - int(buttonsCount / 2) -1) 
				{
					start = pages - buttonsCount
					finish = pages - 1
				}else {
					start = page - int(buttonsCount / 2);
					finish = page + int(buttonsCount / 2);
				}
			}
			
			startCount = page * onPageCount;
			finishCount = startCount + onPageCount;
			finishCount = finishCount > itemsCount?itemsCount: finishCount;
			
			if (hasButtons == true)
			{
				var count:int = pages >= buttonsCount?buttonsCount:pages;
				for (var i:int = 0; i < count; i++ ) {
					_buttons[i].caption = String(start + i + 1);
					_buttons[i].page = start + i;
					if (_buttons[i].page == page) {
						_buttons[i].state = Button.ACTIVE;
					}
				}
				
				pointsLeft.visible = false
				pointsRight.visible = false
				
				if (pages > buttonsCount)
				{
					if (_buttons[0].page == 0)
					{
						if (pointsLeft != null)	pointsLeft.visible = false;
					}else {
						if (pointsLeft != null)	pointsLeft.visible = true;
					}
					
					if (_buttons[buttonsCount - 1].page == pages - 1) {
						if (pointsRight != null) pointsRight.visible = false;
					}else {
						if (pointsRight != null) pointsRight.visible = true;
					}
				}
			}
		}
		
		public function select(e:MouseEvent):void
		{
			page = e.currentTarget.page;
			update();			
			dispatchEvent(new WindowEvent("onPageChange"));
		}
		
		public function createPoints(x:int = 0, y:int = 0, position:int = Paginator.RIGHT):void
		{
			if (position == Paginator.LEFT
			){
				pointsLeft = new ImageButton(Window.textures.points);
				pointsLeft.visible = false;
				addChild(pointsLeft);
				pointsLeft.x = x + 10;
				pointsLeft.y = (PageButton.HEIGHT - pointsLeft.height) / 2 - 15;
				pointsLeft.addEventListener(MouseEvent.MOUSE_DOWN, pointsLeftDown)
			}else if (position == Paginator.RIGHT)
			{
				pointsRight = new ImageButton(Window.textures.points);
				pointsRight.visible = false;
				addChild(pointsRight);
				pointsRight.x = x - 10;
				pointsRight.y = (PageButton.HEIGHT - pointsRight.height) / 2 - 15;
				pointsRight.addEventListener(MouseEvent.MOUSE_DOWN, pointsRightDown)
			}
		}
		
		public function drawArrow(container:*, position:int, x:int = 0, y:int = 0, settings:Object = null):void
		{			
			if (hasArrows == false) return;
			
			if (position == Paginator.LEFT)
			{
				if (settings == null)
				{
					settings = { 'scaleX': 1, 'scaleY': 1 };
				}
				settings['sound'] = 'sound_2';
				arrowLeft = new ImageButton(Window.textures[this.buttonPrev], settings);
				arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, arrowLeftDown)
				
				container.addChild(arrowLeft);
				arrowLeft.x = x;
				arrowLeft.y = y;
			}else if (position == Paginator.RIGHT)
			{
				if (settings == null)
				{
					settings = { 'scaleX': 1, 'scaleY': 1 };
				}
				settings['sound'] = 'sound_2';
				arrowRight = new ImageButton(Window.textures[this.buttonPrev], settings);
				arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, arrowRightDown)
				
				container.addChild(arrowRight);
				arrowRight.x = x;
				arrowRight.y = y;
			}
			
			if (position == Paginator.LEFT_DIAGONAL)
			{
				if (settings == null)
				{
					settings = { 'scaleX': 1, 'scaleY': 1 };
				}
				settings['sound'] = 'sound_2';
				arrowLeft = new ImageButton(Window.textures.menuArrow2, settings);
				arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, arrowLeftDown)
				
				container.addChild(arrowLeft);
				arrowLeft.x = x;
				arrowLeft.y = y;
			}else if (position == Paginator.RIGHT_DIAGONAL)
			{
				if (settings == null)
				{
					settings = { 'scaleX': 1, 'scaleY': 1 };
				}
				settings['sound'] = 'sound_2';
				arrowRight = new ImageButton(Window.textures.menuArrow2, settings);
				arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, arrowRightDown)
				
				container.addChild(arrowRight);
				arrowRight.x = x;
				arrowRight.y = y;
			}
			update();
		}
		
		private function pointsLeftDown(e:MouseEvent):void
		{
			page = 0;
			update();
			dispatchEvent(new WindowEvent("onPageChange"));
		}
		
		private function pointsRightDown(e:MouseEvent):void
		{
			page = pages - 1;	
			update();
			dispatchEvent(new WindowEvent("onPageChange"));
		}
		
		private function arrowLeftDown(e:MouseEvent):void
		{
			if (page > 0)
			{
				page--;
				update();
				dispatchEvent(new WindowEvent("onPageChange"));
			}
		}
		
		private function arrowRightDown(e:MouseEvent):void
		{
			if (page < pages - 1)
			{
				page++;	
				update();
				dispatchEvent(new WindowEvent("onPageChange"));
			}
		}
		
		public function show(length:int):void
		{
			this.visible = true
			this.visible = true
			this.visible = true
			this.itemsCount = length
			this.page = 0
			this.update()
		}
		
		public function hide():void
		{
			this.visible = false
			this.visible = false
			this.visible = false
		}		
	}
}