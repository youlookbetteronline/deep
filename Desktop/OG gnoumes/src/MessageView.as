package 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import enixan.Util;
	import enixan.components.ComponentBase;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	
	public class MessageView extends ComponentBase {
		
		
		private var container:Sprite;
		private var alertLabel:TextField;
		
		private var tweens:Vector.<TweenLite>;
		private var list:Vector.<Message>;
		
		public function MessageView() {
			
			super();
			
			container = new Sprite();
			addChild(container);
			
			/*mouseChildren = false;
			mouseEnabled = false;
			
			alertLabel = Util.drawText( {
				text:		' ',
				width:		300,
				height:		60,
				size:		44,
				color:		0xffffff,
				textAlign:	TextFormatAlign.CENTER
			});
			alertLabel.filters = [new GlowFilter(0xffffff, 0.5, 6, 6)];
			addChild(alertLabel);*/
			
			tweens = new Vector.<TweenLite>;
			list = new Vector.<Message>;
			
			MessageView.instance = this;
			
			resize();
		}
		
		public function resize():void {
			//alertLabel.x = Main.appWidth * 0.5 - alertLabel.width * 0.5;
			//alertLabel.y = 80;
		}
		
		public function addMessage(message:Message):void {
			
			if (list.indexOf(message) != -1) return;
			
			message.y = container.height;
			message.addEventListener(Event.CLOSE, onMessageClose);
			
			list.push(message);
			container.addChild(message);
			
			move();
		}
		
		public function move():void {
			while (tweens.length) {
				tweens.shift().kill();
			}
			
			var heightPosition:int = 0;
			
			list.sort(sorter);
			
			for (var i:int = 0; i < list.length; i++) {
				var time:Number = 0.2;// Math.abs(list[i].y - heightPosition) / 400;
				TweenLite.to(list[i], time, { y:heightPosition, ease:Linear.easeIn } );
				heightPosition += list[i].height;
			}
		}
		private function sorter(a:Message, b:Message):int {
			if (a.y > b.y)
				return 1;
			
			if (b.y > a.y)
				return -1;
			
			return 0;
		}
		
		private function onMessageClose(e:Event):void {
			for (var i:int = 0; i < list.length; i++) {
				if (!container.contains(list[i])) {
					list.splice(i, 1);
					i--;
				}
			}
			
			move();
		}
		
		
		
		
		private static var __instance:MessageView;
		public static function get instance():MessageView {
			return __instance;
		}
		public static function set instance(value:MessageView):void {
			__instance = value;
		}
		
		public static function message(message:String, params:Object = null):void {
			
			var defaults:Object = {
				width:		300,
				height:		0,
				clickable:	true
			}
			
			if (params) {
				for (var s:* in params)
					defaults[s] = params[s];
			}
			
			defaults['text'] = message;
			
			// Проверить или существует message с таким же ID
			if (defaults.id) {
				for each(var mess:Message in MessageView.instance.list) {
					if (mess.id != defaults.id) continue;
					
					mess.text = message;
					mess.draw();
					return;
				}
			}
			
			MessageView.instance.addMessage(new Message(defaults));
			
		}
		
		
		
		private static var alertTween:TweenLite;
		public static function alert(string:String, params:Object = null):void {
			//MessageView.instance.alertLabel.alpha = 3;
			//MessageView.instance.alertLabel.text = string;
			Main.app.mainView.alertLabel.alpha = 3;
			Main.app.mainView.alertLabel.text = string;
			
			if (alertTween) {
				alertTween.kill();
				alertTween = null;
			}
			alertTween = TweenLite.to(Main.app.mainView.alertLabel, 6, { alpha:0 } );
		}
	}

}

import enixan.Util;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

internal class Message extends Sprite {
	
	private var params:Object = {
		timeout:	4000,
		width:		300,
		height:		50,
		text:		'...',
		fontColor:	0x222222,
		backColor:	0xeeeeee,
		backAlpha:	0.95,
		clickable:	true
	};
	
	private var timeout:int; 
	
	public function Message(params:Object) {
		if (params) {
			for (var s:* in params)
				this.params[s] = params[s];
		}
		
		draw();
		
		if (this.params.clickable) {
			addEventListener(MouseEvent.ROLL_OVER, onClick);
		}else {
			mouseChildren = false;
			mouseEnabled = false;
		}
		
		timeout = setTimeout(dispose, this.params.timeout);
	}
	
	
	// Назначить текст
	public function set text(value:String):void {
		params.text = value;
	}
	
	
	// ID сообщения
	public function get id():* {
		return params.id;
	}
	
	
	// Перерисовать
	public function draw():void {
		
		if (numChildren > 0)
			removeChildren();
		
		if (timeout) {
			clearTimeout(timeout);
			timeout = setTimeout(dispose, this.params.timeout);
		}
		
		var messageLabel:TextField = Util.drawText( {
			text:		params.text,
			width:		params.width - 20,
			autoSize:	TextFieldAutoSize.LEFT,
			selectable:	false,
			wordWrap:	true,
			multiline:	true,
			color:		params.fontColor,
			size:		14
		});
		
		var border:Shape = new Shape();
		border.graphics.beginFill(0, 0);
		border.graphics.drawRect(0, 0, params.width, Math.max(params.height, messageLabel.height + 20));
		border.graphics.endFill();
		
		var background:Shape = new Shape();
		background.graphics.beginFill(params.backColor, params.backAlpha);
		background.graphics.drawRect(2, 2, border.width - 4, border.height - 4);
		background.graphics.endFill();
		
		messageLabel.x = 10;
		messageLabel.y = border.y + border.height * 0.5 - messageLabel.height * 0.5;
		
		addChild(border);
		addChild(background);
		addChild(messageLabel);
		
		alpha = 0.5;
	}
	
	private function onClick(e:MouseEvent):void {
		if (params.onClick && params.onClick != null)
			params.onClick();
		
		dispose();
	}
	
	public function dispose():void {
		
		clearTimeout(timeout);
		removeChildren();
		
		if (parent)
			parent.removeChild(this);
		
		removeEventListener(MouseEvent.ROLL_OVER, onClick);
		dispatchEvent(new Event(Event.CLOSE));
	}
	
}