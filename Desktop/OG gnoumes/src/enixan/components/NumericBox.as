package enixan.components 
{
	import adobe.utils.CustomActions;
	import effects.Effect;
	import enixan.Util;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	
	public class NumericBox extends ComponentBase 
	{
		
		protected var textLabel:TextField;
		protected var downButton:Button;
		protected var upButton:Button;
		
		private var previewValue:String;
		
		protected var params:Object = {
			width:			80,
			height:			22,
			color1:			0x4589B0,
			color2:			0x4589B0,
			step:			1,
			alpha:			1,
			current:		3,
			minValue:		1,
			maxValue:		10,
			
			textEditable:	true,
			textBold:		false,
			textSize:		14,
			textColor:		0x111111
		}
		
		public function NumericBox(params:Object = null) {
			
			super();
			
			if (!params) params = { };
			for (var s:* in params) {
				this.params[s] = params[s];
			}
			
			previewValue = String(this.params.current);
			
			draw();
		}
		
		public function draw():void {
			
			removeChildren();
			
			var downShape:Shape = new Shape();
			downShape.graphics.lineStyle(1, 0xFFFFF7);
			downShape.graphics.moveTo(6,0);
			downShape.graphics.lineTo(0,6);
			downShape.graphics.lineTo(6,12);
			downShape.x = 7;
			downShape.y = 5;
			
			downButton = new Button( {
				label:		null,
				width:		20,
				height:		params.height,
				click:		function():void {
					value = abs(value - params.step);
					unfocus();
					dispatchEvent(new Event(Event.CHANGE));
				}
			});
			addChild(downButton);
			downButton.addChild(downShape);
			
			
			
			var upShape:Shape = new Shape();
			upShape.graphics.lineStyle(1, 0xFFFFF7);
			upShape.graphics.moveTo(0,0);
			upShape.graphics.lineTo(6,6);
			upShape.graphics.lineTo(0,12);
			upShape.x = 7;
			upShape.y = 5;
			
			upButton = new Button( {
				label:		null,
				width:		20,
				height:		params.height,
				click:		function():void {
					value = abs(value + params.step);
					unfocus();
					dispatchEvent(new Event(Event.CHANGE));
				}
			});
			upButton.x = params.width - 20;
			addChild(upButton);
			upButton.addChild(upShape);
			
			
			
			textLabel = Util.drawText( {
				text:		params.current.toString(),
				width:		Math.max(20, params.width - downButton.width - upButton.width - 1),
				height:		20,
				size:		params.textSize,
				bold:		params.textBold,
				color:		params.textColor,
				selectable:	params.textEditable,
				type:		TextFieldType.INPUT,
				textAlign:	TextFormatAlign.CENTER,
				border:				true,
				borderColor:		0x111111,
				background:			true,
				backgroundColor:	0xffffff,
				embedFonts:			false
			});
			textLabel.restrict = '0123456789.';
			textLabel.x = downButton.x + downButton.width;
			addChild(textLabel);
			
			textLabel.addEventListener(TextEvent.TEXT_INPUT, onInput);
			textLabel.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			textLabel.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusOut);
		}
		
		private function abs(value:Number):Number {
			return Math.round(value / params.step) * params.step;
		}
		
		
		/**
		 * доступно или нет
		 */
		public function set enabled(value:Boolean):void {
			mouseEnabled = value;
			mouseChildren = value;
			
			if (value) {
				alpha = 1;
				Effect.light(this);
			}else {
				alpha = 0.3;
				Effect.light(this, 0, 0);
			}
		}
		public function get enabled():Boolean {
			return mouseEnabled;
		}
		
		
		/**
		 * Значение поля
		 */
		public function set value(value:Number):void {
			if (value < params.minValue) {
				textLabel.text = params.minValue.toString();
			}else if (value > params.maxValue) {
				textLabel.text = params.maxValue.toString();
			}else {
				textLabel.text = value.toString();
			}
		}
		public function get value():Number {
			return Number(textLabel.text);
		}
		
		protected function onInput(e:TextEvent):void {
			
			previewValue = textLabel.text;
			
			var value:Number;
			if (textLabel.selectedText.length > 0) {
				value = Number(textLabel.text.substring(0, textLabel.selectionBeginIndex) + e.text + textLabel.text.substring(textLabel.selectionEndIndex, textLabel.length));
			}else {
				value = Number(textLabel.text + e.text);
			}
			
			if (isNaN(value)) {
				textLabel.text = previewValue;
				textLabel.setSelection(textLabel.length, textLabel.length);
				e.preventDefault();
			}else if (value < params.minValue) {
				textLabel.text = params.minValue;
				textLabel.setSelection(textLabel.length, textLabel.length);
				e.preventDefault();
			}else if (value > params.maxValue) {
				textLabel.text = params.maxValue;
				textLabel.setSelection(textLabel.length, textLabel.length);
				e.preventDefault();
			}
			
			setTimeout(function():void {
				dispatchEvent(new Event(Event.CHANGE));
			}, 1);
		}
		protected function onFocusIn(e:FocusEvent):void {
			textLabel.setSelection(0, textLabel.length);
		}
		protected function onFocusOut(e:FocusEvent):void {
			var value:Number = int(textLabel.text);
			if (isNaN(value) || value < params.minValue)
				textLabel.text = previewValue;
			
			unfocus();
		}
		
		protected function unfocus():void {
			Main.app.appStage.focus = null;
		}
		
		override public function dispose():void {
			
			if (textLabel) {
				textLabel.removeEventListener(TextEvent.TEXT_INPUT, onInput);
				textLabel.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				textLabel.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusOut);
			}
			
		}
		
	}

}