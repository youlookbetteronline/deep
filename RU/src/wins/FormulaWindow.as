package wins 
{
	import buttons.Button;
	import core.Numbers;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import models.CraftfloorsModel;
	import ui.Hints;
	import units.Craftfloors;
	/**
	 * ...
	 * @author ...
	 */
	public class FormulaWindow extends Window 
	{
		private var _fID:int;
		private var _formula:Object;
		private var _outID:int;
		private var _out:Object;
		private var _model:CraftfloorsModel;
		private var _bttn:Button;
		private var _content:Array;
		private var _items:Vector.<Component> = new Vector.<Component>;
		private var _itemsContainer:Sprite = new Sprite();
		private var _signIco:Bitmap;
		private var _icons:Vector.<Bitmap> = new Vector.<Bitmap>
		private var _item:Component
		private var _resultItem:Component;
		private var _target:Craftfloors;
		private var _window:CraftfloorsWindow;
		
		public function FormulaWindow(settings:Object=null) 
		{
			this._fID = settings.fID;
			this._formula = App.data.crafting[_fID];
			this._outID = _formula.out;
			this._out = App.data.storage[_outID];
			this._model = settings.model;
			this._target = settings.target;
			this._window = settings.window;
			_content = Numbers.objectToArraySidCount(_formula.items)
			settings = settingsInit(settings);
			super(settings);
			
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			settings["width"]				= 170 + _content.length * 145;
			settings["height"] 				= App.user.stock.checkAll(_formula.items)?265:310;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			settings['exitTexture'] 		= 'yellowClose';
			settings['fontColor'] 			= 0x6e411e;
			settings['fontBorderColor'] 	= 0xfdf3cb;
			settings['fontBorderSize']		= 4;
			settings['fontSize'] 			= 40;
			settings['title'] 				= _out.title
			
			return settings;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = Window.backing4(settings.width, settings.height, 0, "yellowBackingTL", "yellowBackingTR", "yellowBackingBL", "yellowBackingBR");
			if (background && background.parent)
				background.parent.removeChild(background);
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			contentChange();
			build();
		}
		
		override public function contentChange():void 
		{
			clearContent();
			var X:int = 0;
			for (var i:int = 0; i < _content.length; i++) 
			{
				_item = new Component(_content[i], _formula, contentChange, false, _window, this);
				
				_item.x = X;
				
				_itemsContainer.addChild(_item);
				_items.push(_item);
				
				X += _item.WIDTH + 35;
				
				if (i < _content.length)
				{
					if (i == _content.length - 1)
						_signIco = new Bitmap(Window.textures.equalsIcon);
					else	
						_signIco = new Bitmap(Window.textures.plusIcon);
						
					_signIco.x = _item.x + _item.width + 4;
					_signIco.y = _item.y + (_item.HEIGHT - _signIco.height) / 2;
					_itemsContainer.addChild(_signIco);
					_icons.push(_signIco);
				}
				
			}
			var _resObj:Object = {};
			_resObj[_outID] = 1
			_resultItem = new Component(_resObj, _formula, null, true, _window, this)
			_resultItem.x = X + 5;
			_itemsContainer.addChild(_resultItem);
			_items.push(_resultItem);
			
			
			drawBttn();
		}
		
		private function drawBttn():void 
		{
			if (_bttn && _bttn.parent)
				_bttn.parent.removeChild(_bttn);
			var bttnSettings:Object = {
				caption			:Locale.__e('flash:1382952380036'),
				fontColor		:0xffffff,
				width			:130,
				height			:48,
				fontSize		:30,
				bgColor			:[0xfed031, 0xf8ac1b],
				bevelColor		:[0xf7fe9a, 0xcb6b1e],
				fontBorderColor	:0x7f3d0e
			};
			_bttn = new Button(bttnSettings);
			_bttn.addEventListener(MouseEvent.CLICK, onCraftingEvent);
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - 65;
			
			bodyContainer.addChild(_bttn);
			
			
			if (!App.user.stock.checkAll(_formula.items))
				_bttn.state = Button.DISABLED;
		}
		
		private function onCraftingEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
			{
				Hints.text(Locale.__e('flash:1510137421605'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
				return;
			}
			afterCraftClose();
			_model.craftingCallback(_fID, _target.click);			
		}
		
		public function afterCraftClose(e:MouseEvent = null):void 
		{
			super.close(e);
		}
		
		override public function close(e:MouseEvent = null):void 
		{
			super.close(e);
			_target.click();
		}
		
		private function build():void 
		{
			titleLabel.y += 35;
			exit.y += 10;
			exit.x -= 10;
			
			_itemsContainer.x = (settings.width - _itemsContainer.width) / 2;
			_itemsContainer.y = 55
			
			bodyContainer.addChild(_itemsContainer);
		}
		
		private function clearContent():void 
		{
			for each(var itm:Component in _items){
				itm.parent.removeChild(itm);
				itm = null;
			}
			
			for each(_signIco in _icons){
				_signIco.parent.removeChild(_signIco);
				_signIco = null;
			}
			
			_items = new Vector.<Component>;
			_icons = new Vector.<Bitmap>
		}
		
	}

}
import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Numbers;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import wins.FormulaWindow;
import wins.Window;
import wins.CraftfloorsWindow;
import wins.ShopWindow;
import flash.text.TextField;

internal class Component extends LayerX
{
	private var _sID:int;									
	private var _item:Object;
	private var _formula:Object;
	private var _callback:Function							//callback for start crafting 
	private var _background:Bitmap;
	private var _icon:Bitmap;
	private var _title:TextField;
	private var _count:int;
	private var _countText:TextField;
	private var _searchBttn:Button;
	private var _buyBttn:Button;
	private var _result:Boolean;
	private var _clock:Bitmap;
	private var _clockContainer:Sprite = new Sprite();
	private var _clockText:TextField;
	private var _window:CraftfloorsWindow;
	private var _formulaWindow:FormulaWindow;
	private var _settings:Object = {
		width		:110,
		height		:110
	};
	public function Component(item:Object, formula:Object, callback:Function, result:Boolean = false, window:CraftfloorsWindow = null, formulaWindow:FormulaWindow = null)
	{
		this._sID = Numbers.firstProp(item).key;
		this._count = Numbers.firstProp(item).val;
		this._item = App.data.storage[_sID];
		this._callback = callback;
		this._result = result;
		this._formula = formula;
		this._window = window;
		this._formulaWindow = formulaWindow;
		
		drawBackground();
		drawTitle();
		drawCount();
		drawIcon();
		drawBttn();
		drawTimeFormula();
		build();
		
		
		this.tip = function():Object{
			return{
				title	:_item.title,	
				text	:_item.description	
			}
		}
	}
	
	private function drawBackground():void 
	{
		if (_result)
			_background = Window.backing2(WIDTH, HEIGHT, 39, 'brownYellowBackingTop', 'brownYellowBackingBot');
		else
			_background = Window.backing2(WIDTH, HEIGHT, 39, 'yellowWhiteBackingTop', 'yellowWhiteBackingBot');
	}
	
	private function drawTitle():void 
	{
		_title = Window.drawText(_item.title/* + '\n шланг'*/, {
			fontSize		:22,
			color			:0xfffffe,
			borderColor		:0x6e411e,
			borderSize		:3,
			textAlign		:'center',
			width			:WIDTH,
			multiline		:true,
			wrap			:true
		});
		
	}
	
	private function drawIcon():void 
	{
		Load.loading(Config.getIcon(_item.type, _item.preview), function(data:Bitmap):void{
			_icon = new Bitmap(data.bitmapData);
			Size.size(_icon, 60, 60)
			_icon.smoothing = true;
			_icon.x = (_background.width - _icon.width) / 2;
			_icon.y = (_background.height - _icon.height) / 2;
			addChild(_icon);

			if (_result)
				return;
			_countText.x = WIDTH - _countText.width - 10;
			_countText.y = HEIGHT - 44;
			addChild(_countText);
			
		})
	}
	
	private function drawCount():void 
	{
		if (_result)
			return;
		_countText = Window.drawText(_count + '/' + App.user.stock.count(_sID) , {
			fontSize		:22,
			color			:0xffffff,
			borderColor		:0x6e411e,
			borderSize		:3,
			textAlign		:'right',
			width			:50
		});
	}
		
	private function drawBttn():void 
	{
		if (_result || App.user.stock.check(_sID,_count))
			return;
		_searchBttn = new Button({
			width			:80,
			height			:33,
			fontSize		:20,
			radius			:16,
			bgColor 		:[0xc7e314, 0x82b730],
			borderColor  	:[0xeafed1, 0x577c2d],
			bevelColor  	:[0xeafed1, 0x577c2d],
			fontColor 		:0xffffff,	
			fontBorderColor :0x4b6a09,
			caption 		:Locale.__e("flash:1407231372860")
		})
		
		_buyBttn = new MoneyButton({
			caption			: Locale.__e('flash:1382952379751') + '\n',
			width			: 95,
			height			: 33,
			fontSize		: 16,
			fontCountSize	: 18,
			radius			: 16,
			countText		: Numbers.firstProp(_item.price).val * (_count - App.user.stock.count(_sID)),
			multiline		: false,
			wrap			: false,
			iconScale		: 0.4,
			notChangePos	: true,
			iconDY			:2,
			bevelColor		:[0xcce8fa, 0x3b62c2],
			bgColor			:[0x65b7ef, 0x567ed0],
			countDY			:0
		})
		
		_searchBttn.addEventListener(MouseEvent.CLICK, onSearchEvent)
		_buyBttn.addEventListener(MouseEvent.CLICK, buyEvent)
		
		_searchBttn.x = (WIDTH - _searchBttn.width) / 2;
		_searchBttn.y = HEIGHT
		
		_buyBttn.x = (WIDTH - _buyBttn.width) / 2;
		_buyBttn.y = _searchBttn.y + _searchBttn.height + 8
		
		addChild(_searchBttn);
		addChild(_buyBttn);
	}
	
	
	
	private function onSearchEvent(e:MouseEvent):void 
	{
		_formulaWindow.afterCraftClose(e);
		ShopWindow.findMaterialSource(_sID);
	}
	
	private function buyEvent(e:MouseEvent):void 
	{
		var def:int = _count - App.user.stock.count(_sID);
		e.currentTarget.state = Button.DISABLED;
		App.user.stock.buy(_sID, def, onBuyEvent);
	}
	
	private function onBuyEvent(price:Object):void 
	{
		_callback();
	}
	
	private function drawTimeFormula():void 
	{
		if (!_result)
			return
		_clock = new Bitmap(Window.textures.yellowClock);
		Size.size(_clock, 29, 29);
		_clock.smoothing = true;
		_clock.filters = [new GlowFilter(0xffffff, 1, 6, 6, 6)]
		_clockContainer.addChild(_clock)
		
		_clockText = Window.drawText(TimeConverter.timeToCuts(_formula.time), {
			fontSize		:24,
			color			:0xfffffe,
			borderColor		:0x6e411e,
			borderSize		:3,
			textAlign		:'left',
			multiline		:true,
			wrap			:true
		})
		_clockText.width = _clockText.textWidth + 2;
		_clockText.x = _clock.x + _clock.width + 7;
		_clockText.y = _clock.y + (_clock.height - _clockText.height) / 2;
		_clockContainer.addChild(_clockText);
		//Window.showBorders(_clockContainer);
	}
	
	private function build():void 
	{
		_title.x = _background.x + (_background.width - _title.width) / 2;
		_title.y = _background.y - _title.textHeight / 2;
		if (!_result)
		{
			_countText.x = WIDTH - _countText.width - 10;
			_countText.y = HEIGHT - 44;
		}
		
		addChild(_background);
		if (_icon)
		{
			_icon.x = (_background.width - _icon.width) / 2;
			_icon.y = (_background.height - _icon.height) / 2;
			addChild(_icon);
		}
		addChild(_title);
		if (!_result)
			addChild(_countText);
		if (_result)
		{
			_clockContainer.x = (WIDTH - _clockContainer.width) / 2;
			_clockContainer.y = HEIGHT + 10;
			addChild(_clockContainer);
		}
		
	}
	
	public function get WIDTH():int { return _settings.width; }
	public function get HEIGHT():int { return _settings.height; }
}