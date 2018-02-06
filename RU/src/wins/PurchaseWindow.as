package wins 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import units.Personage;
	import units.Techno;
	import wins.elements.PurchaseItem;

	public class PurchaseWindow extends Window
	{
		public var items:Array = new Array();
		public var handler:Function; 
		
		private var find:int = 0;
		private var titleLabelSplit:Sprite = new Sprite();
		private var descriptionLabel:TextField;
		private var descriptionLabelSplit:TextField;
		
		public function PurchaseWindow(settings:Object = null)
		{			
			var defaults:Object = {
				width: 750,
				height:370,
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
				itemIconScale:settings.itemIconScale || 1,
				exitTexture: 'closeBttnMetal'
			};
			
			if (settings == null) 
			{
				settings = new Object();
			}
			
			for (var property:* in settings)
			{
				defaults[property] = settings[property];
			}
			settings = defaults;
			settings["noDesc"] = settings.noDesc || false;
			settings["technoCookieWindow"] = settings.technoCookieWindow || false;
			
			handler = settings.callback;
			
			if (settings.find != undefined) this.find = settings.find;
			
			super(settings);
		}
		
		override public function drawTitle():void 
		{
		}
		
		override public function drawBackground():void 
		{
		}		
		
		override public function dispose():void
		{
			removeItems();
			super.dispose();
		}
		
		public function removeItems():void
		{
			if(items){
				for (var i:int = 0; i < items.length; i++)
				{
					if (items[i] != null)
					{
						items[i].dispose();
						items[i] = null;
					}
				}
				items.splice(0, items.length);
			}
		}
		
		public static function createContent(type:String, params:Object = null, ssid:int = 0):Array 
		{
			for (var id:* in App.user.techno) {
				switch(App.user.techno[id].sid) 
				{
					case Personage.TECHNO:		
					break;
					case Personage.TECHNO_GREEK:	
					for (var propt:* in params) {
						for (var view:* in params[propt]) {
							if (params[propt][view]  == 'slave') 
							{
								params[propt][view] = 'slave2';
							}else 
							{
								if (params[propt][view] == 'Cookies') 
								{
									params[propt][view] = 'Cookies2';
								}
							}						
						}
					}
					break;
				}				
			}
			
			var list:Array = new Array();
			var makeGlow:Boolean = false;
			
			for (var sID:* in App.data.storage) {
				var object:Object = App.data.storage[sID];
				object['sID'] = sID;
				
				if (params != null) {
					var _continue:Boolean = false;
					
					for (var prop:* in params) {
						if (object[prop] == undefined || object[prop] != params[prop] /*|| object.out != params.out*/) {
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
				
				if (object.type == type && object.visible && object.out == ssid) // TODO проверку на наличие обновления
				{
					list.push( { sID:sID, order:object.order, glow:makeGlow } );
				}
				//}else if(object.out == ssid)
				//{
					//list.push( { sID:sID, order:object.order, glow:makeGlow } );
				//}
			}
			
			list.sortOn(["order"], Array.NUMERIC);
			return list;
		}
		
		public static function parseContent(sID:int):Array
		{
			var list:Array = new Array();
			for each(var item:* in App.data.storage)
			{
				if (item.type == 'Energy' && item.out == sID)
					list.push( { sID:item.sID, order:item.count} );
			}
			list.sortOn(["order"], Array.NUMERIC);
			return list;
		}
		
		override public function drawBody():void 
		{					
			if (settings.cookWindow) 
			{
				settings.width = settings.width || 600;
				settings.height = settings.height || 570;
				exit.x = settings.width - exit.width / 2;
			}
			
			if (settings.useText) 
			{
				descriptionLabel = drawText(settings.description, {
					fontSize:24,
					autoSize:"center",
					textAlign:"center",
					multiline:true,
					color:0xffffff,
					borderColor:0x853016
				});
				
				descriptionLabel.wordWrap = true;
				descriptionLabel.width = settings.width - 110/* + settings.descWidthMarging*/;				
				descriptionLabel.x = (settings.width - descriptionLabel.width) / 2 + 5;				
				descriptionLabel.y = -8;				
				bodyContainer.addChild(descriptionLabel);
				settings.height += descriptionLabel.textHeight - 18;
			}
			
			var bg:Bitmap = backing(settings.width, settings.height, 50, 'capsuleWindowBacking');
			bg.x = 0;
			layer.addChild(bg);
			
			var bgPaper:Bitmap = backing(settings.width - 68, settings.height - 68, 40, 'paperClear');
			bgPaper.x = bg.x + (bg.width - bgPaper.width) / 2;
			bgPaper.y = bg.y + (bg.height - bgPaper.height) / 2;
			layer.addChild(bgPaper);
			
			drawMirrowObjs('decSeaweed', settings.width + 56, - 56, settings.height - 171, true, true, false, 1, 1, layer);
			
			var itemsBacking:Bitmap = Window.backingShort(settings.width - 80, 'backingGrad', true);
			itemsBacking.scaleY = 3.4;
			itemsBacking.alpha = .8;
			itemsBacking.smoothing = true;
			itemsBacking.x = (settings.width - itemsBacking.width) / 2;
			itemsBacking.y = 118 + settings.offsetY; /*+ (bonusList.height - itemsBacking.height) / 2 + 17;*/
			layer.addChild(itemsBacking);
			
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 36,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x4c871c,			
				borderSize 			: 3,					
				shadowColor	: 0x085c10,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
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
				});
				
				titleLabelSplit.x = (settings.width - titleLabel.width) * .5;
				titleLabelSplit.y =titleLabel.height+ settings.itemHeight+descriptionLabel.height -25;
				headerContainerSplit.addChild(titleLabelSplit);
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
				
				descriptionLabelSplit.width = descriptionLabelSplit.textWidth;
				descriptionLabelSplit.x = settings.width - settings.width / 2 - descriptionLabelSplit.width / 2;
				descriptionLabelSplit.y = titleLabelSplit.y+13;
				
				bodyContainer.addChild(descriptionLabelSplit);
				settings.height += descriptionLabelSplit.textHeight - 18;
			}
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;			
			titleLabel.y = -30;
			
			/*if (settings.technoCookieWindow) 
			{
				titleLabel.y = -10;
			}*/
			
			headerContainer.addChild(titleLabel);
			var ribbon:Bitmap = backingShort((titleLabel.width > 320) ? titleLabel.width : 320, 'ribbonGrenn');
			ribbon.y = -40;
			ribbon.x = (settings.width - ribbon.width) / 2;
			layer.addChild(ribbon);
			
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
		}	
		
		override public function drawExit():void 
		{
			super.drawExit();
			exit.x = settings.width - exit.height;			
			exit.y = 8;
		}
		
		override public function drawArrows():void 
		{
			if (settings.technoCookieWindow) 
			{
				return;
			}
			
			if (items.length)
			{
				paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -0.8, scaleY:0.8 } );
				paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:0.8, scaleY:0.8 } );
				
				var y:int = (settings.height - paginator.arrowLeft.height) / 2;
				paginator.arrowLeft.x = 0 + paginator.arrowLeft.width/2;
				paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 25;
				
				paginator.arrowLeft.y = y;
				paginator.arrowRight.y = y;
				
				/*paginator.arrowRight.x += 35;
				paginator.arrowLeft.x += 35;*/
			}
		}
		
		override public function contentChange():void
		{
			for (var i:int = 0; i < items.length; i++)
			{
				items[i].visible = false;
			}
			
			var itemNum:int = 0
			
			var yPos:int = (settings.cookWindow)?20:0; 
			
			if (settings.useText)
			{
				yPos = descriptionLabel.textHeight + (settings.cookWindow)?50:50 - ((App.isSocial('YB', 'MX', 'AI'))?38:0);
				
				if ((settings.splitWindow)) 
				{
					yPos = descriptionLabel.textHeight +10;
				}
			}
			
			//yPos -= 5;
			
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
					var y_y:uint = ((items[i].height -20) * Math.floor(i / cl)) ;
					
					/*if (Math.floor(i / cl) == 1) 
					{
						y_y+=(settings.splitWindow)?40:0;
					}*/
					
					items[i].y = /*(settings.columnsNum)? y_y :*/settings.offsetY + 10;
					var x_x:uint = 46 + (itemNum%cl) * items[i].bgWidth + 35 * (itemNum%cl);
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
		
		public function createItems():void
		{
			var glow:Boolean = false;
			
			for (var j:int = 0; j < items.length; j++) 
			{
				items[i].dispose();
			}
			
			items = [];
			var itemShineType:String;
			
			itemShineType = "gold";
			
			for (var i:int = 0; i < settings.content.length; i++)
			{
				if (App.data.storage[settings.content[i].sID].out == find) glow = true;
				
				var item:PurchaseItem = new PurchaseItem(settings.content[i].sID, handler, this, i, glow, settings.shortWindow, settings.noDesc, itemShineType,settings.itemHeight,settings.itemWidth, settings.itemIconScale);
				item.bgWidth -= 10;
				item.visible = false;
				bodyContainer.addChild(item);
				items.push(item);
				glow = false;
				item.y = 8;
				/*if (settings.technoCookieWindow) 
				{
					
				}*/
			}
			
			sortItems();
		}
		
		private function sortItems():void 
		{
			var arr:Array = [];
			
			for ( var i:int = 0; i < items.length; i++ )
			{
				if (items[i].doGlow) 
				{
					arr.push(items[i]);
					items.splice(i, 1);
					i--;
				}
			}
			
			for ( i = 0; i < items.length; i++ ) 
			{
				arr.push(items[i]);
			}
			
			items.splice(0, items.length);
			items = arr;
		}
		
		public function set callback(handler:Function):void
		{
			this.handler = handler;
		}
		
		public function blokItems(value:Boolean):void
		{
			var item:*;
			if (value)	for each(item in items) item.state = Window.ENABLED;
			else 		for each(item in items) item.state = Window.DISABLED;
		}		
	}
}