package com.shinelith.dcs.realtime;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.util.Scanner;

public class UdpSender {
	public final int PORT = 46587;
	public final String HOST = "127.0.0.1";

	public void start() throws IOException {
		Scanner s = new Scanner(System.in);
		System.out.println("DCS-ME-Realtime UDP Sender Start");

		while (true) {
			String line = s.nextLine();
			if (line.toLowerCase().equals("exit")) {
				s.close();
				System.out.println("bye!");
				System.exit(0);
			}
			send(line);
		}
	}

	public void send(String d) throws IOException {
		DatagramSocket ds = new DatagramSocket();
		byte[] buf = d.getBytes();
		DatagramPacket dp = new DatagramPacket(buf, buf.length, InetAddress.getByName(HOST), PORT);
		ds.send(dp);
		ds.close();
	}

	public static void main(String[] args) throws Exception {
		UdpSender sender = new UdpSender();
		sender.start();
	}
}
