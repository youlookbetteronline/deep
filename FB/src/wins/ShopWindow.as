package wins
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import core.Numbers;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import ui.WorldPanel;
	import units.Craftfloors;
	import units.Lantern;
	import units.Table;
	import units.Tribute;
	import utils.ObjectsContent;
	import utils.Saver;
	import wins.elements.BankMenu;
	import wins.elements.SearchShopPanel;
	import wins.elements.ShopItem;
	import wins.elements.ShopMenu;

	/*
	    0 - невидимый
		1 - материалы
		2 - растения
		3 - декор
		4 - здания
		5 - персы
		6 - инструменты
		7 - дополнения
		8 - одежда
		13 - ресурсы
		17 - мебель
		18 - Для дома (Производство)
	*/		

	public class ShopWindow extends Window
	{
		public static var shop:Object;
		public static var history:Object = {section:100, page:0};
		private static var _currentBuyObject:Object = { type:null, sid:null, currency:null };
		
		public var sections:Array = new Array();
		public var news:Object = {items:[],page:0};
		public var icons:Array = new Array();
		public var items:Array = [];
		public var plankBmap:Bitmap = new Bitmap();
		
		public static var openInWorld:Array = [];
		public static var glowFirstNewsItem:Boolean = false;
		public static var currentUpdateID:String = "";
		
		private var searchpanel:SearchShopPanel;
		
		public function ShopWindow(settings:Object = null)
		{
			initContent();
			
			_currentBuyObject.type = null;
			_currentBuyObject.sid = null;
			
			if (settings == null) 
			{
				settings = new Object();
			}
			
			settings["section"] = settings.section || history.section; 
			settings["page"] = (settings.page!=null)?settings.page:history.page;
			settings["find"] = settings.find || null;
			settings["title"] = Locale.__e("flash:1382952379765");
			settings["width"] = 730;
			settings["height"] = 580;
			settings["hasPaginator"] = true;
			settings["paginatorSettings"] = {buttonsCount: 3};
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 8;
			settings["returnCursor"] = false;
			settings["glowUpdate"] = settings.glowUpdate;
			settings["currentUpdate"] = settings.currentUpdate;
			
			history.section		= settings.section;
			history.page		= settings.page;
			
			// Туториал
			if (App.user.quests.tutorial) 
			{
				var targets:Array = QuestsRules.getTargtes();
				settings.find = [];
				for (var i:int = 0; i < targets.length; i++) 
				{
					if (App.data.storage[targets[i]])
						settings.find.push(targets[i]);
				}
			}
			
			glowFirstNewsItem = settings.glowUpdate
			currentUpdateID = settings.currentUpdate;
			//var ii:* = shop[history.section];
			if (!(shop[history.section]))
			{
				if(App.user.worldID == User.AQUA_HERO_LOCATION)
					history.section = 17;
				else
					history.section = 100;
			}
			settings.content = shop[history.section].data;
			findTargetPage(settings);
			super(settings);
		}
		
		private function findTargetPage(settings:Object):void 
		{
			for (var section:* in shop)
			{
				if (section == 0)
					continue;
				for (var i:* in shop[section].data)
				{
					var sid:int = shop[section].data[i].sid;
					
					if (settings.find != null && settings.find.indexOf(sid) != -1)
					{
						/*if (section == 14) 
						{
							return;
						}*/
						
						history.section = section;
						history.page = int(int(i) / settings.itemsOnPage);
						settings.section = history.section;
						settings.page = history.page;
						return;
					}
				}
			}
		}
		
		private function setBttnPressed(section:int):void
		{
			for (var i:int = 0; i < menu.arrSquence.length; i ++ ) 
			{
				if (menu.arrSquence[i] == section)
				{
					ShopMenu._currBtn = i;
					menu.menuBttns[i].selected = true;
				}else {
					menu.menuBttns[i].selected = false;
				}
			}
		}
		
		private function checkUpdate(updateID:String):Boolean
		{			
			var update:Object = App.data.updates[updateID];
			
			if (!update.hasOwnProperty('social') || !update.social.hasOwnProperty(App.social)) 
			{
				
				for (var sID:* in App.data.updates[updateID].items)
				{
					if ((update.ext != null && update.ext.hasOwnProperty(App.social)) && (update.stay != null && update.stay[sID] != null))
					{
						
					}
					else
					{
						App.data.storage[sID].visible = 0;
					}
				}
				
				return false;
			}
			
			return true;
		}		
		
		public const PRODUCTION_SECTION:uint = 4;
		public const ANIMALS_SECTION:uint = 15;
		public const PLANTS_SECTION:uint = 2;
		public const DECOR_SECTION:uint = 3;
		public const RESOURCE_SECTION:uint = 7;
		public const IMPORTANT_SECTION:uint = 13;
		
		public static var sarcofitons:Array = [215, 216, 217];
		public static var currentWorld:* = null;
		public static var lockInThisWorld:Array = [];
		public static var worldShop:Object = null;
		
		public function initContent ():void 
		{
			if(App.data.storage[App.user.worldID].hasOwnProperty('shop'))
				worldShop = App.data.storage[App.user.worldID].shop;
			
			if (currentWorld != App.map.id) {
				currentWorld = App.map.id;
				
				
				var _itemsData:Object = ShopWindow.worldShop;
				
				openInWorld = [];
				
				for (var _sect:* in _itemsData)
				{
					for (var __sid:* in _itemsData[_sect])
					{
						if (__sid != 's' && _itemsData[_sect][__sid] == 1 && App.data.storage[__sid] != null && App.data.storage[__sid].type != 'Material' && App.data.storage[__sid].type != 'Lamp') 
						{
							openInWorld.push(__sid);
						}
					}
				}
			}
			
			if (currentWorld != App.map.id) 
			{
				currentWorld = App.map.id;
				var _itemsData2:Object = ShopWindow.worldShop;
				lockInThisWorld = [];
				
				for (var _sect2:* in _itemsData2)
				{
					for (var __sid2:* in _itemsData2[_sect2])
					{
						if (__sid2 != 's' && _itemsData2[_sect][__sid2] == 0) 
						{
							lockInThisWorld.push(__sid2);
						}
					}
				}
			}
				
			if (shop == null) 
			{
				shop = new Object();
				
				shop[100] = {
					data:[],
					page:0
				};
				
				for (var updateID:* in App.data.updates) 
				{
					if (updateID == 'u59ef37ab9d08a')
						continue;
					// Если этого обновления нет в соц. сети
					if (!App.data.updates[updateID].social || !App.data.updates[updateID].social.hasOwnProperty(App.social) || App.data.updates[updateID].preview == 'invisible') 
						continue;
				
						
					var updateObject:Object = {
						id:updateID,
						data:[]
					}
					
					var updatesItems:Array = [];
					var items:Object = App.data.updates[updateID].items;
					
					for (var _sid:* in items)
					{	
						if (App.data.storage.hasOwnProperty(_sid) && App.data.storage[_sid].visible == 0 && updateID != 'u592d292dc79b3' && App.data.storage[_sid].type != 'Material') continue;
						if (sarcofitons.indexOf(_sid) != -1)	continue;
						/*if ((App.data.storage[_sid].type == 'Building' ||
							App.data.storage[_sid].type == 'Pharmacy' ||
							App.data.storage[_sid].type == 'Golden' ||
							App.data.storage[_sid].type == 'Walkgolden' ||
							App.data.storage[_sid].type == 'Mfloors' ||
							App.data.storage[_sid].type == 'Tribute') && !World.canBuyOnThisMap(_sid))
							continue;*/
						updatesItems.push( { sid:_sid, order:items[_sid], updateItem:true } );
					}	
					
					updatesItems.sortOn('order', Array.NUMERIC);
					
					for (var i:int = 0; i < updatesItems.length; i++)
					{
						updateObject.data.push(App.data.storage[updatesItems[i].sid]);
					}
					
					updateObject['order'] = App.data.updates[updateID].order;	
					
					if(App.data.updatelist[App.social].hasOwnProperty(updateID))
						updateObject['order'] = App.data.updatelist[App.social][updateID];
					else
						updateObject['order'] = App.data.updates[updateID].order;
						
					if (updateObject.preview == 'invisible') continue;
					
					shop[100].data.push(updateObject);
					
				}
				
				shop[100].data.sortOn('order', Array.NUMERIC | Array.DESCENDING);
				//shop[14].data.sortOn('type', Array.DESCENDING);
				var _decor:Array = [];
				var updates:Array = [];				
				var _elements:Array = [];
				//var decors:Array = [];
				
				for (var j:int = 0; j < shop[100].data.length; j++) 
				{
					var updatesObjectsList:Array = shop[100].data[j].data;
					updates[j] = [];
					
					for (var k:int = 0; k <updatesObjectsList.length ; k++) 
					{
						var _item:Object = updatesObjectsList[k];
						if (_item == null) 
						{
							continue;
						}
						switch(_item.type)
						{
							case 'Golden':
							case 'Decor':
							case 'Fake':
							//case 'Resource':
							case 'Walkgolden':
								//decors.push(_item.sID);
								updates[j].push(_item);
								break;
						}
					}
				}
				
				for (var itm:* in updates) 
				{
					updates[itm].sortOn('update',Array.NUMERIC | Array.DESCENDING);
				}
				
				for (var upd:* in updates)
				{
					var updateItems:Array = updates[upd];
					updates[upd].sortOn('order', Array.NUMERIC | Array.DESCENDING);
					updateItems.sortOn('type', Array.DESCENDING);
					
					for (var upItm:* in updateItems)
					{
						_decor.push(updateItems[upItm]);
					}
				}
				
				for (var id:String in App.data.storage)
				{
					var item:Object = App.data.storage[id];
					item['sid'] = id;
					
					if (item['sid'] == 1777)
						item.visible = 1
						
					if (ShopWindow.sarcofitons.indexOf(int(item.sid)) != -1)
					{
						continue;
					}
						
					if (App.user.id == '50545195' || App.user.id == '83730403')
					{
						if (item.type == 'Collection') continue;
						if (item.visible == 0 && item.type != 'Resource') continue;
						
						//if (!World.canBuyOnThisMap(item.sID))
							//continue;
					}else{
						if (item.type == 'Collection') continue;
						if (item.visible == 0) continue;
						
						if (!World.canBuyOnThisMap(item.sID))
							continue;
					}
					if (shop[item.market] == null)
					{
						shop[item.market] = {
							data:new Array(),
							page:0
						};
					}
					item['sid'] = id;
					if (item.type == 'Resource' && (App.user.id != '50545195' || App.user.id != '83730403'))
					{
						for (var resSID:* in item.outs)
						{
							if (App.data.storage[resSID].mtype != 3)
							{
								if (resSID != 0 && Stock.isExist(resSID))
								{
									shop[item.market].data.push(item);
									break;
								}
							}
						}
						
					}else{
						if (item.sid == 0)
							continue;
						
						shop[item.market].data.push(item);
					}
					switch(item.type)
					{
						case 'Energy':
							item.order2 = 1;
							break;
						case 'Golden':
							item.order2 = 2;
							break;
						case 'Tribute':
							item.order2 = 3;
							break;
						case 'Mfloors':
							item.order2 = 4;
							break;
						case 'Walkgolden':
							item.order2 = 5;
							break;
						case 'Booster':
							item.order2 = 6;
							break;
						default:
							item.order2 = 7;
					}
					/*switch(item.type)
					{
						case 'Golden':
						case 'Decor':
						case 'Box':
						case 'Fake':
							if(decors.indexOf(int(item.sid)) == -1)
								decors.push(int(item.sid));
							break;
					}*/
				}
				
				for (var market:* in shop)
				{
					if (market == 100 /*|| market == 3*/) continue;
					shop[market].data.sortOn('order', Array.NUMERIC);
					
					if (market == 14)
						shop[market].data.sortOn('type').reverse();
					
				}
				if(shop[DECOR_SECTION])
					shop[DECOR_SECTION].data.sortOn(['order2','order'], Array.NUMERIC);
				//shop[DECOR_SECTION].data = _decor;
			}
		}
		
		override public function titleText(settings:Object):Sprite
		{
			
			if (!settings.hasOwnProperty('width'))
				settings['width'] = 300;
			
			var cont:Sprite = new Sprite();
			
			settings.shadowSize = settings.shadowSize || 3;
			settings.shadowColor = settings.shadowColor || 0x111111;
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			this.settings['titleWidth'] = textLabel.textWidth;
			this.settings['titleHeight'] = textLabel.textHeight;
			textLabel.wordWrap = true;
			textLabel.width = settings.width;
			textLabel.height = textLabel.textHeight + 4;
			
			var filters:Array = []; 
			
			if (settings.borderSize > 0) 
			{
				filters.push(new GlowFilter(settings.borderColor || 0x7e3e14, 1, settings.borderSize, settings.borderSize, 16, 1));
			}
			
			if (settings.shadowSize > 0) 
			{
				filters.push(new DropShadowFilter(settings.shadowSize, 90, 0x4d3300, 1, 0, 0));
			}
			
			textLabel.filters = filters;
			
			cont.addChild(textLabel);
			cont.mouseEnabled = false;
			cont.mouseChildren = false;
			return cont;
		}
		
		override public function dispose():void
		{			
			for each(var item:* in items)
			{
				if(item.parent)
					item.parent.removeChild(item);
					
				item.dispose();
				item = null;
			}
			
			for each(var icon:* in icons)
			{
				icon.dispose();
				icon = null;
			}
			
			super.dispose();
		}
		
		private var background:Bitmap;
		override public function drawBackground():void
		{
			background = backing(settings.width, settings.height, 30, 'shopBackingNew');
			background.y = 50;
			layer.addChild(background);
		}
		
		override public function drawBody():void
		{
			
			this.y -= 35;
			fader.y += 35;

			var roofBmap:Bitmap = backingShort(769, 'shopRoof');
			
			//roofBmap.scaleX = roofBmap.scaleY = 1.05;
			roofBmap.x = -20;
			roofBmap.y = -70;
			bodyContainer.addChild(roofBmap);
			
			var titleBackingBmap:Bitmap = backingShort(270, 'shopTitleBacking');
			
			//roofBmap.scaleX = roofBmap.scaleY = 1.05;
			titleBackingBmap.x = settings.width/2 -titleBackingBmap.width/2;
			titleBackingBmap.y = -60;
			bodyContainer.addChild(titleBackingBmap);
			
			plankBmap = backingShort(settings.width - 90, 'shopPlank');
			
			//roofBmap.scaleX = roofBmap.scaleY = 1.05;
			plankBmap.x = 45;
			plankBmap.y = 350;
			layer.addChild(plankBmap);
			
			var downPlankBmap:Bitmap = backingShort(300, 'shopPlankDown');
			downPlankBmap.x = settings.width/2 -downPlankBmap.width/2;
			downPlankBmap.y = settings.height - 2;
			layer.addChild(downPlankBmap);
			
			exit.x -= 23;
			exit.y += 39;
			titleLabel.y += 5;
			
			//drawMirrowObjs('storageWoodenDec', -5, settings.width+5, 40,false,false,false,1,-1);
			//drawMirrowObjs('storageWoodenDec', -5, settings.width +5, settings.height - 115);
			
			searchpanel = new SearchShopPanel( {
				win:this, 
				callback:showItem,
				stop:onStopFinding,
				hasIcon:false,
				caption:Locale.__e('flash:1407231372860')
			});
			bodyContainer.addChildAt(searchpanel,1);
			searchpanel.y = paginator.y + (paginator.height - searchpanel.height) / 2 + 28;
			searchpanel.x = 12;
			searchpanel.visible = false;
			
			/*if (!settings.find && (settings.section == 17 || settings.section == 18)) {
				setContentSection(100,settings.page)
			}*/
			drawMirrowObjs('shopButtonRopeUp', 50, settings.width  -50, 130, true, true, false, 1, 1, layer);
			drawMirrowObjs('shopButtonRopeDown', 80, settings.width  -80, 365, true, true, false, 1, 1, layer);
			drawMenu();
			/*if (menu.arrSquence.indexOf(history.section) == 0)
			{
				history.section = menu.arrSquence[0];
			}*/
			if (menu.arrSquence.indexOf(settings.section) == -1)
			{
				settings.section = menu.arrSquence[0];
			}
			if (App.user.worldID == User.AQUA_HERO_LOCATION) 
			{
				if (history.section == 100)
					history.section = 17;			
			} /*else
			{
				if (!settings.find) 
				{
					setContentSection(100, settings.page);
				}				
			}*/
			setContentSection(settings.section, settings.page);
			contentChange();
	
		}
		
		public function showSeach(value:Boolean = true):void 
		{
			searchpanel.visible = value;
			if(searchpanel.isFocus)
				searchpanel.searchField.text = "";
			else
				searchpanel.searchField.text = searchpanel.settings.caption;
		}
		
		private function onStopFinding():void 
		{
			setContentSection(settings.section,settings.page);
		}
		
		private function showItem(content:Array):void 
		{
			settings.content = content;
			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			contentChange();
		}
		
		private var menu:ShopMenu;
		public function drawMenu():void 
		{	
			menu = new ShopMenu(this);
			menu.y = 70;
			
			menu.x = (settings.width - menu.width) / 2;
			bodyContainer.addChild(menu);
		}		
		
		public function setContentSection(section:*, page:Number = -1):Boolean
		{
			clearLabelLeft();
			setBttnPressed(history.section)
			
			if (shop.hasOwnProperty(section)) 
			{
				settings.section = section;
				
				settings.content = shop[section].data;
				paginator.page = page == -1 ? shop[section].page : page;
				
				history.section = section;
				history.page = page;
				
				paginator.itemsCount = settings.content.length;
				paginator.update();
				
			}else 
			{
				return false;
			}
			
			if (settings.section == 100)
			{
				showSeach(false);
				paginator.onPageCount = 3;
			}
			else {
				showSeach();
				paginator.onPageCount = settings.itemsOnPage;
			}
			
			paginator.update();
			contentChange();
			if (settings.section == 14 && ShopWindow.easterTimeEnd > App.time)
			{
				drawLabelLeft();
			}
			return true;
		}
		
		private var leftLabelSprite:LayerX;
		private var leftLabel:Bitmap;
		private var leftLabelTimer:TextField;
		public function clearLabelLeft():void
		{
			if (leftLabel && leftLabel.parent)
				leftLabel.parent.removeChild(leftLabel);
				
			if (leftLabelSprite && leftLabelSprite.parent)
				leftLabelSprite.parent.removeChild(leftLabelSprite);
		}
		
		public function drawLabelLeft():void
		{
			leftLabelSprite = new LayerX();
			leftLabel = new Bitmap(UserInterface.textures.labelLeft);
			leftLabel.smoothing = true;
			leftLabelSprite.addChild(leftLabel)
			
			leftLabelSprite.x = settings.width - leftLabelSprite.width + 25;
			leftLabelSprite.y = 76;
			bodyContainer.addChild(leftLabelSprite);
			
			var leftLabelTitle:TextField = Window.drawText(Locale.__e('flash:1393581955601'), {
				width			:leftLabel.width,
				fontSize		:28,
				autoSize		:"center",
				color			:0x7dfdff,
				borderColor		:0x7d3400
			} );
			leftLabelSprite.addChild(leftLabelTitle);
			leftLabelTitle.x = 45;
			leftLabelTitle.y = 8;
			leftLabelTitle.rotation = 8;
			
			leftLabelTimer = Window.drawText(TimeConverter.timeToCuts( ShopWindow.easterTimeEnd - App.time), {
				color:			0xf5ff57,
				borderColor:	0x7d3400,
				width:			100,
				fontSize:		22,
				textAlign:		'center'
			});
			leftLabelTimer.x = 35;
			leftLabelTimer.y = 45;
			leftLabelTimer.rotation = 8;
			//leftLabelTimer.border = true;
			leftLabelSprite.addChild(leftLabelTimer);
			
			App.self.setOnTimer(updateLabelTime);
		}
		
		//public static var easterTimeEnd:uint = 1492704000;
		public static var easterTimeEnd:uint = 1492693200;
		public function updateLabelTime():void
		{
			var time:int = ShopWindow.easterTimeEnd - App.time;
			if (time <= 0)
			{
				App.self.setOffTimer(updateLabelTime);
				clearLabelLeft();
				if (menu && menu.parent)
					menu.parent.removeChild(menu);
				drawMenu();
				setContentSection(100);
			}
			leftLabelTimer.text = TimeConverter.timeToCuts(time);
		}
		
		public function setContentNews(data:Array):Boolean
		{
			for each(var icon:MenuButton in icons)
			{
				icon.selected = false;
			}
			
			settings.content = data;
			paginator.page = 0;
			
			settings.section = 101;
			paginator.onPageCount = settings.itemsOnPage;
			paginator.itemsCount = settings.content.length;
			paginator.update();
			
			contentChange();
			updateArrows();
			return true;
		}
		
		override public function show():void
		{
			if (App.user.quests.tutorial && QuestsRules.qID == 9 && QuestsRules.mID == 3)
				return;
			if (settings.section == 0)
			{
				settings.section = 100;
				settings.find = null;
			}
			if (App.user.mode == User.OWNER) 
			{
				super.show();
			}
		}
  
		override public function contentChange():void
		{
			for each(var _item:* in items) 
			{
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			
			items = [];
			var X:int = 85;
			var Xs:int = X;
			var Ys:int = 115;			
			var itemNum:int = 0;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:*
				if (settings.section == 100) {
					item = new NewsItem(settings.content[i], this);
					Ys = 115;
				}
				else{
					item = new ShopItem(settings.content[i], this);
				}
				bodyContainer.addChildAt(item, 0);
				item.x = Xs - 10;
				item.y = Ys;
				
				items.push(item);
				
				Xs += item.background.width + 6;
				if (itemNum == int(settings.itemsOnPage / 2) - 1)
				{
					Xs = X;
					Ys += item.background.height + 37;
				}
				
				itemNum++;
			}
			
			if (settings.section == 100)
				showBestSellers();
			else
				hideBestSellers();
			
			if (settings.section == 101)
			{
				updateArrows();
				return;
			}
			if(shop.hasOwnProperty(settings.section))
				shop[settings.section].page = paginator.page;
				
			settings.page = paginator.page;
			history.page = settings.page;
			//if (paginator.arrowLeft)
			updateArrows();
			
		}
		public function updateArrows():void 
		{	
			if (paginator.page == 0 && paginator.arrowLeft)
			{
				paginator.arrowLeft.state = Button.DISABLED;
				paginator.arrowLeft.visible = true;
				//paginator.arrowRight.state = Button.NORMAL;
			}
			if (paginator.page != 0 && paginator.arrowLeft)
			{
				paginator.arrowLeft.state = Button.NORMAL;
				//paginator.arrowRight.state = Button.NORMAL;
			}
			if (paginator.page == paginator.pages-1 && paginator.arrowRight){
				paginator.arrowRight.state = Button.DISABLED;
				paginator.arrowRight.visible = true;
			}
			if (paginator.page != paginator.pages-1 && paginator.arrowRight){
				paginator.arrowRight.state = Button.NORMAL;
			}
		}
		
		override public function drawArrows():void 
		{			
			paginator.drawArrow(bodyContainer, Paginator.LEFT, 0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 14;
			paginator.arrowLeft.x = 50;
			paginator.arrowLeft.y = y + 18;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width + 14;
			paginator.arrowRight.y = y + 18;
			
			paginator.x = (settings.width - paginator.width) / 2 - 10;
			paginator.y = settings.height + 25;
			
			paginator.arrowLeft.visible = true;
			paginator.arrowLeft.state = Button.DISABLED;
			paginator.arrowRight.visible = true;
			paginator.arrowRight.state = Button.DISABLED;
			
			contentChange();
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,
				borderColor 		: 0x70401d,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: 0x70401d,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
				//border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = 13;
			headerContainer.addChild(titleLabel);
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.mouseEnabled = false;
		}
		
		static public function set currentBuyObject(value:Object):void
		{
			_currentBuyObject = value;
		}
		
		static public function get currentBuyObject():Object
		{
			return _currentBuyObject;
		}
		
		public var bestBg:Bitmap = null
		public var bestSellers:BestSellers = null
		public function showBestSellers():void 
		{
			//return;
			if (bestSellers != null) return;
			bestSellers = new BestSellers(this);
			
			bodyContainer.addChild(bestSellers);
			
			bestSellers.y = settings.height - 270;
			bestSellers.x = (settings.width - bestSellers.width) / 2;
			
			paginator.visible = false;
			plankBmap.y = 370;
		}
		
		public function hideBestSellers():void 
		{
			if (bestSellers == null) return			
			bestSellers.dispose();
			bodyContainer.removeChild(bestSellers);
			bestSellers = null;
			paginator.visible = true;
			plankBmap.y = 350;
		}
		
		
		override public function drawExit():void 
		{
			exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 49;
			exit.y = 17;
			if (!App.user.quests.tutorial ) 
			{
				exit.addEventListener(MouseEvent.CLICK, close);
			}
		}
		
		public static var help:int = 0;
		
		public static function findMaterialSource(sid:*, window:Window = null, id:int = 0):Boolean
		{
			// Найти где крафтится
			var happy:Boolean = false;
			var happyID:uint;
			
			var exception:Boolean = false;
			var win:*;
			var finded:Array = [];
			var onMapSIDs:Array = [];
			var linked:Boolean = false;
			var findPlant:Boolean = false;
			
			if (sid == 2 || sid == 3 || sid == 7 || sid == 1367)
			{
				window.close();
				switch (sid) 
				{
					case 3:
						BankMenu._currBtn = BankMenu.REALS;
						BanksWindow.history = {section:'Reals',page:0};
						new BanksWindow({popup:true}).show();
						break;
					case 2:
						BankMenu._currBtn = BankMenu.COINS;
						BanksWindow.history = {section:'Coins',page:0};
						new BanksWindow({popup:true}).show();
						break;
					case 7:
						new PurchaseWindow( {
							popup:true,
							width:716,
							itemsOnPage:4,
							content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Energy'}),
							title:Locale.__e("flash:1382952379756"),
							description:Locale.__e("flash:1382952379757"),
							closeAfterBuy:false,
							autoClose:false,
							callback:function(sID:int):void {
								var object:* = App.data.storage[sID];
								App.user.stock.add(sID, object);
							}
						}).show();
						break;
					case 1367:
						new ShopWindow({'section': 17}).show();
						break;
				}
				return true;
			}
			
			for (var s:* in App.data.storage)
			{
				if ((App.data.storage[s].order && App.data.storage[s].order == 0) || s == 0 || (App.data.storage[s].hasOwnProperty('stopfind') && App.data.storage[s].stopfind == 1))
					continue;
				
				if (App.data.storage[s].type == 'Plant') 
				{
					if (App.data.storage[s].hasOwnProperty('treasure') && App.data.storage[s].treasure)
					{
						for each(var pl_tresh:* in App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure].item)
						{
							if (pl_tresh == int(sid))
							{
								finded.push(s);
								findPlant = true;
								break;
							}
						}
					}
					for (var sids:* in App.data.storage[s].outs)
					{
						if (int(sid) == sids)
						{
							var _arr:Array = World.canBuyOnMap(s)
							if (!_arr || (_arr.length == 1 && App.data.storage[_arr[0]].hasOwnProperty('expire') && App.data.storage[_arr[0]]['expire'].hasOwnProperty(App.social) && App.data.storage[_arr[0]]['expire'][App.social] < App.time))
								continue;
							finded.length = 0;
							finded.push(s);
							findPlant = true;
							break;
						}
					}
				}
				
				if (App.data.storage[s].type == 'Animal')
				{
					if (App.data.storage[s].hasOwnProperty('treasure') && App.data.storage[s].treasure != "" && 
					App.data.treasures[App.data.storage[s].treasure].hasOwnProperty(App.data.storage[s].treasure))	
					{
						var removeTreasure:* = App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure];
						for (var _animitm:* in removeTreasure.item)
						{
							if (removeTreasure.item[_animitm] == int(sid) && removeTreasure.probability[_animitm] == 100)
								finded.push(s);
						}
					}
				}
				
				if (App.data.storage[s].type == 'Animal')
				{
					if (App.data.storage[s].hasOwnProperty('devel') && App.data.storage[s].devel.hasOwnProperty('req'))
					{
						for each(var lvl:* in App.data.storage[s].devel.req)
						{
							for (var needSid:* in lvl.out)
							{
								if (needSid == int(sid))
								{
									finded.push(s);
								}
							}
						}
						
						for each(var rew:* in App.data.storage[s].devel.rew)
						{
							
							if (rew != "" &&  App.data.treasures[rew].hasOwnProperty(rew))
							{
								removeTreasure = App.data.treasures[rew][rew];
								for (_animitm in removeTreasure.item)
								{
									if (removeTreasure.item[_animitm] == int(sid) && finded.indexOf(s) == -1)
										finded.push(s);
								}
								
							}
						}
					}
					
				}
				
				if (App.data.storage[s].type == 'Lamp') 
				{
					var _lampTres:* = App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure];
					for (var _litm:* in _lampTres.item)
					{
						if (_lampTres.item[_litm] == int(sid) && _lampTres.probability[_litm] == 100)
							finded.push(s);
					}
				}
				
				if (App.data.storage[s].hasOwnProperty('devel') && App.data.storage[s].devel[1]) //Ищем всё в админке с devel (Билдинги)
				{
					var crafting:* = App.data.storage[s].devel[1].craft;//В эту переменную насыпали список крафта билдинга
					//for each(var cftItm:* in crafting)//Заходим в цифру
					//{
						for each(var cft:* in crafting)//Проходимся по списку
						{
							if (App.data.crafting.hasOwnProperty(cft) && App.data.crafting[cft].out == int(sid))
							{//Если в общем списке крафтов есть крафт из этого здания и там в out наш материал
								if (App.data.storage[s].type != 'Material') 
								{
									if(s != 988) //ранчо улитки не считаем
										finded.push(s);//Тут пушим здание
								}
								
								/*if (s == 203)
								{
									exception = true;
								}*/
							}
						}
					//}
				}else if (((App.data.storage[s].type == 'Resource' || App.data.storage[s].type == 'Walkresource') && !findPlant) || (App.data.storage[s].type == 'Animal') || (App.data.storage[s].type == 'Tree')) //Или растет // может временно убран поиск по животным
				{
					if (s == 490)//ракушник, что на временной карте
						continue;
						
					var crafting2:* = App.data.storage[s].outs;
					for (var cft2:* in crafting2)
					{
						if (cft2 == int(sid))
						{
							finded.push(s);
						}
					}
				}
				
				if ((App.data.storage[s].type == 'Resource' || App.data.storage[s].type == 'Walkresource') && App.data.storage[s].treasure && App.data.storage[s].hasOwnProperty('treasure'))
				{
					if (App.data.treasures[App.data.storage[s].treasure].hasOwnProperty('remove'))
					{
						for each(var rTresh:* in App.data.treasures[App.data.storage[s].treasure]['remove'].item)
						{
							if (rTresh == int(sid))
							{
								finded.push(s);
							}
						}
					}
					
					if (App.data.treasures[App.data.storage[s].treasure].hasOwnProperty('kick'))
					{
						for each(var kTresh:* in App.data.treasures[App.data.storage[s].treasure]['kick'].item)
						{
							if (kTresh == int(sid))
							{
								finded.push(s);
							}
						}
					}
				}
				
				if ((/*(App.data.storage[s].type == 'Tree') ||*/ (App.data.storage[s].type == 'Box'))) 
				{
					var crafting3:* = App.data.storage[s].out;
					for (var cft3:* in crafting3)
					{
						if (cft3 == int(sid))
						{
							finded.push(s);
						}
					}
				}
				
				if (App.data.storage[s].type == 'Tree')
				{
					var crafting_t:* = App.data.storage[s].out;
					for (var cft_t:* in crafting_t)
					{
						if (cft_t == int(sid))
						{
							finded.push(s);
						}
					}
					for each(var tresh_tree:* in App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure].item)
					{
						if (tresh_tree == int(sid))
						{
							finded.push(s);
						}
					}
				}
				
				
				if (App.data.storage[s].type == 'Ctribute')
				{
					//var crafting4:* = App.data.storage[s].tower;
					for each(var c_tresh:* in App.data.treasures[App.data.storage[s].instance.devel[1].req[Numbers.countProps(App.data.storage[s].instance.devel[1].req)].tr][App.data.storage[s].instance.devel[1].req[Numbers.countProps(App.data.storage[s].instance.devel[1].req)].tr].item)
					{
						if (c_tresh == int(sid))
						{
							finded.push(s);
						}
					}
				}
				if (App.data.storage[s].type == 'Mfloors')
				{
					
					for each(var mitm:* in App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure].item)
					{
						if (mitm == int(sid))
								finded.push(s);
					}
				}
				
				if (App.data.storage[s].type == 'Mfloors')
				{
					for each(var m_tresh:* in App.data.storage[s].tower)
					{
						for each(var tresh_mat:* in App.data.treasures[m_tresh.t][m_tresh.t].item)
						{
							if (tresh_mat == int(sid))
								finded.push(s);
						}
					}
				}
				
				if (App.data.storage[s].type == 'Bridge')
				{
					for each(var b_tresh:* in App.data.storage[s].instance.devel)
					{
						for each(rew in b_tresh.rew){
							if (App.data.storage[sid].type == 'Material' && App.data.storage[sid].mtype == 6 && rew.hasOwnProperty(int(sid)))
								finded.push(s);
						}
					}
				}
				
				if (App.data.storage[s].type == 'Portal')
				{
					for each(var rewp:* in App.data.storage[s].instance.devel[1].rew)
					{
						for (var rewpp:* in rewp)
						{
							if (rewpp == int(sid))
								finded.push(s);
						}
					}
				}
				
				if (App.data.storage[s].type == 'Craftfloors')
				{
					for each(var level:* in App.data.storage[s].levels)
					{
						if (level && level.option && level.option.craft)
						{
							for each (var fID:* in level.option.craft)
							{
								if (App.data.crafting[fID].out == int(sid))
									finded.push(s);
							}
						}
						
					}
				}
				
				if (App.data.storage[s].type == 'Barter')
				{
					for each(var bart:* in App.data.barter)
					{
						for (var itm:* in bart.outs)
						{
							if (itm == int(sid))
								finded.push(bart.building);
						}
					}
				}
				
				if (App.data.storage[s].type == 'Tribute')
				{
					if (!App.data.treasures.hasOwnProperty(App.data.storage[s].treasure))
						continue;
					for (var tresh_tribute:* in App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure].item)
					{
						if (App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure].item[tresh_tribute] == int(sid) &&
						App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure].probability[tresh_tribute] == 100)
						{
							finded.push(s);
						}
					}
				}
				
				if (App.data.storage[s].free) 
				{
					if (s == int(sid))
					{
						finded.push(s);
						//В принятых подарках
						if (window)
						{
							Window.closeAll();
						}
						win = new FreeGiftsWindow( { find:finded, icon:'wishlist', popup:true} );
						win.show();
						return true
					}
				}
				
				/*if (((App.data.storage[s].type == 'Happy') || (App.data.storage[s].type == 'Thappy'))) 
				{
					for (var step:* in App.data.storage[s].tower)
					{
						for (var tresure:* in App.data.storage[s].tower) 
						{
							for each(var mItem:* in App.data.treasures[App.data.storage[s].tower[tresure].t][App.data.storage[s].tower[tresure].t].item) 
							{
								if (mItem == sid) 
								{
									finded.push(s);
									happyID = s;
									happy = true;
									break;
								}
							}	
						}
					}
				}*/
				if (App.data.storage[s].type == 'Arcane')
				{
					if (finded.length != 0)
						continue
					for (var arctreasure:* in App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure].item)
					{
						if (App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure].item[arctreasure] == int(sid))
						{
							finded.push(s);
							if (App.user.stock.count(s) > 0)
							{
								win = new StockWindow({ find:finded, popup: true }).show();
							}
							else
							{
								findMaterialSource(s, window)
								/*new SimpleWindow( {
									hasTitle:		true,
									label:			SimpleWindow.ATTENTION,
									text:			Locale.__e("flash:1482142336166") + '\n' + Locale.__e('flash:1511430664847'),
									popup:			true,
									dialog:			true,
									confirm:		function():void{
										utils.Finder.questInUser(894, true);
										return;
									}
								}).show();	*/
							}
							return true;
						}
					}
					
				}
				if (App.data.storage[s].type == 'Table') 
				{
					for each (var siddz:* in App.data.storage[s]['in'])
					{
						var tr:* = App.data.storage[siddz].treasure;
						if(App.data.treasures[tr] && App.data.treasures[tr][tr] && App.data.treasures[tr][tr].item[0] == sid)
						{
							finded.push(s);
							break;
						}
					}
				}
				
				if (App.data.storage[s].type == 'Twigwam') 
				{
					for each(var sidt:* in App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure].item)
					{
						if (int(sid) == sidt && finded.length == 0)
						{
							finded.push(s);
							break;
						}
					}
				}
				
				
				if (App.data.storage[s].type == 'Fatman')
				{
					for each(var fat:* in App.data.storage[s].barters)
					{
						for each(var ftr:* in App.data.treasures[fat.bonus][fat.bonus].item)
						{
							if (ftr == sid)
							{
								finded.push(s)
								break;
							}
						}
					}
				}
				
				if (App.data.storage[s].type == 'Walkhero')
				{
					var wh:* = App.data.storage[s]
					
					for each (var whlvl:* in wh.levels)
					{
						for each(var whlvl_tresh:* in App.data.treasures[whlvl.bonus][whlvl.bonus].item)
						{
							if (whlvl_tresh == int(sid))
							{
								finded.push(s);
								break;
							}
						}
					}
					for each(var wh_tresh:* in App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure].item)
					{
						if (wh_tresh == int(sid))
						{
							finded.push(s);
							break;
						}
					}
				}
								
				if (App.data.storage[s].type == 'Building') 
				{
					if (s == 1257)
						trace();
				}
				
				if (ObjectsContent.creward.indexOf(sid) != -1 && finded.length == 0 )
				{
					
					if (App.data.storage[s].type == 'Collection')
					{
						for (var ritm:* in App.data.storage[s].reward)
						{
							if (ritm == sid && App.data.storage[ritm].type != 3)
							{
								finded.push(s)
								break;
							}
						}
					}
				}
			}
			
			switch(App.data.storage[sid].type)
			{
				case 'Building':
				case 'Craftfloors':
				case 'Manufacture':
				case 'University':
				case 'Barter':
				case 'Wigwam':
				case 'Tribute':
				case 'Floors':
				case 'Port':
				case 'Tradeship':
				case 'Golden':
				case 'Gamble':
				case 'Zoner':
				case 'Ahappy':
				case 'Mfloors':
				case 'Happy':
				case 'Technological':
				case 'Energy':
				case 'Fair':
				case 'Fatman':
				//case 'Material':
				case 'Boss':
				case 'Mfloors':
				case 'Pfloors':
				case 'Tree':
				case 'Thappy':
				case 'Resource':
				case 'Decor':
				case 'Mfield':
				case 'Box':
				case 'Lamp':
				case 'Buildgolden':
					finded.push(sid);
				break;
			}	
			
			if (App.self.getLength(finded) > 0)
			{
				var onMap:Array = Map.findUnits(finded);
				
				for (var j:int = 0; j < onMap.length; j++) 
				{
					onMapSIDs.push(onMap[j].sid);
				}
				
				for (var i:int = 0; i < onMap.length; i++)
				{
					if (true/*onMap[i].hasOwnProperty('crafted') && onMap[i].crafted == 0*/) 
					{
						if (User.inExpedition) 
						{
							new SimpleWindow( {
								hasTitle:true,
								label:SimpleWindow.ATTENTION,
								title:Locale.__e("flash:1428052352624"),
								text:Locale.__e("flash:1434012531218"),
								popup:true
							}).show();	
							return false
						}
						
						ShopWindow.help = int(sid);
						if (window) 
						{
							Window.closeAll();
						}
						var ready:Boolean = false;
						
						for (var l:int = 0; l < onMap.length; l++)
						{
							if (onMap[l] is Table)
							{
								ready = true;
								break;
							}
							if (onMap[l].hasOwnProperty('level') && onMap[l].level && onMap[l].level == onMap[l].totalLevels)
							{
								ready = true;
							}
							
						}
						if (onMap[onMap.length - 1] is Craftfloors)
							App.user.quests.findTarget(onMapSIDs, false, null, false, sid, false, 'ready');
							//App.user.quests.findTarget(onMapSIDs, true , {'id':id}, true, sid, false, 'ready');
						else if (ready)
						{
							if(id != 0){
								App.user.quests.findTarget(onMapSIDs, false, {'id':id}, false, sid, false, 'ready'); //вызов с проверкой на готовность здания
							}else
								App.user.quests.findTarget(onMapSIDs, false, null, false, sid, false, 'ready'); //вызов с проверкой на готовность здания
						}  else {
							if (exception) 
							{
								App.user.quests.findTarget(onMapSIDs, false, null, false , sid, false, '', exception);	
							} else {
								App.user.quests.findTarget(onMapSIDs, false, null, false, sid, false);
								}
						}
						
						linked = true;
						break;
					} else if ((onMap[i].type == 'Resource') || (onMap[i].type == 'Animal') || (onMap[i].type == 'Plant') || (onMap[i].type == 'Tree') || (onMap[i].type == 'Table'))
					{
						if (window)
						{
							Window.closeAll();
						}
						App.user.quests.findTarget(onMapSIDs, false);
						linked = true;
						break;
					}
				}
				
				if (!linked) 
				{
					if (window)
					{
						Window.closeAll();
					}
					
					var removeFinded:Boolean = true;
					
					for (var k:int = finded.length - 1; k >= 0; k--)
					{
						removeFinded = true;
						
						/*if (!App.data.storage[finded[k]].visible) 
						{
							finded.splice(k, 1);
							continue;
						}*/
						
						for (var section:* in  ShopMenu.menuSettings)
						{
							if (App.data.storage[finded[k]].market == section)
							{
								removeFinded = false;
								break;
							}
						}
						
						if (App.data.storage[finded[k]].hasOwnProperty('lands')) 
						{
							continue;
							var worldsWhereEnable:Array = [];
							for each (var f:* in ui.WorldPanel.allWorlds)
							{
								if (App.data.storage[f].hasOwnProperty('shop')) 
								{
									for (var shopNode:String in App.data.storage[f].shop) 
									{
										if (App.data.storage[f].shop[shopNode].hasOwnProperty(finded[k]) && App.data.storage[f].shop[shopNode][finded[k]] == 1) 
										{
											var all:Array = TravelWindow.getAllIncluded();
											if(all.indexOf(int(f))!=-1)
												worldsWhereEnable.push(f);
										}
									}
								}
							}
							
							Travel.findMaterial = {
								find:[sid]
							}
							
							new WorldsWindow( {
								title: Locale.__e('flash:1415791943192'),
								sID:	finded[k],
								only:	worldsWhereEnable,
								popup:	true
							}).show();
							return true;
						}/*else{
							if (removeFinded) 
							{
								finded.splice(k, 1);								
							}
						}*/
					}					
					
					if (finded.length != 0)//Или пусто
					{
						if (User.inExpedition) 
						{
							new SimpleWindow( {
								hasTitle:true,
								label:SimpleWindow.ATTENTION,
								title:Locale.__e("flash:1428052352624"),
								text:Locale.__e("flash:1434012531218"),
								popup:true
							}).show();	
							return false
						}
						
						var whatToFind:* = 0;
						
						for (var z:* in finded)
						{
							if (World.canBuyOnThisMap(finded[z]) || z >= finded.length - 1)
							{
								whatToFind = finded[z];
								break;
							}
						}
						if (App.data.storage[whatToFind].type == 'Lamp')
						{
							var lampWorlds:Array = [];
							for (var _wID:* in App.user.worlds)
							{
								if (App.data.storage[_wID].lantern && App.data.storage[_wID].lantern == whatToFind)
									lampWorlds.push(_wID);
							}
							if (lampWorlds.length > 0)
							{
								if (lampWorlds.indexOf(App.user.worldID) != -1)
								{
									utils.Finder.focusOnLantern();
								}
								else
								{
									new WorldsWindow( {
										title: Locale.__e('flash:1415791943192'),
										sID:	whatToFind,
										only:	lampWorlds,
										popup:	true
									}).show();
								}
								return true;
							}
						}
						var untOnMap:Array = Map.findUnits([uint(whatToFind)])
						if (untOnMap.length) 
						{	
							App.user.quests.findTarget(finded, false, null, false, sid);
						}else {
							var finnded:Boolean = false;
							var worldsWhereEnable2:Array = [];
							for (var jm:* in App.user.maps) 
							{
								if (finnded)
									break;
								for (var mapa:* in App.user.maps[jm].ilands)
								{
									//if (finnded)
										//break;
									//for each(var fnded:* in finded)
									//{
										if (World.canBuyOnThatMap(finded[0], mapa) && worldsWhereEnable2.indexOf(mapa) == -1)
										{
											var updtItems:Array = Stock.notAvailableItems();
											if (updtItems.indexOf(mapa) == -1)
											{
												worldsWhereEnable2.push(mapa);
												finnded = true;
												//break;
											}
										}
									//}
									
								}
							}
							
							if (App.data.storage[finded[0]].type == 'Collection')
							{
								new CollectionWindow( { find:[finded[0]] } ).show();
								return true;
							}
							
							if (!World.canBuyOnThisMap(finded[0]))
							{
								Travel.findMaterial = {
									find:[sid]
								}
								new WorldsWindow( {
									title: Locale.__e('flash:1415791943192'),
									sID:	finded[0],
									only:	worldsWhereEnable2,
									popup:	true
								}).show();
								//return true;
							}else
							{
								if (finded.indexOf(2085) != -1 && finded.indexOf(2086) != -1)
								{
									new SimpleWindow( {
										title:Locale.__e("flash:1474469531767"),
										label:SimpleWindow.ATTENTION,
										text:Locale.__e('flash:1502792316373'),
										popup:true
									}).show();
									return true;
								}
								else
									new ShopWindow( { find:finded } ).show();			
							}
						}
					linked = true;	
					}else {
						
						new SimpleWindow( {
							hasTitle:true,
							label:SimpleWindow.ATTENTION,
							title:Locale.__e("flash:1382952379725"),
							text:(happy)?Locale.__e("flash:1445437620797",App.data.storage[happyID].title):Locale.__e("flash:1424966879700")//К сожалению пока отсутствует на территории/Кипит работа
						}).show();	
					}
				}
			} else {
				
				if (App.data.storage[sid].type == 'Animal')//Поиск животных в магазине на других локациях через WorldsWindow из окна QuestWindow
				{
					finded.push(sid);
					new ShopWindow( { find:finded } ).show();
				}else 
				{
					new SimpleWindow( {
						hasTitle:true,
						label:SimpleWindow.ATTENTION,
						text			:Locale.__e("flash:1482142336166") + '\n' + Locale.__e('flash:1507967972859'),
						//text:Locale.__e("flash:1482142336166"),//Что-то новенькое! Стоит поискать подробности в обновлениях
						popup:true,
						dialog:true,
						confirm:function():void{
							for (var qID:* in App.data.quests)
							{
								if (App.user.quests.data.hasOwnProperty(qID) && App.user.quests.data[qID].finished)
									continue;
								if (App.data.quests[qID].hasOwnProperty('bonus') && App.data.quests[qID].bonus != null)
								{
									if (App.data.quests[qID].bonus.hasOwnProperty('materials') && App.data.quests[qID].bonus.materials != '')
									{
										for (var bID:* in App.data.quests[qID].bonus.materials)
										{
											if (bID == int(sid))
											{
												utils.Finder.questInUser(qID, true);
												//new QuestsChaptersWindow({find:[qID], popup:true}).show();
												return;
											}
											
										}
									}

								}
							}
						}
					}).show();	
				}
				
			}
			return linked;
		}
		
		/*static private function checkAmuletPart(sid:*, window:Window):Boolean
		{
			if (AmuletWindow.amuletArr.indexOf(sid) != -1) {
				Window.closeAll();
				new AmuletWindow( { find:sid } ).show();
				return true;
			}
			return false;
		}*/
	}
}

import buttons.Button;
import buttons.ImageButton;
import buttons.MoneySmallButton;
import com.greensock.TweenMax;
import core.Load;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import ui.Cursor;
import ui.Hints;
import units.Anime;
import units.Field;
import units.Unit;
import wins.ShopWindow;
import wins.SimpleWindow;
import wins.Window;

internal class NewsItem extends Sprite {
	
	public var item:*;
	public var update:*;
	public var background:Bitmap;
	public var bttn:ImageButton;
	public var preloader:Preloader = new Preloader();
	public var title:TextField;
	public var priceBttn:Button;
	public var openBttn:Button;
	public var window:*;
	private var maska:Shape
	private var timerCaption:TextField;
	private var timerLabel:TextField;
	private var timerContainer:Sprite;
	
	public function NewsItem(item:*, window:*) {
		
		this.item = item;
		this.window = window;
		
		update = App.data.updates[item.id];
		
		background = Window.backing(187, 205, 10, "banksBackingItem");
		addChild(background);
		
		if (ShopWindow.glowFirstNewsItem && ShopWindow.currentUpdateID == item.id) 
		{
			customGlowing(background);
		}
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		maska = new Shape();
		maska.graphics.beginFill(0xFFFFFF, 1);
		maska.graphics.drawRoundRect(0, 0, background.width-10, background.height-8, 20, 20);
		maska.graphics.endFill();
		
		maska.x = (background.width - maska.width) / 2;
		maska.y = (background.height - maska.height) / 2;
		
		bttn = new ImageButton(new BitmapData(100,100,true,0));
		addChild(bttn);		
		addChild(maska)
		bttn.mask = maska
		
		addChild(preloader);
		preloader.x = (background.width)/ 2;
		preloader.y = (background.height) / 2;
		
		Load.loading(Config.getImageIcon('updates/icons', update.preview, 'jpg'), onLoad); 
		drawTitle();
		
		//if (update.temporary)
		if (update.hasOwnProperty('temporary') && update.temporary && ((App.data.updatelist[App.social][item.id] + update.duration*3600) > App.time))
			drawTemporary();
	}
	private function drawTemporary():void 
	{
		timerContainer = new Sprite();
		timerCaption = Window.drawText(Locale.__e('flash:1393581955601'),{
			width:			200,
			textAlign:		'center',
			color:			0xffffff,
			borderColor:	0x7e3e13,
			fontSize:		28
		});
		
		timerLabel = Window.drawText(String(TimeConverter.timeToDays(App.data.updatelist[App.social][item.id] + update.duration*3600 - App.time)), {
			width:			200,
			textAlign:		'center',
			color:			0xfed955,
			borderColor:	0x7a4004,
			fontSize:		34
		});
		timerLabel.y = timerCaption.y + 30;
		timerLabel.x = timerCaption.x + (timerLabel.width - timerCaption.width) / 2;
		timerContainer.addChild(timerCaption)
		timerContainer.addChild(timerLabel)
		
		timerContainer.x = background.x + (background.width - timerContainer.width) / 2;
		timerContainer.y = background.y + background.height - 70;
		
		addChild(timerContainer)
		timerContainer.mouseEnabled = false;
		App.self.setOnTimer(redrawTime);
	}
	
	private function redrawTime():void 
	{
		var time:uint = App.data.updatelist[App.social][item.id] + update.duration*3600 - App.time
		if(time > 0)
			timerLabel.text = TimeConverter.timeToDays(time);
		else{
			App.self.setOffTimer(redrawTime);
			window.close();
		}
	}
	
	private function autoSize(txt:TextField):void 
	{
		var maxTextWidth:int = 145; 
		var maxTextHeight:int = 30; 
		
		var f:TextFormat = txt.getTextFormat();
		
		while (txt.textWidth > maxTextWidth || txt.textHeight > maxTextHeight) 
		{
			f.size = int(f.size) - 1;
			txt.setTextFormat(f);
		}
	}
	
	private function drawTitle():void 
	{
		/*var size:Point = new Point(background.width, 30);
		var pos:Point = new Point(
			0,
			8
			);*/
		var title:TextField = Window.drawText(String(update.title),
		{
			color:0xffffff,
			borderColor:0x7c3f15,
			textAlign:"center",
			autoSize:"center",
			fontSize:30,
			textLeading:-6,
			multiline:true
		});
		
		title.wordWrap = true;
		title.width = background.width;
		title.y = 8;
		title.x = 0;
		
		Size.fitImtoTextField(title);
		addChild(title)
	}
	
	private function customGlowing(target:*, callback:Function = null, colorGlow:uint = 0xFFFF00):void 
	{
		TweenMax.to(target, 1, { glowFilter: { color:colorGlow, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 1, { glowFilter: { color:colorGlow, alpha:0, strength: 3, blurX:2, blurY:2 }, onComplete:function():void {
				if (callback != null) {
					callback();
				}
			}});	
		}});
	}
	
	private function onLoad(data:Bitmap):void
	{		
		removeChild(preloader);
		
		bttn.bitmapData = data.bitmapData
		bttn.scaleX = bttn.scaleY = 1.2;
		bttn.x = (background.width - bttn.width) / 2;
		bttn.y = (background.height - bttn.height) / 2;
		bttn.bitmap.smoothing = true;
		
		bttn.addEventListener(MouseEvent.CLICK, onClick);		
	}
	
	private function onClick(e:MouseEvent):void
	{
		window.setContentNews(item.data);
	}
	
	public function dispose():void 
	{
		if (bttn != null) bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
}

internal class BestSellers extends Sprite
{
	private var back:Shape = new Shape();
	public var win:*;
	public var items:Array = [];
	public var content:Array = [];
	
	public function BestSellers(win:*) {
		
		
		for each(var sid:* in App.data.bestsellers) {
			
			var item:Object = App.data.storage[sid];
			
			if (item != null && item.visible != 0)
			{
				if (item.hasOwnProperty('instance') && (World.getBuildingCount(sid) >= getInstanceNum(sid) || App.user.level < item.instance.level[World.getBuildingCount(sid) + 1])) 
					continue;
				
				if ((item.type == 'Resource' || item.type == 'Decor') && App.user.level < item.level)
					continue;
					
				//if(checkNotInWorld(sid))
					//continue;	
				
				item.id = sid;
				item['_order'] = int(Math.random() * 100);
				content.push(item);
			}
		}
		
		content.sortOn('_order');
		
		this.win = win;
		
		drawItems();
		drawTitle();
	}
	
	private function checkNotInWorld(sid:int):Boolean
	{
		var itemsData:Object = ShopWindow.worldShop;
		var end:Boolean = false;
		
		for (var sect:* in itemsData)
		{
			for (var ind:* in itemsData[sect])
			{
				if (sid == ind && itemsData[sect][ind] == 0)
				{
					end = true;
					break;
				}
			}
		}
		return end;
	}
	
	private function getInstanceNum(sid:int):int
	{
		var count:int = 0;
		for each(var inst:* in App.data.storage[sid].instance['level'])
		{
			count++;
		}
		return count;
	}
	
	public function drawItems():void {
		
		var cont:Sprite = new Sprite();
		var X:int = 12;
		
		var _length:int = Math.min(5, content.length);
		for (var i:int = 0; i < _length; i++)
		{
			var item:BestSellerItem = new BestSellerItem(content[i], this);
			cont.addChild(item);
			item.x = X;
			X += item.bg.width + 9;
		}
		
		cont.y = 55;
		cont.x = -11;
		addChild(cont);
	}
	
	private function drawTitle():void 
	{
		back.graphics.beginFill(0xfffeb9, .9);
		back.graphics.drawRect(0, 0, 270, 18);
		back.graphics.endFill();
		back.x = 165;
		back.y = 22;
		back.filters = [new BlurFilter(20, 0, 2)];
		addChild(back);
		
		var title:TextField = Window.drawText(Locale.__e('flash:1382952380296'), {
			color:0xfedb39,
			borderColor:0x7c3f15,
			textAlign:"center",
			autoSize:"center",
			fontSize:32,
			textLeading:-6,
			multiline:true
		});
		
		title.wordWrap = true;
		title.width = win.settings.width - 160;
		title.y = 11;
		title.x = 15; // 27
		
		var ct:ColorTransform = new ColorTransform(3, 3, 2);
		//var sep1:Bitmap = Window.backingShort(500, "dividerLight", false);
		//var sep2:Bitmap = Window.backingShort(500, "dividerLight", false);
		
		/*sep1.transform.colorTransform = sep2.transform.colorTransform = ct;
		sep1.x = 0;
		sep1.y = title.y + 8;
		sep1.alpha = 0.5;		
		
		sep2.x = 700;
		sep2.y = title.y + 8;
		sep2.scaleX *= -1;
		sep2.alpha = 0.5;
		
		addChild(sep1);
		addChild(sep2);*/
		addChild(title);
	}
	
	public function dispose():void
	{
		for each(var _item:* in items) 
		{
			_item.dispose();
		}
	}
}


internal class BestSellerItem extends Sprite 
{	
	public var bg:Bitmap;
	public var item:Object;
	private var bitmap:Bitmap;
	private var buyBttn:Button;
	private var buyBttnNow:MoneySmallButton;
	private var _parent:*;
	private var sprite:LayerX;
	private var preloader:Preloader = new Preloader();
	
	public function BestSellerItem(item:Object, parent:*)
	{		
		this._parent = parent;
		this.item = item;
		bg = Window.backing(110, 120, 20, 'banksBackingItemBest');
		
		addChild(bg);
		
		sprite = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		sprite.tip = function():Object { 
			
			if (item.type == "Plant")
			{
				return {
					title:item.title,
					text:Locale.__e("flash:1382952380297", [TimeConverter.timeToCuts(item.levelTime * item.levels), item.experience, App.data.storage[item.out].cost])
				};
			}
			else if (item.type == "Decor")
			{
				return {
					title:item.title,
					text:Locale.__e("flash:1382952380076", String(item.experience))
				}	
			}
			else
			{
				return {
					title:item.title,
					text:item.description
				};
			}
		};
		
		drawTitle();
		drawBttn();
		
		addChild(preloader);
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height) / 2;
		preloader.scaleX = preloader.scaleY = 0.67;
		
		//if ((item.type == 'Decor' || item.type == 'Golden' || item.type == 'Walkgolden')) 
		//{
			//Load.loading(Config.getSwf(item.type, item.preview), onLoadAnimate);	
		//} else {		
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		//}
	}
	
	private function onLoad(data:Bitmap):void
	{
		if (preloader)
		{
			removeChild(preloader);
			preloader = null;
		}
		
		bitmap.bitmapData = data.bitmapData;
		
		Size.size(bitmap, 50, 80);
		
		bitmap.smoothing = true;
		
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
		
		if (item.preview == 'crupie') {
			sprite.scaleX = sprite.scaleY = 1.2;
			sprite.y -= 10;
			sprite.x -= 20;
		}
	}
	
	private function onLoadAnimate(swf:*):void
	{
		if (preloader)
		{
			removeChild(preloader);
			preloader = null;
		}
		
		if (!sprite) 
		{ 
			sprite = new LayerX();
		}
		
		if (!contains(sprite)) addChild(sprite);
		
		var bitmap:Bitmap = new Bitmap(swf.sprites[swf.sprites.length - 1].bmp, 'auto', true);
		bitmap.x = swf.sprites[swf.sprites.length - 1].dx;
		bitmap.y = swf.sprites[swf.sprites.length - 1].dy;
		sprite.addChild(bitmap);
		
		if (swf.animation)
		{
			var framesType:String;
			for (framesType in swf.animation.animations) break;
			var anime:Anime = new Anime(swf, framesType, swf.animation.ax, swf.animation.ay);
			sprite.addChild(anime);
			anime.startAnimation();
			
			anime.tip = function():Object { 				
				return {
					title:item.title,
					text:item.description
				};
			};
		}
		
		if (sprite.width > bg.width - 20) 
		{
			sprite.scaleX = sprite.scaleY = (bg.width - 20)/(sprite.width);
		}
		
		if (sprite.height > bg.height - 60 ) 
		{
			sprite.height =  bg.height - 60;
			sprite.scaleX = sprite.scaleY;
		}
		
		sprite.x = bg.x + bg.width / 2;
		sprite.y = bg.y + bg.height / 2 + 15;
	}
	
	public function drawTitle():void 
	{
		/*var size:Point = new Point(110, 30);
		var pos:Point = new Point(
		(bg.width - size.x)/2,
		 5
		 );*/
		var title:TextField = Window.drawText(String(item.title), {
			color:0x814f31,
			borderColor:0xfcf6e4,
			textAlign:"center",
			fontSize:20,
			textLeading: -6,
			multiline:true,
			wrap:true,
			width:bg.width - 5
		});
		title.x = (bg.width - title.x) / 2 - 52;
		title.y = -5;
		addChild(title);
	}
	
	public function drawBttn():void
	{		
		var isBuyNow:Boolean = false;
		
		var bttnSettings:Object = {
			caption     :Locale.__e("flash:1382952379751"),
			width		:80,
			height		:35,	
			fontSize	:24,
			scale		:0.8,
			hasDotes    :false,
			fontCountBorder :0x2b4a84
		}
		
		/*if (item.cost) 
		{
			bttnSettings['type'] = 'real';
			bttnSettings['countText'] = item.price;
			bttnSettings["bgColor"] = [0x65b8ef, 0x567dd0];
			bttnSettings["borderColor"] = [0xcce8fa, 0x4465b6];
			bttnSettings["bevelColor"] = [0xa6d7f6, 0x4465b6];
			bttnSettings["fontColor"] = 0xffffff;				
			bttnSettings["fontCountBorder"] = 0x2b4a84;
			bttnSettings['greenDotes'] = false;
			isBuyNow = true;
		}else */if (item.price && item.price[Stock.COINS]) 
		{
			bttnSettings['type'] = 'coins';
			bttnSettings['countText'] = item.price[Stock.COINS];
			bttnSettings['scale'] = .6;
			bttnSettings["fontCountBorder"] = 0x2b4a84;
			isBuyNow = true;
		}else if (item.price && item.price[Stock.FANT])
		{
			bttnSettings['type'] = 'real';
			bttnSettings['countText'] = item.price[Stock.FANT];
			bttnSettings["bgColor"] = [0x65b8ef, 0x567dd0];
			bttnSettings["borderColor"] = [0xcce8fa, 0x4465b6];
			bttnSettings["bevelColor"] = [0xa6d7f6, 0x4465b6];
			bttnSettings["fontColor"] = 0xffffff;				
			bttnSettings["fontCountBorder"] = 0x2b4a84;
			bttnSettings['greenDotes'] = false;
			bttnSettings['scale'] = .5;
			bttnSettings['countDy'] = 3;
			isBuyNow = true;
		}else if (item.instance) 
		{
			var count:int = World.getBuildingCount(item.sID);
			if (count == 0)
				count = 1;
			if (item.instance.cost && item.instance.cost[count][Stock.FANT]) {
				bttnSettings['type'] = 'real';
				bttnSettings["bgColor"] = [0xa9f84a, 0x73bb16];
				bttnSettings["borderColor"] = [0xcce8fa, 0x4465b6];
				bttnSettings["bevelColor"] = [0xa6d7f6, 0x4465b6];
				bttnSettings["fontColor"] = 0xffffff;				
				bttnSettings["fontCountBorder"] = 0x2b4a84;
				bttnSettings['greenDotes'] = false;
				bttnSettings["countText"] = item.instance.cost[count][Stock.FANT];
				isBuyNow = true;
			}
		}
		
		if (!isBuyNow)
		{
			buyBttn = new Button(bttnSettings);
			addChild(buyBttn);
			buyBttn.x = (bg.width - buyBttn.width) / 2;
			buyBttn.y = bg.height - 24;
			
			buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
		}else {
			buyBttnNow = new MoneySmallButton(bttnSettings);
			addChild(buyBttnNow);
			buyBttnNow.x = (bg.width - buyBttnNow.width) / 2;
			buyBttnNow.y = bg.height - 24;
			buyBttnNow.addEventListener(MouseEvent.CLICK, onBuyNow);
			buyBttnNow.coinsIcon.y -= 4;
		}
	}
	
	private function onBuyNow(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		//e.currentTarget.state = Button.DISABLED;
		
		new SimpleWindow( {
			title: Locale.__e("flash:1382952379751"),
			text: Locale.__e("flash:1493797546673", [item.title]),
			label: SimpleWindow.ATTENTION,
			popup:true,
			dialog: true,
			//isImg: true,
			confirm: function():void {
				/*onApplyRemove(callback)*/
				onBuyConfirm();
			}
		}).show();
				
		/*ShopWindow.currentBuyObject = { type:item.type, sid:item.sid };
		
		var unit:Unit;
		switch(item.type)
		{
			case "Material":
				App.user.stock.buy(item.sid, 1, onBuyComplete);
				break;
			case "Boost":
			case "Energy":
				App.user.stock.pack(item.sid, onBuyComplete);
				break;
			case "Plant":
				if(Field.exists == false){
					unit = Unit.add( { sid:13 } );
					unit.move = true;
					App.map.moved = unit;
					Cursor.plant = item.sid;
				}
				Field.exists = false;
				break;
			default:
				unit = Unit.add( { sid:item.sid, buy:true } );				
				unit.move = true;
				App.map.moved = unit;				
			break;
		}
		
		if (item.type != "Material")
		{
			_parent.win.close();
		}*/
		
	}
	
	private function onBuyConfirm():void
	{
		ShopWindow.currentBuyObject = { type:item.type, sid:item.sid };
		
		var unit:Unit;
		switch(item.type)
		{
			case "Material":
				App.user.stock.buy(item.sid, 1, onBuyComplete);
				break;
			case "Boost":
			case "Energy":
				App.user.stock.pack(item.sid, onBuyComplete);
				break;
			case "Plant":
				if(Field.exists == false){
					unit = Unit.add( { sid:13 } );
					unit.move = true;
					App.map.moved = unit;
					Cursor.plant = item.sid;
				}
				Field.exists = false;
				break;
			default:
				unit = Unit.add( { sid:item.sid, buy:true } );				
				unit.move = true;
				App.map.moved = unit;				
			break;
		}
		
		/*if (item.type != "Material")
		{
			_parent.win.close();
		}*/
	}
	
	public function onBuyComplete(type:*, price:uint = 0):void 
	{
		if (!buyBttn)
			buyBttn = buyBttnNow;
		var point:Point = new Point(App.self.mouseX - buyBttn.mouseX, App.self.mouseY - buyBttn.mouseY);
		point.x += buyBttn.width / 2;
		Hints.minus(Stock.FANT, item.real, point, false, App.self.tipsContainer);
		buyBttn.state = Button.NORMAL;		
		flyMaterial();
	}	
	
	private function onBuy(e:MouseEvent):void
	{
		_parent.win.close();
		new ShopWindow( { find:[item.sID], forcedClosing:true, popup: true } ).show();
	}	
	
	public function dispose():void 
	{
		if(buyBttn)buyBttn.removeEventListener(MouseEvent.CLICK, onBuy);
		if(buyBttnNow)buyBttn.removeEventListener(MouseEvent.CLICK, onBuyNow);
	}
	
	private function flyMaterial():void
	{
		var item:BonusItem = new BonusItem(item.sid, 0);		
		var point:Point = Window.localToGlobal(bitmap);
		point.y += bitmap.height / 2;
		item.cashMove(point, App.self.windowContainer);
	}
}