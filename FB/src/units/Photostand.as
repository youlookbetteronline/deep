package units 
{
	import core.Load;
	import core.Numbers;
	import wins.PhotostandWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Photostand extends Decor 
	{
		public var slots:Object = new Object();
		public var die:Boolean = false
		public var totalLevel:int;
		public var level:int = 1;
		public function Photostand(object:Object) 
		{
			if (object.die && object.die == 1)
				this.die = true;
			super(object);
			this.totalLevel = Numbers.countProps(this.info.levels)
			this.slots = object.slots
			if (object.hasOwnProperty('level'))
				this.level = object.level
			multiple = false;
			stockable = false;
			info['dtype'] = 0;
			take();
			loadTextures();
		}
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST)
				return false;
			new PhotostandWindow({
				target	:this,
				callback:loadTextures
			}).show();
			return true;
		}
		
		private function loadTextures():void 
		{
			Load.loading(Config.getSwf(type, info.levels[level].preview), onLoad);
		}
		
	}

}