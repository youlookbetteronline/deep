package units
{
	import api.ExternalApi;
	import core.Post;
	import core.TimeConverter;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.LeftPanel;
	import ui.UnitIcon;
	import wins.MailWindow;
	import wins.OracleWindow;
	import ui.Hints;
	
	public class Oracle extends Tribute
	{
		public static const MAIL:Object = {sid: 901, id: 1};
		public var played:uint = 0;
		
		private var paid:uint = 0;
		private var onPlayed:Function;
		
		public function Oracle(object:Object)
		{
			played = object.played || 0;
			super(object);
			stockable = false;
			
			convertPrediction();
			
			if (object.fromStock)
			{
				tribute = true;
				App.self.setOffTimer(work);
			}
			
			if (this.sid == MAIL.sid)
			{
				removable = false;
			}
		}
		
		private function convertPrediction(predictions:Object = null):Object 
		{
			if (!this.info.predictions.hasOwnProperty('out')) 
			{
				return {}
			}
			
			var pList:Object = this.info.predictions;
			var pListConverted:Object = { };
			
			for (var itm:* in pList.out) 
			{
				for (var itmSid:* in pList.out[itm]) 
				{
					break
				}
				
				var pListObj:Object = { };
				pListObj['m'] = itmSid;
				pListObj['c'] = pList.out[itm][itmSid];
				pListObj['p'] = pList.text[itm].text;					
				pListConverted[itm] = pListObj;				
			}
			
			this.info.predictions = pListConverted;
			return pListConverted;		
		}
		
		override public function init():void 
		{
			
			if (formed)
			{
				if (played < App.midnight && buildFinished) {// Значит играли вчера
					tribute = true;
					showIcon();
				}else{
					tribute = false;
					App.self.setOnTimer(work);
				}
			}else{
				tribute = true;
			}
			
			tip = function():Object {
				if (tribute)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1441759744030")
					};
				}else {
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379912"),
						timerText:TimeConverter.timeToCuts(App.nextMidnight - App.time, true, true),
						timer:true
					};
				}
			}
			checkDaylics();
		}
		
		private function checkDaylics():void 
		{
			if (this.sid == MAIL.sid && App.user.mode == User.OWNER)
			{
				var mailbox:* = Map.findUnits([MAIL.sid]);
				if (mailbox[0] != null && this.sid == mailbox[0].sid && this.id == mailbox[0].id && !tribute)
				{
					App.ui.leftPanel.createDaylicsIcon();
					App.ui.leftPanel.dayliState(true);
					//App.ui.leftPanel.update();
				}
			}
		}
		public function afterUpgrade():void 
		{
			if((level + 1) == totalLevels)
			{
				App.self.setOffTimer(work);
				tribute = true;
			}
		}
		
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{			
			if (error)
			{
				//Возвращаем как было
				for (var id:* in params) {
					App.user.stock.data[id] = params[id];
				}
				
				//this.level--;
				updateLevel();
				return;
			}
			
			hasUpgraded = false;
			upgradedTime = data.upgrade;
			App.self.setOnTimer(upgraded);
			
			if (App.social == 'FB') 
			{						
				ExternalApi._6epush([ "_event", { "event": "achievement", "achievement": "building_construction" } ]);
			}
			
			afterUpgrade();			
		}
		
		override public function work():void
		{
			if (App.time > App.nextMidnight)
			{
				App.self.setOffTimer(work);
				tribute = true;
				showIcon();
			}
		}
		
		override public function showIcon():void {
			if (!formed || !open) return;
			
			if (cloudPositions.hasOwnProperty(App.data.storage[sid].view) ) 
			{
				coordsCloud.x = cloudPositions[App.data.storage[sid].view].x;
				coordsCloud.y = cloudPositions[App.data.storage[sid].view].y;
			}else{
				coordsCloud.x = 0;
				coordsCloud.y = 0;
			}
			
			if (App.user.mode == User.GUEST && touchableInGuest) {
				if (info.type == 'Golden')
				{
					drawIcon(UnitIcon.REWARD, Stock.COINS, 1, {
						glow:		false
					}, 0, coordsCloud.x, coordsCloud.y);
				} 
				
				clearIcon();
			}
			
			if (App.user.mode == User.OWNER) 
			{
				var _view:int=0;
				if (level >= totalLevels && tribute && this.sid == 901) 
				{
					drawIcon(UnitIcon.MAIL, 2, 1, {
						glow:		true
					}, 0, coordsCloud.x, coordsCloud.y);
					this.showGlowing();
					level = 1;
					updateLevel();
				}else
					if (level >= totalLevels && tribute) 
					{		
						drawIcon(UnitIcon.ORACLE, 2, 1, {
							glow:		true
						}, 0, coordsCloud.x, coordsCloud.y);
					}
				/*else if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1)) 
				{
					drawIcon(UnitIcon.BUILD, null);
				}*/
				else 
				{
					clearIcon();
				}
			}
		}
		
		override public function checkOnAnimationInit():void 
		{
			if (textures && textures['animation'] && ((level == totalLevels /*- craftLevels*/) /*|| this.sid == 236*/)) 
			{
				initAnimation();
				if (buildFinished) 
				{
					beginAnimation();
				}
				else
				{
					finishAnimation();
				}
			}
		}
		
		override public function get buildFinished():Boolean 
		{
			return true;// (level == totalLevels);
		}
		
		override public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			removeEffect();
			
			Treasures.bonus(Treasures.convert(info.devel.rew[level]), new Point(this.x, this.y));
			clearIcon();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void
		{
			super.onStockAction(error, data, params);
			//tribute = false;
			played = 0;
		}
		
		override public function click():Boolean 
		{
			if (!clickable || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			App.tips.hide();
			
			if (App.user.mode == User.OWNER && this.sid == MAIL.sid)
			{					
				new MailWindow( {
					target:this,
					onPlay:playEvent,
					popup:true
				}).show();
				
			}else 
				if (App.user.mode == User.OWNER)
				{					
					new OracleWindow( {
						target:this,
						onPlay:playEvent,
						popup:true
					}).show();
				}
			
			return true;
		}		
		
		public function playEvent(paid:int, onPlayed:Function):void 
		{			
			this.onPlayed = onPlayed;
			this.paid = paid;
			
			if (paid == 1) 
			{
				if (!App.user.stock.take(Stock.FANT, info.skip))
				return;
			}
			if (App.user.mode == User.OWNER && this.sid == MAIL.sid)
			{
				level = 2;
				updateLevel();
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
					paid:paid
				}, onStorageEvent);
				
				tribute = false;
			}
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
			BonusItem.takeRewards(data.treasure, new Point(App.self.mouseX, App.self.mouseY), 10, true);
			App.user.stock.addAll(data.bonus);
			
			var tSID:int = 0;
			var tQTTY:int = 0;
			var finalObject:Object = { };
			
			for (var t:* in data.treasure)
			{
				for(var b:* in data.treasure[t])
				{
					finalObject[t] = b;
				}
			}
			
			if (this.sid == MAIL.sid) 
			{
				init();
				//checkDaylics();
			}
			
			App.user.stock.addAll(finalObject);
			App.ui.upPanel.update();
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			
			checkOnAnimationInit();
			if (App.user.mode == User.OWNER && this.sid == MAIL.sid && !tribute)
			{
				level = 2;
				updateLevel();
			}
			
		}
		
		override public function set info(value:Object):void 
		{
			super.info = value;
		}
		
		override public function get tribute():Boolean {
			return _tribute;
		}
		
		override public function set tribute(value:Boolean):void 
		{
			_tribute = value;
			showIcon();
		}
	}
}