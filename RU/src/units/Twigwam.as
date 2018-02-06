package units 
{
	import core.IsoConvert;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.geom.Point;
	import ui.Hints;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.TechnoEquipWindow;
	import wins.TechnoSpeedWindow;
	/**
	 * ...
	 * @author 
	 */
	public class Twigwam extends Wigwam 
	{
		public var thisUnit:uint = 0;
		public var unit:TwigwamWorker;
		public var unitToMove:TwigwamWorker;
		public var equipWin:TechnoEquipWindow;
		
		private var _started:int = 0;
		private var buy:Boolean = false;
		
		public function Twigwam(object:Object) 
		{
			energy = App.data.storage[object.sid].energy || energy;
			animal = App.data.storage[object.sid].worker;
			
			var index:int = World.getBuildingCount(object.sid);
			
			if (Numbers.countProps(App.data.storage[object.sid].instance) > index + 1)
			{
				index = Numbers.countProps(App.data.storage[object.sid].instance) - 1;
			}
			price = App.data.storage[object.sid].instance[index];
			slaveCount = 1;//временно
			time = App.data.storage[object.sid].time;
			
			workerID = this.id;
			workerSID = animal;
			this.crafted = object.crafted;
			buy = object.buy;
			
			if (object.hasOwnProperty('id'))
			{
				this.id = object.id;
			}
			super(object);
		}
		
		public function get started():int 
		{
			return _started;
		}
		public function set started(value:int):void 
		{
			_started = value;
		}
		
		override public function buyAction(setts:*=null):void
		{
			if (!setts)
				setts = {};
			SoundsManager.instance.playSFX('build');
			
			var price:Object = Payments.itemPrice(sid);
			
			if (App.user.stock.takeAll(price)) {
				
				Hints.buy(this);
				
				if (info.hasOwnProperty('instance')) {
					var instances:int = World.getBuildingCount(sid);
				}
				
				
				var params:Object = {
					ctr:	this.type,
					act:	'buy',
					uID:	App.user.id,
					ac:		(ShopWindow.currentBuyObject.currency)?1:0,
					wID:	(setts.hasOwnProperty('wID'))?setts.wID:App.user.worldID,
					sID:	this.sid,
					iID:	instances,
					x:		coords.x,
					z:		coords.z
				};
				
				
				Post.send(params, onBuyAction);
				
				if (this.type == "Resource") 
				{
					this.open = true;
				}
			} else 
			{
				ShopWindow.currentBuyObject.type = null;
				ShopWindow.currentBuyObject.currency = null;
				uninstall();
			}
			
			isBuyNow = false;
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			//super.onStockAction(error, data, params);
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (this.hasOwnProperty('capacity'))
			{
				capacity = 5;	
			}
			
			level++;
			updateLevel();
			
			if (data.hasOwnProperty('id'))
			{
				this.id = data.id;
			}
			addWorker();
			
			workerID = this.id;
			workerSID = animal;
			this.unitToMove.lightUnit();
			addTip();
			
			var hasTechno:Boolean = false;
			var techno:Array = [];
			var reward:Object = info.outs;
			var _reward:Object = {};
			var worker_sid:int = animal;
			Treasures.bonus(Treasures.convert(_reward), new Point(this.x, this.y));
			
			//removeEffect();
			//openConstructWindow();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (this.hasOwnProperty('capacity'))
			{
				capacity = 5;	
			}
			
			level++;
			updateLevel();
			
			if (data.hasOwnProperty('id'))
			{
				this.id = data.id;
			}
			addWorker();
			
			workerID = this.id;
			workerSID = animal;
			this.unitToMove.lightUnit();
			addTip();
			
			var hasTechno:Boolean = false;
			var techno:Array = [];
			var reward:Object = info.outs;
			var _reward:Object = {};
			var worker_sid:int = animal;
			Treasures.bonus(Treasures.convert(_reward), new Point(this.x, this.y));
			
			removeEffect();
			openConstructWindow();
		}
		
		override public function onMoveAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				
				free();
				_move = false;
				placing(prevCoords.x, prevCoords.y, prevCoords.z);
				take();
				state = DEFAULT;
				
				//TODO мен¤ем координаты на старые
				return;
			}
			
			App.map._astar.reload();
			App.map._astarReserve.reload();

			var point:Object = IsoConvert.screenToIso(this.x, this.y, true);
			var placeMove:Object;	
			placeMove = findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:point.x, z:point.z}}, 3);
			var pointPlaceMove:Object = IsoConvert.isoToScreen(placeMove.x, placeMove.z, true);
			if (unit)
			{
				unit.x = pointPlaceMove.x;
				unit.y = pointPlaceMove.y;
			}
		}
		
		private function addWorker(coordsX:int = -10, coordsZ:int = -10):void{
			if (this.thisUnit != 0)
				return;
			
			var technoFree:Boolean;
			var _loc_2:* = IsoConvert.screenToIso(this.x, this.y, true);
			var place:Object;
			if (coordsX == -10 && coordsZ == -10)
			{	
				place = findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:coords.x, z:coords.z}}, 3);
				technoFree = false;
			}else
			{
				place = {x:coordsX, z:coordsZ};
				technoFree = true;
			}
			
			if (!place)
				return;
			
			unit = new TwigwamWorker( { id:this.id, sid:animal, x:place.x, z:place.z, baseX:_loc_2.x + this.rows+1, baseZ:_loc_2.z + this.cells+1, target: this, free: technoFree} );
			this.thisUnit = 1;
			this.unitToMove = unit;
			if (coordsX == -10 && coordsZ == -10)
			{
				unit.goHome();
			}
		}
		
		public function workerGoBeyond():void
		{
			this.unitToMove.goBeyond();
		}
		
		public function workerGoHome():void{
			if (unitToMove)
			{
				//unitToMove.applyRemove = false;
				unitToMove.uninstall();
				//unitToMove.alpha = 0
				//TweenLite.to(unitToMove, 2, {alpha: 0});
			}
				
			var place:Object = findPlaceNearTarget({info:{area:{w:this.cells, h:this.rows}}, coords:{x:this.coords.x, z:this.coords.z}}, 50);
			this.thisUnit = 0;
			this.addWorker(place.x, place.z);
			this.unitToMove.goesBeyond = true;
			this.unitToMove.goFromBeyond();
		}
		
		
		public function goSearch():void{
			App.self.setOnTimer(work);
			workerGoBeyond();
		}
		override public function onLoad(data:*):void
		{
			super.onLoad(data);
			
			if (finished == 0 && !buy)
			{
				if (animal != 0 && (crafted == 0 || hasProduct) && formed)
				addWorker();
			}
			checkProduction();
			
			updateLevel();
			if (clearBmaps)
			{
				Load.clearCache(Config.getSwf(type, info.view));
				data = null;
			}
		}
		
		public function work():void 
		{
			if (App.time >= crafted) 
			{
				App.self.setOffTimer(work);
				onProductionComplete();
			}
		}
		
		override public function onProductionComplete():void
		{
			hasProduct = true;
			crafting = false;
			crafted = 0;
			workerGoHome();
		}
		
		override public function showIcon():void 
		{
			
		}
		
		override public function onBoostEvent(count:int = 0):void 
		{
			if (App.user.stock.take(Stock.FANT, count)) 
			{
				
				crafted = App.time;
				started = crafted - info.time;
				
				var that:Twigwam = this;
				work();
				
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
						crafted = data.crafted;
					}
				});	
			}
		}
		
		override public function click():Boolean
		{
			if (App.user.mode == User.GUEST) {
				return false;
			}
			this.crafted;
			
			hidePointing();
			stopBlink();
			
			if (!isReadyToWork()) 
				return true;
			
			if (isProduct()) 
				return true;
				
			if (App.user.mode == User.OWNER)
			{
				var that:Twigwam = this;
				
				equipWin = new TechnoEquipWindow( {
					title:info.title,
					materials:App.data.storage[this.sid].require,
					busy:false,
					hasDescription:true,
					prodItem:this,
					target:this,
					wID:workerID,
					wSID:workerSID
				});
				
				equipWin.focusAndShow();
				return true;
			}
			
			return false;
		}
		
		override public function onApplyRemove(callback:Function = null):void
		{
			if (!removable)
				return;
			Post.send({ctr: this.type, act: 'remove', uID: App.user.id, wID: App.user.worldID, sID: this.sid, id: this.id}, onRemoveAction, {callback: callback});
			this.uninstall();
		}
		
		override public function checkProduction():void 
		{
			completed = [];
			
			if (crafted > 0)
			{
				if (crafted <= App.time) 
				{
					hasProduct = true;
				}
				else 
				{
					App.self.setOnTimer(work);
				}
			}
		}
		
		override public function isProduct():Boolean
		{
			if (hasProduct)
			{
				new SimpleWindow( {
					title:Locale.__e("flash:1474469531767"),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1475757458469',  App.data.storage[this.animal].title),
					confirm:function():void {
						unitToMove.lightUnit({focus:true}, 10);
					}
				}).show();
				unitToMove.showIcon();
				return true; 
			}
			return false;
		}
		
		override public function isReadyToWork():Boolean
		{
			if (crafted > App.time) 
			{
				new TechnoSpeedWindow( {
					title:Locale.__e("flash:1474469531767"),
					priceSpeed:info.speedup,
					target:this,
					info:info,
					finishTime:crafted,
					totalTime:App.data.storage[sid].time,
					doBoost:onBoostEvent,
					btmdIconType:App.data.storage[sid].type,
					btmdIcon:App.data.storage[sid].preview
				}).show();
				return false;	
				
			}	
			return true;
		}
		
		public function gatherProduct():void
		{
			var sendObject:Object = {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}
			
			Post.send(sendObject, onStorageEvent);
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (data.hasOwnProperty('bonus')) 
			{
				var that:* = this;
				Treasures.bonus(data.bonus, new Point(this.unitToMove.x, this.unitToMove.y));
			}
			hasProduct = false;
			crafted = 0;
		}
		
		override public function uninstall():void 
		{
			App.self.setOffTimer(work);
			//if (unitToMove)
				//unitToMove.uninstall();
			if (unitToMove)
				unitToMove = null;
			super.uninstall();
		}
		
	}

}