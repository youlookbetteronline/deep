package 
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import wins.PreviewWindow;
	
	public class ProjectManager 
	{
		
		public static var serverProjects:Array;
		public static var views:Array;
		public static var projectLastChecked:Array;
		
		public static function init():void {
			if (!Main.storage.serverProject) Main.storage.serverProject = { };
			
			projectLastChecked = (Main.storage.serverProject.projectLastChecked is Array) ? Main.storage.serverProject.projectLastChecked : [];
			views = (Main.storage.serverProject.viewsLastChecked is Array) ? Main.storage.serverProject.viewsLastChecked : [];
			
			if (Main.storage.serverProject.project) __project = Main.storage.serverProject.project;
			if (Main.storage.serverProject.view) __view = Main.storage.serverProject.view;
			
			//__project = null;
			//__view = null;
			
			var projectFile:File = File.applicationDirectory.resolvePath('projects.txt');
			var data:String = Files.openText(projectFile, true);
			serverProjects = data.split(String.fromCharCode(13,10));
		}
		
		
		
		private static var __project:String;
		public static function set project(value:String):void {
			if (addLastChecked(value)) {
				__project = value;
				
				Main.storage.serverProject.project = __project;
				Main.storage.serverProject.projectLastChecked = projectLastChecked;
				Main.app.saveStorage(5000);
			}
		}
		public static function get project():String {
			return __project;
		}
		private static function addLastChecked(value:String):Boolean {
			if (!value) value = '';
			var index:int = serverProjects.indexOf(value.toLowerCase());
			if (index >= 0) {
				if (index > 0)
					serverProjects.unshift(serverProjects.splice(index, 1)[0]);
				
				return true;
			}
			
			return false;
		}
		
		
		
		/**
		 * Получить список видов для проекта
		 */
		public static function getViewByProject(project:String, callback:Function = null):void {
			
			if (!project || serverProjects.indexOf(project) < 0) return;
			
			var path:String = '/home/' + project + '/public_html/resources/swf/';
			Main.app.server.folderList(path, function(object:Object):void {
				if (!object || !object.content || !(object.content is Dictionary)) return;
				
				var previews:Array = [];
				var dictionary:Dictionary = object.content;
				
				// Добвление загруженных видов
				for (var key:String in dictionary)
					previews.push(key);
				
				// Объединение их с используемыми видами
				for (var i:int = 0; i < views.length; i++) {
					var index:int = previews.indexOf(views[i]);
					if (index >= 0) previews.splice(index, 1);
				}
				previews = views.concat(previews);
				
				callback(previews);
			});
		}
		
		
		
		
		private static var __view:String;
		private static var __viewVacant:String;
		public static function get view():String {
			return __view;
		}
		public static function set view(value:String):void {
			if (!value || value.length == 0) return;
			if (__view == value) return;
			__viewVacant = value;
			
			var path:String = '/home/' + project + '/public_html/resources/swf/';
			var previews:Array = [];
			
			Main.app.server.folderList(path, onComplete);
			
			function onComplete(list:Object):void {
				if (!list || !list.content) return;
			
				var dictionary:Dictionary = list.content;
				var findKey:String;
				
				for (var key:String in dictionary) {
					previews.push(key);
					
					if (key.toLowerCase() == __viewVacant.toLowerCase())
						findKey = key;
					
				}
				
				if (!findKey) {
					Alert.yesLabel = 'Создать';
					Alert.noLabel = 'Отмена';
					Alert.show('Вида ' + __viewVacant + ' не существует', Main.appName, Alert.YES | Alert.NO, null, function(e:CloseEvent):void {
						if (e.detail == Alert.YES)
							chacked(__viewVacant);
						
						if (e.detail == Alert.NO)
							if (PreviewWindow.instance)
								PreviewWindow.instance.viewDrop.text = '';
						
						__viewVacant = null;
					});
					return;
				}
				
				chacked(findKey);
				
				__viewVacant = null;
			}
			
			function chacked(value:String):void {
				__view = value;
				
				var index:int = views.indexOf(value);
				if (index > 0) views.splice(index, 1);
				views.unshift(value);
				
				// Вырезать из остачи
				for (var i:int = 0; i < views.length; i++) {
					index = previews.indexOf(views[i]);
					if (index >= 0)
						previews.splice(index, 1);
				}
				
				previews = views.concat(previews);
				
				if (wins.PreviewWindow.instance) {
					wins.PreviewWindow.instance.viewDrop.text = value;
					wins.PreviewWindow.instance.viewDrop.updateList(previews, true);
				}
				
				Main.storage.serverProject.view = value;
				Main.storage.serverProject.viewsLastChecked = views;
				Main.app.saveStorage(5000);
			}
			
		}
		
	}

}