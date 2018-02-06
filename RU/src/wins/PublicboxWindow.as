package wins 
{
	import api.SPApi;
	import buttons.Button;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import units.Publicbox;
	/**
	 * ...
	 * @author ...
	 */
	public class PublicboxWindow extends Window
	{
		private var contentSprite:Sprite = new Sprite();
		private var activeusers:Array;
		private var item:PublicboxItem;
		private var backDesc2:Shape;
		public function PublicboxWindow(settings:Object = null) 
		{
			settings['title'] = settings.target.info.title;
			settings['fontColor']		= 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] 	= 0x116011;
			settings['shadowColor']		= 0x116011;
			settings['fontSize'] 		= 42;
			settings['fontBorderSize'] 	= 3;
			settings['shadowSize'] 		= 2;
			settings['hasPaginator'] 	= false;
			settings['exitTexture'] 	= 'closeBttnMetal',	
			settings['width'] 			= 750;
			settings['height'] 			= 500;
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
			var backDesc:Shape = new Shape();
			backDesc.graphics.beginFill(0xfceaaf);
			backDesc.graphics.drawRect(0, 0, 500, 65)
			backDesc.graphics.endFill();
			backDesc.filters = [new BlurFilter(30, 0, 10)];
			backDesc.x = (settings.width - backDesc.width) / 2;
			backDesc.y = 27;
			bodyContainer.addChild(backDesc);
			var descText:TextField = Window.drawText(settings.target.info.text1/*Locale.__e('flash:1500535428160')*/, {
				color		:0x804116,
				fontSize	:32,
				width		:430,
				border		:false,
				wrap		:true,
				textAlign	:"center"
			});
			descText.x = (settings.width - descText.width) / 2;
			descText.y = backDesc.y + (backDesc.height - descText.height) / 2 + 3;
			bodyContainer.addChild(descText);
			
			var rewBttn:Button = new Button({
				caption		:Locale.__e('flash:1382952379737'),
				fontSize	:38,
				width		:210,
				height		:56
			});
			rewBttn.x = (settings.width - rewBttn.width) / 2;
			rewBttn.y = settings.height - rewBttn.height - 25;	
			if (Connection.activeUsers && Connection.activeUsers.length > Publicbox.MAXPLAYERS)
				rewBttn.state = Button.DISABLED;
			bodyContainer.addChild(rewBttn);
			rewBttn.addEventListener(MouseEvent.CLICK, onTake);
			
			backDesc2 = new Shape();
			backDesc2.graphics.beginFill(0xfceaaf);
			backDesc2.graphics.drawRect(0, 0, 550, 115)
			backDesc2.graphics.endFill();
			backDesc2.filters = [new BlurFilter(30, 0, 10)];
			backDesc2.x = (settings.width - backDesc2.width) / 2;
			backDesc2.y = 295;
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
			
			progressSlider.progress = activeusers.length/Numbers.countProps(settings.target.info.reward);
			progressSlider.x = progressBacking.x - 16;
			progressSlider.y = progressBacking.y - 12;
			progressSlider.start();
			contentSprite.addChild(progressSlider);
			var offset:Number = 520 / Numbers.countProps(settings.target.info.reward);
			var X:int = progressBacking.x + offset - 30;
			var Y:int = 0;
			
			for (var i:int = 0; i < Numbers.countProps(settings.target.info.reward); i++)
			{
				var friend:* = {}
				if (activeusers[i] && activeusers[i] != "")
					friend = App.user.friends.data[activeusers[i]];
				item = new PublicboxItem(friend, Numbers.getProp(settings.target.info.reward, i).key, Numbers.getProp(settings.target.info.reward, i).val, settings.target, this)
				contentSprite.addChild(item);
				item.x = X;
				item.y = Y;
				X += offset;
			}
			contentSprite.x = 105;
			contentSprite.y = 190;
			bodyContainer.addChild(contentSprite);
			
			var rewardText:String = Locale.__e('flash:1382952380000') + '\n';
			var probabilityText:String = Locale.__e('flash:1503303013283') + ' ';
			var probabilityArray:Array = new Array;
			var totalText:String;
			var pointText:String = ', ';
			for (var _itm:* in currentTreasure.item)
			{
				if (_itm == currentTreasure.item.length - 1)
					pointText = '.'
					
				if (currentTreasure.probability[_itm] == 100)
					rewardText += App.data.storage[currentTreasure.item[_itm]].title + pointText
				else
				{
					probabilityText += App.data.storage[currentTreasure.item[_itm]].title + pointText
					probabilityArray.push(currentTreasure.item[_itm]);
				}
			}
			if (probabilityArray.length > 0)
				totalText = rewardText + probabilityText;
			else
				totalText = rewardText;
				
			var descText2:TextField = Window.drawText(totalText, {
				color		:0x804116,
				fontSize	:32,
				width		:550,
				border		:false,
				wrap		:true,
				textAlign	:"center"
			});
			descText2.x = (settings.width - descText2.width) / 2;
			descText2.y = backDesc2.y + (backDesc2.height - descText2.height) / 2;
			bodyContainer.addChild(descText2);
		}
		
		public function get currentTreasure():Object
		{
			var _treas:* = settings.target.info.reward[activeusers.length]
			return App.data.treasures[_treas][_treas]
		}
		
		private function onTake(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
			{
				Hints.text(Locale.__e('flash:1503386745572', Publicbox.MAXPLAYERS), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
				return;
			}
			Window.closeAll();
			settings.target.storageEvent();
			
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
import utils.SocketEventsHandler;
import wins.Window;
import wins.InviteSocketWindow;

internal class PublicboxItem extends LayerX
{
	private var friend:*;
	private var count:int;
	private var target:*;
	private var treasure:String;
	private var avatar:Bitmap;
	private var sprite:Sprite = new Sprite();
	private var bg:Shape;
	private var point:Bitmap;
	private var avatarBttn:ImageButton;
	private var window:*;
	public function PublicboxItem(friend:*, count:int, treasure:String, target:*, window:*)
	{
		this.friend = friend;
		this.count = count;
		this.treasure = treasure;
		this.target = target;
		this.window = window;
		point = new Bitmap(Window.textures.bluePoint);
		if (count != Numbers.countProps(target.info.reward))
			addChild(point);
		drawFriend();
		drawChest();
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
		window.close();
		new InviteSocketWindow({}).show();
	}
	
	private function drawChest():void
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
		
	}
}