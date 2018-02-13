package wins 
{
	import com.adobe.images.BitString;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class BonusLackWindow extends Window 
	{
		private var _persImage:Bitmap;
		private var _description:TextField;
		private var _itemsContainer:Sprite = new Sprite();
		private var _items:Vector.<BubbleItem>;
		private var _item:BubbleItem;
		public function BonusLackWindow(settings:Object=null) 
		{
			settings = settingsInit(settings);
			super(settings);
			
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			settings["width"]				= 680;
			settings["height"] 				= 355;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			settings['exitTexture'] 		= 'blueClose';
			settings['fontColor'] 			= 0xffffff;
			settings['fontBorderColor'] 	= 0x1f5167;
			settings['fontBorderSize']		= 3;
			settings['fontSize'] 			= 40;
			settings['title'] 				= Locale.__e('flash:1429693439093');
			
			return settings;
		}
		
		private function parseContent():void
		{
			settings.content = Numbers.objectToArraySidCount(settings.bonus);
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing4(settings.width, settings.height, 160, 'blueBackingTL', 'blueBackingTR', 'blueBackingBL', 'blueBackingBR');
			layer.addChild(background);	
		}
		
		override public function drawBody():void 
		{
			this.x += 40;
			fader.x -= 40;
			
			drawPersonage();
			drawDescription();
			contentChange();
			build();
			
		}
		
		private function drawPersonage():void 
		{
			Load.loading(Config.getImageIcon('content', 'JanePresent'), function(data:Bitmap):void{
				_persImage = new Bitmap(data.bitmapData);
				_persImage.y = -15;
				_persImage.x = -115;
				bodyContainer.addChild(_persImage);
			})
		}
		
		private function drawDescription():void 
		{
			_description = Window.drawText(Locale.__e('flash:1518449154191'), {
				fontSize		:30,
				color			:0xffe558,
				borderColor		:0x174052,
				borderSize		:3,
				textAlign		:'center',
				width			:525,
				multiline		:true,
				wrap			:true
			})
		}
		
		override public function contentChange():void 
		{
			parseContent();
			for each(var _itm:BubbleItem in _items){
				_itm.parent.removeChild(_itm);
				_itm = null;
			}
			_items = new Vector.<BubbleItem>;
			
			var currentX:int = 0;
			for (var i:int = 0; i < settings.content.length; i++)
			{
				_item = new BubbleItem({
					item:	settings.content[i]
				});
				_item.x = currentX;
				_itemsContainer.addChild(_item);
				_items.push(_item);
				currentX += _item.WIDTH + 15;
			}
		}
		
		private function build():void 
		{
			titleLabel.y += 40;
			exit.y += 10;
			exit.x -= 15;
			
			_description.x = (settings.width - _description.width) / 2;
			_description.y = 52;
			
			_itemsContainer.x = (settings.width - _itemsContainer.width) / 2;
			_itemsContainer.y = 150;
			
			bodyContainer.addChild(_description);
			bodyContainer.addChild(_itemsContainer)
		}
	}
}
import core.Numbers;
import flash.display.Bitmap;
import flash.text.TextField;
import wins.Window;

internal class BubbleItem extends LayerX
{
	private var _settings:Object = {
		width:105,
		height:105
	}
	private var _sid:int;
	private var _count:int;
	private var _item:Object;
	private var _background:Bitmap;
	private var _countText:TextField
	private var _titleText:TextField
	public function BubbleItem(settings:Object)
	{
		for (var property:* in settings)
			_settings[property] = settings[property];
		this._sid = Numbers.firstProp(_settings.item).key;	
		this._count = Numbers.firstProp(_settings.item).val;	
		this._item = App.data.storage[_sid];
		drawBackground();
		drawIcon();
		drawTitle();
		drawCount();
		
		build();
	}
	
	private function drawBackground():void 
	{
		_background = new Bitmap(Window.textures.circleBlueBacking)
		addChild(_background);
	}
	
	private function drawIcon():void 
	{
		
	}
	
	private function drawTitle():void 
	{
		var text:String = _item.title
		var labelArray:Array = text.split(' ');
		var label:String = '';
		for (var i:int = 0; i < labelArray.length; i++)
		{
			label += labelArray[i];
			if (i != labelArray.length - 1)
			label+='\n'
		}
		
		_titleText = Window.drawText(label,{
			color			:0xffffff,
			borderColor		:0x1f5167,
			borderSize		:3,
			fontSize		:26,
			width			:100,
			height			:50,/*
			multiline		:true,
			wrap			:true,*/
			textAlign		:'center',
			autoSize		:'center',
			textLeading		:-14
		})
	}
	
	private function drawCount():void 
	{
		_countText = Window.drawText('x '+String(_count),{
			color			:0xffffff,
			borderColor		:0x1f5167,
			borderSize		:3,
			fontSize		:34,
			width			:90,
			textAlign		:'center'
		})
	}
	
	private function build():void 
	{
		addChild(_background);
		
		_countText.x = (WIDTH - _countText.width) / 2;
		_countText.y = HEIGHT;
		
		addChild(_countText);
		
		_titleText.x = (WIDTH - _countText.width) / 2;
		_titleText.y = -30;
		
		addChild(_titleText);
	}
	
	public function get WIDTH():int { return _settings.width; }
	public function get HEIGHT():int { return _settings.height; }
}