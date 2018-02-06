package wins 
{
	import buttons.Button;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import units.Unit;
	import wins.elements.NeedItem;
	/**
	 * ...
	 * @author ...
	 */
	public class UpgradeWindow extends Window 
	{
		private var _target:Unit;
		private var _items:Array = [];
		private var _itemsContainer:Sprite = new Sprite();
		private var _description:TextField;
		private var _levelText:TextField;
		private var _bttn:Button;
		private var _bonusList:BonusList;
		private var _backBonus:Shape;
		public function UpgradeWindow(settings:Object=null) 
		{
			
			settings = settingsInit(settings);
			super(settings);
			
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			this._target = settings.target;
			initDesc();
			settings["width"]				= 545;
			settings["height"] 				= 435 + _description.height;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= true;
			settings["hasArrows"]			= false;
			settings['exitTexture'] 		= 'closeBttnMetal';
			settings['background	'] 		= 'capsuleWindowBacking';
			settings['fontColor'] 			= 0xffffff;
			settings['fontBorderColor'] 	= 0x116011;
			settings['borderColor'] 		= 0x116011;
			settings['shadowBorderColor']	= 0x116011;
			settings['fontSize'] 			= 50;
			settings['title'] 				= settings.target.info.title;
			
			return settings;
		}
		
		override public function drawBody():void 
		{
			drawRibbon();
			drawDescription();
			contentChange();
			drawBttn();
			drawBonusList();
			build();
		}
		
		private function initDesc():void 
		{
			_description = Window.drawText(_target.info.desctext,{
				fontSize		:30,
				textAlign		:'center',
				color			:0xffffff,
				borderColor		:0x451c00,
				wrap			:true,
				multinline		:true,
				borderSize		:2,
				width			:445
			});
		}
		
		private function drawDescription():void 
		{
			_levelText = Window.drawText(Locale.__e('flash:1397573560652') + ': ' + String(_target['model'].level + 1) + '/' + _target['model'].totalLevel, {
				fontSize		:40,
				color			:0xffffff,
				borderColor		:0x7e3e13,
				textAlign		:'center',
				width			:settings.width - 100
			})
		}
		
		private function drawBonusList():void 
		{
			_backBonus = new Shape();
			_backBonus.graphics.beginFill(0xffffff, .5);
			_backBonus.graphics.drawRect(0, 0, 380, 73);
			_backBonus.graphics.endFill();
			_backBonus.filters = [new BlurFilter(60, 0, 3)];
			
			_bonusList = new BonusList(Treasures.convertToObject(_target['model']['upgradeParams']['bonus']), false, {
				hasTitle:true,
				background:'rewardStripe',
				backingShort:true,
				width: 300,
				height: 60,
				bgWidth:400,
				bgX: 0,
				bgY:0,
				titleColor:0xffffff,
				titleBorderColor:0x7e3e13,
				bonusTextColor:0xffffff,
				bonusBorderColor:0x7e3e13				
			} );
		}
		
		override public function contentChange():void 
		{
			for each(var item:NeedItem in _items){
				
				item.parent.removeChild(item);
				item = null;
				
			}
			_items = [];
			var X:int = 0;
			var Y:int = 0;
			for (var i:int = 0; i < settings.content.length; i++) 
			{
				item = new NeedItem({
					item:settings.content[i],
					width:	140,
					height:	140
				})
				item.x = X;
				item.y = Y;
				
				_itemsContainer.addChild(item);
				_items.push(item);
				X += item.WIDTH + 10;
			}
		} 
		
		private function drawBttn():void 
		{
			var bttnSettings:Object = {
				caption		:_target.info.buttontext,
				bgColor		:[0xfed031, 0xf8ac1b],
				bevelColor	:[0xf7fe9a, 0xcb6b1e],
				fontBorderColor:0x7f3d0e,
				fontColor	:0xffffff,
				width		:160,
				height		:60,
				fontSize	:32
			};
		
			bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
			bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
			bttnSettings['fontBorderColor'] = 0x7f3d0e;
			
			_bttn = new Button(bttnSettings);
			if (!readyUpgrade)
				_bttn.state = Button.DISABLED;
			_bttn.addEventListener(MouseEvent.CLICK, onUpgradeEvent);
		}
		
		private function onUpgradeEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			_target['model'].upgradeCallback()
		}
		
		private function get readyUpgrade():Boolean
		{
			for each(var itm:* in settings.content)
			{
				if (!App.user.stock.checkAll(itm))
					return false;
			}
			return true;
		}
		
		private function build():void 
		{
			exit.y -= 20;
			titleLabel.y += 14;
			titleBackingBmap.y += 5;
			
			_levelText.y = 30;
			_levelText.x = (settings.width - _levelText.width) / 2;
			
			_description.y = 75;
			_description.x = (settings.width - _description.width) / 2;
			
			_itemsContainer.x = (settings.width - _itemsContainer.width) / 2;
			_itemsContainer.y = _description.y + _description.height;

			_backBonus.x = (settings.width - _backBonus.width) / 2;
			_backBonus.y = _itemsContainer.y + _itemsContainer.height + 10
			
			_bonusList.x = _backBonus.x + (_backBonus.width - _bonusList.width) / 2 - 50;
			_bonusList.y = _backBonus.y + (_backBonus.height - _bonusList.height) / 2;
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - 50 - _bttn.height / 2;
			
			bodyContainer.addChild(_levelText);
			bodyContainer.addChild(_description);
			bodyContainer.addChild(_itemsContainer);
			bodyContainer.addChild(_bttn);
			bodyContainer.addChild(_backBonus);
			bodyContainer.addChild(_bonusList);
		}
		
	}

}