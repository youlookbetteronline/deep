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
	import utils.ObjectsContent;
	/**
	 * ...
	 * @author ...
	 */
	public class DailyFriendsWindow extends Window 
	{
		private var item:FriendItem;
		private var container:Sprite = new Sprite();
		private var items:Vector.<FriendItem>;
		public var target:*;
		private var contentobject:Object;
		protected var callback:Function;
		public function DailyFriendsWindow(settings:Object=null, callback:Function = null) 
		{
			this.callback = callback;
			this.target = settings.target
			this.contentobject = App.network.otherFriends;
			//this.contentobject = ObjectsContent.ASKCONTENT;
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
			for each(var _friend:* in contentobject)
			{
				 
				if (_friend.uid == '1')
					continue;
				this.settings['content'].push(_friend);
			}
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
			contentChange();
		}
		
		private function inviteFriends(e:MouseEvent):void 
		{
			if (App.user.quests.tutorial)
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
				} ).show();
			}
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
				item = new FriendItem(this.settings.content[i], this, settings.window, callback);
				container.addChild(item);
				items.push(item);
				item.x = X;
				item.y = Y;				
				X += item.bg.width + 30;
				if ((i+1) % 4 == 0)
				{
					X = 0;
					Y += item.height + 35;
				}
			}
			container.x = 75;
			container.y = 130;
			
			bodyContainer.addChild(container);
		}
		
		
		override public function drawArrows():void {

			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -0.5, scaleY:0.5 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:0.5, scaleY:0.5 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 + 150;
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
	public var user:*;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap;
	private var addBttn:Button;
	public var bg:Shape;
	private var target:*
	private var mainWindow:*;
	private var callback:Function;
	public function FriendItem(user:*, window:*, mainWindow:*, callback:Function = null)
	{
		this.callback = callback;
		this.target = window.target
		this.window = window;
		this.user = user;
		this.mainWindow = mainWindow;
		draw();
		addChild(addBttn);

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
		
		new AvaLoad(user.photo, onLoad);
		
		addChild(sprite);
		//var params:Array = user.aka.split(" ");
		
		var title:TextField = Window.drawText(user.first_name + '\n' + user.last_name,{
			fontSize	:20,
			color		:0x804118,
			border		:false,
			textAlign	:'center',
			wrap		:true,
			textLeading	:-14,
			width		:90
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

	private function addEvent(e:*):void 
	{
		if (callback != null) 
			callback(user.uid);
		Post.addToArchive('NOTIFY');	
		Post.send( {
			ctr:'user',
			act:'setinvite',
			uID:App.user.id,
			fID:user.uid
		},function(error:*, data:*, params:*):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			window.close();
		});
		
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