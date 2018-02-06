package wins 
{
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import buttons.Button;
	import com.greensock.TweenLite;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Strong;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import models.CraftfloorsModel;
	import ui.FloorPanel;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CraftfloorsWindow extends Window
	{
		private var _find				:int;
		private var _slotsContainer		:Sprite = new Sprite();
		private var _craftsContainer	:Sprite = new Sprite();
		private var _progressContainer	:Sprite = new Sprite();
		private var _progressIconContainer	:LayerX = new LayerX();
		private var _slots				:Vector.<Slot> = new Vector.<Slot>
		private var _crafts				:Vector.<Craft> = new Vector.<Craft>
		private var _model				:CraftfloorsModel;
		private var _askButton			:ImageButton;
		private var _progressBar		:ProgressBar;
		private var _progressBacking	:Bitmap;
		private var _progressIconBack	:Bitmap;
		private var _progressIcon		:Bitmap;
		private var _boostBttn			:MoneyButton;
		private var _backingCrafts		:Bitmap;
		private var _craftsMask			:Shape;
		private var _floorPanel			:FloorPanel;
		private var _totalTime			:int
		private var _craftedTime		:uint
		private var _boostPrice			:int
		private var _leftTime			:int
		private var _descCraft			:TextField
		private var _arrowRight			:ImageButton
		private var _arrowLeft			:ImageButton
		private var _shift				:int = 2;
		
		public function CraftfloorsWindow(settings:Object=null) 
		{
			this._model = settings.model;
			settings = settingsInit(settings);
			super(settings);
			if (settings.find)
				_find = settings.find;
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			settings["width"]				= 560;
			settings["height"] 				= 395;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			settings['exitTexture'] 		= 'blueClose';
			settings['fontColor'] 			= 0x004762;
			settings['fontBorderColor'] 	= 0xffffff;
			settings['fontBorderSize']		= 4;
			settings['fontSize'] 			= 40;
			settings['title'] 				= settings.target.info.title;
			
			return settings;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing4(settings.width, settings.height, 160, 'blueBackingTL', 'blueBackingTR', 'blueBackingBL', 'blueBackingBR');
			layer.addChild(background);	
		}
		
		override public function drawBody():void 
		{
			if (_model.floor < _model.totalFloor)
			{
				this.y -= 145;
				this.fader.y += 145;
			}
			
			contentChange();
			
			var widthBackingCrafts:int = _model.craftList.length > _model.craftOnPage? 420: 40 + _model.craftList.length * 95;
			_backingCrafts = Window.backing(widthBackingCrafts, 130, 46, 'blueLightBacking')
			_craftsMask = new Shape();
			_craftsMask.graphics.beginFill(0x000000, 1);
			_craftsMask.graphics.drawRect(0,0,400, 150)
			_craftsMask.graphics.endFill();
			_craftsMask.filters = [new BlurFilter(5, 5, 5)];
			
			drawButton();
			build();
			drawToggle();
			if (_model.floor < _model.totalFloor)
				drawFloors();
			if (_find && App.data.storage[_find].type == 'Material')
				findAndFocus(_find);
		}
			
		private function drawSlots():void 
		{
			for each(var _slot:Slot in _slots){
				_slot.parent.removeChild(_slot);
				_slot = null;
			}
			_slots = new Vector.<Slot>;
			
			var slot:Slot;
			var currentX:int = 0;
			for (var i:int = 0; i < _model.slotCount; i++)
			{
				slot = new Slot(i, this);
				slot.x = currentX;
				_slotsContainer.addChild(slot);
				_slots.push(slot);
				currentX += slot.WIDTH + 10;
			}
		}
		
		private function drawProgress():void 
		{
			disposeProgress();
			
			if (_model.craftingSlot < 0)
			{
				_descCraft = Window.drawText(Locale.__e("flash:1516977977746"), {
					color			:0xffffff,
					borderColor		:0x004762,
					borderSize		:4,
					fontSize		:34,
					width			:470,
					textAlign		:'center'
				})
				_progressContainer.addChild(_descCraft)
				_progressContainer.x = (settings.width - _progressContainer.width) / 2;
				_progressContainer.y = 160;
				
				bodyContainer.addChild(_progressContainer);
				return;
			}
			
			var itemID:int = App.data.crafting[_model.slots[_model.craftingSlot].fID].out
			var item:Object = App.data.storage[itemID]

			_progressIconBack = new Bitmap(Window.textures.backNewTile)
			//_progressIconBack.filters = [new GlowFilter(0xc1ff7b, 1, 0, 0, 4, 0)]
			Size.size(_progressIconBack, 85, 85);
			_progressIconBack.smoothing = true;
			_progressIconContainer.addChild(_progressIconBack);
			
			_progressIcon = new Bitmap();
			Load.loading(Config.getIcon(item.type, item.preview), onProgressIconLoad)
			
			_progressBacking = Window.backingShort(390, "newBlueBacking");
			
			var barSettings:Object = {
				typeLine		:'newYellowSlider',
				width			:388,
				timeColor		:0xffffff,
				timeborderColor	:0x004762,
				timeSize		:23,
				win				:this.parent
			};
			_totalTime = App.data.crafting[_model.slots[_model.craftingSlot].fID].time
			_craftedTime 			= _model.slots[_model.craftingSlot].crafted
			_leftTime 				= _craftedTime - App.time;
			_progressBar 			= new ProgressBar(barSettings);
			_progressBar.start();
			_progressBar.progress 	= (_totalTime - _leftTime) / _totalTime;
			_progressBar.time		= _leftTime;
			
			
			_boostPrice = Math.ceil((_craftedTime - App.time)/settings.target.info.boostops.i) 
			_boostBttn = new MoneyButton({
				caption			: Locale.__e('') + '\n',
				width			: 65,
				height			: 40,
				fontSize		: 24,
				fontCountSize	: 24,
				radius			: 16,
				countText		: _boostPrice,
				multiline		: false,
				wrap			: false,
				notChangePos	: true,
				iconDY			:2,
				bevelColor		:[0xcce8fa, 0x3b62c2],
				bgColor			:[0x65b7ef, 0x567ed0],
				countDY			:1
			})
			App.self.setOffTimer(progress);
			trace('STOOOOOOOOOOOOOOOOOPTIMEUR')
			
			App.self.setOnTimer(progress);
			trace('STARTTIMEUR')
			
			
			
			_progressIconContainer.tip = function():Object{
				return{
					title:		item.title,
					text:		item.description
				}
			}
			
			_progressBacking.x = _progressIconContainer.x + _progressIconContainer.width - 20;
			_progressBacking.y = _progressIconContainer.y + (_progressIconContainer.height - _progressBacking.height) / 2;
			
			_progressBar.x = _progressBacking.x - 17;
			_progressBar.y = _progressBacking.y - 13;
			
			_progressContainer.addChild(_progressBacking);
			_progressContainer.addChild(_progressBar);
			_progressContainer.addChild(_progressIconContainer);
			
			drawBoostBttn();
			
			_progressContainer.x = (settings.width - _progressContainer.width) / 2;
			_progressContainer.y = 145;
			
			bodyContainer.addChild(_progressContainer);
		}
		
		private function onBoostEvent(e:MouseEvent):void 
		{
			if (!App.user.stock.check(3, int(e.currentTarget.countLabel.text)))
			{
				Window.closeAll();
				new BanksWindow( { section:e.currentTarget.settings.mode } ).show();
				return;
			}
			_model.boostCallback(_model.craftingSlot, contentChange)
		}
		
		private function onProgressIconLoad(data:Bitmap):void 
		{
			_progressIcon.bitmapData = data.bitmapData;
			Size.size(_progressIcon, 50, 50);
			_progressIcon.smoothing = true;
			_progressIcon.x = _progressIconBack.x + (_progressIconBack.width - _progressIcon.width) / 2 - 3;
			_progressIcon.y = _progressIconBack.y + (_progressIconBack.height - _progressIcon.height) / 2;
			_progressIcon.filters = [new GlowFilter(0xffffff, 1, 3, 3, 10, 1)];
			_progressIconContainer.addChild(_progressIcon);
		}
		
		private function progress():void 
		{
			if (_model.craftingSlot == -1)
				return;
			_craftedTime 	= _model.slots[_model.craftingSlot].crafted
			_leftTime 		= _craftedTime - App.time;

			if (_leftTime <= 0) 
			{
				//App.self.setOffTimer(progress);
				_model.slots[_model.craftingSlot].crafted = 0
				settings.target.updateSlots();
				contentChange();
				/*drawProgress()
				_model.slots[_model.craftingSlot].crafted = 0
				settings.target.updateSlots();
				return;*/
			}
			if (_model.craftingSlot == -1)
				return;
			_totalTime		= App.data.crafting[_model.slots[_model.craftingSlot].fID].time
			_progressBar.progress 	= (_totalTime - _leftTime) / _totalTime;
			_progressBar.time		= _leftTime;
			
			_boostPrice = Math.ceil((_craftedTime - App.time) / settings.target.info.boostops.i) 
			
			drawBoostBttn();
		}
		
		private function drawBoostBttn():void 
		{
			disposeBoostBttn();
			_boostBttn = new MoneyButton({
				caption			: Locale.__e('') + '\n',
				width			: 65,
				height			: 40,
				fontSize		: 24,
				fontCountSize	: 24,
				radius			: 16,
				countText		: _boostPrice,
				multiline		: false,
				wrap			: false,
				notChangePos	: true,
				iconDY			:2,
				bevelColor		:[0xcce8fa, 0x3b62c2],
				bgColor			:[0x65b7ef, 0x567ed0],
				countDY			:1
			})
			_boostBttn.x = _progressBacking.x + _progressBacking.width
			_boostBttn.y = _progressBacking.y + (_progressBacking.height - _boostBttn.height) / 2;
			_progressContainer.addChild(_boostBttn);
			_boostBttn.addEventListener(MouseEvent.CLICK, onBoostEvent)
			
			_boostBttn.tip = function():Object{
				return{
					title: 	Locale.__e('flash:1516895955751'),
					text:	Locale.__e('flash:1516895981704')
				}
			}
		}
		
		override public function contentChange():void 
		{
			drawSlots();
			disposeProgress()
			drawProgress();
			drawCrafts();
		}
		
		private function drawCrafts():void 
		{
			for each(var _craft:Craft in _crafts){
				_craft.parent.removeChild(_craft);
				_craft = null;
			}
			_crafts = new Vector.<Craft>;
			
			var craft:Craft;
			var currentX:int = 0;
			for (var i:int = 0; i < _model.craftList.length; i++)
			{
				craft = new Craft(_model.craftList[i], this, model, settings.target);
				craft.x = currentX;
				_craftsContainer.addChild(craft);
				_crafts.push(craft);
				currentX += craft.WIDTH + 14;
			}
		}
		
		private function drawToggle():void 
		{
			if (_model.craftList.length <= _model.craftOnPage)
				return;
			_arrowLeft = new ImageButton(Window.textures.yellowArrowLeft)
			_arrowRight = new ImageButton(Window.textures.yellowArrowRight);
			
			_arrowLeft.addEventListener(MouseEvent.CLICK, moveLeft)
			_arrowRight.addEventListener(MouseEvent.CLICK, moveRight)
			
			_arrowLeft.x = _backingCrafts.x - _arrowLeft.width
			_arrowLeft.y = _backingCrafts.y + (_backingCrafts.height - _arrowLeft.height) / 2;
			_arrowLeft.visible = false;
			
			_arrowRight.x = _backingCrafts.x + _backingCrafts.width;
			_arrowRight.y = _backingCrafts.y + (_backingCrafts.height - _arrowRight.height) / 2;
			
			
			bodyContainer.addChild(_arrowLeft);
			bodyContainer.addChild(_arrowRight);
		}
		
		private function moveLeft(e:MouseEvent):void 
		{
			
			move(_shift * -1)
		}
		
		private function moveRight(e:MouseEvent):void 
		{
			move(_shift)
		}
		
		private function move(shift:int, callback:Function = null):void 
		{
			var rightX:int = 87
			var leftX:int = rightX - _craftsContainer.width + _backingCrafts.width - 33;
			var widthItem:int = 99	
			var finishPosition:int = _craftsContainer.x - widthItem * shift
			finishPosition = finishPosition > rightX? rightX : finishPosition
			finishPosition = finishPosition < leftX? leftX : finishPosition
			if (finishPosition <= leftX + 20)
				_arrowRight.visible = false
			else
				_arrowRight.visible = true;
			if (finishPosition >= rightX - 20)
				_arrowLeft.visible = false
			else
				_arrowLeft.visible = true
			TweenLite.to(_craftsContainer, .7, {
				x 			:finishPosition,
				ease		:Quad.easeOut,
				onComplete	:function():void{
					if (callback != null)
						callback();
					
					
				}
			})
		}
		private function drawButton():void
		{
			_askButton = new ImageButton(Window.textures.blueAsk);
			_askButton.bitmap.smoothing = true;
			_askButton.addEventListener(MouseEvent.CLICK, onAskEvent)
			_askButton.tip = function():Object{
				return{
					title:Locale.__e('flash:1382952380254')
				}
			}
			
		}
		
		private function onAskEvent(e:MouseEvent):void 
		{
			close();
			new HintWindow({
				icons:[
					'Craft1',
					'Craft2',
					'Craft3',
				],
				descriptions:[
					Locale.__e("flash:1516965823931"),
					Locale.__e("flash:1516965859995"),
					Locale.__e("flash:1516965879734")
				],
				popup:true,
				callback:	settings.target.click
			}).show();
			//contentChange();
		}
		
		private function build():void 
		{
			titleLabel.y += 28;
			exit.y += 10;
			exit.x -= 15;
			
			_slotsContainer.y = 50;
			_slotsContainer.x = (settings.width - _slotsContainer.width) / 2;
			
			_backingCrafts.y = _slotsContainer.y + 160;
			_backingCrafts.x = (settings.width - _backingCrafts.width) / 2;
			
			_craftsMask.y = _slotsContainer.y + 145;
			_craftsMask.x = (settings.width - _craftsMask.width) / 2;
			
			_craftsContainer.y = _backingCrafts.y + 27;
			_craftsContainer.x = _backingCrafts.x + 17;	
			if (_model.craftList.length < _model.craftOnPage)
				_craftsContainer.x = _backingCrafts.x + (_backingCrafts.width - _craftsContainer.width) / 2;
			_craftsMask.cacheAsBitmap = true;
			_craftsContainer.cacheAsBitmap = true;
			_craftsContainer.mask = _craftsMask
			_askButton.x = 35;
			_askButton.y = 0;

			bodyContainer.addChild(_backingCrafts);
			bodyContainer.addChild(_craftsMask);
			bodyContainer.addChild(_slotsContainer);
			bodyContainer.addChild(_craftsContainer);
			bodyContainer.addChild(_askButton);
		}
		
		override public function dispose():void 
		{
			disposeProgress();
			super.dispose();
		}
		
		
		
		private function disposeProgress():void 
		{
			if (_progressIconBack && _progressIconBack.parent)
				_progressIconBack.parent.removeChild(_progressIconBack);
				
			if (_descCraft && _descCraft.parent)
				_descCraft.parent.removeChild(_descCraft);
				
			if (_progressIcon && _progressIcon.parent){
				_progressIcon.parent.removeChild(_progressIcon);
				_progressIcon = null
			}
				
			if (_progressBacking && _progressBacking.parent)
				_progressBacking.parent.removeChild(_progressBacking);
				
			if (_progressBar && _progressBar.parent)
				_progressBar.parent.removeChild(_progressBar);
				
			disposeBoostBttn();
				
			if (_progressContainer && _progressContainer.parent)
				_progressContainer.parent.removeChild(_progressContainer);
				
			if (_progressIconContainer && _progressIconContainer.parent)
			{
				_progressIconContainer.parent.removeChild(_progressIconContainer);
				_progressIconContainer = new LayerX();
			}
			App.self.setOffTimer(progress);
			trace('STOOOOOOOOOOOOOOOOOPTIMEUR')
		}
		
		private function disposeBoostBttn():void 
		{
			if (_boostBttn && _boostBttn.parent)
			{
				_boostBttn.parent.removeChild(_boostBttn);
				_boostBttn = null;
			}
		}
		
		private function drawFloors():void 
		{
			_floorPanel = new FloorPanel(this, model);
			_floorPanel.x = (settings.width - _floorPanel.width) / 2;
			_floorPanel.y = settings.height - 25;
			bodyContainer.addChild(_floorPanel);
		}
		
		private function findAndFocus(sID:int):void 
		{
			var target:Craft;
			var targetNumber:int;
			var onPage:int = 3;
			var shift:int;
			for (var cr:* in _crafts)
			{
				if (_crafts[cr].outID == sID)
				{
					targetNumber = cr;
					target = _crafts[targetNumber]
					break;
				}
			}
			shift = targetNumber - onPage > 0? targetNumber - onPage : 0
			if (target)
			{
				if (!shift)
					targetGlowing(target)
				else
				{
					
					move(shift, function():void{
						targetGlowing(target)
					})				
				}
			}
			else
			{
				new SimpleWindow( {
					title:Locale.__e("flash:1474469531767"),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1517307378730', [App.data.storage[sID].title, settings.target.info.title]),
					popup:true,
					confirm:function():void{
						targetGlowing(_floorPanel)
					}
				}).show();
				return;
			}
			
			
		}
		
		private function targetGlowing(target:LayerX):void 
		{
			target.showGlowing(0xffff00)
			setTimeout(function():void 
			{
				target.hideGlowing();
			}, 5400);
		}
		
		override public function close(e:MouseEvent = null):void 
		{
			super.close(e);
			settings.target.helpTarget = 0;
		}
		
		public function get model():CraftfloorsModel{return _model;}
		
	}
}
import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Numbers;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import models.CraftfloorsModel;
import silin.filters.ColorAdjust;
import ui.Hints;
import units.Craftfloors;
import wins.CraftfloorsWindow;
import wins.BanksWindow;
import wins.FormulaWindow;
import wins.Window;
import wins.ProgressBar;

internal class Slot extends LayerX
{
	private var _settings:Object = {
		width		:85,
		height		:85
	};
	private var _window:CraftfloorsWindow;
	private var _target:Craftfloors;
	private var _model:CraftfloorsModel;
	private var _backing:Bitmap;
	private var _slotID:int;
	private var _icon:Bitmap;
	private var _title:TextField;
	private var _mode:int;
	private var _bttn:Button;
	
	public function Slot(number:int, window:CraftfloorsWindow)
	{
		this._slotID = number;
		this._window = window;
		this._target = _window.settings.target;
		this._model = _window.model;
		//this._mode = getMode(_slotID)
		drawBacking();
		drawItem();
		drawTitle();
		drawButton();
		
		tip = function():Object{return parseTips();}
	}
	
	private function parseTips():Object 
	{
		switch (mode)
		{
			case CraftfloorsModel.INPROGRESS:
				return{
					title:		App.data.storage[App.data.crafting[_model.slots[_slotID].fID].out].title,
					text:		App.data.storage[App.data.crafting[_model.slots[_slotID].fID].out].description
				}
				break;
			case CraftfloorsModel.FREE:
				return{
					title:		Locale.__e('flash:1516896029352'),
					text:		Locale.__e('flash:1516896084056')
				}
				break;
			case CraftfloorsModel.INQUEUE:
				return{
					title:		App.data.storage[App.data.crafting[_model.slots[_slotID].fID].out].title,
					text:		Locale.__e('flash:1516898812608'),
					timerText: 	TimeConverter.timeToStr(_model.slots[_slotID].crafted - App.time - App.data.crafting[_model.slots[_slotID].fID].time),
					timer:		true
				}
				break;
			case CraftfloorsModel.FINISH:
				return{
					title:		App.data.storage[App.data.crafting[_model.slots[_slotID].fID].out].title,
					text:		Locale.__e('flash:1516898864376')
				}
				break;
			default:
				return{
					title:		Locale.__e('flash:1516896220105'),
					text:		Locale.__e('flash:1516896241601')
				}
				
		}
		
	}
	
	private function drawBacking():void 
	{
		switch (mode)
		{
			case CraftfloorsModel.LOCKED:
				_backing = Window.backing2(90, 90, 30, 'blueRedBackingTop', 'blueRedBackingBot');
				break;
			case CraftfloorsModel.FREE:
				_backing = Window.backing2(90, 90, 30, 'blueCyanBackingTop', 'blueCyanBackingBot');
				break;
			case CraftfloorsModel.FINISH:
				_backing = Window.backing2(90, 90, 30, 'blueYellowBackingTop', 'blueYellowBackingBot');
				break;
			case CraftfloorsModel.INPROGRESS:
				_backing = Window.backing2(90, 90, 30, 'blueGreenBackingTop', 'blueGreenBackingBot');
				break;
			default:
				_backing = Window.backing2(90, 90, 30, 'blueWhiteBackingTop', 'blueWhiteBackingBot');
		}
		
		addChild(_backing);
	}
	
	private function drawItem():void 
	{
		switch (mode)
		{
			case CraftfloorsModel.INPROGRESS:
			case CraftfloorsModel.FINISH:
			case CraftfloorsModel.INQUEUE:
				Load.loading(Config.getIcon(App.data.storage[App.data.crafting[_model.slots[_slotID].fID].out].type, App.data.storage[App.data.crafting[_model.slots[_slotID].fID].out].view), onLoadIcon);
				break;
			case CraftfloorsModel.FREE:
				_icon = new Bitmap(Window.textures.blueClock)
				addIcon();
				break;
			case CraftfloorsModel.LOCKED:
				_icon = new Bitmap(Window.textures.blueLock)
				addIcon();
				break;
				
		}
	}
		
	private function drawTitle():void 
	{
		if (_model.slots[_slotID].fID)
		{
			var titleText:String = App.data.storage[App.data.crafting[_model.slots[_slotID].fID].out].title
			_title = Window.drawText(titleText , {
				fontSize		:18,
				color			:0xfffffe,
				borderColor		:0x004762,
				borderSize		:3,
				textAlign		:'center',
				width			:WIDTH,
				multiline		:true,
				wrap			:true
			});
			
			_title.x = _backing.x + (_backing.width - _title.width) / 2;
			_title.y = _backing.y - 17;
			addChild(_title);
		}
		
		
	}
	
	private function drawButton():void 
	{
		switch (mode)
		{
			case CraftfloorsModel.LOCKED:
				_bttn = new MoneyButton( {
					width			:85,
					height			:35,
					countText		:Numbers.firstProp(_target.info.slots[_slotID].price).val,
					caption			:Locale.__e(' '),
					fontSize		:18,
					boostsec		:1,
					mID				:Numbers.firstProp(_target.info.slots[_slotID].price).key, 
					iconDY			:2,
					bevelColor		:[0xcce8fa, 0x3b62c2],
					bgColor			:[0x65b7ef, 0x567ed0],
					countDY			:3
				});
				if (!_model.slots[_slotID - 1] || !_model.slots[_slotID - 1].status )
					_bttn.state = Button.DISABLED
				_bttn.addEventListener(MouseEvent.CLICK, onUnlockEvent)
			break;
			
			case CraftfloorsModel.FINISH:
				_bttn = new Button({
					caption			:Locale.__e('flash:1382952379737'),
					fontColor		:0xffffff,
					width			:85,
					height			:35,
					fontSize		:18,
					bgColor			:[0xfed031, 0xf8ac1b],
					bevelColor		:[0xf7fe9a, 0xcb6b1e],
					fontBorderColor	:0x7f3d0e
				});
				_bttn.addEventListener(MouseEvent.CLICK, onStorageEvent)

		}
		if (!_bttn)
			return;
		_bttn.x = (_backing.width - _bttn.width) / 2;
		_bttn.y = _backing.height - _bttn.height / 2 - 10;
		addChild(_bttn)
	}
	
	private function onStorageEvent(e:MouseEvent):void 
	{
		_model.storageCallback(_slotID, _window.contentChange);
	}
	
	private function onUnlockEvent(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED)
			return;
		if (App.user.stock.check(_target.info.slots[_slotID].price))
		{
			Window.closeAll();
			new BanksWindow( { section:e.currentTarget.settings.mode } ).show();
			return;
		}
		_model.unlockCallback(_slotID, _window.contentChange);
	}
	
	
	private function get mode():int 
	{
		if (_slotID == _model.craftingSlot)
			return CraftfloorsModel.INPROGRESS;
		else if (_model.finishedSlots.indexOf(_slotID) != -1)
			return CraftfloorsModel.FINISH;
		else if (_model.slots[_slotID].hasOwnProperty('crafted'))
			return CraftfloorsModel.INQUEUE;
		else if (_model.slots[_slotID].status)
			return CraftfloorsModel.FREE;
		else 
			return CraftfloorsModel.LOCKED;
			
			
		
	}
	
	private function onLoadIcon(data:Bitmap):void 
	{
		_icon = new Bitmap(data.bitmapData)
		Size.size(_icon, 50, 50);
		addIcon();
	}
	
	private function addIcon():void 
	{
		_icon.smoothing = true;
		_icon.x = _backing.x + (_backing.width - _icon.width) / 2;
		_icon.y = _backing.y + (_backing.height - _icon.height) / 2 - 5;
		addChild(_icon);
	}
	
	
	
	
	public function get WIDTH():int { return _settings.width; }
	public function get HEIGHT():int { return _settings.height; }
}

internal class Craft extends LayerX
{
	private var _settings:Object = {
		width		:85,
		height		:85
	};
	private var _model:CraftfloorsModel;
	private var _window:CraftfloorsWindow;
	private var _backing:Bitmap;
	private var _icon:Bitmap;
	private var _title:TextField;
	private var _fID:int;
	private var _outID:int;
	private var _craft:Object;
	private var _bttn:Button;
	private var _target:Craftfloors;
	public function Craft(fID:int, window:CraftfloorsWindow, model:CraftfloorsModel, target:Craftfloors)
	{
		this._model = model;
		this._window = window;
		this._fID = fID;
		this._craft = App.data.crafting[_fID];
		this._outID = _craft.out;
		this._target = target;
		drawBacking();
		drawItem();
		drawTitle();
		drawButton();
		tip = function():Object{
			return {
				title:App.data.storage[_outID].title,
				text:App.data.storage[_outID].description
			}
		}	
	}
	
	private function drawBacking():void 
	{
		_backing = Window.backing(90, 90, 30, 'blueBacking');
		_backing.smoothing = true;
		addChild(_backing);
	}
	
	private function drawItem():void 
	{
		Load.loading(Config.getIcon(App.data.storage[_outID].type, App.data.storage[_outID].preview), function(data:Bitmap):void{
			_icon = new Bitmap(data.bitmapData);
			Size.size(_icon, 50, 50);
			_icon.smoothing = true;
			_icon.x = _backing.x + (_backing.width - _icon.width) / 2;
			_icon.y = _backing.y + (_backing.height - _icon.height) / 2;
			addChild(_icon);
		})
	}
	
	private function drawTitle():void 
	{
		_title = Window.drawText(App.data.storage[_outID].title + '\n' + '+' + String(_craft.count) , {
			fontSize		:18,
			color			:0xfffffe,
			borderColor		:0x004762,
			borderSize		:3,
			textAlign		:'center',
			width			:WIDTH,
			multiline		:true,
			wrap			:true
		});
		
		_title.x = _backing.x + (_backing.width - _title.width) / 2;
		_title.y = _backing.y - _title.textHeight + 25;
		addChild(_title);
	}
	
	private function drawButton():void 
	{
		var bttnSettings:Object = {
		caption		:Locale.__e('flash:1382952380036'),
		fontColor	:0xffffff,
		width		:75,
		height		:32,
		fontSize	:19
		};
	
		bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
		bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
		bttnSettings['fontBorderColor'] = 0x7f3d0e;
		
		_bttn = new Button(bttnSettings);
		_bttn.addEventListener(MouseEvent.CLICK, onCraftingEvent);
		
		_bttn.x = _backing.x + (_backing.width - _bttn.width) / 2;
		_bttn.y = _backing.y + _backing.height - 20;
		addChild(_bttn);
		
		if (_model.openSlots.length <= _model.busySlots.length)
			_bttn.state = Button.DISABLED
		
	}
	
	private function onCraftingEvent(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED)
		{
			Hints.text(Locale.__e('flash:1517313165257'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
			return;
		}
		_window.close();
		new FormulaWindow({
			model:	_model,
			fID:	_fID,
			callback:_window.contentChange,
			target	:_target,
			window	:_window
		}).show();
		//_model.craftingCallback(_fID, _window.contentChange);
	}
	
	public function get WIDTH():int { return _settings.width; }
	public function get HEIGHT():int { return _settings.height; }
	
	public function get outID():int {return _outID;}
	
}
