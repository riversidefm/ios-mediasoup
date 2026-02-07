import Foundation
import WebRTC
import Mediasoup_Private


public class SendTransport {
	public weak var delegate: SendTransportDelegate?

	public let transport: SendTransportWrapper

	internal init(transport: SendTransportWrapper) {
		self.transport = transport
		transport.delegate = self
	}

	deinit {
		print("SendTransport deallocated")
	}

	public func createProducer(
		for track: RTCMediaStreamTrack,
		encodings: [RTCRtpEncodingParameters]?,
		codecOptions: String?,
		codec: String?,
		appData: String?
	) throws -> Producer {

		guard let mediaKind = MediaKind(stringValue: track.kind) else {
			throw MediasoupError.invalidParameters("Unknown media kind")
		}

		return try convertMediasoupErrors {
			let producer = try self.transport.createProducer(for: track, encodings: encodings,
				codecOptions: codecOptions, codec: codec, appData: appData)
			return Producer(producer: producer, mediaKind: mediaKind)
		}
	}
}

extension SendTransport: Transport {
	public var id: String {
		return transport.id
	}

	public var closed: Bool {
		return transport.closed
	}

	public var connectionState: TransportConnectionState {
		return TransportConnectionState(stringValue: transport.connectionState) ?? .failed
	}

	public var appData: String {
		return transport.appData
	}

	@available(*, deprecated, message: "Use getStats() throws instead")
	public var stats: String {
		return (try? getStats()) ?? "[]"
	}

	public func getStats() throws -> String {
		try convertMediasoupErrors {
			try transport.getStats()
		}
	}

	public func close() {
		transport.close()
	}

	public func restartICE(with iceParameters: String) throws {
		try convertMediasoupErrors {
			try transport.restartICE(iceParameters)
		}
	}

	public func updateICEServers(_ iceServers: String) throws {
		try convertMediasoupErrors {
			try transport.updateICEServers(iceServers)
		}
	}
}

extension SendTransport: SendTransportWrapperDelegate {
	public func onConnect(_ transport: SendTransportWrapper, dtlsParameters: String) {
		guard transport == self.transport else {
			return
		}

		delegate?.onConnect(transport: self, dtlsParameters: dtlsParameters)
	}

	public func onConnectionStateChange(
		_ transport: SendTransportWrapper,
		connectionState: MediasoupClientTransportConnectionState) {

		guard transport == self.transport,
			let state = TransportConnectionState(stringValue: connectionState.rawValue) else {

			return
		}

		delegate?.onConnectionStateChange(transport: self, connectionState: state)
	}

	public func onProduce(_ transport: SendTransportWrapper, kind: String, rtpParameters: String,
		appData: String, callback: @escaping (String?) -> Void) {

		guard transport == self.transport else {
			callback(nil)
			return
		}

		guard let mediaKind = MediaKind(stringValue: kind) else {
			print("Failed to parse media kind value: \(kind)")
			callback(nil)
			return
		}

		Task { [weak self] in
			guard let self else {
				callback(nil)
				return
			}
			let result = await delegate?.onProduce(
				transport: self,
				kind: mediaKind,
				rtpParameters: rtpParameters,
				appData: appData
			)
			callback(result)
		}
	}

	public func onProduceData(_ transport: SendTransportWrapper, sctpParameters: String,
		label: String, protocol dataProtocol: String, appData: String, callback: @escaping (String?) -> Void) {

		guard transport == self.transport else {
			callback(nil)
			return
		}

		Task { [weak self] in
			guard let self else {
				callback(nil)
				return
			}
			let result = await delegate?.onProduceData(
				transport: self,
				sctpParameters: sctpParameters,
				label: label,
				protocol: dataProtocol,
				appData: appData
			)
			callback(result)
		}
	}
}
