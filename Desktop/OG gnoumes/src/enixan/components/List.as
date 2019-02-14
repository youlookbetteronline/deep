package enixan.components 
{
	import com.greensock.TweenLite;
	import enixan.Size;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author 
	 */
	public class List extends ComponentBase 
	{
		
		public static const VERTICAL:uint = 0;
		public static const HORIZONTAL:uint = 1;
		
		public var focusedNodes:Vector.<ListNode> = new Vector.<ListNode>;
		
		public var container:Sprite;
		public var scroller:Sprite;
		public var maska:Shape;
		public var background:Shape;
		
		public var blockDrag:Boolean;
		public var haveScroller:Boolean;
		public var currWidth:int = 0;
		public var currHeight:int = 0;
		public var nodeWidth:int = 0;
		public var nodeHeight:int = 50;
		public var currStage:Stage;
		
		public var type:uint = 0;
		
		public var params:Object = {
			backgroundColor:		0x444444,
			backgroundAlpha:		1,
			indent:					2,
			autoListMove:			true,	// Автоматиическое движение списка при достижении края списка
			autoListMoveUp:			50,		// Отспуп края списка
			autoListMoveDown:		50		// Отспуп края списка
		}
		
		protected var data:Array;
		public var content:Array;
		
		public var dynamicViewType:Boolean;		// Отрисвывать содержимое динамически
		
		public function List(stage:Stage, width:int, height:int, params:Object = null) {
			
			super();
			
			if (params) {
				for (var s:* in params) {
					this.params[s] = params[s];
					
					if (s == 'type')
						type = params[s];
					
					if (s == 'haveScroller')
						haveScroller = params[s];
				}
			}
			
			currWidth = width;
			currHeight = height;
			currStage = stage;
			
			nodeWidth = currWidth;
			
			data = [];
			content = [];
			
			background = new Shape();
			drawBackground();
			addChild(background);
			
			container = new Sprite();
			addChild(container);
			
			maska = new Shape();
			drawMaska();
			addChild(maska);
			
			scroller = new Sprite();
			scroller.graphics.beginFill(0xbbbbbb);
			scroller.graphics.drawRect(0, 0, 4, 4);
			scroller.graphics.endFill();
			scroller.addEventListener(MouseEvent.MOUSE_DOWN, onScrollDown);
			scroller.visible = haveScroller;
			addChild(scroller);
			
			container.mask = maska;
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
		}
		
		/**
		 * Изменить размер
		 * @param	width
		 * @param	height
		 */
		public function resize(width:int, height:int):void {
			currWidth = width;
			currHeight = height;
			
			drawMaska();
			drawBackground();
			initScroller();
		}
		
		
		/**
		 * 
		 */
		public function get containerWidth():int {
			if (dynamicViewType)
				return nodeWidth * data.length;
			
			return container.width;
		}
		public function get containerHeight():int {
			if (dynamicViewType)
				return nodeWidth * data.length;
			
			return container.height;
		}
		
		
		
		
		public function initScroller():void {
			if (haveScroller && type == VERTICAL && container.height > maska.height) {
				scroller.visible = true;
				scroller.x = maska.x + maska.width + 1;
				scroller.height = maska.height * maska.height / container.height;
			}else if(haveScroller && type == HORIZONTAL && container.width > maska.width) {
				scroller.visible = true;
				scroller.y = maska.y + maska.height + 1;
				scroller.width = maska.width * maska.width / container.width;
			}else {
				scroller.visible = false;
			}
		}
		
		protected function drawMaska():void {
			maska.graphics.clear();
			maska.graphics.beginFill(0xff0000, 0.1);
			maska.graphics.drawRect(0, 0, currWidth, currHeight);
			maska.graphics.endFill();
		}
		protected function drawBackground():void {
			background.graphics.clear();
			background.graphics.beginFill(this.params.backgroundColor, this.params.backgroundAlpha);
			background.graphics.drawRect(0, 0, currWidth, currHeight);
			background.graphics.endFill();
		}
		
		public function clear():void {
			while (content.length) {
				content.shift().dispose();
			}
			checkPosition(true);
		}
		
		/**
		 * List of datas, where is data of node
		 * @param	list
		 */
		public function addAll(list:Array, update:Boolean = true):void {
			for (var i:int = 0; i < list.length; i++) {
				add(list[i], update);
			}
			initScroller();
		}
		
		/**
		 * Data of node
		 * @param	data
		 */
		public function add(info:Object, update:Boolean = true):void {
			
			if (update)
				data.push(info);
			
			var node:ListNode = new ListNode(this, info);
			
			if (type == VERTICAL) {
				node.y = container.numChildren * (nodeHeight + params.indent);
			}else {
				node.x = container.numChildren * (nodeHeight + params.indent);
			}
			
			container.addChild(node);
			content.push(node);
			
		}
		
		
		/**
		 * Select of item
		 */
		public function select(node:ListNode, update:Boolean = true):void {
			if (params.click is Function && params.click != null)
				params.click(node);
			
			dispatchEvent(new Event(Event.SELECT));
		}
		
		
		public function draw():void {
			clear();
			addAll(data, false);
			checkPosition();
		}
		
		
		
		/**
		 * Find node by view.
		 * @param	viewInfo
		 */
		public function find(viewInfo:ViewInfo, update:Boolean = true):void {
			if (content.length == 0) return;
			for (var i:int = 0; i < content.length; i++) {
				if (content[i].data.item == viewInfo) {
					select(content[i], update);
					break;
				}
			}
		}
		
		
		/**
		 * Wheel
		 */
		private var tween:TweenLite;
		private function onMouseWheel(e:MouseEvent):void {
			
			if (type == VERTICAL) {
				if (e.delta > 0) {
					container.y += 50;
				}else {
					container.y -= 50;
				}
			}else {
				if (e.delta > 0) {
					container.x += 50;
				}else {
					container.x -= 50;
				}
			}
			
			checkPosition(true);
		}
		
		
		/**
		 * Перемещение внутри списка
		 */
		private var draged:ListNode, touched:ListNode, dragView:Sprite, dragWay:Number, lastX:int, lastY:int, touchTime:int;
		private function onMouseDown(e:MouseEvent):void {
			
			if (draged) draged.stopDrag();
			
			lastX = mouseX;
			lastY = mouseY;
			dragWay = 0;
			
			if (blockDrag || hasEventListener(MouseEvent.MOUSE_MOVE)) return;
			
			touched = getNode(e.target as DisplayObject);
			
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Main.app.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		private function onMouseMove(e:MouseEvent):void {
			dragWay += Math.sqrt((lastX - mouseX) * (lastX - mouseX) + (lastY - mouseY) * (lastY - mouseY));
			
			if (dragWay > 4) {
				if (!draged) {
					
					draged = getNode(e.target as DisplayObject);
					
					var target:* = e.target;
					while (true) {
						if (target is ListNode) {
							draged = target;
							break;
						}
						
						if (!target || !target.parent || target == container)
							break;
						
						target = target.parent;
					}
					
					if (!draged) return;
					
					if (type == VERTICAL) {
						draged.startDrag(false, new Rectangle(draged.x, -200, draged.x, container.height + 200));
					}else {
						draged.startDrag(false, new Rectangle(-200, draged.y, maska.width + 200, draged.y));
					}
					draged.parent.swapChildrenAt(draged.parent.getChildIndex(draged), draged.parent.numChildren - 1);
					
					
					if (dragView) {
						container.removeChild(dragView);
						dragView = null;
					}
					
					dragView = new Sprite();
					dragView.graphics.beginFill(0xffffff, 0.8);
					dragView.graphics.drawRect(0, -2, currWidth, 5);
					dragView.graphics.endFill();
					container.addChild(dragView);
					
					
					if (params.autoListMove && !dragView.hasEventListener(Event.ENTER_FRAME)) {
						dragView.addEventListener(Event.ENTER_FRAME, onDragViewEvent);
					}
				}
				
				// Позиция маркера
				dragView.y = (nodeHeight + params.indent) * int((mouseY - container.y) / (nodeHeight + params.indent));
				if (dragView.y < 0) dragView.y = 0;
				if (dragView.y > (nodeHeight + params.indent) * content.length) dragView.y = (nodeHeight + params.indent) * content.length;
				
			}
			
		}
		private function onMouseUp(e:MouseEvent):void {
			
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Main.app.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			if (dragView) {
				dragView.removeEventListener(Event.ENTER_FRAME, onDragViewEvent);
				container.removeChild(dragView);
				dragView = null;
			}
			
			var index:int = content.indexOf(draged);
			if (index >= 0 && index < content.length) {
				var object:Object = data.splice(index, 1)[0];
				var pos:int = (mouseY - container.y) / nodeHeight;
				if (pos < 0) pos = 0;
				if (pos > data.length) pos = data.length;
				data.splice(pos, 0, object);
				
				draw();
			}
			
			if (dragWay < 4 && touched) {
				if (touchTime + 200 > getTimer()) {
					touched.dispatchEvent(new MouseEvent(MouseEvent.DOUBLE_CLICK));
				}else{
					touchTime = getTimer();
				}
			}
			
			if (draged) {
				draged.stopDrag();
				draged = null;
			}
			
		}
		private function getNode(target:*):ListNode {
			while (true) {
				if (target is ListNode) {
					return target;
				}
				
				if (!target || !target.parent || target == container)
					break;
				
				target = target.parent;
			}
			
			return null;
		}
		
		
		/**
		 * Автоматическое движение списка при достижении предела при перемещении элементов через drag`&`drop
		 * @param	e
		 */
		private function onDragViewEvent(e:Event):void {
			if (mouseY < params.autoListMoveUp) {
				container.y += (params.autoListMoveUp - mouseY) * 0.4;
				
				if (container.y > maska.y + nodeHeight) {
					container.y = maska.y + nodeHeight;
				}else {
					draged.y -= (params.autoListMoveUp - mouseY) * 0.4;
				}
			}
			
			if (mouseY > currHeight - params.autoListMoveDown) {
				container.y -= (params.autoListMoveDown + mouseY - currHeight) * 0.4;
				draged.y += (params.autoListMoveDown + mouseY - currHeight) * 0.4;
				
				/*if (container.y < background.height - container.height - nodeHeight) {
					container.y = background.height - container.height - nodeHeight;
				}else {
					
				}*/
			}
		}
		
		
		/**
		 * Находится под курсором
		 */
		public function get isSelectedTouch():Boolean {
			for (var i:int = 0; i < focusedNodes.length; i++) {
				if (focusedNodes[i].mouseX > 0 && focusedNodes[i].mouseX < focusedNodes[i].nodeWidth && focusedNodes[i].mouseY > 0 && focusedNodes[i].mouseY < focusedNodes[i].nodeHeight)
					return true;
			}
			
			return false;
		}
		
		
		/**
		 * Drag move list
		 */
		/*private var touched:Boolean, moving:Boolean, currX:int, currY:int, lastX:int, lastY:int;
		private function onMouseDown(e:MouseEvent):void {
			if (tween) {
				tween.kill();
				tween = null;
			}
			
			if (touched)
				onMouseUp();
			
			touched = true;
			
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		private function onMouseUp(e:Event = null):void {
			if (moving) {
				container.stopDrag();
				container.removeEventListener(Event.ENTER_FRAME, onMouseMoveEnterFrame);
				currStage.removeEventListener(Event.MOUSE_LEAVE, onMouseUp);
			}else {
				removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
			
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			currX = mouseX;
			currY = mouseY;
			
			touched = false;
			moving = false;
			
			checkPosition(true);
		}
		private function onMouseMove(e:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			moving = true;
			
			container.startDrag(false, dragRectangle);
			container.addEventListener(Event.ENTER_FRAME, onMouseMoveEnterFrame);
			currStage.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
		}
		private function onMouseMoveEnterFrame(e:Event):void {
			lastX = mouseX;
			lastY = mouseY;
		}*/
		
		
		private function checkPosition(animate:Boolean = false):void {
			var targetY:int;
			
			if (type == VERTICAL) {
				if (container.y > maska.y) {
					targetY = maska.y;
					
					if (animate) {
						tween = TweenLite.to(container, 0.2, { y:targetY } );
					}else {
						container.y = targetY;
					}
				}else if (container.y < background.height - container.height) {
					if (background.height > container.height) {
						targetY = maska.y;
					}else {
						targetY = background.height - container.height;
					}
					
					if (animate) {
						tween = TweenLite.to(container, 0.2, { y:targetY } );
					}else {
						container.y = targetY;
					}
				}
				
				scroller.y = (maska.height - scroller.height) * -container.y / (container.height - maska.height);
				if (scroller.y < 0) scroller.y = 0;
				if (scroller.y > maska.height - scroller.height) scroller.y = maska.height - scroller.height;
			}else {
				if (container.x > maska.x) {
					targetY = maska.x;
					
					if (animate) {
						tween = TweenLite.to(container, 0.2, { x:targetY } );
					}else {
						container.x = targetY;
					}
				}else if (container.x < background.width - container.width) {
					if (background.width > container.width) {
						targetY = maska.x;
					}else {
						targetY = background.width - container.width;
					}
					
					if (animate) {
						tween = TweenLite.to(container, 0.2, { x:targetY } );
					}else {
						container.x = targetY;
					}
				}
				
				scroller.x = (maska.width - scroller.width) * -container.x / (container.width - maska.width);
				if (scroller.x < 0) scroller.x = 0;
				if (scroller.x > maska.width - scroller.width) scroller.x = maska.width - scroller.width;
			}
		}
		
		
		
		private function onScrollDown(e:MouseEvent):void {
			if (type == VERTICAL) {
				scroller.startDrag(false, new Rectangle(scroller.x, 0, 0, maska.height - scroller.height + 1));
			}else{
				scroller.startDrag(false, new Rectangle(0, scroller.y, maska.width - scroller.width + 1, 0));
			}
			scroller.addEventListener(Event.ENTER_FRAME, onScrollMove);
			Main.app.addEventListener(MouseEvent.MOUSE_UP, onScrollUp);
		}
		private function onScrollUp(e:Event = null):void {
			Main.app.removeEventListener(MouseEvent.MOUSE_UP, onScrollUp);
			scroller.removeEventListener(Event.ENTER_FRAME, onScrollMove);
			scroller.stopDrag();
		}
		private function onScrollMove(e:Event):void {
			if (type == VERTICAL) {
				container.y = -scroller.y * (container.height - maska.height) / (maska.height - scroller.height);
			}else{
				container.x = -scroller.x * (container.width - maska.width) / (maska.width - scroller.width);
			}
		}
		
		
		
		private var rectangle:Rectangle;
		protected function get dragRectangle():Rectangle {
			if (!rectangle) {
				rectangle = new Rectangle(0, maska.height, 0, -maska.height - container.height);
			}
			
			return rectangle;
		}
		
		
		override public function dispose():void {
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			scroller.removeEventListener(MouseEvent.MOUSE_DOWN, onScrollDown);
			onScrollUp();
		}
		
	}

}