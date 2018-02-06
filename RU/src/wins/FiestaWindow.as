package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.TimeConverter;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	/**
	 * ...
	 * @author Денис...
	 */
	
	public class FiestaWindow extends Window
	{
		private var background:Bitmap;
		private var textInfo:TextField;
		private var back:Bitmap;
		private var textDay:TextField ;
		private var eventManager:Object = JSON.parse(App.data.options['EventManager']);
		private var ico:BitmapData;
		private var bttnArr:Array = new Array;	
		private var shop:Object;
		
		public function FiestaWindow(settings:Object = null):void
		{		
			if (settings == null) {
				settings = new Object();
			}
			settings["section"] = settings.section || "all"; 
			settings["page"] = settings.page || 0; 
			settings["find"] = settings.find || null;
			settings["title"] = Locale.__e(eventManager.title);
			settings["width"] = 600;
			settings["height"] = 450;
			settings["hasPaginator"] = false;
			settings["hasArrows"] = false;
			settings["itemsOnPage"] = 0;
			settings["buttonsCount"] = 0;
			settings["background"] = 'buildingBacking';
				
			super(settings);
		}
		

		override public function drawBackground():void
		{			
			background = backing(settings.width, settings.height, 50, settings.background);
			bodyContainer.addChild(background);
			background.x = -10;
			background.y = -90;
		}
		
		override public function drawBody():void {
			back = backing(450,190, 0, 'paperBacking');
				back.x =background.x+ 40;
				back.y = background.y + 90;
			bodyContainer.addChild(back);
			
			var fonTitle:Bitmap = backingShort(750,'bigGoldRibbon');
				fonTitle.x = -80;
				fonTitle.y =  -120;
			bodyContainer.addChild(fonTitle);
			
			var back2:Bitmap = backing(170,60, 0, 'counterBacking');
				back2.x =back.x+back.width/2-back2.width/2;
				back2.y = back.y+20;
			bodyContainer.addChild(back2);
			
			var textLost:TextField = Window.drawText(Locale.__e(eventManager.textLeft), {	//Осталось
				color:0xFFFFFF,
				fontSize:42,
				borderColor:0x804040,
				borderSize:2,
				width:70,
				textAlign:"center"
				});
				textLost.x =back.x+back.width/2-textLost.width/2;
				textLost.y = back.y+5;
			bodyContainer.addChild(textLost);
			
			textDay= Window.drawText(Locale.__e("flash:1382952379727"), {	//Дни
				color:0xFFFF00,
				fontSize:42,
				borderColor:0x000000,
				borderSize:3,
				width:70,
				textAlign:"center"
				});
				textDay.x =back.x+back.width/2-textDay.width/2;
				textDay.y = textLost.y+25;
			bodyContainer.addChild(textDay);
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 +5, settings.width / 2 + settings.titleWidth / 2 - 5, -90, true, true);
				textInfo = Window.drawText(Locale.__e(eventManager.textDesc), {	
				fontSize:27,
				color:0x844e1f,
				borderColor:0xffffff,
				borderSize:1,
				multiline:true,
				wrap:true,
				width:350,
				textAlign:"center"
			});
				textInfo.height = textInfo.textHeight+8;
				textInfo.x = back.x + 40;
				textInfo.y = back.y +75;
			bodyContainer.addChild(textInfo);	
			
		
		Load.loading(
			Config.getImage('events', eventManager.img1.bitmap),function(data:*):void {
			ico = data.bitmapData;
			draw(1);
		});

		Load.loading(
			Config.getImage('events', eventManager.img2.bitmap),function(data:*):void {
			ico = data.bitmapData;
			draw(2);
		});			
			drawBtt();
			App.self.setOnTimer(update);
			update();
		}
		
		private function update():void 
		{
			if (eventManager.timeFinish > App.time) {//eventManager.timeFinish[App.social] 
				textDay.text = TimeConverter.timeToDays(eventManager.timeFinish - App.time);
			}else this.close();
		}
		
		private function draw(jj:int):void 
		{		
			var image:Bitmap;
			if(jj==1){
				image = new Bitmap(ico);
				bodyContainer.addChild(image);
				image.x = eventManager.img1.dx-30;
				image.y = eventManager.img1.dy-120-60;
				if (eventManager.img1.scaleX == -1) {
						image.scaleX *= -1;
				}
			}else if (jj == 2) {
				image = new Bitmap(ico);
				bodyContainer.addChild(image);
				image.x = eventManager.img2.dx-80;
				image.y = eventManager.img2.dy-115;
				if (eventManager.img2.scaleX == -1) {
						image.scaleX *= -1;
				}
			}	
		}
		
		private function drawBtt():void 
		{
			for (var i:int = 0; i < eventManager.bttn.length;i++ ){			
			var bttn:Button=new Button( {
				caption:Locale.__e(eventManager.bttn[i].title),	//к первому заданию
				fontSize:30,
				width:180,
				fontColor:				0xFFFFFF,				//Цвет шрифта
				fontBorderColor:		0x814f31,				//Цвет обводки шрифта	
				height:50
			});
			bttn.x = eventManager.bttn[i].dx;
			bttn.y = eventManager.bttn[i].dy-60;
			bodyContainer.addChild(bttn);
			bttn.addEventListener(MouseEvent.CLICK, onMouseClick);
			bttnArr.push(bttn);
			}
		}
		
		private function onMouseClick(e:MouseEvent):void 
		{
				var max:int = 0;
				var mas:Array = new Array();
				for (var i:* in  App.data.updates) {
					for (var j:*in App.data.updates[i].social) {
						if(App.data.updates[i].social[j]==App.SOCIAL)
							if(App.data.updates[i].order>max && App.data.updates[i].quests>0){	
								max = App.data.updates[i].order;
								mas[0] =	i;
						}
					}
				}
				
				var qID:int = App.data.updates[mas[0]].quests
				var quest:Object = App.data.quests[qID];
				var chapterID:int = quest.chapter;
				var masQuests:Array = new Array();

			switch(e.target.caption){	
			case("К заданиям"):
				
				new QuestsChaptersWindow({find:[20],popup:true}).show();
				break;
			
			case("Награда"): 
				var sid:int = 1488;
				new HappyRewardWindow({happy:sid,popup:true}).show();
				break;
			
			case("Магазин"): 
				shopIt();
				var window:ShopWindow;
				if (App.user.quests.tutorial)
				return;
				window = new ShopWindow({popup:true});
				window.show();
				window.setContentNews(shop.data);
				break;
			
			default: break;
			
			}
		}
		
		private function shopIt():void 
		{	
			if (shop == null) {
				shop = new Object();
			shop = {
				data:[],	
				page:0
			};
			
			for (var updateID:* in App.data.updates) {	
				if(	updateID == "5640c649983d6"){
					if (!App.data.updates[updateID].social || !App.data.updates[updateID].social.hasOwnProperty(App.social)) 
						continue;
			var updateObject:Object = {
					id:updateID,
					data:[]
				}
					var updatesItems:Array = [];
					var items:Object = App.data.updates[updateID].items;
					
					for (var _sid:* in items)
					{
						if (!App.data.storage.hasOwnProperty(_sid))
							continue					
						if (App.data.storage[_sid].visible == 0 /*&& !Config.admin*/) continue;
						if (App.data.storage[_sid].type == 'Collection') continue;
						if (App.data.storage[_sid].type == 'Lands') continue;
						updatesItems.push( { sid:_sid, order:items[_sid] } );
					}	
					updatesItems.sortOn('order', Array.NUMERIC);
					for (var i:int = 0; i < updatesItems.length; i++) {
						updateObject.data.push(App.data.storage[updatesItems[i].sid]);
					}
					shop.data=updateObject.data;	
				}
			}
			}	
		}
		
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
					
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = 10-60;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
		}
		
		override public function drawExit():void {
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 60;
			exit.y = -25-60;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
	
		
		override public function dispose():void {
			App.self.setOffTimer(update);
			super.dispose();
		}
	}
}
