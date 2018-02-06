package units 
{
	import core.Post;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.Hints;
	import wins.AnimalProgressWindow;
	import wins.FactoryWindow;
	import wins.FurryWindow;
	import wins.ProductionWindow;
	
	public class Factory extends Building {
		private var _isBoost:Boolean;
		
		public static const TECHNO_FACTORY:uint = 165;
		public static const TECHNO_FACTORY_2:uint = 166;
		public static const TECHNO_FACTORY_3:uint = 167;
		public static const ANIMAL_FACTORY:uint = 134;
		
		public static var waitForTarget:Boolean = false;
		/*public var _boostStarted:int;*/
		
		public function Factory(object:Object)
		{
			super(object);
			
			/*_boostStarted = object.boost;*/
			
			if (sid == TECHNO_FACTORY || sid == TECHNO_FACTORY_2 || sid == TECHNO_FACTORY_3) {
				removable = false;
				//removable = true;
			}else {
				info.ask = 1;
			}
			
			//if(sid == TECHNO_FACTORY && upgradedTime > 0){
				//cloudResource(true, Techno.TECHNO, isPresent, 'productBacking2', 0.6, true, upgradedTime - info.devel.req[level+1].t, upgradedTime);
				//startAnimation();
			//}
			/*if((sid == TECHNO_FACTORY || sid == TECHNO_FACTORY_2 || sid == TECHNO_FACTORY_3) && created > 0){
				cloudResource(true, Techno.TECHNO, isPresent, 'productBacking2', 0.6, true, created - info.devel.req[1].t, created);
				startAnimation();
			}*/
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			if (sid && checkCrafting()) return true;
			
			if (!isReadyToWork()) return true;
			
			if (isPresent()) return true;
			
			if (isProduct()) return true;
			
			var that:Factory = this;
			
			return true;
		}
		
		override public function isProduct():Boolean
		{
			if (hasProduct)
			{	
				storageEvent();
				return true; 
			}
			return false;
		}
		
		override public function storageEvent():void
		{
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fID:fID
			}, onStorageEvent);			
		}
		
		public static var spirit:Techno = null;
		public function addSpirit():void {
			if (App.user.quests.tutorial && this.id == 1) {
				spirit = new Techno({
					id:1,
					sid:Stock.TECHNO,
					x:28,
					z:76,
					spirit:1
				});
			}
		}
		
		private function checkCrafting():Boolean 
		{
			if (crafting) {
				new AnimalProgressWindow({
					title:info.title,
					target:this,
					info:info,
					endTime:crafted,
					pid:fID,
					sid:fID
				}).show();
				return true;
			}
			return false;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			
			openConstructWindow();
			
		}
		
		override public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			var hasTechno:Boolean = false;
			var techno:Array = [];
			var reward:Object = info.devel.rew[level];
			var _reward:Object = { };
			var worker_sid:int = Techno.TECHNO;
			
			for (var _sid:* in reward) {
				if (App.data.storage[_sid].type == 'Techno') {
					hasTechno = true;
					worker_sid = _sid;
				}else{
					_reward[_sid] = reward[_sid];
				}
			}
			
			Treasures.bonus(Treasures.convert(_reward), new Point(this.x, this.y));
			
			removeEffect();
			
			if (hasTechno)
				addChildrens(worker_sid, data.units);
			
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			ordered = false;
			crafting = false;
			
			fID = 0;
			crafted = 0;
			
			var that:* = this;
			spit(function():void{
				Treasures.bonus(data.bonus, new Point(that.x, that.y));
			}, bitmapContainer);
			
			var info:Object = App.data.storage[formula.out];
			if (info.type != 'Animal') return;
			
			addChildrens(formula.out, data.units);
		}
		
		private function addChildrens(_sid:uint, ids:Object):void 
		{
			var rel:Object = { };
			rel[sid] = id;
			var position:Object = getBornPosition();
			
			var unit:Unit;
			if (App.user.quests.tutorial && this.id == 1 && spirit != null) {
				unit = Unit.add( { sid:Techno.TECHNO, id:1, x:spirit.coords.x, z:spirit.coords.z, rel:rel } );
				(unit as WorkerUnit).born();
				return;
			}
			for (var i:* in ids){
				unit = Unit.add( { sid:_sid, id:ids[i], x:position.x, z:position.z, rel:rel } );
				(unit as WorkerUnit).born();
			}
		}
		
		
		private function getBornPosition():Object{
			return {
				x:coords.x + info.area.w,
				z:coords.z + info.area.h / 2 - 1
			}
		}
		
		override public function onApplyRemove(callback:Function = null):void
		{
			if (!removable) return;
			
			var bots:Array = findChildsTechno();
			for each(var bot:Techno in bots)
				bot.remove();
			
			super.onApplyRemove(callback);
		}
		
		public function findChildsTechno():Array 
		{
			var childs:Array = [];
			for each(var bot:* in App.user.techno) {
				if (bot.rel != null) {
					if (bot.rel[sid] != null && bot.rel[sid] == id)
						childs.push(bot);
				}
			}
			return childs;
		}
		
		override public function openProductionWindow():void {
			
			if (level == totalLevels || sid == TECHNO_FACTORY || sid == TECHNO_FACTORY_2 || sid == TECHNO_FACTORY_3)
				return;
				
			/*new ProductionWindow( {
				title:			info.title,
				crafting:		info.devel.craft,
				target:			this,
				onCraftAction:	onCraftAction,
				hasPaginator:	true,
				hasButtons:		true
			}).focusAndShow();*/
		}
		
		
		override public function upgraded(hasReset:Boolean = false):void {
			//if(sid == ANIMAL_FACTORY)updateProgress(upgradedTime - info.devel.req[level+1].t,upgradedTime);
			if (level < totalLevels - craftLevels)
				updateProgress(upgradedTime - info.devel.req[level+1].t,upgradedTime);
			if (isUpgrade()){
				App.self.setOffTimer(upgraded);
				
				
				
				hasPresent = true;
				finishUpgrade();
				this.level++;
				updateLevel();
				fireTechno();
				stopAnimation();
				//removeProgress();
			}
		}
		
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			if (error){
				Errors.show(error, data);
				return;
			}
			hasUpgraded = false;
			upgradedTime = data.upgrade;
			App.self.setOnTimer(upgraded);
			//if (sid == ANIMAL_FACTORY) {
				//addProgressBar();
			//}else {
		
			if(level >= totalLevels - craftLevels){
				//cloudResource(true, Techno.TECHNO, isPresent, 'productBacking2', 0.6, true, upgradedTime - info.devel.req[level+1].t, upgradedTime);
				startAnimation();
			}else {
				//addProgressBar();
			}
			//}
		}
		
		override public function setCraftLevels():void
		{
			for each(var obj:* in info.devel.rew) {
				for (var _sid:* in obj) {
					if(_sid == Techno.TECHNO){
						craftLevels++;
						break;
					}
				}
			}
		}
		
		/*override public function finishUpgrade():void
		{
			super.finishUpgrade();
			if (App.user.quests.tutorial)
				App.tutorial.nextStep(5, 7);
		}*/
	}
}