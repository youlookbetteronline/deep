package wins.mobil 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import wins.achievement.Achievements;
	//import wins.MobileInviteWindow;
	//import wins.PromoGiftToFriend;
	/**
	 * ...
	 * @author ...
	 */
	public class TimerEventsContainer extends Sprite
	{
		
		public function TimerEventsContainer():void
		{
			super();
		}
		
		/*
		 * Доступные окна
		*/
		private const windows:Array = [
			MobileInviteWindow,
			//PromoGiftToFriend
		];
		
		/*
		 * Доступные функции
		*/
		private const functions:Array = [
			openWindow
		];
		
		/*
		 * Проверка активных событий
		*/
		public function checkEvents():void {
			var content:Array = getContent();
			createIcons(content);
		}
		
		private function getContent():Array {
			
			var content:Array = [];
					
			var data:Object = App.data.bonus;
			
			if (App.user.level < 7)
				return content;
				
			for each(var item:* in data){
				if (item.social && item.social.indexOf(App.social) >= 0 && item.bDate <= App.time && item.eDate > App.time) {
					if (!App.user.gotRefBonus || !App.user.gotRefBonus[item.type] || !App.user.gotRefBonus[item.type][item.order]) {
						content.push({icon:item.icon, needParams:true, func:0, window:0, params:{item:item}, endTime:item.eDate});
					}
				}
			}
			
			//if (Achievements.hasReadyDailyBonus())
			
			return content;
		}
		
		/*
		 * Создания иконок в панели
		*/
		private const iconWidth:int = 60;
		private var icons:Array = [];
		private function createIcons(content:Array):void {
			for (var i:* in content){
				if(content[i].hasOwnProperty('func') && functions[content[i].func])
					content[i]['onClick'] = functions[content[i].func];
				
				var icon:TimerEventIcon = new TimerEventIcon(content[i]);
				icon.x = iconWidth * i + 5;
				icons.push(icon);
				addChild(icon);
			}
		}
		
		/*
		 * Открытие любого окна из доступного массива
		*/
		private function openWindow(params:Object):void {
			var numb:int = params.window || 0;
			
			if (!windows[numb]) return;
			
			if (!params.hasOwnProperty('params')){
				var window:* = new windows[numb]();
			} else {
				window = new windows[numb](params.params);
			}
			window.show();
		}
		
		private function clearContainer():void {
			while (icons.length) {
				var child:* = icons[icons.length - 1];
				
				if (contains(child))
					removeChild(child);
				
				icons.splice(icons.indexOf(child), 1);
				
				child = null;
			}
		}
		
		public function update():void {
			clearContainer();
			
			checkEvents();
		}
	}
}