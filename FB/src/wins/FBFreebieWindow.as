package wins {
	
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class FBFreebieWindow extends Window {
		
		//private var helpBttn:Button;
		private var descLabel:TextField;
		private var rewardContainer:Sprite;
		private var progressBar:ProgressBar;
		private var inviteBttn:Button;
		private var sendBacking:Bitmap;
		private var sendIcon:Bitmap;
		private var sendLabel:TextField;
		private var giftBttn:Button;
		private var icon:Bitmap;
		private var countLabel:TextField;
		public var targetID:int = 1032;
		public var items:Vector.<CIcon> = new Vector.<CIcon>;
		private var awardID:int = 1;
		private var awardList:Array = [];
		private var awards:Object;
		private var data:Object;
		
		public function FBFreebieWindow(settings:Object=null) {
			if (!settings) settings = { };
			
			data = App.data.award[awardID];
			
			awards = App.user.storageRead('awards', { } );
			if (!awards[awardID]) awards[awardID] = {};
			
			settings['title'] = data.title;
			settings['width'] = settings['width'] || 640;
			settings['height'] = settings['height'] || 476;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['itemsOnPage'] = 1;
			
			super(settings);
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			
			paginator.arrowLeft.x += 52;
			paginator.arrowLeft.y -= 64;
			paginator.arrowRight.x += 26;
			paginator.arrowRight.y -= 64;
		}
		
		override public function drawBody():void {
			//exit.x += 30;
			exit.y -= 30;
			
			/*helpBttn = drawHelp();
			helpBttn.x = exit.x - 40;
			helpBttn.y = exit.y;
			helpBttn.addEventListener(MouseEvent.CLICK, onHelp);
			headerContainer.addChild(helpBttn);*/
			
			drawMirrowObjs('storageWoodenDec', 2, settings.width, 36, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', 2, settings.width, settings.height - 110, false, false, false, 1, 1);
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -44, true, true);
			
			var backLine:Shape = new Shape();
			//backLine.graphics.lineStyle(2, 0x47424e, 1, true);
			backLine.graphics.beginFill(0xe7c28d, 1);
			backLine.graphics.drawRoundRect(0, 0, settings.width - 100, 80, 40, 40);
			backLine.graphics.endFill();
			bodyContainer.addChildAt(backLine, 0);
			//backLine.alpha = 0.8;
			backLine.x = (settings.width - backLine.width) / 2;
			backLine.y = 10;
			
			// Description
			var desc_text:String = data.description;
			descLabel = drawText(desc_text, {
				width:		settings.width - 120,
				fontSize:	24,
				color:		0xfefce7,
				borderColor:0x7b4101,
				wrap:		true,
				multiline:	true,
				textAlign:	'center'
			});
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 24;
			bodyContainer.addChild(descLabel);
			
			// Content
			rewardContainer = new Sprite();
			bodyContainer.addChild(rewardContainer);
			
			for (var id:* in data.devel.req) {
				for (var sid:* in data.devel.bonus[id])
					break;
				
				awardList.push( {
					sid:		sid,
					countBonus:		data.devel.bonus[id][sid],
					count:		data.devel.req[id].count,
					id:			id,
					window:		this
				});
			}
			awardList.sortOn('count', Array.NUMERIC);
			
			for (var i:int = 0; i < awardList.length; i++) {
				var item:CIcon = new CIcon(awardList[i]);
				items.push(item);
				rewardContainer.addChild(item);
			}
			
			paginator.itemsCount = awardList.length - 4 + 1;
			paginator.update();
			
			contentChange();
			
			// Progress
			drawProgress();
			
			// Counter
			icon = new Bitmap();
			icon.x = progressBar.x - 6;
			icon.y = progressBar.y - 4;
			icon.scaleX = icon.scaleY = 0.6;
			bodyContainer.addChild(icon);
			
			countLabel = drawText('x' + String(App.user.stock.count(targetID)), {
				width:			160,
				textAlign:		'center',
				color:			0xffffca,
				borderColor:	0x522d27,
				fontSize:		36
			});
			countLabel.x = progressBar.x - 60;
			countLabel.y = progressBar.y + 50;
			bodyContainer.addChild(countLabel);
			
			// Invite
			var separator:Sprite = createSeparator(360);
			bodyContainer.addChild(separator);
			
			inviteBttn = new Button( {
				width:		160,
				height:		50,
				caption:	Locale.__e('flash:1382952380197')
			});
			inviteBttn.x = (settings.width - inviteBttn.width) / 2 ;
			inviteBttn.y = 346;
			bodyContainer.addChild(inviteBttn);
			inviteBttn.addEventListener(MouseEvent.CLICK, onInvite);
			
			// Gift
			sendBacking = backing(settings.width - 30, 142, 50, 'paperBacking');
			sendBacking.x = (settings.width - sendBacking.width) / 2;
			sendBacking.y = 400;
			bodyContainer.addChild(sendBacking);
			
			sendIcon = new Bitmap();
			sendIcon.x = sendBacking.x + 25;
			sendIcon.y = sendBacking.y + 23;
			bodyContainer.addChild(sendIcon);
			
			sendLabel = drawText(Locale.__e('flash:1435137635118'), {
				width:		330,
				fontSize:	22,
				color:		0x614605,
				borderColor:0xf0e6c1,
				wrap:		true,
				multiline:	true,
				border:		true
			});
			sendLabel.x = sendBacking.x + 120;
			sendLabel.y = sendBacking.y + (sendBacking.height - sendLabel.height) / 2 + 5;
			bodyContainer.addChild(sendLabel);
			
			giftBttn = new Button( {
				width:			136,
				height:			48,
				caption:		Locale.__e('flash:1382952380118')
			});
			giftBttn.x = sendBacking.x + 440;
			giftBttn.y = sendBacking.y + 46;
			bodyContainer.addChild(giftBttn);
			giftBttn.addEventListener(MouseEvent.CLICK, onGift);
			if (!giftable)
				giftBttn.state = Button.DISABLED;
			
			Load.loading(Config.getIcon(App.data.storage[targetID].type, App.data.storage[targetID].preview), function(data:Bitmap):void {
				sendIcon.bitmapData = data.bitmapData;
				sendIcon.smoothing = true;
				
				icon.bitmapData = data.bitmapData;
				icon.smoothing = true;
			});
			
			this.y -= 45;
			fader.y += 45;
		}
		
		public function createSeparator(top:uint = 0):Sprite {
			var bw:int = width;
			var sepTop:int = top;
			var sepItemWidth:int = -60;
			var sepWidth:int = 340;
			var separator:Bitmap = Window.backingShort(sepWidth, 'dividerLight', false);
			var separator2:Bitmap = Window.backingShort(sepWidth, 'dividerLight', false);
			separator.y = separator2.y = sepTop;
			separator.x = 45;
			separator2.scaleX = -1;
			separator2.x = separator.x + separator.width * 2 - 35;
			var sep:Sprite = new Sprite()
			sep.addChild(separator);
			sep.addChild(separator2);
			//sep.alpha = 0.5;
			return sep;
		}
		
		private function countUpdate():void {
			countLabel.text = 'x' + String(App.user.stock.count(targetID));
		}
		
		private function onInvite(e:MouseEvent):void {
			/*new NotifWindow( {
				popup:			true,
				notifyType: 	NotifWindow.TYPE_DEFAULT,
				type:			NotifWindow.OTHER_FRIENDS,
				callback:		null
			}).show();*/
			ExternalApi.apiInviteEvent();
		}
		
		// Help
		private function onHelp(e:MouseEvent):void {
			new SimpleWindow( {
				popup:		true,
				title:		settings.title,
				text:		Locale.__e('flash:1435137714546')
			}).show();
		}
		
		// Gift
		private function onGift(e:MouseEvent):void {
			if (giftBttn.mode == Button.DISABLED) return;
			
			new NotifWindow( {
				title:		settings.title,
				inviteText:	'',
				buttonText:	Locale.__e('flash:1382952380118'),
				popup:		true,
				notifyType: NotifWindow.TYPE_FREEBIE,
				type:		NotifWindow.FRIENDS,
				callback:	gift
			}).show();
		}
		
		// Progress
		private function drawProgress():void {
			var progressBacking:Bitmap = Window.backingShort(518, "prograssBarBacking3");
			progressBacking.scaleY = 1.5;
			progressBacking.smoothing = true;
			progressBacking.x = (settings.width - progressBacking.width) / 2 + 14;
			progressBacking.y = 251;
			bodyContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar({
				width:		settings.width - 120
			}, true);
			progressBar.x = (settings.width - progressBar.width) / 2;
			progressBar.y = 250;
			bodyContainer.addChild(progressBar);
			progressBar.start();
			progressBar.timer.text = '';
			setProgress();
			
			var numberOfParts:int = awardList.length;
			for (var i:int = 1; i < numberOfParts + 1; i++) {
				//var divider:Shape = new Shape();
				//divider.graphics.beginFill(0xfefefe, 1);
				//divider.graphics.lineStyle(2, 0x7c2c15, 1, false);
				//divider.graphics.drawRoundRect(0, 0, 6, 56, 6, 6);
				//divider.graphics.endFill();
				var divider:Bitmap = new Bitmap(Window.textures.progBarLineFreeby);
				divider.x = progressBar.x + (progressBar.width - 60) * i / numberOfParts + 8;
				divider.y = progressBar.y;
				bodyContainer.addChild(divider);
				
				var textLabel:TextField = drawText(awardList[i-1].count, {
					fontSize:			32,
					autoSize:			'center',
					textAlign:			'center',
					color:				0xffffcb,
					borderColor:		0x542c34
				});
				textLabel.x = divider.x + (divider.width - textLabel.width) / 2;
				textLabel.y = divider.y + divider.height + 2;
				bodyContainer.addChild(textLabel);
			}
		}
		
		public function setProgress():void {
			if (progressBar)
				progressBar.progress = progress();
			
			function progress():Number {
				var count:int = App.user.stock.count(targetID);
				var prev:int = 0;
				var maxPercent:Number = (progressBar.width - 50) / progressBar.width;
				var value:Number = 0
				
				for (var i:int = 0; i < awardList.length; i++) {
					if (awardList[i].count > count) {
						value = maxPercent * (i / awardList.length) + (1 / awardList.length) * maxPercent * ((count - prev) / (awardList[i].count - prev));
						break;
					}
					
					prev = awardList[i].count;
				}
				
				if (value == 0 && i >= awardList.length - 1) {
					value = maxPercent * (i / awardList.length) + maxPercent * (1 / awardList.length) * ((count - prev) / prev);
				}
				
				if (value > 1) value = 1;
				
				return value;
			}
		}
		
		override public function contentChange():void {
			for (var i:int = 0; i < items.length; i++)
				items[i].visible = false;
			
			for (i = paginator.page; i < paginator.page + 4; i++) {
				if (items.length <= i) continue;
				
				items[i].visible = true;
				items[i].x = 146 * (i - paginator.page);
				items[i].y = 0;
			}
			
			rewardContainer.x = 5 + (settings.width - rewardContainer.width) / 2;
			rewardContainer.y = 110;
		}
		
		public function checkStatus(id:*):Boolean {
			if (awards[awardID][id])
				return false;
			
			return true;
		}
		
		public function take(id:*, callback:Function):void {
			Post.send( {
				ctr:		'award',
				act:		'storage',
				wID:		App.map.id,
				uID:		App.user.id,
				aID:		awardID,
				id:			String(id)
			}, function(error:int, data:Object, params:Object):void {
				if (!error) {
					awards[awardID][id] = App.time;
					//App.user.storageStore('award', awards);
					
					// Bonus
					for (var i:int = 0; i < items.length; i++) {
						if (items[i].id == id) {
							BonusItem.takeRewards(data.bonus, items[i]);
						}
					}
					
					App.user.stock.addAll(data.bonus);
					App.ui.upPanel.update();
				}
				
				callback();
			});
		}
		
		public function gift(fiD:*):void {
			if (awards[awardID].hasOwnProperty('gift') && awards[awardID]['gift']) {
				giftBttn.state = Button.DISABLED;
				return;
			}
			
			giftBttn.state = Button.DISABLED;
			
			Post.send( {
				ctr:		'award',
				act:		'gift',
				wID:		App.map.id,
				uID:		App.user.id,
				aID:		awardID,
				id:			String(id),
				fID:		String(fiD)
			}, function(error:int, data:Object, params:Object):void {
				if (!error) {
					awards[awardID]['gift'] = 1;
					App.user.storageStore('awards', awards);
					App.user.stock.take(targetID, 1);
					countUpdate();
					
					giftBttn.state = Button.DISABLED;
				}else {
					giftBttn.state = Button.NORMAL;
				}
				
				Window.closeAll();
			});
		}
		
		private function get giftable():Boolean {
			try {
				if (awards[awardID]['gift'] == 1)
					return false;
			}catch (e:*) { }
			
			return true;
		}
		
		override public function close(e:MouseEvent = null):void {
			while (items.length) {
				var item:CIcon = items.shift();
				item.dispose();
			}
			
			super.close(e);
		}
	}
}

import buttons.Button;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.FBFreebieWindow;
import wins.Window;

internal class CIcon extends LayerX {
	
	private var backing:Bitmap;
	private var image:Bitmap;
	private var mark:Bitmap;
	private var icon:Bitmap;
	private var valueLabel:TextField;
	private var countLabel:TextField;
	private var takeBttn:Button;
	public var sid:int = 0;
	public var id:*;
	public var count:int = 0;
	public var countBonus:int = 0;
	public var info:Object;
	public var window:FBFreebieWindow;
	
	public function CIcon(params:Object) {
		sid = params.sid;
		id = params.id;
		info = App.data.storage[sid];
		count = params.count;
		countBonus = params.countBonus;
		window = params.window;
		
		//backing = Window.backing(130, 125, 25, 'bonusBacking');
		//addChild(backing);
		
		backing = new Bitmap(Window.textures.instCharBacking);
		backing.smoothing = true;
		addChild(backing);
		
		if (!info) {
			var tf:TextField = Window.drawText('Unreal object', {
				width:			100,
				textAlign:		'center',
				color:			0xd9f2ff,
				borderColor:	0x00206c,
				fontSize:		20
			});
			addChild(tf);
			return;
		}
		draw();
	}
	
	public function draw():void {
		image = new Bitmap();
		addChild(image);
		Load.loading(Config.getIcon(info.type, info.preview), onImageLoad);
		
		icon = new Bitmap();
		icon.x = backing.width / 2 - 34;
		icon.y = backing.height - 25;
		addChild(icon);
		Load.loading(Config.getIcon(App.data.storage[window.targetID].type, App.data.storage[window.targetID].preview), onIconLoad);
		
		mark = new Bitmap(Window.textures.checkMark);
		mark.x = (backing.width - mark.width) / 2;
		mark.y = backing.height - mark.height + 12;
		addChild(mark);
		
		valueLabel = Window.drawText(count.toString(), {
			width:			80,
			textAlign:		'left',
			color:			0xffffcf,
			borderColor:	0x502f2a,
			fontSize:		24
		});
		valueLabel.x = icon.x + 35;
		valueLabel.y = icon.y + 5;
		addChild(valueLabel);	
		
		countLabel = Window.drawText('x'+countBonus.toString(), {
			width:			80,
			textAlign:		'left',
			color:			0xffffcf,
			borderColor:	0x502f2a,
			fontSize:		24
		});
		countLabel.x = icon.x + 55;
		countLabel.y = backing.y + 15;
		addChild(countLabel);
		
		takeBttn = new Button( {
			width:		100,
			height:		32,
			caption:	Locale.__e('flash:1382952379737')
		});
		takeBttn.x = 10;
		takeBttn.y = backing.height - takeBttn.height * 0.5 - 5;
		addChild(takeBttn);
		addEventListener(MouseEvent.CLICK, onTake);
		
		checkStatus();
	}
	
	private function onImageLoad(data:Bitmap):void {
		image.bitmapData = data.bitmapData;
		image.smoothing = true;
		Size.size(image, backing.width * 0.85, backing.height * 0.85);
		image.x = backing.x + backing.width * 0.5 - image.width * 0.5;
		image.y = backing.y + backing.height * 0.5 - image.height * 0.5;
	}
	
	private function onIconLoad(data:Bitmap):void {
		icon.bitmapData = data.bitmapData;
		icon.smoothing = true;
		icon.scaleX = icon.scaleY = 0.4;
	}
	
	public function checkStatus():void {
		takeBttn.state = Button.NORMAL;
		
		if (window.checkStatus(id)) {
			mark.visible = false;
			
			if (App.user.stock.count(window.targetID) >= count) {
				takeBttn.visible = true;
				icon.y = backing.height - 60;
				valueLabel.y = icon.y + 5;
			} else {
				takeBttn.visible = false;
				icon.y = backing.height - 25;
				valueLabel.y = icon.y + 5;
			}
		} else {
			takeBttn.visible = false;
			mark.visible = true;
			//icon.y = backing.height - 25;
			//valueLabel.y = icon.y + 5;
			icon.visible = false;
			valueLabel.visible = false;
		}
	}
	
	private function onTake(e:MouseEvent):void {
		if (takeBttn.mode == Button.DISABLED) return;
		takeBttn.state = Button.DISABLED;
		
		window.take(id, checkStatus);
	}
	
	public function dispose():void {
		takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
		takeBttn.dispose();
		takeBttn = null;
		
		if (parent)
			parent.removeChild(this);
	}
}