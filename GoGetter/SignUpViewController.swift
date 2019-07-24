//
//  SignUpViewController.swift
//  GoGetter
//
//  Created by admin on 08/05/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit
import Photos
import AVKit
import Crashlytics
import AVFoundation
import UIImage_ImageCompress
import CropViewController

class SignUpViewController: FormViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GalleryViewControllerDelegates, CropViewControllerDelegate {
    enum Gender {
        case male
        case female
    }
    
    class UserForm {
        var phoneNumber: String?
        var firstName: String?
        var email: String?
        var password: String?
        var gender: Gender = .male
        var birthday: Date?
        var avatar1: UIImage? = nil
        var avatar2: UIImage? = nil
        	
        init() {
            //
        }
        
        init(phoneNumber: String?, firstName: String?, email: String?, password: String?, birthday: Date?, gender: Gender, avatar1: UIImage? = nil, avatar2: UIImage? = nil) {
            self.phoneNumber = phoneNumber
            self.birthday = birthday
            self.firstName = firstName
            self.email = email
            self.password = password
            self.gender = gender
        }
    }
    
    @IBOutlet weak var btnRegister: UIButton!
    
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblPassword1: UILabel!
    @IBOutlet weak var lblPassword2: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblEmailDescr: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var lblFemale: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    
    @IBOutlet weak var rbGenderMale: UIView!
    @IBOutlet weak var rbGenderFemale: UIView!
    
    @IBOutlet weak var editFirstName: CustomTextField!
    @IBOutlet weak var editPassword1: CustomTextField!
    @IBOutlet weak var editPassword2: CustomTextField!
    @IBOutlet weak var editEmail: CustomTextField!
    @IBOutlet weak var editBirthday: CustomTextField!
    
    @IBOutlet weak var dpContainer: UIView!
    @IBOutlet weak var dpDataPicker: UIDatePicker!
    @IBOutlet weak var dpContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewAvatar1: UIView!
    @IBOutlet weak var imgAvatar1: UIImageView!
    @IBOutlet weak var imgPhotoIcon1: UIImageView!
    @IBOutlet weak var viewAvatar2: UIView!
    @IBOutlet weak var imgAvatar2: UIImageView!
    @IBOutlet weak var imgPhotoIcon2: UIImageView!
    
    var dpContainerHeightConstraintDefault: CGFloat = 0.0
    
    var currentPhoneNumber: String? = nil
    var currentGender: Gender? = nil
    var currentData: Date? = nil
    var userForm: UserForm = UserForm()
    
    var isValidateEmail: Bool = false
    
    var selectedIndexPath: IndexPath?
    var previousIndexPath: IndexPath?
    var selectedAvatarIndex: Int = 0
    var selectedAvatar1: UIImage? = nil
    var selectedAvatar2: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // init forms
        self.initTextFields(fields: [
            editFirstName,
            editPassword1,
            editPassword2,
            editEmail,
            editBirthday
            ])
        
        // test values
//        editFirstName.text = "Test"
//        editEmail.text = "test@test.com"
//        editPassword1.text = "123456789"
//        editPassword2.text = "123456789"
//        isValidateEmail = true
//        currentGender = .male
//        currentData = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        
        // set phone
        lblPhone.text = currentPhoneNumber
        
        // hide button
        
        // initial
        userForm.phoneNumber = currentPhoneNumber
        
        // initial avatars
        self.initViewAvatar(view: self.viewAvatar1, img: self.imgAvatar1)
        self.initViewAvatar(view: self.viewAvatar2, img: self.imgAvatar2)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // buttons
        btnRegister.layer.cornerRadius = btnRegister.frame.size.height/2
        btnRegister.shadowButton(0.3, 2, .black, CGSize(width: 2, height: 2))
        btnRegister.isHidden = false;
        
        // init radio button
        initRadioButton(view: rbGenderMale)
        initRadioButton(view: rbGenderFemale)
        
        // text fields
        editBirthday.delegate = self
        editEmail.keyboardType = .emailAddress
        
        // targets
        editFirstName.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        editEmail.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        editPassword1.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        editPassword2.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        editEmail.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        // data picker
        dpContainer.layer.addBorder(edge: [.top], color: UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0), thickness: 1.5)
        dpDataPicker.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        dpDataPicker.minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dpContainerHeightConstraintDefault = dpContainerHeightConstraint.constant
        hideDataPicker(hide: true)
    }
    
    private func initRadioButton(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
        view.layer.borderColor = UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0).cgColor
        view.layer.borderWidth = 1.5
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapRadioButton(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
    }
    
    private func initViewAvatar(view: UIView, img: UIImageView) {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAvatar(_:))))
        
        view.layer.borderColor = self.editFirstName.layer.borderColor
        view.layer.borderWidth = self.editFirstName.layer.borderWidth
        view.layer.cornerRadius = self.editFirstName.layer.cornerRadius
        
        img.layer.borderColor = UIColor.clear.cgColor
        img.layer.borderWidth = self.editFirstName.layer.borderWidth
        img.layer.cornerRadius = self.editFirstName.layer.cornerRadius
        img.isHidden = true
    }
    
    private func hideDataPicker(hide: Bool) {
        if hide {
            dpContainerHeightConstraint.constant = 0
            dpContainer.isHidden = true
        } else {
            dpContainerHeightConstraint.constant = dpContainerHeightConstraintDefault
            dpContainer.isHidden = false
        }
    }
    
    func doUserError(message:String)->Bool{
        self.outAlertError(message:message)
        return false
    }
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    private func validateForm() ->Bool{
        if (selectedAvatar1 == nil){
            return doUserError(message: "Please select your first avatar")
        }
        
        if (selectedAvatar2 == nil){
            return doUserError(message: "Please select your second avatar")
        }
        
        if (editFirstName.text!.count < 1){
            return doUserError(message: "Please enter your name")
        }
        if (editPassword2.text!.count < 8){
            return doUserError(message: "password lengths must be at least 8 characters")
        }
        if (editPassword1.text != editPassword2.text){
            return doUserError(message:"The passwords must be the same");
        }
        if (!isValidEmail(testStr:editEmail.text!)){
            return doUserError(message:"You must enter a valid email address");
        }

        if (currentGender == nil){
            return doUserError(message:"Please select your gender");
        }
        if (currentData == nil){
            return doUserError(message:"Please select your birthday");
        }


        // check birth date at least 18
/*        Calendar now = Calendar.getInstance();
        
        int nowyear = now.get(Calendar.YEAR);
        int nowmonth = now.get(Calendar.MONTH)+1;
        int nowday = now.get(Calendar.DAY_OF_MONTH);
        if (nowyear - year <= 18)
        if (nowmonth <= month)
        if(nowday < day)
        return SLUtils.DoUserError( "You must be 18 years old to use GoGetter, please check your birthday");*/
        return true
    }

    // MARK: - Touches

    @IBAction func btnRegister(_ sender: Any) {
        
        if (validateForm()){
            userForm = UserForm(phoneNumber: currentPhoneNumber, firstName: editFirstName.text, email: editEmail.text, password: editPassword1.text, birthday: currentData, gender: currentGender ?? .male, avatar1: selectedAvatar1, avatar2: selectedAvatar2)
            
            if let newViewController = UIStoryboard(name: "SignIn", bundle:nil).instantiateViewController(withIdentifier: "PhoneViewController") as? PhoneViewController
            {
                newViewController.currentPhoneNumber = currentPhoneNumber
                newViewController.currentUser = userForm
                newViewController.fbLoginType = 2
                self.present(newViewController, animated: true)
            }
        }
            
    }
    
    private func rbGenderChange(view: UIView) {
        switch view {
        case rbGenderMale:
            currentGender = .male
        default:
            currentGender = .female
        }
        
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dpCancel(_ sender: Any) {
        currentData = nil
        hideDataPicker(hide: true)
    }
    
    @IBAction func dpDone(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        editBirthday.text = dateFormatter.string(from: dpDataPicker.date)
        currentData = dpDataPicker.date
        
        hideDataPicker(hide: true)
    }
    
    @objc func changeAvatar(_ sender:UITapGestureRecognizer){
        self.getGalleryImages()
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        self.selectedAvatarIndex = sender.view == self.viewAvatar1 ? 0 : 1
        self.selectedIndexPath = IndexPath.init(row: 0, section: 0)
        
        let actionSheet = UIAlertController(title: "Choose profile photo or video or take it.", message: nil, preferredStyle: .actionSheet)
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (action) in
            
            switch PHPhotoLibrary.authorizationStatus(){
            case .authorized:
                print("You can Access Photos.")
                
                let galleryController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryViewController") as? GalleryViewController
                galleryController?.fetchResult = self.allPhotos
                galleryController?.galleryDelegate = self as? GalleryViewControllerDelegates
                galleryController?.selectedIndex = self.selectedIndexPath!.item - 11
                self.present(galleryController!, animated: true, completion: nil)
            case .denied:
                self.showSettingAlert()
            case .notDetermined:
                print("Premission Alert Not Open.")
                self.getGalleryImages()
            case .restricted:
                print("Premissions Are resticted.")
            }
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.selectImageOrVideo()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        actionSheet.addAction(galleryAction)
        //        if selectedIndexPath?.item != 0{
        actionSheet.addAction(cameraAction)
        // }
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showSettingAlert(){
        let settingAction = action("Settings", .default) { (action) in
            let path = Bundle.main.bundleIdentifier
            let urlString = "\(UIApplication.openSettingsURLString)+\(path!)"
            UIApplication.shared.open(URL(string: urlString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
        let cancelAction = action("Cancel", .cancel) { (action) in
            
        }
        showAlertWithCustomButtons("GoGetter does not have access to your photos or videos, tap Settings and turn on Photos.", nil, settingAction,cancelAction)
    }
    
    @objc func selectImageOrVideo(){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let controller = UIImagePickerController()
            controller.sourceType = .camera
            controller.allowsEditing = true
            controller.delegate = self
            controller.cameraDevice = .front
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    //MARK:-  UIImagePickerController Delegates
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        let mediaType = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)]
        
//        if let type = mediaType{
//            if type is String{
//                let stringType = type as! String
//                if stringType == kUTTypeMovie as String{
//                    let urlOfVideo =  info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL
//                    if let url = urlOfVideo{
//                        let myasset = AVURLAsset(url: urlOfVideo!);
//                        self.imgViewProfile.image = self.thumbnailForVideoASSet(asset: myasset);
//                        DispatchQueue.main.async {
//                            self.playView(url);
//                            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
//                            self.compressVideo(inputURL: url as URL,asset: nil, outputURL: compressedURL) { (exportSession) in
//                                guard let session = exportSession else {
//                                    return
//                                }
//
//                                switch session.status {
//                                case .unknown:
//                                    break
//                                case .waiting:
//                                    break
//                                case .exporting:
//                                    break
//                                case .completed:
//                                    guard let compressedData = NSData(contentsOf: compressedURL) else {
//                                        return
//                                    }
//                                    print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
//                                    DispatchQueue.global(qos: .userInitiated).async {
//                                        // Bounce back to the main thread to update the UI
//                                        DispatchQueue.main.async {
//                                            self.deleteOldVideoFromDocumentDirectory()
//                                            self.writeVideoToDocumentDirectory(compressedData)
//                                            self.postVideoWithData(data: compressedData as Data, imageData: self.imgViewProfile.image!.jpegData(compressionQuality: 1.0)!)
//                                        }
//                                    }
//                                    print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
//                                case .failed:
//                                    break
//                                case .cancelled:
//                                    break
//                                }
//                            }
//
//                        }
//                    }
//                }else{
//                    self.imgViewProfile.isHidden = false
//                    self.viewVideoProfile.isHidden = true
//                    let vwCamera:UIView = self.scrollVwCamera.viewWithTag((selectedIndexPath?.row)!)!
//                    let openViewCamera:OpenCameraView = vwCamera.subviews[0] as! OpenCameraView
//                    openViewCamera.imgViewProfile.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
//                    openViewCamera.lblRecordVideo.text = "CHANGE PHOTO"
//                    if (self.selectedIndexPath?.item)! - 11 == 0 {
//                        DispatchQueue.main.async {
//                            self.postImageWithImage(image: info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as! UIImage, fileName: "profile_pic", type: "image")
//                            self.personalDetail["profile_pic"] = ""
//                        }
//                    }
//                    else {
//                        DispatchQueue.main.async {
//                            self.postImageWithImage(image: info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as! UIImage, fileName: String(format:"image%d",(self.selectedIndexPath?.item)!-11), type: "image")
//                            self.personalDetail[String(format:"image%d",(self.selectedIndexPath?.item)! - 11)] = ""
//                        }
//                    }
//
//                    profileImages[(selectedIndexPath!.item) - 12] = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as! UIImage
//                }
//            }
//        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:-  Gallery Methods(Get image permission and Gallery Controller Delegates)
    var galleryImages = [Any?]()
    var allPhotos: PHFetchResult<PHAsset>!
    
    func getGalleryImages(){
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        PHPhotoLibrary.shared().register(self)
    }
    
    func selectedAsset(_ asset: PHAsset!) {
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        if #available(iOS 11.0, *) {
            switch asset.playbackStyle {
            case .unsupported:
                let alertController = UIAlertController(title: NSLocalizedString("Unsupported Format", comment:""), message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
            case .image :
                self.setImage(asset)
            case .livePhoto:
                print("Live Image")
                self.setImage(asset)
            case .imageAnimated:
                print("Image Animated")
                self.setImage(asset)
            case .video:
                if asset != nil {
//                    selectedVideo(asset)
                }
                else {
                    let alertController = UIAlertController(title: NSLocalizedString("Asset Error", comment:""), message: "Selected asset is nil", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            case .videoLooping:
                print("Video Looping")
                if asset != nil {
//                    selectedVideo(asset)
                }
                else {
                    let alertController = UIAlertController(title: NSLocalizedString("Asset Error", comment:""), message: "Selected asset is nil", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            switch asset.mediaType{
            case .audio:
                let alertController = UIAlertController(title: NSLocalizedString("Unsupported Format", comment:""), message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
            case .video:
                if asset != nil {
//                    selectedVideo(asset)
                }
                else {
                    let alertController = UIAlertController(title: NSLocalizedString("Asset Error", comment:""), message: "Selected asset is nil", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            case .unknown:
                print("UNKnown")
            case .image:
                self.setImage(asset)
            }
        }
    }
    
    func setImage(_ asset: PHAsset){
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        PHImageManager.default().requestImageData(for: asset, options: options) { (data, details, orientations, info) in
            guard let imageData = data else { return }
            let image = UIImage(data: imageData)
            if let selectedImage = image{
                let cropViewController = CropViewController(image: selectedImage)
                cropViewController.delegate = self as? CropViewControllerDelegate
                cropViewController.aspectRatioPreset = CropViewControllerAspectRatioPreset.presetCustom
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.aspectRatioPickerButtonHidden = true
                cropViewController.customAspectRatio = CGSize(width: 222, height: 233)
                self.present(cropViewController, animated: true, completion: nil)
            }
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        
        cropViewController.dismiss(animated: true, completion: {
            if self.selectedAvatarIndex == 0 {
                self.imgAvatar1.image = image
                self.imgAvatar1.isHidden = false
                self.imgPhotoIcon1.isHidden = true
                self.selectedAvatar1 = image
            } else {
                self.imgAvatar2.image = image
                self.imgAvatar2.isHidden = false
                self.imgPhotoIcon2.isHidden = true
                self.selectedAvatar2 = image
            }
        })
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - Delegates
    
    @objc override func textFieldDidChange(_ textField: UITextField) {
        super.textFieldDidChange(textField)
        
        if textField == editEmail {
            isValidateEmail = false
            
            if textField.text != nil && textField.text!.isValidEmail() {
                isValidateEmail = true
            }
        }
        
    }
    
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if super.textFieldShouldBeginEditing(textField) {
            if textField == editBirthday {
                hideDataPicker(hide: false)
                self.hideKeyboard()
                return false;
            }
            
            return true
        }
        
        return false
    }
    
    @objc func handleTapRadioButton(_ sender: UITapGestureRecognizer? = nil) {
        rbGenderMale.backgroundColor = .clear
        rbGenderFemale.backgroundColor = .clear
        
        sender?.view?.backgroundColor = UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0)
        
        if sender?.view != nil {
            rbGenderChange(view: sender!.view!)
        }
    }
}

extension SignUpViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: allPhotos){
                allPhotos = changeDetails.fetchResultAfterChanges
                print(allPhotos)
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
