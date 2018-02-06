package wins {
	
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Numbers;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import units.GardenerSlave;
	import units.Tree;
	import units.Unit;
	import units.WorkerUnit;
	import wins.elements.Bar;
	
	public class GardenerWindow extends Window {
		
		public var fruitsArr:Array = [];
		public var countsArr:Array = [];
		
		private var chooseBttn:Button;
		private var unbindBttn:Button;
		private var collectBttn:Button;
		private var progressBacking:Bitmap;
		private var progressBar:ProgressBar;
		private var finishTime:int;
		private var leftTime:int;
		private var timer:TextField;
		private var totalTime:int;
		private var boostBttn:MoneyButton;
		private var boostPrice:int;
		private var gardenerSlave:GardenerSlave;
		
		public function GardenerWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}
			
			settings["width"] = 565;
			settings["height"] = 340;
			settings["popup"] = true;
			settings["fontSize"] = 48;
			settings['shadowSize'] = 3;
			settings['hasPaginator'] = false;
			settings["description"] = Locale.__e("flash:1382952380232");
			settings["background"] = 'buildingBacking';
			settings["content"] = [];
			
			finishTime = settings.finishTime;
			totalTime = settings.totalTime;
			boostPrice = settings.boostPrice;
			gardenerSlave = settings.gardenerSlave;
			
			if (gardenerSlave.targets.length) {
				for each(var tree:Object in gardenerSlave.targets) {
					var tree_sid:int = Numbers.firstProp(tree).key;
					for (var out:* in App.data.storage[tree_sid].out) {
						if (int(out) != Stock.EXP && int(out) != Stock.COINS && int(out) != Stock.FANTASY) {
							fruitsArr.push(int(out));
							var obj:Tree = Map.findUnit(Numbers.firstProp(tree).key, Numbers.firstProp(tree).val);
							if (obj) 
							{
								
							countsArr.push((int(gardenerSlave.info.duration / App.data.storage[tree_sid].time)>(obj.info.capacity+1-obj.times))?(obj.info.capacity+1-obj.times):int(gardenerSlave.info.duration / App.data.storage[tree_sid].time));
						//	obj.times = countsArr[countsArr.length-1]
							settings.content.push(int(out));
							
							}
						}
					}
				}
			} else {
				for (var i:int = 0; i < gardenerSlave.info.count; i++) {
					fruitsArr.push(0);
					countsArr.push(0);
					settings.content.push(0);
				}
			}
			
			if (gardenerSlave.info.count > 4) {
				settings["height"] = 370;
				settings['hasPaginator'] = true;
				settings["itemsOnPage"] = 4;
			}
			
			super(settings);
		}
		
		override public function drawArrows():void {
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			paginator.arrowLeft.x = -paginator.arrowLeft.width / 2 + 86;
			paginator.arrowLeft.y = 60;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width / 2 - 6;
			paginator.arrowRight.y = 60;
			
			paginator.x -= 32;
			paginator.y -= 66;
		}
		
		private var background2:Bitmap;
		override public function drawBody():void {
			exit.y -= 22;
			drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, 36, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, settings.height - 110, false, false, false, 1, 1);
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -48, true, true);
			
			background2 = Window.backing(510, 150, 10, "giftCounterBacking");
			background2.x = (settings.width - background2.width) / 2;
			background2.y = 15;
			bodyContainer.addChild(background2);
			
			var subTitle:TextField = Window.drawText(Locale.__e("flash:1438351382075"), {
				fontSize:26,
				color:0xFFFFFF,
				autoSize:"center",
				borderColor:0x5b4814,
				textAlign: 'center'
			});
			subTitle.x = (settings.width  - subTitle.width) / 2;
			subTitle.y = 3;
			bodyContainer.addChild(subTitle);
			
			//Выбрать деревья
			chooseBttn = new Button({
				width:		236,
				height:		66,
				fontSize	:28,
				caption:	Locale.__e('flash:1416306272834')
			});
			chooseBttn.x  = (settings.width - chooseBttn.width) / 2;
			chooseBttn.y = settings.height - 140;
			bodyContainer.addChild(chooseBttn);
			chooseBttn.addEventListener(MouseEvent.CLICK, onChoose);
			chooseBttn.visible = false;
			
			//progress
			progressBacking = Window.backingShort(406, "prograssBarBacking3");
			progressBacking.x = 26;
			progressBacking.y = 230;
			
			if (gardenerSlave.info.count < 5) {
				progressBacking.y = 190;
			}
			
			progressBacking.scaleY = 1.4;
			progressBacking.smoothing = true;
			bodyContainer.addChild(progressBacking);
			progressBacking.visible = false;
			
			progressBar = new ProgressBar({ win:this, width:progressBacking.width - 18, isTimer:false, scale:0.7});
			progressBar.x = progressBacking.x - 7;
			progressBar.y = progressBacking.y - 7;
			progressBar.scaleY = 1.4;
			bodyContainer.addChild(progressBar);
			progressBar.visible = false;
			
			timer = Window.drawText(TimeConverter.timeToStr(127), {
				color:			0xffffff,
				borderColor:	0x6d460f,
				fontSize:		28
			});
			timer.height = timer.textHeight;
			timer.width = timer.textWidth + 10;
			timer.x = progressBacking.x + (progressBacking.width - timer.width) / 2;
			timer.y = progressBacking.y + 10;
			bodyContainer.addChild(timer);
			timer.visible = false;
			
			//Ускорить
			boostBttn = new MoneyButton({
				title: Locale.__e("flash:1382952380104"),
				caption:Locale.__e("flash:1382952380104"),
				countText:String(boostPrice),
				width:104,
				height:56,
				fontSize:22,
				borderColor:[0xb5dbff,0x386cdc],
				fontColor:0xFFFFFF,
				fontBorderColor:0x375bb0,
				bevelColor:[0xb5dbff, 0x386cdc],
				fontCountBorder:0x375bb0
			});
			boostBttn.x = progressBacking.x + progressBacking.width + 4;
			boostBttn.y = progressBacking.y - 4;
			boostBttn.textLabel.x = (boostBttn.width - boostBttn.textLabel.textWidth) / 2;
			boostBttn.textLabel.y = 4;
			boostBttn.countLabel.width = boostBttn.countLabel.textWidth + 5;
			boostBttn.coinsIcon.x = (boostBttn.width - boostBttn.coinsIcon.width - boostBttn.countLabel.width) / 2;
			boostBttn.coinsIcon.y = boostBttn.height / 2;
			boostBttn.countLabel.x = boostBttn.coinsIcon.x + boostBttn.coinsIcon.width + 4;
			boostBttn.countLabel.y = boostBttn.height / 2;
			bodyContainer.addChild(boostBttn);
			boostBttn.addEventListener(MouseEvent.CLICK, onBoost);
			boostBttn.visible = false;
			
			//Отвязать деревья
			unbindBttn = new Button({
				width:		160,
				height:		48,
				bgColor:	[0xffa96c, 0xf55e43],
				bevelColor:	[0xfecbb0, 0xd14b28],
				borderColor:[0xa98a5e, 0xa98a5e],
				fontSize	:22,
				caption:	Locale.__e('flash:1438095183465')
			});
			unbindBttn.x  = (settings.width - unbindBttn.width) / 2;
			unbindBttn.y = settings.height - 72;
			bodyContainer.addChild(unbindBttn);
			unbindBttn.addEventListener(MouseEvent.CLICK, onUnbind);
			unbindBttn.visible = false;
			
			//Собрать
			collectBttn = new Button({
				width:		196,
				height:		54,
				fontSize	:34,
				caption:	Locale.__e('flash:1382952380146')
			});
			collectBttn.x  = (settings.width - collectBttn.width) / 2;
			collectBttn.y = settings.height - 140;
			bodyContainer.addChild(collectBttn);
			collectBttn.addEventListener(MouseEvent.CLICK, onCollect);
			collectBttn.visible = false;
			
			contentChange();
			
			if (gardenerSlave.started > 0 && App.time <= gardenerSlave.finished) {
				if (gardenerSlave.workStatus == WorkerUnit.BUSY && gardenerSlave.targets.length > 0) {
					progressBacking.visible = true;
					progressBar.visible = true;
					timer.visible = true;
					
					progress();
					App.self.setOnTimer(progress);
					progressBar.start();
					
					boostBttn.visible = true;
					unbindBttn.visible = true;
				}
			} else if (gardenerSlave.started > 0 && App.time > gardenerSlave.finished) {
				collectBttn.visible = true;
			} else {
				GardenerSlave.countOfTargets = gardenerSlave.info.count;
				chooseBttn.visible = true;
			}
		}
		
		private function onChoose(e:MouseEvent):void {
			showAnyTargets(gardenerSlave.possibleTargets);
			showTargets();
			close();
		}
		
		private function onBoost(e:MouseEvent):void {
			gardenerSlave.onBoostEvent();
			
			progressBacking.visible = false;
			progressBar.visible = false;
			timer.visible = false;
			boostBttn.visible = false;
			unbindBttn.visible = false;
			
			collectBttn.visible = true;
		}
		
		private function onUnbind(e:MouseEvent):void {
			gardenerSlave.unbindAction();
			
			progressBacking.visible = false;
			progressBar.visible = false;
			timer.visible = false;
			boostBttn.visible = false;
			unbindBttn.visible = false;
			
			chooseBttn.visible = true;
			
			fruitsArr = [];
			countsArr = [];
			settings["content"] = [];
			for (var i:int = 0; i < gardenerSlave.info.count; i++) {
				fruitsArr.push(0);
				countsArr.push(0);
				settings.content.push(0);
			}
			
			contentChange();
		}
		
		private function onCollect(e:MouseEvent):void {
			gardenerSlave.storageAction();
			close();
		}
		
		private var possibleTargets:Array = [];
		private function showAnyTargets(possibleSIDs:Array = null):void {
			if (!possibleSIDs) possibleSIDs = [];
			
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:* in possibleTargets) {
				if (res.hasProduct || res.started) continue;
				res.state = res.HIGHLIGHTED;
				res.canAddWorker = true;
			}
		}
		
		private function showTargets():void {
			GardenerSlave.waitWorker = gardenerSlave;
			GardenerSlave.chooseTargets = [];
			GardenerSlave.clickCounter = 0;
			GardenerSlave.waitForTarget = true;
			
			App.ui.upPanel.showCancel(gardenerSlave.onCancel);
			App.ui.upPanel.showHelp(Locale.__e('flash:1416306272834'), 250);
			
			setTimeout(function():void {
				App.self.addEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			}, 100);
		}
		
		private function unselectPossibleTargets(e:MouseEvent):void {
			if (GardenerSlave.waitForTarget) {
				return;
			}
			
			App.self.removeEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			
			GardenerSlave.waitForTarget = false;
			
			for each(var res:* in possibleTargets) {
				res.state = res.DEFAULT;
				if (res.hasOwnProperty('canAddCowboy')) {
					res.canAddCowboy = false;
				}
				if(res.hasOwnProperty('canCollector'))	{
					res.canCollector = false;
				}
				if (res.hasOwnProperty('canAddWorker')) {
					res.canAddWorker = false;
				}
			}
		}
		
		private function progress():void {
			leftTime = finishTime - App.time;
			
			if (leftTime <= 0) {
				leftTime = 0;
				App.self.setOffTimer(progress);
				//close();
				progressBacking.visible = false;
				progressBar.visible = false;
				timer.visible = false;
				boostBttn.visible = false;
				unbindBttn.visible = false;
				
				collectBttn.visible = true;
			}
			
			timer.text = TimeConverter.timeToStr(leftTime);
			var percent:Number = (totalTime - leftTime) / totalTime;
			progressBar.progress = percent;
		}
		
		override public function contentChange():void {
			if (rewards != null && rewards.parent)
				rewards.parent.removeChild(rewards);
			
			if (fruitsArr.length <= 4) {
				drawGift(fruitsArr, countsArr);
			} else if (fruitsArr.length > 4) {
				var fruits_temp:Array = [];
				var counts_temp:Array = [];
				var endCount:int = paginator.finishCount;
				if (endCount > fruitsArr.length)
					endCount = fruitsArr.length;
				for (var i:int = paginator.startCount; i < endCount; i++ ) {
					fruits_temp.push(fruitsArr[i]);
					counts_temp.push(countsArr[i]);
				}
				drawGift(fruits_temp, counts_temp);
			}
		}
		
		private var rewards:RewardListD;
		private function drawGift(fruits:Array, counts:Array) : void {
			rewards = new RewardListD(fruits, counts, false, 0, {itemHasBacking:false, itemWidth:110, itemHeight:118, itemIsGardener:true});
			rewards.x = (settings.width - rewards.backing.width) / 2;
			rewards.y = background2.y;
			rewards.title.visible = false;
			bodyContainer.addChild(rewards);
		}
	}
}