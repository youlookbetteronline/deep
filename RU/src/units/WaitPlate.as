package units 
{
	import astar.AStarNodeVO;
	import core.IsoTile;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import ui.Cursor;
	import ui.UnitIcon;
	import wins.RewardWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 111
	 */
	public class WaitPlate extends LayerX 
	{
		public const OCCUPIED:uint = 1;
		public const EMPTY:uint = 2;
		public const TOCHED:uint = 3;
		public const DEFAULT:uint = 4;
		public const IDENTIFIED:uint = 5;
		public const HIGHLIGHTED:uint = 6;
		
		public var dx:int = 0;
		public var dy:int = 0;
		public var sid:uint = 0;
		public var id:uint = 0;
		public var depth:uint = 0;
		public var cells:uint = 0;
		public var rows:uint = 0;
		public var level:uint = 0;
		public var totalLevels:uint = 0;
		
		public var touchable:Boolean = true;
		public var moveable:Boolean = true;
		public var transable:Boolean = true;
		public var removable:Boolean = true;
		public var clickable:Boolean = true;
		public var rotateable:Boolean = true;
		public var takeable:Boolean = true;
		public var transparent:Boolean = false;
		
		public var formed:Boolean = true;
		public var applyRemove:Boolean = true;
		public var touchableInGuest:Boolean = true;
		public var bitmapContainer:Sprite;
		public var animationBitmap:Bitmap;
		public var bitmap:Bitmap;
		public var layer:String;
		public var icon:UnitIcon;
		public var textures:Object;
		public var bounds:Object;
		public var coords:Object = {x: 0, y: 0, z: 0};
		//public var prevCoords:Object = {x: 0, y: 0, z: 0};
		public var iconPosition:Object = { x:0, y:0 };
		public var booster:Booster;
		public var worker:Unit;
		public var targetWorker:Unit;
		
		private var _touch:Boolean;
		private var _ordered:Boolean;
		private var _rotate:Boolean;
		private var _state:uint = DEFAULT;
		
		public function get info():Object {
			return App.data.storage[sid];
		}
		public function get type():String {
			return App.data.storage[sid].type;
		}
		public function set touch(touch:Boolean):void{
			if (Cursor.type == 'stock')
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
		public function get bmp():Bitmap{
			return bitmap;
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
		private function get centerPoint():Object{
			var left:Object = {x: x - IsoTile.width * rows * .5, y: y + IsoTile.height * rows * .5};
			var right:Object = {x: x + IsoTile.width * cells * .5, y: y + IsoTile.height * cells * .5};
			var centr:Object = {x:(left.x + right.x), y:(left.y + right.y)};
			return {x: (centr.x / 2) - this.x, y: (centr.y / 2) - this.y};
		}
		private var bigBoards:Array = ['board1', 'board2', 'board3', 'board4'];
		private var smallBoards:Array = ['sign1', 'sign2', 'sign3', 'sign4'];
		private function get texture():BitmapData{
			var _vars:Array;
			if (cells <= 5 || rows <= 5)
				_vars = smallBoards;
			else
				_vars = bigBoards;
			var i:int;
			i = Math.random() * _vars.length;
			return Window.textures[_vars[i]]
		}
		public function WaitPlate(data:Object) 
		{
			layer = Map.LAYER_SORT;
			bitmapContainer = new Sprite();
			bitmap = new Bitmap(null, "auto", true);
			sid = data.sid || 0;
			id = data.id || 0;
			
			_rotate = data['rotate'] || false;
			
			if (data.hasOwnProperty('level'))
			{
				level = data.level;
				if (type == 'Building')
				{
					var numInstance:uint = instanceNumber();
					if (info.instance && info.instance.devel && info.instance.devel[numInstance] && info.instance.devel[numInstance].req) 
					{
						for each(var obj:* in info.instance.devel[numInstance].req)
						{
							totalLevels++;
						}
					}
				}
			}
				
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
			
			tip = function():Object 
			{
				return {
					title:info.title,
					text: info.description
				};
			}
			
			bitmapContainer.addChild(bitmap);
			addChild(bitmapContainer);
			
			placing(data.x || 0, data.y || 0, data.z || 0);
			install();
			
			if(this.info && this.info.config){
				var unitConfig:Array = String(this.info.config).split('').reverse();
				for (var configID:int = 0; configID < unitConfig.length; configID++ ) {
					if (unitConfig[configID] == "1" && this.hasOwnProperty(App.map.CONFIG_DATA[configID])) {
						this[App.map.CONFIG_DATA[configID]] = false;
					}
				}
			}
			var _view:BitmapData = texture
			draw(_view, centerPoint.x - _view.width / 2, centerPoint.y - _view.height + 35);
			showIcon();
		}
		
		public function placing(x:uint, y:uint, z:uint):void
		{
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
			
			//iconSetPosition(0, 0);
			calcDepth();
			
			this.alpha = 1;
		}
		
		public function drawIcon(type:String, material:*, need:int = 0, params:Object = null, directSid:int = 0, posX:int = 0, posY:int = 0):void 
		{
			if (icon) clearIcon();
			if (!parent) return;
			
			icon = new UnitIcon(type, material, need, this, params);
			iconPosition = { x:posX, y:posY };
			icon.y = this.y + iconPosition.y;
			icon.x = this.x + iconPosition.x;
			
			if (!App.map.mIcon.contains(icon))
				App.map.mIcon.addChild(icon);
			
			iconSetPosition();
			App.map.iconSortResort();
		}
		
		public function showIcon():void 
		{
			var coordsCloud:Object = {
				x:0,
				y:-20
			};
			
			if (App.user.mode == User.GUEST) 
			{
				if (Friends.isOwnerSleeping(App.owner.id) && App.owner.id != '1' && App.social != 'SP') {
					clickable = false;
					return;
				}
				
				if (level >= totalLevels && (this.type == 'Building' || this.type == 'Pharmacy'))
				{
					drawIcon(UnitIcon.REWARD, Stock.COINS, 1, {
						glow:		false,
						iconScale: .64
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else
					clearIcon();
			}
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
			if (!icon) return;
			//if (!bounds && textures) countBounds();
			//if (bounds) {
				//iconIndentCount();
			icon.x = this.x + centerPoint.x;
			icon.y = this.y + centerPoint.y + bitmap.y - bitmap.height + 5;
			//}
		}
		
		public function iconIndentCount():void 
		{
			// pассчитывает отступ иконки от 0,0
			if (!bounds) return;
			if (this.type != "Golden" && this.type != "Building" && this.type != "Port" && this.type != "Bridge")
				return;
			
			iconPosition.x += bounds.x + bounds.w / 2;
			iconPosition.y += bounds.y + 15;
		}
		
		public function countBounds(animation:String = '', stage:int = -1):void {
			bounds = Anime.bounds(textures, { stage:stage, animation:animation, walking:false} );
		}
		
		public function click():Boolean
		{
			if (!clickable || (App.user.mode == User.GUEST && touchableInGuest == false))
				return false;
			App.tips.hide();
			if (App.user.mode != User.GUEST)
				return false;
			if (this.type == 'Building' || this.type == 'Pharmacy')
				guestClick();
			return true;
		}
		
		public var guestDone:Boolean = false;
		public function guestClick():void 
		{
			if (level < totalLevels)
				return;
			if (guestDone) return;
			
			if(App.user.addTarget({
				target		:this,
				near		:true,
				callback	:onGuestClick,
				event		:Personage.GATHER,
				jobPosition	:getContactPosition(),
				shortcut	:true
			})) {
				ordered = true;
			}else {
				ordered = false;
			}
		}
		
		public function onGuestClick():void 
		{			
			if (App.user.friends.takeGuestEnergy(App.owner.id))
			{
				guestDone = true;
				clearIcon();
				
				var that:* = this;
				Post.send({
					ctr:'user',
					act:'guestkick',
					uID:App.user.id,
					sID:this.sid,
					fID:App.owner.id
				}, function(error:int, data:Object, params:Object):void {
					if (error)
					{
						Errors.show(error, data);
						return;
					}	
					
					if (data.hasOwnProperty("bonus"))
					{
						Treasures.bonus(data.bonus, new Point(that.x, that.y));
					}
					
					ordered = false;
					
					if (data.hasOwnProperty('energy'))
					{
						if (App.user.friends.data[App.owner.id].energy != data.energy)
						{
							App.user.friends.data[App.owner.id].energy = data.energy;
							App.ui.leftPanel.update();
						}
					}
					
					if (data.hasOwnProperty('guestBonus')) 
					{
						if (App.self.getLength(data.guestBonus) == 0) 
						{
							return;
						}
						
						var bonus:Object = { };
						
						for (var sID:* in data.guestBonus) 
						{							
							var item:Object = data.guestBonus[sID];
							for(var count:* in item)
							bonus[sID] = count * item[count];							
						}
						
						App.user.stock.addAll(bonus);
						
						new RewardWindow( { bonus:bonus } ).show();
					}
					
					App.user.friends.giveGuestBonus(App.owner.id);
					that = null;
				});
			}else {
				ordered = false;
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
		
		public function instanceNumber():uint
		{
			var allInstances:Array = Map.findUnits([sid]);
			allInstances = allInstances.sortOn("id", Array.NUMERIC);
			
			var instanceNum:int = allInstances.indexOf(this) + 1;
			
			var numInstance:uint = instanceNum;
				
			var iterator:int = 0;
			
			if (info.instance) 
			{
				for (var dd:* in info.instance.devel)
				{
					iterator++;
				}
			}
			
			if (numInstance > iterator)
				numInstance = iterator;
				
			return numInstance;
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
		
		public function draw(bitmapData:BitmapData, _dx:int, _dy:int):void
		{
			bitmap.bitmapData = bitmapData;
			
			dx = _dx;
			dy = _dy;
			bitmap.x = dx;
			bitmap.y = dy;
			
			if (_rotate)
			{
				scaleX = Math.abs(scaleX) * -1;
			}
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
		
		public function uninstall():void 
		{
			hidePointing();
			App.map.removeUnit(this);
			clearIcon();
			clearVariables();
		}
		
		public function clearVariables():void {
			//return;
			var self:* = this;
			var description:XML = describeType(this);
			var variables:XMLList = description..variable;
			for each(var variable:XML in variables) {
				var ss:String = variable.@type;
				if(variable.@type == '*')
				{
					self[variable.@name] = null;
					continue;
				}
				var classType:Class = getDefinitionByName(variable.@type) as Class;
				switch(classType){
					case Sprite:
						if (self[variable.@name]){
							self[variable.@name].removeChildren();
							self[variable.@name] = null;
						}
						break;
					case Unit:
						self[variable.@name] = null;
						break;
				}
			}
			self = null;
		}
		
		public static function add(object:Object):WaitPlate
		{
			var unit:WaitPlate = new WaitPlate(object);
			unit.take();
			
			return unit;
		}
		
	}

}