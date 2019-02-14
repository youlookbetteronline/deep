package
{
	import enixan.Util;
	import enixan.components.Button;
	import enixan.components.ComponentBase;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	public class AnimationLine extends Sprite {
	
		private var currWidth:int;
		private var currHeight:int;
		
		private var main:Sprite;
		private var container:ComponentBase;
		private var line:Sprite;
		private var maska:Shape;
		private var carriage:Shape;
		private var selecter:Shape;
		private var scroller:Sprite;
		private var animtionBttn:Button;
		
		private var chain:Array;
		private var view:ViewManager;
		
		private var params:Object = {
			frameColor:			0xcccccc,
			frameKeyColor:		0xddddaa,
			carriageColor:		0x57889a,
			carriageBorder:		0x27bff6,
			carriageWidth:		15,
			carriageHeight:		36
		}
		
		public function AnimationLine(view:ViewManager, chain:Array, width:int, height:int):void {
			
			this.view = view;
			
			focusRect = false;
			
			main = new Sprite();
			addChild(main);
			
			container = new ComponentBase();
			main.addChild(container);
			
			line = new Sprite();
			container.addChild(line);
			
			carriage = new Shape();
			carriage.graphics.lineStyle(1, params.carriageBorder, 1, true);
			carriage.graphics.beginFill(params.carriageBorder, 0.2);
			carriage.graphics.drawRect(0, 0, params.carriageWidth, params.carriageHeight);
			carriage.graphics.endFill();
			container.addChild(carriage);
			
			maska = new Shape();
			maska.graphics.beginFill(0x000000, 0.3);
			maska.graphics.drawRect(0, 0, 100, params.carriageHeight + 8);
			maska.graphics.endFill();
			main.addChild(maska);
			
			scroller = new Sprite();
			scroller.graphics.beginFill(0xbbbbbb);
			scroller.graphics.drawRect(0, 0, 100, 4);
			scroller.graphics.endFill();
			scroller.y = params.carriageHeight + 4;
			scroller.addEventListener(MouseEvent.MOUSE_DOWN, onScrollDown);
			main.addChild(scroller);
			
			animtionBttn = new Button( {
				width:		50,
				height:		37,
				fontSize:	8,
				label:		'Анимац.',
				click:		Main.app.viewAnimation
			});
			animtionBttn.x = width - 36;
			animtionBttn.y = 1;
			main.addChild(animtionBttn);
			
			container.mask = maska;
			
			resize(width, height);
			
			changeChain(chain);
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			addEventListener(MouseEvent.RIGHT_CLICK, onMenu);
			addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			//addEventListener(MouseEvent.MOUSE_MOVE, onToolTipMove);
		}
		
		//private function onToolTipMove(e:MouseEvent):void {
			//container.toolTip = 'Файл: ' + ' ';
		//}
		
		public function resize(width:int, height:int):void {
			currWidth = width;
			currHeight = height;
			
			maska.width = currWidth - 46;
			maska.height = currHeight;
			
			animtionBttn.x = currWidth - 36;
			
			initScroller();
		}
		
		public function set frame(value:int):void {
			if (value < 0) value = 0;
			if (value > chain.length) value = chain.length;
			
			carriage.x = params.carriageWidth * value;
			
			if (carriage.x < -container.x + 30) {
				container.x = -carriage.x + 30;
			}else if (carriage.x > -container.x + maska.width - 30) {
				container.x = -carriage.x + maska.width - 30;
			}
			
			checkPosition();
			
		}
		public function get frame():int {
			return int(carriage.x / params.carriageWidth);
		}
		
		public function changeChain(chain:Array, newAnimation:Boolean = false):void {
			
			if (newAnimation)
				selectClear();
			
			this.chain = chain;
			
			line.graphics.clear();
			line.removeChildren();
			
			var previewFrame:int = -1;
			var color:uint;
			var newFrame:Boolean;
			
			for (var i:int = 0; i < this.chain.length; i++) {
				
				newFrame = Boolean(previewFrame != this.chain[i]);
				color = (newFrame) ? params.frameKeyColor : params.frameColor;
				previewFrame = this.chain[i];
				
				line.graphics.lineStyle(1, color, (newFrame) ? 0.5 : 0.3, true);
				line.graphics.beginFill(color, (newFrame) ? 0.3 : 0.1);
				line.graphics.drawRect(i * params.carriageWidth, 0, params.carriageWidth, params.carriageHeight);
				line.graphics.endFill();
				
				if (newFrame) {
					var text:TextField = Util.drawText( {
						text:		String(this.chain[i]),
						size:		11,
						color:		0xffffff,
						autoSize:	TextFieldAutoSize.LEFT//,
						//border:		true
					});
					text.x = i * params.carriageWidth + 8 - text.width * 0.5;
					text.y = params.carriageHeight - text.height + 2;
					line.addChild(text);
				}
			}
			
			line.graphics.lineStyle(1, params.frameKeyColor, 0.5, true);
			line.graphics.beginFill(params.frameKeyColor, 0.3);
			line.graphics.drawRect(i * params.carriageWidth, 0, params.carriageWidth * 3, params.carriageHeight);
			
			var plusData:BitmapData = new BitmapData(9, 9, true, 0x00ffffff);
			plusData.fillRect(new Rectangle(3, 0, 3, 9), params.frameKeyColor * 0xff);
			plusData.fillRect(new Rectangle(0, 3, 9, 3), params.frameKeyColor * 0xff);
			var plus:Bitmap = new Bitmap(plusData);
			plus.x = i * params.carriageWidth + 19;
			plus.y = 14;
			line.addChild(plus);
			
			initCarriage();
			initScroller();
			
			if (frame > this.chain.length - 1) {
				frame = this.chain.length - 1;
				selectToFrame(frame, frame);
				checkPosition();
			}
		}
		
		private function initCarriage():void {
			if (chain.length == 0 || editLabel)
				carriage.visible = false;
			else
				carriage.visible = true;
		}
		private function initScroller():void {
			if (container.width > maska.width) {
				scroller.visible = true;
				scroller.width = maska.width * maska.width / container.width;
			}else {
				scroller.visible = false;
			}
		}
		
		
		// Выбор кадра
		private var moveWay:int = 0;
		private function onDown(e:MouseEvent):void {
			if (scrollerDrag) return;
			
			moveWay = 0;
			onUp();
			Main.app.addEventListener(MouseEvent.MOUSE_UP, onUp);
			addEventListener(MouseEvent.MOUSE_MOVE, onMove);
		}
		private function onUp(e:MouseEvent = null):void {
			Main.app.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
		}
		private function onMove(e:Event):void {
			moveWay ++;
			if (moveWay < 2) return;
			
			var frame:int = int(line.mouseX / params.carriageWidth);
			if (frame < 0) frame = 0;
			if (frame > chain.length) frame = chain.length;
			
			if (this.frame == frame) return;
			
			selectToFrame(frame, frame);
			
			this.frame = frame;
			view.setFrame(frame);
		}
		
		
		private var selectPoint:Point;
		private var selectTime:int;
		private function onClick(e:MouseEvent):void {
			selectClear();
			
			if (chain.length == 0) return;
			if (editLabel) {
				if (Main.app.stage.focus != editLabel) {
					onEditComplete();
				}else {
					return;
				}
			}
			
			var frame:int = int(line.mouseX / params.carriageWidth);
			if (frame < 0) frame = 0;
			if (frame > chain.length) frame = chain.length;
			
			if (Main.shift) {
				selectToFrame(this.frame, frame);
				return;
			}else {
				selectToFrame(frame, frame);
			}
			
			this.frame = frame;
			view.setFrame(frame);
			
			Main.app.appStage.focus = this;
			
			if (selectTime + 200 > getTimer() && Math.sqrt((selectPoint.x - mouseX) * (selectPoint.x - mouseX) + (selectPoint.y - mouseY) * (selectPoint.y - mouseY)) < 4) {
				editFrame();
			}else{
				selectTime = getTimer();
				selectPoint = new Point(mouseX, mouseY);
			}
		}
		private function onWheel(e:MouseEvent):void {
			if (e.delta > 0) {
				container.x += 30;
			}else {
				container.x -= 30;
			}
			
			checkPosition();
		}
		
		private function onMenu(e:MouseEvent):void {
			var frame:int = int(line.mouseX / params.carriageWidth);
			if (frame < 0) frame = 0;
			if (frame > chain.length) frame = chain.length;
			selectToFrame(frame, frame);
			
			var available:Boolean = availableFrame(frame);
			var contextMenu:ContextMenu = new ContextMenu();
			var fileNameCMI:ContextMenuItem = new ContextMenuItem(frameFileName(frame), false, false);
			//var setCMI:ContextMenuItem = new ContextMenuItem('Настроить', false, true, true);
			var editCMI:ContextMenuItem = new ContextMenuItem('Редактировать', false, available, true);
			var copyCMI:ContextMenuItem = new ContextMenuItem('Копировать', true, available, true);
			var pasteCMI:ContextMenuItem = new ContextMenuItem('Вставить', false, true, true);
			var reverseCMI:ContextMenuItem = new ContextMenuItem('Отразить и вставить', false, true, true);
			var deleteCMI:ContextMenuItem = new ContextMenuItem('Удалить', true, available, true);
			
			//contextMenu.addItem(setCMI);
			contextMenu.addItem(fileNameCMI);
			contextMenu.addItem(editCMI);
			contextMenu.addItem(copyCMI);
			contextMenu.addItem(pasteCMI);
			contextMenu.addItem(reverseCMI);
			contextMenu.addItem(deleteCMI);
			
			contextMenu.addEventListener(Event.SELECT, onMenuSelect);
			
			contextMenu.display(Main.app.appStage, Main.app.appStage.mouseX, Main.app.appStage.mouseY);
			
			function onMenuSelect(e:Event):void {
				//if (e.target == setCMI)
					//Main.app.viewAnimation();
				
				if (e.target == pasteCMI && selectData)
					view.pasteChain(selectData.from);
				
				if (e.target == reverseCMI && selectData)
					view.pasteChain(selectData.from, true);
				
				if (e.target == deleteCMI && selectData)
					view.deleteChain(selectData.from, selectData.to);
				
				if (e.target == copyCMI && selectData)
					view.copyChain(selectData.from, selectData.to);
				
				if (e.target == editCMI)
					editFrame();
				
				contextMenu.removeEventListener(Event.SELECT, onMenuSelect);
			}
		}
		
		
		
		
		private function checkPosition():void {
			if (container.x > 0)
				container.x = 0;
			else if (container.width > maska.width && container.x < maska.width - container.width) {
				if (container.width < maska.width) {
					container.x = 0;
				}else{
					container.x = maska.width - container.width;
				}
			}
			
			scroller.x = (maska.width - scroller.width) * -container.x / (container.width - maska.width);
		}
		
		public function handleKey(e:KeyboardEvent):void {
			
			if (e.keyCode == Keyboard.LEFT) {
				frame--;
				selectToFrame(frame, frame);
				view.setFrame(frame);
			}
			
			if (e.keyCode == Keyboard.RIGHT) {
				frame++;
				selectToFrame(frame, frame);
				view.setFrame(frame);
			}
			
			if (e.keyCode == Keyboard.DELETE) {
				view.deleteChain(selectData.from, selectData.to);
			}
			
			if (e.keyCode == Keyboard.ENTER && editLabel) {
				view.editFrame(editFrameID, int(editLabel.text));
				editClear();
			}
			
			if (!e.ctrlKey || !selectData) return;
			
			if (e.keyCode == Keyboard.C) {
				view.copyChain(selectData.from, selectData.to);
			}
			
			if (e.keyCode == Keyboard.V) {
				view.pasteChain(selectData.from);
			}
			
			if (e.keyCode == Keyboard.D) {
				view.copyChain(selectData.from, selectData.to);
				view.pasteChain(selectData.from);
			}
		}
		
		
		public function availableFrame(frame:int):Boolean {
			if (!view || !view.animInfo || view.animInfo.chain.length <= frame || frame < 0)
				return false;
			
			return true;
		}
		
		
		/**
		 * Имя файла
		 * @param	frame
		 * @return
		 */
		public function frameFileName(frame:int):String {
			if (!view || !view.animInfo || view.animInfo.chain.length <= frame || frame < 0 || !view.animInfo.files[view.animInfo.chain[frame]])
				return 'Нет данных';
			
			return view.animInfo.files[view.animInfo.chain[frame]].name;
		}
		
		
		public static var editLabel:TextField;
		private var editFrameID:int
		private function editFrame():void {
			editClear();
			
			if (!selectData || !availableFrame(selectData.from)) return;
			
			editFrameID = selectData.from;
			
			editLabel = Util.drawText( {
				width:			24,
				text:			String(chain[editFrameID]),
				size:			12,
				color:			0x111111,
				type:			TextFieldType.INPUT,
				textAlign:		TextFormatAlign.CENTER,
				selectable:		true,
				border:				true,
				background:			true,
				borderColor:		0x111111,
				backgroundColor:	0xffffff
			});
			editLabel.x = editFrameID * params.carriageWidth + 10 - editLabel.width * 0.5;
			editLabel.y = params.carriageHeight - editLabel.height + 2;
			editLabel.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onEditComplete);
			line.addChild(editLabel);
			
			initCarriage();
		}
		private function onEditComplete(e:FocusEvent = null):void {
			editLabel.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onEditComplete);
			handleKey(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, Keyboard.ENTER, Keyboard.ENTER));
		}
		private function editClear():void {
			if (!editLabel) return;
			
			if (editLabel.parent) editLabel.parent.removeChild(editLabel);
			editLabel.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onEditComplete);
			editLabel = null;
			
			initCarriage();
		}
		
		
		private var selectData:Object;
		private var copyData:Object;
		public function selectToFrame(from:int, to:int):void {
			
			var min:int = Math.min(from, to);
			var max:int = Math.max(from, to);
			
			max++;
			
			if (!selecter) {
				selecter = new Shape();
				container.addChildAt(selecter, container.getChildIndex(line));
			}else{
				selecter.graphics.clear();
			}
			
			selecter.graphics.beginFill(0xffffff, 0.4);
			selecter.graphics.lineStyle(1, 0xffffff, 1);
			selecter.graphics.drawRect(0, 0, int(params.carriageWidth * (max - min)), params.carriageHeight);
			selecter.graphics.endFill();
			selecter.x = min * params.carriageWidth;
			
			selectData = { from:min, to:max };
		}
		public function selectClear():void {
			
			selectData = null;
			
			if (!selecter) return;
			if (container.contains(selecter)) container.removeChild(selecter);
			selecter = null;
		}
		
		
		
		private var scrollerDrag:Boolean;
		private function onScrollDown(e:MouseEvent):void {
			scrollerDrag = true;
			
			Main.app.addEventListener(MouseEvent.MOUSE_UP, onScrollUp);
			scroller.startDrag(false, new Rectangle(0, scroller.y, maska.width - scroller.width + 1, 0));
			scroller.addEventListener(Event.ENTER_FRAME, onScrollMove);
		}
		private function onScrollUp(e:MouseEvent):void {
			scrollerDrag = false;
			
			Main.app.removeEventListener(MouseEvent.MOUSE_UP, onScrollUp);
			scroller.removeEventListener(Event.ENTER_FRAME, onScrollMove);
			scroller.stopDrag();
		}
		private function onScrollMove(e:Event):void {
			container.x = -scroller.x * (container.width - maska.width) / (maska.width - scroller.width);
		}
		
	}

}