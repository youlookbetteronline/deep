package enixan 
{
	import adobe.utils.CustomActions;
	import deng.fzip.FZip;
	import deng.fzip.FZipErrorEvent;
	import deng.fzip.FZipEvent;
	import deng.fzip.FZipFile;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.utils.ByteArray;
	import mx.controls.Alert;
	import wins.PreviewWindow;
	
	
	public class Compiler 
	{
		
		public static var inited:Boolean;
		public static var workFolder:File;
		public static var sdk:File;					// Папка к AIR SDK
		public static var mxmlc:File;				// Папка к mxmlc
		public static var java:File;				// Папка с JAVA
		public static var remote:File;				// Папка резервного копирования проектов
		public static var userprofile:File;			// Папка к профилю пользователя C://User//MyProfile
		public static var programmFiles:File;		// Системная папка к программам
		public static var droplets:Array;			// Cписок файлов дроплетов (для цветокоррекции)
		
		public function Compiler() {
			super();
		}
		
		
		
		/**
		 * Инициализация удаленных приложений
		 */
		public static function init():void {
			
			workFolder = Main.mainFolder;
			
			if (inited) return;
			
			droplets = File.applicationDirectory.resolvePath('droplets').getDirectoryListing();
			
			nativeProcess('set', onVars, null, function(... args):void {
				Alert.show('Не удалось инициализировать исходные параметры', Main.appName);
				inited = true;
			});
			
			function onVars(result:String):void {
				Main.app.info = result;
				
				var array:Array = result.split(String.fromCharCode(13,10));
				for (var i:int = 0; i < array.length; i++) {
					if (array[i].indexOf('USERPROFILE=') >= 0) {
						userprofile = new File(array[i].substring(12, array[i].length));
					}
					
					if (array[i].indexOf('ProgramFiles=') >= 0) {
						programmFiles = new File(array[i].substring(13, array[i].length));
					}
				}
				
				if (sdk && !sdk.exists)
					sdk = null;
				
				if (mxmlc && !mxmlc.exists)
					mxmlc = null;
				
				initJava();
				initSDK();
				
				inited = true;
			}
		}
		
		
		/**
		 * Инициализация Java
		 */
		public static function initJava():void {
			
			java = (Main.storage.java) ? new File(Main.storage.java) : null;
			if (!java || !java.exists || java.name != 'java.exe') java = null;
			
			if (java || !programmFiles) return;
			
			var Java:File = programmFiles.resolvePath('Java');
			if (Java.exists) {
				var list:Array = Java.getDirectoryListing();
				list.sortOn('name', Array.DESCENDING);
				for (var i:int = 0; i < list.length; i++) {
					if (list[i].name.indexOf('1.7') >= 0)
						continue;
					
					if (testJava(list[i] as File))
						return;
				}
			}
		}
		
		/**
		 * Проверка Java
		 * @param	file
		 * @param	updateIfCorrect
		 * @return
		 */
		public static function testJava(file:File, updateIfCorrect:Boolean = true):Boolean {
			
			var currentJava:File;
			
			if (file) {
				
				if (file.isDirectory) {
					
					if (file.resolvePath('bin').exists && file.resolvePath('bin/java.exe').exists) {
						currentJava = file.resolvePath('bin/java.exe');
					}else if (file.resolvePath('java.exe').exists){
						currentJava = file.resolvePath('java.exe');
					}
					
				}else if (file.name == 'java.exe') {
					currentJava = file;
				}
				
				if (currentJava) {
					if (updateIfCorrect) {
						java = currentJava;
						Main.storage.java = java.nativePath;
					}
					
					return true;
				}
			}
			
			return false;
			
			if (file && file.isDirectory && file.resolvePath('bin/java.exe').exists) {
				java = file.resolvePath('bin/java.exe');
				Main.storage.java = java.nativePath;
				return true;
			}
			
			return false;
		}
		
		
		/**
		 * Инициализация Flex SDK
		 */
		public static function initSDK():void {
			
			sdk = (Main.storage.sdk) ? new File(Main.storage.sdk) : null;
			if (sdk && sdk.exists) {
				mxmlc = sdk.resolvePath('bin/mxmlc.exe');
				if (!mxmlc.exists) {
					sdk = null;
					mxmlc = null;
				}
			}
			
			if ((sdk && mxmlc) || !userprofile) return;
			
			var apps:File = userprofile.resolvePath('AppData/Local/FlashDevelop/Apps');
			var files:Array = [];
			
			if (apps.exists) {
				var list:Array = apps.getDirectoryListing();
				for (var i:int = 0; i < list.length; i++) {
					if (list[i].isDirectory == false) continue;
					var appList:Array = list[i].getDirectoryListing();
					for (var j:int = 0; j < appList.length; j++) {
						if ((appList[j] as File).extension == 'xml') {
							var string:String = Files.openText(appList[j] as File, false);
							if (string.indexOf('<Id>flexairsdk</Id>') > 0) {
								for (var k:int = 0; k < appList.length; k++) {
									if (testSDK(appList[k], false)) {
										files.push(appList[k]);
									}
								}
							}
						}
					}
				}
				
				if (files.length > 0) {
					files.sortOn('name', Array.DESCENDING);
					testSDK(files[0]);
				}
			}
		}
		public static function testSDK(file:File, updateIfCorrect:Boolean = true):Boolean {
			
			var currentSDK:File;
			var currentMXMLC:File;
			
			if (file) {
				
				if (file.isDirectory) {
					
					if (file.resolvePath('bin').exists && file.resolvePath('bin/mxmlc.exe').exists) {
						currentSDK =  file;
						currentMXMLC = file.resolvePath('bin/mxmlc.exe');
					}else if (file.resolvePath('mxmlc.exe').exists){
						currentSDK =  file.parent;
						currentMXMLC = file.resolvePath('mxmlc.exe');
					}
					
				}else if (file.name == 'mxmlc.exe') {
					currentSDK =  file.parent.parent;
					currentMXMLC = file;
				}
				
				if (currentSDK && currentMXMLC) {
					if (updateIfCorrect) {
						sdk = currentSDK;
						mxmlc = currentMXMLC;
						Main.storage.sdk = sdk.nativePath;
					}
					
					return true;
				}
			}
			
			return false;
		}
		
		
		
		
		/**
		 * Установка AIR SDK
		 */
		public static function setupSDK(complete:Function = null):void {
			
			if (!userprofile) return;
			
			var name:String = 'flexairsdk'; // C:\Users\Andrew\AppData\Local\FlashDevelop\Apps\flexairsdk
			var sdkName:String = '4.6.0+24.0.0';
			var zip:File = userprofile.resolvePath('AppData/Local/Temp/' + name + '.tmp');
			
			MessageView.message('Установка AIRSDK');
			Files.downloadFile('https://dreams.islandsville.com/gfx/' + name + Main.ZIP + '?2', zip, {
				complete:		onComplete,
				progress:		function(progress:Number, speed:uint):void {
					MessageView.message('Загрузка AIRSDK: ' + (Math.floor(progress * 100)).toString() + '%  ' + (speed / 1024).toString() + 'kBps', { id:'loaderSdk', backColor:0x33ff33, clickable:false });
				},
				error:			function(data:String):void {
					MessageView.message('Не удалось загрузить AIRSDK. ' + data);
				},
				isSpeed:		true
			});
			
			//onComplete();
			
			function onComplete():void {
				var sdk:File = userprofile.resolvePath('AppData/Local/FlashDevelop/Apps/flexairsdk/' + sdkName);
				if (!sdk.exists) {
					if (!Main.app.createDirectory(sdk)) {
						sdk = File.applicationDirectory.resolvePath(name);
						
						if (!Main.app.createDirectory(sdk)) {
							Alert.show('Нет прав для создания папки для AIR SDK. Распакуйте его сами и укажите к нему путь.', Main.appName);
							return;
						}else {
							MessageView.message('Для AIR SDK создана папка по резервному пути, так как к основному нет доступа!');
						}
					}
				}
				
				unzip(zip, sdk, function():void {
					if (zip.exists) {
						zip.deleteFile();
						zip = null;
					}
					
					Compiler.sdk = sdk;
					var mxmlc:File = sdk.resolvePath('bin/mxmlc.exe');
					if (mxmlc.exists) Compiler.mxmlc = mxmlc;
					
					MessageView.message('AIRSDK распаковка завершена!');
				}, function():void {
					if (zip.exists) {
						zip.deleteFile();
						zip = null;
					}
					
					MessageView.message('AIRSDK. Ошибка распаковки...');
				});
			}
		}
		
		
		
		
		/**
		 * Установить JAVA
		 */
		public static function setupJava(complete:Function = null):void {
			
			if (!userprofile) return;
			
			var name:String = 'jre-8u121-windows-i586';
			var exe:File = userprofile.resolvePath('AppData/Local/Temp/' + name + '.exe');
			
			MessageView.message('Загрузка JAVA');
			Files.downloadFile('https://dreams.islandsville.com/gfx/' + name + '.exe', exe, {
				complete:		onComplete,
				progress:		function(progress:Number, speed:uint):void {
					MessageView.message('Загрузка Java: ' + (Math.floor(progress * 100)).toString() + '%  ' + (speed / 1024).toString() + 'kBps', { id:'loaderJava', backColor:0x33ff33, clickable:false });
				},
				error:			function(data:String):void {
					MessageView.message('Не удалось загрузить Java. ' + data);
				},
				isSpeed:		true
			});
			
			
			function onComplete():void {
				exe.openWithDefaultApplication();
			}
		}
		
		
		
		
		/**
		 * Распаковка файла
		 * @param	file
		 * @param	destination
		 * @param	complete
		 * @param	error
		 */
		public static function unzip(zip:File, destination:File, complete:Function = null, error:Function = null):void {
			
			if (!zip.exists) {
				if (error != null) error();
				return;
			}
			
			var fzip:FZip = new FZip();
			fzip.load(new URLRequest(zip.nativePath));
			fzip.addEventListener(Event.COMPLETE, onZIPLoadComplete);
			fzip.addEventListener(FZipErrorEvent.PARSE_ERROR, onZIPParseError);
			
			function onZIPLoadComplete(e:Event):void {
				var count:int = fzip.getFileCount();
				
				while(--count > 0) {
					var file:FZipFile = fzip.removeFileAt(count);
					if (file.filename.charAt(file.filename.length - 1) == '/') continue;
					
					var dfile:File = destination.resolvePath(file.filename);
					Files.save(dfile, file.content);
					file.dispose();
					
					if (System.totalMemory > 1300000000)
						System.gc();
					
				}
				
				if (complete != null)
					complete();
			}
			function onZIPParseError(e:FZipErrorEvent):void {
				if (error != null) error();
			}
		}
		
		
		
		
		/**
		 * Обновление дроплетов
		 */
		public static function dropletsUpdate():Boolean {
			// Если обновляются
			// return true;
			
			return false;
		}
		
		
		
		/**
		 * 
		 */
		public static function photoshopDroplet(droplet:File, source:File, onComplete:Function = null, onProcess:Function = null, onError:Function = null):void {
			
			if (!NativeProcess.isSupported) {
				if (onError != null) onError('NativeProcess.isSupported: ' + NativeProcess.isSupported.toString());
				return;
			}
			if (process && process.running) return;
			
			process = new NativeProcess();
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onSndError);
			process.addEventListener(NativeProcessExitEvent.EXIT, onFileExit);
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onSndOut);
			process.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, onInputData);
			
			var args:Vector.<String> = new Vector.<String>;
			//args.push('/c', 'D:\\house.png', '/U');
			args.push(source.nativePath);
			
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = droplet;
			info.arguments = args;
			
			if (!process.running) {
				process.start(info);
			}else {
				return;
			}
			
			function onSndError(e:ProgressEvent):void {
				if (onError != null)
					onError(e.toString());
				
				dispose();
			}
			function onFileExit(e:NativeProcessExitEvent):void {
				if (onComplete != null)
					onComplete(e.toString());
				
				dispose();
			}
			function onSndOut(e:ProgressEvent):void {
				var value:String = (process.standardOutput.bytesAvailable) ? process.standardOutput.readMultiByte(process.standardOutput.bytesAvailable, 'iso-8859-01') : '';
				
				//text += value;
				
				if (onProcess != null)
					onProcess(value);
			}
			function onInputData(e:ProgressEvent):void {
				//
			}
			function dispose():void {
				if (!process) return;
				process.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onSndError);
				process.removeEventListener(NativeProcessExitEvent.EXIT, onFileExit);
				process.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onSndOut);
				process.removeEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, onInputData);
				process = null;
			}
		}
		
		
		
		// NativeProcess
		private static var process:NativeProcess;
		public static function nativeProcess(string:String, onComplete:Function = null, onProcess:Function = null, onError:Function = null):void {
			
			if (!NativeProcess.isSupported) {
				if (onError != null) onError('NativeProcess.isSupported: ' + NativeProcess.isSupported.toString());
				return;
			}
			if (!string || string.length == 0) return;
			if (process && process.running) return;
			
			var text:String = '';
			
			process = new NativeProcess();
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onSndError);
			process.addEventListener(NativeProcessExitEvent.EXIT, onFileExit);
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onSndOut);
			process.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, onInputData);
			
			var file:File = workFolder.resolvePath('run.cmd');
			var bytes:ByteArray = new ByteArray();
			bytes.writeMultiByte(string, 'cp866');
			Files.save(file, bytes);
			
			var args:Vector.<String> = new Vector.<String>;
			args.push('/c', file.nativePath, '/U');
			
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = new File('c:/windows/system32/cmd.exe');
			info.arguments = args;
			
			if (!process.running) {
				process.start(info);
			}else {
				return;
			}
			
			function onSndError(e:ProgressEvent):void {
				if (onError != null)
					onError((e.target.standardError.bytesAvailable) ? e.target.standardError.readMultiByte(e.target.standardError.bytesAvailable, 'iso-8859-01') : '');
				
				dispose();
			}
			function onFileExit(e:NativeProcessExitEvent):void {
				if (onComplete != null)
					onComplete(text);
				
				dispose();
			}
			function onSndOut(e:ProgressEvent):void {
				var value:String = (e.target.standardOutput.bytesAvailable) ? e.target.standardOutput.readMultiByte(e.target.standardOutput.bytesAvailable, 'iso-8859-01') : '';
				
				text += value;
				
				if (onProcess != null)
					onProcess(value);
			}
			function onInputData(e:ProgressEvent):void {
				//
			}
			function dispose():void {
				if (!process) return;
				process.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onSndError);
				process.removeEventListener(NativeProcessExitEvent.EXIT, onFileExit);
				process.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onSndOut);
				process.removeEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, onInputData);
				process = null;
			}
		}
		
		
		
		/**
		 * Сжать SWF
		 * @param	swf
		 * @param	destination
		 * @param	complete
		 * @param	progress
		 * @param	error
		 */
		public static function zip(swf:File, destination:File = null, complete:Function = null, progress:Function = null, error:Function = null):void {
			
			if (!swf || !swf.exists) {
				if (error != null)
					error();
			}
			
			if (!destination) destination = swf;
			
			var reducer:File = File.applicationDirectory.resolvePath('reducer.jar');
			var compress:String = '"' + Compiler.java.nativePath + '" -jar "' + reducer.nativePath + '" -input "' + swf.nativePath + '" -output "' + destination.nativePath + '" -quality 0.8';
			Compiler.nativeProcess(compress, complete, progress, error);
			
		}
		
		
		
		/**
		 * Собрать SWF
		 * @param	config		Config.xml
		 * @param	destination	Some.swf
		 * @param	complete
		 * @param	error
		 */
		public static var compileQueue:Array;
		public static function compile(config:File, destination:File, complete:Function = null, error:Function = null):void {
			if (!mxmlc) return;
			
			if (!compileQueue) compileQueue = [];
			
			compileQueue.push( {
				config:		config,
				destination:destination,
				complete:	complete,
				error:		error
			});
			
			if (compileQueue.length > 1) return;
			
			compileNext();
		}
		private static function compileNext():void {
			
			if (compileQueue.length == 0) return;
			
			var data:Object = compileQueue[0];
			var string:String = '"' + mxmlc.nativePath + '" -load-config+="' + data.config.nativePath + '" -incremental=true +configname=air -swf-version=29 -o "' + data.destination.nativePath + '"';
			
			Compiler.stateProgress(string);
			
			Compiler.nativeProcess(string, function(result:String):void {

					var cache:File = data.destination.parent.resolvePath(data.destination.name + '.cache');
					cache.deleteFileAsync();

				compileQueue.shift();
				if (data.complete != null) data.complete(result);
				compileNext();
			}, null, function(result:String):void {
				compileQueue.shift();
				if (data.error != null) data.error(result);
				compileNext();
			});
		}
		
		
		
		
		//
		public static const COMPILE_START:String = 'start';
		public static const COMPILE_COPY_FILES:String = 'copyFiles';
		public static const COMPILE_COLOR_CORRECTION:String = 'colorCorrection';
		public static const COMPILE_COMPILE_SWF:String = 'compileSwf';
		public static const COMPILE_COMPILE:String = 'compile';
		public static const COMPILE_ZIP:String = 'zip';
		public static const COMPILE_ICON:String = 'icon';
		public static const COMPILE_UPLOAD:String = 'upload';
		public static const COMPILE_COMPLETE:String = 'complete';
		
		private static var __mode:String;
		
		public static function state(mode:String):void {
			if (__mode == mode) return;
			
			__mode = mode;
			
			if (wins.PreviewWindow.instance)
				wins.PreviewWindow.instance.state(__mode);
		}
		public static function getState():String {
			return __mode;
		}
		public static function stateProgress(text:String):void {
			if (wins.PreviewWindow.instance)
				wins.PreviewWindow.instance.stateProgress(text);
		}
		
	}

}