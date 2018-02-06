package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	public class CalendarWindow extends Window
	{		
		private static var forceAvailable:int = 1;			// Обязательно доступно месяцев от текущего и ниже по списку
		private var maska:Shape;
		private var groupLink:String;
		
		public var dateOffset:int = 0;					// Смещение даты относительно текущей на количество дней. -5 на 5 дней назад
		
		public static var currMonth:uint = 0;
		public static var currYear:uint = 0;
		public static var month:uint;
		public static var year:uint;
		
		public var day:int = 0;
		public var takenInMonth:int = 0;
		public var totalInMonth:int = 0;
		public var monthData:Object = { };
		public var title:String = Locale.__e("flash:1393413668177");
		public var data:Array = [];
		public var availMonthList:Array = [];
		
		public var serverDate:Date;
		
		public var calendarContainer:Sprite;
		public var pressent:PressentBox;
		public var bttnHelp:Button;
		public var bttnGroup:Button;
		public var postTitleLabel:TextField;
		public var postCalLabel:TextField;
		public var countLabel:TextField;
		public var countTitleLabel:TextField;
		public var calendarImage:Bitmap;
		
		public var focused:DayIcon;
		public var pages:Array = [];
		
		public function CalendarWindow(sett:Object = null) 
		{
			if (!sett) sett = { };
			sett['width'] = sett.width || 860;
			sett['height'] = sett.height || 680;
			sett['title'] = title;
			sett['paginator'] = sett.paginator || true;
			sett['hasButtons'] = false;
			sett['exitTexture'] = 'closeBttnMetal';
			
			serverDate = new Date();
			
			serverDate.setTime((App.midnight + serverDate.timezoneOffset * 60 + 3600 * 12 + dateOffset * 86400) * 1000);
			
			day = serverDate.getDate() ;
			month = serverDate.getMonth() + 1 ;
			year = serverDate.getFullYear();
			currMonth = month;
			currYear = year;
			
			for (var years:* in App.user.calendar) 
			{
				for (var months:* in App.user.calendar[years]) 
				{
					if (String(months).length == 1) 
					{
						pages.push(String(years) + '.0' + String(months));
					}else {
						pages.push(String(years) + '.' + String(months));
					}
				}
			}
			
			pages.sort();
			
			//Оставляем только две страницы
			if (pages.length > 2) 
			{
				pages = pages.splice(-2);
			}				
			
			super(sett);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title/* + ": " + App.data.calendar[currMonth].title*/, 
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 45,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x0a557e,			
				borderSize 			: 3,					
				shadowColor			: 0x0a557e,
				width				: 300,
				textAlign			: 'center'
			})
			
			titleLabel.y = -15;
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBackground():void 
		{	
			var background:Bitmap = backing(settings.width, settings.height ,50, 'capsuleWindowBacking');
			layer.addChild(background);	
			var background2:Bitmap = backing2(775, 504 , 45, 'calImgUp', 'calImgBot');
			background2.x = (background.width - background2.width) / 2;
			background2.y = 35;
			layer.addChild(background2);
			
		}
		
		public static function format():void
		{			
			// Создание значений по умолчанию
			
			var year:int = new Date().getFullYear();
			var month:int = new Date().getMonth();
			if (!App.user.calendar) App.user.calendar = { };
			while (forceAvailable > 0) {
				if (!App.user.calendar.hasOwnProperty(year)) App.user.calendar[year] = { };
				if (!App.user.calendar[year].hasOwnProperty(month + 1)) App.user.calendar[year][month + 1] = '';
				
				month--;
				if (month < 0) {
					month = 11;
					year --;
				}
				
				forceAvailable--;
			}
			
			
			// Разбивка на объект год.месяц.день
			for (var years:* in App.user.calendar) {
				if (int(years) < 2013) {
					delete App.user.calendar[years];
					continue;
				}
				
				for (var months:* in App.user.calendar[years]) {
					if ((App.user.calendar[years][months] is String) && App.user.calendar[years][months].length == 0) {
						App.user.calendar[years][months] = [];
					}else{
						App.user.calendar[years][months] = String(App.user.calendar[years][months]).split(',');
						for (var j:int = 0 ; j < App.user.calendar[years][months].length; j++) {
							App.user.calendar[years][months][j] = int(App.user.calendar[years][months][j]);
							if (App.user.calendar[years][months][j] < 1)
								App.user.calendar[years][months].splice(j, 1);
						}
					}
				}
			}
			
			// Автоматически открыть дни
			if (App.data.options.hasOwnProperty('CalendarOpen')) {
				try {
					var info:Object = JSON.parse(App.data.options['CalendarOpen']);
				}catch (e:*) {
					return;
				}
				
				if (!info.hasOwnProperty('social') || info.social.indexOf(App.social) < 0) return;
				if (App.user.calendar.hasOwnProperty(Numbers.firstProp(info.calendar).key) && App.user.calendar[Numbers.firstProp(info.calendar).key].hasOwnProperty(Numbers.firstProp(Numbers.firstProp(info.calendar).val).key))
				{
					for (var openYear:String in info.calendar) {
						for (var openMonth:String in info.calendar[openYear]) {
							for (var i:int = 0; i < info.calendar[openYear][openMonth].length; i++) {
								var skip:Boolean = false;
								try {
									if ((App.user.calendar[openYear][openMonth].indexOf(info.calendar[openYear][openMonth][i]) >= 0)||(App.user.calendar[openYear][openMonth][0] == openYear)) {
										skip = true;
									}
								}catch (e:*) { }
								
								if (skip) continue;
								
								Post.send( {
									uID:	App.user.id,
									ctr:	'Calendar',
									act:	'take',
									d:		info.calendar[openYear][openMonth][i],
									m:		openMonth,
									y:		openYear
								}, function(error:int, data:Object, params:Object):void {
									if (error || !data.bonus) return;
									
									if (!App.user.calendar.hasOwnProperty(openYear)) App.user.calendar[openYear] = { };
									if (!App.user.calendar[openYear].hasOwnProperty(openMonth)) App.user.calendar[openYear][openMonth] = [];
									
									App.user.calendar[openYear][openMonth].push(params.day);
									//App.user.stock.addAll(data.bonus);
								}, { day:info.calendar[openYear][openMonth][i] } );
							}
						}
					}
				}
			}
			
		}
		
		public static function setTake(year:*, month:*, day:*):void 
		{
			if (!App.user.calendar.hasOwnProperty(year)) App.user.calendar[year] = { };
			if (!App.user.calendar[year].hasOwnProperty(month)) App.user.calendar[year][month] = [];
			if (!isNaN(int(day)) && App.user.calendar[year][month].indexOf(int(day)) < 0)
				App.user.calendar[year][month].push(int(day));
		}
		
		override public function drawBody():void 
		{
			
			this.y -= 15;
			fader.y += 15;
			//drawTitle();
			exit.x = settings.width - 50;
			exit.y = -3;
			
			var star1:Bitmap = new Bitmap(Window.textures.decConstructStar1);
			star1.x = titleLabel.x + titleLabel.width + star1.width - 60;
			star1.y = titleLabel.y - star1.height + 20;
			star1.scaleX = star1.scaleY = 0.8;
			star1.smoothing = true;
			star1.filters = [new DropShadowFilter(2.0, 90, 0, 0.8, 4.0, 4.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(star1);
			
			var star2:Bitmap = new Bitmap(Window.textures.decStarBlue);
			star2.x = -5;
			star2.y = titleLabel.y - 30;
			star1.smoothing = true;
			star2.filters = [new DropShadowFilter(2.0, 90, 0, 0.8, 4.0, 4.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(star2);
			
			calendarContainer = new Sprite();
			calendarContainer.x = 50;
			calendarContainer.y = 38;
			bodyContainer.addChild(calendarContainer);
			
			bttnHelp = new Button( {
				caption:Locale.__e('flash:1382952380254'),
				fontSize:20,
				width:102,
				height:40
			});
			
			bodyContainer.addChild(bttnHelp);
			bttnHelp.x = 50;
			bttnHelp.y = 575;
			bttnHelp.addEventListener(MouseEvent.CLICK, onHelpEvent);
			
			var backgroundTitle:Shape = new Shape();
			backgroundTitle.graphics.beginFill(0xf0c001, .6);
		    backgroundTitle.graphics.drawRect(0, 0, 580, 60);
		    backgroundTitle.graphics.endFill();
			backgroundTitle.filters = [new BlurFilter(40, 0, 2)];
			//var backgroundTitle:Bitmap = Window.backingShort(600, 'dailyBonusBackingDesc', true);
			backgroundTitle.x =  bttnHelp.x + 15;
			//backgroundTitle.height = 60;
			backgroundTitle.y = bttnHelp.y - 65;
			//backgroundTitle.alpha = .4;
			bodyContainer.addChild(backgroundTitle);
			
			var crab:Bitmap = new Bitmap(Window.textures.crabQuest);
			crab.x = bttnHelp.x + 350;
			crab.y = settings.height - 242;
			bodyContainer.addChild(crab);
			
			checkGroup();
			
			if (groupLink) 
			{
				bttnGroup = new Button( {
					caption:Locale.__e('flash:1435747596741'),
					fontSize:20,
					width:102,
					height:40
				});
				
				bodyContainer.addChild(bttnGroup);
				bttnGroup.x = 340;
				bttnGroup.y = 578;
				bttnGroup.addEventListener(MouseEvent.CLICK, onGroupEvent);	
				postCalLabel = Window.drawText(Locale.__e("flash:1393413424908")+" "+Locale.__e("flash:1435832524082"), {
					width:			550,
					height:			100,
					fontSize:		20,
					color:			0xf0e6c1,
					borderColor:	0x5c472c,
					autoSize:		'right',
					textAlign:		'right',
					wrap:			true
				});
				
				postCalLabel.x = (App.lang == 'en')?65:45;
				postCalLabel.y = 515;
				bodyContainer.addChild(postCalLabel);
			
			}else 
			{
				postCalLabel = Window.drawText(Locale.__e("flash:1393413424908"), {
					width:			550,
					height:			100,
					fontSize:		20,
					color:			0xf0e6c1,
					borderColor:	0x5c472c,
					autoSize:		'right',
					textAlign:		'right',
					wrap:			true
				});
				//postCalLabel.wordWrap = true;
				postCalLabel.x = 45;
				postCalLabel.y = 515;
				//postCalLabel.border = true;
				bodyContainer.addChild(postCalLabel);	
			}
			
			countLabel = Window.drawText('', {
				width:			120,
				height:			60,
				fontSize:		48,
				color:			0xf7e574,
				borderColor:	0x5c472c,
				borderSize:		4,
				textAlign:		'center',
				filters:		[new DropShadowFilter(2,90,0x5c472c,1,0,0,1)]
			});
			countLabel.x = 470;
			countLabel.y = 404;
			bodyContainer.addChild(countLabel);
			
			countTitleLabel = Window.drawText(Locale.__e("flash:1393414205114"), {
				width:			120,
				height:			36,
				fontSize:		26,
				color:			0xf6f1df,
				borderColor:	0x5c472c,
				borderSize:		3,
				textAlign:		'center',
				filters:		[new DropShadowFilter(2,90,0x5c472c,1,0,0,1)]
			});
			countTitleLabel.x = 470;
			countTitleLabel.y = 450;
			bodyContainer.addChild(countTitleLabel);
			
			pressent = new PressentBox(0, this, false);
			pressent.x = 650;
			pressent.y = 430;
			bodyContainer.addChild(pressent);
			
			paginator.hasPoints = false;
			paginator.onPageCount = 1;
			paginator.itemsCount = pages.length;//availMonthList.length;
			paginator.page = pages.length - 1;
			paginator.update();
			
			contentChange();
		}
		
		private function checkGroup():void 
		{
			switch (App.social) 
			{
				case 'DM':
				groupLink = 'https://vk.com/club134271154';	
				break;
				case 'VK':
				groupLink = 'https://vk.com/club134271154';	
				break;
				case 'OK':
				groupLink = 'http://ok.ru/group/53483724406972'
				break;
				case 'FS':
				groupLink = 'http://fotostrana.ru/public/344947'
				break;
				case 'MM':
				groupLink = 'http://my.mail.ru/community/deepfarm'
				break;
				case 'FB':
				groupLink = 'https://facebook.com/Deepsea-Story-Community-1493576820663172/'	
				break;
			default:
				groupLink = '';
			}
		}
		
		private function onGroupEvent(e:MouseEvent):void 
		{
			navigateToURL(new URLRequest(groupLink));
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			paginator.arrowRight.y = 254;
			paginator.arrowRight.x = 820;
			paginator.arrowLeft.y = 250;
			paginator.arrowLeft.x = 42;
		}
		
		public function drawCalendar():void {
			
			const rowIndent:int = 40;
			const cellIndent:int = 0;
			const rowSize:int = 110;
			const cellSize:int = 100;
			
			
			initMonthData();
			clearCalendar();
			
			
			var array:Array = pages[paginator.page].split('.');
			year = int(array[0]);
			month = int(array[1]);
			var daysOnMonth:int = new Date(year, month, 0).getDate();
			calendarImage  = new Bitmap();
			maska = new Shape();
			//Load.loading(Config.getSwf('Calendar', 'calendar' + (month) + year), onLoad);
			Load.loading(Config.getImage('calendar', 'calendar' + (month) + year, 'jpg'), onLoad);
			
			calendarContainer.addChild(maska);
			calendarContainer.addChild(calendarImage);
			
			
			settings.title = title + ": " + App.data.calendar[month].title;
			while (titleLabel.numChildren > 0) {
				titleLabel.removeChildAt(0);
			}
			
			if (App.user.calendar[year][month][0] == year)
				pressent.update(App.data.calendar[month].reward, true);
			
			for (var i:int = 0; i < daysOnMonth; i++) {
				
				if (App.data.calendar[month] && App.data.calendar[month].hasOwnProperty('items') && App.data.calendar[month].items.hasOwnProperty(i + 1))
					for (var sid:* in App.data.calendar[month].items[i + 1]) break;
				
				var dayIcon:DayIcon = new DayIcon(getState(i + 1), {
					window:		this,
					day:		i+1,
					month:		month,
					year:		year,
					sid:		int(sid),
					skip:		App.data.calendar[month].skip,
					daysOnMonth:daysOnMonth
				});
				dayIcon.x = rowIndent + rowSize * (i % 7);
				dayIcon.y = cellIndent + cellSize * Math.floor(i / 7);
				calendarContainer.addChild(dayIcon);
			}
			
			function getState(index:int):String {
				/*var cd:* = day;
				var mth:* = month;
				var cm:* = currMonth;
				var cy:* = currYear;
				var yr:* = year;
				
				if (months.hasOwnProperty(index) || months is String) {
					return DayIcon.TAKEN;
				}else if (index == day && month == currMonth) {
					return DayIcon.OPEN;
				}else if ((index < day && month == currMonth) || (((month <= currMonth && year == currYear) || (month > currMonth && year < currYear)) && availMonthList.indexOf(month) >= 0)) {
					return DayIcon.LOCKED;
				}else {
					return DayIcon.CLOSE;
				}*/
			//return DayIcon.LOCKED;
				if (!App.user.calendar.hasOwnProperty(year) || !App.user.calendar[year].hasOwnProperty(month) || (year > CalendarWindow.currYear || (year == CalendarWindow.currYear && month > CalendarWindow.currMonth) || (year == CalendarWindow.currYear && month == CalendarWindow.currMonth && day < index))) {
					return DayIcon.CLOSE;
				}else if (App.user.calendar[year][month].indexOf(index) >= 0 || App.user.calendar[year][month].indexOf(year) >= 0) {
					return DayIcon.TAKEN;
				}else if (month == CalendarWindow.currMonth && index == day) {
					return DayIcon.OPEN;
				}else {
					return DayIcon.LOCKED;
				}
			}
		}
		
		
		public function onLoad(data:*):void {
			
			
			//calendarImage.bitmapData = data.calendar;
			calendarImage.bitmapData = data.bitmapData;
			maska.graphics.beginFill(0xFFFFFF, 1);
			maska.graphics.drawRoundRect(0, 0, calendarImage.width-5, calendarImage.height-10, 40, 40);
			maska.graphics.endFill();
			
			maska.x = (calendarImage.width - maska.width) / 2;
			maska.y = (calendarImage.height - maska.height) / 2;
			calendarImage.mask = maska;
			maska.x -= 7;
			maska.y -= 42;
			calendarImage.x -= 8;
			calendarImage.y -= 42;
		//	textures = data;
			//trace('1');
			
		//	setCloudCoords();
		//	checkFlagCoords();
			
					
			
				
		}
		
		public function clearCalendar():void {
			while (calendarContainer.numChildren > 0) {
				if(calendarContainer.getChildAt(0) is DayIcon) {
					var dayicon:DayIcon = calendarContainer.getChildAt(0) as DayIcon;
					dayicon.dispose();
					calendarContainer.removeChild(dayicon);
				}else {
					calendarContainer.removeChildAt(0);
				}
			}
		}
		public function initMonthData():void {
			data = [];
			
			if (!App.data.calendar.hasOwnProperty(month)) return;
			
			monthData = App.data.calendar[month];
			for (var i:int = 0; i < totalInMonth; i++) {
				if	(!monthData.items.hasOwnProperty(i + 1)) break;
				
				data.push(monthData.items[String(i+1)]);
			}
		}
		
		override public function contentChange():void {
			drawCalendar();
			update();
		}
		
		private function onHelpEvent(e:MouseEvent):void {
			new SimpleWindow( {
				popup:		true,
				title:		title,
				text:		Locale.__e("flash:1393413640436")
			}).show();
		}
		
		public function update(redraw:Boolean = false):void {
			/*takenInMonth = 0;
			
			if (App.user.calendar.hasOwnProperty(month)) {
				for (var i:String in App.user.calendar[month]) {
					takenInMonth++;
				}
				if (App.user.calendar[month] is String) takenInMonth = totalInMonth;
			}
			
			if (countLabel) countLabel.text = String(takenInMonth) + "/" + String(totalInMonth);
			if (takenInMonth == totalInMonth && !(App.user.calendar[month] is String))
				pressent.update(App.data.calendar[month].reward, true);*/
			
			if (App.user.calendar[year][month].indexOf(year) >= 0) {
				countLabel.text = String(new Date(year, month, 0).getDate()) + "/" + String(new Date(year, month, 0).getDate());
			}else {
				countLabel.text = String(App.user.calendar[year][month].length) + "/" + String(new Date(year, month, 0).getDate());
			}
			
			if (App.user.calendar[year][month].indexOf(year) < 0 && App.user.calendar[year][month].length >= new Date(year, month, 0).getDate()) {
				pressent.update(App.data.calendar[month].reward, true);
			}else {
				pressent.update(App.data.calendar[month].reward, false);
			}
			headerContainer.removeChild(titleLabel);
			drawTitle();
		}
		
		override public function close(e:MouseEvent = null):void {
			super.close();
		}
		
		override public function dispose():void {
			clearCalendar();
			bttnHelp.removeEventListener(MouseEvent.CLICK, onHelpEvent);
			pressent.dispose();
			
			super.dispose();
		}
	}
	
}
import buttons.Button;
import buttons.MoneyButton;
import com.adobe.net.URIEncodingBitmap;
import com.greensock.easing.Cubic;
import com.greensock.TweenLite;
import core.Load;
import core.Post;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.setTimeout;
import ui.UserInterface;
import units.Anime;
import wins.CalendarWindow;
import wins.SimpleWindow;

internal class DayIcon extends LayerX {
	
	public static const FREE:String = 'free';			// Неактивное свободное отображениe
	public static const CLOSE:String = 'close';			// Закрыт. Не наступил день, чтоб можно было забрать.
	public static const OPEN:String = 'open';			// Открыт сегодня. Можно забрать.
	public static const LOCKED:String = 'locked';		// Закрыт. Можно забрать платно.
	public static const TAKEN:String = 'taken';			// Забран
	
	private var _state:String = CLOSE;
	public var window:*;
	public var year:uint;
	public var month:uint;
	public var day:uint;
	public var sid:String = '';
	public var skip:uint = 1;
	public var pressent:Object;
	public var currWidth:int = 90;
	public var currWidthBttn:int = 50;
	public var currHeight:int = 78;
	
	public var iconContainer:LayerX;
	public var backing:Bitmap;
	public var backTile:Bitmap;
	public var item:Bitmap;
	public var query:Bitmap;
	public var textOpen:TextField;
	public var textTake:TextField;
	public var bttnTake:Button;
	public var bttnOpen:MoneyButton;
	private var preloader:Preloader;
	private var daysOnMonth:int;
	private var textClosed:TextField;
	
	public function DayIcon(state:String, settings:Object) {
		window = settings.window;
		year = settings.year || NaN;
		month = settings.month || NaN;
		day = settings.day || NaN;
		sid = settings.sid;
		skip = settings.skip || skip;
		daysOnMonth = settings.daysOnMonth || 30;
		draw();
		this.state = state;
	}
	
	public function draw():void 
	{
		iconContainer = new LayerX();
		drawTile();
		
		iconContainer.x = -currWidth/2;
		iconContainer.y = -currHeight/2;
		iconContainer.addEventListener(MouseEvent.CLICK, onClick);
		addChild(iconContainer);
		
		preloader = new Preloader();
		
		query = new Bitmap(Window.textures.showMeBttn, 'auto', true);
		query.x = Math.floor((backTile.width - query.width) / 2);
		query.y = Math.floor((backTile.height - query.height) / 2);
		iconContainer.addChild(query);
		
		textClosed = Window.drawText(String(day), {
			width:		115,
			height:		100,
			fontSize:	50,
			color:		0xffffff,
			borderColor:0x4d4bbf,
			textAlign:	'center'
		});
		//textClosed.border = true;
		
		//textClosed.x = -16 + textClosed.textWidth/2;
		textClosed.y = 23;
		textClosed.alpha = 0.8;
		iconContainer.addChild(textClosed);
		
		textOpen = Window.drawText(Locale.__e("flash:1382952379890"), {
			width:		currWidthBttn+50,
			height:		60,
			fontSize:	26,
			color:		0xffffff,
			borderColor:0x4d4bbf,
			autoSize:	'none',
			textAlign:	'center'
		});
		
		textOpen.x  = 5;
		textOpen.y = 2;
		textOpen.alpha = .7;
		iconContainer.addChild(textOpen);
		
		textTake = Window.drawText(Locale.__e("flash:1382952379737"), {
			width			:currWidthBttn+50,
			height			:60,
			fontSize		:26,
			color			:0xffffff,
			borderColor		:0x4d4bbf,
			autoSize		:'none',
			textAlign		:'center'
		});
		textTake.x = 5;
		textTake.y = 2;
		//textTake.alpha = .7;
		iconContainer.addChild(textTake);
		
		bttnTake = new Button( {
			width			:currWidthBttn,
			height			:36,
			fontSize		:26,	
			fontBorderColor	:0x4d4bbf,
			caption			:Locale.__e('flash:1435740909971')
		});
		
		bttnTake.x =-13
		bttnTake.y = -6;
		bttnTake.addEventListener(MouseEvent.CLICK, onTake);
		addChild(bttnTake);
		
		//Кнопка открытия за валюту
		bttnOpen = new MoneyButton( {
			width			:currWidthBttn,
			height			:36,
			countText		:skip,
			caption			:'none',
			fontSize		:24,	
			iconDY			:2,			
			bevelColor		:[0x176dfd, 0x3194a7],
			bgColor			:[0xd56aff, 0x29cdff]
		});
		
		bttnOpen.coinsIcon.scaleX = bttnOpen.coinsIcon.scaleY = 0.5;
		bttnOpen.x =-15
		bttnOpen.y = -5;
		bttnOpen.addEventListener(MouseEvent.CLICK, onOpen);
		bttnOpen.countLabel.x -= 4;
		bttnOpen.countLabel.y -= 1;
		addChild(bttnOpen);
	}
	
	private function drawTile():void 
	{
		backTile = new Bitmap;
		switch (day) 
		{
			case 1:
			backTile.bitmapData = Window.textures.tile1;	
			break;
			case 2:
			case 4:
			case 6:
			backTile.bitmapData = Window.textures.tile6;
			backTile.x -= 29;
			break;
			case 3:
			case 5:
			backTile.bitmapData = Window.textures.tile5;	
			break;
			case 7:
			backTile.bitmapData = Window.textures.tile1;	
			backTile.scaleX = -1;
			backTile.x += backTile.width;
			break;
			case 8:
			backTile.bitmapData = Window.textures.tile3;		
			break;
			case 9:
			case 11:
			case 13:
			backTile.bitmapData = Window.textures.tile2;	
			backTile.y -= 29;
			break;
			case 10:
			case 12:
			backTile.bitmapData = Window.textures.tile4;
			backTile.x -= 29;
			backTile.y -= 1;
			break;
			case 14:
			backTile.bitmapData = Window.textures.tile3;
			backTile.scaleX = -1;
			backTile.x += backTile.width;			
			backTile.x -= 29;			
			break;
			case 15:
			backTile.bitmapData = Window.textures.tile10;
			backTile.y -= 29;
			break;
			case 16:
			case 18:
			case 20:
			backTile.bitmapData = Window.textures.tile4;
			backTile.x -= 29;
			break;
			case 17:
			case 19:
			backTile.bitmapData = Window.textures.tile2;
			backTile.y -= 29;
			break;
			case 21:
			backTile.bitmapData = Window.textures.tile10;
			backTile.scaleX = -1;
			backTile.x += backTile.width;
			backTile.y -= 28;
			break;
			case 22:
			if (daysOnMonth>28) 
			{
				backTile.bitmapData = Window.textures.tile3;
			}else 
			{
				backTile.bitmapData = Window.textures.tile8;
				backTile.scaleX = -1;
				backTile.x += backTile.width;
			}	
			break;
			case 23:
			if (daysOnMonth >= 30) 
			{
				backTile.bitmapData = Window.textures.tile2;//тут
				backTile.y -= 29;
			}else 
			{
				backTile.bitmapData = Window.textures.tile5;
				backTile.scaleY = -1;
				backTile.y += backTile.height;
				backTile.y -= 29;
			}			
			if (daysOnMonth == 29) 
			{
				backTile.bitmapData = Window.textures.tile5;	
				backTile.scaleY = -1;
				backTile.y += backTile.height;		
			}
			break;
			case 25:
			case 27:
			backTile.bitmapData = Window.textures.tile5;
			backTile.scaleY = -1;
			backTile.y += backTile.height;
			backTile.y -= 29;
			break;
			case 24:
			if (daysOnMonth >= 31) 
			{
				backTile.bitmapData = Window.textures.tile4;
				backTile.y -= 1;
				backTile.x -= 29;
			}else 
			{
				backTile.bitmapData = Window.textures.tile6;//тут
				backTile.scaleY = -1;	
				backTile.y += backTile.height;
				backTile.x -= 29;
			}
			break;
			case 26:
			backTile.bitmapData = Window.textures.tile6;
			backTile.scaleY = -1;
			backTile.y += backTile.height;
			backTile.x -= 29;
			break;
			case 28:
			backTile.bitmapData = Window.textures.tile8;
			backTile.x -= 29;
			break;
			case 29:
			if (daysOnMonth == 29) 
			{
				backTile.bitmapData = Window.textures.tile9;	
				backTile.scaleY = -1;
				backTile.y += backTile.height;		
			}else 
			{
				backTile.bitmapData = Window.textures.tile1;//тут	
				backTile.scaleY = -1;
				backTile.y += backTile.height;	
				backTile.y -= 30;
			}
			break;
			case 30:
			if (daysOnMonth == 30) 
			{
				backTile.bitmapData = Window.textures.tile8;
				backTile.y -= 1;
				//backTile.x -= 29;
			}else 
			{
				backTile.bitmapData = Window.textures.tile6;	
				backTile.scaleY = -1;
				backTile.y += backTile.height;		
			}
			backTile.x -= 29;
			break;
			case 31:
			if (daysOnMonth==31) 
			{
				backTile.bitmapData = Window.textures.tile7;
				backTile.y -= 30;
			}				
			break;
			default:
			backTile.bitmapData = Window.textures.tile1;	
			break;
		}
		
		iconContainer.addChild(backTile);
		backTile.x -= 2;
		backTile.y -= 2;
		
		
	}
	
	public function set state(value:String):void
	{
		_state = value;
		query.visible = false;
		textOpen.visible = false;
		textTake.visible = false;
		bttnTake.visible = false;
		bttnOpen.visible = false;
		backTile.visible = false;
		textClosed.visible = false;
		
		switch(value)
		{
			case OPEN:
				bttnTake.visible = true;
				backTile.visible = true;
				textTake.visible = true;
				break;
			case LOCKED:				
				textOpen.visible = true;
				bttnOpen.visible = true;
				backTile.visible = true;
				break;
			case TAKEN:
				break;
			case FREE:
				break;
			case CLOSE:
				backTile.visible = true;
				textClosed.visible = true;
				break;
			default:
				query.visible = true;
		}
		
		if (_state == OPEN || _state == TAKEN || _state == FREE) 
		{
		}else if (_state == CLOSE)		{
			iconContainer.tip = function():Object 
			{
				var date:Date = new Date();
				date.setTime((App.midnight + 86400 * (day - window.day)) * 1000);
				
				var time:int = date.getTime() / 1000 - App.time - window.dateOffset * 86400;
				if (time < 0) time = 0;
				return {
					title: Locale.__e('flash:1393581955601'),
					text: TimeConverter.timeToDays(time),
					timer: true
				}
			}
		}else{
			iconContainer.tip = null;
		}
	}
	
	public function get state():String 
	{
		return _state;
	}
	
	public function onTake(e:MouseEvent = null):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		e.currentTarget.mode = Button.DISABLED;
		
		App.ui.upPanel.calendarBttn.hideGlowing();
		
		Post.send( {
			uID:	App.user.id,
			ctr:	'Calendar',
			act:	'take',
			m:		month,
			d:		day,
			y:		year
		}, function(error:int, data:Object, params:Object):void 
		{
			bttnTake.mode = Button.NORMAL;
			
			if (error) 
			{
				if (error == 66 && !data) 
				{
					data = {};
					data['bonus'] = {};
					data.bonus = App.data.calendar[month].items[day];
				}else {
					notStore();
					return;
				}
			}
			if (!User.inExpedition)
			{
				App.user.stock.addAll(data.bonus);
			}
			if (!error) take(data.bonus, e);
			state = TAKEN;
			
			CalendarWindow.setTake(year, month, day);
			windowUpdate();
		}, {});
	}
	
	public function onOpen(e:MouseEvent = null):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		e.currentTarget.mode = Button.DISABLED;
		
		if (!App.user.stock.check(Stock.FANT, skip)) 
		{
			bttnOpen.mode = Button.NORMAL;
			return;
		}
		
		Post.send( {
			uID:	App.user.id,
			ctr:	'Calendar',
			act:	'buy',
			m:		month,
			d:		day,
			y:		year
		}, function(error:int, data:Object, params:Object):void {
			bttnOpen.mode = Button.NORMAL;
			
			if (error) {
				if (error == 72 && !data) {
					data = {};
					data['bonus'] = {};
					data.bonus = App.data.calendar[month].items[day];
				}else{
					return;
				}
			}
			
			state = TAKEN;
			App.user.stock.take(Stock.FANT, skip);
			
			if (!User.inExpedition) 
			{
			App.user.stock.addAll(data.bonus);
			
			}
			if (!error) take(data.bonus, e);
			App.ui.upPanel.update();
			
			
			CalendarWindow.setTake(year, month, day);
			windowUpdate();
		}, {});
	}
	
	public function onClick(e:MouseEvent = null):void 
	{
	}
	
	private function take(items:Object, e:MouseEvent = null):void 
	{
		for (var i:String in items) 
		{
			Load.loading(Config.getIcon(App.data.storage[i].type, App.data.storage[i].preview), function(data:Bitmap):void {			
				rewardW = new Bitmap;
				rewardW.bitmapData = data.bitmapData;
				wauEffect(e);
			});
		}
	}

	private function windowUpdate():void
	{
		window.update();
	}
	
	private function setFocused():void 
	{
		var scale:Number = (window.focused == this && this.scaleX == 1.2) ? 1 : 1.2;
		var that:* = this;
		
		if (window.focused)
		{
			TweenLite.to(window.focused, 0.12, { scaleX:1, scaleY:1 } );
		}
		
		TweenLite.to(this, 0.12, {
			scaleX:scale,
			scaleY:scale,
			onComplete:onComplete
		} );
		
		function onComplete():void {
			window.focused = that as DayIcon;
		}
	}
	
	public var rewardW:Bitmap;
	public var rewardCont:Sprite;
	private function wauEffect(e:MouseEvent =  null):void
	{
		if (rewardW.bitmapData != null) 
		{
			rewardCont = new Sprite();
			App.self.windowContainer.addChild(rewardCont);
			
			var glowCont:Sprite = new Sprite();
			glowCont.alpha = 0.6;
			glowCont.scaleX = glowCont.scaleY = 0.5;
			rewardCont.addChild(glowCont);
			
			var glow:Bitmap = new Bitmap(Window.textures.dailyBonusItemGlow);
			glow.scaleX = glow.scaleY = 2.4;
			glow.smoothing = true;
			glow.x = -glow.width / 2;
			glow.y = -glow.height / 2;
			glowCont.addChild(glow);
			
			//var glow2:Bitmap = new Bitmap(Window.textures.actionGlow);
			//glow2.scaleY = -1;
			//glow2.x = -glow2.width / 2;
			//glow2.y = glow.height - 90;
			//glowCont.addChild(glow2);
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(rewardW.width, rewardW.height, true, 0));
			bitmap.bitmapData = rewardW.bitmapData;
			bitmap.smoothing = true;
			bitmap.x = -bitmap.width / 2 - 8;
			bitmap.y = -bitmap.height / 2 + 5;
			rewardCont.addChild(bitmap);
			
			if (e) {
				rewardCont.x = e.target.parent.x + e.target.parent.width / 2;
				rewardCont.y = e.target.parent.y + e.target.parent.height / 2;
			} else {
				rewardCont.x = rewardCont.y = 0;
			}
			
			function rotate():void {
				glowCont.rotation += 1.5;
			}
			
			App.self.setOnEnterFrame(rotate);
			rewardCont.addEventListener(MouseEvent.CLICK, closeEarly);
			//TweenLite.from(rewardCont, 0.5, { x:, y:bttnOpen.mouseY} );
			
			TweenLite.to(rewardCont, 0.5, { x:App.self.stage.stageWidth / 2, y:App.self.stage.stageHeight / 2, scaleX:1.25, scaleY:1.25, ease:Cubic.easeInOut, onComplete:function():void {
				setTimeout(function():void {
					App.self.setOffEnterFrame(rotate);
					glowCont.alpha = 0;
					var bttn:* = App.ui.bottomPanel.bttnMainStock;
					var _p:Object = { x:bttn.x + App.ui.bottomPanel.mainPanel.x, y:bttn.y + App.ui.bottomPanel.mainPanel.y};
					SoundsManager.instance.playSFX('takeResource');
					TweenLite.to(rewardCont, 0.3, { ease:Cubic.easeOut, scaleX:0.7, scaleY:0.7, x:_p.x, y:_p.y, onComplete:function():void {
						TweenLite.to(rewardCont, 0.1, { alpha:0, onComplete:function():void {
							if(rewardCont.parent)
								rewardCont.parent.removeChild(rewardCont);
							rewardCont.removeEventListener(MouseEvent.CLICK, closeEarly);}} );
					}} );
				}, 3000)
			}} );
		}
	}
	public function closeEarly(e:MouseEvent = null):void
	{
		if (e.currentTarget)
		{
			rewardCont.parent.removeChild(rewardCont);
			rewardCont.removeEventListener(MouseEvent.CLICK, closeEarly);
		}
		else
			return;
	}
	
	public function notStore():void {
		new SimpleWindow( {
			label:		SimpleWindow.ERROR,
			popup:		true,
			title:		Locale.__e('flash:1393413668177'),
			text:		Locale.__e('flash:1382952379692')
		}).show();
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		bttnTake.removeEventListener(MouseEvent.CLICK, onTake);
		bttnOpen.removeEventListener(MouseEvent.CLICK, onOpen);
	}
}

import wins.Window;

internal class PressentBox extends LayerX {
	
	public var backing:Bitmap;
	public var bttnTake:Button;
	public var preloader:Preloader;
	public var textLabel:TextField;
	public var window:CalendarWindow;
	public var image:LayerX;
	public var checkmark:Bitmap;	
	public var sID:int = 0;
	public var animate:Boolean = false;
	
	function PressentBox(sid:uint = 0, window:CalendarWindow = null, taken:Boolean = false) {
		
		this.window = window;
		sID = sid;
		
		backing = new Bitmap(Window.textures.calendarBubble); //Подложка награды 
		addChild(backing);
		
		preloader = new Preloader();
		preloader.x = backing.width / 2;
		preloader.y = backing.height / 2;
		
		image = new LayerX();
		image.mouseEnabled = true;
		
		image.tip = function():Object {
			return {
				title:		App.data.storage[sID].title,
				text:		App.data.storage[sID].description
			};
		}
		
		bttnTake = new Button( {
			width:		110,
			height:		36,
			color:		0x614605,
			borderColor:0xFFFFFF,
			size:		32,
			caption:	Locale.__e('flash:1382952379737')
		});
		
		bttnTake.x = 18;
		bttnTake.y = 152;
		bttnTake.addEventListener(MouseEvent.CLICK, onTake);
		
		
		checkmark = new Bitmap(Window.textures.checkMark, 'auto', true);
		checkmark.x = backing.x + backing.width / 2 - checkmark.width / 2;
		checkmark.y = Math.floor((backing.height - checkmark.height) / 2);		
		update(sid, taken);
	}
	
	public function update(sid:uint, taken:Boolean = false):void
	{
		if (!App.data.storage.hasOwnProperty(sid)) return;
		
		sID = sid;
		bttnTake.visible = taken;
		
		if (textLabel && textLabel.parent)
			textLabel.parent.removeChild(textLabel);
			
		textLabel = Window.drawText(App.data.storage[sid].title, {
			textSize:		50,
			textAlign:		'center',
			color:			0xffffff,
			borderColor:	0x5c472c,
			multiline:		true,
			width:			160
		});
		
		textLabel.y = -20;	
		textLabel.x = backing.x + backing.width / 2 - textLabel.width / 2;
		
		
		if (!taken && App.user.calendar[CalendarWindow.year][CalendarWindow.month].indexOf(CalendarWindow.year) >= 0)
			checkmark.visible = true;
		else
			checkmark.visible = false;
		
		if (sid > 0) 
		{
			if (!this.contains(image)) 
			{
				addChild(image);
			}
			
			if (!this.contains(preloader))
				addChild(preloader);
			
			if (!this.contains(checkmark))
				addChild(checkmark);
			
			if (!this.contains(bttnTake))
				addChild(bttnTake);
				
			if (!this.contains(textLabel))
				addChild(textLabel);
				
			textLabel.text = App.data.storage[sid].title;
			
			if (App.data.storage.hasOwnProperty(sid)) 
			{
				if (App.data.storage[sid].type == 'Golden') animate = false;
				var link:String;
				if (animate) 
				{
					link = Config.getSwf(App.data.storage[sid].type, App.data.storage[sid].view);
				}else{
					link = Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].view);
				}
				Load.loading(link, onLoad);
			}
		}
	}
	
	private function onLoad(data:*):void
	{
		if (preloader && contains(preloader)) 
			removeChild(preloader);
		
		if (image.numChildren > 0) 
		{
			while (image.numChildren > 0)
			{
				var child:* = image.getChildAt(0);
				if (child is Anime) child.stopAnimation();
				image.removeChild(child);
			}
		}
		
		var bitmap:Bitmap;
		
		if (data is Bitmap) 
		{
			bitmap = new Bitmap(data.bitmapData, 'auto', true);
			image.addChild(bitmap);
			image.x = (backing.width - image.width) / 2;
			image.y = (backing.height - image.height) / 2;
		}else if (data.sprites) 
		{
			var rect:Object = {x:0,ex:0,y:0,ey:0,scale:1};
			
			bitmap = new Bitmap(data.sprites[data.sprites.length - 1].bmp, 'auto', true);
			bitmap.x = data.sprites[data.sprites.length - 1].dx;
			bitmap.y = data.sprites[data.sprites.length - 1].dy;
			image.addChild(bitmap);
			
			var framesType:String = data.view;
			for (framesType in data.animation.animations) break;
			
			for (var s:* in data.animation.animations[framesType].frames)
			{
				var obj:Object = data.animation.animations[framesType].frames[s];
				if (rect.x > obj.ox) rect.x = obj.ox;
				if (rect.y > obj.oy) rect.y = obj.oy;
				if (rect.ex < obj.ox + obj.bmd.width) rect.ex = obj.ox + obj.bmd.width;
				if (rect.ey < obj.oy + obj.bmd.height) rect.ey = obj.oy + obj.bmd.height;
			}
			
			if (rect.x > bitmap.x) rect.x = bitmap.x;
			if (rect.y > bitmap.y) rect.y = bitmap.y;
			if (rect.ex < bitmap.x + bitmap.width) rect.ex = bitmap.x + bitmap.width;
			if (rect.ey < bitmap.y + bitmap.height) rect.ey = bitmap.y + bitmap.height;
			
			var anime:Anime = new Anime(data, framesType, data.animation.ax, data.animation.ay);
			image.addChild(anime);
			anime.startAnimation();
			
			if ((backing.width - 20) / (rect.ex - rect.x) < rect.scale) rect.scale = (backing.width - 20) / (rect.ex - rect.x);
			if ((backing.height - 70) / (rect.ey - rect.y) < rect.scale) rect.scale = (backing.height - 70) / (rect.ey - rect.y);
			image.scaleY = image.scaleX = rect.scale;
			image.x = (backing.width - image.width) / 2 - rect.x * rect.scale - data.animation.ax * 2 * rect.scale;
			image.y = (backing.height - image.height) / 2 - rect.y * rect.scale - 10;
		}
		
	}
	
	public function onTake(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		e.currentTarget.mode = Button.DISABLED;
		
		App.ui.upPanel.calendarBttn.hideGlowing();
		
		Post.send( {
			uID:	App.user.id,
			ctr:	'Calendar',
			act:	'reward',
			m:		CalendarWindow.month,
			y:		CalendarWindow.year
		}, function(error:int, data:Object, params:Object):void {
			if (error) return;			
			App.user.stock.addAll(data.bonus);
			take(data.bonus);
			App.user.calendar[CalendarWindow.year][CalendarWindow.month] = [CalendarWindow.year];
			bttnTake.visible = false;
			checkmark.visible = true;			
			windowUpdate();
		}, {});
	}
	
	private function windowUpdate():void
	{
		window.update(true);
	}
	
	private function take(items:Object):void
	{
		for (var i:String in items) 
		{
			var item:BonusItem = new BonusItem(uint(i), items[i]);
			var point:Point = Window.localToGlobal(bttnTake);
			item.cashMove(point, App.self.windowContainer);
		}
	}
	
	public function dispose():void 
	{
		if (bttnTake)
			bttnTake.removeEventListener(MouseEvent.CLICK, onTake);
		
		while (image.numChildren > 0) {
			var child:* = image.getChildAt(0);
			if (child is Anime) child.stopAnimation();
			image.removeChild(child);
		}
	}
}