package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	
	public class RouletteRewardWindow extends Window 
	{
		private var okBttn:Button;
		public var frontBacking:Bitmap;	
		
		public function RouletteRewardWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = 350;
			settings['height'] = 220;
			settings['title'] = Locale.__e('flash:1456332919950');//Подарок
			settings['hasPaginator'] = false;
			settings["faderAlpha"] = 0.000000001;
			settings['background'] = 'paperClear';
			
			super(settings);
			
			//this.y += 90;
		}
		
		override public function drawBackground():void {
			if (settings.background!=null) 
			{
				var fish1:Bitmap = new Bitmap(Window.textures.decFish1);
				fish1.x = - fish1.width;
				fish1.scaleX = fish1.scaleY = 0.5;
				fish1.y = settings.height - fish1.height - 10;
				
				var fish2:Bitmap = new Bitmap(Window.textures.decFish2);
				fish2.x = settings.width - fish2.width / 3;
				fish2.y = 60;
				
				layer.addChild(fish1);
				layer.addChild(fish2);	
				
				var background:Bitmap = backing(settings.width, settings.height, 40, settings.background);
				layer.addChild(background);
			}
		}
		
		override public function drawBody():void 
		{
			for (var pr:* in settings.prize) {
				//for (var pr:* in settings.prize[iq]) {
					var sid:int = settings.prize/*[iq]*/[pr];
				//}
			}			
			
			//fader.y -= 90;
			exit.visible = false;
			titleLabel.visible = false;	
			
			drawMirrowObjs('decSeaweed', settings.width + 59, - 59, -5, true, true);
			
			var titleText:TextField = drawText(App.data.storage[pr].title, 
			{
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 23,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0x7f3d0e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			
			titleText.x = settings.width / 2 - titleText.width / 2;
			titleText.y = -20;
			bodyContainer.addChild(titleText);
			
			okBttn = new Button( {
				height:50,
				width:165,
				caption:Locale.__e('flash:1404394519330')//Спасибо!
			});
			
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - okBttn.height * 2 + 10;
			okBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			okBttn.addEventListener(MouseEvent.CLICK, onOk);
			bodyContainer.addChild(okBttn);
			
			var textDesc:TextField = drawText(Locale.__e('flash:1382952380000'), {//Награда
				width:settings.width,
				textAlign:'center',
				fontSize:45,
				color:0xfaff77,
				borderColor:0xa35514
			});
			
			//drawMirrowObjs('diamondsTop', settings.width / 2 - textDesc.width / 2 + 140, settings.width / 2 + textDesc.width / 2 - 140, -30, true, true);
			
			textDesc.y = - 48 - textDesc.textHeight / 2 ;
			bodyContainer.addChild(textDesc);
			
			if (settings.hasOwnProperty('prize')){
				drawPrize();
			}
		}
		
		private function drawPrize():void
		{
			for (var s:* in settings.prize) {
				//for (var s:* in settings.prize[iz]) {
					var count:int = settings.prize/*[iz]*/[s];
				//}
			}			
			
			/*for (var iz:* in settings.prize) {
				for (var pr:* in settings.prize[iz]) {
					var sid:int = settings.prize[iq][pr];
				}
			}*/
			
			//Лучи
			/*var rays:Bitmap = new Bitmap(Window.textures.sharpShining, "auto", true);
			rays.x = (settings.width - rays.width) / 2
			rays.y = 55;
			rays.scaleX = rays.scaleY = 1;*/
			//bodyContainer.addChild(rays);
			
			var rewardContainer:LayerX = new LayerX();
			bodyContainer.addChild(rewardContainer);
			
			//Пузырек
			var bg:Bitmap = new Bitmap(Window.textures.clearBubbleBacking, "auto", true)
			bg.x = (settings.width - bg.width) / 2
			bg.y = 15;
			rewardContainer.addChild(bg);			
			
			var icon:Bitmap = new Bitmap();
			rewardContainer.addChild(icon);
			
			Load.loading(Config.getIcon(App.data.storage[s].type, App.data.storage[s].preview), function(data:*):void {
				icon.bitmapData = data.bitmapData;
				icon.smoothing = true;
				Size.size(icon, bg.width - 20, bg.width - 20);
				icon.x = bg.x + bg.width / 2 - icon.width / 2;
				icon.y = bg.y + bg.height / 2 - icon.height / 2 - 5;
			});
			
			rewardContainer.tip = function():Object { 
				return {
					title:App.data.storage[s].title,
					text:App.data.storage[s].description
				};
			};
			
			var countText:TextField = drawText(String(count) , {
				width:settings.width,
				textAlign:'center',
				fontSize:30,
				color:0xffffff,
				borderColor:0x60331c
			});
			countText.y = bg.y + bg.height - 30;
			countText.x += 30;
			bodyContainer.addChild(countText);
		}
		
		private function onOk(e:MouseEvent):void {
			close();
		}
		
		override public function dispose():void {
			okBttn.removeEventListener(MouseEvent.CLICK, onOk);
			super.dispose();
		}
	}

}