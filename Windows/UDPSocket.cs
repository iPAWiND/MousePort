using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace MousePort
{

    public delegate void UDPSocketConnectCallback(string result);
    public delegate void UDPSocketDisconnectCallback();


    public class UDPClient
    {
        private Socket _socket = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp);
        private const int bufSize = 8 * 1024;
        private State state = new State();
        private EndPoint epFrom = new IPEndPoint(IPAddress.Any, 0);
        private AsyncCallback recv = null;
        private UDPSocketConnectCallback callback;
        private UDPSocketDisconnectCallback disconnectCallback;
        private bool monitorStatus = false;

        public class State
        {
            public byte[] buffer = new byte[bufSize];
        }

        public UDPClient(string address, int port)
        {
            _socket.Connect(IPAddress.Parse(address), port);
            beginRceiving();
        }

        public void send(string text, UDPSocketConnectCallback callback = null)
        {
            byte[] data = Encoding.ASCII.GetBytes(text);

            if (callback != null)
            {
                this.callback = callback;

            }

            _socket.BeginSend(data, 0, data.Length, SocketFlags.None, (ar) =>
            {
                State so = (State)ar.AsyncState;
                int bytes = _socket.EndSend(ar);
                Console.WriteLine("SEND: {0}, {1}", bytes, text);

            }, state);
      
        }

        public void monitorConnection(UDPSocketDisconnectCallback callback)
        {

            this.disconnectCallback = callback;

            Thread monitorThread = new Thread(checkIfResponding);

            monitorThread.Start();
        }

        private void checkIfResponding()
        {

            monitorStatus = false;

            send("ping");

            Thread.Sleep(5000);

            if (monitorStatus == true)
            {
                checkIfResponding();
                return;
            }

            this.disconnectCallback();
        }

        private void beginRceiving()
        {
            _socket.BeginReceiveFrom(state.buffer, 0, bufSize, SocketFlags.None, ref epFrom, recv = (ar) =>
            {
                State so = (State)ar.AsyncState;
                int bytes = _socket.EndReceiveFrom(ar, ref epFrom);
                _socket.BeginReceiveFrom(so.buffer, 0, bufSize, SocketFlags.None, ref epFrom, recv, so);
                Console.WriteLine("RECV: {0}: {1}, {2}", epFrom.ToString(), bytes, Encoding.ASCII.GetString(so.buffer, 0, bytes));
                this.callback(Encoding.ASCII.GetString(so.buffer, 0, bytes));
                monitorStatus = true;
            }, state);
        }
    }
}
