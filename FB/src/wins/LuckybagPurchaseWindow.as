package wins 
{
	import buttons.Button;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Personage;
	import wins.elements.LuckybagPurchaseItem;
	import wins.elements.PurchaseItem;

	public class LuckybagPurchaseWindow extends PurchaseWindow
	{		
		private var find:int = 0;
		private var titleLabelSplit:Sprite = new Sprite();	
		private var innerBackground:Bitmap;	
		private var bg:Bitmap = new Bitmap();			
		private var openBagBttn:Button;
		private var description:TextField;
		private var curtain:Shape = new Shape();
		
		public function LuckybagPurchaseWindow(settings:Object = null)
		{			
			var defaults:Object = {
				width: 625,
				height:390,
				hasPaper:true,
				hasDecoration:true,
				title:Locale.__e("flash:1382952380240"),
				titleScaleX:0.76,
				titleScaleY:0.76,
				hasPaginator:true,
				hasArrows:true,
				hasButtons:false,
				splitWindow:false,
				shortWindow:false,
				itemHeight:250,
				itemWidth:153,
				useText:false,
				itemsOnPage:3,
				descWidthMarging:0,
				description:Locale.__e("flash:1382952380241"),
				closeAfterBuy:false,
				autoClose:true,
				popup:true,
				glow:'',
				offsetY:0,
				itemIconScale:settings.itemIconScale||1
			};
			
			if (settings == null) {
				settings = new Object();
			}
			
			for (var property:* in settings) {
				defaults[property] = settings[property];
			}
			settings = defaults;
			
			settings["noDesc"] = settings.noDesc || false;
			settings["width"] = settings.width || defaults.width;
			settings["height"] = settings.height || defaults.height;
			settings["background"] = 'buildingBacking';
			
			handler = settings.callback;
			
			if (settings.find != undefined) this.find = settings.find;
			
			super(settings);
		}
		
		public static function createContent(type:String, params:Object = null):Array
		{
			var list:Array = new Array();
			var makeGlow:Boolean = false;
			
			for (var sID:* in App.data.storage) 
			{
				var object:Object = App.data.storage[sID];
				object['sID'] = sID;
				
				if (params != null) {
					var _continue:Boolean = false;
					
					for (var prop:* in params) 
					{
						if (object[prop] == undefined || object[prop] != params[prop]) 
						{
							_continue = true;
							if (prop == 'view' && params[prop] is Array)
								for (var i:int = 0; i < params[prop].length; i++) {
									if (params[prop][i] == object[prop]) {
										_continue = false;	
									}
								}
							break;
						}
					}
					
					if (_continue) {
						continue;
					}
				}
				
				if (object.type == type && object.visible)
				{
					list.push( { sID:sID, order:object.order, glow:makeGlow } );
				}
			}
			
			list.sortOn(["order"], Array.NUMERIC);
			return list;
		}
		
		private var descriptionLabel:TextField
		private var descriptionLabelSplit:TextField
		
		override public function drawBody():void 
		{			
			exit.y -= 1;
			exit.x += 6;
			
			if (settings.cookWindow) {
				settings.width = settings.width||552;
				settings.height = settings.height||570;
				exit.x = settings.width-exit.width/2;
			}
			
			if (settings.useText) {
				descriptionLabel = drawText(settings.description, {
					fontSize:24,
					autoSize:"center",
					textAlign:"center",
					multiline:true,
					color:0xffffff,
					borderColor:0x7a4b1f
				});
				descriptionLabel.wordWrap = true;
				descriptionLabel.width = settings.width - 60 + settings.descWidthMarging;
				descriptionLabel.x = (settings.width - descriptionLabel.width) / 2+5;
				
				descriptionLabel.y = -8;
				
				bodyContainer.addChild(descriptionLabel);
				settings.height += descriptionLabel.textHeight - 18;
			}			
			
			bg = backing(settings.width, settings.height, 50, settings.background);
			bg.x = 0;
			layer.addChild(bg);		
			
			innerBackground = Window.backing(585, 250, 40, 'buildingDarkBacking');
			layer.addChild(innerBackground);
			innerBackground.x = settings.width / 2 + bg.x - innerBackground.width / 2;
			innerBackground.y = 90;
			
			titleLabel = titleText({
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
			
			
			if (settings.hasDecoration) {
				drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -55, true, true);
			}		
			
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 10, settings.height - 115);//bootom
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 10, 39, false, false, false, 1, -1);
			
			
			if (settings.splitWindow) 
			{
				titleLabelSplit = titleText( {
					title				: settings.titleSplit,
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
				
				titleLabelSplit.x = (settings.width - titleLabelSplit.width) * .5 + 5;			
				
				titleLabelSplit.y =titleLabel.height+ settings.itemHeight+descriptionLabel.height -25;// титульный текст
				headerContainerSplit.addChild(titleLabelSplit);
				
				if (settings.splitWindow) 
				{
					drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 , settings.width / 2 + settings.titleWidth / 2 + 10, titleLabelSplit.y - 25 +settings.offsetY, true, true);	
				}
				
			}		
			
			if (settings.useText && settings.splitWindow) 
			{
				descriptionLabelSplit = drawText(settings.descriptionSplit, {
					fontSize:24,
					autoSize:"center",
					textAlign:"center",
					multiline:true,
					color:0xffffff,
					borderColor:0x7a4b1f
				});
				descriptionLabelSplit.width = settings.width - 60 + settings.descWidthMarging;
				descriptionLabelSplit.x = (settings.width - descriptionLabelSplit.width) / 2 + 5;				
				descriptionLabelSplit.y = titleLabelSplit.y + 13;				
				bodyContainer.addChild(descriptionLabelSplit);
				settings.height += descriptionLabelSplit.textHeight - 18;
			}		
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -23;// титульный текст
			headerContainer.addChild(titleLabel);
			
			createItems();
			contentChange();
			
			if (settings.image) 
			{
				var img:Bitmap = settings.image;
				bodyContainer.addChild(img);
				img.x = -50;
				img.y = -150;
			}	
			
			if (settings.splitWindow) 
			{
				titleLabel.y += settings.offsetY;
				titleLabelSplit.y += settings.offsetY;
				descriptionLabelSplit.y += settings.offsetY;
				descriptionLabel.y += settings.offsetY;
			}			
			
			curtain.graphics.beginFill(0xe8c38e, 0.6);
			curtain.graphics.drawRoundRect(0, 0, 485, 60, 30, 30);
			curtain.graphics.endFill();
			layer.addChild(curtain);
			curtain.x = settings.width / 2 + bg.x - curtain.width / 2;
			curtain.y = 35;
			
			description = Window.drawText(Locale.__e('flash:1450886877237'), {
				width		:500,
				fontSize	:22,
				textAlign	:"center",
				autoSize	:"center",
				color		:0xffffff,
				borderColor	:0x844e28,
				multiline	:true,
				wrap		:true
			});
			
			layer.addChild(description);
			description.x = settings.width / 2 + bg.x - description.width / 2;
			description.y = 40;
			
			drawButton();
		}
		
		public function drawButton():void 
		{
			openBagBttn = new Button( {
				width:185,
				height:55,
				fontSize:32,
				caption:Locale.__e("flash:1450889118031")
			});
			layer.addChild(openBagBttn);
			openBagBttn.x = settings.width / 2 + bg.x - openBagBttn.width / 2;
			openBagBttn.y = 350;
			openBagBttn.addEventListener(MouseEvent.CLICK, onOpenBag);
		}
		
		private function onOpenBag (e:Event = null):void 
		{
			new LuckybagContentWindow({ 
				popup: true,
				targetSID: settings.content[0].sID				
			}).show();
		}	
		
		override public function drawExit():void 
		{
			super.drawExit();
			
			exit.x = settings.width - 50;			
			exit.y = 0;
		}
		
		override public function contentChange():void 
		{
			for (var i:int = 0; i < items.length; i++)
			{
				items[i].visible = false;
			}
			
			var itemNum:int = 0			
			var yPos:int = (settings.cookWindow) ? 20  : 0; 

			if (settings.useText) 
			{
				yPos = descriptionLabel.textHeight + (settings.cookWindow) ? 50 : 50 - ((App.isSocial('YB', 'MX', 'AI')) ? 38 : 0);
				descriptionLabel.y -= ((App.isSocial('YB','MX','AI')) ? 6 : 0)
				if ((settings.splitWindow)) 
				{
					yPos = descriptionLabel.textHeight + 10;
				}
			}
			
			yPos += 65;
			
			if (items.length)
			{				
				var cl:uint = settings.itemsOnPage;
				
				if (settings.columnsNum) 
				{
					cl = settings.columnsNum;
				}
				
				var line:uint = 0;
				
				for (i = paginator.startCount; i < paginator.finishCount; i++)
				{
					items[i].y = 50 + yPos;
					
					var y_y:uint = ((items[i].height - 20) * Math.floor(i / cl));
					
					if (Math.floor(i / cl) == 1) 
					{
						y_y += (settings.splitWindow) ? 40 : 0;
					}
					
					items[i].y = yPos;
					items[i].y += (settings.columnsNum) ? y_y : 0;
					
					var x_x:uint = 40 + (itemNum % cl) * items[i].bgWidth + 10 * (itemNum % cl);
					
					items[i].x = x_x;					
					
					itemNum++;
					items[i].visible = true;
					
					if (settings.splitWindow) 
					{
						items[i].y += settings.offsetY;
					}
				}				
			}
		}
		
		override public function createItems():void 
		{
			var glow:Boolean = false;
			
			for (var j:int = 0; j < items.length; j++) {
				items[i].dispose();
			}
			
			items = [];
			var itemShineType:String;
			itemShineType = "gold";
		
			for (var i:int = 0; i < settings.content.length; i++) {
				
				if (App.data.storage[settings.content[i].sID].out == find) glow = true;
				
				var item:LuckybagPurchaseItem = new LuckybagPurchaseItem(settings.content[i].sID, handler, this, i, glow, settings.shortWindow, settings.noDesc, itemShineType, 220, 175, settings.itemIconScale);
				item.visible = false;
				bodyContainer.addChild(item);
				items.push(item);
				glow = false;
			}
			sortItems();
		}
		
		private function sortItems():void 
		{
			var arr:Array = [];
			for ( var i:int = 0; i < items.length; i++ ) {
				if (items[i].doGlow) {
					arr.push(items[i]);
					items.splice(i, 1);
					i--;
				}
			}
			for ( i = 0; i < items.length; i++ ) {
				arr.push(items[i]);
			}
			items.splice(0, items.length);
			items = arr;
		}		
	}
}
