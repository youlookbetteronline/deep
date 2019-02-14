package 
{
	import effects.Effect;
	import enixan.Size;
	import enixan.Util;
	import enixan.components.Button;
	import enixan.components.List;
	import enixan.components.ListNode;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author 
	 */
	public class AnimNode extends ListNode 
	{
		
		private var image:Bitmap;
		private var closeBttn:Button;
		private var cloneBttn:Button;
		private var editBttn:Button;
		//private var framesLabel:TextField;
		
		public function AnimNode(list:List, data:Object) 
		{
			data.textSize = 11;
			data.textAlign = 'center';
			data.textWidth = list.nodeWidth - 4;
			
			super(list, data);
			
			addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			addEventListener(MouseEvent.MIDDLE_CLICK, onDelete);
			
			toolTip = 'Click + Ctrl - добавит эту анимацию не убирая текущую\nMiddleClick - удалит анимацию\nDoubleClick - позволит переименовать анимации';
		}
		
		override public function draw():void {
			
			super.draw();
			
			image = new Bitmap();
			addChildAt(image, getChildIndex(titleLabel));
			load(data.item.bitmapData);
			
			titleLabel.x = 2;
			titleLabel.y = nodeHeight - titleLabel.height - 2;
			
			// Close
			closeBttn = new Button( {
				label:		null,
				width:		12,
				height:		12,
				color1:		0x990000,
				color2:		0x770000,
				radius:		4,
				click:		onDelete
			});
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
			
			
			
			//framesLabel = Util.drawText( {
				//text:		
			//});
			
			
			// Clone
			cloneBttn = new Button( {
				label:		'c',
				width:		12,
				height:		12,
				color1:		0xffca3b,
				color2:		0xffba01,
				radius:		4,
				textFieldY:	4,
				click:		function():void {
					Main.app.animationClone(data.item)
				}
			});
			cloneBttn.x = closeBttn.x - cloneBttn.width - 3;
			cloneBttn.y = closeBttn.y;
			addChild(cloneBttn);
			
			// Edit
			editBttn = new Button( {
				label:		'e',
				width:		18,
				height:		18,
				color1:		0x33ff33,
				color2:		0x66ff66,
				radius:		4,
				click:		edit
			});
			editBttn.x = cloneBttn.x - editBttn.width - 6;
			editBttn.y = closeBttn.y;
			//addChild(editBttn);
			
		}
		
		public function load(bitmapData:BitmapData):void {
			
			image.bitmapData = bitmapData;
			image.smoothing = true;
			
			Size.size(image, background.width * 0.9, background.height * 0.9);
			
			image.x = background.x + background.width * 0.5 - image.width * 0.5;
			image.y = background.y + background.height * 0.5 - image.height * 0.5;
			
		}
		
		
		private function onDelete(e:MouseEvent = null):void {
			Main.app.animationDelete(data.item)
		}
		
		
		override public function focus(passive:Boolean = false):void {
			//if (list.focusedNode == this)
				//return;
			
			if (Main.ctrl) {
				if (list.focusedNodes.length > 1 && list.focusedNodes.indexOf(this) > -1) {
					var node:ListNode = list.focusedNodes.splice(list.focusedNodes.indexOf(this), 1)[0];
					node.unfocus();
					Main.app.mainView.clearViews(node.data.item);
					
					if (!passive)
						list.select(list.focusedNodes[0]);
					
					return;
				}
			}else {
				//if (list.focusedNodes.indexOf(this) == -1)
					clearFocus(this);
			}
			
			Effect.light(background, 0.1);
			//list.focusedNode = this;
			if (list.focusedNodes.indexOf(this) == -1)
				list.focusedNodes.push(this);
			
			if (!passive) {
				list.select(this);
			}
		}
		
		
		
		private var previewName:String;
		public function edit():void {
			
			if (titleLabel.type == TextFieldType.INPUT) return;
			
			previewName = titleLabel.text;
			
			titleLabel.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusOut);
			
			titleLabel.name = 'edit';
			titleLabel.type = TextFieldType.INPUT;
			titleLabel.multiline = false;
			titleLabel.selectable = true;
			titleLabel.border = true;
			titleLabel.background = true;
			titleLabel.borderColor = 0x111111;
			titleLabel.backgroundColor = 0xffffff;
			titleLabel.textColor = 0x111111;
			titleLabel.setSelection(0, titleLabel.text.length);
			
			Main.app.appStage.focus = titleLabel;
			list.blockDrag = true;
		}
		private function onFocusOut(e:FocusEvent):void {
			
			titleLabel.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusOut);
			titleLabel.selectable = false;
			titleLabel.border = false;
			titleLabel.background = false;
			titleLabel.textColor = 0xffffff;
			titleLabel.type = TextFieldType.DYNAMIC;
			titleLabel.setSelection(0, 0);
			
			var animInfo:AnimInfo = data.item as AnimInfo;
			if (Main.app.animationCheckName(titleLabel.text)) {
				animInfo.changeName(titleLabel.text);
				
			}else if (previewName){
				titleLabel.text = animInfo.name;// previewName;
			}
			
			previewName = null;
			list.blockDrag = false;
		}
		
		
		private function onDoubleClick(e:MouseEvent):void {
			edit();
		}
		
		
		override public function dispose():void {
			removeEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			removeEventListener(MouseEvent.MIDDLE_CLICK, onDelete);
			
			super.dispose();
		}
	}

}