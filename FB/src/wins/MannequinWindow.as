package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import units.Anime2;
	public class MannequinWindow extends Window 
	{	
		public var background:Bitmap;
		public var okayBttn:Button;
		public var info:Object = { };
		public var building:Object = {};
		private var bitmapOne:Bitmap;
		private var anime:Anime2;
		public function MannequinWindow(settings:Object=null)  
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['title'] = settings.title || settings.target.info.title || Locale.__e('flash:1382952380254')//Помощь;
			settings['width'] = 300;	
			settings['height'] = 230;			
			settings['hasTitle'] = true;
			settings['hasButtons'] = true;
			settings['hasPaginator'] = false;
			settings['callback'] = settings.callback || null;			
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			settings['hasExit'] = false;
			settings['hasTitle'] = false;
			settings['popup'] = true;
			settings['fontColor'] = 0xffdf61;
			settings['fontBorderColor'] = 0x804c18;
			settings['shadowBorderColor'] = 0x804c18;
			settings['fontBorderSize'] = 3;
			
			info = App.data.storage[settings.target.sid];
			
			super(settings);			
		}
		
		override public function drawBackground():void
		{
			background = backing(settings.width, settings.height, 30, 'banksBackingItem');
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			var titleText:TextField = drawText(Locale.__e('flash:1493213629892'), {
				fontSize	:36,
				textAlign	:"center",
				color		:0xffffff,
				borderColor	:0x803d08,
				multiline	:true,
				wrap		:true,
				width		:200
				
			});
			//titleText.border = true;
			titleText.x = 80;
			titleText.y = 20;
			layer.addChild(titleText);
			
			for (var _building:* in info.target)
			{
				building['info'] = App.data.storage[_building];
				building['percent'] = info.target[_building];
				break;
			}
			
			var textOne:TextField = drawText(Locale.__e('flash:1493212102547',[building.info.title]), {
				fontSize	:30,
				textAlign	:"center",
				color		:0x803d08,
				multiline	:true,
				border		:false,
				wrap		:true,
				width		:settings.width - 20
				
			});
			//textOne.border = true;
			textOne.x = (settings.width - textOne.width) / 2;
			textOne.y = 90;
			layer.addChild(textOne);
			
			var percentText:TextField = drawText(String(building.percent) +'%', {
				fontSize	:36,
				textAlign	:"center",
				color		:0xfffa74,
				borderColor	:0x803d08,
				multiline	:true,
				wrap		:true,
				width		:150
				
			});
			percentText.x = (settings.width - percentText.width) / 2;
			percentText.y = textOne.y + textOne.height - 5;
			layer.addChild(percentText);
			
			okayBttn = new Button( {
				caption:Locale.__e('flash:1382952380298'),
				fontSize:26,
				width:160,
				hasDotes:false,
				height:47
			});
			okayBttn.addEventListener(MouseEvent.CLICK, close);
			
			bodyContainer.addChild(okayBttn);
			okayBttn.x = (settings.width - okayBttn.width) / 2;
			okayBttn.y = settings.height - okayBttn.height / 2;
			
			//bitmapOne = new Bitmap();
			//bitmapOne.filters = [new DropShadowFilter(4, 45, 0, .55, 0, 0)];
			
			Load.loading(Config.getSwf(info.type, info.preview), onLoadImg);
		}
		private function onLoadImg(data:*):void 
		{				
			drawAnimation(data)
			//bitmapOne.bitmapData = data.bitmapData;
			//Size.size(bitmapOne, 90, 90);
			//layer.addChild(bitmapOne);
			//bitmapOne.smoothing = true;
			//bitmapOne.x = 68 - bitmapOne.width / 2;
			//bitmapOne.y = - bitmapOne.height / 3;
			//bodyContainer.addChild(bitmapOne);
		}
		
		private function drawAnimation(swf:Object):void 
		{
			anime = new Anime2(swf, { w:120, h:130 });
			anime.x = 68 - anime.width / 2;
			anime.y = - anime.height / 3;
			//anime.x = background.width * 0.5 - anime.width * 0.5;
			//anime.y = background.height * 0.5 - anime.height * 0.5;
			bodyContainer.addChild(anime);
			anime.filters = [new DropShadowFilter(4, 45, 0, .55, 0, 0)];
		}
	}

}