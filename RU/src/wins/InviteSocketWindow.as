package wins
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import ui.FriendItem;
	import utils.InviteHelper;
	
	public class InviteSocketWindow extends Window
	{
		public var target:*;
		
		private var item:FriendItem;
		private var container:Sprite = new Sprite();
		private var items:Vector.<FriendItem>;
		
		public function InviteSocketWindow(settings:Object = null)
		{
			this.target = settings.target
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
			settings['itemsOnPage'] = 18;
			settings["paginatorSettings"] = {buttonsCount: 3};
			settings['exitTexture'] = 'closeBttnMetal';
			super(settings);
			createContent();
		}
		
		override public function drawTitle():void
		{
			titleLabel = titleText({title: settings.title, color: settings.fontColor, multiline: settings.multiline, fontSize: 42, textLeading: settings.textLeading, borderColor: settings.fontBorderColor, borderSize: 3, shadowSize: 1, shadowColor: settings.fontBorderColor, shadowBorderColor: settings.shadowBorderColor || settings.fontColor, width: settings.width - settings.titlePading, textAlign: 'center', sharpness: 50, thickness: 50, border: true})
			
			drawRibbon();
			titleLabel.y += 15;
			titleBackingBmap.y += 5;
		}
		
		override public function drawExit():void
		{
			super.drawExit();
			exit.x -= 11;
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
		
		override public function drawArrows():void
		{
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT, 0, 0, {scaleX: -1, scaleY: 1});
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, {scaleX: 1, scaleY: 1});
			
			var y:Number = 253;
			paginator.arrowLeft.x = -paginator.arrowLeft.width / 2 + 64;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width / 2;
			paginator.arrowRight.y = y;
			
			paginator.y += 10;
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
			
			var background:Shape = new Shape();
			background.graphics.beginFill(0xf0e9e0, .7);
			background.graphics.drawRect(0, 0, 460, 400);
			background.y = 79;
			background.x = separator.x;
			background.graphics.endFill();
			background.filters = [new BlurFilter(10, 0, 4)];
			
			var separator2:Bitmap = Window.backingShort(460, "dividerLine");
			separator2.x = (settings.width - separator2.width) / 2;
			separator2.y = 475;
			
			bodyContainer.addChild(background);
			bodyContainer.addChild(separator);
			bodyContainer.addChild(separator2);
			
			var inviteBttn:Button = new Button({caption: Locale.__e('flash:1425399901550'), width: 200, height: 57, fontSize: 30, hasDotes: false});
			
			bodyContainer.addChild(inviteBttn);
			inviteBttn.x = (settings.width - inviteBttn.width) / 2;
			inviteBttn.y = settings.height - 49 - inviteBttn.height / 2;
			inviteBttn.addEventListener(MouseEvent.CLICK, inviteFriends);
			
			contentChange();
		}
		
		public function clearItems():void
		{
			for each (var _itm:* in items)
			{
				if (_itm.parent)
					_itm.parent.removeChild(_itm);
			}
		}
		
		override public function contentChange():void
		{
			clearItems();
			items = new Vector.<FriendItem>();
			var X:int = 0;
			var Y:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				item = new FriendItem(this.settings.content[i], this, settings.window);
				container.addChild(item);
				items.push(item);
				item.x = X;
				item.y = Y;
				X += item.bg.width + 18;
				if ((i + 1) % 6 == 0)
				{
					X = 0;
					Y += item.height + 7;
				}
			}
			container.x = 51;
			container.y = 125;
			
			bodyContainer.addChild(container);
		}
		
		private function createContent():void
		{
			this.settings['content'] = [];
			for each (var _friend:* in App.network.appFriends)
			{
				if (_friend == '1')
					continue;
				if (App.user.friends.data[_friend].hasOwnProperty('pinvite'))
				{
					var _str:String = App.user.id + '_' + String(App.user.worldID);
					if (App.user.friends.data[_friend].pinvite.hasOwnProperty(_str) && App.user.friends.data[_friend].pinvite[_str].hasOwnProperty('pid') && App.user.friends.data[_friend].pinvite[_str].pid == App.owner.world.data.pid)
						continue;
				}
				this.settings['content'].push(_friend);
			}
		
		/*for (var _sfriend:* in target.slots)
		   {
		   if (this.settings.content.indexOf(target.slots[_sfriend]) != -1)
		   {
		   //trace(_sfriend);
		   this.settings.content.splice(this.settings.content.indexOf(target.slots[_sfriend]), 1);
		   }
		   }*/
		}
		
		private function inviteFriends(e:MouseEvent):void
		{
			InviteHelper.inviteOther();
		}
	}
}

import buttons.Button;
import core.AvaLoad;
import core.Post;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextField;
import wins.Window;

internal class FriendItem extends LayerX
{
	public var friend:Object;
	public var uid:String;
	public var bg:Shape;
	
	private var window:*;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap;
	private var addBttn:Button;
	private var target:*;
	private var mainWindow:*;
	
	public function FriendItem(uid:String, window:*, mainWindow:*)
	{
		this.target = window.target;
		this.window = window;
		this.uid = uid;
		this.mainWindow = mainWindow;
		friend = App.user.friends.data[uid];
		draw();
		addChild(addBttn);
	}
	
	private function draw():void
	{
		/*if(!uid){
		   if (this.parent)
		   this.parent.removeChild(this);
		   return;
		   }*/
		bg = new Shape();
		bg.graphics.beginFill(0xc0804d);
		bg.graphics.drawRoundRect(0, 0, 61, 61, 15, 15);
		addChild(bg);
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, 55, 55, 12, 12);
		shape.graphics.endFill();
		shape.x = (bg.width - shape.width) / 2;
		shape.y = (bg.height - shape.height) / 2;
		sprite.mask = shape;
		sprite.addChild(shape);
		
		new AvaLoad(friend.photo, onLoad);
		
		addChild(sprite);
		var params:Array = friend.aka.split(" ");
		
		var title:TextField = Window.drawText(params[0] + '\n' + params[1], {fontSize: 20, color: 0x73370f, border: false, textAlign: 'center', wrap: true, multiline: true, textLeading: -8, width: 85});
		
		title.x = bg.x + (bg.width - title.width) / 2;
		title.y = bg.y - title.height + 5;
		addChild(title);
		
		addBttn = new Button({caption: Locale.__e("flash:1382952379978"), fontSize: 18, radius: 15, color: 0x703f19, width: 70, height: 27});
		addBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
		addBttn.x = (bg.width - addBttn.width) / 2 - 2;
		addBttn.y = bg.x + bg.height - 3;
		addBttn.addEventListener(MouseEvent.CLICK, addEvent);
	}
	
	private function addEvent(e:*):void
	{
		//Notify.inviteToMap(uid, null, Locale.__e('flash:1502982188301', [App.data.storage[App.user.worldID].title]));
		//return;
		//App.user
		//App.owner.world
		if (window.settings.content)
		{
			if (window.settings.content.indexOf(uid) != -1)
			{
				window.settings.content.splice(window.settings.content.indexOf(uid), 1);
				window.createPaginator();
				window.drawArrows();
				window.contentChange();
			}
		}
		if (App.user.friends.data[uid].hasOwnProperty('pinvite'))
		{
			var _str:String = App.user.id + '_' + String(App.user.worldID);
			if (App.user.friends.data[uid].pinvite.hasOwnProperty(_str))
				return;
		}
		Post.send({ctr: 'World', act: 'pinvite', uID: App.user.id, wID: App.user.worldID, pID: App.owner.world.data.pid, fID: uid}, onAddEvent);
	}
	
	private function onAddEvent(error:*, data:*, params:*):void
	{
		if (error)
		{
			Errors.show(error, data);
			return;
		}
		
		if (!App.user.friends.data[uid].hasOwnProperty('pinvite'))
			App.user.friends.data[uid]['pinvite'] = {};
		
		var _str:String = App.user.id + '_' + String(App.user.worldID);
		App.user.friends.data[uid].pinvite[_str] = data.expire;
		
		Notify.inviteToMap(uid, null, Locale.__e('flash:1502982188301', [App.data.storage[App.user.worldID].title]));
		//trace();
		//App.user
		//if (!target.slots)
		//target.slots = new Object();
		//target.slots[this.window.settings.id] = uid;
		//mainWindow.drawFriends();
		//window.close();
	}
	
	private function onLoad(data:*):void
	{
		avatar = new Bitmap();
		avatar.bitmapData = data.bitmapData;
		avatar.scaleX = avatar.scaleY = 1.25;
		Size.size(avatar, 61, 61);
		sprite.addChild(avatar);
		avatar.smoothing = true;
		avatar.x = sprite.x + (sprite.width - avatar.width) / 2;
		avatar.y = sprite.y + (sprite.height - avatar.height) / 2;
	}
}