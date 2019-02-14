package enixan.components 
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author 
	 */
	public class MagnetNode extends Sprite 
	{
		
		public var dragSize:int = 20;
		public var edgeSize:int = 3;
		public var backAlpha:Number = 1;
		
		private var backZone:Shape;
		private var dragZone:Shape;
		
		private var magetItem:DisplayObject;
		
		public function MagnetNode() {
			
			super();
			
			backZone = new Shape();
			addChild(backZone);
			
			dragZone = new Shape();
			addChild(dragZone);
			
			dragZone.name = MagnetCanvas.DRAG_ZONE;
			
		}
		
		public function resize(width:int, height:int, resizeMagnet:Boolean = true):void {
			
			if (magetItem && resizeMagnet) {
				var magnet:* = magetItem;
				if (magnet.hasOwnProperty('resize') && magnet.resize is Function && magnet.resize != null)
					magnet.resize(width - dragSize - edgeSize, height - edgeSize - edgeSize);
			}
			
			backZone.graphics.clear();
			backZone.graphics.beginFill(0x444444, backAlpha);
			backZone.graphics.drawRect(0, 0, width, height);
			backZone.graphics.endFill();
			
			dragZone.graphics.clear();
			dragZone.graphics.beginFill(0xffffff, 0);
			dragZone.graphics.drawRect(0, 0, width, dragSize);
			dragZone.graphics.endFill();
			
			dragZone.graphics.lineStyle(1, 0x4f4f4f, 1);
			dragZone.graphics.moveTo(3, dragSize - 1);
			dragZone.graphics.lineTo(width - 3, dragSize - 1);
			//dragZone.graphics.drawRect(0, 0, width, height);
			
		}
		
		public function addMagnetChild(child:DisplayObject):void {
			child.x = edgeSize;
			child.y = dragSize;
			
			magetItem = child;
			
			addChild(child);
			
			resize(child.width + edgeSize + edgeSize, child.height + dragSize + edgeSize, false);
		}
		
		public function get backgroundWidth():int {
			return backZone.width;
		}
		public function get backgroundHeight():int {
			return backZone.height;
		}
		
	}

}