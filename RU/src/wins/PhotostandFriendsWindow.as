package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Log;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import strings.Strings;
	import ui.FriendItem;
	import utils.InviteHelper;
	/**
	 * ...
	 * @author ...
	 */
	public class PhotostandFriendsWindow extends Window 
	{
		private var item:FriendItem;
		private var container:Sprite = new Sprite();
		private var items:Vector.<FriendItem>;
		public var target:*;
		public function PhotostandFriendsWindow(settings:Object=null) 
		{
			this.target = settings.target
			settings['background'] = "capsuleWindowBacking";
			settings['width'] = 445;
			settings['title'] = Locale.__e('flash:1500042763931');
			settings['height'] = 510;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x804118;
			settings['borderColor'] = 0x804118;
			settings['shadowColor'] = 0x804118;
			settings['fontSize'] = 52;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 2;
			settings['itemsOnPage'] = 8;
			settings["paginatorSettings"] = {buttonsCount: 3};
			settings['exitTexture'] = 'closeBttnMetal';
			super(settings);
			createContent();
		}
		
		private function createContent():void
		{
			this.settings['content'] = [];
			for each(var _friend:* in App.user.friends.data)
			{
				 
				if (_friend.uid == '1')
					continue;
				if ((App.user.socInvitesFrs.hasOwnProperty(_friend.uid) && App.user.socInvitesFrs[_friend.uid] == 1) || target.info.sID == 2000 || target.info.sID == 2256)
					this.settings['content'].push(_friend);
			}
			
		/*	for (var _sfriend:* in target.slots)
			{
				if (this.settings.content.indexOf(target.slots[_sfriend]) != -1)
				{
					//trace(_sfriend);
					this.settings.content.splice(this.settings.content.indexOf(target.slots[_sfriend]), 1);
				}
			}*/
			
			/*if (target.level == 1)
			{
				for (var _sfriend:* in target.slots)
				{
					for (var fr:* in settings.content){
						if (settings.content[fr].uid == target.slots[_sfriend])
							settings.content.splice(fr, 1);
					}
				}
			}
			else
			{*/
				for (var _sfriend:* in target.slots)
				{
					for each(var _frlvl:* in target.slots[_sfriend])
					{
						for (var fr:* in settings.content){
							if (settings.content[fr].uid == _frlvl)
								settings.content.splice(fr, 1);
						}
					}
				}
			//}
		}
		
		override public function drawBackground():void 
		{
			super.drawBackground();
			var back:Bitmap = Window.backing(settings.width - 70, settings.height - 70, 30, 'itemBacking');
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2;
			layer.addChild(back);
		}
		
		override public function drawBody():void 
		{
			var desc:TextField = drawText(Locale.__e('flash:1500451221814'), {
				fontSize		:28,
				color			:0xffffff,
				borderColor		:0x7f3d0e,
				textAlign		:"center",
				width			:325,
				wrap			:true
			});
			
			desc.y = 5;
			desc.x = (settings.width - desc.width) / 2;
			bodyContainer.addChild(desc);
			exit.y -= 20;
			
			var inviteBttn:Button = new Button({
				caption			:Locale.__e('flash:1425399901550'),
				width			:180,
				height			:50,
				fontSize		:30,
				hasDotes		:false
			});
		
			bodyContainer.addChild(inviteBttn);
			inviteBttn.x = (settings.width - inviteBttn.width) / 2;
			inviteBttn.y = settings.height - 63 - inviteBttn.height / 2;
			inviteBttn.addEventListener(MouseEvent.CLICK, inviteFriends);
			
			contentChange();
		}
		
		private function inviteFriends(e:MouseEvent):void 
		{
			InviteHelper.inviteOther();
		}
		
		public function sendPost(uid:*):void {
			var message:String = Strings.__e("FreebieWindow_sendPost", [Config.appUrl]);
			var bitmap:Bitmap = new Bitmap(Window.textures.iPlay, "auto", true);
			
			if (bitmap != null) {
				ExternalApi.apiWallPostEvent(ExternalApi.GIFT, bitmap, String(uid), message, 0, null, {url:Config.appUrl});// , App.ui.bottomPanel.removePostPreloader);
			}
		}
		
		public function clearItems():void 
		{
			for each(var _itm:* in items)
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
				item = new FriendItem(this.settings.content[i].uid, this, settings.window);
				container.addChild(item);
				items.push(item);
				item.x = X;
				item.y = Y;				
				X += item.bg.width + 23;
				if ((i+1) % 4 == 0)
				{
					X = 0;
					Y += item.height + 35;
				}
			}
			container.x = 85;
			container.y = 130;
			
			bodyContainer.addChild(container);
		}
		
		
		override public function drawArrows():void {

			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -0.5, scaleY:0.5 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:0.5, scaleY:0.5 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 + 140;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 146;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 96;
			paginator.arrowRight.y = y;
			
		}
		
	
		
	}
	

}
import buttons.Button;
import core.Post;
import flash.events.MouseEvent;
import wins.Window;
import core.AvaLoad;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.text.TextField;

internal class FriendItem extends LayerX
{
	private var window:*;
	public var friend:Object;
	public var uid:String;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap;
	private var addBttn:Button;
	public var bg:Shape;
	private var target:*
	private var mainWindow:*;
	public function FriendItem(uid:String, window:*, mainWindow:*)
	{
		this.target = window.target
		this.window = window;
		this.uid = uid;
		this.mainWindow = mainWindow;
		/*for each(var _uid:* in App.user.friends.data)
		{*/
			/*if (uid == _uid.uid)
			{*/
		friend = App.user.friends.data[uid];
		draw();
		addChild(addBttn);
				
			/*}
			else
				continue;*/
			
		/*}*/
		
		
	}
	
	private function draw():void
	{
		bg = new Shape();
		bg.graphics.beginFill(0xc0804d);
		bg.graphics.drawRoundRect(0, 0, 51, 51, 15, 15);
		addChild(bg);
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, 44, 44, 15, 15);
		shape.graphics.endFill();
		shape.x = (bg.width - shape.width) / 2;
		shape.y = (bg.height - shape.height) / 2;
		sprite.mask = shape;
		sprite.addChild(shape);
		
		new AvaLoad(friend.photo, onLoad);
		
		addChild(sprite);
		var params:Array = friend.aka.split(" ");
		
		var title:TextField = Window.drawText(params[0] + '\n' + params[1] ,{
			fontSize	:20,
			color		:0x804118,
			border		:false,
			textAlign	:'center',
			wrap		:true,
			textLeading	:-14,
			width		:85
		});
		
		title.x = bg.x + (bg.width - title.width) / 2;
		title.y = bg.y - title.height;
		addChild(title);
		
		addBttn = new Button({
			caption		:Locale.__e("flash:1382952379978"),
			fontSize	:18,
			color		:0x703f19,
			width		:70,
			height		:27
		});
		addBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];		
		addBttn.x = (bg.width - addBttn.width) / 2;
		addBttn.y = bg.x + bg.height + 3;
		addBttn.addEventListener(MouseEvent.CLICK, addEvent)
	}
	
	private function addEvent(e:*):void{
		Post.send( {
			ctr		:target.info.type,
			act		:'setfriend',
			slID	:this.window.settings.id,
			uID		:App.user.id,
			wID		:App.user.worldID,
			fID		:uid,
			sID		:target.sid,
			id		:target.id
		}, onAddEvent);
	}
	
	private function onAddEvent(error:*, data:*, params:*):void
	{
		if (error)
			return;
		if (!target.slots)
		{
			target.slots = new Object();
		}
		
		if (!target.slots[target.level])
		{
			target.slots[target.level] = {}
		}
		target.slots[target.level][this.window.settings.id] = uid;
		mainWindow.drawFriends();
		window.close();
		
	}
	
	private function onLoad(data:*):void {
		avatar = new Bitmap();
		avatar.bitmapData = data.bitmapData;
		Size.size(avatar, 45, 45);
		sprite.addChild(avatar);
		avatar.smoothing = true;
		avatar.x = sprite.x + (sprite.width - avatar.width) / 2;
		avatar.y = sprite.y + (sprite.height - avatar.height) / 2;
	}
	
}