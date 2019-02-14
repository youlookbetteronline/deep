package enixan.components 
{
	import com.greensock.TweenLite;
	import enixan.Util;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	public class ComponentToolTip extends ComponentBase
	{
		
		public static const X_MARGIN:int = 10;
		public static const Y_MARGIN:int = 10;
		public static const MAX_TEXTFIELD_WIDTH:int = 400;
		
		public static var toolTip:ComponentToolTip;		// Описание
		public static var toolTipTarget:ComponentBase;	// От чего описание
		
		public var text:String;
		
		public function ComponentToolTip(target:ComponentBase) 
		{
			ComponentToolTip.dispose();
			ComponentToolTip.toolTipTarget = target;
			ComponentToolTip.toolTip = this;
			
			text = toolTipTarget.toolTip;
			
			var textField:TextField = Util.drawText( {
				text:		text,
				autoSize:	TextFieldAutoSize.LEFT,
				width:		200,
				size:		12,
				color:		0x111111,
				multiline:	true/*,
				wordWrap:	true*/
			});
			if (textField.width > MAX_TEXTFIELD_WIDTH)
				textField.wordWrap = true;
			
			textField.x = 5;
			textField.y = 5;
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xeeeeee, 0.9);
			shape.graphics.drawRoundRect(0, 0, textField.width + 10, textField.height + 10, 6, 6);
			shape.graphics.endFill();
			shape.filters = [new DropShadowFilter(5, 60, 0x000000, 0.5)];
			
			addChild(shape);
			addChild(textField);
			
			Main.app.appStage.addChild(this);
			ComponentToolTip.relocate(new Point(Main.app.appStage.mouseX,Main.app.appStage.mouseY), false);
		}
		
		private var removeTween:TweenLite;
		public function remove():void {
			if (removeTween) return;
			ComponentToolTip.toRemove(this);
			removeTween = TweenLite.to(this, 0.3, { alpha:0, onComplete:function():void {
				dispose();
			}} );
			//TweenLite.to(this, 1, { alpha:0 } );
		}
		override public function dispose():void {
			if (removeTween) {
				removeTween.kill();
				removeTween = null;
			}
			
			if (parent) parent.removeChild(this);
			removeChildren();
			
			if (ComponentToolTip.toolTip == this) {
				ComponentToolTip.toolTip = null;
				ComponentToolTip.toolTipTarget = null;
			}
		}
		
		
		/**
		 * Удаление текущего toolTip
		 */
		public static function dispose():void {
			if (ComponentToolTip.toolTip)
				ComponentToolTip.toolTip.dispose();
		}
		
		
		/**
		 * Список toolTip's
		 */
		public static var tollTips:Vector.<ComponentToolTip> = new Vector.<ComponentToolTip>;
		
		
		/**
		 * Добавить в список toolTip которые должны будут быть очищены
		 * @param	toolTip
		 */
		public static function toRemove(toolTip:ComponentToolTip):void {
			if (tollTips.indexOf(toolTip) > -1) return;
			tollTips.push(toolTip);
		}
		
		
		/**
		 * Подготовка к удалению toolTip
		 */
		public static function toolTipDispose():void {
			if (!toolTip) return;
			toolTip.remove();
		}
		
		
		public static function reinit(position:Point):void {
			var array:Array = Main.app.appStage.getObjectsUnderPoint(position);
			var target:*;		// DisplayObject
			var targetTarget:*;	// ComponentBase
			var level:uint;
			
			while (array.length) {
				target = array.pop();
				level = 0;
				
				while (level < 4) {
					
					level ++;
					
					if (target is ComponentBase && target.toolTip) {
						targetTarget = target;
						break;
					}else if (!target.parent || target is Stage) {
						break;
					}
					
					target = target.parent;
				}
				
				if (targetTarget) {
					array.length = 0;
					break;
				}
				
				break;
			}
			
			if (!targetTarget) {
				if (toolTip) 
					toolTipDispose();
			}else {
				if (toolTipTarget != targetTarget)
					new ComponentToolTip(targetTarget);
			}
			
			if (toolTip) {
				relocate(position);
			}
		}
		
		private static var relocateTween:TweenLite;
		public static function relocate(position:Point, animation:Boolean = true):void {
			if (!toolTip) return;
			
			if (Main.appWidth < Main.app.appStage.mouseX + toolTip.width + X_MARGIN) {
				position.x -= toolTip.width + X_MARGIN;
			}else {
				position.x += X_MARGIN;
			}
			if (Main.appHeight < Main.app.appStage.mouseY + toolTip.height + Y_MARGIN) {
				position.y -= toolTip.height + Y_MARGIN;
			}else {
				position.y += Y_MARGIN;
			}
			
			if (!animation) {
				toolTip.x = position.x;
				toolTip.y = position.y;
				return;
			}
			
			if (toolTip.removeTween)
				return;
			
			if (relocateTween) {
				relocateTween.kill();
				relocateTween = null;
			}
			relocateTween = TweenLite.to(toolTip, 0.15, { x:position.x, y:position.y } );
			
		}
		
		private static var resetTime:int;
		public static function resetInit():void {
			if (resetTime)
				clearTimeout(resetTime);
			
			resetTime = setTimeout(reinit, 1000, new Point(Main.app.appStage.mouseX, Main.app.appStage.mouseY));
		}
		
	}

}