package 
{
	import com.greensock.TweenLite;
	import enixan.Size;
	import enixan.Util;
	import enixan.components.Button;
	import enixan.components.CheckBox;
	import enixan.components.CheckList;
	import enixan.components.ComponentBase;
	import enixan.components.NumericBox;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	
	public class ViewManager extends ComponentBase 
	{
		
		public const HIDDEN_HEIGHT:int = 20;
		
		public var currWidth:int = 0;
		public var currHeight:int = 0;
		
		
		private var titleLabel:TextField;
		private var nothingLabel:TextField;
		private var imageCont:Sprite;
		private var image:Bitmap;
		private var xLabel:TextField;
		private var xTitleLabel:TextField;
		private var yLabel:TextField;
		private var yTitleLabel:TextField;
		private var playBttn:PlayButton;
		private var numericBoxTitleLabel:TextField;
		private var numericBox:NumericBox;
		private var animTypeBoxTitleLabel:TextField;
		private var animTypeBox:CheckList;
		public var animationLine:AnimationLine;
		private var velocityBox:NumericBox;
		private var velocityBoxTitleLabel:TextField;
		private var cellsTitleLabel:TextField;
		private var rowsTitleLabel:TextField;
		//private var cellsLabel:TextField;
		//private var rowsLabel:TextField;
		private var cellsBox:NumericBox;
		private var rowsBox:NumericBox;
		private var multiAnimTitle:TextField;
		private var multiAnimCheckBox:CheckBox;
		
		private var container:Sprite;
		private var infoView:Sprite;
		private var animationView:Sprite;
		private var stageView:Sprite;
		private var pointView:Sprite;
		
		public var animInfo:AnimInfo;
		public var stageInfo:StageInfo;
		
		private var animTypeValues:Array = [
			{ value:AnimInfo.LINEAR_ANIMATION, name:'Линейная' },
			{ value:AnimInfo.PINGPONG_ANIMATION, name:'Вперед-назад' },
			{ value:AnimInfo.ADVANCED_ANIMATION, name:'Пользовательская' }
		];
		
		private var __hidden:Boolean;
		public function set hidden(value:Boolean):void {
			if (value == __hidden) return;
			__hidden = value;
		}
		public function get hidden():Boolean {
			return __hidden;
		}
		
		override public function get height():Number {
			if (hidden)
				return HIDDEN_HEIGHT;
			
			return super.height;
		}
		
		public function ViewManager(stage:Stage, width:int, height:int, params:Object=null) 
		{
			super();
			
			container = new Sprite();
			addChild(container);
			
			resize(width, height, true);
			init();
		}
		
		private function drawBackground():void {
			graphics.clear();
			graphics.beginFill(0x444444);
			graphics.drawRect(0, 0, currWidth, currHeight);
			graphics.endFill();
		}
		
		public function init():void {
			
			nothingLabel.visible = false;
			infoView.visible = false;
			stageView.visible = false;
			animationView.visible = false;
			pointView.visible = false;
			
			if (animInfo) {
				infoView.visible = true;
				animationView.visible = true;
			}else if (stageInfo) {
				infoView.visible = true;
				stageView.visible = true;
			}else if (targetPoint) {
				infoView.visible = true;
				pointView.visible = true;
			}else {
				nothingLabel.visible = true;
			}
		}
		
		private function draw():void {
			
			container.removeChildren();
			drawBackground();
			
			
			// Nothing
			nothingLabel = Util.drawText( {
				text:		'Ничего нет',
				color:		0x666666,
				size:		36,
				width:		200
			});
			nothingLabel.x = currWidth * 0.5 - nothingLabel.width * 0.5;
			nothingLabel.y = 46;
			container.addChild(nothingLabel);
			
			
			// Info
			infoView = new Sprite();
			container.addChild(infoView);
			
			titleLabel = Util.drawText( {
				textAlign:		TextFormatAlign.LEFT,
				rightMargin:	4,
				text:			'...',
				color:			0xffffff,
				size:			18,
				width:			200
			});
			titleLabel.x = 10;
			titleLabel.y = 5;
			infoView.addChild(titleLabel);
			
			xTitleLabel = Util.drawText( {
				textAlign:		TextFormatAlign.LEFT,
				autoSize:		TextFieldAutoSize.LEFT,
				text:			'x:',
				color:			0xffffff,
				size:			14
			});
			xTitleLabel.x = 10;
			xTitleLabel.y = 110;
			infoView.addChild(xTitleLabel);
			
			xLabel = Util.drawText( {
				textAlign:		TextFormatAlign.CENTER,
				text:			'0',
				color:			0x111111,
				size:			14,
				width:			42,
				border:			true,
				borderColor:	0x111111,
				background:			true,
				backgroundColor:	0xffffff,
				selectable:		true,
				type:			'input',
				embedFonts:		false
			});
			xLabel.restrict = '-0-9';
			xLabel.maxChars = 5;
			xLabel.x = xTitleLabel.x + xTitleLabel.width;
			xLabel.y = xTitleLabel.y;
			infoView.addChild(xLabel);
			xLabel.addEventListener(TextEvent.TEXT_INPUT, onCoordinatesChange);
			
			yTitleLabel = Util.drawText( {
				textAlign:		TextFormatAlign.LEFT,
				autoSize:		TextFieldAutoSize.LEFT,
				text:			'y:',
				color:			0xffffff,
				size:			14
			});
			yTitleLabel.x = xLabel.x + xLabel.width + 6;
			yTitleLabel.y = xTitleLabel.y;
			infoView.addChild(yTitleLabel);
			
			yLabel = Util.drawText( {
				textAlign:		TextFormatAlign.CENTER,
				text:			'0',
				color:			0x111111,
				size:			14,
				width:			42,
				border:			true,
				borderColor:	0x111111,
				background:			true,
				backgroundColor:	0xffffff,
				selectable:		true,
				type:			'input',
				embedFonts:		false
			});
			yLabel.restrict = '-0-9';
			yLabel.maxChars = 5;
			yLabel.x = yTitleLabel.x + yTitleLabel.width;
			yLabel.y = xTitleLabel.y;
			infoView.addChild(yLabel);
			yLabel.addEventListener(TextEvent.TEXT_INPUT, onCoordinatesChange);
			yLabel.addEventListener(FocusEvent.FOCUS_OUT, onCoordinatesChange);
			
			
			
			// Анимация
			animationView = new Sprite();
			animationView.x = 150;
			animationView.y = 0;
			container.addChild(animationView);
			
			animationLine = new AnimationLine(this, [], currWidth - 180, 50);
			animationLine.x = 0;
			animationLine.y = 90;
			animationView.addChild(animationLine);
			
			
			multiAnimCheckBox = new CheckBox( {
				width:		18,
				height:		18,
				text:		'Отображать всё',
				textParams:	{
					size:	16
				},
				onChange:	function():void {
					Main.app.mainView.multiAnim = multiAnimCheckBox.check;
					Main.app.mainView.review();
				}
			});
			multiAnimCheckBox.check = Main.app.mainView.multiAnim;
			multiAnimCheckBox.x = 0;
			multiAnimCheckBox.y = 10;
			animationView.addChild(multiAnimCheckBox);
			
			/*multiAnimTitle = Util.drawText( {
				textAlign:		TextFormatAlign.LEFT,
				autoSize:		TextFieldAutoSize.LEFT,
				text:			'Отображать всё',
				color:			0xffffff,
				size:			14
			});
			multiAnimTitle.x = multiAnimCheckBox.x + multiAnimCheckBox.width + 4;
			multiAnimTitle.y = multiAnimCheckBox.y - 2;
			animationView.addChild(multiAnimTitle);*/
			
			
			playBttn = new PlayButton( {
				played:		Main.app.played,
				width:		60,
				height:		60,
				color1:		0xbbbbbb,
				color2:		0x999999,
				click:		onPlay
			});
			playBttn.x = -130;
			playBttn.y = 40;
			animationView.addChild(playBttn);
			
			numericBoxTitleLabel = Util.drawText( {
				textAlign:		TextFormatAlign.LEFT,
				autoSize:		TextFieldAutoSize.LEFT,
				text:			'Замедление:',
				color:			0xffffff,
				size:			14
			});
			numericBoxTitleLabel.x = 98 - 150;
			numericBoxTitleLabel.y = 34;
			animationView.addChild(numericBoxTitleLabel);
			
			numericBox = new NumericBox();
			numericBox.x = 100 - 150;
			numericBox.y = 60;
			animationView.addChild(numericBox);
			numericBox.addEventListener(Event.CHANGE, onNumericChange);
			
			//
			animTypeBoxTitleLabel = Util.drawText( {
				textAlign:		TextFormatAlign.LEFT,
				autoSize:		TextFieldAutoSize.LEFT,
				text:			'Тип анимации:',
				color:			0xffffff,
				size:			14
			});
			animTypeBoxTitleLabel.x = 200;
			animTypeBoxTitleLabel.y = 20;
			animationView.addChild(animTypeBoxTitleLabel);
			
			animTypeBox = new CheckList( {
				values:		animTypeValues
			});
			animTypeBox.x = 200;
			animTypeBox.y = 46;
			animationView.addChild(animTypeBox);
			animTypeBox.addEventListener(Event.CHANGE, onNumericChange);
			
			//
			velocityBoxTitleLabel = Util.drawText( {
				textAlign:		TextFormatAlign.LEFT,
				autoSize:		TextFieldAutoSize.LEFT,
				text:			'Скорость:',
				color:			0xffffff,
				size:			14
			});
			velocityBoxTitleLabel.x = 70;
			velocityBoxTitleLabel.y = 34;
			animationView.addChild(velocityBoxTitleLabel);
			
			velocityBox = new NumericBox( {
				current:	MainView.velocity,
				step:		0.01,
				minValue:	0.01,
				maxValue:	0.5
			});
			velocityBox.x = 70;
			velocityBox.y = 60;
			animationView.addChild(velocityBox);
			velocityBox.addEventListener(Event.CHANGE, function(e:Event):void {
				MainView.velocity = velocityBox.value;
			});
			
			
			// Point
			pointView = new Sprite();
			pointView.x = 150;
			pointView.y = 0;
			container.addChild(pointView);
			
			
			// Stages
			stageView = new Sprite();
			stageView.x = 150;
			stageView.y = 0;
			container.addChild(stageView);
			
			cellsTitleLabel = Util.drawText( {
				textAlign:		TextFormatAlign.LEFT,
				autoSize:		TextFieldAutoSize.LEFT,
				text:			'X:',
				color:			0xffffff,
				size:			14
			});
			cellsTitleLabel.x = 20;
			cellsTitleLabel.y = 20;
			stageView.addChild(cellsTitleLabel);
			
			/*cellsLabel = Util.drawText( {
				textAlign:		TextFormatAlign.CENTER,
				text:			'0',
				color:			0x111111,
				size:			14,
				width:			42,
				border:			true,
				borderColor:	0x111111,
				background:			true,
				backgroundColor:	0xffffff,
				selectable:		true,
				type:			'input',
				embedFonts:		false
			});
			cellsLabel.restrict = '0123456789';
			cellsLabel.maxChars = 2;
			cellsLabel.x = cellsTitleLabel.x;
			cellsLabel.y = cellsTitleLabel.y + cellsTitleLabel.height;
			stageView.addChild(cellsLabel);
			cellsLabel.addEventListener(TextEvent.TEXT_INPUT, onAreaChange);*/
			
			cellsBox = new NumericBox( {
				current:	1,
				step:		1,
				minValue:	0,
				maxValue:	100
			});
			cellsBox.x = cellsTitleLabel.x;
			cellsBox.y = cellsTitleLabel.y + cellsTitleLabel.height + 2;
			stageView.addChild(cellsBox);
			cellsBox.addEventListener(Event.CHANGE, function(e:Event):void {
				Main.app.mainView.handAreaSize = true;
				Main.app.mainView.grid(cellsBox.value, rowsBox.value);
			});
			
			rowsTitleLabel = Util.drawText( {
				textAlign:		TextFormatAlign.LEFT,
				autoSize:		TextFieldAutoSize.LEFT,
				text:			'Z:',
				color:			0xffffff,
				size:			14
			});
			rowsTitleLabel.x = 130;
			rowsTitleLabel.y = cellsTitleLabel.y;
			stageView.addChild(rowsTitleLabel);
			
			/*rowsLabel = Util.drawText( {
				textAlign:		TextFormatAlign.CENTER,
				text:			'0',
				color:			0x111111,
				size:			14,
				width:			42,
				border:			true,
				borderColor:	0x111111,
				background:			true,
				backgroundColor:	0xffffff,
				selectable:		true,
				type:			'input',
				embedFonts:		false
			});
			rowsLabel.restrict = '0123456789';
			rowsLabel.maxChars = 2;
			rowsLabel.x = rowsTitleLabel.x;
			rowsLabel.y = rowsTitleLabel.y + rowsTitleLabel.height;
			stageView.addChild(rowsLabel);
			rowsLabel.addEventListener(TextEvent.TEXT_INPUT, onAreaChange);*/
			
			
			rowsBox = new NumericBox( {
				current:	1,
				step:		1,
				minValue:	0,
				maxValue:	100
			});
			rowsBox.x = rowsTitleLabel.x;
			rowsBox.y = rowsTitleLabel.y + rowsTitleLabel.height + 2;
			stageView.addChild(rowsBox);
			rowsBox.addEventListener(Event.CHANGE, function(e:Event):void {
				Main.app.mainView.handAreaSize = true;
				Main.app.mainView.grid(cellsBox.value, rowsBox.value);
			});
			
			var normalizeBttn:Button = new Button( {
				label:		'Выровнять стадии',
				width:		190,
				height:		40,
				click:		Main.app.normilizeStages
			});
			normalizeBttn.x = cellsTitleLabel.x;
			normalizeBttn.y = cellsBox.y + cellsBox.height + 20;
			stageView.addChild(normalizeBttn);
			
			
			
			animationView.visible = false;
			stageView.visible = false;
			
		}
		
		/**
		 * 
		 */
		private function onCoordinatesChange(e:*):void {
			setTimeout(function():void {
				Main.app.mainView.moveTo(int(xLabel.text), int(yLabel.text));
			}, 10);
		}
		
		
		/**
		 * 
		 */
		/*private function onAreaChange(e:TextEvent):void {
			setTimeout(function():void {
				Main.app.mainView.handAreaSize = true;
				Main.app.mainView.grid(int(cellsLabel.text), int(rowsLabel.text));
			}, 10);
		}*/
		
		
		/**
		 * 
		 */
		public function areaSize(cells:int, rows:int):void {
			cellsBox.value = cells;
			rowsBox.value = rows;
		}
		
		
		private function updateImage(bmd:BitmapData):void {
			image.bitmapData = bmd;
			image.smoothing = true;
			image.scaleX = image.scaleY = 1;
			
			Size.size(image, 120, 120);
			
			image.x = imageCont.x + int(imageCont.width * 0.5 - image.width * 0.5);
			image.y = imageCont.y + int(imageCont.height * 0.5 - image.height * 0.5);
		}
		private function updateTitle(name:String):void {
			titleLabel.text = name;
		}
		private function updateName(name:String):void {
			//nameLabel.text = name;
		}
		
		
		
		
		
		public function view(node:*):void {
			
			targetPoint = null;
			animInfo = null;
			stageInfo = null;
			
			if (node is AnimInfo) {
				
				animInfo = null;
				
				var preAnimInfo:AnimInfo = node as AnimInfo;
				
				titleLabel.text = 'Анимация';
				//nameLabel.text = preAnimInfo.name;
				xLabel.text = preAnimInfo.x.toString();
				yLabel.text = preAnimInfo.y.toString();
				
				var index:int = 0;
				for (var i:int = 0; i < animTypeValues.length; i++) {
					if (preAnimInfo.animType == animTypeValues[i].value)
						index = i;
				}
				animTypeBox.selected = index;
				numericBox.value = preAnimInfo.repeat;
				velocityBox.value = MainView.velocity;
				
				if (animTypeBox.value == AnimInfo.ADVANCED_ANIMATION) {
					numericBoxTitleLabel.alpha = 0.3;
					numericBox.enabled = false;
				}else {
					numericBoxTitleLabel.alpha = 1;
					numericBox.enabled = true;
				}
				
				animInfo = preAnimInfo;
				animationLine.changeChain(animInfo.chain, true);
				
				//updateImage(animInfo.bmds[0]);
				
			}else if (node is StageInfo) {
				
				stageInfo = node as StageInfo;
				
				titleLabel.text = 'Стадия';
				//nameLabel.text = stageInfo.name;
				xLabel.text = stageInfo.x.toString();
				yLabel.text = stageInfo.y.toString();
				
				//updateImage(stageInfo.bmd);
				
			}else if (node && node.hasOwnProperty('extra') > 0) {
				
				titleLabel.text = 'Точка';
				
				xLabel.text = node.x.toString();
				yLabel.text = node.y.toString();
				
				updatePoint(node);
				
			}
			
			init();
		}
		public function clear():void {
			titleLabel.text = '...';
			xLabel.text = '0';
			yLabel.text = '0';
			
			animInfo = null;
			stageInfo = null;
			targetPoint = null;
			
			init();
		}
		
		public function position(x:int, y:int):void {
			xLabel.text = x.toString();
			yLabel.text = y.toString();
		}
		
		public function resize(width:int, height:int, clear:Boolean = false):void {
			currWidth = width;
			currHeight = height;
			
			if (clear) {
				draw();
			}else {
				drawBackground();
				animationLine.resize(currWidth - 180, 50);
			}
			
			nothingLabel.x = currWidth * 0.5 - nothingLabel.width * 0.5;
			
		}
		
		
		// Point
		private var targetPoint:Object;
		public function updatePoint(node:Object):void {
			targetPoint = node;
			pointView.removeChildren();
			
			if (!node || !node.extra) return;
			
			var infoLabel:TextField = Util.drawText( {
				text:		'Параметры точек',
				size:		17,
				color:		0xffffff
			});
			infoLabel.x = 10;
			infoLabel.y = 6;
			pointView.addChild(infoLabel);
			
			var index:int = 0;
			var extra:Object = targetPoint.extra;
			if (!extra) return;
			for (var s:String in targetPoint.extra) {
				var titleLabel:TextField = Util.drawText( {
					text:		s,
					size:		15,
					color:		0xffffff,
					width:		60,
					textAlign:	'right'
				});
				titleLabel.x = 10;
				titleLabel.y = 40 + index * 30;
				pointView.addChild(titleLabel);
				
				var valueLabel:TextField = Util.drawText( {
					text:		targetPoint.extra[s],
					width:		200,
					size:		15,
					color:		0x111111,
					border:		true,
					borderColor:0x000000,
					background:	true,
					backgroundColor:0xffffff,
					type:		'input'
				});
				valueLabel.name = s;
				valueLabel.addEventListener(Event.REMOVED_FROM_STAGE, onPointRemove);
				valueLabel.addEventListener(TextEvent.TEXT_INPUT, onPointEdit);
				valueLabel.x = titleLabel.x + titleLabel.width + 6;
				valueLabel.y = titleLabel.y;
				pointView.addChild(valueLabel);
				
				index++;
			}
		}
		private function onPointEdit(e:TextEvent):void {
			var text:TextField = e.target as TextField;
			setTimeout(function():void {
				if (!targetPoint) return;
				targetPoint.extra[text.name] = text.text;
			}, 10);
		}
		private function onPointRemove(e:Event):void {
			var text:TextField = e.target as TextField;
			text.removeEventListener(Event.REMOVED_FROM_STAGE, onPointRemove);
			text.removeEventListener(TextEvent.TEXT_INPUT, onPointEdit);
		}
		
		
		// Animation
		public function animationUpdate():void {
			if (!animInfo) return;
			animationLine.frame = animInfo.frame;
		}
		public function setFrame(frame:int):void {
			playBttn.played = false;
			Main.app.animationSetChainframe(frame);
		}
		public function editFrame(framePosition:int, frame:int):void {
			if (!animInfo || framePosition < 0 || animInfo.chain.length <= framePosition || frame < 0 || frame >= animInfo.bmds.length) return;
			animInfo.chain[framePosition] = frame;
			animationLine.changeChain(animInfo.chain);
		}
		public function onPlay():void {
			playBttn.played = animationView.visible ? !playBttn.played : false;
			Main.app.aniamtionPlay(playBttn.played);
		}
		public function copyChain(from:int, to:int):void {
			if (!animInfo) return;
			animInfo.copy(from, to);
		}
		public function pasteChain(to:int, reverse:Boolean = false):void {
			if (!animInfo) return;
			animationLine.changeChain(animInfo.paste(to, reverse));
		}
		public function deleteChain(from:int, to:int):void {
			if (!animInfo) return;
			animationLine.changeChain(animInfo.del(from, to));
		}
		
		private function onNumericChange(e:Event):void {
			if (!animInfo) return;
			
			numericBox.enabled = (animTypeBox.value != AnimInfo.ADVANCED_ANIMATION);
			numericBoxTitleLabel.alpha = numericBox.enabled ? 1 : 0.3;
			
			animInfo.createAnimation(animTypeBox.value, numericBox.value);
			animationLine.changeChain(animInfo.chain);
		}
		
		
		override public function dispose():void {
			removeChildren();
		}
		
	}
	
}

import enixan.components.Button;
import flash.display.Shape;

internal class PlayButton extends Button {
	
	private var playView:Shape;
	private var pauseView:Shape;
	
	public function PlayButton(params:Object):void {
		
		params.label = null;
		params.alpha = 0.05;
		
		playView = new Shape();
		playView.graphics.beginFill(0xFFFFF7);
		playView.graphics.moveTo(0, 0);
		playView.graphics.lineTo(28, 18);
		playView.graphics.lineTo(0, 34);
		playView.graphics.endFill();
		
		pauseView = new Shape();
		pauseView.graphics.beginFill(0xFFFFF7);
		pauseView.graphics.drawRect(0, 0, 10, 26);
		pauseView.graphics.drawRect(16, 0, 10, 26);
		pauseView.graphics.endFill();
		
		super(params);
		
		played = false;
		
	}
	
	public function set played(value:Boolean):void {
		if (value) {
			playView.visible = false;
			pauseView.visible = true;
		}else {
			playView.visible = true;
			pauseView.visible = false;
		}
	}
	public function get played():Boolean {
		return pauseView.visible;
	}
	
	override protected function draw():void {
		
		super.draw();
		
		playView.x = 18;
		playView.y = 13;
		pauseView.x = 18;
		pauseView.y = 18;
		
		addChild(playView);
		addChild(pauseView);
		
	}
	
}