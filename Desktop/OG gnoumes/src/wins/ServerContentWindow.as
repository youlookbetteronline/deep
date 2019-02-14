package wins 
{
	import enixan.Size;
	import enixan.Util;
	import enixan.components.List;
	import enixan.components.ListNode;
	import enixan.components.Button;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filesystem.File;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	public class ServerContentWindow extends wins.Window 
	{
		
		public static var instance:ServerContentWindow;
		
		private var pathview:Pathview;
		private var filelist:FileList;
		private var titleLabel:TextField;
		private var searchLabel:TextField;
		
		public function ServerContentWindow(params:Object=null) 
		{
			if (!params) params = { };
			
			params.width = 700;
			params.height = 700;
			
			super(params);
			
			Main.app.appStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboard);
			
			instance = this;
		}
		
		
		override public function close(e:MouseEvent = null):void {
			Main.app.appStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyboard);
			instance = null;
			
			super.close(e);
		}
		
		
		override public function draw():void {
			
			super.draw();
			
			titleLabel = Util.drawText( {
				text:		'Серверный контент',
				size:		42,
				color:		0xffffff
			});
			titleLabel.x = params.width * 0.5 - titleLabel.width * 0.5;
			titleLabel.y = 7;
			container.addChild(titleLabel);
			
			pathview = new Pathview(params.width - 100, 50, onFolderChangeStart);
			pathview.x = 50;
			pathview.y = 80;
			container.addChild(pathview);
			
			filelist = new FileList(Main.app.appStage, 600, 500, {
				backgroundAlpha:	0
			} );
			filelist.x = 50;
			filelist.y = 120;
			container.addChild(filelist);
			
			searchLabel = Util.drawText( {
				text:			'',
				color:			0x111111,
				size:			16,
				width:			300,
				height:			24,
				border:			true,
				borderColor:	0x999999,
				background:		true,
				backgroundColor:0xeeeeee,
				leftMargin:		2,
				rightMargin:	2,
				type:			TextFieldType.INPUT,
				embedFonts:		false
			});
			searchLabel.x = filelist.x;
			searchLabel.y = filelist.y + 520;
			searchLabel.addEventListener(TextEvent.TEXT_INPUT, onSearchInput);
			container.addChild(searchLabel);
			
			onFolderChangeStart(ServerManager.path);
			
			Main.app.appStage.focus = searchLabel;
		}
		
		
		private function onKeyboard(e:KeyboardEvent):void {
			if (Main.app.appStage.focus is TextField) {
				if (e.keyCode == Keyboard.ENTER) {
					if (filelist && filelist.content.length > 0) {
						var item:Object = filelist.content[0];
						onFolderChangeStart(ServerManager.path + ServerManager.separator + item.data.text);
					}
				}
			}else{
				if (e.keyCode == Keyboard.BACKSPACE) {
					var path:String = ServerManager.path;
					var index:int = path.lastIndexOf(ServerManager.separator);
					if (index < 1) return;
					onFolderChangeStart(path.substring(0, index));
				}
			}
		}
		
		
		
		/**
		 * Загрузка на сервер
		 * @param	object
		 */
		private var uploadBlock:Boolean;
		public function load(object:Object):void {
			if (!object || !(object is Array) || uploadBlock) return;
			
			var list:Array = object as Array;
			var uploadList:Array = [];
			
			if (list.length > 0) {
				uploadBlock = true;
				uploadFiles(list);
			}
		}
		private function uploadFiles(list:Array):void {
			if (list.length > 0) {
				var file:File = list.shift() as File;
				if (file && file.exists && ((file.type == Main.SWF && ServerManager.path.indexOf('/swf/') > 0) || (file.type == Main.PNG && ServerManager.path.indexOf('/icons/store/') > 0))) {
					var bytes:ByteArray = Files.open(file);
					Main.app.server.upload([ { path:ServerManager.path + ServerManager.separator + file.name, bytes:bytes } ], function():void {
						MessageView.message('Загрузка файла ' + file.name + ' завершена!');
						uploadFiles(list);
					}, function():void {
						MessageView.message('Файл не загружен: ' + file.name, { fontColor:0xff0000 } );
						uploadFiles(list);
					});
				}else {
					setTimeout(uploadFiles, 5, list);
				}
			}else {
				uploadBlock = false;
				onFolderChangeStart(ServerManager.path, true);
			}
		}
		
		
		
		/**
		 * Поиск файла по имени
		 */
		private var searchTimeout:int;
		private var firstSearchName:String;
		private var filterText:String;
		private function onSearchInput(e:TextEvent):void {
			if (searchTimeout) return;
			firstSearchName = null;
			searchTimeout = setTimeout(onSearchTick, 10);
		}
		private function onSearchTick():void {
			searchTimeout = 0;
			if (!dictionary) return;
			onFolderChange(dictionary, searchLabel.text.toLowerCase());
		}
		private function clearSearch():void {
			firstSearchName = null;
			searchLabel.text = '';
		}
		private function focusSearch():void {
			Main.app.appStage.focus = searchLabel;
		}
		
		
		
		
		
		private var dictionary:Object;
		private function onFolderChange(dictionary:*, filter:String = null):void {
			pathview.show(ServerManager.path);
			
			this.dictionary = dictionary;
			
			var list:Array = [];
			
			for (var s:* in dictionary.content) {
				var object:Object = dictionary.content[s];
				
				if (filter) {
					var index:int = object.name.toLowerCase().indexOf(filter);
					if (index < 0)
						continue;
					
					if (!firstSearchName)
						firstSearchName = object.name;
				}
				
				list.push( {
					text:		object.name,
					dir:		object.dir,
					time:		object.time,
					size:		object.size,
					click:		onFileClick,
					
					color:		getColor(object)
				});
			}
			list.sort(filesort);
			
			filelist.clear();
			filelist.addAll(list);
			removePreloader();
			focusSearch();
			
			function filesort(object1:Object, object2:Object):int {
				if (object1.dir > object2.dir)
					return -1;
				
				if (object1.dir < object2.dir)
					return 1;
				
				if (object1.dir == object2.dir) {
					if (object1.time > object2.time)
						return -1;
					
					if (object1.time < object2.time)
						return 1;
				}
				
				return 0;
			}
		}
		
		private function onFileClick(item:ListNode):void {
			if (!item.data.dir) return;
			
			onFolderChangeStart(ServerManager.path + ServerManager.separator + item.data.text);
		}
		private function onFolderChangeStart(path:String, update:Boolean = false):void {
			filelist.clear();
			addPreloader();
			Main.app.server.changeFolder(path, onFolderChange, update);
			clearSearch();
		}
		
		
		private var preloader:Preloader;
		private function addPreloader():void {
			if (preloader) return;
			preloader = new Preloader();
			preloader.x = filelist.x + 250;
			preloader.y = filelist.y + 250;
			container.addChild(preloader);
		}
		private function removePreloader():void {
			if (!preloader) return;
			if (preloader.parent == container)
				container.removeChild(preloader);
			preloader = null;
		}
		private function getColor(object:Object):uint {
			if (!object.dir)
				return 0x777777;
			
			if (ProjectManager.serverProjects.indexOf(object.name) > -1)
				return 0xa37718;
			
			if (object.name == 'icons' || object.name == 'store' || object.name == 'swf' || object.name == 'resources' || object.name == 'public_html')
				return 0xa37718;
			
			return 0xefb537;
		}
	}

}

import adobe.utils.CustomActions;
import enixan.Size;
import enixan.Util;
import enixan.components.Button;
import enixan.components.List;
import enixan.components.ListNode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.text.TextField;

internal class Pathview extends Sprite {
	
	private var colors:Object = {
		Dreams:		0xffff00
	}
	
	private var color:uint = 0x666666;
	private var currWidth:int;
	private var currHeight:int;
	private var onChange:Function;
	
	public var items:Vector.<PathviewItem> = new Vector.<PathviewItem>;
	
	public function Pathview(width:int, height:int, onChange:Function, path:String = null) {
		
		currWidth = width;
		currHeight = height;
		
		this.onChange = onChange;
		
		show(path || '/');
	}
	
	public function show(path:String = null):void {
		if (!path) return;
		
		var list:Array = path.split(ServerManager.separator);
		var lastIndex:int = 0;
		var cleared:Boolean;
		var previewPath:Array = [];
		var totalWidth:int = 0;
		
		for (var i:int = 0; i < list.length; i++) {
			previewPath[i] = list[i];
			
			if (!list[i] || list[i] == '' || list[i] == '.') continue;
			
			var find:Boolean = false;
			for (lastIndex; lastIndex < items.length; lastIndex++) {
				if (items[lastIndex].text == list[i]) {
					totalWidth = items[lastIndex].x + items[lastIndex].width + 4;
					find = true;
					lastIndex++;
					break;
				}
			}
			if (find) continue;
			
			if (!cleared) {
				clearItemsAfter(lastIndex);
				cleared = true;
			}
			
			var item:PathviewItem = new PathviewItem( {
				text:		list[i],
				color:		color,
				index:		i - 1,
				path:		previewPath.join(ServerManager.separator),
				click:		onChange
			});
			item.x = totalWidth;
			addChild(item);
			items.push(item);
			totalWidth += item.width + 4;
		}
		
		if (!cleared)
			clearItemsAfter(lastIndex);
	}
	public function clearItemsAfter(index:int):void {
		while (items.length > index) {
			items.pop().dispose();
		}
	}
	
	public function dispose():void {
		while (items.length)
			items.shift().dispose();
	}
}

internal class PathviewItem extends Sprite {
	
	public var backing:Shape;
	public var textLabel:TextField;
	private var data:Object;
	
	public function PathviewItem(data:Object) {
		
		this.data = data;
		
		backing = new Shape();
		addChild(backing);
		
		textLabel = Util.drawText( {
			text:		text,
			color:		0xffffff,
			size:		14
		});
		textLabel.x = 5;
		addChild(textLabel);
		
		backing.graphics.beginFill(0x999999);
		backing.graphics.drawRect(0, 0, int(textLabel.width + 10), int(textLabel.height + 2));
		backing.graphics.endFill();
		
		addEventListener(MouseEvent.CLICK, onClick);
		
	}
	
	public function get text():String {
		return data.text;
	}
	public function get index():int {
		return data.index;
	}
	public function get path():String {
		return data.path;
	}
	
	private function onClick(e:MouseEvent):void {
		if (data.click != null)
			data.click(path, true);
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		
		if (parent)
			parent.removeChild(this);
	}
	
}

internal class FileList extends List {
	
	public function FileList(stage:Stage, width:int, height:int, params:Object=null) 
	{
		if (!params) params = { };
		
		params.haveScroller = true;
		params.backgroundAlpha = 0;
		
		super(stage, width, height, params);
		
		nodeHeight = 26;
		blockDrag = true;
		
	}
	override public function add(info:Object, update:Boolean = false):void {
		
		if (update)
			data.push(info);
		
		var node:FileNode = new FileNode(this, info);
		node.y = container.numChildren * (nodeHeight + params.indent);
		container.addChild(node);
		content.push(node);
	}
}

internal class FileNode extends ListNode {
	
	private var loadBttn:Button;
	
	public function FileNode(list:List, data:Object) 
	{
		//data.textSize = 11;
		//data.textAlign = 'center';
		//data.textWidth = list.nodeWidth - 4;
		
		super(list, data);
		
		
	}
	
	override public function draw():void {
		super.draw();
		
		titleLabel.x = 15;
		titleLabel.y = 0;
		titleLabel.width = 250;
		//titleLabel.height = 26;
		titleLabel.multiline = false;
		
		var typeLabel:TextField = Util.drawText( {
			width:		100,
			text:		(data.dir) ? 'DIR' : ((data.size > 0) ? String(data.size) + ' bytes' : ''),
			size:		14,
			color:		0xffffff
		});
		typeLabel.x = titleLabel.x + titleLabel.width;
		typeLabel.y = 2;
		addChild(typeLabel);
		
		var date:Date = new Date();
		date.setTime(data.time * 1000);
		var dateValue:String = date.getFullYear() + '.' + Size.zero(date.getMonth() + 1) + '.' + Size.zero(date.getDate()) + ' ' + date.getHours() + ':' + Size.zero(date.getMinutes()) + ':' + Size.zero(date.getSeconds());
		
		var timeLabel:TextField = Util.drawText( {
			width:		120,
			text:		(data.time) ? dateValue : '',
			size:		12,
			color:		0xffffff
		});
		timeLabel.x = typeLabel.x + typeLabel.width;
		timeLabel.y = 4;
		addChild(timeLabel);
		
	}
	
	override public function focus(passive:Boolean = false):void {
		super.focus(passive);
		
		if (loadBttn || data.dir) return;
		
		loadBttn = new Button( {
			label:		'Загрузить',
			width:		68,
			height:		22,
			click:		load
		});
		loadBttn.x = list.currWidth - loadBttn.width - 4;
		loadBttn.y = 2;
		addChild(loadBttn);
	}
	override public function unfocus():void {
		super.unfocus();
		
		if (loadBttn && !preloader) {
			removeChild(loadBttn);
			loadBttn.dispose();
			loadBttn = null;
		}
	}
	
	private var preloader:Preloader;
	private function load():void {
		
		var path:String = ServerManager.path + ServerManager.separator + data.text;
		if (!Main.app.server.browser.checkDirectory(path)) return;
		
		loadBttn.state = Button.DISABLE;
		loadBttn.label = '0%';
		
		//preloader = new Preloader();
		//preloader.scaleX = preloader.scaleY = 0.6;
		//preloader.x = loadBttn.x + 10;
		//preloader.y = loadBttn.y + loadBttn.height * 0.5;
		//addChild(preloader);
		
		Main.app.server.send(ServerManager.DOWNLOAD, { path:path }, function():void {
			loadBttn.state = Button.NORMAL;
			loadBttn.label = 'Загрузить';
		
			// Настройка параметров проекта
			var array:Array = path.split('/');
			if (array.length >= 7 && array[1] == 'home' && array[3] == 'public_html' && array[4] == 'resources' && array[5] == 'swf' && array[array.length - 1].indexOf(Main.SWF) != -1) {
				ProjectManager.project = array[2];
				ProjectManager.view = array[6];
				Main.storage.projName = data.text.substring(0, data.text.length - 4);
			}
			
			//if (preloader) removeChild(preloader);
		}, null, function(progress:Number):void {
			loadBttn.label = String(int(100 * progress)) + '%';
		});
	}
	
}