package wins 
{
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import models.PostmanModel;
	import units.Postman;
	/**
	 * ...
	 * @author ...
	 */
	public class PostmanSendWindow extends Window 
	{
		private var _target:Postman;
		private var _model:PostmanModel;
		private var _description:TextField;
		private var _bubbleBg:Bitmap;
		private var _friend:Friend;
		private var _friendsContainer:Sprite = new Sprite();
		private var _friends:Vector.<Friend>;
		private var _giftsContainer:LayerX = new LayerX();
		private var _giftsBack:Bitmap
		private var _giftsIcon:Bitmap
		private var _giftsCount:TextField
		public function PostmanSendWindow(settings:Object=null) 
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
			settings["width"]				= 495;
			drawDescription();
			settings["height"] 				= 405 + _description.textHeight;
			settings['fontColor'] 			= 0x004762;
			settings['fontBorderColor'] 	= 0xffffff;
			settings['fontBorderSize']		= 4;
			settings['fontSize'] 			= 40;
			settings['exitTexture'] 		= 'blueClose';
			settings['title'] 				= _target.info.title;
			settings['content'] 			= _model.sendFriends;
			settings['itemsOnPage'] 		= 10;
			settings["paginatorSettings"] 	= {
				buttonsCount	:3, 
				itemsOnPage		:10,
				buttonPrev		:"bubbleArrow"
				
			};
			
			return settings;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing4(settings.width, settings.height, 160, 'blueBackingTL', 'blueBackingTR', 'blueBackingBL', 'blueBackingBR');
			layer.addChild(background);	
		}
		
		override public function drawBody():void 
		{
			drawBubbleBg();
			contentChange();
			drawGifts();
			build();
		}
		
		override public function contentChange():void 
		{
			for each(var item:* in _friends){
				item.parent.removeChild(item);
				item = null;
			}
			_friends = new Vector.<Friend>
			var Y:int = 0;
			var X:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				_friend = new Friend({
					friend	:settings.content[i],
					model	:_model
				});
				_friend.x = X;
				_friend.y = Y;
				_friendsContainer.addChild(_friend)
				_friends.push(_friend);
				X += 81;
				if ((i + 1) % 5 == 0)
				{
					X = 0;
					Y += 115;
				}
			}
		}
		
		private function drawDescription():void
		{
			_description = Window.drawText(Locale.__e("flash:1517584529889", App.data.storage[_model.mtake.sid].title),{
				color			:0xffffff,
				borderColor		:0x004762,
				borderSize		:4,
				fontSize		:28,
				width			:420,
				textAlign		:'center',
				wrap			:true,
				multiline		:true
			})
		}
		
		private function drawGifts():void 
		{
			_giftsBack = new Bitmap(Window.textures.bubbleBackingBig)
			Size.size(_giftsBack, 70, 70);
			_giftsBack.smoothing = true;
			
			_giftsContainer.addChild(_giftsBack);
			
			_giftsContainer.y = -87;
			_giftsContainer.x = settings.width - 120;
			bodyContainer.addChild(_giftsContainer)
			
			_giftsContainer.tip = function():Object{
				return{
					title	:App.data.storage[_model.mtake.sid].title,
					text	:Locale.__e('flash:1521105052667') + String(App.user.stock.count(_model.mtake.sid)) + Locale.__e('flash:flash:1382952379974')
				}
			}
			
			Load.loading(Config.getIcon(App.data.storage[_model.mtake.sid].type, App.data.storage[_model.mtake.sid].preview), onIconLoad)
		}
		
		private function onIconLoad(data:Bitmap):void 
		{
			_giftsIcon = new Bitmap(data.bitmapData);
			Size.size(_giftsIcon, 30, 30)
			_giftsIcon.smoothing = true;
			_giftsIcon.y = _giftsBack.y + (_giftsBack.height - _giftsIcon.height) / 2;
			_giftsIcon.x = _giftsBack.x + 7;
			_giftsContainer.addChild(_giftsIcon);
			
			_giftsCount = Window.drawText(String(App.user.stock.count(_model.mtake.sid)),{
				color			:0xfffffe,
				borderColor		:0x004762,
				borderSize		:4,
				fontSize		:28,
				width			:420,
				textAlign		:'left',
				wrap			:true,
				multiline		:true
			})
			
			_giftsCount.x = _giftsIcon.x + _giftsIcon.width + 2;
			_giftsCount.y = _giftsBack.y + (_giftsBack.height - _giftsCount.textHeight) / 2;
			_giftsContainer.addChild(_giftsCount)
			
		}
		
		private function drawBubbleBg():void 
		{
			_bubbleBg = backing(440, 260, 46, 'blueLightBacking');
			_bubbleBg.x = (settings.width - _bubbleBg.width) / 2;
			_bubbleBg.y = settings.height - _bubbleBg.height - 95;
			bodyContainer.addChild(_bubbleBg);
		}
		
		override public function drawArrows():void 
		{
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 50;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 10;
			paginator.arrowRight.y = y;
		}
		
		private function build():void 
		{
			exit.x -= 10;
			exit.y += 15;
			
			titleLabel.y += 35;
			
			paginator.y += 25;
			
			_description.x = (settings.width - _description.width) / 2;
			_description.y = 42;
			
			_friendsContainer.x = 55
			_friendsContainer.y = _bubbleBg.y + 35;
			
			bodyContainer.addChild(_description);
			bodyContainer.addChild(_friendsContainer);
		}
	}

}
import buttons.Button;
import buttons.ImageButton;
import core.AvaLoad;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import models.PostmanModel;
import ui.Hints;
import wins.Window;
import wins.BubbleInputWindow;
import wins.BubbleSimpleWindow;
import wins.SimpleWindow;

internal class Friend extends LayerX
{
	private var _avatarContainer:Sprite = new Sprite();
	private var _name:String;
	private var _title:TextField;
	private var _background:Bitmap;
	private var _avatar:Bitmap;
	private var _bttn:Button;
	private var _back:Bitmap;
	private var _model:PostmanModel;
	
	private var _settings:Object = {
		width	:425,
		height	:90
	};
	
	public function Friend(settings:Object)
	{
		_model = settings.model;
		for (var property:* in settings)
		{
			_settings[property] = settings[property]
		}
		drawAvatar();
		drawButton();
	}
	
	private function drawAvatar():void 
	{
		_back = Window.backing(56, 56, 19, 'blueWhiteMask')
		_avatarContainer.addChild(_back)
		var aka:Object = {
			firstname:	_settings.friend.aka.split(" ")[0],
			lastname:	_settings.friend.aka.split(" ")[1]
		}
		_title = Window.drawText(aka.firstname + '\n' + aka.lastname, {
			fontSize	:16,
			color		:0x004762,
			borderColor	:0xfffffe,
			textAlign	:'center',
			autoSize	:'center',
			textLeading	:-8,
			width		:56,
			height		:35
		})
		_title.x = _back.x + (_back.width - _title.width) / 2;
		_title.y = _back.y - _title.textHeight / 2 - 5;
		
		addChild(_avatarContainer);
		new AvaLoad(_settings.friend.photo, function(data:Bitmap):void{
			_avatar = new Bitmap();
			_avatar.mask = maska
			_avatar.bitmapData = data.bitmapData;
			Size.size(_avatar, 66, 66);
			_avatarContainer.addChild(_avatar);
			_avatar.smoothing = true;
			_avatar.x = _back.x + (_back.width - _avatar.width) / 2;
			_avatar.y = _back.y + (_back.height - _avatar.height) / 2;
			
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
	
	private function drawButton():void 
	{
		_bttn = new Button({
			caption			:Locale.__e('flash:1382952380118'),
			fontColor		:0xffffff,
			width			:74,
			height			:30,
			fontSize		:18,
			bgColor			:[0xfed131, 0xf8ab1a],
			bevelColor		:[0xf7fe9a, 0xcb6b1e],
			fontBorderColor	:0x6e411e
			})
		_bttn.x = _back.x + (_back.width - _bttn.width) / 2;
		_bttn.y = _back.y + _back.height - 3
		addChild(_bttn);
		
		_bttn.addEventListener(MouseEvent.CLICK, onClick)
		if (App.user.stock.count(_model.mtake.sid) < _model.mtake.count)
			_bttn.state = Button.DISABLED;
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (_model.friends[_settings.friend.uid].post >= _model.limit)
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
			Hints.text(Locale.__e('flash:1517844853393', App.data.storage[_model.mtake.sid].title), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
			return;
		}
		new BubbleInputWindow({
			title		:Locale.__e('flash:1517330407319'),
			maxLength	:65,
			popup		:true,
			confirm		:onSendAction
		}).show();
	}
	
	private function onSendAction(text:String):void 
	{
		_model.sendCallback(text, _settings.friend.uid, sendCallback)
	}
	
	private function sendCallback():void 
	{
		Window.closeAll();
		var item:BonusItem = new BonusItem(_model.mtake.sid, _model.mtake.count);
		item.cashMove(new Point(App.self.stage.mouseX, App.self.stage.mouseY), App.self.windowContainer, true);
	}
}
