//
//  MediaPlayerManagerMQTTClient.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import CocoaMQTT

// https://github.com/emqx/CocoaMQTT
// https://github.com/emqx/CocoaMQTT/blob/master/Example/Example/ViewController.swift

class MediaPlayerManagerMQTTClient: NSObject {
    
    let TAG = String(describing: MediaPlayerManagerMQTTClient.self)
    
    static let EVENT_ON_MQTT_NEW_INFORMATION_RECEIVED = "EVENT_ON_MQTT_NEW_INFORMATION_RECEIVED"
    
    // We keep received payload in this variable, which is accessed when LargePlayerVC is launched.
    static var lastKnownReceivedPayload: String?
    
    var client: CocoaMQTT5!
    
    func connect() {
        GeneralUtils.log(TAG, "Connecting...")
        
        guard let mqttConfig = Bundle.main.infoDictionary?["MQTT"] as? [String: Any],
              let host = mqttConfig["Host"] as? String,
              let port = mqttConfig["Port"] as? Int else {
            GeneralUtils.log(TAG, "MQTT configuration not found in Info.plist")
            return
        }
        
        // MQTT 5.0
        let clientID = "lrios_\(GeneralUtils.getAppVersion(longVersion: true))_\(String(ProcessInfo().processIdentifier))"
        
        client = CocoaMQTT5(clientID: clientID, host: host, port: UInt16(port))
        client.enableSSL = true
        client.autoReconnect = true
        client.keepAlive = 60
        client.delegate = self

        let _ = client.connect()
    }
    
    func disconnect() {
        MediaPlayerManagerMQTTClient.lastKnownReceivedPayload = nil
        
        if (client != nil) {
            client.disconnect()
        }
    }

    func notifyOnMqttNewInformationReceived(_ payload: String) {
        NotificationCenter.default.post(
            name: Notification.Name(MediaPlayerManagerMQTTClient.EVENT_ON_MQTT_NEW_INFORMATION_RECEIVED),
            object: nil,
            userInfo: [MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY: payload as Any]
        )
    }
    
    static func canShowAdditionalPlaybackInfo() -> Bool {
        var result = false
        
        if (MediaPlayerManager.getInstance().currentLivestream != nil &&
            MediaPlayerManager.getInstance().currentLivestream?.have_mqtt == true /*getStationIdInMqttService() != nil*/) {
            result = true
        }
        
        return result
    }
    
    static func getPlaybackAdditionalDataFromPayload(_ payload: String?) -> String? {
        var playbackAdditionalData: String?
        
        if let payload = payload {
            if let payloadAsData = payload.data(using: .utf8) {
                let payloadJson = try? JSONSerialization.jsonObject(with: payloadAsData, options: [])
                if let payloadJson = payloadJson as? [String: Any] {
                    var artist = payloadJson["original_artist"] as? String
                    var title = payloadJson["original_title"] as? String
                    
                    if (artist == nil) {
                        artist = payloadJson["artist"] as? String
                    }
                    
                    if (title == nil) {
                        title = payloadJson["title"] as? String
                    }
                    
                    if (artist != nil && title != nil) {
                        playbackAdditionalData = artist! + " - " + title!
                    }
                }
            }
        }
        
        return playbackAdditionalData
    }
}

extension MediaPlayerManagerMQTTClient: CocoaMQTT5Delegate {
    func mqtt5(_ mqtt5: CocoaMQTT5, didConnectAck ack: CocoaMQTTCONNACKReasonCode, connAckData: MqttDecodeConnAck?) {
        GeneralUtils.log(TAG, "didConnectAck")

        if ack == .success {
            GeneralUtils.log(TAG, "Subscribing...")

            if let stationIdInMqttService = MediaPlayerManager.getInstance().currentLivestream?.have_mqtt /*?.getStationIdInMqttService()*/,
               stationIdInMqttService == true {
                let subscription = MqttSubscription(topic: "lr/" + /*stationIdInMqttService*/ String(describing:  MediaPlayerManager.getInstance().currentLivestream?.id ) + "/live")
                subscription.retainHandling = .sendOnSubscribe
                mqtt5.subscribe([subscription])
            }
        }
    }

    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishMessage message: CocoaMQTT5Message, id: UInt16) { }

    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishAck id: UInt16, pubAckData: MqttDecodePubAck?) { }

    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishRec id: UInt16, pubRecData: MqttDecodePubRec?) { }

    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveMessage message: CocoaMQTT5Message, id: UInt16, publishData: MqttDecodePublish?) {
        GeneralUtils.log(TAG, "didReceiveMessage")

        let payloadAsString = message.string?.description ?? ""

        MediaPlayerManagerMQTTClient.lastKnownReceivedPayload = payloadAsString

        notifyOnMqttNewInformationReceived(payloadAsString)
    }

    func mqtt5(_ mqtt5: CocoaMQTT5, didSubscribeTopics success: NSDictionary, failed: [String], subAckData: MqttDecodeSubAck?) {
        GeneralUtils.log(TAG, "didSubscribeTopics")
    }

    func mqtt5(_ mqtt5: CocoaMQTT5, didUnsubscribeTopics topics: [String], unsubAckData: MqttDecodeUnsubAck?) {
        GeneralUtils.log(TAG, "didUnsubscribeTopics")
    }

    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveDisconnectReasonCode reasonCode: CocoaMQTTDISCONNECTReasonCode) { }

    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveAuthReasonCode reasonCode: CocoaMQTTAUTHReasonCode) { }

    func mqtt5DidPing(_ mqtt5: CocoaMQTT5) {
        GeneralUtils.log(TAG, "mqttDidPing")
    }

    func mqtt5DidReceivePong(_ mqtt5: CocoaMQTT5) {
        GeneralUtils.log(TAG, "mqttDidReceivePong")
    }

    func mqtt5DidDisconnect(_ mqtt5: CocoaMQTT5, withError err: Error?) {
        GeneralUtils.log(TAG, "mqttDidDisconnect")
    }
}
