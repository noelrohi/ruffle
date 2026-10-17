package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.setInterval;

    public class Child extends Sprite {
        private var ran:Array = [];

        public function Child() {
            loaderInfo.addEventListener(Event.UNLOAD, function(e:Event):void {
                var timer:Timer = new Timer(10);
                timer.addEventListener(TimerEvent.TIMER, function(e:Event):void {
                    once("Timer");
                });
                timer.start();
                setInterval(function():void {
                    once("interval");
                }, 10);
                stage.addEventListener(Event.ENTER_FRAME, function(e:Event):void {
                    once("stage enterFrame listener");
                });
            });
        }

        private function once(what:String):void {
            if (ran.indexOf(what) < 0) {
                ran.push(what);
                trace(what + " started by the child's unload handler ran after unloading");
            }
        }
    }
}
