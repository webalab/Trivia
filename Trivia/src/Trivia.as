//AS3///////////////////////////////////////////////////////////////////////////
// 
// Copyright 2010 
// 
////////////////////////////////////////////////////////////////////////////////

package
{

import flash.events.Event;
import flash.display.Sprite;

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
	
	/**
	 * @constructor
	 */
	public function Trivia()
	{
		super();
		stage.addEventListener( Event.ENTER_FRAME, initialize );
	}

	/**
	 * Initialize stub.
	 */
	private function initialize(event:Event):void
	{
		stage.removeEventListener( Event.ENTER_FRAME, initialize );
		trace( "Trivia::initialize()" );
	}
	
}

}
