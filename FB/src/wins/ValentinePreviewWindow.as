package wins 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Unit;
	/**
	 * ...
	 * @author ...
	 */
	public class ValentinePreviewWindow extends PergamentWindow 
	{
		private var picture:Bitmap = new Bitmap();
		private var descPicture:TextField;
		public var helpBttn:Button;
		
		public function ValentinePreviewWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings["width"] = 650;
			settings["height"] = 422;
			settings["faderAlpha"] = 0.2;
			settings["faderAsClose"] = true;
			settings["hasPaginator"] = false;
			settings['description'] = Locale.__e('flash:1497340343228');
			super(settings);		
		}
		
		override public function drawTitle():void{
		}
		
		//public var unitToDelete:Array;
		override public function drawBody():void {
			//exit.y -= 25;
			//exit.x -= 18;
			exit.visible = false;
			/*picture = new Bitmap(Window.textures.pergament);
			picture.x = 40 + (settings.width - picture.width) / 2;
			picture.y = -70;
			bodyContainer.addChild(picture);*/
			Load.loading(Config.getImageIcon('updates/preview', 'booster'), function(data:Bitmap):void{
				picture.bitmapData = data.bitmapData;
				picture.x = 15 + (settings.width - picture.width) / 2;
				picture.y = -90;
				bodyContainer.addChild(picture)
			});
			drawDescription();
			
			//unitToDelete = Map.findUnits([717]);
			/*if (unitToDelete.length > 0){
				
			}*/
			var buttonCapt:String = Locale.__e('flash:1432128036600');
			if (settings.hasOwnProperty('blockButton') && settings.blockButton == true)
				buttonCapt = Locale.__e('flash:1404381496750');
				
			helpBttn = new Button( { 
				caption:buttonCapt,
				width:130,
				height:50,
				radius:12
			});
			helpBttn.x = (settings.width - helpBttn.width) / 2;
			helpBttn.y = settings.height - helpBttn.height - 25;
			bodyContainer.addChild(helpBttn);
			helpBttn.addEventListener(MouseEvent.CLICK, onSearchEvent);
			
		}
		
		public function onSearchEvent(e:MouseEvent = null):void
		{
			//App.map.focusedOn(unitToDelete[0], false);
			//if (settings.hasOwnProperty('blockButton') && settings.blockButton == true)
			//{
				//close();
			//}
			//else{
				//new ShopWindow( { section:100, page:0, glowUpdate:true, currentUpdate:settings.updt.nid} ).show();
				if (App.user.worldID == User.AQUA_HERO_LOCATION)
					new ShopWindow( {find:ShopWindow.AQUA_FURNITURE_1} ).show();
				else
					new ShopWindow( { section:100, page:0, glowUpdate:true, currentUpdate:settings.currentUpdate, openNewsItem:true, find:[1815]} ).show();
				close();
			//}
		}
		
		
		override public function drawDescription():void 
		{			
			var descPicture:TextField = Window.drawText(settings.description, {
				fontSize :30,
				color  :0x7f4015,
				borderColor :0xffffff,
				textAlign :"center",
				textLeading:-4,
				multiline :true,
				width   :450,
				wrap: true
		    });
		    descPicture.x = (settings.width - descPicture.width) / 2;
		    descPicture.y = settings.height - 160;
		    bodyContainer.addChild(descPicture);
		}
		
		
		
	}

}