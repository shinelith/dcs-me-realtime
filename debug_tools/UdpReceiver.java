package com.shinelith.dcs.realtime;

import java.net.DatagramPacket;
import java.net.DatagramSocket;

public class UdpReceiver {
	public final int PORT = 46587;

	public void start() {
		Runnable runnable = new Runnable() {
			@Override
			public void run() {
				System.out.println("DCS-ME-Realtime UDP Receiver Start");
				DatagramSocket ds = null;
				try {
					ds = new DatagramSocket(PORT);
					byte[] buf = new byte[1024];
					DatagramPacket dp = new DatagramPacket(buf, buf.length);

					while (true) {
						ds.receive(dp);
						String data = new String(dp.getData(), 0, dp.getLength());
						System.out.println(data);
					}
				} catch (Exception e) {
					ds.close();
				}
			}
		};
		new Thread(runnable).start();
	}

	public static void main(String[] args) throws Exception {
		new UdpReceiver().start();
	}
}
