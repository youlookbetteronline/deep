package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import utils.ObjectsContent;
	import wins.elements.ContentManager;
	import wins.Paginator;
	
	public class TowerWindowTwo extends Window
	{
		private var items:Array = new Array();
		private var accelerateBttn:MoneyButton
		public var info:Object;
		public var back:Shape = new Shape();
		public var backSmall:Bitmap;
		public var hitBttn:Button;
		public var upgradeBttn:Button;
		public var contentManager:ContentManager;
		public var notifBttn:Button = null;
		public var whatToPlaceTextLabel:TextField;	
		public var progressBar:ProgressBar;
		public var itemsNum:int;
		public var rewardTextLabel:TextField;
		private var background:Bitmap;
		private var background2:Bitmap;
		private var backDesc:Shape = new Shape();
		private var friendCont:Sprite = new Sprite();
		
		public function TowerWindowTwo(settings:Object = null)
		{
			if (settings == null) 
			{
				settings = new Object();
			}
			
			info = settings.target.info;
			
			settings['itemsNum'] = settings.itemsNum;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] = 0x116011;
			settings['shadowBorderColor'] = 0x116011;
			settings['fontSize'] = 32;
			settings['fontBorderSize'] = 4;			
			settings['background'] = "capsuleWindowBacking";
			settings["exitTexture"] = 'closeBttnMetal';
			settings['width'] = (settings.itemsNum == 3) ? 570 : 670;
			settings['height'] = (ObjectsContent.friendsWorld.indexOf(App.user.worldID)!=-1)?600:470;
			settings['title'] = info.title;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 8;			
			settings['content'] = [];
			settings['kicks'] = [];		
			
			itemsNum = settings.itemsNum;
			
			for (var _uid:* in settings.target.guests) 
			{
				if (!App.user.friends.data.hasOwnProperty(_uid)) continue;
				settings['content'].push( { uid:_uid, time:settings.target.guests[_uid] } );
			}
			
			settings['kicks'] = [];
			for (var sID:* in info.mkicks) {
				var obj:Object = { sID:sID, count:info.mkicks[sID].c };
				if (info.mkicks[sID].hasOwnProperty('t')) {
					obj['t'] = info.mkicks[sID].t;
					obj['o'] = info.mkicks[sID].o;
				}
				settings['kicks'].push(obj);
			}
			
			settings['kicks'].sortOn(info.mkicks[sID].t, Array.NUMERIC);
			//settings['content'] = [{0: {uid:'dsdasdas'}}, {1: {uid:'dsdasdas'}}, {2: {uid:'dsdasdas'}}, {3: {uid:'dsdasdas'}}, {4: {uid:'dsdasdas'}}, {5: {uid:'dsdasdas'}}, {6: {uid:'dsdasdas'}}, {7: {uid:'dsdasdas'}}, {8: {uid:'dsdasdas'}}, {9: {uid:'dsdasdas'}}, {10: {uid:'dsdasdas'}}, {11: {uid:'dsdasdas'}}, {12: {uid:'dsdasdas'}} ];
			contentManager = new ContentManager( { from:0, to:settings['itemsOnPage'],cols:settings['itemsOnPage'], content:settings['content'], itemType:FriendItem, margin:0} );
			
			if (settings.target.hasOwnProperty('floor')) {
				floor = settings.target.floor
			}else{
				floor = settings.target.level
			}			
			
			super(settings);
		}
		
		public var floor:int = 0;
		public var titleTxt:Sprite;
		private var txtS:TextField;
		
		public function drawProgress():void 
		{			
			var progressBacking:Bitmap = Window.backingShort(387, "backingBank");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = 65;
			bodyContainer.addChild(progressBacking);
			
			var barSettings:Object = {
				typeLine:'sliderBank',
				width:386,
				win:this.parent
			};
			
			progressBar = new ProgressBar(barSettings);
			progressBar.start();
			progressBar.x = progressBacking.x - 18;
			progressBar.y = progressBacking.y - 13;
			
			bodyContainer.addChild(progressBar);
			progressBar.timer.text = '';
			drawStageInfo()
			progress();	
		}
		
		public function drawStageInfo():void {
			var titleS:String = (info.tower[floor + 1] != undefined)
				? ' ' + Locale.__e("flash:1447159287268", [settings.target.kicks, info.tower[floor + 1].c])
				: '' + Locale.__e("flash:1447159287268", [settings.target.kicks, settings.target.kicksLimit]);
			
			var textSettings:Object = 
			{
				fontSize	:34,
				color		:0xffffff,
				borderColor	:0x6d3c13,
				textAlign	:"center",
				borderSize:2,
				multiline:true,
				wrap:true
			}
			
			txtS = Window.drawText(titleS, textSettings);
			txtS.width = 300;
			txtS.height = txtS.textHeight + 5;
			//titleTxt = new Sprite();
			//bodyContainer.addChild(txtS);
			txtS.x = progressBar.x + 70;
			txtS.y = progressBar.y + 10;
			//titleTxt.x = kickTextPosX;
			//titleTxt.y = 50;
			/*if (!settings.content.length && info.tower[floor + 1] == undefined)
				titleTxt.visible = false;
			bodyContainer.addChild(titleTxt);*/
		}
		
		public function get kickTextPosY():int {
			return settings.height - 200 / 2 - 90;
		}
		
		public function get kickTextPosX():int {
			return (settings.width - 200) / 2;
		}
		
		public function stageInfoAlign():void {
			var _text:String = (info.tower[floor + 1] != undefined)
				?getTextFormInfo('text3') +' '+ Locale.__e("flash:1382952380278", [settings.target.kicks, info.tower[floor + 1].c])
				:getTextFormInfo('text9');
			
			var _title:TextField = drawText(_text, {
				fontSize:36
			});
			/*if (info.tower[floor + 1] != undefined) {
				titleTxt.x = kickTextPosX;
			}else {
				txtS.width = 500;
				titleTxt.x = kickTextPosX;
				titleTxt.y = kickTextPosY;
			}*/
		}
		
		/*protected function drawRibbon():void 
		{
			var ribbonWidth:int = settings.titleWidth + 180;
			if (ribbonWidth < 320)
				ribbonWidth = 320;
			var titleBackingBmap:Bitmap = backingShort(ribbonWidth, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -65;
			//titleBackingBmap.filters = [new GlowFilter(0xf3ff2c, .7, 11, 11, 3)];
			bodyContainer.addChild(titleBackingBmap);
			
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y - 2;
			
			bodyContainer.addChild(titleLabel);
		}*/
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: 42,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,
				borderSize 			: 3,
				shadowSize 			: 1,
				shadowColor			: settings.fontBorderColor,
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			//titleLabel.y -= 4;

		}
		
		override public function drawBackground():void {
			background = backing(settings.width, settings.height, 50, "capsuleWindowBacking");
			layer.addChild(background);	
			background2 = Window.backing(settings.width - 76, settings.height - 76, 40, 'paperClear');//фоны самих квестов
			background2.x = (background.width - background2.width) / 2;
			background2.y = (background.height - background2.height) / 2;
			layer.addChild(background2);
		}
		
		//public var whatToPlaceTextLabel:TextField
		
		override public function drawBody():void 
		{
			
			
			drawMirrowObjs('decSeaweed', settings.width + 55, - 55, settings.height - 175, true, true, false, 1, 1, layer);
			exit.y -= 25;
			//drawLabel(settings.target.textures.sprites[0].bmp);
			//bodyContainer.removeChild(titleLabelImage);
			//titleLabelImage.y -= 20;
			//titleLabelImage
			bodyContainer.addChild(friendCont)
			if (ObjectsContent.friendsWorld.indexOf(App.user.worldID) != -1)
				drawVisitors();
			//drawStageInfo();
			
			if (settings.content.length == 0)
			{
				var descText:String = 'text4';
				if (floor > 0) {
					if (info.tower[floor + 1] == undefined ) {
						descText = 'text9'
					}
				}
				
				var descriptionLabel:TextField = drawText(getTextFormInfo(descText), {
					fontSize:28,
					textAlign:"center",
					color:0xffffff,
					borderColor:0x624512,
					textLeading:-9
				});
				
				descriptionLabel.wordWrap = true;
				descriptionLabel.width = 350;
				descriptionLabel.height = descriptionLabel.textHeight + 10;
				descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
				descriptionLabel.y = 100;
				
				//bodyContainer.addChild(descriptionLabel);
			}
			//stageInfoAlign();
			drawBttns();
			
			//var underTitle:Bitmap = Window.backingShort(215, "yellowRibbon");
			//underTitle.x = (settings.width - underTitle.width) / 2;
			//underTitle.y = 3;
			//bodyContainer.addChild(underTitle);
			
			var levelTextTabel:TextField = Window.drawText(Locale.__e("flash:1397573560652") + " " +  settings.target.floor + "/" + settings.target.totalFloors, {
				fontSize:34,
				color:0xffdf34,
				autoSize:"left",
				borderColor:0x6e411e
			});
			
			bodyContainer.addChild(levelTextTabel);
			levelTextTabel.x = settings.width / 2 - levelTextTabel.width / 2;
			levelTextTabel.y = 18;
			
			drawRibbon();
			titleBackingBmap.y -= 8;
			
			bodyContainer.addChild(contentManager);
			
			contentManager.x = 52;
			contentManager.y = 407;
			
			
			backDesc.graphics.beginFill(0xfbe5c8, 1);
			backDesc.graphics.drawRect(0, 0, settings.width - 240, 43);
			backDesc.graphics.endFill();
			backDesc.x = (settings.width - backDesc.width) / 2;
			backDesc.y = 115;
			backDesc.filters = [new BlurFilter(30, 0, 2)];
			bodyContainer.addChild(backDesc); 
			
			if (upgradeBttn.visible) 
			{
				bodyContainer.removeChild(backDesc);
			}
			
			whatToPlaceTextLabel = drawText(Locale.__e('flash:1426694723184'), {
				fontSize	:32,
				autoSize	:"center",
				textAlign	:"center",
				color		:0x7f4015,
				border		:false
			});
			whatToPlaceTextLabel.x = whatToPlaceTextLabel.width
			whatToPlaceTextLabel.y = backDesc.y + 5;
			bodyContainer.addChild(whatToPlaceTextLabel);			
			
			/*rewardTextLabel = getTextFormInfo('text9');Window.drawText(Locale.__e('flash:1382952380000'), {
				width		:280,
				fontSize	:25,
				textAlign	:"left",
				color:0xffffff,
				borderColor:0x643a00,
				multiline	:true,
				wrap		:true
			});*/		
			
			var upgradeText:String = getTextFormInfo('text9');
			
			var textSett:Object = 
			{
				width		:500,
				height		:400,
				fontSize	:27,
				textAlign	:"center",
				color		:0xffffff,
				borderColor:0x784727,
				multiline	:true,
				wrap		:true
			}
			
			rewardTextLabel = Window.drawText(upgradeText, textSett);	
			bodyContainer.addChild(rewardTextLabel);
			rewardTextLabel.visible = false
			
			if (upgradeBttn.visible) 
			{
				bodyContainer.removeChild(whatToPlaceTextLabel);
				rewardTextLabel.visible = true;
				rewardTextLabel.x = (settings.width - rewardTextLabel.width) / 2;
				rewardTextLabel.y = upgradeBttn.y + 60;
			}
			
			drawProgress();
			drawItems();
			bodyContainer.addChild(txtS);
		}
		
		public var container:Sprite = new Sprite();
		
		public function drawItems():void {
			
			for (var j:int = 0; j < items.length; j++) 
			{
				
				container.removeChild(items[j]);
				items[j].dispose();
			}
			items = [];	
			
			var X:int = 0;
			var Y:int = 18;
			
			settings.kicks.sortOn('o', Array.NUMERIC);		
			for (var i:int = 0; i < settings.kicks.length; i++)
			{
				var _item:UserShareItem = new UserShareItem(settings.kicks[i], this);
				container.addChild(_item);
				_item.x = X;
				_item.y = Y;
				items.push(_item);
				
				X += _item.bg.width + 15;
			}
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2;
			container.y = 153;
			
			if (upgradeBttn.visible) 
			{
				bodyContainer.removeChild(container);
			}
		}		
		
		public function progress():void {
			
			if (info.tower[floor + 1]) 
			{
				progressBar.progress = settings.target.kicks / info.tower[floor + 1].c;
				txtS.text =  (info.tower[floor + 1] != undefined)
						?/*getTextFormInfo('text3')+*/' ' + Locale.__e("flash:1447159287268", [settings.target.kicks, info.tower[floor + 1].c])
						//:getTextFormInfo('text9');
						: '' + Locale.__e("flash:1447159287268", [settings.target.kicks, settings.target.kicksLimit])
			}
			
			/*if (floor > 0) 
			{
				progressBar.progress = (settings.target.kicks - info.tower[floor].c) / (info.tower[floor + 1].c - info.tower[floor].c);
			}else 
			{
				progressBar.progress = settings.target.kicks / info.tower[floor + 1].c;
			}*/
			
		}
		
		private function drawBttns():void {
			
			upgradeBttn = new Button({
				caption		:getTextFormInfo('text2'),
				width		:190,
				height		:52,	
				fontSize	:26
			});
			
			hitBttn = new Button({
				caption		:getTextFormInfo('text5'),
				width		:190,
				height		:52,	
				fontSize	:36
			});
			hitBttn.x = (settings.width - hitBttn.width) / 2;
			hitBttn.y = /*settings.height - hitBttn.height / 2*/settings.height - upgradeBttn.height / 2 - 65;
			
			upgradeBttn.x = (settings.width - upgradeBttn.width) / 2;
			upgradeBttn.y = settings.height - upgradeBttn.height / 2 - 20;
			
			bodyContainer.addChild(upgradeBttn);
			upgradeBttn.showGlowing();
			bodyContainer.addChild(hitBttn);
			hitBttn.showGlowing();
			
			var skipPrice:int = 0
			if (info.tower[floor + 1] != null) {
				skipPrice = settings.target.info.kskip * (info.tower[floor + 1].c - settings.target.kicks);
			}
			
			accelerateBttn = new MoneyButton({
				caption			:Locale.__e('flash:1382952379751'),
				width			:192,
				height			:50,	
				fontSize		:26,
				fontCountSize	:26,
				radius			:18,
				countText		:skipPrice,
				iconScale		:0.8,
				multiline		:true
			});
			
			upgradeBttn.addEventListener(MouseEvent.CLICK, kickEvent);
			hitBttn.addEventListener(MouseEvent.CLICK, buyAllEvent);
			accelerateBttn.addEventListener(MouseEvent.CLICK, buyKickEvent);
			
			//bodyContainer.addChild(accelerateBttn);
			accelerateBttn.x = ((settings.width - accelerateBttn.width) / 2) + 300;
			accelerateBttn.y = settings.height - accelerateBttn.height / 2 - 35;
			
			upgradeBttn.visible = false;
			hitBttn.visible = false;
			accelerateBttn.visible = false;
			
			if (floor > 0 || settings.target.kicks >= info.tower[floor+1].c) {
				if (info.tower[floor+1] != undefined && settings.target.kicks < info.tower[floor+1].c){
					hitBttn.visible = false;
					accelerateBttn.visible = true;
				}else if (info.tower[floor + 1] == undefined) {
					upgradeBttn.visible = false;
					hitBttn.visible = true;
				}else{
					upgradeBttn.visible = true;
					upgradeBttn.y -= 300;
				}
			}else{
				accelerateBttn.visible = true;
			}
		}
		
		public var skipPrice:int;
		private function buyAllEvent(e:MouseEvent):void {
			if (info.tower[floor + 1] != undefined && settings.target.kicks < info.tower[floor + 1].c)
				return;
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.storageEvent(0, onStorageEventComplete);
		}
		
		private function kickEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			settings.upgradeEvent( {} );
			settings.content = [];
			close();
		}
		
		override public function close(e:MouseEvent = null):void {
			if (settings.hasAnimations == true) {
				startCloseAnimation();
			}else {
				dispatchEvent(new WindowEvent("onBeforeClose"));
				new SimpleWindow({title:"ВСё",text:"Строили мы строили..",description:'И ,наконец, построили!'});
				dispose();
			}
		}
		
		private var price:int;
		private function buyKickEvent(e:MouseEvent):void {
			
			price = (info.tower[floor + 1].c - settings.target.kicks) * settings.target.info.kskip;
			
			if (!App.user.stock.check(Stock.FANT, price))
				return;
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.buyKicks({
				callback:onBuyKicks
			});
		}
		
		private function onBuyKicks():void {
			if (titleTxt)
				bodyContainer.removeChild(titleTxt);
				
			drawStageInfo();	
			//titleTxt.x = kickTextPosX;
			
			Hints.minus(Stock.FANT, price, Window.localToGlobal(accelerateBttn), false, this);
			App.user.stock.take(Stock.FANT, price);
			
			/*titleTxt.y = kickTextPosY;
			titleTxt.x = kickTextPosX;*/
			upgradeBttn.visible = true;
			accelerateBttn.visible = false;
			hitBttn.visible = false;
		}
		
		public function onStorageEventComplete(sID:uint, price:uint):void {
			
			if (price == 0 ) {
				close();
				return;
			}
			var X:Number = App.self.mouseX - upgradeBttn.mouseX + upgradeBttn.width / 2;
			var Y:Number = App.self.mouseY - upgradeBttn.mouseY;
			Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
			close();
		}
		
		private function drawVisitors():void {
			
			back.graphics.beginFill(0xfcebd2);
		    back.graphics.drawRect(0, 0, settings.width - 140, 91);
			back.y = settings.height - back.height - 100;
			back.x = (settings.width - back.width) / 2;
		    back.graphics.endFill();
			back.filters = [new BlurFilter(40, 0, 2)];
		    friendCont.addChildAt(back, 0);
			var dev:Shape = new Shape();
			dev.graphics.beginFill(0xc0804d);
			dev.graphics.drawRect(0, 0, settings.width - 110, 2);
			dev.graphics.endFill();
			
			var dev1:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev1.bitmapData.draw(dev);
			dev1.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			dev1.x = (settings.width - dev1.width) / 2;
			dev1.y = back.y - dev1.height;
			friendCont.addChild(dev1);
			
			var dev2:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev2.bitmapData.draw(dev);
			dev2.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			dev2.x = (settings.width - dev2.width) / 2;
			dev2.y = back.y + back.height;
			friendCont.addChild(dev2);
			
			var text:String = Locale.__e(settings.target.info.text1);
			var label:TextField = drawText(text, {
				fontSize:28,
				autoSize:"center",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x764413,
				border:true
			});
			
			label.width = settings.width - 50;
			label.height = label.textHeight;
			label.x = (settings.width - label.width) / 2;
			label.y = 375;
			
			friendCont.addChild(label);
			
			if (settings['content'].length > 0){
				contentChange();
				drawNotif();
			}else{
				drawNotif();
			}	
		}
		
		private function drawNotif():void 
		{
			if (info.tower[floor + 1] == undefined)
				return;
			
			var bttnSettings:Object = {
				caption		:Locale.__e("flash:1407159672690"),//Пигласить
				width		:170,
				height		:40,	
				fontSize	:25
			}
			
			notifBttn = new Button(bttnSettings);
			notifBttn.y = settings.height - notifBttn.height - 40;
			notifBttn.x = (settings.width - notifBttn.width) / 2;
			friendCont.addChild(notifBttn);
			notifBttn.addEventListener(MouseEvent.CLICK, onNotifClick);
		}
		
		private function onNotifClick(e:MouseEvent):void 
		{
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':
					new AskWindow(AskWindow.MODE_INVITE, {
						target:settings.target,
						title:Locale.__e('flash:1382952380197'), 
						friendException:settings.friendsData,
						inviteTxt:Locale.__e("flash:1382952379977"),
						desc:getTextFormInfo('text4')
					} ).show();
					break;
				case 'NK':
					new AskWindow(AskWindow.MODE_NOTIFY, {
						target:				settings.target,
						title:				Locale.__e('flash:1382952380197'), 
						friendException:	settings.friendsData,
						inviteTxt:			Locale.__e("flash:1382952379977"),
						desc:				getTextFormInfo('text4'),
						message:			info.text8
					} ).show();
					break;
				case 'FS':
					AskWindow.notifyIngameFriends( {
						message:		info.text8
					});
					break;
				default:
					ExternalApi.apiInviteEvent();
			}
		}
		
		override public function drawArrows():void 
		{
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = back.y + back.height / 2 - paginator.arrowLeft.height / 2;
			paginator.arrowLeft.x = -paginator.arrowLeft.width / 2 + 83;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width / 2 - 15;
			paginator.arrowRight.y = y;
			
			
		}
		
		public function updateItems():void 
		{
			if (floor > 0 || settings.target.kicks >= info.tower[floor+1].c) {
				if (info.tower[floor+1] != undefined && settings.target.kicks < info.tower[floor+1].c){
					hitBttn.visible = false;
					accelerateBttn.visible = true;
				}else if (info.tower[floor + 1] == undefined) {
					upgradeBttn.visible = false;
					hitBttn.visible = true;
				}else{
					upgradeBttn.visible = true;
					upgradeBttn.y -= 300;
					/*titleTxt.x = kickTextPosX - 50;
					titleTxt.y = kickTextPosY;*/
				}
			}else{
				accelerateBttn.visible = true;
			}
			
			if (upgradeBttn.visible&&bodyContainer.contains(backDesc)) 
			{
				bodyContainer.removeChild(backDesc);
			}
			if (upgradeBttn.visible&&bodyContainer.contains(whatToPlaceTextLabel)) 
			{
				bodyContainer.removeChild(whatToPlaceTextLabel);
				rewardTextLabel.visible = true;
				rewardTextLabel.x = (settings.width - rewardTextLabel.width) / 2;
				rewardTextLabel.y = upgradeBttn.y + 60;
			}
			
			drawItems();
			progress();		
		}
		
		public override function contentChange():void 
		{			
			contentManager.update(paginator.startCount, paginator.finishCount);		
			//contentManager.update(paginator.startCount, paginator.finishCount);				
		}
	
		override public function dispose():void 
		{
			upgradeBttn.removeEventListener(MouseEvent.CLICK, kickEvent);
			hitBttn.removeEventListener(MouseEvent.CLICK, buyAllEvent);
			if (notifBttn != null) notifBttn.addEventListener(MouseEvent.CLICK, onNotifClick);
			super.dispose();
		}
		
		public function disposeProgress():void 
		{
			bodyContainer.removeChild(progressBar);
		}
		
		public function getTextFormInfo(value:String):String 
		{
			var text:String = settings.target.info[value];
			text = text.replace(/\r/, "");
			return Locale.__e(text);
		}
	}		
}

import core.AvaLoad;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;
import ui.UserInterface;
import wins.Window;

internal class ShareItem extends LayerX {
	
	public var window:*;
	public var uid:*;
	public var time:uint;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var maska:Shape;
	
	public function ShareItem(obj:Object, window:*) {
		
		this.uid = obj.uid;
		this.time = obj.time;
		this.window = window;
		
		bg = Window.backing(72, 77, 20, 'textSmallBacking');
		addChild(bg);
		
		maska = new Shape();
		maska.graphics.beginFill(0xFFFFFF, 1);
		maska.graphics.drawRoundRect(0,0,50,50,15,15);
		maska.graphics.endFill();
		
		
		addChild(maska);
		
		new AvaLoad(App.user.friends.data[uid].photo, onLoad);
		
		var count:int = int(Math.random() * 10) + 1;
		
		tip = function():Object {
			return {
				title	:App.user.friends.data[uid].first_name + " " +App.user.friends.data[uid].last_name
			}
		}
	}
	
	private function onLoad(data:Bitmap):void 
	{
		bitmap = new Bitmap(data.bitmapData);
		addChild(bitmap);
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
		
		maska.x = bitmap.x;
		maska.y = bitmap.y;
		bitmap.mask = maska;
	}
	
	public function dispose():void 
	{
		
	}
}

import core.AvaLoad;
import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class FriendItem extends Sprite
{
	public var bg:Shape;
	public var friend:Object;
	public var mode:int;	
	
	private var title:TextField;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap = new Bitmap();
	private var data:Object;
	private var callBack:Function;
	/*private static var testObject:Object = {
		'0':{
			aka:'Сепан Бандера',
			first_name:'Марина',
			last_name:'Черноиваненко',
			photo:"https://pp.vk.me/c636619/v636619624/485fb/OWPVC8BbERE.jpg",
			sex:2,
			uid:'273302797',
			url:"http://vk.com/id1"
		}, '1':{
			aka:'Сепан Бандера',
			first_name:'Черноиваненко',
			last_name:'Черноиваненко',
			photo:"http://cs316618.userapi.com/u174971289/e_29f86101.jpg",
			sex:2,
			uid:"285426075",
			url:"http://vk.com/id1"
		}
	}*/
	
	public function FriendItem( data:Object )
	{
		this.data = data;
		
		this.friend = App.user.friends.data[data.uid];
		//this.friend = testObject[0];  //------------------------ТЕСТ---------------
		bg = new Shape();
		bg.graphics.beginFill(0xc0804d);
		bg.graphics.drawRoundRect(0, 0, 56, 56, 15, 15);
		
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);		
		
		if (friend.first_name != null || friend.aka != null || friend.photo != null) {
			drawAvatar();
		}else {
			App.self.setOnTimer(checkOnLoad);
		}
		
		var txtBttn:String;
	}
	
	private function drawAvatar():void 
	{
		var first_Name:String = friend.first_name || "";
		if (friend.first_name && friend.first_name.length > 0 && friend.first_name != 'User')
			first_Name = friend.first_name;
		else if (friend.aka && friend.aka.length > 0) {
			first_Name = friend.aka;
		}
		
		var params:Array = first_Name.split(" ");
		if (params.length > 0)
			first_Name = params[0];
			
		var size:Point = new Point(bg.width + 5, 30);
		var pos:Point = new Point(
			(width - size.x) / 2 - 3,
			- 20
		 );
		
		title = Window.drawTextX(first_Name, size.x, size.y, pos.x, pos.y, this, {
			fontSize:20,
			color:0xffffff,
			borderColor:0x502f06,
			autoSize:"center",
			textAlign:"center",
			multiline:true
		});
			
		/*var nmTxt:String = (friend.first_name)?friend.first_name:(friend.aka)?friend.aka:"undefined";
		
		title = Window.drawText(nmTxt.substr(0,15), App.self.userNameSettings({
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0,
			textAlign:'center'
		}));*/
		
		addChild(title);
		//title.width = bg.width + 10;
		//title.x = (bg.width - title.width) / 2;
		//title.y = -5;
		
		new AvaLoad(friend.photo, onLoad);
	}
	
	private function checkOnLoad():void 
	{
		if (friend && friend.first_name != null) {
			App.self.setOffTimer(checkOnLoad);
			drawAvatar();
		}
	}
	
	public function get itemRect():Object
	{
		return {width:70,height:80};
	}
	
	public function set state(value:int):void 
	{
		
	}
	
	private function onLoad(data:*):void 
	{		
			avatar.bitmapData = data.bitmapData;
			avatar.smoothing = true;
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawRoundRect(0, 0, 60, 60, 15, 15);
			shape.graphics.endFill();
			sprite.mask = shape;
			sprite.addChild(shape);
			avatar.scaleX = avatar.scaleY = 1.3;
			avatar.smoothing = true;
			Size.size(sprite, 55, 55);
			sprite.x = (bg.width - sprite.width) / 2 + 2;
			sprite.y = (bg.height - sprite.height) / 2 + 2;
		
	}
	
	public function dispose():void
	{
		callBack = null;
		App.self.setOffTimer(checkOnLoad);
	}
}


import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.elements.PriceLabel;
import wins.Window;
import wins.ShopWindow;

internal class UserShareItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	private var kicks:uint;
	private var type:uint;
	private var kicksNum:uint;
	public var iNum:Object;
	
	public function UserShareItem(obj:Object, window:*) {
		
		this.type = obj.t;
		this.sID = obj.sID;
		this.kicks = window.info.mkicks[sID].c;
		this.item = App.data.storage[sID];
		this.kicksNum = window.info.mkicks[sID].k;
		this.window = window;
		
		//iNum = window.itemsNum;
		
		bg = Window.backing(135, 185, 20, 'itemBacking');
		addChild(bg);
		
		/*if (window.upgradeBttn) 
		{
			removeChild(bg);
		}*/
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		drawTitle();
		drawLabel();
		drawkicksNum();
		
		tip = function():Object 
		{
			return {
				title: Locale.__e(item.title),
				text: Locale.__e(item.description)
			}
		}
		
		//drawCount()
	}
	
	/*private var count_txt:TextField; 
	private var count:int; 

	private function drawCount():void
	{
		count = App.user.stock.count(sID);
		count_txt = Window.drawText(Locale.__e('flash:1382952380305')+" "+String(count),{
			fontSize		:24,
			color			:0xffdc39,
			borderColor		:0x6d4b15,
			autoSize:"left"
		});
		
		//addChild(count_txt);
	}*/
	
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption:window.getTextFormInfo('text7'),
			width:120,
			height:38,
			fontSize:23
		}
		
		if(item.real == 0 || type == 1){
			bttnSettings['borderColor'] = [0xaff1f9, 0x005387];
			bttnSettings['bgColor'] = [0x70c6fe, 0x765ad7];
			bttnSettings['fontColor'] = 0x453b5f;
			//bttnSettings['fontBorderColor'] = 0xe3eff1;
		}
		
		bttn = new Button(bttnSettings);		
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 20;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		if (item.real == 0 && App.user.friends.data[App.owner.id]['energy'] <= 0 &&App.user.stock.data[Stock.GUESTFANTASY] <= 0){
			bttn.state = Button.DISABLED;
		}
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		switch(type) {
			case 2:
				if (!App.user.stock.check(Stock.FANT, item.real)) 
					return;
			break;
			case 3:
				if (!App.user.stock.check(sID, 1)) 
				{
					window.close();
					ShopWindow.findMaterialSource(sID);
					return;
				}
			break;
		}
		
		bttn.state = Button.DISABLED;
		/*
		var boost:int = 0;
		if(item.real > 0)
		boost = 1;*/
		
		//window.blockItems(true);
		/*if(App.user.stock.count(sID) <= 0)
		{
			window.close();
			ShopWindow.findMaterialSource(sID);
		}else*/
		window.settings.mKickEvent(sID, onKickEventComplete, type);
	}
	
	private function onKickEventComplete():void {//sID:uint, price:uint
		//window.disposeProgress();
		
		var sID:uint;
		var price:uint;
		if (type == 1) {
			window.close();
			//window.drawProgress();
			//window.drawItems();
			return;
		}
		else if (type == 2)
		{
			sID = Stock.FANT;
			price = item.price[Stock.FANT];
		}
		else if (type == 3)
		{
			sID = this.sID;
			//sID = Stock.GUESTFANTASY;
			price = 1;
		}	
		
		bttn.state = Button.NORMAL;
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
		window.settings.target.kicks += kicksNum;
		//window.close();
		window.updateItems();
		//window.drawItems();
	}	
	
	private function onLoad(data:Bitmap):void 
	{
		bitmap.bitmapData = data.bitmapData;		
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 - 10;
	}
	
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	private var title:TextField; 
	
	public function drawTitle():void {
		title = Window.drawText(String(item.title), {
			color:0x6d4b15,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:26,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = bg.width - 10;
		title.height = title.textHeight;
		title.y = 10;
		title.x = 5;
		addChild(title);		
	}
	
	private var kicksNumLable:TextField; 
	private var kicksNumAmount:int; 
	
	private function drawkicksNum():void
	{
		kicksNumAmount = kicksNum;
		kicksNumLable = Window.drawText("+"+String(kicksNumAmount),{
			fontSize		:26,
			color			:0x814f31,
			borderColor		:0xffffff,
			autoSize		:"left"
		});		
		addChildAt(kicksNumLable, 3);
		kicksNumLable.y = title.y + title.height - 2;
		kicksNumLable.x = (title.x + (title.width / 2)) - 15;
	}
	
	public function drawLabel():void {
		
		var bttnSettings:Object = {
			caption:window.getTextFormInfo('text7'),
			width:120,
			height:38,
			fontSize:23
		}
		
		var price:PriceLabel;
		var text:String = '';
		var hasButton:Boolean = true;
		if (type == 2) { // за кристалы
			bttnSettings["bgColor"] = [0x97c9fe, 0x5e8ef4];
			bttnSettings["borderColor"] = [0xffdad3, 0xc25c62];
			bttnSettings["bevelColor"] = [0xb3dcfc, 0x376dda];
			bttnSettings["fontColor"] = 0xffffff;			
			bttnSettings["fontBorderColor"] = 0x395db3;
			bttnSettings["greenDotes"] = false;
			bttnSettings["diamond"] = "diamond";
			if (item.price && !bttnSettings["countText"]) 
			{
				bttnSettings["countText"] = item.price[3];
			}
			price = new PriceLabel(item.price);
			addChild(price);
			price.x = (bg.width - price.width) / 2;
			price.y = 128;
		}
		else if (type == 3) {
			var count:int; 
			var count_txt:TextField; 

			count = App.user.stock.count(sID);
			count_txt = Window.drawText("x"+String(count),{
				fontSize		:30,
				color			:0xffffff,
				borderColor		:0x6d4b15,
				autoSize:"left"
			});
			
			count_txt.x = bg.x + bg.width - count_txt.width - 15;
			count_txt.y = 128;
			addChild(count_txt);
		}
		else if (type == 1) { // за фантазию
			var guests:Object = window.settings.target.guests;
			
			if (guests.hasOwnProperty(App.user.id) && guests[App.user.id] > 0 && guests[App.user.id] > App.midnight)
			{
				text = Locale.__e("flash:1382952380288");
				hasButton = false;
			}
			else if (window.settings.target.items <= 0)
			{	
				text = Locale.__e("flash:1383041104026");
				hasButton = false;
			}
			else
			{
				var prOb:Object = new Object();
				prOb[Stock.GUESTFANTASY] = 1;
				price = new PriceLabel(prOb);
				addChild(price);
				price.x = (bg.width - price.width) / 2;
				price.y = 135;
			}
		}
		if (type == 3 && App.user.stock.count(sID) <= 0) 
		{
			bttnSettings["bgColor"] = [0xc7e314, 0x7fb531];
			bttnSettings["borderColor"] = [0xeafed1, 0x577c2d];
			bttnSettings["bevelColor"] = [0xdef58a, 0x577c2d];
			bttnSettings["fontColor"] = 0xffffff;			
			bttnSettings["fontBorderColor"] = 0x085c10;
			bttnSettings["caption"] = Locale.__e("flash:1407231372860");
			
		}
		var label:TextField;
		if(text != '')
		{
			label = Window.drawText(text, {
				color:0x6d4b15,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:20,
				textLeading:-6,
				multiline:true
			});
			
			label.wordWrap = true;
			label.width = bg.width - 10;
			label.height = label.textHeight;
			label.y = 140;
			label.x = 5;
			addChild(label);
		}
		
		bttn = new Button(bttnSettings);
		if (!hasButton)
			return;
			
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 12;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		if (!window.info.tower[window.floor + 1]) 
		{
			bttn.state = Button.DISABLED
		}
	}
}

