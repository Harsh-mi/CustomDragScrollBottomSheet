# CustomDragScrollBottomSheet

## Installation

- To install this package, import `https://github.com/Harsh-mi/CustomDragScrollBottomSheet` in SPM.
- iOS version should be eqaul or greater than 13.0

## How to use CustomDragScrollBottomSheet

- First take a view controller in your storyboard.
- Then assign the class of your view controller `CustomDragScrollBottomSheetVC`.
- You need to add data in `arrayPostOptions` as per your requirement. For example

```swift

    let arrayData = [
        DropDownDataModel(image: "", data: "testing1"),
        DropDownDataModel(image: "ic_test", data: "testing2"),
        DropDownDataModel(image: "ic_test", data: "testing3")
    ]

let vc = self.storyboard?.instantiateViewController(withIdentifier: "CustomDragScrollBottomSheetVC") as? CustomDragScrollBottomSheetVC
vc?.arrayPostOptions = arrayData

```
- If you provide image name same like above example then your image will be displayed in the bottom sheet otherwise the default placeholder image will be displayed. 

- Then run the project and you can access custom bottom sheet and you can customize data of bottom sheet as per your requirement.
