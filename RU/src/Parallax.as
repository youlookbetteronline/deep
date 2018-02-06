package  
{
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import ui.SystemPanel;
	/**
	 * ...
	 * @author 
	 */
	public class Parallax
	{
		/*[Embed(source="islands/island1.png")]
		private var Tile1:Class;
		
		[Embed(source="islands/island2.png")]
		private var Tile2:Class;
		
		[Embed(source="islands/island3.png")]
		private var Tile3:Class;
		
		[Embed(source="islands/island4.png")]
		private var Tile4:Class;
		
		[Embed(source="islands/island5.png")]
		private var Tile5:Class;
		
		
		*/
		public var tiles:Object = [
			/*new Tile1().bitmapData,
			new Tile2().bitmapData,
			new Tile3().bitmapData,
			new Tile4().bitmapData,
			new Tile5().bitmapData*/
		]
		
		public var names:Object = [
			'island1',
			'island2',
			'island3',
			'island4',
			'island5',
			'island6',
			'island7'
		]
		
		private static var rockCoords:Array = [
			{x:2341, y:691, ind:10},
			{x:2030, y:583, ind:11},
			{x:1038, y:989, ind:13},
			{x:2038, y:2789, ind:13},
			{x:653, y:1524, ind:1},
			{x:969, y:1969, ind:9},
			{x:749, y:261, ind:2},
			{x:3242, y:-46, ind:14},
			{x:3581, y:2008, ind:15},
			{x:4557, y:361, ind:16},
			{x:5955, y:3193, ind:17},
			{x:7371, y:2140, ind:18},
			{x:5289, y:1530, ind:19},
			{x:6030, y:744, ind:20},
			{x:3428, y:3753, ind:20},
			{x:4155, y:2834, ind:10},
			{x:7765, y:3689, ind:7},
			{x:2826, y:2677, ind:9},
			{x:3479, y:2518, ind:5},
			{x:4196, y:4079, ind:8 },
			{x:8196, y:3379, ind:1 },
			{x:4196, y:-1679, ind:2 },
			{x:8196, y:-1479, ind:1 },
			{x:1696, y:4479, ind:3 },
			{x:8996, y:2979, ind:15 },
			{x:8596, y:1479, ind:4 }
			
		]
		
		public static var islandsPosition:Object = {
			81: {
				x:1400,
				y:500
			},
			196: {
				x:0,
				y:0
			}
		}
		
		public var island:Bitmap;
		public var islands:Array = [];
		public var rocks:Array = [];
		public var layer1:Sprite;
		public var layer2:Sprite;
		
		public function Parallax()
		{
			layer1 = new Sprite();
			App.map.addChildAt(layer1, 0);
			
			layer1.x = islandsPosition[App.map.id].x;
			layer1.y = islandsPosition[App.map.id].y;
			
			layer2 = new Sprite();
			App.map.addChild(layer2);
			
			var cont:Sprite = new Sprite();
			layer1.addChild(cont);
			
			
			for (var i:int = 1; i < 12; i++ ) {
				Load.loading(Config.getSwf('Islands', 'island_' + i), function(data:*):void {
					var bitmap:Bitmap = new Bitmap(data.sprites[0].bmp);
					bitmap.x = data.sprites[0].dx;
					bitmap.y = data.sprites[0].dy;
					cont.addChild(bitmap);
				})
			}
			
			/*cont.x = (App.map.bitmap.width - cont.width) / 2;
			cont.y = (App.map.bitmap.height - cont.height) / 2;*/
			
			Load.loading(Config.getSwf('Islands', 'rocks'), onRocksLoad);
		}
		
		private function onRocksLoad(data:*):void
		{
			var _count:int = Math.floor(rockCoords.length / 3);
			
			var counter:int = 0;
			var rock:Rock;
			for (var j:int = 0; j < 3; j++) {
				for (var i:int = 0; i < _count; i++) {
					rock = new Rock(/*takeRandomRock()*/data.rocks[rockCoords[counter].ind]);
					rock.smoothing = true;
					rock.setDepth(j, Rock.FRONT);
					rocks.push(rock);
					
					layer2.addChild(rock);
					
					rock.x = rockCoords[counter].x;
					rock.y = rockCoords[counter].y;
					
					rock.X = rockCoords[counter].x;
					rock.Y = rockCoords[counter].y;
					counter ++;
				}
			}
			
			function takeRandomRock():* {
				var randomID:int = int(Math.random() * data.rocks.length);
				return data.rocks[randomID];
			}
			
			layer2.visible = false;
		}
		
		private var k:Number = 0.3;// 0.3;
		public function redraw(dx:int, dy:int):void {
			
			if(layer2.visible){
				for each(var rock:Rock in rocks) {
					rock.x += dx * (1.2 + 1 * rock.k);
					rock.y += dy * (1.2 + 1 * rock.k);
				}
			}
			layer1.x -= dx * k;
			layer1.y -= dy * k;
		}
		
		
		
		public function dScale():void 
		{
			layer1.x = islandsPosition[App.map.id].x;
			layer1.y = islandsPosition[App.map.id].y;
			layer2.x = 0;
			layer2.y = 0;
			
			//trace('SystemPanel.scaleMode '+SystemPanel.scaleMode)
			if (App.map.scaleX >= 0.6) {
				layer2.visible = false;
			}else {
				layer2.visible = true;
			}
			
			if(layer2.visible){
				for each(var rock:Rock in rocks) {
					rock.x = rock.X;
					rock.y = rock.Y;
				}
			}	
			
		}
		
		public function update(e:*):void 
		{
			/*for each(var island:Island in islands){
				island.x = App.map.x - App.map.width/2  + (App.self.stage.stageWidth - island.width) / 2 + island.dX * App.map.scaleX;
				island.y = App.map.y - App.map.height / 2 + (App.self.stage.stageHeight - island.height) / 2 + island.dY * App.map.scaleY;
			}*/
		}
	}
}
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.BlurFilter;
import ui.UserInterface;

internal class Island extends Bitmap 
{
	public static const BACK:String = 'back';
	public static const FRONT:String = 'front';
	
	public function Island(view:String):void 
	{
		Load.loading(Config.getImage('islands', view), onLoad)
		super(new BitmapData(1, 1, true));
		
	}
	
	private function onLoad(data:*):void {
		this.bitmapData = data.bitmapData;
		this.scaleX = this.scaleY = 0.5;
	}
	
	public var depth:int = 0;
	public var k:Number = 1;
	public function setDepth(depth:int, side:String = BACK):void{
		this.depth = depth;
		//this.scaleX = this.scaleY = 1 - 0.2 * depth;
		
		if(side == BACK){
			var blur:int = 5 * (depth + 1);
			this.filters = [new BlurFilter(blur, blur, 3)];
			//this.scaleX = this.scaleY = 1 - 0.2 * depth;
			
			if (depth > 0) {
				this.k = depth;
			}
		}
		
		if (side == FRONT) 
		{
			this.scaleX = this.scaleY = 1 + 0.5 * depth;
			blur = 10 * (depth);
			this.filters = [new BlurFilter(blur, blur, 3)];
			
			this.k = depth;
		}
	}	
}


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.BlurFilter;

internal class Rock extends Bitmap 
{
	public var X:int = 0;
	public var Y:int = 0;
	public static const BACK:String = 'back';
	public static const FRONT:String = 'front';
	
	public function Rock(bmd:BitmapData):void 
	{
		//dX = - App.map.width - App.map.x// + Math.random() * App.map.width;
		//dY = - App.map.height- App.map.y// + Math.random() * App.map.height;
		//this.alpha = 0.5 + Math.random() * 0.5;
		//this.scaleX = this.scaleY = Math.random() * 0.5 + 0.5;
		super(bmd);
	}
	
	public var depth:int = 0;
	public var k:Number = 1;
	public function setDepth(depth:int, side:String = BACK):void{
		this.depth = depth;
		//this.scaleX = this.scaleY = 1 - 0.2 * depth;
		
		if(side == BACK){
			var blur:int = 5 * (depth + 1);
			this.filters = [new BlurFilter(blur, blur, 3)];
			//this.scaleX = this.scaleY = 1 - 0.2 * depth;
			
			if (depth > 0) {
				this.k = depth;
			}
		}
		
		if (side == FRONT) 
		{
			this.scaleX = this.scaleY = 1 + 0.5 * depth;
			blur = 10 * (depth);
			this.filters = [new BlurFilter(blur, blur, 3)];
			
			this.k = depth;
		}
	}	
}