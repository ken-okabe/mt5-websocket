using System;
using System.Text;
using RGiesecke.DllExport;
using System.Runtime.InteropServices;
using System.Windows.Forms;

using WebSocket4Net;

namespace MT5websocket
{
    public class Class1
    {
        public static string Pair;

        public static WebSocket websocket;

        [DllExport("onDLL", CallingConvention = CallingConvention.StdCall)]
        public static void onDLL([MarshalAs(UnmanagedType.LPWStr)]string pair)
        {
            //this DLL loaded to MT5 with EA and called the confiramation
            Pair = pair;

            websocket = new WebSocket("ws://mt5-dc-ubuntu.cloudapp.net:9998/");//ubuntu ifconfig
            websocket.Opened += new EventHandler(websocket_Opened);
            /*     websocket.Error += new EventHandler<ErrorEventArgs>(websocket_Error);
                 websocket.Closed += new EventHandler(websocket_Closed);
                 websocket.MessageReceived += new EventHandler(websocket_MessageReceived);*/
            websocket.Open();



        }
        private static void websocket_Opened(object sender, EventArgs e)
        {
            websocket.Send(Pair);
        }

        [DllExport("onTick", CallingConvention = CallingConvention.StdCall)]
        public static void onTick(double bid, double ask)
        {

        }
        [DllExport("onBar", CallingConvention = CallingConvention.StdCall)]
        public static void onBar()
        {

        }

    }
}
