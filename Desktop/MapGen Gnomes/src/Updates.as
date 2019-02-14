package 
{
	import flash.desktop.NativeApplication;
	import flash.desktop.Updater;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	public class Updates 
	{
		
		public static var serverVersion:String;
		
		public static function check(currentVersion:String = '0', applicationName:String = 'application', link:String = null, applink:String = null):void {
			if (!link || !applink) return;
			
			appLink = applink;
			
			var xml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = xml.namespace();
			serverVersion = xml.ns::versionNumber;
			
			var currVersionList:Array = serverVersion.split('.');
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			/*loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(e:*):void {
				trace(e);
			});*/
			loader.load(new URLRequest(link));
			
			function onLoadComplete(e:Event):void {
				var data:String = e.target.data;
				
				if (data.indexOf(applicationName) == -1) return;
				data = data.substring(data.indexOf(applicationName) + applicationName.length, data.indexOf('\n'));
				data = data.replace(/[^0-9.]/gi, '');
				
				if (!data || data.length == 0) return;
				
				var servVersionList:Array = data.split('.');
				
				for (var i:int = 0; i < servVersionList.length; i++) {
					if (int(servVersionList[i]) > int(currVersionList[i])) {
						askForUpdate(data, serverVersion);
						return;
					}else if (int(servVersionList[i]) < int(currVersionList[i])) {
						return;
					}
				}
			}
			function onLoadError(e:IOErrorEvent):void {
				//trace(e);
			}
		}
		
		public static function askForUpdate(serverVersion:String, currentVersion:String):void {
			Alert.show('Текещая версия: ' + currentVersion.toString() + '\nСерверная внрсия: ' + serverVersion.toString(), 'Обновление', 3, null, startUpdate);
		}
		
		private static var appLink:String;
		private static function startUpdate(object:CloseEvent):void {
			if (object.detail != 1) return; // Не YES
			
			var temp:File = new File(File.applicationDirectory.nativePath + File.separator + 'MapGenerator.air');
			
			Files.downloadFile(appLink, temp, {
				complete:onComplete,
				progress:onProgress,
				error:onError
			});
			
			function onComplete(... args):void {
				var updater:Updater = new Updater();
				updater.update(temp, serverVersion);
			}
			function onProgress(... args):void {}
			function onError(... args):void {}
		}
		
	}

}