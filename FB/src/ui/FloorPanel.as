package ui 
{
	import buttons.Button;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import models.CraftfloorsModel;
	import units.Craftfloors;
	import wins.CraftfloorsWindow;
	import wins.Window;
	
	/**
	 * ...
	 * @author ...
	 */
	public class FloorPanel extends LayerX 
	{
		
		private var _window:CraftfloorsWindow;
		private var _model:CraftfloorsModel;
		
		private var _settings:Object = {
			width		:395,
			height		:275
		};
		
		private var _background:Bitmap = new Bitmap();
		private var _title:TextField;
		private var _progressBar:wins.ProgressBar;
		private var _progressBacking:Bitmap;
		private var _progressText:TextField;
		private var _itemsContainer:Sprite = new Sprite();
		private var _progressContainer:Sprite = new Sprite();
		private var _bttn:Button;
		private var _items:Array = [];
		private var _target:Craftfloors;
		private var _content:Array;
		
		public function FloorPanel(window:CraftfloorsWindow, model:CraftfloorsModel)
		{
			this._window = window;
			this._model = model;
			this._target = window.settings.target
			drawBackground();
			drawTitle();
			drawProgress();
			contentChange();
			
			build();
		}
		
		private function parseContent():Array{
			var msimple:Object = _target.info.levels[_model.floor]['throw'].msimple[_model.toThrow['msimple']];
			var mhard:Object = _target.info.levels[_model.floor]['throw'].mhard[_model.toThrow['mhard']];
			var mdonate:Object = _target.info.levels[_model.floor]['throw'].mdonate[_model.toThrow['mdonate']];
			
			msimple.type = 'msimple';
			mhard.type  = 'mhard';
			mdonate.type  = 'mdonate';
			
			return [msimple, mhard, mdonate];
			
		}
		
		private function drawBackground():void 
		{
			_background = Window.backing4(WIDTH, HEIGHT, 0, "yellowBackingTL", "yellowBackingTR", "yellowBackingBL", "yellowBackingBR");
			addChild(_background);
		}
		private function drawTitle():void 
		{
			_title = Window.drawText(Locale.__e('flash:1382952380004', [_model.floor, _model.totalFloor]),{
				fontSize		:32,
				color			:0xffe558,
				borderColor		:0x6e411e,
				borderSize		:3,
				textAlign		:'center',
				width			:300,
				multiline		:true,
				wrap			:true
			});
			
			_title.x = (WIDTH - _title.width) / 2;
			_title.y = 18;
			addChild(_title);
		}
		
		public function contentChange():void 
		{
			drawItems();
			progress();
			drawBttn();
		}
		private function drawItems():void 
		{
			_content = parseContent();
			for each(var item:FloorItem in _items){
				item.parent.removeChild(item);
				item = null;
			}
			_items = [];
			
			var X:int = 0;
			for (var i:int = 0; i < _content.length; i++) 
			{
				item = new FloorItem({
					item:	_content[i],
					throwCallback:_model.throwCallback,
					contentChange:contentChange,
					model:_model,
					target:_target
				});
				item.x = X;
				
				_itemsContainer.addChild(item);
				_items.push(item);
				
				X += item.WIDTH + 14;
			}
		}
		private function drawProgress():void 
		{
			_progressBacking = Window.backingShort(320, "newBrownBacking");
				
			var barSettings:Object = {
				typeLine		:'newBlueSlider',
				width			:318,
				win				:this.parent
			};
			
			_progressBar = new wins.ProgressBar(barSettings);
			_progressBar.start();
			_progressBar.timer.text = '';
			
			
			_progressText = Window.drawText('', {
				fontSize	:25,
				color		:0xffffff,
				borderColor	:0x004762,
				textAlign	:"center",
				borderSize:2,
				multiline:true,
				wrap:true
			});
			_progressText.width = 100;
			
			
			
			/*_progressContainer.x = (settings.width - _progressContainer.width) / 2;
			_progressContainer.y = _slotsContainer.y + 170;
			bodyContainer.addChild(_progressContainer);*/
			
			
		}
		
		private function progress():void 
		{	
			var prog:Number = _model.kicks / _target.info.levels[_model.floor].req.kicks;
			if (prog > 1)
				prog = 1;
			_progressBar.progress = prog;
			/*if (_progressBar.progress > 1)
				_progressBar.progress = 1;*/
			_progressText.text = String(_model.kicks) + '/' + String(_target.info.levels[_model.floor].req.kicks);
		}
		
		private function drawBttn():void 
		{
			if (_bttn && _bttn.parent)
				_bttn.parent.removeChild(_bttn);
				
			var bttnSettings:Object = {
			caption		:Locale.__e('flash:1396963489306'),
			fontColor	:0xffffff,
			width		:122,
			height		:43,
			fontSize	:28
			};
		
			bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
			bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
			bttnSettings['fontBorderColor'] = 0x7f3d0e;
			
			_bttn = new Button(bttnSettings);
			_bttn.addEventListener(MouseEvent.CLICK, onGrowEvent);
			
			if (_model.kicks < _target.info.levels[_model.floor].req.kicks)
				_bttn.state = Button.DISABLED;
			
			_bttn.x = (WIDTH - _bttn.width) / 2;
			_bttn.y = HEIGHT - _bttn.height - 4;
			addChild(_bttn);
		}
		
		private function onGrowEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
			{
				if (_model.kicks < _target.info.levels[_model.floor].req.kicks)
				{
					Hints.text(Locale.__e('flash:1510137421605'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
					return;
				}
				return;
				
			}
			e.currentTarget.state = Button.DISABLED;
			_model.growCallback();
		}
		
		private function build():void 
		{
			_itemsContainer.y = 85;
			_itemsContainer.x = (WIDTH - _itemsContainer.width) / 2;
			
			_progressBar.x = _progressBacking.x - 17;
			_progressBar.y = _progressBacking.y - 13;
			
			_progressText.x = _progressBacking.x + (_progressBacking.width - _progressText.width) / 2;
			_progressText.y = _progressBacking.y + (_progressBacking.height - _progressText.height) / 2 + 4;
			
			
			
			
			_progressContainer.addChild(_progressBacking);
			_progressContainer.addChild(_progressBar);
			_progressContainer.addChild(_progressText);
			
			_progressContainer.x = (WIDTH - _progressContainer.width) / 2;
			_progressContainer.y = 202;
			addChild(_progressContainer);
			
			addChild(_itemsContainer)
			
		}
		
		public function get WIDTH():int{return _settings.width;}
		public function get HEIGHT():int{return _settings.height;}
			
		}

}
import buttons.Button;
import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.ShopWindow;
import wins.Window;
import wins.elements.PriceLabel;

internal class FloorItem extends LayerX
{
	private var _info:Object;
	private var _item:Object;
	private var _background:Bitmap;
	private var _icon:Bitmap;
	private var _title:TextField;
	private var _count:TextField;
	private var _price:PriceLabel;
	private var _bttn:Button;
	private var _settings:Object = {
		width		:95,
		height		:95
	};
	public function FloorItem(settings:Object)
	{
		for (var property:* in settings) {
			_settings[property] = settings[property];
		}
		
		this._info = settings.item;
		this._item = App.data.storage[_info.m];
		drawBackground();
		drawTitle();
		drawCount();
		drawPrice();
		drawIcon();
		drawBttn();
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
		_background = Window.backing2(95, 95, 39, 'yellowWhiteBackingTop', 'yellowWhiteBackingBot');
	}
	
	private function drawTitle():void 
	{
		_title = Window.drawText(_item.title + '\n' + '+' + _info.k, {
			fontSize		:20,
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
			Size.size(_icon, 55, 55)
			_icon.smoothing = true;
			_icon.x = (_background.width - _icon.width) / 2;
			_icon.y = (_background.height - _icon.height) / 2;
			addChild(_icon);
			
			_title.x = _background.x + (_background.width - _title.width) / 2;
			_title.y = _background.y - _title.textHeight + 25;
			addChild(_title);
			
			_count.x = WIDTH - _count.width - 10;
			_count.y = HEIGHT - 44;
			addChild(_count);
			
			_price.x = WIDTH - _price.width - 8;
			_price.y = HEIGHT - 46;
			addChild(_price);
		})
	}
	
	private function drawCount():void 
	{
		_count = Window.drawText('x' + _info.c,{
			fontSize		:22,
			color			:0xffffff,
			borderColor		:0x6e411e,
			borderSize		:3,
			textAlign		:'right',
			width			:50
		});
		if (_info.type == 'mdonate')
			_count.visible = false;
		
	}
	
	private function drawPrice():void 
	{	
		_price = new PriceLabel({'3':Numbers.firstProp(App.data.storage[_info.m].price).val}, false, false, {
			textColor:	0xffffff,
			borderColor:0x6e411e
		});
		if (_info.type != 'mdonate')
			_price.visible = false;
	}
	
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption		:Locale.__e('flash:1467807291800'),
			fontColor	:0xffffff,
			width		:83,
			height		:32,
			fontSize	:20
		};
		
		
		if(_info.type == 'mdonate'){
			bttnSettings['bgColor'] = [0x65b8ef, 0x567dcf];
			bttnSettings['bevelColor'] = [0xcce8fa, 0x3b62c2];
			bttnSettings['fontBorderColor'] = 0x2b4a84;
			_settings["bttnCallback"] = throwEvent;
		}else if (App.user.stock.check(_info.m, _info.c)){
			bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
			bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
			bttnSettings['fontBorderColor'] = 0x6e411e;
			_settings["bttnCallback"] = throwEvent;
		}else{
			bttnSettings["bgColor"] = [0xc7e314, 0x82b730];
			bttnSettings["borderColor"] = [0xeafed1, 0x577c2d];
			bttnSettings["bevelColor"] = [0xeafed1, 0x577c2d];
			bttnSettings["fontColor"] = 0xffffff;			
			bttnSettings["fontBorderColor"] = 0x4b6a09;
			bttnSettings["caption"] = Locale.__e("flash:1407231372860");
			_settings["bttnCallback"] = findMaterial;
			}
		
			
		_bttn = new Button(bttnSettings);
		_bttn.addEventListener(MouseEvent.CLICK, _settings.bttnCallback);
		
		if (_settings.model.kicks >= _settings.target.info.levels[_settings.model.floor].req.kicks)
			_bttn.state = Button.DISABLED
	}
	
	private function throwEvent(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED)
			return;
			
		if (_info.type == 'mdonate')
		{
			if (!App.user.stock.check(Stock.FANT, _info.c))
				return;
			else
				_settings.throwCallback(_info.type, _settings.contentChange, e.currentTarget);
		}
		else
		{
			_settings.throwCallback(_info.type, _settings.contentChange, e.currentTarget);
		}
		
		
	}
	
	private function findMaterial(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED)
			return;
		Window.closeAll();
		ShopWindow.findMaterialSource(_info.m);
	}
	
	private function build():void 
	{
		_title.x = _background.x + (_background.width - _title.width) / 2;
		_title.y = _background.y - _title.textHeight + 25;
		
		_count.x = WIDTH - _count.width - 10;
		_count.y = HEIGHT - 44;
		
		_price.x = WIDTH - _price.width - 8;
		_price.y = HEIGHT - 46;
		
		_bttn.x = (WIDTH - _bttn.width) / 2;
		_bttn.y = HEIGHT - _bttn.height / 2 - 5;
		
		
		addChild(_background);
		if (_icon)
		{
			_icon.x = (_background.width - _icon.width) / 2;
			_icon.y = (_background.height - _icon.height) / 2;
			addChild(_icon);
		}
		addChild(_title);
		addChild(_count);
		addChild(_price);
		addChild(_bttn);
		
		
	}
	
	public function get WIDTH():int { return _settings.width; }
	public function get HEIGHT():int { return _settings.height; }
}