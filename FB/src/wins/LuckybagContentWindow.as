package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.elements.SearchMaterialPanel;

	public class LuckybagContentWindow extends Window
	{
		public static var history:Object = { section:"all", page:0 };
		private var innerBackground:Bitmap;	
		private var separator:Bitmap;	
		private var separator2:Bitmap;	
		public var youGet:Boolean = false;	
		public var sections:Object = new Object();
		public var icons:Array = new Array();
		public var items:Vector.<DaylicsShopItem> = new Vector.<DaylicsShopItem>();
		public var stocks:Array = [];
		
		public function LuckybagContentWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["section"] = settings.section || "all"; 
			settings["page"] = settings.page || 0; 			
			settings["find"] = settings.find || null;			
			settings["title"] = Locale.__e('flash:1451293492450');
			settings["width"] = 590;
			settings["height"] = 595;			
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 12;
			settings["buttonsCount"] = 7;
			settings["background"] = 'storageBackingTop';
			settings["targetSID"] = settings.targetSID;				
			settings["targetContent"] = settings.targetContent;	
			
			if (settings.targetContent) 
			{
				settings["title"] = Locale.__e('flash:1451293420240');
			}
			
			//Созание пула материалов
			/*if (App.self.getLength(App.user.luckyBagData) == 0) 
			{*/
				App.user.luckyBagData = {};
				if (settings.targetSID)//Для окна с распродажей, кнопка "В мешке"
				{			
					//youGet = false;
					for (var number:String in App.data.storage[settings.targetSID].items) 
					{
						var item:Object = App.data.storage[settings.targetSID].items[number];
						
						for (var id:* in item)
						{
							App.user.luckyBagData[id] = App.data.storage[id];
							App.user.luckyBagData[id].quantityToDraw = item[id];							
						}				
					}
				}else if (settings.targetContent)//При распаковке
				{
					//youGet = true;
					for (var number2:String in settings.targetContent) 
					{					
						App.user.luckyBagData[number2] = App.data.storage[number2];	
						App.user.luckyBagData[number2].quantityToDraw = settings.targetContent[number2];
					}					
				}			
			//}
			
			settings["target"] = stocks[0];			
			createContent();			
			findTargetPage(settings);			
			super(settings);
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			for each(var item:* in items) 
			{
				item.dispose();
				item = null;
			}
			
			for each(var icon:* in icons) 
			{
				icon.dispose();
				icon = null;
			}
		}
		
		override public function drawBackground():void
		{		
			//основная подложка
			var background:Bitmap = backing(settings.width, settings.height, 30, 'buildingBacking');
			layer.addChild(background);
			background.x = -10;
			background.y = 40;
			
			//внутренняя подложка
			innerBackground = Window.backing(535, 500, 40, 'buildingDarkBacking');
			layer.addChild(innerBackground);
			innerBackground.x = background.x + background.width / 2 - innerBackground.width / 2;
			innerBackground.y = background.y + background.height / 2 - innerBackground.height / 2;
			
			//сепараторы
			separator = Window.backingShort(455, 'divider');
			separator.alpha = 0.4;
			layer.addChild(separator);
			separator.x = background.x + background.width / 2 - separator.width / 2;
			separator.y = 257 - separator.height / 2;
			
			separator2 = Window.backingShort(455, 'divider');
			separator2.alpha = 0.4;
			layer.addChild(separator2);
			separator2.x = background.x + background.width / 2 - separator.width / 2;
			separator2.y = 419 - separator2.height / 2;
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
					
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -16;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 37;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawExit():void 
		{
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 60;
			exit.y = -5;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		private function findTargetPage(settings:Object):void 
		{					
			for (var section:* in sections) {
				if (App.user.quests.currentQID == 158) 
				section = 'others';
				for (var i:* in sections[section].items) {
					
					var sid:int = sections[section].items[i].sid;
					if (settings.find != null && settings.find.indexOf(sid) != -1) {
						
						history.section = section;
						history.page = int(int(i) / settings.itemsOnPage);
						
						settings.section = history.section;
						settings.page = history.page;
						return;
					}
				}
			}
			
			if (settings.hasOwnProperty('find')&&settings.find !=null) 
			{
				new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1425555522565', [App.data.storage[settings.find[0]].title]),
				title:Locale.__e('flash:1382952379725'),
				popup:true,
				confirm:findRes,
				buttonText:Locale.__e('flash:1407231372860')
				}).show();
			}			
		}
		
		private function findRes():void 
		{			
			ShopWindow.findMaterialSource(settings.find[0],this);
		}
		
		public function createContent():void 
		{			
			if (sections["all"] != null) return;
			
			sections = 
			{				
				"all":{items:new Array(),page:0}
			};
			
			var section:String = "all";
			
			for(var ID:* in App.user.luckyBagData) {
				var item:Object= App.user.luckyBagData[ID];
				if(item == null) continue;				
				
				item["sid"] = ID;
				if (User.inUpdate(item.sID)) 
				{
					sections["all"].items.sortOn('market', Array.DESCENDING);
					sections["all"].items.push(item);
				}				
			}		
		}
		
		override public function drawBody():void 
		{			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, 2, true, true);
			drawMirrowObjs('storageWoodenDec', -10, settings.width - 10, settings.height - 70);
			drawMirrowObjs('storageWoodenDec', -10, settings.width - 10, 80, false, false, false, 1, -1);			
			setContentSection(settings.section,settings.page);
			contentChange();					
			this.x += 10;
			this.y -= 10;
			fader.x -= 10;
			fader.y += 10;			
		}
		
		public function setContentSection(section:*, page:int = -1):Boolean 
		{
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
				if (icon.type == section) {
					icon.selected = true;
				}
			}
			if (sections.hasOwnProperty(section)) {
				settings.section = section;
				settings.content = [];
				
				for (var i:int = 0; i < sections[section].items.length; i++)
				{
					var sID:uint = sections[section].items[i].sid;
						settings.content.push(sections[section].items[i]);
				}				
				paginator.page = page == -1 ? sections[section].page : page;
				paginator.itemsCount = settings.content.length;
				paginator.update();
			}else {
				return false;
			}
			
			contentChange();	
			return true
		}		
		
		public function refresh(e:AppEvent = null):void
		{
			sections = { };
			createContent();
			findTargetPage(settings);
			setContentSection(settings.section,settings.page);			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			contentChange();
		}
		
		override public function contentChange():void {
			
			for each(var _item:DaylicsShopItem in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			
			items = new Vector.<DaylicsShopItem>();
			var X:int = 73;
			var Xs:int = X;
			var Ys:int = 95;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:DaylicsShopItem = new DaylicsShopItem(settings.content[i], this);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
				
				items.push(item);
				Xs += item.bg.width + 5;
				if (itemNum == int(settings.itemsOnPage / 3) - 1 || itemNum == int(settings.itemsOnPage / 3) * 2 - 1){
					Xs = X;
					Ys += item.bg.height + 22;
				}		
				itemNum++;
			}
			
			sections[settings.section].page = paginator.page;
			settings.page = paginator.page;			
		}
		
		override public function drawArrows():void 
		{			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );			
			var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 46;
			paginator.arrowLeft.x = 25;
			paginator.arrowLeft.y = innerBackground.y + innerBackground.height / 2 - paginator.arrowLeft.height / 2;			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 30;
			paginator.arrowRight.y = innerBackground.y + innerBackground.height / 2 - paginator.arrowRight.height / 2;			
			paginator.x = int((settings.width - paginator.width)/2 - 40);
			paginator.y = int(settings.height - paginator.height + 45);
		}
	}
}

	import buttons.Button;
	import buttons.MoneySmallButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Cursor;
	import ui.Hints;
	import units.Anime;
	import units.Field;
	import ui.Cursor;
	import wins.LuckybagContentWindow;
	import wins.Window;
	import wins.SimpleWindow;
	
	internal class DaylicsShopItem extends Sprite {
		
		public var item:Object;
		public var bg:Bitmap;
		private var bitmap:Bitmap;
		private var buyBttn:MoneySmallButton;
		private var buyBttnNow:MoneySmallButton;
		private var _parent:*;
		private var sprite:LayerX;
		private var spriteAnime:LayerX;
		private var preloader:Preloader = new Preloader();
		private var countLabel:TextField = new TextField();
		private var youGet2:Boolean;	
		
		public function DaylicsShopItem (item:Object, parent:*) {
			
			this._parent = parent;
			this.item = item;
			youGet2 = parent.youGet;
			
			bg = Window.backing(120, 140, 15, 'itemBacking');
			addChild(bg);
			
			bg.x -= 35;
			bg.y -= 23;
			
			sprite = new LayerX();
			spriteAnime = new LayerX();
			addChild(sprite);
			addChild(spriteAnime);				
			bitmap = new Bitmap();
			sprite.addChild(bitmap);			
			
			if (item.quantityToDraw /*&& youGet2*/)
			{
				countLabel = Window.drawText('x' + item.quantityToDraw, {
					fontSize:28,
					color:0xf2efe7,
					borderColor:0x464645,
					autoSize:"center"
				});	
				countLabel.x = bg.x + bg.width - countLabel.width - 5;
				countLabel.y = bg.y + bg.height - countLabel.height;
				sprite.addChild(countLabel);
			}	
			
			spriteAnime.tip = function():Object { 
				
				return {
					title:item.title,
					text:item.description
				};
			};
			
			sprite.tip = function():Object { 
				
				if (item.type == "Plant") {
					return {
						title:item.title,
						text:Locale.__e("flash:1382952380297", [TimeConverter.timeToCuts(item.levelTime * item.levels), item.experience, App.data.storage[item.out].cost])
					};
				}
				else if (item.type == "Decor") {
					return {
						title:item.title,
						text:Locale.__e("flash:1382952380076", String(item.experience))
					}	
				} else {
					return {
						title:item.title,
						text:item.description
					};
				}
			};
			
			drawTitle();
			
			addChild(preloader);
			preloader.x = (bg.width) / 2 - 35;
			preloader.y = (bg.height) / 2 - 20;
			preloader.scaleX = preloader.scaleY = 0.67;
			
			if ((item.type == 'Decor' || item.type == 'Golden' || item.type == 'Walkgolden')) {
				Load.loading(Config.getSwf(item.type, item.preview), onLoadAnimate);	
			} else {		
				Load.loading(Config.getIcon(item.type, item.preview), onLoad);
			}
		}
		
		private function onLoad(data:Bitmap):void {
			if (preloader){
				removeChild(preloader);
				preloader = null;
			}
			
			bitmap.bitmapData = data.bitmapData;
			
			if (bitmap.width > bg.width - 20) {
				bitmap.scaleX = bitmap.scaleY = (bg.width - 20)/(bitmap.width);
			}
			if (bitmap.height > bg.height - 50 ) {
				bitmap.height =  bg.height - 50;
				bitmap.scaleX = bitmap.scaleY;
			}
			
			bitmap.smoothing = true;
			
			bitmap.x = ((bg.width - bitmap.width)/2) - 35;
			bitmap.y = ((bg.height - bitmap.height) / 2) - 23;	
			
			spriteAnime.tip = function():Object { 
				
				return {
					title:item.title,
					text:item.description
				};
			};
		}
	 
		private function onLoadAnimate(swf:*):void 
		{
			if (preloader){
				removeChild(preloader);
				preloader = null;
			}
			
			if (!sprite) { 
				sprite = new LayerX();
			}
			if (!contains(sprite)) addChild(sprite);
			
			var bitmap:Bitmap = new Bitmap(swf.sprites[swf.sprites.length - 1].bmp, 'auto', true);
			bitmap.x = swf.sprites[swf.sprites.length - 1].dx;
			bitmap.y = swf.sprites[swf.sprites.length - 1].dy;
			spriteAnime.addChild(bitmap);
			
			spriteAnime.tip = function():Object { 
				
				return {
					title:item.title,
					text:item.description
				};
			};
			
			if(swf.animation){
				var framesType:String;
				for (framesType in swf.animation.animations) break;
				var anime:Anime = new Anime(swf, framesType, swf.animation.ax, swf.animation.ay);
				spriteAnime.addChild(anime);
				anime.startAnimation();
				
				anime.tip = function():Object { 				
					return {
						title:item.title,
						text:item.description
					};
				};
			}
			
			if (spriteAnime.width > bg.width - 20) {
				spriteAnime.scaleX = spriteAnime.scaleY = (bg.width - 20)/(spriteAnime.width);
			}
			if (spriteAnime.height > bg.height - 40 ) {
				spriteAnime.height =  bg.height - 40;
				spriteAnime.scaleX = spriteAnime.scaleY;
			}
			spriteAnime.x = bg.x + bg.width / 2;
			spriteAnime.y = bg.y + bg.height / 2 + 15;
			
			if (item.preview == 'witch_house' || item.preview == 'meadow_rose') {
				spriteAnime.y -= 20;
			}				
			if (item.preview == 'fire_enchantress') {
				spriteAnime.y += 15;
			}			
			if (item.preview == 'earth_element' || item.preview == 'magic_white_tree') {
				spriteAnime.y += 20;
			}			
		}
		
		public function drawTitle():void 
		{
			var title:TextField = Window.drawText(String(item.title), {
				color:0x814f31,
				borderColor:0xfcf6e4,
				textAlign:"center",
				fontSize:18,
				textLeading:-8,
				multiline:false,
				wrap:true,
				width:bg.width
			});
			
			title.y = -15;
			title.x = ((bg.width - title.width)/2) - 35;
			addChild(title);
		}
		
		public function dispose():void 
		{
		}
	}
