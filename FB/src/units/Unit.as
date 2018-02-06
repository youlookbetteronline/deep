package units
{
	import astar.AStarNodeVO;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Strong;
	import com.greensock.plugins.TransformAroundPointPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import effects.explosion.ParticleManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.Hints;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import ui.UserInterface;
	import units.*;
	import wins.SimpleWindowRedux;
	
	import wins.ErrorWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.Window;
	
	public class Unit extends LayerX
	{
		public const OCCUPIED:uint = 1;
		public const EMPTY:uint = 2;
		public const TOCHED:uint = 3;
		public const DEFAULT:uint = 4;
		public const IDENTIFIED:uint = 5;
		public const HIGHLIGHTED:uint = 6;
		public const HIGHLIGHTED_TREE:uint = 7;
		public static const BATHYSCAPHE:int = 2739;
		
		private const STREAM_SLUCK:Number = 2;
		
		public static var lastUnit:Object;
		public static var lastRemove:int;
		public static var unitsMove:Array = [];
		public static var classes:Object = {};
		
		private static var colorizedUnits:Vector.<Unit>;
		
		public var touchable:Boolean = true;
		public var moveable:Boolean = true;
		public var transable:Boolean = true;
		public var removable:Boolean = true;
		public var clickable:Boolean = true;
		public var rotateable:Boolean = true;
		public var takeable:Boolean = true;
		public var applyRemove:Boolean = true;
		public var touchableInGuest:Boolean = true;
		public var multiple:Boolean;
		public var animated:Boolean;
		public var fake:Boolean;
		public var helped:Boolean;
		public var fromShop:Boolean;
		public var isBuyNow:Boolean;
		public var open:Boolean;
		public var clearVars:Boolean;
		public var fromStock:Boolean;
		public var fromMhelper:Boolean;
		public var returnClickable:Boolean;
		
		public var bitmap:Bitmap;
		public var animationBitmap:Bitmap;
		
		public var textures:Object;
		public var bounds:Object;
		public var coords:Object = {x: 0, y: 0, z: 0};
		public var prevCoords:Object = {x: 0, y: 0, z: 0};
		public var iconPosition:Object = { x:0, y:0 };
		
		public var type:String;
		public var ownerID:String;
		public var layer:String;
		public var dx:int;
		public var dy:int;
		public var created:int;
		public var zone:int = 0;
		public var transTimeID:uint;
		public var id:uint = 0;
		public var sid:uint = 0;
		public var depth:uint = 0;
		public var index:uint = 0;
		public var cells:uint = 0;
		public var rows:uint = 0;
		public var busy:uint = 0;
		public var spitY:Number;
		public var spitX:Number;
		public var icon:UnitIcon;
		public var targetWorker:Unit;
		public var worker:WorkerUnit;
		public var bitmapContainer:Sprite;
		public var putCallback:Function;
		
		protected var tween:TweenLite;
		protected var _touch:Boolean;
		protected var _move:Boolean;
		protected var _trans:Boolean;
		protected var _install:Boolean;
		protected var _ordered:Boolean;
		protected var _rotate:Boolean;
		protected var isStreaming:Boolean;
		protected var previosRotate:Boolean;
		protected var _state:uint = DEFAULT;
		
		private var spitCallback:Function;
		private var _stockable:Boolean;
		private var _plane:Sprite;
		private var lastIconX:Number = 0;
		private var lastIconY:Number = 0;
		
		public function set ordered(ordered:Boolean):void{
			_ordered = ordered;
			if (ordered){
				clickable = false;
				alpha = .5;
				
				if (touch){
					touch = false;
					var idx:int = App.map.touched.indexOf(this);
					if (idx >= 0)
						App.map.touched.splice(idx, 1);
				}
			}else{
				clickable = true;
				alpha = 1;
			}
		}
		public function get ordered():Boolean{
			return _ordered;
		}
		public function set state(state:uint):void{
			if (_state == state)
				return;
			
			switch (state){
				case OCCUPIED: 
					this.bitmapContainer.filters = [];
					this.filters = [new GlowFilter(0xFF0000, 1, 6, 6, 7)];
					break;
				case EMPTY: 
					this.bitmapContainer.filters = [];
					this.filters = [new GlowFilter(0x00FF00, 1, 6, 6, 7)];
					break;
				case TOCHED: 
					this.filters = [];
					this.bitmapContainer.filters = [new GlowFilter(glowingColor, 1, 6, 6, 7)];
					break;
				case HIGHLIGHTED: 
					this.bitmapContainer.filters = [];
					this.filters = [new GlowFilter(0x88ffed, 0.6, 6, 6, 7)];
					break;
				case IDENTIFIED: 
					this.bitmapContainer.filters = [];
					this.filters = [new GlowFilter(0x88ffed, 1, 8, 8, 10)];
					break;
				case DEFAULT:
					this.bitmapContainer.filters = [];
					this.filters = [];
					break;
			}
			_state = state;
		}
		public function get state():uint{
			return _state;
		}
		public function get bmp():Bitmap{
			return bitmap;
		}
		public function get info():Object {
			return App.data.storage[sid];
		}
		public function set info(value:Object):void {
			App.data.storage[sid] = value;
		}
		public function get stockable():Boolean{
			if (this.hasOwnProperty('level') && this.hasOwnProperty('totalLevels'))
			{
				if (this['level'] < this['totalLevels'])
					return false;
			}
			return _stockable;
		}
		public function set stockable(_val:Boolean):void{
			_stockable = _val;
		}
		public function get formed():Boolean{
			return (this.id > 0);
		}
		public function set transparent(transparent:Boolean):void{
			if (!transable || _trans == transparent || (App.user.quests.tutorial && transparent == true))
				return;
			var that:* = bitmapContainer;
			if (transparent == true){
				_trans = true;
				transTimeID = setTimeout(function():void{
					if (SystemPanel.animate)
						tween = TweenLite.to(that, 0.2, {alpha: 0.3});
					else
						that.alpha = 0.3;
				}, 150);
			}else{
				clearTimeout(transTimeID);
				_trans = false;
				if (tween){
					tween.complete(true);
					tween.kill();
					tween = null;
				}
				that.alpha = 1;
			}
		}
		public function get transparent():Boolean{
			return _trans;
		}
		public function set rotate(rotate:Boolean):void{
			if (!rotateable || _rotate == rotate)
				return;
			
			previosRotate = _rotate;
			_rotate = rotate;
			
			if(!App.map.moved)
				free();
			
			Cursor.type = "move";
			Cursor.prevType = "rotate";
			App.map.moved = this;
			move = true;
			
			flip();
			return;
		}		
		public function get rotate():Boolean{
			return _rotate;
		}		
		public function set touch(touch:Boolean):void{
			if (Cursor.type == 'stock' && stockable == false)
				return;
				
			if (App.owner && App.owner.worldID == User.SOCKET_MAP){
				touchable = true;
				touchableInGuest = true;
			}
			if (!touchable || (App.user.mode == User.GUEST && touchableInGuest == false))
				return;
			_touch = touch;
			
			if (touch){
				if (state == DEFAULT){
					state = TOCHED;
				}
				else if (state == HIGHLIGHTED){
					state = IDENTIFIED;
				}
			}else{
				if (state == TOCHED){
					state = DEFAULT;
				}else if (state == IDENTIFIED){
					state = HIGHLIGHTED;
				}
			}
		}
		public function get touch():Boolean{
			return _touch;
		}
		public function set move(move:Boolean):void{
			if (!moveable || _move == move){
				return;
			}
			if (!App.self.fakeMode && App.user.useSectors){
				var node1:AStarNodeVO = App.map._aStarNodes[this.coords.x][this.coords.z];
				if (!node1.sector.open && formed){
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1495607052980') + " " + info.title,
						confirm:function():void
						{
							node1.sector.fireNeiborsReses();
						}
					}).show();
					return;
				}
			}
			_move = move;
			if (move){
				if (formed){
					free();
				}
				prevCoords = coords;
				App.self.setOnEnterFrame(moving);
			}else{
				if (state == EMPTY){
					if (_plane && _plane.parent)
						_plane.parent.removeChild(_plane);
					take();
					if (fromStock == true){
						stockAction();
					}else if (!formed){
						buyAction();
					}else{
						moveAction();
					}
					state = DEFAULT;
					App.self.setOffEnterFrame(moving);					
				}else{
					_move = true;
				}
			}
		}
		public function get move():Boolean{
			return _move;
		}
		
		public function Unit(data:Object)
		{
			bitmapContainer = new Sprite();
			bitmap = new Bitmap(null, "auto", true);
			this.id = data.id || 0;
			this.sid = data.sid || 0;
			
			this.fromStock = data.fromStock || false;
			
			if (this.sid > 0) {
				type = info.type;
				
				_rotate = data['rotate'] || false;
				
				if (data.area)
				{
					info.area = data.area;
				}
				else
				{
					if (info.area)
					{
						if (!_rotate)
						{
							cells = info.area.w || 0;
							rows = info.area.h || 0;
						}
						else
						{
							cells = info.area.h || 0;
							rows = info.area.w || 0;
						}
					}
				}
			}
			
			bitmapContainer.addChild(bitmap);
			addChild(bitmapContainer);
			
			placing(data.x || 0, data.y || 0, data.z || 0);
			install();
			
			mouseEnabled = false;
			
			if(this.info && this.info.config){
				var unitConfig:Array = String(this.info.config).split('').reverse();
				for (var configID:int = 0; configID < unitConfig.length; configID++ ) {
					if (unitConfig[configID] == "1" && this.hasOwnProperty(App.map.CONFIG_DATA[configID])) {
						this[App.map.CONFIG_DATA[configID]] = false;
					}
				}
			}
			
			if (formed) {
				open = App.map._aStarNodes[coords.x][coords.z].open;
				zone = App.map._aStarNodes[coords.x][coords.z].z;
				if (this.type == 'Bridge')
				{
					open = App.map._aStarNodes[coords.x + cells - 1][coords.z + rows - 1].open;
					zone = App.map._aStarNodes[coords.x + cells - 1][coords.z + rows - 1].z;
				}
			}
			
			if(!open && zone > 0)
				Fog.addToZone(this);
			
			if (data.fromMhelper)		
				fromMhelper = data.fromMhelper;
				
			if(App.self.fakeMode)
				this.fake = true;
		}
		
		public function makeOpen():void 
		{
			this.open = true;
		}
		
		public function startMoving():void 
		{
			stopMoving();
			App.self.setOnEnterFrame(moving);
		}
		
		public function stopMoving():void 
		{
			App.self.setOffEnterFrame(moving);
		}
		
		public function can():Boolean
		{
			return ordered;
		}
		
		public function take():void
		{
			if (!takeable)
				return;
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			var water:AStarNodeVO;
			
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var waters:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			for (var i:uint = 0; i < cells; i++)
			{
				for (var j:uint = 0; j < rows; j++)
				{
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					
					if (App.self.fakeMode)
					{
						if (node.object != null &&  node.object != this)
							node.object['uninstall'].call(null);
					}
					
					if (this.type == 'PublicBox')
					{
						if (node.object != null &&  node.object != this)
						{
							node.object['uninstall'].call(null);
						}
					}
					nodes.push(node);
					
					node.isWall = true;
					node.b = 1;
					node.object = this;
					if (layer == Map.LAYER_FIELD || layer == Map.LAYER_LAND)
						node.isWall = false;
					
					if (i > 0 && i < cells - 1 && j > 0 && j < rows - 1)
					{
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						
						part.isWall = true;
						part.b = 1;
						part.object = this;
						if (layer == Map.LAYER_FIELD || layer == Map.LAYER_LAND)
							part.isWall = false;
						
						if (info.base != null && info.base == 1)
						{
							if (App.map._aStarWaterNodes != null)
							{
								water = App.map._aStarWaterNodes[coords.x + i][coords.z + j];
								waters.push(water);
								water.isWall = true;
								water.b = 1;
								water.object = this;
							}
						}
						
					}
				}
			}
			
			if (layer == Map.LAYER_SORT)
			{
				App.map._astar.take(nodes);
				App.map._astarReserve.take(parts);
			}
			
			if (info.base != null && info.base == 1)
			{
				if (App.map._astarWater != null)
					App.map._astarWater.take(waters);
			}
		}
		
		public function free():void
		{
			if (!takeable)
				return;
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			if (App.map._aStarNodes != null)
			{
				for (var i:uint = 0; i < cells; i++)
				{
					for (var j:uint = 0; j < rows; j++)
					{
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						nodes.push(node);
						node.isWall = false;
						node.b = 0;
						node.object = null;
						
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						part.isWall = false;
						part.b = 0;
						part.object = null;
					}
				}
				
				if (layer == Map.LAYER_SORT)
				{
					App.map._astar.free(nodes);
					App.map._astarReserve.free(parts);
				}
				
				if (info.base != null && info.base == 1)
				{
					if (App.map._astarWater != null)
						App.map._astarWater.free(nodes);
				}
			}
		}
		
		public function createGrid():void{
			alpha = 1;
			
			clearGrid();
			
			var node:Object;
			var ___X:* = ((coords.x + cells ) < Map.cells)? coords.x + cells: Map.cells - 1;
			var ___Z:* = ((coords.z + rows ) < Map.rows)? coords.z + rows: Map.rows - 1;
			for (var _x:int = ((coords.x) >= 0)? coords.x : 0; _x < ___X; _x++) {
				for (var _z:int = ((coords.z ) >= 0)? coords.z: 0; _z < ___Z; _z++) {
					
					node = App.map._aStarNodes[_x][_z];
					
					if (node.object && (node.object is Unit) && colorizedUnits.indexOf(node.object) == -1) {
						node.object.state = OCCUPIED;
						colorizedUnits.push(node.object);
						alpha = 0.4;
					}
					
				}
			}
		}
		
		public function applyFilter(colour:uint = 0xeff200):void
		{
			var node:AStarNodeVO;
			if (App.map._aStarNodes == null)
				return;
				
			if (App.map._aStarNodes.length < this.coords.x)
				return;
			if (App.map._aStarNodes[0].length < this.coords.z)
				return;
				
			if (this.type == 'Bridge')
			{
				if (this.sid == 1809)
					node = App.map._aStarNodes[this.coords.x][this.coords.z];
				else
					node = App.map._aStarNodes[this.coords.x + this.cells -1][this.coords.z + this.rows - 1];
			}else
			{
				if (App.map.inGrid({x:this.coords.x, z:this.coords.z}))
					node = App.map._aStarNodes[this.coords.x][this.coords.z];
			}
			if (!node)
				return;
			open = node.open;
			
			if (App.user.worldID == User.AQUA_HERO_LOCATION)
			{
				if(this is Wall)
					return;
				if (!open)
				{
					UserInterface.colorize(bitmap, 0x000000, .8);
					clickable = false;
					touchable = false;
					removable = true;
				}else{
					this.bitmap.filters = null;
					touchable = true;
					clickable = true;
					removable = true;
				}
				return;
			}
			var amount:Number = 0;
			var scaleD:Number = 0;
			if (!open){
				this.visible = false;
			}else{
				if (this.type == 'Techno')
				{
					if (this.hasOwnProperty('thisTechnoWigwam') && this['thisTechnoWigwam'] != null && this['thisTechnoWigwam']['workers'][0] && this['thisTechnoWigwam']['workers'][0] != this['thisTechnoWigwam']['workerSID'] && this['thisTechnoWigwam']['wigwamIsBusy'] != 0)
					{
						this.alpha = 0;
						return;
					}
				}
				this.visible = true;
			}
		}
		
		public function clearGrid():void {
			while(colorizedUnits.length) {
				colorizedUnits.shift().state = DEFAULT; 
			}
			colorizedUnits = new Vector.<Unit>();
		}
		
		public function canInstall():Boolean
		{
			return (_state != OCCUPIED);
		}
		
		public function placing(x:uint, y:uint, z:uint):void
		{
			if (_plane && _plane.parent)
				_plane.parent.removeChild(_plane);
				
			if (!App.map)
				return;
			var node:AStarNodeVO;
			
			if ((x < 0 || x + cells > Map.cells) || (z < 0 || z + rows > Map.rows))
			{
				takeable = false;
				return;
			}else
			{
				takeable = true;
			}
			
			node = App.map._aStarNodes[x][z];			
			coords = {x: x, y: y, z: z};
			this.x = node.tile.x;
			this.y = node.tile.y;
			
			iconSetPosition(0, 0, ((move) ? true : false));
			calcDepth();
			
			if (move)
			{
				state = calcState(node);
				
				if (state == OCCUPIED)
					this.alpha = .4;
				else	
					this.alpha = 1;
			}else{
				if (_plane && _plane.parent)
					_plane.parent.removeChild(_plane);
				this.alpha = 1;
			}
		}
		
		public function calcState(node:AStarNodeVO):int
		{
			if (App.self.fakeMode)
				return EMPTY;
			var _node:AStarNodeVO;
			for (var i:uint = 0; i < cells; i++)
			{
				for (var j:uint = 0; j < rows; j++)
				{
					_node = App.map._aStarNodes[coords.x + i][coords.z + j];
					
					if (App.user.useSectors && !_node.sector.open)
						return OCCUPIED;
						
					if (_node.p != 0 || _node.b != 0 || _node.open == false || _node.object != null)
					{
						return OCCUPIED;
					}
				}
			}
			return EMPTY;
		}
		
		public function install():void 
		{
			App.map.addUnit(this);
		}
		
		public function sort(index:*):void
		{
			App.map.mSort.setChildIndex(this, index);
		}
		
		public function calcDepth():void
		{
			var left:Object = {x: x - IsoTile.width * rows * .5, y: y + IsoTile.height * rows * .5};
			var right:Object = {x: x + IsoTile.width * cells * .5, y: y + IsoTile.height * cells * .5};
			depth = (left.x + right.x) + (left.y + right.y) * 100;
		}
		
		
		public function draw(bitmapData:BitmapData, dx:int, dy:int):void
		{
			bitmap.bitmapData = bitmapData;
			
			this.dx = dx;
			this.dy = dy;
			bitmap.x = dx;
			bitmap.y = dy;
			
			if (rotate)
			{
				scaleX = Math.abs(scaleX) * -1;
			}
		}
		
		public function previousPlace():void
		{
			if (_move == true)
			{
				if (formed) {
					_move = false;
					
					if (_rotate != previosRotate)
					{
						_rotate = !_rotate;
						previosRotate = _rotate;
						var temp:uint = cells;
						cells = rows;
						rows = temp;
						scaleX = -scaleX;
						x -= width * scaleX;
					}
					
					placing(prevCoords.x, prevCoords.y, prevCoords.z);
					take();
					state = DEFAULT;
					App.self.setOffEnterFrame(moving);
					this.visible = true;
				}
				else
				{
					_move = false;
					App.self.setOffEnterFrame(moving);
					uninstall();
				}
				if (App.map.moved == this)
				{
					App.map.moved = null;
				}
			}
		}
		
		
		public function drawUnitNodes(_x:int, _z:int):void 
		{
			if (_plane && _plane.parent)
				_plane.parent.removeChild(_plane);
				
			_plane = new Sprite();
			var zoneIDs:Object = { };
			var node:AStarNodeVO;
			var _width:int = info.area.w;
			var _height:int = info.area.h;
			if (rotate)
			{
				_width = info.area.h;
				_height = info.area.w;
			}
			for (var x:int = 0; x < _width; x++) 
			{
				for (var z:int = 0; z < _height; z++) 
				{
					if (App.map._aStarNodes[this.coords.x + x][this.coords.z + z].p == 0) 
					{
						if (App.map._aStarNodes[this.coords.x + x][this.coords.z + z].object) {
							_plane.graphics.beginFill(0xb00000, 0.6);
						}/*else {
							_plane.graphics.beginFill(0x14ae00, 0.6);
						}*/
					}else {
						if (!App.map._aStarNodes[this.coords.x + x][this.coords.z + z].w) {
							_plane.graphics.beginFill(0xaabbff, 0.8);
						}else{
							_plane.graphics.beginFill(0xCC0000, 0.8);
						}
					}
					
					var point:Object = IsoConvert.isoToScreen(x, z, true, true);
					_plane.graphics.moveTo(point.x, point.y);
					_plane.graphics.lineTo(point.x - IsoTile.width/2, point.y + IsoTile.height/2);
					_plane.graphics.lineTo(point.x, point.y + IsoTile.height);
					_plane.graphics.lineTo(point.x + IsoTile.width/2, point.y + IsoTile.height/2);
					_plane.graphics.endFill();
				}
			}
			if(this.layer == 'mLand')
				App.map.mLand.addChildAt(_plane, 0);
			else
				App.map.mLand.addChild(_plane);
			node = App.map._aStarNodes[_x][_z];	
			
			_plane.x = node.tile.x;
			_plane.y = node.tile.y;
			
		}
		
		
		protected function moving(e:Event = null):void
		{
			if (coords.x != Map.X || coords.z != Map.Z)
			{
				placing(Map.X, 0, Map.Z);
				
				if(takeable)
					drawUnitNodes(Map.X, Map.Z);
					
				if (layer == Map.LAYER_SORT)
				{
					App.map.sorted.push(this);
				}
			}
		}
		
		public function flip():void
		{
			var temp:uint = cells;
			cells = rows;
			rows = temp;
			
			scaleX = -scaleX;
			x -= width * scaleX;
			
			placing(coords.x, coords.y, coords.z);
		}
		
		public function remove(_callback:Function = null):void
		{
			if (!removable)
				return;
			var callback:Function = _callback;
			if ((applyRemove == false || this is Field) && App.user.mode == User.OWNER)
			{
				onApplyRemove(callback)
			}
			else{
				new SimpleWindow( {
					title: Locale.__e("flash:1382952379842"),
					text: Locale.__e("flash:1382952379968", [info.title]),
					label: SimpleWindow.ATTENTION,
					dialog: true,
					confirm: function():void {
						onApplyRemove(callback);
					}
				}).show();
			}
		}
		
		public function getContactPosition():Object
		{
			var y:int = -1;
			if (this.coords.z + y < 0)
				y = 0;
				
			return {
				x: Math.ceil(info.area.w / 2),
				y: y,
				direction:0,
				flip:0
			}
		}
		
		public function onApplyRemove(callback:Function = null):void
		{
			if (!removable || (this.sid == 689 && Cursor.type != 'default'))
				return;
			if(this.id == 0){
				uninstall();
				return;
			}
			if (this.fake && this.fake == true)
			{
				trace ("you are FAKE!");
				onRemoveAction(0,{},{callback: callback});
			}else{
				Post.send({ctr: this.type, act: 'remove', uID: App.user.id, wID: App.user.worldID, sID: this.sid, id: this.id}, onRemoveAction, {callback: callback});
			}
			//this.visible = false;
		}
		
		public function onRemoveAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				this.visible = true;
				return;
			}
			var that: * = this;
			
			uninstall();
			
			if (params.callback != null)
			{
				params.callback();
			}
		}
		
		public function click():Boolean
		{
			
			if (!clickable || (App.user.mode == User.GUEST && touchableInGuest == false))
				return false;
			App.tips.hide();
			
			return true;
		}
		
		public function animate(e:Event = null):void {}
		public function putAction():void
		{
			if (!stockable) return;
			
			ordered = true;
			
			Post.send( {
				ctr: this.type,
				act: 'put',
				uID: App.user.id,
				wID: App.user.worldID,
				sID: this.sid,
				id: this.id
			}, onPutAction, {callback:putCallback});
		}
		
		protected function onPutAction(error:int, data:Object, params:Object):void {
			if (error) return;
			
			var object:Object = { };
			object[sid] = 1;
			
			Treasures.bonus(object, new Point(x, y));
			if (params['callback'])
			{
				params.callback();
				putCallback = null;
			}
			uninstall();
		}
		
		public function onAfterStock():void
		{
			moveable = true;
		}
		
		public function stockAction(params:Object = null):void 
		{
			if (!App.user.stock.check(sid))
				return;
			
			App.user.stock.take(sid, 1);
			
			var _postObject:Object = {
				ctr: this.type,
				act: 'stock',
				uID: App.user.id,
				wID: App.user.worldID,
				sID: this.sid,
				x: coords.x,
				z: coords.z
			};
			if (App.user.mode == User.PUBLIC)
			{
				if (!App.owner)
					return;
				_postObject['uID'] = App.owner.id;
				this.ownerID = App.user.id;
			}
			Post.send(_postObject, onStockAction);
		}
		
		protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			
			if (App.user.mode == User.PUBLIC)
			{
				var _objParams:Object = {
					coords	:this.coords,
					sID		:this.sid,
					iD		:this.id
				};
				
				Connection.sendMessage({
					u_event	:'unit_place', 
					aka		:App.user.aka, 
					params	:_objParams
				});
			}
			World.tagUnit(this);
			
			if (!(multiple && App.user.stock.check(sid)))
				App.map.moved = null;
			
			App.ui.glowing(this);
		}
		
		public function buyAction(setts:*=null):void
		{
			if (!setts)
				setts = {};
			
			SoundsManager.instance.playSFX('build');
			
			var price:Object = Payments.itemPrice(sid);
			
			if (!App.user.stock.takeAll(price)) 
			{
				ShopWindow.currentBuyObject.type = null;
				ShopWindow.currentBuyObject.currency = null;
				uninstall();
			}
			if(!setts.hideHints)
				Hints.buy(this);
			
			var params:Object = {
				ctr:	this.type,
				act:	'buy',
				uID:	App.user.id,
				ac:		(ShopWindow.currentBuyObject.currency)?1:0,
				wID:	(setts.hasOwnProperty('wID'))?setts.wID:App.user.worldID,
				sID:	this.sid,
				x:		coords.x,
				z:		coords.z
			};
			
			if (info.hasOwnProperty('instance')) {
				var instances:int = World.getBuildingCount(sid);
				params['iID'] = 1 + (Numbers.countProps(info.instance) < instances) ? Numbers.countProps(info.instance) : instances;
			}
			if (this.type == "Resource")
			{
				this.alpha = .5;
				if (clickable)
				{
					clickable = false;
					returnClickable = true;
				}
			}
			
			if (this.fake && this.fake == true)
			{
				trace ("you are FAKE!");
				var _id:int = 1;
				if (Map.resourcesID.hasOwnProperty(this.type))
				{
					Map.resourcesID[this.type] = Map.resourcesID[this.type] + 1;
					_id = Map.resourcesID[this.type];
				}else{
					Map.resourcesID[this.type] = _id;
				}
					
				onBuyAction(0,{id:_id},{});
			}else{
				Post.send(params, onBuyAction);
			}
			
			makeOpen();
			
			isBuyNow = false;
		}
		
		protected function onBuyAction(error:int, data:Object, params:Object):void
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
				
			this.id = data.id;
			World.tagUnit(this);
			
			dispatchEvent(new AppEvent(AppEvent.AFTER_BUY));
		}
		
		public function moveAction():void
		{
			if (_plane && _plane.parent)
				_plane.parent.removeChild(_plane);
			if (Cursor.prevType == "rotate")
				Cursor.type = Cursor.prevType;
			if (this.fake && this.fake == true)
			{
				trace ("you are FAKE!");
				onMoveAction(0,{},{});
			}else{
				Post.send({ctr: this.type, act: 'move', uID: App.user.id, wID: App.user.worldID, sID: this.sid, id: id, x: coords.x, z: coords.z, rotate: int(rotate)}, onMoveAction);
			}
		}
		
		public function onMoveAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				
				free();
				_move = false;
				placing(prevCoords.x, prevCoords.y, prevCoords.z);
					
				take();
				state = DEFAULT;
				return;
			}
			
			if (_plane && _plane.parent)
				_plane.parent.removeChild(_plane);
		
			App.map._astar.reload();
			App.map._astarReserve.reload();
		}
		
		public function rotateAction():void
		{
			Post.send({ctr: this.type, act: 'rotate', uID: App.user.id, wID: App.user.worldID, sID: this.sid, id: id, rotate: int(rotate)}, onRotateAction);
		}
		
		public function onDown():void
		{
		
		}
		
		private function onRotateAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				//TODO мен¤ем координаты на старые
				return;
			}
		}
		
		public function drawIcon(type:String, material:*, need:int = 0, params:Object = null, directSid:int = 0, posX:int = 0, posY:int = 0):void 
		{
			if (icon) clearIcon();
			if (!formed || !parent) return;
			
			icon = new UnitIcon(type, material, need, this, params);
			iconPosition = { x:posX, y:posY };
			icon.y = this.y + iconPosition.y;
			icon.x = this.x + iconPosition.x;
			
			if (!App.map)
				return;
			if (!App.map.mIcon.contains(icon))
				App.map.mIcon.addChild(icon);
			
			iconSetPosition();
			App.map.iconSortResort();
		}
		
		public function clearIcon():void 
		{
			if (icon) {
				icon.dispose();
				icon = null;
				
				this.hideGlowing();
			}
		}
		public function iconSetPosition(x:int = 0, y:int = 0, stream:Boolean = false):void 
		{
			if (isStreaming) return;
			if (!icon) return;
			if (!bounds && textures) countBounds();
			if (bounds) {
				if (!stream) {
					iconIndentCount();
					icon.x = this.x + ((x == 0) ? iconPosition.x : x);
					icon.y = this.y + ((y == 0) ? iconPosition.y : y);
				}else {
					isStreaming = true;
					App.self.setOnEnterFrame(streaming);
				}
			}
		}
		private function streaming(e:Event = null):void 
		{
			lastIconX = icon.x;
			lastIconY = icon.y;
			icon.x = icon.x + (this.x - icon.x + iconPosition.x) / STREAM_SLUCK;
			icon.y = icon.y + (this.y - icon.y + iconPosition.y) / STREAM_SLUCK;
			if (!move && lastIconX == icon.x && lastIconY == icon.y) {
				isStreaming = false;
				App.self.setOffEnterFrame(streaming);
			}
		}
		public function iconIndentCount():void {
			// pассчитывает отступ иконки от 0,0
			if (!bounds) return;
			if (App.data.storage[this.sid].type != "Golden" && App.data.storage[this.sid].type != "Building" && App.data.storage[this.sid].type != "Port" && App.data.storage[this.sid].type != "Bridge" /*&& App.data.storage[this.sid].type != "Walkgolden"*/)	return;
			
			iconPosition.x += bounds.x + bounds.w / 2;
			iconPosition.y += bounds.y + 15;
			
		}
		public function countBounds(animation:String = '', stage:int = -1):void {
			bounds = Anime.bounds(textures, { stage:stage, animation:animation, walking:((this is WUnit) ? true : false) } );
		}
		
		public function drawPreview():void {
			var sizeX:Number = 19.6;
			var sizeY:Number = 9.8;
			var rows:*;
			var cells:*;
			if(!rotate){
				rows = this.cells;
				cells = this.rows;
			}else {
				rows = this.rows;
				cells = this.cells;
			}
			var shape:Shape = new Shape();
			shape.name = 'preview';
			shape.graphics.beginFill(0x00FF00, 0.3);
			shape.graphics.lineStyle(1, 0x00FF00, 0.6);
			shape.graphics.moveTo(0, 0);
			shape.graphics.lineTo( -sizeX * cells, sizeY * cells);
			shape.graphics.lineTo( -sizeX * cells + sizeX * rows, sizeY * cells + sizeY * rows);
			shape.graphics.lineTo( sizeX * rows, sizeY * rows);
			shape.graphics.lineTo(0, 0);
			shape.graphics.endFill();
			addChild(shape);
			swapChildren(bitmapContainer, shape);
		}
		public function clearPreview():void {
			var shape:Shape = getChildByName('preview') as Shape;
			removeChild(shape);
		}
		
		public function findPlaceNearTarget(target:*, radius:int = 1, infront:Boolean = false):Object
		{
			var places:Array = [];
			
			var targetX:int = target.coords.x;
			var targetZ:int = target.coords.z;
			
			var startX:int = targetX - radius;
			var startZ:int = targetZ - radius;
			
			if (startX <= 0) startX = 1;
			if (startZ <= 0) startZ = 1;
			
			var finishX:int = targetX + radius + target.info.area.w;
			var finishZ:int = targetZ + radius + target.info.area.h;
			
			if (finishX >= Map.cells) finishX = Map.cells - 1;
			if (finishZ >= Map.rows) finishZ = Map.rows - 1;
			
			if (!App.map._aStarNodes)
				return null;
			
			for (var pX:int = startX; pX < finishX; pX++)
			{
				for (var pZ:int = startZ; pZ < finishZ; pZ++)
				{
					if (coords && (coords.x <= pX && pX <= targetX +target.info.area.w) &&
					(coords.z <= pZ && pZ <= targetZ +target.info.area.h)){
						continue;
					}
					
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].isWall) 
						continue;
						
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].open == false) 
						continue;
						
					if(info && info.base == 1){
						if (App.map._aStarNodes[pX][pZ].w != 1 || App.map._aStarNodes[pX][pZ].open == false )
						continue;
					}
					
					if(info && info.base == 0){
						if  ((App.map._aStarNodes[pX][pZ].b != 0) || App.map._aStarNodes[pX][pZ].open == false|| App.map._aStarNodes[pX][pZ].object != null) 
						continue;
					}
					
					places.push( { x:pX, z:pZ} );
				}
			}
			
			if (places.length == 0) 
			{
				places.push( { x:coords.x, z:coords.z } );
			}
			
			var random:uint = int(Math.random() * (places.length - 1));
			return places[random];
		}
		
		public function uninstall():void 
		{
			//if (_plane && _plane.parent)
				//_plane.parent.removeChild(_plane);
			App.self.setOffEnterFrame(streaming);
			App.self.setOffEnterFrame(moving);
			if(App.user.quests.tutorial)
				this.hidePointing();
			free();
			App.map.removeUnit(this);
			clearIcon();
			
			if (this.isBuyNow != true) {
				World.removeBuilding(this);
			}
			if(clearVars)
				clearVariables();
		}
		public var clearBmaps:Boolean;
		public function clearVariables():void {
			//return;
			var self:* = this;
			var description:XML = describeType(this);
			var dscd:XMLList = description.descendants("variable"); 
			var variables:XMLList = description..variable;
			for each(var variable:XML in variables) {
				var ss:String = variable.@type;
				switch(ss){
					case 'Bitmap':
						if (clearBmaps && self[variable.@name] && self[variable.@name].bitmapData)
						{
							self[variable.@name].bitmapData.dispose();
							self[variable.@name].bitmapData = null;
						}
						self[variable.@name] = null;
						continue;
						break;
					case 'Sprite':
						if (self[variable.@name]){
							self[variable.@name].removeChildren();
							self[variable.@name] = null;
						}
						continue;
						break;
				}
				if(ss.search(/units::/) != -1)
				{
					self[variable.@name] = null;
				}
				if(variable.@type == '*')
				{
					self[variable.@name] = null;
					//continue;
				}
			}
			self = null;
			return;
				/*var classType:Class = getDefinitionByName(variable.@type) as Class;
				switch(classType){
					case Bitmap:
						if (self[variable.@name] && self[variable.@name].bitmapData && App.user.mode != User.GUEST)
						{
							self[variable.@name].bitmapData.dispose();
							self[variable.@name].bitmapData = null;
						}
						self[variable.@name] = null;
						break;
					case Sprite:
						if (self[variable.@name]){
							self[variable.@name].removeChildren();
							self[variable.@name] = null;
						}
						break;
					case Unit:
						self[variable.@name] = null;
						break;
					//default:
						//self[variable.@name] = null;
				}
			}
			self = null;*/
		}
		
		public static function add(object:Object):Unit
		{
			if (App.map.moved)
			{
				App.map.moved.move = false;
				App.map.moved = null;
				Cursor.type = "default";
			}
			
			lastUnit = object;
			
			var type:String = 'units.' + App.data.storage[object.sid].type;
			
			var classType:Class;
			if (classes[type] == undefined) {
				classType = getDefinitionByName(type) as Class;
				classes[type] = classType;
			}else if (type == 'units.TableFish') {
				classType = getDefinitionByName('units.Walkgolden') as Class;
			}else if (type == 'units.SpiritZone') {
				classType = getDefinitionByName('units.Personage') as Class;
			}else if (type == 'units.Pest') {
				classType = getDefinitionByName('units.Box') as Class;
			}else if (type == 'units.WaterFloat') {
				classType = getDefinitionByName('units.Decor') as Class;
			} else {
				classType = classes[type];
			}
			var unit:Unit = new classType(object);
			if (unit.formed) 
			{
				unit.take();
			}
			
			return unit;
		}
		
		public static function addMore(hide:Boolean = false):void
		{
			for (var i:int = 0; i < unitsMove.length; i++) 
			{
				if (unitsMove[i].move) 
				{
					unitsMove[i].visible = false;
				}			
			}
			
			if (lastUnit != null)
			{
				if (lastUnit.hasOwnProperty('fromStock') && lastUnit.fromStock == true)
				{
					if (!App.user.stock.check(lastUnit.sid))
					{
						Cursor.type = "default";
						return;
					}
				}
				
				var unit:Unit = add(lastUnit);
				unit.move = true;
				App.map.moved = unit;
			}
		}
		
		public static function calcStateUnit(_coords:Object, _cells:int, _rows:int):Boolean
		{
			var node:AStarNodeVO;
			for (var i:uint = 0; i < _cells; i++)
			{
				for (var j:uint = 0; j < _rows; j++)
				{
					node = App.map._aStarNodes[_coords.x + i][_coords.z + j];
					if (node.p != 0 || node.b != 0 || node.open == false || node.object != null)
					{
						return false;
					}
				}
			}
			return true;
		}

	}
}
