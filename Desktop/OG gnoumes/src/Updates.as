package 
{
	import enixan.Compiler;
	import enixan.Util;
	import flash.desktop.NativeApplication;
	import flash.desktop.Updater;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	public class Updates 
	{
		
		public static const	versionFileLink:String = 'http://dreams.islandsville.com/gfx/version.vsn';
		public static const	applicationFileLink:String = 'http://dreams.islandsville.com/gfx/ObjectGenerator.exe';
		public static var serverVersion:String;
		
		public static function check(applicationName:String = 'application', link:String = null, applink:String = null):void {
			if (!link || !applink) return;
			
			//return;
			
			appLink = applink;
			
			var xml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = xml.namespace();
			serverVersion = /*'0.20'; */xml.ns::versionNumber;
			
			var currVersionList:Array = serverVersion.split('.');
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.load(new URLRequest(link));
			
			function onLoadComplete(e:Event):void {
				var data:String = e.target.data;
				
				if (data.indexOf(applicationName) == -1) return;
				data = data.substring(data.indexOf(applicationName) + applicationName.length, data.indexOf('\n', data.indexOf(applicationName)));
				data = data.replace(/[^0-9.]/gi, '');
				
				if (!data || data.length == 0) return;
				
				/*var servVersionList:Array = data.split('.');
				
				for (var i:int = 0; i < servVersionList.length; i++) {
					if (int(servVersionList[i]) > int(currVersionList[i])) {
						askForUpdate(data, serverVersion);
						return;
					}else if (int(servVersionList[i]) < int(currVersionList[i])) {
						return;
					}
				}*/
			}
			function onLoadError(e:IOErrorEvent):void {
				MessageView.message('Данные по новым версиям не обновились');
			}
		}
		
		public static function askForUpdate(serverVersion:String, currentVersion:String):void {
			//return;
			//Alert.okLabel = 'Обновить';
			//Alert.yesLabel = 'Сохранить';
			//Alert.noLabel = 'Отмена';
			//Alert.buttonWidth = 80;
			//Alert.show('Текущая версия: ' + currentVersion.toString() + '\nСерверная версия: ' + serverVersion.toString(), 'Обновление', Alert.YES | Alert.OK | Alert.NO, null, startUpdate);
		}
		
		private static var appLink:String;
		private static var appAtFolder:Boolean;
		private static function startUpdate(object:CloseEvent):void {
			switch(object.detail) {
				case Alert.OK:
					updateAt(File.cacheDirectory);
					break;
				case Alert.YES:
					Files.openDirectory(function(folder:File):void {
						appAtFolder = true;
						updateAt(folder);
					}, File.applicationDirectory.nativePath, null, 'Директория для загрузки обновления');
					break;
			}
		}
		private static function updateAt(folder:File):void {
			if (!folder || !folder.exists || !folder.isDirectory) return;
			
			var file:File = folder.resolvePath(Main.appName + Main.EXE);
			if (file.exists) file.deleteFile();
			
			Files.downloadFile(appLink + '?' + String(new Date().getTime()), file, {
				complete:onComplete,
				progress:onProgress,
				error:onError
			});
			
			function onComplete(... args):void {
				Main.app.hideMainProgress();
				
				if (appAtFolder) {
					folder.openWithDefaultApplication();
				}else {
					file.openWithDefaultApplication();
				}
				
				appAtFolder = false;
				
				NativeApplication.nativeApplication.exit();
			}
			function onProgress(value:Number):void {
				Main.app.showMainProgress(value, 'Обновление');
			}
			function onError(... args):void {
				Main.app.hideMainProgress();
			}
		}
		
	}

}