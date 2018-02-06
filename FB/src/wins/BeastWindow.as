package wins 
{
	import api.com.adobe.json.JSONDecoder;
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import models.BeastModel;
	import ui.Hints;
	/**
	 * ...
	 * @author ...
	 */
	public class BeastWindow extends Window 
	{
		private var _model:BeastModel;
		private var _info:Object;
		
		private var _items:Array = [];
		private var _itemsContainer:Sprite = new Sprite();
		private var _description:TextField;
		private var _timerCont:LayerX;
		private var _timeToDie:TextField;
		private var _timeToGift:TextField;
		private var _bttn:Button;
		private var _renameBttn:ImageButton
		
		public function BeastWindow(settings:Object=null) 
		{
			_model = settings.model;
			_info = settings.target.info
			settings = settingsInit(settings);
			
			super(settings);
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}

			settings["width"]				= 545;
			settings["height"] 				= 420;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= true;
			settings["hasArrows"]			= false;
			settings['exitTexture'] 		= 'closeBttnMetal';
			settings['background	'] 		= 'capsuleWindowBacking';
			settings['fontColor'] 			= 0xffffff;
			settings['fontBorderColor'] 	= 0x116011;
			settings['borderColor'] 		= 0x116011;
			settings['shadowBorderColor']	= 0x116011;
			settings['fontSize'] 			= 50;
			settings['title'] 				= settings.target.info.title;
			
			return settings;
		}
		
		private function parseContent():Array{
			var simple:Object = _info['throw'].simple[_model.toThrow.simple]
			var complex:Object = _info['throw'].complex[_model.toThrow.complex]
			var donate:Object = _info['throw'].donate[_model.toThrow.donate]
			
			simple.type = 'simple';
			complex.type  = 'complex';
			donate.type  = 'donate';
			
			return [simple, complex, donate];
			
		}	
		override public function drawBody():void 
		{
			drawRibbon();
			drawTimer();
			drawDescription();
			contentChange();
			drawBttn();
			drawRenameBttn();
			build();
		}
		
		private function drawTimer():void 
		{
			_timerCont = new LayerX();
			var format:Object = {
				color		:0xffdf34,
				borderColor	:0x451c00,
				textAlign	:'left',
				fontSize	:34,
				borderSize	:2,
				autoSize	:'left'
			};
			var whiteFont:TextFormat = new TextFormat();
			whiteFont.color = 0xffffff;
			_timeToDie =  Window.drawText(' ' + Locale.__e('flash:1393581955601') + ' ' + TimeConverter.timeToCuts(_model.expire - App.time) + ' ', format);
			if (_model.expire - App.time <= 0)
				_timeToDie.text = Locale.__e('flash:1510740606049');
			var lastIndex:int = _timeToDie.text.indexOf(TimeConverter.timeToDays(_model.expire - App.time));
			_timeToDie.setTextFormat(whiteFont, -1, lastIndex);
			_timerCont.addChild(_timeToDie);
			_timerCont.tip = function():Object{
				return{
					title	:Locale.__e('flash:1474469531767'),
					text	:Locale.__e('flash:1507716816002')
				}
			}
			App.self.setOnTimer(onTick);
		}
		
		private function onTick():void
		{
			var timeToDie:int = _model.expire - App.time;	
			if (timeToDie <= 0)
			{
				App.self.setOffTimer(onTick);
				//Window.closeAll()
				_timeToDie.text = Locale.__e('flash:1510740606049');
				
			}	
			else
				_timeToDie.text = Locale.__e('flash:1393581955601') + ' ' + TimeConverter.timeToCuts(timeToDie);
		}
		
		private function drawDescription():void 
		{
			_description = Window.drawText(Locale.__e('flash:1426694723184'),{
				fontSize		:30,
				textAlign		:'center',
				color			:0xffffff,
				borderColor		:0x451c00,
				borderSize		:2,
				width			:settings.width
			});
		}
		
		override public function contentChange():void
		{
			settings.content = parseContent();
			
			for each(var item:FoodItem in _items){
				item.dispose();
				item.parent.removeChild(item);
				item = null;
			}
			_items = [];
			
			var X:int = 0;
			var Y:int = 0;
			var count:int = 3;
			for (var j:int = 0; j < settings.content.length; j++) 
			{
				item = new FoodItem(settings.content[j], {
					throwCallback	:_model.throwCallback, 
					contentChange	:contentChange,
					window			:this,
					maxTime			:_model.maxTime,
					expireTime		:_model.expire
				});
				item.x = X;
				item.y = Y;
				
				_itemsContainer.addChild(item);
				_items.push(item);
				
				X += item.WIDTH + 10;
			}
		}
		
		private function drawBttn():void 
		{
			var bttnSettings:Object = {
			caption		:Locale.__e('flash:1393579618588'),
			fontColor	:0xffffff,
			width		:150,
			height		:50,
			fontSize	:23
			};
		
			bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
			bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
			bttnSettings['fontBorderColor'] = 0x7f3d0e;
			
			_bttn = new Button(bttnSettings);
			_bttn.addEventListener(MouseEvent.CLICK, onStorageEvent);
			if (!_model.tribute)
				_bttn.state = Button.DISABLED;
		}
		
		private function drawRenameBttn():void 
		{
			var bdata:BitmapData = Window.textures.blueCircle;
			Load.loading(Config.getIcon(_info.type, _info.preview), function(data:Bitmap):void{
				Size.scaleBitmapData(data.bitmapData, 0.6);
				bdata.draw(data.bitmapData, new Matrix(1, 0, 0, 1, (bdata.width - data.bitmapData.width) / 2 + 5, (bdata.height - data.bitmapData.height) / 2));
				_renameBttn = new ImageButton(bdata)
				_renameBttn.addEventListener(MouseEvent.CLICK, renameEvent);
				_renameBttn.x = 5;
				_renameBttn.y = 0;
				bodyContainer.addChild(_renameBttn);
				
				_renameBttn.tip = function():Object{
					return{
						title: 	Locale.__e('flash:1508773663818')
					}
				}

			});
		}
		
		private function renameEvent(e:MouseEvent):void 
		{
			var wind:InputMoneyWindow = new InputMoneyWindow({
				title: 			Locale.__e('flash:1508746566568'),
				buttonText: 	Locale.__e('flash:1508746630249'),
				popup:			true,
				hasExit:		true,
				maxLength:		_model.maxLengthName,
				confirm:		function():void{
					_model.renameCallback(wind.inputField.text, reDrawTitle)
				}
			});
			wind.show();
		}
		
		private function reDrawTitle():void
		{
			drawRibbon();
			titleBackingBmap.y += 5;
			drawTitle()
		}
		override public function drawTitle():void 
		{
			if (titleLabel && titleLabel.parent)
				titleLabel.parent.removeChild(titleLabel)
			titleLabel = titleText( {
				title				: _model.beastName,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowSize			: settings.shadowSize,
				shadowColor			: settings.shadowColor,
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -25;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		private function onStorageEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
			{
				Hints.text(Locale.__e('flash:1382952379839') + TimeConverter.timeToDays(_model.crafted - App.time), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
				return;
			}
			close();
			_model.storageCallback()
			_bttn.state = Button.DISABLED;
		}
		
		private function build():void 
		{
			exit.y -= 20;
			titleLabel.y += 14;
			titleBackingBmap.y += 5;
			
			
			
			_timerCont.x = (settings.width - _timerCont.width) / 2;
			_timerCont.y = 30;
			
			_description.y = _timerCont.y + _timerCont.height + 10;
			
			_itemsContainer.x = (settings.width - _itemsContainer.width) / 2;
			_itemsContainer.y = 135;
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - 35 - _bttn.height / 2;
			
			bodyContainer.addChild(_timerCont);
			bodyContainer.addChild(_description);
			bodyContainer.addChild(_itemsContainer);
			bodyContainer.addChild(_bttn);
		}
		override public function dispose():void
		{
			super.dispose();
			App.self.setOffTimer(onTick);
			_bttn.removeEventListener(MouseEvent.CLICK, onStorageEvent);
		}
		
	}

}

import buttons.Button;
import buttons.ObjectMoneyButton;
import core.Load;
import core.Numbers;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import utils.Effects;
import wins.Window;
import wins.elements.PriceLabel;
import wins.ShopWindow;
import wins.BanksWindow;

internal class FoodItem extends LayerX
{	
	private var _icon:Bitmap;
	private var _item:Object;
	private var _title:TextField;
	private var _count:TextField;
	private var _settings:Object = {
		width		:138,
		height		:180
	};
	private var _bttn:Button;
	private var _timeContainer:Sprite;
	private var _background:Bitmap;
	private var _info:Object;
	private var _price:PriceLabel;
	
	public function FoodItem(item:Object, settings:Object)
	{
		for (var property:* in settings) {
			_settings[property] = settings[property];
		}
		
		_info = item;
		_item = App.data.storage[_info.m];
		
		drawBg();
		drawIcon();
		drawTitle();
		drawTime();
		drawCount();
		drawPrice();
		drawBttn();
		
		build();
		this.tip = function():Object{
			return{
				title	:_item.title,	
				text	:_item.description	
			}
		}
	}
	
	public function build():void 
	{
		_title.x = (WIDTH - _title.width) / 2;
		_title.y = 10;
		
		_timeContainer.x = (WIDTH - _timeContainer.width) / 2; 
		_timeContainer.y = 40; 
		
		_count.x = WIDTH - _count.width - 10;
		_count.y = HEIGHT - 50;
		
		_price.x = (WIDTH - _price.width) / 2;
		_price.y = HEIGHT - 50;
		
		_bttn.x = (WIDTH - _bttn.width) / 2;;
		_bttn.y = HEIGHT - _bttn.height / 2;
		
		addChild(_background);
		addChild(_icon);
		addChild(_title);
		addChild(_timeContainer);
		addChild(_count);
		addChild(_price);
		addChild(_bttn);
	}
	
	public function get WIDTH():int { return _settings.width; }
	public function get HEIGHT():int { return _settings.height; }
	
	private function drawBg():void 
	{
		_background = Window.backing(WIDTH, HEIGHT, 10, 'itemBacking');
	}
	
	private function drawIcon():void 
	{
		_icon = new Bitmap();
		Load.loading(Config.getIcon(_item.type, _item.preview),function (data:Bitmap):void 
		{
			_icon.bitmapData = data.bitmapData;
			Size.size(_icon, 100, 90);
			_icon.smoothing = true;
			
			_icon.x = (WIDTH - _icon.width) / 2;
			_icon.y = (HEIGHT - _icon.height) / 2 + 26;
		});
	}
	
	private function drawTitle():void 
	{
		
		_title = Window.drawText(_item.title,{
			fontSize	:26,
			color		:0x7e3e13,
			borderSize	:0,
			textAlign	:'center',
			width		:WIDTH
		});
	}
	
	private function drawTime():void 
	{
		_timeContainer = new Sprite();
		var timerIcon:Bitmap = new Bitmap(Window.textures.timerDark)
		Size.size(timerIcon, 25, 25);
		var time:TextField = Window.drawText('+'+TimeConverter.timeToCuts(_info.t),{
			color		:0xffdf34,
			borderColor	:0x451c00,
			fontSize	:20,
			borderSize	:2,
			textAlign	:'left',
			width		:35
		});
		
		time.x = timerIcon.width;
		time.y = (timerIcon.height - time.textHeight) / 2;
		
		_timeContainer.addChild(timerIcon)
		_timeContainer.addChild(time)
		
	}
	
	private function drawCount():void 
	{
		_count = Window.drawText('x' + _info.c,{
			fontSize		:30,
			color			:0xffffff,
			borderColor		:0x6e411e,
			borderSize		:2,
			textAlign		:'right',
			width			:50
		});
		if (_info.type == 'donate')
			_count.visible = false;
		
	}
	
	private function drawPrice():void 
	{	
		_price = new PriceLabel({'3':_info.c});
		if (_info.type != 'donate')
			_price.visible = false;
	}
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption		:Locale.__e('flash:1382952379872'),
			fontColor	:0xffffff,
			width		:100,
			height		:38,
			fontSize	:23
		};
		
		
		if(_info.type == 'donate'){
			bttnSettings['bgColor'] = [0x66b9f0, 0x567ccf];
			bttnSettings['bevelColor'] = [0xcce8fa, 0x4465b6];
			bttnSettings['fontBorderColor'] = 0x4465b6;
			_settings["bttnCallback"] = throwEvent;
		}else if (App.user.stock.check(_info.m, _info.c)){
			bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
			bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
			bttnSettings['fontBorderColor'] = 0x7f3d0e;
			_settings["bttnCallback"] = throwEvent;
		}else{
			bttnSettings["bgColor"] = [0xc7e314, 0x7fb531];
			bttnSettings["borderColor"] = [0xeafed1, 0x577c2d];
			bttnSettings["bevelColor"] = [0xdef58a, 0x577c2d];
			bttnSettings["fontColor"] = 0xffffff;			
			bttnSettings["fontBorderColor"] = 0x085c10;
			bttnSettings["caption"] = Locale.__e("flash:1407231372860");
			_settings["bttnCallback"] = findMaterial;
			}
		
			
		_bttn = new Button(bttnSettings);
		if (_settings.maxTime < (_settings.expireTime - App.time) || (_settings.expireTime - App.time) <= 0)
			_bttn.state = Button.DISABLED;
		_bttn.addEventListener(MouseEvent.CLICK, _settings.bttnCallback);
	}
	
	public function dispose():void{
		_bttn.removeEventListener(MouseEvent.CLICK, _settings.bttnCallback);
	}
	
	private function throwEvent(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED && _settings.maxTime < (_settings.expireTime - App.time))
		{
			Hints.text(Locale.__e('flash:1510229171859') + ' ' + TimeConverter.timeToDays(_settings.maxTime), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
			return;
		}
		else if (e.currentTarget.mode == Button.DISABLED && (_settings.expireTime - App.time) <= 0)
		{
			Hints.text(Locale.__e('flash:1510741250260'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
			return;
		}
		if (_info.type == 'donate')
		{
			if (!App.user.stock.check(Stock.FANT, _info.c))
				return;
			else
				_settings.throwCallback(_info.type, _settings.contentChange);
		}
		else
		{
			_settings.throwCallback(_info.type, _settings.contentChange);
		}
		
		
	}
	
	private function findMaterial(e:MouseEvent):void 
	{
		_settings.window.close();
		ShopWindow.findMaterialSource(_info.m);
	}
}