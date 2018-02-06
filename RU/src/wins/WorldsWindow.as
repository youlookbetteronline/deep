package wins {
	
	import buttons.Button;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import wins.elements.WorldItem;
	import wins.TimerMapsWindow;

	
	public class WorldsWindow extends Window {
		
		public var only:Array;
		public var parentWindow:*;
		public var worldList:Array = [];
		public var container:Sprite;
		
		private var items:Array;
		private var background:Bitmap;
		
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
				
			/*for (var i:int = 0; i < only.length; i++) 
			{
				if (App.data.storage[only[i]].hasOwnProperty('expire') && App.data.storage[only[i]]['expire'].hasOwnProperty(App.social) && App.data.storage[only[i]]['expire'][App.social] < App.time)
				{
					only.splice(i, 1);
					i--;
				}else if (!User.inUpdate(only[i])){ 
					only.splice(i, 1);
					i--
				}else if (only[i] == 1402){
					only.splice(i, 1);
					i--
				}
			}*/
			
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
		
		override public function drawBody():void
		{
			titleLabel.y = 44 - titleLabel.height/2;
			
			container = new Sprite();
			container.y = 45;
			bodyContainer.addChild(container);
			paginator.itemsCount = worldList.length;
			paginator.update();
			
			if (worldList.length <= paginator.onPageCount) {
				paginator.visible = false;
			} else {
				paginator.visible = true;
			}
			
			contentChange();
		}
		
		override public function drawArrows():void
		{
			super.drawArrows();
			
			paginator.arrowLeft.x += 55;
			paginator.arrowLeft.y -= 12;
			paginator.arrowRight.x += 20;
			paginator.arrowRight.y -= 12;
		}
		
		override public function contentChange():void {
			clear();
			items = [];
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
				item.title.y = 85;
			}
			container.x = (settings.width - container.width) / 2;
			container.y = 0;
		}
		
		public function clear():void {
			if (!items)
				return;
			while (items.length > 0) {
				var item:WItem = items.shift();
				item.dispose();
			}
		}
		override public function close(e:MouseEvent = null):void 
		{
			clear();
			super.close(e);
		}
	}
}

import com.greensock.plugins.DropShadowFilterPlugin;
import core.Numbers;
import effects.Effect;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import units.Hero;
import utils.Finder;
import wins.WorldsWindow;
import wins.elements.WorldItem;
import wins.TravelWindow;
import wins.TimerMapsWindow;
import wins.TravelPayWindow;
import wins.Window;
import wins.SimpleWindow;

internal class WItem extends WorldItem {
	
	public var user:* = App.user;
	public var userWorlds:Object = {};
	
	private var block:Boolean = false;
	
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
	
	override public function onClick(e:MouseEvent = null):void {
		
		if (!Hero.loaded)
			return;
		if (params.callback)
		{
			params.callback(params.target, sID);
			window.close();
			return;
		}	
		if (App.data.storage[sID].hasOwnProperty('available') && App.data.storage[sID].available != '' && !TravelWindow.availableByTime(sID))
		{	
			Window.closeAll();
			new TimerMapsWindow({}).show();
			return;
		}	
		else if (TravelWindow.availableByTime(sID))
		{
			if (Numbers.countProps(App.data.storage[sID]['charge']) > 0) 
			{
				new TravelPayWindow( {
					worldID:	sID,
					content:	App.data.storage[sID].charge
				}).show();
				return;
			} else {
				if (Travel.findMaterial==null&&params.window.settings.sID!=null) 
				{
					Travel.openShop = {
						find:[int(params.window.settings.sID)]
					}
				}
				else if (params.window.settings.onMap!=null) 
				{
					Travel.openShop = {
						find:[params.window.settings.onMap]
					}
				}
				Travel.goTo(sID);
				return;
			}
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
		
		if (Travel.findMaterial==null&&params.window.settings.sID!=null) 
		{
			Travel.openShop = {
				find:[params.window.settings.sID]
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
		
		if (window is WorldsWindow) 
			Window.closeAll();
	}
	/*private function findOn(e:* = null):void 
	{
		App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, findOn);
		findOnMap(params.window.settings.onMap);
		
	}
	private function findOnMap(sID:int):void 
	{
		
		var onMap:Array = Map.findUnits([sID]);
		App.map.focusedOn(onMap[0], false, function():void{
			onMap[0].click();
		})
	}*/
}