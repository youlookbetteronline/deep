package hlp {
	import astar.AStarNodeVO;
	import buttons.Button;
	import com.junkbyte.console.Cc;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import units.Resource;
	import units.Unit;
	import utils.Saver;
	import wins.Window;
	/**
	 * ...
	 * @author Andrey S
	 */
	public class PropsTool {
		static private var _stage:Stage;
		
		static private var allPresets:String = '';
		static private var x_size:uint = 10;
		static private var z_size:uint = 10;
		static private var x_coord:uint = 100;
		static private var z_coord:uint = 100;
		static private var _isCtrl:Boolean;
		static private var _zone:DisplayObject;
		static private var _sizeText:TextField;
		static private var _saveBttn:Button;
		
		public function PropsTool() 
		{
			
		}
		
		public static function remove():void 
		{
			PropsTool.allPresets = new String();
			ToolsUtils.removeFromParent(_zone);
			ToolsUtils.removeFromParent(_saveBttn);
			ToolsUtils.removeFromParent(_sizeText);
			App.self.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			App.self.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		public static function init():void 
		{
			//App.map.mTreasure.addChild();
			
			//_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseClick);
			PropsTool.allPresets = new String();
			App.self.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			App.self.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			drawBttn();
			drawText();
			addZone();
		}
		
		private static function drawBttn():void {
			ToolsUtils.removeFromParent(_saveBttn);
			
			_saveBttn = new Button( { caption:"Copy To clipboard", fontSize:24 } );
			//_saveBttn.onClick = wrk;
			App.self.addChild(_saveBttn);
			_saveBttn.x = 120;
			_saveBttn.y = 120;
			_saveBttn.addEventListener(MouseEvent.CLICK, wrk);
		}
		
		private static function setText():void 
		{
			if (_sizeText)
			{
				_sizeText.text = 'x: '+ x_size +' z: '+ z_size;
			}
		}
		private static function drawText():void {
			ToolsUtils.removeFromParent(_sizeText);
			
			_sizeText = Window.drawText('x: '+ x_size +' z: '+ z_size, {
				fontSize:17,
				color:0xfcf6e4,
				borderColor:0x5e3402,
				textAlign:"left"
			});
			App.self.addChild(_sizeText);
			
			_sizeText.x = 120;
			_sizeText.y = 160;
		}
		
		private static function onKeyDown(e:KeyboardEvent):void {
			//trace(e.keyCode);
			
			if (e.keyCode == 187 && _zone) //plus
			{ 
				x_size ++; 
				z_size ++;
				addZone();
				setText();
			} 
			
			if (e.keyCode == 189 && _zone) //minus
			{ 
				x_size --; 
				z_size --;
				addZone();
				setText();
			}
			
			if (e.keyCode == Keyboard.F8) 
			{
				PropsTool.remove()
			}
			
			if (e.keyCode == Keyboard.F3) 
			{
				drawBttn();
				addZone();
				setText();
			}
			
			if (e.keyCode == Keyboard.SPACE && _zone) 
			{
				wrk();
			}
			
			if (e.keyCode == Keyboard.LEFT && _zone)
			{
				z_coord++;
				addZone();
			}
			
			if (e.keyCode == Keyboard.RIGHT && _zone)
			{
				z_coord--;
				addZone();
			}
			
			if (e.keyCode == Keyboard.UP && _zone)
			{
				x_coord--;
				addZone();
			}
			
			if (e.keyCode == Keyboard.DOWN && _zone)
			{ 
				x_coord++;
				addZone();
			}
			
			if (e.keyCode == Keyboard.S && e.ctrlKey && allPresets.length > 0)
			{
				Saver.saveText(allPresets, 'allPresets');
			}
		}
		
		private static function addZone():void {
			ToolsUtils.removeFromParent(_zone);
			_zone = HighlightZone.zone(x_coord, z_coord, x_size/2, z_size/2, 0x00ff00, false);
			App.map.mTreasure.addChild(_zone);
			Cc.log('zone  x:' + x_size+', z:' + z_size);
		}
		
		private static function onKeyUp(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.CONTROL) {
				_isCtrl = false;
			}
		}
		
		private static function wrk(e:* = null):void
		{
			var newPresetObject:Object = new Object();
			newPresetObject['size'] = int(x_size);
			
			var result:Array = [];
			var props:Array = [];
			/*for each (var item:* in App.map.depths) 
			{
				if (!(item is Resource)) continue;
				if (item.coords.x >= x_coord - x_size && item.coords.x <= x_coord + x_size && 
					item.coords.z >= z_coord - z_size && item.coords.z <= z_coord + z_size) {
						props.push(item);
					}
			}*/
			for (var i:int = x_coord - x_size/2; i < x_coord + x_size/2; i++)
			{
				for (var j:int = z_coord - z_size/2; j < z_coord + z_size/2; j++)
				{
					var node:AStarNodeVO = App.map._aStarNodes[i][j];
					trace('x:'+i+' y:'+ j+ ' object '+ node.object + '!')
					if (node.object && node.object is Resource)
					{
						//if (node.object.coords.x >= i - node.object.cells/2 /*&& node.object.coords.x + node.object.cells < x_coord + x_size*/ &&
							//node.object.coords.z >= j /*&& node.object.coords.z + node.object.rows < z_coord + z_size*/){
						if (props.indexOf(node.object) == -1)
							props.push(node.object);
						//}
					}
				}
			}
			
			for each(var _unit:Resource in props) {
				result.push( {
					sid:_unit.sid,
					x:_unit.coords.x - (x_coord - x_size/2),// - (x_coord - x_size),
					z:_unit.coords.z - (z_coord - z_size/2),// - (z_coord - z_size),
					rotate:_unit.rotate
				})
			}
			newPresetObject['data'] = result;
			
			var json:String = JSON.stringify(newPresetObject);
			System.setClipboard(json);
			allPresets = allPresets.concat(json+'\n\n')
			trace(json);
		}
	}

}