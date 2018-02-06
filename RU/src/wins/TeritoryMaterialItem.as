package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setTimeout;
	import units.Techno;
	
	/**
	 * ...
	 * @author 
	 */
	public class TeritoryMaterialItem extends MaterialItem 
	{
		
		public static const IN:int = 1;
		public static const OUT:int = 2;
		public static const READY:int = 1;
		public static const UNREADY:int = 2;
		
		private var settings:Object = {};
		public function TeritoryMaterialItem(settings:Object, bg:Bitmap=null) 
		{
			super(settings, bg);
			
		}
		
		override protected function init():void
		{
			
			App.self.addEventListener(AppEvent.ON_CLOSE_BANK, onCloseBank);
			
			var backgroundShape:Shape = new Shape();
			backgroundShape.graphics.beginFill(0xe6b685);
			backgroundShape.graphics.drawCircle(50, 50, 50);
			backgroundShape.graphics.endFill();
			
			background = new Bitmap(new BitmapData(100, 100, true, 0));
			background.bitmapData.draw(backgroundShape);
			//background = new Bitmap(Window.textures.bgItem);
			//background = new Bitmap(Window.textures.glowingBackingNew);
			addChild(background);
			
			drawBitmap();
			drawTitle();
			
			switch(info.type) {
				
				case "Animal":
						drawAnimalInfo();
					break;
				case "Building":
				case "Bridge":
						drawCount();
						drawBttns();
						askBttn.visible = false;
					break;	
				default:
						if(type ==  MaterialItem.IN){
							drawCount();
						}else{
							drawInfo();
						}
						drawBttns();
					break;
				
			}
		}	
		
		override protected function drawBttns():void
		{
			if (type == MaterialItem.IN)
			{	
				wishBttn = new ImageButton(Window.textures.wishlistBttn);
				if (!App.user.quests.tutorial) 
				{
					addChild((wishBttn));
					
				}
				searchBttn = new ImageButton(Window.textures.showMeBttn);
				wishBttn.tip = function():Object 
				{ 
					return {
						title:"",
						text:Locale.__e("flash:1382952380013")
					};
				};
				
				wishBttn.scaleX = wishBttn.scaleY = 0.7;
				searchBttn.scaleX = searchBttn.scaleY = 0.7;
				
				if (settings.window is ConstructWindow) 
				{
					wishBttn.y -= 5 + wishBtnDY ;
					wishBttn.x -= 35;
					wishBttn.scaleX = wishBttn.scaleY = 1;
					searchBttn.scaleX = searchBttn.scaleY = 1;
					searchBttn.x = wishBttn.x + 2;
					searchBttn.y = wishBttn.y + wishBttn.height + 10;
				}
				else 
				{
					wishBttn.scaleX = wishBttn.scaleY = .8;
					searchBttn.scaleX = searchBttn.scaleY = .9;
					wishBttn.y = 2;
					wishBttn.x = - 20;
					searchBttn.x = wishBttn.x + 2;
					searchBttn.y = wishBttn.y + wishBttn.height + 27;
				}
				
				askBttn = new Button({
					caption		:Locale.__e("flash:1407231372860"),
					fontSize	:15,
					radius      :10,
					fontColor:0xffffff,
					fontBorderColor:0x25608a,
					bgColor:[0x6dd4e2,0x238ec3],
					borderColor:[0xa0d5f6, 0x3384b2],
					bevelColor:[0xd3f0fc, 0x405ea4],
					width		:94,
					height		:30,
					fontSize	:15
				});
				
				askBttn.x = background.width / 2 - askBttn.width / 2;
				askBttn.y = background.x + background.height + 8;
				
				buyBttn = new MoneyButton({
					caption			:Locale.__e('flash:1382952379751'),
					width			:101,
					height			:35,
					fontSize		:20,
					fontCountSize	:20,
					radius			:16,
					countText		:0,
					multiline		:true
				});
				
				buyBttn.updatePos();
				buyBttn.x = (background.width - buyBttn.width) / 2;
				buyBttn.y = background.height + 30 - buyBttn.height;
				if (!App.user.quests.tutorial && App.data.storage[sID].mtype != 6) 
				{
					addChild(buyBttn);
				}
				buyBttn.addEventListener(MouseEvent.CLICK, buyEvent);	
				
				if (sID == Stock.FANT || sID == Stock.COINS || sID == Stock.FANTASY) 
				{
					var bttnSettings:Object = { 
						fontSize:24,
						caption:Locale.__e("flash:1382952379751"),
						height:43,
						width:121
					};
					bankBttn = new Button(bttnSettings);
					if (!App.user.quests.tutorial) 
					{
						addChild(bankBttn);
					}
					bankBttn.x = background.width / 2 - bankBttn.width / 2;
					bankBttn.y = 182 - 20;
					bankBttn.addEventListener(MouseEvent.CLICK, showBank);
					buyBttn.alpha = 0;
					
					if (App.social == "FB")
						bankBttn.y -= 20;
					
					switch(sID) {
						case Stock.FANT:
							bankBttn.order = 1;
						break;
						case Stock.COINS:
							bankBttn.order = 2;
						break;
						case Stock.FANTASY:
							bankBttn.order = 3;
						break;
						
					}
				}
				
				addChild(askBttn);
				if (App.user.quests.tutorial) 
				{
					askBttn.y += 10;
					askBttn.name = 'seach_bttn';
				}
				
				if (App.self.flashVars.social != 'OK')
				{
					if (!App.user.quests.tutorial) 
					{
						addChild(searchBttn);
					}
				}
				
				askBttn.addEventListener(MouseEvent.CLICK, searchEvent);
				wishBttn.addEventListener(MouseEvent.CLICK, wishesEvent);
				searchBttn.addEventListener(MouseEvent.CLICK, askEvent);
	
			}
			else
			{
				if (outCount > 1)
				{
					var outCount_txt:TextField = Window.drawText("x "+String(outCount),{
						fontSize		:20,
						color			:0xffdc39,
						borderColor		:0x6d4b15,
						textAlign:"right"
					});
					outCount_txt.width = 140;					
					addChild(outCount_txt);
					
					outCount_txt.x = 10;
					outCount_txt.y = 125;					
				}						
				
				cookBttn = new Button({
					caption:Locale.__e('flash:1382952380036'),
					width:116,
					height:36,
					radius:25,
					shadow:true
				});
				cookBttn.x = background.width / 2 - cookBttn.width / 2;
				cookBttn.y = 174;
			
				addChild(cookBttn);
			}
			
		wishBttn.tip = function():Object
			{
								
			return {text: Locale.__e('flash:1425981479280')}
				
			}
		searchBttn.tip = function():Object
			{
								
			return {text: Locale.__e('flash:1425981456235')}
				
			}
		askBttn.tip = function():Object
			{
								
			return {text: Locale.__e('flash:1425981432950')}
				
			}
			
		}
		
		override protected function drawTitle():void
		{
			var size:Point = new Point(100, 50);
			var pos:Point = new Point(
				(background.width - size.x) / 2,
				 background.y - size.y / 2 - 20
			 );
			
			title = Window.drawTextX(App.data.storage[sID].title, size.x, size.y, pos.x, pos.y, this, {
				color:titleColor,
				borderColor:titleBorderColor,
				fontSize:26,
				color:0x000000,
				borderColor:0x000000,
				textLeading: -6
			});
		}
		
		protected var backgroundG:Bitmap = new Bitmap();
		override public function drawBitmap():void
		{
			
			sprTip.tip = function():Object {
				return {
					title: info.title,
					text: info.description
				};
			}
			
			bitmap = new Bitmap();
			if (this.sID == 2)
			{
				backgroundG = new Bitmap(Window.textures.dailyBonusItemGlow);
				sprTip.addChild(backgroundG);
			}
			sprTip.addChild(bitmap);
			addChild(sprTip);
			
			if (App.user.stock.count(sID) < need) {
				setTimeout(setPluck, 2000);
			}
			
			addChild(preloader);
			preloader.x = (background.width) / 2;
			preloader.y = (background.height) / 2;
			Load.loading(Config.getIcon(info.type, info.preview), onPreviewComplete);
		}
		
		override public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			bitmap.bitmapData = data.bitmapData;
			Size.size(bitmap, 90, 90);
			if (this.sID == 2)
			{
				bitmap.scaleX = bitmap.scaleY = 1.2;
				//backgroundG = new Bitmap(Window.textures.glowingBackingNew);
				backgroundG.x = bitmap.x + (bitmap.width - backgroundG.width) / 2;
				backgroundG.y = bitmap.y + (bitmap.height - backgroundG.height) / 2;
			}
			bitmap.smoothing = true;
			sprTip.x = (background.width - bitmap.width)/ 2;
			sprTip.y = (background.height - bitmap.height) / 2 + bitmapDY;
			
			if (bgItem) 
			{
				
				if (settings.bgItemY) 
					sprTip.y = settings.bgItemY;
				if (settings.bgItemX) 
					sprTip.x = settings.bgItemX;
				
				sprTip.addChildAt(bgItem, 0);
				bitmap.x = bgItem.x + (bgItem.width - bitmap.width) / 2;
				bitmap.y = (bgItem.height - bitmap.height) / 2;
			}
		}
		override protected function refreshCountPosition():void
		{
			count_txt.y = background.y + background.height - 55;
			count_txt.x = 0;
			
			vs_txt.x = count_txt.x + count_txt.textWidth;
			vs_txt.y = count_txt.y;
			need_txt.x = vs_txt.x + vs_txt.textWidth;
			need_txt.y = count_txt.y;
			
			countContainer.x = background.width - countContainer.width / 2 - 20;
		}
		
		override public function drawCount():void
		{
			if (App.data.storage[sID].type != 'Techno') {
				count = App.user.stock.count(sID);
			}else {
				count = Techno.freeTechnoBySID(sID).length;
			}
			
			count_txt = Window.drawText(String(count),{
				fontSize		:28,
				color			:0xffffff,
				borderColor		:0x713f15,
				autoSize:"left"
			});
			
			vs_txt = Window.drawText("/"+" ",{
				fontSize		:26,
				color			:0xffffff,
				borderColor		:0x713f15,
				autoSize:"left"
			});
			
										
			need_txt = Window.drawText(String(need),{
				fontSize		:28,
				color			:0xffffff,
				borderColor		:0x713f15,
				autoSize:"left"
			});							
									
			countContainer.addChild(count_txt)							
			countContainer.addChild(vs_txt)							
			countContainer.addChild(need_txt)							
			countContainer.height = need_txt.textHeight;
			addChild(countContainer)
			refreshCountPosition()
		}
		
		override public function changeOnREADY():void
		{
			clearInterval(intervalPluck);
			
			status = MaterialItem.READY;
			
			setText("count", count);
			
			var filter:GlowFilter = new GlowFilter(0xa35514, 1, 4, 4, 2, 1);
			var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90, 0xa35514,1,1,1,6,1);
			count_txt.filters 	= [filter,shadowFilter];
			vs_txt.filters 		= [filter,shadowFilter];
			need_txt.filters 	= [filter,shadowFilter];
			
			count_txt.textColor = 0xfdff54;
			vs_txt.textColor 	= 0xfdff54;
			need_txt.textColor 	= 0xfdff54;
			
			if (sID == Stock.FANTASY || sID == Stock.COINS || sID == Stock.FANT)
			{
				count_txt.parent.removeChild(count_txt);
				vs_txt.parent.removeChild(vs_txt);
				need_txt.x = 0;
				countContainer.x = background.width - countContainer.width / 2;
			}
			
			countContainer.y = background.height - countContainer.height - 50;
			
			wishBttn.visible 	= false;
			buyBttn.visible 	= false;
			askBttn.visible 	= false;
			searchBttn.visible = false;
			
			if (bankBttn) bankBttn.visible = false;
		}
		
		override public function changeOnUNREADY():void
		{
			if(	App.data.storage[sID].type == 'Techno'){
				count = Techno.freeTechno().length;
			}
			setText("count", count);
			
			status = MaterialItem.UNREADY;
			countContainer.y = background.height - countContainer.height - 50 ;
			var filter:GlowFilter = new GlowFilter(0x713f15, 1, 4, 4, 2, 1);
			var shadowFilter:DropShadowFilter = new DropShadowFilter(1, 90, 0x713f15, 1, 1, 1, 8, 1);
			
			if (!count_txt.parent || !vs_txt.parent) {
				countContainer.addChild(count_txt);
				countContainer.addChild(vs_txt);
				refreshCountPosition();
			}
			
			count_txt.filters 	= [filter, shadowFilter];
			vs_txt.filters 		= [filter, shadowFilter];
			need_txt.filters 	= [filter, shadowFilter];
			
			count_txt.textColor = 0xffffff;
			vs_txt.textColor 	= 0xffffff;
			need_txt.textColor 	= 0xffffff;
			
			if(info.hasOwnProperty('price')){
				buyBttn.count = String((need - count) * info.price[Stock.FANT]);
				buyBttn.visible 	= true;
				if (info.real) info.real = 1;
				if (bankBttn) bankBttn.visible = true;
			}else{
				buyBttn.count = '-1';
				buyBttn.visible 	= false;
				if (bankBttn) bankBttn.visible = false;
			}	
			
			wishBttn.visible 	= true;
			
			if (App.data.storage[sID].type != 'Building' && 
				App.data.storage[sID].type != 'Guide' &&
				App.data.storage[sID].type != 'Bridge' &&
				App.data.storage[sID].type != 'Dock' &&
				App.data.storage[sID].type != 'Floors' &&
				App.data.storage[sID].type != 'Techno' 
				){
				askBttn.visible = true;
				wishBttn.visible = true;
				
				if(!App.isJapan()){  
					searchBttn.visible = true;
				} else {
					searchBttn.visible = false;
				}
			}else{
				askBttn.visible 	= false;
				wishBttn.visible 	= false;
				searchBttn.visible 	= false;
			}
			
			if (info.mtype == 3){
				askBttn.visible 	= false;
				wishBttn.visible 	= false;
				searchBttn.visible 	= false;
			}
		}
		
	}

}