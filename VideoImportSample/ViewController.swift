import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @IBOutlet weak var thumbnailImgView: UIImageView!
  
  @IBAction func showVideoLibrary(_ sender: Any) {
    let sourceType = UIImagePickerController.SourceType.photoLibrary
    if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
      print("photoLibrary not available")
      return
    }
    let picker = UIImagePickerController()
    picker.sourceType = sourceType
    picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
    picker.mediaTypes = ["public.movie"]
    picker.videoExportPreset = AVAssetExportPresetPassthrough
    picker.delegate = self
    present(picker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let url = info[.mediaURL] as? URL {
      do {
        print(url) // file:///private/var/mobile/Containers/Data/PluginKitPlugin/...となる（/Applicationではなく/PluginKitPlugin）
        let asset = AVURLAsset(url: url, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        let thumbnail = UIImage(cgImage: cgImage)
        thumbnailImgView.image = thumbnail
      } catch let error {
        print("*** Error generating thumbnail: \(error.localizedDescription)")
      }
    }
    self.dismiss(animated: true, completion: nil)
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func clearTempFiles(_ sender: Any) {
    FileManager.default.clearTmpDirectory()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

// https://stackoverflow.com/questions/9196443/how-to-remove-tmp-directory-files-of-an-ios-app
extension FileManager {
  // 動画選択後でもtmpDirectoryにファイルは存在しないのでクリアしても意味なさそう
  func clearTmpDirectory() {
    do {
      let tmpDirURL = FileManager.default.temporaryDirectory
      print("tmpDirURL= \(tmpDirURL) ") // file:///private/var/mobile/Containers/Data/Application/....となる
      let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
      try tmpDirectory.forEach { file in
        let fileUrl = tmpDirURL.appendingPathComponent(file)
        print("remove fileUrl= \(fileUrl) ")
        try removeItem(atPath: fileUrl.path)
      }
    } catch {
      print("*** Error clearTmpDirectory: \(error.localizedDescription)")
    }
  }
}
