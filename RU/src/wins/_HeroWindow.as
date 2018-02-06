package wins
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import ui.BottomPanel;
	import ui.UserInterface;
	import units.Hero;
	import units.Personage;
	import wins.elements.ShopItem;

	public class HeroWindow extends Window
	{
		public static const HEAD:String = 'head';
		public static const BODY:String = 'body';
		
		public var femaleBttn:ImageButton;
		public var maleBttn:ImageButton;
		public var saveBttn:Button;
		public var akaField:TextField;
		public var titleUser:TextField;
		public var hero:Hero;
		public var backUser:Bitmap;
		public var backLabel:Shape = new Shape();
		public var backBttn:Shape = new Shape();
		private var infoBttn:ImageButton = null;
		
		public var heroBg:Bitmap;
		public var saveSttings:Object = { };
		
		public var preloader:Preloader = new Preloader();
		public var clothing:Object = null;
		
		private var items:Array = [];
		private var backing:Bitmap;
		private var back:Shape = new Shape();
		public var sexBg:LayerX;
		public static var history:Object = { section:BODY, page:0 };
		private var tutorialMode:Boolean = false;
		
		public function checkOnDressed(sID:uint):Boolean
		{
			for each(var sid:* in hero.cloth)
			{
				if (sid == sID) 
					return true;
			}
			
			return false;
		}
		
		public function HeroWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = 620;
			settings["height"] = 590;
			settings["fontSize"] = 30;
			settings["hasPaginator"] = false;
			
			settings["title"] = Locale.__e("flash:1484301643090");
			
			saveSttings['sex'] = App.user.sex || 'm';
			saveSttings['aka'] = App.user.aka || App.user.first_name;
			
			settings["section"] = settings.section || history.section; 
			settings["page"] = settings.page || history.page;
			
			initContent();
			
			saveSttings.sID = App.user.body;
			saveSttings.head = App.user.head;
			saveSttings.sex = App.user.sex;
			
			/*if ((App.social == 'PL' || App.social == 'PLD') && App.user.quests.currentQID == 530) {
				tutorialMode = true;
				settings.width = 220;
				settings.height = 430;
			}*/
			super(settings);
		}
		
		public function initContent():void {
			
			if (clothing != null) return;
			
			clothing = {
				'm':{
					'head':[],
					'body':[]
				},
				'f':{
					'head':[],
					'body':[]
				}
			};
			
			for (var id:String in App.data.storage)
			{
				if (App.data.storage[id].market == 8)
				{
					var item:Object = App.data.storage[id];	
					if (item.visible == 0) continue;
					
					//if (Events.timeOfComplete > App.time) {
						//if (['1993', '1994', '1995', '1996', '2239','2237','2238','2236','2440','2441','2442','2443','3055','3056','3057','3058'].indexOf(id) >= 0) {
							//if (App.user.stock.count(int(id)) == 0) continue;
						//}
					//}
					if (App.data.storage[id].out == 15)
						item.sex = "f";
					else item.sex = "m";
					item['sid'] = id;
					item['onStock'] = false;
					if (App.user.stock.count(int(id)) > 0)
						item['onStock'] = true;
					
					if (item.part == 1)
						clothing[item.sex]['head'].push(item);
					else
						clothing[item.sex]['body'].push(item);
				}
			}
			
			for (id in clothing.m) {
				clothing.m[id].sortOn('order', Array.NUMERIC);
			}
			for (id in clothing.f) {
				clothing.f[id].sortOn('order', Array.NUMERIC);
			}
		}
		
		override public function drawBackground():void {
			//var background:Bitmap = backing(settings.width, settings.height, 30, "itemBacking");
			//layer.addChild(background);
			var background:Bitmap  = Window.backing(settings.width, settings.height , 50, 'workerHouseBacking');
			layer.addChild(background);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xfffa74,
				multiline			: settings.multiline,			
				fontSize			: 34,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x6e411e,			
				borderSize 			: 2,	
				
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -9;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		private var paginatorUp:Paginator;
		private var paginatorDown:Paginator;
		public function createPaginators():void
		{
			paginator = new Paginator(4, 4, 6, {
				hasArrow:true,
				hasButtons:true
			});
			
			paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);
			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  248,  290, { scaleX:-0.8, scaleY:0.8 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 572, 290, { scaleX:0.8, scaleY:0.8 } );
			
			bottomContainer.addChild(paginator);
		}
		
		private var headBttn:Button;
		private var bodyBttn:Button;
		
		private function createBttns():void
		{
			headBttn = new Button( {
				caption:					Locale.__e("flash:1382952380151"),
				mode:					HEAD,
				fontSize:				28,
				height:					36,
				width:					110,
				multiline:				true,
				bgColor: [0xcaec6e, 0x86ba38],
				bevelColor: [0xf5feb8, 0x648a38],
				fontColor: 0xffffff,
				fontBorderColor: 0x53742d,
				active:{
					bgColor:				[0x86ba38,0xcaec6e],
					bevelColor:				[0x648a38, 0xf5feb8],
					borderColor:			[0xc27b45, 0xffc285],
					fontColor:				0xffffff,
					fontBorderColor:		0x53742d			//Цвет обводки шрифта		
				}
			});
			
			backBttn.graphics.beginFill(0xebab52, .9);
		    backBttn.graphics.drawRect(0, 0, settings.width - 150, 45);
		    backBttn.graphics.endFill();
		    backBttn.x = (settings.width - backBttn.width) / 2 ;
		    backBttn.y = 5;
		    backBttn.filters = [new BlurFilter(40, 0, 2)];
			backBttn.alpha = 0.8;
		    bodyContainer.addChild(backBttn);
			
			bodyContainer.addChild(headBttn);
			headBttn.textLabel.y -= 2;
			headBttn.addEventListener(MouseEvent.CLICK, bttnClick);
			headBttn.x = settings.width/2 - 120;
			headBttn.y = 10;
			
			bodyBttn = new Button({
				caption:				Locale.__e("flash:1382952380153"),
				mode:					BODY,
				fontSize:				28,
				height:					36,
				width:					110,
				multiline:				true,
				bgColor: [0xcaec6e, 0x86ba38],
				bevelColor: [0xf5feb8, 0x648a38],
				fontColor: 0xffffff,
				fontBorderColor: 0x53742d,
				active:{
					bgColor:				[0x86ba38,0xcaec6e],
					bevelColor:				[0x648a38, 0xf5feb8],
					borderColor:			[0xc27b45, 0xffc285],
					fontColor:				0xffffff,
					fontBorderColor:		0x53742d			//Цвет обводки шрифта		
				}
			});
							
			bodyContainer.addChild(bodyBttn);								
			bodyBttn.textLabel.y -= 2;
			bodyBttn.addEventListener(MouseEvent.CLICK, bttnClick);
			bodyBttn.x = headBttn.x + 132;
			bodyBttn.y = 10;
		}
		
		private function bttnClick(e:MouseEvent):void
		{
			changeRazdel(e.currentTarget.settings.mode);
		}
		
		private function changeRazdel(mode:String):void
		{
			settings.mode = mode;
			history.section = mode; 
			switch(mode)
			{
				case HEAD:
					headBttn.state = Button.ACTIVE;
					bodyBttn.state = Button.NORMAL;
				break;
				
				case BODY:
					headBttn.state = Button.NORMAL;
					bodyBttn.state = Button.ACTIVE;
				break;
			}
			
			contentChange();
		}
		
		override public function drawBody():void
		{
			var backgroundTitle:Bitmap = Window.backingShort(190, 'titleBgNew', true);
			backgroundTitle.x = (settings.width - backgroundTitle.width) / 2;
			backgroundTitle.y = - 13;
			layer.addChild(backgroundTitle);
			
			backUser = Window.backing(190, 465, 40, 'paperClear');
			backUser.x = 32;
			backUser.y = 60;
			bodyContainer.addChild(backUser);
			
			drawMirrowObjs('decSeaweed', settings.width + 57, - 57, settings.height - 175, true, true, false, 1, 1, layer);
			
			createPaginators();
			createBttns();
			
			var heroDX:int = 120-10;
			var heroDY:int = 15;
			
			exit.x = settings.width - exit.width + 12;
			
			var akaBg:Shape = new Shape();
			akaBg.graphics.lineStyle(2, 0x5d5321, 1, true);
			akaBg.graphics.beginFill(0xddd7ae,1);
			akaBg.graphics.drawRoundRect(0, 0, 160, 25, 15, 15);
			akaBg.graphics.endFill();
			akaBg.x = heroDX - (akaBg.width) / 2;
			akaBg.y = 10 + heroDY;
			//bodyContainer.addChild(akaBg);
			
			akaField = Window.drawText(saveSttings.aka, App.self.userNameSettings({
				color:0x4f4f4f,
				borderColor:0xfcf6e4,
				border:false,
				textAlign:"left",
				fontSize:20,
				multiline:true,
				input:true
			}));
			
			akaField.height = 22;
			akaField.maxChars = 20; 
			akaField.x = akaBg.x + 6;
			akaField.y = akaBg.y + 2;
			
			akaField.addEventListener(FocusEvent.FOCUS_IN, onFocusInEvent);
			akaField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOutEvent);
			
			heroBg = Window.backing(135, 165, 30, "itemBacking");
			bodyContainer.addChild(heroBg);
			heroBg.x = heroDX - (heroBg.width) / 2 + 15;
			heroBg.y = 95 + heroDY;
			
			titleUser = Window.drawText(String(App.user.aka), {
				color:0xf5ee6e,
				borderColor:0x6e411e,
				textAlign:"center",
				autoSize:"center",
				fontSize:26,
				textLeading:-6,
				multiline:true
			});
			titleUser.wordWrap = true;
			titleUser.width = 140;
			titleUser.y = heroBg.y - 35;
			titleUser.x = heroBg.x;
			bodyContainer.addChild(titleUser);
			
			hero = new Hero(App.user, { sid:Personage.HERO, x:10, z:10 } );
			hero.uninstall();
			hero.touchable = false;
			hero.clickable = false;
			hero.x = heroBg.x/* + 65;*/
			hero.y = heroBg.y/* + 120;*/
			bodyContainer.addChild(hero);
			hero.framesType = 'walk';
			if (hero.textures) 
				hero.startAnimation();
			
			hero.change(saveSttings);

			
			var sexLabel:TextField = Window.drawText(Locale.__e("flash:1484305343833"), {
				fontSize:24,
				autoSize:"left",
				color:0x6e411e,
				border:false
			});
			sexLabel.x = heroDX - (sexLabel.width) / 2 + 14;
			sexLabel.y = heroBg.y + heroBg.height + 15;
			
			sexBg = new LayerX();
			back.graphics.beginFill(0xfbd174, .9);
		    back.graphics.drawRect(0, 0, heroBg.width, 90);
		    back.graphics.endFill();
		    back.filters = [new BlurFilter(10, 0, 2)];
			sexBg.addChild(back);
			bodyContainer.addChild(sexBg);
			sexBg.x = heroDX - (sexBg.width) / 2 + 15;
			sexBg.y = sexLabel.y + sexLabel.height;
			
			backLabel.graphics.beginFill(0xfff4b9, .9);
		    backLabel.graphics.drawRect(0, 0, sexLabel.textWidth + 5, 30);
		    backLabel.graphics.endFill();
		    backLabel.x = sexLabel.x - 3;
		    backLabel.y = sexLabel.y;
		    backLabel.filters = [new BlurFilter(30, 0, 2)];
		    bodyContainer.addChild(backLabel);
			
			
			bodyContainer.addChild(sexLabel);
			
			
			femaleBttn = new ImageButton(UserInterface.textures.female);
			maleBttn = new ImageButton(UserInterface.textures.male);
			//femaleBttn = new ImageButton(UserInterface.textures.cookie);
			//maleBttn = new ImageButton(UserInterface.textures.cookie2);
			
			femaleBttn.addEventListener(MouseEvent.CLICK, onFemaleClick);
			maleBttn.addEventListener(MouseEvent.CLICK, onMaleClick);
			
			bodyContainer.addChild(maleBttn);
			maleBttn.x = sexBg.x + 18;
			maleBttn.y = sexBg.y + 12;
			
			bodyContainer.addChild(femaleBttn);
			femaleBttn.x = sexBg.x + 30 + maleBttn.width;
			femaleBttn.y = sexBg.y + 12;
			
			saveBttn = new Button( {
				width:130,
				height:45,
				fontSize:26,
				caption:Locale.__e("flash:1382952380160")
			});
			
			saveBttn.x = heroDX - (saveBttn.width) / 2 + 11;
			saveBttn.y = sexBg.y + sexBg.height + 15;
			
			bodyContainer.addChild(saveBttn);
			saveBttn.addEventListener(MouseEvent.CLICK, onSaveEvent);
			
			drawItems();
			
			
			if(settings.hasOwnProperty('find')){
				var target:Object = App.data.storage[settings.find];
				if (target.part == 1)
					history.section = HEAD;
				else	
					history.section = BODY;
			}
			
			settings.mode = history.section;
			
			bodyBttn.state = Button.ACTIVE;
			
			if (saveSttings.sex == 'm') {
				//onMaleClick();
				maleBttn.filters = [new GlowFilter(0xd5edf8, 1, 10, 10, 4)];
			}else {
				//onFemaleClick();
				femaleBttn.filters = [new GlowFilter(0xd5edf8, 1, 10, 10, 4)];
			}
			
			changeHero();
			
			if (App.social == 'YB' || App.social == 'NN' || App.social == 'AI') {
				akaBg.visible = false;
				akaField.visible = false;
				var nameLabel:TextField = Window.drawText(App.user.first_name, {
					color:0x6d4b15,
					borderColor:0xfcf6e4,
					textAlign:"center",
					multiline:true,
					fontSize:22,
					width:akaBg.width
				});
				
				nameLabel.x = akaBg.x;
				nameLabel.y = akaBg.y;
				bodyContainer.addChild(nameLabel);
				nameLabel.height = nameLabel.textHeight + 6;
			}
			
			if (App.user.quests.tutorial && App.user.quests.currentQID == 530) {
				saveBttn.showGlowing();
				saveBttn.showPointing('bottom', 126, 26, bodyContainer);
				sexBg.showGlowing();
				
				paginator.hide();
				backing.visible = false;
				headBttn.visible = false;
				bodyBttn.visible = false;
				akaField.visible = false;
				akaBg.visible = false;
			}
			drawInfoBttn();
		}

		private function drawItems():void
		{
			backing = Window.backing(350, backUser.height, 20, 'paperClear');
			
			bodyContainer.addChild(backing);
			backing.x = 235;
			backing.y = backUser.y;
			
			paginator.x = backing.x + (backing.width - paginator.width) / 2;
			paginator.y = backing.y + backing.height + 8;
		}
		
		override public function contentChange():void
		{
			for (var m:int = 0; m < items.length; m++)
			{
				items[m].dispose();
				bodyContainer.removeChild(items[m]);
			}
			
			paginator.itemsCount = clothing[saveSttings.sex][settings.mode].length;
			paginator.update();
			
			items = [];
			var X:int = backing.x + 30;
			var Y:int = backing.y + 30;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:ClothItem = new ClothItem(clothing[saveSttings.sex][settings.mode][i], this);
				bodyContainer.addChild(item);
				item.visible = !tutorialMode;
				item.x = X;
				item.y = Y;
				
				items.push(item);
				X += item.background.width + 20;
				
				if (i % 2 == 1 && i>0)
				{
					X = backing.x + 30;
					Y += item.background.height + 45;
				}
			}
		}
		
		private function onFemaleClick(e:MouseEvent = null ):void 
		{
			saveSttings.sex = 'f';
			maleBttn.filters = [];
			femaleBttn.filters = [new GlowFilter(0xfbd9df, 1, 10, 10, 4)];
			saveSttings.head = User.GIRL_HEAD;
			saveSttings.sID = User.GIRL_BODY;
			changeHero();
		}
		
		private var loadCounter:uint = 0;
		private function changeHero():void
		{
			bodyContainer.addChild(preloader);
			preloader.x = heroBg.x + heroBg.width/2;
			preloader.y = heroBg.y + heroBg.height/2;
			
			loadCounter = 0;
			hero.change(saveSttings, onClothLoad);
			contentChange();
		}
		
		private function onClothLoad():void
		{
			loadCounter++;
			if (loadCounter == 2)
			{
				bodyContainer.removeChild(preloader);
			}
		}
		
		private function onMaleClick(e:MouseEvent = null):void 
		{
			saveSttings.sex = 'm';
			saveSttings.head = User.BOY_HEAD;
			saveSttings.sID = User.BOY_BODY;
			femaleBttn.filters = [];
			maleBttn.filters = [new GlowFilter(0xd5edf8, 1, 10, 10, 4)];
			changeHero();
		}
		
		private function onFocusInEvent(e:Event):void 
		{
			if (App.self.stage.displayState == StageDisplayState.FULL_SCREEN)
			{
				App.self.stage.displayState = StageDisplayState.NORMAL;
			}
			
			if(e.currentTarget.text == saveSttings.aka)	e.currentTarget.text = "";
		}
		
		private function onFocusOutEvent(e:Event):void
		{
			if(e.currentTarget.text == "" || e.currentTarget.text == " ") e.currentTarget.text = saveSttings.aka;
		}
		
		override public function drawExit():void
		{
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		private function onSaveEvent(e:MouseEvent):void
		{
			saveSttings.aka = akaField.text;
			
			App.user.aka = saveSttings.aka;
			App.user.sex = saveSttings.sex;
			App.user.head = saveSttings.head;
			App.user.body = saveSttings.sID;
			
			saveSttings.body = saveSttings.sID;
			
			App.user.onProfileUpdate(saveSttings);
			App.user.hero.change(saveSttings);
			close();
			
			//Nature.tryChangeMode();
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			if(hero) hero.stopAnimation();
			hero = null;
			
			akaField.removeEventListener(FocusEvent.FOCUS_IN, onFocusInEvent);
			akaField.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOutEvent);
			
			femaleBttn.removeEventListener(MouseEvent.CLICK, onFemaleClick);
			maleBttn.removeEventListener(MouseEvent.CLICK, onMaleClick);
			
			saveBttn.removeEventListener(MouseEvent.CLICK, onSaveEvent);
		}
		
		public function addCloth(sID:uint):void
		{
			for (var type:String in clothing[saveSttings.sex])
			{
				var L:uint = clothing[saveSttings.sex][type].length;
				for (var i:int = 0; i < L; i++)
				{
					if (clothing[saveSttings.sex][type][i].sid == sID)
					{
						clothing[saveSttings.sex][type][i].onStock = true;
						return;
					}
				}
			}
		}
		
		public function clothOff(sID:uint):void
		{
			if (App.data.storage[sID].part == 1){
				if (saveSttings.sex == 'm')	saveSttings.head = User.BOY_HEAD;
				else 						saveSttings.head = User.GIRL_HEAD;
			}else{
				if (saveSttings.sex == 'm')	saveSttings.sID = User.BOY_BODY;
				else 						saveSttings.sID = User.GIRL_BODY;
			}	
				
			changeHero();	
		}
		
		public function clothOn(sID:uint):void
		{
			if (App.data.storage[sID].part == 1)
				saveSttings.head = sID
			else
				saveSttings.sID = sID
				
			changeHero();	
		}
		
		private function drawInfoBttn():void 
		{
			infoBttn = new ImageButton(textures.infoBttnPink);
			bodyContainer.addChild(infoBttn);
			infoBttn.x = exit.x + 2;
			infoBttn.y = exit.y + 40;
			infoBttn.addEventListener(MouseEvent.CLICK, info);
			
			
		}
		
		private function info(e:MouseEvent = null):void {
			var hintWindow:WindowInfoWindow = new WindowInfoWindow( {
				popup: true,
				hintsNum:3,
				hintID:5,
				height:540
			});
			hintWindow.show();	
		}
	}
}

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import wins.Window;

	import buttons.Button;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Cursor;
	import ui.Hints;
	import ui.UserInterface;
	import units.Field;
	import units.Unit;
	import wins.elements.PriceLabel;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.Window;

	internal class ClothItem extends Sprite {
		
		public var item:*;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		//public var preloader:Preloader;
		public var title:TextField;
		public var priceBttn:Button;
		public var openBttn:Button;
		public var clothBttn:Button;
		public var window:*;
		private var CY:uint = 70;
		
		public var moneyType:String = "coins";
		
		private var preloader:Preloader = new Preloader();
		
		public function ClothItem(item:*, window:*) {
			
			this.item = item;
			this.window = window;
			
			
			background = Window.backing(130, 168, 10, "itemBacking");
			addChild(background);
			
			var sprite:LayerX = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			
			sprite.tip = function():Object { 				
				return {
					title:item.title,
					text:item.description
				};
			};
			
			drawTitle();
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height) / 2 - 15;
			
			//if (item.hasOwnProperty('free') && item.free == 1)
			//{
				//App.user.stock.buy(item.sid, 1, onBuyEvent);
			//}
			
			if(!item['onStock']){
				if (item.hasOwnProperty('unlock') && App.user.level < item.unlock.level && App.user.shop[item.sid] == undefined) {
					drawOpenBttn();
				}else{
					drawPriceBttn();
				}
			}else{
				drawBuyedLabel();
			}
			
			if (window.settings.find != null && window.settings.find.indexOf(int(item.sid)) != -1) {
				glowing();
			}
			
			Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
		}
		
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.scaleX = bitmap.scaleY = 0.8;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width)/ 2;
			bitmap.y = CY - (bitmap.height)/ 2
		}
		
		public function dispose():void {
			
			if(priceBttn != null){
				priceBttn.removeEventListener(MouseEvent.CLICK, onBuyEvent);
			}
			
			if(openBttn != null){
				openBttn.removeEventListener(MouseEvent.CLICK, onOpenEvent);
			}
			
			if(clothBttn != null){
				clothBttn.removeEventListener(MouseEvent.CLICK, onClothEvent);
			}
			
			if (Quests.targetSettings != null) {
				Quests.targetSettings = null;
				if (App.user.quests.currentTarget == null) {
					QuestsRules.getQuestRule(App.user.quests.currentQID, App.user.quests.currentMID);
				}
			}
		}
		
		public function drawTitle():void 
		{
			var size:Point = new Point(background.width - 20, 25);
			var pos:Point = new Point(
				10,
				-10
			);
			
			title = Window.drawTextX(String(item.title), size.x, size.y, pos.x, pos.y, this, {
			//title = Window.drawText(String(item.title), {
				color:0xffffff,
				borderColor:0x7f3d0e,
				textAlign:"center",
				autoSize:"center",
				fontSize:20,
				textLeading:-6,
				multiline:true
			});
			title.wordWrap = true;
			title.width = background.width - 20;
			title.y = -10;
			title.x = 10;
			//title.border = true;
			addChild(title);
		}
		
		public function drawBuyedLabel():void {
			
			var labelSettings:Object = {
				text:"",
				fontSize:20,
				autoSize:"left"
			}
			
			var bttnSettings:Object = {
				caption:"",
				fontSize:22,
				width:110,
				height:34
			};
			
			if (window.checkOnDressed(item.sid))
			{
				bttnSettings.caption = Locale.__e("Снять");
				bttnSettings.type = 1;
				labelSettings.text = Locale.__e("flash:1382952380162");
				labelSettings.fontSize = 24;
				labelSettings.borderColor = 0x85620d;
				labelSettings.color = 0xf0e6c1;
				
				background.filters = [new GlowFilter(0xFFFF00, 1, 15,15, 7, 1, true)]
			}
			else
			{
				bttnSettings.type = 0;
				bttnSettings.caption = Locale.__e("flash:1382952380163");
				bttnSettings.borderColor = [0x9f9171, 0x9f9171];
				bttnSettings.fontColor = 0xffffff;
				bttnSettings.fontBorderColor = 0xa9634e;
				bttnSettings.bgColor = [0xfeb268, 0xfe9f53];
				
				labelSettings.text = Locale.__e("flash:1382952380080");
				labelSettings.fontSize = 20;
				
				background.filters = null;
			}
			
			clothBttn = new Button(bttnSettings);
			//clothBttn.color = "fe9f53"
			
			addChild(clothBttn);
			clothBttn.x = background.width/2 - clothBttn.width/2;
			clothBttn.y = background.height - 22;
			
			clothBttn.addEventListener(MouseEvent.CLICK, onClothEvent);
				
			//var label:TextField = Window.drawText(labelSettings.text, labelSettings);
			//addChild(label);
			
			//label.x = (background.width - label.width)/2;
			//label.y = background.height - 54;
			
			if (bttnSettings.type == 1) {
				clothBttn.visible = false
				/*switch(int(item.sid))
				{
					case User.BOY_BODY:
					case User.BOY_HEAD:
					case User.GIRL_BODY:
					case User.GIRL_HEAD:
						clothBttn.visible = false
					break	
				}*/
			}
			
			CY = 90;
		}
		
		private function onClothEvent(e:MouseEvent):void
		{
			if (e.currentTarget.settings.type == 1)
				window.clothOff(item.sid);
			else
				window.clothOn(item.sid);
		}
		
		public function drawPriceBttn():void {
			
			var icon:Bitmap;
			var price:int = 0;
			var settings:Object = { fontSize:18, autoSize:"left" };
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379751"),
				fontSize:22,
				width:110,
				height:34
			};
		
			//if (item.price.hasOwnProperty['26']) {
			for (var mt:* in item.price)
				if(mt == Stock.COINS){
					moneyType = "coins";
				}
				else
				{
					moneyType = "real";
				}	
			
			price = item.price[mt];
			if (price > 0)
			{
				var priceLabel:PriceLabel = new PriceLabel(price, moneyType);
				priceLabel.x = (background.width - priceLabel.width)/2;
				priceLabel.y = background.height - 23 - priceLabel.height;
				addChild(priceLabel);
			}else{
				bttnSettings["caption"] = Locale.__e("flash:1382952379890");
			}
			if (moneyType == "real")
			{
				bttnSettings["bgColor"] 		= [0x99c9fc, 0x6697f5];
				bttnSettings["borderColor"]		= [0xbad4de, 0x376dda];
				bttnSettings["bevelColor"]		= [0x91c1fa, 0x376dda];
				bttnSettings["fontColor"]	 	= 0xffffff;
				bttnSettings["fontBorderColor"] = 0x395db3;
			}
			priceBttn = new Button(bttnSettings);
			addChild(priceBttn);
			priceBttn.x = background.width/2 - priceBttn.width/2;
			priceBttn.y = background.height - 22;
			
			priceBttn.addEventListener(MouseEvent.CLICK, onBuyAction);
		}
		
		public function drawOpenBttn():void {
			
			var sprite:Sprite = new Sprite();
			
			var icon:Bitmap;
			var settings:Object = { 
				fontSize:22, 
				autoSize:"left",
				color:0xA3D637,
				borderColor:0x38510D
			};
			
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379890"),
				fontSize:22,
				bgColor: [0xA9DC3C, 0x96C52E],
				borderColor : [0xf8f2bd, 0x836a07],
				fontColor : 0x4E6E16,
				fontBorderColor : 0xDCFA9B,
				width:110,
				height:34,
				shadow:true
			};		
			
			var open:TextField = Window.drawText(Locale.__e("flash:1382952380083"), {
				color:0x4A401F,
				borderSize:0,
				fontSize:16,
				autoSize:"left"
			});
			sprite.addChild(open);
			open.x = 5;
			open.y = 10;
			
			icon = new Bitmap(UserInterface.textures.fantsIcon,"auto",true);
			icon.scaleX = icon.scaleY = 0.7;
				
			icon.x = open.x + open.width + 2;
			icon.y = 6;

			sprite.addChild(icon);
			
			var count:TextField = Window.drawText(String(item.unlock.price),settings);
			sprite.addChild(count);
			count.x = icon.x + icon.width + 2;
			count.y = 8;
			
			var needed:TextField = Window.drawText(Locale.__e("flash:1382952380085",[item.unlock.level]), {
				color:0xbf1a22,
				fontSize:16,
				borderColor:0xfcf5e5,
				textAlign:"center",
				borderSize:6
			});
			
			needed.width = 130;
			needed.height = needed.textHeight;
			sprite.addChild(needed);
			needed.x = 0;
			needed.y = -12;
			
			openBttn = new Button(bttnSettings);
			sprite.addChild(openBttn);
			openBttn.x = 16;
			openBttn.y = 35;
				
			sprite.y = 111;
			addChild(sprite);
					
			openBttn.addEventListener(MouseEvent.CLICK, onOpenEvent);
		}
		
		private function onOpenEvent(e:MouseEvent):void {
			
			openBttn.removeEventListener(MouseEvent.CLICK, onOpenEvent);
			
			if (App.user.stock.take(Stock.FANT, item.unlock.price)) {
				
				Hints.minus(Stock.FANT, item.unlock.price, Window.localToGlobal(e.currentTarget), false, window);
				
				App.user.shop[item.ID] = 1;
				//window.contentChange();
				
				Post.send( {
					ctr:'user',
					act:'open',
					uID:App.user.id,
					sID:item.sid
				}, function(error:*, data:*, params:*):void {
					if (!error) {
						App.user.shop[item.sid] = 1;
						window.contentChange();
					}
				})
			}
		}
		
		private function onBuyAction(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			priceBttn.state = Button.DISABLED;
			App.user.stock.buy(item.sid, 1, onBuyEvent);
		}
		
		private function onBuyEvent(/*MONEY:uint,*/ price:uint):void
		{
			if (priceBttn)
			{
				var point:Point = localToGlobal(new Point(priceBttn.x, priceBttn.y));
				point.x += priceBttn.width / 2;
			}
			//Hints.minus(moneyType,price, point);
			
			window.addCloth(item.sid);
			window.contentChange();
		}
		
		private function glowing():void {
			if (!App.user.quests.tutorial) {
				customGlowing(background, glowing);
			}
			
			if (priceBttn) {
				if (App.user.quests.tutorial) {
					App.user.quests.currentTarget = priceBttn;
					
					priceBttn.showGlowing();
					priceBttn.showPointing("top", priceBttn.width/2 - 15, 0, priceBttn.parent);
				}else {
					customGlowing(priceBttn);
				}
			}
		}
		
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
				}});	
			}});
		}
	}
	


	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	internal class PriceLabel extends Sprite
	{
		public var icon:Bitmap;
		public var text:TextField;
		
		private var compare:Boolean = true; 
		private var withDifferent:Boolean = true; 
		private var sid:int = 0;
		
		public function PriceLabel(count:Number, moneyType:String, iconScale:Number = 0.8, params:Object = null) 
		{
			if (!params) params = { };
			compare = (params.hasOwnProperty('compare')) ? params.compare : true;
			withDifferent = (params.hasOwnProperty('withDifferent')) ? params.withDifferent : true;
			
			if(moneyType == "coins")		icon = new Bitmap(UserInterface.textures.goldenPearl, "auto", true);
			else if (moneyType == "real")	icon = new Bitmap(UserInterface.textures.blueCristal, "auto", true);
			else if (moneyType == "jems")	icon = new Bitmap(UserInterface.textures.gemsIcon, "auto", true);
			else if (moneyType == "ambers")	icon = new Bitmap(UserInterface.textures.ambersIcon, "auto", true);
			else if(moneyType == "energy")	icon = new Bitmap(UserInterface.textures.energyIcon, "auto", true);
			else if(moneyType == "exp")		icon = new Bitmap(UserInterface.textures.expIcon, "auto", true);
			else if(moneyType == "diamond" || moneyType == "tokens")		icon = new Bitmap(UserInterface.textures.diamond, "auto", true);
			else if (moneyType == "icecoins")	icon = new Bitmap(UserInterface.textures.icecoinsIcon, "auto", true);
			else if (moneyType == "shells")	icon = new Bitmap(UserInterface.textures.shellIcon, "auto", true);
			else if (moneyType == "kgold")	icon = new Bitmap(UserInterface.textures.kgoldIcon, "auto", true);
			else if (moneyType == "topcoins")	icon = new Bitmap(UserInterface.textures.topcoinsIcon, "auto", true);
			else if (moneyType == "free_item")	icon = new Bitmap(new BitmapData(30,30,true,0), "auto", true);
			else 								icon = new Bitmap(new BitmapData(1,1,true,0), "auto", true);
			
			addChild(icon);
			icon.scaleX = icon.scaleY = iconScale;
			icon.smoothing = true;
			
			icon.x = 0;
			icon.y = 0;
			sid = params.sid;
			
			updatePrice(count, moneyType);
			
			addChild(text);
			text.height = text.textHeight;
			
			text.x = icon.width + 5;
			text.y = icon.height / 2 - text.textHeight / 2;
			
			if (moneyType == 'free_item' && sid)
				loadIcon(sid);
		}
		
		public function updatePrice(price:int, moneyType:String):void {
			var _price:String = String(price);
			
			var settings:Object = {
				fontSize:24,
				autoSize:"left",
				color:0xffdc39,
				borderColor:0x6d4b15
			}
			
			var onStock:int;
			if (moneyType == "real"){
				settings["color"]	 	= 0xfedb38;
				settings["borderColor"] = 0x6c4b15;
			}else if (moneyType == "diamond") {
				settings["color"]	 	= 0xb0ffff;
				settings["borderColor"] = 0x112f5f;
			//}else if (moneyType == 'jems') {
				//onStock = App.user.stock.count(Stock.GEMS);
				//if (compare)
					//_price = Locale.__e('flash:1382952380278', [onStock, price]);
				//
				//if (withDifferent && price > onStock) {
					//settings['color'] = 0xee9177;
					//settings['borderColor'] = 0x8c2a24;
				//}
			//}else if (moneyType == 'ambers') {
				//onStock = App.user.stock.count(Stock.AMBER);
				//if (compare)
					//_price = Locale.__e('flash:1382952380278', [onStock, price]);
				//
				//if (withDifferent && price > onStock) {
					//settings['color'] = 0xee9177;
					//settings['borderColor'] = 0x8c2a24;
				//}
			//}else if (moneyType == 'icecoins') {
				//onStock = App.user.stock.count(Stock.ICECOINS);
				//if (compare)
					//_price = Locale.__e('flash:1382952380278', [onStock, price]);
				//
				//if (withDifferent && price > onStock) {
					//settings['color'] = 0xee9177;
					//settings['borderColor'] = 0x8c2a24;
				//}else {
					//settings['color'] = 0xb0ffff;
					//settings['borderColor'] = 0x112f5f;
				//}
			//}else if (moneyType == 'shells') {
				//onStock = App.user.stock.count(Stock.SHELLS);
				//if (compare)
					//_price = Locale.__e('flash:1382952380278', [onStock, price]);
				//
				//if (withDifferent && price > onStock) {
					//settings['color'] = 0xee9177;
					//settings['borderColor'] = 0x8c2a24;
				//}else {
					//settings['color'] = 0xb0ffff;
					//settings['borderColor'] = 0x112f5f;
				//}
			//}else if (moneyType == 'free_item') {
				//onStock = App.user.stock.count(sid);
				//if (compare)
					//_price = Locale.__e('flash:1382952380278', [onStock, price]);
				//
				//if (withDifferent && price > onStock) {
					//settings['color'] = 0xee9177;
					//settings['borderColor'] = 0x8c2a24;
				//}else {
					//settings['color'] = color;
					//settings['borderColor'] = borderColor;
				//}
			}
			
			text = Window.drawText(_price, settings);
			
		}
		
		private function get color():uint {
			switch(sid) {
				//case Stock.GAVAY_COINS:	return 0xe7e8e3;
			}
			
			return 0xffdc39;
		}
		
		private function get borderColor():uint {
			switch(sid) {
				//case Stock.GAVAY_COINS:	return 0x5b5f58;	
			}
			
			return 0x6d4b15;
		}
		
		private function loadIcon(sid:*):void {
			if (!App.data.storage[sid]) return;
			Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), function(data:Bitmap):void {
				icon.bitmapData = data.bitmapData;
				icon.smoothing = true;
				icon.width = 25;
				icon.scaleY = icon.scaleX;
			});
		}
		
	}

