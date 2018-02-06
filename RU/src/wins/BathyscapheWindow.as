package wins 
{
	import api.com.adobe.json.JSONTokenType;
	import buttons.Button;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.drm.DRMVoucherDownloadContext;
	import flash.text.TextField;
	import models.BathyscapheModel;
	import utils.Locker;
	/**
	 * ...
	 * @author das
	 */
	public class BathyscapheWindow extends Window 
	{
		private var _model:BathyscapheModel;
		private var _target:Object;
		private var _items:Array = [];
		private var _capacityText:Array = [];
		
		private var _itemsContainer:Sprite = new Sprite();
		private var _capacityContainer:LayerX;
		private var _bttn:Button;
		private var _haveCapacity:TextField;
		public function BathyscapheWindow(settings:Object=null) 
		{
			
			_model = settings.model;
			_target = settings.target.info;
			
			settings["width"]				= 545;
			settings["height"] 				= 400;
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
			settings['content'] 			= _target.mthrow;
			
			super(settings);
			
		}
		
		override public function drawBody():void 
		{
			drawRibbon();
			drawCapacity();
			contentChange();
			drawBttn();
			build();
		}
		private function drawCapacity():void 
		{
			for each(var ct:* in _capacityText){
				//item.dispose();
				ct.parent.removeChild(ct);
				ct = null;
			}
			_capacityText = [];
			_capacityContainer = new LayerX();
			
			_haveCapacity =  Window.drawText(String(_model.throws), {
				color		:0xffdf34,
				borderColor	:0x451c00,
				textAlign	:'left',
				fontSize	:28,
				borderSize	:2,
				autoSize	:'left'
			});
			var maxCapacity:TextField = Window.drawText(('/ ' + _model.limitThrows), {
				color		:0xffdf34,
				borderColor	:0x451c00,
				textAlign	:'left',
				fontSize	:28,
				borderSize	:2,
				autoSize	:'left'
			});
			var description:TextField = Window.drawText(Locale.__e('flash:1508916416791')+' ',{
				color		:0xffffff,
				borderColor	:0x451c00,
				textAlign	:'left',
				fontSize	:36,
				borderSize	:2,
				autoSize	:'left'
			});
			var fuelText:TextField = Window.drawText(Locale.__e('flash:1508920323267') +' ' + App.user.stock.count(_model.materialThrows),{
				color		:0xffffff,
				borderColor	:0x451c00,
				textAlign	:'left',
				fontSize	:36,
				borderSize	:2,
				autoSize	:'left'
			});
			_capacityText.push(_haveCapacity);
			_capacityText.push(maxCapacity);
			_capacityText.push(description);
			_capacityText.push(fuelText);
			
			_haveCapacity.x = description.width;
			_haveCapacity.y = description.y + (description.height - _haveCapacity.height) / 2;
			maxCapacity.x = _haveCapacity.x + _haveCapacity.width;
			maxCapacity.y = _haveCapacity.y;
			
			fuelText.x = description.x + (description.width - fuelText.width) / 2 + 35;
			fuelText.y = _haveCapacity.y + _haveCapacity.height + 5;
			
			_capacityContainer.addChild(_haveCapacity);
			_capacityContainer.addChild(maxCapacity);
			_capacityContainer.addChild(description);
			_capacityContainer.addChild(fuelText);
			
			_capacityContainer.x = (settings.width - _capacityContainer.width) / 2;
			_capacityContainer.y = 30;
			bodyContainer.addChild(_capacityContainer);
		}
		
		public function updateContent():void
		{
			contentChange();
			drawCapacity();
		}
		
		override public function contentChange():void
		{	
			for each(var item:FuelItem in _items){
				//item.dispose();
				item.parent.removeChild(item);
				item = null;
			}
			_items = [];
			
			var X:int = 0;
			var Y:int = 0;
			var count:int = 1;
			for (var j:int = 0; j <3/* settings.content.length*/; j++) 
			{
				item = new FuelItem(settings.content, {
					throwCount		:(j == 0) ? 1 : (j * 5),
					model			:_model,
					updateWindow    :updateContent
					//contentChange:contentChange,
					//window:this
				});
				item.x = X;
				item.y = Y;
				
				_itemsContainer.addChild(item);
				_items.push(item);
				
				X += item.WIDTH + 10;
				count++;
			}
		}
		
		private function drawBttn():void 
		{
			var bttnSettings:Object = {
			caption		:Locale.__e('flash:1393584440735'),
			fontColor	:0xffffff,
			width		:160,
			height		:60,
			fontSize	:23
			};
		
			bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
			bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
			bttnSettings['fontBorderColor'] = 0x7f3d0e;
			
			_bttn = new Button(bttnSettings);
			_bttn.addEventListener(MouseEvent.CLICK, onTravelEvent);
		}
		
		private function onTravelEvent(e:MouseEvent):void 
		{
			//Locker.availableUpdate();
			//return;
			closeAll();
			new TravelWindow().show();
		}
		
		private function build():void 
		{
			exit.y -= 20;
			titleLabel.y += 14;
			titleBackingBmap.y += 5;
			
			_itemsContainer.y = 130;
			_itemsContainer.x = (settings.width - _itemsContainer.width) / 2;
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - 45 - _bttn.height / 2;
			
			bodyContainer.addChild(_itemsContainer);
			bodyContainer.addChild(_bttn);
		}
		
		override public function dispose():void
		{
			super.dispose();
			_bttn.removeEventListener(MouseEvent.CLICK, onTravelEvent);
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

internal class FuelItem extends LayerX
{	
	private var _icon:Bitmap;
	private var _item:Object;
	private var _title:TextField;
	private var _count:TextField;
	private var _settings:Object = {
		width		:138,
		height		:160
	};
	private var _bttn:Button;
	private var _timeContainer:Sprite;
	private var _background:Bitmap;
	private var _info:Object;
	
	public function FuelItem(fuelSid:int, settings:Object)
	{
		for (var property:* in settings) {
			_settings[property] = settings[property];
		}
		
		//_info = item;
		_item = App.data.storage[fuelSid];
		
		drawBg();
		drawIcon();
		drawTitle();
		drawCount();
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
		
		_count.x = WIDTH - _count.width - 10;
		_count.y = HEIGHT - 50;
		
		_bttn.x = (WIDTH - _bttn.width) / 2;;
		_bttn.y = HEIGHT - _bttn.height / 2;
		
		addChild(_background);
		addChild(_icon);
		addChild(_title);
		addChild(_count);
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
			_icon.y = (HEIGHT - _icon.height) / 2 + 6;
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
	
	
	
	private function drawCount():void 
	{
		_count = Window.drawText('x' +_settings.throwCount,{
			fontSize		:30,
			color			:0xffffff,
			borderColor		:0x6e411e,
			borderSize		:2,
			textAlign		:'right',
			width			:50
		});
		
	}
	
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption		:Locale.__e('flash:1467807291800'),
			fontColor	:0xffffff,
			width		:100,
			height		:38,
			fontSize	:23
		};
		
		if (App.user.stock.check(_item.sID, _settings.throwCount)){
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
		if (_settings.model.throws >= _settings.model.limitThrows)
			_bttn.state = Button.DISABLED;
		_bttn.addEventListener(MouseEvent.CLICK, _settings.bttnCallback);
	}
	
	private function throwEvent(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED)
		{
			Hints.text(Locale.__e('flash:1508917433472'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
			return;
		}
		_settings.model.throwCallback(_settings.throwCount, _settings.updateWindow);
	}
	
	private function findMaterial(e:MouseEvent):void 
	{
		Window.closeAll()
		ShopWindow.findMaterialSource(_item.sID);
	}
}