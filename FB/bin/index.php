<?php
session_start();

require_once( 'Facebook/HttpClients/FacebookHttpable.php' );
require_once( 'Facebook/HttpClients/FacebookCurl.php' );
require_once( 'Facebook/HttpClients/FacebookCurlHttpClient.php' );

require_once( 'Facebook/Entities/AccessToken.php' );
require_once( 'Facebook/Entities/SignedRequest.php');

require_once( 'Facebook/FacebookSession.php' );
require_once( 'Facebook/FacebookSignedRequestFromInputHelper.php');
require_once( 'Facebook/FacebookCanvasLoginHelper.php');
require_once( 'Facebook/FacebookRedirectLoginHelper.php' );
require_once( 'Facebook/FacebookRequest.php' );
require_once( 'Facebook/FacebookResponse.php' );
require_once( 'Facebook/FacebookSDKException.php' );
require_once( 'Facebook/FacebookRequestException.php' );
require_once( 'Facebook/FacebookOtherException.php' );
require_once( 'Facebook/FacebookAuthorizationException.php' );
require_once( 'Facebook/GraphObject.php' );
require_once( 'Facebook/GraphUser.php');
require_once( 'Facebook/GraphSessionInfo.php' );
 
use Facebook\HttpClients\FacebookHttpable;
use Facebook\HttpClients\FacebookCurl;
use Facebook\HttpClients\FacebookCurlHttpClient;

use Facebook\Entities\AccessToken;
use Facebook\Entities\SignedRequest;

use Facebook\FacebookSession;
use Facebook\FacebookSignedRequestFromInputHelper;
use Facebook\FacebookCanvasLoginHelper;
use Facebook\FacebookRedirectLoginHelper;
use Facebook\FacebookRequest;
use Facebook\FacebookResponse;
use Facebook\FacebookSDKException;
use Facebook\FacebookRequestException;
use Facebook\FacebookOtherException;
use Facebook\FacebookAuthorizationException;
use Facebook\GraphObject;
use Facebook\GraphUser;
use Facebook\GraphSessionInfo;

$app_id = '1568030493462936';
$app_secret = '08ab51005c3032fea0cdf981f1dd8616';
$app_namespace = 'totemgame';

FacebookSession::setDefaultApplication($app_id, $app_secret);
///////////////////
$helper = new FacebookCanvasLoginHelper();
try {
    $session = $helper->getSession();
} catch (FacebookRequestException $ex) {
    echo $ex->getMessage();
} catch (\Exception $ex) {
    echo $ex->getMessage();
}


if($session == null) {
    $helper = new FacebookRedirectLoginHelper('https://apps.facebook.com/'.$app_namespace);
    $auth_url = $helper->getLoginUrl(array('email', 'publish_actions', 'user_friends', 'user_birthday'));
    echo "<script>window.top.location.href='".$auth_url."'</script>";
    die;
}

try {
    $profile = (new FacebookRequest($session, 'GET', '/me', array('fields' => 'id,first_name,last_name,email,birthday,gender,locale,installed,currency,third_party_id')))->execute()->getGraphObject()->asArray();
} catch(FacebookRequestException $e) {
    echo "Exception occured, code: " . $e->getCode();
    echo " with message: " . $e->getMessage();
    die;
}  




exec('php /home/user/public_html/console.php -ctr Broken -act log -uID '.$profile['id']);
$works = false;
$update = false;

function isAdminUid(){
    global $profile;
    return in_array($profile['id'], array(
        '100004640803161',
        '100004697466051',
        '100000053564531',
        '100006810964464',
        '100006542076902',
        '703397600',
        '100007181340615',
        '100000671459128',
		'461152844051294'
    ));
}

if(isAdminUid()){
    $works = false;
    $update = false;
}

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ru" xml:lang="ru">
  <head>
    <title>Небеса Авиора</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link href="style.css?2" rel="stylesheet" media="all">
    
    <script type="text/javascript" src="js/swfobject.js"></script>
    <script src='https://code.jquery.com/jquery-1.7.1.js'></script>
    <script type="text/javascript" src="js/jquery.cookie.js"></script>
    
    <script type="text/javascript">
        if (!window.console) console = {log: function() {}};
    </script>
	
    
    <?php
        $profile['year'] = 0; 
        if(!empty($profile['birthday'])) {
            $info = explode('/', $profile['birthday']);
            $profile['year'] = $info[count($info) - 1];
        } 
        
        $_profile 				= array();
        $_profile['first_name'] = $profile['first_name'];
        $_profile['last_name'] 	= $profile['last_name'];
        $_profile['sex'] 		= (!empty($profile['gender']) && $profile['gender'] == 'male')?'m':'f';
        $_profile['photo'] 		= 'https://graph.facebook.com/'.$profile['id'].'/picture?width=50&height=50';
        $_profile['year']       = $profile['year'];
        $_profile['email']      = isset($profile['email'])?$profile['email']:'';
        
        $_profile 				= json_encode($_profile);
        
        $locale 				= $profile['locale'];
        $lang    				= strstr($locale,'_')===false?strtolower($locale):explode('_',$locale)[0];
        
        $langs = array('ru','en','es','fr','pl','de','nl');
        
        if(!in_array($lang,$langs)){
            $lang = 'en';
        }
        
        if(!empty($_COOKIE['gamelang']) && $_COOKIE['gamelang'] != $lang){
            $lang = $_COOKIE['gamelang'];
        }
        
        $langlist = array(
            'ru'=>'Русский',
            'en'=>'English',
            'es'=>'Español',
            'fr'=>'Français',
            'it'=>'Italiano',
            'pl'=>'Polski',
            'de'=>'Deutsch',
            'nl'=>'Nederlands'
        );
    ?>
    
        
    <script>
        var uid = "<?php echo $profile['id']; ?>";
        var friends = {};
        var appFriends = [];
        var allFriends = [];
        var otherFriends = {};
        var profile = <?php echo $_profile ?>;
        var albums = null;
        var permissions = {};
        var currency = <?php echo empty($profile['currency'])?'null':json_encode($profile['currency'])?>;
                
        function initNetwork(){            
            if(currency == null){
                getUserCurrency(function(){
                    getNetwork();
                });    
            } else {
                getNetwork();
            }
        }
       /*  if(uid == '569680106986'){
				flashvars.game = 'Tribe_test.swf?v=12';
			} */
			
        function getNetwork(){
            getFriends(function(){                 
                var network = {
                    appFriends:appFriends,
                    friends:friends,
                    allFriends:allFriends,
                    otherFriends:otherFriends,
                    profile:profile,
                    albums:albums,
                    currency:currency
                };
                console.log('----------> network');
                console.log(network);
                getGame().initNetwork(network);
            }); 
        }
        
        function getGame() {
            if (navigator.appName.indexOf("Microsoft") != -1) {
                return window["game"];
            } else {
                return document["game"];
            }
        }

        var lang = '<?php echo $lang;?>';
        
        function startGame(){
            
            var flashvars = {
                'viewer_id':uid,
                'social':'FB',
                'group':'',
                'mainIP':encodeURIComponent(JSON.stringify(['t-fb1.islandsville.com', 't-fb2.islandsville.com', 't-fb3.islandsville.com'])),
                'resIP':encodeURIComponent(JSON.stringify(['t-fb1.islandsville.com', 't-fb2.islandsville.com', 't-fb3.islandsville.com'])),
                'game':'Tribe.swf?v=35',
                'preloader':'preloader.swf?v=6',
                'testMode':0,
                'lang':lang,
                'secure'    :location.protocol
            };
            
            <?php if(preg_match('/(viral|bonus|blink|oneoff|mail)([^z]{12,99}+)z/', $_SERVER['QUERY_STRING'].$_SERVER['HTTP_REFERER'], $mm) === 1):
                switch($mm[1]){
                    case "bonus":
                    case "blink": 
                        print 'flashvars["blink"] = "'.$mm[2].'";';
                        break;  
                    default:
                        print 'flashvars["'.$mm[1].'"] = "'.$mm[2].'";'; 
                        break;                  
                }            
            endif;?>
            
                    
            var params = {
                menu: "false",
                scale: "noScale",
                allowFullscreen: "true",
                allowScriptAccess: "always",
                bgcolor: "#bcefff",
                wmode: "direct"
            }; 
            var attributes = {id:"game"};
            swfobject.embedSWF("LOADER.swf","game", "100%", "700", "11.1.0","expressInstall.swf", flashvars, params, attributes);
        }    
        
        $(function(){
           // startGame();
        });
    
    </script>
    
    <style>
        html, body { height:100%; xoverflow:hidden; } 
        body { margin:0; }
    </style>
 

</head>
<?php if($works || $update):
    $image = ($update == true)?'update':'works'; 
?>
<body id='body'>
    <table style="background:#ffffff;" width="100%" height="100%">
        <tr>
            <td align="center">
                <img src="http://fb.islandsville.com/images/<?php echo $image;?>.jpg" alt="Ведуться технические работы" title="Ведуться технические работы" />
            </td>
        </tr>
    </table>
</body>
<?php else:?>
<body id='body'>    
    <div id="fb-root"></div>
    <script>
		function hasPermission(name){
            return (permissions[name] != undefined) && (permissions[name] == 'granted');
        }
	
        window.fbAsyncInit = function() {
			FB.init({
				appId      : '<?php print $app_id?>',
				status     : true,
				xfbml      : true,
				oauth      : true,
				version    : 'v2.3',
				frictionlessRequests : false,
			});
			
			console.log('----------------------- FB.START -----------------------');
			console.log(FB);
			
			
			 
			FB.Canvas.setUrlHandler(function(data){
				console.log('--->');
				console.log(data);
			});
			
			FB.getAccessToken(function(response) {  
				console.log('----------------------- FB.getAccessToken -----------------------');
				if (response.status === 'connected') {
					accessToken = response.authResponse.accessToken;
				}
			});
			
			FB.getLoginStatus(function(response) {   
				console.log('----------------------- FB.getLoginStatus -----------------------');
				checkLike();              
				if (response.status === 'connected') {
					var uid = response.authResponse.userID;
					accessToken = response.authResponse.accessToken;
					
					FB.api("/me/permissions",function (response) {
						console.log('permissions');
						for(var i in response.data){
							console.log(i);
							console.log(response.data[i]);
						}
						if(response.data != undefined && response.data.length > 0){
							for(var i in response.data){
								permissions[response.data[i].permission] = response.data[i].status;
							}
						}
						
						if(!hasPermission('user_friends')){
							FB.login(function(response){
								console.log('FB.login');
								console.log(response);
								if (response.authResponse) {
									location.reload();
								} 
							}, {scope: 'email, publish_actions, user_friends', auth_type: 'rerequest'});	
						}else{
							startGame();
						}
					});
					
				} else {
					FB.login(function(){}, {scope: 'email, publish_actions, user_friends'});	
				}
			}, true); 
			
         
            FB.Event.subscribe('auth.login', function(response) {
              console.log('----------------------- auth.login -----------------------');
            });
            FB.Event.subscribe('auth.logout', function(response) {
              window.location.reload();
            });
            
            FB.Event.subscribe('edge.create', checkLike);  
			
			FB.AppEvents.activateApp();
		};
		
		function checkParams(params, fields){
			for(var i=0; i < fields.length; i++){
				if(params[fields[i]] == undefined){
					return false;
				}
			}
			return true;
		}
		
		function logEvent(eventname, value, data){
			var event = null;
			var params = {};
			switch(eventname){
				case 'ACHIEVED_LEVEL':
					if(!checkParams(data,['Level']))
						break;
					params[FB.AppEvents.ParameterNames.LEVEL] = data.Level;
					event = FB.AppEvents.EventNames.ACHIEVED_LEVEL;
					break;
				case 'ADDED_TO_WISHLIST':
					if(!checkParams(data,['ContentType','ContentID']))
						break;
					params[FB.AppEvents.ParameterNames.CONTENT_TYPE] = data.ContentType;
					params[FB.AppEvents.ParameterNames.CONTENT_ID] = data.ContentID;
					event = FB.AppEvents.EventNames.ADDED_TO_WISHLIST;
					break;
				case 'COMPLETED_TUTORIAL':
					if(!checkParams(data,['Success','ContentID']))
						break;
					params[FB.AppEvents.ParameterNames.SUCCESS] = data.Success;
					params[FB.AppEvents.ParameterNames.CONTENT_ID] = data.ContentID;
					event = FB.AppEvents.EventNames.COMPLETED_TUTORIAL;
					break;
					
				case 'SPENT_CREDITS':
					if(!checkParams(data,['ContentType','ContentID']))
						break;
					params[FB.AppEvents.ParameterNames.CONTENT_TYPE] = data.ContentType;
					params[FB.AppEvents.ParameterNames.CONTENT_ID] = data.ContentID;
					event = FB.AppEvents.EventNames.SPENT_CREDITS;
					break;
				default: break;
			}
			
			console.log([event,value,params]);
			FB.AppEvents.logEvent(
				event,
				value,
				params
			);
			
		}

		(function(d, s, id){
			var js, fjs = d.getElementsByTagName(s)[0];
			if (d.getElementById(id)) {return;}
			js = d.createElement(s); js.id = id;
			js.src = "//connect.facebook.net/en_US/sdk.js";
			fjs.parentNode.insertBefore(js, fjs);
		}(document, 'script', 'facebook-jssdk'));
	
       function checkLike() {
            FB.api('/gametotemcommunity', function(res){
                console.log(res.id+"---------");
                if( res.id != "undefined" ){
                    FB.api('/me/likes/'+res.id, function(response){
                        // response.data is an array of length 1 if user liked the page
                        console.log(response);
                        if(response.data.length == 1) {
                            // hide the like button
                            $("#likediv").css("display","none");
                        }else{
                            $("#likediv").css("display","block");
                        }
                    });
                }
            });
        } 
       

       function getFriends(callback){
           
		   FB.api("/me/invitable_friends", {'limit':1000}, function (response) {
			  console.log('GET INVITABLE FRIENDS:');
			  console.log(response);
			  if (response && !response.error) {
				/* handle the result */
				for(var i in response.data){
					var friend = response.data[i];
					
					otherFriends[friend.id] = {
						'gender':'m',
						'photo':friend.picture.data.url,
						'first_name':friend.name,
						'last_name':''
					}
				}
				console.log('otherFriends');
				console.log(otherFriends);
			  }
			
			   FB.api("/me/friends",  { fields: 'id,first_name,last_name,gender', 'limit':1000 }, function(response) {
					console.log('GET FRIENDS:');
					console.log(response);
					if (!response || response.error) {
						//getFriends(callback);
					} else {
						
						for(var id in response['data']){
							var friend = response['data'][id];
							friend['gender']	= (friend['gender'] || 'male') == 'male' ? 'm':'f';
							friend['photo'] 	= 'https://graph.facebook.com/'+friend['id']+'/picture?width=50&height=50';
							friend['uid'] 		= friend.id;							
							friends[friend.id] = friend;
							appFriends.push(friend.id);
						
							allFriends.push(friend);
						}
						callback();
					}
				});
			  }
			);
       }

  
        function updateTrialpay(obj){
            setTimeout(function(){
                getGame().updateBalance(false);
            },2000);
        }
        
        
        function reset()  {
            location.reload();
        }
        
        function showInviteBox()  {
            var msg = 'Exciting missions are waiting for you in the game "Totem"! Join me!';
            FB.ui({method: 'apprequests', message: msg, exclude_ids: appFriends}, function(data) {
				getGame().onInviteEvent(data);
			});
        }
		
		function notify(uids, msg)  {
            if(typeof uids != 'array'){
				uids = [uids];
			}
			FB.ui({method: 'apprequests', message: msg, to: uids.join(', ')}, function(response) {
				getGame().updateNotify(response);
			});
        }
        
        function gotoNormalScreen() {
            $('#ad').css('display','block');
        }
        
        function gotoFullScreen()  {
            $('#ad').css('display','none');
        }
        
        function purchase(params) {
            
			console.log('params:')
			console.log([params]);
				
            var requestID = hash(13);
            console.log("Constructing Request ID: " + requestID);
            console.log(params);
            var product = '//t-fb2.islandsville.com/app/api/FB/og/'+params.type+'.html';
            console.log(product); 
            FB.ui({
                method:     'pay',
                action:     'purchaseitem',
                product:    product,
                request_id: requestID+'###'+params.id
            },function(data){
                if(data['error_code'] != undefined){
                    console.error(data);
                    return;
                }
                setTimeout(function(){
                    getGame().updateBalance();
                },2000);
            });
        } 
                

        function getUserCurrency(callback) {
            FB.api('/me/?fields=currency', function(data) {
                if (!data || data.error) {
                    getUserCurrency(callback);
                } else {
                    currency = data.currency;
                    if (callback) callback();
                }
            });
        } 
        

        function hash(s){
            var n;
            if (typeof(s) == 'number' && s === parseInt(s, 10)){
                s = Array(s + 1).join('x');
            }
            return s.replace(/x/g, function(){
                var n = Math.round(Math.random() * 61) + 48;
                n = n > 57 ? (n + 7 > 90 ? n + 13 : n + 7) : n;
                return String.fromCharCode(n);
            });
        } 
        
        function wallPost(uid, fid, header, msg, img, data){
            
            var feedParams = {
               name: header,
               link: "https://apps.facebook.com/<?php echo $app_namespace;?>/?ref=feedpost&_vref=user_" + uid,
               picture: img,
               caption: msg,
               to: fid,
               display: "iframe"
            };
                        
            $.post("https://graph.facebook.com/me/feed?access_token="+accessToken, feedParams, function(response) {
                if(response.id){
                    getGame().onWallPostComplete(response.id);
                    console.log("Post feed Successful!");
                }else{
					getGame().onWallPostComplete(false);
                    console.log("Post Failed!");
                }
            }); 
        }

        function openLeads(){

        }
        
        function showTrialpay(){
            $('#earn_crystals').css('display','inline-block');
        }
        
        function getCookie(name){
            if(name == null ||name == ''){
                console.log($.cookie());
                return $.cookie();
            }else{
                console.log($.cookie(name));
                return $.cookie(name);
            }
        }
        
        function setCookie(name, data, expires){
            if(!expires) expires = 1;
            
            var date = new Date();
            date.setTime(date.getTime() + (expires * 24 * 36001000));
            
            $.cookie(name, data, { expires: date});
        }
        
        function removeCookie(name){
            $.removeCookie(name);
        }  

		function og(action, object){
			var params = {};
			params[object] = 'http://t-fb2.islandsville.com/app/api/FB/og/og.php?a='+action+'&o='+object;
			console.log(params);
			FB.api('me/<?php echo $app_namespace;?>:'+action, 'post', params, function(response) {
					console.log(response);
			});
		}

		
    </script>
    
    <style>
        html, body { xheight:100%; xoverflow:hidden; } 
        body { margin:0; min-width:820px;}
        .bar{
            background: url("./images/OnePXRU.png") repeat-x bottom;
            height:50px;
            line-height:50px;
            width: 100%;
        }
        .bar .lc{
            background: url("./images/BorderRU.png") no-repeat left bottom;
            height:50px;
            line-height:50px;
        }

        .bar .rc{
            background: url("./images/Border2RU.png") no-repeat right bottom;
            height:50px;
            line-height:50px;
            text-align:center;
        }

        a.button {
            display:inline-block;
            border:none;
            cursor:pointer;
            vertical-align:top;
            height: 41px;
        }
        #game{height:700px;}

    </style>
	
	<div id="banner" style="position:relative; margin:10px auto; width: 900px;height: 100px;background: linear-gradient(to top, #7a94c4, #8be5e3);border-radius: 5px;-ms-border-radius: 5px;overflow: hidden;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#7a94c4', endColorstr='#8be5e3',GradientType=0);behavior: url('border-radius.php');">
		<img src="//dreams.islandsville.com/banner/images/EnixanLogo.png" style="position: absolute;">
		<div class="" style="width: 748px; position:absolute;right:10px;top:5px;">
            <a href="https://apps.facebook.com/cloudkingdomgame/" target="_blank"><img src="./images/cloud.jpg" alt="" title="" /></a>
		</div>
	</div>
	

    <div style="text-align:center">
        <div id="likediv" style="width:740px;display:inline-block;padding:5px 0;">
            <div class="fb-like" data-href="https://www.facebook.com/gametotemcommunity/" data-width="400" data-height="35" data-colorscheme="light" data-layout="standard" data-action="like" data-show-faces="false" data-send="false"></div>
        </div>
        
    </div>

    <script>
        function setLanguage(lang){
            $.cookie('gamelang', lang);
            history.go(0);
        }
        
        function showGame(){
            $('#page').css('display','none');
        }
        
        function showPage(page){
            $('#page').css('display','block');
            $('#page').attr('src','html/'+page+'.html');
        }
                
        var script = document.createElement("script");
        script.type = "text/javascript";
        script.src = "//s-assets.tp-cdn.com/static3/js/api/payment_overlay.js";
        document.getElementsByTagName("body")[0].appendChild(script);
        
    </script>
        
    <div class="bar" align="center">
		<div class="lc">
			<div class="rc">
                
                <a class="button" href="javascript:showGame();"><img src="./images/Play.png"></a>&nbsp;
                <a href="javascript:;" onclick="showPage('faq'); return false;" target="_blank" class="button"><img src="./images/FAQ.png" /></a>&nbsp;
                <a href="javascript:;" onclick="showInviteBox();" class="button btn3"><img src="./images/Invite.png" /></a>&nbsp;
                <a href="javascript:;" onclick="getGame().openGifts();" class="button btn5"><img src="./images/FreeGifts.png" /></a>&nbsp;
                <a href="javascript:;" onclick="getGame().openBank();" class="button btn1"><img src="./images/AddDiamonds.png" /></a>&nbsp;
                <a href="https://www.facebook.com/gametotemcommunity/" target="_blank" class="button btn6"><img src="./images/FunPage.png" /></a>  
				<select name="lang" onchange="setLanguage(this.value)" style=" margin: 0 0 11px 10px;  padding: 0; vertical-align: bottom;">
					<?php foreach($langlist as $lng=>$name):?>
					<option value="<?php echo $lng;?>" <?php echo ($lng == $lang)?'selected':''?>><?php echo $name;?></option>
					<?php endforeach;?>
				</select>    
			</div>
		</div>
	</div>
    


    <div style="position:relative;">
            
        <div id="game" style="height:700px;">
            <h1></h1>
            <p><a href="http://www.adobe.com/go/getflashplayer">Get Adobe Flash player</a></p>
        </div>
		
		<iframe id="page" style="position:absolute;left:0;top:0;display:none;" src="" width="100%" height="700"></iframe>
    </div>

    <div align="center" class="footer">
        <a target="_blank" href="https://www.facebook.com/gametotemcommunity/">Fan Page</a> | 
        <a target="_blank" href="http://fb.islandsville.com/terms.html">Terms of Service</a> | 
        <a target="_blank" href="http://fb.islandsville.com/privacy.html">Privacy</a> | 
        Facebook ID: <?php echo $profile['id'] ?> | 
        <a target="_blank" href="mailto:totem.enixan@gmail.com">Contact Support</a>
    </div>

</body>
</html>
<?php endif;?>
