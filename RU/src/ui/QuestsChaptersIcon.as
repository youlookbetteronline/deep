package ui
{	
	import buttons.ImagesButton;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.QuestIcon;
	import wins.Window;
	
	public class QuestsChaptersIcon extends QuestIcon
	{	
		public var checkMark:Bitmap;
		
		public function QuestsChaptersIcon(item:Object, time:uint, questType:String = 'opened') {
			
			super(item);
			tip = function():Object {
				var text:String = questData.description;
				if (App.user.quests.isOpen(questData.ID) || App.user.quests.isFinish(questData.ID))
				{
					if (questData.missions) 
					{
						text = '';
						var count:int = 1;
						for (var mid:* in questData.missions) {
							if (text.length > 0) text += '\n';
							
							var have:int = (App.user.quests.data.hasOwnProperty(qID)) ? App.user.quests.data[qID][mid] : 0;
							var txt:String;
							if (questData.missions[mid].event == "upgrade")
							{
								var unitsSe:Array = Map.findUnits(questData.missions[mid].target);
								for each(var obj:* in unitsSe)
								{
									trace("Level = " + obj.level);
									trace("ID = " + obj.id);
									txt = obj.level + '/' + questData.missions[mid].need;
								}
								if (obj == undefined)
								{
									txt = '0/' + questData.missions[mid].need;
								}
								text += ' - ' + questData.missions[mid].title + ' ' + txt;
							} else if (questData.missions[mid].func != 'sum') 
							{
								if (have == questData.missions[mid].need) {
									txt = '1/1';
								}else {
									txt = '0/' + questData.missions[mid].need;//'0/1';
								}
								text += ' - ' + questData.missions[mid].title + ' ' + txt;
							} else {
								text += ' - ' + questData.missions[mid].title + ' ' + String(App.user.quests.data[qID][mid] || 0) + '/' + String(questData.missions[mid].need);
							}
							count++;
						}
					}
				}else{
					text = Locale.__e('flash:1491401404055');
				}
				
				return {
					title:		questData.title,
					text:		text
				}
			};
			
		}
		
		override public function drawIcon():void 
		{
			var hide:Boolean = false;
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xFF0000, 0.0);
			shape.graphics.drawRect(0, 0, HEIGHT, HEIGHT);
			shape.graphics.endFill();
			addChild(shape);
			
			preloader = new Preloader();
			preloader.scaleX = preloader.scaleY = 1;
			preloader.x = 36;
			preloader.y = 40;
			addChild(preloader);
			
			backing = new Bitmap();
			addChild(backing);
			
			bg = new Bitmap();
			addChild(bg);
			
			var character:String = (App.data.personages.hasOwnProperty(questData.character)) ? App.data.personages[questData.character].preview : "octopus";
			var backPrev:String = (questData.backview > 0) ? questData.backview : '1';
			
			if(questData.character == 3){
				if(App.user.sex == 'm'){
					character = "boy";
				}else{
					character = "girl";
				}
			}
			Load.loading(Config.getImageIcon('quests/backings', backPrev), function(data:Bitmap):void 
			{
				backing.bitmapData = data.bitmapData;
			});
			Load.loading(Config.getImageIcon('quests/icons', character), function(data:Bitmap):void 
			{
				removeChild(preloader);
				preloader = null;
				
				bg.bitmapData = data.bitmapData;
				bg.smoothing = true;
				bg.y = -12;
				resize();
				
				if (txtTime) {
					txtTime.x = (bg.width - txtTime.width) / 2;
					txtTime.y = bg.height - txtTime.height + 10;
				}
				
				if (timerLabel) {
					timerLabel.x = (bg.width - timerLabel.width) / 2;
					timerLabel.y = bg.height - timerLabel.height + 7;
				}
			});
			if (App.user.quests.isFinish(questData.ID))
			{
				checkMark = new Bitmap(Window.textures.checkmarkBig);
				Size.size(checkMark, 40, 40);
				checkMark.smoothing = true;
				checkMark.x = 41;
				checkMark.y = 46;
				addChild(checkMark);
			}
			if (!App.user.quests.isOpen(questData.ID) && !App.user.quests.isFinish(questData.ID))
			{
				UserInterface.colorize(this, 0x000000, .5);
			}
			if (App.user.quests.isOpen(questData.ID) && !App.user.quests.isFinish(questData.ID))
			{
				addEventListener(MouseEvent.CLICK, onQuestOpen);
				addEventListener(MouseEvent.ROLL_OVER, onOver);
				addEventListener(MouseEvent.ROLL_OUT, onOut);
			}
			
			if (questData.duration > 0) {
				drawTime();
			}
			
			if (!App.user.quests.tutorial && item.fresh && isNewItem()) {
				glowIcon(1);
			}
				
			if (questData.hasOwnProperty('glow') && questData.glow == 1) {
				showGlowing();
			}
			
			if (Config.admin) {
				var guestIdLabel:TextField = Window.drawText(qID.toString() + '\n' + ((questData.update && App.data.updates[questData.update]) ? App.data.updates[questData.update].title : ''), {
					textAlign:	'center',
					width:		70,
					fontSize:	18,
					color:		0xffffff,
					borderColor:0x111111,
					multiline:	true,
					wrap:		true
				});
				guestIdLabel.y = 50;
				addChild(guestIdLabel);
			}
		}
		
	}
	
}
