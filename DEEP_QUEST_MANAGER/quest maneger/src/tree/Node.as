package tree 
{
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class Node extends LayerX
	{
		//public var weight:uint;
		public var mparent:uint;
		public var _mchildren:Array;
		private var _rBrather:uint;
		private var _id:uint;
		public var quest:Object;
		private var _mroot:uint;
		public var path:Array;
		private var _quests:Object = App.data.quests;
		public var backing:Bitmap;
		private var pCountSprite:Sprite;
		private var number:TextField;
		private var title:TextField;
		private var _plane:Sprite;
		public var settings:Object;
		public function Node(questID:uint = 0, rootID:uint = 0, _settings:Object = null) 
		{
			if ( !_settings )
				_settings = { };
			_settings['width'] = _settings.width || 120;
			_settings['height'] = _settings.height || 75;
			
			settings = _settings;
			
			this.quest = _quests[questID];
			_id = questID;
			//if (_id == 248) //жуткий костыль! АХТУНГ!!!
				//_rBrather = 258;
			init(rootID);
			_root = rootID;
			tip = function():Object
			{
				return {title: _id + ' ' + quest.title, text: quest['description'] + quest['description2']};
			}
		}
		public function get weight():int{
			if (path)
				//return path.length - 1;
				return path.indexOf(_mroot) ;
			return -1;
		}
		public function get empty ():Boolean{
			return (_id == 0);
		}
		public function get _root():uint{
			return _mroot;
		}
		public function set _root(index:uint):void{
			if (path.indexOf (index) != -1)
				_mroot = index;
			else
				_mroot = ID;
		}
		public function get ID ():uint{
			return _id;
		}
		public function get rightBrather ():uint{
			return _rBrather;
		}
		public function set rightBrather (index:uint):void{
			_rBrather = index;
		}
		public function get _clildren():Array{
			return _mchildren;
		}
		private function init (rootID:uint):void
		{
			path = new Array();
			_mchildren = new Array();
			var _ID:int = _id;
			for each ( var quest:Object in _quests)
			{
				if (App.roots.indexOf (quest.ID) == -1)
				{
					if ( quest.parent ==  _id)
					_mchildren.push(quest.ID);
				}
			}
			for ( var i:int = 0; i < App.questLenght; i ++ )
			{
				path.push (_ID);
				if ( App.roots.indexOf (_ID) != -1 )
					break;
				_ID = _quests[_ID].parent;
			}
			
			if (i == App.questLenght && !_mroot)
				trace ('Loop at link quest:   ' + _id);
			
			if ( _quests[_id].hasOwnProperty('parent') && _quests[_id].parent != 0 )
				mparent = _quests[_id].parent;
			else
				mparent = _id;
			
			_root = rootID;
		}
		
		private function drawBacking():void
		{
			/*_plane = new Sprite();
			_plane.graphics.beginFill(0x1f3a93, 1);
			
			//_plane.graphics.lineStyle(.5, 0xffffff, 0.8);
			_plane.graphics.moveTo(0, 0);

			_plane.graphics.lineTo( settings.width,  0 );// , x + 115	+ randC[0], y + 5   + randC[1]);
			_plane.graphics.lineTo( settings.width,  settings.height);//, x + 115	+ randC[2], y + 85  + randC[3]);
			_plane.graphics.lineTo(0  ,  settings.height);//, x + 5		+ randC[4], y + 85  + randC[5]);
			//_plane.graphics.lineTo(x + 5  , y + 5 );//, x + 5		+ randC[6], y + 5   + randC[7]);
			_plane.graphics.endFill();
			
			
			addChild(_plane);*/
			//var backing:Bitmap = UI.backing(100, 70, 30, "questTaskBackingTopMini");
			//addChildAt(backing,0);
		}
		public static var playersDrawed:Boolean = false;
		public function drawPlayers(donaters:Boolean = false):void
		{
			//if (pCountSprite && pCountSprite.parent)
				//pCountSprite.parent.removeChild(pCountSprite);
				
			//pCountSprite = new Sprite();
			if (App.data.quests.hasOwnProperty(quest.ID) )
			{
				var players:int = 0;
				if (App.data.quests[quest.ID].hasOwnProperty('addInfo'))
				{
					this.backing.filters = null;
					var ss:Number;
					if (donaters)
					{
						players = App.data.quests[quest.ID].addInfo.don_not_complete;
						ss = players / App.data['questsInfo']['maxPayers'];
						//this.alpha = .4 + ss;
						UI.colorize(this.backing, 0xFF0000, ss);
					}
					else{
						players = App.data.quests[quest.ID].addInfo.not_complete;
						ss = players / App.data['questsInfo']['maxNotPayers'];
						//this.alpha = .4 + ss;
						UI.colorize(this.backing, 0xFF0000, ss);
					}
				}else{
					UI.colorize(this.backing, 0x0000FF, 1);
				}
				if (players < 1)
					this.alpha = .4;
				
					
				if (number && number.parent)
					number.parent.removeChild(number);
					
				number = UI.drawText(String(players), {
					textAlign:		'center',
					fontSize:		30,
					width:			settings.width - 10,
					color:			0xffffff,
					borderColor:	0x34495E
				});
				number.x = backing.x + (backing.width - number.width) / 2;
				number.y = backing.y + (backing.height - number.height) / 2;
				//group.alpha = 0.8;
				addChild(number);
				//number.text = Striplayers;
				//var number:TextField = UI.drawText(players, {
					//textAlign:		'left',
					//fontSize:		30,
					//color:			0xffffff,
					//borderColor:	0x34495E
				//});
				//number.x = backing.x + (backing.width - number.width) / 2;
				//number.y = backing.y + (backing.height - number.height) / 2;
				//group.alpha = 0.8;
				
				//var back:Shape = new Shape();
				//back.graphics.beginFill(0xffffff, .8);
				//back.graphics.drawRoundRect(0, 0, number.width, number.height, 25);
				//back.graphics.endFill();
				//
				//pCountSprite.addChild(back);
				//pCountSprite.addChild(number);
				//
				//addChild(pCountSprite)
				//pCountSprite.x = backing.width - pCountSprite.width / 3;
			}
		}
		
		public function draw():void
		{
			//if ( title )
				//return;
			//backing = UI.backing2(120, 100,40,'questsSmallBackingTopPiece','questsSmallBackingBottomPiece');
			//var backing:Bitmap = UI.backing(240,200,40,"tradingPostBackingMain");
			//addChildAt(backing,0);
			//drawBacking();
				
			if (backing && backing.parent)
				backing.parent.removeChild(backing);
			backing = new Bitmap();	
			backing = UI.backing(120, 80, 30, "questTaskBackingTopMini");
			addChildAt(backing, 0);
			addFilters();
			
			drawNumber();
			
			//title = UI.drawText(quest.title, {
				//textAlign:		'center',
				//fontSize:		16,
				//color:			0xffffff,
				//borderColor:	0x34495E,
				//width:			120,//3 * backing.width/4,
				//multiline:		true,
				//wrap:			true
			//});
			//title.x = 5;//(backing.width - title.width) / 2;
			//title.y = number.textHeight;
			//if ( title.textHeight + number.textHeight > 100)
				//title.height = 100 - number.textHeight; 
			//addChild(title);
		}
		
		private function addFilters():void 
		{
			if (quest.update == '')
				return;
			//backing.filters = [new GlowFilter(0xffff00, .6, 15, 15, 2, 1, true)];
			if (!backing.filters)
				backing.filters = [];
			var tempFilters:Array = backing.filters;
			tempFilters.push(new GlowFilter(UI.getColorUpdate(quest.update), .7, 15, 15, 2, 1, true));
			backing.filters = tempFilters;
			
		}
		
		public function drawNumber(e:MouseEvent = null):void
		{
			this.alpha = 1;
			if (number && number.parent)
				number.parent.removeChild(number);
			if (!backing)
				backing = new Bitmap();
			Node.playersDrawed = false;
			number = UI.drawText(String(_id), {
				textAlign:		'center',
				fontSize:		60,
				width:			settings.width - 10,
				color:			0xffffff,
				borderColor:	0x34495E
			});
			number.x = backing.x + (backing.width - number.width) / 2;
			number.y = backing.y + (backing.height - number.height) / 2;
			addChild(number);
		}
		public function onClick(e:MouseEvent = null):void
		{
			
			if (App.treeManeger.mission && App.treeManeger.mission.parent)
				App.self.removeChild(App.treeManeger.mission);
				
			if (App.treeManeger.dialog && App.treeManeger.dialog.parent)
				App.self.removeChild(App.treeManeger.dialog);
				
			if (App.treeManeger.daylic && App.treeManeger.daylic.parent)
				App.self.removeChild(App.treeManeger.daylic);
				
			if (quest.type == 0)
			{
				App.treeManeger.mission = new Missions(ID);
				
				App.self.addChild(App.treeManeger.mission);
				//App.treeManeger.mission.x = e.stageX + 20;// Node(_under.parent).x;
				//App.treeManeger.mission.y = e.stageY - (App.treeManeger.mission.height) / 2;// Node(_under.parent).y;
				App.treeManeger.mission.visible = true;
			}
			else
			{
				App.treeManeger.dialog = new Dialog(ID);
				App.self.addChild(App.treeManeger.dialog);
				//App.treeManeger.dialog.x = e.stageX + 20;// Node(_under.parent).x;
				//App.treeManeger.dialog.y = e.stageY - (App.treeManeger.dialog.height) / 2;// Node(_under.parent).y;
				App.treeManeger.dialog.visible = true;
			}
			
			if (App.complete)
			{
				if (App.userID && App.social)
					completeEvent();
			}
		}
		
		private function completeEvent():void 
		{
			var scored:Object = {};
			var mids:Object = {};
			for (var i:int = 1; i <= Numbers.countProps(_quests[_id].missions); i++)
			{
				mids[i] = {1:1}
			}
			scored[_id] = mids;
			
			Post.send( {
				ctr		:'quest',
				act		:'score',
				uID		:App.userID,
				wID		:4,
				score	:JSON.stringify(scored),
				f		:1
			},function(error:*, data:*, params:*):void {
				if (error) {
					return;
				}
				App.userPanel.onGoEvent(null);
			});
		
		}
		
		public function clear ():void
		{
			//if (parent)
				//parent.removeChild(this);
			////removeChild(backing);
			////removeChild(title);
			//removeChild(number);
			////backing = null;
			////title = null;
			//number = null;
			//removeChild(_plane);
			////removeChild(group);
			//_plane = null;
			//group = null;
			x = 0;
			y = 0;
		}
	}

}