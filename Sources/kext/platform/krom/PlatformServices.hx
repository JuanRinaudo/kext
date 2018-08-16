package kext.platform.krom;

import kext.platform.IPlatformServices;
import kext.platform.html5.GApi;

import js.Browser;
import js.html.Element;

class PlatformServices implements IPlatformServices {

	public var serviceInited:Bool;
	public var isSignedIn(get, null):Bool;

	public var auth2:Dynamic;

	private var loggingButton:Element;

	private var initCallback:GApiCallback;
	private var signInCallback:ServiceResponse;

	public function new() {
		serviceInited = true;
		auth2 = null;
	}

	public function init(initCallback:GApiCallback) {
		this.initCallback(null);
	}

	public function authenticate(config:PlatformConfig, signInCallback:ServiceResponse) {

	}

	private function onSignedIn(response:Dynamic) {
		
	}

	private function getPlayerScores(id:String, timeSpan:String, callback:ServiceResponse) {
		
	}

	public inline function getPlayerScoreAll(id:String, callback:ScoreListResponse) {
		
	}

	public inline function getPlayerScoreAllTime(id:String, callback:ScoreListResponse) {
		
	}

	public inline function getPlayerScoreWeekly(id:String, callback:ScoreListResponse) {
		
	}

	public inline function getPlayerScoreDaily(id:String, callback:ScoreListResponse) {
		
	}

	private function getLeaderboardScores(id:String, collection:String, timeSpan:String, callback:ScoreListResponse) {
		
	}

	private inline function parsePlayerScore(entry:LeaderboardEntry) {
		
	}

	private function parseLeaderboard(response:LeaderboardGetResponse , callback:ScoreListResponse) {
		
	}

	public inline function getAllTimePublicScores(id:String, callback:ScoreListResponse) {
		
	}

	public inline function getWeeklyPublicScores(id:String, callback:ScoreListResponse) {
		
	}
	
	public inline function getDailyPublicScores(id:String, callback:ScoreListResponse) {
		
	}

	public inline function getAllTimeSocialScores(id:String, callback:ScoreListResponse) {
		
	}
	
	public inline function getWeeklySocialScores(id:String, callback:ScoreListResponse) {
		
	}
	
	public inline function getDailySocialScores(id:String, callback:ScoreListResponse) {
		
	}

	public function submitScore(id:String, value:Dynamic, callback:ScoreListResponse) {
		
	}

	public function get_isSignedIn():Bool {
		return false;
	}

}