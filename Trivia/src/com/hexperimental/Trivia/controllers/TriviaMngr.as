package com.hexperimental.Trivia.controllers
{
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import XML;
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import com.adobe.serialization.json.JSON;
	import mx.collections.ArrayCollection;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;

	
	public class TriviaMngr extends Sprite {
	
		public static var ANSWER_SUBMITTED:String = "answerSubmitted";
		public static var GAME_OVER:String = 'gameOver';
		
		private var _data:ArrayCollection;
		public var _pointer:Number=-1;
		private var _url:String;
		public function TriviaMngr() {
			super();
		}
		
		public function answer( qid_:Number, oid_:Number, pts:Number ):void{
			var URLrequest:URLRequest = new URLRequest( _url );	
			var variables:URLVariables = new URLVariables();
			variables.a = 'answer';
			variables.q = qid_;
			variables.o = oid_;
			variables.p = pts;
	    URLrequest.method = URLRequestMethod.POST;
	    URLrequest.data = variables;
			var ldr:URLLoader = new URLLoader( URLrequest );
			ldr.addEventListener(Event.COMPLETE,answerComplete);
			ldr.addEventListener(IOErrorEvent.IO_ERROR,ioError);	
		}
		
		private function answerComplete( e:Event ):void {
			dispatchEvent( new Event(ANSWER_SUBMITTED) );
		}
		
		public function getNext():Object{
			_pointer++;
			return getQuestion();
		}
		
		public function getQuestion( id_:Number = -1 ):Object{
			var _dataPkg:Number;
			if(id_>=0){
				_dataPkg = id_;
			}else{
				_dataPkg = _pointer				
				if(_dataPkg >= _data.length){
					_pointer = -1;
					_dataPkg = 0;
					dispatchEvent( new Event( TriviaMngr.GAME_OVER ) );
					return {};
				}
			}

			//
			return _data[_dataPkg];
		}
		
		public function loadQuestions( filepath_:String ):void {
			_url = filepath_;
			var ldr:URLLoader = new URLLoader( new URLRequest( filepath_ ) );
			ldr.addEventListener(Event.COMPLETE,parseQuestions);
			ldr.addEventListener(IOErrorEvent.IO_ERROR,ioError);	
		}
		
		private function ioError(e:IOErrorEvent):void {
			dispatchEvent( e );
		}
		
		private function parseQuestions( e:Event ):void{
				var rawData:String = String(e.currentTarget.data);
				var arr:Array = (JSON.decode(rawData) as Array);
				_data = new ArrayCollection(arr);
				dispatchEvent( e );
		}
	
	
	}

}