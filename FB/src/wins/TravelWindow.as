package wins
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import buttons.UpgradeButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import ui.Hints;
	import ui.UserInterface;
	import utils.ObjectsContent;
	import wins.elements.ProductionItem;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class TravelWindow extends Window
	{	
		public static var history:int = 0;		
		public static var pages:Array;
		
		public var items:Array;
		public var titleTextField:TextField;
		public var containerMap:Sprite;
		public var image:Bitmap;
		public var topIronBacking:Bitmap;
		public var container:Sprite;
		public var homeBttn:ImageButton;
		public var preloader:Preloader;
		public var unavailableWorldsJson:Object;	
		private var lines:Vector.<Shape>;
		private var back:Shape;
		private var thisFader:Sprite;
		private var circle:Shape;
		private var listMapBttn:ImageButton;
		
		private var thisWindowMask:Shape;
		
		public function TravelWindow(settings:Object = null)
		{			
			if (settings == null) settings = { };
			
			settings['title'] = Locale.__e("flash:1432116737753");
			settings['width'] = Math.min(1400, App.self.stage.stageWidth);
			settings['height'] = Math.min(883,App.self.stage.stageHeight);
			settings['hasArrows'] = true;
			settings['itemsOnPage'] = 1;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasTitle'] = false;
			settings['fontColor'] = 0x003f6b;
			settings['find'] = settings['find'] || 0;
			settings['exitTexture'] = 'closeBttnMetal';
			
			super(settings);
			getPages();
			
			App.self.addEventListener(AppEvent.ON_RESIZE, resize);
		}
		
		private var radarsVector:Vector.<RadarItem>;
		public function generateRadarLocation():void
		{
			clearRadarItems();
			var scale:Number = image.scaleX;
				
			for each(var _item:* in App.user.openedRadarMaps)
			{
				if (App.data.storage[_item].expire[App.social] < App.time)
					continue;
					
				var radarItem:RadarItem = new RadarItem( {
					sID:		int(_item),
					window:		this,
					link:		Config.getIcon('Lands', 'radar')
				});
				
				if (App.user.data.hasOwnProperty('tempWorlds') && App.user.data['tempWorlds'].hasOwnProperty(_item))
				{
					radarItem.x = App.user.data['tempWorlds'][_item]['x'];
					radarItem.y = App.user.data['tempWorlds'][_item]['y'];
				}
				
				container.addChild(radarItem);
				radarsVector.push(radarItem);
				
				if (settings.find == int(_item))
				{
					radarItem.startGlowing();
					radarItem.showPointing("top", -radarItem.width / 2, -58, radarItem.parent);
					focusOnItem(radarItem, true);
				}
			}
			/*if (Config.admin)
			{
				radarItem.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
				radarItem.addEventListener(MouseEvent.MOUSE_UP, onUp);
			}*/
		}
		
		private function clearRadarItems():void
		{
			if (radarsVector)
			{
				while (radarsVector.length > 0)
				{
					radarsVector[0].dispose();
					radarsVector.splice(0, 1);
				}
			}
			radarsVector = new Vector.<RadarItem>();
		}
		
		private var focusedForFind:Boolean = false;
		public function focusOnItem(item:*, forFind:Boolean = false):void
		{
			if (item && !focusedForFind)
			{
				focusedForFind = forFind;
				
				containerMap.x = -(item.x) + settings.width / 2;
				containerMap.y = -(item.y) + settings.height / 2;
				
				if (containerMap.x < settings.width - 20 - image.width)
					containerMap.x = settings.width - 20 - image.width;
					
				if (containerMap.x > 0)
					containerMap.x = 0;
					
				if (containerMap.y < settings.height - 20 - image.height)
					containerMap.y = settings.height - 20 - image.height;
					
				if (containerMap.y > 0)
					containerMap.y = 0;
			}
		}
		
		public static function getPages():Array 
		{
			pages = [];
			for (var i:* in App.user.maps) 
			{
				pages[i] = App.user.maps[i].ilands; 
				for (var j:* in App.user.maps[i].ilands)
				{				
					if (!User.inUpdate(j)) 
					{
						delete(pages[i][j])
					}
				}
			}
			
			return pages
		}
		
		private var background:Shape = new Shape();
		override public function drawBackground():void{}
		
		public static var images:Object = {
			0: { bgColor:0x310f27, title:App.data.storage[807].title, bmd:null },
			1: { bgColor:0x310f27, title:App.data.storage[2765].title, bmd:null }
		};
		
		public static function getAllIncluded():Array
		{
			var allMaps:Array = [];
			var pagesArr:Array = getPages();
			for (var pg:* in pagesArr)
			{
				for (var mp:* in pagesArr[pg])
				{
					allMaps.push(int(mp));
				}
			}
			return allMaps;
		}
		
		override public function drawBody():void 
		{	
			background = new Shape();
			bodyContainer.addChild(background);
			
			containerMap = new Sprite();
			bodyContainer.addChild(containerMap);
			
			image = new Bitmap();
			containerMap.addChild(image);
			
			container = new Sprite();
			containerMap.addChild(container);
			thisFader = new Sprite();
			
			circle = new Shape();
			circle.graphics.beginFill(0, 1);
			circle.graphics.drawCircle(0, 0, 100 * 0.8);
			circle.graphics.endFill();
			circle.filters = [new BlurFilter(20, 20)];
			thisFader.addChild(circle);
			
			topIronBacking = new Bitmap();
			bodyContainer.addChild(topIronBacking);
			
			titleLabel = new Sprite();
			bodyContainer.addChild(titleLabel);
			titleTextField = Window.drawText(settings['title'], {
				fontSize:		46,
				color:			0xfeee9a,
				borderColor:	0x003f6b,
				shadowSize:     5,
				shadowColor:    0x461f34,
				autoSize:		'center'
			});
			titleTextField.x = -titleTextField.width / 2;
			titleTextField.y = 10;
			titleLabel.addChild(titleTextField);
			
			homeBttn = new ImageButton(UserInterface.textures.homeBttnIco);
			homeBttn.addEventListener(MouseEvent.CLICK, onHome);
			bodyContainer.addChild(homeBttn);
			
			// Paginator
			paginator.page = 0;
			
			var targetLandSid:int = 0;
			if (settings.find is Array) 
			{
				targetLandSid = settings.find[0];
			}else if (settings.find is int) 
			{
				targetLandSid = settings.find;
			}
			
			if (targetLandSid && App.data.storage.hasOwnProperty(targetLandSid) && App.data.storage[targetLandSid].type == 'Lands')
			{
				for (var page:* in pages)
				{
					if (pages[page].hasOwnProperty(targetLandSid))
						paginator.page = int(page);
				}
			}
			
			paginator.onPageCount = 1;
			paginator.itemsCount = Numbers.countProps(pages);
			paginator.update();
			drawPageBttns();
			contentChange();
			if (Travel.synopticMaps.length > 0)
				drawListMap();
		}
		
		private function onHome(e:MouseEvent):void 
		{
			if (homeBttn.mode == Button.DISABLED) return;
			
			if (App.user.worldID != User.HOME_WORLD)
				Travel.goHome();
			
			close();
		}
		
		private function onUpgrade(e:MouseEvent):void 
		{
			if (settings.target && settings.target.level < settings.target.totalLevels) 
			{
				settings.target.openConstructWindow();
				close();
			}
		}
		
		public function relocateCircle(e:MouseEvent):void
		{
			circle.x = mouseX;
			circle.y = mouseY;
		}
		
		public function resize(e:AppEvent = null):void
		{
			background.graphics.beginFill(0xecb674, 1);
			background.graphics.drawRect(0, 0, settings.width-23, settings.height-23);
			background.graphics.endFill();
			background.x = (settings.width - background.width) / 2;
			background.y = (settings.height - background.height) / 2;
			
			thisFader.graphics.beginFill(0x091b43, .7);
			thisFader.graphics.drawRect(0, 0, settings.width-23, settings.height-23);
			thisFader.graphics.endFill();
			thisFader.x = (settings.width - thisFader.width) / 2;
			thisFader.y = (settings.height - thisFader.height) / 2;
			
			var topIronBackingD:Bitmap = backing(settings.width, settings.height, 50, 'ironBacking');
			topIronBacking.bitmapData = topIronBackingD.bitmapData;
			background.x = (settings.width - background.width) / 2;
			background.y = (settings.height - background.height) / 2;
			exit.x = background.x + background.width - 30 - 28;
			exit.y = background.y - 0;
			
			titleLabel.x = settings.width / 2;
			titleLabel.y = background.y + 10;
			homeBttn.x = background.x;
			homeBttn.y = background.y;
			bttnContainer.x = (settings.width - bttnContainer.width) / 2;
			bttnContainer.y = background.y + background.height - bttnContainer.height - 12;
			
			arrowsUpdate();
			drawImage();
			itemsResize();
			focusOnItem(TravelItem.currentWorld);
		}
		
		public function drawImage():void 
		{
			if (!images[paginator.page].bmd)
			{
				if (!preloader)
				{
					preloader = new Preloader();
					bodyContainer.addChild(preloader);
				}
				preloader.x = settings.width / 2;
				preloader.y = settings.height / 2;
				Load.loading(Config.getImage('content', 'map_2', 'jpg'), onLoad);
			}
			
			image.bitmapData = images[paginator.page].bmd;
			image.smoothing = true;
			
			container.x = image.x;
			container.y = image.y;
		}
		
		private var loadded:Boolean = false;
		private function onLoad(data:Bitmap):void
		{
			if (preloader && bodyContainer.contains(preloader))
			{
				bodyContainer.removeChild(preloader);
				preloader = null;
			}
			
			loadded = true;
			
			for (var i:int = 0; i < items.length; i++) 
			{
				items[i].visible = true;
				if (!App.user.worlds.hasOwnProperty(items[i].sID) && App.data.storage[items[i].sID].hasOwnProperty('items')){
					items[i].visible = false;
				}
			}
			images[paginator.page].bmd = data.bitmapData;
			//generateRadarLocation();
			coordsPoint();
			drawImage();
			contentChange();
			itemsResize();
			addMask();
			
		}

		public function onDownDraggingMap(e:MouseEvent):void 
		{
			deltaX = e.stageX;
			deltaY = e.stageY;
			
			if ((containerMap.width <= settings.width + 100) &&
			containerMap.height <= settings.height + 100
			) return;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private var coords:Object;
		private function coordsPoint():void
		{
			coords = {
				'2133':{
					'wID':2133,
					'x':[170, 180, 190, 200, 210, 218, 224, 234],
					'y':[20, 19, 17, 13, 8, 2, -5, -15]
				},
				'2001':{
					'wID':2001,
					'x':[10, 20, 30, 40, 50, 60, 70, 80, 95, 104],
					'y':[50, 60, 65, 65, 64, 62, 60, 58, 51, 45]
				},
				'1627':{
					'wID':1627,
					'x':[10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 108, 115, 125, 135, 145, 155, 165, 175, 185, 195, 205, 215, 225, 235, 245, 253, 257, 260, 260, 260, 254, 246, 235, 226, 217, 207, 197, 187, 177, 167, 157, 147, 137, 127, 117, 109, 103, 99 , 93 , 83 , 73 , 63 , 53 , 43 , 33 , 23 , 13 , 4  , -5 , -14, -24 , -31, -36 , -38],
					'y':[50, 60, 65, 65, 64, 62, 60, 58, 58, 62 , 68 , 76 , 80 , 82 , 84 , 84 , 84 , 84 , 85 , 86 , 87 , 89 , 91 , 93 , 96 , 103, 112, 120, 130, 140, 151, 156, 161, 165, 168, 171, 171, 171, 171, 171, 170, 168, 168, 168, 169, 175, 185, 192, 200, 203, 203, 203, 203, 203, 202, 200, 198, 195, 192, 188, 182 , 175, 165 , 155]
				},
				'806':{
					'wID':806,
					'x':[31 , 36 , 42,48 , 54 , 60 , 66, 72 , 79 , 86 , 94 , 102 , 110 , 118],
					'y':[-10, -20,-30,-40,-50, -60, -70, -80, -90, -98, -106, -114, -122, -130]
				},
				'1388':{
					'wID':1388,
					'x':[31 , 36 , 42,48 , 54, 60,  66, 66 ,  62, 55 ,  48 , 42],
					'y':[-10, -20,-30,-40,-50,-60, -70, -80, -90,-100, -110, -120]
				},
				'2698':{
					'wID':2698,
					'x':[15 , 18 , 20, 21 , 21, 18 , 14, 6  , -4, -20, -31, -40, -48, -58, -66, -74, -81, -89, -97, -105, -113, -121, -130, -139, -148, -157],
					'y':[-20, -30,-40, -50,-60, -70,-80, -87,-91, -89,-86 , -79,-72 , -65,-57 , -50,-41 , -34,-28 , -22 ,-17  , -12 , -8  , -4  , -2  , 0]
				},
				'1226':{
					'wID':1226,
					'x':[15 , 18 , 20, 21 , 21, 18 , 14, 6  , -4, -20, -31, -40, -48, -58],
					'y':[-20, -30,-40, -50,-60, -70,-80, -87,-91, -89,-86 , -79,-72 , -65]
				},
				'1446':{
					'wID':1446,
					'x':[-40, -50, -60, -70, -80, -90, -100, -110, -158, -168, -178, -188, -198, -207, -217, -226],
					'y':[30 , 31 ,  32, 34 ,  36, 38 ,  40 , 44  ,  59 , 64  ,  69 , 75  ,  82 , 88  ,  96 , 102]
				},
				'1881':{
					'wID':1881,
					'x':[10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 108, 115, 125, 135, 145, 155, 165, 175, 185, 195, 205, 215, 225, 235, 265, 275, 285, 295, 305, 311, 315, 315, 313, 310],
					'y':[50, 60, 65, 65, 64, 62, 60, 58, 58, 62 , 68 , 76 , 80 , 82 , 84 , 84 , 84 , 84 , 85 , 86 , 87 , 89 , 91 , 93 , 103, 106, 106, 104, 100, 92 , 82 , 74 , 64 , 57]
				},
				'2336':{
					'wID':2336,
					'x':[10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 108, 115, 125, 135, 145, 155, 165, 175, 185, 195, 205, 215, 225, 235, 245, 253, 257, 260, 260, 260, 254, 246],
					'y':[50, 60, 65, 65, 64, 62, 60, 58, 58, 62 , 68 , 76 , 80 , 82 , 84 , 84 , 84 , 84 , 85 , 86 , 87 , 89 , 91 , 93 , 96 , 103, 112, 120, 130, 140, 151, 156]
				},
				'2404':{
					'wID':2404,
					'x':[170, 185, 195, 210, 220, 230],
					'y':[-165, -165, -165, -167, -168, -172]
				},	
				'3069':{
					'wID':3069,
					'x':[10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 108, 115, 125, 135, 145, 155, 165, 175, 185, 195, 205, 215, 225, 235, 245, 253, 259, 264, 270, 276, 283, 290],
					'y':[50, 60, 65, 65, 64, 62, 60, 58, 58, 62 , 68 , 76 , 80 , 82 , 84 , 84 , 84 , 84 , 85 , 86 , 87 , 89 , 91 , 93 , 97 , 104, 112, 120, 127, 134, 140, 146]
				}
			}
			if(lines){
				for each(var line:Shape in lines)
				{
					if (line.parent && parent)
						container.removeChild(line)
						
					lines.splice(lines.indexOf(line), 1)
				}
			}
			
			lines = new Vector.<Shape>()
			if (lines.length == 0)
			{
				for each(var cID:* in coords){
					if (!App.data.storage[cID.wID])
						continue;
					if (App.data.storage[cID.wID].hasOwnProperty('level') && App.data.storage[cID.wID].level != "" && App.data.storage[cID.wID].level > App.user.level)
						continue;
					drawPoints(571, 400, cID)
				}
			}
		}
		
		public var deltaX:int = 0;
		public var deltaY:int = 0;
		public var mapPadding:int = 10;
		public function onMouseMove(e:MouseEvent):void 
		{
			var dx:int = e.stageX - deltaX;
			var dy:int = e.stageY - deltaY;
			
			deltaX = e.stageX;
			deltaY = e.stageY;
			
			redraw(dx, dy);
		}
		
		public function redraw(dx:int, dy:int):void 
		{
			if (!(containerMap.x + dx < 0 && containerMap.x + dx > thisWindowMask.width - image.width)) 
			{
				dx = 0;
			}
			
			if (!(containerMap.y + dy < 0 && containerMap.y + dy > thisWindowMask.height - image.height)) 
			{
				dy = 0;
			}
			
			if (dx || dy) 
			{
				containerMap.x += dx;
				containerMap.y += dy;
			}
		}
		
		public function onUpDraggingMap(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		public static function availableByTime(lID:int):Boolean 
		{
			/*if (Config.admin)
				return true;*/
			var land:* = App.data.storage[lID]
			var available:Boolean = false;
			
			if (!land.hasOwnProperty('available'))
				available = true
			else if (land.hasOwnProperty('available') && land.available != "")
			{
				var serverDate:Date = new Date();
				var day:int;
				var hour:int;
		
				//serverDate.setTime((App.midnight + serverDate.timezoneOffset * 60 + 3600 * 12 + dateOffset * 86400) * 1000);
				serverDate.setTime((App.midnight) * 1000);
				day = serverDate.getDate();
				hour = serverDate.getHours();
				
				if (land.available.hasOwnProperty(day) && land.available[day].hstart <= hour && land.available[day].hend > hour){
					available = true;
					land['endTime'] = App.midnight + land.available[day].hend * 3600;
				}
			}
			return available;
		}
		
		override public function contentChange():void 
		{
			clearItems();
			items = [];
			for (var s:* in pages[paginator.page]) 
			{
				if (s == '') continue;
				
				if (s == 2480 && !Config.admin)
					continue;
				
				if (s == 1446)
					trace();
				
				if (!availableByTime(s))
					continue;
				if ((App.data.storage[s].hasOwnProperty('expire') && App.data.storage[s].expire.hasOwnProperty(App.social) && App.data.storage[s].expire[App.social] < App.time) ||
				(App.data.storage[s].hasOwnProperty('level') && App.data.storage[s].level !="" && App.data.storage[s].level > App.user.level))
					continue;
					
				var item:TravelItem = new TravelItem( {
					sID:		int(s),
					window:		this,
					scale:		1,
					link:		Config.getIcon('Lands', s),
					
					clock:		false,
					clockLink:	Config.getIcon('Lands', "clock"),
					
					align:		'center',
					hasBacking:	false,
					hasTitle:	false
					
				});
				
				container.addChild(item);
				
				var position:Array = pages[paginator.page][s].pos.split(':');
				item.x =  position[0];
				item.y =  position[1];
				
				unavailableWorldsJson = JSON.parse(App.data.options.hideWorld);				
				
				items.push(item);
				
				if (!images[paginator.page].bmd)
					item.visible = false;
				
				if (App.user.worldID == int(item.sID))
					item.setPlace(true);
				
				/*if (Config.admin)
				{
					item.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
					item.addEventListener(MouseEvent.MOUSE_UP, onUp);
				}*/
				
				if (settings.find == int(s))
				{
					item.startGlowing();
					if (loadded || item.bitmap.bitmapData)
					{
						
						item.showPointing("top", -item.width / 2, -20, item.parent);
						focusOnItem(item, true);
					}
				}
				
				//Подсвечивание из поиска если локаций в массиве больше 1
				for (var t:* in settings.find) 
				{
					if (settings.find[t] == int(s)) 
					{
						//item.startGlowing();
					}
				}
				
				//Скрываем залоченные портом локи
				if (!App.user.worlds.hasOwnProperty(int(s)) && s == User.AQUA_HERO_LOCATION)
					item.visible = false;
					
				//И другие костыли
				if(Stock.isExist(1242) == false && s == User.SHARK_LOCATION && !App.user.worlds.hasOwnProperty(User.SHARK_LOCATION))
					item.visible = false;
					
				/*if(Stock.isExist(2120) == false && s == User.VILLAGE_MAP)
					item.visible = false;*/
					
				if (s == User.DUNGEON_LOCATION)
					item.visible = false;
			}
			
			//generateRadarLocation();
			
			for (var i:int = 0; i < pageBttns.length; i++) 
			{
				if (int(pageBttns[i].name) == paginator.page) 
				{
					pageBttns[i].state = Button.ACTIVE;
				}else{
					pageBttns[i].state = Button.NORMAL;
				}
			}
			resize();
			
			if (image.bitmapData)
			{
				generateRadarLocation();
				coordsPoint();
				addMask();
			}
		}
		
		private function drawListMap():void 
		{
			listMapBttn = new ImageButton(UserInterface.textures.timerTravelIcon);
			bodyContainer.addChild(listMapBttn);
			listMapBttn.x = exit.x + (exit.width - listMapBttn.width) / 2;
			listMapBttn.y = exit.y + exit.height + 10;
			listMapBttn.addEventListener(MouseEvent.CLICK, listMapEvent);
		}
		
		private function listMapEvent(e:*):void 
		{
			if (App.isSocial(/*'FB',*/ 'SP')){
				new SimpleWindow({
					title	:Locale.__e("flash:1481879219779"),
					label	:SimpleWindow.ATTENTION,
					popup	:true,
					text	:Locale.__e('flash:1382952379805')
				}).show();
				return;
			}
			new TimerMapsWindow({
				//content	:synopticMaps,
				popup	:true
			}).show();
		}
		
		private function drawPoints(x:int, y:int, points:Object):void
		{
			if (paginator.page != 0)
				return;
			if (App.data.storage[points.wID].hasOwnProperty('expire') && App.data.storage[points.wID].expire.hasOwnProperty(App.social) && App.data.storage[points.wID].expire[App.social] < App.time)
				return;
			if (App.user.worlds.hasOwnProperty(points.wID))
			{
				var dashed:Shape = new Shape();
				dashed.graphics.lineStyle(7, 0xffffff, 1, false, LineScaleMode.NORMAL, CapsStyle.ROUND);
				for (var p:int = 0; p < points.x.length; p+=2){
					dashed.graphics.moveTo(points.x[p], points.y[p]);
					dashed.graphics.lineTo(points.x[p + 1], points.y[p + 1]);
					lines.push(dashed);
				}
				dashed.filters = [new DropShadowFilter(2, 90, 0x000000, .5, 3, 3, 1, 1)];
				dashed.x = x;
				dashed.y = y;
				container.addChildAt(dashed,0);
			}
		}
		
		private function addMask():void
		{
			if (thisWindowMask && thisWindowMask.parent)
				thisWindowMask.parent.removeChild(thisWindowMask);
				
			thisWindowMask = new Shape();
			thisWindowMask.graphics.beginFill(0x669c20);
			thisWindowMask.graphics.drawRect(10, 10, settings.width - 20, settings.height - 20);
			thisWindowMask.graphics.endFill();
			bodyContainer.addChild(thisWindowMask);
			
			containerMap.addEventListener(MouseEvent.MOUSE_DOWN, onDownDraggingMap);
			if (stage)
				stage.addEventListener(MouseEvent.MOUSE_UP, onUpDraggingMap);
			containerMap.mask = thisWindowMask;
		}
		
		private function onDown(e:MouseEvent):void
		{
			e.currentTarget.startDrag(false);
		}
		
		private function onUp(e:MouseEvent):void 
		{
			e.currentTarget.stopDrag();
			//e.currentTarget.block = true;
			trace(/*'land: ' + e.currentTarget.sID + */'x: ' + int(e.currentTarget.x / image.scaleX) + ' y: ' + int(e.currentTarget.y / image.scaleX));
		}
		
		public function itemsResize():void 
		{
			var scale:Number = image.scaleX;
			
			for each(var item:TravelItem in items)
			{
				if (pages[paginator.page].hasOwnProperty(item.sID)) 
				{
					var position:Array = pages[paginator.page][item.sID].pos.split(':');
					item.x = position[0] * scale;
					item.y = position[1] * scale;
				}
			}
		}
		
		private function clearItems():void 
		{
			if (!items)
				return;
			while (items.length > 0)
			{
				var item:TravelItem = items.shift();
				item.dispose();
			}
		}
		
		override public function drawArrows():void 
		{
			super.drawArrows();
			arrowsUpdate();
		}
		
		public function arrowsUpdate():void
		{
			if (paginator && paginator.arrowLeft)
			{
				paginator.arrowLeft.x = 80;
				paginator.arrowLeft.y = (settings.height - paginator.arrowLeft.height) / 2;
				paginator.arrowRight.x = settings.width - paginator.arrowRight.width - 10;
				paginator.arrowRight.y = (settings.height - paginator.arrowRight.height) / 2;
			}
		}
		
		private var pageBttns:Vector.<Button> = new Vector.<Button>;
		private var bttnContainer:Sprite = new Sprite();
		private function drawPageBttns():void
		{
			if (!App.data.updatelist[App.social].hasOwnProperty('u59fc6e6869e61'))
				return;
			if (pageBttns.length > 0) 
				return;
			
			bodyContainer.addChild(bttnContainer);
			
				for (var s:* in App.user.maps)
			{
				var bttn:Button = new Button( {
					caption:	Locale.__e(App.user.maps[s]['title']),
					fontColor	:0xffffff,
					width		:160,
					height		:50,
					fontSize	:23,
					multiline:  true,
					bgColor:	[0xfed031, 0xf8ac1b],
					fontBorderColor: 0x7f3d0e,
					bevelColor:	[0xf7fe9a, 0xcb6b1e],
					active : {
						bgColor:				[0xe0b545, 0xd8a036],
						bevelColor:				[0x9a6d22, 0xf6fd9b],	
						fontBorderColor:		0xa35e34				//Цвет обводки шрифта		
					}
				});
				
				bttn.name = s;
				bttn.textLabel.height = 40;
				bttn.x = pageBttns.length * (bttn.width + 5);
				bttn.addEventListener(MouseEvent.CLICK, onPage);
				bttnContainer.addChild(bttn);
				pageBttns.push(bttn);
			}
		}
		
		private function onPage(e:MouseEvent):void
		{
			var bttn:Button = e.currentTarget as Button;
			if (bttn.mode != Button.NORMAL) return;
			
			paginator.page = int(bttn.name);
			paginator.update();
			contentChange();
		}
		
		override public function dispose():void 
		{
			
			containerMap.removeEventListener(MouseEvent.MOUSE_DOWN, onDownDraggingMap);
			if(stage)
				stage.removeEventListener(MouseEvent.MOUSE_UP, onUpDraggingMap);
			
			for (var i:int = 0; i < pageBttns.length; i++)
			{
				pageBttns[i].removeEventListener(MouseEvent.CLICK, onPage);
				pageBttns[i].dispose();
			}
			
			clearRadarItems();
			
			App.self.removeEventListener(AppEvent.ON_RESIZE, resize);
			if (homeBttn)
				homeBttn.removeEventListener(MouseEvent.CLICK, onHome);
				
			//Fog.dispose();
			lines = null;
			super.dispose();
		}
		
		public function closeAll():void 
		{
			close();
		}
	}
}

import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.greensock.easing.Bounce;
import com.greensock.easing.Cubic;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import silin.filters.ColorAdjust;

internal class RadarItem extends LayerX {
	
	private	var _y:int;
	private var circleTimeout:uint = 1;
	private var circleTimeout2:uint = 2;
	private var _tween:TweenMax;
	private var _timeout:int;
	private var location:int;
	private var finalTime:uint;
	private var settings:Object;
	
	public var timeOfExpire:TextField;
	public var timerText:TextField;
	public var timerBg:Bitmap = new Bitmap();
	public var timerCont:LayerX;
	
	public var blackCircle:Shape;
	public var container:LayerX;
	public var bitmap:Bitmap;
	public function RadarItem(params:Object)
	{
		container = new LayerX();
		bitmap = new Bitmap();
		settings = params;
		
		addChild(container);
		
		blackCircle = new Shape();
		blackCircle.graphics.beginFill(0, .4);
		blackCircle.graphics.drawCircle(0, 0, 12);
		blackCircle.graphics.endFill();
		blackCircle.scaleY = .4;
		container.addChild(blackCircle);
		
		container.addChild(bitmap);
		Load.loading(params['link'], onLoad);
		
		defFilters = this.filters;
		container.addEventListener(MouseEvent.CLICK, onClick);
		container.addEventListener(MouseEvent.ROLL_OVER, onOver);
		container.addEventListener(MouseEvent.ROLL_OUT, onOut);
		if (App.user.worldID == settings['sID'])
		{
			currentLocation = true;
			TravelItem.currentWorld = this;
		}
		drawCircle();
		
		if (App.data.storage[settings['sID']].hasOwnProperty('expire') && App.data.storage[settings['sID']].expire.hasOwnProperty(App.social))
		{
			finalTime = App.data.storage[settings['sID']].expire[App.social];
			radarDrawTemp();
		}
		
		container.tip = function():Object {
			return {
				title:App.data.storage[settings['sID']].title
			}
		}
		//if (App.user.data.hasOwnProperty('tempWorlds'))
		//{
			//finalTime = App.user.data.tempWorldsExpire[App.user.openedRadarMap];
			//radarDrawTemp();
		//}
		//__tween = TweenMax.to(this, 0.8, { glowFilter: { color:glowingColor, alpha:0.8, strength: 3, blurX:blrX, blurY:blrY,inner:inner },onCompleteParams:[0.1,10,25,25,inner], onComplete:function(...args):void {
			//// args[0].dispose();
			 //startGlowing(null,inner)
		//}} );	
	}
	
	private function drawCircle():void
	{
		var radius:int = 80;
		var fillType:String = "radial";
		var colors:Array = [0x0, 0x0, 0xffffff];
		var alphas:Array = [0, 0, .8];
		var ratios:Array = [0, 150, 255];
		var matr:Matrix = new Matrix();
		matr.createGradientBox(radius * 2, radius * 2, 0, -radius, -radius);
		
		var circle:Shape = new Shape();
		circle.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, "pad", "rgb", 0);
		circle.graphics.drawCircle(0, 0, radius);
		circle.graphics.endFill();
		
		var circle2:Shape = new Shape();
		circle2.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, "pad", "rgb", 0);
		circle2.graphics.drawCircle(0, 0, radius);
		circle2.graphics.endFill();
		circle2.visible = false;
		
		var circle3:Shape = new Shape();
		circle3.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, "pad", "rgb", 0);
		circle3.graphics.drawCircle(0, 0, radius);
		circle3.graphics.endFill();
		circle3.visible = false;
		
		container.addChildAt(circle, 0);
		container.addChildAt(circle2, 0);
		container.addChildAt(circle3, 0);
		
		pulseCircle(circle);
		circleTimeout = setTimeout(function():void
		{
			pulseCircle(circle2);
		}, 2000);
		
		circleTimeout2 = setTimeout(function():void
		{
			pulseCircle(circle3);
		},4000);
	}
	
	private function radarTick():void
	{
		var timeToEnd:int = finalTime - App.time;
		if (timeToEnd <= 0)
		{
			App.self.setOffTimer(radarTick);
			dispose();
		}
		timerText.text = TimeConverter.timeToDays(timeToEnd);
	}
	
	private function radarDrawTemp():void
	{
		timerCont = new LayerX();
		timerBg = Window.backingHorizontal(54, 'travelBg');
		timerCont.addChild(timerBg);
		timerText =  Window.drawText(TimeConverter.timeToDays(finalTime - App.time), {
		  color:0xfeee9a,
		  borderColor:0x552c00,
		  textAlign:"center",
		  fontSize:16,
		  width:48
		});
		timerText.y = timerBg.y + (timerBg.height - timerText.height) / 2 + 1; 
		timerText.x = timerBg.x + (timerBg.width - timerText.width) / 2; 
		App.self.setOnTimer(radarTick);
		timerCont.addChild(timerText);
		timerCont.y = 14;
		addChild(timerCont);
	}
	
	private function pulseCircle(target:*):void
	{
		if (currentLocation)
			jump();
		var that:* = target;
		that.alpha = 1;
		that.visible = true;
		that.scaleX = .3;
		that.scaleY = .12;
		
		that.cacheAsBitmap = true;
		_timeout = setTimeout(function():void{
			TweenMax.to(that, 1, { alpha:0});
		}, 3000)
		_tween = TweenMax.to(that, 6, { scaleX:1, scaleY:.5, onComplete:function(...args):void {
			//that.visible = false;
			pulseCircle(that);
		}} );
	}
	
	public function jump():void 
	{
		var item:Bitmap = this.bitmap;
		TweenLite.to(item, 0.4, { scaleX:1, scaleY:1, y:_y-7, ease:Cubic.easeOut, onComplete:function():void {
			TweenLite.to(item, 0.4, { scaleX:1, scaleY:1, y:_y, ease:Bounce.easeOut } );
		}} );
		
		TweenLite.to(blackCircle, 0.4, { scaleX:1.2, scaleY:.5, ease:Cubic.easeOut, onComplete:function():void {
			TweenLite.to(blackCircle, 0.4, { scaleX:1, scaleY:.4, ease:Bounce.easeOut } );
		}} );
	}
	
	public function onClick(e:MouseEvent = null):void 
	{
		//if (App.user.openedRadarMap)
		//{
		if (App.user.worlds.hasOwnProperty(settings['sID']) || Numbers.countProps(App.user.data.tempWorlds) != 0)
		{
			if(App.user.worldID != settings['sID'])
				Travel.goTo(settings['sID']);
		}
		/*}else{
			if (Numbers.countProps(App.user.radarMaps)>0)
			{
				var index:int = (Math.random() * Numbers.countProps(App.user.radarMaps));
				location = Numbers.getProp(App.user.radarMaps, index).key;
				//var variant:int = location.val.vars[int(Math.random() * location.val.vars.length)];
				location = 1851;
				var send:Object = {
					'ctr':'user',
					'act':'generateWorld',
					'uID':App.user.id, 
					'wID':location
				};
				
				Post.send(send, onRadarData);
			}
		}*/
		jump();
		//if (params.clickable == false) return;
		//
		//if (params.jump) jump();
		//
		//if (App.user.mode == User.OWNER && sID != App.map.id && App.user.worlds.hasOwnProperty(sID)) 
		//{
			////Window.closeAll();
			//Travel.goTo(sID);
		//}else if (App.user.mode == User.GUEST) 
		//{
			//Travel.friend = Travel.currentFriend;
			//Travel.onVisitEvent(sID);
		//}
		
		//if (window && window.hasOwnProperty('closeAll') && window.closeAll != null) window.closeAll();
	}
	
	/*private function onRadarData(error:int, data:Object, params:Object):void
	{
		if (error) return;
		if (data)
		{
			if (location)
			{
				App.user.openedRadarMap = location;
				App.user.worlds[location] = location;
			}
		}
	}*/
	
	private var currentLocation:Boolean = false;
	public function setPlace(value:Boolean = false):void 
	{
		currentLocation = value;
		//if (value) 
		//{
			////TravelItem.currentWorld = this;
			//startPlacePointing();
		//}
	}
	
	/*public function startPlacePointing():void
	{
		var that:* = this;
		setTimeout(function():void{
			that.jump();
			that.startPlacePointing();
		}, 2000);
	}*/
	
	
	private var defFilters:Array;
	private var available:Boolean = true;
	public function onOver(e:MouseEvent):void 
	{
		if (available) effect(0.1);
	}
	
	public function onOut(e:MouseEvent):void 
	{
		if (available) effect();
	}
	
	public function effect(count:Number = 0, saturation:Number = 1):void 
	{
		var mtrx:ColorAdjust;
		mtrx = new ColorAdjust();
		mtrx.saturation(saturation);
		mtrx.brightness(count);
		var filters:Array = defFilters.concat([mtrx.filter]);
		
		this.filters = filters;
	}
	
	public function onLoad(data:Bitmap):void
	{
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		bitmap.x = - bitmap.width / 2;
		bitmap.y = - bitmap.height;
		
		_y = bitmap.y;
	}
	
	public function dispose():void
	{
		if (container)
		{
			container.removeEventListener(MouseEvent.CLICK, onClick);
			container.removeEventListener(MouseEvent.ROLL_OVER, onOver);
			container.removeEventListener(MouseEvent.ROLL_OUT, onOut);
		}
		
		App.self.setOffTimer(radarTick);
		
		if (_tween != null)
		{
			_tween.complete(true, true);
			_tween.kill();
			_tween = null;
		}
		clearTimeout(circleTimeout);
		clearTimeout(circleTimeout2);
		clearTimeout(_timeout);
		
		this.hidePointing();
		this.hideGlowing();
		
		if (parent) 
			parent.removeChild(this);
	}
	
}

import buttons.ImageButton;
import com.greensock.TweenMax;
import com.greensock.easing.Strong;
import core.Load;
import core.Numbers;
import core.Post;
import core.TimeConverter;
import effects.Effect;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.utils.setInterval;
import ui.UserInterface;
import wins.elements.WorldItem;
import wins.Window;
import wins.OpenWorldWindow;
import wins.ShopWindow;
import wins.TravelRequireWindow;
import wins.TravelPayWindow;
import wins.SimpleWindow;
import wins.BathyscaphePayWindow;

internal class TravelItem extends WorldItem {
	
	public static var currentWorld:*;
	
	private var lockCont:Sprite;
	private var arrow:Bitmap;
	private var lock:Bitmap;
	private var lockText:TextField;
	private var titleText:TextField;
	private var place:Bitmap;
	private var reqSID:*;
	private var finalTime:int = 0;
	public var timeOfExpire:TextField;
	public var timerText:TextField;
	public var timerBg:Bitmap = new Bitmap();
	public var timerCont:LayerX;
	
	public function TravelItem(params:Object)
	{
		super(params);
		
		container.tip = function():Object {
			return {
				title:App.data.storage[sID].title
			}
		}
	}
	private var __y:int = 0;
	override public function draw():void 
	{
		super.draw();
		lockCont = new Sprite();
		addChild(lockCont);
		lockCont.visible = false;
		
		lock = new Bitmap(Window.textures.timerDark, 'auto', true);
		lock.scaleX = lock.scaleY = 0.75;
		lock.x = -lock.width / 2;
		lock.y = 10;
		lockCont.addChild(lock);
		
		arrow = new Bitmap(Window.textures.upgradeArrow, 'auto', true);
		arrow.scaleX = arrow.scaleY = 0.5;
		lockCont.addChild(arrow);
		
		lockText = Window.drawText(String(openLevel), {
			fontSize:17,
			color:0xfcf6e4,
			borderColor:0x5e3402,
			textAlign:"left",
			borderSize:2,
			width:30
		});
		lockCont.addChild(lockText);
		
		arrow.x = lock.x + (lock.width - arrow.width - 2 - lockText.textWidth-4) / 2;
		arrow.y = 25;
		lockText.x = arrow.x + arrow.width + 2;
		lockText.y = 23;
		
		var sexBdata:String = (App.user.sex == 'm')?'targetBoy':'targetGirl';
		place = new Bitmap(UserInterface.textures[sexBdata], 'auto', true);
		place.x = -place.width / 2;
		place.y = - place.height - 25;
		place.visible = false;
		addChild(place);
		__y = place.y;
		
		checkLock();
		if (App.data.storage[sID].hasOwnProperty('expire') && App.data.storage[sID].expire.hasOwnProperty(App.social))
		{
			finalTime = App.data.storage[sID].expire[App.social];
			drawTemp();
		}
		
		if (App.data.storage[sID].hasOwnProperty('available'))
		{
			//var serverDate:Date = new Date();
			//serverDate.setTime((App.midnight + (24 * 3600)) * 1000);
			//var currDay:int = serverDate.getDate()
			if (App.user.data.hasOwnProperty('tempWorlds') && App.user.data.tempWorlds.hasOwnProperty(sID))
				finalTime = App.user.data.tempWorlds[sID];
			else
			{
				//if (App.isSocial('FB'))
					//finalTime = App.midnight - (60*60*10) + (App.data.storage[sID].available[currDay].hend * 60 * 60)
				//else
					//finalTime = App.midnight + (App.data.storage[sID].available[currDay].hend * 3600)
				finalTime = App.data.storage[sID].endTime;
			}
			
			drawTemp()
		}
		
	}
	public var block:Boolean = false;
	
	public function startPlacePointing():void
	{
		TweenMax.to(place, 0.9, { y:__y -5, onComplete:restartPlacePointing, ease:Strong.easeInOut  } );
	}
	
	public function restartPlacePointing():void
	{
		
		TweenMax.to(place, 0.6, { y:__y, onComplete:startPlacePointing } );
	}
	
	override public function onClick(e:MouseEvent = null):void 
	{
		/*if (sID == 2404)
			return;*/
		if (!params.clickable || block) return;
		if (params.jump) jump();
		
		if (App.data.storage[sID].maptype == 2)
		{
			if (!App.user.worlds.hasOwnProperty(sID))
			{
				World.openMap(sID,function():void{
					Travel.friend = {
						first_name	:App.user.first_name,
						last_name	:App.user.last_name,
						sex			:App.user.sex,
						photo		:App.user.photo,
						level		:App.user.level,
						aka			:App.user.aka,
						visited		:0,
						uid			:App.user.id
					};			
					Travel.onVisitEvent(sID);
				});
				return;
			}else{
				Travel.friend = {
					first_name	:App.user.first_name,
					last_name	:App.user.last_name,
					sex			:App.user.sex,
					photo		:App.user.photo,
					level		:App.user.level,
					aka			:App.user.aka,
					visited		:0,
					uid			:App.user.id
				};			
				Travel.onVisitEvent(sID);
				return;
			}
			/*if (App.user.data.friends.hasOwnProperty('96391814'))
			{
				Travel.friend = App.user.data.friends['96391814'];			
				Travel.onVisitEvent(sID);
				return;
			}
			
			if (App.user.id == '96391814')
			{
				Travel.friend = {
					first_name	:App.user.first_name,
					last_name	:App.user.last_name,
					sex			:App.user.sex,
					photo		:App.user.photo,
					level		:App.user.level,
					aka			:App.user.aka,
					visited		:0,
					uid			:App.user.id
				};			
				Travel.onVisitEvent(sID);
				return;
			}*/
		}
		
		if (!App.user.worlds.hasOwnProperty(sID))
		{
			if (App.data.storage[sID].hasOwnProperty('require') && Numbers.countProps(App.data.storage[sID].require) > 0)
			{
				new OpenWorldWindow( {
					popup:		true,
					worldID:	sID,
					content:	App.data.storage[sID].require
				}).show();
			}else {
				block = true;
				World.openMap(sID, function():void {
					block = false;
					onClick(e);
				});
			}
			
			return;
		}	
		
		if (!App.map || sID != App.map.id) 
		{
			if (Numbers.countProps(App.data.storage[sID]['charge']) > 0) 
			{
				new TravelPayWindow( {
					worldID:	sID,
					window:		window,
					content:	App.data.storage[sID].charge
				}).show();
			}else if (App.data.storage[sID].fuel && App.data.storage[sID].fuel > 0){
				if (App.user.hasOwnProperty('bathyscaphe') && App.user.bathyscaphe != null)
				{
					new BathyscaphePayWindow( {
						worldID:	sID,
						window:		window,
						popup:		true,
						sID:		2742,
						count:		App.data.storage[sID].fuel,
						content:	{2742:App.data.storage[sID].fuel}
					}).show();
				}else{
					new SimpleWindow( {
						hasTitle:true,
						label:SimpleWindow.ATTENTION,
						text			:Locale.__e("flash:1511430442846") + '\n' + Locale.__e('flash:1511430664847'),
						popup:true,
						dialog:true,
						confirm:function():void{
							utils.Finder.questInUser(805, true);
							return;
						}
					}).show();	
				}	
			}else {
				Travel.goTo(sID);
			}
		}
		
		/*if (!App.map || sID != App.map.id) 
		{
			if (Numbers.countProps(App.data.storage[sID]['charge']) > 0) 
			{
				new TravelPayWindow( {
					worldID:	sID,
					window:		window,
					content:	App.data.storage[sID].charge
				}).show(); 
			}else if (App.data.storage[sID].fuel && App.data.storage[sID].fuel > 0)
			{
				new BathyscaphePayWindow({
					worldID:	sID,
					window:		window,
					popup:		true,
					sID:		2742,
					count:		App.data.storage[sID].fuel,
					content:	{2742:App.data.storage[sID].fuel}
				}).show();
			}else {
				//Travel.clearObjects();
				Travel.goTo(sID);
			}
		}*/
	}
	
	public function checkLock():void 
	{
		var item:*;
		for (var i:* in App.user.maps[window.paginator.page].ilands)
		{ 
			if (i == sID)
			{
				item = App.user.maps[window.paginator.page].ilands[i];
				break;
			}
		}
		
		if (item.hasOwnProperty('req')) 
		{
			for (var j:* in item.req)
			{ 
				reqSID = j;
				if (App.user.stock.check(j) < item.req[j])
				{
					params.clickable = false;
					available = false;
					Effect.light(this, 0, 0);
					return;
				}
			}
		}
		
		params.clickable = true;
		available = true;
		Effect.light(this, 0, 1);
	}
	
	public function setPlace(value:Boolean = false):void 
	{
		if (TravelItem.currentWorld && TravelItem.currentWorld is TravelItem)
		{
			TravelItem.currentWorld.place.visible = false;
			TravelItem.currentWorld.params.clickable = true;
			TravelItem.currentWorld = null;
		}
		
		if (value) 
		{
			TravelItem.currentWorld = this;
			startPlacePointing();
			place.visible = true;
			params.clickable = false;
		}
	}
	
	private function onTick():void
	{
		var timeToEnd:int = finalTime - App.time;
		if (timeToEnd <= 0)
		{
			params.window.close();
			App.self.setOffTimer(onTick);
		}
		
		timerText.text = TimeConverter.timeToDays(timeToEnd);
	}
	
	private function drawTemp():void
	{
		timerCont = new LayerX();
		timerBg = Window.backingHorizontal(54, 'travelBg');
		timerCont.addChild(timerBg);
		timerText =  Window.drawText(TimeConverter.timeToDays(finalTime - App.time), {
			color:0xfeee9a,
			borderColor:0x552c00,
			textAlign:"center",
			fontSize:16,
			width:48
		});
		timerText.y = timerBg.y + (timerBg.height - timerText.height) / 2 + 1; 
		timerText.x = timerBg.x + (timerBg.width - timerText.width) / 2; 
		App.self.setOnTimer(onTick);
		timerCont.addChild(timerText);
		timerCont.y = 14;
		addChild(timerCont);
	}
	
	public function get openLevel():int 
	{		
		return 0; //надо будет дописать!
	}
}

