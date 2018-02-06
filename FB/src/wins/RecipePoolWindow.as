package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import wins.elements.OutItem;
	/**
	 * ...
	 * @author ...
	 */
	public class RecipePoolWindow extends RecipeWindow 
	{
		private var image:Bitmap = new Bitmap();
		public function RecipePoolWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['hasTitle'] = false;
			settings['exitTexture'] = 'closeBttnMetal';
			super(settings);
			
		}
		
		override public function drawExit():void 
		{
			var bubbleExit:Bitmap = new Bitmap(Window.textures.clearBubbleBacking);
			headerContainer.addChild(bubbleExit);
			Size.size(bubbleExit, 82, 82);
			bubbleExit.smoothing = true;
			bubbleExit.x = settings.width - bubbleExit.width + 12;
			//bubbleExit.x = settings.width - 262;
			bubbleExit.y = -18;
			
			exit = new ImageButton(textures[this.settings.exitTexture]);
			headerContainer.addChild(exit);
			exit.x = bubbleExit.x + (bubbleExit.width - exit.width) / 2;
			exit.y = bubbleExit.y + (bubbleExit.height - exit.height) / 2;
			
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		override public function drawBackground():void 
		{
			background = new Bitmap(Window.textures.hippodromBacking);
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{	
			
			image = new Bitmap(Window.textures.cauldron);
			image.x = 20;
			image.y = background.height - image.height - 45;
			image.filters = [new DropShadowFilter(4.0, 90, 0, 0.5, 4.0, 4.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(image);
			
			if (settings.hasDescription) settings.height += 40;
			
			var ln:uint = 0;
			
			var reqLength:* = Numbers.countProps(settings['requires']);
			
			if (reqLength > 0)
			{
				needRecs = true;
			}else{
				needRecs = false;
			}
			
			for (var cn:* in settings['materials'])
			{
				ln++;
			}
			
			/*if (settings['materials'].hasOwnProperty(28) || !settings['materials'] && ln < 2)
			{
				createItems(settings['requires']);
				needRecs = false;
			}else {*/
				createItems(settings['materials']);
			//}
			container.x = 170;
			container.y = 85;
			
			bodyContainer.addChild(countContainer);
			(needRecs)?drawRequirements(settings['requires']):null;
			
			onUpdateOutMaterial();
			outItem.addGlow();
			
			
		}
		
		override protected function onStockChange(e:AppEvent):void 
		{
			if (requiresList && requiresList.parent) {
				requiresList.parent.removeChild(requiresList);
				requiresList.dispose();
				requiresList = null;
			}
			
			for (var i:int = 0; i < partList.length; i++ )
			{
				var itm:WorkerItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			if (_equality && _equality.parent)
			{
				_equality.parent.removeChild(_equality);
				_equality = null;
			}
			
			if (outItem && outItem.parent)
			{
				outItem.parent.removeChild(outItem);
				outItem = null;
			}
			
			for (i = 0; i < container.numChildren; i++ )
			{
				container.removeChildAt(0);
				i--;
			}
			
			if (container && container.parent) 
			{
				container.parent.removeChild(container);
			}
			
			createItems(settings['materials']);
			
			/*if (outItem)
			{
				outItem.x = padding + backgroundWidth + 6;
				outItem.y = 70;
			}*/
			
			//container.x = padding + (backgroundWidth - container.width) / 2;
			//_equality.x = padding + backgroundWidth - _equality.width / 2 - 17;
			//_equality.y = 103;
			
			findHelp();
		}
		
		override protected function createItems(materials:Object):void
		{
			var offsetX:int = 0;
			var offsetY:int = 0;
			/*var dX:int = 0;
			if (needRecs == true)
			{
				dX = 70;
			}*/
			
			//var pluses:Array = [];		
			var count:int = 0;
			
			for(var _sID:* in materials) 
			{
				var inItem:WorkerItem = new WorkerItem({
					sID			:_sID,
					need		:materials[_sID],
					window		:this, 
					type		:WorkerItem.IN,
					disableAll	:disableAll,
					//bttnAskHeight	:37,
					//bttnAskWidth	:105,
					//qbttnBuyHeight	:37,
					//bttnBuyWidth	:105,
					blockBttn		:true
				});
				inItem.background.visible = false;
				inItem.searchBttn.alpha = 0;
				inItem.wishBttn.alpha = 0;
				//inItem.buyBttn.y += 5;
				//inItem.buyBttn.x += 4;
				//inItem.buyBttn.x += 4;
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				partList.push(inItem);
				
				container.addChild(inItem);
				inItem.x = offsetX;
				inItem.y = offsetY;
				count++;
				if (count < Numbers.countProps(materials)) 
				{
					var plus:Bitmap = new Bitmap(Window.textures.plus);
					container.addChild(plus);
					//pluses.push(plus)
					plus.scaleX = plus.scaleY = .8;
					plus.smoothing = true;
					plus.x = inItem.x - inItem.background.x + inItem.background.width - 5;
					plus.y = inItem.y + (inItem.background.height - plus.height) / 2;
				}
				
				offsetX += inItem.background.width - inItem.background.x + 25;
			}
			
			//var firstPlus:Bitmap = pluses.shift();
			//container.removeChild(firstPlus);
			
			_equality = new Bitmap(Window.textures.equals, 'auto', true);
			container.addChild(_equality);
			_equality.scaleX = _equality.scaleY = .8;
			//_equality.smoothing = true;
			_equality.x = inItem.x - inItem.background.x + inItem.background.width + 5;
			_equality.y = inItem.y + (inItem.background.height  - _equality.height) / 2;
			
			
			outItem = new OutItem(onCook, {formula:formula, recipeBttnName:"dd", target:settings.target,sID:settings.sID});
			outItem.change(formula);
			outItem.background.visible = false;
			outItem.x = _equality.x + _equality.width + 4;
			outItem.y = inItem.y /*+ (inItem.background.height  - outItem.height) / 2*/;
			container.addChild(outItem);
			
			//outItem.x = offsetX;
			
			
			bodyContainer.addChild(container);
			//backgroundWidth = partList.length * (partList[0].background.width + 70) ;
			//container.x = 20;// (backgroundWidth - container.width) / 2;
			//container.y = 20;
			
			onUpdateOutMaterial();
		}
		
		override public function onUpdateOutMaterial(e:WindowEvent = null):void {
			
			if (PostManager.instance.isActive && PostManager.instance.isProgress){
				PostManager.instance.waitPostComplete(onUpdateOutMaterial);
				return;
			}
			
			var outState:int = MaterialItem.READY;
			for each(var item:* in partList) {
				if(item.status != MaterialItem.READY){
					outState = item.status;
				}
			}
			if(count < 1 && hasTechno){
				outState = MaterialItem.UNREADY;
				//customGlowing(hireTechBttn);
			}
			
			if (requiresList && !requiresList.checkOnComplete())
				outState = MaterialItem.UNREADY;
			
			if (outState == MaterialItem.UNREADY) 
				outItem.recipeBttn.state = Button.DISABLED;
			else if (outState != MaterialItem.UNREADY)
			{
				outItem.recipeBttn.state = Button.NORMAL;
				stopGlowing = true;
			}
			
			var openedSlots:int;
			openedSlots = settings.target.openedSlots;
			if (settings.target.queue.length >= openedSlots+1)
				outItem.recipeBttn.state = Button.DISABLED;
		}
		
		override public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);
			
			for (var i:int = 0; i < partList.length; i++ ) {
				var itm:WorkerItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			super.dispose();
		}
		
	}

}