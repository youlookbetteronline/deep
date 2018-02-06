package wins 
{
	import api.SPApi;
	import buttons.Button;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import units.Monster;
	import units.Publicbox;
	/**
	 * ...
	 * @author ...
	 */
	public class LockMapWindow extends Window
	{
		private var contentSprite:Sprite = new Sprite();
		private var activeusers:Array;
		private var item:FriendItem;
		private var backDesc2:Shape;
		public function LockMapWindow(settings:Object = null) 
		{
			settings['title'] = Locale.__e('flash:1474469531767');
			settings['fontColor']		= 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] 	= 0x116011;
			settings['shadowColor']		= 0x116011;
			settings['fontSize'] 		= 42;
			settings['fontBorderSize'] 	= 3;
			settings['shadowSize'] 		= 2;
			settings['hasPaginator'] 	= false;
			settings['exitTexture'] 	= 'closeBttnMetal',	
			settings['width'] 			= 650;
			settings['height'] 			= 400;
			super(settings);
		}
		
		override public function drawBackground():void 
		{
			super.drawBackground();
			var back:Bitmap = Window.backing(settings.width - 70, settings.height - 70, 30, 'paperClear');
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2;
			layer.addChild(back);
		}
		
		override public function drawBody():void 
		{
			drawRibbon();
			titleLabel.y += 11;
			exit.y -= 30;
			
			var startBttn:Button = new Button({
				caption		:Locale.__e('flash:1393581021929'),
				fontSize	:38,
				width		:210,
				height		:56
			});
			startBttn.x = (settings.width - startBttn.width) / 2;
			startBttn.y = settings.height - startBttn.height - 25;	
			if (Connection.activeUsers && Connection.activeUsers.length > Publicbox.MAXPLAYERS)
				startBttn.state = Button.DISABLED;
			bodyContainer.addChild(startBttn);
			startBttn.addEventListener(MouseEvent.CLICK, onTake);
			
			backDesc2 = new Shape();
			backDesc2.graphics.beginFill(0xfceaaf);
			backDesc2.graphics.drawRect(0, 0, 500, 115)
			backDesc2.graphics.endFill();
			backDesc2.filters = [new BlurFilter(30, 0, 10)];
			backDesc2.x = (settings.width - backDesc2.width) / 2;
			backDesc2.y = 180;
			bodyContainer.addChild(backDesc2);
			
			drawContent();
			
			
		}
		
		private function drawContent():void 
		{
			activeusers = new Array();
			activeusers = Connection.activeUsers;
			
			var progressBacking:Bitmap = Window.backingShort(520, "backingSmall");
			contentSprite.addChild(progressBacking);
			
			var progressSlider:ProgressBar = new ProgressBar({win:this,typeLine:'sliderSmall', width:520, scale:1, isTimer:false});
			
			progressSlider.progress = activeusers.length/Publicbox.MAXPLAYERS;
			progressSlider.x = progressBacking.x - 16;
			progressSlider.y = progressBacking.y - 12;
			progressSlider.start();
			contentSprite.addChild(progressSlider);
			var offset:Number = 520 / Publicbox.MAXPLAYERS;
			var X:int = progressBacking.x + offset - 30;
			var Y:int = 0;
			
			for (var i:int = 0; i < Publicbox.MAXPLAYERS; i++)
			{
				var friend:* = {}
				if (activeusers[i] && activeusers[i] != "")
				{
					if (activeusers[i] == App.user.id)
						friend = App.user;
					else
						friend = App.user.friends.data[activeusers[i]];
					
				}
					
				
				item = new FriendItem(friend, i+1, this)
				contentSprite.addChild(item);
				item.x = X;
				item.y = Y;
				X += offset;
			}
			contentSprite.x = 60;
			contentSprite.y = 110;
			bodyContainer.addChild(contentSprite);
			
			var rewardText:String = Locale.__e('flash:1382952380000') + '\n';
			var probabilityText:String = Locale.__e('flash:1503303013283') + ' ';
			var probabilityArray:Array = new Array;
			var totalText:String;
			var pointText:String = ', ';
			var time:int = int(App.data.storage[App.user.worldID].duration/60)
			var descText2:TextField = Window.drawText(Locale.__e('flash:1503909245249', time), {
				color		:0x804116,
				fontSize	:28,
				width		:550,
				border		:false,
				wrap		:true,
				textAlign	:"center"
			});
			descText2.x = (settings.width - descText2.width) / 2;
			descText2.y = backDesc2.y + (backDesc2.height - descText2.height) / 2;
			bodyContainer.addChild(descText2);
		}
		
		private function onTake(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
			{
				Hints.text(Locale.__e('flash:1503386745572', Publicbox.MAXPLAYERS), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
				return;
			}
			Post.send( {
				ctr:  'world',
				act:  'pstart',
				uID:  App.owner.id,
				wID:  App.owner.worldID
			}, function(error:int, data:Object, params:Object):void {
				if (error) 
					return;
				App.user.data['publicWorlds'][App.owner.worldID] = data.expire;
				if (Monster.self)
				{
					Monster.self.settings.endLife = data.expire;
					Monster.self.startWalk();
				}
				var _objParams:Object = {
					expire :data.expire
				};
				Connection.sendMessage({
					u_event :'world_start', 
					aka  	:App.user.aka, 
					params 	:_objParams
				});
			});		
			Window.closeAll();
		}
		
	}

}
import buttons.ImageButton;
import core.AvaLoad;
import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import units.Publicbox;
import utils.SocketEventsHandler;
import wins.Window;
import wins.InviteSocketWindow;

internal class FriendItem extends LayerX
{
	private var friend:*;
	private var count:int;
	private var avatar:Bitmap;
	private var sprite:Sprite = new Sprite();
	private var bg:Shape;
	private var point:Bitmap;
	private var avatarBttn:ImageButton;
	private var window:*;
	public function FriendItem(friend:*, count:int, window:*)
	{
		this.friend = friend;
		this.count = count;
		this.window = window;
		point = new Bitmap(Window.textures.bluePoint);
		if (count != Publicbox.MAXPLAYERS)
			addChild(point);
		drawFriend();
		//drawChest();
		var aka:String;
		if (friend && friend.photo)
		{
			if (friend.hasOwnProperty('uid'))
				aka = (friend.uid == App.user.id)?friend.aka:SocketEventsHandler.personages[friend.uid].aka
			else if (friend.hasOwnProperty('id'))
				aka = (friend.id == App.user.id)?friend.aka:SocketEventsHandler.personages[friend.id].aka
			this.tip = function():Object
			{
				return {
					title	:aka
				}
			}
		}
	}
	
	private function drawFriend():void 
	{
		bg = new Shape();
		bg.graphics.beginFill(0xc0804d);
		bg.graphics.drawRoundRect(0, 0, 58, 58, 15, 15);
		bg.x = point.x - bg.width / 2;
		bg.y = point.y - bg.height - 10;
		addChild(bg);
		var photo:String;
		if (friend && friend.photo)
		{
			if (friend.hasOwnProperty('uid'))
				photo = (friend.uid == App.user.id)?App.user.photo:SocketEventsHandler.personages[friend.uid].photo
			else if (friend.hasOwnProperty('id'))
				photo = (friend.id == App.user.id)?App.user.photo:SocketEventsHandler.personages[friend.id].photo
			new AvaLoad(photo, onLoad);
		}
		else
			Load.loading(Config.getImage('avatars', 'ava_empty', 'jpg'), onEmptyLoad);
	}
	
	private function onLoad(data:*):void {
		avatar = new Bitmap();
		avatar.bitmapData = data.bitmapData;
		Size.size(avatar, 52, 52);
		avatar.smoothing = true;
		avatar.x = bg.x + (bg.width - avatar.width) / 2;
		avatar.y = bg.y + (bg.height - avatar.height) / 2;
		
		var maska:Shape = new Shape();
		maska.graphics.beginFill(0x000000, 1);
		maska.graphics.drawRoundRect(0, 0, 51, 51, 15, 15);
		maska.graphics.endFill();
		maska.x = bg.x + (bg.width - maska.width) / 2;
		maska.y = bg.y + (bg.height - maska.height) / 2;
		avatar.mask = maska;
		addChild(avatar);
		addChild(maska);
	}
	
	private function onEmptyLoad(data:*):void {
		avatarBttn = new ImageButton(data.bitmapData);
		Size.size(avatarBttn, 52, 52);
		avatarBttn.x = bg.x + (bg.width - avatarBttn.width) / 2;
		avatarBttn.y = bg.y + (bg.height - avatarBttn.height) / 2;
		addChild(avatarBttn);
		avatarBttn.addEventListener(MouseEvent.CLICK, onFriendInvite)
	}
	
	private function onFriendInvite(e:*):void 
	{
		if (App.user.id != App.owner.id)
			return;
		window.close();
		new InviteSocketWindow({}).show();
	}
	
	/*private function drawChest():void
	{
		var chest:Bitmap = new Bitmap(Window.textures.chestBox)
		chest.x = point.x + (point.width - chest.width) / 2;
		chest.y = point.y + point.height - 5;
		addChild(chest);
		
		var counter:TextField = Window.drawText('x'+count,{
			fontSize	:26,
			color		:0xffffff,
			borderColor	:0x6e411e,
			textAlign	:'center',
			wrap		:true,
			textLeading	:-14
		});
		counter.x = chest.x + chest.width - counter.width/2 - 8;
		counter.y = chest.y + chest.height - counter.textHeight - 5;
		if (count != 1)
			addChild(counter);
		
	}*/
}