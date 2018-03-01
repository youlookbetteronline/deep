package units 
{
	import com.greensock.TweenLite;
	import core.Post;
	import core.TimeConverter;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import models.BeastModel;
	import ui.UnitIcon;
	import wins.BeastWindow;
	import wins.SimpleWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Beast extends Techno 
	{
		private var _model:BeastModel;
		private var _deathTimeout:uint = 3;
		
		public function Beast(object:Object) 
		{
			super(object);
			initModel(object)	
			removable = true;
			showIcon();
			startWork();
			tip = function():Object{
				return parseTips();
			}
			touchableInGuest = true;
		}
		
		override public function remove(_callback:Function = null):void
		{
			if (!removable || App.user.mode != User.OWNER)
				return;
			var callback:Function = _callback;
			if (applyRemove == false && App.user.mode == User.OWNER)
			{
				onApplyRemove(callback)
			}
			else{
				new SimpleWindow( {
					title: Locale.__e("flash:1382952379842"),
					text: Locale.__e("flash:1382952379968", [info.title]),
					label: SimpleWindow.ATTENTION,
					dialog: true,
					confirm: function():void {
						onApplyRemove(callback);
					}
				}).show();
			}
		}
		
		private function initModel(params:Object):void 
		{
			_model = new BeastModel();
			_model.maxTime = info.maxtime;
			if (params.beastName)
				_model.beastName = params.beastName;
			else
				_model.beastName = info.beastname;
			if (params.crafted)
				_model.crafted = params.crafted;
			if (params.expire)
				_model.expire = params.expire;
			if (params.toThrow)
				_model.toThrow = params.toThrow;
			if (_model.crafted <= App.time)
				_model.tribute = true;
			_model.storageCallback = storageEvent;
			_model.throwCallback = throwEvent;
			_model.renameCallback = renameAction;
			_model.maxLengthName = 10;
		}
		
		private function parseTips():Object{
			var craftedTime:uint 	= _model.crafted - App.time;	//Время до сбора награды
			var expireTime:uint 	= _model.expire - App.time;		//Время до смерти
			if (App.user.mode == User.GUEST)
			{
				return{
					title:		_model.beastName,
					text:		Locale.__e('flash:1510065817374')
				}
			}
			if (_model.tribute && _model.expire < App.time)
			{
				return{
					title:		_model.beastName,
					text:		Locale.__e("flash:1382952379966") + '\n' + Locale.__e('flash:1510740444771') + '\n'
				}
				
			}
			else if (_model.tribute)
			{
				return{
					title:		_model.beastName,
					text:		Locale.__e("flash:1382952379966") + '\n' + Locale.__e('flash:1491818748419') + '\n',
					timerText:	TimeConverter.timeToDays(expireTime),
					timer:		true
				}
				
			}
			else if (!_model.tribute && _model.expire < App.time)
			{
				return{
					title:		_model.beastName,
					text:		Locale.__e('flash:1510740444771') + '\n' + Locale.__e("flash:1382952379839") + '\n',
					timerText: 	TimeConverter.timeToDays(craftedTime),
					//desc:		Locale.__e('flash:1510740444771'),
					timer:		true
				}
				
			}
			else
			{
				return {
					title:		_model.beastName,
					text:		Locale.__e("flash:1382952379839"),
					timerText: 	TimeConverter.timeToDays(craftedTime),
					desc: 		Locale.__e('flash:1491818748419'),
					timerText2: TimeConverter.timeToDays(expireTime),
					timer:true
				};
			}
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST)
			{
				//saySomething(0xfffef4, 0x123b65, 'Привет, меня зовут ' + _model.beastName)
				return false;
			}
			new BeastWindow({
				model:	_model,
				target:	this
			}).show();
			return true;
		}
		
		private function startWork():void 
		{
			App.self.setOnTimer(work);
		}
		
		private function work():void
		{
			if (App.time >= _model.crafted)
				onProductionComplete();
		}
		
		private function onProductionComplete():void
		{
			App.self.setOffTimer(work);
			_model.tribute = true;
			_model.crafted = App.time;
			showIcon();
		}
		
		override public function showIcon():void 
		{
			if (App.user.mode == User.GUEST){
				clearIcon();
				return;
			}
			initCoordsCloud();
			if (_model.tribute)
			{
				var _view:int = Stock.COINS;
				if(info.hasOwnProperty('shake') && info.shake!="")
					for (var shake:* in App.data.treasures[info.shake][info.shake].item)
						if (Treasures.onlySystemMaterials(info.shake))
						{
							if (App.data.treasures[info.shake][info.shake].probability[shake] == 100)
								_view = App.data.treasures[info.shake][info.shake].item[shake]
						}
						else if (App.data.storage[App.data.treasures[info.shake][info.shake].item[shake]].mtype != 3 &&
							App.data.treasures[info.shake][info.shake].probability[shake] == 100){	
								_view = App.data.treasures[info.shake][info.shake].item[shake];
								break;
						}		
						
				drawIcon(UnitIcon.REWARD, _view, 1, {
					glow:		true
				}, 0, coordsCloud.x, coordsCloud.y);
			}
		}
		
		override public function storageEvent():void
		{
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onStorageEvent);
		}
		
		private function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			if (data.died)
			{
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
				SoundsManager.instance.playSFX('bonus');
				clearIcon();
				uninstall();
				return;
			}
			_model.crafted = App.time + info.time;
			_model.tribute = false;
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			startWork();
			clearIcon();
		}
		
		public function throwEvent(typeThrow:String, throwCallback:Function):void
		{			
			Post.send({
				ctr	:this.type,
				act	:'throw',
				uID	:App.user.id,
				id	:this.id,
				wID	:App.user.worldID,
				sID	:this.sid,
				type:typeThrow
			}, onThrowEvent, {
				throwCallback:throwCallback
			});
		}
		
		public function onThrowEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			_model.expire = data.expire;
			_model.toThrow = data.toThrow;
			App.user.stock.takeAll(data.__take)
			params.throwCallback();
		}
		
		private function renameAction(beastName:String, renameCallback:Function):void
		{			
			Post.send({
				ctr	:this.type,
				act	:'rename',
				uID	:App.user.id,
				id	:this.id,
				wID	:App.user.worldID,
				sID	:this.sid,
				name:beastName
			}, onRenameAction, {
				renameCallback:	renameCallback
			});
		}
		
		private function onRenameAction(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			if (data.beastName)
				_model.beastName = data.beastName;
			params.renameCallback();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			if (data.expire)
				_model.expire = data.expire;
			if (data.toThrow)
				_model.toThrow = data.toThrow;
			startWork();
			goHome();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			if (data.expire)
				_model.expire = data.expire;
			if (data.toThrow)
				_model.toThrow = data.toThrow;
			startWork();
		}
		
		private function removeUnit():void
		{
			var place:Object = findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:coords.x, z:coords.z}}, 7);
			initMove(
				place.x,
				place.z
			);
			_deathTimeout = setTimeout(onUnitDeath, 3000);
			removable = true;
		}
		
		private function onUnitDeath():void
		{
			TweenLite.to(this, 2, { x:this.x, y:this.y, alpha: 0, onComplete: onApplyRemove});
			clearTimeout(_deathTimeout);
		}
		
	}

}