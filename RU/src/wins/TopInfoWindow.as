package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author ...
	 */
	public class TopInfoWindow extends Window 
	{
		private var _bttn:Button;
		private var _position:Position;
		private var _positions:Vector.<Position>;
		private var _positionsContainer:Sprite = new Sprite();
		public function TopInfoWindow(settings:Object=null) 
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
			settings["width"] 				= 490;
			settings["height"] 				= 465;
			settings['fontColor'] 			= 0x6e411e;
			settings['fontBorderColor'] 	= 0xfdf3cb;
			settings['fontBorderSize'] 		= 4;
			settings['fontSize'] 			= 46;
			settings['exitTexture'] 		= 'yellowClose';
			
			settings["hasPaper"] 			= false;
			settings["hasButtons"]			= false;
			settings["title"]				= Locale.__e('flash:1445976778425');
			settings['itemsOnPage']			= 4;
			settings["paginatorSettings"] 	= {
				buttonPrev		:"bubbleArrow"
			};
			
			return settings;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = Window.backing4(settings.width, settings.height, 0, "backingYellowTL", "backingYellowTR", "backingYellowBL", "backingYellowBR");
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			drawButton();
			contentChange();
			build();
		}
		
		
		override public function contentChange():void 
		{
			disposeChilds(_positions);
			_positions = new Vector.<Position>;
			var Y:int = 0;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				_position = new Position({
					item	: settings.content[i],
					iterator: i
				});
				_position.y = Y;
				_positionsContainer.addChild(_position);
				_positions.push(_position);
				Y += _position.HEIGHT;
			}
		}
		
		private function drawButton():void
		{
			_bttn = new Button({
				caption			:Locale.__e('flash:1382952380242'),
				fontColor		:0xffffff,
				width			:145,
				height			:54,
				fontSize		:32,
				bgColor			:[0xfed131, 0xf8ab1a],
				bevelColor		:[0xf7fe9a, 0xcb6b1e],
				fontBorderColor	:0x6e411e
			});
			
			_bttn.addEventListener(MouseEvent.CLICK, onClick)
		}
		
		private function onClick(e:MouseEvent):void 
		{
			close();
		}
		
		private function build():void 
		{
			exit.x -= 15;
			exit.y += 15;
			titleLabel.y += 35;
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - 60;
			bodyContainer.addChild(_bttn);
			
			_positionsContainer.x = (settings.width - _positionsContainer.width) / 2;
			_positionsContainer.y = 53;
			bodyContainer.addChild(_positionsContainer);
		}
		
		override public function close(e:MouseEvent = null):void 
		{
			super.close(e);
			if (settings.callback)
				settings.callback();
		}
		
		override public function drawArrows():void 
		{
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 51;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 11;
			paginator.arrowRight.y = y;
		}
		
	}

}
import core.Numbers;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.BlurFilter;
import flash.text.TextField;
import wins.elements.BubbleItem;
import wins.Window;

internal class Position extends LayerX
{
	private var _settings:Object = {
		width	:450,
		height	:86
	}
	private var _background:Shape = new Shape();
	private var _placeTitle:TextField;
	private var _placeNumber:TextField;
	private var _placeContainer:Sprite = new Sprite();
	private var _item:BubbleItem;
	private var _items:Vector.<BubbleItem>;
	private var _itemsContainer:Sprite = new Sprite();
	
	public function Position(settings:Object) 
	{
		for (var property:* in settings)
			_settings[property] = settings[property]
		drawBackground();
		drawPlace();
		drawItems();
		build();
	}
	
	private function drawBackground():void 
	{
		var bgColor:uint = 0xcda264;
		if ((_settings.iterator + 1) % 2 == 0)
			bgColor = 0xe6d8bd;
		_background.graphics.beginFill(bgColor, .9);
		_background.graphics.drawRect(0,0,_settings.width - 54, _settings.height)
		_background.graphics.endFill();
		_background.filters = [new BlurFilter(60, 0)];
	}
	
	private function drawPlace():void 
	{
		var _placeTitleText:String = Locale.__e('flash:1520335810834');
		var _placeNumberText:String = _settings.item.placeFrom;
		if (_settings.item.placeFrom != _settings.item.placeTo)
		{
			_placeTitleText = Locale.__e('flash:1520335855915');	
			_placeNumberText = _settings.item.placeFrom + ' - ' + _settings.item.placeTo;
		}
		_placeTitle = Window.drawText(_placeTitleText, {
			color			:0xffe558,
			borderColor		:0x6e411e,
			borderSize		:3,
			fontSize		:32,
			width			:95 ,
			textAlign		:'center'
		})
			
		_placeNumber = Window.drawText(_placeNumberText, {
			color			:0xffffff,
			borderColor		:0x6e411e,
			borderSize		:3,
			fontSize		:32,
			width			:95 ,
			textAlign		:'center'
		})
		
		_placeContainer.addChild(_placeTitle);
		_placeNumber.x = _placeTitle.x + (_placeTitle.width - _placeNumber.width) / 2;
		_placeNumber.y = _placeTitle.y + _placeTitle.textHeight;
		_placeContainer.addChild(_placeNumber);
	}
	
	private function drawItems():void 
	{
		for (var itm:* in _items)
		var bonus:Array = [];
		{
			if (itm && itm.parent)
			{
				itm.parent.removeChild(itm);
				itm = null;
			}
		}
		bonus = Numbers.objectToArraySidCount(Treasures.averageDropTreasure(_settings.item.bonus))
		_items = new Vector.<BubbleItem>;
		var X:int = 0;
		for (var i:int = 0; i < bonus.length; i++)
		{
			_item = new BubbleItem(bonus[i], {
				width			:63,
				height			:68,
				bgSettings		:{
					texture:	'yellowSquareBacking',
					padding:	28
				},
				titleSettings	:{
					hasTitle	:false,
					color		:0xffffff,
					borderColor	:0x6e411e,
					fontSize	:20,
					borderSize	:3
				},
				counterSettings	:{
					color		:0xffffff,
					borderColor	:0x6e411e,
					fontSize	:22,
					borderSize	:3
				},
				iconSettings	:{
					width		:45,
					height		:45
				}
			})
			_itemsContainer.addChild(_item);
			_items.push(_item);
			_item.x = X;			
			X += _item.HEIGHT + 11;
		}
		
		
		
	}
	
	private function build():void
	{
		//_background.x = 2;
		_background.y = (_settings.height - _background.height) / 2;
		addChild(_background);
		
		_placeContainer.x = 20;
		_placeContainer.y = (HEIGHT - _placeContainer.height) / 2 + 4;
		addChild(_placeContainer);
		
		_itemsContainer.x = 140;
		_itemsContainer.y = (HEIGHT - _itemsContainer.height) / 2;
		addChild(_itemsContainer);
	}
	
	public function get HEIGHT():int{return _settings.height}
}