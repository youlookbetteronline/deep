package tree 
{
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	/**
	 * ...
	 * @author ...
	 */
	public class DropDownListUpdates extends Sprite
	{
		private var _defaultTarget:uint = 0;
		private var _list:Vector.<LayerX> = new Vector.<LayerX>;
		private var _hide:Boolean = true;
		private var _settings:Object = { };
		private var cont:Sprite ;
		public var maskaHeight:uint = 100;
		private var tween:TweenLite;
		private var content:Array;
		private var maska:Shape;
		public var slider:Slider;
		public function DropDownListUpdates()
		{	
			//if ( settings )
				//_settings = settings;
			createContente();
			draw();
		}
		protected function createContente():void
		{
			content = [];
			for (var updateKey:String in App.data.updates)
			{
				var update:Object = App.data.updates[updateKey];
				if ( !update.quests || update.quests == "")
					update['quests'] = App.treeManeger.currentTree.findUpperQid(updateKey);
				update['update'] = updateKey;
				content.push(update);
				content.sortOn('order', Array.NUMERIC).reverse();
			}
			trace();
		}
		public function draw ():void 
		{
			cont  = new Sprite();
			cont.y = 20;
			var count:int = 0;
			var itemsCont:Sprite = new Sprite ();
			var cntrl:Boolean = false;
			var rootItem:DropDownItem = new DropDownItem( { title:"Updates", dark:false, rootItem:true },this );
			//var 
			addChild(rootItem);
			for each (var upadte:Object in content )
			{
				upadte.dark = cntrl;
				cntrl = !cntrl;
				var item:DropDownItem = new DropDownItem(upadte,this);
				item.y = 20 * count;
				count ++;
				itemsCont.addChild(item);
			}
			
			maskaHeight = count * 20;
			if (maskaHeight > 300)
				maskaHeight = 300;
				
			slider = new Slider(itemsCont, maskaHeight);
			
			cont.addChild(itemsCont);
			maska = new Shape();
			maska.graphics.beginFill(0x777777, 1);
			maska.graphics.lineTo( 250,  0 );// , x + 115	+ randC[0], y + 5   + randC[1]);
			maska.graphics.lineTo( 250,  maskaHeight);//, x + 115	+ randC[2], y + 85  + randC[3]);
			maska.graphics.lineTo( 0  ,  maskaHeight);//, x + 5		+ randC[4], y + 85  + randC[5]);
			maska.graphics.endFill();
			cont.addChild(maska);
			cont.addChild(slider);
			cont.mask = maska;
			addChild(cont);
			closure();
		}
		public function slideY(e:MouseEvent):void
		{
			slider.slideY(e);
		}
		public function hide():void
		{
			if (_hide)
			{	
				App.treeManeger.ddlu = this;
				disclosure();
				if (App.treeManeger.comboBox)
				{
					App.treeManeger.comboBox.hide();
					App.treeManeger.comboBox = null
					
				}
				
			}
			else
			{
				
				closure();
				App.treeManeger.ddlu = null;
			}
			_hide = !_hide;
		}
		private function disclosure():void
		{
			tween = TweenLite.to(maska, 0.8, {height: maskaHeight, onComplete:function():void {
				tween = null;
			}});
		}
		private function closure():void
		{
			tween = TweenLite.to(maska, 0.8, { height: 0, onComplete:function():void {
				tween = null;
			}});
		}
	}

}
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import tree.DropDownListUpdates;
import tree.LayerX;
internal class Slider extends Sprite
{
	private var _cont:Sprite
	private var position:Point;
	private var H:int = 0;
	private var subslider:Sprite;
	public function Slider( cont:Sprite, h:uint)
	{
		H = h;
		_cont = cont;
		var backing:Sprite = new Sprite();
		backing.graphics.moveTo(0, 0);
		backing.graphics.beginFill(0xECECEC, 1);
		backing.graphics.lineTo(20,  0);// , x + 115	+ randC[0], y + 5   + randC[1]);
		backing.graphics.lineTo(20, H);//, x + 115	+ randC[2], y + 85  + randC[3]);
		backing.graphics.lineTo(0,  H);//, x + 5		+ randC[4], y + 85  + randC[5]);
		backing.graphics.endFill();
		backing.x = cont.width - 20;
		
		subslider = new Sprite();
		subslider.graphics.moveTo(0, 0);
		subslider.graphics.beginFill(0x6C7A89, 1);
		subslider.graphics.lineTo(20,  0);// , x + 115	+ randC[0], y + 5   + randC[1]);
		subslider.graphics.lineTo(20, 20);//, x + 115	+ randC[2], y + 85  + randC[3]);
		subslider.graphics.lineTo(0,  20);//, x + 5		+ randC[4], y + 85  + randC[5]);
		subslider.graphics.endFill();
		subslider.y = 0;
		subslider.x = cont.width - 20;
		addChild(backing);
		addChild(subslider);
	}
	public function slideY(e:MouseEvent):void
	{
		if (App.treeManeger.deltaY - parent.parent.y > H - 20  )
		{
			
			subslider.y = H - 20;
			_cont.y = -_cont.height + H;
		}
		else if ( App.treeManeger.deltaY - parent.parent.y < 0 )
		{
			subslider.y = 0;
			_cont.y = 0;
		}
		else {
			subslider.y =   App.treeManeger.deltaY - parent.parent.y - 5;
			_cont.y = - ((subslider.y + subslider.height * 0.5) / H) * _cont.height;
			if ( _cont.y < H - _cont.height )
				_cont.y  = H - _cont.height;
			else if ( _cont.y > 0 )
				_cont.y = 0;
		}
	
	}
}
internal class DropDownItem extends LayerX
{
	private var title:String
	private var id:String
	private var _plane:Sprite;
	private var dark:Boolean = false;
	private var _rootItem:Boolean = false;
	private var _ddl:DropDownListUpdates;
	public function DropDownItem(update:Object, ddl:DropDownListUpdates)
	{
		_ddl = ddl
		title = update.title;
		dark = update.dark;
		id = update.update
		if ( update.rootItem )
			_rootItem = update.rootItem;
		drawBacking();
		var updateTitle:TextField = UI.drawText(title, {
			textAlign:		'left',
			fontSize:		17,
			width:			300,
				//color:			0xe0121b,
			color:			0x563D28,
			borderColor:	0x563D28,
			borderSize:		0
		});
		if (updateTitle.length > 20)
			updateTitle.text = updateTitle.text.slice(0, 20);
		updateTitle.y = -2;
		addChild(updateTitle);
		addEventListener(MouseEvent.CLICK, onClick);
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(UI.getColorUpdate(id), 1);
		shape.graphics.drawRoundRect(0, 0, 26, 16, 5, 5);
		shape.graphics.endFill();
		shape.x = _plane.x + _plane.width - shape.width - 27;
		shape.y = _plane.y + (_plane.height - shape.height) / 2;
		addChild(shape)
		
	}
	private function drawBacking():void
		{
			_plane = new Sprite();
			if ( !dark )
				_plane.graphics.beginFill(0xF2F1EF, 1);
			else
				_plane.graphics.beginFill(0xBFBFBF, 1);
			_plane.graphics.moveTo(0, 0);
			_plane.graphics.lineTo(230,  0);// , x + 115	+ randC[0], y + 5   + randC[1]);
			_plane.graphics.lineTo(230, 20);//, x + 115	+ randC[2], y + 85  + randC[3]);
			_plane.graphics.lineTo(0,  20);//, x + 5		+ randC[4], y + 85  + randC[5]);
			_plane.graphics.endFill();
			
			
			addChild(_plane);
		}
	private function onClick(e:MouseEvent):void
	{
		// showGlowing();
		startBlink();
		if ( _rootItem)
		{
			_ddl.hide();
			return;
		}
		var needQuest:int;
		var needUpd:String;
		var questInUpdate:Vector.<int> = new Vector.<int>
		for each(var upd:* in App.data.updates)
		{
			if (title == upd.title)
			{
				needUpd = upd.update;
				break;
			}
		}
		for each (var _quest:* in App.data.quests)
		{
			if (_quest.update == needUpd)
				questInUpdate.push(_quest.ID)
		}
		questInUpdate.sort(Array.NUMERIC);
		if (questInUpdate.length > 0)
			App.searchPanel.search(App.data.quests[questInUpdate[0]].title);
		else
			App.searchPanel.search(title);
	}
	public function dispose ():void
	{
		removeEventListener(MouseEvent.CLICK, onClick);
	}
}
