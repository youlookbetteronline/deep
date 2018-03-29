package wins.elements 
{
	import buttons.MenuButton;
	import core.Numbers;
	import flash.events.MouseEvent;
	import wins.ShopWindow;
	import flash.display.Sprite;
	
	public class ShopMenu extends Sprite
	{
		/*
			'0'=>_('Невидимый'),
            '2'=>_('Растения'),
            '3'=>_('Декорации'),
            '4'=>_('Производство'),
            '14'=>_('Здания'),
            '7'=>_('Важное'),
            '13'=>_('Ресурсы'),
			*/
		public var menuBttns:Array = [];
		public var subBttns:Array = [];
		public var window:ShopWindow;
		
		public static var _currBtn:int = 0;
		
		public static var menuSettings:Object = {
			
			100: { order:0, 	title:Locale.__e("flash:1382952379743") },//Новое
			2:	{ order:3, 	title:Locale.__e("flash:1410167506188") },//Растения
			4: 	{ order:1,	title:Locale.__e("flash:1382952380292") },//Производство
			15: { order:2,	title:Locale.__e("flash:1402910864995") },//Животные
			///14: { order:2,	title:Locale.__e("flash:1396612468985") },//Постройки
			14: { order:14, title:Locale.__e("flash:1491906763164") }, //Пасха
			17: { order:6,	title:Locale.__e("flash:1444730210412") },//Интерьер
			18: { order:7,	title:Locale.__e("flash:1382952380292") },//Для дома (Производство)
			3: 	{ order:4,	title:Locale.__e("flash:1382952380294") },//Декор
			7: 	{ order:5,	title:Locale.__e("flash:1382952380295") },//Важное
			13: { order:5,	title:Locale.__e("flash:1396612503921") }//Ресурсы
		};
		
		public var arrSquence:Array = new Array([]); //[ 14, 13, 2, 4, 5, 3, 7];
		
		
		public function ShopMenu(window:ShopWindow)
		{
			/*switch (App.user.worldID){
				case User.HOLIDAY_LOCATION:
					arrSquence = [100, 4, 3, 13, 7];
				break;
				
				case User.TRAVEL_LOCATION:
					arrSquence = [100, 2, 13, 15, 7];
					break;
					
				case User.AQUA_HERO_LOCATION: 
					arrSquence = [17, 18];
					break;	
					
				case User.FARM_LOCATION:
				case User.SIGNAL_SOURCE: 
				case User.SOCKET_MAP: 
					arrSquence = [100, 7];
					break;
					
				case User.NEPTUNE_MAP: 
					arrSquence = [100, 7, 14];
					break;
					
				case User.HUNT_MAP: 
					arrSquence = [100, 4, 2, 7];
					break;	
				case User.SCIENCE_MAP: 
					arrSquence = [100, 2, 13, 7];
					break;
				case User.SYNOPTIK_MAP: 
					arrSquence = [100, 2, 13, 7];
					break;
				case User.LAND_2: 
					arrSquence = [100, 4, 2, 15, 3, 13, 7];
					break;	
				case User.HALLOWEEN_MAP: 
					arrSquence = [100, 4, 13, 7];
					break;	
				case User.SWEET_MAP: 
					arrSquence = [100, 4, 2, 13, 7, 14];
					break;	
					
				default: 
					arrSquence = [100, 4, 2, 15, 3, 13, 7];
					break;
			}*/
			arrSquence = ShopMenu.getMapShop(App.user.worldID);
			//if (App.user.worldID == User.HOLIDAY_LOCATION)
			//	arrSquence = [100, 4, /*14, 2,*/ 15, 3, 13, 7, 17/*, 18*/];
			//else 
			//	arrSquence = [100, 4, /*14, */2, 15, 3, 13, 7, 17/*, 18*/];
			
			this.window = window;
			drawSubmenuBg();
			for (var i:int = 0; i < arrSquence.length; i++ ) {
				for (var item:* in menuSettings) {
					if (item == arrSquence[i]) {
						var settings:Object = menuSettings[item];
						settings['type'] = item;
						//settings['onMouseDown'] = onMenuBttnSelect;
						settings['fontSize'] = 22;//24;						
						settings['widthPlus'] = 35;//50
						
						//if (item == 3 && App.user.worldID == User.MARTIN_JANE_LOCATION) settings.title = Locale.__e('flash:1435054686292');
						
						if (settings.order == 0) {
							settings["bgColor"] = [0xd8a036, 0xe0b545];
							settings["bevelColor"] = [0xf6fd9b, 0x9a6d22];
							settings["fontBorderColor"] = 0x755036;
							settings['active'] = {
								bgColor:				[0xe0b545, 0xd8a036],
								bevelColor:				[0x9a6d22, 0xf6fd9b],	
								fontBorderColor:		0xa35e34				//Цвет обводки шрифта		
							}
						}
						
						if (settings.order == 14) {
							settings["bgColor"] = [0xd36efd, 0x9c32c8];
							settings["bevelColor"] = [0xef99fd, 0xe8117ad];
							settings["fontBorderColor"] = 0x6e039b;
							settings['active'] = {
								bgColor:				[0xb377cb, 0x9c32c8],
								bevelColor:				[0xc890d7, 0xe8117ad],	
								fontBorderColor:		0x6e039b				//Цвет обводки шрифта		
							}
						}
						
						var bttn:MenuButton = new MenuButton(settings);
						menuBttns.push(bttn);
						bttn.addEventListener(MouseEvent.CLICK, onMenuBttnSelect);
					}
				}
			}
			
			/*for (var item:* in menuSettings) {
				var settings:Object = menuSettings[item];
					settings['type'] = item;
					settings['onMouseDown'] = onMenuBttnSelect;
					settings['fontSize'] = 24;
					
					settings['widthPlus'] = 60;
					
					if (settings.order == 0) {
						settings["bgColor"] = [0xfec37f, 0xfc8524];
						settings["bevelColor"] = [0xffe294, 0xbe5e24];
						settings["fontBorderColor"] = 0x914d24;
						settings['active'] = {
							bgColor:				[0xb25000,0xdb8627],
							borderColor:			[0x504529,0xe0ac0e],	//Цвета градиента
							bevelColor:				[0x863707,0xddab14],	
							//fontColor:				0xffffff,				//Цвет шрифта
							fontBorderColor:		0x914d24				//Цвет обводки шрифта		
						}
					}
					
				menuBttns.push(new MenuButton(settings));
			}
			menuBttns.sortOn('order');*/
			if (menuBttns.length-1 < _currBtn)
				_currBtn = 0;
			menuBttns[_currBtn].selected = true;
			
			var bttnsContainer:Sprite = new Sprite();
			
			var offset:int = 0;
			for (i = 0; i < menuBttns.length; i++)
			{
				menuBttns[i].x = offset;
				offset += menuBttns[i].settings.width + 4;
				bttnsContainer.addChild(menuBttns[i]);
			}
			
			//bttnsContainer.x = ( submenuBg.width - bttnsContainer.width ) / 2;
			addChild(bttnsContainer);
			
			//this.x = (window.settings.width - submenuBg.width) / 2;
			//this.y = 5;
			
			
		}
		
		public static function getMapShop(_worldID:int):Array{
			var _arrSquence:Array = [100, 4, 2, 15, 3, 13, 7];
			switch (_worldID)
			{
				case User.HOLIDAY_LOCATION:
					_arrSquence = [100, 4, 3, 13, 7];
				break;
				case User.TRAVEL_LOCATION:
					_arrSquence = [100, 2, 13, 15, 7];
					break;
				case User.AQUA_HERO_LOCATION: 
					_arrSquence = [17, 18];
					break;
				case User.FARM_LOCATION:
				case User.SIGNAL_SOURCE: 
				case User.SOCKET_MAP: 
					_arrSquence = [100, 7];
					break;
				case User.NEPTUNE_MAP: 
					_arrSquence = [100, 7, 14];
					break;
				case User.HUNT_MAP: 
					_arrSquence = [100, 4, 2, 7];
					break;	
				case User.SCIENCE_MAP: 
					_arrSquence = [100, 2, 13, 7];
					break;
				case User.SYNOPTIK_MAP: 
					_arrSquence = [100, 2, 4, 13, 7];
					break;
				case User.LAND_2: 
					_arrSquence = [100, 4, 2, 15, 3, 13, 7];
					break;	
				case User.HALLOWEEN_MAP: 
					_arrSquence = [100, 4, 13, 7];
					break;	
				case User.SWEET_MAP: 
					_arrSquence = [100, 4, 2, 13, 7, 14];
					break;	
				case User.FISHLOCK_MAP: 
					_arrSquence = [100, 2, 13];
					break;	
				case User.OMUT: 
					_arrSquence = [7];
					break;
				case User.MAP_2975: 
					_arrSquence = [100, 7];
					break;	
				case User.MAP_3069: 
					_arrSquence = [100, 4, 7];
					break;	
				case 3009: 
					_arrSquence = [100, 2, 4, 15, 3, 7];
					break;	
				case 3184: 
					_arrSquence = [100, 2, 15, 4, 3, 7];
					break;
				case 3253: 
					_arrSquence = [100, 3, 4, 7, 2, 15];
					break;
				case 3333: 
					_arrSquence = [100, 4, 7, 14];
					break;
				case 3526: 
					_arrSquence = [100, 4, 2, 7];
					break;
				case 3629: 
					_arrSquence = [100, 4, 2, 3, 15, 7];
					break;
				case 3602: 
					_arrSquence = [100, 7];
					break;
				default: 
					_arrSquence = [100, 2, 13, 4, 15, 3, 7];
					break;
			}
			return _arrSquence;
		}
		
		private function clearSubmenu():void {
			
			for each(var bttn:SubMenuBttn in subBttns) 
			{
				submenuContainer.removeChild(bttn);
			}
			if(submenuContainer) removeChild(submenuContainer);
			submenuContainer = null
			subBttns = [];
		}
		
		private var submenuContainer:Sprite
		private function drawSubmenu(section:int):void {
			
			var childs:Object = menuSettings[section]['childs'];
			childs['all'] = { order:0,	title:Locale.__e("flash:1382952380301"), childs:[]};
			
			for (var item:* in childs) {
				var settings:Object = childs[item];
					settings['type'] = item;
					settings['onMouseDown'] = onSubMenuBttnSelect;
					settings['height'] = 36;
					settings['parentSection'] = section;
					
					if (item != 'all')
						childs['all'].childs.push(item);
					
				subBttns.push(new SubMenuBttn(settings));
			}
			subBttns.sortOn('order');
			submenuContainer = new Sprite();
			
			var offset:int = 0;
			for (var i:int = 0; i < subBttns.length; i++)
			{
				subBttns[i].x = offset;
				offset += subBttns[i].settings.width + 4;
				submenuContainer.addChild(subBttns[i]);
			}
			
			submenuContainer.x = 10;// (submenuBg.width - submenuContainer.width ) / 2;
			submenuContainer.y = submenuBg.y + 2;
			addChild(submenuContainer);
			
			//subBttns[0].selected = true;
			subBttns[0].dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		}
		
		private var submenuBg:Sprite;
		private function drawSubmenuBg():void 
		{
			submenuBg = new Sprite();
			submenuBg.graphics.lineStyle(0x000000, 0, 0, true);	
			submenuBg.graphics.beginFill(0xb8a574);
			submenuBg.graphics.drawRoundRect(0, 0, window.settings.width - 120, 40, 25, 25);
			submenuBg.graphics.endFill();
			//this.addChild(submenuBg);
			submenuBg.y = 45;
		}
		
		public function onMenuBttnSelect(e:MouseEvent):void
		{
			for each(var bttn:MenuButton in menuBttns) {
				bttn.selected = false;
			}
			e.currentTarget.selected = true;
			
			ShopWindow.history.section = arrSquence[menuBttns.indexOf(e.currentTarget)];
			
			_currBtn = menuBttns.indexOf(e.currentTarget);
			
			clearSubmenu();
			
			if (menuSettings[e.currentTarget.type].hasOwnProperty('childs'))
				drawSubmenu(e.currentTarget.type);
			else	
				window.setContentSection(e.currentTarget.type);
		}		
		
		public function onSubMenuBttnSelect(e:MouseEvent):void
		{
			for each(var bttn:SubMenuBttn in subBttns) {
				bttn.selected = false;
			}
			e.currentTarget.selected = true;
			
			if (e.currentTarget.type == 'all')
				window.setContentSection(e.currentTarget.settings.childs);	
			else
				window.setContentSection([e.currentTarget.type]);	
			
		}	
	}
}

import buttons.MenuButton;
internal class SubMenuBttn extends MenuButton
{
	public function SubMenuBttn(settings:Object = null) {

		settings["bgColor"] = settings.bgColor || [0xffdd93, 0xfdb165];	
		settings["bevelColor"] = settings.bevelColor || [0xffeddf, 0xffeddf];
		settings["fontColor"] = settings.fontColor || 0xffffff;				
		settings["fontBorderColor"] = settings.fontBorderColor || 0x786840
		settings["shadow"] = false;
		
		settings["active"] = {
				bgColor:				[0xf7efd2,0xfffade],
				bevelColor:				[0x7f6e43,0x7f6e43],	
				fontColor:				0x705f36,	
				fontBorderColor:		0xffffff	
			}
		super(settings);
	}
}
