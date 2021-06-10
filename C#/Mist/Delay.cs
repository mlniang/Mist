using System;
using System.Runtime.InteropServices;

namespace Mist
{
    public class Delay
    {
        [DllImport("kernel32.dll")]
        static extern void Sleep(uint dwMilliseconds);

        public static bool DoSleep(uint seconds = 5)
        {
            DateTime beforeSleep = DateTime.Now;
            Sleep(seconds * 1000);
            double duration = DateTime.Now.Subtract(beforeSleep).TotalSeconds;
            return duration >= (seconds - 0.5);
        }
    }
}
