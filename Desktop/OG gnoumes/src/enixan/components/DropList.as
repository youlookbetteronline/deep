package enixan.components 
{
	
	import enixan.Util;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	public class DropList extends ComponentBase 
	{
		
		public static var focusedDropList:DropList;
		
		private var params:Object = {
			width:			140,
			height:			24,
			listHeight:		200,
			listItemHeight:	24,
			alpha:			1,
			radius:			4,
			text:			null,
			textParams:		{
				color:			0x111111,
				size:			16,
				border:			true,
				borderColor:	0x666666,
				background:		true,
				backgroundColor:0xffffff,
				type:			TextFieldType.INPUT,
				selectable:		true,
				leftMargin:		2,
				rightMargin:	2
			},
			focusInHandler:	null,
			focusOutHandler:null
		}
		
		private var label:TextField;
		private var appStage:Stage;
		
		public function DropList(stage:Stage, params:Object = null) 
		{
			super();
			
			appStage = stage;
			
			for (var s:* in params) {
				this.params[s] = params[s];
			}
			
			draw();
			
			
		}
		
		private function onKeyboardDown(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.DOWN)
				listSelectDown();
			
			if (e.keyCode == Keyboard.UP)
				listSelectUp();
			
			if (e.keyCode == Keyboard.ENTER && listSelect >= 0 && listSelect < listItems.length) {
				this.text = listItems[listSelect].label;
				hideList();
			}
			
		}
		private var listSelect:int = -1;
		private function listSelectDown():void {
			listSelect ++;
			if (listSelect >= listItems.length) listSelect = 0;
			listSetSelect(listSelect);
		}
		private function listSelectUp():void {
			listSelect --;
			if (listSelect < 0) listSelect = listItems.length - 1;
			listSetSelect(listSelect);
		}
		private function listSetSelect(index:int):void {
			for (var i:int = 0; i < listItems.length; i++) {
				if (i == index) listItems[i].select = true;
				if (i != index && listItems[i].select) listItems[i].select = false;
			}
		}
		
		private function draw():void {
			
			params.textParams['width'] = params.width;
			params.textParams['height'] = params.height;
			params.textParams['text'] = params.text;
			
			label = Util.drawText(params.textParams);
			addChild(label);
			
			label.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChange);
			label.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			label.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
			
		}
		
		private function onFocusIn(e:FocusEvent):void {
			if (params.focusInHandler != null)
				params.focusInHandler();
			
		}
		private function onFocusChange(e:FocusEvent = null):void {
			if (!listContainer) {
				if (params.focusOutHandler != null)
					params.focusOutHandler();
			}
			
			Main.clearFocus(label);
		}
		private function onTextInput(e:TextEvent):void {
			setTimeout(textInput, 10);
		}
		private function textInput():void {
			analizeList();
			createList();
		}
		
		// Выделить содержимое
		public function selectAll():void {
			label.setSelection(0,label.text.length);
		}
		
		
		/**
		 * Список
		 * Обновление данных списка
		 */
		private var list:Array = [];				// Список
		private var worklist:Array = [];			// Рабочий список
		private var listItems:Vector.<Button>;		// Список элементов списка
		private var listContainer:Sprite;			// Контейнер списка
		private var listFrom:int;					// Позиция с которой рисуется список
		private var listFilter:String;				// Позиция с которой рисуется список
		public function updateList(list:Array, redraw:Boolean = false):void {
			this.list = list;
			
			analizeList(label.text);
			
			if (redraw)
				createList();
		}
		
		
		/**
		 * Создание / пересоздание выпадающего списка
		 */
		public function createList():void {
			if (!worklist || !parent) return;
			
			if (!listItems) listItems = new Vector.<Button>;
			
			if (DropList.focusedDropList != this) {
				if (DropList.focusedDropList)
					DropList.focusedDropList.hideList();
				
				DropList.focusedDropList = this;
			}
			
			if (!listContainer) {
				listContainer = new Sprite();
				listContainer.x = x;
				listContainer.y = y + params.height + 2;
				parent.addChild(listContainer);
				
				appStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
				appStage.addEventListener(MouseEvent.CLICK, onAnywhereClick);
			}
			
			if (listContainer)
				clearList();
			
			for (var i:int = listFrom; i < worklist.length; i++) {
				if (listItems.length * params.listItemHeight > params.listHeight) break;
				
				var bttn:Button = new Button( {
					label:		worklist[i],
					width:		params.width,
					height:		params.listItemHeight,
					color1:		0xcccccc,
					color2:		0xcccccc,
					textColor:	0x111111,
					click:		onListChoose,
					onClickParams:		worklist[i]
				});
				bttn.y = listContainer.numChildren * (params.listItemHeight + 1)
				listContainer.addChild(bttn);
				listItems.push(bttn);
			}
		}
		
		/**
		 * Очистить список
		 */
		private function clearList():void {
			listSelect = -1;
			
			if (!listContainer) return;
			
			while (listItems.length)
				listItems.shift().dispose();
		}
		
		/**
		 * Скрыть список
		 */
		public function hideList():void {
			
			appStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
			appStage.removeEventListener(MouseEvent.CLICK, hideList);
			
			clearList();
			
			if (!listContainer) return;
			
			listContainer.removeChildren();
			if (listContainer.parent)
				listContainer.parent.removeChild(listContainer);
			
			listContainer = null;
			
			if (Main.app.appStage.focus != label) {
				onFocusChange();
			}
		}
		
		
		private function onAnywhereClick(e:MouseEvent):void {
			if (Main.app.appStage.focus != label)
				hideList();
		}
		
		
		/**
		 * Определение последних вводимых символов
		 * @param	text
		 */
		public function analizeList(text:String = null):void {
			listFrom = 0;
			
			listFilter = text;
			if (!listFilter) listFilter = label.text;
			
			if (listFilter && listFilter.length > 0) {
				worklist.length = 0;
				for (var i:int = 0; i < list.length; i++) {
					if (list[i].toLowerCase().indexOf(listFilter.toLowerCase()) >= 0)
						worklist.push(list[i]);
				}
			}else {
				worklist.length = 0;
				for (i = 0; i < list.length; i++)
					worklist.push(list[i]);
			}
		}
		
		/**
		 * 
		 */
		private function onListChoose(text:String):void {
			var index:int = -1;
			for (var i:int = 0; i < list.length; i++) {
				if (list[i] == text) {
					index = i;
					break;
				}
			}
			
			if (index >= 0) {
				this.text = list[i];
			}else {
				this.text = text;
			}
			
			hideList();
		}
		
		
		
		/**
		 * Содержимое текстового поля
		 */
		public function get text():String {
			return label.text;
		}
		public function set text(value:String):void {
			label.text = value;
		}
		
		
		override public function dispose():void {
			
			hideList();
			
			if (label) {
				label.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChange);
				label.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				label.removeEventListener(TextEvent.TEXT_INPUT, onTextInput);
			}
			
			if (parent)
				parent.removeChild(this);
			
		}
		
	}

}