package wins {
	
	import buttons.Button;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import wins.elements.WorldItem;
	
	public class WorldsWindow extends Window {
		
		public var okBttn:Button;
		public var only:Array;
		public var parentWindow:*;
		public var worldList:Array = [];
		
		public function WorldsWindow(settings:Object = null) {
			if (!settings) settings = { };
			
			settings['width'] = 250;
			settings['height'] = settings['height'] || 220;
			settings['title'] = settings['title'] || Locale.__e('');
			settings['popup'] = settings['popup'] || true;
			settings['hasPaginator'] = settings['hasPaginator'] || true;
			settings['hasButtons'] = settings['hasButtons'] || false;
			settings['itemsOnPage'] = settings['itemsOnPage'] || 4;
			settings['fontColor'] = 0xffd73b;
			settings['fontBorderColor'] = 0x451c00;
			settings['shadowSize'] = 0;
			settings['fontBorderSize'] = 4;
			settings['exitTexture'] = 'closeBttnMetal';
			
			if (settings['only'] && (settings['only'] is Array))
				only = settings['only'];
				
			for (var _world:int = 0; _world < only.length; _world++) 
			{
				if (App.data.storage[only[_world]].hasOwnProperty('expire') && App.data.storage[only[_world]]['expire'].hasOwnProperty(App.social) && App.data.storage[only[_world]]['expire'][App.social] < App.time){
					only.splice(_world, 1);
					_world--;
				}	
				else if (!User.inUpdate(only[_world])){
					only.splice(_world, 1);
					_world--;
				}	
				else if (only[_world] == 1402){
					only.splice(_world, 1);
					_world--;
				}		
				else if (!TravelWindow.availableByTime(only[_world])){
					only.splice(_world, 1);
					_world--;
				}	
			}
			if (settings['window'])
				parentWindow = settings['window'];
			
			init();
			settings['width'] = ((worldList.length < settings['itemsOnPage']) ? worldList.length : settings['itemsOnPage']) * 120 + 100;
			
			super(settings);
		}
		
		private function init():void {
			worldList = only;
		}
		private var background:Bitmap;
		override public function drawBackground():void
		{
			background = backing(settings.width, settings.height, 104, "capsuleWindowBacking");
			bodyContainer.addChild(background);
			
			var back:Bitmap = backing(settings.width - 70, settings.height - 70, 32, "banksBackingItem");
			back.x = background.x +(background.width - back.width) / 2;
			back.y = background.y + (background.height - back.height) / 2;
			bodyContainer.addChild(back);
		}
		
		override public function drawTitle():void 
		{
			super.drawTitle();
		}
		
		public var container:Sprite;
		override public function drawBody():void
		{
			titleLabel.y = 44 - titleLabel.height/2;
			
			container = new Sprite();
			container.y = 45;
			bodyContainer.addChild(container);
			
			//okBttn = new Button( {
				//width:200,
				//height:46,
				//caption:Locale.__e('flash:1413820223844')
			//});
			//okBttn.x = (settings.width - okBttn.width) / 2;
			//okBttn.y = settings.height - okBttn.height - 5;
			//okBttn.addEventListener(MouseEvent.CLICK, onOk);
			
			paginator.itemsCount = worldList.length;
			paginator.update();
			
			if (worldList.length <= paginator.onPageCount) {
				paginator.visible = false;
			} else {
				paginator.visible = true;
			}
			
			contentChange();
		}
		
		//public function onOk(e:MouseEvent):void 
		//{
			//new TravelWindow().show();
			//closeAll();
		//}
		
		override public function drawArrows():void
		{
			super.drawArrows();
			
			paginator.arrowLeft.x += 55;
			paginator.arrowLeft.y -= 12;
			paginator.arrowRight.x += 20;
			paginator.arrowRight.y -= 12;
		}
		
		private var items:Vector.<WItem> = new Vector.<WItem>;
		override public function contentChange():void {
			clear();
			
			for (var i:int = 0; i < paginator.onPageCount; i++) {
				if (worldList.length <= i + paginator.page * paginator.onPageCount) continue;
				var currntID:int = i + paginator.page * paginator.onPageCount;
				
				var item:WItem = new WItem( {
					sID			:worldList[currntID],
					window		:this,
					link		:Config.getIcon('Lands', worldList[currntID]),
					clickable	:World.isAvailable(worldList[i]),
					callback	:settings.callback,
					target		:settings.target,
					user		:settings.user || App.user
				});
				item.x = 10 + i * 120;
				item.y = 40;
				items.push(item);
				container.addChild(item);
				item.title.y = 90;
			}
			container.x = (settings.width - container.width) / 2;
			container.y = 0;
		}
		
		public function clear():void {
			while (items.length > 0) {
				var item:WItem = items.shift();
				item.dispose();
			}
		}
		
		public function closeAll():void {
			if (parentWindow && parentWindow is Window)
				parentWindow.close();
			
			close();
		}
		
		override public function dispose():void {
			super.dispose();
			
			//okBttn.removeEventListener(MouseEvent.CLICK, onOk);
			//okBttn.dispose();
		}
	}
}

import com.greensock.plugins.DropShadowFilterPlugin;
import effects.Effect;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import units.Hero;
import utils.Finder;
import wins.WorldsWindow;
import wins.elements.WorldItem;
import wins.TravelWindow;
import wins.Window;
import wins.SimpleWindow;
import wins.BathyscaphePayWindow;

internal class WItem extends WorldItem {
	public var user:* = App.user;
	public var userWorlds:Object = {};
	public function WItem(params:Object) {
		super(params);
		if (params.hasOwnProperty('user'))
			user = params.user;
			
		userWorlds = {};
		for each(var wID:* in user.worlds) 
		{
			userWorlds[int(wID)] = int(wID);
		}
		
		if (!userWorlds.hasOwnProperty(sID)) 
		{
			Effect.light(this, 0, .1);
		}
		defFilters = this.filters;
	}
	
	private function openWorld(callback:Function):void 
	{
		//World.openMap(sID, callback);
	}
	
	private var block:Boolean = false;
	override public function onClick(e:MouseEvent = null):void {
		
		if (!Hero.loaded)
			return;
		if (sID == User.AQUA_HERO_LOCATION && !App.user.worlds.hasOwnProperty(User.AQUA_HERO_LOCATION))
		{
			var arrayHouse:Array = Map.findUnits([820]);
			if (arrayHouse.length > 0)
			{
				Window.closeAll();
				App.map.focusedOnCenter(arrayHouse[0], false, function():void 
				{
					arrayHouse[0].showPointing("top", -arrayHouse[0].width/2,- 50);
				});
			}else{
				new WorldsWindow( {
					title	:Locale.__e('flash:1415791943192'),
					sID		:820,
					only	:[806],
					popup	:true
				}).show();
			}
			return;
		}
		if (params.clickable == false || block) 
		{
			if (!params.clickable) 
			{
				Window.closeAll();
				new TravelWindow({
					find:sID
				}).show();
			}
			return;
		}
		if (params.callback)
		{
			params.callback(params.target, sID);
			//window.close();
			return;
		}
		if (App.data.storage[sID].fuel && App.data.storage[sID].fuel > 0)
			{
				new BathyscaphePayWindow({
					worldID:	sID,
					window:		window,
					popup:		true,
					sID:		2742,
					count:		App.data.storage[sID].fuel,
					content:	{2742:App.data.storage[sID].fuel}
				}).show();
				return;
			}
			
		if (Travel.findMaterial == null && params.window.settings.sID != null)
		{
			Window.closeAll();
			Travel.openShop = {find:params.window.settings.sID};
			
			
			if (params.window.settings.sID is Array){
				Travel.openShop = {
					find:params.window.settings.sID
				}
			}else{
				Travel.openShop = {
					find:[params.window.settings.sID]
				}
			}
		}
		
			
		if (!App.user.worlds.hasOwnProperty(sID) && !App.data.storage[sID].hasOwnProperty('items')) 
		{
			block = true;
			new TravelWindow({find:App.data.storage[sID].sID, popup: true}).show();
			return;
		} else {
			if (!App.user.worlds.hasOwnProperty(sID)&&App.data.storage[sID].hasOwnProperty('items')) 
			{
				var itm:*;
				for (itm in App.data.storage[sID].items[0])
				break;
				Travel.findMaterial = {
					find:itm
				}
				Window.closeAll();
				new TravelWindow({find:sID}).show();
				
			}else 
			{
				super.onClick(e);	
			}
			
		}
		
		if (window && window.hasOwnProperty('closeAll') && window.closeAll != null) window.closeAll();
	}
}