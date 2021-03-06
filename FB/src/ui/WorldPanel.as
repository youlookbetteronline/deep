package ui 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import wins.elements.WorldItem;
	import wins.Paginator;
	import wins.TravelWindow;
	import wins.Window;
	import wins.WindowEvent;
	
	public class WorldPanel extends Sprite {
		
		public static var allWorlds:Array = [];
		
		private var paginator:Paginator;
		private var backing:Shape;
		private var container:Sprite;
		
		public var currentWidth:int = 0;
		
		public static function init():void {
			//var included:Array = [];	
			////included = TravelWindow.getAllIncluded();
			////var included:Array = [];
			//for (var s:String in App.data.storage) {
				//if (App.data.storage[s].type == 'Lands' && App.data.storage[s].enabled == 1) {
					//if (int(s) == User.HOME_ALIEN_WORLD) continue;
					//if (!User.inUpdate(s)) continue;					// Недоступно в обновлениях
					//if (App.data.storage[s].size == 1) continue;		// Не показывать минилокации
					//if (included.indexOf(int(s)) == -1)
						//continue;
					//allWorlds.push(s);
				//}
			//}
		}
		
		public function WorldPanel() 
		{
			if (allWorlds.length == 0) init();
			visible = false;
			
			container = new Sprite();
			addChild(container);
			
			paginator = new Paginator(0, 1, 1, {
				hasButtons:	false
			});
			paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);
			addChild(paginator);
			drawArrows();
			
			App.self.addEventListener(AppEvent.ON_OWNER_COMPLETE, onOwnerComplete);
		}
		
		private function drawArrows():void {
			paginator.drawArrow(this, Paginator.LEFT,  0, 0, { scaleX: -0.4, scaleY:0.6 } );
			paginator.drawArrow(this, Paginator.RIGHT, 0, 0, { scaleX:0.4, scaleY:0.6 } );
			paginator.arrowLeft.y = 30;
			paginator.arrowRight.y = 30;
			paginator.arrowLeft.visible = true;
			paginator.arrowRight.visible = true;
		}
		
		override public function set width(value:Number):void {
			if (value == super.width) return;
			super.width = value;
			draw();
		}
		
		public function resize():void {
			if (!visible) return;
			
			currentWidth = App.self.stage.stageWidth / 2 - 100;
			container.x = App.self.stage.stageWidth - currentWidth + (currentWidth - container.width) / 2;
			paginator.arrowLeft.x = container.x - 12;
			paginator.arrowRight.x = container.x + container.width + 9;
			paginator.page = 0;
			show();
			
			paginator.itemsCount = (iconsOnPage < worldIcons.length) ? (worldIcons.length - iconsOnPage + 1) : 0;
			paginator.update();
		}
		
		public function onOwnerComplete(e:AppEvent):void {
			visible = true;
			draw();
		}
		public function hide():void {
			visible = false;
			clear();
		}
		
		public var worldIcons:Vector.<WorldItem> = new Vector.<WorldItem>;
		public function draw():void {
			clear();
			
			for (var i:int = 0; i < allWorlds.length; i++) {
				if (App.data.storage[allWorlds[i]].enabled) {
					var worldIcon:WorldItem = new WorldItem( { sID:allWorlds[i], clickable:App.user.worlds.hasOwnProperty(allWorlds[i]), scale:1, hasTitle:false, align:'center' } );
					worldIcons.push(worldIcon);
				}
			}
			worldIcons.sort(sorter);
			
			resize();
		}
		
		private function sorter(a:*, b:*):int {
			if (int(a.info.order) > int(b.info.order)) {
				return 1;
			} else if (int(a.info.order) < int(b.info.order)) {
				return -1;
			} else {
				if (int(a.sID) > int(b.sID)) {
					return 1;
				}else if (int(a.sID) < int(b.sID)) {
					return -1;
				}else {
					return 0;
				}
			}
		}
		
		private const ICON_WIDTH:int = 96;
		private var iconsOnPage:int = 0;
		private function show():void {
			if (int(Travel.currentFriend.uid) == 1) {
				hide();
				return;
			}
			iconsOnPage = Math.floor((currentWidth - 80) / ICON_WIDTH);
			
			for (var i:int = 0; i < worldIcons.length; i++) {
				if (i >= paginator.page && i < paginator.page + iconsOnPage) {
					if (!container.contains(worldIcons[i])) {
						container.addChild(worldIcons[i]);
					}
					worldIcons[i].x = ICON_WIDTH / 2 + ICON_WIDTH * (i - paginator.page);
					worldIcons[i].y = 5 + ICON_WIDTH / 2;
				}else {
					if (container.contains(worldIcons[i])) {
						container.removeChild(worldIcons[i]);
						worldIcons[i].x = 0;
					}
				}
				
				if (int(worldIcons[i].sID) == App.owner.worldID)
					addMarker(worldIcons[i]);
			}
			
			if (iconsOnPage < worldIcons.length) {
				showPaginator();
			} else {
				hidePaginator();
			}
			
			container.x = App.self.stage.stageWidth - currentWidth + (currentWidth - container.width) / 2;
			paginator.arrowLeft.x = container.x - 12;
			paginator.arrowRight.x = container.x + container.width + 9;
		}
		
		private function clear():void {
			if (backing && contains(backing)) removeChild(backing);
			
			while (worldIcons.length > 0) {
				var worldItem:WorldItem = worldIcons.shift();
				worldItem.dispose();
			}
		}
		
		private function addMarker(item:WorldItem):void {
			var title:TextField = Window.drawText(Locale.__e('flash:1436169149173'), {
				fontSize:24,
				color:0xf6fff8,
				borderColor:0x7e4f35,
				multiline:true,
				textAlign:"center",
				width:item.width
			});
			title.x = -title.width / 2;
			title.y = 20;
			item.addChild(title);
			
			item.startGlowing();
		}
		
		public function showPaginator():void {
			if (paginator.page > 0) {
				paginator.arrowLeft.visible = true;
			}
			if (paginator.page + iconsOnPage < worldIcons.length) {
				paginator.arrowRight.visible = true;
			}
		}
		
		public function hidePaginator():void {
			paginator.arrowLeft.visible = false;
			paginator.arrowRight.visible = false;
		}
		
		private function onPageChange(e:WindowEvent):void {
			show();
		}
		
		public function dispose():void {
			clear();
			paginator.dispose();
		}
	}

}