package wins 
{
	import buttons.Button;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import utils.TopHelper;
	import wins.elements.BubbleItem;
	/**
	 * ...
	 * @author ...
	 */
	public class TopResultWindow extends Window
	{
		private var _description:TextField;
		private var _itemsContainer:Sprite = new Sprite();
		private var _items:Vector.<BubbleItem>;
		private var _item:BubbleItem;
		private var _takeBttn:Button;
		
		public function TopResultWindow(settings:Object = null) 
		{
			settings = settingsInit(settings);
			super(settings);
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null)
			{
				settings = {};
			}
			
			settings["width"] 				= 450;
			if (Numbers.countProps(settings.bonus) > 3)
				settings["width"] += (Numbers.countProps(settings.bonus) - 3) * 120;
			settings["height"] 				= 337;
			settings['fontColor'] 			= 0x6e411e;
			settings['fontBorderColor'] 	= 0xfdf3cb;
			settings['fontBorderSize'] 		= 4;
			settings['fontSize'] 			= 46;
			settings['exitTexture'] 		= 'yellowClose';
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			settings["title"]				= Locale.__e('flash:1393579648825');
			
			return settings;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = Window.backing4(settings.width, settings.height, 0, "backingYellowTL", "backingYellowTR", "backingYellowBL", "backingYellowBR");
			layer.addChild(background);
		}
		
		private function parseContent():void 
		{
			settings.content = Numbers.objectToArraySidCount(settings.bonus);
		}
		
		override public function drawBody():void 
		{
			drawDescription();
			drawContent();
			drawButton();
			build();
		}
		
		private function drawDescription():void 
		{
			var descriptionText:String = Locale.__e('flash:1519982379108', [settings.position, settings.topName]);
			if (settings.type == 'lbonus')
				descriptionText = Locale.__e('flash:1520238699547', settings.topName);
			_description = Window.drawText(descriptionText, {
				color			:0xffe851,
				borderColor		:0x6e411e,
				borderSize		:4,
				fontSize		:26,
				width			:settings.width - 40 ,
				textAlign		:'center',
				multiline		:true,
				wrap			:true
			})
		}
		
		private function drawContent():void 
		{
			parseContent();
			disposeChilds(_items);
			_items = new Vector.<BubbleItem>;
			var X:int = 0;
			for (var i:int = 0; i < settings.content.length; i++)
			{
				_item = new BubbleItem(settings.content[i]);
				_item.x = X;
				_itemsContainer.addChild(_item);
				_items.push(_item);
				X += _item.WIDTH + 15;
			}
		}
		
		private function drawButton():void
		{
			_takeBttn = new Button({
				caption			:Locale.__e('flash:1382952379737'),
				fontColor		:0xffffff,
				width			:145,
				height			:51,
				fontSize		:32,
				bgColor			:[0xfed131, 0xf8ab1a],
				bevelColor		:[0xf7fe9a, 0xcb6b1e],
				fontBorderColor	:0x6e411e
			});
			
			_takeBttn.addEventListener(MouseEvent.CLICK, onClick)
		}
		
		private function onClick(e:MouseEvent):void 
		{
			TopHelper.getReward(settings.tID, settings.iID, settings.type, onTakeReward)
		}
		
		private function onTakeReward(bonus:Object):void 
		{
			App.user.stock.addAll(bonus);
			/*for (var _sid:* in bonus) 
			{
				var item:BonusItem = new BonusItem(_sid, bonus[_sid]);
				var point:Point = new Point(App.self.mouseX, App.self.mouseY)
				point.y += 80;
				item.cashMove(point, App.self.windowContainer);
			}*/
			App.map.focusedOn(App.user.hero);
			Treasures.bonus(bonus, new Point(App.user.hero.x, App.user.hero.y));
			close();
		}
		
		private function build():void 
		{
			exit.x -= 15;
			exit.y += 15;
			titleLabel.y += 40;
			
			_description.x = (settings.width - _description.width) / 2;
			_description.y = 60;
			bodyContainer.addChild(_description);
			
			_itemsContainer.x = (settings.width - _itemsContainer.width) / 2;
			_itemsContainer.y = 150;
			
			bodyContainer.addChild(_itemsContainer);
			
			_takeBttn.x = (settings.width - _takeBttn.width) / 2;
			_takeBttn.y = settings.height - 60;
			bodyContainer.addChild(_takeBttn);
		}
	}

}