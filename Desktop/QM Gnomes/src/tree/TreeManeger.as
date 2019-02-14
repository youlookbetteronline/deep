package tree 
{
	import adobe.utils.CustomActions;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author ...
	 */
	public class TreeManeger 
	{
		public var deltaY:int = 0;
		public var mission:Missions;
		public var daylic:Daylics;
		public var dialog:Dialog;
		public var startDrag:Boolean = false;
		
		private var _currentTree:Tree;
		private var deltaX:int = 0;
		private var blendModeFlag:Boolean = false;
		private var under:Array;
		private var backing:Bitmap;
		private var tipFlag:Boolean = false;
		private var _isItinted:Boolean = false;
		private var tip:Tips = new Tips();
		public function get currentTree():Tree{
			if ( !_currentTree ) _currentTree = new Tree(App.startQest);
			return _currentTree;
		}
		public function TreeManeger(){}
		public function show(id:int = 0):void
		{
			setCurrentTree(id);
			trace(new Date().time / 1000);
			currentTree.draw();
			_isItinted = true;
			App.self.addChild(currentTree);
			showFirst();
			App.self.addChild(tip);
		}
		
		public function setCurrentTree(id:int = 0):void
		{
			if (!id)
				id = App.startQest;
			if (!_currentTree)
				_currentTree = new Tree(App.startQest);
			_currentTree._root = id;
		}
		public function showFirst():void
		{
			var point:Object = currentTree.getFirstCoordsAndGlow;
			currentTree.x = -currentTree._nodesCont.x -point.x*currentTree.scaleX + App.self.stage.stageWidth / 2;
			currentTree.y = 0;
		}
		public function onMouseWheel(e:MouseEvent):void
		{
			var perCoord:Point = new Point ( App.self.stage.stageWidth,  App.self.stage.stageHeight);
			if (e.delta < 0){
				if (currentTree.scaleY > 0.4){
					if (!e.ctrlKey)
						saveCoord(- 0.1);
					currentTree.scaleX = currentTree.scaleY = currentTree.scaleY - 0.1;
				}
			}
			else
			{
				if (currentTree.scaleY < 0.9)
				{
					if (!e.ctrlKey)
						saveCoord(0.1);
					currentTree.scaleX = currentTree.scaleY = currentTree.scaleY + 0.1;
				}
			}
			if (e.ctrlKey)
				showFirst();
		}
		public function clearWindow():void
		{
			//if (daylic)
				//daylic.visible = false;
			if (dialog)
				dialog.visible = false;
			if (mission)
				mission.visible = false;
		}
		public function saveCoord(scaleParam:Number = 0):void
		{
			if (scaleParam > 0){
				currentTree.x += currentTree.x * Math.abs(scaleParam);
				currentTree.y += currentTree.y * Math.abs(scaleParam);
				//currentTree.x = Math.ceil(currentTree.x * currentTree.scaleX);
				//currentTree.y = Math.ceil(currentTree.y * currentTree.scaleY);
			}
			else{
				currentTree.x -= currentTree.x * Math.abs(scaleParam);
				currentTree.y -= currentTree.y * Math.abs(scaleParam);
			}
			if (App.self.navigator)
				App.self.navigator.drawTree();
		}

		public function onMouseMove(e:MouseEvent):void 
		{
			if ((!startDrag && (e.target is Navigator || (e.target.parent && e.target.parent is Navigator))) || App.self.navigator.isSDrugging)
				return;
			if (e.buttonDown == true )
			{
				
				if (startDrag)
				{
					if (daylic)
					{
						daylic.slideY(e);
						deltaX = e.stageX;
						deltaY = e.stageY;
					}
					
					App.ddl.slideY(e);
					deltaX = e.stageX;
					deltaY = e.stageY;
					return;
				}
				var newX:Number = currentTree.x + e.stageX - deltaX;
				var newY:Number = currentTree.y + e.stageY - deltaY;
				if ( newX > 500 )
					currentTree.x = 500;
				else if (App.self.stage.stageWidth  < newX + currentTree.width + 500)
					currentTree.x += e.stageX - deltaX;
				
				if ( newY > 500 )	
					currentTree.y = 500;
				else if (App.self.stage.stageHeight  < newY + currentTree.height + 500)
					currentTree.y += e.stageY - deltaY;
				deltaX = e.stageX;
				deltaY = e.stageY;
				if (App.self.navigator)
					App.self.navigator.redrawUp();
			}
			else
			{
				var touched:Boolean = false;
				under = App.self.getObjectsUnderPoint(new Point(e.stageX, e.stageY));
				
				tipFlag = false;
				for each(var _under:Object in under)
				{
					if (_under.parent is Daylics)
					{
						tip.hide();
						break;
					}
					if (/*(_under.parent) is Node ||*/ (_under.parent) is LayerX)
					{
						tip.relocate();
						if (tip)
							App.self.removeChild(tip);
						tip.show(_under.parent as DisplayObject);
						App.self.addChild(tip);
						tipFlag = true;
					}
				}
				if ( !tipFlag )
					tip.hide();
			}
		}
	
		public function onQuestsChange():void
		{
			currentTree.setChecked();
		}
		public function onGroup(ID:int/*,mparent:int*/):void
		{
			clearWindow();
			if (ID != currentTree._root /*&& mparent != currentTree._root*/ )
				show(ID);
			else
				show(App.startQest);
		}
		public function onMouseUp(e:MouseEvent):Boolean 
		{
			//var touched:Boolean = false;
			under =  App.self.getObjectsUnderPoint(new Point(e.stageX, e.stageY));
			var clickedObj:*;
			for each(var _under:Object in under)
			{
				
				/*if ((_under.parent.parent) is ComboBox)
				{
					clickedObj = _under.parent.parent;
					continue;
				}
				
				if ((_under.parent) is UserPanel)
				{
					clickedObj = _under.parent;
					continue;
				}*/
				if (!((_under.parent) is Node)){
					clickedObj = null;
					continue;
				}
				
				if ((_under.parent) is Node)
				{
					clickedObj = _under.parent;
					//return true;
				}
			}
			
			if ((clickedObj) is Node)
			{
				clickedObj.onClick(e);
				return true;
			}/*else{
				clickedObj.click();
			}*/
			
			return false;
		}
		
		public function onMouseDown(e:MouseEvent):void 
		{
			deltaX = e.stageX /** currentTree.scaleX*/;
			deltaY = e.stageY /** currentTree.scaleY*/;
		}
		public function onKeyDown(e:KeyboardEvent):void 
		{
			//
			//if (e.keyCode == Keyboard.A /*&& e.ctrlKey */) {
				////if (currentTree.x <= -50) 
					//currentTree.x += 100;
			//}
			//if (e.keyCode == Keyboard.D /*&& e.ctrlKey*/ ) {
				//currentTree.x -= 100;
			//}
			if (e.keyCode == Keyboard.S) {
				currentTree.setBlendMode(blendModeFlag);
				blendModeFlag = !blendModeFlag;
				
			}
			//if (e.ctrlKey)
			//{
			if ( e.ctrlKey && e.keyCode == 189 )
			{
				currentTree.scaleX = currentTree.scaleY = currentTree.scaleY - 0.1;
				showFirst();
			}
			if (e.ctrlKey &&  e.keyCode == 187 )
			{
				currentTree.scaleX = currentTree.scaleY = currentTree.scaleY + 0.1;
				showFirst();
			}
		}
	}
}