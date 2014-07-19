using System;
using System.Text;
 
using RGiesecke.DllExport;
using System.Runtime.InteropServices;
using System.Windows.Forms;

using WebSocket4Net;

using System.Web.Script.Serialization;



namespace MT5websocket
{
    public class Class1
    {
        public static string Pair;
        public static string Period;

        public static WebSocket websocket;

        [DllExport("onDLL", CallingConvention = CallingConvention.StdCall)]
        public static void onDLL([MarshalAs(UnmanagedType.LPWStr)]string pair, [MarshalAs(UnmanagedType.LPWStr)]string period)
        {
            //this DLL loaded to MT5 with EA and called the confiramation
            Pair = pair;
            Period = period;

            websocket = new WebSocket("ws://localhost:9998/");//ubuntu ifconfig
            websocket.Opened += new EventHandler(websocket_Opened);
            /*     websocket.Error += new EventHandler<ErrorEventArgs>(websocket_Error);
                 websocket.Closed += new EventHandler(websocket_Closed);
                 websocket.MessageReceived += new EventHandler(websocket_MessageReceived);*/
            websocket.Open();
 
        }

       

        struct pairData
        {
            public String pair;
            public String period;
        }
       

        private static void websocket_Opened(object sender, EventArgs e)
        {
            pairData pairData1 = new pairData();
            pairData1.pair = Pair;
            pairData1.period = Period;
            var serializer = new JavaScriptSerializer();
            var json = serializer.Serialize(pairData1);
            websocket.Send(json);
        }

        struct tickData
        {
            public double bid;
            public double ask;
        }

        [DllExport("onTick", CallingConvention = CallingConvention.StdCall)]
        public static void onTick(double bid, double ask)
        {

            tickData tickData1 = new tickData();
            tickData1.bid = bid;
            tickData1.ask = ask;
            var serializer = new JavaScriptSerializer();
            var json = serializer.Serialize(tickData1);
            websocket.Send(json);
        }

        struct barData
        {
            public string time;
            public double open;
            public double high;
            public double low;
            public double close;
        } 

        [DllExport("onBar", CallingConvention = CallingConvention.StdCall)]
        public static void Bar(int time, double open, double high, double low, double close)
        {
            var time1 = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc).AddSeconds(time).ToString("yy.MM.dd HH:mm");         
            barData barData1 = new barData();
            barData1.time = time1;
            barData1.open = open;
            barData1.high = high;
            barData1.low = low;
            barData1.close = close;

            var serializer = new JavaScriptSerializer();
            var json = serializer.Serialize(barData1);
            websocket.Send(json);
        }

     

    }
}
