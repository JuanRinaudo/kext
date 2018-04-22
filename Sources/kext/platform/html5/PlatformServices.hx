package kext.platform.html5;

import kext.platform.IPlatformServices;
import kext.platform.html5.GApi;

class PlatformServices implements IPlatformServices {

	private var initCallback:GApiCallback;

	public function new() {

	}

	public function init(initCallback:GApiCallback) {
		this.initCallback = initCallback;
		GApi.load("auth2", authLoaded);
	}

	public function authLoaded(response:Dynamic) {
		GApiClient.load("games", "v1", initCallback);
	}

	public function authenticate(signInCallback:GApiCallback) {
		GApiAuth2.init({client_id: "757682925901-i6l2k31hcfve3hj0i9kogb4apt3jt6vc.apps.googleusercontent.com"}).then(function(auth2:Dynamic) {
			trace( "signed in: " + auth2.isSignedIn.get() );
			auth2.isSignedIn.listen(signInCallback);
			var button = js.Browser.document.querySelector('#game');
			button.addEventListener('click', function() {
				auth2.signIn();
			});
		});
	}

	private function getPlayerScores(id:String, timeSpan:String, callback:ServiceResponse) {
		var request = GApiScores.get({leaderboardId: id, playerId: "me", timeSpan: timeSpan});
		request.execute(callback);
	}

	public inline function getAllPlayerScore(id:String, callback:ServiceResponse) {
		getPlayerScores(id, TimeSpan.ALL, callback);
	}

	public inline function getAllTimePlayerScore(id:String, callback:ServiceResponse) {
		getPlayerScores(id, TimeSpan.ALL, callback);
	}

	public inline function getWeeklyPlayerScore(id:String, callback:ServiceResponse) {
		getPlayerScores(id, TimeSpan.WEEKLY, callback);
	}

	public inline function getDailyPlayerScore(id:String, callback:ServiceResponse) {
		getPlayerScores(id, TimeSpan.DAILY, callback);
	}

	private function getLeaderboardScores(id:String, collection:String, timeSpan:String, callback:ServiceResponse) {
		var request = GApiScores.list({leaderboardId: id, collection: collection, timeSpan: timeSpan});
		request.execute(callback);
	}

	public inline function getAllTimePublicScores(id:String, callback:ServiceResponse) {
		getLeaderboardScores(id, Collection.PUBLIC, TimeSpan.ALL_TIME, callback);
	}

	public inline function getWeeklyPublicScores(id:String, callback:ServiceResponse) {
		getLeaderboardScores(id, Collection.PUBLIC, TimeSpan.WEEKLY, callback);
	}
	
	public inline function getDailyPublicScores(id:String, callback:ServiceResponse) {
		getLeaderboardScores(id, Collection.PUBLIC, TimeSpan.DAILY, callback);
	}

	public inline function getAllTimeSocialScores(id:String, callback:ServiceResponse) {
		getLeaderboardScores(id, Collection.SOCIAL, TimeSpan.ALL_TIME, callback);
	}
	
	public inline function getWeeklySocialScores(id:String, callback:ServiceResponse) {
		getLeaderboardScores(id, Collection.SOCIAL, TimeSpan.WEEKLY, callback);
	}
	
	public inline function getDailySocialScores(id:String, callback:ServiceResponse) {
		getLeaderboardScores(id, Collection.SOCIAL, TimeSpan.DAILY, callback);
	}

	public function submitScore(id:String, value:Dynamic, callback:ServiceResponse) {
		var request = GApiScores.submit({leaderboardId: id, score: value});
		request.execute(callback);
	}

}