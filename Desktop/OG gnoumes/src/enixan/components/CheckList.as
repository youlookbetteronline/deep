package enixan.components 
{
	import enixan.Util;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class CheckList extends ComponentBase 
	{
		
		private static var container:ComponentBase;
		
		private var textLabel:TextField;
		
		protected var params:Object = {
			width:			130,
			height:			22,
			color1:			0x4589B0,
			color2:			0x4589B0,
			alpha:			1,
			current:		3,
			minValue:		1,
			maxValue:		10,
			maskHeight:		400,
			
			textEditable:	true,
			textBold:		false,
			textSize:		14,
			textColor:		0x111111
		}
		
		private var values:Array;
		
		public function CheckList(params:Object = null) {
			
			super();
			
			if (!params) params = { };
			for (var s:* in params) {
				this.params[s] = params[s];
			}
			
			values = params.values || [];
			
			draw();
			
			addEventListener(MouseEvent.CLICK, onClick);
			
		}
		
		private function onClick(e:MouseEvent):void {
			if (container) {
				container.removeChildren();
				container = null;
			}else {
				open();
			}
		}
		
		private var Mask:Shape;
		private function open():void {
			if (container) {
				close();
				return;
			}
			
			Mask = new Shape();
			
			container = new ComponentBase();
			container.x = x;
			container.y = y + params.height + 1;
			container.mask = Mask;
			parent.addChild(container);
			
			Mask.x = container.x;
			Mask.y = container.y;
			parent.addChild(Mask);
			
			container.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			var back:Shape = new Shape();
			container.addChild(back);
			
			for (var i:int = 0; i < values.length; i++) {
				var item:CheckBoxItem = new CheckBoxItem(values[i].value, values[i].name, onItemClick, {
					width:		params.width,
					height:		params.height,
					color:		0x73B1D6
				});
				item.y = 23 * (container.numChildren-1);
				container.addChild(item);
			}
			
			back.graphics.beginFill(0x595959,0.3);
			back.graphics.drawRect(container.x, container.y, container.width, container.height);
			back.graphics.endFill();
			back.name = 'line' + i;
			
			Mask.graphics.beginFill(0xff0000, 0.5);
			Mask.graphics.drawRect(0,0,container.width,params.maskHeight);
			Mask.graphics.endFill();
		}
		
		private function close():void {
			if (!container) return;
			
			parent.removeChild(Mask);
			Mask = null;
			
			container.removeChildren();
			parent.removeChild(container);
			container.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			container = null;
		}
		
		private function onMouseWheel(e:MouseEvent):void {
			var step:int = 24;
			//var percent:Number = (container.height - Mask.height) / 100;
			if (e.delta > 0){
				if (container.y + step >= Mask.y){
					container.y = Mask.y;
					return;
				}
				container.y += step;
			} else {
				if (container.y + container.height - step <= Mask.height + Mask.y) {
					container.y = -container.height + Mask.height + Mask.y * 2;
					return;
				}
				container.y -= step;
			}
		}
		
		private function onItemClick(value:*):void {
			//if (this.value == value) return;
			
			for (var i:int = 0; i < values.length; i++) {
				if (values[i].value == value) {
					if (selected != i)
						selected = i;
					
					break;
				}
			}
			
			change();
		}
		
		public function draw():void {
			
			graphics.beginFill(params.color1);
			graphics.drawRect(0, 0, params.width, params.height);
			graphics.endFill();
			
			textLabel = Util.drawText( {
				text:		valueName,
				width:		params.width - 4,
				size:		14,
				color:		0xffffff
			});
			textLabel.x = 4;
			addChild(textLabel);
			
		}
		
		// Изменение данных
		private function change():void {
			
			close();
			
			textLabel.text = valueName;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get value():* {
			return values[selected].value;
		}
		
		public function get valueName():String {
			return values[selected].name;
		}
		
		private var __selected:int = -1;
		public function get selected():int {
			if (__selected < 0 && values.length > 0)
				__selected = 0;
			
			return __selected;
		}
		public function set selected(value:int):void {
			if (value >= values.length) value = values.length - 1;
			if (value < 0) value = 0;
			
			__selected = value;
			
			change();
		}
		
		override public function dispose():void {
			
		}
		
	}

}

import effects.Effect;
import enixan.Util;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

internal class CheckBoxItem extends Sprite {
	
	private var textLabel:TextField;
	private var value:*;
	private var click:Function;
	
	public function CheckBoxItem(value:*, name:String, click:Function, params:Object) {
		
		this.value = value;
		this.name = name;
		this.click = click;
		
		graphics.beginFill(params.color);
		graphics.drawRect(0, 0, params.width, params.height);
		graphics.endFill();
		
		textLabel = Util.drawText( {
			text:		name,
			width:		params.width,
			size:		14,
			color:		0xffffff
		});
		textLabel.x = 4;
		addChild(textLabel);
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	private function onClick(e:MouseEvent):void {
		if (click != null)
			click(value);
	}
	private function onOver(e:MouseEvent):void {
		Effect.light(this, 0.15);
	}
	private function onOut(e:MouseEvent):void {
		Effect.light(this);
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
}