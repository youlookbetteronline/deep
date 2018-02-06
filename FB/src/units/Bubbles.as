package units 
{
	import astar.AStarNodeVO;
	import core.IsoConvert;
	import core.IsoTile;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import ui.SystemPanel;
	/**
	 * ...
	 * @author 
	 */
	public class Bubbles extends Sprite 
	{
		public static var interval:int;
		public static var spotz:Array = [];
		//public static var count:int = 10;
		public function Bubbles()
		{
			
		}
		
		public static function init():void
		{
			interval = setInterval(addSpot, 2000);
		}
		
		public static function addSpot(coords:Object = null):void
		{
			if (!coords)
			{
				coords = {
					x:int(Math.random() * Map.cells),
					z:int(Math.random() * Map.rows)
				}
			}else{
				trace();
			}
			if (!App.map._aStarNodes)
				return;
			var node:AStarNodeVO = App.map._aStarNodes[coords.x][coords.z];
			if (node.w == 0 || node.open)
				return;
			var pos:Object = IsoConvert.isoToScreen(coords.x, coords.z, true);
			var s:Spot = new Spot(pos);
			spotz.push(s);
			/*for (var j:int = 0; j < count; j++)
			{
				var b:Bubble = new Bubble(pos);
				spotz.push(b);
			}*/
			//b.x = int( -10 + Math.random() * 20);
			
		}
		
		public static function disposeSpots():void
		{
			clearInterval(interval);
			if (spotz.length != 0)
			{
				for each(var bubl:* in spotz)
				{
					bubl.dispose();
				}
			}
		}
	}
}

import flash.display.Sprite;
import flash.events.Event;
import flash.events.Event;
import flash.events.Event;
import flash.events.Event;
import flash.geom.PerspectiveProjection;
import flash.geom.Point;
import flash.utils.setTimeout;

internal class Spot extends Sprite{
	
	private var bubbles:Array = [];
	private var count:int;
	public function Spot(pos:Object):void
	{
		/*var center:Object = {
			x: -App.map.x * App.map.scaleX + App.self.stage.stageWidth / 2,
			y: -App.map.y * App.map.scaleX + App.self.stage.stageHeight / 2
		}*/
		//this.transform.perspectiveProjection = new PerspectiveProjection();
        //this.transform.perspectiveProjection.projectionCenter = new Point(App.map.centerPoint.x, App.map.centerPoint.y); 
		this.x = pos.x;
		this.y = pos.y;
		
		App.map.mTreasure.addChild(this);
		
		count = 8 + int(Math.random() * 5);
		
		for (var j:int = 0; j < count; j++)
		{
			var b:Bubble = new Bubble({x:0, y:0}, this);
			addChild(b);
			bubbles.push(b);
		}
		//App.self.addEventListener(AppEvent.ON_MAP_REDRAW, relocateCenter);
	}
	
	/*public function relocateCenter(e:AppEvent):void
	{
		this.transform.perspectiveProjection.projectionCenter = new Point(App.map.centerPoint.x, App.map.centerPoint.y); 
	}*/
	
	public function disposeBubble(_b:Bubble):void
	{
		if (bubbles.indexOf(_b) != -1){
			removeChild(_b);
			bubbles.splice(bubbles.indexOf(_b), 1);
		}
	}
	
	public function dispose():void{
		//App.self.removeEventListener(AppEvent.ON_MAP_REDRAW, relocateCenter);
		for each(var b:Bubble in bubbles){
			b.dispose();
		}
		
		bubbles = [];
		if (parent)
			parent.removeChild(this);
		//App.map.mTreasure.removeChild(this);
	}
}

import flash.display.Bitmap;
import flash.events.Event;
import wins.Window;

internal class Bubble extends Bitmap{
	
	private static var bubblesArray:Array = ['dailyBonusBubble1', 'dailyBonusBubble2', 'dailyBonusBubble4', 'dailyBonusBubble5'];
	
	private var angleX:Number = -10 + Math.random() * 20;
	private var centerX:Number = 0;
	private var v:Number = 0.5;
	private var counter:int = 100 + Math.random() * 50;
	private var layer:Spot;
	
	public function Bubble(pos:Object, _layer:Spot):void
	{
		layer = _layer;
		
		v = 2 + Math.random() * 3;
		this.scaleX = this.scaleY = .2 + Math.random()*.8;
		var numm:int = int(Math.random() * bubblesArray.length);
		this.bitmapData = Window.textures[bubblesArray[numm]];
		this.smoothing = true;
		
		this.x = pos.x -10 + Math.random() * 20;
		this.y = pos.y;
		centerX = this.x;
		App.self.setOnEnterFrame(update);
		//addEventListener(Event.ENTER_FRAME, update);
	}
	
	private function update(e:Event):void
	{
		y -= v;
		x = centerX + Math.sin(angleX) * 10;
		angleX += .1;
		counter --;
		if (counter < 0)
			dispose();
	}
	
	public function dispose():void{
		App.self.setOffEnterFrame(update);
		//removeEventListener(Event.ENTER_FRAME, update);
		layer.disposeBubble(this);
	}
}