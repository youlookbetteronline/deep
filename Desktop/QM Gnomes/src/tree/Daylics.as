package tree 
{
	import core.Load;
	import core.Numbers;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class Daylics extends Sprite
	{
		private var quest:Object;
		private var craftz:Object = new Object();
		private var bonusList:BonusList;
		private var backSprite:Sprite = new Sprite();
		private var contentSprite:Sprite = new Sprite();
		private var bonusBackgroutnd:Bitmap;
		private var stageDay:int;
		private var slider:Slider;
		public var bgWidth:int = 600;
		public var bgHeight:int = 650;
		public function Daylics(settings:Object = null) 
		{
			//stageDay = qID;
			//quest = User.daylics.quests[qID];
			var lastY:int = 0;
			var lastX:int = 0;
			/*for (var mID:String in  quest )
			{
				var mission:DaylicItem  = new DaylicItem (qID, int(mID));
				addChild(mission);
				mission.y = lastY;
				mission.x = (bgWidth - mission.width)/2;
				lastY += 105;
				lastX = mission.width;
			}*/
			//drawBonus();
			
			/*if(Numbers.countProps(quest) < 3){
				var descLabel:TextField = UI.drawText('Этап ' + qID +" закончен: " +TimeConverter.getDatetime("%Y.%m.%d %H:%i", uint(quest)), {
					fontSize:24,
					color:0xffffff,
					borderColor:0x49341e,
					multiline:true,
					borderSize:3,
					textAlign:"center",
					textLeading:-3
				});
				
				descLabel.x = (bgWidth - descLabel.width) / 2;
				descLabel.y = 100;
				addChild(descLabel);
			}*/
			for each(var _qst:* in settings.quests)
			{
				var mission:StatItem  = new StatItem ({'quest':App.data.quests[_qst], 'target':this});
				contentSprite.addChild(mission);
				mission.y = lastY;
				mission.x = lastX;
				lastY += mission.height + 3;
			}
			
			backSprite.addChild(contentSprite);
			
			
			addChild(backSprite);
			backSprite.x = 20;
			backSprite.y = 20;
			
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0, 1);
			mask.graphics.drawRect(0, 0, bgWidth, bgHeight - 20);
			mask.graphics.endFill();
			mask.y = 10;
			addChild(mask);
			backSprite.mask = mask;
			
			bonusBackgroutnd = UI.backing(bgWidth, bgHeight, 47, 'questTaskBackingTop');
			bonusBackgroutnd.x = 0;
			bonusBackgroutnd.y = 0;
			addChildAt(bonusBackgroutnd, 0);
			
			slider = new Slider(contentSprite, bgHeight - 50);
			backSprite.addChild(slider);
			slider.x += 20;
			
			var exitBttn:ImageButton = new ImageButton(Textures.textures.stopBttnIco);
			addChild(exitBttn);
			exitBttn.scaleX = exitBttn.scaleY = 1.2;
			exitBttn.x = bonusBackgroutnd.x + bonusBackgroutnd.width - exitBttn.width - 3;
			exitBttn.y = -3;
			exitBttn.addEventListener(MouseEvent.CLICK, dispose);
			
			//slider.y += 20;
			relocate();
		}
		
		public function slideY(e:MouseEvent):void
		{
			slider.slideY(e);
		}
		
		public function relocate():void 
		{
			x = (App.self.stage.stageWidth - bonusBackgroutnd.width) / 2;
			y = (App.self.stage.stageHeight - bonusBackgroutnd.height) / 2;
			
			/*if (App.self.stage.stageWidth - App.self.stage.mouseX < bonusBackgroutnd.width)
				x -= bonusBackgroutnd.width;
			
			if (App.self.stage.stageHeight - App.self.stage.mouseY < bonusBackgroutnd.height - 40)
				y -= bonusBackgroutnd.height;
				
			if (y < 0)
				y = 0;
				
			if (y + bonusBackgroutnd.height > App.self.stage.stageHeight)
				y = App.self.stage.stageHeight - bonusBackgroutnd.height;*/
			//App.treeManeger.mission.x = e.stageX + 20;
			//App.treeManeger.mission.y = e.stageY - (App.treeManeger.mission.height) / 2;
		}
		
		public function dispose(e:* = null):void 
		{
			if (this.parent)
				this.parent.removeChild(this)
		}
	}

}

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import tree.ComboBox;
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
		backing.graphics.lineTo(15,  0);// , x + 115	+ randC[0], y + 5   + randC[1]);
		backing.graphics.lineTo(15, H);//, x + 115	+ randC[2], y + 85  + randC[3]);
		backing.graphics.lineTo(0,  H);//, x + 5		+ randC[4], y + 85  + randC[5]);
		backing.graphics.endFill();
		backing.x = cont.width - 15;
		
		subslider = new Sprite();
		subslider.graphics.moveTo(0, 0);
		subslider.graphics.beginFill(0x6C7A89, 1);
		subslider.graphics.lineTo(15,  0);// , x + 115	+ randC[0], y + 5   + randC[1]);
		subslider.graphics.lineTo(15, 15);//, x + 115	+ randC[2], y + 85  + randC[3]);
		subslider.graphics.lineTo(0,  15);//, x + 5		+ randC[4], y + 85  + randC[5]);
		subslider.graphics.endFill();
		subslider.y = 0;
		subslider.x = cont.width - 15;
		addChild(backing);
		addChild(subslider);
	}
	public function slideY(e:MouseEvent):void
	{
		if (App.treeManeger.deltaY - parent.parent.y - 25 > H - 20  )
		{
			subslider.y = H - 20;
			_cont.y = -_cont.height + H;
		}
		else if ( App.treeManeger.deltaY - parent.parent.y - 25 < 0 )
		{
			subslider.y = 0;
			_cont.y = 0;
		}
		else {
			subslider.y =   App.treeManeger.deltaY - parent.parent.y - 25;
			_cont.y = - ((subslider.y + subslider.height * 0.5) / H) * _cont.height;
			if ( _cont.y < H - _cont.height )
				_cont.y  = H - _cont.height;
			else if ( _cont.y > 0 )
				_cont.y = 0;
		}
	
	}
}

import flash.display.Sprite;
import flash.text.TextField;
import tree.LayerX;
internal class StatItem extends LayerX
{
	private var title:String
	private var _plane:Sprite;
	public var updateTitle:TextField;
	public var questDesc:TextField;
	public var settings:Object;
	public function StatItem(_data:Object)
	{
		settings = _data;
		drawBacking();
		updateTitle = UI.drawText(_data.quest.ID + ' ' + _data.quest.title, {
			textAlign:		'left',
			fontSize:		17,
			width:			settings.target.bgWidth - 70,
			//color:			0xe0121b,
			color:			0x563D28,
			borderColor:	0x563D28,
			borderSize:		0
		});
		updateTitle.y = -2;
		addChild(updateTitle);
		
		questDesc = UI.drawText(_data.quest.description2, {
			textAlign:		'left',
			fontSize:		17,
			width:			settings.target.bgWidth - 70,
			//color:			0xe0121b,
			color:			0x563D28,
			borderColor:	0x563D28,
			borderSize:		0
		});
		questDesc.y = updateTitle.y + 15;
		addChild(questDesc);
		//addEventListener(MouseEvent.CLICK, onClick);
	}
	private function drawBacking():void
	{
		_plane = new Sprite();
		//if ( !dark )
			//_plane.graphics.beginFill(0xF2F1EF, 1);
		//else
		_plane.graphics.beginFill(0xBFBFBF, 1);
		_plane.graphics.drawRect(0, 0, settings.target.bgWidth - 70, 40);
		_plane.graphics.endFill();
		
		
		addChild(_plane);
	}
}