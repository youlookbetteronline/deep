package wins 
{
	import api.ExternalApi;
	import api.OKApi;
	import buttons.Button;
	import buttons.ImageButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import core.Log;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import strings.Strings;

	public class FriendsRewardWindow extends Window
	{
		public var items:Array = new Array();
		private var back:Bitmap;
		private var okBttn:Button;
		public var currentDayItem:FriendRewardItem;
		public var friendsCount:int = 6;
		public var giftStage:int = 3;
		public var background:Bitmap;
		private var backDesc:Shape = new Shape();
		
		public function FriendsRewardWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 				= 700;
			settings['height'] 				= 360;
			settings['title'] 				= Locale.__e("flash:1427277406259");
			settings['hasPaginator'] 		= false;
			settings['content'] 			= [];
			settings['fontSize'] 			= 48;
			settings['shadowBorderColor']   = 0x342411;
			settings['fontBorderSize'] 		= 4;
			//settings['hasExit'] 			= false;
		//	settings['faderClickable'] 		= false;
			//App.data.
			var defContent:Object = 
			[ { bonus: { 3:5 }, stage:1,f:5, desc:'' },
			 { bonus: { 4:5 }, stage:2,f:10, desc:'' },
			 { bonus: { 5:10 }, stage:3,f:15, desc:'' },
			 { bonus: { 6:15 }, stage:4,f:20, desc:'' },
			 { bonus: { 10:13 }, stage:5,f:30, desc:'' } ];
			
			for (var item:Object in freebieValue.bonus)
			{
				var rel:Object = { };
				rel = freebieValue.req[item];
				rel['bonus'] = (freebieValue.bonus[item]);
				rel['stage'] = item;
				var obj:Object = { };
		
				settings.content.push(rel);
			}
			
			super(settings);
			friendsCount = invitedFriends;
			giftStage = curStage;
		}
		
		override public function drawExit():void {
			exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 49;
			exit.y = -8;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		private function get curStage():int 
		{
			var value:int = 0;
			for (var item:Object in settings.content)
			{
				if (int(settings.content[item].f)<=friendsCount&&(value<int(settings.content[item].f))) 
				{
					value = settings.content[item].f;
				} 
			}
			return value;
		}
		
		public static function get freebieValue():Object {
			var value:Object;
			if (App.data.hasOwnProperty('freebie')) {
				for each(var freebie:* in App.data.freebie) {
					if (freebie['social'] == App.social && freebie.hasOwnProperty('stage') && freebie.stage.hasOwnProperty('req')) {
						value = freebie.stage;
					}
				}
			}
			return value;
		}
		
		public function get invitedFriends():int {
			var count:int = 0;
			for (var fid:* in App.user.socInvitesFrs) {
				if (int(App.user.socInvitesFrs[fid]) == 1)
					count++;
			}
			return count;
		}
		
		override public function drawTitle():void 
		{
			/*var bk1:Shape = new Shape();
			bk1.graphics.beginFill(0xe8c38e);
			bk1.graphics.drawRoundRect(0, 0, 490, 115, 50, 50);
			bk1.graphics.endFill();
			bodyContainer.addChild(bk1);
			bk1.x = (settings.width - bk1.width) / 2;
			bk1.y = 30;*/
			
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 35,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x4b7915,			
				borderSize 			: 3,					
				shadowColor			: 0x085c10,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center'
			})
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -53;
			
			var ribbon:Bitmap = backingShort(320, 'ribbonGrenn',true,1.3);
			ribbon.x = settings.width / 2 -ribbon.width / 2;			
			ribbon.y = titleLabel.y - 11;
			bodyContainer.addChild(ribbon);
			bodyContainer.addChild(titleLabel);
			//drawMirrowObjs('diamondsTop', settings.width - 30, titleLabel.x + titleLabel.width + 5, titleLabel.y , true, true);
			//drawMirrowObjs('storageWoodenDec', 2, settings.width-2, 75,false,false,false,1,-1);
			//drawMirrowObjs('storageWoodenDec', 2, settings.width - 2, settings.height - 68);
			
			var descLabel:TextField = Window.drawText(Locale.__e("flash:1427277551930"), {
				fontSize	:24,
				color		:0xFFFFFF,
				borderColor	:0x8a4413,
				textAlign	:"center"
			});
			descLabel.width = descLabel.textWidth + 20;
			descLabel.x = titleLabel.x + (titleLabel.width - descLabel.width) / 2;
			descLabel.y = ribbon.y + 93;
			
			backDesc.graphics.beginFill(0xfff4b9, .9);
		    backDesc.graphics.drawRect(0, 0, descLabel.width + 60, 30);
		    backDesc.graphics.endFill();
		    backDesc.x = descLabel.x - 25;
		    backDesc.y = descLabel.y;
		    backDesc.filters = [new BlurFilter(40, 0, 2)];
		    bodyContainer.addChild(backDesc);
			bodyContainer.addChild(descLabel);
		}
		
		
		/*override public function titleText(settings:Object):Sprite
		{
			
			if (!settings.hasOwnProperty('width'))
				settings['width'] = 300;
			
			var cont:Sprite = new Sprite();
			
			settings.shadowSize = settings.shadowSize || 3;
			settings.shadowColor = settings.shadowColor || 0x111111;
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			this.settings['titleWidth'] = textLabel.textWidth;
			this.settings['titleHeight'] = textLabel.textHeight;
			textLabel.wordWrap = true;
			textLabel.width = settings.width;
			textLabel.height = textLabel.textHeight + 4;
			
			var filters:Array = []; 
			
			if (settings.borderSize > 0) 
			{
				filters.push(new GlowFilter(settings.borderColor || 0x7e3e14, 1, settings.borderSize, settings.borderSize, 16, 1));
			}
			
			if (settings.shadowSize > 0) 
			{
				filters.push(new DropShadowFilter(settings.shadowSize, 90, 0x085c10, 1, 0, 0));
			}
			
			textLabel.filters = filters;
			
			cont.addChild(textLabel);
			cont.mouseEnabled = false;
			cont.mouseChildren = false;
			return cont;
		}*/
		
		override public function drawBackground():void {

			background = backing(settings.width, settings.height , 50, 'workerHouseBacking');
			var background2:Bitmap  = backing2(settings.width - 60, settings.height - 54, 40, 'capsuleWindowBackingPaperUp', 'capsuleWindowBackingPaperDown');

			background2.x = background.x + (background.width - background2.width) / 2;
			background2.y = background.y + (background.height - background2.height) / 2;
			layer.addChildAt(background, 0);
			layer.addChildAt(background2, 1);
			//drawMirrowObjs('diamondsTop', titleLabel.x +15, titleLabel.x + titleLabel.width -15 , titleLabel.y+15 , true, true);
			
			//decorateWith('storageWoodenDec');
			
		}
		
		override public function drawBody():void {
			Load.loading(Config.getImage('promo/images', 'crystals'), function(data:Bitmap):void {
					var image:Bitmap = new Bitmap(data.bitmapData);
					headerContainer.addChildAt(image, 0);
					image.x = settings.width / 2 - image.width / 2;
					image.y = -80;
			});
			
			drawItems();
		//	friendsCount = 2;
			var maxFriends:int = 0;
			for (var i:* in settings.content) {
				if (settings.content[i].stage == App.user.freebie.status+1) {
					maxFriends = settings.content[i].f;
					if ( friendsCount >= maxFriends) 
					{
						new FriendRewardWindow(settings.content[i],settings.ID).show();
					}
				}
			}
			
			var bar:WinBar = new WinBar( { val:friendsCount, max:maxFriends } );
			bodyContainer.addChild(bar);
			bar.x = (settings.width - bar.width) / 2;
			bar.y = 235;
			okBttn = new Button( {
				caption:Locale.__e('flash:1382952380197'),
				fontSize:28,
				width:167,
				height:48
			});
			
			bodyContainer.addChild(okBttn);
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - 71;
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
		}
		
		
		
		
		
		private function onOkBttn(e:MouseEvent):void 
		{
			close();
			
			if (App.social == "OK"){
				OKApi.showInviteCallback = showInviteCallback;
				ExternalApi.apiInviteEvent();
			}else if (App.social == "MM"){ExternalApi.apiInviteEvent({callback:true});}else{
				new AskWindow(AskWindow.MODE_NOTIFY_2,  { 
						title:Locale.__e('flash:1407159672690'), 
						inviteTxt:Locale.__e("flash:1407159700409"), 
						desc:Locale.__e("flash:1430126122137"),
						descY:30,
						height:530,
						itemsMode:5
					},  function(uid:String):void {
							sendPost(uid);
							Log.alert('uid '+uid);
						//ExternalApi.notifyFriend({uid:uid, text:Locale.__e('flash:1407155160192'),callback:Post.statisticPost(Post.STATISTIC_INVITE)});
						} ).show();
				//take();
				//конец
			}
		}
		
		private function showInviteCallback(e:* = null):void {
			Log.alert('showInviteCallback');
			Log.alert(e.data);
			Log.alert(e);
			
			if (e.hasOwnProperty("status") && e.status == "opened")
				return;
				
			var friendID:String;
			if (App.social == "ML" && e && e is Array)
			{
				for each (friendID in e) 
				{
					Invites.postAboutInvite(friendID);
				}
			}
			else if (App.social == "FB" && e.to)
			{
				for each (friendID in e.to)
				{
					Invites.postAboutInvite(friendID);
				}
			}
			else
			{
				friendID = e.data;
				Invites.postAboutInvite(friendID);
			}
		}
		
		
		public function sendPost(uid:*):void {
		var message:String = Strings.__e("FreebieWindow_sendPost", [Config.appUrl]);
		var bitmap:Bitmap = new Bitmap(Window.textures.iPlay, "auto", true);
		
		if (bitmap != null) {
			ExternalApi.apiWallPostEvent(ExternalApi.GIFT, bitmap, String(uid), message, 0, null, {url:Config.appUrl});// , App.ui.bottomPanel.removePostPreloader);
				
			//ExternalApi.apiWallPostEvent(ExternalApi.PROMO, bitmap, String(App.user.id), message, 0, null, {url:Config.appUrl});
		}
	}
		
		private var container:Sprite;
		private var OffsetY:int = 35;
		private function drawItems():void {
			
			/*var bk2:Bitmap = Window.backing(534, 143, 50, 'buildingDarkBacking');
			bodyContainer.addChild(bk2);
			bk2.x = (settings.width - bk2.width) / 2;
			bk2.y = 87;*/
			container = new Sprite();
			
			var X:int = 0;
			var Y:int = 10;
			
			for (var i:int = 0; i < 5; i++) {
				
				var item:FriendRewardItem = new FriendRewardItem(settings.content[i], this,i);	
				
				container.addChild(item);
				item.x = X;
				item.y = Y;
				
				X += item.bg.width + 12;
			}
		//	new FriendRewardWindow();
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2 + 5;
			container.y = 80;
		}
		
		public function take():void 
		{
/*			Post.send( {
				ctr:'user',
				act:'day',
				uID:App.user.id
			}, function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (App.social == 'FB') {						
					ExternalApi.og('claim', 'daily_bonus');
				}
				
				App.user.stock.addAll(data.bonus);
				
				for (var _sid:* in data.bonus) {
					var item:BonusItem = new BonusItem(_sid, data.bonus[_sid]);
					var point:Point = Window.localToGlobal(currentDayItem);
					point.y += 80;
					item.cashMove(point, App.self.windowContainer);
				}
				
				setTimeout(close, 300);
			});*/
		}
		
		override public function dispose():void {
			while (container.numChildren > 0) {
				var _item:* = container.getChildAt(0);
				if (_item is FriendRewardItem) _item.dispose();
				container.removeChild(_item);
			}
			okBttn.removeEventListener(MouseEvent.CLICK, onOkBttn);
			
			super.dispose();
		}
	}
}	


import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import ui.UserInterface;
import wins.FriendsRewardWindow;
import wins.Window;
	

internal class FriendRewardItem extends LayerX {
	
	private var item:Object;
	public var bg:Bitmap;
	public var win:FriendsRewardWindow;
	private var title:TextField;
	private var sID:uint;
	private var count:uint;
	private var bitmap:Bitmap;
	private var status:int = 0;
	public var itemDay:int;
	private var check:Bitmap = new Bitmap(Window.textures.checkMark);
	private var layer:LayerX;
	private var intervalPluck:int;
	public var isCurrent:Boolean = false;
	
	public function FriendRewardItem(item:Object, win:FriendsRewardWindow,numb:int = 0) {
		
		this.win = win;
		this.item = item;
		bg = new Bitmap(Window.textures.clearBubbleBacking);
		//bg.scaleX = bg.scaleY = 0.8;
		bg.smoothing = true;
		
		if (numb > App.user.freebie.status) {
			status = 2;
		}
		if (numb < App.user.freebie.status) {
			status = 0;
		}
		
		if (numb == App.user.freebie.status) {
		//	if (win.friendsCount >= item.f) {
				status = 1
		//	}
			isCurrent = true;
		}
		
		addChild(bg);
		layer = new LayerX();
		addChild(layer);
		bitmap = new Bitmap();
		if (isCurrent) 
		{
			var gf:GlowEffect = new GlowEffect();
			gf.scaleX = gf.scaleY = 0.6;
			gf.x = bg.width / 2;
			gf.y = bg.height / 2;
			//layer.addChild(gf);
			gf.start();
		}
		layer.addChild(bitmap);

		if (item == null) return;
		
		for (var _sID:* in item.bonus) break;
			sID = _sID;
		count = item.bonus[_sID];
		
		drawTitle();
		drawCount();
		
		var tText:String = App.data.storage[sID].description;
		if (status == 0 && !isCurrent)
		{
			tText = Locale.__e('flash:1484130958324', [String(count) +' ' + String(App.data.storage[sID].title)]);
		}else{
			tText = Locale.__e('flash:1484132172255', [String(item.f), String(count), String(App.data.storage[sID].title)]);
		}
		layer.tip = function():Object 
		{
			return {
				title:App.data.storage[sID].title,
				text:tText
			}
		}
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), function(data:Bitmap):void {
			bitmap.bitmapData = data.bitmapData;
			/*var needScale:Number = Math.max(data.width / bg.width, data.height / bg.height);
			if (needScale > 1)
			{
				var scale:Number = 1 / needScale;
				var matrix:Matrix = new Matrix();
				matrix.scale(scale, scale);
				var smallBMD:BitmapData = new BitmapData(data.width * scale, data.height * scale, true, 0x000000);
				smallBMD.draw(data, matrix, null, null, null, true);
				bitmap.bitmapData = smallBMD;
				bitmap.smoothing = true;
			}
			if(sID == Stock.EXP)
				bitmap.scaleX = bitmap.scaleY = 0.8;
			else
				bitmap.scaleX = bitmap.scaleY = 0.9;*/
			Size.size(bitmap, bg.width - 20, bg.height - 20);
			bitmap.smoothing = true;
			bitmap.x = (bg.width - bitmap.width) / 2;
			bitmap.y = (bg.height - bitmap.height) / 2;
			//if (status == 1) startPluck();
			//if (sID == Stock.FANT) return;
		});
		
		drawMark();
		if (status == 2) {
			UserInterface.effect(bg, 0, 0.4);
		}
	}
	
	private function drawMark():void 
	{
		if (status == 0 && !isCurrent){
			UserInterface.effect(bg, 0, 0.8);
			addChild(check);
		}
		check.x = (bg.width - check.width) / 2;
		check.y = (bg.height - check.height) / 2;
	}
		
	private function drawTitle():void
	{	
		title = Window.drawText(Locale.__e('flash:1427276489992',[item.f]), {
		color:0xffffff,
		borderColor:0x682f1e,
		textAlign:"center",
		autoSize:"center",
		fontSize:24,
		textLeading:-6,
		multiline:true
		});
		title.wordWrap = true;
		title.y = -17;
		title.x = (bg.width - title.width) / 2;
		addChild(title)
	}

	private function drawCount():void
	{
		var countText:TextField = Window.drawText("x" + String(count), {
			color:0xffffff,
			borderColor:0x682f1e,
			textAlign:"left",
			autoSize:"center",
			fontSize:28,
			textLeading: -6,
			width:80
			//multiline:true
		});
	//	countText.wordWrap = true;
		countText.width = (countText.textWidth);
		countText.y = bg.height - countText.height + 22;
		countText.x = bg.x + (bg.width - countText.textWidth)/2;
		addChild(countText)
		
	}
	
	public function startPluck():void {
		intervalPluck = setInterval(randomPluck, Math.random()* 5000 + 2000);
	}
	
	private function randomPluck():void
	{
		layer.pluck(30, layer.width / 2, layer.height / 2 + 50);
	}
	
	public function dispose():void {
		clearInterval(intervalPluck);
		layer.pluckDispose();
	}
}

internal class WinBar extends Sprite {
	
	private var back:Bitmap = new Bitmap(Window.textures.prograssBarBacking);
	private var viewVal:Bitmap = new Bitmap(Window.textures.progressBar);
	private var label:TextField = new TextField();;
	private var currVal:int = 0;
	private var maxVal:int = 100;
	
	public function WinBar(params:Object):void {
		currVal = params.val || 0;
		maxVal = params.max || 100;

		label = Window.drawText(currVal + '/' + maxVal,
			{
				color:0xffffff,
				borderColor:0x644b2b,
				fontSize:32,
				width:back.width,
				textAlign:"center"
			});
		
		addChild(back);
		addChild(viewVal);
		addChild(label);
		viewVal.x = 0;
		viewVal.y = 1;
		setValue(currVal);
	}
	
	public function setValue(val:int = 0):void {
		currVal = Math.min(currVal,maxVal);
		label.text = currVal  + '/' + maxVal;
		var ht:int = back.height;
		var wd:int = int(back.width * (currVal / maxVal));
		
		var shape:Shape = new Shape();
		addChild(shape);
		shape.graphics.beginFill(0xff0000, 1);
		shape.graphics.moveTo(0, 0);
		shape.graphics.lineTo(wd, 0);
		shape.graphics.lineTo(wd, ht);
		shape.graphics.lineTo(0, ht);
		shape.graphics.lineTo(0, 0);
		shape.graphics.endFill();
		
		shape.x = viewVal.x;
		shape.y = viewVal.y;
		viewVal.mask = shape;
	}
}

internal class GlowEffect extends Sprite {
	private var glowBitmap:Bitmap = new Bitmap(Window.textures.glowingBackingNew);
	private var glowCont:Sprite = new Sprite();
	
	public function GlowEffect():void {
		addChild(glowCont);
		glowBitmap.x = -glowBitmap.width / 2;
		glowBitmap.y = -glowBitmap.height / 2;
		glowCont.addChild(glowBitmap);
	}
	
	public function start():void {
		var that:GlowEffect = this;
		
		App.self.setOnEnterFrame(function():void {
			if (that && that.parent) {
				glowCont.rotation++;
			}else {
				App.self.setOffEnterFrame(arguments.callee);
			}
		});
	}
	
}