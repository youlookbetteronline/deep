package wins {
	
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	public class GroupWindow extends Window {
		
		private var bitmapImage:Bitmap;
		private var bitmapTitle:Bitmap;
		private var descLabel:TextField;
		private var desc2Label:TextField;
		private var checkBttn:CheckboxButton;
		private var enterBttn:Button;
		private var back:Bitmap = new Bitmap();
		public static var inGroup:Boolean = false;
		public static var groupLink:String = '';
		private var infoBttn:ImageButton = null;

		
		public function GroupWindow(settings:Object = null) {
			if (!settings) settings = { };
			settings['width'] = 590;
			settings['height'] = 440;
			settings['hasTitle'] = false;
			settings['hasPaginator'] = false;
			settings['background'] = 'dialogueLightBacking';
			settings['title'] = Locale.__e('flash:1481298339658');
			settings['fontBorderColor'] = 0x136111;
			//settings['hasExit'] = false;
			
			super(settings);
		}
		
		public static function addWindow():void {
			//if (App.isSocial('VK', 'OK', 'MM', 'FB') && App.user.level >= 4 && App.user.storageRead('gw', 1) == 1) {
				//// Найти ссылку на группу для соцсети
				//if (App.data.options.hasOwnProperty('GroupLinks')) {
					//var soc:Object = JSON.parse(App.data.options.GroupLinks);
					//if (soc.hasOwnProperty(App.social))
						//groupLink = soc[App.social];
				//}
				//
				//// Если ссылки нет (groupLink == null) не показываем окно
				//if (groupLink.length == 0) return;
				//
				//// Проверяем наличие в группе и показываем окно
				//if (ExternalInterface.available) {
					//ExternalApi.checkGroupMember(function(param:*):void {
						//if (param == 1)
							//inGroup = true;
					//});
					//setTimeout(function():void {
						//if (!inGroup) {
							//new GroupWindow().show();
						//}
					//}, 5000);
				//}else {
					new GroupWindow().show();
				//}
			//}
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height ,50, 'capsuleWindowBacking');
			
			layer.addChild(background);
			
			back = backing(525, 365, 40, "paperClear");
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2;
			bodyContainer.addChild(back);
		}
			
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 38,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x136111,			
				borderSize 			: 2,	
				
				shadowBorderColor	: 0x136111,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -20;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			bodyContainer.addChild(titleLabel);
			
		}
		
		override public function drawBody():void {
			super.drawBody();
		
			// Рисование элементов
			drawInfoBttn();
			
			drawMirrowObjs('decSeaweed', settings.width + 58, - 58, settings.height - 170, true, true, false, 1, 1);
			
			var titleBackingBmap:Bitmap = backingShort(358, 'ribbonGrenn',true,1.3);
			titleBackingBmap.x = settings.width/2 -titleBackingBmap.width/2;
			titleBackingBmap.y = -30;
			bodyContainer.addChild(titleBackingBmap);
			drawTitle();
			
			var imageP:Preloader = new Preloader();
			imageP.x = settings.width / 2;
			imageP.y = 120;
			bodyContainer.addChild(imageP);
			bitmapImage = new Bitmap();
			bitmapTitle = new Bitmap();
			
			bodyContainer.addChild(bitmapImage);
			bodyContainer.addChild(bitmapTitle);
			
			var textFirstPart:String = Locale.__e('flash:1481300340242').split('\n')[0];
			var textSecondPart:String = Locale.__e('flash:1417426901521').split('\n')[1];
			
			descLabel = Window.drawText(textFirstPart, {
				width:			310,
				textAlign:		'center',
				fontSize:		28,
				color:			0x6f4320,
				borderColor:	0xffffff,
				borderSize:		5,
				textLeading:	-7,
				wrap:			true,
				filters:		[new DropShadowFilter(2, 90, 0x604729, 1, 0, 0)]
			});
			descLabel.y = 240;
			descLabel.x = (settings.width - descLabel.width) / 2 + 50;
			//bodyContainer.addChild(descLabel);
			
			desc2Label = Window.drawText(textSecondPart, {
				width:			270,
				textAlign:		'center',
				fontSize:		14,
				color:			0xffe694,
				borderColor:	0x5f2e06,
				borderSize:		5,
				wrap:			true,
				textLeading:	-7,
				filters:		[new DropShadowFilter(2, 90, 0x604729, 1, 0, 0)]
			});
			desc2Label.y = descLabel.y + descLabel.height - 12;
			desc2Label.x = (settings.width - desc2Label.width) / 2;
			//bodyContainer.addChild(desc2Label);
						
			// блок выбора - показывать окно в следующий раз или нет
			var checkCont:Sprite = new Sprite();
			checkBttn = new CheckboxButton( {
				width: 190,
				multiline:false,
				wordWrap:false,
				fontSize:24,
				fontSizeUnceked: 24,
				captionChecked:Locale.__e('flash:1417427612599'),
				captionUnchecked:Locale.__e('flash:1417427612599')
				//state:CheckboxButton.PASSIVE
			});
			checkBttn.checked = CheckboxButton.UNCHECKED;
			//checkBttn.scaleX = checkBttn.scaleY = 0.8;
			/*var checkLabel:TextField = Window.drawText(Locale.__e('flash:1417427612599'), {
				width: 			150,
				autoSize:		'left',
				color:			0x7c3f15,
				border:			false,
				fontSize:		24
				
			});
			checkLabel.x = checkBttn.x + checkBttn.width + 100;
			checkLabel.y = (checkBttn.height - checkLabel.height) / 2;*/
			checkCont.addChild(checkBttn);
			//checkCont.addChild(checkLabel);
			bodyContainer.addChild(checkCont);
			checkCont.x = (settings.width - 225) / 2 + 0;
			checkCont.y = settings.height - 80;// desc2Label.y + desc2Label.height + 5;
			
			enterBttn = new Button({
				color:		0xffffff,
				borderColor:0x7f3d0e,
				fontSize:	32,
				width:		160,
				height:		52,
				caption:	Locale.__e('flash:1417427832679')
			});
			enterBttn.x = (settings.width - enterBttn.width) / 2;
			enterBttn.y = settings.height - enterBttn.height / 2 - 12;
			enterBttn.addEventListener(MouseEvent.CLICK, onEnter);
			enterBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(enterBttn);
			
			var fish:Bitmap = new Bitmap(Window.textures.decFish2);
			fish.scaleX = fish.scaleY = 1.4; 
			fish.scaleX = - fish.scaleX; 
			fish.smoothing = true;
			fish.x = infoBttn.x + 60;
			fish.y = infoBttn.y + 300;
			bodyContainer.addChild(fish);
					
			Load.loading(Config.getImage('promo', 'Community1Pic'), function(data:Bitmap):void {
				if (bodyContainer.contains(imageP)) bodyContainer.removeChild(imageP);
				bitmapImage.bitmapData = data.bitmapData;
				bitmapImage.smoothing = true;
				bitmapImage.x = (settings.width - bitmapImage.width) / 2;
				bitmapImage.y = (settings.height - bitmapImage.height) / 2 - 10;
				
				Load.loading(Config.getImage('promo/images', 'groupGiftTitle_' + App.lang), function(data:Bitmap):void {
					bitmapTitle.bitmapData = data.bitmapData;
					if (bitmapImage.width - 20 < bitmapTitle.width) {
						bitmapTitle.width = bitmapImage.width - 20;
					}
					bitmapTitle.x = (settings.width - bitmapTitle.width) / 2 - 178;
					bitmapTitle.y = bitmapImage.y + bitmapImage.height - bitmapTitle.height - 10;
					bodyContainer.addChild(descLabel);
					bitmapTitle.filters = [new DropShadowFilter(3.0, 45, 0, 0.5, 4, 4, 1, 2, false, false, false)];
					
				});
			});
			
			exit.y -= 25;
		}
		
		//public function onEnter(e:MouseEvent = null):void {
			////if (checkBttn.state == CheckoxButton.ACTIVE) App.user.storageStore('gw', 0);
			//if (groupLink.length > 0)
				//navigateToURL(new URLRequest(groupLink));
			//
			//close();
		//}
		
		public function onEnter(e:MouseEvent = null):void {
			//Log.alert('Group link ' + App.self.flashVars.group);
			if (checkBttn.checked == CheckboxButton.CHECKED) App.user.storageStore('gw', 1);
			//if (groupLink.length > 0)
				navigateToURL(new URLRequest(App.self.flashVars.group), "_blank");
			
			close();
		}
		
		override public function dispose():void {
			super.dispose();
			
			enterBttn.removeEventListener(MouseEvent.CLICK, onEnter);
		}
		private function drawInfoBttn():void 
		{
			infoBttn = new ImageButton(textures.infoBttnPink);
			bodyContainer.addChild(infoBttn);
			infoBttn.x = exit.x + 5;
			infoBttn.y = exit.y + 50;
			infoBttn.addEventListener(MouseEvent.CLICK, info);
			
			
		}
		
		private function info(e:MouseEvent = null):void {
		
			
		}
	}
}