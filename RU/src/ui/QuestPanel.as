package ui
{
	import flash.display.Sprite;
	
	
	public class QuestPanel extends Sprite
	{
		public static const PROGRESS:uint = 1;
		public static const NEW:uint = 2;
		
		public var questsList:Array = [];
		public var icons:Array = [];
		public var paginator:QuestPaginator;
		public var showNewMode:Boolean = false;
		public var _parent:LeftPanel;
		public var dY:int = 240;
		public var prevY:int = 0;
		
		private var container:Sprite = new Sprite();
		private var countDoChange:int = 0;
		private var time:int = 0;
		
		public static var newQuests:Object = {};
		public static var progressQuest:uint = 0;		
		public static var pCase:uint = 0
		
		public function QuestPanel(parent:LeftPanel)
		{
			_parent = parent;
			paginator = new QuestPaginator(App.user.quests.opened, 5, this);
			addChild(container);
			paginator.drawArrows();
			resize();
		}
		
		public function clearIconsGlow():void 
		{
			/*for (var i:int = 0; i < icons.length; i++)
			{
				icons[i].bttn.hideGlowing();
				icons[i].bttn.hidePointing();
			}*/	
		}
		
		public function refresh():void 
		{
			var newQuests:Array = [];
			
			for each(var item:* in App.user.quests.opened) 
			{
				if (item.fresh)
				{
					QuestPanel.newQuests[item.id] = App.time + 10;
					newQuests.push(item.id);					
				}
			}
			
			if (newQuests.length > 0)
			{
				focusedOnQuest(newQuests[0]);
				change();
				return;
			}
			
			change();
		}
		
		public function focusedOnQuest(qID:uint, questMission:int = 1, type:uint = 0):void
		{
			if (questMission != 0 && App.data.quests[qID].missions && App.data.quests[qID].missions.hasOwnProperty(questMission) && App.data.quests[qID].missions[questMission].event == 'zone')
				return;
			if (type == PROGRESS) {
				progressQuest = qID;
			}
			for (var i:int = 0; i < shownList.length; i++)
			{
				if (shownList[i].id == qID)
				{
					paginator.focusedOn(i);
					break;
				}
			}
			
			for (var f:int = 0; f < icons.length; f++) 
			{
				if (icons[f].qID == qID)
				{
					var _mission:int = (questMission == 0) ? 1 : questMission;
					icons[f].glowIcon(_mission, 3000, true, type);
					break;
				}
			}
		}
		
		public function resize(promo:Boolean = false):void
		{
			var delta:uint = 100;
			if (App.self.stage.stageWidth > 935)
				delta = 70;
			
			this.y = -120 + 20;
			
			var newHeight:uint = App.self.stage.stageHeight - dY - delta + 30 - 10 - 30;
			if (promo) 
			{
				newHeight -= 60;	
			}
			paginator.resize(newHeight);
		}		
		
		public function availableInWorld(openedItem:Object):Boolean
		{
			var item:Object = App.data.quests[openedItem.id];
			
			if (App.data.quests[item.ID].type == 1) return false;
			//if (App.data.quests[item.ID].duration > 0 && App.user.quests.data[item.ID].created + App.data.quests[item.ID].duration * 3600 <= App.time) 
				//return false;
			if ((item.dream == null || item.dream == '')/* && App.user.worldID == User.HOME_WORLD*/)
			{
				return true;	
			}
			
			for each(var dream:* in item.dream) 
			{
				if (dream == 5)
					dream  = 4;
				if (dream == '' || dream == App.user.worldID)
				{
					return true;
				}
			}
			return false;
		}
		
		public function get shownList():Array 
		{
			sortQuests();
			var reslt:Array = [];
			for (var i:* in App.user.quests.opened)
			{
				if (availableInWorld(App.user.quests.opened[i])) 
				{
					if (App.user.quests.opened[i].type <= 0)
						reslt.push(App.user.quests.opened[i]);								
				}
			}
			return reslt;
		}
		
		public function get shownCount():int 
		{
			var count:int = 0;
			for (var i:* in App.user.quests.opened)
			{
				if (availableInWorld(App.user.quests.opened[i])) {
					count++;
				}
			}
			return count;
		}
		
		public function sortQuests():void
		{
			return;
			for each(var qst:* in App.user.quests.opened)
			{
				var territory:int = 0;
				qst['terSort'] = 0;
				if (App.data.quests[qst.id].hasOwnProperty('dream') && App.data.quests[qst.id]['dream'] != null)
				{
					territory = App.data.quests[qst.id]['dream'][0];
					if (territory == 5)
						territory = 4;
					if (territory == App.user.worldID)
						qst['terSort'] = 1;
				}
			}
			App.user.quests.opened.sortOn('terSort', Array.NUMERIC | Array.DESCENDING);
		}
		
		public function change():void
		{			
			removeIcons();
			//sortQuests();
			var itemNum:int = 0;
			var padding:int = 4;
			prevY = -6;
			
			container.y = dY;
			
			var endItem:int = paginator.endItem;
			var counter:int = 0;
			var freshQuest:Boolean = false;
			for (var i:int = paginator.startItem; i < Math.min(paginator.endItem, shownList.length); i++)
			{				
				var item:Object = shownList[i];
				
				if (item == null || item.type > 0)
				{
					continue;
				}
				
				time = (App.user.quests.data[item.id].created + App.data.quests[item.id].duration * 3600) - App.time;
				if (time < 0)
				{
					time = 0;
				}
				
				if (!(App.data.quests[item.id].hasOwnProperty("duration")) || (App.data.quests[item.id].duration && time > 0) || (App.data.quests[item.id].duration == 0)) 
				{
					
					for each ( var fresh:* in App.user.quests.opened){
						if(fresh.id == item.id)
							freshQuest = fresh.fresh;
					}
					var icon:QuestIcon = new QuestIcon(item, this, freshQuest);
					counter++;
					icons.push(icon);					
					container.addChildAt(icon, 0);
					icon.x =  10;					
					icon.y = prevY;					
					itemNum ++;
					prevY += 86 /*+ padding*/;
					
				} else {
				}				
			}
			
			if (counter < (paginator.endItem - paginator.startItem) - 1 && paginator.startItem != 0)
			{
				paginator.startItem = 0;
				paginator.endItem = paginator.startItem + paginator.itemsOnPage;
				paginator.change();
			}
		}
		
		public function distinguishQuest(qID:uint, type:uint = 0):void
		{
			for (var i:int = 0; i < App.user.quests.opened.length; i++) 
			{
				if (App.user.quests.opened[i].id == qID)
				{
					App.user.quests.currentTarget = icons[i];
					break;
				}
			}			
		}
		
		private function removeIcons():void 
		{
			for each(var icon:QuestIcon in icons)
			{
				icon.dispose();
				//icon.clear();
				//container.removeChild(icon);
				//icon = null;
			}			
			icons = [];
		}
	}
}

import buttons.ImageButton;
import core.Size;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import ui.QuestPanel;
import wins.Window;

internal class QuestPaginator extends Sprite
{	
	public var startItem:uint = 0;
	public var endItem:uint = 0;
	public var length:uint = 0;
	public var itemsOnPage:uint = 0;	
	public var _parent:QuestPanel;
	public var data:Array;
	public var arrowUp:ImageButton;
	public var arrowDown:ImageButton;
	
	public function QuestPaginator(data:Array, itemsOnPage:uint, _parent:*) 
	{		
		this._parent = _parent;
		this.data = data;
		length = data.length;
		startItem = 0;
		this.itemsOnPage = itemsOnPage;
		endItem = startItem + itemsOnPage;
	}
	
	public function up(e:* = null):void 
	{
		if (startItem > 0) 
		{
			startItem --;
			endItem = startItem + itemsOnPage;
			change();
		}
	}
	
	public function down(e:* = null):void 
	{		
		if (_parent.shownCount < startItem + itemsOnPage)
		{
			return;
		}
		
		startItem ++;
		endItem = startItem + itemsOnPage;
		change();
	}
	
	public function change():void
	{		
		length = _parent.shownList.length
		
		if (startItem == 0)
		{
			arrowUp.visible = false;// аменить на false
		}else{
			arrowUp.visible = true;
		}	
		
		if(startItem + itemsOnPage >= length)
			arrowDown.visible = false;
		else
			arrowDown.visible = true;
		
		_parent.change();
	}	
	
	public function drawArrows():void
	{
		if (arrowUp == null && arrowDown == null)
		{
			arrowUp = new ImageButton(Window.textures.arrowUp, {scaleX:1, scaleY:1, sound:'arrow_bttn'});
			arrowDown = new ImageButton(Window.textures.arrowUp, {scaleX:1, scaleY:-1, sound:'arrow_bttn'});
			
			_parent.addChild(arrowUp);
			Size.size(arrowUp, 30, 30); 
			arrowUp.x = 31;
			
			_parent.addChild(arrowDown);
			Size.size(arrowDown, 30, 30); 
			arrowDown.x = 31;
			
			arrowUp.addEventListener(MouseEvent.CLICK, up);
			arrowDown.addEventListener(MouseEvent.CLICK, down);
		}
		
		setArrowsPosition();
	}
	
	public function focusedOn(id:uint):void 
	{
		startItem = id;
		endItem = startItem + itemsOnPage;
		
		/*if (endItem > App.user.quests.opened.length) 
		{
			endItem = App.user.quests.opened.length;
			if (endItem - itemsOnPage < 0)
				startItem = 0;
			else
				startItem = endItem - itemsOnPage;
		}*/
		if (endItem > _parent.shownList.length) 
		{
			endItem = _parent.shownList.length;
			if (endItem - itemsOnPage < 0)
				startItem = 0;
			else
				startItem = endItem - itemsOnPage;
		}
		change();
	}
	
	public function resize(_height:uint):void 
	{
		itemsOnPage = Math.floor(_height / 86)
		startItem = 0;
		if (itemsOnPage > 9)
		itemsOnPage = 9;
		endItem = startItem + itemsOnPage;
		setArrowsPosition();
		change();
	}
 
	public function setArrowsPosition():void 
	{
		arrowUp.y  = _parent.dY - 32;
		//arrowUp.filters = [new GlowFilter(0xfffff, .7, 4, 4, 10)]; 
		/*if(itemsOnPage == 9)
		{
			arrowDown.y = arrowUp.y + (itemsOnPage + 1) * 70 + 44;
		}
		else if(itemsOnPage == 6)
		{
			arrowDown.y = arrowUp.y + (itemsOnPage + 1) * 70 + 67;
		}else if(itemsOnPage == 1)
		{
			arrowDown.y = arrowUp.y + (itemsOnPage + 1) * 70 + -16;
		}else if(itemsOnPage == 2)
		{
			arrowDown.y = arrowUp.y + (itemsOnPage + 1) * 70 + 0;
		}else if(itemsOnPage == 5)
		{
			arrowDown.y = arrowUp.y + (itemsOnPage + 1) * 70 + 50;
		}else if(itemsOnPage == 3)
		{
			arrowDown.y = arrowUp.y + (itemsOnPage + 1) * 70 + 20;
		}else if(itemsOnPage == 4)
		{
			arrowDown.y = arrowUp.y + (itemsOnPage + 1) * 70 + 35;
		}else 
		{*/
			arrowDown.y = arrowUp.y + (itemsOnPage + 1) * 86 - 42;
		//}
	}
}