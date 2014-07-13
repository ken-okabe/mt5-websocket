using System;
using System.Text;
using System.IO;
using System.Runtime.Serialization.Json;
using RGiesecke.DllExport;
using System.Runtime.InteropServices;
using System.Windows.Forms;

using WebSocket4Net;



namespace MT5websocket
{
    public class Class1
    {
        public static string Pair;
        public static int Period;

        public static WebSocket websocket;

        [DllExport("onDLL", CallingConvention = CallingConvention.StdCall)]
        public static void onDLL([MarshalAs(UnmanagedType.LPWStr)]string pair,int period)
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
            public int period;
        }

        private static void websocket_Opened(object sender, EventArgs e)
        {
            pairData pairData1 = new pairData();
            pairData1.pair = Pair;
            pairData1.period = Period;

        /*    MemoryStream stream1 = new MemoryStream();
            DataContractJsonSerializer ser = new DataContractJsonSerializer(typeof(pairData));

            ser.WriteObject(stream1, pairData1);

            stream1.Position = 0;
            StreamReader sr = new StreamReader(stream1); 
            String s = sr.ReadToEnd();*/ 
             websocket.Send("{pair:'eur',period:'5'}");
        }

        [DllExport("onTick", CallingConvention = CallingConvention.StdCall)]
        public static void onTick(double bid, double ask)
        {
          //  var tick ={bid:bid,ask:ask};

           // websocket.Send(tick);
        }
        [DllExport("onBar", CallingConvention = CallingConvention.StdCall)]
        public static void onBar()
        {

        }

    }
}
