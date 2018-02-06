package wins {
	
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.events.Event;
	import units.Mfield;
	
	public class WindowMegaField extends Window {
		
		private static const CLOSE_BUTTON_X_OFFSET:int = 12;
		private static const CLOSE_BUTTON_Y_OFFSET:int = -28;
		
		private static const WINDOW_WIDTH:int = 700;
		private static const WINDOW_HEIGHT:int = 510;
		
		private static const LIST_BACKGROUND_WIDTH:int = 630;
		private static const LIST_BACKGROUND_HEIGHT:int = 208;
		private static const LIST_BACKGROUND_PADDING:int = 20;
		
		private static const LIST_BACKGROUND_Y:int = 12;
		
		private static const LIST_START_X:int = 55;
		private static const LIST_START_Y:int = 22;
		private static const LIST_INTERVAL_H:int = 5;
		
		private static const ARROWS_OFFSET_Y:int = -130;
		
		private static const SELECTED_ITEM_X:int = 130;
		private static const SELECTED_ITEM_Y:int = 275;
		
		private var _callerMfield:Mfield;
		private var _itemViews:Vector.<PlantItem>;
		
		private var _viewSelectedItem:SelectedPlantSubview;
		private var _viewGrowingItem:GrowingPlantSubview;
		
		public function WindowMegaField(settings:Object = null, caller:Mfield = null) {
			if (!settings) {
				settings = { };
			}
			
			settings['width'] = WINDOW_WIDTH;
			settings['height'] = WINDOW_HEIGHT;
			settings['hasPaginator'] = true;
			settings['hasArrows'] = true;
			settings['itemsOnPage'] = 1;
			settings['hasButtons'] = false;
			settings['hasAnimations'] = false;
			settings['hasTitle'] = true;
			settings['faderAlpha'] = 0.6;
			
			_itemViews = new Vector.<PlantItem>();
			
			_callerMfield = caller;
			
			super(settings);
		}
		
		override public function drawBody():void {
			exit.x += CLOSE_BUTTON_X_OFFSET;
			exit.y += CLOSE_BUTTON_Y_OFFSET;
			
			drawMirrowObjs('storageWoodenDec', -8, settings.width + 8, 40, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', -8, settings.width + 8, settings.height - 110, false, false, false, 1, 1);
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 1, settings.width / 2 + settings.titleWidth / 2 + 1, -44, true, true);
			
			var backing:Bitmap = Window.backing(LIST_BACKGROUND_WIDTH, LIST_BACKGROUND_HEIGHT, LIST_BACKGROUND_PADDING, "giftCounterBacking");
			backing.x = (settings.width - backing.width) * 0.5;
			backing.y = LIST_BACKGROUND_Y;
			bodyContainer.addChild(backing);
			
			content = initContent();
			
			updatePaginator();
			contentChange();
			
			_viewSelectedItem = new SelectedPlantSubview(_callerMfield);
			_viewSelectedItem.visible = false;
			layer.addChild(_viewSelectedItem);
			_viewSelectedItem.x = SELECTED_ITEM_X;
			_viewSelectedItem.y = SELECTED_ITEM_Y;
			
			_viewSelectedItem.addEventListener(Event.COMPLETE, onPlantComplete);
			
			if (_callerMfield && _callerMfield.pID) {
				drawGrowingPlantSubview();
			}
		}
		
		private function drawGrowingPlantSubview():void {
			var obj:Object = App.data.storage[_callerMfield.pID];
			var itemPrice:Object = getItemPrice(obj);
			for (var sid:* in obj.outs) {
							if (sid == Stock.COINS && App.self.getLength(obj.outs) > 1) {
								// nothing
							} else {
								break;
							}
						}
			var plantModel:PlantItemModel = new PlantItemModel(App.data.storage[sid].type, App.data.storage[sid].view, obj.sID, obj.title, itemPrice.count, obj.levelTime, obj.experience, itemPrice.mID, obj.levels);
			_viewGrowingItem = new GrowingPlantSubview(plantModel, _callerMfield, this);
			_viewGrowingItem.x = 75;
			_viewGrowingItem.y = 265;
			layer.addChild(_viewGrowingItem);
			
			_viewGrowingItem.addEventListener(Event.COMPLETE, onHarvestComplete);
		}
		
		private function initContent():Array {
			var result:Array = [];
			
			for each (var item:Object in App.data.storage) {
				if (item.type && item.type == "Plant"&&item.visible&&User.inUpdate(item.sID)) {
					var itemPrice:Object = getItemPrice(item);
					for (var sid:* in item.outs) {
							if (sid == Stock.COINS && App.self.getLength(item.outs) > 1) {
								// nothing
							} else {
								break;
							}
						}
					var itemModel:PlantItemModel = new PlantItemModel(App.data.storage[sid].type, App.data.storage[sid].view, item.sID, item.title, itemPrice.count, item.levelTime, item.experience, itemPrice.mID, item.levels);
					result.push(itemModel);
				}
			}
			
			paginator.onPageCount = 1;
			return result;
		}
		
		/**
		 * Parses item and returns in price and money type
		 * @param	item - item to get it proce
		 * @return object that contains fiels
		 * 			-mID - id of money type
		 * 			-count - count of money
		 */
		private function getItemPrice(item:Object):Object {
			var moneyID:int;
			var moneyCount:int;
			
			if (item.price && Numbers.countProps(item.price) > 0) {
				if (Numbers.firstProp(item.price).key == Stock.COINS) {
					moneyID = Stock.COINS;
					moneyCount = Numbers.firstProp(item.price).val;
				} else if (Numbers.firstProp(item.price).key == Stock.FANT) {
					moneyID = Stock.FANT;
					moneyCount = Numbers.firstProp(item.price).val;
				}
			}
			
			return { mID:moneyID, count:moneyCount };
		}
		
		private function updatePaginator():void {
			paginator.itemsCount = content.length;
			paginator.update();
		}
		
		override public function contentChange():void {
			var numItemViews:int = _itemViews.length;
			var oldItemView:PlantItem;
			for (var i:int = 0; i < numItemViews; i++) {
				oldItemView = _itemViews.shift();
				oldItemView.removeEventListener(Event.SELECT, onItemSelected);
				oldItemView.dispose();
			}
			
			var startX:int = LIST_START_X;
			var startY:int = LIST_START_Y;
			
			var newItemView:PlantItem;
			
			for (var j:int = paginator.startCount; j < paginator.finishCount + 3; j++) {
				newItemView = new PlantItem(content[j], this);
				newItemView.x = startX + _itemViews.length * (newItemView.width + LIST_INTERVAL_H);
				newItemView.y = startY;
				
				_itemViews.push(newItemView);
				
				newItemView.addEventListener(Event.SELECT, onItemSelected);
				
				bodyContainer.addChild(newItemView);
			}
			
			if (paginator.finishCount >= content.length - 3) {
				paginator.arrowRight.visible = false
				return;
			}
		}
		
		override public function show():void {
			super.show();
			_itemViews[0].dispatchEvent(new Event(Event.SELECT));
		}
		
		private function onItemSelected(event:Event):void {
			if (!_callerMfield.pID) {
				var selectedItemModel:PlantItemModel = (event.currentTarget as PlantItem).model;
				_viewSelectedItem.updateModel(selectedItemModel);
				_viewSelectedItem.visible = true;
			}
		}
		
		private function onPlantComplete(e:Event):void {
			_viewSelectedItem.visible = false;
			_viewSelectedItem.removeEventListener(Event.COMPLETE, onPlantComplete);
			
			drawGrowingPlantSubview();
		}
		
		private function onHarvestComplete(e:Event):void {
			close(null);
		}
		
		/*override public function drawArrows():void {
			super.drawArrows();
			
			paginator.arrowLeft.y += ARROWS_OFFSET_Y;
			paginator.arrowRight.y += ARROWS_OFFSET_Y;
		}*/
		override public function drawArrows():void {
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			paginator.arrowLeft.x = -paginator.arrowLeft.width / 2 + 86;
			paginator.arrowLeft.y = 80;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width / 2 - 6;
			paginator.arrowRight.y = 80;
		}
		
		override public function dispose():void {
			var numPlantItems:int = _itemViews.length;
			
			for (var i:int = 0; i < numPlantItems; i++) {
				_itemViews[i].removeEventListener(Event.SELECT, onItemSelected);
				_itemViews[i].dispose();
			}
			
			if (_viewSelectedItem) {
				_viewSelectedItem.removeEventListener(Event.COMPLETE, onPlantComplete);
				_viewSelectedItem.dispose();
			}
			
			if (_viewGrowingItem) {
				_viewGrowingItem.removeEventListener(Event.COMPLETE, onPlantComplete);
				_viewGrowingItem.dispose();
			}
			
			super.dispose();
		}
	}
}

import buttons.Button;
import buttons.MoneyButton;
import com.greensock.easing.Cubic;
import core.Load;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextField;
import mx.utils.StringUtil;
import ui.UserInterface;
import units.Mfield;
import wins.Window;
import wins.ProgressBar;

internal class PlantItem extends Sprite {
	
	private static const ITEM_WIDTH:int = 145;
	private static const ITEM_HEIGHT:int = 175;
	private static const ITEM_PADDING:int = 10;
	
	private static const BUTTON_WIDTH:int = 106;
	private static const BUTTON_HEIGHT:int = 40;
	
	private static const PREVIEW_SIZE:int = 105;
	
	private var _model:PlantItemModel;
	private var _window:Window;
	private var _background:Bitmap;
	private var _preloader:Preloader;
	private var _bitmapPreview:Bitmap;
	private var _textTitle:TextField;
	public var _buttonSelect:Button;
	
	public function PlantItem(model:PlantItemModel, window:Window) {
		_model = model;
		
		drawBody();
		drawPreloader();
		drawView();
		drawTitle();
		drawButton();
		
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	private function drawPreloader():void {
		_preloader = new Preloader();
		_preloader.x = _background.width * 0.5;
		_preloader.y = _background.height * 0.5;
		addChild(_preloader);
	}
	
	private function drawBody():void {
		_background = Window.backing(ITEM_WIDTH, ITEM_HEIGHT, ITEM_PADDING, "itemBacking");
		addChild(_background);
	}
	
	private function drawView():void {
		_bitmapPreview = new Bitmap();
		addChild(_bitmapPreview);
		
		Load.loading(Config.getIcon(_model.type, _model.previewID), onViewLoadComplete);
	}
	
	private function onViewLoadComplete(data:Bitmap):void {
		if (_preloader.parent == this) {
			removeChild(_preloader);
		}
		
		_bitmapPreview.bitmapData = data.bitmapData;
		Size.size(_bitmapPreview, PREVIEW_SIZE, PREVIEW_SIZE);
		_bitmapPreview.smoothing = true;
		
		_bitmapPreview.x = (_background.width - _bitmapPreview.width) * 0.5;
		_bitmapPreview.y = (_background.height - _bitmapPreview.height) * 0.5;
	}
	
	private function drawTitle():void {
		var textTitleSettings:Object = { 
			fontSize:22,
			autoSize:"left",
			textAlign:"center",
			color:			0xffffff,
			borderColor:	0x814f31,
			width:100
		};
		_textTitle = Window.drawText(_model.title, textTitleSettings);
		_textTitle.x = (_background.width - _textTitle.width) * 0.5;
		_textTitle.y = 10;
		addChild(_textTitle);
	}
	
	private function drawButton():void {
		_buttonSelect = new Button({
			width:BUTTON_WIDTH,
			height:BUTTON_HEIGHT,
			caption:Locale.__e("flash:1382952379978"),
			fontSize:24
		});
		_buttonSelect.x = (_background.width - _buttonSelect.width) * 0.5;
		_buttonSelect.y = _background.height - (_buttonSelect.height * 0.7);
		addChild(_buttonSelect);
		_buttonSelect.addEventListener(MouseEvent.CLICK, onButtonSelectClick);
	}
	
	private function onButtonSelectClick(e:MouseEvent):void {
		dispatchEvent(new Event(Event.SELECT));
	}
	
	private function onOver(e:MouseEvent):void {
		this.filters = [new GlowFilter(0xFFFF00,1, 6, 6, 7)];
	}
	
	private function onOut(e:MouseEvent):void {
		this.filters = [];
	}
	
	public function dispose():void {
		removeChild(_background);
		
		if (_preloader.parent == this) {
			removeChild(_preloader);
		}
		
		if (_bitmapPreview.parent == this) {
			removeChild(_bitmapPreview);
		}
		
		removeChild(_textTitle);
		removeChild(_buttonSelect);
		
		removeEventListener(MouseEvent.CLICK, onButtonSelectClick);
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	public function get model():PlantItemModel {
		return _model;
	}
}

internal class SelectedPlantSubview extends Sprite {
	
	private static const BACK_WIDTH:int = 255;
	private static const BACK_HEIGHT:int = 190;
	private static const BACK_PADDING:int = 20;
	
	private static const PREVIEW_SIZE:int = 110;
	
	private static const TEXT_TITLE_WIDTH:int = 200;
	private static const TEXT_TITLE_HEIGHT:int = 25;
	
	private static const TEXT_TITLE_X:int = 25;
	private static const TEXT_TITLE_Y:int = 9;
	
	private static const MAX_COUNT:int = 50;
	
	private var _callerMfield:Mfield;
	private var _model:PlantItemModel;
	
	private var _selectedCount:int;
	
	private var _bitmapBackground:Bitmap;
	private var _bitmapCountBack:Bitmap;
	private var _bitmapPreview:Bitmap;
	private var _bitmapCoin:Bitmap;
	private var _bitmapFantasy:Bitmap;
	
	private var _buttonMinus10:Button;
	private var _buttonPlus10:Button;
	
	private var _buttonMinus1:Button;
	private var _buttonPlus1:Button;
	
	private var _textTitle:TextField;
	private var _textCurrentCount:TextField;
	private var _textSelectCount:TextField;
	
	private var _textGrowTime:TextField;
	
	private var _textFullPrice:TextField;
	private var _textFullPriceValue:TextField;
	
	private var _textFantasyCostValue:TextField;
	
	private var _textSelectedCount:TextField;
	private var _bitmapSelectedCountBack:Bitmap;
	
	private var _buttonPlantIt:Button;
	
	public function SelectedPlantSubview(caller:Mfield) {
		_callerMfield = caller;
		
		drawBody();
		drawView();
		drawTextFields()
		drawButtons();
	}
	
	private function drawBody():void {
		_bitmapBackground = Window.backing(BACK_WIDTH, BACK_HEIGHT, BACK_PADDING, "itemBacking");
		addChild(_bitmapBackground);
		
		_bitmapSelectedCountBack = Window.backing(40, 35, 10, "smallBacking");
		_bitmapSelectedCountBack.x = 109;
		_bitmapSelectedCountBack.y = 145;
		addChild(_bitmapSelectedCountBack);
		
		Load.loading(Config.getIcon(App.data.storage[Stock.COINS].type, App.data.storage[Stock.COINS].preview), onMoneyIconLoadComplete);
		Load.loading(Config.getIcon(App.data.storage[Stock.FANTASY].type, App.data.storage[Stock.FANTASY].preview), onBitmapFanatasyLoadComplete)
	}
	
	private function onMoneyIconLoadComplete(data:Bitmap):void {
		if (_bitmapCoin && _bitmapCoin.parent == this) {
			removeChild(_bitmapCoin);
		}
		
		_bitmapCoin = data;
		Size.size(_bitmapCoin, 27, 27);
		_bitmapCoin.smoothing = true;
		
		//_bitmapCoin.x = 343;
		_bitmapCoin.y = 100;
		
		/*if (App.isSocial('NK')) {
			_bitmapCoin.x = 370;
		}*/
		
		addChild(_bitmapCoin);
	}
	
	private function onBitmapFanatasyLoadComplete(data:Bitmap):void {
		_bitmapFantasy = data;
		Size.size(_bitmapFantasy, 27, 27);
		_bitmapFantasy.smoothing = true;
		
		if (!_textFullPrice) {
			_bitmapFantasy.x = 345;
		} else {
			_bitmapFantasy.x = _textFullPrice.x + _textFullPrice.textWidth + 8;
		}
		
		//_bitmapFantasy.x = 343;
		_bitmapFantasy.y = 75;
		
		/*if (App.isSocial('NK')) {
			_bitmapFantasy.x = 375;
		}*/
		
		addChild(_bitmapFantasy);
	}
	
	private function drawView():void {
		_bitmapPreview = new Bitmap();
		addChild(_bitmapPreview);
	}
	
	private function drawTextFields():void {
		var textSettings:Object = { 
			width:			TEXT_TITLE_WIDTH,
			height:			TEXT_TITLE_HEIGHT,
			fontSize:		24,
			textAlign:		"center",
			color:			0xffffff,
			borderColor:	0x814f31
		};
		_textTitle = Window.drawText("",textSettings);
		_textTitle.x = TEXT_TITLE_X;
		_textTitle.y = TEXT_TITLE_Y;
		addChild(_textTitle);
		
		textSettings.width = 180;
		textSettings.height = 25;
		textSettings.fontSize = 22;
		textSettings.textAlign = "left";
		textSettings.color = 0xffffff;
		textSettings.borderColor = 0x5a2a11;
		
		_textGrowTime = Window.drawText("", textSettings);
		_textGrowTime.x = 280;
		_textGrowTime.y = 5;
		addChild(_textGrowTime);
		
		textSettings.fontSize = 24;
		textSettings.width = 95;
		_textFullPrice = Window.drawText(Locale.__e("flash:1382952380131"), textSettings);
		_textFullPrice.x = 280;
		_textFullPrice.y = 70;
		addChild(_textFullPrice);
		
		textSettings.fontSize = 28;
		textSettings.width = 105;
		textSettings.height = 30;
		textSettings.color = 0xffffff;
		textSettings.borderColor = 0x5a2a11;
		
		_textFullPriceValue = Window.drawText("", textSettings);
		//_textFullPriceValue.x = 375;
		_textFullPriceValue.x = _textFullPrice.x + _textFullPrice.textWidth + _bitmapCoin.width + 5;
		_textFullPriceValue.y = 100;
		addChild(_textFullPriceValue);
		
		_textFantasyCostValue = Window.drawText("", textSettings);
		//_textFantasyCostValue.x = 375;
		_textFantasyCostValue.x = _textFullPrice.x + _textFullPrice.textWidth + _bitmapCoin.width + 5;
		_textFantasyCostValue.y = 70;
		addChild(_textFantasyCostValue);
		
		_bitmapCoin.x = _textFullPrice.x + _textFullPrice.textWidth + 3;
		
		textSettings.fontSize = 36;
		textSettings.width = 90;
		textSettings.height = 40;
		textSettings.color = 0xffffff;
		textSettings.borderColor = 0x814f31;
		textSettings.textAlign = "center";
		
		_textCurrentCount = Window.drawText("1/50", textSettings);
		_textCurrentCount.x = 135;
		_textCurrentCount.y = 70;
		addChild(_textCurrentCount);
		
		textSettings.fontSize = 20;
		textSettings.color = 0xfffbff;
		textSettings.borderColor = 0x614605;
		textSettings.width = 35;
		textSettings.height = 30;
		
		_textSelectedCount = Window.drawText("", textSettings);
		_textSelectedCount.x = 111;
		_textSelectedCount.y = 152;
		addChild(_textSelectedCount);
		
		if (_bitmapCoin) {
			_bitmapCoin.x = _textFullPrice.x + _textFullPrice.textWidth + 3;
		}
		
		if (_bitmapFantasy) {
			_bitmapFantasy.x = _textFullPrice.x + _textFullPrice.textWidth + 8;
		}
		
		/*if (App.isSocial('NK')) {
			_textFullPriceValue.x = 400;
			_textFantasyCostValue.x = 400;
		}*/
	}
	
	private function drawButtons():void {
		var buttonSettings:Object = {
			width:145,
			height:50,
			caption:Locale.__e("flash:1396612366738")
		};
		
		_buttonPlantIt = new Button(buttonSettings);
		_buttonPlantIt.x = 280;
		_buttonPlantIt.y = 140;
		addChild(_buttonPlantIt);
		
		var buttonsBitmap:Bitmap = new Bitmap(BitmapData(UserInterface.textures.stopBacking));
		
		buttonSettings.width = 35;
		buttonSettings.height = 25;
		buttonSettings.caption = "-10";
		buttonSettings.fontSize = 15;
		buttonSettings.bgColor = [0xC18A65, 0xF3BFA6];
		buttonSettings.textAlign = "center";
		buttonSettings.borderColor = [0xC9C9C9, 0x777A81];
		buttonSettings.textLeading = 0;
		buttonSettings.fontColor = 0xfffbff;
		buttonSettings.fontBorderColor = 0x614605;
		
		_buttonMinus10 = new Button(buttonSettings);
		_buttonMinus10.x = 40;
		_buttonMinus10.y = 150;
		addChild(_buttonMinus10);
		
		buttonSettings.caption = " -1";
		_buttonMinus1 = new Button(buttonSettings);
		_buttonMinus1.x = 75;
		_buttonMinus1.y = 150;
		addChild(_buttonMinus1);
		
		buttonSettings.caption = " +1";
		_buttonPlus1 = new Button(buttonSettings);
		_buttonPlus1.x = 150;
		_buttonPlus1.y = 150;
		addChild(_buttonPlus1);
		
		buttonSettings.caption = "+10"
		_buttonPlus10 = new Button(buttonSettings);
		_buttonPlus10.x = 185;
		_buttonPlus10.y = 150;
		addChild(_buttonPlus10);
		
		_buttonPlantIt.addEventListener(MouseEvent.CLICK, onButtonPlantClick);
		_buttonMinus10.addEventListener(MouseEvent.CLICK, onCounterButtonClick);
		_buttonMinus1.addEventListener(MouseEvent.CLICK, onCounterButtonClick);
		_buttonPlus1.addEventListener(MouseEvent.CLICK, onCounterButtonClick);
		_buttonPlus10.addEventListener(MouseEvent.CLICK, onCounterButtonClick);
	}
	
	private function onCounterButtonClick(e:MouseEvent):void {
		var callerButton:Button = e.currentTarget as Button;
		
		var newCount:int = _selectedCount;
		switch (callerButton) {
			case _buttonMinus10:
				if (newCount >= 10) {
					newCount -= 10;
				}
				break;
			case _buttonMinus1:
				if (newCount >= 1) {
					newCount -= 1;
				}
				break;
			case _buttonPlus1:
				newCount += 1;
				break;
			case _buttonPlus10:
				newCount += 10;
				break;
		}
		
		var hasFunds:Boolean = checkMoney(newCount * _model.price) && checkFantasy(newCount);
		
		if (hasFunds && newCount != _selectedCount && newCount <= MAX_COUNT) {
			_selectedCount = newCount;
			
			updateButtons();
			updateTextFields();
		}
	}
	
	private function onButtonPlantClick(e:MouseEvent):void {
		if (_selectedCount > 0) {
			_callerMfield.plant(_model.sID, _selectedCount, onPlanted);
		}
	}
	
	private function onPlanted():void {
		App.user.stock.take(_model.moneyType, _model.price * _selectedCount);
		App.user.stock.take(Stock.FANTASY, _selectedCount);
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	public function updateModel(model:PlantItemModel):void {
		_model = model;
		
		_selectedCount = 0;
		
		updatePreview();
		updateTextFields();
		updateButtons();
		updateMoneyIcon();
	}
	
	private function updateMoneyIcon():void {
		Load.loading(Config.getIcon(App.data.storage[_model.moneyType].type, App.data.storage[_model.moneyType].preview), onMoneyIconLoadComplete);
	}
	
	private function updatePreview():void {
		Load.loading(Config.getIcon(_model.type, _model.previewID), onViewLoadComplete);
	}
	
	private function updateTextFields():void {
		//var localizedString:String = Locale.__e("flash:1382952380297", [TimeConverter.timeToStr(_model.growTime * _model.levels), int(_model.exp * _selectedCount).toString(), _model.price.toString()]);
		var localizedString:String = Locale.__e("flash:1382952380075", [TimeConverter.timeToStr(_model.growTime * _model.levels), int(_model.exp * _selectedCount)]);
		
		_textTitle.text = _model.title;
		_textGrowTime.text = localizedString;
		_textGrowTime.height = 100;
		
		_textFullPriceValue.text = (_model.price * _selectedCount).toString();
		
		_textFantasyCostValue.text = (_selectedCount).toString();
		
		_textCurrentCount.text = StringUtil.substitute("{0}/50", _selectedCount.toString());
		_textSelectedCount.text = _selectedCount.toString();
	}
	
	private function checkMoney(count:int):Boolean {
		var userCoins:int = App.user.stock.count(_model.moneyType);
		return (count <= userCoins);
	}
	
	private function checkFantasy(count:int):Boolean {
		var userFantasy:int = App.user.stock.count(Stock.FANTASY);
		return (count <= userFantasy);
	}
	
	private function updateButtons():void {
		if ((_selectedCount - 10) < 0) {
			_buttonMinus10.disable();
		} else {
			_buttonMinus10.enable();
		}
		
		if ((_selectedCount - 1) < 0) {
			_buttonMinus1.disable();
		} else {
			_buttonMinus1.enable();
		}
		
		if (!checkMoney((_selectedCount + 1) * _model.price) || !checkFantasy(_selectedCount + 1) || (_selectedCount + 1) > MAX_COUNT) {
			_buttonPlus1.disable();
		} else {
			_buttonPlus1.enable();
		}
		
		if (!checkMoney((_selectedCount + 10) * _model.price) || !checkFantasy(_selectedCount + 10) || (_selectedCount + 10) > MAX_COUNT) {
			_buttonPlus10.disable();
		} else {
			_buttonPlus10.enable();
		}
		
		if (_selectedCount == 0) {
			_buttonPlantIt.disable();
		} else {
			_buttonPlantIt.enable();
		}
	}
	
	private function onViewLoadComplete(data:Bitmap):void {
		_bitmapPreview.bitmapData = data.bitmapData;
		Size.size(_bitmapPreview, PREVIEW_SIZE, PREVIEW_SIZE);
		_bitmapPreview.smoothing = true;
		
		_bitmapPreview.x = (_bitmapBackground.x + ((_bitmapBackground.width * 0.5) - _bitmapPreview.width));
		_bitmapPreview.y = (_bitmapBackground.width * 0.35) - (_bitmapPreview.height * 0.5);
	}
	
	public function dispose():void {
		_buttonPlantIt.removeEventListener(MouseEvent.CLICK, onButtonPlantClick);
		_buttonMinus10.removeEventListener(MouseEvent.CLICK, onCounterButtonClick);
		_buttonMinus1.removeEventListener(MouseEvent.CLICK, onCounterButtonClick);
		_buttonPlus1.removeEventListener(MouseEvent.CLICK, onCounterButtonClick);
		_buttonPlus10.removeEventListener(MouseEvent.CLICK, onCounterButtonClick);
	}
}

import wins.Window;
import wins.PurchaseWindow;

internal class GrowingPlantSubview extends Sprite {
	
	public var win:*;
	
	private var _model:PlantItemModel;
	private var _caller:Mfield;
	
	private var _textStatus:TextField;
	private var _textTitle:TextField;
	private var _textGrowTime:TextField;
	private var _textMultiplier:TextField;
	
	private var _backing:Bitmap = new Bitmap();
	private var _bitmapPreview:Bitmap;
	private var _bitmapGlow:Bitmap;
	
	private var _progressBacking:Bitmap;
	private var _progressBar:ProgressBar;
	
	private var _buttonSpeedUp:MoneyButton;
	private var _buttonHarvest:Button;
	
	public function GrowingPlantSubview(model:PlantItemModel, caller:Mfield, win:*):void {
		_model = model;
		_caller = caller;
		this.win = win;
		
		drawPreview();
		drawProgress();
		drawButtons();
		drawTextFields();
		
		checkState();
	}
	
	private function drawTextFields():void {
		var textSettings:Object = { 
			width:			117,
			height:			37,
			fontSize:		36,
			textAlign:		"left",
			color:			0xffffff,
			borderColor:	0x814f31
		};
		
		_textStatus = Window.drawText(Locale.__e("flash:1440085490479"), textSettings);
		_textStatus.x = 80;
		_textStatus.y = 35;
		addChild(_textStatus);
		
		textSettings.fontSize = 26;
		textSettings.width = 220;
		textSettings.height = 25;
		textSettings.textAlign = "center";
		_textTitle = Window.drawText(_model.title, textSettings);
		_textTitle.x = 164;
		_textTitle.y = -6;
		addChild(_textTitle);
		
		textSettings.fontSize = 20;
		textSettings.textAlign = "left";
		textSettings.width = 190;
		textSettings.borderColor = 0x5a2a11;
		
		//var text:String = Locale.__e("flash:1382952380297", [TimeConverter.timeToStr(_model.growTime * _model.levels), int(_model.exp * _caller.count).toString(), _model.price.toString()]);
		var text:String = Locale.__e("flash:1382952380075", [TimeConverter.timeToStr(_model.growTime * _model.levels), int(_model.exp * _caller.count)]);
		_textGrowTime = Window.drawText(text, textSettings);
		_textGrowTime.x = 360;
		_textGrowTime.y = 35;
		addChild(_textGrowTime);
		
		textSettings.width = 45;
		textSettings.height = 25;
		textSettings.fontSize = 26;
		textSettings.borderColor = 0x814f31;
		
		text = StringUtil.substitute("x{0}", _caller.count.toString());
		_textMultiplier = Window.drawText(text, textSettings);
		_textMultiplier.x = 324;
		_textMultiplier.y = 106;
		addChild(_textMultiplier);
	}
	
	private function drawPreview():void {
		_bitmapGlow = new Bitmap(Window.textures.glowingBackingNew/*actionGlow*/);
		//_bitmapGlow.scaleX = _bitmapGlow.scaleY = 0.6;
		_bitmapGlow.x = 282 - (_bitmapGlow.width / 2);
		_bitmapGlow.y = 82 - (_bitmapGlow.height / 2);
		addChild(_bitmapGlow);
		_bitmapGlow.visible = false;
		Load.loading(Config.getIcon(_model.type, _model.previewID), onViewLoadComplete);
	}
	
	private function onViewLoadComplete(data:Bitmap):void {
		_backing = new Bitmap(Window.textures.instCharBacking);
		_backing.smoothing = true;
		_backing.x = 214;
		_backing.y = 26;
		addChild(_backing);
		_backing.visible = false;
		
		_bitmapPreview = data;
		Size.size(_bitmapPreview, 105, 105);
		_bitmapPreview.smoothing = true;
		_bitmapPreview.x = 220;
		_bitmapPreview.y = 34;
		addChild(_bitmapPreview);
	}
	
	private function drawProgress():void {
		_progressBacking = Window.backingShort(406, "prograssBarBacking3");
		_progressBacking.x = 7;
		_progressBacking.y = 148;
		_progressBacking.scaleY = 1.4;
		_progressBacking.smoothing = true;
		addChild(_progressBacking);
		
		var barSettings:Object = {
			width:397,
			win:this.parent
		};
		_progressBar = new ProgressBar( barSettings);
		_progressBar.x = 0;
		_progressBar.y = 145;
		_progressBar.start();
		addChild(_progressBar);
		
		App.self.setOnTimer(onTimer);
	}
	
	private function drawButtons():void {
		var buttonSettings:Object = {
			caption		:Locale.__e("flash:1382952380104"),
			width		:155,
			height		:65,
			fontSize	:22,
			radius		:15,
			countText	:_caller.count,
			multiline	:true,
			fontCountBorder :0x2e56ae
		};
		
		buttonSettings['type'] = 'fertilizer';
		
		_buttonSpeedUp = new MoneyButton(buttonSettings);
		_buttonSpeedUp.x = 430;
		_buttonSpeedUp.y = 137;
		_buttonSpeedUp.addEventListener(MouseEvent.CLICK, onButtonSpeedUpClick);
		_buttonSpeedUp.coinsIcon.visible = false;
		addChild(_buttonSpeedUp);
		
		Load.loading(Config.getIcon(App.data.storage[Stock.FERTILIZER].type, App.data.storage[Stock.FERTILIZER].view), function(data:Bitmap):void {
			_buttonSpeedUp.coinsIcon.bitmapData = data.bitmapData;
			Size.size(_buttonSpeedUp.coinsIcon, 25, 25);
			_buttonSpeedUp.coinsIcon.y -= 2;
			_buttonSpeedUp.coinsIcon.visible = true;
			_buttonSpeedUp.coinsIcon.smoothing = true;
		});
		
		
		
		buttonSettings.width = 154;
		buttonSettings.height = 54;
		buttonSettings.fontSize = 30;
		buttonSettings.caption = Locale.__e("flash:1382952379737");
		buttonSettings.bgColor = [0xffd448, 0xf5a922];
		buttonSettings.bevelColor = [0xfff17f, 0xc67d0d];
		buttonSettings.borderColor = [0xba9a51, 0xa7865a];
		buttonSettings.fontBorderColor = 0x814f31;
		
		_buttonHarvest = new Button(buttonSettings);
		_buttonHarvest.x = 200;
		_buttonHarvest.y = 150;
		_buttonHarvest.addEventListener(MouseEvent.CLICK, onButtonHarvestClick);
		_buttonHarvest.visible = false;
		_buttonHarvest.textLabel.height += 5;
		
		addChild(_buttonHarvest);
	}
	
	private function onTimer():void {
		checkState();
	}
	
	private function checkState():void {
		var currentTime:int = App.time;
		var plantTime:int = _caller.plantedTime;
		var growTime:int = _model.growTime * _model.levels;
		var progressTime:int = currentTime - plantTime;
		var leftTime:int = growTime - progressTime;
		
		if (leftTime <= 0) {
			setReadyState();
			_progressBar.progress = progressTime / growTime;
			_progressBar.time = leftTime;
		} else {
			setProgressState();
			_progressBar.progress = progressTime / growTime;
			_progressBar.time = leftTime;
		}
	}
	
	private function setProgressState():void {
		_backing.visible = true;
		_progressBacking.visible = true;
		_progressBar.visible = true;
		_buttonSpeedUp.visible = true;
		_buttonHarvest.visible = false;
		
		_textGrowTime.visible = true;
		
		_bitmapGlow.visible = false;
		_backing.visible = true;
	}
	
	private function setReadyState():void {
		_backing.visible = false;
		_progressBacking.visible = false;
		_progressBar.visible = false;
		_buttonSpeedUp.visible = false;
		_buttonHarvest.visible = true;
		
		_textGrowTime.visible = false;
		_textStatus.visible = false;
		
		_bitmapGlow.visible = true;
		_backing.visible = false;
	}
	
	private function onButtonHarvestClick(e:MouseEvent):void {
		//if (App.user.stock.check(Stock.FERTILIZER, _caller.count)) {
		_caller.harvest(harvestCallback);
		//}
		
	}
	
	private function harvestCallback():void {
		var rewardObj:Object = { };
		for (var sID:* in _caller._plant.info.outs) {
		rewardObj[sID] = _caller._plant.info.outs[sID]*_caller.count;	
		}
		rewardObj[Stock.EXP] = _caller._plant.info.experience * _caller.count;
	
	//	_caller._plant.info.outs
		BonusItem.takeRewards(rewardObj, _bitmapPreview,0,true);
		
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	private function onButtonSpeedUpClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		e.currentTarget.state = Button.DISABLED;
		
		// Снятие леек за ускорение
		if (!App.user.stock.check(345, _caller.count)) {
			win.close();
			new PurchaseWindow({
				width:395,
				itemsOnPage:2,
				content:PurchaseWindow.createContent("Boost"),
				title:Locale.__e("flash:1382952379903"),
				returnCursor:false,
				noDesc:false,
				description:Locale.__e("flash:1382952379904"),
				closeAfterBuy:false,
				autoClose:false
			}).show();
			return;
		}
		
		App.user.stock.take(345, _caller.count);
		
		_caller.boost(boostCallback);
	}
	
	private function boostCallback():void {
		checkState();
	}
	
	public function dispose():void {
		App.self.setOffTimer(onTimer);
		
		_buttonSpeedUp.removeEventListener(MouseEvent.CLICK, onButtonSpeedUpClick);
		_buttonHarvest.removeEventListener(MouseEvent.CLICK, onButtonHarvestClick);
	}
}

internal class PlantItemModel {
	
	private var _type:String;
	private var _previewID:String;
	private var _sID:int;
	private var _title:String;
	private var _price:int;
	private var _growTime:int;
	private var _exp:int;
	private var _boostPrice:int
	private var _moneyType:int;
	private var _levels:int;
	
	public function PlantItemModel(type:String, previewID:String, sID:int, title:String, price:int, growTime:int, exp:int, moneyType:int, levels:int = 1) {
		_type = type;
		_previewID = previewID;
		_sID = sID;
		_title = title;
		_price = price;
		_growTime = growTime;
		_exp = exp;
		_boostPrice = boostPrice;
		_moneyType = moneyType;
		
		_levels = levels;
	}
	
	public function get type():String {
		return _type;
	}
	
	public function get previewID():String {
		return _previewID;
	}
	
	public function get sID():int {
		return _sID;
	}
	
	public function get title():String {
		return _title;
	}
	
	public function get price():int {
		return _price;
	}
	
	public function get growTime():int {
		return _growTime;
	}
	
	public function get exp():int {
		return _exp;
	}
	
	public function get boostPrice():int {
		return _boostPrice;
	}
	
	public function get moneyType():int {
		return _moneyType;
	}
	
	public function get levels():int {
		return _levels;
	}
}