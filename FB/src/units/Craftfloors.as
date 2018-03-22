package units 
{
	import buttons.Button;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.geom.Point;
	import models.CraftfloorsModel;
	import ui.UnitIcon;
	import wins.CraftfloorsWindow;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class Craftfloors extends Decor 
	{
		private var _model:CraftfloorsModel;
		private var _helpTarget:int = 0;
		private var _ltween:TweenLite;
		private var _rtween:TweenLite;
		
		public function Craftfloors(object:Object) 
		{
			super(object);
			initModel(object);
			changeSWF(_model.floor, false);
			showIcon();
			tip = function():Object{
				return parseTips();
			}
			multiple = false
			stockable = false
		}
		
		
		private function initModel(params:Object):void 
		{
			_model = new CraftfloorsModel(this);
			_model.slots = Numbers.objectToArray(params.slots) || [];
			_model.floor = params.floor || 1
			_model.craftList = Numbers.objectToArray(params.crafts) || []
			_model.craftingSlot = getCraftingSlot;
			_model.finishedSlots = getFinishedSlots;
			_model.busySlots = getBusySlots;
			_model.toThrow = params.toThrow || {};
			_model.kicks = params.kicks || 0;
			_model.throwCallback = throwEvent;
			_model.openSlots = getOpenSlots;
			_model.growCallback = growEvent;
			_model.storageCallback = storageEvent;
			_model.cancelCallback = cancelEvent;
			_model.craftingCallback = craftingEvent;
			_model.unlockCallback = unlockEvent;
			_model.boostCallback = boostEvent;
		}
		
		
		public function updateSlots():void 
		{
			_model.craftingSlot = getCraftingSlot;
			_model.finishedSlots = getFinishedSlots;
			//_model.craftList = this.info.levels[_model.floor].option.craft
			_model.craftingSlot = getCraftingSlot;
			_model.finishedSlots = getFinishedSlots;
			_model.openSlots = getOpenSlots;
			_model.busySlots = getBusySlots;
			
		}
		
		
		private function get getCraftingSlot():int 
		{
			var result:int = -1;						//if not find CraftingSlot
			
			for (var slNum:* in _model.slots)
			{
				if (_model.slots[slNum].hasOwnProperty('crafted'))
				{
					if (_model.slots[slNum].crafted > App.time)
					{
						if ((_model.slots[slNum].crafted - App.data.crafting[_model.slots[slNum].fID].time) <= App.time)
						{
							result = slNum
							break;
						}
					}
				}
				
			}
			return result;
		}
		
		private function get getFinishedSlots():Array 
		{
			var result:Array = new Array();						//if not find FinishedSlot
			for (var sl:* in _model.slots)
			{
				if (_model.slots[sl].hasOwnProperty('crafted'))
				{
					if (_model.slots[sl].crafted <= App.time)
						result.push(sl);
				}
				
			}
			return result;
		}
		
		private function get getBusySlots():Array 
		{
			var result:Array = new Array();						//if not find FinishedSlot
			for (var sl:* in _model.slots)
			{
				if (_model.slots[sl].hasOwnProperty('fID'))
					result.push(sl);
			}
			return result;
		}
		
		private function get getOpenSlots():Array 
		{
			var result:Array = new Array();						//if not find FinishedSlot
			for (var sl:* in _model.slots)
			{
				if (_model.slots[sl].status)
					result.push(sl);
			}
			return result;
		}
		
		public function get helpTarget():int 
		{
			return _helpTarget;
		}
		
		public function set helpTarget(value:int):void 
		{
			_helpTarget = value;
		}
		
		public function get model():CraftfloorsModel 
		{
			return _model;
		}
		
		private function parseTips():Object 
		{
			return{
					title:		info.title,
					text:		info.description
				}
		}
		
		private function loadSWF(level:int, effect:Boolean = true):void
		{
			Load.loading(Config.getSwf(info.type, info.levels[level].option.preview), onLoad);
		}
		
		private function showIcon():void
		{	
			clearIcon();
			_model.finishedSlots = getFinishedSlots;
			if (_model.finishedSlots.length == 0)
				return;
			var coordsCloud:Object = new Object();
			if (App.data.storage[sid].hasOwnProperty('cloudoffset') && 
			(App.data.storage[sid]['cloudoffset'].dx != 0 || App.data.storage[sid]['cloudoffset'].dy != 0))
			{
				coordsCloud.x = App.data.storage[sid]['cloudoffset'].dx;
				coordsCloud.y = App.data.storage[sid]['cloudoffset'].dy;
			}else{
				coordsCloud.x = 0;
				coordsCloud.y = -50;
			}
			var _view:int = App.data.crafting[_model.slots[_model.finishedSlots[0]].fID].out;
			drawIcon(UnitIcon.REWARD, _view, 1, {
				glow:		true
			}, 0, coordsCloud.x, coordsCloud.y);
			
		}
		
		private function throwEvent(typeMkick:String, throwCallback:Function, button:Button):void 
		{
			button.state = Button.DISABLED;
			Post.send({
				ctr		:this.type,
				act		:'throw',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid,
				type	:typeMkick
			}, onThrowEvent, {
				throwCallback:	throwCallback,
				button: 		button
			});
		}
		
		private function onThrowEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			_model.kicks = data.kicks;
			_model.toThrow = data.toThrow;
			App.user.stock.takeAll(data.__take)
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			params.throwCallback();
			params.button.state = Button.DISABLED;
		}
		
		private function growEvent():void 
		{
			Post.send({
				ctr		:this.type,
				act		:'grow',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid
			}, onGrowEvent);
		}
		
		private function onGrowEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				//Errors.show(error, data);
				return;
			}
			showIcon()
			Window.closeAll()
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			if (data.floor)
				_model.floor = data.floor;
				
			if (data.toThrow)
				_model.toThrow = data.toThrow;
			if (data.crafts)
				_model.craftList = Numbers.objectToArray(data.crafts);
			updateSlots();
			showIcon();
			clearBmaps = true
			changeSWF(_model.floor);
		}
		
		private function craftingEvent(fID:int, craftCallback:Function):void 
		{
			var sendObj:Object = {
				ctr		:this.type,
				act		:'crafting',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid,
				fID		:fID
			}
			if (_model.booster)
			{
				sendObj['bSID'] = _model.booster.sid;
				sendObj['bID'] = _model.booster.id;
			}
			Post.send(sendObj, onCraftingEvent, {
				craftCallback:craftCallback
			});
		}
		
		private function onCraftingEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				return;
			}
			//Window.closeAll()
			App.user.stock.takeAll(data.__take)
			_model.slots = Numbers.objectToArray(data.slots);
			updateSlots();
			params.craftCallback()
		}
		
		private function cancelEvent(slotID:int, cancelCallback:Function):void 
		{
			Post.send({
				ctr		:this.type,
				act		:'cancel',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid,
				slotID	:slotID
			}, onCancelEvent, {
				cancelCallback:cancelCallback
			});
		}
		
		private function onCancelEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				return;
			}
			Window.closeAll()
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			_model.slots = Numbers.objectToArray(data.slots);
			updateSlots();
			params.cancelCallback()
		}
		
		private function storageEvent(slotID:int, storageCallback:Function):void 
		{
			Post.send({
				ctr		:this.type,
				act		:'storage',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid,
				slotID	:slotID
			}, onStorageEvent, {
				callback:storageCallback
			});
		}
		
		private function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			_model.slots = Numbers.objectToArray(data.slots);
			updateSlots();
			params.callback()
			showIcon();
		}
		
		private function unlockEvent(slotID:int, unlockCallback:Function):void 
		{
			Post.send({
				ctr		:this.type,
				act		:'unlock',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid,
				slotID	:slotID
			}, onUnlockEvent, {
				callback:unlockCallback
			});
		}
		
		private function onUnlockEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			App.user.stock.takeAll(data.__take);
			_model.slots = Numbers.objectToArray(data.slots);
			updateSlots();
			params.callback()
		}
		
		private function boostEvent(slotID:int, boostCallback:Function):void 
		{
			Post.send({
				ctr		:this.type,
				act		:'boost',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid,
				slotID	:slotID
			}, onBoostEvent, {
				callback:boostCallback
			});
		}
		
		private function onBoostEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			App.user.stock.takeAll(data.__take);
			_model.slots = Numbers.objectToArray(data.slots);
			updateSlots();
			params.callback()
			showIcon();
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST) 
				return true;
			new CraftfloorsWindow({
				target:	this,
				model:	_model,
				find:	helpTarget
			}).show();
			return true;
		}
		
		private function changeSWF(level:int, effect:Boolean = true):void
		{
			if (level > Numbers.countProps(info.levels))
				level = Numbers.countProps(info.levels)
			/*if (textures) {
				stopAnimation();
			}
			if (effect)
			{
				_ltween = TweenLite.to(this, 1, { alpha:0.5, scaleX:0.5, scaleY:0.5, onComplete:function():void{
					Load.loading(Config.getSwf(info.type, info.levels[level].option.preview), onLoad);
				}});
				this.showGlowingOnce(0xfff000, 1);
			}
			else*/
				Load.loading(Config.getSwf(info.type, info.levels[level].option.preview), onLoad);
		}
		
		/*override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			
			_ltween = TweenLite.to(this, 1, { alpha:1, scaleX:1, scaleY:1})
			if (_ltween && _ltween.active)
			{
				_ltween.kill();
				_ltween = null
			}
		}*/
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			_model.toThrow = data.toThrow;
			_model.slots = Numbers.objectToArray(data.slots);
			_model.craftList = Numbers.objectToArray(data.crafts);
			updateSlots();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			_model.toThrow = data.toThrow;
			_model.slots = Numbers.objectToArray(data.slots);
			_model.craftList = Numbers.objectToArray(data.crafts);
			updateSlots();
		}
		
	}

}