package ui 
{
	/**
	 * ...
	 * @author 
	 */
	
	import core.AvaLoad;
	import core.Load;
	import core.Log;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Timer;
	import silin.filters.ColorAdjust;
	import ui.UserInterface;
	import wins.GiftItemWindow;
	import wins.Window;
	import wins.WorldsWindow;

	public class FriendItem extends LayerX {
	
		public var sprite:Sprite = new Sprite();
		public var avatar:Bitmap = new Bitmap(null, "auto", true);
		public var legs:Bitmap = new Bitmap(UserInterface.textures.legs);
		public var zzz:Bitmap = new Bitmap();
		public var friend:Object;	
		public var w:uint = 0;
		public var h:uint = 0;
		public var px:Number = 0;	
		public var type:String;	
		public var friendsBackingBmp:Bitmap;
		public var friendsPanel:*;
		public var uid:String;
		
		public function FriendItem(panel:*, friend:Object = null, type:String = 'default'):void 
		{
			this.friend = friend;
			this.type = type;
			this.friendsPanel = panel;
			
			if(friend != null && friend.hasOwnProperty('uid'))
				uid = friend.uid;
				
			friendsBackingBmp = new Bitmap(UserInterface.textures.friendsBacking);
			addChild(friendsBackingBmp);
			
			if (friend != null)
			{
				var first_Name:String = friend.first_name || "";
				if (friend.first_name && friend.first_name.length > 0 && friend.first_name != 'User')
					first_Name = friend.first_name;
				else if (friend.aka && friend.aka.length > 0) {
					first_Name = friend.aka;
				}
				
				if (friend.uid == "1") 
				{
					first_Name = friend.first_name;
				}
				
				if (friend['lastvisit'] % 2 == 0)
				{ 
					zzz = new Bitmap(UserInterface.textures.smallCoinIconPl);
				}
				else
				{
					zzz = new Bitmap(UserInterface.textures.smallEnergyIconPl);
				}
				if (App.isSocial('OK'))
				{
					zzz = new Bitmap(UserInterface.textures.interSleepIco);
				}
				
				var params:Array = first_Name.split(" ");
				if (params.length > 0)
					first_Name = params[0];
				//Log.alert('this_should_be_displayed - ' + first_Name + ' |||| ' + first_Name.substr(0, 15));
				//Log.alert(first_Name);
				var size:Point = new Point(friendsBackingBmp.width + 5, 30);
				var pos:Point = new Point(
					(width - size.x) / 2 - 3,
					 -size.y / 2 - 2
				 );
				
				var name:TextField = Window.drawTextX(first_Name, size.x, size.y, pos.x, pos.y, this, {
				//var name:TextField = Window.drawText(first_Name.substr(0, 15), App.self.userNameSettings( {
					fontSize:18,
					color:0xffffff,
					borderColor:0x0c4065,
					autoSize:"center",
					textAlign:"center",
					multiline:true
				});
				
				addChild(sprite);
				sprite.x = 0;
				sprite.y = 0;
				sprite.addChild(avatar);
				addChild(name);
				
				//name.visible = false;
				//name.wordWrap = true;
				//name.width = friendsBackingBmp.width + 6;
				//name.x = (width - name.width) / 2 - 3;
				//name.y = -10;
				//name.border = true;
				
				var star:Bitmap = new Bitmap(Window.textures.star);
				addChild(star);
				star.scaleX = star.scaleY = 0.8; 
				star.smoothing = true;
				star.x = width - star.width - 4;
				star.y = height - star.height - 10;
				
				var level:TextField = Window.drawText(String(friend.level || 0), {
					fontSize:16,
					color:0xFFFFFF,
					borderColor:0x704f1a,
					autoSize:"left",
					multiline:true
				});
				
				addChild(level);
				level.x = star.x + star.width / 2 - level.width / 2;
				level.y = star.y + 5;
				
				if (friend["photo"] != undefined)
				{
					//if (friend.aka == 'Александра Лапчук')
						new AvaLoad(friend.photo, onLoad);
				}
				
				addChild(zzz);
				zzz.visible = false;
				zzz.y = star.y - zzz.height/2;
				zzz.x = 0;
				
				addChild(legs);
				legs.visible = false;
				legs.y = star.y + 6;
				legs.x = 3;
				legs.filters = [new GlowFilter(0xd8c5a6, 1, 2, 2, 5, 1)];
				
				if (friend['visited'] != undefined && friend.visited > App.midnight) {
					legs.visible = true;
				}
				if ((friend['lastvisit'] != undefined && friend.lastvisit < (App.time-App.data.options['LastVisitDays']))&&friend.uid!='1' )
				
				{
					zzz.visible = true;	
					
					if (!App.isSocial('VK','OK','FS','MM','DM','FB','NK')) 
					{
						zzz.visible = false;	
					}				
				}			
			}
			else
			{
				var bubbleGroup:Bitmap = new Bitmap(Window.textures.bubbleGroup);
				bubbleGroup.x += 23;
				bubbleGroup.y += 8;
				addChild(bubbleGroup);
				
				friendsBackingBmp.bitmapData = UserInterface.textures.friendsAddBacking;
				friendsBackingBmp.x = 8;
				var user_txt:TextField = Window.drawText(Locale.__e('flash:1481644888055'), {
					fontSize		:16,
					color			:0xffffff,
					borderColor		:0x065477,
					autoSize:"center",
					width			:50,
					wrap			:true,
					multiline		:true,
					textAlign		:'center'
				});
				user_txt.x = 15;
				user_txt.y += 30;
			
				//addChild(user_txt);
				//var textLabel:String = Locale.__e('flash:1382952379777');
				//if(type == 'manage'){
					//textLabel = Locale.__e('flash:1382952379778');
				//}
				//var text:TextField = Window.drawText(textLabel, {
					//fontSize:17,
					//color:0xfceecf,
					//borderColor:0xbba275,
					//textAlign:"center",
					//autoSize:"center",
					//textLeading:-6,
					//multiline:true
				//});
				//text.wordWrap = true;
				//text.width = friendsBackingBmp.width;
				//text.height = text.textHeight+2;
				//text.x = friendsBackingBmp.x;
				//text.y = 26;
				
				//var container:Sprite = new Sprite();
				//addChild(container);
				//container.addChild(text);
			}
			
			w = this.width;
			h = this.height;
			
			addEventListener(MouseEvent.MOUSE_OVER, onOverEvent);
			addEventListener(MouseEvent.MOUSE_OUT, onOutEvent);
			addEventListener(MouseEvent.CLICK, onClick);
			
			mouseChildren = false;
			
			var that:FriendItem = this;
			tip = function():Object {
				if (type == 'manage') {
					return {
						title: Locale.__e('flash:1382952379779')
					};
				}
				
				return {
					title: that.friend != null ? Locale.__e('flash:1382952379780') : Locale.__e('flash:1382952379781')
				};
			}
		}
		

		private function onOverEvent(e:MouseEvent):void 
		{
			for each(var item:FriendItem in friendsPanel.friendsItems) 
			{
				item.friendsBackingBmp.filters = [];
			}
			
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(1);
			mtrx.brightness(0.1);
			friendsBackingBmp.filters = [mtrx.filter];
			if (avatar != null) avatar.filters = [mtrx.filter];
			
			if(!App.user.quests.tutorial)
				friendsPanel.wishList.show(this);
		}
		
		private function onOutEvent(e:MouseEvent):void 
		{
			for each(var item:FriendItem in friendsPanel.friendsItems)
			{
				item.friendsBackingBmp.filters = [];
				if(avatar != null) avatar.filters = [];
			}
			friendsPanel.wishList.hide();
		}
		
		
		private function onClick(e:MouseEvent):void 
		{
			if (QuestsRules.cantPress(this))
				return;
				
			if (e.currentTarget.friend == null)
				return;
			
			if (e.currentTarget.friend.uid == '1')
			{
				friendsPanel.onVisitEvent(e.currentTarget, User.HOME_WORLD);
				return;
			}
			/*if (App.social == 'FB')
			{
				if (e.currentTarget.friend != null)
					friendsPanel.onVisitEvent(e.currentTarget, User.HOME_WORLD);
				return;
			}*/
			var worldsWhereEnable:Array = [User.HOLIDAY_LOCATION, User.HOME_WORLD];
			
			new WorldsWindow( {
				title		:Locale.__e('flash:1491899660691'),
				sID			:null,
				only		:worldsWhereEnable,
				popup		:true,
				callback	:friendsPanel.onVisitEvent,
				target		:e.currentTarget,
				user		:e.currentTarget.friend
			}).show();
			//if (e.currentTarget.friend != null)
				//friendsPanel.onVisitEvent(e.currentTarget, User.HOME_WORLD);
		}
		
		private function onLoad(data:*):void
		{
				if (data is Bitmap)
				{
					avatar.bitmapData = data.bitmapData;
					avatar.scaleX = avatar.scaleY = 1.2;
					avatar.smoothing = true;
					//avatar.visible = false;
				}	
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0x000000, 1);
				shape.graphics.drawRoundRect(4, 4, 56, 56, 32, 32);
				shape.graphics.endFill();
				shape.filters = [new BlurFilter(2, 2)];
				//shape.alpha = .5;
				shape.cacheAsBitmap = true;
				sprite.mask = shape;
				sprite.cacheAsBitmap = true;
				sprite.addChild(shape);
		}	
	}

}