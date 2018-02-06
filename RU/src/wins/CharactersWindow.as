package wins 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	/**
	 * ...
	 * @author ...
	 */
	public class CharactersWindow extends Window
	{
		private var titleQuest:TextField;
		private var titleShadow:TextField;
		private var descLabel:TextField;
		
		private var winContainer:Sprite;
		private var titleFilterContainer:Sprite;
		private var confirmBttn:Button;
		public var quest:Object = { };
		public var curHeight:int = 0;
		
		public function CharactersWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 444;
			settings['height'] = 500;
			settings['hasPaginator'] = false;				//Окно с пагинацией
			settings['hasButtons'] = false;
			settings['hasExit']	= false;
			settings['hasPaginator'] = false;
			settings['hasTitle'] = false;			
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			settings['escExit'] = false;
			
			super(settings);
			
			quest = App.data.quests[settings.qID];
		}
		
		
		private var preloader:Preloader = new Preloader();
		private var titleQuestContainer:Sprite;
		private var character:Bitmap = new Bitmap();
		
		override public function drawBackground():void {
			
		}
		
		override public function drawBody():void 
		{
			//1 - Зикимо
			//2 - Профессор
			//3 - Джейн
			//4 - Мартин
			//6 - Мира, Дух времени
			//7 - Коммуникатор
			//var character:Bitmap = new Bitmap();
			bodyContainer.addChild(preloader);
			preloader.x = 38;
			preloader.y = 184;
			
			drawMessage();
			drawBttns();
			
			bodyContainer.addChildAt(character, 2);
			
			var characterPerv:String = (App.data.personages.hasOwnProperty(quest.character)) ? App.data.personages[quest.character].preview : "octopus";
			
			if(quest.character == 3){
				if(App.user.sex == 'm'){
					characterPerv = "boy";
				}else{
					characterPerv = "girl";
				}
			}
			
			Load.loading(Config.getQuestIcon('preview', characterPerv), function(data:*):void {
				bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;
				
				switch(App.data.personages[quest.character].preview) {
					case 'octopus_jonhy':
						character.x = -character.width / 2 + 80;//400
						character.y = (settings.height - character.height) / 2;
					break;
					case 'snail':
						character.x = -character.width / 2 + 20;//400
						character.y = (settings.height - character.height) / 2 - 60;
					break;
					/*case 'firstPers':
						character.x = -(character.width / 4) * 3 + 110;//170
						character.y = (curHeight - character.height)/2 + 100;//-37
					break;
					case 'boy':
						character.x = -(character.width / 4) * 3 + 96;//156
						character.y = 50;//-40
					break;
					case 'professor':
						character.x = -80;//-20
						character.y = -22;//-68
					break;
					case 'chief':
						character.x = -143;//-83
						character.y = -70;//-58
					break;
					case 'zikimund':
						character.x = -150;
						character.y = -80;
					break;
					case 'spirit':
						character.x = -160;//-100
						character.y = -40;//-50
					break;
					case 'ingrid':
						character.x = -160;//-100
						character.y = -40;//-50
					break;
					case 'prince_turn':
						character.x = -160;//-100
						character.y = -40;//-50
					break;
					case 'AI':
						character.x = -character.width + 340;//400
						character.y = 20;//-70
					break;*/
					default:
						character.x = -character.width / 2 + 80;//400
						character.y = settings.height - character.height - 0;
					break;
				}
				
				//bodyContainer.addChildAt(character, 0);
				//bodyContainer.addChildAt(character,1);
			});
		}
		
		private function drawBttns():void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952380242"),
				fontSize:30,
				width:170,
				height:46,
				hasDotes:false
			};
			
			confirmBttn = new Button(bttnSettings);
			/*confirmBttn.tip = function():Object { 
				return {
					title:"",
					text:Locale.__e("flash:1382952380242")
				};
			};*/
		
			confirmBttn.x = (winContainer.width - confirmBttn.width)/2 - 50;
			confirmBttn.y = winContainer.height - confirmBttn.height + 80;
			
			winContainer.addChild(confirmBttn);
			
			confirmBttn.addEventListener(MouseEvent.CLICK, closeThis);
			
			if(App.user.quests.tutorial)
				App.user.quests.glowTutorialBttn(this, confirmBttn);
		}
		
		private function closeThis(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
				
			e.currentTarget.state = Button.DISABLED;
			
			confirmBttn.removeEventListener(MouseEvent.CLICK, closeThis);
			App.user.quests.readEvent(settings.qID, function():void {
				/*if (settings.qID == 541) 
				{
					new AchivementsWindow({findAmulet:true}).show();
				}*/
				close();
			});
		}
		
		private function drawMessage():void 
		{
			var titlePadding:int = 20;
			var descPadding:int = 30;
			
			var descMarginX:int = 10;
			
			winContainer = new Sprite();
			titleFilterContainer = new Sprite();
			App.user.quests.data
			var fontSize:int = 50;
			do{
				titleQuest = Window.drawText(quest.title, {
					color:0xffffff,
					borderColor:0x65371b,
					borderSize:4,
					fontSize:fontSize,
					multiline:true,
					textAlign:"center"
				});
				titleQuest.autoSize = TextFieldAutoSize.CENTER;
				titleQuest.y = 72 + titleQuest.textHeight/2;
				fontSize -= 1;
			}
			while (titleQuest.width >= 380);
			
			descLabel = Window.drawText(quest.description, {
				color:0x65371b, 
				borderColor:0xfef2dc,
				fontSize:26,
				multiline:true,
				textAlign:"center"
			});
			descLabel.wordWrap = true;
			descLabel.width = 360;
			descLabel.height = descLabel.textHeight + 10;
			
			curHeight = titleQuest.height + descLabel.height + titlePadding*2 + 50;
			
			if (curHeight < 200) curHeight = 200;
			
			//var bg:Bitmap = Window.backing(settings.width, curHeight, 50, 'dialogueBacking');
			var bg:Bitmap = backing(settings.width, curHeight , 50, 'tipWindowUp');
			titleQuest.x = ((bg.width - titleQuest.width) / 2) - 40;

			descLabel.y = titleQuest.y + titleQuest.height;
			descLabel.x = (bg.width - descLabel.width)/2 + 140;
			winContainer.addChild(bg);
			bg.x -= 50;
			bg.y += 120;
			
			titleFilterContainer.addChild(titleQuest);
			
			var myGlow:GlowFilter = new GlowFilter();
			myGlow.inner = false;
			myGlow.color = 0xbfaa81;
			myGlow.blurX = 5;
			myGlow.blurY = 5;
			myGlow.strength = 20;
			myGlow.alpha = 0.4;
			titleFilterContainer.filters = [myGlow];
			
			
			winContainer.addChild(titleFilterContainer);			
			
			bodyContainer.addChild(winContainer);
			bodyContainer.addChild(descLabel);
			winContainer.x = (settings.width - winContainer.width) / 2 + 180;
			winContainer.y = -25;
			//drawMirrowObjs('diamondsTop', bg.width / 2 - titleQuest.width / 2 + 135, bg.width / 2 + titleQuest.width / 2 + 145, 70, true, true);
		}	
	}
}