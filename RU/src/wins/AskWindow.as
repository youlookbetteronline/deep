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
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import ui.UserInterface;
	import utils.ObjectsContent;
	import wins.elements.SearchFriendsPanel;
	/**
	 * ...
	 * @author 
	 */
	public class AskWindow extends Window
	{
		public static const MODE_ASK:int = 1;
		public static const MODE_INVITE:int = 2;
		public static const MODE_PUT_IN_ROOM:int = 3;
		public static const MODE_INVITE_BEST_FRIEND:int = 4;
		public static const MODE_NOTIFY:int = 5;
		public static const MODE_NOTIFY_2:int = 6;
		public static const MODE_GIFT:int = 7;
		
		
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
		
		
		public function AskWindow(mode:int, settings:Object = null, callBack:Function = null)
		{
			this.mode = mode || AskWindow.MODE_NOTIFY_2;
			
					
			this.callBack = callBack;
			
			if (settings == null) {
				settings = new Object();
			}
			settings['popup'] = true;
			settings['background'] = "banksBackingItem";
			settings["width"] = settings.width || (750);
			settings["height"] = settings.height || 580;//(552-83);
			settings['descY'] = settings.descY || 20;
			settings["title"] = settings.title || Locale.__e('flash:1487244417841')//Locale.__e("flash:1382952379975");
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
			settings['shadowColor'] = 0x116011;
			settings['fontSize'] = 42;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 2;
			settings['bttnInvTxt'] = settings['bttnInvTxt'] || Locale.__e('flash:1382952380197');
			
			
			if (mode == MODE_NOTIFY_2) 
			{
				var dataFriends:Object = App.network.otherFriends; //норм
				if (App.network.otherFriends)
				{
					for each (var item5:* in App.network.otherFriends ) 
					{
						Log.alert(App.network.otherFriends[item5]);
					}
				}
				//var dataFriends:Object = App.network.appFriends;
				//var dataFriends:Object = ObjectsContent.ASKCONTENT; //не очень норм
				var invitesArr:Array = new Array();
				for (var fid:* in App.user.socInvitesFrs) 
				{
					invitesArr.push(fid);
				}
					
				if (App.social == "MM")
					dataFriends = App.network.friends;
				for (var item2:* in dataFriends)
				{
					settings.content.push(dataFriends[item2]);
				}
				if (!dataFriends)
					settings.content = [];
				for (var j:int = 0; j < settings.content.length; j++)
				{
					settings.content[j]['order'] = int(j/*Math.random() * settings.content.length*/);
					if (invitesArr.indexOf(settings.content[j].uid) != -1)
						settings.content[j]['invited'] = 1;
					else
						settings.content[j]['invited'] = 0;
				}
				settings.content.sortOn('order');
				settings.content.sortOn('invited');
				
				/*if(mode == MODE_NOTIFY && App.social != "ML"){
					for(var item3:* in App.user.friends.keys){
						settings.content.push(App.user.friends.keys[item3]);
					}
				}*/
			}else {
				for (var item:* in App.user.friends.keys)
				{
					if (App.user.friends.keys[item].uid && App.user.friends.keys[item].uid != 1)
					{
						settings.content.push(App.user.friends.keys[item]);
					}
				}
				
				var L:uint = settings.content.length;
				for (var i:int = 0; i < L; i++)
				{
					settings.content[i]['order'] = int(i/*Math.random() * L*/);
				}
				settings.content.sortOn('order');
			}
			//var L:uint = settings.content.length;
			//for (var i:int = 0; i < L; i++)
			//{
				//settings.content[i]['order'] = int(Math.random() * L);
			//}
			//settings.content.sortOn('order');
			//settings.content = [];	
			super(settings);
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
			
			if (mode == MODE_INVITE_BEST_FRIEND) 
			{
				background.y = (settings.height - background.height) / 2 + 70;
				var inviteBack:Bitmap = new Bitmap(Window.textures.inviteFuryBack);
				//layer.addChild(inviteBack);
				inviteBack.x = background.x + (background.width - inviteBack.width) / 2;
				inviteBack.y = background.y - 250;
				
				layer.addChild(background);
				var stripe:Bitmap = Window.backingShort(settings.width + 160, 'questRibbon');
				layer.addChild(stripe);
				stripe.x = background.x + (background.width - stripe.width) / 2;
				stripe.y = background.y - 25;
				
				//titleLabel.y = stripe.y + (stripe.height - titleLabel.height) / 2 - 20;
			}else
				layer.addChild(background);
		}
		
		/*protected function drawRibbon():void 
		{
			var titleBackingBmap:Bitmap = backingShort(settings.titleWidth + 180, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -65;
			//titleBackingBmap.filters = [new GlowFilter(0xf3ff2c, .7, 11, 11, 3)];
			bodyContainer.addChild(titleBackingBmap);
			
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y - 4;
			
			bodyContainer.addChild(titleLabel);
		}*/
		
		/*override public function drawTitle():void 
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
			//titleLabel.y -= 4;
			drawRibbon();

		}*/
		
		
		protected var bgBig:Bitmap;
		protected var background:Bitmap;
		override public function drawBody():void
		{
			drawMirrowObjs('decSeaweed', settings.width + 55, - 55, settings.height - 175, true, true, false, 1, 1, layer);
			
			/*var backgroundTitle:Bitmap = Window.backingShort(190, 'titleBgNew', true);
			backgroundTitle.x = (settings.width - backgroundTitle.width) / 2;
			backgroundTitle.y = 56 - 65;
			layer.addChild(backgroundTitle);*/
			drawRibbon();
			drawBackDivider();
			exit.y -= 18;
			
			bgBig = new Bitmap(Window.textures.janeInvite); //Window.backing(settings.width - 60, 300, 20, "buildingDarkBacking");
			bgBig.x = settings.width - bgBig.width - 50;
			bgBig.y = - 45;
			//bgBig.alpha = 0.9;
			titleLabel.y += 12;
			bodyContainer.addChild(bgBig);
			
			if (mode == MODE_INVITE_BEST_FRIEND) 
			{
				bgBig.y = settings.height - bgBig.height - 35;
			}
			
			setPaginatorCount();
			paginator.update();
			//paginator.scaleY = 0.9;
			paginator.y += 21;
			paginator.x -= 7;
			
			/*if (mode == MODE_INVITE_BEST_FRIEND) 
			{
				paginator.y += 65;
			}*/
			
			drawInfoBttn();
			
			drawDesc();
			
			seachPanel = new SearchFriendsPanel( {
				win:this,
				callback:refreshContent
			});
			
			bodyContainer.addChild(seachPanel);
			seachPanel.x = 54;
			seachPanel.y = settings.height - seachPanel.height + 5 - bgBig.height;
			
			if (mode == MODE_NOTIFY || mode == MODE_NOTIFY_2) 
			{
				seachPanel.x = descFriends.x + (descFriends.width - seachPanel.width) / 2;
				seachPanel.y = descFriends.y + descFriends.height + 15;
				if (App.lang == 'jp')
					seachPanel.y -= 15;
				drawCheckAll();
			}
			
			if (mode == MODE_INVITE_BEST_FRIEND) 
			{
				seachPanel.x = 54;
				seachPanel.y = settings.height - seachPanel.height - 40 - bgBig.height;
			}
			
			if (mode != MODE_INVITE_BEST_FRIEND && mode != MODE_NOTIFY && mode != MODE_NOTIFY_2 && mode != MODE_GIFT) 
			{
				seachPanel.y = settings.height - seachPanel.height - 100 - bgBig.height;
				
				inviteBttn = new Button({
					caption:settings.inviteTxt,
					width:160,
					height:42,
					fontSize:24,
					hasDotes:false
				});
			
				bodyContainer.addChild(inviteBttn);
				inviteBttn.x = (settings.width - inviteBttn.width) /2;
				inviteBttn.y = settings.height - inviteBttn.height - 135 - bgBig.height;
				inviteBttn.addEventListener(MouseEvent.CLICK, inviteEvent);
			}
			
			if (true) 
			{
				for (var frind1:* in settings.content)
				{
					settings.content[frind1].checked = CheckboxButton.UNCHECKED;
				}
				switch(mode){
					case MODE_GIFT:
						settings['bttnInvTxt'] = Locale.__e('flash:1382952380118'); break;
					case MODE_INVITE:
						settings['bttnInvTxt'] = Locale.__e('flash:1382952380197'); break;
					case MODE_ASK:
						settings['bttnInvTxt'] = Locale.__e('flash:1382952379975'); break;
				}
					
				inviteAllBttn = new Button({
					caption			:settings['bttnInvTxt'],
					width			:160,
					height			:50,
					fontSize		:26,
					hasDotes		:false
				});
			
				bodyContainer.addChild(inviteAllBttn);
				inviteAllBttn.x = (settings.width - inviteAllBttn.width) / 2;
				inviteAllBttn.y = settings.height - 40 - inviteAllBttn.height / 2;
				inviteAllBttn.addEventListener(MouseEvent.CLICK, inviteCheckedEvent);
			}
			
			/*else {
				var bestFFIcon:Bitmap = new Bitmap(UserInterface.textures.bFFBttnIco);
				bestFFIcon.scaleX = bestFFIcon.scaleY = 2;
				bestFFIcon.smoothing = true;
				bodyContainer.addChild(bestFFIcon);
				bestFFIcon.x = settings.width - bestFFIcon.width - 80;
				bestFFIcon.y = settings.height - bestFFIcon.height - 100 - bgBig.height;
			}*/
			
			if (mode == MODE_INVITE) 
			{
				seachPanel.x = (settings.width - seachPanel.width) / 2 - 160 ;
				seachPanel.y -= 30;
				
				inviteBttn.x = seachPanel.x +seachPanel.width - 180;
				inviteBttn.y = seachPanel.y - 50;
			
			}
			
			ExternalApi.onCloseApiWindow = function():void {
				//blokedStatus = true;
				//blokItems(blokedStatus);
			}
			
			
			if (mode == MODE_INVITE)
			{
				bttnFriendsInGame = new Button( {
					width:200,		
					fontSize : 20,
					offset : 20,
					icon : false,
					caption:Locale.__e("flash:1382952380138")
				});
				//bodyContainer.addChild(bttnFriendsInGame);
				bttnFriendsInGame.x = 280;
				bttnFriendsInGame.y = 156 - bttnFriendsInGame.height;
				bttnFriendsInGame.addEventListener(MouseEvent.CLICK, onFriendsInGame);
				
				bttnAllFriends = new Button( {
					width:100,
					fontSize : 20,
					offset : 20,
					icon : false,
					caption:Locale.__e("flash:1382952380139")
				});
				//bodyContainer.addChild(bttnAllFriends);
				bttnAllFriends.x = bttnFriendsInGame.x + bttnFriendsInGame.width + 12;
				bttnAllFriends.y = 156 - bttnAllFriends.height;
				bttnAllFriends.addEventListener(MouseEvent.CLICK, onAllFriends);
				
				if (settings['noAllFriends'])
					bttnAllFriends.state = Button.DISABLED;
				
				bttnFriendsInGame.state = Button.ACTIVE;
			}else {
				if (mode != MODE_INVITE_BEST_FRIEND && mode != MODE_NOTIFY && mode != MODE_NOTIFY_2 && mode != MODE_PUT_IN_ROOM && mode != MODE_GIFT) {
					inviteBttn.x = seachPanel.x + seachPanel.width + 24;
					inviteBttn.y = settings.height - inviteBttn.height - 105 - bgBig.height;
				}
			}
			
			if (mode != MODE_INVITE_BEST_FRIEND) 
			{
				//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -45, true, true);
				//drawMirrowObjs('storageWoodenDec', +5, settings.width - 5, settings.height - 116);
			}else
				//drawMirrowObjs('storageWoodenDec', +5, settings.width - 5, settings.height - 50);
			
			if (mode == MODE_INVITE_BEST_FRIEND)
				refreshContent(seachPanel.search("", false));
				
				
			if (App.social == 'FB' || App.social == 'NK') 
			{
				if(bttnAllFriends) bttnAllFriends.visible = false;
				if(bttnFriendsInGame) bttnFriendsInGame.visible = false;
			}
			
			if (mode == MODE_ASK) 
			{
				//backText.y = 15;
				seachPanel.x += 50;
				seachPanel.y -= 75;
				inviteBttn.x -= 170;
				inviteBttn.y -= 30;
			}
			
			if (mode == MODE_GIFT)
			{
				seachPanel.y -= 150;
				seachPanel.x += 33;
			}
			
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
		
		private function drawBackDivider():void{
			backText.graphics.beginFill(0xffffff);
		    backText.graphics.drawRect(0, 0, settings.width - 140, 255);
			backText.y = 213;
			backText.x = (settings.width - backText.width) / 2;
		    backText.graphics.endFill();
			backText.filters = [new BlurFilter(40, 0, 2)];
			backText.alpha = .4;
		    bodyContainer.addChildAt(backText, 0);
			
			var dev:Shape = new Shape();
			dev.graphics.beginFill(0xc0804d);
			dev.graphics.drawRect(0, 0, settings.width - 110, 2);
			dev.graphics.endFill();
			
			var dev1:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev1.bitmapData.draw(dev);
			dev1.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			dev1.x = (settings.width - dev1.width) / 2;
			dev1.y = backText.y - dev1.height;
			bodyContainer.addChild(dev1);
			
			var dev2:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev2.bitmapData.draw(dev);
			dev2.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			dev2.x = (settings.width - dev2.width) / 2;
			dev2.y = backText.y + backText.height;
			bodyContainer.addChild(dev2);
		}
		private function onAllFriends(e:MouseEvent):void 
		{
			if (bttnAllFriends.mode == Button.ACTIVE || bttnAllFriends.mode == Button.DISABLED) return;
			
			bttnFriendsInGame.state = Button.NORMAL;
			bttnAllFriends.state = Button.ACTIVE;
			settings['itemsMode'] = 5;
			refreshContent(seachPanel.search("", false));
		}
		
		private function onFriendsInGame(e:MouseEvent):void 
		{
			if (bttnFriendsInGame.mode == Button.ACTIVE) return;
			
			bttnFriendsInGame.state = Button.ACTIVE;
			bttnAllFriends.state = Button.NORMAL;
			settings['itemsMode'] = 3;
			refreshContent(seachPanel.search("", false));
		}
		
		protected function drawCheckAll():void 
		{
			checkAllBox = new CheckboxButton({
				//width				:150,
				fontSize			:26,
				fontSizeUnceked		:26,
				caption 			:true,
				brownBg				:true,
				multiline			:false,
				wordWrap			:false,
				captionChecked		:Locale.__e('flash:1395846352679'),
				captionUnchecked	:Locale.__e('flash:1395846352679'),
				checked				:CheckboxButton.UNCHECKED,
				fontColor			:0xffffff,
				fontBorderColor		:0x7e3e13,
				dY					:4
			});
			//checkBox.checked = checked;
			
			checkAllBox.addEventListener(MouseEvent.CLICK, onCheckAllClick);
			
			/*if (checkBox.checked == CheckboxButton.CHECKED)
			{
				this.friend.checked = CheckboxButton.CHECKED
			}*/
			bodyContainer.addChild(checkAllBox);
			
			checkAllBox.x = seachPanel.x + 40 + (seachPanel.width - checkAllBox.width) / 2;
			checkAllBox.y = seachPanel.y + seachPanel.height + 10;
			if (App.lang == 'jp')
				checkAllBox.y -= 10;
		}
		private function onCheckAllClick(e:MouseEvent):void
		{
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			//for (var frind2:* in settings.content)
			{
				settings.content[i].checked = checkAllBox.checked;
			}
			contentChange();
			//this.friend.checked = checkBox.checked;
		}
		
		private var descFriends:TextField;
		protected function drawDesc():void 
		{
			/*backText.graphics.beginFill(0xfcebb0);
		    backText.graphics.drawRect(0, 0, settings.width - 140, 70);
			backText.y += 30;
			backText.x = (settings.width - backText.width) / 2;
		    backText.graphics.endFill();
			backText.filters = [new BlurFilter(40, 0, 2)];
		    bodyContainer.addChildAt(backText, 0);*/
			
			//return;
			if (settings.desc) {
				descFriends = Window.drawText(settings.desc, {
					fontSize	:24,
					color		:0x6e411e,
					width		:250,
					textAlign	:"center",
					border		:false,
					multiline	:true,
					wrap 		:true
				});
				//descFriends.wordWrap = true;
				//descFriends.width = settings.width - 80;
				bodyContainer.addChild(descFriends);
				descFriends.x = 90;
				//descFriends.border = true;
				descFriends.y = settings.descY;
				if (mode == MODE_GIFT)
					descFriends.y += 20;
					descFriends.x -= 20;
			}
		}
		
		protected function refreshContent(friends:Array = null):void
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
					
					if (invitesArr.indexOf(settings.content[i].uid) != -1)
						settings.content[i]['invited'] = 1;
					else
						settings.content[i]['invited'] = 0;
					//settings.content[i]['order'] = int(1);
					//settings.content[i]['added'] =  int(1);
					
					/*for (var fid:* in App.user.socInvitesFrs) 
					{
						if ((fid) == (settings.content[i].uid))
							settings.content[i]['order'] =  int(2);
					}*/
				}
				settings.content.sortOn('order');
				settings.content.sortOn('invited', Array.NUMERIC);
			}
			else
			{
				settings.content = friends;
				settings.content.sortOn('level');
				//settings.content.sortOn('invited', Array.NUMERIC);
			}
			
			
			
			
			setPaginatorCount();
			paginator.update();
			contentChange();
		}
		
		protected function setPaginatorCount():void
		{
			if (mode == MODE_PUT_IN_ROOM) 
			{
				for (var fr:* in App.user.friends.data) 
				{
					if (App.user.friends.data[fr].settle && App.user.friends.data[fr].settle == 1) 
					{
						for (var i:int = 0; i < settings.content.length; i++ ) 
						{
							if (settings.content[i].uid == fr) 
							{
								settings.content.splice(i, 1);
							}
						}
						continue;
					}
				}
			}
			paginator.itemsCount = settings.content.length;
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
			if (mode == MODE_INVITE_BEST_FRIEND) 
			{
				X = 130;
				Xs = 130;
				Ys = 220;
			}
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				//if (checkExceptain(settings.content[i].uid) || !settings.content[i].uid) continue;
				//Log.alert("eeeeeeeeeeeeeeeeee___-=  " + settings.content[i]['uid']);
				//if (typeof(settings.content[i]) == 'number') {
					//settings.content[i] = { fid:settings.content[i], first_name:'', last_name:'' };
				//}
				
				var item:FriendItem = new FriendItem(this, settings.content[i], mode, callBack, i);
				
				//if (checkedAll == true && item.checked == false)
					//checkedAll = false;
					
				//if (checkedAll == false && item.checked == true)
					//checkedAll = true;
					
				/*for (var fid:* in App.user.socInvitesFrs) 
				{
					if ((fid) == (settings.content[i].uid))
						item.showGlowing();
				}*/
				
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
				
				items.push(item);
				Xs += item.bg.width + 108 + 40;
				
				if (mode == MODE_INVITE_BEST_FRIEND) 
				{
					if (itemNum == 4 || itemNum == 9)
					{
						Xs = X;
						Ys += item.bg.height + 50;
					}
				}else 
				{
					if (itemNum == 2 || itemNum == 5 || itemNum == 8)
					{
						Xs = X;
						Ys += item.bg.height + 14;
					}
				}
				
				itemNum++;
			}
			//if (checkedAll)
				//checkAllBox.checked = CheckboxButton.CHECKED;
			//else	
				//checkAllBox.checked = CheckboxButton.UNCHECKED;
			settings.page = paginator.page;
		}
		
		
		protected function checkExceptain(uid:*):Boolean 
		{
			if (settings.friendException) {
				for (var id:* in settings.friendException) {
					if (settings.friendException[id] == uid) {
						return true;
					}
				}
			}
			return false;
		}
		
		public override function close(e:MouseEvent=null):void 
		{
			if (settings.onClose != null && settings.onClose is Function)
			{
				settings.onClose();
			}
			
			super.close();
		}
		
		private function inviteCheckedEvent(e:MouseEvent):void 
		{
			if (settings.content.length <= 0)
				return;
			settings.content.sortOn('checked');
			if (mode == AskWindow.MODE_ASK && settings.content[0].checked == CheckboxButton.CHECKED)
			{
				while (true)
				{
					if (settings.content.length <= 0)
						break;
					if(settings.content[0].checked && settings.content[0].checked == CheckboxButton.CHECKED)
						onSelectClick(settings.content[0], this);
					else
						break;
				}
				/*for (var frind:* in settings.content)
				{
					if(settings.content[frind].checked && settings.content[frind].checked == CheckboxButton.CHECKED)
						onSelectClick(settings.content[frind], this);
				}*/
				paginator.update();
				contentChange();
			}else{
				for (var frind:* in settings.content)
				{
					if(settings.content[frind].checked && settings.content[frind].checked == CheckboxButton.CHECKED)
						onSelectClick(settings.content[frind], this);
				}
			}
		}
		private var friend:Object;
		private function onSelectClick(data:Object, window:*):void
		{
			this.friend = new Object();
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
			
			switch(mode){
				case AskWindow.MODE_ASK:
					var index:int = window.settings.content.indexOf(data);
					if (index != -1) {
						window.settings.content.splice(index, 1);
						window.paginator.itemsCount--;
						//window.paginator.update();
						//window.contentChange();
						
						if (window.paginator.itemsCount == 0) {
							window.close();
						}
						
						Gifts.ask(window.settings['sID'], data.uid);
					}
				break;
				case AskWindow.MODE_INVITE:
					if (window.settings.target) {
					
						WallPost.makePost(WallPost.INSTANCE_INVATE, { sid:window.settings.target.sid, uid:data.uid } );
					}
				break;
				case AskWindow.MODE_PUT_IN_ROOM:
					if (callBack != null) 
						callBack(friend.uid);
					window.close();
				break;
				case AskWindow.MODE_INVITE_BEST_FRIEND:
					if (callBack != null) 
						callBack(friend.uid);
					window.close();
				break;
				case AskWindow.MODE_NOTIFY:
					if (callBack != null) 
						callBack(friend.uid);
					
					ExternalApi.notifyFriend( {
						uid:	[friend.uid],
						text:	window.settings.message,
						type:	'instance'
					});
					break;
				case AskWindow.MODE_NOTIFY_2:
					if (App.isSocial('AM')){
						var _params:Object = {
							uid			:[friend.uid]
						}
						//if (callBack != null) 
						_params['callback'] = contentChange;
						if (!App.user.allreadyInvite.hasOwnProperty(friend.uid))
							ExternalApi.notifyFriend(_params);
						break;
					}
					if (callBack != null) 
						callBack(friend.uid);
					Post.addToArchive('NOTIFY');	
					Post.send( {
						ctr:'user',
						act:'setinvite',
						uID:App.user.id,
						fID:friend.uid
					},function(error:*, data:*, params:*):void {
						if (error) {
							Errors.show(error, data);
							return;
						}
						
						//(e.currentTarget).showGlowing();
						/*var obj:Object = { };
						obj[friend.uid] = App.time;
						App.user.socInvitesFrs.push(obj);
						Log.alert('APPPPPPPPP');
						Log.alert(App.user.socInvitesFrs);*/
						//Post.addToArchive(obj);
					});
					//window.close();
				break;
				case AskWindow.MODE_GIFT:
					if (window.settings.callback) window.settings.callback(friend.uid);
					window.close();
				break;
			}
		}
		private function inviteEvent(e:MouseEvent):void 
		{
			
			if (mode == MODE_ASK || mode == MODE_NOTIFY || mode == MODE_NOTIFY_2 || mode == MODE_INVITE) {
				ExternalApi.apiInviteEvent();
			}else{
				if(settings.target)
					WallPost.makePost(WallPost.INSTANCE_INVATE_ALL, { sid:settings.target.sid } ); 
			}
		}
		
		public function blokItems(value:Boolean):void
		{
			var item:*;
			if (value)	for each(item in items) item.state = Window.ENABLED;
			else 		for each(item in items) item.state = Window.DISABLED;
		}
		
		override public function dispose():void {
			ExternalApi.onCloseApiWindow = null
			for each(var item:* in items) {
				item.dispose();
			}
			
			if (inviteBttn) {
				inviteBttn.removeEventListener(MouseEvent.CLICK, inviteEvent);
				inviteBttn.dispose();
				inviteBttn = null;
			}
			if (inviteAllBttn) {
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
			}
			
			super.dispose();
		}
		
		public static function notifyIngameFriends(params:Object = null):void {
			if (!params) params = { };
			
			ExternalApi.notifyFriend( {
				uid:	App.user.friends.ingameFriendList,
				text:	params.message || ''
			});
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
import wins.AskWindow;
import wins.Window;

internal class FriendItem extends LayerX
{
	private var window:AskWindow;
	public var bg:Shape;
	public var friend:Object;
	public var checked:int = CheckboxButton.UNCHECKED;
	
	private var title:TextField;
	private var infoText:TextField;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap = new Bitmap();
	//private var selectBttn:Button;
	private var checkBox:CheckboxButton;
	private var data:Object;
	private var friandID:int;
	
	private var preloader:Preloader = new Preloader();
	
	public var mode:int;
	
	private var callBack:Function;
	
	public function FriendItem(window:AskWindow, data:Object, mode:int, callBack:Function = null, idF:int = 0)
	{
		this.data = data;
		friandID = idF;
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
		bg = new Shape();
		bg.graphics.beginFill(0xc0804d);
		bg.graphics.drawRoundRect(0, 0, 50, 50, 15, 15);
		//sp.height = lightPositions[view].height * 0.7;
		//cont.addChild(sp);
		//bg = Window.backing(90, 90, 10, "banksBackingItem");
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);
		
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
			case AskWindow.MODE_GIFT:
				txtBttn = Locale.__e("flash:1382952380118");
			break;
		}
		if (this.friend.hasOwnProperty('checked'))
		{
			this.checked = this.friend.checked
		}
		checkBox = new CheckboxButton({
			width			:0,
			fontSize		:22,
			fontSizeUnceked	:22,
			caption 		:false,
			brownBg			:true,
			checked			:this.checked
		});
		//checkBox.checked = checked;
		
		checkBox.addEventListener(MouseEvent.CLICK, onCheckClick);
		
		/*if (checkBox.checked == CheckboxButton.CHECKED)
		{
			this.friend.checked = CheckboxButton.CHECKED
		}*/
		if(App.isSocial('AM')){
			if (!App.user.allreadyInvite.hasOwnProperty(friend.uid))
				addChild(checkBox);
		}else{
			addChild(checkBox);
		}
		
		//checkBox.x = okBttn.x + (okBttn.width - 170) / 2;
		//checkBox.y = paperBack.y + paperBack.height - checkBox.height - 25;	
		
		checkBox.x = - 50;
		checkBox.y = (bg.height - checkBox.height) / 2;
		
		/*selectBttn = new Button({
			caption		:txtBttn,
			fontSize	:20,
			width		:bg.width - 20,
			height		:32,	
			onMouseDown	:onSelectClick
		});
		//addChild(selectBttn);
		
		selectBttn.x = - selectBttn.width - 5;
		selectBttn.y = (bg.height - selectBttn.height) / 2;
		
		if(!window.blokedStatus)
			selectBttn.state = Button.DISABLED;*/
	}
	
	private function drawAvatar():void 
	{
		//banksBackingItem
		var size:Point = new Point(100, 30);
		var pos:Point = new Point(
			width + 1,
			(height-size.y) / 2
		);
		//friend['aka'] = friend['first_name'] + ' ' + friend['last_name'];
		//var fName:String = (friend['first_name'])?friend['first_name']:(friend['aka'])?friend['aka']:'undefined';
		var fName:String = (friend['aka']) ? friend['aka'] : (friend['first_name']) ? friend['first_name']:'undefined';
		if (friend.aka && friend.aka.length > 0) {
			fName = friend.aka;
		}else{
			fName = friend['first_name'] + ' ' + friend['last_name'];
		}
		//var fName:String = friend.fName || "";
		/*if (friend.fName && friend.fName.length > 0 && friend.fName != 'User')
				fName = friend.fName + ' ' + friend['last_name'];
			else if (friend.aka && friend.aka.length > 0) {
				fName = friend.aka;
			}*/
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
		if (!friend.hasOwnProperty('photo') || friend.photo == '') {
			errCall();
		}else{
			new AvaLoad(friend.photo, onLoad);
		}
	}
	
	public function errCall():void {
		removeChild(preloader);
		
		var noImageBcng:Bitmap = new Bitmap(UserInterface.textures.crab);
		onLoad(noImageBcng);
		//drawPic(noImageBcng,true);
	}
	
	private function checkOnLoad():void {
		if (friend && friend.first_name != null) {
			App.self.setOffTimer(checkOnLoad);
			drawAvatar();
		}
	}
	
	/*public function set state(value:int):void {
		selectBttn.state = value;
	}*/
	
	private function onCheckClick(e:MouseEvent):void
	{
		if (App.isSocial('AM'))
		{
			if (App.user.allreadyInvite.hasOwnProperty(friend.uid))
			{
				window.settings.content[friandID].checked = CheckboxButton.UNCHECKED;
				return;
			}
		}
		//if (checkBox.checked == CheckboxButton.CHECKED)
		//{
		window.settings.content[friandID].checked = checkBox.checked;
			//this.friend.checked = checkBox.checked;
		//}
	}
	private function onSelectClick(e:MouseEvent = null):void
	{
		//window.blokedStatus = false
		
		switch(mode){
			case AskWindow.MODE_ASK:
				var index:int = window.settings.content.indexOf(data);
				if (index != -1) {
					window.settings.content.splice(index, 1);
					window.paginator.itemsCount--;
					window.paginator.update();
					window.contentChange();
					
					if (window.paginator.itemsCount == 0) {
						window.close();
					}
					
					Gifts.ask(window.settings['sID'], data.uid);
				}
			break;
			case AskWindow.MODE_INVITE:
				if (window.settings.target) {
				/*	if (window.settings.target is Happy){
						WallPost.makePost(WallPost.HAPPY_INVITE, { sid:window.settings.target.sid, uid:data.uid, bmd:window.settings.bmd } );
					}else if (window.settings.target is Tree){
						WallPost.makePost(WallPost.TREE_INVITE, { sid:window.settings.target.sid, uid:data.uid } );
					}else{	*/
						WallPost.makePost(WallPost.INSTANCE_INVATE, { sid:window.settings.target.sid, uid:data.uid } );
					//}
				}
			break;
			case AskWindow.MODE_PUT_IN_ROOM:
				if (callBack != null) 
					callBack(friend.uid);
				window.close();
			break;
			case AskWindow.MODE_INVITE_BEST_FRIEND:
				if (callBack != null) 
					callBack(friend.uid);
				window.close();
			break;
			case AskWindow.MODE_NOTIFY:
				if (callBack != null) 
					callBack(friend.uid);
				
				ExternalApi.notifyFriend( {
					uid:	[friend.uid],
					text:	window.settings.message,
					type:	'instance'
				});
				break;
			case AskWindow.MODE_NOTIFY_2:
				if (callBack != null) 
					callBack(friend.uid);
				Post.addToArchive('NOTIFY');	
				Post.send( {
					ctr:'user',
					act:'setinvite',
					uID:App.user.id,
					fID:friend.uid
				},function(error:*, data:*, params:*):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					//(e.currentTarget).showGlowing();
					/*var obj:Object = { };
					obj[friend.uid] = App.time;
					App.user.socInvitesFrs.push(obj);
					Log.alert('APPPPPPPPP');
					Log.alert(App.user.socInvitesFrs);*/
					//Post.addToArchive(obj);
				});
				window.close();
			break;
			case AskWindow.MODE_GIFT:
				if (window.settings.callback) window.settings.callback(friend.uid);
				window.close();
			break;
		}
	}
		
	private function onLoad(data:*):void {
		if (data == null) {
			errCall();
		}else{
			if(preloader.parent)
				removeChild(preloader);
			avatar.bitmapData = data.bitmapData;
			Size.size(avatar, 50, 50);
			avatar.smoothing = true;
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawRoundRect(0, 0, 50, 50, 15, 15);
			shape.graphics.endFill();
			sprite.mask = shape;
			sprite.addChild(shape);
			Size.size(sprite, 45, 45);
			sprite.x = (bg.width - sprite.width) / 2;
			sprite.y = (bg.height - sprite.height) / 2;
		}
	}
	
	public function dispose():void
	{
		callBack = null;
		App.self.setOffTimer(checkOnLoad);
		checkBox.removeEventListener(MouseEvent.CLICK, onCheckClick);
		//selectBttn.dispose();
	}
}