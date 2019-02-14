package  
{
	import astar.AStar;
	import astar.AStarNodeVO;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.NativeWindowDisplayState;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.filters.GlowFilter;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.graphics.codec.PNGEncoder;
	import silin.FaderPoint;
	
	public class Map extends Sprite
	{
		
		[Embed(source="personage.png", mimeType="image/png")]
		private var PersonageClass:Class;
		private var personageBMD:BitmapData = new PersonageClass().bitmapData;
		
		public static var markersData:Vector.<Vector.<Object>> = new Vector.<Vector.<Object>>;
		public static var tile:Object;
		public static var openTile:Object;
		public static var dragBlock:Boolean = false;
		public static var dragGrid:Boolean = false;
		
		public static var self:Map;
		
		public var draging:Boolean = false;
		public var gridding:Boolean = false;
		public var scaleable:Boolean = true;
		public var gridBacking:Boolean = false;
		
		public var main:*;
		public var canvas:UIComponent;
		public var mapCont:Sprite;
		public var gridCont:Sprite;
		public var persCont:Sprite;
		public var fader:Shape;
		public var infoLabel:TextField;
		public var respawnPoint:Point = new Point();
		
		public var file:File;
		
		public static var map:Bitmap;
		public var gridBitmap:Bitmap;
		public static var grid:BitmapData;
		
		private var brush:Sprite;
		
		public function Map(main:*) {
			
			self = this;
			
			this.main = main;
			this.canvas = main.canvas;
			
			Map.tile = { b:0, p:0, w:0, z:0 };
			Map.openTile = { };
			
			canvas.addChild(this);
			
			mapCont = new Sprite();
			addChild(mapCont);
			
			
			map = new Bitmap();
			mapCont.addChild(map);
			
			gridCont = new Sprite();
			mapCont.addChild(gridCont);
			
			gridBitmap = new Bitmap(null, 'auto', true);
			gridCont.addChild(gridBitmap);
			
			persCont = new Sprite();
			gridCont.addChild(persCont);
			
			fader = new Shape();
			gridCont.addChild(fader);
			
			infoLabel = new TextField();
			infoLabel.x = 5;
			infoLabel.y = 3;
			infoLabel.width = 200;
			infoLabel.defaultTextFormat = new TextFormat('Tahoma', 10);
			infoLabel.multiline = true;
			infoLabel.wordWrap = true;
			infoLabel.mouseEnabled = false;
			infoLabel..filters = [new GlowFilter(0xffffff,1,3,3,32)];
			addChild(infoLabel);
			
			showInfo();
			
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			addEventListener(MouseEvent.MOUSE_UP, onUp);
			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
			
			// Map
			var path:String = Storage.read('map', '');
			if (path.length > 0) {
				var file:File = new File(path);
				loadMapFromFile(file);
			}
			
			// Grid
			var gridPos:Object = Storage.read('gridPos', { x:0, y:0 } );
			gridCont.x = gridPos.x;
			gridCont.y = gridPos.y;
			gridUpdate();
			
			var preMarkersData:* = Storage.read('markersData', null);
			if (preMarkersData)
				updateMarkerData(preMarkersData);
			
			/*var zones:Object = Storage.read('zoneData', null);
			if (zones) {
				faders = zones.faders;
			}*/
			
			createGrid((markersData.length > 0) ? markersData.length : 10, (markersData.length > 0 && markersData[0].length > 0) ? markersData[0].length : 10);
			
		}
		
		public function updateMarkerData(array:*):void {
			for (var i:int = 0; i < array.length; i++) {
				if (markersData.length <= i) markersData.push(new Vector.<Object>);
				for (var j:int = 0; j < array[i].length; j++) {
					markersData[i][j] = array[i][j];
				}
			}
		}
		
		private var cDrugObject:*;
		public var touchedPoint:FaderPoint;
		public function onDown(event:MouseEvent):void {
			if(main.addFPoint){
				addSimpleFaderPoint(true);
			}
			if (event.target is FaderPoint){
				if (cDrugObject){
					cDrugObject.stopDrag();
					cDrugObject = null;
				}
				if (fader.hasEventListener(Event.ENTER_FRAME)){
					fader.removeEventListener(Event.ENTER_FRAME, onFaderUpdate);
				}
				fader.addEventListener(Event.ENTER_FRAME, onFaderUpdate);
				cDrugObject = event.target;
				
				main.zone = cDrugObject.zoneId;
				main.updateZoneData();
				main.map.updateGridColor();
				cDrugObject.startDrag(false, null);
				return;
			}
			
			if (Map.dragBlock) return;
			
			if (Map.dragGrid) {
				gridCont.startDrag(false, null);
				gridding = true;
			}else {
				mapCont.startDrag(false, null);
				draging = true;
			}
			
			//var rectangle:Rectangle = new Rectangle((canvas.width + 400 < map.width) ? 200 : map.x, (canvas.height + 200 < map.height) ? 100 : map.y, (canvas.width + 400 < map.width) ? canvas.width - map.width - 400 : 0, (canvas.height + 200 < map.height) ? canvas.height - map.height - 200 : 0);
			
		}
		public function onUp(event:MouseEvent = null):void {
			if (draging) {
				mapCont.stopDrag();
				draging = false;
			}
			if (cDrugObject){
				cDrugObject.stopDrag();
				cDrugObject = null;
				if (fader.hasEventListener(Event.ENTER_FRAME)){
					fader.removeEventListener(Event.ENTER_FRAME, onFaderUpdate);
				}
			}
			if (gridding) {
				gridCont.stopDrag();
				gridding = false;
				
				gridUpdate();
				Storage.store('gridPos', { x:gridCont.x, y:gridCont.y } );
			}
		}
		public function onOver(event:MouseEvent):void {
			scaleable = true;
			
			main.currStage.focus = null;
			
			createBrush();
			//createFader();
		}
		public function onOut(event:MouseEvent):void {
			if (draging) onUp();
			
			scaleable = false;
			
			clearBrush();
		}
		
		
		//Fader
		private var __fadering:Boolean = false;
		public function set fadering(value:Boolean):void {
			if (__fadering == value) return;
			
			__fadering = value;
			
			if (__fadering) {
				showInfo('fader');
				createFader();
				//fader.graphics.clear();
			}else {
				showInfo();
				escapeFader();
				clearFader();
				fader.graphics.clear();
			}
			
		}
		public function get fadering():Boolean {
			return __fadering;
		}
		
		
		public var faders:Object = { };
		public var faderPointTime:uint = 0;
		private var faderPointComplete:uint = 0;
		private var faderPoint:Point;
		/*private function preaddFaderPoint():void {
			faderPointTime = getTimer();
			faderPoint = new Point(gridCont.mouseX, gridCont.mouseY);
		}*/
		public function addFaderPoint(complete:Boolean = false):void 
		{
			if (fader.hasEventListener(Event.ENTER_FRAME)){
				fader.removeEventListener(Event.ENTER_FRAME, onFaderUpdate);
			}
			fader.addEventListener(Event.ENTER_FRAME, onFaderUpdate);
			
			faderPoint = new Point(gridCont.mouseX, gridCont.mouseY);
			
			if (!faders[main.zone] || faders[main.zone].complete) {
				faders[main.zone] = {
					points:		new Vector.<Point>,
					coords:		new Vector.<Point>,
					complete:	false,
					color:		main.zoneColor
				};
			}
			
			faderPointComplete = getTimer();
			
			var point:Point = faderPoint.clone();
			var object:Object = IsoConvert.screenToIso(point.x, point.y, true);
			
			faders[main.zone].points.push(point);
			faders[main.zone].coords.push(new Point(object.x, object.z));
			
			if (complete)
				escapeFader();
		}
		
		public function removeFaderPoint():void 
		{
			if(touchedPoint && faders[touchedPoint.zoneId]){
				var _index:int = touchedPoint.pointId;
				//var arrr:Vector.<Point> = 
				//touchedPoint = null;
				clearPoints();
				faders[touchedPoint.zoneId].coords.splice(_index, 1);
				faders[touchedPoint.zoneId].points.splice(_index, 1);
				touchedPoint.dispose();
				touchedPoint = null;
				onFaderUpdate();
				drawPoints();
			}
		}
		
		public function addSimpleFaderPoint(fromPoint:Boolean = false):void 
		{
			faderPoint = new Point(gridCont.mouseX, gridCont.mouseY);
			
			if (!faders[main.zone]) {
				faders[main.zone] = {
					points:		new Vector.<Point>,
					coords:		new Vector.<Point>,
					complete:	false,
					color:		main.zoneColor
				};
			}
			
			faderPointComplete = getTimer();
			
			var point:Point = faderPoint.clone();
			var object:Object = IsoConvert.screenToIso(point.x, point.y, true);
			if (fromPoint){
				if (touchedPoint && touchedPoint.zoneId == main.zone){
					fader.graphics.clear();
					var _index:int = touchedPoint.pointId;
					//var arrr:Vector.<Point> = 
					object = IsoConvert.screenToIso(touchedPoint.x, touchedPoint.y - 5, true);
					faders[main.zone].coords = Numbers.pushInVector(faders[main.zone].coords, _index, {x:object.x, y:object.z});
					faders[main.zone].points = Numbers.pushInVector(faders[main.zone].points, _index, {x:touchedPoint.x, y:touchedPoint.y-5});
					clearPoints();
					touchedPoint = null;
				}else
					return;
			}else{
				faders[main.zone].points.push(point);
				faders[main.zone].coords.push(new Point(object.x, object.z));
			}
			escapeFader();
			onFaderUpdate();
			drawPoints();
		}
		
		public function createFader():void {
			if (!fadering) return;
			onFaderUpdate();
			drawPoints();
			//if (fader.hasEventListener(Event.ENTER_FRAME)) return;
			
			//fader.addEventListener(Event.ENTER_FRAME, onFaderUpdate);
		}
		public function clearFader():void {
			clearPoints();
			//if (!fader.hasEventListener(Event.ENTER_FRAME)) return;
			
			//fader.removeEventListener(Event.ENTER_FRAME, onFaderUpdate);
		}
		public function escapeFader():void {
			if (!faders[main.zone]) return;
			
			if (faders[main.zone].points.length >= 3) {
				faders[main.zone].complete = true;
			}else {
				faders[main.zone] = null;
			}
			
			faderPointComplete = 0;
			faderPoint = null;
			
			if (fader.hasEventListener(Event.ENTER_FRAME)){
				fader.removeEventListener(Event.ENTER_FRAME, onFaderUpdate);
			}
		}
		
		private var fPoints:Vector.<FaderPoint>;
		private function clearPoints():void {
			if(fPoints){
				for each(var _point:FaderPoint in fPoints){
					_point.dispose();
				}
				fPoints = null;
			}
		}
		private function drawPoints():void {
			clearPoints();
			fPoints = new Vector.<FaderPoint>();
			for (var zone:* in faders) {
				if (!faders[zone] || !main.zones[zone]) continue;
				var _fpoint:FaderPoint;
				if (faders[zone].points.length >= 1){
					_fpoint = new FaderPoint(zone, 0);
					gridCont.addChild(_fpoint);
					fPoints[fPoints.length] = _fpoint;
					
				}
				for (var j:int = 1; j < faders[zone].points.length; j++) {
					_fpoint = new FaderPoint(zone, j);
					gridCont.addChild(_fpoint);
					fPoints[fPoints.length] = _fpoint;
				}
			}
		}
		
		private function onFaderUpdate(e:Event = null):void {
			fader.graphics.clear();
			if(cDrugObject){
				cDrugObject.updateFader();
			}
			for (var zone:* in faders) {
				if (!faders[zone] || !main.zones[zone]) continue;
				
				fader.graphics.beginFill(faders[zone].color, 0.4);
				fader.graphics.lineStyle(1, faders[zone].color);
				
				if (faders[zone].points.length >= 1){
					fader.graphics.moveTo(faders[zone].points[0].x, faders[zone].points[0].y);
					
				}
				
				for (var j:int = 1; j < faders[zone].points.length; j++) {
					fader.graphics.lineTo(faders[zone].points[j].x, faders[zone].points[j].y);
				}
				
				if (faders[zone].complete == false) {
					fader.graphics.lineStyle(1, faders[zone].color, 0.7);
					fader.graphics.lineTo(gridCont.mouseX, gridCont.mouseY);
				}
				
				fader.graphics.endFill();
			}
		}
		
		// Brush
		private var brushText:TextField;
		public function createBrush():void {
			if (fadering) return;
			if (main.mouseHandleMode != 'brush') return;
			
			if (!brush) {
				brush = new Sprite();
				brush.mouseChildren = false;
				brush.mouseEnabled = false;
				brush.addEventListener(Event.ENTER_FRAME, onBrushMove);
				addChild(brush);
				
				brushText = new TextField();
				brushText.width = brushText.height = 0;
				brushText.defaultTextFormat = new TextFormat('Tahoma', 11, 0xffffff, true);
				brushText.filters = [new GlowFilter(0x000000,1,3,3,32)];
				brush.addChild(brushText);
				
			}else {
				brush.graphics.clear();
				brush.removeChildren();
			}
			
			var size:Number = main.brushSize;
			
			brush.graphics.beginFill(0x000000, 0.25);
			brush.graphics.moveTo(0, 0);
			brush.graphics.lineTo(NODE_WIDTH * size * mapCont.scaleX, NODE_HEIGHT * size * mapCont.scaleX);
			brush.graphics.lineTo(0, NODE_HEIGHT*2 * size * mapCont.scaleX);
			brush.graphics.lineTo( -NODE_WIDTH * size * mapCont.scaleX, NODE_HEIGHT * size * mapCont.scaleX);
			//brush.scaleX = brush.scaleY = mapCont.scaleX;
			
		}
		private function clearBrush():void {
			if (!brush) return;
			
			brush.removeEventListener(Event.ENTER_FRAME, onBrushMove);
			removeChild(brush);
			brush = null;
		}
		private function onBrushMove(e:Event):void {
			if (!brush) return;
			
			brush.x = mouseX;
			brush.y = mouseY /*+ NODE_HEIGHT*2*/;
			
			var object:Object = IsoConvert.screenToIso(gridCont.mouseX, gridCont.mouseY, true);
			brushText.text = String(object.x) + ':' + String(object.z);
			brushText.width = brushText.textWidth + 4;
			brushText.height = brushText.textHeight + 4;
			brushText.x = -brushText.width * 0.5;
			brushText.y = -brushText.height - 10;
		}
		
		
		public function gridUpdate():void {
			gridCont.x = Math.round(gridCont.x);
			gridCont.y = Math.round(gridCont.y);
			main.gridX.text = gridCont.x.toString();
			main.gridY.text = gridCont.y.toString();
		}
		
		public function loadMapFromFile(file:File):void {
			if (!file.exists) return;
			
			this.file = file;
			
			Load.openAsync(file, function(data:ByteArray):void {
				loadMapBytes(data, file.nativePath);
				main.mapGenerator.enabled = true;
			});
		}
		
		public function loadMapBytes(data:ByteArray, path:String = ''):void {
			
			Storage.store('map', path);
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.loadBytes(data);
			
			function onComplete(e:Event):void {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				map.bitmapData = (loader.content as Bitmap).bitmapData;
				
				main.setCanvasBackgroundColor(Map.getColor());
			}
			function onError(e:IOErrorEvent):void {
				Alert.show('Не удалось загрузить карту!', 'MapGenerator');
			}
		}
		
		public static function getColor():uint {
			return (Map.map.bitmapData.width > 2 && Map.map.bitmapData.height > 2) ? Map.map.bitmapData.getPixel32(2, 2) : 0xffffffff;
		}
		
		public function scale(scale:Boolean, center:Point = null):void {
			if (!scaleable) return;
			
			var prevWidth:int = width;
			var prevHeight:int = height;
			
			if (scale && mapCont.scaleX < 4) {
				
				mapCont.scaleX *= 1.5;
				mapCont.scaleY *= 1.5;
				
			}else if (mapCont.scaleX > 0.1) {
				
				mapCont.scaleX *= 0.75;
				mapCont.scaleY *= 0.75;
				
			}
			
			
			mapCont.x = 0;
			mapCont.y = 0;
			
			createBrush();
			
			//x -= (width - prevWidth + mapCont.x) * (center.x / prevWidth);
			//y -= (height - prevHeight + mapCont.y) * (center.y / prevHeight);
		}
		
		
		// Grid
		public static var cells:uint = 0;
		public static var rows:uint = 0;
		
		public static const NODE_WIDTH:Number = 12.5;//19.63;
		public static const NODE_HEIGHT:Number = 10;
		private var gridThick:Number = 0.5;
		private var gridColor:uint = 0x000000;
		private var gridAlpha:Number = 0.7;
		public function createGrid(cells:uint, rows:uint):void {
			
			//cells = 160;
			//rows = 160;
			
			Map.cells = cells;
			Map.rows = rows;
			
			main.TX.value = cells;
			main.TZ.value = rows;
			
			var i:uint;
			var x_offset:int = NODE_WIDTH * Math.max(Map.cells, Map.rows);
			
			var shape:Shape = new Shape();
			shape.graphics.lineStyle(gridThick, gridColor, gridAlpha, true);
			
			for (i = 0; i < cells + 1; i++) {
				shape.graphics.moveTo(x_offset - NODE_WIDTH * i, NODE_HEIGHT * i);
				shape.graphics.lineTo(x_offset + NODE_WIDTH * rows - NODE_WIDTH * i, NODE_HEIGHT * rows + NODE_HEIGHT * i);
			}
			for (i = 0; i < rows + 1; i++) {
				shape.graphics.moveTo(x_offset + NODE_WIDTH * i, NODE_HEIGHT * i);
				shape.graphics.lineTo(x_offset - NODE_WIDTH * cells + NODE_WIDTH * i, NODE_HEIGHT * cells + NODE_HEIGHT * i);
			}
			
			grid = null;
			grid = new BitmapData(x_offset * 2/*shape.width + gridThick*/, shape.height + gridThick, true, (gridBacking) ? 0x44ffff00 : 0x00000000);
			grid.draw(shape);
			
			gridBitmap.bitmapData = grid;
			gridBitmap.smoothing = true;
			
			for (i = 0; i < cells; i++) {
				if (markersData.length <= i) markersData.push(new Vector.<Object>);
				for (var j:int = 0; j < rows; j++) {
					if (markersData[i].length <= j) {
						markersData[i].push( { z:0, w:0, b:0, p:0 } );
					}
				}
			}
			
			// Clear
			if (markersData.length > cells) {
				markersData.splice(cells, markersData.length - cells);
			}
			if (markersData.length > 0 && markersData[0].length > rows) {
				for (i = 0; i < markersData.length; i++) {
					markersData[i].splice(rows, markersData[i].length - rows);
				}
			}
			
			//var encoder:PNGEncoder = new PNGEncoder();
			//var bytes:ByteArray = encoder.encode(grid);
			//
			//var file:File = new File('d:/grid_160x160.png');
			//
			//var stream:FileStream = new FileStream(); 
			//stream.open(file, FileMode.WRITE); 
			//stream.writeBytes(bytes);
			//stream.close();
			
			updateGridColor();
			
			mapCont.graphics.beginFill(0xff0000, 0);
			mapCont.graphics.drawRect( gridCont.x, -1000 + gridCont.y, gridCont.width, gridCont.height + 2000 + gridCont.y);
			mapCont.graphics.endFill();
		}
		
		public function updateGridColor():void {
			var x_offset:int = NODE_WIDTH * Math.max(Map.cells, Map.rows);
			var i:int, j:int;
			var keysList:Array = [];
			
			if (main.zonesOnBttn.selected) {
				for (i = 0; i < markersData.length; i++) {
					for (j = 0; j < markersData[i].length; j++) {
						grid.floodFill(x_offset - i * NODE_WIDTH + j * NODE_WIDTH, i * NODE_HEIGHT + j * NODE_HEIGHT + NODE_HEIGHT * 0.5, main.getZoneColor(markersData[i][j].z)/*main.colors[markersData[i][j].z]*/);
					}
				}
			}else {
				for (i = 0; i < markersData.length; i++) {
					for (j = 0; j < markersData[i].length; j++) {
						keysList.length = 0;
						for (var key:String in Map.openTile) {
							if (key == 'z') continue;
							if (markersData[i][j][key] == 1) {
								keysList.push(key);
							}
						}
						
						grid.floodFill(x_offset - i * NODE_WIDTH + j * NODE_WIDTH, i * NODE_HEIGHT + j * NODE_HEIGHT + NODE_HEIGHT * 0.5, getColor(keysList));
					}
				}
			}
		}
		
		
		public function gridFloodZone(keys:Object, fromX:int = 0, fromY:int = 0, cells:int = 1, rows:int = 1):void {
			var x_offset:int = NODE_WIDTH * Math.max(Map.cells, Map.rows);
			var color:uint = main.zoneColor;
			var keysList:Array = [];
			
			for (var i:int = fromX; i < fromX + cells; i++) {
				for (var j:int = fromY; j < fromY + rows; j++) {
					if (i < 0 || j < 0 || i >= Map.cells || j >= Map.rows) continue;
					keysList.length = 0;
					
					for (var key:String in markersData[i][j]) {
						if (keys.hasOwnProperty(key)) {
							markersData[i][j][key] = main.zone;
						}
						if (markersData[i][j][key] > 0) {
							keysList.push(key);
						}
					}
					
					grid.floodFill(x_offset - i * NODE_WIDTH + j * NODE_WIDTH, i * NODE_HEIGHT + j * NODE_HEIGHT + NODE_HEIGHT * 0.5, color);
				}
			}
		}
		public function gridClearZone(keys:Object, fromX:int = 0, fromY:int = 0, cells:int = 1, rows:int = 1):void {
			var x_offset:int = NODE_WIDTH * Math.max(Map.cells, Map.rows);
			
			for (var i:int = fromX; i < fromX + cells; i++) {
				if (i < 0 || i >= Map.cells) continue;
				
				for (var j:int = fromY; j < fromY + rows; j++) {
					if (j < 0 || j >= Map.rows) continue;
					
					markersData[i][j]['z'] = 0;
					
					grid.floodFill(x_offset - i * NODE_WIDTH + j * NODE_WIDTH, i * NODE_HEIGHT + j * NODE_HEIGHT + NODE_HEIGHT * 0.5, 0x00000000);
				}
			}
		}
		public function gridFlood(keys:Object, fromX:int = 0, fromY:int = 0, cells:int = 1, rows:int = 1):void {
			var x_offset:int = NODE_WIDTH * Math.max(Map.cells, Map.rows);
			var keysList:Array = [];
			
			for (var i:int = fromX; i < fromX + cells; i++) {
				for (var j:int = fromY; j < fromY + rows; j++) {
					if (i < 0 || j < 0 || i >= Map.cells || j >= Map.rows) continue;
					keysList.length = 0;
					
					/*for (var key:String in markersData[i][j]) {
						if (keys.hasOwnProperty(key)) {
							markersData[i][j][key] = 1;
						}
						if (key != 'z' && markersData[i][j][key] == 1) {
							keysList.push(key);
						}
					}*/
					
					for (var key:String in keys) {
						markersData[i][j][key] = 1;
						keysList.push(key);
					}
					
					grid.floodFill(x_offset - i * NODE_WIDTH + j * NODE_WIDTH, i * NODE_HEIGHT + j * NODE_HEIGHT + NODE_HEIGHT * 0.5, getColor(keysList));
				}
			}
		}
		public function gridClear(keys:Object, fromX:int = 0, fromY:int = 0, cells:int = 1, rows:int = 1):void {
			var x_offset:int = NODE_WIDTH * Math.max(Map.cells, Map.rows);
			var keysList:Array = [];
			
			for (var i:int = fromX; i < fromX + cells; i++) {
				if (i < 0 || i >= Map.cells) continue;
				
				for (var j:int = fromY; j < fromY + rows; j++) {
					if (j < 0 || j >= Map.rows) continue;
					keysList.length = 0;
					
					/*for (var key:String in markersData[i][j]) {
						if (keys.hasOwnProperty(key)) {
							markersData[i][j][key] = 0;
						}
						if (markersData[i][j][key] == 1) {
							keysList.push(key);
						}
					}
					
					grid.floodFill(x_offset - i * NODE_WIDTH + j * NODE_WIDTH, i * NODE_HEIGHT + j * NODE_HEIGHT + NODE_HEIGHT * 0.5, getColor(keysList));*/
					
					for (var key:String in keys) {
						markersData[i][j][key] = 0;
					}
					
					grid.floodFill(x_offset - i * NODE_WIDTH + j * NODE_WIDTH, i * NODE_HEIGHT + j * NODE_HEIGHT + NODE_HEIGHT * 0.5, 0x00000000);
				}
			}
		}
		public function gridFill(keys:Object, fromX:int, fromY:int):void {
			if (fromX < 0 || fromX >= Map.cells || fromY < 0 || fromY >= Map.rows) return;
			
			var x_offset:int = NODE_WIDTH * Math.max(Map.cells, Map.rows);
			var keysList:Array = [];
			var count:int;
			var point:Object;
			var points:Object = { };
			var prepoints:Object = { };
			var old:Object = { };
			var oldPoints:Object = { };
			var canFill:Boolean = false;
			var color:uint = 0x00000000;
			
			for (var key:String in markersData[fromX][fromY])
				old[key] = markersData[fromX][fromY][key];
			
			for (key in keys) {
				keysList.push(key);
				
				if (old[key] != 1)
					canFill = true;
			}
			
			if (!canFill) return;
			
			color = getColor(keysList);
			
			floodFill(fromX, fromY, color);
			
			points[fromX.toString() + '_' + fromY.toString()] = { x:fromX, y:fromY };
			count = 1;
			
			while (count > 0) {
				
				count = 0;
				prepoints = { };
				
				for (var pid:String in points) {
					if (pid in oldPoints) continue;
					
					point = points[pid];
					
					if (point.x - 1 >= 0 && !points.hasOwnProperty((point.x - 1).toString() + '_' + point.y.toString())) {
						floodFill(point.x - 1, point.y, color);
					}
					
					if (point.x + 1 < Map.cells && !points.hasOwnProperty((point.x + 1).toString() + '_' + point.y.toString())) {
						floodFill(point.x + 1, point.y, color);
					}
					
					if (point.y - 1 >= 0 && !points.hasOwnProperty(point.x.toString() + '_' + (point.y - 1).toString())) {
						floodFill(point.x, point.y - 1, color);
					}
					
					if (point.y + 1 < Map.rows && !points.hasOwnProperty(point.x.toString() + '_' + (point.y + 1).toString())) {
						floodFill(point.x, point.y + 1, color);
					}
					
					oldPoints[pid] = true;
					count ++;
				}
				
				for (pid in prepoints) {
					points[pid] = prepoints[pid];
				}
				
			}
			
			oldPoints = null;
			points = null;
			
			function floodFill(x:int, y:int, color:uint):void {
				for (key in markersData[x][y]) {
					if (old[key] != markersData[x][y][key])
						return;
				}
				
				for (key in keys) {
					markersData[x][y][key] = keys[key];
				}
				
				prepoints[x.toString() + '_' + y.toString()] = { x:x, y:y };
				grid.floodFill(x_offset - x * NODE_WIDTH + y * NODE_WIDTH, x * NODE_HEIGHT + y * NODE_HEIGHT + NODE_HEIGHT * 0.5, getColor(keysList));
			}
		}
		
		private var colorAssets:Object = {
			b:	0x99FF0000,
			p:	0x990000FF,
			w:	0x997FFFFF
		}
		public function getColor(keys:Array, color:uint = 0):uint {
			/*var a:uint = 0;
			var r:uint = 0;
			var g:uint = 0;
			var b:uint = 0;*/
			
			var a:uint = (( color >> 24 ) & 0xFF);
			var r:uint = (( color >> 16 ) & 0xFF);
			var g:uint = (( color >> 8 ) & 0xFF);
			var b:uint = (color & 0xFF);
			
			for each(var key:* in keys) {
				if (!colorAssets.hasOwnProperty(key)) continue;
				
				a = a + (( colorAssets[key] >> 24 ) & 0xFF);
				r = r + (( colorAssets[key] >> 16 ) & 0xFF);
				g = g + (( colorAssets[key] >> 8 ) & 0xFF);
				b = b + (colorAssets[key] & 0xFF);
			}
			
			a /= keys.length;
			r /= keys.length;
			g /= keys.length;
			b /= keys.length;
			
			return ( a << 24 ) | ( r << 16 ) | ( g << 8 ) | b;
			
		}
		
		public function get gridLeftWidth():int {
			return (Map.markersData && Map.markersData.length > 0) ? Map.markersData.length * IsoTile.width * 0.5 : 0;
		}
		
		// персонаж
		public function setRespawnPoint():void {
			var object:Object = IsoConvert.screenToIso(gridCont.mouseX, gridCont.mouseY, true);
			
			if (object.x < 0 || !markersData || markersData.length <= object.z && markersData[object.z].length <= object.x) return;
			
			if (markersData[object.z][object.x]['p'] != 1) {
				Alert.show('Это не проходимая клетка!', 'Персонаж', 0);
				return;
			}
			
			respawnPoint.x = object.x;
			respawnPoint.y = object.z;
			
			createPersonage();
		}
		
		private var personage:Sprite;
		public function createPersonage():void {
			if (!personage) {
				personage = new Sprite();
				//personage.graphics.beginFill(0x000000, 0.85);
				//personage.graphics.moveTo(0, 0);
				//personage.graphics.lineTo(NODE_WIDTH, NODE_HEIGHT);
				//personage.graphics.lineTo(0, NODE_WIDTH);
				//personage.graphics.lineTo( -NODE_WIDTH, NODE_HEIGHT);
				persCont.addChild(personage);
				
				var bitmap:Bitmap = new Bitmap(personageBMD);
				bitmap.alpha = 0.85;
				bitmap.x = -bitmap.width * 0.5 + 2;
				bitmap.y = -bitmap.height + 15;
				personage.addChild(bitmap);
			}
			
			var object:Object = IsoConvert.isoToScreen(respawnPoint.x, respawnPoint.y, true);
			
			personage.x = object.x;
			personage.y = object.y;
		}
		
		
		public function showInfo(type:String = ''):void {
			var text:String = 'SHIFT - рисовать\nCTRL - стирать\nG - перемещать сетку относительно карты\nR - установить точку респауна';
			
			switch(type) {
				case 'fader':
					text = 'SPACE - установить точку\nESC - завершить рисование области';
					break;
			}
			
			infoLabel.text = text;
			infoLabel.height = infoLabel.textHeight + 4;
		}
		
		
		
		
		public static function get mapWidth():int {
			return grid.width;
		}
		
	}
}