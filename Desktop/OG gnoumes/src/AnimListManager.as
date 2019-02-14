package 
{
	import enixan.components.Button;
	import enixan.components.ComponentToolTip;
	import enixan.components.List;
	import enixan.components.ListNode;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import wins.TextureWindow;
	
	/**
	 * ...
	 * @author 
	 */
	public class AnimListManager extends List 
	{
		
		public var addBttn:Button;
		
		public function AnimListManager(stage:Stage, width:int, height:int, params:Object=null) 
		{
			if (!params) params = { };
			
			params.backgroundColor = 0x444444;
			
			super(stage, width, height, params);
			
			nodeHeight = 100;
			
			addBttn = new Button( {
				label:		'Добавить анимац.',
				width:		width - 6,
				height:		24,
				click:		function():void {
					Main.app.addFromBrowse('Папки Анимаций', Main.storage.resourcePath);
				}
			});
			addBttn.x = 3;
			addBttn.y = 3;
			addChild(addBttn);
			
			addEventListener(MouseEvent.RIGHT_CLICK, onMouseRightClick);
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
			
			var node:AnimNode = new AnimNode(this, info);
			node.y = container.numChildren * (nodeHeight + params.indent);
			container.addChild(node);
			content.push(node);
			
		}
		
		public function show(list:Vector.<AnimInfo>):void {
			
			data.length = 0;
			for (var i:int = 0; i < list.length; i++) {
				data.push( {
					text:	list[i].name,
					color:	0x4f4f4f,
					item:	list[i]
				});
			}
			
			draw();
			
		}
		
		override public function select(node:ListNode, update:Boolean = true):void {
			super.select(node);
			
			if (update) Main.app.viewShow(node.data.item);
		}
		public function selectByInfo(animInfo:AnimInfo):void {
			for (var i:int = 0; i < content.length; i++) {
				if (content[i].data.item == animInfo) {
					content[i].focus(true);
				}
			}
		}
		
		
		private function onMouseRightClick(e:MouseEvent):void {
			
			if (!isSelectedTouch) return;
			
			ComponentToolTip.dispose();
			
			var contextMenu:ContextMenu = new ContextMenu();
			var concatCMI:ContextMenuItem = new ContextMenuItem('Объединить выделенные', false, true, true);
			var textureCMI:ContextMenuItem = new ContextMenuItem('Создать текстуру', false, true, true);
			
			if (focusedNodes.length > 1)
				contextMenu.addItem(concatCMI);
			
			//if (focusedNodes.length > 0)
				//contextMenu.addItem(textureCMI);
			
			contextMenu.addEventListener(Event.SELECT, onMenuSelect);
			
			contextMenu.display(Main.app.appStage, Main.app.appStage.mouseX, Main.app.appStage.mouseY);
			
			function onMenuSelect(e:Event):void {
				if (e.target == concatCMI)
					concatSelected();
				
				if (e.target == textureCMI)
					new TextureWindow().show();
				
				contextMenu.removeEventListener(Event.SELECT, onMenuSelect);
			}
		}
		
		
		/**
		 * Объединить выделенные ячейки
		 */
		private function concatSelected():void {
			var list:Vector.<AnimInfo> = new Vector.<AnimInfo>;
			var index:int;
			var nodeIndex:int;
			var animInfo:AnimInfo;
			
			for (index = 0; index < content.length; index++) {
				nodeIndex = focusedNodes.indexOf(content[index]);
				if (nodeIndex > -1) {
					list.push(content[index].data.item);
					focusedNodes[nodeIndex].unfocus();
				}
			}
			
			if (list.length >= 2) {
				animInfo = list[0].clone();
				animInfo.animType = AnimInfo.ADVANCED_ANIMATION;
				
				for (nodeIndex = 1; nodeIndex < list.length; nodeIndex++) {
					var anim:AnimInfo = list[nodeIndex];
					
					for (index = 0; index < anim.chain.length; index++) {
						animInfo.chain.push(anim.chain[index] + animInfo.bmds.length);
					}
					for (index = 0; index < anim.indents.length; index++) {
						animInfo.indents.push(new Point(anim.indents[index].x, anim.indents[index].y));
					}
					
					animInfo.bmds = animInfo.bmds.concat(anim.bmds);
				}
				
				animInfo.png = null;
				animInfo.atlas = null;
				animInfo.atlasPositions = new Vector.<Point>(animInfo.bmds.length);
				
				animInfo.name = 'anim';
				if (!Main.app.animationCheckName(animInfo.name)) {
					animInfo.name = Main.app.nextName(animInfo.name);
				}
			}else {
				return;
			}
			
			for (index = list.length - 1; index > -1; index--) {
				if (Main.app.animationsList.indexOf(list[index]) > -1)
					Main.app.animationsList.splice(Main.app.animationsList.indexOf(list[index]), 1);
			}
			
			Main.app.animationsList.push(animInfo);
			Main.app.atlasDataAdd(animInfo);
			Main.app.updateView();
		}
		
		override public function dispose():void {
			removeEventListener(MouseEvent.RIGHT_CLICK, onMouseRightClick);
			super.dispose();
		}
		
	}

}