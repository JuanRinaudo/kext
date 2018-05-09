package kext.platform.android;

import android.app.Activity;
import android.content.Intent;
import android.content.Context;

typedef GoogleServiceCallback = Dynamic -> Void;

@:enum
abstract TimeSpan(String) {
	public static var ALL = "ALL";
	public static var ALL_TIME = "ALL_TIME";
	public static var DAILY = "DAILY";
	public static var WEEKLY = "WEEKLY";
}

@:enum
abstract Collection(String) {
	public static var PUBLIC = "PUBLIC";
	public static var SOCIAL = "SOCIAL";
	public static var SOCIAL_1P = "SOCIAL_1P";
}

typedef Fragment = Dynamic;
typedef Executor = Dynamic;
typedef Exception = Dynamic;
typedef Scope = Dynamic;
typedef Account = Dynamic;
typedef Uri = Dynamic;
typedef Parcel = Dynamic;
typedef Object = Dynamic;

@:native("com.google.android.gms.tasks.OnCanceledListener") extern class OnCanceledListener<T> {
	public function new();
	public function onCanceled():Void;
}
@:native("com.google.android.gms.tasks.OnCompleteListener") extern class OnCompleteListener<T> {
	public function new();
	public function onComplete(task:Task<T>):Void;
}
@:native("com.google.android.gms.tasks.OnFailureListener") extern class OnFailureListener<T> {
	
}
@:native("com.google.android.gms.tasks.OnSuccessListener") extern class OnSuccessListener<T> {
	
}

@:native("com.google.android.gms.tasks.Task") extern class Task<T> {
	public function new();
	@:overload public function addOnCanceledListener(listener:OnCanceledListener<T>):Task<Dynamic>;
	@:overload public function addOnCanceledListener(executor:Executor, listener:OnCanceledListener<T>):Task<Dynamic>;
	@:overload public function addOnCanceledListener(activity:Activity, listener:OnCanceledListener<T>):Task<Dynamic>;
	@:overload public function addOnCompleteListener(listener:OnCompleteListener<T>):Task<Dynamic>;
	@:overload public function addOnCompleteListener(executor:Executor, listener:OnCompleteListener<T>):Task<Dynamic>;
	@:overload public function addOnCompleteListener(activity:Activity, listener:OnCompleteListener<T>):Task<Dynamic>;
	@:overload public function addOnFailureListener(listener:OnFailureListener<T>):Task<Dynamic>;
	@:overload public function addOnFailureListener(executor:Executor, listener:OnFailureListener<T>):Task<Dynamic>;
	@:overload public function addOnFailureListener(activity:Activity, listener:OnFailureListener<T>):Task<Dynamic>;
	@:overload public function addOnSuccessListener(listener:OnSuccessListener<T>):Task<Dynamic>;
	@:overload public function addOnSuccessListener(executor:Executor, listener:OnSuccessListener<T>):Task<Dynamic>;
	@:overload public function addOnSuccessListener(activity:Activity, listener:OnSuccessListener<T>):Task<Dynamic>;
	public function getException():Exception;
	@:overload public function getResult():Dynamic;
	@:overload public function getResult(exceptionType:Dynamic):Dynamic;
	public function isCanceled():Bool;
	public function isComplete():Bool;
	public function isSuccessful():Bool;
}

extern class Creator<T> {
	
}

@:native("java.util.Set") extern class Set<T> {

}

@:native("com.google.android.gms.auth.api.signin.GoogleSignIn") extern class GoogleSignIn {
	public static function getAccountForExtension(context:Context, extension:GoogleSignInOptionsExtension):GoogleSignInAccount;
	public static function getAccountForScopes(context:Context, scope:Scope, scopes:Dynamic):GoogleSignInAccount; //Scope... scopes):GoogleSignInAccount
	@:overload public static function getClient(context:Context, options:GoogleSignInOptions):GoogleSignInClient;
	@:overload public static function getClient(activity:Activity, options:GoogleSignInOptions):GoogleSignInClient;
	public static function getLastSignedInAccount(context:Context):GoogleSignInAccount;
	public static function getSignedInAccountFromIntent(data:Intent):Task<GoogleSignInAccount>;
	@:overload public static function hasPermissions(account:GoogleSignInAccount, extension:GoogleSignInOptionsExtension):Bool;
	@:overload public static function hasPermissions(account:GoogleSignInAccount, scopes:Dynamic):Bool; //Scope... scopes):Bool
	@:overload public static function requestPermissions(activity:Activity, requestCode:Int, account:GoogleSignInAccount, extension:GoogleSignInOptionsExtension):Void;
	@:overload public static function requestPermissions(activity:Activity, requestCode:Int, account:GoogleSignInAccount, scopes:Dynamic):Void; //Scope... scopes):Void
	@:overload public static function requestPermissions(fragment:Fragment, requestCode:Int, account:GoogleSignInAccount, extension:GoogleSignInOptionsExtension):Void;
	@:overload public static function requestPermissions(fragment:Fragment, requestCode:Int, account:GoogleSignInAccount, scopes:Dynamic):Void; //Scope... scopes):Void
}

@:native("com.google.android.gms.auth.api.signin.GoogleSignInAccount") extern class GoogleSignInAccount {
	public static var CREATOR:Creator<GoogleSignInAccount>;
	public function equals(obj:Object):Bool;
	public function getAccount():Account;
	public function getDisplayName():String;
	public function getEmail():String;
	public function getFamilyName():String;
	public function getGivenName():String;
	public function getGrantedScopes():Set<Scope>;
	public function getId():String;
	public function getIdToken():String;
	public function getPhotoUrl():Uri;
	public function getServerAuthCode():String;
	public function hashCode():Int;
	public function writeToParcel(out:Parcel, flags:Int):Void;
}

@:native("com.google.android.gms.auth.api.signin.GoogleSignInClient") extern class GoogleSignInClient {
	public function getSignInIntent():Intent;
	public function revokeAccess():Task<Void>;
	public function signOut():Task<Void>;
	public function silentSignIn():Task<GoogleSignInAccount>;
}

@:native("com.google.android.gms.auth.api.signin.GoogleSignInOptions") extern class GoogleSignInOptions {
	public static var CREATOR:Creator<GoogleSignInOptions>;
	public static var DEFAULT_GAMES_SIGN_IN:GoogleSignInOptions;
	public static var DEFAULT_SIGN_IN:GoogleSignInOptions;

	public static function equals(obj:Object):Bool;
	public static function getScopeArray():Array<Scope>;
	public static function hashCode():Int;
	public static function writeToParcel(out:Parcel, flags:Int):Void;
}

@:native("com.google.android.gms.auth.api.signin.GoogleSignInOptionsExtension") extern class GoogleSignInOptionsExtension {
	
}

typedef GetLeaderboardsParameters = {
	leaderboardId:String,
	?consistencyToken:Int,
	?language:String
}

typedef ListLeaderboardsParameters = {
	?consistencyToken:Int,
	?language:String,
	?maxResults:Int,
	?pageToken:String
}

typedef LeaderboardEntry = {
	formattedScore:String,
	formattedScoreRank:String,
	kind:String,
	player:Player,
	scoreRank:String,
	scoreValue:String,
	timeSpan:String,
	writeTimestampMillis:String,
}

typedef Player = {
	bannerUrlLandscape:String,
	bannerUrlPortrait:String,
	displayName:String,
	experienceInfo:ExperienceInfo,
	kind:String,
	playerId:String,
	profileSettings:ProfileSettings,
	title:String
}

typedef ExperienceInfo = {
	currentExperiencePoints:String,
	currentLevel:PlayerLevel,
	kind:String,
	nextLevel:PlayerLevel,
}

typedef PlayerLevel = {
	kind:String,
	level: Int,
	minExperiencePoints: String,
	maxExperiencePoints: String
}

typedef ProfileSettings = {
	kind:String, 
	profileVisible:Bool
}

typedef LeaderboardGetResponse = {
	items:Array<LeaderboardEntry>,
	kind:String,
	numScores:Int,
	playerScore:LeaderboardEntry,
}

typedef Leaderboard = {
	iconUrl:String,
	id:String,
	isIconUrlDefault:Bool,
	kind:String,
	name:String,
	order:String
}

typedef LeaderboardListResponse = {
	items:Array<Leaderboard>,
	kind:String
}