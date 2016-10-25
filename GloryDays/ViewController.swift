//
//  ViewController.swift
//  GloryDays
//
//  Created by Edu on 21/10/16.
//  Copyright © 2016 Edu. All rights reserved.
//

import UIKit
import Speech
import Photos
import  AVFoundation


class ViewController: UIViewController {

    //MARK: LABEL
    @IBOutlet weak var infoLabel: UILabel!
    
    //MARK: VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK: MEMORY WARNING
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: BUTTON
    @IBAction func askForPermissions(_ sender: UIButton) {
        
        self.askForPhotosPermission()
        
    }
    //MARK: PERMISSIONS
    //MARK: 1-ASK FOR PHOTOS PERMISSION
    func askForPhotosPermission(){
        PHPhotoLibrary.requestAuthorization {[unowned self](authStatus) in
            
            //Enviar el siguiente bloque al hilo de ejecucion principal
            //Para poder actualizar la etiqueta o aceptar los permisos en tiempo real
            DispatchQueue.main.async{
                
                if authStatus == .authorized{
                    self.askForRecordPermission()
                }else{
                    self.infoLabel.text = "Debes aceptar los permisos desde Configuration/Permission"
                }
            }
        }
    }

    //MARK: 2-ASK FOR RECORD PERMISSION
    func askForRecordPermission(){
        
        AVAudioSession.sharedInstance().requestRecordPermission {[unowned self](allowed) in
            DispatchQueue.main.async {
                if allowed{
                    self.askForTranscriptionPermission()
                }else{
                    self.infoLabel.text = "Debes aceptar los permisos desde Configuration/Permission"
                }
            }
        }
        
    }

    //MARK: 3-ASK FOR TRANSCRIPTION PERMISSION
    func askForTranscriptionPermission(){
        SFSpeechRecognizer.requestAuthorization {[unowned self](authStatus) in
            DispatchQueue.main.async {
                if authStatus == .authorized{
                    self.authorizationCompleted()
                }else{
                    self.infoLabel.text = "Debes aceptar los permisos desde Configuration/Permission"
                }
            }
        }
        
    }
    
    //MARK: 4-AUTORIZED COMPLETED
    func authorizationCompleted(){
        
        //Oculta este View Controller
        dismiss(animated: true)
        
    }
    
     /*
     AÑADIR AL ARCHIVO info.plist LOS SIGUIENTES PARAMETROS DE DICCIONARIO
     NSPhotoLibraryUsageDescription       :  "Access to Camera Library"
     NSMicrophoneUsageDescription         :  "Access to Microphone"
     NSSpeechRecognitionUsageDescription  :  "Access to Voice Recognition"
     
     
     */
    
    

}

