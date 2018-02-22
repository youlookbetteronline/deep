package wins 
{
	
	import buttons.Button;
	import com.greensock.TweenLite;
	import core.Post;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import units.Animal;
	import units.Barter;
	import units.Techno;
	import units.Tribute;
	import units.Unit;
	
	
	public class DialogWindow extends Window
	{
		
		public var okBttn:Button;
		private var dialog:String;
		private var dialogData:Array;
		
		private var hunter:*
		private var ctree:Unit;
		private var vojd:*
		private var synoptic:*
		private var vojdbarter:*
		private var seal:*
		
		public function DialogWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 550;
			settings['height'] = 400;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['hasExit']	= false;
			settings['hasPaginator'] = false;
			settings['hasTitle'] = false;
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			settings['escExit'] = false;
			settings['delay'] = 10;
			
			settings['timeout'] = 400;
			
			dialog = settings.dialog;
			dialogData = [];
			
			if (dialog) 
			{
				var ss:int = dialog.search(/ [0-99]+:/);
				while (ss != -1)
				{
					dialog = dialog.slice(0, ss+1).concat('\n' + dialog.slice(ss+1, dialog.length));
					ss = dialog.search(/ [0-99]+:/);
				}
				
				var list:Array = dialog.split('\n');
				var reg:RegExp = new RegExp(/[0-9]+:\s/);
				var text:String;
				var personage:int;
				
				for (var i:int = 0; list && i < list.length; i++) {
					personage = int(list[i].substring(0, list[i].indexOf(':')));
					text = list[i].substring(list[i].indexOf(':') + 1, list[i].length);
					
					// Удаление пробелов в начале строки
					text = text.replace(/^[" \d]+/, '');
					
					dialogData.push( { personage:personage, text:text } );
				}
			}
			
			super(settings);
		}
		
		override public function show():void 
		{
			super.show();
			if (settings.qID == 536)
			{
				if (Map.ready)
					placePatsan();
				else
					App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, placePatsan);
				
				
			}
			
			if (settings.qID == 602)
			{
				if (Map.ready)
				{
					placeBarter();
					placeVojd();
				}
				else
				{
					App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, placeBarter);
					App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, placeVojd);
				}
			}
			
			if (settings.qID == 691)
			{
				if (Map.ready)
				{
					placeSynoptic();
				}
				else
				{
					App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, placeSynoptic);
				}
			}
			
			if (settings.qID == 755)
			{
				if (Map.ready)
				{
					placeSeal();
				}
				else
				{
					App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, placeSeal);
				}
			}
			
			if (settings.qID == 923)
			{
				if (Map.ready)
				{
					removeTree();
				}
				else
				{
					App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, removeTree);
				}
			}
		}
		
		private function removeTree():void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, removeTree);
			if (Map.findUnits([Tribute.CTREE]).length < 1)
				return;
			ctree = Map.findUnits([Tribute.CTREE])[0];
			ctree.removable = true;
			ctree.onApplyRemove();
		}
		
		private function placePatsan(e:* = null):void
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, placePatsan);
			if (Map.findUnits([Animal.HUNTER]).length > 0)
				return;
			//var placeOct:Object = App.user.hero.findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:162, z:64}}, 10);
			hunter = Unit.add({sid:Animal.HUNTER, x:162, z:64});
			hunter.buyAction();
			hunter.take();
		}
		
		private function placeBarter(e:* = null):void
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, placeBarter);
			if (Map.findUnits([Barter.VOJDBARTER]).length > 0)
				return;
			vojdbarter = Unit.add({sid:Barter.VOJDBARTER, x:61, z:51});
			vojdbarter.buyAction();
			vojdbarter.take();
		}
		
		private function placeVojd(e:* = null):void
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, placeVojd);
			if (Map.findUnits([Techno.VOJD]).length > 0)
				return;
			vojd = Unit.add({sid:Techno.VOJD, x:26, z:60});
			vojd.buyAction();
			vojd.take();
		}
		
		private function placeSynoptic(e:* = null):void
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, placeSynoptic);
			if (Map.findUnits([Techno.SYNOPTIC]).length > 0)
				return;
			synoptic = Unit.add({sid:Techno.SYNOPTIC, x:26, z:60});
			synoptic.buyAction();
			synoptic.take();
		}
		
		private function placeSeal(e:* = null):void
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, placeSeal);
			if (App.user.worldID == User.HOME_WORLD)
			{
				if (Map.findUnits([Techno.SEAL]).length > 0)
					return;
				seal = Unit.add({sid:Techno.SEAL, x:140, z:159});
				seal.buyAction();
				seal.take();
			}
			else
			{
				var postObject:Object = {
					ctr:App.data.storage[Techno.SEAL].type,
					act:'buy',
					uID:App.user.id,
					wID:4,
					sID:Techno.SEAL,
					x:140,
					z:159
				}
				Post.send(postObject, function():void{});
				
			}
			
		}
		
		override public function drawBackground():void {}
		
		private var dialogs:Vector.<Dialog>;
		private var currentShow:uint = 0;
		private var currentY:uint = 0;
		private var timeout:int = 0;
		override public function drawBody():void {
			
			okBttn = new Button( {
				width:180,
				height:52,
				fontSize:26,
				caption:Locale.__e("flash:1382952380242")
			});
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.alpha = 0;
			okBttn.name = 'DialogWindow_okBttn';
			okBttn.addEventListener(MouseEvent.CLICK, closeThis);
			
			createDialogs();
			
			timeout = setTimeout(showNext, 200);
			
		}
		
		private function onReadEvent(e:MouseEvent):void {
			if (settings.callback != null)
				settings.callback();
				
			if ((settings.qID == 234 || settings.qID == 225) && App.user.hero)
				App.user.hero.checkPet();
			
			close();
		}
		
		override public function close(e:MouseEvent = null):void 
		{
			super.close(e);
			if((App.social == 'OK' || App.social == 'VK'  || App.social == 'MM'  || App.social == 'FS') && App.user.mode == User.OWNER && App.user.worldID == User.HUNT_MAP && settings.qID == 574)
				lionCostile();
		}
		
		protected function lionCostile():void 
		{
			var lions:Array = Map.findUnits([2057, 2125]);
			if (lions.length <= 0){
				var lion:Unit = Unit.add( {sid:2057, x:34, z:70} );
				lion.take();
				lion.buyAction();
			}
		}

		
		private function closeThis(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
				
			e.currentTarget.state = Button.DISABLED;
			okBttn.removeEventListener(MouseEvent.CLICK, closeThis);
			App.user.quests.readEvent(settings.qID, function():void {
				
				close();
			});
		}
		
		private function createDialogs():void {
			
			dialogs = new Vector.<Dialog>;
			var change:Boolean = false;
			var prev:Boolean;
			for (var i:int = 0; i < dialogData.length; i++) {
				prev = (i > 0 && dialogData [i].personage != dialogData[i - 1].personage);
				change = prev && !change;
				
				var dialog:Dialog = new Dialog(dialogData[i], Boolean(i % 2));
				dialogs.push(dialog);
			}
		}
		
		private function showNext():void {
			
			if (currentShow < dialogs.length) {
				var dialog:Dialog = dialogs[currentShow];
				var positionX:int = (dialog.side) ? settings.width - dialog.width : 0;
				dialog.x = (dialog.side) ? positionX + 20 : positionX - 20;
				dialog.y = currentY;
				dialog.alpha = 0;
				bodyContainer.addChild(dialog);
				
				
				currentShow ++;
				currentY += dialog.backingHeight + 20;
				
				if (currentY > settings.height)
					TweenLite.to(bodyContainer, 0.4, { y:settings.height - currentY } );
				
				TweenLite.to(dialog, 0.4, { x:positionX, alpha:1 } );
			}
			
			if (currentShow >= dialogs.length) {
				timeout = setTimeout(showConfirmButton, 200);
			}else {
				timeout = setTimeout(showNext, settings.timeout);
			}
		}
		private function showConfirmButton():void {
			App.self.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel, false, 10);
			
			okBttn.y = currentY;
			bodyContainer.addChild(okBttn);
			//okBttn.state  = Button.DISABLED;
			TweenLite.to(okBttn, 0.4, { alpha:1, onComplete:function():void {
				/* setTimeout(function():void
				 {
					okBttn.state  = Button.NORMAL;
				 }, dialogs.length * 1000);*/
				 
				if (!App.user.quests.tutorial) return;
				
				okBttn.showGlowing();
				okBttn.showPointing('right',0, okBttn.height - 44, bodyContainer);
			}} );
		}
		
		private function onWheel(e:MouseEvent):void {
			if (settings.height > bodyContainer.height) return;
			
			e.stopImmediatePropagation();
			
			if (e.delta > 0) {
				bodyContainer.y += 50;
			}else {
				bodyContainer.y -= 50;
			}
			
			if (bodyContainer.y > 0) bodyContainer.y = 0;
			if (bodyContainer.y < settings.height - bodyContainer.height) bodyContainer.y = settings.height - bodyContainer.height;
		}
		
		override public function dispose():void {
			super.dispose();
			
			App.self.removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			
			if(okBttn)
				okBttn.removeEventListener(MouseEvent.CLICK, onReadEvent);
			
			if (timeout)
				clearTimeout(timeout);
			
			while (dialogs && dialogs.length > 0) {
				var dialog:Dialog = dialogs.shift();
				dialog.dispose();
			}
		}
		
	}

}

import flash.display.Bitmap;
import flash.text.TextField;
import flash.utils.setTimeout;
import ui.BitmapLoader;
import wins.Window;

internal class Dialog extends LayerX {
	
	private var back:Bitmap;
	private var personageIcon:BitmapLoader;
	private var dialogLabel:TextField;
	private var titlePersonage:TextField;
	
	public var currWidth:int;
	public var personage:int;
	public var text:String;
	public var side:Boolean;
	
	public function Dialog(data:Object, side:Boolean = false) {
		
		this.side = side;
		
		currWidth = data.width || 420;
		personage = data.personage;
		text = data.text;
		
		dialogLabel = Window.drawText(text, {
			fontSize:		28,
			width:			currWidth - 160,
			textAlign:		'center',
			color:			0x51300f,
			borderColor:	0xf2e6cc,
			multiline:		true,
			wrap:			true
		});
		dialogLabel.y = 30;
		addChild(dialogLabel);
		
		//back = Window.backing(currWidth - 60, dialogLabel.height + dialogLabel.y * 2, 20, 'shopBackingSmall1');
		back = Window.backing(currWidth - 60, dialogLabel.height + dialogLabel.y * 2, 50, 'tipWindowUp');
		addChildAt(back, 0);
		
		if (personagePreview)
		{
			personageIcon = new BitmapLoader(Config.getImage('questIcons', personagePreview), 0, 0, 1, relocate);
			addChild(personageIcon);
		}
		//drawTitlePersonage();
		if (side) {//правая колонка
			personageIcon.scaleX = -1;
			dialogLabel.x = 30;
			personageIcon.x = 300 + 110;
			//dialogLabel.border = true;
		}else {//левая колонка
			personageIcon.x = 25;
			back.x = 65;
			dialogLabel.x = 140;
			//dialogLabel.border = true;
		}
		
		//graphics.beginFill(0xff0000, 0.5);
		//graphics.drawRect(0, 0, currWidth + 10, back.height * 0.5);
		//graphics.endFill();
	}
	
	public function get personagePreview():String {
		if (personage == 3) {
			if (App.user.sex == 'm')
				return 'boy';
			
			return 'girl';
		}
		
		return String(personage);
	}
	
	public function get backingHeight():int {
		return back.height;
	}
	
	private function relocate():void {
		if (!App.isSocial('SP')){
			drawTitlePersonage();
		}
		setTimeout(function():void {
			if (personageIcon) {
				personageIcon.y = back.y + back.height * 0.5;
				
				switch(personage) {
					case 2:
						personageIcon.y -= 60;
						break;
					case 3:
						personageIcon.y -= 66;
						break;
					default:
						personageIcon.y -= 56;
				}
				if (side)
					titlePersonage.x = back.x + back.width - titlePersonage.width / 2;//personageIcon.x + (personageIcon.width - titlePersonage.width) / 2;
				else
					titlePersonage.x = back.x - titlePersonage.width / 2 
				titlePersonage.y = personageIcon.y + personageIcon.height - 20;
			}
		}, 10);
		
	}
	
	private function drawTitlePersonage():void
	{
		titlePersonage = Window.drawText(App.data.personages[personage].name, {
			color:		0xffd05b,	
			borderColor:0x573317,
			fontSize:	30,
			textAlign:	'center'
		})
		titlePersonage.width = titlePersonage.textWidth + 5;
		if (side)
				titlePersonage.x = back.x + back.width - titlePersonage.width / 2;//personageIcon.x + (personageIcon.width - titlePersonage.width) / 2;
		else
			titlePersonage.x = back.x - titlePersonage.width / 2 
		titlePersonage.y = personageIcon.y + personageIcon.height - 20;
		addChild(titlePersonage);
		
	}
	
	public function dispose():void {
		if (parent)
			parent.removeChild(this);
	}
	
}