package wins 
{
	import com.greensock.TweenLite;
	import enixan.Color;
	import enixan.Compiler;
	import enixan.Size;
	import enixan.Util;
	import enixan.components.Button;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	import mx.controls.Alert;
	
	/**
	 * ...
	 * @author 
	 */
	public class SettingsWindow extends wins.Window 
	{
		
		[Embed(source = "../../res/air_logo.png")]
		private var AirClass:Class;
		
		[Embed(source="../../res/java_logo.jpg")]
		private var JavaClass:Class;
		
		[Embed(source="../../res/folder.png")]
		private var FolderClass:Class;
		
		private var customContainer:Sprite;		// Для настроек в стиле переключатель - описание
		private var infoContainer:Sprite;		// Для текстового представления JSON настроек
		
		private var titleLabel:TextField;
		private var infoLabel:TextField;
		private var saveBttn:Button;
		
		private var locale0:String = 'Настройка';
		private var locale1:String = 'AIR SDK не найден';
		private var locale2:String = 'Air SDK';
		private var locale3:String = 'Проверить';
		private var locale4:String = 'Назначить';
		private var locale5:String = 'Загрузить';
		private var locale6:String = 'Java не найден';
		private var locale7:String = 'Java';
		
		public function SettingsWindow(params:Object = null) 
		{
			if (!params) params = { };
			
			params.width = 600;
			params.height = 750;
			
			super(params);
		}
		
		override public function draw():void {
			
			super.draw();
			
			var titleCont:Sprite = new Sprite();
			titleCont.mouseChildren = false;
			titleCont.mouseEnabled = false;
			container.addChild(titleCont);
			
			titleLabel = Util.drawText( {
				text:		locale0,
				size:		42,
				color:		0xffffff
			});
			titleLabel.x = params.width * 0.5 - titleLabel.width * 0.5;
			titleLabel.y = 7;
			titleCont.addChild(titleLabel);
			
			
			createSDKView();
			createJavaView();
			
			
			/*var list:Tree = new Tree(Main.app.appStage, 520, 360);
			list.x = 40;
			list.y = 200;
			container.addChild(list);
			list.init(Main.storage);*/
			
			
			
			// Custom 
			
			customContainer = new Sprite();
			customContainer.y = 190;
			container.addChild(customContainer);
			
			
			
			
			// Info
			
			infoContainer = new Sprite();
			infoContainer.y = 190;
			container.addChild(infoContainer);
			
			infoLabel = Util.drawText( {
				width:		520,
				height:		500,
				multiline:	true,
				wordWrap:	false,
				text:		format(Main.storage),
				size:		13,
				color:		0x111111,
				border:			true,
				borderColor:	0x888888,
				background:		true,
				backgroundColor:0x666666,
				type:			'input'
			});
			infoLabel.x = params.width * 0.5 - infoLabel.width * 0.5;
			infoContainer.addChild(infoLabel);
			
			saveBttn = new Button( {
				width:		140,
				height:		30,
				label:		'Сохранить',
				color1:		0x33ee66,
				color2:		Color.light(0x33ee66, -0x44),
				click:		function():void {
					var temp:Object;
					try {
						temp = JSON.parse(infoLabel.text);
						Main.storage = temp;
						Main.app.saveStorage();
						close();
					}catch (e:Error) {
						infoLabel.borderColor = 0xff8888;
						infoLabel.backgroundColor = 0x660000;
						TweenLite.to(infoLabel, 0.5, { borderColor:0x888888, backgroundColor:0xffffff } );
					}
				}
			});
			saveBttn.x = params.width * 0.5 - saveBttn.width * 0.5;
			saveBttn.y = 515;
			infoContainer.addChild(saveBttn);
			
		}
		
		// Форматирование объекта в спиле читабельного построчного JSON
		private function format(object:Object):String {
			
			const OPEN_TAG:String = '{';
			const OPEN_TAG2:String = '[';
			const CLOSE_TAG:String = '}';
			const CLOSE_TAG2:String = ']';
			const TAB:String = '\t';
			const COMA:String = ',';
			const SLASH:String = '\\';
			const ENTER:String = '\n';
			
			var source:String;
			var string:String = '';
			var indent:int = 0;
			var indentEntity:String = '';
			var currentChar:String;
			var tabUp:Boolean;
			
			try {
				source = JSON.stringify(object);
			}catch (e:Error) { }
			
			var index:uint = source.length;
			for (var i:int = 0; i < index; i++) {
				
				currentChar = source.charAt(i);
				
				if (currentChar == OPEN_TAG || currentChar == OPEN_TAG2) {
					tabUp = true;
					indent ++;
					while (indentEntity.length < indent)
						indentEntity += TAB;
					
				}else if (currentChar == CLOSE_TAG || currentChar == CLOSE_TAG2) {
					indent --;
					indentEntity = '';
					while (indentEntity.length < indent)
						indentEntity += TAB;
					string += ENTER + indentEntity;
				}
				
				string += currentChar;
				
				if (tabUp || currentChar == COMA) {
					tabUp = false;
					string += ENTER + indentEntity;
				}
			}
			
			return string;
			
		}
		
		
		
		// SDK
		protected function createSDKView():void {
			
			var logo:Bitmap = new Bitmap(new AirClass().bitmapData, PixelSnapping.AUTO, true);
			Size.size(logo, 40, 40);
			logo.x = 40;
			logo.y = 80;
			container.addChild(logo);
			
			var shape:Shape = new Shape();
			shape.x = logo.x + logo.width + 12;
			shape.y = logo.y + 10;
			container.addChild(shape);
			
			var text:TextField = Util.drawText( {
				text:		locale2,
				color:		0xffffff
			});
			text.x = logo.x + logo.width + 10;
			text.y = logo.y + logo.height * 0.5 - text.height * 0.5 - 2;
			container.addChild(text);
			
			var path:TextField = Util.drawText( {
				text:		' ',
				width:		250,
				color:		0x333333,
				background:	0xcccccc,
				backgroundColor:	0x333333,
				border:		true//,
				//type:		TextFieldType.INPUT,
				//restrict:	'A-Za-z0-9А-Яа-я .-_'
			});
			path.visible = false;
			path.x = logo.x + logo.width + 10;
			path.y = logo.y + logo.height * 0.5 - path.height * 0.5 - 2;
			container.addChild(path);
			
			var checkBttn:Button = new Button( {
				label:		locale3,
				width:		80,
				height:		30,
				click:		checkAirSdk
			});
			checkBttn.x = 390;
			checkBttn.y = logo.y + 2;
			container.addChild(checkBttn);
			
			var setBttn:Button = new Button( {
				label:		'Назначить',
				width:		80,
				height:		30,
				click:		setAirSdk
			});
			setBttn.x = checkBttn.x + checkBttn.width + 6;
			setBttn.y = checkBttn.y;
			container.addChild(setBttn);
			
			var downloadBttn:Button = new Button( {
				label:		'Загрузить',
				width:		80,
				height:		30,
				click:		downloadAirSdk,
				color:		0x99aaff
			});
			downloadBttn.visible = false;
			downloadBttn.toolTip = 'Загрузка и установка AIR SDK';
			downloadBttn.x = checkBttn.x;
			downloadBttn.y = checkBttn.y;
			container.addChild(downloadBttn);
			
			var checkFolder:Button = new Button( {
				bmd:		new FolderClass().bitmapData,
				click:		onCheckFolder
			});
			checkFolder.visible = false;
			checkFolder.toolTip = 'Выбор папки с AIR SDK';
			checkFolder.x = checkBttn.x - 6 - checkFolder.width;
			checkFolder.y = checkBttn.y;
			container.addChild(checkFolder);
			
			// Проверить наличие файлов AIR SDK
			function checkAirSdk():void {
				if (!Compiler.testSDK(Compiler.sdk, false)) {
					airSdkFail();
				}else {
					airSdkSuccess();
				}
			}
			
			// AIR SDK файлы не найдены
			function airSdkFail():void {
				
				text.textColor = 0xCC0000;
				TweenLite.to(text, 0.2, { x:logo.x + logo.width + 36 } );
				
				shape.graphics.clear();
				shape.graphics.lineStyle(2, 0xCC0000);
				shape.graphics.drawCircle(8, 8, 8);
				shape.graphics.moveTo(3, 3);
				shape.graphics.lineTo(13, 13);
				
			}
			
			// AIR SDK файлы найдены
			function airSdkSuccess():void {
				
				text.text = 'Air SDK';
				text.textColor = 0x00CC00;
				
				TweenLite.to(text, 0.2, { x:logo.x + logo.width + 36 } );
				
				shape.graphics.clear();
				shape.graphics.lineStyle(2, 0x00CC00);
				shape.graphics.moveTo(0, 12);
				shape.graphics.lineTo(4, 16);
				shape.graphics.lineTo(16, 4);
				
				if (Compiler.sdk && Compiler.sdk.exists && Compiler.sdk.resolvePath('air-sdk-description.xml').exists) {
					var data:String = Files.openText(Compiler.sdk.resolvePath('air-sdk-description.xml'));
					var values:Array = data.match(/\<version\>[0-9\. ]+\<\/version\>/g);
					if (values && values[0]) {
						text.appendText(' ' + values[0].replace(/[^0-9.]+/g, ''));
						text.width = text.textWidth + 4;
					}
				}
			}
			
			// 
			function setAirSdk():void {
				
				shape.graphics.clear();
				
				text.x = logo.x + logo.width + 12;
				text.text = 'Air SDK';
				text.textColor = 0xffffff;
				
				shape.visible = path.visible;
				text.visible = path.visible;
				checkBttn.visible = path.visible;
				downloadBttn.visible = !path.visible;
				checkFolder.visible = !path.visible;
				path.visible = !path.visible;
				
				setBttn.label = (path.visible) ? 'Назад' : 'Назначить';
				
				if (Compiler.sdk) {
					path.text = Compiler.sdk.nativePath;
					downloadBttn.state = Button.DISABLE;
				}else {
					path.text = locale1;
					downloadBttn.state = Button.NORMAL;
				}
				
				path.scrollH = path.maxScrollH;
			}
			
			// Выбрать папку с AIR SDK
			var file:File;
			function onCheckFolder():void {
				
				file = new File((Compiler.sdk) ? Compiler.sdk.nativePath : null);
				file.addEventListener(Event.SELECT, onCheckFolderSelect);
				file.addEventListener(Event.CANCEL, onCheckFolderCancel);
				file.browseForDirectory('Путь для AIR SDK');
				
			}
			function onCheckFolderSelect(e:Event):void {
				onCheckFolderCancel();
				
				if (!Compiler.testSDK(file)) return;
				
				path.text = Compiler.sdk.nativePath;
				path.scrollH = path.maxScrollH;
				
				Main.app.saveStorage(1000);
				
			}
			function onCheckFolderCancel(e:Event = null):void {
				file.removeEventListener(Event.SELECT, onCheckFolderSelect);
				file.removeEventListener(Event.CANCEL, onCheckFolderCancel);
			}
			
			// 
			function downloadAirSdk():void {
				if (Compiler.testSDK(Compiler.sdk)) {
					Alert.show('AIR SDK уже доступно!', Main.appName);
				}else{
					downloadBttn.state = Button.DISABLE;
					Compiler.setupSDK();
					Alert.show('Дожитесь установки AIR SDK!', Main.appName);
				}
			}
		}
		
		// Java
		protected function createJavaView():void {
			
			var logo:Bitmap = new Bitmap(new JavaClass().bitmapData, PixelSnapping.AUTO, true);
			Size.size(logo, 40, 40);
			logo.x = 40;
			logo.y = 130;
			container.addChild(logo);
			
			var shape:Shape = new Shape();
			shape.x = logo.x + logo.width + 12;
			shape.y = logo.y + 10;
			container.addChild(shape);
			
			var text:TextField = Util.drawText( {
				text:		locale7,
				color:		0xffffff
			});
			text.x = logo.x + logo.width + 10;
			text.y = logo.y + logo.height * 0.5 - text.height * 0.5 - 2;
			container.addChild(text);
			
			var path:TextField = Util.drawText( {
				text:		' ',
				width:		250,
				color:		0x333333,
				background:	0xcccccc,
				backgroundColor:	0x333333,
				border:		true//,
				//type:		TextFieldType.INPUT,
				//restrict:	'A-Za-z0-9А-Яа-я .-_'
			});
			path.visible = false;
			path.x = logo.x + logo.width + 10;
			path.y = logo.y + logo.height * 0.5 - path.height * 0.5 - 2;
			container.addChild(path);
			
			var checkBttn:Button = new Button( {
				label:		locale3,
				width:		80,
				height:		30,
				click:		checkJava
			});
			checkBttn.x = 390;
			checkBttn.y = logo.y + 2;
			container.addChild(checkBttn);
			
			var setBttn:Button = new Button( {
				label:		locale4,
				width:		80,
				height:		30,
				click:		setJava
			});
			setBttn.x = checkBttn.x + checkBttn.width + 6;
			setBttn.y = checkBttn.y;
			container.addChild(setBttn);
			
			var downloadBttn:Button = new Button( {
				label:		locale5,
				width:		80,
				height:		30,
				click:		downloadJava,
				color:		0x99aaff
			});
			downloadBttn.visible = false;
			downloadBttn.toolTip = 'Загрузка и установка Java';
			downloadBttn.x = checkBttn.x;
			downloadBttn.y = checkBttn.y;
			container.addChild(downloadBttn);
			
			/*var checkFolder:Button = new Button( {
				bmd:		new FolderClass().bitmapData,
				click:		onCheckFolder
			});
			checkFolder.visible = false;
			checkFolder.toolTip = 'Выбор папки с Java';
			checkFolder.x = checkBttn.x - 6 - checkFolder.width;
			checkFolder.y = checkBttn.y;
			container.addChild(checkFolder);*/
			
			// Проверить наличие файлов Java
			function checkJava():void {
				if (!Compiler.testJava(Compiler.java, false)) {
					javaFail();
				}else {
					javaSuccess();
				}
			}
			
			// Java файлы не найдены
			function javaFail():void {
				
				text.textColor = 0xCC0000;
				TweenLite.to(text, 0.2, { x:logo.x + logo.width + 36 } );
				
				shape.graphics.clear();
				shape.graphics.lineStyle(2, 0xCC0000);
				shape.graphics.drawCircle(8, 8, 8);
				shape.graphics.moveTo(3, 3);
				shape.graphics.lineTo(13, 13);
				
			}
			
			// Java файлы найдены
			function javaSuccess():void {
				
				text.text = 'Java';
				text.textColor = 0x00CC00;
				
				TweenLite.to(text, 0.2, { x:logo.x + logo.width + 36 } );
				
				shape.graphics.clear();
				shape.graphics.lineStyle(2, 0x00CC00);
				shape.graphics.moveTo(0, 12);
				shape.graphics.lineTo(4, 16);
				shape.graphics.lineTo(16, 4);
				
				if (Compiler.java && Compiler.java.exists && Compiler.java.parent.parent.resolvePath('release').exists) {
					var data:String = Files.openText(Compiler.java.parent.parent.resolvePath('release'));
					var values:Array = data.match(/JAVA_VERSION=\"[0-9._]\"/);
					if (values && values[0]) {
						text.appendText(' ' + values[0].replace(/[^0-9._]+/g, ''));
						text.width = text.textWidth + 4;
					}
				}
			}
			
			// 
			function setJava():void {
				
				shape.graphics.clear();
				
				text.x = logo.x + logo.width + 12;
				text.text = 'Java';
				text.textColor = 0xffffff;
				
				shape.visible = path.visible;
				text.visible = path.visible;
				checkBttn.visible = path.visible;
				downloadBttn.visible = !path.visible;
				//checkFolder.visible = !path.visible;
				path.visible = !path.visible;
				
				setBttn.label = (path.visible) ? 'Назад' : 'Назначить';
				
				if (Compiler.java) {
					path.text = Compiler.java.nativePath;
					downloadBttn.state = Button.DISABLE;
				}else {
					path.text = locale6;
					downloadBttn.state = Button.NORMAL;
				}
				
				path.scrollH = path.maxScrollH;
			}
			
			// Выбрать папку с Java
			/*var file:File;
			function onCheckFolder():void {
				
				file = new File((Compiler.java) ? Compiler.java.nativePath : null);
				file.addEventListener(Event.SELECT, onCheckFolderSelect);
				file.addEventListener(Event.CANCEL, onCheckFolderCancel);
				file.browseForDirectory('Путь для Java');
				
			}
			function onCheckFolderSelect(e:Event):void {
				onCheckFolderCancel();
				
				if (!Compiler.testJava(file)) return;
				
				path.text = Compiler.java.nativePath;
				path.scrollH = path.maxScrollH;
				
				Main.app.saveStorage(1000);
				
			}
			function onCheckFolderCancel(e:Event = null):void {
				file.removeEventListener(Event.SELECT, onCheckFolderSelect);
				file.removeEventListener(Event.CANCEL, onCheckFolderCancel);
			}*/
			
			// 
			function downloadJava():void {
				if (Compiler.testJava(Compiler.java)) {
					Alert.show('Java уже доступно!', Main.appName);
				}else {
					downloadBttn.state = Button.DISABLE;
					Compiler.setupJava();
					Alert.show('Дожитесь установки Java!', Main.appName);
				}
			}
			
		}
	}
}

import enixan.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import wins.Window;

internal class Tree extends Sprite 
{
	public static const WIDTH:uint = 300;
	public static const HEIGHT:uint = 18;
	
	public static var plus:BitmapData;
	public static var minus:BitmapData;
	public static var hand:BitmapData;
	
	public var params:Object = { };
	
	public var source:Object;//Оригинальные данные
	public var data:Array;//Данные древа
	public var activeList:Array;
	public var currWidth:int = 0;
	public var currHeight:int = 0;
	public var currStage:Stage;
	
	private var container:Sprite;
	private var scroller:Sprite;
	private var maska:Shape;
	private var focusedIndex:int = 0;
	private var focusedCount:int = 0;
	private var updateTimeout:int;
	private var __moving:Boolean = false;
	
	public function Tree(stage:Stage, width:int, height:int, params:Object = null) 
	{
		if (params) {
			for (var s:* in params) 
				this.params[s] = params[s];
		}
		
		currWidth = width;
		currHeight = height;
		currStage = stage;
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_MOVE, onMove);
		addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
	}
	
	public function init(data:Object = null):void 
	{
		if (!Tree.plus) 
		{
			var plus:BitmapData = new BitmapData(11, 11, true, 0xffffffff);
			plus.fillRect(new Rectangle(1, 1, 9, 9), 0x00ffffff);
			plus.fillRect(new Rectangle(5, 3, 1, 5), 0xffffffff);
			plus.fillRect(new Rectangle(3, 5, 5, 1), 0xffffffff);
			
			Tree.plus = plus;
		}
		
		if (!Tree.minus) 
		{
			var minus:BitmapData = new BitmapData(11, 11, true, 0xffffffff);
			minus.fillRect(new Rectangle(1, 1, 9, 9), 0x00ffffff);
			minus.fillRect(new Rectangle(3, 5, 5, 1), 0xffffffff);
			
			Tree.minus = minus;
		}
		
		if (!Tree.hand) 
		{
			var hand:BitmapData = new BitmapData(11, 11, true, 0x00ffffff);
			hand.fillRect(new Rectangle(5, 5, 6, 1), 0xffffffff);
			hand.fillRect(new Rectangle(5, 0, 1, 6), 0xffffffff);
			
			Tree.hand = hand;
		}
		
		clear();
		
		if (!this.data) this.data = [];
		if (!data) data = { };
		if (!activeList) activeList = [];
		
		this.data = parse(this.data, data);
		
		redraw();
	}
	
	private function parse(result:Array, object:Object, key:* = null, level:int = 0):* 
	{
		for (var s:* in object) 
		{
			var child:Object = {
				value:	[],
				key:	s,
				open:	(!key) ? true : false,
				level:	level,
				find:	false//Поисковый регистр
			};
			
			child.value = (typeof(object[s]) == 'object') ? parse(child.value, object[s], s, level + 1) : object[s];
			result.push(child);
		}
		
		return result;
	}
	
	public function find(value:*):void 
	{
		function findInBranch(value:*, list:Array):Boolean {
			var finded:Boolean = false;
			
			for (var i:int = 0; i < list.length; i++ ) 
			{
				list[i].find = false;
				
				if (list[i].value is Array && findInBranch(value, list[i].value)) 
				{
					list[i].find = true;
					finded = true;
				}else if (String(list[i].key).indexOf(value) != -1 || (!(list[i].value is Array) && String(list[i].value).indexOf(value) != -1)) 
				{
					list[i].find = true;
					finded = true;
				}
			}
			
			return finded;
		}
		
		findInBranch(value, data);
		
		focusReset();
		focusOnNext();
	}
	
	// Фокусировка и перефокусировка по пунктам списка
	public function focusOnNext():void 
	{
		var index:int = focusedIndex;
		var finded:Boolean = false;
		
		focusedIndex ++;
		focusedCount = 0;
		
		for (var i:int = 0; i < activeList.length; i++) 
		{
			if (activeList[i].find) 
			{
				focusedCount ++;
				
				if (index == 0) 
				{
					container.y = -HEIGHT * i + int(currHeight * 0.5);
					normalizeContainer();
					update();
				}
				
				index --;
			}
		}
		
		if (focusedCount > 0 && index > 0) 
		{
			focusReset();
			focusOnNext();
		}
	}
	
	private function focusReset():void 
	{
		focusedIndex = 0;
		focusedCount = 0;
	}	
	
	public function redraw():void 
	{		
		function parseBranch(object:Object):void {
			if (object is Array) 
			{
				if (object.length > 0 && object[0].key is Number) 
				{
					object.sortOn('key', Array.NUMERIC);
				}else{
					object.sortOn('key');
				}
			}
			
			for (var s:* in object) 
			{
				if (object[s].open) 
				{
					activeList.push(object[s]);
					
					if (object[s].value is Array)
						parseBranch(object[s].value);
				}
			}
		}
		
		activeList.length = 0;
		
		parseBranch(data);
		update();
		drawMask();
		
		normalizeContainer();
		createScroller();
	}
	
	private function drawMask():void 
	{
		if (!maska) 
		{
			maska = new Shape();
			addChild(maska);
		}
		
		maska.graphics.clear();
		maska.graphics.beginFill(0xff0000, 1);
		maska.graphics.drawRect(0, 0, currWidth, currHeight);
		maska.graphics.endFill();
		
		container.mask = maska;
	}
	
	public function update():void 
	{
		if (!container) 
		{
			container = new Sprite();
			addChild(container);
		}else {
			container.removeChildren();
		}
		
		var from:int = -container.y / HEIGHT - currHeight / HEIGHT;
		var to:int = from + 3 * currHeight / HEIGHT;
		
		for (var i:int = from; i < to; i++) 
		{
			if (!activeList[i]) continue;
			
			var object:Object = {
				width:		currWidth
			}
			
			for (var s:* in activeList[i]) {
				object[s] = activeList[i][s];
			}
			
			var treeItem:TreeItem = new TreeItem(activeList[i]);
			treeItem.x = 20 * activeList[i].level;
			treeItem.y = HEIGHT * i;
			container.addChild(treeItem);
		}
	}
	
	private function normalizeContainer():void 
	{
		if (container.y > 0) 
		{
			container.y = 0;
		}else if (container.y < -activeList.length * HEIGHT + currHeight) {
			container.y = -activeList.length * HEIGHT + currHeight;
		}
	}
	
	private function createScroller():void 
	{
		if (!scroller) 
		{
			scroller = new Sprite();
			addChild(scroller);
			
			currStage.addEventListener(MouseEvent.MOUSE_DOWN, onScrollerDown);
			currStage.addEventListener(MouseEvent.MOUSE_UP, onScrollerUp);
		}
		
		if (HEIGHT * activeList.length < currHeight) 
		{
			scroller.visible = false;
			return;
		}
		
		var scrollHeight:int = currHeight * currHeight / (HEIGHT * activeList.length);
		if (scrollHeight < 30) scrollHeight = 30;
		
		scroller.visible = true;
		scroller.graphics.clear();
		scroller.graphics.beginFill(0xffffff, 1);
		scroller.graphics.drawRect(0, 0, 6, scrollHeight);
		scroller.graphics.endFill();
		
		scroller.x = currWidth;
		scroller.y = -container.y * (currHeight - scroller.height) / (HEIGHT * activeList.length - currHeight);
		
		function onScrollerDown(e:MouseEvent):void {
			var clickedOnScroller:Boolean = false;
			var list:Array = currStage.getObjectsUnderPoint(new Point(currStage.mouseX, currStage.mouseY));
			
			for (var i:int = 0; i < list.length; i++) 
			{
				if (list[i] == scroller) 
				{
					clickedOnScroller = true;
				}
			}
			
			if (!clickedOnScroller) return;
			
			if (!moving) 
			{
				moving = true;
				scroller.startDrag(false, new Rectangle(scroller.x, 0, 0, currHeight - scroller.height));
			}
			
		}
		
		function onScrollerUp(e:MouseEvent):void {
			scroller.stopDrag();
			moving = false;
		}
		
	}
	
	private function onScrollerMove(e:Event):void 
	{
		container.y = -scroller.y * (HEIGHT * activeList.length - currHeight) / (currHeight - scroller.height);
		update();
	}
	
	public function set moving(value:Boolean):void 
	{
		if (__moving == value) return;
		
		__moving = value;
		
		if (__moving) 
		{
			currStage.addEventListener(Event.ENTER_FRAME, onScrollerMove);
		}else {
			currStage.removeEventListener(Event.ENTER_FRAME, onScrollerMove);
		}
	}
	
	public function get moving():Boolean 
	{
		return __moving;
	}
	
	private function onWheel(e:MouseEvent):void 
	{
		container.y += (e.delta > 0) ? currHeight * 0.75 : -currHeight * 0.75;
		
		normalizeContainer();
		
		scroller.y = -container.y * (currHeight - scroller.height) / (HEIGHT * activeList.length - currHeight);
		
		if (updateTimeout > 0) clearTimeout(updateTimeout);
		updateTimeout = setTimeout(function():void {
			updateTimeout = 0;
			update();
		}, 100);
	}
	
	private function onMove(e:MouseEvent):void 
	{
		if (container.mouseX > WIDTH) return;
		
		var pos:int = int(container.mouseY / HEIGHT);
		
		container.graphics.clear();
		container.graphics.beginFill(0x000000, 0.4);
		container.graphics.drawRect(0, pos * HEIGHT, currWidth, HEIGHT);
		container.graphics.endFill();
		
	}
	
	private function onClick(e:MouseEvent):void 
	{
		var pos:int = int(container.mouseY / HEIGHT);
		
		if (pos >= 0 && activeList.length > pos && container.mouseX < WIDTH) 
		{
			if (activeList[pos].value is Array) 
			{
				// Определение ветвей древа
				var link:Array = [activeList[pos].key];
				var level:int = activeList[pos].level;
				
				for (var i:int = pos; i > -1; i--) 
				{
					if (activeList[i].level < level) 
					{
						level = activeList[i].level;
						link.unshift(activeList[i].key);
					}
					
					if (level <= 0) break;
				}
				
				// Открытие/закрытие ветви древа
				var array:Array = (activeList[pos].value as Array);
				
				for (i = 0; i < array.length; i++) 
				{
					array[i].open = !array[i].open;
				}
				
				redraw();
				
				//Admin.branch(link);
			}
		}
	}
	
	public function clear():void 
	{
		if (container) 
		{
			container.removeChildren();
			container = null;
		}
		
		if (maska) 
		{
			maska.graphics.clear();
			maska = null;
		}
		
		source = null;
		data = null;
		activeList = null;
	}
	
	public function dispose():void 
	{
		clear();
		
		if (parent)
			parent.removeChild(this);
	}
}

internal class TreeItem extends Sprite 
{
	private var object:Object;
	
	public function TreeItem(object:Object) 
	{
		this.object = object;
		
		if (isObject) 
		{
			var bitmap:Bitmap = new Bitmap();
			bitmap.x = 3;
			bitmap.y = 3;
			addChild(bitmap);
			
			if (object.value is Array && object.value.length > 0 && object.value[0].open) 
			{
				bitmap.bitmapData = Tree.minus;
			}else {
				bitmap.bitmapData = Tree.plus;
			}
		}
		
		if (object.find) 
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xff0000, 0.4);
			shape.graphics.drawRect(0, 0, object.width, Tree.HEIGHT);
			shape.graphics.endFill();
			addChild(shape);
		}
		
		var text:TextField = new TextField();
		
		text.x = 16;
		text.width = Tree.WIDTH;
		text.height = 20;
		text.selectable = object.selectable;
		text.defaultTextFormat = new TextFormat('arial', 11, 0xdddddd);
		text.text = value;
		
		addChild(text);
	}
	
	private function get isObject():Boolean 
	{
		if (object.value is Number || object.value is String || object is Boolean)
			return false;
		
		return true;
	}
	
	private function get value():String 
	{
		if (!isObject)
			return String(object.key) + ': ' + String(object.value);
		
		return String(object.key);
	}
}