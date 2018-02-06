package utils 
{
	import flash.geom.Point;
	import ui.EventsManager;
	import units.FakeHero;
	import units.Monster;
	import units.Personage;
	import units.Publicbox;
	import units.Resource;
	import units.Unit;
	import wins.SimpleRewardWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class SocketEventsHandler 
	{
		
		public function SocketEventsHandler() 
		{
		}
		
		public static var personages:Object = new Object();
		public static var objects:Object = {'resources':{}};
		
		
		public static function handleEvent(uid:String,obj:Object):void
		{
			if (uid == App.user.id)
				return;
				
			if (obj.hasOwnProperty('u_event'))
			{
				switch(obj['u_event']){
					case'hero_move':
						if(personages.hasOwnProperty(uid)){
							personages[uid].initMove(obj.params.coords.x, obj.params.coords.z, personages[uid].onStop);
							/*EventsManager.addEvent( {
								ctr			:'move',
								act			:'hero',
								titleText	:obj.aka,
								uID			:uid,
								text		:('x: ' + obj.params.coords.x + ' z: ' + obj.params.coords.z)
							});*/
						}else{
							Connection.sendMessage({u_event:'get_hero', uID:uid});
						}
						break;
					case'hero_say':
						if (personages.hasOwnProperty(uid)){
							if(obj.text != ""){
								personages[uid].saySomething(0xfffef4, 0x123b65, obj.text);
								EventsManager.addEvent( {
									ctr			:'say',
									act			:'hero',
									titleText	:obj.aka,
									uID			:uid,
									text		:obj.text
								});
							}
						}else{
							Connection.sendMessage({u_event:'get_hero', uID:uid});
						}
						break;
					case'hero_load':
						var isCreate:Boolean = false;
						if (SocketEventsHandler.personages.hasOwnProperty(String(uid)))
							isCreate = true;
						if(Map.ready){
							SocketActions.createFakeHero(String(uid), obj);
						}
						if(!isCreate){
							EventsManager.addEvent( {
								ctr			:'simple',
								act			:'hero',
								titleText	:obj.aka,
								uID			:uid,
								text		:Locale.__e('flash:1503069286642')
							});	
						}
						break;
						
					case'hero_leave':
						EventsManager.addEvent( {
							ctr			:'simple',
							act			:'hero',
							titleText	:obj.aka,
							uID			:uid,
							text		:Locale.__e('flash:1503069343042')
						});
						
						SocketActions.clearUserResources(String(uid));
						
						if (personages.hasOwnProperty(uid)){
							personages[uid].uninstall();
							delete personages[uid];
						}
						break;
					case'get_hero':
						if (obj.uID == App.user.id)
						{
							var _owner:Object = {
								sex:App.user.sex,
								head:App.user.head,
								body:App.user.body,
								photo:App.user.photo,
								id:App.user.id
							};
							
							var _paramsObject:Object = {
								uID:App.user.id, 
								owner:_owner, 
								coords:{x:App.user.hero.coords.x, z:App.user.hero.coords.z}
							};
							
							if (App.user.hero.tm.queue.length > 0){
								var resTargets:Array = [];
								var tempReses:Array = [];
								for each(var _rs:* in App.user.hero.tm.queue)
								{
									if (tempReses.indexOf(_rs.target) != -1)
										continue;
									resTargets.push({sid:_rs.target.sid, id:_rs.target.id});
									tempReses.push(_rs.target);
								}
								_paramsObject['resources'] = JSON.stringify(resTargets);
							}
							
							if (App.user.hero.fireworkTargets.length > 0){
								var fwTargets:Array = [];
								for each(var _fw:* in App.user.hero.fireworkTargets){
									fwTargets.push({sid:_fw.sid, id:_fw.id, targets:JSON.stringify(_fw.tempUnits)});
								}
								_paramsObject['fireworks'] = JSON.stringify(fwTargets);
							}
							
							Connection.sendMessage({u_event:'hero_load', aka:App.user.aka, params:_paramsObject});
						}
						break;
					case'resource_reserve':
						SocketActions.resourceReserve(String(uid), obj.params.iD, obj.params.sID);
						break;
					case'resource_free':
						SocketActions.resourceFree(String(uid), obj.params.iD, obj.params.sID);
						break;
					case'resources_free':
						SocketActions.clearUserResources(String(uid));
						break;
					case'unit_place':
						var unit:Unit = Unit.add({ sid:obj.params.sID, id:obj.params.iD, x:obj.params.coords.x, z:obj.params.coords.z});
						unit.ownerID = uid;
						//SocketActions.generateDamage(obj.params.units, uid, obj.params.sID, obj.params.iD);
						EventsManager.addEvent( {
							ctr			:'place',
							act			:'hero',
							sID			:obj.params.sID,
							titleText	:obj.aka,
							uID			:uid,
							text		:'Поставил:'
						});
						break;
					case'box_drop':
						var _box:Publicbox = Map.findUnit(obj.params.sID, obj.params.iD);
						if (_box){
							_box.free();
							_box.placing(obj.params.coords.x, 0, obj.params.coords.z);
							_box.rotate = Boolean(obj.params.rotation);
							_box.visible = true;
							_box.take();
						}
						if (Monster.self)
							Monster.self.clearIcon();
						EventsManager.addEvent( {
							ctr			:'place',
							act			:'hero',
							sID			:obj.params.sID,
							titleText	:obj.aka,
							uID			:uid,
							text		:'Отвоевал:'
						});
						break;
					case'firework_reserve':
						SocketActions.reserveFirework(JSON.parse(obj.params.units), uid, obj.params.sID, obj.params.iD);
						
						break;
					case'world_start':
						App.user.data['publicWorlds'][App.owner.worldID] = obj.params.expire;
					
						if (Monster.self){
							Monster.self.settings.endLife = obj.params.expire;
							Monster.self.startWalk();
						}
						EventsManager.addEvent( {
							ctr			:'simple',
							act			:'hero',
							titleText	:obj.aka,
							uID			:uid,
							text		:'Запустил карту'
						});
						break;
					case'firework_boom':
						SocketActions.generateDamage(JSON.parse(obj.params.units), uid, obj.params.sID, obj.params.iD);
						/*EventsManager.addEvent( {
							ctr			:'bonus',
							act			:'hero',
							bonus		:obj.params.bonus,
							titleText	:obj.aka,
							uID			:uid,
							text		:''
						});*/
						break;
					case'resource_kick':
						if (SocketEventsHandler.objects['resources'].hasOwnProperty(obj.params.iD) && 
							SocketEventsHandler.objects['resources'][obj.params.iD] == uid)
						{
							var _res:Resource = Map.findUnit(obj.params.sID, obj.params.iD);
							
							_res.cickOwner = uid;
							_res.capacity = obj.params.capacity;
							if (obj.params.hasOwnProperty('bonus'))
							{
								Treasures.bonus(obj.params.bonus, new Point(_res.x, _res.y), {target:personages[uid]});
							}
							//_res.setCapacity(obj.params.capacity)
							//if (_res.capacity < 1){
								//_res.uninstall();
								//_res.sectorFree();
							//}
								
							EventsManager.addEvent( {
								ctr			:'bonus',
								act			:'hero',
								bonus		:obj.params.bonus,
								titleText	:obj.aka,
								uID			:uid,
								text		:Locale.__e('flash:1503319022152')
							});
						}
						break;
						case 'reward_window_open':
							if (obj.params.bonus.hasOwnProperty(App.user.id))
								obj.params.bonus = Treasures.convert2(obj.params.bonus[App.user.id]);
							App.user.stock.addAll(obj.params.bonus);
							new SimpleRewardWindow({
								bonus:obj.params.bonus
							}).show();
						break;
				}
			}
			
		}
	}

}