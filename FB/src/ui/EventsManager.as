package ui 
{
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author ...
	 */
	public class EventsManager extends Sprite
	{
		
		public var queue:Array = [];
		public static var self:EventsManager;
		public function EventsManager()
		{
			self = this;
		}
		
		public function removeEvent(eventItem:EventItem):void {
			var index:int = queue.indexOf(eventItem);
			if (index != -1) {
				remove(index);
			}
		}
		
		public function remove(id:int):void {
			var item:* = queue[id];
			queue.splice(id, 1);
			
			TweenLite.to(item, 0.3, { alpha:0 } );
			setTimeout(function():void {
				item.parent.removeChild(item);
				item.dispose();
				refresh();
			},300);
		}
		
		public function refresh():void
		{
			for (var i:int = 0 ; i < queue.length; i++) 
			{
				var _point:int = 0;
				if (i > 0)
					_point = queue[i - 1].movePointTo + queue[i - 1].height;
				queue[i].moveTo(_point);
			}
		}
		
		public static function addEvent(event:Object):void
		{
			if (self == null) return;
			var eventItem:EventItem = new EventItem(event);
			
			self.queue.push(eventItem);
			if (self.queue.length > maxCount) 
			{
				self.removeEvent(self.queue[0]);
			}
			self.showEvent(eventItem);
			
		}
		
		private var dY:int = 45;
		public function showEvent(eventItem:EventItem):void 
		{
			var startY:int =  App.self.stage.stageHeight - 320;
			var finishY:int = 0;
			if (queue.length > 1)
				finishY = queue[queue.length - 2].movePointTo + queue[queue.length - 2].height;
				
			addChild(eventItem);
			eventItem.x = -eventItem.backWidth - 8;
			eventItem.y = startY;
			eventItem.moveTo(finishY);
		}
		
		private function get actionSpace():int
		{
			//if (App.ui.salesPanel && App.ui.salesPanel.promoIcons.length > 0) {
				//return 100;
			//}
			return 0;
		}
		
		public static var maxCount:int = 0;
		public function resize():void {
			this.x = App.self.stage.stageWidth - actionSpace;
			this.y = 160;
			
			var freeSize:int = App.self.stage.stageHeight - 160 - 320;
			maxCount = Math.ceil(freeSize / dY);
			
			if (queue.length > maxCount) {
				for (var i:int = maxCount; i < queue.length; i++) 
				{
					if (!item) continue;
					var item:EventItem = queue[i];
					item.parent.removeChild(item);
					item.dispose();
				}
				queue.splice(maxCount, queue.length - maxCount);
				refresh();
			}
		}
		
		public static var eventsStrings:Object = {
			'storage': {
				'building': {
					text:Locale.__e('flash:1459344345'),
					live:6
				},
				'material': {
					text:Locale.__e('flash:1459344346'),
					live:6
				}
			},
			'reward': {
				'building': {
					hasTitle:true,
					text:Locale.__e('flash:1459344347'),
					live:6
				},
				'material': {
					text:Locale.__e('flash:1459344348'),
					live:6
				}
			},
			'hero': {// Эвенты героя
				'say': {
					hasTitle:true,
					noIcon:true,
					live:6
				},
				'move': {
					hasTitle:true,
					noIcon:true,
					live:6
				},
				'simple': {
					hasTitle:true,
					noIcon:true,
					live:6
				},
				'place': {
					hasTitle:true,
					noIcon:true,
					live:6
				},
				'bonus': {
					hasTitle:true,
					noIcon:true,
					live:6
				}
			},
			'resource': {
				'kick': {
					hasTitle:true,
					live:6
				}
			},
			'learn': {
				'technology': { 
					text:Locale.__e('flash:1459344350'),
					live:6
				},
				'rank':{
					hasTitle:true,
					noInfoTitle:true,
					text:Locale.__e('flash:1459344351'),
					live:6
				}
			},
			'add': {
				'stock': {
					text:Locale.__e('flash:1459344352'),
					live:6
				}
			},
			'buy': {
				hasTitle:true,
				text:Locale.__e('flash:1459344353'),
				live:6
			},
			'place': {
				hasTitle:true,
				text:Locale.__e('flash:1459344354'),
				live:6
			},
			'move': {
				text:Locale.__e('flash:1459344355')
			}
		}
	}
}


import com.greensock.easing.Strong;
import com.greensock.TweenLite;
import core.AvaLoad;
import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.setTimeout;
import ui.UserInterface;
import ui.EventsManager;
import utils.SocketEventsHandler;
import wins.Window;
import wins.elements.BonusList;

internal class EventItem extends Sprite {
	
	public var backWidth:int = 180;
	private var title:TextField
	private var title2:TextField
	private var bg:Shape;
	private var avatar:Bitmap;
	private var avatarBacking:Shape;
	private var avatarSprite:Sprite;
	private var bitmap:Bitmap;
	private var event:Object;
	private	var bgHeight:int = 0;
	public function EventItem(event:Object) {
		
		var dY:int = 130;
		this.event = event;
		
		var eventsString:Object = EventsManager.eventsStrings[event.act];
		if (EventsManager.eventsStrings[event.act].hasOwnProperty(event.ctr))
			eventsString = EventsManager.eventsStrings[event.act][event.ctr];
			
		var item:Object = App.data.storage[event.sID];
		var liveTime:int = eventsString.live;
		var titleText:String = eventsString.text;
		var shadow:DropShadowFilter = new DropShadowFilter(2, 90, 0, 1, 2, 2, 2);
		if (event.hasOwnProperty('titleText'))
			titleText = event.titleText;
			
		var size:Point = new Point(150, 30);
		var pos:Point = new Point(0, 10);
		
		title = Window.drawTextX(titleText, size.x, size.y, pos.x, pos.y, this, {
			fontSize	:20,
			color		:0xffdc62,
			border		:false,
			textAlign	:'center',
			width		:backWidth - 30
		});
		//title.border = true;
		addChild(title);
		
		drawAvatar();
		if (event.ctr == 'bonus' || event.ctr == 'place')
		{
			title2  = Window.drawText(event.text, { //текстовка
				color		:0xffffff,
				borderColor	:0x052256,
				fontSize	:18,
				multiline	:true,
				wrap		:true,
				textAlign	:"center",
				width		:backWidth-6
			});
			
			//title2.border = true;
			addChild(title2);
			title2.x = 3;
			title2.y = 45;
			//bgHeight = title2.textHeight;
			if (event.ctr == 'bonus')
				addBonus();
			if (event.ctr == 'place')
				addPlaceTarget();
			
			
		}else{
			title2  = Window.drawText(event.text, { //текстовка
				color		:0xffffff,
				borderColor	:0x052256,
				fontSize	:18,
				multiline	:true,
				wrap		:true,
				textAlign	:"center",
				width		:backWidth-6
			});
			
			//title2.border = true;
			addChild(title2);
			title2.x = 3;
			title2.y = 45;
			bgHeight = title2.textHeight;
		}
		
		bg = new Shape();
		bg.graphics.beginFill(0x15256d, .75);
		bg.graphics.drawRoundRect(0, 13, backWidth, 40 + bgHeight + 10, 25, 25);
		bg.graphics.endFill();
		
		addChildAt(bg, 0);
		
		var that:EventItem = this;
		setTimeout(function():void {
			EventsManager.self.removeEvent(that);
		}, liveTime * 1000);
		
		this.addEventListener(MouseEvent.CLICK, onMouseClick);
	}
	
	private	var blist:BonusList;
	private function addBonus():void 
	{
		var _bonus:Object = Treasures.convert2(event.bonus);
		blist = new BonusList(_bonus, false, {hasTitle:false, width:backWidth - 10});
		addChild(blist);
		blist.x = 3;
		blist.y = title2.y + title2.height + 5;
		
		bgHeight = title2.height + 5 + blist.height;
	}
	
	private var placeSprite:LayerX;
	private function addPlaceTarget():void 
	{
		placeSprite = new LayerX();
		var targetIcon:Bitmap = new Bitmap();
		var targetText:TextField  = Window.drawText(App.data.storage[event.sID].title, {
			color		:0xffffff,
			borderColor	:0x052256,
			fontSize	:18,
			multiline	:true,
			wrap		:true,
			textAlign	:"left",
			width		:backWidth-61
		});
		targetText.x = 55;
		targetText.y = (50 - targetText.height) / 2;
		Load.loading(Config.getIcon(App.data.storage[event.sID].type, App.data.storage[event.sID].preview),function(data:*):void{
			targetIcon.bitmapData = data.bitmapData;
			Size.size(targetIcon, 50, 50);
			placeSprite.addChild(targetIcon);
		});
		placeSprite.addChild(targetText);
		addChild(placeSprite);
		placeSprite.x = 3;
		placeSprite.y = title2.y + title2.height + 5;
		
		bgHeight = title2.height + 5;
		if (placeSprite.height < 50)
			bgHeight += 50;
		else
			bgHeight += placeSprite.height;
	}
	
	private function drawAvatar():void 
	{
		avatarSprite = new Sprite();
		addChild(avatarSprite);
		avatarBacking = new Shape();
		
		avatarBacking.graphics.beginFill(0x15256d, .75);
		avatarBacking.graphics.drawCircle(19, 19, 19);
		avatarBacking.graphics.endFill();
		
		avatarSprite.addChild(avatarBacking);
		avatarSprite.x = backWidth - avatarBacking.width;
		
		avatar = new Bitmap();
		avatarSprite.addChild(avatar);
		
		var photo:String = 'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg';
		if (event.hasOwnProperty('uID') && SocketEventsHandler.personages.hasOwnProperty(event['uID']))
			photo = SocketEventsHandler.personages[event['uID']].photo;
			
		new AvaLoad(photo, onLoad);
	}
	
	private function onLoad(data:*):void 
	{
		if (data == null) {
			errCall();
		}else{
			//if(preloader.parent)
			//removeChild(preloader);
			avatar.bitmapData = data.bitmapData;
			avatar.x = avatarBacking.x + (avatarBacking.width - avatar.width) / 2;
			avatar.y = avatarBacking.y + (avatarBacking.height - avatar.height) / 2;
			
			avatar.smoothing = true;
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawCircle(16, 16, 16);
			shape.graphics.endFill();
			
			shape.x = avatar.x + (avatar.width - shape.width) / 2;
			shape.y = avatar.y + (avatar.height - shape.height) / 2;
			
			avatar.mask = shape;
			avatarSprite.addChild(shape);
		}
	}
	
	public function errCall():void 
	{
		//removeChild(preloader);
		var noImageBcng:Bitmap = new Bitmap(UserInterface.textures.friendsBacking);
		onLoad(noImageBcng);
	}
	
	public function onMouseClick(e:MouseEvent):void 
	{
		dispose();
		EventsManager.self.removeEvent(this);
	}
	
	private var imgCont:Sprite;
	public var tween:TweenLite = null;
	public var movePointTo:int = 0;
	public function moveTo(_y:int):void 
	{
		movePointTo = _y;
		if (tween != null) {
			tween = null;
		}
			
		tween = TweenLite.to(this, 0.5, { y:_y, ease:Strong.easeOut } );
	}
	
	public function dispose():void {
		this.removeEventListener(MouseEvent.CLICK, onMouseClick);
	}
}