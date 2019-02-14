package wins 
{
	import enixan.components.Button;
	import enixan.components.ComponentBase;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class Window extends ComponentBase 
	{
		
		public static var windows:Vector.<Window> = new Vector.<Window>;
		
		protected var fader:Sprite;
		public var container:Sprite;
		public var hold:Boolean;
		
		public var params:Object = {
			width:				400,
			height:				400,
			background:			true,
			backgroundColor:	0x666666,
			
			hasFader:			true,
			faderClose:			true,
			faderAlpha:			0.4,
			
			hasClose:			true
		}
		
		public function Window(params:Object = null) 
		{
			super();
			
			if (params) { 
				for (var s:* in params) {
					this.params[s] = params[s];
				}
			}
			
			if (this.params.hasFader) {
				fader = new Sprite();
				fader.graphics.beginFill(0x000000, this.params.faderAlpha);
				fader.graphics.drawRect(0, 0, Main.appWidth, Main.appHeight);
				fader.graphics.endFill();
				fader.x = -int(Main.appWidth * 0.5);
				fader.y = -int(Main.appHeight * 0.5);
				addChild(fader);
				if (this.params.faderClose) fader.addEventListener(MouseEvent.CLICK, close);
			}
			
			container = new Sprite();
			container.x = -int(this.params.width * 0.5);
			container.y = -int(this.params.height * 0.5);
			addChild(container);
			
			drawClose();
			
			draw();
		}
		
		protected var closeBttn:Button;
		public function drawClose():void {
			if (!params.hasClose) return;
			
			if (!closeBttn) {
				closeBttn = new Button( {
					label:		null,
					width:		24,
					height:		24,
					color1:		0x990000,
					color2:		0x770000,
					click:		close
				});
				addChild(closeBttn);
				
				var closeShape:Shape = new Shape();
				closeShape.graphics.lineStyle(3, 0xffffff);
				closeShape.graphics.moveTo(7, 7);
				closeShape.graphics.lineTo(17, 17);
				closeShape.graphics.moveTo(7, 17);
				closeShape.graphics.lineTo(17, 7);
				closeBttn.addChild(closeShape);
			}
			
			closeBttn.x = container.x + params.width - closeBttn.width - 4;
			closeBttn.y = container.y + 4;
			
		}
		
		// Нарисовать окно
		public function draw():void {
			container.graphics.beginFill(params.backgroundColor);
			container.graphics.drawRect(0, 0, params.width, params.height);
			container.graphics.endFill();
		}
		
		// Показать
		public function show():void {
			if (Main.app.windowLayer.numChildren > 0) {
				var window:Window = Main.app.windowLayer.getChildAt(0) as Window;
				window.close();
			}
			
			windows.push(this);
			Main.app.windowLayer.addChild(this);
		}
	
		// Закрыть
		public function close(e:MouseEvent = null):void {
			if (hold) return;
			
			dispose();
		}
		
		// Блокировка 
		public function set block(value:Boolean):void {
			container.mouseChildren = value;
			container.mouseEnabled = value;
		}
		public function get block():Boolean {
			return container.mouseEnabled;
		}
		
		override public function dispose():void {
			removeChildren();
			
			var index:int = Window.windows.indexOf(this);
			Window.windows.splice(index, 1);
			
			if (parent)
				parent.removeChild(this);
			
			if (fader)
				fader.removeEventListener(MouseEvent.CLICK, close);
			
			if (closeBttn) {
				closeBttn.dispose();
				closeBttn = null;
			}
		}
		
		public static function closeAll():Boolean {
			while (windows.length) {
				var window:Window = windows.shift();
				if (window.hold)
					return false;
				
				window.close();
			}
			
			return true;
		}
		public static function isOpenClass(issue:Class):Boolean {
			for each(var window:Window in Window.windows) {
				if (window is issue)
					return true;
			}
			
			return false;
		}
		
	}

}