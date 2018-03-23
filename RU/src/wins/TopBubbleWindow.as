package wins
{
	import buttons.ImageButton;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import utils.TopHelper;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TopBubbleWindow extends Window
	{
		private var _askButton:ImageButton;
		private var _expireContainer:Sprite = new Sprite();
		private var _description:TextField;
		private var _itemsContainer:Sprite = new Sprite();
		private var _items:Vector.<TopItem>;
		private var _item:TopItem;
		private var _ownerItem:TopItem;
		private var _ownerReplaceText:TextField;
		private var _leftTimeContainer:Sprite = new Sprite;
		private var _leftTimeText:TextField
		private var _leftTimeBack:Bitmap
		
		public function TopBubbleWindow(settings:Object = null)
		{
			settings = settingsInit(settings);
			super(settings);
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null)
			{
				settings = {};
			}
			
			settings["width"] 				= 580;
			settings["height"] 				= 580;
			settings['fontColor'] 			= 0x004762;
			settings['fontBorderColor'] 	= 0xffffff;
			settings['fontBorderSize'] 		= 4;
			settings['fontSize'] 			= 46;
			settings['exitTexture'] 		= 'blueClose';
			settings["hasPaper"] 			= false;
			settings["hasButtons"] 			= false;
			settings["paginatorSettings"] 	= {
				buttonPrev		:"bubbleArrow"
			};
			settings['itemsOnPage'] 		= 5;
			
			return settings;
		}
		
		override public function drawBackground():void
		{
			var background:Bitmap = backing4(settings.width, settings.height, 160, 'blueBackingSmallTL', 'blueBackingSmallTR', 'blueBackingSmallBL', 'blueBackingSmallBR');
			layer.addChild(background);
		}
		
		override public function drawBody():void
		{
			drawAskButton();
			drawLeftTime();
			drawDescription();
			contentChange();
			build();
		}
		
		private function drawAskButton():void 
		{
			_askButton = new ImageButton(Window.textures.blueAsk);
			_askButton.bitmap.smoothing = true;
			_askButton.addEventListener(MouseEvent.CLICK, onAskEvent)
			_askButton.tip = function():Object{
				return{
					title:Locale.__e('flash:1382952380254')
				}
			}
			
			_askButton.x = 35;
			_askButton.y = 0;
			bodyContainer.addChild(_askButton);
		}
		
		private function onAskEvent(e:MouseEvent):void 
		{
			close();
			var tbonus:* = settings.top.tbonus;
			var content:Array = []
			for (var iterator:* in tbonus.d)
			{
				content.push({
					placeFrom	: tbonus.s[iterator],
					placeTo		: tbonus.e[iterator],
					bonus		: tbonus.t[iterator]
				})
			}
			new TopInfoWindow({
				content:content,
				callback:function():void{
					TopHelper.showTopWindow(settings.sid);
				}
			}).show();
			/*new HintWindow({
				icons:[
					'Craft1',
					'Craft2',
					'Craft3',
				],
				descriptions:[
					Locale.__e("flash:1516965823931"),
					Locale.__e("flash:1516965859995"),
					Locale.__e("flash:1516965879734")
				],
				popup:true,
				callback:	function():void{
					TopHelper.showTopWindow(settings.sid);
				}
			}).show();*/
		}
		
		private function drawLeftTime():void 
		{
			_leftTimeBack = new Bitmap(Window.textures.popupBack)
			Size.size(_leftTimeBack, 128, 120)
			_leftTimeBack.smoothing = true;
			_leftTimeContainer.addChild(_leftTimeBack);
			
			
			var timeLeft:int = settings.top.expire.e - App.time;
			_leftTimeText = Window.drawText(Locale.__e('flash:1393581955601') + '\n' + TimeConverter.timeToDays(timeLeft),{
				fontSize		:32,
				color			:0xfff330,
				borderColor		:0x224076,
				borderSize		:3,
				textAlign		:'center',
				width:115
			})
			_leftTimeText.x = (_leftTimeBack.width - _leftTimeText.width) / 2;
			_leftTimeText.y = (_leftTimeBack.height - _leftTimeText.height) / 2;
			_leftTimeContainer.addChild(_leftTimeText)
			App.self.setOnTimer(expireTimer)
		}
		
		private function expireTimer():void 
		{
			var timeLeft:int = settings.top.expire.e - App.time;
			if (timeLeft < 0)
			{
				close();
				App.self.setOffTimer(expireTimer);
				return;
			}
			_leftTimeText.text = Locale.__e('flash:1393581955601') + '\n' + TimeConverter.timeToDays(timeLeft)
		}
		
		override public function contentChange():void 
		{
			disposeChilds(_items);
			if (_ownerReplaceText && _ownerReplaceText.parent)
				_ownerReplaceText.parent.removeChild(_ownerReplaceText);
			_items = new Vector.<TopItem>();
			var Y:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				_item = new TopItem({
					window	:this,
					item	:this.settings.content[i],
					index	:i,
					top		:settings.top
				});
				_itemsContainer.addChild(_item);
				_items.push(_item);
				_item.y = Y;			
				Y += _item.HEIGHT;
			}
			_itemsContainer.x = (settings.width - _itemsContainer.width) / 2;
			_itemsContainer.y = 117;
			bodyContainer.addChild(_itemsContainer);
			if (getOwnerIndex != -1)
			{
				if (getOwnerPage != paginator.page)
				{
					_ownerItem = new TopItem({
						window	:this,
						item	:this.settings.content[getOwnerIndex],
						index	:getOwnerIndex,
						owner	:true,
						top		:settings.top
					})
					_items.push(_ownerItem);
					
					_ownerItem.x = (settings.width - _ownerItem.width) / 2;
					_ownerItem.y = _itemsContainer.y + _itemsContainer.height - 5;
					bodyContainer.addChild(_ownerItem)
				}
				else
				{
					_ownerReplaceText = Window.drawText(Locale.__e('flash:1519837258520'),{
						color			:0xffffff,
						borderColor		:0x004762,
						borderSize		:4,
						fontSize		:26,
						width			:520,
						textAlign		:'center',
						multiline		:true,
						wrap			:true
					});
					_ownerReplaceText.x = (settings.width - _ownerReplaceText.width) / 2;
					_ownerReplaceText.y = _itemsContainer.y + _itemsContainer.height;
					bodyContainer.addChild(_ownerReplaceText)
				}
				
			}
		}
		
		private function get getOwnerIndex():int
		{
			var index:int = -1;
			for (var usr:* in settings.content)
			{
				if (settings.content[usr]._id && settings.content[usr]._id == App.user.id)
					return usr;
			}
			return index;
		}
		
		private function get getOwnerPage():int
		{
			var page:int = int(getOwnerIndex / settings['itemsOnPage'])
			return page;
		}
		
		private function drawDescription():void 
		{
			_description = Window.drawText(settings.description, {
				color			:0xffffff,
				borderColor		:0x004762,
				borderSize		:4,
				fontSize		:26,
				width			:520,
				textAlign		:'center',
				multiline		:true,
				wrap			:true
			})
		}
		
		override public function drawArrows():void 
		{
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 20;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 30;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width / 2 + 14;
			paginator.arrowRight.y = y;
		}
		
		private function build():void
		{
			exit.x -= 10;
			exit.y += 15;
			
			titleLabel.y += 35;
			
			_description.x = (settings.width - _description.width) / 2;
			_description.y = 55;
			
			bodyContainer.addChild(_description);
			
			_leftTimeContainer.x = 30;
			_leftTimeContainer.y = -100;
			bodyContainer.addChild(_leftTimeContainer);
		}
	
	}

}
import core.AvaLoad;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import flash.text.TextField;
import ui.UserInterface;
import wins.TopBubbleWindow;
import wins.Window;

internal class TopItem extends LayerX
{	
	private var _settings:Object = {
		width	:550,
		height	:67
	}
	private var _user:Object;
	private var _owner:Boolean = false;
	private var _window:TopBubbleWindow;
	private var _index:int;
	private var _background:Shape;
	private var _avatar:Bitmap;
	private var _name:TextField
	private var _pointText:TextField
	private var _pointBitmap:Bitmap
	private var _pointSprite:Sprite = new Sprite();
	private var _numberText:TextField
	private var _numberBitmap:Bitmap
	private var _numberSprite:Sprite = new Sprite();
	
	public function TopItem(settings:Object = null)
	{
		_user = settings.item;
		_window = settings.window;
		_index = settings.index;
		if (settings.owner)
			_owner = true;
		for (var property:* in settings)
			_settings[property] = settings[property];
		if (_owner)
		{
			_settings.bgColor = 0xd2d896;
			_settings.color = 0x673d1d
			_settings.borderColor = 0x6e411e;
			_settings.bitmapPoints = 'cupYellowIcon'
		}
		else
		{
			_settings.borderColor = 0x004762;
			_settings.bitmapPoints = 'cupIcon'
			if ((_index + 1) % 2 == 0)
			{
				_settings.bgColor = 0x86cde1;
				_settings.color = 0x004762
			}
			else
			{
				_settings.bgColor = 0x14789f;
				_settings.color = 0xffffff
			}
		}
		drawBackground();
		drawNumber();
		drawAvatar();
		drawName();
		drawPoint();
		
		build();	

	}
	
	private function drawBackground():void 
	{
		_background = new Shape();
		_background.graphics.beginFill(_settings.bgColor, .9);
		_background.graphics.drawRect(0,0,_settings.width - 70, _settings.height)
		_background.graphics.endFill();
		_background.filters = [new BlurFilter(50, 0)];
	}
	
	private function drawNumber():void 
	{
		var number:int = _index + 1;
		switch (number){
			case 1:
				_numberBitmap = new Bitmap(Window.textures.firstPlaceIcon)
				_numberSprite.addChild(_numberBitmap);
				break;
			case 2:
				_numberBitmap = new Bitmap(Window.textures.secondPlaceIcon)
				_numberSprite.addChild(_numberBitmap);
				break;
			case 3:
				_numberBitmap = new Bitmap(Window.textures.thirdPlaceIcon)
				_numberSprite.addChild(_numberBitmap);
				break;
			default:
				_numberText = Window.drawText(String(number), {
					color			:0xffffff,
					borderColor		:_settings.borderColor,
					fontSize		:36,
					width			:60,
					textAlign		:'center'
				})
				_numberText.y += 6;
				_numberSprite.addChild(_numberText);
		}
	}
	
	private function drawAvatar():void 
	{
		new AvaLoad(_user.photo, onAvaLoad)
	}
	
	private function onAvaLoad(data:Bitmap):void 
	{
		_avatar = Size.rectBorderBitmap(data);
		_avatar.x = 100;
		_avatar.y = (HEIGHT - _avatar.height) / 2;
		addChild(_avatar);
		
		var levelSprite:Sprite = new Sprite();
		var expIco:Bitmap = new Bitmap(UserInterface.textures.expIco);
		Size.size(expIco, 30, 30);
		expIco.smoothing = true;
		expIco.filters = [new GlowFilter(0xffffff, 1, 2, 2, 4, 4)];
		levelSprite.addChild(expIco);
		var expText:TextField = Window.drawText(_user.level,{
			color			:0x804218,
			border			:false,
			fontSize		:20,
			width			:30,
			textAlign		:'center'
		})
		expText.x = expIco.x + (expIco.width - expText.width) / 2 + 1;
		expText.y = expIco.y + (expIco.height - expText.textHeight) / 2 + 2;
		levelSprite.addChild(expText);
		
		levelSprite.x = _avatar.x + _avatar.width - levelSprite.width / 2;
		levelSprite.y = _avatar.y + _avatar.height - levelSprite.height;
		
		addChild(levelSprite);
		
	}
	
	private function drawName():void 
	{
		var nameText:String = _user.aka;
		var nameVector:Array = nameText.split(' ');
		_name = Window.drawText(nameVector[0] + '\n' + nameVector[1], {
			color			:_settings.color,
			border			:false,
			fontSize		:26,
			width			:130,
			textAlign		:'center'
		})
		
	}
	
	private function drawPoint():void 
	{
		var pointString:String = String(_user.points)
		_pointBitmap = new Bitmap(Window.textures[_settings.bitmapPoints]);
		if (_settings.top.hasOwnProperty('astime') && _settings.top.astime)
			pointString = TimeConverter.timeToDays(_user.points)
		_pointText = Window.drawText(pointString, {
			color			:0xffe84b,
			borderColor		:_settings.borderColor,
			fontSize		:30,
			width			:100,
			textAlign		:'center'
		})
		_pointText.x = _pointBitmap.x + _pointBitmap.width + 5;
		_pointSprite.addChild(_pointBitmap);
		_pointSprite.addChild(_pointText);
	}
	
	private function build():void 
	{
		_background.x = 2;
		_background.y = (_settings.height - _background.height) / 2;
		addChild(_background);
		
		_numberSprite.y = (HEIGHT - _numberSprite.height) / 2;
		_numberSprite.x = 10;
		addChild(_numberSprite);
		
		_name.y = (HEIGHT - _name.textHeight) / 2;
		_name.x = 210;
		addChild(_name);
		
		_pointSprite.y = _name.y + (_name.height - _pointSprite.height) / 2;
		_pointSprite.x = 345;
		addChild(_pointSprite);
	}
	
	public function get HEIGHT():int
	{
		return _settings.height;
	}
}