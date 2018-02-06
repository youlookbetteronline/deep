package units 
{
	import core.TimeConverter;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.UnitIcon;
	public class Booker extends Walkgolden 
	{
		public var played:uint = 0;
		public var playAllow:Boolean;
		public static const UNDINA_EXPENSIVE:uint = 1947;
		public static const UNDINA_CHEAP:uint = 1974;		
		
		public function Booker(object:Object) 
		{
			played = object.played || 0;
			super(object);	
			
			started = object.started;
			
			stockable = false;
			
			init();
		}
		
		public var smartTime:int;
		public var gameOver:Boolean = false;
		public function getTime():void 
		{	
			if (started + info.time <= App.time) 
			{
				smartTime = 0;	
				gameOver = true;
			}else {
				smartTime = started + info.time - App.time;
				gameOver = false;
			}
			
			
		}	
		
		public function init():void {
			if(formed){
				if (played < App.midnight) {// Значит играли вчера
					tribute = true;
					App.self.setOnTimer(getTime);
				}else{
					tribute = false;
					App.self.setOnTimer(work);
				}	
			}	
			
			App.self.setOnTimer(getTime);
			
			tip = function():Object {
				if (tribute && !gameOver)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379966") + '\n' + info.description + ' ' + Locale.__e('flash:1386855956497'),
						timerText: TimeConverter.timeToDays(smartTime),
						timer:true
					};
				}else if (gameOver) {
					return {
						title:info.title,
						text:Locale.__e("flash:1450689190253")
					};
				} else {
					return {
						title:info.title,
						text:info.description + ' ' + Locale.__e('flash:1386855956497'),
						timerText: TimeConverter.timeToDays(smartTime),
						timer:true
					};
				}
			}
		}	
		
		override public function click():Boolean 
		{			
			//if (wasClick) return false;
			
			if (App.user.mode == User.GUEST) {
				return true;
			}
			
			if (tribute) {
				storageEvent();
				return true;
			}
			
			return true;
		}
		
		override public function work():void
		{
			if (App.time > App.nextMidnight)
			{
				App.self.setOffTimer(work);
				tribute = true;
			}
		}
		
		override public function set tribute(value:Boolean):void {
			if (value)
			{
				playAllow = value;
			}
			else
			{
				playAllow = false;
			}
			
			/*setTimeout(function():void {
				showIcon();
			}, 3000)*/
			showIcon();
		}
		
		override public function get tribute():Boolean {
			return playAllow;
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			started = App.time;
			
			this.cell = coords.x; 
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			moveable = true;
			
			played = App.midnight - 10;
			tribute = true;
			
			open = true;
			
			//showIcon();
			
			setTimeout(function():void {
				showIcon();
			}, 3000)
			
			goHome();
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			ordered = false;
			
			if(data.hasOwnProperty('played')){
				this.played = data.played;
			}
			
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			
			if (/*started + info.time + 86400 < 0*/gameOver) {
				uninstall();
			}
		}
		
		override public function showIcon():void {
			if (!formed || !open) return;
			
			if (App.user.mode == User.GUEST && touchableInGuest) {
				{
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:false,
						iconDX:-40,
						iconDY:30
					});
				} 
			}
			
			if (App.user.mode == User.OWNER) {
				if (tribute) {
					drawIcon(UnitIcon.REWARD, Stock.FANT, 1, {
						glow:true,
						iconDX:-20,
						iconDY:0
					});
				}else {
					clearIcon();
				}
			}
		}
		
	}

}