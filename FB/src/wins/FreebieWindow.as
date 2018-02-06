package wins {
	
	import api.ExternalApi;
	import api.OKApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import strings.Strings;
	import ui.UserInterface;

	public class FreebieWindow extends Window {
		
		private var items:Array = new Array();
		public var action:Object = {};
		private var container:Sprite;
		private var okBttn:Button;
		private var stateCont:Sprite;
		public var state:int = 0;
		
		public function FreebieWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}
			action = App.data.freebie[settings['ID']];
			
			settings['width'] = 450;
			settings['height'] = 500;
			settings['title'] = Locale.__e('flash:1406539345347'); // action.title;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontSize'] = 36;
			settings['fontBorderSize'] = 2;
			settings["fontColor"] = 0xffffff;
			settings["fontBorderColor"] = 0x276a12;
			settings["shadowColor"] = 0x00276a12;
			settings['background'] = 'capsuleWindowBacking';
			settings['exitTexture'] = 'closeBttnMetal';
			
			super(settings);
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - settings.titlePading,
				shadowColor			: settings.shadowColor,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			});
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = - 48;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		public static function get freebieMaxValue():int {
			var value:int = 0;
			if (App.data.hasOwnProperty('freebie')) {
				for each(var freebie:* in App.data.freebie) {
					if (freebie['social'] == App.social && freebie.hasOwnProperty('stage') && freebie.stage.hasOwnProperty('req')) {
						value = Numbers.countProps(freebie.stage.req);
					}
				}
			}
			return value;
		}
		
		public function checkComplete():Boolean 
		{
			var complete:Boolean = true;
			for each(var _item:* in items) {
				//_item.complete = true;
				if (_item.complete == false)
				{
					_item.complete = false;
					complete = false;
				}
			}
			
			return complete;
		}
		
		override public function drawBody():void 
		{
			this.y += 50;
			fader.y -= 50;
			exit.y -= 20;
			var back1:Bitmap = new Bitmap();
			
			
			
			back1 = backing(settings.width - 66, settings.height - 60, 40, 'paperClear');
			bodyContainer.addChild(back1);
			back1.x = (settings.width - back1.width) / 2;
			back1.y = (settings.height - back1.height) / 2 - 38;
			
			var titleBackingBmap:Bitmap = backingShort(390, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -65;
			bodyContainer.addChild(titleBackingBmap);
			
			back = new Shape();
			back.graphics.beginFill(0xecb674, .9);
			back.graphics.drawRect(0, 0, settings.width - 120, 120);
			back.graphics.endFill();
			back.x = (settings.width - back.width) / 2;
			back.y = settings.height - back.height - 100;
			back.filters = [new BlurFilter(40, 0, 2)];
			bodyContainer.addChild(back);
			
			//back = Window.backingShort(settings.width - 60, 'dailyBonusBackingDesc', true);
			//back.x = (settings.width - back.width) / 2;
			//back.height = 120;
			//back.alpha = .3;
			//back.y = settings.height - back.height - 100;
			//bodyContainer.addChild(back);
			
			var textOne:TextField = drawText(Locale.__e('flash:1479896671167'), {
				fontSize	:28,
				textAlign	:"center",
				autoSize	:"center",
				color		:0xfdff54,
				borderColor	:0xa35618,
				multiline	:true,
				wrap		:true,
				width		:settings.width-100
			});
			
			textOne.x = (settings.width - textOne.width) / 2;
			textOne.y = 242;
			bodyContainer.addChild(textOne);
			
			//back = Window.backingShort(settings.width - 40, 'dailyBonusBackingDesc'); //подложка под наградой
			//back.x = (settings.width - back.width) / 2;
			//back.y = settings.height - back.height - 50 - 60 + 12 + 32;
			//bodyContainer.addChild(back);
			
			var fixY:int = 55 - 39;
			titleLabel.y += fixY + 15;
			
			var glowIcon:Bitmap = new Bitmap(Window.textures.dailyBonusItemGlow);
			glowIcon.scaleX = glowIcon.scaleY = 1.9;
			glowIcon.smoothing = true;
			glowIcon.x = (settings.width - glowIcon.width) / 2;
			glowIcon.y = -40 - glowIcon.height/2;
			layer.addChildAt(glowIcon, 0);
			
			
			var fishes:Bitmap = new Bitmap(Window.textures.freebieFishes);
			fishes.x = (settings.width - fishes.width) / 2 - 10;
			fishes.y = -155;
			layer.addChildAt(fishes, 0);
			
			var cauldronIcon:Bitmap = new Bitmap(Window.textures.cauldronWithDiamonds);
			cauldronIcon.x = (settings.width - cauldronIcon.width) / 2 - 35;
			cauldronIcon.y = -204;
			bodyContainer.addChild(cauldronIcon);
			
			stateCont = new Sprite();
			bodyContainer.addChild(stateCont);
			
			drawMirrowObjs('decSeaweed', settings.width + 57, - 57, settings.height - 211, true, true, false, 1, 1, bodyContainer);
			drawState();
		}
		
		private var progressBar:ProgressBar;
		//private var back:Bitmap;
		private var back:Shape;
		private function drawState():void 
		{
			clearState();
			
			var stateBacking:Bitmap;
			var levelLabel:TextField;
		
			if (App.user.freebie.status > 0) 
			{
				close();
				new FriendsRewardWindow(settings).show();
				
			} else 
			{
				var types:Array = ['bookmark', 'invite', 'join', 'tell'];
				for (var j:int = 0; j < types.length; j++)
				{
					if (action[types[j]] == 0)
					{
						types.splice(j, 1);
						j --;
					}
				}
				
				var cX:int = 0;
				var cY:int = 28;
				for (var i:int = 0; i < types.length; i++) 
				{
					var task:TaskItem = new TaskItem(types[i], this);
					
					task.height += 5;
					task.width += 20;
					task.x = cX + (settings.width - task.width) / 2;
					task.y = i * (task.height + 4) + cY;
					
					stateCont.addChild(task);
					items.push(task);
				}
				
				checkComplete();
			}
			
			var count:int = 0;
			var posX:int = 0;
			var stg:int = App.user.freebie.status + 1;
			var item:Object = 
			{
				state	:stg,
				reward	:[],
				friends	:action.stage.req[stg].f
			}
			for (var s:* in action.stage.bonus[stg]) 
			{
				var itmData:Object = {};
				item.reward.push(action.stage.bonus[stg]);
			}
			
			var freebieItem:FreebieItem = new FreebieItem(item, this);
			posX = (settings.width - freebieItem.width) / 2;
			
			freebieItem.y = back.y + 0;
			//freebieItem.x = back.x ;
			freebieItem.x = (settings.width - freebieItem.itemRect.w) / 2;
			stateCont.addChild(freebieItem);
		}
		
		private function clearState():void 
		{
			for (var i:int = stateCont.numChildren - 1; i > -1; i--) 
			{
				var child:* = stateCont.getChildAt(i);
				if (child.hasOwnProperty('dispose') && (child.dispose is Function)) 
				{
					child.dispose();
				}
				if (stateCont.contains(child))
					stateCont.removeChild(child);
					
				if (child is Button) child = null;
			}
		}
		
		private function progress():void 
		{
			progressBar.progress = invitedFriends / App.data.freebie[settings.ID].stage.req[App.user.freebie.status + 1].f;
			progressBar.timer.text = String(invitedFriends) + ' / ' + String(App.data.freebie[settings.ID].stage.req[App.user.freebie.status + 1].f);
		}
		
		public function sendChanges(type:String, value:*):void 
		{
			var sendObject:Object = 
			{
				ctr		:'freebie',
				act		:'set',
				uID		:App.user.id,
				fID		:settings.ID
			}
			
			Log.alert('fID +' + settings.ID);
			sendObject[type] = value;
			
			Post.send( sendObject, 
			function(error:int, data:Object, params:Object):void 
			{
				if (error) 
				{
					Errors.show(error, data);
					return;
				}
			});
		}
		
		public function take(target:* = null):void 
		{
			var sendObject:Object = 
			{
				ctr		:'freebie',
				act		:'take',
				uID		:App.user.id,
				fID		:settings.ID
			}
			
			Post.send( sendObject, function(error:int, data:Object, params:Object):void 
			{
				if (error) 
				{
					Errors.show(error, data);
					return;
				}
				
				App.user.stock.addAll(data.bonus);
				BonusItem.takeRewards(data.bonus, (target != null) ? target : this);
				App.user.freebie.status++;
				
				if (App.user.freebie.status < FreebieWindow.freebieMaxValue) 
				{
					drawState();
				}else {
					close();
					App.ui.rightPanel.hideFreebie();
				}
			});
			
		}
		
		public function onShowFriends(e:MouseEvent = null):void 
		{
			close();
			
			if (App.social == "OK")
			{
				OKApi.showInviteCallback = App.self.showInviteCallback;
				ExternalApi.apiInviteEvent();
			}else if (App.social == "MM"){ExternalApi.apiInviteEvent({callback:true});}else if (App.social == "FS"){ExternalApi.apiInviteEvent();}else{
				new AskWindow(AskWindow.MODE_NOTIFY_2,  
				{ 
					title		:Locale.__e('flash:1407159672690'), 
					inviteTxt	:Locale.__e("flash:1407159700409"), 
					desc		:Locale.__e("flash:1430126122137"),
					descY		:30,
					itemsMode	:5,
					height		:530
				},  function(uid:String):void 
				{
					sendPost(uid);
					Log.alert('uid '+uid);
					//ExternalApi.notifyFriend({uid:uid, text:Locale.__e('flash:1407155160192'),callback:Post.statisticPost(Post.STATISTIC_INVITE)});
				} ).show();
			}
		}
		
		public function sendPost(uid:*):void 
		{
		var message:String = Strings.__e("FreebieWindow_sendPost", [Config.appUrl]);
		var bitmap:Bitmap = new Bitmap(Window.textures.iPlay, "auto", true);
		
		if (bitmap != null) 
		{
			ExternalApi.apiWallPostEvent(ExternalApi.GIFT, bitmap, String(uid), message, 0, null, {url:Config.appUrl});// , App.ui.bottomPanel.removePostPreloader);
			//ExternalApi.apiWallPostEvent(ExternalApi.PROMO, bitmap, String(App.user.id), message, 0, null, {url:Config.appUrl});
		}
	}
		
	

		/*private function showInviteCallback(e:*):void {
			Log.alert('showInviteCallback');
			Log.alert(e.data);
			Post.addToArchive('FREEBIE');
			Post.send( {
				ctr:'user',
				act:'setinvite',
				uID:App.user.id,
				fID:e.data
			},function(error:*, data:*, params:*):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}*/
		
		public function get invitedFriends():int {
			var count:int = 0;
			for (var fid:* in App.user.socInvitesFrs) {
				if (int(App.user.socInvitesFrs[fid]) == 1)
					count++;
			}
			return count;
		}
		
		public override function dispose():void {
			for each(var _item:* in items) {
				_item.dispose();
				_item = null;
			}
			super.dispose();
		}
	}
}

import api.ExternalApi;
import buttons.Button;
import com.junkbyte.console.Cc;
import core.Load;
import core.Log;
import core.Numbers;
import core.Post;
import effects.Effect;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.net.navigateToURL;
import flash.net.URLRequest;
import flash.text.TextField;
import strings.Strings;
import wins.Window;
import wins.FreebieWindow;

internal class TaskItem extends Sprite {
	
	public var background:Bitmap
	private var title:String = '';
	private var type:String = '';
	private var win:FreebieWindow;
	public var bttn:Button;
	private var check:Bitmap = new Bitmap(Window.textures.checkBoxPress);
	private var checkBacking:Bitmap = new Bitmap(Window.textures.checkBox);
	public var _complete:Boolean = false;
	public var onClickFunction:Function;
	
	public function TaskItem(type:String, win:*) {
		this.type = type;
		this.win = win;
		
		switch(type) {
			case 'bookmark'		:title = Locale.__e('flash:1382952380107'); 				break;
			case 'invite'		:title = Locale.__e('flash:1382952380108', [win.action.stage.req[App.user.freebie.status + 1].f]);	break;
			case 'join'			:title = Locale.__e('flash:1382952380109');					break;
			case 'tell'			:title = Locale.__e('flash:1382952380110');					break;
		}
		
		bttn = new Button({
			caption			:title,
			multiline		:true,
			fontSize		:24,
			radius			:26,
			height			:45,
			width			:330,
			bgColor			:[0xf9d0a3, 0xf0bf89],	
			borderColor		:[0xf9d0a3, 0xd7a46c],
			bevelColor		:[0xffeee2, 0xc07841],
			fontColor		:0xffffff,			
			fontBorderColor	:0x8b420e,
			active			:{
				bgColor			:[0xf9d0a3, 0xf0bf89],	
				borderColor		:[0xf9d0a3, 0xd7a46c],
				bevelColor		:[0xffeee2, 0xc07841],
				fontColor		:0xffdc7b,			
				fontBorderColor	:0x8b420e				//Цвет обводки шрифта		
			}
		});	
		bttn.textLabel.y -= 2;
		bttn.textLabel.height = bttn.textLabel.textHeight + 5;
		addChild(bttn);
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		
		
		checkBacking.x = bttn.width - 45;
		checkBacking.y = bttn.height / 2 - checkBacking.height / 2;
		checkBacking.smoothing = true;
		addChild(checkBacking);
		
		check.x = checkBacking.x + (checkBacking.width - check.width) / 2;
		check.y = checkBacking.y + (checkBacking.height - check.height) / 2;
		check.smoothing = true;
		addChild(check);
		check.visible = false;
		
		checkOnComplete();
	}
	
	private function checkOnComplete():void {
		
		function bookmarkChange(response:*):void {
			Post.addToArchive('\n showSettingsBox: ' + JSON.stringify(response));
			if (response == '1') {
				App.user.freebie['bookmark'] = 1;
				complete = true;
			} else {
				App.user.freebie['bookmark'] = 0;
				complete = false;
			}
			
			win.checkComplete();
			win.sendChanges('bookmark', App.user.freebie['bookmark']);
		}
		
		switch(type) {
			case 'bookmark':
				ExternalApi.addSettingsCallback(bookmarkChange);
				ExternalApi.getAppPermission();
				
				onClickFunction = function():void {
					bttn.state = Button.NORMAL;
					ExternalApi.showSettingsBox();
				}
				if (App.user.freebie['bookmark'] >=  win.action['bookmark']) {
					win.sendChanges('bookmark', 1);
					complete = true;
				}
				break;
				
			case 'invite':
				onClickFunction = win.onShowFriends;
				
				if (win.invitedFriends >= win.action.stage.req[1].f)
					complete = true;
				break;
				
			case 'join':
				onClickFunction = function():void {
					navigateToURL(new URLRequest(App.self.flashVars.group), "_blank");
					win.close();
				}
				
				if (App.user.freebie['join'] >=  win.action['join']) { 
					complete = true;
				} else {
					ExternalApi.checkGroupMember(function(resonse:*):void {
						Cc.log('\n checkGroupMember: ' + JSON.stringify(resonse));
						if (resonse == 1) {
							complete = true
							win.checkComplete();
							App.user.freebie['join'] = 1;
							win.sendChanges('join', 1);
						}
						else {
							App.user.freebie['join'] = 0;
							win.sendChanges('join', 0);
						}
					});
				}
				break;
				
			case 'tell':
				onClickFunction = function():void {
					sendPost();
				}
				if (App.user.freebie['tell'] >=  win.action['tell']) //расскомитить
					complete = true;
				break;
		}
	}
	
	public function set complete(value:Boolean):void {
		_complete = value;
		
		if(value)
				state = Button.ACTIVE;
			else
				state = Button.NORMAL;
	}
	
	public function get complete():Boolean {
		return _complete;
	}
	
	private function onClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.NORMAL) {
			//e.currentTarget.mode = Button.DISABLED;
			onClickFunction();
		}
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function set state(value:uint):void {
		if (value == Button.ACTIVE) {
			bttn.state = value;
			check.visible = true;
		} else {
			check.visible = false;
			bttn.state = value;
		}
	}
	
	public function sendPost():void {
		var message:String = Strings.__e("FreebieWindow_sendPost", [Config.appUrl]);
		var bitmap:Bitmap = new Bitmap(Window.textures.iPlay, "auto", true);
		
		if (bitmap != null) {
			Log.alert('ExternalApi.apiWallPostEvent +');
			ExternalApi.apiWallPostEvent(ExternalApi.PROMO, bitmap, String(App.user.id), message, 0, onPostComplete, {url:Config.appUrl});
		}
	}
	
	public function onPostComplete(result:*):void {
		Log.alert('result.status +' + result);
		if (App.social == "MM" && result.status != "publishSuccess")
				return;
		Log.alert('result.status2 +' + result);
		Post.addToArchive('\n onPostComplete: ' + JSON.stringify(result));
		
		switch(App.self.flashVars.social) {
			case "VK":
					if (result != null && result.hasOwnProperty('post_id')) {
						App.user.freebie['tell'] = 1;
						win.sendChanges('tell', 1);
						complete = true;
					}
				break;
			case "OK":
			case "MM":
					if (result != null && result != "null") {
						App.user.freebie['tell'] = 1;
						win.sendChanges('tell', 1);
						complete = true;
					}
				break;
			case "FS":
					if (result) {
						App.user.freebie['tell'] = 1;
						win.sendChanges('tell', 1);
						complete = true;
				}
				break;	
		}
		win.checkComplete();
	}
}

internal class FreebieItem extends LayerX {
	
	private var container:Sprite;
	private var title:TextField;
	private var takeBttn:Button;
	
	public var status:int = 0;
	public var freebie:Object;
	public var items:Array = [];
	public var window:*;
	
	public function FreebieItem(params:Object, window:*):void {
		status = params.state;
		freebie = params;
		this.window = window;
		draw();
	}
	
	public function draw():void {
		container = new Sprite();
		addChild(container);
		
		var count:int = 0;
		for (var i:String in freebie['reward'][0]) {
			var itmData:Object = Numbers.getProp(freebie['reward'][0], count);
			var itm:RewardItem = new RewardItem( { sID:itmData.key, count:itmData.val } );
			itm.x = count * itm.size.w;
			items.push(itm);
			addChild(itm);
			count++;
		}
		
		takeBttn = new Button( {
			caption		:Locale.__e('flash:1382952379737'),
			width		:160,
			height		:50,
			fontSize	:30
		});
		takeBttn.x = (this.width - takeBttn.width) / 2 - 20;
		takeBttn.y = this.height - takeBttn.height - 18;
		takeBttn.state = Button.DISABLED;
		container.addChild(takeBttn);
		takeBttn.addEventListener(MouseEvent.CLICK, onTake);
		
		if (App.user.freebie.status != status - 1) takeBttn.visible = false;
		if (App.user.freebie.status > status - 1) Effect.light(container, 0, 0.4);
		
		updateStatus();
	}
	
	public function get itemRect():Object {
		return { w:items.length * items[0].size.w, h:items[0].size.h };
	}
	
	private function onTake(e:MouseEvent):void  {
		if (takeBttn.mode == Button.DISABLED) return;
		takeBttn.state = Button.DISABLED;
		
		
		window.take(takeBttn);
	}

	private function get getText():String {
		for (var sid:* in freebie.reward) break;
		if (int(sid) == Stock.FANT) {
			return '+' + String(freebie.reward[sid]);
		}
		
		var info:Object = App.data.storage[sid];
		return info.title;
	}
	
	public function updateStatus():void {
		if (status - 1 == 0) {
			if (window.checkComplete()) {
				takeBttn.state = Button.NORMAL;
			}
		} else {
			if (freebie.friends <= window.invitedFriends) {
				takeBttn.state = Button.NORMAL;
			}
		}
	}
	
	public function dispose():void {
		takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
	}
}

import core.Size;

internal class RewardItem extends LayerX {
	
	public var size:Object = { w:100, h:115 };
	public var iconSize:Object = { w:65, h:65 };
	private var _item:Object;
	private var _titleLabel:TextField;
	private var _countLabel:TextField;
	private var _icon:Bitmap = new Bitmap();
	
	public function RewardItem(data:Object):void {
		_item = App.data.storage[data.sID];
		_titleLabel = Window.drawText(_item.title,
		{
			color		:0x6e411e,
			border		:false,
			//borderColor	:0xffffff, 
			fontSize	:26
		});
		
		_countLabel = Window.drawText(data.count,
		{
			fontSize	:26,
			color		:0xfdff54,
			borderColor	:0xa35514
			
		});
		
		if (this._item.sID == 2)
		{
			addChild(backgroundG);
		}
		
		addChild(_icon);
		addChild(_titleLabel);
		addChild(_countLabel);
		
		_titleLabel.width = _titleLabel.textWidth + 4;
		_titleLabel.height = _titleLabel.textHeight + 4;
		_titleLabel.x = (size.w - _titleLabel.width) / 2;
		
		_countLabel.width = _countLabel.textWidth + 4;
		_countLabel.height = _countLabel.textHeight + 4;
		_countLabel.x = (size.w - _countLabel.width) / 2;
		_countLabel.y = size.h - _countLabel.height + 10;
		
		tip = function():Object {
			return {
				title	:_item.title,
				text	:_item.description
			}
		}
		Load.loading(Config.getIcon(_item.type, _item.view), drawIcon);
	}
	
	/*private function drawIcon(data:Bitmap):void {
		_icon.bitmapData = data.bitmapData;
		
		var needScale:Number = Math.max(data.width / iconSize.w, data.height / iconSize.h);
		if (needScale > 1){
			var scale:Number = int((1/needScale)*100) / 100;
			var matrix:Matrix = new Matrix();
			matrix.scale(scale, scale);
			var smallBMD:BitmapData = new BitmapData(data.width * scale, data.height * scale, true, 0x000000);
			smallBMD.draw(data, matrix, null, null, null, true);
			_icon.bitmapData = smallBMD;
		}
		
		_icon.x = (size.w - _icon.width) / 2;
		_icon.y = (size.h - _icon.height) / 2;
		_icon.smoothing = true;
	}*/
	
	private var backgroundG:Bitmap = new Bitmap(Window.textures.dailyBonusItemGlow);
	private function drawIcon(data:Bitmap):void 
	{
		_icon.bitmapData = data.bitmapData;
		if (this._item.sID == 2)
		{
			_icon.scaleX = _icon.scaleY = 1.5;
			backgroundG.x = (size.w - backgroundG.width) / 2;
			backgroundG.y = (size.h - backgroundG.height) / 2;
		}
		else
			_icon.filters = [new GlowFilter(0xffffff, .7, 10, 10, 3)];
		Size.size(_icon, 65, 65);
		_icon.smoothing = true;
		_icon.x = (size.w - _icon.width) / 2;
		_icon.y = (size.h - _icon.height) / 2;
	}
}