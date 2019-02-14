package tree 
{
	import adobe.utils.ProductManager;
	import core.Numbers;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.net.NetStreamMulticastInfo;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class Tree extends Sprite
	{
		private static var quests:Object = App.data.quests;
		
		public var struct:Object;
		public var _nodesCont:Sprite;
		
		private var _bias:int;
		private var lineContainer:Sprite;
		private var nodes:Array;
		private var mroot:uint;
		
		public static function get roots():Array{
			var _roots:Array = new Array();
			for each (var quest:Object in quests){
				if (!quests[quest.ID].hasOwnProperty('parent') || quests[quest.ID].parent == 0 || !quests.hasOwnProperty(quests[quest.ID].parent[0]) || quest.ID == 0 )
					_roots.push (quest.ID);
			}
			return _roots;
		}
		public function set _root(rootID:uint):void{
			mroot = rootID;
			for each (var node:Node in nodes)
				node._root = rootID;
			setStruct();
		}
		public function get _root():uint{
			return mroot;
		}
		public function get getFirstCoordsAndGlow():Point{
			var re:Point = new Point (0,0);
			for (var level:String in struct){
				var testNode:Node = getFirst(int (level));
				re.x = testNode.x 
				re.y = testNode.y;
				testNode.showGlowing();
				break;
			}
			return re;
		}
		public function get lastNodes():Array{
			var qstArray:Array = new Array();
			for each(var _nod:* in nodes){
				if (_nod._mchildren.length == 0){
					qstArray.push(_nod.quest.ID)
				}
			}
			return qstArray;
		}
		public function Tree(rootID:uint) 
		{
			nodes = new Array();
			for each (var quest:Object in quests)
			{
				var node:Node = new Node (quest.ID, rootID);
				//if (quest.ID == 71)
					//trace();
				if ( node.weight > 0 )
					nodes.push(node);
				else 
					node = null;
			}
			setStruct();
		}
		public function setStruct():void
		{
			struct = { };
			for each(var node:Node in nodes)
			{
				if (!struct.hasOwnProperty(node.weight))
					struct [node.weight] = { };
				struct[node.weight][node.ID] = node;
				//if (node.ID == 71)
					//trace();
			}
			createRightBr();
		}
		public function createRightBr():void
		{	
			var lust:Node;
			for (var level:Object in struct)
			{
				if (level == 15)
					trace();
				if ( level == 1)
				{
					var prev_item:Node = null;
					for each(var item:Node in struct[level])
					{
						if (prev_item /*&& prev_item.mparent != item.mparent*/)
							prev_item.rightBrather = item.ID;
						
						prev_item = item;
					}
					continue;
				}
				var length:int = App.numOfProps(struct[level]);
				var firstWithSon:* = getFirstWithSon(int (level) - 1);
				if ( !firstWithSon)
					continue;
				item = struct [level] [firstWithSon._children[0]];
				//item = Numbers.getProp(struct [level], 1).val;// [firstWithSon._children[0]];
				//for ( item in struct [level - 1] )
				if (_bias < length)
					_bias = length;
				
				for ( var i:int = 0; i < length; i ++ )
				{
					if (!item)
						break;
					if (lust)
						lust.rightBrather = item.ID;
					lust = item;
					item = getNextBrother(item);
					//item = Numbers.getProp(struct [level], i).val;
				}
				lust = null;
				
				if (level == 16)
					trace();
			}
		}
		public function setBlendMode(value:Boolean):void
		{
			for each (var node:Node in nodes)
			if (value)
				node.blendMode = BlendMode.INVERT;
			else
				node.blendMode = BlendMode.NORMAL;

		}
		
		public function refreshQuests():void
		{
			for each (var node:Node in nodes)
			{
				node.drawNumber();
				node.backing.filters = null;
			}
			setChecked();
		}
		public function playersOnQuests(_donators:Boolean = false):void
		{
			if (!App.data.hasOwnProperty('questsInfo'))
				return;
			for each (var node:Node in nodes)
			{
				node.backing.filters = null;
				node.drawPlayers(_donators); 
			}
		}
		
		public function setChecked():void
		{
			var glowingColor:uint = 0x00FF00;
			for each (var node:Node in nodes)
			{
				node.drawNumber();
				if (User.quests.hasOwnProperty(node.quest.ID))
				{
					if (User.quests[node.quest.ID].finished == 0)
						glowingColor = 0x0f00f0;
					else
						glowingColor = 0x00FF00;
					node.backing.filters = [new GlowFilter(glowingColor, .4, 4, 4, 10)]; 
				}else
					node.backing.filters = null;
				//node.blendMode = BlendMode.NORMAL;
			}
		}
		
		private function getNextBrother (node:Node):Node
		{
			if (node.weight == 15)
				trace();
			var _parent:Node = struct[node.weight - 1] [node.mparent];
			var pArr:Array = _parent._children;
			var index:int = pArr.indexOf(node.ID);
			if ( index < pArr.length - 1) // если у отца есть еще сыновья возвращаем следующего
			{
				return struct[node.weight][pArr[index + 1]];
			}
			else 
			{
				var length:int = App.numOfProps(struct[node.weight]);
				for ( var i:int = 0; i < length; i ++ )
				{
					if (_parent.rightBrather == 0)
						return null;
					
						//находим правого брата у отца, который имеет детей. 
						//для увеличения читабельности можно использовать рекусивный вызов функции
					var chlids:Array = struct [_parent.weight] [_parent.rightBrather]._children;
					if ( chlids.length > 0 )
						return struct[node.weight][chlids[0]];
					_parent = struct[_parent.weight][_parent.rightBrather];
				}
			}
			return null;
		}
		public function findUpperQid(update:String):int
		{
			for each (var level:Object in struct)
			{
				for each (var node:Node in level)
				{
					if (node.quest.update == update)
						return node.ID;
				}
			}
			return -1;
		}
		private function getFirst(level:int):Node
		{
			if ( !struct.hasOwnProperty(level) )
				return null;
			//var node:Node = Numbers.getProp(struct[level], 0).val;
			for each(var node:Node in struct [level])
			{
				var _item:Node = null;
				for each( var item:Node in struct [level])
				{	
					if ( node.ID == item.rightBrather )
					{
						_item = item;
					}
				}
				if (!_item)
					return node;
			}
			return null;
		}
		private function getFirstWithSon (level:int):Node
		{
			var node:Node = getFirst(level);

			//var length:int = App.numOfProps(struct[level]);
			//for ( var i:int = 0; i < length; i ++ )
			//{
				//if (!node)
					//return null;
				//if ( node._children.length > 0)
					//return node;
				//node = struct[level][node.rightBrather];
			//}
			while (node)
			{
				if (node._children.length > 1)
					trace();
				if (node._children.length > 0)
					return node;
				node = struct[level][node.rightBrather];
			}
			return null;
		}
		public function draw ():void
		{
			var _dx:int = 0;
			
			lineContainer = new Sprite();
			lineContainer.graphics.lineStyle(10, 0xFFFFFF, 1);
			addChild(lineContainer);
			
			_nodesCont = new Sprite();
			addChild(_nodesCont);
			//var _bias:int = 5;
			for (var level:Object in struct)
			{
				for each(var _node:Node in struct[level]){
					if(!_node.parent){
						_node.draw();
						_nodesCont.addChild(_node);
						_node.y = (uint(level) - 1) * (_node.settings.height + 50);
					}
					if (!struct[level + 1])
						break;
					_bias = 0;
					for each(var _cNode:Node in struct[level+1]){
						_bias += _cNode._children.length;
					}
					//if(_bias == 0)
						//_bias = 1;
					for each(_cNode in struct[level+1]){
						if (_cNode.parents.indexOf(_node.ID) != -1){
							_cNode.draw();
							_nodesCont.addChild(_cNode);
							_cNode.x = _node.x + (_node.width/2) * _bias - ((_node._children.length * _node.width) / 2) * _bias + (_node._children.indexOf(_cNode.ID) * _node.width) * _bias;
							_cNode.y = (uint(level)) * (_cNode.settings.height + 50);
							if (_cNode.x < _dx)
								_dx = _cNode.x;
							trace(_cNode.ID);
							trace();
						}
					}
				}
				
				var line:Shape = new Shape();
				line.graphics.beginFill(0xff0000);
				line.graphics.drawRect(-150, 0, 4000, 2);
				line.graphics.endFill();
				addChild(line);
				line.y = (uint(level)) * (75 + 50) - 20;
				var levelNumber:TextField = UI.drawText(String(level), {
					textAlign:		'center',
					fontSize:		40,
					width:			60,
					color:			0xff0000,
					borderColor:	0xffffff
				});
				levelNumber.x = -150;
				levelNumber.y = line.y - levelNumber.textHeight - 5;
				addChild(levelNumber);
			}
			_nodesCont.x = -_dx;
			lineContainer.x = _nodesCont.x;
			drawAllLinks();
		}
		
		public function drawOld ():void
		{
			lineContainer = new Sprite();
			lineContainer.graphics.lineStyle(10, 0xFFFFFF, 1);
			addChild(lineContainer);
			
			for (var level:Object in struct)
			{
				if (level == 15)
					trace();
				var node:Node = getFirst(int(level));
				var count:int = 0;
				//var length:int = App.numOfProps(struct[level]);
				//for ( var i:int = 0; i < length; i ++ )
				//{
					
				while (node)
				{
					if (node.quest.order == 259)
						trace();
						//break;
					if (node._children[0] == 259)
						trace();
					
					if (node.ID == 71)
						trace();
					node.draw();
					addChild(node);
					
					var line:Shape = new Shape();
					line.graphics.beginFill(0xff0000);
					line.graphics.drawRect(-500, 0, 3000, 2);
					line.graphics.endFill();
					addChild(line);
					line.y = (uint(level)) * (node.settings.height + 50) - 20;
					var levelNumber:TextField = UI.drawText(String(level), {
						textAlign:		'center',
						fontSize:		40,
						width:			60,
						color:			0xff0000,
						borderColor:	0xffffff
					});
					levelNumber.x = -500;
					levelNumber.y = line.y - levelNumber.textHeight - 5;
					addChild(levelNumber);
					
					node.y = (uint(level) - 1) * (node.settings.height + 50);
					if ( uint(level) - 1 )
						node.x += struct[int (level) - 1][node.mparent].x + ( (node.settings.width+10) * struct[node.weight - 1][node.mparent]._children.indexOf(node.ID) ) + 0;
					else
						//node.x = i * ( 120/*node.width*/);
						node.x = count * (node.settings.width/*node.width*/);
					align(node);
					node = struct[level][node.rightBrather];
					count++;
				}
			}
			alignParent();
			drawAllLinks();
		}
		private function alignParent ():void
		{
			for (var level:Object in struct)
			{
				var node:Node = getFirst(int (level));
				var length:int = App.numOfProps(struct[level]);
				for ( var i:int = 0; i < length; i ++ )
				{
					if (!node)
						break;
					if ( node._children.length > 1 )
					{
						node.x += (struct[node.weight + 1][node._children[node._children.length - 1]].x - struct[node.weight + 1][node._children[0]].x) / 2;
					}
					if (struct.hasOwnProperty (node.weight -1) && struct[node.weight - 1].hasOwnProperty (node.mparent))
						var _parent:Node = struct[node.weight - 1][node.mparent]
					while (_parent && _parent.mparent != 0 && _parent.x != node.x)
					{
						if (_parent._children.length == 1)
							_parent.x = node.x;
						else 
							break;
						if (struct.hasOwnProperty (_parent.weight -1) && struct[_parent.weight - 1].hasOwnProperty (_parent.mparent))
							_parent = struct[_parent.weight - 1][_parent.mparent];
						else
							break;
					}
					node = struct[level][node.rightBrather];
				}
			}
		}
		public function getCoordAndGlow(find:String):Point
		{
			var re:Point = new Point(0, 0);
			if (!isNaN(Number(find)))
			{
				for (var level:Object in struct)
				{
					var node:Node = getFirst(int (level));
					var length:int = App.numOfProps(struct[level]);
					for ( var i:int = 0; i < length; i ++ )
					{
						
						if (!node)
							break;
						if ( node.ID ==  int (find))
						{
							re.x = node.x;
							re.y = node.y;
							node.showGlowing();
						}
						node = struct[level][node.rightBrather];
					}
				}
			}
			else
			{
				if ( find.length == 0)
					return re;
				for (level in struct)
				{
					node = getFirst(int (level));
					length = App.numOfProps(struct[level]);
					for ( i = 0; i < length; i ++ )
					{
						
						if (!node)
							break;
						if ( node.quest.title.search (find) != -1)
						{
							re.x = node.x;
							re.y = node.y;
							node.showGlowing();
							return re;
						}
						node = struct[level][node.rightBrather];
					}
				}
				var update:String = '';
				for each( var ins:Object in App.data.updates )
				{
					if ( ins.title.search (find) != -1 )
					{
						return getCoordAndGlow(ins.quests);
					}
				}
			}
			if (node)
				node.showGlowing();
			return re;
		}
		private function drawAllLinks ():void
		{
			for (var level:Object in struct){
				for each(var _node:Node in struct[level]){
					drawLinks (_node);
					//if(!_node.parent){
					/*	_node.draw();
						addChild(_node);
						_node.y = (uint(level) - 1) * (_node.settings.height + 50);
					}
					if (!struct[level + 1])
						break;
					for each(var _cNode:Node in struct[level+1]){
						if (_cNode.parents.indexOf(_node.ID) != -1){
							_cNode.draw();
							addChild(_cNode);
							_cNode.x = _node.x + (_node.width/2) * 3 - ((_node._children.length * _node.width) / 2) * 3 + (_node._children.indexOf(_cNode.ID) * _node.width) * 3;
							_cNode.y = (uint(level)) * (_cNode.settings.height + 50);
							trace(_cNode.ID);
							trace();
						}
					}*/
				}
			}
			/*return;
			for (var level:Object in struct)
			{
				var node:Node = getFirst(int (level));
				var length:int = App.numOfProps(struct[level]);
				for ( var i:int = 0; i < length; i ++ )
				{
					
					if (!node)
						break;
					drawLinks (node);
					node = struct[level][node.rightBrather];
				}
			}*/
		}
		private function drawLinks (node:Node):void
		{
			if (node.ID == 72)
				trace();
			if (node.ID == 73)
				trace();
			if (node.parents.length > 1)
				trace();
			if ( node.weight <= 1 ) // приходят пустые ноды надо проверить
				return;
			//var line:Shape = new Shape(); 
			 
			// red triangle, starting at point 0, 0 
			var parent:Node = struct[node.weight - 1][node.mparent];
			lineContainer.graphics.moveTo(parent.x + parent.settings.width * 0.5, parent.y + parent.settings.height); 
			lineContainer.graphics.cubicCurveTo(node.x + node.settings.width * 0.5, node.y - 55, node.x + node.settings.width * 0.5, node.y - 15, node.x + node.settings.width * 0.5, node.y);
			
			//addChild ( line );

		}
		private function align(node:Node):void
		{
			var test:Node = node;
			var shift:int = node._children.length - 1;

			if ( struct.hasOwnProperty (node.weight -1) && struct[node.weight - 1].hasOwnProperty (node.mparent) )
			{
				if (struct[node.weight - 1][node.mparent]._children.indexOf(node.ID) == struct[node.weight - 1][node.mparent]._children.length - 1  && shift <= 0)
					shift = struct[node.weight - 1][node.mparent]._children.length - 1;
				node = struct[node.weight - 1][node.mparent];
			}
			else
				node = null;
			
			if ( shift < 1)
				return;
			while ( node && node.mparent != 0 )
			{
				var rightBrather:Node = null;
				if (node.rightBrather != 0 )
					rightBrather = struct[node.weight][node.rightBrather];
				while (rightBrather)
				{
					//if (rightBrather.ID == 788)
						//trace(node.ID + '	' + shift + '	' + test.ID);
					rightBrather.x += node.settings.width * shift;
					if (rightBrather.rightBrather != 0)
						rightBrather = struct[node.weight][rightBrather.rightBrather];
					else
						rightBrather = null;
				}
				if ( struct.hasOwnProperty (node.weight -1) && struct[node.weight - 1].hasOwnProperty (node.mparent) )
					node = struct[node.weight - 1][node.mparent];
				else
					node = null;
			}

		}
	}

}