using System;
using System.Text;

namespace Encoders
{
    public class Ceasarus
    {
        public int Shift;

        public Ceasarus()
        {
            Random rand = new Random();
            this.Shift = rand.Next(5, 100);
        }

        public Ceasarus(int shift)
        {
            this.Shift = shift;
        }

        private byte[] ShiftBytes(byte[] buf, bool toTheLeft = false)
        {
            int shift = this.Shift;
            if (toTheLeft)
            {
                shift = -1 * this.Shift;
            }

            byte[] result = new byte[buf.Length];
            for (int i = 0; i < buf.Length; i++)
            {
                result[i] = (byte)(((uint)buf[i] + shift) & 0xFF);
            }

            return result;
        }

        private string BytesToHex(byte[] buf)
        {
            StringBuilder hexBuilder = new StringBuilder(buf.Length * 2);
            foreach (byte b in buf)
            {
                hexBuilder.AppendFormat("0x{0:x2},", b);
            }
            string hex = hexBuilder.ToString();
            return hex.Remove(hex.Length - 1);
        }

        public byte[] Encode(byte[] buf)
        {
            return this.ShiftBytes(buf);
        }

        public string EncodeAsHex(byte[] buf)
        {
            byte[] encoded = this.Encode(buf);
            return this.BytesToHex(encoded);
        }

        public byte[] Decode(byte[] buf)
        {
            return this.ShiftBytes(buf, true);
        }

        public string DecodeAsHex(byte[] buf)
        {
            byte[] decoded = this.Decode(buf);
            return this.BytesToHex(decoded);
        }
    }
}
