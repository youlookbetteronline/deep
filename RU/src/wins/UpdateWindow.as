package wins 
{
	import buttons.Button;
	import buttons.CheckboxButton;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import flash.utils.setInterval;
	/**
	 * ...
	 * @author ...
	 */
	public class UpdateWindow extends Window 
	{
		private var _descLabel:TextField
		private var _bttn:Button;
		private var _update:Object;
		private var _tellBttn:CheckboxButton;
		private var _image:Bitmap;
		private var _items:Array;
		private var _mask:Shape;
		private var _icon:Bitmap;
		private var _imageSprite:Sprite = new Sprite();
		private var _itemSprite:Sprite = new Sprite();
		private var _sprite:Sprite = new Sprite();
		private var _itemMask:Shape = new Shape();
		private var _canTell:Boolean = false;
		private var _extra:ExtraReward
		
		public function UpdateWindow(settings:Object=null) 
		{
			this._update = settings.news;
			if (settings == null) {
				settings = new Object();
			}
			initDesc();
			settings['hasPaginator'] 		= false;
			settings['background'] 			= 'paperBackingBig';
			settings['fontSize'] 			= 50;	
			settings['fontColor'] 			= 0xffffff;
			settings['height'] 				= 440 + _descLabel.height;
			settings['width'] 				= 520;
			settings['title'] 				= _update.title;
			settings['fontBorderColor'] 	= 0x6e411e;
			settings['borderColor'] 		= 0x6e411e;
			settings['shadowBorderColor']	= 0x6e411e;
			settings["hasBubbles"] 		= true;
			settings["bubblesCount"] 	= 14;
			settings["bubbleRightX"] 	= -660;
			settings["bubbleLeftX"] 	= 570;
			settings["bubblesSpeed"] 	= 5;
			super(settings);
			
			if (App.isSocial('DM', 'VK') && App.user.settings.hasOwnProperty('upd')) {
				var array:Array = App.user.settings.upd.split('_');
				if (!array[2] || array[2] == '0') _canTell = true;
			}
			
		}
		
		override public function drawBody():void 
		{
			drawRibbon();
			loadImage();
			drawIcon();
			drawItem();
			//drawDescription();
			if (_canTell)
			{
				drawExtra();
				drawTell();
			}
			drawBttn();
			build();
		}
		
		private function initDesc():void 
		{
			var desc:String = _update.description;
			
			_descLabel = Window.drawText(desc, {
				fontSize 	:26,
				color  		:0x6e411e,
				border		:false,
				textLeading	:-4,
				textAlign 	:"center",
				multiline 	:true,
				width   	:410,
				wrap		:true
		    });
		}
		
		private function drawExtra():void 
		{
			_extra = new ExtraReward(_update.reward);
			bodyContainer.addChild(_extra);
			_extra.x = settings.width - _extra.bg.width + 35;
			_extra.y = settings.height - _extra.height - 100;
		}
		
		override protected function drawRibbon():void 
		{
			var titleBackingBmap:Bitmap = backingShort(titleLabel.width + 50, 'actionRibbonBg', true);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -55;
			bodyContainer.addChild(titleBackingBmap);
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y + 16;
			
			bodyContainer.addChild(titleLabel);
		}
		
		private function drawIcon():void 
		{
			_mask = new Shape();
			_mask.graphics.beginFill(0x000000, 1);
			_mask.graphics.drawRoundRect(0, 0, 340, 205, 20, 20);
			_mask.graphics.endFill();
			_mask.cacheAsBitmap = true;
			_mask.filters = [new BlurFilter(10, 10, 2)];

			Load.loading(Config.getImageIcon('updates/pictures', _update.preview, 'jpg'), function(data:Bitmap):void 
			{
				_icon = new Bitmap(data.bitmapData);
				Size.size(_icon, 360, 240);
				_icon.smoothing = true;
				_icon.x = _mask.x + (_mask.width - _icon.width) / 2;
				_icon.y = _mask.y + (_mask.height - _icon.height) / 2;
				_icon.cacheAsBitmap = true;
				_imageSprite.addChild(_icon);
				_imageSprite.addChild(_mask);
				_icon.mask = _mask;
			});
		}
		
		private function drawItem():void 
		{
			_itemMask = new Shape();
			_itemMask.graphics.beginFill(0x000000, 1);
			_itemMask.graphics.drawRect(0, 0, settings.width + 300, settings.height - 100)
			_itemMask.graphics.endFill();
			
			
			_items = [];
			var items:Array = []
			var Y:int = 0
			for (var itm:* in _update.items)
			{
				if (App.data.storage[itm].type == 'Zones')
					continue;
				items.push(itm);
			}
			for (var i:int = 0; i < items.length; i++) 
			{
				var item:BubbleItem = new BubbleItem(items[i]);
				_itemSprite.addChild(item)
				if (i % 2 == 0)
				{
					item.x = -90;
					Y += 130;
				}
				else
					item.x = settings.width;
				item.y = Y;
				_items.push(item);
				
			}
			
			setInterval(moveItems, 1);
		}
		
		private function moveItems():void 
		{
			_itemSprite.y -= 1;
			if (_itemSprite.y < -_itemSprite.height - 210)
				_itemSprite.y = settings.height - 260;
		}
		/*
		private function drawDescription():void {
			
			var desc:String = _update.description;
			
			_descLabel = Window.drawText(desc, {
				fontSize 	:26,
				color  		:0x6e411e,
				border		:false,
				textLeading	:-4,
				textAlign 	:"center",
				multiline 	:true,
				width   	:settings.width - 120,
				wrap		:true
		    });
		    
		}*/
		
		private function loadImage():void {
			Load.loading(Config.getImageIcon('updates/images', _update.preview, 'jpg'), function(data:Bitmap):void 
			{
				_image = new Bitmap(data.bitmapData);
			});
		}
		
		private function drawTell():void 
		{
			_tellBttn = new CheckboxButton({
				fontSize			:26,
				fontSizeUnceked		:26,
				caption 			:true,
				brownBg				:true,
				multiline			:false,
				wordWrap			:false,
				captionChecked		:Locale.__e('flash:1396608121799'),
				captionUnchecked	:Locale.__e('flash:1396608121799'),
				checked				:CheckboxButton.UNCHECKED,
				fontColor			:0xffffff,
				fontBorderColor		:0x7e3e13,
				dY					:4
			});
			
		}
		
		private function drawBttn():void 
		{
			var bttnSettings:Object = {
			caption		:Locale.__e('flash:1382952380228'),
			fontColor	:0xffffff,
			width		:160,
			height		:60,
			fontSize	:25
			};
		
			bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
			bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
			bttnSettings['fontBorderColor'] = 0x7f3d0e;
			
			_bttn = new Button(bttnSettings);
			_bttn.addEventListener(MouseEvent.CLICK, onOpenEvent);
		}
		
		private function onOpenEvent(e:MouseEvent):void 
		{
			if (_bttn.mode == Button.DISABLED) {
				return;
			}
			if (_canTell && _tellBttn.checked == CheckboxButton.CHECKED)
			{
				if (_image != null) {
					_bttn.state = Button.DISABLED;
					WallPost.makePost(WallPost.UPDATE, {btm:_image});
				}
			}
			new ShopWindow( { section:100, page:0, glowUpdate:true, currentUpdate:_update.nid} ).show();
			close();
		}
		
		private function build():void
		{
			exit.x -= 20;
			_descLabel.x = (settings.width - _descLabel.width) / 2;
		    _descLabel.y = 280;
			
			_itemMask.x = (settings.width - _itemMask.width) / 2;
			_itemMask.y = (settings.height - _itemMask.height) / 2 - 20;
			
			_sprite.x = (settings.width - _mask.width) / 2;
			_sprite.y = 40;
			
			_itemSprite.x = -93;
			
			_imageSprite.x = (settings.width - _mask.width) / 2;
			_imageSprite.y = 60;
				
			if (_tellBttn)
			{
				_tellBttn.x = (settings.width - _tellBttn.width) / 2;
				_tellBttn.y = settings.height - 160;
			}
			
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - 77 - _bttn.height / 2;
			
		    bodyContainer.addChild(_imageSprite);
			
		    _sprite.addChild(_itemSprite);
			_itemMask.cacheAsBitmap = true;
			_itemMask.filters = [new BlurFilter(0,20,20)]
		    bodyContainer.addChild(_sprite);
			bodyContainer.addChild(_itemMask);
			_sprite.cacheAsBitmap = true;
			_sprite.mask = _itemMask;
			
		    bodyContainer.addChild(_descLabel);
		    bodyContainer.addChild(_bttn);
			
			if (_tellBttn)
				bodyContainer.addChild(_tellBttn);
			
		}
		
	}

}
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import wins.Window;

internal class BubbleItem extends Sprite
{
	private var _sID:uint;
	private var _background:Bitmap;
	private var _bitmap:Bitmap;
	
	private var _sprite:LayerX;
	
	public function BubbleItem(sID:int)
	{
		this._sID = sID;
		var type:String = App.data.storage[sID].type;
		var preview:String = App.data.storage[sID].preview;
		
		_sprite = new LayerX();
		addChild(_sprite);
		drawBg();
		Load.loading(Config.getIcon(type, preview), onIconLoad);
	}
	
	private function drawBg():void
	{
		_background = new Bitmap(Window.textures.bubbleBackingBig);
		Size.size(_background, 100, 100)
		_background.smoothing = true;
		_sprite.addChild(_background);
	}
	private function onIconLoad(data:Bitmap):void
	{
		_bitmap = new Bitmap(data.bitmapData);
		Size.size(_bitmap, _background.width * 0.75, _background.height * 0.75);
		_bitmap.smoothing = true;
		_bitmap.x = (_background.width - _bitmap.width) / 2;
		_bitmap.y = (_background.height - _bitmap.height) / 2;
		
		_sprite.tip = function():Object
		{
			return {title: App.data.storage[_sID].title, text: App.data.storage[_sID].description};
		}
		_sprite.addChildAt(_bitmap, 0);
	}
}

import core.Numbers;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.NewsWindow;
import wins.RewardList;
import wins.Window;
import wins.ExtraBonusList;

internal class ExtraReward extends Sprite
{
	public var extra:Object = new Object();
	public var bg:Bitmap;
	
	public function ExtraReward(reward:Object) 
	{
		for (var i:int = 1; i <= Numbers.countProps(reward.c);i++)
		{	
			extra[reward.m[i]] = reward.c[i];
		}
		bg = Window.backing(190, 125, 50, "tipUp");
		addChild(bg);
		bg.y += 80;
		
		drawTitle();
		drawReward();
	}
	
	private function drawTitle():void 
	{
		var title:TextField = Window.drawText(Locale.__e("flash:1428049916402"), {
			fontSize	:18,
			color		:0xffffff,
			borderColor	:0x005571,
			textAlign   :'center',
			multiline   :true,
			wrap        :true
		});
		title.width = bg.width - 50;
		title.x = 23;
		title.y = 95;
		
		addChild(title);
	}
	
	private function drawReward():void 
	{
		var reward:ExtraBonusList = new ExtraBonusList(extra, false);
		addChild(reward);
		reward.x = bg.x + (bg.width - reward.width) / 2 - 10;
		reward.y = bg.height - reward.height + 50;

	}
}