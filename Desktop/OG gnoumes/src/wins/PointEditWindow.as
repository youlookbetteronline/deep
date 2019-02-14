package wins 
{
	import enixan.Color;
	import enixan.Size;
	import enixan.Util;
	import enixan.components.Button;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	public class PointEditWindow extends Window 
	{
		
		public var ID:String;
		public var object:Object;
		
		private var titleLabel:TextField;
		private var additionals:Sprite;
		private var addBttn:Button;
		private var clearBttn:Button;
		
		public static function edit(object:Object):void {
			wins.Window.closeAll();
			new PointEditWindow( {
				object:		object
			}).show();
		}
		
		public function PointEditWindow(params:Object = null) 
		{
			
			if (params.object) {
				object = params.object;
				ID = object.id;
			}
			
			super(params);
		}
		
		public function additionalPoles():void {
			if (!additionals) {
				additionals = new Sprite();
				additionals.x = 40;
				additionals.y = 60;
				container.addChild(additionals);
			}
			
			additionals.removeChildren();
			
			if (object.extra) {
				for (var i:int = 0; i < object.extra.length; i++) {
					var text:TextField = Util.drawText( {
						text:				object.extra[i],
						size:				15,
						color:				0x111111,
						width:				320,
						backgroundColor:	0xffffff,
						background:			true,
						border:				true,
						type:				'input'
					});
					text.name = i.toString();
					text.y = 30 * additionals.numChildren;
					additionals.addChild(text);
					text.addEventListener(TextEvent.TEXT_INPUT, onInput);
				}
			}
			
			addBttn = new Button( {
				width:		155,
				height:		27,
				label:		'Добавить',
				color1:		0xffbb00,
				color2:		0xffbb00,
				click:		onAdd
			});
			addBttn.y = 30 * additionals.numChildren;
			additionals.addChild(addBttn);
			
			clearBttn = new Button( {
				width:		155,
				height:		27,
				label:		'Убрать',
				color1:		0xff3300,
				color2:		0xff3300,
				click:		onClear
			});
			clearBttn.x = addBttn.x + addBttn.width + 10;
			clearBttn.y = addBttn.y;
			additionals.addChild(clearBttn);
		}
		private function onAdd():void {
			if (!object.extra)
				object['extra'] = [];
			
			if (object.extra.length >= 6)
				return;
			
			object.extra.push('');
			additionalPoles();
		}
		private function onClear():void {
			if (!object.extra) return;
			object.extra.pop();
			additionalPoles();
		}
		private function onInput(e:TextEvent):void {
			setTimeout(function():void {
				if (!object.extra)
					object['extra'] = [];
				
				var text:TextField = e.target as TextField;
				object.extra[text.name] = text.text;
			}, 10);
		}
		
		override public function draw():void {
			
			super.draw();
			
			titleLabel = Util.drawText( {
				text:		params.object.name,
				size:		30,
				color:		0xffffff
			});
			titleLabel.x = params.width * 0.5 - titleLabel.width * 0.5;
			titleLabel.y = 10;
			container.addChild(titleLabel);
			
			additionalPoles();
			
		}
		
		override public function close(e:MouseEvent = null):void {
			super.close(e);
			
			Main.app.saveStorage();
			
			new PointWindow().show();
		}
	}
}