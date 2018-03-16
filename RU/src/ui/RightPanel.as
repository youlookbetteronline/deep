package ui 
{
	import buttons.ImagesButton;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import wins.CalendarWindow;
	import wins.CollectionWindow;
	import wins.FBFreebieWindow;
	import wins.FreebieWindow;
	import wins.FreeGiftsWindow;
	import wins.FriendsRewardWindow;
	import wins.GiftWindow;
	import wins.GroupWindow;
	import wins.MapWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.TravelWindow;
	import wins.Window;
	
	public class RightPanel extends Sprite
	{
		
		public var bttnMainGifts:ImagesButton;
		public var bttnMainCollections:ImagesButton;
		public var bttnMap:ImagesButton;
		public var freebieBttn:ImagesButton;
		
		public var counterPanel:Bitmap;
		public var giftCounter:TextField;
		public var collCounter:TextField;
		
		private var giftCounterCont:Sprite
		private var collCounterCont:Sprite
		
		public var bttnCommunity:ImagesButton;
		
		public function RightPanel():void 
		{
			bttnMainGifts = new ImagesButton(UserInterface.textures.interRoundBttn, UserInterface.textures.giftsIcon,null, 0.8);
			bttnMainGifts.tip = function():Object {
				return {
					title:Locale.__e("flash:1382952379798"),
					text:Locale.__e("flash:1382952379799")
				};
			}
			//addChild(bttnMainGifts);
			bttnMainGifts.addEventListener(MouseEvent.CLICK, onMainGifts);
			
			counterPanel = new Bitmap(UserInterface.textures.simpleCounterRed);
			
			var textSettings:Object = {
				color:0xffffff,
				borderColor:0x35717d,
				fontSize:16,
				textAlign:"center"
			};
			
			giftCounter = Window.drawText(String(25), textSettings);
			giftCounter.width = 60;
			giftCounter.height = giftCounter.textHeight;
			giftCounter.x = counterPanel.width / 2 - 31;
			giftCounter.y = counterPanel.height / 2 - giftCounter.height / 2 - 1;
			//
			giftCounterCont = new Sprite();
			giftCounterCont.addChild(counterPanel);
			giftCounterCont.addChild(giftCounter);
			giftCounterCont.x = bttnMainGifts.x - 12;
			giftCounterCont.y = bttnMainGifts.y + 30;
			//addChild(giftCounterCont);
			giftCounterCont.addEventListener(MouseEvent.CLICK, onMainGifts);
			
			update();
			resize();
		}
		
		public function hide():void {
			this.visible = false;
		}
		
		public function show():void {
			this.visible = true;
		}
		
		public function resize():void {
			this.x = App.self.stage.stageWidth - 63;
			this.y = App.self.stage.stageHeight - 126;
		}
		
		public function addCommunityButton():void {
			bttnCommunity = new ImagesButton(UserInterface.textures.community, null, {/*onClick:onFreebie,*/ tip: {title:Locale.__e('flash:1382952380109')/*, text:Locale.__e('flash:1428501372225')*/}});
			
			bttnCommunity.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				bttnCommunity.hideGlowing();
				bttnCommunity.hidePointing();
				new GroupWindow().show();
			});
			bttnCommunity.scaleX = bttnCommunity.scaleY = 0.8;
			bttnCommunity.x = -160;
			bttnCommunity.y = - bttnCommunity.height + 42;
			addChild(bttnCommunity);
		}
		
		public function addFreebie():void {
			
			if (App.social != 'VK' && App.social != 'DM')
				return
				
			if (App.social != 'VK'&&App.social != 'OK'&&App.social != 'MM'&&App.social != 'FS'&&App.social != 'FB'||App.user.quests.tutorial||(App.user.freebie&&App.user.freebie.hasOwnProperty('status')&&App.user.freebie.status > 4))
			return
			
			if (freebieBttn != null) {
				return;
			}
			//return;
			
			//if(App.social == 'PL' && !(App.self.flashVars.hasOwnProperty('platform') && App.self.flashVars.platform == 'nk'))
				//return;
			
			//if (freebieBttn != null)
				//return;
				
			freebieBttn = getMoneyIcon(freebieBttn);
			
			if(App.user.freebie){
				freebieBttn.settings['ID'] = App.user.freebie.ID || 0;
			}
			freebieBttn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				freebieBttn.hideGlowing();
				freebieBttn.hidePointing();
				onFreebie(e);
			});
			//
			freebieBttn.y = -110;
			freebieBttn.x = -15;
			//if (Capabilities.playerType != 'StandAlone')
				addChild(freebieBttn);
		//
			////rectangle.y -= 100;
			//if (App.user.settings.f == '0') {
				//App.user.settings.f = '1';
				//Post.addToArchive('freebie read: ' + App.user.settings.f);
				//startGlow();
				//App.user.settingsSave();
			//}
			//
			//function startGlow():void {
				//freebieBttn.showGlowing();
				//freebieBttn.showPointing("top", 10, 90, freebieBttn);
			//}
			//startGlow();
			
		}
		
		public function hideFreebie():void {
			removeChild(freebieBttn);
			freebieBttn.removeEventListener(MouseEvent.CLICK, onFreebie);
			freebieBttn = null;
		}
		
		private function onMainGifts(e:MouseEvent):void
		{
			if (App.user.gifts.length == 0)
				new FreeGiftsWindow().show();
			else		
				new FreeGiftsWindow( {
					mode:FreeGiftsWindow.TAKE
				}).show();
		}
		
		public function onBttnCalendar(e:MouseEvent):void {
			new CalendarWindow().show();
		}
		
		/*public function onMapClick(e:MouseEvent):void
		{
			if (!App.isSocial('DM','VK','OK','FS','MM','FB','NK', 'HV','YB','MX','AI')) 
			{
				new SimpleWindow( {
					title:Locale.__e('flash:1382952379804'),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e("flash:1382952379805"),
					popup:true,
					buttonText:Locale.__e("flash:1382952380298"),
					ok:function():void {
						new ShopWindow( { find:[726] } ).show();
					}
				}).show();
				return
			}
			var hasGuide:Boolean = false;
			if (App.user.stock.count(726) > 0)
				hasGuide = true;
			else {
				var guids:Array = Map.findUnits([726]);
				for each(var _guid:* in guids)
					if (_guid.level >= _guid.totalLevels)
						hasGuide = true;
			}
			
			if (hasGuide) {
				openTravelWindow();
			}
			else
			{
			
				new SimpleWindow( {
					title:Locale.__e('flash:1382952379804'),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e("flash:1382952379805"),
					popup:true,
					buttonText:Locale.__e("flash:1382952380298"),
					ok:function():void {
						new ShopWindow( { find:[726] } ).show();
					}
				}).show();
				
				new TravelWindow().show();
				
				new SimpleWindow( {
					'label':SimpleWindow.ATTENTION,
					'title': Locale.__e('flash:1421686497877'),
					'text': Locale.__e('flash:1423495911093')
				}).show();	
				
			}
		}*/
		
		public function onMapClick(e:MouseEvent):void
		{
			new TravelWindow().show();
		}
		
		private function openTravelWindow():void {
			if (App.user.mode == User.OWNER) {
				new TravelWindow().show();
			}else{
				new MapWindow({ 
					sID:441
				}).show();
			}
		}
		
		private function onFreebie(e:MouseEvent):void
		{
			if (App.isSocial('FB','PL')) {
				new FBFreebieWindow().show();
				return;
			}
			if(App.user.freebie.hasOwnProperty('status')&&App.user.freebie.status > 0){
				new FriendsRewardWindow( { ID:e.currentTarget.settings.ID } ).show();
			}else {
				new FreebieWindow( { ID:e.currentTarget.settings.ID } ).show();
			}
			
			//new FreebieWindow( { ID:'5512c4f88cdbc'} ).show();
			//var many:Boolean = false;
			//var fast:Boolean = true;
			//
			//if(App.user.freebie == null || App.user.freebie.status == 1){
				//fast = false;
			//}
			//
			//if (fast) {
				//new FreebieWindow( { ID:e.currentTarget.settings.ID } ).show();
			//}
		}
		
		public function update():void
		{
			giftCounter.text = String(App.user.gifts.length);
			if (App.user.gifts.length == 0) 
				giftCounterCont.visible = false;	
			else 							
				giftCounterCont.visible = true;	
				
			/*collCounter.text = String(CollectionWindow.completed());
			if (Number(collCounter.text) == 0) 
				collCounterCont.visible = false;	
			else 							
				collCounterCont.visible = true;		*/
		}
		
		private function getMoneyIcon(bttn:ImagesButton):ImagesButton {
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(85, 85, true, 0), "auto", true);
			
			bttn = new ImagesButton(bitmap.bitmapData, UserInterface.textures.blueCristal); 
			bttn.iconBmp.visible = false;
			bttn.visible = false;
			//bttn.addGlow(Window.textures.iconEff, 1, 0.7, 0x8cd72d);
			
			var title:TextField = Window.drawText(Locale.__e("flash:1382952380285"), {
				color:0xffffff,
				borderColor:0x0f3343,
				fontSize:18,
				textAlign:'center',
				multiline:true,
				width:70,
				distShadow:0
			});
			
			title.wordWrap = true;
			//title.border = true;
			title.height = title.textHeight + 4;
			
			
				bttn.bitmapData = new Bitmap(UserInterface.textures.saleBacking2).bitmapData;
				
				bttn.addChild(title);
				bttn.bitmap.scaleX = bttn.bitmap.scaleY = .8;
				title.x = (bttn.bitmap.width - title.width)/2;
				title.y = (bttn.bitmap.height - title.height) / 2 + 18;
				
				bttn.iconBmp.visible = true;
				bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = 1.1;
				bttn.iconBmp.smoothing = true;
				//bttn.iconBmp.x -= 5;
				bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width) / 2 + 1;
				bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2 - 3;
				//bttn.iconBmp.y -= 7;
				//bttn.glowIcon.visible = true;
				
				bttn.visible = true;
			
			
			return bttn;
			
		}
		
		private var _mode:int = User.OWNER;
		public function set mode(value:*):void {
			_mode = value;
			if (value == User.OWNER) 
			{
				bttnMainGifts.visible = true;
				bttnMainCollections.visible = true;
				freebieBttn.visible = true;
				giftCounterCont.visible = true;
				collCounterCont.visible = true;
				bttnMap.y = bttnMap.height - 6;
			}
			
			if (value == User.GUEST) 
			{
				bttnMainGifts.visible = false;
				bttnMainCollections.visible = false;
				freebieBttn.visible = false;
				bttnMap.y = bttnMainCollections.y;
				giftCounterCont.visible = false;
				collCounterCont.visible = false;
			}
			
			if (value == User.OWNER) 
			{
				bttnMainGifts.visible = false;
				bttnMainCollections.visible = false;
				freebieBttn.visible = false;
				bttnMap.y = bttnMainCollections.y;
				giftCounterCont.visible = false;
				collCounterCont.visible = false;
			}
			
		}
	}
}