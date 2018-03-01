package wins 
{
	import api.com.adobe.images.PNGEncoder;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import core.Numbers;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import models.ContestModel;
	import ui.Hints;
	import utils.TopHelper;
	/**
	 * ...
	 * @author ...
	 */
	public class ContestWindow extends Window 
	{
		private var _model:ContestModel;
		private var _info:Object;
		
		private var _items:Array = [];
		private var _itemsContainer:Sprite = new Sprite();
		private var _description:TextField;
		private var _timerCont:LayerX;
		private var _timeToDie:TextField;
		private var _timeToGift:TextField;
		private var _bttnStorage:Button;
		private var _bttnUpgrade:Button;
		private var _renameBttn:ImageButton;
		private var _progressBarMaterials:		ProgressBar;
		private var _progressBackingMaterials:	Bitmap;
		private var _progressTextMaterials:		TextField;
		private var _descriptionText:			TextField;
		private var _timeStorageText:			TextField;
		private var _topIcon:					ImageButton;
		
		public function ContestWindow(settings:Object=null) 
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
			settings["height"] 				= 470;
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
			var msimple:Object = _info.levels[_model.floor]['throw'].msimple[_model.toThrow.msimple]
			var mcomplex:Object = _info.levels[_model.floor]['throw'].mcomplex[_model.toThrow.mcomplex]
			var mdonate:Object = _info.levels[_model.floor]['throw'].mdonate[_model.toThrow.mdonate]
			
			msimple.type = 'msimple';
			mcomplex.type  = 'mcomplex';
			mdonate.type  = 'mdonate';
			
			return [msimple, mcomplex, mdonate];
			
		}	
		
		override public function drawBody():void 
		{
			drawRibbon();
			drawDescription();
			drawTexts();
			drawProgress()
			contentChange();
			drawTimeStorage();
			drawInfoBttn();
			drawTopButton();
			build();
		}
		
		private function drawTexts():void 
		{
			_descriptionText = Window.drawText(Locale.__e('flash:1397573560652') + ': ' + _model.floor + '/' + _model.totalFloor, {
				fontSize		:38,
				color			:0xffffff,
				borderColor		:0x7e3e13,
				textAlign		:'center',
				width			:settings.width - 100
			})	
		}
		
		private function drawProgress():void
		{
			_progressBackingMaterials = Window.backingShort(320, "backingBank");
			
			var barSettings:Object = {
				typeLine:'sliderBank',
				width:319,
				win:this.parent
			};
			
			_progressBarMaterials = new ProgressBar(barSettings);
			_progressBarMaterials.start();
			_progressBarMaterials.timer.text = '';
			
			_progressTextMaterials = Window.drawText('', {
				fontSize	:30,
				color		:0xffffff,
				borderColor	:0x6d3c13,
				textAlign	:"center",
				borderSize:2,
				multiline:true,
				wrap:true
			});
			_progressTextMaterials.width = 100;
		}
		
		private function progress():void 
		{
			if (_model.floor == _model.totalFloor)
			{
				_progressBarMaterials.progress = _model.kicks / _info.levels[_model.floor].req.kicks;
				_progressTextMaterials.text = String(_model.kicks);
			}
			else
			{
				_progressBarMaterials.progress = _model.kicks / _info.levels[_model.floor].req.kicks;
				_progressTextMaterials.text = String(_model.kicks) + '/' + String(_info.levels[_model.floor].req.kicks);
			}
			
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
			drawBttn();
			settings.content = parseContent();
			progress();
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
					model			:_model,
					target			:settings.target
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
			if (_bttnStorage && _bttnStorage.parent)
				_bttnStorage.parent.removeChild(_bttnStorage);
			if (_bttnUpgrade && _bttnUpgrade.parent)
				_bttnUpgrade.parent.removeChild(_bttnUpgrade);
			var bttnSettings:Object = {
			caption		:Locale.__e('flash:1447939811359'),
			fontColor	:0xffffff,
			width		:164,
			height		:50,
			fontSize	:28
			};
		
			bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
			bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
			bttnSettings['fontBorderColor'] = 0x7f3d0e;
			
			_bttnStorage = new Button(bttnSettings);
			_bttnStorage.addEventListener(MouseEvent.CLICK, onStorageEvent);
			if (!_model.tribute)
				_bttnStorage.state = Button.DISABLED;
			
			_bttnUpgrade = new Button({
				caption			:Locale.__e('flash:1396963489306'),
				fontColor		:0xffffff,
				width			:164,
				height			:50,
				fontSize		:28,
				bgColor			:[0xbcec63, 0x68bc21],
				bevelColor		:[0xe0ffad, 0x4e8b2c],
				fontBorderColor	:0x085c10
			});
			_bttnUpgrade.addEventListener(MouseEvent.CLICK, onUpgradeEvent);
			
			
			if (_model.floor == _model.totalFloor)
			{
				_bttnStorage.x = (settings.width - _bttnStorage.width) / 2;
				_bttnStorage.y = settings.height - 78;
				bodyContainer.addChild(_bttnStorage);
			}
			else
			{
				_bttnStorage.x = settings.width / 2 - _bttnStorage.width - 10;
				_bttnStorage.y = settings.height - 78;
				
				_bttnUpgrade.x = settings.width / 2 + 10;
				_bttnUpgrade.y = settings.height - 78;
				
				bodyContainer.addChild(_bttnStorage);
				bodyContainer.addChild(_bttnUpgrade);
				
				if (_model.kicks < _info.levels[_model.floor].req.kicks)
					_bttnUpgrade.state = Button.DISABLED;
			}
		}
		
		private function drawTimeStorage():void 
		{
			_timeStorageText = Window.drawText(Locale.__e('flash:1396606659545') +' '+ TimeConverter.timeToDays(_model.crafted - App.time), {
				fontSize		:30,
				textAlign		:'center',
				color			:0xffffff,
				borderColor		:0x451c00,
				borderSize		:2,
				width			:settings.width - 70
			})
			var timeToDie:int = _model.crafted - App.time;
			if (timeToDie <= 0)
				_timeStorageText.text = Locale.__e('flash:1510740606049');
	
			App.self.setOnTimer(onTick);
		}
		
		
		private function onTick():void
		{
			var timeToDie:int = _model.crafted - App.time;	
			if (timeToDie <= 0)
			{
				App.self.setOffTimer(onTick);
				_timeStorageText.text = Locale.__e('flash:1510740606049');
				
			}	
			else
				_timeStorageText.text = Locale.__e('flash:1396606659545') +' '+ TimeConverter.timeToDays(timeToDie)
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
			e.currentTarget.state = Button.DISABLED;
		}
		
		private function onUpgradeEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			e.currentTarget.state = Button.DISABLED;
			_model.upgradeCallback(function():void{
				close();
			})
		}
		
		private function drawInfoBttn():void 
		{
			var infoBttn:ImageButton = new ImageButton(textures.askBttnMetal);
			bodyContainer.addChild(infoBttn);
			infoBttn.x = settings.width - 47;
			infoBttn.y = 40;
			infoBttn.addEventListener(MouseEvent.CLICK, infoEvent);
		}
		
		private function infoEvent(e:MouseEvent):void 
		{
			
		}
		
		private function drawTopButton():void
		{
			_topIcon = new ImageButton(Window.textures.topIcon);
			Size.size(_topIcon, 100, 100);
			_topIcon.addEventListener(MouseEvent.CLICK, onClickTopButton)
		}
		
		private function onClickTopButton(e:MouseEvent):void 
		{
			close();
			TopHelper.showTopWindow(settings.target.info.sID);
			/*new TopBubbleWindow({
				popup:	true
			}).show();*/
		}
		
		private function build():void 
		{
			exit.y -= 20;
			titleLabel.y += 14;
			titleBackingBmap.y += 5;
			
			_description.y = 110
			
			
			_itemsContainer.x = (settings.width - _itemsContainer.width) / 2;
			_itemsContainer.y = 145;
			
			_descriptionText.x = (settings.width - _descriptionText.width) / 2;
			_descriptionText.y = 25;
			
			_progressBackingMaterials.x = (settings.width - _progressBackingMaterials.width) / 2;
			_progressBackingMaterials.y = 75;	
			
			_timeStorageText.x = (settings.width - _timeStorageText.width) / 2;
			_timeStorageText.y = 353;
			
			_progressBarMaterials.x = _progressBackingMaterials.x - 18;
			_progressBarMaterials.y = _progressBackingMaterials.y - 13;
			
			_progressTextMaterials.x = _progressBackingMaterials.x + (_progressBackingMaterials.width - _progressTextMaterials.width) / 2;
			_progressTextMaterials.y = _progressBackingMaterials.y + (_progressBackingMaterials.height - _progressTextMaterials.height) / 2 + 4;
			
			_topIcon.x = 5;
			_topIcon.y = 50;

			bodyContainer.addChild(_description);
			bodyContainer.addChild(_itemsContainer);
			
			bodyContainer.addChild(_progressBackingMaterials);
			bodyContainer.addChild(_progressBarMaterials);
			bodyContainer.addChild(_progressTextMaterials);
			bodyContainer.addChild(_descriptionText);
			bodyContainer.addChild(_timeStorageText);
			bodyContainer.addChild(_topIcon);

		}
		override public function dispose():void
		{
			super.dispose();
			_bttnStorage.removeEventListener(MouseEvent.CLICK, onStorageEvent);
			_bttnUpgrade.removeEventListener(MouseEvent.CLICK, onUpgradeEvent);
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
	private var _countPlus:TextField;
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
		drawCountPlus();
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
		
		_countPlus.x = (WIDTH - _countPlus.width) / 2; 
		_countPlus.y = 40; 
		
		_count.x = WIDTH - _count.width - 10;
		_count.y = HEIGHT - 50;
		
		_price.x = (WIDTH - _price.width) / 2;
		_price.y = HEIGHT - 50;
		
		_bttn.x = (WIDTH - _bttn.width) / 2;;
		_bttn.y = HEIGHT - _bttn.height / 2;
		
		addChild(_background);
		addChild(_icon);
		addChild(_title);
		addChild(_countPlus);
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
	
	private function drawCountPlus():void 
	{
		_countPlus = Window.drawText('+'+_info.k,{
			color		:0xffdf34,
			borderColor	:0x451c00,
			fontSize	:20,
			borderSize	:2,
			textAlign	:'left',
			width		:35
		});
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
		if (_info.type == 'mdonate')
			_count.visible = false;
		
	}
	
	private function drawPrice():void 
	{	
		_price = new PriceLabel({'3':_info.c});
		if (_info.type != 'mdonate')
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
		
		
		if(_info.type == 'mdonate'){
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

		_bttn.addEventListener(MouseEvent.CLICK, _settings.bttnCallback);
		
		if (_settings.model.kicks >= _settings.target.info.levels[_settings.model.floor].req.kicks && _settings.model.floor != _settings.model.totalFloor)
			_bttn.state = Button.DISABLED
	}
	
	public function dispose():void{
		_bttn.removeEventListener(MouseEvent.CLICK, _settings.bttnCallback);
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