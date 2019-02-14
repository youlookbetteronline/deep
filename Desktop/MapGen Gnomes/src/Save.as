package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import mx.controls.Alert;
	import flash.filesystem.*;
	import mx.events.CloseEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class Save 
	{
		public static var swfPath:String;
		public static var projectDirectory:File = File.applicationDirectory;
		public static var projectPath:String;
		public static var name:String;
		
		public static var gridDelta:int = 0;
		public static var mapID:uint = 0;
		
		public function Save()
		{
			
		}
		
		public static function loadSavedGrid(callback:Function):void
		{
			var file:File = File.applicationDirectory.resolvePath("markers.txt"); 
			file.addEventListener(Event.COMPLETE, onLoadMarkersData); 
			file.load(); 
			
			function onLoadMarkersData(event:Event):void 
			{ 
				var str:String; 
				var bytes:ByteArray = file.data; 
				str = bytes.readUTFBytes(bytes.length); 
				var data:Object = JSON.parse(str);
				callback(data as Array);
			}
		}
		
		public static function generateProject():void
		{
			if (Main.main.mapName.text != "") name = Main.main.mapName.text;
			else{
				Alert.show('Введите название карты!');
				return;
			}
			
			var directory:File = new File(Main.main.projectPath.text).resolvePath(name + "/");
			var targetParent:File = directory.parent;
			targetParent.createDirectory();
			
			//Создаем директории
			var target:File = directory.resolvePath("obj/temp.txt");
			targetParent = target.parent;
			targetParent.createDirectory();
			
			var src:File = directory.resolvePath("src/");
			targetParent = src.parent;
			targetParent.createDirectory();
			
			var sprites:File = src.resolvePath("sprites/");
			var replaces:Object = generateContent(sprites);
			
			//Генерируем файл проекта
			var as3proj:File = File.applicationDirectory.resolvePath('templates/project.as3proj');
			var stream:FileStream = new FileStream();
			stream.open(as3proj, FileMode.READ);
			var as3projData:String =  stream.readMultiByte(stream.bytesAvailable, File.systemCharset);
			stream.close();
			as3projData = as3projData.replace(/\{path\}/, Main.main.swfPath.text);
			as3projData = as3projData.replace(/\{name\}/g, name);
			
			//Сохраняем файл проекта
			as3proj = directory.resolvePath(name + '.as3proj');
			stream.open(as3proj, FileMode.WRITE);
			stream.writeMultiByte(as3projData, File.systemCharset);
			stream.close(); 
			
			
			//Генерируем основной AS3 файл
			var as3:File = File.applicationDirectory.resolvePath('templates/code.as');
			stream.open(as3, FileMode.READ); 
			var as3Data:String =  stream.readMultiByte(stream.bytesAvailable, File.systemCharset);
			stream.close();
			
			as3Data = as3Data.replace(/\{name\}/g, name);
			as3Data = as3Data.replace(/\{embed\}/, replaces.embed);
			as3Data = as3Data.replace(/\{assets\}/, replaces.assets);
			as3Data = as3Data.replace(/\{grid\}/, replaces.grid);
			as3Data = as3Data.replace(/\{elements\}/, replaces.elements);
			as3Data = as3Data.replace(/\{vars\}/, replaces.vars);
			
			as3 = directory.resolvePath('src/'+name + '.as');
			stream.open(as3, FileMode.WRITE); 
			stream.writeMultiByte(as3Data, File.systemCharset);
			stream.close();
			
			var appPath:String = File.applicationDirectory.nativePath;
			
			var batDir:File = as3proj.parent.parent;
			var batValue:String = '"C:\\Program Files (x86)\\FlashDevelop\\Tools\\fdbuild\\fdbuild.exe" "' + batDir.nativePath + '\\' + name + '\\' + name + '.as3proj" -compiler "C:\\Program Files (x86)\\FlashDevelop\\Tools\\flexsdk" -notrace -library "C:\\Program Files (x86)\\FlashDevelop\\Library"' + ";\n"+'java -jar '+appPath+'\\reducer.jar -input '+Main.main.swfPath.text+'\\'+name+'.swf -output '+Main.main.swfPath.text+'\\'+name+'.swf -quality 0.6'+"\n\n";
			var batFile:File = batDir.resolvePath("as3projs.bat");
			stream.open(batFile, FileMode.APPEND); 
			stream.writeMultiByte(batValue, "utf-8");
			stream.close();
			
			
			Alert.show("Проект успешно сохранен. Запустить проект?", "Успех!", Alert.YES|Alert.NO, Main.main, alertClickHandler);
			function alertClickHandler(e:CloseEvent):void {
				if (e.detail == Alert.YES) {
					as3proj.openWithDefaultApplication();
				}
			}
		}
		
		/**
		 * Генереруем наполнение острова
		 * @param	event
		 */
		public static function generateContent(sprites:File):Object
		{
			var targetParent:File = sprites.parent;
			targetParent.createDirectory();
			
			var i:int = 0;
			var j:int = 0;
			var assetsObj:Object = { };
			
			//var bmp:Bitmap = Map.map;
			//var encoder:JPGEncoder = new JPGEncoder(80); 
			//var pixels:ByteArray = encoder.encode(bmp.bitmapData);
			var image:File = sprites.resolvePath(Map.self.file.name);
			//var stream:FileStream = new FileStream(); 
			//stream.open(image, FileMode.WRITE); 
			//stream.writeBytes(pixels);
			//stream.close();
			
			Map.self.file.copyTo(image, true);
			
			var embed:String 		= "";
			var elements:String 	= "";
			var grid:String 		= "";
			var vars:String 		= "";
			var assets:String		= "\n\t\tpublic var assets:Object = {\n\t\t\t1:\t172\n\t\t};";
			
			embed += "\n\t\t[Embed(source=\"sprites/" + Map.self.file.name + "\", mimeType=\"image/jpeg\")]\n\t\tprivate var Tile:Class;\n";
			embed += "\t\t\public var tile:BitmapData = new Tile().bitmapData";
			
			/*elements = "\n\t\tpublic var elements:Array = [\n";
			var units:Array = Map.units;
			for (var i:int = 0; i < Map.units.length; i++)
			{
				var unit:Unit = Map.units[i];
				elements += "\t\t\t\t\t{name:'" + unit.label + "', url:\"" + unit.url + "\", x:" + unit.getIsoCoords().x + ", y:" + unit.getIsoCoords().z + ", width:" + unit.width + ", height:" + unit.height + ", iso:true, depth:" + Map.self.mUnits.getChildIndex(unit) + "}";
				if (i != Map.units.length - 1)
				{
					elements += ","
				}
				elements += "\n";
			}
			
			elements += "\t\t\t\t\t];";*/
			
			assets = "\n\t\tpublic var assetZones:Object = {";
			for (i = 0; i < Map.markersData.length; i++) {
				for (j = 0; j < Map.markersData[i].length; j++) {
					if (Map.markersData[i][j].z != 0 && !assetsObj.hasOwnProperty(Map.markersData[i][j].z)) {
						if (Numbers.countProps(assetsObj) > 0) assets += ",";
						assetsObj[Map.markersData[i][j].z] = 0;
						assets += "\n\t\t\t" + Map.markersData[i][j].z + ":" + ((Main.main.zones[Map.markersData[i][j].z]) ? String(Main.main.zones[Map.markersData[i][j].z]['zone']) : "0");
					}
				}
			}
			
			if (Numbers.countProps(assetsObj) > 0) {
				assets += "\n\t\t};\n\t\t";
			}else {
				assets += "};\n\t\t";
			}
			
			
			grid += "public var gridData:Object = JSON.parse('" + Save.getMarkersData() + "');";
			
			vars += "public var id:uint = 0;\n";
			vars += "\t\tpublic var gridDelta:int = "	+Map.self.gridLeftWidth+			";\n";
			vars += "\t\tpublic var isoCells:uint = "	+Map.markersData[0].length+			";\n";
			vars += "\t\tpublic var isoRows:uint = "	+Map.markersData.length+			";\n";
			vars += "\t\tpublic var mapWidth:uint = "	+Map.self.gridBitmap.width+			";\n";
			vars += "\t\tpublic var mapHeight:uint = " 	+Map.self.gridBitmap.height+		";\n";
			vars += "\t\t\n";
			vars += "\t\tpublic var tileDX:int = " + (-Map.self.gridCont.x).toString() + ";\n";
			vars += "\t\tpublic var tileDY:int = " + (-Map.self.gridCont.y).toString() + ";\n";
			vars += "\t\tpublic var type:String = 'image';\n";
			vars += "\t\tpublic var bgColor:uint = 0x" + Map.getColor().toString(16) + ";\n";
			vars += "\t\t\n";
			vars += "\t\tpublic var heroPosition:Object = {x:" + Main.main.map.respawnPoint.x + ", z:" + Main.main.map.respawnPoint.y + "};\n";
			vars += "\t\t\n";
			
			vars += "\t\tpublic var zones:Object = {";
			var count:int = 0;
			for (var fid:* in Main.main.map.faders) {
				if (!Main.main.zones[fid] || !Main.main.map.faders[fid] || !Main.main.map.faders[fid]['complete'])
					continue;
				
				if (count > 0) vars += ",";
				count++;
				
				vars += "\n\t\t\t" + ((Main.main.zones[fid]) ? Main.main.zones[fid]['zone'] : fid) + ": {";
				vars += "\n\t\t\t\tpoints: [";
				
				if (Main.main.map.faders[fid] && Main.main.map.faders[fid].points.length > 2) {
					for (i = 0; i < Main.main.map.faders[fid].points.length; i++) {
						if (i != 0) vars += ",";
						vars += "\n\t\t\t\t\t{ x: " + Main.main.map.faders[fid].points[i].x + ", z: " + Main.main.map.faders[fid].points[i].y + " }";
					}
					vars += "\n\t\t\t\t]";
				}else {
					vars += "]";
				}
				vars += ",\n\t\t\t\tclouds: []";
				vars += "\n\t\t\t}";
			}
			
			if (Numbers.countProps(Main.main.map.faders) > 0) {
				vars += "\n\t\t};\n";
			}else {
				vars += "};\n";
			}
			
			return {
				embed:embed,
				grid:grid,
				elements:elements,
				vars:vars,
				assets:assets
			}
			
		}
		
		public static function saveMarkersData():void
		{
			var result:String = Save.getMarkersData();
			
			var file:File = File.applicationStorageDirectory.resolvePath("markers.txt"); 
			file.addEventListener(Event.COMPLETE, onSaveMarkersData);
			file.save(result);
		}
		
		/*public static function getMarkersData():String {
			var reformat:Array = [];
			
			for (var i:int = 0; i < Map.markersData.length; i++) {
				if (reformat.length <= i) reformat[i] = [];
				for (var j:int = 0; j < Map.markersData[i].length; j++) {
					var object:Object = { };
					
					for (var s:* in Map.markersData[i][j]) {
						if (s == 'b' || s == 'p') {
							if (Map.markersData[i][j][s] == 1) {
								object[s] = 0;
							}else {
								object[s] = 1;
							}
							continue;
						}
						
						object[s] = Map.markersData[i][j][s];
					}
					reformat[i][j] = object;
				}
			}
			
			return JSON.stringify(reformat);
		}*/
		
		public static function getMarkersData():String {
			var reformat:Array = [];
			
			for (var i:int = 0; i < Map.markersData.length; i++) {
				for (var j:int = 0; j < Map.markersData[i].length; j++) {
					if (reformat.length <= j) reformat[j] = [];
					var object:Object = { };
					
					for (var s:* in Map.markersData[i][j]) {
						if (s == 'b' || s == 'p') {
							if (Map.markersData[i][j][s] == 1) {
								object[s] = 0;
							}else {
								object[s] = 1;
							}
							continue;
						}
						
						object[s] = Map.markersData[i][j][s];
					}
					reformat[j][i] = object;
				}
			}
			
			return JSON.stringify(reformat);
		}
		
		private static function onSaveMarkersData(event:Event):void 
		{
			Alert.show('Cетка карты сохранена');
		}
	}
}