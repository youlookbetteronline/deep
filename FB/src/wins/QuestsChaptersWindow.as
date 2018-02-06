package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;

	public class QuestsChaptersWindow extends Window
	{
		public static const MINISTOCK:int = 4;
		public static const ARCHIVE:int = 1;
		public static const DESERT_WAREHOUSE:int = 2;
		public static const PAGODA:int = 3;
		public static const DEFAULT:int = 0;
		
		public static var mode:int = DEFAULT;
		public var sections:Object = new Object();
		public var icons:Array = new Array();
		public var openedQuestsId:Array = [];
		public var backIcon:Shape = new Shape();
		public var finishedQuestsId:Array = [];
		public var items:Vector.<ChapterItem> = new Vector.<ChapterItem>();
		public static var find:Array = [];
		public static var treashureUpdateQuests:Array = [113, 147, 183, 187, 193, 83, 221, 209, 210, 211, 216, 217, 212, 214, 222, 223, 213, 175, 84, 85, 102, 215, 219, 224, 220];
		
		public static var history:Object = { section:"all", page:0 };
		
		public function QuestsChaptersWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["section"] = settings.section || "all"; 
			settings["page"] = settings.page || 0; 
			settings["find"] = settings.find || [];
			settings["title"] = Locale.__e('flash:1446136966526');
			settings["width"] = 652;
			settings["height"] = 665;
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 3;
			settings["buttonsCount"] = 8;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] = 0x116011;
			settings['shadowBorderColor'] = 0x116011;
			//settings["background"] = 'paperScroll';
			mode = settings.mode || DEFAULT;
			
			/*var stocks:Array = [];
			switch(mode) {
				default:
					stocks = Map.findUnits([Storehouse.SILO]);
				break;
			}*/
			
			find = settings.find;
			
			//settings["target"] = stocks[0];
			
			createContent();
			
			findTargetPage(settings);
			
			super(settings);
			App.user.stock.data
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
		}
		
		override public function dispose():void {
			super.dispose();
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
			
			for each(var item:* in items) {
				item.dispose();
				item = null;
			}
			
			for each(var icon:* in icons) {
				icon.dispose();
				icon = null;
			}
		}
		
		override public function drawBackground():void
		{
			var background:Bitmap = new Bitmap(Window.textures.parerBackingBig);
			layer.addChild(background);
			background.smoothing = true;
			
			backIcon.graphics.beginFill(0xe2b690, 1);
			backIcon.graphics.lineStyle(1, 0xc28f5e);
			backIcon.graphics.drawRoundRect(0, 0, settings.width - 105, settings.height - 170, 20, 20);
			backIcon.y = 113;
			backIcon.x = (settings.width - backIcon.width) / 2 - 5;
		    backIcon.graphics.endFill();
		    layer.addChild(backIcon);
			
		}
		
		/*override protected function drawRibbon():void 
		{
			var titleBackingBmap:Bitmap = backingShort(settings.titleWidth + 180, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -50;
			//titleBackingBmap.filters = [new GlowFilter(0xf3ff2c, .7, 11, 11, 3)];
			bodyContainer.addChild(titleBackingBmap);
			
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y + 8;
			
			bodyContainer.addChild(titleLabel);
		}*/
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: 42,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,
				borderSize 			: 3,
				shadowSize 			: 1,
				shadowColor			: settings.fontBorderColor,
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			drawRibbon();
			titleLabel.y += 15;
			titleBackingBmap.y += 5;

		}
		
		
		
		public static function inShop(sid:uint = 0):Boolean 
		{
		var shop:Object = App.data.storage[App.user.worldID]['shop'];
			if (shop) {
				for (var type:* in shop) {
					if (shop[type].hasOwnProperty(sid)) {
						if (shop[type][sid] == 1)
							return true
					}
				}
			}
			return false
		}
	
		private function findTargetPage(settings:Object):void {			
			
			for (var section:* in sections) { 
				if (section != 'active')
					continue; 
				for (var i:* in sections[section].items) {
					 
					var sid:* = sections[section].items[i].sid;
					if (getFindUpdate != null && getFindUpdate.indexOf(sid) != -1) {
						
						history.section = section;
						history.page = int(int(i) / settings.itemsOnPage);
						
						settings.section = /*'active'//*/history.section;
						settings.page = history.page;
						return;
					}
				}
			}			
		}
		
		private function get getFindUpdate():Array
		{
			var upd:Array = []
			for each(var qid:* in find)
			{	
				upd.push(App.data.quests[qid].update);
				break;
			}
			return upd;
		}

		public function createContent():void {
			
			if (sections["all"] != null) return;
			
			sections = {
				
				//"done"		:{items:new Array(),page:0},
				"all"		:{items:new Array(),page:0},
				"active"	:{items:new Array(),page:0}
				//"locked"	:{items:new Array(),page:0}
			};
			
			var section:String = "all";			
			
			for (var index:* in App.user.quests.opened) 
			{
				openedQuestsId.push(App.user.quests.opened[index].id);
			}
			
			for (var indexF:* in App.user.quests.data) {
				if (App.user.quests.data[indexF].finished != 0) {
					finishedQuestsId.push(indexF);
				}
			}			
			
			for (var ID:* in App.data.updates)
			{
				if (ID == 'u58bd20e3c5e6c')
					continue;
				if (ID == 'u59ef37ab9d08a')
					continue;
				if (!App.data.updatelist[App.social].hasOwnProperty(ID))
					continue;
				var item:Object = App.data.updates[ID];
				item.excludeSocial = [];
				item.openedQuests = [];
				item.closedQuests = [];
				item.finishedQuests = [];	
				
				for (var social:* in item.exclude) {
					item.excludeSocial.push(item.exclude[social]);
				}
				
				if (item.excludeSocial.indexOf(App.SOCIAL) != -1) {
					continue;
				}
				
				for (var IDquest:* in App.data.quests) 
				{
					var itemQ:Object = App.data.quests[IDquest];
					
					if ((App.data.quests[IDquest].update == ID) && (App.data.quests[IDquest].missions !== null))
					{
						if (openedQuestsId.indexOf(IDquest) >= 0) {
							item.openedQuests.push(itemQ);
						} else if (finishedQuestsId.indexOf(IDquest) >= 0) {
							item.finishedQuests.push(itemQ);
						} else {
							item.closedQuests.push(itemQ);
						}						
					}else{
						if (treashureUpdateQuests.indexOf(IDquest) != -1 && App.data.quests[IDquest].missions !== null && ID == 'u58887a0e8a755' && App.data.quests[IDquest].update == '')
						{
							if (openedQuestsId.indexOf(IDquest) >= 0) {
								item.openedQuests.push(itemQ);
							} else if (finishedQuestsId.indexOf(IDquest) >= 0) {
								item.finishedQuests.push(itemQ);
							} else {
								item.closedQuests.push(itemQ);
							}
						}else
							if (App.data.quests[IDquest].missions !== null && ID == 'u5878df0a1baa4' && App.data.quests[IDquest].update == '' && treashureUpdateQuests.indexOf(IDquest) == -1)
							{
								if (openedQuestsId.indexOf(IDquest) >= 0) {
									item.openedQuests.push(itemQ);
								} else if (finishedQuestsId.indexOf(IDquest) >= 0) {
									item.finishedQuests.push(itemQ);
								} else {
									item.closedQuests.push(itemQ);
								}		
							}
					}			
				}
		
				if (item.openedQuests.length == 0 && item.closedQuests.length > 0 && item.finishedQuests.length == 0) {
					item.type = 'locked'; //не октрыто
					//sections["all"].items.push(item);
					if (item.description != 'Тестовая' && ! (App.isSocial('DM', 'VK', 'MM', 'FS', 'OK' ) && item.ID == 20))
					{
						//if (item.exclude == "") 
						//{
							//sections["locked"].items.push(item);
						//}
						
					}					
				}
				
				if (item.openedQuests.length > 0) {
					item.type = 'active';//активна
					//sections["all"].items.push(item);
					if (item.description != 'Тестовая' && ! (App.isSocial('DM', 'VK', 'MM', 'FS', 'OK' ) && item.ID == 20))
					{
						//if (item.exclude == "") 
						//{
							sections["active"].items.push(item);
						//}
						
					}					
				}
				
				if (item.openedQuests.length == 0 && item.closedQuests.length == 0 && item.finishedQuests.length > 0) {
					item.type = 'done';//выполено
					//sections["all"].items.push(item);
					if (item.description != 'Тестовая' && ! (App.isSocial('DM', 'VK', 'MM', 'FS', 'OK' ) && item.ID == 20))
					{
						//if (item.exclude == "") 
						//{
							//sections["done"].items.push(item);
						//}
						
					}
					
				}
				
				item["sid"] = ID;
				//sections[section].items.push(item);
				if (item.description != 'Тестовая' && ! (App.isSocial('DM', 'VK', 'MM', 'FS', 'OK' ) && item.ID == 20))
				{
					//if (item.exclude == "") 
					//{
						sections["all"].items.push(item);
					//}
					
				}
			}
			sections['all'].items.sortOn('order', Array.NUMERIC);
			sections['active'].items.sortOn('order', Array.NUMERIC);
		}
		
		private var artifacts:Object = { 1:[], 2:[], 3:[] };
		
		override public function drawBody():void {
			exit.x -= 30;
			
			drawMenu();
			
			setContentSection(settings.section, settings.page);
			contentChange();
			
		}
		
		public function drawMenu():void {
			
			var menuSettings:Object = {
				"all":			{order:1, 	title:Locale.__e("flash:1382952380301")},
				"active":		{order:4, 	title:Locale.__e("flash:1446313327612")},
				"done":			{order:6, 	title:Locale.__e("flash:1446313393958")}
				//"locked":		{order:7, 	title:Locale.__e("flash:1446313433698")}
			}
			
			for (var item:* in sections) {
				if (menuSettings[item] == undefined) continue;
				var settings:Object = menuSettings[item];
				settings['type'] = item;
				settings['onMouseDown'] = onMenuBttnSelect;
				
				if (settings) {
					settings["bgColor"] = [0xce934f,0xce934f];
					settings["borderColor"] = [0xbc7e3d, 0xbc7e3d];
					settings["height"] = 55;
					settings["radius"] = 10;
					settings["width"] = (item == 'all')?90:123;
					settings["bevelColor"] = [0xf5bc79,0xf5bc79];
					settings["captionOffsetY"] = -3;
					settings["fontSize"] = 30;
					settings["fontBorderColor"] = 0x7f3d0e;
					settings['active'] = {
						bgColor:				[0xe2b690, 0xe2b690],
						borderColor: 			[0xc69261,0xc69261],
						height: 				50,
						bevelColor:				[0xfff7e5, 0xfff7e5],	
						fontBorderColor:		0x7f3d0e//Цвет обводки шрифта		
					}
				}
						
				icons.push(new MenuButton(settings));
			}
			icons.sortOn("order");
			
			var sprite:Sprite = new Sprite();
			
			var offset:int = 0;
			for (var i:int = 0; i < icons.length; i++)
			{
				icons[i].x = offset;
				offset += icons[i].settings.width + 6;
				sprite.addChild(icons[i]);
			}
			layer.addChildAt(sprite,1);
			sprite.x = 80;
			sprite.y = 70;
			
		}
		
		private function onMenuBttnSelect(e:MouseEvent):void
		{
			if (App.user.quests.tutorial) 
				return;
			e.currentTarget.selected = true;
			setContentSection(e.currentTarget.type);
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
					if (sections[section].items[i].preview == 'invisible' && sections[section].items[i].sid != 'u5878df0a1baa4')
						continue;
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
			
			for (var i:int = 0; i < settings.content.length; i++)
			{
				if (App.user.stock.count(settings.content[i].sid) == 0)
				{
					settings.content.splice(i, 1);
				}
			}
			sections = { };
			createContent();
			findTargetPage(settings);
			setContentSection(settings.section,settings.page);
			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			contentChange();
		}
		override public function contentChange():void {
			
			for each(var _item:ChapterItem in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			
			items = new Vector.<ChapterItem>();
			var Ys:int = 100;
			settings.content.sortOn(['order', 'type'], Array.NUMERIC);
			//settings.content.sortOn('type');
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:ChapterItem = new ChapterItem(settings.content[i], this);
				
				bodyContainer.addChild(item);
				items.push(item);
				item.x = (settings.width - item.background.width) / 2;
				item.y = Ys - 5;
				Ys += 155;
			}
			
			sections[settings.section].page = paginator.page;
			settings.page = paginator.page;
		}
		
		
		override public function drawArrows():void 
		{			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 45;
			paginator.arrowLeft.x = paginator.arrowRight.width - 10;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 0;
			paginator.arrowRight.y = y;
			
			paginator.x = int((settings.width - paginator.width)/2 - 20);
			paginator.y = int(settings.height - paginator.height - 15);
		}		
	}
}

import buttons.Button;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.Load;
import core.Log;
import core.Numbers;
import core.Post;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import ui.Cursor;
import ui.UserInterface;
import ui.WishList;
import units.Field;
import units.Techno;
import units.Unit;
import wins.QuestsChaptersWindow;
import wins.Window;
import silin.filters.ColorAdjust;

internal class StockMenuItem extends Sprite {
	
	public var textLabel:TextField;
	public var icon:Bitmap;
	public var type:String;
	public var order:int = 0;
	public var title:String = "";
	public var selected:Boolean = false;
	public var window:*;
	
	public function StockMenuItem(type:String, window:*) {
		
		this.type = type;
		this.window = window;
		
		switch(type) {
			case "all"			: order = 1; title = Locale.__e("flash:1382952380301"); break;//Все
			case "active"		: order = 2; title = Locale.__e("flash:1446313327612"); break;//Активные materials
			case "done"			: order = 3; title = Locale.__e("flash:1446313393958"); break;//Выполненные others
			//case "locked"		: order = 3; title = Locale.__e("flash:1446313433698"); break;//Недоступные
		}

		icon.y = - icon.height + 6;
		
		addChild(icon);
		
		textLabel = Window.drawText(title,{
			fontSize:18,
			color:0xf2efe7,
			borderColor:0x464645,
			autoSize:"center"
		});
		
		addChild(textLabel);
		textLabel.x = (icon.width - textLabel.width) / 2 + 200;
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	private function onClick(e:MouseEvent):void {
		if (App.user.quests.tutorial)
		return
		this.active = true;
		window.setContentSection(type);
	}
	
	private function onOver(e:MouseEvent):void{
		if(!selected){
			effect(0.1);
		}
	}
	
	private function onOut(e:MouseEvent):void {
		if(!selected){
			icon.filters = [];
		}
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	public function set active(selected:Boolean):void {
		var format:TextFormat = new TextFormat();
		
		this.selected = selected;
		if (selected) {
			glow();
			format.size = 18;
			textLabel.setTextFormat(format);
		}else {
			icon.filters = [];
			textLabel.setTextFormat(textLabel.defaultTextFormat);
		}
	}
	
	public function glow():void{
		
		var myGlow:GlowFilter = new GlowFilter();
		myGlow.inner = false;
		myGlow.color = 0xf1d75d;
		myGlow.blurX = 10;
		myGlow.blurY = 10;
		myGlow.strength = 10
		icon.filters = [myGlow];
	}
	
	private function effect(count:int):void {
		var mtrx:ColorAdjust;
		mtrx = new ColorAdjust();
		mtrx.brightness(count);
		icon.filters = [mtrx.filter];
	}
}

import wins.RewardWindow
import wins.StockDeleteWindow;
import wins.WorldsWindow;
import wins.BonusList;
import wins.QuestsManagerWindow;
import wins.Window;
import flash.filters.GlowFilter;

internal class ChapterItem extends LayerX {
	
	public var item:*;
	public var background:Shape = new Shape();
	public var bitmap:Bitmap;
	public var window:*;
	public var chapterTextLabel:TextField;
	public var questsCounterTextLabel:TextField;
	public var chapterCharacter:Bitmap;
	public var bonusList:BonusList;
	public var goToQuestsBttn:Button;
	public var goalBitmap:Bitmap;
	public var checkMark:Bitmap;
	public var defFilters:Array = [new BlurFilter(40, 0, 2)];
	public var notOpenedTextLabel:TextField;
	public var descUpdate:TextField;
	public var doneTextLabel:TextField;
	private var preloader:Preloader = new Preloader();
	public var rewards:Sprite;
	public var textCont:LayerX = new LayerX();
	public var rewardTextLabel:TextField;
	private static var STARTPOS:int = 33;

	public function ChapterItem(item:*, window:*):void {
		
		this.item = item;
		this.window = window;
		
		this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
		this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		/*textCont.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		textCont.addEventListener(MouseEvent.MOUSE_UP, onUp);*/
		background.graphics.beginFill(0xf0e9e0, .7);
		background.graphics.drawRect(0, 0, 425, 130);
		background.y = 27;
		background.x = 30;
		background.graphics.endFill();
		background.filters = defFilters;
		addChild(background);
		
		//FiestaWinterWindow rules		
		if (QuestsChaptersWindow.find.indexOf(item.ID) >= 0) 
		{
			customGlowing(background);
		}
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		
		drawBttns();
		
		chapterTextLabel = Window.drawText(item.title, {
			width		:280,
			fontSize	:28,
			textAlign	:"center",
			color		:0xffdf34,
			borderColor	:0x5b3c06,
			multiline	:true,
			wrap		:true
		});
		
		addChild(chapterTextLabel);
		chapterTextLabel.x = (background.x + (background.width / 2)) - 140;
		chapterTextLabel.y = 5;
		
		var totalQuests:Number = 0;
		/*for (var qID:* in App.data.quests) {
			if (App.data.quests[qID].chapter == item.ID && App.data.quests[qID].type == 0) {
				totalQuests++
			}
		}*/	
		totalQuests = item.finishedQuests.length + item.openedQuests.length + item.closedQuests.length;
		
		questsCounterTextLabel = Window.drawText(Locale.__e('flash:1446287453859') + " " + item.finishedQuests.length + "/" + totalQuests, {
			width		:280,
			fontSize	:24,
			textAlign	:"center",
			color		:0xffffff,
			borderColor :0x7f3d0e,
			multiline	:true,
			wrap		:true
		});
		if (item.finishedQuests.length != totalQuests && item.type != 'locked')
			addChild(questsCounterTextLabel);
		questsCounterTextLabel.x = (background.x + (background.width / 2)) - 5;
		questsCounterTextLabel.y = 50;
		
		chapterCharacter = new Bitmap();
		addChild(chapterCharacter);
		Load.loading(Config.getImageIcon('updates/chapters', item.preview,'jpg'),
			function(data:Bitmap):void {
				var bg:Shape = new Shape();
				bg.graphics.beginFill(0xfff7e5, 1);
				bg.graphics.drawRoundRect(0, 0, 144, 144, 25, 25);
				bg.graphics.endFill();
				bg.x = background.x - 80;
				bg.y = background.y - 9;
				addChild(bg);
				
				chapterCharacter.bitmapData = data.bitmapData;
				Size.size(chapterCharacter, 134, 134);
				//chapterCharacter.scaleY = chapterCharacter.scaleX = 0.8;
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0x000000, 1);
				shape.graphics.drawRoundRect(0, 0, 134, 134, 25, 25);
				shape.graphics.endFill();
				shape.x = background.x - 75;
				shape.y = background.y - 4;
				chapterCharacter.mask = shape;			
				chapterCharacter.x = shape.x;
				chapterCharacter.y = shape.y;
				chapterCharacter.cacheAsBitmap = true;
				shape.cacheAsBitmap = true;
				if (item.type == 'locked')
					UserInterface.colorize(chapterCharacter, 0x676767, 0.8);
				
				addChild(chapterCharacter);	
				addChild(shape);
			}
		);	
		/*Load.loading(
			Config.getQuestIcon('icons', App.data.personages[1].preview),//кастЫль
			function(data:Bitmap):void {
				chapterCharacter.bitmapData = data.bitmapData;
				chapterCharacter.x = background.x + 20;
				chapterCharacter.y = background.y + 20;
				addChild(chapterCharacter);		
			}
		);*/
		
		/*bonusList = new BonusList(item.bonus, true, { hasTitle: false, background: 'giftCounterBacking' });
		addChild(bonusList);
		bonusList.x = (background.width - bonusList.width) / 2 + 20;
		bonusList.y = background.height - 60;	
		bonusList.height -= 15;
		bonusList.width -= 45;
		
		rewardTextLabel = Window.drawText(Locale.__e('flash:1382952380000'), {
			width		:280,
			fontSize	:25,
			textAlign	:"left",
			color:0xffffff,
			borderColor:0x643a00,
			multiline	:true,
			wrap		:true
		});
		
		addChild(rewardTextLabel);
		rewardTextLabel.x = bonusList.x - 75;
		rewardTextLabel.y = bonusList.y + 10;*/
		
		//addChild(preloader);
		//preloader.x = chapterCharacter.x + 90;
		//preloader.y =  chapterCharacter.y + 90;
		//preloader.scaleX = preloader.scaleY = 0.5;
		
		/*goalBitmap = new Bitmap();
		addChild(goalBitmap);
		if(item.hasOwnProperty('items')){
		item['target'] = (Numbers.firstProp(item.items).key);
		}
		else
			item['target'] = 499;
		Load.loading(
			Config.getIcon(App.data.storage[item.target].type, App.data.storage[item.target].preview),
			function(data:Bitmap):void {
				removeChild(preloader);	
				goalBitmap.bitmapData = data.bitmapData;
				if (goalBitmap.width > 60) {
					goalBitmap.scaleX = goalBitmap.scaleY = (56) / (goalBitmap.width);
				}
				if (goalBitmap.height > 60 ) {
					goalBitmap.height =  60;
					goalBitmap.scaleX = goalBitmap.scaleY;
				}
				bitmap.smoothing = true;
				goalBitmap.x = chapterCharacter.x + 50;
				goalBitmap.y = chapterCharacter.y + 35;
				App.ui.staticGlow(goalBitmap, { color:0xffef5e, size:5, strength:5 });
			}
		);*/
		var textUpdate:String = item.description;
		descUpdate = Window.drawText(item.description, {//Ещё не открыто
			fontSize	:22,
			textAlign	:"center",
			textLeading	:-3,
			color		:0x7e3e13,
			border		:false,
			multiline	:true,
			wrap		:true,
			width		:210
		});
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRect(0, 0, 425, 115);
		shape.graphics.endFill();
		shape.filters = [new BlurFilter(0,5,30)]
		textCont.mask = shape;
		shape.cacheAsBitmap = true;
		textCont.cacheAsBitmap = true;
		textCont.addChild(descUpdate);
		textCont.x = 105;
		textCont.y = 33;	
		shape.x = 105;
		shape.y = 35;
		addChild(textCont)
		
		addChild(shape);
		
		
		notOpenedTextLabel = Window.drawText(Locale.__e('flash:1446326824127'), {//Ещё не открыто
			width		:280,
			fontSize	:25,
			textAlign	:"left",
			color		:0xffffff,
			borderColor	:0x824c2f,
			multiline	:true,
			wrap		:true
		});
		
		addChild(notOpenedTextLabel);
		notOpenedTextLabel.x = background.x + background.width - notOpenedTextLabel.width + ((App.lang=="ru")?140:170);
		notOpenedTextLabel.y = background.y + (background.height / 2) - (notOpenedTextLabel.height / 2);
		
		if (item.openedQuests.length == 0 && item.closedQuests.length > 0 && item.finishedQuests.length == 0) {
			notOpenedTextLabel.visible = true;
		} else {
			notOpenedTextLabel.visible = false;
		}	
		
		var doneContainer:Sprite = new Sprite();
		addChild(doneContainer);
		doneContainer.x = background.x + background.width - 125;
		doneContainer.y = background.y + background.height - 115;
		
		if (item.openedQuests.length == 0 && item.closedQuests.length == 0 && item.finishedQuests.length > 0) {
			doneContainer.visible = true;
		} else {
			doneContainer.visible = false;
		}
		
		var shapeBg:Shape = new Shape();
		shapeBg.graphics.beginFill(0xe4a772);
		shapeBg.graphics.drawRoundRect(0, 0, 36, 28, 24, 24);
		shapeBg.filters = [new DropShadowFilter(1.0, 90, 0, 0.5, 2.0, 2.0, 1.0, 2, true, false, false), new DropShadowFilter(1.0, 90, 0xffffff, 0.5, 2.0, 2.0, 1.0, 2, false, false, false)];
	
		var bd2:BitmapData = new BitmapData( shapeBg.width + 50, shapeBg.height + 50, true, 0x0);
		var matrix:Matrix = new Matrix(1, 0, 0, 1, 4, 12);
		
		bd2.draw(shapeBg, matrix);
		bd2.draw(Size.scaleBitmapData(Window.textures.checkmarkBig, .6));
		checkMark = new Bitmap(bd2);
		checkMark.x = 33;
		checkMark.y = 20;
		doneContainer.addChild(checkMark);
		
		doneTextLabel = Window.drawText(Locale.__e('flash:1446376312281'), {//Выполнено
			width		:280,
			fontSize	:25,
			textAlign	:"left",
			color		:0x95e972,
			borderColor	:0x1a4a0e,
			multiline	:true,
			wrap		:true
		});
		
		doneContainer.addChild(doneTextLabel);
		doneTextLabel.x = checkMark.x - ((App.lang=="en")?2:25);
		doneTextLabel.y = checkMark.y + checkMark.height - 35;
		
		if (window.settings.find)
		{
			if (window.settings.find.indexOf(item.sid) != -1) {
				this.startGlowing();
			}
			
			findArray = [];
			for each(var _quest:* in item.openedQuests){
				if (window.settings.find.indexOf(_quest.ID) != -1){
					findArray.push(_quest.ID)
				}
			}
			
			if (findArray.length != 0)
				onGoToQuests();
			else
				findArray = null;
		}
	}
	
	private function onOver(e:MouseEvent):void{
		this.background.filters = defFilters.concat([new GlowFilter(0xfff10d, 0.4, 4, 4, 2, 2)]);
		this.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel)
	}
	
	private function onWheel(e:MouseEvent):void{
		//Log.alert('WHEEEEEEEEEEL DEEEEEEEEEEEELTA\n');
		//Log.alert(e.delta)
		e.delta *= 7;
		if ((textCont.y + e.delta) < (STARTPOS - textCont.height + background.height))
			e.delta = (STARTPOS - textCont.y - textCont.height + background.height);
			
		if ((textCont.y + e.delta) > STARTPOS)
			e.delta = (STARTPOS - textCont.y);
			
		if ((textCont.y + e.delta) < (STARTPOS - textCont.height + background.height) || (textCont.y + e.delta) > STARTPOS)
			return;
			
		this.textCont.y += e.delta;
	}
	
	private function onOut(e:MouseEvent):void{
		this.background.filters = defFilters;
		this.removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
	}
	/*private function onDown(e:MouseEvent):void{
	e.currentTarget.startDrag(
			false,
			new Rectangle(
				e.currentTarget.x,
				0,
				0,
				e.currentTarget.height
			)
			
		);
	}*/
	/*
	private function onUp(e:MouseEvent):void{
		textCont.stopDrag();
	}*/
	
	public function dispose():void {
		
	}
	
	public function drawBttns():void {
		
		var btnnCont:Sprite = new Sprite();
		addChild(btnnCont);
		btnnCont.x = (background.width - btnnCont.width) / 2 ;
		btnnCont.y = background.height - btnnCont.height / 2;
		
		if (item.type == 'locked')
			return;
			
		goToQuestsBttn = new Button( {
				width:140,
				height:45,
				fontSize:25,
				caption:Locale.__e("flash:1394010224398")
		});
		
		addChild(goToQuestsBttn);
		goToQuestsBttn.x = background.x + background.width - goToQuestsBttn.width - 5;
		goToQuestsBttn.y = background.y + (background.height / 2) - (goToQuestsBttn.height / 2) + 15;
		goToQuestsBttn.addEventListener(MouseEvent.CLICK, onGoToQuests);
		if (item.finishedQuests.length < (item.finishedQuests.length + item.openedQuests.length + item.closedQuests.length)) {
			goToQuestsBttn.visible = true;
		} else {
			goToQuestsBttn.visible = false;
		}	
	}	
	
	public var findArray:Array;
	private function onGoToQuests (e:Event = null):void 
	{
		//window.close();
		if (Window.hasType(QuestsManagerWindow))
			return;
		var questsManagerWindow:QuestsManagerWindow = new QuestsManagerWindow({
			find: findArray,
			popup: true,
			chapterItem: this,
			questID: item.ID,
			updatePreview: item.preview,
			personage: item.personage,
			questTitle: item.title,
			questDescription: item.description,
			questBonus: item.bonus,
			openedQuests: item.openedQuests,
			closedQuests: item.closedQuests,
			finishedQuests: item.finishedQuests
		});
		questsManagerWindow.show();
	}	
	
	private function customGlowing(target:*, callback:Function = null, colorGlow:uint = 0xFFFF00):void 
		{
			TweenMax.to(target, 1, { glowFilter: { color:colorGlow, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:colorGlow, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
				}});	
			}});
		}
}