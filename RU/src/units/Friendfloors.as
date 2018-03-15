package units 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import models.FriendfloorsModel;
	import ui.UnitIcon;
	import wins.FriendfloorsWindow;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class Friendfloors extends Decor 
	{
		private var _model:FriendfloorsModel
		private var _ltween:TweenLite;
		private var _rtween:TweenLite;

		public function Friendfloors(object:Object) 
		{
			super(object);
			initModel(object);
			multiple = false;
			changeSWF(_model.floor, false);
			showIcon();
			startWork();
			tip = function():Object{
				return parseTips();
			}
			stockable = false;
		}
		
		private function initModel(params:Object):void 
		{
			_model = new FriendfloorsModel();
			_model.floor = params.floor || 1;
			_model.kicks = params.kicks || 0;
			_model.crafted = params.crafted || 0;
			_model.lifetime = params.lifetime || 0;
			_model.mkickCallback = mkickEvent;
			_model.fkickCallback = fkickEvent;
			_model.fakefkickCallback = fakefkickEvent;
			_model.growCallback = growEvent;
			_model.totalFloor = Numbers.countProps(info.levels);
			_model.friends = params.friends || {};
			_model.freeze = params.died || false;
			if (params.toThrow)
				_model.toThrow = params.toThrow;
		}
		
		private function parseTips():Object{	
			if (App.user.mode == User.GUEST)
			{
				return{
					title:		info.title,
					text:		Locale.__e('flash:1510065817374')
				}
			}
			else if (_model.freeze)
			{
				return{
					title:		info.title,
					text:		Locale.__e('flash:1515061892747')
				}
			}
			else if (_model.floor > _model.totalFloor && info.faction == FriendfloorsModel.GOLDEN)
			{
				var craftedTime:int 	= _model.crafted - App.time;		//Время до сбора награды
				var lifetime:int 		= _model.lifetime - App.time;		//Время до смерти
				if (info.hasOwnProperty('lifetime') && info.lifetime != '')
				{
					if (lifetime > 0)
					{
						if (craftedTime > 0)
						{
							return {
								title:		info.title,
								text:		Locale.__e("flash:1382952379839"),
								timerText: 	TimeConverter.timeToDays(craftedTime),
								desc: 		Locale.__e('flash:1491818748419'),
								timerText2: TimeConverter.timeToDays(lifetime),
								timer:true
							};
						}
						else
						{
							return{
								title:		info.title,
								text:		Locale.__e("flash:1382952379966") + '\n' + Locale.__e('flash:1491818748419') + '\n',
								timerText:	TimeConverter.timeToDays(lifetime),
								timer:		true
							}
						}
					}
					else
					{
						if (craftedTime > 0)
						{
							return{
								title:		info.title,
								text:		Locale.__e('flash:1510740444771') + '\n' + Locale.__e("flash:1382952379839") + '\n',
								timerText: 	TimeConverter.timeToDays(craftedTime),
								//desc:		Locale.__e('flash:1510740444771'),
								timer:		true
							}
						}
						else
						{
							return{
								title:		info.title,
								text:		Locale.__e("flash:1382952379966") + '\n' + Locale.__e('flash:1510740444771') + '\n'
							}
						}
					}
				}
				else
				{
					if (_model.crafted > App.time)
					{
						return {
							title:		info.title,
							text:		Locale.__e("flash:1382952379839"),
							timerText: 	TimeConverter.timeToDays(craftedTime),
							timer:true
						}
					}
					else
					{
						return{
							title:		info.title,
							text:		Locale.__e("flash:1382952379966")
						}
					}
				}
				
			}
			else
				return{
						title:		info.title,
						text:		info.description
					}	
		}
		
		override public function click():Boolean 
		{
			if (_model.freeze)
				return false;
			if (_model.floor > _model.totalFloor && info.faction == FriendfloorsModel.GOLDEN)
			{
				if (_model.crafted > App.time)
					return false;
				
				storageEvent();
				return true;
			}
			return openWindow();
		}
		
		private function startWork():void 
		{
			if (_model.freeze)
				return;
			if (_model.floor <= _model.totalFloor)
				return;
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
			_model.crafted = App.time;
			showIcon();
		}
		
		private function openWindow():Boolean 
		{
			if (_model.freeze || App.user.mode == User.GUEST)
				return false;
			new FriendfloorsWindow({
				target:	this,
				model:	_model
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
					Load.loading(Config.getSwf(info.type, info.levels[level].req.preview), onLoad);
				}});
				this.showGlowingOnce(0xfff000, 1);
			}
			else*/
				Load.loading(Config.getSwf(info.type, info.levels[level].req.preview), onLoad);
		}
		
		//override public function onLoad(data:*):void 
		//{
			//super.onLoad(data);
			
			/*_ltween = TweenLite.to(this, 1, { alpha:1, scaleX:1, scaleY:1})
			if (_ltween && _ltween.active)
			{
				_ltween.kill();
				_ltween = null
			}*/
		//}
		
		private function mkickEvent(mID:int, typeMkick:String, mkickCallback:Function):void 
		{
			Post.send({
				ctr		:this.type,
				act		:'mkick',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid,
				type	:typeMkick
			}, onMkickEvent, {
				mkickCallback:mkickCallback
			});
		}
		
		private function onMkickEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				//Errors.show(error, data);
				return;
			}
			_model.kicks = data.kicks  
			App.user.stock.takeAll(data.__take)
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			params.mkickCallback();
		}
		
		private function fkickEvent(fID:String, callbackFunc:Function):void 
		{
			Post.send({
				ctr		:this.type,
				act		:'fkick',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid,
				fID		:fID
			}, onFkickEvent, {
				callback: callbackFunc
			});
		}
		
		private function onFkickEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			_model.friends = data.friends  
			App.user.stock.takeAll(data.__take);
			_model.window.contentChange();
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			params.callback();
		}
		
		private function fakefkickEvent(ffID:int, callbackFunc:Function):void 
		{
			Post.send({
				ctr		:this.type,
				act		:'fakefkick',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid,
				ffID	:ffID
			}, onFakefkickEvent, {
				callback: callbackFunc
			});
		}
		
		private function onFakefkickEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			_model.friends = data.friends  
			App.user.stock.takeAll(data.__take);
			_model.window.contentChange();
			params.callback();
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
				Errors.show(error, data);
				return;
			}
			showIcon()
			Window.closeAll()
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			if (data.died)
			{
				if (info.faction == FriendfloorsModel.DECOR)
				{
					_model.freeze = true;
					showIcon();
				}
				else if (data.hasOwnProperty('id'))
				{
					uninstall();
					var type:String = 'units.' + App.data.storage[info.emergent].type;
					var classType:Class = getDefinitionByName(type) as Class;
					var unit:Unit = new classType({ id:data.id, sid:info.emergent, x:coords.x, z:coords.z});
					unit.take();
				}
				else
					removeUnit();
				return;	
			}
			if (data.floor)
				_model.floor = data.floor  
			if (data.crafted)
				_model.crafted = data.crafted;  
			if (data.lifetime)
				_model.lifetime = data.lifetime;  
			showIcon();
			startWork();
			clearBmaps = true
			changeSWF(_model.floor);
		}
		
		private function storageEvent():void 
		{
			Post.send({
				ctr		:this.type,
				act		:'storage',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid
			}, onStorageEvent);
		}
		
		private function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			//
			
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			if (data.crafted)
				_model.crafted = data.crafted;
			if (info.hasOwnProperty('lifetime') && info.lifetime != '')
			{
				if (data.died)
				{
					_model.freeze = true;
				}
			}
			startWork();
			showIcon();
			
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			_model.toThrow = data.toThrow;
			showIcon();
			startWork();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			_model.toThrow = data.toThrow;
			showIcon();
			startWork();
		}
		
		private function removeUnit():void 
		{
			showGlowingOnce(0xfff000, 2)
			_rtween = TweenLite.to(this, 2, { alpha:1, scaleX:0.1, scaleY:0.1, onComplete:function():void{
				removable = true;
				uninstall();
				if (_rtween && _rtween.active)
				{
					_rtween.kill();
					_rtween = null
				}
			}});
		}
		
		private function showIcon():void
		{	
			if (!World.zoneIsOpen(App.map._aStarNodes[this.coords.x][this.coords.z].z))
				return;
			clearIcon()
			if (_model.freeze)
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
			
			if (_model.floor > _model.totalFloor && info.faction == FriendfloorsModel.GOLDEN)
			{
				if (_model.crafted > App.time)
				{
					clearIcon();
					return;
				}
				var _view:int = 2192;
				if(info.hasOwnProperty('treasure') && info.treasure!="")
					for (var shake:* in App.data.treasures[info.treasure][info.treasure].item)
						if (Treasures.onlySystemMaterials(info.treasure))
						{
							if (App.data.treasures[info.treasure][info.treasure].probability[shake] == 100)
								_view = App.data.treasures[info.treasure][info.treasure].item[shake]
						}
						else if (App.data.storage[App.data.treasures[info.treasure][info.treasure].item[shake]].mtype != 3 &&
							App.data.treasures[info.treasure][info.treasure].probability[shake] == 100){	
								_view = App.data.treasures[info.treasure][info.treasure].item[shake];
								break;
						}
						
				drawIcon(UnitIcon.REWARD, _view, 1, {
					glow:		true
				}, 0, coordsCloud.x, coordsCloud.y);
			}
			else
			{
				drawIcon(UnitIcon.FRIENDS, 1, 1, {
					glow:		true
				}, 0, coordsCloud.x, coordsCloud.y);
			}
		}
		
		override public function applyFilter(colour:uint = 0xeff200):void 
		{
			super.applyFilter(colour);
			//startAnimation();
		}
		
		public function get model():FriendfloorsModel 
		{
			return _model;
		}
		
		public function set model(value:FriendfloorsModel):void 
		{
			_model = value;
		}
		
		
	}

}