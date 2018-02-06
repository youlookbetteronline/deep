package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import buttons.ImageButton;
	import core.Log;
	import core.Post;
	import core.Size;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.elements.SearchFriendsPanel;
	/**
	 * ...
	 * @author 
	 */
	public class AddResWindow extends Window
	{
		
		
		public var items:Array = [];
		public var seachPanel:SearchFriendsPanel;
		
		public var inviteBttn:Button;
		public var inviteAllBttn:Button;
		public var infoBttn:ImageButton = null;
		public var bttnAllFriends:Button;
		public var bttnFriendsInGame:Button;
		public var backText:Shape = new Shape();
		public var bg:Bitmap = new Bitmap();
		public var blokedStatus:Boolean = true;
		public var checkAllBox:CheckboxButton;
		
		public var mode:int;
		
		protected var callBack:Function;
		
		public function AddResWindow(settings:Object = null, callBack:Function = null)
		{
			this.callBack = callBack;
			
			if (settings == null) {
				settings = new Object();
			}
			super(settings);
			settings['popup'] = true;
			settings['background'] = "banksBackingItem";
			settings["width"] = 750;
			settings["height"] = 580;
			settings['descY'] = settings.descY || 20;
			settings["title"] = settings.title || Locale.__e('flash:1487244417841');
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = settings.itemsOnPage || 12;
			settings['friendException'] = settings.friendException || null;
			settings["sID"] = settings["sID"] || 2;
			settings['message'] = settings['message'] || Locale.__e('flash:1382952380111', [Config.appUrl]);
			settings.content = [];
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] = 0x116011;
			settings['shadowBorderColor'] = 0x116011;
			settings['fontSize'] = 32;
			
			initContent();
			
		}
		
		override public function show():void 
		{
			if (App.user.quests.tutorial) 
				return;
			super.show();
		}
		
		override public function drawBackground():void
		{
			background = backing(settings.width, settings.height, 20, 'paperWithBacking');
			layer.addChild(background);
		}
		
		protected function drawRibbon():void 
		{
			var titleBackingBmap:Bitmap = backingShort(settings.titleWidth + 180, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -65;
			bodyContainer.addChild(titleBackingBmap);
			
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y - 4;
			
			bodyContainer.addChild(titleLabel);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: 42,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,
				borderSize 			: 3,
				shadowSize 			: 1,
				shadowColor			: settings.fontBorderColor,
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
		}
		
		
		protected var bgBig:Bitmap;
		protected var background:Bitmap;
		override public function drawBody():void
		{
			drawMirrowObjs('decSeaweed', settings.width + 55, - 55, settings.height - 175, true, true, false, 1, 1, layer);
			
			
			backText.graphics.beginFill(0xffffff);
		    backText.graphics.drawRect(0, 0, settings.width - 140, 255);
			backText.y = 213;
			backText.x = (settings.width - backText.width) / 2;
		    backText.graphics.endFill();
			backText.filters = [new BlurFilter(40, 0, 2)];
			backText.alpha = .4;
		    bodyContainer.addChildAt(backText, 0);
			
			var dev1:Bitmap = Window.backingShort(settings.width - 110, "dividerTop", false);
			dev1.x = (settings.width - dev1.width) / 2;
			dev1.y = backText.y - dev1.height;
			bodyContainer.addChild(dev1);
			
			var dev2:Bitmap = Window.backingShort(settings.width - 110, "dividerTop", false);
			dev2.x = (settings.width - dev2.width) / 2;
			dev2.y = backText.y + backText.height;
			bodyContainer.addChild(dev2);
			
			drawInfoBttn();
			
			drawDesc();
			
			if (true) 
			{
				for (var frind1:* in settings.content)
				{
					settings.content[frind1].checked = CheckboxButton.UNCHECKED;
				}
				inviteAllBttn = new Button({
					caption			:'Кнопочка',
					width			:160,
					height			:50,
					fontSize		:26,
					hasDotes		:false
				});
			
				bodyContainer.addChild(inviteAllBttn);
				inviteAllBttn.x = (settings.width - inviteAllBttn.width) / 2;
				inviteAllBttn.y = settings.height - 40 - inviteAllBttn.height / 2;
				//inviteAllBttn.addEventListener(MouseEvent.CLICK, inviteCheckedEvent);
			}
			
			if (settings.content.length > 0){
				contentChange();
			}
		}
		
		private var descFriends:TextField;
		protected function drawDesc():void 
		{
			if (settings.desc) 
			{
				descFriends = Window.drawText(settings.desc, {
					fontSize	:24,
					color		:0x6e411e,
					width		:250,
					textAlign	:"center",
					border		:false,
					multiline	:true,
					wrap 		:true
				});
				bodyContainer.addChild(descFriends);
				descFriends.x = 90;
				descFriends.y = settings.descY;
			}
		}
		
		protected function drawInfoBttn():void 
		{
			infoBttn = new ImageButton(textures.infoBttnPink);
			bodyContainer.addChild(infoBttn);
			infoBttn.x = exit.x + 3;
			infoBttn.y = exit.y + 40;
			infoBttn.addEventListener(MouseEvent.CLICK, info);
		}
		
		private function info(e:MouseEvent = null):void {
		
			var hintWindow:WindowInfoWindow = new WindowInfoWindow( {
				popup: true,
				hintsNum:3,
				hintID:1,
				height:540
			});
			hintWindow.show();	
			
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -.9, scaleY:.9 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:.9, scaleY:.9 } );
			
			var y:Number = settings.height / 2 - paginator.arrowLeft.height;
			
			paginator.arrowLeft.x = paginator.arrowLeft.width / 2 + 18;
			paginator.arrowLeft.y = y + 85;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width / 2 - 18;
			paginator.arrowRight.y = y + 85;
		}
		
		public function initContent():void 
		{
			for each(var zid:* in App.data.storage)
			{
				if (zid.type == 'Resource')
					settings.content[zid.ID] = zid;
			}
		}
		override public function contentChange():void {
			var checkedAll:Boolean = false;
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			
			var X:int = 130;
			var Xs:int = 130;
			var Ys:int = 220;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
			//for (var i:* in settings.content)
			//{
				var item:ResourceItem = new ResourceItem(this, settings.content[i], mode, callBack, i);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
				
				items.push(item);
				Xs += item.bg.width + 108 + 40;
				
				if (itemNum == 4 || itemNum == 9)
				{
					Xs = X;
					Ys += item.bg.height + 50;
				}
				
				
				itemNum++;
			}
			settings.page = paginator.page;
		}
		
		public override function close(e:MouseEvent=null):void 
		{
			if (settings.onClose != null && settings.onClose is Function)
			{
				settings.onClose();
			}
			
			super.close();
		}
		
		private var friend:Object;
		private function onSelectClick(data:Object, window:*):void
		{
			
		}
		
		
		override public function dispose():void 
		{
			for each(var item:* in items) {
				item.dispose();
			}
			
			/*if (inviteBttn) {
				inviteBttn.removeEventListener(MouseEvent.CLICK, inviteEvent);
				inviteBttn.dispose();
				inviteBttn = null;
			}*/
			/*if (inviteAllBttn) {
				inviteAllBttn.removeEventListener(MouseEvent.CLICK, inviteCheckedEvent);
				inviteAllBttn.dispose();
				inviteAllBttn = null;
			}
			if (bttnAllFriends){
				bttnAllFriends.removeEventListener(MouseEvent.CLICK, onAllFriends);
				bttnAllFriends.dispose();
				bttnAllFriends = null;
			}
			if (bttnFriendsInGame) {
				bttnFriendsInGame.removeEventListener(MouseEvent.CLICK, onFriendsInGame);
				bttnFriendsInGame.dispose();
				bttnFriendsInGame = null;
			}*/
			
			super.dispose();
		}
	}
}

import api.ExternalApi;
import buttons.Button;
import buttons.CheckboxButton;
import core.Log;
import core.AvaLoad;
import core.Load;
import core.Post;
import core.Size;
import core.WallPost;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import units.Tree;
import wins.AddResWindow;
import wins.AskWindow;
import wins.Window;

internal class ResourceItem extends LayerX
{
	private var window:AddResWindow;
	public var bg:Shape;
	public var resource:Object;
	public var checked:int = CheckboxButton.UNCHECKED;
	
	private var title:TextField;
	private var infoText:TextField;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap = new Bitmap();
	//private var selectBttn:Button;
	private var checkBox:CheckboxButton;
	private var data:Object;
	private var resSID:int;
	
	private var preloader:Preloader = new Preloader();
	
	public var mode:int;
	
	private var callBack:Function;
	
	public function ResourceItem(window:AddResWindow, data:Object, mode:int, callBack:Function = null, idF:int = 0)
	{
		this.data = data;
		
		this.window = window;
		this.mode = mode;
		this.callBack = callBack;
		bg = new Shape();
		bg.graphics.beginFill(0xc0804d);
		bg.graphics.drawRoundRect(0, 0, 50, 50, 15, 15);
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);
		
		addChild(preloader);
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height) / 2;
		
		drawAvatar();
		
		var txtBttn:String;
		
		if (data.hasOwnProperty('checked'))
		{
			this.checked = data.checked;
		}
		
		checkBox = new CheckboxButton({
			width			:0,
			fontSize		:22,
			fontSizeUnceked	:22,
			caption 		:false,
			brownBg			:true,
			checked			:this.checked
		});
		
		checkBox.addEventListener(MouseEvent.CLICK, onCheckClick);
		addChild(checkBox);
		
		checkBox.x = - 50;
		checkBox.y = (bg.height - checkBox.height) / 2 + 13;
	}
	
	private function drawAvatar():void 
	{
		var size:Point = new Point(100, 30);
		var pos:Point = new Point(
			size.x / 2,
			(height-size.y) / 2
		);
		title = Window.drawTextX(data.title, size.x, size.y, pos.x, pos.y, this, {
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0,
			textAlign:'center'
		});
		addChild(title);
		Load.loading(Config.getIcon(data.type, data.preview), onLoad);
	}
	
	private function onCheckClick(e:MouseEvent):void
	{
		window.settings.content[resSID].checked = checkBox.checked;
	}
	
	private function onSelectClick(e:MouseEvent = null):void
	{
		
	}
		
	private function onLoad(data:*):void {
		if (data != null) 
		{
			Size.size(sprite, 45, 45);
			sprite.x = (bg.width - sprite.width) / 2;
			sprite.y = (bg.height - sprite.height) / 2;
		}
	}
	
	public function dispose():void
	{
		checkBox.removeEventListener(MouseEvent.CLICK, onCheckClick);
	}
}