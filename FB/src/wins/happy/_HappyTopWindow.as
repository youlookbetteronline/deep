package wins.happy {
	import buttons.Button;
	import buttons.IconButton;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Happy;
	import wins.ShopWindow;
	import wins.TopWindow;
	import wins.Window;
	


	public class _HappyTopWindow extends Window {
		
		protected var descriptionLabel:TextField;
		public var descText:String;
		private var info:Object={};
		private var top:Object = {};
		private var _bttOk:Boolean ;
		private var top100Bttn:IconButton;
		private var expire:int;
		private var topRewerd:Object;
		private var contents:Array = [];
		
		public function _HappyTopWindow(settings:Object = null,sh:Boolean=true) {
			info = App.data.storage[settings.sid];
			_bttOk = sh;
			if (settings == null) 
			{
				settings = new Object();
			}
			settings['background'] 		= 'newsBacking';
			settings['width'] 			= 860;
			//settings['width'] 			= 700;
			settings['height'] 			= 670;
			//settings['height'] 			= 420;
			settings['title'] 			= info.title;
			settings['hasPaginator'] 	= false;
			settings['hasExit'] 		= true;
			settings['hasTitle'] 		= true;
			settings['faderClickable'] 	= true;
			settings['popup'] 			= true;
			settings['faderAlpha'] 		= 0.6;
			
			settings['shadowSize'] = 4;
			settings['shadowColor'] = 0x611f13;
			settings["fontColor"]       = 0xfdfdfb;
			settings["fontBorderColor"]	= settings.fontBorderColor || 0xc38538;
			
			for (var top:* in App.data.top)
				if (App.data.top[top].target == settings.sid) 
				{
					_top = top;
					break;
				}
			if (_top == 0)
				settings['height'] 			= 400;
				
			super(settings);	
			
			creatTop();
			onTop100();
		}
		
		private var _top:int;
		private var _liga:int;
		private function creatTop():void 
		{
			for (var top:* in App.data.top)
				if (App.data.top[top].target == settings.sid) 
				{
					_top = top;
					break;
				}
			if(_top>0)
				for (var liga:* in App.data.top[_top].league.tbonus)
					_liga = liga;
		}
		
		private var itemCont:Sprite;
		private var topCont:Sprite;
		override public function drawBody():void {
			titleLabel.y += 48;
			exit.y += 32;
			//exit.x -= 10;
			//drawDecorations();
			drawShape(42, 50);
			
			if (_top > 0)
				drawShape(300, 60);
	
			itemCont = new Sprite();
			topCont = new Sprite();
			
			
			var bttn:Button = new Button( {  
				width:194, 
				height:53, 
				caption:Locale.__e('flash:1418816484831') 
				} );
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = settings.height - bttn.height - 50;
			
			bttn.addEventListener(MouseEvent.CLICK, onHappy);
			
		
			
			
			var item:InfoWindowItem;
			for (var st:* in info.tower){
				item = new InfoWindowItem(info.tower[st].t, st,this);
				item.x = 150 * (st-1);
				itemCont.addChild(item);
			}
			
			if (_top > 0)
			{
				var itemTop:InfoWindowItem;
			
				for (var top:* in /*settings.top.league.tbonus[1].t*/ App.data.top[_top].league.tbonus[_liga].t) {
					st++;	
					itemTop = new InfoWindowItem(App.data.top[_top].league.tbonus[_liga].t[top], App.data.top[_top].league.tbonus[_liga].e[top],this,true);
					itemTop.x = 150 * top;
					topCont.addChild(itemTop);
				}
				itemCont.x = (settings.width - itemCont.width) / 2;
				itemCont.y = 120;
				
			
			}
				itemCont.x = (settings.width - itemCont.width) / 2;
				itemCont.y = 120;
				//topCont.x = itemCont.x;//(settings.width - topCont.width) / 2;
				//topCont.y = 390;
			
				
				
			if(_bttOk && _top>0)
				bodyContainer.addChild(bttn);

			//var descPrms:Object = {
				//color			:0x7a471c,
				//borderColor		:0xffffff,
				////width			:settings.width-100,
				//multiline		:true,
				//wrap			:true,
				//textAlign		:'center',
				//fontSize		:35
			//}
			TextSettings.description2.fontSize = 22;
			TextSettings.description2.color = 0xfffdf4;
			TextSettings.description2.borderColor = 0x77613c;
			descriptionLabel = Window.drawText(Locale.__e('flash:1476796601079'), TextSettings.description2);
			descriptionLabel.width = settings.width - 100;
			descriptionLabel.x = (settings.width-descriptionLabel.width)/2;
			descriptionLabel.y = bodyContainer.y + 60;
			bodyContainer.addChild(descriptionLabel);
			
			//TextSettings.description2.borderColor = 0x77613c;
			if (_top > 0)
			{
				var descriptionLabel2:TextField = Window.drawText(Locale.__e('flash:1476798458495'), TextSettings.description2);
				descriptionLabel2.width = settings.width/2;
				descriptionLabel2.x = (settings.width-descriptionLabel2.width)/2-120;
				descriptionLabel2.y = bodyContainer.y + 310;
				bodyContainer.addChild(descriptionLabel2);
			}
			
			bodyContainer.addChild(itemCont);
			bodyContainer.addChild(topCont);
			
			if (_top > 0)
			{
				var topBttnText:String = Locale.__e('flash:1473845055751', [App.data.top[_top].limit]);
			
				var bttntop:Bitmap = Window.backingShort(200,'bttnTop');
		
				top100Bttn = new IconButton(bttntop.bitmapData,{
						width:		200,
						//height:		90,
						caption:	topBttnText
					});
				top100Bttn.textLabel.y += 3;
				top100Bttn.textLabel.x += 3;
				top100Bttn.addEventListener(MouseEvent.CLICK, 	onTop100Show);
				top100Bttn.x = background.x +background.width-top100Bttn.width- 125;
				top100Bttn.y = background.y +297;
				bodyContainer.addChild(top100Bttn);
			}
			if(_top>0)
			drawTimer();	
		}
		
		private function drawpoints():void 
		{
		
			var backgST:Bitmap = Window.backing(255, 160, 40, "itemBackingYellow");
			backgST.x = background.x + background.width - backgST.width - 60;
			backgST.y = 390;
			bodyContainer.addChild(backgST);
			
			var separator1:Bitmap = Window.backingShort(180, "dividerLine", true);
			separator1.x = backgST.x+(backgST.width - separator1.width) * 0.5;
			separator1.y = backgST.y+(backgST.height-separator1.height)/2;
			bodyContainer.addChild(separator1);
			
			var _poins:int = 0;
			var _rang:int = 0;
			
			for (var c:int = 0; c < contents.length; c++)
				if (contents[c].uID == App.user.id)
				{
					_poins = contents[c].points;
					_rang = c+1;
				}
			
			
			TextSettings.description2.borderColor = 0x7c564d;
			TextSettings.description2.width = 90;
			var desc1:TextField = Window.drawText(Locale.__e('flash:1474035377504'), TextSettings.description2); //D у тебя
			desc1.x =backgST.x+ 30;
			desc1.y = separator1.y - 35;
			bodyContainer.addChild(desc1);
			
			var desc2:TextField = Window.drawText(Locale.__e('flash:1476804461470'), TextSettings.description2); //D у тебя
			desc2.x =backgST.x+ 45;
			desc2.y = separator1.y + 20;
			bodyContainer.addChild(desc2);
			
////////
			TextSettings.description2.fontSize = 22;
			var tpoin:String = Locale.__e('flash:1476866133741');
			var trang:String = Locale.__e('flash:1476866133741');
			if (_poins > 0)
			{
				tpoin = "" + _poins;
				trang = "" + _rang
				TextSettings.description2.fontSize = 41;
			}
			
			
			
			TextSettings.description2.color = 0xfacdb0;
			TextSettings.description2.borderColor = 0x832d14;
			TextSettings.description2.width = 150;
			TextSettings.description2.textAlign='left';
			var desc1Rez:TextField = Window.drawText(tpoin, TextSettings.description2); //D у тебя
			desc1Rez.x =desc1.x+desc1.width+15;
			desc1Rez.y = separator1.y - 55;
			bodyContainer.addChild(desc1Rez);
			
			TextSettings.description2.color = 0xfea702;
			TextSettings.description2.borderColor = 0x745f26;
			var desc1Rez2:TextField = Window.drawText(trang, TextSettings.description2); //D у тебя
			desc1Rez2.x =desc1Rez.x;
			desc1Rez2.y = desc2.y;
			bodyContainer.addChild(desc1Rez2);
			TextSettings.description2.textAlign='center';
		}
		
		public var timerLabel:TextField;
		protected function drawTimer():void {
			var timerBacking:Bitmap = new Bitmap(Window.textures.iconGlow/*mapGlow*/, 'auto', true);// Window.backingShort(150, 'seedCounterBacking'); 		 //D
			timerBacking.x =10;
			timerBacking.y = -10;
			timerBacking.alpha = 0.7;
			bodyContainer.addChild(timerBacking);
			
			var timerDescLabel:TextField = drawText(Locale.__e('flash:1393581955601'), {
				width:			timerBacking.width,
				textAlign:		'center',
				fontSize:		26,
				color:			0xfffcff,
				borderColor:	0x5b3300
			});
			timerDescLabel.x = timerBacking.x + (timerBacking.width - timerDescLabel.width) / 2;
			timerDescLabel.y = timerBacking.y + 20;
			bodyContainer.addChild(timerDescLabel);
			
			timerLabel = drawText('00:00:00', {
				width:			timerBacking.width + 40,
				textAlign:		'center',
				fontSize:		40,
				color:			0xffd855,
				borderColor:	0x3f1b05
			});
			timerLabel.x = timerBacking.x + (timerBacking.width - timerLabel.width) / 2;
			timerLabel.y = timerBacking.y + 45;
			bodyContainer.addChild(timerLabel);
			
			//if (expire < App.time) {			//D
				//timerBacking.visible = false;
				//timerDescLabel.visible = false;
				//timerLabel.visible = false;
			//}
			App.self.setOnTimer(timer);
		}
		
		public function timer():void
		{
			timerLabel.text = TimeConverter.timeToDays((expire < App.time) ? 0 : (expire - App.time));
		}
		
		
		public var topNumber:int;
		public static var rateChecked:int = 0;
		private function onTop100():void 
		{
						
				
			//if (!Happy.users || Numbers.countProps(Happy.users) == 0) return;
			
			//if (rateChecked > 0 && rateChecked + 60 < App.time) {
				//rateChecked = 0;
				//getRate(onTop100);
				//return;
			//}
			
			//changeRate();
			
			var _top:int = 0;
			for(var _t:* in App.data.top)
				if (App.data.top[_t].target == settings.sid){
					_top = _t;
					topNumber = App.data.top[_t].limit;
					expire = App.data.top[_t].expire.e;
					break;
				}
				
			Post.send( {
				ctr:		'top',
				act:		'users',
				uID:		App.user.id,
				tID:		_top// App.user.topID				//D
			}, function(error:int, data:Object, params:Object):void {
				if (error) 
					return;
				
				//if (data.hasOwnProperty('rate'))
					//Happy.users = data['rate'] || { };
			
				if (data.hasOwnProperty('users'))
					Happy.users = data['users'] || { };

				if (Numbers.countProps(Happy.users) > topNumber) 
				{
					var array:Array = [];
					
					for (var s:* in Happy.users) 
					{
						array.push(Happy.users[s]);
					}
					
					array.sortOn('points', Array.NUMERIC | Array.DESCENDING);
					array = array.splice(0, topNumber);
					
					for (s in Happy.users) 
					{
						if (array.indexOf(Happy.users[s]) < 0)
							delete Happy.users[s];
					}
				}
				
				//changeRate();
				
				/*if (settings.target.expire < App.time)
					onUpgradeComplete();*/
					
				//if (onUpdateRate != null) {
					//onUpdateRate();
					//onUpdateRate = null;
				//}
			var k:int = 0;
			for (var _s:* in Happy.users) {
				var user:Object = Happy.users[_s];
				user['uID'] = _s;
				contents.push(user);
				k++
			}
			contents.sortOn('points', Array.NUMERIC | Array.DESCENDING);
			trace("k " + k);
			drawpoints();
			});
			
			
		}
		
		
		
		private function onTop100Show(e:MouseEvent):void 
		{
			var top100DescText:String =  Locale.__e('flash:1467807241824');
			//getReward();
			//this.info.expire = expire;
			new TopWindow( {
				title:info.title,
				expire:expire,
				//target:			this,
				content:		contents,
				description:	top100DescText,
				max:			topNumber,
				sid:settings.sid,
				info:info,
				top:topRewerd
			}).show();
			
			close();
		}
		
		private function drawShape(dy:int, dh:int):void 
		{
			var backingDesc:Shape = new Shape();
			backingDesc.x = background.x+52;
			backingDesc.y = background.y + dy;
			
			bodyContainer.addChild(backingDesc);
		
			backingDesc.graphics.beginFill(0xe4c9ac,1)
			backingDesc.graphics.drawRect(0, 0,background.width - 105,dh);
			backingDesc.graphics.endFill();
		}
		
		private function onHappy(e:MouseEvent):void 
		{
			var unitsArr:Array = Map.findUnits([settings.sid]);
			if (unitsArr.length > 0) {
				this.close();
				App.map.focusedOn(unitsArr[0], true);
			}else {
				this.close();
				new ShopWindow({find:[settings.sid]}).show();
			}
			trace();
		}
	}

}
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class InfoWindowItem extends LayerX {
	
	private var background:Bitmap;
	private var win:Window;
	
	
	public function InfoWindowItem(image:String,i:int, _win:Window,top:Boolean=false) {
		win = _win;
		
		this.tip=function():Object {
				return { title:App.data.storage[sid].title, text:App.data.storage[sid].description };
			}

		var sid:int=App.data.treasures[image][image].item[0]

		
		drawBacking();
		var titlPrms:Object = {
				color			:0xffe354,
				borderColor		:0x5c3903,
				multiline		:true,
				wrap			:true,
				textAlign		:'center',
				fontSize		:28,
				border			:true
			}
		var descPrms:Object = {
				color			:0x7b441b,
				borderColor		:0xffffff,
				multiline		:true,
				wrap			:true,
				textAlign		:'center',
				fontSize		:20,
				border			:true
			}
			
		var txt:String;
		if (top)
			txt = Locale.__e("flash:1473845055751",[i]);					
		else
			txt = Locale.__e("flash:1418735019900", [i]);
			
		var titlLabel:TextField = Window.drawText(txt,titlPrms);
			
			titlLabel.width = background.width-5;
			titlLabel.x =(background.width-titlLabel.width)/2;
			titlLabel.y = -30 ;
			

	
		var descriptionLabel:TextField = Window.drawText(App.data.storage[sid].title,descPrms);
			
			descriptionLabel.width = background.width-5;
			descriptionLabel.x =(background.width-descriptionLabel.width)/2;
			descriptionLabel.y = titlLabel.y + titlLabel.height;
		
		
		var bitmap:Bitmap = new Bitmap();
		
		Load.loading (Config.getIcon(App.data.storage[sid].type,App.data.storage[sid].preview), function (data:*):void {
			bitmap.bitmapData = data.bitmapData;
			//if (bitmap.width > 120){
				//bitmap.width = 120;
				//bitmap.scaleY = bitmap.scaleX;
			//}
			//if (bitmap.height > 120) {
				//bitmap.height = 120;
				//bitmap.scaleX = bitmap.scaleY;			
			//}
			Size.size(bitmap,120,120)
			
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = background.height - bitmap.height-10;
			
		//if(bitmap.height==130)
				//bitmap.y = background.height - bitmap.height;
			//else {	
				//
				//bitmap.y = background.height - bitmap.height- (130- bitmap.height)/2;
			//}
			addChild(bitmap);
			
			addChild (titlLabel);
			addChild (descriptionLabel);
		});
		
		
			
	}
	
		
	private function drawBacking():void {
		background = Window.backing(145, 160, 40, "itemBacking");
		addChildAt(background,0);
	}
}