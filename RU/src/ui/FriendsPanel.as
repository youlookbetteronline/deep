package ui 
{
	import api.ExternalApi;
	import api.OKApi;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import strings.Strings;
	import ui.BottomPanel;
	import buttons.ImageButton;
	import units.Hero;
	import utils.InviteHelper;
	import utils.ObjectsContent;
	import wins.AskWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class FriendsPanel extends LayerX
	{	
		private const FREE_FRIEND_CONT:int = 6;
		
		public var allFriendsItems:Vector.<FriendItem> = new Vector.<FriendItem>();
		public var friendsItems:Vector.<FriendItem> = new Vector.<FriendItem>();
		public var opened:Boolean = false;
		public var ROW:int = 6;
		
		private var bottomPanel:BottomPanel;
		private var bg:Bitmap;
		private var seaweedDecoration:Bitmap;
		private var friendsCont:Sprite;		
		private var _limit:int;
		private var guestMode:Boolean = false;
		
		public function FriendsPanel(_parent:*) 
		{			
			bottomPanel = _parent;
			resize();
			initFriends();			
			createWishList();			
		}
		
		public var wishList:WishListPopUp = null;		
		
		public function createWishList():void
		{
			wishList = new WishListPopUp(this);
			addChild(wishList);
			//wishList.x = 52;
			wishList.y = -50;
		}
		
		public function resize(guest:Boolean = false ):void 
		{
			this.guestMode = guest;		
			drawItems();
			showFriends();
			drawBttns();
		}
		
		private function dispose():void 
		{
			
		}
		
		public var bttnPrev:ImageButton;
		public var bttnPrevSix:ImageButton;
		public var bttnPrevAll:ImageButton;
		public var bttnNext:ImageButton;
		public var bttnNextSix:ImageButton;
		public var bttnNextAll:ImageButton;
		public var bttnFav:ImageButton;
		
		private function drawBttns():void 
		{	
			if (bttnPrev) removeChild(bttnPrev);
			if (bttnPrevAll) removeChild(bttnPrevAll);
			if (bttnNext) removeChild(bttnNext);
			if (bttnNextAll) removeChild(bttnNextAll);
			if (bttnFav) removeChild(bttnFav);
			
			bttnPrev 		= new ImageButton(UserInterface.textures.friendsBttnOne);
			bttnPrevAll 	= new ImageButton(UserInterface.textures.friendsBttnFew);
			bttnNext 		= new ImageButton(UserInterface.textures.friendsBttnOne, {scaleX:-1});
			bttnNextAll		= new ImageButton(UserInterface.textures.friendsBttnFew, { scaleX: -1 } );
			bttnFav			= new ImageButton(App.user.fmode == Friends.ALL?UserInterface.textures.onFav:UserInterface.textures.offFav);
			
			bttnPrev.addEventListener(MouseEvent.CLICK, onPrevSixEvent);
			bttnPrevAll.addEventListener(MouseEvent.CLICK, onPrevAllEvent);
			bttnNext.addEventListener(MouseEvent.CLICK, onNextSixEvent);
			bttnNextAll.addEventListener(MouseEvent.CLICK, onNextAllEvent);
			bttnFav.addEventListener(MouseEvent.CLICK, onBttnFav);
			
			bttnFav.tip = function():Object{
				return{
					title: (App.user.fmode == Friends.ALL)?Locale.__e('flash:1510656969594'):Locale.__e('flash:1510657011834')
				}
			}
			
			bttnPrev.x = 145;
			bttnPrev.y = 64;
			
			bttnPrevAll.x =145 - 20;
			bttnPrevAll.y = 76;	
			
			bttnNext.x = bg.width + 70;
			bttnNext.y = 64;	
			
			bttnNextAll.x = bg.width + 90;
			bttnNextAll.y = 76;
			
			bttnFav.x = bg.width + 40;
			bttnFav.y = 15;
			
			addChild(bttnPrev);
			addChild(bttnPrevAll);
			
			addChild(bttnNext);
			addChild(bttnNextAll);
			
			addChild(bttnFav);
		}
		
		private function onPrevEvent(e:MouseEvent):void {
			showFriends(-1);
		}
		private function onPrevSixEvent(e:MouseEvent):void {
			var limit:int = getLimit();
			showFriends(-limit);
		}
		private function onPrevAllEvent(e:MouseEvent):void {
			showFriends(-App.user.friends.keys.length);
		}
		private function onNextEvent(e:MouseEvent):void {
			showFriends(+1);
		}
		private function onNextSixEvent(e:MouseEvent):void {
			var limit:int = getLimit();
			showFriends(+limit);
		}
		private function onNextAllEvent(e:MouseEvent):void {
			showFriends(App.user.friends.count - ROW + FREE_FRIEND_CONT);
		}
		private function onBttnFav(e:MouseEvent):void {
			App.tips.hide();
			var needmode:int = App.user.fmode == Friends.ALL?Friends.FAV:Friends.ALL;
			Post.send({
					ctr		:'friends',
					act		:'changemode',
					uID		:App.user.id,
					mode	:needmode//App.user.fmode
			}, onChangeMode);
			/*if (App.user.fmode == Friends.ALL)
			{
				
				
				App.ui.bottomPanel.friendsPanel.searchFriends("", Friends.favorites)
				App.user.fmode = Friends.FAV;
				
			}
			else
			{
				App.ui.bottomPanel.friendsPanel.searchFriends("")
				App.user.fmode = Friends.ALL;
			}
			redrawBttnFav(App.user.fmode)*/
		}
		
		private function onChangeMode(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				return;
			}
			App.user.fmode = data.mode;
			if (App.user.fmode == Friends.FAV)
			{
				
				
				App.ui.bottomPanel.friendsPanel.searchFriends("", Friends.favorites)
				//App.user.fmode = Friends.FAV;
				
			}
			else
			{
				App.ui.bottomPanel.friendsPanel.searchFriends("")
				//App.user.fmode = Friends.ALL;
			}
			redrawBttnFav(App.user.fmode)
		}
		
		private function redrawBttnFav(fmode:int):void 
		{
			bttnFav.parent.removeChild(bttnFav)
			var bdata:BitmapData = (fmode == Friends.ALL)?UserInterface.textures.onFav:UserInterface.textures.offFav;
			bttnFav.bitmapData = bdata;
			addChild(bttnFav);
		}
		
		private function drawItems():void 
		{
			if (bg != null) {
				removeChild(bg);
				removeChild(seaweedDecoration);
				seaweedDecoration = null;
				bg = null;
			}
			seaweedDecoration = new Bitmap(UserInterface.textures.bottom_left_back_guest_seaweed);
			
			if (guestMode) {//bottom panel
				seaweedDecoration.visible = true;
				bg = BottomPanel.drawPanelBg(App.self.stage.stageWidth - 240/*260*/, 'mainFriendsPanelBG_2');  //friendsPanel
			} else {
				seaweedDecoration.visible = false;
				//seaweedDecoration = null;
				//bg = BottomPanel.drawPanelBg(App.self.stage.stageWidth - (((App.isSocial('YB','AI','MX','GN')) )?380:320), 'mainFriendsPanelBG_2');
				bg = BottomPanel.drawPanelBg(App.self.stage.stageWidth - 450, 'mainFriendsPanelBG_2');
			}
			//seaweedDecoration.y -= 100;
			
			
			addChild(seaweedDecoration);
			addChild(bg);
			
			
			bg.x = 106;
			bg.y = 20;
			
			seaweedDecoration.x = 104;
			seaweedDecoration.y = bg.y - 10;
			
			
			
			var crab:Bitmap = new Bitmap(UserInterface.textures.crab);
			crab.x = 120;
			crab.y = bg.y + 10;
			addChild(crab);
			
			drawBttns();
			drawSearch();			
		}		
		
		public function initFriends():void 
		{
			if (App.user.fmode == Friends.FAV)
				searchFriends("", Friends.favorites)
			else
				searchFriends("")
			//searchFriends();
		}
		
		private var searchBgPanel:Bitmap;
		
		private function drawSearch():void 
		{	
			if (bttnSearch != null)
				removeChild(bttnSearch);
				
			if (searchBgPanel != null)
				removeChild(searchBgPanel);
				
			bttnSearch =  new ImageButton(UserInterface.textures.searchBttn);
			bttnSearch.x = bg.x + 60;  
			bttnSearch.y = bg.y - 40;
			
			addChild(bttnSearch);
			bttnSearch.addEventListener(MouseEvent.CLICK, onSearchEvent);
			
			searchBgPanel = new Bitmap(UserInterface.textures.searchBackingLongInt);
			searchBgPanel.x = bttnSearch.x + 38; //40
			searchBgPanel.y =  bttnSearch.y + 3;//5
			addChildAt(searchBgPanel, 1);
			searchBgPanel.visible = false;
			bttnSearch.tip =  function():Object { return { title:Locale.__e("flash:1382952379771") }; }
			
			searchPanel.x = bttnSearch.x + 46;
			searchPanel.y =  bttnSearch.y + 10;
			addChild(searchPanel);
			
			if (searchBg != null)
			{
				searchPanel.removeChild(searchBg);
			}
			
			var searchBg:Shape = new Shape();
			searchBg.graphics.lineStyle(1, 0x47424e, 1, true);
			searchBg.graphics.beginFill(0xadd6df,1);
			searchBg.graphics.drawRoundRect(-1, -3, 75, 18, 13, 13);
			searchBg.graphics.endFill();
			
			searchPanel.addChild(searchBg);
			
			if (bttnBreak != null)
				searchPanel.removeChild(bttnBreak);
			
			bttnBreak = new ImageButton(UserInterface.textures.stopIcon);			
			
			searchPanel.addChild(bttnBreak);		
			bttnBreak.x = searchBgPanel.width - bttnBreak.width - 10.5;
			bttnBreak.y = -5;
			bttnBreak.scaleX = bttnBreak.scaleY = .9;
			bttnBreak.addEventListener(MouseEvent.CLICK, onBreakEvent);
			
			searchField = Window.drawText("",{ 
				color:0x604729,
				borderColor:0xf8f2e0,
				fontSize:16,
				input:true,
				border:false
			});
			
			searchField.width = bttnBreak.x - 5;
			searchField.height = searchField.textHeight + 2;
			searchField.x = 2;
			searchField.y = -3;
			
			searchPanel.addChild(searchField);
			searchPanel.visible = false;
			
			searchField.addEventListener(Event.CHANGE, onInputEvent);
			searchField.addEventListener(FocusEvent.FOCUS_IN, onFocusEvent);
		}
		
		private function onFocusEvent(e:FocusEvent):void 
		{
			if (App.self.stage.displayState != StageDisplayState.NORMAL) {
				App.self.stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		private function onInputEvent(e:Event):void 
		{
			if (App.user.fmode == Friends.FAV)
				searchFriends(e.target.text, Friends.favorites)
			else
				searchFriends(e.target.text)
			//searchFriends(e.target.text);
		}
		
		private function onSearchEvent(e:MouseEvent):void 
		{
			if (!searchPanel.visible) {
				searchField.text = "";
			}
			
			searchPanel.visible = !searchPanel.visible;
			searchBgPanel.visible = !searchBgPanel.visible;
		}
		
		private function onBreakEvent(e:MouseEvent):void
		{
			searchField.text = "";
			if (App.user.fmode == Friends.FAV)
				searchFriends('', Friends.favorites)
			else
				searchFriends()
			searchPanel.visible = false;
			searchBgPanel.visible = !searchBgPanel.visible;
		}
		
		public var start:int = 0;
		private var guest:int;
		public var friends:Array = [];
		public var searchPanel:Sprite = new Sprite();
		public var bttnSearch:ImageButton;
		public var bttnBreak:ImageButton;
		public var searchField:TextField;
		public function searchFriends(query:String = "", content:Object = null):void 
		{
			friends = [];
			var friend:Object;
			query = query.toLowerCase();
			var bot:Object;
			
			if (query == "")
			{
				if (content != null)
				{
					for each(friend in content)
					{
						if (friend.uid == "1")
						{
							bot = friend;
						}else {	
							friends.push(friend);
						}
					}
				}
				else
				{
					for each(friend in App.user.friends.data)
					{
						if (friend.uid == "1")
						{
							bot = friend;
						}else {	
							friends.push(friend);
						}
					}
				}
				
			}else {
				if (content != null)
				{
					for each(friend in content)
					{
						if (
							friend.aka.toLowerCase().indexOf(query) == 0 ||
							(friend.first_name && friend.first_name.toLowerCase().indexOf(query) == 0) ||
							(friend.last_name && friend.last_name.toLowerCase().indexOf(query) == 0) ||
							friend.uid.toString().toLowerCase().indexOf(query) == 0
						){
							if (friend.uid == "1") {
								bot = friend;
							}else{
								friends.push(friend);
							}
							if (!friend.hasOwnProperty('first_name') || ['User', ' ', ' ', '  ', '   ', '    ', '     ', '      ', '       ', '        '].indexOf(friend.first_name) == -1 || friend.first_name != '' || friend.first_name == 0) {
								friend.first_name == friend.aka
							}
						}
					}
				}
				else
				{
					for each(friend in App.user.friends.data)
					{
						if (
							friend.aka.toLowerCase().indexOf(query) == 0 ||
							(friend.first_name && friend.first_name.toLowerCase().indexOf(query) == 0) ||
							(friend.last_name && friend.last_name.toLowerCase().indexOf(query) == 0) ||
							friend.uid.toString().toLowerCase().indexOf(query) == 0
						){
							if (friend.uid == "1") {
								bot = friend;
							}else{
								friends.push(friend);
							}
							if (!friend.hasOwnProperty('first_name') || ['User', ' ', ' ', '  ', '   ', '    ', '     ', '      ', '       ', '        '].indexOf(friend.first_name) == -1 || friend.first_name != '' || friend.first_name == 0) {
								friend.first_name == friend.aka
							}
						}
					}
				}
				
			}
			
			friends.sortOn("level", Array.NUMERIC | Array.DESCENDING);
			if(bot){
				friends.unshift(bot);
			}
			
			showFriends();
		}
		
		private function getLimit():int 
		{
			
			if (guestMode) 
			{
				limit = Math.ceil((App.self.stage.stageWidth - 433) / 63);		
			}
			else 
			{
				limit = Math.ceil((App.self.stage.stageWidth - 290 - 353) / 63);	
			}
			return limit;
		}
		
		public function showFriends(shift:int = 0):void 
		{
			if (friendsCont)
				removeChild(friendsCont);
				
			friendsCont = new Sprite();
			start += shift;
			
			var limit:int = getLimit();
			
			if (start >= friends.length - limit + 1)
				start = friends.length - limit + 1;
				
			if (start <= 0)
				start = 0;
				
			var childs:int = numChildren;
			
			friendsItems = new Vector.<FriendItem>();
			allFriendsItems = new Vector.<FriendItem>();
			
			//limit -= 1;
			
			var length:int = friends.length > start + limit ?start + limit :friends.length;
			var item:FriendItem;
			
			var X:int = 0;
			var Y:int = 10;
			
			for (var i:int = start; i < length; i++) {
				item = new FriendItem(this, friends[i]);
				friendsItems.push(item);
				item.x = X;
				item.y = Y;
				friendsCont.addChild(item);
				item.px = item.x;
				X += item.width - 4;
				//item.addEventListener(MouseEvent.CLICK, onVisitEvent);
			}
			
			for (i = length; i < start + limit; i++) {
				item = new FriendItem(this);
				friendsItems.push(item);
				item.x = X - 8;
				item.y = Y;
				friendsCont.addChild(item);
				item.px = item.x;
				X += item.width + 2;
				item.addEventListener(MouseEvent.CLICK, onInviteEvent);
			}
			try{
				for (i = friendsItems.length -1 ; i >= 0; i--)
				{
					friendsCont.setChildIndex(friendsItems[i], this.numChildren - 1);
				}
			}catch (e:Error){}
		
			
			friendsCont.x = bg.x + (bg.width - friendsCont.width) / 2 - 0;
			friendsCont.y = 8;
			addChild(friendsCont);
			
			/*for (i = 0; i < friends.length; i++) 
			{
				item = new FriendItem(this,friends[i]);
				allFriendsItems.push(item);
				//item.addEventListener(MouseEvent.CLICK, onVisitEvent);
			}*/
		}
		
		public var tempFriend:FriendItem;
		private function selectFriendItem(target:* = null):void
		{
			for each(var item:* in friendsItems)
			{
				if (item == target)
				{
					var scale:Number = 1.15;
					item.y = 24;
					item.x = item.px - 4;
					item.width = item.w * scale;
					item.height = item.h * scale;
				}
				else
				{
					item.width = item.w;
					item.height = item.h;
					item.y = 34;
					item.x = item.px
				}
			}
		}
		
		public function onVisitEvent(target:*, worldID:uint = 4):void {
			if (App.user.quests.tutorial)
			{
				if(App.user.mode == User.GUEST || target.friend.uid != 1)
					return;
			}
			if (!Hero.loaded)
				return;
				
			var isOpened:Boolean = false;		
			/*if ( e.target.friend.uid=='1')
			{
				isOpened = true;
			}*/
			var friendWorlds:Object = {};
			for each(var wID:* in target.friend.worlds) 
			{
				friendWorlds[int(wID)] = int(wID);
			}
			if (friendWorlds && friendWorlds.hasOwnProperty(worldID))
			{
				isOpened = true;
			}
			/*if (App.user.quests.data.hasOwnProperty("87") && App.user.quests.data[87].finished != 0) {
				isOpened = true;	
			}*/
			if (!isOpened) 
			{
				//Window.closeAll();
				new SimpleWindow( {
					'label'	:SimpleWindow.ATTENTION,
					'title'	:Locale.__e('flash:1474469531767'),
					'text'	:Locale.__e('flash:1491900377052'),
					popup	:true
				}).show();						
				return;
			}
			//Window.closeAll();
			Travel.friend = target.friend;			
			Travel.onVisitEvent(worldID);
		}
		
		public function onInviteEvent(e:MouseEvent):void 
		{
			InviteHelper.inviteOther();
			/*if (App.user.quests.tutorial)
				return;
			if (App.isSocial('NK','FS','MM','FB','YB','AI','HV','YN','SP','GN')) {
				ExternalApi.apiInviteEvent(null,App.self.onInviteComplete);
				
			}else if (App.social == "OK"){
				//OKApi.showInviteCallback = App.self.showInviteCallback;
				ExternalApi.apiInviteEvent(null,App.self.showInviteCallback);
			}else{
				new AskWindow(AskWindow.MODE_NOTIFY_2,  {
					title:Locale.__e('flash:1407159672690'), 
					inviteTxt:Locale.__e("flash:1407159700409"), 
					desc:Locale.__e("flash:1430126122137"),
					itemsMode:5
				},  function(uid:String):void {
					sendPost(uid);
					Log.alert('uid '+uid);
				}).show();
			}*/
		}
		
		public function sendPost(uid:*):void 
		{
			var message:String = Strings.__e("FreebieWindow_sendPost", [Config.appUrl]);
			var bitmap:Bitmap = new Bitmap(Window.textures.iPlay, "auto", true);
			
			if (bitmap != null) {
				ExternalApi.apiWallPostEvent(ExternalApi.GIFT, bitmap, String(uid), message, 0, null, {url:Config.appUrl});// , App.ui.bottomPanel.removePostPreloader);
			}
		}
		
		public function get limit():int 
		{
			return _limit;
		}
		
		public function set limit(value:int):void 
		{
			_limit = value;
		}
	}
}


import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import ui.FriendsPanel;
import ui.FriendItem;
import wins.GiftItemWindow;
import wins.Window;

internal class WishListPopUp extends LayerX
{
	private var showed:Boolean = false;
	private var items:Array = [];
	private var container:Sprite;
	private var overed:Boolean = false;
	private var overTimer:Timer = new Timer(250, 1);
	public var window:FriendsPanel;
	public var callback:Function;
	public var uid:String;

	public function WishListPopUp(window:FriendsPanel)
	{
		this.window = window;
		callback = function():void
		{
		}
		overTimer.addEventListener(TimerEvent.TIMER, dispose)
	}
	
	public function show(target:FriendItem):void
	{
		if (!target.uid)
			return;
		if (!App.user.friends.data[target.uid].hasOwnProperty("wl")) return;
		
		uid = target.uid;
		var wlist:Object = App.user.friends.data[uid].wl;
		
		dispose();
		items = [];
			//target.friendsPanel.x
		var X:int = target.friendsPanel.x + 43;
		var Y:int = 10;
		if (App.user.mode == User.GUEST)
			X += 226;
		
		for (var i:* in wlist)
		{
			var item:WishListItem = new WishListItem(wlist[i], this, uid);
			item.x = X;
			item.y = Y;
			item.addEventListener(MouseEvent.MOUSE_OVER, over);
			item.addEventListener(MouseEvent.MOUSE_OUT, out);
			
			items.push(item);
			X += item.width;
			addChild(item);
		}
		this.x = target.x + (target.width - this.width)/2 + 4;
		this.x = target.x + (target.width - this.width)/2 + 4;
		
		showed = true;
		window.setChildIndex(this, window.numChildren-1);
	}
	
	private function over(e:MouseEvent):void
	{
		overed = true;
	}
	
	private function out(e:MouseEvent):void
	{
		overed = false;
	}
	
	private function dispose(e:TimerEvent = null):void
	{
		overTimer.reset();
		if (overed)
		{
			overTimer.start();
			return;
		}
		
		for each(var _item:* in items)
		{
			_item.dispose();
			_item.removeEventListener(MouseEvent.MOUSE_OVER, over);
			_item.removeEventListener(MouseEvent.MOUSE_OUT, out);
			removeChild(_item);
			_item = null;
		}
		items = [];
		
		showed = false;
	}
	
	public function hide():void
	{
		overTimer.reset();
		overTimer.start();
	}
}

internal class WishList extends Sprite
{
	public var items:Array = [];
	public var icon:*;
	public var uid:String;
	public var callback:Function;

	public function WishList(wlist:Object, icon:*)
	{
		this.icon = icon;
		this.uid = icon.uid;
		var X:int = 0;
		var Y:int = 0;
		callback = function():void{
			icon.win.refreshIcon();
			icon.win.refreshContent();
		}
		
		for (var i:* in wlist)
		{
			var item:WishListItem = new WishListItem(wlist[i], this, uid);
			item.x = X;
			item.y = Y;
			items.push(item);
			X += 56;
			addChild(item);
		}
	}
	
	public function dispose():void
	{
		for each(var item:* in items)
		{
			item.dispose();
			item = null;
		}
	}
}

internal class WishListItem extends LayerX
{
	private var bitmap:Bitmap;
	private var bg:Bitmap;
	private var has:Boolean = false;
	private var preloader:Preloader = new Preloader();
	private var wList:*;
	private var sID:uint;
	private var uid:String;
		
	public function WishListItem(sID:uint, wList:*, uid:String)
	{
		this.wList = wList;
		this.sID = sID;
		this.uid = uid;
		
		if (App.user.stock.count(sID) > 0)
		{
			has = true;
			bg = new Bitmap(Window.textures.cursorsPanelItemBg);
			//bg.x = -2;
			//bg.y = -2;
			this.addEventListener(MouseEvent.CLICK, onClick);
		} else { 
			bg = new Bitmap(Window.textures.cursorsPanelItemBg);
			//bg.alpha = .6;
		}
		bg.scaleX = bg.scaleY = .8;
		bg.smoothing = true;
		
		addChild(bg);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		this.tip = function():Object { 
			return {
				title:App.data.storage[this.sID].title,
				text:App.data.storage[this.sID].description
			};
		};
		
		addChild(preloader);
		preloader.scaleX = preloader.scaleY = 0.8;
		preloader.x = bg.width / 2;
		preloader.y = bg.height / 2;
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
	}

	private function onClick(e:MouseEvent):void
	{
		new GiftItemWindow( {
			sID:sID,
			fID:uid,
			callback:function():void {
				wList.callback();
			}
		}).show();
	}
	
	public function dispose():void
	{
		this.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onLoad(data:Bitmap):void
	{
		removeChild(preloader);		
		bitmap.bitmapData = data.bitmapData;
		Size.size(bitmap, bg.width - 15, bg.height - 15);
		bitmap.y = (bg.height - bitmap.height) / 2;
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.smoothing = true;
		if (!has)
			bitmap.alpha = .6;
	}
}