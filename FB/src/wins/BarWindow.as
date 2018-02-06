package wins 
{
	import buttons.Button;
	import core.Load;
	import ui.Hints;
	import wins.elements.ProductionItem;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class BarWindow extends ProductionWindow
	{
		
		public function BarWindow(settings:Object = null)
		{
			settings['hasButtons'] = false;
			super(settings);
		}
		
		public var storageCont:LayerX;
		
		public function drawStorage():void {
			
			var icon:Bitmap;
			storageCont = new LayerX();
			var bg:Bitmap = Window.backing(200, 130, 10, "windowDarkBacking");
			bg.scaleX = bg.scaleY = 0.9
			bg.smoothing = true;
			storageCont.addChild(bg);
			
			for(var sID:* in settings.target.info.kicks)
				if (App.data.storage[sID].real == 0)
					break;
					
					
			var title:TextField = Window.drawText(Locale.__e("flash:1382952379991"), {
				fontSize:26,
				color:0x502f06,
				borderColor:0xf0e6c1,
				textAlign:"center"
			});	
			
			title.width = bg.width;
			storageCont.addChild(title);
			title.y = -10;
				
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), function(data:Bitmap):void 
			{
				icon = new Bitmap();
				icon.bitmapData = data.bitmapData;
				icon.scaleX = icon.scaleY = 0.8;
				icon.smoothing = true;
				storageCont.addChild(icon);
				icon.x = 70 - icon.width / 2;
				icon.y = 64 - icon.height / 2;
				
				var countOnStock:TextField = Window.drawText("x "+settings.target.items, {
					color:0xe9ddba,
					borderColor:0x2e3332,
					fontSize:30,
					autoSize:"left"
				});
				
				storageCont.addChild(countOnStock);
				countOnStock.x = icon.x + icon.width + 5;
				countOnStock.y = icon.y + icon.height / 2 - countOnStock.height / 2;
			});
			
			bodyContainer.addChild(storageCont);
			storageCont.x = 95;
			storageCont.y = 45;
		}
		
		public var tableCont:LayerX
		public function drawTable():void {
			var icon:Bitmap;
			tableCont = new LayerX();
			var bg:Bitmap = Window.backing(200, 130, 10, "windowDarkBacking");
				bg.scaleX = bg.scaleY = 0.9
				bg.smoothing = true;
			tableCont.addChild(bg);
			
			var table_sID:uint = settings.target.info.targets[0];
					
			var title:TextField = Window.drawText(Locale.__e("flash:1382952379992"), {
				fontSize:26,
				color:0x502f06,
				borderColor:0xf0e6c1,
				textAlign:"center"
			});	
			title.width = bg.width;
			tableCont.addChild(title);
			title.y = -10;
			
			Load.loading(Config.getIcon("Material", 'friends'), function(data:Bitmap):void 
			{
				icon = new Bitmap();
				icon.bitmapData = data.bitmapData;
				icon.scaleX = icon.scaleY = 0.8;
				icon.smoothing = true;
				tableCont.addChild(icon);
				icon.x = (bg.width - icon.width) / 2;
				icon.y = 30;
				
				var countOnStock:TextField = Window.drawText(settings.target.guestsCount()+" "+Locale.__e("flash:1382952379993")+" "+settings.target.tablesCount(), {
					color:0xe9ddba,
					borderColor:0x2e3332,
					fontSize:30,
					autoSize:"left"
				});
				
				tableCont.addChild(countOnStock);
				countOnStock.x = (bg.width - countOnStock.width) / 2;
				countOnStock.y = icon.y + icon.height - 20;
			});
			
			bodyContainer.addChild(tableCont);
			tableCont.x = 320;
			tableCont.y = 45;
		}
		
		public var buildBttn:Button
		public function drawDescription():void {
			
			var descriptionLabel:TextField = drawText(settings.target.info.text4,{
				fontSize:24,
				autoSize:"left",
				textAlign:"left",
				multiline:true,
				color:0x5d450f,
				borderColor:0xefe5c3,
				textLeading: -5//,
				//width:350
			});
			
			descriptionLabel.wordWrap = true;
			descriptionLabel.width = 320;
			descriptionLabel.x = 70;
			descriptionLabel.y = 180;
			
			bodyContainer.addChild(descriptionLabel);
			
			buildBttn = new Button({
				width:120,
				caption:Locale.__e('flash:1382952379806')
			});
			
			bodyContainer.addChild(buildBttn);
			buildBttn.x = settings.width - buildBttn.width - 70;
			buildBttn.y = descriptionLabel.y;
			
			buildBttn.addEventListener(MouseEvent.CLICK, onBuildClick);
		}
		
		private function onBuildClick(e:MouseEvent):void {
			var targets:Array = [];
			for (var sID:* in App.data.storage)
				if (App.data.storage[sID].type == 'Table')
					targets.push(sID);
			
			close();		
			new ShopWindow( { find:targets } ).show();
		}
		
		override public function drawBody():void {
			
			topBg = Window.backing(490, 200, 50, "windowDarkBacking");
			topBg.x = (settings.width - topBg.width) / 2;
			topBg.y = 58 + 210;
			bodyContainer.addChild(topBg);
			
			progressBacking = Window.backing(490, 80, 10, "bonusBacking");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = topBg.y + topBg.height + 15;
			bodyContainer.addChild(progressBacking);
			
			subTitle = Window.drawText(Locale.__e("flash:1382952379994"), {
				fontSize:26,
				color:0x502f06,
				autoSize:"left",
				borderColor:0xf0e6c1
			});
			bodyContainer.addChild(subTitle);
			
			subTitle.x = settings.width / 2 - subTitle.width / 2;
			subTitle.y = topBg.y - subTitle.textHeight - 2;
			
			createItems();
			paginator.itemsCount = 0;
			for each(var fID:* in settings.crafting) paginator.itemsCount ++;
			
			paginator.page = settings.page;
			paginator.update();
			
			paginator.y -= 82;
			
			contentChange();
			showProgressBar();
			cookingTitle.y = topBg.y + topBg.height + 20;
			cookingBar.y = topBg.y + topBg.height + 45;
			
			drawStorage();
			drawTable();
			
			drawDescription();
		}
	}
}
