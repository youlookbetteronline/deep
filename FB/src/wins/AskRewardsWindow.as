package wins 
{
	import api.ExternalApi;
	import flash.display.Bitmap;
	import flash.text.TextField;
	import wins.elements.SearchFriendsPanel;
	/**
	 * ...
	 * @author 
	 */
	public class AskRewardsWindow extends AskWindow 
	{
		
		public function AskRewardsWindow(mode:int, settings:Object=null, callBack:Function=null) 
		{
			super(mode, settings, callBack);
			settings.itemsMode = GiftWindow.FRIENDS;
			
		}
		
		override public function contentChange():void {

			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			
			var X:int = 47;
			var Xs:int = 47;
			var Ys:int = bgBig.y + 40;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:FriendItem = new FriendItem(this, settings.content[i], mode, callBack);
				
				
				/*for (var fid:* in App.user.socInvitesFrs) 
				{
					if ((fid) == (settings.content[i].uid))
						item.showGlowing();
				}*/
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
				
				items.push(item);
				Xs += item.bg.width + 14;
				
				if (mode == MODE_INVITE_BEST_FRIEND) 
				{
					if (itemNum == 5)
					{
						Xs = X;
						Ys += item.bg.height + 50;
					}
				}else 
				{
					if (itemNum == 5)
					{
						Xs = X;
						Ys += item.bg.height + 50;
					}
				}
				
				itemNum++;
			}
			settings.page = paginator.page;
		}
		
		override protected function refreshContent(friends:Array = null):void
		{
			//return;
			if (friends.length == App.user.friends.keys.length) friends = null;
			if (friends == null)
			{
				var invitesArr:Array = new Array();
				for (var fid:* in App.user.socInvitesFrs) 
				{
					invitesArr.push(fid);
				}
				
				settings.content = [];
				if (mode == MODE_NOTIFY || mode == MODE_NOTIFY_2)
					settings.content = settings.content.concat(App.network.otherFriends);
					//settings.content = testObject;
				else
					settings.content = settings.content.concat(App.user.friends.keys);
				
				var L:uint = settings.content.length;
				for (var i:int = 0; i < L; i++)
				{
					if (i >= settings.content.length) 
						break
					if (checkExceptain(settings.content[i].uid) || !settings.content[i].uid) 
					{
						settings.content.splice(i, 1); 
						i--;
						
						continue;
					}
				}
				settings.content.sortOn('order');
			}
			else
			{
				settings.content = friends;
				settings.content.sortOn('level');
			}
			
			
			
			
			setPaginatorCount();
			paginator.update();
			contentChange();
		}
		
		override public function drawBody():void
		{
			
			var backgroundTitle:Bitmap = Window.backingShort(190, 'titleBgNew', true);
			backgroundTitle.x = (settings.width - backgroundTitle.width) / 2;
			backgroundTitle.y = 56 - 65;
			layer.addChild(backgroundTitle);
			
			exit.y -= 18;
			
			bgBig = backing(settings.width - 60, 300, 20, 'shopBackingMain');
			bgBig.x = (settings.width - bgBig.width) / 2;
			bgBig.y = settings.height - bgBig.height - 95;
			bgBig.alpha = 0.9;
			titleLabel.y += 12;
			
			setPaginatorCount();
			paginator.update();
			paginator.y += 68;
			paginator.x -= 7;
			
			//drawInfoBttn();
			
			seachPanel = new SearchFriendsPanel( {
				win:this,
				callback:refreshContent
			});
			
			bodyContainer.addChild(seachPanel);
			seachPanel.x = (settings.width - seachPanel.width) / 2;
			seachPanel.y = backText.y + backText.height + 120;//settings.height - seachPanel.height + 5 - bgBig.height;
			
			ExternalApi.onCloseApiWindow = function():void 
			{
				blokedStatus = true;
				blokItems(blokedStatus);
			}
			
			/*if (mode != MODE_INVITE_BEST_FRIEND && mode != MODE_NOTIFY && mode != MODE_NOTIFY_2 && mode != MODE_PUT_IN_ROOM) 
			{
				inviteBttn.x = seachPanel.x + seachPanel.width + 24;
				inviteBttn.y = settings.height - inviteBttn.height - 105 - bgBig.height;
			}*/
			
			drawDesc();
			
			/*if (App.social == 'FB' || App.social == 'NK') 
			{
				if(bttnAllFriends) bttnAllFriends.visible = false;
				if(bttnFriendsInGame) bttnFriendsInGame.visible = false;
			}*/
			
			
			var downPlankBmap:Bitmap = backingShort(255, 'shopPlankDown');
			downPlankBmap.x = settings.width / 2 -downPlankBmap.width / 2;
			downPlankBmap.y = settings.height - 39;
			layer.addChild(downPlankBmap);
			
			settings['itemsMode'] = 3;
			
			refreshContent(seachPanel.search("", false));
			
			if (settings.content.length > 0){
				contentChange();
			}else{
				var inviteText:TextField = drawText(Locale.__e('flash:1382952379976'),{
					fontSize:26,
					textAlign:"center",
					color:0xffffff,
					borderColor:0x794a1f,
					textLeading: 8,
					multiline:true
				});
				
				//bodyContainer.addChild(inviteText);
				inviteText.wordWrap = true;
				inviteText.width = settings.width - 140;
				inviteText.height = inviteText.textHeight + 10;
				inviteText.x = (settings.width - inviteText.width) / 2;
				inviteText.y = (settings.height - inviteText.height) / 2 - 30;
			}
		}
	}

}

import api.ExternalApi;
import buttons.Button;
import core.Log;
import core.AvaLoad;
import core.Load;
import core.Post;
import core.WallPost;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import units.Tree;
import wins.AskWindow;
import wins.Window;

internal class FriendItem extends LayerX
{
	private var window:AskWindow;
	public var bg:Bitmap;
	public var friend:Object;
	
	private var priceLabel:TextField;
	private var title:TextField;
	private var infoText:TextField;
	private var sprite:Sprite = new Sprite();
	private var priceSprite:Sprite = new Sprite();
	private var avatar:Bitmap = new Bitmap();
	private var coin:Bitmap = new Bitmap();
	private var selectBttn:Button;
	private var data:Object;
	
	private var preloader:Preloader = new Preloader();
	
	public var mode:int;
	
	private var callBack:Function;
	
	public function FriendItem(window:AskWindow, data:Object, mode:int, callBack:Function = null)
	{
		this.data = data;
		
		if (window.mode == AskWindow.MODE_NOTIFY || window.mode == AskWindow.MODE_NOTIFY_2) 
		{
			this.friend = data;
			if (App.user.friends.data[data.uid]) 
				this.friend = App.user.friends.data[data.uid];
		}
		else 
		{
			this.friend = App.user.friends.data[data.uid];
		}
		
		for (var frItm:* in App.user.friends.data)
		{
			if (App.user.friends.data[frItm].uid + "" == data.uid + "") 
			{
				this.friend = App.user.friends.data[frItm];
			}
		}
		
		this.window = window;
		this.mode = mode;
		this.callBack = callBack;
		bg = Window.backing(90, 90, 10, "banksBackingItem");
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);
		//sprite.addChild(priceSprite);
		
		//drawPrice();
		
		addChild(preloader);
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height) / 2;
		
		if (friend.first_name != null || friend.aka != null) 
		{
			drawAvatar();
		}else {
			App.self.setOnTimer(checkOnLoad);
		}
		
		var txtBttn:String;
		switch(mode) 
		{
			case AskWindow.MODE_ASK:
				txtBttn = Locale.__e("flash:1382952379978");
			break;
			case AskWindow.MODE_INVITE:
				//txtBttn = Locale.__e("flash:1382952380197");
				txtBttn = Locale.__e("flash:1382952380230");
			break;
			case AskWindow.MODE_PUT_IN_ROOM:
				txtBttn = Locale.__e("flash:1393580021031");
			break;
			case AskWindow.MODE_INVITE_BEST_FRIEND:
				txtBttn = Locale.__e("flash:1382952380230");
			break;
			case AskWindow.MODE_NOTIFY_2:
			case AskWindow.MODE_NOTIFY:
				txtBttn = Locale.__e("flash:1382952380230");
			break;
		}
		
		selectBttn = new Button({
			caption		:txtBttn,
			fontSize	:20,
			width		:bg.width - 20,
			height		:32,	
			onMouseDown	:onSelectClick
		});
		addChild(selectBttn);
		
		selectBttn.x = (bg.width - selectBttn.width) / 2;
		selectBttn.y = bg.height - 12;
		
		if(!window.blokedStatus)
			selectBttn.state = Button.DISABLED;
	}
	
	private function drawPrice():void 
	{
		priceLabel = Window.drawText('+50', {
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0,
			textAlign:'left'
		});
		priceSprite.addChild(priceLabel);
		coin = new Bitmap()
		
	}
	private function drawAvatar():void 
	{
		//banksBackingItem
		var size:Point = new Point(bg.width + 10, 30);
		var pos:Point = new Point(
			(width - size.x) / 2,
			-size.y / 2 - 2
		);
		//var fName:String = (friend['first_name'])?friend['first_name']:(friend['aka'])?friend['aka']:'undefined';
		var fName:String = (friend['aka']) ? friend['aka'] : (friend['first_name']) ? friend['first_name']:'undefined';
		
		//var fName:String = friend.fName || "";
		if (friend.fName && friend.fName.length > 0 && friend.fName != 'User')
				fName = friend.fName;
			else if (friend.aka && friend.aka.length > 0) {
				fName = friend.aka;
			}
		if (friend.uid == "1") 
		{
			fName = friend.fName;
		}
		/*var params:Array = fName.split(" ");
		if (params.length > 0)
			fName = params[0];*/
		//Log.alert('this_should_be_displayed - ' + first_Name + ' |||| ' + first_Name.substr(0, 15));
		Log.alert(fName);
		
		title = Window.drawTextX(fName, size.x, size.y, pos.x, pos.y, this, {
		//var name:TextField = Window.drawText(first_Name.substr(0, 15), App.self.userNameSettings( {
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0,
			textAlign:'center'
		});
		addChild(title);
		/*title = Window.drawText(fName.substr(0,15), App.self.userNameSettings({
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0,
			textAlign:'center'
		}));*/
		
		/*title.width = bg.width + 10;
		title.x = (bg.width - title.width) / 2;
		title.y = -5;*/
		if (!friend.hasOwnProperty('photo')) {
			errCall();
		}else{
			new AvaLoad(friend.photo, onLoad);
		}
	}
	
	public function errCall():void {
		removeChild(preloader);
		
		var noImageBcng:Bitmap = new Bitmap(UserInterface.textures.friendsBacking);
		onLoad(noImageBcng);
		//drawPic(noImageBcng,true);
	}
	
	private function checkOnLoad():void {
		if (friend && friend.first_name != null) {
			App.self.setOffTimer(checkOnLoad);
			drawAvatar();
		}
	}
	
	public function set state(value:int):void {
		
		selectBttn.state = value;
	}
	
	private function onSelectClick(e:MouseEvent):void
	{
		window.settings.target.friend = friend.uid;
		window.settings.target.callBack();
	}
		
	private function onLoad(data:*):void {
		if (data == null) {
			errCall();
		}else{
			if(preloader.parent)
			removeChild(preloader);
			
			avatar.bitmapData = data.bitmapData;
			avatar.smoothing = true;
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawRoundRect(0, 0, 50, 50, 15, 15);
			shape.graphics.endFill();
			sprite.mask = shape;
			sprite.addChild(shape);
			
			var scale:Number = 1.4;
			
			sprite.width *= scale;
			sprite.height *= scale;
			
			sprite.x = (bg.width - sprite.width) / 2;
			sprite.y = (bg.height - sprite.height) / 2;
		}
	}
	
	public function dispose():void
	{
		callBack = null;
		App.self.setOffTimer(checkOnLoad);
		selectBttn.dispose();
	}
}