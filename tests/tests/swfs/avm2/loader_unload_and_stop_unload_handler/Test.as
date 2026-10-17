package {
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.URLRequest;

    public class Test extends Sprite {
        private var loader:Loader = new Loader();
        private var frame:int = -1;

        public function Test() {
            addChild(loader);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
                frame = 0;
            });
            addEventListener(Event.ENTER_FRAME, onFrame);
            loader.load(new URLRequest("child.swf"));
        }

        private function onFrame(e:Event):void {
            if (frame < 0) {
                return;
            }
            frame++;
            if (frame == 2) {
                loader.unloadAndStop(true);
                trace("unloaded");
            } else if (frame == 12) {
                trace("done, content " + loader.content);
                removeEventListener(Event.ENTER_FRAME, onFrame);
            }
        }
    }
}
