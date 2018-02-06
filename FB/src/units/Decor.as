package units
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Load;
	import core.MD5;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.Hints;
	import ui.SystemPanel;
	import utils.UnitsHelper;
	import wins.DayliBonusWindow;
	import wins.DaylicWindow;
	import wins.HeroWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.TravelWindow;
	import wins.Window;
	
	public class Decor extends AUnit{

		public static var DOG_SAND:int = 1716;
		public static var HORSE_NET:int = 1141;
		public static var WARDROBE:int = 1342;
		public static var STOCKHOUSE:int = 2537;
		public static var OCTOPUS_RUINS:int = 689;
		private var roadObjs:Array = ['road_1','road_3','road_2'];
		private var bridgeDecor:Array = [925, 926, 927, 928, 929];
		private var magazineDecor:Array = [1124, 1125, 1126];
		private var tableDecor:Array = [1114, 1115];
		private var clickAnimateDecor:Array = [1347, 2893];
		private var octopusPers:Unit;
		private var horsePers:Unit;
		private var dogPers:Unit;
		
		public function Decor(object:Object)
		{
			layer = Map.LAYER_SORT;
			if (App.data.storage[object.sid].dtype == 1)
				layer = Map.LAYER_LAND;
			
			object['hasLoader'] = false;
			super(object);
			
			touchableInGuest = false;
			if (App.user.worldID != User.AQUA_HERO_LOCATION)
				multiple = true;
			stockable = true;
			transable = false;
			
			if (Config.admin)
			{
				stockable = true;
				touchable = true;
				rotateable = true;
				moveable = true;
				removable = true;
				transable = true;
			}
			if (this.type && (this.type == 'Decor' || this.type == 'Firework' || this.type == 'Wall' || this is WaterFloat))
			{
				if (App.user.mode == User.GUEST)
				{
					var hash:String = MD5.encrypt(Config.getSwf(type, info.view));
					if ((Load.cache[hash] != undefined && Load.cache[hash].status == 3) || !open) {
						Load.loading(Config.getSwf(type, info.view), onLoad);
					}else{
						if(SystemPanel.noload)
							clearBmaps = true;
						Load.loading(Config.getSwf(type, info.view), onLoad);
						//if (true)
							//onLoad(UnitsHelper.cTexture);
						//else
							//onLoad(UnitsHelper.bTexture);
					}
				}else
					Load.loading(Config.getSwf(type, info.view), onLoad);
			
			}
			
			if(!formed) addEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			tip = function():Object {
				return {
					title:info.title,
					text:info.description
				};
			};
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			
			var leftTop:Boolean = App.map._aStarNodes[coords.x][coords.z + rows -1].open;
			var rightTop:Boolean = App.map._aStarNodes[coords.x][coords.z].open;
			var leftBot:Boolean = App.map._aStarNodes[coords.x + cells -1][coords.z + rows -1].open;
			var rightBot:Boolean = App.map._aStarNodes[coords.x + cells -1][coords.z].open;
			
			if (leftTop && rightTop && leftBot && rightBot)
			{
				this.open = true;
			}else
			{
				this.open = false;
			}
			if (bridgeDecor.indexOf(this.sid) != -1)
				open = true;
			if (App.user.worldID == User.NEPTUNE_MAP || App.user.worldID == User.HALLOWEEN_MAP || App.user.worldID == User.SWEET_MAP)
				stockable = false;
		}
		
		override public function calcDepth():void
		{
			//var left:Object = {x: x + IsoTile.width * ((rows > 1) ? rows * .5 : 1), y: y + IsoTile.height * ((rows > 1) ? rows * .5 : 1)};
			//var right:Object = {x: x + IsoTile.width * ((cells > 1) ? cells * .5 : 1), y: y + IsoTile.height * ((cells > 1) ? cells * .5 : 1)};
			var left:Object = {x: x - IsoTile.width * rows * .5, y: y + IsoTile.height * rows * .5};
			var right:Object = {x: x + IsoTile.width * cells * .5, y: y + IsoTile.height * cells * .5};
			depth = (left.x + right.x) + (left.y + right.y) * 100;
			if (magazineDecor.indexOf(this.sid) != -1)
			{
				depth = (left.x + right.x) + (left.y + right.y) * 103;
			}
		}
		
		//override public function addAnimation():void
		//{
			//multiBitmap = new Bitmap();
			//addChild(multiBitmap);
			//
			//ax = textures.animation.ax;
			//ay = textures.animation.ay; // позиция битмапки персонажа 
			//
			//clearAnimation();
			//
			//var arrSorted:Array = [];
			//for each(var nm:String in framesTypes) {
				//arrSorted.push(nm); 
			//}
			//arrSorted.sort();
			//
			//for (var i:int = 0; i < arrSorted.length; i++ ) {
				//var name:String = arrSorted[i];
				//multipleAnime[name] = { bitmap:new Bitmap(), cadr: -1 };
				//bitmapContainer.addChild(multipleAnime[name].bitmap);
				//
				//if (textures.animation.animations[name]['unvisible'] != undefined && textures.animation.animations[name]['unvisible'] == true) {
					//multipleAnime[name].bitmap.visible = false;
				//}
				//if (onHideAnim.indexOf(this.sid) != -1)
					//multipleAnime[name].bitmap.visible = false;
				//
				//multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				//multipleAnime[name]['frame'] = 0;
				//multipleAnime[name]['bid'] = i;
				//
			//}
			//
			//firstDraw = false;
			//
			///*if (!animated)
			//{
				//startAnimation();
			//}*/
		//}
		
		override public function initAnimation():void 
		{
			if (!textures || !textures.hasOwnProperty('animation') || Numbers.countProps(textures.animation.animations) == 0)
				return;
			framesTypes = [];
			
			var frameType:String = new String(); if (textures && textures.hasOwnProperty('animation')) 
			{
				
				for (frameType in textures.animation.animations) 
				{
					framesTypes.push(frameType);
				}
				addAnimation();
				//if(bridgeDecor.indexOf(this.sid) != -1)
				startAnimation(true);
			}
		}
		
		override public function take():void 
		{
			if (info.dtype == 0 || info.type != 'Decor') super.take();
		}
		override public function free():void 
		{
			if (info.dtype == 0 || info.type != 'Decor') super.free();
		}
		
		override public function set touch(touch:Boolean):void 
		{
			/*if ((!moveable && Cursor.type == 'move') ||
				(!removable && Cursor.type == 'remove') ||
				(!rotateable && Cursor.type == 'rotate') ||
				( !touchable && Cursor.type == 'default'))*/
			
			if (onTouchDecor.indexOf(this.sid) != -1)
				return;
			
			super.touch = touch;
		}
		
		
		public function onAfterBuy(e:AppEvent):void
		{
			removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			App.user.stock.add(Stock.EXP, info.experience);
			for (var itemAdded:* in info.tostock)
			{
				App.user.stock.add(itemAdded, info.tostock[itemAdded]);
			}
			
			if(App.data.storage[sid].experience > 0)Hints.plus(Stock.EXP, App.data.storage[sid].experience, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
			
			/*if (App.social == 'FB') {
				ExternalApi._6epush([ "_event", { "event": "gain", "item": "decoration" } ]);
			}*/
			
			if (App.social == 'FB')
			{
				ExternalApi.og('buy','decoration');
			}
		}
		
		override public function onLoad(data:*):void 
		{
			textures = data;
			var levelData:Object = new Object;
			if(textures.sprites.length > 0){
				levelData = textures.sprites[0];
			}else{
				var sttr:* = Numbers.firstProp(textures.animation.animations);
				levelData = textures.animation.animations[sttr.key].frames[0];
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			framesType = info.view;
			if (textures && textures.hasOwnProperty('animation')) 
				initAnimation();
				
			if (!open && formed)
				applyFilter();
				
			if (__hasPointing)
			{
				hidePointing();
				showPointing(currPointingSetts['position'],currPointingSetts['deltaX'],currPointingSetts['deltaY'],currPointingSetts['container']);
			}
			if(clearBmaps){
				Load.clearCache(Config.getSwf(type, info.view));
				data = null;
			}
			
		}
		
		override public function draw(bitmapData:BitmapData, dx:int, dy:int):void 
		{
			super.draw(bitmapData, dx, dy);
			if (this.sid == 1018)
				drawMirror();
		}
		
		private var tempBmap:Bitmap;
		private function drawMirror():void
		{
			tempBmap = new Bitmap(new BitmapData(bitmap.width, bitmap.height, true, 0x0));
			tempBmap.x = bitmap.x;
			tempBmap.y = bitmap.y;
			bitmapContainer.addChildAt(tempBmap,0);
			//tempBmap = new Bitmap(bitmap.bitmapData.clone());
			App.self.setOnEnterFrame(redrawMirror);
			//redrawMirror();
		}
		private var mirrorSprite:Sprite;
		private function redrawMirror(e:* = null):void
		{
			mirrorSprite = new Sprite();
			var mapPart:Bitmap = new Bitmap(new BitmapData(bitmap.width, bitmap.height, true, 0x0));
			
			var pos:Object = IsoConvert.isoToScreen(this.coords.x - 5, this.coords.z + 0, true)
			if (rotate)
				pos = IsoConvert.isoToScreen(this.coords.x -2, this.coords.z - 3, true);
				
			mapPart.bitmapData.draw(App.map, new Matrix(1, 0, 0, 1, -pos.x, -pos.y));
			if (rotate)
			{
				mapPart.scaleX *=-1;
				mapPart.x += mapPart.width;
			}
				
			var mask:Shape = new Shape()
			mask.graphics.beginFill(0xffffff, 1);
			mask.graphics.drawEllipse(0, 0, bitmap.width-15, bitmap.height-14);
			mask.graphics.endFill();
			mask.rotation = -12;
			mask.x = -3;
			mask.y = + 17;
			mask.cacheAsBitmap = true;
			mapPart.cacheAsBitmap = true;
			
			mapPart.mask = mask;
			mapPart.smoothing = true;
			mirrorSprite.addChild(mapPart);
			mirrorSprite.addChild(mask);
			tempBmap.bitmapData.draw(mirrorSprite);
		}
		
		private var cantClick:Boolean = true;
		override public function click():Boolean 
		{
			if (!cantClick || !textures)
				return false;
			
			if (App.user.useSectors)
			{
				var node1:AStarNodeVO = App.map._aStarNodes[this.coords.x][this.coords.z];
				
				if (!node1.sector.open)
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1495607052980') + " " + info.title,
						confirm:function():void
						{
							node1.sector.fireNeiborsReses();
						}
					}).show();
					return false;
				}
			}
			
			//getGoldenReward();
			if (sid == Decor.STOCKHOUSE)
			{
				new StockWindow( {
					mode:(User.inExpedition?StockWindow.MINISTOCK:StockWindow.DEFAULT)
				}).show();
				return true;
			}
			if (sid == Decor.WARDROBE && App.user.mode == User.OWNER)
			{
				new HeroWindow({sID:sid}).show();
			}
			if (sid == Decor.OCTOPUS_RUINS && App.user.mode == User.OWNER)
			{
				cantClick = true;
				App.user.addTarget({target: this, near: true, callback: function():void 
				{
					removable = true;
					touchable = false;
					applyRemove = false;
					remove();
					octopusPers = new Walkgolden( { sid:Walkgolden.JOHNY, id:1, x:coords.x, z:coords.z } );
					octopusPers.buyAction({hideHints:true});
					App.user.hero.framesType = Personage.STOP;
				}, event: Personage.WORK, jobPosition: getContactPosition(), shortcutCheck: true, onStart: function(_target:* = null):void
				{
					ordered = false;
				}});
			}
			
			if (sid == Decor.HORSE_NET && App.user.mode == User.OWNER)
			{
				cantClick = true;
				App.user.addTarget({target: this, near: true, callback: function():void 
				{
					removable = true;
					touchable = false;
					applyRemove = false;
					remove();
					horsePers = new Animal( { sid:Animal.SEAHORSE, x:coords.x, z:coords.z } );
					horsePers.buyAction({hideHints:true});
					App.user.hero.framesType = Personage.STOP;
				}, event: Personage.WORK, jobPosition: getContactPosition(), shortcutCheck: true, onStart: function(_target:* = null):void
				{
					ordered = false;
				}});
			}
			
			if (sid == Decor.DOG_SAND && App.user.mode == User.OWNER)
			{
				cantClick = true;
				App.user.addTarget({target: this, near: true, callback: function():void 
				{
					removable = true;
					touchable = false;
					applyRemove = false;
					remove();
					dogPers = new Pet( { sid:Pet.DOG, x:coords.x, z:coords.z } );
					dogPers.buyAction({hideHints:true});
					App.user.hero.framesType = Personage.STOP;
				}, event: Personage.WORK, jobPosition: getContactPosition(), shortcutCheck: true, onStart: function(_target:* = null):void
				{
					ordered = false;
				}});
			}
			if (!super.click()) return false;
			
			return true;
		}
		
		private function onContextClick():void
		{
			//trace("onContextClick");
		}
		
		override public function buyAction(setts:*=null):void {
			//Hints.plus(Stock.EXP, info.experience, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y),true);
			//App.user.stock.add(Stock.EXP, info.experience);
			super.buyAction();
		}
		
		override public function uninstall():void 
		{
			if (this.sid == 1018)
			{
				App.self.setOffEnterFrame(redrawMirror);
			}
			super.uninstall();
		}
		
		public var onTouchDecor:Array = [925, 926, 927, 928, 929];
		override public function calcState(node:AStarNodeVO):int
		{
			//return EMPTY;
			/*if (onTouchDecor.indexOf(this.sid) == -1)
				return EMPTY;*/
				
			if (info.market == 17)
			{
				for (var n:uint = 0; n < cells; n++) 
				{
					for (var m:uint = 0; m < rows; m++) 
					{
						node = App.map._aStarNodes[coords.x + n][coords.z + m];
						
						if (info.base == 1)
						{
							if (node.w != 1 || node.open == false)
							{
								//if (node.object != null && (node.object is Wall))
									//return EMPTY;
								//else
									return OCCUPIED;
							}
						}
						if (info.base == 0)
						{
							if  ((node.b != 0) || node.open == false || node.object != null) 
							{
								return OCCUPIED;
							}
						}
					}
				}
				
				return EMPTY;
			}
			
			if (info.dtype == 0 || info.type != 'Decor')
			{
				for (var i:uint = 0; i < cells; i++) {
					for (var j:uint = 0; j < rows; j++) {
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						
						if (magazineDecor.indexOf(this.sid) != -1)
						{
							if(node.object != null &&  tableDecor.indexOf(node.object['sid']) != -1)
								return EMPTY;
							else
								return OCCUPIED;
						}
						
						if (info.base == 1)
						{
							if (node.w != 1 || node.open == false /*|| node.object != null*/)
							{
								return OCCUPIED;
							}
						}
						if (info.base == 0)
						{
							if  ((node.b != 0) || node.open == false|| node.object != null) 
							{
								return OCCUPIED;
							}
						}
						/*if (node.b != 0 || node.open == false)
						{
							if (node.object && !(node.object is Resource) && !(node.object is Field))
									return EMPTY;
							
							return OCCUPIED;
						}*/
					}
				}
				
				return EMPTY;
			}else{
				return super.calcState(node);
			}
		}
	}
}