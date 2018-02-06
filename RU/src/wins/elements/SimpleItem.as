package wins.elements 
{
	import api.com.adobe.json.JSONDecoder;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import com.greensock.TweenLite;
	import core.Load;
	import Config;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import mx.core.BitmapAsset;
	import ui.Hints;
	import ui.UserInterface;
	import wins.ShopWindow;
	import wins.Window;
	
	/**
	 * ...
	 */
	public class SimpleItem extends Sprite
	{
		private var _dY:int = 0;
		private var _image:Bitmap;
		private var _needItem:int;
		private var _haveItem:int;
		protected var count:TextField;
		protected var background:Shape;
		protected var titleSprite:Sprite = new Sprite();
		protected var countSprite:Sprite = new Sprite();
		protected var imageSprite:LayerX;
		protected var findBttn:Button;
		protected var buyBttn:Button;
		protected var desc:TextField;
		protected var titleBg:Bitmap;
		protected var item:Object;
		
		protected var container:Sprite;
		
		public var settings:Object = {
			title:{
				hasTitle	:true,
				caption	 	:'',
				textSettings:{
					fontSize		:25,
					color			:0x451c00,
					borderSize		:0
				},
				dx			:0,
				dy			:0
				
			},
			bg:{
				hasBg		:true,
				dRadius		:0,
				dHeight		:0,
				dx			:0,
				dy			:0
			},
			count:{
				hasCount	:true,
				count		:null,
				need		:0,
				align		:'right',
				dx			:0,
				dy			:0
			},
			item:{
				hasIcon		:true,
				width		:130,
				height		:130,
				onClick		:null,
				dx			:0,
				dy			:0
			},
			bttns: {
				hasFindBttn	:true,
				hasBuyBttn	:true,
				dx			:0,
				dy			:0
			},
			window:null
		};
		
		public function SimpleItem(sID:Object,settings:Object = null) 
		{
			trace(this);
			if (settings.hasOwnProperty('bg') && !settings.bg.hasBg) this.settings.item.width = this.settings.item.height = 100;
			item = App.data.storage[sID];
			for (var subProperty:* in settings)
			{
				if (Numbers.countProps(settings[subProperty]) <= 0)
				{
					this.settings[subProperty] = settings[subProperty];
					continue;
				}
				for (var property:String in settings[subProperty]){
					this.settings[subProperty][property] = settings[subProperty][property];
				}
			}
			_needItem = this.settings.count.need
			_haveItem = App.user.stock.count(item.sID)
			
			create();
			build();
		}
		
		protected function create():void 
		{	
			drawBackground();
			drawImage();
			drawTitle();
			drawCount();
			drawBttn();
			setTips();
			setListeners();
			refreshItem();
		}
		
		protected function build():void 
		{	
			titleSprite.x = (this.WIDTH - titleSprite.width) / 2 + settings.title.dx;
			titleSprite.y = - titleSprite.height / 2 + settings.title.dy;
			countSprite.x = 0;
			countSprite.y = this.HEIGHT - countSprite.height + settings.count.dy;
			findBttn.x = (this.WIDTH - findBttn.width) / 2 + settings.bttns.dx;
			findBttn.y = this.HEIGHT + settings.bttns.dy;
			buyBttn.x = (this.WIDTH - buyBttn.width) / 2 + settings.bttns.dx - 2;
			buyBttn.y = (settings.bttns.hasFindBttn) ? findBttn.y + findBttn.height: this.HEIGHT + settings.bttns.dy;
			
			if (settings.bg.hasBg)			addChild(background);
			if (settings.item.hasIcon)		addChild(imageSprite);
			if (settings.title.hasTitle)	addChild(titleSprite);
			if (settings.count.hasCount)	addChild(countSprite);
			if (settings.bttns.hasFindBttn)	addChild(findBttn);
			if (settings.bttns.hasBuyBttn && item.mtype != 3 && item.mtype != 4 && item.mtype != 6 && item.mtype != 8)	addChild(buyBttn);
			//addChild(buyBttn);
		}
		
		
		protected function drawBackground():void
		{
			var radius:int = (settings.item.width + settings.bg.dRadius) / 2;
			background = new Shape();
			background.graphics.beginFill(0xf9d2ac, 1);
			background.graphics.drawCircle(0, 0, radius);
			background.graphics.endFill();
			background.x += background.width / 2 + settings.bg.dx;
			background.y += background.height / 2 + settings.bg.dy;
		}
		
		protected function drawImage():void
		{	
			imageSprite = new LayerX();
			_image = new Bitmap(new BitmapData(settings.item.width, settings.item.height));
			imageSprite.addChild(_image);
			Load.loading(Config.getIcon(item.type, item.preview), onImageLoad);
		}
		
		protected function onImageLoad(data:Bitmap):void{
			_image.bitmapData = data.bitmapData;
			if (settings.bg.hasBg)
				Size.size(_image, settings.item.width * .85, settings.item.height * .85)
			else
				Size.size(_image, settings.item.width, settings.item.height)
			_image.smoothing = true;
			_image.x = (this.WIDTH - _image.width) / 2;
			_image.y = (this.HEIGHT - _image.height) / 2;
		}
		
		protected function drawTitle():void
		{	var caption:String = (settings.title.caption != '') ? settings.title.caption : item.title;
			var size:Point = new Point(this.WIDTH, Math.min(this.HEIGHT * 0.4, 40));
			var title:TextField = Window.drawTextX(caption, size.x, size.y, 0, 0, titleSprite, settings.title.textSettings, 'up');
		}
		
		protected function drawCount():void 
		{
			var textSettings:Object = {
				fontSize		:28,
				color			:0xfd5454,
				borderColor		:0x451c00,
				textAlign		:settings.count.align
			}
			var size:Point = new Point(this.WIDTH, Math.min(this.HEIGHT * 0.25, 25));
			
			if (_needItem <= 0 || _haveItem >= _needItem)
				textSettings.color = 0xffffff;
			if (_needItem > 0)
				count = Window.drawTextX(String(_haveItem) + "/" + String(_needItem),this.WIDTH, this.HEIGHT * 0.25, 0, 0, countSprite, textSettings, 'up');
			else
				count = Window.drawTextX(String(_haveItem),size.x, size.y, 0, 0, countSprite, textSettings);
		}
		
		protected function drawBttn():void
		{
			var price:int = (item.hasOwnProperty('price')) ? Numbers.firstProp(item.price).val * (_needItem - _haveItem) : 0;
			var bttnBmd:BitmapData = Window.backingHorizontal(this.WIDTH, 'findBttn').bitmapData;
			var findBttnCaption:TextField = Window.drawText(Locale.__e("flash:1407231372860"), {
				fontSize	: 24,
				width		: this.WIDTH * 0.55,
				height		: 25,
				color		: 0xffffff,
				borderColor	: 0x3f6e03,
				wrap		: false,
				multiline	: false
			})
			bttnBmd.draw( Window.textures.findIcon, new Matrix(1, 0, 0, 1, (this.WIDTH - this.WIDTH * 0.15 - 22), 6));
			bttnBmd.draw(findBttnCaption, new Matrix(1, 0, 0, 1, this.WIDTH * 0.11, (bttnBmd.height - findBttnCaption.height) / 2));
			findBttn = new ImageButton(bttnBmd);
			buyBttn = new MoneyButton({
				caption			: Locale.__e('flash:1382952379751'),
				width			: this.WIDTH + 2,
				height			: 44,
				fontSize		: Math.min(this.WIDTH * 0.24, 24),
				fontCountSize	: Math.min(this.WIDTH * 0.20, 20),
				radius			: 16,
				countText		: price,
				multiline		: false,
				wrap			: false
			});
		}
		
		protected function setTips():void
		{
			imageSprite.tip = function():Object {return {title: item.title, text: item.description}}
			findBttn.tip = function():Object{return {text: Locale.__e('flash:1425981432950')}}
			buyBttn.tip = function():Object{return {text: Locale.__e('flash:1382952379970')}}
		}
		
		protected function setListeners():void 
		{
			findBttn.onMouseUp = onFindEvent;	
			buyBttn.onMouseUp =  onBuyEvent;
			if (settings.item.onClick)
				this.addEventListener(MouseEvent.MOUSE_UP, settings.item.onClick)
		}
		
		protected function onBuyEvent(e:*):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) 
				return;
			else
				e.currentTarget.state = Button.DISABLED;
			App.user.stock.buy(item.sID, (_needItem - _haveItem), onBuyComplete);
		}
		
		protected function onFindEvent(e:*):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) 
				return;
			else
				e.currentTarget.state = Button.DISABLED;
			ShopWindow.findMaterialSource(item.sID, settings.window);
			e.currentTarget.state = Button.NORMAL;
		}
		
		private function onBuyComplete(price:Object):void 
		{
			for (var sID:* in price) {
				var pnt:Point = App.self.tipsContainer.localToGlobal(new Point(buyBttn.mouseX, buyBttn.mouseY));
				pnt.x += this.x + buyBttn.x; 
				pnt.y += this.y + buyBttn.y - 30; 
				Hints.minus(sID, price[sID], pnt, false);
				break;
			}
			_haveItem = App.user.stock.count(item.sID);
			refreshItem();
		}
		
		private function refreshItem():void 
		{
			_haveItem = App.user.stock.count(item.sID);
			//_haveItem = 99999;
			
			if (_needItem <= 0 || _haveItem >= _needItem)
				count.textColor = 0xffffff;
			else
				count.textColor = 0xfd5454;
			if (_needItem > 0)
				count.text = (String(_haveItem) + "/" + String(_needItem));
			else
				count.text = (String(_haveItem));
			if (_needItem > 0 && _haveItem >= _needItem)
			{
				findBttn.visible = false;
				buyBttn.visible = false;
			}	
		}
		
		public function dispose():void
		{
			if (settings.item.onClick)
				this.removeEventListener(MouseEvent.MOUSE_UP, settings.item.onClick)
			if (findBttn)
				findBttn.dispose();
			if (buyBttn)
				buyBttn.dispose();
		}
		
		public function get WIDTH():int { return (settings.bg.hasBg) ? background.width : settings.item.width; }
		public function get HEIGHT():int { return (settings.bg.hasBg) ? background.height : settings.item.height; }
	}

}