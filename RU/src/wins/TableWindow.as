package wins 
{
	import buttons.ImageButton;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import units.Table;
	import units.table.TableEvent;
	import units.table.TableSlot;
	//import wins.HelpExplainWindow;
	import wins.MaterialIcon;
	import wins.table.TableSlotClosedItem;
	import wins.table.TableSlotEmptyItem;
	import wins.table.TableSlotFullItem;
	import wins.table.TableSlotItem;
	import wins.table.TableSlotItemEvent;
	import wins.table.TableSlotReadyItem;
	import wins.Window;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TableWindow extends Window 
	{
		
		private var _target:Table;
		private var _itemsContainer:LayerX;
		public var infoBttn:ImageButton = null;
		private var _items:Vector.<TableSlotItem>;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		public function get items():Vector.<TableSlotItem> 
		{
			return _items;
		}
		
		private var _textAcceptedMaterials:TextField;
		private var _acceptedMaterialsSprite:Sprite;
		private var _acceptedMaterialItems:Vector.<MaterialIcon>;
		
		private var _bttnHelp:ImageButton;
		private var _bttnHelp2:ImageButton;
		
		public function TableWindow(settings:Object=null) 
		{
			settings["width"] = 740;
			settings["height"] = 460;
			settings["hasPaginator"] = false;
			
			if (settings.target)
			{
				_target = Table(settings.target);
				_target.addEventListener(TableEvent.BECAME_READY, onRadyEvent);
			}
			
			settings["title"] = _target.info.title;
			
			super(settings);
		}
		
		private var titleContainer:Sprite = new Sprite();
		override public function drawTitle():void 
		{
			
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,
				fontSize			: 42,
				textLeading	 		: settings.textLeading,
				borderColor 		: 0x673104,
				borderSize 			: 3,
				shadowSize			: 4,
				shadowColor			: 0x691F16,
				hasShadow			: true,				
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			});
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -15;
			
			titleContainer.addChild(titleLabel);
			titleContainer.mouseEnabled = false;
			titleContainer.mouseChildren = false;
		}
		
		private function onRadyEvent(e:TableEvent):void 
		{
			contentChange();
		}
		
		public var background:Bitmap;
		override public function drawBackground():void {
			if (settings.background!=null){
			var background:Bitmap = backing2(settings.width, settings.height, 50, 'constructBackingUp', 'constructBackingBot');//= backing(settings.width, settings.height, 50, settings.background);
			layer.addChild(background);	
			}
		}
		
		override public function drawBody():void 
		{
			
			drawRightBttn();  
			super.drawBody();
			
			
			exit.y = 10;
			exit.x -= 19;
			drawMirrowObjs('decSeaweed', settings.width + 38, - 38, settings.height - 210, true, true, false, 1, 1, layer);
			
			var titleBackingBmap:Bitmap = backingShort(320, 'shopTitleBacking');
			titleBackingBmap.x = settings.width/2 -titleBackingBmap.width/2;
			titleBackingBmap.y = -76;
			bodyContainer.addChild(titleBackingBmap);
			
			var backgroundTitle:Shape = new Shape();
			backgroundTitle.graphics.beginFill(0xf5d761, .4);
			backgroundTitle.graphics.drawRect(0, 0, settings.width - 170, 60);
			backgroundTitle.graphics.endFill();
			backgroundTitle.filters = [new BlurFilter(20, 0, 2)];
			
			//var backgroundTitle:Bitmap = Window.backingShort(settings.width - 170, 'dailyBonusBackingDesc', true);
			backgroundTitle.x =  (settings.width -  backgroundTitle.width) / 2;
			backgroundTitle.y = settings.height - backgroundTitle.height - 120;
			bodyContainer.addChild(backgroundTitle);
			
			
			var plankBmap:Bitmap = backingShort(320, 'helfBacking'); // надо будет заменить
			plankBmap.x = (settings.width - plankBmap.width) / 2;
			plankBmap.y = 200;
			layer.addChild(plankBmap);
			
			var descLabel:TextField = Window.drawText(Locale.__e("flash:1464963482132"), {
				fontSize	:28,
				color		:0xFFFFFF,
				borderColor	:0x7f3d0e,
				textAlign	:"center"
			});
			descLabel.width = descLabel.textWidth + 20;
			descLabel.x = backgroundTitle.x + (backgroundTitle.width - descLabel.width) / 2;
			descLabel.y = backgroundTitle.y + (backgroundTitle.height - descLabel.height) / 2 + 4;
			bodyContainer.addChild(descLabel);
			
			var star1:Bitmap = new Bitmap(Window.textures.decStarBlue);
			star1.x = titleBackingBmap.x + titleBackingBmap.width + star1.width/2 - 15;
			star1.y = -star1.height / 2;
			star1.smoothing = true;
			
			var star3:Bitmap = new Bitmap(Window.textures.decStarRed);
			star3.x = 7;
			star3.y = -star1.height / 2 + 8;
			star3.smoothing = true;
			
			var star2:Bitmap = new Bitmap(Window.textures.decStarYellow);
			star2.x = star3.x + star3.width + 14;
			star2.y = -star2.height / 2 + 5;
			star2.smoothing = true;
			
			bodyContainer.addChild(star1);
			bodyContainer.addChild(star2);
			//bodyContainer.addChild(star3);
			
			titleContainer.y -= 40;
			bodyContainer.addChild(titleContainer);
			
			//drawAcceptedMaterials();
			drawTime();
			updateDuration();
			App.self.setOnTimer(updateDuration);
			
			_itemsContainer = new LayerX();
			bodyContainer.addChild(_itemsContainer);
			
			initContent();
			
			var helpTexture:BitmapData = Window.textures["aksBttnNew"];
			_bttnHelp = new ImageButton(helpTexture);
			//_bttnHelp.scaleX = _bttnHelp.scaleY = 0.85;
			
			_bttnHelp.x = 0;
			_bttnHelp.y = -12;
			_bttnHelp.addEventListener(MouseEvent.CLICK, onHelpClick);
			bodyContainer.addChild(_bttnHelp);
			
			
		}
		
		private function drawRightBttn():void 
		{
			infoBttn = new ImageButton(textures.infoBttnPink);
			bodyContainer.addChild(infoBttn);
			infoBttn.x = settings.width - 65;
			infoBttn.y = 50;
			infoBttn.addEventListener(MouseEvent.CLICK, info);
			var helpTexture2:BitmapData = Window.textures["buttonList"];
			//---------------------------------------------------------
			_bttnHelp2 = new ImageButton(helpTexture2);
			//_bttnHelp.scaleX = _bttnHelp.scaleY = 0.85;
			
			_bttnHelp2.x = infoBttn.x;
			_bttnHelp2.y = infoBttn.y + 65;
			Size.size(_bttnHelp2, 58, 58);
			_bttnHelp2.addEventListener(MouseEvent.CLICK, onInfo);
			bodyContainer.addChild(_bttnHelp2);
				
		}
		private var itemsGive:Object = { };
		private function onInfo(e:MouseEvent):void 
		{
			
			var i:int = 0;
			for each(var ii:* in settings.target.info['in'])
			{
				itemsGive[App.data.treasures[App.data.storage[ii].treasure][App.data.storage[ii].treasure].item[0]] = 1;
					
				i++;
			}
			
			var hintWindow:RouletteItemsWindow = new RouletteItemsWindow({
				popup:true,
				title:settings.title,
				description:Locale.__e('flash:1482916508392'),
				items:{0: itemsGive}
			});
			hintWindow.show();
			
		}
		
		private function info(e:MouseEvent = null):void {
		
			var hintWindow:WindowInfoWindow = new WindowInfoWindow( {
				popup: true,
				hintsNum:3,
				hintID:3,
				height:540
			});
			hintWindow.show();	
			
		}
		
		private function onHelpClick(e:MouseEvent):void 
		{
			var hintWindow:ExpeditionHintWindow = new ExpeditionHintWindow( {
				popup: true,
				hintsNum:3,
				hintID:1,
				height:540
			});
			hintWindow.show();	
		}
		
		private function drawAcceptedMaterials():void
		{
			_textAcceptedMaterials = Window.drawText(Locale.__e("flash:1456139472093"), {//Можно предложить
				multiline:true,
				wrap:true,
				textAlign:"center",
				width:settings.width - 100,
				color:0xFCFEFB,
				borderColor:0x7E3129,
				fontSize:38
			} );
			
			_textAcceptedMaterials.x = (settings.width - _textAcceptedMaterials.width) * 0.5;
			_textAcceptedMaterials.y = settings.height - 280;
			
			bodyContainer.addChild(_textAcceptedMaterials);
			
			_acceptedMaterialsSprite = new Sprite();
			
			//var _materialsBG:Shape = new Shape();
			//var _materialsBG:Bitmap = new Bitmap();
			
			/*var fillType:String = GradientType.LINEAR;
			var colors:Array = [0xCD9584, 0xCD9584, 0xCD9584, 0xCD9584];
			var alphas:Array = [0, 1, 1, 0];
			var ratios:Array = [0, 32, 223, 255];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(505, 505, 0, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;*/
			
			var _materialsBG:Bitmap = backingShort(settings.width - 140, 'tablePaperBacking');
			
			/*_materialsBG.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			_materialsBG.graphics.drawRect(0, 0, 505, 100);
			_materialsBG.graphics.endFill();*/
			_materialsBG.y += 30;
			_acceptedMaterialsSprite.addChild(_materialsBG);
			
			_acceptedMaterialItems = new Vector.<MaterialIcon>();
			
			
			var materialsContainer:Sprite = new Sprite();
			var currentItem:MaterialIcon;
			var dX:int = 10;
			var iconSize:int = 90;
			var currentCharterIcon:MaterialIcon;
			var itemInfo:Object;
			var fish:int;
			
			for (var i:int = 0; i < _target.acceptedMaterials.length; i++) 
			{
				var table:Object = this;//ТУТ
				var innerObhect:Object = App.data.storage[ _target.sid]["in"];
				
				for (var k:* in innerObhect) 
				{
					if (k == _target.acceptedMaterials[i]) 
					{
						fish = innerObhect[k];
					}
				}
				
				currentItem = new MaterialIcon(_target.acceptedMaterials[i], false, 0, iconSize, 20, null, true, fish);
				currentItem.x = i * (iconSize + dX);
				currentItem.y = (_acceptedMaterialsSprite.height - iconSize) * 0.5;
				_acceptedMaterialItems.push(currentItem);
				materialsContainer.addChild(currentItem);
				
				itemInfo = App.data.storage[_target.acceptedMaterials[i]];
				
				for (var key:String in itemInfo.worth)
				{
					currentCharterIcon = new MaterialIcon(int(key), false, 1, 35);
					currentCharterIcon.x = 40;
					currentCharterIcon.y = 30;
					currentItem.addChild(currentCharterIcon);
					currentCharterIcon.filters = [new GlowFilter(0xffffff, 1, 3, 3, 10)];
					break;
				}
			}
			
			materialsContainer.x = (_acceptedMaterialsSprite.width - ((iconSize * _acceptedMaterialItems.length) + (dX * (_acceptedMaterialItems.length - 1)))) * 0.5;
			materialsContainer.y = (_acceptedMaterialsSprite.height - iconSize) * 0.5 - 10;
			_acceptedMaterialsSprite.addChild(materialsContainer);
			
			_acceptedMaterialsSprite.x = (settings.width - _acceptedMaterialsSprite.width) * 0.5;
			_acceptedMaterialsSprite.y = settings.height - _acceptedMaterialsSprite.height * 1.78;
			//_textAcceptedMaterials.y + (_textAcceptedMaterials.height * 0.5);
			bodyContainer.addChild(_acceptedMaterialsSprite);
			
			bodyContainer.swapChildren(_textAcceptedMaterials, _acceptedMaterialsSprite);
			
		}
		
		private function initContent():void
		{
			contentChange();
		}
		
		private var timerContainer:Sprite;
		private var backgroundT:Bitmap;
		public function drawTime():void {
			
			if (timerContainer != null)
				bodyContainer.removeChild(timerContainer);
				
			timerContainer = new Sprite()
			
			backgroundT = Window.backingShort(200, 'bubbleTimerBack');
			timerContainer.addChild(backgroundT);
			backgroundT.x =  - backgroundT.width/2;
			backgroundT.y = 0;
			
			var colorTransform:ColorTransform = new ColorTransform(0.5, 0.5, 0.5);
			
			
			descriptionLabel = drawText(Locale.__e('flash:1393581955601'), {
				fontSize:30,
				textAlign:"left",
				color:0xffffff,
				borderColor:0x5a2910
			});
			descriptionLabel.x =  backgroundT.x + (backgroundT.width - descriptionLabel.textWidth) / 2;
			descriptionLabel.y = backgroundT.y - descriptionLabel.textHeight - 0;
			timerContainer.addChild(descriptionLabel);
			
			//var time:int = action.duration * 60 * 60 - (App.time - App.user.promo[action.id].started);
			//timerText = Window.drawText(TimeConverter.timeToCuts(time, true, true), {
			timerText = Window.drawText(/*TimeConverter.timeToStr(time)*/TimeConverter.timeToStr(_target._fastestFinish - App.time), {
				color:0xf8d74c,
				letterSpacing:3,
				textAlign:"center",
				fontSize:34,//30,
				borderColor:0x502f06
			});
			timerText.width = 200;
			timerText.y = backgroundT.y + (backgroundT.height - timerText.textHeight) / 2;
			timerText.x = backgroundT.x;
			
			timerContainer.addChild(timerText);
			timerContainer.y = 65;
			bodyContainer.addChild(timerContainer);
			timerContainer.x = settings.width / 2;
			
		}
		
		private function updateDuration():void 
		{
			var time:int = _target._fastestFinish - App.time;
			timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) 
			{
				descriptionLabel.visible = false;
				timerText.visible = false;
				backgroundT.visible = false;
			}else
			{
				descriptionLabel.visible = true;
				timerText.visible = true;
				backgroundT.visible = true;
			}
		}
		
		override public function contentChange():void 
		{
			var currentItem:TableSlotItem;
			
			if (!_items)
				_items = new Vector.<TableSlotItem>();
			else
			{
				clearItems();
			}
			
			var dX:int = 10;
			var dY:int = 5;
			var numSlots:int = _target.slots.length;
			var currentSlot:TableSlot;
			for (var j:int = 0; j < numSlots; j++) 
			{
				currentSlot = _target.slots[j];
				if (!currentSlot.isOpen)
				{
					currentItem = new TableSlotClosedItem(_target, j + 1);
				}
				else if (currentSlot.currentMaterial && currentSlot.finished <= App.time)
				{
					currentItem = new TableSlotReadyItem(_target, j + 1);
				}
				else if (currentSlot.currentMaterial && currentSlot.finished > App.time)
				{
					currentItem = new TableSlotFullItem(_target, j + 1);
				}
				else
				{
					currentItem = new TableSlotEmptyItem(_target, j + 1);
				}
				
				_items.push(currentItem);
				
				currentItem.addEventListener(TableSlotItemEvent.SET_ITEMS, onTableSlotSetItems);
				currentItem.addEventListener(TableSlotItemEvent.OPEN_SLOT, onTableSlotOpenSlot);
				currentItem.addEventListener(TableSlotItemEvent.TAKE_REWARD, onTableSlotTakeReward);				
				
				currentItem.x = 0;//(settings.width - currentItem.width) / 2;//(j % 3) * (150 + dX);//currentItem.width
				currentItem.y =  0//currentItem.height + 200;//int(j / 3) * (190 + dY);
				_itemsContainer.addChild(currentItem);
			}
			
			_itemsContainer.x = (settings.width - _itemsContainer.width) * 0.5;
			_itemsContainer.y = 110;// _acceptedMaterialsSprite.y + _acceptedMaterialsSprite.height - 350;
		}		
		
		private function onTableSlotTakeReward(e:TableSlotItemEvent):void 
		{
			_target.addEventListener(TableEvent.TAKEN_REWARD, onTableTakenReward);
			_target.storageBonus(e.slotID);
		}
		
		private function onTableTakenReward(e:TableEvent):void 
		{
			_target.removeEventListener(TableEvent.TAKEN_REWARD, onTableTakenReward);
			
			var slotItem:TableSlotItem = _items[e.slotID - 1];
			
			var currentSlot:TableSlot = _target.slots[e.slotID - 1];
			var bonus:Object = { };
			bonus[Stock.COINS] = Math.ceil(e.count * currentSlot.priceFactor);
			
			var slotMaterial:Object = App.data.storage[e.materialID];
			
			if (slotMaterial.worth)
			{
				for (var key:String in slotMaterial.worth)
				{
					bonus[key] =  slotMaterial.worth.key * e.count;
				}
			}
			
			BonusItem.takeRewards(bonus, slotItem);
			contentChange();
		}
		
		
		private function onTableSlotOpenSlot(e:TableSlotItemEvent):void 
		{
			_target.addEventListener(TableEvent.OPENED_SLOT, onOpenedSlot);
			_target.openSlot(e.slotID);
		}
		
		private function onOpenedSlot(e:TableEvent):void 
		{
			_target.removeEventListener(TableEvent.OPENED_SLOT, onOpenedSlot);
			
			var slotItem:TableSlotItem = _items[e.slotID - 1];
			var point:Point = new Point(slotItem.x + (slotItem.width * 0.5), slotItem.y + (slotItem.height * 0.5));
			
			contentChange();
			Hints.minus(Stock.FANT, _target.slots[e.slotID - 1].openPrice, point, false, _itemsContainer);
		}
		
		
		
		private function onTableSlotSetItems(e:TableSlotItemEvent):void 
		{
			_target.addEventListener(TableEvent.SET_ITEMS, onTableSetItems);
			_target.setMaterialToSlot(e.materialID, e.count, e.slotID);
		}
		
		private function onTableSetItems(e:TableEvent):void 
		{
			_target.removeEventListener(TableEvent.SET_ITEMS, onTableSetItems);
			
			var slotItem:TableSlotItem = _items[e.slotID - 1];
			var point:Point = new Point(slotItem.x + (slotItem.width * 0.5), slotItem.y + (slotItem.height * 0.5));
			
			contentChange();
			Hints.minus(e.materialID, e.count, point, false, _itemsContainer);
		}
	
		private function clearItems():void
		{
			var numItems:int = _items.length;
			var currentItem:TableSlotItem;
			for (var i:int = 0; i < numItems; i++) 
			{
				currentItem = _items.shift();
				if (_itemsContainer.contains(currentItem))
				{
					_itemsContainer.removeChild(currentItem);
				}
				
				currentItem.removeEventListener(TableSlotItemEvent.SET_ITEMS, onTableSlotSetItems);
				currentItem.removeEventListener(TableSlotItemEvent.OPEN_SLOT, onTableSlotOpenSlot);
				currentItem.removeEventListener(TableSlotItemEvent.TAKE_REWARD, onTableSlotTakeReward);
				currentItem.dispose();
				currentItem = null;
			}
		}
		
		override public function dispose():void 
		{
			_bttnHelp.removeEventListener(MouseEvent.CLICK, onHelpClick);
			_target.removeEventListener(TableEvent.BECAME_READY, onRadyEvent);
			clearItems();
			
			App.self.setOffTimer(updateDuration);
			super.dispose();
		}
	}
}