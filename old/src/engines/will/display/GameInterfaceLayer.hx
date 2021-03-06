package engines.will.display;

import reflash.display2.Seconds;
import reflash.display2.View;
import lang.DisposableGroup;
import lang.IDisposable;
import lang.signal.Signal;
import common.input.GameInput;
import lang.promise.Promise;
import lang.promise.IPromise;
import reflash.display.DisplayObject2;
import reflash.display.AnimatedImage2;
import reflash.display.TextField2;
import reflash.gl.wgl.WGLTexture;
import flash.display.BitmapData;
import reflash.display2.Easing;
import haxe.Log;
import engines.will.formats.wip.WIP;
import reflash.display.Sprite2;

class GameInterfaceLayer extends Sprite2 {
    private var willResourceManager:WillResourceManager;
    private var wipLayer:WIPLayer;
    private var textFieldContent:TextField2;
    private var textFieldTitle:TextField2;
    private var waitingLayer:DisplayObject2;
    private var view:View;

    public function new(view:View, willResourceManager:WillResourceManager) {
        super();

        this.view = view;
        this.willResourceManager = willResourceManager;
    }

    public function initAsync():IPromise<Dynamic> {
// QLOAD, QSAVE, LOAD, SAVE, LOG, AUTO, SKIP, STATUS, SYSTEM
        var deferred = Promise.createDeferred();
        willResourceManager.getWipWithMaskAsync("CLKWAIT").then(function(clkWaitWip:WIP) {
            willResourceManager.getWipWithMaskAsync("WINBASE0").then(function(winBase0Wip:WIP) {
                var clkwaitTexture = WGLTexture.fromBitmapData(clkWaitWip.get(0).bitmapData);
                var clkwaitFrames = clkwaitTexture.split(55, clkwaitTexture.height);

//wip.save('c:/temp');
//Log.trace("$wip");
                wipLayer = WIPLayer.fromWIP(winBase0Wip);
                wipLayer.setPosition(400, 600 - 8);
                wipLayer.setAnchor(0.5, 1);
                addChild(wipLayer);

                wipLayer.addChild(textFieldContent = new TextField2());
                textFieldContent.setPosition(50, 58);

                wipLayer.addChild(textFieldTitle = new TextField2());
                textFieldTitle.setPosition(50, 26);

                wipLayer.addChild(this.waitingLayer = new AnimatedImage2(clkwaitFrames, 30).setPosition(650, 120));
                this.waitingLayer.visible = false;
//wipLayer.addChild(new Image2(clkwaitTexture));

                setButtonState(Buttons.QLOAD, 1);
                setButtonState(Buttons.QSAVE, 1);
                setButtonState(Buttons.LOAD, 1);
                setButtonState(Buttons.SAVE, 1);
                setButtonState(Buttons.LOG, 1);
                setButtonState(Buttons.AUTO, 1);
                setButtonState(Buttons.SKIP, 1);
                setButtonState(Buttons.STATUS, 1);
                setButtonState(Buttons.SYSTEM, 1);

                hideAsync(new Seconds(0)).then(function(?e) {
                    deferred.resolve(null);
                });
            });
        });
        return deferred.promise;
    }

    public function setTextSize(size:Int):Void {
        var scale:Float = switch (size) {
            case 0: 1;
            case 1: 2;
            default: throw('Invalid size');
        };
        textFieldContent.scaleY = textFieldContent.scaleX = scale;
    }

    public function setTextAsync(text:String, title:String, ?timePerCharacter:Seconds):IPromise<Dynamic> {
        if (timePerCharacter == null) timePerCharacter = new Seconds(0.05);
        var totalTime = new Seconds(timePerCharacter.toFloat() * text.length);
        this.waitingLayer.visible = false;

        var disposable = DisposableGroup.create();

        if (title != null && title != '') {
            wipLayer.setLayerVisibility(31, true);
            textFieldTitle.text = title;
            textFieldTitle.visible = true;
        }
        else {
            wipLayer.setLayerVisibility(31, false);
            textFieldTitle.text = '';
            textFieldTitle.visible = false;
        }

        var promise = view.animateAsync(totalTime, function(step:Float) {
            textFieldContent.text = text.substr(0, Math.round(text.length * step));
        }).then(function(e) {
            waitingLayer.visible = true;
            Log.trace('Completed text! $text');
            disposable.dispose();
        });

        disposable.add(Signal.addAnyOnce([GameInput.onClick, GameInput.onKeyPress], function(e) {
            promise.cancel();
        }));

        return promise;
    }

    public function hideAsync(?time:Seconds):IPromise<Dynamic> {
        if (time == null) time = new Seconds(0.3);
        if (wipLayer.alpha == 0) return Promise.createResolved();

        this.waitingLayer.visible = false;
        wipLayer.setLayerVisibility(31, false);

        return Promise.whenAll([
        view.interpolateAsync(wipLayer.getLayer(0), time, { scaleY: 0 }, Easing.easeInOutQuad),
        view.interpolateAsync(wipLayer, time, { alpha: 0 }, Easing.easeInOutQuad)
        ]);
    }

    public function showAsync(?time:Seconds):IPromise<Dynamic> {
        if (time == null) time = new Seconds(0.3);
        if (wipLayer.alpha == 1) return Promise.createResolved();

        this.waitingLayer.visible = false;
//wipLayer.setLayerVisibility(31, false);

        return Promise.whenAll([
        view.interpolateAsync(wipLayer.getLayer(0), time, { scaleY: 1 }, Easing.easeInOutQuad),
        view.interpolateAsync(wipLayer, time, { alpha: 1 }, Easing.easeInOutQuad)
        ]);
    }

    private function setButtonState(button:Int, state:Int):Void {
        if (state == 0) wipLayer.setLayerVisibility(1 + button, true);
        if (state == 1) wipLayer.setLayerVisibility(10 + button, true);
        if (state == 2) wipLayer.setLayerVisibility(19 + button, true);
    }
}

//@:coreType abstract Button from Int to Int { }

class Buttons {
    static public var QLOAD:Int = 0;
    static public var QSAVE:Int = 1;
    static public var LOAD:Int = 2;
    static public var SAVE:Int = 3;
    static public var LOG:Int = 4;
    static public var AUTO:Int = 5;
    static public var SKIP:Int = 6;
    static public var STATUS:Int = 7;
    static public var SYSTEM:Int = 8;
}
