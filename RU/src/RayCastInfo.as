package 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import wins.Window;
	
	/**
	 * ...
	 * @author K.Shelest
	 * 1. Что бы показать окно RayCastInfo.instance.show( @stage );
	 * 2. Нужно передать основную сцену @stage
	 * 3. Что бы закрыть окно, нажимаем кнопку Esc. 
	 */
	public class RayCastInfo
	{
		private var stage:Stage;
		private var sprite:Sprite;
		private var back:Shape;
		private var text:TextField;
		private var close:Boolean;
		
		// Синgелтон.
		private static var _instance:RayCastInfo;
		public static function get instance():RayCastInfo
		{
			if (_instance == null){
				_instance = new RayCastInfo();
			}
			return _instance;
		}
		
		// Конструктор.
		public function RayCastInfo()
		{
			if (_instance){
				throw new Error("Вы не можете создавать экземпляры класса при помощи конструктора. Для доступа к экземпляру используйте RayCastInfo.instance.")
			}else{
				_instance = this;
			}
		}
		
		/**
		 * Показать окно.
		 * @layer - слой, на котором будет отрисовано окно.
		 */
		public function show(_stage:Stage):void
		{	
			if (sprite != null)
				return;
			
			stage = _stage;
			
			// тело окна
			sprite = new Sprite();
			stage.addChild(sprite);
			
			// подложка
			back = new Shape();
			back.graphics.beginFill(0x000000,0.8);
			back.graphics.drawRect(0,0,50,50);
			back.graphics.endFill();
			sprite.addChild(back);
			
			// текст
			text = Window.drawText("", {
				fontSize:18,
				border:false,
				multiline:true,
				autoSize:true,
				textAlign:"left"
			});
			
			//text.height = 100;
			text.width = 1200;
			
			sprite.addChild(text);
			
			stage.addEventListener(Event.ENTER_FRAME, update);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, exit);
		}
		
		/**
		 * Обновить список тел, которые находятся под курсором.
		 */
		private function changeList():void
		{
			var i:int;
			var j:int;
			var copyList:Array;
			var rayCastList:Array = stage.getObjectsUnderPoint(new Point(stage.mouseX, stage.mouseY));
						
			var list:Array = new Array();				// список всех обьектов под курсором.
						
			for (i = 0; i < rayCastList.length; i++ )
			{
				// Проверка на App and Map.
				if (rayCastList[i].parent is App || rayCastList[i].parent is Map)
					continue;
				
				var checking:Boolean = true;
				
				var target:Object = rayCastList[i].parent;
				
				while (checking)
				{								
					list.push(target);
					
					if (target.parent == null){
						target = null;
					}
					else{
						target = target.parent;
					}
				
					// выход из цикла.
					if (target == null || target is App){
						checking = false;
					}
				}	
			}
			
			copyList = new Array();
			
			// Удаляем из списка, повроряющие елементы.
			for ( i = 0; i < list.length; i++ )
			{
				var trg:Object = list[i];
				
				var str:String = String(trg);
				
				if (str == "[object Sprite]"   || 
					str == "[object LayerX]"   || 
					str == "[object Map]"){		//TODO
					continue;
				}
				
				var add:Boolean = true;
				for ( j = 0; j < copyList.length; j++ )
				{
					if (trg == copyList[j]){
						add = false;
					}
				}
				
				if (add){
					copyList.push(trg);
				}
			}
			
			// Далее заполняем текстовое поле.
			text.text = "";
			
			for ( i = 0; i < copyList.length; i++ )
			{
				if ( copyList[i].hasOwnProperty("info") )
				{
					var info:String = String(copyList[i]);
					
					if (copyList[i].hasOwnProperty("type")){
						info += "  type = " + copyList[i].type;
					}
					
					if (copyList[i].info && copyList[i].info.hasOwnProperty("sID")){
						info += "  sid = " + copyList[i].info.sID;
					}
					
					if (copyList[i].hasOwnProperty("id")){
						info += "  id = " + copyList[i].id;
					}
					
					if (copyList[i].hasOwnProperty("coords")){
						info += "  x = " + copyList[i].coords.x;
					}
					
					if (copyList[i].hasOwnProperty("coords")){
						info += "  y = " + copyList[i].coords.z;
					}
					
					text.appendText(info);
				}
				else
				{
					text.appendText(copyList[i]);
				}
				
				text.appendText("\n");
			}
						
			back.width = text.textWidth + 5;
			back.height = text.textHeight + 5;
		}
		
		private function update(e:Event):void
		{
			changeList();
			changePosition();
		}
		
		/**
		 * Позиционирование окна.
		 */
		private function changePosition():void 
		{
			var offset:Number = 30;
			
			sprite.x = stage.mouseX + offset;
			sprite.y = stage.mouseY + offset;
			
			// Проверка на левый угол.
			if (stage.mouseX > (App.self.stage.stageWidth / 2) + 200)
			{
				sprite.x -= back.width + offset*2;
			}
			
			// Проверка на левый угол.
			if (stage.mouseY > (App.self.stage.stageHeight / 2) + 200)
			{
				sprite.y -= back.height + offset;
			}
				
		}
		
		/**
		 * Закрыть окно.
		 */
		private function exit(e:KeyboardEvent):void 
		{
			if (e.keyCode != Keyboard.ESCAPE)
				return;
			
			stage.removeEventListener(Event.ENTER_FRAME, update);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, exit);
						
			while (sprite.numChildren > 0) sprite.removeChildAt(0);
			
			stage.removeChild(sprite);
			sprite = null;
			stage = null;
		}
			
		
	}
	
}