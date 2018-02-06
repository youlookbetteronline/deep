package wins.elements 
{
	import buttons.MenuButton;
	import flash.events.MouseEvent;
	import wins.BanksWindow;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author 
	 */
	public class BankUsualMenu extends Sprite
	{
		public static var COINS:int = 1;
		public static var REALS:int = 0;
		public static var SETS:int = 2;
		
		public var menuBttns:Array = [];
		public var subBttns:Array = [];
		public var window:*;
		public var bttnWidth:int = 140;
		
		public static var _currBtn:int = 0;
		
		public var menuSettings:Object = {
			1: { type:'Coins', 	order:1,	title:App.data.storage[Stock.COINS].title },
			2: { type:'Reals', 	order:2,	title:App.data.storage[Stock.FANT].title },
			3: { type:'Sets', 	order:3,	title:Locale.__e('flash:1382952379981') }
		};
			
		public var arrSquence:Array = [2, 1, 0];
			
		public function BankUsualMenu(window:*)
		{
			/*if (Config.admin) {
				menuSettings[0] = { type:'Sets', order:0,	title:Locale.__e('flash:1382952379981') };
				if (App.social == 'OK') bttnWidth = 100;
			}*/
			
			this.window = window;
			//drawSubmenuBg();
			
			for (var i:int = 0; i < arrSquence.length; i++ ) {
				for (var item:* in menuSettings) {
					if (item == arrSquence[i]) {
						var settings:Object = menuSettings[item];
							settings['type'] = settings.type;
							settings['onMouseDown'] = onMenuBttnSelect;
							settings['fontSize'] = 24;
							
							settings['widthPlus'] = 60;
							settings['width'] = bttnWidth;
							
							switch(settings.type) {
								case BanksWindow.REALS:
									settings["bgColor"] = [0x97c8ff, 0x5d8ef4];
									settings["bevelColor"] = [0xb6dcff, 0x376ce0];
									settings["fontBorderColor"] = 0x3f59a6;
									settings["fontCountColor"] = 0xFFFFFF;
									settings["fontCountBorder"] = 0x354321;
									settings["fontBorderSize"] = 3;
									settings['active'] = {
										bgColor:				[0x5d8ef4, 0x97c8ff],//[0x47750b,0x74bc17],
										bevelColor:				[0x376ce0, 0xb6dcff],//[0x335309,0x7ecb19],	
										fontBorderColor:		0x3f59a6				//Цвет обводки шрифта
									}
								break;
								case BanksWindow.COINS:
									settings["bgColor"] = [0xf5d057, 0xeeb331];
									settings["bevelColor"] = [0xfff17f, 0xbf7e1a];
									settings["fontBorderColor"] = 0x3f4a6f;
									settings["fontBorderColor"] = 0x814f31;
									settings['active'] = {
										bgColor:				[0xeeb331,0xf5d057],
										bevelColor:				[0xbf7e1a,0xfff17f],	
										fontBorderColor:		0x6d3f23				//Цвет обводки шрифта		
									}
								break;
								case BanksWindow.SETS:
									settings["bgColor"] = [0xd36efd, 0x9c32c8];/*[0x82c9f7, 0x5cabdd];*/
									settings["bevelColor"] = [0xef99fd, 0xe8117ad];/*[0xc2e2f4, 0x3384b2];*/
									settings["fontBorderColor"] = /*0x993a40*/ 0x6e039b;					
									//settings["fontCountBorder"] = 0x354321;
									//settings["fontBorderColor"] = 0x426da1;
									settings['active'] = {
										bgColor:				[0x9c32c8, 0xd36efd],/*[0x105f91,0x5cabdd],*/
										bevelColor:				[0xe8117ad, 0xef99fd],/*[0x0c4b73,0x61addc],	*/
										fontBorderColor:		/*0x993a40*/0x6e039b				//Цвет обводки шрифта		
									}
								break;
							}
							
							
						menuBttns.push(new MenuButton(settings));
					}
				}
			}
			//menuBttns.sortOn('order');
			//menuBttns.reverse();
			if(window.settings.section == "Reals"){
				menuBttns[0].selected = true;
			}else {
				menuBttns[1].selected = true;
			}
			
			var bttnsContainer:Sprite = new Sprite();
			var bttnOffset:int = 15;
			var offset:int = 0;
			
			// Если есть какие-то дополнительные кнопки акций или т.п.
			//if (window is BanksWindow && window.clickCont) {
				//bttnOffset = 15;
				//offset = 10;
			//}
			
			for (i = 0; i < menuBttns.length; i++)
			{
				menuBttns[i].x = offset;
				offset += menuBttns[i].settings.width + bttnOffset;
				bttnsContainer.addChild(menuBttns[i]);
			}
			
			bttnsContainer.x = 0;// ( submenuBg.width - bttnsContainer.width ) / 2;
			addChild(bttnsContainer);
			
			this.x = /*184;*/25 + (window.settings.width - bttnsContainer.width) / 2;
			this.y = 5;
			
		}
		
		public function onMenuBttnSelect(e:MouseEvent):void
		{
			for each(var bttn:MenuButton in menuBttns) {
				bttn.selected = false;
			}
			e.currentTarget.selected = true;
			_currBtn = menuBttns.indexOf(e.currentTarget);
			
			window.setContentSection(e.currentTarget.type);
		}		
		
	}
}

import buttons.MenuButton;
internal class SubMenuBttn extends MenuButton
{
	public function SubMenuBttn(settings:Object = null) {
		
		settings["bgColor"] = settings.bgColor || [0xcfbd8c, 0xb19d6f];	
		settings["bevelColor"] = settings.bevelColor || [0x7d6d44, 0x70603a];	
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
