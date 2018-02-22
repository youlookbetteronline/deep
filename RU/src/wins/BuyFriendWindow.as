package wins 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import units.AUnit;
	/**
	 * ...
	 * @author ...
	 */
	public class BuyFriendWindow extends Window 
	{
		private var _fakefriend:Fakefriend;
		private var _fakefriendList:Vector.<Fakefriend>;
		private var _fakefriendContainer:Sprite = new Sprite();
		private var _target:AUnit;
		public function BuyFriendWindow(settings:Object=null) 
		{
			_target = settings.target;
			settings["width"]				= 530;
			settings["height"] 				= 330;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= true;
			settings["hasArrows"]			= false;
			settings['exitTexture'] 		= 'closeBttnMetal';
			settings['background']	 		= 'capsuleWindowBacking';
			settings['fontColor'] 			= 0xffffff;
			settings['fontBorderColor'] 	= 0x116011;
			settings['borderColor'] 		= 0x116011;
			settings['shadowBorderColor']	= 0x116011;
			settings['fontSize'] 			= 50;
			settings['content'] 			= _target.info.fakefriends;
			
			super(settings);
			
			
		}
		
		override public function contentChange():void 
		{
			disposeChilds(_fakefriendList);
			_fakefriendList = new Vector.<Fakefriend>
			var X:int = 0;
			for (var i:int = 0; i < settings.content.length; i++) 
			{
				_fakefriend = new Fakefriend({
					sID:	settings.content[i],
					model:	settings.model,
					target:	settings.target,
					window:	this
				});
				_fakefriend.x = X;
				
				_fakefriendContainer.addChild(_fakefriend);
				_fakefriendList.push(_fakefriend);
				
				X += _fakefriend.SIDE + 20;
			}
		}
		
		
		override public function drawBody():void 
		{
			drawRibbon();
			var _bg:Shape = new Shape();
			_bg.graphics.beginFill(0xfeeed3);
			_bg.graphics.drawRect(0, 0, settings.width - 110, 200);
			_bg.graphics.endFill();
			_bg.x = (settings.width - _bg.width) / 2;
			_bg.y = (settings.height - _bg.height) / 2 - 25;
			_bg.filters = [new BlurFilter(10, 0, 10)];
			bodyContainer.addChild(_bg);
			contentChange()
			build();
		}
		
		private function build():void 
		{
			exit.y -= 20;
			titleLabel.y += 12;
			titleBackingBmap.y += 6;
			
			_fakefriendContainer.x = (settings.width - _fakefriendContainer.width) / 2;
			_fakefriendContainer.y = 80
			bodyContainer.addChild(_fakefriendContainer);
		}
	}

}
import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Numbers;
import core.Size;
import flash.events.MouseEvent;
import models.FriendfloorsModel;
import units.Friendfloors;
import utils.Locker;
import wins.Window;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.text.TextField;

internal class Fakefriend extends LayerX
{
	private var _settings:Object = {
		side:112
	}
	private var _bg:Shape = new Shape();
	private var _image:Bitmap;
	private var _titleLabel:TextField;
	private var _item:Object;
	private var _bttn:Button;
	private var _model:FriendfloorsModel;
	private var _target:Friendfloors;
	public function Fakefriend(settings:Object = null)
	{
		this._item = App.data.storage[settings.sID];
		this._model = settings.model;
		this._target = settings.target;
		for (var property:* in settings)
			_settings[property] = settings[property];
		drawBackground();	
		drawTitle();	
		drawAvatar();
		drawButton();
		build();
	}
	
	private function drawBackground():void 
	{
		_bg.graphics.beginFill(0xb27647, 1);
		_bg.graphics.drawRoundRect(0, 0, SIDE, SIDE, 30);
		_bg.graphics.endFill();
	}
	
	private function drawTitle():void 
	{
		_titleLabel = Window.drawText(_item.title,{
			fontSize	:26,
			color		:0x6e411e,
			borderSize	:0,
			textAlign	:'center',
			wrap		:true,
			multiline	:true,
			width		:SIDE
		})
	}
	
	private function drawAvatar():void 
	{
		Load.loading(Config.getIcon(_item.type, _item.preview), onLoad) 
	}
	
	private function onLoad(data:Bitmap):void 
	{
		_image = new Bitmap(data.bitmapData);
		Size.size(_image, 110, 110);
		_image.smoothing = true;
		addImage()
	}
	
	private function addImage():void 
	{
		if (!_image)
			return;
		_image.x = _bg.x + (_bg.width - _image.width) / 2;
		_image.y = _bg.y + (_bg.height - _image.height) / 2;
		
		var _mask:Shape = new Shape();
		_mask.graphics.beginFill(0xb27647, 1);
		_mask.graphics.drawRoundRect(0, 0, 104, 104, 26);
		_mask.graphics.endFill();
		_mask.x = _bg.x + (_bg.width - _mask.width) / 2;
		_mask.y = _bg.y + (_bg.height - _mask.height) / 2;
		addChild(_image);
		addChild(_mask);
		
		_image.mask = _mask;
	}
	
	private function drawButton():void 
	{
		_bttn = new MoneyButton({
			caption			: Locale.__e('flash:1518780998508') + '\n',
			width			:SIDE,
			height			:44,
			fontSize		:20,
			fontCountSize	:20,
			radius			:16,
			countText		:Numbers.firstProp(_item.price).val,
			boostsec		:1,
			mID				:Numbers.firstProp(_item.price).key, 
			multiline		:false,
			wrap			:false,
			notChangePos	:true,
			iconDY			:2,
			bevelColor		:[0xcce8fa, 0x3b62c2],
			bgColor			:[0x65b7ef, 0x567ed0]
		})
		
		_bttn.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (!App.user.stock.checkAll(_item.price))
		{
			Locker.notEnoughOnStock(Numbers.firstProp(_item.price).key, false);
			return;
		}
		_model.fakefkickCallback(_item.sID, function():void{
			_settings.window.close();
		})
		
	}
	
	private function build():void{
		_titleLabel.x = (SIDE - _titleLabel.width) / 2;
		_titleLabel.y = -35;
		addChild(_bg);
		addImage();
		addChild(_titleLabel);
		
		_bttn.x = (SIDE - _bttn.width) / 2;
		_bttn.y = SIDE
		addChild(_bttn)
	}
	
	public function get SIDE():int { return _settings.side; }
	
}