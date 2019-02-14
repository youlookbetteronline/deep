package wins 
{
	import com.adobe.crypto.MD5;
	import enixan.Color;
	import enixan.Compiler;
	import enixan.Util;
	import enixan.components.Button;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import wins.Window;
	
	public class HistoryWindow extends Window 
	{
		
		private var preloader:Preloader;
		private var titleLabel:TextField;
		
		private var projectContainer:Sprite;
		
		public function HistoryWindow(params:Object=null) 
		{
			if (!params) params = { };
			
			params.width = 900;
			params.height = 700;
			
			super(params);
			
		}
		
		override public function draw():void {
			
			super.draw();
			
			titleLabel = Util.drawText( {
				text:		'История',
				size:		42,
				color:		0xffffff
			});
			titleLabel.x = params.width * 0.5 - titleLabel.width * 0.5;
			titleLabel.y = 7;
			container.addChild(titleLabel);
			
			start();
			
		}
		
		private function start():void {
			addPreloader();
			initRemote();
		}
		
		
		// Загружчик
		private function addPreloader():void {
			preloader = new Preloader();
			preloader.x = params.width * 0.5 - 40;
			preloader.y = params.height * 0.5;
			container.addChild(preloader);
		}
		private function removePreloader():void {
			if (preloader) {
				if (preloader.parent) preloader.parent.removeChild(preloader);
				preloader = null;
			}
		}
		
		
		// Удаленное хранилище
		private var remoteList:Array;
		private function initRemote():void {
			
			Files.readFolderAsync(Compiler.remote, function(list:Array):void {
				removePreloader();
				remoteList = list;
				remoteList.sort(sortAsImportant);
				createProjectPanel();
			}, function():void {
				removePreloader();
				trace();
			});
			
		}
		
		
		
		/**
		 * Сортировка по важности
		 */
		private function sortAsImportant(f1:File, f2:File):int {
			if (f1.name > f2.name)
				return 1;
			
			if (f1.name < f2.name)
				return -1;
			
			return 0;
		}
		
		
		
		private var projectPanel:ProjectPanel;
		private function createProjectPanel():void {
			if (!projectPanel) {
				projectPanel = new ProjectPanel(Main.app.appStage, params.width - 60, 30, {
					click:		onProjectSelect
				});
				projectPanel.x = 30;
				projectPanel.y = 80;
				container.addChild(projectPanel);
			}
			
			var list:Array = [];
			for (var i:int = 0; i < remoteList.length; i++) {
				var md5:String = MD5.hash(remoteList[i].name);
				
				list.push( {
					width:	80,
					height:	30,
					text:	remoteList[i].name,
					file:	remoteList[i],
					color:	parseInt(md5.substring(0,6), 16)
				} );
			}
			
			projectPanel.clear();
			projectPanel.addAll(list);
		}
		private function onProjectSelect(node:*):void {
			onProjectLoad(node.data.file);
		}
		
		
		private var reading:Boolean;
		private var srcFiles:Array = [];
		private var projectFiles:Array = [];
		private var projectIndex:int;
		private function onProjectLoad(folder:File):void {
			if (reading || !folder || !folder.exists) return;
			
			addPreloader();
			
			if (projetcList)
				projetcList.clear();
			
			reading = true;
			srcFiles.length = 0;
			
			Files.readFolderAsync(folder, onOpenMain, onErrorMain);
		}
		private function onOpenMain(list:Array):void {
			srcFiles = list;
			projectFiles.length = 0;
			projectIndex = 0;
			nodesLoad();
		}
		private function onErrorMain():void {
			reading = false;
		}
		
		private function nodesLoad():void {
			Files.readFolderAsync(srcFiles[projectIndex], onNodeComplete, onNodeError);
		}
		private function onNodeComplete(list:Array):void {
			projectFiles = projectFiles.concat(list);
			projectIndex++;
			checkComplete();
		}
		private function onNodeError():void {
			projectIndex++;
			checkComplete();
		}
		private function checkComplete():void {
			if (projectIndex < srcFiles.length) {
				setTimeout(nodesLoad, 40);
				return;
			};
			
			reading = false;
			
			updateProjectsList();
		}
		
		
		
		private var projetcList:ProjectsList;
		private function updateProjectsList():void {
			removePreloader();
			
			var list:Array = [];
			for (var i:int = 0; i < projectFiles.length; i++) {
				list.push({ file:projectFiles[i], modification:projectFiles[i].modificationDate.getTime() });
				//list.push({ file:projectFiles[i], modification:Date.UTC(projectFiles[i].modificationDate.getFullYear(), projectFiles[i].modificationDate.getMonth(), projectFiles[i].modificationDate.getDate(), projectFiles[i].modificationDate.getHours(), projectFiles[i].modificationDate.getMinutes() ) });
			}
			
			list.sortOn('modification', Array.NUMERIC | Array.DESCENDING);
			
			if (!projetcList) {
				projetcList = new ProjectsList(Main.app.appStage, params.width - 60, params.height - 150, { nodeHeight:26 });
				projetcList.x = 30;
				projetcList.y = 120;
				container.addChild(projetcList);
			}
			
			projetcList.addAll(list);
			
		}
		
		override public function close(e:MouseEvent = null):void {
			super.close(e);
		}
		
	}

}

import enixan.Size;
import enixan.Util;
import enixan.components.Button;
import enixan.components.List;
import enixan.components.ListNode;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import mx.controls.Alert;
import wins.Window;

internal class ProjectsList extends List {
	
	public function ProjectsList(stage:Stage, width:int, height:int, params:Object=null) 
	{
		if (!params) params = { };
		
		params.haveScroller = true;
		
		super(stage, width, height, params);
		
		nodeHeight = 30;
		blockDrag = true;
		
	}
	override public function add(info:Object, update:Boolean = false):void {
		
		if (update)
			data.push(info);
		
		var node:ProjectNode = new ProjectNode(this, {
			height:30,
			color:0x555555,
			item:info
		});
		node.y = container.numChildren * (nodeHeight + params.indent);
		container.addChild(node);
		content.push(node);
	}
}

internal class ProjectNode extends ListNode {
	
	private var loadBttn:Button;
	
	public function ProjectNode(list:List, data:Object) 
	{
		data.textSize = 11;
		data.textAlign = 'center';
		data.textWidth = list.nodeWidth - 4;
		
		super(list, data);
	}
	
	override public function draw():void {
		super.draw();
		
		var textFormat:TextFormat = titleLabel.getTextFormat();
		textFormat.align = TextFormatAlign.LEFT;
		textFormat.size = 20;
		
		titleLabel.x = 15;
		titleLabel.y = 0;
		titleLabel.width = 380;
		titleLabel.height = 26;
		titleLabel.multiline = false;
		titleLabel.defaultTextFormat = textFormat;
		titleLabel.text = data.item.file.name;
		
		
		var date:Date = data.item.file.modificationDate;
		var dateString:String = date.getFullYear() + '.' + Size.zero(date.getMonth() + 1) + '.' + Size.zero(date.getDate()) + ' ' + Size.zero(date.getHours()) + ':' + Size.zero(date.getMinutes()) + '.' + Size.zero(date.getSeconds());
		var dateLabel:TextField = Util.drawText( {
			text:			dateString,
			color:			0xffffff,
			width:			200,
			textAlign:		TextFormatAlign.LEFT
		});
		dateLabel.x = 400;
		dateLabel.y = 4;
		addChild(dateLabel);
		
	}
	
	override public function focus(passive:Boolean = false):void {
		super.focus(passive);
		
		if (loadBttn) return;
		loadBttn = new Button( {
			label:		'Загрузить',
			width:		68,
			height:		22,
			click:		load
		});
		loadBttn.x = list.currWidth - loadBttn.width - 4;
		loadBttn.y = 4;
		addChild(loadBttn);
	}
	override public function unfocus():void {
		super.unfocus();
		
		if (loadBttn) {
			removeChild(loadBttn);
			loadBttn.dispose();
			loadBttn = null;
		}
	}
	
	private function load():void {
		loadBttn.state = Button.DISABLE;
		
		Main.app.parseProject(data.item.file, function():void {
			Window.closeAll();
		}, function():void {
			if (loadBttn) loadBttn.state = Button.NORMAL;
		});
	}
	
}