package  
{
	import flash.utils.Timer;
	import units.Field;
	import units.Personage;
	import units.Techno;
	/**
	 * ...
	 * @author 
	 */
	public class TargetManager
	{
		public static const FREE:int = 0;
		public static const BUSY:int = 1;
		public static const WORKING:int = 2;
		
		public var status:int = FREE;
		public var queue:Array = [];
		public var owner:Personage;
		
		private var _currentTarget:Object = null;
		
		public function TargetManager(_owner:Personage):void
		{
			owner = _owner;
		}
		
		public function add(targetObject:Object):void
		{
			if (targetObject.isPriority)
				queue.unshift(targetObject);
			else 
				queue.push(targetObject);
			
			if (targetObject.hasOwnProperty('priority'))
				call(targetObject.priority);
			else
				call();
			
		}
		
		public function get length():int {
			return queue.length;
		}
		
		public function get currentTarget():Object 
		{
			return _currentTarget;
		}
		
		public function set currentTarget(value:Object):void 
		{
			_currentTarget = value;
		}
		
		public function dispose():void {
			if (currentTarget == null||currentTarget.target == null) {
				return;
			}
			
			if (currentTarget.target.ordered) {
				currentTarget.target.ordered = false;
				currentTarget.target.worker = null;
				if (!currentTarget.target.formed) {
					currentTarget.target.uninstall();
				}
			}
			
			if (currentTarget.target.hasOwnProperty('reserved') && currentTarget.target.reserved > 0) {
				currentTarget.target.reserved = 0;
			}
			
			currentTarget = null;
			status = FREE;
			for each(var target:* in queue) {
				if (target.target.ordered) {
					target.target.ordered = false;
					target.target.worker = null;
					if (!target.target.formed) {
						target.target.uninstall();
					}
				}
				if (target.target.hasOwnProperty('reserved') && target.target.reserved > 0) {
					target.target.reserved = 0;
				}
			}
			queue = [];
		}
		
		public function call(priority:* = null):void
		{
			if (status == FREE || priority != null) {
				if (queue.length > 0){
					makeNext();
				}else{
					if (App.user.queue.length > 0)
					{
						for (var i:int = 0; i < App.user.queue.length; i++) 
					{
						if (owner is Techno) {
							if (App.user.queue[i].target is Field) {
							continue	
							}else 
							{
							queue = App.user.queue.splice(i, 1);	
							
							break
							}
							
						}else 
						{
						queue.push(App.user.queue.shift());	
						break	
						}
						
					}
						if (queue.length > 0) 
						{
							makeNext();
						}
						
					}
					if (currentTarget) 
					owner.beginLive();
				}
			}
		}
		
		private function makeNext():void
		{
			/*for (var i:int = 0; i < queue.length; i++) 
			{
				if (owner is Techno) {
					if (queue[i].target is Field) {
					continue	
					}else 
					{
					currentTarget = queue.splice(i, 1);	
					currentTarget = currentTarget[i];
					break
					}
					
				}else 
				{
				currentTarget = queue.shift();	
				break	
				}
				
			}*/
			
			currentTarget = queue.shift();	
			
			queue = queue.concat(App.user.takeTaskForTarget(currentTarget.target));
			if (owner.sid == 2 && currentTarget.target is Field)
			{
				currentTarget['event'] = Personage.GATHER; //TODO поменять костыль, пересобрав главного героя
			}
			var target:* 			= currentTarget.target;
			var jobPosition:Object 	= currentTarget.jobPosition;
			var callback:Function 	= currentTarget.callback;
			
			var cells:int 	= target.coords.x + jobPosition.x;
			var rows:int 	= target.coords.z + jobPosition.y;
			
			
			
			status = BUSY;
			
			target.worker = owner;
			if(!(owner.coords.x == cells && owner.coords.z == rows))
				owner.initMove(cells, rows, owner.onPathToTargetComplete);
			else
				owner.onPathToTargetComplete();
		}
		
		public function onTargetComplete():void
		{
			status = FREE;
			owner.framesDirection = currentTarget.jobPosition.direction;
			owner.framesFlip = currentTarget.jobPosition.flip;
			currentTarget.target.targetWorker = owner;
				
			currentTarget.callback();
		
			call();
		}	
		
		public function stop():void
		{
			queue = [];
			status = FREE;
		}
	}
}
