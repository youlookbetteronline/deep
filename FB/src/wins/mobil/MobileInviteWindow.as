package wins.mobil
{

	/**
	* @author created by WindowGenerator v.Alpha
	* @author Stas Kazachok
	*/

	import buttons.ImageButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import ui.UserInterface;
	import wins.Window;
	import ui.BitmapLoader;
	import flash.text.TextField;

	public class MobileInviteWindow extends Window
	{
		private var locale1:String = Locale.__e("flash:1498565928650"); // Перейди по ссылки и забери награду:
		private var locale2:String = Locale.__e("flash:1394010224398"); // Перейти:
		
		private var link1:String = 'ASBttn'; // Картинка App Store
		private var link2:String = 'GPBttn'; // Картинка Google Play
		private var link3:String = 'gl_star'; // Название png с подарком
		private var URL:URLRequest;
		
		private var item:Object;
		
		public function MobileInviteWindow(settings:Object = null):void 
		{
			
			if (!settings) settings = {};
			
			settings["hasPaginator"]	= settings["hasPaginator"] || false;
			settings["title"]			= Locale.__e("flash:1498564995097");
			settings["width"]			= settings["width"] || 590;
			settings["hasButtons"]		= settings["hasButtons"] || false;
			settings["height"]			= settings["height"] || 580;
			settings["hasArrows"]		= settings["hasArrows"] || false;
			settings['exitTexture']		= 'closeBttnMetal';
			
			
			item = settings['item'] || null;
			
			super(settings);
		}
		
		override public function drawBody():void 
		{
			exit.x -= 16;
			exit.y -= 10;
			titleLabel.x = 70;
			
			var projectImage:BitmapLoader = new BitmapLoader(Config.getImage('mobile', "TotemGiftImage"), 530, 452);
			projectImage.x = -35;
			projectImage.y = -20;
			bodyContainer.addChild(projectImage);
			
			var description:TextField = Window.drawText(locale1, {
				borderColor: 6305539, 
				textAlign: "center", 
				color: 16509184, 
				width: 430, 
				multiline: true, 
				height: 57, 
				wrap: true, 
				autoSize: "center", 
				fontSize: 26
			});
			description.x = (settings.width - description.width) * .5;
			description.y = 25;
			bodyContainer.addChild(description);
			
			var motivationText:TextField = Window.drawText(locale2, {
				borderColor: 6769184, 
				textAlign: "center", 
				color: 16777215, 
				width: 230, 
				multiline: true, 
				height: 35, 
				wrap: true, 
				autoSize: "center", 
				fontSize: 34
			});
			motivationText.x = (settings.width - motivationText.width) * .5;
			motivationText.y = 340;
			bodyContainer.addChild(motivationText);
			
			drawButtons();
			drawReward();
		}
		
		private var ASBttn:ImageButton;
		private var GPBttn:ImageButton;
		public function drawButtons():void 
		{
			Load.loading(Config.getImage('mobile', link1), function(data:Bitmap):void {
				ASBttn = new ImageButton(data.bitmapData, {
					onClick:goToAppStore
				});
				ASBttn.name = 'ios';
				ASBttn.x = 34;
				ASBttn.y = 400;
				bodyContainer.addChild(ASBttn);
			});
			
			Load.loading(Config.getImage('mobile', link2), function(data:Bitmap):void {
				GPBttn = new ImageButton(data.bitmapData, {
					onClick:goToGooglePlay
				});
				GPBttn.name = 'android';
				GPBttn.x = 288;
					
				GPBttn.y = 400;
				bodyContainer.addChild(GPBttn);
			});

		}
		
		public var rewardCont:Sprite;
		public function drawReward():void 
		{	
			var rewardImage:BitmapLoader = new BitmapLoader(Config.getImage('mobile', link3), 154, 138);
			rewardImage.x = 230;
			rewardImage.y = 170;
			bodyContainer.addChild(rewardImage);
			
			var count:int = Numbers.firstProp(item.rewardSocial).val;
			
			//var count:int = 20;
			
			var rewardCounter:TextField = Window.drawText("x"+count, {
				borderColor: 6769184, 
				color: 16777215, 
				width: 78, 
				multiline: true, 
				height: 66, 
				wrap: true, 
				autoSize: "left", 
				fontSize: 48
			});
			rewardCounter.x = 326;
			rewardCounter.y = 263;
			bodyContainer.addChild(rewardCounter);
		}
		
		private function goToAppStore(e:MouseEvent):void 
		{
			URL = new URLRequest(item.appstore);
			navigateToURL(URL);	
			
			Post.send( {
				ctr:		'user',
				act:		'refclick',
				uID:		App.user.id,
				bID:		item.order,
				os:			e.currentTarget.name,
				type:		item.type
			}, function(error:int, data:Object, params:Object):void {
				if (error) 
				{
					return;
				}
				
				close();
				Treasures.bonus(data.bonus, new Point(App.map.mouseX, App.map.mouseY));
				
				//if (!App.user.gotRefBonus[item.type])
					//App.user.gotRefBonus[item.type] = {};
				//
				//if (!App.user.gotRefBonus[item.type][item.order])
					//App.user.gotRefBonus[item.type][item.order] = true;
				
				//App.ui.upPanel.timerEventsContainer.update();
				//App.ui.upPanel.updateContainerPositions();
				//App.ui.systemPanel.timerEventsContainer.update();
				//App.ui.systemPanel.updateContainerPositions();
			});
		}
		
		private function goToGooglePlay(e:MouseEvent):void 
		{
			URL = new URLRequest(item.googleplay);
			navigateToURL(URL);	
			
			Post.send( {
				ctr:		'user',
				act:		'refclick',
				uID:		App.user.id,
				bID:		item.order,
				os:			e.currentTarget.name,
				type:		item.type
			}, function(error:int, data:Object, params:Object):void {
				if (error) 
				{
					return;
				}
				
				close();
				Treasures.bonus(data.bonus, new Point(App.map.mouseX, App.map.mouseY));
				
				//if (!App.user.gotRefBonus[item.type])
					//App.user.gotRefBonus[item.type] = {};
				//
				//if (!App.user.gotRefBonus[item.type][item.order])
					//App.user.gotRefBonus[item.type][item.order] = true;
				
				//App.ui.upPanel.timerEventsContainer.update();
				//App.ui.upPanel.updateContainerPositions();
				//App.ui.systemPanel.timerEventsContainer.update();
				//App.ui.systemPanel.updateContainerPositions();
			});
		}
	}
}

