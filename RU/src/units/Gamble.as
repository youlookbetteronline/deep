package units
{
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.Cloud;
	import ui.Cursor;
	import ui.UnitIcon;
	import wins.GambleWindow;
	import wins.RouletteWindow;
	import wins.Window;
	
	public class Gamble extends Golden
	{
		public var played:uint = 0;
		
		public static const LOTTERY:int = 477;
		
		public function Gamble(object:Object)
		{
			played = object.played || 0;			
			super(object);
			touchableInGuest = false;
			transable = true;
			//multiple = true;
			stockable = false;
			touchable = true;
			moveable = true;
			tip = function():Object {
				
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379911")
					}
				
			}
		}
		
		override public function set touch(touch:Boolean):void 
		{
			super.touch = touch;
		}
		
		public override function init():void
		{			
			if (formed)
			{
				if (played < App.midnight)//Значит играли вчера
				{
					tribute = true;
				}else{
					tribute = false;
					App.self.setOnTimer(work);
				}	
			}
			
			findCloudPosition();
		}
		
		
		override public function work():void
		{
			if (App.time > App.nextMidnight)
			{
				App.self.setOffTimer(work);
				tribute = true;
			}
			
		}
		
		override public function set tribute(value:Boolean):void 
		{
			_tribute = value;
			
			//if (_tribute&&App.user.mode == User.OWNER)
			//{
				showIcon();
			//}
			//else
			//{
				//clearIcon();
			//}
		}
		
		override public function onAfterBuy(e:AppEvent):void
		{
			super.onAfterBuy(e);			
			tribute = true;			
			findCloudPosition();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			started = App.time;
			
			created = App.time + App.data.storage[sid].time;
			crafted = App.time + App.data.storage[sid].time;
			
			beginCraft(0, crafted);
			
			initAnimation();
			beginAnimation();
			
			tribute = true;
			findCloudPosition();
		}
		
		override public function onLoad(data:*):void 
		{
			
			super.onLoad(data);
			
			if (played < App.midnight)//Значит играли вчера
			{
				tribute = true;
			}else{
				tribute = false;
				App.self.setOnTimer(work);
			}
			
			findCloudPosition();
		}
		
		override public function click():Boolean
		{
			if (!clickable || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			App.tips.hide();
			
			if (App.user.mode == User.OWNER)
			{		
				if (sid == 1200){
					new GambleWindow( {
						target:this,
						onPlay:playEvent
					}).show();
				}
				else
					new RouletteWindow({sID: this.sid, id: this.id}).show();
			}
			
			return true;
		}
		
		override public function showIcon():void {
			if (!formed || !open) return;
			
			if (cloudPositions.hasOwnProperty(App.data.storage[sid].view) ) 
			{
				coordsCloud.x = cloudPositions[App.data.storage[sid].view].x;
				coordsCloud.y = cloudPositions[App.data.storage[sid].view].y;
			}else{
				this.textures
				coordsCloud.x = 0;
				coordsCloud.y = -0;
			}
			
			if (App.user.mode == User.GUEST && touchableInGuest) {
				
				clearIcon();
			}
			
			if (App.user.mode == User.OWNER) 
			{
				
				if (true) 
				{
					var _view:int = Numbers.firstProp(info.materialskip).key;
					//App.data.storage[sid].view
					/*if(info.hasOwnProperty('shake') && info.shake!="")
						for (var shake:* in App.data.treasures[info.shake][info.shake].item)
							if (App.data.storage[App.data.treasures[info.shake][info.shake].item[shake]].mtype != 3 &&
								App.data.treasures[info.shake][info.shake].probability[shake] == 100){	
									
									_view = App.data.treasures[info.shake][info.shake].item[shake];
									break;
							}*/
					
							
					drawIcon(UnitIcon.REWARD, _view, 1, {
						glow:		true
					}, 0, coordsCloud.x, coordsCloud.y);
				}
			}
		}
		
		private var paid:uint = 0;
		private var onPlayed:Function;
		
		public function playEvent(paid:int, onPlayed:Function):void
		{			
			this.onPlayed = onPlayed;
			this.paid = paid;
			
			if (paid > 0)
			{
				if (!App.user.stock.take(Numbers.firstProp(info.materialskip).key, Numbers.firstProp(info.materialskip).val))
				{					
					return;
				}
			}
			
			storageEvent();
		}
		
		override public function storageEvent():void
		{
			if (App.user.mode == User.OWNER)
			{				
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					paid:1
				}, onStorageEvent);
				
				tribute = false;
			}
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (!(multiple && App.user.stock.check(sid)))
			{
				App.map.moved = null;
			}
			
			this.id = data.id;			
			tribute = true;
			
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void
		{			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			ordered = false;
			
			if (data.hasOwnProperty('played'))
			{
				this.played = data.played;
			}
			
			if (onPlayed != null) onPlayed(data.bonus);
		}
		
		override public function findCloudPosition():void
		{
			switch(info.view) 
			{
				case 'lottery':
						setCloudPosition(0, -130);
					break;
				case 'crupie':
						setCloudPosition(20, -100);
				break;
				case 'wheel_of_fortune':
						setCloudPosition(10, -60);
				case 'fortune_sphere':
						setCloudPosition(10, -60);
				break;
				case 'girl_raarrr':
						setCloudPosition(20, -50);
				break;
			}
		}
		
		override public function putAction():void
		{			
			/*if (!stockable)
			{
				return;
			}
			
			
			if (sid == LOTTERY) 
			{
				return;
			}*/
			if (!stockable)
			{
				return;
			}
			uninstall();
			App.user.stock.add(sid, 1);
			
			Post.send( {
				ctr: this.type,
				act: 'put', 
				uID: App.user.id, 
				wID: App.user.worldID, 
				sID: this.sid, id: this.id,
				level: level
			},function(error:int, data:Object, params:Object):void{});
		}
	}
}