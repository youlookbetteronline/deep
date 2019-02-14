package 
{
	
	import com.greensock.TweenLite;
	import enixan.Anime;
	import enixan.BitmapLoader;
	import enixan.Util;
	import enixan.components.Button;
	import enixan.components.ComponentBase;
	import enixan.components.List;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import mx.controls.Alert;
	
	public class MainView extends Sprite
	{
		
		[Embed(source = "../res/tile.jpg")]
		private var Grass:Class;
		private var grass:BitmapData = new Grass().bitmapData;
		
		public static var smoothing:Boolean = true;
		
		private var backgroundColor:uint = 0x282828;
		public var viewBorders:Boolean = false;
		public var handAreaSize:Boolean = false;
		
		public var layer:Sprite;
		private var back:Sprite;
		private var stageLayer:Sprite;
		private var animLayer:Sprite;
		public var polygonLayer:Sprite;
		private var roadLayer:ComponentBase;
		public var gridLayer:Sprite;
		public var pointLayer:Sprite;
		public var upLayer:Sprite;
		public var alertLabel:TextField;
		
		public var multiAnim:Boolean = Main.storage.multiAnim;
		
		public var viewInfo:Object;
		public var stages:Vector.<StageCo>;
		public var anims:Vector.<AnimCo>;
		private var previews:Array;
		
		private var layerCenter:Point;
		private var layerOffset:Point;
		
		public function MainView() {
			
			layerCenter = new Point();
			layerOffset = new Point();
			
			layer = new Sprite();
			addChild(layer);
			
			back = new Sprite();
			roadLayer = new ComponentBase();
			stageLayer = new Sprite();
			animLayer = new Sprite();
			polygonLayer = new Sprite();
			gridLayer = new Sprite();
			pointLayer = new Sprite();
			upLayer = new Sprite();
			
			back.graphics.beginFill(0xcc0000, 1);
			back.graphics.drawCircle(0, 0, 2);
			back.graphics.endFill();
			
			back.graphics.lineStyle(1, 0xffff00, 0.05);
			back.graphics.moveTo( -300, 0 );
			back.graphics.lineTo( 300, 0 );
			back.graphics.moveTo( -0.5, -150 );
			back.graphics.lineTo( -0.5, 150 );
			back.graphics.moveTo( 0, 0 );
			back.graphics.lineTo( -235, 182 );
			back.graphics.moveTo( 0, 0 );
			back.graphics.lineTo( 235, 182 );
			
			layer.addChild(roadLayer);
			layer.addChild(gridLayer);
			layer.addChild(back);
			layer.addChild(stageLayer);
			layer.addChild(animLayer);
			layer.addChild(polygonLayer);
			layer.addChild(pointLayer);
			layer.addChild(upLayer);
			
			stages = new Vector.<StageCo>;
			anims = new Vector.<AnimCo>;
			previews = [];
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			addEventListener(MouseEvent.MIDDLE_CLICK, onMouseMiddleClick);
			addEventListener(MouseEvent.RIGHT_CLICK, onMouseRightClick);
			addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseRightDown);
			addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseRightUp);
			
			
			alertLabel = Util.drawText( {
				text:		' ',
				width:		300,
				height:		60,
				size:		44,
				color:		0xffffff,
				textAlign:	TextFormatAlign.CENTER
			});
			alertLabel.filters = [new GlowFilter(0xffffff, 0.5, 6, 6)];
			addChild(alertLabel);
			
			resize();
			
		}
		
		
		
		
		/**
		 * Спрайт находится в списке отрисовки
		 */
		public function inViewList(content:*):Object {
			for (var i:int = 0; i < stages.length; i++) {
				if (stages[i].sprite == content || stages[i].bitmap == content || stages[i].item == content)
					return stages[i];
			}
			
			for (i = 0; i < anims.length; i++) {
				if (anims[i].sprite == content || anims[i].bitmap == content || anims[i].item == content)
					return anims[i];
			}
			
			return null;
		}
		
		
		
		/**
		 * Сетка
		 */
		public function grid(rows:int = 1, cells:int = 1):void {
			
			const color:uint = 0xff6600;
			
			var scale:int = 1;
			var halfWidth:Number = IsoTile.WIDTH * 0.5;
			var halfHeight:Number = IsoTile.HEIGHT * 0.5;
			
			if (cells > 40) cells = 40;
			if (rows > 40) rows = 40;
			
			gridLayer.graphics.clear();
			
			if (cells <= 0 || rows <= 0) {
				gridResizerClear();
				return;
			}
			
			gridLayer.graphics.lineStyle(1, color);
			gridLayer.graphics.beginFill(color, 0.25);
			gridLayer.graphics.moveTo(0, 0);
			gridLayer.graphics.lineTo(-halfWidth * rows * scale, halfHeight * rows);
			gridLayer.graphics.lineTo((-halfWidth * rows + halfWidth * cells) * scale, halfHeight * rows + halfHeight * cells);
			gridLayer.graphics.lineTo(halfWidth * cells * scale, halfHeight * cells);
			gridLayer.graphics.endFill();
			
			for (var i:int = 1; i < rows; i++) {
				gridLayer.graphics.moveTo(-halfWidth * i * scale, halfHeight * i);
				gridLayer.graphics.lineTo((-halfWidth * i + halfWidth * cells) * scale, halfHeight * i + halfHeight * cells);
			}
			for (i = 1; i < cells; i++) {
				gridLayer.graphics.moveTo(halfWidth * i * scale, halfHeight * i);
				gridLayer.graphics.lineTo((-halfWidth * rows + halfWidth * i) * scale, halfHeight * rows + halfHeight * i);
			}
			
			if (!gridResizer || !gridResizer.hasEventListener(Event.ENTER_FRAME))
				gridResizerShow(new Point(halfWidth * (cells - rows), halfHeight * (cells + rows)));
		}
		
		
		
		private var gridResizer:Sprite;
		private function gridResizerShow(point:Point):void {
			if (!gridResizer) {
				gridResizer = new Sprite();
				gridResizer.name = 'gridResizer';
				gridLayer.addChild(gridResizer);
				
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0xff6600, 1);
				shape.graphics.drawCircle(0, 0, 4);
				shape.graphics.endFill();
				
				var circle:Bitmap = new Bitmap(new BitmapData(10, 10, true, 0));
				circle.bitmapData.draw(shape, new Matrix(1,0,0,1,5,5));
				circle.x = -5;
				circle.y = -5;
				gridResizer.addChild(circle);
			}
			
			gridResizer.visible = true;
			gridResizer.x = point.x;
			gridResizer.y = point.y + 5;
		}
		private function gridResizerClear():void {
			if (gridResizer) gridResizer.visible = false;
		}
		private function gridResizerStart():void {
			Main.app.addEventListener(MouseEvent.MOUSE_UP, gridMouseUp);
			gridResizer.addEventListener(Event.ENTER_FRAME, gridEnterFrame);
			gridResizer.startDrag(false);
		}
		private function gridMouseUp(e:MouseEvent):void {
			Main.app.removeEventListener(MouseEvent.MOUSE_UP, gridMouseUp);
			gridResizer.removeEventListener(Event.ENTER_FRAME, gridEnterFrame);
			gridResizer.stopDrag();
			
			handAreaSize = true;
			
			var point:Point = IsoTile.poleToIso(new Point(gridResizer.x, gridResizer.y));
			point = IsoTile.isoToPole(point);
			TweenLite.to(gridResizer, 0.15, { x:point.x, y:point.y + 5 } );
		}
		private function gridEnterFrame(e:Event):void {
			var point:Object = IsoTile.poleToIso(new Point(gridResizer.x, gridResizer.y));
			grid(point.y, point.x);
			Main.app.viewManager.areaSize(point.x, point.y);
		}
		
		
		
		
		
		/**
		 * Возвращает параметры сетки
		 */
		private function drawRoundPixels(bitmap:BitmapData, point:Point):Point {
			var vector:Vector.<uint> = bitmap.getVector(new Rectangle(0, 0, bitmap.width, bitmap.height));
			
			var width:int = bitmap.width;
			var height:int = bitmap.height * 0.3;
			var startY:int = bitmap.height - height;
			var pos:Object = {
				x:point.x + bitmap.width * 0.5,
				y:bitmap.width,
				xmin:point.x + bitmap.width * 0.5,
				ymin:bitmap.width,
				xmax:point.x + bitmap.width * 0.5,
				ymax:bitmap.width
			};
			
			if (height < 0) height = 0;
			if (height > bitmap.height) height = bitmap.height;
			
			var lilVector:Array = new Array();
			for	(var j:int = vector.length - width * height; j < vector.length; j++) {
				lilVector.push(vector[j]);
			}
			
			var object:Object = { };
			for (j = 0; j < height; j++){
				for (var g:int = 0; g < width; g++) {
					var a:uint = ((lilVector[g + j * width] >> 24) & 0xFF);
					if (a > 200) {
						object[j+startY] = { };
						object[j+startY][g] = { };
						object[j+startY][g] = a;
						break;
					}
				}
			}
			
			for (j = height - 1; j > 0; j--){
				for (g = width - 1; g > 0; g--) {
					a = ((lilVector[g + j * width] >> 24) & 0xFF);
					if (a > 200) {
						object[j+startY][g] = a;
						break;;
					};
				}
			}
			
			var CoordYmax:int;
			var CoordXmin:int;
			var CoordXmax:int;
			for (var y:* in object) {
				for (var x:* in object[y]) {
					
					if (!CoordXmin || x < CoordXmin){
						CoordXmin = x;
						pos.xmin = x + point.x;
						pos.ymin = y + point.y;
					}
					
					else if (!CoordXmax || x > CoordXmax){
						CoordXmax = x;
						pos.xmax = x + point.x;
						pos.ymax = y + point.y;
					}
					
					if (!CoordYmax || y > CoordYmax){
						CoordYmax = y;
						pos.x = x + point.x;
						pos.y = y + point.y;
					}
				}
			}
			var sizeX:Number = IsoTile.WIDTH * 0.5;
			var sizeY:Number = IsoTile.HEIGHT * 0.5;
			
			var rows:int = Math.ceil((pos.y / sizeY - pos.x / sizeX) / 2);
			var cells:int = Math.ceil(pos.x / sizeX + (pos.y / sizeY - pos.x / sizeX) / 2);
			
			var rowsmax:int = Math.ceil((pos.ymin / sizeY - pos.xmin / sizeX) / 2);
			var cellsmax:int = Math.ceil(pos.xmax / sizeX + (pos.ymax / sizeY - pos.xmax / sizeX) / 2);
			
			if (rows <= 0 || cells <= 0 || (rows <= 0 && cells <= 0))
				return new Point(0, 0);
				
			else if (rows < rowsmax)
				rows = rowsmax;
				
			else if (cells < cellsmax)
				cells = cellsmax;
			
			return new Point(rows, cells);
		}
		
		
		/**
		 * Параметры проигрывания анимации
		 */
		private var __play:Boolean;
		public function set play(value:Boolean):void {
			if (__play == value) return;
			
			__play = value;
			
			if (__play) {
				addEventListener(Event.ENTER_FRAME, Main.app.onFrame);
			}else {
				removeEventListener(Event.ENTER_FRAME, Main.app.onFrame);
			}
		}
		public function get play():Boolean {
			return __play;
		}
		
		
		/**
		 * Дорожка под ходячими
		 */
		private var roadMask:Shape;
		private var roadView:Sprite;
		public function set road(value:Boolean):void {
			
			const NODEW:int = 40;
			const NODEH:int = 21;
			const LENGTH:int = 10;
			const WIDTH:int = 4;
			
			roadLayer.removeChildren();
			
			if (!value) {
				roadMask = null;
				roadView = null;
				return;
			}
			
			roadMask = new Shape();
			roadMask.graphics.beginFill(0xff0000, 1);
			roadMask.graphics.moveTo(NODEW * 0.5 * (LENGTH - WIDTH), NODEH * 0.5 * ( -LENGTH - WIDTH));
			roadMask.graphics.lineTo(NODEW * 0.5 * (LENGTH + WIDTH + 1), NODEH * 0.5 * (WIDTH + 1 - LENGTH));
			roadMask.graphics.lineTo(NODEW * 0.5 * (-LENGTH + WIDTH), NODEH * 0.5 * (LENGTH + WIDTH + 2));
			roadMask.graphics.lineTo(NODEW * 0.5 * (-LENGTH - WIDTH - 1), NODEH * 0.5 * (LENGTH + 1 - WIDTH));
			roadMask.graphics.endFill();
			
			roadMask.filters = [new BlurFilter(10, 10)];
			
			//roadMask.graphics.beginFill(0xff0000, 0.5);
			//roadMask.graphics.drawCircle(NODEW * 0.5 * (LENGTH - WIDTH), NODEH * 0.5 * ( -LENGTH - WIDTH), 5);
			//roadMask.graphics.endFill();
			
			//roadMask.graphics.beginFill(0xffff00, 0.5);
			//roadMask.graphics.drawCircle(NODEW * 0.5 * (LENGTH + WIDTH + 1), NODEH * 0.5 * (WIDTH + 1 - LENGTH), 5);
			//roadMask.graphics.endFill();
			
			//roadMask.graphics.beginFill(0x00ff00, 0.5);
			//roadMask.graphics.drawCircle(NODEW * 0.5 * (-LENGTH + WIDTH), NODEH * 0.5 * (LENGTH + WIDTH + 2), 5);
			//roadMask.graphics.endFill();
			
			//roadMask.graphics.beginFill(0x00ffff, 0.5);
			//roadMask.graphics.drawCircle(NODEW * 0.5 * (-LENGTH - WIDTH - 1), NODEH * 0.5 * (LENGTH + 1 - WIDTH), 5);
			//roadMask.graphics.endFill();
			
			
			roadView = new Sprite();
			roadLayer.addChild(roadView);
			roadLayer.addChild(roadMask);
			
			roadView.mask = roadMask;
			roadView.cacheAsBitmap = true;
			roadMask.cacheAsBitmap = true;
			
			for (var i:int = 0; i < 9; i++) {
				var bitmap:Bitmap = new Bitmap(grass, 'auto', true);
				bitmap.x = grass.width * ((i % 3) - 2);
				bitmap.y = grass.height * (int(i / 3) - 1);
				roadView.addChild(bitmap);
			}
			
		}
		public function get road():Boolean {
			return Boolean(roadMask);
		}
		
		
		/**
		 * Изменение размера рабочего поля
		 */
		public function resize():void {
			setBackgroundColor(backgroundColor);
			
			layerCenter.x = int(Main.appWidth * 0.5);
			layerCenter.y = int(Main.appHeight * 0.45);
			
			alertLabel.x = layerCenter.x - alertLabel.width * 0.5;
			alertLabel.y = 80;
			
			resetLayer();
		}
		public function resetLayer():void {
			layer.scaleX = layer.scaleY = 1;
			layer.x = layerCenter.x + layerOffset.x;
			layer.y = layerCenter.y + layerOffset.y;
			
			//wheelHandler();
		}
		
		
		/**
		 * Отразить
		 */
		private var __flip:Boolean;
		public function set flip(value:Boolean):void {
			__flip = value;
			
			animLayer.scaleX = (__flip) ? -1 : 1;
			stageLayer.scaleX = animLayer.scaleX;
			pointLayer.scaleX = animLayer.scaleX;
			roadLayer.scaleX = animLayer.scaleX;
			gridLayer.scaleX = animLayer.scaleX;
		}
		public function get flip():Boolean {
			return __flip;
		}
		
		
		
		
		/**
		 * 
		 */
		public static var velocity:Number = 0.15;
		private var roadValueX:Number = 0;
		private function roadStep():void {
			if (!roadView || multiAnim) return;
			
			roadValueX += MainView.velocity * 20 / grass.width;
			
			roadView.x = grass.width * (roadValueX % 1);
			roadView.y = -((grass.height * roadValueX * 21 / 40) % grass.height);
		}
		
		
		/**
		 * Цвет фона главного вида
		 */
		public function setBackgroundColor(color:uint = 0x111111):void {
			
			Main.storage['backgroundColor'] = color;
			backgroundColor = color;
			
			graphics.clear();
			graphics.beginFill(backgroundColor, 1);
			graphics.drawRect(0, 0, Main.appWidth, Main.appHeight);
			graphics.endFill();
		}
		
		
		
		/**
		 * Добавление вида (стадия или анимация)
		 */
		public function addView(viewInfo:ViewInfo):* {
			
			var itemCo:*;
			
			if (previews.indexOf(viewInfo) == -1) {
				previews.push(viewInfo);
				
				var sprite:Sprite = new Sprite();
				sprite.x = viewInfo.x;
				sprite.y = viewInfo.y;
				
				var bitmap:Bitmap = new Bitmap(viewInfo.bitmapData);
				bitmap.smoothing = MainView.smoothing;
				sprite.addChild(bitmap);
				
				focused = bitmap;
				
				if (viewInfo is AnimInfo) {
					animLayer.addChild(sprite);
					itemCo = new AnimCo(sprite, bitmap, viewInfo as AnimInfo);
					anims.push(itemCo);
					
					if ((viewInfo as AnimInfo).indents && (viewInfo as AnimInfo).indents.length > 0 && (viewInfo as AnimInfo).indents[0]) {
						bitmap.x = (viewInfo as AnimInfo).indents[0].x;
						bitmap.y = (viewInfo as AnimInfo).indents[0].y;
					}
					
					road = (!multiAnim) ? (viewInfo as AnimInfo).road : false;
					if (!handAreaSize) grid();
					
				}else {
					stageLayer.addChild(sprite);
					itemCo = new StageCo(sprite, bitmap, viewInfo as StageInfo);
					stages.push(itemCo);
					
					checkHidden(itemCo);
				}
				
				sourceBorder(itemCo, viewBorders);
			}
			
			initPoints();
			
			return itemCo;
		}
		public function clearViews(viewInfo:ViewInfo = null):void {
			
			for (var i:int = 0; i < stages.length; i++) {
				var stageCo:StageCo = stages[i];
				if (stageCo.item.extra.lock) continue;
				if (viewInfo && stageCo.item != viewInfo) continue;
				
				previews.splice(previews.indexOf(viewInfo), 1);
				stages.splice(i, 1);
				i--;
				
				if (stageLayer.contains(stageCo.sprite))
					stageLayer.removeChild(stageCo.sprite);
			}
			
			if (multiAnim) return;
			
			for (i = 0; i < anims.length; i++) {
				var animCo:AnimCo = anims[i];
				if (viewInfo && viewInfo != animCo.item) continue;
				
				previews.splice(previews.indexOf(animCo.item), 1);
				anims.splice(i, 1);
				i--;
				
				if (animLayer.contains(animCo.sprite))
					animLayer.removeChild(animCo.sprite);
			}
		}
		
		
		
		public function checkHidden(itemCo:*):void {
			itemCo.sprite.alpha = (itemCo && itemCo.item && itemCo.item.hasOwnProperty('extra') && itemCo.item.extra && itemCo.item.extra.hidden) ? 0.4 : 1;
		}
		
		
		
		/**
		 * Обновление видов
		 */
		public function review(viewInfo:ViewInfo = null, notClearPreview:Boolean = false):void {
			
			var need:Array = [];
			for (var i:int = 0; i < Main.app.stageManager.content.length; i++) {
				//if (Main.app.stageManager.content[i] == Main.app.stageManager.focusedNode)
				if (Main.app.stageManager.focusedNodes.indexOf(Main.app.stageManager.content[i]) > -1)
					need.push(Main.app.stageManager.content[i].data.item);
				if (Main.app.stageManager.content[i].lockBox.check == true)
					need.push(Main.app.stageManager.content[i].data.item);
			}
			
			for (i = 0; i < Main.app.animListManager.content.length; i++) {
				if (Main.app.animationsList.indexOf(Main.app.animListManager.content[i].data.item) == -1)
					continue;
				
				if (multiAnim) {
					need.push(Main.app.animListManager.content[i].data.item);
				//}else if (Main.app.animListManager.content[i] == Main.app.animListManager.focusedNode) {
				}else if (Main.app.animListManager.focusedNodes.indexOf(Main.app.animListManager.content[i]) > -1) {
					need.push(Main.app.animListManager.content[i].data.item);
				}
			}
			
			if (!notClearPreview) {
				for (i = 0; i < stages.length; i++) {
					if (need.indexOf(stages[i].item) < 0) {
						if (stages[i].item.name == 'walk')
							road = false;
						
						if (stageLayer.contains(stages[i].sprite))
							stageLayer.removeChild(stages[i].sprite);
						
						previews.splice(previews.indexOf(stages[i].item), 1);
						stages.splice(i, 1);
						i--;
					}else {
						need.splice(need.indexOf(stages[i].item), 1);
					}
				}
				
				for (i = 0; i < anims.length; i++) {
					if (need.indexOf(anims[i].item) < 0) {
						if (animLayer.contains(anims[i].sprite))
							animLayer.removeChild(anims[i].sprite);
						
						previews.splice(previews.indexOf(anims[i].item), 1);
						anims.splice(i, 1);
						i--;
					}else {
						need.splice(need.indexOf(anims[i].item), 1);
					}
				}
			}
			
			if (need.length == 1) {
				this.viewInfo = need[0];
			}else if(need.length > 1){
				this.viewInfo = null;
			}
			
			for (i = 0; i < need.length; i++) {
				addView(need[i]);
			}
			
		}
		
		
		/**
		 * Очистить поле
		 */
		public function clear():void {
			handAreaSize = false;
			pointLayer.removeChildren();
			review();
		}
		
		
		
		/**
		 * Добавление стадии по информации о стадии (StageInfo)
		 */
		public function isLockBySprite(sprite:Sprite):Boolean {
			for (var i:int = 0; i < stages.length; i++) {
				if (stages[i].sprite == sprite && stages[i].item.extra.lock)
					return true;
			}
			
			for (i = 0; i < anims.length; i++) {
				if (anims[i].sprite == sprite && anims[i].item.extra.lock)
					return true;
			}
			
			return false;
		}
		
		
		public function animationUpdate():void {
			
			var prevFrame:int;
			var frameIndex:int;
			
			for each(var object:Object in anims) {
				var animInfo:AnimInfo = object.item;
				
				prevFrame = animInfo.chain[animInfo.frame];
				animInfo.frame ++;
				
				if (animInfo.chain.length <= animInfo.frame)
					animInfo.frame = 0;
				
				//if (prevFrame != animInfo.chain[animInfo.frame])
					//object.bitmap.bitmapData = animInfo.bmds[animInfo.chain[animInfo.frame]];
				
				frameIndex = animInfo.chain[animInfo.frame]
				if (prevFrame != frameIndex) {
					object.bitmap.bitmapData = animInfo.bmds[frameIndex];
					object.bitmap.smoothing = MainView.smoothing;
					
					if (animInfo.indents && animInfo.indents[frameIndex]) {
						object.bitmap.x = animInfo.indents[frameIndex].x;
						object.bitmap.y = animInfo.indents[frameIndex].y;
					}
				}
			}
			
			roadStep();
		}
		public function animationSetChainframe(frame:int, animInfo:AnimInfo):void {
			for each(var object:Object in anims) {
				if (object.item == animInfo || multiAnim) {
					var info:AnimInfo = object.item;
					if (frame < 0 || frame >= info.chain.length) continue;
					
					info.frame = frame;
					object.bitmap.bitmapData = info.bmds[info.chain[animInfo.frame]];
					
					if (info.indents && info.indents[info.chain[info.frame]]) {
						object.bitmap.x = info.indents[info.chain[info.frame]].x;
						object.bitmap.y = info.indents[info.chain[info.frame]].y;
					}
				}
			}
		}
		public function animationSetFrame(frame:int, animInfo:AnimInfo):void {
			for each(var object:Object in anims) {
				if (object.item == animInfo || multiAnim) {
					var info:AnimInfo = object.item;
					if (frame < 0 || frame >= info.bmds.length) continue;
					
					info.frame = frame;
					object.bitmap.bitmapData = info.bmds[animInfo.frame];
					
					if (info.indents && info.indents[info.chain[info.frame]]) {
						object.bitmap.x = info.indents[info.chain[info.frame]].x;
						object.bitmap.y = info.indents[info.chain[info.frame]].y;
					}
				}
			}
		}
		
		
		/**
		 * 
		 */
		private function getDraged(child:DisplayObject):Sprite {
			
			while (child) {
				
				if (!child.parent)
					return null;
				
				child = child.parent;
				
				if (child.parent == pointLayer || child.parent == animLayer || child.parent == stageLayer || child.parent == gridLayer)
					return child as Sprite;
			}
			
			return null;
		}
		
		
		/**
		 * 
		 */
		private function getInterActiveElement(displayObject:DisplayObject):Boolean {
			
			if (!displayObject)
				return false;
			
			viewInfo = null;
			
			var container:DisplayObject;
			for (var i:int = 0; i < stages.length; i++) {
				if (stages[i].bitmap == displayObject) {
					viewInfo = stages[i].item;
					Main.app.stageManager.selectByInfo(stages[i].item);
					return true;
				}
			}
			for (i = 0; i < anims.length; i++) {
				if (anims[i].bitmap == displayObject) {
					viewInfo = anims[i].item;
					Main.app.animListManager.selectByInfo(anims[i].item);
					return true;
				}
			}
			for (i = 0; i < pointLayer.numChildren; i++) {
				container = pointLayer.getChildAt(i);
				if (displayObject.parent && displayObject.parent.parent == container)
					return true;
			}
			
			return false;
		}
		
		
		/**
		 * Смещение объекта в фокусе (тот что был последним выделен)
		 */
		public function move(x:int, y:int):void {
			if (!focused || !focused.parent) return;
			
			focused.parent.x += x;
			focused.parent.y += y;
			Main.app.viewManager.position(focused.parent.x, focused.parent.y);
			
			if (focused.parent is PointTarget && Main.shift) {
				for (i = 0; i < pointLayer.numChildren; i++) {
					var child:PointTarget = pointLayer.getChildAt(i) as PointTarget;
					if (child == focused.parent) continue;
					child.x += x;
					child.y += y;
				}
				return;
			}
			
			var target:Object;
			for (var i:int = 0; i < stages.length; i++) {
				if (stages[i].bitmap == focused)
					target = stages[i];
			}
			for (i = 0; i < anims.length; i++) {
				if (anims[i].bitmap == focused)
					target = anims[i];
			}
			if (!target) return;
			target.item.x = focused.parent.x;
			target.item.y = focused.parent.y;
			
			if (!Main.shift) return;
			
			for (i = 0; i < Main.app.stagesList.length; i++) {
				if (target.item == Main.app.stagesList[i]) continue;
				Main.app.stagesList[i].x += x;
				Main.app.stagesList[i].y += y;
			}
			for (i = 0; i < Main.app.animationsList.length; i++) {
				if (target.item == Main.app.animationsList[i]) continue;
				Main.app.animationsList[i].x += x;
				Main.app.animationsList[i].y += y;
			}
		}
		public function moveTo(x:int, y:int):void {
			if (!focused || !focused.parent) return;
			
			var item:Object = inViewList(focused);
			if (!item.item) return;
			
			item.item.x = x;
			item.item.y = y;
			item.sprite.x = x;
			item.sprite.y = y;
			//Main.app.viewManager.position(item.sprite.x, item.sprite.y);
		}
		
		
		
		/**
		 * Выделение и перемещение елементов
		 */
		private var startPoint:Point;
		private var focused:Bitmap;
		private var draged:Sprite;
		private var dragedMove:int;
		private var prevX:int;
		private var prevY:int;
		private var multiMove:Boolean;
		private var layerMove:Boolean;
		private function onMouseDown(e:MouseEvent):void {
			
			prevX = mouseX;
			prevY = mouseY;
			
			// Перемещение главного поля
			if (Main.mainCanvasMove) {
				layerMove = true;
				layer.startDrag(false);
				addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				return;
			}
			
			var bitmap:Bitmap = getFirstBitmapUnderMouse();
			
			if (focused != bitmap)
				focused = bitmap;
			
			dragedMove = 0;
			draged = getDraged(focused);
			
			Main.clearFocus();
			
			if (!draged) {
				//Main.clearFocus();
				return;
			}
			
			//clearDeletePoint();
			
			// Клонирует объект при зажатом SHIFT и специальных условиях
			var clone:Sprite = cloneTargetIfNeed();
			if (clone) {
				draged = clone;
				
				// Отключить мультиперемещение если клонируется объект
				Main.shift = false;
			}
			
			if (Main.shift) {
				multiMove = true;
				startPoint = new Point(draged.x, draged.y);
			}
			
			if (draged.name == 'gridResizer') {
				gridResizerStart();
				return;
			}
			
			if (draged is PointTarget) {
				Main.app.viewManager.view(draged);
				for (var i:int = 0; i < pointLayer.numChildren; i++) {
					var child:PointTarget = pointLayer.getChildAt(i) as PointTarget;
					child.savePosition();
				}
			}
			
			draged.startDrag(false);
			draged.alpha = 0.7;
			
			if (draged.parent.getChildIndex(draged) != draged.parent.numChildren - 1 && !isLockBySprite(draged))
				draged.parent.swapChildrenAt(draged.parent.getChildIndex(draged), draged.parent.numChildren - 1);
			
			getInterActiveElement(focused);
			
			addEventListener(Event.ENTER_FRAME, onUnitMove);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		private function onMouseUp(e:MouseEvent):void {
			
			removeEventListener(Event.ENTER_FRAME, onUnitMove);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			// Обработка данных смещения рабочего поля
			if (layerMove) {
				layerMove = false;
				layerOffset.x = layer.x - layerCenter.x;
				layerOffset.y = layer.y - layerCenter.y;
				layer.stopDrag();
				return;
			}
			
			// Обработка данных смещения
			if (!draged) return;
			
			var source:*;
			var index:int = -1;
			
			for (var i:int = 0; i < stages.length; i++) {
				if (stages[i].sprite == draged) {
					if (dragedMove > 1 && !Main.ctrl)
						Main.app.stageManager.find(stages[i].item, false);
					
					checkHidden(stages[i]);
					source = stages;
					index = i;
				}
			}
			for (i = 0; i < anims.length; i++) {
				if (anims[i].sprite == draged) {
					if (dragedMove > 1 && !Main.ctrl)
						Main.app.animListManager.find(anims[i].item, false);
					
					checkHidden(anims[i]);
					source = anims;
					index = i;
				}
			}
			
			if (source && index != -1) {
				if (multiMove) {
					var deltaX:int = draged.x - source[index].item.x;
					var deltaY:int = draged.y - source[index].item.y;
					
					for (i = 0; i < Main.app.stagesList.length; i++) {
						Main.app.stagesList[i].x += deltaX;
						Main.app.stagesList[i].y += deltaY;
					}
					for (i = 0; i < Main.app.animationsList.length; i++) {
						Main.app.animationsList[i].x += deltaX;
						Main.app.animationsList[i].y += deltaY;
					}
				}else {
					source[index].item.x = draged.x;
					source[index].item.y = draged.y;
				}
			}
			
			dragedMove = 0;
			draged.stopDrag();
			//draged.alpha = 1;
			draged = null;
			startPoint = null;
			multiMove = false;
			
		}
		private function onUnitMove(e:Event):void {
			
			dragedMove ++;
			
			if (draged) {
				Main.app.viewManager.position(draged.x, draged.y);
				
				for (var i:int = 0; i < stages.length; i++) {
					if (!handAreaSize && stages[i].sprite == draged) {
						var point:Point = drawRoundPixels(focused.bitmapData, new Point(draged.x, draged.y));
						grid(point.x, point.y);
						Main.app.viewManager.areaSize(point.x, point.y);
					}
				}
				
				if (multiMove) {
					var index:int;
					var deltaX:int = startPoint.x - draged.x;
					var deltaY:int = startPoint.y - draged.y;
					
					if (trackMark) {
						trackMark.x = -deltaX;
						trackMark.y = -deltaY;
					}
					
					if (draged is PointTarget) {
						for (i = 0; i < pointLayer.numChildren; i++) {
							var child:PointTarget = pointLayer.getChildAt(i) as PointTarget;
							if (child == draged) continue;
							child.x = child.currX - deltaX;
							child.y = child.currY - deltaY;
						}
						return;
					}
					
					for (i = 0; i < stages.length; i++) {
						index = Main.app.stagesList.indexOf(stages[i].item);
						if (index < 0) continue;
						stages[i].sprite.x = Main.app.stagesList[index].x - deltaX;
						stages[i].sprite.y = Main.app.stagesList[index].y - deltaY;
					}
					for (i = 0; i < anims.length; i++) {
						index = Main.app.animationsList.indexOf(anims[i].item);
						if (index < 0) continue;
						anims[i].sprite.x = Main.app.animationsList[index].x - deltaX;
						anims[i].sprite.y = Main.app.animationsList[index].y - deltaY;
					}
				}
			}
		}
		private function onWheel(e:MouseEvent):void {
			if (e.delta > 0) {
				layer.scaleX += 0.1;
			}else {
				layer.scaleX -= 0.1;
			}
			
			wheelHandler();
		}
		private function onMouseMove(e:MouseEvent):void {
			if (draged) return;
			
			if (pointLayer.hitTestPoint(mouseX, mouseY, true)) {
				for (var i:int = 0; i < pointLayer.numChildren; i++) {
					var child:DisplayObject = pointLayer.getChildAt(i);
					if (child.visible && child.hitTestPoint(mouseX, mouseY, true))
						return;
				}
			}
		}
		private function onMouseMiddleClick(e:MouseEvent):void {
			
			function getTarget(target:*):* {
				while (target) {
					if (target is PointTarget || target.parent == animLayer || target.parent == stageLayer)
						return target;
					
					target = target.parent;
				}
				
				return null;
			}
			
			var target:* = getTarget(getFirstBitmapUnderMouse());
			
			if (target is PointTarget)
				pointLayer.removeChild(target);
			
			var view:Object = inViewList(target);
			if (view) clearViews(view.item);
			
		}
		private function getFirstBitmapUnderMouse():Bitmap {
			var list:Array = getObjectsUnderPoint(new Point(mouseX, mouseY));
			var bitmap:Bitmap;
			
			for (var i:int = 0; i < list.length; i++) {
				var child:* = list[i];
				
				while (child.parent) {
					if (child is Bitmap && (child as Bitmap).bitmapData.getPixel32(child.mouseX, child.mouseY) != 0) {
						bitmap = child as Bitmap;
						break;
					}
					
					child = child.parent;
				}
			}
			
			return bitmap;
		}
		
		
		
		public function wheelHandler():void {
			
			// Ограничения увеличения и/или уменьшения
			if (layer.scaleX > 0.92 && layer.scaleX < 1.08) {
				layer.scaleX = 1;
			}else if (layer.scaleX < 0.2) {
				layer.scaleX = 0.2;
			}else if (layer.scaleX > 4) {
				layer.scaleX = 4;
			}
			
			layer.scaleY = layer.scaleX;
			
			checkScaleReset();
			
			MessageView.alert((int(layer.scaleX * 1000) / 10).toString() + '%');
		}
		private function checkScaleReset():void {
			Main.app.settingsPanel.scaleResetBttn.visible = Boolean(layer.scaleX != 1);
		}
		
		
		
		private function onMouseRightClick(e:MouseEvent):void {
			
			if (mouseX != prevX || mouseY != prevY) return;
			
			var contextMenu:ContextMenu = new ContextMenu();
			var newProjectCMI:ContextMenuItem = new ContextMenuItem('Новый проект', false, true, true);
			var clearSceneCMI:ContextMenuItem = new ContextMenuItem('Очистить сцену', true, (stages.length > 0 || anims.length > 0 || pointLayer.numChildren > 0) ? true : false, true);
			var addStageCMI:ContextMenuItem = new ContextMenuItem('Добавить пустую стадию', false, true, true);
			
			contextMenu.addItem(newProjectCMI);
			contextMenu.addItem(clearSceneCMI);
			contextMenu.addItem(addStageCMI);
			contextMenu.addEventListener(Event.SELECT, onMenuSelect);
			contextMenu.display(Main.app.appStage, Main.app.appStage.mouseX, Main.app.appStage.mouseY);
			
			function onMenuSelect(e:Event):void {
				contextMenu.removeEventListener(Event.SELECT, onMenuSelect);
				
				if (e.target == newProjectCMI)
					Main.app.onNewProject();
				
				if (e.target == clearSceneCMI)
					clearViews();
				
				if (e.target == addStageCMI)
					Main.app.stageAdd();
			}
		}
		private function onMouseRightDown(e:MouseEvent):void {
			prevX = mouseX;
			prevY = mouseY;
			
			layer.startDrag(false);
		}
		private function onMouseRightUp(e:MouseEvent):void {
			layer.stopDrag();
		}
		
		
		
		/**
		 * Клонирование объекта
		 */
		private function cloneTargetIfNeed():Sprite {
			if (Main.ctrl && draged) {
				var view:Object = inViewList(draged);
				if (view) {
					if (view is AnimCo) {
						var animInfo:AnimInfo = Main.app.animationClone(view.item);
						var animCo:AnimCo = addView(animInfo) as AnimCo;
						
						animCo.sprite.x = draged.x;
						animCo.sprite.y = draged.y;
						
						return animCo.sprite;
					}
					
					if (view is StageCo) {
						var stageInfo:StageInfo = Main.app.stageClone(view.item);
						var stageCo:StageCo = addView(stageInfo) as StageCo;
						
						stageCo.sprite.x = draged.x;
						stageCo.sprite.y = draged.y;
						
						return stageCo.sprite;
					}
				}
				
				/*for (var i:int = 0; i < anims.length; i++) {
					if (anims[i].sprite == draged) {
						var animInfo:AnimInfo = Main.app.animationClone(anims[i].item);
						var animCo:AnimCo = addView(animInfo) as AnimCo;
						
						if (animCo) {
							animCo.sprite.x = draged.x;
							animCo.sprite.y = draged.y;
							
							return animCo.sprite;
						}
					}
				}*/
				
				if (draged is PointTarget) {
					var array:Array = draged.name.split('_');
					var point:PointTarget = addPoint(array[1], { x:draged.x, y:draged.y } );
					
					return point;
				}
			}
			
			return null;
		}
		
		
		
		/**
		 * Создание следа перемещения
		 */
		private var trackMark:Sprite;
		public function createTrackMark():void {
			
			if (trackMark) return;
			
			trackMark = new Sprite();
			trackMark.mouseEnabled = false;
			trackMark.mouseChildren = false;
			
			var stageInfo:StageInfo;
			var animInfo:AnimInfo;
			var bitmap:Bitmap;
			
			for (var i:int = 0; i < Main.app.stagesList.length; i++) {
				var skip:Boolean = false;
				for (var j:int = 0; j < stages.length; j++) {
					if (stages[j].item == Main.app.stagesList[i])
						skip = true;
				}
				if (skip) continue;
				
				stageInfo = Main.app.stagesList[i];
				bitmap = new Bitmap(stageInfo.bitmapData);
				bitmap.x = stageInfo.x;
				bitmap.y = stageInfo.y;
				bitmap.transform.colorTransform = new ColorTransform(0.2, 1, 0, 0.1, -255, 255, -255);
				trackMark.addChild(bitmap);
			}
			for (i = 0; i < Main.app.animationsList.length; i++) {
				skip = false;
				for (j = 0; j < anims.length; j++) {
					if (anims[j].item == Main.app.animationsList[i])
						skip = true;
				}
				if (skip) continue;
				
				animInfo = Main.app.animationsList[i];
				bitmap = new Bitmap(animInfo.bitmapData);
				bitmap.x = animInfo.x + ((animInfo.indents[0]) ? animInfo.indents[0].x : 0);
				bitmap.y = animInfo.y + ((animInfo.indents[0]) ? animInfo.indents[0].y : 0);
				bitmap.transform.colorTransform = new ColorTransform(0.2, 1, 0, 0.1, -255, 255, -255);
				trackMark.addChild(bitmap);
			}
			
			
			//trackMark.x = layerCenter.x;
			//trackMark.y = layerCenter.y;
			back.addChild(trackMark);
		}
		public function clearTrackMark():void {
			if (trackMark && trackMark.parent == back) {
				back.removeChild(trackMark);
				trackMark.removeChildren();
				trackMark = null;
			}
		}
		
		
		
		/**
		 * Удаление точек
		 */
		//private var pointDeleteBttn:Button;
		//private var pointChildForDelete:DisplayObject;
		/*private function addDeletePoint(child:DisplayObject):void {
			clearDeletePoint();
			
			pointChildForDelete = child;
			pointChildForDelete.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 64);
			
			pointDeleteBttn = new Button( {
				label:		null,
				width:		18,
				height:		18,
				color1:		0x990000,
				color2:		0x770000,
				radius:		4,
				click:		function():void {
					pointLayer.removeChild(pointChildForDelete);
					clearDeletePoint();
				}
			});
			pointDeleteBttn.x = pointChildForDelete.x + pointChildForDelete.width - pointDeleteBttn.width - 4;
			pointDeleteBttn.y = pointChildForDelete.y + 4;
			upLayer.addChild(pointDeleteBttn);
			
			var closeShape:Shape = new Shape();
			closeShape.graphics.lineStyle(2, 0xffffff);
			closeShape.graphics.moveTo(6, 6);
			closeShape.graphics.lineTo(12, 12);
			closeShape.graphics.moveTo(6, 12);
			closeShape.graphics.lineTo(12, 6);
			pointDeleteBttn.addChild(closeShape);
		}
		private function clearDeletePoint():void {
			if (pointChildForDelete) {
				pointChildForDelete.transform.colorTransform = new ColorTransform();
				pointChildForDelete = null;
			}
			
			if (pointDeleteBttn) {
				if (pointDeleteBttn.parent)
					pointDeleteBttn.parent.removeChild(pointDeleteBttn);
				
				pointDeleteBttn.dispose();
				pointDeleteBttn = null;
			}
		}*/
		
		
		
		
		/**
		 * Точка дыма
		 */
		public function addPoint(type:String, params:Object = null):PointTarget {
			/*if (StageManager.chooseNode == null) return;*/
			
			var __params:Object = {
				x:0,
				y:0
			}
			
			if (params) {
				for (var s:* in params)
					__params[s] = params[s];
			}
			
			if (!Main.storage.hasOwnProperty('points') || !Main.storage.points) return null;
			
			var object:Object = Main.storage.points[type];
			if (!object) return null;
			
			var count:int = object.count || 1;
			var stageLink:int = object.stageLink || 0;
			var link:String = object.link;
			var arrayName:Array = ['point',type];
			
			// Проверить или выделена стадия
			if (stageLink == 1) {
				if (Main.app.stageManager.focusedNodes.length > 0)
					arrayName[2] = Main.app.stageManager.focusedNodes[0].index;
				else {
					Alert.show('Для таких точек должена быть выблана стадия.', Main.appName);
					return null;
				}
			}else {
				arrayName[2] = -1;
			}
			
			// Проверить или позволяет количество
			for (var i:int = 0; i < pointLayer.numChildren; i++) {
				var child:DisplayObject = pointLayer.getChildAt(i);
				if (child.name.indexOf(type) >= 0)
					count --;
			}
			if (count <= 0) {
				Alert.show('Нельзя устанавливать больше чем ' + object.count + ' таких точек.', Main.appName);
				return null;
			}
			
			
			var point:PointTarget = new PointTarget(object);
			pointLayer.addChild(point);
			point.name = arrayName.join('_');
			point.x = __params.x || 0;
			point.y = __params.y || 0;
			point.addEventListener(MouseEvent.ROLL_OVER, onPointOver);
			point.addEventListener(MouseEvent.ROLL_OUT, onPointOut);
			
			return point;
		}
		private function initPoints():void {
			
			var stageIndex:int = (Main.app.stageManager.focusedNodes.length) ? Main.app.stageManager.focusedNodes[0].index : -1;
			
			for (var i:int = 0; i < pointLayer.numChildren; i++) {
				var child:DisplayObject = pointLayer.getChildAt(i);
				var array:Array = child.name.split('_');
				if (array[0] != 'point') continue;
				if (array[2] < 0 || array[2] == stageIndex) {
					child.visible = true;
				}else {
					child.visible = false;
				}
			}
		}
		private function onPointOver(e:MouseEvent):void {
			Main.app.info = (e.currentTarget as PointTarget).extra;
		}
		private function onPointOut(e:MouseEvent):void {
			Main.app.info = null;
		}
		
		
		// Границы
		public function sourceBorder(object:Object, draw:Boolean = true):void {
			if (!object.hasOwnProperty('sprite') || !object.hasOwnProperty('item')) return;
			
			var sprite:Sprite = object.sprite;
			var item:Object = object.item;
			
			sprite.graphics.clear();
			if (!draw) return;
			sprite.graphics.lineStyle(1, 0xffff00, 0.35);
			sprite.graphics.drawRect(0, 0, item.sourceWidth, item.sourceHeight);
		}
		public function set showBorders(value:Boolean):void {
			if (viewBorders == value) return;
			viewBorders = value;
			for (var i:int = 0; i < stageLayer.numChildren; i++) {
				var item:* = inViewList(stageLayer.getChildAt(i));
				if (!item) continue;
				sourceBorder(item, viewBorders);
			}
			for (i = 0; i < animLayer.numChildren; i++) {
				item = inViewList(animLayer.getChildAt(i));
				if (!item) continue;
				sourceBorder(item, viewBorders);
			}
		}
		public function get showBorders():Boolean {
			return viewBorders;
		}
	}

}

import enixan.Anime;
import enixan.BitmapLoader;
import enixan.Size;
import enixan.Util;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Bitmap;

internal class StageCo {
	
	public var sprite:Sprite;
	public var bitmap:Bitmap;
	public var item:StageInfo;
	
	public function StageCo(sprite:Sprite, bitmap:Bitmap, item:StageInfo) {
		this.sprite = sprite;
		this.bitmap = bitmap;
		this.item = item;
	}
	
}

internal class AnimCo {
	
	public var sprite:Sprite;
	public var bitmap:Bitmap;
	public var item:AnimInfo;
	
	public function AnimCo(sprite:Sprite, bitmap:Bitmap, item:AnimInfo) {
		this.sprite = sprite;
		this.bitmap = bitmap;
		this.item = item;
	}
	
}

internal class PointTarget extends Sprite {
	
	[Embed(source = "../res/point.png")]
	private var PointView:Class;
	private var pointBitmapData:BitmapData = new PointView().bitmapData;
	
	public var info:Object;
	public var extra:Object;
	public var currX:int;
	public var currY:int;
	
	public function PointTarget(object:Object) {
		
		super();
		
		if (!object) return;
		
		info = object;
		
		if (object.extra && object.extra is Array) {
			if (!extra) extra = { };
			for (var i:int = 0; i < object.extra.length; i++) {
				extra[object.extra[i]] = '';
			}
		}
		
		var link:String = object.link;
		if (link) {
			if (link.indexOf(Main.PNG) >= 0) {
				var point1:BitmapLoader = new BitmapLoader(link);
				addChild(point1);
			}else {
				var point2:Anime = new Anime(link, {
					autoDispose:		false
				});
				addChild(point2);
			}
		}else {
			
			var circle:Shape = new Shape();
			circle.graphics.lineStyle(1);
			circle.graphics.beginFill(int(Math.random() * 16777215), 1);
			circle.graphics.drawCircle(8.5, 9, 5);
			circle.graphics.endFill();
			
			var bitmapData:BitmapData = pointBitmapData.clone();
			bitmapData.draw(circle);
			
			var point3:Bitmap = new Bitmap(bitmapData, 'auto', true);
			point3.x = -point3.width * 0.5 - 0.5;
			point3.y = -point3.height;
			addChild(point3);
		}
		
	}
	
	public function savePosition():void {
		currX = x;
		currY = y;
	}
	
}