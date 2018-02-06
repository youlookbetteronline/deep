package units 
{
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.Hints;
	import ui.UnitIcon;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import wins.Window;
	
	public class Ganimal extends WorkerUnit
	{
		public static var animals:Vector.<Ganimal> = new Vector.<Ganimal>;
		
		public var feeds:int = 0;
		public var animal:int = 0;
		public var started:uint = 0;
		public var hasProduct:Boolean = false;
		public var walkable:Boolean = true;
		public var superBlock:Boolean = false;
		
		private var contLight:LayerX;
		private var requestBlock:Boolean = false;
		private var nextFeedLevel:int;
		private var readyToPair:Boolean = false;
		private var radius:int;
		private var crafted:int;
		private var whoCanIHaveSexWith:Array;
		private var partner:Object;
		private var isMoving:Boolean = false;
		
		public function Ganimal(object:Object)
		{
			started = object.started || 0;
			feeds = object.feeds || 0;
			animal = object.animal || 1;
			object['area'] = { w:1, h:1 }; 
			
			super(object);
			
			if (object.hasOwnProperty('searchForPair') && object.searchForPair) 
			{
				readyToPair = true;
				App.self.setOnTimer(checkForPartner);
			}
			
			if (object.hasOwnProperty('crafted') && object.crafted > 0) 
			{
				crafted = object.crafted;
			}
			
			cells = rows = 1;
			radius = info.searchRad;
			
			takeable = false;
			moveable = true;
			removable = false;
			multiple = false;
			
			if (started > 0) 
			{
				if (started > App.time) 
				{
					App.self.setOnTimer(work);
				}else {
					hasProduct = true;
					walkable = false;
				}
			}
			
			if (readyToPair && animal != 3)
			{
				walkable = true;
			}
			
			if (started == 0 || started <= App.time)
				showIcon();
			
			tip = function():Object 
			{
				var stage:int = 0;
				
				for (var st:* in info.devel.req) 
				{
					stage++;
				}
				
				if (readyToPair) 
				{
					if (animal == 3) 
					{
						if (App.time > crafted) 
						{
							return {
								title:info.title,
								text:Locale.__e('flash:1488369161351')//Кролики готовы дать потомство!
							}
						}else 
						{
							return {
								title:info.title,
								timer:true,
								text:Locale.__e('flash:1488369221519') + ' ' + TimeConverter.timeToStr(crafted - App.time)//Кролики заняты. Закончат через:
							}
						}
					}else 
					{
						return {
							title:info.title,
							text:Locale.__e('flash:1487345568127')//Кролик влюбился!
						}
					}
				}
				
				if (started != 0)
				{
					if (started > App.time) 
					{
						return {
							title:info.title,
							text:Locale.__e('flash:1487669237176', [String(animal), String(stage - 1)]) + "\n" + Locale.__e('flash:1487345419880', [TimeConverter.timeToStr(started - App.time)] + "\n" + Locale.__e("flash:1403797940774", [String(leftFeedsOnStage)])),//Животное на %s стадии из %s  Созреет через %s  Осталось кормлений: %s
							timer:true
						}
					}else {
						return {
							title:info.title,
							text:Locale.__e('flash:1487345520908')//Материал готов
						}
					}
				}	
				
				for (var out_sID:* in info.devel.rew[animal]) break;
				
				return {
					title:info.title,
					text:Locale.__e('flash:1487669237176', [String(animal), String(stage - 1)]) + "\n" + Locale.__e('flash:1382952380034') +' '+App.data.storage[out_sID].title + "\n" + Locale.__e("flash:1403797940774", [String(leftFeedsOnStage)])
				}
			}
			
			/*graphics.beginFill(0xff0000, 0.5);
			graphics.drawCircle(0,0,200)*/
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			if (Map.ready && ( started > 0  || (readyToPair && animal != 3)))
				goHome();//После перезагрузки, если условия выполнены
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			//App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			
			shortcutDistance = 50;
			homeRadius = radius;
			
			if (formed)
				animals.push(this);
			
			whoCanIHaveSexWith = [];
			
			for (var s:* in info.selection)//Собираем массив сидов тех, с кем можно спариваться
			{
				var obj:Object = info.selection[s];
				whoCanIHaveSexWith.push(obj.partner);
			}
			
			if (crafted > 0 && App.time < crafted) 
			{
				App.self.setOnTimer(doThisWhenLoveWillBeOver);
			}
		}
		
		override public function load():void
		{
			var view:String = info.view;
			
			try {
				view = info.devel.req[animal].v;
			}catch(e:*) {}
			
			if (preloader) addChild(preloader);
			
			if (textures && animated) 
			{
				stopAnimation(); 
				textures = null;
			}
			
			Load.loading(Config.getSwf(info.type, view), onLoad);
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			bounds = null;
			iconSetPosition();
			//id visible width height alpha
		}
		
		override public function set move(move:Boolean):void 
		{
			super.move = move;
			
			if (move)
			{
				stopWalking();
				framesType = STOP;
				isMoving = true;
			}else 
			{
				isMoving = false;
				previousPlace();
			}
		}
		
		override public function previousPlace():void 
		{
			super.previousPlace();
			
			if (contLight) 
			{
				removeChild(contLight);
				contLight = null;
			}
		}
		
		override public function spit(callback:Function = null, target:* = null):void 
		{
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			
			if (contLight) 
			{
				removeChild(contLight);
				contLight = null;
			}
			
			this.cell = coords.x;
			this.row = coords.z;
			this.id = data.id;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			showIcon();
		}
		
		override public function moveAction():void 
		{
			if (Cursor.prevType == "rotate") Cursor.type = Cursor.prevType;
			
			if (!visible) return;
 			
			Post.send( {
				ctr:this.type,
				act:'move',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id,
				x:coords.x,
				z:coords.z,
				rotate:int(rotate)
			}, onMoveAction);
		}
		
		override public function onMoveAction(error:int, data:Object, params:Object):void
		{
			if (contLight) 
			{
				removeChild(contLight);
				contLight = null;
			}
			
			if (error) 
			{
				Errors.show(error, data);
				
				free();
				_move = false;
				placing(prevCoords.x, prevCoords.y, prevCoords.z);
				take();
				state = DEFAULT;
				return;
			}
			
			this.cell = coords.x;
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			walkable = true;
			
			if ( started > 0  || (readyToPair && animal != 3))
				goHome();//После того как передвинули
		}
		
		override public function take():void 
		{
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			
			showIcon();
			moveable = true;
			fromStock = false;
			
			this.cell = coords.x;
			this.row = coords.z;
			movePoint.x = coords.x;
			movePoint.y = coords.z;
		}
		
		private function onMapComplete(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			if (started > 0 || (readyToPair && animal != 3))
				goHome();//После перезагрузки, если первый раз карта была не готова
		}
		
		override public function onGoHomeComplete():void 
		{
			stopRest();
			
			if (started > 0 || (readyToPair && animal != 3))
			{
				var time:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, time);
			}
		}
		
		override public function stopRest():void 
		{
			framesType = Personage.STOP;
			
			if (timer > 0)
				clearTimeout(timer);
		}
		
		override public function uninstall():void 
		{
			App.self.setOffTimer(work);
			
			if (animals.indexOf(this) != -1)
				animals.splice(index, 1);
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			
			super.uninstall();
			clearIcon();
		}
		
		override public function click():Boolean
		{
			if (readyToPair)
			{
				if (animal == 3 && App.time >= crafted) 
				{
					getResult();
				}
				
				return true;
			}
			
			if (App.user.mode == User.GUEST) 
			{
				return true;
			}
			
			if (hasProduct) 
			{
				storageEvent();
				return true;
			}
			
			showIcon();
			
			if (started == 0)
				feedEvent();
			
			return true;
		}
		
		public function startWork():void 
		{
			clearIcon();
			App.self.setOnTimer(work);
		}
		
		public function feedEvent(value:int = 0):void 
		{
			if (requestBlock) return;
			if (!formed) return;
			
			for (var foodID:* in food) break;
			
			if (!App.user.stock.check(foodID, food[foodID]))
			{
				new PurchaseWindow( {
					width:382,
					itemsOnPage:2,
					content:PurchaseWindow.createContent("Energy", { inguest:0, view:'Feed'} ),
					find:foodID,
					closeAfterBuy:false,
					autoClose:false,
					title:Locale.__e("flash:1396606700679"),
					shortWindow:true,
					description:Locale.__e("flash:1382952379757"),
					callback:function(sID:int):void {}
				}).show();
				return;
			}
			
			requestBlock = true;
			
			var point:Point = new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y);			
			Hints.minus(foodID, food[foodID], point);
			
			App.ui.flashGlowing(this, 0x83c42a);
			flyMaterial(foodID);
			clearIcon();
			
			Post.send({
				ctr:this.type,
				act:'feed',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, function(error:int, data:Object, params:Object):void {
				
				requestBlock = false;
				
				if (error) 
				{
					Errors.show(error, data);
					return;
				}
				
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_STOCK));
				
				App.user.stock.takeAll(food);
				
				started = data.started;
				feeds = data.feed;
				walkable = true;
				App.self.setOnTimer(work);
				setRest();
				setTimeout(goHome, 5000);//После кормежки
			});
		}
		
		override public function setRest():void 
		{
			if (App.user.quests.tutorial) 
			{
				framesType = STOP;
				return;
			}
			
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			restCount = generateRestCount();
			framesType = randomRest;
			startSound(randomRest);
		}
		
		override public function goHome(_movePoint:Object = null):void
		{
			clearTimeout(timer);
			if (!walkable) return;
			if (animal == 3) return;
			
			if (_framesType != Personage.STOP && _framesType != 'work') 
			{
				var newtime:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, newtime);
				return;
			}
			
			if (isRemove)
				return;
			
			if (move) 
			{
				var time:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, time);
				return;
			}
			
			if (workStatus == BUSY)
				return;
			
			var place:Object;
			
			if (_movePoint != null) 
			{
				place = _movePoint;
			}else {
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:this.movePoint.x, z:this.movePoint.y}}, homeRadius);
			}
			
			framesType = Personage.WALK;
			
			initMove(
				place.x,
				place.z,
				onGoHomeComplete
			);
		}
		
		private function flyMaterial(sid:int):void
		{
			var item:BonusItem = new BonusItem(sid, 0);
			var point:Point = Window.localToGlobal(App.ui.bottomPanel.bttnMainStock);
			var moveTo:Point = new Point(App.self.mouseX, App.self.mouseY);
			item.fromStock(point, moveTo, App.self.tipsContainer);
		}
		
		private function work():void 
		{
			if (App.user.mode == User.GUEST) return;
			
			if (App.time > started) 
			{
				App.self.setOffTimer(work);
				hasProduct = true;
				walkable = false;
				showIcon();
			}
		}
		
		public function onBoostEvent(count:int = 1):void 
		{
			if (!App.user.stock.take(Stock.FANT, count)) return;
			
			var that:Ganimal = this;
			clearIcon();
			
			Post.send({
				ctr:this.type,
				act:'boost',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, function(error:*, data:*, params:*):void {
				
				if (error) 
				{
					Errors.show(error, data);
					return;
				}
				
				if (!error && data) 
				{
					App.ui.flashGlowing(that);
					started = data.started;
					hasProduct = true;
				}
				
				SoundsManager.instance.playSFX('bonusBoost');
			});
		}
		
		private function storageEvent(value:int = 0):void 
		{
			if (App.user.mode == User.GUEST) return;
			clearIcon();
			
			nextFeedLevel = feeds + 1;
			
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onStorageEvent, {result:result});
		}
		
		private function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			
			var develsQuantity:int = Numbers.countProps(info.devel.req);//Сколько уровней улучшений у животного
			var thisDevelFeedsMax:int = info.devel.req[data.level].c;//Максимальное кол-во кормлений на текущем уровне улучшения
			
			if (data.level == develsQuantity - 1 && data.feed == thisDevelFeedsMax)//Животное умерло девственником
			{
				uninstall();
				clearIcon();
				return;
			}
			
			hasProduct = false;
			started = 0;
			
			if (data['level']) 
			{
				var nextLevel:Boolean = false;
				
				if (data.level > animal) 
				{
					nextLevel = true;
					feeds = 0;
				}else {
					feeds = data.feed;
				}
				animal = data.level;
				if (nextLevel) load();
			}	
			
			if (data.searchForPair) 
			{
				readyToPair = true;
				App.self.setOnTimer(checkForPartner);
				walkable = true;
				App.self.setOffEnterFrame(walk);
				_framesType = Personage.STOP;
				
				setTimeout(function():void {
					App.self.setOnEnterFrame(walk);
					goHome();
				}, 5000);//После того как стали половозрелыми
			}else 
			{
				stopWalking();
				onGoHomeComplete();
				clearTimeout(timer);
			}
			
			if (animal >= Numbers.countProps(info.devel.req) && feeds >= info.devel.req[animal].c && nextFeedLevel > feeds) 
			{
				var that:* = this;
				
				TweenLite.to(this, 1, { alpha:0, onComplete:function():void 
				{
					removable = true;
					uninstall();
				}});
			} else {
				showIcon();
			}
			
			if (data['bonus']) 
			{
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
			}
			
			Treasures.bonus(Treasures.convert(params.result), new Point(this.x, this.y));
		}
		
		private function checkForPartner(e:* = null):void 
		{	
			if (partner && partner.hasOwnProperty('id') || animal == 3 || isMoving) //Дополнительная защита
			{
				return;
			}
			
			var possiblePartners:Array = Map.findUnitsByType(['Ganimal']);//Находим на карте все объекты с типом Ganimal	
			
			for (var i:int = possiblePartners.length - 1; i > -1; i--)
			{
				if (possiblePartners[i].id == id // Удаляем себя
					|| !possiblePartners[i].readyToPair //Удаляем из массива себя и зверей, которые не готовы к случке 
					|| whoCanIHaveSexWith.indexOf(possiblePartners[i].sid) == -1 //Удаляем животных, с которыми мы не совместимы
					|| possiblePartners[i].partner // Удаляем занятых партнеров
					|| possiblePartners[i].isMoving
					|| possiblePartners[i].animal == 3
					|| !(coords.x - radius <= possiblePartners[i].coords.x && possiblePartners[i].coords.x <= coords.x + radius) // Удаляем тех, кто не в радиусе
					|| !(coords.z - radius <= possiblePartners[i].coords.z && possiblePartners[i].coords.z <= coords.z + radius)) // Удаляем тех, кто не в радиусе
				{
					possiblePartners.splice(i, 1);
				}
			}
			
			if (possiblePartners.length) 
			{
				possiblePartners[0].stopCheckForPartner(id); // Убираем поиск партнера з цели
				partner = { id: possiblePartners[0].id } // Убираем нас з возможных целей
				
				framesType = Personage.WALK;
				
				initMove(
					possiblePartners[0].coords.x,
					possiblePartners[0].coords.z,
					function ():void {
						doFuck(possiblePartners[0]);
						possiblePartners[0].clearIcon();
					}
				);
				
				App.self.setOffTimer(checkForPartner);
			}
		}
		
		public function stopCheckForPartner(pid:* = 0):void
		{
			App.self.setOffTimer(checkForPartner);
			partner = { id: pid };
			walkable = false;
			App.self.setOffEnterFrame(walk);
			framesType = Personage.STOP;
		}
		
		public function doFuck(partnerToRemove:* = null):void
		{
			framesType = Personage.STOP;//Останавливаем главного, чтоб пока не прришел ответ от сервера он не шел на месте
			Cursor.type = "default";
			
			if (superBlock) return;
			superBlock = true;//Защита от повторного поста getpair
			
			var that:* = this;
			
			Post.send( {
				ctr:		'Ganimal',
				act:		'getpair',
				id:			that.id,
				pairID:		partnerToRemove.id,
				pairSID:	partnerToRemove.sid,
				sID:		this.sid,
				uID:		App.user.id,
				wID:		App.user.worldID
			}, function(error:int, data:Object, params:Object):void {
				
				superBlock = false;
				if (error) 
				{
					return; 
				}
				
				clearIcon();
				
				TweenLite.to(partnerToRemove, 1, { x:partnerToRemove.x, y:partnerToRemove.y, alpha: 0, onComplete:function():void {					
					partnerToRemove.visible = false;
					partnerToRemove.uninstall();
				}});//Уходит в альфу партнер
				
				
				TweenLite.to(that, 1, { x:that.x, y:that.y, alpha: 0, onComplete:function():void {
					crafted = data.crafted;
					animal++;
					load();
					App.self.setOnTimer(doThisWhenLoveWillBeOver);
					TweenLite.to(that, 1, { x:that.x, y:that.y, alpha: 1 } );//Приходит из альфы пара	
				}});//Уходит в альфу главный
			});
		}
		
		private function doThisWhenLoveWillBeOver():void 
		{
			if (App.time >= crafted) 
			{
				showIcon();
				App.self.setOffTimer(doThisWhenLoveWillBeOver)
			}
		}
		
		override public function onRemoveFromStage(e:Event):void 
		{
			clearTimeout(timer);
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);	
			super.onRemoveFromStage(e);
		}
		
		override public function checkOnSplice(start:*, finish:*):Boolean 
		{
			return false;
		}
		
		public function getResult():void 
		{
			Post.send( {
				ctr:		'Ganimal',
				act:		'getresult',
				id:			this.id,
				sID:		this.sid,
				uID:		App.user.id,
				wID:		App.user.worldID
			}, function(error:int, data:Object, params:Object):void {
				if (error) 
				{
					return; 
				}
				
				Treasures.bonus(data.reward, new Point(x, y));
				uninstall();
			});
		}
		
		public function showIcon():void 
		{
			if (App.user.mode == User.OWNER) 
			{	
				if (animal == 3 && App.time < crafted)//Во время спаривания клауд не нужен
				{
					return;
				}
				
				if (animal == 3 && App.time > crafted)//После спаривания рисуем клауд для сбора финальной награды
				{
					drawIcon(UnitIcon.ANIMAL, result, 0, {onClick:getResult});
					return;
				}
				
				if (readyToPair == true)//Когда стали готовы к спариванию рисуем соответствующий клауд
				{
					drawIcon(UnitIcon.ANIMAL, null, 0, {});
					return;
				}
				
				if (started > 0 && started > App.time)//Тут условия для состояний до половой зрелости
				{
					if (App.user.quests.tutorial) 
					{
						icon.hideGlowing();
						clearIcon();
						return;
					}
					
					drawIcon(UnitIcon.PROGRESS, null, 0, {//Прогресс-бар и кнопка ускорить
						clickable:		false,
						boostPrice:		boostPrice,
						onClick:		this.onBoostEvent,
						progressBegin:	started - duration,
						progressEnd:	started,
						hidden:			true,
						bttnCaption:	Locale.__e('flash:1382952380104')//Ускорить
					});
				} else if (started < App.time && hasProduct) 
				{
					drawIcon(UnitIcon.REWARD, result, 0, {//Можно собрать материал, выдающийся после кормления
						iconScale:  	0.7,
						multiclick:		true,
						iconDY:			-10,
						iconDX:			-35
					});
				} else {
					var foodSID:int = Numbers.firstProp(food).key;
					var foodQTY:int = Numbers.firstProp(food).val;
					
					drawIcon(UnitIcon.MATERIAL, foodSID, foodQTY, {//Клауд с битмапкой того, чем кормим
						onClick:		feedEvent,
						iconScale:		0.7,
						stocklisten:	true,
						disableText:	true,
						multiclick:		true
					});
				}
			}
		}
		
		private function onChangeStock(e:AppEvent):void 
		{
			showIcon();
		}
		
		public function get leftFeedsOnStage():int 
		{
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('req') && info.devel.req.hasOwnProperty(animal)) 
			{
				return info.devel.req[animal].c - feeds;
			}
			
			return 0;
		}
		
		public function get food():Object 
		{
			return info.devel.obj[animal];
		}
		
		public function get producting():Boolean 
		{
			if (started > App.time) return true;
			return false;
		}
		
		public function get result():Object 
		{
			return info.devel.rew[animal];
		}
		
		public function get boostPrice():int 
		{
			return info.devel.req[animal].f;
		}
		
		public function get duration():int 
		{
			return info.devel.req[animal].t;
		}
		
		public function get maxState():uint 
		{
			var st:uint = 1;
			while (App.data.storage[sid].devel.rew.hasOwnProperty(st))
				st++;
			return st-1;
		}
	}
}