package
{
	import com.adobe.images.PNGEncoder;
	import effects.Effect;
	import enixan.Size;
	import enixan.Util;
	import enixan.components.Button;
	import enixan.components.CheckBox;
	import enixan.components.List;
	import enixan.components.ListNode;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	/**
	 * ...
	 * @author
	 */
	public class StageNode extends ListNode
	{
		
		private var image:Bitmap;
		private var closeBttn:Button;
		public var numLabel:TextField;
		public var lockBox:CheckBox;
		public var hiddenBox:CheckBox;
		
		public function StageNode(list:List, data:Object)
		{
			data.textSize = 11;
			data.textAlign = 'center';
			data.textWidth = list.nodeWidth;
			
			super(list, data);
			
			lockBox.check = lock;
			hiddenBox.check = hidden;
			onHidden();
			
			addEventListener(MouseEvent.MIDDLE_CLICK, onDelete);
			addEventListener(MouseEvent.RIGHT_CLICK, onMouseRightClick);
			
			toolTip = 'Click + Ctrl - добавит эту стадию не убирая текущую\nMiddleClick - удалит стадию';
		}
		
		override public function draw():void {
			
			super.draw();
			
			image = new Bitmap(data.item.bitmapData);
			addChildAt(image, getChildIndex(titleLabel));
			load(data.item.bitmapData);
			
			titleLabel.x = 0;
			titleLabel.y = nodeHeight - titleLabel.height - 2;
			
			closeBttn = new Button({label: null, width: 12, height: 12, color1: 0x990000, color2: 0x770000, radius: 4, click:onDelete });
			closeBttn.x = background.x + background.width - closeBttn.width - 6;
			closeBttn.y = 6;
			addChild(closeBttn);
			
			var closeShape:Shape = new Shape();
			closeShape.graphics.lineStyle(2, 0xffffff);
			closeShape.graphics.moveTo(3, 3);
			closeShape.graphics.lineTo(9, 9);
			closeShape.graphics.moveTo(3, 9);
			closeShape.graphics.lineTo(9, 3);
			closeBttn.addChild(closeShape);
			
			hiddenBox = new CheckBox({width: 10, height: 10, onChange: onHidden});
			hiddenBox.x = closeBttn.x - hiddenBox.width - 2;
			hiddenBox.y = closeBttn.y + 1;
			addChild(hiddenBox);
			hiddenBox.toolTip = 'Скрыть стадию\nСтадия не участвует при сборке';
			
			lockBox = new CheckBox({width: 10, height: 10, color:0xcccc00, onChange: onChange});
			lockBox.x = hiddenBox.x - lockBox.width - 3;
			lockBox.y = closeBttn.y + 1;
			addChild(lockBox);
			lockBox.toolTip = 'Закрепить стадию';
			
			numLabel = Util.drawText( {
				text:		' ',
				size:		30,
				color:		0xffffff,
				textAlign:	TextFormatAlign.LEFT,
				autoSize:	TextFieldAutoSize.LEFT
			});
			numLabel.x = 4;
			numLabel.y = 4;
			addChild(numLabel);
		}
		
		private function onChange():void
		{
			
			for (var i:int = 0; i < list.content.length; i++)
			{
				if (list.content[i].lock)
				{
					var stageNode:StageNode = list.content[i];
					lock = false;
					stageNode.lockBox.check = false;
					Main.app.mainView.review(null, true);
					
					if (list.content[i] == this)
						return;
				}
			}
			
			lockBox.check = true;
			lock = true;
		}
		
		public function load(bitmapData:BitmapData):void {
			
			image.bitmapData = bitmapData;
			image.smoothing = true;
			
			Size.size(image, background.width * 0.9, background.height * 0.9);
			
			image.x = background.x + background.width * 0.5 - image.width * 0.5;
			image.y = background.y + background.height * 0.5 - image.height * 0.5;
			
		}
		
		private function onDelete(e:MouseEvent = null):void {
			Main.app.stageDelete(data.item);
		}
		
		private function onMouseRightClick(e:MouseEvent):void {
			var contextMenu:ContextMenu = new ContextMenu();
			var concatCMI:ContextMenuItem = new ContextMenuItem('Сохранить картинку', false, true, true);
			
			contextMenu.addItem(concatCMI);
			
			contextMenu.addEventListener(Event.SELECT, onMenuSelect);
			
			contextMenu.display(Main.app.appStage, Main.app.appStage.mouseX, Main.app.appStage.mouseY);
			
			function onMenuSelect(e:Event):void {
				if (e.target == concatCMI)
					saveSelected();
				
				contextMenu.removeEventListener(Event.SELECT, onMenuSelect);
			}
			function saveSelected():void {
				Files.openDirectory(onChooseFolderComplete, Main.storage.folderChoose, null, 'Сохранить сюда');
			}
			function onChooseFolderComplete(folder:File):void {
				if (!folder || !folder.exists) return;
				
				Main.storage.folderChoose = folder.nativePath;
				
				var name:String = data.item.name;
				if (name.indexOf(Main.PNG) < 0) name += Main.PNG;
				var file:File = folder.resolvePath(name);
				while (file.exists) {
					name = Main.app.nextName(name);
					file = folder.resolvePath(name);
				}
				
				Files.save(file, PNGEncoder.encode(data.item.bitmapData));
				MessageView.message('Картинка сохранена ' + name);
			}
		}
		
		
		private function onHidden():void {
			
			hidden = hiddenBox.check;
			filters.length = 0;
			titleLabel.alpha = (hiddenBox.check) ? 0.5 : 1;
			image.alpha = (hiddenBox.check) ? 0.35 : 1;
			
			Main.app.stageManager.updateNumeric();
		}
		
		public function set lock(value:Boolean):void {
			data.item.extra['lock'] = value;
		}
		public function get lock():Boolean {
			return data.item.extra.lock;
		}
		public function set hidden(value:Boolean):void {
			data.item.extra['hidden'] = value;
		}
		public function get hidden():Boolean {
			return data.item.extra.hidden;
		}
		
		override public function dispose():void {
			removeEventListener(MouseEvent.MIDDLE_CLICK, onDelete);
			removeEventListener(MouseEvent.RIGHT_CLICK, onMouseRightClick);
			
			super.dispose();
		}
		
	}

}