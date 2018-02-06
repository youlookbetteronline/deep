package wins.table 
{
	import buttons.Button;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Table;
	import wins.MaterialIcon;
	import wins.MaterialItem;
	//import wins.selectMaterialWindow.PriceFactor;
	import wins.Window;
	import wins.PriceFactor;
	/**
	 * ...
	 * @author ...
	 */
	public class TableSlotReadyItem extends TableSlotItem 
	{
		private var _bttnTekeReward:Button;
		
		private var _materialIcon:MaterialIcon;
		private var _rewardIcon:MaterialIcon;
		private var _rewardGramotan:MaterialIcon;
		
		public function TableSlotReadyItem(target:Table, slotID:int) 
		{
			super(target, slotID);
		}
		
		override protected function drawbody():void 
		{
			super.drawbody();
			
			var iconSize:int = 80;
			
			_materialIcon = new MaterialIcon(_currentSlot.currentMaterial, true, _currentSlot.count, iconSize, 30);
			_materialIcon.x = _bg.x + (_bg.width -80) * .5 ;
			_materialIcon.y = _bg.y - 80 + 80/2 + 8;
			addChild(_materialIcon);
			
			_bttnTekeReward = new Button( {
				width:120,
				height:45,
				caption:Locale.__e("flash:1382952379737"),//Забрать
				fontSize:22
			});
			
			_bttnTekeReward.x = _bg.x + (_bg.width - _bttnTekeReward.width) * 0.5;
			_bttnTekeReward.y = _bg.y + _bg.height + 23;//height - boostBttn.height / 2 ;
			_bttnTekeReward.addEventListener(MouseEvent.CLICK, onTakeRewardClick);
			addChild(_bttnTekeReward);
		}
		
		private function onTakeRewardClick(e:MouseEvent):void 
		{
			_bttnTekeReward.state = Button.DISABLED;
			dispatchEvent(new TableSlotItemEvent(TableSlotItemEvent.TAKE_REWARD, _currentSlot.currentMaterial, _currentSlot.count, _slotID));
		}
		
		override public function dispose():void 
		{
			_bttnTekeReward.removeEventListener(MouseEvent.CLICK, onTakeRewardClick);
			super.dispose();
		}
	}
}