package
{
    import flash.display.Graphics;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import mx.core.FlexSprite;
    import mx.events.NumericStepperEvent;

    public class Controller
    {
        public static const MAX_WHEELS:int = 5;
        public static const MAX_SPEED:Number = 10;

        public const TO_RAD:Number = Math.PI/180;

        public var ui:SpiralDraw;
        public var g:Graphics;

        public var centerX:Number;
        public var centerY:Number;
        public var radius:Number;

        public var numWheels:int;
        public var currentWheel:int;
        public var wheels:Vector.<Wheel>;

        public var animTimer:Timer;
        public var animating:Boolean;
        public var paused:Boolean;

        public var iterations:int;
        public var iter:int;

        public var red:SColor;
        public var green:SColor;
        public var blue:SColor;
        public var color:uint;

        public var rainbow:Boolean;

        public function Controller(ui:SpiralDraw)
        {
            this.ui = ui;
            g = ui.displayArea.graphics;

            animating = paused = false;

            wheels = new Vector.<Wheel>(MAX_WHEELS, true);
            for (var i:String in wheels)
                wheels[i] = new Wheel(1.0, 1.0);

            red = new SColor(0, 0, 0);
            green = new SColor(0, 0, 0);
            blue = new SColor(0, 0, 0);

            getVars();
            getWheelVars();
        }

        public function getVars():void
        {
            currentWheel = ui.wheelNum.value;
            numWheels = ui.numWheels.value;

            iterations = ui.iterations.value;

            centerX = ui.displayArea.width/2;
            centerY = ui.displayArea.height/2;
            radius = Math.min(centerX, centerY);

            red.value   = red.min   = ui.red.value;
            green.value = green.min = ui.green.value;
            blue.value  = blue.min  = ui.blue.value;

            red.max   = ui.redMax.value;
            green.max = ui.greenMax.value;
            blue.max  = ui.blueMax.value;

            red.step   = ui.redStep.value;
            green.step = ui.greenStep.value;
            blue.step  = ui.blueStep.value;

            color = SColor.color(red, green, blue);

            rainbow = ui.rainbow.selected;
        }

        public function getWheelVars():void
        {
            wheels[currentWheel - 1] = new Wheel(
                ui.wheelRadius.value, ui.wheelSpeed.value);

            currentWheel = ui.wheelNum.value;
            ui.wheelRadius.value = wheels[currentWheel - 1].rad;
            ui.wheelSpeed.value = wheels[currentWheel - 1].spd;
        }

        public function updateUI():void
        {
            ui.numWheels.value = numWheels;
            ui.wheelNum.value = 2;
            ui.wheelRadius.value = wheels[1].rad;
            ui.wheelSpeed.value = wheels[1].spd;
            ui.iterations.value = iterations;

            ui.red.value = red.min;
            ui.redMax.value = red.max;
            ui.redStep.value = red.step;

            ui.green.value = green.min;
            ui.greenMax.value = green.max;
            ui.greenStep.value = green.step;

            ui.blue.value = blue.min;
            ui.blueMax.value = blue.max;
            ui.blueStep.value = blue.step;

            ui.rainbow.selected = rainbow;
        }

        public function randomize():void
        {
            getVars();

            numWheels = Math.random() * (MAX_WHEELS - 1) + 2;
            for (var w:int = 1; w < numWheels; w++)
            {
                wheels[w].rad = Math.random();
                wheels[w].spd = Math.random() * 2 * MAX_SPEED - MAX_SPEED;
            }

            updateUI();
            draw();
        }

        public function handleDraw(animated:Boolean = false):void
        {
            getVars();
            getWheelVars();
            draw(animated);
        }

        public function pauseAnimation(on:Boolean = true):void
        {
            if (!animating)
                return;

            if (on)
            {
                paused = true;
                animTimer.stop();
                ui.animationToggle.label = "Play";
            }
            else
            {
                paused = false;
                animTimer.start();
                ui.animationToggle.label = "Pause";
            }
        }

        public function getCode():void
        {
            var code:String;
            var elements:Vector.<Number> = new Vector.<Number>();
            var strings:Vector.<String> = new Vector.<String>();
            
            elements.push(numWheels);
            elements.push(iterations);
            
            for (var w:int = 1; w < numWheels; w++)
            {
                var wheel:Wheel = wheels[w];
                elements.push(wheel.rad);
                elements.push(wheel.spd);
            }

            elements.push(red.min);
            elements.push(red.max);
            elements.push(red.step);

            elements.push(green.min);
            elements.push(green.max);
            elements.push(green.step);

            elements.push(blue.min);
            elements.push(blue.max);
            elements.push(blue.step);

            elements.push(rainbow ? 1 : 0);

            for each (var num:Number in elements)
            {
                strings.push(num.toString());
            }

            code = strings.join(" ");

            ui.code.text = code;
        }

        public function loadCode():void
        {
            var code:String = ui.code.text;
            var elements:Vector.<Number> = new Vector.<Number>();
            var strings:Vector.<String> = Vector.<String>(code.split(" "));
            var e:int, w:int;

            var headEls:int = 2;
            var wheelEls:int;
            var colorEls:int = 3 * 3 + 1;
            var totalEls:int;

            try
            {
                for each (var string:String in strings)
                {
                    elements.push(parseFloat(string));
                }

                numWheels = int(elements[0]);
                wheelEls = (numWheels - 1) * 2;
                totalEls = headEls + wheelEls + colorEls;

                if (elements.length != totalEls)
                    throw new Error();

                iterations = int(elements[1]);

                for (e = 2, w = 1; e < totalEls - colorEls; e += 2, w++)
                {
                    var wheel:Wheel = wheels[w];
                    wheel.rad = elements[e];
                    wheel.spd = elements[e+1];
                }

                red.value = int(elements[e++]);
                red.max = int(elements[e++]);
                red.step = int(elements[e++]);

                green.value = int(elements[e++]);
                green.max = int(elements[e++]);
                green.step = int(elements[e++]);

                blue.value = int(elements[e++]);
                blue.max = int(elements[e++]);
                blue.step = int(elements[e++]);

                rainbow = Boolean(elements[e]);

                updateUI();
                draw();
            }
            catch (exception:Error)
            {
                ui.code.text ="Error!";
            }
        }

        public function stopAnimation():void
        {
            if (animating)
            {
                pauseAnimation(false);
                animating = false;
                paused = true;
                animTimer.stop();
                animTimer = null;
            }
        }

        public function draw(animated:Boolean = false):void
        {
            getCode();

            g.clear();
            g.lineStyle(2, color);

            stopAnimation();
            
            if (animated)
            {
                animating = true;
                iter = 0;
                animTimer = new Timer(1/30, iterations);
                animTimer.addEventListener(
                    TimerEvent.TIMER, handleAnimStep, false, 0, true);
                animTimer.start();
                pauseAnimation(false);
            }
            else
            {
                for (iter = 0; iter < iterations; iter++)
                {
                    drawSegment();
                }
            }
        }

        public function handleAnimStep(event:TimerEvent):void
        {
            drawSegment();
            iter++;
        }

        public function drawSegment():void
        {
            var x:Number = 0;
            var y:Number = 0;
            var tempx:Number, tempy:Number;
            var wheel:Wheel;
            var angle:Number;

            for (var w:int = 0; w < numWheels; w++)
            {
                wheel = wheels[w];

                angle = iter * wheel.spd * TO_RAD;

                tempx = Math.cos(angle);
                tempy = Math.sin(angle);

                tempx *= wheel.rad;
                tempy *= wheel.rad;

                x *= 1 - wheel.rad;
                y *= 1 - wheel.rad;
                    
                x += tempx;
                y += tempy;
            }
                
            x *= radius;
            y *= radius;

            x += centerX;
            y += centerY;

            if (rainbow)
            {
                red.takeStep();
                green.takeStep();
                blue.takeStep();

                color = SColor.color(red, green, blue);
                g.lineStyle(2, color);
            }

            if (iter == 0) g.moveTo(x, y);
            g.lineTo(x, y);

        }
    }
}
