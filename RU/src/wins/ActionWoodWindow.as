package wins 
{
	import api.com.adobe.images.PNGEncoder;
	import buttons.Button;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class ActionWoodWindow extends AddWindow 
	{
		private var timerText:TextField;
		private var timerContainer:Sprite;
		private var buyBttnConteiner:Sprite = new Sprite();
		private var priceBttn:Button;
		private var items:Array = new Array();
		private var container:Sprite;
		private var woodShelf2:Bitmap;
		private var backgroundDown:Bitmap = new Bitmap();
		private var paperBg:Bitmap = new Bitmap();
		private var backgroundUp:Bitmap = new Bitmap();
		
		public function ActionWoodWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = { };
			}
			settings['width'] = 560;
			settings['height'] = 473;
			settings['title'] = App.user.promo[settings.pID].text1;// 'Домик аквалангиста'//Locale.__e('flash:1382952379793');
			settings['hasTitle'] = true;
			settings['hasPaginator'] = false;
			settings['exitTexture'] = 'closeBttnWood';
			settings['fontColor'] = 0xffffff;
			settings['fontSize'] = 46;
			settings['fontBorderColor'] = 0x244700;
			settings['fontBorderSize'] = 3;
			super(settings);
			
		}
		
		override public function drawBody():void 
		{
			drawRibbon();
			titleLabel.y = -95;
			titleBackingBmap.y = titleLabel.y -7;
			exit.y = -50;
			exit.x = settings.width - exit.width - 15;
			drawTimer();
			updateDuration();
			App.self.setOnTimer(updateDuration);
			
			settings.content = initContent(action.items);
			//settings.content.lenght = 6
			if (settings.content.lenght <= 6 )
			{
				reDrawBg();
			}
			
			var decSeaSprite:Sprite = new Sprite();
			drawMirrowObjs('decSeaweed', settings.width + 58, -58, settings.height - 180, true, true, false, 1, 1, decSeaSprite);
			layer.addChildAt(decSeaSprite, 0);
			contentChange();
			drawPrice();
		}
		
		override public function drawPromoPanel():void 
		{
			//super.drawPromoPanel();
		}
		override public function drawBackground():void 
		{
			
			backgroundDown = backing2(settings.width, settings.height, 50, 'woodBgMid', 'woodBgDown');
			backgroundDown.x = (settings.width - backgroundDown.width) / 2;
			backgroundDown.y = (settings.height - backgroundDown.height) / 2;
			layer.addChild(backgroundDown);
			backgroundUp = backingHorizontal(settings.width + 30, 'woodBgUp');
			backgroundUp.y = backgroundDown.y - backgroundUp.height + 30;
			backgroundUp.x = (settings.width - backgroundUp.width) / 2;
			layer.addChild(backgroundUp);
			paperBg = backing4(settings.width - 25, settings.height - 104, 50, 'paperBgUpL', 'paperBgUpR', 'paperBgDownL', 'paperBgDownR');
			paperBg.x = (settings.width - paperBg.width) / 2;
			paperBg.y = backgroundUp.y + 65;
			layer.addChild(paperBg);
			
			var woodShelf:Bitmap = backingHorizontal(paperBg.width + 140, 'woodShelf');
			woodShelf.x = (settings.width - woodShelf.width) / 2;
			woodShelf.y = 50;
			woodShelf2 = backingHorizontal(paperBg.width + 140, 'woodShelf');
			woodShelf2.x = (settings.width - woodShelf.width) / 2;
			woodShelf2.y = woodShelf.y + woodShelf2.height - 40;
			layer.addChild(woodShelf2);
			layer.addChild(woodShelf);
		}
		public function reDrawBg():void 
		{
			settings['height'] = 310;
			layer.removeChild(backgroundDown);
			layer.removeChild(paperBg);
			backgroundDown = backing2(settings.width, settings.height, 50, 'woodBgMid', 'woodBgDown');
			backgroundDown.x = (settings.width - backgroundDown.width) / 2;
			backgroundDown.y = (settings.height - backgroundDown.height) / 2;
			layer.addChildAt(backgroundDown, 1);
			paperBg = backing4(settings.width - 25, settings.height -94, 50, 'paperBgUpL', 'paperBgUpR', 'paperBgDownL', 'paperBgDownR');
			paperBg.x = (settings.width - paperBg.width) / 2;
			paperBg.y = backgroundUp.y + 65;
			layer.addChildAt(paperBg, 2);
			woodShelf2.visible = false
		}
		
		public function drawTimer():void {
			
			if (timerContainer != null)
				bodyContainer.removeChild(timerContainer);
				
			timerContainer = new Sprite()
			
			var timerIcon:Bitmap = new Bitmap(Window.textures.timerDark);
			timerContainer.addChild(timerIcon);
			
			var descriptionLabel:TextField = drawText(Locale.__e('flash:1393581955601'), {
				fontSize	:30,
				textAlign	:"left",
				color		:0x603024,
				borderSize	:0
			});
			descriptionLabel.x =  timerIcon.width + 5;
			descriptionLabel.y =  (timerIcon.height - descriptionLabel.textHeight) / 2;
			timerContainer.addChild(descriptionLabel);
			
			var time:int;
			if (action.hasOwnProperty('additional'))
				time = action.duration * 60 * 60 - (App.time - action.time);
			else
				time = action.duration * 60 * 60 - (App.time - action.time);
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color			:0xf8d74c,
				letterSpacing	:3,
				textAlign		:"left",
				fontSize		:34,
				borderColor		:0x502f06,
				autoSize		: 'left'
			});
			timerText.width = 120;
			timerText.x = descriptionLabel.x + descriptionLabel.textWidth + 5;
			timerText.y =  (timerIcon.height - timerText.textHeight) / 2;
			
			timerContainer.addChild(timerText);
			timerContainer.y = 10;
			timerContainer.x = (settings.width - timerContainer.width) / 2;
			
			bodyContainer.addChild(timerContainer);
		}
		
		private function updateDuration():void
		{
			var time:int = action.duration * 3600 - (App.time - App.data.actions[action.id].begin_time);
			timerText.text = TimeConverter.timeToStr(time);
		}
		
		public function drawPrice():void {
			
			var bttnSettings:Object = {
				fontSize:32,
				width:186,
				height:52 + 10*int(App.isSocial('MX'))
			};
			price = action.price[App.self.flashVars.social];
			var text:String = '%d';
			switch(App.self.flashVars.social) {
				
				case "VK":
						text = 'flash:1382952379972';
					break;
				case "DM":
						text = 'flash:1382952379972';
					break;
				case "OK":
						text = 'Купить за %d ОК';
					break;	
				case "MM":
						text = '[%d мэйлик|%d мэйлика|%d мэйликов]';
					break;
				case "HV":
					price = int(price) / 100;
					text = '%d €';
				break;	
				case "PL":
				case "AI":
					text = '%d aコイン';
					bttnSettings.fontSize = 20;
					break;
				case "YB":
					text = 'flash:1421404546875'; 
					bttnSettings.fontSize = 20;
					break;
				case "MX":
					text = '%d pt.'
					break;
				case "FS":
					text = '%d ФМ'; 
				break;
				case "NK":
					text = '%d €GB'; 
				break;
				case "YN":
					text = String(price) + ' USD'; 
					break;
				case "FB":
						var price:Number = action.price[App.self.flashVars.social];
						price = price * App.network.currency.usd_exchange_inverse;
						price = int(price * 100) / 100;
						text = price + ' ' + App.network.currency.user_currency;
					break;
			}
			
			if (priceBttn != null)
				buyBttnConteiner.removeChild(priceBttn);
				
			bttnSettings['caption'] = Locale.__e(text, [price]);
			priceBttn = new Button(bttnSettings);
			buyBttnConteiner.addChild(priceBttn);
			layer.addChild(buyBttnConteiner);
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			buyBttnConteiner.x = (settings.width - priceBttn.width) / 2;
			buyBttnConteiner.y = settings.height - buyBttnConteiner.height - 25;
			
			if (App.isSocial('MX'))
			{
				var mixiLogo:Bitmap =   new Bitmap(Window.textures.mixieLogo);
				priceBttn.topLayer.addChild(mixiLogo);
				priceBttn.fitTextInWidth(priceBttn.width - (mixiLogo.width + 10));
				priceBttn.textLabel.width = priceBttn.textLabel.textWidth + 5;
				priceBttn.textLabel.x = (priceBttn.width - (priceBttn.textLabel.width + mixiLogo.width + 5)) / 2 + mixiLogo.width + 5;
				mixiLogo.x = priceBttn.textLabel.x - mixiLogo.width - 5 ;
				mixiLogo.y = (priceBttn.height - mixiLogo.height) / 2;
			}
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var sID:* in data)
				result.push({sID:sID, count:data[sID], order:action.iorder[sID]});
			
			result.sortOn('order');
			return result;
		}
		public override function contentChange():void 
		{
			
			for each(var _item:ActionItem in items)
			{
				container.removeChild(_item);
				_item = null;
			}
			items = [];
			var Xs:int = 0;
			var Ys:int = 65;
			container = new Sprite();
			
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var item:ActionItem = new ActionItem(settings.content[i], this);
				container.addChild(item);
				item.x = Xs;
				item.y += Ys - item.bgShape.height;
				items.push(item);
				Xs += item.bgShape.width + 5;
				if ((i + 1) % Math.ceil(settings.content.length/2) == 0)
				{
					Xs = 0;	
					Ys += container.height + 10;
				}
			}
			container.y = 85;
			container.x = (settings.width - container.width) / 2 + 17;
			bodyContainer.addChild(container);
		}
		
	}
}
	
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;

internal class ActionItem extends Sprite {
		
		public var count:uint;
		public var sID:uint;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var shadow:Shape;
		public var bgShape:Shape;
		public var title:TextField;
		
		public var window:*;
		private var preloader:Preloader = new Preloader();
		
		
		private var bonus:Boolean = false;
		
		private var sprite:LayerX;
		
		public function ActionItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			this.window = window;
			
			sprite = new LayerX();
			addChild(sprite);
			shadow = new Shape();
			sprite.addChild(shadow);
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			var type:String = App.data.storage[sID].type;
			var preview:String = App.data.storage[sID].preview;
			bgShape = new Shape();
			bgShape.graphics.beginFill(0xffffff, 0);
			bgShape.graphics.drawRect(0 , 0, 75, 100);
			bgShape.graphics.endFill();
			sprite.addChild(bgShape);
			Load.loading(Config.getIcon(type, preview), onIconLoad);
		}
	
		
		public function onIconLoad(data:Bitmap):void
		{
			
			bitmap.bitmapData = data.bitmapData;
			Size.size(bitmap, 70, 70);
			bitmap.smoothing = true;
			bitmap.x = (bgShape.width - bitmap.width) / 2;
			bitmap.y = bgShape.height - bitmap.height - 5;
			
			shadow.graphics.beginFill(0x8e5f3b, .75);
			shadow.graphics.drawEllipse(0, 0, bitmap.width, 20);
			shadow.graphics.endFill();
			shadow.x = (bgShape.width - shadow.width) / 2;
			shadow.y = bgShape.height - 6 - shadow.height / 2;
			
			var description:String = App.data.storage[sID].description;
			//if (sID == App.data.storage[App.user.worldID].techno[0]) {
				//description = Locale.__e('flash:1396445082768');
			//}
			sprite.tip = function():Object {
				return {
					title:App.data.storage[sID].title,
					text:description
				};
			}
			drawCount();
		}
		
		public function drawCount():void {
			var countText:TextField = Window.drawText('x' + String(count), {
				color:0xffffff,
				borderColor:0x603024,
				textAlign:"center",
				autoSize:"center",
				fontSize:32,
				textLeading:-6,
				multiline:true
			});
			countText.wordWrap = true;
			countText.x = (bgShape.width - countText.width) / 2;
			countText.y = bgShape.height;
			addChild(countText);
		}
	}