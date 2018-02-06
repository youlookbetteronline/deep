package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import ui.Cursor;
	import ui.UserInterface;
	import units.Unit;
	/**
	 * ...
	 * @author ...
	 */
	
	public class CollectionMsgWindow extends Window
	{
		public static var isShowed:Boolean = false;
		
		public static var showed:Array = [];
		public var collection:Object;
		public var indMission:int;
		public static var self:CollectionMsgWindow;
		
		private var intervalClose:int;
		public function CollectionMsgWindow(collection:Object, settings:Object = null) 
		{
			self = this;
			if (settings == null) {
				settings = new Object();
			}
			
			this.collection = collection;
			this.indMission = indMission;
			showed.push(collection.ID);  
			settings['width'] = 360;
			settings['height'] = 126;
			settings['background'] = 'achievementUnlockBacking';
			settings['hasPaginator'] = false;
			
			settings['hasFader'] = false;
			settings['faderClickable'] = false;
			settings['faderAlpha'] = 1;
			settings['autoClose'] = true;
			settings['hasExit'] = false;
			
			settings['title'] = collection.description || 'Остров пасхи';  
			
			settings['totalStars'] = settings.totalStars || 5;  
			
			super(settings);
			updateContent();
			isShowed = true;
			
			intervalClose = setInterval(doClose, 5500);
			
			this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void
		{
			new CollectionWindow({find:[App.data.storage[collection.materials[0]].collection]}).show();
		}
		
		private var tweenClose:TweenLite;
		private function doClose():void
		{
			clearInterval(intervalClose);
			tweenClose = TweenLite.to(this, 0.3, { x:this.x + 210, y:this.y + 190, scaleX:0.5, scaleY:0.5, alpha:0, onComplete:function():void { close(); }});
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 50, 'tipUp');
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			
			this.x = -int(App.self.stage.stageWidth / 2) + this.width / 2 + 100;
			this.y = int(App.self.stage.stageHeight / 2) - this.height - 20;
			
			
			opened = false;
		}
		override public function drawTitle():void 
		{
			var descTitle:TextField = Window.drawText(settings.title, {
				fontSize:26,
				color:0xffffff,
				textAlign:"left",
				borderColor:0x094068,
				borderSize:2
			});
			descTitle.width = descTitle.textWidth + 5;
			bodyContainer.addChild(descTitle);
			descTitle.x = this.x + (settings.width - descTitle.width) / 2;
			descTitle.y = this.y + 10;
		}
		
		public var items:Vector.<CollectionItem> = new Vector.<CollectionItem>();
		private function drawItems():void 
		{
			var i:Number = 0;		
			for each(var sID:uint in collection.materials) 
			{
				var item:CollectionItem = new CollectionItem(sID, this);
				items.push(item);
				item.y = 40;
				item.x = 13 + item.width * i;
				i+=1.02;
				bodyContainer.addChild(item);
				//if (App.user.stock.data[item.sID] < minCount)
					//minCount = App.user.stock.data[item.sID];
				item.check();
				
				
			}
		}
			
		override public function show():void 
		{
			if (App.map != null) 
			{
				for each(var trans:Unit in App.map.transed) 
				{
					var bmp:Bitmap = trans.bmp;
					
					trans.transparent = false;
					App.map.transed.splice(App.map.transed.indexOf(trans), 1);
				}
			}
			
			//if(App.map != null){
				//App.map.untouches();
				//
				//if (App.map.moved != null) 
				//{
					//App.map.moved.previousPlace();
				//}
			//}
			
			//App.tips.hide();
			//Cursor.prevType = Cursor.type;
			//Cursor.type = "default";
			//Cursor.plant = false;
			
			if (App.ui != null)
			{
				App.ui.bottomPanel.cursorsPanel.visible = false;
			}
				var hasQueue:Boolean = false;
				for (var i:int = 0; i < App.self.windowContainer.numChildren; i++)
				{
					var backWindow:* = App.self.windowContainer.getChildAt(i);
					if (backWindow is Window && (settings.forcedClosing == true || backWindow.settings.autoClose == true)) 
					{
						if (backWindow is LevelUpWindow) 
						{
							hasQueue = true;
							return;
						}else if (backWindow is OracleWindow) 
						{ 
							hasQueue = true;
							return;
						}else if (backWindow.settings.strong) 
						{
							hasQueue = true;
							//return;
						}else if ((backWindow is AchivementMsgWindow))
						{
							backWindow.close();
							//hasQueue = true;
						}else if (settings.popup) 
						{ 
							backWindow.close();
						}else 
						{
							//backWindow.close();
							hasQueue = true;
						}
					}else if (backWindow is Window && !(backWindow is AchivementMsgWindow)  &&  settings.popup == false) 
					{
						hasQueue = true;
					}
				}
				
				App.ui.addChildAt(this, 1);
				layer.visible = false;
				addChild(layer);
				if (hasQueue == true) 
				{
					return;
				}
				create();
				drawItems();
			SoundsManager.instance.playSFX(settings.openSound);
			
		}
		
		/*private function getMission():int 
		{
			var num:int = 1;
			for (var cnt:* in collection.missions) {
				if (App.user.ach[collection.ID][cnt] > 1000000000)
					num++;
			}
			
			if (num == 0) num = 1;
			return num;
		}*/
		
		/*private function onTake(e:MouseEvent):void 
		{
			close();
			new AchivementsWindow( { find:collection.ID } ).show();
			e.stopImmediatePropagation();
		}*/
		
		/*override public function drawTitle():void 
		{
		}*/
		
		override protected function onRefreshPosition(e:Event = null):void
		{ 		
			super.onRefreshPosition(e);
			
			this.x = -int(App.self.stage.stageWidth / 2) + this.width / 2 + 63;
			this.y = int(App.self.stage.stageHeight / 2) - this.height - 26;
		}
		
		override public function drawExit():void {
			/*exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 50;
			exit.y = 0;
			exit.addEventListener(MouseEvent.MOUSE_DOWN, close);*/
		}
		
		override public function close(e:MouseEvent=null):void {
				
			if (settings.hasAnimations == true) {
				startCloseAnimation();
			}else {
				dispatchEvent(new WindowEvent("onBeforeClose"));
				dispose();			
			}	
			
			if(e != null)
				e.stopImmediatePropagation();
		}
		
		public function updateContent():void 
		{
			settings['content'] = [];
			for (var sID:* in App.data.storage) {
				var item:Object = App.data.storage[sID];
				item['sID'] = sID;
				if (item.type == 'Collection' && item.visible) {
					settings.content.push(item);
					
					var full:Boolean = true;
					for each(var mID:int in item.materials) {
						if (App.user.stock.count(mID) == 0) {
							full = false;
							break;
						}
					}
					if (full && item.order > 0) {
						item.order *= -1;
					}else if (!full && item.order < 0) {
						item.order *= -1;
					}
				}
			}
			settings.content.sortOn('order', Array.NUMERIC);
			for each(var maters:* in settings.content)
			{
				for each(var itms:* in maters.materials){
					if (itms == collection.sid)
					{
						collection.materials = maters.materials;
						settings['title'] = maters.title;
					}
				}
			}
			
			//paginator.itemsCount = settings.content.length;
			//paginator.update();
		}
		
		override public function dispose():void {
			clearInterval(intervalClose);
			
			self = null;
			isShowed = false;
			
			if (fader != null && fader.hasEventListener(MouseEvent.CLICK)) {
				fader.removeEventListener(MouseEvent.CLICK, onFaderClick);
				fader = null;
			}
			
			if (this.stage != null)
			{
				this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				this.stage.removeEventListener(Event.RESIZE, onRefreshPosition);
			}
			
			if (settings.hasPaginator && paginator != null) {
				paginator.dispose();
			}
			
			if (this.parent != null) {
				this.parent.removeChild(this);
			}else {
				if(App.self.windowContainer.contains(this)){
					App.self.windowContainer.removeChild(this);
				}
			}
			
			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
				var backWindow:* = App.self.windowContainer.getChildAt(i);

				if (backWindow is Window && !(backWindow is AchivementMsgWindow) && backWindow.opened == false) {
					backWindow.create();
					break;
				}else if(backWindow is Window)
				{
					break;
				}
			}
			
			if(settings.returnCursor && Cursor.type != "stock" && Cursor.type != "water"){
				Cursor.type = Cursor.prevType;
			}
			
			dispatchEvent(new WindowEvent("onAfterClose"));		
			
			if (clearQuestsTargets) 
			{
				Quests.help = false;
			}
			
			this.removeEventListener(MouseEvent.CLICK, onClick);	//	отписка от собития открытия окна с указаной колекцией
		}
	}

}

import buttons.ImageButton;
import buttons.MoneyButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.Window;
import wins.CollectionWindow;

internal class CollectionItem extends LayerX {
	
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var material:Object;
	public var sID:int;
	public var countOnStock:TextField;
	public var window:*;
		
	public function CollectionItem(sID:int, window:*) {
		
		this.sID = sID;
		this.window = window;
		
		background = Window.backing(66, 66, 32, "banksBackingItem");
		addChild(background);
		
		bitmap = new Bitmap(null, "auto", true);
		addChild(bitmap);
		
		material = App.data.storage[sID];
		
		/*title = Window.drawText(material.title, {
			color:0x814f31,
			borderColor:0xfaf9ec,
			fontSize:17,
			multiline:true,
			textAlign:"center",
			wrap:true,
			width:background.width - 20
		});
		
		title.x = 10;
		title.y = 10;
		addChild(title);*/
		
		Load.loading(Config.getIcon('Material', material.view), onLoad);
		
		drawCount();

		function shuffle(a:*,b:*):int {
			var num : int = Math.round(Math.random()*2)-1;
			return num;
		}
	
		var cID:int = material['collection'];
		var places:Array = [];
		if (App.data.collectionIndex[cID] != undefined) {
			for each(var id:* in App.data.collectionIndex[cID]){
				places.push(id);
			}
			places = places.sort(shuffle);
		}
		
		tip = function():Object {
			//var text:String = Locale.__e('flash:1383041279569');
			/*var titles:Array = [];
			var max:int = 5;
			for each(var id:* in places) {
				if(App.data.storage[id] != undefined){
					if((titles.indexOf(App.data.storage[id].title) == -1) &&(User.inUpdate(id))){
						titles.push(App.data.storage[id].title);
						max--;
					}
					if (max == 0) {
						break;
					}
				}
			}
			text += titles.join(', ');*/
			return {
				title:material['title'],
				text:material['description']
			}
		}
		
	}
	
	private function onLoad(data:Bitmap):void 
	{
		bitmap.bitmapData = data.bitmapData;
		//bitmap.scaleX = bitmap.scaleY = .7;
		Size.size(bitmap, background.width - 16, background.height - 16);
		bitmap.smoothing = true;
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2;
		
	}
	
	public function drawCount():void {
		
		var count:int = App.user.stock.count(sID);
		//count = (sID == 216)?2:count;
		if (count == 0) return;
		//count = 15;
		
		var counterSprite:LayerX = new LayerX();
		counterSprite.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380305")
			};
		};
		
		var countOnStock:TextField = Window.drawText('x' + count || "", {
			color		:0xffffff,
			borderColor	:0x0a3756,  
			fontSize	:20,
			borderSize	:2,
			autoSize	:"left"
		});
		
		var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
		
		addChild(counterSprite);
		counterSprite.x = background.width - counterSprite.width - 33;
		counterSprite.y = 122;
		
		addChild(countOnStock);
		countOnStock.x = background.x + background.width - countOnStock.width - 5;
		countOnStock.y = background.y + background.height - countOnStock.height - 5;
	}
	
	public function check():void 
	{
		var count:uint = App.user.stock.count(sID);
		/*count = (sID == 216)?2:count;*/
		if (count == 0) 
		{  
			bitmap.alpha = 0.4;
			if(countOnStock)
				countOnStock.text = "0";
		}else 
		{
			bitmap.alpha = 1;
			if(countOnStock)
				countOnStock.text = String(count);
		}
	}
}