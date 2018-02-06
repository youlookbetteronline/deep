package wins
{
	import buttons.Button;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import utils.ActionsHelper;
	
	public class SaleLimitWindow extends AddWindow
	{
		public static var picCoords:Object = new Object(/*{x:10, y:10}*/);
		
		public var maska:Shape = new Shape();
		//public var action:Object;
		public var picture:Bitmap = new Bitmap();
		
		private var items:Array = new Array();
		private var container:Sprite;
		private var actionImages:Object;
		private var priceBttn:Button;
		private var timerText:TextField;
		private var pID:uint;
		private var descriptionLabel:TextField;
		private var backgroundItem:Bitmap = new Bitmap();
		private var background:Bitmap;
		private var axeX:int
		private var _descriptionLabel:TextField;
		private var promoCount:int = 0;
		private var menuSprite:Sprite
		private var bttns:Array = [];
		private var glowing:Bitmap;
		private var stars:Bitmap;
		private var stars2:Bitmap;
		private var stars3:Bitmap;
		private var stars4:Bitmap;
		private var stars5:Bitmap;
		private var stars6:Bitmap;
		private var timerContainer:Sprite;
		private var cont:Sprite;
		private var back:Shape = new Shape();
		private var bias:Number = 50;
		private var desc:TextField;
		
		protected var actions:Object;
		
		public function SaleLimitWindow(settings:Object = null)
		{
			pID = settings.pID;
			actions = App.data.actions[pID];
			if (settings == null)
			{
				settings = new Object();
			}
			initDesc();
			settings['width'] = 430;
			settings['height'] = 395 + desc.height;
			
			settings['title'] = Locale.__e("flash:1382952379793");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['exitTexture'] = 'closeBttnMetal';
			settings['fontColor'] = '0xffffff';
			settings['fontSize'] = 44;
			settings['fontBorderColor'] = 0x4b7915;
			settings['shadowColor'] = 0x085c10;
			settings['fontBorderSize'] = 3;
			
			super(settings);
		}
		
		override public function drawPromoPanel():void
		{
		
		}
		
		private function initDesc():void 
		{
			var descText:String = App.data.actions[pID].text1;
			if (descText == '')
				descText = App.data.storage[Numbers.firstProp(App.data.actions[pID].items).key].description;
			desc = Window.drawText(descText, {
				color: 0x6d350d, border: false, textAlign: "center", autoSize: "center", fontSize: 23, textLeading: -6, multiline: true});
			desc.wordWrap = true;
			desc.width = 350;
		}
		
		override public function drawBackground():void
		{
			var background:Bitmap = backing(settings.width, settings.height, 45, "capsuleWindowBacking"/*, "questsSmallBackingBottomPiece"*/);
			layer.addChild(background);
		}
		
		public function changePromo(pID:String):void
		{
			App.self.setOffTimer(updateDuration);
			action = App.data.actions[pID];
			settings.content = initContent(action.items); 
			settings['L'] = settings.content.length;
			if (settings['L'] < 2) settings['L'] = 2;
			
			drawImage();
			contentChange();
			drawPrice();
			drawTime();
			
			App.self.setOnTimer(updateDuration);
			
			if (fader != null)
				onRefreshPosition();
			
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			exit.y -= 10;
			
			if (menuSprite != null)
			{
				menuSprite.x = settings.width / 2 - (promoCount * 70) / 2 - 20;
			}
		}
		
		public override function dispose():void
		{
			for each (var _item:ActionItem in items)
			{
				_item = null;
				this.removeEventListener(MouseEvent.MOUSE_MOVE, movePictureParallax);
			}
			
			App.self.setOffTimer(updateDuration);
			super.dispose();
		}
		
		override public function drawBody():void
		{
			this.y -= 20;
			fader.y += 20;
			
			drawRibbon();
			titleLabel.y += 10;
			var glowIcon:Bitmap = new Bitmap(Window.textures.dailyBonusItemGlow);
			glowIcon.scaleX = glowIcon.scaleY = 2.5;
			glowIcon.smoothing = true;
			glowIcon.x = (settings.width - glowIcon.width) / 2;
			glowIcon.y = -130;
			bodyContainer.addChild(glowIcon);
			
			var star3:Bitmap = new Bitmap(Window.textures.decStarRed);
			star3.x = -15;
			star3.y = -43;
			star3.smoothing = true;
			bodyContainer.addChild(star3);
			
			var bubbles3:Bitmap = new Bitmap(Window.textures.bubbles3);
			bubbles3.x = 41;
			bubbles3.y = -62;
			bubbles3.smoothing = true;
			bodyContainer.addChild(bubbles3);
						
			var squid:Bitmap = new Bitmap(Window.textures.squid);
			squid.x = -158;
			squid.y = 0;
			squid.smoothing = true;
			bodyContainer.addChild(squid);
			
			var fish2:Bitmap = new Bitmap(Window.textures.decFish2);
			fish2.x = settings.width - 25;
			fish2.y = settings.height - 150;
			layer.addChildAt(fish2, 0);
			
			drawMirrowObjs('decSeaweedWithBubbles', settings.width + 56, - 56, settings.height - 267, true, true, false, 1, 1, layer);
			
			backgroundItem = new Bitmap(Window.textures.actionItemBg);
			backgroundItem.x = (settings.width - backgroundItem.width) / 2;
			backgroundItem.y = 24;
			bodyContainer.addChild(backgroundItem);
			
			Load.loading(Config.getImage('actions/backgrounds', actions.picture, 'jpg'), onBgComplete);
			bodyContainer.addChild(picture);
			bodyContainer.addChild(maska);

			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2;
			container.y = 60;

			changePromo(settings['pID']);
			
			if (settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;

			drawDescription();
		}
		
		public function drawPrice():void
		{
			var bttnSettings:Object = {fontSize: 36, width: (App.isSocial('OK', 'MM')) ? 208 : 180, height: 52, hasDotes: false, textAlign: 'center'};
			var priceLable:Object = ActionsHelper.priceLable(action.price[App.social]);
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
			
			bttnSettings['caption'] = Locale.__e(priceLable.text, [priceLable.price])
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = settings.height - priceBttn.height / 2 - 40;
			
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			
			if (cont != null)
				bodyContainer.removeChild(cont);
			
			cont = new Sprite();
			
			bodyContainer.addChild(cont);
			cont.x = priceBttn.x + priceBttn.width / 2 - cont.width / 2;
			cont.y = priceBttn.y - 30;
		}
		
		public function drawTime():void
		{
			if (timerContainer != null)
				bodyContainer.removeChild(timerContainer);
			
			timerContainer = new Sprite()

			descriptionLabel = drawText(Locale.__e('flash:1393581955601'), {fontSize: 30, textAlign: "right", color: 0xffffff, borderColor: 0x7f3d0e});
			descriptionLabel.width = descriptionLabel.textWidth + 10;
			timerContainer.addChild(descriptionLabel);
			
			var time:int = action.duration * 60 * 60 - (App.time - App.data.actions[action.id].time);
			
			timerText = Window.drawText(TimeConverter.timeToStr(time), {color: 0xffffff, letterSpacing: 3, textAlign: "left", fontSize: 28,//30,
				borderColor: 0x7f3d0e});
			timerText.width = timerText.textWidth + 10;
			timerText.y = descriptionLabel.y + 2;
			timerText.x = descriptionLabel.x + descriptionLabel.width + 3;
			timerContainer.addChild(timerText);
			
			bodyContainer.addChild(timerContainer);
			timerContainer.x = (settings.width - timerContainer.width) / 2;
			timerContainer.y = 280;
		}
		
		public override function contentChange():void
		{
			for each (var _item:ActionItem in items)
			{
				container.removeChild(_item);
				_item = null;
			}
			
			items = [];
			
			var Xs:int = 0;
			var Ys:int = 0;
			var X:int = 0;
			
			var itemNum:int = 0;
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var item:ActionItem = new ActionItem(settings.content[i], this);
				
				container.addChild(item);
				items.push(item);
			}
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, movePictureParallax);
			
			container.y = 32;
			container.x = (settings.width - item.background.width) / 2;
		}
		
		override protected function onRefreshPosition(e:Event = null):void
		{
			var stageWidth:int = App.self.stage.stageWidth;
			var stageHeight:int = App.self.stage.stageHeight;
			
			layer.x = (stageWidth - settings.width) / 2;
			layer.y = (stageHeight - settings.height) / 2;
			
			fader.width = stageWidth;
			fader.height = stageHeight;
		}
		
		private function drawDescription():void
		{

			back.graphics.beginFill(0xf6db65, .9);
			back.graphics.drawRect(0, 0, settings.width - 120, desc.textHeight + 10);
			back.graphics.endFill();
			back.x = (settings.width - back.width) / 2;
			back.y = timerContainer.y + 37;
			back.filters = [new BlurFilter(40, 0, 2)];
			
			desc.y = back.y + (back.height - desc.textHeight) / 2;
			desc.x = (settings.width - desc.width) / 2;
			
			bodyContainer.addChild(back);
			bodyContainer.addChild(desc);
		}
		
		private function drawMenu():void
		{
			menuSprite = new Sprite();
			var X:int = 10;
			
			if (App.data.promo == null) return;
			bodyContainer.addChild(menuSprite);
			menuSprite.y = settings.height - 70;
			var bg:Bitmap = Window.backing((promoCount * 70) + 40, 70, 10, 'smallBacking');
			menuSprite.addChildAt(bg, 0);
			
			menuSprite.x = (settings.width - menuSprite.width) / 2 - 10;
		}
		
		private function drawImage():void
		{
			if (action.image != null && action.image != " " && action.image != "")
			{
				Load.loading(Config.getImage('promo/images', action.image), function(data:Bitmap):void
				{
					
					var image:Bitmap = new Bitmap(data.bitmapData);
					bodyContainer.addChildAt(image, 0);
					image.x = 20;
					image.y = 185;
					if (action.image == 'bigPanda')
					{
						image.x = -200;
						image.y = -20;
							//this.x += 100;
					}
				});
			}
			else
			{
				axeX = settings.width / 2;
			}
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var sID:* in data)
				result.push({sID: sID, count: data[sID], order: action.iorder[sID], pID: settings.pID});
			
			result.sortOn('order');
			return result;
		}
		
		private function onBgComplete(data:Bitmap):void
		{
			picture.bitmapData = data.bitmapData;
			Size.size(picture, settings.width - 20, settings.height - 20);
			picture.smoothing = true;
			maska.graphics.beginFill(0xFFFFFF, 1);
			maska.graphics.drawCircle(0, 0, 88);
			maska.graphics.endFill();
			Size.size(picture, 400, 400);
			picture.x = backgroundItem.x + (backgroundItem.width - picture.width) / 2;
			picture.y = backgroundItem.y + (backgroundItem.height - picture.height) / 2;
			picCoords['x'] = picture.x;
			picCoords['y'] = picture.y;
			maska.x = backgroundItem.x + backgroundItem.width / 2;
			maska.y = backgroundItem.y + backgroundItem.height / 2 - 5;
			
			maska.cacheAsBitmap = true;
			picture.mask = maska;
			
			pictureParallax();
		}
		
		private function updateDuration():void
		{
			var time:int = action.duration * 60 * 60 - (App.time - App.data.actions[action.id].time);
			timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0)
			{
				descriptionLabel.visible = false;
				timerText.visible = false;
			}
		}
		
		private function movePictureParallax(e:MouseEvent):void
		{
			pictureParallax();
		}
		
		private function pictureParallax():void
		{
			picture.x = picCoords.x - bias / 2 + bias * (mouseX / stage.stageWidth) + picture.width / 8;
			picture.y = picCoords.y - bias / 2 + bias * (mouseY / stage.stageHeight);
			if (items.length > 0 && items[0].anime)
			{
				items[0].anime.x = items[0].animeCoords.x - (bias / 8) + (bias / 4) * (mouseX / stage.stageWidth);
				items[0].anime.y = items[0].animeCoords.y - (bias / 8) + (bias / 4) * (mouseY / stage.stageHeight);
			}
		}
	}
}

import core.Load;
import flash.display.Bitmap;
import flash.text.TextField;
import units.Anime2Golden;
import wins.Window;

internal class ActionItem extends LayerX
{
	public var count:uint;
	public var sID:uint;
	
	public var background:Bitmap;
	public var bitmap:Bitmap;
	
	public var title:TextField;
	public var window:*;
	public var animeCoords:Object;
	public var anime:Anime2Golden;
	
	private var sprite:LayerX;
	private var preloader:Preloader = new Preloader();
	
	private var bonus:Boolean = false;
	
	public function ActionItem(item:Object, window:*, bonus:Boolean = false)
	{
		sID = item.sID;
		count = item.count;
		this.window = window;
		this.bonus = bonus;
		
		background = new Bitmap(Window.textures.actionItemBg);
		sprite = new LayerX();
		addChild(sprite);
		tip = function():Object
		{
			return {title: App.data.storage[sID].title, text: App.data.storage[sID].description};
		};
		drawTitle();
		
		addChild(preloader);
		preloader.x = (background.width) / 2;
		preloader.y = (background.height) / 2 - 15;
		
		Load.loading(Config.getSwf(App.data.storage[sID].type, App.data.storage[sID].preview)+ '?1', onAnimComplete);
	}
	
	private function onAnimComplete(swf:*):void
	{
		if (preloader)
		{
			removeChild(preloader);
			preloader = null;
		}
		anime = new Anime2Golden(swf, {w: background.width - 100, h: background.height - 50, type: App.data.storage[sID].type});
		sprite.addChild(anime);
		anime.x = (background.width - sprite.width) / 2;
		anime.y = (background.height - sprite.height) / 2;
		animeCoords = {x: anime.x, y: anime.y};
	}
	
	private function addBonusLabel():void
	{
		removeChild(background);
		background = null;
		background = Window.backing(150, 190, 55, 'shopSpecialBacking');
		addChild(background);
		
		var bonusIcon:Bitmap = new Bitmap(Window.textures.redBow);
		bonusIcon.y = -20;
		bonusIcon.x = -20;
		addChild(bonusIcon);
	}
	
	private function drawTitle():void
	{
		if (!App.data.storage.hasOwnProperty(sID))
		{
			Window.closeAll();
			return;
		}
		title = Window.drawText(String(App.data.storage[sID].title), {color: 0xffffff, borderColor: 0x7f3d0e, textAlign: "center", autoSize: "center", fontSize: 30, textLeading: -6, multiline: true});
		title.wordWrap = false;
		title.width = background.width - 20;
		
		var ribbWidth:int = title.textWidth + 100;
		if (ribbWidth < 200)
			ribbWidth = 200;
		var yellowRibbon:Bitmap = Window.backingShort(ribbWidth, 'actionRibbonBg');
		yellowRibbon.scaleY = .5;
		yellowRibbon.x = (background.width - yellowRibbon.width) / 2;
		yellowRibbon.y = background.y + background.height - 35;
		addChild(yellowRibbon);
		title.y = yellowRibbon.y + 3;
		title.x = yellowRibbon.x + (yellowRibbon.width - title.width) / 2;
		addChild(title);
	}
}