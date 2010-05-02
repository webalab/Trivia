//AS3///////////////////////////////////////////////////////////////////////////
// 
// Copyright 2010 
// 
////////////////////////////////////////////////////////////////////////////////

package
{
import flash.utils.*;
import flash.net.*;
import flash.events.Event;
import flash.display.Sprite;
import com.hexperimental.Config;
import flash.text.TextField;
import com.hexperimental.Trivia.controllers.TriviaMngr;
import flash.events.IOErrorEvent;
import com.hexperimental.Notification;
import flash.display.StageQuality;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.events.MouseEvent;
import Error;
import flash.events.HTTPStatusEvent;
import flash.events.SecurityErrorEvent;

/**
 * Application entry point for Trivia.
 * 
 * @langversion ActionScript 3.0
 * @playerversion Flash 9.0
 * 
 * @author Antonio Perez
 * @since 01.05.2010
 */
public class Trivia extends Sprite
{
	private var myTrivia:TriviaMngr;
	
	[Embed(source="/assets/assets_trivia.swf", symbol="QuestionClip")]
  public static var QUESTION_CLIP:Class;
	
	[Embed(source="/assets/assets_trivia.swf", symbol="AnswerButton")]
  public static var OPTION_CLIP:Class;

	[Embed(source="/assets/assets_trivia.swf", symbol="GameOverClip")]
  public static var GAMEOVER_CLIP:Class;
	
	
	public var questionSprite:Sprite;
	private var isGameOver:Boolean = false;
	/**
	 * @constructor
	 */
	public function Trivia() {
		super();

		// Stage settings.
		stage.quality = StageQuality.MEDIUM;
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		Config.instance().addEventListener(Event.COMPLETE, buildTrivia);
		Notification.ROOT = this;
		
		Config.init( this );
	}
	
	private function buildTrivia( e:Event = null ):void{
		Config.instance().removeEventListener(Event.COMPLETE, buildTrivia);
		myTrivia = new TriviaMngr();
		myTrivia.addEventListener(Event.COMPLETE, initialize);
		myTrivia.addEventListener(IOErrorEvent.IO_ERROR, err);
		myTrivia.loadQuestions( Config.get('baseurl')+Config.get('entrypoint') );		
		myTrivia.addEventListener(TriviaMngr.ANSWER_SUBMITTED,onAnswerSubmitted);
		myTrivia.addEventListener(TriviaMngr.GAME_OVER,onGameOver);
//	
	}
	
	private function onGameOver(e:Event):void{
		cleanQuestion();
		Notification.instance().throwAlert("GameOver",'notice');
		isGameOver = true;
		var goc:DisplayObject = new GAMEOVER_CLIP;
		goc['continueButton'].addEventListener(MouseEvent.CLICK, onGameOverClicked);
		addChild(goc);

	}
	
	private function onGameOverClicked(e:Event):void{
		saveScore('1','1');
	}
	
	private function onAnswerSubmitted(e:Event):void{
		cleanQuestion();
		if(isGameOver){return;}
		//clean
		
		//reload
		showQuestion();
	}
	
	
	private function err( e:IOErrorEvent = null ):void {
		Notification.instance().throwAlert("Error:"+e.text.toString(),'error',"TR",3);
	}

	/**
	 * Initialize stub.
	 */
	private function initialize( e:Event = null ):void {
		showQuestion();
	}
	
	private function showQuestion():void {
		questionSprite = drawQuestion();
		addChild( questionSprite );

	}

	private function cleanQuestion():void {
		try{
			removeChild(questionSprite);
		}catch(e:Error){
			
		}
	}

	private function drawQuestion():Sprite {
		var sprt:Sprite = new Sprite();
		var qClip:DisplayObject = new QUESTION_CLIP;
		var q:Object = myTrivia.getNext();
		
		if( !q.question ){ 
			return new Sprite(); 
		}
		
		qClip['questionText'].text= q.question;
		var pos:Array = new Array(new Point(10,134),
															new Point(230,134),
															new Point(10,214),
															new Point(230,214)
															);
		var i:uint = 0;													
		for each( var opt:Object in q.options) {
			var oClip:DisplayObject = new OPTION_CLIP;
			oClip['optionText'].text = opt.option;
			oClip.name = q.qid+"_"+opt.oid+"_"+opt.status;
			oClip.x = pos[i].x;
			oClip.y = pos[i].y;
			oClip.addEventListener(MouseEvent.CLICK,optionClicked);
			i++;
			Sprite(qClip).addChild(oClip);
		}
		sprt.addChild(qClip);
		return sprt;
	}
	
	private function optionClicked(e:MouseEvent):void{		
		var parts:Array = e.currentTarget.name.split('_');
		var qid:Number = Number( parts[0] );
		var oid:Number = Number( parts[1] );
		var sts:Number = Number( parts[2] ); 
		//submit answer
		myTrivia.answer(qid,oid,sts);
		//splash
		if( Config.get('silent')!='true'){
			
		}
		
	}
	
	
	
	public function saveScore(challenge_:String,score_:String):void {
		navigateToURL(new URLRequest( Config.get('baseurl')+Config.get('afterpath')),"_self");
		/*
		var url:String = SAVE_URL;
		var request:URLRequest = new URLRequest(url);
		var requestVars:URLVariables = new URLVariables();
			requestVars.cid = challenge_;
			requestVars.score = score_;
			request.data = requestVars;
			request.method = URLRequestMethod.POST;
 
		var urlLoader:URLLoader = new URLLoader();
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, ss_loaderCompleteHandler, false, 0, true);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, ss_httpStatusHandler, false, 0, true);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, ss_securityErrorHandler, false, 0, true);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ss_ioErrorHandler, false, 0, true);
		for (var prop:String in requestVars) {
			//trace("Sent: " + prop + " is: " + requestVars[prop]);
		}
		try {
			urlLoader.load(request);
		} catch (e:Error) {
			trace(e);
		}
		*/
	}
	public function ss_loaderCompleteHandler(e:Event):void {
	//	var responseVars:URLVariables = URLVariables( e.target.data );
	//	myDebugger.log( "responseVars: " + responseVars );
		navigateToURL(new URLRequest(Config.get('baseurl')+Config.get('afterpath')),"_self");
	}
	
	public function ss_httpStatusHandler( e:HTTPStatusEvent ):void {
		//trace("httpStatusHandler:" + e);
	}
	public function ss_securityErrorHandler( e:SecurityErrorEvent ):void {
	//	trace("securityErrorHandler:" + e);
	}
	public function ss_ioErrorHandler( e:IOErrorEvent ):void {
		//trace("ORNLoader:ioErrorHandler: " + e);
	//	dispatchEvent( e );
	}		
	
}

}