//
//  CarPlaySceneDelegate.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 09/09/2022.
//

// https://developer.apple.com/documentation/carplay/displaying_content_in_carplay
// https://medium.com/br-next/launching-br-radio-on-carplay-audio-8baab824b932#fbdf

import CarPlay
import FirebaseAnalytics

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {

    var TAG = String(describing: CarPlaySceneDelegate.self)
        
    var autoContentManager: AutoContentManager?
    
    // CarPlay connected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        
        GeneralUtils.log(TAG, "didConnect")
        
        Analytics.logEvent("car_connect", parameters: [
        "os": "iOS" as NSObject,
        "iOS": "text" as NSObject,
        ])
        
        
        // Store a reference to the interface controller so
        // you can add and remove templates as the user
        // interacts with your app.
        autoContentManager = AutoContentManager()
        autoContentManager?.interfaceController = interfaceController

        autoContentManager?.loadRootTemplate()
    }
    
    // CarPlay disconnected
    private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        GeneralUtils.log(TAG, "didDisconnect")
        
        onDisconnect()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        GeneralUtils.log(TAG, "sceneDidDisconnect")
        
        onDisconnect()
    }
    
    func onDisconnect() {
        autoContentManager = nil
    }
    
    static func getCarPlaySceneDelegate() -> CarPlaySceneDelegate? {
        var result: CarPlaySceneDelegate?
        
        for scene in UIApplication.shared.connectedScenes {
            if let carPlaySceneDelegate: CarPlaySceneDelegate = (scene.delegate as? CarPlaySceneDelegate) {
                result = carPlaySceneDelegate
                
                break
            }
        }
        
        return result
    }
}
