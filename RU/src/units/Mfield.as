package units {
	
	import core.Post;
	import wins.Window;
	import wins.WindowMegaField;
	public class Mfield extends Building {
		
		public static const STATUS_EMPTY:String = "Mfield.empty";
		public static const STATUS_GROWING:String = "Mfield.growing";
		public static const STATUS_READY:String = "Mfield.ready";
		
		private var _currentStatus:String;
		private var _pID:int;
		private var _count:int;
		private var _plantedTime:int;
		private var _title:String;
		public var _plant:MfieldPlant;
		
		public function Mfield(object:Object) {
			level = 1;
			super(object);
			_title = App.data.storage[sid].title;
			
			if (object.pID && (object.pID is int) && App.data.storage[object.pID]) {
				_pID = object.pID;
				_count = object.count;
				_plantedTime = object.planted;
				
				createPlant(_pID, _plantedTime);
			}
		}
		
		override public function click():Boolean {
			if (App.user.mode == User.OWNER) {
				new WindowMegaField({title:_title}, this).show();
			}
			
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			return true;
		}
		
		private function createPlant(pID:int, planted:int):void {
			_plant = new MfieldPlant({
				sid:pID,
				planted:planted,
				point:{x:-3, y:75},
				mfield:this
			});
			
			addChild(_plant);
		}
		
		private function removePlant():void {
			if (_plant && _plant.parent == this) {
				removeChild(_plant);
			}
		}
		
		private var _plantSuccessCallback:Function;
		public function plant(pID:int, count:int, callback:Function = null):void {
			Post.send({
				ctr:"Mfield",
				act:"plant",
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id,
				pID:pID,
				count:count
				}, plantCallback);
				
			_pID = pID;
			_count = count;
			
			_plantSuccessCallback = callback;
		}
		
		private function plantCallback(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				_pID = 0;
				_count = 0;
				_plantedTime = 0;
				
				return;
			}
			
			_plantedTime = App.time;
			
			var plant:Object = App.data.storage[_pID];
			
			if (_plantSuccessCallback != null) {
				_plantSuccessCallback();
			}
			
			createPlant(_pID, _plantedTime);
		}
		
		private var _harvestSuccessCallback:Function;
		public function harvest(callback:Function = null):void {
			Post.send({
				ctr:"Mfield",
				act:"harvest",
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id
			}, harvestCallback);
			
			_harvestSuccessCallback = callback;
		}
		
		private function harvestCallback(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			//var materialID:int = App.data.storage[pID].outs;
			for (var out:* in App.data.storage[pID].outs) {
				if (int(out) != Stock.EXP && int(out) != Stock.COINS && int(out) != Stock.FANTASY) {
					var materialID:int = int(out);
					break;
				}
			}
			
			if (_harvestSuccessCallback != null) {
				_harvestSuccessCallback();
			}
			
		//	App.user.stock.add(materialID, count);
			_pID = 0;
			_count = 0;
			_plantedTime = 0;
			
			removePlant();
		}
		
		private var _boostSuccessCallback:Function;
		public function boost(callback:Function = null):void {
			Post.send({
				ctr:"Mfield",
				act:"boost",
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id
			}, boostCallback);
			
			_plantedTime = 0;
			
			_boostSuccessCallback = callback;
		}
		
		private function boostCallback(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			_plantedTime = 0;
			_plant.level = _plant.info.levels;
			_plant.planted = 0;
			
			if (_boostSuccessCallback != null) {
				_boostSuccessCallback();
			}
		}
		
		public function get pID():int {
			return _pID;
		}
		
		public function get count():int {
			return _count;
		}
		
		public function get plantedTime():int {
			return _plantedTime;
		}
		
		public function get currentStatus():String {
			return _currentStatus;
		}
	}
}