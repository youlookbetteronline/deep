package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.adobe.images.BitString;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import models.PostmanModel;
	import units.Postman;
	/**
	 * ...
	 * @author ...
	 */
	public class PostmanGetWindow extends Window 
	{
		private var _target:Postman;
		private var _model:PostmanModel;
		private var _friend:Friend;
		private var _friends:Vector.<Friend>;
		private var _friendsContainer:Sprite = new Sprite();
		private var _askButton:ImageButton;
		private var _sendBttn:Button;
		private var _popupContainer:LayerX = new LayerX();
		private var _popupBack:Bitmap;
		private var _popupText:TextField;
		public function PostmanGetWindow(settings:Object=null) 
		{
			_model = settings.model;
			_target = settings.target;
			
			settings = settingsInit(settings);
			super(settings);
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			
			settings['content'] 			= parseContent;
			settings["width"]				= 580;
			settings["height"] 				= 520;
			if (settings.content.length < 4)
			{
				var tempCount:int = settings.content.length == 0?1:settings.content.length
				settings["height"] = 234 + (tempCount - 1) * 96;
				if (settings.height < 320)
					settings.height = 320
			}
			settings['fontColor'] 			= 0x004762;
			settings['fontBorderColor'] 	= 0xffffff;
			settings['fontBorderSize']		= 4;
			settings['fontSize'] 			= 40;
			settings['exitTexture'] 		= 'blueClose';
			settings['title'] 				= _target.info.title;
			settings['itemsOnPage'] 		= 4;
			settings["paginatorSettings"] 	= {
				buttonsCount	:3, 
				itemsOnPage		:3,
				buttonPrev		:"bubbleArrow"
				
			};
			
			return settings;
		}
		
		private function get parseContent():Array 
		{
			var result:Array = [];
			for (var _post:* in _model.post)
			{
				var obj:Object = {};
				obj['postID'] = _post;
				obj['messageID'] =  _model.post[_post].msg;
				obj['friendID'] = _model.post[_post].fID;
				result.push(obj);
			}
			return result;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing4(settings.width, settings.height, 160, 'blueBackingTL', 'blueBackingTR', 'blueBackingBL', 'blueBackingBR');
			layer.addChild(background);	
		}
		
		override public function drawBody():void 
		{
			contentChange();
			build();
		}
		
		override public function contentChange():void 
		{
			settings.content = parseContent;
			paginator.itemsCount = settings.content.length;
			paginator.update();
			drawPopup();
			for each(var item:* in _friends){
				item.parent.removeChild(item);
				item = null;
			}
			_friends = new Vector.<Friend>
			var Y:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				_friend = new Friend({
					giftSid	:_model.msend.sid,
					model	:_model,
					friend	:settings.content[i].friendID,
					message	:settings.content[i].messageID,
					post	:settings.content[i].postID,
					window	:this
				});
				_friend.y = Y;
				_friendsContainer.addChild(_friend)
				_friends.push(_friend);
				Y += 95;
			}
			
		}
		
		private function drawPopup():void 
		{
			if (_popupBack && _popupBack.parent)
				_popupBack.parent.removeChild(_popupBack);
			if (_popupText && _popupText.parent)
				_popupText.parent.removeChild(_popupText);
			_popupBack = new Bitmap(Window.textures.popupBack)
			Size.size(_popupBack, 140, 100);
			_popupBack.smoothing = true;
			_popupContainer.addChild(_popupBack);
			
			_popupText = Window.drawText(Locale.__e('flash:1382952379798')+':'+ '\n' + String(settings.content.length) + '/'+String(_model.limit),{
				fontSize	:26,
				color		:0xffe55d,
				borderColor	:0x0a4961,
				textAlign	:'center',
				autoSize	:'center',
				textLeading	:-8,
				width		:120
			})
			
			_popupText.x = _popupBack.x + (_popupBack.width - _popupText.width) / 2;
			_popupText.y = _popupBack.y + (_popupBack.height - _popupText.height) / 2;
			_popupContainer.addChild(_popupText);
			
			_popupContainer.x = settings.width - 130;
			_popupContainer.y = -100;
			bodyContainer.addChild(_popupContainer);
			
			_popupContainer.tip = function():Object{
				return {
					title: Locale.__e('flash:1518014530739', _model.limit)
				}
			}
		}
		
		override public function drawArrows():void 
		{
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 20;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 40;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2;
			paginator.arrowRight.y = y;
		}
		
		
		private function build():void 
		{
			exit.x -= 10;
			exit.y += 15;
			
			titleLabel.y += 35;
			
			paginator.y += 25;
			_friendsContainer.x = (settings.width - _friendsContainer.width) / 2;
			_friendsContainer.y = 50;
			
			bodyContainer.addChild(_friendsContainer);
		}
		
	}

}
import api.HVApi;
import buttons.Button;
import buttons.ImageButton;
import core.AvaLoad;
import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import models.PostmanModel;
import ui.Hints;
import wins.Window;
import wins.BubbleSimpleWindow;
import wins.BubbleInputWindow;
import flash.text.TextField;

internal class Friend extends LayerX
{
	private var _avatarContainer:Sprite = new Sprite();
	private var _name:String;
	private var _title:TextField;
	private var _background:Bitmap;
	private var _avatar:Bitmap;
	private var _icon:Bitmap;
	private var _message:TextField;
	private var _bttn:ImageButton;
	private var _repplyBttn:Button;
	private var _friend:*;
	private var _model:PostmanModel;
	private var _janeProfile:*;
	
	private var _settings:Object = {
		width	:525,
		height	:90
	};
	
	public function Friend(settings:Object)
	{
		for (var property:* in settings)
		{
			_settings[property] = settings[property]
		}
		this._janeProfile = App.user.friends.data['1'];
		this._friend = App.user.friends.data[_settings.friend]
		this._name = _friend?_friend.aka.split(" ")[0]:_janeProfile.aka.split(" ")[0];
		this._model = _settings.model
		drawBackground();
		drawAvatar();
		drawIcon();
		drawMessage();
		drawButton();
		trace();
	}
	
	private function drawBackground():void 
	{
		_background = Window.backing(_settings.width, _settings.height, 46, "blueLightBacking")
		addChild(_background);
	}
	
	private function drawAvatar():void 
	{
		var back:Bitmap = Window.backing(56, 56, 19, 'blueWhiteMask')
		_avatarContainer.addChild(back)
		
		
		_title = Window.drawText(_name, {
			fontSize	:20,
			color		:0x004762,
			borderColor	:0xfffffe,
			textAlign	:'center',
			autoSize	:'center',
			textLeading	:-8,
			width		:56,
			height		:27
		})
		_title.x = back.x + (back.width - _title.width) / 2;
		_title.y = back.y + back.height - _title.textHeight / 2;
		
		
		_avatarContainer.y = (_background.height - _avatarContainer.height) / 2;
		_avatarContainer.x = 20;
		addChild(_avatarContainer);
		new AvaLoad(_friend?_friend.photo:_janeProfile.photo, function(data:Bitmap):void{
			_avatar = new Bitmap();
			_avatar.mask = maska
			_avatar.bitmapData = data.bitmapData;
			Size.size(_avatar, 66, 66);
			_avatarContainer.addChild(_avatar);
			_avatar.smoothing = true;
			_avatar.x = back.x + (back.width - _avatar.width) / 2;
			_avatar.y = back.y + (back.height - _avatar.height) / 2;
			
			var maska:Shape = new Shape();
			maska.graphics.beginFill(0xffffff, 1);
			maska.graphics.drawRoundRect(0, 0, 50, 50, 22, 22)
			maska.graphics.endFill()
			maska.x = _avatar.x + (_avatar.width - maska.width) / 2;
			maska.y = _avatar.y + (_avatar.height - maska.height) / 2;
			_avatarContainer.addChild(maska)
			_avatar.mask = maska;
			
			_avatarContainer.addChild(_title)
		});
		
	}
	
	private function drawIcon():void 
	{
		Load.loading(Config.getIcon(App.data.storage[_settings.giftSid].type, App.data.storage[_settings.giftSid].view), function(data:Bitmap):void{
			_icon = new Bitmap(data.bitmapData);
			Size.size(_icon, 65, 65)
			_icon.smoothing = true;
			_icon.x = _avatarContainer.x + _avatarContainer.width + 15;
			_icon.y = (_background.height - _icon.height) / 2;
			_icon.filters = [new GlowFilter(0xffffff, 1, 2, 2, 4, 4)]
			addChild(_icon)
		})
	}
	
	private function drawMessage():void 
	{
		_message = Window.drawText(_settings.message,{
			fontSize	:20,
			color		:0x004762,
			borderColor	:0xfffffe,
			textAlign	:'center',
			multiline	:true,
			wrap		:true,
			//textLeading	:-8,
			width		:170
		})
		_message.x = _avatarContainer.x + _avatarContainer.width + 95;
		_message.y = (_background.height - _message.height) / 2;
		addChild(_message)
	}
	
	private function drawButton():void 
	{
		_bttn = new ImageButton(Window.textures.presentIcon)
		Size.size(_bttn, 60, 60);
		_bttn.bitmap.smoothing = true;
		_bttn.x = _background.x + _background.width - 165;
		_bttn.y = _background.y + (_background.height - _bttn.height) / 2;
		addChild(_bttn);
		_bttn.startBlink();
		_bttn.tip = function():Object{
			return {
				title: Locale.__e('flash:1517410242462')
			}
		}
		
		_repplyBttn = new Button({
			caption			:Locale.__e('flash:1382972712784'),
			fontColor		:0xffffff,
			width			:86,
			height			:46,
			fontSize		:18,
			textAlign		:'center',
			bgColor			:[0xfed131, 0xf8ab1a],
			bevelColor		:[0xf7fe9a, 0xcb6b1e],
			fontBorderColor	:0x6e411e
		})
		
		_repplyBttn.x = _bttn.x + _repplyBttn.width - 20;
		_repplyBttn.y = _background.y + (_background.height - _repplyBttn.height) / 2;
		addChild(_repplyBttn);
		
		_bttn.addEventListener(MouseEvent.CLICK, takeEvent)
		_repplyBttn.addEventListener(MouseEvent.CLICK, repplyEvent)
		
		if (App.user.stock.count(_model.mtake.sid) < _model.mtake.count || !_friend)
			_repplyBttn.state = Button.DISABLED;
	}
	
	private function takeEvent(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED)
			return;
		_model.takeCallback(_settings.post, onTakeEvent)
		e.currentTarget.state = Button.DISABLED
	}
	
	private function onTakeEvent():void 
	{
		_bttn.mode = Button.NORMAL
		if (Numbers.countProps(_model.post) == 0)
			Window.closeAll();
		else
			_settings.window.contentChange();
	}
	
	private function repplyEvent(e:MouseEvent):void 
	{
		if (_model.friends[_settings.friend].post >= _model.limit)
		{
			new BubbleSimpleWindow({
				popup	:true,
				title	:Locale.__e('flash:1474469531767'),
				label	:Locale.__e('flash:1406275629192')
			}).show();
			return;
		}
		
		if (e.currentTarget.mode == Button.DISABLED)
		{
			if (!_friend)
				return;
			Hints.text(Locale.__e('flash:1517844853393', App.data.storage[_model.mtake.sid].title), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
			return;
		}
		
		new BubbleInputWindow({
			title		:Locale.__e('flash:1517330407319'),
			maxLength	:65,
			popup		:true,
			confirm		:onRepplyAction
		}).show();
	}
	
	private function onRepplyAction(text:String):void 
	{
		_model.sendCallback(text, _settings.friend, sendCallback)
	}
	
	private function sendCallback():void 
	{
		Window.closeAll();
		var item:BonusItem = new BonusItem(_model.mtake.sid, _model.mtake.count);
		item.cashMove(new Point(App.self.stage.mouseX, App.self.stage.mouseY), App.self.windowContainer, true);
	}
}