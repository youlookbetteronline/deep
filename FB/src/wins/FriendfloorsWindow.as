package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import models.FriendfloorsModel;
	import ui.Hints;
	/**
	 * ...
	 * @author ...
	 */
	public class FriendfloorsWindow extends Window 
	{
		private var _bttn:						Button;
		private var _friendBttn:				ImageButton;
		private var _info:						Object;
		private var _materialSprite:			Sprite 	= new Sprite();
		private var _materialItems:				Array = [];
		private var _friendSprite:				Sprite 	= new Sprite();
		private var _descriptionText:			TextField;
		private var _materialText:				TextField;
		private var _friendText:				TextField;
		private var _model:						FriendfloorsModel;
		private var _progressBarMaterials:		ProgressBar;
		private var _progressBackingMaterials:	Bitmap;
		private var _progressTextMaterials:		TextField;
		private var _progressBarFriends:		ProgressBar;
		private var _progressBackingFriends:	Bitmap;
		private var _progressTextFriends:		TextField;
		
		public function FriendfloorsWindow(settings:Object=null) 
		{
			this._model = settings.model;
			this._info = settings.target.info
			settings["width"]				= 620;
			settings["height"] 				= 540;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= true;
			settings["hasArrows"]			= false;
			settings['exitTexture'] 		= 'closeBttnMetal';
			settings['background	'] 		= 'capsuleWindowBacking';
			settings['fontColor'] 			= 0xffffff;
			settings['fontBorderColor'] 	= 0x116011;
			settings['borderColor'] 		= 0x116011;
			settings['shadowBorderColor']	= 0x116011;
			settings['fontSize'] 			= 52;
			settings['title'] 				= settings.target.info.title;
			_model.window = this;
			super(settings);
			
		}
		
		private function parseContent():Array{
			var msimple:Object = _info.levels[_model.floor]['throw'].msimple[_model.toThrow.msimple]
			var mdonate:Object = _info.levels[_model.floor]['throw'].mdonate[_model.toThrow.mdonate]

			msimple.type = 'msimple';
			mdonate.type  = 'mdonate';
			
			return [msimple, mdonate];
			
		}	
		
		override public function drawBody():void 
		{
			drawRibbon();
			drawTexts();
			drawProgress();
			contentChange();
			//drawBttn();
			build();
		}
		
		private function drawTexts():void 
		{
			_descriptionText = Window.drawText(Locale.__e('flash:1397573560652') + ': ' + _model.floor + '/' + _model.totalFloor, {
				fontSize		:44,
				color			:0xffffff,
				borderColor		:0x7e3e13,
				textAlign		:'center',
				width			:settings.width - 100
			})
			
			_materialText = Window.drawText(Locale.__e('flash:1509966943668'), {
				fontSize	:30,
				color		:0x7e3e13,
				borderSize	:0,
				textAlign	:'center',
				width		:settings.width - 100
			})
			
			_friendText = Window.drawText(Locale.__e('flash:1509966982725'), {
				fontSize	:30,
				color		:0x7e3e13,
				borderSize	:0,
				textAlign	:'center',
				width		:settings.width - 100
			})
		}
		override public function contentChange():void 
		{
			settings.content = parseContent();
			drawMaterialSprite();
			drawFriendSprite();
			progress()
			drawBttn();
		}
		
		private function drawProgress():void 
		{
			_progressBackingMaterials = Window.backingShort(190, "backingBank");
			
			
			var barSettings:Object = {
				typeLine:'sliderBank',
				width:189,
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
			
			_progressBackingFriends = Window.backingShort(290, "backingBank");
			
			
			var barSettingsF:Object = {
				typeLine:'sliderBank',
				width:289,
				win:this.parent
			};
			
			_progressBarFriends = new ProgressBar(barSettingsF);
			_progressBarFriends.start();
			_progressBarFriends.timer.text = '';
			
			_progressTextFriends = Window.drawText('', {
				fontSize	:30,
				color		:0xffffff,
				borderColor	:0x6d3c13,
				textAlign	:"center",
				borderSize:2,
				multiline:true,
				wrap:true
			});
			_progressTextFriends.width = 100;
		}
		
		private function drawMaterialSprite():void
		{
			
			for each(var item:KickItem in _materialItems){
				item.parent.removeChild(item);
				item = null;
			}
			
			
			_materialItems = [];
			
			var X:int = 0;
			var Y:int = 0;
			for (var i:int = 0; i < settings.content.length; i++) 
			{
				item = new KickItem(settings.content[i], {
					mkickCallback:_model.mkickCallback,
					fkickCallback:_model.fkickCallback,
					contentChange:contentChange,
					model		 :_model,
					target		 :_info,
					window:this
				});
				item.x = X;
				item.y = Y;
				
				_materialSprite.addChild(item);
				_materialItems.push(item);
				
				X += item.WIDTH + 10;
			}
			
		}
			
		
		private function drawFriendSprite():void
		{
			_friendBttn = new ImageButton(Window.textures.friendIcoBig)
			Size.size(_friendBttn, 90, 90)
			_friendBttn.bitmap.smoothing = true;
			_friendBttn.addEventListener(MouseEvent.CLICK, addFriends)
			
		}
		
		private function addFriends(e:MouseEvent):void 
		{
			if (Numbers.countProps(_model.friends) >= settings.target.info.levels[_model.floor].req.friends)
			{
				Hints.text(Locale.__e('flash:1510137461363'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
				return;
			}
			
			new FriendsListWindow({
				popup:		true,
				target:		settings.target,
				callback:	_model.fkickCallback,
				model:		_model,
				content:	getFriends()
			}).show();
		}
		
		private function getFriends():Array 
		{
			var friends:Array = [];
			for each(var _friend:* in App.user.friends.data)
			{
				if (settings.model.friends.hasOwnProperty(_friend.uid))
					continue;
				friends.push(_friend);
			}
			return friends;
		}
		
		
		
		
		private function progress():void 
		{	
			_progressBarMaterials.progress = _model.kicks / _info.levels[_model.floor].req.kicks;
			_progressTextMaterials.text = String(_model.kicks) + '/' + String(_info.levels[_model.floor].req.kicks);
			
			_progressBarFriends.progress = Numbers.countProps(_model.friends) / _info.levels[_model.floor].req.friends;
			_progressTextFriends.text = String(Numbers.countProps(_model.friends)) + '/' + String(_info.levels[_model.floor].req.friends);
		}
		
		private function drawBttn():void 
		{
			if (_bttn && _bttn.parent)
				_bttn.parent.removeChild(_bttn);
			var bttnText:String = _info.buttontext || Locale.__e('flash:1467807291800');
			var bttnSettings:Object = {
			caption		:bttnText,
			fontColor	:0xffffff,
			width		:160,
			height		:60,
			fontSize	:32
			};
		
			bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
			bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
			bttnSettings['fontBorderColor'] = 0x7f3d0e;
			
			_bttn = new Button(bttnSettings);
			if (Numbers.countProps(_model.friends) < _info.levels[_model.floor].req.friends || _model.kicks < _info.levels[_model.floor].req.kicks)
				_bttn.state = Button.DISABLED;
			_bttn.addEventListener(MouseEvent.CLICK, onFloorEvent);
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - 55 - _bttn.height / 2;
			bodyContainer.addChild(_bttn);
		}
		
		private function onFloorEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
			{
				Hints.text(Locale.__e('flash:1510137421605'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
				return;
			}
			_model.growCallback();
		}
		
		private function build():void 
		{
			exit.y -= 20;
			titleLabel.y += 14;
			titleBackingBmap.y += 5;
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - 55 - _bttn.height / 2;
			
			_materialText.x = (settings.width - _materialText.width) / 2;
			_materialText.y = 80;
			
			_descriptionText.x = (settings.width - _descriptionText.width) / 2;
			_descriptionText.y = 30;
			
			_friendText.x = (settings.width - _friendText.width) / 2;
			_friendText.y = 320;
			
			_materialSprite.x = 70;
			_materialSprite.y = 120;
			
			_friendBttn.x = 110;
			_friendBttn.y = 360;
			
			_progressBackingMaterials.x = settings.width / 2 + 60;
			_progressBackingMaterials.y = 195;
			
			_progressBarMaterials.x = _progressBackingMaterials.x - 18;
			_progressBarMaterials.y = _progressBackingMaterials.y - 13;
			
			_progressTextMaterials.x = _progressBackingMaterials.x + (_progressBackingMaterials.width - _progressTextMaterials.width) / 2;
			_progressTextMaterials.y = _progressBackingMaterials.y + (_progressBackingMaterials.height - _progressTextMaterials.height) / 2 + 4;
			
			_progressBackingFriends.x = settings.width / 2 - 80;
			_progressBackingFriends.y = 390;
			
			_progressBarFriends.x = _progressBackingFriends.x - 18;
			_progressBarFriends.y = _progressBackingFriends.y - 13;
			
			_progressTextFriends.x = _progressBackingFriends.x + (_progressBackingFriends.width - _progressTextFriends.width) / 2;
			_progressTextFriends.y = _progressBackingFriends.y + (_progressBackingFriends.height - _progressTextFriends.height) / 2 + 4;
			
			bodyContainer.addChild(_materialText);
			bodyContainer.addChild(_descriptionText);
			bodyContainer.addChild(_friendText);
			bodyContainer.addChild(_bttn);
			bodyContainer.addChild(_friendBttn);
			bodyContainer.addChild(_materialSprite);
			
			bodyContainer.addChild(_progressBackingMaterials);
			bodyContainer.addChild(_progressBarMaterials);
			bodyContainer.addChild(_progressTextMaterials);
			
			bodyContainer.addChild(_progressBackingFriends);
			bodyContainer.addChild(_progressBarFriends);
			bodyContainer.addChild(_progressTextFriends);

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
import flash.text.TextField;
import utils.Effects;
import wins.Window;
import wins.elements.PriceLabel;
import wins.ShopWindow;
import wins.BanksWindow;

internal class KickItem extends LayerX
{	
	private var _icon:Bitmap;
	private var _item:Object;
	private var _title:TextField;
	private var _count:TextField;
	private var _countPlus:TextField;
	private var _settings:Object = {
		width		:138,
		height		:160
	};
	private var _bttn:Button;
	private var _timeContainer:Sprite;
	private var _background:Bitmap;
	private var _info:Object;
	private var _price:PriceLabel;
	
	public function KickItem(item:Object, settings:Object)
	{
		for (var property:* in settings) {
			_settings[property] = settings[property];
		}
		
		_info = item;
		_item = App.data.storage[_info.m];
		
		drawBg();
		drawIcon();
		drawTitle();
		drawPrice();
		drawCount();
		drawCountPlus();
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
		_title.y = 0;
		
		_price.x = (WIDTH - _price.width) / 2;
		_price.y = HEIGHT - 50;
		
		_count.x = WIDTH - _count.width - 10;
		_count.y = HEIGHT - 50;
		
		_countPlus.x = (WIDTH - _countPlus.width) / 2;
		_countPlus.y = 20;
		
		_bttn.x = (WIDTH - _bttn.width) / 2;;
		_bttn.y = HEIGHT - _bttn.height / 2;
		
		addChild(_background);
		addChild(_icon);
		addChild(_count);
		addChild(_countPlus);
		addChild(_title);
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
			Size.size(_icon, 90, 80);
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
	
	private function drawCountPlus():void 
	{
		_countPlus = Window.drawText('+' + _info.k,{
			fontSize		:26,
			color			:0xffffff,
			borderColor		:0x6e411e,
			borderSize		:2,
			textAlign		:'center',
			width			:50
		});
		
	}
	
	private function drawPrice():void 
	{	
		_price = new PriceLabel({'3':Numbers.firstProp(App.data.storage[_info.m].price).val});
		if (_info.type != 'mdonate')
			_price.visible = false;
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
		if(_info.type == 'mdonate'){
			bttnSettings['bgColor'] = [0x66b9f0, 0x567ccf];
			bttnSettings['bevelColor'] = [0xcce8fa, 0x4465b6];
			bttnSettings['fontBorderColor'] = 0x4465b6;
			_settings["bttnCallback"] = mkickEvent;
		}else if (App.user.stock.check(_info.m, _info.c)){
			bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
			bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
			bttnSettings['fontBorderColor'] = 0x7f3d0e;
			_settings["bttnCallback"] = mkickEvent;
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
		if (_settings.model.kicks >= _settings.target.levels[_settings.model.floor].req.kicks)
		
			_bttn.state = Button.DISABLED
		_bttn.addEventListener(MouseEvent.CLICK, _settings.bttnCallback);
	}
	private function mkickEvent(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED)
			return;
		if (_info.type == 'mdonate')
		{
			if (!App.user.stock.checkAll(App.data.storage[_info.m].price))
				return;
			else
				_settings.mkickCallback(_info.m, _info.type, _settings.contentChange);
		}
		else
			_settings.mkickCallback(_info.m, _info.type, _settings.contentChange);
		
	}
	
	private function findMaterial(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED)
			return;
		_settings.window.close();
		ShopWindow.findMaterialSource(_info.m);
	}
}