package wins 
{
	import adobe.utils.CustomActions;
	import enixan.Compiler;
	import enixan.Util;
	import enixan.components.Button;
	import enixan.components.CheckBox;
	import enixan.components.DropList;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filesystem.File;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	import mx.controls.Alert;
	import mx.controls.textClasses.TextRange;
	import wins.Window;
	
	public class PreviewWindow extends Window 
	{
		
		[Embed(source="../../res/folder.png")]
		private var FolderIcon:Class;
		private var folderBMD:BitmapData = new FolderIcon().bitmapData;
		
		public static var animate:Boolean = true;
		public static var Stage:int = -1;
		public static var Anim:String = '';
		public static var window:PreviewWindow;
		public static var instance:PreviewWindow;
		public static var bitmapData:BitmapData = new BitmapData(100, 100, true, 0x0);;
		
		public var previewitem:PreviewItem;
		
		public function PreviewWindow(params:Object = null)
		{
			
			window = this;
			if (!params) params = { };
			
			params.width = 1000;
			params.height = 740;
			params.itemWidth = 500;
			params.itemHeight = 450;
			
			super(params);
			
			PreviewWindow.instance = this;
		}
		
		override public function draw():void {
			super.draw();
			
			drawCreateProject();
			
			previewitem = new PreviewItem({ width:params.itemWidth, height:params.itemHeight }, getInfo);
			previewitem.x = params.width / 2 - 50;
			previewitem.y = projectContainer.y + 30;
			container.addChild(previewitem);
			
			var titleCont:Sprite = new Sprite();
			titleCont.mouseChildren = false;
			titleCont.mouseEnabled = false;
			container.addChild(titleCont);
			
			titleLabel = Util.drawText( {
				text:		'Сборка',
				size:		42,
				color:		0xffffff
			});
			titleLabel.x = params.width * 0.5 - titleLabel.width * 0.5;
			titleLabel.y = 7;
			titleCont.addChild(titleLabel);
			
			if (Main.app.swfContent)
				previewitem.onLoad(Main.app.swfContent);
			
			
		}
		
		
		/**
		 * Тип сборки SWF или JSON
		 */
		private var __type:String = Main.SWF;
		public function get type():String {
			return __type;
		}
		public function set type(value:String):void {
			__type = value;
			
			MessageView.message(__type);
		}
		
		
		
		/**
		 * Загрузка на сервер
		 */
		public static function get upload():Boolean {
			return (instance && instance.getActionChecked(7));
		}
		
		
		public function update():void {
			buttonsState();
		}
		
		public function getInfo(data:Object):void {
			if(data.bitmapData)
				bitmapData = data.bitmapData;
		}
		
		/**
		 * Добавление функции обратного вызова на событие EnterFrame
		 * @param	callback	функция обратного вызова
		 */
		public function setOnEnterFrame(callback:Function):void {
			addEventListener(Event.ENTER_FRAME, callback);
		}
		
		/**
		 * Удаление функции обратного вызова с события EnterFrame
		 * @param	callback	функция обратного вызова
		 */
		public function setOffEnterFrame(callback:Function):void {
			removeEventListener(Event.ENTER_FRAME, callback);
		}
		
		private var projectContainer:Sprite;
		private var projectViewContainer:Sprite;
		private var dropViewContainer:Sprite;
		private var ccContainer:Sprite;
		private var iconContainer:Sprite;
		private var titleSWFLabel:TextField;
		private var pathSWFLabel:TextField;
		private var browseSWFBttn:Button;
		private var titleLabel:TextField;
		private var titleProjLabel:TextField;
		private var pathProjLabel:TextField;
		private var browseProjBttn:Button;
		private var titleNameLabel:TextField;
		private var nameLabel:TextField;
		private var logLabel:TextField;
		private var projectBttn:Button;
		private var projectCancelBttn:Button;
		private var systemBrowserBttn:Button;
		private var systemBrowserProjBttn:Button;
		private var tempFolderBttn:Button;
		private var serverFolderBttn:Button;
		private var cc1:CheckBox;
		private var cc2:CheckBox;
		private var cc3:CheckBox;
		private var cc4:CheckBox;
		private var cc5:CheckBox;
		private var colorCorrectionBox:CheckBox;
		private var animationBox:CheckBox;
		
		private var iconBox:CheckBox;
		private var titleIconWidthLabel:TextField;
		private var titleIconHeightLabel:TextField;
		private var iconWidthLabel:TextField;
		private var iconHeightLabel:TextField;
		
		private var titleServerLabel:TextField;
		public var serverBox:CheckBox;
		
		public var projectDropTitle:TextField;
		public var viewDropTitle:TextField;
		public var projectDrop:DropList;
		public var viewDrop:DropList;
		
		private function drawCreateProject():void {
			
			Main.app.addEventListener('compileStart', onCompileStart);
			Main.app.addEventListener('compileComplete', onCompileComplete);
			
			projectContainer = new Sprite();
			projectContainer.x = 30;
			projectContainer.y = 60;
			container.addChild(projectContainer);
			
			
			dropViewContainer = new Sprite();
			dropViewContainer.y = 0;
			
			
			// Папка сохранения
			titleProjLabel = Util.drawText( {
				textAlign:	TextFormatAlign.LEFT,
				text:		'Проект (если путь будет не найден, сохранится во временную папку)',
				color:		0xffffff,
				size:		12,
				width:		305
			});
			titleProjLabel.x = 6;
			titleProjLabel.y = 0;
			projectContainer.addChild(titleProjLabel);
			
			var newTextFormat:TextFormat = titleProjLabel.getTextFormat(0, 1);
			newTextFormat.size = 9;
			titleProjLabel.setTextFormat(newTextFormat,7,titleProjLabel.length);
			
			pathProjLabel = Util.drawText( {
				text:			Main.storage.projPath,
				color:			0x111111,
				size:			16,
				width:			320,
				border:			true,
				borderColor:	0x999999,
				background:		true,
				backgroundColor:0xeeeeee,
				type:			TextFieldType.INPUT,
				embedFonts:		false
			});
			pathProjLabel.x = 0;// titleProjLabel.x + titleProjLabel.width;
			pathProjLabel.y = titleProjLabel.y + titleProjLabel.height + 2;
			projectContainer.addChild(pathProjLabel);
			pathProjLabel.scrollH = pathProjLabel.maxScrollH;
			pathProjLabel.tabEnabled = true;
			pathProjLabel.tabIndex = 1;
			//pathProjLabel.addEventListener(TextEvent.TEXT_INPUT, onProjInput);
			//pathProjLabel.addEventListener(FocusEvent.FOCUS_OUT, onPathProjFocusOut);
			pathProjLabel.addEventListener(FocusEvent.FOCUS_IN, onPathProjFocusIn);
			
			browseProjBttn = new Button( {
				bmd:		folderBMD,
				click:		onBrowseProject
			});
			browseProjBttn.scaleX = browseProjBttn.scaleY = 0.8;
			browseProjBttn.x = pathProjLabel.x + pathProjLabel.width + 6;
			browseProjBttn.y = pathProjLabel.y;
			projectContainer.addChild(browseProjBttn);
			
			systemBrowserProjBttn = new Button( {
				bmd:		folderBMD,
				click:		function():void {
					var folder:File = new File(pathProjLabel.text);
					if (folder.exists && folder.isDirectory)
						folder.openWithDefaultApplication();
				}
			});
			systemBrowserProjBttn.scaleX = systemBrowserProjBttn.scaleY = 0.8;
			systemBrowserProjBttn.x = browseProjBttn.x + browseProjBttn.width + 6;
			systemBrowserProjBttn.y = browseProjBttn.y;
			systemBrowserProjBttn.transform.colorTransform = new ColorTransform(1, .8, .3);
			projectContainer.addChild(systemBrowserProjBttn);
			
			tempFolderBttn = new Button( {
				bmd:		folderBMD,
				click:		function():void {
					var folder:File = Main.autoFolder;
					if (folder.exists && folder.isDirectory)
						folder.openWithDefaultApplication();
				}
			});
			tempFolderBttn.scaleX = tempFolderBttn.scaleY = 0.4;
			tempFolderBttn.x = titleProjLabel.x + titleProjLabel.width + 8;
			tempFolderBttn.y = titleProjLabel.y + 5;
			projectContainer.addChild(tempFolderBttn);
			
			
			
			
			// Server
			serverBox = new CheckBox( {
				width:		16,
				height:		16,
				checked:	Main.autoSave,
				onChange:	onActionStep,
				text:		'Сохранить на сервер',
				textParams:	{
					size:	20
				}
			});
			serverBox.x = 0;
			serverBox.y = pathProjLabel.y + pathProjLabel.height + 16;
			projectContainer.addChild(serverBox);
			
			serverFolderBttn = new Button( {
				bmd:		folderBMD,
				click:		function():void {
					close();
					new ServerContentWindow().show();
				}
			});
			serverFolderBttn.scaleX = serverFolderBttn.scaleY = 0.5;
			serverFolderBttn.x = serverBox.x + serverBox.width + 4;
			serverFolderBttn.y = serverBox.y + 5;
			projectContainer.addChild(serverFolderBttn);
			
			
			
			
			// Выбор проекта
			projectDropTitle = Util.drawText( {
				textAlign:	TextFormatAlign.RIGHT,
				rightMargin:4,
				text:		'Проект',
				color:		0xffffff,
				size:		12,
				width:		48
			});
			projectDropTitle.x = 0;
			projectDropTitle.y = serverBox.y + serverBox.height + 3;
			dropViewContainer.addChild(projectDropTitle);
			
			projectDrop = new DropList(Main.app.appStage, {
				text:				ProjectManager.project,
				focusInHandler:		function():void {
					projectDrop.createList();
					projectDrop.selectAll();
				},
				focusOutHandler:	function():void {
					ProjectManager.project = projectDrop.text;
					
					// Обновление списка папок в листе видов (viewDrop)
					ProjectManager.getViewByProject(ProjectManager.project, function(list:Array):void {
						if (!viewDrop) return;
						viewDrop.updateList(list, true);
					});
				}
			});
			projectDrop.x = projectDropTitle.x + projectDropTitle.width;
			projectDrop.y = projectDropTitle.y - 4;
			projectDrop.updateList(ProjectManager.serverProjects);
			dropViewContainer.addChild(projectDrop);
			
			
			viewDropTitle = Util.drawText( {
				textAlign:	TextFormatAlign.RIGHT,
				rightMargin:4,
				text:		'Тип',
				color:		0xffffff,
				size:		12,
				width:		48
			});
			viewDropTitle.x = projectDrop.x + projectDrop.width + 12;
			viewDropTitle.y = projectDropTitle.y;
			dropViewContainer.addChild(viewDropTitle);
			
			viewDrop = new DropList(Main.app.appStage, {
				text:				ProjectManager.view,
				focusInHandler:		function():void {
					ProjectManager.getViewByProject(ProjectManager.project, function(list:Array):void {
						viewDrop.updateList(list);
						viewDrop.createList();
					});
					viewDrop.selectAll();
				},
				focusOutHandler:	function():void {
					ProjectManager.view = viewDrop.text;
				}
			});
			viewDrop.x = viewDropTitle.x + viewDropTitle.width;
			viewDrop.y = projectDrop.y;
			dropViewContainer.addChild(viewDrop);
			
			
			
			// SWF
			/*projectViewContainer = new Sprite();
			projectViewContainer.x = -10;
			projectViewContainer.y = 0;
			
			titleSWFLabel = Util.drawText( {
				textAlign:	TextFormatAlign.RIGHT,
				rightMargin:4,
				text:		'SWF',
				color:		0xffffff,
				size:		12,
				width:		48
			});
			titleSWFLabel.x = 0;
			titleSWFLabel.y = 0;
			projectViewContainer.addChild(titleSWFLabel);
			
			pathSWFLabel = Util.drawText( {
				text:		Main.storage.swfPath,
				color:		0x111111,
				size:		16,
				width:		280,
				border:		true,
				borderColor:	0x999999,
				background:	true,
				backgroundColor:0xeeeeee,
				type:		TextFieldType.INPUT,
				embedFonts:		false
			});
			pathSWFLabel.x = titleSWFLabel.x + titleSWFLabel.width;
			pathSWFLabel.y = titleSWFLabel.y - 2;
			projectViewContainer.addChild(pathSWFLabel);
			pathSWFLabel.scrollH = pathSWFLabel.maxScrollH;
			pathSWFLabel.tabEnabled = true;
			pathSWFLabel.tabIndex = 0;
			pathSWFLabel.addEventListener(TextEvent.TEXT_INPUT, onSWFInput);
			pathSWFLabel.addEventListener(FocusEvent.FOCUS_OUT, onPathSWFFocusOut);
			
			browseSWFBttn = new Button( {
				bmd:		folderBMD,
				click:		onBrowseSWF
			});
			browseSWFBttn.x = pathSWFLabel.x + pathSWFLabel.width + 6;
			browseSWFBttn.y = titleSWFLabel.y - 4;
			projectViewContainer.addChild(browseSWFBttn);
			
			systemBrowserBttn = new Button( {
				bmd:		folderBMD,
				click:		function():void {
					var folder:File = new File(pathSWFLabel.text);
					if (folder.exists && folder.isDirectory)
						folder.openWithDefaultApplication();
				}
			});
			systemBrowserBttn.x = browseSWFBttn.x + browseSWFBttn.width + 6;
			systemBrowserBttn.y = browseSWFBttn.y;
			systemBrowserBttn.transform.colorTransform = new ColorTransform(1, .8, .3);
			projectViewContainer.addChild(systemBrowserBttn);*/
			
			
			
			// Project
			/*titleProjLabel = Util.drawText( {
				textAlign:	TextFormatAlign.RIGHT,
				rightMargin:4,
				text:		'Project',
				color:		0xffffff,
				size:		12,
				width:		48
			});
			titleProjLabel.x = 0;
			titleProjLabel.y = titleSWFLabel.y + titleSWFLabel.height + 16;
			projectViewContainer.addChild(titleProjLabel);
			
			pathProjLabel = Util.drawText( {
				text:			Main.storage.projPath,
				color:			0x111111,
				size:			16,
				width:			pathSWFLabel.width,
				border:			true,
				borderColor:	0x999999,
				background:		true,
				backgroundColor:0xeeeeee,
				type:			TextFieldType.INPUT,
				embedFonts:		false
			});
			pathProjLabel.x = titleProjLabel.x + titleProjLabel.width;
			pathProjLabel.y = titleProjLabel.y - 2;
			projectViewContainer.addChild(pathProjLabel);
			pathProjLabel.scrollH = pathProjLabel.maxScrollH;
			pathProjLabel.tabEnabled = true;
			pathProjLabel.tabIndex = 1;
			pathProjLabel.addEventListener(TextEvent.TEXT_INPUT, onProjInput);
			pathProjLabel.addEventListener(FocusEvent.FOCUS_OUT, onPathProjFocusOut);
			
			browseProjBttn = new Button( {
				bmd:		folderBMD,
				click:		onBrowseProject
			});
			browseProjBttn.x = pathProjLabel.x + pathProjLabel.width + 6;
			browseProjBttn.y = titleProjLabel.y - 4;
			projectViewContainer.addChild(browseProjBttn);
			
			systemBrowserProjBttn = new Button( {
				bmd:		folderBMD,
				click:		function():void {
					var folder:File = new File(pathProjLabel.text);
					if (folder.exists && folder.isDirectory)
						folder.openWithDefaultApplication();
				}
			});
			systemBrowserProjBttn.x = browseProjBttn.x + browseProjBttn.width + 6;
			systemBrowserProjBttn.y = browseProjBttn.y;
			systemBrowserProjBttn.transform.colorTransform = new ColorTransform(1, .8, .3);
			projectViewContainer.addChild(systemBrowserProjBttn);*/
			
			
			
			// NAME
			titleNameLabel = Util.drawText( {
				text:		'Имя проекта:',
				color:		0xffffff,
				size:		14,
				width:		100
			});
			titleNameLabel.x = 0;
			titleNameLabel.y = serverBox.y + 60;// titleProjLabel.y + titleProjLabel.height + 20;
			projectContainer.addChild(titleNameLabel);
			
			nameLabel = Util.drawText( {
				text:			Main.storage.projName,
				color:			0x111111,
				size:			20,
				width:			390,
				height:			30,
				border:			true,
				borderColor:	0x999999,
				background:		true,
				backgroundColor:0xeeeeee,
				leftMargin:		4,
				rightMargin:	4,
				type:			TextFieldType.INPUT,
				embedFonts:		false,
				multiline:		false
			});
			nameLabel.name = 'previewWindowName';
			nameLabel.restrict = 'A-Za-z0-9_';
			nameLabel.x = 0;
			nameLabel.y = titleNameLabel.y + titleNameLabel.height + 3;
			nameLabel.addEventListener(TextEvent.TEXT_INPUT, onNameInput);
			projectContainer.addChild(nameLabel);
			
			
			
			
			
			// CC
			colorCorrectionBox = new CheckBox( {
				width:		16,
				height:		16,
				checked:	getActionChecked(1),
				onChange:	onActionStep,
				text:		'Цветовая коррекция',
				textParams:	{
					size:	20
				}
			});
			colorCorrectionBox.x = 4;
			colorCorrectionBox.y = nameLabel.y + nameLabel.height + 16;
			projectContainer.addChild(colorCorrectionBox);
			
			
			ccContainer = new Sprite();
			ccContainer.x = colorCorrectionBox.x + 20;
			ccContainer.y = colorCorrectionBox.y + colorCorrectionBox.height;
			projectContainer.addChild(ccContainer);
			
			cc1 = new CheckBox( {
				width:		12,
				height:		12,
				checked:	getChecked(1),
				onChange:	onCCCheck,
				text:		'Слой 1'
			} );
			ccContainer.addChild(cc1);
			
			cc2 = new CheckBox({
				width:		12,
				height:		12,
				checked:	getChecked(2),
				onChange:	onCCCheck,
				text:		'Слой 2'
			});
			cc2.x = cc1.x;
			cc2.y = cc1.y + cc1.height;
			ccContainer.addChild(cc2);
			
			cc3 = new CheckBox({
				width:		12,
				height:		12,
				checked:	getChecked(3),
				onChange:	onCCCheck,
				text:		'Слой 3'
			});
			cc3.x = cc1.x;
			cc3.y = cc2.y + cc2.height;
			ccContainer.addChild(cc3);
			
			cc4 = new CheckBox({
				width:		12,
				height:		12,
				checked:	getChecked(4),
				onChange:	onCCCheck,
				text:		'Слой 4'
			});
			cc4.x = cc1.x;
			cc4.y = cc3.y + cc3.height;
			ccContainer.addChild(cc4);
			
			cc5 = new CheckBox({
				width:		12,
				height:		12,
				checked:	getChecked(5),
				onChange:	onCCCheck,
				text:		'Слой 5'
			});
			cc5.x = cc1.x;
			cc5.y = cc4.y + cc4.height;
			ccContainer.addChild(cc5);
			
			
			
			// Анимация для персонажей или для зданий
			animationBox = new CheckBox( {
				width:		16,
				height:		16,
				checked:	Main.app.animationType,
				onChange:	onActionStep,
				text:		'Анимация для персонажей',
				textParams:	{
					size:	20
				}
			});
			animationBox.x = 0;
			animationBox.y = ccContainer.y + ccContainer.height + 4;
			projectContainer.addChild(animationBox);
			
			
			
			// Иконка
			iconBox = new CheckBox( {
				width:		16,
				height:		16,
				checked:	(Main.storage.actionStep && Main.storage.actionStep[6] == 1) ? true : false,
				onChange:	onActionStep,
				text:		'Создать иконку',
				textParams:	{
					size:	20
				}
			});
			iconBox.x = 0;
			iconBox.y = animationBox.y + animationBox.height + 2;
			projectContainer.addChild(iconBox);
			
			if (!Main.storage.iconWidth) Main.storage.iconWidth = 120;
			if (!Main.storage.iconHeight) Main.storage.iconHeight = 120;
			
			
			iconContainer = new Sprite();
			iconContainer.x = iconBox.x + 20;
			iconContainer.y = iconBox.y + iconBox.height + 2;
			projectContainer.addChild(iconContainer);
			
			titleIconWidthLabel = Util.drawText( {
				textAlign:	TextFormatAlign.RIGHT,
				rightMargin:4,
				text:		'Ширина',
				color:		0xffffff,
				size:		12
			});
			titleIconWidthLabel.x = 0;
			titleIconWidthLabel.y = 2;
			iconContainer.addChild(titleIconWidthLabel);
			
			iconWidthLabel = Util.drawText( {
				text:		Main.storage.iconWidth,
				color:		0x111111,
				size:		16,
				width:		60,
				border:		true,
				borderColor:	0x999999,
				background:	true,
				backgroundColor:0xeeeeee,
				type:		TextFieldType.INPUT,
				textAlign:	TextFormatAlign.CENTER,
				embedFonts:	false,
				maxChars:	3
			});
			iconWidthLabel.addEventListener(FocusEvent.FOCUS_OUT, onIconFocusOut);
			iconWidthLabel.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onIconFocusOut);
			iconWidthLabel.x = titleIconWidthLabel.x + titleIconWidthLabel.width + 4;
			iconWidthLabel.y = titleIconWidthLabel.y - 2;
			iconWidthLabel.restrict = '0-9';
			iconWidthLabel.maxChars = 3;
			iconContainer.addChild(iconWidthLabel);
			
			titleIconHeightLabel = Util.drawText( {
				textAlign:	TextFormatAlign.RIGHT,
				rightMargin:4,
				text:		'Высота',
				color:		0xffffff,
				size:		12
			});
			titleIconHeightLabel.x = iconWidthLabel.x + iconWidthLabel.width + 10;
			titleIconHeightLabel.y = titleIconWidthLabel.y;
			iconContainer.addChild(titleIconHeightLabel);
			
			iconHeightLabel = Util.drawText( {
				text:		Main.storage.iconHeight,
				color:		0x111111,
				size:		16,
				width:		60,
				border:		true,
				borderColor:	0x999999,
				background:	true,
				backgroundColor:0xeeeeee,
				type:		TextFieldType.INPUT,
				textAlign:	TextFormatAlign.CENTER,
				embedFonts:	false
			});
			iconHeightLabel.addEventListener(FocusEvent.FOCUS_OUT, onIconFocusOut);
			iconHeightLabel.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onIconFocusOut);
			iconHeightLabel.x = titleIconHeightLabel.x + titleIconHeightLabel.width + 4;
			iconHeightLabel.y = titleIconHeightLabel.y - 2;
			iconHeightLabel.restrict = '0-9';
			iconHeightLabel.maxChars = 3;
			iconContainer.addChild(iconHeightLabel);
			
			
			
			
			// Project
			projectBttn = new Button( {
				width:			280,
				height:			60,
				label:			'Собрать',
				textSize:		20,
				textBold:		true,
				click:			compileProject
			});
			projectBttn.x = 0;
			projectBttn.y = 420;// iconCreateBox.y + iconCreateBox.height + 20;
			projectContainer.addChild(projectBttn);
			
			projectCancelBttn = new Button( {
				width:			100,
				height:			60,
				label:			'Отмена',
				color1:			0xe00000,
				color2:			0x990000,
				textSize:		20,
				textBold:		true,
				click:			Main.app.compileCancel
			});
			projectCancelBttn.x = projectBttn.x + projectBttn.width + 6;
			projectCancelBttn.y = projectBttn.y;
			projectContainer.addChild(projectCancelBttn);
			
			logLabel = Util.drawText( {
				color:		0xffffff,
				size:		10,
				width:		params.width - 40,
				height:		80,
				multiline:	true,
				wordWrap:	true,
				selectable:	true
			});
			logLabel.border = true;
			logLabel.borderColor = 0x777777;
			logLabel.x = 20;
			logLabel.y = 630;
			container.addChild(logLabel);
			
			
			//projectContainer.addChild(projectViewContainer);
			projectContainer.addChild(dropViewContainer);
			
			
			onActionStep();
			buttonsState();
			
		}
		
		
		// Потеря фокуса 
		private function onIconFocusOut(e:FocusEvent = null):void {
			var iconWidthValue:int = int(iconWidthLabel.text);
			var iconHeightValue:int = int(iconHeightLabel.text);
			
			if (!isNaN(iconWidthValue) && iconWidthValue > 0 && iconWidthValue < 1000)
				Main.storage.iconWidth = iconWidthValue;
			
			if (!isNaN(iconHeightValue) && iconHeightValue > 0 && iconHeightValue < 1000)
				Main.storage.iconHeight = iconHeightValue;
			
			if (Main.app.compileState == 0 && previewitem.icon) {
				previewitem.show(PreviewItem.PNG);
			}
			
			Main.app.saveStorage(5000);
		}
		
		
		
		public function compileProject():void {
			if (Main.app.compileState > 0) return;
			
			projectDrop.hideList();
			viewDrop.hideList();
			
			if (serverBox.check) {
				if (ProjectManager.serverProjects.indexOf(projectDrop.text) < 0) {
					Alert.show('Указан неподдерживаемый проект', Main.appName);
					return;
				}
				
				if (viewDrop.text.length == 0) {
					Alert.show('Не указан вид объекта', Main.appName);
					return;
				}
			}
			
			// Сохранение позиций анимаций
			var createTime:int = int(new Date().getTime() / 1000);	// Время
			for (var i:int = 0; i < Main.app.animationsList.length; i++) {
				var animInfo:AnimInfo = Main.app.animationsList[i];
				if (!animInfo.name) continue;
				Main.storage.animations[animInfo.name] = {
					t:	animInfo.animType,
					r:	animInfo.repeat,
					c:	createTime
				}
			}
			
			if (!validPath) {
				Alert.show('Путь ' + pathProjLabel.text + ' не существует', Main.appName);
			}
			
			updatePaths();
			onIconFocusOut();
			
			
			Main.storage.projName = nameLabel.text;
			Main.app.compileName = nameLabel.text;
			
			// Сборка проекта
			switch(type) {
				case Main.JSN:
					Main.app.compileJSONProject();
					break;
				default:
					Main.app.compileProject();
			}
			
			Main.app.saveStorage();
		}
		
		
		
		private function buttonsState():void {
			projectBttn.state = (Main.app.compileState > 0 || !Main.app.hasCompile || Main.app.atlasCreating) ? Button.DISABLE : Button.NORMAL;
			projectCancelBttn.state = (Main.app.compileState > 0) ? Button.NORMAL : Button.DISABLE;
		}
		
		/**
		 * Проверка существования родителя указанной папки
		 * @return
		 */
		private function updatePaths():void {
			if (!validPath) {
				setActionChecked(7, 1);
				pathProjLabel.borderColor = 0xdd0000;
				pathProjLabel.backgroundColor = 0xffcccc;
			}
			
			Main.storage.projPath = pathProjLabel.text;
		}
		public function get validPath():Boolean {
			var find:Boolean;
			var separator:String;
			var path:String = pathProjLabel.text;
			
			if (path.indexOf('\\') > -1) separator = '\\';
			if (!separator && path.indexOf('/') > -1) separator = '/';
			if (separator) {
				path = path.replace((separator == '/') ? /\/$/ : /\\$/, '');
				
				var array:Array = path.split(separator);
				if (array.length > 1) {
					array.pop();
					path = array.join(separator);
					
					var file:File = new File(path);
					if (file.exists)
						return true;
				}
			}
			
			return false;
		}
		
		
		private function onCompileStart(e:Event):void {
			hold = true;
			
			drawProgress();
			buttonsState();
		}
		private function onCompileComplete(e:Event):void {
			hold = false;
			buttonsState();
			if (loader) loader.state(Compiler.COMPILE_COMPLETE);
			previewitem.drawItem(Main.app.currentSwf.nativePath);
		}
		
		
		private function onNameInput(e:TextEvent):void {
			Main.storage.projName = e.currentTarget.text + e.text;
		}
		
		
		
		// Color Correction check
		private function getChecked(layer:int):Boolean {
			if (Main.storage.ccLayers && Main.storage.ccLayers[layer])
				return true;
			
			return false;
		}
		
		
		// Action check
		public function getActionChecked(action:int):Boolean {
			if (Main.storage.actionStep && Main.storage.actionStep[action])
				return true;
			
			return false;
		}
		public function setActionChecked(action:int, check:*):void {
			if (!Main.storage.actionStep) Main.storage.actionStep = { };
			Main.storage.actionStep[action] = check;
		}
		
		
		// Color Correctio check
		private function onCCCheck():void {
			Main.storage.ccLayers = {
				1:	int(cc1.check),
				2:	int(cc2.check),
				3:	int(cc3.check),
				4:	int(cc4.check),
				5:	int(cc5.check)
			}
			
			var file:File = Main.app.getDropletFile();
			if (!file) Alert.show('Нет такого дроплета', Main.appName);
		}
		
		
		// Action
		private function onActionStep():void {
			Main.storage.actionStep = {
				1:	int(colorCorrectionBox.check),
				5:	int(animationBox.check),		// Анимация для персонажей
				6:	int(iconBox.check),				// Создание иконки
				7:	int(serverBox.check)			// Сохранение на сервер
			}
			
			if (Main.storage.actionStep[1]) {
				ccContainer.mouseChildren = true;
				ccContainer.mouseEnabled = true;
				ccContainer.alpha = 1;
			}else {
				ccContainer.mouseChildren = false;
				ccContainer.mouseEnabled = false;
				ccContainer.alpha = 0.4;
			}
			
			if (iconBox.check) {
				iconContainer.mouseChildren = true;
				iconContainer.mouseEnabled = true;
				iconContainer.alpha = 1;
			}else {
				iconContainer.mouseChildren = false;
				iconContainer.mouseEnabled = false;
				iconContainer.alpha = 0.4;
			}
			
			if (serverBox.check) {
				dropViewContainer.mouseChildren = true;
				dropViewContainer.mouseEnabled = true;
				dropViewContainer.alpha = 1;
			}else {
				dropViewContainer.mouseChildren = false;
				dropViewContainer.mouseEnabled = false;
				dropViewContainer.alpha = 0.4;
			}
			
			Main.app.animationType = getActionChecked(5);
			Main.app.createIcon = getActionChecked(6);
		}
		
		// Browse
		/*private function onBrowseSWF():void {
			Util.openDirectory(onBrowseSWFComplete, Main.storage.swfPath, null, 'Для SWF');
		}*/
		private function onBrowseProject():void {
			Files.openDirectory(onBrowseProjectComplete, Main.storage.projPath, null, 'Для проекта (as3proj)');
		}
		
		// Browse complete
		/*private function onBrowseSWFComplete(file:File):void {
			pathSWFLabel.text = file.nativePath;
			Main.storage.swfPath = file.nativePath;
			Main.app.saveStorage(1000);
		}*/
		private function onBrowseProjectComplete(file:File):void {
			pathProjLabel.text = file.nativePath;
			Main.storage.projPath = file.nativePath;
			Main.app.saveStorage(1000);
		}
		
		/**
		 * Обработка вводимого текста в поля путей файлов
		 */
		//private function onSWFInput(e:TextEvent):void {
			/*setTimeout(function():void {
				Main.storage.swfPath = pathSWFLabel.text;
				Main.storage.projPath = pathProjLabel.text;
				Main.app.saveStorage(5000);
			}, 10);*/
			
			/*var path:String = e.target.text + e.text;
			if (path.indexOf('//') >= 0 || path.indexOf('\\\\') >= 0) {
				e.preventDefault();
				return;
			}
			
			Main.storage.swfPath = path;
			Main.app.saveStorage(5000);*/
		//}
		private function onPathSWFFocusOut(e:FocusEvent):void {
			//modifiPathOfPoles(pathSWFLabel, pathProjLabel);
			pathSWFLabel.scrollH = pathSWFLabel.maxScrollH;
			Main.storage.swfPath = pathSWFLabel.text;
			Main.storage.projPath = pathProjLabel.text;
			Main.app.saveStorage(5000);
		}
		private function onPathProjFocusIn(e:FocusEvent):void {
			if (pathProjLabel.backgroundColor == 0xffffff) return;
			
			pathProjLabel.borderColor == 0x111111;
			pathProjLabel.backgroundColor = 0xffffff;
		}
		//private function onPathProjFocusOut(e:FocusEvent):void {
			//pathProjLabel.scrollH = pathProjLabel.maxScrollH;
			//Main.storage.swfPath = pathSWFLabel.text;
			//Main.storage.projPath = pathProjLabel.text;
			//Main.app.saveStorage(5000);
		//}
		//private function onProjInput(e:TextEvent):void {
			/*setTimeout(function():void {
				Main.storage.swfPath = pathSWFLabel.text;
				Main.storage.projPath = pathProjLabel.text;
				Main.app.saveStorage(5000);
			}, 10);*/
			
			/*var path:String = e.target.text + e.text;
			if (path.indexOf('//') >= 0 || path.indexOf('\\\\') >= 0) {
				e.preventDefault();
				return;
			}
			
			Main.storage.projPath = path;
			Main.app.saveStorage(5000);*/
		//}
		
		
		private function modifiPathOfPoles(input:TextField, output:TextField):void {
			
			var inputSeparator:String = (input.text.indexOf('\\') > -1) ? '\\' : null;
			if (!inputSeparator) inputSeparator = (input.text.indexOf('/') > -1) ? '/' : null;
			
			var outputSeparator:String = (output.text.indexOf('\\') > -1) ? '\\' : null;
			if (!outputSeparator) outputSeparator = (output.text.indexOf('/') > -1) ? '/' : null;
			if (!inputSeparator || !outputSeparator) return;
			
			var inputList:Array = input.text.split(inputSeparator);
			var outputList:Array = output.text.split(outputSeparator);
			
			inputList.reverse();
			outputList.reverse();
			
			for (var i:int = 0; i < inputList.length; i++) {
				for (var j:int = 0; j < outputList.length; j++) {
					if (inputList[i] == outputList[j]) {
						outputList.length = j;
						for (i; i < inputList.length; i++) {
							outputList.push(inputList[i]);
						}
						outputList.reverse();
						output.text = outputList.join(inputSeparator);
						return;
					}
				}
			}
			
		}
		
		
		// Создание иконки
		public function createIcon(swf:Object):void {
			previewitem.onLoad(swf);
			previewitem.createBitmapData();
		}
		
		
		
		// Update state
		public function state(mode:String):void {
			if (loader)	loader.state(mode);
			if (mode == Compiler.COMPILE_COMPLETE) {
				projectBttn.state = Button.NORMAL;
			}
			
			if (iconBox.check && mode == Compiler.COMPILE_COMPILE_SWF)
				previewitem.drawItem(Main.app.currentSwf.nativePath);
			
		}
		public function stateProgress(text:String):void {
			logLabel.appendText(((logLabel.text.length > 0) ? '\n' : '') + text);
			logLabel.scrollV = logLabel.maxScrollV;
		}
		
		
		public var loader:LoadView;
		public function drawProgress():void {
			var list:Array = [
				{ name:Compiler.COMPILE_START, title:'Старт' },
				{ name:Compiler.COMPILE_COPY_FILES, title:'Копирование файлов' },
				{ name:Compiler.COMPILE_COLOR_CORRECTION, title:'Цветокоррекция' },
				{ name:Compiler.COMPILE_COMPILE_SWF, title:'Сборка проекта' },
				{ name:Compiler.COMPILE_ZIP, title:'Сжатие' },
				{ name:Compiler.COMPILE_ICON, title:'Создание иконок' },
				{ name:Compiler.COMPILE_UPLOAD, title:'Загрузка на сервер' },
				{ name:Compiler.COMPILE_COMPLETE, title:'Готово' }
			];
			
			loader = new LoadView(list);
			loader.x = params.width * 0.5 - loader.width * 0.5;
			loader.y = 565;
			container.addChild(loader);
		}
		
		
		override public function close(e:MouseEvent = null):void {
			
			if (hold) {
				Main.app.compileCancel();
				return;
			}
			
			Main.storage.projPath = pathProjLabel.text;
			
			PreviewWindow.instance = null;
			
			projectDrop.dispose();
			projectDrop = null;
			
			viewDrop.dispose();
			viewDrop = null;
			
			systemBrowserProjBttn.dispose();
			systemBrowserProjBttn = null;
			
			browseProjBttn.dispose();
			browseProjBttn = null;
			
			tempFolderBttn.dispose();
			tempFolderBttn = null;
			
			//pathProjLabel.removeEventListener(TextEvent.TEXT_INPUT, onProjInput);
			//pathProjLabel.removeEventListener(FocusEvent.FOCUS_OUT, onPathProjFocusOut);
			//pathSWFLabel.removeEventListener(TextEvent.TEXT_INPUT, onSWFInput);
			//pathSWFLabel.removeEventListener(FocusEvent.FOCUS_OUT, onPathSWFFocusOut);
			
			iconWidthLabel.removeEventListener(FocusEvent.FOCUS_OUT, onIconFocusOut);
			iconWidthLabel.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onIconFocusOut);
			iconHeightLabel.removeEventListener(FocusEvent.FOCUS_OUT, onIconFocusOut);
			iconHeightLabel.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onIconFocusOut);
			
			super.close();
		}
		
	}

}

import adobe.utils.CustomActions;
import com.greensock.TweenLite;
import enixan.Util;
import enixan.components.CheckList;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import enixan.Anime;
import enixan.components.Button;
import flash.display.StageQuality;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.events.TextEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormatAlign;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import wins.PreviewWindow;

internal class LoadView extends Sprite {
	
	private var passiveColor:uint = 0x666666;
	private var activeColor:uint = 0x22EE44;
	
	public var list:Array;
	private var states:Vector.<Shape> = new Vector.<Shape>;
	private var loading:Preloader;
	
	public function LoadView(list:Array) {
		
		// name, title, weight
		this.list = list;
		
		draw();
		
	}
	
	private function draw():void {
		
		const LINE_HEIGHT:int = 20;
		const COLOR:uint = 0xeeeeee;
		
		for (var i:int = 0; i < list.length; i++) {
			
			var line:Shape = new Shape();
			line.graphics.lineStyle(2, COLOR);
			line.graphics.lineTo(100, 0);
			line.x = i * 100;
			line.y = LINE_HEIGHT;
			line.alpha = 0.0;
			line.name = 'line' + i;
			addChild(line);
		}
		
		for (i = 0; i < list.length; i++) {
			var shape:Shape = new Shape();
			shape.name = list[i].name;
			shape.x = i * 100;
			shape.y = LINE_HEIGHT;
			
			if (i == 0) {
				shape.graphics.beginFill(COLOR);
				shape.graphics.drawCircle(0, 0, 7);
				shape.graphics.endFill();
				addChild(shape);
			}else{
				
				shape.graphics.lineStyle(2, COLOR);
				shape.graphics.beginFill(0x666666);
				shape.graphics.drawCircle(0, 0, 14);
				shape.graphics.endFill();
				addChild(shape);
				
				var textLabel:TextField = Util.drawText( {
					text:		i.toString(),
					color:		COLOR,
					size:		24
				});
				textLabel.x = shape.x - textLabel.width * 0.5;
				textLabel.y = shape.y - textLabel.height * 0.5 - 1;
				addChild(textLabel);
			}
			
			states.push(shape);
		}
		
		loading = new Preloader();
		loading.y = LINE_HEIGHT;
		addChild(loading);
		
	}
	
	public function state(mode:String):void {
		var position:int = -1;
		for (var i:int = 0; i < list.length; i++) {
			if (list[i].name == mode) {
				position = i;
				break;
			}
		}
		
		if (position < 0) return;
		if (position == list.length - 1) {
			dispose();
			return;
		}
		
		loading.x = 100 * position;
		
		for (i = 0; i < list.length; i++) {
			if (position <= i) break;
			
			var shape:Shape = getChildByName('line' + i.toString()) as Shape;
			if (shape && shape.alpha == 0) {
				TweenLite.to(shape, 0.6, { alpha:1 } );
			}
		}
	}
	
	public function dispose():void {
		removeChildren();
		
		if (parent)
			parent.removeChild(this);
	}
	
}

internal class PreviewItem extends Sprite
{
	public static const SWF:String = 'swf';
	public static const PNG:String = 'png';
	
	public var settings:Object = {
		width: 450,
		height: 450
	};
	public var callback:Function = null;
	public function PreviewItem(settings:Object = null, callback:Function = null) {
		for (var item:* in settings){
			this.settings[item] = settings[item];
		}
			
		if (callback != null)
			this.callback = callback;
		
		drawBackground();
	}
	
	public var background:Shape;
	public function drawBackground():void {
		background = new Shape();
		background.graphics.beginFill(0x595959);
		background.graphics.drawRect(0, 0, settings.width, settings.height);
		background.graphics.endFill();
		addChild(background);
	}
	
	public var animations:Object = {};
	public var stages:Object = {};
	private var anime:Anime;
	private var url:String = 'D:/Work/swf/polar_bear.swf';//bear_fryer,polar_bear,reitar_s.swf
	private var loading:Preloader;
	public var icon:Sprite;
	public function drawItem(url:String = null):void {
		if (!url) return;
		
		this.url = url;
		
		loading = new Preloader();
		loading.name = 'loading';
		loading.x = (background.width - loading.width) / 2;
		loading.y = (background.height - loading.height) / 2;
		addChild(loading);
		Util.load(url, onLoad);
	}
	
	private var stop_pause:String = 'stop_pause';
	private var stop_pause_swim:String = 'stop_pause_swim';
	private var walk:String = 'walk';
	private var walk_back:String = 'walk_back'
	private var swim:String = 'swime';
	private var swim_back:String = 'swime_back';
	private var back:String = '_back';
	private var swf:*;
	private var iconStage:Bitmap;
	private var iconID:int;
	private var iconType:String;
	public function onLoad(swf:Object):void {
		
		if (loading && loading.parent && getChildByName(loading.name))
			removeChild(loading);
		
		iconType = null;
		
		this.swf = swf;
		
		//drawBackground();
		//drawUpPanel();
		
		show(SWF);
	}
	
	private var __state:String;
	public function get state():String {
		return __state;
	}
	public function set state(value:String):void {
		__state = value;
	}
	
	public function show(state:String = null):void {
		
		if (state == null) return;
		//if (this.state == state) return;
		this.state = state;
		
		clear();
		drawBackground();
		drawUpPanel();
		
		switch(state) {
			case PNG:
				drawBacking();
				drawBottomPanel();
				
				if(animTypeValues.length > 0)
					drawPNGCheckList();
				
				showPNG();
				
				break;
			default:
				showSWF();
		}
	}
	
	private function clear():void {
		while (this.numChildren > 0){
			var child:* = this.getChildAt(this.numChildren - 1);
			if (child is StagesPanel || child is AnimPanel || child is IconsPanel || child is Button){
				child.dispose();
			}
			this.removeChild(child);
			child = null;
		}
		while (panels.numChildren > 0){
			child = panels.getChildAt(panels.numChildren - 1);
			if (child is StagesPanel || child is AnimPanel || child is IconsPanel || child is Button){
				child.dispose();
			}
			panels.removeChild(child);
			child = null;
		}
		if (iconsPanel) {
			while (iconsPanel.numChildren > 0){
				child = iconsPanel.getChildAt(iconsPanel.numChildren - 1);
				if (child is Button){
					child.dispose();
				}
				iconsPanel.removeChild(child);
				child = null;
			}
			iconsPanel = null;
		}
		if (stagesPanel) {
			while (stagesPanel.numChildren > 0){
				child = stagesPanel.getChildAt(stagesPanel.numChildren - 1);
				if (child is Button){
					child.dispose();
				}
				stagesPanel.removeChild(child);
				child = null;
			}
			stagesPanel = null;
		}
		if (animPanel) {
			while (animPanel.numChildren > 0){
				child = animPanel.getChildAt(animPanel.numChildren - 1);
				if (child is Button){
					child.dispose();
				}
				animPanel.removeChild(child);
				child = null;
			}
			animPanel = null;
		}
		if (icon) {
			icon.removeChildren();
			icon = null;
		}
		if (iconBacking) {
			iconBacking = null;
		}
	}
	
	private var upPanel:Sprite = new Sprite();
	private function drawUpPanel():void {
		addChild(upPanel);
		
		var swfButton: Button = new Button( {
			label:		'swf',
			width:		100,
			height:		30,
			click:		function():void { 
				/*clear();
				drawBackground();
				drawUpPanel();
				showSWF();*/
				
				show(SWF);
			}
		} );
		upPanel.addChild(swfButton);
		var pngButton: Button = new Button( {
			label:		'png',
			width:		100,
			height:		30,
			click:		function():void {
				/*clear();
				drawBackground();
				drawBacking();
				drawUpPanel();
				drawBottomPanel();
				
				if(animTypeValues.length > 0)
					drawPNGCheckList();
				
				showPNG();*/
				
				show(PNG);
			}
		} );
		pngButton.x = swfButton.width + 5;
		upPanel.addChild(pngButton);
		upPanel.x = background.x + (background.width - upPanel.width) / 2;
	}
	
	
	/**
	 * Создание иконки
	 */
	public function createBitmapData():void {
		
		var iconWidth:int = Main.storage.iconWidth;
		var iconHeight:int = Main.storage.iconHeight;
		var tempCreateIcon:Boolean;
		
		//if (iconWidth > background.width) iconWidth = background.width;
		//if (iconHeight > background.height) iconHeight = background.height;
		
		if (!icon) {
			tempCreateIcon = true;
			showPNG();
		}
		
		// Отношение сторон
		if (iconWidth / iconHeight < icon.width / icon.height) {
			icon.width = iconWidth;
			if (icon.scaleX > 1) icon.scaleX = 1;
			icon.scaleY = icon.scaleX;
		}else {
			icon.height = iconHeight;
			if (icon.scaleY > 1) icon.scaleY = 1;
			icon.scaleX = icon.scaleY;
		}
		
		var pos:Object = icon.getBounds(icon);
		
		if (pos.width > 0 && pos.height > 0) {
			icon.x = -pos.left * icon.scaleX + (background.width - pos.width * icon.scaleX) / 2;
			icon.y = -pos.top * icon.scaleY + (background.height - pos.height * icon.scaleY) / 2;
			
			var matrix:Matrix = new Matrix();
			matrix.translate(-pos.topLeft.x,-pos.topLeft.y);
			matrix.scale(icon.width / pos.width, icon.height / pos.height);
			
			PreviewWindow.bitmapData = new BitmapData(icon.width, icon.height, true, 0x00000000);
			PreviewWindow.bitmapData.drawWithQuality(icon, matrix, null, null, null, true, StageQuality.BEST);
		}else {
			PreviewWindow.bitmapData = new BitmapData(iconWidth, iconHeight, true, 0);
		}
		
		callback( { bitmapData:PreviewWindow.bitmapData } );
		
		if (tempCreateIcon && icon) {
			removeChild(icon);
		}
	}
	
	
	private var bottomPanel:Sprite = new Sprite();
	private var saveIconButton:Button;
	private function drawBottomPanel():void {
		addChild(bottomPanel);
		
		var saveIconButton:Button = new Button({
			label:		'Создать иконку',
			width:		100,
			height:		30,
			click:		function():void {
				createBitmapData();
				Main.app.saveIcon();
			}
		});
		saveIconButton.x = 0;
		saveIconButton.y = 0;
		bottomPanel.addChild(saveIconButton);
		
		
		bottomPanel.x = background.x + (background.width - bottomPanel.width) / 2;
		bottomPanel.y = background.y + background.height - bottomPanel.height;
	}
	
	private var iconAnim:Bitmap;
	private var iconWidth:int;
	private var iconHeight:int;
	private var framesDirection:int;
	public function showPNG():void {
		
		if (!swf) return;
		
		if (icon){
			var child:* = getChildByName(icon.name);
			if (child) removeChild(child);
		}
		
		icon = new Sprite();
		addChild(icon);
		
		for (var j:int = panels.numChildren - 1; j >= 0; j--){
			child = panels.getChildAt(j);
			if (child is StagesPanel || child is AnimPanel || child is IconsPanel){
				child.dispose();
				panels.removeChild(child);
			}
		}
		
		if(swf.hasOwnProperty('animation') && swf.animation.animations) {
			animations = swf.animation.animations;
			if (!iconType){
				if (animations.hasOwnProperty(stop_pause)){
					iconType = stop_pause;
				}else if (animations.hasOwnProperty(stop_pause_swim)){
					iconType = stop_pause_swim;
				}else{
					for (var anim:* in animations){
						iconType = anim;
					}
				}
			}
		}
		animTypeValues = [];
		
		if (iconType){
			if (iconType.indexOf(back) != -1){
				iconType = iconType.substring(0, iconType.indexOf(back));
				framesDirection = 1;
			} else {
				framesDirection = 0;
			}
			if (swf.animation.animations[iconType].frames[0] is Array){
				animations = swf.animation.animations[iconType].frames;
				for (var itm:* in swf.animation.animations){
					if (swf.animation.animations[itm].frames.length > 1){
						animTypeValues.push({value:itm, name:itm});
						animTypeValues.push({value:itm+back, name:itm+back});
					} else {
						animTypeValues.push({value:itm, name:itm});
					}
					
				}
			} else {
				animations = swf.animation.animations[iconType].frames;
				for (itm in swf.animation.animations){
					animTypeValues.push({value:itm, name:itm});
				}
			}
			if(!iconsTypeBox)
				drawPNGCheckList();
			
			/*if (stages.lenght > 0){
				Stage = stages.lenght - 1;
			}
			
			if (Stage != -1) { 
				var params:Object = {stage:Stage};
			}*/
			
			if (swf.animation.animations[iconType].frames[0] is Array){
				if (!swf.animation.animations[iconType].frames[framesDirection])
					framesDirection = swf.animation.animations[iconType].frames.length - 1;
				
				if (!swf.animation.animations[iconType].frames[framesDirection][iconID])
					iconID = swf.animation.animations[iconType].frames[framesDirection][swf.animation.animations[iconType].frames[framesDirection].length];
				
				iconAnim = new Bitmap(swf.animation.animations[iconType].frames[framesDirection][iconID].bmd, "auto", true);
			} else {
				if (!swf.animation.animations[iconType].frames[iconID])
					iconID = swf.animation.animations[iconType].frames[swf.animation.animations[iconType].frames.length];
				
				iconAnim = new Bitmap(swf.animation.animations[iconType].frames[iconID].bmd, "auto", true);
			}
		}
		
		if(swf.sprites.length > 0) {
			if (swf.sprites is Array) {
				if (swf.sprites.length <= Stage || Stage < 0)
					Stage = swf.sprites.length - 1;
			}
			
			iconStage = new Bitmap(swf.sprites[Stage].bmp, "auto", true);
			iconStage.x = swf.sprites[Stage].dx;
			iconStage.y = swf.sprites[Stage].dy;
			icon.addChild(iconStage);
		}else {
			Stage = -1;
		}
		
		if (iconAnim && Stage == swf.sprites.length - 1){
			if (swf.animation.animations[iconType].frames[0] is Array){
				iconAnim.x = swf.animation.animations[iconType].frames[framesDirection][iconID].ox;
				iconAnim.y = swf.animation.animations[iconType].frames[framesDirection][iconID].oy;
			} else {
				iconAnim.x = swf.animation.animations[iconType].frames[iconID].ox;
				iconAnim.y = swf.animation.animations[iconType].frames[iconID].oy;
			}
			icon.addChild(iconAnim);
		}
		
		//try {
			createBitmapData();
			drawPNGButtons();
		//}catch (e:Error) { }
		
	}
	
	private var iconBacking:Shape;
	private function drawBacking():void {
		if (!iconBacking) {
			iconBacking = new Shape();
			addChild(iconBacking);
		}
		
		iconBacking.graphics.clear();
		iconBacking.graphics.beginFill(0x494949,1);
		iconBacking.graphics.drawRect(0, 0, Main.storage.iconWidth, Main.storage.iconHeight);
		iconBacking.graphics.endFill();
		iconBacking.x = background.x + (background.width - iconBacking.width) / 2;
		iconBacking.y = background.y + (background.height - iconBacking.height) / 2;
	}
	
	private function showSWF():void {
		if (!swf) return;
		
		for (var j:int = panels.numChildren - 1; j >= 0; j--){
			var child:* = panels.getChildAt(j);
			if (child is IconsPanel){
				child.dispose();
				panels.removeChild(child);
			}
		}
		
		if(swf.hasOwnProperty('animation') && swf.animation.animations) {
			animations = swf.animation.animations;
			if (!Anim){
				if (animations.hasOwnProperty(stop_pause)){
					Anim = stop_pause;
				}else if (animations.hasOwnProperty(stop_pause_swim)){
					Anim = stop_pause_swim;
				}else{
					for (var anim:* in animations){
						Anim = anim;
					}
				}
			}
		}
		stages = (swf && swf.hasOwnProperty('sprites')) ? swf.sprites : { };
		if(stages.lenght > 0){
			Stage = stages.lenght;
		}
		
		if (Stage != -1) { 
			var params:Object = {stage:Stage};
		}
		
		if (Anim){
			if (!params){
				params = { };
			}
			
			params.framesType = Anim;
			
			if (Anim.indexOf(back) != -1){
				Anim = Anim.substring(0, Anim.indexOf(back));
				params.framesType = Anim;
				params.framesDirection = 1;
			}
		}
		
		anime = new Anime(swf, params);
		
		if (anime.height > background.height * 0.8){
			anime.height = background.height * 0.8;
			anime.scaleX = anime.scaleY;
		}else if (anime.width > background.width * 0.8){
			anime.width = background.width * 0.8;
			anime.scaleY = anime.scaleX;
		}
		
		anime.x = (background.width - anime.width) / 2;
		anime.y = (background.height - anime.height) / 2;
		addChild(anime);
		
		if (panels.numChildren == 0)
			drawSWFButtons();
	}
	
	private function drawPNGCheckList():void{
		iconsTypeBox = new CheckList( {
			values:		animTypeValues
		});
		iconsTypeBox.x = background.width - iconsTypeBox.width;
		panels.addChild(iconsTypeBox);
		iconsTypeBox.addEventListener(Event.CHANGE, onNumericChange);
	}
	
	public var panels:Sprite = new Sprite();
	private var animTypeValues:Array = [];
	private var iconsTypeBox:CheckList;
	private var iconsPanel:IconsPanel;
	public function drawPNGButtons():void {
		if (stagesPanel && panels.numChildren > 0){
			var child:* = getChildByName(stagesPanel.name);
			if(child){
				child.dispose();
				panels.removeChild(child);
				child = null;
			}
		}
		
		if (iconsPanel && panels.numChildren > 0){
			child = getChildByName(iconsPanel.name);
			if(child){
				child.dispose();
				panels.removeChild(child);
				child = null;
			}
		}
		
		stagesPanel = new StagesPanel(stages, setIconStage, {width:30, height:30, maskHeight:settings.height - 100});
		stagesPanel.y = background.height - stagesPanel.Mask.height;
		panels.addChild(stagesPanel);
		
		if(animations[0] is Array) {
			iconsPanel = new IconsPanel(animations[framesDirection], setIcon, {width:30, height:30, height:30, maskHeight:settings.height - 100});
		} else {
			iconsPanel = new IconsPanel(animations, setIcon, {width:30, height:30, height:30, maskHeight:settings.height - 100});
		}
		iconsPanel.x = background.width - iconsPanel.Mask.width;
		iconsPanel.y = background.height - iconsPanel.Mask.height;
		panels.addChild(iconsPanel);
		
		addChild(panels);
	}
	
	private function onNumericChange(e:Event):void {
		//if (!animInfo) return;
		
		iconType = iconsTypeBox.value;
		showPNG();
		//animationLine.changeChain(animInfo.chain);
	}
	
	private var stagesPanel:StagesPanel;
	private var animPanel:AnimPanel;
	public function drawSWFButtons():void {
		if (stagesPanel && panels.numChildren > 0){
			stagesPanel.dispose();
			panels.removeChild(stagesPanel);
			stagesPanel = null;
		}
		if (animPanel  && panels.numChildren > 0) {
			animPanel.dispose();
			panels.removeChild(animPanel);
			animPanel = null;
		}
		
		stagesPanel = new StagesPanel(stages, setStage, {width:30, height:30, maskHeight:settings.height - 100});
		stagesPanel.y = background.height - stagesPanel.Mask.height;
		panels.addChild(stagesPanel);
		
		animPanel = new AnimPanel(animations, setAnimation, {width:100, height:30, maskHeight:settings.height - 100});
		animPanel.x = background.width - animPanel.Mask.width;
		animPanel.y = background.height - animPanel.Mask.height;
		panels.addChild(animPanel);
		
		addChild(panels);
	}
	
	public function setIconStage(object:Object):void {
		Stage = object.name;
		
		showPNG();
	}
	
	public function setIcon(object:Object):void {
		iconID = object.name;
		
		showPNG();
	}
	
	
	public static var Stage:int = -1;
	public static var Anim:String = null;
	public function setStage(object:Object):void {
		for (var i:int = 0; i < this.numChildren; i++){
			var child:* = getChildAt(i);
			if(child is Anime)
				removeChild(child);
		}
		anime = null;
		
		Stage = object.name;
		
		showSWF();
	}
	
	public function setAnimation(object:Object):void {
		for (var i:int = 0; i < this.numChildren; i++){
			var child:* = getChildAt(i);
			if(child is Anime)
				removeChild(child);
		}
		anime = null;
		
		Anim = object.name;
		
		showSWF();
	}
}

internal class StagesPanel extends Sprite
{
	public var settings:Object = {
		width:	30,
		height:	30,
		maskWidth:	100,
		maskHeight:	400
	};
	public var sprite:Sprite = new Sprite();
	private var backing:Shape = new Shape();
	public var Mask:Shape = new Shape();
	private var background:Shape = new Shape();
	public var back:Sprite = new Sprite();
	public var Buttons:Array = new Array();
	public function StagesPanel(stages:Object, callback:Function, settings:Object = null ) {
		if (settings != null){
			for (var itm:* in settings) {
				this.settings[itm] = settings[itm];
			}
		}
		
		sprite.mask = Mask;
		back.addChild(background);
		sprite.addChild(backing);
		addChild(Mask);
		addChild(back);
		addChild(sprite);
		
		for (var item:* in stages){
			var button: Button = new Button( {
				label:		String(item),
				width:		this.settings.width,
				height:		this.settings.height,
				click:		callback,
				onClickParams: {'name':item}
			} );
			button.name = item;
			Buttons.push(button);
			sprite.addChild(button);
			button.y = (button.height + 5) * Buttons.indexOf(button);
		}
		
		Mask.graphics.beginFill(0xff0000, 0.5);
		Mask.graphics.drawRect(0,0,sprite.width,settings.maskHeight);
		Mask.graphics.endFill();
		
		background.graphics.beginFill(0x595959, 0.5);
		if(sprite.height > Mask.height){
			background.graphics.drawRect(0, 0, sprite.width, Mask.height);
		}else{
			background.graphics.drawRect(0, 0, sprite.width, sprite.height);
		}
		background.graphics.endFill();
		
		backing.graphics.beginFill(0x595959, 0.5);
		backing.graphics.drawRect(0, 0, sprite.width, sprite.height);
		backing.graphics.endFill();
		
		sprite.x = - sprite.width - 1;
		back.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
		
		if (sprite.height > Mask.height){
			sprite.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		} else {
			sprite.y = Mask.height - sprite.height;
			back.y = Mask.height - back.height;
		}
		
		drawScroll();
	}
	
	public function dispose():void {
		for (var i:int = numChildren - 1; i >= 0; i--){
			var child:* = getChildAt(i);
			if (child is Button){
				child.dispose();
				removeChild(child);
				child = null;
			}
		}
	}
	
	private var scrollSprite:Sprite = new Sprite();
	private var scrollLabel:Shape = new Shape();
	private var scroll:Sprite = new Sprite();
	private var scrollBack:Shape = new Shape();
	private function drawScroll():void {
		addChild(scrollSprite);
		scrollSprite.x = Mask.x - 5;
		scrollSprite.y = Mask.y;
		
		scrollBack.graphics.beginFill(0x595959, 0.5);
		if(sprite.height > Mask.height){
			scrollBack.graphics.drawRect(0, 0, 5, Mask.height);
		}else{
			scrollBack.graphics.drawRect(0, 0, 5, sprite.height);
		}
		scrollBack.graphics.endFill();
		scrollSprite.addChild(scrollBack);
		
		scrollLabel.graphics.beginFill(0xFFFFFF, 0.5);
		if(sprite.height > Mask.height){
			scrollLabel.graphics.drawRect(0, 0, 5, Mask.height / 5);
			scroll.addEventListener(MouseEvent.MOUSE_DOWN, onScrollDown);
		}else{
			scrollLabel.graphics.drawRect(0, 0, 5, sprite.height);
		}
		scrollLabel.graphics.endFill();
		scroll.addChild(scrollLabel);
		
		scroll.addEventListener(MouseEvent.ROLL_OVER, onScrollOver);
		
		scrollSprite.addChild(scroll);
		
		if(sprite.height < Mask.height){
			scrollBack.y = scrollLabel.y = Mask.height - scrollLabel.height;
		}
	}
	
	private var onScrollClick:Boolean = false;
	private function onScrollDown(e:MouseEvent):void {
		Main.app.addEventListener(MouseEvent.MOUSE_UP, onScrollUp);
		scroll.startDrag(false, new Rectangle(scrollBack.x, scrollBack.y, scrollBack.x, scrollBack.height - scroll.height));
		scroll.addEventListener(Event.ENTER_FRAME, onScrollMove);
		onScrollClick = true;
	}
	
	private function onScrollOver(e:MouseEvent):void {
		scrollLabel.graphics.clear();
		scrollLabel.graphics.beginFill(0x65a9d0, 0.8);
		if(sprite.height > Mask.height){
			scrollLabel.graphics.drawRect(0, 0, 5, Mask.height / 5);
		}else{
			scrollLabel.graphics.drawRect(0, 0, 5, sprite.height);
		}
		scrollLabel.graphics.endFill();
		scroll.addEventListener(MouseEvent.ROLL_OUT, onScrollOut);
	}
	
	private function onScrollOut(e:MouseEvent = null):void {
		if(!onScrollClick){
			scroll.removeEventListener(MouseEvent.ROLL_OUT, onScrollOut);
			scrollLabel.graphics.clear();
			scrollLabel.graphics.beginFill(0xFFFFFF, 0.5);
			if(sprite.height > Mask.height){
				scrollLabel.graphics.drawRect(0, 0, 5, Mask.height / 5);
			}else{
				scrollLabel.graphics.drawRect(0, 0, 5, sprite.height);
			}
			scrollLabel.graphics.endFill();
		}
	}
	
	private function onScrollMove(e:Event):void {
		sprite.y = -scroll.y / (Mask.height - scroll.height) * (sprite.height - Mask.height);
	}
	
	private function onScrollUp(e:MouseEvent):void {
		Main.app.removeEventListener(MouseEvent.MOUSE_UP, onScrollUp);
		scroll.stopDrag();
		scroll.removeEventListener(Event.ENTER_FRAME, onScrollMove);
		onScrollClick = false;
	}
	
	private function changeScroll(percent:Number):void {
		scroll.y = (Mask.height - scroll.height) * percent;
	}
	
	private function onMouseOver(e:MouseEvent):void {
		this.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		TweenLite.to( sprite, 0.15, {x:0} );
	}
	
	private function onMouseOut(e:MouseEvent):void {
		this.removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		TweenLite.to( sprite, 0.15, {x:- sprite.width - 1} );
	}
	
	private function onMouseWheel(e:MouseEvent):void {
		var step:int = 24;
		var percent:Number = (sprite.height - Mask.height) / 100;
		if (e.delta > 0){
			if (sprite.y + step >= 0){
				sprite.y = 0;
				changeScroll(Math.abs(sprite.y / (sprite.height - Mask.height)));
				return;
			}
			sprite.y += step;
			changeScroll(Math.abs(sprite.y / (sprite.height - Mask.height)));
		} else {
			if (sprite.y + sprite.height - step <= Mask.height) {
				sprite.y = -sprite.height + Mask.height;
				changeScroll(Math.abs(sprite.y / (sprite.height - Mask.height)));
				return;
			}
			sprite.y -= step;
			changeScroll(Math.abs(sprite.y / (sprite.height - Mask.height)));
		}
	}
}

internal class AnimPanel extends Sprite
{
	public var settings:Object = {
		width:		100,
		height:		30,
		maskWidth:	100,
		maskHeight:	400
	};
	public var Buttons:Array = new Array();
	private var backing:Shape = new Shape();
	public var sprite:Sprite = new Sprite();
	private var background:Shape = new Shape();
	public var back:Sprite = new Sprite();
	public var Mask:Shape = new Shape();
	public function AnimPanel(animes:Object, callback:Function, settings:Object = null ) {
		if (settings != null){
			for (var itm:* in settings) {
				this.settings[itm] = settings[itm];
			}
		}
		
		sprite.mask = Mask;
		back.addChild(background);
		sprite.addChild(backing);
		addChild(Mask);
		addChild(back);
		addChild(sprite);
		
		
		for (var item:* in animes){
			var button: Button = new Button( {
				label:		item,
				width:		this.settings.width,
				height:		this.settings.height,
				click:		callback,
				onClickParams: {'name':item}
			} );
			button.name = item;
			Buttons.push(button);
			sprite.addChild(button);
			button.y = (button.height + 5) * Buttons.indexOf(button);
			if (animes[item].frames[0] is Array && animes[item].frames[1]){
				button = new Button( {
					label:		item + '_back',
					width:		this.settings.width,
					height:		this.settings.height,
					click:		callback,
					onClickParams: {'name':item + '_back'}
				} );
				button.name = item+'_back';
				Buttons.push(button);
				sprite.addChild(button);
				button.y = (button.height + 5) * Buttons.indexOf(button);
			}
		}
		
		Mask.graphics.beginFill(0xff0000, 0.5);
		Mask.graphics.drawRect(0,0,sprite.width,settings.maskHeight);
		Mask.graphics.endFill();
		
		backing.graphics.beginFill(0x595959, 0.5);
		backing.graphics.drawRect(0, 0, sprite.width, sprite.height);
		backing.graphics.endFill();
		
		background.graphics.beginFill(0x595959, 0.5);
		if(sprite.height > Mask.height){
			background.graphics.drawRect(0, 0, sprite.width, Mask.height);
		}else{
			background.graphics.drawRect(0, 0, sprite.width, sprite.height);
		}
		background.graphics.endFill();
		
		sprite.x = sprite.width;
		
		back.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
		
		if (sprite.height > Mask.height){
			sprite.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		} else {
			sprite.y = Mask.height - sprite.height;
			back.y = Mask.height - back.height;
		}
		
		drawScroll();
	}
	
	public function dispose():void {
		sprite.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		
		for (var i:int = numChildren - 1; i >= 0; i--){
			var child:* = getChildAt(i);
			if (child is Button){
				child.dispose();
				child = null;
				removeChild(child);
			}
		}
	}
	
	private var scrollSprite:Sprite = new Sprite();
	private var scrollLabel:Shape = new Shape();
	private var scroll:Sprite = new Sprite();
	private var scrollBack:Shape = new Shape();
	private function drawScroll():void {
		addChild(scrollSprite);
		scrollSprite.x = Mask.x + Mask.width;
		scrollSprite.y = Mask.y;
		
		scrollBack.graphics.beginFill(0x595959, 0.5);
		if(sprite.height > Mask.height){
			scrollBack.graphics.drawRect(0, 0, 5, Mask.height);
		}else{
			scrollBack.graphics.drawRect(0, 0, 5, sprite.height);
		}
		scrollBack.graphics.endFill();
		scrollSprite.addChild(scrollBack);
		
		scrollLabel.graphics.beginFill(0xFFFFFF, 0.5);
		if(sprite.height > Mask.height){
			scrollLabel.graphics.drawRect(0, 0, 5, Mask.height / 5);
			scroll.addEventListener(MouseEvent.MOUSE_DOWN, onScrollDown);
		}else{
			scrollLabel.graphics.drawRect(0, 0, 5, sprite.height);
		}
		scrollLabel.graphics.endFill();
		
		scroll.addChild(scrollLabel);
		
		scroll.addEventListener(MouseEvent.ROLL_OVER, onScrollOver);
		
		scrollSprite.addChild(scroll);
		
		if(sprite.height < Mask.height){
			scrollBack.y = scrollLabel.y = Mask.height - scrollLabel.height;
		}
	}
	
	private var onScrollClick:Boolean = false;
	private function onScrollDown(e:MouseEvent):void {
		Main.app.addEventListener(MouseEvent.MOUSE_UP, onScrollUp);
		scroll.startDrag(false, new Rectangle(scrollBack.x, scrollBack.y, scrollBack.x, scrollBack.height - scroll.height));
		scroll.addEventListener(Event.ENTER_FRAME, onScrollMove);
		onScrollClick = true;
	}
	
	private function onScrollOver(e:MouseEvent):void {
		scrollLabel.graphics.clear();
		scrollLabel.graphics.beginFill(0x65a9d0, 0.8);
		if(sprite.height > Mask.height){
			scrollLabel.graphics.drawRect(0, 0, 5, Mask.height / 5);
		}else{
			scrollLabel.graphics.drawRect(0, 0, 5, sprite.height);
		}
		scrollLabel.graphics.endFill();
		scroll.addEventListener(MouseEvent.ROLL_OUT, onScrollOut);
	}
	
	private function onScrollOut(e:MouseEvent = null):void {
		if(!onScrollClick){
			scroll.removeEventListener(MouseEvent.ROLL_OUT, onScrollOut);
			scrollLabel.graphics.clear();
			scrollLabel.graphics.beginFill(0xFFFFFF, 0.5);
			if(sprite.height > Mask.height){
				scrollLabel.graphics.drawRect(0, 0, 5, Mask.height / 5);
			}else{
				scrollLabel.graphics.drawRect(0, 0, 5, sprite.height);
			}
			scrollLabel.graphics.endFill();
		}
	}
	
	private function onScrollMove(e:Event):void {
		sprite.y = -scroll.y / (Mask.height - scroll.height) * (sprite.height - Mask.height);
	}
	
	private function onScrollUp(e:MouseEvent):void {
		Main.app.removeEventListener(MouseEvent.MOUSE_UP, onScrollUp);
		scroll.stopDrag();
		scroll.removeEventListener(Event.ENTER_FRAME, onScrollMove);
		onScrollClick = false;
		onScrollOut();
	}
	
	private function changeScroll(percent:Number):void {
		scroll.y = (Mask.height - scroll.height) * percent;
	}
	
	private function onMouseOver(e:MouseEvent):void {
		this.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		TweenLite.to( sprite, 0.15, {x:0} );
	}
	
	private function onMouseOut(e:MouseEvent):void {
		this.removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		TweenLite.to( sprite, 0.15, {x:sprite.width} );
	}
	
	private function onMouseWheel(e:MouseEvent):void {
		var step:int = 24;
		var percent:Number = (sprite.height - Mask.height) / 100;
		if (e.delta > 0){
			if (sprite.y + step >= 0){
				sprite.y = 0;
				changeScroll(Math.abs(sprite.y / (sprite.height - Mask.height)));
				return;
			}
			sprite.y += step;
			changeScroll(Math.abs(sprite.y / (sprite.height - Mask.height)));
		} else {
			if (sprite.y + sprite.height - step <= Mask.height) {
				sprite.y = -sprite.height + Mask.height;
				changeScroll(Math.abs(sprite.y / (sprite.height - Mask.height)));
				return;
			}
			sprite.y -= step;
			changeScroll(Math.abs(sprite.y / (sprite.height - Mask.height)));
		}
	}
}

internal class IconsPanel extends Sprite
{
	public var settings:Object = {
		width:		100,
		height:		30,
		maskWidth:	100,
		maskHeight:	400
	};
	public var Buttons:Array = new Array();
	private var backing:Shape = new Shape();
	public var sprite:Sprite = new Sprite();
	private var background:Shape = new Shape();
	public var back:Sprite = new Sprite();
	public var Mask:Shape = new Shape();
	public function IconsPanel(animes:Object, callback:Function, settings:Object = null ) {
		if (settings != null){
			for (var itm:* in settings) {
				this.settings[itm] = settings[itm];
			}
		}
		
		sprite.mask = Mask;
		back.addChild(background);
		sprite.addChild(backing);
		addChild(Mask);
		addChild(back);
		addChild(sprite);
		
		
		for (var item:* in animes){
			var button: Button = new Button( {
				label:		String(item),
				width:		this.settings.width,
				height:		this.settings.height,
				click:		callback,
				onClickParams: {'name':String(item)}
			} );
			button.name = String(item);
			Buttons.push(button);
			sprite.addChild(button);
			button.y = (button.height + 5) * Buttons.indexOf(button);
		}
		
		Mask.graphics.beginFill(0xff0000, 0.5);
		Mask.graphics.drawRect(0,0,sprite.width,settings.maskHeight);
		Mask.graphics.endFill();
		
		backing.graphics.beginFill(0x595959, 0.5);
		backing.graphics.drawRect(0, 0, sprite.width, sprite.height);
		backing.graphics.endFill();
		
		background.graphics.beginFill(0x595959, 0.5);
		if(sprite.height > Mask.height){
			background.graphics.drawRect(0, 0, sprite.width, Mask.height);
		}else{
			background.graphics.drawRect(0, 0, sprite.width, sprite.height);
		}
		background.graphics.endFill();
		
		sprite.x = sprite.width;
		
		back.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
		
		if (sprite.height > Mask.height){
			sprite.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		} else {
			sprite.y = Mask.height - sprite.height;
			back.y = Mask.height - back.height;
		}
		
		drawScroll();
	}
	
	public function dispose():void {
		sprite.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		
		for (var i:int = numChildren - 1; i >= 0; i--){
			var child:* = getChildAt(i);
			if (child is Button){
				child.dispose();
				removeChild(child);
				child = null;
			}else{
				removeChild(child);
				child = null;
			}
		}
	}
	
	private var scrollSprite:Sprite = new Sprite();
	private var scrollLabel:Shape = new Shape();
	private var scroll:Sprite = new Sprite();
	private var scrollBack:Shape = new Shape();
	private function drawScroll():void {
		addChild(scrollSprite);
		scrollSprite.x = Mask.x + Mask.width;
		scrollSprite.y = Mask.y;
		
		scrollBack.graphics.beginFill(0x595959, 0.5);
		if(sprite.height > Mask.height){
			scrollBack.graphics.drawRect(0, 0, 5, Mask.height);
		}else{
			scrollBack.graphics.drawRect(0, 0, 5, sprite.height);
		}
		scrollBack.graphics.endFill();
		scrollSprite.addChild(scrollBack);
		
		scrollLabel.graphics.beginFill(0xFFFFFF, 0.5);
		if(sprite.height > Mask.height){
			scrollLabel.graphics.drawRect(0, 0, 5, Mask.height / 5);
			scroll.addEventListener(MouseEvent.MOUSE_DOWN, onScrollDown);
		}else{
			scrollLabel.graphics.drawRect(0, 0, 5, sprite.height);
		}
		scrollLabel.graphics.endFill();
		
		scroll.addChild(scrollLabel);
		
		scroll.addEventListener(MouseEvent.ROLL_OVER, onScrollOver);
		
		scrollSprite.addChild(scroll);
		
		if(sprite.height < Mask.height){
			scrollBack.y = scrollLabel.y = Mask.height - scrollLabel.height;
		}
	}
	
	private var onScrollClick:Boolean = false;
	private function onScrollDown(e:MouseEvent):void {
		Main.app.addEventListener(MouseEvent.MOUSE_UP, onScrollUp);
		scroll.startDrag(false, new Rectangle(scrollBack.x, scrollBack.y, scrollBack.x, scrollBack.height - scroll.height));
		scroll.addEventListener(Event.ENTER_FRAME, onScrollMove);
		onScrollClick = true;
	}
	
	private function onScrollOver(e:MouseEvent):void {
		scrollLabel.graphics.clear();
		scrollLabel.graphics.beginFill(0x65a9d0, 0.8);
		if(sprite.height > Mask.height){
			scrollLabel.graphics.drawRect(0, 0, 5, Mask.height / 5);
		}else{
			scrollLabel.graphics.drawRect(0, 0, 5, sprite.height);
		}
		scrollLabel.graphics.endFill();
		scroll.addEventListener(MouseEvent.ROLL_OUT, onScrollOut);
	}
	
	private function onScrollOut(e:MouseEvent = null):void {
		if(!onScrollClick){
			scroll.removeEventListener(MouseEvent.ROLL_OUT, onScrollOut);
			scrollLabel.graphics.clear();
			scrollLabel.graphics.beginFill(0xFFFFFF, 0.5);
			if(sprite.height > Mask.height){
				scrollLabel.graphics.drawRect(0, 0, 5, Mask.height / 5);
			}else{
				scrollLabel.graphics.drawRect(0, 0, 5, sprite.height);
			}
			scrollLabel.graphics.endFill();
		}
	}
	
	private function onScrollMove(e:Event):void {
		sprite.y = -scroll.y / (Mask.height - scroll.height) * (sprite.height - Mask.height);
	}
	
	private function onScrollUp(e:MouseEvent):void {
		Main.app.removeEventListener(MouseEvent.MOUSE_UP, onScrollUp);
		scroll.stopDrag();
		scroll.removeEventListener(Event.ENTER_FRAME, onScrollMove);
		onScrollClick = false;
		onScrollOut();
	}
	
	private function changeScroll(percent:Number):void {
		scroll.y = (Mask.height - scroll.height) * percent;
	}
	
	private function onMouseOver(e:MouseEvent):void {
		this.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		TweenLite.to( sprite, 0.15, {x:0} );
	}
	
	private function onMouseOut(e:MouseEvent):void {
		this.removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		TweenLite.to( sprite, 0.15, {x:sprite.width} );
	}
	
	private function onMouseWheel(e:MouseEvent):void {
		var step:int = 24;
		var percent:Number = (sprite.height - Mask.height) / 100;
		if (e.delta > 0){
			if (sprite.y + step >= 0){
				sprite.y = 0;
				changeScroll(Math.abs(sprite.y / (sprite.height - Mask.height)));
				return;
			}
			sprite.y += step;
			changeScroll(Math.abs(sprite.y / (sprite.height - Mask.height)));
		} else {
			if (sprite.y + sprite.height - step <= Mask.height) {
				sprite.y = -sprite.height + Mask.height;
				changeScroll(Math.abs(sprite.y / (sprite.height - Mask.height)));
				return;
			}
			sprite.y -= step;
			changeScroll(Math.abs(sprite.y / (sprite.height - Mask.height)));
		}
	}
}