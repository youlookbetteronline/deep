package 
{
	
	import enixan.components.Button;
	import enixan.components.List;
	import enixan.components.ListNode;
	import flash.display.Stage;
	import flash.net.FileFilter;
	
	public class StageManager extends List {
		
		//public static var chooseNode:StageNode;
		
		public var addBttn:Button;
		
		public function StageManager(stage:Stage, width:int, height:int, params:Object=null) {
			
			if (!params) params = { };
			
			params.backgroundColor = 0x444444;
			
			super(stage, width, height, params);
			
			nodeHeight = 120;
			
			addBttn = new Button( {
				label:		'Добавить стадии',
				width:		width - 6,
				height:		24,
				click:		function():void {
					Main.app.addFromBrowse('Файлы для Стадий', Main.storage.resourcePath, [new FileFilter('Images', '*.png'),new FileFilter('SWF', '*.swf')]);
				}
			});
			addBttn.x = 3;
			addBttn.y = 3;
			addChild(addBttn);
			
		}
		
		override protected function drawMaska():void {
			maska.graphics.beginFill(0xff0000, 0.1);
			maska.graphics.drawRect(0, 0, currWidth, currHeight - 30);
			maska.graphics.endFill();
			maska.y = 30;
		}
		
		override public function add(info:Object, update:Boolean = false):void {
			
			if (update)
				data.push(info);
			
			var node:StageNode = new StageNode(this, info);
			node.y = container.numChildren * (nodeHeight + params.indent);
			container.addChild(node);
			content.push(node);
			
		}
		
		public function show(list:Vector.<StageInfo>):void {
			
			//data.length = 0;
			for (var i:int = 0; i < list.length; i++) {
				if (isinList(list[i])) continue;
				
				data.push( {
					text:	list[i].name,
					color:	0x4f4f4f,
					item:	list[i]
				});
			}
			
			for (i = 0; i < data.length; i++) {
				if (list.indexOf(data[i].item) == -1) {
					data.splice(i, 1);
					i--;
				}
			}
			
			draw();
		}
		
		override public function draw():void {
			super.draw();
			
			updateNumeric();
		}
		
		public function updateNumeric():void {
			var increment:int = 1;
			for (var i:int = 0; i < content.length; i++) {
				if (!content[i].hidden) {
					content[i].numLabel.text = increment.toString();
					increment++;
				}else {
					content[i].numLabel.text = '';
				}
			}
		}
		
		public function isinList(stageInfo:StageInfo):Boolean {
			for (var j:int = 0; j < data.length; j++) {
				if (data[j].item == stageInfo)
					return true;
			}
			
			return false;
		}
		
		override public function select(node:ListNode, update:Boolean = true):void {
			super.select(node);
			
			if (update)
				Main.app.viewShow(node.data.item);
		}
		public function selectByInfo(stageInfo:StageInfo):void {
			for (var i:int = 0; i < content.length; i++) {
				if (content[i].data.item == stageInfo) {
					content[i].focus(true);
				}
			}
		}
		
	}

}