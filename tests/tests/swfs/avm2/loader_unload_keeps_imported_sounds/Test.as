package {
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.URLRequest;

    public class Test extends Sprite {
        private var loader:Loader = new Loader();
        private var frames:int = -1;

        public function Test() {
            addChild(loader);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
            addEventListener(Event.ENTER_FRAME, onFrame);
            loader.load(new URLRequest("importer.swf"));
        }

        private function onComplete(e:Event):void {
            trace("importer loaded");
            frames = 0;
        }

        private function onFrame(e:Event):void {
            if (frames >= 0 && ++frames == 3) {
                loader.unloadAndStop(true);
                trace("importer unloaded");
            } else if (frames == 20) {
                trace("done");
                removeEventListener(Event.ENTER_FRAME, onFrame);
            }
        }
    }
}
