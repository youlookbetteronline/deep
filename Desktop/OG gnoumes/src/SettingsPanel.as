package 
{
	import com.greensock.TweenLite;
	import enixan.components.Button;
	import enixan.components.ComponentBase;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import wins.PreviewWindow;
	import wins.ServerContentWindow;
	
	public class SettingsPanel extends ComponentBase 
	{
		
		[Embed(source = "../res/settings2.png")]
		private var Settings:Class;
		private var settingsBMD:BitmapData = new Settings().bitmapData;
		
		private var container:Sprite;
		private var mainLayer:Sprite;
		private var settingsLayer:Sprite;
		
		private var backgroundColor:ComponentBase;
		private var black:ComponentBase;
		private var gridBttn:GridButton;
		private var flipBttn:Button;
		private var iconBttn:Button;
		private var compileBttn:Button;
		private var newBttn:Button;
		private var settingsBttn:Button;
		private var historyBttn:Button;
		private var bordersBttn:Button;
		public var scaleResetBttn:Button;
		
		public function SettingsPanel() 
		{
			super();
			draw();
			
		}
		
		public function resize():void {
			settingsLayer.x = -settingsLayer.width * 0.5;
			settingsLayer.y = -settingsLayer.height - 6;
			mainLayer.x = -mainLayer.width * 0.5;
		}
		
		private function draw():void {
			
			
			container = new Sprite();
			addChild(container);
			
			settingsLayer = new Sprite();
			container.addChild(settingsLayer);
			mainLayer = new Sprite();
			container.addChild(mainLayer);
			
			
			
			newBttn = new Button( {
				label:		'Новый (N)',
				width:		80,
				height:		32,
				color1:		0xcc9933,
				color2:		0x996622,
				click:		Main.app.onNewProject
			});
			newBttn.toolTip = 'Очистка данных и вызов очистки мусора';
			newBttn.y = 6;
			mainLayer.addChild(newBttn);
			
			compileBttn = new Button( {
				label:		'Собрать (Z)',
				width:		120,
				height:		32,
				click:		function():void {
					new PreviewWindow().show();
				}
			});
			compileBttn.toolTip = 'Сборка проекта';
			compileBttn.x = newBttn.x + newBttn.width + 6;
			compileBttn.y = 6;
			mainLayer.addChild(compileBttn);
			
			settingsBttn = new Button( {
				bmd:		settingsBMD,
				click:		onOpen
			});
			settingsBttn.x = compileBttn.x + compileBttn.width + 6;
			settingsBttn.y = compileBttn.y + 2;
			mainLayer.addChild(settingsBttn);
			settingsBttn.toolTip = 'Vesion ' + Updates.serverVersion + '\n' + 'PNG файлы расценимаются как стадии\nПапки с PNG файлами расцениваются как анимации\nПапки с файлом .as3proj расцениваются как проект\nSWF файлы расцениваются как проект (возможно уже с цветокоррекцией)\n\nM - перемещение общего поля (или ПКМ (Правой кнопкой мыши))\nP - точки\nZ - сборка проекта\nA - редактор анимации (текстовый)\nI - информация о сохранениях\nH - история (фокуса)\nN - новый проект\nS - серверная папка\nB - показвть границы исходных картинок\n\nSHIFT - перемещает все анимации и стадии вместе\nCTRL - перемещает на +10 / клонирует объекты\nESCAPE - отмена\nF11 - на весь экран\nF2 - переименовать анимации\n\nАнимация:\nSPACE - запуск/остановка анимации\nSHIFT - можно выделить ряд кадров\nCtrl+C - копирует\nCtrl+V - вставляет\nCtrl+D - дублирует\nDELETE - удаляет выделенное\nLEFT - кадр назад\nRIGHT - кадр вперед';
			
			
			backgroundColor = new ComponentBase();
			initBackgroundColor(Main.storage.backgroundColor);
			backgroundColor.addEventListener(MouseEvent.CLICK, onBackgoundChange);
			settingsLayer.addChild(backgroundColor);
			
			// 
			gridBttn = new GridButton( {
				click:		onGrid
			});
			gridBttn.x = backgroundColor.x + backgroundColor.width + 4;
			gridBttn.y = 4;
			settingsLayer.addChild(gridBttn);
			
			flipBttn = new Button( {
				label:		'Отразить',
				width:		60,
				height:		26,
				click:		onFlip
			});
			flipBttn.x = gridBttn.x + gridBttn.width + 4;
			settingsLayer.addChild(flipBttn);
			
			iconBttn = new Button( {
				label:		'Точки (P)',
				width:		60,
				height:		26,
				click:		Main.app.showPointWindow
			});
			iconBttn.x = flipBttn.x + flipBttn.width + 4;
			settingsLayer.addChild(iconBttn);
			
			bordersBttn = new Button( {
				label:		'Границы (B)',
				width:		74,
				height:		26,
				click:		function():void {
					Main.app.mainView.showBorders = !Main.app.mainView.showBorders;
				}
			});
			bordersBttn.x = iconBttn.x + iconBttn.width + 4;
			settingsLayer.addChild(bordersBttn);
			
			historyBttn = new Button( {
				label:		'Сервер (S)',
				width:		70,
				height:		26,
				click:		function():void {
					new ServerContentWindow().show();
				}
			});
			historyBttn.x = bordersBttn.x + bordersBttn.width + 4;
			settingsLayer.addChild(historyBttn);
			
			scaleResetBttn = new Button( {
				width:		140,
				height:		30,
				label:		'Вернуть на 100%',
				color0:		0x00e0e8,
				color1:		0x00a2a8,
				click:		function():void {
					Main.app.mainView.resetLayer();
					Main.app.mainView.wheelHandler();
				}
			});
			scaleResetBttn.x = 45;// mainLayer.width >> 1 - scaleResetBttn.width >> 1;
			scaleResetBttn.y = 50;
			scaleResetBttn.visible = false;
			mainLayer.addChild(scaleResetBttn);
			
			// 
			resize();
		}
		
		private function initBackgroundColor(color:uint = 0x282828):void {
			backgroundColor.graphics.clear();
			backgroundColor.graphics.lineStyle(2, 0x777777);
			backgroundColor.graphics.beginFill((color == 0x282828) ? 0xF7F7F7 : 0x282828, 1);
			backgroundColor.graphics.drawRect(0, 0, 28, 24);
			backgroundColor.graphics.endFill();
		}
		
		private var timeout:int;
		private function onOpen():void {
			if (hasEventListener(MouseEvent.ROLL_OVER)) {
				onClose();
				return;
			}else {
				onOver();
			}
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			TweenLite.to(container, 0.15, { y:settingsLayer.height + 12 } );
		}
		private function onOver(e:MouseEvent = null):void {
			clearTimeout(timeout);
			timeout = setTimeout(onClose, 10000);
		}
		private function onClose():void {
			clearTimeout(timeout);
			removeEventListener(MouseEvent.ROLL_OVER, onOver);
			TweenLite.to(container, 0.15, { y:0 } );
		}
		
		private function onBackgoundChange(e:MouseEvent):void {
			var color:int = Main.storage.backgroundColor;
			if (isNaN(color) || !color) color = 0x282828;
			color = (color == 0x282828) ? 0xF7F7F7 : 0x282828;
			
			Main.app.mainView.setBackgroundColor(color);
			initBackgroundColor(color);
		}
		private function onGrid():void {
			Main.app.mainView.gridLayer.visible = !Main.app.mainView.gridLayer.visible;
		}
		private function onFlip():void {
			Main.app.mainView.flip = !Main.app.mainView.flip;
		}
		
		
		private var onlineView:Sprite;
		public function set online(value:Boolean):void {
			if (!onlineView) {
				onlineView = new Sprite();
				onlineView.x = newBttn.x - 16;
				onlineView.y = newBttn.y + newBttn.height * 0.5;
				mainLayer.addChild(onlineView);
			}
			
			onlineView.graphics.clear();
			onlineView.graphics.beginFill((value) ? 0x669933 : 0xcc0000);
			onlineView.graphics.drawCircle(0, 0, 6);
			onlineView.graphics.endFill();
			
		}
		
		
		override public function dispose():void {
			if (timeout) {
				clearTimeout(timeout);
				removeEventListener(MouseEvent.ROLL_OVER, onOver);
				container.y = 0;
			}
			
			removeChildren();
		}
		
	}

}

import enixan.components.Button;
import flash.display.Shape;

internal class GridButton extends Button {
	
	public function GridButton(params:Object) {
		
		super(params);
		
	}
	
	override protected function draw():void {
		
		graphics.lineStyle(1, 0xff6600);
		graphics.beginFill(0x333333);
		graphics.moveTo(14, 0);
		graphics.lineTo(0, 8);
		graphics.lineTo(14, 16);
		graphics.lineTo(28, 8);
		graphics.lineTo(14, 0);
		graphics.endFill();
		graphics.moveTo(7, 4);
		graphics.lineTo(21, 12);
		graphics.moveTo(21, 4);
		graphics.lineTo(7, 12);
		
	}
	
}