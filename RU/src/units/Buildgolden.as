package units
{
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.Hints;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import wins.ChoiceWindow;
	import wins.ConstructWindow;
	import wins.SimpleWindow;
	import wins.SpeedWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Buildgolden extends Building
	{
		public var capacity:int = 0;
		public function Buildgolden(object:Object):void
		{
			super(object);

			if(object.crafted)
				crafted = object.crafted;
				
			if(object.level)
				level = object.level;

			capacity = object.capacity?object.capacity:0;

			craftLevels = -1;
			if (info.instance.devel && info.instance.devel[1].req) {
				for each (var value:* in info.instance.devel[1].req) {
					if (value.tr && App.data.treasures.hasOwnProperty(value.tr))
						craftLevels++;
				}
			}
			if (craftLevels < 0)
				craftLevels = 0;

			if (level > totalLevels) {
				level = totalLevels;
			}
			if (level >= totalLevels - craftLevels) {
				if (App.time > crafted - time) {
					if (!isWorking) {
						App.self.setOnTimer(work);
						isWorking = true;
					}
				}
			}
			touchableInGuest = false;
			tip = function():Object {
				var capacityText:String = capacity < info.capacity?'\n' + Locale.__e('flash:1382952379794', String(info.capacity - capacity)):'';
				if (App.user.mode == User.GUEST) {
					return {
						title:info.title,
						text:info.description
					};
				}

				if (level == totalLevels)
				{
					if (App.time >= crafted) {
						return {
							title:info.title,
							text:Locale.__e("flash:1382952379966") + capacityText
						};
					}else{
						return {
							title:info.title,
							text:Locale.__e("flash:1382952379839"),
							timerText:TimeConverter.timeToStr(crafted - App.time) + capacityText,
							timer:true
						};
					}
				}
				else
				{
					if (App.time >= crafted) {
						return {
							title:info.title,
							text:Locale.__e("flash:1506524402233") + capacityText
						};
					}else{
						return {
							title:info.title,
							text:Locale.__e("flash:1382952379839"),
							timerText:TimeConverter.timeToStr(crafted - App.time) + capacityText,
							timer:true
						};
					}
				}

				return {
					title:info.title,
					text:Locale.__e("flash:1382952379967")
				};
			}

			if (buildFinished && !isWorking) {
				showIcon();
			}

		}

		private var showComponent:Boolean = false;
		override public function click():Boolean {
			
			if (App.user.mode == User.OWNER) {
				if (buildFinished)
				{
					if (level != totalLevels)
					{
						if (App.time < crafted) {
							openSpeedWindow();
						}
						else
						{
							new ChoiceWindow( {
								title			:info.title,
								mainText		:Locale.__e('flash:1506693163063'),
								descriptionText	:Treasures.stringify(currentTreasure),
								leftBttnText	:Locale.__e('flash:1382952380146'),	
								rightBttnText	:Locale.__e('flash:1396963489306'),	
								width			:500,
								height			:235,
								leftEvent		:storageEvent,
								rightEvent		:openConstructWindow
							}).show();
						}
					}
					else
					{
						if (App.time < crafted) 
							openSpeedWindow();
						else
							storageEvent()
					}
				}
				else
				{
					openConstructWindow();
				}
			}
			return false;
		}
		
		protected function openSpeedWindow():void {
			new SpeedWindow( {
				title:info.title,
				priceSpeed:info.skip,
				target:this,
				info:info,
				noBoostBttn:(info.hasOwnProperty('capacity') && info.capacity != 0),
				finishTime:crafted,
				totalTime:time,
				doBoost:onBoostEvent,
				btmdIconType:App.data.storage[sid].type,
				btmdIcon:App.data.storage[sid].preview,
				upgrade:(level < totalLevels) ? openConstructWindow : null
			}).show();
		}

		override public function get buildFinished():Boolean {
			return level >= totalLevels - craftLevels;
		}

		override public function onBoostEvent(count:int = 0):void {
			if (App.user.stock.take(Stock.FANT, count)){
				ordered = true
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					if (!error && data) {
						crafted = data.crafted;
					}
					onProductionComplete();
					ordered = false;
					startAnim();
				});
			}
		}

		override public function openConstructWindow(openWindowAfterUpgrade:Boolean = false):Boolean
		{
			if (level <= totalLevels || level == 0)
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						if (info.instance.devel[1].req.hasOwnProperty(level + 1)) {
							new ConstructWindow( {
								title:			info.title,
								upgTime:		info.instance.devel[1].req[level + 1].t,
								request:		info.instance.devel[1].obj[level + 1],
								target:			this,
								win:			this,
								onUpgrade:		upgradeEvent,
								hasDescription:	true
							}).show();
						} else {
							//
						}

						return true;
					}
				}
			}
			return false;
		}

		public var isWorking:Boolean = false;
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void {
			super.onUpgradeEvent(error, data, params);
			if (buildFinished) {
				crafted = App.time;
				showIcon();
				if(!isWorking){
					App.self.setOnTimer(work);
					isWorking = true;
				}
			};
		}


		public function work():void {
			if (App.user.mode == User.GUEST)
				return;

			if (App.time > crafted) {
				App.self.setOffTimer(work);
				showIcon()
				isWorking = false;
			}else {
				clearIcon();
			}
		}
		
		override public function storageEvent():void
		{
			ordered = true;
			
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onStorageEvent);
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			if(data.hasOwnProperty('bonus')){
				var trgPoint:Point = new Point(this.x, this.y);
				Treasures.bonus(data.bonus, trgPoint);
			}
			
			capacity++;
			if (info.capacity && capacity >= info.capacity) {
				uninstall();
				return;
			}
			ordered = false;
			crafted = App.time + time;
			showIcon();
			if (!isWorking) {
				clearIcon();
				App.self.setOnTimer(work);
				isWorking = true;
			}

			if (buildFinished && level >= totalLevels) {
				checkOnAnimationInit();
				initAnimation();
				startAnimation();
			}
		}

		public function get time():int {
			if (info.instance.devel[1] && info.instance.devel[1].req && info.instance.devel[1].req[level])
				return info.instance.devel[1].req[level].time;

			return info.time;
		}

		protected function startAnim():void
		{
			checkOnAnimationInit();

			startAnimation();
		}

		override public function showIcon():void {
			if (App.user.mode == User.GUEST) {
				clearIcon();
				return;
			}

			iconIndentCount();
			if (crafted > 0 && App.time >= crafted && buildFinished) {
				drawIcon(UnitIcon.REWARD, 2, 1, {
					glow:		false
				});
			}
		}

		override public function onLoad(data:*):void {
			super.onLoad(data);
			startAnim();
		}
		
		private function get currentTreasure():Object
		{
			return App.data.treasures[info.instance.devel[1].req[level].tr][info.instance.devel[1].req[level].tr]	
		}
	}
}