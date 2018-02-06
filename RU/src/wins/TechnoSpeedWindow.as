package wins {
	
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.BoostTool;
	
	public class TechnoSpeedWindow extends Window {
		
		private var progressBar:ProgressBar;
		
		private var finishTime:int;
		private var leftTime:int;
		
		private var isBoost:Boolean;
		
		private var timer:TextField;
		
		public var boostBttn:MoneyButton;
		public var moveBttn:Button;
		
		private var totalTime:int;
		
		private var priceSpeed:int = 0;
		private var priceBttn:int = 0;
		
		public var noBoostJson:Object;
		public var noBoostArray:Array;
		
		public function TechnoSpeedWindow(settings:Object = null) {
			settings["width"] = 550;
			settings["height"] = 400;
			settings["fontSize"] = 38;
			settings["hasPaginator"] = false;
			
			if (settings.hasOwnProperty('hasBoost')) {
				settings["hasBoost"] = settings.hasBoost;	
			} else {
				settings["hasBoost"] = true;		
			};
			
			finishTime = settings.finishTime;
			totalTime = settings.totalTime;
			
			super(settings);
			
			priceSpeed = settings.priceSpeed || settings.info.speedup || settings.info.skip;
		}
		
		private function progress():void {
			leftTime = finishTime - App.time;
			
			if (leftTime <= 0) {
				leftTime = 0;
				App.self.setOffTimer(progress);
				close();
			}
			
			timer.text = TimeConverter.timeToStr(leftTime);
			var percent:Number = (totalTime - leftTime) / totalTime;
			progressBar.progress = percent;
			
			if (App.user.quests.tutorial)
				return;
			
			if (boostBttn && priceBttn != priceSpeed && priceSpeed != 0) {
				priceBttn = priceSpeed;
				boostBttn.count = String(priceSpeed);
			}
		}
		
		override public function drawBackground():void {
			background = backing(settings.width, settings.height, 40, "constructBackingUp");
			layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12 - 25;
			exit.y = -12 + 30;
		}
		
		public function get canBoost():Boolean {
			var itm:Object = App.data.storage[settings.target.sid];
			return (itm.hasOwnProperty('mboost') && itm.mboost != "" &&!isNaN(itm.mboost))
		}
		
		//private var iconTarget:Bitmap = new Bitmap();
		private var background:Bitmap;
		override public function drawBody():void 
		{
			titleLabel.y += 37;
			
			var btmd:BitmapData;
			
			var itm:Object = App.data.storage[settings.target.sid];
			//Load.loading(Config.getIcon(itm.type, itm.preview), onPreviewComplete);
			
			//bodyContainer.addChildAt(iconTarget, 0);
			var backing:Bitmap = backing2(settings.width - 160, settings.height - 200, 50, "capsuleWindowBackingPaperUp", "capsuleWindowBackingPaperDown");
			backing.x = (settings.width - backing.width) / 2;
			backing.y = 50;
			bodyContainer.addChild(backing);
			
			var description:TextField = Window.drawText(Locale.__e("flash:1475757914609", App.data.storage[settings.target.animal].title), {
				multiline:true,
				wrap:true,
				textAlign:"center",
				width:backing.width - 20,
				color:0xFCFEFB,
				borderColor:0x7E3129,
				fontSize:36
			} );
			
			description.x = (settings.width - description.width) * 0.5;
			description.y = backing.y +25;
			bodyContainer.addChild(description);
			
			var progressBacking:Bitmap = Window.backingShort(390, "prograssBarBacking3");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = settings.height - progressBacking.height - 100;
			bodyContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar( { win:this, width:progressBacking.width - 21, isTimer:false, scale:0.67});
			//progress();
			progressBar.x = (settings.width - progressBacking.width) / 2 - 7;
			progressBar.y = progressBacking.y - 5;
			progressBar.visible = false;
			
			bodyContainer.addChild(progressBar);
			
			progressBar.visible = true;
			
			
			timer = Window.drawText(TimeConverter.timeToStr(127), {
				color:			0xFCFEFB,
				borderColor:	0x7E3129,
				fontSize:		40
			});
			
			bodyContainer.addChild(timer);
			timer.y = description.y + description.textHeight + 10;
			
			timer.x = settings.width / 2 - 50;
			
			timer.height = timer.textHeight;
			timer.width = timer.textWidth + 10;
			
			progress();
			App.self.setOnTimer(progress);
			progressBar.start();
			
			if (App.user.quests.tutorial) {
				priceSpeed = 0;
			}
			
			var downPlankBmap:Bitmap = backingShort(300, 'shopPlankDown');
			downPlankBmap.x = settings.width / 2 -downPlankBmap.width / 2;
			downPlankBmap.y = settings.height - downPlankBmap.height -30;
			bodyContainer.addChild(downPlankBmap);
			
			boostBttn = new MoneyButton( {
				caption: Locale.__e("flash:1382952380104"),
				countText:String(priceSpeed),
				iconScale: .8,
				width:140,
				height:45,
				fontSize:(App.lang == 'de') ? 18 : 22,
				bgColor:[0xbaf76e,0x68af11],
				//borderColor:[0xa0d5f6, 0x53742d],
				fontColor:0xFFFFFF,
				fontCountBorder:0x53742d,
				fontBorderColor:0x53742d,
				bevelColor:[0xd8e7ae, 0x4f9500]
				
			});
			
			noBoostJson = JSON.parse(App.data.options.noBoost);
			noBoostArray = noBoostJson.sid;
			
			if (noBoostArray.indexOf(settings.target.sid) != -1) {
				boostBttn.visible = false;
			}else 
			{
				boostBttn.visible = true;
			}
			
			//boostBttn.visible = ((settings.target.sid != '798' ) && (settings.target.sid != '1925') && (settings.target.sid != '1923') && (settings.target.sid != '1858') && (settings.target.sid != '1859') && (settings.target.sid != '1866') && (settings.target.sid != '1775') && (settings.target.sid != '439') && (settings.target.sid != '1617') &&(settings.target.sid != '1606') && (settings.target.sid != '996') && (settings.target.sid != '1291') && (settings.target.sid != '1290') && (settings.target.sid != '1289') && (settings.target.sid != '1288'));
			bodyContainer.addChild(boostBttn);
			boostBttn.x = downPlankBmap.x + (downPlankBmap.width - boostBttn.width) / 2;
			boostBttn.y = downPlankBmap.y + (downPlankBmap.height - boostBttn.height) / 2;
			boostBttn.countLabel.width = boostBttn.countLabel.textWidth + 5;
			
			if (settings.hasOwnProperty('moveTo') && User.inExpedition) {
				moveBttn = new Button( {
					caption: Locale.__e("flash:1434377492145"),
					width:192,
					height:56,
					fontSize:32,
					fontCountSize:32,
					radius:26,
					
					/*bgColor:[0xa8f84a, 0x73bb16],
					borderColor:[0xffffff, 0xffffff],
					bevelColor:[0xcefc97, 0x5f9c11],	
					
					fontColor:0xffffff,			
					fontBorderColor:0x2b784f,
					
					fontCountColor:0xffffff,				
					fontCountBorder:0x2b784f,*/
					iconScale:0.8
				});
				moveBttn.x = (settings.width - moveBttn.width)/2;
				moveBttn.y = settings.height - moveBttn.height - 10 + 60;
				bodyContainer.addChild(moveBttn);
				moveBttn.addEventListener(MouseEvent.CLICK, onMoveEvent);
			}
			
			if (!settings.hasBoost) {
				boostBttn.visible = false;
				
			}
			boostBttn.addEventListener(MouseEvent.CLICK, onBoostEvent);
			
			if (canBoost) {
				var bt:BoostTool = new BoostTool(int(settings.target.sid), mBoost)
				bt.x = boostBttn.x + boostBttn.width + 150;
				bt.y = boostBttn.y - 125;
				//bodyContainer.addChild(bt);
			}
		}
		
		private function onMoveEvent(e:MouseEvent):void {
			moveBttn.state = Button.DISABLED;
			close()
			settings.moveTo();
			
		}
		
		/*private function onPreviewComplete(data:Bitmap):void {
			iconTarget.bitmapData = data.bitmapData;
			iconTarget.smoothing = true;
			
			if (iconTarget.width > 150) {
				iconTarget.scaleX = iconTarget.scaleY = 150/(iconTarget.width);
			}
				
			if (iconTarget.height > 150 ) {
				iconTarget.height =  150;
				iconTarget.scaleX = iconTarget.scaleY;
			}
			
			iconTarget.x = (settings.width - iconTarget.width) / 2;
			iconTarget.y = (27 - iconTarget.height);
		}*/
		
		private function onBoostEvent(e:MouseEvent = null):void {
			if (settings.doBoost)
				settings.doBoost(priceBttn);
			else
				settings.target.acselereatEvent(priceBttn);
			close();
		}
		
		override public function dispose():void {
			if(progressBar)progressBar.dispose();
			progressBar = null;
			if(boostBttn)boostBttn.removeEventListener(MouseEvent.CLICK, onBoostEvent);
			boostBttn = null;
			App.self.setOffTimer(progress);
			super.dispose();
		}
		
		public function mBoost(onComplete:Function = null):void 
		{
			var mBoost:int;
			if (settings.target.info.hasOwnProperty('mboost') && !isNaN(settings.target.info.mboost)) {
				mBoost = settings.target.info.mboost;
			}else {
				new SimpleWindow({text:'Нельзя ускорить',popup:true}).show();
				return;
			}
			if (App.user.stock.count(mBoost)) {
				var pstParams:Object = {
					ctr:settings.target.info.type,
					act:'mboost',
					uID:App.user.id,
					id:settings.target.id,
					wID:App.user.worldID,
					sID:settings.target.sid
				}
				Post.send(pstParams,mBoostComplete,{completeCallback:onComplete,boostedSid:mBoost});
			}else {
				if(onComplete != null)
					onComplete();
				//ShopWindow.findMaterialSource(mBoost)
				new SimpleWindow({text:Locale.__e('flash:1445780031642'),popup:true}).show();
				return;
			}
		}

		public function mBoostComplete(error:*, data:*, params:*):void {
			if (params.hasOwnProperty('boostedSid') && params.boostedSid) {
				var takeObj:Object = { };
				takeObj[params.boostedSid] = 1;
				App.user.stock.takeAll(takeObj);
			}
			if (params.hasOwnProperty('completeCallback') && params.completeCallback != null) {
				params.completeCallback();
			}
			
			if (error) {
				Errors.show(error, data);
				return;
			}
			finishTime = data.crafted;
			settings.target.began = data.crafted - App.time;
			settings.target.crafted = data.crafted;
			for each(var q:* in settings.target.queue) {
				q.crafted = data.crafted;
			}
		}
	}
}