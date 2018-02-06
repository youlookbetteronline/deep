package wins
{
	import buttons.Button;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import utils.InviteHelper;
	
	public class FriendsSocketWindow extends Window
	{
		private var item:FriendInviteItem;
		private var container:Sprite = new Sprite();
		private var items:Vector.<FriendInviteItem>;
		
		public function FriendsSocketWindow(settings:Object = null)
		{
			//this.target = settings.target
			settings['background'] = "capsuleWindowBacking";
			settings['width'] = 560;
			settings['title'] = Locale.__e('flash:1500455096741');
			settings['height'] = 600;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x085c10;
			settings['borderColor'] = 0x085c10;
			settings['shadowColor'] = 0x085c10;
			settings['fontSize'] = 52;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 2;
			settings['itemsOnPage'] = 6;
			settings["paginatorSettings"] = {buttonsCount: 3};
			settings['exitTexture'] = 'closeBttnMetal';
			super(settings);
			checkUsers();
		}
		
		override public function drawExit():void
		{
			super.drawExit();
			exit.x -= 11;
		}
		
		override public function drawTitle():void
		{
			titleLabel = titleText({title: settings.title, color: settings.fontColor, multiline: settings.multiline, fontSize: 42, textLeading: settings.textLeading, borderColor: settings.fontBorderColor, borderSize: 3, shadowSize: 1, shadowColor: settings.fontBorderColor, shadowBorderColor: settings.shadowBorderColor || settings.fontColor, width: settings.width - settings.titlePading, textAlign: 'center', sharpness: 50, thickness: 50, border: true})
			
			drawRibbon();
			titleLabel.y += 15;
			titleBackingBmap.y += 5;
		}
		
		override public function drawBackground():void
		{
			drawMirrowObjs('decSeaweedWithBubbles', settings.width + 56, -56, settings.height - 267, true, true, false, 1, 1, layer);
			super.drawBackground();
			var back:Bitmap = Window.backing(settings.width - 60, settings.height - 60, 30, 'itemBackingPaper');
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2;
			layer.addChild(back);
		}
		
		override public function drawBody():void
		{
			var desc:TextField = drawText(Locale.__e('flash:1500454904916'), {fontSize: 31, color: 0x73370f, borderSize: 0, textAlign: "center"});
			
			desc.height = desc.textHeight + 5;
			desc.width = desc.textWidth + 5;
			desc.y = 37;
			desc.x = (settings.width - desc.width) / 2;
			bodyContainer.addChild(desc);
			exit.y -= 20;
			
			var separator:Bitmap = Window.backingShort(460, "dividerLine");
			separator.x = (settings.width - separator.width) / 2;
			separator.y = 79;
			
			//var background:Shape = new Shape();
			//background.graphics.beginFill(0xf0e9e0, .7);
			//background.graphics.drawRect(0, 0, 460, 400);
			//background.y = 79;
			//background.x = separator.x;
			//background.graphics.endFill();
			//background.filters = [new BlurFilter(10, 0, 4)];
			//bodyContainer.addChild(background);
			
			var separator2:Bitmap = Window.backingShort(460, "dividerLine");
			separator2.x = (settings.width - separator2.width) / 2;
			separator2.y = 478;
			
			bodyContainer.addChild(separator);
			bodyContainer.addChild(separator2);
			
			var inviteBttn:Button = new Button({caption: Locale.__e('flash:1425399901550'), width: 200, height: 57, fontSize: 30, hasDotes: false});
			bodyContainer.addChild(inviteBttn);
			inviteBttn.x = (settings.width - inviteBttn.width) / 2;
			inviteBttn.y = settings.height - 49 - inviteBttn.height / 2;
			inviteBttn.addEventListener(MouseEvent.CLICK, inviteFriends);
			
			contentChange();
		}
		
		override public function contentChange():void
		{
			clearItems();
			items = new Vector.<FriendInviteItem>();
			var X:int = 0;
			var Y:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
					item = new FriendInviteItem(this.settings.content[i], this);
					container.addChild(item);
					items.push(item);
					item.x = X;
					item.y = Y;
					Y += item.background.height + 5;
					/*if ((i+1) % 8 == 0)
					   {
					   X = 0;
					   Y += item.height + 13;
					   }*/
			}
			container.x = 51;
			container.y = 89;
			
			bodyContainer.addChild(container);
		}
		
		override public function drawArrows():void
		{
			paginator.drawArrow(bodyContainer, Paginator.LEFT, 0, 0, {scaleX: -1, scaleY: 1});
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, {scaleX: 1, scaleY: 1});
			
			var y:Number = 253;
			paginator.arrowLeft.x = -paginator.arrowLeft.width / 2 + 63;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width / 2;
			paginator.arrowRight.y = y;
			
			paginator.y += 10;
		}
		
		public function clearItems():void
		{
			for each (var _itm:* in items)
			{
				if (_itm.parent)
					_itm.parent.removeChild(_itm);
			}
		}
		
		private function checkUsers(e:* = null):void
		{
			var friends:Array = [];
			if (!App.user.data.user.hasOwnProperty('pinvite'))
				return;
			
			for (var _chanel:* in App.user.data.user.pinvite)
			{
				//if (_friend == '1')
				//continue;
				//var _chanel:String = _friend + '_' + User.SOCKET_MAP;
				if (App.user.data.user.pinvite[_chanel].expire != 0 && App.user.data.user.pinvite[_chanel].expire < App.time)
					continue;
				
				friends.push(_chanel);
			}
			
			Post.send({ctr: 'user', act: 'chanusers', uID: App.user.id, channels: JSON.stringify(friends)}, function(e:int, data:Object, params:Object):void
			{
				if (e)
				{
					Errors.show(e, data);
					return;
				}
				createContent(data);
				//trace(data)
				//_chat = new ChatModel(data.token, settings);
			});
		}
		
		private function createContent(_data:Object):void
		{
			if (!_data.hasOwnProperty('presence'))
				return;
			this.settings['content'] = [];
			for each (var _chan:* in _data.presence)
			{
				var fObject:Object = _chan[0].body
				var _uid:String = fObject.channel;
				var ss:int = _uid.search('_' + User.SOCKET_MAP);
				
				_uid = _uid.slice(0, ss);
				fObject['uid'] = _uid;
				fObject['count'] = Numbers.countProps(fObject.data);
				if (App.user.data.friends.hasOwnProperty(_uid))
					this.settings['content'].push(fObject);
			}
			settings.content.sortOn('count', Array.NUMERIC | Array.DESCENDING);
			createPaginator();
			drawArrows();
			contentChange();
		}
		
		private function inviteFriends(e:MouseEvent):void
		{
			InviteHelper.inviteOther();
		}
	}
}

import buttons.Button;
import core.AvaLoad;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.text.TextField;
import wins.Window;

internal class FriendInviteItem extends LayerX
{
	public var friend:Object;
	public var uid:String;
	public var bg:Shape;
	public var background:Shape;
	public var data:Object;
	
	private var window:*;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap;
	private var addBttn:Button;
	
	public function FriendInviteItem(_params:Object, window:*)
	{
		this.window = window;
		this.uid = _params['uid'];
		this.data = _params['data'];
		friend = App.user.friends.data[this.uid];
		draw();
		addChild(addBttn);
	}
	
	private function draw():void
	{
		var _color:uint = 0xffffff;
		if (App.user.mode == User.PUBLIC && App.owner && App.owner.id == uid)
			_color = 0xffff00;
		background = new Shape();
		background.graphics.beginFill(_color, .4);
		background.graphics.drawRect(0, 0, 460, 60);
		addChild(background);
		background.filters = [new BlurFilter(10, 0)];
		
		bg = new Shape();
		bg.graphics.beginFill(0xc0804d);
		bg.graphics.drawRoundRect(0, 0, 51, 51, 15, 15);
		addChild(bg);
		bg.x = background.x + 30;
		bg.y = background.y + (background.height - bg.height) / 2;
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, 44, 44, 12, 12);
		shape.graphics.endFill();
		shape.x = (bg.width - shape.width) / 2;
		shape.y = (bg.height - shape.height) / 2;
		sprite.mask = shape;
		sprite.addChild(shape);
		sprite.x = bg.x + 0;
		sprite.y = bg.y + 0;
		
		new AvaLoad(friend.photo, onLoad);
		
		addChild(sprite);
		var params:Array = friend.aka.split(" ");
		
		var title:TextField = Window.drawText(params[0] + '\n' + params[1], {fontSize: 20, color: 0x804118, border: false, textAlign: 'center', wrap: true, width: 85});
		title.height = title.textHeight + 5;
		title.x = bg.x + bg.width + 5;
		title.y = bg.y + (bg.height - title.height) / 2 + 2;
		addChild(title);
		
		var countText:TextField = Window.drawText(String(Numbers.countProps(data)) + ' / ' + String(Connection.MAX_USERS), {fontSize: 36, color: 0x804118, border: false, textAlign: 'center', wrap: true, textLeading: -14, width: 85});
		countText.height = countText.textHeight + 5;
		countText.x = bg.x + 150;
		countText.y = bg.y + (bg.height - countText.height) / 2;
		addChild(countText);
		
		addBttn = new Button({caption: Locale.__e("flash:1394010224398"), fontSize: 22, color: 0x703f19, width: 100, height: 40});
		//addBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];		
		addBttn.x = background.x + background.width - addBttn.width - 30;
		addBttn.y = background.y + (background.height - addBttn.height) / 2 - 2;
		addBttn.addEventListener(MouseEvent.CLICK, addEvent)
		checkBttnState();
	}
	
	private function checkBttnState():void
	{
		if (!addBttn)
			return;
		var _maxUsers:int = Connection.MAX_USERS - 1;
		for each (var _player:* in data)
		{
			if (_player.user == uid)
			{
				_maxUsers = Connection.MAX_USERS;
				break;
			}
		}
		if ((App.user.mode == User.PUBLIC && App.owner && App.owner.id == uid) || (Numbers.countProps(data) >= _maxUsers))
			addBttn.state = Button.DISABLED;
	}
	
	private function addEvent(e:*):void
	{
		if (e.currentTarget.mode == Button.DISABLED)
			return;
		if (App.user.data.friends.hasOwnProperty(uid))
		{
			Travel.friend = App.user.data.friends[uid];
			Travel.onVisitEvent(User.SOCKET_MAP);
		}
	}
	
	private function onLoad(data:*):void
	{
		avatar = new Bitmap();
		avatar.bitmapData = data.bitmapData;
		Size.size(avatar, 45, 45);
		sprite.addChild(avatar);
		avatar.smoothing = true;
		avatar.x = (bg.width - avatar.width) / 2;
		avatar.y = (bg.height - avatar.height) / 2;
	}
}