package enixan.components 
{
	import effects.Effect;
	import enixan.Util;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class CheckBox extends ComponentBase 
	{
		public const OBJECT:String = 'object';
		
		private var params:Object = {
			width:			30,
			height:			30,
			backgroundColor:0x666666,
			color:			0xcccccc,
			alpha:			1,
			radius:			4,
			checked:		false,
			
			text:			null,
			textParams:		{
				color:		0xffffff,
				size:		14
			},
			textIndent:		4
		}
		
		private var box:Sprite;
		private var mark:Shape;
		private var label:TextField;
		
		public function CheckBox(params:Object) {
			super();
			
			for (var s:* in params) {
				
				if (typeof(params[s]) == OBJECT) {
					for (var t:* in params[s])
						this.params[s][t] = params[s][t]; 
				}else {
					this.params[s] = params[s];
				}
			}
			
			draw();
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
		}
		
		protected function draw():void {
			
			box = new Sprite();
			addChild(box);
			
			box.graphics.beginFill(params.backgroundColor);
			box.graphics.lineStyle(2, params.color, 1, true);
			box.graphics.drawRoundRect(0, 0, params.width, params.height, params.radius, params.radius);
			box.graphics.endFill();
			
			mark = new Shape();
			mark.graphics.beginFill(params.color);
			mark.graphics.drawRoundRect(-params.width * 0.3, -params.height * 0.3, params.width * 0.6, params.height * 0.6, params.radius, params.radius);
			mark.graphics.endFill();
			mark.visible = params.checked;
			mark.x = params.width * 0.5;
			mark.y = params.height * 0.5;
			box.addChild(mark);
			
			if (params.text) {
				params.textParams['text'] = params.text;
				
				label = Util.drawText(params.textParams);
				label.x = mark.x + params.width + params.textIndent;
				label.y = params.height * 0.5 - label.height * 0.5;
				addChild(label);
				
			}
			
		}
		
		public function set check(value:Boolean):void {
			mark.visible = value;
		}
		public function get check():Boolean {
			return mark.visible;
		}
		
		private function onClick(e:MouseEvent):void {
			check = !check;
			
			if (params.onChange)
				params.onChange();
		}
		private function onOver(e:MouseEvent):void {
			Effect.light(box, 0.15);
		}
		private function onOut(e:MouseEvent):void {
			Effect.light(box);
		}
		
		override public function dispose():void {
			
			removeEventListener(MouseEvent.CLICK, onClick);
			removeEventListener(MouseEvent.ROLL_OVER, onOver);
			removeEventListener(MouseEvent.ROLL_OUT, onOut);
			
			super.dispose();
			
		}
		
	}

}