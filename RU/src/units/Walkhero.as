package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.geom.Point;
	import models.WalkheroModel;
	import ui.UnitIcon;
	import wins.SimpleWindow;
	import wins.SpeedWindow;
	import wins.UpgradeWindow;
	import wins.WalkheroWindow;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class Walkhero extends Techno 
	{
		private var _model:WalkheroModel;
		private var _upTween:TweenLite;
		private var _downTween:TweenLite;
		public function Walkhero(object:Object) 
		{
			super(object);
			initModel(object);
			tip = function():Object{
				return parseTips();
			}
			load();
			showIcon();
			if(this.info && this.info.config){
				var unitConfig:Array = String(this.info.config).split('').reverse();
				for (var configID:int = 0; configID < unitConfig.length; configID++ ) {
					if (unitConfig[configID] == "1" && this.hasOwnProperty(App.map.CONFIG_DATA[configID])) {
						this[App.map.CONFIG_DATA[configID]] = false;
					}
				}
			}
		}
		
		private function initModel(params:Object):void 
		{
			_model = new WalkheroModel();
			_model.level = params.level || 0;
			_model.expired = params.expired || 0;
			_model.crafted = params.crafted || App.time;
			_model.totalLevel = Numbers.countProps(info.levels);
			_model.upgradeParams = _model.level < _model.totalLevel ? info.levels[_model.level + 1] : null;
			_model.upgradeCallback = upgradeEvent;
			_model.storageCallback = storageEvent;
			if (params.died)
				_model.freeze = true;
			App.self.setOnTimer(work);
			
			
		}
		
		private function parseTips():Object{
			if (_model.freeze)
			{
				return{
						title:info.title,
						text:info.description
					}
			}
			if (_model.level < _model.totalLevel)
			{
				return{
					title:		info.title,
					text:		Locale.__e('flash:1511968517450')
				}
			}
			else if (_model.crafted > App.time && info.lifetime)
			{
				var lastTime:int = _model.expired - App.time;
				if (info.downgrade)
				{
					if (lastTime > 0)
					{
						return{
							title:		info.title,
							text:		info.description + '\n' + '\n' + Locale.__e("flash:1382952379839") + '\n',
							timerText:	TimeConverter.timeToDays(_model.crafted - App.time),
							desc: 		info.downgradetext,
							timerText2: TimeConverter.timeToDays(lastTime),
							timer:		true
						}
					}
					else
					{
						return{
							title:		info.title,
							text:		info.description + '\n' + '\n' + Locale.__e('flash:1510741250260') + ' ' + Locale.__e("flash:1382952379839") + '\n',
							timerText:	TimeConverter.timeToDays(_model.crafted - App.time),
							timer:		true
						}
					}
				}
				else
				{
					if (lastTime > 0)
					{
						return{
							title:		info.title,
							text:		info.description + '\n' + '\n' + Locale.__e("flash:1382952379839") + '\n',
							timerText:	TimeConverter.timeToDays(_model.crafted - App.time),
							desc: 		Locale.__e('flash:1491818748419'),
							timerText2: TimeConverter.timeToDays(lastTime),
							timer:		true
						}
					}
					else
					{
						return{
							title:		info.title,
							text:		info.description + '\n' + '\n' + Locale.__e('flash:1510741250260') + ' ' + Locale.__e("flash:1382952379839") + '\n',
							timerText:	TimeConverter.timeToDays(_model.crafted - App.time),
							timer:		true
						}
					}
				}
				
				
			}
			else if (_model.crafted > App.time)
			{
				return{
					title:		info.title,
					text:		info.description + '\n' + '\n' + Locale.__e("flash:1382952379839") + '\n',
					timerText:	TimeConverter.timeToDays(_model.crafted - App.time),
					timer:		true
				}
			}
			else
			{
				if (info.lifetime)
				{
					var _lastTime:int = _model.expired - App.time;
					if (info.downgrade)
					{
						if (_lastTime > 0)
						{
							return{
								title:		info.title,
								text: 		Locale.__e("flash:1382952379966") + ' ' + info.downgradetext,
								timerText: 	TimeConverter.timeToDays(_lastTime),
								timer:		true
							}
						}
						else
						{
							return{
								title:		info.title,
								text:		info.description + '\n' + '\n' + Locale.__e('flash:1510741250260')
							}
						}
					}
					else
					{
						if (_lastTime > 0)
						{
							return{
								title:		info.title,
								text: 		Locale.__e("flash:1382952379966") + ' ' + info.description,
								timerText: TimeConverter.timeToDays(_lastTime),
								timer:		true
							}
						}
						else
						{
							return{
								title:		info.title,
								text:		info.description + '\n' + '\n' + Locale.__e('flash:1510741250260')
							}
						}
					}
				}
				else
				{
					return{
						title:info.title,
						text:Locale.__e("flash:1382952379966")
					}
				}
			}
		}
		
		override public function click():Boolean 
		{
			
			if (App.user.useSectors)
			{
				var node1:AStarNodeVO = App.map._aStarNodes[this.coords.x][this.coords.z];
				
				if (!node1.sector.open)
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1495607052980') + " " + info.title,
						confirm:function():void
						{
							node1.sector.fireNeiborsReses();
						}
					}).show();
					return false;
				}
			}
			if (_model.freeze)
				return false;
			if (_model.level < _model.totalLevel)
			{
				new UpgradeWindow({
					target:	this,
					content:Numbers.objectToArraySidCount(_model.upgradeParams.require)
				}).show()
			}
			else
			{
				if (_model.crafted <= App.time)
					_model.storageCallback();
				else
				{
					new SpeedWindow( {
						title			:info.title,
						priceSpeed		:info.speedup,
						target			:this,
						info			:info,
						finishTime		:_model.crafted,
						totalTime		:info.time,
						doBoost			:onBoostEvent,
						btmdIconType	:info.type,
						btmdIcon		:info.preview
					}).show();
				}
			}
			return true;
		}
		
		private function work():void 
		{
			if (App.time >= _model.crafted)
			{
				App.self.setOffTimer(work);
				showIcon();
			}
		}
		
		override public function load():void 
		{
			if (preloader) addChild(preloader);
			var view:String = _model.level == 0?info.view:info.levels[_model.level].options.preview;
			Load.loading(Config.getSwf(info.type, view), onLoad);
		}
		
		override public function onLoad(data:*):void 
		{
			textures = data;
			getRestAnimations();
			addAnimation();
			createShadow();
			
			if (!open && formed) 
				applyFilter();
			
		}
		
		private function changeLevel():void 
		{
			var self:Walkhero = this;
			var view:String = _model.level == 0?info.view:info.levels[_model.level].options.preview;
			Load.loading(Config.getSwf(info.type, view), function(data:*):void {
				self.textures = data;
			});
		}
		
		private function onDownEvent(data:*):void 
		{
			textures = data;
			getRestAnimations();
			addAnimation();
			createShadow();
			if (!open && formed) 
				applyFilter();
				
			_downTween = TweenLite.to(this, 1, { x:this.x, y:this.y + 100, scaleX: 1, scaleY: 1, alpha: 1})
			if (_downTween && _downTween.active)
			{
				_downTween.kill();
				_downTween = null
			}
		}
		
		private function upgradeEvent():void
		{
			Post.send({
				ctr	:this.type,
				act	:'upgrade',
				uID	:App.user.id,
				id	:this.id,
				wID	:App.user.worldID,
				sID	:this.sid
			}, onUpgradeEvent)
		}
		
		private function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
				return;
			Window.closeAll();
			App.user.stock.takeAll(data.__take);
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			_model.level = data.level;
			if (data.expired)
				_model.expired = data.expired;
			_model.upgradeParams = _model.level < _model.totalLevel ? info.levels[_model.level + 1] : null;
			changeLevel();
			showIcon()
		}
		
		private function onBoostEvent(count:int = 0):void 
		{
			if (App.user.stock.take(Stock.FANT, info.speedup)) 
			{
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) 
					{
						_model.crafted = App.time;
					}
					App.ui.upPanel.update();
					App.self.setOnTimer(work);
					showIcon();
				});	
			}
		}
		
		override public function storageEvent():void
		{
			Post.send({
				ctr	:this.type,
				act	:'storage',
				uID	:App.user.id,
				id	:this.id,
				wID	:App.user.worldID,
				sID	:this.sid
			}, onStorageEvent)
		}
		
		private function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
				return;
			_model.crafted = data.crafted;
			if (data.hasOwnProperty('level'))
			{
				_model.level = data.level;
				_model.upgradeParams = _model.level < _model.totalLevel ? info.levels[_model.level + 1] : null;
				changeLevel();
			}
			if (data.bonus)
			{
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
				SoundsManager.instance.playSFX('bonus');
			}
			
			if (data.died)
			{
				_model.freeze = true;
				clearIcon();
				return;
			}
			App.self.setOnTimer(work);
			showIcon();
		}
		
		override public function applyFilter(colour:uint = 0xeff200):void 
		{
			super.applyFilter(colour);
			showIcon();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			_model.level = data.level;
			if (data.expired)
				_model.expired = data.expired;
			changeLevel();
			showIcon();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			_model.level = data.level;
			if (data.expired)
				_model.expired = data.expired;
			changeLevel();
			showIcon();
		}
		
		
		override public function showIcon():void
		{
			clearIcon();
			if (App.user.mode != User.OWNER || _model.freeze)
				return;
				
			if (!World.zoneIsOpen(App.map._aStarNodes[this.coords.x][this.coords.z].z))
				return;
				
			if (cloudPositions.hasOwnProperty(App.data.storage[sid].view) ) 
			{
				coordsCloud.x = cloudPositions[App.data.storage[sid].view].x;
				coordsCloud.y = cloudPositions[App.data.storage[sid].view].y;
			}else{
				if (App.data.storage[sid].hasOwnProperty('cloudoffset') && 
				(App.data.storage[sid]['cloudoffset'].dx != 0 || App.data.storage[sid]['cloudoffset'].dy != 0))
				{
					coordsCloud.x = App.data.storage[sid]['cloudoffset'].dx;
					coordsCloud.y = App.data.storage[sid]['cloudoffset'].dy;
				}else{
					coordsCloud.x = 0;
					coordsCloud.y = -50;
				}
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
						
			if (_model.level < _model.totalLevel)
			{
				drawIcon(UnitIcon.WALKHERO, 1, 1, {
						glow:		true,
						iconScale: .1
					}, 0, coordsCloud.x, coordsCloud.y);
			}
			else if (_model.crafted <= App.time)
			{
				
				drawIcon(UnitIcon.REWARD, _view, 1, {
					glow:		true
				}, 0, coordsCloud.x, coordsCloud.y);
			}
			else
			{
				drawIcon(UnitIcon.PRODUCTION, _view, 0, 
				{
					iconScale:	0.7,
					progressBegin:	_model.crafted - info.time,
					progressEnd:	_model.crafted
				}, 0, coordsCloud.x, coordsCloud.y);
			}

			
		}
		
		public function get model():WalkheroModel{return _model;}
		public function set model(value:WalkheroModel):void{_model = value;}
		
		
	}

}