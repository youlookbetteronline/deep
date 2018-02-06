package
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Post;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import wins.Window;
	
	/**
	 * ...
	 * @author K.Shelest
	 * 1. При отправке запроса на сервер выполняется метод @eventPostStart_handler
	 * 		1.2 Все кнопки, которые находятся в массиве @buttonList становятся неактивными. 
	 * 2. При уснешном ответе от сервера выполняется метод @eventPostEnd_handler
	 * 		2.1 Делаем все кнопки снова активными.
	 * 
	 * 3. Если функция, должна обновить кнопки, то передайте её в функцию @waitPostComplete
	 * 		PostManager.instance.waitPostComplete( ваша функция );
	 * 
	 * 4. @isProgress == true, если запрос ушел на сервер, НО пока еще не вернулся.
	 * 
	 * 5. @isActive == true, менеджер должен работает.
	 * 
	 * 6. ВАЖНО!!! Что бы отключить менеджер, то просто закомитьте в функции add добавление элементов в массив buttonList
	 */
	public class PostManager
	{
		private var buttonList:Vector.<Button>;
		
		private var _isProgress:Boolean;
				
		// Синgелтон.
		private static var _instance:PostManager;
		public static function get instance():PostManager
		{
			if (_instance == null){
				_instance = new PostManager();
			}
			return _instance;
		}
		
		// Конструктор.
		public function PostManager()
		{
			_instance = this;
			
			buttonList = new Vector.<Button>();
			
			Post.instance.addEventListener(Post.EVENT_POST_START, 	eventPostStart_handler);
			Post.instance.addEventListener(Post.EVENT_POST_END, 	eventPostEnd_handler);
		}
		
		/**
		 * Добавить кнопку в менеджер событий запросов/ответа сервера.
		 */
		public function add(b:Button):void
		{			
			buttonList.push(b);
			
			// TODO: кнопки при isProgress == true должны при добавлении быть block(true);
		}
		
		/**
		 * Запрос ушел на сервер.
		 * Блокируем кнопки.
		 */
		private function eventPostStart_handler(e:Event):void 
		{
			checkButtonList();
			block(true);
			_isProgress = true;
		}
		
		/**
		 * Запрос вернулся к клиенту.
		 * Разблокируем кнопки.
		 */
		private function eventPostEnd_handler(e:Event):void 
		{
			_isProgress = false;
			block(false);
		}
		
		/**
		 * Блокируем/разблокируем кнопки.
		 */
		private function block(block:Boolean):void
		{
			for ( var i:int = 0; i < buttonList.length; i++ )
			{
				var b:Button = buttonList[i];
				
				if (block){
					b.state = Button.DISABLED;
				}
				else{
					b.state = b.oldState;
				}
			}
		}
		
		/**
		 * Проверяем список, и удалям неактуальные кнопки.
		 */
		private function checkButtonList():void
		{
			for ( var i:int = 0; i < buttonList.length; i++ )
			{
				var b:Button = buttonList[i];
				var dead:Boolean = false;
				
				// Грубая проверка на null.
				if (b == null || b.parent == null)
					dead = true;
					
				// Идем по цепочке родителей, пока не впремся в Window. 
				// Если родитель Window, то смотрим его parent - если он null, значит кнопка уже не активна.
				if ( !dead ){
					var bParent:Object = b.parent;
										
					while ( !(bParent is Window) && bParent != null )
					{
						bParent = bParent.parent;
					}
					
					if ( bParent == null )
						dead = true;
				}
				
				if (dead){
					buttonList.splice(i, 1);
					if(i > 0) i--;	
				}
			}
		}
		
		/**
		 * Выполнить функцию по окончанию запроса от сервера.
		 */
		public function waitPostComplete(func:Function/*, ... args*/):void
		{
			if (isProgress){
				Post.instance.addEventListener(Post.EVENT_POST_END, runWaitFunction);	// ждем ответа от сервера.
			}
			else{
				func();																	// выполнить функцию.
			}
			
			function runWaitFunction(e:Event):void{
				Post.instance.removeEventListener(Post.EVENT_POST_END, runWaitFunction);
				func();			// Если ошибка, значит неверно передана функция.
								// Или функция которую мы вызываем, ожидает каких то входящих данных.
			}
		}
		
		/**
		 * Истина, если запрос ушел на сервер, НО пока еще не вернулся.
		 */
		public function get isProgress():Boolean{
			return _isProgress;
		}
		
		/**
		 * Истина, если в менеджер добавлены кнопки, а значит менеджер активный.
		 */
		public function get isActive():Boolean{
			if ( buttonList && buttonList.length > 0 )
				return true;
			
			return false;
		}
		
	}
	
}