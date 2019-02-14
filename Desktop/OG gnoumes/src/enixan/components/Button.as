package enixan.components 
{
	import effects.Effect;
	import enixan.Util;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author 
	 */
	public class Button extends ComponentBase 
	{
		public static const NORMAL:uint = 0;
		public static const DISABLE:uint = 1;
		
		private var textField:TextField;
		
		private var params:Object = {
			label:			'OK',
			width:			100,
			height:			30,
			color1:			0x4589B0,
			color2:			0x4589B0,
			alpha:			1,
			radius:			0,
			
			textBold:		false,
			textSize:		12,
			textColor:		0xffffff,
			textFieldY:		2
		}
		
		public function Button(params:Object) {
			super();
			
			for (var s:* in params) {
				if (s == 'color') {
					this.params.color1 = params[s];
					this.params.color2 = params[s];
				}
				
				this.params[s] = params[s];
			}
			
			draw();
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
			
			buttonMode = true;
		}
		
		protected function draw():void {
			
			if (params.bmd && params.bmd is BitmapData) {
				var bitmap:Bitmap = new Bitmap(params.bmd);
				addChild(bitmap);
				return;
			}
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(params.width, params.height, 90 * Math.PI / 180);
			
			var background:Shape = new Shape();
			background.graphics.beginGradientFill(GradientType.LINEAR, [params.color1, params.color2], [params.alpha, params.alpha], [0, 255], matrix);
			background.graphics.drawRoundRect(0, 0, params.width, params.height, params.radius, params.radius);
			background.graphics.endFill();
			addChild(background);
			
			if (params.label) {
				textField = Util.drawText( {
					width:			params.width,
					text:			params.label,
					size:			params.textSize,
					bold:			params.textBold,
					color:			params.textColor,
					textAlign:		TextFormatAlign.CENTER
				});
				textField.y = background.height * 0.5 - textField.textHeight * 0.5 - params.textFieldY;
				addChild(textField);
			}
			
		}
		
		private function onClick(e:MouseEvent):void {
			if (state == DISABLE)
				return;
			
			if (params.click != null) {
				if (params.onClickParams)
					params.click.apply(null, [params.onClickParams]);
				else
					params.click();
			}
		}
		private function onOver(e:MouseEvent):void {
			if (state == DISABLE) return;
			select = true;
		}
		private function onOut(e:MouseEvent):void {
			if (state == DISABLE) return;
			select = false;
		}
		
		
		public function set label(value:String):void {
			if (!value) value = '';
			textField.text = value;
		}
		public function get label():String {
			return textField.text;
		}
		
		
		private var __select:Boolean;
		public function set select(value:Boolean):void {
			__select = value;
			if (value) {
				Effect.light(this, 0.15);
			}else {
				Effect.light(this);
			}
		}
		public function get select():Boolean {
			return __select;
		}
		
		
		private var __state:int = 0;
		public function set state(value:int):void {
			__state = value;
			
			if (__state == DISABLE) {
				Effect.light(this, 0, 0);
			}else {
				Effect.light(this);
			}
		}
		public function get state():int {
			return __state;
		}
		
		override public function dispose():void {
			
			removeEventListener(MouseEvent.CLICK, onClick);
			removeEventListener(MouseEvent.ROLL_OVER, onOver);
			removeEventListener(MouseEvent.ROLL_OUT, onOut);
			
			removeChildren();
			
			if (parent)
				parent.removeChild(this);
			
		}
		
	}

}