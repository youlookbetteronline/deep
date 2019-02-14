package enixan.components 
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author 
	 */
	public class MagnetCanvas extends ComponentBase 
	{
		
		public static const DRAG_ZONE:String = 'dragZone';
		public static var magnetItem:MagnetNode;
		
		public var leftWidth:int = 160;
		public var rightWidth:int = 180;
		public var topHeight:int = 50;
		public var bottomHeight:int = 100;
		
		private var appStage:Stage;
		
		public function MagnetCanvas(stage:Stage) {
			
			super();
			
			//this.stage = stage;
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
		}
		
		private function onMouseDown(e:MouseEvent):void {
			
			if (magnetItem) {
				onMouseUp();
			}
			
			var list:Array = getObjectsUnderPoint(new Point(mouseX, mouseY));
			var name:Boolean;
			
			for (var i:int = 0; i < list.length; i++) {
				var child:* = list[i];
				name = false;
				
				while (child.parent) {
					if (child.name == MagnetCanvas.DRAG_ZONE)
						name = true;
					
					if (child.parent == this)
						magnetItem = child;
					
					child = child.parent;
				}
				
				if (magnetItem && name) break;
			}
			
			if (!magnetItem || !name) return;
			
			setChildIndex(magnetItem, numChildren - 1);
			magnetItem.startDrag(false, new Rectangle(0, 0, Main.appWidth - magnetItem.backgroundWidth, Main.appHeight - magnetItem.backgroundHeight));
			
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			addEventListener(Event.ENTER_FRAME, onMouseMoveEnterFrame);
		}
		private function onMouseUp(e:MouseEvent = null):void {
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			removeEventListener(Event.ENTER_FRAME, onMouseMoveEnterFrame);
			
			magnetItem.stopDrag();
			magnetItem = null;
		}
		private function onMouseMoveEnterFrame(e:Event):void {
			
		}
		
	}

}