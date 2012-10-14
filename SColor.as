package
{
    public class SColor
    {
        public static function color(red:SColor, green:SColor, blue:SColor):uint
        {
            return (red.value << 16) | (green.value << 8) | blue.value;
        }

        public var value:int;
        public var min:int;
        public var max:int;
        public var step:int;
        public var direction:int;

        public function SColor(min:int, max:int, step:int)
        {
            this.min = min;
            this.max = max;
            this.step = step;
            direction = 1;
        }

        public function takeStep():void
        {
            value += step * direction;

            if (value > max)
            {
                value = max;
                direction = -1;
            }
            else if (value < min)
            {
                value = min;
                direction = 1;
            }
        }
    }
}
