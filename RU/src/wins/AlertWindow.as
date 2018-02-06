package wins 
{
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class AlertWindow extends Window
	{
		
		public function AlertWindow(settings:Object = null)
		{
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;
			settings['hasImage'] 		= settings.hasImage || false;
			settings['imageName'] 		= settings.imageName || '';
			settings['descriptionXY']	= settings.descriptionXY || new Point(0,0);
			settings['descSettings']	= settings.descSettings ||{};
			settings['imageXY']			= settings.imageXY || new Point(0, 0);
			settings['description']		= settings.description || '';
			settings['background'] 		= settings.background || 'workerHouseRedBacking';
			super(settings);
		}
		private var preloader:Preloader = new Preloader();
		private var imageBMP:Bitmap = new Bitmap();
		private var descriptionLabel:TextField;
		
		override public function drawBody():void 
		{
			super.drawBody();
			bodyContainer.addChild(preloader);
			preloader.x = settings.width / 2;
			preloader.y = 184;
			if (settings.hasImage && settings.imageName != '')
				drawImage();
			if (settings.hasDescription)
				drawDescription();
		}
		
		private function drawDescription():void
		{
			var descSettings:Object = {
				textAlign:"center",
				width:370,
				fontSize:22,
				wrap:true,
				miltiline:true
			}
			for (var key:String in settings.descSettings)
				descSettings[key] = settings.descSettings[key];
			
			descriptionLabel = drawText( settings.description, descSettings);
			bodyContainer.addChild(descriptionLabel);
			descriptionLabel.x = settings.descriptionXY.x;
			descriptionLabel.y = settings.descriptionXY.y;
		}
		
		private function drawImage():void
		{
			var back:Bitmap = backing(background.width - 85, background.height - 75, 50, 'itemBacking');
			bodyContainer.addChild(back);
			back.x = settings.imageXY.x;
			back.y = 7.5;
			
			bodyContainer.addChild(imageBMP);
			Load.loading(Config.getImage('content', settings.imageName), function(data:*):void { 
				if (bodyContainer.contains(preloader))
					bodyContainer.removeChild(preloader);
				
				imageBMP.bitmapData = data.bitmapData;
				imageBMP.x = settings.imageXY.x;
				imageBMP.y = settings.imageXY.y;
			});
		}
		override public function close(e:MouseEvent = null):void 
		{
			if (settings.onClose != null)
				settings.onClose();
			super.close(e);
		}
	}

}