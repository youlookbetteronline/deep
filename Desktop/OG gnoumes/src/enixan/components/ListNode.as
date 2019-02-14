package enixan.components 
{
	import effects.Effect;
	import enixan.Util;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author 
	 */
	public class ListNode extends ComponentBase 
	{
		
		protected var background:Sprite;
		protected var titleLabel:TextField;
		
		public var nodeWidth:int;
		public var nodeHeight:int;
		
		protected var list:List;
		public var data:Object;
		
		public function ListNode(list:List, data:Object) {
			
			super();
			
			this.list = list;
			this.data = data;
			
			if (data.width) nodeWidth = data.width;
			else nodeWidth = list.nodeWidth;
			
			if (data.height) nodeHeight = data.height;
			else nodeHeight = list.nodeHeight;
			
			draw();
			
			addEventListener(MouseEvent.CLICK, onClick);
			
		}
		
		public function draw():void {
			
			background = new Sprite();
			background.graphics.beginFill(data.color || 0x111111, data.backAlpha || 1);
			background.graphics.drawRect(0, 0, nodeWidth, nodeHeight);
			background.graphics.endFill();
			addChild(background);
			
			titleLabel = Util.drawText( {
				text:		data.text || '...',
				size:		data.textSize || 16,
				color:		data.textColor || 0xffffff,
				textAlign:	data.textAlign || 'left',
				width:		data.textWidth || width - 15
			});
			titleLabel.x = 10;
			titleLabel.y = background.height * 0.5 - titleLabel.textHeight * 0.5 - 2;
			addChild(titleLabel);
			
		}
		
		private function onClick(e:MouseEvent):void {
			focus();
			
			if (data.click != null)
				data.click(this);
		}
		
		
		// Focus
		public function focus(passive:Boolean = false):void {
			clearFocus(this);
			
			Effect.light(background, 0.1);
			
			if (list.focusedNodes.indexOf(this) == -1)
				list.focusedNodes.push(this);
			
			if (!passive) {
				list.select(this);
			}
			
		}
		public function unfocus():void {
			Effect.light(background);
		}
		public function clearFocus(extendNode:ListNode = null):void {
			var index:int = list.focusedNodes.length;
			while (--index > -1) {
				var node:ListNode = list.focusedNodes[index];
				if (node == extendNode) continue;
				list.focusedNodes.splice(index, 1);
				node.unfocus();
			}
		}
		
		
		/**
		 * Вернуть значение в списке
		 */
		public function get index():int {
			return list.content.indexOf(this);
		}
		
		
		override public function dispose():void {
			if (parent)
				parent.removeChild(this);
			
			removeEventListener(MouseEvent.CLICK, onClick);
		}
		
	}

}