package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.IsoConvert;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	
	public class GroupGiftWindow extends Window 
	{
		
		private var bitmapImage:Bitmap;
		private var bitmapTitle:Bitmap;
		private var descLabel:TextField;
		private var desc2Label:TextField;
		private var checkBttn:CheckboxButton;
		private var enterBttn:Button;
	
		
		public static var inGroup:Boolean = false;
		public static var groupLink:String = '';
		
		public function GroupGiftWindow(settings:Object = null) 
		{
			if (!settings) settings = { };
			settings['width'] = settings['width'] || 404;
			settings['height'] = settings['height'] || 338;
			settings['hasTitle'] = false;
			//settings['title'] = 'asdasd';
			settings['hasPaginator'] = false;
			settings['background'] = 'paperBacking';
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
					new GroupGiftWindow().show();
				//}
			//}
		}
		
		override public function drawBackground():void {
			
			var background:Bitmap = backing(settings.width, settings.height, 50, settings.background);
			background.y += 50;
			layer.addChild(background);
		}
		
		public var groupGiftLabel:TextField;
		override public function drawBody():void {

			super.drawBody();
			
			// Рисование элементов
			var imageP:Preloader = new Preloader();
			var bigGold:Bitmap = Window.backingShort(586, "bigGoldRibbon");
			
			imageP.x = settings.width / 2;
			imageP.y = 120;
			bodyContainer.addChild(imageP);
			bitmapImage = new Bitmap();
			bitmapTitle = new Bitmap();
			
			drawPresent();
			bodyContainer.addChild(bitmapImage);
			bodyContainer.addChild(bitmapTitle);
			
			
			
			var textFirstPart:String = Locale.__e('flash:1417426901521').split('\n')[0];
			var textSecondPart:String = Locale.__e('flash:1417426901521').split('\n')[1];
			
			descLabel = Window.drawText(textFirstPart, {
				width:			270,
				textAlign:		'center',
				fontSize:		25,
				color:			0xffe294,
				borderColor:	0x533405,
				borderSize:		5,
				textLeading:	-7,
				wrap:			true,
				filters:		[new DropShadowFilter(2, 90, 0x604729, 1, 0, 0)]
			});
			descLabel.y = 240;
			descLabel.x = (settings.width - descLabel.width) / 2;
			//bodyContainer.addChild(descLabel);
			
			desc2Label = Window.drawText(textSecondPart, {
				width:			270,
				textAlign:		'center',
				fontSize:		17,
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
			
			var divider:Bitmap = backingShort(370, 'dividerLight');
			//divider.transform.colorTransform = new ColorTransform(2, 3, 3);
			divider.alpha = 0.8;
			divider.y = descLabel.y + descLabel.height - 7;
			divider.x = (settings.width - divider.width) / 2;
			//bodyContainer.addChild(divider);
			
			// блок выбора - показывать окно в следующий раз или нет
			var checkCont:Sprite = new Sprite();
			checkBttn = new CheckboxButton( {
				width: 150,
				multiline:false,
				wordWrap:false,
				fontSize:20,
				captionChecked:Locale.__e('flash:1417427612599'),
				captionUnchecked:Locale.__e('flash:1417427612599')
				//state:		CheckboxButton..PASSIVE
			});
			//checkBttn.scaleX = checkBttn.scaleY = 0.8;
			var checkLabel:TextField = Window.drawText(Locale.__e('flash:1417427612599'), {
				autoSize:		'left',
				color:			0x6a4528,
				borderColor:	0xfbf5d5,
				fontSize:		21
			});
			checkLabel.x = checkBttn.x + checkBttn.width;
			checkLabel.y = (checkBttn.height - checkLabel.height) / 2;
			checkCont.addChild(checkBttn);
			//checkCont.addChild(checkLabel);
			//bodyContainer.addChild(checkCont);
			checkCont.x = (settings.width - checkCont.width) / 2;
			checkCont.y = desc2Label.y + desc2Label.height + 5;
			
			enterBttn = new Button( {
				fontSize:	40,
				width:		200,
				height:		60,
				caption:	Locale.__e('flash:1382952379737')
			});
			enterBttn.x = (settings.width - enterBttn.width) / 2;
			enterBttn.y = checkCont.y + checkCont.height + 10;
			enterBttn.addEventListener(MouseEvent.CLICK, onEnter);
			bodyContainer.addChild(enterBttn);
			
			Load.loading(Config.getImage('promo', 'Community1Pic'), function(data:Bitmap):void {
				if (bodyContainer.contains(imageP)) bodyContainer.removeChild(imageP);
				bitmapImage.bitmapData = data.bitmapData;
				bitmapImage.smoothing = true;
				bitmapImage.x = (settings.width - bitmapImage.width) / 2 + 5;
				bitmapImage.y = -193/*bitmapImage.height / 2 -60*/;
				
				bigGold.x = bitmapImage.x - (Math.abs(bigGold.width - bitmapImage.width) / 2);
				bigGold.y = bitmapImage.y + bitmapImage.height - bigGold.height * 1.2;
				
				bodyContainer.addChild(bigGold);
				
				var ttlParams:Object = 
				{
					title			:String(App.user.level),
					fontSize		:45,//32,
					width			:300,
					color			:0xf8fce5,
					borderColor		:0x974a14,
					textAlign		:'center',
					borderSize		:2
				}
				groupGiftLabel = Window.drawText(Locale.__e('flash:1419937168202'), ttlParams);
				bodyContainer.addChild(groupGiftLabel);
				//groupGiftLabel.x = bigGold.x
				centerOn(groupGiftLabel, bigGold);
				
				//titleLabel.y += 200;
				//layer.y -= 500;
				
				Load.loading(Config.getImage('promo/images', 'groupGiftTitle_' + App.lang), function(data:Bitmap):void {
					bitmapTitle.bitmapData = data.bitmapData;
					if (bitmapImage.width - 20 < bitmapTitle.width) {
						bitmapTitle.width = bitmapImage.width - 20;
						bitmapTitle.scaleY = bitmapTitle.scaleX;
					}
					bitmapTitle.x = (settings.width - bitmapTitle.width) / 2;
					bitmapTitle.y = bitmapImage.y + bitmapImage.height - bitmapTitle.height - 10;
					

				});
			});
			
			this.y += 50;
			fader.y -= 50;
			
			exit.y += 30;
		}
		
		public var presentItem:groupGiftItem;
		public function drawPresent():void {
			var fogLeft:Bitmap = new Bitmap(Window.textures.magicalFog);
			var fogRight:Bitmap = new Bitmap(Window.textures.magicalFog);
			bodyContainer.addChild(fogLeft);
			bodyContainer.addChild(fogRight);
			fogLeft.x = 28;
			fogLeft.y = fogRight.y = 181;
			fogRight.scaleX = -1;
			fogRight.x = 251 + fogRight.width;
			presentItem = new groupGiftItem(this, settings.sid );
			bodyContainer.addChild(presentItem);
			//presentItem.x = (settings.width - groupGiftItem.size) / 2;
			//presentItem.y = (settings.height - groupGiftItem.size) / 2;
			presentItem.x = 147 + groupGiftItem.size / 2;
			presentItem.y = 214 + groupGiftItem.size / 2;
		}
		
		public function onEnter(e:MouseEvent = null):void {
			//if (checkBttn.state == CheckoxButton.ACTIVE) App.user.storageStore('gw', 0);
			//if (groupLink.length > 0)
				//navigateToURL(new URLRequest(groupLink));
			var tresItem:Object = { };
			tresItem[settings.sid] = 1;
			tresItem = Treasures.convert(tresItem);
			var conv:Object = IsoConvert.screenToIso(presentItem.x, presentItem.y);
			//var point:Point = new Point(IsoConvert.isoToScreen(presentItem.x,presentItem.y).x, IsoConvert.isoToScreen(presentItem.x,presentItem.y).y);
			var point:Point = new Point(conv.x,conv.y);
			Treasures.bonus(tresItem, point, null, true);
			close();
		}
		
		override public function dispose():void {
			super.dispose();
			
			enterBttn.removeEventListener(MouseEvent.CLICK, onEnter);
		}
	}
}
import wins.GroupGiftWindow;
import wins.Window;
import buttons.Button;
import com.flashdynamix.motion.extras.BitmapTiler;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.external.ExternalInterface;
import flash.geom.ColorTransform;
import flash.net.URLRequest;
import flash.utils.setTimeout;
	
internal class groupGiftItem extends LayerX {
	
	public var itmBack:Bitmap = new Bitmap();
	public var itmGift:Bitmap = new Bitmap();
	public var giftEffect:Bitmap = new Bitmap();
	public var giftContiner:Sprite = new Sprite();
	public var item:Object;
	public static var size:uint = 100;
	public var eff:Function;
	
	public function groupGiftItem(win:GroupGiftWindow, sid:String):void {
		itmBack = new Bitmap(Window.textures.instCharBacking);
		giftEffect = new Bitmap(Window.textures.glowingBackingNew);
		size = itmBack.width;
		item = App.data.storage[sid];
		Load.loading(Config.getIcon(item.type, item.view), onLoad);
		this.addChild(itmBack);
		giftEffect.x = (-giftEffect.width) / 2;
		giftEffect.y = (-giftEffect.height) / 2;
		giftContiner.addChild(giftEffect);
		addChild(giftContiner);
		itmBack.x = (-itmBack.width) / 2;
		itmBack.y = (-itmBack.height) / 2;
		this.addChild(itmGift);
		giftContiner.alpha = 0;
		eff = function():void {
			if (!giftContiner || !giftContiner.parent || !giftEffect) {
				App.self.setOffEnterFrame(eff);
			}
			if(giftContiner.alpha < 1){
				giftContiner.alpha += 0.05;
			}else {
				giftContiner.alpha = 1;
			}
			giftContiner.rotation += 2;
		}
		App.self.setOnEnterFrame(eff);
	}
	
	public function onLoad(data:Bitmap):void {
		itmGift.bitmapData = data.bitmapData;
		itmGift.x = -data.width / 2;
		itmGift.y = -data.height / 2;
		App.ui.flashGlowing(itmGift);
		
	}
}