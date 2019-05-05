// MousePort
// Copyright © 2019 iPAWiND. All rights reserved.

using System;
using System.Drawing;
using System.Net;
using System.Threading;
using System.Windows.Forms;

namespace MousePort
{
    public partial class Form1 : Form
    {

        private UDPClient socket;
        private Point lastMousePosition;
        private bool mouseDown = false;
        private Thread connectionThread;

        public Form1()
        {
            InitializeComponent();

            // Enter Full Screen
            FormBorderStyle = FormBorderStyle.None;
            WindowState = FormWindowState.Maximized;

            connectionThread = new Thread(() => initConnection());

            connectionThread.Start();

            Shown += (s, e1) => {
                runUIThread();
            };
            
        }

        private void runUIThread()
        {
            Thread uiThread = new Thread(() => updateUI());
            uiThread.Start();
        }

        private void updateUI()
        {

            Console.WriteLine("Update UI");

            Invoke((MethodInvoker)delegate
            {

                Console.WriteLine("Size :"+Size);

                Point titleLocation = titleLabel.Location;

                titleLocation.X = (Size.Width / 2) - (titleLabel.Size.Width / 2);
                titleLocation.Y = 100;

                titleLabel.Location = titleLocation;

                Point statusLabelLocation = statusLabel.Location;

                statusLabelLocation.X = (Size.Width / 2) - (statusLabel.Size.Width / 2);
                statusLabelLocation.Y = Size.Height - 300;

                statusLabel.Location = statusLabelLocation;

                Point copyrightLabelLocation = copyrightLabel.Location;

                copyrightLabelLocation.Y = Size.Height - 100;
                copyrightLabelLocation.X = (Size.Width / 2) - (copyrightLabel.Size.Width / 2);

                copyrightLabel.Location = copyrightLabelLocation;

            });


                while (this.socket == null)
            {

                Invoke((MethodInvoker)delegate
                {

                    if (statusLabel.Text.Length > 12 || statusLabel.Text.Contains("Searching") == false)
                    {
                        statusLabel.Text = "Searching";
                    }

                    statusLabel.Text += ".";
                });

                Console.WriteLine("Update UI");

                Thread.Sleep(500);
            }

            Invoke((MethodInvoker)delegate {
                statusLabel.Text = "CONNECTED";
            });

        }


        private void initConnection()
        {
            string hostName = Dns.GetHostName(); // Retrive the Name of HOST  
            Console.WriteLine(hostName);

            // Get the IP  
            string myIP = Dns.GetHostByName(hostName).AddressList[0].ToString();
            string[] componenets = myIP.Split('.');
            componenets[componenets.Length - 1] = "";

            string ipScheme = String.Join(".", componenets);

            for (int i = 0; i < 256; i++)
            {

                string ip = ipScheme + i;

                if (ip == myIP) continue;

                Console.WriteLine("Testing ip: " + ip);

                UDPClient socket = new UDPClient(ip, 1011);

                socket.send("ping", (result) =>
                {
                    Console.WriteLine("Server found " + ip);
                    // Server responded back
                    if (this.socket != null) return;

                    this.socket = socket;

                    this.socket.monitorConnection(didDisconnect);
                });

            }

            Thread.Sleep(5000);

            if (this.socket == null)
            {
                initConnection();
            }
        }

        private void didDisconnect()
        {
            this.socket = null;

            Invoke((MethodInvoker)delegate
            {
                runUIThread();
            });

            initConnection();
        }

        private void Form1_MouseMove(object sender, MouseEventArgs e)
        {

            int x = MousePosition.X;
            int y = MousePosition.Y;

            bool isDragging = mouseDown;

            sendEvent(isDragging ? 3 : 0);

            Console.WriteLine("Mouse Moved " + x + " " + y);
        }

        private void Form1_MouseDown(object sender, MouseEventArgs e)
        {

            int x = MousePosition.X;
            int y = MousePosition.Y;

            mouseDown = true;

            sendEvent(1);

            Console.WriteLine("Mouse Down " + x + " " + y);
        }

        private void Form1_MouseUp(object sender, MouseEventArgs e)
        {

            int x = MousePosition.X;
            int y = MousePosition.Y;

            mouseDown = false;

            sendEvent(2);

            Console.WriteLine("Mouse Up " + x + " " + y);
        }

        private void Form1_MouseEnter(object sender, System.EventArgs e)
        {

            int x = MousePosition.X;
            int y = MousePosition.Y;

            lastMousePosition = new Point(x, y);

            Console.WriteLine("Mouse Enter " + x + " " + y);
        }

        private void sendEvent(int id)
        {

            if (this.socket == null) return;

            int x = MousePosition.X;
            int y = MousePosition.Y;

            int deltaX = x - lastMousePosition.X;
            int deltaY = y - lastMousePosition.Y;

            lastMousePosition.X = x;
            lastMousePosition.Y = y;

            socket.send("{ \"event\" : " + id + ", \"x\" : " + deltaX + ", \"y\" : " + deltaY + " }");
        }

    }
}
