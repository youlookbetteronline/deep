package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class PhotostandWindow extends Window
	{
		private var descText:TextField;
		private var rewBttn:Button;
		private var bg:Bitmap;
		private var image:Bitmap;
		private var bottomSprite:Sprite;
		private var friendsSprite:Sprite;
		private var friendBgSprite:Sprite;
		private var upperSprite:Sprite;
		private var mainSprite:Sprite = new Sprite();
		public var target:*;
		private var maskBg:Shape
		public function PhotostandWindow(settings:Object=null) 
		{
			this.target = settings.target;
			settings['title'] = target.info.title;
			settings['background'] = settings.background || "capsuleWindowBacking";
			settings['hasPaginator'] = false;
			settings['exitTexture'] = 'closeBttnMetal',	
			settings['width'] = 775;
			settings['height'] = 570;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] = 0x116011;
			settings['shadowColor'] = 0x116011;
			settings['fontSize'] = 42;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 2;
			super(settings);
			this.addEventListener(MouseEvent.CLICK, coordsCursor);
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
			exit.y -= 20;
			descText = Window.drawText(Locale.__e('flash:1500535428160'), {
				color		:0x804116,
				fontSize	:32,
				width		:550,
				border		:false,
				textAlign	:"center"
			});
			descText.x = (settings.width - descText.width) / 2;
			descText.y = 25;
			bodyContainer.addChild(descText);
			draw();
			
			
		}
		
		private function coordsCursor(e:*):void
		{
			trace('x: ' + (App.self.stage.mouseX - this.layer.x) + ' y: ' + (App.self.stage.mouseY - this.layer.y));
		}
		
		private function draw():void
		{
			
			bottomSprite = new Sprite();
			mainSprite.addChild(bottomSprite);
			friendsSprite = new Sprite();
			mainSprite.addChild(friendsSprite);
			upperSprite = new Sprite();
			mainSprite.addChild(upperSprite);
			friendBgSprite = new Sprite();
			mainSprite.addChild(friendBgSprite);
			
			maskBg = new Shape();
			maskBg.graphics.beginFill(0x000000, 1);
			maskBg.graphics.drawRoundRect(0, 0, 660, 405, 30, 30);
			maskBg.graphics.endFill();
			maskBg.x = (settings.width - maskBg.width) / 2;
			maskBg.y = 70;
			
			//mainSprite.filters = [new DropShadowFilter(4, 270, 0xe0a779, .8, 4, 4, 1, 1), new DropShadowFilter(3, 90, 0xe0a779, .8, 3, 3, 1, 1)];
				
			bodyContainer.addChild(maskBg);
			mainSprite.mask = maskBg;
			mainSprite.filters = [new DropShadowFilter(1, 90, 0xe0a779, 1, 4, 4, 4, 1, true), new DropShadowFilter(1, -90, 0xe0a779, .8, 4, 4, 4, 1, true), new DropShadowFilter(1, 90, 0, .3, 4, 4, 4, 1)];
			
			
			Load.loading(Config.getImage(target.info.type, 'PhotostendBg0', 'jpg'), onLoadBg);
			drawFriends();
			Load.loading(Config.getImage(target.info.type, target.info.levels[target.level].backview), onLoadImage);
		}
		
		private function onLoadBg(data:Bitmap):void
		{
			bg = new Bitmap();
			bg.bitmapData = data.bitmapData;
			Size.size(bg, 675, 430);
			bg.smoothing = true;
			bottomSprite.addChild(bg);
			bottomSprite.x = maskBg.x + (maskBg.width - bottomSprite.width) / 2;
			bottomSprite.y = maskBg.y + maskBg.height - bottomSprite.height;
		}
		
		private function onLoadImage(data:Bitmap):void
		{
			image = new Bitmap;
			image.bitmapData = data.bitmapData;
			
			upperSprite.addChild(image);
			upperSprite.x = maskBg.x;
			upperSprite.y = maskBg.y + maskBg.height - upperSprite.height;
			bodyContainer.addChild(mainSprite);
		}
		
		private function drawBttn(bttnState:Boolean):void
		{
			
			if (rewBttn && rewBttn.parent)
				rewBttn.parent.removeChild(rewBttn);
				
			rewBttn = new Button({
				caption		:Locale.__e('flash:1500041809543'),
				fontSize	:38,
				width		:230,
				height		:62
			});
			rewBttn.x = (settings.width - rewBttn.width) / 2;
			rewBttn.y = settings.height - rewBttn.height - 25;	
			bodyContainer.addChild(rewBttn);
			if(!bttnState)
				rewBttn.state = Button.DISABLED;
			rewBttn.addEventListener(MouseEvent.CLICK, storageEvent);
		}

		private function storageEvent(e:*):void{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			
			Post.send({
				ctr		:target.info.type,
				act		:'storage',
				uID		:App.user.id,
				wID		:App.user.worldID,
				sID		:target.sid,
				id		:target.id
			}, onStorageEvent);
			
		}
		
		private function onStorageEvent(error:*, data:*, params:*):void
		{
			if (error)
				return;
			
			if (data.hasOwnProperty("bonus")) {
				Treasures.bonus(data.bonus, new Point(target.x, target.y));
			}
			if (target.level == target.totalLevel)
				target.die = true;
			else
				target.level += 1;
			close();
		}
		
		private var items:Vector.<FriendItem> = new Vector.<FriendItem>();
		public function drawFriends():void
		{
			var bttnState:Boolean = false;
			clearItems();
			items = new Vector.<FriendItem>();
			var countSlots:int = Numbers.countProps(target.info.levels[target.level].slots)
			for (var i:int = 0; i < countSlots; i++ )
			{
				var item:FriendItem = new FriendItem(target.level, target.info.levels[target.level].slots[i + 1], settings.target, this, i + 1);
				item.x = target.info.levels[target.level].slots[i+1].x - target.info.levels[target.level].slots[i+1].width / 2;
				item.y = target.info.levels[target.level].slots[i + 1].y - target.info.levels[target.level].slots[i + 1].width;
				items.push(item);
				if (target.slots && target.slots[target.level] && target.slots[target.level].hasOwnProperty(i + 1))
					friendsSprite.addChild(item);
				else
					mainSprite.addChild(item);
			}
			if (target.slots && target.slots[target.level] && Numbers.countProps(target.slots[target.level]) == countSlots)
				bttnState = true;
			
			if(!target.die)
				drawBttn(bttnState);
		}
		
		public function clearItems():void
		{
			for each(var _itm:* in items)
			{
				if (_itm.parent)
					_itm.parent.removeChild(_itm);
			}
			
		}
		
	}

}
import buttons.ImageButton; 
import core.AvaLoad;
import core.Load;
import core.Numbers;
import core.Size;
import wins.PhotostandFriendsWindow;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;

internal class FriendItem extends Sprite {
	private var bg:Bitmap;
	private var avatar:Bitmap;
	private var bdata:String;
	private var diameter:int;
	private var bgBttn:ImageButton;
	private var slotID:int;
	private var window:*;
	private var pullSlots:Array = [];
	public function FriendItem(level:int, slot:*, target:*, window:*,slotID:int)
	{
		this.slotID = slotID;
		this.bdata = slot.image;
		this.diameter = slot.width;
		this.window = window;
				
		if (target.slots && target.slots[target.level] && target.slots[target.level].hasOwnProperty(slotID))
		{
			var friend:* = App.user.friends.data[target.slots[target.level][slotID]];
			if (!friend)
				friend = Numbers.firstProp(App.user.friends.data).val;
			new AvaLoad(friend.photo, function(data:*):void{
				avatar = new Bitmap();
				avatar.bitmapData = data.bitmapData;
				Size.size(avatar, 60, 60);
				if ((60 - diameter) < 9)
					avatar.scaleX = avatar.scaleY = 1.23;
				avatar.smoothing = true;
				addChild(avatar);
			});
		}
		else{
			Load.loading(Config.getImage('Photostand', bdata), function(data:*):void
			{
				bgBttn = new ImageButton(data.bitmapData);
				Size.size(bgBttn, diameter, diameter);
				addChild(bgBttn);
				bgBttn.addEventListener(MouseEvent.CLICK, addFriend);
			});
		}
	}
	
	
	private function addFriend(e:MouseEvent):void
	{
		new PhotostandFriendsWindow({
			id		:slotID,
			popup	:true,
			//content	:App.network.appFriends,
			target	:window.target,
			window	:window
		}).show();
		window.drawFriends();
	}
	

}