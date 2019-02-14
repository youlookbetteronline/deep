package enixan.components 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ComponentBase extends Sprite 
	{
		
		public var toolTip:String;
		
		public function ComponentBase() {
			super();
		}
		
		
		
		/**
		 * Advenced child remove
		 * @param	beginIndex
		 * @param	endIndex
		 */
		override public function removeChildren(beginIndex:int = 0, endIndex:int = int.MAX_VALUE):void {
			
			for (var i:int = numChildren - 1; i > -1; i--) {
				var child:* = getChildAt(i);
				
				if (child is DisplayObjectContainer && child.numChildren > 0)
					child.removeChildren();
				
				if (child is ComponentBase) {
					child.dispose();
				}else if (child.hasOwnProperty('dispose') && child.dispose is Function && child.dispose != null) {
					child.dispose();
				}
			}
			
			super.removeChildren();
			removeEventListeners();
		}
		
		
		
		/**
		 * Listeners advenced manage
		 */
		private var listenersList:Vector.<ListenerObject>;
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			
			if (!listenersList)
				listenersList = new Vector.<ListenerObject>;
			
			listenersList.push(new ListenerObject(type, listener, useCapture));
		}
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			if (listenersList) {
				for (var i:int = 0; i < listenersList.length; i++) {
					if (listenersList[i].type == type && listenersList[i].listener == listener) {
						listenersList.splice(i, 1);
						break;
					}
				}
			}
			
			super.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * Remove all listeners
		 */
		public function removeEventListeners():void {
			if (!listenersList) return;
			
			while (listenersList.length) {
				removeEventListener(listenersList[0].type, listenersList[0].listener);
			}
		}
		
		
		
		/**
		 * Clear all needed functionality
		 */
		public function dispose():void { }
		
	}

}

internal class ListenerObject extends Object {
	
	public var type:String;
	public var listener:Function;
	public var useCapture:Boolean;
	
	public function ListenerObject(type:String, listener:Function, useCapture:Boolean = false) {
		
		this.type = type;
		this.listener = listener;
		this.useCapture = useCapture;
		
	}
	
}