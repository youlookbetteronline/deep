package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.filters.BlurFilter;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.Cursor;
	/**
	 * ...
	 * @author 
	 */
	public class Wall extends Decor 
	{
		public var thisZone:int;
		public var zoneOpen:int;
		public var isDoor:Boolean = false;
		public function Wall(object:Object) 
		{
			super(object);
			if (object.hasOwnProperty('zoneOpen'))
			{
				this.zoneOpen = object.zoneOpen;
				isDoor = true;
			}
			if (App.map.rooms.hasOwnProperty(this.zone))
				App.map.rooms[this.zone].newRoomObject(this);
				
			var node:AStarNodeVO = App.map._aStarNodes[this.coords.x][this.coords.z];
			thisZone = node.z;
			checkWallState();
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			return EMPTY;
		}
		
		public var wallFader:LayerX = new LayerX();
		public function drawFader(state:int):void
		{
			if (this.info.view == 'wall_house_outdoor' || this.info.view == 'wall_house_angle' || this.info.view == 'wall_house_1' || this.info.view == 'wall_house_2'|| this.info.view == 'wall_house_3'|| this.info.view == 'wall_house_4'|| this.info.view == 'wall_house')
				return;
			
			if (wallFader && wallFader.parent)
				wallFader.parent.removeChild(wallFader);
				
			var checkNode:AStarNodeVO;
			if (App.map._aStarNodes[coords.x].hasOwnProperty(coords.z + rows) && rotate == false)
			{
				checkNode = App.map._aStarNodes[coords.x + 1][coords.z + rows];
				if (World.zoneIsOpen(checkNode.z))
					return;
			}
			
			if (App.map._aStarNodes.hasOwnProperty(coords.z + cells) && rotate == true)
			{
				checkNode = App.map._aStarNodes[coords.x + cells][coords.z + 1];
				if (World.zoneIsOpen(checkNode.z))
					return;
			}
			
			wallFader = new LayerX();
			var fHeight:int;
			var fWidth:int = 80;
			var fBias:int = 40;
			var dY:int;
			if (this.info.view == 'wall_house_half')
			{
				fWidth = 40;
				fBias = 20;
			}
			if (this.info.view == 'wall_house_empty_2')
			{
				fWidth = 60;
				fBias = 30;
			}
			if (state == Room.LOWER)
			{
				dY = 0;
				fHeight = 65; 
			}	
			else{
				dY = -120;
				fHeight = 186;
			}
			var point:Object = {x:-38, y:dY};
			wallFader.graphics.moveTo(point.x, point.y);
			wallFader.graphics.beginFill(0x000000, .5);
			
			point = {x:-38 + fWidth, y:dY + fBias};
			wallFader.graphics.lineTo(point.x, point.y);
			
			point = {x:-38 + fWidth, y:dY + fHeight - 50 + fBias + 10};
			wallFader.graphics.lineTo(point.x, point.y);
			
			point = {x:-38, y:dY + fHeight - 40};
			wallFader.graphics.lineTo(point.x, point.y);
			
			point = {x:-38, y:dY};
			wallFader.graphics.lineTo(point.x, point.y);
			wallFader.graphics.endFill();
			wallFader.filters = [new BlurFilter(8, 8)];
			
			this.bitmapContainer.addChild(wallFader);
		}
		
		private var stateDecor:int = 0;
		override public function click():Boolean 
		{
			return false;
		}
		
		public function set wallState(state:int):void 
		{
			stateWall = state;
		}
		private var checkTimeout:uint = 1;
		private var stateWall:int = 1;
		public function checkWallState():void
		{
			if (!textures){
				checkTimeout = setTimeout(checkWallState, 200);
				return;
			}
			var levelData:Object;
			if (isDoor)
			{
				if (World.zoneIsOpen(zoneOpen))
				{
					free();
					if(stateWall == Room.LOWER){
					levelData = textures.sprites[3];
					}
					else{
						levelData = textures.sprites[2];
					}
				}else{
					if(stateWall == Room.LOWER){
						levelData = textures.sprites[1];
					}
					else{
						levelData = textures.sprites[0];
					}
				}
			}else{
				if(stateWall == Room.LOWER){
					levelData = textures.sprites[1];
				}
				else{
					levelData = textures.sprites[0];
				}
			}
			if (stateWall == Room.FULL)
			{
				drawFader(stateWall);
					
				draw(levelData.bmp, levelData.dx, levelData.dy);
			}else{
				var newBitmapa:Bitmap = new Bitmap(bitmap.bitmapData.clone());
				addChild(newBitmapa);
				newBitmapa.x = bitmap.x;
				newBitmapa.y = bitmap.y;
				bitmap.alpha = 0;
				
				drawFader(stateWall);
					
				draw(levelData.bmp, levelData.dx, levelData.dy);
				TweenLite.to(bitmap, Room.checkTime, {alpha:1, onComplete:function():void{}});
				
				TweenLite.to(newBitmapa, Room.checkTime, {alpha:0, onComplete:function():void{
					if (newBitmapa && newBitmapa.parent)
						newBitmapa.parent.removeChild(newBitmapa);
				}});
			
			}
		}
		
		override public function set touch(touch:Boolean):void 
		{}
		
		override public function take():void
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
					
					nodes.push(node);
					
					node.isWall = true;
					node.b = 1;
					node.w = 1;
					node.object = this;
					if (layer == Map.LAYER_FIELD || layer == Map.LAYER_LAND)
						node.isWall = false;
					
					if (i > 0 && i < cells - 1 && j > 0 && j < rows - 1)
					{
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						
						part.isWall = true;
						part.b = 1;
						part.w = 1;
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
								water.w = 1;
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
		
		override public function free():void
		{
			if (!takeable)
				return;
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			var fromCell:int = 0;
			var fromRow:int = 0;
			var toCell:int = cells;
			var toRow:int = rows;
			
			if (isDoor && World.zoneIsOpen(zoneOpen))
			{
				if (rotate)
				{
					fromRow = 2;//2
					toRow = rows - 1;
				}else{
					fromCell = 2;//2
					toCell = cells - 1;
				}
			}
			
			if (App.map._aStarNodes != null)
			{
				for (var i:uint = fromCell; i < toCell; i++)
				{
					for (var j:uint = fromRow; j < toRow; j++)
					{
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						nodes.push(node);
						node.isWall = false;
						node.b = 0;
						node.w = 0;
						node.object = null;
						
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						part.isWall = false;
						part.b = 0;
						node.w = 0;
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
		
		override public function onLoad(data:*):void 
		{
			textures = data;
			var levelData:Object = new Object;
			if (textures.sprites.length > 0){
				if (isDoor)
				{
					if (World.zoneIsOpen(zoneOpen))
						levelData = textures.sprites[2];
					else
						levelData = textures.sprites[0];
				}
				else
					levelData = textures.sprites[0];
			}else{
				var sttr:* = Numbers.firstProp(textures.animation.animations);
				levelData = textures.animation.animations[sttr.key].frames[0];
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			framesType = info.view;
			if (textures && textures.hasOwnProperty('animation')) 
				initAnimation();
			
			applyFilter();
			if (__hasPointing)
			{
				hidePointing();
				showPointing(currPointingSetts['position'],currPointingSetts['deltaX'],currPointingSetts['deltaY'],currPointingSetts['container']);
			}
		}
		
		override public function uninstall():void 
		{
			clearTimeout(checkTimeout);
			super.uninstall();
		}
		
		override public function applyFilter(colour:uint = 0xeff200):void
		{
			checkWallState();
		}
	}

}