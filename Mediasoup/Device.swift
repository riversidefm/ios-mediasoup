import Foundation
import Mediasoup_Private
import WebRTC


open class Device {
    
	private let device: DeviceWrapper

    public init(audioDevice: RTCAudioDevice? = nil) {
        self.device = DeviceWrapper(audioDevice: audioDevice)
	}

	public func isLoaded() -> Bool {
		return device.isLoaded()
	}

	public func load(with routerRTPCapabilities: String) throws {
		try convertMediasoupErrors {
			try device.load(with: routerRTPCapabilities)
		}
	}

	public func rtpCapabilities() throws -> String {
		try convertMediasoupErrors {
			try device.rtpCapabilities()
		}
	}

	public func sctpCapabilities() throws -> String {
		try convertMediasoupErrors {
			try device.sctpCapabilities()
		}
	}

	public func canProduce(_ mediaKind: MediaKind) throws -> Bool {
		try convertMediasoupErrors {
			try device.canProduce(mediaKind.mediaClientValue)
		}
	}

	open func createSendTransport(id: String, iceParameters: String, iceCandidates: String,
		dtlsParameters: String, sctpParameters: String?, iceServers: String? = nil,
		iceTransportPolicy: ICETransportPolicy = .all, appData: String?) throws -> SendTransport {

		return try convertMediasoupErrors {
			let transport = try device.createSendTransport(withId: id, iceParameters: iceParameters,
				iceCandidates: iceCandidates, dtlsParameters: dtlsParameters, sctpParameters: sctpParameters,
				iceServers: iceServers, iceTransportPolicy: iceTransportPolicy.rtcICETransportPolicy,
				appData: appData)

			return SendTransport(transport: transport)
		}
	}

	open func createReceiveTransport(id: String, iceParameters: String, iceCandidates: String,
		dtlsParameters: String, sctpParameters: String? = nil, iceServers: String? = nil,
		iceTransportPolicy: ICETransportPolicy = .all, appData: String? = nil) throws -> ReceiveTransport {

		return try convertMediasoupErrors {
			let transport = try device.createReceiveTransport(withId: id, iceParameters: iceParameters,
				iceCandidates: iceCandidates, dtlsParameters: dtlsParameters, sctpParameters: sctpParameters,
				iceServers: iceServers, iceTransportPolicy: iceTransportPolicy.rtcICETransportPolicy,
				appData: appData)

			return ReceiveTransport(transport: transport)
		}
	}
}
