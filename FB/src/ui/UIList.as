package ui 
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Sprite;
	import flash.events.Event;
	import wins.Paginator;
	
	public class UIList extends Sprite 
	{
		public static const VERTICAL:uint = 0;
		public static const HORIZONTAL:uint = 1;
		
		public static const STACK_UNSHIFT:uint = 0;		// Добавляет в начало списка
		public static const STACK_PUSH:uint = 1;		// Добавляет в конец списка
		
		public var type:uint = VERTICAL;				// Тип списка (вертикальный, горизонтальный)
		public var stackType:uint = STACK_PUSH;			// Тип добавления в список (в конец, в начало)
		
		public var startIndent:Number = 0;		// Начальный отступ
		public var finishIndent:Number = 0;		// Конечный отступ
		public var indent:Number = 0;			// Отступ между элементами списка
		public var maxItems:int = -1;			// Максимальное количество элементов, если меньше 0 то рисует все
		public var pagination:Boolean = false;	// Пагинатор
		
		public var params:Object = { };
		
		private var _listWidth:Number = 0;
		private var _listHeight:Number = 0;
		
		public var container:Sprite;
		
		public function UIList(params:Object = null) 
		{
			if (params) { 
				for (var p:* in params) {
					if (hasOwnProperty(p)) {
						this[p] = params[p];
					}else {
						this.params[p] = params[p];
					}
				}
			}
			
			super();
			
			if (this.params['backAlpha'] > 0) {
				shape = new Shape();
				shape.name = 'borders';
				super.addChild(shape);
			}
			
			container = new Sprite();
			super.addChild(container);
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			if (stackType == STACK_UNSHIFT) {
				container.addChildAt(child, 0);
			}else {
				container.addChild(child);
			}
			
			resize();
			return child;
		}
		
		public function get listWidth():Number {
			return _listWidth;
		}
		public function get listHeight():Number {
			return _listHeight;
		}
		
		public function get containsElements():Boolean {
			if (container.numChildren > 0) return true;
			return false;
		}
		
		private var shape:Shape;
		public function resize():void {
			if (type == HORIZONTAL) {
				_listWidth = startIndent;
				_listHeight = 0;
			}else {
				_listWidth = 0;
				_listHeight = startIndent;
			}
			
			for (var i:int = 0; i < container.numChildren; i++) {
				var child:* = container.getChildAt(i);
				
				if (maxItems >= 0 && (i < paginatorStart || i >= maxItems + paginatorStart)) {
					child.visible = false;
				}else if (!child.visible) {
					child.visible = true;
				}
				
				if (child.visible) {
					if (type == HORIZONTAL) {
						child.x = _listWidth;
						_listWidth += child.width;
						if (i < container.numChildren - 1) _listWidth += indent;
						if (_listHeight < child.height) _listHeight = child.height;
					}else {
						child.y = _listHeight;
						_listHeight += child.height;
						if (i < container.numChildren - 1) _listHeight += indent;
						if (_listWidth < child.width) _listWidth = child.width;
					}
					
				}
			}
			
			if (type == HORIZONTAL) {
				_listWidth += finishIndent - indent;
			}else {
				_listHeight += finishIndent - indent;
			}
			
			if (params['backAlpha'] > 0) {
				shape.graphics.clear();
				shape.graphics.beginFill(0xFF0000, params.backAlpha);
				shape.graphics.drawRect(0, 0, listWidth, listHeight);
				shape.graphics.endFill();
			}
		}
		
		private function onRemove(e:*):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			dispose();
		}
		public function dispose():void {
			for (var i:int = container.numChildren - 1; i > -1; i--) {
				var child:* = container.getChildAt(i);
				if (child.name == 'borders') continue;
				if (child.hasOwnProperty('dispose') && (child.dispose is Function)) {
					child.dispose();
				}
				if (container.contains(child)) {
					container.removeChild(child);
				}
				child = null;
			}
		}
		
		// Paginator
		private var paginatorStart:int = 0;			// Элемент с которого рисуется список
		public var paginatorStepSize:int = 1;		// Шаг прокрутки
	}

}