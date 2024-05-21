# CustomDragScrollBottomSheet

## Installation

- To install this package, import `https://github.com/Harsh-mi/CustomDragScrollBottomSheet` in SPM.
- iOS version should be eqaul or greater than 13.0

## How to use CustomDragScrollBottomSheet

- First take a view controller in your storyboard with button to open the bottom sheet on button action.
- You need to add data in `arrayPostOptions` as per your requirement.
- Then you can access the `CustomDragScrollBottomSheet` on button action as shown in below example:

```swift

    let arrayData = [
        DropDownDataModel(image: "", data: "testing1"),
        DropDownDataModel(image: "ic_test", data: "testing2"),
        DropDownDataModel(image: "ic_test", data: "testing3")
    ]

    @IBAction func actionShowBottomSheet(_ sender: UIButton) {
        let vc = CustomDragScrollBottomSheetVC()
        vc.selectedBottomSheetData = { data in
            self.labelOption.text = data.data
        }
        vc.arrayBottomSheetData = arrayOfData
        self.present(vc, animated: true)
    }

```
- You need to create an object of the `CustomDragScrollBottomSheet`, assign your custom `arrayOfData` to the `arrayBottomSheetData`.

- Here `vc.selectedBottomSheetData = { data in }` is the closure which will return selected data from the bottom sheet as a `DropDownDataModel` object.

- If you provide image name same like above example then your image will be displayed in the bottom sheet otherwise the default placeholder image will be displayed. 

- So after following these steps you need to call `self.present(vc, animated: true)` to display `CustomDragScrollBottomSheet` in your ViewController
