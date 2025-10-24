# PDF Manager iOS App  
**Repository:** [dias-btt/aezakmi_test](https://github.com/dias-btt/aezakmi_test)

## 🎯 Project Overview  
A SwiftUI iOS application that enables users to create and manage PDF documents by importing images or PDF files, editing pages, combining PDFs, and sharing the results.  
Built with iOS 15+ in mind, using MVVM architecture, Core Data (or file system storage), and PDFKit.

## 🚀 Key Features  
- Import images from the photo gallery (multi-select) or import existing PDF files.  
- Convert imported images into a new PDF document.  
- View list of saved PDF documents — each shows a thumbnail of page 1, file name, extension, creation date.  
- Open a PDF document in a reader:  
  - Delete individual pages by selecting them.  
  - Add more pages either from files or gallery.  
  - Merge multiple PDFs into a new one.  
  - Share the document via the system share sheet.  
- Clean SwiftUI UI with modular views (scroll view of thumbnails, action buttons view, etc).  
- Uses `PDFKit`, `PHPickerViewController`, `.fileImporter`, and native share workflows.

## 🧱 Architecture & Implementation  
- **UI Framework:** SwiftUI (iOS 15+).  
- **Architecture:** MVVM — `ViewModels` encapsulate business logic; `Models`/services handle file & PDF operations.  
- **PDF Handling:**  
  - Uses `PDFDocument` from `PDFKit`.  
  - Converts `UIImage` to `PDFPage`, merges pages, deletes, writes back to disk.  
- **Pickers:**  
  - `ImagePicker` — a `UIViewControllerRepresentable` wrapper around `PHPickerViewController` for selecting images.  
  - `.fileImporter` — for selecting PDF or image files from the Files app.  
- **Storage:** Documents are saved in the app’s Documents directory.  
- **Views:** Modular components like `SelectedImagesScrollView`, `ActionButtonsView`, `LoadingOverlayView` for UI clarity.

## ✅ Setup & Running  
1. Clone the repository:  
   ```bash
   git clone https://github.com/dias-btt/aezakmi_test.git
  Open the project in Xcode (14 or later), target iOS 15+.
2. Build and run on a simulator or device.
3. Grant permissions when prompted (photo library access, file access).
4. Use the Welcome screen to create documents and manage them.
