//
//  MemoriesCollectionVC.swift
//  GloryDays
//
//  Created by Edu on 21/10/16.
//  Copyright © 2016 Edu. All rights reserved.
//

import UIKit

import Speech
import Photos
import  AVFoundation

    //MARK: GLOBAL VARIABLES
private let reuseIdentifier = "Cell"

// MARK: CLASS
class MemoriesCollectionVC: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: VARIABLES
    var memories:[URL] = []

    // MARK: VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadMemories()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addImagePressed))

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self,
                                      forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    //MARK: VIEW DID APPEAR
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.checkForGrantedPermissions()
        
    }
    
    // MARK: DID RECEIVE MEMORY WARNING
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // CHECK PERMISSIONS
    func checkForGrantedPermissions(){
        
        let photosAuth: Bool = PHPhotoLibrary.authorizationStatus() == .authorized
        let recordingAuth: Bool = AVAudioSession.sharedInstance().recordPermission() == .granted
        let transcriptionAuth: Bool = SFSpeechRecognizer.authorizationStatus() == .authorized
        
        let authorized = photosAuth && recordingAuth && transcriptionAuth
        if !authorized {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "ShowTerms") {
                navigationController?.present(vc, animated: true)
            }
        }
    }
    
    //
    func loadMemories(){
        self.memories.removeAll()
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil, options: []) else {
            return
        }
        
        for file in files {
             let fileName = file.lastPathComponent
                if fileName.hasSuffix(".thumb"){
                    let noExtension = fileName.replacingOccurrences(of: ".thumb", with: "")
                    
                    if let memoryPath = try? getDocumentsDirectory().appendingPathComponent(noExtension){
                        memories.append(memoryPath)
                    }
                }
        }
        collectionView?.reloadSections(IndexSet(integer: 1))
    }
    
    //
    func getDocumentsDirectory()-> URL{
        
        //Necesitams un gestor de archivos
        let paths = FileManager.default.urls(for: .documentDirectory, in: .localDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func addImagePressed(){
        // Creamos picker controller
        let vc = UIImagePickerController()
        //de damos estilo
        vc.modalPresentationStyle = .formSheet
        //Nosotros somos el delegado
        vc.delegate = self
        
        navigationController?.present(vc, animated: true)
        
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Si esto me devuelve una UIImagen
        if let theImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self .addNewMemory(image: theImage)
            //Se refresca la pantalla con la imagen
            self.loadMemories()
        }
    }
    
    
    // MARK: ADD A NEW IMAGEN
    func addNewMemory(image: UIImage){
        //Este es el nombre que le damos al archivo.
        //Esto nos devuelve un numero muy largo
        let memoryName = "memory-\(Date().timeIntervalSince1970)"
        
        let imageName = "\(memoryName).jpg"
        let thumbName = "\(memoryName).thumb"
        
        do{
            // MARK: Esto es la imagen
            //recuperar la URL donde guardamos el jpg en una carpeta en los archivos de usuario llamada imageName
            let imagePath = try getDocumentsDirectory().appendingPathComponent(imageName)
            //Hay que guardar la imagen en un OBJETO de bits 
            //que reconozca el sistema con la clase NSData
            //Si consigo construir en mapa de bits guardo en el imagePath
            //Parametros, la imagen y compresión en porcentaje
            //(0 es sin comprimir y ocupa más y 1 alreves)
            if let jpejData = UIImageJPEGRepresentation(image, 80){
                try jpejData.write(to: imagePath, options: [.atomicWrite])
            }
            
            // MARK: Esto es para crear el thumb
            //Hay que reescalar las imagenes y para eso creamos una nueva funcion llamada resizeImages()
            // Si puede hacer la miniatura
            if let thumbnail = resizeImages(image: image, to: 200){
                // MARK: Esto es la imagen
                //recuperar la URL donde guardamos el jpg en una carpeta en los archivos de usuario llamada imageName
                let thumbPath = try getDocumentsDirectory().appendingPathComponent(thumbName)
                //Hay que guardar la imagen en un OBJETO de bits
                //que reconozca el sistema con la clase NSData
                //Si consigo construir en mapa de bits guardo en el imagePath
                //Parametros, la imagen y compresión en porcentaje
                //(0 es sin comprimir y ocupa más y 1 alreves)
                if let jpejData = UIImageJPEGRepresentation(thumbnail, 80){
                    try jpejData.write(to: thumbPath, options: [.atomicWrite])
                }
            }
        }catch{
            print("Ha fallado la escritura en disco")
        }
        
    }

    // MARK: RESIZE IMAGEN PARA THUMB
    func resizeImages(image: UIImage, to width:CGFloat) -> UIImage?{
        //Calculo el factor de escalado que debo reducir
        //-----------------200px-2000px--=--0.10(osea 10%)Mantiene AspectRatio
        let scaleFactor = width / image.size.width
        //Recortamos la imagen para un nuevo lienzo
        let height = image.size.height * scaleFactor
        //Redimensionamos una imagen
        //El false es para indicar que no queremos ningun fondo tranparente y el 0 que es el de 
        // la resolución de el dispositivo que sea
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        // Redibujara la imagen real a este nuevo rectangulo
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        //Creamos una nueva imagen desde la anterior extrallendola a newImage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //Con esto indicamos que hemos terminado la edicion
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
    
    func imageURL(for memory: URL) ->URL{
        return try! memory.appendPathExtension("jpg")
    }

    func thumbURL(for memory: URL) ->URL{
        return try! memory.appendPathExtension("thumb")
    }
    
    func audioURL(for memory: URL) ->URL{
        return try! memory.appendPathExtension("m4a")
    }
    
    func transcriptionURL(for memory: URL) ->URL{
        return try! memory.appendPathExtension("txt")
    }
    
    
    // MARK: DELEGATES
    // MARK: UICOLLECTION VIEW DATA SOURCE

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        // Una para el header buscador y otra para las imagenes
        return 2
    }


    // MARK: COLLECTION VIEW NUMBERS OF ITEM IN SECTION
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //
        if section == 0{
            return 0
        }else{
            return self.memories.count
        }
    }

    // MARK: COLLECTION VIEW CELL FOR ITEM AT
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICOLLECTION VIEW DELEGATE

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
